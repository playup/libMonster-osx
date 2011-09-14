//
//  libMonster.m
//  libMonster
//
//  Created by Sugendran Ganess on 25/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import "MetricMonster.h"
#import "MonsterRequest.h"
#import "MonsterIdentifier.h"

#define kMetricMonsterDictKeySessionCount           @"sessionCount"
#define kMetricMonsterDictKeySessionDuration        @"sessionDuration"
#define kMetricMonsterDictKeyApplicationDuration    @"applicationDuration"

@interface MetricMonster()<MonsterRequestDelegate>{
    NSTimer *_timer;
    NSMutableArray *_eventStack;
    NSDateFormatter *_dateFormatter;
    double _sessionStart;
    int _sessionCount;
    double _appDuration;
    BOOL _isSending;
}

- (void) startTimer;
- (void) addEvent:(NSDictionary *)data;

@property (nonatomic, copy) NSString *catalogName;
@property (nonatomic, copy) NSString *projectKey;
@property (nonatomic, copy) NSString *monsterFilePath;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, retain) NSMutableDictionary *heartBeatData;
@property (nonatomic, retain) MonsterRequest *currentRequest;

@end

@implementation MetricMonster

@synthesize catalogName, projectKey, monsterFilePath, deviceId = _deviceId, heartBeatData, currentRequest;

#pragma mark -
#pragma mark Initialisation and Dealloc and things like that

- (id)init {
    self = [super init];
    if (self) {
        _eventStack = [[NSMutableArray alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        [self setMonsterFilePath:[libraryDirectory stringByAppendingPathComponent:@"MonsterInfo.plist"]];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
        
        self.heartBeatData = [NSMutableDictionary dictionary];
        _isSending = NO;
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    
    self.heartBeatData = nil;
    self.catalogName = nil;
    self.projectKey = nil;
    self.monsterFilePath = nil;
    self.deviceId = nil;
    [super dealloc];
}
#endif

-(NSString *)deviceId
{
    if(_deviceId == nil){
        // store the deviceId in the keychain http://overhrd.com/?p=208
        _deviceId = [[MonsterIdentifier identifier] retain];
    }
    return _deviceId;
}

#pragma mark -
#pragma mark Record some stats

- (void) addEvent:(NSDictionary *)data
{
    NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithDictionary:data];
    [eventData setValue:[self deviceId] forKey:kMetricMonsterMessageKeyDeviceId];
    [_eventStack addObject:[NSArray arrayWithObjects:@"EVENT", [_dateFormatter stringFromDate:[NSDate date]], data, nil]];
}

- (void) addHeartBeatEvent
{
    double sessionDuration = [NSDate timeIntervalSinceReferenceDate] - _sessionStart;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *eventData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [infoDictionary objectForKey:@"CFBundleShortVersionString"], kMetricMonsterMessageKeyApplicationVerion,
                               [[UIDevice currentDevice] model], kMetricMonsterMessageKeyDeviceType,
                               [[UIDevice currentDevice] systemVersion], kMetricMonsterMessageKeySystemVersion,
                               [NSNumber numberWithInt:_sessionCount], kMetricMonsterMessageKeySessionCount,
                               [NSNumber numberWithDouble:sessionDuration], kMetricMonsterMessageKeySessionDuration,
                               [NSNumber numberWithDouble:(_appDuration + sessionDuration)], kMetricMonsterDictKeyApplicationDuration,
                               nil];
    [eventData addEntriesFromDictionary:self.heartBeatData];
    [self addEvent:eventData];
}

#pragma mark -
#pragma mark Event sending

- (void) monsterRequestCompleted:(BOOL) success withEvents:(NSArray*)data;
{
    if(!success){
        [_eventStack addObjectsFromArray:data];
    }
    _isSending = NO;
    NSLog(@"data sent to the monster");
    self.currentRequest = nil;
}

- (void) sendEventStack
{
    if((_eventStack == nil) || ([_eventStack count] == 0)){
        return;
    }
    
    NSArray *data = [[_eventStack copy] autorelease];
#if !__has_feature(objc_arc)
    [_eventStack release];
#endif
    _eventStack = [[NSMutableArray alloc] init];
    self.currentRequest = [[[MonsterRequest alloc] init] autorelease];
    [self.currentRequest sendEvents:data toCatalog:self.catalogName withProjectKey:self.projectKey delegate:self];
}

-(void) sendEvent:(NSTimer*)timer
{
    if(_isSending){
        return;
    }
    [self addHeartBeatEvent];
    
    [self sendEventStack];
}

#pragma mark -
#pragma mark Application Events

- (void) finalizeSession
{
    _isSending = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self monsterFilePath]];
    if(dict == nil){
        dict = [NSMutableDictionary dictionary];
    }
    double sessionDuration = [NSDate timeIntervalSinceReferenceDate] - _sessionStart;
    [dict setObject:[NSNumber numberWithDouble:(_appDuration + sessionDuration)] forKey:kMetricMonsterDictKeyApplicationDuration];
    
    [dict writeToFile:[self monsterFilePath] atomically:YES];
    
    [self sendEventStack];    
}

- (void) applicationEnteredBackground:(NSNotification*)notification
{
    [self finalizeSession];
}

- (void) applicationWillEnterForeground:(NSNotification*)notification
{

}

- (void) applicationWillTerminate:(NSNotification*)notification
{
//    [self finalizeSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) registerForNotifications
{
    // setup a bunch of details on load
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self monsterFilePath]];
    if(dict == nil){
        dict = [NSMutableDictionary dictionary];
    }
    
    NSNumber *sessions = [dict objectForKey:kMetricMonsterDictKeySessionCount];
    _sessionCount = (1 + [sessions intValue]);
    _appDuration = [[dict objectForKey:kMetricMonsterDictKeyApplicationDuration] doubleValue];    
    _sessionStart = [NSDate timeIntervalSinceReferenceDate];
    
    [dict setObject:[NSNumber numberWithInt:_sessionCount] forKey:kMetricMonsterDictKeySessionCount];
    [dict setObject:[NSNumber numberWithDouble:0.0] forKey:kMetricMonsterDictKeyApplicationDuration];
    [dict writeToFile:[self monsterFilePath] atomically:YES];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}


#pragma mark -
#pragma mark Timer stuff

- (void) startTimer
{
#if !__has_feature(objc_arc)
    if(_timer != nil){
        [_timer release];
        _timer = nil;
    }
#endif
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:50 target:self selector:@selector(sendEvent:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

#pragma mark -
#pragma mark Static Methods

// the iOS 4.0+ way of doing singletons
// http://cocoasamurai.blogspot.com/2011/04/singletons-your-doing-them-wrong.html
+ (MetricMonster *)singleton {
    static dispatch_once_t pred;
    static MetricMonster *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MetricMonster alloc] init];
    });
    return shared;
}

+ (void) engageWithCatalog:(NSString *)catalogName andProjectKey:(NSString *)projectKey
{    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MetricMonster *monster = [self singleton];
        [monster setCatalogName:catalogName];
        [monster setProjectKey:projectKey];
        [monster registerForNotifications];
        [monster startTimer];
    });
}

+ (void) addEvents:(NSDictionary *)data
{
    MetricMonster *monster = [self singleton];
    [monster addEvent:data];
}

+ (void) addEventData:(id)value forKey:(NSString *)key
{
    MetricMonster *monster = [self singleton];
    [monster addEvent:[NSDictionary dictionaryWithObject:value forKey:key]];    
}

+ (void) setDeviceId:(NSString *)deviceId
{
    MetricMonster *monster = [self singleton];
    [monster setDeviceId:deviceId];
}

+ (void) addHeartBeatValue:(id)object forKey:(NSString *)keyName
{
    MetricMonster *monster = [self singleton];
    [[monster heartBeatData] setValue:object forKey:keyName];
}

+ (void) replaceHeartBeatValueForKey:(NSString *)keyName withValue:(id)object
{
    MetricMonster *monster = [self singleton];
    [[monster heartBeatData] setValue:object forKey:keyName];
}

+ (void) removeHeartBeatValue:(NSString *)keyName
{
    MetricMonster *monster = [self singleton];
    [[monster heartBeatData] removeObjectForKey:keyName];
}

+ (id) heartBeatValueForKey:(NSString *)keyName
{
    MetricMonster *monster = [self singleton];
    return [[monster heartBeatData] objectForKey:keyName];
}

#pragma mark -

@end
