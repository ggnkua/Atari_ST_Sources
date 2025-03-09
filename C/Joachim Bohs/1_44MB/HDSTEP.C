/* newstep: Einstellen der Steprate (fÅr beide Laufwerke)
** Written 1988 by Claus Brod
** Original in GFABASIC, siehe SCHEIBENKLEISTER
*/

#define  seekrate 	 		0x440L
#define 	_hdv_init 			0x46AL

#include <stdio.h>
#include <tos.h>
#include <stdlib.h>

void step(int);
void main(int,char **);
void dpoke(unsigned long, int);

/* dpoke: Schreibt inhalt.w in adresse */
void dpoke( adresse, inhalt )
unsigned long adresse;
int inhalt;
{
	*(int *)adresse = inhalt;
}


/* step: Steprate einstellen */
void step(steprate)
int steprate;
{
	long hdv_init, old_stack;

	old_stack = Super(0L);
	dpoke(seekrate, steprate);
	hdv_init = *(unsigned long *)_hdv_init;
	(void) Super( (void *)old_stack );

	Supexec(hdv_init);
}

void main(argc, argv)
int argc;
char *argv[];
{
	char newstep = '0';
	
	puts("Stepraten einstellen - (C)1989 Claus Brod");
			
	if (argc > 1)
	{
		newstep = *argv[1];
		
		if ((argc != 2) || (newstep < '0') || (newstep > '3'))
		{
			puts("USAGE: newstep [0|1|2|3]");
			puts("       0=6ms, 1=12ms, 2=2ms, 3=3ms");
			Cnecin();
			exit(1);
		}
	}
	step((int)(newstep - '0'));
	exit(0);
}
