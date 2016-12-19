//
//  ScanBindDeviceViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "ScanBindDeviceViewController.h"
#import "HandBindDeviceViewController.h"
#import "RootViewController.h"


@interface ScanBindDeviceViewController () <QRCodeScanneDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIButton *bindBtn;
@property (nonatomic, copy, readwrite) NSString *urlString;

@end

@implementation ScanBindDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.title = @"绑定设备";
    
    QRCScanner *scanner = [[QRCScanner alloc]initQRCScannerWithView:self.view];
    scanner.scanningLieColor = KColor;
    scanner.cornerLineColor =  [UIColor blueColor];
    scanner.delegate = self;
    [self.view addSubview:scanner];
    
    self.bindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bindBtn.frame = CGRectMake((SCREENWIDTH - 160)/2, SCREENHEIGHT - 150, 160,  45);
    self.bindBtn.backgroundColor = ButtonBgColor;
    [self.bindBtn setTitle:@"手动输入绑定" forState:UIControlStateNormal];
    self.bindBtn.layer.masksToBounds = YES;
    self.bindBtn.layer.cornerRadius = 2.f;
    [self.bindBtn addTarget:self action:@selector(handBindClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bindBtn];
    
    //从相册选取二维码
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(readerImage)];
}

#pragma mark - 扫描二维码成功后结果的代理方法
- (void)didFinshedScanningQRCode:(NSString *)result{
    
    if ([self.delegate respondsToSelector:@selector(didFinshedScanning:)]) {
        [self.delegate didFinshedScanning:result];
        
        [self bindDevice:result];
    }
    else{
        NSLog(@"没有收到扫描结果，看看是不是没有实现协议！");
    }
//    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 从相册获取二维码图片
- (void)readerImage{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *result = [QRCScanner scQRReaderForImage:srcImage];
    
    if ([self.delegate respondsToSelector:@selector(didFinshedScanning:)]) {
        [self.delegate didFinshedScanning:result];
    }
    else{
        NSLog(@"没有收到扫描结果，看看是不是没有实现协议！");
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 扫描绑定设备
- (void)bindDevice:(NSString *)result
{
    NSString *url = @"eq/bingEq";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
    NSDictionary *parameter = @{@"token":token, @"model":result, @"childId":childId};
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                NSDictionary *acc = [dict objectForKey:@"jsonResult"];
                [self saveAccount:acc];
                
                RootViewController *vc = [[RootViewController alloc]initWithContentViewController:[[MainViewController alloc]init] leftMenuViewController:[[LeftMenuViewController alloc]init] rightMenuViewController:nil];
                [self presentViewController:vc animated:YES completion:^{}];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

- (void)saveAccount:(NSDictionary *)account
{
    NSString *eqId = [NSString stringWithFormat:@"%@",[account objectForKey:@"eqId"]];
    [[AppDefaultUtil sharedInstance] setEqId:eqId];
}

#pragma mark - 跳转到手动绑定
- (void)handBindClick:(UIButton *)sender
{
    HandBindDeviceViewController *vc = [[HandBindDeviceViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
