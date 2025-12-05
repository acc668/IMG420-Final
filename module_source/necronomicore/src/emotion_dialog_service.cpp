#include "emotion_dialog_service.h"
#include "json_utils.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <sstream>

using namespace godot;

namespace necronomicore {

Dictionary NPCPersonality::to_dictionary() const {
    Dictionary dict;
    dict["npc_id"] = String(npc_id.c_str());
    dict["npc_name"] = String(npc_name.c_str());
    dict["archetype"] = String(archetype.c_str());
    dict["current_mood"] = String(current_mood.c_str());
    dict["sanity_level"] = sanity_level;
    
    Array traits_array;
    for (const auto& trait : traits) {
        Dictionary trait_dict;
        trait_dict["name"] = String(trait.trait_name.c_str());
        trait_dict["intensity"] = trait.intensity;
        trait_dict["description"] = String(trait.description.c_str());
        traits_array.append(trait_dict);
    }
    dict["traits"] = traits_array;
    
    return dict;
}

NPCPersonality NPCPersonality::from_dictionary(const Dictionary& dict) {
    NPCPersonality personality;
    personality.npc_id = JSONUtils::get_string(dict, "npc_id");
    personality.npc_name = JSONUtils::get_string(dict, "npc_name");
    personality.archetype = JSONUtils::get_string(dict, "archetype", "mysterious stranger");
    personality.current_mood = JSONUtils::get_string(dict, "current_mood", "neutral");
    personality.sanity_level = JSONUtils::get_float(dict, "sanity_level", 1.0f);
    
    if (JSONUtils::has_key(dict, "traits")) {
        Array traits_array = JSONUtils::get_array(dict, "traits");
        for (int i = 0; i < traits_array.size(); i++) {
            Dictionary trait_dict = traits_array[i];
            PersonalityTrait trait;
            trait.trait_name = JSONUtils::get_string(trait_dict, "name");
            trait.intensity = JSONUtils::get_float(trait_dict, "intensity", 0.5f);
            trait.description = JSONUtils::get_string(trait_dict, "description");
            personality.traits.push_back(trait);
        }
    }
    
    return personality;
}

EmotionDialogService::EmotionDialogService(std::shared_ptr<OpenAIClient> openai_client)
    : client(openai_client) {
}

EmotionDialogService::~EmotionDialogService() {
}

void EmotionDialogService::register_npc(const String& npc_id, const Dictionary& personality) {
    std::string id = npc_id.utf8().get_data();
    NPCPersonality npc = NPCPersonality::from_dictionary(personality);
    npc.npc_id = id;
    npc_personalities[id] = npc;
}

void EmotionDialogService::update_npc_trait(const String& npc_id, const String& trait, float intensity) {
    std::string id = npc_id.utf8().get_data();
    
    if (npc_personalities.find(id) == npc_personalities.end()) {
        return;
    }
    
    NPCPersonality& personality = npc_personalities[id];
    std::string trait_name = trait.utf8().get_data();
    
    //find and update trait
    for (auto& t : personality.traits) {
        if (t.trait_name == trait_name) {
            t.intensity = intensity;
            return;
        }
    }
    
    //add new trait
    PersonalityTrait new_trait;
    new_trait.trait_name = trait_name;
    new_trait.intensity = intensity;
    personality.traits.push_back(new_trait);
}

Dictionary EmotionDialogService::get_npc_personality(const String& npc_id) {
    std::string id = npc_id.utf8().get_data();
    
    if (npc_personalities.find(id) == npc_personalities.end()) {
        return Dictionary();
    }
    
    return npc_personalities[id].to_dictionary();
}

std::string EmotionDialogService::build_dialog_prompt(const NPCPersonality& personality,
                                                      const DialogContext& context,
                                                      const std::string& player_input) {
    std::ostringstream prompt;
    
    prompt << "You are roleplaying as an NPC in a Lovecraftian horror dungeon crawler game.\n\n";
    prompt << "NPC Name: " << personality.npc_name << "\n";
    prompt << "Archetype: " << personality.archetype << "\n";
    prompt << "Current Mood: " << personality.current_mood << "\n";
    prompt << "Sanity Level: " << (personality.sanity_level * 100) << "%\n\n";
    
    prompt << "Personality Traits:\n";
    for (const auto& trait : personality.traits) {
        prompt << "- " << trait.trait_name << " (intensity: " << trait.intensity << "): " 
               << trait.description << "\n";
    }
    
    prompt << "\nContext:\n";
    prompt << "Location: " << context.location << "\n";
    if (!context.recent_player_action.empty()) {
        prompt << "Player recently: " << context.recent_player_action << "\n";
    }
    if (context.first_encounter) {
        prompt << "This is your first time meeting the player.\n";
    }
    
    if (!context.previous_dialog_lines.empty()) {
        prompt << "\nPrevious dialog:\n";
        for (size_t i = 0; i < context.previous_dialog_lines.size() && i < 3; i++) {
            prompt << "- " << context.previous_dialog_lines[i] << "\n";
        }
    }
    
    prompt << "\nGenerate a single line of dialog that this NPC would say. ";
    prompt << "Stay in character. Use atmosphere and horror elements. ";
    prompt << "Keep response under 100 words. ";
    prompt << "Do not include quotation marks or character name in the response.\n";
    
    if (!player_input.empty()) {
        prompt << "\nPlayer said: \"" << player_input << "\"\n";
    }
    
    return prompt.str();
}

std::string EmotionDialogService::extract_dialog_from_response(const std::string& response_json) {
    Dictionary response = JSONUtils::parse_json(response_json);
    
    if (JSONUtils::has_key(response, "choices")) {
        Array choices = JSONUtils::get_array(response, "choices");
        if (choices.size() > 0) {
            Dictionary first_choice = choices[0];
            Dictionary message = JSONUtils::get_dict(first_choice, "message");
            return JSONUtils::get_string(message, "content");
        }
    }
    
    return "...";
}

void EmotionDialogService::update_npc_mood(const std::string& npc_id, const std::string& player_action) {
    if (npc_personalities.find(npc_id) == npc_personalities.end()) {
        return;
    }
    
    NPCPersonality& personality = npc_personalities[npc_id];
    
    //simple mood update
    if (player_action.find("attack") != std::string::npos ||
        player_action.find("hostile") != std::string::npos) {
        personality.current_mood = "hostile";
    } else if (player_action.find("help") != std::string::npos ||
               player_action.find("gift") != std::string::npos) {
        personality.current_mood = "friendly";
    }
}

void EmotionDialogService::generate_dialog(const String& npc_id,
                                           const String& player_input,
                                           const Dictionary& context_dict,
                                           std::function<void(const std::string&)> on_success,
                                           std::function<void(const std::string&)> on_error) {
    std::string id = npc_id.utf8().get_data();
    
    if (npc_personalities.find(id) == npc_personalities.end()) {
        on_error("NPC not registered: " + id);
        return;
    }
    
    const NPCPersonality& personality = npc_personalities[id];
    
    DialogContext context;
    context.location = JSONUtils::get_string(context_dict, "location", "unknown");
    context.recent_player_action = JSONUtils::get_string(context_dict, "recent_action", "");
    context.first_encounter = JSONUtils::get_bool(context_dict, "first_encounter", false);
    context.player_sanity = JSONUtils::get_int(context_dict, "player_sanity", 100);
    
    std::string prompt = build_dialog_prompt(personality, context, player_input.utf8().get_data());
    
    Array messages;
    Dictionary user_message;
    user_message[Variant("role")] = Variant("user");
    user_message[Variant("content")] = Variant(String(prompt.c_str()));
    messages.append(user_message);
    
    client->chat_completion(messages, "gpt-3.5-turbo", 0.9, 150,
        [this, id, on_success, on_error](const HTTPResponse& response) {
            if (response.success) {
                std::string dialog = extract_dialog_from_response(response.body);
                
                // Store in history
                if (dialog_history.find(id) == dialog_history.end()) {
                    dialog_history[id] = std::vector<std::string>();
                }
                dialog_history[id].push_back(dialog);
                
                on_success(dialog);
            } else {
                on_error(response.error_message);
            }
        }
    );
}

std::string EmotionDialogService::generate_dialog_sync(const String& npc_id,
                                                       const String& player_input,
                                                       const Dictionary& context_dict) {
    std::string id = npc_id.utf8().get_data();
    
    if (npc_personalities.find(id) == npc_personalities.end()) {
        return "...";
    }
    
    const NPCPersonality& personality = npc_personalities[id];
    
    DialogContext context;
    context.location = JSONUtils::get_string(context_dict, "location", "unknown");
    context.recent_player_action = JSONUtils::get_string(context_dict, "recent_action", "");
    context.first_encounter = JSONUtils::get_bool(context_dict, "first_encounter", false);
    
    std::string prompt = build_dialog_prompt(personality, context, player_input.utf8().get_data());
    
    Array messages;
    Dictionary user_message;
    user_message[Variant("role")] = Variant("user");
    user_message[Variant("content")] = Variant(String(prompt.c_str()));
    messages.append(user_message);
    
    HTTPResponse response = client->chat_completion_sync(messages, "gpt-3.5-turbo", 0.9, 150);
    
    if (!response.success) {
        return "...";
    }
    
    return extract_dialog_from_response(response.body);
}

void EmotionDialogService::update_relationship(const String& npc_id, int delta) {
    std::string id = npc_id.utf8().get_data();
    
    if (npc_personalities.find(id) == npc_personalities.end()) {
        return;
    }
    
    NPCPersonality& personality = npc_personalities[id];
    
    if (personality.relationship_scores.find("player") == personality.relationship_scores.end()) {
        personality.relationship_scores["player"] = 0;
    }
    
    personality.relationship_scores["player"] += delta;
}

int EmotionDialogService::get_relationship_score(const String& npc_id) {
    std::string id = npc_id.utf8().get_data();
    
    if (npc_personalities.find(id) == npc_personalities.end()) {
        return 0;
    }
    
    const NPCPersonality& personality = npc_personalities[id];
    
    if (personality.relationship_scores.find("player") == personality.relationship_scores.end()) {
        return 0;
    }
    
    return personality.relationship_scores.at("player");
}

Array EmotionDialogService::get_dialog_history(const String& npc_id) {
    Array result;
    std::string id = npc_id.utf8().get_data();
    
    if (dialog_history.find(id) != dialog_history.end()) {
        for (const auto& line : dialog_history[id]) {
            result.append(String(line.c_str()));
        }
    }
    
    return result;
}

void EmotionDialogService::clear_dialog_history(const String& npc_id) {
    std::string id = npc_id.utf8().get_data();
    dialog_history.erase(id);
}

void EmotionDialogService::generate_environmental_message(const Dictionary& context,
                                                         std::function<void(const std::string&)> callback) {
    std::string location = JSONUtils::get_string(context, "location", "dungeon room");
    int danger_level = JSONUtils::get_int(context, "danger_level", 1);
    
    std::ostringstream prompt;
    prompt << "Generate a short, cryptic environmental message for a Lovecraftian horror game. ";
    prompt << "Location: " << location << ". ";
    prompt << "This might be scrawled on a wall, carved into stone, or written in fungal growth. ";
    prompt << "Make it unsettling and atmospheric. Maximum 20 words.";
    
    Array messages;
    Dictionary user_message;
    user_message[Variant("role")] = Variant("user");
    user_message[Variant("content")] = Variant(String(prompt.str().c_str()));
    messages.append(user_message);
    
    client->chat_completion(messages, "gpt-3.5-turbo", 1.0, 50,
        [callback](const HTTPResponse& response) {
            if (response.success) {
                Dictionary resp_dict = JSONUtils::parse_json(response.body);
                if (JSONUtils::has_key(resp_dict, "choices")) {
                    Array choices = JSONUtils::get_array(resp_dict, "choices");
                    if (choices.size() > 0) {
                        Dictionary first_choice = choices[0];
                        Dictionary message = JSONUtils::get_dict(first_choice, "message");
                        std::string content = JSONUtils::get_string(message, "content");
                        callback(content);
                        return;
                    }
                }
            }
            callback("The walls whisper secrets best left forgotten...");
        }
    );
}

} // namespace necronomicore

