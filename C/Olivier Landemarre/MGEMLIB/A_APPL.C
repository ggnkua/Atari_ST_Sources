/*
 * Aes application library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cg -- d2cg@dtek.chalmers.se
 * modified: cf -- felsch.tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 */
#include <string.h>
#include "mgem.h"


int mt_appl_bvset(int bvdisk, int bvhard, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={16,2,1,0,0};
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

                    
	aes_intin[0] = bvdisk;
	aes_intin[1] = bvhard;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef appl_bvset
#undef appl_bvset
#endif
int appl_bvset(int bvdisk, int bvhard)
{
	return(mt_appl_bvset(bvdisk, bvhard, aes_global));
}

int mt_appl_control(int ap_cid, int ap_cwhat, void *ap_cout, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={129,2,1,1,0};
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
                   
	aes_intin[0] = ap_cid;
	aes_intin[1] = ap_cwhat;
	aes_addrin[0] = (long)ap_cout;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef appl_control
#undef appl_control
#endif
int appl_control(int ap_cid, int ap_cwhat, void *ap_cout)
{
	return(mt_appl_control(ap_cid,ap_cwhat,ap_cout, aes_global));
}

int mt_appl_exit(INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={19,0,1,0,0};
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

#ifdef appl_exit
#undef appl_exit
#endif
int appl_exit(void)
{
	return(mt_appl_exit(aes_global));
}

int mt_appl_find(char *Name, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={13,0,1,1,0};
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

#ifdef appl_find
#undef appl_find
#endif
int appl_find(char *Name)
{
	return(mt_appl_find(Name, aes_global));
}

int mt_appl_getinfo(int type, INT16 *out1, INT16 *out2, INT16 *out3, INT16 *out4, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={130,1,5,0,0};
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
                    
	aes_intin[0] = type;

	aes(&aes_params);

	*out1 = aes_intout[1];
	*out2 = aes_intout[2];
	*out3 = aes_intout[3];
	*out4 = aes_intout[4];
	return aes_intout[0];
}

#ifdef appl_getinfo
#undef appl_getinfo
#endif
int appl_getinfo(int type, INT16 *out1, INT16 *out2, INT16 *out3, INT16 *out4)
{
	return(mt_appl_getinfo(type,out1, out2, out3, out4, aes_global));
}

int mt_appl_init(INT16 *global_aes)
{
		int ff;
		INT16 *pts;
		long *ptl;
		
   	static INT16 	aes_control[AES_CTRLMAX]={10,0,1,0,0};
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
                    
	/* clear all binding arrays */
	/* other binding arrays are synonyms for the stuff */
	/* listed below - c.f. "common.h"				 */

	for(ff=0,pts=&aes_intin[0];ff<AES_INTINMAX;ff++) *(pts++)=0;
	for(ff=0,pts=&aes_intout[0];ff<AES_INTOUTMAX;ff++) *(pts++)=0;
	for(ff=0,ptl=&aes_addrin[0];ff<AES_ADDRINMAX;ff++) *(ptl++)=0L;
	for(ff=0,ptl=&aes_addrout[0];ff<AES_ADDROUTMAX;ff++) *(ptl++)=0L;
	for(ff=0,pts=&global_aes[0];ff<AES_GLOBMAX;ff++) *(pts++)=0;

	aes(&aes_params);

	gl_ap_version = aes_global[0];
	gl_apid = aes_intout[0];
	return aes_intout[0];
}

#ifdef appl_init
#undef appl_init
#endif
int appl_init(void)
{
	return(mt_appl_init(aes_global));
}

int mt_appl_read(int ApId, int Length, void *ApPbuff, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={11,2,1,1,0};
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
                    
	aes_intin[0] =  ApId;
	aes_intin[1] = Length;
	aes_addrin[0] = (long)ApPbuff;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef appl_read
#undef appl_read
#endif
int appl_read(int ApId, int Length, void *ApPbuff)
{
	return(mt_appl_read(ApId, Length, ApPbuff, aes_global));
}


int mt_appl_search(int mode, char *fname, INT16 *type, INT16 *ap_id, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={18,1,3,1,0};
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
                    
	aes_intin[0] = mode;
	aes_addrin[0] = (long)fname;

	aes(&aes_params);

	*type = aes_intout[1];
	*ap_id = aes_intout[2];
	return aes_intout[0];
}

#ifdef appl_search
#undef appl_search
#endif
int appl_search(int mode, char *fname, INT16 *type, INT16 *ap_id)
{
	return(mt_appl_search( mode, fname, type, ap_id, aes_global));
}


int mt_appl_tplay(void *Mem, int Num, int Scale, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={14,2,1,1,0};
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
                    
	aes_intin[0] =	Num;
	aes_intin[1] =	Scale;
	aes_addrin[0] = (long)Mem;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef appl_tplay
#undef appl_tplay
#endif
int appl_tplay(void *Mem, int Num, int Scale)
{
	return(mt_appl_tplay(Mem, Num, Scale, aes_global));
}


int mt_appl_trecord(void *Mem, int Count, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={15,1,1,1,0};
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
                    
	aes_intin[0] = Count;
	aes_addrin[0] = (long)Mem;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef appl_trecord
#undef appl_trecord
#endif
int appl_trecord(void *Mem, int Count)
{
	return(mt_appl_trecord(Mem, Count, aes_global));
}


int mt_appl_write(int ApId, int Length, void *ApPbuff, INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={12,2,1,1,0};
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

	aes_intin[0] = ApId;
	aes_intin[1] = Length;
	aes_addrin[0] = (long)ApPbuff;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef appl_write
#undef appl_write
#endif
int appl_write(int ApId, int Length, void *ApPbuff)
{
	return(mt_appl_write( ApId, Length, ApPbuff, aes_global));
}

int mt_appl_yield(INT16 *global_aes)
{
   	static INT16 	aes_control[AES_CTRLMAX]={17,0,1,0,0};
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

#ifdef appl_yield
#undef appl_yield
#endif
int appl_yield(void)
{
	return(mt_appl_yield(aes_global));
}
