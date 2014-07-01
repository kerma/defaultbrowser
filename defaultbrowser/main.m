//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // handler command line -set argument
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        NSString *set = [args stringForKey:@"set"];
        
        // we're interested in things which can handle http
        CFStringRef urlschemeref = (__bridge CFStringRef)@"http";
        
        if (set == nil) {
            // what is our current handler?
            NSString *currentHandler = (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(urlschemeref);
            currentHandler = [[currentHandler componentsSeparatedByString:@"."] lastObject];
            printf("Current: %s\n\n", [currentHandler cStringUsingEncoding:NSUTF8StringEncoding]);
            printf("Use -set <browser> to set a new default HTTP handler\n");
        } else {
            // lets figure out which handlers are available
            NSArray *HTTPHandlers = (__bridge NSArray *) LSCopyAllHandlersForURLScheme(urlschemeref);
            NSMutableDictionary *handlers = [NSMutableDictionary dictionary];
            for (int i = 0; i < [HTTPHandlers count]; i++) {
                NSString *split = HTTPHandlers[i];
                NSArray *parts = [split componentsSeparatedByString:@"."];
                [handlers setObject:split  forKey:[[parts lastObject] lowercaseString]];
            }
            
            // set a new default
            if ([handlers valueForKey:[set lowercaseString]] != nil) {
                CFStringRef newHandler = (__bridge CFStringRef)([handlers valueForKey:[set lowercaseString]]);
                OSStatus s = LSSetDefaultHandlerForURLScheme(urlschemeref, newHandler);
                if (s == 0) {
                    printf("New default browser: %s\n", [set cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                else {
                    printf("Setting a new default browser failed\n");
                    return 1;
                }
            } else {
                printf("%s is not available as a HTTP browser\n", [set cStringUsingEncoding:NSUTF8StringEncoding]);
                printf("Available browsers:\n");
                for (NSString *key in handlers) {
                    printf("- %s\n", [key cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                return 1;
            }
        }
    }
    return 0;
}

