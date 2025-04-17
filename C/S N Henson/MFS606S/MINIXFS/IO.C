/* This file is part of 'minixfs' Copyright 1991,1992,1993 S.N.Henson */

#include "minixfs.h"
#include "global.h"
#include "proto.h"

/* This is a 'corrected rwabs' , it behaves as though sector-size==1K
 * irrespective of what it really is. Currently it only supports 512 byte 
 * and 1K sectors , also if the extended rwabs is needed use it .
 */

void crwabs(rw,buf,num,recno,dev)
int rw;
void *buf;
unsigned num;
long recno;
int dev;
{
	long r;

	if(!super_ptr[dev]) {
		ALERT("Minixfs : attempted I/O with illegal Drive %c:",dev+'A');
		ALERT("Minixfs : please submit a bug report!");
		return;
	}

	if( (rw & 1) && (recno < 2) )
	{
		ALERT("Minixfs: illegal write");
		return;
	}

	r = block_rwabs(rw,buf,num,recno,&disk[dev]);

	if (r) ALERT("minixfs: Rwabs returned %ld sector %ld drive %c:"
				, r,recno,dev+'A');

	return;
}
