//
//  WeightViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "WeightViewController.h"
#import "ScanBindDeviceViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DLFRulerView.h"

/** rulerMultiple参数为控制缩放比 */
static CGFloat const rulerMultiple=10;

/** 最大刻度值 */
static CGFloat const maxValue = 150;

/** 最小刻度值 */
static CGFloat const minValue = 10;

///** 默认刻度值 */
//static CGFloat const defatuleValue = 30;

@interface WeightViewController () <DLFRulerViewDelegate,QRCodeScannerViewControllerDelegate>

@property (nonatomic,strong) UIImageView *genderImageView;
@property (nonatomic,strong) UILabel *weightLabel;
@property (nonatomic,strong) UIButton *completeBtn;

@property (nonatomic,strong) DLFRulerView *ruleView;
@property (nonatomic,strong) NetWork *netWork;

@end

@implementation WeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"体重";
//    self.weight = [NSString stringWithFormat:@"%.f",defatuleValue];
    [self initView];
}

- (void)initView
{
    self.genderImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 60, 60)];
        imageView.center = CGPointMake(self.view.centerX, imageView.centerY);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (self.gender == 0) {
            imageView.image = [UIImage imageNamed:@"boy"];
        }else{
            imageView.image = [UIImage imageNamed:@"gril"];
        }
//        UIImage *image = [UIImage imageNamed:@"cont_ic_baby"];
//        imageView.image = [UIImage circleImage:image borderColor:[UIColor clearColor] borderWidth:0.f];
        imageView;
    });
    [self.view addSubview:self.genderImageView];
    
    self.weightLabel = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.genderImageView.frame)+10, SCREENWIDTH, 40)];
        label.center = CGPointMake(self.view.centerX, label.centerY);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:25];
        label.text = [NSString stringWithFormat:@"%@KG",self.weight];
        label;
    });
    [self.view addSubview:self.weightLabel];
    
    self.completeBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, SCREENHEIGHT-10-45-64, SCREENWIDTH-40, 45);
        button.backgroundColor = ButtonBgColor;
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.completeBtn];
    
    self.ruleView = ({
        DLFRulerView *rulerView = [[DLFRulerView alloc]initWithmaxValue:maxValue minValue:minValue rulerViewShowType:rulerViewshowHorizontalType andRulerMultiple:rulerMultiple];
        rulerView.frame = CGRectMake(20, CGRectGetMaxY(self.weightLabel.frame)+20, SCREENWIDTH-40, 90);
        rulerView.defaultValue = [self.weight floatValue];
        rulerView.clipsToBounds = YES;
        rulerView.layer.masksToBounds = YES;
        rulerView.layer.cornerRadius = 2.f;
        rulerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        rulerView.layer.borderWidth = 1.f;
        rulerView.delegate = self;
        rulerView.backgroundColor = [UIColor whiteColor];
        rulerView;
    });
    [self.view addSubview:self.ruleView];
    
    
}

#pragma mark - DLFRulerViewDelegate
- (void)getRulerValue:(CGFloat)rulerValue
{
    self.weightLabel.text = [NSString stringWithFormat:@"%.fKG",rulerValue];
    self.weight = [NSString stringWithFormat:@"%.f",rulerValue];
}

#pragma mark -
-(BOOL)canUseCamera {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        DLog(@"相机权限受限");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

-(BOOL)validateCamera {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (void)showQRViewController
{
    ScanBindDeviceViewController *vc = [[ScanBindDeviceViewController alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)completeClick:(UIButton *)sender
{
    /*
    LeftMenuViewController *leftMenuViewController = [[LeftMenuViewController alloc] init];
    self.sideMenuViewController = [[RESideMenu alloc]initWithContentViewController:[[MainViewController alloc] init] leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
    self.sideMenuViewController.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.sideMenuViewController.delegate = self;
    // 禁止手势侧滑
    self.sideMenuViewController.panGestureEnabled = NO;
    self.sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    self.sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    self.sideMenuViewController.contentViewShadowOpacity = 0.8;
    self.sideMenuViewController.contentViewShadowRadius = 12;
    self.sideMenuViewController.contentViewShadowEnabled = YES;
    
    [self presentViewController:self.sideMenuViewController animated:YES completion:^{}];
     */
    if ([self.type isEqualToString:@"update"]) {
        
        NSString *url = @"child/updateChildInformation";
        NSString *token = [[AppDefaultUtil sharedInstance]getToken];
        JKEncrypt *encrypt = [[JKEncrypt alloc]init];
        token = [encrypt doDecEncryptStr:token];
        NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
        NSDictionary *parameters = @{@"token":token, @"childId":childId, @"km":self.weight};
        
        NetWork *netWork = [[NetWork alloc]init];
        [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dict objectForKey:@"code"]integerValue] == 0) {
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:@"refresh_update"];
                    [defaults synchronize];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                }
                
            }else{
                if (error) {
                    
                }
            }
        }];
        
    }
    else {
        NSString *url = @"http://123.57.164.156:8080/smart_child_cloth/child/saveChildInformation";
        NSString *token = [[AppDefaultUtil sharedInstance]getToken];
        JKEncrypt *encrypt = [[JKEncrypt alloc]init];
        token = [encrypt doDecEncryptStr:token];
        
        NSDictionary *parameter = @{@"token":token, @"name":self.nickName, @"sex":[NSString stringWithFormat:@"%zd",self.gender], @"birthday":self.birthday, @"high":self.height, @"km":self.weight};
        
        
        [self postPictureWithUrl:url parameters:parameter image:self.picImage];
    }
}

- (void)postPictureWithUrl:(NSString *)url parameters:(NSDictionary *)parameters image:(UIImage *)image
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"text/plain",
                                                         nil];
       [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *imageData =UIImageJPEGRepresentation(image,0.5);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:@"picture"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
        DLog(@"%@",uploadProgress);
        [SVProgressHUD showWithStatus:@"正在保存"];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        if ([[dict objectForKey:@"code"]integerValue] == 0) {
        //上传成功
            NSDictionary *acc = [dict objectForKey:@"jsonResult"];
            DLog(@"acc = %@",acc);
            [self saveAccount:acc];
            [self bindDevice];
            
        }else {
            [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        //上传失败
        DLog(@"%@上传失败",error);
    }];
}

- (void)saveAccount:(NSDictionary *)account
{
    NSString *childId = [NSString stringWithFormat:@"%@",[account objectForKey:@"childid"]];
    NSString *headUrl = [NSString stringWithFormat:@"%@",[account objectForKey:@"headUrl"]];
    
    [[AppDefaultUtil sharedInstance] setChildId:childId];
    [[AppDefaultUtil sharedInstance] setHeadImageUrl:headUrl];
    [[AppDefaultUtil sharedInstance] setNickName:self.nickName];
}

- (void)bindDevice
{
    if ([self validateCamera] && [self canUseCamera]) {
        
        [self showQRViewController];
        
    }
    else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有摄像头或摄像头不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - QRCodeScannerViewControllerDelegate
- (void)didFinshedScanning:(NSString *)result{
    DLog(@"扫描到的结果=%@",result);
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
