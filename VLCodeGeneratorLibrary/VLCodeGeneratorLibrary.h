//
//  VLCodeGeneratorLibrary.h
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/2/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLAbstractLanguageAdaptor.h"
#import "VLTransformationServiceVendor.h"

@class VLAbstractTransformationTypeAdaptor;
@class VLGSLLanguageAdaptor;

typedef void (^VLCodeGeneratorLibraryJobDidCompleteBlock)(BOOL);

@interface VLCodeGeneratorLibrary : NSObject
{
    @private
    NSXMLDocument *_myTransformationBlueprintTree;
    NSXMLDocument *_myModelSpecificationTree;
    NSXMLDocument *_myCodeGeneratorConfigurationTree;
    
    
    NSString *_myTransformationFilePath;
    NSString *_myTransformationLanguageAdaptor;
    NSString *_myTransformationTypeAdaptor;
}

// properties -
@property (strong) NSXMLDocument *myTransformationBlueprintTree;
@property (strong) NSXMLDocument *myCodeGeneratorConfigurationTree;

@property (strong) NSString *myTransformationFilePath;
@property (strong) NSString *myTransformationLanguageAdaptor;
@property (strong) NSString *myTransformationTypeAdaptor;



// override the init method and grab the trees -
+(VLCodeGeneratorLibrary *)codeGeneratorInstance;

// public launch method -
-(void)executeCodeGenerationJobWithCompletionHandler:(VLCodeGeneratorLibraryJobDidCompleteBlock)block;


@end
