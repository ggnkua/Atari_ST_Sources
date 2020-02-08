/********************************************************************/
/* 				MatDigi Window Program - Parameter Menus			*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 27.09.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler		*/
/*																	*/
/********************************************************************/

# define WINDOW_TYPE 		(NAME|CLOSER|MOVER|FULLER|SIZER|VSLIDE|HSLIDE|UPARROW|DNARROW|LFARROW|RTARROW)
# define WINDOW_TYPE_NO_BAR (NAME|CLOSER|MOVER)
# define WINDOW_TYPE_PURE	0

/* DMSD 7191 status bits */
# define UNLOCKC 	0x41
# define UNLOCKBW	0x40
# define LOCKC		0x01
# define LOCKBW		0x00

/* possible "_VID" cookie values */
# define VID_ST		0x00L
# define VID_STE	0x01L
# define VID_TT		0x02L
# define VID_FALCON	0x03L

/* new FALCON 3D buttons */
# define AES_FALCON 0x340			/* FALCON / MultiTOS AES version */
# define FL3DNONE	0x0000			/* no 3D effect  */
# define FL3DIND	0x0200			/* 3D indicator  */
# define FL3DBAK	0x0400			/* 3D background */
# define FL3DACT	0x0600			/* 3D activator  */

/* HDG's 3D buttons for old AES versions */
# define HDG_BUTTON BIT(15)

typedef enum { PALrgb, PALyuv, PALgrey } TPaletteDisplayMode ;

typedef enum
{
	IDLE, DIGITIZE, RECORD,
	PLAY_FORWARD, PLAY_BACK, PLAY_FAST_FORWARD, PLAY_FAST_BACK,
	LOADfilm, SAVEfilm
} TRunMode ;

typedef enum { GRAB_OFF, GRAB_ON } TGrabMode ;

extern unsigned 	madi_ok ;

extern TBlitWindow	BlitWindow ;
extern POINT		Zoom ;
extern TImageWindow	MatDigiF ;

# define NUMzoomCodes	6
# define	Z11		0
# define	Z21		1
# define	Z22		2
# define	Z41		3
# define	Z42		4
# define	Z82		5

extern POINT		ZoomTable[NUMzoomCodes] ;
extern unsigned		menu_zoom ;

extern int    		whandle ;

# if 0
extern int FRAMEX ;
extern int FRAMEY ;
extern int SLIDEX ;
extern int SLIDEY ;
# endif
extern TRectangle  DeskTop ;

extern int			aes_version ;
extern long			video_cookie ;
extern long			cpu_cookie ;
extern long			fram_cookie ;
extern int	   		bit_planes ;
extern unsigned		end_program ;
extern unsigned 	border_x ;
extern unsigned 	head_y, tail_y ;
extern int			Drive ;
extern int 			cycle ;
extern int    		max_x, max_y ;

extern unsigned 	menu_vsignal ;
extern unsigned 	menu_vsource ;
extern unsigned		menu_vfactor ;

# ifndef __MATDIGIF__
extern unsigned 	video_signal ;
extern unsigned 	video_source ;
# endif !__MATDIGIF__
extern unsigned		vfactor ;
extern TRunMode		RunMode ;
extern int			whole ;

extern POINT  screen_size ;

extern void init_menus		( void ) ;

extern int handle_fparams	( OBJECT *fromtree, int fromobj,
							  int dialtr, int editstart ) ;
extern int handle_params	( OBJECT *fromtree, int fromobj,
							  int dialtr, int editstart ) ;
							  
extern int handle_fdialog 	( OBJECT *fromtree, int fromobj,
				   			  int dialtr, int editstart ) ;
extern int handle_sdialog	( OBJECT *fromtree, int fromobj,
							  int dialtr, int editstart,
							  int exit1, int exit2 ) ;
							  
extern void mopen_dialog	( OBJECT *fromtree, int fromobj,
				   			  OBJECT *dialtree,
				   			  TRectangle *rect, TRectangle *fr );
extern void mclose_dialog	( OBJECT *fromtree, int fromobj, 
							  TRectangle *rect, TRectangle *fr ) ;

extern void update_info		( void ) ;
							  
extern void reset_window ( int style ) ;

extern void check_display_pop ( int planes ) ;
extern void check_zoom_pop ( void ) ;
extern void check_source_pop ( void ) ;
extern void check_signal_pop ( void ) ;
extern void check_standard_pop ( void ) ;

extern int  check_video_param ( void ) ;
extern void setup_video_param ( void ) ;
extern void get_window_title ( char *info ) ;
extern void setup_param ( void ) ;
extern void grey_to_white ( int dialtr ) ;
extern void chk_buttons ( void ) ;
extern char *get_free_string ( int tree ) ;
extern void UpdateTreeString (int tree, int child, const char *new) ;
