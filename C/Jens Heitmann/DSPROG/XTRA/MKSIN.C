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
long file;

																			/* Sinustabelle initial. */
for(i = 0, sip = sin_d4; i < 2048; i++) 
	*(sip++) = (int)(sin((i * PI2) / (double)8192.0) * 32768.0);
*(sip++) = 32767;

file = Fcreate("DSPROG.TAB", 0);
Fwrite((int)file, 4098L, sin_d4);
Fclose((int)file);
}
