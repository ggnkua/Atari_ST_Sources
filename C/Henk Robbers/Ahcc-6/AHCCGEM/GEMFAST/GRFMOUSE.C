/**************************************************************************
 *
 *************************************************************************/

#include "gemf.h"

#undef graf_mouse   /* undo remapping, we have to call The Real Thing. */

#ifndef NULL
  #define NULL 0L
#endif

/*
 * when returning the prior shape, we can't return the ARROW shape as
 * zero, because that looks like a failure of graf_mouse().  instead,
 * we return GRF_MSALTARROW.  when we're asked to set the shape to GRF_MSALTARROW,
 * we translate it back to ARROW before passing it to GEM.
 */

/*
 * GEM starts programs up with BUSYBEE as the initial shape...
 */

static int  lastshape = BUSYBEE;
static void *lastform = NULL;

int grf_mouse( int shape, void *pform)
{
	int retshape;

	retshape = lastshape;

	if (shape <= USER_DEF)		/* if it's not just M_ON or M_OFF... */
	{
		if (shape == GRF_MSINQUIRE)
		{									/* if the caller wants inquiry */
			if (pform != NULL)				/* without change, return the  */
				*(void **)pform = lastform; /* form pointer (if we were    */
											/* given somewhere to return   */
			return retshape;				/* it to) & return lastshape.  */

		} else
		{
			lastshape = (shape == ARROW) ? GRF_MSALTARROW : shape;

			if (shape == USER_DEF)
			{								/* if we're changing to a      */
				if (pform == NULL)
				{							/* user-defined shape, and     */
					pform = lastform;   	/* weren't given a pointer to  */
				} else {					/* it, restore the last udef   */
					lastform = pform;   	/* shape, else remember this   */
				}   						/* as the last udef shape.     */

			} else if (shape == GRF_MSALTARROW)	/* if we were given GRF_MSALTARROW  */
				shape = ARROW;  			/* to set, change it back to   */
											/* the normal ARROW.		   */
		}
	}

	if (0 == graf_mouse(shape, pform))		/* do it.  if it fails, change */
		retshape = 0;   					/* our return value to indicate*/
											/* failure. 				   */

	return retshape;	/* return prior mouse shape. */
}

