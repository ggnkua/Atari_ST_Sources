/* ----------- ROM PORT control--------------------------------- */
extern void	grab_rom 		( int vfactor ) ;
extern void	set_rom_vfact	( int vfactor ) ;
extern void wait_grab		( void ) ;

/* ----------- ROM PORT ( RGB data --> RGB-buffer ) -------------- */
extern void	fetch_rom_init	( void  ) ;
extern void	frpr_getline	( void *rgb, int source ) ;
extern byte *writeadd32_clip8 ( byte *p, int a8, long b32 ) ;

/* ----------- ROM PORT ( YC/YY data --> YC-buffer ) -------------- */
extern void	fetch_rom_pic	( void *yc, int dx, int dy ) ;
extern void	fetch_2rom_pic	( void *yc, int dx, int dy ) ;
extern void	frp_getline		( void *yc, void *source, int dx ) ;

/* ----------- ROM PORT ( Y-Y fast grey data ) ----------------- */
extern void Y_to_2grey		( void *yy, void *yc, int dy, int planes ) ;
extern void	Alt_Y_to_2grey	( void *yy, int dy, int planes ) ;
extern void	Y_to_2mono		( void *yy, int dy ) ;
extern void	Y_to_2dith		( void *yy, int dy ) ;
extern void Y_to_2grey_ntc	( void *yy, int dy ) ;

/* ----------- ROM PORT ( Y-C grey data ) ---------------------- */
extern void Y_to_dith		( void *buffer, int lines ) ;
extern void Y_to_mono		( void *buffer, int lines ) ;
extern void Y_to_grey		( void *buffer, void *ycbuf, int lines, int planes ) ;
extern void Alt_Y_to_grey	( void *buffer, void *dummy, int lines, int planes ) ;
extern void Y_to_grey_ntc 	( void *buffer, int lines ) ;

/* ----------- ROM PORT ( Y-C colour data ) -------------------- */
extern int add32clip8 		( int a8, long b32 ) ;
extern void Y_to_332		( void *buffer, void *ycbuf, int lines ) ;
extern void Y_to_ntc		( void *buffer, int lines ) ;

