#import <Foundation/Foundation.h>
#import <FlutterMacOS/FlutterMacOS.h>

@interface KotlinBridge : NSObject

+ (void)registerMethodChannelWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end
