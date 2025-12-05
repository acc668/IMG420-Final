#include "item_generation_service.h"
#include "json_utils.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/classes/json.hpp>
#include <sstream>
#include <algorithm>

using namespace godot;

namespace necronomicore {

Dictionary ItemDefinition::to_dictionary() const {
    Dictionary dict;
    dict["name"] = String(name.c_str());
    dict["description"] = String(description.c_str());
    dict["type"] = static_cast<int>(type);
    dict["rarity"] = static_cast<int>(rarity);
    dict["damage"] = damage;
    dict["defense"] = defense;
    dict["healing"] = healing;
    dict["cooldown"] = cooldown;
    dict["flavor_text"] = String(flavor_text.c_str());
    dict["sprite_hint"] = String(sprite_hint.c_str());
    
    Array effects_array;
    for (const auto& effect : effects) {
        effects_array.append(String(effect.c_str()));
    }
    dict["effects"] = effects_array;
    
    return dict;
}

ItemDefinition ItemDefinition::from_json(const std::string& json) {
    ItemDefinition item;
    Dictionary dict = JSONUtils::parse_json(json);
    
    item.name = JSONUtils::get_string(dict, "name", "Unknown Item");
    item.description = JSONUtils::get_string(dict, "description", "");
    item.damage = JSONUtils::get_int(dict, "damage", 0);
    item.defense = JSONUtils::get_int(dict, "defense", 0);
    item.healing = JSONUtils::get_int(dict, "healing", 0);
    item.cooldown = JSONUtils::get_float(dict, "cooldown", 0.0f);
    item.flavor_text = JSONUtils::get_string(dict, "flavor_text", "");
    item.sprite_hint = JSONUtils::get_string(dict, "sprite_hint", "");
    
    // Parse rarity
    std::string rarity_str = JSONUtils::get_string(dict, "rarity", "common");
    std::transform(rarity_str.begin(), rarity_str.end(), rarity_str.begin(), ::tolower);
    
    if (rarity_str == "uncommon") item.rarity = ItemRarity::UNCOMMON;
    else if (rarity_str == "rare") item.rarity = ItemRarity::RARE;
    else if (rarity_str == "epic") item.rarity = ItemRarity::EPIC;
    else if (rarity_str == "legendary") item.rarity = ItemRarity::LEGENDARY;
    else if (rarity_str == "cursed") item.rarity = ItemRarity::CURSED;
    else item.rarity = ItemRarity::COMMON;
    
    // Parse type
    std::string type_str = JSONUtils::get_string(dict, "type", "weapon");
    std::transform(type_str.begin(), type_str.end(), type_str.begin(), ::tolower);
    
    if (type_str == "armor") item.type = ItemType::ARMOR;
    else if (type_str == "consumable") item.type = ItemType::CONSUMABLE;
    else if (type_str == "relic") item.type = ItemType::RELIC;
    else if (type_str == "artifact") item.type = ItemType::ARTIFACT;
    else item.type = ItemType::WEAPON;
    
    return item;
}

ItemGenerationService::ItemGenerationService(std::shared_ptr<OpenAIClient> openai_client)
    : client(openai_client) {
    initialize_fallback_pool();
}

ItemGenerationService::~ItemGenerationService() {
}

std::string ItemGenerationService::build_item_generation_prompt(const Dictionary& run_config) {
    int difficulty = run_config.get("difficulty", 1);
    int floor_number = run_config.get("floor", 1);
    String theme = run_config.get("theme", "lovecraftian fungal dungeon");
    
    std::ostringstream prompt;
    prompt << "Generate a pool of items for a roguelike dungeon crawler game. ";
    prompt << "Theme: " << theme.utf8().get_data() << ". ";
    prompt << "Difficulty level: " << difficulty << ", Floor: " << floor_number << ". ";
    prompt << "\n\nRespond with ONLY a JSON array (no markdown, no explanation), using this exact format:\n";
    prompt << "[\n";
    prompt << "  {\n";
    prompt << "    \"name\": \"Item Name\",\n";
    prompt << "    \"description\": \"Brief description\",\n";
    prompt << "    \"type\": \"weapon\",\n";
    prompt << "    \"rarity\": \"common\",\n";
    prompt << "    \"damage\": 10,\n";
    prompt << "    \"defense\": 0,\n";
    prompt << "    \"healing\": 0,\n";
    prompt << "    \"cooldown\": 1.0,\n";
    prompt << "    \"flavor_text\": \"Atmospheric description\",\n";
    prompt << "    \"sprite_hint\": \"Visual description for artists\"\n";
    prompt << "  },\n";
    prompt << "  {\"name\": \"Item 2\", ...}\n";
    prompt << "]\n\n";
    prompt << "Generate 10 items with varied rarities (common, uncommon, rare, epic, legendary, cursed). ";
    prompt << "Items should fit the Lovecraftian fungal theme with names inspired by mushrooms and cosmic horror. ";
    prompt << "Types can be: weapon, armor, consumable, relic, or artifact.";
    
    return prompt.str();
}

std::vector<ItemDefinition> ItemGenerationService::parse_item_array(const std::string& json) {
    std::vector<ItemDefinition> items;
    
    Dictionary response = JSONUtils::parse_json(json);
    
    // Handle OpenAI response format: response.choices[0].message.content
    if (JSONUtils::has_key(response, "choices")) {
        Array choices = JSONUtils::get_array(response, "choices");
        if (choices.size() > 0) {
            Dictionary first_choice = choices[0];
            Dictionary message = JSONUtils::get_dict(first_choice, "message");
            std::string content = JSONUtils::get_string(message, "content");
            
            // The content is a JSON string, parse it
            // GPT might return just an array like: [{item1}, {item2}, ...]
            Ref<JSON> json_parser;
            json_parser.instantiate();
            Error err = json_parser->parse(String(content.c_str()));
            
            if (err == OK) {
                Variant content_data = json_parser->get_data();
                
                // Check if it's directly an array
                if (content_data.get_type() == Variant::ARRAY) {
                    Array items_array = content_data;
                    for (int i = 0; i < items_array.size(); i++) {
                        if (items_array[i].get_type() == Variant::DICTIONARY) {
                            Dictionary item_dict = items_array[i];
                            ItemDefinition item = ItemDefinition::from_json(JSONUtils::stringify_json(item_dict));
                            validate_and_clamp_item(item);
                            items.push_back(item);
                        }
                    }
                }
                // Or if it's a dict with "items" key
                else if (content_data.get_type() == Variant::DICTIONARY) {
                    Dictionary content_dict = content_data;
                    if (content_dict.has(Variant("items"))) {
                        Variant items_var = content_dict[Variant("items")];
                        if (items_var.get_type() == Variant::ARRAY) {
                            Array items_array = items_var;
                            for (int i = 0; i < items_array.size(); i++) {
                                if (items_array[i].get_type() == Variant::DICTIONARY) {
                                    Dictionary item_dict = items_array[i];
                                    ItemDefinition item = ItemDefinition::from_json(JSONUtils::stringify_json(item_dict));
                                    validate_and_clamp_item(item);
                                    items.push_back(item);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return items;
}

void ItemGenerationService::validate_and_clamp_item(ItemDefinition& item) {
    // Clamp stats based on rarity
    int max_stat = 10;
    switch (item.rarity) {
        case ItemRarity::COMMON: max_stat = 15; break;
        case ItemRarity::UNCOMMON: max_stat = 30; break;
        case ItemRarity::RARE: max_stat = 50; break;
        case ItemRarity::EPIC: max_stat = 75; break;
        case ItemRarity::LEGENDARY: max_stat = 100; break;
        case ItemRarity::CURSED: max_stat = 150; break; // Can be powerful but dangerous
    }
    
    item.damage = std::clamp(item.damage, 0, max_stat);
    item.defense = std::clamp(item.defense, 0, max_stat);
    item.healing = std::clamp(item.healing, 0, max_stat * 2);
    item.cooldown = std::clamp(item.cooldown, 0.0f, 60.0f);
}

void ItemGenerationService::initialize_fallback_pool() {
    // Create some basic fallback items in case API is unavailable
    ItemDefinition sword;
    sword.name = "Rusty Blade";
    sword.description = "A worn weapon covered in fungal growth";
    sword.type = ItemType::WEAPON;
    sword.rarity = ItemRarity::COMMON;
    sword.damage = 10;
    sword.flavor_text = "Even decay has its uses.";
    
    fallback_pool.common_items.push_back(sword);
    fallback_pool.pool_id = "fallback";
    fallback_pool.theme = "emergency_pool";
}

void ItemGenerationService::generate_item_pool(const Dictionary& run_config,
                                               std::function<void(const std::string&)> on_success,
                                               std::function<void(const std::string&)> on_error) {
    std::string pool_id = "pool_" + std::to_string(cached_pools.size());
    std::string prompt = build_item_generation_prompt(run_config);
    
    Array messages;
    Dictionary user_message;
    user_message[Variant("role")] = Variant("user");
    user_message[Variant("content")] = Variant(String(prompt.c_str()));
    messages.append(user_message);
    
    client->chat_completion(messages, "gpt-3.5-turbo", 0.8, 2000,
        [this, pool_id, on_success, on_error](const HTTPResponse& response) {
            if (response.success) {
                std::vector<ItemDefinition> items = parse_item_array(response.body);
                
                if (items.empty()) {
                    on_error("Failed to parse items from API response");
                    return;
                }
                
                ItemPool pool;
                pool.pool_id = pool_id;
                
                // Organize by rarity
                for (const auto& item : items) {
                    switch (item.rarity) {
                        case ItemRarity::COMMON: pool.common_items.push_back(item); break;
                        case ItemRarity::UNCOMMON: pool.uncommon_items.push_back(item); break;
                        case ItemRarity::RARE: pool.rare_items.push_back(item); break;
                        case ItemRarity::EPIC: pool.epic_items.push_back(item); break;
                        case ItemRarity::LEGENDARY: pool.legendary_items.push_back(item); break;
                        case ItemRarity::CURSED: pool.cursed_items.push_back(item); break;
                    }
                }
                
                cached_pools[pool_id] = pool;
                on_success(pool_id);
            } else {
                on_error(response.error_message);
            }
        }
    );
}

std::string ItemGenerationService::generate_item_pool_sync(const Dictionary& run_config) {
    std::string pool_id = "pool_" + std::to_string(cached_pools.size());
    std::string prompt = build_item_generation_prompt(run_config);
    
    Array messages;
    Dictionary user_message;
    user_message[Variant("role")] = Variant("user");
    user_message[Variant("content")] = Variant(String(prompt.c_str()));
    messages.append(user_message);
    
    HTTPResponse response = client->chat_completion_sync(messages, "gpt-3.5-turbo", 0.8, 2000);
    
    if (!response.success) {
        return "fallback";
    }
    
    std::vector<ItemDefinition> items = parse_item_array(response.body);
    if (items.empty()) {
        return "fallback";
    }
    
    ItemPool pool;
    pool.pool_id = pool_id;
    
    for (const auto& item : items) {
        switch (item.rarity) {
            case ItemRarity::COMMON: pool.common_items.push_back(item); break;
            case ItemRarity::UNCOMMON: pool.uncommon_items.push_back(item); break;
            case ItemRarity::RARE: pool.rare_items.push_back(item); break;
            case ItemRarity::EPIC: pool.epic_items.push_back(item); break;
            case ItemRarity::LEGENDARY: pool.legendary_items.push_back(item); break;
            case ItemRarity::CURSED: pool.cursed_items.push_back(item); break;
        }
    }
    
    cached_pools[pool_id] = pool;
    return pool_id;
}

Dictionary ItemGenerationService::get_random_item(const std::string& pool_id, ItemRarity rarity) {
    const ItemPool* pool = &fallback_pool;
    
    if (cached_pools.find(pool_id) != cached_pools.end()) {
        pool = &cached_pools[pool_id];
    }
    
    const std::vector<ItemDefinition>* items_vec = nullptr;
    
    switch (rarity) {
        case ItemRarity::COMMON: items_vec = &pool->common_items; break;
        case ItemRarity::UNCOMMON: items_vec = &pool->uncommon_items; break;
        case ItemRarity::RARE: items_vec = &pool->rare_items; break;
        case ItemRarity::EPIC: items_vec = &pool->epic_items; break;
        case ItemRarity::LEGENDARY: items_vec = &pool->legendary_items; break;
        case ItemRarity::CURSED: items_vec = &pool->cursed_items; break;
    }
    
    if (!items_vec || items_vec->empty()) {
        return fallback_pool.common_items[0].to_dictionary();
    }
    
    int index = rand() % items_vec->size();
    return (*items_vec)[index].to_dictionary();
}

Dictionary ItemGenerationService::get_random_item_any_rarity(const std::string& pool_id) {
    ItemRarity rarities[] = {
        ItemRarity::COMMON,
        ItemRarity::UNCOMMON,
        ItemRarity::RARE,
        ItemRarity::EPIC,
        ItemRarity::LEGENDARY,
        ItemRarity::CURSED
    };
    
    ItemRarity selected = rarities[rand() % 6];
    return get_random_item(pool_id, selected);
}

Array ItemGenerationService::get_all_items_in_pool(const std::string& pool_id) {
    Array result;
    
    const ItemPool* pool = &fallback_pool;
    if (cached_pools.find(pool_id) != cached_pools.end()) {
        pool = &cached_pools[pool_id];
    }
    
    for (const auto& item : pool->common_items) result.append(item.to_dictionary());
    for (const auto& item : pool->uncommon_items) result.append(item.to_dictionary());
    for (const auto& item : pool->rare_items) result.append(item.to_dictionary());
    for (const auto& item : pool->epic_items) result.append(item.to_dictionary());
    for (const auto& item : pool->legendary_items) result.append(item.to_dictionary());
    for (const auto& item : pool->cursed_items) result.append(item.to_dictionary());
    
    return result;
}

bool ItemGenerationService::has_pool(const std::string& pool_id) const {
    return cached_pools.find(pool_id) != cached_pools.end();
}

void ItemGenerationService::clear_pool(const std::string& pool_id) {
    cached_pools.erase(pool_id);
}

void ItemGenerationService::clear_all_pools() {
    cached_pools.clear();
}

Dictionary ItemGenerationService::get_pool_metadata(const std::string& pool_id) {
    Dictionary metadata;
    
    if (!has_pool(pool_id)) {
        return metadata;
    }
    
    const ItemPool& pool = cached_pools[pool_id];
    metadata["pool_id"] = String(pool.pool_id.c_str());
    metadata["difficulty"] = pool.difficulty_level;
    metadata["floor"] = pool.floor_number;
    metadata["theme"] = String(pool.theme.c_str());
    metadata["total_items"] = pool.common_items.size() + pool.uncommon_items.size() + 
                             pool.rare_items.size() + pool.epic_items.size() + 
                             pool.legendary_items.size() + pool.cursed_items.size();
    
    return metadata;
}

} // namespace necronomicore

