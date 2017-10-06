/*
 *	Aes shel library interface
 *
 *	++jrb	bammi@cadence.com
 *	modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int shel_envrn(char **result, char *param)
{
	aes_addrin[0] = (long)result;
	aes_addrin[1] = (long)param;
   aes_control[0] = 125;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_find(char *buf)
{
	aes_addrin[0] = (long)buf;
   aes_control[0] = 124;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_get(char *Buf, int Len)
{
	aes_intin[0] = Len;
	aes_addrin[0] = (long)Buf;
   aes_control[0] = 122;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_help(int sh_hmode, char *sh_hfile, char *sh_hkey)
{
	aes_intin[0] = sh_hmode;
	aes_addrin[0] = (long)sh_hfile;
	aes_addrin[1] = (long)sh_hkey;
   aes_control[0] = 128;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_put(char *Buf, int Len)
{
	aes_intin[0] = Len;
	aes_addrin[0] = (long)Buf;
   aes_control[0] = 123;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_rdef(char *lpcmd, char *lpdir)
{
	aes_addrin[0] = (long)lpcmd;
	aes_addrin[1] = (long)lpdir;
   aes_control[0] = 126;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_read(char *Command, char *Tail)
{
	aes_addrin[0] = (long)Command;
	aes_addrin[1] = (long)Tail;
   aes_control[0] = 120;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

int shel_wdef(char *lpcmd, char *lpdir)
{
	aes_addrin[0] = (long)lpcmd;
	aes_addrin[1] = (long)lpdir;
   aes_control[0] = 127;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int shel_write(int wodex, int wisgr, int wiscr, void *cmd, char *tail)
{
	aes_intin[0] = wodex;
	aes_intin[1] = wisgr;
	aes_intin[2] = wiscr;
	aes_addrin[0] = (long)cmd;
	aes_addrin[1] = (long)tail;
   aes_control[0] = 121;
   aes_control[1] = 3;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}
