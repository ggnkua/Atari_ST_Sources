/********************************************************************/
/* 				Read/Write Y-C & RGB Video (for MATdigi)			*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 13.04.93												*/
/*																	*/
/*  WA - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*  HG - Mini-Version for MATdigi									*/
/*																	*/
/********************************************************************/


# define MONO 1
# define NTC  16

# define PIXWIDTH  768
# define PIXHEIGHT 544
# define GPIXWIDTH  (PIXWIDTH >> 1) 	/*384*/
# define GPIXHEIGHT (PIXHEIGHT >> 1) 	/*272*/

extern byte	*std_buffer ;
extern byte	*ras_buffer ;

/* YC (4:2:2) */
extern int double_yc				( YCpic *yc ) ;
extern void clear_yc				( YCpic *yc, long pattern ) ;
extern int fetch_and_save			( char * fname,
									  RECTangle *win,
									  POINT *vid,
									  YCpic *yc,
									  ESMpic *esm ) ;

extern int display_full_colour		( int vdi_handle,
									  RECTangle *win,
									  POINT *vid,
									  int planes ) ;

/* Grey (YC) in YC buffer */
extern int display_full_dither		( int vdi_handle,
									  RECTangle *win,
									  POINT *vid ) ;

extern int display_full_mono		( int vdi_handle,
									  RECTangle *win,
									  POINT *vid ) ;
									  
extern int display_full_grey		( int vdi_handle,
									  RECTangle *win,
									  POINT *vid,
									  int planes ) ;
									  
extern int display_full_grey_ntc	( int vdi_handle,
									  RECTangle *win,
									  POINT *vid ) ;

extern int repeat_colour			( int vdi_handle,
							  		  RECTangle *win,
							  		  POINT *vid,
							  		  int dx,
							  		  int dy,
							  		  int planes ) ;

/* Grey in standard buffer */
extern int repeat_grey				( int vdi_handle,
							  		  RECTangle *win,
							  		  POINT *vid,
							  		  int dx,
							  		  int dy,
							  		  int planes ) ;

extern int repeat_mono				( int vdi_handle,
							  		  RECTangle *win,
							  		  POINT *vid,
							  		  int dx,
							  		  int dy ) ;

/* Fast Grey (YY) in YC buffer */
extern int display_dither			( int vdi_handle,
								  	  RECTangle *win,
									  POINT *vid ) ;

extern int display_grey				( int vdi_handle,
									  RECTangle *win,
									  POINT *vid,
									  int planes ) ;
									  
extern int display_grey_ntc			( int vdi_handle,
					   				  RECTangle *win,
					   				  POINT *vid ) ;

extern int display_mono				( int vdi_handle,
							  		  RECTangle *win,
							  		  POINT *vid ) ;


/* ESM (RGB) */
extern void clear_esm		( ESMpic *esm, int w, int h, long pattern ) ;
extern int display_rgb		( ESMpic *rgb,
							  byte *dp,
							  int x, int y, int w, int h,
							  unsigned bpl ) ;

/* YC & ESM */
extern int  save_video_file ( char *name, YCpic *yc, ESMpic *esm ) ;
extern int  load_video_file ( char *name, YCpic *yc, ESMpic *esm ) ;
extern int cut_and_save 	( char *file, RECTangle *win,
										  YCpic *yc, ESMpic *esm ) ;

/* General Routines */
extern int init_vidig ( int w, int h ) ;
extern void term_vidig ( void ) ;
extern long video_status ( void ) ;
extern void video_info ( void ) ;

/* Buffers */
extern YCpic  yc_buffer ;
extern ESMpic esm_buffer ;
