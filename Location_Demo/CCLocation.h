//
//  CCLocation.h
//  Location_Demo
//
//  Created by chencheng on 2018/1/29.
//  Copyright © 2018年 double chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef void(^LocationCallback)(CLLocation *location);
typedef void(^HeadingCallback)(CGFloat heading);
typedef void(^PlacemarkCallback)(CLPlacemark *placemark);
typedef void(^FailCallback)(NSError *error);

@interface CCLocation : NSObject

+ (CCLocation *)shareInstance;

/*
 申请定位权限
 Privacy - Location When In Use Usage Description
 Privacy - Location Always Usage Description
 */
- (void)requestPermission;

/*
 查看定位权限
 */
- (BOOL)checkPermission;

/*
 获取当前定位
 desiredAccuracy:定位所需精度
 属性说明:
 location.altitude:海拔高度，正数表示在海平面之上，而负数表示在海平面之下
 location.verticalAccuracy:海拔高度的精度。为正值表示海拔高度的误差为对应的米数；为负表示altitude(海拔高度)的值无效
 location.horizontalAccuracy:位置的精度(半径)。位置精度通过一个圆表示，实际位置可能位于这个圆内的任何地方。这个圆是由coordinate(坐标)和horizontalAccuracy(半径)共同决定的，horizontalAccuracy的值越大，那么定义的圆就越大，因此位置精度就越低。如果horizontalAccuracy的值为负，则表明coordinate的值无效
 location.speed:速度。该属性是通过比较当前位置和前一个位置，并比较它们之间的时间差异和距离计算得到的。鉴于Core Location更新的频率，speed属性的值不是非常精确，除非移动速度变化很小
 */
- (void)updateLocationWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy block:(LocationCallback)block fail:(FailCallback)fail;

/*
 持续获取当前定位
 desiredAccuracy:定位所需精度
 distanceFilter:定位频率
 */
- (void)keepUpdateLocationWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy distanceFilter:(CGFloat)distanceFilter block:(LocationCallback)block fail:(FailCallback)fail;

/*
 停止获取定位
 */
- (void)stopUpdateLocaiton;

/*
 获取指南针信息
 */
- (void)updateHeadingToBlock:(HeadingCallback)block;

/*
 停止获取指南针信息
 */
- (void)stopUpdateHeading;

/*
 地理编码
 */
- (void)geocodeAddressString:(NSString *)address block:(PlacemarkCallback)block fail:(FailCallback)fail;

/*
 反地理编码
 placemark.name:位置名称
 placemark.addressDictionary:位置信息，字典
 placemark.location:位置坐标，不一定和传入参数一致
 */
- (void)reverseGeocodeLocation:(CLLocation *)location block:(PlacemarkCallback)block fail:(FailCallback)fail;
- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate block:(PlacemarkCallback)block fail:(FailCallback)fail;



@end
