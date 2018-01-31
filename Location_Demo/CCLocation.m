//
//  CCLocation.m
//  Location_Demo
//
//  Created by chencheng on 2018/1/29.
//  Copyright © 2018年 double chen. All rights reserved.
//

#import "CCLocation.h"

@interface CCLocation ()<CLLocationManagerDelegate>
{
    LocationCallback _locationCallback;
    BOOL _keepLocation; //持续定位
    HeadingCallback _headingCallback;
    FailCallback _failCallback;
}

@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) CLGeocoder *geocoder;

@end

@implementation CCLocation

+ (CCLocation *)shareInstance {
    static CCLocation *location = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        location = [[CCLocation alloc] init];
        [location initializedLocationManager];
    });
    return location;
}

# pragma mark - APIs(public)
/*
 申请定位权限
 */
- (void)requestPermission {
    
    //iOS9.0以上系统除了配置info之外，还需要添加这行代码，才能实现后台定位，否则程序会crash
    if (@available(iOS 9.0, *)) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    } else {
        // Fallback on earlier versions
    }
    [_locationManager requestAlwaysAuthorization];  //一直保持定位
    [_locationManager requestWhenInUseAuthorization]; //使用期间定位
}

/*
 查看定位权限
 */
- (BOOL)checkPermission {
    /*
     kCLAuthorizationStatusNotDetermined                  //用户尚未对该应用程序作出选择
     kCLAuthorizationStatusRestricted                     //应用程序的定位权限被限制
     kCLAuthorizationStatusAuthorizedAlways               //允许一直获取定位
     kCLAuthorizationStatusAuthorizedWhenInUse            //在使用时允许获取定位
     kCLAuthorizationStatusAuthorized                     //已废弃，相当于一直允许获取定位
     kCLAuthorizationStatusDenied                         //拒绝获取定位
     */
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"用户尚未进行选择");
                break;
            case kCLAuthorizationStatusRestricted:
                NSLog(@"定位权限被限制");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"允许定位");
                return YES;
                break;
            case kCLAuthorizationStatusDenied:
                NSLog(@"不允许定位");
                break;
                
            default:
                break;
        }
    }
    
    return NO;
}

/*
 获取当前定位
 */
- (void)updateLocationWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy block:(LocationCallback)block fail:(FailCallback)fail {
    _locationCallback = block;
    _failCallback = fail;
    _keepLocation = NO;
    self.locationManager.desiredAccuracy = desiredAccuracy;
    [self.locationManager startUpdatingLocation];
}

/*
 持续获取当前定位
 */
- (void)keepUpdateLocationWithDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy distanceFilter:(CGFloat)distanceFilter block:(LocationCallback)block fail:(FailCallback)fail {
    _locationCallback = block;
    _failCallback = fail;
    _keepLocation = YES;
    self.locationManager.desiredAccuracy = desiredAccuracy;
    self.locationManager.distanceFilter = distanceFilter;
    [self.locationManager startUpdatingLocation];
}

/*
 停止获取定位
 */
- (void)stopUpdateLocaiton {
    [self.locationManager stopUpdatingLocation];
    _keepLocation = NO;
    _locationCallback = nil;
}

/*
 获取指南针信息
 */
- (void)updateHeadingToBlock:(HeadingCallback)block {
    _headingCallback = block;
    [self.locationManager startUpdatingHeading];
}

/*
 停止获取指南针信息
 */
- (void)stopUpdateHeading {
    [self.locationManager stopUpdatingHeading];
}

/*
 地理编码
 */
- (void)geocodeAddressString:(NSString *)address block:(PlacemarkCallback)block {
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"编码坐标信息出错,error: %@",error);
            return;
        }
        block(placemarks.lastObject);
        
    }];
}

/*
 反地理编码
 */
- (void)reverseGeocodeLocation:(CLLocation *)location block:(PlacemarkCallback)block {
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"编码坐标信息出错,error: %@",error);
            return;
        }
//        for (CLPlacemark *placemark in placemarks) {
//            NSLog(@"%@,%@,%@",placemark.name,placemark.addressDictionary,placemark.location);
//        }
        block(placemarks.lastObject);
    }];
}

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate block:(PlacemarkCallback)block {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self reverseGeocodeLocation:location block:block];
}

# pragma mark - APIs(private)
- (void)initializedLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    /*
     定位精确度
     kCLLocationAccuracyBestForNavigation    最适合导航
     kCLLocationAccuracyBest    精度最好的
     kCLLocationAccuracyNearestTenMeters    附近10米
     kCLLocationAccuracyHundredMeters    附近100米
     kCLLocationAccuracyKilometer    附近1000米
     kCLLocationAccuracyThreeKilometers    附近3000米
     */
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    /*
     每隔多少米更新一次位置，即定位更新频率
     */
//    _locationManager.distanceFilter = kCLDistanceFilterNone; //系统默认值
}

# pragma mark - Lazy load
- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

# pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (_locationCallback) {
        _locationCallback(locations.lastObject);
        
        
    }
    if (_keepLocation == NO) {
        [self.locationManager stopUpdatingLocation];
        _locationCallback = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorLocationUnknown) {
        NSLog(@"无法检索位置");
    }
    else if(error.code == kCLErrorNetwork) {
        NSLog(@"网络问题");
    }
    else if(error.code == kCLErrorDenied) {
        NSLog(@"定位权限的问题");
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
    
    if (_failCallback) {
        _failCallback(error.code);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (_headingCallback) {
        _headingCallback(newHeading.magneticHeading);
    }
}

@end
