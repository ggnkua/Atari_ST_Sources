#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <fiodef.h>
#include <atarierr.h>
#include <tos.h>

#define RMAGIC 'RI10'

typedef struct
{
	long	magic; 
	long	width;			/* Pixels */
	long	line_width;	/* Pixels, filled to full word */
	long	height;
	int		bits;		/* 1= S/W, 8=Grey, 16=8 Bit mit CMY-Pal, 24=TC */
}RAW_HEAD;

void cdecl	mod_init(void);	/* Initialisierung des Moduls */
int cdecl		identify(FILE_DSCR *fd);
int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd);
int cdecl		save_file(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options);

int c_pal[256][3];

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
	'BRAW',
	
	/* name */
	"Raw-Output",

	/* Exportformate */
	SUP1|SUP8G|SUP8C|SUP24RGB,
	
	/* Anzahl der Kompressionsverfahren */
	0,
	/* Namen */
	NULL,
	
	/* Anzahl der Optionen */
	0,
	/* Optionen */
	NULL,
	
		
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
	int rec;
	RAW_HEAD	*rh=(RAW_HEAD*)(fd->buf256);
	
	if(rh->magic != RMAGIC)
		return(UNKNOWN);

	rec=REL_REC;
	if((rh->bits==1)||(rh->bits==8)||(rh->bits==16)||(rh->bits==24))
		rec|=CAN_LOAD;
		
	strcpy(dscr,"Raw Image-Data, ");
	switch(rh->bits)
	{
		case 1: 	/* S/W */
			strcat(dscr, " Schwarz/Weiž|");
		break;
		case 8:	/* Grey */
			strcat(dscr, " Graustufen|");
		break;
		case 16: /* Pal */
			strcat(dscr, " 256 Farben|");
		break;
		case 24: /* TrueColor */
			strcat(dscr, " True Color|");
		break;
		default:
			strcat(dscr, " ");
			itoa(rh->bits, &(dscr[strlen(dscr)]), 10);
			strcat(dscr, "|");
		break;
	}
	strcat(dscr, "Gr”že: ");
	ltoa(rh->width, &(dscr[strlen(dscr)]), 10);
	strcat(dscr, " x ");
	ltoa(rh->height, &(dscr[strlen(dscr)]), 10);
	strcat(dscr, " Pixel");
	
	fd->descr=dscr;
	fd->width=(int)(rh->width);
	fd->height=(int)(rh->height);
	
	return(rec);
}

/*
 ***************
 LOAD
 ***************
*/

int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd)
{
	uchar	*lbuf;
	long	fsize, read;
	int		fh=fd->fh;
	RAW_HEAD rh;
	BLOCK_DSCR bd;

	Fseek(0, fh, 0);
	read=Fread(fh, sizeof(RAW_HEAD), &rh);	
	fsize=rh.line_width*rh.height;
	if(rh.bits==16)
		fsize*=8;
	else
		fsize*=(long)(rh.bits);
	fsize/=8;
	lbuf=_GF_ malloc(fsize);
	if(lbuf==NULL) return(ENSMEM);
	
	if(rh.bits==16)
	{/* Palette laden */
		read=Fread(fh, 3*256*sizeof(int), &(c_pal[0][0]));
		if(read < 0)
		{
			_GF_ free(lbuf);
			return((int)read);
		}
	}
	
	read=Fread(fh, fsize, lbuf);
	if(read < 0)
	{
		_GF_ free(lbuf);
		return((int)read);
	}

	switch(rh.bits)
	{
		case 1:
			bd.format=B1;
			bd.subcode=B1_WB;
		break;
		case 8:
			bd.format=B8;
			bd.subcode=B8_GWBPP;
		break;
		case 16:
			bd.format=B8;
			bd.subcode=B8_CPP;
			_GF_ set_col_pal(CMY_8, 256, &(c_pal[0][0]));
		break;
		case 24:
			bd.format=B24;
			bd.subcode=B24_RGBPP;
		break;
	}

	bd.height=bd.h=(int)(rh.height);
	bd.width=bd.w=(int)(rh.width);
	bd.lw=(int)(rh.line_width);
	bd.data=lbuf;
	bd.x=bd.y=0;
	_GF_ store_block(&bd, dd);
	_GF_ free(lbuf);
	return(0);
}

/*
 ***************
 SAVE
 ***************
*/ 

int	cdecl	save_file(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options)
{
	RAW_HEAD		rh;
	uchar				*buf;
	BLOCK_DSCR	bd;
	long				size, ww;
	int					*pal;
	
	/* Speicher fr Buffer */
	ww=((sd->width+15)/16)*16;
	switch(ex_format)
	{
		case SUP1:
			size=((ww * (long)(sd->height)))/8;
			rh.bits=1;
		break;
		case SUP8G:
			size=ww * (long)(sd->height);
			rh.bits=8;
		break;
		case SUP8C:
			size=ww * (long)(sd->height);
			rh.bits=16;
			pal=_GF_ get_col_pal(CMY_8, 256);
		break;
		case SUP24RGB:
			size=ww * (long)(sd->height) * 3;
			rh.bits=24;
		break;
		default:
			return(-1);
	}
	buf=_GF_ calloc(size, 1);
	if(buf==NULL) return(ENSMEM);
	/* Header initialisieren */
	rh.magic=RMAGIC;
	rh.height=sd->height;
	rh.width=sd->width;
	rh.line_width=ww;
	Fwrite(fd->fh, sizeof(RAW_HEAD), &rh);
	if(rh.bits==16) Fwrite(fd->fh, 256*3*sizeof(int), pal);
	/* Daten von Grape holen */
	/* Dazu meinen Block-Descriptor initialisieren */
	switch(ex_format)
	{
		case SUP1:	bd.format=B1; bd.subcode=B1_WB; break;
		case SUP8G: bd.format=B8; bd.subcode=B8_GWBPP; break;
		case SUP8C: bd.format=B8; bd.subcode=B8_CPP; break;
		case SUP24RGB:	bd.format=B24; bd.subcode=B24_RGBPP; break;
	}
	bd.height=bd.h=(int)(rh.height);
	bd.width=bd.w=(int)(rh.width);
	bd.lw=(int)(rh.line_width);
	bd.data=buf;
	bd.x=bd.y=0;
	/* holen */
	_GF_ get_block(&bd, sd);
	
	/* Schreiben */
	size=Fwrite(fd->fh, size, buf);
	
	/* Fertig */
	_GF_ free(buf);
	
	if(size < 0) return((int)size);
	return(0);
}
