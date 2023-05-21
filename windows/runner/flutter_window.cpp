#include "flutter_window.h"

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include "../../account_ledger_lib_kotlin_native/lib/build/bin/mingwX64/debugShared/account_ledger_lib_api.h"

using namespace std;

static constexpr int kBatteryError = -1;
static constexpr int kNoBattery = -2;

static int GetBatteryLevel() {
  SYSTEM_POWER_STATUS status;
  if (GetSystemPowerStatus(&status) == 0) {
    return kBatteryError;
  } else if (status.BatteryFlag == 128) {
    return kNoBattery;
  } else if (status.BatteryLifePercent == 255) {
    return kBatteryError;
  }
  return status.BatteryLifePercent;
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
          flutter_controller_->engine()->messenger(), "samples.flutter.io/battery",
          &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
          [](const flutter::MethodCall<>& call,
             std::unique_ptr<flutter::MethodResult<>> result) {
              if (call.method_name() == "getBatteryLevel") {
                int battery_level = GetBatteryLevel();

                if (battery_level == kBatteryError) {
                  result->Error("UNAVAILABLE", "Battery level not available.");
                } else if (battery_level == kNoBattery) {
                  result->Error("NO_BATTERY", "Device does not have a battery.");
                } else {
                  result->Success(battery_level);
                }
              } else if (call.method_name() == "getGistData") {

                account_ledger_lib_ExportedSymbols *lib = account_ledger_lib_symbols();

                account_ledger_lib_kref_account_ledger_library_utils_GistUtils newInstance = lib->kotlin.root.account_ledger_library.utils.GistUtils.GistUtils();
                string accountLedgerGistText  = lib->kotlin.root.account_ledger_library.utils.GistUtils.processGistIdForTextData(newInstance, "USERNAME", "GITHUB_ACCESS_TOKEN", "GIST_ID", false, false);
                lib->DisposeStablePointer(newInstance.pinned);

                result->Success(accountLedgerGistText);

              } else {
                  result->NotImplemented();
              }
          });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
