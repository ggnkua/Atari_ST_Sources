/***********************************************************************
**
** RAMDISK.CPP
**
**	This is a device driver for a RAM disk.  It uses RAM to make a
** virtual disk drive that has sectors and everything.
**
** The data for this thing must live in non-volatile memory.  Due to
** the nature of the beast, memory must be allocated before hand.  It
** cannot be dynamically allocated because of the way startup code works
**
** I admit it, some of this code is REALLY UGLY!!!
**
************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include "cio.h"
#include "ramdisk.h"
#include "stack.h"

#pragma function(calling)

static long D_open(IOCB *iocb,va_list argp);
static long D_close(IOCB *iocb,va_list argp);
static long D_get(IOCB *iocb,va_list argp);
static long D_read(IOCB *iocb,va_list argp);
static long D_put(IOCB *iocb,int a,va_list argp);
static long D_write(IOCB *iocb,va_list argp);
static long D_status(IOCB *iocb,va_list argp);
static long D_xio(int cmd,IOCB *iocb,va_list argp);

#pragma function()

static const H_JVEC d_vec = {
	D_open,
	D_close,
	D_get,
	D_read,
	D_put,
	D_write,
	D_status,
	D_xio,
	D_init
};

static RamDisk *RamDiskDescp;		//ram disk descriptor table
static unsigned char *RamFat;                //start of FAT, gets initialized at power up
static unsigned char *RamData;               //start of data, gets initialized at power up
static unsigned *Checksums;			//checksums for Sectors

#pragma region("ram = nonvol")

//all data declared here will be in non-volatile memory

static unsigned char RamDiskData[(RAMDISK_MAXSECTORS+2) * 512l];	//ram disk data

//-----------------------------------------------------------------------
// The first 256 bytes of RamDiskData is for the Ram Disk Descriptor Table
// The second 256 bytes of RamDiskData is for the FAT.
// The third 512 bytes of RamDiskData is for sector checksums.
// This will use up the first two "clusters" of data.
// The fat is basically a table that points to the NEXT sector for a file
// Sectors have values from 0->0xfd.  0xfe indicates end of file.
// 0xff indicates free sector.
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
//
// Misc routines for controlling ram disk
//
//-----------------------------------------------------------------------

static unsigned int CalculateFatChecksum(void)
{
	int i;
	unsigned cs=0;

	for(i=0;i<256;++i)
		cs += (unsigned)RamFat[i];
	return cs;
}

static unsigned int CalculateDataChecksum(int sector)
{
	int i;
	unsigned cs=0;
	unsigned char *p = RamData + ((long)sector << 9);

	for(i=0;i<512;++i)
		cs += (unsigned)*p++;
	return cs;
}

static void Format(void)	//initialize ram disk
{
	int i;
	long *p;
	unsigned char *f;
	unsigned char fatinit = 0xff;

	for(p=(long *)RamData,i=0;i< ((RAMDISK_MAXSECTORS) * 128);++i)
		*p++ = 0;
	for(f=RamFat,i=0;i<256;++i)
	{
		if(i == RAMDISK_MAXSECTORS) fatinit = 0xfe;
		*f++ = fatinit;		/*	initaialize Fat table to all availiable	*/
	}
	//
	// Directory is always the first file on the "DRIVE"
	//
	RamFat[0] = 1;
	RamFat[1] = 2;
	RamFat[2] = 3;
	RamFat[3] = 0xfe;	//four sectors for directory 128 files

	f = RamData;
	for(i=0;i<2048;i+=16)
		f[i] = '?';		//indicates spot is open for file
	//
	//initialize Ram Disk Descriptor
    //
	RamDiskDescp->magic = 0x12345678;
	RamDiskDescp->FatChecksum = CalculateFatChecksum();
	RamDiskDescp->Directory = 0;
	RamDiskDescp->DirSize = 4;
	for(i=0;i<RAMDISK_MAXSECTORS;++i)
		Checksums[i] = CalculateDataChecksum(i);
}

static DirEntry *DirSearch(char *name,int *sect)
{
	int i;
	DirEntry *d=NULL;
	int sector = RamDiskDescp->Directory;	//get first sector of directory
	while(sector != 0xfe)	//process all direcotry sectors
	{
		d = (DirEntry *)RamData + ((long)sector << 9);
		for(i=0;i<32;++i)
		{
			if(strncmp(d->name,name,8) == 0)
			{
				*sect = sector;
				return d;	//return start sector
			}
			d++;
		}
		sector = RamFat[sector];	//next sector please
	}
	return NULL;
}

static void DeallocateSectors(int sector)
{
	//------------------------------------------------------
	//this function dealocates a string of allocated sectors
	//------------------------------------------------------
	Stack *s = new Stack(RAMDISK_MAXSECTORS);

	do
	{
		s->Push(sector);
		sector = RamFat[sector];	/*	next sector	*/
	}while(sector != 0xfe);
	while((sector = s->Pop()) != -1)
		RamFat[sector] = 0xff;		//mark availiable
	RamDiskDescp->FatChecksum = CalculateFatChecksum();
	delete s;
}

static int GetSector(void)
{
	int i,loop,retval=-1;

	for(i=0,loop=1;i < (RAMDISK_MAXSECTORS) && loop;++i)	//search for a free sector
	{
		if(RamFat[i] == 0xff)	//free sector
		{
			loop = 0;
			retval = i;
		}
	}
	return retval;
}

static DirEntry *GetDirectoryEntry(int *sect)
{
	int i;
	DirEntry *d=NULL;
	int sector = RamDiskDescp->Directory;	//get first sector of directory

	while(sector != 0xfe)	//process all direcotry sectors
	{
		d = (DirEntry *)RamData + ((long)sector << 9);
		for(i=0;i<32;++i)
		{
			if(d->name[0] == '?')	//is this sector availiable?
			{
				*sect = sector;
				return d;	//return start sector
			}
			d++;
		}
		sector = RamFat[sector];	//next sector please
	}
	return d;
}

static int Flush(FCB *fcb)
{
	//flush any buffers to ram disk
	int retval=0;
	int i,j;
	unsigned char *d;
	int r;
	int sector;
	int s;

	if(fcb->buffer && (fcb->FileSize > fcb->Dir->size))	//is there a buffer to flush?
	{
		if((r = fcb->SectorIndex) == 0)	/*	even block size	*/
		{
			d = RamData + fcb->CurrentSector * 512;
			memcpy(d,fcb->buffer,fcb->bufferindex);	//copy data
			Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
			fcb->Dir->size += fcb->bufferindex;
			fcb->SectorIndex = fcb->bufferindex;
			fcb->bufferindex = 0;
		}
		else
		{
			d = RamData + ((long)fcb->CurrentSector << 9) + r;	//point to end of data
			if(fcb->bufferindex < 512-r)
			{
				memcpy(d,fcb->buffer,fcb->bufferindex);
				fcb->SectorIndex = fcb->bufferindex + r;
				fcb->Dir->size +=fcb->bufferindex;
				fcb->bufferindex = 0;
			}
			else
			{
				memcpy(d,fcb->buffer,512-r);
				Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
				sector = GetSector();	//get a new sector
				RamFat[fcb->CurrentSector] = sector;	//link new sector
				fcb->CurrentSector = sector;
				RamFat[fcb->CurrentSector] = 0xfe;	//mark end of file
				d = RamData + ((long)fcb->CurrentSector << 9);
				memcpy(d,fcb->buffer + (512 - r),fcb->bufferindex - (512 - r));
				fcb->Dir->size +=fcb->bufferindex;
				fcb->SectorIndex = fcb->bufferindex - (512 - r);
				fcb->bufferindex = 0;
			}
		}
		RamDiskDescp->FatChecksum = CalculateFatChecksum();
		Checksums[fcb->DirSector] = CalculateDataChecksum(fcb->DirSector);
	}
	return retval;
}

static void FixSpec(char *s)
{
	int i;
	int flag;

	for(i=0,flag=0;i<8;++i)
	{
		if(s[i] == '*')
			flag = 1;
		if(flag)
			s[i] = '?';
	}
}

static int MatchSpec(char *s,char *n)
{
	//does a string compare, returns 1 if match, 0 if no match
	int retval = 1; //assume it has matched already
	int i;

	if(n[0] == '?')		//deleted file?
		retval = 0;
	else
	{
		for(i=0;(i<8) && retval;++i)	//check while still matched
		{
			if(s[i] != '?')	//this is an automatic match
				{
				if(s[i] != n[i])
					retval = 0;	//did not match
			}
		}
	}
	return retval;
}

//-----------------------------------------------------------------------
//
// These routines are the CIO entry points
//
//-----------------------------------------------------------------------
//
long D_init()
{
	RamData = &RamDiskData[RAMDISK_DATA];
	RamFat = &RamDiskData[RAMDISK_FAT];
	Checksums = (unsigned *)&RamDiskData[RAMDISK_CHECKSUMS];
	RamDiskDescp = (RamDisk *)&RamDiskData[RAMDISK_DESCRIPTOR];
	if(RamDiskDescp->magic != 0x12345678)
		Format();
	return AddHandler("D",&d_vec);
}

static long D_open(IOCB *iocb,va_list argp)
{
	//file name is pointed to by iocb->dev_name
	FCB *fcb = new FCB;
	DirEntry *d;
	long retval = 0;
	int sector;
	iocb->p = (void *)fcb;
	char *n = strchr(iocb->dev_name,':');	//find start of file name
	if(n)
	{
		++n;
		if((d = DirSearch(n,&sector)) != NULL)	//search for file name
		{	//file was found, check to see what mode we are in
			fcb->DirSector = sector;
			fcb->StartSector = d->start;	//get start sector
			fcb->CurrentSector = d->start;	//current sector
			fcb->FilePointer = 0;			//always start at begin of file
			fcb->Dir = d;					//remember directory entry
			fcb->SectorIndex = 0;
			fcb->bufferindex = 0;
			if(iocb->mode & WRITE_ONLY)	//we are going to be writing, use buffer
			{
				fcb->buffer = new unsigned char[512];	//allocate buffer
				if(iocb->mode & READ_ONLY)	//opened for update?
				{
					fcb->FileSize = d->size;	//get file size
				}
				else
				{
					//purely write only, erase file, esentially
					fcb->FileSize = 0;
					DeallocateSectors(fcb->StartSector);
					RamFat[fcb->StartSector] = 0xfe;	//now the last sector
				}
			}
			else
			{
				fcb->buffer = 0;
				fcb->FileSize = d->size;
			}
		}
		else	//could not file the desired file name
		{
			if(iocb->mode & WRITE_ONLY)	//create file if write
			{
				if((d = GetDirectoryEntry(&sector)) != NULL)
				{
					if( (d->start = GetSector()) >= 0)
					{
						fcb->DirSector = sector;
						strncpy(d->name,n,8);
						fcb->StartSector = d->start;
						d->size = 0;
						fcb->CurrentSector = d->start;
						fcb->FileSize = 0;
						fcb->FilePointer = 0;
						fcb->Dir = d;
						fcb->SectorIndex = 0;
						fcb->buffer = new unsigned char[512];
						fcb->bufferindex=0;
                        RamFat[fcb->StartSector] = 0xfe;
					}
					else
					{
						retval = RAMDISK_NOSECTORS;
					}
				}

				else
				{
					retval = RAMDISK_FILENOTFOUND;	//could not open file
				}
			}
			else
			{
				retval = RAMDISK_NODIRECTORIES;
			}
		}
	}
	else
	{
		retval = RAMDISK_BADNAME;	//something wrong with file name
	}
	if(retval)
	{
		delete fcb;	//open failed, delete file control block
		iocb->p = (void *)0;
	}
	else
		RamDiskDescp->FatChecksum = CalculateFatChecksum();
	return retval;
}

static long D_close(IOCB *iocb,va_list argp)
{
	long retval=0;

	FCB *fcb = (FCB *)iocb->p;
	if(iocb->mode & WRITE_ONLY)
		retval = Flush(fcb);		//flush data;
	iocb->p = 0;				//get rid of fcb
	if(fcb->buffer)
		delete[] fcb->buffer;		//free buffer ram if any
	delete fcb;
	return retval;					//free up ram
}

static long D_get(IOCB *iocb,va_list argp)
{
	long retval;
	unsigned char *p;

	FCB *fcb = (FCB *)iocb->p;
	p = RamData + ((long)fcb->CurrentSector << 9) + fcb->SectorIndex++;
	if(fcb->FilePointer >= fcb->Dir->size)
		retval = RAMDISK_EOF;
	else
	{
		fcb->FilePointer++;
		if(fcb->SectorIndex == 512)
		{
			fcb->CurrentSector = RamFat[fcb->CurrentSector];
			fcb->SectorIndex = 0;
		}
		retval = (long)*p;
	}
	return retval;
}

static long D_read(IOCB *iocb,va_list argp)
{
	FCB *fcb = (FCB *)iocb->p;
	long bytesread=0;
	int r;
	unsigned char *s = RamData + ((long)fcb->CurrentSector << 9) + fcb->SectorIndex;
	int len,l,loop;
	char *buff = va_arg(argp,char *);
	long count = va_arg(argp,long);
	long c = count;
	char *p = buff;

	//---------------------------------------------------------------
	//read chucks of 512 into buff as long as count is greater than 0
	//if the first sector is not a complete 512 bytes, then bring it
	//up to snuff
	//return actual number of bytes read
	//----------------------------------------------------------------
	if((r = fcb->SectorIndex) != 0)	//less than 512 bytes in sector
	{
		if(c < (512-r)) len = c; else len = 512-r;
		if((l = fcb->FileSize - fcb->FilePointer) < len) len = l;
		memcpy(p,s,len);	//copy what is left in this sector
		c -= len;
		p += len;
		bytesread += len;
		fcb->FilePointer += len;
		if((fcb->SectorIndex += len) == 512)
		{
			fcb->SectorIndex = 0;
			fcb->CurrentSector = RamFat[fcb->CurrentSector];	//next sector
		}
	}
	loop = c;
	while(c > 0 && loop)
	{
		s = RamData + ((long)fcb->CurrentSector << 9);
		if((l = fcb->FileSize - fcb->FilePointer) < 512)
		{
			len = l;
			loop = 0;
		}
		else
			len = 512;
		if(c < len)
			len = c;
		if(len != 512) fcb->SectorIndex += len;
		memcpy(p,s,len);
		p+= len;
		c -= len;
		bytesread += len;
		fcb->FilePointer += len;
		if(len == 512)
			fcb->CurrentSector = RamFat[fcb->CurrentSector];	//next sector
	}
	return bytesread;
}

static long D_put(IOCB *iocb,int a,va_list argp)
{
	/*---------------------------------------------------------------------
	** Write to a sector
	**--------------------------------------------------------------------*/
	int r;
	unsigned char *d;
	int sector;
	long retval=0;

	FCB *fcb = (FCB *)iocb->p;	//get file control block
	fcb->buffer[fcb->bufferindex++] = (unsigned char)a;
	fcb->FilePointer++;
	fcb->FileSize++;
	if(fcb->bufferindex == 512)	//is it time to flush buffer
	{
		if((r = fcb->SectorIndex) == 0)	/*	even block size	*/
		{
			d = RamData + (fcb->CurrentSector << 9);
			memcpy(d,fcb->buffer,512);	//copy data
			Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
			sector = GetSector();
			RamFat[fcb->CurrentSector] = sector;
			fcb->CurrentSector = sector;
			RamFat[sector] = 0xfe;	//mark end of file;
		}
		else
		{
			d = RamData + ((long)fcb->CurrentSector << 9) + r;
			memcpy(d,fcb->buffer,512-r);
			Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
			sector = GetSector();
			RamFat[fcb->CurrentSector] = sector;
			fcb->CurrentSector = sector;
			RamFat[fcb->CurrentSector] = 0xfe;	//mark end of file
			d = RamData + fcb->CurrentSector * 512;
			memcpy(d,fcb->buffer + (512 -r),r);
			Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
		}
		fcb->bufferindex = 0;
		fcb->Dir->size += 512;	//update directory file size;
		RamDiskDescp->FatChecksum = CalculateFatChecksum();
		Checksums[fcb->DirSector] = CalculateDataChecksum(fcb->DirSector);

	}
	return retval;
}

static long D_write(IOCB *iocb,va_list argp)
{
	FCB *fcb = (FCB *)iocb->p;
	long byteswritten=0;
	int r;
	int len,l;
	int sector;
	char *buff = va_arg(argp,char *);
	long count = va_arg(argp,long);
	long c = count;
	char *p = buff;
	//---------------------------------------------------------------
	//read chucks of 512 into buff as long as count is greater than 0
	//if the first sector is not a complete 512 bytes, then bring it
	//up to snuff
	//return actual number of bytes read
	//----------------------------------------------------------------
	if(fcb->bufferindex)
    	Flush(fcb);
	unsigned char *s = RamData + ((long)fcb->CurrentSector << 9) + fcb->SectorIndex;
	if((r = fcb->SectorIndex) != 0)	//less than 512 bytes in sector
	{
		if(c < (512-r)) len = c; else len = 512-r;
		memcpy(s,p,len);	//copy what is left in this sector
		Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
		c -= len;
		p += len;
		byteswritten += len;
		fcb->FilePointer += len;
		fcb->FileSize += len;
		fcb->Dir->size = fcb->FileSize;
		if((fcb->SectorIndex += len) == 512)
		{
			sector = GetSector();
			RamFat[fcb->CurrentSector] = sector;
			RamFat[sector] = 0xfe;
			fcb->CurrentSector = sector;	//next sector
			fcb->SectorIndex=0;
		}
	}
	while(c > 0)
	{
		s = RamData + ((long)fcb->CurrentSector << 9);
		if(c > 512)
			len = 512;
		else
			len = c;
		fcb->SectorIndex += len;
		memcpy(s,p,len);
		Checksums[fcb->CurrentSector] = CalculateDataChecksum(fcb->CurrentSector);
		p+= len;
		c -= len;
		byteswritten += len;
		fcb->FilePointer += len;
		fcb->FileSize += len;
		fcb->Dir->size = fcb->FileSize;
		if(fcb->SectorIndex == 512)
		{
			sector = GetSector();
			RamFat[fcb->CurrentSector] = sector;
			RamFat[sector] = 0xfe;
			fcb->CurrentSector = sector;	//next sector
			fcb->SectorIndex = 0;
		}
	}
	RamDiskDescp->FatChecksum = CalculateFatChecksum();
	Checksums[fcb->DirSector] = CalculateDataChecksum(fcb->DirSector);
	return byteswritten;
}

static long D_status(IOCB *iocb,va_list argp)
{
	FCB *fcb = (FCB *)iocb->p;
	long retval=0;
	int i;

	if(fcb)
		retval = fcb->FileSize - fcb->FilePointer;
	else	//if there is no FCB, then return free bytes in drive
		for(i=0;i<RAMDISK_MAXSECTORS;++i)
			if(RamFat[i] == 0xff) retval += 512;

	return retval;	//return number of bytes left in file
}

static long D_xio(int cmd,IOCB *iocb,va_list argp)
{
	long retval = 0;
	FCB *fcb = (FCB *)iocb->p;
	Ffblk *ff;
	DirEntry *d;
	int loop;
	char *p;
	char *buffer = va_arg(argp,char *);
	long count = va_arg(argp,long);
	int aux = va_arg(argp,int);

	switch(cmd)
	{
		case RAMDISK_FLUSH:
			if(fcb)
				retval = (long)Flush(fcb);
			else
				retval = RAMDISK_EOF;
			break;
		case RAMDISK_FINDFIRST:
			//------------------------------------------------------
			// a pointer to a Ffblk is the first parameter of argp
			//------------------------------------------------------
			ff = va_arg(argp,Ffblk *);
			strncpy(ff->spec,buffer,8);
			ff->sector = RamDiskDescp->Directory;
			ff->index = 0;
			d = (DirEntry *)(RamData + ((long)ff->sector << 9));
			FixSpec(ff->spec);	//process wild cards
			loop=1;
			do
			{
				if(MatchSpec(ff->spec,d->name))
				{
					loop = 0;
					strncpy(ff->name,d->name,8);
					ff->name[8] = 0;
					ff->size = d->size;
					ff->attrib = d->attrib;
				}
				else
				{
					++d;
					ff->index++;
					if(ff->index == 32)	//run out of sector
					{
						if(RamFat[ff->sector] != 0xfe)	//end?
						{
							ff->sector = RamFat[ff->sector];
							d = (DirEntry *)(RamData + ((long)ff->sector << 9));
							ff->index = 0;
						}
						else
						{
							loop = 0;
							retval = RAMDISK_EOF;
						}
					}
				}
			}while(loop);	//search until first entry found
			break;
		case RAMDISK_FINDNEXT:
			//------------------------------------------------------
			// a pointer to a Ffblk is the first parameter of argp
			//------------------------------------------------------
			ff = va_arg(argp,Ffblk *);
			ff->index++;	//increment index
			if(ff->index == 32)	//run out of sector
			{
				if(RamFat[ff->sector] != 0xfe)	//end?
				{
					ff->sector = RamFat[ff->sector];
					ff->index = 0;
				}
				else
				{
					retval = RAMDISK_EOF;
				}
			}
			if(!retval)
			{
				loop = 1;
				d = (DirEntry *)(RamData + ((long)ff->sector << 9) + (ff->index << 4));
			}
			while(loop)
			{
				if(MatchSpec(ff->spec,d->name))
				{
					loop = 0;
					strncpy(ff->name,d->name,8);
					ff->name[8] = 0;
					ff->size = d->size;
					ff->attrib = d->attrib;
				}
				else
				{
					++d;
					ff->index++;
					if(ff->index == 32)	//run out of sector
					{
						if(RamFat[ff->sector] != 0xfe)	//end?
						{
							ff->sector = RamFat[ff->sector];
							d = (DirEntry *)(RamData + ((long)ff->sector << 9));
							ff->index = 0;
						}
						else
						{
							loop = 0;
							retval = RAMDISK_EOF;
						}
					}
				}
			}
			break;
		case RAMDISK_SEEK:
			//-------------------------------------------
			//new file pointer is passed in count
			//this is the only long availiable
			//-------------------------------------------
			if(fcb)
			{
				if(count > fcb->FileSize)
					retval = RAMDISK_EOF;
				else
				{
					long diff = count - fcb->FilePointer;
					if(diff < 0)
					{	//go backwards (hard)
						//to go backwards, start at beginning of file and word forwards
						fcb->CurrentSector = fcb->StartSector;
						diff = count;
						while(diff >= 512)
						{
							fcb->CurrentSector = RamFat[fcb->CurrentSector];
							diff -= 512;
							fcb->FilePointer += 512;
						}
						fcb->SectorIndex = diff;
					}
					else
					{	//go forward (easy)
						while(diff >= 512)
						{
							if(RamFat[fcb->CurrentSector] != 0xfe)
							{
								fcb->CurrentSector = RamFat[fcb->CurrentSector];
								fcb->FilePointer += 512;
								diff -= 512;
							}
							else
								return RAMDISK_EOF;
						}
						if((diff + fcb->SectorIndex) > 512)
						{
							diff -= 512 - fcb->SectorIndex;
							fcb->FilePointer += 512 - fcb->SectorIndex;
							if(RamFat[fcb->CurrentSector] != 0xfe)
							{
								fcb->CurrentSector = RamFat[fcb->CurrentSector];
								fcb->FilePointer += diff;
								fcb->SectorIndex = diff;
							}
							else
								return RAMDISK_EOF;
						}
						else
							fcb->SectorIndex += diff;
					}
				}
			}
			else
				retval = RAMDISK_EOF;
			break;
		case RAMDISK_TELL:
			if(fcb)
				retval = fcb->FilePointer;
			else
				retval = RAMDISK_EOF;
			break;
		case RAMDISK_FREE:
			int i;

			for(i=0;i<RAMDISK_MAXSECTORS;++i)
				if(RamFat[i] == 0xff) retval += 512;
			break;
		case RAMDISK_DELETE:
			/*
			** file name is in buffer
			** find file, then deallocate sectors
			*/
			int sector;

			if(buffer == 0)
			{
				p = iocb->dev_name;
				p = strchr(p,':');
				p++;	//point to begining of name
			}
			else
				p = buffer;
			if((d = DirSearch(p,&sector)) != NULL)
			{
				DeallocateSectors(d->start);
				d->name[0] = '?';		//mark as unoccupied
			}
			else
				retval = RAMDISK_EOF;
			RamDiskDescp->FatChecksum = CalculateFatChecksum();
			Checksums[sector] = CalculateDataChecksum(sector);
			break;
		case RAMDISK_FORMAT:
			Format();
			break;
		case RAMDISK_FILESIZE:
			retval = fcb->FileSize;
			break;
	}
	return retval;
}

