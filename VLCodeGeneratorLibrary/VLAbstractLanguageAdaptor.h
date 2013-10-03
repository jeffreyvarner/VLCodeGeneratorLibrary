//
//  VLAbstractLanguageAdaptor.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLAbstractLanguageAdaptor : NSObject
{
    
}



// general methods for all model types -
-(NSString *)generateModelDataStructureBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options;


@end
