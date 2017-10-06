/*
 *	Aes shel library interface
 *
 *	++jrb	bammi@cadence.com
 *	modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre@utbm.fr
 */
#include "mgem.h"


int mt_shel_envrn(char **result, char *param, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={125,0,1,2,0};
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

                    
	aes_addrin[0] = (long)result;
	aes_addrin[1] = (long)param;

	aes(&aes_params);

	return aes_intout[0];
}


#ifdef shel_envrn
#undef shel_envrn
#endif
int shel_envrn(char **result, char *param)
{
	return(mt_shel_envrn(result,param, aes_global));
}

int mt_shel_find(char *buf, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={124,0,1,1,0};
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

   	aes_addrin[0] = (long)buf;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_find
#undef shel_find
#endif
int shel_find(char *buf)
{
	return(mt_shel_find(buf, aes_global));
}


int mt_shel_get(char *Buf, int Len, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={122,1,1,1,0};
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

                    
	aes_intin[0] = Len;
	aes_addrin[0] = (long)Buf;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_get
#undef shel_get
#endif
int shel_get(char *Buf, int Len)
{
	return(mt_shel_get(Buf, Len, aes_global));
}


int mt_shel_help(int sh_hmode, char *sh_hfile, char *sh_hkey, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={128,1,1,2,0};
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

                    
	aes_intin[0] = sh_hmode;
	aes_addrin[0] = (long)sh_hfile;
	aes_addrin[1] = (long)sh_hkey;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_help
#undef shel_help
#endif
int shel_help(int sh_hmode, char *sh_hfile, char *sh_hkey)
{
	return(mt_shel_help(sh_hmode, sh_hfile, sh_hkey, aes_global));
}


int mt_shel_put(char *Buf, int Len, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={123,1,1,1,0};
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

 	aes_intin[0] = Len;
	aes_addrin[0] = (long)Buf;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_put
#undef shel_put
#endif
int shel_put(char *Buf, int Len)
{
	return(mt_shel_put(Buf, Len, aes_global));
}


int mt_shel_rdef(char *lpcmd, char *lpdir, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={126,0,1,2,0};
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

                    
	aes_addrin[0] = (long)lpcmd;
	aes_addrin[1] = (long)lpdir;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_rdef
#undef shel_rdef
#endif
int shel_rdef(char *lpcmd, char *lpdir)
{
	return(mt_shel_rdef(lpcmd, lpdir, aes_global));
}


int mt_shel_read(char *Command, char *Tail, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={120,0,1,2,0};
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

                    
	aes_addrin[0] = (long)Command;
	aes_addrin[1] = (long)Tail;

	aes(&aes_params);
	return aes_intout[0];
}

#ifdef shel_read
#undef shel_read
#endif
int shel_read(char *Command, char *Tail)
{
	return(mt_shel_read(Command, Tail, aes_global));
}


int mt_shel_wdef(char *lpcmd, char *lpdir, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={127,0,1,2,0};
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

                    
	aes_addrin[0] = (long)lpcmd;
	aes_addrin[1] = (long)lpdir;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_wdef
#undef shel_wdef
#endif
int shel_wdef(char *lpcmd, char *lpdir)
{
	return(mt_shel_wdef(lpcmd, lpdir, aes_global));
}


int mt_shel_write(int wodex, int wisgr, int wiscr, void *cmd, char *tail, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={121,3,1,2,0};
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

                    
	aes_intin[0] = wodex;
	aes_intin[1] = wisgr;
	aes_intin[2] = wiscr;
	aes_addrin[0] = (long)cmd;
	aes_addrin[1] = (long)tail;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef shel_write
#undef shel_write
#endif
int shel_write(int wodex, int wisgr, int wiscr, void *cmd, char *tail)
{
	return(mt_shel_write(wodex, wisgr, wiscr, cmd, tail, aes_global));
}
