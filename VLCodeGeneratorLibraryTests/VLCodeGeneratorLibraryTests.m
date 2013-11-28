//
//  VLCodeGeneratorLibraryTests.m
//  VLCodeGeneratorLibraryTests
//
//  Created by Jeffrey Varner on 10/2/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLCoreUtilitiesLib.h"
#import "VLAbstractLanguageAdaptor.h"
#import "VLCodeGeneratorLibrary.h"

@interface VLCodeGeneratorLibraryTests : XCTestCase

@end

@implementation VLCodeGeneratorLibraryTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testCreateXMLDocumentFromVFFFile
{
    // load the files -
    NSString *test_model_file_path = @"/Users/jeffreyvarner/Desktop/TestTransformation/Alternative.net";
    NSURL *test_model_url = [NSURL fileURLWithPath:test_model_file_path];
    
    NSXMLDocument *model_tree = [VLCoreUtilitiesLib createXMLDocumentFromVFFFile:test_model_url];
    //NSLog(@"%@",[model_tree debugDescription]);
}

-(void)testGenerateSBMLFileFromVFFFile
{
    NSString *test_configuration_file_path = @"/Users/jeffreyvarner/Desktop/TestTransformation/CodeGeneratorConfiguration.xml";
    NSString *test_transformation_file_path = @"/Users/jeffreyvarner/Desktop/TestTransformation/Transformation.xml";
    
    NSURL *transformation_url = [NSURL fileURLWithPath:test_transformation_file_path];
    NSURL *configuration_url = [NSURL fileURLWithPath:test_configuration_file_path];
    
    NSXMLDocument *transformation_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:transformation_url];
    NSXMLDocument *configuration_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:configuration_url];
    
    
    void (^MyCompletionBlock)(BOOL) = ^(BOOL success)
    {
        NSLog(@"Got %hhd back",success);
    };
    
    // Build the generator -
    VLCodeGeneratorLibrary *generator = [VLCodeGeneratorLibrary codeGeneratorInstance];
    [generator setMyCodeGeneratorConfigurationTree:configuration_tree];
    [generator setMyTransformationBlueprintTree:transformation_tree];
    [generator executeCodeGenerationJobWithCompletionHandler:MyCompletionBlock];
}

//-(void)testGenerateCirculationMatrixMethod
//{
//    // load the files -
//    NSString *transformation_file_path = @"/Users/jeffreyvarner/Desktop/MyUniversalProjects/PBPKModelGenerator/conf/Transformation.xml";
//    NSString *model_file_path = @"/Users/jeffreyvarner/Desktop/MyUniversalProjects/PBPKModelGenerator/conf/Model.xml";
//    
//    NSURL *transformation_url = [NSURL fileURLWithPath:transformation_file_path];
//    NSURL *model_url = [NSURL fileURLWithPath:model_file_path];
//    
//    NSXMLDocument *transformation_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:transformation_url];
//    NSXMLDocument *model_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:model_url];
//    NSDictionary *options = @
//    {
//        kXMLTransformationTree: transformation_tree,
//        kXMLModelTree: model_tree
//    };
//    
//    VLAbstractLanguageAdaptor *adapter = [[VLAbstractLanguageAdaptor alloc] init];
//    [adapter generateModelCirculationMatrixBufferWithOptions:options];
//}
//
//-(void)testGenerateStoichiometricMatrixMethod
//{
//    // load the files -
//    NSString *transformation_file_path = @"/Users/jeffreyvarner/Desktop/MyUniversalProjects/PBPKModelGenerator/conf/Transformation.xml";
//    NSString *model_file_path = @"/Users/jeffreyvarner/Desktop/MyUniversalProjects/PBPKModelGenerator/conf/Model.xml";
//    
//    NSURL *transformation_url = [NSURL fileURLWithPath:transformation_file_path];
//    NSURL *model_url = [NSURL fileURLWithPath:model_file_path];
//    
//    NSXMLDocument *transformation_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:transformation_url];
//    NSXMLDocument *model_tree = [VLCoreUtilitiesLib createXMLDocumentFromFile:model_url];
//    NSDictionary *options = @
//    {
//        kXMLTransformationTree: transformation_tree,
//        kXMLModelTree: model_tree
//    };
//    
//    VLAbstractLanguageAdaptor *adapter = [[VLAbstractLanguageAdaptor alloc] init];
//    [adapter generateModelStoichiometricMatrixBufferWithOptions:options];
//}


@end
