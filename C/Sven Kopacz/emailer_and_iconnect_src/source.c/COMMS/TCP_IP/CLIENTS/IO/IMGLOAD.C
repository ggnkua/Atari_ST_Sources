#include <ec_gem.h>
#include "ioglobal.h"
#include <atarierr.h>
#include	<Types2B.h>
#include	<TOS.H>
#include  <VDICOL.H>

char	*aexe;

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

unsigned char *img_decode(char *get, long *dst_size) 
{ 
  char        c, *p, *line_buf, *line_buf_max, *buf_ptr, 
        *pline_buf; 
  IMG         *head; 
  unsigned char       scan_count = 0, n; 
  unsigned int        byte_per_line, odd_flag; 
  int         lines; 
  long        lsz, plsz, psz; 
  char        *ziel; 
 
  head        = (IMG *)get; 
  byte_per_line   = (head->linew + 7) >> 3; 
  odd_flag    = byte_per_line & 1; 
 
  lsz = (long)((head->linew+15)>>4) * sizeof(int); 
  plsz = lsz * (long)head->nplanes; 
  psz = lsz * (long)head->lines; 
  buf_ptr = malloc(plsz); 
 
  *dst_size = psz * (long)head->nplanes; 
  pline_buf = malloc(*dst_size); 
  ziel = pline_buf; 
  if (ziel==0L) { 
    return(0L); 
  } 
 
  get += 2 * head->headlen;               /*  Header-Bytes Åberlesen  */ 
 
  line_buf_max= buf_ptr + plsz; 
  lines       = head->lines; 
 
  while (lines > 0) { 
    line_buf    = buf_ptr; 
    scan_count  = 1; 
    do { 
      p = line_buf; 
      line_buf += byte_per_line; 
      do { 
        if ( (c = *get++) < 0 ) {   /*  Bit 7 gesetzt?  */ 
                      /*  Bit 7 lîschen   */ 
          if (!(c += 128)) {      /*  Fall 0x80 = n uncompressed 
                        Bytes */ 
            n = *(unsigned char*)get++; 
            do{ 
              *p++ = *get++; 
            } while(--n); 
          } 
          else                    /*  FÅllen mit 0xFF */ 
            do { 
              *p++ = 0xFF; 
            } while(--c); 
        } 
        else if ( !c ) {            /*  Fall 0x00 = Scanline    */ 
          if ( ( n = *(unsigned char*)get++ ) > 0 ) { 
            char    patbuf[20], *pat;  /*  Pattern n-mal   */ 
            int i = head->patlen; 
 
            pat = patbuf;   /*  Pattern lesen   */ 
            do { 
              *pat++ = *get++; 
            } while(--i); 
 
            /*  Pattern n-mal schreiben */ 
            do { 
              i   = head->patlen; 
              pat = patbuf; 
              do { 
                *p++ = *pat++; 
              } while( --i ); 
            } while( --n ); 
          } 
          else {                      /*  Scanline-run    */ 
            get++;                  /*  öberlese Flag   */ 
            scan_count = *get++;    /*  Wdh.-Anzahl */ 
          } 
        } 
        else                            /*  FÅllen mit 0x00 */ 
          do { 
            *p++ = 0; 
          } while( --c ); 
 
      } while( p < line_buf ); 
 
    } while( (line_buf += odd_flag) < line_buf_max ); 
 
    do { 
      p   = buf_ptr; 
      line_buf= pline_buf; 
 
      do { 
        memcpy( line_buf, p, byte_per_line ); 
        line_buf += psz; 
        p += lsz; 
      } while( p < line_buf_max ); 
 
      pline_buf += lsz; 
      lines--; 
      scan_count--; 
 
    } while( lines > 0 && scan_count > 0 ); 
  } 
 
  free(buf_ptr); 
 
  return((unsigned char*)ziel); 
} 



int nvdi5(void)
{
	static int work_out[57], done=0;
	
	if(!done) {vq_extnd(handle, 1, work_out); done=1;}
	return(work_out[30] & 1);
}

int load_img_file(int fh, long fsize, MFDB *mf)
{
	unsigned char	*lbuf, *decbuf;
	long	read;
	int		num, a, off_handle;
	int16 pxy[8];
/*	int 	vdi2tos[]={0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1};*/
	IMG		*imgh;
	MFDB	m1, m2;
	COLOR_TAB256 ctab;
	GCBITMAP	gcbm, offbm;
	
	lbuf=malloc(fsize);
	if(lbuf==NULL) return(ENSMEM);
	read=Fread(fh, fsize, lbuf);
	if(read < 0)
	{
		free(lbuf);
		return((int)read);
	}
	decbuf=img_decode((char*)lbuf, &fsize);
	if(decbuf==NULL)
	{
		free(lbuf);
		return(ENSMEM);
	}
	imgh=(IMG*)lbuf;

	if(imgh->magic=='XIMG')
	{/* Farbpalette holen */
		ctab.magic='ctab';
		ctab.length=sizeof(COLOR_TAB);
		ctab.format=ctab.reserved=0;
		ctab.map_id=1;
		ctab.color_space=CSPACE_RGB;
		ctab.flags=0;
		ctab.no_colors=num=1 << imgh->nplanes;
		if(imgh->colmode==0)
		{/* RGB */
			/* Batman-Workaround... */
			/*imgh->colpal[15][0]=0;imgh->colpal[15][1]=0;imgh->colpal[15][2]=0;*/

			for(a=0; a < num; ++a)
			{
				ctab.colors[a].rgb.reserved=0;
				ctab.colors[a].rgb.red=(imgh->colpal[a][0])*65;
				ctab.colors[a].rgb.green=(imgh->colpal[a][1])*65;
				ctab.colors[a].rgb.blue=(imgh->colpal[a][2])*65;
			}
		}
		else	
		{/* CMY */
			for(a=0; a < num; ++a)
			{
				imgh->colpal[a][0]=255-imgh->colpal[a][0];
				imgh->colpal[a][1]=255-imgh->colpal[a][1];
				imgh->colpal[a][2]=255-imgh->colpal[a][2];
				ctab.colors[a].rgb.reserved=0;
				ctab.colors[a].rgb.red=imgh->colpal[a][0]*65;
				ctab.colors[a].rgb.green=imgh->colpal[a][1]*65;
				ctab.colors[a].rgb.blue=imgh->colpal[a][2]*65;
			}
		}
	}
	/* Wenn kein NVDI 5 da ist, dann muû IMG in aktueller
		 Auflîsung und Palette vorliegen */
	if(nvdi5()==0) goto _no_nvdi5;
	
	/* Transformieren auf Offscreen-Bitmap im Screen-Format
	   und von dort in MFDB holen */

	/* Quell-Bitmap anlegen */
	gcbm.magic='cbtm';
	gcbm.length=sizeof(GCBITMAP);
	gcbm.format=0; gcbm.reserved=0;
	gcbm.addr=decbuf;
	gcbm.width=((imgh->linew+15)>>4)<<4; /* Breite in Pixeln */
	gcbm.width*=imgh->nplanes; /* Breite in Bit */
	gcbm.width>>=3;	/* Breite in Byte */
	gcbm.bits=imgh->nplanes;
	gcbm.px_format=PX_1COMP+PX_PLANES+((imgh->nplanes)<<8)+(imgh->nplanes);
	gcbm.xmin=0; gcbm.ymin=0; 
	gcbm.xmax=imgh->linew; gcbm.ymax=imgh->lines;
	gcbm.ctab=(COLOR_TAB*)(&ctab);
	gcbm.itab=NULL;
	gcbm.reserved0=gcbm.reserved1=0;

	/* Offscreen-Bitmap anlegen */
	offbm.magic='cbtm';
	offbm.length=sizeof(GCBITMAP);
	offbm.format=0; offbm.reserved=0;
	offbm.addr=NULL; offbm.width=0; offbm.bits=0; offbm.px_format=0;
	offbm.xmin=0; offbm.ymin=0;
	offbm.xmax=imgh->linew; offbm.ymax=imgh->lines;
	offbm.reserved0=0; offbm.reserved1=0;
	off_handle=v_open_bm(handle, &offbm, 0, 0, 0, 0);

	/* Transformieren */
	pxy[0]=0; pxy[1]=0;
	pxy[2]=imgh->linew-1; pxy[3]=imgh->lines-1;
	graf_mouse(BUSYBEE, NULL);
	vr_transfer_bits(handle, &gcbm, &offbm, pxy, pxy, T_REPLACE|T_DITHER_MODE);
	graf_mouse(ARROW, NULL);
	
	/* Ergebnis in MFDB kopieren */
	m2.fd_addr=malloc(offbm.ymax*offbm.width);
	m2.fd_w=imgh->linew;
	m2.fd_h=imgh->lines;
	m2.fd_wdwidth=(imgh->linew+15)>>4;
	m2.fd_stand=0;
	m2.fd_nplanes=(int)offbm.bits;
	m2.fd_r1=m1.fd_r2=m1.fd_r3=0;
	if(m2.fd_addr==NULL) {free(lbuf);free(decbuf);return(0);}
	memcpy(m2.fd_addr, offbm.addr, offbm.ymax*offbm.width);

	v_clsbm(off_handle);
	goto _vdi_done;


	/* Funktionen ohne NVDI 5: */
_no_nvdi5:
	m1.fd_addr=decbuf;
	m1.fd_w=imgh->linew;
	m1.fd_h=imgh->lines;
	m1.fd_wdwidth=(imgh->linew+15)>>4;
	m1.fd_stand=1;
	m1.fd_nplanes=imgh->nplanes;
	m1.fd_r1=m1.fd_r2=m1.fd_r3=0;
	

	m2=m1;
	m2.fd_addr=malloc((imgh->nplanes*m1.fd_wdwidth*sizeof(int)*m1.fd_h));
	if(m2.fd_addr==NULL) {free(lbuf);free(decbuf);return(0);}
	m2.fd_stand=0;
	vr_trnfm(handle, &m1, &m2);

_vdi_done:
	free(lbuf);
	free(decbuf);
	*mf=m2;
	return(0);
}

int load_img(MFDB *mf, char *path)
{
	long	fhl;
	int 	fh;

	fhl=Fopen(path, FO_READ);
	if(fhl < 0) return(0);
	fh=(int)fhl;
	fhl=Fseek(0, fh, 2);
	Fseek(0, fh, 0);
	fhl=load_img_file(fh, fhl, mf);
	Fclose(fh);
	if(fhl < 0) return(0);
	return(1);
}
