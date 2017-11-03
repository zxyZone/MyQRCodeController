//
//  GSQRCodeCtl.h
//  GSQRCode
//
//  Created by Johnson on 17/3/22.
//  Copyright © 2017年 Johnson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSQRCodeController;
@protocol GSQRCodeCtlDelegate <NSObject>

@optional

- (void)gsQRCodeCtl:(GSQRCodeController *)codeCtl codeString:(NSString *)codeString;

@end

@interface GSQRCodeController : UIViewController

/** 扫描结果 */
@property (nonatomic, copy) void (^returnScanBarCodeValue)(NSString * barCodeString);

/**
 * 代理
 */
@property (nonatomic, weak) id <GSQRCodeCtlDelegate> delegate;

@end
