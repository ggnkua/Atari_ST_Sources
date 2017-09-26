#include <ec_gem.h>
#include <gscript.h>

/* in IO.C */
extern OBJECT *omenu;
extern void switch_list(int res);
/* in ONLINE.C */
extern void script_online(int do_pm, int do_om, int do_warn);

/* GemScript constants */
static GS_INFO	ap_gi={sizeof(GS_INFO), 0x0100, GSM_COMMAND, 0};

/* Commands */
static char *GS_EXCHANGE="mail_exchange";

/* Errors */
static char *GS_ERR="-1\0\0"; /* generic error */
static char *GS_INVAL="-2\0\0"; /* parameter error */


void process_gs_request(int *pbuf)
{
	int request_id=pbuf[7], rep_id=pbuf[1];
	
	pbuf[0]=GS_REPLY;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*(GS_INFO**)(&(pbuf[3]))=&ap_gi;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=request_id;
	appl_write(rep_id, 16, pbuf);
}

/* -------------------------------------- */

int menu_locked(OBJECT *tree)
{/* PrÅft, ob alle MenÅtitel auûer dem ersten disabled sind */
#define obj_type(a, b) ((int)(a[b].ob_type & 0xff))
	int go=0, ob=0;
	
	do
	{
		if(obj_type(tree, ob)==G_TITLE)
		{	
			if(go)
			{
				if(!(tree[ob].ob_state & DISABLED)) return(0);
			}
			else
			{
				go=1;
			}
		}
	}while(!(tree[ob++].ob_flags & LASTOB));
	return(1);
#undef obj_type
}

/* -------------------------------------- */

void process_gs_command(int *pbuf)
{
	int rep_id=pbuf[1], result=GSACK_UNKNOWN;
	int	pm, om, warn;
	static int in_buf[8];
	char *cmd=*(char**)(&(pbuf[3])), *my_err;

	/* Puffer merken, weil im Falle script_online alles Åberschrieben wird */	
	for(om=0; om < 8; ++om) in_buf[om]=pbuf[om];

	if(!stricmp(cmd, GS_EXCHANGE))
	{/* geht das? */
		if(menu_locked(omenu))
		{
			result=GSACK_ERROR; my_err=GS_ERR;
		}
		else
		{
			cmd+=strlen(GS_EXCHANGE)+1; /* Zeigt jetzt auf Parameter 1 =  do pm */
			pm=atoi(cmd);
			while(*cmd) ++cmd;
			++cmd; /* Zeigt jetzt auf Parameter 2 */
			om=atoi(cmd);
			while(*cmd) ++cmd;
			++cmd; /* Zeigt jetzt auf Paramter 3 */
			warn=atoi(cmd);
			
			if((pm==0) && (om==0))
			{
				result=GSACK_ERROR; my_err=GS_INVAL;
			}
			else
			{
				lock_menu(omenu);
				script_online(pm, om, warn);
				unlock_menu(omenu);
				switch_list(0);

				result=GSACK_OK; my_err=NULL;
			}
						
		}
	}

	in_buf[0]=GS_ACK;
	in_buf[1]=ap_id;
	in_buf[2]=0;
	/* leave pbuf[3/4] untouched */
	*(char**)(&(in_buf[5]))=my_err;
	in_buf[7]=result;
	appl_write(rep_id, 16, in_buf);
}
