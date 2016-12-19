//
//  HomeViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "HomeViewController.h"
#import "TrackNoteViewController.h"
#import "TextImageButton.h"
#import "CustomAnnotationView.h"
#import "DropDownMenu.h"
#import "LocationModal.h"
#import "Baby.h"


#define kCalloutViewMargin          -8
#define SUPPORT_IOS9                1

@interface HomeViewController () <UIActionSheetDelegate,MAMapViewDelegate>
{
    NSMutableArray *babys;
}

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) UIButton *locationButton;

// navi
@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) TextImageButton *homeBtn;
@property (nonatomic,strong) DropDownMenu *menuView;
@property (nonatomic,strong) UIView *darkView;

//@property (nonatomic,strong) MAAnnotationView *userLocationAnnotationView;
@property (nonatomic,strong) MAPointAnnotation *pointAnnotaiton; //device
@property (nonatomic,strong) MAPointAnnotation *currentAnnotation; //phone
//@property (nonatomic,strong) LocationModal *modal;
@property (nonatomic,strong) CLLocation *currentLocation;
@property (nonatomic,strong) CLLocation *deviceLocation;

@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *place;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavigationBar];
    
    [self configMapView];
    
    [self configUI];
    
    [self configLocation];
    
    
 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    [self.homeBtn setTitle:[[AppDefaultUtil sharedInstance] getNickName] forState:UIControlStateNormal];
    
    [self request];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.pointAnnotaiton = nil;
    self.currentAnnotation = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
 
}

#pragma mark - config
- (void)configMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // 关闭指南针
    self.mapView.showsCompass= NO;
    // show traffic
    self.mapView.showTraffic = YES;
    self.mapView.delegate = self;

    [self.view addSubview:self.mapView];
    // 后台定位适用于记录轨迹或者出行类App司机端
    //注意：后台定位必须将info.plist的字段改成NSLocationAlwaysUsageDescription字段。
    
    /**
     *  定位 NSLocationWhenInUsageDescription
     */
//    self.mapView.showsUserLocation = YES; //YES 为打开定位，NO为关闭定位
    
    [self.mapView setZoomLevel:16.1 animated:NO];
    
    // 后台定位
//        self.mapView.pausesLocationUpdatesAutomatically = NO;
#if SUPPORT_IOS9
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
//        self.mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    }
#endif
    
}


- (void)configLocation
{
    self.locationManager = [[AMapLocationManager alloc]init];
    // kCLLocationAccuracyHundredMeters，一次还不错的定位，偏差在100米以内，耗时在2s左右
    // 高精度：kCLLocationAccuracyBest，精度很高的一次定位，偏差在10米以内，耗时在10s左右
    // 设置定位精确到米
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // 设置过滤器为无
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout = 2;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 2;
 
     //以下两个属性设置后,能保持程序持续定位
 
//    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    // iOS9以上
#if SUPPORT_IOS9
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
//        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
#endif
}


#pragma mark - request
- (void)request
{
    NSString *url = @"location/findLocation";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    if ([eqId isEqualToString:@"<null>"] || [eqId isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请先绑定设备" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    NSDictionary *parameter = @{@"token":token, @"eqId":eqId};
    if (self.netWork == nil) {
        self.netWork = [[NetWork alloc]init];
    }
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                NSDictionary *result = [dict objectForKey:@"jsonResult"];
                NSString *latitude = [NSString stringWithFormat:@"%@",[result objectForKey:@"latitude"]]; // 纬度
                NSString *longitude = [NSString stringWithFormat:@"%@",[result objectForKey:@"longitude"]]; // 经度
                NSString *time = [NSString stringWithFormat:@"%@",[result objectForKey:@"time"]];
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                [formatter setDateFormat:@"yyyy-MM-dd HH:MM:ss"];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[time integerValue]/1000];
                self.time = [formatter stringFromDate:confromTimesp];
//                NSString *locationId = [NSString stringWithFormat:@"%@",[result objectForKey:@"locationId"]];
                NSString *type = [NSString stringWithFormat:@"%@",[result objectForKey:@"type"]];
                NSString *distance = [NSString stringWithFormat:@"%@",[result objectForKey:@"distance"]];
                self.desc = [NSString stringWithFormat:@"本次采用%@定位(精确度%d米)",[type integerValue]==1?@"GPS":@"基站和WIFI", [distance intValue]];
                
                // 百度坐标转谷歌坐标
//                CLLocationCoordinate2D coordinate = [MHTransformCorrdinate getGoogleLocFromBaiduLocLat:[latitude doubleValue] lng:[longitude doubleValue]];
                // GPS坐标转谷歌坐标
//                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
//                coordinate = [MHTransformCorrdinate GPSLocToGoogleLoc:coordinate];
                 CLLocation *location = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                
                
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    
                    if (placemarks.count > 0){
                        
                        CLPlacemark *placemark = placemarks[0];
                        //获取城市
                        NSString *city = placemark.locality;
                        if (!city) {
                            //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                            city = placemark.administrativeArea;
                        }
                        
                        self.place = placemark.name;
                        NSDictionary *address = placemark.addressDictionary;
                        NSString *City = [address objectForKey:@"City"];
                        NSString *Name = [address objectForKey:@"Name"];
                        NSString *State = [address objectForKey:@"State"];
                        NSString *Street = [address objectForKey:@"Street"];
                        NSString *SubLocality = [address objectForKey:@"SubLocality"];
                        NSString *Thoroughfare = [address objectForKey:@"Thoroughfare"];
                        self.place = [NSString stringWithFormat:@"%@%@%@%@",State,city,SubLocality,Street];
                        self.deviceLocation = location;
                        
                        if (self.pointAnnotaiton == nil)
                        {
                            self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
                            [self.pointAnnotaiton setCoordinate:self.deviceLocation.coordinate];
                            self.pointAnnotaiton.title = @"device";
                            [self.mapView addAnnotation:self.pointAnnotaiton];
                    
                            
                        }
                        
                        // 设置地图中心点
                        [self.mapView setCenterCoordinate:self.deviceLocation.coordinate];
                        // 设置地图使所有的annotation都可见
                        [self.mapView showAnnotations:self.mapView.annotations animated:NO];
                        
                    }else if (error == nil && [placemarks count] == 0)
                    {
                        DLog(@"No results were returned.");
                    }
                    else if (error != nil)
                    {
                        DLog(@"An error occurred = %@", error);
                    }
                    
                }];
                
                
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}
 
#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPointAnnotation *pointAnno = (MAPointAnnotation *)annotation;
        if ([pointAnno.title isEqualToString:@"device"]) {
            
            static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
            CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
                
            }
            annotationView.canShowCallout               = NO; // 设置为NO，用以调用自定义的calloutView
            // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -18);
            
            annotationView.image = [UIImage imageNamed:@"locate"];
            annotationView.time = self.time;
            annotationView.place = self.place;
            annotationView.desc = self.desc;
            
            return annotationView;
        }
        else {
        
            static NSString *pointReuseIndetifier = @"ReuseIndetifier";
            MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            }
            
            annotationView.canShowCallout               = YES;
            annotationView.animatesDrop                 = YES;
//            annotationView.draggable                    = YES;
//            annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.pinColor                     = MAPinAnnotationColorRed;
            
            return annotationView;

        
        }
    }
    
    return nil;
}


- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    // Adjust the map center in order to show the callout view completely.
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        UIView  *calloutView = (UIView *)cusView.calloutView;
        CGRect frame = [cusView convertRect:calloutView.frame toView:self.mapView];
    
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            // Calculate the offset to make the callout view show up.
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];
            
            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
        
    }
}

// 地图区域即将改变
/*
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    DLog(@"地图区域即将改变=========");
}
*/

/*
// 地图移动结束
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    DLog(@"地图移动结束============");
}

// 地图缩放结束
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    DLog(@"地图缩放结束==============%f",mapView.zoomLevel);
//    [self.mapView setZoomLevel:mapView.zoomLevel animated:NO];
}
*/
 
// 定位图层
/*
// 当mapView新添加annotation views时调用此接口
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
        pre.image = [UIImage imageNamed:@"locate"];
        pre.lineWidth = 3;
//        pre.lineDashPattern = @[@6, @3];
        
        [self.mapView updateUserLocationRepresentation:pre];
        
        view.calloutOffset = CGPointMake(0, 0);
        view.canShowCallout = NO;
        self.userLocationAnnotationView = view;
    } 
}
*/

#pragma mark -  Utility

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

#pragma mark - UI
- (void)initNavigationBar
{
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController)];
    UIBarButtonItem *GPSItem = [[UIBarButtonItem alloc]initWithTitle:@"GPS" style:UIBarButtonItemStylePlain target:self action:@selector(GPS)];
    self.navigationItem.leftBarButtonItems = @[leftItem,GPSItem];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home_nav_ic-trajectory"] style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]initWithTitle:@"device" style:UIBarButtonItemStylePlain target:self action:@selector(refreshDeviceLocation)];

    self.navigationItem.rightBarButtonItems = @[rightItem,refreshItem];
    
    self.titleView = ({
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        view;
    });
    
    self.homeBtn = [[TextImageButton alloc]init];
    [self.homeBtn setTitle:[[AppDefaultUtil sharedInstance] getNickName] forState:UIControlStateNormal];
    [self.homeBtn setImage:[UIImage imageNamed:@"home_nav-ic_down"] forState:UIControlStateNormal];
    [self.homeBtn setImage:[UIImage imageNamed:@"home_nav-ic_down"] forState:UIControlStateHighlighted];
    [self.homeBtn addTarget:self action:@selector(dropDownMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.homeBtn];
    
    CGSize size = [[[AppDefaultUtil sharedInstance] getNickName] boundingRectWithSize:CGSizeMake(100, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]} context:nil].size;
    
    [self.homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size.width+10, 44));
        make.centerX.mas_equalTo(@5);
        make.centerY.mas_equalTo(@0);
    }];
    
    self.headImageView = ({
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 15.f;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
        imageView;
    });
    [self.titleView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(@0);
        make.right.mas_equalTo(self.homeBtn.mas_left).offset(-5);
    }];
    
    self.navigationItem.titleView = self.titleView;
}

- (void)configUI
{
    UIView *zoomPannelView = [self makeZoomPannelView];
    zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10,
                                        self.view.bounds.size.height/2 -  CGRectGetMidY(zoomPannelView.bounds) + 40);
    
    zoomPannelView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:zoomPannelView];
    
    self.locationButton = [self makeLocationButtonView];
    self.locationButton.center = CGPointMake(self.view.bounds.size.width - CGRectGetMidX(self.locationButton.bounds) - 10,
                                        self.view.bounds.size.height -  CGRectGetMidY(self.locationButton.bounds) - 100 - 20);
    [self.view addSubview:self.locationButton];
    self.locationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
}

// 定位按钮
- (UIButton *)makeLocationButtonView {
    UIButton *ret = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    ret.backgroundColor = [UIColor whiteColor];
    ret.layer.cornerRadius = 4;
    
    [ret setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
    [ret addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    
    return ret;
}

// 地图缩放的UI
- (UIView *)makeZoomPannelView
{
    UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 80)];
    
    UIButton *incBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [incBtn setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
    incBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [incBtn addTarget:self action:@selector(zoomPlusAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *decBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 40, 40)];
    [decBtn setImage:[UIImage imageNamed:@"decrease"] forState:UIControlStateNormal];
    decBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [decBtn addTarget:self action:@selector(zoomMinusAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [ret addSubview:incBtn];
    [ret addSubview:decBtn];
    
    return ret;
}

- (void)dropDownMenu:(UIButton *)button{
    
    NSMutableArray *nickNames = [NSMutableArray array];
    NSMutableArray *headUrls = [NSMutableArray array];
    NSMutableArray *childIds = [NSMutableArray array];
    // 取出
    NSArray *array = [[AppDefaultUtil sharedInstance] getChilds];
    babys = [NSMutableArray arrayWithCapacity:array.count];
    for (NSData *data in array) {
        Baby *b = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        DLog(@"baby:eqId=%@ name=%@ headUrl=%@ childId=%@",b.eqId,b.name,b.headUrl,b.childId);
        [babys addObject:b];
        if (![[[AppDefaultUtil sharedInstance] getNickName] isEqualToString:b.name]) {
            [nickNames addObject:b.name];
            [headUrls addObject:b.headUrl];
            [childIds addObject:b.childId];
        }
        
    }
    if (nickNames.count <= 0) {
        return;
    }
    
    if (!_darkView) {
        _darkView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _darkView.backgroundColor = [UIColor colorWithWhite:.7 alpha:.3];
        _darkView.userInteractionEnabled = YES;
        [self.view addSubview:_darkView];
    }
    self.darkView.hidden = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture)];
    singleTap.numberOfTapsRequired = 1;
    [self.darkView addGestureRecognizer:singleTap];
    
    if (!_menuView) {
        self.menuView = [[DropDownMenu alloc] initWithFrame:CGRectMake(0, 0, 150, 200)];
        self.menuView.center = CGPointMake(self.view.centerX, self.menuView.centerY);
        self.menuView.dataSource = nickNames;
        ;
        [self.view addSubview:self.menuView];
    }
    self.menuView.hidden = NO;
    
    __weak typeof(self)weakSelf = self;
    [self.menuView setFinishBlock:^(NSString *title){
        
        NSInteger index = [nickNames indexOfObject:title];
        
        [weakSelf.homeBtn setTitle:title forState:UIControlStateNormal];
        [weakSelf.homeBtn setTitle:title forState:UIControlStateHighlighted];
        [weakSelf.headImageView sd_setImageWithURL:[NSURL URLWithString:headUrls[index]]];
        [weakSelf handleSingleTapGesture];
        
        [[AppDefaultUtil sharedInstance] setNickName:title];
        [[AppDefaultUtil sharedInstance] setHeadImageUrl:headUrls[index]];
        [[AppDefaultUtil sharedInstance] setChildId:childIds[index]];
    }];
    
}

#pragma mark - 跳转地图APP

- (NSArray *)checkHasOwnApp{
    NSArray *mapSchemeArr =@[@"iosamap://navi"];
    
    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果地图",nil];
    
    for (int i =0; i < [mapSchemeArr count]; i++) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[mapSchemeArr objectAtIndex:i]]]]) {
            if (i ==0) {
                [appListArr addObject:@"高德地图"];
            }else {
                
            }
        }
    }
    
    return appListArr;
}

- (void)fromCurrentLocation:(CLLocation *)currentLocation ToTargetLocation:(CLLocation *)targetLocation ToName:(NSString *)name{
    
    
    NSArray *appListArr = [self checkHasOwnApp];
    NSString *sheetTitle = [NSString stringWithFormat:@"导航到 %@",name];
    UIActionSheet *sheet;
    if ([appListArr count] == 1) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],nil];
    }else if ([appListArr count] == 2) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self  cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],nil];
    }
    sheet.actionSheetStyle =UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (!self.place) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"设备位置有误"];
        return;
    }
    
    CLLocationCoordinate2D coords2 = self.deviceLocation.coordinate;
    MKMapItem *fromLoc = [MKMapItem mapItemForCurrentLocation];
    
    MKMapItem *toLoc = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coords2 addressDictionary:nil]];
    toLoc.name = self.place;
   
    if (buttonIndex ==0) {
        
        NSArray *items = [NSArray arrayWithObjects:fromLoc, toLoc,nil];
        NSDictionary *options =@{
                                 MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                 MKLaunchOptionsMapTypeKey:
                                     [NSNumber numberWithInteger:MKMapTypeStandard],
                                 MKLaunchOptionsShowsTrafficKey:@YES
                                 };
        
        //打开苹果自身地图应用
        [MKMapItem openMapsWithItems:items launchOptions:options];
        
    }
    if ([btnTitle isEqualToString:@"高德地图"]){
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,@"我的位置",self.deviceLocation.coordinate.latitude,self.deviceLocation.coordinate.longitude,self.place]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *r = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:r];
        //        NSLog(@"%@",_lastAddress);
        
    }
    else if (actionSheet.cancelButtonIndex==buttonIndex){
        //解决点击取消后重复出现选择框的问题
        [actionSheet removeFromSuperview];
        
    }
    
    
    
}

#pragma mark - Action Handlers
- (void)zoomPlusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom + 1) animated:YES];
}

- (void)zoomMinusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom - 1) animated:YES];
}

- (void)locationAction {
    
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
       
        if (error)
        {
            DLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        DLog(@"location:%@", location);
        self.currentLocation = location;
        
        if (regeocode)
        {
            DLog(@"reGeocode:%@", regeocode);
            
            if (self.currentAnnotation == nil)
            {
                self.currentAnnotation = [[MAPointAnnotation alloc] init];
                [self.currentAnnotation setCoordinate:location.coordinate];
                self.currentAnnotation.title = regeocode.formattedAddress;
                
                [self.mapView addAnnotation:self.currentAnnotation];
            }
            
            // 设置地图使所有的annotation都可见
            [self.mapView showAnnotations:self.mapView.annotations animated:NO];
        }
        
    }];
    
    
}

- (void)handleSingleTapGesture{
    //    [self.darkView removeFromSuperview];
    //    [self.menuView removeFromSuperview];
    self.darkView.hidden = YES;
    self.menuView.hidden = YES;
}

#pragma mark - navigation Handle
- (void)presentLeftMenuViewController
{
     [self handleSingleTapGesture];
    
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)GPS
{
    DLog(@"导航.....");

    [self fromCurrentLocation:self.currentLocation ToTargetLocation:self.deviceLocation ToName:self.place];
    
}

- (void)refreshDeviceLocation
{
    [self request];
}

- (void)rightClick
{
    [self handleSingleTapGesture];
    
    TrackNoteViewController *vc = [[TrackNoteViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)dealloc
{
    DLog(@"%@被dealloc",NSStringFromClass([self class]));
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
