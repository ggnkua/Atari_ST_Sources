/*	CRYSIF.C	05/04/84 - 12/19/84		Lee Lorenzen	*/
#include <portab.h>
#include <gemlib.h>

#include "crysbind.h"
#include "cryslib.h"

#define EXTERN extern


EXTERN	BYTE	ctrl_cnts[];

typedef struct cblk
{
	LONG		cb_pcontrol;
	LONG		cb_pglobal;
	LONG		cb_pintin;
	LONG		cb_pintout;
	LONG		cb_padrin;
	LONG		cb_padrout;		
} CBLK;
				


WORD	crystal( LONG pb );
WORD	crys_if( WORD opcode );


CBLK		c;
UWORD		control[C_SIZE];
UWORD		global[G_SIZE];
WORD		int_in[I_SIZE];
UWORD		int_out[O_SIZE];
LONG		addr_in[AI_SIZE];
LONG		addr_out[AO_SIZE];
LONG		ad_c;


WORD
crys_if( opcode )
WORD	opcode;
{
	WORD		i;
	BYTE		*pctrl;

	/* Load the AES Parameter Block */
	c.cb_pcontrol = (LONG)&control[0]; 
	c.cb_pglobal  = (LONG)&global[0];
	c.cb_pintin   = (LONG)&int_in[0];
	c.cb_pintout  = (LONG)&int_out[0];
	c.cb_padrin   = (LONG)&addr_in[0];
	c.cb_padrout  = (LONG)&addr_out[0];
	ad_c = ( LONG )&c;

	control[0] = opcode;

	pctrl = &ctrl_cnts[(opcode - 10) * 3];
	for(i=1; i<C_SIZE; i++)
	  control[i] = *pctrl++;

	crystal( ad_c );
	return( ( WORD )RET_CODE );
}
