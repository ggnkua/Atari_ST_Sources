
overlay "reader"

#include "..\\include\\lists.h"
#include "..\\include\\raster.h"
#include "..\\include\\poly.h"
#include "..\\include\\format.h"
#include "..\\include\\color.h"
#include "..\\include\\acts.h"
#include "..\\include\\script.h"


struct raster_list *raster_master = NULL;

#ifdef EDITOR

#ifdef ATARI

struct atari_cel *
scale_ibits_by_4(source)
struct atari_cel *source;
{
struct atari_cel *dest;
int i, j;
register WORD *sp, *dp;
WORD *slinep, *dlinep;
register unsigned WORD smask, dmask;

if ((dest = init_atari_cel(source->width>>2, source->height>>2)) == NULL)
	return(NULL);
i = dest->height;
slinep = source->form;
dlinep = dest->form;
while (--i >= 0)
	{
	sp = slinep;
	dp = dlinep;
	j = dest->width;
	smask = 0x8000;
	dmask =  0x8000;
	while (--j >= 0)
	{
	if ( sp[0] & smask)
		dp[0] |= dmask;
	if ( sp[1] & smask)
		dp[1] |= dmask;
	if ( sp[2] & smask)
		dp[2] |= dmask;
	if ( sp[3] & smask)
		dp[3] |= dmask;
	if ((smask>>=4) == 0)
		{
		smask = 0x8000;
		sp += 4;
		}
	if ((dmask>>= 1) == 0)
		{
		dmask = 0x8000;
		dp += 4;
		}
	}
	slinep += (source->nxln<<1);
	dlinep += (dest->nxln>>1);
	}
add_mask_to_cel(dest);
return(dest);
}
#endif ATARI

#ifdef SUN
scale_bytes_by_4( plane_in, word_in, height_in, plane_out, word_out, height_out)
WORD *plane_in;
WORD word_in;
WORD height_in;
WORD **plane_out;
WORD *word_out, *height_out;
{
register WORD *line_in, *line_out;
register char *src_pt, *dest_pt;
register WORD dest_words;
WORD dest_height;
WORD i,j;
register WORD src_word, dest_word;

*word_out = dest_words = (word_in + 3)/4;
*height_out = dest_height = height_in/4;
*plane_out = line_out = (WORD *)alloc(dest_words * dest_height
	* sizeof(WORD) );
line_in = plane_in;
i = dest_height;
while (--i >= 0)
	{
	src_pt = (char *)line_in;
	dest_pt = (char *)line_out;
	j = dest_words<<1;
	while (--j >= 0)
	{
	*dest_pt++ = *src_pt;
	src_pt += 4;
	}
	line_out += dest_words;
	line_in += (word_in << 2);
	}
}
#endif SUN

scale_bits_by_4( plane_in, word_in, height_in, plane_out, word_out, height_out)
WORD *plane_in;
WORD word_in;
WORD height_in;
WORD **plane_out;
WORD *word_out, *height_out;
{
register WORD *line_in, *line_out;
register WORD *src_pt, *dest_pt;
register WORD dest_words;
WORD dest_height;
WORD i,j;
register WORD src_word, dest_word;

*word_out = dest_words = (word_in + 3)/4;
*height_out = dest_height = height_in/4;
*plane_out = line_out = (WORD *)ralloc(dest_words * dest_height
	* sizeof(WORD) );
line_in = plane_in;
i = dest_height;
while (--i >= 0)
	{
	src_pt = line_in;
	dest_pt = line_out;
	j = word_in>>2;
	while (--j >= 0)
	{
	dest_word = 0;
	src_word = *src_pt++;
	if (src_word & (1<<15) )
		dest_word |= (1<<15);
	if (src_word & (1<<11) )
		dest_word |= (1<<14);
	if (src_word & (1<<7) )
		dest_word |= (1<<13);
	if (src_word & (1<<3) )
		dest_word |= (1<<12);

	src_word = *src_pt++;
	if (src_word & (1<<15) )
		dest_word |= (1<<11);
	if (src_word & (1<<11) )
		dest_word |= (1<<10);
	if (src_word & (1<<7) )
		dest_word |= (1<<9);
	if (src_word & (1<<3) )
		dest_word |= (1<<8);

	src_word = *src_pt++;
	if (src_word & (1<<15) )
		dest_word |= (1<<7);
	if (src_word & (1<<11) )
		dest_word |= (1<<6);
	if (src_word & (1<<7) )
		dest_word |= (1<<5);
	if (src_word & (1<<3) )
		dest_word |= (1<<4);

	src_word = *src_pt++;
	if (src_word & (1<<15) )
		dest_word |= (1<<3);
	if (src_word & (1<<11) )
		dest_word |= (1<<2);
	if (src_word & (1<<7) )
		dest_word |= (1<<1);
	if (src_word & (1<<3) )
		dest_word |= (1<<0);
	*dest_pt++ = dest_word;
	}
	j = word_in & 3;
	if (j)
	{
	dest_word = 0;
	src_word = *src_pt++;
	if (src_word & (1<<15) )
		dest_word |= (1<<15);
	if (src_word & (1<<11) )
		dest_word |= (1<<14);
	if (src_word & (1<<7) )
		dest_word |= (1<<13);
	if (src_word & (1<<3) )
		dest_word |= (1<<12);

	if (j>1)
		{
		src_word = *src_pt++;
		if (src_word & (1<<15) )
		dest_word |= (1<<11);
		if (src_word & (1<<11) )
		dest_word |= (1<<10);
		if (src_word & (1<<7) )
		dest_word |= (1<<9);
		if (src_word & (1<<3) )
		dest_word |= (1<<8);
		}
	if (j>2)
		{
		src_word = *src_pt++;
		if (src_word & (1<<15) )
		dest_word |= (1<<7);
		if (src_word & (1<<11) )
		dest_word |= (1<<6);
		if (src_word & (1<<7) )
		dest_word |= (1<<5);
		if (src_word & (1<<3) )
		dest_word |= (1<<4);
		}
	*dest_pt = dest_word;
	}
	line_out += dest_words;
	line_in += (word_in << 2);
	}
}


free_rm_scales()
{
register struct raster_list *rl = raster_master;
while (rl)
	{
	free_a_raster(rl->scaled, rl->type);
	rl->scaled = NULL;
	rl = rl->next;
	}
}


scale_rm_by_4()
{
register struct raster_list *rl = raster_master;
register RASTER_POINTER raster;
WORD i;

while (rl)
	{
	if (rl->scaled)
	free_a_raster(rl->scaled, rl->type);
	raster = (RASTER_POINTER)rl->raster;
	switch(rl->type)
	{
	case BITPLANE_RASTER:
		{
		register struct bit_plane *bp;
		bp = (struct bit_plane *)
		clone_zero(sizeof( struct bit_plane) );
		rl->scaled = (RASTER_POINTER)bp;
		scale_bits_by_4( 
		((struct bit_plane *)raster)->plane,
		((struct bit_plane *)raster)->words_per_line,
		((struct bit_plane *)raster)->height,
		&(bp->plane),
		&(bp->words_per_line),
		&(bp->height));
		bp->width = ((struct bit_plane *)raster)->width / 4;
		}
		break;
#ifdef AMIGA
	case AMIGA_BITMAP:
		{
		register struct BitMap *bp;
		WORD words_per_line;

		bp = (struct BitMap *)
		clone_structure(raster, sizeof( struct BitMap) );
		rl->scaled = (RASTER_POINTER)bp;
		for (i=0; i<8; i++)
		{
		if (bp->Planes[i])
			scale_bits_by_4( 
			((struct BitMap *)raster)->Planes[i],
			((struct BitMap *)raster)->BytesPerRow>>1,
			((struct BitMap *)raster)->Rows,
			&(bp->Planes[i]),
			&words_per_line,
			&(bp->Rows));
		}
		bp->width = ((struct BitMap *)raster)->width / 4;
		bp->BytesPerRow = words_per_line<<1;
		}
		break;
#endif AMIGA
#ifdef ATARI
	case ATARI_CEL:
		rl->scaled = (RASTER_POINTER)scale_ibits_by_4(raster);
		break;
#endif ATARI
#ifdef SUN
	case BYPLANE_RASTER:
		{
		register struct byte_plane *bp;
		bp = (struct byte_plane *)
		clone_zero(sizeof( struct byte_plane) );
		rl->scaled = (RASTER_POINTER)bp;
		scale_bytes_by_4( 
		((struct byte_plane *)raster)->plane,
		((struct byte_plane *)raster)->words_per_line,
		((struct byte_plane *)raster)->height,
		&(bp->plane),
		&(bp->words_per_line),
		&(bp->height));
		bp->width = ((struct byte_plane *)raster)->width / 4;
		}
		break;
	case BYPLANE_STENCIL:
		break;
#endif SUN
	}
	rl = rl->next;
	}
}
#endif EDITOR

struct raster_list *
add_new_raster(raster, type, name, orgx, orgy)
RASTER_POINTER raster;
WORD type;
char *name;
WORD orgx, orgy;
{
register struct raster_list *new;

#ifdef DEBUG
printf("add_new_raster(%lx %d %s)\n", raster, type, name);
#endif DEBUG
new = (struct raster_list *)clone_zero(sizeof(struct raster_list) );
new->name = clone_string(name);
new->raster = raster;
new->type = type;
new->xoff = orgx;
new->yoff = orgy;
new->next = raster_master;
raster_master = new;
return(new);
}

#ifdef SLUFFED
add_text(name)
char *name;
{
struct text_stamp *stamp;
struct raster_list *new;

stamp = Alloc_a(struct text_stamp);
new = (struct raster_list *)clone_zero(sizeof(struct raster_list) );
stamp->string = new->name = clone_string(name);
stamp->width = string_width(name);
stamp->height = CHAR_HEIGHT;
new->raster = (RASTER_POINTER)stamp;
new->type = TEXT_WINDOW;
new->next = raster_master;
raster_master = new;
}
#endif SLUFFED

free_a_raster(raster, type)
RASTER_POINTER raster;
WORD type;
{
switch(type)
	{
#ifdef AMIGA
	case AMIGA_BITMAP:
		free_BitMap(raster);
		break;
#endif AMIGA
	case BITPLANE_RASTER:
		free_bit_plane(raster);
		break;
#ifdef SUN
	case BYPLANE_RASTER:
		free_byte_plane(raster);
		break;
	case BYPLANE_STENCIL:
		free_byte_bit_plane(raster);
		break;
#endif SUN
#ifdef ATARI
	case ATARI_CEL:
		free_atari_cel(raster);
		break;
#endif ATARI
	case TEXT_WINDOW:
		mfree(raster, sizeof(struct text_stamp) );
		break;	 
	case ANI_STRIP:
		rfree_s_sequence(raster, 0);
		break;
	}
}

clean_raster_master()
{
register struct raster_list *last, *this;

#ifdef DEBUG
ldprintf("\nclean_raster_master");
#endif DEBUG

while (raster_master)  /*first remove empties at head*/
	{
	if (raster_master->links < 1)
		{
		last = raster_master;
		raster_master = raster_master->next;
		free_string(last->name);
		free_a_raster(last->raster, last->type);
		free_a_raster(last->scaled, last->type);
		mfree(last, sizeof(struct raster_list) );
		}
	else
		break;
	}
	
if ( !(last = raster_master) )
	{
	return; 		 /*cleaned from head on down, now nothing left*/
	}
this = last->next;
while (this)		/*free raster, and delink from list*/
	{	
	if ( this->links < 1)
		{
		free_string(this->name);
		free_a_raster(this->raster, this->type);
		free_a_raster(this->scaled, this->type);
		last->next = this->next;
		mfree(this, sizeof(struct raster_list) );
		this = last->next;
		}
	else
		{
		last = this;
		this = this->next;
		}
	}
}


unlink_rasters(list)
register Item_list *list;
{
register struct raster_list *raster;

#ifdef DEBUG
ldprintf("\nunlink_rasters(%lx)", list);
#endif DEBUG
while (list)
	{
	raster = (struct raster_list *)list->item;
	--(raster->links);
	list = list->next;
	}
}

link_script_rasters(script)
Script *script;
{
link_rasters(script->script_rasters);
}

link_rasters(list)
register Item_list *list;
{
register struct raster_list *raster;

#ifdef DEBUG
ldprintf("\nlink_rasters(%lx)", list);
#endif DEBUG

while (list)
	{
	raster = (struct raster_list *)list->item;
	(raster->links)++;
	list = list->next;
	}
}



#ifdef NEVER
link_script_rasters(script)
Script *script;
{
register Item_list *srasters;
register struct raster_list *raster;

#ifdef DEBUG
ldprintf("\nlink_script_rasters(%lx)", script);
#endif DEBUG
srasters = script->script_rasters;
while (srasters)
	{
	raster = (struct raster_list *)srasters->item;
	(raster->links)++;
	srasters = srasters->next;
	}
}
#endif NEVER

Item_list  *
remake_raster_list(script)
Script *script;
{
register Item_list *rasters = NULL;
struct tween **tweens, *tween;
register WORD **acts, *act;
register WORD i,j;
struct raster_list *rl;

#ifdef DEBUG
ldprintf("\remake_raster_list(%lx)", script);
#endif DEBUG

tweens = script->tween_list;
i = script->tween_count;
while (--i >= 0)
	{
	tween = *tweens++;
	acts = tween->act_list;
	j = tween->act_count;
	while (--j>=0)
		{
		act = *acts++;
		switch ( act[1] )
			{
			case INSERT_RASTER:
			case INSERT_STENCIL:
			rasters = or_in_item( *( (RASTER_POINTER *)(act+3)),
				rasters);
			break;
			case INSERT_STRIP:
			rasters = or_in_item( 
				in_name_list(
				script->child_scripts[act[3]]->name, raster_master),
				rasters);
			break;
			}
		}
	}
return(rasters);
}

#ifdef ATARI
add_mask_to_cel(cel)
struct atari_cel *cel;
{
register int length_plane;
register WORD *s, *d;

length_plane = ((cel->nxln * cel->height )>>2);
if ((d = cel->mask = (WORD *)alloc(length_plane)) == NULL)
	return(0);
s = cel->form;
length_plane >>= 1;
while (--length_plane >= 0)
	*d++ = ~(*s++ | *s++ | *s++ | *s++);
return(1);
}
#endif ATARI

#ifdef AMIGA
BitMap_to_cel(bitmap)
register struct BitMap *bitmap;
{
register int length_plane;
register WORD i;

length_plane = bitmap->BytesPerRow * bitmap->Rows;
if (!bitmap->Planes[7])
	{
	bitmap->Planes[7] = (WORD *)ralloc(length_plane);
	}
if (bitmap->Planes[7])
	{
	block_stuff(bitmap->Planes[7], 0, length_plane);
	for (i=0; i<bitmap->Depth; i++)
	or_structure(bitmap->Planes[i], bitmap->Planes[7], length_plane);
	}
}
#endif AMIGA

#ifdef SUN
/*makes a byte_bit_plane from byte_plane.  Eats byte_plane in process */
struct byte_bit_plane *
byte_bit_from_byte(byte_plane)
struct byte_plane *byte_plane;
{
register struct byte_bit_plane *bbp;

bbp = (struct byte_bit_plane *)clone_structure(byte_plane,
	sizeof(struct byte_bit_plane) );
if (bbp)
	{
	bbp->swords_per_line = (bbp->width + 15)/16;
	bbp->stencil = (WORD *)ralloc(
		bbp->swords_per_line * bbp->height * sizeof(WORD) );
	if (bbp->stencil)
		{
		make_stencil( bbp->plane, bbp->stencil, bbp->width, bbp->height,
			bbp->words_per_line, bbp->swords_per_line);
		}
	else
		{
		rfree( bbp->plane, bbp->words_per_line * bbp->height * sizeof(WORD) );
		mfree( bbp, sizeof(struct byte_bit_plane) );
		bbp = NULL;
		}
	}
else
	rfree( byte_plane->plane,
	byte_plane->words_per_line * byte_plane->height * sizeof(WORD) );
mfree(byte_plane, sizeof(struct byte_plane) );
return(bbp);
}

make_stencil(source, dest, width, height, smod, dmod)
register char *source;
register WORD *dest;
WORD width, height;
WORD smod, dmod;
{
register WORD i, j;
register unsigned WORD bitmask;
register char *sline;
register WORD *dline;

smod *= 2;  /*since treating source as byte not word array */
block_stuff( dest, 0, dmod * height * sizeof(WORD) );
i = height;
while (--i >= 0)
	{
	sline = source;
	dline = dest;
	j = width;
	bitmask = 1<<15;
	while (--j >= 0)
	{
	if ( *sline++)
		*dline |= bitmask;
	bitmask >>= 1;
	if ( !bitmask)
		{
		bitmask = 1<<15;
		dline++;
		}
	}
	source += smod;
	dest += dmod;
	}
}
#endif SUN

#ifdef ATARI
free_atari_cel(cel)
struct atari_cel *cel;
{
if (cel)
	{
	if (cel->mask)
	mfree(cel->mask, (cel->nxln*cel->height)>>2);
	mfree(cel->form, cel->nxln * cel->height);
	Free_a(cel);
	}
}

struct atari_cel *
init_atari_cel(width, height)
register int width, height;
{
register struct atari_cel *cc;
register *form;
register int length;

#ifdef DEBUG 
printf("init_atari_cel(%d %d)\n", width, height);
#endif DEBUG

cc = Alloc_z(struct atari_cel);
if (cc)
	{
	cc->nxln = ((width+15)/16) * 2 * 4;
	cc->nxpl = 2;
	cc->nxwd = 8;
	cc->plane_ct = 4;
	length = cc->nxln * height;
	cc->width = width;
	cc->height = height;
	if ((cc->form = (WORD *)clone_zero(length)) == NULL)
	{
	Free_a(cc);
	return(NULL);
	}
	}
return(cc);
}
#endif ATARI

#ifdef AMIGA
struct BitMap *
init_BitMap(width, height, depth)
register int width , height ,depth;
{
register struct BitMap *bb;
register WORD i, *plane;
register int length;

bb = (struct BitMap *)clone_zero(sizeof(struct BitMap) );
if (bb)
	{
	bb->BytesPerRow = ((width+15)/16) * 2;
	length = bb->BytesPerRow * height;
	bb->Rows = height;
	bb->width = width;
	for (i=0; i<depth; i++)
	{
	plane = (WORD *)ralloc(length);
	if (!plane)
		{
		ldprintf("\ncan't alloc plane %d in init_BitMap(%d %d %d)",
		i, width, height, depth);
		if (i == 0)
		{
		mfree(bb, sizeof(struct BitMap) );
		return(NULL);
		}
		else
		plane = bb->Planes[i-1];
		}
	bb->Planes[i] = plane;
	bb->Depth++;
	}
	}
return(bb);
}
#endif AMIGA





#ifdef AMIGA
free_BitMap(bm)
register struct BitMap *bm;
{
register WORD i;
register int length;
register WORD *last_plane, *plane;

if (bm)
	{
	length = bm->BytesPerRow * bm->Rows;
	i = bm->Depth;
	last_plane = NULL;
	while (--i >= 0)
	{
	plane = bm->Planes[i];
	if ( plane != NULL && plane != last_plane)
		rfree( plane, length);
	last_plane = plane;
	}
	if (plane = bm->Planes[7])
	rfree(plane, length);
	mfree(bm, sizeof(struct BitMap) );
	}
}
#endif AMIGA

Bit_plane *
init_bit_plane(width, height)
int width, height;
{
register Bit_plane *bp;

bp = (Bit_plane *)alloc(sizeof(Bit_plane) );
if (bp)
	{
	bp->width = width;
	bp->height = height;
	bp->words_per_line = (width+15)/16;
#ifdef AMIGA
	bp->plane = (WORD *)
	ralloc( bp->words_per_line * bp->height * sizeof(WORD));
#endif AMIGA
#ifdef ATARI
	bp->plane = (WORD *)
	clone_zero(bp->words_per_line * bp->height * sizeof(WORD));
#endif ATARI
	if (!bp->plane)
		{
		mfree(bp, sizeof(Bit_plane) );
		return(NULL);
		}
	}
return(bp);
}

free_bit_plane(bp)
register Bit_plane *bp;
{
if (bp)
	{
	rfree(bp->plane,
		bp->words_per_line * bp->height * sizeof(WORD ) );
	mfree(bp, sizeof(Bit_plane) );
	}
}

#ifdef SUN
Byte_plane *
init_byte_plane(width, height)
int width, height;
{
register Byte_plane *bp;

bp = (Byte_plane *)alloc(sizeof(Byte_plane) );
if (bp)
	{
	bp->width = width;
	bp->height = height;
	bp->words_per_line = (width+1)/2;
	bp->plane = (WORD *)
	ralloc( bp->words_per_line * bp->height * sizeof(WORD));
	if (!bp->plane)
		{
		mfree(bp, sizeof(Byte_plane) );
		bp = NULL;
		}
	}
return(bp);
}
#endif SUN


#ifdef SUN
free_byte_plane(bp)
Bit_plane *bp;
{
#ifdef DEBUG
if (sizeof(Bit_plane) != sizeof(Byte_plane) )
	ldprintf("\nGOTCHA in free_byte_plane");
#endif DEBUG

free_bit_plane(bp);
}

free_byte_bit_plane(bp)
register struct byte_bit_plane *bp;
{
if (bp)
	{
	rfree(bp->plane,
		bp->words_per_line * bp->height * sizeof(WORD ) );
	rfree(bp->stencil,
		bp->swords_per_line * bp->height * sizeof(WORD ) );
	mfree(bp, sizeof(struct byte_bit_plane) );
	}
}

struct byte_plane *
dummy_byte_plane(name)
char *name;
{
register struct byte_plane *bm;
int width, height;

#ifdef DEBUG
ldprintf("\ndummy_byte_plane(%s)", name);
#endif DEBUG
width = string_width(name) + 2;
height = CHAR_HEIGHT+1;
bm = init_byte_plane(width, height);
if (bm)
	{
	set_draw_to_byteplane(bm);
	whipe_screen();
	gtext(name, 1, 1, 0);
	set_d2_front();
	}
return (bm);
}
#endif SUN

#ifdef AMIGA
struct BitMap *
dummy_BitMap(name)
char *name;
{
register struct BitMap *bm;
int width, height;

#ifdef DEBUG
ldprintf("\ndummy_BitMap(%s)", name);
#endif DEBUG
width = string_width(name) + 2;
height = CHAR_HEIGHT+1;
bm = init_BitMap(width, height, BITPLANES);
if (bm)
	{
	set_draw_to_BitMap(bm);
	whipe_screen();
	gtext(name, 1, 1, 0);
	set_d2_front();
	}
return (bm);
}
#endif AMIGA

#ifdef SLUFFED
struct atari_cel *
dummy_atari_cel(name)
char *name;
{
return(NULL);
}
#endif SLUFFED

#ifdef AMIGA
struct bit_plane *
dummy_bitplane(name)
char *name;
{
register struct bit_plane *bp;
int width;

width = string_width(name);

bp = init_bit_plane(width + 2, CHAR_HEIGHT + 2);
if (bp)
	{
	set_d2_bitplane(bp);
	whipe_screen();
	gtext(name, 1, 1, 0);
	set_d2_front();
	}
return (bp);
}
#endif SLUFFED

