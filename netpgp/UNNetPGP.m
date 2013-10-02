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

@implementation UNNetPGP {
}

+ (void)initialize
{
    lock_queue = dispatch_queue_create("UUNetPGP lock queue", DISPATCH_QUEUE_SERIAL);
}

- (instancetype) init
{
    if (self = [super init]) {
        // by default search keys in Document directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.homeDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    }
    return self;
}

- (void) dealloc
{
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


#pragma mark - private

- (netpgp_t *) buildnetpgp;
{
    netpgp_t *netpgp = calloc(0x1, sizeof(netpgp_t));
    
    if (self.userId)
        netpgp_setvar(netpgp, "userid", [self.userId UTF8String]);
    
    if (self.homeDirectory)
        netpgp_setvar(netpgp, "homedir", [self.homeDirectory UTF8String]);
    
    if (self.secretKeyRing)
        netpgp_setvar(netpgp, "secring", [self.secretKeyRing UTF8String]);
    
    if (self.publicKeyRing)
        netpgp_setvar(netpgp, "pubring", [self.publicKeyRing UTF8String]);
    
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
