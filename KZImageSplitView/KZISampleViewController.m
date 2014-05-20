//
//  Created by merowing on 10/05/2014.
//
//
//


#import "KZISampleViewController.h"
#import "KZImageSplitView.h"


@implementation KZISampleViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  KZImageSplitView *splitView = [[KZImageSplitView alloc] initWithImageA:[UIImage imageNamed:@"imageA.jpg"]
                                                          imageB:[UIImage imageNamed:@"imageB.jpg"]];
  splitView.frame = self.view.bounds;
  [self.view addSubview:splitView];
}

@end