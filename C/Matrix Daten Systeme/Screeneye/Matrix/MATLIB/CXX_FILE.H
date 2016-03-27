extern void get_moc_palette ( PALETTE *mocpal ) ;
extern void set_moc_palette(PALETTE *mocpal) ;
extern void set_vid_palette(byte **in_buffer,int levels) ;
extern int mcc_def_malloc ( MCCpic *mccpic ) ;
extern int moc_def_malloc ( MOCpic *mocpic ) ;
extern int cxx_compress (	int x, int y, int w, int h,
					MCCpic *mccpic ) ;
extern int cxx_uncompress ( int x, int y, MCCpic *mccpic ) ;
extern int cxx_get_moc (	int x, int y, int w, int h,
					MOCpic *mocpic ) ;

extern int cxx_limits ( int *x, int *y, int *w, int *h ) ;
extern void calc_disp_rect ( PIChead *pichead,
						int x0, int y0, int dx, int dy,
						Point *dim ) ;
extern void center_disp_rect ( Point *dim, Point *pos ) ;

extern unsigned init_cxx_file ( void ) ;


