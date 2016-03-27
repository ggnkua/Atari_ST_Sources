/********************************************************************/
/* 				MatDigi Save A File									*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 15.09.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler		*/
/*																	*/
/********************************************************************/

# include <stdlib.h>
# include <portab.h>
# include <aes.h>
# include <stdio.h>
# include <string.h>
# include <vdi.h>
# include <tos.h>

# include <global.h>

# include <picfiles.h>
# include "..\matdigi\fastrom.h"
# include "..\matdigi\md_video.h"

# include "savefile.h"
# include "select.h"
# include "menus.h"
# include "dwind.h"

# define mouse_on()		graf_mouse ( M_ON, (MFORM *)0 )
# define mouse_off()	graf_mouse ( M_OFF, (MFORM *)0 )
# define mouse_arrow()	graf_mouse ( ARROW, (MFORM *)0 )
# define mouse_busy()	graf_mouse ( BUSYBEE, (MFORM *)0 )


extern int			whole ;
extern void redraw_window ( unsigned wnum ) ;

/*------------------------------------------ display_err ------------*/
void display_err ( int result )
{
		switch ( result )
		{
case OK :			break ;
case CANTcreate : 	form_alert ( 1, get_free_string ( AL_NAME ) ) ;
					break ;
case CANTwrite : 	form_alert ( 1, get_free_string ( AL_SAVE ) ) ;
					break ;
case NOmemory :		form_alert ( 1, get_free_string ( AL_MEM ) ) ;
					break ;
default :			form_alert ( 1, get_free_string ( AL_ERR ) ) ;
/*					printf ("Error num = %d\n", result ) ; */
		}
}


/*------------------------------------------ save_a_file ------------*/
void save_a_file ( int wnum, RECTangle *win, POINT *vid,
				   int vfactor, int *drive )
{
	int  result = CANTwrite ;
	RECTangle save_area;
	int thandle ;
	char fname[STPATHLEN + STFILELEN] = {"*.*"} ;
	OBJECT *dialtree ;
	RECTangle rect, fr ;
	POINT save_pt;
	
	if ( *drive == CURRENT_DRIVE )
		 *drive = GetDrive() ;

	if ( NoPath ( *drive ) )
		InitPath ( *drive ) ;
		
	SetDrive ( *drive ) ;
	
	if ( op_fbox_name ( "w", "???", fname, drive ) != 0 )
	{	/* check if file already exists */
		redraw_window ( wnum ) ;
# define ABBRUCH_BUT 1
# define OVERW_BUT 2
		if ( ( thandle = (int) Fopen ( fname, FO_READ ) ) >= 0 )		/* file exists */
			if ( form_alert ( OVERW_BUT,
							  get_free_string ( AL_OVERW ) )
							  == ABBRUCH_BUT )
			{	/* close the file again */
				Fclose ( thandle ) ;
				return ;
			}
			
		/* check name has been entered */
		if ( fname [strlen ( fname ) -1] == '\\' )
		{
			display_err ( CANTcreate ) ;
			return ;
		}
		
		/* check extension */
		switch ( pic_file_type ( fname ) )
		{
case YCfile :	
case ESMfile :
case TIFfile :	break ;
default :		form_alert ( 1, get_free_string ( AL_EXT ) ) ;
		}

		/* switch digitiser to large format */
		if ( vfactor == 4 )
		{
			set_rom_vfact ( 7 ) ;
			grab_rom ( 7 ) ;

			/* adjust area to be saved for vfactor 8 */
			save_pt.x   = vid->x * 2 ;	/* border_x ? */
			save_pt.y   = vid->y * 2 ;	/* head_y ? */
			save_area.x = win->x ;		/* not used */
			save_area.y = win->y ;		/* not used */
			save_area.w = win->w * 2 ;
			save_area.h = win->h * 2 ;
		}
		else /* vfactor 8 */
		{
			save_pt.x   = vid->x ;	/* border_x ? */
			save_pt.y   = vid->y ;	/* head_y ? */
			save_area.x = win->x ;		/* not used */
			save_area.y = win->y ;		/* not used */
			save_area.w = win->w ;
			save_area.h = win->h ;
		}

/*********** Save file here ***********************/
		mouse_busy() ;
		UpdateTreeString ( MD_MESG, MTXT_MESG1, get_free_string ( T_SAVE ) ) ;
		UpdateTreeString ( MD_MESG, MTXT_MESG2, fname ) ;
# define NO_EDIT 0
		if ( rsrc_gaddr ( R_TREE, MD_MESG, &dialtree ) != 0)
			mopen_dialog ( NULL, 0, dialtree, &rect, &fr ) ;

		if ( whole )
			result = fetch_and_save ( fname, NULL, NULL,
									  &yc_buffer, &esm_buffer ) ;
		else
			result = fetch_and_save ( fname, &save_area, &save_pt,
									  &yc_buffer, &esm_buffer ) ;
									  
		mclose_dialog ( NULL, 0, &rect, &fr ) ;
		mouse_arrow() ;
/**************************************************/

		display_err ( result ) ;
		if ( result == CANTwrite )
			Fdelete ( fname ) ;

		if ( vfactor == 4 )
		{
			set_rom_vfact ( 3 ) ;
			grab_rom ( 3 ) ;
		}
	}
}

