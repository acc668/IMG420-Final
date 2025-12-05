#ifndef NECRONOMI_CORE_H
#define NECRONOMI_CORE_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <string>
#include <memory>

namespace necronomicore {

class OpenAIClient;
class ItemGenerationService;
class EmotionDialogService;
class RandomRollService;

//main singleton class for ai integration
class NecronomiCore : public godot::Node {
    GDCLASS(NecronomiCore, godot::Node)

private:
    static NecronomiCore* singleton;
    
    std::shared_ptr<OpenAIClient> openai_client;
    std::shared_ptr<ItemGenerationService> item_service;
    std::shared_ptr<EmotionDialogService> dialog_service;
    std::shared_ptr<RandomRollService> roll_service;
    
    godot::String api_key;
    bool initialized;

protected:
    static void _bind_methods();

public:
    NecronomiCore();
    ~NecronomiCore();

    //singleton access
    static NecronomiCore* get_singleton();

    //init
    void set_api_key(const godot::String& key);
    godot::String get_api_key() const;
    bool is_initialized() const;
    void initialize();

    //service methods
    void request_item_generation(const godot::Dictionary& config);
    void request_emotion_dialog(const godot::String& npc_name, const godot::String& context, const godot::Dictionary& personality);
    int generate_random_roll(int min_value, int max_value, const godot::String& context);

    //signals
    void emit_item_pool_ready(const godot::Array& items);
    void emit_dialog_ready(const godot::String& dialog_text);
    void emit_request_failed(const godot::String& error_message);

    //godot lifecycle
    void _ready() override;
    void _process(double delta) override;
};

} // namespace necronomicore

#endif // NECRONOMI_CORE_H

