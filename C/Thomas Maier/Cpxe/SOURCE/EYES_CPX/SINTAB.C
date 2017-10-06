
#include <tm_start.h>
#include <tmstdlib.h>
#include <math.h>

#include "eyes.h"

#define topi(_a)  (M_PI / 180.0 * (double)(_a))

void main(void)
{
	WORD i;
	
	Printf("\r\n/* Sinus/Cosinus und Tangens Tabelle */\r\n\r\n"
		   "#include <compiler.h>\r\n"
		   "#include \"eyes.h\"\r\n\r\n");
	
	Printf("WORD sintab[SINTABMAX+1] = {\r\n");
	
	for ( i = 0; i <= SINTABMAX; i++ )
	{
		Printf("%hd",(WORD)( sin(topi(i)) * MATHOFFSET ) );
		if ( i < SINTABMAX ) Printf(",\r\n");
	}
	Printf("\r\n};\r\n\r\n");
	
	
	Printf("WORD tantab[TANTABMAX+1] = {\r\n");
	
	for ( i = 0; i <= TANTABMAX; i++ )
	{
		Printf("%hd",(WORD)( tan(topi(i)) * MATHOFFSET ) );
		if ( i < TANTABMAX ) Printf(",\r\n");
	}
	Printf("\r\n};\r\n");
	
	exit(0);
}