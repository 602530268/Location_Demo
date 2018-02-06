//
//  LocationVC.m
//  Location_Demo
//
//  Created by chencheng on 2018/1/31.
//  Copyright © 2018年 double chen. All rights reserved.
//

#import "LocationVC.h"
#import "CCLocation.h"

static NSString *cellIdentifier = @"cellIdentifier";

@interface LocationVC ()<UITableViewDataSource>
{
    NSMutableArray *_datas;
}

@property(nonatomic,strong) UITableView *tableView;

@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_tableView];
    _tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 400);
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults] valueForKey:@"Locations"];
    _datas = @[].mutableCopy;
    for (NSDictionary *info in arr) {
        NSTimeInterval time = [info[@"time"] floatValue];
        BOOL add = YES;
        for (NSDictionary *dic in _datas) {
            NSTimeInterval dTime = [dic[@"time"] floatValue];
            if (fabs(dTime - time) < 1.0f) {
                add = NO;
                break;
            }
        }
        if (add) {
            [_datas addObject:info];
        }
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    NSDictionary *info = _datas[indexPath.row];
    
    cell.textLabel.text = @"正在进行地理编码";
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-hh-dd HH:mm:ss"];
    
    if (info[@"address"] != nil) {
        NSLog(@"已进行过地理编码");
        cell.textLabel.text = info[@"address"];
        
        NSTimeInterval time = [info[@"time"] floatValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    }else {
        NSLog(@"进行地理编码");
        CGFloat latitude = [info[@"coordinate"][@"latitude"] floatValue];
        CGFloat longitude = [info[@"coordinate"][@"longitude"] floatValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        dispatch_queue_t serial = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
        dispatch_async(serial, ^{
            [[CCLocation shareInstance] reverseGeocodeCoordinate:coordinate block:^(CLPlacemark *placemark) {
                NSString *country = placemark.addressDictionary[@"Country"];
                NSString *city = placemark.addressDictionary[@"City"];
                NSString *lines = [placemark.addressDictionary[@"FormattedAddressLines"] lastObject];
                NSString *address = [NSString stringWithFormat:@"%@,%@,%@",country,city,lines];
                NSLog(@"%@",address);
                
                NSTimeInterval time = [info[@"time"] floatValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.textLabel.text = address;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
                });
                
                NSMutableDictionary *mInfo = info.mutableCopy;
                [mInfo setValue:address forKey:@"address"];
                [_datas replaceObjectAtIndex:indexPath.row withObject:mInfo];
                [[NSUserDefaults standardUserDefaults] setValue:_datas forKey:@"Locations"];
            } fail:^(NSError *error) {
                NSLog(@"地理编码失败: %@",error);
            }];
        });

    }
    
    return cell;
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
