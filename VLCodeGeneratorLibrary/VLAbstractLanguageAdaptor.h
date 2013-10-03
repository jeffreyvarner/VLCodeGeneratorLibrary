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

// kinetics -
-(NSString *)generateModelOperationKineticsBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelOperationKineticsHeaderBufferWithOptions:(NSDictionary *)options;

// massbalances -
-(NSString *)generateModelMassBalancesImplBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateModelMassBalancesHeaderBufferWithOptions:(NSDictionary *)options;

// driver -
-(NSString *)generateModelDriverImplBufferWithOptions:(NSDictionary *)options;

// make -
-(NSString *)generateModelMakeFileImplBufferWithOptions:(NSDictionary *)options;

@end
