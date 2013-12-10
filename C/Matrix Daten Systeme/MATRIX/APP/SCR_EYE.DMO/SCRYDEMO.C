/********************************************************************/
/* 				ScreenEye Interface Demo Program					*/
/*																	*/
/*  (c) 1993 Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler	*/
/*																	*/
/********************************************************************/

# define DEBUG 0

# define DEFsource	1

# include <stdlib.h>
# include <tos.h>
# include <stdio.h>
# include <string.h>
# include <linea.h>
# include <ext.h>

# include <e:\develop\matlib\global.h>

# define NotOK	1
# define ESC	0x1b
# define CR		0x0d

#define HELP          0x6200
#define RETURN        0x1c0d
#define ENTER         0x720d
#define CUR_UP        0x4800
#define CUR_LEFT      0x4b00
#define CUR_RIGHT     0x4d00
#define CUR_DOWN      0x5000
#define HOME          0x4700
#define SHFT_HOME     0x4737

# include "e:\develop\app\matdigi.f\digiblit.h"
# include "e:\develop\app\matdigi.f\film.h"
# include "e:\develop\app\matdigi.f\digitise.h"
# include "e:\develop\app\matdigi.f\mdf_lca.h"

# include "e:\develop\app\matdigi.f\screyeif.h"
# include "e:\develop\app\matdigi.f\scryiacc.h"


typedef enum
{
	IDLE, DIGITIZE, RECORD,
	PLAY_FORWARD, PLAY_BACK, PLAY_FAST_FORWARD, PLAY_FAST_BACK,
	LOADfilm, SAVEfilm
} TRunMode ;

typedef enum { GRAB_OFF, GRAB_ON } TGrabMode ;

bool ScreenEyeOk ;

TBlitWindow		BlitWindow ;
POINT			Zoom ;
TImageWindow	MatDigiF ;
POINT 			screen_size ;
int				bit_planes ;

# define NUMzoomCodes	5
# define	Z11		0
# define	Z21		1
# define	Z41		2
# define	Z42		3
# define	Z82		4

int ZoomCode = Z41 ;

POINT			ZoomTable[NUMzoomCodes] =
{	/*	X	Y							320 x 240			320 x 480			*/
	{	1,	1 	},	/*	720 x 288	: full image								*/
	{	2,	1 	},	/*	360 x 288	: 1:1 aspect ratio							*/
	{	4,	1 	},	/*	180 x 288	: 						1:1 aspect ratio	*/
	{	4,	2 	},	/*	180 x 144	: 1/4 image fast mode						*/
	{	8,	2 	}	/*	 90 x 144	: 						1/4 image fast mode	*/
} ;

POINT        FullZoom = { 1, 1 } ;

TRunMode 	 RunMode = IDLE ;

TImageWindow DigitizerImage ;
TBlitWindow  FullFrameBuffer,	/* background buffer for full image			*/
			 FullImageBuffer,	/* buffer for full image = odd + even field	*/
			 LiveImageBuffer ;	/* buffer for live video outside 
								   full screen mode */
TImageWindow LiveBox ;

SEQUENCE 	Sequence ;
int			PictureNumber = 0 ;
int			ScreenDumpNumber = 0 ;

int			Step = +1 ;
# define FASTsteps	4

char 		CurrentFileDir[128] = "c:\\film" ;
char 		CurrentDrive = 'c' ;
char 		CurrentFilmName[8] = "test" ;
char 		BaseName[128] ;
uword		SequenceFileFormat = DEFformat ;

int			dummy ;

/*------------------------------------------------ auto_check ----*/
void auto_check ( void )
{
	if ( ScreenEyeOk )
	{
		SetVideoSignal ( PUP_AUTO ) ;
		SetVideoSource ( DEFsource ) ;
		chk_set_chan_sig ( (int *)&GetVideoSource(),
						   (int *)&GetVideoSignal(),
						   (int *)&dummy ) ;
	}
}


/* ----------------------------------- resize_window ------------------- */
void resize_window ( void )
{
	BlitWindow.dst.window.x = 0 ;
	BlitWindow.dst.window.y = 0 ;
	BlitWindow.dst.window.w = MatDigiF.image.w / Zoom.y ;
	BlitWindow.dst.window.h = MatDigiF.image.h / Zoom.x ;

	if ( BlitWindow.dst.window.w > screen_size.x )
		BlitWindow.dst.window.w = screen_size.x ;
	if ( BlitWindow.dst.window.h > screen_size.y )
		BlitWindow.dst.window.h = screen_size.y ;
}


/* ----------------------------------- get_pic ------------------- */
void get_pic ( TGrabMode gmode )
{
	if ( ScreenEyeOk )
	{
		if ( gmode == GRAB_ON )
			GrabFieldIntoFifo ( GetWaitUntilFrameGrabbed(), FIELDnext ) ;

		BlitWindow.src.window.w = BlitWindow.dst.window.w ;
		BlitWindow.src.window.h = BlitWindow.dst.window.h ;
		Blit555Window ( &BlitWindow, &Zoom ) ;
	}
}


/*------------------------------------ GrabFullFrame --------------------*/
bool GrabFullFrame ( void )
{
	if ( FullFrameBuffer.dst.image.data != NULL)
	{
		LoadMatDigiFLcaData ( 0, DIGcolor, &FullZoom, TRUE ) ;
		Blit555Window ( &FullFrameBuffer, &FullZoom ) ;
		InterPolate555 ( &FullFrameBuffer.dst, &BlitWindow.dst, &Zoom ) ;
		LoadMatDigiFLcaData ( 0, DIGcolor, &Zoom, TRUE ) ;

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
		printf ( "* Film leer\n" ) ;
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
		printf ( "* Film nicht leer\n" ) ;
		return FALSE ;
	}
}

/*-------------------------------------------- WriteError --------*/
void WriteError ( int result )
{
	printf ( "* Schreibfehler %d\n", result ) ;
}

/*-------------------------------------------- MakeBaseName --------*/
bool MakeBaseName ( void )
{
	*CurrentFileDir = CurrentDrive ;
	Dcreate ( CurrentFileDir ) ;
	strcat ( strcat ( strcpy ( BaseName, CurrentFileDir ),
					  "\\" ),
			 CurrentFilmName ) ;
	return TRUE ;
}

/*-------------------------------------------- SaveStart --------*/
bool SaveStart ( void )
{
	int result ;
	
	if ( CheckSequenceAvailable() )
	{
		if ( MakeBaseName() )
		{
			printf ( "Schreiben '%s'\n", BaseName ) ;
			result = WriteSequenceHeader ( &Sequence, BaseName, SequenceFileFormat ) ;
			if ( result == OK )
			{
				Sequence.current = 0 ;
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
	
	if ( ( frame = Sequence.current ) < Sequence.frames )
	{
		result = WriteFrame ( &Sequence, BaseName, frame ) ;
		if( result == OK )
		{
			printf ( "\rframe : %d", frame ) ;
			Sequence.current++ ;
			return frame ;
		}
		else
			WriteError ( result ) ;
	}
	return -1 ;
}


/*-------------------------------------- SaveEnd ------------*/
void SaveEnd ( void )
{
	printf ( "\n- save end # d\n", Sequence.valid ) ;
	FreeConvBuffer();
}



/*-------------------------------------------- ReadError --------*/
void ReadError ( int result )
{
	printf ( "* Lesefehler %d\n", result ) ;
}


/*-------------------------------------------- LoadStart --------*/
bool LoadStart ( void )
{
	int result ;

	if ( CheckSequenceEmpty() )
	{
		if ( MakeBaseName() )
		{
			printf ( "Lesen '%s'\n", BaseName ) ;
			result = ReadSequenceHeader ( &Sequence, BaseName ) ;
			if ( result == OK )
			{
				Sequence.current = 0 ;
				return TRUE ;
			}
			else
				ReadError ( result ) ;
		}
	}
	return FALSE ;
}

/*--------------------------------------------- LoadNext -----------*/
int LoadNext ( void )
{
	int frame, result ;
	
	if ( ( frame = Sequence.current ) < Sequence.valid )
	{
		result = ReadFrame ( &Sequence, BaseName, frame ) ;
		if( result == OK )
		{					/* open error only, if first file	*/
			printf ( "\rframe : %d", frame ) ;
			Sequence.current++ ;
			return frame ;
		}
		else 
			ReadError ( result ) ;
	}
	return -1 ;
}


/*-------------------------------------- LoadEnd ------------*/
void LoadEnd ( void )
{
	Sequence.valid = Sequence.current ;
	Sequence.current = 0 ;

	printf ( "\n- load end # d\n", Sequence.valid ) ;
	FreeConvBuffer();
}


/*-------------------------------------------- DeleteFilm --------*/
void DeleteFilm ( void )
{
	if ( CheckSequenceAvailable() )
	{
		printf ( "* L”sche Film\n" ) ;
		FreeSequence ( &Sequence ) ;
	}
}


/*-------------------------------------------- MallocFilm --------*/
int MallocFilm ( void )
{
	int frames ;
	
	frames = MallocSequence ( &Sequence, 999, &BlitWindow.src, &Zoom ) ;
	return frames > 0 ;
}


/*-------------------------------------------- NewZoomSetup --------*/
void NewZoomSetup ( void )
{
	LoadMatDigiFLcaData ( GetDmsdType(), DIGcolor, &Zoom, TRUE ) ;
	printf ( "- zoom = %d:%d\n", Zoom.x, Zoom.y ) ;
	resize_window();
}

/*-------------------------------------------- NewZoomCode --------*/
void NewZoomCode ( int zoomcode )
{
	ZoomCode = zoomcode ;
	Zoom = ZoomTable [ZoomCode] ;
	NewZoomSetup();
}



/*------------------------------------------ TerminateRunMode ---------*/
void TerminateRunMode ( void )
{
	switch ( RunMode )
	{
case IDLE :		return ;

case DIGITIZE :	GrabFullFrame();
				break ;

case LOADfilm :	LoadEnd();
				break ;
				
case SAVEfilm :	SaveEnd();
				break ;

case PLAY_FORWARD :
case PLAY_BACK :
case PLAY_FAST_FORWARD :
case PLAY_FAST_BACK :
				PlayStop ( &Sequence ) ;
				break ;

case RECORD :	RecordStop ( &Sequence ) ;
				printf ( "- record stop bei #%d\n", Sequence.valid - 1 ) ;
				break ;
	}
}

/*------------------------------------------ StartRunMode ---------*/
bool StartRunMode ( void )
{
	switch ( RunMode )
	{
case IDLE :		break ;

case LOADfilm :	return LoadStart() ;
				
case SAVEfilm :	return SaveStart();

case DIGITIZE :	Step = +1 ;
				break ;

case RECORD :	Step = +1 ;
				RecordStart ( &Sequence ) ;
				break ;

case PLAY_FORWARD :
case PLAY_FAST_FORWARD :
case PLAY_BACK :
case PLAY_FAST_BACK :
				PlayStart ( &Sequence, Step ) ;
				break ;
	}
	return TRUE ;
}


/*------------------------------------------------ NewRunMode ------*/
bool NewRunMode ( TRunMode newmode )
{
	if ( RunMode != newmode )
	{
		TerminateRunMode();
		RunMode = newmode ;
		if ( ! StartRunMode() )
			RunMode = IDLE ;
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

# if 0
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
		FullImageBuffer.dst.window.w = MatDigiF.image.w ;
	
		LoadMatDigiFLcaData ( 0, DIGyc, &FullZoom, TRUE ) ;

		printf ( "Grab odd" ) ;
		GrabFieldIntoFifo ( TRUE, FIELDodd ) ;
		FullImageBuffer.dst.window.x = 0 ;
		printf ( "Convert odd" ) ;
		BlitRGBWindow ( &FullImageBuffer, &FullZoom ) ;
	
		printf ( "Grab even" ) ;
		GrabFieldIntoFifo ( TRUE, FIELDeven ) ;
		FullImageBuffer.dst.window.x = MatDigiF.image.w ;
		printf ( "Convert even" ) ;
		BlitRGBWindow ( &FullImageBuffer, &FullZoom ) ;

		LoadMatDigiFLcaData ( 0, DIGcolor, &Zoom, TRUE ) ;

		SetToFullSize ( &FullImageBuffer.dst,
						 FullImageBuffer.dst.image.data,
						 MatDigiF.image.w, 2 * MatDigiF.image.h, 24 ) ;
		return OK ;
	}
	else
	{
		printf ( "* Speicher voll" ) ;
		return NotOK ;	
	}
}

/* ------------------------------------------------- SnapFullPicture ------- */
void SnapFullPicture ( void )
{
	char filename[128] ;
	int  result ;

	printf ( "- SnapFullPicture\n" ) ;		
	
	if ( MakeBaseName() )
	{
		sprintf ( filename, "%s%04u.tif",
					BaseName, PictureNumber ) ;
		printf ( "- schreiben %s\n", filename ) ;		
		if ( GetFullRGBFrame() == OK )
		{
			if ( ( result = WriteTiffFile ( filename, 
							FullImageBuffer.dst.image.data,
							FullImageBuffer.dst.image.w,
							FullImageBuffer.dst.image.h ) ) == OK )
					PictureNumber++ ;
				else
					WriteError ( result ) ;
			free ( FullImageBuffer.dst.image.data ) ;
			FullImageBuffer.dst.image.data = NULL ;
		}
	}
}

/* ------------------------------------------------- ScreenDump ------- */
void ScreenDump ( void )
{
	char filename[128] ;

	if ( MakeBaseName() )
	{
		sprintf ( filename, "%ssc%02u.tga",
					BaseName, ScreenDumpNumber++ ) ;
		WriteTargaFile ( filename, screen_size.x, screen_size.y, Logbase() ) ;
	}
}


/*------------------------------------ SnapFilmPicture ----------------*/
int SnapFilmPicture ( void )
{
	int frame ;

	if ( SequenceEmpty ( &Sequence ) )
	{
		if ( MallocFilm() > 0 )
			frame = 0 ;
		else
			return -1 ;
	}
	else
		frame = Sequence.current ;

	if ( ( frame = RecordFrame ( &Sequence, frame, GetWaitUntilFrameGrabbed() ) ) >= 0 )
	{
		Sequence.current = frame++ ;
		PositionSequence ( frame ) ;
	}
		
	return frame ;
}
# endif


/*------------------------------------------------- LimitFrame --------*/
int LimitFrame ( int f )
{
	return f < 0 ? 0
				 : f >= Sequence.valid ? Sequence.valid
				 					   : f ;
}

/*-------------------------------------------------------- PositionSequence ------*/
void PositionSequence ( int frame )
{
	Sequence.current = LimitFrame ( frame ) ;
	DisplayFrame ( &Sequence, Sequence.current, &BlitWindow.dst ) ;
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

/*-------------------------------------------- set_window_title ------*/
void set_window_title ( void )
{
	printf ( "signal = %d, source = %d\n", 	GetVideoSignal(),
				  							GetVideoSource() ) ;
}

/*----------------------------------------- StartPlayMode ------------*/
void StartPlayMode ( TRunMode playmode, int step )
{
	if ( CheckSequenceAvailable() )
	{
		printf ( "\033E" ) ;
		Step = step ;
		if ( Step > 0 && Sequence.current >= Sequence.valid )
		{
			printf ( "- rewind\n" ) ;
			Sequence.current = 0 ;
		}
		else if ( Step < 0 && Sequence.current <= 0 )
		{
			printf ( "- wind\n" ) ;
			Sequence.current = Sequence.valid - 1 ;
		}
		NewRunMode ( playmode ) ;
	}
	else
	{
		NewRunMode ( IDLE ) ;
	}
}


/*---------------------------------------------- get_cmdin_stat ----*/
bool get_cmdin_stat ( void )
{
	return Bconstat ( 2 ) != 0 ;
}

/*---------------------------------------------- get_cmdin_char ----*/
unsigned get_cmdin_char ( void )
{
	long lc ;

	lc = Bconin ( 2 ) ;

	if ( ( lc & 0x00ff ) && ( lc < 0x3b0000L ) )		/* pure ascii	*/
		return (unsigned) ( (lc&0xff) ) ;
	else												/* scan & ascii	*/
		return (unsigned) ( (lc>>8) | (lc&0xff) ) ;
}


/*-------------------------------------------- CommandLoop ------*/
void CommandLoop ( void )
{
	int i, keycode ;
	
	for(;;)
	{
		if ( get_cmdin_stat() )
		{
			keycode = get_cmdin_char() ;
			switch ( keycode )
			{
	case '?' :	BlitWindowInfo ( &BlitWindow ) ;
				set_window_title ( ) ;
				break ;
	case '1' :
	case '2' :
	case '3' :	SetVideoSource ( keycode - '0' ) ;
				if ( ScreenEyeOk )
					InitMdf ( GetVideoSignal(),
							  GetVideoSource(), GetDmsdType() ) ;
				set_window_title ( ) ;
				break ;

	case 'a' :
	case 'A' :	SetVideoSignal ( PUP_AUTO ) ;
				SetVideoSource ( DEFsource ) ;
				auto_check ( ) ;
				set_window_title ( ) ;
				break ;
		
	case 'f' :
	case 'F' :	SetVideoSignal ( PUP_CVBS ) ;
				if ( ScreenEyeOk )
					InitMdf ( GetVideoSignal(),
					      	  GetVideoSource(), GetDmsdType() ) ;
	            set_window_title ( ) ;
				break ;

	case 'P' :	StartPlayMode ( PLAY_FAST_FORWARD, +FASTsteps ) ;	break ;
	case 'p' :	StartPlayMode ( PLAY_FORWARD, +1 ) ;				break ;

	case 'B' :	StartPlayMode ( PLAY_FAST_BACK, -FASTsteps ) ;		break ;	
	case 'b' :	StartPlayMode ( PLAY_BACK, -1 ) ;					break ;

	case 'o' :
	case 'O' :	SwitchDigitiserMode();
				break ;

	case 's' :
	case 'S' :	SetVideoSignal ( PUP_SVHS ) ;
				if ( ScreenEyeOk )
					InitMdf ( GetVideoSignal(),
						      GetVideoSource(), GetDmsdType() ) ;
	            set_window_title ( ) ;
	           	break ;

	case 'v' :	*(ScreenEyeParameter->verbose) = 1 ;
				break ;
	case 'V' :	*(ScreenEyeParameter->verbose) = 0 ;
				break ;
	case 'Z' :	printf ( "\033E" ) ;
				NewZoomCode ( ( ZoomCode +(NUMzoomCodes-1) ) % NUMzoomCodes ) ;
				break ;
	case 'z' :	printf ( "\033E" ) ;
				NewZoomCode ( ( ZoomCode + 1 ) % NUMzoomCodes ) ;
				break ;

	case 'Q' :
	case 'q' :	return ;

	case 'R' :
	case 'r' :	printf ( "\033E" ) ;
				if ( SequenceNotEmpty ( &Sequence ) )
					DeleteFilm();
				if ( MallocFilm() > 0 )
					NewRunMode ( RECORD ) ;
				else
					NewRunMode ( IDLE ) ;
				break ;


	case HELP :	NewRunMode ( IDLE ) ;
				printf ( "\033E"
"ScreenEye - Treiber Demo\n"
"---------------------------------\n"
"  ?      -  BlitWindow - Info\n"
"  o      -  Digitialiserung ein / aus\n"
"  p      -  Play\n"
"  P      -  Play fast\n"
"  b      -  Play back\n"
"  B      -  Play fast back\n"
"  z      -  zoom <\n"
"  Z      -  zoom >\n"
"  r      -  Aufnahme Film\n"
"  ESC    -  Stop\n"
"  HOME   -  -> Anfang Film\n"
"  S-HOME -  -> Ende Film\n"
"  ->     -  Bild vor\n"
"  <-     -  Bild zurck\n"
"  q      -  quit\n"
				) ;
				break ;

	case CR :
	case ENTER :
	case RETURN :
	case ' ' :	get_pic ( GRAB_ON ) ;
				break ;

	case 'D' :
	case 'd' :	NewRunMode ( DIGITIZE ) ;
				break ;

	case ESC :	printf ( "\033E" ) ;
				NewRunMode ( IDLE ) ;
				if ( Sequence.valid > 0 )
					PositionSequence ( Sequence.current ) ;
				break ;

case HOME:		PositionSequence ( 0 ) ;								break ;
case SHFT_HOME:	PositionSequence ( Sequence.valid - 1 ) ;				break ;

case CUR_LEFT:	PositionSequence ( Sequence.current - 1 ) ;				break ;
case CUR_RIGHT:	PositionSequence ( Sequence.current + 1 ) ;				break ;
			}
		}
		
		switch ( RunMode )
		{
case IDLE :	break ;

case LOADfilm :
			if ( LoadNext() < 0 )
				NewRunMode ( IDLE ) ;
			break ;

case SAVEfilm :
			if ( SaveNext() < 0 )
				NewRunMode ( IDLE ) ;
			break ;

case DIGITIZE :
			get_pic ( GRAB_ON ) ;
			if ( ( GetVideoSignal() == PUP_AUTO ) || ( GetVideoSource() == PUP_AUTO ) )
				auto_check() ;
			break ;

case RECORD :
			if ( ( i = RecordCurrFrame ( &Sequence, GetWaitUntilFrameGrabbed() ) ) >= 0 )
				StretchBlit ( &Sequence.blitwind.dst, &LiveBox ) ;
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
	case SEQnotSynced :			/* wait	*/
				continue ;
			}
		/* 	no break ;	*/

case PLAY_FAST_FORWARD :
case PLAY_FAST_BACK :
			i = DisplayCurrentFrame ( &Sequence, &BlitWindow.dst ) ;
			if ( i >= 0 )
				Sequence.current += Step ;
			else
				NewRunMode ( IDLE ) ;
			break ;
		}
	} /* for */
}

										
/* ----------------------------------------------- init_vars ------ */
void init_vars ( void )
{
	InitSequence ( &Sequence ) ;

	SetVideoSignal ( PUP_AUTO ) ;
	SetVideoSource ( DEFsource ) ;

	RunMode = IDLE ;
	ScreenEyeOk = FALSE ;
	
	SetWaitUntilFrameGrabbed ( FALSE ) ;
}


# define PressAnyKey() printf ( "- bitte Taste drcken !\n" ) ; getch();

/*--------------------------------------------- ResetDigiImages ------*/
void ResetDigiImages ( TBlitWindow *blitwind )
{
	SetToFullSize ( &blitwind->src, NULL, MatDigiF.image.w, MatDigiF.image.h, 16 ) ;
	SetToFullSize ( &blitwind->dst, Logbase(), screen_size.x, screen_size.y, bit_planes ) ;
}
/*--------------------------------------------- ResetBlitWindow ------*/
void ResetBlitWindow ( TBlitWindow *blitwind, POINT *zoom )
{
	ResetDigiImages ( blitwind ) ;
	ResetDigiWindows ( blitwind ) ;
	*zoom = ZoomTable[ZoomCode] ;
}
/* ---------------------------------------------------- main ------ */
void main ( void )
{
	printf ( "\033EMATRIX ScreenEye " __TIME__ " / " __DATE__ "\n"
			 "- Treiber Demo\n" ) ;
	linea_init();

	if ( GetScreenEyeParameter() != OK )
	{
		if ( ScreenEyeParameter == NULL )
		{
			printf ( "* ScreenEye-Driver nicht installiert\n" ) ;
		}
		else
		{
			printf ( "%s\n", ScreenEyeParameter->copyright ) ;
	 		printf ( "* falsche Treiberversion\n" ) ;
		}
		PressAnyKey();
		exit ( 0 ) ;
	}
	else
	{
		printf ( ">>> %s\n", ScreenEyeParameter->copyright ) ;
 	}

	bit_planes = Linea->v_planes ;
	screen_size.x = Vdiesc->v_rez_hz ;
	screen_size.y = Vdiesc->v_rez_vt ;

	init_vars () ;
	
# if DEBUG == 0
	if ( bit_planes == 1 )

# endif
	{
		Zoom = ZoomTable[ZoomCode] ;
		ScreenEyeOk = LoadMatDigiFLcaData ( GetDmsdType(), DIGcolor, &Zoom, TRUE ) == 0 ;
		if ( ScreenEyeOk )
			ScreenEyeOk = InitMdf ( PUP_CVBS, 1, GetDmsdType() ) ;

		if ( ScreenEyeOk )
			printf ( "ScreenEye ok\n" ) ;
		else
			printf ( "* ScreenEye - Fehler bei Initialisierung\n" ) ;
		
		SetToFullSize ( &MatDigiF, NULL,
						 GetDmsdType() == 7191 ? DIGdx7191 : DIGdx9051,
						 DIGdyF, 16 ) ;

		ResetBlitWindow ( &BlitWindow, &Zoom ) ;
		resize_window();
		
		FullFrameBuffer.dst = FullFrameBuffer.src = MatDigiF ;

		FullImageBuffer = FullFrameBuffer ;
		LiveImageBuffer = FullFrameBuffer ;

		FullFrameBuffer.dst.image.data = malloc ( _SizeOf ( &FullFrameBuffer.dst.image ) ) ;

		LiveBox.image    = BlitWindow.dst.image ;
		LiveBox.window.x = ( screen_size.x - 48 ) / 2  ;
		LiveBox.window.y = ( screen_size.y - 32 ) / 2  ;
		LiveBox.window.w = 48 ;
		LiveBox.window.h = 32 ;

		if ( bit_planes != 16 )
			ScreenEyeOk	= FALSE ;

		get_pic ( GRAB_ON ) ;
		RunMode = DIGITIZE ;
		CommandLoop ();
	}
# if DEBUG == 0
	else
	{
		printf ( "ScreenEye - Demo l„uft nur im True Color Modus !\n" ) ;
		PressAnyKey();
	}
# endif
}

