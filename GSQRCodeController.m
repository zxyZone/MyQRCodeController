//
//  GSQRCodeCtl.m
//  GSQRCode
//
//  Created by Johnson on 17/3/22.
//  Copyright © 2017年 Johnson. All rights reserved.
//

#import "GSQRCodeController.h"

#import <AVFoundation/AVFoundation.h>

#import "GSQRCodeView.h"

@interface GSQRCodeController ()<AVCaptureMetadataOutputObjectsDelegate>

/** 输入输出的中间桥梁 */
@property (nonatomic, strong) AVCaptureSession *session;

/** 遮罩层 */
@property (nonatomic, strong) GSQRCodeView *maskView;


@end

@implementation GSQRCodeController



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.maskView removeAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self capture];
    [self configView];
}

/**
 *  添加遮罩层
 */
- (void)configView{
    self.maskView = [[GSQRCodeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.maskView];
    
}

/**
 *  扫描初始化
 */
- (void)capture{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    

    if (input) {
        [self.session addInput:input];
    }
    if (output) {
        [self.session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [arr addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [arr addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [arr addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [arr addObject:AVMetadataObjectTypeCode128Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeDataMatrixCode]) {
            [arr addObject:AVMetadataObjectTypeDataMatrixCode];
        }
        output.metadataObjectTypes = arr;
    }

    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.frame = self.view.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.backgroundColor = [UIColor yellowColor].CGColor;
    [self.view.layer addSublayer:layer];
    
    //开始捕获
    [self.session startRunning];
    
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
        if (metadataObjects.count > 0) {
            
            [self.session stopRunning];
            
            AVMetadataMachineReadableCodeObject *metadata = metadataObjects.firstObject;
            NSString  *result = nil;
            result = metadata.stringValue;
            if (_delegate && [_delegate respondsToSelector:@selector(gsQRCodeCtl:codeString:)]) {
                    [_delegate gsQRCodeCtl:self codeString:result];
                }

            !self.returnScanBarCodeValue ?: self.returnScanBarCodeValue(result);
            
        }
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    
}

#pragma - setter/getter

- (AVCaptureSession *)session{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc]init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _session;
}


@end
