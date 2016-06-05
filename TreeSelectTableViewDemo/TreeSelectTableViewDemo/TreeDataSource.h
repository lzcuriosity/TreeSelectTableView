//
//  DataSource.h
//  TreeSelectTableViewDemo
//
//  Created by lz on 16/6/1.
//  Copyright © 2016年 Zen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefixHeader.pch"

@interface TreeDataSource : NSObject
{
    NSArray *arrTreeDataSource;
    NSMutableDictionary *dicTreeNoteAttributes;
    NSMutableDictionary *dicSelectCates;
    BOOL isInitialize;
    
    
}

//是否是单选 默认是多选
@property (nonatomic,assign) BOOL isSingleSelect;
//可以选择的数量 默认为0 如果为0则不限制
@property (nonatomic,assign) NSInteger chooseCount;


//由数据源数组来初始化
- (instancetype) initWithArray:(NSArray *) arrayDataSource SelectCategory:(NSArray *)arrSelect;
//获取section的数量
- (NSInteger) getSectionsCount;
//根据section获取对应的类的id
- (NSString *) getIdFromSection:(NSInteger)section;
//获取子类的数量 包括子类的子类
- (NSInteger) getSubCategoryCount:(NSString *)categoryId;
//获取类别id 根据section 和row 获取
-(NSString *) getCateIdForSection:(NSInteger )section Row:(NSInteger )row;
//根据cateId获取dictValue
- (NSDictionary *)getDicValueFromCateId:(NSString *)cateId;
//获取类别的层级 最顶层返回0 否则每隔一层+1
- (NSInteger) getGradeForCell:(NSString *)strCateId;
//改变选择状态 多选超出范围回调提醒
-(void) setCategorySelectState:(NSString *)strCateId OverChooseCountBlock:(void(^)(NSString *info))block;
//遍历 查询哪个类别被选择 并且是最底层类别
-(NSArray *) getSelectedArray;
@end
