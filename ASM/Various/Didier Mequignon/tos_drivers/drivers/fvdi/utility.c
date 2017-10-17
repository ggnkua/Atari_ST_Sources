/* TOS 4.04 fVDI init stuctures for the CT60/CTPCI boards
*  Didier Mequignon 2005, e-mail: aniplay@wanadoo.fr
*  from fVDI setup Copyright 1999-2003, Johan Klockars 
*
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Lesser General Public
*  License as published by the Free Software Foundation; either
*  version 2.1 of the License, or (at your option) any later version.
*
*  This library is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*  Lesser General Public License for more details.
*
*  You should have received a copy of the GNU Lesser General Public
*  License along with this library; if not, write to the Free Software
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "config.h"
#include <mint/osbind.h>
#include <mint/sysvars.h>
#include "fvdi.h"
#include "relocate.h"

#ifndef NULL
#define NULL (void *)0
#endif

#define DEBUG

#define WHITE 0
#define BLACK 1

#define BLOCKS           2              /* Default number of memory blocks to allocate for internal use */
#define BLOCK_SIZE     100              /* Default size of those blocks, in kbyte */

#define LOG_SIZE     8192

extern void *default_text;
extern void *default_line;
extern void *default_fill;
extern long buf_cursor;

extern void initialize_wk_palette(Virtual *vwk);
extern short *loaded_palette;
extern short os_magic, memory_ok, drive_ok, redirect;
extern long boot_alloc(long size);

typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;

/* global */
long Version=0x100;
Access *access;           /* fVDI */
void *tab_func_fvdi;
long blocks;
long block_size;
char *block_chain;
short arc_split,arc_min,arc_max;
char buf_log[LOG_SIZE+1];
static char *ptr_buf_log;

/* some functions for the fVDI driver */
extern long linea_fonts();
extern long fixup_font(Fontheader *font, char *buffer, long flip);
extern long unpack_font(Fontheader *header, long format);
extern long insert_font(Fontheader **first_font, Fontheader *new_font);

/* some functions */
extern long atol(const char *text);
extern void ltoa(char *buf, long n, unsigned long base);

void minus(char *s)
{
	while(*s)
	{
		if(*s>='A' && *s<='Z')
			*s += 0x20;
		if(*s=='\\')
			*s='/';
		s++;
	}
}

COOKIE *fcookie(void)
{
	COOKIE *p;
	long stack=0;
	if(Super(1L)>=0)
		stack=Super(0L);
	p=*(COOKIE **)0x5a0;
	if(stack)
		Super((void *)stack);
	if(!p)
		return((COOKIE *)0);
	return(p);
}

COOKIE *ncookie(COOKIE *p)
{
	if(!p->ident)
		return((COOKIE *)0);
	return(++p);
}

COOKIE *get_cookie(long id)
{
	COOKIE *p;
	p=fcookie();
	while(p)
	{
		if(p->ident==id)
			return(p);
		p=ncookie(p);
	}
	return((COOKIE *)0);
}

int add_cookie(COOKIE *cook)
{
	COOKIE *p;
	int i=0;
	p=fcookie();
	while(p)
	{
		if(p->ident==cook->ident)
			return(-1);
		if(!p->ident)
		{
			if(i+1 < p->v.l)
			{
				*(p+1)=*p;
				*p=*cook;
				return(0);
			}
			else
				return(-2);			/* problem */
		}
		i++;
		p=ncookie(p);
	}
	return(-1);						/* no cookie-jar */
}

static void copy_mem(const void *s, void *d, long n)
{
	char *src, *dest;
	src  = (char *)s;
	dest = (char *)d;
	for(n = n - 1; n >= 0; n--)
		*dest++ = *src++;
}

static const char *next_line(const char *ptr)
{
	while(1)
	{
		if(!*ptr)
			return 0;
		else if((*ptr == 10) || (*ptr == 13))
			break;
		ptr++;
	}
	ptr++;
	while(1)
	{
		if(!*ptr)
			return(0);
		else if((*ptr != 10) && (*ptr != 13))
			break;
		ptr++;
	}
	return(ptr);
}

static const char *skip_space(const char *ptr)
{
	if(!ptr)
		return(0);
	while(1)
	{
		if(!*ptr)
			return(0);
		else if(*ptr <= ' ');
		else if(*ptr == '#')
		{
			if(!(ptr = next_line(ptr)))
				return(0);
			else
				continue;     /* Updating of ptr already done! */
		}
		else
				return ptr;
		ptr++;
	}
}

static const char *get_token(const char *ptr, char *buf, long n)
{
	if(*ptr == '=')     /* Assignment token? */
		*buf++ = *ptr++;
	else if(*ptr != '\"')
	{                   /* Get ordinary token */
		while(--n)
		{
			if((*ptr <= ' ') || (*ptr == '='))
				break;
			*buf++ = *ptr++;
		}
	}
	else
	{                   /* Get quoted token */
		ptr++;
		while(--n)
		{
			if(((*ptr < ' ') && (*ptr != '\t')) || (*ptr == '\"'))
				break;
			*buf++ = *ptr++;
		}
		if(*ptr == '\"')
			ptr++;
   }
   *buf = '\0';
   return(ptr);
}

static long equal(const char *str1, const char *str2)
{
	char ch1, ch2;
	do
	{
		ch1 = *str1++;
		ch2 = *str2++;
		if(ch1 != ch2)
		{
			if((ch1 >= 'A') && (ch1 <= 'Z'))
			{
				if((ch1 | 32) != ch2)
					return(0);
			}
			else
				return(0);
		}
	}
	while(ch1 && ch2);
	return(1);
}

long length(const char *text)
{
	long length=0;
	while(*text++)
		length++;
	return(length);
}

void copy(const char *src, char *dest)
{
	while(*src)
		*dest++ = *src++;
	*dest = 0;
}

void cat(const char *src, char *dest)
{
	while(*dest++);
	dest--;
	while(*src)
		*dest++ = *src++;
	*dest = 0;
}

static long numeric(long ch)
{
	if((ch >= '0') && (ch <= '9'))
		return(1);
	return(0);
}

static void *fmalloc(long size, long type)
{
	if(type);
	return((void *)boot_alloc(size));
}

static long free(void *addr)
{
	if((os_magic == 1) && !memory_ok)
		return(0);
	return(Mfree(addr));
}

static int puts(const char *text)
{
#if 0 // #ifdef COLDFIRE
#ifdef DEBUG
	extern void display_string(const char *string);
	display_string(text);
#endif
#endif
	if(!redirect)
		Cconws(text);
	if(!drive_ok)
	{
		while(*text && (ptr_buf_log < &buf_log[LOG_SIZE]))
			*ptr_buf_log++ = *text++;
		*ptr_buf_log = '\0';
	}
	return(1);
}

static void error(const char *text1, const char *text2)
{
	puts(text1);
	if(text2)
		puts(text2);
	puts("\x0a\x0d");
}

static long getcookie(const unsigned char *cname, long super)
{
	COOKIE *p;
	if(super);
	p=get_cookie(*((long*)cname));
	if(p)
		return(p->v.l);
	else
		return(-1); /* not found */
}

static long setcookie(const unsigned char *cname, long value)
{
	COOKIE *p;
	COOKIE cookie;
	p=get_cookie(*((long*)cname));
	if(p)
	{
		p->v.l=value;
		return(0);
	}
	else
	{
		cookie.ident=*((long*)cname);
		cookie.v.l=value;
		return(add_cookie(&cookie));
	}
}

static long get_size(const char *name)
{
	if(name);      /* not implemented */
	return(0);
}

// static char memory_pool[BLOCK_SIZE * 1024 * BLOCKS];

long initialize_pool(long size, long n)
{
	char *addr, *ptr;
	if((size <= 0) || (n <= 0))
		return(0);
#if 0
	if((size * n) <= (BLOCK_SIZE * 1024 * BLOCKS))
    addr = memory_pool;
  else
#endif
  {
		if((addr = (char *)fmalloc(size * n, 3)) == NULL)
			return(0);
	}
	block_size = size;
	ptr = 0;
	for(n = n - 1; n >= 0; n--)
	{
		block_chain = addr;
		*(char **)addr = ptr;
		ptr = addr;
		addr += size;
	}
	return(1);
}

char *allocate_block(long size)
{
	char *addr;
	if((size > block_size) || !block_chain)
		return(0);
	addr = block_chain;
	block_chain = *(char **)addr;
	*(long *)addr = block_size;    /* make size info available */
	return(addr);
}

void free_block(void *addr)
{
	*(char **)addr = block_chain;
	block_chain = addr;
}

static void cache_flush(void)
{
#ifdef COLDFIRE
	asm volatile (" .chip 68060\n\t");
#endif
	asm volatile (" cpusha BC\n\t");
#ifdef COLDFIRE
#if (__GNUC__ > 3)
	asm volatile (" .chip 5485\n\t");
#else
	asm volatile (" .chip 5200\n\t");
#endif
#endif
}

static long misc(long func, long par, const char *token)
{
	if(func);      /* not implemented */
	if(par);
	if(token);
	return(0);
}

static long event(long id_type, long data)
{
	if(id_type);   /* not implemented */
	if(data);
	return(0);
}

Virtual *init_var_fvdi(void)
{
 	Workstation *wk;
	Virtual *vwk;
	Driver *driver;
	Fontheader **system_font, *header;
	long header_size = sizeof(Fontheader) - sizeof(Fontextra);
	blocks = BLOCKS;
	block_size = BLOCK_SIZE * 1024;
	ptr_buf_log = buf_log;
	*ptr_buf_log = '\0';
	arc_split = 16384;  /* 1/4 as many lines as largest ellipse axel radius in pixels */
	arc_min = 16;       /* Minimum number of lines in an ellipse */
	arc_max = 256;      /* Maximum */
	loaded_palette = (short *)0;
	access->vars.version=&Version;  /* fVDI Access structure */
#ifdef COLDFIRE
	access->vars.name="FIRETOS";
#else
	access->vars.name="CT60 TOS";
#endif
	access->funcs.copymem=copy_mem;
	access->funcs.next_line=next_line;
	access->funcs.skip_space=skip_space;
	access->funcs.get_token=get_token;
	access->funcs.equal=equal;
	access->funcs.length=length;
	access->funcs.copy=copy;
	access->funcs.cat=cat;
	access->funcs.numeric=numeric;
	access->funcs.atol=atol;
	access->funcs.error=error;
	access->funcs.malloc=fmalloc;
	access->funcs.free=free;
	access->funcs.puts=puts;
	access->funcs.ltoa=ltoa;
	access->funcs.get_cookie=getcookie;
	access->funcs.set_cookie=setcookie;
	access->funcs.fixup_font=fixup_font;
	access->funcs.unpack_font=unpack_font;
	access->funcs.insert_font=insert_font;
	access->funcs.get_size=get_size;
	access->funcs.allocate_block=allocate_block;
	access->funcs.free_block=free_block;
	access->funcs.cache_flush=cache_flush;
	access->funcs.misc=misc;
	access->funcs.event=event;
	if(!(wk = (Workstation *)fmalloc(sizeof(Workstation),3)))
		return(0);
	if(!(vwk = (Virtual *)fmalloc(sizeof(Virtual),3)))
	{
		free(wk);
		return(0);
	}
	if(!(driver = (Driver *)fmalloc(sizeof(Driver),3)))
	{
		free(vwk);
		free(wk);
		return(0);
	}
	/*
	 * Set up the default real and virtual workstations.
	 * These are never actually used, but can be considered templates with some
	 * reasonable initial values.
	 * The virtual workstation is both returned and stored as 'default_virtual'.
	 */
/* Screen */
	wk->driver = driver;
	wk->screen.type = 0;
	wk->screen.palette.colours = 0;
	wk->screen.palette.transformation = 0;
	wk->screen.mfdb.address = 0;
	wk->screen.mfdb.wdwidth = 0;
	wk->screen.mfdb.standard = 0;
	wk->screen.linea = 0;
	wk->screen.shadow.buffer = 0;
	wk->screen.shadow.address = 0;
	wk->screen.shadow.wrap = 0;
/* */
	wk->screen.pixel.width = 238;       /* Used to be 353 */
	wk->screen.pixel.height = 149;
/* */
	wk->screen.coordinates.course = 0;
/* */
	wk->screen.coordinates.min_x = 0;
	wk->screen.coordinates.min_y = 0;
/* */
	wk->writing.fonts = 0;
	wk->writing.first_font = 0;
	wk->writing.effects = 0x1f;              /* Outline/underline/italic/light/bold supported */
	wk->writing.rotation.possible = 0;
	wk->writing.rotation.type = 0;
	wk->writing.justification = 0;
/* */
	wk->writing.size.possibilities = 3;      /* Get these some real way! */
	wk->writing.size.height.min = 4;
	wk->writing.size.height.max = 13;
	wk->writing.size.width.min = 5;
	wk->writing.size.width.max = 7;
/* */
	wk->drawing.primitives.supported = 10;    /* Everything */
	wk->drawing.primitives.attributes = ((3 + 1) <<  0) + ((0 + 1) <<  3) + ((3 + 1) <<  6) +
	                                    ((3 + 1) <<  9) + ((3 + 1) << 12) + ((0 + 1) << 15) +
	                                    ((3L + 1) << 18) + ((0L + 1) << 21) + ((0L + 1) << 24) + ((2L + 1) << 27);
	wk->drawing.rubber_banding = 0;
	wk->drawing.flood_fill = 0;
	wk->drawing.writing_modes = 4;
	wk->drawing.fill.possible = 1;
	wk->drawing.fill.patterns = 24;
	wk->drawing.fill.hatches = 12;
	wk->drawing.marker.types = 6;
	wk->drawing.marker.size.possibilities = 8;
	wk->drawing.marker.size.height.min = 11;
	wk->drawing.marker.size.height.max = 88;
	wk->drawing.marker.size.width.min = 15;
	wk->drawing.marker.size.width.max = 120;
	wk->drawing.line.types = 7;
	wk->drawing.line.wide.width.possibilities = 0;
	wk->drawing.line.wide.width.max = 31;        /* Was 255 */
	wk->drawing.line.wide.width.min = 1;
	wk->drawing.line.wide.types_possible = 1;
	wk->drawing.line.wide.writing_modes = 0;
	wk->drawing.bezier.available = 1;
	wk->drawing.bezier.depth_scale.min = 9;
	wk->drawing.bezier.depth_scale.max = 0;
	wk->drawing.bezier.depth.min = 2;
	wk->drawing.bezier.depth.max = 7;
	wk->drawing.cellarray.available = 0;
	wk->raster.scaling = 0;
/* 16x16 op/s */
	wk->various.input_type = 0;
/* Nedsvartning */
	wk->various.max_ptsin = 1024;                /* Was -1 */
	wk->various.max_intin = -1;
	wk->various.buttons = 0;
	wk->various.cursor_movement = 0;
	wk->various.number_entry = 0;
	wk->various.selection = 0;
	wk->various.typing = 0;
	wk->various.workstation_type = 0;
/* Console */
/* Mouse */
	wk->mouse.type = 0;           /* Default to old VDI mouse */
	wk->mouse.hide = 0;
	wk->mouse.buttons = 0;
	wk->mouse.forced = 0;
	wk->mouse.position.x = 0;
	wk->mouse.position.y = 0;
	wk->vector.motion = 0; // mouse_move;
	wk->vector.draw   = 0; // do_nothing;
	wk->vector.button = 0; // do_nothing;
	wk->vector.wheel  = 0; // do_nothing;
	wk->vector.vblank = 0; // mouse_timer;
	wk->vblank.real = 0;
	wk->vblank.frequency = 50;
	wk->r.set_palette = 0;
	wk->r.get_colour  = 0;
	wk->r.set_pixel   = 0;
	wk->r.get_pixel   = 0;
	wk->r.line     = &default_line;
	wk->r.expand   = 0; /* need accel.c */
	wk->r.fill     = &default_fill;
	wk->r.fillpoly = 0; /* use fill */
	wk->r.blit     = 0; /* need accel.c */
	wk->r.text     = &default_text;
	wk->r.mouse    = 0;
	
	vwk->clip.on = 0;
	vwk->clip.rectangle.x1 = 0;
	vwk->clip.rectangle.y1 = 0;
	vwk->clip.rectangle.x2 = 0;
	vwk->clip.rectangle.y2 = 0;
	vwk->text.colour.background = WHITE;
	vwk->text.colour.foreground = BLACK;
	vwk->text.effects = 0;
	vwk->text.alignment.horizontal = 0;
	vwk->text.alignment.vertical = 0;
	vwk->text.rotation = 0;
	vwk->text.font = 0;
	vwk->text.current_font = 0;        /* Address will be set on first call to vst_font */
	vwk->line.colour.background = WHITE;
	vwk->line.colour.foreground = BLACK;
	vwk->line.width = 1;
	vwk->line.type = 1;
	vwk->line.ends.beginning = 0;
	vwk->line.ends.end = 0;
	vwk->line.user_mask = 0xffff;
	vwk->bezier.on = 0;                /* Should these really be per vwk? */
	vwk->bezier.depth_scale = 0;
	vwk->marker.colour.background = WHITE;
	vwk->marker.colour.foreground = BLACK;
	vwk->marker.size.height = 11;
	vwk->marker.size.width = 15;
	vwk->marker.type = 3;
	vwk->fill.colour.background = WHITE;
	vwk->fill.colour.foreground = BLACK;
	vwk->fill.interior = 0;
	vwk->fill.style = 1;
	vwk->fill.perimeter = 1;
	vwk->fill.user.pattern.in_use = 0;
	vwk->fill.user.pattern.extra = 0;
	vwk->fill.user.multiplane = 0;
	vwk->mode = 1;
	vwk->real_address = (void *)wk;
	vwk->standard_handle = 1;
	vwk->palette = 0;
	
	system_font = (Fontheader **)linea_fonts();
	if(!(header = (Fontheader *)fmalloc(sizeof(Fontheader) * 3,3)))
	{
		free(vwk);
		free(wk);
		return(0);
	}
	copy_mem(system_font[0], &header[0], header_size);
	copy_mem(system_font[1], &header[1], header_size);
	copy_mem(system_font[2], &header[2], header_size);
	fixup_font(&header[0], (char *)header_size, 0);
	fixup_font(&header[1], (char *)header_size, 0);
	fixup_font(&header[2], (char *)header_size, 0);
	unpack_font(&header[0], 1);
	unpack_font(&header[1], 1);
	unpack_font(&header[2], 1);
	insert_font(&wk->writing.first_font, &header[0]);
	insert_font(&wk->writing.first_font, &header[1]);
	insert_font(&wk->writing.first_font, &header[2]);
	wk->writing.fonts++;
	vwk->text.font = 1;
	vwk->text.current_font = wk->writing.first_font;
	
	buf_cursor = 0;

	return(vwk);
}
