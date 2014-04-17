/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990/1991 Tom Bajoras

	module FILE :  file functions

	disktowind, windtodisk, windtowind,
	disktomidi, miditodisk, windtomidi, miditowind
	load_data, load_genp, load_nong
	miditobuf, buftomidi, edittomidi, edittodev
	savedatafile

	disktodev, windtodev, devtodisk, devtowind

	init_studio, load_studio, save_studio, edit_studio

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

int tempcnxmem,tempdatamem;
char *alertstr[2]= { CHNGELDAT, CHNGERDAT };

long load_file(),atol();
char *get_extent();

	/* in cnx.c */
extern int cnxlcursn;
	/* in cnftocnx.c */
extern int ge_nfields;
extern char ge_fieldtype[];
extern long ge_fieldval[];
extern char ge_buf[];

/* file to window ...........................................................*/

disktowind(side)
int side;		/* 0= left, 1= right */
{
	char filename[13],pathname[80];
	char *ext;
	register int i,ch;
	register long *lptr;
	long fileleng,offset;
	int error;
	char savename[NCHPERCNX];

	/* overwrite changed data? */
	if (change_flag[side ? rdatCHANGE : ldatCHANGE])
		if (form_alert(1,alertstr[side])==2) return;

	filename[0]=0;
	Dsetdrv(side ? rdat_drive : ldat_drive);
	dsetpath(side ? rdat_path : ldat_path);
	tempmem= -1;

	/* when loading from disk, show same kind of file as is already in window */
	ext= get_extent(windfile[side]);
	if (!ext) ext= ALL_EXT;

	if (getfile(pathname,filename,ext,side ? RLDE_TITL : LLDE_TITL)>0)
	{
		i= Dgetdrv();
		if (side)
			rdat_drive= i;
		else
			ldat_drive= i;
		Dgetpath(side ? rdat_path : ldat_path, i+1 );

		if (fileleng=load_file(pathname,filename))
		{
			/* save old window config name */
			copy_bytes(windcnxname[side],savename,(long)(NCHPERCNX));
			lptr= (long*)( heap[tempmem].start );
			/* skip Mac file header */
			offset=0L;
			if ((lptr[0]!=DATAMAGIC)&&(lptr[0]!=GENPMAGIC))
			{
				lptr += MACBINLENG/4 ;
				offset= MACBINLENG;
			}
			switch ( lptr[0] )
			{
				case DATAMAGIC: error= load_data(side,-1,filename,offset)<0; break;
				case GENPMAGIC: error= load_genp(side); 	break;
				default:			 error= load_nong(side,fileleng);
			}
			if (!error)
			{
				strcpy(windfile[side],filename);
				/* if window config name changed, reset its device info */
				if ( windlodc &&
					  comp_bytes(windcnxname[side],savename,(long)NCHPERCNX) )
				{
					i= find_device(&windcnxname[side][NCHPERCNX-3]);
					if (i<0)
						init_device(&wind_device[side]);
					else
						wind_device[side]= studioDev[i];
				}
				draw_window(side);
				change_flag[side ? rdatCHANGE : ldatCHANGE]=0;
			}
		}	/* end if file loaded into tempmem successfully */
	}	/* end if OK from file selector */

	dealloc_mem(tempmem);

}	/* end disktowind() */

/* file to midi .............................................................*/

disktomidi()
{
	disktodev(-1);
}

/* midi to file .............................................................*/

miditodisk()
{
	devtodisk(-1);
}	/* end miditodisk() */

/* midi to window ...........................................................*/

miditowind(side)
register int side;	/* 0= left, 1= right */
{
	devtowind(-1,side);
}	/* end miditowind() */

/* window to midi ...........................................................*/

windtomidi(side)
int side;	/* 0= left, 1= right */
{
	windtodev(side,-1);
}	/* end windtomidi() */

/* window to file ...........................................................*/

windtodisk(side)
int side;		/* 0= left, 1= right */
{
	char filename[13],pathname[80];
	char *ext;
	int temp,dmem,cmem;
	register int i;

	strcpy(filename,windfile[side]);
	Dsetdrv(side ? rdat_drive : ldat_drive);
	dsetpath(side ? rdat_path : ldat_path);

	ext= get_extent(filename);
	if (!ext) ext= ALL_EXT;
	if (getfile(pathname,filename,ext,side ? RSVE_TITL : LSVE_TITL)>0)
	{
		temp= Dgetdrv();
		if (side)
			rdat_drive= temp;
		else
			ldat_drive= temp;
		Dgetpath(side ? rdat_path : ldat_path, temp+1 );
		dmem= windatamem[side];
		cmem= windcnxmem[side];
		if (savedatafile(filename,pathname,windcnxname[side],
							  heap[dmem].nbytes,heap[dmem].start,
							  heap[cmem].nbytes,heap[cmem].start))
		{
			strcpy(windfile[side],filename);
			draw_file(side);
			change_flag[side ? rdatCHANGE : ldatCHANGE]=0;
		}	/* end if file saved successfully */
	}	/* end if got a file from file selector */
}	/* end windtodisk() */

/* window to window .........................................................*/

windtowind(from,to)
register int from,to;	/* 0= left, 1= right */
{
	/* overwrite changed data? */
	if (change_flag[to ? rdatCHANGE : ldatCHANGE])
		if (form_alert(1,alertstr[to])==2) return;

	/* copy stuff */
	copy_mem(windatamem[from],windatamem[to]);
	copy_mem(windcnxmem[from], windcnxmem[to] );
	copy_bytes(windcnxname[from],windcnxname[to],(long)(NCHPERCNX));
	strcpy(windfile[to],windfile[from]);
	wind_device[to]= wind_device[from];
	change_flag[to ? rdatCHANGE : ldatCHANGE]=
		change_flag[from ? rdatCHANGE : ldatCHANGE];

	draw_window(to);

}	/* end windtowind() */

/* midi to buffer ...........................................................*/
/* returns # data bytes received (even), 0L for error or cancelled */

long miditobuf(devNum,side,out)
int devNum;		/* source device, -1 means from midi */
int side;		/* 0= midi to left window,
						1= midi to right window,
					  -1= midi to disk
					*/
int *out;		/* which cnx used */
{
	static int last=0;
	int which,abort,temp;
	int lastbyte;
	long start,end;
	long nbytes,templong,avail_mem();
	char *datastart,*dataend,*dataptr;

	/* context */
	set_device(devNum);
	if (devNum<0)
	{
		which= choose_cnx(last);
		if (which<0) return 0L;
		last=which;
	}
	else
	{
		which= studioLink[devNum].confignum;
		if (which>=0)
		{
			if ( comp_bytes(&cnxname[which][NCHPERCNX-3],
					studioLink[devNum].extent, 3L) )
			{
				if (big_alert(2,BADDEVCNX1,studioLink[devNum].extent,
					BADDEVCNX2)==2) return 0L;
				/* try to find a config with the right extent */
				which= find_cnxextent(studioLink[devNum].extent);
				which= choose_cnx(which);
			}
		}
		else
			which= choose_cnx(-1);
		if (which<0) return 0L;
		if ( !(cnxoffset[which+1]-cnxoffset[which]) ) return 0L;
	}
	*out= which;

	/* prepare temporary buffer to receive data */
	nbytes= avail_mem();
	tempmem= nbytes<=0L ? -1 : alloc_mem(nbytes);
	if (tempmem<0) return 0L;
	datastart= (char*)( heap[tempmem].start );
	dataend= datastart + nbytes;

	/* if there's a Common segment, exec it first, then exec Receive */
	reset_cnx();
	if (findcnxseg(which,(int)(cnxCMMN),&start,&end))
		exec_cnx((int)(cnxCMMN),start,end,&dummy,&dummy,&dummy,&dummy,0L);
	if (findcnxseg(which,(int)(cnxRECV),&start,&end))
	{
		exec_cnx((int)(cnxRECV),start,end,datastart,dataend,
					&dummy,&dummy,ACTIVE_MSG);
		nbytes= cnxvars[VAR_PTR];
	}
	else
		nbytes= 0L;

	abort= cnxvars[VAR_ERR];
	dataptr= datastart+nbytes;	/* start + index = pointer */

	/* buffer empty or filled with nothing but END_OF_DATA */
	for (templong=nbytes-1; templong>=0L; templong--)
	{
		lastbyte= datastart[templong];
		if (lastbyte!=END_OF_DATA) break;
	}
	if (templong<0) nbytes=0L;

	/* keep data bytes from aborted command?  (default is to keep if last byte
		in data buffer is EOX, otherwise default is to  discard) */
	if (nbytes&&abort)
	{
		temp= (lastbyte&0xFF)==midiEOX ? 1 : 2 ;
		if (form_alert(temp,CHEKKEEP)==2) nbytes=0L;
	}

	/* must be even (pad data buffer with end markers) */
	if (nbytes&1)
	{
		nbytes++;
		*dataptr++ = END_OF_DATA;
	}
	/* if successful, update window midi channel */
	if (nbytes&&(side>=0)) get_device(&wind_device[side]);

	return nbytes;

}	/* end miditobuf() */

/* buffer to midi ...........................................................*/

buftomidi(side,cnxhand,datahand,filename)
int side;		/* 0= left window to midi,
						1= right window to midi,
					  -1= disk to midi
					*/
int cnxhand,datahand;	/* cnxhand heap contains a single cnx */
char *filename;			/* name of file to be sent */
{
	long datastart,dataend,oldsize;
	int bufmem;
	char cnxinfomsg[81];

	/* build CNX info line */
	strcpy(cnxinfomsg,CNXINFO1_MSG);
	strcat(cnxinfomsg,filename);
	strcat(cnxinfomsg,CNXINFO2_MSG);

	/* expand the data buffer so that transmit segment can use high mem */
	oldsize= heap[datahand].nbytes;
	fill_mem(datahand);

	/* start and end of data buffer */
	datastart= heap[datahand].start;
	dataend= datastart + heap[datahand].nbytes;

	/* if there's a Common segment, exec it first, then exec Transmit */
	exec_seg(cnxhand,(int)cnxTRAN,datastart,dataend,&dummy,&dummy,cnxinfomsg);

	/* if successful, update window device */
	if ( !cnxvars[VAR_ERR] && (side>=0) ) get_device(&wind_device[side]);

	/* shrink data buffer back to original size */
	change_mem(datahand,oldsize);
}	/* end buftomidi() */

/* send edit buffer to midi .................................................*/
/* returns 1= ok, 0= error */

edittomidi(side)
register int side;	/* 0= left, 1= right */
{
	edittodev(side,-1);
}	/* end edittomidi() */

/* send edit buffer to a device .............................................*/
/* returns 1= ok, 0= error */

edittodev(side,devNum)
int side,devNum;		/* side= 0 or 1, devNum= 0-(NDEVICES-1), -1 to midi */
{
	long editstart,editend;
	long datastart,dataend;
	int result;

	/* start and end of edit buffer (= data buffer) */
	editstart= heap[editmem].start;
	editend= editstart + heap[editmem].nbytes;
	datastart= heap[windatamem[side]].start;
	dataend= datastart + heap[windatamem[side]].nbytes ;

	/* context */
	if (devNum<0)
		set_device(NDEVICES+side);
	else
	{
		if (studioLink[devNum].confignum>=0)
			if ( comp_bytes(&windcnxname[side][NCHPERCNX-3],
								studioLink[devNum].extent, 3L) )
				if (form_alert(2,CHEKDEVDIF)==2) return 0;
		set_device(devNum);
	}

	graf_mouse(255,midi_icon);
	/* if there's a Common segment, exec it first, then exec Send */
	result=
		exec_seg(windcnxmem[side],(int)cnxSEND,
					editstart,editend,editstart,editend,0L);
	graf_mouse(ARROWMOUSE);
	if (result) get_device(&wind_device[side]);

	return result;
}	/* end edittodev() */

/* disk to device ...........................................................*/

disktodev(devNum)
int devNum;				/* 0..(NDEVICES-1), -1 disk to midi */
{
	char filename[13],pathname[80];
	char title[80];
	char *ext;
	int block,nblocks;
	register long *lptr;
	long fileleng,offset;
	int i;

	/* allocate virtual window */
	tempcnxmem= alloc_mem(0L);
	if (tempcnxmem<0) return;
	tempdatamem= alloc_mem(0L);
	if (tempdatamem<0)
	{
		dealloc_mem(tempcnxmem);
		return;
	}

	filename[0]=0;
	tempmem= -1;
	Dsetdrv(midi_drive); dsetpath(midi_path);
	if (devNum<0)
	{
		strcpy(title,MLDE_TITL);
		ext= ALL_EXT;
	}
	else
	{
		strcpy(title,DSK2DVTITL);
		strcat(title,studioLink[devNum].name);
		ext= studioLink[devNum].extent;
		if (!ext[0]) ext=ALL_EXT;
	}
	if (getfile(pathname,filename,ext,title)>0)
	{
		midi_drive= Dgetdrv(); Dgetpath(midi_path,midi_drive+1);
		if (fileleng=load_file(pathname,filename))
		{
			lptr= (long*)( heap[tempmem].start );
			/* skip Mac file header */
			offset=0L;
			if ((lptr[0]!=DATAMAGIC)&&(lptr[0]!=GENPMAGIC))
			{
				lptr += MACBINLENG/4 ;
				offset= MACBINLENG;
			}
			switch ( lptr[0] )
			{
				case DATAMAGIC :	/* send all the blocks */
				block=0;
				while ( (nblocks=load_data(-1,block++,filename,offset)) >= 0 )
				{
					i= devNum;
					if (i<0)		/* try to figure out where to send it */
					{
						ext= get_extent(filename);
						if (ext)
							i= find_device(ext);
					}
					set_device(i);
					buftomidi(-1,tempcnxmem,tempdatamem,filename);
					/* stop prematurely */
					if ( cnxvars[VAR_ERR] && (block<nblocks) )
						if (form_alert(1,CHEKMLXBREAK)==1) break;
				}
				if (!cnxvars[VAR_ERR]) make_tone();
				break;

				case GENPMAGIC :
				if (!load_genp(-1))
				{
					set_device(devNum);
					buftomidi(-1,tempcnxmem,tempdatamem,filename);
					if (!cnxvars[VAR_ERR]) make_tone();
				}
				break;

				default:
				form_alert(1,BADNONGFIL);
			}
		}	/* end if file loaded successfully */
	}	/* end if ok from file selector */

	dealloc_mem(tempmem);
	dealloc_mem(tempcnxmem);
	dealloc_mem(tempdatamem);
}

/* window to device .........................................................*/

windtodev(side,devNum)
int side,devNum;				/* devNum= -1 means window-to-midi */
{
	/* set up context */
	if (devNum<0)
		set_device(side+NDEVICES);
	else
	{
		if (studioLink[devNum].confignum>=0)
			if ( comp_bytes(&windcnxname[side][NCHPERCNX-3],
								studioLink[devNum].extent, 3L) )
				if (form_alert(2,CHEKDEVDIF)==2) return;
		set_device(devNum);
	}
	buftomidi(side,windcnxmem[side],windatamem[side],windfile[side]);
	if (!cnxvars[VAR_ERR]) make_tone();
}

/* device to disk ...........................................................*/

devtodisk(devNum)
int devNum;				/* -1 means midi to disk */
{
	char filename[13],pathname[80];
	int which;
	long nbytes,miditobuf();
	char file_ext[4];

	tempmem= -1;
	nbytes= miditobuf(devNum,-1,&which);
	if (nbytes>0L)
	{
		make_tone();
		/* default file name */
		strcpy(filename,defdataname);	/* without extension */
		copy_bytes(&cnxname[which][NCHPERCNX-3],file_ext,3L);
		file_ext[3]=0;
		if (ext_ok(file_ext))
		{
			strcat(filename,".");
			strcat(filename,file_ext);
		}
		else
			strcpy(file_ext,ALL_EXT);
		Dsetdrv(midi_drive); dsetpath(midi_path);
		if (getfile(pathname,filename,file_ext,MSVE_TITL)>0)
		{
			midi_drive= Dgetdrv(); Dgetpath(midi_path,midi_drive+1);
			savedatafile(filename,pathname,cnxname[which],
							 nbytes,heap[tempmem].start,
							 cnxoffset[which+1]-cnxoffset[which],
							 heap[cnxmem].start+cnxoffset[which]);
		}	/* end if ok from file selector */
	}	/* end if miditobuf successful */

	dealloc_mem(tempmem);
}

/* device to window .........................................................*/

devtowind(devNum,side)
int devNum,side;			/* devNum = -1 means midi-to-window */
{
	register int temp;
	register long nbytes;
	long miditobuf();
	int which;
	char file_ext[5];

	/* overwrite changed data? */
	if (change_flag[side ? rdatCHANGE : ldatCHANGE])
		if (form_alert(1,alertstr[side])==2) return;

	tempmem= -1;
	nbytes= miditobuf(devNum,side,&which);
	if (nbytes>0L)
	{
		make_tone();
		/* swap window and temporary buffer */
		temp= windatamem[side];
		windatamem[side]= tempmem;
		tempmem= temp;

		if (change_mem(windatamem[side],nbytes))
		{
			/* window CNX */
			nbytes= cnxoffset[which+1] - cnxoffset[which];
			change_mem(temp=windcnxmem[side],nbytes);
			copy_words(heap[cnxmem].start+cnxoffset[which],
							heap[temp].start,nbytes/2);
			change_flag[side ? rdatCHANGE : ldatCHANGE]=1;
			copy_bytes(cnxname[which],windcnxname[side],(long)(NCHPERCNX));

			/* window name */
			strcpy(windfile[side],defdataname);
			file_ext[0]='.';
			copy_bytes(&cnxname[which][NCHPERCNX-3],&file_ext[1],3L);
			file_ext[4]=0;
			if (!ext_ok(file_ext+1)) file_ext[1]=0;
			strcat(windfile[side],file_ext);
			draw_window(side);
		}
	}

	dealloc_mem(tempmem);
}

/* copy GenEdit data file from tempmem to window ............................*/
/* returns -1= error (alert inside here) else nblocks */

load_data(side,block,filename,file_offset)
int side;	/* 0= left, 1= right, -1= virtual window (disktomidi) */
int block;	/* which block to be loaded (>= 0), -1 to select one */
char filename[13];	/* changed if loading a block out of a multi-block */
long file_offset;
{
	int nblocks,type,cnxhand,datahand;
	GLOBRECORD *blockptr[MAXNBLOCKS+1];
	long ptr,dataptr,cnxptr,dataleng,cnxleng,length;
	FILEHEADER *header;
	RECHEADER *recptr;

	/* error if file version too high */
	ptr= heap[tempmem].start + file_offset;
	header= (FILEHEADER*)(ptr);
	if (header->version > dataheader.version )
	{
		form_alert(1,BADVERSION);
		return -1;
	}

	/* count blocks in this file */
	nblocks= scan_blocks(ptr,blockptr);
	if (!nblocks) return -1;	/* no blocks: can't happen? */

	/* choose one of blocks */
	if (block<0)
		block= select_block(WHICHBLOCK,nblocks,blockptr);
	if ( (block<0) || (block>=nblocks) ) return -1;
	ptr= (long)(blockptr[block]);

	/* find data and config in this block */
	recptr= (RECHEADER*)(ptr);
	dataleng= dataptr= 0L;
	cnxleng= cnxptr= 0L;
	type= recptr->type;
	while (type!=idEND)
	{
		length= recptr->length;
		if ( (type==idDATA) && !dataleng )
		{
			dataptr= ptr + sizeof(*recptr);
			dataleng= length;	/* might be odd */
		}
		if ( (type==idCNXSEGS) && !cnxleng )
		{
			cnxptr= ptr + sizeof(*recptr);
			cnxleng= length;
		}
		if (dataleng&&cnxleng) break;
		if (length&1) length++;
		ptr += (length + sizeof(*recptr) );
		recptr= (RECHEADER*)(ptr);
		type= recptr->type;
	}

	/* loading to midi: must have config and data */
	if (side<0)
	{
		if (!cnxleng)
		{
			form_alert(1,BADSENDCNX);
			return -1;
		}
		if (!dataleng)
		{
			form_alert(1,BADSENDDAT);
			return -1;
		}
	}

	/* optionally don't load parts */
	if (!windlodc&&(side>=0)) cnxptr=0L;
	if (!windlodd&&(side>=0)) dataptr=0L;

	/* memory block handle for each part */
	if (side<0)
	{
		cnxhand= tempcnxmem;
		datahand= tempdatamem;
	}
	else
	{
		cnxhand= windcnxmem[side];
		datahand= windatamem[side];
	}

	/* resize parts:  tempmem may move! */
	cnxptr -= heap[tempmem].start;
	dataptr -= heap[tempmem].start;
	if (windlodc||(side<0))
		if (!change_mem(cnxhand,cnxleng)) return -1;
	if (windlodd||(side<0))
		if (!change_mem(datahand,dataleng)) return -1;
	cnxptr += heap[tempmem].start;
	dataptr += heap[tempmem].start;
	scan_blocks(heap[tempmem].start+file_offset,blockptr);

	/* config name */
	if ( windlodc && (side>=0) )
		copy_bytes(blockptr[block]->cnxname,windcnxname[side],(long)(NCHPERCNX));

	/* config */
	if ( windlodc && cnxptr )
		copy_words(cnxptr,heap[cnxhand].start,cnxleng/2);

	/* data */
	if ( windlodd && dataptr )
	{
		length=dataleng;
		if (length&1) length++;
		copy_words(dataptr,heap[datahand].start,length/2);
		if (dataleng&1)
			*(char*)(heap[datahand].start+dataleng)= END_OF_DATA;
	}

	/* if loading out of a multi-block, change filename to block name */
	if (nblocks>1)
	{
		copy_bytes(blockptr[block]->comment,filename,12L);
		filename[12]=0;
	}

	return nblocks;
}	/* end load_data() */

/* find blocks in data file .................................................*/
/* returns # of blocks */

scan_blocks(ptr,blockptr)
register long ptr;	/* --> data file (disk format) */
long blockptr[];		/* output: pointers to blocks, last one --> end record */
{
	register int nblocks=0;
	RECHEADER *recptr;
	int type;
	long length;

	ptr += sizeof(dataheader);
	recptr= (RECHEADER*)(ptr);
	type= recptr->type;
	while (type!=idEND)
	{
		length= recptr->length;
		if (type==idGLOBDATA)
		{
			if (nblocks==MAXNBLOCKS)
			{
				form_alert(1,BADNBLOCKS);
				break;
			}
			blockptr[nblocks++]= ptr;
		}
		if (length&1) length++;
		ptr += (length + sizeof(*recptr) );
		recptr= (RECHEADER*)(ptr);
		type= recptr->type;
	}
	blockptr[nblocks]= ptr;

	return nblocks;
}	/* end scan_blocks() */

/* select block from data file ..............................................*/
/* returns block #, -1 = cancel */

select_block(title,nblocks,blockptr)
char *title;	/* dialog box title */
int nblocks;
GLOBRECORD *blockptr[];
{
	register char *ptr;
	char *blocklist[MAXNBLOCKS];
	register int i;
	register long j;
	char buf[NCHPERCNX+1];

	/* there's only one block, so choose it */
	if (nblocks==1) return 0;

	/* format and initialize list to be displayed in pop-up box */
	j= 8000/MAXNBLOCKS;
	ptr= (char*)(cnxscrsave);
	set_bytes(ptr,j*nblocks,0);

	/* build list */
	for (i=0; i<nblocks; i++,ptr+=j)
	{
		copy_bytes(blockptr[i]->comment,ptr,12L);
		pad_str(12,ptr,' ');
		strcat(ptr," | ");
		copy_bytes(blockptr[i]->cnxname,buf,(long)NCHPERCNX);
		buf[NCHPERCNX]=0;
		strcat(ptr,buf);
		blocklist[i]= ptr;
	}

	/* select from list */
	return pop_up(title,-1,nblocks,0L,0,blocklist) ;
}	/* end select_block() */

/* copy single-block GenPatch file from tempmem to window ...................*/
/* returns -1= error, 0= ok */

load_genp(side)
int side;	/* 0= left, 1= right, -1= virtual window (disktomidi) */
{
	register long *lptr;
	register long templong;
	int cnfleng,temp,cnxhand,datahand;
	long cnxleng,dataleng,convertcnf();

	templong= heap[tempmem].start;
	lptr= (long*)(templong);
	if (lptr[1])	/* can't load GenPatch multi-block file */
	{
		form_alert(1,BADGENPMLT);
		return -1;
	}
	cnfleng= *(int*)(lptr+2);

	/* length of data might not be even */
	dataleng= heap[tempmem].nbytes - 48 - cnfleng;
	if (dataleng&1) dataleng++;

	/* GenP data file has only one cnx segment: cnxTRAN, and it's never null */
	if (windlodc)
	{
		cnxleng= convertcnf(templong+48,templong+10,0L,cnfleng,0);
		if (cnxleng<0L) return -1;	/* err msg inside convertcnf() */
	}

	/* resize real or virtual window */
	if (side<0)
	{
		cnxhand= tempcnxmem;
		datahand= tempdatamem;
	}
	else
	{
		cnxhand= windcnxmem[side];
		datahand= windatamem[side];
	}

	if (windlodc)
		if (!change_mem(cnxhand,cnxleng+8)) return -1;
	if (!change_mem(datahand,dataleng)) return -1;
	templong= heap[tempmem].start;

	if (windlodc)
	{
		lptr= (long*)( heap[cnxhand].start );
		*lptr++= cnxTRAN;
		*lptr++= cnxleng;
		if (side>=0) copy_bytes(templong+11,windcnxname[side],(long)(NCHPERCNX));
		convertcnf(templong+48,templong+10,lptr,cnfleng,1);
	}
	copy_words(templong+48+cnfleng,heap[datahand].start,dataleng/2);

	return 0;
}	/* end load_genp() */

/* copy unknown file format from tempmem to window ..........................*/
/* returns -1= error, 0= ok */

load_nong(side,totlleng)
int side;			/* 0= left, 1= right (can't be virtual window) */
long totlleng;		/* file length */
{
	static long headleng,dataleng;
	long cnxleng;
	register char *ptr;
	register long *lptr;
	register long templong;
	char *headptr,*dataptr;
	int cnxhand,datahand;
	CONSTVAR cv1,cv2,cv3;

again:
	/* default lengths, prevent nonsense */
	dataleng= totlleng-headleng;
	if (dataleng<0) dataleng=0;
	if ( (headleng+dataleng) > totlleng ) headleng= totlleng-dataleng;

	/* encode into dialog box */
	headptr= ((TEDINFO*)(nongaddr[NONGHEAD].ob_spec))->te_ptext;
	dataptr= ((TEDINFO*)(nongaddr[NONGDATA].ob_spec))->te_ptext;
	ltoa(totlleng,nongaddr[NONGTOTL].ob_spec,6);
	ltoa(headleng,headptr,6);
	ltoa(dataleng,dataptr,6);

	if ( do_dial(nongaddr,NONGHEAD) == CANNONG ) return -1;

	/* option: define headleng and dataleng by finding $F0 and
		$F7 or end-of-file */
	if (nongaddr[NONGFIND].ob_state&SELECTED)
	{
		ptr=(char*)(heap[tempmem].start);
		for (headleng=0L; headleng<totlleng; headleng++)
			if ((ptr[headleng]&0xFF)==midiSOX) break;
		if (headleng==totlleng)
		{
			headleng=0;
			form_alert(1,BADNONG1);
			return -1;
		}
		for (dataleng=headleng; dataleng<totlleng; dataleng++)
			if ((ptr[dataleng]&0xFF)==midiEOX) break;
		/* data includes SOX and EOX */
		if (dataleng==totlleng) dataleng -= headleng;
	}
	else
	{
		headleng= atol(headptr);
		dataleng= atol(dataptr);
		if (!dataleng && (headleng<totlleng)) dataleng= totlleng-headleng;
		if ( (headleng+dataleng) > totlleng )
		{
			form_alert(1,BADNONG2);
			goto again;
		}
	}
	if (!dataleng)
	{
		form_alert(1,BADNONG3);
		goto again;
	}

	/* construct a simple configuration for this */
	ge_nfields= 4;
	ge_fieldtype[0]= FT_CMD0+GE_TRANDATA;	ge_fieldval[0]= GE_TRANDATA;
	ge_fieldtype[1]= FT_DEC;			ge_fieldval[1]= dataleng;
	ge_fieldtype[2]= FT_HEX;			ge_fieldval[2]= 0xF7;
	ge_fieldtype[3]= FT_DEC;			ge_fieldval[3]= 1;
	cnxleng= ge_line(GE_TRANDATA) ;	/* token put into ge_buf */

	/* optionally replace the current window configuration */
	if (windlodc)
	{
		cnxhand= windcnxmem[side];
		if (nongaddr[NONGFIND].ob_state&SELECTED)
		{
			if (!change_mem(cnxhand,8L+cnxleng)) return -1;
			lptr= (long*)( heap[cnxhand].start );
			*lptr++= cnxTRAN;
			*lptr++= cnxleng;
			copy_bytes(ge_buf,lptr,cnxleng);
			copy_bytes(NONGCNXNAME,windcnxname[side],(long)(NCHPERCNX));
		}
		else
		{
			change_mem(cnxhand,0L);
			initcnxname(-1,windcnxname[side]);
		}
	}

	datahand= windatamem[side];
	if (!change_mem(datahand,dataleng)) return -1;
	copy_bytes(heap[tempmem].start+headleng,heap[datahand].start,dataleng);
	if (dataleng&1)
		*(char*)( heap[datahand].start + dataleng )= END_OF_DATA;
	
	return 0;
}	/* end load_nong() */

/* save a single-block data file ............................................*/
/* returns 1= ok, 0= error */

savedatafile(file,path,cnxname,dataleng,data,cnxleng,cnx)
char *file,*path;
long cnxname;		/* --> NCHPERCNX characters */
long dataleng;		/* bytes in data (even) */
long data;			/* --> data */
long cnxleng;		/* bytes in cnx */
long cnx;			/* --> cnx */
{
	long addr[32],leng[32];	/* oversized */
	GLOBRECORD globrecord;
	RECHEADER datarecord,cnxrecord;
	long endrecord= idEND;
	register int i;

	/* build file -- */
	i=0;

	/* -- header */
	addr[i]= (long)(&dataheader);		leng[i++]= sizeof(dataheader);

	/* -- global record */
	set_bytes(&globrecord,(long)sizeof(globrecord),0);
	globrecord.type= idGLOBDATA;
	globrecord.length= sizeof(globrecord) - sizeof(datarecord);
	globrecord.patch= -1;
	strcpy(globrecord.comment,file);
	if (windsavc) copy_bytes(cnxname,globrecord.cnxname,(long)NCHPERCNX);
	addr[i]= (long)(&globrecord);		leng[i++]= sizeof(globrecord);

	/* -- data record */
	if (windsavd&&dataleng)
	{
		datarecord.type= idDATA;
		/* record length doesn't include pad */
		datarecord.length= *(char*)(data+dataleng-1)==END_OF_DATA ?
								dataleng-1 : dataleng ;
		addr[i]= (long)(&datarecord);		leng[i++]= sizeof(datarecord);
		addr[i]= data;							leng[i++]= dataleng;
	}

	/* -- cnx record */
	if (windsavc&&cnxleng)
	{
		cnxrecord.type= idCNXSEGS;
		cnxrecord.length= cnxleng;
		addr[i]= (long)(&cnxrecord);	leng[i++]= sizeof(cnxrecord);
		addr[i]= cnx;						leng[i++]= cnxleng;
	}

	/* -- end record */
	addr[i]= (long)(&endrecord);		leng[i++]= 4;

	return save_file(file,path,i,addr,leng);

}	/* end savedatafile() */

/* studio description stuff .................................................*/

/* initialize */
init_studio(devnum)
int devnum;		/* 0 - (NDEVICES-1), -1 means all */
{
	register int i;

	if (devnum<0)
	{
		if ( !change_flag[stuCHANGE] || (form_alert(1,CHNGESTU)==1) )
		{
			for (i=0; i<NDEVICES; i++) init_studio(i);
			studioHome=0;
			draw_studio(-1);
			change_flag[stuCHANGE]= 0;
		}
	}
	else
	{
		init_device(&studioDev[devnum]);
		studioLink[devnum].confignum= -1;
		strcpy(studioLink[devnum].extent,"");
		strcpy(studioLink[devnum].name,"");
	}
}

/* edit */
/* returns 1=ok, 0=cancel */
edit_studio(devnum)
int devnum;		/* 0 - (NDEVICES-1),
						NDEVICES left window, NDEVICES+1 right window */
{
	int done,mstate,edit_obj,exit_obj;
	DEV_STRUCT *dev, backupDev;
	CONFIG_LINK *link, backupLink;
	register int i;
	char *nameptr;
	TEXTEDFMT i_format,x_format,*format;
	int i_offset,x_offset,*offset;
	int kstate,key;
	long templong;
	char namebuf[80],tempbuf[4];
	char undostr[33],*str;
	static char midivalid[16+6+1+1]= {
		'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F',
		'a','b','c','d','e','f',
		'n',
		0
	};

	/* backup */
	if (devnum<NDEVICES)
	{
		dev= &studioDev[devnum];
		link= &studioLink[devnum];
		backupLink= *link;
	}
	else
		dev= &wind_device[devnum-NDEVICES];
	backupDev= *dev;

	/* encode into dialog box */
	if (devnum<NDEVICES)
	{
		strcpy(namebuf,DEV_MSG);
		itoa(devnum+1,tempbuf,2);
		strcat(namebuf,tempbuf);
		strcat(namebuf,":                ");
	}
	else
		strcpy(namebuf, devnum==NDEVICES ? DEVLEFTMSG : DEVRGHTMSG);
	((TEDINFO*)(stuaddr[STUNUMB].ob_spec))->te_ptext= namebuf;
	nameptr= ((TEDINFO*)(stuaddr[STUNAME].ob_spec))->te_ptext;
	if (devnum<NDEVICES)
	{
		strcpy(nameptr, link->name);
		stuaddr[STUNAME].ob_flags &= ~HIDETREE;
	}
	else
		stuaddr[STUNAME].ob_flags |= HIDETREE;
	strcpy(stuaddr[STUCHAN].ob_spec,chanchar[dev->midichan+1]);
	ena_obj(midiplexer,stuaddr,STUIPORT);
	ena_obj(midiplexer,stuaddr,STUOPORT);
	stuaddr[STUIPORT].ob_spec[0]= 'A' + (midiplexer&1)*dev->in_port;
	stuaddr[STUOPORT].ob_spec[0]= 'A' + (midiplexer&1)*dev->out_port;
	for (i=0; i<6; i++)
		if (dev->speed == speedtable[i] ) break;
	set_rbutton(stuaddr,STUSPEED,6,i);
	for (i=0; i<4; i++)
		sel_obj(BITTEST(i,dev->filter),stuaddr,STUFILT+i);
	if (devnum<NDEVICES)
	{
		stu_cfgname(link->confignum);
		stuaddr[STUCONFG].ob_flags &= ~HIDETREE;
		stuaddr[STUCONF2].ob_flags &= ~HIDETREE;
	}
	else
	{
		stuaddr[STUCONFG].ob_flags |= HIDETREE;
		stuaddr[STUCONF2].ob_flags |= HIDETREE;
	}

	putdial(stuaddr,-1,0);

	/* position and display init string */
	i_format.spacing= 2;	/* "XX XX XX" format */
	i_format.valid= midivalid;
	i_format.fillchar= '_';
	i_format.spacechar= ' ';
	i_format.bell=1;
	objc_offset(stuaddr,STUISTRG,&i_format.x,&i_format.y);
	i_format.x /= charw;
	i_format.w= stuaddr[STUISTRG].ob_width / charw ;
	text_edit(-1,0,dev->initstring,32,i_offset=0,&i_format);

	/* position and display exit string */
	x_format.spacing= 2;	/* "XX XX XX" format */
	x_format.valid= midivalid;
	x_format.fillchar= '_';
	x_format.spacechar= ' ';
	x_format.bell=1;
	objc_offset(stuaddr,STUXSTRG,&x_format.x,&x_format.y);
	x_format.x /= charw;
	x_format.w= stuaddr[STUXSTRG].ob_width / charw ;
	text_edit(-1,0,dev->exitstring,32,x_offset=0,&x_format);

	done=0;
	edit_obj= devnum<NDEVICES ? STUNAME : -1 ;
	do
	{
		exit_obj=my_form_do(stuaddr,&edit_obj,&mstate,0,&dummy);
		kstate= Kbshift(-1)&0x0F;
		switch(exit_obj)
		{
			case CANSTU:
			*dev= backupDev;
			if (devnum<NDEVICES) *link= backupLink;
			case OKSTU:
			done=1;
			break;

			case STUCHAN:
			i= dev->midichan + mstate;
			if (i<(-1)) i=15;
			if (i>15) i= -1;
			dev->midichan= i;
			strcpy(stuaddr[exit_obj].ob_spec,chanchar[dev->midichan+1]);
			draw_object(stuaddr,exit_obj);
			break;

			case STUIPORT:
			i= dev->in_port + mstate;
			if (i<0) i= 1;
			if (i>1) i= 0;
			dev->in_port= i;
			stuaddr[exit_obj].ob_spec[0]= 'A' + dev->in_port;
			draw_object(stuaddr,exit_obj);
			break;

			case STUITEST:
			send_pmidi(dev->initstring);
			break;

			case STUXTEST:
			send_pmidi(dev->exitstring);
			break;

			case STUOPORT:
			i= dev->out_port + mstate;
			if (i<0) i= 3;
			if (i>3) i= 0;
			dev->out_port= i;
			stuaddr[exit_obj].ob_spec[0]= 'A' + dev->out_port;
			draw_object(stuaddr,exit_obj);
			break;

			case STUISTRG:
			case STUXSTRG:
			str= exit_obj==STUISTRG ? dev->initstring : dev->exitstring ;
			offset= exit_obj==STUISTRG ? &i_offset : &x_offset ;
			format= exit_obj==STUISTRG ? &i_format : &x_format ;
			text_edit(0,0, str, 32, *offset, format);
			copy_bytes(str,undostr,33L);
			while (!done)
			{
				templong= Crawcin();
				kstate= Kbshift(-1)&0x0F;
				switch (key=(templong>>16))
				{
					case SCAN_UNDO:
					copy_bytes(undostr,str,33L);
					*offset=0;
					text_edit(0,0,str,32,*offset,format);
					break;

					case SCAN_CR:
					case SCAN_ENTER:
					done=1;
					break;
					
					default:
					key= templong | (key<<8) ;
					*offset= text_edit(key,kstate,str,32,*offset,format);
				}	/* end switch (key) */
			}
			text_edit(-1,0,str,32,*offset,format);
			done=0;
			break;

			case STUCONFG:
			if (devnum>=NDEVICES) break;
			if (kstate==K_ALT) /* initialize config # */
				i= -1;
			else
			{
				putdial(0L,0,exit_obj);
				i= choose_cnx(link->confignum);
				putdial(stuaddr,-1,0);
				text_edit(-1,0,dev->initstring,32,i_offset,&i_format);
				text_edit(-1,0,dev->exitstring,32,x_offset,&x_format);
				if (i<0) break; /* cancelled */
			}
			link->confignum=i;
			stu_cfgname(link->confignum);
			if (i<0)
				strcpy(link->extent,"");
			else
			{
				copy_bytes(&cnxname[i][NCHPERCNX-3],link->extent,3L);
				/* inherit config name to device name */
				if (!nameptr[0])
				{
					copy_bytes(&cnxname[i][0], nameptr, 15L);
					draw_object(stuaddr,STUNAME);
				}
			}
			draw_object(stuaddr,exit_obj);
			break;

		}	/* end switch (exit_obj) */
		waitmouse();	/* none of these auto-repeat */
	}
	while (!done);
	putdial(0L,0,exit_obj);
	if (exit_obj==CANSTU) return 0;

	/* decode out of dialog box */
	if (devnum<NDEVICES)
		strcpy( link->name, nameptr );
	dev->speed= speedtable[ whichbutton(stuaddr,STUSPEED,6) ];
	dev->filter= 0;
	for (i=0; i<4; i++)
		if (is_obj_sel(stuaddr,STUFILT+i))
			BITSET(i,dev->filter);

	/* anything changed? */
	if (comp_bytes(&backupDev,dev,(long)sizeof(backupDev))) return 1;
	if (devnum<NDEVICES)
		if (comp_bytes(&backupLink,link,(long)sizeof(backupLink))) return 1;
	return 0;
}	/* end edit_studio() */

/* encode config name */
stu_cfgname(i)
int i;
{
	char *name;

	if (i<0)
		name= "--------------------";
	else
		name= cnxname[i];
	copy_bytes(name,stuaddr[STUCONFG].ob_spec,(long)NCHPERCNX);
}

/* load */
load_studio()
{
	char filename[13],pathname[80];
	int saveMP;

	/* reconsider */
	if ( change_flag[stuCHANGE] && (form_alert(1,CHNGESTU)!=1) ) return;

	if (midiplexer) saveMP=MPoff();

	filename[0]=0;
	Dsetdrv(orig_drive); dsetpath(orig_path);
	if (getfile(pathname,filename,STU_EXT,STULDTITL)>0)
	{
		switch ( load_stu(pathname) )
		{
			case 0:
			draw_studio(-1);
			change_flag[stuCHANGE]= 0;
			break;

			case 1: big_alert(1,BADREAD1,filename,BADREAD2); break;
			case 2: big_alert(1,BADOPEN1,filename,BADOPEN2);
		}
	}
	if (midiplexer&&saveMP) MPon();
}

load_stu(pathname) /* returns 1= can't read, 2= can't open, 0= ok */
char *pathname;
{
	register int i,filehand;
	long templong;
	FILEHEADER header;
	int n;
	int error=1;
	DEV_STRUCT *devptr, dummyDev;
	CONFIG_LINK *linkptr,dummyLink;

	/* open file */
	filehand= Fopen(pathname,0);
	if (filehand<0) return 2;

	/* read header */
	templong= sizeof(FILEHEADER);
	if (Fread(filehand,templong,&header) != templong) goto exit;

	/* validate header */
	if ( (header.magic!=stu_header.magic) ||
		  (header.version > stu_header.version) ) goto exit;

	/* how many devices in this file? */
	templong= sizeof(n);
	if (Fread(filehand,templong,&n) != templong) goto exit;

	/* validate # of devices */
	if (n<=0) goto exit;

	/* read devices */
	for (i=0; i<n; i++)
	{
		templong= sizeof(DEV_STRUCT);
		devptr= (i<NDEVICES) ? &studioDev[i] : &dummyDev ;
		if (Fread(filehand,templong,devptr) != templong) goto exit;
	}

	/* read links */
	for (i=0; i<n; i++)
	{
		templong= sizeof(CONFIG_LINK);
		linkptr= (i<NDEVICES) ? &studioLink[i] : &dummyLink ;
		if (Fread(filehand,templong,linkptr) != templong) goto exit;
	}

	error=0;
exit:
	Fclose(filehand);
	return error;
}

/* save */
save_studio()
{
	char filename[13],pathname[80];
	char *filestart[4];
	long fileleng[4];
	int n,saveMP;

	if (midiplexer) saveMP=MPoff();

	strcpy(filename,STUFILE1);
	Dsetdrv(orig_drive); dsetpath(orig_path);
	if (getfile(pathname,filename,STU_EXT,STUSVTITL)>0)
	{
		filestart[0]= (char*)(&stu_header);
		fileleng[0]= sizeof(stu_header);
		n= NDEVICES;
		filestart[1]= (char*)(&n);
		fileleng[1]= sizeof(n);
		filestart[2]= (char*)(&studioDev[0]);
		fileleng[2]= n * sizeof(DEV_STRUCT);
		filestart[3]= (char*)(&studioLink[0]);
		fileleng[3]= n * sizeof(CONFIG_LINK);
		if (save_file(filename,pathname,4,&filestart,&fileleng))
			change_flag[stuCHANGE]= 0;
	}
	if (midiplexer&&saveMP) MPon();
}

/* move this to disk.c and use throughout !!! */
char *get_extent(filename)
char *filename;
{
	char *ext;
	register int i;
	int ch;

	ext= filename;
	for (i=0; i<9; i++)
	{
		ch= ext[i];
		if ((ch==0)||(ch=='.')) break;
	}
	if (ch=='.')
		ext+=(i+1);
	else
		ext= (char*)0;
	return ext;
}

/* EOF */
