/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren, this file Dj.Vukovic
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <np_aes.h>
#include <vdi.h>
#include <error.h>
#include <xdialog.h>
#include <boolean.h>
#include "xfilesys.h"
#include "resource.h"
#include "desk.h"
#include "icon.h"
#include "library.h"
#include "window.h"

static XDINFO vidinfo;

extern GRECT xd_desk;

int 
#ifdef _OVSCAN
	ovrstat,	/* state of overscan 	      */
#endif
	vprefsold,	/* previous state of voptions */
	bltstat,	/* presence of blitter        */
	currez;  	/* current screen mode        */    

long
#ifdef _OVSCAN
	over,		/* identification of overscan type */
#endif
	vdo;		/* identification of video hardware- shifter type */
	
/* 
 *  Routine get_set_video acquires data on current state of bliter (if any)
 *  and of current resolution, or sets same data
 */
 
void get_set_video (int set){ /* 0=get, 1=set, 2=set & change rez */

	long
#ifdef _OVSCAN
		s,						/* sup.stack p.        */
#endif
		logb,       			/* logical screen base  */
		phyb;       			/* physical screen base */

#ifdef _OVSCAN
	char
		*acia;

	static int ov_max_h, ov_max_w;

	int std_x[4] = {320,640,1280,0};
	int std_y[4] = {200,400,800,0};
	int idi;
#endif

	/* Where is the screen ? */

	logb = xbios(3); 				/* Logbase();  */
	phyb = xbios(2);				/* Physbase(); */

	if ( set == 0 ){ /* get data */

		/* Find about video hardware (shifter; will be 0xffffffff without cookie */
		
		vdo = find_cookie( '_VDO' );
		
		/* Try to find out about a couple of overscan types */
		
#ifdef _OVSCAN		
		if (   ( (over = find_cookie('OVER')) != - 1 )
		    || ( (over = find_cookie('Lace')) != - 1 ) )
		{

			ovrstat = 0;
			for ( idi = 0; idi < 3; idi++ )
				if ( max_h > std_y[idi] && max_h < std_y[idi + 1] )
				{
					ov_max_w = max_w;
					ov_max_h = max_h;
					ovrstat = 1;
					break;
				}

			if ( ovrstat != 0 )
				options.V2_2.vprefs |= VO_OVSCAN;
			else
				options.V2_2.vprefs &= ~VO_OVSCAN;
		}
		else
			over  = 0xffffffffL;
#endif

		/* Get current blitter state; insert into options  */
  
		if ( get_tosversion() >= 0x104 ) 
			bltstat = Blitmode(-1);   /* Function known only to tos >= 1.4 ? */
		else
			bltstat = 0;
		if ( bltstat & 0x0001 ) 	
			options.V2_2.vprefs |= VO_BLITTER; 
		else
			options.V2_2.vprefs &= ~VO_BLITTER;
    		
		/* Which is the current standard resolution ? */
	
		currez = xbios(4); /* Getrez() */   	
		
		options.V2_2.vrez = currez; 

	}
	else /* set data */
	{	
		/* Set blitter, if present */
	
		if ( bltstat & 0x0002 )
		{
			if ( options.V2_2.vprefs & VO_BLITTER ) 
				bltstat |= 0x0001;	
			else
				bltstat &= ~0x0001;
			bltstat = Blitmode ( bltstat );
		}

#ifdef _OVSCAN
		/* 
		 * Set overscan (Lacescan, in fact)
		 * that which is below is ok but not enough !!!!
		 * therefore disabled for the time being
		 */

		if ( (over != 0xffffffffL ) && ( (vprefsold^options.V2_2.vprefs) && VO_OVSCAN) )
		{

			menu_bar ( menu, 0 ); 

			s = Super (0L );
			(long)acia = 0xFFFC00L; /* address of the acia chip reg  HR 240203 (long) */

			if ( options.V2_2.vprefs & VO_OVSCAN )
			{
				*acia = 0xD6; /* value for the acia reg- switch overscan ON */
				ovrstat = 1;
				max_h = ov_max_h;
				max_w = ov_max_w;
			}
			else
			{
				*acia = 0x96; /* value for the acia reg- switch overscan OFF */
				ovrstat = 0;
				max_w = std_x[idi];
				max_h = std_y[idi];
			}

			/* 
			 * An attempt to change resolution (to the same one) will 
			 * provoke Lacescan to adapt 
			 */

			xbios(5, logb, phyb, currez); 	/* Setscreen (logb,phyb,currez); */ 

			Super ( (void *) s );

			wind_set(0, WF_NEWDESK, desktop, 0); 

			/* 
			 * For some reason desktop doesn't get redrawn correctly here
			 * after overstat switch unless menu_bar is called TWICE
			 * (possibly at first call it is too long and corrupts
			 * part of the screen?)
			 */
			menu_bar(menu, 1); 
			dsk_draw(); 
			menu_bar(menu, 1); 

/*			wd_attrib();		*/
            wd_fields();		/* HR 050303 */
		}	
			
#endif

		/* Change resolution */
		/* xbios(...) produces slightly smaller code */
		
		if ( set > 1 )
		{
			/*
			 * This will actually (almost) reset the computer
			 */

			shel_write( 5, currez + 2, 0, NULL, NULL ); /* DjV 007 110203 */

			/* DjV 007 290103: is no good, so disabled for the time being */

			xbios(5, logb, phyb, currez); 	/* Setscreen (logb,phyb,currez); */ 

		}
	}
}


/* Routine voptions handles video options dialog */ 

int voptions(void){
    
	int 
		button,    /* selected button */
		newrez,    /* desired resolution   */
		rmap[16],  /* map standard resolutions to .rsc objects */
		rimap[32]; /* inverse to above */
	               /* dimensioning will be problematic */
    	           /* if indices in rsc are large */
 
	/* which button to select for which resolution code */ 
  
	rmap[0] = VSTLOW; 
	rmap[1] = VSTMED;  
	rmap[2] = VSTHIGH;
	rmap[4] = VTTMED;  
	rmap[6] = VTTHIGH;
	rmap[7] = VTTLOW;
    
	/* which resolution code is selected by which button */

	rimap[0] = -1; 
	rimap[VSTLOW]  = 0;
	rimap[VSTMED]  = 1;
	rimap[VSTHIGH] = 2;
	rimap[VTTMED]  = 4;
	rimap[VTTHIGH] = 6;
	rimap[VTTLOW]  = 7;
    
	
	/* Find current video configuration */
	
	get_set_video(0);
	
	/* Set radiobutton for current resolution selected */
	
	xd_set_rbutton(vidoptions, VREZOL, rmap[currez]);
	
	/* Which video options are not available? Disable unavailables   */
	/* Or maybe better not- what about graphic cards and multisyncs? */

	
	if ( vdo < 2 )         /* this is a ST/STe-type shifter, disable TT res */
	{	   
		vidoptions[VTTLOW].ob_state  |= DISABLED;
		vidoptions[VTTMED].ob_state  |= DISABLED;
		vidoptions[VTTHIGH].ob_state |= DISABLED;
	
		if ( currez == 2 )   /* st-high? disable low and med res */
		{
			vidoptions[VSTLOW].ob_state  |=  DISABLED;
			vidoptions[VSTMED].ob_state  |=  DISABLED;
			vidoptions[VSTHIGH].ob_state &= ~DISABLED;
		}
		else               /* st-low/med? disable hi res */
		{
			vidoptions[VSTLOW].ob_state  &= ~DISABLED;
			vidoptions[VSTMED].ob_state  &= ~DISABLED;
			vidoptions[VSTHIGH].ob_state |=  DISABLED; 
	  }
	}
	else if ( vdo == 2 )   /* this is a TT */
	{
		if ( currez == 6 ){   /* tt-high? disable low and med res */
			vidoptions[VSTLOW].ob_state  |=  DISABLED;
			vidoptions[VSTMED].ob_state  |=  DISABLED;
			vidoptions[VSTHIGH].ob_state |=  DISABLED;
			vidoptions[VTTLOW].ob_state  |=  DISABLED;
			vidoptions[VTTMED].ob_state  |=  DISABLED;
			vidoptions[VTTHIGH].ob_state &= ~DISABLED; 
		}
		else               /* tt-low/med? disable hi res */
		{
			vidoptions[VSTLOW].ob_state  &= ~DISABLED;
			vidoptions[VSTMED].ob_state  &= ~DISABLED;
	    	vidoptions[VSTHIGH].ob_state &= ~DISABLED;
			vidoptions[VTTLOW].ob_state  &= ~DISABLED;
			vidoptions[VTTMED].ob_state  &= ~DISABLED;
			vidoptions[VTTHIGH].ob_state |=  DISABLED; 
	  }
	}
	else /* other video types- unsupported ??? */
	{	  
	 /* nothing yet */ 
	}

	/* Set button for blitter */
    
	if ( bltstat & 0x0002 )		/* blitter is present */
		set_opt ( vidoptions, options.V2_2.vprefs, VO_BLITTER, VBLITTER );
	else						/* blitter not present */
		vidoptions[VBLITTER].ob_state |=DISABLED;

	/* Palette */

	set_opt ( vidoptions, options.cprefs, SAVE_COLORS, SVCOLORS );

#ifdef _OVSCAN 
	/* Overscan */
  
	if ( (vdo == 0) && ( over != 0xffffffffL ) )
  		set_opt( vidoptions, options.V2_2.vprefs, VO_OVSCAN, VOVERSCN ); 
	else
		vidoptions[VOVERSCN].ob_state |= DISABLED;
#else
	vidoptions[VOVERSCN].ob_flags |= HIDETREE;
#endif
	
	/* Dialog... */
	
	vprefsold = options.V2_2.vprefs;
	button = xd_dialog( vidoptions, 0 );
  
	/* If selected OK ... */
  
	if ( button == VIDOK ){
	  
		/* Save palette */
    
		get_opt( vidoptions, &options.cprefs, SAVE_COLORS, SVCOLORS );
     
		/* Set blitter, (couldn't have been selected if not present) */
    
		get_opt( vidoptions, &options.V2_2.vprefs, VO_BLITTER, VBLITTER);
     
#ifdef _OVSCAN
		/* Set overscan option (could not have been selected if not present) */
   
		get_opt ( vidoptions, &options.V2_2.vprefs, VO_OVSCAN, VOVERSCN ); 
#endif
			
		/* Change resolution ? */
     
		newrez = rimap[xd_get_rbutton(vidoptions, VREZOL)];
		
		get_set_video(1); /* execute settings which do not require a reset */

		if ( newrez != currez && newrez != -1 )
		{
			currez = newrez;	 	/* new becomes old */
			return 1;  		 		/* to initiate resolution change */				
		}
		 
	}	/* OK button ? */
  
	return 0;
}
