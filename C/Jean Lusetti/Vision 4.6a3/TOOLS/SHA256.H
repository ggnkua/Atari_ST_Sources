#ifndef __SHA256_H
#define __SHA256_H

typedef unsigned long uint32 ;

/* Compute SHA256 from a file contents:                              */
/* Returns:  0: Success, SHA256 is filled in sha256 array (32 bytes) */
/*          -1: Error, file can't be opened                          */
long fSHA256(char* name, uint32 sha256[8]) ;

/* Compute SHA256 from memory:                           */
/* Returns:  SHA256 is filled in sha256 array (32 bytes) */
void mSHA256(void* data, uint32 size, uint32 sha256[8]) ;

#endif
