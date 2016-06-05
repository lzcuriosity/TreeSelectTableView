//
//  DataSource.m
//  TreeSelectTableViewDemo
//
//  Created by lz on 16/6/1.
//  Copyright © 2016年 Zen3. All rights reserved.
//

#import "TreeDataSource.h"

@implementation TreeDataSource


//由数据源数组来初始化
- (instancetype) initWithArray:(NSArray *) arrDataSource SelectCategory:(NSArray *)arrSelect
{
    self = [super init];
    if (self) {
        arrTreeDataSource = arrDataSource;
        isInitialize = YES;
        _isSingleSelect = NO;
        _chooseCount = 0;
        
        dicTreeNoteAttributes = [[NSMutableDictionary alloc] init];
        [self addTreeNoteAttribute:arrDataSource ParentID:@"0"];
        
        if (!dicSelectCates)
        {
            dicSelectCates = [[NSMutableDictionary alloc] init];
        }
        [dicSelectCates removeAllObjects];
        
        for (NSDictionary *dicCate in arrSelect)
        {
            id cateId = GET_OBJECT_OR_NULL([dicCate objectForKey:TREENOTE_ATTRIBUTE_ID_KEY]);
            if (cateId)
            {
                [dicSelectCates setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@",cateId]];
            }
        }
        
        NSArray *arrKeys = [dicSelectCates allKeys];
        for (NSString *strCateId in arrKeys)
        {
            BOOL isSelct = [[dicSelectCates objectForKey:strCateId] boolValue];
            if (isSelct)
            {
                [self setCategorySelectState:strCateId OverChooseCountBlock:nil];
            }
        }

        isInitialize = NO;
    }
    return self;
}

//将树形数组拆分，方便管理
- (void) addTreeNoteAttribute:(NSArray *)arrCates ParentID:(NSString *)parentId
{
    for (int i=0; i<arrCates.count; i++)
    {
        NSDictionary *dicRootNote = GET_OBJECT_OR_NULL([arrCates objectAtIndex:i]);
        
        NSMutableDictionary *dicValue=[[NSMutableDictionary alloc] init];
        //以每个类别的id为key值保存
        NSString *cateId=[NSString stringWithFormat:@"%@",GET_OBJECT_OR_NULL([dicRootNote objectForKey:TREENOTE_ATTRIBUTE_ID_KEY])];
        [dicTreeNoteAttributes setObject:dicValue forKey:cateId];
        
        //保存展开状态 默认不展开
        [dicValue setObject:[NSNumber numberWithBool:NO] forKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY];
        //保存选中 默认不选中
        [dicValue setObject:[NSNumber numberWithBool:NO] forKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY];
        //保存父类别id 以便递归查询父关系
        [dicValue setObject:parentId forKey:TREENOTE_ATTRIBUTE_PARENTID_KEY];
        //保存分类名
        NSString *strName = GET_OBJECT_OR_NULL([dicRootNote objectForKey:TREENOTE_ATTRIBUTE_NAME_KEY]);
        [dicValue setObject:strName?:@"" forKey:TREENOTE_ATTRIBUTE_NAME_KEY];
        
        NSArray *subCate = GET_OBJECT_OR_NULL([dicRootNote objectForKey:TREENOTE_DATASOURCE_SUBCATEGORYS_KEY]);
        
        if (subCate.count>0)
        {
            //保存子类的数量
            [dicValue setObject:[NSNumber numberWithInteger:subCate.count] forKey:TREENOTE_ATTRIBUTE_SUBCOUNT_KEY];
            NSMutableArray *arrSubId=[[NSMutableArray alloc] init];
            ///遍历子类别 筛选id 保存
            for (NSDictionary *dicSub in subCate)
            {
                NSString *subCateID=[NSString stringWithFormat:@"%@",GET_OBJECT_OR_NULL([dicSub objectForKey:TREENOTE_ATTRIBUTE_ID_KEY])];
                [arrSubId addObject:subCateID];
            }
            ///保存子类别id数组
            [dicValue setObject:arrSubId forKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
            
            ///递归调用
            [self addTreeNoteAttribute:subCate ParentID:cateId];
        }
    }
}


//根据cateId获取dictValue
- (NSDictionary *)getDicValueFromCateId:(NSString *)cateId
{
    NSDictionary *dictValue = [dicTreeNoteAttributes objectForKey:cateId];
    return dictValue;
}

//获取section的数量
- (NSInteger) getSectionsCount
{
    return arrTreeDataSource.count;
}

//根据section获取对应的类的id
- (NSString *) getIdFromSection:(NSInteger)section
{
    NSDictionary *dicNote = GET_OBJECT_OR_NULL([arrTreeDataSource objectAtIndex:section]);

    NSString *cateId = [NSString stringWithFormat:@"%@",[dicNote objectForKey:TREENOTE_ATTRIBUTE_ID_KEY]];
    
    return cateId;
}

//获取类别id 根据section 和row 获取
-(NSString *) getCateIdForSection:(NSInteger )section Row:(NSInteger )row
{
    ///首先先拿到根节点id
    NSDictionary *dicDataNote = GET_OBJECT_OR_NULL([arrTreeDataSource objectAtIndex:section]);
    NSString *strRootId = [NSString stringWithFormat:@"%@",GET_OBJECT_OR_NULL([dicDataNote objectForKey:TREENOTE_ATTRIBUTE_ID_KEY])];
    
    NSDictionary *dicRootNote = [dicTreeNoteAttributes objectForKey:strRootId];
    NSArray *arrSub = [dicRootNote objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
    NSString *strCateId = [self getCateId:arrSub Rows:row];
    
    return strCateId;
}

//递归获取类别id
-(NSString *)getCateId:(NSArray *)arrSub Rows:(NSInteger )row
{
    NSInteger count = row;
    NSString *strCateId = nil;
    for (int i = 0; i < arrSub.count; i++)
    {
        NSString *strSubId = [arrSub objectAtIndex:i];
        NSMutableDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strSubId];
        
        ///如果为0则代表刚好对应行的cell
        if (count == 0)
        {
            strCateId = strSubId;
        }
        else
        {
            count--;
            
            BOOL isOpen = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
            if (isOpen)
            {
                NSArray *arrSub1 = [dicNote objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
                
                for (int j = 0; j < arrSub1.count; j++)
                {
                    NSString *strSubId1 = [arrSub1 objectAtIndex:j];
                    NSMutableDictionary *dicNote1=[dicTreeNoteAttributes objectForKey:strSubId1];
                    if (count == 0)
                    {
                        strCateId = strSubId1;
                    }
                    else
                    {
                        count --;
                        
                        BOOL isOpen1 = [[dicNote1 objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
                        if (isOpen1) {
                            NSArray *arrSub2 = [dicNote1 objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
                            for (int n = 0; n < arrSub2.count; n++)
                            {
                                NSString *strSubId2 = [arrSub2 objectAtIndex:n];
                                NSMutableDictionary *dicNote2=[dicTreeNoteAttributes objectForKey:strSubId2];
                                if (count == 0)
                                {
                                    strCateId = strSubId2;
                                }
                                else
                                {
                                    count--;
                                    BOOL isOpen2 = [[dicNote2 objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
                                    if (isOpen2) {
                                        NSArray *arrSub3 = [dicNote2 objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
                                        for (int m = 0; m < arrSub3.count; m++)
                                        {
                                            NSString *strSubId3=[arrSub3 objectAtIndex:m];
                                            if (count == 0) {
                                                strCateId = strSubId3;
                                            }
                                            else
                                            {
                                                
                                            }
                                            if (strCateId)
                                            {
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (strCateId)
                                {
                                    break;
                                }
                            }
                        }
                    }
                    if (strCateId)
                    {
                        break;
                    }
                }
            }
        }
        
        if (strCateId)
        {
            break;
        }
    }
    
    return strCateId;

}
//获取子类的数量 包括子类的子类
- (NSInteger) getSubCategoryCount:(NSString *)categoryId
{
    NSInteger rowCount = 0;
    NSMutableDictionary *dicOneNote = [dicTreeNoteAttributes objectForKey:categoryId];
    BOOL isOpen=[[dicOneNote objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
    if (isOpen)
    {
        NSArray *arrSub=[dicOneNote objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
        rowCount += arrSub.count;
        //递归计算
        for (NSString *strSubId in arrSub)
        {
            rowCount += [self getSubCategoryCount:strSubId];
        }
    }
    
    return rowCount;
}

///获取类别的层级 最顶层返回0 否则每隔一层+1
- (NSInteger) getGradeForCell:(NSString *)strCateId
{
    NSMutableDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strCateId];
    NSInteger grade = 0;
    NSString *strParentId = [dicNote objectForKey:TREENOTE_ATTRIBUTE_PARENTID_KEY];
    return [self getGrade:strParentId Grade:grade];
}

//递归判断类别的层级 最顶层返回0 每隔一级+1
- (NSInteger) getGrade:(NSString *)strCateId Grade:(NSInteger )grade
{
    NSInteger iGrade = grade;
    NSMutableDictionary *dicParentNote = [dicTreeNoteAttributes objectForKey:strCateId];
    NSString *strParentId = [dicParentNote objectForKey:TREENOTE_ATTRIBUTE_PARENTID_KEY];
    if (strParentId && ![strParentId isEqualToString:@"0"])
    {
        iGrade++;
        iGrade = [self getGrade:strParentId Grade:iGrade];
    }
    return iGrade;
}

//获取父类的id
-(NSString *)getParentId:(NSString *)strCateId
{
    NSMutableDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strCateId];
    NSString *strParentId =[dicNote objectForKey:TREENOTE_ATTRIBUTE_PARENTID_KEY];
    return strParentId;
}

//改变父类别的选中状态
-(BOOL)setParentSelectState:(NSString *)strParentId SelectState:(BOOL)selectState
{
    NSMutableDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strParentId];
    BOOL isSelect = NO;
    //如果是去掉选择 则判断是否还有其他子类选中
    if (!selectState)
    {
        NSArray *arrSubIds = [dicNote objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
        
        for (NSString *strSubId in arrSubIds)
        {
            NSMutableDictionary *dicSubNote = [dicTreeNoteAttributes objectForKey:strSubId];
            BOOL isSubSelect = [[dicSubNote objectForKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY] boolValue];
            if (isSubSelect)
            {
                isSelect=isSubSelect;
                break;
            }
        }
        //如果都没有子类别被选中才去掉选中
        if (!isSelect)
        {
            [dicNote setObject:[NSNumber numberWithBool:isSelect] forKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY];
        }
    }
    else
    {
        [dicNote setObject:[NSNumber numberWithBool:selectState] forKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY];
    }
    
    return YES;
}

//改变选择状态 多选超出范围回调提醒
-(void) setCategorySelectState:(NSString *)strCateId OverChooseCountBlock:(void(^)(NSString *info))block
{
    NSMutableDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strCateId];
    NSInteger subCount = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_SUBCOUNT_KEY] integerValue];
    
    //判断子类别数量 来判断是否是最底层
    if (subCount <= 0)
    {
        
        BOOL isSelect = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY] boolValue];
        isSelect = !isSelect;
        
        //先判断选择的数量，上限以内才允许选择
        if (isSelect && _chooseCount != 0)
        {
            NSInteger currentCount = 0;
            NSArray *arrKeys = [dicSelectCates allKeys];
            
            //遍历 查询哪个类别被选择 并且是最底层类别
            for (NSString *strCateId in arrKeys)
            {
                BOOL isSelect = [[dicSelectCates objectForKey:strCateId] boolValue];
                NSDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strCateId];
                if (dicNote)
                {
                    NSArray *arrSub = [[dicTreeNoteAttributes objectForKey:strCateId] objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
                    if (isSelect && arrSub.count <= 0)
                    {
                        currentCount++;
                    }
                }
            }
            //超过则不允许点击
            if (_chooseCount != 0 && currentCount >= _chooseCount)
            {
                NSString *info = [NSString stringWithFormat:@"只能选择%d个分类，请重新选择哦",(int)_chooseCount];
                block(info);
                return;
            }
        }
        
        //改变选择状态
        [dicNote setObject:[NSNumber numberWithBool:isSelect] forKey:TREENOTE_ATTRIBUTE_SELECTSTATE_KEY];
        NSString *strParentId = strCateId;
        
        //顺便改变相对应的父节点选择状态
        while (![[self getParentId:strParentId] isEqualToString:@"0"])
        {
            strParentId = [self getParentId:strParentId];
            [self setParentSelectState:strParentId SelectState:isSelect];
            if (strParentId)
            {
                NSMutableDictionary *dicParent = [dicTreeNoteAttributes objectForKey:strParentId];
                [dicParent setObject:[NSNumber numberWithBool:YES] forKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY];
            }
            
        }
        
        //如果是单选则选中最后一级时自动返回
        if (_isSingleSelect && !isInitialize)
        {
            [dicSelectCates removeAllObjects];
            //保存选中类别的集合
            [dicSelectCates setObject:[NSNumber numberWithBool:YES] forKey:strCateId];
            block(nil);
        }
        else
        {
            //保存选中类别的集合
            [dicSelectCates setObject:[NSNumber numberWithBool:isSelect] forKey:strCateId];
        }
    }
    else
    {
        BOOL isOpen = [[dicNote objectForKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY] boolValue];
        isOpen =! isOpen;
        [dicNote setObject:[NSNumber numberWithBool:isOpen] forKey:TREENOTE_ATTRIBUTE_OPENSTATE_KEY];
    }
}
//遍历 查询哪个类别被选择 并且是最底层类别
-(NSArray *) getSelectedArray
{
    NSMutableArray *arrSelect = [[NSMutableArray alloc] init];
    NSArray *arrKeys = [dicSelectCates allKeys];
    
    for (NSString *strCateId in arrKeys)
    {
        BOOL isSelect = [[dicSelectCates objectForKey:strCateId] boolValue];
        NSDictionary *dicNote = [dicTreeNoteAttributes objectForKey:strCateId];
        if (dicNote)
        {
            NSArray *arrSub = [[dicTreeNoteAttributes objectForKey:strCateId] objectForKey:TREENOTE_ATTRIBUTE_SUBIDS_KEY];
            if (isSelect&&arrSub.count <= 0)
            {
                NSMutableDictionary *dicCate = [[NSMutableDictionary alloc] init];
                [dicCate setObject:strCateId forKey:TREENOTE_ATTRIBUTE_ID_KEY];
                NSString *strName = [[dicTreeNoteAttributes objectForKey:strCateId] objectForKey:TREENOTE_ATTRIBUTE_NAME_KEY];
                [dicCate setObject:strName?:@"" forKey:TREENOTE_ATTRIBUTE_NAME_KEY];
                [arrSelect addObject:dicCate];
            }
        }
    }
    return arrSelect;
}


@end
