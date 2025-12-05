#ifndef RANDOM_ROLL_SERVICE_H
#define RANDOM_ROLL_SERVICE_H

#include "openai_client.h"
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string.hpp>
#include <memory>
#include <random>
#include <string>

namespace necronomicore {

/// Roll result structure
struct RollResult {
    int value;
    int min_range;
    int max_range;
    std::string context;
    std::string flavor_text; // AI-generated description of outcome
    bool critical_success;
    bool critical_failure;
    
    godot::Dictionary to_dictionary() const;
};

/// Roll modifier (luck, curses, items, etc.)
struct RollModifier {
    std::string name;
    int flat_bonus;
    float multiplier;
    std::string description;
};

/// Noah's Random Roll Service
/// Generates random rolls for gambling and chance-based systems
/// Can optionally use AI for flavor text and dramatic outcomes
class RandomRollService {
private:
    std::shared_ptr<OpenAIClient> client;
    std::mt19937 rng;
    std::map<std::string, std::vector<RollModifier>> active_modifiers;
    
    // AI-enhanced rolls
    bool use_ai_flavor;
    std::string generate_roll_flavor_text(const RollResult& result, const std::string& context);
    
    // Modifier calculation
    int apply_modifiers(int base_value, const std::string& player_id);

public:
    RandomRollService(std::shared_ptr<OpenAIClient> openai_client);
    ~RandomRollService();

    // Basic rolls (fast, local RNG)
    int roll_dice(int num_dice, int sides);
    int roll_range(int min_val, int max_val);
    bool roll_percentage(float success_chance);
    
    // Advanced rolls with context (can use AI for flavor)
    godot::Dictionary roll_with_context(int min_val, int max_val, const godot::String& context);
    godot::Dictionary roll_gambling(const godot::String& game_type, int bet_amount);
    
    // Critical hit/miss system
    godot::Dictionary roll_attack(int base_damage, float crit_chance);
    godot::Dictionary roll_saving_throw(int difficulty, const godot::String& situation);
    
    // Modifier management
    void add_modifier(const godot::String& player_id, const godot::String& modifier_name, int bonus, float multiplier);
    void remove_modifier(const godot::String& player_id, const godot::String& modifier_name);
    void clear_all_modifiers(const godot::String& player_id);
    godot::Array get_active_modifiers(const godot::String& player_id);
    
    // Configuration
    void set_ai_flavor_enabled(bool enabled);
    bool is_ai_flavor_enabled() const;
    
    // Seeding (for reproducible runs if needed)
    void seed_rng(unsigned int seed);
};

} // namespace necronomicore

#endif // RANDOM_ROLL_SERVICE_H

