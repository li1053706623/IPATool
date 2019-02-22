//
//  IPAFine.m
//  IPATool
//
//  Created by Apple on 2019/1/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "IPAFine.h"

@implementation IPAFine

- (NSString *)doTask:(NSString *)path arguments:(NSArray *)arguments currentDirectory:(NSString *)currentDirectory
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = path;
    task.arguments = arguments;
    if (currentDirectory) task.currentDirectoryPath = currentDirectory;
    
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    task.standardError = pipe;
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    NSString *result = data.length ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
    
    NSLog(@"CMD:\n%@\n%@ARG\n\n%@\n\n", path, arguments, (result ? result : @""));
    return result;
}
//
- (NSString *)doTask:(NSString *)path arguments:(NSArray *)arguments
{
   return [self doTask:path arguments:arguments currentDirectory:nil];
}
- (NSString *)unzipIPA:(NSString *)ipaPath workPath:(NSString *)workPath{
   
    
    NSString *result = [self doTask:@"/usr/bin/unzip" arguments:[NSArray arrayWithObjects:@"-q", ipaPath, @"-d", workPath, nil]];
    NSString *payloadPath = [workPath stringByAppendingPathComponent:@"Payload"];
//    NSLog(@"---payloadPath---%@",payloadPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:payloadPath])
    {
        NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:payloadPath error:nil];
        for (NSString *dir in dirs)
        {
            if ([dir.pathExtension.lowercaseString isEqualToString:@"app"])
            {

                NSString* appPath = [payloadPath stringByAppendingPathComponent:dir];
                //删除Watch和PlugIns两个目录
                NSString* watchPath = [appPath stringByAppendingPathComponent:@"Watch"];
                NSString* plugInsPath = [appPath stringByAppendingPathComponent:@"PlugIns"];

                [self doTask:@"/bin/rm" arguments:[NSArray arrayWithObjects:@"-rf", watchPath, nil]];
                [self doTask:@"/bin/rm" arguments:[NSArray arrayWithObjects:@"-rf", plugInsPath, nil]];
                _appPath = appPath;
//                //拷贝资源文件
//                NSString  *bundlePath = [[ NSBundle   mainBundle ]. resourcePath   stringByAppendingPathComponent : @"GCDWebUploader.bundle" ];
//                [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:@"-rf",bundlePath, appPath, nil]];

                //拷贝沙盒和配置文件到工程目录下
                //NSString  *settingFilePath = [[ NSBundle   mainBundle ]. resourcePath   stringByAppendingPathComponent : @"setting.prop" ];
                // [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:@"-rf",settingFilePath, appPath, nil]];
                //NSString  *documentsPath = [[ NSBundle   mainBundle ]. resourcePath   stringByAppendingPathComponent : @"Documents.zip" ];
                //[self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:@"-rf",documentsPath, appPath, nil]];


                return appPath;
            }
        }
        _error = @"Invalid app";
        return nil;
    }
    _error = [@"Unzip failed:" stringByAppendingString:result ? result : @""];
   return nil;
}

- (void)injectApp:(NSString *)appPath dylibPath:(NSString *)dylibPath frameworkpath:(NSString *)framework{
    
    NSString *infoPath = [appPath stringByAppendingPathComponent:@"Info.plist"];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath];
    NSString *exeName = [info objectForKey:@"CFBundleExecutable"];
    NSString *exePath = [appPath stringByAppendingPathComponent:exeName];
 
    [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:@"-rf",framework,appPath, nil]];
     //动态库注入到可执行文件中
    [self doTask:@"/bin/chmod" arguments:[NSArray arrayWithObjects:@"+x",exeName, nil]];
    [self doTask:@"/usr/local/bin/yololib" arguments:@[exePath,[NSString stringWithFormat:@"Frameworks/%@",[dylibPath lastPathComponent]]]];
    
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Frameworks",appPath]]) {
//        NSString *framework = [NSString stringWithFormat:@"%@/Frameworks",appPath];
//        [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:@"-rf",@"/Users/apple/Desktop/Frameworks/libsubstrate.dylib",framework, nil]];
//        [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:@"-rf",dylibPath,framework, nil]];
//        [self doTask:@"/usr/bin/cd" arguments:@[appPath]];
//        [self doTask:@"/bin/chmod" arguments:[NSArray arrayWithObjects:@"+x",exeName, nil]];
//        [self doTask:@"/usr/local/bin/yololib" arguments:@[exePath,[NSString stringWithFormat:@"Frameworks/%@",[dylibPath lastPathComponent]]]];
//
//
//    }
//    if (dylibPath.length)
//    {
//        NSString *targetPath= nil;
//
//        if ([[NSFileManager defaultManager] fileExistsAtPath:dylibPath])
//        {
//            targetPath = [appPath stringByAppendingPathComponent:[dylibPath lastPathComponent]];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath])
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
//            }
//
//            [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:dylibPath, targetPath, nil]];
//
//        }
//
//        // Find executable
//        NSString *infoPath = [appPath stringByAppendingPathComponent:@"Info.plist"];
//        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath];
//        NSString *exeName = [info objectForKey:@"CFBundleExecutable"];
//        if (exeName == nil)
//        {
//            _error = [NSString stringWithFormat:@"Inject failed: No CFBundleExecutable on %@", infoPath];
//            return;
//        }
//        NSString *exePath = [appPath stringByAppendingPathComponent:exeName];
//        NSString *dylibName=[[dylibPath componentsSeparatedByString:@"/"] lastObject];
//        //动态库注入到可执行文件中
//        [self doTask:@"/usr/bin/cd" arguments:@[appPath]];
//        [self doTask:@"/usr/local/bin/yololib" arguments:@[exePath,dylibName]];
//    }
}
-(void)insertAndReplaceAndZipWithbundleIdentifer:(NSString *)bundleIdentifer WithobjectId:(NSString *)objectId WithClues:(NSString *)clues WithZip:(NSString *)result WithIPA:(NSString *)IPAPath  WithAPPName:(NSString *)appName WithDylibName:(nonnull NSString *)dylib withFramework:(nonnull NSString *)framework{
    
    NSString *infoPath = [_appPath stringByAppendingPathComponent:@"Info.plist"];
    NSString *resultStr = [NSString stringWithFormat:@"iOS_%@",appName];
    NSString *outPauth =[NSString stringWithFormat:@"%@/%@.ipa",IPAPath.stringByDeletingLastPathComponent,resultStr];
  
    NSDictionary *InfoDict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    if ([[InfoDict allKeys] containsObject:@"objectid"] && [[InfoDict allKeys] containsObject:@"clues"]) {
        if (![objectId isEqualToString:@""]) {
            [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Set:objectid '%@'",objectId],infoPath, nil]];
        }
        [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Set:clues '%@'",clues],infoPath, nil]];
    }else if (![[InfoDict allKeys] containsObject:@"objectid"] && ![[InfoDict allKeys] containsObject:@"clues"]){
        if (![objectId isEqualToString:@""]) {
            [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Add:objectid string '%@'",objectId],infoPath, nil]];
        }

        [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Add:clues string '%@'",clues],infoPath, nil]];
    }else{
        if (![objectId isEqualToString:@""]) {
            [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Add:objectid string '%@'",objectId],infoPath, nil]];
        }
        [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Set:clues '%@'",clues],infoPath, nil]];
    }

    [self doTask:@"/usr/libexec/PlistBuddy" arguments:[NSArray arrayWithObjects:@"-c",[NSString stringWithFormat:@"Set:CFBundleIdentifier '%@'",bundleIdentifer],infoPath, nil]];
    
    [self injectApp:_appPath dylibPath:dylib frameworkpath:framework];

    [self doTask:@"/usr/bin/xcrun" arguments:[NSArray arrayWithObjects:@"-sdk",@"iphoneos",@"PackageApplication",@"-v",_appPath,@"-o",outPauth, nil]];

    [self doTask:@"/bin/rm" arguments:[NSArray arrayWithObjects:@"-rf",IPAPath.stringByDeletingPathExtension, nil]];
    
   
}
@end
