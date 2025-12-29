#include <tos.h>
#include <linea.h>
#include <vdi.h>		/* nur fÅr MFDB!! */
#include <stdlib.h>

#include "sdump.h"

#ifndef GEMDUMP
	extern SCREEN_DUMP dump;
#	define inst		dump.inst
#	define scr_nr	dump.nr
#else
	extern INST inst;
	extern int scr_nr;
#endif

/*
	fehlerbehandlung
*/
int xerr;

int h_error(long err,long z)
{
	if ( err<0L || ((z!=0L)&&(err!=z) ) ) {
		xerr=(int)err;
		if ( err>0l )
			xerr=-1000;
		return 1;
	}
	return 0;
}

/*
	gepufferte schreibroutinen
*/
int f_id,z;		/* f_id: file-id, z: schreibpostiotion im puffer */
char *w_buf;	/* zeigt auf puffer der grîûe BUF_SIZE */
static void init_write(char *puffer)
{
	w_buf=puffer;
	z=0;
}

static int write_byte(char byte)		/* schreibe ein byte gepuffert */
{
	w_buf[z++]=byte;
	if ( z==BUF_SIZE ) {
		if ( h_error(Fwrite(f_id,BUF_SIZE,w_buf),BUF_SIZE) )
			{ Fclose(f_id); return 1; }
		z=0;
	}
	return 0;
}

										/* schreibe block gepuffert */
static int write_block(long len,char *block)
{
long i;
	for ( i=0; i<len; i++,block++ )
		if ( write_byte(*block) )
			return 1;
	return 0;
}

										/* schreibe restpuffer & schlieûe datei */
static int close_write(void)
{
	if ( z!=0 ) {
		if ( h_error(Fwrite(f_id,(long)z,w_buf),(long)z) )
			{ Fclose(f_id); return 1; }
		z=0;
	}
	return 0;
}

										/* schreibe ungepackte daten (fÅr img) */
static int write_upk(int len,char *unpacked)
{			
	if ( write_byte(0x80) || write_byte(len) )
		return 1;
	return write_block(len,unpacked);
}

/*
	initialisiere strukturen fÅr xIMG-Datei
*/
static void init_img(SAVE_IMG *img,IMG_HEAD *head,MFDB *mfdb,int w,int h,char *line,int llen)
{
	img->line=line;								/* zeilenbuffer */
	img->pic_line=img->pic_buf=mfdb->fd_addr;	/* bildbuffer */
	img->flag=img->line_nr=0;					/* laufvariable */

	img->bwid=w/8;								/* ausmaûe */
	if ( w%8 )
		img->bwid++;
	if ( img->bwid>llen/mfdb->fd_nplanes )
		img->bwid=llen/mfdb->fd_nplanes;
	img->hght=h;

	img->pic_bwid=mfdb->fd_wdwidth*2;			/* breite der bitmap */
	if ( !mfdb->fd_stand )
		img->pic_bwid*=mfdb->fd_nplanes;

	img->plane_size=(long)mfdb->fd_wdwidth*2l*mfdb->fd_h;

	img->standard=mfdb->fd_stand;

	head->ver_num=0;							/* dateiheader */
	head->head_len=8;
	head->pat_len=2;

	head->pix_wid=0x174;
	head->pix_hght=0x174;
	img->planes=mfdb->fd_nplanes;

	head->plane_num=mfdb->fd_nplanes;
	head->pix_num=w;
	if ( w>llen/mfdb->fd_nplanes*8 )
		head->pix_num=llen/mfdb->fd_nplanes*8;
	head->scan_num=h;
}

/*
	lese/vergleiche zeile
*/
static int get_line(SAVE_IMG *img,int mode)
{
char *h1,*h2;
int cnt,i,ii;

	if ( img->flag==-1 || (img->flag && mode) )
		return 0;

	h1=img->line;

	if ( !img->standard ) {				/* st-screen format */
	  int offset;
		if ( mode ) {	/* nur testen */
			for ( i=0,offset=0; i<img->planes; i++,offset+=2 ) {
				for ( cnt=0,h2=img->pic_line+offset; cnt<img->bwid; h2+=2*(img->planes-1) )
					for ( ii=0; ii<2 && cnt<img->bwid; ii++,cnt++ )
						if ( *h1++!=*h2++ )
							return 0;
			}
		}
		else {			/* kopieren */
			for ( i=0,offset=0; i<img->planes; i++,offset+=2 ) {
				for ( cnt=0,h2=img->pic_line+offset; cnt<img->bwid; h2+=2*(img->planes-1) )
					for ( ii=0; ii<2 && cnt<img->bwid; ii++,cnt++ )
						*h1++=*h2++;
			}
			img->flag=0;
		}
	}
	else {								/* standard format */
	  long offset;
		if ( mode ) {	/* nur testen */
			for ( i=0,offset=0l; i<img->planes; i++,offset+=img->plane_size ) {
				for ( cnt=0,h2=img->pic_line+offset; cnt<img->bwid; cnt++ )
					if ( *h1++!=*h2++ )
					return 0;
			}
		}
		else {			/* kopieren */
			for ( i=0,offset=0l; i<img->planes; i++,offset+=img->plane_size ) {
				for ( cnt=0,h2=img->pic_line+offset; cnt<img->bwid; cnt++ )
					*h1++=*h2++;
			}
			img->flag=0;
		}
	}

	img->pic_line+=img->pic_bwid;
	img->line_nr++;
	if ( img->line_nr==img->hght ) {	/* ende erreicht */
		img->flag=-1;
	}
	return 1;
}

/*
	schreibe block (0,0,wid,hght) aus 'buffer' in xIMG-Datei 'name'
	'col' zeigt auf farbtabelle, 'xflag' gibt an ob IMG (xflag=0) oder xIMG (xflag!=0)
	geschrieben werden soll (falls xflag==0 ist col redundand und wird nicht beachtet)

	falls GEMDUMP nicht (mit -DGEMDUMP) in den compileroptionen gesetzt ist
	wird bei gesetztem xflag und 'col==0l' statt der farbtabelle in col
	die farben via xbios ermittelt und geschrieben!

	rÅckgabewert: 0 ok
				  <0 gemdos/bios fehlernummer oder
				  	 -1000 fÅr 'zu wenig daten geschrieben bei fwrite'
*/
int do_store_img(char *name,MFDB *buffer,int wid,int hght,COLOR *col,int xflag)
{
char *line;
static char lline[MAX_LINE_LEN],unpacked[256];
static char buf[BUF_SIZE];
static IMG_HEAD header;
static SAVE_IMG img;
int cnt,len,i;
char *h;

	if ( h_error((long)(f_id=Fcreate(name,0)),0L) )
		return xerr;

	init_write(buf);	/* init fÅr write_byte */

	line=lline;

	init_img(&img,&header,buffer,wid,hght,line,MAX_LINE_LEN);


	/*
		header modifizieren fÅr ximg
	*/
	if ( xflag )
		header.head_len+=3+3*(1<<header.plane_num);
		header.head_len+=3+3*(1<<header.plane_num);

	/*
		header schreiben
	*/
	for ( h=(char*)&header,len=0; len<16; len++,h++ )
		if ( write_byte(*h) )
			{ Fclose(f_id); return xerr; }


	/*
		ximg schreiben
	*/
	if ( xflag ) {
		if ( write_byte('X') || write_byte('I') || write_byte('M') || write_byte('G')
				|| write_byte(0) || write_byte(0) )
				{ Fclose(f_id); return xerr; }
		len=(int)sizeof(COLOR)*(1<<header.plane_num);

#ifndef GEMDUMP
		if ( col ) {
#endif
			for ( h=(char*)col; len>0; h++,len-- )
				if ( write_byte(*h) )
					{ Fclose(f_id); return xerr; }
#ifndef GEMDUMP
		}
		else {	/* farben nicht gesetzt -> via xbios holen */
		  COLOR col;
		  int i,c;
			for ( i=0; i<(1<<buffer->fd_nplanes); i++ ) {
				c=Setcolor(i,-1);
				col.red=(((c>>8)&7)*1000)/7;
				col.green=(((c>>4)&7)*1000)/7;
				col.blue=((c&7)*1000)/7;
				for ( h=(char*)&col,len=(int)sizeof(COLOR); len>0; h++,len-- )
					if ( write_byte(*h) )
						{ Fclose(f_id); return xerr; }
			}
		}
#endif
	}

	/*
		schreibe graphikdaten
	*/
	while ( get_line(&img,0) ) {
		cnt=1;
		while ( cnt<255 && get_line(&img,1) ) {		/* gleiche zeilen? */
			cnt++;
		}
		if ( cnt>1 ) {								/* zeilenwiederholung eintragen */
			if ( write_byte(0) || write_byte(0) || write_byte(0xFF) || write_byte(cnt) )
				{ Fclose(f_id); return xerr; }
		}

		h=line;										/* zeile schreiben */
		for ( i=0; i<img.planes; i++ ) {
			for ( len=cnt=0; cnt<img.bwid; ) {
				if ( (*h==0 && *(h+1)==0) || (*h==0xFF && *(h+1)==0xFF) ) {
				  char muster;						/* solid run */
					if ( len ) {
						if ( write_upk(len,unpacked) )
							{ Fclose(f_id); return xerr; }
					}
					len=0;
					muster=*h;
					while ( *h==muster && cnt<img.bwid && len<63 )
						len++,cnt++,h++;
					if ( muster!=0 )
						len|=128;
					if ( write_byte(len) )
						{ Fclose(f_id); return xerr; }
					len=0;
				}
				else if ( cnt+5<img.bwid && *h==*(h+1) && *h==*(h+2) && *h==*(h+3) && *h==*(h+4) ) {
				  char muster_lo,muster_hi;			/* pattern run */
				  char *h1,*h2;
					if ( len ) {
						if ( write_upk(len,unpacked) )
							{ Fclose(f_id); return xerr; }
					}
					len=0;
					h1=h;
					h2=h1+1;
					muster_lo=*h1;
					muster_hi=*h2;
					while ( *h1==muster_lo && *h2==muster_hi && cnt<img.bwid-1 && len<255 )
						len++,cnt+=2,h1+=2,h2+=2;
					if ( write_byte(0) || write_byte(len) || write_byte(muster_lo) || write_byte(muster_hi) )
						{ Fclose(f_id); return xerr; }
					h=h1;
					len=0;
				}
				else {								/* unpacked */
					unpacked[len++]=*h++;
					cnt++;
					if ( len==255 ) {
						if ( write_upk(len,unpacked) )
							{ Fclose(f_id); return xerr; }
						len=0;
					}
				}
			}
			if ( len ) {
				if ( write_upk(len,unpacked) )
					{ Fclose(f_id); return xerr; }
			}
		}
	}

	if ( close_write() )
		{ return xerr; }
	h_error((long)Fclose(f_id),0L);

	return 0;
}

/*
	erzeuge namen fÅr screendump
		scr_nr ist zÑhler fÅr bildnummer
*/
void make_name(char *name)
{
char *d,*s,nr[10];

	for ( d=name,s=inst.file; *s!=0; )	/* kopiere dump_file nach name */
		*d++=*s++;
	itoa(scr_nr,nr,10);	/* don't use sprintf here (exceeds prg-size) */
	scr_nr++;
	for ( s=nr; *s!=0; )				/* strcat nr an name */
		*d++=*s++;
	for ( s=".IMG"; *s!=0; )
		*d++=*s++;
	*d=0;
}

#ifndef GEMDUMP							/* verwaltet zugriff auf fullscreen */
										/* mittels scr->fd_addr==0l */
										/* liest parameter via XBIOS (Logbase) */
										/* Vdiesc/LineA-Variable */
										/* dx==0 -> fullscreen */
										/* dy==0 -> fullscreen */
int store_img(char *name,MFDB *scr,int dx,int dy,COLOR *col,int xflag)
{
	if ( scr->fd_addr==0l ) {
		linea_init();
		scr->fd_addr=Logbase();
		scr->fd_wdwidth=Vdiesc->bytes_lin/2/Linea->v_planes;
										/* notwendig fÅr overscan (dann ungleich dx/16!!) */
		scr->fd_w=Vdiesc->v_rez_hz;
		scr->fd_h=Vdiesc->v_rez_vt;
		scr->fd_nplanes=Linea->v_planes;
		scr->fd_stand=0;				/* gerÑteformat */
	}
	if ( dx==0 )
		dx=scr->fd_w;
	if ( dy==0 )
		dy=scr->fd_h;

	if ( do_store_img(name,scr,dx,dy,col,xflag) )
		return xerr;

	return 0;
}

void do_althelp(void)					/* aufruf von althelp */
{
MFDB scr;
char name[64];

	make_name(name);

	scr.fd_addr=0l;						/* access screen */
	store_img(name,&scr,0,0,0l,inst.ximg);
}
#endif

