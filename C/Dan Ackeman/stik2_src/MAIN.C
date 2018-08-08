/*
 * stiktsr.c - TSR portion of STiK
 *
 *
 * Copyright (c) 1996 FreeSTiK team
 */
#include "lattice.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include "cookie.h"

#include "globdefs.h"
#include "globdecl.h"
#include "resolve.h"
#include "krmalloc.h"
#include "ppp.h"
#include "ppp.p"
#include "tpl.h"

#include "gemhook.h"


/*void (*myprog)();*/
long init(void);
extern void _invec(void);

static int	enabled = 0;	/* -1 = error, +1 = enabled	*/

static int cdrive;		/* Current drive at startup	*/
char cdir[100];	/* Config file directory	*/

GPKT *outqueue = (GPKT *)NULL;   /* Initial value must be NULL       */

#define TCP_DRIVER_VERSION	"02.00"
#define STATUS_TPL_VERSION  "01.00"

/* This will need to be expanded to one per port */
struct slip *myslip;
struct slcompress *comp;
struct cstate mytstate[MAX_STATES];
struct cstate myrstate[MAX_STATES];

/* Probably don't need machine type, but might later.	*/
static mch_type  =  0;	/* Value of the _MCH cookie		*/
#define MCH_ST		0
#define MCH_STE		1
#define MCH_TT		2
#define MCH_FALCON	3

#define VBLCNT 0x454L
#define VBLLIST 0x456L

long linkin(void);
long * vbl_hook;

CONFIG config = {
    0L,         	/* client_ip    */
    0L,         	/* provider_ip  */
    64,         	/* Norm TTL     */
    255,        	/* `ping' TTL   */
    252,        	/* MTU          */
    212,        	/* MSS          */
    580,        	/* Defrag buffer size   */
	5000,			/* TCP receive window */
    5000,       	/* Initial RTT 			*/
    TWAIT_DEF,  	/* TTIME_WAIT timout    */
    UP_ICMP,    	/* respond to pkt to unreachable ports  */
    0L,         	/* Time of connection (Unix time)       */
    FALSE,      	/* cd_valid     */
	LP_PPP,			/* Protocol SLIP/CSLIP/PPP */
	0L,				/* Address of Vector we have stolen */
	NULL,			/* SLP slip structure pointer */
    NULL,           /*  Space for extra config variables     */
	0,				/*  Should problem reports be printed to screen */
	0,				/* Max number of ports */
	0,				/* Received data count */
	0,				/* Sent data count */
	NULL,			/* User name */
	NULL,			/* User password */
	0,				/* Identdcn */
	0x7F000001L, 	/* Localhost 127.0.0.1 */
	1,				/* default slice value */
	NULL			/* PAP_ID */
};


struct TPL tpl = {
	"TRANSPORT_TCPIP",
	"(c) FreeSTiK team",
	TCP_DRIVER_VERSION,
	STiKextmalloc,
	STiKextfree,
	STiKextgetfree,
	STiKextrealloc,
	get_err_text,
	getvstr,
	carrier_detect,
	TCP_open,
	TCP_close,
	TCP_send,
	TCP_wait_state,
	TCP_ack_wait,
	UDP_open,
	UDP_close,
	UDP_send,
	CNkick,
	CNbyte_count,
	CNget_char,
	CNget_NDB,
	CNget_block,
	housekeep,
	resolve,
	ser_disable,
	ser_enable,
	set_flag,
	clear_flag,
	CNgetinfo,
	on_port,
	off_port,
	setvstr,
	query_port,
	CNgets,
	ICMP_send,
	ICMP_handler,
	ICMP_discard,
	TCP_info,
	cntrl_port,
	UDP_info,
	RAW_open,
	RAW_close,
	RAW_out,
	CN_setopt,
	CN_getopt,
	CNfree_NDB
};


/* Status is really a misnomer now, it's functions are for the dialer
 * etc.  Not direct communications routines. They are for getting and 
 * setting info on the STACK
 */
struct STATUS_TPL status = {
	"STACK_STATUS",
	"(c) FreeSTiK team",
	STATUS_TPL_VERSION,
	get_elog,
	query_state,
	Set_DNS
};

typedef struct drv_header {
	char *module;
	char *author;
	char *version;
} DRV_HDR;

extern DRV_HDR * cdecl get_dftab(char *);
extern int16	 cdecl ETM_exec(char *);

struct DRV_LIST {
	char magic[10];
	DRV_HDR * cdecl (*get_dftab)(char *);
	int16     cdecl (*ETM_exec)(char *);
	CONFIG	*config;
	DRV_HDR *drvlist[20];
} drivers = {
	"STiKmagic",
	get_dftab,
	ETM_exec,
	&config,
	(DRV_HDR *)&tpl,
	(DRV_HDR *)&status,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
};

DRV_HDR * cdecl get_dftab(char *drv_name)
{
	int x;

	for (x = 0; x < 20; ++x) {
		if (drivers.drvlist[x] == (DRV_HDR *)NULL)
			continue;

		if (!strcmp(drivers.drvlist[x]->module, drv_name))
			return (drivers.drvlist[x]);
	}

	return ((DRV_HDR *)NULL);
}

int16 cdecl ETM_exec(char *ex_mod)
{
	if (ex_mod)
		return (0);
	else
		return (0);
}


typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

long init_drivers(void)
{
	long i = 0;
	ck_entry *jar = *((ck_entry **) 0x5a0);

	while (jar[i].cktag) {
		if (!strncmp((char *)&jar[i].cktag, "STiK", 4)) {

			jar[i].ckvalue = (long)&drivers;
				
			return ((long)0);
		}
		
		++i;
	}
	

	return (2);	/* Pointless return value...	*/
}

unsigned int tos_ver;

static long get_tos_version()
{
	int i = 0;
	ck_entry *jar = *((ck_entry **) 0x5a0);
    unsigned long *_sysbase = (unsigned long *)0x4F2L;
	unsigned int *tv = (unsigned int *)*_sysbase + 1;

	if (jar != (ck_entry *)0) {
		while (jar[i].cktag) {
			if (!strncmp((char *)&jar[i].cktag, "_MCH", 4)) {
				mch_type = (int)(jar[i].ckvalue >> 16);
				break;
			}
			++i;
		}
	}

	tos_ver = *tv;

	return (0L);
}

long
install_cookie(void)
{
	if ( !get_cookie(STIK_COOKIE))	/* if not already installed*/
		{
			add_cookie(STIK_COOKIE,(long)&drivers);
		
			return(1L);
		}
	
	return (0L);
}

long tsrinit(void)
{
	int16 l;
	FILE *fp;

	extern int init_stuff(void);

	printf("\r\n\033p                STiK                    \r\n");
	printf("               v2.00pre2                \r\n");
	printf("Copyright 1997 Dan Ackerman             \r\n");
	printf("               Steve Adam               \r\n");
	printf("               Martin Mitchell          \r\n");
	printf("               Michael White            \033q\r\n");
	
	if (Supexec(install_cookie))	/* if not already installed*/
	{
			/* Set up config dir */
			/* First check STIK_DIR.DAT	*/
			if ((fp = fopen("STIK_DIR.DAT", "r")) != (FILE *)NULL) 
				{
					fgets(cdir, (int)99, fp);
					l = (int16)strlen(cdir) - 1;
					while (cdir[l] == '\n' || cdir[l] == ' ' || cdir[l] == '\t')
						cdir[l--] = '\0';

					fclose(fp);
				}
			else 
				{
					cdrive = (int)Dgetdrv();
					cdir[0] = 'A' + cdrive;
					cdir[1] = ':';
					strcpy(&cdir[2], "\\STIK_CFG\\");
				}
	
			enabled = init_stuff();

			printf(" Installed\n"
				   "%ld bytes resident\n",
					 _PgmSize);

		    if(!linkin())
		        {
				      printf("\n - cannot install interupt\n");
		        }
		}
	else
		{
			printf(" Not Installed\r\n");
			exit(1);
		}
    return 0;
}



void main()
{
	/*Supexec(tsrinit);*/
	tsrinit();
	
	Ptermres(_PgmSize,0);		/* sit into memory */
}

#if 0
long
init()				/* initialization */
{
  int i;
  long ssp;
  int cnt;
 void (**queue)();
 extern long *vbl_hook;
 extern void stik(void);

  vbl_hook = NULL;
  cnt = *(int*)VBLCNT;
  queue = *((void(***)())VBLLIST);
 
  ssp=Super(0L);		/* enter supervisor state */

  for (i=0; i<8; i++) 
  	{
  	  if (queue[i] == 0L) 
  	  	{
      		*(queue)[i]=stik;	/* install scheduler in vblank queue */
      		Super((void *)ssp);
      		return 1;		/* installation successful */
    	}
  	}
  	
  Super((void *)ssp);
  
  return -1;		/* installation failed */
}
#endif