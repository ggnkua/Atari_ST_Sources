/********************************************************************/
/* 				MatDigi Multi-Windows Program						*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 15.09.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler		*/
/*																	*/
/********************************************************************/
# define TEST 0
# define DEBUG

# define RSC_NAME "DWIND.RSC"

# include <stdlib.h>
# include <portab.h>
# include <aes.h>
# include <tos.h>
# include <stdio.h>
# include <scancode.h>
# include <string.h>
# include <linea.h>
# include <vdi.h>
# include <ext.h>

# include <global.h>
# include <fast.h>
# include <cookie.h>

# include <picfiles.h>
# include "..\matdigi\fastrom.h"
# include "..\matdigi\md_vmer.h"
# include "..\matdigi\md_video.h"

# include "\pc\tcxx\chips\i2c_hdg.h"
# include "digitise.h"

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\dialog.h"

# include "select.h"
# include "savefile.h"
# include "dwind.h"
# include "menus.h"
# include "coltable.h"
# include "mdr_vers.h"

# define V_DX		(PIXWIDTH)
# define V_DY		(PIXHEIGHT)

# define MIN_DELAY	1		/* ms */
# define GEM_DELAY	50	 	/* ms */
# define INIT_DELAY 750		/* ms */
# define NOMD_DELAY 1000	/* ms */

# define MAXvdiLevel 1000

# define mouse_on()		graf_mouse ( M_ON, (MFORM *)0 )
# define mouse_off()	graf_mouse ( M_OFF, (MFORM *)0 )
# define mouse_arrow()	graf_mouse ( ARROW, (MFORM *)0 )
# define mouse_busy()	graf_mouse ( BUSYBEE, (MFORM *)0 )

extern 		int _app;

int    		phys_handle, vdi_handle ;
int	   		hwchar, hhchar, hwbox, hhbox ;
int			x_page, y_page ;

int    		appl_id = -1, menu_id = -1, dummy ;
PALETTE 	palette ;
int    		*phys_to_vdi ;

int      	colours ;
int		 	l_time ;
int 		old_msg = 0;

bool		acc_opened = FALSE ;

/* ------------------------------------------------- aes_delay ------- */
void aes_delay ( int ms )
{
	evnt_timer ( ms, 0 ) ;
}

/*--------------------------------------------- calc_x_slider -----*/
void calc_x_slider ( unsigned wnum, int pos1000,
					 RECTangle *win, POINT *vid )
{
	int		picw ;
	long	vid_pos ;

	wind_set ( whandle[wnum], WF_HSLIDE, pos1000 ) ;
	picw = V_DX * vfactor[wnum] / 8 - border_x - win->w ;
	vid_pos = (long)pos1000 * (long)picw / 1000L ;
	vid->x = (int)vid_pos ;
}


/*--------------------------------------------- calc_y_slider -----*/
void calc_y_slider ( unsigned wnum, int pos1000,
					 RECTangle *win, POINT *vid )
{
	int		pich ;
	long	vid_pos ;

	wind_set ( whandle[wnum], WF_VSLIDE, pos1000 ) ;
	pich = V_DY * vfactor[wnum] / 8 - head_y - win->h ;
	vid_pos = (long)pos1000 * (long)pich / 1000L ;
	vid->y = (int)vid_pos ;
}


/*--------------------------------------------- update_x_slider -----*/
void update_x_slider ( unsigned wnum, RECTangle *win, POINT *vid )
{
	int		vidw ;
	long	wxl, wwl ;				/* scaled x, w */

	vidw = ( V_DX * vfactor[wnum] / 8 ) - border_x ;

	vid->x = max ( vid->x, 0 ) ;
	vid->x = min ( vid->x, vidw - win->w ) ;

	wwl = 1000L * (long) win->w / (long) vidw ;

	if ( vidw != win->w )
		wxl = 1000L * (long) vid->x / (long) ( vidw - win->w ) ;	  
	else
		wxl = 1000L ;

	wind_get ( whandle[wnum], WF_HSLIDE, &vidw ) ;
	if ( vidw !=  (int) wxl )
		wind_set ( whandle[wnum], WF_HSLIDE,  (int) wxl ) ;
	wind_set ( whandle[wnum], WF_HSLSIZE, (int) wwl ) ;

	x_page = win->w ;
}


/*--------------------------------------------- update_y_slider -----*/
void update_y_slider ( unsigned wnum, RECTangle *win, POINT *vid )
{
	int		vidh ;
	long	wyl, whl ;		/* scaled y, h */

	vidh = V_DY * vfactor[wnum] / 8 - head_y ;

	vid->y = max ( vid->y, 0 ) ;
	vid->y = min ( vid->y, vidh - win->h) ;

	whl = 1000L * (long) win->h / (long) vidh ;

	if ( vidh != win->h )
		wyl = 1000L * (long) vid->y / (long) ( vidh - win->h ) ;
	else
		wyl = 1000L ;

	wind_get ( whandle[wnum], WF_VSLIDE, &vidh ) ;
	if ( vidh !=  (int) wyl )
		wind_set ( whandle[wnum], WF_VSLIDE,  (int) wyl ) ;
	wind_set ( whandle[wnum], WF_VSLSIZE, (int) whl ) ;

	y_page = win->h ;
}


/*--------------------------------------------- update_sliders -----*/
void update_sliders ( unsigned wnum, RECTangle *win, POINT *vid )
{
	update_x_slider ( wnum, win, vid ) ;
	update_y_slider ( wnum, win, vid ) ;
}


/* ------------------------------------------- chk_window ------ */
void chk_window ( unsigned wnum, RECTangle *win, RECTangle *curr, POINT *vid )
{
	if ( curr->x < 0 ) curr->x = 0 ;
	if ( curr->y < MENUY ) curr->y = MENUY ;
	wind_set ( whandle[wnum], WF_CURRXYWH, curr->x, curr->y, curr->w, curr->h ) ;
	wind_get ( whandle[wnum], WF_WORKXYWH, &win->x, &win->y, &win->w, &win->h ) ;
	win->w = min ( win->w, screen_size.x - win->x ) ;
	win->h = min ( win->h, screen_size.y - win->y ) ;
	update_sliders ( wnum, win, vid ) ;
}


/* ------------------------------------------- calc_window ------ */
void calc_window ( unsigned wnum, RECTangle *win, POINT *vid )
{
	RECTangle   desk ;
	RECTangle	curr ;
	int			winw, winh ;

	wind_get ( 0, WF_WORKXYWH, &desk.x, &desk.y,
							   &desk.w, &desk.h );

	winw = ( V_DX * vfactor[wnum] / 8 ) - border_x ;
	winh = ( V_DY * vfactor[wnum] / 8 ) - head_y ;
	
	curr.x = ( 20 * wnum ) +  8 * ( max_x - winw - FRAMEX - SLIDEX ) / 16 ;
	curr.y = ( 20 * wnum ) + ( desk.y + ( max_y - winh - FRAMEY - SLIDEY ) ) / 2 ;
	curr.w = min ( max_x, winw + FRAMEX + SLIDEX ) ;
	curr.h = min ( max_y - MENUY, winh + FRAMEY + SLIDEY ) ;
	
	vid->x = 0 ;
	vid->y = 0 ;

	chk_window ( wnum, win, &curr, vid ) ;
}


/*--------------------------------------------- set_window_title -----*/
void set_window_title ( unsigned wnum )
{
	if ( wnum < NUMofWINDOWS )
	{
		get_window_title ( wnum, title[wnum] ) ;	
		wind_set ( whandle[wnum], WF_NAME, title[wnum] ) ;
	}
}


/*------------------------------------------------ auto_check ----*/
void auto_check ( unsigned wnum )
{
	if ( madi_ok )
	{
		video_signal[wnum] = PUP_AUTO ;
		video_source[wnum] = PUP_AUTO ;
		mouse_busy () ;
		chk_set_chan_sig ( (int *)&video_source[wnum],
						   (int *)&video_signal[wnum],
						   (int *)&dummy ) ;
		mouse_arrow () ;

		if ( ( video_signal[wnum] != PUP_AUTO ||
			   video_source[wnum] != PUP_AUTO ) )
			set_window_title ( wnum ) ;

		check_source_pop ( wnum ) ;
		check_signal_pop ( wnum ) ;
	}
}


/* ------------------------------------------- open_window ------ */
void open_window ( unsigned wnum, int fac )
{
	if ( whandle[wnum] < 0 )
	{
		vfactor[wnum] = fac ;
		check_format_pop ( wnum ) ;
		whandle[wnum] = wind_create ( WINDOW_TYPE,
									  0, MENUY,
									  screen_size.x,
									  screen_size.y - MENUY ) ;
		if ( whandle[wnum] <= 0 )
			return ;
		wind_open ( whandle[wnum], 0, MENUY, 0, 0 ) ;
		calc_window ( wnum, &window[wnum], &video_pos[wnum] ) ;
		set_window_title ( wnum ) ;
		win_open[wnum] = TRUE ;
	}
}


/* ------------------------------------------- recalc_open_window ------ */
void recalc_open_window ( unsigned wnum, RECTangle *win )
{
	RECTangle	curr ;

	curr.x = win->x - FRAMEX ;
	curr.y = win->y - FRAMEY ;
	curr.w = win->w + FRAMEX + SLIDEX ;
	curr.h = win->h + FRAMEY + SLIDEY ;

	wind_open ( whandle[wnum],
				curr.x, curr.y,
 				curr.w, curr.h ) ;
}

/* ------------------------------------------- reopen_window ------ */
void reopen_window ( unsigned wnum, int fac )
{
# if TEST
	printf ("+reopen_window\n");
# endif TEST
	if ( whandle[wnum] >= 0 )
	{
		check_format_pop ( wnum ) ;
		if ( !win_open[wnum] )
		{
			recalc_open_window ( wnum, &window[wnum] ) ;
			win_open[wnum] = TRUE ;
		}
	}
	else
		open_window ( wnum, fac ) ;
# if TEST
	printf ("-reopen_window\n");
# endif TEST
}


/* ---------------------------------------- next_vfactor -------- */
int next_vfactor ( int vfac )
{
	int vf;
	
	vf = 12 - vfac ;
	set_rom_vfact ( vf - 1 ) ;
	return ( vf ) ;
}


/* ----------------------------------- set_clip_box --------------- */
void set_clip_box ( RECTangle *box, int *clip )
{
	int *c0 ;
	
	c0 = clip ;
    *clip++ = box->x;
    *clip++ = box->y;
    *clip++ = box->x + box->w - 1;
    *clip++ = box->y + box->h - 1;

    vs_clip ( vdi_handle, 1, c0 ) ;
}

int test_color = WHITE ;

/* ----------------------------------- test_output --------------- */
void test_output ( RECTangle *box )
{
	int clip[4] ;

	set_clip_box ( box, clip ) ;

	if ( ++test_color >= 16 )
		test_color = WHITE ;
    vsf_color ( vdi_handle, test_color );
	mouse_off() ;
    vr_recfl ( vdi_handle, clip );              /* fill rectangle */
	mouse_on() ;
}


# define pRED   0
# define pGREEN 1
# define pBLUE  2
/*----------------------------------------- restore_md_palette -------*/
void restore_md_palette ( PALETTE *pal, int *phys_to_vdi )
{
	byte *pb ;
	int physi, rgb[3] ;
	
	if ( bit_planes <= 8 ) 
	{
		pb = (byte *)pal ;
		for ( physi = 0 ; physi < colours ; physi++ )
		{
			pb++ ;
			rgb[0] = (int) ( (long)*pb++ * (long)MAXvdiLevel / (long)255 );
			rgb[1] = (int) ( (long)*pb++ * (long)MAXvdiLevel / (long)255 );
			rgb[2] = (int) ( (long)*pb++ * (long)MAXvdiLevel / (long)255 );
			vs_color ( vdi_handle, phys_to_vdi[physi], rgb ) ;
		}
	}	
}


/*---------------------------------------------- get_md_palette -------*/
void get_md_palette ( PALETTE *pal, int *phys_to_vdi )
{
	byte *pb ;
	int physi, rgb[3] ;

	if ( bit_planes <= 8 ) 
	{	
		pb = (byte *)pal ;
		for ( physi = 0 ; physi < colours ; physi++ )
		{
			vq_color ( vdi_handle, phys_to_vdi[physi], 0, rgb ) ;
			*pb++ = 0 ;
			*pb++ = (byte)( (long)rgb[0] * (long)255 / (long)MAXvdiLevel ) ;
			*pb++ = (byte)( (long)rgb[1] * (long)255 / (long)MAXvdiLevel ) ;
			*pb++ = (byte)( (long)rgb[2] * (long)255 / (long)MAXvdiLevel ) ;
		}
	}
}


/*---------------------------------------------- set_grey_palette -------*/
void set_grey_palette ( int *phys_to_vdi )
{
	int physi, rgb[3] ;

	if ( bit_planes <= 8 ) 
	{
		for ( physi = 0 ; physi < colours ; physi++ )
		{
			rgb[pRED] = rgb[pGREEN] = rgb[pBLUE] =
					(int) ( (long)physi * (long)MAXvdiLevel / (long)(colours-1) );
			vs_color ( vdi_handle, phys_to_vdi[colours-physi-1], rgb ) ;
		}
	}
}


/*---------------------------------------------- set_col_palette -------*/
void set_col_palette ( int *phys_to_vdi )
{
	int physi, rgb[3] ;

	if ( bit_planes <= 8 ) 
	{
		switch ( bit_planes )
		{
	case 8 :	for ( physi = 0; physi <= colours; physi++)
				{
					rgb[pRED]   = iscale ( 0xe0 - ( physi & 0xe0 ), 1000, 0xe0 );
					rgb[pGREEN] = iscale ( 0x1c - ( physi & 0x1c ), 1000, 0x1c );
					rgb[pBLUE]  = iscale ( 0x03 - ( physi & 0x03 ), 1000, 0x03 );
					vs_color ( vdi_handle, phys_to_vdi[physi], rgb ) ;
				}
				break ;
	default :	restore_md_palette ( &palette, phys_to_vdi ) ;
		}
	}
}


/*---------------------------------------------- set_md_palette -------*/
void set_md_palette ( int *phys_to_vdi, int display_mode )
{
	if ( display_mode == ZGREY )
		set_grey_palette ( phys_to_vdi ) ;
	else
		set_col_palette ( phys_to_vdi ) ;
}


/*---------------------------------------------- clear_keyboard -------*/
void clear_keyboard ( void )
{
	int dummy, key, event ;

	do
    {	/* remove all keys from the event queue */
    	event = evnt_multi ( MU_KEYBD | MU_TIMER,
 					 		0, 0, 0,
					 		0, 0, 0, 0, 0,
					 		0, 0, 0, 0, 0,
				 			NULL,
				 			30, 0,
				 			&dummy, &dummy, &dummy, &dummy,
				 			&key, &dummy ) ;
	} while ( event & MU_KEYBD ) ;
}


/* ----------------------------------------- new_top ----- */
void new_top ( unsigned wn )
{
	if ( madi_ok )
		i2c_initrom ( video_signal[wn], video_source[wn] ) ;
    check_source_pop ( wn ) ;
    check_signal_pop ( wn ) ;
	check_display_pop ( wn, bit_planes ) ;
	check_format_pop ( wn ) ;
	set_rom_vfact ( vfactor[wn] - 1 ) ;
	if ( ( vfactor[wn] == 4 ) || ( bit_planes < 8 ) )
		if ( dmode[wn] == ZCOLOUR )
			dmode[wn] = ZGREY ;
	set_md_palette ( phys_to_vdi, dmode[wn] ) ;
}

/* --------------------------------- restart_sliders ------------------- */
void restart_sliders ( unsigned wnum )
{
	if ( speed == GEM_SPEED )
	{
		calc_x_slider  ( wnum, 0, &window[wnum], &video_pos[wnum] ) ;
		calc_y_slider  ( wnum, 0, &window[wnum], &video_pos[wnum] ) ;
		update_sliders ( wnum,    &window[wnum], &video_pos[wnum] ) ;
	}
}

/* --------------------------------- max_speed_event ------------------- */
void max_speed_event ( unsigned *wnum, int *i )
{	/* in maximum speed mode */
	int mx, my,
		kstate,
		key,
		clicks,
		event,
		state ;
	int pipe[8] ;
	unsigned wn ;
		
	event = evnt_multi ( MU_TIMER | MU_BUTTON | MU_KEYBD,
 						 1, 0x2, 2,
                		 0, 0, 0, 0, 0,
                    	 0, 0, 0, 0, 0,
						 pipe,
						 MIN_DELAY, 0,
 						 &mx, &my, &state, &kstate, &key, &clicks );

	if ( ( event & MU_BUTTON ) || ( event & MU_KEYBD ) )
	{
		speed = GEM_SPEED ;
		check_speed_pop () ;
		restart_sliders ( *wnum ) ;		
		*i = 0 ;				/* end max-speed mode */
	}
	if ( ( cycle != 0 ) && ( NUMofWINDOWS > 1 ) )
	{
		wn = *wnum ;
		do
		{
			wn = ++wn % NUMofWINDOWS ;
		} while ( !win_open[wn] && ( wn != *wnum ) ) ;

		if ( wn != *wnum )
		{
			*wnum = wn ;
			if ( madi_ok )
				i2c_initrom ( video_signal[*wnum],
			   			      video_source[*wnum] ) ;
			set_rom_vfact ( vfactor[*wnum] - 1 ) ;
			wind_set ( whandle[wn], WF_TOP ) ;
			aes_delay ( 2 * I2C_SETTLEtime ) ;
		}
	}
}


/* ---------------------------- do_get_pic ------------------- */
void do_get_pic ( unsigned *wnum, int *i, GRAB_MODE gmode, SPEED_MODE spd )
{
	if ( gmode == GRAB_ON )
		grab_rom ( vfactor[*wnum] - 1 ) ;
	
	if ( vfactor[*wnum] == 4 )
	{
		switch ( dmode[*wnum] )
		{		/******** fast grey ******/
	case ZGREY	 :	if ( bit_planes !=  1 )
					{
						display_grey ( vdi_handle, &window[*wnum],
									   &video_pos[*wnum], bit_planes ) ;
				  		break ;
				  	}
				  	else
				  		dmode[*wnum] = ZDITHER ;
	case ZDITHER :	display_dither ( vdi_handle, &window[*wnum], &video_pos[*wnum] ) ;
					break ;
	default		 :
	case ZMONO 	 :
					display_mono ( vdi_handle, &window[*wnum], &video_pos[*wnum] ) ;
				  	break ;
		}
	}
	else
	{
		if ( dmode[*wnum] != ZCOLOUR )
		{
			switch ( dmode[*wnum] )
			{		/******** ful grey ******/
		case ZGREY	 :	if ( bit_planes !=  1 )
						{
							display_full_grey ( vdi_handle, &window[*wnum], &video_pos[*wnum], bit_planes ) ;
							break ;
						}
					  	else
					  		dmode[*wnum] = ZDITHER ;
		case ZDITHER :	display_full_dither ( vdi_handle, &window[*wnum], &video_pos[*wnum] ) ;
						break ;
		default		 :
		case ZMONO 	 :	display_full_mono ( vdi_handle, &window[*wnum], &video_pos[*wnum] ) ;
					  	break ;
			}
		}
		else	/******** full colour ******/
			display_full_colour ( vdi_handle, &window[*wnum], &video_pos[*wnum], bit_planes ) ;
	}
	
	if ( spd == MAX_SPEED )
		max_speed_event ( wnum, i ) ;
	else
		(*i)-- ;
}


/* ----------------------------------- get_pic ------------------- */
void get_pic ( unsigned wnum, int count, GRAB_MODE gmode, SPEED_MODE spd )
{
	RECTangle	curr ;
	int i ;

	if ( madi_ok )
	{		
	    wind_get ( whandle[wnum], WF_CURRXYWH, &curr.x, &curr.y,
	    							     	   &curr.w, &curr.h ) ;
		mouse_busy() ;
		if ( spd == MAX_SPEED )
			mouse_off() ;
		i = count ;

		do
		{
			do_get_pic ( &wnum, &i, gmode, spd ) ;
		} while ( i > 0 ) ;

		mouse_arrow() ;
		if ( spd == MAX_SPEED )		
			mouse_on() ;
	}
	else
		test_output ( &window[wnum] ) ;
}


/* -------------------------------- repeat_pic ------------------- */
void repeat_pic ( unsigned wnum )
{
	int dx, dy ;
	
	dx = vfactor[wnum] * PIXWIDTH  / 8 ;
	dy = vfactor[wnum] * PIXHEIGHT / 8 ;
	
	switch ( dmode[wnum] )
	{
case ZCOLOUR 	:
			repeat_colour ( vdi_handle, &window[wnum], &video_pos[wnum],
							dx, dy, bit_planes ) ;
			break ;
case ZGREY 	:
			repeat_grey ( vdi_handle, &window[wnum], &video_pos[wnum],
						  dx, dy, bit_planes ) ;
		  	break ;
case ZMONO	:
case ZDITHER 	:
default	 	 	:
		 	repeat_mono ( vdi_handle, &window[wnum], &video_pos[wnum], dx, dy ) ;
			break ;
	} /* switch */
}


/* ---------------------------------------- resize_window -------- */
void resize_window ( unsigned wnum, int fac )
{
	vfactor[wnum] = fac ;
	check_format_pop ( wnum ) ;
	calc_window ( wnum, &window[wnum], &video_pos[wnum] ) ;
	get_pic ( wnum, 1, GRAB_ON, GEM_SPEED ) ;
}


/* ----------------------------------------- redraw_window -------- */
void redraw_window ( unsigned wnum )
{
	RECTangle box, curr ;
	int       	clip[4];

	if ( ( whandle[wnum] <= 0 ) || ! win_open[wnum] )
		return ;

	vsf_color ( vdi_handle, BLUE ) ;
	vswr_mode ( vdi_handle, MD_REPLACE ) ;

	wind_get ( whandle[wnum], WF_FIRSTXYWH, &box.x, &box.y, &box.w, &box.h );
	wind_get ( whandle[wnum], WF_CURRXYWH, &curr.x, &curr.y, &curr.w, &curr.h );

	mouse_off();
	while ( box.w > 0 && box.h > 0 )
    {
    	if ( rc_intersect( &window[wnum], &box ) )
		{
			if ( madi_ok )
			{
				set_clip_box ( &box, clip ) ;
				repeat_pic ( wnum ) ;
			} 			
            else	/* test output : coloured rectangles	*/
            	test_output ( &box ) ;
		}
		wind_get ( whandle[wnum], WF_NEXTXYWH, &box.x, &box.y, &box.w, &box.h );
	}
	mouse_on() ;
    vs_clip ( vdi_handle, 0, clip ) ;
}


/*--------------------------------------------- close_d_window ---*/
void close_d_window ( unsigned wnum )
{
	unsigned wn ;
	int top_window ;
	
	if ( whandle[wnum] >= 0 )
	{
		if ( win_open[wnum] )
		{
			wind_close ( whandle[wnum] ) ;
			win_open[wnum] = FALSE ;
			wind_get ( 0, WF_TOP, &top_window ) ;
			for ( wn = 0; wn < NUMofWINDOWS; wn++ )
 			{
				if ( top_window == whandle[wn] )
				{
					new_top ( wn ) ;
					wn = NUMofWINDOWS ; /* break */
				}
			}
		}
	}
}


/* ----------------------------------------------- update_hardware ------ */
void update_hardware ( unsigned wnum, int old_vfac )
{
	setup_param ( wnum ) ;
	set_rom_vfact ( vfactor[wnum] - 1 ) ;
	if ( ( vfactor[wnum] == 4 ) || ( bit_planes < 8 ) )
		if ( dmode[wnum] == ZCOLOUR )
			dmode[wnum] = ZGREY ;
			
	check_display_pop ( wnum, bit_planes ) ;
	check_format_pop ( wnum ) ;
	check_speed_pop () ;
	check_digitise_pop () ;
	check_save_pop () ;
	check_grab_pop () ;
	set_md_palette ( phys_to_vdi, dmode[wnum] ) ;
	check_signal_pop ( wnum ) ;
	check_source_pop ( wnum ) ;
	
	if ( madi_ok )
	{
		if ( ( video_signal[wnum] == PUP_AUTO ) || ( video_source[wnum] == PUP_AUTO ) )
		{
			video_signal[wnum] = PUP_AUTO ;
			video_source[wnum] = PUP_AUTO ;
			set_window_title ( wnum ) ;
			auto_check ( wnum ) ;
		}
		else
		{
			i2c_initrom ( video_signal[wnum], video_source[wnum] ) ;
			set_window_title ( wnum ) ;
		}
	}

	restart_sliders ( wnum ) ;	
	if ( ( check_video_param ( wnum ) ) || ( old_vfac != vfactor[wnum] ) )
		resize_window ( wnum, vfactor[wnum] ) ;
	else
		get_pic ( wnum, 1, GRAB_OFF, GEM_SPEED ) ;
}

/*--------------------------------------------- kill_d_window ---*/
void kill_d_window ( unsigned wnum )
{
	if ( whandle[wnum] >= 0 )
	{
		if ( win_open[wnum] )
		{
			wind_close ( whandle[wnum] ) ;
			win_open[wnum] = FALSE ;
		}
		wind_delete ( whandle[wnum] ) ;
		whandle[wnum] = -1 ;
	}
}

/*--------------------------------------------- kill_digit_windows ---*/
void kill_digit_windows ( void )
{
	unsigned wnum;
	
	acc_opened = FALSE ;

	restore_md_palette ( &palette, phys_to_vdi ) ;
	for ( wnum = 0; wnum < NUMofWINDOWS; wnum++ )
		kill_d_window ( wnum ) ;
}


/*------------------------------------------- restart_acc ---------*/
void restart_acc ( void )
{
	unsigned wnum ;
	int i ;
	int work_in[11] ;
	int work_out[57] ;

	v_clsvwk ( vdi_handle ) ;
	for ( wnum = 0; wnum < NUMofWINDOWS; wnum++ )
		dmode[wnum] = ZMONO ;

	for ( i = 0; i < 10; i++ )
		work_in[i]  = 1 ;
	work_in[10] = 2 ;
	phys_handle = graf_handle ( &hwchar, &hhchar, &hwbox, &hhbox ) ;
	vdi_handle = phys_handle ;
	v_opnvwk ( work_in, &vdi_handle, work_out ) ;
	if ( vdi_handle != 0 )
	{
		max_x = work_out[0] ;
		max_y = work_out[1] ;
		screen_size.x = max_x + 1 ;
		screen_size.y = max_y + 1 ;
		colours = work_out[13] ;
				
		vq_extnd ( vdi_handle, 1, work_out ) ;
		bit_planes = work_out[4] ;
		if ( bit_planes <= 8 )
			set_phys_to_vdi ( vdi_handle, colours, phys_to_vdi, NULL ) ;
	}
}


/* ----------------------------------------- handle_message ----- */
int handle_message( unsigned wnum, int pipe[8] )
{
	RECTangle curr ;
	int wn ;
	
	switch ( pipe[0] )
	{
case WM_ARROWED:
		if ( ( ( old_msg != WM_ARROWED ) || 
			   ( pipe[4] == WA_UPLINE  ) ||
			   ( pipe[4] == WA_DNLINE  ) ||
			   ( pipe[4] == WA_LFLINE  ) ||
			   ( pipe[4] == WA_RTLINE  ) ) && pipe[3] == whandle[wnum] )
		{
			switch ( pipe[4] )
			{
		case WA_LFPAGE:	video_pos[wnum].x -= x_page ;
						update_x_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
		case WA_RTPAGE:	video_pos[wnum].x += x_page ;
						update_x_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
		case WA_LFLINE:	video_pos[wnum].x -- ;
						update_x_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
		case WA_RTLINE:	video_pos[wnum].x ++ ;
						update_x_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
						
		case WA_UPPAGE:	video_pos[wnum].y -= y_page ;
						update_y_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
		case WA_DNPAGE:	video_pos[wnum].y += y_page ;
						update_y_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
		case WA_UPLINE:	video_pos[wnum].y -- ;
						update_y_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
		case WA_DNLINE:	video_pos[wnum].y ++ ;
						update_y_slider ( wnum, &window[wnum], &video_pos[wnum] ) ;
						break ;
			default:	break ;
			}
			repeat_pic ( wnum ) ;
		}
		break ;

case WM_VSLID:
		if ( pipe[3] == whandle[wnum] )
		{
			calc_y_slider ( wnum, pipe[4], &window[wnum], &video_pos[wnum] ) ;
			repeat_pic ( wnum ) ;
		}
		break ;
      
case WM_HSLID:
		if ( pipe[3] == whandle[wnum] )
		{
			calc_x_slider ( wnum, pipe[4], &window[wnum], &video_pos[wnum] ) ;
			repeat_pic ( wnum ) ;
		}
		break ;

 case WM_REDRAW:
 		for ( wn = 0; wn < NUMofWINDOWS; wn++ )
 		{
 			if ( whandle[wn] == pipe[3] )
 			{
 				redraw_window ( (unsigned)wn ) ;
 				wn = NUMofWINDOWS ;	/* = break */
 			}
 		}
		break;

 case WM_TOPPED:
 		for ( wn = 0; wn < NUMofWINDOWS; wn++ )
 		{
 			if ( whandle[wn] == pipe[3] )
 			{
				wind_set ( whandle[wn], WF_TOP ) ;
 				new_top ( wn ) ;
				wn = NUMofWINDOWS ;	/* = break */
			}
 		}
		break ;

 case WM_FULLED:
		if ( pipe[3] == whandle[wnum] )
			calc_window ( wnum, &window[wnum], &video_pos[wnum] ) ;
		get_pic ( wnum, 1, GRAB_OFF, GEM_SPEED ) ;
		break ;

 case WM_CLOSED:
		if ( pipe[3] == whandle[wnum] )
		{
			close_d_window ( wnum ) ;
			for ( wn = 0; wn < NUMofWINDOWS; wn++ )
			{
				if ( win_open[wn] )
				{
					old_msg = pipe[0] ;
					return 0 ;
				}
			}
			restore_md_palette ( &palette, phys_to_vdi ) ;

			acc_opened = FALSE ;
			return _app ;
		}
		break ;

 case WM_MOVED:
 case WM_SIZED:
		if ( pipe[3] == whandle[wnum] )
		{
			curr.x = pipe[4] ;
			curr.y = pipe[5] ;
			curr.w = min ( pipe[6], ( V_DX * vfactor[wnum] / 8 ) + FRAMEX + SLIDEX - border_x ) ;
			curr.h = min ( pipe[7], ( V_DY * vfactor[wnum] / 8 ) + FRAMEY + SLIDEY - head_y ) ;
			chk_window ( wnum, &window[wnum], &curr, &video_pos[wnum] ) ;
		}
		break;

 case AC_OPEN:
		if ( pipe[4] == menu_id )
		{
			if ( !acc_opened )
			{
				/* setup essential variables */
				end_program = 0 ;
				wn = 0 ;
				acc_opened = TRUE ;
				restart_acc () ;

				/* save current palette, choose palette again */
				get_md_palette ( &palette, phys_to_vdi ) ;
				set_md_palette ( phys_to_vdi, dmode[wn] ) ;

				/* reopen window */
    			reopen_window ( (unsigned)wn, vfactor[wn] ) ;

				/* find video signal */
				video_signal[wn] = PUP_AUTO ;
				video_source[wn] = PUP_AUTO ;
				auto_check ( (unsigned)wn ) ;
				check_display_pop ( (unsigned)wn, bit_planes ) ;

				/* get picture */
				set_rom_vfact ( vfactor[wn] - 1 ) ;
				get_pic ( (unsigned)wn, 1, GRAB_ON, GEM_SPEED ) ;
			}
			else
			{
				wn = 0 ;
				wind_set ( whandle[wn], WF_TOP ) ;
				new_top ( wn ) ;
			}
		}
		break;

 case AC_CLOSE:
		if ( pipe[3] == menu_id )
		{
			kill_digit_windows () ;
			return _app ;
		}
	}
	old_msg = pipe[0] ;
	return 0 ;
}


/*-------------------------------------------------------- digit_keyboard ------*/
unsigned digit_keyboard ( unsigned wnum, int keycode )
{
	unsigned old_vfac ;
	
	if ( ( keycode & 0xff ) >= ' ' )
		keycode &= 0xff ;

	switch (keycode)
	{
case '?' :
case HELP :		if ( aes_version >= AES_FALCON )
					handle_fdialog ( NULL, 0, DHELP, NO_EDIT ) ;
				else
					handle_sdialog ( NULL, 0, DHELP, NO_EDIT,
								 	 DH_OK, DHTXT_OK ) ;
				return 0 ;
case '1' :
case '2' :
case '3' :		video_source[wnum] = keycode - '0' ;
				if ( madi_ok )
					i2c_initrom ( video_signal[wnum],
								  video_source[wnum] ) ;
	            set_window_title ( wnum ) ;
	            check_source_pop ( wnum ) ;
				return 0 ;
case 'a' :
case 'A' :		video_signal[wnum] = PUP_AUTO ;
				video_source[wnum] = PUP_AUTO ;
				set_window_title ( wnum ) ;
				auto_check ( wnum ) ;
				return 0 ;
case 'c' :
case 'C' :		if ( ++dmode[wnum] > ZMONO )
					dmode[wnum] = ZCOLOUR ;
				if ( ( vfactor[wnum] == 4 ) || ( bit_planes < 8 ) )
					if ( dmode[wnum] == ZCOLOUR )
						dmode[wnum] = ZGREY ;
		  		check_display_pop ( wnum, bit_planes ) ;
				set_md_palette ( phys_to_vdi, dmode[wnum] ) ;
				get_pic ( wnum, 1, GRAB_OFF, GEM_SPEED ) ;
				return 0 ;
case 'd' :
case 'D' :		get_pic ( wnum, 1, GRAB_ON, GEM_SPEED ) ;
				clear_keyboard () ;
				return 0 ;
# if TEST
case 'e' :
case 'E' :		if ( madi_ok )
					save_a_file ( wnum, &window[wnum], &video_pos[wnum],
							  	  vfactor[wnum], &Drive ) ;
				
				return 0 ;
# endif TEST
case 'f' :
case 'F' :		video_signal[wnum] = PUP_CVBS ;
				if ( madi_ok )
					i2c_initrom ( video_signal[wnum],
						      	  video_source[wnum] ) ;
	            set_window_title ( wnum ) ;
	            check_signal_pop ( wnum ) ;
				return 0 ;
case 'i' :
case 'I' :		update_info () ;
				if ( aes_version >= AES_FALCON )
					handle_fdialog ( NULL, 0, MD_INFO, NO_EDIT ) ;
				else
					handle_sdialog ( NULL, 0, MD_INFO, NO_EDIT,
								 	 I_OK, ITXT_OK ) ;
				return 0 ;
case 'm' :
case 'M' :		speed = ( speed == MAX_SPEED ) ? GEM_SPEED : MAX_SPEED ;
				check_speed_pop () ;
				restart_sliders ( wnum ) ;
				return 0 ;
case 'o' :
case 'O' :		digitise = ( digitise == SINGLE ) ? MULTIPLE : SINGLE ;
				check_digitise_pop () ;
				return 0 ;
case 'p' :
case 'P' :		old_vfac = vfactor[wnum] ;
				if ( aes_version >= AES_FALCON )
					handle_fparams ( NULL, 0, MD_PARAM, NO_EDIT, wnum ) ;
				else
					handle_params ( NULL, 0, MD_PARAM, NO_EDIT, wnum ) ;
				update_hardware ( wnum, old_vfac ) ;
				return 0 ;
case 'r' :
case 'R' :		grab = ( grab == GRAB_ON ) ? GRAB_OFF : GRAB_ON ;
				check_grab_pop () ;							
				return 0 ;
case 's' :
case 'S' :		video_signal[wnum] = PUP_SVHS ;
				if ( madi_ok )
					i2c_initrom ( video_signal[wnum],
							      video_source[wnum] ) ;
	            set_window_title ( wnum ) ;
	            check_signal_pop ( wnum ) ;
				return 0 ;
# if TEST
case 'v' :
case 'V' :		verbose = 1 - verbose ;
				return 0 ;
# endif TEST	
case 'w' :
case 'W' :		whole = 1 - whole ;
				check_save_pop () ;
				return 0 ;
# if TEST
case 'y' :
case 'Y' :		cycle = 1 - cycle ;
				return 0 ;
# endif TEST	
case 'z' :
case 'Z' :		vfactor[wnum] = next_vfactor ( vfactor[wnum] ) ;
				if ( ( vfactor[wnum] == 4 ) || ( bit_planes < 8 ) )
					if ( dmode[wnum] == ZCOLOUR )
						dmode[wnum] = ZGREY ;
		  		check_display_pop ( wnum, bit_planes ) ;
				set_md_palette ( phys_to_vdi, dmode[wnum] ) ;
       	    	resize_window ( wnum, vfactor[wnum] ) ;
				return 0 ;

case CNTRL_Q :	kill_digit_windows () ;
				return _app ;

default :		return 0 ;
	}
}


/* ------------------------------------------------- event_loop ------- */
void event_loop ( void )
{
	int x, y,
		kstate,
		key,
		clicks,
		event,
		state;
	int pipe[8];
	int quit;
	int top_window ;
	unsigned old_vfac ;
	unsigned wnum, wn ;
	
	quit = 0 ;
	do
	{
    	event = evnt_multi ( MU_MESAG | MU_KEYBD | MU_TIMER | MU_BUTTON,
 							 1, 2, 2,
							 0, 0, 0, 0, 0,
							 0, 0, 0, 0, 0,
							 pipe,
							 l_time, 0,
							 &x, &y, &state, &kstate, &key, &clicks );
		wind_update ( BEG_UPDATE ) ;
   		wind_get ( 0, WF_TOP, &top_window ) ;

		/* find the top window */
		for ( wnum = 0; wnum < NUMofWINDOWS; wnum++)
			if ( whandle[wnum] == top_window )
				break;

		/* handle events */
		if ( ( event & MU_BUTTON ) && ( top_window == whandle[wnum] ) )
		{
			old_vfac = vfactor[wnum] ;
			if ( aes_version >= AES_FALCON )
				handle_fparams ( NULL, 0, MD_PARAM, NO_EDIT, wnum ) ;
			else
				handle_params ( NULL, 0, MD_PARAM, NO_EDIT, wnum ) ;
			if ( ! end_program )
				update_hardware ( wnum, old_vfac ) ;
		}
		else if ( event & MU_MESAG )
			quit = handle_message ( wnum, pipe );
		else if ( ( event & MU_KEYBD ) && ( top_window == whandle[wnum] ) )
			quit = digit_keyboard ( wnum, key ) ;
		else if ( event & MU_TIMER )
		{
      		if ( ( whandle[wnum] >= 0 ) && ( win_open[wnum] ) )
      			if ( ( video_signal[wnum] == PUP_AUTO ) || ( video_source[wnum] == 	PUP_AUTO ) )
      				auto_check ( wnum ) ;
      			if ( ( digitise == MULTIPLE ) &&
      			     ( top_window == whandle[wnum] ) )
      				get_pic ( wnum, 1, grab, speed ) ;
				if ( ( speed == MAX_SPEED ) &&
					 ( digitise == MULTIPLE ) &&
					 ( cycle != 0 ) &&
					 ( NUMofWINDOWS > 1 )     )
				{
					wn = wnum ;
					do
					{
						wn = ++wn % NUMofWINDOWS ;
					} while ( !win_open[wn] && ( wn != wnum ) ) ;
					if ( wn != wnum )
					{
						wind_set ( whandle[wn], WF_TOP ) ;
						new_top ( wn ) ;
						aes_delay ( I2C_SETTLEtime ) ;
					}
				}
 
		}
      	wind_update( END_UPDATE );

		if ( ! ( event & MU_MESAG ) )
			old_msg = 0 ;

		if ( end_program )
		{
			kill_digit_windows () ;
        	quit = _app ;
        }
	}
   	while ( !quit );
}


/* ----------------------------------------------- init_vars ------ */
void init_vars ( void )
{
	unsigned wnum ;
	
	end_program = 0 ;
	verbose = 0 ;
	for ( wnum = 0; wnum < NUMofWINDOWS; wnum++ )
	{
		whandle[wnum] = -1 ;
		win_open[wnum] = FALSE ;
		video_signal[wnum] = PUP_AUTO ;
		video_source[wnum] = PUP_AUTO ;
		video_pos[wnum].x = 0 ;
		video_pos[wnum].y = 0 ;
		vfactor[wnum] = 4 ;
		dmode[wnum] = ZMONO ;
	}
	whandle[NUMofWINDOWS] = -1 ;
	digitise = MULTIPLE ;
	madi_ok = 0 ;
	speed = GEM_SPEED ;
	l_time = GEM_DELAY ;
	grab = GRAB_ON ;
	set_rom_vfact ( 3 ) ;
	head_y = 32 ;
	border_x = 12 ;
	whole = 0 ;
	Drive = GetDrive() ;
	cycle = 0 ;
}

/* ================== TERMINATING PROCEDURES ====================== */
/* ----------------------------------------------- exit_appl ------ */
void exit_appl ( void )
{
	appl_exit () ;
}


/* ----------------------------------------------- free_rsrc ------ */
void free_rsrc ( void )
{
	rsrc_free () ;
}


/* -------------------------------------------- kill_palette ------ */
void kill_palette ( void )
{
	if ( phys_to_vdi != NULL )
		Mfree ( phys_to_vdi ) ;
}
/* ================================================================ */


/*------------------------------------------------------------------ acc_stop() ---------*/
void acc_stop ( void )
{
	int dummy ;
	
	if ( ! _app )	/* if accessory : loop	*/
		for(;;)
			evnt_multi(	0,
		     			0,0,0,	0, 0,0,0,0,	0, 0,0,0,0, NULL, 0,0,
 		   				&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
}

/* ---------------------------------------------------- main ------ */
void main ( void )
{
	int wn ;
	int i ;
	int work_in[11] ;
	int work_out[57] ;
	long vcookie_name = 0x5F56444FL ; /* = "_VDO" */
	long ccookie_name = 0x5F435055L ; /* = "_CPU" */
	long fcookie_name = 0x5F465242L ; /* = "_FRB" */
	long old_super_stack ;

	/* What type of video, cpu & fast RAM is available ?*/
	old_super_stack = Super ( 0L ) ;
	if ( CK_JarInstalled () )
	{
		CK_ReadJar ( vcookie_name, &video_cookie ) ;
		CK_ReadJar ( ccookie_name, &cpu_cookie ) ;
		CK_ReadJar ( fcookie_name, &fram_cookie ) ;
	}
	Super ( (void *) old_super_stack ) ;
	
	linea_init();
	appl_id = appl_init ();
	if ( appl_id >= 0 )
	{
		aes_version = _GemParBlk.global[0] ;
		atexit ( exit_appl ) ;
		if ( rsrc_load ( RSC_NAME ) != 0 )
		{
			atexit ( free_rsrc ) ;
			if ( _app == 0 )				/* = ACC */
				menu_id = menu_register ( appl_id, "  MatDigiR" ) ;

			init_vars () ;
			init_menus () ;
			setup_video_param () ;
			for ( i = 0; i < 10; i++ )
				work_in[i]  = 1;
			work_in[10] = 2;
			phys_handle = graf_handle ( &hwchar, &hhchar, &hwbox, &hhbox ) ;
			vdi_handle = phys_handle ;
			v_opnvwk ( work_in, &vdi_handle, work_out ) ;
			if ( vdi_handle != 0 )
			{
				max_x = work_out[0] ;
				max_y = work_out[1] ;
				screen_size.x = max_x + 1 ;
				screen_size.y = max_y + 1 ;
				colours = work_out[13] ;
				
				vq_extnd ( vdi_handle, 1, work_out ) ;
				bit_planes = work_out[4] ;
				phys_to_vdi = calloc ( colours, sizeof(int)) ;
				if ( bit_planes <= 8 )
					set_phys_to_vdi ( vdi_handle, colours, phys_to_vdi, NULL );
				get_md_palette ( &palette, phys_to_vdi ) ;
				atexit ( kill_palette );
				
				madi_ok = ( init_vidig ( V_DX, V_DY ) == OK ) ;
				atexit ( term_vidig ) ;
				if ( madi_ok )
				{
# ifndef DEBUG
					chk_vme () ;
					madi_ok = ( i2c_bus != NULL ) ;
					madi_ok = i2c_initrom ( PUP_CVBS, 1 ) ;
# else
# define MAXTEST 20
					i2c_bus   = (byte *)I2C_ROMPORT  ;
					i2c_romport = TRUE ;
					for ( i = 0; i < MAXTEST; i++ )
					{
						i2c_stop ( i2c_bus ) ;
						chk_vme () ;
						madi_ok = ( i2c_bus != NULL ) ;
						if ( madi_ok )
						{
							i2c_initrom ( PUP_CVBS, 1 ) ;
							break ;
						}
					} 
# endif
					if ( !madi_ok )
						l_time = NOMD_DELAY ;
				}
				else
				{
					form_alert ( 1, get_free_string ( AL_MEM ) ) ;
					l_time = NOMD_DELAY ;
				}
				aes_delay ( INIT_DELAY ) ;

				chk_buttons () ;
				
				if ( _app != 0 )			/* = PRG */
				{
					mouse_arrow() ;
					set_md_palette ( phys_to_vdi, ZMONO ) ;
					for ( wn = NUMofWINDOWS-1; wn >= 0; wn--)
					{
		    			open_window ( (unsigned)wn, vfactor[wn] ) ;
						video_signal[wn] = PUP_AUTO ;
						video_source[wn] = PUP_AUTO ;
						set_window_title ( (unsigned)wn ) ;
						auto_check ( (unsigned)wn ) ;
						set_rom_vfact ( vfactor[wn] - 1 ) ;
						check_display_pop ( (unsigned)wn, bit_planes ) ;
						get_pic ( (unsigned)wn, 1, GRAB_ON, GEM_SPEED ) ;
					}
				}
				
				event_loop ();
				v_clsvwk ( vdi_handle );

			} /* vdi_handle != 0 */
		} /* resource file loaded */
		else
		{	/* resource file not found - English message */
			form_alert ( 1, "[1][| MATDIGIR Error | Resource file | "RSC_NAME" | not found! ][ OK ]");
			acc_stop () ;
		}
	} /* appl_id >= 0  .... application registered */

	exit ( 0 ) ;
}

