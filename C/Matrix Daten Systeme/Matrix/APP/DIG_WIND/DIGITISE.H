/*	digitise.h	/	 9.3.92	/	MATRIX	/	WA	*/
/*	MatDigi		/	15.9.93	/	MATRIX	/	HG	*/

# define I2C_SETTLEtime 150 /* mSec */

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

/* For MatDigiR */
extern int i2c_initrom ( unsigned signal, unsigned source ) ;

/* For MatDigi1 */
extern bool i2c_init ( unsigned format, unsigned source ) ;

extern void chk_set_chan_sig ( int *channel, int *signal, int *byps ) ;
extern void chk_set_signal ( int channel, int *signal, int *byps ) ;
extern bool set_lumi_cntrl ( int aper, int cori, int bpss, 
							 int pref, int byps ) ;
extern byte i2c_status ( void ) ;

# ifdef __MATDIGI1__
extern bool digi_init ( void ) ;
# endif __MATDIGI1__
