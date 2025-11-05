//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {
    return [[[app_bundle_id componentsSeparatedByString:@"."] lastObject] lowercaseString];
}

NSMutableDictionary* get_http_handlers() {
    NSURL *url = [NSURL URLWithString:@"http://example.com"];
    NSArray<NSURL *> *appURLs = [[NSWorkspace sharedWorkspace] URLsForApplicationsToOpenURL:url];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (NSURL *appURL in appURLs) {
        NSBundle *bundle = [NSBundle bundleWithURL:appURL];
        NSString *bundleId = [bundle bundleIdentifier];
        if (bundleId) {
            dict[app_name_from_bundle_id(bundleId)] = bundleId;
        }
    }

    return dict;
}

NSString* get_current_http_handler() {
    NSURL *url = [NSURL URLWithString:@"http://example.com"];
    NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:url];

    if (appURL) {
        NSBundle *bundle = [NSBundle bundleWithURL:appURL];
        NSString *bundleId = [bundle bundleIdentifier];
        if (bundleId) {
            return app_name_from_bundle_id(bundleId);
        }
    }

    return nil;
}

void set_default_handler(NSString *url_scheme, NSString *handler) {
    LSSetDefaultHandlerForURLScheme(
        (__bridge CFStringRef) url_scheme,
        (__bridge CFStringRef) handler
    );
}

int main(int argc, const char *argv[]) {
    const char *target = (argc == 1) ? NULL : argv[1];

    @autoreleasepool {
        // Get all HTTP handlers
        NSMutableDictionary *handlers = get_http_handlers();

        // Get current HTTP handler
        NSString *current_handler_name = get_current_http_handler();

        if (target == NULL) {
            // List all HTTP handlers, marking the current one with a star
            for (NSString *key in handlers) {
                char *mark = [key caseInsensitiveCompare:current_handler_name] == NSOrderedSame ? "* " : "  ";
                printf("%s%s\n", mark, [key UTF8String]);
            }
        } else {
            NSString *target_handler_name = [NSString stringWithUTF8String:target];

            if ([target_handler_name caseInsensitiveCompare:current_handler_name] == NSOrderedSame) {
              printf("%s is already set as the default HTTP handler\n", target);
            } else {
                NSString *target_handler = handlers[target_handler_name];

                if (target_handler != nil) {
                    // Set new HTTP handler (HTTP and HTTPS separately)
                    set_default_handler(@"http", target_handler);
                    set_default_handler(@"https", target_handler);
                } else {
                    printf("%s is not available as an HTTP handler\n", target);

                    return 1;
                }
            }
        }
    }

    return 0;
}
