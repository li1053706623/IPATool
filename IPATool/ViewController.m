//
//  ViewController.m
//  IPATool
//
//  Created by Apple on 2019/1/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "ViewController.h"
#import "IPAFine.h"
#import "HttpManager.h"
#import "NSButton+QiEventInterval.h"

@interface ViewController()<NSTextFieldDelegate>
{
    NSString *_appPath;
   
}
@property (weak) IBOutlet NSTextField *parhTextField;
@property (weak) IBOutlet NSTextField *bundleIdTextField;
@property (weak) IBOutlet NSTextField *objectIdTextField;
@property (weak) IBOutlet NSTextField *resultPathField;
@property (weak) IBOutlet NSTextField *cluesTextField;
@property (weak) IBOutlet NSButton *InjectionButton;
@property (weak) IBOutlet NSTextField *dyldTexrFeild;
@property (weak) IBOutlet NSTextField *endTimeTextFeild;
@property (weak) IBOutlet NSTextField *FrameworkTextField;
@property(nonatomic,strong)NSButton *closeButton;

@property(nonatomic,strong)IPAFine *IpaTool;
@property(nonatomic,strong)NSAlert *alert;
@property(nonatomic,strong)NSString *appName;
@property(nonatomic,strong)NSDatePicker *datePicker;

@end

@implementation ViewController

-(IPAFine *)IpaTool{
    if (!_IpaTool) {
        _IpaTool = [[IPAFine alloc]init];
    }
    return _IpaTool;
}
-(NSDatePicker *)datePicker{
    if (!_datePicker) {
        NSDatePicker *datePicker = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0, 0, 300, 200)];
        [datePicker setDatePickerStyle:NSDatePickerStyleClockAndCalendar];
        datePicker.wantsLayer = YES;
        datePicker.layer.backgroundColor = [NSColor blackColor].CGColor;
        datePicker.alphaValue = 0.8;
        
        // 设置日期选择控件的类型为“时钟和日历”。其他类型有如，NSTextField文本框
        [datePicker setDateValue: [NSDate date]];
        // 初始化选中当前日期
        [datePicker setAction:@selector(updateDateResult:)];
        _datePicker = datePicker;
    }
    return _datePicker;
}
-(NSButton *)closeButton{
    if (!_closeButton) {
        NSButton *closebutton = [NSButton buttonWithTitle:@"关闭" target:self action:@selector(closeButtonClick)];
        closebutton.frame = CGRectMake(220, 140, 80, 80);
        closebutton.wantsLayer = YES;
        closebutton.font = [NSFont systemFontOfSize:12];
        _closeButton = closebutton;
    }
    return _closeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    
    self.parhTextField.selectable = YES;
    self.parhTextField.delegate = self;
    self.dyldTexrFeild.delegate = self;
    self.FrameworkTextField.delegate = self;
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:NSControlTextDidChangeNotification object:self.parhTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DYLBTextChange:) name:NSControlTextDidChangeNotification object:self.dyldTexrFeild];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameworkTextFieldChange:) name:NSControlTextDidChangeNotification object:self];
    [self.InjectionButton setAction:@selector(injection:)];
//
//    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]initWithRect:self.view.frame options:NSTrackingMouseEnteredAndExited
//     owner:self userInfo:nil];
//    [self.view addTrackingArea:trackingArea];
//    [self.view becomeFirstResponder];
   
    // Do any additional setup after loading the view.
}


- (void)textChange:(NSNotification *)noti {
    
     NSTextField *textField = (NSTextField *)noti.object;
    
    NSString *strValue = textField.stringValue;
    if (strValue.length > 3 && [[strValue substringFromIndex:[strValue length] - 4] isEqualToString:@".ipa"] && [[NSFileManager defaultManager] fileExistsAtPath:strValue]) {
        
         [self SetunZipIPA:strValue];

    }
    
  
}
- (void)DYLBTextChange:(NSNotification *)noti {
    
    NSTextField *textField = (NSTextField *)noti.object;
    
//    self.dyldTexrFeild.stringValue = textField.stringValue;
//    NSLog(@"----%@",self.dyldTexrFeild.stringValue);
    NSString *strValue = textField.stringValue;
    if (strValue.length > 6 && [[strValue substringFromIndex:[strValue length] - 6] isEqualToString:@".dylib"] && [[NSFileManager defaultManager] fileExistsAtPath:strValue]) {

        self.dyldTexrFeild.stringValue = textField.stringValue;
//        NSLog(@"----%@",self.dyldTexrFeild.stringValue);

    }
    
    
}
- (void)frameworkTextFieldChange:(NSNotification *)noti {
    
    NSTextField *textField = (NSTextField *)noti.object;
    self.FrameworkTextField.stringValue = textField.stringValue;
    //    self.dyldTexrFeild.stringValue = textField.stringValue;
    //    NSLog(@"----%@",self.dyldTexrFeild.stringValue);
    
    
    
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)ipaPath:(NSButton *)sender {
    
   
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"ipa", @"IPA", @"xcarchive"]];

    if ([openDlg runModal] == NSModalResponseOK)
    {
        
        NSString* fileNameOpened = [[[openDlg URLs] objectAtIndex:0] path];
        [self SetunZipIPA:fileNameOpened];
    }
}
- (IBAction)resultIPAPath:(NSButton *)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSString* fileNameOpened = [[[openDlg URLs] objectAtIndex:0] path];
        [self.resultPathField setStringValue:fileNameOpened];
    }
}
- (IBAction)ChoseTime:(NSButton *)sender {
    self.datePicker.hidden = NO;
    [self.view addSubview:self.datePicker];
    [self.datePicker addSubview:self.closeButton];
    
}
- (IBAction)ChoseFrameWork:(NSButton *)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSString* fileNameOpened = [[[openDlg URLs] objectAtIndex:0] path];
        [self.FrameworkTextField setStringValue:fileNameOpened];
    }
}
-(void)updateDateResult:(NSDatePicker *)datePicker{
    // 拿到当前选择的日期
    NSDate *theDate = [datePicker dateValue];
    if (theDate) {
        // 把选择的日期格式化成想要的形式
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *dateString = [formatter stringFromDate:theDate];
        [self.endTimeTextFeild setStringValue:dateString];
        datePicker.hidden = YES;
    }
}
- (void)injection:(NSButton *)sender {
    
    sender.enabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
   
    
    if ([self.parhTextField.stringValue isEqualToString:@""]||
        [self.bundleIdTextField.stringValue isEqualToString:@""]||
        [self.resultPathField.stringValue isEqualToString:@""]||
        [self.cluesTextField.stringValue isEqualToString:@""] ||
        [self.endTimeTextFeild.stringValue isEqualToString:@""] ||
        [self.FrameworkTextField.stringValue isEqualToString:@""]) {
        [self GetAlert:@"请填写完整"];
        return;
    }
    
//     NSLog(@"------%@",self.appName);
    NSDictionary *parmates = @{@"appname":self.appName,
                               @"bundleid":self.bundleIdTextField.stringValue,
                               @"objectid":self.objectIdTextField.stringValue,
                               @"endTime":self.endTimeTextFeild.stringValue};
    
   
 [self.IpaTool insertAndReplaceAndZipWithbundleIdentifer:self.bundleIdTextField.stringValue WithobjectId:self.objectIdTextField.stringValue WithClues:self.cluesTextField.stringValue WithZip:self.resultPathField.stringValue WithIPA:self.parhTextField.stringValue WithAPPName:self.appName WithDylibName:self.dyldTexrFeild.stringValue withFramework:self.FrameworkTextField.stringValue];

//    __weak __typeof__(self) weakSelf = self;
    [HttpManager postWithURLString:@"http://apptime.qingdabao.com//v1/api0/apptime/add" parameters:parmates success:^(NSDictionary *responseObject) {
//         NSLog(@"---parmates--%@-----responseObject--%@",parmates,responseObject);
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {

            [self GetAlertAndAction:@"注入成功"];
        }else{
            [self GetAlert:@"注入失败"];
        }

    } failure:^(NSError *error) {

        [self GetAlert:@"注入失败"];

    }];
    
 


}


-(void)GetAlert:(NSString *)AlertString{
    NSAlert * alert = [[NSAlert alloc]init];
    alert.alertStyle = NSAlertStyleInformational;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"OK"];
    alert.messageText = AlertString;
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}
-(void)GetAlertAndAction:(NSString *)AlertString{
    NSAlert * alert = [[NSAlert alloc]init];
    alert.alertStyle = NSAlertStyleInformational;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"OK"];
     alert.messageText = AlertString;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        [self.IpaTool doTask:@"/usr/bin/open" arguments:[NSArray arrayWithObjects:self.resultPathField.stringValue, nil]];
    }];
}


-(BOOL)textField:(NSTextField *)textField textView:(NSTextView *)textView shouldSelectCandidateAtIndex:(NSUInteger)index{
    
    return YES;
}

-(void)SetunZipIPA:(NSString *)ipaPath{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString* fileNameOpened = [[[openDlg URLs] objectAtIndex:0] path];
        [self.parhTextField setStringValue:ipaPath];
        [self.resultPathField setStringValue:ipaPath.stringByDeletingLastPathComponent];
        NSString *infoPath = [[self.IpaTool unzipIPA:ipaPath workPath:ipaPath.stringByDeletingPathExtension] stringByAppendingPathComponent:@"Info.plist"];
        NSDictionary *Dict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        
        [self.bundleIdTextField setStringValue:[Dict objectForKey:@"CFBundleIdentifier"]];
        if ([[Dict allKeys] containsObject:@"CFBundleDisplayName"]) {
             weakSelf.appName = [Dict objectForKey:@"CFBundleDisplayName"];
        }else{
             weakSelf.appName = [Dict objectForKey:@"CFBundleName"];
        }
//        if ([[Dict objectForKey:@"CFBundleDisplayName"] isKindOfClass:[NSNull class]]) {
//              weakSelf.appName = [Dict objectForKey:@"CFBundleName"];
//        }else{
//             weakSelf.appName = [Dict objectForKey:@"CFBundleDisplayName"];
//        }
       
      
        
    });
}

- (IBAction)dylbButtonClick:(NSButton *)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"dylib", @"DYLIB"]];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSString* fileNameOpened = [[[openDlg URLs] objectAtIndex:0] path];
        [self.dyldTexrFeild setStringValue:fileNameOpened];
    }
}
-(void)closeButtonClick{
    self.datePicker.hidden = YES;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除监听
}
@end
