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
    NSXMLDocument *_myVendorSelectorTree;
    
    VLAbstractLanguageAdaptor *_myLanguageAdaptor;
    VLAbstractTransformationTypeAdaptor *_myTransformationAdaptor;
    
}

// Properties -
@property (retain) NSXMLDocument *myBlueprintTree;
@property (retain) NSString *myTransformationName;
@property (strong) NSXMLDocument *myVendorSelectorTree;
@property (strong) VLAbstractLanguageAdaptor *myLanguageAdaptor;
@property (strong) VLAbstractTransformationTypeAdaptor *myTransformationAdaptor;

// Methods
-(void)cleanMyMemory;
-(void)startTransformationWithName:(NSString *)transformationName forModelTree:(NSXMLDocument *)modelTree;
-(void)stopTransformation;
-(void)postMessageTransformationMessage:(NSString *)message;

@end
