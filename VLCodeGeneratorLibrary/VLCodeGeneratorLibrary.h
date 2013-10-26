//
//  VLCodeGeneratorLibrary.h
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 10/2/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//
//test comment by ac2283 on 10/26

#import <Foundation/Foundation.h>
#import "VLAbstractLanguageAdaptor.h"
#import "VLTransformationServiceVendor.h"

@class VLGSLLanguageAdaptor;

typedef void (^VLCodeGeneratorLibraryJobDidCompleteBlock)(BOOL);

@interface VLCodeGeneratorLibrary : NSObject
{
    @private
    NSXMLDocument *_myTransformationBlueprintTree;
    NSXMLDocument *_myModelSpecificationTree;
    NSString *_myTransformationFilePath;
    NSString *_myTransformationLanguageAdaptor;
}

// properties -
@property (strong) NSXMLDocument *myTransformationBlueprintTree;
@property (strong) NSString *myTransformationFilePath;
@property (strong) NSString *myTransformationLanguageAdaptor;



// override the init method and grab the trees -
+(VLCodeGeneratorLibrary *)codeGeneratorInstance;

// public launch method -
-(void)executeCodeGenerationJobWithCompletionHandler:(VLCodeGeneratorLibraryJobDidCompleteBlock)block;


@end
