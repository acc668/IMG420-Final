#include "random_roll_service.h"
#include "json_utils.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <chrono>
#include <sstream>

using namespace godot;

namespace necronomicore {

Dictionary RollResult::to_dictionary() const {
    Dictionary dict;
    dict["value"] = value;
    dict["min_range"] = min_range;
    dict["max_range"] = max_range;
    dict["context"] = String(context.c_str());
    dict["flavor_text"] = String(flavor_text.c_str());
    dict["critical_success"] = critical_success;
    dict["critical_failure"] = critical_failure;
    return dict;
}

RandomRollService::RandomRollService(std::shared_ptr<OpenAIClient> openai_client)
    : client(openai_client), use_ai_flavor(false) {
    // Seed RNG with current time
    auto seed = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    rng.seed(static_cast<unsigned int>(seed));
}

RandomRollService::~RandomRollService() {
}

int RandomRollService::roll_dice(int num_dice, int sides) {
    std::uniform_int_distribution<int> dist(1, sides);
    int total = 0;
    for (int i = 0; i < num_dice; i++) {
        total += dist(rng);
    }
    return total;
}

int RandomRollService::roll_range(int min_val, int max_val) {
    std::uniform_int_distribution<int> dist(min_val, max_val);
    return dist(rng);
}

bool RandomRollService::roll_percentage(float success_chance) {
    std::uniform_real_distribution<float> dist(0.0f, 1.0f);
    return dist(rng) <= success_chance;
}

std::string RandomRollService::generate_roll_flavor_text(const RollResult& result, const std::string& context) {
    if (!use_ai_flavor) {
        if (result.critical_success) {
            return "Fate smiles upon you...";
        } else if (result.critical_failure) {
            return "The stars align against you...";
        }
        return "The die is cast.";
    }
    
    // AI-generated flavor (would need to be async in real implementation)
    return "The cosmic forces stir...";
}

int RandomRollService::apply_modifiers(int base_value, const std::string& player_id) {
    if (active_modifiers.find(player_id) == active_modifiers.end()) {
        return base_value;
    }
    
    float total = static_cast<float>(base_value);
    int flat_bonus = 0;
    float multiplier = 1.0f;
    
    for (const auto& mod : active_modifiers[player_id]) {
        flat_bonus += mod.flat_bonus;
        multiplier *= mod.multiplier;
    }
    
    total = (total + flat_bonus) * multiplier;
    return static_cast<int>(total);
}

Dictionary RandomRollService::roll_with_context(int min_val, int max_val, const String& context) {
    RollResult result;
    result.min_range = min_val;
    result.max_range = max_val;
    result.context = context.utf8().get_data();
    result.value = roll_range(min_val, max_val);
    
    // Check for criticals (top/bottom 10%)
    int range = max_val - min_val;
    int crit_threshold = range / 10;
    
    if (result.value >= max_val - crit_threshold) {
        result.critical_success = true;
        result.critical_failure = false;
    } else if (result.value <= min_val + crit_threshold) {
        result.critical_success = false;
        result.critical_failure = true;
    } else {
        result.critical_success = false;
        result.critical_failure = false;
    }
    
    result.flavor_text = generate_roll_flavor_text(result, result.context);
    
    return result.to_dictionary();
}

Dictionary RandomRollService::roll_gambling(const String& game_type, int bet_amount) {
    RollResult result;
    result.context = std::string("Gambling: ") + game_type.utf8().get_data();
    result.min_range = 0;
    result.max_range = 100;
    
    // Simple gambling logic
    int roll = roll_range(0, 100);
    result.value = roll;
    
    // Win thresholds
    if (roll >= 75) {
        result.critical_success = true;
        result.flavor_text = "Fortune favors you! The elder bloom glows with approval.";
    } else if (roll >= 50) {
        result.flavor_text = "A modest victory. The spores shimmer faintly.";
    } else if (roll >= 25) {
        result.flavor_text = "The fungus remains dormant. Nothing gained, nothing lost.";
    } else if (roll >= 10) {
        result.flavor_text = "The bloom wilts. Your luck turns sour.";
    } else {
        result.critical_failure = true;
        result.flavor_text = "The elder bloom recoils in disgust. Dire consequences await.";
    }
    
    return result.to_dictionary();
}

Dictionary RandomRollService::roll_attack(int base_damage, float crit_chance) {
    RollResult result;
    result.context = "Attack";
    result.min_range = 0;
    result.max_range = base_damage;
    
    // Roll for crit
    bool is_crit = roll_percentage(crit_chance);
    
    if (is_crit) {
        result.value = base_damage * 2;
        result.critical_success = true;
        result.critical_failure = false;
        result.flavor_text = "A devastating blow! Fungal tendrils erupt from the wound.";
    } else {
        // Random damage variation
        result.value = roll_range(base_damage / 2, base_damage);
        result.critical_success = false;
        result.critical_failure = false;
        result.flavor_text = "Your strike connects.";
    }
    
    return result.to_dictionary();
}

Dictionary RandomRollService::roll_saving_throw(int difficulty, const String& situation) {
    RollResult result;
    result.context = std::string("Saving throw: ") + situation.utf8().get_data();
    result.min_range = 1;
    result.max_range = 20;
    
    int roll = roll_dice(1, 20);
    result.value = roll;
    
    if (roll == 20) {
        result.critical_success = true;
        result.flavor_text = "Against all odds, you resist the horror!";
    } else if (roll == 1) {
        result.critical_failure = true;
        result.flavor_text = "Your mind fractures. Sanity slips away...";
    } else if (roll >= difficulty) {
        result.flavor_text = "You steel yourself against the darkness.";
    } else {
        result.flavor_text = "The eldritch forces overwhelm you.";
    }
    
    return result.to_dictionary();
}

void RandomRollService::add_modifier(const String& player_id, const String& modifier_name, 
                                     int bonus, float multiplier) {
    std::string id = player_id.utf8().get_data();
    
    RollModifier mod;
    mod.name = modifier_name.utf8().get_data();
    mod.flat_bonus = bonus;
    mod.multiplier = multiplier;
    
    if (active_modifiers.find(id) == active_modifiers.end()) {
        active_modifiers[id] = std::vector<RollModifier>();
    }
    
    active_modifiers[id].push_back(mod);
}

void RandomRollService::remove_modifier(const String& player_id, const String& modifier_name) {
    std::string id = player_id.utf8().get_data();
    std::string name = modifier_name.utf8().get_data();
    
    if (active_modifiers.find(id) == active_modifiers.end()) {
        return;
    }
    
    auto& mods = active_modifiers[id];
    mods.erase(
        std::remove_if(mods.begin(), mods.end(),
            [&name](const RollModifier& mod) { return mod.name == name; }),
        mods.end()
    );
}

void RandomRollService::clear_all_modifiers(const String& player_id) {
    std::string id = player_id.utf8().get_data();
    active_modifiers.erase(id);
}

Array RandomRollService::get_active_modifiers(const String& player_id) {
    Array result;
    std::string id = player_id.utf8().get_data();
    
    if (active_modifiers.find(id) != active_modifiers.end()) {
        for (const auto& mod : active_modifiers[id]) {
            Dictionary mod_dict;
            mod_dict[Variant("name")] = Variant(String(mod.name.c_str()));
            mod_dict[Variant("flat_bonus")] = Variant(mod.flat_bonus);
            mod_dict[Variant("multiplier")] = Variant(mod.multiplier);
            mod_dict[Variant("description")] = Variant(String(mod.description.c_str()));
            result.append(mod_dict);
        }
    }
    
    return result;
}

void RandomRollService::set_ai_flavor_enabled(bool enabled) {
    use_ai_flavor = enabled;
}

bool RandomRollService::is_ai_flavor_enabled() const {
    return use_ai_flavor;
}

void RandomRollService::seed_rng(unsigned int seed) {
    rng.seed(seed);
}

} // namespace necronomicore

