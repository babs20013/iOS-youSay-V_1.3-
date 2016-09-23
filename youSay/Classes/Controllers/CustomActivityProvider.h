//
//  CustomActivityProvider.h
//  youSay
//
//  Created by Baban on 19/01/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CustomActivityProvider : UIActivityItemProvider <UIActivityItemSource>
@property (nonatomic, strong) NSString *urlString;
@end