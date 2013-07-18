//
//  main.m
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  /*  NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"App Directory is: %@", appFolderPath);
    NSLog(@"Directory Contents:\n%@", [fileManager directoryContentsAtPath: appFolderPath]);*/
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    
    [pool release];
    return retVal;
}






//(x,z) 13  //(x,z,)=14