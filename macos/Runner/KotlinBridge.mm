#import "KotlinBridge.h"
#import "../../account_ledger_lib_kotlin_native/lib/build/bin/macosArm64/releaseShared/libaccount_ledger_lib_api.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <unistd.h>

@implementation KotlinBridge

+ (int)getBatteryLevel {
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    if (!blob) {
        return -1;
    }
    
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    if (!sources) {
        CFRelease(blob);
        return -1;
    }
    
    if (CFArrayGetCount(sources) == 0) {
        CFRelease(sources);
        CFRelease(blob);
        return -1;
    }
    
    CFDictionaryRef pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, 0));
    if (!pSource) {
        CFRelease(sources);
        CFRelease(blob);
        return -1;
    }
    
    const void *psValue;
    int curCapacity = 0;
    int maxCapacity = 100;
    
    psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
    if (psValue) {
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberIntType, &curCapacity);
    }
    
    psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
    if (psValue) {
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberIntType, &maxCapacity);
    }
    
    CFRelease(sources);
    CFRelease(blob);
    
    return (int)((double)curCapacity / (double)maxCapacity * 100.0);
}

+ (void)registerMethodChannelWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"samples.flutter.io/battery"
        binaryMessenger:messenger
        codec:[FlutterStandardMethodCodec sharedInstance]];
    
    [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"getBatteryLevel" isEqualToString:call.method]) {
            int batteryLevel = [KotlinBridge getBatteryLevel];
            
            if (batteryLevel == -1) {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                           message:@"Battery level not available."
                                           details:nil]);
            } else {
                result(@(batteryLevel));
            }
        } else if ([@"getGistData" isEqualToString:call.method]) {
            NSDictionary* args = call.arguments;
            
            NSString* username = args[@"USERNAME"];
            NSString* token = args[@"GITHUB_ACCESS_TOKEN"];
            NSString* gistId = args[@"GIST_ID"];
            
            // Validate required parameters
            if (!username || !token || !gistId) {
                result([FlutterError errorWithCode:@"INVALID_ARGUMENTS"
                                           message:@"Missing required parameters: USERNAME, GITHUB_ACCESS_TOKEN, or GIST_ID"
                                           details:nil]);
                return;
            }
            
            libaccount_ledger_lib_ExportedSymbols *lib = libaccount_ledger_lib_symbols();
            
            libaccount_ledger_lib_kref_account_ledger_library_utils_GistUtilsInteractiveNative newInstance = lib->kotlin.root.account_ledger_library.utils.GistUtilsInteractiveNative.GistUtilsInteractiveNative();
            libaccount_ledger_lib_kref_kotlin_Function3 dummyFunction;
            dummyFunction.pinned = nullptr;
            
            // Redirect stdout to capture the JSON output
            int stdout_backup = dup(STDOUT_FILENO);
            int pipefd[2];
            pipe(pipefd);
            dup2(pipefd[1], STDOUT_FILENO);
            
            // Call the function with isApiCall=true to print JSON
            libaccount_ledger_lib_kref_account_ledger_library_models_AccountLedgerGistModelV3 gistModel = lib->kotlin.root.account_ledger_library.utils.GistUtilsInteractiveNative.processGistIdForDataV3(
                newInstance, 
                [username UTF8String], 
                0, 
                [token UTF8String], 
                [gistId UTF8String], 
                false, 
                true,  // isApiCall=true to print JSON
                false, 
                dummyFunction
            );
            
            // Restore stdout
            fflush(stdout);
            dup2(stdout_backup, STDOUT_FILENO);
            close(pipefd[1]);
            close(stdout_backup);
            
            // Read captured output
            char buffer[65536];
            ssize_t count = read(pipefd[0], buffer, sizeof(buffer) - 1);
            close(pipefd[0]);
            
            if (count > 0) {
                buffer[count] = '\0';
                // Remove trailing newline if present
                if (count > 0 && buffer[count - 1] == '\n') {
                    buffer[count - 1] = '\0';
                }
            } else {
                buffer[0] = '\0';
            }
            
            NSString* resultString = [NSString stringWithUTF8String:buffer];
            
            // Free Kotlin-allocated resources
            lib->DisposeStablePointer(gistModel.pinned);
            lib->DisposeStablePointer(newInstance.pinned);
            
            result(resultString);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

@end
