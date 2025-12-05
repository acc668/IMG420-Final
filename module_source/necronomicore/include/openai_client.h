#ifndef OPENAI_CLIENT_H
#define OPENAI_CLIENT_H

#include <string>
#include <functional>
#include <map>
#include <queue>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/dictionary.hpp>

namespace necronomicore {

//http response
struct HTTPResponse {
    int status_code;
    std::string body;
    std::map<std::string, std::string> headers;
    bool success;
    std::string error_message;
};

//openai api request
struct OpenAIRequest {
    std::string endpoint;
    std::string method;
    std::map<std::string, std::string> headers;
    std::string body;
    std::function<void(const HTTPResponse&)> callback;
};

//openai http client
//handles api communication
class OpenAIClient {
private:
    std::string api_key;
    std::string base_url;
    std::queue<OpenAIRequest> request_queue;
    bool processing;
    
    //rate limiting
    int max_requests_per_minute;
    int current_request_count;
    double last_reset_time;

    //internal http methods
    HTTPResponse send_http_request(const OpenAIRequest& request);
    std::string build_chat_completion_body(const godot::Array& messages, 
                                           const godot::String& model,
                                           float temperature,
                                           int max_tokens);
    std::string build_image_generation_body(const godot::String& prompt,
                                           const godot::String& model,
                                           const godot::String& size,
                                           int n);

public:
    OpenAIClient();
    ~OpenAIClient();

    //config
    void set_api_key(const std::string& key);
    void set_base_url(const std::string& url);
    std::string get_api_key() const { return api_key; }

    //api methods
    void chat_completion(const godot::Array& messages,
                        const godot::String& model,
                        float temperature,
                        int max_tokens,
                        std::function<void(const HTTPResponse&)> callback);

    void image_generation(const godot::String& prompt,
                         const godot::String& model,
                         const godot::String& size,
                         int n,
                         std::function<void(const HTTPResponse&)> callback);

    //sync versions
    HTTPResponse chat_completion_sync(const godot::Array& messages,
                                     const godot::String& model,
                                     float temperature,
                                     int max_tokens);

    //queue management
    void process_queue();
    bool has_pending_requests() const;
    void clear_queue();

    //rate limiting
    bool can_make_request() const;
    void update_rate_limit(double delta_time);
};

} // namespace necronomicore

#endif // OPENAI_CLIENT_H

