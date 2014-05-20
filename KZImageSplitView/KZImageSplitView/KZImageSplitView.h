//
//  Created by merowing on 10/05/2014.
//
//
//


#import <Foundation/Foundation.h>


@interface KZImageSplitView : UIView
@property(nonatomic, strong, readonly) UIImage *imageA;
@property(nonatomic, strong, readonly) UIImage *imageB;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

//! interface builder support
@property(nonatomic, copy) NSString *imageAName;
@property(nonatomic, copy) NSString *imageBName;


- (id)initWithImageA:(UIImage *)imageA imageB:(UIImage *)b;
@end