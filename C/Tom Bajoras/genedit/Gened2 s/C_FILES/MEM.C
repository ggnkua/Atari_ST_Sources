/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module: MEM -- memory manager

	init_mem, alloc_mem, dealloc_mem, change_mem, avail_mem, fill_mem
	copy_mem

******************************************************************************/

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* initialize heap management ...............................................*/
/* returns 1 successful, 0 failed (no error message) */

init_mem(nbytes)
register long nbytes;	/* # bytes requested for heap */
{
	register int i;

	/* Malloc can't be trusted with < 256 bytes */
	if (nbytes<256L) return 0;
	if (nbytes&0xffL) nbytes= (nbytes+0xff)&0xffffff00;

	heap_start= Malloc(nbytes);						/* get heap from system */
	if (heap_start<=0L) return 0;
	heap_nbytes= nbytes;

	for (i=0; i<NHEAPBLKS; i++) heap[i].start= heap[i].nbytes= 0L;

	/* heap divided into 1 block, filling entire heap, unowned */
	nmemblks=1;
	mem[0].start= heap_start;
	mem[0].nbytes= heap_nbytes;
	mem[0].handle= -1;
	return 1;

}	/* end init_mem() */

/* allocate block of memory from heap .......................................*/
/* returns handle of block (>=0), -1 error (message inside this function) */

alloc_mem(_nbytes)
long _nbytes;	/* size of requested block */
{
	register int i,j;
	register long nbytes;
	int handle= -1;
	int nexthandle;
	long memnbytes;
	long avail_mem();

	nbytes= _nbytes;
	if (nbytes&1) nbytes++; /* must be even */

	/* all handles used? */
	for (nexthandle=0; nexthandle<NHEAPBLKS; nexthandle++)
		if (!heap[nexthandle].start) break;
	if (nexthandle==NHEAPBLKS) goto exit_this;

	/* not enough memory? */
	if (avail_mem()<nbytes) goto exit_this;

	/* try to find a single unused memory block big enough */
	for (i=0; i<nmemblks; i++)
	{
		if (mem[i].handle<0) /* this block unowned */
		{
			memnbytes= mem[i].nbytes;
			if (memnbytes>=nbytes) /* this block is big enough */
			{
				if (memnbytes>nbytes) /* split the block */
				{
					if (nmemblks==NMEMBLKS) continue;
					split_mem(i,nbytes);
				}
				handle= nexthandle;
				heap[handle].start= mem[i].start;
				heap[handle].nbytes= nbytes;
				mem[i].handle= handle;
				goto exit_this;
			}
		}
	}

	/* merge smallest number of unused blocks at end of heap */
	memnbytes=0L;
	for (j=nmemblks-1; j>=0; j--)
	{
		if (mem[j].handle<0) memnbytes+=mem[j].nbytes;
		if (memnbytes>=nbytes) break;
	}
	if (j>=0)
	{
		compact_mem(j);
		return alloc_mem(nbytes);
	}

exit_this:
	if (handle<0)
		form_alert(1,BADMEM2);
	else
		pad_mem(handle,_nbytes);
	return handle;

}	/* end alloc_mem() */

/* delete block of memory from heap .........................................*/
/* returns 1= success, 0= error (handle not in use -- no error message) */

dealloc_mem(handle)
int handle;	/* handle to be deleted */
{
	register int i;
	register long del_ptr,size;

	if ((handle<0)||(handle>=NHEAPBLKS)) return 0;	/* nonsense handle */
	if (!heap[handle].start) return 0;					/* unused handle */

	heap[handle].start= heap[handle].nbytes= 0L;

	for (i=0; i<nmemblks; i++) if (mem[i].handle==handle) break;
	mem[i].handle= -1;
	collect_mem();
	return 1;

}	/* end dealloc_mem() */

/* merge adjacent unowned blocks, eliminate unowned null blocks */

collect_mem()
{
	register int i,j;

	i=0;
	while (i<(nmemblks-1))
	{
		if ( (mem[i].handle<0) && (mem[i+1].handle<0) )
		{
			mem[i].nbytes += mem[i+1].nbytes;
			for (j=i+1; j<(nmemblks-1); j++) mem[j]=mem[j+1];
			nmemblks--;
			i=0;
		}
		else
			i++;
	}
	i=0;
	while (i<nmemblks)
	{
		if ( (mem[i].handle<0) && !mem[i].nbytes )
		{
			for (j=i; j<(nmemblks-1); j++) mem[j]=mem[j+1];
			nmemblks--;
			i=0;
		}
		else
			i++;
	}
}	/* end collect_mem() */

/* change memory block size .................................................*/
/* returns 1= success, 0= error (error message inside this function) */

change_mem(handle,_newsize)
int handle;			/* handle to be changed */
long _newsize;
{
	register long del,oldsize;
	register int i,j;
	long newsize;
	long avail_mem();
	int forward,backward;

	/* check for nonsense handle */
	if ( (handle<0) || (handle>=NHEAPBLKS) ) goto bad_ret3;
	/* check for unused handle */
	if ( !heap[handle].start ) goto bad_ret3;
	/* check for nonsense size */
	if (_newsize<0L) goto bad_ret3;

	oldsize= heap[handle].nbytes;
	newsize= _newsize;
	if (newsize&1) newsize++;									/* must be even */
	del= newsize-oldsize;										/* change in size */
	if (!del) return 1;											/* no effect */
	if (del>avail_mem()) goto bad_ret2;						/* can't get that big */

	/* which memory block are we talking about? */
	for (i=0; i<nmemblks; i++) if (mem[i].handle==handle) break;

	/* unused block after it? */
	forward= (i<(nmemblks-1)) && (mem[i+1].handle<0) ;
	/* unused block before it? */
	backward= (i>0) && (mem[i-1].handle<0) ;

	/* shrink it */
	if (del<0L)
	{
		if (forward)	/* following unused block gets bigger */
		{
			mem[i].nbytes += del ;
			mem[i+1].nbytes -= del ;
			mem[i+1].start += del ;
		}
		else
		{	/* create unused block between this block and following used block */
			if (nmemblks==NMEMBLKS) goto bad_ret3;
			split_mem(i,newsize);
		}
		goto good_ret;
	}

	/* expand */
	if (del>0L)
	{
		if (forward)
		{	/* expand into following unused block */
			if (mem[i+1].nbytes >= del)
			{
				mem[i].nbytes += del ;
				mem[i+1].nbytes -= del ;
				mem[i+1].start += del ;
				goto good_ret;
			}
		}
		if (backward)
		{	/* expand into preceding unused block */
			if (mem[i-1].nbytes >= del)
			{
				move_mem(mem[i].start,mem[i].start-del,-mem[i].nbytes);
				mem[i].start -= del;
				mem[i].nbytes += del;
				mem[i-1].nbytes -= del;
				heap[handle].start= mem[i].start;
				goto good_ret;
			}
		}
		if (forward&&backward)
		{	/* fill following unused block,
				then expand into preceding unused block */
			if ( (mem[i-1].nbytes+mem[i+1].nbytes) >= del )
			{
				del -= mem[i+1].nbytes ;
				mem[i].nbytes += mem[i+1].nbytes;
				mem[i+1].nbytes = 0L;
				mem[i+1].start = mem[i].start + mem[i].nbytes ;
				move_mem(mem[i].start,mem[i].start-del,-mem[i].nbytes);
				mem[i].start -= del;
				mem[i].nbytes += del;
				mem[i-1].nbytes -= del;
				heap[handle].start= mem[i].start;
				goto good_ret;
			}
		}
		/* try to find a single unused block big enough */
		for (j=0; j<nmemblks; j++)
			if ( (mem[j].handle<0) && (mem[j].nbytes>=newsize) ) break;
		if (j<nmemblks)
		{
			if ( (mem[j].nbytes==newsize) || (nmemblks<NMEMBLKS) )
			{
				if (j>i)	/* move forward */
					move_mem(mem[i].start,mem[j].start,oldsize);
				else		/* move backward */
					move_mem(mem[i].start,mem[j].start,-oldsize);
				mem[i].handle= -1;
				mem[j].handle= handle;
				heap[handle].start= mem[j].start;
				if (mem[j].nbytes>newsize) split_mem(j,newsize);
				goto good_ret;
			}
		}
		/* this isn't really right -- this works only when the sum of unowned
			block lengths >= newsize.  The right way is to push memory blocks
			after i up in memory, push memory blocks below i down in memory,
			and then return change_mem(handle,newsize).  That way it would
			work when sum of unowned block lengths >= del !!! */
		if (compact_mem(0))
			return change_mem(handle,newsize);
		else
			goto bad_ret2;
	}

good_ret:
	collect_mem();
	heap[handle].nbytes= newsize;
	pad_mem(handle,_newsize);
	return 1;
bad_ret2:
	form_alert(1,BADMEM2);
	return 0;
bad_ret3:
	form_alert(1,BADMEM3);
	return 0;
}	/* end change_mem() */

move_mem(from,to,n)
register int *from,*to;
register long n;		/* <0L for backward move, >0L for forward */
{
	n/=2;	/* convert from bytes to words */
	if (!n) return;	/* you really shouldn't have called move_mem() */
	if (n<0L)
	{
		n= -n;
		for (; n>0L; n--) *to++ = *from++;
	}
	else
	{
		from += n;
		to += n;
		for (; n>0L; n--) *(--to) = *(--from);
	}
}	/* end move_mem() */

split_mem(i,nbytes)
register int i;		/* which memory block is to be split */
long nbytes;			/* new size for block (must be < current size) */
{
	register int j;

	for (j=nmemblks-1; j>i; j--) mem[j+1]=mem[j];
	nmemblks++;
	mem[i+1].start= mem[i].start + nbytes;
	mem[i+1].nbytes= mem[i].nbytes-nbytes;
	mem[i].nbytes= nbytes;
	mem[i+1].handle= -1;
}	/* end split_mem() */

compact_mem(i)
register int i;
{
	register int j;
	register long bothnbytes;
	int result=0;

	j=i;
	while (j<(nmemblks-1))
	{
		if ( (mem[j].handle<0) && (mem[j+1].handle>=0) )
		{
			move_mem(mem[j+1].start,mem[j].start,-mem[j+1].nbytes);
			bothnbytes= mem[j].nbytes + mem[j+1].nbytes;
			mem[j].nbytes= mem[j+1].nbytes;
			mem[j].handle= mem[j+1].handle;
			mem[j+1].start= mem[j].start + mem[j].nbytes;
			mem[j+1].nbytes= bothnbytes - mem[j].nbytes;
			mem[j+1].handle= -1;
			heap[mem[j].handle].start= mem[j].start;
			collect_mem();
			j=i;
			result=1;	/* something happened */
		}
		else
			j++;
	}
	return result;
}	/* end compact_mem() */

/* what's the largest heap block that can be allocated ......................*/

long avail_mem()
{
	register int i;
	register long maxsize= 0L;

	/* !!!...
	for (i=0; i<nmemblks; i++)
		if ( (mem[i].handle<0) && (mem[i].nbytes>maxsize) )
			maxsize= mem[i].nbytes;
	return maxsize;
	... */

	/* sum of all unowned memory blocks */
	for (i=0; i<nmemblks; i++)
		if (mem[i].handle<0) maxsize += mem[i].nbytes;

	return maxsize;
}	/* end avail_mem() */

/* expand a heap to all available memory ....................................*/

fill_mem(i)
int i;	/* heap handle: must be in use */
{
	long templong;
	long avail_mem();

	/* simplified !!! */
	templong= max(heap[i].nbytes,avail_mem());
	templong= min(templong,MAXHEAPSIZE);	/* otherwise slow on mega */
	change_mem(i,templong);
	return;

	templong= heap[i].nbytes + avail_mem();
	change_mem(i,templong);

}	/* end fill_mem() */

/* copy a heap block ........................................................*/
/* returns 1= ok, 0= error */
/* use this throughout, for example when copying tem pages !!! */

copy_mem(from,to)
int from,to;	/* heap handles */
{
	register long templong;
	int result=0;

	templong= heap[from].nbytes;
	if (change_mem(to,templong))
	{
		copy_words(heap[from].start,heap[to].start,templong/2);
		result=1;
	}
	return result;
}	/* end copy_mem() */

/* optional single null pad byte at end of heap .............................*/

pad_mem(handle,_nbytes)
int handle;
long _nbytes;	/* might not be even */
{
	if ( _nbytes< heap[handle].nbytes )
		*(char*)(heap[handle].start + _nbytes)= 0;
}	/* end pad_mem() */

/* get rid of this in final version !!! */
display_mem()
{
	register int i;

	HIDEMOUSE;
	save_screen(0,200*rez-1);
	Cconout(0x1b); Cconout(0x45);

	for (i=0; i<nmemblks; i++)
	{
		display1mem(mem[i].start,mem[i].nbytes,mem[i].handle);
		if ( (i%18)==17 )
		{
			Cconws("\n\r\n\r   --- Type any key ---");
			Crawcin();
		}
	}
	Cconws("\n\r\n\r   --- Type any key ---");
	Crawcin();

	rest_screen(0,200*rez-1);
	SHOWMOUSE;

}
display1mem(start,nbytes,handle)
register long start,nbytes;
register int handle;
{
	char buf[80];
	char buf2[30];
	register int i;
	unsigned int ch,lo,hi;
	char *ptr;

	strcpy(buf,"\n\rStart= $");
	for (i=3; i>=0; i--)
	{
		ch= (start>>(8*i))&0xff;
		hi= ch>>4;
		lo= ch&0xf;
		buf2[0]= (hi<10) ? hi+'0' : hi-10+'A' ;
		buf2[1]= (lo<10) ? lo+'0' : lo-10+'A' ;
		buf2[2]= 0;
		strcat(buf,buf2);
	}

	strcat(buf,"    Length= $");
	for (i=3; i>=0; i--)
	{
		ch= (nbytes>>(8*i))&0xff;
		hi= ch>>4;
		lo= ch&0xf;
		buf2[0]= (hi<10) ? hi+'0' : hi-10+'A' ;
		buf2[1]= (lo<10) ? lo+'0' : lo-10+'A' ;
		buf2[2]= 0;
		strcat(buf,buf2);
	}

	strcat(buf,"    Owner= ");
	itoa(handle,buf2,-1);
	strcat(buf,buf2);
	Cconws(buf);
}

/* EOF */
