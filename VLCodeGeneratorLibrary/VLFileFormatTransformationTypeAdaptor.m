//
//  VLFileFormatTransformationTypeAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 11/28/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLFileFormatTransformationTypeAdaptor.h"

@implementation VLFileFormatTransformationTypeAdaptor

-(NSString *)generateSBMLFileFromVFFWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // ok, process this request -
    NSString *code_block = [self processTransformationSelector:_cmd withOptions:options];
    [buffer appendString:code_block];
    
    // return -
    return buffer;
}


@end
