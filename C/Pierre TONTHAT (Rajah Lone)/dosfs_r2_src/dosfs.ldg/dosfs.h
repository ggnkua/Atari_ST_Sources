/*
	DOSFS Embedded FAT-Compatible Filesystem
	(C) 2005 Lewin A.R.W. Edwards (sysadm@zws.com)
*/

#ifndef _DOSFS_H
#define _DOSFS_H

#include <stdint.h>

//===================================================================
// User-supplied functions
uint32_t DFS_ReadSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count);
uint32_t DFS_WriteSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count);


//===================================================================
// Configurable items
#define MAX_PATH	260			// Maximum path length (increasing this will
								          // GREATLY increase stack requirements!)
#define DIR_SEPARATOR	'\\' // character separating directory components

// End of configurable items
//===================================================================

//===================================================================
// 32-bit error codes
#define DFS_OK			0			// no error
#define DFS_EOF			1			// end of file (not an error)
#define DFS_WRITEPROT	2			// volume is write protected
#define DFS_NOTFOUND	3			// path or file not found
#define DFS_PATHLEN		4			// path too long
#define DFS_ALLOCNEW	5			// must allocate new directory cluster
#define DFS_ISDIRECTORY 6			// (ggn) requested to open a directory
#define DFS_ERRMISC			0xffffffff	// generic error
#define DFS_HOSTMISSING	0xfffffffe	// (raj) host was not attached

//===================================================================
// File access modes
#define DFS_READ		1			// read-only
#define DFS_WRITE		2			// write-only
#define DFS_FOLDER	4			// (ggn) create folder
#define DFS_DELETEOPEN	8	// (ggn) when opening file for write, delete it if it exists

//===================================================================
// Miscellaneous constants
#define SECTOR_SIZE		512		// sector size in bytes

//===================================================================
// Internal subformat identifiers
#define FAT12			0
#define FAT16			1
#define FAT32			2

//===================================================================
// DOS attribute bits
#define ATTR_READ_ONLY	0x01
#define ATTR_HIDDEN		0x02
#define ATTR_SYSTEM		0x04
#define ATTR_VOLUME_ID	0x08
#define ATTR_DIRECTORY	0x10
#define ATTR_ARCHIVE	0x20
#define ATTR_LONG_NAME	(ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID)


// Code from: Jacknife wcx Total Commander module / author: ggn
// (raj) removed structures and functions to handle hard disk images.

/*
	Logical Boot Record structure (volume boot sector)
	ATARI define from: Jacknife wcx Total Commander module / author: ggn
	(raj) forced to merge into big LBR structure instead of external Atari ST BPB structure (1 byte shift problem under m68k-cross-mint-gcc)
*/
typedef struct _tagLBR {
	uint16_t bra;				// This WORD contains a 680x0 BRA.S instruction to the boot code in this sector if the disk is executable, otherwise it is unused.
	uint8_t oem[6];				// These six bytes are reserved for use as any necessary filler information. The disk-based TOS loader program places the string 'Loader' here.
	uint8_t serial[3];			// The low 24-bits of this LONG represent a unique disk serial number.
	uint8_t bytepersec_l;		// 0x000B - This is an Intel format WORD (low byte first) which indicates the number of bytes per sector on the disk.
	uint8_t bytepersec_h;
	uint8_t secperclus;		// 0x000D - This is a BYTE which indicates the number of sectors per cluster on the disk.
	uint8_t reserved_l;
	uint8_t reserved_h;		// 0x000E - This is an Intel format WORD which indicates the number of reserved sectors at the beginning of the media (usually one for floppies).
	uint8_t numfats;
	uint8_t rootentries_l;	// 0x0011 - This is an Intel format WORD indicating the number of ROOT directory entries.
	uint8_t rootentries_h;
	uint8_t sectors_s_l;	// 0x0013 - This is an Intel format WORD indicating the number of sectors on the disk (including those reserved).
	uint8_t sectors_s_h;
	uint8_t mediatype;		// 0x0015 - This BYTE is a media descriptor. Hard disks set this value to 0xF8, otherwise it is unused.
	uint8_t secperfat_l;		// 0x0016 - This is an Intel format WORD indicating the number of sectors per FAT.
	uint8_t secperfat_h;
	uint8_t secpertrk_l;		// 0x0018 - This is an Intel format WORD indicating the number of sectors per track.
	uint8_t secpertrk_h;
	uint8_t heads_l;	// 0x001A - This is an Intel format WORD indicating the number of sides on the disk.
	uint8_t heads_h;
	uint8_t hidden_l;		// 0x001C - This is an Intel format WORD indicating the number of hidden sectors on a disk (currently ignored).
	uint8_t hidden_h;
	uint8_t code[480];			// This area is used by any executable boot code. The code must be completely relocatable as its loaded position in memory is not guaranteed.
	uint8_t checksum[2];		// The entire boot sector WORD summed with this Motorola format WORD will equal 0x1234 if the boot sector is executable or some other value if not.
} LBR, *PLBR;

/*
	Volume information structure (Internal to DOSFS)
*/
typedef struct _tagVOLINFO {
	uint8_t unit;				// unit on which this volume resides
	uint8_t filesystem;			// formatted filesystem

// These two fields aren't very useful, so support for them has been commented out to
// save memory. (Note that the "system" tag is not actually used by DOS to determine
// filesystem type - that decision is made entirely on the basis of how many clusters
// the drive contains. DOSFS works the same way).
// See tag: OEMID in dosfs.c
//	uint8_t oemid[9];			// OEM ID ASCIIZ
//	uint8_t system[9];			// system ID ASCIIZ
	uint8_t label[12];			// volume label ASCIIZ
	uint32_t startsector;		// starting sector of filesystem
	uint8_t secperclus;			// sectors per cluster
	uint16_t reservedsecs;		// reserved sectors
	uint32_t numsecs;			// number of sectors in volume
	uint32_t secperfat;			// sectors per FAT
	uint16_t rootentries;		// number of root dir entries

	uint32_t numclusters;		// number of clusters on drive

	// The fields below are PHYSICAL SECTOR NUMBERS.
	uint32_t fat1;				// starting sector# of FAT copy 1
	uint32_t rootdir;			// starting sector# of root directory (FAT12/FAT16) or cluster (FAT32)
	uint32_t dataarea;			// starting sector# of data area (cluster #2)
} VOLINFO, *PVOLINFO;

/*
	Flags in DIRINFO.flags
*/
#define DFS_DI_BLANKENT		0x01	// Searching for blank entry

/*
	Directory search structure (Internal to DOSFS)
*/
typedef struct _tagDIRINFO {
	uint32_t currentcluster;	// current cluster in dir
	uint8_t currentsector;		// current sector in cluster
	uint8_t currententry;		// current dir entry in sector
	uint8_t *scratch;			// ptr to user-supplied scratch buffer (one sector)
	uint8_t flags;				// internal DOSFS flags
} DIRINFO, *PDIRINFO;

/*
	Directory entry structure
	note: if name[0] == 0xe5, this is a free dir entry
	      if name[0] == 0x00, this is a free entry and all subsequent entries are free
		  if name[0] == 0x05, the first character of the name is 0xe5 [a kanji nicety]

	Date format: bit 0-4  = day of month (1-31)
	             bit 5-8  = month, 1=Jan..12=Dec
				 bit 9-15 =	count of years since 1980 (0-127)
	Time format: bit 0-4  = 2-second count, (0-29)
	             bit 5-10 = minutes (0-59)
				 bit 11-15= hours (0-23)
*/
typedef struct _tagDIRENT {
	uint8_t name[11];			// filename
	uint8_t attr;				// attributes (see ATTR_* constant definitions)
	uint8_t reserved;			// reserved, must be 0
	uint8_t crttimetenth;		// create time, 10ths of a second (0-199 are valid)
	uint8_t crttime_l;			// creation time low byte
	uint8_t crttime_h;			// creation time high byte
	uint8_t crtdate_l;			// creation date low byte
	uint8_t crtdate_h;			// creation date high byte
	uint8_t lstaccdate_l;		// last access date low byte
	uint8_t lstaccdate_h;		// last access date high byte
	uint8_t startclus_h_l;		// high word of first cluster, low byte (FAT32)
	uint8_t startclus_h_h;		// high word of first cluster, high byte (FAT32)
	uint8_t wrttime_l;			// last write time low byte
	uint8_t wrttime_h;			// last write time high byte
	uint8_t wrtdate_l;			// last write date low byte
	uint8_t wrtdate_h;			// last write date high byte
	uint8_t startclus_l_l;		// low word of first cluster, low byte
	uint8_t startclus_l_h;		// low word of first cluster, high byte
	uint8_t filesize_0;			// file size, low byte
	uint8_t filesize_1;			//
	uint8_t filesize_2;			//
	uint8_t filesize_3;			// file size, high byte
} DIRENT, *PDIRENT;

/*
	File handle structure (Internal to DOSFS)
*/
typedef struct _tagFILEINFO {
	PVOLINFO volinfo;			// VOLINFO used to open this file
	uint32_t dirsector;			// physical sector containing dir entry of this file
	uint8_t diroffset;			// # of this entry within the dir sector
	uint8_t mode;				// mode in which this file was opened
	uint32_t firstcluster;		// first cluster of file
	uint32_t filelen;			// byte length of file

	uint32_t cluster;			// current cluster
	uint32_t pointer;			// current (BYTE) pointer
} FILEINFO, *PFILEINFO;

/*
	Get starting sector# of specified partition on drive #unit
	NOTE: This code ASSUMES an MBR on the disk.
	scratchsector should point to a SECTOR_SIZE scratch area
	Returns 0xffffffff for any error.
	If pactive is non-NULL, this function also returns the partition active flag.
	If pptype is non-NULL, this function also returns the partition type.
	If psize is non-NULL, this function also returns the partition size.
*/
uint32_t DFS_GetPtnStart(uint8_t unit, uint8_t *scratchsector, uint8_t pnum, uint8_t *pactive, uint8_t *pptype, uint32_t *psize);

/*
	Retrieve volume info from BPB and store it in a VOLINFO structure
	You must provide the unit and starting sector of the filesystem, and
	a pointer to a sector buffer for scratch
	Attempts to read BPB and glean information about the FS from that.
	Returns 0 OK, nonzero for any error.
*/
uint32_t DFS_GetVolInfo(uint8_t unit, uint8_t *scratchsector, uint32_t startsector, PVOLINFO volinfo);

/*
	Open a directory for enumeration by DFS_GetNextDirEnt
	You must supply a populated VOLINFO (see DFS_GetVolInfo)
	The empty string or a string containing only the directory separator are
	considered to be the root directory.
	Returns 0 OK, nonzero for any error.
*/
uint32_t DFS_OpenDir(PVOLINFO volinfo, uint8_t *dirname, PDIRINFO dirinfo, uint8_t volflag);

/*
	Get next entry in opened directory structure. Copies fields into the dirent
	structure, updates dirinfo. Note that it is the _caller's_ responsibility to
	handle the '.' and '..' entries.
	A deleted file will be returned as a NULL entry (first char of filename=0)
	by this code. Filenames beginning with 0x05 will be translated to 0xE5
	automatically. Long file name entries will be returned as NULL.
	returns DFS_EOF if there are no more entries, DFS_OK if this entry is valid,
	or DFS_ERRMISC for a media error
*/
uint32_t DFS_GetNext(PVOLINFO volinfo, PDIRINFO dirinfo, PDIRENT dirent);

/*
	Open a file for reading or writing. You supply populated VOLINFO, a path to the file,
	mode (DFS_READ or DFS_WRITE) and an empty fileinfo structure. You also need to
	provide a pointer to a sector-sized scratch buffer.
	Returns various DFS_* error states. If the result is DFS_OK, fileinfo can be used
	to access the file from this point on.
*/
uint32_t DFS_OpenFile(PVOLINFO volinfo, uint8_t *path, uint8_t mode, uint8_t *scratch, PFILEINFO fileinfo, uint32_t filedatetime);

/*
	Read an open file
	You must supply a prepopulated FILEINFO as provided by DFS_OpenFile, and a
	pointer to a SECTOR_SIZE scratch buffer.
	Note that returning DFS_EOF is not an error condition. This function updates the
	successcount field with the number of bytes actually read.
*/
uint32_t DFS_ReadFile(PFILEINFO fileinfo, uint8_t *scratch, uint8_t *buffer, uint32_t *successcount, uint32_t len);

/*
	Write an open file
	You must supply a prepopulated FILEINFO as provided by DFS_OpenFile, and a
	pointer to a SECTOR_SIZE scratch buffer.
	This function updates the successcount field with the number of bytes actually written.
*/
uint32_t DFS_WriteFile(PFILEINFO fileinfo, uint8_t *scratch, uint8_t *buffer, uint32_t *successcount, uint32_t len);

/*
	Seek file pointer to a given position
	This function does not return status - refer to the fileinfo->pointer value
	to see where the pointer wound up.
	Requires a SECTOR_SIZE scratch buffer
*/
void DFS_Seek(PFILEINFO fileinfo, uint32_t offset, uint8_t *scratch);

/*
	Delete a file
	scratch must point to a sector-sized buffer
*/
uint32_t DFS_UnlinkFile(PVOLINFO volinfo, uint8_t *path, uint8_t *scratch);

/*
	(raj) Rename a file, newname is the new file name (without path)
	scratch must point to a sector-sized buffer
*/
uint32_t DFS_RenameFile(PVOLINFO volinfo, uint8_t *path, uint8_t *newname, uint8_t *scratch);

/*
	(raj) get volume name and set it if newname has length. You supply populated VOLINFO,
	a pointer to buffer that will contain the name in return (mode = DFS_READ) or the name
	that must be changed (mode = DFS_WRITE) if the entry exists (attribute ATTR_VOLUME_ID).
	You also need to provide a pointer to a sector-sized scratch buffer.
	Returns various DFS_* error states. If the result is DFS_OK.
*/
uint32_t DFS_volumeName(PVOLINFO volinfo, uint8_t *name, uint8_t mode, uint8_t *scratch);

// If we are building a host-emulation version, include host support
#ifdef HOSTVER
#include "hostemu.h"
#endif

#endif // _DOSFS_H
