# define TEST 0

# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <tos.h>

# include <global.h>
# include <error.h>
# include <readcook.h>
# include <cookie.h>

# include "digiblit.h"
# include "digiblix.h"
# include "digitise.h"
# include "digitisx.h"
# include "mdf_if.h"
# include "mdf_lca.h"
# include "mdf_lcax.h"
# include "yc.h"
# include "film.h"
# include "filmx.h"
# include "stretch.h"

# include <vdi.h>		/* needed only for MFDB declaration in jpgdh.h */
# include "d:\pc\app\jpeg_dsp\if\jpgdh.h"
# include "d:\pc\app\jpeg_dsp\if\if.h"

# include "screyeif.h"
# include "digbltif.h"


#define	VERSION		0
#define RELEASE		8

# define COPYRIGHT		"MATRIX ScreenEye Driver"
# define INSTALLED		"- Treiber installiert !\n"
# define NOTinstalled	"- ScreenEye-Driver nicht installiert !\n"
# define REinstall		"- Instanz #%d : $%08lx -> $%08lx!\n"
# define WASinstalled	"- ScreenEye-Driver war bereits installiert !\n"
# define UNlocked		"- ScreenEye-Driver unlocked !\n"
# define COOKIEnotInstd	"- Cookie kann nicht installiert werden !\n"
# define PRESSreturn	"- Weiter mit RETURN !\n"
# define ILLEGALmagic	"- Falsche ScreenEye-Driver Version !\n"
# define NOTpresent		"- ScreenEye - Hardware nicht installiert !\n"
# define NOdspJpeg		"* Warnung : kein DSP-JPEG Treiber\n"

char CopyRight[] = COPYRIGHT " / " __DATE__ " / " __TIME__ ;

extern TYCtoF8format yctof8_format ;	/* s. yc_fast.s / palette.c	*/

TDigiParameter DigiParameterBlock =
{
	{
		NULL,
		DIGdx9051, DIGdyF,
		16,
		DIGdx9051 * ( 16 / 8 )
	},
	&yctof8_format,
	FALSE,
} ;


TScreenEyeParameterBlock ScreenEyeParameterBlock =
{
	VERSION*10+RELEASE,
	(unsigned) sizeof ( TScreenEyeParameterBlock ),
	CopyRight,
	0,						/* = instance	*/
	0,						/* = lock		*/

	&verbose,
	&DigiParameterBlock,
	&DmsdParameterBlock,
	
	{ 0, 0 /* ... */ },		/* reserved 	*/

	GetSetDmsdRegister,
	LoadDmsdRegister,
	
	GetBlitDigiToWindow,
							/* BlitProcedures	*/
	BlitDigiToWindow,
	BlitP8ColorWindow,
	BlitP8GreyWindow,
	BlitF7GreyWindow,
	BlitGreyWindow,
	Blit555SWWindow,
	Blit555HWSimWindow,
	Blit555Window,
	BlitRGBWindow,
	BlitF332Window,
	BlitF8GreyWindow,
	BlitFyc224Window,
	
	ImageInfo,
	WindowInfo,
	BlitWindowInfo,
	ImageWindowInfo,

	SetToFullSize,
	PixelPosition,

	InitGreyTo555Table,
	InitGreyTo555TableWithColors,

	ShowHisto,

	GrabFieldIntoFifo,
	DigitiseFrame,
	ResetGrabber,
	
	chk_set_video_standard,
	chk_set_chan_sig,
	chk_set_signal,
	set_lumi_cntrl,
	GetDmsdStatus,
	InitMdf,
	InitDmsd,
	
/*... film ...*/
	DigitiseMatrix,
	InterPolate555,
	StretchBlit,
	WriteRGBFiles,
	WriteTargaFile,
	WriteFrame,
	WriteSequenceHeader,
	SequenceWrite,
	ReadTargaFrame,
	ReadBlockFrame,
	ReadFrame,
	ReadSequenceHeader,
	SequenceRead,
	FreeConvBuffer,
	InitSequence,
	MallocSequence,
	FreeSequence,
	SequenceInfo,
	RecordSequence,
	PlaySequence,
	RecordStart,
	RecordStop,
	RecordRestart,
	RecordCurrFrame,
	RecordFrame,
	PlayStart,
	PlayRestart,
	PlayStop,
	PlaySyncCurrent,
	ActivateFrame,
	DisplayCurrentFrame,
	ChkAndSetCurrentFrame,
	DisplayFrame,
	
	NULL,	/* AbortLoop..	*/
	NULL,	/* JpegUser..	*/

	SetDmsdType,
	ResetDigiWindows,
	CheckDigiWindows,

	LoadMatDigiFLcaData,
	
	yuv_to_rgb,
	CheckCalcCSCtables
} ;


typedef int  (iPROC)(void);
typedef bool (bPROC)(void);

/*-------------------------------------------- DummyProc -----------*/
void DummyProc ( void )
{
	printf ( "\033H\n\n\n" NOTpresent ) ;
}

/*-------------------------------------------- DummyProc_1 -----------*/
int DummyProc_1 ( void )
{
	DummyProc();
	return -1 ;
}

/*-------------------------------------------- DummyProcFalse -----------*/
bool DummyProcFalse ( void )
{
	DummyProc();
	return FALSE ;
}


/*------------------------------------------------------ UserRoutine -----*/
short UserRoutine ( JPGD_PTR jpgd )
{
	if ( ScreenEyeParameterBlock._JpegUserRoutine != NULL )
		return (*(ScreenEyeParameterBlock._JpegUserRoutine))( jpgd ) ;
	else
		return 0 ;
}


/*-------------------------------------------- ReplaceHotFunctions ---------*/
void ReplaceHotFunctions ( TScreenEyeParameterBlock *sp )
/* replace all functions with ScreenEye - HW access by dummys	*/
{
	(PROC *)(sp->_GetSetDmsdRegister )		= DummyProc ;
	(PROC *)(sp->_LoadDmsdRegister )		= DummyProc ;
	(PROC *)(sp->_BlitDigiToWindow )		= DummyProc ;
	(PROC *)(sp->_BlitP8ColorWindow )		= DummyProc ;
	(PROC *)(sp->_BlitP8GreyWindow )		= DummyProc ;
	(PROC *)(sp->_BlitF7GreyWindow )		= DummyProc ;
	(PROC *)(sp->_BlitGreyWindow )			= DummyProc ;
	(PROC *)(sp->_Blit555SWWindow )			= DummyProc ;
	(PROC *)(sp->_Blit555HWSimWindow )		= DummyProc ;
	(PROC *)(sp->_Blit555Window )			= DummyProc ;
	(PROC *)(sp->_BlitRGBWindow )			= DummyProc ;
	(PROC *)(sp->_BlitF332Window )			= DummyProc ;
	(PROC *)(sp->_BlitF8GreyWindow )		= DummyProc ;
	(PROC *)(sp->_BlitFyc224Window )		= DummyProc ;

	(iPROC *)(sp->_GrabFieldIntoFifo )		= DummyProc_1 ;
	(iPROC *)(sp->_DigitiseFrame )			= DummyProc_1 ;
	(iPROC *)(sp->_ResetGrabber )			= DummyProc_1 ;
	
	(iPROC *)(sp->_chk_set_chan_sig )		= DummyProc_1 ;
	(iPROC *)(sp->_chk_set_signal )			= DummyProc_1 ;
	(bPROC *)(sp->_set_lumi_cntrl )			= DummyProcFalse ;
	(iPROC *)(sp->_GetDmsdStatus )			= DummyProc_1 ;
	(bPROC *)(sp->_InitMdf )				= DummyProcFalse ;
	(iPROC *)(sp->_InitDmsd )				= DummyProc_1 ;
	
	(iPROC *)(sp->_DigitiseMatrix )			= DummyProc_1 ;
	(iPROC *)(sp->_RecordSequence )			= DummyProc_1 ;
	(iPROC *)(sp->_RecordStart )			= DummyProc_1 ;
	(iPROC *)(sp->_RecordStop )				= DummyProc_1 ;
	(iPROC *)(sp->_RecordRestart )			= DummyProc_1 ;
	(iPROC *)(sp->_RecordCurrFrame )		= DummyProc_1 ;
	(iPROC *)(sp->_RecordFrame )			= DummyProc_1 ;
	
	(iPROC *)(sp->_SetDmsdType )			= DummyProc_1 ;

	(iPROC *)(sp->_LoadMatDigiFLcaData )	= DummyProc_1 ;
}


/*------------------------------------------ BlitDigiToWindow ---------*/
bool SetBlitDigiToWindow ( TBlitWindow *blitwind, POINT *zoom, TPictureFormat format )
{
	TBlitProcedure *blitproc ;

	blitproc = GetBlitDigiToWindow ( blitwind, zoom, format ) ;
	if ( blitproc != NULL )
	{
		ScreenEyeParameterBlock._BlitDigiToWindow = blitproc ;
		return TRUE ;
	}
	else
		return FALSE ;
}


/*------------------------------------------------- ShowInfo -------*/
void ShowInfo ( TScreenEyeParameterBlock *syp )
{
	if ( syp != NULL )
	{
		printf ( "ScreenEye parameter block ( $%08lx ) :\n", syp ) ;
		printf ( "version   : %u.%u\n", syp->version/10, syp->version%10 ) ;
		printf ( "magic     : %u\n", 	syp->magic ) ;
		printf ( "copyright : %s\n", 	syp->copyright ) ;
		printf ( "instance  : %u\n", 	syp->instance ) ;
		printf ( "*verbose  : $%04x\n", *syp->verbose ) ;
		printf ( "lock      : %u\n", 	syp->lock ) ;
		printf ( "dmsd      : %u\n", 	syp->DmsdParam->dmsd ) ;
	 ImageInfo ( "digitizer : ", 		&(syp->DigiParam->image) ) ;
	}
	else
		printf ( "* ScreenEyeParameterBlock undefined ( NULL )\n" ) ;
}

/* use ImageInfo direct	*/

# include "scryiacc.h"

char screye_cookie_name[] = MATscreyeCookie ;
bool cookie_write_ok = FALSE ;
extern COOKIE *screye_cookie ; /* scryiacc.c	*/


/*------------------------------------------ PressReturn -----------*/
void PressReturn ( void )
{
	printf ( PRESSreturn ) ;
	getchar() ;
}

/* ------------------------------------------------- SkipInput ------- */
bool SkipInput ( void )
{
	if ( ScreenEyeParameterBlock._AbortLoopFunction != NULL )
	{
		return (*(ScreenEyeParameterBlock._AbortLoopFunction))() ;
	}
	else
	{
		if ( ( Kbshift(-1) & 0xef ) != 0 )
			return TRUE ;
		else
			return FALSE ;
	}
}



/*--------------------------------------- write_screye_cookie --------*/
long write_screye_cookie ( void )
{
	cookie_write_ok = CK_WriteJar ( *(long *)screye_cookie_name, (long)&ScreenEyeParameterBlock ) ;
	return 0 ;
}

/*--------------------------------------- replace_screye_cookie --------*/
long replace_screye_cookie ( void )
{
	screye_cookie->value = (long)&ScreenEyeParameterBlock ;
	return 0 ;
}

/*---------------------------------------- TerminateResident -------*/
void TerminateResident ( bool doit )
{
	if ( doit )
	{
		printf ( INSTALLED ) ;
		Ptermres ( _PgmSize, 0 ) ;
	}
	else
	{
		printf ( COOKIEnotInstd ) ;
		screye_cookie = NULL ;
	}
}

/*---------------------------------------------- CheckHardWareOk ---------*/
bool CheckHardWareOk ( bool demo, TScreenEyeParameterBlock *sp )
{
	sp->DmsdParam->dmsd = demo ? NOdmsd : CheckScreenEyeHardware() ;
	if ( sp->DmsdParam->dmsd == NOdmsd )
	{
		printf ( NOTpresent ) ;
		PressReturn();
		ReplaceHotFunctions ( sp ) ;
		return FALSE ;
	}
	else
		return TRUE ;
}		


/*---------------------------------- UpdateScreenEyeParameterBlock -------*/
void UpdateScreenEyeParameterBlock ( TScreenEyeParameterBlock *sp )
{
	switch ( sp->DmsdParam->dmsd )
	{
case 9051 :	sp->DigiParam->image.w   = DIGdx9051 ;
			sp->DigiParam->image.bpl = DIGdx9051 * ( 16 / 8 ) ;
			break ;
case 7191 :	sp->DigiParam->image.w   = DIGdx7191 ;
			sp->DigiParam->image.bpl = DIGdx7191 * ( 16 / 8 ) ;
			break ;
	}
}

#define	unused(x)	(x)=(x)

/*------------------------------------------------------ printfnl --------*/
int printfnl ( const char *format, ... )
{
	int l ;
	
	l = vprintf ( format, (va_list)... ) ;
	l += printf ( "\n" ) ;

	return l ;
}

/*------------------------------------------------------ printnull --------*/
int printnull ( const char *format, ... )
{
	unused(format) ;
	return 0 ;
}


/*----------------------------------------------------------- main -------*/
int main ( int argc, char *argv[] )
{
	int  result, instresult ;
	bool demo = FALSE ;
	bool oldfound ;

# if TEST
	uprintf = printfnl ;
# else
	uprintf = printnull ;
# endif
	
	result  = OK ;
	verbose = 0 ;
	
	printf ( "Install %s\n", CopyRight ) ;
	if ( CheckJpegDriverLoaded() != OK )
		printf ( NOdspJpeg ) ;

	instresult = GetScreenEyeParameter() ;
	oldfound = ScreenEyeParameter != NULL ;
	if ( ! oldfound )
		ScreenEyeParameter = &ScreenEyeParameterBlock ;
				
	while ( argc > 1 )
	{
		argv++ ;
		argc-- ;
		if ( verbose > 1 )
			printf ( " %d-opt:'%s'", argc, *argv ) ;
		if ( (*argv)[0] == '-' )
		{
			switch ( (*argv)[1] )
			{
	case '?' :  printf ( 
"usage : screyeif [ -?|-vV/erb|-r/einst|-i/nfo|-u/nlk|-d/emo|-h/w|-tT/est ]\n" ) ;
				PressReturn();
				return OK ;
	case 'h' :  printf ( "- ScreenEye HW-status : %u\n",
							CheckScreenEyeHardware() ) ;
				PressReturn();
				return OK ;
	case 'D' :
	case 'd' :	demo = TRUE ;
				break ;
	case 'V' :	*(ScreenEyeParameter->verbose) = 0 ;
				uprintf = printnull ;
				break;
	case 'v' :	*(ScreenEyeParameter->verbose) = ++verbose ;
				uprintf = printfnl ;
				break;
	case 'T' :	*(ScreenEyeParameter->verbose) &= ~0x8000 ;
				break;
	case 't' :	*(ScreenEyeParameter->verbose) |= 0x8000 ;
				break;
	case 'R' :
	case 'r' :	if ( screye_cookie != NULL )	/* already installed	*/
				{
					ScreenEyeParameterBlock.instance = ScreenEyeParameter->instance + 1 ;
					printf ( REinstall, ScreenEyeParameterBlock.instance,
							ScreenEyeParameter,
							&ScreenEyeParameterBlock ) ;
					if ( CheckHardWareOk ( demo, &ScreenEyeParameterBlock ) )
						PressReturn();
					/* else "press Return !" done in CheckHW..	*/
					UpdateScreenEyeParameterBlock ( &ScreenEyeParameterBlock );
					Supexec ( replace_screye_cookie ) ;
					TerminateResident ( TRUE ) ;
					return OK ;
				}
				break ;
	case 'U' :
	case 'u' :	if ( oldfound )
				{
					printf ( "lock : %u\n", ScreenEyeParameter->lock ) ;
					ScreenEyeParameter->lock = 0 ;
					printf ( UNlocked ) ;
				}
				else
					printf ( NOTinstalled ) ;
				PressReturn();
				return OK ;
	case 'I' :
	case 'i' :	ShowInfo ( ScreenEyeParameter ) ;
				PressReturn();
				return OK ;
	default :	result = NotOK ;
				break ;
			}
		}
		else
			result = NotOK ;
		
		if ( result != OK )
		{
			printf ( "- illegal option : '%s'\n", *argv ) ;
			PressReturn();
			return OK ;
		}
	}

	if ( instresult != OK )
	{
		if ( ! oldfound )
		{
			CheckHardWareOk ( demo, &ScreenEyeParameterBlock ) ;
			UpdateScreenEyeParameterBlock ( &ScreenEyeParameterBlock );
			Supexec ( write_screye_cookie ) ;
			TerminateResident ( cookie_write_ok ) ;
		}
		else /* installed, but wrong magic	*/
		{
			printf ( "- found %s\n", ScreenEyeParameter->copyright ) ;
 			printf ( ILLEGALmagic ) ;
		}
	}
	else /* OK && ScreenEyeParameter valid, same version was installed	*/
	{
		printf ( "- found %s\n", ScreenEyeParameter->copyright ) ;
		printf ( WASinstalled ) ;
	}
	PressReturn();

	return ( OK ) ;
}