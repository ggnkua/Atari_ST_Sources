#include <stdio.h>
#include <aes.h>
#include <tos.h>
#include <stddef.h>
#include <string.h>
#include <magx.h>
#include <fido_msg.h>

#define FALSE	0
#define TRUE	1

int ap_id,
		has_appl_search=FALSE;

int getcookie (long cookie,long *p_value)
{	long oldstack = 0L,*cookiejar;
	if (!Super ((void *)1L)) oldstack = Super (0L);
	cookiejar = *((long **)0x5a0L);
	if (oldstack) Super ((void *)oldstack);
	if (!cookiejar) return 0;
	do
	{	if (cookiejar[0] == cookie)
		{	if (p_value)
				*p_value = cookiejar[1];
			return 1;
		}
		else
			cookiejar = &(cookiejar[2]);
	}
	while (cookiejar[-2]);
	return 0;
}

void send_msg(int id_to,long info)
{	int pipe[8];
	pipe[0] = FIDO_MSG;
	pipe[1] = ap_id;
	pipe[2] = 0;
	*((long *) &pipe[3]) = 'FTST';			/* own ID (dummy value) */
	*((long *) &pipe[5]) = info;
	pipe[7] = 0;
	appl_write(id_to,16,pipe);
}

void send_to(char *prg,long info)
{	int rc,id,type;
	char program[128];
	if (has_appl_search)
	{ rc = appl_search(0,program,&type,&id);
		while( rc )
		{	if ( !strncmpi(program,prg,8) && id!=ap_id )
				send_msg(id,info);
			rc = appl_search(1,program,&type,&id);
		}
	}
	else
	{ id = appl_find(prg);
		if ( id>=0 && id!=ap_id )
			send_msg(id,info);
	}
}

void main(void)
{	int pipe[8],which,mx,my,mb,ks,kr,br,
			aes_version,i,j;
	long value;
	MAGX_COOKIE *MagX;

	ap_id=appl_init();
	aes_version = _GemParBlk.global[0];

/*
**	Test, if multitasking environment
*/

	MagX = getcookie( 'MagX', &value ) ? (MAGX_COOKIE *) value : NULL;
	if ( aes_version>=0x400 ||
			 wind_get(0,'WX',&i,&i,&i,&i)=='WX'	||
			 (MagX && MagX->aesvars && MagX->aesvars->version>=0x200) )
	{	if (appl_getinfo(4,&i,&i,&j,&i))
			has_appl_search = j ? TRUE : FALSE;
	}

/*
**	Send FidoMessage 'FM' with command ???_INFO to all AVALON and
**	LED tasks
*/

	send_to("LED     ",LED_INFO);
	send_to("AVALON  ",AVAL_INFO);

/*
**	Wait 5 sec. for returning 'FI' FIDO_INFO message
*/

	do
	{ which = evnt_multi(MU_MESAG|MU_TIMER,
  										2,1,1,0,0,0,0,0,0,0,0,0,0,pipe,
   										5000,0,
   									 	&mx,&my,&mb,&ks,&kr,&br);
		printf("--------\n");
		if (which & MU_MESAG)
		{	printf("Message type: %c%c \n",pipe[0] >> 8,pipe[0]);
			printf("From program: %u  (appl_init) \n",pipe[1]);
			printf("From program: %c%c%c%c \n",pipe[3] >> 8,pipe[3],pipe[4] >> 8,pipe[4]);
			printf("Prog.version: %#4x \n",pipe[5]);
			printf("Command rev : %#4x \n",pipe[6]);
		}	
 	}
  while (which & MU_MESAG);

	appl_exit();
}
