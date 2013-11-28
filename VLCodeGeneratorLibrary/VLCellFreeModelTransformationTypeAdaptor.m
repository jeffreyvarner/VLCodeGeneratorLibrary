//
//  VLCellFreeModelTransformationTypeAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 11/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCellFreeModelTransformationTypeAdaptor.h"

@implementation VLCellFreeModelTransformationTypeAdaptor

-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // check, do we have a specific language adaptor?
    if ([self myLanguageAdaptor] == nil)
    {
        // no languagae adaptor. Make Matlab the default
        self.myLanguageAdaptor = [[VLMatlabLanguageAdaptor alloc] init];
    }
    
    // ok, let's create a method pointer -
    if ([[self myLanguageAdaptor] respondsToSelector:_cmd] == YES)
    {
        //specify the function pointer
        typedef NSString* (*method_pointer)(id, SEL,NSDictionary*);
        
        // get the actual method -
        method_pointer command = (method_pointer)[[self myLanguageAdaptor] methodForSelector:_cmd];
        
        // run the method
        NSString *code_block = command([self myLanguageAdaptor],_cmd,options);
        [buffer appendString:code_block];
    }
    else
    {
        // ooops ...
        // Our language adaptor doesn't run this command. Send an error message -
        // ...
    }
    
    // return -
    return buffer;
}

@end
