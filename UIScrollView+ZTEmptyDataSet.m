//
//  UIScrollView+HibaEmptyDataSet.m
//  MedSolace
//
//  Created by Hiba Khalifah on 3/11/19.
//  Copyright © 2019 ZetaTech Solutions. All rights reserved.
//

#import "UIScrollView+ZTEmptyDataSet.h"

#pragma mark - EmptyDataSetView
@interface EmptyDataSetView : UIView

@property (nonatomic) UIView *contentView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CGFloat verticalOffset;
@property (nonatomic, strong) UIButton *button;
@end

@implementation EmptyDataSetView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setVerticalOffset:0];
    }
    return self;
}

- (UIView *)contentView {
    
    if (!_contentView) {
        _contentView = [UIView new];
        [_contentView setBackgroundColor:[UIColor clearColor]];
        [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_titleLabel setFont:[UIFont systemFontOfSize:18.0]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_titleLabel setNumberOfLines: 0];
    }
    return _titleLabel;
}

- (UILabel *)descriptionLabel {
    
    if (!_descriptionLabel) {
        _descriptionLabel = [UILabel new];
        [_descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_descriptionLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_descriptionLabel setTextAlignment:NSTextAlignmentCenter];
        [_descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_descriptionLabel setNumberOfLines: 0];
    }
    return _descriptionLabel;
}

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [UIImageView new];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _imageView;
}

- (UIButton *)button {
 
    if (!_button) {
         _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.backgroundColor = [UIColor clearColor];
        [_button setUserInteractionEnabled:YES];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (void)invalidateSubViews {
    _titleLabel = nil;
    _descriptionLabel = nil;
    _imageView = nil;
    _button = nil;
}

- (void)didTapButton:(id)sender {
    SEL selector = NSSelectorFromString(@"zt_didTapButton:");
    if ([self.contentView.superview respondsToSelector:selector]) {
        [self.contentView.superview performSelector:selector withObject:sender afterDelay:0.0f];
    }
}

@end


@interface UIScrollView ()

@property (retain) EmptyDataSetView *emptyDataSetView;

@end

static NSMutableDictionary *implementationLookupTable;
static char const * const ZTEmptyDataSetViewKey = "emptyDataSetView";
static char const * const ZTEmptyDataSetSourceKey = "emptyDataSetSource";
static char const * const ZTEmptyDataSetDelegateKey = "emptyDataSetDelegate";
static NSString * const ZTSwizzleInfoOwnerClassKey = @"ownerClass";
static NSString * const ZTSwizzleInfoSelectorKey = @"selector";
static NSString * const ZTSwizzleInfoPointerKey = @"pointer";


@implementation UIScrollView (ZTEmptyDataSet)

- (void)reloadEmptyDataSet {
    
    NSInteger numberOfSections = 1;
    NSInteger numberOfItems = 0;
    
    // if scroll view does not respond to scroll view
    if (![self respondsToSelector:@selector(dataSource)]) {
        return;
    }
    
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            numberOfSections = [dataSource numberOfSectionsInTableView:tableView];
        }
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            
            for (NSInteger section = 0; section < numberOfSections; section++) {
                numberOfItems += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self                                                                                                                                                                                                    ;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < numberOfSections; section++) {
                numberOfItems += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    [self invalidateEmptyView];
    if (numberOfItems == 0 || numberOfSections == 0) {
        [self setupEmptyDataSetView];
    }
}

#pragma mark - EmptyDataSetSource Accessors

- (id<ZTEmptyDataSetSource>)emptyDataSetSource {
     return objc_getAssociatedObject(self, ZTEmptyDataSetSourceKey);
}

- (void)setEmptyDataSetSource:(id<ZTEmptyDataSetSource>)emptyDataSetSource {
        objc_setAssociatedObject(self, ZTEmptyDataSetSourceKey, emptyDataSetSource , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self swizzleIfPossible:@selector(reloadData)];
        if ([self isKindOfClass:[UITableView class]]) {
            [self swizzleIfPossible:@selector(endUpdates)];
        }
}

#pragma mark - EmptyDataSetDelegate Accessors

- (id<ZTEmptyDataSetDelegate>)emptyDataSetDelegate {
    return objc_getAssociatedObject(self, ZTEmptyDataSetDelegateKey);
}

- (void)setEmptyDataSetDelegate:(id<ZTEmptyDataSetDelegate>)emptyDataSetDelegate {
    objc_setAssociatedObject(self, ZTEmptyDataSetDelegateKey, emptyDataSetDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - EmptyDataSetView Accessors

- (void)setEmptyDataSetView:(EmptyDataSetView *)emptyDataSetView {
    objc_setAssociatedObject(self, ZTEmptyDataSetViewKey, emptyDataSetView , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EmptyDataSetView *)emptyDataSetView {
    return objc_getAssociatedObject(self, ZTEmptyDataSetViewKey);

}

#pragma mark - EmptyDataSetView Setups

- (void)setupEmptyDataSetView {
    EmptyDataSetView *view = [self emptyDataSetView];
    
    if (!view) {
        view = [EmptyDataSetView new];
    }
    
    [self setEmptyDataSetView:view];
    [self addSubview:view.contentView];
    
    if ([self emptyDataSetSource]) {
        
        if ([[self emptyDataSetSource] respondsToSelector:@selector(imageForEmptyDataSet:)]) {
            [[view imageView] setImage:[[self emptyDataSetSource] imageForEmptyDataSet:self]];
            [view.contentView addSubview:view.imageView];
            [self setupImageViewConstraints:view];
        }
        if ([[self emptyDataSetSource] respondsToSelector:@selector(titleForEmptyDataSet:)]) {
            [[view titleLabel] setAttributedText:[[self emptyDataSetSource] titleForEmptyDataSet:self]];
            [view.contentView addSubview:view.titleLabel];
            [self setupTitleLabelConstraints:view];
        }
        if ([[self emptyDataSetSource] respondsToSelector:@selector(descriptionForEmptyDataSet:)]) {
            [[view descriptionLabel] setAttributedText:[[self emptyDataSetSource] descriptionForEmptyDataSet:self]];
            [view.contentView addSubview:view.descriptionLabel];
            [self setupDescriptionLabelConstraints:view];
        }
        if ([[self emptyDataSetSource] respondsToSelector:@selector(backgroundColorForEmptyDataSet:)]) {
            [view.contentView setBackgroundColor:[[self emptyDataSetSource] backgroundColorForEmptyDataSet:self]];
        }
        if ([[self emptyDataSetSource] respondsToSelector:@selector(verticalOffsetForEmptyDataSet:)]) {
            [view setVerticalOffset:[[self emptyDataSetSource] verticalOffsetForEmptyDataSet:self]];
        }

        if ([[self emptyDataSetSource] respondsToSelector:@selector(emptyDataSet:enableEmptyDataSetButton:)]) {
            if ([[self emptyDataSetSource] emptyDataSet:self enableEmptyDataSetButton:view.button]) {
                [view.contentView addSubview:view.button];
                [self setupButtonConstraints:view];
            }
        }
        [self setupContentViewConstraints:view];
    }
}

- (void)setupImageViewConstraints:(EmptyDataSetView *)view {
    
    [[NSLayoutConstraint constraintWithItem:view.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.imageView  attribute:NSLayoutAttributeTrailing multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200] setActive:YES];
}

- (void)setupTitleLabelConstraints:(EmptyDataSetView *)view {
    
    [[NSLayoutConstraint constraintWithItem:view.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.titleLabel  attribute:NSLayoutAttributeTrailing multiplier:1 constant:8] setActive:YES];
}

- (void)setupDescriptionLabelConstraints:(EmptyDataSetView *)view {
    
    [[NSLayoutConstraint constraintWithItem:view.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.descriptionLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:8] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.descriptionLabel  attribute:NSLayoutAttributeTrailing multiplier:1 constant:8] setActive:YES];
}

- (void)setupContentViewConstraints:(EmptyDataSetView *)view {
    
    [[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self superview] attribute:NSLayoutAttributeCenterY multiplier:1 constant:[view verticalOffset]] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:view.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:250] setActive:YES];
    
    [[[view.contentView leadingAnchor] constraintEqualToAnchor:[[self superview] leadingAnchor] constant:16] setActive:YES];
    [[[[self superview] trailingAnchor] constraintEqualToAnchor:[view.contentView trailingAnchor] constant:16] setActive:YES];
}

- (void)setupButtonConstraints:(EmptyDataSetView *)view {
    
    [[NSLayoutConstraint constraintWithItem:view.button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:250] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:view.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0] setActive:YES];
   

    [[[view.button leadingAnchor] constraintEqualToAnchor:[view.contentView leadingAnchor] constant:0] setActive:YES];
    [[[view.contentView trailingAnchor] constraintEqualToAnchor:[view.button trailingAnchor] constant:0] setActive:YES];
}

#pragma mark - Swizzling Methods

- (void)swizzleIfPossible:(SEL)selector {
    
    if (![self respondsToSelector:selector]) {
        return;
    }
    
    if (!implementationLookupTable) {
        implementationLookupTable = [NSMutableDictionary new];
    }
    
    // We make sure that setImplementation is called once per class kind, UITableView or UICollectionView.
    for (NSDictionary *info in [implementationLookupTable allValues] ) {
        Class class = [info objectForKey:ZTSwizzleInfoOwnerClassKey];
        NSString *selectorName = [info objectForKey:ZTSwizzleInfoSelectorKey];
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    Class baseClass = [self baseClassToSwizzleFor:self];
    NSString *infoKey  = [self implementationLookupTableKeyForTarget:baseClass selector:selector];
    NSValue *implementaionValue = [[implementationLookupTable objectForKey:infoKey] valueForKey:ZTSwizzleInfoPointerKey];
    
    // If the implementation for this class already exist, skip!!
    if (implementaionValue || !infoKey || !baseClass) {
        return;
    }
    
    // Swizzle by injecting additional implementation
    Method method = class_getInstanceMethod(baseClass, selector);
    IMP newImplementation = method_setImplementation(method, (IMP)zt_swizzledImplementation);
    
    // Store the new implementation in the lookup table
    NSDictionary *swizzledInfo = @{ZTSwizzleInfoOwnerClassKey: baseClass,
                                   ZTSwizzleInfoSelectorKey: NSStringFromSelector(selector),
                                   ZTSwizzleInfoPointerKey: [NSValue valueWithPointer:newImplementation]};
    
    [implementationLookupTable setObject:swizzledInfo forKey:infoKey];
    
}

void zt_swizzledImplementation(id self, SEL _cmd) {
    
    NSLog(@"scroll view did reload for  %@", [self class]);
    
    // Fetch original implementation from lookup table
    Class baseClass = [self baseClassToSwizzleFor:self];
    NSString *key = [self implementationLookupTableKeyForTarget:baseClass selector:_cmd];
    
    NSDictionary *swizzleInfo = [implementationLookupTable objectForKey:key];
    
    NSValue *impValue = [swizzleInfo valueForKey:ZTSwizzleInfoPointerKey];
    
    IMP impPointer = [impValue pointerValue];
    
    // We then inject the additional implementation for reloading the empty dataset
    [self reloadEmptyDataSet];
    
    // If found, call original implementation
    if (impPointer) {
        ((void(*)(id,SEL))impPointer)(self,_cmd);
    }
}

- (NSString *)implementationLookupTableKeyForTarget:(Class)class selector:(SEL)selector {
    
    if (!class || !selector) {
        return nil;
    }
    
    NSString *className = NSStringFromClass([class class]);
    
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@",className,selectorName];
}

- (Class)baseClassToSwizzleFor:(id) target {
    
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }
    else if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }
    else if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    return nil;
}

- (void)invalidateEmptyView {
    
    if ([self emptyDataSetView]) {
        
        [self.emptyDataSetView invalidateSubViews];
        [self.emptyDataSetView.contentView removeFromSuperview];
        [self setEmptyDataSetView:nil];
    }
}

#pragma mark - ZTEmptyViewDataSetDelegate
- (void)zt_didTapButton:(id)sender {
    if ([self emptyDataSetDelegate] && [[self emptyDataSetDelegate] respondsToSelector:@selector(emptyDataSet:didTapButton:)]) {
        [[self emptyDataSetDelegate] emptyDataSet:self didTapButton:sender];
    }
}

@end

