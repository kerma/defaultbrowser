//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {
    return [[app_bundle_id componentsSeparatedByString:@"."] lastObject];
}

NSMutableDictionary* get_http_handlers() {
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) @"http"
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];
        [dict setObject:handler forKey:[app_name_from_bundle_id(handler) lowercaseString]];
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
                char *mark = [key isEqual:current_handler_name] ? "* " : "  ";
                printf("%s%s\n", mark, [key UTF8String]);
            }
        } else {
            NSString *target_handler_name = [NSString stringWithUTF8String:target];

            if ([target_handler_name isEqual:current_handler_name]) {
              printf("%s is already set as the default HTTP handler\n", target);
            } else {
                NSString *target_handler = [handlers valueForKey:target_handler_name];

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
