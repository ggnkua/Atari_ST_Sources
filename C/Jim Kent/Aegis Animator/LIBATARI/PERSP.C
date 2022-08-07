
#include <osbind.h>		/* st bs */

#define XMAX 320
#define WORD int

/*

 *** note: the following references are external...

	structure pixrect ...
	pr_offset(line_pr)
	pr_get(source_pr,x,y)
	pr_rop(dest_pr,d_lf, this_line, s, 1, MOVE_DATA, line_pr, 0, 0)
	mem_create( dest_pr , 1, FB_DEPTH, LOC_MEMORY)
	mem_destroy( line_pr )
	iproduct( int1, int2 )
	iscale( src_last, this_line, dst_last)

*/
struct point
{
	WORD x,y;
	};

struct line
{
	struct point first;
	struct point second;
	};

struct conv_polygon
{
	struct point *peak;
	struct point *first;
	struct point *last;
	WORD inc_right;
	WORD inc_left;
	WORD right_count;
	WORD left_count;
	};

WORD *cscreen;

struct point spts[4] = { {0, 0}, {100, 0}, {100, 100}, {0, 100} };
struct point dpts[4] = { {100, 100}, {150, 150}, {200, 100}, {150, 50} };
struct conv_polygon spoly = 
	{
	spts,
	spts,
	spts+3,
	1, -1,
	2, 2,
	};

struct conv_polygon dpoly =
	{
	dpts+3,
	dpts,
	dpts+3,
	-1, 1,
	2, 2,
	};

main()
{
/* ST bs */
cscreen = (WORD *)Physbase();
make_ytable();

persp(&spoly, &dpoly);
}

extern struct point *next_vertex();
extern long iproduct();

long iproduct(a, b)
WORD a, b;
{
return( (long)a * (long)b);
}

WORD iscale(p1, p2, q)
WORD p1, p2, q;
{
return( ((long)p1 * (long)p2)/q);
}

/***************************************************************************
*
*	persp(dest,source,dest_pr,source_pr);
*
*dest and source are 2-d polygons: a simple array of count points with the
*last one assumed to connect back to the first one.
*source and dest must have same # of vertices.
*
*persp performs a linear perspective transformation between them.
persp will go ahead and do any polygons without crashing, but the only
*ones where it will make sense are with the destination polygon convex: ie
*no edge crossings, and only one local max and one local min;
****************************************************************************/


persp (dest, source)
struct conv_polygon *dest, *source;
{
char line_buf[XMAX];

	if (!is_rotated (dest,source))
		persp_no_rotation (dest, source);
	else
	{
		struct point   *d_next_lf, *d_next_rt, *s_next_lf, *s_next_rt;
		WORD		  rtct, lfct;
		WORD		  q_lf,q_rt;
		int			n_lf,n_rt;
		int			this_line;
/*variables used to keep track of segment to output*/
		char		   *line_pr_data;
		int			poly_offset;

/*
printf("in persp()");
*/
		line_pr_data = line_buf;

		d_next_lf = d_next_rt = dest->peak;
		poly_offset = dest->peak - dest->first;
		s_next_lf = s_next_rt = source->first + poly_offset;

		lfct = rtct = 0;
		n_lf = n_rt = 1;
		q_lf = q_rt = 0;

		this_line = d_next_lf->y;
		while (rtct <= dest->right_count && lfct <= dest->left_count)
		{
			struct point   *d_this_lf, *d_this_rt, *s_this_lf, *s_this_rt;

			if (n_lf > q_lf)
			{
				do
				{
					lfct++;
					d_this_lf = d_next_lf;
					s_this_lf = s_next_lf;
					d_next_lf = next_vertex (dest, d_next_lf, dest->inc_left);
					poly_offset = d_next_lf - dest->first;
					s_next_lf = source->first + poly_offset;
					} while (d_next_lf->y == d_this_lf->y);
				n_lf = q_lf == 0 ? 0 : 1;
				q_lf = d_next_lf->y - d_this_lf->y;
				}
			if (n_rt > q_rt)
			{
				do
				{
					rtct++;
					d_this_rt = d_next_rt;
					s_this_rt = s_next_rt;
					d_next_rt = next_vertex (dest, d_next_rt, dest->inc_right);
					poly_offset = d_next_rt - dest->first;
					s_next_rt = source->first + poly_offset;
					} while (d_next_rt->y == d_this_rt->y);
				n_rt = q_rt == 0 ? 0 : 1;
				q_rt = d_next_rt->y - d_this_rt->y;
				}

/*
printf("\nnew peak, next line is ");
*/
			for (; n_lf <= q_lf && n_rt <= q_rt; n_lf++, n_rt++)
			{
/* variables for inner loop of double cycle */
/* note the longs must be long!  They are frsults of 3 multiplies of screen
   coordinates.*/
				register WORD sample_count;
				WORD		  x, y, incx, incy, s, d_lf, d_rt;
				long		   a_lf, a_rt, b_lf, b_rt;
				char		  *sp;
				int			color;
/*variables used in setting up double cycle*/
				register long  samples, dx, dy, xcycle, ycycle;
/*
printf(" %d", this_line);
*/
				d_lf = q_lf - n_lf;
				d_rt = q_rt - n_rt;

				a_lf = iproduct (d_lf, s_this_lf->x) +
						iproduct (n_lf, s_next_lf->x);
				a_rt = iproduct (d_rt, s_this_rt->x) +
						iproduct (n_rt, s_next_rt->x);
				b_lf = iproduct (d_lf, s_this_lf->y) +
						iproduct (n_lf, s_next_lf->y);
				b_rt = iproduct (d_rt, s_this_rt->y) +
						iproduct (n_rt, s_next_rt->y);

				d_lf = (iproduct (d_lf, d_this_lf->x) +
					   iproduct (n_lf, d_next_lf->x)) / q_lf;
				d_rt = (iproduct (d_rt, d_this_rt->x) +
					   iproduct (n_rt, d_next_rt->x)) / q_rt;
				s = d_rt - d_lf + 1;
/*
printf("(%d, %d, %d,", q_lf, q_rt, s);
*/

				dx = (q_lf * a_rt - q_rt * a_lf);
				dy = (q_lf * b_rt - q_rt * b_lf);

				x = a_lf / q_lf;
				y = b_lf / q_lf;

/* the below noise is my attempt at maintaining sampling over a
   fractional grid */

				if (dx >= 0)
				{
					incx = 1;
					xcycle = a_lf % q_lf * q_rt * s;
					}
				else
				{
					dx = -dx;
					incx = -1;
					xcycle = (q_lf - a_lf) % q_lf * q_rt * s;
					}

				if (dy >= 0)
				{
					incy = 1;
					ycycle = b_lf % q_lf * q_rt * s;
					}
				else
				{
					dy = -dy;
					incy = -1;
					ycycle = (q_lf - b_lf) % q_lf * q_rt * s;
					}

				samples = iproduct (q_lf, q_rt);

				dx += samples;
				dy += samples;

				samples *= s;
/*
printf(" %ld)", samples);
*/
				xcycle += dx - samples;
				ycycle += dy - samples;
				color = -1;
				sp = line_buf;
				for (sample_count = 0; sample_count < s; sample_count++)
				{
					if (color == -1 && (color = getdot( x, y)) == -1)
						color = 0;

					*sp++ = color;

					if (xcycle >= 0)
					{
						color = -1;
						do
							x += incx;
						while ((xcycle -= samples) >= 0);
						}
					xcycle += dx;

					if (ycycle >= 0)
					{
						color = -1;
						do
							y += incy;
						while ((ycycle -= samples) >= 0);
						}
					ycycle += dy;
					}
				putline(d_lf, this_line, s, line_buf);
				this_line++;
				}
			}
/*
printf("\nexiting persp()\n");
*/
		}
	}


is_rotated (dest, source)
struct conv_polygon *dest, *source;
{
	struct point   *dst_this, *src_this;

	dst_this = dest->peak;
	src_this = source->peak;
	if (dst_this -dest->first == src_this - source->first)
	{
		struct point   *dst_next, *src_next;

		dst_next = next_vertex (dest, dst_this, dest->inc_right);
		src_next = next_vertex (source, src_this, source->inc_right);
		if (dst_next - dest->first == src_next - source->first &&
			(dst_next->x == dst_this->x || dst_next->y == dst_this->y))
			return (0);
		}

	return (1);
	}

persp_no_rotation (dest, source)
struct conv_polygon *dest, *source;
{
	struct point   *dst_rt, *src_rt;
	WORD		  this_line, src_last, dst_last;
	WORD		  dx, samples;
	char line_buf[XMAX];

	dst_rt - dest->peak;

	do
		dst_rt = next_vertex (dest, dst_rt, dest->inc_right);
	while (dst_rt->y == 0);
	src_rt = source->first + (dst_rt - dest->first);

	this_line = 0;
	dst_last = dst_rt->y;
	src_last = src_rt->y;
	samples = dst_rt->x + 1;
	dx = src_rt->x + 1;

	while (this_line <= dst_last)
	{
		register WORD sample_count;
		WORD		  x, y;
		char		  *sp;
		int			color;
		register WORD xcycle;

		x = 0;
		y = iscale ( src_last, this_line, dst_last);
		xcycle = dx - samples;
		color = -1;
		sp = line_buf;
		for (sample_count = 0; sample_count < samples; sample_count++)
		{
			if (color == -1 && (color = getdot ( x, y)) == -1)
				color = 0;

			*sp++ = color;

			if (xcycle >= 0)
			{
				color = -1;
				do
					++x;
				while ((xcycle -= samples) >= 0);
				}
			xcycle += dx;
			}
		do
			putline(0, this_line, samples, line_buf);
		while (++this_line <= dst_last &&
				iscale (src_last, this_line, dst_last) == y);
		}

	}

putline(x, y, width, buf)
WORD x, y;
WORD width;
char *buf;
{
while (--width >= 0)
	putdot(x++, y, *buf++);
}

/***************************************************************************
*
* next_vertex(cv,current,inc)
*	return pointer to next element in conv_polygon list, wrapping
*	at ends of the list if required.
*
**************************************************************************/

struct point *
next_vertex(cv, current, inc)
register struct conv_polygon  *cv;
register struct point		 *current;
WORD						 inc;
{
	register struct point	*next;

	next = current + inc;
	if (next > cv->last) next = cv->first; /* wrap around list end to beg. */
	if (next < cv->first) next = cv->last; /* wrap around list beg to end. */
	return (next);
}





