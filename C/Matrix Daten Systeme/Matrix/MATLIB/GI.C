# include <stdio.h>
# include <tos.h>
# include <ext.h>

# include "gi.h"

# if 0
# define PRTdata	15
# endif

/*------------------------------------------ gi_sequence --------*/
void gi_sequence ( int *tab )
{
	int reg, data, time ;

	for(;;)
	{
		reg  = *tab++ ;
		switch ( reg )
		{
  case -1 :	printf ( "\n" ) ;
  			return ;
  case -2 :	time = *tab++ ;
			delay ( time ) ;
			printf ( "delay %d  ", time ) ;
			break ;
  default :	data = *tab++ ;
			printf ( "%x:%02x ", reg, data ) ;
			GIwrite ( reg, data ) ;
			break ;
		}
	}
}

int tone[] =
{
	0, 0xff,
	1, 0x00,
	7, 0x3e,
	8, 0x0c,
	-1
} ;

int gi_wmask[16] =
{
	0xff, 0x3f,	 0xff, 0x3f,  0xff, 0x3f,
	0x1f,
	0x3f,
	0x1f, 0x1f, 0x1f,
	0xff, 0xff,
	0x0f,
	0x00, 0x00
} ;

/*-------------------------------------------------------- GIset -----------*/
void GIset ( int reg, int value )
{
	GIwrite ( reg, ( GIread(reg) & ~ gi_wmask[reg] ) | ( value & gi_wmask[reg] ) ) ;
}

/*-------------------------------------------------------- gi_tone ------*/
void gi_tone ( int channel, int freq, int volume )
{
	GIset ( channel*2,   freq & 0xff ) ;
	GIset ( channel*2+1, freq >> 8 ) ;
	GIset ( channel+8,   volume ) ;
	GIset ( 7,		   GIread(7) & ~ BIT(channel) ) ;
}


/*------------------------------------------ gi_on -------------*/
void gi_on ( int channel )
{
	GIset ( 7, GIread(7) & ~BIT(channel) ) ;
}


/*------------------------------------------ gi_off -------------*/
void gi_off ( int channel )
{
	GIset ( 7, GIread(7) | BIT(channel) ) ;
}

/*-------------------------------------- gi_all_off -------------*/
void gi_all_off ( int channel )
{
	GIset ( 7, GIread(7) | BIT(channel) ) ;
}


