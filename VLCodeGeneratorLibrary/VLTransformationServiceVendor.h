//
//  VLTransformationServiceVendor.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLAbstractLanguageAdaptor.h"

@class VLAbstractTransformationTypeAdaptor;

@interface VLTransformationServiceVendor : NSObject
{
    @protected
    NSXMLDocument *_myBlueprintTree;
    NSString *_myTransformationName;
    NSXMLDocument *_myCodeGenerationConfigurationTree;
    
    VLAbstractLanguageAdaptor *_myLanguageAdaptor;
    VLAbstractTransformationTypeAdaptor *_myTransformationAdaptor;
    
}

// Properties -
@property (retain) NSXMLDocument *myBlueprintTree;
@property (retain) NSString *myTransformationName;
@property (strong) NSXMLDocument *myCodeGenerationConfigurationTree;

// Methods
-(void)cleanMyMemory;
-(void)startTransformationWithNode:(NSXMLElement *)transformationNode
                           nameKey:(NSString *)transformationName
                           typeKey:(NSString *)type_key
                       languageKey:(NSString *)language_key
                         vendorKey:(NSString *)vendorKey
                   languageAdaptor:(VLAbstractLanguageAdaptor *)languageAdaptor
             transformationAdaptor:(VLAbstractTransformationTypeAdaptor *)transformationAdaptor
                      forModelTree:(NSXMLDocument *)modelTree;

-(void)stopTransformation;
-(void)postMessageTransformationMessage:(NSString *)message;

@end
