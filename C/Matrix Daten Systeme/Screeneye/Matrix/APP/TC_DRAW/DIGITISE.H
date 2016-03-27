/*	digitise.h	/	 9.3.92	/	MATRIX	/	WA	*/
/*	MatDigi		/	30.7.92	/	MATRIX	/	HG	*/

# define MINvfactor	1
# define MAXvfactor	8
# define MAXvframes 9999

# define COLOUR_DISPLAY 0
# define GREY_DISPLAY 1

# define I2C_SETTLEtime 100 /* mSec */

# define PUP_AUTO 0
# define PUP_PAL 1
# define PUP_NTSC 2
# define PUP_SECAM 3
# define PUP_VTR 0
# define PUP_TV 1
# define PUP_SVHS 1
# define PUP_FBAS 2
# define PUP_BAS 3

# define SENSinit 0x90
# define GAINinit 0x00

typedef struct
{
	int factor ;
	int frames ;
	RECTangle window ;
} VIDEO_WINDOW ;

extern VIDEO_WINDOW *curr_video ;
extern VIDEO_WINDOW video ;

extern bool	video_on ;

extern int g_check_init ( void ) ;	/* for demo.c only	*/
extern bool digitiser_running ( void ) ;
extern int digitise_video ( bool with_grab, int dmode, int matbpp ) ;
extern void digitiser_stop ( void ) ;
extern int current_frame ( void ) ;

/* For MatDigi */
extern bool tcbpp ( int *bpp ) ;

extern bool digi_init ( void ) ;
extern bool	i2c_init ( void ) ;
extern bool csc_vlut_init ( void ) ;
extern void lumi_cntrl_init ( int *aper, int *cori, int *bpss, 
							  int *pref, int *byps ) ;

extern void chk_set_chan_sig ( int *channel, int *signal, int *byps ) ;
extern void chk_set_std ( int source, int *standard, int *sensitivity ) ;
extern void chk_set_signal ( int channel, int *signal, int *byps ) ;
extern bool set_lumi_cntrl ( int aper, int cori, int bpss, 
							 int pref, int byps ) ;
extern bool set_gain ( int gain ) ;
extern bool set_sensitivity ( int standard, int sensitivity ) ;

extern void toggle_hardware ( void ) ;
