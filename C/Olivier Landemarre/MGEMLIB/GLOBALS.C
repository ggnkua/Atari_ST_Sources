
/* #include <stdio.h> */
#include "mgemx.h"

	/* global identify string for the lib: */
char __Ident_gem[] = "$PatchLevel: GEM library: " GEMLIB_PATCHLEVEL " $";

	/* global aes binding params: */
INT16 aes_global[AES_GLOBMAX];

	/* global aes variables, initialized by appl_init: */
int gl_apid;
int gl_ap_version;

	/* global vdi binding params: */
INT16 vdi_intin[VDI_INTINMAX], vdi_intout[VDI_INTOUTMAX], vdi_ptsin[VDI_PTSINMAX], vdi_ptsout[VDI_PTSOUTMAX], vdi_control[VDI_CNTRLMAX];

VDIPB vdi_params =
{
	&vdi_control[0],
	&vdi_intin[0],
	&vdi_ptsin[0],
	&vdi_intout[0],
	&vdi_ptsout[0] 
};
