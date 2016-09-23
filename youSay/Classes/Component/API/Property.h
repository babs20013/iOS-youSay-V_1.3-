//
//  Property.h
//  XMLSerializerTest
//
//  Created by Baban on 11/5/14.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Property : NSObject
@property (copy,nonatomic) NSString *name;
@property (assign,nonatomic) Class type;
@property (copy,nonatomic) NSString *protocol;
@property (assign,nonatomic) BOOL isRequired;
@property (assign,nonatomic) NSString *primitiveType;

@end
