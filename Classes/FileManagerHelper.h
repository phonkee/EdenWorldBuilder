//
//  FileManagerHelper.h
//  Eden
//
//  Created by Ari Ronen on 5/20/14.
//
//

#import <Foundation/Foundation.h>
#import "FileManager.h"
@interface FileManagerHelper : NSObject
void fmh_init(FileManager* tfm);
void fmh_readColumnFromDefault(int cx,int cz);


@end
