//
//  UNNetPGP.h
//  netpgp
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 HAKORE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNNetPGP : NSObject

/** user identifier */
@property (strong, atomic) NSString *userId;

/** home dir for keyrings */
@property (strong, atomic) NSString *homeDirectory;

/** path to public key ring file */
@property (strong, atomic) NSString *publicKeyRingPath;

/** path to secure key ring file */
@property (strong, atomic) NSString *secretKeyRingPath;

/** keys in a keyring */
@property (strong, atomic) NSArray *keys;

/** armored */
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
