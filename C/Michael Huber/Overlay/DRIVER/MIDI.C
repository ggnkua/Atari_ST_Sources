/*

	Midi-Note-On-Treiber fr Overlay
	Michael Huber
	(c) 1994
	
*/	

#include <tos.h>
#include <stdio.h>
#include <ext.h>
#define MIDIVEL 

int main()
{

	/*** Midi-Note-On-Driver ***/
	
	
	int id = 0x8000;
	long status, note, vel, first;
		
	
	status = 144;	/* default running status */
	
	if( Bconstat(3) )
	{
		first = Bconin(3);
		if( (first & 0xf0) == 144)	/* hole Note ab */
		{
			status = first;
			if( Bconstat(3) )
				note = Bconin(3);
			else
				return id;	
		} else if( status &0x80 )  	/* anderer Status */		
			return id;	
		else
			note = first;			
		
		if( Bconstat(3) )			/* Velocity holen */
		{
			vel = Bconin(3);
			if( vel != 0 )			
			{
				id = 0x4000;
				#ifdef MIDIVEL
				id |= ((unsigned char)vel >> 5) + 'a'; /* 32er Vel-Schritte */
				#else
				id |= (unsigned char)note;			
				#endif
			}
		}
	}	
	return id;
	
}			