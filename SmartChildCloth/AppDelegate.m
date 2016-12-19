//
//  AppDelegate.m
//  SmartChildCloth
//
//  Created by Kitty on 16/11/15.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "AppDelegate.h"
#import "GuideViewController.h"

@interface AppDelegate () <GeTuiSdkDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GuideViewController *guideVc = [[GuideViewController alloc]init];
    self.window.rootViewController = guideVc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    BOOL isFirst = [[AppDefaultUtil sharedInstance] getFirstLanuch];
    if (!isFirst) {
        // 第一次启动
        [[AppDefaultUtil sharedInstance] setFirstLanuch:YES];
        
    }else{
        
        [guideVc presentLogin];
    }
    
    
    //配置用户Key
    [AMapServices sharedServices].apiKey = GaoDeAPIKey;
    
    [self deleteKeychain];
    NSLog(@"===================%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    
//    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    // [ GTSdk ]：使用APPID/APPKEY/APPSECRENT启动个推
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    
    // 注册APNs - custom method - 开发者自定义的方法
    [self registerRemoteNotification];
    
    
    return YES;
}


#pragma mark - 删除keychain
- (void)deleteKeychain
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    BOOL isFirst = [[AppDefaultUtil sharedInstance] getFirstLanuch];
    if (!isFirst) {
        // 第一次启动
        [[AppDefaultUtil sharedInstance] setFirstLanuch:YES];
        
        NSString *value = [SSKeychain passwordForService:identifier account:@"isFirstInstall"];
        if (value && [value isEqualToString:@"1"]) {
            BOOL delete = [SSKeychain deletePasswordForService:identifier account:@"isFirstInstall"];
            if (delete) {
                DLog(@"删除keychain成功");
            }
        }
        
    }
}

- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

/*
#pragma mark - CBCentralManagerDelegate
// 此处监控一下central的状态值，可以判断蓝牙是否开启/可用
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    DLog(@"centralManagerDidUpdateState");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChange" object:[NSNumber numberWithBool:NO]];
    if (central.state == CBCentralManagerStatePoweredOn) {
        
        [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
    if(central.state == CBCentralManagerStatePoweredOff)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PoweredOff"];
    }
}
//也就是收到了一个周围的蓝牙发来的广告信息，这是CBCentralManager会通知代理来处理
//当扫描到4.0的设备后，系统会通过回调函数告诉我们设备的信息，然后我们就可以连接相应的设备，代码如下:
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    DLog(@"name:%@",peripheral.name);
    DLog(@"advertisementData = %@",[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]);
    
    if (!peripheral || !peripheral.name || ([peripheral.name isEqualToString:@""])) {
        return;
    }
    
    if (!self.peripheral || (self.peripheral.state == CBPeripheralStateDisconnected)) {
        if([peripheral.name isEqualToString:@"YY_clothes"])
        {
            //  YY_clothes
            self.peripheral = peripheral;
            self.peripheral.delegate = self;
            DLog(@"connect peripheral");
        }
        //  [_manager connectPeripheral:peripheral options:nil];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"PoweredOff"])
    {
        [_manager connectPeripheral:peripheral options:nil];
    }
}

//这个连接的方法会一直执行。如何实现自动断线重连，就是在断开的委托方法中，执行连接蓝牙的方法。
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // [[UIApplication sharedApplication].keyWindow makeToast:@"连接失败，重新连接"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChange" object:[NSNumber numberWithBool:NO]];
    
    [_manager connectPeripheral:peripheral options:nil];
}

//4扫描外设中的服务和特征(discover)
//同样的，当连接成功后，系统会通过回调函数告诉我们，然后我们就在这个回调里去扫描设备下所有的服务和特征，代码如下:
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [SVProgressHUD dismiss];
    DLog(@"连接成功后 %@",peripheral.name);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChange" object:[NSNumber numberWithBool:YES]];
    [[UIApplication sharedApplication].keyWindow makeToast:@"连接成功"];
    if(!peripheral)
    {
        return ;
    }
    //停止搜寻设备
    [_manager stopScan];
    
    // 寻找指定UUID的service
    [self.peripheral discoverServices:nil];
    
    
}

//当然我们最后再说一点，如果连接上的两个设备突然断开了，程序里面会自动回调下面的方法：
-   (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChange" object:[NSNumber numberWithBool:NO]];
    
    self.peripheral =nil;
    // 重新开启搜索
    [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

#pragma mark - CBPeripheralDelegate
// 找到Service后会调用下面的方法：
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = nil;
    if (peripheral != self.peripheral) {
        DLog(@"Wrong Peripheral.\n");
        return ;
    }
    if (error)
    {
        DLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    services = [peripheral services];
    if (!services || ![services count]) {
        DLog(@"No Services");
        return ;
    }
    for (CBService *service in services)
    {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9F"]])
        {
            //每个板子uuid一样 mac不一样 此处保存mac
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}
//Step 6 找到Characteristic后读取数据
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DLog(@"characteristics:%@",[service characteristics]);
    
    if (peripheral != self.peripheral) {
        return ;
    }
    if (error)
    {
        DLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9F"]])
        {
            notifycharacteristic = characteristic;
            [self startSubscribe];
            
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9F"]])
        {
            _writecharacteristic = characteristic;//保存读的特征
            // 同步时间请求
//            [self.peripheral writeValue:[self lishixinxi] forCharacteristic:_writecharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

//Step 7 处理数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    NSData *data = characteristic.value;
    DLog(@"读取的数据====%@",characteristic.value);
    
    // 此处我们就可以拿到value值对其进行数据解析了
    unsigned char *buffer = (unsigned char *)[data bytes];
    Byte *testByte = (Byte *)[data bytes];
    
    if(testByte[0] == 4)
    {
        Byte byte[] = {testByte[2],testByte[3]};
        NSData *data11 = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        NSString *str333 = [self hexStringFromData:data11];
        NSString *jieguoStr = [NSString stringWithFormat:@"%ld", strtoul([str333 UTF8String],0,16)];
        NSLog(@"单片机 步数 ======= %@",jieguoStr);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentWalk" object:jieguoStr];
        
    
        
    }
    if(testByte[0] == 3&&testByte[1] == 6)
    {
        if(testByte[2] == 0)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"outSafeDis"];
            
            [[UIApplication sharedApplication].keyWindow makeToast:@"重回安全距离"];
            
        }else if(testByte[2] == 1)
        {
            
            [[UIApplication sharedApplication].keyWindow makeToast:@"超出安全距离"];
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"outSafeDis"])
            {
                return ;
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"outSafeDis"];
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"cell1"])
            {
                // #define SOUNDID  1109  //1012 -iphone   1152 ipad  1109 ipad
                
                AudioServicesPlaySystemSound( 1109 );
//                //铃声
//                LxxPlaySound *sound = [[LxxPlaySound alloc]initForPlayingSystemSoundEffectWith:@"Tock" ofType:@"aiff"];
//                [sound play];
            }else
            {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                //震动
                //  LxxPlaySound *playSound =[[LxxPlaySound alloc]initForPlayingVibrate];
                // [playSound play];
            }
        }
    }
}

#pragma mark - 蓝牙方法
//这里我们可以使用readValueForCharacteristic:来读取数据。如果数据是不断更新的，则可以使用setNotifyValue:forCharacteristic:来实现只要有新数据，就获取。
-(void)startSubscribe
{
    [self.peripheral setNotifyValue:YES forCharacteristic:notifycharacteristic];
}

-(NSString *)hexStringFromData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
*/

#pragma mark - 用户通知(推送) _自定义方法
/** 注册远程通知 */
- (void)registerRemoteNotification {
    
//    [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 0, .patchVersion = 0}]
    /*
    if (IOS10) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"succeeded!");
            }
        }];
    }
     */
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        // >=iOS8
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else { //iOS8以下
//        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
//                                                                       UIRemoteNotificationTypeSound |
//                                                                       UIRemoteNotificationTypeBadge);
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }

}


#pragma mark - background fetch  唤醒
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // [ GTSdk ]：Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    DLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    // [ GTSdk ]：向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError:%@", [error localizedDescription]]];
    DLog(@"失败：%@",[error localizedDescription]);
}

#pragma mark - APP运行中接收到通知(推送)处理
/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台)  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    
    // 显示APNs信息到页面
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], userInfo];
    [[UIApplication sharedApplication].keyWindow makeToast:record];
    DLog(@"收到通知：%@",record);
    
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - GeTuiSdkDelegate
// SDK启动成功返回cid
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [ GTSdk ]：个推SDK已注册，返回clientId
    [[AppDefaultUtil sharedInstance] setClientId:clientId];
    DLog(@">>[GTSdk RegisterClient]:%@", clientId);
}

// SDK收到透传消息回调
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    
    // 数据转换
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    
    // 页面显示日志
    NSString *record = [NSString stringWithFormat:@"%d, %@, %@%@", ++_lastPayloadIndex, [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    //    [[UIApplication sharedApplication].keyWindow makeToast:record];
    
    // 控制台打印日志
    NSString *msg = [NSString stringWithFormat:@"%@ : %@%@", [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    DLog(@">>[GTSdk ReceivePayload]:%@, taskId: %@, msgId :%@ record:%@", msg, taskId, msgId, record);
}

// SDK收到sendMessage消息回调
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // 页面显示：上行消息结果反馈
    NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
    //    [[UIApplication sharedApplication].keyWindow makeToast:record];
    DLog(@"Received sendmessage:%@",record);
}

// SDK遇到错误回调
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // 页面显示：个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    //    [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]];
    DLog(@"[GexinSdk error]:%@",[error localizedDescription]);
}

// SDK运行状态通知
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // 页面显示更新通知SDK运行状态 [GeTuiSdk status]
    //    [_viewController updateStatusView:self];
    DLog(@"[GeTuiSdk status]:%d",[GeTuiSdk status]);
}

// SDK设置推送模式回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    // 页面显示错误信息
    if (error) {
        [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@">>>[SetModeOff error]: %@", [error localizedDescription]]];
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@">>>[GexinSdkSetModeOff]: %@", isModeOff ? @"开启" : @"关闭"]];
    
    // 页面更新按钮事件
    //    UIViewController *vc = _naviController.topViewController;
    //    if ([vc isKindOfClass:[ViewController class]]) {
    //        ViewController *nextController = (ViewController *) vc;
    //        [nextController updateModeOffButton:isModeOff];
    //    }
    // 开启推送
    [GeTuiSdk setPushModeForOff:NO];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
