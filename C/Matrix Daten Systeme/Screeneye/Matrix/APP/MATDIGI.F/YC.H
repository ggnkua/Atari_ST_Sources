extern void yc_to_ntc_window ( uword *ycdata,  int sbpl,
				  		uword *ntcdata, int dbpl,
						int   w, 	    int h,
						int   mode   ) ;
extern void print_ntc ( uword ntc, char *es ) ;
extern void print_yc ( uword *yc, int odd, char *es ) ;
extern uword Cyuv_to_ntc ( uword y, uword cr, uword cb ) ;
extern uword CyuvToNtcNoClip ( uword y, uword cr, uword cb ) ;
extern byte *yuv_to_rgb ( byte *out, uword y, uword cr, uword cb ) ;
extern byte *yuv_to_bgr ( byte *out, uword y, uword cr, uword cb ) ;

extern void CheckCalcCSCtables ( int *coeff ) ;
extern void CalcCSCtables ( int *coeff ) ;
extern void InitYC ( void ) ;

# define DEFAULTycCoeff { 351, -179, -86, 443 }
# define Kcrr	0
# define Kcrg	1
# define Kcbg	2
# define Kcbb	3

extern int DefaultYCcoeff[] ;
