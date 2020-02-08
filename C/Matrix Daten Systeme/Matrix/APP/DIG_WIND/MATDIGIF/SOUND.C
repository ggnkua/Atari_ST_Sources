# include <stdio.h>
# include <tos.h>
# include <global.h>

# include "\dsp.1\xbar\sndbind.h"

# define _gain(g)	((g)<<4)

# define DEFatt		0
# define DEFgain	_gain(15)

/*----------------------------------------------- SetVolume ----*/
bool SetVolume ( int gain, int att )
{
	if ( locksnd() )
	{
# if 0
		printf ( "\033H g=%3d a=%3d   ", gain, att ) ;
# endif
		if ( gain < 0 )	gain = DEFgain ;
		if ( att < 0 )	att = DEFatt ;

		soundcmd(LTATTEN,att);
		soundcmd(RTATTEN,att);
		soundcmd(LTGAIN,gain);
		soundcmd(RTGAIN,gain);

		unlocksnd();
		
		return TRUE ;
	}
	else
	{
		printf ( "\033H* can't lock sound ! \n" ) ;
		return FALSE ;
	}
}


/*----------------------------------------------- SoundInToOut ----*/
bool SoundInToOut ( bool on )
{
	if ( locksnd() )
	{
		soundcmd ( ADCINPUT, 0 ) ;			/* ADC inputs from microphone */

		setmode(STEREO16);

		buffoper(0) ;

		if ( on )
			soundcmd(ADDERIN,1);
		else
			soundcmd(ADDERIN,0);

		buffoper(0);

		unlocksnd();
		return TRUE ;
	}
	else
	{
		printf ( "\033H* can't lock sound ! \n" ) ;
		return FALSE ;
	}
}

