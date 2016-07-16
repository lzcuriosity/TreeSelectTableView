
## 摘要
给大家分享一个自己写的基于UITableView的多级下拉选择列表（树形选择列表），支持到4级拓展，可多选、单选。

## 先上效果图吧

![](http://zen3-blog.oss-cn-shenzhen.aliyuncs.com/%E5%9F%BA%E4%BA%8EUITableView%E7%9A%84%E5%A4%9A%E7%BA%A7%E4%B8%8B%E6%8B%89%E9%80%89%E6%8B%A9%E5%88%97%E8%A1%A8/show.gif)

## 使用
### 导入头文件

```objc
#import"Header.h"
```
### 导入数据的格式要求
像上面的电影分类的数据格式如下:

![](http://zen3-blog.oss-cn-shenzhen.aliyuncs.com/%E5%9F%BA%E4%BA%8EUITableView%E7%9A%84%E5%A4%9A%E7%BA%A7%E4%B8%8B%E6%8B%89%E9%80%89%E6%8B%A9%E5%88%97%E8%A1%A8/data.png)

所有的电影以树形的格式存储，本质是一个 **NSArray**.

**NSArray** 里的每一个对象都是一个 **NSDictionary**.

 每个 **NSDictionary** 都包含以下3个对象：
 
 - key：（NSString *）id （每一个分类的唯一标识符，必须存在）
 - key：（NSString *）name （分类的名称）
 - key：（NSArray *）subCategory （分类的子类数组，它的数据和上面的 **NSArray** 相同，也就是循环嵌套来实现子类也有自己的子类）

可以想我在Demo里一样，将电影的数据先存为 **.plist** 文件。也可以手动代码去生成。

### 生成下拉列表

详细代码见demo
#### 单选

```objc
	TreeSelectTableViewController *singleSelecteTableView;
    TreeDataSource *data1;   
    data1 = [[TreeDataSource alloc] initWithArray:dataSource SelectCategory:selectedCateArray1];
    singleSelecteTableView = [[TreeSelectTableViewController alloc] initWithTreeDataSource:data1 IsSingleSelect:YES ResultBlock:^(NSArray *arrResult{			//处理回调的选择结果arrResult
        }
    }];
```

#### 多选

```objc
	TreeSelectTableViewController *multiSelectTableView;
    TreeDataSource *data2;
    
    data2 = [[TreeDataSource alloc] initWithArray:dataSource SelectCategory:selectedCateArray2];
    data2.chooseCount = 3;
    multiSelectTableView  = [[TreeSelectTableViewController alloc] initWithTreeDataSource:data2 IsSingleSelect:NO ResultBlock:^(NSArray *arrResult){
        //处理回调的选择结果arrResult
    }];
```

### 关于样式的修改
- 目前版本不支持修改 cell 的 height ，如果需要改动可能需要自己修改源码。
- 在 image 目录下，可以自行替换图标。
- 关于数据源关键字的修改可以直接在 **PrefixHeader.pch** 文件下替换。

## 源码解析

model 目录下的 TreeDataSource 是做主要的数据操作。

controlller 目录下的 TreeSelectTableViewController 是根据 TreeDataSource 来控制列表控件。

目前可支持到4级目录的下拉，如果想支持多于4级的列表的，请找到 TreeDataSource.m 文件下的

```objc
//递归获取类别id
-(NSString *)getCateId:(NSArray *)arrSub Rows:(NSInteger )row;
```
再做添加。

更详细的函数说明，变量说明，我都写在代码注释里面啦啦啦啦~~

## 详情请见我的博客：
http://lzcuriosity.github.io/2016/06/05/源码分享：基于UITableView的多级下拉选择列表/
