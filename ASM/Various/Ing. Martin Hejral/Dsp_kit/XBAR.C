/*
* Falcon audio programming
*/

#include <aes.h>
#include <tos.h>
#include "sndbind.h"
#include "dspbind.h"

#include "xbar.h"

#define HIDE_MOUSE graf_mouse(256,&dummy)
#define SHOW_MOUSE graf_mouse(257,&dummy)

char buffer[1000];	/* This buffer needs to be the size of DSP program */

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];



long main(void)
{
int handle, dummy;
int mx,my,mb,ks;
int cod,dsp,dma,ext;
int curadder,curadc;
int retval;
int charw, charh, boxw, boxh;
int xdial,ydial,wdial,hdial;
int x,y,w,h;
int freq=CLK50K;
long xav,yav;
char *rambuf;

OBJECT *tree;

/* Set the system up to do GEM calls*/

appl_init();

/* Get the handle of the desktop */

/*handle=graf_handle(&charw,&charh,&boxw,&boxh);*/

graf_mouse(ARROW,(MFORM *)&dummy);

rsrc_load("xbar.rsc");

rsrc_gaddr(0,ROOT,&tree);
 
form_center( tree, &xdial, &ydial, &wdial, &hdial );

x = y = w = h = 0;
form_dial( 0, x, y, w, h, xdial, ydial, wdial, hdial );

Locksnd();

if(Dsp_Lock() != 0) {
/*	printf("DSP je jiz pouzivan\n");*/
	Unlocksnd();	return -1;
}

/**
Dsp_Available(&xav,&yav);
Dsp_Reserve(xav,yav);
if (Dsp_GetProgAbility() != 1234)
	Dsp_LoadProg("FLANG203.LOD",1234,buffer,);

soundcmd(LTATTEN,0);			/* Set Left Attenuation to zero */
soundcmd(RTATTEN,0);			/* Set Right Attenuation to zero */
soundcmd(LTGAIN,0x80);		/* Set Left Gain to 8 */
soundcmd(RTGAIN,0x80);		/* Set Right Gain to 8 */
**/

curadder=Soundcmd(ADDERIN,INQUIRE);
Soundcmd(ADDERIN,2);			/* Adder input from Matrix only */

curadc=Soundcmd(ADCINPUT,INQUIRE);			/* ADC inputs from microphone */
Soundcmd(ADCINPUT,0);			/* ADC inputs from microphone */

Dsptristate(ENABLE,ENABLE);	/* Allow DSP to talk to matrix */

rambuf=(char *)Malloc(1000000L);

Setmode(STEREO16);

Setbuffer(0,&rambuf[0],&rambuf[100000L]);
Setbuffer(1,&rambuf[0],&rambuf[100000L]);

Buffoper(PLAY_ENABLE|PLAY_REPEAT|RECORD_ENABLE|RECORD_REPEAT);

objc_draw ( tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial );

do {
	cod=0;
	dsp=0;
	dma=0;
	ext=0;

	if (tree[CODCOD].ob_state == SELECTED) cod |= DAC;

	if (tree[CODDSP].ob_state == SELECTED) dsp |= DAC;

	if (tree[CODDMA].ob_state == SELECTED) dma |= DAC;

	if (tree[CODEXT].ob_state == SELECTED) ext |= DAC;

	if (tree[DSPCOD].ob_state == SELECTED) cod |= DSPREC;

	if (tree[DSPDSP].ob_state == SELECTED) dsp |= DSPREC;

	if (tree[DSPDMA].ob_state == SELECTED) dma |= DSPREC;

	if (tree[DSPEXT].ob_state == SELECTED) ext |= DSPREC;

	if (tree[DMACOD].ob_state == SELECTED) cod |= DMAREC;

	if (tree[DMADSP].ob_state == SELECTED) dsp |= DMAREC;

	if (tree[DMADMA].ob_state == SELECTED) dma |= DMAREC;

	if (tree[DMAEXT].ob_state == SELECTED) ext |= DMAREC;

	if (tree[EXTCOD].ob_state == SELECTED) cod |= EXTOUT;

	if (tree[EXTDSP].ob_state == SELECTED) dsp |= EXTOUT;

	if (tree[EXTDMA].ob_state == SELECTED) dma |= EXTOUT;

	if (tree[EXTEXT].ob_state == SELECTED) ext |= EXTOUT;

	Devconnect(ADC,cod,INTERNAL_25M,freq,NO_HANDSHAKE);
	Devconnect(EXTINP,ext,INTERNAL_25M,freq,NO_HANDSHAKE);
	Devconnect(DSPXMIT,dsp,INTERNAL_25M,freq,NO_HANDSHAKE);
	Devconnect(DMAPLAY,dma,INTERNAL_25M,freq,NO_HANDSHAKE);

	if (tree[ADDER].ob_state == SELECTED) 
		Soundcmd(ADDERIN,3);
	else
		Soundcmd(ADDERIN,2);

	evnt_button(1,1,0,&mx,&my,&mb,&ks);

	retval=form_do( tree, 0 ); 

} while (retval!=DONE);

Buffoper(0);
/**
Dsptristate(TRISTATE,TRISTATE);	/* Disconnect DSP from matrix */

Soundcmd(ADDERIN,curadder);
Soundcmd(ADCINPUT,curadc);
**/
Dsp_Unlock();
Unlocksnd();

form_dial( 0, x, y, w, h, xdial, ydial, wdial, hdial );

appl_exit();

return 0;

} /* main() */
