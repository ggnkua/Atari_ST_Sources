/*

	Tastatur-Treiber fr Overlay
	Michael Huber
	(c) 1994 
			
*/	


#include <aes.h>
#include <stdio.h>

int main()
{


	int ev_mgpbuff[8];
	int key;
	int dummy;
	int event = 0;


	event = evnt_multi( MU_TIMER | MU_KEYBD,
							0, 0, 0,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							ev_mgpbuff, 10, 0, &dummy, &dummy,
							&dummy, &dummy,
							&key, &dummy);
	if( event & MU_KEYBD )
	{
		switch( key )						
		{
			case 18432: key = 'u'; break;	/* Cursortasten */
			case 18488: key = 'U'; break;
			case 20480: key = 'd'; break;
			case 20530: key = 'D'; break;
			case 19200: key = 'l'; break;
			case 19252: key = 'L'; break;
			case 19712: key = 'r'; break;
			case 19766: key = 'R'; break;
			case 18176: key = 'h'; break;	/* Home 		*/
			case 18231: key = 'H'; break;	/* Clr/Home		*/
		}	
		return ((unsigned char)key | 0x4000);	
	}	
	return 0x8000;
	
}
