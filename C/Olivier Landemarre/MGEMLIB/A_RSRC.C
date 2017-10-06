/*
 * Aes resource library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre@utbm.fr
 */
#include "mgem.h"


int mt_rsrc_free( INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={111,0,1,0,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef rsrc_free
#undef rsrc_free
#endif
int rsrc_free()
{
	return(mt_rsrc_free(aes_global));
}


int mt_rsrc_gaddr(int Type, int Index, void *Address, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={112,2,1,0,1};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Type;
	aes_intin[1] = Index;

	aes(&aes_params);

	*((void **) Address) = (void *)aes_addrout[0];
	return aes_intout[0];
}

#ifdef rsrc_gaddr
#undef rsrc_gaddr
#endif
int rsrc_gaddr(int Type, int Index, void *Address)
{
	return( mt_rsrc_gaddr( Type, Index,Address, aes_global));
}


int mt_rsrc_load(char *Name, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={110,0,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)Name;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef rsrc_load
#undef rsrc_load
#endif
int rsrc_load(char *Name)
{
	return(mt_rsrc_load(Name, aes_global));
}

int mt_rsrc_obfix(void *Tree, int Index, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={114,1,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Index;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef rsrc_obfix
#undef rsrc_obfix
#endif
int rsrc_obfix(void *Tree, int Index)
{
	return(mt_rsrc_obfix(Tree, Index, aes_global));
}

int mt_rsrc_rcfix(void *rc_header, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={115,0,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)rc_header;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef rsrc_rcfix
#undef rsrc_rcfix
#endif
int rsrc_rcfix(void *rc_header)
{
	return(mt_rsrc_rcfix(rc_header, aes_global));
}

int mt_rsrc_saddr(int Type, int Index, void *Address, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={113,2,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = Type;
	aes_intin[1] = Index;
	aes_addrin[0] = (long)Address;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef rsrc_saddr
#undef rsrc_saddr
#endif
int rsrc_saddr(int Type, int Index, void *Address)
{
	return(mt_rsrc_saddr(Type, Index, Address,aes_global));
}
