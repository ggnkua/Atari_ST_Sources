/* gifcode.c - GIF encoder/decoder routines. */

#include <stdio.h>
#include <string.h>

#include "uffile.h"
#include "gifcode.h"

static void
init_coder(gc,ff,datasize)
GIF_CODER *gc; FFILE *ff; int datasize;
{
	int c;

	gc->ff = ff;
	gc->curblocksize = gc->curblockpos = 0;
	gc->nbits = 0;
	gc->bits = 0L;
	gc->datasize = datasize;
	gc->clear = (1<<datasize);
	gc->eoi = gc->clear+1;
	for (c=0; c<gc->clear; c++) {
		gc->prefix[c] = -1;
		gc->suffix[c] = c;
	}
}

static void
reset_codesize(gc)
GIF_CODER *gc;
{
	gc->codesize = gc->datasize+1;
	gc->codemask = (1<<gc->codesize)-1;
	gc->avail = gc->eoi+1;
}

static void
inc_codesize(gc)
GIF_CODER *gc;
{
	gc->codesize++;
	gc->codemask = (1<<gc->codesize)-1;
}

static void
clear_encoder(gc)
GIF_CODER *gc;
{
	reset_codesize(gc);
	memset(gc->u.e.sl_ptr,0,GIF_MAXCODES*sizeof(int));
	gc->u.e.sl_index = 1;
}

static void
clear_decoder(gc)
GIF_CODER *gc;
{
	reset_codesize(gc);
	gc->u.d.prevc = -1;
}

void
gif_start_encoding(gc,ff,datasize)
GIF_CODER *gc; FFILE *ff; int datasize;
{
	init_coder(gc,ff,datasize);
	clear_encoder(gc);
	gc->u.e.curprefix = -1;
}

static int
putcurblock(gc)
GIF_CODER *gc;
{
	if (ff_putc(gc->curblocksize,gc->ff)==EOF
		|| ff_write(gc->curblock,gc->curblocksize,gc->ff)!=gc->curblocksize)
		return -1;
	gc->curblocksize = 0;
	return 0;
}

static int
putcode(c,gc)
int c; GIF_CODER *gc;
{
	gc->bits |= (((long)(c&gc->codemask))<<gc->nbits);
	gc->nbits += gc->codesize;
	while (gc->nbits >= 8) {
		gc->curblock[gc->curblocksize++] = (gc->bits&0xFF);
		gc->bits >>= 8;
		gc->nbits -= 8;
		if (gc->curblocksize==254 && putcurblock(gc)<0)
			return -1;
	}
	return 0;
}

static int
end_putcode(gc)
GIF_CODER *gc;
{
	if (putcode(gc->eoi,gc) < 0)
		return -1;
	if (gc->nbits > 0)
		gc->curblock[gc->curblocksize++] = (gc->bits&0xFF);
	if (gc->curblocksize>0 && putcurblock(gc)<0)
		return -1;
	if (ff_putc(0,gc->ff) == EOF)
		return -1;
	return 0;
}

static int
getcode(gc)
GIF_CODER *gc;
{
	int size,c;

	while (gc->nbits < gc->codesize) {
		if (gc->curblockpos < gc->curblocksize) {
			gc->bits |= (((long)gc->curblock[gc->curblockpos++])<<gc->nbits);
			gc->nbits += 8;
		} else if ((size=ff_getc(gc->ff))==EOF || size==0
			|| ff_read(gc->curblock,size,gc->ff)!=size)
			return -1;
		else {
			gc->curblocksize = size;
			gc->curblockpos = 0;
		}
	}
	c = (int)(gc->bits&gc->codemask);
	gc->bits >>= gc->codesize;
	gc->nbits -= gc->codesize;
	return c;
}

static int
end_getcode(gc)
GIF_CODER *gc;
{
	int size;

	if (gc->curblockpos == gc->curblocksize) {
		if ((size=ff_getc(gc->ff)) == 0)
			return 0;
		else if (size==EOF || ff_read(gc->curblock,size,gc->ff)!=size)
			return -1;
		else {
			gc->curblocksize = size;
			gc->curblockpos = 0;
		}
	}
	if (getcode(gc) != gc->eoi)
		return -1;
	if (ff_getc(gc->ff) == 0)
		return 0;
	else
		return -1;
}

static int
check_codetable(gc,c)
GIF_CODER *gc; int c;
{
	int ind;

	ind = gc->u.e.sl_ptr[gc->u.e.curprefix];
	while (ind != 0)
		if (c == gc->u.e.sl_suffix[ind])
			return gc->u.e.sl_newprefix[ind];
		else
			ind = gc->u.e.sl_next[ind];
	return -1;
}

static void
add_to_codetable(gc,newc)
GIF_CODER *gc; int newc;
{
	int ind;

	ind = gc->u.e.sl_index++;
	gc->u.e.sl_next[ind] = gc->u.e.sl_ptr[gc->prefix[newc]];
	gc->u.e.sl_ptr[gc->prefix[newc]] = ind;
	gc->u.e.sl_suffix[ind] = gc->suffix[newc];
	gc->u.e.sl_newprefix[ind] = newc;
}

int
gif_encode_c(c,gc)
int c; GIF_CODER *gc;
{
 	int newpref,newc;

	if (gc->u.e.curprefix < 0) {
		gc->u.e.curprefix = c;
		return putcode(gc->clear,gc);
	} else if ((newpref=check_codetable(gc,c)) >= 0) {
		gc->u.e.curprefix = newpref;
		return 0;
	}
	newc = gc->avail++;
	gc->prefix[newc] = gc->u.e.curprefix;
	gc->suffix[newc] = c;
	add_to_codetable(gc,newc);
	if (putcode(gc->u.e.curprefix,gc) < 0)
		return -1;
	gc->u.e.curprefix = c;
	if (gc->avail == GIF_MAXCODES) {
		if (putcode(gc->clear,gc) < 0)
			return -1;
		clear_encoder(gc);
	} else if (gc->codemask < newc)
		inc_codesize(gc);
	return 0;
}

int
gif_end_encoding(gc)
GIF_CODER *gc;
{
	if ((gc->u.e.curprefix>=0 && putcode(gc->u.e.curprefix,gc)<0)
		|| end_putcode(gc)<0)
		return -1;
	else
		return 0;
}

void
gif_start_decoding(gc,ff,datasize)
GIF_CODER *gc; FFILE *ff; int datasize;
{
	int c;

	init_coder(gc,ff,datasize);
	clear_decoder(gc);
	for (c=0; c<gc->clear; c++)
		gc->u.d.first[c] = c;
	gc->u.d.csttop = 0;
}

int
gif___f_decode_c(gc)
GIF_CODER *gc;
{
	int c,newc;

	for (;;) {
		if (gc->u.d.csttop > 0)
			return gc->u.d.cstack[--gc->u.d.csttop];
		else if ((c=getcode(gc))<0 || c==gc->eoi || gc->avail<c)
			return -1;
		else if (c == gc->clear)
			clear_decoder(gc);
		else {
			if (gc->u.d.prevc>=0 && gc->avail<GIF_MAXCODES) {
				newc = gc->avail++;
				gc->prefix[newc] = gc->u.d.prevc;
				gc->u.d.first[newc] = gc->u.d.first[gc->u.d.prevc];
				gc->suffix[newc] = gc->u.d.first[c];
				if (gc->codemask<gc->avail && gc->avail<GIF_MAXCODES)
					inc_codesize(gc);
			}
			if (c == gc->avail)
				return -1;
			gc->u.d.prevc = c;
			do {
				gc->u.d.cstack[gc->u.d.csttop++] = gc->suffix[c];
				c = gc->prefix[c];
			} while (c >= 0);
		}
	}
}

int
gif_end_decoding(gc)
GIF_CODER *gc;
{
	if (end_getcode(gc) < 0)
		return -1;
	else
		return 0;
}
