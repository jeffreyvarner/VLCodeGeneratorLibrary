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
            NSString *class_string = self.myTransformationLanguageAdaptor;
            VLAbstractLanguageAdaptor *language_adaptor = [[NSClassFromString(class_string) alloc] init];
            
            // Second, build the transformation service vendor, set some props -
            VLTransformationServiceVendor *transformation_service_vendor = [[VLTransformationServiceVendor alloc] init];
            [transformation_service_vendor setMyLanguageAdaptor:language_adaptor];
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
}


@end
