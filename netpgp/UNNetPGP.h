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

- (BOOL) signFileAtPath:(NSString *)inFilePath writeSignatureToFile:(NSString *)signatureFilePath;
- (BOOL) signFileAtPath:(NSString *)inFilePath writeSignatureToFile:(NSString *)signatureFilePath detached:(BOOL)detached;

- (BOOL) verifyFileAtPath:(NSString *)inFilePath;

- (NSData *) encryptData:(NSData *)inData;
- (NSData *) decryptData:(NSData *)inData;

- (NSData *) signData:(NSData *)data;
- (BOOL) verifyData:(NSData *)inData;

@end
