//
//  VLCoreUtilitiesLib.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>

@interface VLCoreUtilitiesLib : NSObject
{
    
}

// low level methods -
+(NSXMLDocument *)createXMLDocumentFromFile:(NSURL *)url;
+(NSXMLDocument *)createXMLDocumentFromSNLFile:(NSURL *)url;
+(NSXMLDocument *)createXMLDocumentFromVFFFile:(NSURL *)url;

+(NSArray *)executeXPathQuery:(NSString *)xpath withXMLTree:(NSXMLDocument *)document;
+(void)writeBuffer:(NSString *)buffer
             toURL:(NSURL *)fileURL;
+(NSArray *)loadGenericFlatFile:(NSString *)filePath
                 withRecordDeliminator:(NSString *)recordDeliminator
                  withFieldDeliminator:(NSString *)fieldDeliminator;

+(NSString *)lookupInputPathForTransformationWithName:(NSString *)transformName inTree:(NSXMLDocument *)blueprintTree;
+(NSString *)lookupOutputPathForTransformationWithName:(NSString *)transformName inTree:(NSXMLDocument *)blueprintTree;
+(NSString *)lookupOutputFileNameForTransformationWithName:(NSString *)transformName inTree:(NSXMLDocument *)blueprintTree;

// numerics -
+(CGFloat)generateSampleFromNormalDistributionWithMean:(CGFloat)mean
                                  andStandardDeviation:(CGFloat)standard_deviation;

@end
