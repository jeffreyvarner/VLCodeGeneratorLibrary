//
//  VLTransformationServiceVendor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLTransformationServiceVendor.h"

@interface VLTransformationServiceVendor ()


@end

@implementation VLTransformationServiceVendor

// synthesize
@synthesize myBlueprintTree = _myBlueprintTree;
@synthesize myTransformationName = _myTransformationName;
@synthesize myLanguageAdaptor = _myLanguageAdaptor;

-(void)dealloc
{
    [self cleanMyMemory];
}

-(void)cleanMyMemory
{
    self.myBlueprintTree = nil;
    self.myTransformationName = nil;
    self.myLanguageAdaptor = nil;
    self.myVendorSelectorTree = nil;
}

-(void)postMessageTransformationMessage:(NSString *)message
{
    // dispatch -
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Make a message and send -
        NSNotification *myNotification = [NSNotification notificationWithName:VLTransformationJobProgressUpdateNotification
                                                                       object:message];
        
        [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    });
}

#pragma mark - override these methods in subclass
-(void)startTransformationWithName:(NSString *)transformationName forModelTree:(NSXMLDocument *)modelTree
{
    // grab the name (before we start) -
    self.myTransformationName = transformationName;
    
    // Get the code generation engine -
    VLCodeGenerationFoundationServer *codeGenerationEngine = [VLCodeGenerationFoundationServer sharedFoundationServer];
    
    // Get file paths -
    __unused NSString *inputFilePath = [VLCoreUtilitiesLib lookupInputPathForTransformationWithName:transformationName inTree:[self myBlueprintTree]];
    NSString *outputFilePath = [VLCoreUtilitiesLib lookupOutputPathForTransformationWithName:transformationName inTree:[self myBlueprintTree]];
    NSString *outputFileName = [VLCoreUtilitiesLib lookupOutputFileNameForTransformationWithName:transformationName inTree:[self myBlueprintTree]];
    
    // Formulate the blocks and go -
    __block NSMutableString *buffer = [[NSMutableString alloc] init];
    NSXMLDocument *myBlueprintDocument = [self myBlueprintTree];
    
    // Setup blocks -
    // Input handler block -
    __weak VLTransformationServiceVendor *weak_self = self;
    void (^VLOperationBlock)(void) = ^{
        
        // Create the buffer -
        buffer = [NSMutableString string];
        
        // Use my language adaptor to generate data file code in specified language -
        NSDictionary *options = @
        {
            kXMLModelTree : modelTree,
            kXMLTransformationTree : myBlueprintDocument
        };
        
        // ok, do we have a selector tree?
        if ([weak_self myVendorSelectorTree]!=nil)
        {
            // Get the vendor_key for this transformation -
            NSError *xpath_error;
            NSString *xpath = [NSString stringWithFormat:@".//Transformation[@name='%@']/@vendor_key",transformationName];
            NSString *vendor_key = [[[[self myBlueprintTree] nodesForXPath:xpath error:&xpath_error] lastObject] stringValue];
            
            // lookup the vendor key in myVendorSelector tree -
            NSString *selector_xpath_string = [NSString stringWithFormat:@".//record[@vendor_key='%@']/@selector",vendor_key];
            NSString *selector_string = [[[[weak_self myVendorSelectorTree] nodesForXPath:selector_xpath_string error:&xpath_error] lastObject] stringValue];
            
            NSLog(@"vendor_key = %@ selector_string = %@",vendor_key,selector_string);
            
            if (selector_string!=nil)
            {
                // get the selector -
                SEL code_transformation_selector = NSSelectorFromString(selector_string);
                
                NSLog(@"Language adaptor = %@",[[self myLanguageAdaptor] debugDescription]);
                
                // does the language adaptor have this selector?
                if ([[weak_self myLanguageAdaptor] respondsToSelector:code_transformation_selector] == YES)
                {
                    //specify the function pointer
                    typedef NSString* (*methodPtr)(id, SEL,NSDictionary*);
                    
                    //get the actual method
                    methodPtr command = (methodPtr)[[weak_self myLanguageAdaptor] methodForSelector:code_transformation_selector];
                    
                    //run the method
                    NSString *code_block = command([weak_self myLanguageAdaptor],code_transformation_selector,options);
                    [buffer appendString:code_block];
                }
                else
                {
                    // print message to console -
                    NSString *message = [NSString stringWithFormat:@"ERROR: Missing or incorrect selector requested for %@",transformationName];
                    [weak_self postMessageTransformationMessage:message];
                }
            }
            else
            {
                // print message to console -
                NSString *message = [NSString stringWithFormat:@"ERROR: Missing or incorrect vendor_key requested for %@",transformationName];
                [weak_self postMessageTransformationMessage:message];
            }
        }
        else
        {
            // print message to console -
            NSString *message = [NSString stringWithFormat:@"ERROR: Missing or incorrect vendor_key requested for %@",transformationName];
            [weak_self postMessageTransformationMessage:message];
        }
    };
    
    // Output handler block -
    void (^VLCompletionBlock)(void) = ^{
        
        // dump the buffer to disk -
        NSString *fullPathString = [NSString stringWithFormat:@"%@%@",outputFilePath,outputFileName];
        NSURL *fileURL = [NSURL fileURLWithPath:fullPathString];
        
        // Create *final* output string -
        NSString *output = [NSString stringWithString:buffer];
        
        // dump -
        [VLCoreUtilitiesLib writeBuffer:output toURL:fileURL];
        
        // print message to console -
        NSString *message = [NSString stringWithFormat:@"Completed transformation: %@",transformationName];
        [weak_self postMessageTransformationMessage:message];
    };
    
    
    // No dependecy, launch single operation -
    [codeGenerationEngine performSingleOperationWithName:transformationName
                                                   block:VLOperationBlock
                                              completion:VLCompletionBlock];
}

-(void)stopTransformation
{
    
}


@end
