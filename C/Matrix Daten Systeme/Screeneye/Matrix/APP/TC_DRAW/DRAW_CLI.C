/*
		draw_cli.c
		
		installation for the TCxx
	
		5.10.92
		
		MATRIX / Werner Armingeon
		
		(c) MATRIX Daten Systeme GmbH
*/

# define TEST	0

# include <vdi.h>
# include <aes.h>
# include <vdi_ext.h>

# include <stdlib.h>
# include <stdio.h>
# include <string.h>
# include <ext.h>
# include <ctype.h>

# include <tos.h>

# include <global.h>
# include <command.h>
# include <syscom.h>
# include <error.h>
# include <ascii.h>
# include <vt52.h>
# include <toolbox.h>

# include "tcdr_cmd.h"

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"

typedef struct POTIstruct { int i ; } ;

# include "colors.h"
# include "effects.h"
# include "basics.h"
# include "drawwind.h"
# include "pictures.h"
# include "demo.h"
# include "tc_draw.h.h"	/* for toolbox numbers	*/
# if TEST
# include "drawutil.h"
# endif

# include "draw_cli.h"

# define MAXvdiLevel (1000)

bool SaveDrawing = FALSE ;

# define _tst(is,in)	if ( stricmp ( s, is ) == 0 ) return in ;
/*------------------------------------- get_icn_from_name --------------*/
int get_icn_from_name ( char *s )
{
	_tst ( "general", IT_GNRAL ) ;
	_tst ( "disk", IT_DISK ) ;
	_tst ( "help", IT_HELP ) ;
	_tst ( "demo", IT_DEMO ) ;
	_tst ( "filter", IT_FILTR ) ;
	_tst ( "palette", IT_PALET ) ;
	_tst ( "histogramm", IT_HISTO ) ;
	_tst ( "runs", IT_RUNS ) ;
	_tst ( "video", IT_VIDEO ) ;
	_tst ( "vdi", IT_VDI ) ;
	_tst ( "copy", IT_COPY ) ;
	_tst ( "window", IT_WIND ) ;
	_tst ( "videopar", IT_TVPAR ) ;
	return -1 ;
}

/*-------------------------------------- legal_colix -----------------*/
bool legal_colix ( int colix )
{
	return (unsigned)colix < colors ;
}


/*-------------------------------------- make_rgb -----------------*/
bool make_rgb ( int r, int g, int b, int *rgb )
{
	if (   (unsigned)r <= MAXvdiLevel 
		&& (unsigned)g <= MAXvdiLevel 
		&& (unsigned)b <= MAXvdiLevel )
	{
		*rgb++ = r ;
		*rgb++ = g ;
		*rgb   = b ;
		return TRUE ;
	}
	else
	{
		*rgb++ = 0 ;
		*rgb++ = 0 ;
		*rgb++ = 0 ;
		return FALSE ;
	}
}

/*-------------------------------------- print_rect_cmd -----------*/
void print_rect_cmd ( const char *name, int*pts )
{
	if ( verbose )
		( verbose == 1 ? *uprintf : printf )
			( "%s %d:%d %d:%d\n", name, pts[X0],  pts[Y0],  pts[X1],  pts[Y0] ) ;
}


/*-------------------------------------- check_points_parameter ----*/
bool check_points_parameter ( int npars, int *pts )
{
	switch ( npars )				/* set pts prophylaktich	*/
	{
case 9 : case 8 : case 7 : case 6 : case 5 : 
case 4 :	pts[X0] = p[0].i ;			/* rect = check against canvas	*/
			pts[Y0] = p[1].i ;
			pts[X1] = p[2].i ;
			pts[Y1] = p[3].i ;
			chk_canvas_pts ( pts ) ;
			break ;
case 1 :	if ( p[0].i > 0 )			/* -1 == full	*/
				return FALSE ;
case 0 :	set_canvas_pts ( pts ) ;	/* no par == full	*/
			break ;
default :	return FALSE ;
	}
	return TRUE ;
}

/*--------------------------------------------- exec_nrectfct ------*/
void exec_nrectfct ( const char *name, 
					GRAPHICfunction graphfct,
					int npars, int *pts, int save  )
{
	if ( check_points_parameter ( npars, pts ) )
	{
# if 1
		print_rect_cmd ( name, pts ) ;
# endif
		clip_on() ;
		start_time = get_ticks() ;
		graphfct ( pts ) ;
		end_time = get_ticks() ;
		if ( SaveDrawing & save )
			save_p0p1 ( pts ) ;
	}
}


# define exec_line(fct,sav)   exec_nrectfct ( "Xline", fct, npars, pts, sav )
# define exec_rect(fct,sav)   exec_nrectfct ( "Xrect", fct, npars, pts, sav )
# define exec_blit(fct,sav)   exec_nrectfct ( "Xblit", fct, npars, pts, sav )
# define exec_circle(fct,sav) exec_nrectfct ( "Xcircle", fct, npars, pts, sav )
# define exec_cross(fct,sav)  exec_nrectfct ( "Xcross", fct, npars, pts, sav )

		
/*-------------------------------------- user_command_case --------*/
void user_command_case ( int cmd, int npars,
						 char *argument, int *result )
{
	int rgb[3] ;
	int pts[8] ;
	
	switch ( cmd )
	{
case  CMDversion :		(*uprintf) ( "tcdraw cli\n" ) ;
						break ;

case +CMDsave :			switch ( npars )
						{
				case 4 :	if ( check_points_parameter ( npars, pts ) )
								save_p0p1 ( pts ) ;
							break ;
				case 0 :	SaveDrawing = TRUE ;
							break ;
				default :	*result = NOargs ;
							break ;
						}
						break ;
						
case -CMDsave :			SaveDrawing = FALSE ;
						break ;

case  CMDclosetools :	close_toolboxes() ;
						break ;
case +CMDswitchtool :	switch_toolbox_on ( get_icn_from_name ( p[0].s ) ) ;
						break ;
case -CMDswitchtool :	switch_toolbox_off ( get_icn_from_name ( p[0].s ) ) ;
						break ;
		
case  CMDwritemode :	if ( npars == 0 )
							p[0].i = DEFpar ;
						set_new_writing_mode ( p[0].i ) ;
						break ;

case  CMDblitmode :		if ( npars == 0 )
							p[0].i = DEFpar ;
						set_new_blit_mode ( p[0].i ) ;
						break ;

case  CMDpattern :		if ( npars == 0 )
							p[0].i = DEFpar ;
						set_new_pattern ( p[0].i ) ;
						break ;

case  CMDcolor :		if ( p[0].i >= 0 && p[0].i < colors )
						{
							curr_color = p[0].i ;
							set_new_color() ;
						}
						break ;

case  CMDload :			pts[0] = p[1].i ;
						pts[1] = p[2].i ;
						pts[2] = p[3].i ;
						pts[3] = p[4].i ;
						chk_canvas_pts ( pts ) ;

						if ( LoadNamedPicFile ( p[0].s, pts ) )
						{
							if ( SaveDrawing )
								save_p0p1 ( pts ) ;
						}
						else
							(*uprintf) ( "* file load error\n" ) ;
						break ;


# define AsgRGB(d,s) d[0] = s[0] ; d[1] = s[1] ; d[2] = s[2]

case  CMDrgb :			if ( make_rgb ( p[0].i,  p[1].i,  p[2].i, rgb ) )
						{
# if 1
							AsgRGB(curr_line_rgb,rgb);
							AsgRGB(curr_text_rgb,rgb);
							AsgRGB(curr_fill_rgb,rgb);
# else
							vsl_rgb ( vdi_handle, rgb ) ;
							vsf_rgb ( vdi_handle, rgb ) ;
							vst_rgb ( vdi_handle, rgb ) ;
# endif
/*
							update_color_boxes ???
*/
						}
						break ;

case  CMDpalette :		if ( legal_colix ( p[0].i ) && make_rgb ( p[1].i,  p[2].i,  p[3].i, rgb ) )
						{
							vs_color ( vdi_handle, p[0].i, rgb ) ;
/*
							update_palette_color ???
*/
						}
						break ;


/*... special drawing .................................................*/

case CMD_ERASE :		if ( npars == 1 )
						{
							curr_color = p[0].i ;
							set_new_color() ;
						}
						erase_picture();
						break ;

/*... standard drawing .................................................*/

case CMD_CIRCL :
				exec_circle ( circle_function, 1 ) ;
				break ;

case CMD_DOT :	vs_pixrgb ( vdi_handle, p[0].i, p[1].i, curr_fill_rgb ) ;
				break ;

case CMD_LINE :	exec_line ( Line, 1 ) ;
				break ;

case CMD_FILL :	pts[0] = p[0].i ;
				pts[1] = p[1].i ;
				Fill ( pts, npars == 3 ? p[2].i : -1 ) ;
				break ;

case CMD_MIRR:	if ( check_points_parameter ( npars, pts ) )
				{
					mirror_rect ( pts, npars == 5
						? ( p[4].i % 180 ) / 45 * 45
						: -1 ) ;
					if ( SaveDrawing )
						save_p0p1 ( pts ) ;
				}
				break ;

case CMD_RECT :	exec_rect ( draw_frame, 1 ) ;
				break ;

case CMD_CUBE :	exec_rect ( color_cube, 1 ) ;
				break ;

case CMD_INV :	exec_rect ( invert_rect, 1 ) ;
				break ;
		
case CMD_GRAY :	exec_rect ( gray_rect, 1 ) ;
				break ;
		
case CMD_BRIGH :
				exec_rect ( bright_rect, 1 ) ;
				break ;

case CMD_CRUN :	exec_rect ( rgb_slope, 1 ) ;
				break ;

case CMD_FRECT:	
# if TEST
	printf ( "\033Hwrm=%d pat=%d int=%d sty=%d rgb=%d:%d:%d ol=%d\n",
				writing_mode, pattern, interior, style,
				curr_fill_rgb[R], curr_fill_rgb[G], curr_fill_rgb[B],
							with_outlines ) ;
#endif
				exec_rect ( filled_rectangle, 1 ) ;
				break ;

case CMD_LUPE:	exec_cross ( zoom_box, 1 ) ;
				break ;

case -CMD_VIDEO:	switch_video_off() ;
					break ;

case +CMD_VIDEO:	if ( check_points_parameter ( npars, pts ) )
					{
						switch ( npars )
						{
				case 5 :	SetVideoFrames ( p[4].i ) ;
						/*	continue ;	*/
				case 4 :	if ( pts[X1] > 0 )
								SetVideoWindow ( pts ) ;
						/*	continue ;	*/
				case 0 :	switch_video_off() ;
							switch_video_on ( IC_VSWI ) ;
							break ;
				default :	*result = NOargs ;
							break ;
						}
					}
					break ;

case CMD_TOBOX:	if ( check_points_parameter ( npars, pts ) )
					ToBox ( pts ) ;
				break ;

case CMD_FRBOX:	if ( check_points_parameter ( npars, pts ) )
					FromBox ( pts ) ;
				break ;

					
case CMDdemo :	if ( check_points_parameter ( npars, pts ) )
					run_demo ( p[4].i, p[5].i, p[6].i, pts ) ;
				break ;

case CMD_COPY:	if ( check_points_parameter ( npars, pts ) )
				{
					pts[4] = p[4].i ;
					pts[5] = p[5].i ;
					pts[6] = p[6].i ;
					pts[7] = p[7].i ;
		
					copy_rectangle ( pts, &pts[4] ) ;
				}
				break ;

case CMD_TEXT:	if ( check_points_parameter ( npars, pts ) )
					DrawText ( pts, p[4].s ) ;
				break ;
	
case CMD_RBOW :	switch ( npars )
				{
		case 5 :	exec_rect ( lines_box, 1 ) ;
					break ;
		case 4 :	exec_rect ( rain_bow, 1 ) ;
					break ;
		default :	*result = NOargs ;
					break ;
				}
				break ;

case CMD_PSIM :	exec_rect ( SimulateClut, 1 ) ;
				break ;
	
case CMD_FRACT :exec_rect ( DrawFractal, 1 ) ;
				break ;


# if 0000000000000000000000000000000000000000000000

case CMD_DTOS:	if ( check_points_parameter ( npars, pts ) )
					dev_to_std ( pts ) ;
				break ;

case CMD_STOD:	if ( check_points_parameter ( npars, pts ) )
					std_to_dev ( pts ) ;
				break ;

case CMD_HRECT :exec_rect ( histo_rect, 0 ) ;
				break ;
				
case CMD_HLINE :exec_line ( histo_line, 0 ) ;
				break ;

case CMD_FILTR :exec_rect ( Filter, 0 ) ;
				break ;


case CMD_CALIB :if ( ! ( get_rectangle ( pts, obj_info_text ( IC_CALIB ) ) & RIGHT_BUTTON ) )
				{
					int pts[4] ;
					
					MouseOn()??
					MouseThinCross();
					if ( get_position ( &pts[X0], "Referenzbereich oberer Rand" ) & RIGHT_BUTTON )
						break ;
					if ( get_position ( &pts[X1], "Referenzbereich unterer Rand" ) & RIGHT_BUTTON )
						break ;
					MouseOff();
					start_time = get_ticks() ;
					calib_rect ( pts, pts[Y0], pts[Y0] ) ;
					end_time = get_ticks() ; 
					if ( SaveDrawing )
						save_p0p1 ( pts ) ;
					MouseOn();
				}
				break ;

case CMD_3RUN :
case CMD_4RUN :
					{
						int rgbs[12], ptsa[8] ;

# define X(i)	ptsa[((i)*2)]
# define Y(i)	ptsa[((i)*2+1)]
						X(0) = pts[0] ;
						Y(0) = pts[1] ;
						
						??MouseThinCross();
						if ( get_position ( &X(1), "2. Punkt" ) & RIGHT_BUTTON )
							break ;
						if ( get_position ( &X(2), "3. Punkt" ) & RIGHT_BUTTON )
							break ;
						if ( curr_mode != IC_3RUN )
						{							/*			0			*/
													/*		1				*/
													/*					2	*/
													/*				3		*/
							X(3) = X(2) + X(1) - X(0) ;
							Y(3) = Y(2) + Y(1) - Y(0) ;
							if ( ! inside_canvas ( &X(3) ) )
							{
								info_printf ( "Fehler : 4. Punkt ( %d:%d ) auûerhalb ZeichenflÑche",
												X(3), Y(3) ) ;
								break ;
							}
						}
						
						set_line_attr ( MD_REPLACE, 1, 1, BLACK ) ;

						??MouseOff();
						draw_run_frame ( ptsa ) ;						
						??MouseOn();
	
						if ( fetch_rgb_color ( &rgbs[0], "Farbe picken fÅr Punkt 1" ) & RIGHT_BUTTON )
								break ;
						if ( fetch_rgb_color ( &rgbs[3], "Farbe picken fÅr Punkt 2" ) & RIGHT_BUTTON )
								break ;
						if ( fetch_rgb_color ( &rgbs[6], "Farbe picken fÅr Punkt 3" ) & RIGHT_BUTTON )
								break ;
						if ( curr_mode != IC_3RUN )
							if ( fetch_rgb_color ( &rgbs[9], "Farbe picken fÅr Punkt 4" ) & RIGHT_BUTTON )
								break ;

						??MouseOff();
						start_time = get_ticks() ;
						if ( curr_mode == IC_3RUN )
							vrun_triangle ( vdi_handle, ptsa, rgbs ) ;
						else
							vrun_parallel ( vdi_handle, ptsa, rgbs ) ;
						end_time = get_ticks() ; 
						if ( with_outlines )
							draw_run_frame ( ptsa ) ;
						??MouseOn();
					}
					break ;

case CMD_FRUN :	if ( ! ( get_rectangle ( pts, obj_info_text ( IC_FRUN ) ) & RIGHT_BUTTON ) )
				{
					int rgbs[12] ;
# if 1
					if ( fetch_rgb_color ( &rgbs[0], "Farbe picken fÅr linke obere Ecke" ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[3], "Farbe picken fÅr rechte obere Ecke"     ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[6], "Farbe picken fÅr linke untere Ecke"   ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[9], "Farbe picken fÅr rechte untere Ecke"  ) & RIGHT_BUTTON )
							break ;
# else
					if ( fetch_rgb_color ( &rgbs[0], "Pick top left corner color : %3d - %3d" ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[3], "Pick top right corner color : %3d - %3d"     ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[6], "Pick bottom left corner color : %3d - %3d"   ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[9], "Pick bottom right corner color : %3d - %3d"  ) & RIGHT_BUTTON )
							break ;
# endif
					??MouseOff();
					start_time = get_ticks() ;
# if 1
					vrun_rect ( vdi_handle, pts, rgbs ) ;
# else
					rect_rgb_slope ( pts, rgbs ) ;
# endif
					end_time = get_ticks() ; 
					if ( with_outlines )
						draw_frame ( pts ) ; 
					if ( SaveDrawing )
						save_p0p1 ( pts ) ;
					??MouseOn();
				}
				break ;

case CMD_MRUN :
				if ( ! ( get_rectangle ( pts, obj_info_text ( IC_MRUN ) ) & RIGHT_BUTTON ) )
				{
					multi_point_run ( pts ) ;
					end_time = get_ticks() ; 
					??MouseOff();
					if ( with_outlines )
						draw_frame ( pts ) ; 
					if ( SaveDrawing )
						save_p0p1 ( pts ) ;
					??MouseOn();
				}
				break ;

case CMD_STORE :if ( ! ( get_rectangle ( pts, obj_info_text ( IC_STORE ) ) & RIGHT_BUTTON ) )
				{
					??MouseOff();
					save_draw_window ( pts ) ;
					??MouseOn();
				}
				break ;

# endif 0000000000000000000000000000000000000000000000

default :			*result = ILLcommand ;
					break ;
	}
#pragma warn -par
}
#pragma warn .par

/*-------------------------------------------- init_draw_cli -------*/
void init_draw_cli ( void )
{
	syscom_init() ;
}

/*------------------------------------------------- cli_file -------*/
int cli_file ( char *filename )
{
	return interpret_list ( filename, command_loop ) ;
}

/*------------------------------------------------- cli_line -----*/
int cli_line ( char *line )
{
	int result ;

	result = interpret_string ( line, command_loop ) ;
#if 0
			if ( result != OK && error_messages )
				(*uprintf) ( "* %-8s # %2d : %s\n",
					argument, result, get_error_text ( result ) ) ;
	if ( result != OK )
		info_printf ( "* Fehler %d in : %s", result, curr_text ) ;
# endif
	return result ;
}
