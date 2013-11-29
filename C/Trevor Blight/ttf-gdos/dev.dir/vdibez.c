/**************************************************
*
*  example bindings for Bezier curves. 
*
*  This file is provided for info only, it probably needs mods
*/


/*******
 * v_bez_con(int handle, int onoff)
 * 
 * Enable Bezier capabilities.
 * v_bez_on (alias v_bezon) = v_bez_con( handle, 1 )
 * If onoff is 1 then enable Bezier capabilities and
 * Returns maximum Bezier depth (a measure of smoothness). The return
 * value can range from 0-7, and is the exponent of 2, giving the
 * number of line segments that make up the curve. 
 * 0 == 2**0 == 1 == straight line and
 * 7 == 2**7 == 128 line segments.
 *
 *
 * Disable Bezier capabilities.
 * v_bez_off (alias v_bezoff) = v_bez_con( handle, 0 )
 * If onoff is 0 then disable Bezier capabilities and
 * release memory allocated in v_set_app_buff call.
 * Returns NOTHING!
 *
 * note: beziers are always enabled in ttf-gdos
 * ie v_bez_con() ignores the onoff parameter,
 *                it just returns the current bezier depth
 *    v_bez_on()  returns the bezier depth
 *    v_bez_off() has no effect
 */

int v_bez_con(int handle, int onoff)
{
	_control[0] = 11;
	_control[1] = onoff;
	_control[3] = 0;
	_control[5] = 13;
	_control[6] = handle;
	vdi(&vdi_params);
   return(_intout[0]);
}

int v_bez_on(int handle)
{
   return v_bez_con( handle, 1 );
}

void v_bez_off(int handle)
{
   (void)v_bez_con( handle, 0 );
}


/*************
 * Draw an unfilled Bezier curve
 *    xyarr   - an array of 'count' pairs of control vertices
 *    bezarr  - an array of flags specifying which control points
 *		are jump points
 *              bit 0  off - start of a polyline if not continuation
 *              bit 0  on  - start of a Bezier segment
 *              bit 1  on  - jump point (move to the next one without draw)
 *
 * Returns - a number of points in a Bezier curve
 */

void
v_bez(     int	 handle,   /* Device handle we're drawing to */
           int   count,	   /* Number of points total... */
	   int  *xyarr,	   /* The points in x1,y1,x2,y2 format */
	   char	*bezarr,   /* Flag array, so that we can set start, jump pts */
	   int	*extent,   /* "bounding box coordinates */
	   int	*totpts,   /* number of resulting polygon points */
	   int	*totmoves) /* number of resulting moves  */
{
    short *end;
    char *pbd = bezarr;
    char *opbd = (char *)_intin;
#ifndef __MSHORT__
    short *optr;
    int *iptr = xyarr;
#endif

    /* copy entries from bezarr to _intin packing and swaping bytes ???! */
    /* this requirement for byte swapping  is not documented - if you    */
    /* discount some old code example, but things seem to work this way  */
    end  = (short *) (pbd + count);
    while (pbd < (char *)end) {
	*(opbd + 1) = *pbd++;
	if (pbd >= (char *)end)
	    break;
	*opbd = *pbd++;
	opbd += 2;
    }
#ifdef __MSHORT__
    _vdiparams[2] = (void *) xyarr;
    _vdiparams[4] = (void *) extent;
#else
    /* copy xyarr into an array of shorts */

	optr = _ptsin;
	end  = optr + count + count;
	while (optr < end)
	    *optr++ = *xyarr++;
#endif

	_control[0] = 6;
	_control[1] = count;
	_control[3] = ((count + 1) >> 1);
	_control[5] = 13;
	_control[6] = handle;
	vdi(&vdi_params);

#ifdef __MSHORT__
    /* restore standard parameter block */ 
    _vdiparams[2] = (void *) _ptsin;
    _vdiparams[4] = (void *) _ptsout;
#else
    optr = _ptsout;
    iptr = extent;
    *iptr++ = *optr++;
    *iptr++ = *optr++;
    *iptr++ = *optr++;
    *iptr   = *optr;
#endif
    *totmoves = _intout[1];
    *totpts = _intout[0]; 	/* number of points in Bezier */
}




/***********
 * v_bez_fill (alias _v_bezfill)
 * Draw a filled Bezier curve
 *    xyarr   - an array of 'count' pairs of control vertices
 *    bezarr  - an array of flags specifying which control points
 *		are jump points
 *              bit 0  off - start of a polyline if not continuation
 *              bit 0  on  - start of a Bezier segment
 *              bit 1  on  - jump point (move to the next one without draw)
 * Returns - a number of points in a filled Bezier curve
 */

void
v_bez_fill(int handle,	   /* Device handle we're drawing to */
           int   count,	   /* Number of points total... */
	   int  *xyarr,	   /* The points in x1,y1,x2,y2 format */
	   char	*bezarr,   /* Flag array, so that we can set start, jump pts */
	   int	*extent,   /* "bounding box coordinates */
	   int	*totpts,   /* number of resulting polygon points */
	   int	*totmoves) /* number of resulting moves  */
{
    short *end;
    char *pbd = bezarr;
    char *opbd = (char *)_intin;
#ifndef __MSHORT__
    short *optr;
    int *iptr = xyarr;
#endif

    /* copy entries from bezarr to _intin packing and swaping bytes ???! */
    /* this requirement for byte swapping  is not documented - if you    */
    /* discount some old code example, but things seem to work this way  */
    end  = (short *) (pbd + count);
    while (pbd < (char *)end) {
	*(opbd + 1) = *pbd++;
	if (pbd >= (char *)end)
	    break;
	*opbd = *pbd++;
	opbd += 2;
    }
#ifdef __MSHORT__
    _vdiparams[2] = (void *) xyarr;
    _vdiparams[4] = (void *) extent;
#else
    /* copy xyarr into an array of shorts */

	optr = _ptsin;
	end  = optr + count + count;
	while (optr < end)
	    *optr++ = *xyarr++;
#endif

	_control[0] = 9;
	_control[1] = count;
	_control[3] = ((count + 1) >> 1);
	_control[5] = 13;
	_control[6] = handle;
	vdi(&vdi_params);

#ifdef __MSHORT__
    /* restore standard parameter block */ 
    _vdiparams[2] = (void *) _ptsin;
    _vdiparams[4] = (void *) _ptsout;
#else
    optr = _ptsout;
    iptr = extent;
    *iptr++ = *optr++;
    *iptr++ = *optr++;
    *iptr++ = *optr++;
    *iptr   = *optr;
#endif
    *totmoves = _intout[1];
    *totpts = _intout[0]; 	/* number of points in Bezier */
}


/************
 * v_bez_qual
 * Set the quality / speed tradeoff when drawing Beizier curve
 * quality is given in percents
 * 
 * Returns an actual quality set.
 *
 */
int
v_bez_qual (int handle, int percent, int *actual)
{
    short *wptr = _intin;

    *wptr++ = 32;
    *wptr++ = 1;
    *wptr  = percent;

     wptr = (short *)_contrl;
    *wptr++ = 5;	/* 0  - opcode */
    *wptr++ = 0;	/* 1 */
     wptr++;		/* 2 */
    *wptr++ = 3;	/* 3  - # of entries in _intin */
     wptr++;	   /* 4 */
    *wptr++ = 99;	/* 5 - id */
    *wptr   = handle;	/* 6 - handle */
	 vdi(&vdi_params);		/* call vdi */
    
    return (*actual = *_intout);
}

/* -eof- */
