#include "http_client.h"
#include <iostream>

#ifdef _WIN32
#include <windows.h>
#include <winhttp.h>
#pragma comment(lib, "winhttp.lib")

struct PlatformData {
    HINTERNET hSession;
    HINTERNET hConnect;
};
#endif

namespace necronomicore {

HTTPClient::HTTPClient() : timeout_seconds(30), platform_data(nullptr) {
#ifdef _WIN32
    platform_data = new PlatformData();
    PlatformData* data = static_cast<PlatformData*>(platform_data);
    data->hSession = nullptr;
    data->hConnect = nullptr;
#endif
}

HTTPClient::~HTTPClient() {
#ifdef _WIN32
    if (platform_data) {
        PlatformData* data = static_cast<PlatformData*>(platform_data);
        if (data->hConnect) WinHttpCloseHandle(data->hConnect);
        if (data->hSession) WinHttpCloseHandle(data->hSession);
        delete data;
    }
#endif
}

void HTTPClient::set_timeout(int seconds) {
    timeout_seconds = seconds;
}

int HTTPClient::get_timeout() const {
    return timeout_seconds;
}

SimpleHTTPResponse HTTPClient::post(const std::string& url,
                                    const std::map<std::string, std::string>& headers,
                                    const std::string& body) {
    return make_request("POST", url, headers, body);
}

SimpleHTTPResponse HTTPClient::get(const std::string& url,
                                   const std::map<std::string, std::string>& headers) {
    return make_request("GET", url, headers, "");
}

SimpleHTTPResponse HTTPClient::make_request(const std::string& method,
                                           const std::string& url,
                                           const std::map<std::string, std::string>& headers,
                                           const std::string& body) {
    SimpleHTTPResponse response;
    response.success = false;
    response.status_code = 0;

#ifdef _WIN32
    // Parse URL
    std::wstring wurl(url.begin(), url.end());
    URL_COMPONENTS urlComp;
    ZeroMemory(&urlComp, sizeof(urlComp));
    urlComp.dwStructSize = sizeof(urlComp);
    
    wchar_t szHostName[256];
    wchar_t szUrlPath[2048];
    urlComp.lpszHostName = szHostName;
    urlComp.dwHostNameLength = sizeof(szHostName) / sizeof(wchar_t);
    urlComp.lpszUrlPath = szUrlPath;
    urlComp.dwUrlPathLength = sizeof(szUrlPath) / sizeof(wchar_t);

    if (!WinHttpCrackUrl(wurl.c_str(), 0, 0, &urlComp)) {
        response.error = "Failed to parse URL";
        return response;
    }

    // Create session
    HINTERNET hSession = WinHttpOpen(L"NecronomiCore/1.0",
                                     WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                                     WINHTTP_NO_PROXY_NAME,
                                     WINHTTP_NO_PROXY_BYPASS, 0);
    if (!hSession) {
        response.error = "Failed to create HTTP session";
        return response;
    }

    // Create connection
    HINTERNET hConnect = WinHttpConnect(hSession, szHostName, urlComp.nPort, 0);
    if (!hConnect) {
        WinHttpCloseHandle(hSession);
        response.error = "Failed to connect to server";
        return response;
    }

    // Create request
    std::wstring wmethod(method.begin(), method.end());
    DWORD dwFlags = (urlComp.nScheme == INTERNET_SCHEME_HTTPS) ? WINHTTP_FLAG_SECURE : 0;
    
    HINTERNET hRequest = WinHttpOpenRequest(hConnect,
                                           wmethod.c_str(),
                                           szUrlPath,
                                           NULL,
                                           WINHTTP_NO_REFERER,
                                           WINHTTP_DEFAULT_ACCEPT_TYPES,
                                           dwFlags);
    if (!hRequest) {
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        response.error = "Failed to create request";
        return response;
    }

    // Set timeout
    int timeout_ms = timeout_seconds * 1000;
    WinHttpSetTimeouts(hRequest, timeout_ms, timeout_ms, timeout_ms, timeout_ms);

    // Add headers
    std::wstring allHeaders;
    for (const auto& header : headers) {
        std::wstring wheader(header.first.begin(), header.first.end());
        std::wstring wvalue(header.second.begin(), header.second.end());
        allHeaders += wheader + L": " + wvalue + L"\r\n";
    }

    if (!allHeaders.empty()) {
        WinHttpAddRequestHeaders(hRequest,
                                allHeaders.c_str(),
                                -1L,
                                WINHTTP_ADDREQ_FLAG_ADD);
    }

    // Send request
    BOOL bResults = WinHttpSendRequest(hRequest,
                                      WINHTTP_NO_ADDITIONAL_HEADERS,
                                      0,
                                      (LPVOID)body.c_str(),
                                      body.length(),
                                      body.length(),
                                      0);

    if (!bResults) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        response.error = "Failed to send request";
        return response;
    }

    // Receive response
    bResults = WinHttpReceiveResponse(hRequest, NULL);
    if (!bResults) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        response.error = "Failed to receive response";
        return response;
    }

    // Get status code
    DWORD dwStatusCode = 0;
    DWORD dwSize = sizeof(dwStatusCode);
    WinHttpQueryHeaders(hRequest,
                       WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                       NULL,
                       &dwStatusCode,
                       &dwSize,
                       NULL);
    response.status_code = dwStatusCode;

    // Read response body
    std::string responseBody;
    DWORD dwDownloaded = 0;
    do {
        dwSize = 0;
        if (!WinHttpQueryDataAvailable(hRequest, &dwSize)) {
            break;
        }

        if (dwSize == 0) {
            break;
        }

        char* pszOutBuffer = new char[dwSize + 1];
        ZeroMemory(pszOutBuffer, dwSize + 1);

        if (WinHttpReadData(hRequest, (LPVOID)pszOutBuffer, dwSize, &dwDownloaded)) {
            responseBody.append(pszOutBuffer, dwDownloaded);
        }

        delete[] pszOutBuffer;
    } while (dwSize > 0);

    response.body = responseBody;
    response.success = (dwStatusCode >= 200 && dwStatusCode < 300);

    // Cleanup
    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

#else
    response.error = "HTTP client not implemented for this platform";
#endif

    return response;
}

} // namespace necronomicore

