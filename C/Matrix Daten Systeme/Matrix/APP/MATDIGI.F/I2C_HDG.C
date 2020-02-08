/* i2c.c / 4.11.91 / MATRIX /	WA	*/
/*       / 24.4.92 / MATRIX /	TR&HG	*/

# define MAIN 0
# define TEST 1

# if MAIN || TEST
#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <string.h>
#include <ctype.h>
#include <tos.h>
# endif

# include <global.h>
# include <error.h>
# include <traps.h>

# include "i2c_hdg.h"

extern int verbose ;

# define I2C_WRITE	0x00	/*	i2c command bit 0	*/
# define I2C_READ	0x01


/* 	i2c bus register :				xxxx.xxrd	*/

# define I2C_DATA		0x01	/*			^	*/
# define I2C_CLOCK		0x02	/*		   ^	*/


bool	i2c_romport = FALSE ;

# define i2c_setscl(p) dummy = (*(p + 0x4000))
# define i2c_resscl(p) dummy = (*(p + 0x5000))
# define i2c_setsda(p) dummy = (*(p + 0x6000))
# define i2c_ressda(p) dummy = (*(p + 0x7000))
# define i2c_get(p)	(*(p))

/*---------------------------------------- i2c_set ----------------*/
void i2c_set ( I2C_BUS *i2cbus, int dout )
{
	byte	dummy ;

	if ( ! i2c_romport )
		*i2cbus = dout ;
	else switch ( dout )
	{
case 0 :	i2c_ressda ( i2cbus ) ;
			i2c_resscl ( i2cbus ) ;
			break ;
case 1 :	i2c_setsda ( i2cbus ) ;
			i2c_resscl ( i2cbus ) ;
			break ;
case 2 :	i2c_ressda ( i2cbus ) ;
			i2c_setscl ( i2cbus ) ;
			break ;
case 3 :	i2c_setsda ( i2cbus ) ;
			i2c_setscl ( i2cbus ) ;
default :	;
	} 
	dummy = dummy ;					/* fool compiler */
}

/*------------------------------------------- delay_us -------------*/
void delay_us ( int us )
{
	int i, a ;
	
	for ( i = 0 ; i < us ; i++ )
	{
		a = i * i ;	/* delay 1 us ? cache ?	*/
		a = a ;
	}
}

/*---------------------------------------- i2c_clock ---------------*/
int i2c_clock ( I2C_BUS *i2cbus, int dout )
/*
	output clock puls on i2c bus,
	samples data bit value in the middle of the clock pulse

									dout
	SDA		   -+---------------+	 1
				X
			   -+---------------+	 0

					  sample
						v
	SCL				+---X---+
					|		|
			   -+---+.......+---+-
	time (us)	| 2 | 2 | 2 | 2 |
*/
{
	int din ;

	i2c_set ( i2cbus, dout ) ;
	delay_us ( 2 ) ;
	i2c_set ( i2cbus, I2C_CLOCK | dout ) ;
	delay_us ( 2 ) ;
	din = i2c_get ( i2cbus ) & I2C_DATA ;
	delay_us ( 2 ) ;
	i2c_set ( i2cbus, dout ) ;
	delay_us ( 2 ) ;
	return ( din ) ;
}


/*---------------------------------------- i2c_start ---------------*/
int i2c_start ( I2C_BUS *i2cbus )
/*
	output start condition on i2c bus

	SDA		   -+
				|
				+-------+
	SCL		   -+---+
					|
			   .+...+---+
	time (us)	| 2 | 2 |
*/
{
	if ( i2c_get ( i2cbus ) & I2C_DATA )
	{
		i2c_set ( i2cbus, I2C_CLOCK ) ;
		delay_us ( 2 ) ;
		i2c_set ( i2cbus, 0 ) ;
		delay_us ( 2 ) ;
		return ( OK ) ;
	}
	else
	{
		return ( I2CnotFree ) ;
	}
}


/*---------------------------------------- i2c_release -------------*/
void i2c_release ( I2C_BUS *i2cbus )
/*
	release i2c bus

	SDA		  ?-+---+------+
					|
			   -+---+......+
	SCL		  ?-+---+------+
					|	
			   -+---+......+
	time (us)	| 2 |  5   |
*/
{
	delay_us ( 2 ) ;
	i2c_set ( i2cbus, I2C_DATA | I2C_CLOCK ) ;
	delay_us ( 5 ) ;
}


/*---------------------------------------- i2c_stop ---------------*/
void i2c_stop ( I2C_BUS *i2cbus )
/*
	output stop condition on i2c bus

	SDA		   -+		+------+
				|		|
			   -+-------+......+
	SCL				+----------+
					|		
			   -+---+..........+
	time (us)	| 2 | 2 |  5   |
*/
{
	i2c_set ( i2cbus, 0 ) ;
	delay_us ( 2 ) ;
	i2c_set ( i2cbus, I2C_CLOCK ) ;

	i2c_release ( i2cbus ) ;
}


/*... byte procedures ...*/


/*---------------------------------------- i2c_send ----------------*/
int i2c_send ( I2C_BUS *i2cbus, int value )
{
	int bit, dout ;
	
	for ( bit = 0x80 ; bit > 0; bit >>= 1 )
	{
		dout = value & bit ? 1 : 0 ;
		if ( i2c_clock ( i2cbus, dout ) != dout )
			return ( I2CsdaFix ) ;
	}
	/*	accept ACK */
	return ( i2c_clock ( i2cbus, 1 ) == 0 ? OK : I2CnoACK ) ;
}


/*---------------------------------------- i2c_receive -------------*/
void i2c_receive ( I2C_BUS *i2cbus, byte *value, bool ack )
{
	byte bit ;

	*value = 0 ;
	for ( bit = 0x80 ; bit > 0; bit >>= 1 )
		*value = ( *value << 1 ) | i2c_clock ( i2cbus, 1 ) ;
	/*	generate ACK */
	i2c_clock ( i2cbus, ack ? 0 : 1 ) ;
}


/*... buffer procedures ...*/

# define IRQdisable	1
# if IRQdisable

/*---------------------------------------------- enable ----------*/
void enable (void)
{
	Supexec (ena_irq);
} /*- enable -*/


/*--------------------------------------------- disable ----------*/
void disable (void)
{
	Supexec (disa_irq);
} /*- disable -*/

# endif IRQdisable

/* ============================================================== */


/*---------------------------------------- i2c_swrite ---------------*/
int i2c_swrite ( I2C_BUS *i2cbus, int slave,
				int count, bool stop, byte *data )
{
	int n, result ;
	byte *dp ;

# if TEST && ! IRQdisable
	if ( verbose > 3 )
		printf ( "+ i2c_write, slave = %02x, count = %d, data = ",
												slave, count ) ;
# endif

# if IRQdisable
	disable () ;
# endif

	if ( ( result = i2c_start ( i2cbus ) ) == OK )
	{
		result = i2c_send ( i2cbus, slave | I2C_WRITE ) ;

		dp = data ;
		for ( n = 0 ; n < count && result == OK ; n++ )
		{
# if TEST && ! IRQdisable
	if ( verbose > 3 )
			printf ( "%02x ", *dp ) ;
# endif
			result = i2c_send ( i2cbus, *dp++ ) ;
		}

	}

	if ( result == OK && stop )
		i2c_stop ( i2cbus ) ;
	else
		i2c_release ( i2cbus ) ;

# if IRQdisable
	enable () ;
# endif

# if TEST && ! IRQdisable
	if ( verbose > 3 )
		printf ( "\n- i2c_swrite(%d)\n", result ) ;
# endif
	return ( result ) ;
}



/*---------------------------------------- e2prom_write ------------*/
int e2prom_write ( I2C_BUS *i2cbus, int count, byte *data )
{
	int n, m, result = OK ;
	byte *dp, wa ;

# if TEST
	if ( verbose > 3 )
		printf ( "+ e2prom_write, count = %d, data = ", count ) ;
# endif

	dp = data ;				/* pointer to data byte */
	wa = *dp++ ;			/* word address */

	for ( n = 1 ; n < count && result == OK ; n += 2, wa += 2 )
	{
# if IRQdisable
		disable () ;
# endif
		if ( ( result = i2c_start ( i2cbus ) ) == OK )
		{
			result = i2c_send ( i2cbus, E2PROM | I2C_WRITE ) ;
# if TEST && ! IRQdisable
	if ( verbose > 3 )
			printf ( "(@%02x) ", wa ) ;
# endif
			if ( result == OK )
				result = i2c_send ( i2cbus, wa ) ;
			for ( m = 0 ; m < 2 && result == OK ; m++ )
			{
				if ( n + m == count )
					break ;
# if TEST
	if ( verbose > 3 )
			printf ( "%02x ", *dp ) ;
# endif
				if ( result == OK )
					result = i2c_send ( i2cbus, *dp++ ) ;
			}
			if ( result == OK )
				i2c_stop ( i2cbus ) ;
			else
				i2c_release ( i2cbus ) ;
		} /* i2c_start */
		
# if IRQdisable
		enable () ;
# endif
		delay ( 100 ) /* msec */ ;
	} /* for n */


# if TEST
	if ( verbose > 3 )
		printf ( "\n- e2prom_write(%d)\n", result ) ;
# endif
	return ( result ) ;
}



/*---------------------------------------- i2c_read ----------------*/
int i2c_read ( I2C_BUS *i2cbus, int slave, int count, byte *data )
{
	int n, result ;
	byte *dp ;

# if TEST
	if ( verbose > 3 )
		printf ( "+ i2c_read, slave = %02x, count = %d, data = ",
												slave, count ) ;
# endif

	if ( ( result = i2c_start ( i2cbus ) ) == OK )
	{
		if ( ( result = i2c_send ( i2cbus, slave | I2C_READ ) ) == OK )
		{
			dp = data ;
			for ( n = 1 ; n <= count ; n++ )
			{
				i2c_receive ( i2cbus, dp, n < count ) ;
# if TEST
				if ( verbose > 3 )
					printf ( "%02x ", *dp ) ;
# endif
				dp++ ;
			}
		}
	}

	if ( result == OK )
		i2c_stop ( i2cbus ) ;
	else
		i2c_release ( i2cbus ) ;

# if TEST
	if ( verbose > 3 )
		printf ( "\n- i2c_read(%d)\n", result ) ;
# endif
	return ( result ) ;
}



# if MAIN
# define VMEa24d16			0xfe000000L
# define TC800periBase		VMEa24d16+0x200000L
# define DEFi2cAddress		(byte *)(TC800periBase+0x1003L)

/*---------------------------------------- main --------------------*/
int main ( void )
# define MAXDATA 256
{
	int		count, loop, endaddr;
	byte 	address, data[MAXDATA] ;
	char	string[MAXDATA] ;
	
	printf ( "* Read/Write i2c Bus / 8.4.92 / MATRIX / WA\n" ) ;

	for(;;)
	{
		printf ( "\n" ) ;
		printf ( "* Read, read Addressed, Write, write String, Erase, CLS, Quit\n-  ( numbers : n..n | 0xh..h )\n" ) ;
		printf ( "? >" ) ;
		
		switch ( tolower ( getch() ) )
		{
 case 'c' : printf ( "\033E" ) ;	/* clear screen */
			break ;
			
 case 'w' : printf ( "\n? data address >" ) ;
			data[0] = (int)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;
 			for ( count = 1 ; count < MAXDATA; count++ )
 			{
 				printf ( "? data ( RETURN == stop ) >", count ) ;
 				fgets ( string, MAXDATA, stdin ) ;
 				if ( *string > ' ' )
				{
					data[count] = (int)strtol ( string, NULL, 0 ) ;
					printf ( "%2d : %02x\n", count, data[count] ) ;
				}
				else
					break ;
 			}

 			e2prom_write ( DEFi2cAddress, count, data ) ;
 			break ; 

 case 's' : printf ( "\n? data address >" ) ;
			data[0] = (int)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;
			printf ( "\n? string >" ) ;
			fgets ( string, MAXDATA-1, stdin ) ;
			count = (int) strlen ( string ) ;
 			for ( loop = 0 ; loop < count ; loop++ )
 				data[loop+1] = (byte) string[loop] ;
 			/* Terminate string with an ASCII 0 */
 			data[loop] = '\0' ;
 			count++ ; 
 			e2prom_write ( DEFi2cAddress, count, data ) ;
 			break ; 

 case 'e' : printf ( "\n? first data address >" ) ;
			data[0] = (int)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;
			printf ( "\n? last data address >" ) ;
			endaddr = (int)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;
			count = endaddr - (int) data[0] + 1 ;
 			for ( loop = 1 ; loop <= count ; loop++ )
 				data[loop] = '\xff' ;
 			e2prom_write ( DEFi2cAddress, count, data ) ;
 			break ; 

 case 'a' : printf ( "\n? data address >" ) ;
			address = (byte)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;
 			printf ( "\n? count >" ) ;
			count = (int)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;

 			e2prom_aread ( DEFi2cAddress, count, &address, data ) ;
 			break ; 

 case 'r' : printf ( "\n? count >" ) ;
			count = (int)strtol ( fgets ( string, MAXDATA, stdin ), NULL, 0 ) ;

 			e2prom_read ( DEFi2cAddress, count, data ) ;
 			break ; 
 			
 case 'q' :	return 0 ;
		}
	}
}
# endif
