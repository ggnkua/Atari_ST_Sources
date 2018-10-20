#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <fiodef.h>
#include <atarierr.h>
#include <tos.h>
#include <setjmp.h>
#include "imgcodec.h"

extern void mfdb_in_proc(MFDB *mfdb, IBUFPUB *image);
extern IBUFPUB *mfdb_output_init(IMG_HEADER *input_header, MFDB *mfdb,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));

/* Gr”že des Output-Zeilenbuffers */
#define BUFFLINE	1024

typedef struct { 
    unsigned int version; 
    unsigned int headlen; 
    unsigned int nplanes; 
    unsigned int patlen; 
    unsigned int pixelw; 
    unsigned int pixelh; 
    unsigned int linew; 
    unsigned int lines;
    /* XIMG */
    long				 magic;						/* 'XIMG' */
    unsigned int colmode;					/* 0=RGB, 1=CMY, 2=Pantone */
    unsigned int colpal[256][3];	/* Color-Palette in Promille */
} IMG; 

typedef struct { 
	FBUFPUB	pub;
	int			filehandle;
	long		line_len;
	void		*buf;
}MFBUF;

void cdecl	mod_init(void);	/* Initialisierung des Moduls */
int cdecl		identify(FILE_DSCR *fd);
int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd);
int cdecl		save_file(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options);

uchar *img_decode(char *get, long dst_size);

static jmp_buf jmp_buffer;

char *comp_names[]={"Level 1", "Level 2", "Level 3"};
char *option[]={"2 Byte Patrun"};
OPTION opts[]=
{
	1,option
};

static MODULE_FIOFN mod_fn=
{
	/* Meine Funktionen */	
	mod_init,
	identify,
	load_file,
	save_file
};

static FIOMODBLK fblock=
{
	"GRAPEFIOMOD",
	'0101',
	
	/* id */
	'IMGE',
	
	/* name */
	"GEM-Image",

	/* Exportformate */
	SUP1,
	
	/* Anzahl der Kompressionsverfahren */
	3,
	/* Namen */
	comp_names,
	
	/* Anzahl der Optionen */
	1,
	/* Optionen */
	opts,
	
		
	/* Meine Funktionen */	
	&mod_fn,
	
	/* Grape-Functions */
	NULL
};

void main(void)
{
	appl_init();
	if(fblock.magic[0])
		form_alert(1,"[3][Ich bin ein Grape-Modul!][Abbruch]");
	appl_exit();
}

void cdecl mod_init(void)
{
}
int	cdecl	identify(FILE_DSCR *fd)
{
	static char dscr[120];
	int rec, cant_load=0;
	IMG	*imgh=(IMG*)(fd->buf256);
	
	if(stricmp(fd->ext, ".IMG"))
		return(UNKNOWN);
	
	if(imgh->nplanes==2)
		cant_load=1;
		
	rec=EXT_REC;
	if((fd->buf256[0]==0) && (fd->buf256[1]==1) && 
			((imgh->magic=='XIMG')||(imgh->headlen==8)))
	rec=EDT_REC;
	if(imgh->magic=='XIMG')
	{
		rec=REL_REC;
		strcpy(dscr,"GEM XImage File, ");
		itoa(imgh->nplanes, &(dscr[strlen(dscr)]), 10);
		switch(imgh->colmode)
		{
			case 0:	/* RGB */
				strcat(dscr, " Bit mit RGB-Palette|");
			break;
			case 1:	/* CMY */
				strcat(dscr, " Bit mit CMY-Palette|");
			break;
			case 2: /* Pantone */
				strcat(dscr, " Bit mit Pantone-Palette|");
				cant_load=1;
			break;
		}
	}
	else
	{
		strcpy(dscr,"GEM Image File, ");
		itoa(imgh->nplanes, &(dscr[strlen(dscr)]), 10);
		strcat(dscr, " Bit Farbtiefe|");
	}
	strcat(dscr, "Gr”že: ");
	itoa(imgh->linew, &(dscr[strlen(dscr)]), 10);
	strcat(dscr, " x ");
	itoa(imgh->lines, &(dscr[strlen(dscr)]), 10);
	strcat(dscr, " Pixel");
	
	strcat(dscr, "|Kodierung: Level ");
	itoa(imgh->version, &(dscr[strlen(dscr)]), 10);
	if(imgh->version > 3) cant_load=1;
	
	fd->descr=dscr;
	fd->width=imgh->linew;
	fd->height=imgh->lines;
	
	if((!cant_load)&&((imgh->nplanes==1)||(imgh->nplanes==4)||(imgh->nplanes==8)))
		rec|=CAN_LOAD;
	return(rec);
}


void image_exit(void)
{
  longjmp(jmp_buffer, 2);
}

/*
 ***************
 LOAD
 ***************
*/
void read_line(FBUFPUB *fp)
{
	/* Sollte nie aufgerufen werden, weil die Datei komplett in
			den Puffer gelesen wurde. Deshalb Rcksprung zur obersten 
			Routine.
	*/
  longjmp(jmp_buffer, 1);
}

int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd)
{
	uchar	*lbuf, *decbuf;
	long	fsize, read;
	int		setpal_mode, fh=fd->fh;
	IMG		*imgh;
	BLOCK_DSCR bd;
	
	fsize=fd->flen;
	lbuf=_GF_ malloc(fsize);
	if(lbuf==NULL) return(ENSMEM);
	read=Fread(fh, fsize, lbuf);
	if(read < 0)
	{
		_GF_ free(lbuf);
		return((int)read);
	}
	decbuf=img_decode((char*)lbuf, fd->flen);
	if(decbuf==NULL)
	{
		_GF_ free(lbuf);
		return(ENSMEM);
	}
	imgh=(IMG*)lbuf;

	if(imgh->magic=='XIMG')
	{/* Farbpalette setzen */
		if(imgh->colmode==0) setpal_mode=RGB_PM;
		else	setpal_mode=CMY_PM;
		_GF_ set_col_pal(setpal_mode, 1 << imgh->nplanes, (int*)&((imgh->colpal)[0][0]));
	}
	
	switch(imgh->nplanes)
	{
		case 1:
			bd.format=B1;
			bd.subcode=B1_WB;
		break;
		case 4:
			bd.format=B4;
			bd.subcode=B4_IP_FL;
		break;
		case 8:
			bd.format=B8;
			bd.subcode=B8_CIP_FL;
		break;
	}
	bd.lw=((imgh->linew + 15) >> 4) << 4;

	bd.height=bd.h=imgh->lines;
	bd.width=bd.w=imgh->linew;
	bd.data=decbuf;
	bd.x=bd.y=0;
	_GF_ free(lbuf);
	_GF_ store_block(&bd, dd);
	_GF_ free(decbuf);
	return(0);
}

uchar *img_decode(char *file, long file_size) 
{ 
  IMG         *head=(IMG*)file; 
  long        lsz; 
	MFDB				mfdb;
	IBUFPUB			*ibuf;
	FBUFPUB			fbuf;
 	/* Buffer fr Einlesen holen */ 
  lsz = (long)((head->linew+15)>>4) * sizeof(int); 
  lsz *=(long)head->nplanes; 
  lsz *=(long)head->lines; 
  lsz *=(long)head->nplanes; 
 	mfdb.fd_addr = _GF_ calloc(lsz,1); 
  if (mfdb.fd_addr==NULL)  return(NULL); 
 	/* MFDB initialisieren */
 	mfdb.fd_w=head->linew;
 	mfdb.fd_h=head->lines;
 	mfdb.fd_wdwidth=((head->linew+15)>>4);
 	mfdb.fd_stand=1;
 	mfdb.fd_nplanes=head->nplanes;
 	mfdb.fd_r1=mfdb.fd_r2=mfdb.fd_r3=0;
 	
 	/* IBUFPUB holen */
 	ibuf=mfdb_output_init((IMG_HEADER*)head, &mfdb, Malloc, image_exit);
 	if(ibuf==NULL)
 	{
 		_GF_ free(mfdb.fd_addr);
 		return(NULL);
 	}
 	
 	/* Fbuf initialisieren */
 	fbuf.pbuf=file+2*head->headlen;
 	fbuf.bytes_left=file_size-2*(head->headlen);
	fbuf.data_func=read_line;
	/* Bild dekodieren */
	if (setjmp(jmp_buffer) == 0)
		level_3_decode(&fbuf, ibuf);
	
	Mfree(ibuf); 
  return((uchar*)(mfdb.fd_addr)); 
} 

/*
 ***************
 SAVE
 ***************
*/ 

void write_line(MFBUF *fp)
{
	long count;
	
	count=fp->line_len-fp->pub.bytes_left;
	if(count)
	{
		Fwrite(fp->filehandle, count,fp->buf);
		fp->pub.pbuf=fp->buf;
		fp->pub.bytes_left=fp->line_len;
	}
}

int	cdecl	save_file(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options)
{

	IBUFPUB			*image;
	MFBUF				out;
	IMG_HEADER	ihead;
	MFDB				mfdb;
	BLOCK_DSCR	bd;
	long				size, ww;
	
	++cmp_format;
	++options[0];
	
	if(ex_format==SUP8G)
		ex_format=SUP8C;
	/* Speicher fr meinen MFDB-Buffer */
	ww=((sd->width/16)+1)*16;
	size=((ww * (long)(sd->height))*(long)ex_format)/8;
	mfdb.fd_addr=_GF_ calloc(size, 1);
	if(mfdb.fd_addr==NULL) return(ENSMEM);
	/* MFDB initialisieren */
	mfdb.fd_w=sd->width;
	mfdb.fd_h=sd->height;
	mfdb.fd_wdwidth=(int)ww/16;
	mfdb.fd_stand=1;
	mfdb.fd_nplanes=ex_format;
	mfdb.fd_r1=mfdb.fd_r2=mfdb.fd_r3=0;
	/* IMG-Header initialisieren */
	ihead.version=cmp_format;
	ihead.headlen=sizeof(IMG_HEADER)>>1;
	ihead.planes=ex_format;
	ihead.pat_run=options[0];
	ihead.pix_width=0x174;
	ihead.pix_height=0x174;
	ihead.sl_width=sd->width;
	ihead.sl_height=sd->height;
	Fwrite(fd->fh, sizeof(IMG_HEADER), &ihead);
	/* Filebuff-struct initialisieren */
	out.pub.pbuf=_GF_ malloc(BUFFLINE);
	if(out.pub.pbuf==NULL)
	{
		_GF_ free(mfdb.fd_addr);
		return(ENSMEM);
	}
	out.pub.bytes_left=BUFFLINE;
	out.pub.data_func=(void (*)(FBUFPUB *fp))write_line;
	out.filehandle=fd->fh;
	out.line_len=BUFFLINE;
	out.buf=out.pub.pbuf;
	/* Encoder initialisieren */
	image=encode_init(&ihead, (FBUFPUB*)&out, Malloc, image_exit, cmp_format, options[0]);
	if(image==NULL)
	{
		_GF_ free(mfdb.fd_addr);
		return(ENSMEM);
	}

	/* Daten von Grape holen */
	/* Dazu meinen Block-Descriptor initialisieren */
	switch(ex_format)
	{
		case SUP1:	bd.format=B1; bd.subcode=B1_WB; break;
		case SUP4:	bd.format=B4; bd.subcode=B4_IP_FL; break;
		case SUP8C: bd.format=B8; bd.subcode=B8_CIP_FL; break;
	}
	bd.height=bd.h=mfdb.fd_h;
	bd.width=bd.w=mfdb.fd_w;
	bd.lw=mfdb.fd_wdwidth*16;
	bd.data=mfdb.fd_addr;
	bd.x=bd.y=0;
	/* holen */
	_GF_ get_block(&bd, sd);
	
	/* Verarbeiten */
	if (setjmp(jmp_buffer) == 0)
		mfdb_in_proc(&mfdb, image);
	/* Flush buffer */
	write_line(&out);

	Mfree(image);
	_GF_ free(mfdb.fd_addr);
	return(0);
}
