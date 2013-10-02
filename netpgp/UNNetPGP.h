//
//  UNNetPGP.h
//  netpgp
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 HAKORE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNNetPGP : NSObject

@property (strong, nonatomic) NSString *userId;


- (BOOL) encrypt:(NSURL *)inFileURL to:(NSURL *)outFileURL;

@end
