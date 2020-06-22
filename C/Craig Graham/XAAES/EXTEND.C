/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"

/*
	Extended XaAES calls
*/

/*
	Get the file handle of the client reply pipe
*/
unsigned long XA_appl_pipe(short clnt_pid, AESPB *pb)
{
	pb->intout[0]=clients[clnt_pid].clnt_pipe_rd;
	return XAC_DONE;
}
