//
//  AppDelegate.h
//  SmartChildCloth
//
//  Created by Kitty on 16/11/15.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>
{
    //蓝牙中心管理器
    CBCharacteristic *notifycharacteristic;
}

@property(nonatomic,strong)CBCentralManager *manager; // 中央设备
@property(nonatomic,strong)CBPeripheral *peripheral; // 外围设备
@property(nonatomic,assign)NSInteger jingzuoNum;
@property(nonatomic,strong)CBCharacteristic *writecharacteristic;

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) int lastPayloadIndex;


@end

