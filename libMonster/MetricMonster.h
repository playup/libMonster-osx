//
//  libMonster.h
//  libMonster
//
//  Created by Sugendran Ganess on 25/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMetricMonsterMessageKeyDeviceId            @"deviceId"
#define kMetricMonsterMessageKeyDeviceType          @"deviceType"
#define kMetricMonsterMessageKeyApplicationVerion   @"version"
#define kMetricMonsterMessageKeySystemVersion       @"osVersion"
#define kMetricMonsterMessageKeySessionCount        @"sessionCount"
#define kMetricMonsterMessageKeySessionDuration     @"sessionDuration"
#define kMetricMonsterMessageKeyTotalDuration       @"totalDuration"
#define kMetricMonsterMessageKeyCurrentScene        @"scene"

@interface MetricMonster : NSObject

+ (void) engageWithCatalog:(NSString *)catalogName andProjectKey:(NSString *)projectKey;
+ (void) addEvents:(NSDictionary *)data;
+ (void) addEventData:(id)value forKey:(NSString *)key;
+ (void) setDeviceId:(NSString *)deviceId;

+ (void) addHeartBeatValue:(id)object forKey:(NSString *)keyName;
+ (void) removeHeartBeatValue:(NSString *)keyName;
+ (void) replaceHeartBeatValueForKey:(NSString *)keyName withValue:(id)object;
+ (id) heartBeatValueForKey:(NSString *)keyName;

@end
