#ifndef __FAT_CACHE_H__
#define __FAT_CACHE_H__

#include "fat_filelib.h"

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------
int		fatfs_cache_init(struct fatfs *fs, FL_FILE *file);
int		fatfs_cache_get_next_cluster(struct fatfs *fs, FL_FILE *file, UINT32 clusterIdx, UINT32 *pNextCluster);
int		fatfs_cache_set_next_cluster(struct fatfs *fs, FL_FILE *file, UINT32 clusterIdx, UINT32 nextCluster);

int		fatfs_browse_cache_init(struct fatfs *fs);
int		fatfs_browse_cache_get_next_cluster(struct fatfs *fs, UINT32 clusterIdx, UINT32 *pNextCluster);
int		fatfs_browse_cache_set_next_cluster(struct fatfs *fs, UINT32 clusterIdx, UINT32 nextCluster);

#endif
