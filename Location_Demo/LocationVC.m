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
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults] valueForKey:@"LocationInfos"];
    _datas = arr.mutableCopy;
    if (_datas == nil) {
         arr = [[NSUserDefaults standardUserDefaults] valueForKey:@"Locations"];
        _datas = arr.mutableCopy;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *info = _datas[indexPath.row];
    
    cell.textLabel.text = @"正在进行地理编码";
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (info[@"address"] != nil) {
        NSLog(@"已进行过地理编码");
        cell.textLabel.text = info[@"address"];
    }else {
        NSLog(@"进行地理编码");
        CGFloat latitude = [info[@"latitude"] floatValue];
        CGFloat longitude = [info[@"longitude"] floatValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        [[CCLocation shareInstance] reverseGeocodeCoordinate:coordinate block:^(CLPlacemark *placemark) {
            NSString *country = placemark.addressDictionary[@"Country"];
            NSString *city = placemark.addressDictionary[@"City"];
            NSString *lines = [placemark.addressDictionary[@"FormattedAddressLines"] lastObject];
            NSString *address = [NSString stringWithFormat:@"%@,%@,%@",country,city,lines];
            NSLog(@"%@",address);
            cell.textLabel.text = address;
            
            NSMutableDictionary *mInfo = info.mutableCopy;
            [mInfo setValue:address forKey:@"address"];
            [_datas replaceObjectAtIndex:indexPath.row withObject:mInfo];
            [[NSUserDefaults standardUserDefaults] setValue:_datas forKey:@"LocationInfos"];
        } fail:^(NSError *error) {
            NSLog(@"地理编码失败: %@",error);
        }];
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
