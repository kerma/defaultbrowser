//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NSMutableDictionary* get_http_handlers(NSArray *url_scheme_refs) {
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) ([url_scheme_refs objectAtIndex:0])
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];
        NSArray  *parts   = [handler componentsSeparatedByString:@"."];
        [dict setObject:handler forKey:[[parts lastObject] lowercaseString]];
    }

    return dict;
}

NSString* get_current_http_handler(NSArray *url_scheme_refs) {
    NSString *handler =
        (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(
            (__bridge CFStringRef) ([url_scheme_refs objectAtIndex:0])
        );

    handler = [[handler componentsSeparatedByString:@"."] lastObject];

    return handler;
}

int main(int argc, const char *argv[]) {
    const char *target = argv[1];

    @autoreleasepool {
        NSArray *url_scheme_refs = [[NSArray alloc] initWithObjects:@"http", @"https", nil];

        // Get all HTTP handlers
        NSMutableDictionary *handlers = get_http_handlers(url_scheme_refs);

        if (target == NULL) {
            // Get current HTTP handler
            NSString *currentHandler = get_current_http_handler(url_scheme_refs);

            // List all HTTP handlers, marking the current one with a star
            for (NSString *key in handlers) {
                char *mark = (key == currentHandler) ? "* " : "  ";
                printf("%s%s\n", mark, [key cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        } else {
            NSString *target_handler = [handlers valueForKey:[NSString stringWithUTF8String:target]];

            // Set new HTTP handler
            if (target_handler != nil) {
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

    return 0;
}
