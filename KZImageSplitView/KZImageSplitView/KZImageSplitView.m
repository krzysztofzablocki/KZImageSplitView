//
//  Created by merowing on 10/05/2014.
//
//
//


#import "KZImageSplitView.h"
#import "KZAsserts.h"

#define KZI_USE_AUTOMATIC_ANIMATION 0

static const CGFloat kPathSnappingDuration = 0.2f;
static const CGFloat kPathSnapMarginPercentage = 0.3f;

@interface KZImageSplitView ()
@property(nonatomic, strong) UIImageView *backgroundImageView;
@property(nonatomic, strong) UIImageView *foregroundImageView;
#if KZI_USE_AUTOMATIC_ANIMATION
@property(nonatomic, weak) CADisplayLink *displayLink;
#endif
@property(nonatomic, strong) CAShapeLayer *shapeLayer;
@property(nonatomic, strong, readwrite) UIImage *imageA;
@property(nonatomic, strong, readwrite) UIImage *imageB;
@end

@implementation KZImageSplitView

- (id)initWithImageA:(UIImage *)imageA imageB:(UIImage *)imageB
{
  AssertTrueOrReturnNil(imageA);
  AssertTrueOrReturnNil(imageB);

  self = [super init];
  if (self) {
    _imageA = imageA;
    _imageB = imageB;
    [self setupUI];
  }

  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  self.imageA = [UIImage imageNamed:self.imageAName];
  self.imageB = [UIImage imageNamed:self.imageBName];
  AssertTrueOrReturn(self.imageA);
  AssertTrueOrReturn(self.imageB);
  [self setupUI];
}


- (void)setupUI
{
  [self sizeToFit];
  [self setupImageViews];
  [self setupMaskingForView:self.foregroundImageView];

#if KZI_USE_AUTOMATIC_ANIMATION
  [self.displayLink invalidate];
  CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
  [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
  self.displayLink = link;
#else
  [self setupGestureRecognizer];
#endif
}

- (void)setupGestureRecognizer
{
  [self removeGestureRecognizer:self.panGestureRecognizer];
  self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
  const CGPoint location = [gestureRecognizer locationInView:self];
  const CGFloat width = CGRectGetWidth(self.bounds);
  const CGFloat height = CGRectGetHeight(self.bounds);

  const CGFloat distance = sqrtf((float)(location.x * location.x + pow((height - location.y), 2)));
  const CGFloat maxDistance = sqrtf(width * width + height * height);

  CGFloat fraction = distance / maxDistance;

  const BOOL isEnding = gestureRecognizer.state == UIGestureRecognizerStateEnded;
  const CGFloat snapMargin = kPathSnapMarginPercentage;
  if (isEnding && fraction > 1.0 - snapMargin) {
    fraction = 1;
  }

  if (isEnding && fraction < snapMargin) {
    fraction = 0;
  }

  const CGPathRef newPath = [self pathForMaskingUpToPercentage:fraction];

  if (isEnding) {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)self.shapeLayer.path;
    pathAnimation.toValue = (__bridge id)newPath;
    pathAnimation.duration = kPathSnappingDuration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.shapeLayer addAnimation:pathAnimation forKey:@"path"];
  }
  self.shapeLayer.path = newPath;
}

#if KZI_USE_AUTOMATIC_ANIMATION

- (void)tick
{
  static CGFloat cosOffset = 0;
  cosOffset += 0.01;
  if (cosOffset > M_PI) {
    cosOffset = 0;
  }
  self.shapeLayer.path = [self pathForMaskingUpToPercentage:cosf(cosOffset - (CGFloat)M_PI_2)];
}

#endif

- (void)setupMaskingForView:(UIImageView *)view
{
  self.shapeLayer = [CAShapeLayer layer];
  self.shapeLayer.path = [self pathForMaskingUpToPercentage:0.5];
  view.layer.mask = self.shapeLayer;
  view.layer.masksToBounds = YES;
}

- (CGPathRef)pathForMaskingUpToPercentage:(CGFloat)percentage
{
  const CGFloat width = CGRectGetWidth(self.bounds);
  const CGFloat height = CGRectGetHeight(self.bounds);
  const CGFloat ratio = width / height;

  const CGFloat min = MAX(height, width);
  const CGFloat offset = -min + 2 * min * percentage;

  UIBezierPath *bezierPath = [UIBezierPath bezierPath];
  [bezierPath moveToPoint:CGPointMake(0, height)];
  [bezierPath addLineToPoint:CGPointMake(0, 0 - offset)];
  [bezierPath addLineToPoint:CGPointMake(width + offset * ratio, height)];
  [bezierPath closePath];
  return bezierPath.CGPath;
}

- (void)setupImageViews
{
  self.backgroundImageView = [self imageViewForImage:self.imageA];
  self.foregroundImageView = [self imageViewForImage:self.imageB];

  [self addSubview:self.backgroundImageView];
  [self addSubview:self.foregroundImageView];
}

- (UIImageView *)imageViewForImage:(UIImage *)image
{
  UIImageView *const imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = self.bounds;
  return imageView;
}

- (CGSize)sizeThatFits:(CGSize)size
{
  return CGSizeMake(self.imageA.size.width / self.imageA.scale, self.imageA.size.height / self.imageA.scale);
}


- (void)layoutSubviews
{
  [super layoutSubviews];
  self.backgroundImageView.frame = self.foregroundImageView.frame = self.bounds;
}

@end