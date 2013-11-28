//
//  VLTransformationServiceVendor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLTransformationServiceVendor.h"
#import "VLAbstractTransformationTypeAdaptor.h"

@interface VLTransformationServiceVendor ()

@property (strong) VLAbstractLanguageAdaptor *myLanguageAdaptor;
@property (strong) VLAbstractTransformationTypeAdaptor *myTransformationAdaptor;

@end

@implementation VLTransformationServiceVendor


-(void)dealloc
{
    [self cleanMyMemory];
}

-(void)cleanMyMemory
{
    self.myBlueprintTree = nil;
    self.myTransformationName = nil;
    self.myCodeGenerationConfigurationTree = nil;
}

-(void)postMessageTransformationMessage:(NSString *)message
{
    NSLog(@"message: %@",message);
    
    // dispatch -
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Make a message and send -
        NSNotification *myNotification = [NSNotification notificationWithName:VLTransformationJobProgressUpdateNotification
                                                                       object:message];
        
        [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    });
}

#pragma mark - override these methods in subclass
-(void)startTransformationWithNode:(NSXMLElement *)transformationNode
                           nameKey:(NSString *)transformationName
                           typeKey:(NSString *)type_key
                       languageKey:(NSString *)language_key
                         vendorKey:(NSString *)vendorKey
                   languageAdaptor:(VLAbstractLanguageAdaptor *)languageAdaptor
             transformationAdaptor:(VLAbstractTransformationTypeAdaptor *)transformationAdaptor
                      forModelTree:(NSXMLDocument *)modelTree
{
    
    // do have the myCodeGenerationConfigurationTree?
    if ([self myCodeGenerationConfigurationTree] == nil)
    {
        // print message to console -
        NSString *message = [NSString stringWithFormat:@"ERROR: Missing or incorrect vendor_key requested for %@",transformationName];
        [self postMessageTransformationMessage:message];
        return;
    }
    
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
        
        
        NSString *selector_string = vendorKey;
        if (selector_string!=nil)
        {
            // get the selector -
            SEL code_transformation_selector = NSSelectorFromString(selector_string);
        
            // does the language adaptor have this selector?
            if ([transformationAdaptor respondsToSelector:code_transformation_selector] == YES)
            {
                // ok, so we need to set the language adaptor reference *on* my transformation adaptor
                // so we know what language to generate the code in
                [transformationAdaptor setMyTransformationName:transformationName];
                
                //specify the function pointer
                typedef NSString* (*methodPtr)(id, SEL,NSDictionary*);
                
                //get the actual method
                methodPtr command = (methodPtr)[transformationAdaptor methodForSelector:code_transformation_selector];
                
                //run the method
                NSString *code_block = command(transformationAdaptor,code_transformation_selector,options);
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
