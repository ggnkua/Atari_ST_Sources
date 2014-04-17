/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module MULTI :  multi-block manager

	ex_multi

******************************************************************************/

overlay "file"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* global variables .........................................................*/

#define NMLXSCAN 7					/* keys recognized by mlx dialog box */

int data_mem,mlx_mem;				/* heap handles */
int data_drive;
char data_path[80];
char mlxfile[13],mlxpath[80];

/* multi-block manager top level ............................................*/

ex_multi()
{
#if MULTIFLAG
	int exit_obj;
	static int fixed;

	/* start with blank multi-block file name (every time) */
	mlxfile[0]=	mlxpath[0]= 0;

	/* set up drives and paths (first time only) */
	if (!fixed)
	{
		data_drive= mlt_drive;
		strcpy(data_path,mlt_path);
		fixed=1;
	}

	do
	{
		data_mem= mlx_mem= tempmem= -1;
		switch (exit_obj=mlx_dial())
		{
			case MULTADD :	mlx_add();			break;
			case MULTEXTR:	mlx_extract();		break;
			case MULTDEL :	mlx_delete();		break;
			case MULTREPL:	mlx_replace();		break;
			case MULTNAME:	mlx_name();
		}	/* end switch */
		/* buffers could be left over from the mlx_ function */
		dealloc_mem(data_mem);
		dealloc_mem(mlx_mem);
		dealloc_mem(tempmem);
	}
	while (exit_obj!=MULTEXIT);
#endif
}	/* end ex_multi() */

#if MULTIFLAG

/* handle multi-block manager dialog box ....................................*/

mlx_dial()
{
	int key,exit_obj,edit_obj;
	register int i;
	static int mlxscan[NMLXSCAN]= {
		SCAN_CR, SCAN_ESC, SCAN_A,
		SCAN_X,	SCAN_D,	 SCAN_R,	SCAN_N
	};
	static int mlxobj[NMLXSCAN]= {
		MULTEXIT, MULTEXIT, MULTADD,
		MULTEXTR, MULTDEL,  MULTREPL, MULTNAME
	};

	/* draw dialog box, centered */
	putdial(multaddr,-1,0);
	edit_obj= -1;	/* no editable objects */
	do
	{
		key=0;				/* clear out previous key */
		exit_obj= my_form_do(multaddr,&edit_obj,&dummy,1,&key);
		if (key)
		{
			key >>= 8;		/* scan code */
			for (i=0; i<NMLXSCAN; i++) if (key==mlxscan[i]) break;
			exit_obj= i==NMLXSCAN ? -1 : mlxobj[i] ;
		}
	}
	while (exit_obj<0);
	putdial(0L,0,exit_obj);
	return exit_obj;
}	/* end mlx_dial() */

/* add block to multi-block file ............................................*/

mlx_add()
{
	long blockptr[MAXNBLOCKS+1];
	char filename[13],pathname[80];
	int block,nblocks,create_it;
	register int i;
	long addr[32],leng[32];	/* oversized */
	long end_record= idEND;

	/* load data file containing block to be added */
	Dsetdrv(data_drive); dsetpath(data_path);
	filename[0]=0;
	if (!readdatafile(MLXDATTITL,filename,pathname,ALL_EXT,0)) return;
	data_drive= Dgetdrv(); Dgetpath(data_path,data_drive+1);
	data_mem= tempmem;

	/* choose block from it */
	nblocks= scan_blocks(heap[data_mem].start,blockptr);
	if (!nblocks) return;	/* can't happen? */
	block= select_block(BLOCK2ADD,nblocks,blockptr);
	if ( (block<0) || (block>=nblocks) ) return;

	/* load multi-block file to receive block */
	Dsetdrv(mlt_drive); dsetpath(mlt_path);
	create_it= readdatafile(MLXADDTITL,mlxfile,mlxpath,MLX_EXT,1);
	if (!create_it) return;
	if (create_it<0)
	{
		if (form_alert(1,CHEKCREMLX)!=1) return;
		create_it=1;
	}
	else
		create_it=0;
	mlt_drive= Dgetdrv(); Dgetpath(mlt_path,mlt_drive+1);
	mlx_mem= tempmem;

	/* because data_mem may have moved */
	scan_blocks(heap[data_mem].start,blockptr);

	/* build file -- */
	i=0;

	/* -- header */
	addr[i]= (long)(&dataheader);
	leng[i++]= sizeof(dataheader);

	/* -- if file already exists, chop header off start, end_record off end */
	if (!create_it)
	{
		addr[i]= heap[mlx_mem].start + sizeof(dataheader);
		leng[i++]= heap[mlx_mem].nbytes - 4 - sizeof(dataheader);
	}

	/* -- the new block */
	addr[i]= blockptr[block];
	leng[i++]= blockptr[block+1] - blockptr[block];

	/* -- end_record */
	addr[i]= (long)(&end_record);
	leng[i++]= 4;

	save_file(mlxfile,mlxpath,-i,addr,leng); /* replace without warning */

}	/* end mlx_add() */

/* extract block from multi-block file ......................................*/

mlx_extract()
{
	char filename[13],pathname[80];
	char *ext;
	int nblocks,block;
	register int i;
	long blockptr[MAXNBLOCKS+1];
	long addr[32],leng[32];	/* oversized */
	long end_record= idEND;
	GLOBRECORD *ptr;

	/* load multi-block file containing block to be extracted */
	Dsetdrv(mlt_drive); dsetpath(mlt_path);
	if (!readdatafile(MLXEXTTITL,mlxfile,mlxpath,MLX_EXT,0)) return;
	mlt_drive= Dgetdrv(); Dgetpath(mlt_path,mlt_drive+1);
	mlx_mem= tempmem;

	/* choose block from it */
	nblocks= scan_blocks(heap[mlx_mem].start,blockptr);
	if (!nblocks) return;	/* can't happen? */
	block= select_block(BLOCK2EXT,nblocks,blockptr);
	if ( (block<0) || (block>=nblocks) ) return;

	/* name of data file defaults to block comment */
	Dsetdrv(data_drive); dsetpath(data_path);
	ptr= (GLOBRECORD*)(blockptr[block]);
	copy_bytes(ptr->comment,filename,12L);
	filename[12]=0;
	ext=filename;
	for (i=0; i<9; i++) if (ext[i]=='.') break;
	if (i<9)
		ext+=(i+1);
	else
		ext= ALL_EXT;
	if (getfile(pathname,filename,ext,MLXXDATTITL)<=0) return;
	data_drive= Dgetdrv(); Dgetpath(data_path,data_drive+1);

	/* build file -- */
	i=0;

	/* -- header */
	addr[i]= (long)(&dataheader);
	leng[i++]= sizeof(dataheader);

	/* -- the selected block */
	addr[i]= blockptr[block];
	leng[i++]= blockptr[block+1] - blockptr[block] ;

	/* -- end record */
	addr[i]= (long)(&end_record);
	leng[i++]= 4;

	save_file(filename,pathname,i,addr,leng);

}	/* end mlx_extract() */

/* delete block from multi-block file .......................................*/

mlx_delete()
{
	int nblocks,block;
	register int i;
	long blockptr[MAXNBLOCKS+1];
	long addr[32],leng[32];	/* oversized */
	long end_record= idEND;

	/* load multi-block file containing block to be deleted */
	Dsetdrv(mlt_drive); dsetpath(mlt_path);
	if (!readdatafile(MLXDELTITL,mlxfile,mlxpath,MLX_EXT,0)) return;
	mlt_drive= Dgetdrv(); Dgetpath(mlt_path,mlt_drive+1);
	mlx_mem= tempmem;

	/* choose block from it */
	nblocks= scan_blocks(heap[mlx_mem].start,blockptr);
	if (!nblocks) return;	/* can't happen? */
	if (nblocks==1)
	{
		form_alert(1,BADMLXDEL);
		return;
	}
	block= select_block(BLOCK2DEL,nblocks,blockptr);
	if ( (block<0) || (block>=nblocks) ) return;

	/* build file -- */
	i=0;

	/* -- header */
	addr[i]= (long)(&dataheader);
	leng[i++]= sizeof(dataheader);

	/* -- blocks before the selected block */
	if (block>0)
	{
		addr[i]= blockptr[0];
		leng[i++]= blockptr[block] - blockptr[0] ;
	}

	/* -- blocks after the selected block */
	if (block<(nblocks-1))
	{
		addr[i]= blockptr[block+1];
		leng[i++]= blockptr[nblocks] - blockptr[block+1] ;
	}

	/* -- end record */
	addr[i]= (long)(&end_record);
	leng[i++]= 4;

	save_file(mlxfile,mlxpath,-i,addr,leng);	/* replace without warning */

}	/* end mlx_delete() */

/* replace block in multi-block file ........................................*/

mlx_replace()
{
	char filename[13],pathname[80];
	int mlxnblocks,mlxblock;
	int datnblocks,datblock;
	long mlxblockptr[MAXNBLOCKS+1];
	long datblockptr[MAXNBLOCKS+1];
	register int i;
	long addr[32],leng[32];	/* oversized */
	long end_record= idEND;

	/* load data file containing block to be added */
	Dsetdrv(data_drive); dsetpath(data_path);
	filename[0]=0;
	if (!readdatafile(MLXRDATTITL,filename,pathname,ALL_EXT,0)) return;
	data_drive= Dgetdrv(); Dgetpath(data_path,data_drive+1);
	data_mem= tempmem;

	/* choose block from it */
	datnblocks= scan_blocks(heap[data_mem].start,datblockptr);
	if (!datnblocks) return;	/* can't happen? */
	datblock= select_block(BLOCK2REP,datnblocks,datblockptr);
	if ( (datblock<0) || (datblock>=datnblocks) ) return;

	/* load multi-block file to receive block */
	Dsetdrv(mlt_drive); dsetpath(mlt_path);
	if (!readdatafile(MLXREPTITL,mlxfile,mlxpath,MLX_EXT,0)) return;
	mlt_drive= Dgetdrv(); Dgetpath(mlt_path,mlt_drive+1);
	mlx_mem= tempmem;

	/* choose block from it */
	mlxnblocks= scan_blocks(heap[mlx_mem].start,mlxblockptr);
	if (!mlxnblocks) return;	/* can't happen? */
	mlxblock= select_block(BLOCK2BRP,mlxnblocks,mlxblockptr);
	if ( (mlxblock<0) || (mlxblock>=mlxnblocks) ) return;

	/* because data_mem may have moved */
	scan_blocks(heap[data_mem].start,datblockptr);

	/* build file -- */
	i=0;

	/* -- header */
	addr[i]= (long)(&dataheader);
	leng[i++]= sizeof(dataheader);

	/* -- blocks before the selected block */
	if (mlxblock>0)
	{
		addr[i]= mlxblockptr[0];
		leng[i++]= mlxblockptr[mlxblock] - mlxblockptr[0] ;
	}

	/* -- new block */
	addr[i]= datblockptr[datblock];
	leng[i++]= datblockptr[datblock+1] - datblockptr[datblock] ;

	/* -- blocks after the selected block */
	if (mlxblock<(mlxnblocks-1))
	{
		addr[i]= mlxblockptr[mlxblock+1];
		leng[i++]= mlxblockptr[mlxnblocks] - mlxblockptr[mlxblock+1] ;
	}

	/* -- end record */
	addr[i]= (long)(&end_record);
	leng[i++]= 4;

	save_file(mlxfile,mlxpath,-i,addr,leng);	/* replace without warning */

}	/* end mlx_replace() */

/* rename block in multi-block file .........................................*/

mlx_name()
{
	int nblocks,block;
	GLOBRECORD *blockptr[MAXNBLOCKS+1];
	long addr[32],leng[32];	/* oversized */

	/* load multi-block file containing block to be renamed */
	Dsetdrv(mlt_drive); dsetpath(mlt_path);
	if (!readdatafile(MLXNAMTITL,mlxfile,mlxpath,MLX_EXT,0)) return;
	mlt_drive= Dgetdrv(); Dgetpath(mlt_path,mlt_drive+1);
	mlx_mem= tempmem;

	/* choose block from it */
	nblocks= scan_blocks(heap[mlx_mem].start,blockptr);
	if (!nblocks) return;	/* can't happen? */
	block= select_block(BLOCK2NAM,nblocks,blockptr);
	if ( (block<0) || (block>=nblocks) ) return;

	/* edit the comment field in the selected block, and replace file
		without warning */
	if (_mlx_name(blockptr[block]->comment))
	{
		addr[0]= heap[mlx_mem].start;
		leng[0]= heap[mlx_mem].nbytes;
		save_file(mlxfile,mlxpath,-1,addr,leng);
	}

}	/* end mlx_name() */

_mlx_name(ptr)
char *ptr;
{
	char *nameptr;
	char tempfile[13];
	int result;

	/* encode into dialog box */
	nameptr= ((TEDINFO*)(fnamaddr[FNAMTITL].ob_spec))->te_ptext;
	strcpy(nameptr,NEWBLOCKMSG);
	nameptr= ((TEDINFO*)(fnamaddr[FNAMNAME].ob_spec))->te_ptext;
	copy_bytes(ptr,tempfile,12L);
	tempfile[12]=0;
	encodefname(tempfile,nameptr);

	do
	{
		result= do_dial(fnamaddr,FNAMNAME) == OKFNAM ;
		if (result)
			if (decodefname(nameptr,tempfile))
				result= -1;
		if (result<0) form_alert(1,BADNAME);
	}
	while (result<0);
	if (result==1) strcpy(ptr,tempfile);
	return result;
}	/* end _mlx_name() */

/* allocate tempmem and load data file into it ..............................*/
/* returns 1= ok, 0 = error (message inside here) or cancel,
	-1 = file doesn't exist yet, let's create it */

readdatafile(title,filename,pathname,ext,allow_create)
char *title,*filename,*pathname,*ext;
int allow_create;
{
	int result,saveMP;

	if (midiplexer) saveMP=MPoff();
	result= _readdatafile(title,filename,pathname,ext,allow_create);
	if (midiplexer&&saveMP) MPon();
	return result;
}
_readdatafile(title,filename,pathname,ext,allow_create)
char *title,*filename,*pathname,*ext;
int allow_create;
{
	FILEHEADER *header;
	int result=0;
	long offset,load_file();
	int hand;

	if (getfile(pathname,filename,ext,title)>0)
	{
		hand= Fopen(pathname,2);
		if ( (hand<0) && allow_create ) return -1;
		if (hand>=0) Fclose(hand);
		if (load_file(pathname,filename))
		{
			header= (FILEHEADER*)(heap[tempmem].start);
			offset=0;
			if (header->magic != DATAMAGIC )
				header= (FILEHEADER*)(heap[tempmem].start+(offset=MACBINLENG));
			if (header->magic != DATAMAGIC )
				big_alert(1,BADREAD1,filename,BADREAD2);
			else
				if ( header->version > dataheader.version )
					form_alert(1,BADVERSION);				
				else
					result= 1;
		}
	}
	/* delete Mac file header */
	if (result&&offset)
	{
		copy_bytes(heap[tempmem].start+offset,heap[tempmem].start,offset);
		change_mem(tempmem,heap[tempmem].nbytes-offset);
	}
	return result;
}	/* end _readdatafile() */

#endif

/* EOF */
