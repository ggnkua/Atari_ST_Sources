#include "gemx.h"

/*
 * global identify string for the lib
*/
char __Ident_gem[] = "$PatchLevel: GEM library: " GEMLIB_PATCHLEVEL " $";


/*
 * global aes binding params 
*/    
short	aes_global[AES_GLOBMAX],
		aes_control[AES_CTRLMAX],
		aes_intin[AES_INTINMAX],
		aes_intout[AES_INTOUTMAX];
long	aes_addrin[AES_ADDRINMAX],
		aes_addrout[AES_ADDROUTMAX];

AESPB aes_params = {&aes_control[0],
			           &aes_global[0],
                    &aes_intin[0],
                    &aes_intout[0],
                    &aes_addrin[0],
                    &aes_addrout[0] };

/*
 * global aes variables, initialized by appl_init
*/
int gl_apid;
int gl_ap_version;



/*
 * global vdi binding params 
*/
short	vdi_intin[VDI_INTINMAX], 
		vdi_intout[VDI_INTOUTMAX],
		vdi_ptsin[VDI_PTSINMAX], 
		vdi_ptsout[VDI_PTSOUTMAX],
		vdi_control[VDI_CNTRLMAX];

VDIPB	vdi_params = {&vdi_control[0],
                    &vdi_intin[0],
                    &vdi_ptsin[0],
                    &vdi_intout[0],
                    &vdi_ptsout[0] };
