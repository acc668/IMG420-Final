#ifndef ITEM_GENERATION_SERVICE_H
#define ITEM_GENERATION_SERVICE_H

#include "openai_client.h"
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/array.hpp>
#include <vector>
#include <string>
#include <memory>

namespace necronomicore {

//item rarity
enum class ItemRarity {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY,
    CURSED
};

//item type
enum class ItemType {
    WEAPON,
    ARMOR,
    CONSUMABLE,
    RELIC,
    ARTIFACT
};

//item definition
struct ItemDefinition {
    std::string name;
    std::string description;
    ItemType type;
    ItemRarity rarity;
    
    //stats
    int damage;
    int defense;
    int healing;
    float cooldown;
    
    //special properties
    std::vector<std::string> effects;
    std::map<std::string, float> modifiers;
    
    //thematic
    std::string flavor_text;
    std::string sprite_hint;
    
    //convert to godot dictionary
    godot::Dictionary to_dictionary() const;
    
    //parse from json
    static ItemDefinition from_json(const std::string& json);
};

//item pool for run
struct ItemPool {
    std::string pool_id;
    int difficulty_level;
    int floor_number;
    
    std::vector<ItemDefinition> common_items;
    std::vector<ItemDefinition> uncommon_items;
    std::vector<ItemDefinition> rare_items;
    std::vector<ItemDefinition> epic_items;
    std::vector<ItemDefinition> legendary_items;
    std::vector<ItemDefinition> cursed_items;
    
    //metadata
    std::string theme;
    std::map<std::string, std::string> run_params;
};

//item generation service
//pregenerates item pools at run start
class ItemGenerationService {
private:
    std::shared_ptr<OpenAIClient> client;
    std::map<std::string, ItemPool> cached_pools;
    ItemPool fallback_pool;
    
    //prompt construction
    std::string build_item_generation_prompt(const godot::Dictionary& run_config);
    
    //json parsing
    std::vector<ItemDefinition> parse_item_array(const std::string& json);
    
    //validation
    void validate_and_clamp_item(ItemDefinition& item);
    
    //fallback items
    void initialize_fallback_pool();

public:
    ItemGenerationService(std::shared_ptr<OpenAIClient> openai_client);
    ~ItemGenerationService();

    //pregeneration at run start
    void generate_item_pool(const godot::Dictionary& run_config,
                           std::function<void(const std::string&)> on_success,
                           std::function<void(const std::string&)> on_error);

    //sync version
    std::string generate_item_pool_sync(const godot::Dictionary& run_config);

    //item retrieval from cached pool
    godot::Dictionary get_random_item(const std::string& pool_id, ItemRarity rarity);
    godot::Dictionary get_random_item_any_rarity(const std::string& pool_id);
    godot::Array get_all_items_in_pool(const std::string& pool_id);
    
    //pool management
    bool has_pool(const std::string& pool_id) const;
    void clear_pool(const std::string& pool_id);
    void clear_all_pools();
    
    //metadata
    godot::Dictionary get_pool_metadata(const std::string& pool_id);
};

} // namespace necronomicore

#endif // ITEM_GENERATION_SERVICE_H

