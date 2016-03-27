/*	tcdraw.c			/	23.7.91	/	MATRIX	/WA	*/
/*	MatDigi Additions	/    3.8.92	/	MATRIX	/HG	*/

# define RSC_TEST	0
# define TEST_MADI	1
# define USE_HELP	0

# define CLICK_TEST	0
# define EDIT_TEXT	1
# define VIDEO_SPECIAL	0

# if CLICK_TEST
int test_count = 0 ;
# endif

# define TEST	0
# if TEST

#include <ext.h>
# define tprintf(p) 	printf( "\033Y K" p ) ;		delay(1000)
# define tprintf2(p,q)	printf( "\033Y K" p, q ) ;	delay(1000)
# endif

#include <vdi.h>
#include <aes.h>
#include <linea.h>
#include <tos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <portab.h>
#include <math.h>

#include <global.h>
#include <scancode.h>
#include <vdi_ext.h>
#include <fast.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\dialog.h"
# include "\pc\cxxsetup\screen.h"
# include "\pc\cxxsetup\draw.h"
# include "\pc\cxxsetup\cxxfast.h"
# include "\pc\cxxsetup\files.h"
# include "\pc\cxxsetup\tosutils.h"
# include "\pc\cxxsetup\poti.h"

# if RSC_TEST
# include "\pc\app\resource\rsc_info.h"
# endif

# include <windows.h>

# include "tc_dra.h"
# include "tc_draw.h"

# include "draw_cli.h"

# if ! VIDEO_SPECIAL
# undef PO_VFAC
# undef PO_COUNT
# endif

# include <tab_init.h>
# include "\pc\tcxx\tcxx.lib\tcxxfast.h"
# include <beauty.h>
# include "basics.h"
# include "effects.h"
# include "demo.h"
# include "text.h"
# include "popup.h"
# include "drawutil.h"
# include "graph.h"
# include "colors.h"
# include "pictures.h"
# include "toolbox.h"
# include "updown.h"
# include "mfilter.h"
# include "version.h"
# include "digitise.h"

# include "tdconfig.h"
# define DEFAULTcfg	"TC_DRAW.INF"

# include "draw_wnd.h"
# include "drawwind.h"


# define keyboard_state(kc) ((*keyshift & (kc))!=0)

# define RELEASE_TEST	0

SYSHDR *syshead ;
byte   *keyshift ;

# if RELEASE_TEST
bool relbut = FALSE ;
long last_but_time = 0 ;
# define release_button()	relbut = TRUE
# endif


# if TEST
int tcdraw_test = 0 ;
# endif

# define MESG_CYCLE	100	/* msec	*/

WINDOWdescr *tc_draw_window ;

OBJECT	*tcdraw_tree ;

bool is_mattc ;

# define DRAWwindElements (MOVER|CLOSER|NAME|SIZER|FULLER)

# define WINDborder	32

RECTangle tcdraw_work, canvas ;

RECTangle clip_window ;
RECTangle save_box ;
RECTangle saved_rect ;
int source_rect[4] ;

bool do_clipping = FALSE ;

int curr_mode ;
char *curr_help = "" ;	/* HELP for curr_mode */

POPUP_MENU *pup_matrix ;


/*... pictures ...*/

# define MAX_TRANSP_COLOR	255

int transp_color = MAX_TRANSP_COLOR+1 ;

struct POTIstruct transp_poti =
	 { NULL, PO_TRCOL, &transp_color, 0, MAX_TRANSP_COLOR+1, MAX_TRANSP_COLOR+1, 1, 0, NULL, no_update, NULL } ;


/*-------------------------------------------------------- find_file_ext -----*/
char *find_file_ext ( void )
{
	return tcdraw_tree[TX_PFORM].ob_spec.tedinfo->te_ptext ;
}


/*... colors ...*/

int pup_color ;
POPUP_MENU *pup_colors ;


struct POTIstruct rgb_poti[3] =
	{
		DEFpsn ( PO_RED,   &color_levels[R], set_current_rgb, &rgb_poti[G] ),
		DEFpsn ( PO_GREEN, &color_levels[G], set_current_rgb, &rgb_poti[B] ),
		DEFpsn ( PO_BLUE,  &color_levels[B], set_current_rgb, NULL )
	} ;		

struct POTIstruct colix_poti =
		DEFpsmn ( PO_VDICO, &curr_color,	255, set_new_color, NULL ) ;

extern ReGrBl clut_masks = { 3, 3, 2 } ;

struct POTIstruct clut_mask_poti[3] =
	{
		DEFpsmn ( PO_R_MSK, &clut_masks[R], 8, set_clut_mask, &clut_mask_poti[G] ),
		DEFpsmn ( PO_G_MSK, &clut_masks[G], 8, set_clut_mask, &clut_mask_poti[B] ),
		DEFpsmn ( PO_B_MSK, &clut_masks[B], 8, set_clut_mask, NULL )
	} ;		


/*----------------------------------------- update_clut_mask --------*/
void update_clut_mask(void)
{
	o_printf ( tcdraw_tree, IC_PSIM, "%d:%d:%d",
					clut_masks[R], clut_masks[G], clut_masks[B] ) ;
}

/*----------------------------------------- set_clut_mask -----------*/
void set_clut_mask(void)
{
	update_clut_mask();
	ObjectDraw ( tcdraw_tree, IC_PSIM ) ;
}


/*----------------------------------------- draw_big_color_box ------*/
void draw_big_color_box ( void )
{
	ObjectDraw ( tcdraw_tree, BX_BICOL ) ;
}

/*----------------------------------------- palette_box_active ------*/
bool palette_box_active ( void )
{
	return find_toolbox_entry ( IT_PALET ) >= 0 ;
}

/* TV_PARS */

local bool madi_ok = FALSE ;

# define DRAW TRUE
# define NO_DRAW FALSE

POPUP_MENU *pup_coring ;
int coring ;

POPUP_MENU *pup_bpss ;
int bpss ;

POPUP_MENU *pup_tvstand ;
int tv_standard ;

POPUP_MENU *pup_signal ;
int signal ;

POPUP_MENU *pup_vsource ;
int video_source ;

POPUP_MENU *pup_channel ;
int channel ;

int matbpp = 0 ;

POPUP_MENU *pup_dmode ;
int display_mode ;

POPUP_MENU *pup_agc ;
int agc = GAINinit ;

POPUP_MENU *pup_aperture ;
int aperture ;

POPUP_MENU *pup_trap ;
int chroma_trap = 0 ;

POPUP_MENU *pup_prefilter ;
int prefilter ;

# define MAX_MULT_TIME ( 4000 / MESG_CYCLE ) /* time in mSec / MESG_CYCLE */
int	multiple_time = 0 ;	/* force immediate check */


/*... pixel info ...*/

# define MAXinfoLength 128
char tcdraw_title[MAXinfoLength+1] = TITEL ;
char tcdraw_info[MAXinfoLength+1] = "" ;

# define INFO_OFF	0
# define INFO_NORM	1
# define INFO_CONT	3
# define INFO_PERC	5
# define INFOzoom	6

# define INFOdec	0
# define INFOhex	1

int info_mode ;
# if 0
int zoom_active ;
# endif

# define MAXtextSize 80
char curr_text[MAXtextSize+1] = "" ;
char back_text[MAXtextSize+1] ;

POPUP_MENU *pup_info_mode ;

POPUP_MENU *pup_cube_space ;
int color_space ;

POPUP_MENU *pup_gs ;
int gray_mode ;

POPUP_MENU *pup_pic_format ;
int pic_format ;



/*... for tcxxfast.s : ...*/

unsigned char *screen_address ;
int bytes_per_line ;


/*... demo ... */

# define MAX_CNDEM 9999

int demo_number = 1 ;
int demo_count  = MAX_CNDEM/4 ;
int demo_erase  = 200 ;
struct POTIstruct demo_count_poti =
	 { NULL, PO_CNDEM, &demo_count, 1, MAX_CNDEM, MAX_CNDEM, 1, 0, NULL, no_update, NULL } ;
struct POTIstruct demo_erase_poti =
	 { NULL, PO_ERDEM, &demo_erase, 1, MAX_CNDEM, MAX_CNDEM, 1, 0, NULL, no_update, NULL } ;

/*... grid ... */

# define DEFgridWidth	32
bool snap_grid = FALSE ;
POINT grid_width  = { DEFgridWidth, DEFgridWidth } ;
POINT end_corr	  = { 1, 1 } ;

bool quadrat 	 = FALSE ;	/* w = h !	*/
bool puzzle_mode = FALSE ;

struct POTIstruct x_grid_poti =
	 { NULL, PO_XGRID, &grid_width.x, 1, 256, 256, 1, 0, NULL, no_update, NULL } ;

struct POTIstruct y_grid_poti =
	 { NULL, PO_YGRID, &grid_width.y, 1, 256, 256, 1, 0, NULL, no_update, NULL } ;


/*... outlines ... */

bool with_outlines = FALSE ;
int outline_width = 1 ;

struct POTIstruct outline_poti =
		DEFpsmn ( PO_OLINE, &outline_width,	16, no_update, NULL ) ;



/*......................... timer .................................*/

long start_time, end_time ;

/*-------------------------------------------------------- terminate_video --*/
int *SetPointsFromRect ( int *pts, RECTangle *rect )
{
	pts[X0] = rect->x ;
	pts[Y0] = rect->y ;
	pts[X1] = rect->x + rect->w - 1 ;
	pts[Y1] = rect->y + rect->h - 1 ;

	return pts ;
}


/*-------------------------------------------------- clip_on ------*/
void clip_on ( void )
{
	if ( do_clipping )
		clipping ( vdi_handle,
			clip_window.x+tcdraw_work.x, clip_window.y+tcdraw_work.y,
			clip_window.w, clip_window.h, TRUE ) ;
	else
		ClippingOn ( vdi_handle, canvas ) ;
}
				
/*---------------------------------------------- out_std_text -----*/
void out_std_text ( int h, int x, int y, int color, int wrm, char *s )
{
	vswr_mode ( h, wrm ) ;
	vst_alignment ( h, 0, 5, &dummy, &dummy ) ;
	vst_color ( h, color ) ;
	vst_effects (  h, 0 ) ;
	v_gtext ( h, x, y, s ) ;
}

/*---------------------------------------------- info_vprintf -----*/
int info_vprintf ( const char *format, void *args )
{
	RECTANGLE irect ;
	int len, maxl, wi, maxw ;
	
	if ( tcdraw_tree[TX_INFO].ob_flags & HIDETREE )
		return 0 ;

	ObjectGetRectangle ( tcdraw_tree, TX_INFO, irect ) ;
	maxw = scr_max_x - irect.x ;
	if ( irect.w > maxw )
		irect.w = maxw ;
	irect.x += 4 ;
	irect.w -= 4 ;
	maxl = irect.w / hwchar ;
	if ( ( len = vsprintf ( tcdraw_info, format, args ) ) > maxl )	/* skip output	*/
	{
		len = maxl ;
		tcdraw_info[maxl+1] = 0 ;
	}

	wi = len * hwchar ;
	MouseOff();
	out_std_text ( vdi_handle, irect.x, irect.y, BLACK, MD_REPLACE, tcdraw_info ) ;
	if ( len != maxl )
		draw_box ( WHITE, FIS_SOLID, 1, irect.x + wi, irect.y,
										irect.w - wi, irect.h ) ;
	MouseOn();
	return len ;
}
				
/*---------------------------------------------- info_printf --------*/
int info_printf ( const char *format, ... )
{
	return info_vprintf ( format, ... ) ;
}



/*---------------------------------------------- vdi_vprintf -----*/
int vdi_vprintf ( int x, int y, int wrm, const char *format, void *args )
{
	int len, col ;
	char str[256], *s, *ss ;
		
	len = vsprintf ( str, format, args ) ;

	col = BLACK ;
	MouseOff();
	ss = str ;
	do
	{
		if ( ss[0] == '\033' && ss[1] == 'c' )
		{
			col = ss[2] ;
			ss += 3 ;
		}
		s = ss ;	/* set s to start of next line segment	*/
		while ( *ss != 0 )	/* split line at \n - positions	*/
		{
			if ( *ss == '\n' )
			{
				*ss++ = 0 ;	/* break line, set ss to start of next segment	*/
				break ;
			}
			ss++ ;
		}
		out_std_text ( vdi_handle, x, y, col, wrm, s ) ;
		y += 16 ;
	} while ( *ss != 0 ) ;
	MouseOn();
	return len ;
}


/*---------------------------------------------- vdi_printf --------*/
int vdi_printf ( int x, int y, int wrm, const char *format, ... )
{
	return vdi_vprintf ( x, y, wrm, format, ... ) ;
}




/*... video ...............*/

bool with_grab ;

# define VID_1_1	0
# define VID_1_2	1
# define VID_1_4	2
POPUP_MENU *pup_video_size ;
int video_size = VID_1_1 ;

# ifdef PO_VFAC
struct POTIstruct vfac_poti =
	 { NULL, PO_VFAC, &video.factor,  MINvfactor, MAXvfactor, MAXvfactor, 1, 0, NULL, no_update, NULL } ;
# endif

# ifdef PO_COUNT
struct POTIstruct frames_poti =
	DEFpsmn ( PO_COUNT,  &video.frames, MAXvframes, no_update, NULL ) ;
# endif

int sensitivity = ( ~ SENSinit ) & 0xFF ;
struct POTIstruct sens_poti =
	 { NULL, PO_SENS, &sensitivity,  0, 255, 255,
	   1, 0, NULL, no_update, NULL } ;

/*... writing_mode ... */


/*------------------------------------------- set_tool_pup_value ---*/
bool set_tool_pup_value ( POPUP_MENU *pup, int toolicn, int value,
						  int mini, int maxi )
{
	if ( mini <= value && value <= maxi )
	{
		popup_set_value ( pup, value,
				find_toolbox_entry ( toolicn ) >= 0 ) ;
		return TRUE ;
	}
	else
		return FALSE ;
}


int writing_mode = MD_REPLACE ;
POPUP_MENU *pup_writing_mode ;

/*------------------------------------------- set_new_writing_mode ----*/
void set_new_writing_mode ( int wrm )
{
	if ( wrm == DEFpar )
		wrm = MD_REPLACE ;
	set_tool_pup_value ( pup_writing_mode, IT_VDI, wrm,
						  MD_REPLACE, MD_ERASE ) ;
}

/*... blit_mode ... */

int blit_mode = S_ONLY ;
POPUP_MENU *pup_blit_mode ;

/*------------------------------------------- set_new_blit_mode ----*/
void set_new_blit_mode ( int blm )
{
	if ( blm == DEFpar )
		blm = S_ONLY ;
	set_tool_pup_value ( pup_blit_mode, IT_VDI, blm,
						  ALL_WHITE, MAXblitOP ) ;
}


/*------------------------------------------- set_new_pattern ----*/
void set_new_pattern ( int pat )
{
	if ( pat == DEFpar )
		pat = DEFpattern ;
	if ( pat >= MINpattern && pat <= MAXpattern )
	{
		pattern = pat ;
		set_fill_pattern();
		if ( find_toolbox_entry ( IT_VDI ) >= 0 )
		{
			vdis_poti ( &pattern_poti ) ;
			update_pattern();
		}
		else
		{
			vupdate_poti ( &pattern_poti ) ;
		}
	}
}


/*... text_effects ... */

int text_effects = 0 ;
POPUP_MENU *pup_text_effects ;

POPUP_MENU *pup_mirror ;

int mirr_mode = MIR_POINT ;

/*-------------------------------------------- update_and_save_config -----*/
void update_and_save_config ( void)
{
	configuration.work.x = tcdraw_work.x ;
	configuration.work.y = tcdraw_work.y ;
	configuration.work.w = tcdraw_work.w ;
	configuration.work.h = tcdraw_work.h ;
						
	strncpy ( configuration.picpath, pic_path, STPATHLEN ) ;
						
	save_config ( DEFAULTcfg ) ;
}


/*-------------------------------------------- load_and_set_config -----*/
void load_and_set_config ( void)
{
	load_config ( DEFAULTcfg ) ;
}



# define CASE_TOOLS \
	case IT_GNRAL :\
	case IT_FILTR :\
	case IT_HELP :\
	case IT_HISTO :\
	case IT_VDI :\
	case IT_COPY :\
	case IT_DISK :\
	case IT_VIDEO :\
	case IT_TVPAR :\
	case IT_RUNS :\
	case IT_PALET :\
	case IT_WIND :\
	case IT_DEMO

# define CASE_CLOSER \
	case CL_SELCT :\
	case CL_GNRAL :\
	case CL_FILTR :\
	case CL_HISTO :\
	case CL_VDI :\
	case CL_COPY :\
	case CL_DISK :\
	case CL_VIDEO :\
 	case CL_TVPAR :\
 	case CL_RUNS :\
	case CL_PALET :\
	case CL_WIND :\
	case CL_HELP :\
	case CL_DEMO


# define CASE_GEN_MODES \
	case IC_LINE :\
	case IC_DOT :\
	case IC_CIRCL :\
	case IC_FILL :\
	case IC_RECT :\
	case IC_FRECT :\
	case IC_COPY :\
	case IC_DTOS :\
	case IC_STOD :\
	case IC_TOBOX :\
	case IC_FRBOX :\
	case IC_VIDEO :\
	case IC_TEXT

# define CASE_DEMOS \
	case IC_RDEMO :\
	case IC_LDEMO :\
	case IC_CNDEM :\
	case IC_BDEMO

# define CASE_TC_MODES \
	case IC_MIRR :\
	case IC_LUPE :\
	case IC_FRUN :\
	case IC_3RUN :\
	case IC_4RUN :\
	case IC_MRUN :\
	case IC_CRUN :\
	case IC_STORE :\
	case IC_LOAD :\
	case IC_PSIM :\
	case IC_FILTR :\
	case IC_CALIB :\
	case IC_GRAY :\
	case IC_YUV :\
	case IC_INV :\
	case IC_BRIGH :\
	case IC_HRECT :\
	case IC_HLINE

# define CASE_IC_USEROBJ \
	case IC_CUBE :\
	case IC_RBOW :\
	case IC_FRACT

# define CASE_IC_MODES CASE_GEN_MODES : CASE_TC_MODES : CASE_DEMOS



/*-------------------------------------------------------- obj_info_text -----*/
char *obj_info_text ( int obj )
{
	switch ( obj )
	{
case BT_SELCT :	return MSG_TOOL_SELECT ; 
case BT_GNRAL :
case IT_GNRAL :	return MSG_TOOL_GENERAL ; 
case BT_FILTR :
case IT_FILTR :	return MSG_TOOL_FILTER ; 
case BT_HISTO :
case IT_HISTO :	return MSG_TOOL_HISTO ; 
case BT_VDI :
case IT_VDI :		return MSG_TOOL_VDI ; 
case BT_COPY :
case IT_COPY :	return MSG_TOOL_COPY ; 
case BT_DISK :
case IT_DISK :	return MSG_TOOL_DISK ; 
case BT_VIDEO :
case IT_VIDEO :	return MSG_TOOL_VIDEO ; 
case BT_RUNS :
case IT_RUNS :	return MSG_TOOL_RUNS ; 
case BT_PALET :
case IT_PALET :	return MSG_TOOL_PALET ; 
case BT_DEMO :
case IT_DEMO :	return MSG_TOOL_DEMO ; 
case BT_WIND :
case IT_WIND :	return MSG_TOOL_WINDOW ; 
case IB_HELP :
case BT_HELP :
case IT_HELP :	return MSG_TOOL_HELP ; 
case BT_TVPAR :
case IT_TVPAR :	return MSG_TOOL_TVPAR ; 

CASE_CLOSER :			return MSG_CLOSER ;

case BX_CANVS :			return MSGcanvas ; 
POTIf(PO_VDICO) :	return MSGvdiColor ; 
POTIf(PO_RED) :			return MSGredIntensity ; 
POTIf(PO_GREEN) :		return MSGgreenIntensity ; 
POTIf(PO_BLUE) :		return MSGblueIntensity ;

 
case BX_HISTO :		return "Histogrammgraph" ; 
case IC_HRECT :	return "Histogramm FlÑche" ; 
case IC_HLINE :	return "Histogramm Linie" ; 

case IC_PUZZL :		return "Puzzle Modus" ;		 
case BX_SAVE :			return "Kopierpuffer" ;		 
case IC_CLIP :			return "Clip Rechteck" ;		 
case IC_OLINE :		return "Umriû" ;		 
case BX_BICOL :		return "Farbe GEM-Auswahl /  picken" ; 

case TX_PFORM :	return "Bilddateiformat" ; 
# ifdef BU_WGRAB
case BU_WGRAB :	return "Grab aktiv" ; 
# endif
case BU_VAUTO :	return "Videosignal suchen" ; 
# ifdef BU_MDVER
case BU_MDVER :	return "Andere Hardware wÑhlen" ; 
# endif
case BU_SDEF :	return "TV-Parameter Defaults" ; 


case BX_LCOL :	return "Linienfarbe picken" ; 
case BX_TCOL :	return "Textfarbe picken" ; 
case BX_FCOL :	return "FÅllfarbe picken" ; 

case IC_PSIM :		return "Palettensimulation [ P ]" ; 

case IC_FILTR :		return "Matrix-Filter" ; 
case IC_CALIB :		return "Kalibration" ; 
case IC_INV :		return "Invertieren" ; 
case IC_GRAY :		return "Graustufen" ;
case IC_YUV :		return "RGB -> YUV" ;
case IC_BRIGH :		return "Aufhellen" ; 
POTIf(PO_R_MSK) :	return "Palettensimulation : Bits rot" ; 
POTIf(PO_G_MSK) :	return "Palettensimulation : Bits grÅn" ; 
POTIf(PO_B_MSK) :	return "Palettensimulation : Bits blau" ; 
case IC_GRID :			return "Maus-Rastfunktion ( Gitter )" ; 
POTIf(PO_OLINE) :	return "Umriû-Dicke" ; 
POTIf(PO_XGRID ) :	return "Gitterweite horizontal" ; 
POTIf(PO_YGRID ) :	return "Gitterweite vertikal" ; 
case ICN_CLI :		return "Command Line Interpreter" ; 
case IC_ERASE :		return "Alles lîschen" ; 
case IC_STORE :		return "Ausschnitt speichern [ ^S ]" ; 
case IC_LOAD :		return "Bild laden [ ^L ]" ; 
case TX_WMODE :		return "Schreibmodus" ; 
case TX_BMODE:		return "KopierverknÅpfung" ; 
case TX_EFFCT:		return "Texteffekte" ; 
case TX_INFO:		return "Infozeile / Texteingabe ( Klick | 'Tab' )" ; 
case TX_IMODE:		return "Pixel Information" ; 
case TX_MAT:		return "Auswahl Filter" ; 
case TX_GS:			return "Graustufenmodus" ; 

/* ---- TV PAR ---- */
case TX_CHAN :		return "Eingang" ; 
case TX_VSRC :		return "Quelle" ; 
case TX_TVSTD : 	return "Standard" ; 
case TX_SIGT :		return "Signaltyp" ; 
case TX_DMODE :		return "Darstellung" ; 
case TX_CORI:		return "Coring-Bits" ; 
case TX_APER :		return "Apertur" ; 
case TX_BPSS :		return "Luminance-Filter" ; 
case TX_PREF :		return "Pre-Filter" ; 
case TX_CTRAP :		return "Farbfalle" ; 
case TX_AGC :		return "Auto Gain Control" ; 
POTIf(PO_SENS) :	return "FarbsensitivitÑt (PAL/SECAM)" ;

case TX_CSPAC:	return "Farbraum FarbwÅrfel" ; 
POTIf(PO_PATT ) :	return "FÅllmuster" ; 


POTIf(PO_CNDEM ) :	return "Anzahl Objekte" ; 
POTIf(PO_ERDEM ) :	return "Gleichzeitig sichtbare Objekte" ; 

POTIf( PO_TRCOL ) :	return "Transparentfarbe fÅr Bilder" ; 

case IC_RDEMO :		return "Rechteck Demo" ;
case IC_LDEMO :		return "Linien Demo" ;
case IC_CNDEM :		return "Kreis Demo" ;
case IC_BDEMO :		return "FlÑchen Demo" ;
case IC_PALDEMO :	return "Demo Palettensimulation" ;
case IC_SHOW :		return rsrc_gstring ( ST_SHOW ) ;
 
case IC_VIDEO :		return "Videofenster" ; 
case IC_VSWI :		return "Kontinuierlich digitalisieren Start / Stop [ O ]" ;
case IC_SNAP :		return "Einzelbild digitalisieren" ;
case IC_ZAHN :		return "BewegungsunschÑrfe eliminieren" ;
# ifdef PO_COUNT
POTIf(PO_COUNT) :		return "Anzahl Digitalisierungen" ;
# endif
# ifdef PO_VFAC
POTIf(PO_VFAC) :	return "Digitalisierungsfaktor" ;
# endif

case IC_LUPE :			return "Zoom [ Z ]" ; 
# if 0
case IC_LINE :			return "Linie [ L ], -antialiased" ; 
# else
case IC_LINE :			return "Linie [ L ]" ; 
# endif
case IC_CIRCL :		return "Kreis" ; 
case IC_DOT :			return "Punkt" ; 
case IC_FRECT :		return "GefÅlltes Rechteck [ B ]" ; 
case IC_FILL :			return "FluûfÅllen bis != Farbe /  != Pixel  [ F ]" ; 
case IC_RECT :			return "Rechteck [ R ]" ;				 
 case IB_FRACT :
case IC_FRACT :		return "Fractale" ;				 
case IC_FRUN :		return "Verlauf, Farbwahl fÅr Eckpunkte" ; 
case IC_3RUN :			return "Verlauf in Dreieck, Farbwahl fÅr Eckpunkte" ; 
case IC_4RUN :			return "Verlauf in Parallelogramm, Farbwahl fÅr Eckpunkte" ; 
case IC_CRUN :		return "Verlauf Åber Eckpunkte" ;	 
case IB_RBOW :
 case IC_RBOW :		return "Regenbogen" ;				 
case IC_MRUN :		return "Verlauf, Farbwahl fÅr beliebige Punkte" ; 
case IC_MIRR :		switch ( mirr_mode )
					{
				case MIR_POINT :	return "Spiegelung um Zentrum" ;	 
				case MIR_0	  :	return "Spiegelung horizontal" ;	 
				case MIR_45	  :	return "Spiegelung schrÑg ( 45 \370 )" ; 
				case MIR_90	  :	return "Spiegelung vertikal" ;	 
				case MIR_135	  :	return "Spiegelung schrÑg ( 135 \370 )" ; 
					}
					break ;
case TX_GRAD :		return "Spiegelachse ( Grad )" ;	 
case IC_TEXT :		return "Text [ T ]" ;					 
case IB_CUBE :
case IC_CUBE :		return "FarbwÅrfel [ U ]" ;			 
case IC_DTOS :		return "Bereich transformieren" ;		
case IC_STOD :		return "Bereich transformieren" ;		
case IC_COPY :			return "Bereich kopieren [ C ]" ;		
case IC_TOBOX :		return "Bereich in Kopierpuffer kopieren" ;		
case IC_FRBOX :		return "Kopierpuffer in Bild kopieren" ;		
	}
	return empty_mesg ;				
}



# define icon_disable(tree,icn)	icon_change (icn,DISABLED)
# define icon_select(tree,icn)	icon_change (icn,SELECTED)
# define icon_normal(tree,icn)	icon_change (icn,NORMAL)


/*------------------------------------------ clear_curr_mode -----*/
void clear_curr_mode ( void )
{
	switch ( curr_mode )
	{
CASE_IC_USEROBJ :
		ObjectChange ( tcdraw_tree, curr_mode+1,
							NORMAL, icon_visible(curr_mode) ) ;
		icon_normal ( tcdraw_tree, curr_mode ) ;
		break ;
CASE_IC_MODES :
		icon_normal ( tcdraw_tree, curr_mode ) ;
		break ;
	}
	curr_mode = -1 ;
	curr_help = empty_mesg ;
}

/*-------------------------------------------- set_curr_mode -------*/
void set_curr_mode ( void )
{
	switch ( curr_mode )
	{
CASE_IC_MODES :
		icon_select ( tcdraw_tree, curr_mode ) ;
		curr_help = obj_info_text ( curr_mode ) ;
		break ;
CASE_IC_USEROBJ :
		ObjectChange ( tcdraw_tree, curr_mode+1,
								SELECTED, icon_visible(curr_mode) ) ;
		icon_select ( tcdraw_tree, curr_mode ) ;
		curr_help = obj_info_text ( curr_mode ) ;
		break ;
	}
	info_printf ( curr_help ) ;
}


/*-------------------------------------------------------- check_mouse -------*/
void check_mouse ( int form )
{
	if ( base_mouse_form != form )
	{
		graf_mouse ( form, 0 ) ;
		base_mouse_form = form ;
	}
}

/*-------------------------------------- senspoti_state ------------*/
void senspoti_state ( int standard )
{
	if ( standard == PUP_NTSC )
/*		poti_disable ( &sens_poti ) */ ; 
	else
/*		poti_enable ( &sens_poti ) */ ;
}


/* ---> poti.c ??? @@@ */
/*------------------------------------ vdis_update_poti ------------*/
void vdis_update_poti ( int obj, POTENTIOMETER poti )
{
	if ( find_toolbox_entry ( obj ) >= 0 )
		vdis_poti ( poti ) ;
	else
		vupdate_poti ( poti ) ;
}


/*--------------------------------------------- save_box_visible ------------*/
bool save_box_visible ( bool mesg )
{
	if ( find_toolbox_entry ( IT_WIND ) >= 0 )
	{
		return TRUE ;
	}
	else
	{
		if ( mesg )
		{
			info_printf ( "Kopierfenster nicht sichtbar" ) ;
			release_button() ;
		}
		return FALSE ;
	}
}



/*--------------------------------------------- save_box_inside ------------*/
bool save_box_inside ( int *pts )
{
	return ( save_box_visible ( FALSE )
					&& pts[X1] - pts[X0] < save_box.w && pts[Y1] - pts[Y0] < save_box.h ) ; 
}


/*--------------------------------------------- save_to_box ------------*/
void save_to_box ( int *pts )
{
	int pts1[4] ;

	saved_rect.w = pts[X1] - pts[X0] + 1 ;
	if ( saved_rect.w > save_box.w )
		saved_rect.w = save_box.w ;
	saved_rect.h = pts[Y1] - pts[Y0] + 1 ;
	if ( saved_rect.h > save_box.h )
		saved_rect.h = save_box.h ;

	fill_object ( tcdraw_tree, BX_SAVE, BLACK ) ;
	pts[X1] = pts[X0] + saved_rect.w - 1 ;
	pts[Y1] = pts[Y0] + saved_rect.h - 1 ;
	copy_box ( pts, SetPointsFromRect ( pts1, &saved_rect ), blit_mode ) ;
}


/*--------------------------------------------- ToBox ------------*/
void ToBox ( int *pts )
{
	if ( save_box_visible ( TRUE ) )
		save_to_box ( pts ) ;
}

			
bool full_saved = FALSE ;
int pts_centered[4], pts_saved[4] ;


/*--------------------------------------------- full_inside_canvas ------------*/
bool full_inside_canvas ( int *pts )
{
	if ( pts[X0] < canvas.x )
		return FALSE ;
	if ( pts[X1] >= canvas.x + canvas.w )
		return FALSE ;
	if ( pts[Y0] < canvas.y )
		return FALSE ;
	if ( pts[Y1] >= canvas.y + canvas.h )
		return FALSE ;
	return TRUE ;
}

/*--------------------------------------------- inside_canvas ------------*/
bool inside_canvas ( int *pts )
{
	return pts[X0] >= canvas.x
		&& pts[X0] < canvas.x + canvas.w
		&& pts[Y0] >= canvas.y
		&& pts[Y0] < canvas.y + canvas.h ;
}

/*--------------------------------------------- chk_canvas_pts ------------*/
void chk_canvas_pts ( int *pts )
{
	if ( pts[X0] < 0 )	pts[X0] = canvas.x ;
	if ( pts[Y0] < 0 )	pts[Y0] = canvas.y ;
	if ( pts[X1] <= 0 )	pts[X1] = canvas.x + canvas.w - 1 ;
	if ( pts[Y1] <= 0 )	pts[Y1] = canvas.y + canvas.h - 1 ;
}

/*--------------------------------------------- set_canvas_pts ------------*/
void set_canvas_pts ( int *pts )
{
	pts[X0] = canvas.x ;
	pts[Y0] = canvas.y ;
	pts[X1] = canvas.x + canvas.w - 1 ;
	pts[Y1] = canvas.y + canvas.h - 1 ;
}


/*--------------------------------------------- save_full_box ------------*/
void save_full_box ( int *pts )
# define ZOOM_DIV	4
{
	int dx2, dy2 ;

	dx2 = save_box.w / (2*ZOOM_DIV) ;
	dy2 = save_box.h / (2*ZOOM_DIV) ;
	saved_rect.w = dx2 * 2 ;
	saved_rect.h = dy2 * 2 ;
	pts_centered[X0] = pts[X0] - dx2 ;
	pts_centered[X1] = pts[X0] + dx2 ;
	pts_centered[Y0] = pts[Y0] - dy2 ;
	pts_centered[Y1] = pts[Y0] + dy2 ;

	if ( ! full_inside_canvas ( pts_centered ) )
		return ;

	copy_box ( pts_centered, SetPointsFromRect ( pts_saved, &saved_rect ), S_ONLY ) ;
	full_saved = TRUE ;
}

/*--------------------------------------------- restore_full_box ------------*/
void restore_full_box ( void )
{
	if ( full_saved )
	{
		copy_box ( pts_saved, pts_centered, S_ONLY ) ;
		full_saved = FALSE ;
	}
}


/*------------------------------------------------------ run_zoom --*/
bool run_zoom ( int *pts )
{
	if ( save_box_visible ( FALSE ) )
	{
		restore_full_box ( ) ;
		save_full_box ( pts ) ;
		zoom_copy ( pts_saved, pts_centered ) ;
		return TRUE ;
	}
	return FALSE ;
}

# define RUBline	0
# define RUBrect	1
# define RUBblit	2
# define RUBtext	3
# define RUBcircle	4
# define RUBcross	5

# define RUBdraw	0
# define RUBdelete	1

int	rub_pattern = 0x3333 ;

/*---------------------------------------------------------- init_rubber_object ---*/
void init_rubber_object ( int rubtyp )
{
	switch ( rubtyp )
	{
case RUBcircle :
case RUBtext :	break ;
case RUBcross :
case RUBline :
case RUBrect :	vsl_udsty ( vdi_handle, rub_pattern ) ;
				set_line_attr ( MD_XOR, 7, 1, BLACK ) ;
				break ;
case RUBblit :	fill_object ( tcdraw_tree, BX_SAVE, BLACK ) ;
				saved_rect.w = source_rect[X1] - source_rect[X0] + 1 ;
				saved_rect.h = source_rect[Y1] - source_rect[Y0] + 1 ;
				break ;
	}
}


/*---------------------------------------------------------- term_rubber_object ---*/
void term_rubber_object ( int rubtyp )
{
	switch ( rubtyp )
	{
case RUBtext :	vst_effects (  vdi_handle, 0 ) ;
				break ;
	}
}

/*---------------------------------------------------------- draw_rubber_object ---*/
bool draw_rubber_object ( int *pts, int rubtyp, int mode )
{
	int pts1[4] ;

	switch ( rubtyp )
	{
case RUBtext :	vswr_mode ( vdi_handle, MD_XOR ) ;
				vst_alignment ( vdi_handle, 0, 5, &dummy, &dummy ) ;
				vst_effects (  vdi_handle, text_effects ) ;
   				if ( is_mattc )
   					vst_rgb ( vdi_handle, curr_text_rgb ) ;
   				else
   					vst_color ( vdi_handle, curr_color ) ;
				if ( mode == RUBdraw )
				{
					v_gtext ( vdi_handle, pts[X0], pts[Y0], curr_text ) ;
					strcpy ( back_text, curr_text ) ;
				}
				else
				{
					v_gtext ( vdi_handle, pts[X0], pts[Y0], back_text ) ;
				}
				return TRUE ;

case RUBline :	if ( mode == RUBdraw )
					rub_pattern = ~rub_pattern ;
				vsl_udsty ( vdi_handle, rub_pattern ) ;
				vswr_mode ( vdi_handle, MD_XOR ) ;
				draw_linep ( pts ) ;
				return TRUE ;

case RUBcross :	if ( mode == RUBdraw )
					rub_pattern = ~rub_pattern ;
				vsl_udsty ( vdi_handle, rub_pattern ) ;
				vswr_mode ( vdi_handle, MD_XOR ) ;
				draw_cross ( pts ) ;
				return TRUE ;

case RUBrect :	if ( mode == RUBdraw )
					rub_pattern = ~rub_pattern ;
				vsl_udsty ( vdi_handle, rub_pattern ) ;
				vswr_mode ( vdi_handle, MD_XOR ) ;
				draw_rect ( pts ) ;
				return TRUE ;

case RUBcircle :
				vswr_mode ( vdi_handle, MD_XOR ) ;
				vsf_interior ( vdi_handle, FIS_HOLLOW );
				vsf_color ( vdi_handle, BLACK );
				vsf_perimeter ( vdi_handle, 1 );
				DrawCircle ( pts ) ;
				return TRUE ;

case RUBblit :	if ( mode == RUBdraw )
				{
					copy_box ( pts,					/* save background		*/
							   SetPointsFromRect ( pts1, &saved_rect ),
			  				   S_ONLY ) ;
					copy_box ( source_rect,
							   pts, 
			  				   blit_mode ) ;
				}
				else	/*	RUBdelete	*/						/* restore backgroud	*/
					copy_box ( SetPointsFromRect ( pts1, &saved_rect ),
							   pts,
							   S_ONLY ) ;
				return TRUE ;
default :		return FALSE ;
	}
}
	
/*----------------------------------------------- get_2d --------------*/
int get_2d ( int *pts, char *info, int rubtyp )
{
	int button ;
	int lpts[4] ;
	long loop ;
	bool drawn ;
	
	release_button() ;

	if ( pts[X0] < 0 || pts[Y0] < 0 )
	{
		MouseThinCross();
		button = get_position ( pts, info ) ;
		if ( button & RIGHT_BUTTON )
			return button ;
	}

	clip_grid ( NULL, pts ) ;

	lpts[X1] = lpts[X0] = pts[X1] = pts[X0] ;
	lpts[Y1] = lpts[Y0] = pts[Y1] = pts[Y0] ;
	drawn = FALSE ;
	
	info_printf ( "Startpunkt %4d:%4d - %s", pts[X0], pts[Y0], info ) ;
	init_rubber_object ( rubtyp ) ;
	
	WindMouseBegin() ;
	for ( loop = 0; ; loop++ )
	{
		if ( mouse_move ( &pts[X1], &button, TRUE ) || loop == 0  )
		{
			if ( loop == 0 )
				MouseOff();
			if ( drawn )
				draw_rubber_object ( lpts, rubtyp, RUBdelete ) ;
			if ( button & BOTH_BUTTONS )
			{
# if 0
				if ( inside_work(lpts[X1],lpts[Y1]) )
# endif
					release_button() ;
				WindMouseEnd() ;
				MouseOn();
				term_rubber_object ( rubtyp ) ;
				if ( button & RIGHT_BUTTON )
					info_printf ( FCTaborted ) ;
				else
					info_printf ( "" ) ;

				if ( rubtyp != RUBline )
					sort_pts ( pts ) ;

				return button ;
			}
			if ( ( puzzle_mode || rubtyp == RUBtext || rubtyp == RUBblit )
						&& grid_width.x > 1 && grid_width.y > 1 )
			{
				pts[X0] = pts[X1] - grid_width.x ;				/* mouse pos is right bottom corner	*/
				pts[Y0] = pts[Y1] - grid_width.y ;

				if ( pts[X0] < canvas.x )
				{
					pts[X0] = canvas.x ;
					pts[X1] = canvas.x + grid_width.x ;
				}
				if ( pts[Y0] < canvas.y )
				{
					pts[Y0] = canvas.y ;
					pts[Y1] = canvas.y + grid_width.y ;
				}
			}

			drawn = draw_rubber_object ( pts, rubtyp, RUBdraw ) ;
			if ( drawn )
			{
				lpts[X1] = pts[X1] ;
				lpts[Y1] = pts[Y1] ;
				lpts[X0] = pts[X0] ;
				lpts[Y0] = pts[Y0] ;
				if ( rubtyp == RUBcircle )
				{
					info_printf ( "%4d:%4d / %4d:%4d (%4d) - %s",
								lpts[X0], lpts[Y0], lpts[X1], lpts[Y1],
								radius ( lpts ),
								info ) ;
				}
				else
				{
					info_printf ( "%4d:%4d / %4d:%4d (%4d:%4d) - %s",
								lpts[X0], lpts[Y0], lpts[X1], lpts[Y1],
								lpts[X1] - lpts[X0],
								lpts[Y1] - lpts[Y0],
								info ) ;
				}
			}
		}
	}
}



# define get_rectangle(pts,info)	get_2d(pts,info,RUBrect)	

/*......... M F D B ...........................................*/

/*--------------------------------------------- free_mfdb -----*/
void free_mfdb ( MFDB **pmfdb )
{
	if ( *pmfdb != NULL )
	{
		if ( (*pmfdb)->fd_addr != NULL )
			Mfree ( (*pmfdb)->fd_addr ) ;
		Mfree ( *pmfdb ) ;
		*pmfdb = NULL ;
	}
}

int out_line = 0 ;

/*--------------------------------------------- print_nl -----*/
void print_nl ( void )
{
   	printf ( "\033Y%c ", ' '+(out_line++ % 8)+10 ) ;
}

/*---------------------------------------------------------------- print_mfdb -----*/
void print_mfdb ( FILE *out, MFDB *mfdb, char *name )
{
   	fprintf ( out, "MFDB %s = { $%8.8lx, %3d:%3d, wi=%d, pl=%d, std=%d }",
				name, mfdb->fd_addr, mfdb->fd_w, mfdb->fd_h, mfdb->fd_wdwidth,
					  mfdb->fd_nplanes, mfdb->fd_stand ) ;
}


/*---------------------------------------------------------------- malloc_mfdb -----*/
MFDB *malloc_mfdb ( int dx, int dy, int planes, int std )
{
	MFDB *mfdb ;
	int mono_wpl ;
	long size ;
	
	mfdb = Mxalloc ( sizeof ( MFDB ), 3 ) ;
	if ( mfdb != NULL )
	{
		mono_wpl = ( dx + 15 ) / 16 ;	/* round up to * 16	bits */
		size = (long)mono_wpl * (long)dy * (long)planes * sizeof(word) ;
		mfdb->fd_addr = Mxalloc ( size, 3 ) ;
		if ( mfdb->fd_addr != NULL )
		{
			mfdb->fd_nplanes = planes ;
			mfdb->fd_w		 = dx ;
			mfdb->fd_h		 = dy ;
			mfdb->fd_wdwidth = mono_wpl ;
			mfdb->fd_stand	 = std ;
# if 0
				print_nl();
				print_mfdb ( mfdb, "mall" ) ;
				printf ( ", size = %ld\n", size ) ;
# endif
			return ( mfdb ) ;
		}
		else
			Mfree ( mfdb ) ;
	}
	return ( NULL ) ;
}


/*......................................................................*/

# define exec_line(fct,sav)   exec_function ( pts, RUBline,   fct,	sav )
# define exec_rect(fct,sav)   exec_function ( pts, RUBrect,   fct,	sav )
# define exec_blit(fct,sav)   exec_function ( pts, RUBblit,   fct,	sav )
# define exec_circle(fct,sav) exec_function ( pts, RUBcircle, fct,	sav )
# define exec_cross(fct,sav)  exec_function ( pts, RUBcross,  fct,	sav )


/*--------------------------------------------- exec_function ------*/
void exec_function ( int *pts, int rubtyp, GRAPHICfunction graphfct, int save )
{
	if ( ! ( get_2d ( pts, curr_help, rubtyp )
				 & RIGHT_BUTTON ) )
	{
		MouseOff();
		clip_on() ;
		start_time = get_ticks() ;
		pts[X1] -= end_corr.x ;
		pts[Y1] -= end_corr.y ;
		graphfct ( pts ) ;
		end_time = get_ticks() ; 
		if ( save )
			save_p0p1 ( pts ) ;
		MouseOn();
	}
	release_button();
}





uword histo_data[3*1024] ;
uword histo_maxi  = 0 ;
uword histo_xmaxi  = 0 ;
uword histo_count = 0 ;
int   histo_back  = WHITE ;

/*--------------------------------------------- histo_info ------------*/
bool histo_info ( int *pts )
{
	RECTangle rect ;

	if ( histo_count > 0 )
	{
		ObjectGetRectangle ( tcdraw_tree, BX_HISTO, rect ) ;
		info_printf ( "x = %3u, y = %3u",
						uscale ( pts[X0] - rect.x, histo_count, rect.w ),
						uscale ( rect.y + rect.h - 1 - pts[Y0], histo_maxi, rect.h - 1 ) ) ;
		return TRUE ;
	}
	else
		return FALSE ;
}

/*--------------------------------------------- draw_histogramm ------------*/
void draw_histogramm ( void )
{
	RECTangle rect ;
	int bc ;

	if ( histo_count > 0 )
	{
		ObjectGetRectangle ( tcdraw_tree, BX_HISTO, rect ) ;
	
		set_fill_attr ( FIS_SOLID, 1, histo_back, 0  ) ;
		filled_box ( rect.x, rect.y, rect.w, rect.h ) ;
	
		o_printf ( tcdraw_tree, TX_HMAX, "%5u",  histo_maxi ) ;
		ObjectDraw ( tcdraw_tree, TX_HMAX ) ;
		o_printf ( tcdraw_tree, TX_HXMAX, "%5u", histo_xmaxi ) ;
		ObjectDraw ( tcdraw_tree, TX_HXMAX ) ;
		for ( bc = R; bc <= B; bc++ )
		{
			draw_curve ( vdi_handle, &rect, histo_maxi,
							  &histo_data[ histo_count * bc ], histo_count, RED+bc  ) ;
		}
	}
}


/*--------------------------------------------- histo_rect ------------*/
void histo_rect ( int *pts )
{
	histo_back = WHITE ;		
	get_rgb_histo ( pts, histo_data ) ;
	histo_count = 256 ;
	histo_xmaxi = 255 ;
	histo_maxi  = max_histo ( histo_data, 3*256 ) ;

	draw_histogramm() ;
}


/*--------------------------------------------- histo_line ------------*/
void histo_line ( int *pts )
{
	histo_back = BLACK ;		
	histo_count = get_line_histo ( pts, histo_data ) ;
	histo_xmaxi = hypothenuse ( pts ) ;
	histo_maxi  = 255 ;

	draw_histogramm() ;
}


/*--------------------------------------------- Filter ----------------*/
void Filter ( int *pts )
{
	filter_rect ( pts, filters[selected_matrix] ) ;
}



/*.......   u s e r  o b j e c t s   .............................*/

/*-------------------------------------------------------- SetPointsFromPARMBLK --*/
int *SetPointsFromPARMBLK ( int *pts, PARMBLK *parmblock )
{
	pts[X0] = parmblock->pb_x ;
	pts[Y0] = parmblock->pb_y ;
	pts[X1] = parmblock->pb_x + parmblock->pb_w - 1 ;
	pts[Y1] = parmblock->pb_y + parmblock->pb_h - 1 ;

	return pts ;
}


/*--------------------------------------- usrobj_pattern -------*/
int cdecl usrobj_pattern ( PARMBLK *parmblock )
{
	parmblock = parmblock ;	/* no warning	*/

	set_fill_pattern();

	vswr_mode	  ( vdi_handle, MD_REPLACE ) ;      
	vsf_interior  ( vdi_handle, interior ) ;
	vsf_style	  ( vdi_handle, style ) ;
	vsf_perimeter ( vdi_handle, 1 ) ;
	vsf_color	  ( vdi_handle, BLACK ) ;
	filled_box ( parmblock->pb_x, parmblock->pb_y,
				 parmblock->pb_w, parmblock->pb_h ) ;
	return 0 ;
}


/*----------------------------------------- obj_frame ----*/
void obj_frame ( int *pts )
{
	set_line_attr ( MD_REPLACE, 1, 1, BLACK ) ;

	draw_line4 ( pts[X0], pts[Y0], pts[X0], pts[Y1] ) ;	/*	left	*/
	draw_line4 ( pts[X0], pts[Y1], pts[X1], pts[Y1] ) ;	/*	bottom	*/
	draw_line4 ( pts[X0], pts[Y0], pts[X1], pts[Y0] ) ;	/*	top		*/
	draw_line4 ( pts[X1], pts[Y0], pts[X1], pts[Y1] ) ;	/*	right	*/
}

/*--------------------------------------- usrobj_fill -------*/
int cdecl usrobj_fill ( PARMBLK *parmblock )
{
	int scrpts[4] ;

	vswr_mode ( vdi_handle, MD_REPLACE ) ;      
	vsf_interior ( vdi_handle, FIS_SOLID ) ;
	vsf_perimeter ( vdi_handle, 0 ) ;
	if ( is_mattc && (int *)parmblock->pb_parm != NULL )
		vsf_rgb ( vdi_handle, (int *)parmblock->pb_parm ) ;
	else
		vsf_color ( vdi_handle, curr_color ) ;
  	filled_box ( parmblock->pb_x+1, parmblock->pb_y+1,
				 parmblock->pb_w-2, parmblock->pb_h-2 ) ;
	obj_frame ( SetPointsFromPARMBLK ( scrpts, parmblock ) ) ;
	return 0 ;
}

/*--------------------------------------- find_last_blank ---*/
char *find_last_blank ( char *start, char *end )
{
	for ( ; end > start ; end-- )
	{
		if ( *end == ' ' )
			return end ;
	}
	return NULL ;
}


/*--------------------------------------- usrobj_help -------*/
int cdecl usrobj_help ( PARMBLK *parmblock )
{
	int len, maxl ;
	
	maxl = parmblock->pb_w / hwchar ;

	len = (int)strlen ( curr_help ) ;
	if ( len <= maxl )
	{
		out_std_text ( vdi_handle,
					   parmblock->pb_x, parmblock->pb_y, BLACK, MD_TRANS,
					   curr_help ) ;
	}
	else
	{
		char h, *start, *sb, *se, *end, hstr[6*22] ;	/* ??? */
		int y ;
		
		strcpy ( hstr, curr_help ) ;

		start = hstr ;
		se = hstr + len ;
		y = parmblock->pb_y ;
		for(;;)
		{
			end = start + maxl ;
			if ( end < se )
			{
				sb = find_last_blank ( start, end ) ;
				if ( sb == NULL )	/* no blank found	*/
					sb = end ;
				h = *sb ;	/* save char */
				*sb = 0 ;
			}
			else
				sb  = NULL ;

			out_std_text ( vdi_handle, parmblock->pb_x, y, BLACK, MD_TRANS,
				 		   start ) ;
			if ( sb == NULL )
				break ;
			y += hhchar ;
			start = sb ;
			if ( h == ' ' )
				start += 1 ;
			else
				*start = h ;	/* restore char */
		}
	}
	return 0 ;
}


/*--------------------------------------- usrobj_chk_select --------*/
int usrobj_chk_select ( PARMBLK *parmblock )
{
	if ( parmblock->pb_currstate & SELECTED )
	{
		set_invert_attr() ;
		filled_box ( parmblock->pb_x, parmblock->pb_y,
					 parmblock->pb_w, parmblock->pb_h ) ;
	}
	return 0 ;
}

/*--------------------------------------- usrobj_cube -------*/
int cdecl usrobj_cube ( PARMBLK *parmblock )
{
	int scrpts[4] ;
	
  	rgb_cube ( SetPointsFromPARMBLK ( scrpts, parmblock ),
			   CMYspace ) ;
	usrobj_chk_select ( parmblock ) ;
	return 0 ;
}

# define FRACT_DATA	1

# if FRACT_DATA
# include "fracticn.h"
# else
# define FW	parmblock->pb_w
# define FH	parmblock->pb_h

MFDB *fract_mfdb = NULL ;
# endif

# if FRACT_DATA
/*--------------------------------------- usrobj_fract -------*/
int cdecl usrobj_fract ( PARMBLK *parmblock )
{
	int pxyarray[8], color_index[1] ;

	pxyarray[X0] = pxyarray[Y0] = 0 ;
	pxyarray[X1] = FW - 1 ;
	pxyarray[Y1] = FH - 1 ;
							   
	SetPointsFromPARMBLK ( &pxyarray[4], parmblock ) ;

	vrt_cpyfm ( vdi_handle, MD_REPLACE, pxyarray,
						&fract_mfdb, &vdi_screen, color_index ) ;
	usrobj_chk_select ( parmblock ) ;
	return 0 ;
}

# else

/*--------------------------------------- usrobj_fract -------*/
int cdecl usrobj_fract ( PARMBLK *parmblock )
{
	int scrpts[4], fracpts[4] ;

	fracpts[X0] = fracpts[Y0] = 0 ;
	fracpts[X1] = FW - 1 ;
	fracpts[Y1] = FH - 1 ;
							   
	SetPointsFromPARMBLK ( scrpts, parmblock ) ;

	if ( fract_mfdb == NULL )
	{
		check_stop_off();
		draw_fractal ( 7*256-1,
						 parmblock->pb_x, parmblock->pb_y,
						   parmblock->pb_w,	parmblock->pb_h,
# if 1
									-0.74591, -0.74448, 0.11196, 0.11339, 40.0 ) ;
# else
									-3.0, -3.0, 3.0, 3.0, 40.0 ) ;
# endif
		fract_mfdb = malloc_mfdb ( parmblock->pb_w,	parmblock->pb_h, bit_planes, 0 ) ; 
		if ( fract_mfdb != NULL )
		{
			copy_block ( scrpts, fracpts, S_ONLY,
					  	 &vdi_screen, fract_mfdb ) ;
			{
				FILE *out ;
				int x, y, dxx ;
				byte *bp ;
				
				out = fopen ( "FRACTICN.S", "w" ) ;
				if ( out != NULL )
				{
					dxx = (parmblock->pb_w + 15 ) / 16 * 16 ;
					fprintf ( out, "w = %d, w+ = %d\n",
									parmblock->pb_w, dxx ) ;
					
					bp = fract_mfdb->fd_addr ;
					
					print_mfdb ( out, fract_mfdb, "fract_mfdb" ) ;
					fprintf ( out, "\nlong fract_data[] = {" ) ;
					for ( y = 0; y < parmblock->pb_h ; y++ )
					{
						fprintf ( out, "\n/* line %2d */", y ) ;
						for ( x = 0; x < dxx ; x++ )
						{
							if (( x & 3 ) == 0 )
								fprintf ( out, "\n" );
							fprintf ( out, " 0x%02x,0x%02x,0x%02x,",
												 bp[1], bp[2], bp[3] ) ;
							bp += 4 ;
						}
					}
					fprintf ( out, "} ;" ) ;
					fclose ( out ) ;
				}
			}
		}
	}
	else
	{
			copy_block ( fracpts, scrpts, S_ONLY,
					  	 fract_mfdb, &vdi_screen ) ;
	}
	usrobj_chk_select ( parmblock ) ;
	return 0 ;
}
# endif

/*--------------------------------------- usrobj_bow -------*/
int cdecl usrobj_bow ( PARMBLK *parmblock )
{
	int scrpts[4] ;

  	rain_bow ( SetPointsFromPARMBLK ( scrpts, parmblock ) ) ;
	usrobj_chk_select ( parmblock ) ;

	return 0 ;
}

USERBLK usrblk_line = { usrobj_fill, 	(long)curr_line_rgb } ;
USERBLK usrblk_text = { usrobj_fill, 	(long)curr_text_rgb } ;
USERBLK usrblk_fill = { usrobj_fill, 	(long)curr_fill_rgb } ;

USERBLK usrblk_pat  = { usrobj_pattern, 0					} ;

USERBLK usrblk_cbox = { usrobj_fill, 	(long)NULL			} ;
USERBLK usrblk_help = { usrobj_help, 	0					} ;

USERBLK usrblk_cube  = { usrobj_cube, 	0					} ;
USERBLK usrblk_fract = { usrobj_fract, 	0					} ;
USERBLK usrblk_bow   = { usrobj_bow, 	0					} ;


/*--------------------------------------- make_user_object -------*/
void make_user_object ( OBJECT *tree, int obj, USERBLK *usrblk )
{
	tree[obj].ob_type		  = G_USERDEF ;
	tree[obj].ob_spec.userblk = usrblk ;
}

/*--------------------------------------- init_user_objects -------*/
void init_user_objects ( void )
{
	make_user_object ( tcdraw_tree, BX_LCOL, &usrblk_line ) ;
  	make_user_object ( tcdraw_tree, BX_TCOL, &usrblk_text ) ;
  	make_user_object ( tcdraw_tree, BX_FCOL, &usrblk_fill ) ;

  	make_user_object ( tcdraw_tree, BX_PATT,	&usrblk_pat   ) ;
  	make_user_object ( tcdraw_tree, BX_BICOL,	&usrblk_cbox  ) ;
  	make_user_object ( tcdraw_tree, IB_HELP,		&usrblk_help  ) ;
	if ( is_mattc )
  	{
  		make_user_object ( tcdraw_tree, IB_CUBE,		&usrblk_cube  ) ;
  		make_user_object ( tcdraw_tree, IB_FRACT,	&usrblk_fract ) ;
  		make_user_object ( tcdraw_tree, IB_RBOW,	&usrblk_bow   ) ;
  	}
}

/*.......   t o o l b o x   ......................................*/


TOOLbox tool_boxes[] = {
	{ NOicon,	BT_SELCT,	CL_SELCT,	MT_SELCT,	0x0001	},
	{ IT_GNRAL,	BT_GNRAL,	CL_GNRAL,	MT_GNRAL,	0x0002	},
	{ IT_FILTR,	BT_FILTR,	CL_FILTR,	MT_FILTR,	0x0004	},
	{ IT_VDI,	BT_VDI,		CL_VDI,		MT_VDI,		0x0002	},
	{ IT_HISTO,	BT_HISTO,	CL_HISTO,	MT_HISTO,	0x0004	},
	{ IT_COPY,	BT_COPY,	CL_COPY,	MT_COPY,	0x0002	},
	{ IT_DISK,	BT_DISK,	CL_DISK,	MT_DISK,	0x0001	},
	{ IT_VIDEO,	BT_VIDEO,	CL_VIDEO,	MT_VIDEO,	0x0001	},
	{ IT_TVPAR,	BT_TVPAR,	CL_TVPAR,	MT_TVPAR,	0x0001	},
	{ IT_RUNS,	BT_RUNS,	CL_RUNS,	MT_RUNS,	0x0001	},
	{ IT_PALET,	BT_PALET,	CL_PALET,	MT_PALET,	0x0002	},
	{ IT_DEMO,	BT_DEMO,	CL_DEMO,	MT_DEMO,	0x0001	},
	{ IT_WIND,	BT_WIND,	CL_WIND,	MT_WIND,	0x0002	},
	{ IT_HELP,	BT_HELP,	CL_HELP,	MT_HELP,	0x0001	},
	{ -1, -1, -1, -1, 0 }
} ;


/*-------------------------------------------- redraw_toolbox -------*/
void redraw_toolbox ( int icnobj )
{
	switch ( icnobj )
	{
 case IT_WIND :	ObjectGetRectangle ( tcdraw_tree, BX_SAVE, save_box ) ;
						SetRectangle ( saved_rect, save_box.x, save_box.y, 0, 0 ) ;
						break ;
 case IT_HISTO :	draw_histogramm() ;
  						break ;
  	}
}

int redraw_sequence = 0 ;

/*--------------------------------------------- redraw_tcdraw -----*/
void redraw_tcdraw ( RECTangle *work, RECTangle *rect, int loop )
{
	NOwarning(work);

# if TEST == 2
	printf ( "+ redraw_tcdraw %3d:%3d %3d:%3d, loop : %d\n",
				 VALrect(*rect), loop ) ;
# endif		

	if ( loop == 0 )
	{
		redraw_sequence++ ;
		update_color_potis();
		set_curr_mode () ;
		ObjectGetRectangle ( tcdraw_tree, BX_CANVS, canvas ) ;
	}

	objc_draw ( tcdraw_tree, BX_DRWIN, MAX_DEPTH, VALrect(*rect) ) ;

	if ( buffer_ok() )
	{
		if ( redraw_sequence > 1 )
		{
			ClippingOn ( vdi_handle, canvas ) ;
			if ( rc_intersect ( &canvas, rect ) )
				restore_window ( work, rect ) ;
		}
		else
		{
			save_window ( &tcdraw_work, rect ) ;
		}
	}


	redraw_toolboxes ( rect ) ;
# if TEST == 2
	printf ( "- redraw_tcdraw\n" ) ;
# endif		

}



/*------------------------------------------------- chk_mat_graph -----*/
bool chk_mat_graph ( void )
{
	if ( is_mattc )
		return ( TRUE ) ;

	info_printf ( "* Nur mîglich auf MATRIX Karte im TC Modus" ) ;
	release_button();
	return ( FALSE ) ;
}


/*--------------------------------------------- to_box ------------*/
void to_box ( int *pts )
{
	if ( save_box_visible ( TRUE ) )
	{
		if ( ! ( get_rectangle ( pts, "Quelle" ) & RIGHT_BUTTON ) )
		{
			MouseOff();
			save_to_box ( pts ) ;
			MouseOn();
		}
	}
}


MFDB *buf_mfdb = NULL ;



/*--------------------------------------------- dev_to_std ------------*/
void dev_to_std ( int *pts )
/* copy screen window to memory	*/
{
	int  dx, dy ;
	MFDB *mfdb1 ;
		
	if ( ! ( get_rectangle ( pts, "Quelle" ) & RIGHT_BUTTON ) )
	{
		dx = pts[X1]-pts[X0]+1 ;
		dy = pts[Y1]-pts[Y0]+1 ;
		free_mfdb ( &buf_mfdb ) ;
		buf_mfdb = malloc_mfdb ( dx, dy, bit_planes, 1 ) ;
		if ( buf_mfdb != NULL )
		{
			mfdb1 = malloc_mfdb ( dx, dy, bit_planes, 0 ) ; 
			if ( mfdb1 != NULL )
			{
				int dpts[4] ;
# if 0
				print_nl();
				print_mfdb ( mfdb1, "mfdb1" ) ;
				print_nl();
			   	printf ( "copy %3d:%3d..%3d:%3d -> %3d:%3d..%3d:%3d",
						   	pts,
							 0, 0, dx-1, dy-1 ) ;
# endif
				MouseOff();
				dpts[X0] = dpts[Y0] = dx - 1 ;
				dpts[X1] = dx - 1 ;
				dpts[Y1] = dy - 1 ;
				copy_block ( pts, dpts, blit_mode,
							 &vdi_screen, mfdb1 ) ;
				MouseOn();
# if 0
				print_nl();
				print_mfdb ( mfdb1, "mfdb1" ) ;
				print_nl();
				print_mfdb ( buf_mfdb, "buf_mfdb" ) ;
# endif
				vr_trnfm ( vdi_handle, mfdb1, buf_mfdb ) ;
				free_mfdb ( &mfdb1 ) ;
				return ;
			}
			free_mfdb ( &buf_mfdb ) ;
		}
		info_printf ( "Nicht genÅgend Speicher frei" ) ;
	}
}

/*--------------------------------------------- std_to_dev ------------*/
void std_to_dev ( int *pts )
{
	int spts[4] ;
	
	MFDB *mfdb1 ;
	
	if ( buf_mfdb != NULL )
	{
		mfdb1 = malloc_mfdb ( buf_mfdb->fd_w, buf_mfdb->fd_h, buf_mfdb->fd_nplanes, 0 ) ; 
		if ( mfdb1 != NULL )
		{
			vr_trnfm ( vdi_handle, buf_mfdb, mfdb1 ) ;
			MouseOff();
			spts[X0] = spts[Y0] = 0 ;
			spts[X1] = buf_mfdb->fd_w - 1 ;
			spts[Y1] = buf_mfdb->fd_h - 1 ;
			pts[X1] = pts[X0] + spts[X1] ;
			pts[Y1] = pts[Y0] + spts[Y1] ;
			copy_block ( spts, pts, blit_mode,
						 mfdb1, &vdi_screen ) ;
			MouseOn();
			free_mfdb ( &mfdb1 ) ;
		}
		else
			info_printf ( "Nicht genÅgend Speicher frei" ) ;
	}
	else
		info_printf ( "Transformpuffer leer" ) ;
}


/*--------------------------------------------- screen_to_screen ------------*/
void screen_to_screen ( int *pts )
{
	int rubtyp ;
	POINT old_gw ;
	
	if ( ! ( get_rectangle ( pts, "Quelle" ) & RIGHT_BUTTON ) )
	{
		int dstpts[4] ;

		dstpts[X0] = dstpts[Y0] = -1 ;
		rubtyp = save_box_inside ( pts ) ? RUBblit : RUBrect ;
		source_rect[X0] = pts[X0] ;
		source_rect[Y0] = pts[Y0] ;
		source_rect[X1] = pts[X1] ;
		source_rect[Y1] = pts[Y1] ;
		if ( rubtyp == RUBblit )
		{
			old_gw.x = grid_width.x ;
			old_gw.y = grid_width.y ;
			grid_width.x = pts[X1] - pts[X0] + 1 ;
			grid_width.y = pts[Y1] - pts[Y0] + 1 ;
		}

		if ( ! ( get_2d ( dstpts, "Ziel", rubtyp ) & RIGHT_BUTTON ) )
		{
			MouseOff();
			copy_rectangle ( pts, dstpts ) ;
			MouseOn();
		}

		if ( rubtyp == RUBblit )
		{
			grid_width.x = old_gw.x ;
			grid_width.y = old_gw.y ;
		}

	}
}


/*--------------------------------------------- Text ------------*/
void Text ( int *pts )
{
	if ( ! ( get_2d ( pts, "Text", RUBtext ) & RIGHT_BUTTON ) )
	{
		MouseOff();
		clip_on();
		DrawText ( pts, curr_text ) ;
		save_p0p1 ( pts ) ;
		MouseOn();
	}
}
				

/*--------------------------------------------- FromBox ------------*/
void FromBox ( int *pts )
{
	int pts1[4] ;
 
	if ( save_box_visible ( TRUE ) )
	{
		if ( RectangleNotEmpty ( saved_rect ) )
				copy_box ( SetPointsFromRect ( pts1, &saved_rect ),
						   pts, blit_mode ) ;
		else
			info_printf ( "Kopierpuffer leer" ) ;
	}
}


/*--------------------------------------------- from_box ------------*/
void from_box ( int *pts )
{
	int pts1[4] ;
 
	if ( save_box_visible ( TRUE ) )
	{
		if ( RectangleNotEmpty ( saved_rect ) )
		{
			if ( ! ( get_rectangle ( pts, "Ziel" ) & RIGHT_BUTTON ) )
			{
				MouseOff();
				clip_on();
				copy_box ( SetPointsFromRect ( pts1, &saved_rect ),
						   pts, blit_mode ) ;
				save_p0p1 ( pts ) ;
				MouseOn();
			}
		}
		else
		{
			info_printf ( "Kopierpuffer leer" ) ;
			release_button() ;
		}
	}
}




typedef struct
{
	POINT	pos ;
	byte	color[3] ;
	long	idist ;
} COLORpoint ;


# define MULTI_MODE	1

/*-------------------------------------------------- DrawMultiRun ------------*/
void DrawMultiRun ( int *pts, ulong	unit, int ncolpts, COLORpoint *cptab )
{
	POINT 	p ;
	ulong	sum_dist ;
	ulong	col[3] ;
	byte 	rgb[3] ;
	COLORpoint *cpt ;
	int		n ;
	
	for ( p.y = pts[Y0]; p.y <= pts[Y1]; p.y++ )
	{
		for ( p.x = pts[X0]; p.x <= pts[X1]; p.x++ )
		{
			cpt = cptab ;
			sum_dist = 0 ;
			col[0] = 0 ;
			col[1] = 0 ;
			col[2] = 0 ;
			for ( n = 0; n < ncolpts; n++ )
			{
# if MULTI_MODE == 0
 # if 0
 				cpt->idist = isqr_dist ( &p, &cpt->pos, unit ) ;
 # else
 				long ax, ay, axy ;
 				
				ax = sqr ( p.x - cpt->pos.x ) ;
				ay = sqr ( p.y - cpt->pos.y ) ;
				axy = ax + ay ;
				if ( axy == 0 )
					cpt->idist = -1 ;
				else
					cpt->idist = unit / axy ;
 # endif
# elif MULTI_MODE == 1
				int ax, ay, axy ;
				
				ax = p.x - cpt->pos.x ; if ( ax < 0 ) ax = -ax ;
				ay = p.y - cpt->pos.y ; if ( ay < 0 ) ay = -ay ;
				axy = ax + ay ;
				if ( axy == 0 )
					cpt->idist = -1 ;
				else
					cpt->idist = unit / axy ;
# elif MULTI_MODE == 2
				int ax, ay ;
				
				ax = p.x - cpt->pos.x ; if ( ax < 0 ) ax = -ax ;
				ay = p.y - cpt->pos.y ; if ( ay < 0 ) ay = -ay ;
				cpt->idist = unit - ( ax + ay ) ;
# endif
				if ( cpt->idist < 0 )
				{
					set_pixel ( p.x, p.y, cpt->color ) ;	/* exact match	*/
					sum_dist = 0 ;
					break ;
				}
# if MULTI_MODE == 0  && 0 /* ????????????????? */
				add_color ( col, cpt->color, cpt->idist ) ;
# elif MULTI_MODE == 1 || MULTI_MODE == 2
				col[0] += cpt->color[0] * cpt->idist ;
				col[1] += cpt->color[1] * cpt->idist ;
				col[2] += cpt->color[2] * cpt->idist ;
# endif
				sum_dist += cpt->idist ;
				cpt++ ;
			}

			if ( sum_dist > 0 )
			{		
				rgb[0] = col[0]/sum_dist ;
				rgb[1] = col[1]/sum_dist ;
				rgb[2] = col[2]/sum_dist ;
				set_pixel ( p.x, p.y, rgb ) ;
			}
		}
	}
}


/*-------------------------------------------------- GetMultiRunPoints ------------*/
int GetMultiRunPoints ( COLORpoint *cpt, int maxpts )
{
	char	s[48] ;
	int		ncolpts, cpts[2] ;

	for ( ncolpts = 1 ;  ; ncolpts++, cpt++  )
	{
		sprintf ( s, "Position Farbpunkt %d", ncolpts ) ;
		MouseThinCross();
		if ( get_position ( cpts, s ) & RIGHT_BUTTON )
			return 0 ;
		cpt->pos.x = cpts[X0] ;
		cpt->pos.y = cpts[Y0] ;
		if ( ( fetch_color ( cpt->color, "Farbe picken, Ende mit Klick rechts" )  & RIGHT_BUTTON )
				|| ( ncolpts >= maxpts ) )
			break ;;
	}
	return ncolpts ;
}


/*----------------------------------------------- multi_point_run ----------*/
void draw_frame_with_mouse_off ( int *pts )
{
	MouseOff();
	draw_frame ( pts ) ;
	MouseOn();
}

/*----------------------------------------------- multi_point_run ----------*/
void multi_point_run ( int *pts  )
{
# define MAXpoints 16
	ulong	unit ;
	int		ncolpts ;
	COLORpoint col_pt_table[MAXpoints] ;
 
	ncolpts = GetMultiRunPoints ( col_pt_table, MAXpoints ) ;
	if ( ncolpts > 0 )
	{
		MouseOff();
		info_printf ( curr_help ) ;
	
# if MULTI_MODE == 0
# if 0	
		unit = sqr ( scr_max_x + 1 ) + sqr ( scr_max_y + 1 ) ;
# else
		unit = 800*600 ;
# endif
# elif MULTI_MODE == 1
		unit = 16*32768L ;
# elif MULTI_MODE == 2
		unit = 16*32768L) / MAXpoints ; ??
		unit = scr_max_x + 1 + scr_max_y + 1 ;
# endif
		start_time = get_ticks() ;
		DrawMultiRun ( pts, unit, ncolpts, col_pt_table ) ;
		MouseOn();
	}
}








/*-------------------------------------------------- set_new_mode --*/
void set_new_mode ( int obj )
{
	if ( curr_mode != obj && tool_enabled ( obj ) )
	{
		clear_curr_mode () ;
		curr_mode = obj ;
		set_curr_mode () ;
		quadrat = obj == IC_MIRR && ( mirr_mode == MIR_45 || mirr_mode == MIR_135 ) ;
	}
	release_button();
}


/*-------------------------------------------------- set_icn_mode --*/
void set_icn_mode ( int obj )
{
	set_new_mode ( obj ) ;
}

/*-------------------------------------------------- set_demo_mode --*/
void set_demo_mode ( int demo_obj, int demonum )
{
	demo_number	= demonum ;
	set_new_mode ( demo_obj ) ;
}


int last_obj = 0 ;
int last_mx = 0 ;
int last_my = 0 ;
char *last_mesg = NULL ;
char pos_mesg[32] ;

/*-------------------------------------------------------- display_pixel_status -----*/
void display_pixel_status ( int *pts )
{
	byte *pixa ;
	int rgb[3] ;

	MouseOff();
	switch ( info_mode )
	{
  case INFO_NORM+INFOhex :
  case INFO_CONT+INFOhex :
		pixa = (byte *)pixel_address ( pts[X0], pts[Y0] ) ;
		info_printf ( "%4d:%4d ($%02x $%02x:$%02x:$%02x)",
							pts[X0], pts[Y0], pixa[0], pixa[1], pixa[2], pixa[3] ) ;
		break ;
  case INFO_PERC :
		vq_pixrgb ( vdi_handle, pts[X0], pts[Y0], rgb ) ;
		info_printf ( "%4d:%4d   R=%3d%% G=%3d%% B=%3d%%",
						pts[X0], pts[Y0], rgb[0]/10, rgb[1]/10, rgb[2]/10 ) ;
		break ;
  case INFOzoom :
		run_zoom ( pts ) ;
		break ;
  default :
  		vq_pixrgb ( vdi_handle, pts[X0], pts[Y0], rgb ) ;
	  	info_printf ( "%4d:%4d (%4d:%4d:%4d)",
						pts[X0], pts[Y0], rgb[0], rgb[1], rgb[2] ) ;
		break ;
	}
	MouseOn();
}

/*-------------------------------------------------------- terminate_video --*/
void terminate_video ( void )
{
	int pts[4] ;
	
	digitiser_stop() ;
	MouseOff() ;
	save_p0p1 ( SetPointsFromRect ( pts, &curr_video->window ) ) ;
	MouseOn() ;
}

/*----------------------------------------------- auto_chk_video -----*/
void auto_chk_video ( bool draw )
{
	if ( channel == PUP_AUTO )
	{
		set_lumi_cntrl ( aperture, coring, bpss, 
						 prefilter, 0 ) ;
		chk_set_chan_sig ( &channel, &signal, &chroma_trap ) ;
		popup_update ( pup_channel, ( draw & ( channel != PUP_AUTO ) ) ) ;
		popup_update ( pup_signal, ( draw & ( signal != PUP_AUTO ) ) ) ;
		popup_update ( pup_trap, ( draw &
									( signal != PUP_AUTO ) &
									( find_toolbox_entry ( IT_TVPAR ) >= 0 ) ) ) ;
		set_lumi_cntrl ( aperture, coring, bpss, 
						 prefilter, chroma_trap ) ;
	}
	if ( signal == PUP_AUTO )
	{
		set_lumi_cntrl ( aperture, coring, bpss, 
						 prefilter, 0 ) ;
		chk_set_signal ( channel, &signal, &chroma_trap ) ;
		popup_update ( pup_signal, ( draw & ( signal != PUP_AUTO ) ) ) ;
		popup_update ( pup_trap, ( draw &
									( signal != PUP_AUTO ) &
									( find_toolbox_entry ( IT_TVPAR ) >= 0 ) ) ) ;
		set_lumi_cntrl ( aperture, coring, bpss, 
						 prefilter, chroma_trap ) ;
	}
	if ( tv_standard == PUP_AUTO )
	{
		chk_set_std ( video_source, &tv_standard, &sensitivity ) ;
		senspoti_state ( tv_standard ) ;
		vdis_update_poti ( IT_TVPAR, &sens_poti ) ;
		popup_update ( pup_tvstand, draw & ( tv_standard != PUP_AUTO ) ) ;
	}
}


/*-------------------------------------------------------- video_icon_select ----*/
void video_icon_select ( int mode )
{
	if ( mode == IC_VSWI )
		strcpy ( tcdraw_tree[IC_VSWI].ob_spec.iconblk->ib_ptext, "Stop" ) ;
# if 0
	else
		icon_disable ( tcdraw_tree, IC_VSWI ) ;
# endif
	icon_select ( tcdraw_tree, mode ) ;
}

/*-------------------------------------------------------- video_icon_normal ----*/
void video_icon_normal ( void )
{
	strcpy ( tcdraw_tree[IC_VSWI].ob_spec.iconblk->ib_ptext, "Start" ) ;
	icon_normal ( tcdraw_tree, IC_VSWI ) ;
	icon_normal ( tcdraw_tree, IC_SNAP ) ;
}


/*-------------------------------------------------------- timer_tcdraw -----*/
void timer_tcdraw ( int mx, int my )
{
	int pts[4] ;
	int obj ;
	char *m ;

	pts[X0] = mx ;
	pts[Y0] = my ;

	if ( icon_visible ( IC_VIDEO ) )
	{
		if ( multiple_time-- <= 0 )
		{
			auto_chk_video ( DRAW ) ;
			multiple_time = MAX_MULT_TIME ;
		}
	}

	if ( video_on && ! digitiser_running() )
	{
		terminate_video() ;
		info_printf ( "Digitalisierung beendet" ) ;
		video_icon_normal() ;
		return ;
	}

	if ( info_mode >= INFO_CONT && info_mode < INFO_PERC )
	{
		display_pixel_status ( pts ) ;
		return ;
	}

	if ( pts[X0] != last_mx || pts[Y0] != last_my )
	{
		last_mx = pts[X0] ;
		last_my = pts[Y0] ;

		obj = objc_find ( tcdraw_tree, BX_DRWIN, MAX_DEPTH, pts[X0], pts[Y0] ) ;
		if ( obj > 0 )
		{
			if ( obj == BX_HISTO && histo_info ( pts ) )
			{
				check_mouse ( THIN_CROSS ) ;
				return ;
			}

			if ( obj == BX_CANVS )
			{
				check_mouse ( THIN_CROSS ) ;
				if ( info_mode != INFO_OFF )
				{
					display_pixel_status ( pts ) ;
					last_mesg = NULL ;
					last_obj = obj ;
					return ;
				}
# if 0
				if ( zoom_active && run_zoom ( pts ) )
					return ;
# endif
				m = curr_help ;
			}
			else
			{
				if ( last_obj == obj )
					return ;
				else
					m = obj_info_text ( obj ) ;
			}

			if ( m != last_mesg )
			{
				check_mouse ( POINT_HAND ) ;
				info_printf ( "%s", m ) ;
				last_mesg = m ;
			}
			last_obj = obj ;
		}
		else
		{
			if ( last_obj > 0 )
			{
				last_obj = obj ;
				last_mesg = empty_mesg ;
			}
		}
	}
}

# define EVEN(n) (n & 0xFFFE)
/*-------------------------------------------------------- SetVideoWindow -----*/
void SetVideoWindow ( int *pts )
{
	SetRectangle ( curr_video->window,
					EVEN(pts[X0]), pts[Y0],
					EVEN(pts[X1]) - EVEN(pts[X0]) + 2,
					pts[Y1] - pts[Y0] + 1 ) ;
}

/*-------------------------------------------------------- SetVideoFrames -----*/
void SetVideoFrames ( int frms )
{
	if ( video.frames != frms )
	{
		video.frames = frms ;
# ifdef PO_COUNT
		vdis_update_poti ( IT_TVPAR, &frames_poti ) ;
# endif
	}
}

/*-------------------------------------------------------- switch_video_off -----*/
void switch_video_off ( void )
{
	if ( video_on )
	{
		terminate_video() ;
		info_printf ( "Digitalisierung bei Bild %d abbgebrochen",
						current_frame() ) ;
		video_icon_normal() ;
	}
}

/*-------------------------------------------------------- restart_video -----*/
void restart_video ( void )
{
	if ( video_on )
	{
		switch_video_off() ;
		switch_video_on ( IC_VSWI ) ;
	}
}


/*--------------------------------------------------------- check_video_window -*/
bool check_video_window ( void )
{
	if ( RectangleNotEmpty ( curr_video->window ) )
	{
		return TRUE ;
	}
	else
	{
		info_printf ( "Kein Digitalisierfenster definiert" ) ;
		return FALSE ;
	}
}


/*-------------------------------------------------------- switch_video_on -----*/
void switch_video_on ( int mode )
{
	if ( check_video_window() )
	{	
		if ( display_mode == GREY_DISPLAY || video.factor == 8 )
	 	{
			video_icon_select ( mode );
		
			switch ( digitise_video ( with_grab, display_mode, matbpp ) )
			{
		  case OK :	info_printf ( "Digitalisierung gestartet" ) ;
					break ;
		  case 1 :	info_printf ( "TC Karte nicht initialisert" ) ;
					break ;
		  case 2 :	info_printf ( "Graphikkern nicht geladen" ) ;
					break ;
		  case 3 :	info_printf ( "Fehler bei Initialisierung Graphikkern" ) ;
					break ;
		  case 5 :	info_printf ( "Grafikprozessor nicht bereit" ) ;
					break ;
			}
		}
		else
		{
			info_printf ( "Farbdigitalisierung nur bei Vollbild mîglich" ) ;
		}
		if ( ! video_on )
			video_icon_normal() ;
	}
}

/*-------------------------------------------------------- switch_video -----*/
void switch_video ( int mode )
{
	if ( video_on )
		switch_video_off() ;
	else
		switch_video_on ( mode ) ;
}


/*......................................................................*/

/*--------------------------------------------- exec_rectfct ------*/
void exec_rectfct ( GRAPHICfunction graphfct,
					int *pts, int save  )
{
	MouseOff();
	clip_on() ;
	start_time = get_ticks() ;
	graphfct ( pts ) ;
	end_time = get_ticks() ;
	if ( save )
		save_p0p1 ( pts ) ;
	MouseOn();
}



/*----------------------------------------------- exec_command -----*/
void exec_command ( int *pts )
{
	snap_xy2_canv ( pts ) ;
	switch ( curr_mode )
	{
 case IC_RECT :		exec_rectfct ( draw_frame, pts, 1 ) ;
					break ;
 case IC_FRECT :	exec_rectfct ( filled_rectangle, pts, 1 ) ;
					break ;
 default :			info_printf ( NOTimplemented ) ;
					break ;
	}
}


/*--------------------------------------------- draw_run_frame -----*/
void draw_run_frame ( int *ptsa )
{
	draw_linep ( ptsa ) ;
	draw_line4 ( ptsa[0], ptsa[1], ptsa[4], ptsa[5] ) ;
	if ( curr_mode == IC_3RUN )
	{
		draw_linep ( &ptsa[2] ) ;
	}
	else	/* IC_4RUN	*/
	{
		ptsa[6] = ptsa[2] + ( ptsa[4] - ptsa[0] ) ;	/* end - x	*/
		ptsa[7] = ptsa[3] + ( ptsa[5] - ptsa[1] ) ;	/* end - y	*/
		draw_line4 ( ptsa[2], ptsa[3], ptsa[6], ptsa[7] ) ;
		draw_linep ( &ptsa[4] ) ;
	}
}



/*-------------------------------------------------------- canvas_function -----*/
void canvas_function ( int *pts )
{
	int kbstate ;
	
	switch ( curr_mode )
	{
case IC_CIRCL :
				exec_circle ( circle_function, 1 ) ;
				break ;

case IC_DOT :	MouseOff () ;
				vs_pixrgb ( vdi_handle, pts[X0], pts[Y0], curr_fill_rgb ) ;
				MouseOn() ;
				break ;

case IC_LINE :	exec_line ( Line, 1 ) ;
				break ;

case IC_FILL :	MouseOff();
				evnt_button ( 0, 0, 0, &dummy, &dummy, &dummy, &kbstate ) ;
				Fill ( pts, kbstate & K_ALT ? curr_color : -1 ) ;
				MouseOn();
				break ;

case IC_MIRR:	exec_rect ( Mirror, 1 ) ;
				break ;

case IC_RECT :	exec_rect ( draw_frame, 1 ) ;
				break ;

case IC_CUBE :	exec_rect ( color_cube, 1 ) ;
				break ;

case IC_HRECT :
				exec_rect ( histo_rect, 0 ) ;
				break ;
				
case IC_HLINE :
				exec_line ( histo_line, 0 ) ;
				break ;

case IC_FILTR :exec_rect ( Filter, 0 ) ;
				break ;

case IC_CALIB :
				if ( ! ( get_rectangle ( pts, obj_info_text ( IC_CALIB ) ) & RIGHT_BUTTON ) )
				{
					int pts[4] ;
					
					MouseThinCross();
					if ( get_position ( &pts[X0], "Referenzbereich oberer Rand" ) & RIGHT_BUTTON )
						break ;
					if ( get_position ( &pts[X1], "Referenzbereich unterer Rand" ) & RIGHT_BUTTON )
						break ;
					MouseOff();
					start_time = get_ticks() ;
					calib_rect ( pts, pts[Y0], pts[Y0] ) ;
					end_time = get_ticks() ; 
					save_p0p1 ( pts ) ;
					MouseOn();
				}
				break ;

case IC_INV :	exec_rect ( invert_rect, 1 ) ;
				break ;

case IC_YUV :	exec_rect ( yuv_rect, 1 ) ;
				break ;
		
case IC_GRAY :	exec_rect ( gray_rect, 1 ) ;
				break ;
		
case IC_BRIGH :	exec_rect ( bright_rect, 1 ) ;
				break ;

case IC_3RUN :
case IC_4RUN :	{
					int rgbs[12], ptsa[8] ;

# define X(i)	ptsa[((i)*2)]
# define Y(i)	ptsa[((i)*2+1)]
					X(0) = pts[0] ;
					Y(0) = pts[1] ;
					
					MouseThinCross();
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

					MouseOff();
					draw_run_frame ( ptsa ) ;						
					MouseOn();

					if ( fetch_rgb_color ( &rgbs[0], "Farbe picken fÅr Punkt 1" ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[3], "Farbe picken fÅr Punkt 2" ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[6], "Farbe picken fÅr Punkt 3" ) & RIGHT_BUTTON )
							break ;
					if ( curr_mode != IC_3RUN )
						if ( fetch_rgb_color ( &rgbs[9], "Farbe picken fÅr Punkt 4" ) & RIGHT_BUTTON )
							break ;

					MouseOff();
					start_time = get_ticks() ;
					if ( curr_mode == IC_3RUN )
						vrun_triangle ( vdi_handle, ptsa, rgbs ) ;
					else
						vrun_parallel ( vdi_handle, ptsa, rgbs ) ;
					end_time = get_ticks() ; 
					if ( with_outlines )
						draw_run_frame ( ptsa ) ;
					MouseOn();
				}
				break ;


case IC_FRUN :	if ( ! ( get_rectangle ( pts, obj_info_text ( IC_FRUN ) ) & RIGHT_BUTTON ) )
				{
					int rgbs[12] ;

					draw_frame_with_mouse_off ( pts ) ;

					if ( fetch_rgb_color ( &rgbs[0], "Farbe picken fÅr linke obere Ecke"   ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[3], "Farbe picken fÅr rechte obere Ecke"  ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[6], "Farbe picken fÅr linke untere Ecke"  ) & RIGHT_BUTTON )
							break ;
					if ( fetch_rgb_color ( &rgbs[9], "Farbe picken fÅr rechte untere Ecke" ) & RIGHT_BUTTON )
							break ;

					MouseOff();
					start_time = get_ticks() ;
# if 1
					vrun_rect ( vdi_handle, pts, rgbs ) ;
# else
					rect_rgb_slope ( pts, rgbs ) ;
# endif
					end_time = get_ticks() ; 
					if ( with_outlines )
						draw_frame ( pts ) ; 
					save_p0p1 ( pts ) ;
					MouseOn();
				}
				break ;

case IC_MRUN :	if ( ! ( get_rectangle ( pts, obj_info_text ( IC_MRUN ) ) & RIGHT_BUTTON ) )
				{
					draw_frame_with_mouse_off ( pts ) ;

					multi_point_run ( pts ) ;

					end_time = get_ticks() ; 
					MouseOff();
					if ( with_outlines )
						draw_frame ( pts ) ; 
					save_p0p1 ( pts ) ;
					MouseOn();
				}
				break ;
	
case IC_CRUN :	exec_rect ( rgb_slope, 1 ) ;
				break ;
				
case IC_STORE :	if ( ! ( get_rectangle ( pts, obj_info_text ( IC_STORE ) ) & RIGHT_BUTTON ) )
				{
					MouseOff();
					save_draw_window ( pts ) ;
					MouseOn();
				}
				break ;
	
case IC_FRECT:	exec_rect ( filled_rectangle, 1 ) ;
				break ;

case IC_LUPE:	exec_cross ( zoom_box, 1 ) ;
				break ;

# define EVEN(n) (n & 0xFFFE)

case IC_VIDEO:	if ( ! ( get_rectangle ( pts, obj_info_text ( IC_VIDEO ) ) & RIGHT_BUTTON ) )
				{
					SetVideoWindow ( pts ) ;
					if ( with_outlines )
						draw_frame_with_mouse_off ( pts ) ;
				}
				restart_video ();
				break ;

CASE_DEMOS :	if ( ! ( get_rectangle ( pts, curr_help ) & RIGHT_BUTTON ) )
				{
					switch_video_off() ;
					MouseOff();
					check_stop_message() ;
					run_demo ( demo_number, demo_count, demo_erase, pts ) ;
					MouseOn();
				}
				break ;

case IC_TOBOX:	to_box ( pts ) ;
				break ;

case IC_FRBOX:	from_box ( pts ) ;
				break ;
					
case IC_COPY:	screen_to_screen ( pts ) ;
				break ;

case IC_DTOS:	dev_to_std ( pts ) ;
				break ;

case IC_STOD:	std_to_dev ( pts ) ;
				break ;

case IC_TEXT:	Text ( pts ) ;
				break ;
	
case IC_RBOW :	if ( keyboard_state ( K_ALT ) )
					exec_rect ( lines_box, 1 ) ;
				else
					exec_rect ( rain_bow, 1 ) ;
				break ;
	
case IC_LOAD :	if ( ! ( get_rectangle ( pts, obj_info_text ( IC_LOAD ) ) & RIGHT_BUTTON ) )
				{
					if ( LoadPicture ( pts ) )
					{
						MouseOff();
						save_p0p1 ( pts ) ;
						MouseOn();
					}
				}
				break ;

case IC_PSIM :
				exec_rect ( SimulateClut, 1 ) ;
				break ;
	
case IC_FRACT :
				exec_rect ( DrawFractal, 1 ) ;
				break ;
	}

	ClippingOff ( vdi_handle ) ;
}


/*-------------------------------------------------------- menu_tcdraw -----*/
bool menu_tcdraw ( int menu_entry )
{
	int icnobj ;
	
	switch ( menu_entry )
	{
  case MN_INFO :		handle_dialog ( NULL, 0, TR_INFO, NO_EDIT ) ;
						return FALSE ;
  case MN_QUIT :		term_windows();
						return TRUE ;

  case MN_LDCFG	:	load_and_set_config () ;
  						break ;
  case MN_STCFG	:	update_and_save_config () ;
  						break ;
  default :				icnobj = get_toolicn_from_menu ( menu_entry ) ;
  						if ( icnobj >= 0 )
  							switch_toolbox ( icnobj ) ;
						break ;
	}
	return FALSE ;
}

# define DEMOcolPoints	5
# define BASEdimDxy	100			/* base rectangle */
COLORpoint base_col_pt_table[DEMOcolPoints] =
{	/*	{  x, y }, {  r,  g,  b },	*/
	{	{ 20,20 }, {255,  0,  0 }, 0 },
	{	{ 80,20 }, {  0,  0,255 }, 0 },
	{	{ 20,80 }, {255,128,  0 }, 0 },
	{	{ 90,90 }, {  0,255,  0 }, 0 },
	{	{ 70,70 }, {255,  0,255 }, 0 }
} ;

COLORpoint demo_col_pt_table[DEMOcolPoints] ;

/*-------------------------------------------------------- DemoMultiColorRun -----*/
void DemoMultiColorRun ( int *pts )
{
	int		ncolpts, dx, dy ;
	COLORpoint *scpt, *dcpt ;
	
	dx = pts[X1] - pts[X0] - 1 ;
	dy = pts[Y1] - pts[Y0] - 1 ;

	scpt = base_col_pt_table ;
	dcpt = demo_col_pt_table ;
	for ( ncolpts = 1 ; ncolpts <= DEMOcolPoints ; ncolpts++, scpt++, dcpt++ )
	{
		dcpt->pos.x = pts[X0] + uscale ( scpt->pos.x, dx, BASEdimDxy ) ;
		dcpt->pos.y = pts[Y0] + uscale ( scpt->pos.y, dy, BASEdimDxy ) ;
		
		dcpt->color[R] = scpt->color[R] ;
		dcpt->color[G] = scpt->color[G] ;
		dcpt->color[B] = scpt->color[B] ;
	}

	DrawMultiRun ( pts, 16*32768L, DEMOcolPoints, demo_col_pt_table ) ;
}


/*-------------------------------------------------------- DemoShow -----*/
void DemoShow ( int mode )
{
	int pts[4], pts1[4], pts2[4], pts3[4], pts4[4], ptsm[4] ;
	int dx, dy, xmid,  ymid ;
	
	switch_video_off() ;
	MouseOff();
	close_toolboxes() ;
	SetPointsFromRect ( pts, &canvas ) ;
	
	dx = pts[X1] - pts[X0] ;
	dy = pts[Y1] - pts[Y0] ;
	xmid = pts[X0] + dx / 2 ;
	ymid = pts[Y0] + dy / 2 ;
	
	pts1[X0] = pts[X0] + 16 ;
	pts1[Y0] = pts[Y0] + 16 ;
	pts1[X1] = xmid - 16 ;
	pts1[Y1] = ymid - 16 ;
	
	pts2[X0] = xmid + 16 ;					/*			1	2		*/
	pts2[Y0] = pts1[Y0] ;					/*			3	4		*/
	pts2[X1] = pts[X1] - 16 ;
	pts2[Y1] = pts1[Y1] ;
	
	pts3[X0] = pts1[X0] ;
	pts3[Y0] = ymid + 16 ;
	pts3[X1] = pts1[X1] ;
	pts3[Y1] = pts[Y1] - 16 ;
	
	pts4[X0] = pts2[X0] ;
	pts4[Y0] = pts3[Y0] ;
	pts4[X1] = pts2[X1] ;
	pts4[Y1] = pts3[Y1] ;

	ptsm[X0] = ( pts1[X0]+pts1[X1] ) / 2 ;
	ptsm[Y0] = pts[Y0] ;
	ptsm[X1] = ( pts2[X0]+pts2[X1] ) / 2 ;
	ptsm[Y1] = pts[Y1] ;

	switch ( mode )
	{
case IC_SHOW :
		check_stop_message() ;
		for(;;)
		{
		  	rain_bow ( pts ) ;									if ( check_stop() ) break ;
		  	rgb_cube ( pts1, RGBspace ) ;						if ( check_stop() ) break ;
		  	rgb_cube ( pts4, CMYspace ) ;						if ( check_stop() ) break ;
			run_demo ( 1, demo_count, demo_erase, pts2 ) ;		if ( check_stop() ) break ;
			run_demo ( 2, demo_count, demo_erase, pts3 ) ;		if ( check_stop() ) break ;
			simulate_tclut ( ptsm, 3, 3, 2 ) ;					if ( check_stop() ) break ;
			run_demo ( 3, demo_count, demo_erase, pts2 ) ;		if ( check_stop() ) break ;
			run_demo ( 4, demo_count/2, demo_erase, pts3 ) ;	if ( check_stop() ) break ;
		}
		info_printf ( "" ) ;
		break ;

# define SUMunits	40
case IC_PALDEMO :
		pts1[X0] = pts2[X0] = pts3[X0] = pts4[X0] = pts[X0] + 160 ;
		pts1[X1] = pts2[X1] = pts3[X1] = pts4[X1] = pts[X1] - uscale (  1, dy, SUMunits ) ;
		
		pts1[Y0] = pts[Y0] + uscale (  1, dy, SUMunits ) ;
		pts1[Y1] = pts[Y0] + uscale (  9, dy, SUMunits ) ;
		
		pts2[Y0] = pts[Y0] + uscale ( 11, dy, SUMunits ) ;
		pts2[Y1] = pts[Y0] + uscale ( 19, dy, SUMunits ) ;
		
		pts3[Y0] = pts[Y0] + uscale ( 21, dy, SUMunits ) ;
		pts3[Y1] = pts[Y0] + uscale ( 29, dy, SUMunits ) ;
		
		pts4[Y0] = pts[Y0] + uscale ( 31, dy, SUMunits ) ;
		pts4[Y1] = pts[Y0] + uscale ( 39, dy, SUMunits ) ;
							/* end	SUMunits =  40 */

		set_fill_attr ( FIS_SOLID, 1, LWHITE, 0  ) ;
		filled_box ( pts[X0], pts[Y0], dx, dy ) ;

		DemoMultiColorRun ( pts1 ) ;
		copy_box ( pts1, pts2, S_ONLY ) ;
		copy_box ( pts1, pts3, S_ONLY ) ;
		copy_box ( pts1, pts4, S_ONLY ) ;
		simulate_tclut ( pts2, 5, 5, 5 ) ;

		vdi_printf ( pts[X0]+16, pts1[Y0]+16, MD_TRANS, "256 Farben\n8 Bit / Pixel\nRGB 3:3:2 Bits" ) ;
		simulate_tclut ( pts1, 3, 3, 2 ) ;
		vdi_printf ( pts[X0]+16, pts2[Y0]+16, MD_TRANS, "32.768 Farben\n15 Bit / Pixel\nRGB 5:5:5 Bits" ) ;
		simulate_tclut ( pts3, 5, 6, 6 ) ;
		vdi_printf ( pts[X0]+16, pts3[Y0]+16, MD_TRANS, "65.536 Farben\n16 Bit / Pixel\nRGB 5:6:5 Bits" ) ;
		vdi_printf ( pts[X0]+16, pts4[Y0],    MD_TRANS, "\033c\002True Color\n\033c\00116,7 Mill. Farben\n24 Bit / Pixel\nRGB 8:8:8 Bits" ) ;
		break ;
	}

	if ( buffer_ok() )
		save_window ( &tcdraw_work, &canvas ) ;

	MouseOn();
}

# if EDIT_TEXT
/*-------------------------------------------------------- edit_text_line -----*/
void edit_text_line ( void )
{
	strcpy ( tcdraw_info, curr_text ) ;
	ObjectDraw ( tcdraw_tree, TX_INFO ) ;
	edit_text ( tcdraw_tree, TX_INFO ) ;
	strcpy ( curr_text, tcdraw_info ) ;
	*tcdraw_info = 0 ;
	ObjectDraw ( tcdraw_tree, TX_INFO ) ;
}
# endif

/*-------------------------------------------------------- button_tcdraw -----*/
bool button_tcdraw ( int mx, int my, int button )
{
	int obj, pts[4] ;
	long used_time ;

	pts[X0] = mx ;
	pts[Y0] = my ;

	start_time = end_time = 0 ;

	NOwarning(button);

	obj=objc_find(tcdraw_tree,BX_DRWIN,MAX_DEPTH,mx,my);
	if(obj>0)
	{
# ifdef M00
		if ( M00 + UPDOWN_DOWN <= obj && obj <= M00+(USERdimension*USERdimension-1)*4 + UPDOWN_UP )
			click_updown ( &updown_matrix[ ( obj - M00 ) / 4 ], obj ) ;
		else
# endif
		  switch(obj)
		{
# ifdef VA_MAOFS
UPDOWN(VA_MAOFS) : 	click_updown ( &updown_offset, obj ) ;	break ;
UPDOWN(VA_MASCA) : 	click_updown ( &updown_scale, obj ) ;	break ;
# endif

POTI ( PO_VDICO ):	poti_click ( &colix_poti, obj, mx ) ;	break ;
POTI ( PO_RED ):			rgb_poti_click(R,obj,mx) ;				break ;
POTI ( PO_GREEN ):			rgb_poti_click(G,obj,mx) ;				break ;
POTI ( PO_BLUE ):			rgb_poti_click(B,obj,mx) ;				break ;

POTI ( PO_R_MSK ):		poti_click ( &clut_mask_poti[R], obj, mx ) ;	break ;
POTI ( PO_G_MSK ):		poti_click ( &clut_mask_poti[G], obj, mx ) ;	break ;
POTI ( PO_B_MSK ):		poti_click ( &clut_mask_poti[B], obj, mx ) ;	break ;


case ICN_CLI :		MouseOff();
					if ( *curr_text != 0 )
					{
						info_printf ( "CLI : %s", curr_text ) ;
						cli_line ( curr_text ) ;
					}
					release_button();
					MouseOn();
					break ;

case IC_ERASE :		MouseOff();
					close_toolboxes() ;
					erase_picture() ;
					release_button();
					MouseOn();
					break ;

POTI (PO_OLINE):poti_click ( &outline_poti, obj, mx ) ;
					break ;
case IC_OLINE :	with_outlines = toggle_selection ( tcdraw_tree, IC_OLINE ) ;
					break ;

POTI (PO_XGRID):	poti_click ( &x_grid_poti, obj, mx ) ;
					break ;
POTI (PO_YGRID):	poti_click ( &y_grid_poti, obj, mx ) ;
					break ;
case IC_GRID :		snap_grid = toggle_selection ( tcdraw_tree, IC_GRID ) ;
					break ;

case IC_PUZZL :		puzzle_mode = toggle_selection ( tcdraw_tree, IC_PUZZL ) ;
					break ;

# if 0
case IC_ZOOM :		zoom_active = toggle_selection ( tcdraw_tree, IC_ZOOM ) ;
					break ;
# endif

case IC_ZAHN :		switch_video_off() ;
					if ( check_video_window() )
					{
						SetPointsFromRect ( pts, &curr_video->window ) ;
						even_to_odd ( pts ) ;
						save_p0p1 ( pts ) ;
					}
					release_button() ;
					break ;
					
case IC_SNAP :		switch_video_off() ;
					icon_select ( tcdraw_tree, IC_SNAP ) ;
					SetVideoFrames ( 1 ) ;
					switch_video ( IC_SNAP ) ;
					release_button() ;
					break ;

case IC_VSWI :		if ( video.frames == 1 )
						SetVideoFrames ( 0 ) ;
					switch_video ( IC_VSWI ) ;
					release_button() ;
					break ;

# ifdef BU_WGRAB
case BU_WGRAB:		with_grab = toggle_selection ( tcdraw_tree, BU_WGRAB ) ;
					break ;
# endif

/* test function */
# ifdef BU_MDVER
case BU_MDVER:
					toggle_selection ( tcdraw_tree, BU_MDVER ) ;
					toggle_hardware () ;
					restart_video ();
					break ;
# endif
case BU_SDEF:
					ObjectSetState ( tcdraw_tree, BU_SDEF, SELECTED ) ;
					ObjectDraw ( tcdraw_tree, BU_SDEF ) ;
					sensitivity = ( ~ SENSinit ) & 0xFF ; 
					set_sensitivity ( tv_standard, sensitivity ) ;
					vdis_update_poti ( IT_TVPAR, &sens_poti ) ;
					lumi_cntrl_init ( &aperture, &coring, &bpss, 
									  &prefilter, &chroma_trap ) ;
					popup_update ( pup_aperture, DRAW ) ;
					popup_update ( pup_coring, DRAW ) ;
					popup_update ( pup_bpss, DRAW ) ;
					popup_update ( pup_prefilter, DRAW ) ;
					chroma_trap = (int) ( signal == PUP_SVHS ) ;
					popup_update ( pup_trap, DRAW ) ;
					agc = GAINinit ;
					popup_update ( pup_agc, DRAW ) ;
					ObjectClearState ( tcdraw_tree, BU_SDEF, SELECTED ) ;
					ObjectDraw ( tcdraw_tree, BU_SDEF ) ;
					break ;
					
case BU_VAUTO:
					ObjectSetState ( tcdraw_tree, BU_VAUTO, SELECTED ) ;
					ObjectDraw ( tcdraw_tree, BU_VAUTO ) ;
					channel = PUP_AUTO ;
					signal = PUP_AUTO ;
					tv_standard = PUP_AUTO ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, 0 ) ;
					chk_set_chan_sig ( &channel, &signal, &chroma_trap ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					popup_update ( pup_channel, DRAW ) ;
					popup_update ( pup_signal, DRAW ) ;
					popup_update ( pup_trap, ( DRAW &
									( find_toolbox_entry ( IT_TVPAR ) >= 0 ) ) ) ;
					chk_set_std ( video_source, &tv_standard, &sensitivity ) ;
					senspoti_state ( tv_standard ) ;
					vdis_update_poti ( IT_TVPAR, &sens_poti ) ;
					popup_update ( pup_tvstand, DRAW ) ;
					ObjectClearState ( tcdraw_tree, BU_VAUTO, SELECTED ) ;
					ObjectDraw ( tcdraw_tree, BU_VAUTO ) ;
					break ;

case IC_MAT:	set_new_mode ( IC_FILTR ) ;
					ObjectSelect ( tcdraw_tree, IC_MAT ) ;
					filter_copy() ;
					release_button() ;
					ObjectNormal ( tcdraw_tree, IC_MAT ) ;
					break ;

case IC_CLIP :		do_clipping =  toggle_selection ( tcdraw_tree, IC_CLIP ) ;
					if ( do_clipping )
					{
						pts[X0] = pts[Y0] = - 1;
						if ( ! ( get_rectangle ( pts,  obj_info_text ( IC_CLIP )  ) & RIGHT_BUTTON )
						  &&   ( pts[X0] <= pts[X1] && pts[Y0] <= pts[Y1] ) ) 
						{
							SetRectangle ( clip_window, pts[X0]-tcdraw_work.x, pts[Y0]-tcdraw_work.y,
													pts[X1] - pts[X0] + 1, pts[Y1] - pts[Y0] + 1 ) ;
						}
						else	/* abort	*/
						{
							ObjectNormal ( tcdraw_tree, IC_CLIP ) ;
							do_clipping = FALSE ;
						}
					}
					break ;

POTI (PO_PATT):MouseOff();
					poti_click ( &pattern_poti, obj, mx ) ;
					MouseOn();
					break ;


case TX_GS:			if ( popup_menu ( pup_gs ) )
						set_new_mode ( IC_GRAY ) ;
					break ;
case TX_CSPAC:
					if ( popup_menu ( pup_cube_space ) )
						set_new_mode ( IC_CUBE ) ;
					break ;

case TX_BMODE:		popup_menu ( pup_blit_mode ) ;
					break ;

case TX_WMODE:		popup_menu ( pup_writing_mode ) ;
					break ;

POTI (PO_SENS):
					poti_click ( &sens_poti, obj, mx ) ;
 					set_sensitivity ( tv_standard, sensitivity ) ;
 					break ;

# ifdef PO_VFAC
POTI (PO_VFAC):
					poti_click ( &vfac_poti, obj, mx ) ;
					break ;
# endif

# ifdef PO_COUNT
POTI (PO_COUNT):	poti_click ( &frames_poti, obj, mx ) ;
					break ;
# endif

POTI (PO_CNDEM):	poti_click ( &demo_count_poti, obj, mx ) ;
					break ;

POTI (PO_ERDEM):	poti_click ( &demo_erase_poti, obj, mx ) ;
					break ;

POTI (PO_TRCOL):
					poti_click ( &transp_poti, obj, mx ) ;
					break ;

CASE_CLOSER :		switch_toolbox_off ( get_toolicn_from_closer ( obj ) ) ;
					release_button();
					break ;

CASE_TOOLS :		if ( ObjectSelected ( tcdraw_tree, obj ) )
						switch_toolbox_off ( obj ) ;
					else
						switch_toolbox_on ( obj ) ;
					release_button();
					break ;

case IC_RDEMO :		set_demo_mode ( obj, 3 ) ;
					break ;
case IC_LDEMO :		set_demo_mode ( obj, 1 ) ;
					break ;
case IC_CNDEM :		set_demo_mode ( obj, 2 ) ;
					break ;

case IC_BDEMO :		set_demo_mode ( obj, 4 ) ;
					break ;

case IC_PALDEMO :
case IC_SHOW :		DemoShow ( obj ) ;
					break ;

case IB_CUBE :
case IB_FRACT :
case IB_RBOW :	if ( ! chk_mat_graph() )
						break ;
					set_icn_mode ( obj - 1 ) ;
					break ;

CASE_IC_USEROBJ :
CASE_TC_MODES :		if ( ! chk_mat_graph() )
						break ;
CASE_GEN_MODES : 	set_icn_mode ( obj ) ;
					break ;

case BX_BICOL:	if ( keyboard_state ( K_ALT ) )
					{
						if ( chk_mat_graph() )
							pick_color () ;
						release_button();
					}
					else
					{
						popup_set_value ( pup_colors, curr_color, 0 ) ;
						if ( popup_menu ( pup_colors ) )
							change_vdi_color ( pup_color ) ;
					}
					break ;

case BX_LCOL:		set_new_mode ( IC_LINE ) ;
					if ( chk_mat_graph() )
						pick_rgb_color ( obj, curr_line_rgb ) ;
					release_button();
					break ;

case BX_TCOL:		set_new_mode ( IC_TEXT ) ;
					if ( chk_mat_graph() )
						pick_rgb_color ( obj, curr_text_rgb ) ;
					release_button();
					break ;

case BX_FCOL:if ( curr_mode != IC_FILL && curr_mode != IC_CIRCL )
						set_new_mode ( IC_FRECT ) ;
					if ( chk_mat_graph() )
						pick_rgb_color ( obj, curr_fill_rgb ) ;
					release_button();
					break ;

case TX_EFFCT:	if ( popup_menu ( pup_text_effects ) )
						set_new_mode ( IC_TEXT ) ;
					break ;

case TX_MAT:	if ( popup_menu ( pup_matrix ) )
						set_new_mode ( IC_FILTR ) ;
					break ;

# if EDIT_TEXT
case TX_INFO:		edit_text_line();
					break ;
# endif

case TX_GRAD:		popup_menu ( pup_mirror ) ;
					break ;

case TX_IMODE:		popup_menu ( pup_info_mode ) ;
					break ;

case TX_PFORM:		if ( popup_menu ( pup_pic_format ) && curr_mode != IC_STORE )
						set_new_mode ( IC_LOAD ) ;
					break ;

case BX_SAVE:		ObjectGetRectangle ( tcdraw_tree, BX_SAVE, save_box ) ;
					info_printf ( "Inhalt Kopierpuffer : %4d:%4d",
									saved_rect.w, saved_rect.h ) ;
					release_button();
					break ;

case BX_CANVS :		canvas_function ( pts ) ;
					break ;

/* ---- TV PAR ____ */

case TXT_VFAC :		if ( video.factor == 8 )
						video_size = VID_1_1 ;
					else
						video_size = VID_1_4 ;
					
					popup_menu ( pup_video_size ) ;
					video.factor = video_size == VID_1_1 ? 8 : 4 ;
# ifdef PO_VFAC
					vdis_update_poti ( IT_TVPAR, &vfac_poti ) ;
# endif
					break ;

case TX_CHAN :		popup_menu ( pup_channel ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, 0 ) ;
					chk_set_chan_sig ( &channel, &signal, &chroma_trap ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					popup_update ( pup_channel, DRAW ) ;
					popup_update ( pup_signal, DRAW ) ;
					popup_update ( pup_trap, ( DRAW &
									( find_toolbox_entry ( IT_TVPAR ) >= 0 ) ) ) ;
					chk_set_std ( video_source, &tv_standard, &sensitivity ) ;
					senspoti_state ( tv_standard ) ;
					vdis_update_poti ( IT_TVPAR, &sens_poti ) ;
					popup_update ( pup_tvstand, DRAW ) ;
					break ;
					
case TX_VSRC :
					popup_menu ( pup_vsource ) ;
					chk_set_std ( video_source, &tv_standard, &sensitivity ) ;
					senspoti_state ( tv_standard ) ;
					vdis_update_poti ( IT_TVPAR, &sens_poti ) ;
					break ;
					
case TX_TVSTD :
					popup_menu ( pup_tvstand ) ;
					chk_set_std ( video_source, &tv_standard, &sensitivity ) ;
					senspoti_state ( tv_standard ) ;
					vdis_update_poti ( IT_TVPAR, &sens_poti ) ;
					popup_update ( pup_tvstand, DRAW ) ;
					break ;

case TX_SIGT :
					popup_menu ( pup_signal ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, 0 ) ;
					chk_set_signal ( channel, &signal, &chroma_trap ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					popup_update ( pup_signal, DRAW ) ;
					popup_update ( pup_trap, ( DRAW &
									( find_toolbox_entry ( IT_TVPAR ) >= 0 ) ) ) ;
					break ;

case TX_DMODE :
					popup_menu ( pup_dmode ) ;
					if ( matbpp == 8 )
					{
						if ( display_mode == GREY_DISPLAY )
							initialise_palette ( matbpp, 256, PHYSgrayPalette ) ;
						else
							initialise_palette ( matbpp, 256, RGB332Palette ) ;
					}
					restart_video ();
					break ;
					
case TX_APER:		popup_menu ( pup_aperture ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					break ;

case TX_CORI:		popup_menu ( pup_coring ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					break ;
					
case TX_BPSS :		popup_menu ( pup_bpss ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					break ;

case TX_PREF:
					popup_menu ( pup_prefilter ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					break ;

case TX_CTRAP:
					popup_menu ( pup_trap ) ;
					set_lumi_cntrl ( aperture, coring, bpss, 
									 prefilter, chroma_trap ) ;
					break ;
					
case TX_AGC :		popup_menu ( pup_agc ) ;
					set_gain ( agc ) ;
					break ;


default :			release_button();
					break ;
		}

		if ( start_time == 0 )
			used_time = 0 ;
		else
			used_time = (end_time - start_time) * TIMEfac ;
		if ( used_time >= 10 /* msec */ )
			info_printf ( "Zeit : %ld msec", used_time ) ;

		MouseBase() ;

	}
	return ( FALSE ) ;
}


/*---------------------------------------------- tree_qdialog -----*/
int tree_qdialog ( OBJECT *dialtree, int editstart )
{
	RECTangle rect ;

	FormCenter(dialtree,rect);
	FormDialStart(rect);

	dialtree->ob_x += 1 ;
	dialtree->ob_y += 1 ;
	ObjectDraw(dialtree,0);	/* draw from TOP */

# if 0
	int ex_object ;
	ex_object = FormDo( dialtree, editstart ) ;
	dialtree[ex_object & 0x7FFF].ob_state &= ~ SELECTED ;

	FormDialFinish(rect);
	return(ex_object);
# else
editstart = editstart ;
	release_button() ;
	evnt_button ( 1, 1, 1, &dummy, &dummy, &dummy, &dummy ) ;
	release_button() ;
	
	FormDialFinish(rect);
	return 0 ;
# endif
}


# if USE_HELP
/*--------------------------------------------- help ------*/
void help ( int mx, int my )
{
	OBJECT *help_tree ;
	int	   sti ;
	
	if ( rsrc_gaddr ( R_TREE, TR_HELP, &help_tree ) != 0 )
	{
# if 0
		for ( sti = ST_HMIN ; sti <= ST_HMAX ; sti++ )
			strcpy ( help_tree[sti].ob_spec.free_string, "" ) ;

		strcpy ( help_tree[TXT_HELPHEAD].ob_spec.tedinfo->te_ptext, "Nicht aktiv" ) ;
# else
		for ( sti = ST_HMIN ; sti <= ST_HMAX ; sti++ )
			sprintf ( help_tree[sti].ob_spec.free_string, "# %2d", sti ) ;

		sprintf ( help_tree[TXT_HELPHEAD].ob_spec.tedinfo->te_ptext, "Maus bei %3d:%3d",
					mx, my ) ;
# endif

		
		tree_qdialog ( help_tree, NO_EDIT ) ;
	}
}
# endif

/*--------------------------------------------- keyboard_tcdraw ------*/
bool keyboard_tcdraw ( int keycode, int mx, int my )
{
# if ! USE_HELP
	NOwarning ( mx ) ;
	NOwarning ( my ) ;
# endif

# if EDIT_TEXT
	switch(keycode)
	{
case TABkey:	edit_text_line();
				break ;
# else
	int len ;
	char *s, c ;

	c = (char) keycode ;
	
	if ( c >= ' ' )						/* put char to curr_text	*/
	{
		len = (int)strlen ( curr_text ) ;
		if ( len < MAXtextSize )
		{
			s = curr_text + len ;
			*s++ = keycode ;
			*s++ = 0 ;
			info_printf ( "%s", curr_text ) ;
		}
	}
	else if ( c == ESC )	/* clear curr_text	*/	
	{
		curr_text[0] = 0 ;
		info_printf ( "%s", curr_text ) ;
	}
	else
	{
		switch(keycode)
		{
# if 0
case DELETE :	curr_text[0] = 0 ;				/* clear curr_text	*/	
				info_printf ( "" ) ;
				break ;
# endif

case BACKSPACE :
				len = (int)strlen ( curr_text ) ;
				if ( len > 0 )
				{
					curr_text[len-1] = 0 ;
					info_printf ( "%s", curr_text ) ;
				}
				break ;

# endif

# if TEST
case CNTRL_T :	tcdraw_test++ ;
				printf ( "test %d", tcdraw_test ) ;
				break ;
case CNTRL_U :	tcdraw_test-- ;
				printf ( "test %d", tcdraw_test ) ;
				break ;
# endif


case CNTRL_H :	info_printf ( "CFG : W=%c R={%4d,%4d,%4d,%4d}",
								configuration.in_window,
								configuration.work.x,
								configuration.work.y,
								configuration.work.w,
								configuration.work.h
								) ;
				break ;

case CNTRL_M :	configuration.menu = '1' ;
				show_menu() ;
				break ;

case CNTRL_N :	configuration.menu = '0' ;
				hide_menu() ;
				break ;

case CNTRL_P :	update_and_save_config () ;
  				break ;

case CNTRL_R :	load_and_set_config () ;
  				break ;

case ALT_O :	switch_video ( IC_VSWI ) ;
				break ;

case RETURN :
case ENTER :
# if 0
				{
					int i, pts[4] ;
					char *ss, *es ;
					
					ss = curr_text ;
					for ( i = 0 ; i < 4 ; i++ )
					{
						pts[i] = (int)strtol ( ss, &es, 0 ) ;
						if ( es == ss )
						{
							info_printf ( "* Syntaxfehler in : %s", curr_text ) ;
							return ( TRUE ) ;
						}
						ss = es ;
						if ( *ss == ',' )
							ss++ ;
					}
					exec_command ( pts ) ;
				}
# else
				MouseOff();
				if ( *curr_text != 0 )
					cli_line ( curr_text ) ;
				MouseOn();
# endif
				break ;
					

case ALT_M :	if ( chk_mat_graph() ) set_icn_mode ( IC_MIRR ) ;	break ;
case ALT_P :	if ( chk_mat_graph() ) set_icn_mode ( IC_PSIM ) ;	break ;
case ALT_U :	if ( chk_mat_graph() ) set_icn_mode ( IC_CUBE ) ;		break ;
case ALT_L :	set_icn_mode ( IC_LINE ) ;		break ;
case ALT_C :	set_icn_mode ( IC_COPY ) ;		break ;
case ALT_F :	set_icn_mode ( IC_FILL ) ;		break ;
case ALT_T :	set_icn_mode ( IC_TEXT ) ;		break ;
case ALT_B :	set_icn_mode ( IC_FRECT ) ;	break ;
case ALT_R :	set_icn_mode ( IC_RECT ) ;		break ;
case ALT_Z :	if ( chk_mat_graph() ) set_icn_mode ( IC_LUPE ) ;		break ;

# if USE_HELP
case HELP :		help ( mx, my ) ;				break ;
# endif

case F1 :		switch_toolbox ( NOicon ) ;				break ;
case SHFT_F1 :	switch_toolbox ( IT_HELP ) ;		break ;
case F2 :		switch_toolbox ( IT_GNRAL ) ;	break ;
case F3 :		switch_toolbox ( IT_PALET ) ;		break ;
case F4 :		switch_toolbox ( IT_VDI ) ;		break ;
case F5 :		switch_toolbox ( IT_FILTR ) ;	break ;
case SHFT_F5 :	switch_toolbox ( IT_HISTO ) ;		break ;
case F6 :		switch_toolbox ( IT_RUNS ) ;		break ;
case F7 :		switch_toolbox ( IT_COPY ) ;		break ;
case SHFT_F7 :	switch_toolbox ( IT_WIND ) ;	break ;
case F8 :		switch_toolbox ( IT_DEMO ) ;		break ;
case F9 :		switch_toolbox ( IT_VIDEO ) ;		break ;
case SHFT_F9 :	switch_toolbox ( IT_TVPAR ) ;	break ;
case F10 :		switch_toolbox ( IT_DISK ) ;		break ;

# if 0
	case IC_FRUN :		no key defined for these functions
	case IC_MRUN :
	case IC_CRUN :
	case IC_RBOW :
	case IC_BRIGH :
# endif

case CNTRL_C :	switch_toolbox_off ( get_last_toolbox() ) ;			break ;
case CNTRL_L :	if ( chk_mat_graph() ) set_icn_mode ( IC_LOAD ) ;	break ;
case CNTRL_S :	if ( chk_mat_graph() ) set_icn_mode ( IC_STORE ) ;	break ;
case CNTRL_Q :	term_windows();
				return ( TRUE ) ;

case ALT_0 :	change_vdi_color ( 0 ) ;
				break ;
	
case ALT_1 :
case ALT_2 :
case ALT_3 :
case ALT_4 :
case ALT_5 :
case ALT_6 :
case ALT_7 :
case ALT_8 :
case ALT_9 :	change_vdi_color ( ( (keycode-ALT_1) >> 8 ) + 1 ) ;
				break ;

case UNDO	 :	break ;
# if ! EDIT_TEXT
		}
# endif
	}
	return ( TRUE ) ;
}


MOUSEevent mous_evt[2] =
{
	{ 0, { THIN_CROSS, ARROW } },
	{ 0, { POINT_HAND, ARROW } }
} ;


/*---------------------------------------- close_tcdraw_window ----------*/
void close_tcdraw_window ( void )
{
	if ( video_on )
		digitiser_stop() ;
}


/*------------------------------------------------- tcdraw_loop ------*/
void tcdraw_loop(void)
{
	POINT	  mouse ;
	int	  	  event,
			  buffer[8],
			  keycode,
			  button,
			  windhand,
			  windtop ;
	bool  	  quit ;

	quit = FALSE ;
	while(!quit)
	{
# if TEST
		printf ( "* tcdraw_loop : %d *", test_count++ ) ;
# endif
		windhand = window_handle ( tc_draw_window ) ;
		WindGetWork ( windhand, tcdraw_work ) ;
		ObjectGetRectangle ( tcdraw_tree, BX_CANVS, canvas ) ;
		WindGetTop ( windtop ) ;
		event = evnt_multi (
# if 0
				MU_M1 | MU_M2 | MU_MESAG | MU_BUTTON | MU_KEYBD | MU_TIMER,
# else	/* kein WM_UNTOP ???	*/
				windhand == windtop
					? ( MU_MESAG | MU_BUTTON | MU_KEYBD | MU_TIMER )
					: MU_MESAG,
# endif
         		1,1,1,       	      	/* left button, single click */
 				mous_evt[0].state,	VALrect(canvas),
 				mous_evt[1].state,	VALrect(canvas),
 		   		buffer,
 		   		MESG_CYCLE,0,                	/* timer */    
 		    	&mouse.x,&mouse.y,&button,&dummy,&keycode,&dummy);

		ClippingOff ( vdi_handle ) ;

# if WINDOW_SIZING
		ClippingOn ( vdi_handle, tcdraw_work ) ;
# endif		
		WindUpdateBegin();

		if(event & MU_MESAG)	quit = message_event ( buffer ) ;
		if(event & MU_M1)		mouse_event ( &mous_evt[0] ) ;
		if(event & MU_M2)		mouse_event ( &mous_evt[1] ) ;
# if RELEASE_TEST
		if(event & MU_BUTTON)
		{
			if ( ( button & LEFT_BUTTON ) != 0
					&& ( ! relbut || ( get_ticks() - last_but_time ) > 200/TIMEfac ) )
			{
				quit = button_tcdraw ( mouse.x, mouse.y, button ) ;
				last_but_time = get_ticks() ;
			}
		}
# else
# if CLICK_TEST
		test_count++ ;
		printf ( "\033Y%c%c%4d %c %02x    ",
					 ' ' + 8 + (test_count/8 & 15),
					 ' ' + (test_count%8)* 8,
					test_count, event & MU_BUTTON ? '*' : ' ', button ) ;
		if(event & MU_BUTTON)	quit = button_tcdraw ( mouse.x, mouse.y, button ) ;
# else
		if(event & MU_BUTTON)
		{
			quit = button_tcdraw ( mouse.x, mouse.y, button ) ;
			event = evnt_multi (	/* eat double clicks	*/
				MU_BUTTON | MU_TIMER,
				1,1,1,       	      	/* left button, single click */
 				mous_evt[0].state,	VALrect(canvas),
 				mous_evt[1].state,	VALrect(canvas),
 		   		buffer,
 		   		MESG_CYCLE,0,                	/* timer */    
 		    	&mouse.x,&mouse.y,&button,&dummy,&keycode,&dummy ) ;
		}
# endif
# endif
		if(event & MU_KEYBD)	quit = keyboard_tcdraw ( keycode, mouse.x, mouse.y ) ;
		if(event & MU_TIMER)	timer_tcdraw ( mouse.x, mouse.y ) ;

		WindUpdateEnd();
	
# if WINDOW_SIZING
		ClippingOff ( vdi_handle ) ;
# endif		
	}
}

# define OBJECTborder 4

/*---------------------------------------- calc_obj_sizes ----------*/
void calc_obj_sizes ( RECTangle *work )
{
	OBJECT 	*canvobj, *info ;
	
	canvobj	  = &tcdraw_tree[BX_CANVS] ;
	info	  = &tcdraw_tree[TX_INFO] ;

	canvobj->ob_height = work->h ;
	canvobj->ob_width  = work->w ;

	if ( ( info->ob_flags & HIDETREE ) == 0 )
	{
		info->ob_width = work->w - 2 * OBJECTborder ;
		canvobj->ob_height -= canvobj->ob_y + OBJECTborder ;
		canvobj->ob_width  -= 2 * OBJECTborder ;
	}
}

/*---------------------------------------- size_tcdraw_window ----------*/
void size_tcdraw_window ( RECTangle *old, RECTangle *new, unsigned changes )
{
	old = old ;
	if ( changes & WINDOWsized )
		calc_obj_sizes ( new ) ;
}



/*---------------------------------------- open_tcdraw_window ------*/
bool open_tcdraw_window ( int argc, char *argv[] )
{
	OBJECT *box, *canvobj, *info ;

	RECTangle outside, work ;
	int elements ;
	unsigned flags ;

# if TEST
	tprintf ( "+ open_tcdraw_window\n" ) ;
# endif
	
	NOwarning ( argc ) ;
	NOwarning ( argv ) ;

	if ( rsrc_gaddr ( R_TREE, TR_DRWIN, &tcdraw_tree ) != 0 )
	{
		init_colors() ;
		
		with_outlines = ObjectSelected ( tcdraw_tree, IC_OLINE )
							|| program_level[0] != '7' ;

		o_printf ( tcdraw_tree, ST_X,	"X : %4d",  	screen_size.x ) ;
		o_printf ( tcdraw_tree, ST_Y,	"Y : %4d",  	screen_size.y ) ;
		o_printf ( tcdraw_tree, ST_BPP, "Planes : %2d", bit_planes ) ;

		setup_poti ( &outline_poti, tcdraw_tree, -1 ) ;

		snap_grid = ObjectSelected ( tcdraw_tree, IC_GRID ) ;
		setup_poti ( &x_grid_poti, tcdraw_tree, -1 ) ;
		setup_poti ( &y_grid_poti, tcdraw_tree, -1 ) ;

		puzzle_mode = ObjectSelected ( tcdraw_tree, IC_PUZZL ) ;
# if 0
		zoom_active = ObjectSelected ( tcdraw_tree, IC_ZOOM ) ;
# endif
		set_fill_pattern();
		setup_poti ( &pattern_poti, tcdraw_tree, -1 ) ;

		pup_cube_space = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_CSPAC,
					 TR_POPUP, PU_CSPAC,
					 &color_space, RGBspace, NULL ) ;
		pup_blit_mode = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_BMODE,
					 TR_POPUP, PU_BMODE,
					 &blit_mode, ALL_WHITE, NULL ) ;
		popup_set_dimension ( pup_blit_mode, 16 /* (MAXblitOP+1)/2 */ , 2 ) ;
		pup_writing_mode = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_WMODE,
					 TR_POPUP, PU_WMODE,
					 &writing_mode, MD_REPLACE, NULL ) ;
# if RSC_TEST
		{
			OBJECT *puptre ;
			
			if ( rsrc_gaddr ( R_TREE, TR_POPUP, &puptre ) != 0 )
			{
				object_info ( puptre, PU_MIRR,  "PU_MIRR" ) ;
				object_info ( puptre, PM_POINT, "PM_POINT" ) ;
			}
			else
				printf ( "* error : rsrc_gaddr TR_POPUP\n" ) ;
			object_info ( tcdraw_tree, TX_GRAD, "TX_GRAD" ) ;
			getchar();
		}
# endif
		pup_mirror = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_GRAD,
					 TR_POPUP, PU_MIRR,
					 &mirr_mode, MIR_POINT, NULL ) ;
		pup_pic_format = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_PFORM,
					 TR_POPUP, PU_DUMMY,
					 &pic_format, 0, txttab_pic_format ) ;
		pup_info_mode = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_IMODE,
					 TR_POPUP, PU_IMODE,
					 &info_mode, INFO_OFF, NULL ) ;
		pup_matrix = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_MAT,
					 TR_POPUP, PU_MAT,
					 &selected_matrix, 0, NULL ) ;
		pup_gs = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_GS,
					 TR_POPUP, PU_GS,
					 &gray_mode, 0, NULL ) ;

		pup_text_effects = popup_create ( SELECTmultiple,
					 tcdraw_tree, TX_EFFCT,
					 TR_POPUP, PU_EFFCT,
					 &text_effects, 0, NULL ) ;

		pup_colors = popup_create ( SELECTsingle,
					 tcdraw_tree, BX_BICOL,
					 TR_POPUP, PU_COLRS,
					 &pup_color, 0, NULL ) ;

/* ------ VIDEO PAR ------ */
		lumi_cntrl_init ( &aperture, &coring, &bpss, 
						  &prefilter, &chroma_trap ) ;
		/* or use "popup_set_value" ????? */

		pup_video_size = popup_create ( SELECTsingle,
					 tcdraw_tree, TXT_VFAC,
					 TR_POPUP, PU_VIDSIZE,
					 &video_size, VID_1_1, NULL ) ;
		pup_coring = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_CORI,
					 TR_POPUP, PU_CORI,
					 &coring, 0, NULL ) ;
		pup_agc = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_AGC,
					 TR_POPUP, PU_AGC,
					 &agc, 0, NULL ) ;
		pup_channel = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_CHAN,
					 TR_POPUP, PU_CHAN,
					 &channel, 0, NULL ) ;
		pup_vsource = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_VSRC,
					 TR_POPUP, PU_VSRC,
					 &video_source, 0, NULL ) ;
		pup_tvstand = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_TVSTD,
					 TR_POPUP, PU_TVSTD,
					 &tv_standard, 0, NULL ) ;
		pup_signal = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_SIGT,
					 TR_POPUP, PU_SIGT,
					 &signal, 0, NULL ) ;
		pup_dmode = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_DMODE,
					 TR_POPUP, PU_DMODE,
					 &display_mode, 0, NULL ) ;
		pup_bpss = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_BPSS,
					 TR_POPUP, PU_BPSS,
					 &bpss, 0, NULL ) ;
		pup_aperture = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_APER,
					 TR_POPUP, PU_APER,
					 &aperture, 0, NULL ) ;
		pup_trap = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_CTRAP,
					 TR_POPUP, PU_CTRAP,
					 &chroma_trap, 0, NULL ) ;
		pup_prefilter = popup_create ( SELECTsingle,
					 tcdraw_tree, TX_PREF,
					 TR_POPUP, PU_PREF,
					 &prefilter, 0, NULL ) ;

		if ( ! is_mattc )
		{
 			tcdraw_tree[BX_LCOL].ob_flags |= HIDETREE ;
 			tcdraw_tree[BX_TCOL].ob_flags |= HIDETREE ;
 			tcdraw_tree[BX_FCOL].ob_flags |= HIDETREE ;
 		}

# ifdef BU_WGRAB
		with_grab = ObjectSelected ( tcdraw_tree, BU_WGRAB ) ;
# else
		with_grab = TRUE ;
# endif
		setup_poti ( &sens_poti,		tcdraw_tree, -1 ) ;
# ifdef PO_VFAC
		setup_poti ( &vfac_poti,		tcdraw_tree, -1 ) ;
# endif
# ifdef PO_COUNT
		setup_poti ( &frames_poti,		tcdraw_tree, -1 ) ;
# endif
		setup_poti ( &demo_count_poti,	tcdraw_tree, -1 ) ;
		setup_poti ( &demo_erase_poti,	tcdraw_tree, -1 ) ;
		setup_poti ( &transp_poti,	 	tcdraw_tree, -1 ) ;

# ifdef VA_MAOFS
		init_user_filter ( M00, VA_MAOFS, VA_MASCA ) ;
# endif
		curr_color = last_color = 1 ;
		curr_mode = -1 ;

		init_user_objects ( ) ;

		/* calculate object sizes	*/

		tcdraw_tree[BX_SAVE].ob_width  &= ~ 3 ;	/* w/h * 4 !	*/
		tcdraw_tree[BX_SAVE].ob_height &= ~ 3 ;
			
        box	      = &tcdraw_tree[BX_DRWIN] ;
		canvobj	  = &tcdraw_tree[BX_CANVS] ;
		info	  = &tcdraw_tree[TX_INFO] ;

		info->ob_spec.tedinfo->te_ptext  = tcdraw_info ;
		info->ob_spec.tedinfo->te_txtlen = MAXinfoLength ;

		WindGetWork ( DESK_TOP, outside ) ;

# if 1
		if ( ! init_redraw_buffer ( screen_size.x, screen_size.y ) )
# elif 0
		if ( ! init_redraw_buffer ( outside.w, outside.h ) )
# else
?? move down ???
		if ( ! init_redraw_buffer ( work.w, work.h ) )
# endif
		{
			printf ( "*** no redraw buffer[%d:%d], press RETURN !\n",
							 screen_size.x, screen_size.y ) ;
			getchar() ;
		}

		info->ob_x     = OBJECTborder ;
		info->ob_y     = OBJECTborder ;

		/* configuration setup	*/
		
		if ( *configuration.picpath != 0 )
			strncpy ( pic_path, configuration.picpath, STPATHLEN ) ;

		if ( configuration.menu != '0' )
			show_menu() ;

		if ( configuration.in_window == '?' )
			configuration.in_window = keyboard_state ( K_LSHIFT )
										? '1' : '0' ;
		switch ( configuration.in_window )
		{
 case '1' :	elements =  DRAWwindElements ;
			flags	 =  NOwhLimit ;
			canvobj->ob_x  = OBJECTborder ;
			canvobj->ob_y  = info->ob_height + 2 * OBJECTborder ;

			if ( configuration.work.w == 0
					|| configuration.work.h == 0 )
			{
# if TEST
				tprintf ( "  w=h=0" ) ;
# endif
				outside.x = 0 ;
				outside.y = 0 ;
				outside.w -= 2*WINDborder ;
				outside.h -= 2*WINDborder ;
			}
			else
			{
				int maxx, maxy ;

				outside.x = configuration.work.x ;
				outside.y = configuration.work.y ;
				outside.w = configuration.work.w ;
				outside.h = configuration.work.h ;
				maxx = scr_max_x - 2 * WINDborder ;
				maxy = scr_max_y - 2 * WINDborder ;
				if ( outside.x > maxx )	outside.x = maxx ;
				if ( outside.y > maxy )	outside.y = maxy ;
			}
			break ;

 case 'F' :	elements = 0 ;
 			flags	 =  NOwhLimit | FULLscreen ;

			canvobj->ob_x = 0 ;
 			canvobj->ob_y = 0 ;
 			canvobj->ob_type = G_IBOX ;
 			canvobj->ob_spec.obspec.framesize = 0 ;
 			
 			tcdraw_tree[TX_INFO].ob_flags |= HIDETREE ;
			break ;

 default :	elements =  0 ;	/* '0'	*/
 			flags	 =  NOwhLimit | FULLwindow ;

			canvobj->ob_x  = OBJECTborder ;
			canvobj->ob_y  = info->ob_height + 2 * OBJECTborder ;

			break ;
		}
# if TEST
		tprintf ( "* 5 *" ) ;
# endif

		WindCalc ( WC_WORK, elements, outside, work ) ;

		if ( outside.y == 0 )
		{
			box->ob_x = box->ob_y = 0 ;	/* force center	*/
		}
		else
		{
			box->ob_x = work.x ;
			box->ob_y = work.y ;
		}
		box->ob_width  = work.w ;
		box->ob_height = work.h ;

		calc_obj_sizes ( &work ) ;

		init_toolbox ( tcdraw_tree, *program_level & 0x0007,
					   BX_CANVS, &tc_draw_window ) ;

		popup_object_change ( pup_signal, POB_BAS, DISABLED, 0 ) ;

		if ( ! tcbpp ( &matbpp ) ) 
		{	/* Colour display of video window not allowed */	
			popup_object_change ( pup_dmode, POB_COL, DISABLED, 0 ) ;
			popup_set_value ( pup_dmode, GREY_DISPLAY, (int)NO_DRAW ) ; 
		}

		if ( digi_init () )
		{
			madi_ok = TRUE ;

			if ( i2c_init () )
				csc_vlut_init () ;

			auto_chk_video ( FALSE ) ;
	
			if ( matbpp == 8 )
			{
				if ( display_mode == GREY_DISPLAY )
					initialise_palette ( matbpp, 256, PHYSgrayPalette ) ;
				else
					initialise_palette ( matbpp, 256, RGB332Palette ) ;
			}
		}
		else if ( configuration.test == 0 )
		{
			toolbox_disable ( get_toolbox ( IT_VIDEO ) ) ;
			toolbox_disable ( get_toolbox ( IT_TVPAR ) ) ;
		}

# if TEST
		tprintf ( "> open_otree_window\n" ) ;
# endif
		if ( open_object_tree_window( &tc_draw_window,
								 flags, elements,
								  tcdraw_tree, tcdraw_title, 
									redraw_tcdraw, tcdraw_loop ) )
		{
# if TEST
			tprintf2 ( "  window handle = %d\n",  window_handle ( tc_draw_window ) ) ;
# endif
			set_size_fct ( tc_draw_window, size_tcdraw_window ) ;
			set_menu_fct ( tc_draw_window, menu_tcdraw ) ;
			set_close_fct ( tc_draw_window, close_tcdraw_window ) ;
# if 0
			WindGetWork ( window_handle ( tc_draw_window ), tcdraw_work ) ;
			ObjectGetRectangle ( tcdraw_tree, BX_CANVS, canvas ) ;
# endif
# if TEST
			tprintf ( "- open_tcdraw_window, ok\n" ) ;
# endif
			return ( TRUE ) ;
		}
	}
# if TEST
	tprintf ( "- open_tcdraw_window, bad\n" ) ;
# endif
	return ( FALSE ) ;
}


/*-------------------------------------------------- activate_tcdraw_window --*/
bool activate_tcdraw_window(void)
{
# if TEST
	tprintf ( "= activate_tcdraw_window" ) ;
# endif
	if( keyboard_state ( K_ALT ) )
		close_all_but ( tc_draw_window ) ;
	if( tc_draw_window != NULL )
	{
# if TEST
		tprintf ( ", set top\n" ) ;
# endif
		WindSetTop ( window_handle ( tc_draw_window ) ) ;
		return ( TRUE ) ;
	}
	else
	{
# if TEST
		tprintf ( ", open window\n" ) ;
# endif
		return ( open_tcdraw_window ( 0, NULL ) ) ;
	}
}


/*------------------------------------------- init_tcdraw ----------*/
bool init_tcdraw ( void )
# define _sysbase 0x4F2L
{
# if TEST
	tprintf ( "+ init_tcdraw\n" ) ;
# endif
	syshead = (SYSHDR *) get_lcont ( (long *)_sysbase ) ;
	keyshift = (byte *)syshead->kbshift ;

	uprintf = info_printf ;
	init_draw_cli();
	
	init_rainbow() ;
	init_bright() ;
	init_filters() ;	

	linea_init();

	screen_address = Logbase();
	bytes_per_line = Linea->v_lin_wr ;

	is_mattc = bit_planes > 8 ;
	
	tc_draw_window = NULL ;
	
	load_config ( DEFAULTcfg ) ;

# if TEST
	tprintf ( "- init_tcdraw, ok\n" ) ;
# endif
	return ( TRUE ) ;
}

/*------------------------------------------- term_tcdraw ----------*/
void term_tcdraw ( void )
{
	close_tcdraw_window();
	hide_menu();
	term_redraw_buffer() ;
}


