//
//  ViewController.m
//  Location_Demo
//
//  Created by chencheng on 2018/1/23.
//  Copyright © 2018年 double chen. All rights reserved.
//

#import "ViewController.h"
#import "LocationVC.h"
#import "CCLocation.h"

static NSString *cellIdentifier = @"cellIdentifier";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataSource;
    NSMutableArray *_locations;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataSource = @[@"请求定位权限",
                    @"查询定位权限",
                    @"获取当前定位",
                    @"持续获取当前定位",
                    @"后台持续定位",
                    @"停止获取定位",
                    @"获取指南针信息",
                    @"停止获取指南针信息",
                    @"地理编码",
                    @"反地理编码",
                    @"查看历史定位",
                    @"后台定位低功耗设置",
                    @"取消低功耗设置"].mutableCopy;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    if (@available(iOS 10.0, *)) {
//        [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"%@",_locations);
//        }];
    } else {
        // Fallback on earlier versions
    }
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults] valueForKey:@"Locations"];
    _locations = arr.mutableCopy;
    if (!_locations) {
        _locations = @[].mutableCopy;
    }
    NSLog(@"%@",_locations);
}

# pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}

# pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        //请求定位权限
        [[CCLocation shareInstance] requestPermission];
    }else if (indexPath.row == 1) {
        //查询定位权限
        [[CCLocation shareInstance] checkPermission];
    }else if (indexPath.row == 2) {
        //获取当前定位
        [[CCLocation shareInstance] updateLocationWithDesiredAccuracy:kCLLocationAccuracyBest block:^(CLLocation *location) {
            NSLog(@"获取当前定位");
            NSLog(@"位置: %@",location);
            NSLog(@"位置精度(半径): %f",location.horizontalAccuracy);
            NSLog(@"海拔: %f",location.altitude);
            NSLog(@"海拔高度精度: %f",location.verticalAccuracy);
            NSLog(@"速度: %f",location.speed);
        } fail:^(NSError *error) {
            NSLog(@"定位失败:");
            if(error.code == kCLErrorLocationUnknown) {
                NSLog(@"无法检索位置");
            }
            else if(error.code == kCLErrorNetwork) {
                NSLog(@"网络问题");
            }
            else if(error.code == kCLErrorDenied) {
                NSLog(@"定位权限的问题");
            }
        }];
    }else if (indexPath.row == 3) {
        //持续获取当前定位
        [[CCLocation shareInstance] keepUpdateLocationWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:10.0f block:^(CLLocation *location) {
            NSLog(@"持续获取定位");
            NSLog(@"位置: %@",location);
            NSLog(@"位置精度(半径): %f",location.horizontalAccuracy);
            NSLog(@"海拔: %f",location.altitude);
            NSLog(@"海拔高度精度: %f",location.verticalAccuracy);
            NSLog(@"速度: %f",location.speed);
        } fail:^(NSError *error) {
            
        }];
    }else if (indexPath.row == 4) {
        //后台持续定位
        [[CCLocation shareInstance] keepUpdateLocationInBackgroundWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:10.0f block:^(CLLocation *location) {
            NSLog(@"持续获取定位");
            NSLog(@"位置: %@",location);
            NSLog(@"位置精度(半径): %f",location.horizontalAccuracy);
            NSLog(@"海拔: %f",location.altitude);
            NSLog(@"海拔高度精度: %f",location.verticalAccuracy);
            NSLog(@"速度: %f",location.speed);
            
//            [_locations addObject:@{@"latitude":@(location.coordinate.latitude),
//                                    @"longitude":@(location.coordinate.longitude)}];
//            [[NSUserDefaults standardUserDefaults] setValue:_locations forKey:@"Locations"];
        } fail:^(NSError *error) {
            
        }];
    }else if (indexPath.row == 5) {
        //停止获取定位
        [[CCLocation shareInstance] stopUpdateLocaiton];
    }else if (indexPath.row == 6) {
        //获取指南针信息
        [[CCLocation shareInstance] updateHeadingToBlock:^(CGFloat heading) {
           NSLog(@"指南针指向: %f",heading);
        }];
    }else if (indexPath.row == 7) {
        //停止获取指南针信息
        [[CCLocation shareInstance] stopUpdateHeading];
    }else if (indexPath.row == 8) {
        //地理编码
        [[CCLocation shareInstance] updateLocationWithDesiredAccuracy:kCLLocationAccuracyBest block:^(CLLocation *location) {
            [[CCLocation shareInstance] geocodeAddressString:@"深圳市" block:^(CLPlacemark *placemark) {
                NSLog(@"%@,%@,%@",placemark.name,placemark.addressDictionary,placemark.location);
            } fail:^(NSError *error) {
                NSLog(@"地理编码出错,error: %@",error);
            }];
        } fail:^(NSError *error) {
            
        }];
    }else if (indexPath.row == 9) {
        //反地理编码
        [[CCLocation shareInstance] updateLocationWithDesiredAccuracy:kCLLocationAccuracyBest block:^(CLLocation *location) {
            [[CCLocation shareInstance] reverseGeocodeLocation:location block:^(CLPlacemark *placemark) {
                NSLog(@"%@,%@,%@",placemark.name,placemark.addressDictionary,placemark.location);
            } fail:^(NSError *error) {
                NSLog(@"反地理编码出错,error: %@",error);
            }];
        } fail:^(NSError *error) {
            
        }];
    }else if (indexPath.row == 10) {
        //查看历史定位
        LocationVC *vc = [[LocationVC alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }else if (indexPath.row == 11) {
        //后台定位低功耗设置
        [[CCLocation shareInstance] delayUpdateLocationWith:10.0 timeout:10.0f];
    }else if (indexPath.row == 12) {
        //取消低功耗设置
        [[CCLocation shareInstance] cancelDelayUpdateLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
