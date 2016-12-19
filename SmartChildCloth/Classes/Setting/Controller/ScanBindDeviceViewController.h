//
//  ScanBindDeviceViewController.h
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCScanner.h"

@protocol QRCodeScannerViewControllerDelegate <NSObject>
/**
 *  扫描成功后返回扫描结果
 *
 *  @param result 扫描结果
 */
- (void)didFinshedScanning:(NSString *)result;

@end

@interface ScanBindDeviceViewController : UIViewController

@property (nonatomic, copy, readonly) NSString *urlString;

@property (nonatomic,assign) id<QRCodeScannerViewControllerDelegate> delegate;

@end
