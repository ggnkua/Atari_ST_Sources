/* digiblix.h	*/

# define USEhisto	1

extern byte  	*GreyBuffer ;
extern bool 	ClipConversion,
				GrabBeforeDisplay ;

typedef enum { GMnormal, GMzoomG8 } TGrabMode ;

extern TGrabMode GrabMode ;

typedef uword (*YUVtoNTCproc) ( uword y, uword cr, uword cb ) ;
extern YUVtoNTCproc _Cyuv_to_ntc ;

extern int test ;

# if USEhisto
extern unsigned long YDhisto[256] ;
extern unsigned long Yhisto[256] ;
extern unsigned long Uhisto[256] ;
extern unsigned long Vhisto[256] ;
extern unsigned long Rhisto[256] ;
extern unsigned long Ghisto[256] ;
extern unsigned long Bhisto[256] ;
extern unsigned long UDhisto[4][4] ;
extern unsigned long VDhisto[4][4] ;

extern ulong SumDelta, NDelta ;
# endif

extern uword *pixel_position ( uword *base, int x, int y, int bpl ) ;

extern void SetCntrlReg ( byte val ) ;
extern byte GetCntrlReg ( void ) ;


extern void ImageInfo ( char *info, TImage *img ) ;
extern void WindowInfo ( char *info, TRectangle *wnd ) ;
extern void BlitWindowInfo ( TBlitWindow *blitwind ) ;
extern void ImageWindowInfo ( char *info, TImageWindow *imgwnd ) ;

extern void SetToFullSize ( TImageWindow *imgwnd, void *data, int w, int h, int planes ) ;

extern void *PixelPosition ( TImageWindow *imgwnd ) ;

extern void InitGreyTo555Table ( void ) ;
extern void InitGreyTo555TableWithColors ( void ) ;
extern void ShowHisto ( char name, unsigned long *h, int maxi ) ;

extern unsigned GrabFieldIntoFifo ( bool wait, TFieldType field ) ;

extern void DigitiseFrame ( TBlitWindow *blitwind, POINT *zoom, bool wait ) ;
extern void ResetGrabber ( void ) ;

extern void BlitFyc224Window ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitF8GreyWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitF7GreyWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitGreyWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void Blit555SWWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void Blit555HWSimWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void Blit555WindowTest ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void Blit555Window ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitF332Window ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitRGBWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitP8GreyWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
extern void BlitP8ColorWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
