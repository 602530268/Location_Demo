//
//  ViewController.m
//  Location_Demo
//
//  Created by chencheng on 2018/1/23.
//  Copyright © 2018年 double chen. All rights reserved.
//

#import "ViewController.h"
#import "CCLocation.h"

static NSString *cellIdentifier = @"cellIdentifier";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataSource;
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
                    @"停止获取定位",
                    @"获取指南针信息",
                    @"停止获取指南针信息",
                    @"地理编码",
                    @"反地理编码",].mutableCopy;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[CCLocation shareInstance] requestPermission];
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
        //停止获取定位
        [[CCLocation shareInstance] stopUpdateLocaiton];
    }else if (indexPath.row == 5) {
        //获取指南针信息
        [[CCLocation shareInstance] updateHeadingToBlock:^(CGFloat heading) {
           NSLog(@"指南针指向: %f",heading);
        }];
    }else if (indexPath.row == 6) {
        //停止获取指南针信息
        [[CCLocation shareInstance] stopUpdateHeading];
    }else if (indexPath.row == 7) {
        //地理编码
        [[CCLocation shareInstance] updateLocationWithDesiredAccuracy:kCLLocationAccuracyBest block:^(CLLocation *location) {
            [[CCLocation shareInstance] geocodeAddressString:@"深圳市" block:^(CLPlacemark *placemark) {
                NSLog(@"%@,%@,%@",placemark.name,placemark.addressDictionary,placemark.location);
            } fail:^(NSError *error) {
                NSLog(@"地理编码出错,error: %@",error);
            }];
        } fail:^(NSError *error) {
            
        }];
    }else if (indexPath.row == 8) {
        //反地理编码
        [[CCLocation shareInstance] updateLocationWithDesiredAccuracy:kCLLocationAccuracyBest block:^(CLLocation *location) {
            [[CCLocation shareInstance] reverseGeocodeLocation:location block:^(CLPlacemark *placemark) {
                NSLog(@"%@,%@,%@",placemark.name,placemark.addressDictionary,placemark.location);
            } fail:^(NSError *error) {
                NSLog(@"反地理编码出错,error: %@",error);
            }];
        } fail:^(NSError *error) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
