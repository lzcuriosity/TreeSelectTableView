//
//  TreeSelectTableViewController.m
//  TreeSelectTableViewDemo
//
//  Created by lz on 16/6/1.
//  Copyright © 2016年 Zen3. All rights reserved.
//

#import "TreeSelectTableViewController.h"

@interface TreeSelectTableViewController ()

@end

@implementation TreeSelectTableViewController

- (instancetype) initWithTreeDataSource:(TreeDataSource *)treeDataSource IsSingleSelect:(BOOL)isSingle ResultBlock:(void(^)(NSArray *arrResult))block
{
    self = [super init];
    if (self)
    {
        
        dataSource = treeDataSource;
        dataSource.isSingleSelect = isSingle;
        getSelectCategor = nil;
        getSelectCategor = [block copy];
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
    
}

- (void) buildUI
{
    //如果可以多选 则显示确定按钮
    if(!dataSource.isSingleSelect)
    {
        UIBarButtonItem *barConfirmSelect = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(click_ConfirmSelect:)];
        barConfirmSelect.tintColor = navigationButonColor;
        self.navigationItem.rightBarButtonItem = barConfirmSelect;
    }
    
    //树形列表
    tableViewForTree = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    tableViewForTree.dataSource = self;
    tableViewForTree.delegate = self;
    
    [self.view addSubview:tableViewForTree];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource getSectionsCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    NSString *cateId = [dataSource getIdFromSection:section];
    rowCount = [dataSource getSubCategoryCount:cateId];
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell = @"cell";
    UITableViewCell *cell = [tableViewForTree dequeueReusableCellWithIdentifier:strCell];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        
        ///前选择框图片
        UIImageView *imgSelect = [[UIImageView alloc] initWithFrame:CGRectMake(50, 11, 20, 20)];
        imgSelect.tag = 10;
        [cell.contentView addSubview:imgSelect];
        
        ///节点文本
        UILabel *lblNote = [[UILabel alloc] initWithFrame:CGRectMake(65, 6, self.view.frame.size.width - 100, 20)];
        lblNote.tag = 11;
        lblNote.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblNote];
        
        //下拉显示列表的图片
        UIImageView *imgAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 31, 17, 16, 9)];
        imgAccessory.tag = 12;
        cell.accessoryView = imgAccessory;
        cell.backgroundColor = tableViewBackgroungColor;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.section;
    
    NSString *strCateId = [dataSource getCateIdForSection:indexPath.section Row:indexPath.row];
    NSDictionary *dicNote = [dataSource getDicValueFromCateId:strCateId];
    
    BOOL isOpen = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
    BOOL isSelect = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY] boolValue];
    NSInteger subCount = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_SUBCOUNT_KEY] integerValue];
    
    ///获取层级关系
    NSInteger grade = [dataSource getGradeForCell:strCateId];
    
    UIImageView *imgSelect = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *lblNote = (UILabel *)[cell.contentView viewWithTag:11];
    
    UIImageView *imgAccessory = (UIImageView *)cell.accessoryView;
    imgSelect.image = [UIImage imageNamed:@"boxyCheckNot"];
    
    if (isSelect)
    {
        imgSelect.image = [UIImage imageNamed:@"boxyCheckSelect"];
    }
    
    lblNote.text = [dicNote objectForKey:TREENOTE_ATTRIBUTE_NAME_KEY];
    
    //缩进宽度
    CGFloat indentionWidth = 50 + 35 * grade;
    imgSelect.frame = CGRectMake(indentionWidth, 11, 20, 20);
    
    //根据打开状态右边图片显示不同
    if (isOpen)
    {
        imgAccessory.image = [UIImage imageNamed:@"dropMenuSelect"];
    }
    else
    {
        imgAccessory.image = [UIImage imageNamed:@"dropMenuNot"];
    }
    //如果是最底层则隐藏右边图片
    imgAccessory.hidden = YES;
    if (subCount > 0)
    {
        imgAccessory.hidden = NO;
    }
    
    [cell setSeparatorInset:(UIEdgeInsetsMake(0, imgSelect.frame.origin.x, 0, 0))];
    
    lblNote.frame = CGRectMake(indentionWidth + 35, 11, self.view.frame.size.width - indentionWidth - 70,20);

    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 44;
    }
    return 43;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *strCateId = [dataSource getIdFromSection:section];
    NSDictionary *dicNote = [dataSource getDicValueFromCateId:strCateId];
    
    BOOL isOpen = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
    BOOL isSelect = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY] boolValue];
    NSInteger subCount = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_SUBCOUNT_KEY] integerValue];
    
    UIButton *btnHeader = [UIButton buttonWithType:UIButtonTypeCustom];
    btnHeader.frame = CGRectMake(0, 1, self.view.frame.size.width, section == 0?42:41);
    btnHeader.backgroundColor = [UIColor whiteColor];
    [btnHeader addTarget:self action:@selector(click_NoteHeader:) forControlEvents:UIControlEventTouchUpInside];
    btnHeader.tag = section;
    
    UIImageView *imgSelect = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 20, 20)];
    NSString *strSelectImgName = nil;
    if (isSelect)
    {
        strSelectImgName = @"pointCheckSelect";
    }
    else
    {
        strSelectImgName = @"pointCheckNot";
    }
    
    imgSelect.image = [UIImage imageNamed:strSelectImgName];
    imgSelect.tag = 10;
    [btnHeader addSubview:imgSelect];
    
    UILabel *lblNote = [[UILabel alloc] initWithFrame:CGRectMake(50, 11, self.view.frame.size.width - 85, 20)];
    lblNote.backgroundColor = [UIColor clearColor];
    
    NSString *strNoteText = GET_OBJECT_OR_NULL([dicNote objectForKey:TREENOTE_ATTRIBUTE_NAME_KEY]);
    lblNote.text = strNoteText;
    lblNote.tag = 11;
    [btnHeader addSubview:lblNote];
    
    ///下拉显示列表的图片
    UIImageView *imgAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 31, 17, 16, 9)];
    imgAccessory.tag = 12;
    
    ///根据打开状态右边图片显示不同
    if (isOpen)
    {
        imgAccessory.image = [UIImage imageNamed:@"dropMenuSelect"];
    }
    else
    {
        imgAccessory.image = [UIImage imageNamed:@"dropMenuNot"];
    }
    
    ///如果是最底层则隐藏右边图片
    imgAccessory.hidden = YES;
    if (subCount>0)
    {
        imgAccessory.hidden = NO;
    }
    
    [btnHeader addSubview:imgAccessory];
    imgSelect = nil;
    lblNote = nil;
    imgAccessory = nil;
    return btnHeader;
}




-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //避免block的循环引用
    __weak typeof(self) weakSelf = self;
    NSString *strCateId= [dataSource getCateIdForSection:indexPath.section Row:indexPath.row];
    [dataSource setCategorySelectState:strCateId OverChooseCountBlock:^(NSString *info){
        
        if (!info)
        {
            [weakSelf click_ConfirmSelect:nil];
        }else
        {
            [SVProgressHUD showErrorWithStatus:info];
        }
       
    }];
    [tableViewForTree reloadData];
}

#pragma mark - 点击事件
//确定选择按钮
- (void) click_ConfirmSelect:(id)sender
{
    NSArray *arrSelect = [dataSource getSelectedArray];
    if (getSelectCategor)
    {
        getSelectCategor(arrSelect);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//类别的头点击事件
-(void)click_NoteHeader:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UIButton *btnHeader = (UIButton *)sender;
    NSString *strCateId = [dataSource getIdFromSection:btnHeader.tag];
    [dataSource setCategorySelectState:strCateId OverChooseCountBlock:^(NSString *info){
        if (!info)
        {
            [weakSelf click_ConfirmSelect:nil];
        }else
        {
            [SVProgressHUD showErrorWithStatus:info];
        }
    }];
    [tableViewForTree reloadData];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
