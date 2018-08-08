/*  main.c             (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *	main module for STiK run as a desk accessory...
 */
#include "lattice.h" 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#include <tos.h>		/* 1 Supexec */
#include "device.h"

#include "globdefs.h"
#include "globdecl.h"
#include "krmalloc.h"
#include "display.h"
#include "ppp.h"
#include "resolve.h"

static int	initialised = FALSE;
static int  carrier = 0;
static int	closing_port = 0;

DEV_LIST *bdev_list;
DEV_LIST *bdev = (DEV_LIST *)NULL; /* Our global device for all I/O	*/

extern STATE_DATA state_info;

int16 new_carrier_detect(void);

static char *dial_file;

static char *etxt[] = {
    "No error",
    "Output Buffer full",
    "No data available",
    "EOF from remote",
    "RST received from remote",
    "RST.  Other end sent unacceptable pkt",
    "No memory available",
    "Connection refused by remote",
    "A SYN was received in the window",
    "Bad connection handle used",
    "Socket in LISTEN state, can't send",
    "No free CCB's available",
    "No connection matches this packet (TCP)",
    "Failure to connect to remote port (TCP)",
    "Invalid TCP_close() requested",
    "User timout expired",
    "Connection timed out",
    "Domain query, Can't resolve",
    "Bad format in domain name or dotted decimal",
    "Modem is not connected",
    "Hostname does not exist",
    "Resolver reached work limit",
    "No nameserver found",
    "Bad format of DNS query",
    "Destination unreachable",
    "No Address records found for name",
    "Routine unavailable - Locked by another APP"
};

int16 lastcn; /* last connection index for searches */

char * cdecl get_err_text(int16 code)
{
    code = abs(code);

    if (code >= 0 && code <= E_LASTERROR)
        return (etxt[code]);

    else
        return ("");
}

static void setlineprotocol(uint16 prot)
{
	switch (prot)
	{
	case LP_SLIP:
	case LP_CSLIP:
					prot_in = slip_in;
					prot_out = slip_out;
					prot_kicker = dummyfn;
					prot_term = dummyfn;
					break;
	case LP_PPP:
					prot_in = ppp_in;
					prot_out = ppp_out;
					prot_kicker = ppp_kicker;
					prot_term = ppp_term;
	}
}

int port_open = FALSE;

int16 cdecl on_port(char *port)
{
	/*
		We will need to do a search of the array to find the port that the user
		wants to open, then determine whether it is already open or not.
	*/

/*    char ert[50];*/

	if (port[1] != '\0' || (port[0] != '0' && port[0] != '1')) {
		while (bdev != (DEV_LIST *)NULL) {
			if (!strcmp(port, bdev->name))
				break;

			bdev = bdev->next;
		}
		if (bdev == (DEV_LIST *)NULL) {
/*			strcpy(ert, "Invalid Serial Port | Using ");*/
			bdev = bdev_list;
/*			strcat(ert, bdev->name);
			disp_info(ert);*/
		}
	}

	/* setup function pointers - must be before port_open is changed */

	setlineprotocol(config.line_protocol);

	if (port_open == TRUE)
		{
			/*disp_info("aborting port open\r\n");*/
			return (TRUE);
		}

	if (bdev == (DEV_LIST *)NULL)
		return (FALSE);

	port_open = OpenDevice(bdev);

	config.slp->bdev = bdev;

	/* Now init some info */

    config.mss = config.mtu - 40;

    config.df_bufsize = max(config.mtu,8192);

	if (config.line_protocol == LP_CSLIP)
	{
			config.slp->flags = SLF_USRMASK;
					
			/*config.slp->flags &= ~SLF_USRMASK;*/
	}
	else if (config.line_protocol == LP_SLIP)
	{
		config.slp->flags = 0x0;
	}

	return (port_open);
}

void cdecl off_port(char *port)
{
	if (port_open == FALSE || config.slp->bdev == (DEV_LIST *)NULL)
	{
		disp_info("off port failed\r\n");
		return;
	}
		
	if (port[1] != '\0' || (port[0] != '0' && port[0] != '1'))
	{
		while (bdev != (DEV_LIST *)NULL)
		{
			if (!strcmp(port, bdev->name))
				break;

			bdev = bdev->next;
		}

		if (bdev == (DEV_LIST *)NULL)
		{
			/*Invalid Serial Port Using bdev->name*/
			bdev = bdev_list;
		}
	}

	/*config.slp->bdev = bdev;*/

	port_open = FALSE;

	closing_port = 1;
	
	while (closing_port)
		;
}

void
close_port(void)
{
	CloseDevice(bdev);

	config.slp->bdev = (DEV_LIST *)NULL;

	carrier = -1;
	closing_port = 0;
}

#if 0
int stik_disable(void)
{
	int button;

	extern int cn_count;
	extern void CNcloseall(void);

	if (cn_count) {
		button = form_alert(2, "[3][ | Open Connections "
							   " | Close all??? ][ Yes | Cancel ]");

		if (button != 1)
			return (1);

		CNcloseall();
	}
	if (port_open && carrier_detect() >= 0 && config.cn_time) {
		button = form_alert(2, "[3][ | Hangup Modem ?? ]"
							   "[ Yes | No ]");

		if (button == 1)
			disconnect();
	}

	if (query_port(config.slp->bdev->name))
		{
			off_port(config.slp->bdev->name);
		}

	/* removed this to change to always active */

	return (0);
}
#endif

int16 cdecl query_port(char *port)
{
/*    char ert[50];*/

	if (port_open == FALSE || config.slp->bdev == (DEV_LIST *)NULL)
		return FALSE;

	if (port[1] != '\0' || (port[0] != '0' && port[0] != '1')) 
	{
		while (bdev != (DEV_LIST *)NULL) 
		{
			if (!strcmp(port, bdev->name))
				break;

			bdev = bdev->next;
		}

		if (bdev == (DEV_LIST *)NULL) 
			{
				return(FALSE); /* If the port doesn't exist don't tell them it does */			
			}
	}

	return TRUE;
}

static long
slip_cfg_init(void)
{
	int i;
	
/*  Build up SLIP structure, later we will need multiple ones */

/*	config.slp->bdev = (DEV_LIST *)bdev;*/

	config.slp->bdev = (DEV_LIST *)NULL;

	memset(config.slp->comp, 0, sizeof(struct slcompress));

	for (i=0; i < MAX_STATES ; i++)
	{
		config.slp->comp->rstate[i] = (struct cstate *)STiKmalloc(sizeof(struct cstate));
	}

	for (i=0; i < MAX_STATES ; i++)
	{
		config.slp->comp->tstate[i] = (struct cstate *)STiKmalloc(sizeof(struct cstate));
	}
		
	for (i = MAX_STATES - 1; i > 0; --i)
	{
		config.slp->comp->tstate[i]->cs_id = i;
		config.slp->comp->tstate[i]->cs_next = (struct cstate *)&config.slp->comp->tstate[i - 1]; 
	}

	config.slp->comp->tstate[0]->cs_next = (struct cstate *)&config.slp->comp->tstate[MAX_STATES - 1];
	config.slp->comp->tstate[0]->cs_id = 0;
	config.slp->comp->last_cs = (struct cstate *)&config.slp->comp->tstate[0];
	
	config.slp->comp->last_recv = 255;
	config.slp->comp->last_xmit = 255;

	return 1;
}

void
reset_userpass(void)
{
   config.password = getvstr("PASSWORD");
   
   /* needed */
   
   config.username = getvstr("USERNAME");

   config.pap_id = getvstr("PAP_ID");
   
   if (strcmp(config.pap_id,"0")==0)
	{
   		setvstr("PAP_ID", config.username);
   		config.pap_id =getvstr("PAP_ID");
	}
   if (strcmp(config.username,"0")==0)
	{
   		setvstr("USERNAME", config.pap_id);
   		config.username =getvstr("USERNAME");
	}	
	if ((strcmp(config.username,"0")==0)&&
		(strcmp(config.pap_id,"0")==0))
	{
		disp_info("No USERNAME or PAP_ID variables set\n");
		disp_info("Configure one or both and reboot your system\n");	
	}
}

/*************************** ppp_cfg_init() ***********************/
/* This function sets up the necessary PPP parameters */
static void ppp_cfg_init(void)
{
	/* Tell PPP to request compression */
	/* IP Compression added here when we support it
	state_info.send_opt[IPCP_OFFSET] |=
			(1 << IP_COMPRESSION_PROTOCOL); */
	state_info.send_opt[LCP_OFFSET] |= 
			(1 << PROTOCOL_FLD_COMPRESSION_ID) |
			(1 << ADDR_AND_CTRL_FLD_COMP_ID);
	/* Everything else is plain ol' PPP */
} /* ppp_cfg_init() */


int init_stuff(void)
{
    int x;
	long sstat;
    extern uint16 unique_id;
    int32 lval;
    int16 ival;
    char *cp;
    char cfg_file[50]; /*, ert[50];*/
	extern unsigned char flagbox[64];
	extern long init_drivers(void);
	
	for (x = 0; x < 64; flagbox[x++] = 0)
		;

	strcpy(cfg_file, cdir);
	strcat(cfg_file, "DEFAULT.CFG");

    if (init_cfg(cfg_file) < 0) 
    {
		disp_info("Can't load config");
        return (-1);
    }

    lval = atol(getvstr("ALLOCMEM"));

    if (lval < 2)
        lval = 75000L;

    if (!STiKmeminit(lval)) {
		disp_info("Can't allocate memory");
        return (-1);
    }

	sstat = Supexec(init_drivers);
	
	if (sstat) {
		if (sstat == 1)
			{
				disp_info("STiK Cookie Not Present!");
			}
		else if (sstat == 2)
			{
				disp_info("No Cookie Jar");
			}

		return (-1);
	}

	/* Initialise serial devices */

	bdev_list = InitDevices((void *)NULL, (void *)NULL);

	bdev = bdev_list;	/* Set current dev to start of list */

	if (resolveinit() < 0) 
	{
		disp_info("Can't initialise DNS");
		return (-1);
	}

    /*  Clear stat log array   */
    for (x = 0; x < E_REASONS; ++x)
        elog[x] = 0L;

    /* OK, initialise stuff from the loaded config file */

    config.max_num_ports = 1;

    cp = getvstr("CLIENT_IP");
    if ((lval = atol(cp)) != 0) {
        if ((config.client_ip = dd_to_ip(cp)) <= 1L) {
            disp_info("CLIENT_IP bad format");
		}
    }

    cp = getvstr("SERIALPORT");

/*	if (cp[1] != '\0' || (cp[0] != '0' && cp[0] != '1')) {
		while (bdev != (DEV_LIST *)NULL) {
			if (!strcmp(cp, bdev->name))
				break;

			bdev = bdev->next;
		}
		if (bdev == (DEV_LIST *)NULL) {

			strcpy(ert, "Invalid Serial Port | Using ");
			
			bdev = bdev_list;
			
			strcat(ert, bdev->name);
			disp_info(ert);
		}
	}
*/
    cp = getvstr("CDVALID");

    if ((lval = atol(cp)) != 0)
        config.cd_valid = TRUE;
    else
        config.cd_valid = FALSE;

    cp = getvstr("TTL");
    if ((lval = atol(cp)) != 0)
        config.ttl = (uint16)lval;
    else
    	config.ttl = 64;

    cp = getvstr("PING_TTL");
    if ((lval = atol(cp)) != 0)
        config.ping_ttl = (uint16)lval;
    else
    	config.ping_ttl = 255;

    cp = getvstr("SLICE");
    if ((ival = atoi(cp)) >= 0)
        config.slice = ival;
	else
		config.slice = 0;

    cp = getvstr("MTU");
    if ((lval = atol(cp)) != 0)
        config.mtu = (uint16)lval;
    else
    	config.mtu = 1500;

    config.mss = config.mtu - 40;

    config.df_bufsize = max(config.mtu,8192);

    cp = getvstr("RCV_WND");
    if ((lval = atol(cp)) != 0)
        config.rcv_window = (uint16)lval;
    else
    	config.rcv_window = config.mtu * 4;

    cp = getvstr("PROVIDER");
    if (cp[1] && cp[0] != '0' && cp[0] != '1') 
    {
        if ((uint32)(lval = dd_to_ip(cp)) > 1)
            config.provider = (uint32)lval;
    }

	/* remove */

    cp = getvstr("DIALFILE");
    if (cp[0] == '0' || cp[0] == '1')
        dial_file = "dial.scr";
    else
        dial_file = cp;

	/* remove when identd in */

    cp = getvstr("UP_RESPONSE");
    if ((lval = atol(cp)) != 0) {
        if (lval < 0 || lval > 3)
            disp_info("UP_RESPONSE value out of range");
        else
            config.unreach_resp = (uint16)lval - 1;
    }

	/* used only in IP.C - remove and make hacker variable */

	cp = getvstr("YIELD");
	
	if((lval = atol(cp)) == 1)
		yield = _appl_yield;
	else
		yield = dummyfn;

   cp = getvstr("REPORT");
    if ((lval = atol(cp)) != 0)
        config.reports = (uint16)lval;

	/* required */

   cp = getvstr("PROTOCOL");
   if ( ((lval = strtol(cp,NULL,10)) >= LP_SLIP) && ( lval <= LP_PPP ) )
	{
        config.line_protocol = (uint16)lval;
    }
	else
	{
		printf("Error with PROTOCOL variable: setting default PPP\n");
   		config.line_protocol = LP_PPP;
   	}

	/* needed */

	reset_userpass();

#if 0
   config.password = getvstr("PASSWORD");
   
   /* needed */
   
   config.username = getvstr("USERNAME");

   config.pap_id = getvstr("PAP_ID");
   
   if (strcmp(config.pap_id,"0")==0)
	{
   		setvstr("PAP_ID", config.username);
   		config.pap_id =getvstr("PAP_ID");
	}
   if (strcmp(config.username,"0")==0)
	{
   		setvstr("USERNAME", config.pap_id);
   		config.username =getvstr("USERNAME");
	}	
	if ((strcmp(config.username,"0")==0)&&
		(strcmp(config.pap_id,"0")==0))
	{
		disp_info("No USERNAME or PAP_ID variables set\n");
		disp_info("Configure one or both and reboot your system\n");	
	}
#endif

    init_ports();       /* Initialise the current user port value (TCP) */

	/* Now I'm going to bump up the recieve and send buffers */
	
	/*SetRxBuffer		( bdev, 12288);
	SetTxBuffer		( bdev, 12288);*/

	config.slp = myslip = (struct slip *)STiKmalloc(sizeof(struct slip));
	config.slp->comp = myslip->comp = comp = (struct slcompress *)STiKmalloc(sizeof (struct slcompress));

	switch (config.line_protocol)
	{
	case LP_SLIP:
	case LP_CSLIP:
					slip_cfg_init();
					break;
	case LP_PPP:
					ppp_cfg_init();
					break;
	}
	
    srand((int)clock());
    unique_id = rand();

	/* init local host value */
	
	config.localhost = 0x7F000001L;

	/* Open the identd port */
	
	config.identdcn = -1;

	/* Initialize lastcn variable */
	lastcn = 0; 

	/* Initialize carrier value - for carrier detect */

	carrier = -1;

	initialised = TRUE;

    return (1);
}

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

/* For compatbility only */

int16 cdecl carrier_detect(void)
{
	return(carrier); /* Now return value from new_carrier detect was  0; Status unknown */
}


/* Stuff from the old dialer.c */
int16 new_carrier_detect(void)
{
    if (!config.cd_valid)
    {
    	carrier = 0;
    	return 0;				/*	Status unknown	*/
	}

	if (IsCarrier(bdev))
		carrier = 1;				/*	Carrier On		*/
	else
		carrier = -1;				/*	Carrier Off		*/
		
	return(carrier);
}

void cdecl ser_disable(void)	/* Disable serial I/O (prior to file access)	*/
{
	return;

/*	StopReceiver(bdev); */
}

void cdecl ser_enable(void)	/* Enable serial I/O (after disk access)	*/
{
	return;

/*	StartReceiver(bdev); */
}

clock_t msclock(void)
{
    return (Sclock()*(1000/CLK_TCK));
}
