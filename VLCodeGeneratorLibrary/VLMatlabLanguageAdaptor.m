//
//  VLMatlabLanguageAdaptor.m
//  VLCodeGeneratorLibrary
//
//  Created by Jeffrey Varner on 11/27/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLMatlabLanguageAdaptor.h"

@implementation VLMatlabLanguageAdaptor

#pragma mark - overrides
-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    // get the tree's
    __unused NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    __unused NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // ok, so what type of tree do we have comning in?
    if (self.myModelTreeType == VLAbstractLanguageAdaptorModelTreeTypeSBML)
    {
        
    }
    else if (self.myModelTreeType == VLAbstractLanguageAdaptorModelTreeTypePBPKML)
    {
        
    }
    else if (self.myModelTreeType == VLAbstractLanguageAdaptorModelTreeTypeCCML)
    {
        
    }
    else
    {
        // ooops ..
        // We are trying to process and unsupported input tree.
        // What should we do here?
    }
    
    
    return buffer;
}

#pragma mark - private logic
-(NSString *)generateModelDataStructureBufferWithTransformationTree:(NSXMLDocument *)transformationTree
                                                        andSBMLTree:(NSXMLDocument *)sbmlTree
{
    // initialize the buffer -
    NSMutableString *buffer = [[NSMutableString alloc] init];

    // what is the name?
    
    
    return buffer;
}

@end
