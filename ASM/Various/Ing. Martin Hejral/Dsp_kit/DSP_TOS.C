/******************************************************
*     first DSP programm - use it as frame
******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#include "dspbind.h"
#include "sndbind.h"



long dsp_exec(char *lodfile, long x, long y, long nblocks)
{
int ability;
long len;
char *buf;

ability = Dsp_RequestUniqueAbility();

if(Dsp_Reserve(x, y) < 0) {
	Dsp_FlushSubroutines();
	if(Dsp_Reserve(x, y) < 0) {
		fprintf(stderr, "Neni dost DSP pameti\n");
		return -1;
	}
}

len = 3*( x+y+(3*nblocks) );
if( (buf=malloc(len)) == NULL )
	return -1;

len = Dsp_LodToBinary(lodfile, buf);
printf("- delka binarniho DSP programu = %li\n", len);
Dsp_ExecProg(buf, len, ability);

return ability;
} /* dsp_exec() */



long main(void)
{
int freq=CLK50K;
long err=0;

printf("######### Falcon DSP program #########\n");

if(Dsp_GetWordSize() != 3) {
	fprintf(stderr, "Spatny typ DSP\n");
	return -1;
}

if(Locksnd() != 1) {
	fprintf(stderr, "Zvukovy system je jiz pouzivan\n");
	return  -1;
}

if(Dsp_Lock() != 0) {
	fprintf(stderr, "DSP je jiz pouzivan\n");
	Unlocksnd();	return -1;
}

/* pokud je stav systemu chybny, resetuj audiosystem */
if( Sndstatus(0) != 0 ) {
	Sndstatus(1);
	Soundcmd(LTATTEN, 0xF0);
	Soundcmd(RTATTEN, 0xF0);
}

printf("Startuji DSP program ...\n");
if(dsp_exec("MIXER.LOD", 1000, 5000, 50) == -1) {
	Dsp_Unlock();
	Unlocksnd();
	return -1;
}

Soundcmd(ADDERIN, 2);	/* vystupni scitacka napajena pouze z matice */
Soundcmd(ADCINPUT, 0);	/* vstup z mikrofonniho konektoru */
Setmode(STEREO16);
Settrack(0, 0);
Setmontrack(0);
Devconnect(DMAPLAY,   0, INTERNAL_25M, freq, NO_HANDSHAKE);
Devconnect(EXTINP,    0, INTERNAL_25M, freq, NO_HANDSHAKE);
Devconnect(ADC,  DSPREC, INTERNAL_25M, freq, NO_HANDSHAKE);
Devconnect(DSPXMIT, DAC, INTERNAL_25M, freq, NO_HANDSHAKE);
Dsptristate(1, 1);  	/* pripojeni DSP na matici */

if( (err=Sndstatus(0)) != 0 )
	printf("Chyba #$%lX v audiosystemu!\n", err);

printf("Enter command:\n");
getchar();

/*
Dsptristate(0, 0);  	/* odpojeni DSP od zvukove matice */
Soundcmd(ADDERIN, 1);	/* vystupni scitacka napajena primo z ADC */
Soundcmd(ADCINPUT, 3);	/* vstup z chipu YAMAHA */
*/
Dsp_Unlock();
Unlocksnd();
return 0;
} /* end of main() */
