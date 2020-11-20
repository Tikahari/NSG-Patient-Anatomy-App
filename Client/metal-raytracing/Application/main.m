/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Application entry point for all platforms
*/

#if defined(TARGET_IOS)
#import <UIKit/UIKit.h>
#import <TargetConditionals.h>
#import <Availability.h>
#import "AppDelegate.h"
#else
#import <Cocoa/Cocoa.h>
#endif

#if defined(TARGET_IOS)

int main(int argc, char * argv[]) {

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

#elif defined(TARGET_MACOS)

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}

#endif
