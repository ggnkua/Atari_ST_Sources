#ifndef SCAN_H
#define SCAN_H

#include <stdio.h>

int parsefile(dev_t device, ino_t inode, const char *filename, 
#if defined(ASCII_DB)||defined(BINARY_DB)
FILE *outfp
#endif
#ifdef BERKELEY_DB
DB *outfp
#endif
);

#endif
