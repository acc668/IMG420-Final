#ifndef EMOTION_DIALOG_SERVICE_H
#define EMOTION_DIALOG_SERVICE_H

#include "openai_client.h"
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string.hpp>
#include <memory>
#include <map>
#include <vector>

namespace necronomicore {

//personality trait
struct PersonalityTrait {
    std::string trait_name;
    float intensity; //0 to 1
    std::string description;
};

//npc personality profile
struct NPCPersonality {
    std::string npc_id;
    std::string npc_name;
    std::string archetype;
    
    std::vector<PersonalityTrait> traits;
    std::map<std::string, std::string> background_info;
    std::map<std::string, int> relationship_scores;
    
    //emotional state
    std::string current_mood;
    float sanity_level;
    
    //convert to/from godot dictionary
    godot::Dictionary to_dictionary() const;
    static NPCPersonality from_dictionary(const godot::Dictionary& dict);
};

//dialog context for ai
struct DialogContext {
    std::string location;
    std::string recent_player_action;
    std::vector<std::string> previous_dialog_lines;
    std::map<std::string, bool> world_state_flags;
    int player_sanity;
    bool first_encounter;
};

//emotion dialog service
//generates npc dialogue based on personality
class EmotionDialogService {
private:
    std::shared_ptr<OpenAIClient> client;
    std::map<std::string, NPCPersonality> npc_personalities;
    std::map<std::string, std::vector<std::string>> dialog_history;
    
    //prompt construction
    std::string build_dialog_prompt(const NPCPersonality& personality,
                                   const DialogContext& context,
                                   const std::string& player_input);
    
    //response parsing
    std::string extract_dialog_from_response(const std::string& response_json);
    
    //personality updates
    void update_npc_mood(const std::string& npc_id, const std::string& player_action);

public:
    EmotionDialogService(std::shared_ptr<OpenAIClient> openai_client);
    ~EmotionDialogService();

    //npc management
    void register_npc(const godot::String& npc_id, const godot::Dictionary& personality);
    void update_npc_trait(const godot::String& npc_id, const godot::String& trait, float intensity);
    godot::Dictionary get_npc_personality(const godot::String& npc_id);

    //dialog generation
    void generate_dialog(const godot::String& npc_id,
                        const godot::String& player_input,
                        const godot::Dictionary& context,
                        std::function<void(const std::string&)> on_success,
                        std::function<void(const std::string&)> on_error);

    //sync version
    std::string generate_dialog_sync(const godot::String& npc_id,
                                    const godot::String& player_input,
                                    const godot::Dictionary& context);

    //relationship system
    void update_relationship(const godot::String& npc_id, int delta);
    int get_relationship_score(const godot::String& npc_id);
    
    //dialog history
    godot::Array get_dialog_history(const godot::String& npc_id);
    void clear_dialog_history(const godot::String& npc_id);
    
    //environmental messages
    void generate_environmental_message(const godot::Dictionary& context,
                                       std::function<void(const std::string&)> callback);
};

} // namespace necronomicore

#endif // EMOTION_DIALOG_SERVICE_H

