//
//  UNNetPGP.h
//  netpgp
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 HAKORE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNNetPGP : NSObject

@property (strong, atomic) NSString *userId;
@property (strong, atomic) NSString *homeDirectory;
@property (strong, atomic) NSString *publicKeyRing;
@property (strong, atomic) NSString *secretKeyRing;
@property (assign) BOOL armored;

- (BOOL) encryptFileAtPath:(NSString *)inFilePath toFileAtPath:(NSString *)outFilePath;
- (BOOL) decryptFileAtPath:(NSString *)inFilePath toFileAtPath:(NSString *)outFilePath;

@end