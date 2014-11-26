//
//  ShareUtil.h
//  prototype
//
//  Created by Ari Ronen on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownload.h"

@interface ShareUtil : NSObject {
   FileDownload* dlmanager;
    BOOL isPreview,isWorldlist;
    NSString* listresult;
}
-(void)canceldl;
-(void)loadShared:(NSString*)file_name;
-(void)reportWorld:(NSString*)file_name;
-(void)loadSharedPreview:(NSString*)file_name;
- (void)shareWorld:(NSString*)file_name;
- (void)getSharedWorldList;
- (NSData *)gzipInflate:(NSData*)data;
-(void)uploadSuccess:(id)obj;
-(void)uploadError:(id)obj;
-(void)downloadSuccess:(id)obj;
-(void)reportSuccess:(id)obj;
-(void)reportError:(id)obj;

-(void)downloadError:(id)obj;
- (NSString*)searchSharedWorlds:(NSString*)query;
@property(nonatomic,assign)   NSString* listresult;
@end
