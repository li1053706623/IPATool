//
//  NSButton+QiEventInterval.h
//  IPATool
//
//  Created by Apple on 2019/1/22.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSButton (QiEventInterval)

@property (nonatomic, assign) NSTimeInterval qi_eventInterval;

@end

NS_ASSUME_NONNULL_END
