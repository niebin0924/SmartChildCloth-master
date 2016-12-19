//
//  BaseMapViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/12.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "BaseMapViewController.h"

@interface BaseMapViewController ()

@property (nonatomic, assign) BOOL isFirstAppear;

@end

@implementation BaseMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _isFirstAppear = YES;
    
    [self initMapView];
    
    [self initSearch];
    
    [self initLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.mapView.mapType = MAMapTypeStandard;
    
//    if (_isFirstAppear)
//    {
//        self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
//        _isFirstAppear = NO;
//        
//        [self hookAction];
//    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self clearMapView];
    
    [self clearSearch];
    
}

- (void)dealloc
{
    [self clearMapView];
    
    [self clearSearch];
    
    DLog(@"%@被dealloc",NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self clearMapView];
    
    [self clearSearch];
}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    // 关闭指南针
    self.mapView.showsCompass= NO;
    // show traffic
    self.mapView.showTraffic = YES;
        
    [self.view addSubview:self.mapView];
}

- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc]init];
}

- (void)initLocation
{
    self.locationManager = [[AMapLocationManager alloc]init];
    
}

#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    DLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

#pragma mark - Handle URL Scheme

- (NSString *)getApplicationName
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo valueForKey:@"CFBundleDisplayName"] ?: [bundleInfo valueForKey:@"CFBundleName"];
}

- (NSString *)getApplicationScheme
{
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *URLTypes           = [bundleInfo valueForKey:@"CFBundleURLTypes"];
    
    NSString *scheme;
    for (NSDictionary *dic in URLTypes)
    {
        NSString *URLName = [dic valueForKey:@"CFBundleURLName"];
        if ([URLName isEqualToString:bundleIdentifier])
        {
            scheme = [[dic valueForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            break;
        }
    }
    
    return scheme;
}

#pragma mark - Utility

- (void)clearMapView
{
    // reset traffic
    self.mapView.showTraffic = NO;
    
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
    self.mapView.delegate = nil;

//    [self.mapView removeFromSuperview];
//    self.mapView = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
    self.search = nil;
}

/**
 *  hook,子类覆盖它,实现想要在viewDidAppear中执行一次的方法,搜索中有用到
 */
- (void)hookAction
{
    
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
