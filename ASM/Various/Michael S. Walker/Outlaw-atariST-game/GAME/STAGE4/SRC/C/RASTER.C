#include <RASTER.H>
#include <TYPES.H>
#include <MODEL.H>
#include <UTIL.H>
#include <FONT.H> /* for PlotChar */

void PlotChar(const void *base, int x0, int y0, uint8_t bm)
{
	register uint8_t *ch;
	register int i, row_offset, col_offset;
	register uint8_t *bp = (uint8_t *)base;

	if (IS_PRINTABLE(bm))
		ch = GLYPH_START(bm);
	else
		return;

	col_offset = (640 >> 3);
	row_offset = (x0 >> 3);
	for (i = 0; i < FONT_HEIGHT; i++)
		bp[((y0 + i) * col_offset) + row_offset] = ch[i];
}

void Rast8Clear(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint8_t *bp = (uint8_t *)base; /* store the address of the frame buffer */

	register int col_align = aligntonext(sprite->x_pos, 3); /* align x and y */
	register int row_align = aligntonext(sprite->y_pos, 3);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS); /* this should never happen */
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 3;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT8_OFFSET(i + sprite->y_pos, col); /* store loc x,y in loc */
		bp[loc] = 0;								/* clear the bits at loc loc */
	}
}

void Rast8Alpha(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;

	register uint8_t *bp = (uint8_t *)base; /* store the address of the frame buffer */
	register uint8_t *img = (uint8_t *)sprite->bitmap.current_image;

	register int col_align = aligntonext(sprite->x_pos, 3); /* align x and y */
	register int row_align = aligntonext(sprite->y_pos, 3);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS); /* if x or y not in bounds, correct */
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 3;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT8_OFFSET(i + sprite->y_pos, col); /* store loc x,y in loc */
		bp[loc] ^= img[i];							/* set the bits at loc loc */
	}
}

void Rast8Draw(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;

	register uint8_t *bp = (uint8_t *)base; /* store the address of the frame buffer */
	register uint8_t *img = (uint8_t *)sprite->bitmap.current_image;

	register int col_align = aligntonext(sprite->x_pos, 3); /* align x and y */
	register int row_align = aligntonext(sprite->y_pos, 3);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS); /* if x or y not in bounds, correct */
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 3;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT8_OFFSET(i + sprite->y_pos, col); /* store loc x,y in loc */
		bp[loc] |= img[i];							/* set the bits at loc loc */
	}
}

void Rast16Clear(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint16_t *bp = (uint16_t *)base;

	register int col_align = aligntonext(sprite->x_pos, 4);
	register int row_align = aligntonext(sprite->y_pos, 4);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS);
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 4;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT16_OFFSET(i + sprite->y_pos, col);
		bp[loc] = 0;
	}
}

void Rast16Alpha(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint16_t *bp = (uint16_t *)base;
	register uint16_t *img = (uint16_t *)sprite->bitmap.current_image;

	register int col_align = aligntonext(sprite->x_pos, 4);
	register int row_align = aligntonext(sprite->y_pos, 4);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS);
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 4;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT16_OFFSET(i + sprite->y_pos, col);
		bp[loc] ^= img[i];
	}
}

void Rast16Draw(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint16_t *bp = (uint16_t *)base;
	register uint16_t *img = (uint16_t *)sprite->bitmap.current_image;

	register int col_align = aligntonext(sprite->x_pos, 4);
	register int row_align = aligntonext(sprite->y_pos, 4);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS);
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 4;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT16_OFFSET(i + sprite->y_pos, col);
		bp[loc] |= img[i];
	}
}

void Rast32Clear(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint32_t *bp = (uint32_t *)base;

	register int col_align = aligntonext(sprite->x_pos, 5);
	register int row_align = aligntonext(sprite->y_pos, 5);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS - 16);
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 5;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT32_OFFSET(i + sprite->y_pos, col);
		bp[loc] = 0;
	}
}

void Rast32Draw(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint32_t *bp = (uint32_t *)base;
	register uint32_t *img = (uint32_t *)sprite->bitmap.current_image;

	register int col_align = aligntonext(sprite->x_pos, 5);
	register int row_align = aligntonext(sprite->y_pos, 5);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS - 16);
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 5;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT32_OFFSET(i + sprite->y_pos, col);
		bp[loc] |= img[i];
	}
}

void Rast32Alpha(const void *base, Sprite *sprite)
{
	unsigned int i, loc, col;
	register uint32_t *bp = (uint32_t *)base;
	register uint32_t *img = (uint32_t *)sprite->bitmap.current_image;

	register int col_align = aligntonext(sprite->x_pos, 5);
	register int row_align = aligntonext(sprite->y_pos, 5);

	sprite->y_pos = WrapInteger(row_align, 0, SCREEN_HEIGHT_NBITS - 16);
	sprite->x_pos = WrapInteger(col_align, 0, SCREEN_WIDTH_NBITS);

	col = sprite->x_pos >> 5;
	for (i = 0; i < sprite->bitmap.height; i++)
	{
		loc = UINT32_OFFSET(i + sprite->y_pos, col);
		bp[UINT32_OFFSET(i + sprite->y_pos, col)] ^= img[i];
	}
}

void PLotRectangle(const void *base, int length, int width, int x_pos, int y_pos)
{
	int x0 = x_pos;
	int xf = x0 + width;
	int y0 = y_pos;
	int yf = y_pos + length;

	PlotVline(base, x0, y0, yf);
	PlotVline(base, xf, y0, yf);
	PlotHline(base, y0, x0, xf);
	PlotHline(base, yf, x0, xf);
}

void PlotVline(const void *base, int x0, int y0, int yf)
{
	int i;
	yf = aligntonext(yf, 3); /* word align points */
	y0 = aligntonext(y0, 3);
	x0 = aligntonext(x0, 3);

	TrimLine(&x0, 0, 640); /* keep in boundary */
	TrimLine(&y0, 0, 400);
	TrimLine(&yf, 0, 400);

	if (y0 == yf)
	{
		PlotPoint((unsigned char *)base, x0, y0);
		return;
	}

	if (y0 > yf)
	{ /* swap */
		y0 ^= yf;
		yf ^= y0;
		y0 ^= yf;
	}

	for (i = y0; i < yf; i += N_BITS_IN_WORD)
		Plot8Pixels((unsigned char *)base, x0, i); /* draw the line */
}

void PlotHline(const void *base, int y0, int x0, int xf)
{
	int i, offset;

	unsigned char *b8 = (unsigned char *)base;

	y0 = aligntonext(y0, 3); /* word align points */
	x0 = aligntonext(x0, 3);
	xf = aligntonext(xf, 3);

	TrimLine(&y0, 0, 400); /* keep in boundary */
	TrimLine(&x0, 0, 640);
	TrimLine(&xf, 0, 640);

	if (x0 == xf)
	{
		PlotPoint((unsigned char *)base, x0, y0);
		return;
	}

	if (x0 > xf)
	{ /* swap */
		x0 ^= xf;
		xf ^= x0;
		x0 ^= xf;
	}

	for (i = x0; i < xf; i++)
	{ /* draw line 8 bits at a time */
		offset = (y0 * 80) + (i >> 3);
		b8[offset] |= 0xff;
	}
}

void PlotPoint(unsigned char *base, int x, int y)
{
	int offset = (y * 80) + (x >> 3);
	base[offset] |= 0x80;
}

void Plot8Pixels(unsigned char *base, int x, int y)
{
	int i, offset;
	x >>= 3;

	for (i = 0; i < 8; i++)
	{
		offset = ((y + i) * 80) + (x);
		base[offset] |= 0x80;
	}
}

void PrintScreen(void *base, Sprite *sprite)
{
	register int row;
	register uint32_t *bp = (uint32_t *)base;
	register uint32_t *bm = (uint32_t *)sprite->bitmap.current_image;

	for (row = 0; row < sprite->bitmap.height; row++)
		bp[row] |= bm[row];
}
