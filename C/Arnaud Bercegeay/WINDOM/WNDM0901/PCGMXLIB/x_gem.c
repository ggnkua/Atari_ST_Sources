/*
 * On complete les appels classique AES
 */

#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

/* On complete les appels classique AES */

int appl_getinfo(int type, int *out1, int *out2, int *out3, int *out4) {
	aespb.intin[0] = type;
	aespb.contrl[0] = 130;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 5;
	aespb.contrl[3] = 0;
	aespb.contrl[4] = 0;
	aes( &aespb);
	*out1 = aespb.intout[1];
	*out2 = aespb.intout[2];
	*out3 = aespb.intout[3];
	*out4 = aespb.intout[4];
	return  aespb.intout[0];
}

int appl_control(int ap_cid, int ap_cwhat, void *ap_cout) {
  	aespb.intin[0] 	= ap_cid;
   	aespb.intin[1] 	= ap_cwhat;
  	aespb.addrin[0] = (long)ap_cout;
	aespb.contrl[0] = 129;
	aespb.contrl[1] = 2;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
  	return aespb.intout[0];
}	

int objc_sysvar(int mode, int which, int in1, int in2, int *out1, int *out2) {
	aespb.intin[0] = mode;
	aespb.intin[1] = which;
	aespb.intin[2] = in1;
	aespb.intin[3] = in2;
    aespb.contrl[0] = 48;
    aespb.contrl[1] = 4;
    aespb.contrl[2] = 3;
    aespb.contrl[3] = 0;
    aespb.contrl[4] = 0;
    aes( &aespb);
    *out1 = aespb.intout[1];
    *out2 = aespb.intout[2];
    return  aespb.intout[0];
}


/******************** Appels VDI **************************/

/* La librairie est directement tir‚ de
 * GEMX.LIB de GemLib pl 38. On utilise
 * leur d‚finition des tableaux du GEM.
 */


static void vdi_str_to_c( int *src, char *des, int len) {
	while (len > 0) {
		*des++ = (char) *src++;
		len--;
	}
	*des++ = 0;
}

/*
 *	Fonction inspir‚e de la doc d‚veloppeur NVDI 4  qui
 *	intŠgre les sp‚cifit‚s de Speedo (caractŠre 33) et 
 *  celles de NVDI (caractŠre 34).
 */

int vqt_extname( int handle, int index, char *name, 
				 int *speedo, int *format, int *flags ) {
	int i;
	
	vdipb.intin[0] = index; 
	vdipb.intin[1] = 0;
 
	vdipb.contrl[0] = 130; 
	vdipb.contrl[1] = 0; 
	vdipb.contrl[3] = 2; 
	vdipb.contrl[5] = 1; 
	vdipb.contrl[6] = handle; 
 
 	vdi( &vdipb);

	/* On recopie les 31 octets de nom de la fonte */
	for( i = 0; i < 32; i ++)
		name[i] = vdipb.intout[i+1];
	name[32] = '\0';
    *flags = 0;
    *format = 0; 
    *speedo = 0;

	if(  vdipb.contrl[4] >= 33) {
		*speedo = vdipb.intout[33];
		if( vdipb.contrl[4] >= 34) {
	  		*flags = (vdipb.intout[34] >> 8) & 0xff; 
			*format = vdipb.intout[34] & 0xff; 
		}
	}
  	return( vdipb.intout[0]);
}
