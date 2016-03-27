extern void Skip ( uword *port, int n ) ;
extern void SkipW ( uword *port, int n ) ;
extern void Blit555Rect ( uword *in, uword *out, int w, int h, int incin, int incout ) ;

extern uword *MoveYCToFyc224 ( uword *out, uword *port, int n, unsigned zoomx ) ;
extern uword *MoveYCToF8Grey ( uword *out, uword *port, int n, unsigned zoomx ) ;
extern uword *MoveYCToF7Grey ( uword *out, uword *port, int n, unsigned zoomx ) ;
extern uword *Move555ToF332Color ( uword *out, uword *port, int n, unsigned zoomx ) ;
extern uword *Move555To555Color ( uword *out, uword *port, int n, unsigned zoomx ) ;
extern uword *MoveYCTo555Grey ( uword *out, uword *port, int n, unsigned zoomx ) ;
extern uword *MoveRegisterFile ( uword *out, uword *port ) ;
extern uword *MoveWordRegisterFiles ( uword *out, uword *port, int n ) ;
extern uword *MoveByteRegisterFiles ( uword *out, uword *port, int n ) ;
extern uword *MoveZXByteRegisterFiles ( uword *out, uword *port, int n, int zx ) ;
extern uword yuv_to_ntc ( uword y, uword cr, uword cb ) ;

extern int add32_clip8 ( int a8, long b32 ) ;
extern uword yc_to_ntc ( int y0cb, int y1cr ) ;
extern void yc_ntc_line ( uword *sd, uword *dd, int w ) ;
extern void yc_gray_line ( uword *sd, uword *dd, int w ) ;
