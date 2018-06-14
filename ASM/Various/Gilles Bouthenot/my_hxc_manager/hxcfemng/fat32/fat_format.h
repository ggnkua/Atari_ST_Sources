#ifndef __FAT_FORMAT_H__
#define __FAT_FORMAT_H__

#include "fat_defs.h"
#include "fat_opts.h"
#include "fat_access.h"

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------
int fatfs_format_fat16(struct fatfs *fs, UINT32 volume_sectors, const char *name);

#endif
