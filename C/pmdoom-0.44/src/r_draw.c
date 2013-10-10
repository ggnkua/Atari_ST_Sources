// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// $Log:$
//
// DESCRIPTION:
//	The actual span/column drawing functions.
//	Here find the main potential for optimization,
//	 e.g. inline assembly, different algorithms.
//
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <string.h>

#include "doomdef.h"

#include "i_system.h"
#include "z_zone.h"
#include "w_wad.h"

#include "r_local.h"

// Needs access to LFB (guess what).
#include "v_video.h"
#include "i_video.h"

// State.
#include "doomstat.h"

#include "st_stuff.h"

// ?
static int maxwidth=0, maxheight=0;

//
// All drawing to the view buffer is accomplished in this file.
// The other refresh files only know about ccordinates,
//  not the architecture of the frame buffer.
// Conveniently, the frame buffer is a linear one,
//  and we need only the base address,
//  and the total size == width*height*depth/8.,
//


byte*		viewimage; 
int		viewwidth;
int		scaledviewwidth;
int		viewheight;
int		viewwindowx;
int		viewwindowy; 
byte*		*ylookup=NULL; 
int		*columnofs=NULL; 

// Color tables for different players,
//  translate a limited part to another
//  (color ramps used for  suit colors).
//
byte		translations[3][256];	
 
 


//
// R_DrawColumn
// Source is the top of the column to scale.
//
lighttable_t*		dc_colormap; 
int			dc_x; 
int			dc_yl; 
int			dc_yh; 
fixed_t			dc_iscale; 
fixed_t			dc_texturemid;

// first pixel in a column (possibly virtual) 
byte*			dc_source;		

// just for profiling 
int			dccount;

//
// A column is a vertical slice/span from a wall texture that,
//  given the DOOM style restrictions on the view orientation,
//  will always have constant z depth.
// Thus a special case loop for very fast rendering can
//  be used. It has also been used with Wolfenstein 3D.
// 
void R_DrawColumn (void) 
{ 
	unsigned short		count; 
	byte*		dest; 
	fixed_t		frac;
	fixed_t		fracstep;	 

	// Zero length, column does not exceed a pixel.
    if (dc_yh < dc_yl) 
		return; 
				 
#ifdef RANGECHECK 
    if ((unsigned)dc_x >= sysvideo.width
	|| dc_yl < 0
	|| dc_yh >= sysvideo.height) 
	I_Error ("R_DrawColumn: %i to %i at %i", dc_yl, dc_yh, dc_x); 
#endif 

	count = dc_yh - dc_yl; 

    // Framebuffer destination address.
    // Use ylookup LUT to avoid multiply with ScreenWidth.
    // Use columnofs LUT for subwindows? 
    dest = ylookup[dc_yl] + columnofs[dc_x];  

    // Determine scaling,
    //  which is the only mapping to be done.
    fracstep = dc_iscale; 
    frac = dc_texturemid + (dc_yl-centery)*fracstep; 

    // Inner loop that does the actual texture mapping,
    //  e.g. a DDA-lile scaling.
    // This is as fast as it gets.
#if defined(__GNUC__) && (defined(__M68000__) || defined(__M68020__))
    __asm__ __volatile__ (
	"moveql	#127,d0\n"
"	swap	%1\n"
"	swap	%2\n"
"	moveql	#0,d1\n"
"	movew	%0,d2\n"	/* d2 = 3-(count&3) */
"	notw	d2\n"
"	andw	#3,d2\n"
"	lea		R_DrawColumn_loop,a0\n"
"	muluw	#R_DrawColumn_loop1-R_DrawColumn_loop,d2\n"
"	lsrw	#2,%0\n"
"	move	#4,ccr\n"
"	jmp		a0@(0,d2:w)\n"

"R_DrawColumn_loop:\n"
"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),%5@\n"
"	addw	%6,%5\n"

"R_DrawColumn_loop1:\n"
"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),%5@\n"
"	addw	%6,%5\n"

"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),%5@\n"
"	addw	%6,%5\n"

"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),%5@\n"
"	addw	%6,%5\n"

"	dbra	%0,R_DrawColumn_loop"
	 	: /* no return value */
	 	: /* input */
	 		"d"(count), "d"(fracstep), "d"(frac), "a"(dc_source),
			"a"(dc_colormap), "a"(dest), "a"(sysvideo.pitch)
	 	: /* clobbered registers */
	 		"d0", "d1", "d2", "d3", "a0", "cc", "memory" 
	);
#else
    do 
    {
	// Re-map color indices from wall texture column
	//  using a lighting/special effects LUT.
	*dest = dc_colormap[dc_source[(frac>>FRACBITS)&127]];
	
	dest += sysvideo.pitch; 
	frac += fracstep;
	
    } while (count--); 
#endif
} 


void R_DrawColumnLow (void) 
{ 
    unsigned short			count; 
    byte*		dest; 
    fixed_t		frac;
    fixed_t		fracstep;	 
 
    // Zero length.
    if (dc_yh < dc_yl) 
	return; 
				 
#ifdef RANGECHECK 
    if ((unsigned)dc_x >= sysvideo.width
	|| dc_yl < 0
	|| dc_yh >= sysvideo.height)
    {
	
	I_Error ("R_DrawColumn: %i to %i at %i", dc_yl, dc_yh, dc_x);
    }
    //	dccount++; 
#endif 
    // Blocky mode, need to multiply by 2.
/*    dc_x <<= 1;*/
    
    count = dc_yh - dc_yl; 

    dest = ylookup[dc_yl] + columnofs[dc_x<<1];
    
    fracstep = dc_iscale; 
    frac = dc_texturemid + (dc_yl-centery)*fracstep;
    
#if defined(__GNUC__) && (defined(__M68000__) || defined(__M68020__))
    __asm__ __volatile__ (
	"moveql	#127,d0\n"
"	swap	%1\n"
"	swap	%2\n"
"	moveql	#0,d1\n"

"	movew	%0,d2\n"
"	notw	d2\n"
"	andw	#3,d2\n"
"	lea		R_DrawColumnLow_loop,a0\n"
"	muluw	#R_DrawColumnLow_loop1-R_DrawColumnLow_loop,d2\n"
"	lsrw	#2,%0\n"
"	move	#4,ccr\n"
"	jmp		a0@(0,d2:w)\n"

"R_DrawColumnLow_loop:\n"
"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),d2\n"
"	moveb	d2,%5@+\n"
"	moveb	d2,%5@+\n"
"	addw	%6,%5\n"

"R_DrawColumnLow_loop1:\n"
"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),d2\n"
"	moveb	d2,%5@+\n"
"	moveb	d2,%5@+\n"
"	addw	%6,%5\n"

"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),d2\n"
"	moveb	d2,%5@+\n"
"	moveb	d2,%5@+\n"
"	addw	%6,%5\n"

"	andw	d0,%2\n"
"	moveb	%3@(0,%2:w),d1\n"
"	addxl	%1,%2\n"
"	moveb	%4@(0,d1:w),d2\n"
"	moveb	d2,%5@+\n"
"	moveb	d2,%5@+\n"
"	addw	%6,%5\n"

"	dbra	%0,R_DrawColumnLow_loop"
	 	: /* no return value */
	 	: /* input */
	 		"d"(count), "d"(fracstep), "d"(frac), "a"(dc_source),
			"a"(dc_colormap), "a"(dest), "a"(sysvideo.pitch-2)
	 	: /* clobbered registers */
	 		"d0", "d1", "d2", "d3", "a0", "cc", "memory" 
	);
#else
    do 
    {
		int spot;
	// Hack. Does not work corretly.
	spot =  dc_colormap[dc_source[(frac>>FRACBITS)&127]];
	*dest++ = spot;
	*dest++ = spot;
	
	dest += sysvideo.pitch-2;
	frac += fracstep; 

    } while (count--);
#endif
}


//
// Spectre/Invisibility.
//
#define FUZZTABLE		64 


int	fuzzoffset[FUZZTABLE] =
{
	 1,-1, 1,-1, 1, 1,-1, 1,
	 1, 1,-1, 1, 1, 1,-1,-1,
	 1, 1, 1,-1,-1,-1,-1, 1,
	 1,-1,-1, 1, 1, 1, 1,-1,
	 1,-1, 1, 1,-1,-1, 1, 1,
	 1,-1,-1,-1,-1, 1, 1,-1,
	 1, 1,-1, 1, 1,-1, 1, 1,
	-1, 1, -1, 1, 1, -1, -1
}; 

static int	fuzzpos = 0; 


//
// Framebuffer postprocessing.
// Creates a fuzzy image by copying pixels
//  from adjacent ones to left and right.
// Used with an all black colormap, this
//  could create the SHADOW effect,
//  i.e. spectres and invisible players.
//
void R_DrawFuzzColumn (void) 
{ 
    unsigned short		count; 
    byte*		dest; 
    fixed_t		frac;
    fixed_t		fracstep;	 

    // Adjust borders. Low... 
    if (!dc_yl) 
	dc_yl = 1;

    // .. and high.
    if (dc_yh == viewheight-1) 
	dc_yh = viewheight - 2; 
		 

    // Zero length.
    if (dc_yh < dc_yl) 
	return; 

    
#ifdef RANGECHECK 
    if ((unsigned)dc_x >= sysvideo.width
	|| dc_yl < 0 || dc_yh >= sysvideo.height)
    {
	I_Error ("R_DrawFuzzColumn: %i to %i at %i",
		 dc_yl, dc_yh, dc_x);
    }
#endif

    count = dc_yh - dc_yl; 

   
    // Does not work with blocky mode.
    dest = ylookup[dc_yl] + columnofs[dc_x];

    // Looks familiar.
    fracstep = dc_iscale; 
    frac = dc_texturemid + (dc_yl-centery)*fracstep; 

    // Looks like an attempt at dithering,
    //  using the colormap #6 (of 0-31, a bit
    //  brighter than average).
    do 
    {
	// Lookup framebuffer, and retrieve
	//  a pixel that is either one column
	//  left or right of the current one.
	// Add index from colormap to index.
	*dest = colormaps[6*256+dest[fuzzoffset[fuzzpos]*sysvideo.pitch]]; 

	// Clamp table lookup index.
	fuzzpos++;
	fuzzpos &= FUZZTABLE-1;
	
	dest += sysvideo.pitch;

	frac += fracstep; 
    } while (count--); 
} 

void R_DrawFuzzColumnLow (void) 
{ 
    unsigned short		count; 
    byte		*dest; 
    fixed_t		frac;
    fixed_t		fracstep;	 

    /*  Adjust borders. Low...  */
    if (!dc_yl) 
	dc_yl = 1;

    /*  .. and high. */
    if (dc_yh == viewheight-1) 
	dc_yh = viewheight - 2; 
		 

    /*  Zero length. */
    if (dc_yh < dc_yl) 
	return; 

    
#ifdef RANGECHECK 
    if ((unsigned)dc_x >= sysvideo.width
	|| dc_yl < 0 || dc_yh >= sysvideo.height)
    {
	I_Error ("R_DrawFuzzColumn: %i to %i at %i",
		 dc_yl, dc_yh, dc_x);
    }
#endif
    
    count = dc_yh - dc_yl; 

    /*  Does not work with blocky mode. */
    dest = ylookup[dc_yl] + columnofs[dc_x << 1];

    /*  Looks familiar. */
    fracstep = dc_iscale; 
    frac = dc_texturemid + (dc_yl-centery)*fracstep; 

    /*  Looks like an attempt at dithering, */
    /*   using the colormap #6 (of 0-31, a bit */
    /*   brighter than average). */
    do 
    {
	int spot;
	/*  Lookup framebuffer, and retrieve */
	/*   a pixel that is either one column */
	/*   left or right of the current one. */
	/*  Add index from colormap to index. */
	spot = colormaps[6*256+dest[fuzzoffset[fuzzpos]*sysvideo.pitch]]; 

	*dest++ = spot;
	*dest++ = spot;

	fuzzpos++;
	fuzzpos &= FUZZTABLE-1;
	
	dest += sysvideo.pitch-2;

	frac += fracstep; 
    } while (count--); 
}  
  
 

//
// R_DrawTranslatedColumn
// Used to draw player sprites
//  with the green colorramp mapped to others.
// Could be used with different translation
//  tables, e.g. the lighter colored version
//  of the BaronOfHell, the HellKnight, uses
//  identical sprites, kinda brightened up.
//
byte*	dc_translation;
byte*	translationtables;

void R_DrawTranslatedColumn (void) 
{ 
    unsigned short	count; 
    byte*		dest; 
    fixed_t		frac;
    fixed_t		fracstep;	 
 
    if (dc_yh < dc_yl) 
	return; 
				 
#ifdef RANGECHECK 
    if ((unsigned)dc_x >= sysvideo.width
	|| dc_yl < 0
	|| dc_yh >= sysvideo.height)
    {
	I_Error ( "R_DrawColumn: %i to %i at %i",
		  dc_yl, dc_yh, dc_x);
    }
    
#endif 

    count = dc_yh - dc_yl; 
    
    // FIXME. As above.
    dest = ylookup[dc_yl] + columnofs[dc_x]; 

    // Looks familiar.
    fracstep = dc_iscale; 
    frac = dc_texturemid + (dc_yl-centery)*fracstep; 

    // Here we do an additional index re-mapping.
    do 
    {
	// Translation tables are used
	//  to map certain colorramps to other ones,
	//  used with PLAY sprites.
	// Thus the "green" ramp of the player 0 sprite
	//  is mapped to gray, red, black/indigo. 
	*dest = dc_colormap[dc_translation[dc_source[frac>>FRACBITS]]];
	dest += sysvideo.pitch;
	
	frac += fracstep; 
    } while (count--); 
} 

void R_DrawTranslatedColumnLow (void) 
{ 
    unsigned short	count; 
    byte		*dest; 
    fixed_t		frac;
    fixed_t		fracstep;	 
 
    if (dc_yh < dc_yl) 
	return; 
				 
#ifdef RANGECHECK 
    if ((unsigned)dc_x >= sysvideo.width
	|| dc_yl < 0
	|| dc_yh >= sysvideo.height)
    {
	I_Error ( "R_DrawColumn: %i to %i at %i",
		  dc_yl, dc_yh, dc_x);
    }
    
#endif 
    
    count = dc_yh - dc_yl; 

    /*  FIXME. As above. */
    dest = ylookup[dc_yl] + columnofs[dc_x << 1]; 

    /*  Looks familiar. */
    fracstep = dc_iscale; 
    frac = dc_texturemid + (dc_yl-centery)*fracstep; 

    /*  Here we do an additional index re-mapping. */
    do 
    {
		int spot;

	/*  Translation tables are used */
	/*   to map certain colorramps to other ones, */
	/*   used with PLAY sprites. */
	/*  Thus the "green" ramp of the player 0 sprite */
	/*   is mapped to gray, red, black/indigo.  */
	spot = dc_colormap[dc_translation[dc_source[frac>>FRACBITS]]];

	*dest++ = spot;
	*dest++ = spot;

	dest += sysvideo.pitch-2;
	
	frac += fracstep; 
    } while (count--); 
} 



//
// R_InitTranslationTables
// Creates the translation tables to map
//  the green color ramp to gray, brown, red.
// Assumes a given structure of the PLAYPAL.
// Could be read from a lump instead.
//
void R_InitTranslationTables (void)
{
    int		i;
	
    translationtables = Z_Malloc (256*3+255, PU_STATIC, 0);
    translationtables = (byte *)(( (int)translationtables + 255 )& ~255);
    
    // translate just the 16 green colors
    for (i=0 ; i<256 ; i++)
    {
	if (i >= 0x70 && i<= 0x7f)
	{
	    // map green ramp to gray, brown, red
	    translationtables[i] = 0x60 + (i&0xf);
	    translationtables [i+256] = 0x40 + (i&0xf);
	    translationtables [i+512] = 0x20 + (i&0xf);
	}
	else
	{
	    // Keep all other colors as is.
	    translationtables[i] = translationtables[i+256] 
		= translationtables[i+512] = i;
	}
    }
}




//
// R_DrawSpan 
// With DOOM style restrictions on view orientation,
//  the floors and ceilings consist of horizontal slices
//  or spans with constant z depth.
// However, rotation around the world z axis is possible,
//  thus this mapping, while simpler and faster than
//  perspective correct texture mapping, has to traverse
//  the texture at an angle in all but a few cases.
// In consequence, flats are not stored by column (like walls),
//  and the inner loop has to step in texture space u and v.
//
int			ds_y; 
int			ds_x1; 
int			ds_x2;

lighttable_t*		ds_colormap; 

fixed_t			ds_xfrac; 
fixed_t			ds_yfrac; 
fixed_t			ds_xstep; 
fixed_t			ds_ystep;

// start of a 64*64 tile image 
byte*			ds_source;	

// just for profiling
int			dscount;


//
// Draws the actual span.
void R_DrawSpan (void) 
{ 
    fixed_t		xfrac;
    fixed_t		yfrac; 
    byte*		dest; 
    unsigned short		count;
	 
#ifdef RANGECHECK 
    if (ds_x2 < ds_x1
	|| ds_x1<0
	|| ds_x2>=sysvideo.width  
	|| (unsigned)ds_y>sysvideo.height)
    {
	I_Error( "R_DrawSpan: %i to %i at %i",
		 ds_x1,ds_x2,ds_y);
    }
//	dscount++; 
#endif 

    
    xfrac = ds_xfrac; 
    yfrac = ds_yfrac; 
	 
    dest = ylookup[ds_y] + columnofs[ds_x1];

    // We do not check for zero spans here?
    count = ds_x2 - ds_x1; 

#if defined(__GNUC__) && (defined(__M68000__) || defined(__M68020__))
    __asm__ __volatile__ (
	"lsrl	#6,%3\n"
"	lsrl	#6,%1\n"
"	moveql	#0,d1\n"

"	movew	%0,d0\n"
"	notw	d0\n"
"	andw	#3,d0\n"
"	lea		R_DrawSpan_loop,a0\n"
"	muluw	#R_DrawSpan_loop1-R_DrawSpan_loop,d0\n"
"	lsrw	#2,%0\n"
"	jmp		a0@(0,d0:w)\n"

"R_DrawSpan_loop:\n"
"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),%7@+\n"
"	addw	%3,%1\n"

"R_DrawSpan_loop1:\n"
"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),%7@+\n"
"	addw	%3,%1\n"

"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),%7@+\n"
"	addw	%3,%1\n"

"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),%7@+\n"
"	addw	%3,%1\n"

"	dbra	%0,R_DrawSpan_loop"
	 	: /* no return value */
	 	: /* input */
	 		"d"(count), "d"(xfrac), "d"(yfrac), "d"(ds_xstep), "d"(ds_ystep),
			"a"(ds_colormap), "a"(ds_source), "a"(dest)
	 	: /* clobbered registers */
	 		"d0", "d1", "a0", "cc", "memory" 
	);
#else
    do 
    {
	    int			spot; 

	// Current texture index in u,v.
	spot = ((yfrac>>(16-6))&(63*64)) + ((xfrac>>16)&63);

	// Lookup pixel from flat texture tile,
	//  re-index using light/colormap.
	*dest++ = ds_colormap[ds_source[spot]];

	// Next step in u,v.
	xfrac += ds_xstep; 
	yfrac += ds_ystep;
	
    } while (count--); 
#endif
} 

void R_DrawSpanFlat (void) 
{ 
    fixed_t		xfrac;
    fixed_t		yfrac; 
    byte*		dest; 
    unsigned short	count;
	unsigned long color;
	 
#ifdef RANGECHECK 
    if (ds_x2 < ds_x1
	|| ds_x1<0
	|| ds_x2>=sysvideo.width  
	|| (unsigned)ds_y>sysvideo.height)
    {
	I_Error( "R_DrawSpanFlat: %i to %i at %i",
		 ds_x1,ds_x2,ds_y);
    }
//	dscount++; 
#endif 

    
    xfrac = ds_xfrac; 
    yfrac = ds_yfrac; 
	 
    dest = ylookup[ds_y] + columnofs[ds_x1];

    // We do not check for zero spans here?
    count = ds_x2 - ds_x1; 

	color = ds_colormap[*ds_source];
	color |= (color<<24)|(color<<16)|(color<<8);

	if ((((unsigned long)dest) & 1) && (count>1)) {
		*dest++ = color;
		count--;
	}

	if (count>4) {
		unsigned long *dest2=(unsigned long *)dest;
		int count2 = (count>>2)-1;
		do {
			*dest2++ = color;
		} while (count2--); 
		count -= (count2+1)<<2;
		dest += (count2+1)<<2;
	}

	if (count>0) {
		do {
			*dest++ = color;
		} while (count--); 
	}	
} 


//
// Again..
//
void R_DrawSpanLow (void) 
{ 
    fixed_t		xfrac;
    fixed_t		yfrac; 
    byte*		dest; 
    unsigned short		count;
	 
#ifdef RANGECHECK 
    if (ds_x2 < ds_x1
	|| ds_x1<0
	|| ds_x2>=sysvideo.width  
	|| (unsigned)ds_y>sysvideo.height)
    {
	I_Error( "R_DrawSpan: %i to %i at %i",
		 ds_x1,ds_x2,ds_y);
    }
//	dscount++; 
#endif 
	 
    xfrac = ds_xfrac; 
    yfrac = ds_yfrac; 

    dest = ylookup[ds_y] + columnofs[ds_x1<<1];
  
    count = ds_x2 - ds_x1; 

#if defined(__GNUC__) && (defined(__M68000__) || defined(__M68020__))
    __asm__ __volatile__ (
	"lsrl	#6,%3\n"
"	lsrl	#6,%1\n"
"	moveql	#0,d1\n"

"	movew	%0,d0\n"
"	notw	d0\n"
"	andw	#3,%%d0\n"
"	lea		R_DrawSpanLow_loop,a0\n"
"	muluw	#R_DrawSpanLow_loop1-R_DrawSpanLow_loop,d0\n"
"	lsrw	#2,%0\n"
"	jmp		a0@(0,d0:w)\n"

"R_DrawSpanLow_loop:\n"
"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),d2\n"
"	moveb	d2,%7@+\n"
"	addw	%3,%1\n"
"	moveb	d2,%7@+\n"

"R_DrawSpanLow_loop1:\n"
"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),d2\n"
"	moveb	d2,%7@+\n"
"	addw	%3,%1\n"
"	moveb	d2,%7@+\n"

"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),d2\n"
"	moveb	d2,%7@+\n"
"	addw	%3,%1\n"
"	moveb	d2,%7@+\n"

"	movel	%2,d0\n"
"	movew	%1,d0\n"
"	lsrl	#6,d0\n"
"	lsrw	#4,d0\n"
"	moveb	%6@(0,d0:w),d1\n"
"	addl	%4,%2\n"
"	moveb	%5@(0,d1:w),d2\n"
"	moveb	d2,%7@+\n"
"	addw	%3,%1\n"
"	moveb	d2,%7@+\n"

"	dbra	%0,R_DrawSpanLow_loop"
	 	: /* no return value */
	 	: /* input */
	 		"d"(count), "d"(xfrac), "d"(yfrac), "d"(ds_xstep), "d"(ds_ystep),
			"a"(ds_colormap), "a"(ds_source), "a"(dest)
	 	: /* clobbered registers */
	 		"d0", "d1", "d2", "a0", "cc", "memory" 
	);
#else
    do 
    { 
	    int			spot; 

	spot = ((yfrac>>(16-6))&(63*64)) + ((xfrac>>16)&63);
	spot = ds_colormap[ds_source[spot]];
	// Lowres/blocky mode does it twice,
	//  while scale is adjusted appropriately.
	*dest++ = spot; 
	*dest++ = spot;
	
	xfrac += ds_xstep; 
	yfrac += ds_ystep; 

    } while (count--); 
#endif
}

void R_DrawSpanLowFlat (void) 
{ 
    fixed_t		xfrac;
    fixed_t		yfrac; 
    byte*		dest; 
    unsigned short		count;
	unsigned long color;
	 
#ifdef RANGECHECK 
    if (ds_x2 < ds_x1
	|| ds_x1<0
	|| ds_x2>=sysvideo.width  
	|| (unsigned)ds_y>sysvideo.height)
    {
	I_Error( "R_DrawSpan: %i to %i at %i",
		 ds_x1,ds_x2,ds_y);
    }
//	dscount++; 
#endif 
	 
    xfrac = ds_xfrac; 
    yfrac = ds_yfrac; 

    dest = ylookup[ds_y] + columnofs[ds_x1<<1];
  
    count = (ds_x2 - ds_x1)<<1;

	color = ds_colormap[*ds_source];
	color |= (color<<24)|(color<<16)|(color<<8);

	if ((((unsigned long)dest) & 1) && (count>1)) {
		*dest++ = color;
		count--;
	}

	if (count>4) {
		unsigned long *dest2=(unsigned long *)dest;
		int count2 = (count>>2)-1;
		do {
			*dest2++ = color;
		} while (count2--); 
		count -= (count2+1)<<2;
		dest += (count2+1)<<2;
	}

	if (count>0) {
		do {
			*dest++ = color;
		} while (count--); 
	}	
}

//
// R_InitBuffer 
// Creats lookup tables that avoid
//  multiplies and other hazzles
//  for getting the framebuffer address
//  of a pixel to draw.
//
void
R_InitBuffer
( int		width,
  int		height ) 
{ 
	int		i; 

	if (sysvideo.width>maxwidth) {
		if (columnofs)
			Z_Free(columnofs);
		maxwidth = sysvideo.width;
		columnofs = Z_Malloc(maxwidth*sizeof(int), PU_STATIC, NULL);
	}

	if (sysvideo.height>maxheight) {
		if (ylookup)
			Z_Free(ylookup);
		maxheight = sysvideo.height;
		ylookup = Z_Malloc(maxheight*sizeof(byte *), PU_STATIC, NULL);
	}

	// Handle resize,
	//  e.g. smaller view windows
	//  with border and/or status bar.
	viewwindowx = (sysvideo.width-width) >> 1; 

	// Column offset. For windows.
	for (i=0 ; i<width ; i++) 
		columnofs[i] = viewwindowx + i;

	// Samw with base row offset.
	if (width == sysvideo.width) 
		viewwindowy = 0; 
	else 
		viewwindowy = (sysvideo.height-st_height-height) >> 1; 

	// Preclaculate all row offsets.
	for (i=0 ; i<height ; i++) 
		ylookup[i] = screens[0] + (i+viewwindowy)*sysvideo.pitch; 
} 
 
 


//
// R_FillBackScreen
// Fills the back screen with a pattern
//  for variable screen sizes
// Also draws a beveled edge.
//
void R_FillBackScreen (void) 
{ 
	byte*	src;
	byte*	dest; 
	int		x;
	int		y; 
	patch_t*	patch;

	// DOOM border patch.
	char	name1[] = "FLOOR7_2";

	// DOOM II border patch.
	char	name2[] = "GRNROCK";	

	char*	name;

	if (scaledviewwidth == sysvideo.width)
		return;

	if ( gamemode == commercial)
		name = name2;
	else
		name = name1;

	src = W_CacheLumpName (name, PU_CACHE); 
	dest = screens[1]; 

	for (y=0 ; y<sysvideo.height-st_height ; y++) { 
		for (x=0 ; x<sysvideo.width/64 ; x++) { 
			memcpy (dest, src+((y&63)<<6), 64); 
			dest += 64; 
		} 

		if (sysvideo.width&63) { 
			memcpy (dest, src+((y&63)<<6), sysvideo.width&63); 
			dest += (sysvideo.width&63); 
		} 
	} 

	patch = W_CacheLumpName ("brdr_t",PU_CACHE);
	for (x=0 ; x<scaledviewwidth ; x+=8)
		V_DrawPatch (viewwindowx+x,viewwindowy-8,1,patch);

	patch = W_CacheLumpName ("brdr_b",PU_CACHE);
	for (x=0 ; x<scaledviewwidth ; x+=8)
		V_DrawPatch (viewwindowx+x,viewwindowy+viewheight,1,patch);

	patch = W_CacheLumpName ("brdr_l",PU_CACHE);
	for (y=0 ; y<viewheight ; y+=8)
		V_DrawPatch (viewwindowx-8,viewwindowy+y,1,patch);

	patch = W_CacheLumpName ("brdr_r",PU_CACHE);
	for (y=0 ; y<viewheight ; y+=8)
		V_DrawPatch (viewwindowx+scaledviewwidth,viewwindowy+y,1,patch);


	// Draw beveled edge. 
	V_DrawPatch (viewwindowx-8, viewwindowy-8, 1,
		W_CacheLumpName ("brdr_tl",PU_CACHE));

	V_DrawPatch (viewwindowx+scaledviewwidth, viewwindowy-8, 1,
		W_CacheLumpName ("brdr_tr",PU_CACHE));

	V_DrawPatch (viewwindowx-8, viewwindowy+viewheight, 1,
		W_CacheLumpName ("brdr_bl",PU_CACHE));

	V_DrawPatch (viewwindowx+scaledviewwidth, viewwindowy+viewheight, 1,
		W_CacheLumpName ("brdr_br",PU_CACHE));
} 
 

//
// Copy a screen buffer.
//
void
R_VideoErase
( int x, int y,
  int		count ) 
{ 
	// LFB copy.
	// This might not be a good idea if memcpy
	//  is not optiomal, e.g. byte by byte on
	//  a 32bit CPU, as GNU GCC/Linux libc did
	//  at one point.
	memcpy (screens[0]+y*sysvideo.pitch+x, screens[1]+y*sysvideo.width+x, count); 
} 


//
// R_DrawViewBorder
// Draws the border around the view
//  for different size windows?
//
void
V_MarkRect
( int		x,
  int		y,
  int		width,
  int		height ); 
 
void R_DrawViewBorder (void) 
{ 
    int		top;
    int		side;
    int		i; 
 
	if (scaledviewwidth == sysvideo.width) 
		return; 
  
    top = ((sysvideo.height-st_height)-viewheight)/2; 
    side = (sysvideo.width-scaledviewwidth)/2; 
 
    // copy top
	for (i=0;i<top; i++) {
	    R_VideoErase (0, i, sysvideo.width); 
 	}
 
    // copy bottom 
	for (i=viewheight+top; i<sysvideo.height-st_height; i++) {
	    R_VideoErase (0, i, sysvideo.width); 
	}

    // copy sides
	for (i=top; i<top+viewheight; i++) {
		R_VideoErase (0, i, side);
		R_VideoErase (sysvideo.width-side, i, side);
	}

    // ? 
    V_MarkRect (0,0,sysvideo.width, sysvideo.height-st_height); 
} 
