#include <global.h>
#include <stdio.h>
#include <string.h>
#include <ext.h>

#include "tools.h"

#include "initdmsd.h"
#include "digitise.h"

#define MDF_BASE   	0xF00000L
#define I2Caddr		((byte *)(MDF_BASE + 0x78001L))

byte	*i2c_bus = I2Caddr ; /* global */

int video_signal = PUP_FBAS ;
int video_source = 1 ;
		

/*----------------------------------------- ChangeDmsdParameter ----*/
bool ChangeDmsdParameter ( unsigned chip )
{
	char 	 buffer[128] ;
	unsigned regnum ;
	I2CdataBuffer *i2cdb ;
	
	switch ( chip )
	{
case 7191 :	i2cdb = &DmsdData7191 ;
			break ;
case 9051 :	i2cdb = &DmsdData9051 ;
			break ;
default:	printf ( "* illegal chip : %u\n", chip ) ;
			return FALSE ;
	}
	
	printf ( "\033H\033K- DMSD%u : register [ 0..%u] nn/0xhh? >",
							chip, i2cdb->length-1 ) ;
	gets ( buffer ) ;
	regnum = (unsigned)strtol ( buffer, NULL, 0 ) ;
	if ( regnum < i2cdb->length )
	{
		sprintf ( buffer, "DMSD register[%u=$%02x]", regnum, regnum ) ;
		return ( GetUChar ( buffer, &i2cdb->data[regnum], 0 ) ) ;
	}
	else
	{
		printf( "* illegal regnum\n" ) ;
		return FALSE ;
	}
}

/*----------------------------------------- InitDmsd ---------------*/
int InitDmsd ( unsigned chip )
{
	int dummy, result ;
	
    if ( verbose )
    	printf ( "init DMSD %u\n", chip );

	if ( ( result = i2c_initrom ( PUP_FBAS, 1, chip ) ) != 0 )
		return result ;

	chk_set_chan_sig ( &video_source, &video_signal, &dummy ) ;

	if ( verbose )
	{
		if ( ( video_signal != PUP_AUTO ||
			   video_source != PUP_AUTO ) )
			printf ( "source : %u, signal : %u\n", video_source, video_signal ) ;
		else
			printf ( "* no signal found\n" ) ;

	    printf ( "DMSD status: $%02x\n", i2c_status() ) ;
	}

    return 0 ;
}



