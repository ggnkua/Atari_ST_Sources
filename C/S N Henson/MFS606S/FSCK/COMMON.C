/* This file is part of 'fsck' Copyright S.N. Henson */

/* Functions Common to V1 and V2 Filesystems */

#include <stdio.h>
#include <alloc.h>
#include <string.h>
#include <stdlib.h>
#include "fs.h"
#include "global.h"
#include "proto.h"

/* Parse a comma separated list of integers, return number of integers read.
 * Fill in elements in a linked list. 
 */

int comma_parse(str,list)
char *str;
llist **list;
{
	char *tstr,*fstr,*comma;
	int count;
	count=0;
	if( !(tstr=strdup(str)) ) fatal("Out of memory");
	fstr=tstr;

	do
	{
		llist *p;
		comma=strchr(tstr,',');
		if(comma) *comma=0;
		if( !(p=malloc(sizeof(list)) ) ) fatal("Out of memory");
		p->member=atol(tstr);		
		p->next=*list;
		*list=p;
		count++;
		if(comma) tstr=++comma;
	}
	while(comma);

	free(fstr);

	return count;
}

void read_zone(zone,buff)
long zone;
void *buff;
{
	read_blocks(zone,1,buff);
}

void write_zone(zone,buff)
long zone;
void *buff;
{
	if(zone==0)
	{
		printf("Illegal Write Zone\n");
		return;
	}
	write_blocks(zone,1,buff);
}

/* Check a zone number is legitimate */
int chk_range(zone)
long zone;
{
	if( (zone > maxzone) || (zone < minzone) ) return 0;
	return 1;
}


/* Bitmap stuff */

void setbit(zone,map)
long zone;
unsigned *map;
{
	map[zone>>4] |= (1<<(zone & 0xf));
}

void clrbit(zone,map)
long zone;
unsigned *map;
{
	map[zone>>4] &= ~(1<<(zone & 0xf));
}

int isset(zone,map)
long zone;
unsigned *map;
{
	return( ( map[zone>>4] & ( 1<<(zone & 0xf) ) ) ? 1:0 );
}

/* Find the first Zero bit in bitmap */
long findbit(map,limit)
unsigned *map;
long limit;
{
	long ret;
	long i;
	int j;

	for(i=0;i<(limit+15/16);i++)
	{
		if(map[i]!=0xffff)
		{
			for(j=0;j<16;j++) 
			{
				if(!(map[i] & (1<<j)))
				{
							
					ret=i*16+j;
					if(ret < limit)
					{
						setbit(ret,map);
						return ret;
					}
					return 0;
				}
			}
		}
	}
	return 0;
}

long alloc_zone()
{
	long ret;
	ret=findbit(szbitmap,maxzone-minzone);
	if(!ret) return 0;
	ret+=minzone-1;
	return ret;
}

int mark_zone(zone)
long zone;
{
	unsigned ret;
	zone-=minzone-1;
	ret= isset(zone,szbitmap);
	setbit(zone,szbitmap);
	return ret;
}

void unmark_zone(zone)
long zone;
{
	zone-=minzone-1;
	clrbit(zone,szbitmap);
}

int ask(str,alt)
char *str;
char *alt;
{
	char ans[20];
	if(alln) return 0;
	if(ally)
	{
		printf("(%s)",alt);
		return 1;
	}
	printf("%s",str);
	fgets(ans,20,stdin);
	if( (ans[0] & ~32) == 'Y') return 1;
	return 0;
}

void fatal(str)
char *str;
{
	printf("Fatal error: %s\n",str);
	close_device();
	exit(1);
}

void sfatal(str)
char *str;
{
	printf("Bad Superblock: %s\n",str);
	close_device();
	exit(1);
}


void usage()
{
	printf("Usage : fsck device\n");
	printf("Filesystem consistency checker. Copyright S.N. "
	"Henson 1992,1993.\nAll Rights Reserved\n");
	printf("Version 0.0 pre-alpha patchlevel 5\n");
	exit(1);
}

/* Read in superblock, perform some sanity checks on it, then read in the 
 * bitmaps.
 */

void read_tables()
{
	Super=(super_block *)malloc(BLOCKSIZE);
	read_zone(1,Super);
	/* Sanity checks on super block */
	if(Super->s_magic!=SUPER_V1)
	{

		if(Super->s_magic==SUPER_V2) 
		{
			version=1;
			maxzone=Super->s_zones;
		}
		else sfatal("Invalid Magic Number");
	}
	else maxzone=Super->s_nzones;

	if(set_size(maxzone)) fatal("Cannot access filesystem");

	if( (Super->s_ninodes+8192l)/8192 != Super->s_imap_blks)	
		sfatal("Inode Bitmap Wrong Size");
	if( (maxzone+8192)/8192 !=Super->s_zmap_blks )
		sfatal("Zone Bitmap Wrong Size");

	/* Set up some variables */

	maxino=Super->s_ninodes;
	minzone=Super->s_firstdatazn;
	maxzone--;

}

int do_trunc()
{
	printf("Inode %ld Contains Too Many Zones\n",cino);
	done_trunc=1;
	if(ask("Truncate?","Truncated"))
	{
		trunc=1;
		return 1;
	}
	return 0;
}


int chk_irange(inum)
unsigned inum;
{
	if(inum && inum <=maxino) return 1;
	return 0;
}


void inerr(name)
char *name;
{
	printf("Inode %ld: %s\n",cino,name);
}

int badname(name)
char *name;
{
	if(strchr(name,'/')) return 1;
	return 0;
}

/* Copy a directory entry */
void cpdir(dest,src)
dir_struct *dest,*src;
{
	bcopy((char*)src,(char *)dest,DSIZE*incr);
}

/* Show FS info */
void showinfo()
{
	if(info)
	{
		printf("\nDrive %s\n",drvnam);
		printf("V%d Filesystem\n",version+1);
		printf("Directory Increment %d\n",incr);
		printf("%ld\t\tInodes\n",maxino);
		printf("%ld\t\tFree Inodes\n",ifree);
		printf("%ld\t\tData Zones\n",maxzone-minzone+1);
		printf("%ld\t\tFree Data Zones\n",zfree);
		printf("%ld\t\tDirectories\n",ndir);
		printf("%ld\t\tRegular Files\n",nreg);
		printf("%ld\t\tSymbolic Links\n\n",nsym);
#ifdef NOTUSED
		printf("%ld\t\tFIFO's\n",nfifo);
		printf("%ld\t\tCharacter Special Files\n",nchar);
		printf("%ld\t\tBlock Special Files\n",nblk);
#endif
	}

	if(info>1)
	{
		printf("First Inode Block  %ld\n",ioff);
		printf("First Datazone     %ld\n\n",minzone);
	}
	if(modified) 
	{
		printf("**************************************\n");
		printf("*    FILESYSTEM HAS BEEN MODIFIED    *\n");
		printf("**************************************\n\n");
	}
}
