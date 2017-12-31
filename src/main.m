//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {
    return [[app_bundle_id componentsSeparatedByString:@"."] lastObject];
}

NSMutableDictionary* get_http_handlers(NSArray *url_scheme_refs) {
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) ([url_scheme_refs objectAtIndex:0])
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];
        [dict setObject:handler forKey:[app_name_from_bundle_id(handler) lowercaseString]];
    }

    return dict;
}

NSString* get_current_http_handler(NSArray *url_scheme_refs) {
    NSString *handler =
        (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(
            (__bridge CFStringRef) ([url_scheme_refs objectAtIndex:0])
        );

    return app_name_from_bundle_id(handler);
}

int main(int argc, const char *argv[]) {
    const char *target = (argc == 1) ? '\0' : argv[1];

    @autoreleasepool {
        NSArray *url_scheme_refs = [[NSArray alloc] initWithObjects:@"http", @"https", nil];

        // Get all HTTP handlers
        NSMutableDictionary *handlers = get_http_handlers(url_scheme_refs);

        // Get current HTTP handler
        NSString *current_handler_name = get_current_http_handler(url_scheme_refs);

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
                    for (NSString *url_scheme_ref in url_scheme_refs) {
                        LSSetDefaultHandlerForURLScheme(
                            (__bridge CFStringRef) url_scheme_ref,
                            (__bridge CFStringRef) target_handler
                        );
                    }
                } else {
                    printf("%s is not available as an HTTP handler\n", target);

                    return 1;
                }
            }
        }
    }

    return 0;
}
