# define TEST 0

# if TEST
# include <stdio.h>
# endif

#include <vdi.h>
#include <aes.h>

# include <global.h>

#include "aesutils.h"
#include "windows.h"
#include "main.h"

int work_in[12] = {1,1,1,1,1,1,1,1,1,1,2} ;

int appl_id,
	colors,
	bit_planes,
	palette_support,
	scr_max_x,
	scr_max_y,
    vdi_handle,
	hwchar, hhchar,
	hwbox, hhbox,
	dummy;

POINT screen_size ;	/* dimension	*/

OBJECT *menu_tree = NULL ;
bool   menu_shown = FALSE ;
int		menu_id = -1 ;

int		   base_mouse_form = ARROW ;


/*------------------------------------------------- mouse_event ------*/
void mouse_event ( MOUSEevent *mous_evt )
{
	base_mouse_form = mous_evt->form[mous_evt->state] ;
	graf_mouse ( base_mouse_form, 0 ) ;
	mous_evt->state = 1 - mous_evt->state ;	/* toggle direction	*/
}


/*------------------------------------------------- show_menu -----*/
void show_menu ( void )
{
	if ( menu_tree != NULL && ! menu_shown )
	{
		MenuShow ( menu_tree ) ;
		menu_shown = TRUE ;
	}
}

/*------------------------------------------------- hide_menu -----*/
void hide_menu ( void )
{
	if ( menu_tree != NULL && menu_shown )
	{
		MenuHide ( menu_tree ) ;
		menu_shown = FALSE ;
	}
}


/*------------------------------------------------------- not_impl ------------*/
void not_impl(void)
{
	form_alert ( 1, "[3][| To do !!! ][Abbruch]" ) ;
}

# ifndef AP_TERM	/* MINT	*/
# define AP_TERM		50
# define SHUT_COMPLETED	60
# endif

/*--------------------------------------------- message_event ---------------*/
bool message_event(int buffer[])
# define acc_id			buffer[3]
# define buffer_handle	buffer[3]
# define buffer_rect	((RECTangle *)&buffer[4])
# define menu_title		buffer[3]
# define menu_entry		buffer[4]
# define new_pos		buffer[4]
# define arrow			buffer[4]
{
	bool	result ;
	int topwind ;

	switch(buffer[0])
	{
case AC_OPEN:	open_application_window(0,NULL);
				return ( TRUE ) ;

case AC_CLOSE:	clear_windows();
				/*
				if( acc_id == menu_id) term_windows();
				*/
				return ( TRUE ) ;

case AP_TERM :	/*
				printf ( "\nAP_TERM, reason : %d\n", buffer[5] ) ;
				*/
				term_windows();
				return ( TRUE ) ;

case MN_SELECTED :
				WindGetTop ( topwind ) ;
				if ( topwind >= 0 )
					result = menu_window ( find_window ( topwind ), menu_entry ) ;
				else
					result = TRUE ;
	            MenuNormal ( menu_tree, menu_title );
	            return ( result ) ;
				
case WM_CLOSED:	remove_window ( find_window ( buffer_handle ) ) ;
				if( windows_open() )
					WindSetTop ( first_open_handle() ) ;
				return ( TRUE ) ;
				
case WM_REDRAW:	redraw_window ( find_window ( buffer_handle ), buffer_rect ) ;
				break;
				
case WM_MOVED:	move_window( find_window ( buffer_handle ), buffer_rect ) ;
				break;

case WM_NEWTOP: 				
case WM_TOPPED:	WindSetTop( buffer_handle );
				return ( TRUE ) ;
			
case WM_FULLED: full_size_window ( find_window ( buffer_handle ) ) ;
				return ( FALSE ) ;
				
case WM_ARROWED:arrow_window ( find_window ( buffer_handle ), arrow ) ;
				return ( FALSE ) ;
				
case WM_HSLID : hslide_window ( find_window ( buffer_handle ), new_pos ) ;
				return ( FALSE ) ;
				
case WM_VSLID : vslide_window ( find_window ( buffer_handle ), new_pos ) ;
				return ( FALSE ) ;
				
case WM_SIZED : size_window ( find_window ( buffer_handle ), buffer_rect ) ;
				return ( FALSE ) ;
	}
	return ( FALSE ) ;
}
		


/*------------------------------------------------- main_loop ------*/
void main_loop(void)
{
	int event,
		buffer[8] ;
	WINDOWhandle topw ;
	WINDOWdescr  *top_window ;
	
	while( (!_app) || windows_open() )
	{
		WindGetTop ( topw ) ;
		top_window = find_window ( topw ) ;
		if( legal_window ( top_window ) )
		{
			event_window ( top_window ) ;
		}
		else
		{
			event = evnt_multi(	MU_MESAG,
			     		0,0,0,	0, R0,	0, R0, buffer, 0,0,
 		    			&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
		
			if(event & MU_MESAG)	message_event ( buffer ) ;
		}
	}
}


/*------------------------------------------------- run_program -----*/
void run_program(int argc,char *argv[])
{
	if ( menu_num_tree < 0
		|| rsrc_gaddr ( R_TREE, menu_num_tree, &menu_tree ) == 0 )
			menu_tree = NULL ;
    MouseArrow();
   	if( open_application_window(argc,argv) )
		main_loop();
}


/*------------------------------------------------- run_accesory -----*/
void run_accessory(void)
{
	menu_id = menu_register( appl_id, acc_menu_title );
	if(menu_id >= 0)
		main_loop();
}



/*-------------------------------------------------- main ------------*/
int main(int argc,char *argv[])
{
    int work_out[57] ;

	appl_id = appl_init();
	
	if ( appl_id >= 0 )
	{
# if TEST
printf ( "\033Y$$appl_id = %d\n", appl_id ) ;
# endif
		vdi_handle = graf_handle ( &hwchar, &hhchar, &hwbox, &hhbox ) ;

		v_opnvwk( work_in,&vdi_handle,work_out);
		if( vdi_handle >= 0 )
		{
			scr_max_x		= work_out[0] ;
			scr_max_y		= work_out[1] ;
			screen_size.x	= work_out[0] + 1 ;
			screen_size.y	= work_out[1] + 1 ;
			colors 			= work_out[13] ;
			
			vq_extnd ( vdi_handle, 1, work_out ) ;
		    bit_planes = work_out[4] ;
		    palette_support = work_out[5] ;
# if TEST
			printf ( "bpp=%d, pal=%d\n", bit_planes, palette_support ) ;
			getchar() ;
# endif			
			if( rsrc_load(rsc_filename) != 0 )
			{
				init_windows() ;
				if( init_application() )
				{				
	    			if ( application )
						run_program(argc,argv) ;
					else
						run_accessory() ;
	
					term_application();
				}

				term_windows() ;
				rsrc_free();
			}
			else
			{
				form_alert( 1, "[3][| Fehler beim Lesen | der Resourcedatei ][ OK ]" ) ;
	    		if ( accessory )	/* if accessory : loop	*/
				{
					for(;;)
					{
						evnt_multi(	0,
			     			0,0,0,	0, R0,	0, R0, NULL, 0,0,
 		    				&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
					}
				}
			}
			v_clsvwk(vdi_handle);
		}
		appl_exit();
	}
	return(0);
}