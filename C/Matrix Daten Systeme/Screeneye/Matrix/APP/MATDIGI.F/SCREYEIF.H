/********************************************************************/
/*																	*/
/* 	ScreenEye Interface : parameter structure definitions			*/
/*																	*/
/*	screyeif.h / 15.4.94											*/
/*																	*/
/*  (c) 1994 Matrix Daten Systeme GmbH								*/
/*		Talstr. 16, D-71570 Oppenweiler								*/
/*																	*/
/********************************************************************/

# ifndef __SCREYEIF__
# define __SCREYEIF__

/* *** note :	Access to ScreenEye parameter and functions		*/
/*				via macros, defined in 'scryiacc.h'				*/

typedef void TBlitProcedure ( TBlitWindow *blitwind, POINT *zoom ) ;

typedef struct { unsigned mask, shift, sign, rndofs ; } TYCtoF8format ;

typedef struct
{
	TImage			image ;
	TYCtoF8format	*YcToF8Format ;
	bool			waituntilgrabbed ;	/* digitise parameter	*/
} TDigiParameter ;

# ifndef __JPGDH__
	struct _JPGD_STRUCT { int dummy ; } ;
# endif

typedef struct
{
	unsigned		version ;
	unsigned		magic ;
	char 			*copyright ;
	unsigned		instance ;
	int				lock ;				/* 0 = released	*/

	int				*verbose ;
	TDigiParameter	*DigiParam ;
	TDmsdParameter	*DmsdParam ;

	long			reserved[25] ;

	int 			(*_GetSetDmsdRegister) ( unsigned regnum, int newval ) ;
	bool 			(*_LoadDmsdRegister) ( void ) ;

# ifndef HIDEfunctions

	TBlitProcedure *(*_GetBlitDigiToWindow) ( TBlitWindow *blitwind, POINT *zoom, TPictureFormat format ) ;

								/* blit functions, source = ScreenEye local memory		*/
	TBlitProcedure
		*_BlitDigiToWindow,		/* general blit procedure, set by SetBlitDigiToWindow	*/
		*_BlitP8ColorWindow,	/* specific blit procedures								*/
		*_BlitP8GreyWindow,
		*_BlitF7GreyWindow,
		*_BlitGreyWindow,
		*_Blit555SWWindow,
		*_Blit555HWSimWindow,
		*_Blit555Window,
		*_BlitRGBWindow,
		*_BlitF332Window,
		*_BlitF8GreyWindow,
		*_BlitFyc224Window ;

    /* debug functions : print info about structure, info = header string 	*/

	void (*_ImageInfo) ( char *info, TImage *img ) ;
	void (*_WindowInfo) ( char *info, TRectangle *wnd ) ;
	void (*_BlitWindowInfo) ( TBlitWindow *blitwind ) ;
	void (*_ImageWindowInfo) ( char *info, TImageWindow *imgwnd ) ;

    /* initialise 'imgwnd' to full size 'w':'h' */
	void (*_SetToFullSize) ( TImageWindow *imgwnd, void *data, int w, int h, int planes ) ;

	/* get start address of 'imgwnd->window'	*/
	void *(*_PixelPosition) ( TImageWindow *imgwnd ) ;

	/* initialise color space conversion tables	*/
	void (*_InitGreyTo555Table) ( void ) ;
	void (*_InitGreyTo555TableWithColors) ( void ) ;

    /* debug function : show histogram 	*/
	void (*_ShowHisto) ( char name, unsigned long *h, int maxi ) ;

    /* digitise one field into local ScreenEye-field memory	*/
	unsigned (*_GrabFieldIntoFifo) ( bool wait, TFieldType field ) ;

    /* digitise one frame into 'blitwind', 'wait' for end of digitising before transfer	*/
	void (*_DigitiseFrame) ( TBlitWindow *blitwind, POINT *zoom, bool wait ) ;

	/* reset ScreenEye digitiser logic	*/
	void (*_ResetGrabber) ( void ) ;

	/* digitiser parameter set / check functions	*/
	int  (*_chk_set_video_standard) ( unsigned standard ) ;
	void (*_chk_set_chan_sig) ( int *channel, int *signal, int *byps ) ;
	void (*_chk_set_signal) ( int channel, int *signal, int *byps ) ;
	bool (*_set_lumi_cntrl) ( int aper, int cori, int bpss, 
							 int pref, int byps ) ;
	void (*_GetDmsdStatus) ( bool *locked, bool *code, bool *fidt ) ;
	bool (*_InitMdf) ( unsigned signal, unsigned source, int chip ) ;
	int  (*_InitDmsd) ( unsigned chip ) ;

	/* digitise into picture matrix 'nx':'ny'	*/
	void (*_DigitiseMatrix) ( int nx, int ny, TBlitWindow *blitwind, POINT *zoom, bool wait ) ;

    /* interpolate 555 - rgb picture 'source' to 'destin'	*/
	void (*_InterPolate555) ( TImageWindow *source, TImageWindow *destin, POINT *zoom ) ;

    /* stretch 'source'-image to ( smaller ) 'destin' - image ( 555 rgb )	*/
	void (*_StretchBlit) ( TImageWindow *source, TImageWindow *destin ) ;

	/* write 555 rgb data :	*/
    /*  - split into r,g, and b - file	*/
	int (*_WriteRGBFiles) ( char *filename, int w, int h, uword *data ) ;
    /*  - targa format	*/
	int (*_WriteTargaFile) ( char *filename, int w, int h, uword *data ) ;

	/* write one 'frame' of 'sequence'	*/
	int (*_WriteFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
    /* write film sequence header	*/
	int (*_WriteSequenceHeader) ( SEQUENCE *sequence, char *basename, uword format ) ;
    /* write frame 'from'..'to' from 'sequence'	*/
	int (*_SequenceWrite) ( SEQUENCE *sequence, char *basename, int from, int to, uword format ) ;

    /* read one 'frame'	into 'sequence', 'basename' without extension and number : ....NNNN.EXT	*/
	int (*_ReadTargaFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
	int (*_ReadBlockFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
	int (*_ReadFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;

	/* read film sequence header	*/
	int (*_ReadSequenceHeader) ( SEQUENCE *sequence, char *basename ) ;
	/* read frame 'from'..'to' into 'sequence'	*/
	int (*_SequenceRead) ( SEQUENCE *sequence, char *basename, int from, int to ) ;

    /* release conversion buffers, used internally by some read/write functions	*/
	void (*_FreeConvBuffer) ( void ) ;

    /* initialise 'sequence' - structure	*/
	int (*_InitSequence) ( SEQUENCE *sequence ) ;
    /* malloc 'nreq' frame buffers to 'sequence'	*/
	int (*_MallocSequence) ( SEQUENCE *sequence, int nreq, TImageWindow *srcwnd, POINT *zoom ) ;
    /* release frame buffers	*/
	void (*_FreeSequence) ( SEQUENCE *sequence ) ;
    /* debug output */
	void (*_SequenceInfo) ( SEQUENCE *sequence ) ;
    /* record continuous sequence	*/
	int (*_RecordSequence) ( SEQUENCE *sequence, bool wait ) ;
    /* play continuous seqeunce	*/
	int (*_PlaySequence) ( SEQUENCE *sequence, TImageWindow *dstwnd ) ;

	/* step by step record / play procedures	*/
    /* record setup	*/
	int (*_RecordStart) ( SEQUENCE *sequence ) ;
    /* record stop */ 
	int (*_RecordStop) ( SEQUENCE *sequence ) ;
    /* restart after stop	*/
	int (*_RecordRestart) ( SEQUENCE *sequence ) ;
	/* record current frame of 'sequence'	*/
	int (*_RecordCurrFrame) ( SEQUENCE *sequence, bool wait ) ;
    /* record 'frame' of 'seqeunce'	*/
	int (*_RecordFrame) ( SEQUENCE *sequence, int frame, bool wait ) ;

    /* play setup	*/
	int (*_PlayStart) ( SEQUENCE *sequence, int step ) ;
    /* play restart setup	*/
	int (*_PlayRestart) ( SEQUENCE *sequence ) ;
    /* stop play seqeunce	*/
	int (*_PlayStop) ( SEQUENCE *sequence ) ;

    /* display current frame, syncronised by time code	*/
	int (*_PlaySyncCurrent) ( SEQUENCE *sequence ) ;

    /* set current frame pointer to 'frame'	*/
	TValid (*_ActivateFrame) ( SEQUENCE *sequence, int frame ) ;
    /* display current frame	*/
	int (*_DisplayCurrentFrame) ( SEQUENCE *sequence, TImageWindow *dstwnd ) ;

	/* set current frame pointer to 'frame', check before setting	*/
	int (*_ChkAndSetCurrentFrame) ( SEQUENCE *sequence, int frame ) ;
    /* display 'frame' of 'sequence' to 'dstwnd'	*/
	int (*_DisplayFrame) ( SEQUENCE *sequence, int frame, TImageWindow *dstwnd ) ;

   	/* pointer to user function, returns true if continuous abort requested	*/
	bool (*_AbortLoopFunction) ( void ) ;

   	/* pointer to user function, cyclic called from DSP-JPEG	*/
	short (*_JpegUserRoutine)(struct _JPGD_STRUCT *);

	int (*_SetDmsdType) ( int chip, unsigned lcatyp ) ;
    /* reset 'blitwind'	*/ 
	void (*_ResetDigiWindows) ( TBlitWindow *blitwind ) ;
	/* check 'blitwind' & 'dstimg' - parameter	*/
	void (*_CheckDigiWindows) ( TBlitWindow *blitwind, POINT *zoom, TImage *dstimg ) ;
    /* configure ScreenLogic logic for the given parameters	*/ 
	int (*_LoadMatDigiFLcaData) ( unsigned chip, TDigitiserMode mode, POINT *zoom, bool init ) ;

    /* color space conversion : y,cr,cb -> 24 bit rgb	*/
	byte *(*_yuv_to_rgb) ( byte *out, uword y, uword cr, uword cb ) ;
    /* check if CSC tables are calculated, if not, do it	*/
	void (*_CheckCalcCSCtables) ( int *coeff ) ;

# endif HIDEfunctions
} TScreenEyeParameterBlock ;

# endif __SCREYEIF__
