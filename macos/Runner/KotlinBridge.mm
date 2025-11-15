#import "KotlinBridge.h"
#import "../../account_ledger_lib_kotlin_native/lib/build/bin/macosArm64/debugShared/libaccount_ledger_lib_api.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>

@implementation KotlinBridge

+ (int)getBatteryLevel {
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    
    if (CFArrayGetCount(sources) == 0) {
        CFRelease(blob);
        CFRelease(sources);
        return -1;
    }
    
    CFDictionaryRef pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, 0));
    if (!pSource) {
        CFRelease(blob);
        CFRelease(sources);
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
    
    CFRelease(blob);
    CFRelease(sources);
    
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
            
            libaccount_ledger_lib_ExportedSymbols *lib = libaccount_ledger_lib_symbols();
            
            libaccount_ledger_lib_kref_account_ledger_library_utils_GistUtilsInteractiveNative newInstance = lib->kotlin.root.account_ledger_library.utils.GistUtilsInteractiveNative.GistUtilsInteractiveNative();
            libaccount_ledger_lib_kref_kotlin_Function3 dummyFunction;
            dummyFunction.pinned = nullptr;
            
            NSString* username = args[@"USERNAME"];
            NSString* token = args[@"GITHUB_ACCESS_TOKEN"];
            NSString* gistId = args[@"GIST_ID"];
            
            const char *accountLedgerGistText = lib->kotlin.root.account_ledger_library.utils.GistUtilsInteractiveNative.processGistIdForDataV3(
                newInstance, 
                [username UTF8String], 
                0, 
                [token UTF8String], 
                [gistId UTF8String], 
                false, 
                false, 
                false, 
                dummyFunction
            );
            
            lib->DisposeStablePointer(newInstance.pinned);
            
            NSString* resultString = [NSString stringWithUTF8String:accountLedgerGistText];
            result(resultString);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

@end
