/* i2c.h / 4.10.91 / MATRIX /	WA	*/
/*       / 22.3.93 / MATRIX /	TR&HG	*/

typedef byte I2C_BUS ;


extern void i2c_stop 	( I2C_BUS *i2cbus ) ;
extern void i2c_release ( I2C_BUS *i2cbus ) ;
extern int  i2c_swrite  ( I2C_BUS *i2cbus, int slave,
					      int count, bool stop, byte *data ) ;
extern int  i2c_read    ( I2C_BUS *i2cbus, int slave, int count, byte *data ) ;

# define i2c_write(b,s,n,dp)  i2c_swrite(b,s,n,TRUE,dp)


extern	bool i2c_romport ;



/* special macros & routines for e2prom  PCF 8582 A  etc.		*/

# define E2PROM	0xa0

# define e2prom_read(b,n,dp)	 i2c_read(b,E2PROM,n,dp)
# define e2prom_aread(b,n,ap,dp) i2c_swrite(b,E2PROM,1,FALSE,ap) != OK \
									? NotOK : i2c_read(b,E2PROM,n,dp)
extern int e2prom_write ( I2C_BUS *i2cbus, int count, byte *data ) ;

