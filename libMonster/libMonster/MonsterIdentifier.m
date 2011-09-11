//
//  MonsterIdentifier.m
//  libMonster
//
//  Created by Sugendran Ganess on 8/09/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import "MonsterIdentifier.h"

@implementation MonsterIdentifier

+(NSString*) identifier
{
    return [[UIDevice currentDevice] uniqueIdentifier];
}

@end
