
//  AreaAddressViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "AreaAddressViewController.h"
#import "CustomAnnotationView.h"
#import "POIAnnotation.h"

#define kCalloutViewMargin          -8
#define MinArea 300
#define MaxArea 1000

@interface AreaAddressViewController () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSString *city;
    CLLocationCoordinate2D selectCoordinate;
}

@property (nonatomic,strong) UITextField *addressField;
@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UILabel *rightLabel;
@property (nonatomic,strong) UISlider *slider;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *tips;
@property (nonatomic,strong) NSMutableArray *poiAnnotations;

@property (nonatomic,assign) NSInteger safeArea;
@property (nonatomic,strong) MAPointAnnotation *pointAnnotaiton; //device
@property (nonatomic,strong) MAPointAnnotation *poiAnnotation; // poi
@property (nonatomic,strong) NetWork *netWork;

@property (nonatomic,strong) CLLocation *deviceLocation;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *place;

@end

@implementation AreaAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.titleString;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeClick)];
    
    self.safeArea = 600;
    self.tips = [NSMutableArray array];
    
    [self initView];
    
    
    if (self.netWork == nil){
        self.netWork = [[NetWork alloc]init];
    }
    
    /**
     *  首先初始化围栏
     */
//    MACircle *circle = [MACircle circleWithCenterCoordinate:selectCoordinate radius:self.safeArea];
//    [self.mapView addOverlay:circle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configMapView];
    [self configSearch];
    
//    [self.locationManager startUpdatingLocation];
//    self.locationManager.delegate = self;
    
    [self request];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    [self.locationManager stopUpdatingLocation];
    
    self.pointAnnotaiton = nil;
    [self.mapView removeAnnotation:self.pointAnnotaiton];
    
}

- (void)configMapView
{
    // 后台定位适用于记录轨迹或者出行类App司机端
    //注意：后台定位必须将info.plist的字段改成NSLocationAlwaysUsageDescription字段。
    
    /**
     *  定位 NSLocationWhenInUsageDescription
     */
//    self.mapView.showsUserLocation = YES; //YES 为打开定位，NO为关闭定位
//    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    
    
    // 后台定位
    //        self.mapView.pausesLocationUpdatesAutomatically = NO;
#if SUPPORT_IOS9
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
//        self.mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    }
#endif
    
    
    // 加入annotation旋转动画后，暂未考虑地图旋转的情况。
    self.mapView.rotateCameraEnabled = NO;
    self.mapView.rotateEnabled = NO;
}

- (void)configSearch
{
    self.search.delegate = self;
}

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
                
                NSString *type = [NSString stringWithFormat:@"%@",[result objectForKey:@"type"]];
                NSString *distance = [NSString stringWithFormat:@"%@",[result objectForKey:@"distance"]];
                self.desc = [NSString stringWithFormat:@"本次采用%@定位（精确度%d米）",[type integerValue]==1?@"GPS":@"基站和WIFI", [distance intValue]];
                
                CLLocation *location = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                self.deviceLocation = location;
                
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    
                    if (placemarks.count > 0){
                        
                        CLPlacemark *placemark = placemarks[0];
                        //获取城市
                        NSString *locality = placemark.locality;
                        if (!locality) {
                            //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                            locality = placemark.administrativeArea;
                        }
                        city = [locality substringWithRange:NSMakeRange(0, locality.length-1)];
                        
                        self.place = placemark.name;
                        
                        if (self.pointAnnotaiton == nil)
                        {
                            self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
                            [self.pointAnnotaiton setCoordinate:location.coordinate];
                            self.pointAnnotaiton.title = self.place;
                            [self.mapView addAnnotation:self.pointAnnotaiton];
                        }
                        
                        selectCoordinate = self.pointAnnotaiton.coordinate;
                        
                    }else if (error == nil && [placemarks count] == 0)
                    {
                        DLog(@"No results were returned.");
                    }
                    else if (error != nil)
                    {
                        DLog(@"An error occurred = %@", error);
                    }
                    
                }];
                
                
                
                [self.mapView setZoomLevel:15.1 animated:NO];
                [self.mapView setCenterCoordinate:location.coordinate];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    DLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
//    self.deviceLocation = location;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count > 0){
            
            CLPlacemark *placemark = placemarks[0];
            //获取城市
            NSString *locality = placemark.locality;
            if (!locality) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                locality = placemark.administrativeArea;
            }
            city = locality;
   
        }else if (error == nil && [placemarks count] == 0)
        {
            DLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            DLog(@"An error occurred = %@", error);
        }
        
    }];
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            
        }
        annotationView.canShowCallout               = YES; // 设置为NO，用以调用自定义的calloutView
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        //        annotationView.animatesDrop                 = YES; //设置标注动画显示，默认为NO
        
        if ([annotation.title isEqualToString:self.place]) {
            annotationView.pinColor                     = MAPinAnnotationColorRed;
        }else{
            self.addressField.text = annotation.title;
            annotationView.pinColor                     = MAPinAnnotationColorPurple;
            annotationView.draggable                    = YES; //设置标注可以拖动，默认为NO
        }
//        annotationView.image = [UIImage imageNamed:@"locate"];
//        annotationView.time = self.time;
//        annotationView.place = self.place;
//        annotationView.desc = self.desc;
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[POIAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"poiReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            
        }
        annotationView.canShowCallout               = YES; // 设置为NO，用以调用自定义的calloutView
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.pinColor                     = MAPinAnnotationColorPurple;
        annotationView.draggable = YES;
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

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleView = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleView.lineWidth = 2.f;
        circleView.strokeColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
        circleView.fillColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
        circleView.lineDash = YES;//YES表示虚线绘制，NO表示实线绘制
        
        return circleView;
    }
    return nil;
}


- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois
{
    if (pois.count == 0)
    {
        return;
    }
    
    /* Remove prior annotation. */
    [self.mapView removeAnnotation:self.poiAnnotation];
    self.poiAnnotation = nil;
    
    MATouchPoi *touchPoi = pois[0];
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = touchPoi.coordinate;
    annotation.title      = touchPoi.name;
    
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    self.poiAnnotation = annotation;
    selectCoordinate = self.poiAnnotation.coordinate;
    [self.mapView removeOverlays:self.mapView.overlays];
}

#pragma mark -  AMapSearchDelegate
//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    self.poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        POIAnnotation *annotatin = [[POIAnnotation alloc] initWithPOI:obj];
        [self.poiAnnotations addObject:annotatin];
        
    }];
    
}

//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0)
    {
        return;
    }
    
    
    self.poiAnnotations = [NSMutableArray arrayWithCapacity:response.tips.count];
    [response.tips enumerateObjectsUsingBlock:^(AMapTip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
        annotation.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        annotation.title = obj.name;
        [self.poiAnnotations addObject:annotation];
    }];
    
    self.tableView.hidden = NO;
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    [self.tips setArray:response.tips]; // AMapTip
    [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (self.tips && self.tips.count > 0) {
        self.tableView.hidden = NO;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.addressField resignFirstResponder];
    if ([textField.text isEqualToString:@""]) {
        self.tableView.hidden = YES;
    }
//    [self setupSearch:textField.text];
    [self searchPoiByKeyword:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.addressField resignFirstResponder];
    self.tableView.hidden = YES;
//    [self setupSearch:textField.text];
    [self searchPoiByKeyword:textField.text];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self searchTipsWithKey:textField.text];
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    AMapTip *tip = self.tips[indexPath.row];
    cell.textLabel.text = tip.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapTip *tip = self.tips[indexPath.row];
    self.addressField.text = tip.name;
    [self.addressField resignFirstResponder];
    self.tableView.hidden = YES;
    
    if (self.poiAnnotation) {
        [self.mapView removeAnnotation:self.poiAnnotation];
    }
    
    MAPointAnnotation *annotatin = self.poiAnnotations[indexPath.row];
    [self.mapView addAnnotation:annotatin];
    [self.mapView setCenterCoordinate:annotatin.coordinate animated:YES];
    
    selectCoordinate = annotatin.coordinate;
    self.poiAnnotation = annotatin;
    [self.mapView removeOverlays:self.mapView.overlays];
}

#pragma mark - UI
- (void)initView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 45)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, 15, 20)];
    imgView.center = CGPointMake(view.centerX, view.centerY);
    imgView.contentMode = UIViewContentModeCenter;
    imgView.image = [UIImage imageNamed:@"locate"];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame)+15, 5, 0.5, 45-10)];
    label.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:label];
    
    self.addressField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, SCREENWIDTH-20, 45)];
    self.addressField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressField.backgroundColor = KblackgroundColor;
    self.addressField.font = [UIFont systemFontOfSize:15];
    self.addressField.placeholder = @"搜索地址";
    self.addressField.leftViewMode = UITextFieldViewModeAlways;
    self.addressField.leftView = view;
    self.addressField.delegate = self;
    self.addressField.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.addressField];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(65, 55, SCREENWIDTH-20-70, 150) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.f;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-64-50, SCREENWIDTH, 50)];
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    bottomView.layer.borderWidth = 1.f;
    [self.view addSubview:bottomView];
    
    self.leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 40, 30)];
    self.leftLabel.font = [UIFont systemFontOfSize:14];
    self.leftLabel.textColor = [UIColor lightGrayColor];
    self.leftLabel.text = @"300m";
    [bottomView addSubview:self.leftLabel];
    
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(50, 0, SCREENWIDTH-105, 50)];
    self.slider.thumbTintColor = KColor;
    UIImage *image = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(8, 8)];
    [self.slider setThumbImage:[UIImage circleImage:image borderColor:[UIColor lightGrayColor] borderWidth:0.5f] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage circleImage:image borderColor:[UIColor lightGrayColor] borderWidth:0.5f] forState:UIControlStateHighlighted];
    CGFloat value = (CGFloat)(self.safeArea - MinArea) / (MaxArea - MinArea);
    self.slider.value = value;
    [self.slider addTarget:self action:@selector(areaChange:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:self.slider];
    
    self.rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREENWIDTH-55, 10, 45, 30)];
    self.rightLabel.font = [UIFont systemFontOfSize:14];
    self.rightLabel.textColor = [UIColor lightGrayColor];
    self.rightLabel.text = @"1000m";
    [bottomView addSubview:self.rightLabel];
}

- (void)areaChange:(UISlider *)slider
{
    self.safeArea = slider.value * (MaxArea - MinArea) + MinArea;
    
//    [self.mapView setCenterCoordinate:selectCoordinate animated:NO];
    
//    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
//    dispatch_after(timer, dispatch_get_main_queue(), ^{
    

        [self.mapView removeOverlays:self.mapView.overlays];
        MACircle *circle = [MACircle circleWithCenterCoordinate:selectCoordinate radius:self.safeArea];
        [self.mapView addOverlay:circle];
//    });
    
}

/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword:(NSString *)keyword
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    
    request.keywords            = keyword;
    request.city                = city;
//    request.types               = @"高等院校";
    request.requireExtension    = YES;
    
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit           = YES;
    request.requireSubPOIs      = YES;
    
    [self.search AMapPOIKeywordsSearch:request];
}

/* 在指定的范围内搜索POI. */
- (void)searchPoiByPolygon:(NSString *)keyword
{
    NSArray *points = [NSArray arrayWithObjects:
                       [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476],
                       [AMapGeoPoint locationWithLatitude:39.890459 longitude:116.581476],
                       nil];
    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:points];
    
    AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];
    
    request.polygon             = polygon;
    request.keywords            = keyword;
    request.requireExtension    = YES;
    
    [self.search AMapPOIPolygonSearch:request];
}

/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    tips.city     = city;
//    tips.cityLimit = YES; 是否限制城市
    
    [self.search AMapInputTipsSearch:tips];
}

/* 根据中心点坐标来搜周边的POI. */
- (void)setupSearch:(NSString *)keyword
{
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:self.deviceLocation.coordinate.latitude longitude:self.deviceLocation.coordinate.longitude];
    request.keywords = keyword;
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
//    request.types = @"餐饮服务|商务住宅|生活服务";
    request.sortrule = 0;
    request.requireExtension = YES;
    
    //发起周边搜索
    [self.search AMapPOIAroundSearch:request];
   
}

#pragma mark - Utility
- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

- (void)addAnnotation
{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:22.54504222 longitude:113.94038916];
    if (self.pointAnnotaiton == nil)
    {
        self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
        [self.pointAnnotaiton setCoordinate:location.coordinate];
        self.pointAnnotaiton.title = @"软件大厦";
        [self.mapView addAnnotation:self.pointAnnotaiton];
    }
    [self.mapView setZoomLevel:15.1 animated:NO];
    [self.mapView setCenterCoordinate:location.coordinate];
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
}

#pragma mark -
- (void)completeClick
{
    NSString *url = @"guardian/setguardian";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    
    NSDictionary *parameters = @{@"token":token, @"eqId":eqId, @"type":self.type, @"longitude": [NSString stringWithFormat:@"%.6f",selectCoordinate.longitude], @"latitude":[NSString stringWithFormat:@"%.6f",selectCoordinate.latitude]};
    
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"设置位置信息成功"];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"refresh_update"];
                [defaults synchronize];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(updateAddress:)]) {
                    [self.delegate updateAddress:self.addressField.text];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
                
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else
        {
            if (error) {
                
            }
        }
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
