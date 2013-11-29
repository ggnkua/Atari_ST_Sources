#include <stdlib.h>
#include <math.h>					/* Mathefunktionen */
#include <stdio.h>					/* Standard I/O    */
#include <tos.h>

/* Modulglobale Variablen, die das Leben vereinfachen */
static double PI2	= 6.283185307;	/* PI*2 */ 

static int sin_d4[2049];

/***********************************************************
* init_dfht(): Initialisierung durchfuehren
***********************************************************/
void main(void)
{
int i;
int *sip;	

																			/* Sinustabelle initial. */
for(i = 0, sip = sin_d4; i <= 2048; i++) 
	*(sip++) = (int)(sin((i * PI2) / (double)8192.0) * 30000.0);
	
i = Fcreate("SND_TOOL.TAB", 0);
Fwrite(i, 4098L, sin_d4);
Fclose(i);
}
