//
//  MonsterRequest.m
//  libMonster
//
//  Created by Sugendran Ganess on 25/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import "MonsterRequest.h"
#import "MonsterJSON.h"

#ifndef kMetricMonsterQueryUrl
#define kMetricMonsterQueryUrl @"http://api.metricmonster.com/query.rest"
#endif
#define kMetricMonsterQueryTimeout 10.0

@implementation MonsterRequest

@synthesize delegate, requestData;

- (id)init {
    self = [super init];
    if (self) {
        _receivedData = nil;
        self.delegate = nil;
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    [_receivedData release];
    _receivedData = nil;
    self.delegate = nil;
    self.requestData = nil;
    [super dealloc];
}
#endif

-(void) sendEvents:(NSArray*)events toCatalog:(NSString*)catalog withProjectKey:(NSString *)projectKey delegate:(id<MonsterRequestDelegate>)requestDelegate;
{
    self.delegate = requestDelegate;
    self.requestData = events;
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?key=%@", kMetricMonsterQueryUrl, projectKey]]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:kMetricMonsterQueryTimeout];

    [theRequest setHTTPMethod:@"POST"];

    NSString *request = [NSString stringWithFormat:@"USE %@ ADD JSON ",catalog];
    NSMutableData *requestbody = [NSMutableData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    
    MonsterJSON *serializer = [[MonsterJSON alloc] init];
#if !__has_feature(objc_arc)
    [serializer autorelease];
#endif
    NSError *theError = nil;
    NSData *eventData = [serializer serializeArray:events error:&theError];
    if(theError){
        NSLog(@"Could not serialize data fro Metric Monster - %@", [theError localizedDescription]);
        [self.delegate monsterRequestCompleted:NO withEvents:self.requestData];
        return;
    }else{
        [requestbody appendData:eventData];
        [theRequest setHTTPBody:requestbody];
    }
    
    NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
    if (theConnection) {
        if(_receivedData){
#if !__has_feature(objc_arc)
            [_receivedData release];
            _receivedData = nil;
#endif
        }
        _receivedData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"Failed to create a connection to send data to Metric Monster");
        [self.delegate monsterRequestCompleted:NO withEvents:self.requestData];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
#if !__has_feature(objc_arc)
    [connection release];
    [_receivedData release];
    _receivedData = nil;
#endif
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [self.delegate monsterRequestCompleted:NO withEvents:self.requestData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    
    NSString *result = [[NSString alloc] initWithData:_receivedData encoding:NSASCIIStringEncoding];
    NSRange range = [result rangeOfString:@"error"];
    if(range.location != NSNotFound){
        NSLog(@"Failed to send message to Metric Monster - %@", result);
        [self.delegate monsterRequestCompleted:NO withEvents:self.requestData];
    }else{
        [self.delegate monsterRequestCompleted:YES withEvents:self.requestData];
    }
    
#if !__has_feature(objc_arc)
    [result release];
//    [connection release];
    [_receivedData release];
    _receivedData = nil;
#endif
}

@end
