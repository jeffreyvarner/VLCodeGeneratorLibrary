//
//  VLAbstractLanguageAdaptor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLAbstractLanguageAdaptor.h"

@implementation VLAbstractLanguageAdaptor


// blank method implementations -
-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options
{
    // force the user to overide -
    [self doesNotRecognizeSelector:_cmd];
    return @"u_need_2_override_me";
}

@end
