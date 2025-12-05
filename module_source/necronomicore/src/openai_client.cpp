#include "openai_client.h"
#include "http_client.h"
#include "json_utils.h"
#include <godot_cpp/variant/variant.hpp>
#include <sstream>

using namespace godot;

namespace necronomicore {

OpenAIClient::OpenAIClient() 
    : base_url("https://api.openai.com/v1"),
      processing(false),
      max_requests_per_minute(60),
      current_request_count(0),
      last_reset_time(0.0) {
}

OpenAIClient::~OpenAIClient() {
    clear_queue();
}

void OpenAIClient::set_api_key(const std::string& key) {
    api_key = key;
}

void OpenAIClient::set_base_url(const std::string& url) {
    base_url = url;
}

std::string OpenAIClient::build_chat_completion_body(const Array& messages,
                                                     const String& model,
                                                     float temperature,
                                                     int max_tokens) {
    Dictionary body;
    body[Variant("model")] = Variant(model);
    body[Variant("messages")] = Variant(messages);
    body[Variant("temperature")] = Variant(temperature);
    body[Variant("max_tokens")] = Variant(max_tokens);
    
    return JSONUtils::stringify_json(body);
}

std::string OpenAIClient::build_image_generation_body(const String& prompt,
                                                      const String& model,
                                                      const String& size,
                                                      int n) {
    Dictionary body;
    body[Variant("model")] = Variant(model);
    body[Variant("prompt")] = Variant(prompt);
    body[Variant("size")] = Variant(size);
    body[Variant("n")] = Variant(n);
    
    return JSONUtils::stringify_json(body);
}

HTTPResponse OpenAIClient::send_http_request(const OpenAIRequest& request) {
    HTTPClient client;
    client.set_timeout(30);
    
    std::map<std::string, std::string> headers = request.headers;
    headers["Authorization"] = "Bearer " + api_key;
    headers["Content-Type"] = "application/json";
    
    std::string url = base_url + request.endpoint;
    SimpleHTTPResponse simple_response;
    
    if (request.method == "POST") {
        simple_response = client.post(url, headers, request.body);
    } else if (request.method == "GET") {
        simple_response = client.get(url, headers);
    }
    
    HTTPResponse response;
    response.status_code = simple_response.status_code;
    response.body = simple_response.body;
    response.headers = simple_response.headers;
    response.success = simple_response.success;
    response.error_message = simple_response.error;
    
    return response;
}

void OpenAIClient::chat_completion(const Array& messages,
                                  const String& model,
                                  float temperature,
                                  int max_tokens,
                                  std::function<void(const HTTPResponse&)> callback) {
    OpenAIRequest request;
    request.endpoint = "/chat/completions";
    request.method = "POST";
    request.body = build_chat_completion_body(messages, model, temperature, max_tokens);
    request.callback = callback;
    
    request_queue.push(request);
}

void OpenAIClient::image_generation(const String& prompt,
                                   const String& model,
                                   const String& size,
                                   int n,
                                   std::function<void(const HTTPResponse&)> callback) {
    OpenAIRequest request;
    request.endpoint = "/images/generations";
    request.method = "POST";
    request.body = build_image_generation_body(prompt, model, size, n);
    request.callback = callback;
    
    request_queue.push(request);
}

HTTPResponse OpenAIClient::chat_completion_sync(const Array& messages,
                                                const String& model,
                                                float temperature,
                                                int max_tokens) {
    OpenAIRequest request;
    request.endpoint = "/chat/completions";
    request.method = "POST";
    request.body = build_chat_completion_body(messages, model, temperature, max_tokens);
    
    return send_http_request(request);
}

void OpenAIClient::process_queue() {
    if (processing || request_queue.empty() || !can_make_request()) {
        return;
    }
    
    processing = true;
    OpenAIRequest request = request_queue.front();
    request_queue.pop();
    
    HTTPResponse response = send_http_request(request);
    
    if (request.callback) {
        request.callback(response);
    }
    
    current_request_count++;
    processing = false;
}

bool OpenAIClient::has_pending_requests() const {
    return !request_queue.empty();
}

void OpenAIClient::clear_queue() {
    while (!request_queue.empty()) {
        request_queue.pop();
    }
}

bool OpenAIClient::can_make_request() const {
    return current_request_count < max_requests_per_minute;
}

void OpenAIClient::update_rate_limit(double delta_time) {
    last_reset_time += delta_time;
    
    //reset counter every minute
    if (last_reset_time >= 60.0) {
        current_request_count = 0;
        last_reset_time = 0.0;
    }
}

} // namespace necronomicore

