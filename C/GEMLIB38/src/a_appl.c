/*
 * Aes application library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch.tu-harburg.de
 */
#include <string.h>
#include "gem.h"


int appl_bvset(int bvdisk, int bvhard)
{
	aes_intin[0] = bvdisk;
	aes_intin[1] = bvhard;
	aes_control[0] = 16;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_control(int ap_cid, int ap_cwhat, void *ap_cout)
{
	aes_intin[0] = ap_cid;
	aes_intin[1] = ap_cwhat;
	aes_addrin[0] = (long)ap_cout;
	aes_control[0] = 129;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_exit(void)
{
	aes_control[0] = 19;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_find(char *Name)
{
	aes_addrin[0] = (long)Name;
	aes_control[0] = 13;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_getinfo(int type, int *out1, int *out2, int *out3, int *out4)
{
	aes_intin[0] = type;
	aes_control[0] = 130;
	aes_control[1] = 1;
	aes_control[2] = 5;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	*out1 = aes_intout[1];
	*out2 = aes_intout[2];
	*out3 = aes_intout[3];
	*out4 = aes_intout[4];
	return aes_intout[0];
}


int appl_init(void)
{
	/* clear all binding arrays */
	/* other binding arrays are synonyms for the stuff */
	/* listed below - c.f. "common.h"				 */
	bzero(&aes_control[0], AES_CTRLMAX * sizeof(short));
	bzero(&aes_intin[0],	AES_INTINMAX * sizeof(short));
	bzero(&aes_intout[0],	AES_INTOUTMAX * sizeof(short));
	bzero(&aes_addrin[0],	AES_ADDRINMAX * sizeof(short));
	bzero(&aes_addrout[0], AES_ADDROUTMAX * sizeof(short));
	bzero(&aes_global[0],	AES_GLOBMAX * sizeof(short));

	aes_control[0] = 10;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	gl_ap_version = aes_global[0];
	gl_apid = aes_intout[0];
	return aes_intout[0];
}


int appl_read(int ApId, int Length, void *ApPbuff)
{
	aes_intin[0] =  ApId;
	aes_intin[1] = Length;
	aes_addrin[0] = (long)ApPbuff;
	aes_control[0] = 11;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_search(int mode, char *fname, int *type, int *ap_id)
{
  	aes_intin[0] = mode;
  	aes_addrin[0] = (long)fname;
	aes_control[0] = 18;
	aes_control[1] = 1;
	aes_control[2] = 3;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
  	*type = aes_intout[1];
  	*ap_id = aes_intout[2];
  	return aes_intout[0];
}


int appl_tplay(void *Mem, int Num, int Scale)
{
	aes_intin[0] =	Num;
	aes_intin[1] =	Scale;
	aes_addrin[0] = (long)Mem;
	aes_control[0] = 14;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_trecord(void *Mem, int Count)
{
	aes_intin[0] = Count;
	aes_addrin[0] = (long)Mem;
	aes_control[0] = 15;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_write(int ApId, int Length, void *ApPbuff)
{
	aes_intin[0] = ApId;
	aes_intin[1] = Length;
	aes_addrin[0] = (long)ApPbuff;
	aes_control[0] = 12;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int appl_yield(void)
{
	aes_control[0] = 17;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0]; 
}
