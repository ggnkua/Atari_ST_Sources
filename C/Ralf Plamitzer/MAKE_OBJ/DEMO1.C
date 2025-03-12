/********************************\
|  Von   Ralf Plamitzer          |
|        Dresdenerstr. 7         |
|        6120 Michelstadt        |
|                                |
|        TURBO C 2.0             |
|                                |
\********************************/

#include <tos.h>

extern long BILD;

int main(void)
{
	int i;
	long *screen = Logbase(),*pic = &BILD;
	
	for(i = 0;i < 8000;i++)
		*screen++ = *pic++;
	Cnecin();
	return(0);
}