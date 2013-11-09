//
//  UNNetPGP_Tests.m
//  UNNetPGP Tests
//
//  Created by Tom Whipple on 11/9/13.
//  Copyright (c) 2013 Tom Whipple. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UNNetPGP.h"

@interface UNNetPGP_Tests : XCTestCase {

  UNNetPGP* pgp;
  
}

@end

@implementation UNNetPGP_Tests

- (void)setUp
{
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  pgp = [[UNNetPGP alloc] init];
}

- (void)tearDown
{
  // Put teardown code here. This method is called after the invocation of each test method in the class.
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



@end
