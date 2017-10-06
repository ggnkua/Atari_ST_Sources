/*
 * Aes resource library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int rsrc_free(void)
{
   aes_control[0] = 111;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int rsrc_gaddr(int Type, int Index, void *Address)
{
	aes_intin[0] = Type;
	aes_intin[1] = Index;
   aes_control[0] = 112;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 1;
   aes(&aes_params);
	*((void **) Address) = (void *)aes_addrout[0];
	return aes_intout[0];
}


int rsrc_load(char *Name)
{
	aes_addrin[0] = (long)Name;
   aes_control[0] = 110;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int rsrc_obfix(void *Tree, int Index)
{
	aes_intin[0] = Index;
	aes_addrin[0] = (long)Tree;
   aes_control[0] = 114;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int rsrc_rcfix(void *rc_header)
{
	aes_addrin[0] = (long)rc_header;
   aes_control[0] = 115;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int rsrc_saddr(int Type, int Index, void *Address)
{
	aes_intin[0] = Type;
	aes_intin[1] = Index;
	aes_addrin[0] = (long)Address;
   aes_control[0] = 113;
   aes_control[1] = 2;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}
