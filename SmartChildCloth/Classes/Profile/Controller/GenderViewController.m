//
//  GenderViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "GenderViewController.h"
#import "BirthdayViewController.h"

@interface GenderViewController ()

@property (nonatomic,strong) UIImageView *boyImageView;
@property (nonatomic,strong) UIImageView *girlImageView;
@property (nonatomic,strong) UILabel *boyLabel;
@property (nonatomic,strong) UILabel *girlLabl;

@property (nonatomic,strong) UIButton *nextBtn;



@end

@implementation GenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"性别";
    
    [self initView];
}

- (void)initView
{
    self.boyImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 60, 60)];
        imageView.center = CGPointMake(self.view.centerX, imageView.centerY);
        UIImage *image = [UIImage imageNamed:@"boy"];
//        imageView.image = [UIImage circleImage:image borderColor:[UIColor clearColor] borderWidth:0.f];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView;
    });
    [self.view addSubview:self.boyImageView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    self.boyImageView.userInteractionEnabled = YES;
    [self.boyImageView addGestureRecognizer:tap1];
    
    self.girlImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.boyImageView.frame)+60, 60, 60)];
        imageView.center = CGPointMake(self.view.centerX, imageView.centerY);
        UIImage *image = [UIImage imageNamed:@"gril"];
//        imageView.image = [UIImage circleImage:image borderColor:[UIColor clearColor] borderWidth:0.f];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView;
    });
    [self.view addSubview:self.girlImageView];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    self.girlImageView.userInteractionEnabled = YES;
    [self.girlImageView addGestureRecognizer:tap2];
    
    self.boyLabel = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.boyImageView.frame)+10, 60, 20)];
        label.center = CGPointMake(self.boyImageView.centerX, label.centerY);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:15];
        label.text = @"男宝";
        label;
    });
    [self.view addSubview:self.boyLabel];
    
    self.girlLabl = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.girlImageView.frame)+10, 60, 20)];
        label.center = CGPointMake(self.girlImageView.centerX, label.centerY);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:15];
        label.text = @"女宝";
        label;
    });
    [self.view addSubview:self.girlLabl];
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, SCREENHEIGHT-10-45-64, SCREENWIDTH-40, 45);
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
    
    if (self.gender == 0) {
        // 初始化选中为男宝
        self.girlImageView.backgroundColor = [UIColor clearColor];
        self.boyImageView.backgroundColor = [UIColor lightGrayColor];
    }else{
        self.boyImageView.backgroundColor = [UIColor clearColor];
        self.girlImageView.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark -
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    UIImageView *imgView = (UIImageView *)tap.view;
    if ([imgView isEqual:self.boyImageView]) {
        self.gender = 0;
        self.girlImageView.backgroundColor = [UIColor clearColor];
        self.boyImageView.backgroundColor = [UIColor lightGrayColor];
    }else {
        self.gender = 1;
        self.boyImageView.backgroundColor = [UIColor clearColor];
        self.girlImageView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)nextClick:(UIButton *)sender
{
    if ([self.type isEqualToString:@"update"]) {
    
        NSString *url = @"child/updateChildInformation";
        NSString *token = [[AppDefaultUtil sharedInstance]getToken];
        JKEncrypt *encrypt = [[JKEncrypt alloc]init];
        token = [encrypt doDecEncryptStr:token];
        NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
        NSDictionary *parameters = @{@"token":token, @"childId":childId, @"sex":[NSString stringWithFormat:@"%zd",self.gender]};
        
//        [self postPictureWithUrl:url parameters:parameters image:self.picImage];
        
        
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
        
        
    }else{
    
        BirthdayViewController *vc = [[BirthdayViewController alloc]init];
        vc.nickName = self.nickName;
        vc.gender = self.gender;
        vc.birthday = @"";
        vc.picImage = self.picImage;
        vc.type = @"add";
        [self.navigationController pushViewController:vc animated:YES];
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
        DLog(@"dict = %@",dict);
        if ([[dict objectForKey:@"code"]integerValue] == 0) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"refresh_update"];
            [defaults synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        //上传失败
        DLog(@"%@上传失败",error);
    }];
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
