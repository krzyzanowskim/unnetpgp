//
//  UNNetPGP.m
//  netpgp
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 HAKORE. All rights reserved.
//

#import "UNNetPGP.h"
#import "netpgp.h"

static dispatch_queue_t lock_queue;

@implementation UNNetPGP

@synthesize availableKeys = _availableKeys;

+ (void)initialize
{
    lock_queue = dispatch_queue_create("UUNetPGP lock queue", DISPATCH_QUEUE_SERIAL);
}

- (instancetype) init
{
    if (self = [super init]) {
        // by default search keys in resources
        self.homeDirectory = [[NSBundle mainBundle] resourcePath];
    }
    return self;
}

#pragma mark - Data

- (NSData *) encryptData:(NSData *)inData
{
    __block NSData *result = nil;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            void *inbuf = calloc(inData.length, sizeof(Byte));
            memcpy(inbuf, inData.bytes, inData.length);
            
            int maxlen = (int)(inData.length * 1.2f); // magic number 1.2, how much bigger it can be?
            void *outbuf = calloc(maxlen, sizeof(Byte));
            int outsize = netpgp_encrypt_memory(netpgp, [self.userId UTF8String], inbuf, inData.length, outbuf, maxlen, self.armored ? 1 : 0);
            
            if (outsize > 0) {
                result = [NSData dataWithBytesNoCopy:outbuf length:outsize freeWhenDone:YES];
            }
            
            [self finishnetpgp:netpgp];
            
            if (inbuf)
                free(inbuf);
        }
    });
    
    return result;
}

- (NSData *) decryptData:(NSData *)inData
{
    __block NSData *result = nil;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            int maxlen = (int)(inData.length * 1.2f); // magic number 1.2, how much bigger it can be?
            void *outbuf = calloc(maxlen, sizeof(Byte));
            int outsize = netpgp_decrypt_memory(netpgp, inData.bytes, inData.length, outbuf, maxlen, self.armored ? 1 : 0);
            
            if (outsize > 0) {
                result = [NSData dataWithBytesNoCopy:outbuf length:outsize freeWhenDone:YES];
            }
            
            [self finishnetpgp:netpgp];
        }
    });
    
    return result;
}

- (NSData *) signData:(NSData *)inData
{
    __block NSData *result = nil;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            void *inbuf = calloc(inData.length, sizeof(Byte));
            memcpy(inbuf, inData.bytes, inData.length);
            
            int maxlen = (int)(inData.length * 1.2f); // magic number 1.2, how much bigger it can be?
            void *outbuf = calloc(maxlen, sizeof(Byte));
            int outsize = netpgp_sign_memory(netpgp, [self.userId UTF8String], inbuf, inData.length, outbuf, maxlen, self.armored ? 1 : 0, 1 /* cleartext */);
            
            if (outsize > 0) {
                result = [NSData dataWithBytesNoCopy:outbuf length:outsize freeWhenDone:YES];
            }
            
            [self finishnetpgp:netpgp];
            
            if (inbuf)
                free(inbuf);
        }
    });
    
    return result;
}

- (BOOL) verifyData:(NSData *)inData
{
    __block BOOL result = NO;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            result = netpgp_verify_memory(netpgp, inData.bytes, inData.length, NULL, 0, self.armored ? 1 : 0);
            [self finishnetpgp:netpgp];
        }
    });
    
    return result;
}


#pragma mark - Files

/**
 Encrypt file.
 
 @param inFilePath File to encrypt
 @param outFilePath Optional. If `nil` then encrypted name is created at the same path as original file with addedd suffix `.gpg`.
 @return `YES` if operation success.
 
 Encrypted file is created at outFilePath, file is overwritten if already exists.
 */
- (BOOL) encryptFileAtPath:(NSString *)inFilePath toFileAtPath:(NSString *)outFilePath
{
    __block BOOL result = NO;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:inFilePath])
        return NO;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        
        if (netpgp) {
            char infilepath[inFilePath.length];
            strcpy(infilepath, inFilePath.UTF8String);

            char *outfilepath = NULL;
            if (outFilePath) {
                outfilepath = calloc(outFilePath.length, sizeof(char));
                strcpy(outfilepath, outFilePath.UTF8String);
            }

            result = netpgp_encrypt_file(netpgp, [self.userId UTF8String], infilepath, outfilepath, self.armored ? 1 : 0);

            [self finishnetpgp:netpgp];

            if (outfilepath)
                free(outfilepath);
        }
    });

    return result;
}

/**
 Decrypt file.
 
 @param inFilePath File to encrypt
 @param outFilePath Optional. If `nil` then encrypted name is created at the same path as original file with addedd suffix `.gpg`.
 @return `YES` if operation success.
 
 Descrypted file is created at outFilePath, file is overwritten if already exists.
 */
- (BOOL) decryptFileAtPath:(NSString *)inFilePath toFileAtPath:(NSString *)outFilePath
{
    __block BOOL result = NO;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:inFilePath])
        return NO;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            char infilepath[inFilePath.length];
            strcpy(infilepath, inFilePath.UTF8String);
            
            char *outfilepath = NULL;
            if (outFilePath) {
                outfilepath = calloc(outFilePath.length, sizeof(char));
                strcpy(outfilepath, outFilePath.UTF8String);
            }
            
            result = netpgp_decrypt_file(netpgp, infilepath, outfilepath, self.armored ? 1 : 0);
            
            [self finishnetpgp:netpgp];

            if (outfilepath)
                free(outfilepath);
        }
    });

    return result;
}

- (BOOL) signFileAtPath:(NSString *)inFilePath writeSignatureToFile:(NSString *)signatureFilePath
{
    return [self signFileAtPath:inFilePath writeSignatureToFile:signatureFilePath detached:YES];
}

- (BOOL) signFileAtPath:(NSString *)inFilePath writeSignatureToFile:(NSString *)signatureFilePath detached:(BOOL)detached
{
    __block BOOL result = NO;

    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            char infilepath[inFilePath.length];
            strcpy(infilepath, inFilePath.UTF8String);
            
            char *outfilepath = NULL;
            if (signatureFilePath) {
                outfilepath = calloc(signatureFilePath.length, sizeof(char));
                strcpy(outfilepath, signatureFilePath.UTF8String);
            }
            
            result = netpgp_sign_file(netpgp, [self.userId UTF8String], infilepath, outfilepath /* sigfile name */, self.armored ? 1 : 0, 1 /* cleartext */, detached ? 1 : 0 /* detached */);
            
            [self finishnetpgp:netpgp];
        }
    });
    
    return result;
}

- (BOOL) verifyFileAtPath:(NSString *)inFilePath
{
    __block BOOL result = NO;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            char infilepath[inFilePath.length];
            strcpy(infilepath, inFilePath.UTF8String);
            
            result = netpgp_verify_file(netpgp, infilepath, NULL, self.armored ? 1 : 0);
            
            [self finishnetpgp:netpgp];
        }
    });
    
    return result;
}

#pragma mark - Keys

- (NSArray *)availableKeys
{
    __block NSArray *keysDict = nil;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            
            char *jsonCString = NULL;
            if (netpgp_list_keys_json(netpgp, &jsonCString, 0) && (jsonCString != NULL)) {
                NSError *error = nil;
                keysDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:jsonCString length:strlen(jsonCString)] options:0 error:&error];
            }
            free(jsonCString);
            
            [self finishnetpgp:netpgp];
        }
    });
    return keysDict;
}

- (void)setAvailableKeys:(NSArray *)keys
{
    dispatch_sync(lock_queue, ^{
        _availableKeys = keys;
    });
}

- (NSString *)exportKeyNamed:(NSString *)keyName
{
    __block NSString *keyData;
    
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {            
            char keyname[keyName.length];
            strcpy(keyname, keyName.UTF8String);
            
            char *keydata = netpgp_export_key(netpgp, keyname);
            if (keydata) {
                keyData = [NSString stringWithCString:keydata encoding:NSASCIIStringEncoding];
                free(keydata);
            }
            
            [self finishnetpgp:netpgp];
        }
    });
    return keyData;
}

/** import a key into keyring */
- (BOOL) importKeyFromFileAtPath:(NSString *)inFilePath
{
    __block BOOL result = NO;
    dispatch_sync(lock_queue, ^{
        netpgp_t *netpgp = [self buildnetpgp];
        if (netpgp) {
            
            char infilepath[inFilePath.length];
            strcpy(infilepath, inFilePath.UTF8String);
            result = netpgp_import_key(netpgp, infilepath);
            
            [self finishnetpgp:netpgp];
        }
    });
    
    return result;
}

#pragma mark - private

- (netpgp_t *) buildnetpgp;
{
    // Love http://jverkoey.github.io/fmemopen/

    netpgp_t *netpgp = calloc(0x1, sizeof(netpgp_t));
    
    if (self.userId)
        netpgp_setvar(netpgp, "userid", [self.userId UTF8String]);
    
    if (self.homeDirectory)
        netpgp_setvar(netpgp, "homedir", [self.homeDirectory UTF8String]);
    
    if (self.secretKeyRingPath)
        netpgp_setvar(netpgp, "secring", [self.secretKeyRingPath UTF8String]);
    
    if (self.publicKeyRingPath)
        netpgp_setvar(netpgp, "pubring", [self.publicKeyRingPath UTF8String]);
    
    if (!netpgp_init(netpgp)) {
        NSLog(@"Can't initialize netpgp stack");
        free(netpgp);
        return nil;
    }
    
    return netpgp;
}

- (void) finishnetpgp:(netpgp_t *)netpgp
{
    if (!netpgp) {
        return;
    }
    
    netpgp_end(netpgp);
    free(netpgp);
}


@end
