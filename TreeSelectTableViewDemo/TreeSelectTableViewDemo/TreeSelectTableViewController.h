//
//  TreeSelectTableViewController.h
//  TreeSelectTableViewDemo
//
//  Created by lz on 16/6/1.
//  Copyright © 2016年 Zen3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.pch"
#import "TreeDataSource.h"
#import "SVProgressHUD.h"

@interface TreeSelectTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    //可展开树形列表
    UITableView *tableViewForTree;
    
    //列表数据
    TreeDataSource *dataSource;

    //返回选中的类别
    void(^getSelectCategor)(NSArray *arrResult);
    
}

- (instancetype) initWithTreeDataSource:(TreeDataSource *)treeDataSource IsSingleSelect:(BOOL)isSingle ResultBlock:(void(^)(NSArray *arrResult))block;
@end
