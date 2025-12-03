#define FALSE	0
#define TRUE	1

#define PKTCOOKIE	0x5f504b54L			/* "_PKT" */

#define ET_IP	0x800
#define ET_ARP	0x806
#define ET_RARP	0x8035


#define NETRESET		0
#define NETOPEN			1
#define NETRELEASE		2
#define NETSEND			3
#define NETGETADR		4
#define NETINFO			5
#define NETPKTALLOC		6
#define NETPKTFREE		7
#define NETCONFIG		8

/*---------------------------------------------------------------*/
/* Fehlermeldungen                                               */
/*---------------------------------------------------------------*/
#define EPROTAVAIL		-1
#define EPROTUSED		-2     /* Protokoll wird bereits benutzt */
#define EHANDLE			-3
#define EPROTBUSY		-4     /* Protokoll im Gebrauch          */
#define EINIT			-5     /* Fehler beim Initialisieren     */
#define EPARAM			-6     /* unzulaessige Parameter         */
#define EPKTLEN			-7     /* ungueltige Paketlaenge         */
#define ECOLLISION		-8     /* Kollision festgestellt         */
#define ETIMEOUT		-9     /* Timeout beim warten auf Pakete */

#define MAXPROTOCOLS	4      /* Anzahl installierbarer Protok. */
#define ET_UNUSED		0
#define ET_FREE			-1

#define MAXPKT			30     /* Anzahl Pakete im Ringpuffer    */

/*---------------------------------------------------------------*/
/* Typen                                                         */
/*---------------------------------------------------------------*/
typedef int (*procref)();
typedef int HANDLE;
typedef int(*pkt_hndl)(int,char *); /* type of upcall function */

typedef struct
{
	long	st_sent;
	long	st_xmiterr;
	long	st_collision;
	long	st_got;
	long	st_received;
	long	st_missed;
	long	st_crc;
	int		st_err;
	int		st_free;
	long	st_intr;
    long    st_magic;    /* hier steht 0x12344321, wenn das naechste Feld gueltig ist */
    long    st_type;     /* Art der Schnittstelle (1=SLIP) */
} et_stat;

typedef struct
{
	unsigned int type;
	int (*handler)(int,lan_buffer_typ *);
	unsigned int recvd;
	unsigned int sent;
} PROTOCOL;

/*---------------------------------------------------------------*/
/* Prototypen                                                    */
/*---------------------------------------------------------------*/
int net_info(int, et_stat *);
int net_open(int, int (*)(int,lan_buffer_typ *));
int net_release(int);
int net_send(int, lan_buffer_typ *);
int	net_getadr(int,unsigned char *);
int net_reset(void);
lan_buffer_typ *net_pktalloc(unsigned short);
int net_pktfree(lan_buffer_typ *);
int net_config(int);

int net_init(void);
