/*	md_fast.h	/	MATRIX	/	29.01.93	*/


/* ----------- ROM PORT ( Y-C 4:4:2 data ) --------------------- */
# if 0
extern void		grab_rom 		( int vfactor ) ;
extern void		set_rom_vfact	( int vfactor ) ;
extern void		fetch_rom_pic	( void *yc, int dx, int dy ) ;
extern void		fetch4_rom_pic	( void *yc, int dx, int dy ) ;
extern void		fetch2_rom_pic	( void *yc, int dx, int dy ) ;
# endif

/* ----------- VME PORT ( Y-C or RGB data ) -------------------- */
extern void		set_vfact 		( int vfactor ) ;
extern void		grab_vme	 	( void ) ;
extern byte		fetch_yc_tc		( void *yc, int dx, int dy,
								  int dline ) ;
extern byte		fetch_rgb_tc	( void *rgb, int dx, int dy,
								  int dline ) ;




/* output byte, word or long bit-serially e.g. for OnCE */
extern void send_long ( byte *port, long l ) ;
extern void send_byte ( byte *port, byte b ) ;
extern void send_data ( byte *port, long l, int n ) ;

/* read byte, word or long bit-serially e.g. from OnCE */
extern long rec_long ( byte *port ) ;
extern byte rec_byte ( byte *port ) ;
extern long rec_data ( byte *port, int n ) ;

/* simple in & output */
extern void out_word ( uword *port, uword w ) ;
extern uword in_word ( uword *port ) ;
extern void or_word  ( uword *port, uword w ) ;
extern void and_word ( uword *port, uword w ) ;

/* simple bit setting & clearing */
extern void set_bit ( uword *port, unsigned bnum ) ;
extern void clr_bit ( uword *port, unsigned bnum ) ;

/* write as 2 words, high word first e.g. for HOST extending if needed */
extern void h_out_byte ( ulong *port, byte b ) ;
extern void h_out_word ( ulong *port, uword w ) ;
extern void h_out_long ( ulong *port, ulong l ) ;


