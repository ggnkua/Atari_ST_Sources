/* matdigif.c */

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <ctype.h>
# include <tos.h>
# include <linea.h>
# include <portab.h>
# include <ext.h>

# include <global.h>
# include <sys_vars.h>
# include <scancode.h>
# include <picfiles.h>
# include "yc.h"
# include "yc_fast.h"
# include <fast.h>
# include "tools.h"

#include <vdi.h>
#include "d:\pc\app\jpeg_dsp\if\jpgdh.h"
#include "d:\pc\app\jpeg_dsp\if\if.h"

# include "digiblit.h"
# include "digitise.h"
# define HIDEfunctions
# include "screyeif.h"
# include "initdmsd.h"
# include "digiblix.h"
# include "digitisx.h"
# include "film.h"
# include "filmx.h"
# include "stretch.h"
# include "draw_555.h"
# include "mdf_if.h"
# include "mdf_lca.h"
# include "mdf_lcax.h"

# include "..\screen.eye\palette.h"


# define JPEGfileName "..\\jpeg_dsp\\images\\amick-00.jpg"

char fnbuffer[128] = JPEGfileName /* "test.yc" */ ;

# define FIRSTcolor	0

uword *BackGroundBuffer = NULL ;
uword *SaveBuffer   	= NULL ;
long  ScreenPixels ;

TImage ScreenImage ;

unsigned char *GreyBuffer = NULL ;

# define _Plus()	( DmsdType == 7191 )

# define ImageSize(img)	((long)img.h * (long)img.bpl)
# define ScreenSize()	ImageSize(ScreenImage)

# define _SaveScreen(b) 	memcpy ( b, 			   ScreenImage.data,  ScreenSize() )
# define _RestoreScreen(b) 	memcpy ( ScreenImage.data, b, 		 		  ScreenSize() )

int	CurrentYCcoeff[] = DEFAULTycCoeff ;
char *CoeffName[] = { "cr -> r", "cr -> g", "cb -> g", "cb -> b" } ;

bool Continuous = FALSE ;
bool AutoSave   = FALSE ;   

unsigned FrameCount = 0 ;

typedef void (*TDigitiseFunction) ( TBlitWindow *blitwind, POINT *zoom ) ;
TDigitiseFunction DigitiseFunction = Blit555Window ;

SEQUENCE 	Sequence ;
TBlitWindow BlitWindow ;
POINT 		Zoom = { 1, 1 } ;


char *MdfHelpTable[] =
{
	"Grab",
		"' ' - start / stop digitising\n"	
		"*   - toggle mode Continuous/Single\n"	
		"\n"
		"g   - grab grey\n"
		"c   - grab color 5:5:5, hw conversion\n"
		"      f8 : 332 rgb palette\n"
		"Y   - grab color f8 : 224/233 yuv palette\n"
		"s   - grab color 5:5:5, sw conversion\n"
		"h   - grab color 5:5:5, hw simulation\n"
		"N   - toggle grab before display on / off\n"
		"U   - toggle wait until grabbed on / off\n"
		"i   - window info\n"
		"!   - pixel info\n",

	"Sequence",
		":r  - read film\n"
		":w  - write film\n"
		":r  - free sequence\n"
		":i  - Info\n"
		"\n"
		"F6  - Info\n"
		"F7  - Record / Play loop\n"
		"F8  - Record\n"
		"F9  - Play\n",

	"Buffer",
		")   - save screen to background buffer\n"
		"(   - restore screen from background buffer\n"
		">   - save screen to save buffer\n"
		"<   - restore screen from save buffer\n"
		"a   - toggle auto save/restore switch\n"
		"=   - compare screen with buffer\n",

	"Window / current parameter values",
		"cursor - change\n"	
		"S      - set to source\n"	
		"D      - set to destination\n"	
		"S      - set to dimension ( width / height )\n"
		"Home   - reset all\n"
		"\n"
		"x+/-   - zoom factor x +-1\n"
		"y+/-   - zoom factor y +-1\n",
	
	"File",
		"j    - display jpeg file : " JPEGfileName "\n"
		"f    - set file name\n"
		"Fg/c - display file grey / color\n",
	
	"Histogramm",
		"H   - histogramm, sub commands :\n"
		"   y    -   Y\n"
		"   u    -   Uhisto\n"
		"   v    -   Vhisto\n"
		"   c    -   R,G,B\n"
		"   0..3 -   UD,VD 4:1:1 data byte parts\n",

	"Special",
		"I    - InitDmsd\n"
		"$    - change DMSD parameter\n"
		"V    - Set LCA - version ? >\n"
		"m    - Get YC -> RGB matrix\n"
		"o    - Toogle YC -> RGB conversion clipping switch\n"
		"0..5 - Set test variable\n"
		"Gg/c - grey tab : pure grey/with colors(n=32/96)\n"
		"7/9  - Set dmsd type 7191 / 9051 and reinit\n"
		"w    - write ctrlreg\n"
		"r    - read ctrlreg\n"
		"~	  - TestRun\n",
	
	"System",
		"v    - set verbose\n"
		".    - Clear Screen\n"
		"?    - help\n"
		"q    - quit\n",
	
	NULL
} ;


/*--------------------------------------------- H16Line332 -----*/
word *H16Line332 ( word *p, unsigned color, unsigned xn )
{
	unsigned plane, x ;
	
	for ( x = 0 ; x < xn; x++ )
	{
		for ( plane = 0; plane < 8; plane++ )
			*p++ = ( color & (1<<plane) ) ? 0xffff : 0x0000 ;
	}
	return p ;
}

/*------------------------------------------- ImagePixelPosition ---*/
void *ImagePixelPosition ( TImage *image, int x, int y )
{
	return (void *) (((long)image->data)
						+ (long)y * (long)image->bpl
						+ (long) iscale ( x, image->planes, 8 ) ) ;
}


/*--------------------------------------------- Fill332Rect -----*/
void Fill332Rect ( unsigned color, int x0, int y0, int x1, int y1 )
{
	int y, x16 ;

	x0 &= ~15 ;
	x16 = ( x1 - x0 ) / 16 ; ;
	
	for ( y = y0; y<=y1; y++ )
		H16Line332 ( ImagePixelPosition ( &ScreenImage, x0, y ), color, x16 ) ;
}

# define _Col332(r,g,b) (((r)<<5)|((g)<<2)|(b))	

/*--------------------------------------------- Rgb332Run -----*/
void Rgb332Run ( int color )
/*		640 pixels = 640 bytes = 320 Worte = 40 * 8 Worte
		16 pixel / block * 8 colors = 128 blocks / color run
480
*/
{
	int r, y ;
	word *p ;

	p = ScreenImage.data ;
	Fill332Rect ( color, 0, 0, 640, 480/4 ) ;

	p = ImagePixelPosition ( &ScreenImage, 0, 480/4 ) ;

	/* red run	*/
	for ( y = 0; y < 480/4; y++ )
	{
		for ( r = 0; r < 8 ; r++ )
			p = H16Line332 ( p, r << 5, 5 ) ;
	}
	
	/* green run	*/
	for ( y = 0; y < 480/4; y++ )
	{
		for ( r = 0; r < 8 ; r++ )
			p = H16Line332 ( p, r << 2, 5 ) ;
	}
	/* blue run	*/
	for ( y = 0; y < 480/4; y++ )
	{
		for ( r = 0; r < 8 ; r++ )
			p = H16Line332 ( p, r >> 1, 5 ) ;
	}
}

int colormax[] = { 7, 7, 3 } ;

static void Digitise ( TBlitWindow *blitwind, POINT *zoom ) ;

# define _tbit(v,b)	((v&b)?1:0)

/*--------------------------------------------- GetColor332 -------*/
int GetColor332 ( int x, int y )
{
	int color, plane, bitmsk ;
	word *p ;
	
	bitmsk = 1 << ( 15 - ( x & 15 ) ) ;
	p = ImagePixelPosition ( &ScreenImage, x & ~15, y ) ;
	color = 0 ;
	for ( plane = 0; plane < 8; plane++ )
		if ( *p++ & bitmsk )
			color |= 1 << plane ;
	return color ;
}

/*--------------------------------------------- fprcolor -------*/
void fprcolor ( FILE *ofi, char *ss, int color, char *se )
{
# if 0
	fprintf ( ofi, "rgb = %d%d%d %d%d %d%d\n", 
		_tbit(r&4), _tbit(r&2), _tbit(r&1),
		_tbit(g&4), _tbit(g&2), _tbit(g&1),
		_tbit(b&2), _tbit(b&1)  ) ;
# else
	fprintf ( ofi, "%s", ss ) ;
	fprintf ( ofi, "%d%d%d %d%d%d %d%d", 
		_tbit(color,0x80),
		_tbit(color,0x40),
		_tbit(color,0x20),
		_tbit(color,0x10),
		_tbit(color,0x08),
		_tbit(color,0x04),
		_tbit(color,0x02),
		_tbit(color,0x01) ) ;
	fprintf ( ofi, "%s", se ) ;
# endif
}

/*--------------------------------------------- TestSequence -------*/
void TestSequence ( void )
{
	int base, rgb, y, r, g, b, color ;
	FILE *ofi ;
	
	ofi = fopen ( "0TEST.C", "w" ) ;
	if ( ofi == NULL )
		return ;
	for ( base = 0; base < 3; base++ )
	{
		for ( rgb = 0; rgb <= colormax[base]; rgb++ )
		{
			r = g = b = 0 ;
			switch ( base )
			{
	   case 0 :	r = rgb ;	break ;
	   case 1 :	g = rgb ;	break ;
	   case 2 :	b = rgb ;	break ;
			}

	   		color = _Col332(r,g,b) ;

			Rgb332Run ( color ) ;
			Digitise ( &BlitWindow, &Zoom );
			fprintf ( ofi, "\nrgb = %d %d %d\n", r, g, b ) ;
			fprcolor ( ofi, "colmsk = ", color, "\n" ) ;
			for ( y = 10; y < 15; y++ )
				fprcolor ( ofi, "digit  = ", GetColor332(64,y), "\n" ) ;
		}
	}
	fclose ( ofi ) ;
}


/*--------------------------------------------- HistoGramm -------*/
void HistoGramm ( void )
{
	printf ( "\033E* Histogramm  y u v 0 1 2 3 c d / g . ? >" ) ;
	switch ( get_cmdin_char() ) 
	{
case '.' :	printf ( "\033E" ) ;
			break ;
case 'g' :	printf ( "\033EGreyBuffer :\n" ) ;
			DumpBuffer ( GreyBuffer, ScreenPixels ) ;
			break ;
case 'd' :  printf ( "\033H" ) ;
			ShowHisto ( 'D', YDhisto, 255 ) ;
# if 0
			printf ( "\nSumDelta = %lu = %f / pixel\n", SumDelta, (float)SumDelta/(float)NDelta ) ;
# else
			printf ( "\nSumDelta = %lu = %lu / 100 pixel\n", SumDelta, SumDelta/(NDelta/100) ) ;
# endif
			break ;
case 'y' :  printf ( "\033H" ) ;
			ShowHisto ( 'Y', Yhisto, 255 ) ;
			break ;
case 'u' :  printf ( "\033H" ) ;
			ShowHisto ( 'U', Uhisto, 255 ) ;
			break ;
case 'v' :  printf ( "\033H" ) ;
			ShowHisto ( 'V', Vhisto, 255 ) ;
			break ;
case 'c' :  printf ( "\033H" ) ;
			ShowHisto ( 'R', Rhisto, 32 ) ;
			ShowHisto ( 'G', Ghisto, 32 ) ;
			ShowHisto ( 'B', Bhisto, 32 ) ;
			break ;
case '0' :
case '1' :
case '2' :
case '3' :  printf ( "\033HUd\n" ) ;
			ShowHisto ( '0', UDhisto[0], 3 ) ;
			ShowHisto ( '1', UDhisto[1], 3 ) ;
			ShowHisto ( '2', UDhisto[2], 3 ) ;
			ShowHisto ( '3', UDhisto[3], 3 ) ;
			printf ( "Vd\n" ) ;
			ShowHisto ( '0', VDhisto[0], 3 ) ;
			ShowHisto ( '1', VDhisto[1], 3 ) ;
			ShowHisto ( '2', VDhisto[2], 3 ) ;
			ShowHisto ( '3', VDhisto[3], 3 ) ;
			break ;
	}
}



/*--------------------------------------------- ResetDigiImages ------*/
void ResetDigiImages ( TBlitWindow *blitwind )
{
	SetToFullSize ( &blitwind->src, NULL, _Plus() ? DIGdx7191 : DIGdx9051, DIGdyF, 16 ) ;
	SetToFullSize ( &blitwind->dst, ScreenImage.data, ScreenImage.w, ScreenImage.h, ScreenImage.planes ) ;
}


/*----------------------------------------- ChangeDmsdParameter ----*/
bool ChangeDmsdParameter ( unsigned chip )
{
	char 	 buffer[128] ;
	int 	 oldval, newval ;
	unsigned regnum ;
	
	printf ( "\033H\033K- DMSD%u : register [ nn/0xhh ] ? >", chip ) ;
	gets ( buffer ) ;
	if ( buffer[0] != 0 )
	{
		regnum = (unsigned)strtol ( buffer, NULL, 0 ) ;
		if ( ( oldval = GetSetDmsdRegister ( regnum, -1 ) ) >= 0 )
		{
			printf ( "DMSD register %u=$%02x == $%02x ? >",
							 regnum, regnum, oldval ) ;
			gets ( buffer ) ;
			if ( buffer[0] != 0 )
			{
				newval = (int)strtol ( buffer, NULL, 0 ) ;
				if ( GetSetDmsdRegister ( regnum, newval ) >= 0 )
					return TRUE ;
				else
					printf ( "- error !\n" ) ;
			}			
			else
				printf ( "- not changed !\n" ) ;
		}
		else
			printf( "* can't access register %u=$%02x\n", regnum, regnum ) ;
	}
	else
		printf ( "- no register !\n" ) ;
	return FALSE ;
}

/*--------------------------------------------- CheckF8 -----------*/
void CheckF8 ( TBlitWindow *blitwind )
{
	if (  Linea->v_planes < 16 )
		blitwind->src.window.w = blitwind->dst.window.w &= ~15 ;
}


/*--------------------------------------------- ResetBlitWindow ------*/
void ResetBlitWindow ( TBlitWindow *blitwind, POINT *zoom )
{
	ResetDigiImages ( blitwind ) ;
	ResetDigiWindows ( blitwind ) ;
	zoom->x = zoom->y = 1 ;

	if ( verbose )
		BlitWindowInfo ( blitwind ) ;
}

	
/*----------------------------------------- SetDigitiserMode -------*/
void SetDigitiserMode ( TDigitiseFunction digfct, TDigitiserMode mode, POINT *zoom )
{
	DigitiseFunction = digfct ;
# if 0
	LoadMdfLcaFile ( CurrentLcaType, LcaVersion, LcaRelease ) ;
# else
	LoadMatDigiFLcaData ( DmsdType, mode, zoom, TRUE ) ;
# endif
}

/*--------------------------------------------- Digitise -----------*/
void Digitise ( TBlitWindow *blitwind, POINT *zoom )
{
	int result ;
	unsigned startframe, frames ;
	long starttime, usedtime, msperframe ;

	if ( verbose )
	{
		startframe = FrameCount ;
		starttime =	get_lcont(_hz_200) ;
	}
	do
	{
		if ( verbose )
		{
			StatusLine();
			printf ( "frame : %d", ++FrameCount ) ;
		}
		if ( GrabBeforeDisplay )
		{
			if ( ( result = GrabFieldIntoFifo ( WaitUntilGrabbed, FIELDnext ) ) != 0 )
			{
				printf ( " * error : %d", result ) ;
				return ;
			}
		}
		else
			ResetGrabber() ;

		(*DigitiseFunction) ( blitwind, zoom ) ;

		if ( verbose )
			printf ( "* stop\n" ) ;
	}
	while ( Continue ( &Continuous ) ) ;
	
	if ( verbose )
	{
		usedtime = get_lcont(_hz_200) - starttime ;
		frames = FrameCount - startframe ;
		msperframe = ( usedtime * 5 ) / (long)frames ;
		if ( frames > 0 )
			printf ( "ms / frame = %ld, F = %ld mHz\n", msperframe, 1000000L / msperframe ) ;
	}
	
	if ( AutoSave )
		_SaveScreen ( BackGroundBuffer ) ;
# if CHKrgbRange
	if ( DigitiseFunction == Blit555HWSimWindow )
	{
		printf ( "\033H%6lu%6lu%6lu%6lu%6lu%6lu\n",
			RgbUnder[0], RgbOver[0],
			RgbUnder[1], RgbOver[1],
			RgbUnder[2], RgbOver[2] ) ;
	}
# endif
}


# define CASE(c,s)	case c : s ; break

extern int yctof8_format[] ;	/* s. yc_fast.s, palette.c	*/

/*--------------------------------------------- PressAnyKey -------*/
void PressAnyKey ( char *txt )
{
	printf ( "\033H- %s, press any key !", txt ) ;
	getch();
}

/*... DSP JPEG IF ...*/

#define	unused(x)	(x)=(x)

/*------------------------------------------------------ printfnl --------*/
int printfnl ( const char *format, ... )
{
	int l ;
	
	l = vprintf ( format, (va_list)... ) ;
	l += printf ( "\n" ) ;

	return l ;
}

/*------------------------------------------------------ UserRoutine -----*/
short UserRoutine ( JPGD_PTR jpgd )
{
	unused(jpgd);
	if ( ( ++(jpgd->User[0]) % 32 ) == 0 )
	{
		Cconout('\r');
		Cconout('\n');
	}
	Cconout('.');
	return 0 ;
}


/*------------------------------------------ DisplayJpegFile -------*/
void DisplayJpegFile ( char *filename )
{
	ERROR err ;
  	long outsize ;
	MFDB mfdb ;
	TBlitWindow blitwind ;

/*
	err = JpegDecodeToMemory ( filename, RGBout, ScreenImage.planes/8, &mfdb, &outsize ) ;
*/
	err = JpegDecodeToMemory ( filename, RGBout, 2, &mfdb, &outsize ) ;
	if ( err == OK )
	{
		printf ( "mfdb = $%p - %d:%d,  ww=%d, std=%d, planes=%d\n",
							mfdb.fd_addr,
							mfdb.fd_w,
							mfdb.fd_h,
							mfdb.fd_wdwidth,
							mfdb.fd_stand,
							mfdb.fd_nplanes ) ;

		if ( mfdb.fd_nplanes == ScreenImage.planes )
		{
# if 1
			SetToFullSize ( &blitwind.src, mfdb.fd_addr, mfdb.fd_wdwidth, mfdb.fd_h, mfdb.fd_nplanes ) ;
# else
			SetToFullSize ( &blitwind.src, mfdb.fd_addr, mfdb.fd_w, mfdb.fd_h, mfdb.fd_nplanes ) ;
# endif
			SetToFullSize ( &blitwind.dst, ScreenImage.data, ScreenImage.w, ScreenImage.h, ScreenImage.planes ) ;
  			
			BlitFullSourceWindow ( &blitwind.src, &blitwind.dst ) ;
		}
		else
			printf ( "error : planes %d -> %d\n", mfdb.fd_nplanes, ScreenImage.planes ) ;
		
		free ( mfdb.fd_addr ) ;
	}
	else
		printf ( "jpeg error #%d : %s\n", err, GetJpegErrorText ( err ) ) ;
}

char FilmName[128] ;

/*-------------------------------------------- GetFilmName --------*/
bool GetFilmName ( void )
{
	printf ( "- film name [ d:\..\abcd ] ? >" ) ;
	gets ( FilmName ) ;
	return FilmName[0] > ' ' ;
}

/*--------------------------------------------- command_loop -------*/
void command_loop ( char *filename )
{
	unsigned cmd ;
	bool stop, changed ;
	int	 i, frames ;
	char buffer[128] ;
	long val ;
	int *px, *py, *pz ;	/* points to current values to be modified by cursor keys	*/

	InitSequence ( &Sequence ) ;
	
	px = &BlitWindow.src.window.x ;
	py = &BlitWindow.src.window.y ;
	
# if 0
	SetDmsdType ( AnyShiftPressed() ? ALTdmsdType : DEFdmsdType,
						LCAtypColor ) ;
# else
	DmsdType = CheckScreenEyeHardware();
	printf ( "DMSD = %u\n", DmsdType ) ;
	InitDmsd ( DmsdType ) ;
	ResetDigiImages ( &BlitWindow ) ;
	CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
	CheckF8 ( &BlitWindow ) ;
# endif
	ResetBlitWindow ( &BlitWindow, &Zoom ) ;

	switch ( Linea->v_planes )
	{
 case  8 :	if ( _Plus() )
# if 0
				SetDigitiserMode ( BlitP8GreyWindow, DIGgrey8, &Zoom ) ;
# else
				SetDigitiserMode ( BlitP8ColorWindow, DIGcolor8, &Zoom ) ;
# endif
			else
				SetDigitiserMode ( BlitF332Window, DIGcolor, &Zoom ) ;
			break ;
 case 16 :	SetDigitiserMode ( Blit555Window, DIGcolor, &Zoom ) ;
 			break ;
 default :	printf ( "- illegal plane # : %d\n", Linea->v_planes ) ;
 			return ;
	}

	for ( stop = FALSE ; ! stop ; )
	{
/*
			SetCrs(17) ;
*/
/*
			SkipInput() ;
*/
			cmd = get_cmdin_char() ;
			switch ( cmd )
			{
	case '.' :	printf ( "\033E" ) ;
				break ;
# if 0
	case '9' :
	case '7' :	SetDmsdType ( cmd == '7' ? 7191 : 9051, CurrentLcaType ) ;
				ResetDigiImages ( &BlitWindow ) ;
				CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
				CheckF8 ( &BlitWindow ) ;
				break ;
# endif
	case '$' :  if ( ChangeDmsdParameter ( DmsdType ) )
					LoadDmsdRegister() ;
				break ;

	case 'm' :	changed = FALSE ;
				for ( i = Kcrr; i <= Kcbb; i++ )
					if ( GetInt ( CoeffName[i], &CurrentYCcoeff[i], DefaultYCcoeff[i] ) )
						changed = TRUE ;
				if ( changed )
					CalcCSCtables ( CurrentYCcoeff ) ;
				break ;
				
	case 'x' :	pz = &Zoom.x ;
				goto chgzoom ;
	case 'y' :	pz = &Zoom.y ;
	   chgzoom:	switch ( get_cmdin_char() )
				{
		case '+' :	(*pz)++ ;
					break ;
		case '-' :	if ( *pz > 1 )
						(*pz)-- ;
					break ;
				}
				StatusLine();
				printf ( "zoom x:y= %d:%d", Zoom.x, Zoom.y ) ;
				ResetDigiImages ( &BlitWindow ) ;
				CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
				CheckF8 ( &BlitWindow ) ;
				break ;

	case 'z' :	switch ( Zoom.x )
				{
		case 1 :	Zoom.y = 1 ;	Zoom.x++ ;		break ;
		case 2 :	Zoom.y = 2 ;	Zoom.x++ ;		break ;
		case 3 :	Zoom.y = 3 ;	Zoom.x++ ;		break ;
		default :	Zoom.y = 1 ;	Zoom.x = 1 ;
				
					BlitWindow.dst.window.w = ScreenImage.w;
					BlitWindow.dst.window.h = ScreenImage.h;
					BlitWindow.dst.window.x = 0;
					BlitWindow.dst.window.y = 0;
					break ;
				}
				if ( Linea->v_planes == 8 )
				{
		  			SetDigitiserMode ( BlitP8ColorWindow, DIGgrey8, &Zoom ) ;
					set_phys_palette ( CLUTgrey7Base, CLUTgrey7Base+127, clut_grey7 ) ;
				}				
				else
					SetDigitiserMode ( Blit555Window, DIGcolor, &Zoom ) ;
				CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
				CheckF8 ( &BlitWindow ) ;
				do
				{
					Digitise ( &BlitWindow, &Zoom );
				} while (!kbhit());
				break ;
				
	case 'Z' :	Zoom.x = 1 ;
				Zoom.y = 1 ;
				BlitWindow.dst.window.w = ScreenImage.w;
				BlitWindow.dst.window.h = ScreenImage.h;
				BlitWindow.dst.window.x = 0;
				BlitWindow.dst.window.y = 0;
				CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
				CheckF8 ( &BlitWindow ) ;
				SetDigitiserMode ( BlitGreyWindow, DIGyc, &Zoom ) ;
				Digitise ( &BlitWindow, &Zoom );
				PressAnyKey ( "grau" );
				SetDigitiserMode ( Blit555SWWindow, DIGyc, &Zoom ) ;
				Digitise ( &BlitWindow, &Zoom );
				PressAnyKey ( "YC Farbe" );
				SetDigitiserMode ( Blit555Window, DIGcolor, &Zoom ) ;
				Digitise ( &BlitWindow, &Zoom );
				printf ( "\033H- HW Farbe, press any key !" ) ;
				break ;

	case ':' :	switch ( tolower ( getch() ) )
				{
		case 'r' :	printf ( "\033Hread sequence\n" ) ;
					if ( GetFilmName() )
					{
						FreeSequence ( &Sequence ) ;
						SequenceRead ( &Sequence, FilmName, 0, 999 ) ;
					}
					break ;
		case 'w' :	printf ( "\033Hwrite sequence\n" ) ;
					if ( Sequence.frames > 0 )
					{
						if ( GetFilmName() )
							SequenceWrite ( &Sequence, FilmName, 0, 999, BLKformat ) ;
					}
					else
						printf ( "- FIlm leer\n" ) ;
					break ;
		case 'f' :	FreeSequence ( &Sequence ) ;
					break ;
		case 'i' :	SequenceInfo ( &Sequence ) ;
					break ;
				}
				break ;


	/*... function keys ...*/
	
	case F2:	Continuous = TRUE ;
	case F1:	Digitise ( &BlitWindow, &Zoom );
				break ;

	case F3 :	Zoom.x = Zoom.y = 1 ;
				goto zoomset ;
# if 0
	case F4 :	Zoom.x = Zoom.y = 2 ;
				goto zoomset ;
# else
	case F4 :	Zoom.x = 2 ;
				Zoom.y = 1 ;
				goto zoomset ;
# endif
	case F5 :	Zoom.x = 2 ;	/* centered quarter window */
				Zoom.y = 1 ;
				BlitWindow.dst.window.w = ScreenImage.w / 2 ;
				BlitWindow.dst.window.h = ScreenImage.h / 2 ;
				BlitWindow.dst.window.x = ScreenImage.w / 4 ;
				BlitWindow.dst.window.y = ScreenImage.h / 4 ;
 zoomset:
				CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
				CheckF8 ( &BlitWindow ) ;
				break ;

	case F6:	SequenceInfo ( &Sequence ) ;
				break ;
	case F8 :	FreeSequence ( &Sequence ) ;
				if ( MallocSequence ( &Sequence, -1, &BlitWindow.src, &Zoom ) > 0 )
					RecordSequence ( &Sequence, WaitUntilGrabbed ) ;
				break ;
	case F9:	PlaySequence ( &Sequence, &BlitWindow.dst ) ;
				break ;

	case F10 :	stop = TRUE ;
				break ;

	case F7:	FreeSequence ( &Sequence ) ;
				if ( ( frames = MallocSequence ( &Sequence, -1, &BlitWindow.src, &Zoom ) ) == 0 )
					break ;

				while ( RecordSequence ( &Sequence, WaitUntilGrabbed ) == frames
					 && ! SkipInput()
					 && PlaySequence ( &Sequence, &BlitWindow.dst ) == frames
					 && ! SkipInput() )
					/* loop */ ;
				break ;

	CASE( '~', 	if ( Linea->v_planes > 8 ) TestRun() ; else Rgb332Run( _Col332(2,2,1) ) ) ;
	CASE( '|', 	if ( Linea->v_planes == 8 ) TestSequence() ) ;
		
	CASE( 'N',	ToggleSwitch ( "grab before display", &GrabBeforeDisplay ) ) ;
	CASE( 'U',	ToggleSwitch ( "wait until grabbed", &WaitUntilGrabbed ) ) ;
	CASE( 'o',	ToggleSwitch ( "clip color values", &ClipConversion ) ) ;
	CASE( 'a',	ToggleSwitch ( "auto save",  &AutoSave ) ) ;
	CASE( '*',	ToggleSwitch ( "continuous grab", &Continuous ) ) ;

	CASE( 'I',	InitDmsd ( DmsdType ) ;					 ) ;
	CASE( 't',	GetInt ( "test", 	&test, 	  0 ) ) ;
	CASE( 'v',	GetInt ( "verbose", &verbose, 0 ) ) ;
								
	CASE( '?',	Help ( MdfHelpTable ) ) ;
# if 0
	case 'V' :	if ( GetUInt ( "LCA - release", &LcaRelease, 0 ) )
					LoadMdfLcaFile ( LCAtypGrey, LcaVersion, LcaRelease ) ;
				break ;
# endif					
	case 'i' :	printf ( "\033Eblit window :\n%s", dotline ) ;
				BlitWindowInfo ( &BlitWindow ) ;
				printf ( dotline ) ;
				More();
				if ( AutoSave )
					_RestoreScreen ( BackGroundBuffer ) ;
				break ;

# if USEhisto
	case 'H' :	HistoGramm();						break ;
# endif
	case 'w' :	StatusLine();
				printf ( "* new ctrlreg value ( dec | 0xhex | exit = Return ) ? >" ) ;
				gets ( buffer ) ;
				if ( strlen ( buffer ) > 0 )
				{
					val = strtol ( buffer, NULL, 0 ) ;
					SetCntrlReg ( (byte)val ) ;
				}
				StatusLine();
				printf( "ctrlreg w = $%02x", (byte)val ) ;
			/*	continue ; 	*/
	case 'r' :	StatusLine();
				printf( "ctrlreg r = $%02x", GetCntrlReg() ) ;
				break ;

	case 'G' :	switch ( tolower ( get_cmdin_char() ) )
				{
		case 'c' :	InitGreyTo555TableWithColors() ; 	break ;
		case 'g' :	InitGreyTo555Table();				break ;
				}
				break ;

	case 'F' :	display_file ( filename, tolower ( get_cmdin_char() ) == 'g' ? 0 : 1 ) ;
				break ;

# define INCx	16
# define INCy	16

case CUR_RIGHT:	*px += INCx ;	goto dodigit ;				/*>*/
case CUR_UP:	*py -= INCy ;	goto dodigit ;				/*^*/
case CUR_DOWN:	*py += INCy ;	goto dodigit ;				/*v*/
case CUR_LEFT:	*px -= INCx ;	goto dodigit ;				/*<*/
case HOME:		ResetBlitWindow ( &BlitWindow, &Zoom ) ;	/*Home*/

	  dodigit:	Continuous = FALSE ;
				CheckDigiWindows ( &BlitWindow, &Zoom, &ScreenImage ) ;
				CheckF8 ( &BlitWindow ) ;
				Digitise ( &BlitWindow, &Zoom );
				break ;

	case 'S' :	px = &BlitWindow.src.window.x ; py = &BlitWindow.src.window.y ; break ;
	case 'D' :	px = &BlitWindow.dst.window.x ; py = &BlitWindow.dst.window.y ; break ;
	case 'W' :	px = &BlitWindow.dst.window.w ; py = &BlitWindow.dst.window.h ; break ;
						
	case ')' :  _SaveScreen ( BackGroundBuffer ) ;
				break ;
	case '(' :  _RestoreScreen ( BackGroundBuffer ) ;
				break ;
	case '>' :  _SaveScreen ( SaveBuffer ) ;
				break ;
	case '<' :  _RestoreScreen ( SaveBuffer ) ;
				break ;
	case '=' :  {
					long n, gt, lt, eq ;
					uword *s, *b ;
					gt = lt = eq = 0 ;
					s = BackGroundBuffer ;
					b = SaveBuffer ;
					for ( n = ScreenPixels;	n > 0; n--, s++, b++ )
					{
						if ( *s == *b )
							eq++ ;
						else
							if ( *s < *b )
								lt++ ;
							else
								gt++ ;
					}
					StatusLine();
					printf ( "bak ? sav : < %lu, > %lu, = %lu", lt, gt, eq ) ;
				}
				break ;

	case ' ' :  if ( AutoSave )
					_RestoreScreen ( BackGroundBuffer ) ;
				Digitise ( &BlitWindow, &Zoom );
				break ;

	case '#' :	{
					int ldn, n ;

					/* 320 = 5  * 64 =  5 * 2^6 */
					/* 240 = 15 * 16 = 15 * 2^4	*/
					ldn = get_cmdin_char() - '0' ;
					if ( ldn >= 1 && ldn <= 4 )	/* horizontal 2..16 = 4 .. 256 frames divs	*/
					{
						n = 1 << ldn ;
						DigitiseMatrix ( n, n, &BlitWindow, &Zoom, WaitUntilGrabbed ) ;
					}
				}
				break ;
	case 0x2200 :	/* ALT-g	: sw grey-7	*/
		  		SetDigitiserMode ( BlitF7GreyWindow, DIGyc, &Zoom ) ;
				set_phys_palette ( CLUTgrey7Base, CLUTgrey7Base+127, clut_grey7 ) ;
				break ;
	case 'g' :	switch ( Linea->v_planes )
				{
		  case  8 :	if ( _Plus() )
		  				SetDigitiserMode ( BlitP8GreyWindow, DIGgrey8, &Zoom ) ;
		  			else
		  			{
# if 0	/* sw grey-8	*/
		  				SetDigitiserMode ( BlitF8GreyWindow, DIGyc, &Zoom ) ;
# else	/* fast grey-8	*/
		  				SetDigitiserMode ( BlitP8ColorWindow, DIGgrey8, &Zoom ) ;
						set_phys_palette ( CLUTgrey7Base, CLUTgrey7Base+127, clut_grey7 ) ;
						break ;
# endif
					}
					set_phys_palette ( 16, 240, clut_grey ) ;
					break ;
		  case 16 :	SetDigitiserMode ( BlitGreyWindow, DIGyc, &Zoom ) ;
					break ;
				}
				break ;
	case 'p' :	set_vdi_palette ( FIRSTcolor, 255, save_clut ) ;
				break ;
	case 'Y' :	switch ( Linea->v_planes )
				{
		  case  8 :	SetDigitiserMode ( BlitFyc224Window, DIGyc, &Zoom ) ;
					set_vdi_palette ( FIRSTcolor, 255, clut_yc224 ) ;
					printf ( "F8 - YC format : %d\n", *(yctof8_format-1) ) ;
					break ;
		  case 16 :	SetDigitiserMode ( Blit555Window, DIGcolor, &Zoom ) ;
					break ;
				}
				break ;
	case 0x2e00 :	goto f332 ;	/* ALT-C	*/
	case 'c' :	switch ( Linea->v_planes )
				{
		  case  8 :	
		  			if ( _Plus() )
		  				SetDigitiserMode ( BlitP8ColorWindow, DIGcolor8, &Zoom ) ;
		  			else
		  		f332:
		  				SetDigitiserMode ( BlitF332Window, DIGcolor, &Zoom ) ;
					set_vdi_palette ( FIRSTcolor, 255, clut_332 ) ;
					break ;
		  case 16 :	SetDigitiserMode ( Blit555Window, DIGcolor, &Zoom ) ;
					break ;
				}
				break ;
	case 's' :	SetDigitiserMode ( Blit555SWWindow, DIGyc, &Zoom ) ;
				break ;
	case 'h' :	SetDigitiserMode ( Blit555HWSimWindow, DIGyc, &Zoom ) ;
				break ;
#if 0
	case '!' :	pixel_info ( (uword *)yc.data, ycbpl, ScreenImage.w, ScreenImage.h ) ;
				break ;
# else
	case '!' :	pixel_info ( NULL, 0, ScreenImage.w, ScreenImage.h ) ;
				break ;
# endif
	case 'f' :	GetString ( "file name *.yc", filename ) ;
				break ;
	case 'j' :	DisplayJpegFile ( filename ) ;
				break ;
	case 'Q' - '@' :
	case 'q' :	stop = TRUE ;
				break ;
	default :	StatusLine();
				printf ( " cmd = $%02x", cmd ) ;
				break ;
		}
	}
}



int dummy, vdi_handle, appl_id, phys_handle ;

/*---------------------------------- set_332_palette ----------------*/
void set_332_palette ( void )
{
	int i ;
	int work_in[11] ;
	int work_out[57] ;

	appl_id = appl_init ();
	for ( i = 0; i < 10; i++ )
		work_in[i]  = 1;
	work_in[10] = 2;
	phys_handle = graf_handle ( &dummy, &dummy, &dummy, &dummy ) ;
	vdi_handle = phys_handle ;
	v_opnvwk ( work_in, &vdi_handle, work_out ) ;

	init_palette() ;
}

/*---------------------------------- reset_332_palette ----------------*/
void reset_332_palette ( void )
{
	set_vdi_palette ( 0, 15, save_clut ) ;
	v_clsvwk ( vdi_handle );
	appl_exit();
}


/*==========================*/




/*----------------------------------------------- main -------*/
int main ( int argc, char *argv[] )
{
# if 1
	printf ( "\033EMatDigi/Falcon - Test / ", __DATE__ " / " __TIME__ "\n" ) ;
# else
	printf ( "\033HMatDigi/Falcon - Test / ", __DATE__ " / " __TIME__ "\n" ) ;
# endif
	verbose = 0 ;

	uprintf = printfnl ;

	linea_init();
	hide_mouse( );

	switch ( Linea->v_planes )
	{
 default :						/* use pseudo screen	*/
		ScreenImage.w 		= 320 ;
		ScreenImage.h 		= 240 ;
		ScreenImage.planes 	= 16 ;
		ScreenImage.bpl		= 320 * 2 ;

		DisplayEnabled = FALSE ;
		verbose = 1 ;
		break ;
		
 case  8 :						/* use real  8 bpp screen	*/
 		DigitiseFunction = BlitF332Window ; /* replace fct	*/

		set_332_palette();
		verbose = 1 ;
	/*	continue ;	*/
 case 16 :						/* use real 16 bpp screen	*/
		ScreenImage.w 		= Vdiesc->v_rez_hz ;
		ScreenImage.h 		= Vdiesc->v_rez_vt ;
		ScreenImage.planes 	= Linea->v_planes ;
		ScreenImage.bpl		= Linea->v_lin_wr ;
		break ;
	}

	ScreenPixels  = (long)ScreenImage.h * (long)ScreenImage.h ;
	
	if ( DisplayEnabled )
		ScreenImage.data = Logbase() ;
	else
		ScreenImage.data = malloc ( ScreenSize() ) ;	/* display not implemented	*/

	BackGroundBuffer = malloc ( ScreenSize() ) ;
	GreyBuffer   	 = malloc ( ScreenPixels ) ;
	SaveBuffer   	 = malloc ( ScreenSize() ) ;

	_SaveScreen ( BackGroundBuffer ) ;
	_SaveScreen ( SaveBuffer ) ;
				
	printf ( "  resolution = %d x %d x %d\n", ScreenImage.w, ScreenImage.h, ScreenImage.planes ) ;
	printf ( "  bpl = %d, screen = $%p, size = %lu\n", ScreenImage.bpl, ScreenImage.data, ScreenSize() ) ;
	
	InitGreyTo555Table();
/*
	TestScreen();
*/
	if ( argc > 1 )
		command_loop ( strcpy ( fnbuffer, argv[1] ) ) ;
# if 1
	else
		command_loop ( fnbuffer ) ;
# else
	else
	{
		printf ( "\n- Press any key !" ) ;
		getch();
	}
# endif

	switch ( Linea->v_planes )
	{
 case  8 :
 		reset_332_palette();
		break ;
	}
	
	show_mouse ( 1 );

	return 0 ;
}

