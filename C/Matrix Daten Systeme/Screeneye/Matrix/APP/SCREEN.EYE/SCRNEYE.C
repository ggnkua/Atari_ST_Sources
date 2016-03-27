/* scrneye.prg / 15.1..93 / 0.2 / WA	*/

# define TESTfileSelector	0

# define INFORMATION 0
# define FASTgrey	1

# define RSC_NAME "SCRN_EYE.RSC"

# include <stdlib.h>
# include <ctype.h>
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
# include <error.h>
# include <fast.h>

# include <picfiles.h>

# if 1
# include "\pc\app\matdigi.f\digiblit.h"
# include "\pc\app\matdigi.f\film.h"
# include "\pc\app\matdigi.f\digitise.h"
# include "\pc\app\matdigi.f\mdf_lca.h"

# include "\pc\app\matdigi.f\screyeif.h"
# include "\pc\app\matdigi.f\scryiacc.h"
# else
# include "\pc\app\matdigif\digiblit.h"
# include "\pc\app\matdigif\mdf_if.h"
# include "\pc\app\matdigif\mdf_lca.h"
# include "\pc\app\matdigif\initdmsd.h"
# include "\pc\app\matdigif\i2c_hdg.h"
# include "\pc\app\matdigif\digitise.h"
# include "\pc\app\matdigif\film.h"
# endif

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\dialog.h"

# include "picture.h"
# include "scrn_eye.h"
# include "sound.h"
# include "menus.h"

# include "tool_bar.h"
# include "digiwind.h"
# include "palette.h"

# include "scrneye.h"

# define DEFsource	1

# define MIN_DELAY	   1		/* ms */
# define BACK_DELAY	 100	 	/* ms */
# define TOP_DELAY	   0	 	/* ms */
# define INIT_DELAY  750		/* ms */
# define NOMD_DELAY 1000	    /* ms */

# define MAXvdiLevel 1000

# define FASTsteps	4

# if DEBUG
int  Debug = 0 ;
# endif

int  MouseCount = 1 ;	/* 0 == aus, 1,.. = an	*/
bool Paused = FALSE ;
bool Fast  = FALSE ;
bool SoundOn = FALSE ;
bool LastDisplaySequenceOn = FALSE ;

int  Volume	= 00 ;	/* 0-0 .. 7-7 : gain 0-14, att 14..0	*/ 
int  ZoomXY ;

int  Step = +1 ;

int border_left ;
int realtime_tail_y ;

char 	CurrentFilmName[8] = "test" ;
char 	BaseName[128] ;
uword	SequenceFileFormat = DEFformat ;

TImageWindow DigitizerImage ;

TBlitWindow FullFrameBuffer,	/* background buffer for full image			*/
			FullImageBuffer,	/* buffer for full image = odd + even field	*/
			LiveImageBuffer ;	/* buffer for live video outside 
								   full screen mode */

void *ScreenBuffer 	  = NULL ;
long ScreenBufferSize = 0 ;
bool FileSelectorRedrawDone = FALSE ;

# if FASTgrey
int FirstPaletteIndex[] = 	{		 0,         0,        			CLUTgrey7Base } ;
int LastPaletteIndex[] = 	{	   255,         255,				CLUTgrey7Base+127 } ;
int *(ClutTable[]) = 	  	{ clut_332, 		clut_yc224, 		clut_grey7 } ;
TDigitiserMode DigiMode[] = { DIGcolor, 	 	DIGyc,   			DIGgrey8 } ;
# else
int FirstPaletteIndex[] = 	{		 0,          0,        			16 } ;
int LastPaletteIndex[] = 	{	   255,         255,        		255 } ;
int *(ClutTable[]) = 	  	{ clut_332, 		clut_yc224, 		clut_grey } ;
TDigitiserMode DigiMode[] = { DIGcolor, 	 	DIGyc,     			DIGyc } ;
# endif

TBlitProcedure *(BlitProc[3]) ;

TPaletteDisplayMode PaletteDisplayMode 	= PALrgb ;
TRunMode 			RunMode  			= IDLE ;
unsigned			VideoStandard 		= PUP_PAL ;


POINT       FullZoom = { 1, 1 } ;

# define mouse_arrow()		graf_mouse ( ARROW, (MFORM *)0 )
# define mouse_busy()		graf_mouse ( BUSYBEE, (MFORM *)0 )
# define mouse_point_hand()	graf_mouse ( POINT_HAND, (MFORM *)0 )
# define mouse_flat_hand()	graf_mouse ( FLAT_HAND, (MFORM *)0 )

/*--------------------------------------- InitBlitProcTable -------*/
void InitBlitProcTable ( void )
{
	BlitProc[PALrgb] =	ScreenEyeParameter->_BlitF332Window ;
	BlitProc[PALyuv] =	ScreenEyeParameter->_BlitFyc224Window ;
# if FASTgrey
	BlitProc[PALgrey] =	ScreenEyeParameter->_BlitP8ColorWindow ;
# else
	BlitProc[PALgrey] =	ScreenEyeParameter->_BlitF8GreyWindow ;
# endif
}

/* ---------------------------------------------- UpdatePalette ---- */
void UpdatePalette ( void )
{
	if ( bit_planes < 16 )
	{
		set_vdi_palette ( 0, 15, save_clut ) ;
		set_phys_palette ( FirstPaletteIndex[PaletteDisplayMode],
								LastPaletteIndex[PaletteDisplayMode],
									ClutTable[PaletteDisplayMode] ) ;
	}
}

/* ---------------------------------------------- RestorePalette ---- */
void RestorePalette ( void )
{
	if ( bit_planes < 16 )
		set_vdi_palette ( 0, 255, save_clut ) ;
}


/* ---------------------------------------------- set_film_name ---- */
void set_film_name ( char *fnam )
{
	strcpy ( ToolsTree[TX_NAME].ob_spec.tedinfo->te_ptext, fnam ) ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, TX_NAME ) ;
}



char PurePath[80] = "" ;
char LastPath[80] = "C:\\*.*" ;
char LastSel[12]  = "" ;

/* -------------------------------------------------- extract_path ------ */
char *extract_path ( char *path )
{
	char *s, *lastslash ;
	
	for ( lastslash	= NULL, s = path; *s != 0; s++ )
		if ( *s == '\\' )
			lastslash = s ;
	if ( lastslash != NULL )
		*(lastslash+1) = 0 ;

	return path ;
} 

/* ------------------------------------------------- file_selector ------ */
bool file_selector ( char *inpath, char *insel, char *title )
{
    int  exbutton, result ;

# if TESTfileSelector
printf ( "\033H"
		 "titl = %s\n", title ) ;
printf ( "+pat = %s\n", inpath ) ;
printf ( "+sel = %s\n", insel ) ;
# endif TESTfileSelector
	if ( ScreenBuffer != NULL )
		memcpy ( ScreenBuffer, Logbase(), ScreenBufferSize ) ;
	mouse_arrow();
	mouse_on();
	result = fsel_exinput ( inpath, insel, &exbutton, title ) ;
	mouse_off();
	if ( ScreenBuffer != NULL )
	{
		memcpy ( Logbase(), ScreenBuffer, ScreenBufferSize ) ;
		FileSelectorRedrawDone = TRUE ;
	}
# if TESTfileSelector
printf ( "-pat = %s\n", inpath ) ;
printf ( "-sel = %s\n", insel ) ;
# endif TESTfileSelector
	if ( result )
 	{
 		if ( exbutton )
 			return TRUE ;
 		else
 			WindowMessage ( "* Abbruch !" ) ;
 	}
	return FALSE ;
}

# define strequ(a,b) (strcmp(a,b)==0)

/* ------------------------------------------------- get_pic_file_name -- */
bool get_pic_file_name ( char *basename, char *pattern, uword *filtyp, char *title )
{
	char *ext ;

	if ( pattern != NULL )
		strcat ( extract_path ( LastPath ), pattern ) ;
	
	if ( file_selector ( LastPath, LastSel, title ) )
	{
		if ( ( ext = strchr ( LastSel, '.' ) ) != NULL )
		{
			ext++ ;
			if ( strequ ( ext, "TIF" ) )
				*filtyp = TIFformat ;
			else if ( strequ ( ext, "TIC" ) )
				*filtyp = TICformat ;
			else if ( strequ ( ext, "TGA" ) )
				*filtyp = TGAformat ;
			else if ( strequ ( ext, "JPG" ) )
				*filtyp = JPGformat ;
			else if ( strequ ( ext, "FLM" ) )
				*filtyp = BLKformat ;
			else 
			{
				WindowMessage ( "* Falscher Dateityp : %s", ext ) ;
				return FALSE ;
			}

			extract_path ( strcpy ( PurePath, LastPath ) ) ;

# if TESTfileSelector
printf ( "ftyp = %c\n", (char)*filtyp ) ;
printf ( "last = %s\n", LastPath ) ;
printf ( "pure = %s\n", PurePath ) ;
# endif TESTfileSelector

			if ( basename != NULL )
			{
				*(ext-1) = 0 ;	/* temp disable extension */
				sprintf ( CurrentFilmName, "%.4s", LastSel ) ;
				set_film_name ( CurrentFilmName ) ;
				sprintf ( basename, "%s%s", PurePath, CurrentFilmName ) ;
# if TESTfileSelector
printf ( "base = %s\n", basename ) ;
# endif TESTfileSelector
				*(ext-1) = '.' ;	/* enable extension */
			}
 			return TRUE ;
		}
		else
		{
			WindowMessage ( "* Kein Dateityp .xxx" ) ;
		}
 	}
	return FALSE ;
}


/* ------------------------------------------------- aes_delay ------- */
void aes_delay ( int ms )
{
	evnt_timer ( ms, 0 ) ;
}

/* ------------------------------------------------- SquareRoot ------- */
int SquareRoot ( int i )
/* return n with i <= n*n		*/
/* (a+1)^2 = a^1 + 2a + 1		*/
{
	int n ;

	for ( n = 0; n < 128; n++ )
		if ( i <= n*n )
			break ;
	return n ;
}

/*---------------------------------------- mouse_on -------------*/
void mouse_on ( void )
{
	if ( MouseCount++ == 0 )
		graf_mouse ( M_ON, (MFORM *)0 ) ;
}


/*---------------------------------------- mouse_off -------------*/
void mouse_off ( void )
{
	if ( --MouseCount == 0 )
		graf_mouse ( M_OFF, (MFORM *)0 ) ;
}



/* ----------------------------------------- PointInsideRectangle ------- */
bool PointInsideRectangle ( int x, int y, TRectangle *rect )
{
	return x >= rect->x && x < rect->x + rect->w
		&& y >= rect->y && y < rect->y + rect->h ;
}



extern 		int _app;

int    		phys_handle, vdi_handle ;
int	   		hwchar, hhchar, hwbox, hhbox ;
int			x_page, y_page ;

int    		appl_id = -1, menu_id = -1, dummy ;

int      	colours ;
int 		old_msg = 0;

bool		acc_opened = FALSE ;


SEQUENCE 	Sequence ;

# define _vq_mouse(h,pb,px,py) evnt_button ( 0, 0, 0, px, py, pb, &dummy )


/*----------------------------------------------- WaitForClick ---*/
int WaitForClick ( void )
{
	int buttons ;

	for(;;)
	{
		_vq_mouse ( vdi_handle, &buttons, &dummy, &dummy ) ;
		if ( buttons != 0 )
			return buttons ;
		aes_delay ( 50 ) ;
	}
}

/*----------------------------------------------- ReleasePosition ---*/
void ReleasePosition ( int *x, int *y )
{
	int buttons ;

	for(;;)
	{
		_vq_mouse ( vdi_handle, &buttons, x, y ) ;
		if ( buttons == 0 )
			return ;
		aes_delay ( 50 ) ;
	}
}


/*----------------------------------------------- DrawBox ---*/
void DrawBox ( TRectangle *rect, int color )
{
	int pxy[4] ;
	
	pxy[0] = rect->x ;
	pxy[1] = rect->y ;
	pxy[2] = rect->x + rect->w - 1  ;
	pxy[3] = rect->y + rect->h - 1  ;
	
	vswr_mode ( vdi_handle, MD_REPLACE ) ;
	vsf_color ( vdi_handle, color ) ;
	vsf_interior ( vdi_handle, FIS_SOLID ) ;
	
	v_bar( vdi_handle, pxy );
}

/*----------------------------------------------- RubberInit ---*/
void RubberInit ( void )
{
	vswr_mode ( vdi_handle, MD_XOR ) ;
	vsl_color ( vdi_handle, BLACK ) ;
	vsl_type ( vdi_handle, DOT );
	vsl_width ( vdi_handle, 1 ) ;
}

/*----------------------------------------------- FrameInit ---*/
void FrameInit ( int wrm, int color )
{
	vswr_mode ( vdi_handle, wrm ) ;
	vsl_color ( vdi_handle, color ) ;
	vsl_type ( vdi_handle, SOLID );
	vsl_width ( vdi_handle, 1 ) ;
}

/*----------------------------------------------- DrawFrame ---*/
void DrawFrame ( TRectangle *box  )
/*
	x0
 y0	0,1/8,9--------2,3
	|				|
	|				|
	6,7------------4,5
*/
{
	int pts[10] ;

	if ( box->x < DeskTop.x )
		box->x = DeskTop.x ;	
	if ( box->y < DeskTop.y )
		box->y = DeskTop.y ;	
	pts[0] = box->x ;			pts[1] = box->y ;
	pts[2] = box->x+box->w-1 ;	pts[3] = box->y ;
	pts[4] = pts[2] ;			pts[5] = box->y+box->h-1 ;
	pts[6] = box->x ;			pts[7] = pts[5] ;
	pts[8] = box->x ;			pts[9] = box->y ;

	v_pline ( vdi_handle, 5, pts ) ;
}


/*----------------------------------------------- MoveRubberBox ---*/
void MoveRubberBox ( TRectangle *box )
{
	int x, y, dx, dy, buttons ;

	ClippingOn ( vdi_handle, DeskTop ) ;
	_vq_mouse ( vdi_handle, &buttons, &x, &y ) ;
	dx = x - box->x ; 
	dy = y - box->y ; 
	RubberInit();
	mouse_off();
	DrawFrame ( box ) ;			/* draw	first */
	mouse_on();
	for(;;)
	{
		_vq_mouse ( vdi_handle, &buttons, &x, &y ) ;
		x -= dx ;
		y -= dy ;

		if ( buttons == 0 )
		{
			mouse_off();
			DrawFrame ( box ) ;	/* delete	*/
			mouse_on();
			ClippingOff ( vdi_handle ) ;
			return ;
		}

		if ( box->x != x || box->y != y )
		{
			mouse_off();
			DrawFrame ( box ) ;	/* delete	*/
			box->x = x ;
			box->y = y ;
			DrawFrame ( box ) ;	/* draw		*/
			mouse_on();
		}
		aes_delay ( 50 ) ;
	}
}



# define FRAMEcolor	RED
# define BACKcolor	BLUE
# define EMPTYcolor	YELLOW

# define MINFields	  2
# define MAXFields	 16
# define DEFFields	  4

# define FIELDcode(x,y)	(x*10+y)
# define FIELDx(code)	(code/10)
# define FIELDy(code)	(code%10)
# define FIELDborder	2
POINT FieldStart[MAXFields+2] ;	/* Start field 0..9, Stop 9	*/

int FrameStart = 0,		/* display sequence parameter	*/
	FrameEnd   = 0 ;
int CurrentMark = -1 ;

int NumXYFields  = FIELDcode(DEFFields,DEFFields) ;
int NumXFields   = DEFFields ;
int NumYFields   = DEFFields ;

int CurrXFields = 0 ;
int CurrYFields = 0 ;

int Mini  =    0 ;
int Maxi  =  999 ;
int Count =    0 ;



/*----------------------------------------------- SetupFieldStartTable ---*/
void SetupFieldStartTable ( TRectangle *dstwnd )
{
	int xyi, xy, wh ;
	POINT *pt ;
	
	xy = dstwnd->x + FIELDborder ;
	wh = dstwnd->w - FIELDborder ;
	for ( pt = FieldStart, xyi = 0; xyi <= NumXFields; xyi++, pt++ )
		pt->x = xy + iscale ( xyi, wh, NumXFields ) ;

	xy = dstwnd->y + FIELDborder ;
	wh = dstwnd->h - FIELDborder ;
	for ( pt = FieldStart, xyi = 0; xyi <= NumYFields; xyi++, pt++ )
		pt->y = xy + iscale ( xyi, wh, NumYFields ) ;
}


/*----------------------------------------------- GetSmallXYWH ---*/
void GetSmallXYWH ( int xi, int yi, TRectangle *dstwnd, TRectangle *small )
{
	dstwnd = dstwnd ;
	
	small->x = FieldStart[xi].x ; 
	small->w = FieldStart[xi+1].x - small->x - FIELDborder ;

	small->y = FieldStart[yi].y ; 
	small->h = FieldStart[yi+1].y - small->y - FIELDborder ;
}

/*----------------------------------------------- GetSmallRectangle ---*/
void GetSmallRectangle ( int i, TRectangle *dstwnd, TRectangle *small )
{
	GetSmallXYWH ( i % NumXFields, i / NumXFields, dstwnd, small ) ;
}

/*-------------------------------------------- MarkFrame -----*/
void MarkFrame ( int frame, TImageWindow *dest, int color )
{
	TRectangle small ;

	small = dest->window ;
	GetSmallRectangle ( frame - FrameStart, &dest->window, &small ) ;
	small.x-- ;
	small.y-- ;
	small.w += 2 ;
	small.h += 2 ;
	FrameInit ( MD_REPLACE, color ) ;
	DrawFrame ( &small ) ;
}


/*-------------------------------------------- MarkActiveFrame -----*/
void MarkActiveFrame ( int frame, TImageWindow *dest )
{
	if ( CurrentMark != frame )
	{
		if ( CurrentMark >= 0 )
			MarkFrame ( CurrentMark, dest, BACKcolor ) ;
		
		if ( frame >= 0 )
		{
			CurrentMark = frame ;
			MarkFrame ( CurrentMark, dest, FRAMEcolor ) ;
		}
		else
			CurrentMark = -1 ;
	}
}


/*------------------------------------------------- DrawSmallContents ----*/
bool DrawSmallContents ( SEQUENCE *sequence, TImageWindow *small, int frame )
{	
	switch ( ActivateFrame ( sequence, frame ) )
	{
case FR_DATAVALID :
# if DEBUG
		if ( bit_planes != 16 )
			DrawBox ( &small->window, WHITE ) ;
		else
# endif				
			StretchBlit ( &sequence->blitwind.dst, small ) ;
		break ;

case FR_BUFFERVALID :
		DrawBox ( &small->window, EMPTYcolor ) ;
		break ;

case FR_INVALID :
		return FALSE ;
	}
	return TRUE ;
}


/*----------------------------------------------- DrawSingleSmall --*/
void DrawSingleSmall ( SEQUENCE *sequence, TImageWindow *dest, int frame )
{
	TImageWindow small ;

	small = *dest ;
	GetSmallRectangle ( frame - FrameStart, &dest->window, &small.window ) ;

	DrawSmallContents ( sequence, &small, frame ) ;
}


/*----------------------------------------------- DrawSequence ---*/
void DrawSequence ( SEQUENCE *sequence, TImageWindow *dest )
{
	int xi, yi, oldcurr ;
	int frame, curr ;
	TImageWindow small ;
	bool end ;
		
	oldcurr = sequence->current ;
	
	small = *dest ;
	DrawBox ( &dest->window, BACKcolor ) ;

	curr = sequence->current ;

	if ( curr > sequence->valid )
		curr = sequence->valid ;
	if ( curr < 0 )
		curr = 0 ;

	if ( curr < FrameStart || curr > FrameEnd /* outside current range	*/
		|| NumXFields != CurrXFields
		|| NumYFields != CurrYFields )
	{
		CurrXFields = NumXFields ;	
		CurrYFields = NumYFields ;	
		FrameStart = curr / NumXFields * NumXFields ;	/* start at beginning of line */
	}

	SetupFieldStartTable ( &dest->window ) ;
		
	end = FALSE ;
	frame = FrameStart ;
	for ( yi = 0; yi < NumYFields && ! end; yi++ )
	{
		for ( xi = 0; xi < NumXFields && ! end; xi++, frame++ )
		{
			GetSmallXYWH ( xi, yi, &dest->window, &small.window ) ;
			end = ! DrawSmallContents ( sequence, &small, frame ) ;
		}
	}
	FrameEnd = frame-1 ;
	
	sequence->current = oldcurr ;
	CurrentMark = -1 ;

	MarkActiveFrame ( oldcurr, dest ) ;

	DisplaySequenceOn = TRUE ;
}


/*------------------------------------------- ClearDisplaySequence --------*/
void ClearDisplaySequence ( void )
{
	CurrentMark = -1 ;
	DisplaySequenceOn = FALSE ;
}


/*-------------------------------------------- CheckFrameDisplayed -----*/
bool CheckFrameDisplayed ( SEQUENCE *sequence, TImageWindow *dest, int frame )
/* returns TRUE <=> sequence display ok	*/ 
{
	bool redraw ;
	
	if ( DisplaySequenceOn )
	{
		mouse_off();

		redraw = frame < FrameStart || frame > FrameEnd ;
		if ( redraw )
			DrawSequence ( sequence, dest ) ;
		mouse_on();
		return redraw ;
	}
	else
		return TRUE ;
}


/*-------------------------------------------- CheckCurrentDisplayed -----*/
bool CheckCurrentDisplayed ( SEQUENCE *sequence, TImageWindow *dest )
/* returns TRUE <=> sequence display ok	*/ 
{
	return CheckFrameDisplayed ( sequence, dest, sequence->current ) ;
}


/*----------------------------------------------- FindSmall ---*/
int FindSmall ( int x, int y, TRectangle *dest )
{
	int xi, yi ;
	int frame ;
	TRectangle small ;

	frame = FrameStart ;
	for ( yi = 0; yi < NumYFields; yi++ )
	{
		for ( xi = 0; xi < NumXFields && frame <= FrameEnd; xi++, frame++ )
		{
			GetSmallXYWH ( xi, yi, dest, &small ) ;
			if ( PointInsideRectangle ( x, y, &small ) )
				return frame ;
		}
	}
	return -1 ;	
}


/*------------------------------------------------ SetCounter ------*/
void SetCounter ( int count )
{
	Count = count ;
	SetToolNumber ( IS_COUNT, count ) ;
}

/*------------------------------------------------ SetMaxi ------*/
void SetMaxi ( int maxi )
{
	Maxi = maxi ;
	SetToolNumber ( IS_MAX, maxi ) ;
}




/*----------------------------------------------- ReleaseButtons ---*/
void ReleaseButtons ( void )
{
	ReleasePosition ( &dummy, &dummy ) ;
}


/* ------------------------------------------------- SkipInput ------- */
bool SkipInput ( void )
{
	int buttons, dummy ;
	
	if ( ( Kbshift(-1) & 0xef ) != 0 )
		return TRUE ;

	_vq_mouse ( vdi_handle, &buttons, &dummy, &dummy ) ;
	if ( buttons != 0 )
	{
		ReleaseButtons();
		return TRUE ;
	}
	else
		return FALSE ;
}



/*------------------------------------------------ auto_check ----*/
void auto_check ( void )
{
	if ( madi_ok )
	{
		SetVideoSignal ( PUP_AUTO ) ;
		SetVideoSource ( DEFsource ) ;
		mouse_busy () ;
		chk_set_chan_sig ( (int *)&GetVideoSource(),
						   (int *)&GetVideoSignal(),
						   (int *)&dummy ) ;
		mouse_arrow () ;

		if ( ( GetVideoSignal() != PUP_AUTO ||
			   GetVideoSource() != PUP_AUTO ) )
			set_window_title() ;

		check_source_pop() ;
		check_signal_pop() ;
		check_standard_pop() ;
	}
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
void new_top ( void )
{
	if ( madi_ok )
		InitMdf ( GetVideoSignal(), GetVideoSource(), GetDmsdType() ) ;
    check_source_pop() ;
    check_signal_pop() ;
	check_display_pop ( bit_planes ) ;
	check_zoom_pop() ;
}

/* ----------------------------------- BlitScreenEyeWindow ------------------- */
void BlitScreenEyeWindow ( void )		
{
	BlitWindow.src.window.w = BlitWindow.dst.window.w ;
	BlitWindow.src.window.h = BlitWindow.dst.window.h ;
/*
	printf ( "\033H" ) ;
	BlitWindowInfo (  &BlitWindow ) ;
*/
	if ( bit_planes == 16 )
	{
		Blit555Window ( &BlitWindow, &Zoom ) ;
	}
	else
	{
		BlitWindow.dst.window.x &= ~15 ;
		BlitWindow.src.window.w = BlitWindow.dst.window.w &= ~15 ;
		(*(BlitProc[PaletteDisplayMode]))( &BlitWindow, &Zoom ) ;
	}
}

/* ----------------------------------- get_picture ------------------- */
void get_picture ( bool dograb )
{
# if DEBUG
	if ( madi_ok && bit_planes >= 8 )
# else
	if ( madi_ok )
# endif
	{
		if ( dograb )
			GrabFieldIntoFifo ( GetWaitUntilFrameGrabbed(), FIELDnext ) ;

		BlitScreenEyeWindow() ;
	}
	else
		if ( dograb )
			test_output ( &BlitWindow.dst.window ) ;
}


/* -------------------------------- repeat_pic ------------------- */
void repeat_pic ( void )
{
# if DEBUG
	if ( bit_planes < 8 )
	{
		test_output ( &BlitWindow.dst.window ) ;
		return ;
	}
# endif
	BlitScreenEyeWindow() ;
}



/* ----------------------------------------------- update_hardware ------ */
void update_hardware ( void )
{
	setup_param() ;
			
	check_display_pop ( bit_planes ) ;
	check_zoom_pop() ;
	check_signal_pop () ;
	check_source_pop () ;
	
	if ( madi_ok )
	{
		if ( ( GetVideoSignal() == PUP_AUTO ) || ( GetVideoSource() == PUP_AUTO ) )
		{
			SetVideoSignal ( PUP_AUTO ) ;
			SetVideoSource ( DEFsource ) ;
			set_window_title () ;
			auto_check () ;
		}
		else
		{
			InitMdf ( GetVideoSignal(),
						  GetVideoSource(), GetDmsdType() ) ;
			set_window_title () ;
		}
	}

	restart_sliders () ;	
	if ( ( check_video_param () ) )
		resize_window();
	else
		get_picture ( FALSE ) ;
}




/*------------------------------------------- restart_acc ---------*/
void restart_acc ( void )
{
	int i ;
	int work_in[11] ;
	int work_out[57] ;

	v_clsvwk ( vdi_handle ) ;

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
	}
}



/* ----------------------------------------- handle_message ----- */
int handle_message( int pipe[8] )
{
/*	TRectangle curr, work ; */
	
	switch ( pipe[0] )
	{
case WM_ARROWED:
		if ( ( ( old_msg != WM_ARROWED ) || 
			   ( pipe[4] == WA_UPLINE  ) ||
			   ( pipe[4] == WA_DNLINE  ) ||
			   ( pipe[4] == WA_LFLINE  ) ||
			   ( pipe[4] == WA_RTLINE  ) ) && pipe[3] == whandle )
		{
			switch ( pipe[4] )
			{
		case WA_LFPAGE:	BlitWindow.src.window.x -= x_page ;
						update_x_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
		case WA_RTPAGE:	BlitWindow.src.window.x += x_page ;
						update_x_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
		case WA_LFLINE:	BlitWindow.src.window.x -- ;
						update_x_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
		case WA_RTLINE:	BlitWindow.src.window.x ++ ;
						update_x_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
						
		case WA_UPPAGE:	BlitWindow.src.window.y -= y_page ;
						update_y_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
		case WA_DNPAGE:	BlitWindow.src.window.y += y_page ;
						update_y_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
		case WA_UPLINE:	BlitWindow.src.window.y -- ;
						update_y_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
		case WA_DNLINE:	BlitWindow.src.window.y ++ ;
						update_y_slider ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						break ;
			default:	break ;
			}
			repeat_pic () ;
		}
		break ;

case WM_VSLID:
		if ( pipe[3] == whandle )
		{
			calc_y_slider ( pipe[4], &BlitWindow.dst.window, &BlitWindow.src.window ) ;
			repeat_pic () ;
		}
		break ;
      
case WM_HSLID:
		if ( pipe[3] == whandle )
		{
			calc_x_slider ( pipe[4], &BlitWindow.dst.window, &BlitWindow.src.window ) ;
			repeat_pic () ;
		}
		break ;

 case WM_REDRAW:
		if ( whandle == pipe[3] )
		{
			if ( ! FileSelectorRedrawDone )
				redraw_window () ;
			else
				FileSelectorRedrawDone = FALSE ;
		}
		break;

 case WM_TOPPED:
		if ( whandle == pipe[3] )
		{
			wind_set ( whandle, WF_TOP ) ;
 			new_top () ;
		}
		break ;

 case WM_FULLED:
		if ( pipe[3] == whandle )
			ToggleWindowFulled() ;
		break ;

 case WM_CLOSED:
		if ( pipe[3] == whandle )
		{
			close_d_window () ;

			acc_opened = FALSE ;
			return _app ;
		}
		break ;

 case WM_MOVED:
 case WM_SIZED:
		if ( pipe[3] == whandle )
# if 0
			WindowMovedOrSized ( (TRectangle *)&pipe[4] ) ;
# else
			SetWindowRectangle ( (TRectangle *)&pipe[4] ) ;
# endif
		break;

 case AC_OPEN:
		if ( pipe[4] == menu_id )
		{
			if ( !acc_opened )
			{
				/* setup essential variables */
				end_program = 0 ;
				acc_opened = TRUE ;
				restart_acc () ;

				/* reopen BlitWindow.dst.window */
    			reopen_window() ;

				/* find video signal */
				SetVideoSignal ( PUP_AUTO ) ;
				SetVideoSource ( DEFsource ) ;
				auto_check () ;
				check_display_pop ( bit_planes ) ;

				/* get picture */
				UpdatePalette();
				get_picture ( TRUE ) ;
			}
			else
			{
				wind_set ( whandle, WF_TOP ) ;
				new_top () ;
			}
		}
		break;

 case AC_CLOSE:
		if ( pipe[3] == menu_id )
		{
			RestorePalette();
			kill_digit_windows () ;
			return _app ;
		}
	}
	old_msg = pipe[0] ;
	return 0 ;
}


/*-------------------------------------------- LoadActualScreenEyeLca --------*/
void LoadActualScreenEyeLca ( void )
{
	LoadMatDigiFLcaData ( 0, DigiMode[PaletteDisplayMode], &Zoom, TRUE ) ;
}

/*-------------------------------------------- SetNewPaletteDisplayMode --------*/
void SetNewPaletteDisplayMode ( TPaletteDisplayMode plm, char *info )
{
	if ( bit_planes < 16 )
	{
		PaletteDisplayMode = plm ;
		if ( info != NULL )
			WindowMessage ( info ) ;
		LoadActualScreenEyeLca() ;
		UpdatePalette() ;
	}
}


/*------------------------------------ GrabFullFrame --------------------*/
bool GrabFullFrame ( void )
{
	if ( FullFrameBuffer.dst.image.data != NULL)
	{
/*
printf ( "\033H" ) ;	BlitWindowInfo ( &BlitWindow ) ;
printf ( "\033K" ) ;	BlitWindowInfo ( &FullFrameBuffer ) ;
*/
		LoadMatDigiFLcaData ( 0, DIGcolor, &FullZoom, TRUE ) ;
		Blit555Window ( &FullFrameBuffer, &FullZoom ) ;
		InterPolate555 ( &FullFrameBuffer.dst, &BlitWindow.dst, &Zoom ) ;

		LoadActualScreenEyeLca();

		return TRUE ;
	}
	else
		return FALSE ;
}


/*----------------------------------- CheckSequenceAvailable -----------*/
bool CheckSequenceAvailable ( void )
{
	if ( SequenceEmpty ( &Sequence ) )
	{
		WindowMessage ( "* Film leer" ) ;
		return FALSE ;
	}
	else
		return TRUE ;
}

/*----------------------------------- CheckSequenceEmpty -----------*/
bool CheckSequenceEmpty ( void )
{
	if ( SequenceEmpty ( &Sequence ) )
	{
		return TRUE ;
	}
	else
	{
		WindowMessage ( "* Film nicht leer" ) ;
		return FALSE ;
	}
}

/*-------------------------------------------- WriteError --------*/
void WriteError ( int result )
{
	WindowMessage ( "* Schreibfehler %d", result ) ;
}


/*-------------------------------------------- SaveStart --------*/
bool SaveStart ( void )
{
	int result ;
	
	if ( CheckSequenceAvailable() )
	{
		if ( get_pic_file_name ( BaseName, "*.*", &SequenceFileFormat, "Film schreiben" ) )
		{
			mouse_busy();
			mouse_on();
			WindowMessage ( "Schreiben '%s'", BaseName ) ;
			result = WriteSequenceHeader ( &Sequence, BaseName, SequenceFileFormat ) ;
			mouse_off();
			mouse_arrow();
			if ( result == OK )
			{
				Sequence.current = Mini ;
				if ( Maxi >= Sequence.valid )
					SetMaxi ( Sequence.valid - 1 ) ;
				return TRUE ;
			}
			else
				WriteError ( result ) ;
		}
	}
	return FALSE ;
}

/*--------------------------------------------- SaveNext -----------*/
int SaveNext ( void )
{
	int frame, result ;
	
	if ( ( frame = Sequence.current ) <= Maxi )
	{
		mouse_busy();
		result = WriteFrame ( &Sequence, BaseName, frame ) ;
		mouse_off();	/* during display update	*/
		mouse_arrow();
		if( result == OK )
		{
			SetCounter ( frame ) ;
			SignalReady ( frame, Maxi ) ;
			Sequence.current++ ;
		}
		else
			WriteError ( result ) ;
		mouse_on();
	}
	else
		frame = -1 ;
	return frame ;
}


/*-------------------------------------- SaveEnd ------------*/
void SaveEnd ( void )
{
	FreeConvBuffer();
}



/*-------------------------------------------- ReadError --------*/
void ReadError ( int result )
{
	WindowMessage ( "* Lesefehler %d", result ) ;
# if 0
	SetMaxi ( INVALID ) ;
	SetCounter ( INVALID ) ;
# endif
}


/*-------------------------------------------- LoadStart --------*/
bool LoadStart ( void )
{
	int result ;

Tprintf ( ( "\033H+ LoadStart  \n" ) ;	result = 0 ) ;
	if ( CheckSequenceEmpty() )
	{
		if ( get_pic_file_name ( BaseName, "*.*", &SequenceFileFormat, "Film lesen" ) )
		{
			mouse_busy();
			mouse_on();
			WindowMessage ( "Lesen '%s'", BaseName ) ;
			result = ReadSequenceHeader ( &Sequence, BaseName ) ;
			mouse_off();
			mouse_arrow();
			if ( result == OK )
			{
				Sequence.current = Mini ;
				if ( Maxi >= Sequence.valid )
					SetMaxi ( Sequence.valid - 1 ) ;
Tprintf ( ( "- LoadStart ok, Maxi = %d \n", Maxi ) ) ;
				Sequence.valid = Sequence.frames = 0 ;
				return TRUE ;
			}
			else
				ReadError ( result ) ;
		}
	}
Tprintf ( ( "- LoadStart * bad : %d \n", result ) ) ;	
	return FALSE ;
}

/*--------------------------------------------- LoadNext -----------*/
int LoadNext ( void )
{
	int frame, result ;
	
	if ( ( frame = Sequence.current ) <= Maxi )
	{
Tprintf ( ( "+ LoadNext %d\n", frame ) ) ;
		mouse_busy();
		result = ReadFrame ( &Sequence, BaseName, frame ) ;
		mouse_off();	/* during display update	*/
		mouse_arrow();
		if( result == OK )
		{					/* open error only, if first file	*/
			SetCounter ( frame ) ;
			SignalReady ( frame, Maxi ) ;
			Sequence.current++ ;
Tprintf ( ( "- LoadNext ok \n" ) ) ;	
		}
		else
		{
			if ( result != FILEopenError || frame == Mini )
				ReadError ( result ) ;
# if 0
			frame = -1 ;
# endif
Tprintf ( ( "- LoadNext * bad * \n" ) ) ;	
		}
		mouse_on();
	}
	else
		frame = -1 ;
Tprintf ( ( "- LoadNext * end * \n" ) ) ;	
	return frame ;
}


/*-------------------------------------- LoadEnd ------------*/
void LoadEnd ( void )
{
	Sequence.valid = Sequence.current ;
	SetMaxi ( Sequence.valid - 1 ) ;

	FreeConvBuffer();
}

/*-------------------------------------------- RedrawDisplaySequence ----*/
void RedrawDisplaySequence ( void )
{
	mouse_off();
	DrawSequence ( &Sequence, &BlitWindow.dst ) ;
	mouse_on();
}


/*-------------------------------------------- SetDisplaySequenceMode ----*/
void SetDisplaySequenceMode ( bool on )
{
	if ( on != DisplaySequenceOn )
	{
		if ( on )
			RedrawDisplaySequence();
		else
		{
			ClearDisplaySequence() ;
# if DEBUG
			if ( bit_planes != 16 || DisplayFrame ( &Sequence, Sequence.current, &BlitWindow.dst ) < 0 )
# else
			if ( DisplayFrame ( &Sequence, Sequence.current, &BlitWindow.dst ) < 0 )
# endif
				get_picture ( FALSE ) ;
		}
	}
}


POINT infopos = { 0, 0 } ;
char *infomesg = NULL ;
extern char *empty_mesg ;

/*-------------------------------------------------- GetObjectInfo ---------*/
char *GetObjectInfo ( int obj )
{
	switch ( obj )
	{
	case IS_LEFT2 :		return "Schneller Rcklauf" ;
	case IS_LEFT  :		return "Abspielen rckw„rts" ;
	case IS_STOP  :		return "Stop" ;
	case IS_PAUSE :		return "Pause" ;
	case IS_RIGHT :		return "Abspielen vorw„rts" ;
	case IS_RIGHT2 :	return "Schneller Vorlauf" ;
	case IS_TV    :		return "Live Video" ;
	case IS_LIVE_BOX :	return "Sucherfenster" ;
	case IS_FILM  :		return "Film" ;
	case IS_REWIND :	return "zum Anfang" ;
	case IS_LSTEP :		return "1 Bild links" ;
	case IS_RECORD :	return "Aufnahme" ;
	case IS_SOUND :		return "Ton an/aus" ;
	case IS_RSTEP :		return "1 Bild rechts" ;
	case IS_WIND  :		return "zum Ende" ;
	case IS_PHOTO :		return "Einzelbild -> Film" ;
	case IS_PHOTO_MAX :	return "Vollbild -> TIF-Datei" ;
	case IS_WR_DISK :	return "Film schreiben" ;
	case IS_RD_DISK :	return "Film lesen" ;
	case IS_TRASH :		return "Mlleimer" ;
	case IS_DISPLAY :	return "Einzelbild / Sequenz" ;
	case TX_NAME  :		return "Filmname" ;
	case TX_PARAM  :	return "-> Parameterbox" ;
	case IS_VOLUME :	return "Lautst„rke" ;
	case IS_PARAM :		return "X/Y Anzahl Sequenz" ;
	case IS_MIN   :		return "Minimum" ;
	case IS_COUNT :		return "Z„hler" ;
	case IS_MAX   :		return "Maximum" ;
	case IS_ZOOM :		return "Zoom < / >" ;	
	case TX_ZOOM  :		return "X/Y Zoom" ;
# if 0
	case IS_TOOLS :		return "Werkzeugleiste aus" ;
# else
	case TX_CLOSE :		return "Werkzeuge aus / Ende" ;
# endif

# if 0
	case IS_M :			return "Sonderfunktionen" ;
	case TX_MESG  :		return "" ;
# endif
	default :			return empty_mesg ;
	}
}


/*------------------------------------------ TerminateRunMode ---------*/
void TerminateRunMode ( void )
{
	switch ( RunMode )
	{
case IDLE :		return ;

case DIGITIZE :	
# if DEBUG
				if ( bit_planes == 16 )
# endif
					GrabFullFrame();
				SetDisplaySequenceMode ( LastDisplaySequenceOn ) ;
				break ;

case LOADfilm :	LoadEnd();
				SetTrashState();
				if ( DisplaySequenceOn )
					RedrawDisplaySequence();
				break ;
				
case SAVEfilm :	SaveEnd();
				break ;

case PLAY_FORWARD :
case PLAY_BACK :
case PLAY_FAST_FORWARD :
case PLAY_FAST_BACK :
				PlayStop ( &Sequence ) ;
				if ( LastDisplaySequenceOn )
					RedrawDisplaySequence();
				break ;

case RECORD :	RecordStop ( &Sequence ) ;
				SetMaxi ( Sequence.valid - 1 ) ;
				SetTrashState();
				if ( LastDisplaySequenceOn )
					RedrawDisplaySequence();
				break ;
	}

	SwitchFilmIconColor ( LWHITE ) ;
	CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) ;
}

/*------------------------------------------ UpdateInfo -----------*/
void UpdateInfo ( char *mesg )
{
	if ( mesg != infomesg )
	{
		WindowMessage ( mesg ) ;
		infomesg = mesg ;
	}
}

/*------------------------------------------ StartRunMode ---------*/
bool StartRunMode ( void )
{
	LastDisplaySequenceOn = DisplaySequenceOn ;

	switch ( RunMode )
	{
case IDLE :		ToolNormal ( IS_STOP ) ;
				break ;

case LOADfilm :	SwitchFilmIconColor ( BLUE ) ;
				return LoadStart() ;
				
case SAVEfilm :	SwitchFilmIconColor ( RED ) ;
				return SaveStart();

case DIGITIZE :	Step = +1 ;
				ClearDisplaySequence() ;
				SwitchFilmIconColor ( GREEN ) ;
				UpdatePalette();
				break ;

case RECORD :	Step = +1 ;
				SwitchFilmIconColor ( RED ) ;
				RecordStart ( &Sequence ) ;
				break ;

case PLAY_FORWARD :
case PLAY_FAST_FORWARD :
case PLAY_BACK :
case PLAY_FAST_BACK :
				ClearDisplaySequence() ;
				PlayStart ( &Sequence, Step ) ;
				break ;
	}
	return TRUE ;
}


/*------------------------------------------------ NewRunMode ------*/
bool NewRunMode ( TRunMode newmode )
{
	int toolicon ;
	
	if ( RunMode != newmode )
	{
		TerminateRunMode();
		ToolNormal ( GetToolIcon() ) ;

		RunMode = newmode ;
		toolicon = GetToolIcon() ;
		ToolSelect ( toolicon ) ;

		UpdateInfo ( GetObjectInfo ( toolicon ) ) ;

		if ( ! StartRunMode() )
		{
			ToolNormal ( toolicon ) ;
			RunMode = IDLE ;
		}
		return TRUE ;
	}
	else
		return FALSE ;
}

/*------------------------------------------------ SwitchDigitiserMode ------*/
void SwitchDigitiserMode ( void )
{
	if ( RunMode == DIGITIZE )
		NewRunMode ( IDLE ) ;
	else
		NewRunMode ( DIGITIZE ) ;
}





# define CHANGEDflags	0x8000	/* allow neg. numbers > -16k	*/
# define CHANGEDmask	0xc000

/*------------------------------------------ PositionSequence ------*/
void PositionSequence ( int frame )
{
	bool framechanged ;

	framechanged = ( frame & CHANGEDmask ) == CHANGEDflags ;
	if ( framechanged )
		frame &= ~CHANGEDmask ; 

	if ( frame < 0 )
		frame = 0 ;
	if ( frame > Sequence.valid )
		frame = Sequence.valid  ;
	Sequence.current = frame ;
		
	if ( ! ToolsVisible )
		WindowMessage ( "* Frame # %d", frame ) ;

	if ( CheckSequenceAvailable() )
	{
		mouse_off();
		NewRunMode ( IDLE ) ;
		if ( DisplaySequenceOn )
		{
# if 1
			if ( ! CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) 
				&& framechanged )
				DrawSingleSmall ( &Sequence, &BlitWindow.dst, frame ) ;
			MarkActiveFrame ( frame, &BlitWindow.dst ) ;
# else
			if ( ( ChkAndSetCurrentFrame ( &Sequence, frame ) ) >= 0 )
			{
				if ( ! CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) 
					&& framechanged )
					DrawSingleSmall ( &Sequence, &BlitWindow.dst, frame ) ;
			}
# endif
		}
		else	/* full screen mode	*/
		{
			if ( frame < Sequence.valid )
			{
# if DEBUG
				if ( bit_planes != 16 )
					test_output ( &BlitWindow.dst.window ) ;
				else
# endif
					frame = DisplayFrame ( &Sequence, frame, &BlitWindow.dst ) ;
			}
			else
				DrawBox ( &BlitWindow.dst.window, EMPTYcolor ) ;
		}
		SetCounter ( frame ) ;
		mouse_on();
	}
}


/*-------------------------------------------- DeleteFilm --------*/
void DeleteFilm ( void )
{
	if ( CheckSequenceAvailable() )
	{
		ToolSelect ( IS_TRASH ) ;
		WindowMessage ( "* L”sche Film" ) ;
		FreeSequence ( &Sequence ) ;
		SetTrashState();
		SetMaxi ( 999 ) ;
		SetCounter ( INVALID ) ;
		ToolNormal ( IS_TRASH ) ;
	}
}

/*-------------------------------------------- MallocFilm --------*/
int MallocFilm ( void )
{
	int frames ;
	
	frames = MallocSequence ( &Sequence, Maxi, &BlitWindow.src, &Zoom ) ;
	SetMaxi ( frames ) ;
	return frames > 0 ;
}


/*-------------------------------------------- NewZoomSetup --------*/
void NewZoomSetup ( void )
{
	char *txt ;

	if ( Zoom.x > 2 && PaletteDisplayMode == PALgrey )
		 Zoom.x = 2 ;

	check_zoom_pop () ;
	LoadActualScreenEyeLca();
	txt = ToolsTree[TX_ZOOM].ob_spec.tedinfo->te_ptext ;
	*txt++ = Zoom.x + '0' ;	/* set 'xy'	-> txt	*/
	*txt++ = Zoom.y + '0' ;
	ZoomXY = Zoom.x * 10 + Zoom.y ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, TX_ZOOM ) ;

	resize_window ();
}

/*-------------------------------------------- SetNewZoomCode --------*/
void SetNewZoomCode ( int zoomcode, int incr )
{
	if ( incr != 0 )
		zoomcode = ( zoomcode + (NUMzoomCodes+incr) ) % NUMzoomCodes ;

	if ( zoomcode > Z22 && PaletteDisplayMode == PALgrey )
		zoomcode = incr > 0 ? Z11 : Z22 ;

	menu_zoom = zoomcode ;
	Zoom = ZoomTable [menu_zoom] ;
	NewZoomSetup();
}


/*-------------------------------------------- SwitchTools -----------*/
void SwitchTools ( void )
{
	ToolsVisible = ToolBarOn = ! ToolBarOn ;
	reset_window ( CurrentStyle ) ;
}


/*-------------------------------------------- CheckNumOfFields ----------*/
void CheckNumOfFields ( int *nflds )
{
	if ( *nflds < MINFields	)
		*nflds = MINFields ;
	if ( *nflds > MAXFields	)
		*nflds = MAXFields ;
}


/*------------------------------------------- TerminateEditTextField ------*/
int TerminateEditTextField ( void )
{
	int   oldobj ;

	oldobj = DeselectCurrTextField() ;
	switch ( oldobj )
	{
case IS_MIN :	break ;
case IS_MAX :	break ;

case IS_COUNT :	PositionSequence ( Count ) ;
				break ;

case IS_PARAM :	if ( NumXYFields == 00 && Sequence.frames >= 4 )
				{
					NumXFields = SquareRoot ( Sequence.frames ) ;
					NumYFields = ( Sequence.frames + NumXFields - 1 ) / NumXFields ;
				}
				else
				{
					NumXFields = FIELDx(NumXYFields) ;
					NumYFields = FIELDy(NumXYFields) ;
					if ( NumXFields == 1 )
						NumXFields = 16 ;
					if ( NumYFields == 1 )
						NumYFields = 16 ;
					if ( Sequence.frames >= 4 )
					{
						if ( NumXFields == 0 )
							NumXFields = ( Sequence.frames + NumYFields - 1 ) / NumYFields ;
						else if ( NumYFields == 0 )
							NumYFields = ( Sequence.frames + NumXFields - 1 ) / NumXFields ;
					}
				}
				CheckNumOfFields ( &NumXFields ) ;
				CheckNumOfFields ( &NumYFields ) ;
				NumXYFields = ( NumXFields <= 9 ? NumXFields : 0 ) * 10
								+ ( NumYFields <= 9 ? NumYFields : 0 ) ;
				SetToolNumber ( IS_PARAM, NumXYFields ) ;
				if ( DisplaySequenceOn
					&& ( NumXFields != CurrXFields
					  || NumYFields != CurrYFields ) )
					DrawSequence ( &Sequence, &BlitWindow.dst ) ;
				break ;

case IS_VOLUME :{
					int gain, att ;
					
					gain = ( Volume/10 ) << 4 ; 		 /* 0.. 7 */
					att  = ( ( Volume%10 ) << 5 ) + 16 ; /* 1..15 */
					if ( gain < 256 && att < 256 ) 
						SetVolume ( gain, att ) ;
					WindowMessage ( "Vol %d, Gain %d, Att %d", 
											Volume, gain, att ) ;
				}
				break ;

case TX_ZOOM :	Zoom.x = ZoomXY / 10 ;
				Zoom.y = ZoomXY % 10 ;
				if ( Zoom.x < 1 )
					Zoom.x = 1 ;
				else if ( Zoom.x > 2 && PaletteDisplayMode == PALgrey )
					 Zoom.x = 2 ;
				if ( Zoom.y < 1 )
					Zoom.y = 1 ;
				NewZoomSetup();
				break ;
	}
	return oldobj ;
}

# define DONTset	((int)0x8000)

/*------------------------------------------- StartEditTextField ------*/
void StartEditTextField ( int obj, int *pval, int defval )
{
	if ( TerminateEditTextField() != obj )
	{
		if ( defval != DONTset && pval != NULL )	/* set to default value */
		{
			*pval = defval ;
			SelectTextField ( obj, pval ) ;
			TerminateEditTextField() ;
		}
		else
		{
			SelectTextField ( obj, pval ) ;
		}
	}
}

/* ------------------------------------------------- ParameterBox ------- */
void ParameterBox ( void )
{
	mouse_on();
	handle_fparams ( NULL, 0, MD_PARAM, NO_EDIT ) ;
	update_hardware();
	mouse_off();
}

				
/*-------------------------------------------------------- digit_keyboard ------*/
unsigned digit_keyboard ( int keycode )
{
	if ( ( keycode & 0xff ) >= ' ' )
		keycode &= 0xff ;

	switch (keycode)
	{
case HELP :		SwitchTools() ;
				return 0 ;

case RETURN :
case ENTER :	TerminateEditTextField();
				return 0 ;

/*.............................................................*/

case F1 :		NewRunMode ( IDLE ) ;
				get_picture ( TRUE ) ;
				clear_keyboard () ;
				return 0 ;

case F2 :		NewRunMode ( DIGITIZE ) ;
				return 0 ;

case F3 :		tail_y = 0 ;
				SetNewZoomCode ( max_y > (240+480)/2 ? Z41 : Z21, 0 ) ;
				return 0;
				
case F4 :		tail_y = 0 ;
				SetNewZoomCode ( max_y > (240+480)/2 ? Z82 : Z42, 0 ) ;
				return 0;

# if 0
case CUR_UP :	if ( realtime_tail_y < 128 )
					realtime_tail_y++ ;
				WindowMessage ( "Tail - Y %d", realtime_tail_y ) ;
				return 0 ;

case CUR_DOWN :	if ( realtime_tail_y > 0 )
					realtime_tail_y-- ;
				WindowMessage ( "Tail - Y %d", realtime_tail_y ) ;
				return 0 ;
# endif
case F5 :		tail_y = realtime_tail_y ;
				SetNewZoomCode ( Z42, 0 ) ;
				return 0;

# if INFORMATION
case F6:		printf ( "\033H" ) ;
				SequenceInfo ( &Sequence ) ;
				return 0 ;
# endif

case CUR_LEFT:	PositionSequence ( Sequence.current - 1 ) ;				return 0 ;
case CUR_RIGHT:	PositionSequence ( Sequence.current + 1 ) ;				return 0 ;
case CUR_UP:	PositionSequence ( Sequence.current - NumXFields ) ;	return 0 ;
case CUR_DOWN:	PositionSequence ( Sequence.current + NumXFields ) ;	return 0 ;

case SHFT_CL:	PositionSequence ( Sequence.current / NumXFields * NumXFields ) ;	return 0 ;
case SHFT_CR:	PositionSequence ( Sequence.current / NumXFields * NumXFields + NumXFields - 1 ) ;	return 0 ;
case SHFT_CU:	PositionSequence ( Sequence.current - NumXFields*NumYFields ) ;	return 0 ;
case SHFT_CD:	PositionSequence ( Sequence.current + NumXFields*NumYFields ) ;	return 0 ;

# if 0
case F7:
case F8 :
case F9:
case '*':
# endif

case HOME :		PositionSequence ( 0 ) ;				return 0 ;
case SHFT_HOME:	PositionSequence ( Sequence.valid-1 ) ;	return 0 ;

case SHFT_F7:	DeleteFilm() ;					return 0 ;
	
# if 0
case SHFT_F8:	SaveFilm();
				return 0 ;
	
case SHFT_F9:	LoadFilm();
				return 0 ;
# endif

case F10 :
case CNTRL_Q :	NewRunMode ( IDLE ) ;
				kill_digit_windows () ;
				return _app ;


default :		/* edit / ascii chars 	*/
				if ( GetCurrTextField() >= 0 )
				{
					EnterCurrTextField ( keycode ) ;
				}
				else
				{
					switch ( keycode )
					{
		case '?' :		mouse_on();
						handle_fdialog ( NULL, 0, DHELP, NO_EDIT ) ;
						mouse_off();
						return 0 ;
		case '1' :
		case '2' :
		case '3' :		SetVideoSource ( keycode - '0' ) ;
						if ( madi_ok )
							InitMdf ( GetVideoSignal(),
								  GetVideoSource(), GetDmsdType() ) ;
				        set_window_title ( ) ;
				        check_source_pop ( ) ;
						return 0 ;

		case 'a' :
		case 'A' :		SetVideoSignal ( PUP_AUTO ) ;
						SetVideoSource ( DEFsource ) ;
						set_window_title ( ) ;
						auto_check ( ) ;
						return 0 ;
		
# if 0
		case '#' :		calc_window ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
						get_picture ( FALSE ) ;
						return 0 ;
# endif
		
# if ! INFORMATION
		case F6:		return 0 ;
# endif
		case 'b' :
		case 'B' :		WindStyleNumber = ++WindStyleNumber % 3 ;
						reset_window ( WindStyleTable [ WindStyleNumber ] ) ;
						return 0 ;
		
		case 'd' :
		case 'D' :		get_picture ( TRUE ) ;
						clear_keyboard () ;
						return 0 ;
		case 'f' :
		case 'F' :		SetVideoSignal ( PUP_CVBS ) ;
						if ( madi_ok )
							InitMdf ( GetVideoSignal(),
								      	  GetVideoSource(), GetDmsdType() ) ;
			            set_window_title ( ) ;
			            check_signal_pop ( ) ;
						return 0 ;
		case 'i' :
		case 'I' :		mouse_on();
						update_info () ;
						handle_fdialog ( NULL, 0, MD_INFO, NO_EDIT ) ;
						mouse_off();
						return 0 ;
		
		case 'o' :
		case 'O' :		SwitchDigitiserMode();
						return 0 ;
		case 'p' :
		case 'P' :		ParameterBox() ;
						return 0 ;
		case 's' :
		case 'S' :		SetVideoSignal ( PUP_SVHS ) ;
						if ( madi_ok )
							InitMdf ( GetVideoSignal(),
									      GetVideoSource(), GetDmsdType() ) ;
			            set_window_title ( ) ;
			            check_signal_pop ( ) ;
						return 0 ;

		case 'g' :		SetNewPaletteDisplayMode ( PALgrey, "Graupalette" ) ;
						break ;
						
		case 'y' :		SetNewPaletteDisplayMode ( PALyuv, "YUV-Palette" ) ;
						break ;
						
		case 'c' :		SetNewPaletteDisplayMode ( PALrgb, "Farbpalette" ) ;
						break ;
		
		case 't' :
		case 'T' :		SwitchTools() ;
						return 0 ;
		
		case 'Z' :		SetNewZoomCode ( menu_zoom, -1 ) ;
						return 0;
		case 'z' :		SetNewZoomCode ( menu_zoom, +1 ) ;
						return 0;
# if TEST
		case 'v' :		*(ScreenEyeParameter->verbose) = 1 ;
						return 0;
		case 'V' :		*(ScreenEyeParameter->verbose) = 0 ;
						return 0;
# endif TEST	
		default :		return 0 ;
					}
				}
	}
	return 0 ;
}

/*-------------------------------------------- GetLoopDelay -----------*/
int GetLoopDelay ( void )
{
	int top ;

	wind_get ( whandle, WF_TOP, &top ) ;

# if DEBUG
	if ( bit_planes != 16 )
		return 50 ;
# endif
	return whandle == top && !Paused && RunMode != IDLE
				? TOP_DELAY : BACK_DELAY ;
}


/*----------------------------------------- StartPlayMode ------------*/
void StartPlayMode ( int obj, TRunMode playmode, int step )
{
	ToolSelect ( obj ) ;
	ReleaseButtons();
	if ( CheckSequenceAvailable() )
	{
		Step = step ;
		SwitchFilmIconColor ( BLUE ) ;
		NewRunMode ( playmode ) ;
	}
	else
	{
		NewRunMode ( IDLE ) ;
		ToolNormal ( obj ) ;
	}
}


/* ------------------------------------------------- YesOrNo --------------- */
bool YesOrNo ( const char *format, ... )
{
	char mesg[64] ;
	int buttons ;
	
	vsprintf ( mesg, format, (va_list)... ) ;
	WindowMessage ( "- %s (Ly/Rn) ?", mesg ) ;
	ReleaseButtons();
	buttons = WaitForClick() ;
	WindowMessage ( "- %s - %s !", mesg, buttons & 1 ? "ja" : "nein" ) ;
	ReleaseButtons();

	return buttons & 1 ;
}

# define READYstates	9

/* ------------------------------------------------- GetFullRGBFrame ------- */
int GetFullRGBFrame ( void )
/*
	during digitizing do if we would have ( w = 2 * W, h = H ) :
	
				+--- odd 0 ----+--- even 0 ----+
				+--- odd 1 ----+--- even 1 ----+
				+--- odd 3 ----+--- even 2 ----+
				......

	digitize 2 times with x-offset 0 & W
					
	after that we change it to ( w = W, h = 2 * H ) :

				+--- odd 0  ---+
				+--- even 0 ---+
				+--- odd 1  ---+
				+--- even 1 ---+
				+--- odd 3  ---+
				+--- even 2 ---+
				......
*/
{
	SetToFullSize ( &FullImageBuffer.dst, NULL,
					 2 * MatDigiF.image.w, MatDigiF.image.h, 24 ) ;

	FullImageBuffer.dst.image.data = malloc ( _SizeOf ( &FullImageBuffer.dst.image ) ) ;
	if ( FullImageBuffer.dst.image.data != NULL )
	{
		SignalReady ( 1, READYstates ) ;
		FullImageBuffer.dst.window.w = MatDigiF.image.w ;
	
		LoadMatDigiFLcaData ( 0, DIGyc, &FullZoom, TRUE ) ;

# if 0
		WindowMessage ( "Grab odd" ) ;
# else
		SignalReady ( 2, READYstates ) ;
# endif
		GrabFieldIntoFifo ( TRUE, FIELDodd ) ;
		FullImageBuffer.dst.window.x = 0 ;
# if 0
		WindowMessage ( "Convert odd" ) ;
# else
		SignalReady ( 3, READYstates ) ;
# endif
		BlitRGBWindow ( &FullImageBuffer, &FullZoom ) ;
	
# if 0
		WindowMessage ( "Grab even" ) ;
# else
		SignalReady ( 4, READYstates ) ;
# endif
		GrabFieldIntoFifo ( TRUE, FIELDeven ) ;
		FullImageBuffer.dst.window.x = MatDigiF.image.w ;
# if 0
		WindowMessage ( "Convert even" ) ;
# else
		SignalReady ( 5, READYstates ) ;
# endif
		BlitRGBWindow ( &FullImageBuffer, &FullZoom ) ;

		SignalReady ( 6, READYstates ) ;
	
		LoadActualScreenEyeLca() ;

		SignalReady ( 7, READYstates ) ;

		SetToFullSize ( &FullImageBuffer.dst,
						 FullImageBuffer.dst.image.data,
						 MatDigiF.image.w, 2 * MatDigiF.image.h, 24 ) ;
		return OK ;
	}
	else
	{
		WindowMessage ( "* Speicher voll" ) ;
Tprintf (( "*** malloc fail " )) ;		
		return NOmemory ;	
	}
}


/* ------------------------------------------------- SnapFullPicture ------- */
void SnapFullPicture ( void )
{
	char filename[128] ;
	int  result ;

Tprintf (( "\033H- SnapFullPicture" )) ;		
	
	if ( get_pic_file_name ( NULL, "*.TIF", &SequenceFileFormat, "Bild schreiben" ) )
	{
		SignalReady ( 0, READYstates ) ;
		if ( SequenceFileFormat == TIFformat )
		{
			mouse_busy();
			mouse_on();
			sprintf ( filename, "%s%s", PurePath, LastSel ) ;
Tprintf (( "- schreiben %s\n", filename )) ;		
			if ( GetFullRGBFrame() == OK )
			{
# if 0
				if ( YesOrNo ( "%s schreiben", filename ) )
# endif
				{
					SignalReady ( 8, READYstates ) ;
					if ( ( result = WriteTiffFile ( filename, 
								FullImageBuffer.dst.image.data,
								FullImageBuffer.dst.image.w,
								FullImageBuffer.dst.image.h ) ) != OK )
							WriteError ( result ) ;
					SignalReady ( 9, READYstates ) ;
				}
				free ( FullImageBuffer.dst.image.data ) ;
				FullImageBuffer.dst.image.data = NULL ;
			}
			mouse_off();
			mouse_arrow();
		}
		else
			WindowMessage ( "* Nur TIF m”glich" ) ;
	}
}

/* ------------------------------------------------- ScreenDump ------- */
void ScreenDump ( void )
{
	char filename[128] ;

	if ( get_pic_file_name ( NULL, "*.TGA", &SequenceFileFormat, "Screendump" ) )
	{
		if ( SequenceFileFormat == TGAformat )
		{
			sprintf ( filename, "%s%s", PurePath, LastSel ) ;
			WriteTargaFile ( filename, screen_size.x, screen_size.y, Logbase() ) ;
		}
		else
			WindowMessage ( "* Nur TGA m”glich" ) ;
	}
}

/*------------------------------------ SnapFilmPicture ----------------*/
int SnapFilmPicture ( void )
{
	int frame ;
	TRunMode oldmode ;

	oldmode = RunMode ;
	if ( SequenceEmpty ( &Sequence ) )
	{
		if ( MallocFilm() > 0 )
			frame = 0 ;
		else
			return -1 ;
	}
	else
		frame = Count ;

	NewRunMode ( IDLE ) ;
	
	if ( ( frame = RecordFrame ( &Sequence, frame, GetWaitUntilFrameGrabbed() ) ) >= 0 )
	{
		PositionSequence ( frame | CHANGEDflags ) ;
		Sequence.current = frame++ ;
		PositionSequence ( frame ) ;
	}
		
	if ( oldmode == DIGITIZE )
		NewRunMode ( DIGITIZE ) ;

	return frame ;
}

/*------------------------------------------------- LimitFrame --------*/
int LimitFrame ( int f )
{
	return f < 0 ? 0
				 : f >= Sequence.valid ? Sequence.valid
				 					   : f ;
}


/*------------------------------------------- SwitchToFullDisplay -------*/
void SwitchToFullDisplay ( int frame )
{
	int displayed ;

	if ( ChkAndSetCurrentFrame ( &Sequence, frame ) >= 0 )
	{
		SetDisplaySequenceMode ( FALSE ) ;
		ToolNormal ( IS_DISPLAY ) ;
# if DEBUG
		if ( bit_planes != 16 )
			displayed = frame ;
		else
# endif
			displayed = DisplayCurrentFrame ( &Sequence, &BlitWindow.dst ) ;
		if ( displayed >= 0 )
			SetCounter ( displayed ) ;
	}
}


/*------------------------------------------- SelectNewSmall -------*/
void SelectNewSmall ( int frame )
{
	if ( ChkAndSetCurrentFrame ( &Sequence, frame ) < 0 )
		frame = LimitFrame ( frame ) ;
	SetCounter ( frame ) ;
	MarkActiveFrame ( frame, &BlitWindow.dst ) ;
}


/*------------------------------------ MoveWindow ------------------------*/
void MoveWindow ( void )
{
	TRectangle curr ;

	WindGetCurr ( whandle, curr ) ;
	mouse_flat_hand();

	MoveRubberBox ( &curr ) ;
	SetWindowRectangle ( &curr ) ;
			
	mouse_arrow() ;
}


/*------------------------------------ MoveFilm ------------------------*/
void MoveFilm ( int y0 )
{
	int y, buttons, framebase, frame, lastframe ;
	
	SwitchFilmIconColor ( GREEN ) ;
	mouse_flat_hand();
	mouse_on();

	framebase = Sequence.current ;
	lastframe = -1 ;
	for(;;)
	{
		_vq_mouse ( vdi_handle, &buttons, &dummy, &y ) ;

		if ( buttons == 0 )
			break ;
		if ( y < ToolsTree->ob_y && framebase < Sequence.valid )	/* scroll up	*/
			framebase += 4 ;
		else if ( y > ToolsTree->ob_y + ToolsTree[IS_FILM].ob_height && framebase > 0 )
														/* scroll down	*/
			framebase -= 4 ;
		frame = framebase + ( y0 - y  ) ;
		if ( frame < 0 )
			frame = 0 ;
		if ( frame > Sequence.valid )
			frame = Sequence.valid ;
		if ( frame != lastframe )
		{
			PositionSequence ( frame ) ;
			if ( ToolsVisible )
				StepFilm ( frame > lastframe ) ;
			lastframe = frame ;
		}
		aes_delay ( 0 ) ;
	}

	SwitchFilmIconColor ( LWHITE ) ;
	mouse_off();
	mouse_arrow() ;
}
					

/* ------------------------------------------------- HWok ------- */
bool HWok ( void )
{
	if ( GetDmsdType() != NOdmsd )
	{
		return TRUE ;
	}
	else
	{
		WindowMessage ( "* Kein ScreenEye da !" ) ;
		return FALSE ;
	}
}


/* ------------------------------------------------- MouseButton ------- */
bool MouseButton ( int buttons, int clicks, int x, int y )
{
	int obj ;
	
	if ( clicks )	; /* no warning 	*/

	if ( verbose )
		printf ( "\033H%3d:%3d [%3d:%3d]\033K",
					x, y, ToolsTree->ob_x, ToolsTree->ob_y ) ;

	mouse_off();
	if (   ToolsVisible
		&& ( obj = objc_find ( ToolsTree, 0, 999, x, y ) ) > 0 
		&& ObjectEnabled ( ToolsTree, obj ) )
	{
		if ( verbose )
			printf ( " - obj:%3d", obj ) ;

		if ( obj == GetToolIcon() )
			obj = IS_STOP ;
		switch ( obj )
		{
	case TX_PARAM :	ReleaseButtons();
					ParameterBox();
					break ;

	case IS_ZOOM :	if ( buttons & 2 )
						SetNewZoomCode ( menu_zoom, -1 ) ;
					else
						SetNewZoomCode ( menu_zoom, +1 ) ;
					break ;

# if 0
	case IS_TOOLS : 
# endif
	case TX_CLOSE :	if ( buttons & 2 )	/* quit	*/
					{
						NewRunMode ( IDLE ) ;
						ReleaseButtons();
						kill_digit_windows () ;
						return _app ;
					}
					else				/* close tools	*/
					{
						ToolsVisible = ToolBarOn = FALSE ;
						reset_window ( CurrentStyle ) ;
					}
					break ;

	case IS_M :		if ( buttons & 2 )
						ScreenDump();
					else if ( bit_planes <= 8 )
						RestorePalette();
					break ;

	case IS_PAUSE :	Paused = ToggleTool ( obj ) ;
					CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) ;
					break ;

	case IS_REWIND :ToolSelect ( obj ) ;
					PositionSequence ( 0 ) ;
					ToolNormal ( obj ) ;
					break ;

	case IS_WIND :	ToolSelect ( obj ) ;
					PositionSequence ( Sequence.valid-1 ) ;
					ToolNormal ( obj ) ;
					break ;
# if 0
	case IS_CAMERA:	Fast = ToggleTool ( obj ) ;	/* ???? FAST ICON ???? */
					break ;
# endif

	case IS_DISPLAY:SetDisplaySequenceMode ( ToggleTool ( obj ) ) ;
					break ;

	case IS_SOUND:	SoundOn = ToggleTool ( obj ) ;	/* ???? FAST ICON ???? */
					SetVolume ( 128+Volume, 128-Volume ) ;
					SoundInToOut ( SoundOn ) ;
					break ;

	case IS_RD_DISK :
# if 0
					ToolSelect ( obj ) ;
					SetMaxi ( INVALID ) ;
					LoadFilm();
					ToolNormal ( obj ) ;
					CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) ;
					SetMaxi ( Sequence.valid-1 ) ;
# else
					NewRunMode ( LOADfilm ) ;
# endif
					break ;

	case IS_WR_DISK:
# if 0
					ToolSelect ( obj ) ;
					SaveFilm();
					ToolNormal ( obj ) ;
# else
					NewRunMode ( SAVEfilm ) ;
# endif
					break ;

	case IS_TV : 	if ( ! HWok() )
						break ;
					NewRunMode ( DIGITIZE );
					break ;

	case IS_STOP :	ToolSelect ( obj ) ;
					ReleaseButtons();
					NewRunMode ( IDLE );
					ToolNormal ( obj ) ;
					break ;

	case IS_LSTEP:	ToolSelect ( obj ) ;
					PositionSequence ( Sequence.current - 1 ) ;
					ToolNormal ( obj ) ;
					break ;

	case IS_RSTEP:	ToolSelect ( obj ) ;
					PositionSequence ( Sequence.current + 1 ) ;
					ToolNormal ( obj ) ;
					break ;

	case IS_PHOTO_MAX :
					if ( ! HWok() )
						break ;
					ToolSelect ( obj ) ;
					ReleaseButtons();
					SnapFullPicture();
					ToolNormal ( obj ) ;
					break ;

	case IS_PHOTO :	if ( ! HWok() )
						break ;
					ToolSelect ( obj ) ;
					ReleaseButtons();
					SnapFilmPicture();
					ToolNormal ( obj ) ;
					break ;
# if 0
	case IS_PHOTO :	ToolSelect ( obj ) ;
					ReleaseButtons();
					if ( buttons & 2 )
						SnapFullPicture();
					else
						SnapFilmPicture();
					ToolNormal ( obj ) ;
					break ;
# endif

	case IS_RECORD:	if ( ! HWok() )
						break ;
					ToolSelect ( obj ) ;
					ReleaseButtons();
					if ( SequenceNotEmpty ( &Sequence ) )
						DeleteFilm();
					if ( MallocFilm() > 0 )
					{
						NewRunMode ( RECORD ) ;
					}
					else
					{
						NewRunMode ( IDLE ) ;
						ToolNormal ( obj ) ;
					}
					break ;


	case IS_MIN :	StartEditTextField ( obj, &Mini, buttons & 2 ? Sequence.current : DONTset ) ;			break ;
	case IS_MAX :	StartEditTextField ( obj, &Maxi, buttons & 2 ? Sequence.current : DONTset ) ;			break ;
	case IS_COUNT :	StartEditTextField ( obj, &Count, buttons & 2 ? Sequence.current : DONTset ) ;		break ;
	case IS_PARAM :	StartEditTextField ( obj, &NumXYFields, DONTset ) ;	break ;
	case IS_VOLUME: StartEditTextField ( obj, &Volume, DONTset ) ;		break ;
	case TX_ZOOM :	StartEditTextField ( obj, &ZoomXY, DONTset ) ;		break ;

	case IS_RIGHT:	StartPlayMode ( obj, PLAY_FORWARD, 		+1 ) ;
					break ;
	case IS_LEFT:	StartPlayMode ( obj, PLAY_BACK, 		-1 ) ;
					break ;
	case IS_RIGHT2:	StartPlayMode ( obj, PLAY_FAST_FORWARD, +FASTsteps ) ;
					break ;
	case IS_LEFT2:	StartPlayMode ( obj, PLAY_FAST_BACK, 	-FASTsteps ) ;
					break ;
	case IS_TRASH :	DeleteFilm() ;
					CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) ;
					break ;
	case IS_FILM :	if ( RunMode == IDLE )
						MoveFilm ( y ) ;
					break ;
		}
	}
	else
	{
		if ( PointInsideRectangle ( x, y, &BlitWindow.dst.window ) )
		{
			int frame ;

			if ( DisplaySequenceOn )
			{
				if ( ( frame = FindSmall ( x, y, &BlitWindow.dst.window ) ) >= 0 )
				{
					if ( buttons & 2 )	/* right buttons	*/
						SwitchToFullDisplay ( frame ) ;
					else
						SelectNewSmall ( frame ) ;
				}
				else
					MoveWindow();
			}
			else
			{
				if ( buttons & 2 )
				{
					DrawSequence ( &Sequence, &BlitWindow.dst ) ;
					ToolSelect ( IS_DISPLAY ) ;
				}
				else
					MoveWindow();
			}
		}
		else if ( verbose )
			printf ( " - no obj" ) ;
	}
	mouse_on();
	ReleaseButtons();
	return FALSE ;
}



/* ------------------------------------------------- MouseInfo --------- */
void MouseInfo ( int x, int y )
{
	int obj ;
		
	if ( ToolsVisible && infopos.x != x || infopos.y != y )
	{
		infopos.x = x ;
		infopos.y = y ;
	
		if ( ( obj = objc_find ( ToolsTree, 0, 999, x, y ) ) > 0 )
			UpdateInfo ( GetObjectInfo ( obj ) ) ;
# if 0
		else
			UpdateInfo ( empty_mesg ) ;
# endif
	}
}


/*-------------------------------------------- DigitizeToLiveBox --------*/
void DigitizeToLiveBox ( void )
{
	LiveImageBuffer.src = BlitWindow.src ;
	SetToFullSize ( &FullFrameBuffer.dst,
					NULL,
					BlitWindow.dst.window.w,
					BlitWindow.dst.window.h, 16 ) ;
	if ( ( LiveImageBuffer.dst.image.data = malloc ( _SizeOf ( &LiveImageBuffer.dst.image ) ) ) != NULL )
	{
		DigitiseFrame ( &LiveImageBuffer, &Zoom, GetWaitUntilFrameGrabbed() ) ;
		StretchBlit ( &BlitWindow.dst, &LiveBox ) ;

		free ( FullFrameBuffer.dst.image.data ) ;
		FullFrameBuffer.dst.image.data = NULL ;
	}
}

/* ------------------------------------------------- TimerEvent ------- */
bool TimerEvent ( int x, int y )
{
	int i ;

	switch ( RunMode )
	{
case IDLE :	MouseInfo ( x, y ) ;
			return FALSE ;

case LOADfilm :
			if ( LoadNext() < 0 )
				NewRunMode ( IDLE ) ;
			break ;

case SAVEfilm :
			if ( SaveNext() < 0 )
				NewRunMode ( IDLE ) ;
			break ;

case DIGITIZE :
# if DEBUG
		if ( bit_planes == 16 )
		{
# endif
			if ( DisplaySequenceOn )
			{
				if ( ToolsVisible && ! Fast )
					DigitizeToLiveBox();
			}
			else	/* full screen 	*/
			{
				if ( ( GetVideoSignal() == PUP_AUTO ) || ( GetVideoSource() == PUP_AUTO ) )
					auto_check() ;
				get_picture ( TRUE ) ;
				if ( ToolsVisible && ! Fast )
					StretchBlit ( &BlitWindow.dst, &LiveBox ) ;
			}
# if DEBUG
		}
		else
		{
			if ( ! DisplaySequenceOn )
				get_picture ( TRUE ) ;
		}
# endif
		break ;

case RECORD :
		if ( ( i = RecordCurrFrame ( &Sequence, GetWaitUntilFrameGrabbed() ) ) >= 0 )
		{
			if ( !Fast )
			{
				SetCounter ( i ) ;
# if DEBUG
				if ( bit_planes == 16 && ToolsVisible )
# else
				if ( ToolsVisible )
# endif
					StretchBlit ( &Sequence.blitwind.dst, &LiveBox ) ;
			}
		}
		else
			NewRunMode ( IDLE ) ;
		break ;

case PLAY_FORWARD :
case PLAY_BACK:
		switch ( PlaySyncCurrent ( &Sequence ) )
		{
	case SEQend	:
			NewRunMode ( IDLE ) ;
			break ;
	case SEQnotSynced :
			return TRUE ;
		}
		/* 	continue ;	*/

case PLAY_FAST_FORWARD :
case PLAY_FAST_BACK :
# if DEBUG
		if ( bit_planes != 16 )
		{
			i = Sequence.current ;
			if ( i >= Sequence.valid )
				i = -1 ;
		}
		else
# endif
			i = DisplayCurrentFrame ( &Sequence, &BlitWindow.dst ) ;
		if ( i >= 0 )
		{
			if ( !Fast )
				SetCounter ( i ) ;
			Sequence.current += Step ;
		}
		else
			NewRunMode ( IDLE ) ;
		break ;
	}
	return TRUE ;
}

										
/* ------------------------------------------------- event_loop ------- */
void event_loop ( void )
{
	int x, y,
		kstate,
		key,
		clicks,
		event, chkevent,
		last_buttons, buttons ;
	int pipe[8];
	int quit;
	int	mevt1, mevt2 ;
	int loop_delay ;	/* msec	*/
	
	last_buttons = 0 ;
	mevt1 = 0 ;
	mevt2 = 0 ;
	quit = 0 ;
	loop_delay = GetLoopDelay() ;

	TprintfK (( "* event_loop" )) ;

	if ( whandle >= 0 )
	{
	   	chkevent = MU_M1 | MU_MESAG | MU_KEYBD | MU_TIMER | MU_BUTTON ;
		if ( ToolsVisible )
			chkevent |= MU_M2 ;
	}
	else
	   	chkevent = MU_MESAG | MU_TIMER ;

	do
	{
    	event = evnt_multi ( chkevent,
				 1, 1, 1,
				 mevt1,
				 BlitWindow.dst.window.x,
				 BlitWindow.dst.window.y,
				 BlitWindow.dst.window.w,
				 BlitWindow.dst.window.h,
				 mevt2,
				 ToolsTree->ob_x, ToolsTree->ob_y,
				 ToolsTree->ob_width, ToolsTree->ob_height,
				 pipe,
				 loop_delay, 0,
				 &x, &y, &buttons, &kstate, &key, &clicks );

		wind_update ( BEG_UPDATE ) ;

		evnt_button ( 0, 0, 0, &dummy, &dummy, &buttons, &dummy ) ;
		if ( ~last_buttons & buttons & 2 )
			event |= MU_BUTTON ;
		last_buttons = buttons ;

		if ( event & MU_TIMER && ( whandle >= 0 ) )
		{
			if ( ! Paused && TimerEvent ( x, y ) && !Fast && ToolsVisible )
				StepFilm ( Step >= 0 ) ;

   			if ( event == MU_TIMER )	/* only timer event	*/
   			{
   				wind_update ( END_UPDATE ) ;
   				continue ;
   			}
		}

		if ( event & MU_BUTTON )
			quit = MouseButton ( buttons, clicks, x, y ) ;
		
		if ( event & MU_MESAG )
			quit = handle_message ( pipe );
		else
			old_msg = 0 ;

		if ( event & MU_KEYBD )
			quit = digit_keyboard ( key ) ;

		if ( event & MU_M1 && ! Paused && RunMode != IDLE )
		{
			if ( mevt1 )		/* 1 = -> out		*/
			{
				mouse_on();
				mevt1 = 0 ;
			}
			else 				/* 0 = -> in		*/
			{
				mouse_off() ;
				mevt1 = 1 ;
			}
		}

		if ( event & MU_M2 )
		{
			if ( mevt2 )			/* 1 = -> out		*/
			{
				mouse_arrow();
				mevt2 = 0 ;
			}
			else 					/* 0 = -> in		*/
			{
				mouse_point_hand() ;
				mevt2 = 1 ;
			}
		}

		if ( mevt1 && ( Paused || RunMode == IDLE ) )
		{
			mouse_on();
			mevt1 = 0 ;
		}

      	wind_update ( END_UPDATE ) ;


		loop_delay = GetLoopDelay();

		if ( whandle >= 0 )
		{
		   	chkevent = MU_M1 | MU_MESAG | MU_KEYBD | MU_TIMER | MU_BUTTON ;
	   		if ( ToolsVisible )
				chkevent |= MU_M2 ;
		}
		else	/* window closed	*/
		{
		   	chkevent = MU_MESAG | MU_TIMER ;
			if ( MouseCount == 0 )
				mouse_on();
		}

		if ( end_program )
		{
			kill_digit_windows () ;
        	quit = _app ;
        }
	}
   	while ( !quit );
	mouse_on();
}


/* ----------------------------------------------- init_vars ------ */
void init_vars ( void )
{
	InitSequence ( &Sequence ) ;

	end_program = 0 ;
	verbose = 0 ;
	whandle = -1 ;
	SetVideoSignal ( PUP_AUTO ) ;
	SetVideoSource ( DEFsource ) ;

	whandle = -1 ;
	RunMode = _app ? DIGITIZE : IDLE ;
	madi_ok = 0 ;
# if 0
	head_y = 32 ;
	border_x = 12 ;
# else
	tail_y = 0 ;
	realtime_tail_y = 64 ;
	head_y = 2 ;
	border_x    = 12 ;
	border_left = 8 ;
	SetWaitUntilFrameGrabbed ( FALSE ) ;
# endif
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

# if 1
# define WindowMessage	DebugWindowMessage
int line = 999 ;
/*--------------------------------------------- WindowMessage -----*/
int WindowMessage ( const char *newtitle, ... )
{
	if ( line++ > 24 )
	{
		printf ( "\033H\033K" ) ;
		line = 0 ;
	}
	printf ( newtitle, (va_list)... ) ;
	printf ( "\n\033K" ) ;
	return 1 ;
}
# endif

/* ---------------------------------------------------- main ------ */
void main ( void ){
	int i ;
	int work_in[11] ;
	int work_out[57] ;
	long vcookie_name = 0x5F56444FL ; /* = "_VDO" */
	long ccookie_name = 0x5F435055L ; /* = "_CPU" */
	long fcookie_name = 0x5F465242L ; /* = "_FRB" */
	long old_super_stack ;

	Tprintf (( "\033H* ScreenEye " __DATE__ " / " __TIME__ )) ;

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

		Tprintf (( ">>> GetScreenEyeParameter()" )) ;

		if ( GetScreenEyeParameter() != OK )
		{
			if ( ScreenEyeParameter == NULL )
				form_alert ( 1, get_free_string ( AL_SDNINST ) ) ;
			else
				form_alert ( 1, get_free_string ( AL_SDILVER ) ) ;
			exit ( 0 ) ;
		}
# if TEST
		else
		{
			printf ( ">>> %s\n", ScreenEyeParameter->copyright ) ;
			PressAnyKey();
	 	}
# endif

# if DEBUG
		if ( ( *(ScreenEyeParameter->verbose) & 0xf000 ) == 0x8000 )
		{
			printf ( "- debug mode\n" ) ;
			*(ScreenEyeParameter->verbose) &= ~0x8000 ;
			Debug = 1 ;
		}
# endif

		if ( rsrc_load ( RSC_NAME ) != 0 )
		{
			atexit ( free_rsrc ) ;
			if ( _app == 0 )				/* = ACC */
				menu_id = menu_register ( appl_id, "  ScreenEye" ) ;

			TprintfK (( ">>> init vars" )) ;
			init_vars () ;
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

				uprintf = WindowMessage ;

				TprintfK (( ">>> check bit planes" )) ;
# if DEBUG
				if ( bit_planes >= 8 || Debug )
				{
# else
				if ( bit_planes >= 8 )
				{
# endif
					if ( bit_planes == 8 )
						form_alert ( 1, "[1][| ScreenEye l„uft in dieser | Version mit 256 Farben | nur eingeschr„nkt ! ][ Ok ]");
	
					InitBlitProcTable();

					wind_get ( 0, WF_WORKXYWH, &DeskTop.x, &DeskTop.y,
										   &DeskTop.w, &DeskTop.h );
					ToolBarInit();
					SetToolNumber ( IS_MAX, Maxi ) ;
					SetToolNumber ( IS_PARAM, NumXYFields ) ;
					set_film_name ( "" ) ;

# if 0
					if ( GetDmsdType() == NOdmsd || bit_planes != 16 )
					{
						ObjectSetState ( ToolsTree, IS_RECORD, DISABLED ) ;
						ObjectSetState ( ToolsTree, IS_TV, DISABLED ) ;
						ObjectSetState ( ToolsTree, IS_PHOTO, DISABLED ) ;
						ObjectSetState ( ToolsTree, IS_PHOTO_MAX, DISABLED ) ;
					}
# endif
					TprintfK (( ">>> init window vars" )) ;

					menu_zoom = bit_planes > 8 ? Z42 : Z22 ;
					Zoom = ZoomTable [menu_zoom] ;

					madi_ok = GetDmsdType() != NOdmsd
								&& LoadMatDigiFLcaData ( GetDmsdType(), DIGcolor, &Zoom, TRUE ) == 0 ;

					if ( madi_ok )
						madi_ok = InitMdf ( PUP_CVBS, 1, GetDmsdType() ) ;
					else
						printf ( "- Fehler bei Initialisierung ScreenEye\n" ) ;

					SetToFullSize ( &MatDigiF, NULL,
									 GetDmsdType() == 7191 ? DIGdx7191 : DIGdx9051,
									 DIGdyF, 16 ) ;

					ResetBlitWindow ( &BlitWindow, &Zoom ) ;
					ZoomXY = Zoom.x * 10 + Zoom.y ;

					FullFrameBuffer.dst = FullFrameBuffer.src = MatDigiF ;

					FullImageBuffer = FullFrameBuffer ;
					LiveImageBuffer = FullFrameBuffer ;

					FullFrameBuffer.dst.image.data = malloc ( _SizeOf ( &FullFrameBuffer.dst.image ) ) ;
					
					aes_delay ( INIT_DELAY ) ;

					init_menus () ;
					chk_buttons () ;

# if DEBUG
					if ( bit_planes != 16 || ! madi_ok )
# else
					if ( ! madi_ok )
# endif
						RunMode = IDLE ;
				

					if ( bit_planes < 16 )
					{
						init_palette() ;
						UpdatePalette() ;
					}
				  	
					if ( RunMode == DIGITIZE )
					{
						ObjectSetState ( ToolsTree, IS_TV, SELECTED ) ;
						UpdatePalette();
					}

					TprintfK (( ">>> start operation" )) ;

					ScreenBufferSize = (long)screen_size.x * (long)screen_size.y
									/ 8L * (long)bit_planes ;
					ScreenBuffer = malloc ( ScreenBufferSize ) ;

					if ( _app )			/* = PRG */
					{
						mouse_arrow() ;
	TprintfK (( ">>> open_window" )) ;
		    			open_window() ;
	TprintfK (( ">>> check_display_pop" )) ;
						check_display_pop ( bit_planes ) ;
					}

					event_loop ();
					if ( ScreenBuffer != NULL )
						free ( ScreenBuffer ) ;
					RestorePalette();
# if DEBUG
					if ( Debug )
						*(ScreenEyeParameter->verbose) |= 0x8000 ;
# endif
				}
				else
				{
					form_alert ( 1, get_free_string ( AL_NOT16BPP ) ) ;
					acc_stop () ;
				}

				v_clsvwk ( vdi_handle );

			} /* vdi_handle != 0 */
		} /* resource file loaded */
		else
		{	/* resource file not found - English message */
			form_alert ( 1, "[1][| ScreenEye Error | Resource file | "RSC_NAME" | not found! ][ Abort ]");
			acc_stop () ;
		}
	} /* appl_id >= 0  .... application registered */

	exit ( 0 ) ;
}

