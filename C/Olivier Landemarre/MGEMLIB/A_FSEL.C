/*
 * Aes file selector library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 * modified: er -- ers@free.fr
 *					little speed & size optimisation for mt_fsel_exinput (), mt_fsel_input ();
 */

#include "mgem.h"


int mt_fsel_exinput (char *path, char *file, INT16 *exit_but, char *title, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={91,0,2,3,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long *ptr_l;
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	ptr_l = aes_addrin;
	*(ptr_l ++) = (long)path;							/* [0] */
	*(ptr_l ++) = (long)file;							/* [1] */
	*(ptr_l) = (long)title;								/* [2] */

	aes (&aes_params);

	*exit_but = aes_intout[1];

	return (aes_intout[0]);
}

#ifdef fsel_exinput
#undef fsel_exinput
#endif
int fsel_exinput(char *path, char *file, INT16 *exit_but, char *title)
{
	return(mt_fsel_exinput(path, file, exit_but, title, aes_global));
}


int mt_fsel_input (char *path, char *file, INT16 *exit_but, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={90,0,2,2,0};
	INT16 aes_intin[AES_INTINMAX], aes_intout[AES_INTOUTMAX];
	long aes_addrin[AES_ADDRINMAX], aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;

	aes_params.control = &aes_control[0];				/* AES Control Array */
	aes_params.global = &global_aes[0];					/* AES Global Array */
	aes_params.intin = &aes_intin[0];					/* input integer array */
	aes_params.intout = &aes_intout[0];					/* output integer array */
	aes_params.addrin = &aes_addrin[0];					/* input address array */
	aes_params.addrout = &aes_addrout[0];				/* output address array */

	aes_addrin[0] = (long)path;
	aes_addrin[1] = (long)file;

	aes (&aes_params);

	*exit_but = aes_intout[1];

	return (aes_intout[0]);
}

#ifdef fsel_input
#undef fsel_input
#endif
int fsel_input(char *path, char *file, INT16 *exit_but)
{
	return(mt_fsel_input(path, file, exit_but,aes_global));
}
