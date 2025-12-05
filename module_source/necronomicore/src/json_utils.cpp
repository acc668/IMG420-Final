#include "json_utils.h"
#include <godot_cpp/classes/json.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

namespace necronomicore {

Dictionary JSONUtils::parse_json(const std::string& json_str) {
    Ref<JSON> json;
    json.instantiate();
    
    Error err = json->parse(String(json_str.c_str()));
    if (err != OK) {
        UtilityFunctions::push_error("JSON parse error: " + json->get_error_message());
        return Dictionary();
    }
    
    Variant result = json->get_data();
    if (result.get_type() == Variant::DICTIONARY) {
        return result;
    }
    
    return Dictionary();
}

std::string JSONUtils::stringify_json(const Dictionary& dict) {
    Ref<JSON> json;
    json.instantiate();
    String result = json->stringify(dict);
    return result.utf8().get_data();
}

std::string JSONUtils::get_string(const Dictionary& dict, const std::string& key, const std::string& default_val) {
    String gkey(key.c_str());
    if (dict.has(gkey)) {
        return String(dict[gkey]).utf8().get_data();
    }
    return default_val;
}

int JSONUtils::get_int(const Dictionary& dict, const std::string& key, int default_val) {
    String gkey(key.c_str());
    if (dict.has(gkey)) {
        return dict[gkey];
    }
    return default_val;
}

float JSONUtils::get_float(const Dictionary& dict, const std::string& key, float default_val) {
    String gkey(key.c_str());
    if (dict.has(gkey)) {
        return dict[gkey];
    }
    return default_val;
}

bool JSONUtils::get_bool(const Dictionary& dict, const std::string& key, bool default_val) {
    String gkey(key.c_str());
    if (dict.has(gkey)) {
        return dict[gkey];
    }
    return default_val;
}

Array JSONUtils::get_array(const Dictionary& dict, const std::string& key) {
    String gkey(key.c_str());
    if (dict.has(gkey)) {
        Variant val = dict[gkey];
        if (val.get_type() == Variant::ARRAY) {
            return val;
        }
    }
    return Array();
}

Dictionary JSONUtils::get_dict(const Dictionary& dict, const std::string& key) {
    String gkey(key.c_str());
    if (dict.has(gkey)) {
        Variant val = dict[gkey];
        if (val.get_type() == Variant::DICTIONARY) {
            return val;
        }
    }
    return Dictionary();
}

bool JSONUtils::has_key(const Dictionary& dict, const std::string& key) {
    return dict.has(String(key.c_str()));
}

bool JSONUtils::is_valid_json(const std::string& json_str) {
    Ref<JSON> json;
    json.instantiate();
    return json->parse(String(json_str.c_str())) == OK;
}

} // namespace necronomicore

