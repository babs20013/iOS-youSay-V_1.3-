//
//  Serialize.m
//  
//
//  Created by Baban on 11/6/14.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "Serializable.h"
#import "Property.h"
#import <objc/runtime.h>
@implementation Serializable{
    NSMutableArray *arrProperties;
}
-(instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)err{
    //input is not dictionary
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        //error handling
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Invalid dictionary" forKey:NSLocalizedDescriptionKey];
        *err = [NSError errorWithDomain:@"Serialize" code:1 userInfo:errorDetail];
        return nil;
    }
    //create a class instance
    self = [self init];
    if (!self) {
        return nil;
    }
    
    //get all properties from the class object model
    [self objectProperties];
    
    //map object
    [self mapObjectFromDictionary:dictionary error:err];
    
    return self;
}

-(NSString*)mapKey:(NSString*)key{
    NSString* result = key;
    Class klass = [self class];
    while (klass != [Serializable class]) {
        if ([[klass class]keyMapper] && [[klass class]keyMapper].count > 0) {
            result = [[[klass class]keyMapper] valueForKey:key];
            if (result.length) {
                return result;
            }
        }
        klass = [klass superclass];
    }

    if (!result.length) {
        return key;
    }
    
    return result;
}

-(BOOL)mapObjectFromDictionary:(NSDictionary*)dict error:(NSError**)err{

    if (!arrProperties || arrProperties.count <= 0) {
        //Class dont have any properties
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[NSString stringWithFormat:@"No properties on class %@",[[self class] description]] forKey:NSLocalizedDescriptionKey];
        *err = [NSError errorWithDomain:@"Serialize" code:2 userInfo:errorDetail];
    }
    
    for (Property* property in arrProperties) {
        id value;
        @try {
            value = [dict valueForKeyPath: [self mapKey:property.name]];
        }
        @catch (NSException *exception) {
            value = dict[property.name];
        }

        //if value is null continue
        if (!value || [value isKindOfClass:[NSNull class]]) {
            if (property.type == [NSString class]) {
                //set string to empty string instead of a nil
               value = @"";
            }
            else{
                value = nil;
            }
//            [self setValue:value forKey: property.name];
            [self mapObjectValue:value withProperty:property];
            continue;
        }

        if( [self isSerialzeable:property.type]){
            NSError* initErr = nil;
            id objValue = [[property.type alloc] initWithDictionary:value error:&initErr];
            if (initErr && err) {
                *err = initErr;
            }
//            [self setValue:objValue forKey: property.name];
            [self mapObjectValue:objValue withProperty:property];
            continue;
        }
        else{
            if(property.protocol){
                NSError* initErr = nil;
                //Convert object class
                value = [self convertModel:value forProperty:property error:&initErr];
                if (initErr && err) {
                    *err = initErr;
                }
            }

            if(property.type && [value isKindOfClass:property.type] ){
//                [self setValue:value forKey: property.name];
                [self mapObjectValue:value withProperty:property];
            }
            
            if (![value isKindOfClass:property.type] && value != nil ) {
                //convert type
//                value  = [self convertValue:value toType:property.type];
                [self mapObjectValue:value withProperty:property];
//                [self setValue:value forKey: property.name];
            }
            
            if (!property.type) {
                Class model = NSClassFromString(property.protocol);
                if ([value isKindOfClass:[model class]]) {
                    //class is and id with model protocol
                    [self mapObjectValue:value withProperty:property];
//                    [self setValue:value forKey: property.name];
                }
            }
            
            continue;
        }
    }
    return YES;
}

-(id)convertModel:(id)value forProperty:(Property*)property error:(NSError**)err{
    @try {
        //Checking if value is nil/empty bail
        if (!value || ([[value class]isSubclassOfClass:[NSString class]] && [value length]==0)) {
            if ([self isArray:property.type]) {
                return [NSArray array];
            }
            else if ([self isDictionary:property.type]){
                return [NSDictionary dictionary];
            }
            return nil;
        }
        
        Class model = NSClassFromString(property.protocol);
        NSError *error = nil;
        if ([self isSerialzeable:model]) {
            //if Array
            if ([self isArray:property.type]) {
                NSString * title = [[self class] childNode] ? [[[self class] childNode] valueForKey:[self mapKey:property.name]] : [self mapKey:property.name];
                if (title.length) {
                    value = [value valueForKey:title];
                }
                
                if ([self isArray:value]) {
                    value = [[model class] listOfModelFromDictionary:value error:&error];
                }
                else{
                    //the data only have 1 record but expected to be an array
                    NSMutableArray* list = [NSMutableArray arrayWithCapacity: 1];
                    id temp = [[[model class] alloc] initWithDictionary:value error:&error];
                    if (temp) {
                        [list addObject:temp];
                    }
                    value = list;
                }
            }
            //if Dictionary
            else if ([self isDictionary:property.type]){
                if (![self isDictionary:value]) {
                    if (err) {
                        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                        [errorDetail setValue:[NSString stringWithFormat:@"Expection a dictionary on property %@",property.name] forKey:NSLocalizedDescriptionKey];
                        *err = [NSError errorWithDomain:@"Serialize" code:4 userInfo:errorDetail];
                    }
                }
                value = [[model class] dictionaryOfModelFromDictionary:value error:&error];
            }
            else{
                //Unsuported format
                value = [[[model class ]alloc] initWithDictionary:value error:&error];
            }
        }
        
        if (err && error) {
            *err = error;
        }
    }
    @catch (NSException *exception) {
    }
    
    return value;
}

+(NSMutableDictionary*)dictionaryOfModelFromDictionary:(NSDictionary*)dict error:(NSError**)err{
    NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
    NSError* error = nil;
    for (NSString* key in [dict allKeys]) {
        id obj = [[self alloc] initWithDictionary:dict[key] error:&error];
        [resDict setValue:obj forKey:key];
    }
    return resDict;
}

+(NSMutableArray*)listOfModelFromDictionary:(NSArray*)array error:(NSError**)err
{
    //bail early
    if (!array || [array isKindOfClass:[NSNull class]]) return nil;

    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];

    for (NSDictionary* dt in array) {

        NSError* error = nil;
        id obj = [[self alloc] initWithDictionary:dt error:&error];
        if (obj == nil)
        {
            if (err && error) {
                *err = error;
            }
            return nil;
        }

        [list addObject: obj];
    }

    return list;
}


#pragma mark - TODO
#pragma mark Convert Value
-(id)convertValue:(id)value toType:(Class)type{
    id result =nil;
    if ([type isSubclassOfClass:[NSNumber class]]) {
        //convert to number
        return [NSNumber numberWithFloat: [value doubleValue]];
    }
    return result;
}

-(void)mapObjectValue:(id)value withProperty:(Property*)property{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"manualMapObject_%@:", property.name]);
    if ([self respondsToSelector:selector]) {
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, NSDictionary *) = (void *)imp;
        func(self, selector, value);
    }
    else{
        if (property.primitiveType.length > 0) {
            //nothing
            //primitive type need to manualy map
        }
        else{
            [self setValue:value forKey: property.name];
        }
    }
}
#pragma mark -
#pragma mark - Object to dictionary
-(NSDictionary*)toDictionary{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self objectProperties];
    for (Property* property in arrProperties) {
        id value;
        value = [self valueForKey:property.name];

        if(value && [self isSerialzeable:property.type]){
            id objValue = [value toDictionary];
            if (!objValue || [objValue isKindOfClass:[NSNull class]]) {
                objValue = @"";
            }
            [dictionary setObject:objValue forKey:[self mapKey:property.name]];
            continue;
        }
        else{
            if (!value || [value isKindOfClass:[NSNull class]]) {
                value = @"";
            }
            
//            if(property.type && [value isKindOfClass:property.type] ){
                [dictionary setObject:value forKey:[self mapKey:property.name]];
//            }
        }
    }
    return dictionary;
}

#pragma mark -
#pragma mark Object to String

-(NSString*)toXMLString{
    return [self toXMLStringWithTitle:nil];
}
-(NSString*)toXMLStringWithTitle:(NSString*)title{
    //get all properties from the class object model
    [self objectProperties];
    
    NSMutableString *returnStr = [[NSMutableString alloc]init];
    if (title.length) {
        [returnStr appendFormat:@"<%@>", title];
    }
    for (Property* property in arrProperties) {
        id value = [self valueForKey:property.name];
        [returnStr appendFormat:@"<%@", [self mapKey:property.name]];
        if (value) {
            if([self isSerialzeable:property.type]){
                [returnStr appendFormat:@">"];
                [returnStr appendFormat:@"%@",[value toXMLString]];
            }
            else{
                if (property.protocol) {
                    if ([self isArray:property.type]) {
                        NSString * node = [[[self class] childNode] valueForKey:property.name];

                        [returnStr appendFormat:@">"];
                        [returnStr appendFormat:@"%@",[self xmlArray:value WithElement:node]];
                    }
                }
                else{
                    [returnStr appendFormat:@">"];
                    [returnStr appendFormat:@"%@",[self encodeXML:value]];
                }

                if (!property.type && property.protocol) {
                    Class model = NSClassFromString(property.protocol);
                    if ([value isKindOfClass:[model class]]) {
                        [returnStr appendFormat:@">"];
                        [returnStr appendFormat:@"%@", [value toXMLString]];
                    }
                }
            }
        }
        else{
            //for nil value
            [returnStr appendFormat:@">"];
        }

        [returnStr appendFormat:@"</%@>",[self mapKey:property.name]];
    }
    if (title.length) {
        [returnStr appendFormat:@"</%@>", title];
    }
    return returnStr;
}
#pragma mark -
#pragma mark encode/decode
- (NSString*)decodeXML:(NSString*)value{
    NSMutableString	*decodedValue = [[NSMutableString alloc] initWithString:value];
    [decodedValue replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [decodedValue length])];
    [decodedValue replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0, [decodedValue length])];
    [decodedValue replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0, [decodedValue length])];
    [decodedValue replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, [decodedValue length])];
    [decodedValue replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [decodedValue length])];
    return decodedValue;
}
- (NSString*) encodeXML:(NSString*) value{
    NSMutableString	*encodedValue = [[NSMutableString alloc] initWithString:value];
    [encodedValue replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [encodedValue length])];
    [encodedValue replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [encodedValue length])];
    [encodedValue replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [encodedValue length])];
    [encodedValue replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [encodedValue length])];
    [encodedValue replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, [encodedValue length])];
    return encodedValue;
}

-(BOOL)isSerialzeable:(Class)class{
    class = [class class];
    return [class isSubclassOfClass:[Serializable class]];
}
-(BOOL) isArray:(Class)class{
    class = [class class];
    return [class isSubclassOfClass:[NSArray class]];
}
-(BOOL) isDictionary:(Class)class{
    class = [class class];
    return [class isSubclassOfClass:[NSDictionary class]];
}

-(NSString*)xmlArray:(NSArray*)array WithElement:(NSString*)elementName{
    if (!array || [array isKindOfClass:[NSNull class]]) return nil;
    NSMutableString *string = [[NSMutableString alloc]init];
    for (id obj in array) {
        if ([self isSerialzeable:[obj class]]) {
            if (elementName) {
                [string appendFormat:@"<%@>%@</%@>", elementName,[obj toXMLString],elementName];
            }
            else{
                [string appendFormat:@"%@",[obj toXMLString]];
            }
        }
    }
    return string;
}
+(NSDictionary*)keyMapper{
    return nil;
}
+(NSDictionary*)childNode{
    return nil;
}

#pragma mark -
#pragma mark Object Helper
-(void)objectProperties{
    //Store property
    arrProperties = [NSMutableArray array];
    NSScanner *scanner = nil;
    NSString* propertyType = nil;
    Class class = [self class];
    unsigned int propertyCount;
    while (class != [Serializable class]) {
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (unsigned int i = 0; i < propertyCount; i++) {
            Property *prop = [[Property alloc]init];

            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            prop.name = @(propertyName);

            const char *attributes = property_getAttributes(property);
            NSString* propertyAttributes = @(attributes);


            scanner = [NSScanner scannerWithString: propertyAttributes];
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                prop.type = NSClassFromString(propertyType);
                //Scan Protocol
                //Ex: T@"NSArray<Protocol1><Protocol2>",&,N,V_PropertyName
                while ([scanner scanString:@"<" intoString:NULL]) {

                    NSString* protocolName = nil;
                    [scanner scanUpToString:@">" intoString: &protocolName];

                    if ([protocolName isEqualToString:@"Required"]) {
                        prop.isRequired = YES;
                    } else {
                        prop.protocol = protocolName;
                    }

                    [scanner scanString:@">" intoString:NULL];
                }
            }
            else{
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                if ([propertyType isEqualToString:@"c"] || [propertyType isEqualToString:@"B"]) {
                    prop.primitiveType = @"BOOL";
                }
//                else{
                    prop.type = [[self valueForKey:prop.name] class];
//                }
            }

            if (prop) {
                [arrProperties addObject:prop];
            }
        }
        free(properties);
        class = [class superclass];
    }
}
#pragma mark -
#pragma mark - Method
+(NSMutableArray*)arrayObjectFromDictionary:(NSDictionary*)dictionary forKeyPath:(NSString*)keypath withObjectClass:(Class)klass error:(NSError**)err{
    @try {
        NSError *error;
        id objArray =   [dictionary valueForKeyPath:keypath];
        if (![[objArray class] isSubclassOfClass:[NSArray class]]) {
            
            if (objArray) {
                NSArray *arr = [NSArray arrayWithObject:objArray];
                objArray = arr;
            }
            else{
                *err = [[NSError alloc ] initWithDomain:@"Serializer" code:99 userInfo:@{NSLocalizedDescriptionKey: @"Expected an array but object is not an array."}];
                return nil;
            }
        }
        else if (!objArray){
            *err = [[NSError alloc ] initWithDomain:@"Serializer" code:99 userInfo:@{NSLocalizedDescriptionKey: @"Array is nil."}];
            return nil;
        }
        return [Serializable arrayObjectFromArray:objArray withObjectClass:klass error:&error];
    }
    @catch (NSException *exception) {
    }
}

+(NSMutableArray*)arrayObjectFromArray:(NSArray*)objArray withObjectClass:(Class)klass error:(NSError**)err{
    NSError *error;
    @try {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *trx in objArray) {
            id trxHistory = [[klass alloc] initWithDictionary:trx error:&error];
            if (trxHistory) {
                [array addObject:trxHistory];
            }
        }
        return array;
    }
    @catch (NSException *exception) {
    }
}

#pragma mark -
#pragma mark XML Helper
//-(id)objectFromXMLData:(NSData*)xmlData error:(NSError**)err{
//    if (!xmlData) {
//        return self;
//    }
//    NSError *error = nil;
//    NSDictionary *obj = [XMLReader dictionaryWithXMLData:xmlData error:&error];
//    id objModel = [self initWithDictionary:obj error:&error];
//    return objModel;
//
//}
//-(id)objectFromXMLString:(NSString*)string error:(NSError**)err{
//    if (!string) {
//        //error handling [TODO:]
//    }
//    NSError *error = nil;
//    NSDictionary *obj = [XMLReader dictionaryWithXMLString:string error:&error];
//    id objModel = [self initWithDictionary:obj error:&error];
//    return objModel;
//}
//
////Helper to get the body object
////there is no generic
//-(id)responseBodyFromXMLData:(NSData*)xmlData error:(NSError**)err{
//    if (!xmlData) {
//        return self;
//    }
//    NSError *error = nil;
//    NSDictionary *obj = [XMLReader dictionaryWithXMLData:xmlData error:&error];
//    obj = [obj valueForKey:@"response"];
//    NSDictionary* body = [obj valueForKey:@"body"];
//    
//    id objModel = [self initWithDictionary:body error:&error];
//    return objModel;
//}
//
//-(id)responseBodyFromString:(NSString*)string error:(NSError**)err{
//    if (!string) {
//        //error handling [TODO:]
//    }
//    NSError *error = nil;
//    NSDictionary *obj = [XMLReader dictionaryWithXMLString:string error:&error];
//    obj = [obj valueForKey:@"response"];
//    NSDictionary* body = [obj valueForKey:@"body"];
//
//    id objModel = [self initWithDictionary:body error:&error];
//    return objModel;
//}
@end
