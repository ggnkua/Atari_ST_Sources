#ifndef _INET_IPCUST
#define _INET_IPCUST



#define INETCUSTCOOKIE   0x49435354L		/* "ICST" */

#define MAXUSERNAME		16
#define MAXNAME			64
#define MAXHOSTNAME		16

typedef unsigned long INADDR;
typedef char HADDR[6];

typedef struct
{
	long	magic;				/* magic to identify version */
	HADDR	haddr;				/* my ethernet address 		 */
	INADDR	inaddr;				/* my internet address       */
	short	subnetbits;			/* number of subnet bits	 */
	short	tcpwnd;				/* default tcp window size   */
	short	tcplowater;
	long	netmem;				/* size of mem to hold buffers */
	char	username[MAXUSERNAME];
	char	hosts[64];			/* path to hosttable		 */
	char	passwd[64];			/* path to passwdfile		 */
	short	gmtoffs;			/* time zone offset 		 */
	char	tzname[6];			/* timezone name			 */
	INADDR	timeserver[2];		/* ip adr of 2 timeservers   */ 
	INADDR	nameserver[3];		/* ip adr of 3 nameservers   */
	INADDR	gateway;			/* ip adr of gateway		 */
	char	hostname[MAXHOSTNAME];			/* name of this host */
	char	domainname[MAXNAME];/* domainname of this host */
	char	mailhost[MAXNAME];	/* mailhost name */
	char	loginhost[MAXNAME];	/* default host */
	char	printhost[MAXNAME];	/* printserver */
	char	printdev[MAXHOSTNAME];			/* printer device */
	
} INETCUST;



#endif