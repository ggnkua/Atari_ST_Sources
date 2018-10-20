#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <fiodef.h>
#include <atarierr.h>
#include <tos.h>

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

void cdecl	mod_init(void);	/* Initialisierung des Moduls */
int cdecl		identify(FILE_DSCR *fd);
int cdecl		load_file(FILE_DSCR *fd, GRAPE_DSCR *dd);

uchar *img_decode(char *get, long *dst_size);

static MODULE_FIOFN mod_fn=
{
	/* Meine Funktionen */	
	mod_init,
	identify,
	load_file,
	NULL
};

static FIOMODBLK fblock=
{
	"GRAPEFIOMOD",
	'0101',
	
	/* id */
	'IMG1',
	
	/* name */
	"GEM-Image",

	/* Exportformate */
	0,
	
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
	strcat(dscr, "Grîûe: ");
	itoa(imgh->linew, &(dscr[strlen(dscr)]), 10);
	strcat(dscr, " x ");
	itoa(imgh->lines, &(dscr[strlen(dscr)]), 10);
	strcat(dscr, " Pixel");
	
	strcat(dscr, "|Kodierung: Level ");
	itoa(imgh->version, &(dscr[strlen(dscr)]), 10);
	if(imgh->version > 1) cant_load=1;
	
	fd->descr=dscr;
	fd->width=imgh->linew;
	fd->height=imgh->lines;
	
	if((!cant_load)&&((imgh->nplanes==1)||(imgh->nplanes==4)||(imgh->nplanes==8)))
		rec|=CAN_LOAD|FAST_LOAD;
	return(rec);
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
	decbuf=img_decode((char*)lbuf, &fsize);
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

uchar *img_decode(char *get, long *dst_size) 
{ 
  char        c, *p, *line_buf, *line_buf_max, *buf_ptr, 
        *pline_buf; 
  IMG         *head; 
  uchar       scan_count = 0, n; 
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
  buf_ptr = _GF_ malloc(plsz); 
 
  *dst_size = psz * (long)head->nplanes; 
  pline_buf = _GF_ malloc(*dst_size); 
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
            n = *(uchar*)get++; 
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
          if ( ( n = *(uchar*)get++ ) > 0 ) { 
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
 
  _GF_ free(buf_ptr); 
 
  return((uchar*)ziel); 
} 


