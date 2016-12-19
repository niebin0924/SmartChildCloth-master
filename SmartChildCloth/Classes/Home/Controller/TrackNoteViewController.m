//
//  TrackNoteViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/11.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "TrackNoteViewController.h"
#import <MAMapKit/MATraceManager.h>
#import "MovingAnnotationView.h"
#import "CalenderView.h"
#import "TracingPoint.h"
#import "Util.h"

@interface TrackNoteViewController () <CalenderViewDelegate>
{
    NSString *timestamp;
    CLLocationCoordinate2D *_coordinates;
    NSMutableArray *_tracking;
    MovingAnnotationView *carView;
    
    BOOL flag; // 判读是否重复点击
    BOOL isPlay; // 是否播放
    BOOL isPause; // 是否暂停
}

@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *pauseBtn;
@property (nonatomic,strong) CalenderView *calender;

@property (nonatomic,strong) NetWork *netWork;

@property (nonatomic, strong) NSOperation *queryOperation;
@property (nonatomic, strong) NSMutableArray *processedOverlays; //处理后的

@property (nonatomic,strong) MAPolyline *routeLine;
@property (nonatomic,strong) NSMutableArray *pointArray;
@property (nonatomic,strong) MAPointAnnotation *car;

// 轨迹回放动画时间
@property (nonatomic, assign) NSTimeInterval duration;


@end

@implementation TrackNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"轨迹记录";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"日历" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    
    self.processedOverlays = [NSMutableArray array];
    self.duration = 8.f;
    timestamp = @"";
    
    [self configMapView];
    [self initView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.mapView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64-50);
    
    [self request:timestamp];
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.car = nil;
    self.routeLine = nil;
    carView = nil;
    
    [self cancelAction];
}

- (void)configMapView
{
    
    // 后台定位适用于记录轨迹或者出行类App司机端
    //注意：后台定位必须将info.plist的字段改成NSLocationAlwaysUsageDescription字段。
    
    /**
     *  定位 NSLocationWhenInUsageDescription
     */
//    self.mapView.showsUserLocation = YES; //YES 为打开定位，NO为关闭定位
//    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
//    [self.mapView setZoomLevel:15.1 animated:NO];
    
    // 后台定位
    //        self.mapView.pausesLocationUpdatesAutomatically = NO;
#if SUPPORT_IOS9
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
//        self.mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    }
#endif
    
    // 加入annotation旋转动画后，暂未考虑地图旋转的情况。
    self.mapView.rotateCameraEnabled = NO;//倾斜手势
    self.mapView.rotateEnabled = NO;//旋转手势
}


- (void)request:(NSString *)time
{
    if (self.netWork == nil) {
        self.netWork = [[NetWork alloc]init];
    }
    
    NSString *url;
    NSDictionary *parameter;
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    if ([timestamp isEqualToString:@""]) {
        url = @"location/findCurrentLocation";
        parameter = @{@"token":token, @"eqId":eqId};
    }
    else{
        url = @"location/findLocationByDate";
        parameter = @{@"token":token, @"eqId":eqId, @"time":time};
    }
    
    
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSMutableArray *mArr = [NSMutableArray array];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                NSArray *results = [dict objectForKey:@"jsonResult"];
                NSMutableArray *mutArray = [NSMutableArray array];
                if (results && results.count > 0) {
                    for (NSDictionary *result in results) {
                        NSString *latitude = [NSString stringWithFormat:@"%@",[result objectForKey:@"latitude"]]; // 纬度
                        NSString *longitude = [NSString stringWithFormat:@"%@",[result objectForKey:@"longitude"]]; // 经度
                        double time = [[NSString stringWithFormat:@"%@",[result objectForKey:@"time"]] doubleValue];
                        double speed = [[NSString stringWithFormat:@"%@",[result objectForKey:@"rate"]] doubleValue];
                        
                        CLLocation *location = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                        
                        MATraceLocation *loc = [[MATraceLocation alloc] init];
                        loc.loc = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
                        loc.time = time;
                        loc.speed = speed;
                        [mArr addObject:loc];
                        
                        
                        AMapCoordinateType type = AMapCoordinateTypeGPS;
                        MATracePoint *p = [[MATracePoint alloc] init];
                        if(type <= AMapCoordinateTypeGPS) {
                            //坐标转换
                            CLLocationCoordinate2D l = AMapCoordinateConvert(loc.loc, type);
                            p.latitude = l.latitude;
                            p.longitude = l.longitude;
                            loc.loc = l;
                        } else {
                            p.latitude = location.coordinate.latitude;
                            p.longitude = location.coordinate.longitude;
                        }
                        
                        if (fabs(p.longitude - 0) < 0.0001 && fabs(p.latitude - 0) < 0.0001) {
                            continue;
                        }
                        
                        [mutArray addObject:p];
                        
                
                        
                    }
                    
                    _pointArray = mutArray;
                    
                    
                }
             

                [self configRoutes];
                
                // 通过time和speed进行轨迹纠偏
//                [self traceRectify:mArr];
                
                [self move];

                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

#pragma mark - 轨迹
// 轨迹纠偏
- (void)traceRectify:(NSArray *)mArr
{
    // 1.轨迹点数据
    AMapCoordinateType type = AMapCoordinateTypeGPS;
    // 2.纠偏
    MATraceManager *temp = [[MATraceManager alloc] init];
    __weak typeof(self) weakSelf = self;
    NSOperation *op = [temp queryProcessedTraceWith:mArr type:type processingCallback:^(int index, NSArray<MATracePoint *> *points) {
        
        [weakSelf addSubTrace:points];
        
    }  finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        
        weakSelf.queryOperation = nil;
        [weakSelf addFullTrace:points];
        
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        DLog(@"Error: %@", errorDesc);
        weakSelf.queryOperation = nil;
    }];
    
    self.queryOperation = op;
}

- (void)configRoutes
{
    // 地图画线
    _coordinates = (CLLocationCoordinate2D *)malloc(self.pointArray.count * sizeof(CLLocationCoordinate2D));
    
    for (NSInteger idx=0; idx<self.pointArray.count; idx++) {
        MATracePoint *location = self.pointArray[idx];
        
        _coordinates[idx].longitude = location.longitude;
        _coordinates[idx].latitude = location.latitude;
    }
    
    
    if (_routeLine) {
        [self.mapView removeOverlay:_routeLine];
    }
    _routeLine = [MAPolyline polylineWithCoordinates:_coordinates count:self.pointArray.count];
    
    if (_routeLine != nil) {
        [self.mapView addOverlay:_routeLine];
    }
    
    
    // 添加标注
    NSMutableArray *routeAnno = [NSMutableArray array];
    for (NSInteger i=0; i<self.pointArray.count; i++) {
        MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
        a.coordinate = _coordinates[i];
        a.title = @"route";
        [routeAnno addObject:a];
    }
    [self.mapView addAnnotations:routeAnno];
    [self.mapView showAnnotations:routeAnno animated:YES];
    
    // 轨迹
    [self configTracking];
    
    if (_coordinates) {
        free(_coordinates);
    }
    
    /* Step 1. */
    //show car
    if (self.car) {
        self.car = nil;
    }
    self.car = [[MAPointAnnotation alloc] init];
    TracingPoint *start = [_tracking firstObject];
    self.car.coordinate = start.coordinate;
    self.car.title = @"Car";
    [self.mapView addAnnotation:self.car];

}

- (void)configTracking
{
    _tracking = [NSMutableArray array];
    for (int i = 0; i<self.pointArray.count - 1; i++)
    {
        TracingPoint * tp = [[TracingPoint alloc] init];
        tp.coordinate = _coordinates[i];
        tp.course = [Util calculateCourseFromCoordinate:_coordinates[i] to:_coordinates[i+1]];
        [_tracking addObject:tp];
    }
    
    TracingPoint * tp = [[TracingPoint alloc] init];
    tp.coordinate = _coordinates[self.pointArray.count - 1];
    tp.course = ((TracingPoint *)[_tracking lastObject]).course;
    [_tracking addObject:tp];
}

- (void)move
{
    if (self.car && _tracking) {
        /* Step 3. */
        /* Find annotation view for car annotation. */
        carView = (MovingAnnotationView *)[self.mapView viewForAnnotation:self.car];
        
        /*
         Add multi points animation to annotation view.
         The coordinate of car annotation will be updated to the last coords after animation is over.
         */
        if (!isPlay) {
            isPlay = YES;
            [carView addTrackingAnimationForPoints:_tracking duration:_duration];
            
        }else{
            if (isPause) {
                [carView pauseTrackingAnimationForPoints:_tracking];
            }else{
                [carView resumeTrackingAnimationForPoints:_tracking];
            }
        }
        
    }
}

#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    /* Step 2. */
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *trackingReuseIndetifier = @"trackingReuseIndetifier";

        MovingAnnotationView *annotationView = (MovingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:trackingReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MovingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:trackingReuseIndetifier];
        }
        
        if ([annotation.title isEqualToString:@"Car"])
        {
            UIImage *imge  =  [UIImage imageNamed:@"userPosition"];
            annotationView.image =  imge;
            CGPoint centerPoint = CGPointZero;
            [annotationView setCenterOffset:centerPoint];
        }
        else if ([annotation.title isEqualToString:@"route"])
        {
            annotationView.image = [UIImage imageNamed:@"trackingPoints"];
        }
        
        
        return annotationView;
    }
    
    return nil;
}

// 地图线属性
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 3.f;
        polylineView.strokeColor = [UIColor colorWithRed:0 green:0.47 blue:1.0 alpha:0.9];
        polylineView.lineJoinType = kCGLineJoinRound;//连接类型
        polylineView.lineCapType = kCGLineCapRound;//端点类型
        
        return polylineView;
    }
    return nil;
}

//减小内存
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapView removeFromSuperview];
    
    [self.view addSubview:mapView];
}

#pragma mark - CalenderViewDelegate
- (void)calenderView:(CalenderView *)calenderView SelectItem:(NSIndexPath *)indexPath WithDate:(NSDate *)date
{
    timestamp = [GLDateUtils descriptionForDate:date];
    
    if ([GLDateUtils date:date isSameDayAsDate:[NSDate date]]) {
        timestamp = @"";
    }
    
    [self.mapView removeAnnotation:self.car];
    [self.mapView removeAnnotations:self.mapView.annotations];
    carView = nil;
    isPlay = NO;
}

#pragma mark - Utility
- (void)cancelAction {
    if(self.queryOperation) {
        [self.queryOperation cancel];
        
        self.queryOperation = nil;
    }
}

- (MAPolyline *)makePolyLineWith:(NSArray<MATracePoint*> *)tracePoints {
    if(tracePoints.count == 0) {
        return nil;
    }
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * tracePoints.count);
    if(!pCoords) {
        return nil;
    }
    
    for(int i = 0; i < tracePoints.count; ++i) {
        MATracePoint *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.latitude;
        pCur->longitude = p.longitude;
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:pCoords count:tracePoints.count];
    
    if(pCoords) {
        free(pCoords);
    }
    
    return polyline;
}

- (void)addFullTrace:(NSArray<MATracePoint*> *)tracePoints {
    MAPolyline *polyline = [self makePolyLineWith:tracePoints];
    if(!polyline) {
        return;
    }
    
    
    [self.mapView removeOverlays:self.processedOverlays];
    [self.processedOverlays removeAllObjects];
    
    
    [self.mapView setVisibleMapRect:MAMapRectInset(polyline.boundingMapRect, -1000, -1000)];
    
    
    [self.processedOverlays addObject:polyline];
    [self.mapView addOverlays:self.processedOverlays];
    
}

- (void)addSubTrace:(NSArray<MATracePoint*> *)tracePoints{
    MAPolyline *polyline = [self makePolyLineWith:tracePoints];
    if(!polyline) {
        return;
    }
    
    MAMapRect visibleRect = [self.mapView visibleMapRect];
    if(!MAMapRectContainsRect(visibleRect, polyline.boundingMapRect)) {
        MAMapRect newRect = MAMapRectUnion(visibleRect, polyline.boundingMapRect);
        [self.mapView setVisibleMapRect:newRect];
    }
    
   
    [self.processedOverlays addObject:polyline];
    
    [self.mapView addOverlay:polyline];
}

// 经纬度转屏幕坐标, 调用着负责释放内存.
- (CGPoint *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (coordinates == NULL || count <= 1)
    {
        return NULL;
    }
    
    /* 申请屏幕坐标存储空间. */
    CGPoint *points = (CGPoint *)malloc(count * sizeof(CGPoint));
    
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)
    {
        points[i] = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
    }
    
    return points;
}

/* 构建path, 调用着负责释放内存. */
- (CGMutablePathRef)pathForPoints:(CGPoint *)points count:(NSUInteger)count
{
    if (points == NULL || count <= 1)
    {
        return NULL;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddLines(path, NULL, points, count);
    
    return path;
}

/* 构建annotationView的keyFrameAnimation. */
- (CAAnimation *)constructAnnotationAnimationWithPath:(CGPathRef)path
{
    if (path == NULL)
    {
        return nil;
    }
    
    CAKeyframeAnimation *thekeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    thekeyFrameAnimation.duration        = self.duration;
    thekeyFrameAnimation.path            = path;
    thekeyFrameAnimation.calculationMode = kCAAnimationPaced;
    
    return thekeyFrameAnimation;
}

/* 构建shapeLayer的basicAnimation. */
- (CAAnimation *)constructShapeLayerAnimation
{
    CABasicAnimation *theStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    theStrokeAnimation.duration         = self.duration;
    theStrokeAnimation.fromValue        = @0.f;
    theStrokeAnimation.toValue          = @1.f;
    
    return theStrokeAnimation;
}

#pragma mark - UI
- (void)initView
{
    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT-51-64, SCREENWIDTH, 1)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line1];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(0, SCREENHEIGHT-50-64, (SCREENWIDTH-2)/2, 50);
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseBtn.frame = CGRectMake((SCREENWIDTH-2)/2+2, SCREENHEIGHT-50-64, (SCREENWIDTH-2)/2, 50);
    [self.pauseBtn setTitle:@"停止" forState:UIControlStateNormal];
    [self.pauseBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.pauseBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pauseBtn];
    
    UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 2, 20)];
    line2.center = CGPointMake(self.view.centerX, self.playBtn.centerY);
    line2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line2];
}

#pragma mark -
- (void)rightClick
{
    UIControl *bgView = [[UIControl alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    [bgView addTarget:self action:@selector(touchClick:) forControlEvents:UIControlEventTouchUpInside];
    self.calender = [[CalenderView alloc]initWithFrame:CGRectMake(10, 150, SCREENWIDTH - 20, ((SCREENWIDTH - 20) / 7) * 5 + 40)];
    self.calender.backgroundColor = [UIColor clearColor];
    self.calender.delegate = self;
    [bgView addSubview:self.calender];
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
}

- (void)touchClick:(UIControl *)control
{
    if (control != nil) {
        [control removeFromSuperview];
    }
}

- (void)play:(UIButton *)sender
{
    if (!isPlay) {
        
        [self request:timestamp];
        
    }else{
        if (isPause) {
            isPause = NO;
            [self move];
        }
        
        
    }
}

- (void)pause:(UIButton *)sender
{
    if (!isPause) {
        isPause = YES;
        [self move];
    }
    
    
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
