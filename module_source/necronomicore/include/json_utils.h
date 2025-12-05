#ifndef JSON_UTILS_H
#define JSON_UTILS_H

#include <string>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/array.hpp>

namespace necronomicore {

/// Lightweight JSON utilities for parsing OpenAI responses
/// Uses Godot's built-in JSON parser where possible
class JSONUtils {
public:
    // Parse JSON string to Godot Dictionary
    static godot::Dictionary parse_json(const std::string& json_str);
    
    // Stringify Godot Dictionary to JSON
    static std::string stringify_json(const godot::Dictionary& dict);
    
    // Extract specific fields safely
    static std::string get_string(const godot::Dictionary& dict, const std::string& key, const std::string& default_val = "");
    static int get_int(const godot::Dictionary& dict, const std::string& key, int default_val = 0);
    static float get_float(const godot::Dictionary& dict, const std::string& key, float default_val = 0.0f);
    static bool get_bool(const godot::Dictionary& dict, const std::string& key, bool default_val = false);
    static godot::Array get_array(const godot::Dictionary& dict, const std::string& key);
    static godot::Dictionary get_dict(const godot::Dictionary& dict, const std::string& key);
    
    // Validation
    static bool has_key(const godot::Dictionary& dict, const std::string& key);
    static bool is_valid_json(const std::string& json_str);
};

} // namespace necronomicore

#endif // JSON_UTILS_H

