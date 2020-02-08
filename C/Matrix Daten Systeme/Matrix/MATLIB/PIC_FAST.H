extern byte *add32_clip8 ( byte *p, int a8, long b32 ) ;
extern byte *conv411 ( byte *buf411, byte *bufY ) ;
extern int  get411Y  ( byte *buf411, byte *bufY, int count ) ;
extern void Y_to_tt4 ( byte *buf411, byte *screen, int count ) ;
extern void Y_to_cx8 ( byte *buf411, byte *screen, int count ) ;
extern byte *swap_buffer ( byte *buf411, int count ) ;
