//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {

    NSString *handler = app_bundle_id;
    NSString *shortname = @"";

    if ([handler caseInsensitiveCompare:@"company.thebrowser.Browser"] == NSOrderedSame) {
        shortname = @"arc";
    } else if ([handler caseInsensitiveCompare:@"com.brave.Browser"] == NSOrderedSame) {
        shortname = @"brave";
    } else {
        shortname = [[[app_bundle_id componentsSeparatedByString:@"."] lastObject] lowercaseString];
    }

    return shortname;
}

NSMutableDictionary* get_http_handlers() {
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) @"http"
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];

        NSString *shortname = app_name_from_bundle_id(handler);

        dict[shortname] = handler;
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
                char *mark = [key caseInsensitiveCompare:current_handler_name] == NSOrderedSame ? "* " : "  ";
                printf("%s%s\n", mark, [key UTF8String]);
            }
        } else {

            if ([target caseInsensitiveCompare:current_handler_name] == NSOrderedSame) {
                printf("%s is already set as the default HTTP handler\n", [target UTF8String]);
            } else {
                NSString *target_handler = handlers[target];

                if (target_handler != nil) {
                    // Set new HTTP handler (HTTP and HTTPS separately)
                    set_default_handler(@"http", target_handler);
                    set_default_handler(@"https", target_handler);
                } else {
                    printf("%s is not available as an HTTP handler\n", [target UTF8String]);

                    return 1;
                }
            }
        }
    }

    return 0;
}
