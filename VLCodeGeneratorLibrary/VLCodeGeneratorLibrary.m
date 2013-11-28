//
//  VLCodeGeneratorLibrary.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/2/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCodeGeneratorLibrary.h"
#import "VLGSLLanguageAdaptor.h"

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
        
        NSError *error;
        NSString *myInputFilePath = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='INPUT_FILE_PATH']/@value" error:&error] lastObject] stringValue];
        NSString *myModelFileName = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='MODEL_FILE_NAME']/@value" error:&error] lastObject] stringValue];
        
        // First, we need to loopup the language and transformation adaptors -
        NSString *xpath_transformation = [NSString stringWithFormat:@".//TransformationMap/transform_type[@transformation_key='%@']/transform_adaptor",type_key];
        NSString *transformation_adaptor = [[[[self myCodeGeneratorConfigurationTree] nodesForXPath:xpath_transformation error:nil] lastObject] stringValue];
        self.myTransformationTypeAdaptor = transformation_adaptor;
        
        NSString *xpath_language = [NSString stringWithFormat:@".//LanguageMap/language_type[@language_key='%@']/language_adaptor",language_key];
        NSString *language_adaptor = [[[[self myCodeGeneratorConfigurationTree] nodesForXPath:xpath_language error:nil] lastObject] stringValue];
        self.myTransformationLanguageAdaptor = language_adaptor;
        
        // First, build the language and type adaptor strings -
        NSString *language_adaptor_class_string = self.myTransformationLanguageAdaptor;
        NSString *transformation_adaptor_class_string = self.myTransformationTypeAdaptor;
        VLAbstractLanguageAdaptor *language_adaptor_class = [[NSClassFromString(language_adaptor_class_string) alloc] init];
        VLAbstractTransformationTypeAdaptor *transformation_adaptor_class = [[NSClassFromString(transformation_adaptor_class_string) alloc] init];
        
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
                // we have a legacy VFF type. We need to convert this to an xml tree -
                
            }
            else
            {
                // we have a local tree that is an XML type. Load it -
                NSError *error;
                NSString *xpath_model_name = @".//property[@key='MODEL_FILE_NAME']/@value";
                NSString *myModelFileName = [[[transformation_node nodesForXPath:xpath_model_name error:&error] lastObject] stringValue];
                NSString *myInputFilePath = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='INPUT_FILE_PATH']/@value" error:&error] lastObject] stringValue];
                
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
        [transformation_service_vendor setMyLanguageAdaptor:language_adaptor_class];
        [transformation_service_vendor setMyTransformationAdaptor:transformation_adaptor_class];
        [transformation_service_vendor setMyTransformationName:transformationName];
        [transformation_service_vendor setMyBlueprintTree:[self myTransformationBlueprintTree]];
        [transformation_service_vendor setMyVendorSelectorTree:[self myCodeGeneratorConfigurationTree]];
        
        // Last, execute -
        [transformation_service_vendor startTransformationWithName:transformationName
                                                      forModelTree:model_tree];
        
        // prepare message -
        NSString *message_string = [NSString stringWithFormat:@"Submitted transformation %@",transformationName];
        [self sendMessage:message_string toNotificationWithName:VLTransformationJobProgressUpdateNotification];
    }
    
    // call completion handler -
    DID_JOB_COMPLETE_FLAG = YES;
    block(DID_JOB_COMPLETE_FLAG);

}

-(void)executeCodeGenerationJobWithCompletionHandlerOld:(VLCodeGeneratorLibraryJobDidCompleteBlock)block
{
    BOOL DID_JOB_COMPLETE_FLAG = YES;
    
    if (block == nil)
    {
        return;
    }
    
    // Load the model specification tree -
    NSError *error;
    NSString *myInputFilePath = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='INPUT_FILE_PATH']/@value" error:&error] lastObject] stringValue];
    NSString *myModelFileName = [[[[self myTransformationBlueprintTree] nodesForXPath:@".//listOfGlobalTransformationProperties/property[@key='MODEL_FILE_NAME']/@value" error:&error] lastObject] stringValue];
    NSString *path_to_model_file = [NSString stringWithFormat:@"%@%@",myInputFilePath,myModelFileName];
    
    // Load the model file -
    NSURL *fileURL = [NSURL fileURLWithPath:path_to_model_file];
    NSXMLDocument *model_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:fileURL];
    
    // do we have the model tree?
    if (model_tree!=nil &&
        error == nil)
    {
        // ok, so we have the tree. Let's run transformations -
        self.myModelSpecificationTree = model_tree;
        
        // Need to load the selector_vendor map -
        NSXMLDocument *selector_document;
        NSString *path_to_mapping_file = [[NSBundle mainBundle] pathForResource:@"Selectors" ofType:@"xml"];
        if (path_to_mapping_file!=nil)
        {
            // load XML file and get output nodes -
            selector_document = [VLCoreUtilitiesLib createXMLDocumentFromFile:[NSURL fileURLWithPath:path_to_mapping_file]];
        }
        else
        {
            // report error -
            NSString *message_string = [NSString stringWithFormat:@"ERROR: Missing vendor_key or mapping tree for %@\n",myModelFileName];
            [self sendMessage:message_string toNotificationWithName:VLTransformationJobProgressUpdateNotification];
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
            // Get the name of this transformation -
            NSString *transformationName = [[transformation_node attributeForName:@"name"] stringValue];
            
            // prepare message -
            NSString *message_string = [NSString stringWithFormat:@"Processing transformation %@",transformationName];
            [self sendMessage:message_string toNotificationWithName:VLTransformationJobProgressUpdateNotification];
            
            // Setup transformation vendor -
            // First, build the language adaptor -
            NSString *language_adaptor_class_string = self.myTransformationLanguageAdaptor;
            NSString *transformation_adaptor_class_string = self.myTransformationTypeAdaptor;
            VLAbstractLanguageAdaptor *language_adaptor = [[NSClassFromString(language_adaptor_class_string) alloc] init];
            VLAbstractTransformationTypeAdaptor *transformation_adaptor = [[NSClassFromString(transformation_adaptor_class_string) alloc] init];
            
            // Second, build the transformation service vendor, set some props -
            VLTransformationServiceVendor *transformation_service_vendor = [[VLTransformationServiceVendor alloc] init];
            [transformation_service_vendor setMyLanguageAdaptor:language_adaptor];
            [transformation_service_vendor setMyTransformationAdaptor:transformation_adaptor];
            [transformation_service_vendor setMyTransformationName:transformationName];
            [transformation_service_vendor setMyBlueprintTree:[self myTransformationBlueprintTree]];
            [transformation_service_vendor setMyVendorSelectorTree:selector_document];
            
            // Last, execute -
            [transformation_service_vendor startTransformationWithName:transformationName
                                                          forModelTree:model_tree];
        }
        
        // call completion handler -
        DID_JOB_COMPLETE_FLAG = YES;
        block(DID_JOB_COMPLETE_FLAG);
    }
    else
    {
        DID_JOB_COMPLETE_FLAG = NO;
        
        // call the completion handler -
        block(DID_JOB_COMPLETE_FLAG);
    }
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
