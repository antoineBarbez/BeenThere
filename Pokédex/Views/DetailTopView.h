//
//  DetailTopView.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 07/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTopView : UIView

@property (assign, nonatomic) CGFloat minHeight;
@property (assign, nonatomic) CGFloat maxHeight;

@property (nonatomic, weak) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *flexibleView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *circleImage;
@property (weak, nonatomic) IBOutlet UIView *counter;
@end
