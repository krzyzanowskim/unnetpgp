//
//  UNNetPGP_Tests.m
//  UNNetPGP Tests
//
//  Created by Tom Whipple on 11/9/13.
//  Copyright (c) 2013 Tom Whipple. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UNNetPGP.h"

#define PLAINTEXT @"Plaintext: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse blandit justo eros."

@interface UNNetPGP_Tests : XCTestCase {

  UNNetPGP* pgp;
  NSFileManager* fm;
  NSString* plaintextFile;
}

@end

@implementation UNNetPGP_Tests

- (void)setUp
{
  [super setUp];
  
  fm = [NSFileManager defaultManager];

  pgp = [[UNNetPGP alloc] init];
  
  NSError* error = nil;
  NSArray* homeContents = [fm contentsOfDirectoryAtPath:pgp.homeDirectory error:&error];
  XCTAssertTrue(error == nil, @"error reading directory: %@", error.localizedDescription);

  for (NSString* item in homeContents) {
    NSString* itemPath = [pgp.homeDirectory stringByAppendingPathComponent:item];
    [fm removeItemAtPath:itemPath error:&error];
    XCTAssertTrue(error == nil, @"couldn't remove %@:\n%@", itemPath, error.localizedDescription);
  }
  
  plaintextFile = [pgp.homeDirectory stringByAppendingPathComponent:@"plain.txt"];
  
  NSData* plainData = [PLAINTEXT dataUsingEncoding:NSASCIIStringEncoding];
  [plainData writeToFile:plaintextFile atomically:YES];
  XCTAssertTrue([fm fileExistsAtPath:plaintextFile], @"expect file is present");
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testHomeDirectory
{
  NSString* home = [pgp homeDirectory];
  XCTAssertTrue(home != nil, @"home directory should not be nil");
  BOOL isDirectory = NO;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:home isDirectory:&isDirectory];
  XCTAssertTrue(exists && isDirectory, @"home directory should exist");
}

- (void)testBasicGenerateKey
{
  BOOL generated = [pgp generateKey:1024];
  XCTAssertTrue(generated, @"key generation should be true");
}

- (void)testGenerateAndExportNamedKey {
  BOOL generated = [pgp generateKey:2048 named:@"alice" toDirectory:pgp.homeDirectory];
  XCTAssertTrue(generated, @"key generation for Alice should be true");
  
  NSString* keyString = [pgp exportKeyNamed:@"alice"];
  
  XCTAssertTrue([keyString hasPrefix:@"-----BEGIN PGP PUBLIC KEY BLOCK-----"], @"should begin properly instead of\n%@", keyString);
  
  // FAILS: There's extra junk after the end message
  XCTAssertTrue([keyString hasSuffix:@"-----END PGP PUBLIC KEY BLOCK-----"], @"should end properly insetad of\n%@", keyString);
  
}

- (void)testSignData {
  BOOL success = [pgp generateKey:1024];
  XCTAssertTrue(success, @"key generation should be true");
  
  NSData* inData = [PLAINTEXT dataUsingEncoding:NSASCIIStringEncoding];
  NSData* signedData = [pgp signData:inData];
  XCTAssertNotNil(signedData, @"expect signed data");
  
  success = [pgp verifyData:signedData];
  XCTAssertTrue(success, @"expect verification");
}

- (void)testSignFile {
  BOOL success = [pgp generateKey:1024];
  XCTAssertTrue(success, @"key generation should be true");
  
  XCTAssertTrue([fm fileExistsAtPath:plaintextFile], @"expect the plaintext file");
  
  NSString* sigFile = [pgp.homeDirectory stringByAppendingPathComponent:@"signed.asc"];
  XCTAssertFalse([fm fileExistsAtPath:sigFile], @"don't expect a signature yet");
  success = [pgp signFileAtPath:plaintextFile writeSignatureToFile:sigFile detached:YES];
  XCTAssertTrue(success, @"expect successful signing");
  XCTAssertTrue([fm fileExistsAtPath:sigFile], @"expect signature file %@", sigFile);
  
  success = [pgp verifyFileAtPath:sigFile];
  XCTAssertTrue(success, @"expect successful verification");
}

@end
