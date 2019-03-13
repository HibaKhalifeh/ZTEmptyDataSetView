//
//  UIScrollView+HibaEmptyDataSet.h
//  MedSolace
//
//  Created by Hiba Khalifah on 3/11/19.
//  Copyright © 2019  ZetaTech Solutions. All rights reserved.
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

@end

@interface UIScrollView (ZTEmptyDataSet)

@property (nonatomic, nullable) id <ZTEmptyDataSetSource> emptyDataSetSource;

- (void)reloadEmptyDataSet;

@end

NS_ASSUME_NONNULL_END
