extern uword col555 ( int r, int g, int b ) ;
extern uword col16 ( int r, int g, int b ) ;
extern void frect555 ( int x, int y, int w, int h, uword color ) ;
extern void frect ( int x, int y, int w, int h,
			 int r, int g, int b ) ;
extern void ColorRun ( int x, int y, int dx, int dy, int r, int g, int b ) ;
extern void TestRun ( void ) ;
extern void TestScreen ( void ) ;
extern void yc_pixel_info ( uword *base, int x, int y, int bpl ) ;
extern void pixel_info ( uword *ycdata, int ycbpl, int maxx, int maxy ) ;
extern void display_file ( char *name, unsigned mode ) ;

