//
//  UNNetPGP.m
//  netpgp
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 HAKORE. All rights reserved.
//

#import "UNNetPGP.h"
#import "netpgp.h"

@implementation UNNetPGP {
    netpgp_t netpgp;
}

- (instancetype) init
{
    if (self = [super init]) {
        memset(&netpgp, 0x0, sizeof(netpgp));
    }
    return self;
}

- (void) dealloc
{
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    
    const char *userIdCString = [userId UTF8String];
    netpgp_setvar(&netpgp, "userid", userIdCString);
}

- (BOOL) encrypt:(NSURL *)inFileURL to:(NSURL *)outFileURL
{
    netpgp_setvar(&netpgp, "homedir", [[[self class] homeDirectory] UTF8String]);
    if (!netpgp_init(&netpgp)) {
        NSLog(@"Can't initialize %@",[self class]);
        return NO;
    }
    
    char infilepath[inFileURL.path.length];
    strcpy(infilepath, inFileURL.path.UTF8String);
    
//    char outfilepath[outFileURL.path.length];
//    strcpy(outfilepath, outFileURL.path.UTF8String);

    BOOL ret = netpgp_encrypt_file(&netpgp, [self.userId UTF8String], infilepath, NULL, 0);
    
    netpgp_end(&netpgp);
    
    return ret;
}

- (BOOL) run
{
    
    netpgp_setvar(&netpgp, "homedir", [[[self class] homeDirectory] UTF8String]);
    if (!netpgp_init(&netpgp)) {
        NSLog(@"Can't initialize %@",[self class]);
        return NO;
    }

    netpgp_end(&netpgp);
    return YES;
}


+ (NSString *) homeDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
