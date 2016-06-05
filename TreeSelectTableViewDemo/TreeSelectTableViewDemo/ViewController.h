//
//  ViewController.h
//  TreeSelectTableViewDemo
//
//  Created by lz on 16/6/1.
//  Copyright © 2016年 Zen3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"Header.h"

@interface ViewController : UIViewController

- (IBAction)creatSingleSelecteTableView:(id)sender;
- (IBAction)createMultiSelectTableView:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

