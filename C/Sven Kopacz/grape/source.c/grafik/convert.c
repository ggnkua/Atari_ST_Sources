#include <grape_h.h>
#include <fiodef.h>
#include "convert.h"
#include "ip82pp24.h"

uchar grey_pal[256];

/*
**********************************************************

                    GENERAL CONVERSIONS

**********************************************************
*/  

void pp_to_ip8(int mode, BLOCK_DSCR *bd)
{/* Convert from 8Bit pp to 8Bit interleaved */
 /* mode: 0=Low bit first, 1=High bit first */
	register uchar *src, *dst, dbit;
	register int ry, rx;
	register char bit;
	ulong size=bd->lw * bd->h;
	uchar	*mdst;
	register ulong adpix, adbit;
	
	mdst=dst=calloc(size, 1);
	if(dst==NULL) return;	/* Sorry, no return-code... */
	
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Offset Dest */
	adbit=adpix/8;
	if(adbit*8 < adpix) ++adbit;	/* Restbit aus unvollem Byte */

	if(mode==0)	for(bit=0; bit < 8; ++bit)
	{
		/* Sourceadresse */
		src=bd->data;
		for(ry=bd->h; ry; --ry)
		{
			dbit=0;
			for(rx=bd->w; rx; --rx)
			{
				*dst|=(*src++ & bit) << dbit++;
				if(dbit==8){++dst;dbit=0;}
			}
			src+=adpix;
			dst+=adbit;
		}
	}
	else for(bit=7; bit>=0; --bit)
	{
		/* Sourceadresse */
		src=bd->data;
		for(ry=bd->h; ry; --ry)
		{
			dbit=0;
			for(rx=bd->w; rx; --rx)
			{
				*dst|=(*src++ & bit) << dbit++;
				if(dbit==8){++dst;dbit=0;}
			}
			src+=adpix;
			dst+=adbit;
		}
	}
	
	/* Ergebnis zurckkopieren */
	dst=bd->data;
	src=mdst;
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*dst++=*src++;
		}
		dst+=adpix; src+=adpix;
	}
	free(mdst);
}

/*
**********************************************************

                       GREY-MASK

**********************************************************
*/  
/* 
***************************************
* Input Converters for 8-Bit Greymask *
***************************************
*/

void mincon_1(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 1 Bit Pixelplane, 0=gc_pal[0], 1=gc_pal[1] */
	long					 sadd;
	register uchar *m, *src;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register uchar set, nset;
	
	/* Farben fr Bit0/1 */
	nset=grey_pal[0];
	set=grey_pal[1];

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			if(src[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				*m++=set;
			else
				*m++=nset;
			++spix;
		}
		spix+=adpix;
		m+=dadpix;
	}
}

void mincon_4pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 4 Bit PixelPacked, col=pal[0-15] */
	long					 sadd;
	register uchar *m, *src, *pal=grey_pal;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register uchar scol;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			if(spix & 1) /* Untere H„lfte des Bytes */
				scol=src[spix>1] & 15;
			else				 /* Obere H„lfte des Bytes */
				scol=(src[spix>1])>>4;
			*m++=pal[scol];
			++spix;
		}
		spix+=adpix;
		m+=dadpix;
	}
}

void mincon_4ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 4 Bit Interleaved Planes, col=pal[0-15] */
 /* mode=0: first bit=low bit, else first bit=high bit */
	long					 sadd;
	register uchar *m, *src1, *src2, *src3, *src4;
	register uchar *pal=grey_pal;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register uchar scol;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadressen */
	sadd=(long)(bd->lw/8)*(long)(bd->h);
	if(mode)
	{
		src1=bd->data+sadd*3;
		src2=src1-sadd;
		src3=src2-sadd;
		src4=src3-sadd;
	}
	else
	{
		src1=bd->data;
		src2=src1+sadd;
		src3=src2+sadd;
		src4=src3+sadd;
	}
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			scol=0;
			if(src1[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=1;
			if(src2[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=2;
			if(src3[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=4;
			if(src4[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=8;

			*m++=pal[scol];
			++spix;
		}
		spix+=adpix;
		m+=dadpix;
	}
}

void mincon_8ppgrey(BLOCK_DSCR *bd, GRAPE_DSCR *dd, int mode)
{/* Source is 8 Bit PixelPacked, 
	mode 0: 0=white, 255=black
	mode 1: 255=white, 1=black */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	if (mode) for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*m++=~(*src++);
		src+=adpix;
		m+=dadpix;
	}
	else for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*m++=*src++;
		src+=adpix;
		m+=dadpix;
	}
}

void mincon_8pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit PixelPacked, col=pal */
	long					 sadd;
	register uchar *m, *src, *pal=grey_pal;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register uchar scol;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			scol=*src++;
			*m++=pal[scol];
		}
		src+=adpix;
		m+=dadpix;
	}
}

void mincon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */
	long					 sadd;
	register uchar *m;
	register uchar *src1, *src2, *src3, *src4, *src5, *src6, *src7, *src8;
	register uchar *pal=grey_pal;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register uchar scol;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadressen */
	sadd=(long)(bd->lw/8)*(long)(bd->h);
	if(mode)
	{
		src1=bd->data+sadd*7;
		src2=src1-sadd;
		src3=src2-sadd;
		src4=src3-sadd;
		src5=src4-sadd;
		src6=src5-sadd;
		src7=src6-sadd;
		src8=src7-sadd;
	}
	else
	{
		src1=bd->data;
		src2=src1+sadd;
		src3=src2+sadd;
		src4=src3+sadd;
		src5=src4+sadd;
		src6=src5+sadd;
		src7=src6+sadd;
		src8=src7+sadd;
	}
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			scol=0;
			if(src1[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=1;
			if(src2[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=2;
			if(src3[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=4;
			if(src4[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=8;
			if(src5[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=16;
			if(src6[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=32;
			if(src7[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=64;
			if(src8[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=128;

			*m++=pal[scol];
			++spix;
		}
		spix+=adpix;
		m+=dadpix;
	}
}

void mincon_rgbpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is RGB PixelPacked */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register unsigned int	mr, mg, mb, mc;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			mr=*src++;
			mg=*src++;
			mb=*src++;
			mc=77*mr+151*mg+28*mb;
			mc=mc >> 8;
			*m++=255-mc;
		}
		src+=adpix;
		m+=dadpix;
	}
}

void mincon_rgbip(int planes, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=PRED|PGREEN|PBLUE, Source is RGB Interleaved Planes */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register unsigned int mc;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;

	if(planes & PRED)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{ mc=*src++; *m++=255-((mc*77)>>8);}
		src+=adpix;
		m+=dadpix;
	}
	else
	{/* Ziel erstmal ausnullen */
		for(ry=bd->h; ry; --ry)
		{
			for(rx=bd->w; rx; --rx)
				*m++=0;
			m+=dadpix;
		}
	}
	m=dd->mask+sadd;
	if(planes & PGREEN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{ mc=*src++; *m++ +=255-((mc*151)>>8);}
		src+=adpix;
		m+=dadpix;
	}
	m=dd->mask+sadd;
	if(planes & PBLUE)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{ mc=*src++; *m++ +=255-((mc*28)>>8);}
		src+=adpix;
		m+=dadpix;
	}
}

void mincon_cmypp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is CMY PixelPacked */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register unsigned int	mr, mg, mb, mc;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			mr=255-*src++;
			mg=255-*src++;
			mb=255-*src++;
			mc=77*mr+151*mg+28*mb;
			mc=mc >> 8;
			*m++=255-mc;
		}
		src+=adpix;
		m+=dadpix;
	}
}

void mincon_cmykpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is CMYK PixelPacked */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register unsigned int	mr, mg, mb, mc;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	adpix*=4;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			mr=255-*src++;
			mg=255-*src++;
			mb=255-*src++;
			mc=77*mr+151*mg+28*mb;
			mc=mc >> 8;
			*m++=255-mc+*src++;
		}
		src+=adpix;
		m+=dadpix;
	}
}

void mincon_cmykip(int planes,BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=PCYAN|PMAG|PYEL|PBLACK, Source is CMYK Interleaved Planes */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register unsigned int mc;
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	if(planes & PCYAN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{mc=255-*src++; *m++=255-((77*mc)>>8);}
		src+=adpix;
		m+=dadpix;
	}
	else
	{/* Ziel erstmal ausnullen */
		for(ry=bd->h; ry; --ry)
		{
			for(rx=bd->w; rx; --rx)
				*m++=0;
			m+=dadpix;
		}
	}
	m=dd->mask+sadd;
	if(planes & PMAG)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{mc=255-*src++; *m++ +=255-((151*mc)>>8);}
		src+=adpix;
		m+=dadpix;
	}
	m=dd->mask+sadd;
	if(planes & PYEL)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{mc=255-*src++; *m++ +=255-((28*mc)>>8);}
		src+=adpix;
		m+=dadpix;
	}
	m=dd->mask+sadd;
	if(planes & PBLACK)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*m++ +=*src++;

		src+=adpix;
		m+=dadpix;
	}
}


/* 
****************************************
* Output Converters for 8-Bit Greymask *
****************************************
*/


void moutcon_1(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 1 Bit Pixelplane, 1=if any set, 0=else */
 /* Das Ziel MUSS komplett 0 gesetzt sein! */
	long					 sadd;
	register uchar *m, *src;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Quelle*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Quelladresse */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;

	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			if(*m++)
				src[spix>>3] |= (1<<(7-(spix & 7))); /* Bit setzen */
			++spix;
		}
		spix+=adpix;
		m+=dadpix;
	}
}

void moutcon_4pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 4 Bit PixelPacked, col=pal[0-15] */
	long					 sadd;
	register uchar *pal=&(gc_pal[0][0]);
	register uchar *m, *src, nibble;
	register long	 adpix, dadpix;
	register int	 ry, rx, pc;
	
	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	for(ry=bd->h; ry; --ry)
	{
		nibble=1;
		for(rx=bd->w; rx; --rx)
		{
			for(pc=0; pc < 3*16; pc+=3)
				if(pal[pc]==*m) break;
			if(nibble)
			{
				*src=(pc/3)<<4;
				nibble=0;
			}
			else
			{
				*src++|=(pc/3);
				nibble=1;
			}
			++m;
		}
		src+=adpix;
		m+=dadpix;
	}
}

void moutcon_4ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 4 Bit Interleaved Planes, col=pal[0-15] */
 /* mode=0: first bit=low bit, else first bit=high bit */
}

void moutcon_8pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 8 Bit PixelPacked, col=pal */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=*m++;
		src+=adpix;
		m+=dadpix;
	}
}

void moutcon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */

 moutcon_8pp(bd, dd);
 pp_to_ip8(mode, bd);
}

void moutcon_rgbpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is RGB PixelPacked */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*src++=~(*m);
			*src++=~(*m);
			*src++=~(*m++);
		}
		src+=adpix;
		m+=dadpix;
	}
}

void moutcon_rgbip(int planes, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=RED|GREEN|BLUE, Dest is RGB Interleaved Planes */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	if(planes & PRED)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*m++);
		src+=adpix;
		m+=dadpix;
	}
	m=dd->mask+sadd;
	if(planes & PGREEN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*m++);
		src+=adpix;
		m+=dadpix;
	}
	m=dd->mask+sadd;
	if(planes & PBLUE)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*m++);
		src+=adpix;
		m+=dadpix;
	}
}

void moutcon_cmypp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is CMY PixelPacked */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*src++=*m;
			*src++=*m;
			*src++=*m++;
		}
		src+=adpix;
		m+=dadpix;
	}
}

void moutcon_cmykpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is CMYK PixelPacked */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*src++=0;
			*src++=0;
			*src++=0;
			*src++=*m++;
		}
		src+=adpix;
		m+=dadpix;
	}
}

void moutcon_cmykip(int planes,BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=PCYAN|PMAG|PYEL|PBLACK, Dest is CMYK Interleaved Planes */
	long					 sadd;
	register uchar *m, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	/* Offset  fr SRC*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* SRCadressen */
	m=dd->mask+sadd;
	/* Zeilenoffest SRC */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	if(planes & PCYAN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=0;
		src+=adpix;
	}
	if(planes & PMAG)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=0;
		src+=adpix;
	}
	if(planes & PYEL)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=0;
		src+=adpix;
	}
	if(planes & PBLACK) for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=*m++;
		src+=adpix;
		m+=dadpix;
	}
}



/*
**********************************************************

                       CMY-LAYER

**********************************************************
*/  
                     
/* 
****************************************
* Input Converters for 24Bit CMY-Layer *
****************************************
*/


void incon_1(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 1 Bit Pixelplane, 0=gc_pal[0], 1=gc_pal[1] */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register uchar sc, sm, sy, nsc, nsm, nsy;

	if(dd->mask)	{mincon_1(bd, dd); return;}
		
	/* Farben fr Bit0/1 */
	nsc=gc_pal[0][0]; nsm=gc_pal[0][1]; nsy=gc_pal[0][2];
	sc=gc_pal[1][0]; sm=gc_pal[1][1]; sy=gc_pal[1][2];

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			if(src[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
			{	*c++=sc; *m++=sm; *y++=sy;}
			else
			{ *c++=nsc; *m++=nsm; *y++=nsy;}
			++spix;
		}
		spix+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_4pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 4 Bit PixelPacked, col=pal[0-15] */
	long					 sadd;
	register uchar *c, *m, *y, *src, *pal=&(gc_pal[0][0]);
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register int	 scol;

	if(dd->mask)	{mincon_4pp(bd, dd); return;}
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			if(spix & 1) /* Untere H„lfte des Bytes */
				scol=src[spix>1] & 15;
			else				 /* Obere H„lfte des Bytes */
				scol=(src[spix>1])>>4;
			scol*=3;
			*c++=pal[scol];
			*m++=pal[scol+1];
			*y++=pal[scol+2];
			++spix;
		}
		spix+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_4ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 4 Bit Interleaved Planes, col=pal[0-15] */
 /* mode=0: first bit=low bit, else first bit=high bit */
	long					 sadd;
	register uchar *c, *m, *y, *src1, *src2, *src3, *src4;
	register uchar *pal=&(gc_pal[0][0]);
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register int	 scol;

	if(dd->mask)	{mincon_4ip(mode, bd, dd); return;}
	
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadressen */
	sadd=(long)((long)(bd->lw/8)*(long)(bd->h));
	if(mode)
	{
		src1=bd->data+sadd*3;
		src2=src1-sadd;
		src3=src2-sadd;
		src4=src3-sadd;
	}
	else
	{
		src1=bd->data;
		src2=src1+sadd;
		src3=src2+sadd;
		src4=src3+sadd;
	}
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			scol=0;
			if(src1[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=1;
			if(src2[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=2;
			if(src3[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=4;
			if(src4[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=8;
			
			scol*=3;
			
			*c++=pal[scol];
			*m++=pal[scol+1];
			*y++=pal[scol+2];
			++spix;
		}
		spix+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_8ppgrey(BLOCK_DSCR *bd, GRAPE_DSCR *dd, int mode)
{/* Source is 8 Bit PixelPacked, col=pal */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{mincon_8ppgrey(bd, dd, mode); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	if (mode) for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*c++=*m++=*y++=~(*src++);
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
	else for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*c++=*m++=*y++=*src++;
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_8pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit PixelPacked, col=pal */
	long					 sadd;
	register uchar *c, *m, *y, *src, *pal=&(gc_pal[0][0]);
	register long	 adpix, dadpix;
	register int	 ry, rx;
	register int	 scol;
	
	if(dd->mask)	{mincon_8pp(bd, dd); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			scol=*src++;
			scol*=3;
			*c++=pal[scol];
			*m++=pal[scol+1];
			*y++=pal[scol+2];
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
		
		rx=(int)Fcreate("DEB.RAW",0);
		Fwrite(rx, 256*3, pal);
		Fwrite(rx, (long)(bd->w)*(long)(bd->h), bd->data);
		Fclose(rx);
}

void nomem_incon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */
 /* Wird von incon_8ip aufgerufen, wenn kein Speicher mehr frei ist */
	long					 sadd;
	register uchar *c, *m, *y;
	register uchar *src1, *src2, *src3, *src4, *src5, *src6, *src7, *src8;
	register uchar *pal=&(gc_pal[0][0]);
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register int scol;
	
	if(dd->mask)	{mincon_8ip(mode, bd, dd); return;}
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadressen */
	sadd=(long)((long)(bd->lw/8l)*(long)(bd->h));
	if(mode)
	{
		src1=bd->data+sadd*7;
		src2=src1-sadd;
		src3=src2-sadd;
		src4=src3-sadd;
		src5=src4-sadd;
		src6=src5-sadd;
		src7=src6-sadd;
		src8=src7-sadd;
	}
	else
	{
		src1=bd->data;
		src2=src1+sadd;
		src3=src2+sadd;
		src4=src3+sadd;
		src5=src4+sadd;
		src6=src5+sadd;
		src7=src6+sadd;
		src8=src7+sadd;
	}
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			scol=0;
			if(src1[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=1;
			if(src2[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=2;
			if(src3[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=4;
			if(src4[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=8;
			if(src5[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=16;
			if(src6[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=32;
			if(src7[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=64;
			if(src8[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
				scol|=128;

			scol*=3;
			*c++=pal[scol];
			*m++=pal[scol+1];
			*y++=pal[scol+2];
			++spix;
		}
		spix+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */
 /* In /ALT/CONVERT.C findet sich der hier aufgerufene
 		Assemblerteil in C */
 		
	long					 sadd, siz;
	uchar					 *mbuf;
	
	if(dd->mask)	{mincon_8ip(mode, bd, dd); return;}

	/* Puffer holen */
  siz=(long)((long)(bd->w)*(long)(bd->h));

 	mbuf=dbuf=calloc(siz, 1);
  if(mbuf==NULL){nomem_incon_8ip(mode, bd, dd); return;}
  
  /* Jede Bitplane einzeln in Puffer kopieren */
	/* Sourceadressen */
	sadd=(long)((long)(bd->lw/8l)*(long)(bd->h));
	if(mode)
		src=bd->data+sadd*7;
	else
		src=bd->data;
  add_src=sadd;
  add_pix=(bd->lw-bd->w+7)/8;
  hi=bd->h;  wi=bd->w;  amode=mode;
  ip82pp24();
  
	/* Puffer per Palette in Dest kopieren */
	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	cp=dd->c+sadd;	mp=dd->m+sadd;	yp=dd->y+sadd;

  dbuf=mbuf;  hi=bd->h;  wi=bd->w;  add_buf=0;
	cpal=&(gc_pal[0][0]);
  add_dest=dd->line_width-bd->w;
	pp82pp24();
	free(mbuf);
}

void incon_rgbpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is RGB PixelPacked */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{mincon_rgbpp(bd, dd); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*c++=~(*src++);
			*m++=~(*src++);
			*y++=~(*src++);
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_rgbip(int planes, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=PRED|PGREEN|PBLUE, Source is RGB Interleaved Planes */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{mincon_rgbip(planes, bd, dd); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	if(planes & PRED)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*c++=~(*src++);
		src+=adpix;
		c+=dadpix;
	}
	if(planes & PGREEN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*m++=~(*src++);
		src+=adpix;
		m+=dadpix;
	}
	if(planes & PBLUE)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*y++=~(*src++);
		src+=adpix;
		y+=dadpix;
	}
}

void incon_cmypp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is CMY PixelPacked */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{mincon_cmypp(bd, dd); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*c++=*src++;
			*m++=*src++;
			*y++=*src++;
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void incon_cmykpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is CMYK PixelPacked */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{mincon_cmykpp(bd, dd); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	adpix*=4;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*c=*src++;
			*m=*src++;
			*y=*src++;
			*c++ +=(*src);
			*m++ +=(*src);
			*y++ +=(*src++);
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
	
}

void incon_cmykip(int planes,BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=PCYAN|PMAG|PYEL|PBLACK, Source is CMYK Interleaved Planes */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{mincon_cmykip(planes, bd, dd); return;}

	/* Offset  fr Ziel*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Zieladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Dest */
	dadpix=dd->line_width-bd->w;
	/* Sourceadresse */
	src=bd->data;
	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	
	if(planes & PCYAN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*c++=*src++;
		src+=adpix;
		c+=dadpix;
	}
	if(planes & PMAG)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*m++=*src++;
		src+=adpix;
		m+=dadpix;
	}
	if(planes & PYEL)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*y++=*src++;
		src+=adpix;
		y+=dadpix;
	}
	if(planes & PBLACK)	
	{
		/* Zieladressen */
		c=dd->c+sadd;
		m=dd->m+sadd;
		y=dd->y+sadd;
		for(ry=bd->h; ry; --ry)
		{
			for(rx=bd->w; rx; --rx)
			{
				*c++ +=(*src);
				*m++ +=(*src);
				*y++ +=(*src++);
			}
			src+=adpix;
			c+=dadpix; m+=dadpix; y+=dadpix;
		}
	}
}


/* 
*****************************************
* Output Converters for 24Bit CMY layer *
*****************************************
*/

void outcon_1(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 1 Bit Pixelplane, 1=if any set, 0=else */
 /* Das Ziel MUSS komplett 0 gesetzt sein! */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_1(bd, dd); return;}

	/* Offset  fr Quelle*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Quelladressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	/* Aktueller Pixel */
	spix=0;

	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			if(*c || *m || *y)
				src[spix>>3] |= (1<<(7-(spix & 7))); /* Bit setzen */
			++c; ++m; ++y;
			++spix;
		}
		spix+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void outcon_4pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 4 Bit PixelPacked, col=pal[0-15] */
	long					 sadd;
	register uchar *c, *m, *y, cc, mm, yy, *src, nibble;
	register uchar *pal=&(gc_pal[0][0]), pc;
	register long	 adpix, dadpix;
	register int	 ry, rx;

	if(dd->mask)	{moutcon_4pp(bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffset Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=(bd->lw-bd->w)/2;
	for(ry=bd->h; ry; --ry)
	{
		nibble=1;	
		for(rx=bd->w; rx; --rx)
		{
			cc=*c++; mm=*m++; yy=*y++;
			for(pc=0; pc < 16*3; pc+=3)
				if((cc==pal[pc])&&(mm==pal[pc+1])&&(yy==pal[pc+2])) break;
			if(nibble)	/* Oberes Nibble */
			{
				*src=(pc/3)<<4;
				nibble=0;
			}
			else
			{
				*src++|=(pc/3);
				nibble=1;
			}
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void outcon_4ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 4 Bit Interleaved Planes, col=pal[0-15] */
 /* mode=0: first bit=low bit, else first bit=high bit */
	if(dd->mask)	{moutcon_4ip(mode, bd, dd); return;}
}

void outcon_8ppgrey(BLOCK_DSCR *bd, GRAPE_DSCR *dd, int mode)
{/* Dest is 8 Bit PixelPacked, mode=0: 0=white/255=black
		mode=1: white=255/black=0 */
	long					 sadd;
	register uchar *c, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_8pp(bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	if(mode)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*c++);
		src+=adpix;
		c+=dadpix;
	}
	else	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=*c++;
		src+=adpix;
		c+=dadpix;
	}

}

void outcon_8ipgrey(int lbit, int black, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 8 Bit Grey interleaved
		lbit: 0=Low bit first, 1=High Bit first
		black: 1=Black is zero, 0=White is zero
 */
	if(dd->mask)	{moutcon_8ip(lbit, bd, dd); return;}
 
	outcon_8ppgrey(bd, dd, black);
	pp_to_ip8(lbit, bd);
}

void outcon_8pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 8 Bit PixelPacked, col=pal */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register uchar *pal=&(gc_pal[0][0]);
	register long	 adpix, dadpix;
	register int	 ry, rx, pc;

	if(dd->mask)	{moutcon_8pp(bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffset Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			for(pc=0; pc < 255*3; pc+=3)
				if((*c==pal[pc])&&(*m==pal[pc+1])&&(*y==pal[pc+2])) break;
				
			*src++=pc/3;
			c++;m++;y++;
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void outcon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */
	if(dd->mask)	{moutcon_8ip(mode, bd, dd); return;}
	
	outcon_8pp(bd, dd);
	pp_to_ip8(mode, bd);
}

void outcon_rgbpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is RGB PixelPacked */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_rgbpp(bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*src++=~(*c++);
			*src++=~(*m++);
			*src++=~(*y++);
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void outcon_rgbip(int planes, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=RED|GREEN|BLUE, Dest is RGB Interleaved Planes */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_rgbip(planes, bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	if(planes & PRED)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*c++);
		src+=adpix;
		c+=dadpix;
	}
	if(planes & PGREEN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*m++);
		src+=adpix;
		m+=dadpix;
	}
	if(planes & PBLUE)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=~(*y++);
		src+=adpix;
		y+=dadpix;
	}
}

void outcon_cmypp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is CMY PixelPacked */
	long					 sadd;
	register uchar *c, *m, *y, *src;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_cmypp(bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			*src++=*c++;
			*src++=*m++;
			*src++=*y++;
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void outcon_cmykpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Dest is CMYK PixelPacked */
	long					 sadd;
	register uchar *c, *m, *y, *src, op;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_cmykpp(bd, dd); return;}

	/* Offset  fr Src*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* Srcadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest Src */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	adpix*=3;
	
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			op=*c; if(*m < op) op=*m; if(*y < op) op=*y;
			*src++=(*c++) - op;
			*src++=(*m++) - op;
			*src++=(*y++) - op;
			*src++=op;
		}
		src+=adpix;
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
}

void outcon_cmykip(int planes,BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* planes=PCYAN|PMAG|PYEL|PBLACK, Dest is CMYK Interleaved Planes */
	long					 sadd;
	register uchar *c, *m, *y, *src, op;
	register long	 adpix, dadpix;
	register int	 ry, rx;
	
	if(dd->mask)	{moutcon_cmykip(planes, bd, dd); return;}

	/* Offset  fr SRC*/
	sadd=(long)(bd->y)*(long)(dd->line_width);
	sadd+=(long)(bd->x);
	/* SRCadressen */
	c=dd->c+sadd;
	m=dd->m+sadd;
	y=dd->y+sadd;
	/* Zeilenoffest SRC */
	dadpix=dd->line_width-bd->w;
	/* Destadresse */
	src=bd->data;
	/* Zeilenoffset Dest */
	adpix=bd->lw-bd->w;
	
	if(planes & PCYAN)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=*c++;
		src+=adpix;
		c+=dadpix;
	}
	if(planes & PMAG)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=*m++;
		src+=adpix;
		m+=dadpix;
	}
	if(planes & PYEL)	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
			*src++=*y++;
		src+=adpix;
		y+=dadpix;
	}
	if(planes & PBLACK)
	{
		/* Srcadressen */
		c=dd->c+sadd;
		m=dd->m+sadd;
		y=dd->y+sadd;
		for(ry=bd->h; ry; --ry)
		{
			for(rx=bd->w; rx; --rx)
			{
				op=*c++; if(*m < op) op=*m; if(*y < op) op=*y;
				++m; ++y;
				*src++=op;
			}
			src+=adpix;
			c+=dadpix; m+=dadpix; y+=dadpix;
		}
	}
}


/* 
*********************
* Palette Functions *
*********************
*/


void con_set_grey_pal(int mode)
{/* mode=0: pal[0]=white, pal[255]=black
		mode=1: pal[0]=black, pal[255]=white
	*/
	int ix;
	
	switch(mode)
	{
		case 0:
			for(ix=255; ix>=0; --ix)
				grey_pal[ix]=gc_pal[ix][0]=gc_pal[ix][1]=gc_pal[ix][2]=ix;
		break;
		case 1:
			for(ix=255; ix>=0; --ix)
				grey_pal[ix]=gc_pal[ix][0]=gc_pal[ix][1]=gc_pal[ix][2]=255-ix;
		break;
	}
}

void pal_to_grey(int num)
{/* Rechnet die num ersten Eintr„ge in Graustufen um */
 /* Ergebnis in grey_pal */
 int a;
 unsigned int mr,mg,mb,mc;

	for(a=0; a < num; ++a)
	{
		mr=255-gc_pal[a][0];
		mg=255-gc_pal[a][1];
		mb=255-gc_pal[a][2];
		/* RGB->Grey Hibyte(77*R+151*G+28*B) */
		mc=77*mr+151*mg+28*mb;
		mc=mc >> 8;
		grey_pal[a]=(unsigned char)255-mc;
	}
}