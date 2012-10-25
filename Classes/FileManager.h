//
//  FileManager.h
//  prototype
//
//  Created by Ari Ronen on 10/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Terrain.h"

@interface FileManager : NSObject {
	int chunkOffsetX;
	int chunkOffsetZ;
	int oldOffsetX;
	int oldOffsetZ;
	NSString* documents;
    BOOL convertingWorld;
    BOOL genflat;
}
-(BOOL)worldExists:(NSString*)name;
-(void)saveColumn:(int)cx:(int)cz;
-(void)readColumn:(int)cx:(int)cz:(NSFileHandle*)nsfh;
-(void)saveWorld;
-(void)writeDirectory;
-(void)readDirectory;
-(void)clearDirectory;
-(void)convertFile:(NSString*) file_name;
-(NSString*)getName:(NSString*)file_name;

-(void)setName:(NSString*)file_name:(NSString*)display_name;
-(void)setImageHash:(NSString*)hash;
-(void)loadWorld:(NSString*)name;
-(BOOL)deleteWorld:(NSString*)name;
@property(nonatomic,readonly) int chunkOffsetX,chunkOffsetZ;
@property(nonatomic,readonly) NSString* documents;
@property(nonatomic,readonly) BOOL convertingWorld;
@property(nonatomic,assign) BOOL genflat;
@end
