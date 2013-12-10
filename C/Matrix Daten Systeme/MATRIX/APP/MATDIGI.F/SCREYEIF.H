/* screyeif.h	/	28.10.93	*/

typedef void TBlitProcedure ( TBlitWindow *blitwind, POINT *zoom ) ;

typedef struct
{
	unsigned mask, shift, sign, rndofs ;
} TYCtoF8format ;

typedef struct
{
	TImage			image ;
	TYCtoF8format	*YcToF8Format ;
	bool			waituntilgrabbed ;	/* digitise parameter	*/
} TDigiParameter ;


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

	long			reserved[32] ;

# ifndef HIDEfunctions	
	TBlitProcedure	*_BlitGreyWindow,
					*_Blit555SWWindow,
					*_Blit555HWSimWindow,
					*_Blit555Window,
					*_BlitRGBWindow,
					*_BlitF332Window,
					*_BlitF8GreyWindow,
					*_BlitFyc224Window ;

	void (*_ImageInfo) ( char *info, TImage *img ) ;
	void (*_WindowInfo) ( char *info, TRectangle *wnd ) ;
	void (*_BlitWindowInfo) ( TBlitWindow *blitwind ) ;
	void (*_ImageWindowInfo) ( char *info, TImageWindow *imgwnd ) ;

	void (*_SetToFullSize) ( TImageWindow *imgwnd, void *data, int w, int h, int planes ) ;

	void *(*_PixelPosition) ( TImageWindow *imgwnd ) ;

	void (*_InitGreyTo555Table) ( void ) ;
	void (*_InitGreyTo555TableWithColors) ( void ) ;
	void (*_ShowHisto) ( char name, unsigned long *h, int maxi ) ;

	unsigned (*_GrabFieldIntoFifo) ( bool wait, TFieldType field ) ;

	void (*_DigitiseFrame) ( TBlitWindow *blitwind, POINT *zoom, bool wait ) ;
	void (*_ResetGrabber) ( void ) ;

	int  (*_chk_set_video_standard) ( unsigned standard ) ;
	void (*_chk_set_chan_sig) ( int *channel, int *signal, int *byps ) ;
	void (*_chk_set_signal) ( int channel, int *signal, int *byps ) ;
	bool (*_set_lumi_cntrl) ( int aper, int cori, int bpss, 
							 int pref, int byps ) ;
	void (*_GetDmsdStatus) ( bool *locked, bool *code, bool *fidt ) ;
	bool (*_InitMdf) ( unsigned signal, unsigned source, int chip ) ;
	int  (*_InitDmsd) ( unsigned chip ) ;


	void (*_DigitiseMatrix) ( int nx, int ny, TBlitWindow *blitwind, POINT *zoom, bool wait ) ;
	void (*_InterPolate555) ( TImageWindow *source, TImageWindow *destin, POINT *zoom ) ;
	void (*_StretchBlit) ( TImageWindow *source, TImageWindow *destin ) ;

	int (*_WriteRGBFiles) ( char *filename, int w, int h, uword *data ) ;
	int (*_WriteTargaFile) ( char *filename, int w, int h, uword *data ) ;
	int (*_WriteFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
	int (*_WriteSequenceHeader) ( SEQUENCE *sequence, char *basename, uword format ) ;
	int (*_SequenceWrite) ( SEQUENCE *sequence, char *basename, int from, int to, uword format ) ;

	int (*_ReadTargaFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
	int (*_ReadBlockFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
	int (*_ReadFrame) ( SEQUENCE *sequence, char *basename, int frame ) ;
	int (*_ReadSequenceHeader) ( SEQUENCE *sequence, char *basename ) ;
	int (*_SequenceRead) ( SEQUENCE *sequence, char *basename, int from, int to ) ;

	void (*_FreeConvBuffer) ( void ) ;

	int (*_InitSequence) ( SEQUENCE *sequence ) ;
	int (*_MallocSequence) ( SEQUENCE *sequence, int nreq, TImageWindow *srcwnd, POINT *zoom ) ;
	void (*_FreeSequence) ( SEQUENCE *sequence ) ;
	void (*_SequenceInfo) ( SEQUENCE *sequence ) ;
	int (*_RecordSequence) ( SEQUENCE *sequence, bool wait ) ;
	int (*_PlaySequence) ( SEQUENCE *sequence, TImageWindow *dstwnd ) ;

	int (*_RecordStart) ( SEQUENCE *sequence ) ;
	int (*_RecordStop) ( SEQUENCE *sequence ) ;
	int (*_RecordRestart) ( SEQUENCE *sequence ) ;
	int (*_RecordCurrFrame) ( SEQUENCE *sequence, bool wait ) ;
	int (*_RecordFrame) ( SEQUENCE *sequence, int frame, bool wait ) ;

	int (*_PlayStart) ( SEQUENCE *sequence, int step ) ;
	int (*_PlayRestart) ( SEQUENCE *sequence ) ;
	int (*_PlayStop) ( SEQUENCE *sequence ) ;

	int (*_PlaySyncCurrent) ( SEQUENCE *sequence ) ;

	TValid (*_ActivateFrame) ( SEQUENCE *sequence, int frame ) ;
	int (*_DisplayCurrentFrame) ( SEQUENCE *sequence, TImageWindow *dstwnd ) ;

	int (*_ChkAndSetCurrentFrame) ( SEQUENCE *sequence, int frame ) ;
	int (*_DisplayFrame) ( SEQUENCE *sequence, int frame, TImageWindow *dstwnd ) ;

	bool (*_AbortLoopFunction) ( void ) ;

	int (*_LoadMdfLcaFile) ( char typ, unsigned ver, unsigned rel ) ;

	int (*_SetDmsdType) ( int chip, unsigned lcatyp ) ;
	void (*_ResetDigiWindows) ( TBlitWindow *blitwind ) ;
	void (*_CheckDigiWindows) ( TBlitWindow *blitwind, POINT *zoom,
							   TImage *dstimg ) ;
	int (*_LoadMatDigiFLcaData) ( unsigned chip, TDigitiserMode mode, POINT *zoom, bool init ) ;

	byte *(*_yuv_to_rgb) ( byte *out, uword y, uword cr, uword cb ) ;
	void (*_CheckCalcCSCtables) ( int *coeff ) ;

# endif HIDEfunctions
} TScreenEyeParameterBlock ;
