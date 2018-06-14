//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//					        FAT16/32 File IO Library
//								    V2.6
// 	  							 Rob Riglar
//						    Copyright 2003 - 2010
//
//   					  Email: rob@robriglar.com
//
//								License: GPL
//   If you would like a version with a more permissive license for use in
//   closed source commercial applications please contact me for details.
//-----------------------------------------------------------------------------
//
// This file is part of FAT File IO Library.
//
// FAT File IO Library is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// FAT File IO Library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with FAT File IO Library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
#include <stdio.h>
#include <string.h>
#include "fat_cache.h"

// Per file cluster chain caching used to improve performance.
// This does not have to be enabled for architectures with low
// memory space.

#ifdef  FAT_BROWSE_CLUSTER_CACHE_ENTRIES
static	unsigned long	browse_cluster_cache_idx[FAT_BROWSE_CLUSTER_CACHE_ENTRIES];
static	unsigned long	browse_cluster_cache_data[FAT_BROWSE_CLUSTER_CACHE_ENTRIES];
#endif

//-----------------------------------------------------------------------------
// fatfs_cache_init:
//-----------------------------------------------------------------------------
int	fatfs_cache_init(struct fatfs *fs, FL_FILE *file)
{
#ifdef FAT_CLUSTER_CACHE_ENTRIES
	int i;

	for (i=0;i<FAT_CLUSTER_CACHE_ENTRIES;i++)
	{
		file->cluster_cache_idx[i] = 0xFFFFFFFF; // Not used
		file->cluster_cache_data[i] = 0;
	}
#endif

	return 1;
}
//-----------------------------------------------------------------------------
// fatfs_cache_get_next_cluster:
//-----------------------------------------------------------------------------
int	fatfs_cache_get_next_cluster(struct fatfs *fs, FL_FILE *file, UINT32 clusterIdx, UINT32 *pNextCluster)
{
#ifdef FAT_CLUSTER_CACHE_ENTRIES
	UINT32 slot = clusterIdx % FAT_CLUSTER_CACHE_ENTRIES;

	if (file->cluster_cache_idx[slot] == clusterIdx)
	{
		*pNextCluster = file->cluster_cache_data[slot];
		return 1;
	}
#endif

	return 0;
}
//-----------------------------------------------------------------------------
// fatfs_cache_set_next_cluster:
//-----------------------------------------------------------------------------
int	fatfs_cache_set_next_cluster(struct fatfs *fs, FL_FILE *file, UINT32 clusterIdx, UINT32 nextCluster)
{
#ifdef FAT_CLUSTER_CACHE_ENTRIES
	UINT32 slot = clusterIdx % FAT_CLUSTER_CACHE_ENTRIES;

	if (file->cluster_cache_idx[slot] == clusterIdx)
		file->cluster_cache_data[slot] = nextCluster;
	else
	{
		file->cluster_cache_idx[slot] = clusterIdx;
		file->cluster_cache_data[slot] = nextCluster;
	}
#endif

	return 1;
}

//////////////////////////////////////////////////////////////


//-----------------------------------------------------------------------------
// fatfs_cache_init:
//-----------------------------------------------------------------------------
int	fatfs_browse_cache_init(struct fatfs *fs)
{
#ifdef FAT_BROWSE_CLUSTER_CACHE_ENTRIES
	int i;

	for (i=0;i<FAT_BROWSE_CLUSTER_CACHE_ENTRIES;i++)
	{
		browse_cluster_cache_idx[i] = 0xFFFFFFFF; // Not used
		browse_cluster_cache_data[i] = 0;
	}
#endif

	return 1;
}
//-----------------------------------------------------------------------------
// fatfs_cache_get_next_cluster:
//-----------------------------------------------------------------------------
int	fatfs_browse_cache_get_next_cluster(struct fatfs *fs, UINT32 clusterIdx, UINT32 *pNextCluster)
{
#ifdef FAT_BROWSE_CLUSTER_CACHE_ENTRIES
	UINT32 slot = clusterIdx % FAT_BROWSE_CLUSTER_CACHE_ENTRIES;

	if (browse_cluster_cache_idx[slot] == clusterIdx)
	{
		*pNextCluster = browse_cluster_cache_data[slot];
		return 1;
	}
#endif

	return 0;
}
//-----------------------------------------------------------------------------
// fatfs_cache_set_next_cluster:
//-----------------------------------------------------------------------------
int	fatfs_browse_cache_set_next_cluster(struct fatfs *fs, UINT32 clusterIdx, UINT32 nextCluster)
{
#ifdef FAT_BROWSE_CLUSTER_CACHE_ENTRIES
	UINT32 slot = clusterIdx % FAT_BROWSE_CLUSTER_CACHE_ENTRIES;

	if (browse_cluster_cache_idx[slot] == clusterIdx)
		browse_cluster_cache_data[slot] = nextCluster;
	else
	{
		browse_cluster_cache_idx[slot] = clusterIdx;
		browse_cluster_cache_data[slot] = nextCluster;
	}
#endif

	return 1;
}
