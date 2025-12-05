#ifndef HTTP_CLIENT_H
#define HTTP_CLIENT_H

#include <string>
#include <map>

namespace necronomicore {

/// Simple HTTP response structure
struct SimpleHTTPResponse {
    int status_code;
    std::string body;
    std::map<std::string, std::string> headers;
    bool success;
    std::string error;
};

/// Minimal HTTP client for OpenAI API calls
/// Platform-specific implementation (uses WinHTTP on Windows)
class HTTPClient {
public:
    HTTPClient();
    ~HTTPClient();

    // POST request (primary method for OpenAI)
    SimpleHTTPResponse post(const std::string& url,
                          const std::map<std::string, std::string>& headers,
                          const std::string& body);

    // GET request (for downloading images, etc.)
    SimpleHTTPResponse get(const std::string& url,
                         const std::map<std::string, std::string>& headers);

    // Timeout configuration
    void set_timeout(int seconds);
    int get_timeout() const;

private:
    int timeout_seconds;
    
    // Platform-specific implementation details
    void* platform_data; // Will hold WinHTTP handles on Windows
    
    // Helper methods
    SimpleHTTPResponse make_request(const std::string& method,
                                   const std::string& url,
                                   const std::map<std::string, std::string>& headers,
                                   const std::string& body);
};

} // namespace necronomicore

#endif // HTTP_CLIENT_H

