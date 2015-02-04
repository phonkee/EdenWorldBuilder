//
//  FileArchive.c
//  Eden
//
//  Created by Ari Ronen on 5/10/14.
//
//

/*
#include <stdio.h>

#import "zlib.h"
#import "zpipe.h"
#import "FileArchive.h"
#import "World.h"

typedef struct _archData {
	NSString* descriptive_name;
    NSString* file_name;
} ArchiveEntry;

const char* archive_idx_file="archive.index";
ArchiveEntry ArchiveIndex[300];
int s_archive=0;
void init(){
    
    
    
}
NSString* getArchiveName(NSString* name){
    if([name length]<9)return NULL;
    name=[name stringByDeletingPathExtension];
    for(int i=0;i<s_archive;i++){
       // NSLog(@"%@!=%@",name,ArchiveIndex[i].file_name);
        if([ArchiveIndex[i].file_name isEqualToString:name]) {
            return ArchiveIndex[i].descriptive_name;
        }
    }
    return NULL;
    
    
}
BOOL writeIndex(){
    
    FILE* file = fopen([[NSString stringWithFormat:@"%@/%s",[World getWorld].fm.documents,archive_idx_file] cStringUsingEncoding:NSUTF8StringEncoding], "wb");
    if(!file){
        NSLog(@"can't open  archive file");
        return FALSE;
    }
    
    for(int i=0;i<s_archive;i++){
        const char* s1=[ArchiveIndex[i].file_name cStringUsingEncoding:NSUTF8StringEncoding];
        const char* s2=[ArchiveIndex[i].descriptive_name cStringUsingEncoding:NSUTF8StringEncoding];
        fprintg(file,"%s=%s\n",s1,s2);
    }
    
    
    fclose(file);
    return TRUE;
}

BOOL removeFromIndex(NSString* name){
    BOOL found=FALSE;
    for(int i=0;i<s_archive;i++){
        if([ArchiveIndex[i].file_name isEqualToString:name]) {
            [ArchiveIndex[i].file_name release];
            [ArchiveIndex[i].descriptive_name release];
            found=TRUE;
            s_archive--;
            for(int j=i;j<s_archive;j++){
                ArchiveIndex[j]=ArchiveIndex[j+1];
                
            }
            break;
        }
    }
    if(found){
        NSLog(@"archive entry found and removed\n");
        writeIndex();
    }
    return TRUE;
}


BOOL readIndex(){
    
  //  printg("Reading index...\n");
    FILE* file = fopen([[NSString stringWithFormat:@"%@/%s",[World getWorld].fm.documents,archive_idx_file] cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if(!file){
        NSLog(@"can't find or open  archive index file");
        return FALSE;
    }
    char buffer[1000];
    char file_name[500];
    char descriptive_name[500];
    s_archive=0;
    while(true){
        int n=fscanf(file," %[^\n]",buffer);
        if(n<=0)break;
        
        sscanf(buffer,"%[^=]=%[^\n]",file_name,descriptive_name);
        ArchiveIndex[s_archive].file_name=[NSString stringWithUTF8String:file_name];
        ArchiveIndex[s_archive].descriptive_name=[NSString stringWithUTF8String:descriptive_name];
        [ArchiveIndex[s_archive].file_name retain];
        [ArchiveIndex[s_archive].descriptive_name retain];
        s_archive++;
        if(s_archive==300)break;
       // printg("%s--%s\n",file_name,descriptive_name);
    }
     fclose(file);
    
   // printg("Done index...\n");
    return FALSE;
}


BOOL addToIndex(const char* fname,NSString* desc_name){
    if(s_archive>299)return FALSE;
    NSString* nsfname=[NSString stringWithUTF8String:fname];;
    int replaceEntry=-1;
    for(int i=0;i<s_archive;i++){
        if([ArchiveIndex[i].file_name isEqualToString:nsfname]){
            [ArchiveIndex[i].file_name release];
            [ArchiveIndex[i].descriptive_name release];
            replaceEntry=i;
            break;
        }
    }
    int idx=s_archive;
    if(replaceEntry!=-1){
        idx=replaceEntry;
    }
    ArchiveIndex[idx].file_name=nsfname;
    ArchiveIndex[idx].descriptive_name=desc_name;//
    
    [ArchiveIndex[idx].file_name retain];
    [ArchiveIndex[idx].descriptive_name retain];
    
     if(replaceEntry==-1)
         s_archive++;
    
    return writeIndex();
    
    
    
}

void CompressWorld(const char* aname){
    const char* fname=[[NSString stringWithFormat:@"%@/%s",[World getWorld].fm.documents,aname] cStringUsingEncoding:NSUTF8StringEncoding];
    NSString* temp_name=[NSString stringWithFormat:@"%s.archive",fname];
    const char* tname=[temp_name cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE* fsource = fopen(fname, "rb");
    if(!fsource){
        NSLog(@"can't open fsource");
        return;
    }
    
    
    FILE* fdest = fopen(tname, "wb");
    if(!fdest)
    {
        NSLog(@"cant open dest: %s",tname);
        
        return;
    }
    NSLog(@"Compressing  %s\n  ----> %s\n",fname,tname);
    int ret=compressFile(fsource, fdest,Z_DEFAULT_COMPRESSION);
    
    
    fclose(fsource);
    fclose(fdest);
    if (ret != Z_OK){
        zerr(ret);
        NSLog(@"Compression failed!");
        remove(tname);
        return;
    }
    
    if(addToIndex(aname,[[World getWorld].fm getName: [NSString stringWithUTF8String:aname]]))
    remove(fname);
    else{
        NSLog(@"Error adding file to index");
    }
    
    
    
}

BOOL DecompressWorld(const char* world){
    
    
   
    int len=strlen(world);
    if(len<12||len>250){
        NSLog(@"weird file name length, aborting decompress...");
        return FALSE;
    }
    NSString* tt=[NSString stringWithFormat:@"%s.archive",world];
    const char* fname=[tt cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSString* temp_name=[NSString stringWithFormat:@"%s",world];
    const char* tname=[temp_name cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE* fsource = fopen(fname, "rb");
    if(!fsource){
        NSLog(@"cant open %s",fname);
        return FALSE;
    }
    
    FILE* fdest = fopen(tname, "wb");
    if(!fdest)
    {
        NSLog(@"cant open dest %s",tname);
        fclose(fsource);
        return FALSE;
    }
   
    int ret=decompressFile(fsource, fdest);
    
    
    fclose(fsource);
    fclose(fdest);
   // remove(fname);
   // rename(tname,fname);
    if (ret != Z_OK){
        zerr(ret);
       remove(tname);
        return FALSE;
    }
     NSLog(@"Decompressed %s    --------------->    %s\n",fname,tname);
    
    return TRUE;
    
}*/
