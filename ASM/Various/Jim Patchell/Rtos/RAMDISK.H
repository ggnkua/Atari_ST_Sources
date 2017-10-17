/*************************************************************************
**
** Device Driver for Ramdisk
**
**
*************************************************************************/

#ifndef RAMDISK__H
#define RAMDISK__H

#include "erorcode.h"

#define RAMDISK_MAXSECTORS	254

struct RamDisk {
	unsigned long magic;		//magic number to indicate formated ramdisk
	unsigned FatChecksum;		//checksum of fat table
	int Directory;				//Start Sector for Directory
	int DirSize;				//Size of Directory
};

struct DirEntry {
	char name[8];				//8 bytes for name
	long size;					//4 bytes for size
	int start;					//2 bytes for start sector
	unsigned attrib;			//2 bytes for attributes
};

//-----------------------------------------------------------------------
// DirEntry->attrib bits
//-----------------------------------------------------------------------

#define RAMDISK_READONLY	0x01	//locks file
#define RAMDISK_OPEN		0x02	//indicates file is in use

struct FCB {
	int StartSector;			//first data sector for file
	int CurrentSector;			//current active sector
	int SectorIndex;			//index in current sector where data points
	long FilePointer;			//index in file where data points
	long FileSize;				//total size of file
	unsigned char *buffer;		//pointer to file buffer if needed
	int bufferindex;			//index in file buffer
	DirEntry *Dir;				//pointer to directory entry
	int DirSector;				//sector directory entry is in
};

struct Ffblk {
	char name[10];				//name of file
	long size;					//size of file
	unsigned attrib;			//file attributes
	char spec[8];				//user is not supposed to know about this
	int sector;					//current sector
	int index;					//index in sector
};

#define RAMDISK_DESCRIPTOR	0		//offset for ramdisk descriptor
#define RAMDISK_FAT			256		//offset for ramdisk FAT
#define RAMDISK_CHECKSUMS	512		//offset for ramdisk checksums
#define RAMDISK_DATA		1024	//offset for ramdisk data

/*	XIO function calls		*/

#define RAMDISK_FLUSH		0x20	//flush buffers
#define RAMDISK_FINDFIRST	0x21	//find first entry in directory
#define RAMDISK_FINDNEXT	0x22	//find next entry in directory
#define RAMDISK_SEEK		0x23	//seek position in file
#define RAMDISK_TELL		0x24	//get position in file
#define RAMDISK_FREE		0x25	//free space in ramdisk
#define RAMDISK_DELETE		0x26	//delete file in ramdisk
#define RAMDISK_FORMAT		0x27	//format (initialize) ramdisk
#define RAMDISK_FILESIZE	0x28	//get size of file


//------------------------------------------------
// various macros
//------------------------------------------------

//	FindFirst(char *filespec,int attributes,Ffblk *ff);
#define FindFirst(n,a,f)	(int)Xio((RAMDISK_FINDFIRST),(-1),("D:"),((char *)(n)),(0l),(a),(f))
#define FindNext(f)			(int)Xio((RAMDISK_FINDNEXT),(-1),("D:"),((char *)0),(0l),(0),(f))
#define FormatRamdisk()		(int)Xio((RAMDISK_FORMAT),(-1),("D:"),((char *)0l),(0l),(0))
#define FileSize(h)			(int)Xio((RAMDISK_FILESIZE),(h),(char *)0,(char *)0,0l,0);

#ifdef __cplusplus
extern "C" {
#endif

#pragma function( calling)

extern long D_init(void);

#pragma function()

#ifdef __cplusplus
}
#endif

#endif	/* RAMDISK__H	*/
