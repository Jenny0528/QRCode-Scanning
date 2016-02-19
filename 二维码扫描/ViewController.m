//
//  ViewController.m
//  二维码扫描
//
//  Created by Jenny on 16/2/18.
//  Copyright © 2016年 Jenny. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate> //用于处理采集信息的代理
@property (nonatomic, strong) AVCaptureSession *session;//输入输出的中间桥梁
@property (nonatomic, strong) AVCaptureDevice *device;//获取摄像设备
@property (nonatomic, strong) AVCaptureDeviceInput *input;//创建输入流
@property (nonatomic, strong) AVCaptureMetadataOutput *output;//创建输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, strong) UIView *scanRectView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"扫一扫";
    
    //获取摄像设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    //创建输出流
    self.output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化链接对象
    self.session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    //设置扫码支持的编码格式
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    
    
    //扫描框
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGSize scanSize = CGSizeMake(windowSize.width * 5 / 8, windowSize.width * 5 / 8);
    CGRect scanRect = CGRectMake((windowSize.width - scanSize.width) / 2, (windowSize.height - scanSize.height) / 2 - 100, scanSize.width, scanSize.height);
    scanRect = CGRectMake(scanRect.origin.y / windowSize.height, scanRect.origin.x / windowSize.width, scanRect.size.height / windowSize.height,scanRect.size.width / windowSize.width);
    
    self.output.rectOfInterest = scanRect;
    
    scanRect = CGRectMake((windowSize.width - scanSize.width) / 2, (windowSize.height - scanSize.height) / 2 - 100, scanSize.width, scanSize.height);
    
    self.scanRectView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xiangkuang"]];
    [self.view addSubview:self.scanRectView];
    self.scanRectView.frame = scanRect;
    self.scanRectView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.scanRectView.layer.borderWidth = 1;
    
   
    
    //
    UILabel *label = [UILabel new];
    label.text = @"将二维码/条码放入框内,即可自动扫描";
    label.frame = CGRectMake(0, self.scanRectView.frame.origin.y + self.scanRectView.frame.size.height + 10, self.view.frame.size.width, 30);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor grayColor];
    scanRect.origin.y = scanRect.origin.y + scanSize.height+5;
    scanRect.size.height = 10;
    [self.view addSubview:label];
   
    
    //开始捕获
    [self.session startRunning];
    
}
#pragma mark - 以上我们就可以看到UI效果
#pragma mark - 实现代理方法, 完成二维码扫描
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count == 0) {
        NSLog(@"%@", metadataObjects);
        return;
    }
    
    if (metadataObjects.count > 0) {
        //停止扫描
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        //扫描得到的文本
        NSLog(@"%@", metadataObject.stringValue);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
