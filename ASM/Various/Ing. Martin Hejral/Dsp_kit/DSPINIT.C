/******************************************************
*  routines to install & run DSP programm on Falcon   *
******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#include "dspbind.h"
#include "sndbind.h"



/***** spusteni DSP programu *****/
static long dsp_exec(char *lodfile, long x, long y, long nblocks)
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

if( (len=Dsp_LodToBinary(lodfile, buf)) < 0 ) {
	fprintf(stderr, "Spatny soubor %s\n", lodfile);
	return -1;
}
Dsp_ExecProg(buf, len, ability);

return ability;
} /* dsp_exec() */



/***** nastaveni systemu pro zpracovani zvuku *****/
long dsp_init(char *lodfile)
{
int freq=CLK25K;
long err=0;

if(Locksnd() != 1) {
	fprintf(stderr, "Zvukovy system je jiz pouzivan\n");
	Unlocksnd();  return -1;
}

if(Dsp_GetWordSize() != 3) {
	fprintf(stderr, "Spatny typ DSP\n");
	return -1;
}

if(Dsp_Lock() != 0) {
	fprintf(stderr, "DSP je jiz pouzivan\n");
	Dsp_Unlock();  Unlocksnd();  return -1;
}

/* pokud je stav systemu chybny, resetuj audiosystem */
if( Sndstatus(0) != 0 ) {
	Sndstatus(1);
	Soundcmd(LTATTEN, 0xF0);
	Soundcmd(RTATTEN, 0xF0);
}

if(dsp_exec(lodfile, 1000, 5000, 50) == -1) {
	Dsp_Unlock();
	Unlocksnd();
	return -1;
}

Setmode(STEREO16);
Settrack(0, 0);	/* 1 prehravaci a 1 nahravaci stereo stopa */
Setmontrack(0);	/* na vystupu stopa 0 */
Devconnect(DMAPLAY,   0, INTERNAL_25M, freq, NO_HANDSHAKE);
Devconnect(EXTINP,    0, INTERNAL_25M, freq, NO_HANDSHAKE);
Devconnect(ADC,  DSPREC, INTERNAL_25M, freq, NO_HANDSHAKE);
Devconnect(DSPXMIT, DAC, INTERNAL_25M, freq, NO_HANDSHAKE);
Dsptristate(1, 1);  	/* pripojeni DSP na matici */
Soundcmd(ADDERIN, 2);	/* vystupni scitacka napajena pouze z matice */
Soundcmd(ADCINPUT, 0);	/* vstup z mikrofonniho konektoru */

if( (err=Sndstatus(0)) != 0 )
	printf("Chyba #$%lX v audiosystemu!\n", err);

return 0;
} /* end of dsp_init() */



/***** DSP posila vypoctena data do pameti (napr. obraz) *****/
long dsp_mem_init(char *lodfile)
{
int freq=CLK50K;
long err=0;

if(Locksnd() != 1) {
	fprintf(stderr, "Zvukovy system je jiz pouzivan\n");
	Unlocksnd();  return -1;
}

if(Dsp_GetWordSize() != 3) {
	fprintf(stderr, "Spatny typ DSP\n");
	return -1;
}

if(Dsp_Lock() != 0) {
	fprintf(stderr, "DSP je jiz pouzivan\n");
	Dsp_Unlock();  Unlocksnd();  return -1;
}

/* pokud je stav systemu chybny, resetuj audiosystem */
if( Sndstatus(0) != 0 ) {
	Sndstatus(1);
	Soundcmd(LTATTEN, 0xF0);
	Soundcmd(RTATTEN, 0xF0);
}

if(dsp_exec(lodfile, 1000, 5000, 50) == -1) {
	Dsp_Unlock();
	Unlocksnd();
	return -1;
}

Soundcmd(ADCINPUT, 3);	/* vstup ADC z chipu YAMAHA */
Soundcmd(ADDERIN, 1);	/* vystupni scitacka napajena primo z ADC */
Setmode(STEREO16);
Settrack(0, 0);	/* 1 prehravaci a 1 nahravaci stereo stopa */
Setmontrack(0);	/* na vystupu stopa 0 */
Devconnect(DMAPLAY, 0,      INTERNAL_32M, freq, NO_HANDSHAKE);
Devconnect(EXTINP,  0,      INTERNAL_32M, freq, NO_HANDSHAKE);
Devconnect(ADC,     DSPREC, INTERNAL_32M, freq, NO_HANDSHAKE);
Devconnect(DSPXMIT, DMAREC, INTERNAL_25M, freq, NO_HANDSHAKE);
Dsptristate(1, 1);  	/* pripojeni DSP na matici */

if( (err=Sndstatus(0)) != 0 )
	printf("Chyba #$%lX v audiosystemu!\n", err);

return 0;
} /* end of dsp_mem_init() */



/* active==TRUE -> DSP zustane zapojen v sign lov‚ ceste a aktivn¡ */
void dsp_free(int active)
{
if(!active) {
	Soundcmd(ADDERIN, 1);	/* vystupni scitacka napajena primo z ADC */
	Soundcmd(ADCINPUT, 3);	/* vstup z chipu YAMAHA */
	Dsptristate(0, 0);  	/* odpojeni DSP od zvukove matice */
	/* pro STE/TT software */
	Devconnect(EXTINP,    0, INTERNAL_25M, CLK_STE, NO_HANDSHAKE);
	Devconnect(ADC,       0, INTERNAL_25M, CLK_STE, NO_HANDSHAKE);
	Devconnect(DSPXMIT,   0, INTERNAL_25M, CLK_STE, NO_HANDSHAKE);
	Devconnect(DMAPLAY, DAC, INTERNAL_25M, CLK_STE, NO_HANDSHAKE);
	Setmode(MONO8);
	Setmontrack(0);
}
Dsp_Unlock();
Unlocksnd();
}
