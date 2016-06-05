//
//  ViewController.m
//  TreeSelectTableViewDemo
//
//  Created by lz on 16/6/1.
//  Copyright © 2016年 Zen3. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSArray *dataSource;

    NSMutableArray *selectedCateArray1;
    NSMutableArray *selectedCateArray2;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"电影分类";
    self.navigationController.navigationBar.tintColor = navigationButonColor;
    selectedCateArray1 = [[NSMutableArray alloc] init];
    selectedCateArray2 = [[NSMutableArray alloc] init];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MovieData" ofType:@"plist"];
    dataSource = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (IBAction)creatSingleSelecteTableView:(id)sender
{
    TreeSelectTableViewController *singleSelecteTableView;
    TreeDataSource *data1;
    
    data1 = [[TreeDataSource alloc] initWithArray:dataSource SelectCategory:selectedCateArray1];
    singleSelecteTableView = [[TreeSelectTableViewController alloc] initWithTreeDataSource:data1 IsSingleSelect:YES ResultBlock:^(NSArray *arrResult){
        
        [selectedCateArray1 removeAllObjects];
        if (arrResult.count == 0)
        {
            [self.label1 setText:@"未选中"];
        }else
        {
            NSDictionary *categoryDic=[arrResult firstObject];
            NSString *selectCategoryID = [categoryDic objectForKey:@"id"];
            NSString *selectCategoryName = [categoryDic objectForKey:@"name"];
            [selectedCateArray1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:selectCategoryID,@"id", nil]];
            [self.label1 setText:selectCategoryName];
        }
    }];
    [self.navigationController pushViewController:singleSelecteTableView animated:YES];
}

- (IBAction)createMultiSelectTableView:(id)sender
{
    TreeSelectTableViewController *multiSelectTableView;
    TreeDataSource *data2;
    
    data2 = [[TreeDataSource alloc] initWithArray:dataSource SelectCategory:selectedCateArray2];
    data2.chooseCount = 3;
    multiSelectTableView  = [[TreeSelectTableViewController alloc] initWithTreeDataSource:data2 IsSingleSelect:NO ResultBlock:^(NSArray *arrResult){
        
        [selectedCateArray2 removeAllObjects];
        if (arrResult.count == 0)
        {
            [self.label2 setText:@"未选中"];
        }else
        {
            NSMutableArray *selectCategoryName = [[NSMutableArray alloc] init];
            for(int i = 0;i < arrResult.count;i++)
            {
                NSDictionary *categoryDic=[arrResult objectAtIndex:i];
                NSString *selectCategoryID = [categoryDic objectForKey:@"id"];
                [selectCategoryName addObject:[categoryDic objectForKey:@"name"]];
                [selectedCateArray2 addObject:[NSDictionary dictionaryWithObjectsAndKeys:selectCategoryID,@"id", nil]];
            }
            
            [self.label2 setText:[selectCategoryName componentsJoinedByString:@","]];
        }
    }];

    [self.navigationController pushViewController:multiSelectTableView animated:YES];
}
@end
