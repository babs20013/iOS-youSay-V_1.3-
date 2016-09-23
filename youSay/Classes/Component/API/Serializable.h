//
//  Serialize.h
//
//  Created by Baban on 11/6/14.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Serializable : NSObject
//-(id)objectFromXMLData:(NSData*)xmlData error:(NSError**)err;
//-(id)objectFromXMLString:(NSString*)string error:(NSError**)err;
//-(id)responseBodyFromString:(NSString*)string error:(NSError**)err;
-(id)initWithDictionary:(NSDictionary*)dictionary error:(NSError**)err;
-(NSString*)toXMLString;
-(NSString*)toXMLStringWithTitle:(NSString*)title;
-(NSDictionary*)toDictionary;

+(NSMutableArray*)arrayObjectFromDictionary:(NSDictionary*)dictionary forKeyPath:(NSString*)keypath withObjectClass:(Class)klass error:(NSError**)err;
+(NSMutableArray*)arrayObjectFromArray:(NSArray*)objArray withObjectClass:(Class)klass error:(NSError**)err;

@end
