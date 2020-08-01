/*****************************************************************
 *
 *                dirent.h
 *
 *****************************************************************/

#ifndef __DIRENT_H
#define __DIRENT_H

#include <errno.h>

#ifndef ENOTDIR
#define ENOTDIR     20
#endif

#ifndef NAME_MAX
#define NAME_MAX    31
#endif

struct dirent {
    unsigned long   d_fileno;
    short           d_reclen;
    short           d_namlen;
    char            d_name[NAME_MAX + 1];
};

typedef struct {
    short           ioFDirIndex;
    short           ioVRefNum;
    long            ioDrDirID;
    short           flags;
    struct dirent   currEntry;
} DIR;

#define direct dirent

DIR *opendir(char *);
struct dirent *readdir(DIR *);
void rewinddir(DIR *);
int closedir(DIR *);
#endif
