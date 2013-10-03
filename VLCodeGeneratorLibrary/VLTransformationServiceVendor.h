//
//  VLTransformationServiceVendor.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLAbstractLanguageAdaptor.h"

@interface VLTransformationServiceVendor : NSObject
{
    @protected
    NSXMLDocument *_myBlueprintTree;
    NSString *_myTransformationName;
    VLAbstractLanguageAdaptor *_myLanguageAdaptor;
    NSXMLDocument *_myVendorSelectorTree;
}

// Properties -
@property (retain) NSXMLDocument *myBlueprintTree;
@property (retain) NSString *myTransformationName;
@property (strong) VLAbstractLanguageAdaptor *myLanguageAdaptor;
@property (strong) NSXMLDocument *myVendorSelectorTree;

// Methods
-(void)cleanMyMemory;
-(void)startTransformationWithName:(NSString *)transformationName forModelTree:(NSXMLDocument *)modelTree;
-(void)stopTransformation;
-(void)postMessageTransformationMessage:(NSString *)message;

@end
