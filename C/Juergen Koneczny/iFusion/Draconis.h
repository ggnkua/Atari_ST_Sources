#ifndef	DRACONIS_OPTIONS
#define	DRACONIS_OPTIONS
typedef struct options CFG_OPT;
struct options
{
	int32 dcfg;
	char provider[21];
	
	/* Connect options */
	char user[36];
	char password[36];
	char phone_no[21];
	char term_before;
	char term_after;
	
	/* Modem configuration */
	char modem_init[50];
	char modem_dial[50];
	char modem_hangup[50];
	char modem_cmdok[50];
	char modem_conmsg[50];
	char modem_fail1[50];
	char modem_fail2[50];
	
	/* RS232 settings */
	int16 port;
	int16 baud;
	int16 parity;
	int16 bits;
	int16 stopbits;
	
	/* Protocol options */
	int32 prot_cookie;
	int16  protocol;
	char ip_compression;
	char soft_compression;  
	
	/* Gateway options */
	uint32 nameserver1;
	uint32 nameserver2;
	uint32 target1, gateway1;
	uint32 target2, gateway2;
	uint32 target3, gateway3;
	uint32 std_gateway;
	int16 subnet1, subnet2, subnet3;
	char default_gw;
	
	/* TCP options */
	char ip_assign;
	uint32 ip;
	uint32 subnet;	   
	char host[21];
	char domain[21];
	
	/* Proxys */
	char http[41];
	char http_port[5];
	char ftp[41];
	char ftp_port[5];
	char gopher[41];
	char gopher_port[5];
	char secure[41];
	char secure_port[5];
	char exclude[3][47];
	
	/* Mail */
	char email[43];
	char email2[43];
	char mailpass[43];
	char popuser[43];
	char popserver[43];
	char smtpserver[43];
	
	int16  timeout;
	char netlogon, force_enc, tonline;	
};
#endif