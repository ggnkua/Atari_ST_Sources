/*
 *      drivers.h           (c) Steve Adam   1995
 *                              steve@netinfo.com.au
 *                   Support by Dan Ackerman 1996
 *                              ackerman.29@postbox.acs.ohio-state.edu
 *
 *      Data types etc. for access to STiK TCP/IP drivers.
 */

#ifndef STIK_DRIVERS_H
#define STIK_DRIVERS_H


/*--------------------------------------------------------------------------*/

/*
 * Data types used throughout STiK
 */
typedef          char  int8;
typedef unsigned char uint8;
typedef          int   int16;
typedef unsigned int  uint16;
typedef          long  int32;
typedef unsigned long uint32;

#ifndef TRUE
#define TRUE    1
#endif
#ifndef FALSE
#define FALSE   0
#endif

#define MAX_STATES    12         /* Was 16, must be > 2 and < 256           */
#define MAX_HDR      128         /* XXX 4bsd-ism : should really be 128     */

/*
 * The minimum IP header
 */
typedef struct ip_header {
    unsigned ver : 4;         /*  Version                                   */
    unsigned ihl : 4;         /*  Internet Header Length                    */
    unsigned tos : 8;         /*  Type of Service                           */
    int16  len;               /*  Total length, 16 bits                     */
    uint16  id;               /*  Identification, 16 bits                   */
    int16  ofst;              /*  Fragment offset, 16 bits, includes Flags  */
    uint8   ttl;              /*  Time to live, 8 bits                      */
    uint8   ptcl;             /*  Protocol, 8 bits                          */
    uint16  sum;              /*  Header checksum, 16 bits                  */
    uint32  s_ip;             /*  Source Address, 32 bits                   */
    uint32  d_ip;             /*  Destination Address, 32 bits              */
 /* char optlen;                  Length of options field, in bytes         */
 /* char options[IP_MAXOPT];      Options field                             */
} IP_HDR;


/*--------------------------------------------------------------------------*/

/*
 * STIK global configuration structure
 */
typedef struct config {
    uint32  client_ip;          /* IP address of client (local) machine     */
    uint32  provider;           /* IP address of provider, or 0L            */
    uint16  ttl;                /* Default TTL for normal packets           */
    uint16  ping_ttl;           /* Default TTL for 'ping'ing                */
    uint16  mtu;                /* Default MTU (Maximum Transmission Unit)  */
    uint16  mss;                /* Default MSS (Maximum Segment Size)       */
    uint16  df_bufsize;         /* Size of defragmentation buffer to use    */
    uint16  rcv_window;         /* TCP receive window                       */
    uint16  def_rtt;            /* Initial RTT time in ms                   */
    int16   time_wait_time;     /* How long to wait in 'TIME_WAIT' state    */
    int16   unreach_resp;       /* Response to unreachable local ports      */
    int32   cn_time;            /* Time connection was made                 */
    int16   cd_valid;           /* Is Modem CD a valid signal ??            */
    int16   line_protocol;      /* What type of connection is this          */
    void    (*old_vec)(void);   /* Old vector address                       */
    struct  slip *slp;          /* Slip structure for happiness             */
    char    *cv[101];           /* Space for extra config variables         */
    int16   reports;            /* Problem reports printed to screen ??     */
    int16   max_num_ports;      /* Maximum number of ports supported        */
    uint32  received_data;      /* Counter for data being received          */
    uint32  sent_data;          /* Counter for data being sent              */
} CONFIG;


/*--------------------------------------------------------------------------*/

/*
 * Driver access structure / functions
 */
#define MAGIC   "STiKmagic"
#define CJTAG   "STiK"

typedef struct drv_header {                 /* Header part of TPL structure */
    char *module;
    char *author;
    char *version;
} DRV_HDR;

typedef struct drv_list {
    char      magic[10];                    /* Magic string, def'd as MAGIC */
    DRV_HDR * cdecl (*get_dftab) (char *);  /* Get Driver Function Table    */
    int16     cdecl (*ETM_exec) (char *);   /* Execute a STiK module        */
    CONFIG    *cfg;
} DRV_LIST;

extern DRV_LIST *drivers;

#define get_dftab(x)    (*drivers->get_dftab)(x)
#define ETM_exec(x)     (*drivers->ETM_exec)(x)
#define stik_cfg        (drivers->cfg)


/*--------------------------------------------------------------------------*/

/*
 * "state" data for each active tcp conversation on the wire.
 */
struct cstate {
     struct cstate   *cs_next;       /* Next mru cstate (transmit only)     */
     unsigned short  cs_hlen;        /* Size of header (receive only)       */
     unsigned char   cs_id;          /* Con. no. associated with this state */
     unsigned char   cs_filler;
     union {
          char             csu_hdr[MAX_HDR];
          struct ip_header csu_ip;   /* Header from most recent packet      */
     } slcs_u;
};

#define cs_ip   slcs_u.csu_ip
#define cs_hdr  slcs_u.csu_hdr

/*
 * Serial line state - we need one per line 
 */
typedef struct slcompress {
     struct cstate  *last_cs;                /* Most recently used tstate   */
     uint8          last_recv;               /* Last received connection id */
     uint8          last_xmit;               /* Last sent connection id     */
     uint8          flags;
     struct cstate  *tstate[MAX_STATES];     /* Transmit connection states  */
     struct cstate  *rstate[MAX_STATES];     /* Receive connection states   */
};

typedef struct slip {
     void   *bdev;      /* Backlink to interface, cast this to (DEV_LIST *) */
     short  flags;                    /* Misc flags, meaning see below      */
     struct slcompress *comp;         /* States for VJ compression          */
};

/*
 * Bit masks for 'flags' entry in 'struct slip'
 */
#define SLF_ESC        0x01      /* Next char is escaped                    */
#define SLF_DROP       0x02      /* Drop this packet                        */
#define SLF_LINKED     0x04      /* Interface is linked to device           */
#define SLF_COMPRESS   0x08      /* Turn on VJ compression                  */
#define SLF_AUTOCOMP   0x10      /* Enable comp. on TCP_UNCOMP. frame       */
#define SLF_COMPCID    0x20      /* Enable CID compression                  */
#define SLF_USRMASK    (SLF_COMPRESS|SLF_AUTOCOMP|SLF_COMPCID)


/*--------------------------------------------------------------------------*/

#endif /* STIK_DRIVERS_H */
