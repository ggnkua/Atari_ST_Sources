#ifndef ulong
	#define ulong unsigned long
#endif
#ifndef uint
	#define uint unsigned int
#endif
#ifndef uchar
	#define uchar unsigned char
#endif

#define ICON_VERSION " V1.8"					/* RechtsbÅndig, fÅnf Zeichen */
#define ICON_VERSION_LONG 0x00010800l	/* BCD-Codiert */
#define ICON_SETUP_VERSION 3

typedef struct
{
	char	service[14];	/* 12+0+padding */
	ulong	ip;
	int		port;
	char	not_use[6*40+2];
}PROXY;


/* Script step actions */
#define SC_SEND_STRING	0
#define SC_SEND_CHAR		1
#define SC_PAUSE				2
#define SC_WAIT_FOR			3
#define SC_WAIT_CHAR		4
#define SC_USER_INPUT		5
#define SC_SECRET_INPUT	6
#define SC_READ_IP			7
#define SC_TERMINAL_ON	8
#define SC_DONE					9

typedef struct
{
	int		action;	/* 0-9, see above */
	int		param;	/* Parameter:
									 send string:	CR
									 send char:		char as int
									 pause:				seconds as int
									 wait for:		-
									 wait char:		char as int
									 user input:	CR
									 secret input:CR
									 Read IP:			-
									 Done:				Slip(0) or PPP(1)
									 Terminal on: -
								*/
						
	char	free_string[30];
}SCRIPT_STEP;

typedef struct
{
	char	name[22];	/* 20+0+padding */
	
	/* Modem */
	int		port;			/* Index to HSMODEM-List */
	int		baud;			/* All following: Index on static list */
	int		hshake;
	int		parity;
	int		dbits;
	int		sbits;
	char	port_name[20];	/* Name of Port in U:\DEV\, only used on storing */

	/* Hang up */
	char		hang_use_dtr;		/* 1=Yes */
	char		hang_escape[5];	/* Escape Sequence */
	char		hang_wait;			/* seconds to wait */
	char		hang_at[7];			/* AT command to hang up */
	
	/* Login */
	SCRIPT_STEP	login_step[50];
	int			login_wait_to;		/* Timeout */
	int			login_restart_to;	/* Timeout */
	
	/* Logout */
	SCRIPT_STEP	logout_step[50];
	int			logout_wait_to;		/* Timeout */
	int			logout_hangup_to;	/* Timeout */
	
	/* DNS, Resolver */
	ulong		dns_ip;
	int			query_to;		/* Timeout */
	int			query_rt;		/* Retries */
	int			use_cache;	/* 0/1 */
	int			cache_size;
	
	/* Services */
	char		email[46];	/* 44+0+padding */
	ulong		pop_ip;
	ulong		smtp_ip;
	ulong		news_ip;
	ulong		time_ip;
	ulong		reserved_ip[20];
	
	/* Proxies */
	PROXY		proxies[10];
	
	/* Slip */
	ulong		default_ip;
	
	/* PPP */
	char		ppp_auth_user[80];
	char		ppp_auth_pass[80];
	int			conf_retry;
	int			conf_to;
	int			term_retry;
	int			term_to;
	int			nak_ack;
	
	/* Sockets */
	int			path_env;	/* Use path(0) or env(1) setup */
	char		etc_path[256];	/* Gemdos-Path */
	char		etc_env[22];		/* 20+0+padding */
	int			min_port;
	int			max_port;
	int			max_backlog;
	
	/* TCP */
	int			conn_to;
	int			trans_to;
	int			default_rcv_win;
	int			precedence_raise;	/* Bit 0: 0/1 allow precedence raise */
														/* Bit 1: 0/1 disable(!) send-ahead */
	/* UDP */
	int			max_udp_ports;
	
	/* IP */
	int			in_queue_to;
	int			tos;
	int			precedence;
	int			ttl;
	unsigned int	mtu;
	
	/* PPP Additional */
	ulong		ppp_default_ip;

	/* T-Online Additional */
	int			t_online_mode;
	
	int			version;		/* 0=struct hîrt nach reserved_int auf */
											/* 1=Textfelder fÅr Services und Proxies folgen */
											/* 2=Textfelder fÅr POP-user und pass folgen */
	char		modem_init[24];
	char		phone_number[32];
	int			dial_type;			/* 0=Tone, 1=Pulse */
	int			redial_wait;		/* In Sekunden */

	/* Additional TCP parameter */
	int			default_snd_win;	/* send window limiter */
	
	char		real_name[66];
		
	/* Additional PPP parameter */
	int			lcp_echo_sec;
	
	/* Additional DNS parameter */
	/* IConnect uses a default one second delay in earlier versions (< 1.8)
		 If the user does simply upgrade to IConnect 1.8 his connection
		 might no longer work, because the value stored here is zero.
		 This would be very bad, poor poor user.
		 This is why we introduce a second variable, dns_initial_delay_set
		 If this is zero, IConf and IConnect will set dns_initial_delay to
		 one second and dns_initial_delay_set to 1 (which means true).
		 Everything else will then work as expected.
	*/
	int			dns_initial_delay;
	int			dns_initial_delay_set;
	
	int			reserved_int[29];  /* DONT FORGET TO CHANGE THE DEF BELOW! */
	
	/* Ab version 1 */
	char		service_names[24][66];	/* 64 Name+0+Padding */
	char		proxy_names[10][66];
	
	/* Ab version 2 */
	char		pop_user[80];
	char		pop_pass[80];
	
	/* Ab Version 3 */
	char		nntp_user[80];
	char		nntp_pass[80];	
}SETUP;
#define RESERVED_INT 29


typedef struct _set_list
{
	SETUP	*set;
	struct _set_list	*next;
}SET_LIST;


/* Establish-automaton states */
#define ES_INITIAL				0
#define ES_START_SCRIPT		1
#define ES_INIT_MODEM			2
#define ES_WAIT_MODEM			3
#define ES_DIAL						4
#define ES_WAIT_DIAL			5
#define ES_RESTART_SCRIPT	6
#define ES_RUN_SCRIPT			7
#define ES_INIT_SOCK			8
#define ES_INIT_PPP				9
#define ES_LINK_PPP				10
#define ES_INIT_SLIP			11
#define ES_DONE						12
#define ES_BREAK					13

/* Command to script-stepper */
#define STEP_NEW		0
#define STEP_CONT		1

/* Results of script-stepper */
#define STEP_AGAIN		0
#define STEP_COMPLETE	1
#define STEP_RETRY		2
#define STEP_CANCEL		3

/* PPP Events to start up */
#define PEV_LOW_UP			0		/* Lower Level is up */
#define PEV_LOW_DOWN		1		/* Lower Level is down */
#define PEV_ADMIN_OPEN	2		/* Administrative Open */
#define PEV_ADMIN_CLOSE	3		/* Administrative Close */
