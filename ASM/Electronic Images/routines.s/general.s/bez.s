#define WORD_BITS	16		/* screen "word" this size in bits */
#define LO_PLANES	4		/* for lo rez */
#define	LO_XMIN		0
#define	LO_XMAX		319
#define	LO_YMIN		0
#define	LO_YMAX		199
#define	LO_XWIDTH	(LO_XMAX - LO_XMIN + 1)
#define LO_YHEIGTH	(LO_YMAX - LO_YMIN + 1)
#define LO_WPLINE	(LO_PLANES * LO_XWIDTH / WORD_BITS)
#define LO_COLORS	(1 << LO_PLANES)
#define CHANGE		0x0f		/* how often to change colors */
#define	NQ		10		/* length of FIFO queue */
#define MAXNQ		50		/* max number of lines (-l) */
#define	FLAT		32L		/* for area convergence */
#define CONSOLE		2		/* BIOS console */
#define	BITS		5
#define SCALE		(1 << BITS)
#define SCALE2		(1 << (BITS-1))

typedef struct
{
	long		b_x[4];
	long		b_y[4];
	int		b_active;

} bez_t;

int	grayscale = 0;				/* for color gray palette */

/*------------------------------*/
/*	bezier			*/
/*------------------------------*/
void bezier (pinfo, x0, y0, x1, y1, x2, y2, x3, y3)
info_t *pinfo;
long	x0;
long	y0;
long	x1;
long	y1;
long	x2;
long	y2;
long	x3;
long	y3;
{

/*	bezier()
 *
 *	Draw the cubic (2d) Bezier curve specified by P0, P1, P2 and P3
 *	by subdividing it recursively into sub-curves until it
 *	can be approximated smoothly by straight line segments.
 *	We use fixed point arithmetic to achieve increased precision
 *	in coordinate computations. The control points have been
 *	scaled with SCALE and 0.5 has been added to the coordinates
 *	so that we can feed rounded coordinate values to draw_line().
 */

	long    v1x,
	        v1y,
	        v2x,
	        v2y,
	        v3x,
	        v3y;
	long    vcp1,
	        vcp2,
	        vcp3,
	        area;
	long    mid_x,
	        mid_y;
	int     code;



	/* 
	 *   Stop the recursion when the size of the area covered
	 *   by the convex hull of the Bezier curve is less than or
	 *   equal to pinfo->i_maxarea.
	 */

	/*
	 *   First, compute direction vectors
	 */
	v3x = x3 - x0;
	v3y = y3 - y0;
	v2x = x2 - x0;
	v2y = y2 - y0;
	v1x = x1 - x0;
	v1y = y1 - y0;
	/*
	 *   Then, compute vector cross products.
	 */
	code = 0;
	if ((vcp1 = v3x * v2y - v2x * v3y) < 0)
		code += 4;
	if ((vcp2 = v3x * v1y - v1x * v3y) < 0)
		code += 2;
	if ((vcp3 = v2x * v1y - v1x * v2y) < 0)
		code += 1;

x0	DC.W 0
y0	DC.W 0
x1	DC.W 0
y1	DC.W 0
x2	DC.W 0
y2	DC.W 0
x3	DC.W 0
y3	DC.W 0

bezier	MOVEM.L D0-D7/A0-A6,-(SP)

	MOVEM.W x0(PC),D0-D7		; x0,y0 =d0,d1 etc
					; x1,y1 =d2,d3
					; x2,y2 =d4,d5
					; x3,y3 =d6,d7
	SUB.W D0,D6			; v3x = x3 - x0; (d6)
	SUB.W D1,D7			; v3y = y3 - y0; (d7)
	SUB.W D0,D4			; v2x = x2 - x0; (d4)
	SUB.W D1,D5			; v2y = y2 - y0; (d5)
	SUB.W D0,D2			; v1x = x1 - x0; (d2)
	SUB.W D1,D3		 	; v1y = y1 - y1; (d3)			
		
	
	MOVE.W D6,D0			; v3x
	MULS D5,D0			; v3x*v2y
	MOVE.W D4,D1			; v2x
	MULS D7,D1			; v2x*v3y
	SUB.W D0,D1			; ((vcp1 = v3x * v2y - v2x * v3y) < 0)
	BGE.S .ok1

		code += 4;
.ok1
	MOVE.W D6,D0			; v3x*v1y
	MULS D3,D0 
	MOVE.W D2,D1			; v1x*v3y
	MULS D7,D1	
	SUB.W D0,D1			; ((vcp2 = v3x * v1y - v1x * v3y) < 0)
	BGE.S .ok2
.ok2   
	
	MOVE.W D4,D0			; v2x
	MULS D3,D0			; v2x*v1y
	MOVE.W D2,D1			; v1x
	MULS D5,D1			; v1x*v2y
	SUB.W D0,D1			; ((vcp3 = v2x * v1y - v1x * v2y) < 0)
	BGE.S .ok3

.ok3

	MOVEM.L (SP)+,D0-D7/A0-A6
	RTS

	/*
	 *   Finally, compute size of area covered by convex hull
	 *
	 *   We actually compute 2*area, but that doesn't matter much.
	 */
	switch (code)
	{
	case 0: 
	case 2: 
	case 5: 
	case 7: 
		area = vcp1 + vcp3;
		break;
	case 1: 
	case 6: 
		area = vcp2 - vcp3;
		break;
	case 3: 
	case 4: 
		area = vcp1 - vcp2;
		break;
	default: 
		return;
	}

	if (code & 4)
		area = -1 * area;



	/*
	 *   converged?
	 */
	if (area <= pinfo->i_maxarea)
	{

/*
 *   Yes. Stop recursion and draw a line from P0 to P3.
 *
 *   Rescale and round coordinates before
 *   feeding them to draw_line()
 */

		draw_line (pinfo,
			((long) x0) >> BITS,
			((long) y0) >> BITS,
			((long) x3) >> BITS,
			((long) y3) >> BITS);

		return;
	}
	else
	{
		/*
		 *   No. Area is still too big, so subdivide the curve into
		 *   two sub-curves and draw these recursively.
		 */
		mid_x = (long) (x0 + (3 * x1) + (3 * x2) + x3) >> 3;
		mid_y = (long) (y0 + (3 * y1) + (3 * y2) + y3) >> 3;

		bezier (pinfo,
			(long) x0,
			(long) y0,
			(long) (x0 + x1) >> 1,
			(long) (y0 + y1) >> 1,
			(long) (x0 + (2 * x1) + x2) >> 2,
			(long) (y0 + (2 * y1) + y2) >> 2,
			(long) mid_x,
			(long) mid_y);

		bezier (pinfo,
			(long) mid_x,
			(long) mid_y,
			(long) (x1 + (2 * x2) + x3) >> 2,
			(long) (y1 + (2 * y2) + y3) >> 2,
			(long) (x2 + x3) >> 1,
			(long) (y2 + y3) >> 1,
			(long) x3,
			(long) y3);

		return;
	}
}




