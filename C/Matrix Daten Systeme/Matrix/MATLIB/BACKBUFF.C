#include <vdi.h>
#include <aes.h>

#include <global.h>

#include "\pc\cxxsetup\aesutils.h"
#include "\pc\cxxsetup\main.h"

#include "backbuff.h"


local MFDB *background_buffer = NULL ;
local MFDB vdi_screen = { NULL } ;
local bool back_buffer_used = FALSE ;

/*--------------------------------------- set_back_buffer_usage ----*/
bool set_back_buffer_usage ( bool set )
{
	if ( set )
		background_buffer = get_aes_buffer ( 128, 128 ) ;	/* dummy rect */
	else
		background_buffer = NULL ;
	return background_buffer != NULL ;
}

/*--------------------------------------------- set_pxy -----*/
local bool set_pxy ( TRectangle *rect,
			   int *bufpxy, int *scrpxy )
{
# if TEST
	if (   (unsigned)rect->w > (unsigned)background_buffer->fd_w
		|| (unsigned)rect->h > (unsigned)background_buffer->fd_h )
	{
		printf ( "*** save window overflow\n" ) ;
		return FALSE ;
	}
# endif

	bufpxy[0] = 0 ;						/* buffer contents = window	*/
	bufpxy[1] = 0 ;
	bufpxy[2] = rect->w - 1 ;
	bufpxy[3] = rect->h - 1 ;

	scrpxy[0] = rect->x ;				/* screen	*/
	scrpxy[1] = rect->y ;
	scrpxy[2] = rect->x + rect->w - 1 ;
	scrpxy[3] = rect->y + rect->h - 1 ;

	return TRUE ;
}



/*--------------------------------------------- save_background -----*/
void save_background ( TRectangle *rect )
{
			/* source = screen	window,	  dest = buffer */
	if ( ! back_buffer_used && background_buffer != NULL && chk_aes_buffer ( rect->w, rect->h ) )
	{
		int pxyarray[8] ;

		back_buffer_used = TRUE ;
		if ( set_pxy ( rect, &pxyarray[4], &pxyarray[0] ) )
		{
			MouseOff();
			vro_cpyfm ( vdi_handle, S_ONLY, pxyarray,
						&vdi_screen, background_buffer ) ;
			MouseOn();
		}
	}
	else
	{
		back_buffer_used = FALSE ;
		FormDialStart(*rect);
	}
}


/*--------------------------------------------- restore_background -----*/
void restore_background ( TRectangle *rect )
{
	if ( back_buffer_used  )
	{
		int pxyarray[8] ;
				/* source = buffer,	  dest = screen	window */
		if ( set_pxy ( rect, &pxyarray[0], &pxyarray[4] ) )
		{
			MouseOff();
			vro_cpyfm ( vdi_handle, S_ONLY, pxyarray,
						background_buffer, &vdi_screen ) ;
			MouseOn();
		}
		back_buffer_used = FALSE ;
	}
	else
	{
		FormDialFinish(*rect);
	}
}

