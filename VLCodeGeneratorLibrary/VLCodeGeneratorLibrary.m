//
//  VLCodeGeneratorLibrary.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/2/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCodeGeneratorLibrary.h"
#import "VLFileFormatTransformationTypeAdaptor.h"
#import "VLAbstractTransformationTypeAdaptor.h"

#import "VLFileFormatTransformationTypeAdaptor.h"
#import "VLSMBLLanguageAdaptor.h"


@interface VLCodeGeneratorLibrary ()

@property (strong) NSXMLDocument *myModelSpecificationTree;

// methods -
-(void)setup;
-(void)cleanMyMemory;

// private conversion methods for legacy input formats -


@end

@implementation VLCodeGeneratorLibrary

+(VLCodeGeneratorLibrary *)codeGeneratorInstance
{
    VLCodeGeneratorLibrary *lib_instance = [[[self class] alloc] init];
    
    // call setup -
    [lib_instance setup];
    
    // return -
    return lib_instance;
}

-(void)dealloc
{
    [self cleanMyMemory];
}

#pragma mark - public methods
-(void)executeCodeGenerationJobWithCompletionHandler:(VLCodeGeneratorLibraryJobDidCompleteBlock)block
{
    BOOL DID_JOB_COMPLETE_FLAG = YES;
    
    if (block == nil)
    {
        return;
    }

    // do we have the transformation tree -and- the configuration tree?
    if ([self myCodeGeneratorConfigurationTree]==nil || [self myTransformationBlueprintTree]==nil)
    {
        DID_JOB_COMPLETE_FLAG = NO;
        block(DID_JOB_COMPLETE_FLAG);
        return;
    }
    
    // ok, look up the transformations that I need to execute
    NSError *transformation_lookup_error;
    NSArray *transformation_node_array = [[self myTransformationBlueprintTree] nodesForXPath:@".//Transformation" error:&transformation_lookup_error];
    
    if ([transformation_node_array count] == 0)
    {
        // prepare message -
        NSString *message_string = [NSString stringWithFormat:@"ERROR: No transformations found at model file %@\n",[self myTransformationFilePath]];
        [self sendMessage:message_string toNotificationWithName:VLTransformationJobProgressUpdateNotification];
    }
    else
    {
        // prepare message -
        NSString *message_string = [NSString stringWithFormat:@"Found %lu transformations. Starting ...",[transformation_node_array count]];
        [self sendMessage:message_string toNotificationWithName:VLTransformationJobProgressUpdateNotification];
    }
    
    // process each transformation -
    for (NSXMLElement *transformation_node in transformation_node_array)
    {
        // Get the reqd information for this transformation -
        NSString *transformationName = [[transformation_node attributeForName:@"name"] stringValue];
        NSString *language_key = [[transformation_node attributeForName:@"language_key"] stringValue];
        NSString *type_key = [[transformation_node attributeForName:@"transformation_key"] stringValue];
        NSString *vendor_key = [[transformation_node attributeForName:@"vendor_key"] stringValue];
        
        NSError *error;
        NSString *myInputFilePath = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='INPUT_FILE_PATH']/@value" error:&error] lastObject] stringValue];
        NSString *myModelFileName = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='MODEL_FILE_NAME']/@value" error:&error] lastObject] stringValue];
        
        // Next, we need to check to see if my input is an xml type (we could have legacy FF formats for example)
        // Do we have a model type flag *in* this transformation, is it type VFF?
        NSXMLDocument *model_tree;
        NSString *xpath_model_type = @".//property[@key='MODEL_FILE_TYPE']/@value";
        NSArray *value_node_array = [transformation_node nodesForXPath:xpath_model_type error:&transformation_lookup_error];
        if (value_node_array!=nil && [value_node_array count]>0)
        {
            NSString *local_file_type = [[value_node_array lastObject] stringValue];
            if ([local_file_type isCaseInsensitiveLike:@"VFF"] == YES)
            {
                NSError *error;
                NSString *xpath_model_name = @"./property[@key='INPUT_FILE_NAME']/@value";
                NSString *myModelFileName = [[[transformation_node nodesForXPath:xpath_model_name error:&error] lastObject] stringValue];
                NSString *path_to_model_file = [NSString stringWithFormat:@"%@%@",myInputFilePath,myModelFileName];
                
                // Load the model file -
                NSURL *fileURL = [NSURL fileURLWithPath:path_to_model_file];

                // we have a legacy VFF type. We need to convert this to an xml tree -
                model_tree = [VLCoreUtilitiesLib createXMLDocumentFromVFFFile:fileURL];
            }
            else
            {
                // we have a local tree that is an XML type. Load it -
                NSError *error;
                NSString *xpath_model_name = @".//property[@key='MODEL_FILE_NAME']/@value";
                NSString *myModelFileName = [[[transformation_node nodesForXPath:xpath_model_name error:&error] lastObject] stringValue];
                NSString *path_to_model_file = [NSString stringWithFormat:@"%@%@",myInputFilePath,myModelFileName];
                
                // Load the model file -
                NSURL *fileURL = [NSURL fileURLWithPath:path_to_model_file];
                model_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:fileURL];
            }
        }
        else
        {
            // ok, we do not have a local tree override, let's use the global tree
            NSString *path_to_model_file = [NSString stringWithFormat:@"%@%@",myInputFilePath,myModelFileName];
            
            // Load the model file -
            NSURL *fileURL = [NSURL fileURLWithPath:path_to_model_file];
            model_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:fileURL];
        }
        
        
        // Next, build the transformation service vendor, set some props -
        VLTransformationServiceVendor *transformation_service_vendor = [[VLTransformationServiceVendor alloc] init];
        [transformation_service_vendor setMyBlueprintTree:[self myTransformationBlueprintTree]];
        [transformation_service_vendor setMyCodeGenerationConfigurationTree:[self myCodeGeneratorConfigurationTree]];
        
        // Get the selector -
        // lookup the selector using vendor_key in myVendorSelector tree -
        NSError *xpath_error;
        NSString *selector_xpath_string = [NSString stringWithFormat:@".//record[@vendor_key='%@']/@selector",vendor_key];
        NSArray *selector_array = [[self myCodeGeneratorConfigurationTree] nodesForXPath:selector_xpath_string error:&xpath_error];
        NSString *selector_string = [[selector_array lastObject] stringValue];
        
        // First, we need to lookup the language and transformation adaptors -
        NSString *xpath_transformation = [NSString stringWithFormat:@".//TransformationMap/transform_type[@transformation_key='%@']/@transform_adaptor",type_key];
        NSString *transformation_adaptor_class_string = [[[[self myCodeGeneratorConfigurationTree] nodesForXPath:xpath_transformation error:nil] lastObject] stringValue];
        
        NSString *xpath_language = [NSString stringWithFormat:@".//LanguageMap/language_type[@language_key='%@']/@language_adaptor",language_key];
        NSString *language_adaptor_class_string = [[[[self myCodeGeneratorConfigurationTree] nodesForXPath:xpath_language error:nil] lastObject] stringValue];
        
        //Next, build the language and type adaptors -
        //Class my_language_adaptor_class = NSClassFromString(language_adaptor_class_string);
        VLAbstractLanguageAdaptor *language_adaptor = [[VLSMBLLanguageAdaptor alloc] init];
        VLAbstractTransformationTypeAdaptor *transformation_adaptor = [[VLFileFormatTransformationTypeAdaptor alloc] init];
        
        // Last, execute -
        [transformation_service_vendor startTransformationWithNode:transformation_node
                                                           nameKey:transformationName
                                                           typeKey:type_key
                                                       languageKey:language_key
                                                         vendorKey:selector_string
                                                   languageAdaptor:language_adaptor
                                             transformationAdaptor:transformation_adaptor
                                                      forModelTree:model_tree];
        
        // prepare message -
        NSString *message_string = [NSString stringWithFormat:@"Submitted transformation %@ for processing .... :-)",transformationName];
        [self sendMessage:message_string toNotificationWithName:VLTransformationJobProgressUpdateNotification];
    }
    
    // call completion handler -
    DID_JOB_COMPLETE_FLAG = YES;
    block(DID_JOB_COMPLETE_FLAG);

}

#pragma mark - private helpers
-(void)sendMessage:(NSString *)message toNotificationWithName:(NSString *)notificationName
{
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:message];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - private lifecyle
-(void)setup
{
    
}

-(void)cleanMyMemory
{
    self.myModelSpecificationTree = nil;
    self.myTransformationBlueprintTree = nil;
    self.myTransformationFilePath = nil;
    self.myTransformationLanguageAdaptor = nil;
    self.myTransformationTypeAdaptor = nil;
}


@end
