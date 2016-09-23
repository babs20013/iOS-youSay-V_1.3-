//
//  ServiceConnector.h
//  Service Reader
//
//  Created by Divan Visagie on 2012/08/25.
//

#import <Foundation/Foundation.h>

@protocol ServiceConnectorDelegate <NSObject>

-(void)requestReturnedData:(NSData*)data;

@end

@interface ServiceConnector : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (strong,nonatomic) id <ServiceConnectorDelegate> delegate;

-(void)getTest;
-(void)postTest:(NSString *)requestType authorization_id:(NSString *)authorization_id access_token:(NSString *)access_token authority_type:(NSString *)authority_type app_name:(NSString *)app_name app_version:(NSString *)app_version  device_info:(NSString *)device_info;
@end
