# BYStateScrollView_Swift
==============

自定义UITableView/UICollectionView为空和刷新的状态

参考 : [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet)

![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

## 要求

* iOS 7.0+
* Xcode 7.0
* Swift 2.0

## 截图

![](byState.gif)


## 用法 

设置UITableView/UICollectionView的数据代理： 

```swift
class SomeTableViewController : UITableViewController , BYStateDataSource,BYStateDelegate{
	override func viewDidLoad() {
		super.viewDidLoad()
    	//...
		tableView.byStateDataSource = self
        tableView.byStateDelegate = self
    	//...
	}
}
```

数据源的实现：

```swift
//设置标题的文本
func byStateTitleAttributedText( scrollView : UIScrollView ) -> NSAttributedString?{
}
//设置具体内容的文本
func byStateDetailAttributedText( scrollView : UIScrollView ) -> NSAttributedString?{
}
//设置图片
func byStateImage( scrollView : UIScrollView ) -> UIImage?{
}
//设置按钮文本
func byStateButtonAttributedText( scrollView : UIScrollView , forState : UIControlState) -> NSAttributedString?{
}
//自定义配置按钮
func byStateCustomButton( scrollView : UIScrollView , button : UIButton?){
}
```

代理的实现：

```swift
//视图的按钮事件的实现
func byStateTapAction (scrollView : UIScrollView ){
}
```

设置视图的 `byState` (`.Loading`,`.Custom`) 来让视图显示不同的状态。

* `tableView.byState = .Loading` : 设置视图在刷新状态（表单的数据必须为空）
* `tableView.byState = .Custom` : 设置视图为自定义配置的状态（表单的数据必须为空）

设置完成之后调用`reloadData`方法去刷新视图。

## Communication

- Found a bug or have a feature request? [Open an issue](https://github.com/sgxiang/BYStateScrollView_Swift/issues).

- Want to contribute? [Submit a pull request](https://github.com/sgxiang/BYStateScrollView_Swift/pulls).

## Author

- [sgxiang](https://twitter.com/sgxiang1992)
