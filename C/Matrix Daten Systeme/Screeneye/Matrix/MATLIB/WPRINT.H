/* wprint.h / 13.09.90 / MATRIX / WA */

extern POINT cursor ;

extern int v_printf(int handle, int x, int y, const char *format, ... );
extern int w_printf( RECTangle *work, const char *format, ... );
extern void dis_text( int color, int x, int y, char *s);
