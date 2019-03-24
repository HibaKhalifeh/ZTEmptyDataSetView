//
//  UIScrollView+HibaEmptyDataSet.h
//  MedSolace
//
//  Created by Hiba Khalifah on 3/11/19.
//  Copyright © 2019 ZetaTech Solutions All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZTEmptyDataSetSource <NSObject>

@optional

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView;
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView;
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView;
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView;
- (BOOL)emptyDataSet:(UIScrollView *)scrollView enableEmptyDataSetButton:(UIButton *)button;

@end

@protocol ZTEmptyDataSetDelegate <NSObject>

@optional

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button;
- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

@end

@interface UIScrollView (ZTEmptyDataSet)

@property (nonatomic, nullable, weak) IBOutlet id <ZTEmptyDataSetSource> emptyDataSetSource;
@property (nonatomic, nullable, weak) IBOutlet id <ZTEmptyDataSetDelegate> emptyDataSetDelegate;

- (void)reloadEmptyDataSet;

@end
NS_ASSUME_NONNULL_END
