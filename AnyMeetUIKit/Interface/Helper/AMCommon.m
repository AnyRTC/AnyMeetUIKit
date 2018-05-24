//
//  AMCommon.m
//  AnyMeetUIKit
//
//  Created by derek on 2018/4/28.
//  Copyright © 2018年 derek. All rights reserved.
//

#import "AMCommon.h"

@implementation AMCommon

+(UIColor *)getColor:(NSString *)color {
    
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip "0X" or "#" if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

//均分
+(void)makeEqualWidthViews:(NSArray *)views inView:(UIView *)containerView LRpadding:(CGFloat)LRpadding viewPadding :(CGFloat)viewPadding
{
    UIView *lastView;
    for (UIView *view in views) {
        view.frame = CGRectZero;
        [containerView addSubview:view];
        if (lastView) {
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(containerView).offset(5);
                make.bottom.equalTo(containerView).offset(-5);
                make.left.equalTo(lastView.mas_right).offset(viewPadding);
                make.width.equalTo(lastView);
            }];
        } else {
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(containerView).offset(LRpadding);
                make.top.equalTo(containerView).offset(5);
                make.bottom.equalTo(containerView).offset(-5);
            }];
        }
        lastView=view;
    }
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-LRpadding);
    }];
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

/**
 *  关闭所有键盘
 */
+ (void)hideKeyBoard{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
}

+(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}

//将字典转换为JSON对象
+ (NSString *)fromDicToJSONStr:(NSDictionary *)dic{
    NSString *JSONStr;
    //判断对象是否可以构造为JSON对象
    if ([NSJSONSerialization isValidJSONObject:dic]){
        NSError *error;
        //转换为NSData对象
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        //转换为字符串，即为JSON对象
        JSONStr=[[NSMutableString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return JSONStr;
}

+ (id)fromJsonStr:(NSString*)jsonStrong {
    if ([jsonStrong isKindOfClass:[NSDictionary class]]) {
        return jsonStrong;
    }
    NSData* data = [jsonStrong dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

//随机字符串
+ (NSString*)randomString:(int)len {
    char* charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    char* temp = malloc(len + 1);
    for (int i = 0; i < len; i++) {
        int randomPoz = (int) floor(arc4random() % strlen(charSet));
        temp[i] = charSet[randomPoz];
    }
    temp[len] = '\0';
    NSMutableString* randomString = [[NSMutableString alloc] initWithUTF8String:temp];
    free(temp);
    return randomString;
}

+ (NSString *)getTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSString* stringData = [formatter stringFromDate:[NSDate date]];
    return stringData;
}

//间距
+ (NSDictionary *)setTextLineSpaceWithString:(NSString*)str withFont:(UIFont*)font withLineSpace:(CGFloat)lineSpace withTextlengthSpace:(NSNumber *)textlengthSpace paragraphSpacing:(CGFloat)paragraphSpacing{
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    paraStyle.alignment = NSTextAlignmentLeft;
    
    paraStyle.lineSpacing = lineSpace; //设置行间距
    
    paraStyle.hyphenationFactor = 1.0;
    
    paraStyle.firstLineHeadIndent = 0.0;
    
    paraStyle.paragraphSpacingBefore = 0.0;
    
    paraStyle.headIndent = 0;
    
    paraStyle.tailIndent = 0;
    
    NSDictionary *dic = @{NSFontAttributeName:font,
                          
                          NSParagraphStyleAttributeName:paraStyle,
                          
                          NSKernAttributeName:textlengthSpace
                          
                          };
    return dic;
    
}
+ (NSString*)joinMeetingError:(int)nCode {
    
    switch (nCode) {
        case 1:
            return @"未知错误";
            break;
        case 2:
            return @"SDK调用异常";
            break;
        case 3:
            return @"SDK未初始化";
            break;
        case 4:
            return @"参数非法";
            break;
        case 5:
            return @"没有网络链接";
            break;
        case 6:
            return @"没有找到摄像头设备";
            break;
        case 7:
            return @"没有打开摄像头权限";
            break;
        case 8:
            return @"没有音频录音权限";
            break;
        case 9:
            return @" 浏览器不支持webrtc";
            break;
        case 100:
            return @"网络错误";
            break;
        case 101:
            return @"网络断开";
            break;
        case 102:
            return @"直播出错";
            break;
        case 103:
            return @"异常错误";
            break;
        case 201:
            return @"服务不支持的错误请求";
            break;
        case 202:
            return @"认证失败";
            break;
        case 203:
            return @"此开发者信息不存在";
            break;
        case 204:
            return @"服务器内部数据库错误";
            break;
        case 205:
            return @"账号欠费";
            break;
        case 206:
            return @"账号被锁定";
            break;
        case 207:
            return @"强制离开";
            break;
        case 208:
            return @"AnyRTC ID非法";
            break;
        case 209:
            return @"服务未开通";
            break;
        case 210:
            return @"Bundle ID不匹配";
            break;
        case 211:
            return @"订阅的PubID已过期";
            break;
        case 212:
            return @"没有RTC服务器";
            break;
        case 700:
            return @"会议未开始";
            break;
        case 701:
            return @"会议室已满";
            break;
        case 702:
            return @"会议类型不匹配";
            break;
        default:
            break;
    }
    return @"未知错误";
}
@end
