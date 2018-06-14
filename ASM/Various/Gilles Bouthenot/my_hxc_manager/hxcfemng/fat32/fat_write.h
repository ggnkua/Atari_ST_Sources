#ifndef __FAT_WRITE_H__
#define __FAT_WRITE_H__

#include "fat_defs.h"
#include "fat_opts.h"

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------
int		fatfs_add_file_entry(struct fatfs *fs, UINT32 dirCluster, char *filename, char *shortfilename, UINT32 startCluster, UINT32 size, int dir);
int		fatfs_add_free_space(struct fatfs *fs, UINT32 *startCluster);
int		fatfs_allocate_free_space(struct fatfs *fs, int newFile, UINT32 *startCluster, UINT32 size);

#endif
