/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include <osbind.h>
#include "flicker.h"

extern long calc_dlt_size();
extern char *getend();

free_cel(cel)
register Cel *cel;
{
if (cel == NULL)
	return;
freemem(cel->image);
if (cel->mask)
	freemem(cel->mask);
Free_a(cel);
}

Cel *
init_cel(w, h)
register WORD w, h;
{
register Cel *cel;

if ((cel = Alloc_a(Cel)) == NULL)
	return(NULL);
cel->image_size = LRaster_block((long)w, (long)h);
cel->image = NULL;
cel->width = w;
cel->height = h;
cel->mask = NULL;
cel->xoff = cel->yoff = 0;
return(cel);
}

Cel *
alloc_cel(w, h)
register WORD w, h;
{
register Cel *cel;

if ((cel = init_cel(w, h)) == NULL)
	return(NULL);
if (  (cel->image = (WORD *)laskmem(cel->image_size)) == NULL)
	{
	Free_a(cel);
	return(NULL);
	}
return(cel);
}

struct seq_header s_head;
struct neo_head n_head;
int empty;
char *errinfo[4];

ld_frame(fd, name)
int fd;
char *name;
{
char *cbuf;
Cel *tcel;

if (Fread(fd, (long)sizeof(n_head), &n_head) < sizeof(n_head) )
	{
	file_truncated(name);
	return(0);
	}
if (n_head.compress == NEO_UNCOMPRESSED)
	n_head.data_size = LRaster_block(n_head.width, (long)n_head.height);
if (n_head.type != -1)
	{
	errinfo[1] = "Bad Cel Magic! File damaged!";
	continu_from(errinfo);
	return(0);
	}
if (n_head.data_size > 0)
	{
	if ((tcel = alloc_cel(n_head.width, n_head.height)) == NULL)
		{
		outta_memory();
		return(0);
		}
	if (n_head.compress == NEO_CCOLUMNS)
		{
		if (n_head.data_size > 32000)
			{
			free_cel(tcel);
			mangled(name);
			return(0);
			}
		if ((cbuf = laskmem(n_head.data_size)) == NULL)
			{
			free_cel(tcel);
			outta_memory();
			return(0);
			}
		if (Fread(fd, n_head.data_size, cbuf)<n_head.data_size)
			{
			free_cel(tcel);
			file_truncated(name);
			freemem(cbuf);
			return(0);
			}
		word_uncompress(cbuf,  tcel->image, n_head.data_size>>1);
		freemem(cbuf);
		}
	else
		{
		if (Fread(fd, tcel->image_size, tcel->image) 
			< tcel->image_size)
			{
			file_truncated(name);
			free_cel(tcel);
			return(0);
			}
		}
	if (n_head.op != NEO_XOR )
		{
		clear_screen();
		if (n_head.compress == NEO_CCOLUMNS)
			twist_copy_celblit(n_head.xoff, n_head.yoff, tcel);
		else
			copy_celblit(n_head.xoff, n_head.yoff, tcel);
		}
	else
		{
		if (n_head.compress == NEO_CCOLUMNS)
			twist_xor_celblit(n_head.xoff, n_head.yoff, tcel);
		else
			xor_celblit(n_head.xoff, n_head.yoff, tcel);
		}
	free_cel(tcel);
	}
else
	{
	if (n_head.op != NEO_XOR )
		clear_screen();
	else
		empty = 1;
	}
return(1);
}

ld_seq(name, t)
char *name;
struct tlib *t;
{
int fd;
struct seq_lib *s;
int i;
long dsize;
WORD *dbuf;
char nbuf[16];



errinfo[0] = name;
errinfo[2] = NULL;
s = NULL;
if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_find(name);
	return(0);
	}
if (Fread(fd, (long)sizeof(s_head), &s_head) < sizeof(s_head) )
	{
	file_truncated(name);
	goto BAD;
	}
if (s_head.magic != 0xfedc && s_head.magic != 0xfedb)
	{
	errinfo[1] = "Bad Magic!  Not a Cyber Sequence";
	continu_from(errinfo);
	goto BAD;
	}
if ((s = begzeros(sizeof(*s))) == NULL)
	goto BAD;
if ((s->first_frame = begmem(32000)) == NULL)
	goto BAD;
t->bytes = 32000;
if ((s->deltas = begzeros((int)(s_head.cel_count)*sizeof(char *))) == NULL)
	goto BAD;
s->frame_count = s_head.cel_count;
	/* skip past the offset lists */
hide_mouse();
Fseek( s_head.cel_count * sizeof(long), fd, 1);	
cscreen = bscreen;
sprintf(nbuf, "of %ld", s_head.cel_count);
gtext(nbuf, 73*CH_WIDTH, 0, white);
for (i=0; i<s_head.cel_count; i++)
	{
	sprintf(nbuf, "%4d", i+1);
	gtext(nbuf, 68*CH_WIDTH, 0, white);
	empty = 0;
	if (!ld_frame(fd, name))
		goto BAD;
	if (i != 0)
		{
		if (!empty)
			dsize = calc_dlt_size(cscreen, s->first_frame) + 32;
		else
			dsize = 34;
		if ((dbuf = laskmem(dsize)) == NULL)
			{
			outta_memory();
			goto BAD;
			}
		copy_words(n_head.colormap, dbuf, 16);
		if (empty)
			dbuf[16] = 0;
		else
			{
			make_deltas(cscreen, s->first_frame, dbuf+16);
			}
		s->deltas[i] = dbuf;
		t->bytes += dsize;
		s->frames_read++;
		}
	if (!empty)
		copy_screen(cscreen, s->first_frame);
	}
Fseek( sizeof(s_head) + s_head.cel_count * sizeof(long), fd, 0);	
cscreen = s->first_frame;	/* re-read 1st frame */
if (!ld_frame(fd, name))
	{
	goto BAD;
	}
dsize = calc_dlt_size(cscreen, bscreen) + 32;
if ((dbuf = laskmem(dsize)) == NULL)
	{
	outta_memory();
	goto BAD;
	}
copy_words(n_head.colormap, dbuf, 16);
make_deltas(cscreen, bscreen, dbuf+16);
s->deltas[0] = dbuf;
t->bytes += dsize;
s->frames_read++;
cscreen = pscreen;
Fclose(fd);
if (s_head.speed == 0)
	s_head.speed = 400;
t->default_speed = s_head.speed/100;
t->samples = s->frames_read;
t->image = s;
show_mouse();
return(1);
BAD:
cscreen = pscreen;
Fclose(fd);
free_slib(s);
show_mouse();
return(0);
}

