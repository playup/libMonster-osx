//
//  MonsterRequest.h
//  libMonster
//
//  Created by Sugendran Ganess on 25/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MonsterRequestDelegate <NSObject>

- (void) monsterRequestCompleted:(BOOL) success withEvents:(NSArray*)data;

@end

@interface MonsterRequest : NSObject{
    NSMutableData *_receivedData;
}

@property (nonatomic, retain) id<MonsterRequestDelegate> delegate;
@property (nonatomic, retain) NSArray *requestData;

-(void) sendEvents:(NSArray*)events toCatalog:(NSString*)catalog withProjectKey:(NSString *)projectKey delegate:(id<MonsterRequestDelegate>)delegate;

@end
