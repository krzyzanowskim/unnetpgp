//
//  UNNetPGP.h
//  netpgp
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 Marcin Krzyżanowski
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
@property (strong, atomic) NSArray *availableKeys;

/** password for key **/
@property (copy, atomic) NSString *password;

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

- (BOOL) importKeyFromFileAtPath:(NSString *)inFilePath;
- (NSString *)exportKeyNamed:(NSString *)keyName;

- (BOOL) generateKey:(int)numberOfBits;
- (BOOL) generateKey:(int)numberOfBits named:(NSString *)keyName toDirectory:(NSString *)path;

@end
