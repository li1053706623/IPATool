//
//  IPAFine.h
//  IPATool
//
//  Created by Apple on 2019/1/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPAFine : NSObject
{
    NSString *_error;
    NSString *_appPath;
}

- (NSString *)doTask:(NSString *)path arguments:(NSArray *)arguments;

- (NSString *)unzipIPA:(NSString *)ipaPath workPath:(NSString *)workPath;

- (void)insertAndReplaceAndZipWithbundleIdentifer:(NSString *)bundleIdentifer WithobjectId:(NSString *)objectId WithClues:(NSString *)clues WithZip:(NSString *)result WithIPA:(NSString *)IPAPath WithAPPName:(NSString *)appName WithDylibName:(NSString *)dylib withFramework:(NSString *)framework;

@end

NS_ASSUME_NONNULL_END
