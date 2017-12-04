//
//  CCExampleListViewController.m
//  ConfigCenter
//
//  Created by 叫我小贱🤪 on 2017/12/4.
//  Copyright © 2017年 刘健. All rights reserved.
//

#import "CCExampleListViewController.h"
#import "CCExampleViewController.h"
#import "CCAllDataView.h"
#import "CCModelDataView.h"

static NSString * const cellID = @"cellID";

@interface CCExampleListViewController ()

@property (nonatomic, strong) NSArray *exampleControllers;

@end

@implementation CCExampleListViewController

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.title = @"Examples";
    self.exampleControllers = @[
                                [[CCExampleViewController alloc] initWithTitle:@"CCAllDataView" viewClass:CCAllDataView.class],
                                [[CCExampleViewController alloc]
                                 initWithTitle:@"CCModelDataView"
                                 viewClass:CCModelDataView.class]
                                ];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellID];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = self.exampleControllers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = viewController.title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exampleControllers.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = self.exampleControllers[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
