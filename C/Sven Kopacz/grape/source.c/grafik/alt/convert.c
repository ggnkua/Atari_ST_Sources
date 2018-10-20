void c_incon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */
 
 /* WIE OBEN, IN C LANGSAMER  */
	long					 sadd, siz;
	uchar					 *mbuf;
	register uchar *c, *m, *y;
	register uchar *src1, *buf, bit;
	register uchar *pal=&(gc_pal[0][0]);
	register long	 spix, adpix, dadpix;
	register int	 rx, ry, rb;
	
	if(dd->mask)	mincon_8ip(mode, bd, dd);
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
		src1=bd->data+sadd*7;
	else
		src1=bd->data;

	/* Zeilenoffset Source */
	adpix=bd->lw-bd->w;
	/* Puffer holen */
  siz=(long)((long)(bd->w)*(long)(bd->h));
 	mbuf=buf=calloc(siz, 1);
  
  /* Jede Bitplane einzeln in Puffer kopieren */
	for(rb=0; rb < 8; ++rb)
	{	
		bit=1 << rb;
		spix=0;
		for(ry=bd->h; ry; --ry)
		{
			for(rx=bd->w; rx; --rx)
			{
				if(src1[spix>>3] & (1<<(7-(spix & 7)))) /* Bit gesetzt */
					*buf|=bit;
				++buf;
				++spix;
			}
			spix+=adpix;
		}
		if(mode)
			src1-=sadd;
		else
			src1+=sadd;
		buf=mbuf;
	}

	/* Puffer per Palette in Dest kopieren */
	for(ry=bd->h; ry; --ry)
	{
		for(rx=bd->w; rx; --rx)
		{
			rb=*buf++ *3;
			*c++=pal[rb];
			*m++=pal[rb+1];
			*y++=pal[rb+2];
		}
		c+=dadpix; m+=dadpix; y+=dadpix;
	}
	
	free(mbuf);
}

void oldincon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd)
{/* Source is 8 Bit Interleaved Planes, col=pal */
 /* mode=0: first bit=low bit, else first bit=high bit */
	long					 sadd;
	register uchar *c, *m, *y;
	register uchar *src1, *src2, *src3, *src4, *src5, *src6, *src7, *src8;
	register uchar *pal=&(gc_pal[0][0]);
	register long	 spix, adpix, dadpix;
	register int	 ry, rx;
	register int scol;
	
	if(dd->mask)	mincon_8ip(mode, bd, dd);
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
	counter=0;
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
show(counter);
}
