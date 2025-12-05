#include "necronomi_core.h"
#include "openai_client.h"
#include "item_generation_service.h"
#include "emotion_dialog_service.h"
#include "random_roll_service.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

namespace necronomicore {

NecronomiCore* NecronomiCore::singleton = nullptr;

NecronomiCore::NecronomiCore() : initialized(false) {
    ERR_FAIL_COND_MSG(singleton != nullptr, "NecronomiCore singleton already exists!");
    singleton = this;
}

NecronomiCore::~NecronomiCore() {
    singleton = nullptr;
}

NecronomiCore* NecronomiCore::get_singleton() {
    return singleton;
}

void NecronomiCore::_bind_methods() {
    //properties
    ClassDB::bind_method(D_METHOD("set_api_key", "key"), &NecronomiCore::set_api_key);
    ClassDB::bind_method(D_METHOD("get_api_key"), &NecronomiCore::get_api_key);
    ClassDB::bind_method(D_METHOD("is_initialized"), &NecronomiCore::is_initialized);
    ClassDB::bind_method(D_METHOD("initialize"), &NecronomiCore::initialize);

    //service methods
    ClassDB::bind_method(D_METHOD("request_item_generation", "config"), &NecronomiCore::request_item_generation);
    ClassDB::bind_method(D_METHOD("request_emotion_dialog", "npc_name", "context", "personality"), &NecronomiCore::request_emotion_dialog);
    ClassDB::bind_method(D_METHOD("generate_random_roll", "min_value", "max_value", "context"), &NecronomiCore::generate_random_roll);

    //signals
    ADD_SIGNAL(MethodInfo("item_pool_ready", PropertyInfo(Variant::ARRAY, "items")));
    ADD_SIGNAL(MethodInfo("dialog_ready", PropertyInfo(Variant::STRING, "dialog_text")));
    ADD_SIGNAL(MethodInfo("request_failed", PropertyInfo(Variant::STRING, "error_message")));
}

void NecronomiCore::set_api_key(const String& key) {
    api_key = key;
    if (openai_client) {
        openai_client->set_api_key(key.utf8().get_data());
    }
}

String NecronomiCore::get_api_key() const {
    return api_key;
}

bool NecronomiCore::is_initialized() const {
    return initialized;
}

void NecronomiCore::initialize() {
    if (initialized) {
        UtilityFunctions::print("NecronomiCore already initialized");
        return;
    }

    if (api_key.is_empty()) {
        UtilityFunctions::push_error("Cannot initialize NecronomiCore without API key");
        emit_signal("request_failed", "API key not set");
        return;
    }

    //create openai client
    openai_client = std::make_shared<OpenAIClient>();
    openai_client->set_api_key(api_key.utf8().get_data());

    //create services
    item_service = std::make_shared<ItemGenerationService>(openai_client);
    dialog_service = std::make_shared<EmotionDialogService>(openai_client);
    roll_service = std::make_shared<RandomRollService>(openai_client);

    initialized = true;
    UtilityFunctions::print("NecronomiCore initialized successfully");
}

void NecronomiCore::request_item_generation(const Dictionary& config) {
    if (!initialized) {
        emit_signal("request_failed", "NecronomiCore not initialized");
        return;
    }

    //async item generation
    item_service->generate_item_pool(config,
        [this](const std::string& pool_id) {
            //success
            Array items = item_service->get_all_items_in_pool(pool_id);
            emit_signal("item_pool_ready", items);
        },
        [this](const std::string& error) {
            //error
            emit_signal("request_failed", String(error.c_str()));
        }
    );
}

void NecronomiCore::request_emotion_dialog(const String& npc_name, const String& context, const Dictionary& personality) {
    if (!initialized) {
        emit_signal("request_failed", "NecronomiCore not initialized");
        return;
    }

    //register npc
    dialog_service->register_npc(npc_name, personality);

    //generate dialog
    Dictionary ctx;
    ctx["context"] = context;
    
    dialog_service->generate_dialog(npc_name, "", ctx,
        [this](const std::string& dialog) {
            emit_signal("dialog_ready", String(dialog.c_str()));
        },
        [this](const std::string& error) {
            emit_signal("request_failed", String(error.c_str()));
        }
    );
}

int NecronomiCore::generate_random_roll(int min_value, int max_value, const String& context) {
    if (!initialized) {
        UtilityFunctions::push_error("NecronomiCore not initialized");
        return 0;
    }

    Dictionary result = roll_service->roll_with_context(min_value, max_value, context);
    return result.get("value", 0);
}

void NecronomiCore::emit_item_pool_ready(const Array& items) {
    emit_signal("item_pool_ready", items);
}

void NecronomiCore::emit_dialog_ready(const String& dialog_text) {
    emit_signal("dialog_ready", dialog_text);
}

void NecronomiCore::emit_request_failed(const String& error_message) {
    emit_signal("request_failed", error_message);
}

void NecronomiCore::_ready() {
    UtilityFunctions::print("NecronomiCore node ready");
}

void NecronomiCore::_process(double delta) {
    if (!initialized || !openai_client) {
        return;
    }

    //update rate limiting
    openai_client->update_rate_limit(delta);

    //process queued requests
    openai_client->process_queue();
}

} // namespace necronomicore

