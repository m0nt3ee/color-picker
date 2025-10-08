#include <windows.h>
#include <flutter/dart_project.h>
#include "flutter_window.h"
#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"
#include <memory>

using flutter::EncodableMap;
using flutter::EncodableValue;

HHOOK g_mouseHook = nullptr;
POINT g_clickPoint;
bool g_clicked = false;

LRESULT CALLBACK LowLevelMouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode == HC_ACTION && wParam == WM_LBUTTONDOWN) {
        MSLLHOOKSTRUCT* pMouseStruct = (MSLLHOOKSTRUCT*)lParam;
        if (pMouseStruct != nullptr) {
            g_clickPoint = pMouseStruct->pt;
            g_clicked = true;
        }
        UnhookWindowsHookEx(g_mouseHook);
        g_mouseHook = nullptr;
        return 1;
    }
    return CallNextHookEx(g_mouseHook, nCode, wParam, lParam);
}

EncodableMap PickColorOnNextClickGlobal() {
    g_clicked = false;
    g_mouseHook = SetWindowsHookEx(WH_MOUSE_LL, LowLevelMouseProc, nullptr, 0);

    MSG msg;
    while (!g_clicked && GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    EncodableMap result;
    HDC hdcScreen = GetDC(NULL);
    COLORREF color = GetPixel(hdcScreen, g_clickPoint.x, g_clickPoint.y);
    ReleaseDC(NULL, hdcScreen);

    result[EncodableValue("r")] = EncodableValue(GetRValue(color));
    result[EncodableValue("g")] = EncodableValue(GetGValue(color));
    result[EncodableValue("b")] = EncodableValue(GetBValue(color));
    return result;
}

void RegisterColorPickerChannel(flutter::FlutterViewController* controller) {
    auto channel = std::make_unique<flutter::MethodChannel<EncodableValue>>(
        controller->engine()->messenger(),
        "com.example.colorpicker",
        &flutter::StandardMethodCodec::GetInstance()
    );

    channel->SetMethodCallHandler(
        [](const flutter::MethodCall<EncodableValue>& call,
           std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
            if (call.method_name() == "pickColor") {
                EncodableMap color = PickColorOnNextClickGlobal();
                result->Success(EncodableValue(color));
            } else {
                result->NotImplemented();
            }
        }
    );
}

int APIENTRY wWinMain(HINSTANCE, HINSTANCE, wchar_t*, int) {
    flutter::DartProject project(L"data");
    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(450, 300);
    if (!window.Create(L"Color Picker", origin, size)) {
        return EXIT_FAILURE;
    }

    RegisterColorPickerChannel(window.controller());
    window.SetQuitOnClose(true);

    MSG msg;
    while (GetMessage(&msg, nullptr, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    return EXIT_SUCCESS;
}
