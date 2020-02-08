# define I2C_SETTLEtime 150 /* mSec */

# define SENSinit 0x90
# define GAINinit 0x00

typedef struct
{
	unsigned length ;
	unsigned char *data ;
} I2CdataBuffer ;

extern I2CdataBuffer DmsdData7191,
					 DmsdData9051 ;

extern byte	*i2c_bus ; /* global */

/* For MatDigi1 */
extern bool i2c_init ( unsigned format, unsigned source ) ;
extern int  GetSetDmsdRegister ( unsigned regnum, int newval) ;
extern bool LoadDmsdRegister ( void ) ;

extern void chk_set_chan_sig ( int *channel, int *signal, int *byps ) ;
extern void chk_set_signal ( int channel, int *signal, int *byps ) ;
extern bool set_lumi_cntrl ( int aper, int cori, int bpss, 
							 int pref, int byps ) ;
extern int  chk_set_video_standard ( unsigned standard ) ;
extern void GetDmsdStatus ( bool *locked, bool *code, bool *fidt ) ;
extern bool InitMdf ( unsigned signal, unsigned source, int chip ) ;
extern int  InitDmsd ( unsigned chip ) ;
extern unsigned CheckScreenEyeHardware ( void ) ;
extern void SetDmsdSlaveAddress ( unsigned chip ) ;

extern TDmsdParameter DmsdParameterBlock ;
