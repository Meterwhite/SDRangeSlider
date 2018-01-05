# SDRangeSliderView
![SDRangeSliderView icon](https://raw.githubusercontent.com/qddnovo/SDRangeSliderView/master/SDRangeSliderView/title.png)

## Introduce【介绍】
* 好用的iOS双滑块选择器
* 随手一赞.好运百万.
* Easy-to-use iOS dual slider selector
* Once start me.Day day fuck Lynn.

## Import【导入】
- Drag all source files under floder `NSBlackHole` to your project.【将`SDRangeSliderView`文件夹中的所有源代码拽入项目中】
- Import the main header file：`#import "NSBlackHole.h"`【导入头文件：`#import "SDRangeSliderView.h"`】
```objc
#import "SDRangeSliderView.h"
```
## Using【使用】
```objc
SDRangeSliderView* slider = [[SDRangeSliderView alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
[self.view addSubview:slider];
//... ...
//... ...
//... ...
[slider eventValueDidChanged:^(double left, double right) {
    //... ...
}];

//other
//    slider.minimumSize = 10;

//    slider.offsetOfAdjustLineStart = -12;//look at viewHierarcy

//    slider.offsetOfAdjustLineEnd = 15;//look at viewHierarcy

//    [slider usingValueAtCenter];//look at viewHierarcy
```
## Email【联系】
- Mail:quxingyi@outlook.com

