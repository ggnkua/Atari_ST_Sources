extern byte *conv411	( byte *buf411, byte *bufY ) ;
extern int  get411Y 	( byte *buf411, byte *bufY, int count ) ;

extern byte *add32_clip8( byte *p, int a8, long b32 ) ;

extern void Y_to_cx8 ( byte *buf422, byte *screen, int count, int dummy ) ;
extern void Y_to_tc  ( byte *buf422, byte *screen, int count, int dummy ) ;
# if 0
extern void Y_to_tt4	( void *buffer, int lines ) ;
extern void Y_to_fa8	( void *buffer, int lines ) ;
extern void Y_to_tc		( void *buffer, int lines ) ;
extern void Y_to_ntc	( void *buffer, int lines ) ;
# endif