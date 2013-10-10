
#include "flicker.h"

struct rot_seg
	{
	Point s1, s2;
	WORD dxoff;	/* x offset of this line of dest */
	WORD dw;	/* width of dest */
	};
typedef struct rot_seg Rot_seg;

#ifdef DEBUG
dump_1rseg(rs)
struct rot_seg *rs;
{
printf("(%d %d) (%d %d) %d %d\n",
	rs->s1.x, rs->s1.y,
	rs->s2.x, rs->s2.y,
	rs->dxoff, rs->dw);
}

dump_rseg(rs, count)
struct rot_seg *rs;
WORD count;
{
printf("dump_rseg(%lx %d)\n", rs, count);
while (--count >= 0)
	dump_1rseg(rs++);
}
#endif DEBUG

struct thread
	{
	WORD count;
	struct point dpoints[4];
	struct point spoints[4];
	};

#ifdef DEBUG
dump_thread(t)
struct thread *t;
{
printf("thread %d\n", t->count);
printf("d (%d %d) (%d %d) (%d %d) (%d %d)\n",
	t->dpoints[0].x, t->dpoints[0].y,
	t->dpoints[1].x, t->dpoints[1].y,
	t->dpoints[2].x, t->dpoints[2].y,
	t->dpoints[3].x, t->dpoints[3].y);
printf("s (%d %d) (%d %d) (%d %d) (%d %d)\n",
	t->spoints[0].x, t->spoints[0].y,
	t->spoints[1].x, t->spoints[1].y,
	t->spoints[2].x, t->spoints[2].y,
	t->spoints[3].x, t->spoints[3].y);
}
#endif DEBUG

static Point source_poly[4], dest_poly[4];
static struct thread thread1, thread2;
struct min_max minmax;

sq_poly(w, h, dest)
register WORD w, h;
register WORD *dest;
{
w -= 1;
h -= 1;
*dest++ = 0;
*dest++ = 0;

*dest++ = 0;
*dest++ = h;

*dest++ = w;
*dest++ = h;

*dest++ = w;
*dest++ = 0;
}

find_min_max(source)
register WORD *source;
{
register WORD a;
register WORD i;

minmax.xmin = minmax.xmax = *source++;
minmax.ymin = minmax.ymax = *source++;
minmax.ymin_ix = minmax.ymax_ix = 0;
for (i=1; i<4; i++)
	{
	a = *source++;
	if (a < minmax.xmin)
		minmax.xmin = a;
	if (a > minmax.xmax)
		minmax.xmax = a;
	a = *source++;
	if (a < minmax.ymin)
		{
		minmax.ymin = a;
		minmax.ymin_ix = i;
		}
	if (a > minmax.ymax)
		{
		minmax.ymax = a;
		minmax.ymax_ix = i;
		}
	}
}

sub_min(p)
register WORD *p;
{
register WORD i;

i = 4;
while (--i >= 0)
	{
	*p++ -= minmax.xmin;
	*p++ -= minmax.ymin;
	}
minmax.xmax -= minmax.xmin - 1;
minmax.ymax -= minmax.ymin - 1;
}

find_thread(thread, dir)
register struct thread *thread;
WORD dir;
{
register WORD ix;
register WORD count;

ix = minmax.ymin_ix;
count = 1;
thread->dpoints[0] = dest_poly[ix];
thread->spoints[0] = source_poly[ix];
do
	{
	ix += dir;
	ix &= 3;
	thread->dpoints[count] = dest_poly[ix];
	thread->spoints[count] = source_poly[ix];
	count++;
	}
while (ix != minmax.ymax_ix);
thread->count = count;
}


WORD ground_z = 512;

Cel *
raster_transform(b, dpoly)
Byte_cel *b;
Point *dpoly;
{
Cel	*rot_cel;
unsigned char *bbuf;	/* byte-a-pixel line buffer */
WORD bbuf_length;
Rot_seg *rs;

sq_poly(b->width, b->height, source_poly);
copy_words(dpoly, dest_poly, sizeof(dest_poly) );
/* find bounding box of dest_poly */
find_min_max(dest_poly);

/* and shove everything against left edge */
sub_min(dest_poly);

/* and try for a cel to put the result of the raster rotation into */
if ((rot_cel = alloc_cel(minmax.xmax, minmax.ymax)) == NULL)
	{
	return(NULL);
	}

/* preserve color map */
copy_words(b->cmap, rot_cel->cmap, COLORS);

/* single pixel high dests do screw things up.  Actually the bug is
   in find_thread or fill_sbuf, but the quick fix is here*/
if (minmax.ymax <= 1)
	{
	return(rot_cel);
	}

/* pad the width to multiple of 16 and try for a byte-a-pixel line buffer */
bbuf_length = (minmax.xmax+15)&0xfff0;
if ((bbuf = (unsigned char *)begmem(bbuf_length) ) == NULL)
	{
	free_cel(rot_cel);
	return(NULL);
	}


/* try to get buffer to hold the "segment-list" that will eventually
   pass to fast assembler raster-rotater */
if ((rs = (Rot_seg *)begmem((minmax.ymax) * sizeof(Rot_seg) )) == NULL)
	{
	free_cel(rot_cel);
	freemem(bbuf);
	return(NULL);
	}

/* go do all the twisted calls to make up the segment list */
find_thread(&thread1, 1);
find_thread(&thread2, -1);
fill_sbuf(&thread1, &(rs->dxoff) );
fill_sbuf(&thread2, &(rs->dw) );
add_sxsources(&thread1, &rs->s1);
add_sxsources(&thread2, &rs->s2);
add_sysources(&thread1, &rs->s1.y);
add_sysources(&thread2, &rs->s2.y);
fix_rseg(rs, minmax.ymax);
bap_rrot(b->image, b->line_bytes, rot_cel->image, 
	Raster_line(rot_cel->width), rs, minmax.ymax, bbuf);
freemem(bbuf);
freemem(rs);
if (!mask_cel(rot_cel))
	{
	free_cel(rot_cel);
	return(NULL);
	}
return(rot_cel);
}

Cel *
rot_byte_cel(b, angle, axis)
Byte_cel *b;
WORD angle;
{
Point temp_poly1[4], temp_poly2[4];
WORD i;
WORD cenx, ceny;
WORD z;
Cel *rot_cel;

/* make up polygon to correspond to byte-cel */
sq_poly(b->width, b->height, source_poly);


/* and rotate it into dest_poly */
cenx = (b->width>>1);
ceny = (b->height>>1);
switch (axis)
	{
	case 'x':
		for (i=0; i<4; i++)
			{
			temp_poly1[i].x = 0;
			temp_poly1[i].y = source_poly[i].y - ceny;
			}
		rot_points(angle, temp_poly1, temp_poly2, 4);
		for (i=0; i<4; i++)
			{
			z = temp_poly2[i].x + ground_z;
			dest_poly[i].x = sscale_by(source_poly[i].x - cenx, 
				ground_z, z) + cenx;
			dest_poly[i].y = sscale_by(temp_poly2[i].y,
				ground_z, z) + ceny;
			}
		break;
	case 'y':
		for (i=0; i<4; i++)
			{
			temp_poly1[i].x = source_poly[i].x - cenx;
			temp_poly1[i].y = 0;
			}
		rot_points(angle, temp_poly1, temp_poly2, 4);
		for (i=0; i<4; i++)
			{
			z = temp_poly2[i].y + ground_z;
			dest_poly[i].y = sscale_by(source_poly[i].y - ceny, 
				ground_z, z) + ceny;
			dest_poly[i].x = sscale_by(temp_poly2[i].x,
				ground_z, z) + cenx;
			}
		break;
	case 'z':
		rot_points(angle, source_poly, dest_poly, 4);
		break;
	}
rot_cel = raster_transform(b, dest_poly);
if (rot_cel != NULL)
	{
	/* and keep center in the same place */
	rot_cel->xoff = b->xoff + (b->width>>1) - (rot_cel->width>>1);
	rot_cel->yoff = b->yoff + (b->height>>1) - (rot_cel->height>>1);
	}
return(rot_cel);
}

