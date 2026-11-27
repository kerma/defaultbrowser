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
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) @"http"
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];
        dict[app_name_from_bundle_id(handler)] = handler;
    }

    return dict;
}

NSString* get_current_http_handler() {
    NSString *handler =
        (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(
            (__bridge CFStringRef) @"http"
        );

    return app_name_from_bundle_id(handler);
}

void set_default_handler(NSString *url_scheme, NSString *handler) {
    LSSetDefaultHandlerForURLScheme(
        (__bridge CFStringRef) url_scheme,
        (__bridge CFStringRef) handler
    );
}

// NSWorkspace (macOS 12+) shows one prompt per call, so https is set only if http did not carry over.
BOOL set_default_handler_modern(NSString *url_scheme, NSString *handler) {
    if (@available(macOS 12.0, *)) {
        NSURL *app_url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:handler];
        if (app_url == nil) return NO;

        dispatch_semaphore_t done = dispatch_semaphore_create(0);
        [[NSWorkspace sharedWorkspace] setDefaultApplicationAtURL:app_url
                                             toOpenURLsWithScheme:url_scheme
                                                completionHandler:^(NSError *error) {
            if (error != nil) {
                fprintf(stderr, "Failed to set %s: %s\n", [url_scheme UTF8String],
                        [[error localizedDescription] UTF8String]);
            }
            dispatch_semaphore_signal(done);
        }];
        dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
        return YES;
    }
    return NO;
}

BOOL is_default_handler(NSString *url_scheme, NSString *handler) {
    NSString *current = (NSString *) CFBridgingRelease(LSCopyDefaultHandlerForURLScheme(
        (__bridge CFStringRef) url_scheme
    ));
    return [current caseInsensitiveCompare:handler] == NSOrderedSame;
}

void set_http_and_https(NSString *handler) {
    if (!set_default_handler_modern(@"http", handler)) {
        set_default_handler(@"http", handler);
        set_default_handler(@"https", handler);
        return;
    }

    if (!is_default_handler(@"https", handler)) {
        set_default_handler_modern(@"https", handler);
    }
}

int main(int argc, const char *argv[]) {
    const char *target = (argc == 1) ? '\0' : argv[1];

    @autoreleasepool {
        // Get all HTTP handlers
        NSMutableDictionary *handlers = get_http_handlers();

        // Get current HTTP handler
        NSString *current_handler_name = get_current_http_handler();

        if (target == '\0') {
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
                    set_http_and_https(target_handler);
                } else {
                    printf("%s is not available as an HTTP handler\n", target);

                    return 1;
                }
            }
        }
    }

    return 0;
}
