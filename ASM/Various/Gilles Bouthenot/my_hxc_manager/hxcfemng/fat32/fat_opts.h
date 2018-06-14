#ifndef __FAT_OPTS_H__
#define __FAT_OPTS_H__

//-------------------------------------------------------------
// Configuration
//-------------------------------------------------------------

// Is the system little endian (1) or big endian (0)
#define FATFS_IS_LITTLE_ENDIAN				0

// Max filename Length
#define FATFS_MAX_LONG_FILENAME				260

// Max open files (reduce to lower memory requirements)
#define FATFS_MAX_OPEN_FILES				1

// Max FAT sectors to buffer (min 1)
// (mem used is FAT_BUFFERED_SECTORS * FAT_SECTOR_SIZE)
#define FAT_BUFFERED_SECTORS				16

// Size of cluster chain cache (can be undefined)
// Mem used = FAT_CLUSTER_CACHE_ENTRIES * 4 * 2
// Improves access speed considerably
#define FAT_CLUSTER_CACHE_ENTRIES	     64
#define FAT_BROWSE_CLUSTER_CACHE_ENTRIES    128

// Include support for writing files
//#define FATFS_INC_WRITE_SUPPORT				1

// Support long filenames (1 / 0)?
// (if not (0) only 8.3 format is supported)
#define FATFS_INC_LFN_SUPPORT				1

// Support directory listing (1 / 0)?
#define FATFS_DIR_LIST_SUPPORT				1

// Include support for formatting disks (can be undefined)
//#define FATFS_INC_FORMAT_SUPPORT			1

// Sector size used
#define FAT_SECTOR_SIZE						512

#define FAT_PRINTF(a)
//printf a


#endif
