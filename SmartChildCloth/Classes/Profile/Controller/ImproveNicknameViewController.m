//
//  ImproveNicknameViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/11.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "ImproveNicknameViewController.h"
#import "GenderViewController.h"


@interface ImproveNicknameViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIImageView *picImageView;
@property (nonatomic,strong) UITextField *nicknameField;
@property (nonatomic,strong) UIButton *nextBtn;

@end

@implementation ImproveNicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    if ([self.type isEqualToString:@"update"]) {
        self.title = @"编辑宝贝信息";
    }else{
        self.title = @"完善宝贝信息";
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
    
    [self initView];
}

- (void)initView
{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 25)];
    topView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:topView];
    UILabel *hitLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREENWIDTH-10, 25)];
    hitLabel.textColor = [UIColor whiteColor];
    hitLabel.font = [UIFont systemFontOfSize:14];
    hitLabel.text = @"您是管理员，请完善宝贝信息。";
    [topView addSubview:hitLabel];
    
    self.picImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        imageView.center = CGPointMake(self.view.centerX, hitLabel.centerY+60);
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 30.f;
        UIImage *image = [UIImage imageNamed:@"default_headpic"];
        imageView.image = image;
        imageView;
    });
    [self.view addSubview:self.picImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    self.picImageView.userInteractionEnabled = YES;
    [self.picImageView addGestureRecognizer:tap];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 40, 20)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.text = @"昵称";
    [view addSubview:label];
    
    // 昵称的边框
    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(10, CGRectGetMaxY(self.picImageView.frame)+40, SCREENWIDTH-20, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setMasksToBounds:YES];
    [signBtn1.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];
    
    self.nicknameField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.picImageView.frame)+40, SCREENWIDTH-20, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"请输入2-12位昵称";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeyNext;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField;
    });
    [self.view addSubview:self.nicknameField];
    self.nicknameField.leftViewMode = UITextFieldViewModeAlways;
    self.nicknameField.leftView = view;
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, CGRectGetMaxY(self.nicknameField.frame)+30, SCREENWIDTH-40, 45);
        button.backgroundColor = ButtonBgColor;
        if ([self.type isEqualToString:@"update"]) {
            [button setTitle:@"完成" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"下一步" forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.nextBtn];
    
    
    if ([self.type isEqualToString:@"update"]) {
        topView.hidden = YES;
        
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance]getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
        self.nicknameField.text = [[AppDefaultUtil sharedInstance] getNickName];
    }
}

#pragma mark - hide
- (void)keyboardHide:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (void)tapAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"照片", nil];
    [sheet showInView:self.view];
}

- (void)nextClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    // 2-12位 判断是否符合条件
    if (self.nicknameField.text.length < 2 || self.nicknameField.text.length > 12) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请输入符合条件的昵称" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else{
        
        if ([self.type isEqualToString:@"update"]) {
            
            NSString *url = @"child/updateChildInformation";
            NSString *token = [[AppDefaultUtil sharedInstance]getToken];
            JKEncrypt *encrypt = [[JKEncrypt alloc]init];
            token = [encrypt doDecEncryptStr:token];
            NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
            NSDictionary *parameters = @{@"token":token, @"childId":childId, @"name":self.nicknameField.text};
            
            NetWork *netWork = [[NetWork alloc]init];
            [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
                if (data) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if ([[dict objectForKey:@"code"]integerValue] == 0) {
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setBool:YES forKey:@"refresh_update"];
                        [defaults synchronize];
                        
                        [[AppDefaultUtil sharedInstance] setNickName:self.nicknameField.text];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }else{
                        [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                    }
                    
                }else{
                    if (error) {
                        
                    }
                }
            }];
            
            
        }else{
        
            GenderViewController *vc = [[GenderViewController alloc]init];
            vc.nickName = self.nicknameField.text;
            vc.gender = 0; // 初始化为男宝
            vc.picImage = self.picImageView.image;
            vc.type = @"add";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamera) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"没有摄像头" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            return ;
        }
        //从摄像头获取活动图片
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
        
        
    }else if (buttonIndex == 1) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self  presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
// 取消相册
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // UIImagePickerControllerOriginalImage
    UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if(picker.sourceType==UIImagePickerControllerSourceTypeCamera){
        //        UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
    }
    
    
    self.picImageView.image = img;
    if ([self.type isEqualToString:@"update"]) {
        [self uploadHeadImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 上传图像
- (void)uploadHeadImage
{
    NSString *url = @"http://123.57.164.156:8080/smart_child_cloth/child/uploadpicture";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
    NSDictionary *parameters = @{@"token":token, @"childId":childId};
    
    [self postPictureWithUrl:url parameters:parameters image:self.picImageView.image];
}

- (void)postPictureWithUrl:(NSString *)url parameters:(NSDictionary *)parameters image:(UIImage *)image
{
    DLog(@"parameters = %@,url=%@",url,parameters);
    
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
        [SVProgressHUD showWithStatus:@"正在上传图像"];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        DLog(@"dict = %@",dict);
        if ([[dict objectForKey:@"code"]integerValue] == 0) {
            
            //上传成功
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"refresh_update"];
            [defaults synchronize];
            
            NSDictionary *result = [dict objectForKey:@"jsonResult"];
            NSString *headUrl = [NSString stringWithFormat:@"%@",[result objectForKey:@"headUrl"]];
            [[AppDefaultUtil sharedInstance] setHeadImageUrl:headUrl];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }else {
            [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        //上传失败
        DLog(@"%@上传失败",error);
    }];
}

#pragma mark - UINavigationControllerDelegate

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
