//
//  CustomImgsView.m
//  ExchangeDemo
//
//  Created by apple on 2020/2/21.
//  Copyright © 2020 apple. All rights reserved.
//

#import "CustomImgsView.h"

@interface CustomImgsView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *imgsView;

@property (nonatomic, assign) CGFloat leftX;

//图片控件数组
@property (nonatomic, strong) NSMutableArray *subViewsArray;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

//长按选中移动中的icon
@property (nonatomic, strong) UIImageView *movingIcon;

//存储UIImage的数组。显示原则：高度固定 168*ScaleX，宽不固定
@property (nonatomic, strong) NSMutableArray *imageClassArray;

//点击手势相对于imgsView的point
@property(nonatomic, assign)CGPoint longPressPrePointInView;

//当前选中的图片数据：UIImage、NSString
@property (nonatomic, strong) id selectedObject;
//长按选中的Index
@property (nonatomic, assign) NSInteger startIndex;

@end
@implementation CustomImgsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        _leftX = 20;
        
        _imgsView = [[UIScrollView alloc] init];
        [self addSubview:_imgsView];
        _imgsView.showsHorizontalScrollIndicator = NO;
        [_imgsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(168);
        }];

        _imgsView.backgroundColor = [UIColor orangeColor];
        
        _imgsView.userInteractionEnabled = YES;

        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
        gesture.minimumPressDuration = 0;
        [_imgsView addGestureRecognizer:gesture];
        
    }
    return self;
}
- (void)setImgsArray:(NSMutableArray *)imgsArray
{
    _imgsArray = imgsArray;
    
    [_imgsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _subViewsArray = [NSMutableArray array];
    _imageClassArray = [NSMutableArray arrayWithArray:imgsArray];
    
    UIView *lastView = nil;
    for (int i = 0; i < imgsArray.count; i++) {
        
        UIImageView *icon = [[UIImageView alloc] init];
        [_imgsView addSubview:icon];
        icon.tag = i;
        [_subViewsArray addObject:icon];
        id object = imgsArray[i];
        UIImage *image;
        if ([object isKindOfClass:[UIImage class]]) {
            image = object;
            icon.image = image;
            [_imageClassArray replaceObjectAtIndex:i withObject:image];
        }else if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *dic = object;
//            NSURL *url = [NSURL URLWithString:dic[@"url"]];
//            WS(weakSelf);
//            [icon sd_setImageWithURL:url placeholderImage:DefaultImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                CGFloat imgWidth = image.size.width/image.size.height * 168*ScaleX;
//                [icon mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.width.mas_equalTo(imgWidth);
//                }];
//                [weakSelf.imageClassArray replaceObjectAtIndex:i withObject:image];
//            }];
        }else if ([object isKindOfClass:[NSString class]]){
            image = [UIImage imageNamed:object];
            icon.image = image;
            [_imageClassArray replaceObjectAtIndex:i withObject:image];
        }
        
        icon.layer.cornerRadius = 24;
        icon.layer.masksToBounds = YES;
            
        CGFloat imgWidth = 80;
        if (image) {
            imgWidth = image.size.width/image.size.height * 168;
        }
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastView ? lastView.mas_right:_imgsView).offset(lastView ? 8:_leftX);
            make.height.mas_equalTo(168);
            if (image) {
                make.width.mas_equalTo(imgWidth);
            }
            make.top.equalTo(_imgsView);
        }];
        
        lastView = icon;
        
          icon.userInteractionEnabled = YES;
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"publish_delete"] forState:UIControlStateNormal];
        
      [icon addSubview:btn];
      [btn mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.bottom.equalTo(icon);
          make.width.height.mas_equalTo(50);
      }];
      btn.tag = i;
      [btn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchDown];
      
    }
    
    [_imgsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lastView.mas_right).offset(16);
    }];
     
}

- (void)deleteAction:(UIButton *)btn
{
    [_imgsArray removeObjectAtIndex:btn.tag];
    [self  imgsArray];
}

#pragma mark - 交换处理
-(void)longPressGestureAction:(UILongPressGestureRecognizer *)longGesture{
    
    if(_imgsArray.count <= 1)return;
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        [self longPressGestureActionBegin:longGesture];
    }
    else if(longGesture.state == UIGestureRecognizerStateChanged){
       [self longPressGestureActionChange:longGesture];
    }
    else if(longGesture.state == UIGestureRecognizerStateEnded ||
            longGesture.state == UIGestureRecognizerStateCancelled ){
       [self longPressGestureActionEnd:longGesture];
    }
}

-(void)longPressGestureActionBegin:(UILongPressGestureRecognizer *)longGesture{
    if(_imgsArray.count <= 1)return;
    for (UIImageView *icon in _subViewsArray) {
    //        避免和删除按钮事件冲突
            icon.userInteractionEnabled = NO;
    }
    
    CGPoint p = [longGesture locationInView:self.imgsView];
    
    CGFloat pointX = p.x;
    
    NSInteger index = -1;
    
    CGFloat imgsX = _leftX;
    for (int i = 0; i < _imageClassArray.count; i++) {
        UIImage *image = _imageClassArray[i];
        CGFloat imgWidth = image.size.width/image.size.height * 168;
        CGFloat endX = imgWidth+imgsX;
        if (pointX <= endX && pointX > imgsX) {
            index = i;
            break;
        }
        imgsX = endX;
    }
    
    if (index < 0) {
        return;
    }
    _movingIcon = [_subViewsArray objectAtIndex:index];
    [_imgsView bringSubviewToFront:_movingIcon];
    self.longPressPrePointInView = p;
    _startIndex = index;
    
//    此处代码是把选中的view放在window上，便于识别，可不用
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    CGRect rect = [_movingIcon convertRect:_movingIcon.bounds toView:window];
//
//    self.selectedView = [[SelectedImgView alloc] init];
//    self.selectedView.imgView.image = _imageClassArray[index];
//    [window addSubview:self.selectedView];
//    self.selectedView.frame = CGRectMake(rect.origin.x-10*ScaleX, rect.origin.y-10*ScaleX, rect.size.width+20*ScaleX, rect.size.height+20*ScaleX);
}

-(void)longPressGestureActionChange:(UILongPressGestureRecognizer *)longGesture{
    if(_imgsArray.count <= 1 || self.movingIcon == nil)return;
    
    CGPoint pointInView = [longGesture locationInView:self.imgsView];
//    只有左右滑动。y = 0
    CGPoint translate = CGPointMake(pointInView.x - self.longPressPrePointInView.x, 0);

    self.longPressPrePointInView = pointInView;
    CGRect frame = self.movingIcon.frame;
    frame.origin.x += translate.x;
    frame.origin.y += translate.y;
    self.movingIcon.frame = frame;
    
    NSLog(@"movingIcon.x+++++++++++++++%f---%f----%f",  frame.origin.x+frame.size.width, [UIScreen mainScreen].bounds.size.width, _imgsView.contentOffset.x);
//    以下代码处理如果移动的图片超出屏幕范围，底部图片自动滑动一个屏幕宽, n不成熟，需要更改
//    CGFloat leftValue = frame.origin.x + frame.size.width;
    
//    if (leftValue > _imgsView.contentOffset.x+mainWidth) {
//        CGFloat offsetWidth = _imgsView.contentOffset.x+mainWidth/2;
////        滑动不能超出_imgsView的所有图片的宽度+间隙的和，即imgsView.contentSize.width
//        if (offsetWidth > _imgsView.contentSize.width) {
//            offsetWidth = _imgsView.contentSize.width;
//        }
//        [_imgsView setContentOffset:CGPointMake(translate.x, 0) animated:NO];
//    }
}

-(void)longPressGestureActionEnd:(UILongPressGestureRecognizer *)longGesture{
    if(self.imgsArray.count <= 1 || self.movingIcon == nil)return;
    // 交换
//imgsArray数组中有UIImage类型也有NSString类型
    id mode1;
    id mode2;
    
    NSInteger index1 = self.startIndex;
    NSInteger index2 = -1;
        
    CGPoint p = [longGesture locationInView:self.imgsView];
    
    CGFloat pointX = p.x;
    
    CGFloat imgsX = _leftX;
    for (int i = 0; i < _imageClassArray.count; i++) {
        UIImage *image = _imageClassArray[i];
        CGFloat imgWidth = image.size.width/image.size.height * 168;
        CGFloat endX = imgWidth+imgsX;
        if (pointX <= endX && pointX > imgsX) {
            index2 = i;
            break;
        }
        imgsX = endX;
    }
    
    if (index2 < 0) {
        [self setImgsArray:_imgsArray];
        return;
    }
    if (index1 < self.imgsArray.count) {
        mode1 = [self.imgsArray objectAtIndex:index1]; //点击了，移动的model
    }
    if (index2 < self.imgsArray.count) {
        mode2 = [self.imgsArray objectAtIndex:index2]; //紫圈的待交换的model
    }
    
//        移动
//    if (index1 > index2) {
//        //    从后面往前面移动
//        [_imgsArray insertObject:mode1 atIndex:index2];
//        NSInteger index = index1+1;
//        if (index < _imgsArray.count) {
//            [_imgsArray removeObjectAtIndex:index];
//        }
//    }else if (index1 < index2){
////        //    从前面往后面移动
//        [_imgsArray insertObject:mode1 atIndex:index2+1];
//        NSInteger index = index1;
//        if (index < _imgsArray.count) {
//            [_imgsArray removeObjectAtIndex:index];
//        }
//    }
    
//    交换
    [_imgsArray exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
        
    [self setImgsArray:_imgsArray];
    
}


@end
