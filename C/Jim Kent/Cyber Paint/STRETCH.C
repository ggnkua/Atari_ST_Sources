
#include "flicker.h"


free_byte_cel(b)
register Byte_cel *b;
{
if (b == NULL)
	return;
freemem(b->image);
Free_a(b);
}


Byte_cel *
cel_to_byte(c)
register Cel *c;
{
register Byte_cel *b;
unsigned char *bpt;
char *image;
WORD i;
WORD pixels16;
WORD line_bytes;

if ((b = Alloc_a(Byte_cel)) == NULL)
	return(NULL);

/* force it to even width */
b->width = c->width;
i = b->height = c->height;
b->xoff = c->xoff;
b->yoff = c->yoff;
b->image_size  = b->line_bytes = ((c->width + 15)&0xfff0);	
b->image_size *= b->height;
copy_words(c->cmap, b->cmap, COLORS);
if ( (bpt = b->image = (unsigned char *)laskmem(b->image_size)) == NULL)
	{
	Free_a(b);
	return(NULL);
	}
image = (char *)c->image;
line_bytes = Raster_line(c->width);
pixels16 = line_bytes>>3;
while (--i >= 0)
	{
	word_zero(bpt, b->width/sizeof(WORD) );
	conv_buf(image, bpt, pixels16);
	image += line_bytes;
	bpt += b->line_bytes;
	}
return(b);
}


Cel *
stretch_byte_cel(b, new_width, new_height)
Byte_cel *b;
WORD new_width; 
register WORD new_height;
{
register Cel *c;
WORD *tbuf;
WORD tb_size;
unsigned char *pixel_buf;
unsigned char *bpt;
unsigned char *image;
WORD pb_size;
WORD line_bytes;	/* on Cel to return */
WORD pixels16;
WORD j;
register WORD error, old_height;
register WORD last_again;

/* allocate index table for stretch ... contains array of indexes into source
   which correspond to this place in dest */
tb_size = new_width*sizeof(WORD);
if ((tbuf = (WORD *)askmem(tb_size)) == NULL)
	{
	return(NULL);
	}
stretcht(tbuf, b->width, new_width); /* and fill in table */

/* allocate a byte-a-pixel destination buffer for stretch */
pb_size = ((new_width+15)&0xfff0);
if ((pixel_buf = (unsigned char *)askmem(pb_size) ) == NULL)
	{
	freemem(tbuf);
	return(NULL);
	}
word_zero(pixel_buf, pb_size/sizeof(WORD) ); /* and zero out end especially */

/* allocate the cel to return this all in */
if ((c = alloc_cel(new_width, new_height)) == NULL)
	{
	freemem(tbuf);
	freemem(pixel_buf);
	return(NULL);
	}
c->xoff = b->xoff;
c->yoff = b->yoff;
line_bytes = Raster_line(new_width);
pixels16 = (line_bytes>>3);
bpt = b->image;
j = new_height;
image = (unsigned char *)c->image;
old_height = b->height;
last_again = 0;
if (old_height < new_height)
	{
	error = (old_height>>1) - new_height;
	}
else
	{
	error = -1;
	old_height -= 1;
	if (old_height <= 0)
		old_height = 1;
	new_height -= 1;
	if (new_height <= 0)
		new_height = 1;
	}

/* the following bit of code was lifted from machine language in stretcht.asm 
   which is maybe why it looks less like C than macro assembler... */

incdest:
	if (--j < 0)				/* hit the dest j = new_height # of times  */
		goto end_ystretch;
	if (!last_again)			/* see if this line is clone of last... */
		{
		xlookup(bpt, pixel_buf, tbuf, new_width);
		iconv_buf(pixel_buf, image, pixels16);
		last_again = 1;
		}
	else
		{
		copy_words(image - line_bytes, image, line_bytes>>1);
		}
	image += line_bytes;
	if ((error += old_height) < 0)
		goto incdest;
incsource:
	bpt += b->line_bytes;
	last_again = 0;
	if ((error -= new_height) >= 0)
		goto incsource;
	goto incdest;
end_ystretch:

freemem(tbuf);
freemem(pixel_buf);
if (!mask_cel(c))
	{
	free_cel(c);
	return(NULL);
	}
copy_words(b->cmap, c->cmap, COLORS);
return(c);
}


