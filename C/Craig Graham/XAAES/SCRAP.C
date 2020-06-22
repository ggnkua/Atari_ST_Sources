/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <strings.h>
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"

/*
	Scrap/clipboard directory stuff
*/

unsigned long XA_scrap_read(short clnt_pid, AESPB *pb)
{
	strcpy((char*)pb->addrin[0],scrap_path);
	pb->intout[0]=1;
	
	return XAC_DONE;
}

unsigned long XA_scrap_write(short clnt_pid, AESPB *pb)
{
	char *new_path=(char*)pb->addrin[0];
	
	if (strlen(new_path)<128)
	{
		strcpy(scrap_path,new_path);
		pb->intout[0]=1;
	}else{
		pb->intout[0]=0;
	}
	
	return XAC_DONE;
}
