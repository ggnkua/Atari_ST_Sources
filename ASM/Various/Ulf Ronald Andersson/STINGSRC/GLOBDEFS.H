/*
 *      globdefs.h          (c) Peter Rottengatter  1996
 *                              perot@pallas.amp.uni-hannover.de
 *
 *      Included into all STinG source code files
 */



#define  FALSE       0
#define  TRUE        1

#define  TCP_DRIVER_VERSION    "01.20"
#define  STX_LAYER_VERSION     "01.05"
#define  CFG_NUM               100
#define  MAX_HANDLE            32
#define  LOOPBACK              0x7f000001L


#pragma warn -par



/*--------------------------------------------------------------------------*/


/*
 *   Protocols.
 */

#define  ICMP        1        /* IP assigned number for ICMP                */
#define  TCP         6        /* IP assigned number for TCP                 */
#define  UDP        17        /* IP assigned number for UDP                 */


/*
 *   A concession to portability ...
 */

typedef           char   int8;        /*   Signed  8 bit (char)             */
typedef  unsigned char  uint8;        /* Unsigned  8 bit (byte, octet)      */
typedef           int    int16;       /*   Signed 16 bit (int)              */
typedef  unsigned int   uint16;       /* Unsigned 16 bit (word)             */
typedef           long   int32;       /*   Signed 32 bit                    */
typedef  unsigned long  uint32;       /* Unsigned 32 bit (longword)         */



/*--------------------------------------------------------------------------*/


/*
 *   Network Data Block.  For data delivery.
 */

typedef  struct ndb {
    char        *ptr;       /* Pointer to base of block. (For free() ;-)    */
    char        *ndata;     /* Pointer to next data to deliver              */
    uint16      len;        /* Length of remaining data.                    */
    struct ndb  *next;      /* Next NDB in chain or NULL                    */
 } NDB;


/*
 *   Addressing information block.
 */

typedef  struct cab {
    uint16      lport;      /* Local  port        (ie: local machine)       */
    uint16      rport;      /* Remote port        (ie: remote machine)      */
    uint32      rhost;      /* Remote IP address  (ie: remote machine)      */
    uint32      lhost;      /* Local  IP address  (ie: local machine)       */
 } CAB;


/*
 *   Connection information block.
 */

typedef  struct cib {
    uint16      protocol;   /* TCP or UDP or ... 0 means CIB is not in use  */
    CAB         address;    /* Adress information                           */
    uint16      status;     /* Net status. 0 means normal                   */
 } CIB;



/*--------------------------------------------------------------------------*/


/*
 *   IP packet header.
 */

typedef  struct ip_header {
    unsigned  version   : 4;    /* IP Version                               */
    unsigned  hd_len    : 4;    /* Internet Header Length                   */
    unsigned  tos       : 8;    /* Type of Service                          */
    uint16    length;           /* Total of all header, options and data    */
    uint16    ident;            /* Identification for fragmentation         */
    unsigned  reserved  : 1;    /* Reserved : Must be zero                  */
    unsigned  dont_frg  : 1;    /* Don't fragment flag                      */
    unsigned  more_frg  : 1;    /* More fragments flag                      */
    unsigned  frag_ofst : 13;   /* Fragment offset                          */
    uint8     ttl;              /* Time to live                             */
    uint8     protocol;         /* Protocol                                 */
    uint16    hdr_chksum;       /* Header checksum                          */
    uint32    ip_src;           /* Source IP address                        */
    uint32    ip_dest;          /* Destination IP address                   */
 } IP_HDR;


/*
 *   Internal IP packet representation.
 */

typedef  struct ip_packet {
    IP_HDR    hdr;              /* Header of IP packet                      */
    void      *options;         /* Options data block                       */
    int16     opt_length;       /* Length of options data block             */
    void      *pkt_data;        /* IP packet data block                     */
    int16     pkt_length;       /* Length of IP packet data block           */
    uint32    timeout;          /* Timeout of packet life                   */
    uint32    ip_gateway;       /* Gateway for forwarding this packet       */
    struct port_desc  *recvd;   /* Receiving port                           */
    struct ip_packet  *next;    /* Next IP packet in IP packet queue        */
 } IP_DGRAM;


/*
 *   Defragmentation queue entries.
 */

typedef  struct defrag_rsc {
    IP_DGRAM  *dgram;           /* Datagram to be reassembled               */
    uint16    ttl_data;         /* Total data length for defragmentation    */
    uint16    act_space;        /* Current space of reassembly buffer       */
    void      *blk_bits;        /* Fragment block bits table                */
    struct defrag_rsc  *next;   /* Next defrag resources in defrag queue    */
 } DEFRAG;


/*
 *   Protocol array entry for received data.
 */

typedef  struct protocol_entry {
    int16     active;           /* Protocol is installed                    */
    IP_DGRAM  *queue;           /* Link to first entry in received queue    */
    DEFRAG    *defrag;          /* Link to defragmentation queue            */
    int16  cdecl  (* process) (IP_DGRAM *);   /* Call to process packet     */
 } IP_PRTCL;



/*--------------------------------------------------------------------------*/


/*
 *   Internal port descriptor.
 */

typedef  struct port_desc {
    char      *name;            /* Name of port                             */
    int16     type;             /* Type of port                             */
    int16     active;           /* Flag for port active or not              */
    uint32    flags;            /* Type dependent operational flags         */
    uint32    ip_addr;          /* IP address of this network adapter       */
    uint32    sub_mask;         /* Subnet mask of attached network          */
    int16     mtu;              /* Maximum packet size to go through        */
    int16     max_mtu;          /* Maximum allowed value for mtu            */
    int32     stat_sd_data;     /* Statistics of sent data                  */
    IP_DGRAM  *send;            /* Link to first entry in send queue        */
    int32     stat_rcv_data;    /* Statistics of received data              */
    IP_DGRAM  *receive;         /* Link to first entry in receive queue     */
    int16     stat_dropped;     /* Statistics of dropped datagrams          */
    struct drv_desc   *driver;  /* Driver program to handle this port       */
    struct port_desc  *next;    /* Next port in port chain                  */
 } PORT;


/*
 *   Link Type Definitions.
 */

#define  L_INTERNAL   0           /* Internal pseudo port                   */
#define  L_SER_PTP    1           /*   Serial point to point type link      */
#define  L_PAR_PTP    2           /* Parallel point to point type link      */
#define  L_SER_BUS    3           /*   Serial            bus type link      */
#define  L_PAR_BUS    4           /* Parallel            bus type link      */
#define  L_SER_RING   5           /*   Serial           ring type link      */
#define  L_PAR_RING   6           /* Parallel           ring type link      */
#define  L_MASQUE     7           /*   Masquerading pseudo port             */


/*
 *   Port driver descriptor.
 */

typedef  struct drv_desc {
    int16 cdecl  (* set_state) (PORT *, int16);       /* Setup and shutdown */
    int16 cdecl  (* cntrl) (PORT *, uint32, int16);   /* Control functions  */
    void  cdecl  (* send) (PORT *);                   /* Send packets       */
    void  cdecl  (* receive) (PORT *);                /* Receive packets    */
    char             *name;     /* Name of driver                           */
    char             *version;  /* Version of driver in "xx.yy" format      */
    uint16           date;      /* Compile date in GEMDOS format            */
    char             *author;   /* Name of programmer                       */
    struct drv_desc  *next;     /* Next driver in driver chain              */
    BASPAG           *basepage; /* Basepage of this module                  */
 } DRIVER;



/*--------------------------------------------------------------------------*/


/*
 *   High level protocol module descriptor.
 */

typedef  struct lay_desc {
    char             *name;          /* Name of layer                       */
    char             *version;       /* Version of layer in xx.yy format    */
    uint32           flags;          /* Private data                        */
    uint16           date;           /* Compile date in GEMDOS format       */
    char             *author;        /* Name of programmer                  */
    int16            stat_dropped;   /* Statistics of dropped data units    */
    struct lay_desc  *next;          /* Next layer in driver chain          */
    BASPAG           *basepage;      /* Basepage of this module             */
 } LAYER;



/*--------------------------------------------------------------------------*/


/*
 *   Entry definition for function chain.
 */

typedef  struct func_list {
    int16    cdecl    (* handler) (IP_DGRAM *);
    struct func_list  *next;
 } FUNC_LIST;



/*--------------------------------------------------------------------------*/


/*
 *   CN functions structure for TCP and UDP.
 */

typedef  struct cn_funcs {
    int16  cdecl  (* CNkick) (void *);
    int16  cdecl  (* CNbyte_count) (void *);
    int16  cdecl  (* CNget_char) (void *);
    NDB *  cdecl  (* CNget_NDB) (void *);
    int16  cdecl  (* CNget_block) (void *, void *, int16);
    CIB *  cdecl  (* CNgetinfo) (void *);
    int16  cdecl  (* CNgets) (void *, char *, int16, char);
 } CN_FUNCS;



/*--------------------------------------------------------------------------*/


/*
 *   STinG global configuration structure.
 */

typedef  struct config {
    uint32     client_ip;       /* IP address of local machine (obsolete)   */
    uint16     ttl;             /* Default TTL for normal packets           */
    char       *cv[CFG_NUM+1];  /* Space for config variables               */
    int16      max_num_ports;   /* Maximum number of ports supported        */
    uint32     received_data;   /* Counter for data being received          */
    uint32     sent_data;       /* Counter for data being sent              */
    int16      active;          /* Flag for polling being active            */
    int16      thread_rate;     /* Time between subsequent thread calls     */
    int16      frag_ttl;        /* Time To Live for reassembly resources    */
    PORT       *ports;          /* Pointer to first entry in PORT chain     */
    DRIVER     *drivers;        /* Pointer to first entry in DRIVER chain   */
    LAYER      *layers;         /* Pointer to first entry in LAYER chain    */
    FUNC_LIST  *interupt;       /* List of application interupt handlers    */    
    FUNC_LIST  *icmp;           /* List of application ICMP handlers        */    
    int32      stat_all;        /* All datagrams that pass are counted here */
    int32      stat_lo_mem;     /* Dropped due to low memory                */
    int32      stat_ttl_excd;   /* Dropped due to Time-To-Live exceeded     */
    int32      stat_chksum;     /* Dropped due to failed checksum test      */
    int32      stat_unreach;    /* Dropped due to no way to deliver it      */
    void       *memory;         /* Pointer to main memory for KRcalls       */
    int16      new_cookie;      /* Flag indicating if new jar was created   */
 } CONFIG;



/*--------------------------------------------------------------------------*/


/*
 *   Entry for routing table.
 */

typedef  struct route_entry {
    uint32  template;           /* Net to be reached this way               */
    uint32  netmask;            /* Corresponding subnet mask                */
    uint32  ip_gateway;         /* Next gateway on the way to dest. host    */
    PORT    *port;              /* Port to route the datagram to            */
 } ROUTE_ENTRY;


/*
 *   Router return values.
 */

#define  NET_UNREACH     ((void *)  0L)    /* No entry for IP found         */
#define  HOST_UNREACH    ((void *) -1L)    /* Entry found but port inactive */
#define  NO_NETWORK      ((void *) -6L)    /* Routing table empty           */
#define  NO_HOST         ((void *) -7L)    /* Currently unused              */



/*--------------------------------------------------------------------------*/


/*
 *   ICMP types.
 */

#define  ICMP_ECHO_REPLY      0       /* Response to echo request           */
#define  ICMP_DEST_UNREACH    3       /* IP error : Destination unreachable */
#define  ICMP_SRC_QUENCH      4       /* IP error : Source quench           */
#define  ICMP_REDIRECT        5       /* IP hint : Redirect datagrams       */
#define  ICMP_ECHO            8       /* Echo requested                     */
#define  ICMP_ROUTER_AD       9       /* Router advertisement               */
#define  ICMP_ROUTER_SOL      10      /* Router solicitation                */
#define  ICMP_TIME_EXCEED     11      /* Datagram TTL exceeded, discarded   */
#define  ICMP_PARAMETER       12      /* IP error : Parameter problem       */
#define  ICMP_STAMP_REQU      13      /* Timestamp requested                */
#define  ICMP_STAMP_REPLY     14      /* Response to timestamp request      */
#define  ICMP_INFO_REQU       15      /* Information requested (obsolete)   */
#define  ICMP_INFO_REPLY      16      /* Response to info req. (obsolete)   */
#define  ICMP_MASK_REQU       17      /* Subnet mask requested              */
#define  ICMP_MASK_REPLY      18      /* Response to subnet mask request    */



/*--------------------------------------------------------------------------*/


/*
 *   Handler flag values.
 */

#define  HNDLR_SET        0         /* Set new handler if space             */
#define  HNDLR_FORCE      1         /* Force new handler to be set          */
#define  HNDLR_REMOVE     2         /* Remove handler entry                 */
#define  HNDLR_QUERY      3         /* Inquire about handler entry          */



/*--------------------------------------------------------------------------*/


/*
 *   Buffer for inquiring port names.
 */

typedef  struct pnta {
    PORT    *opaque;            /* PORT for current name                    */
    int16   name_len;           /* Length of port name buffer               */
    char    *port_name;         /* Buffer address                           */
 } PNTA;


#define  CTL_KERN_FIRST_PORT    ('K' << 8 | 'F')    /* Query first port     */
#define  CTL_KERN_NEXT_PORT     ('K' << 8 | 'N')    /* Query following port */
#define  CTL_KERN_FIND_PORT     ('K' << 8 | 'G')    /* Port struct. address */



/*--------------------------------------------------------------------------*/


/*
 *   Other cntrl_port() opcodes.
 */

#define  CTL_GENERIC_SET_IP     ('G' << 8 | 'H')    /* Set IP address       */
#define  CTL_GENERIC_GET_IP     ('G' << 8 | 'I')    /* Get IP address       */
#define  CTL_GENERIC_SET_MASK   ('G' << 8 | 'L')    /* Set subnet mask      */
#define  CTL_GENERIC_GET_MASK   ('G' << 8 | 'M')    /* Get subnet mask      */
#define  CTL_GENERIC_SET_MTU    ('G' << 8 | 'N')    /* Set line MTU         */
#define  CTL_GENERIC_GET_MTU    ('G' << 8 | 'O')    /* Get line MTU         */
#define  CTL_GENERIC_GET_MMTU   ('G' << 8 | 'P')    /* Get maximum MTU      */
#define  CTL_GENERIC_GET_TYPE   ('G' << 8 | 'T')    /* Get port type        */
#define  CTL_GENERIC_GET_STAT   ('G' << 8 | 'S')    /* Get statistics       */
#define  CTL_GENERIC_CLR_STAT   ('G' << 8 | 'C')    /* Clear statistics     */



/*--------------------------------------------------------------------------*/


/*
 *   Miscellaneous Definitions.
 */

#define  MAX_CLOCK    86400000L      /* Maximum value for sting_clock       */



/*--------------------------------------------------------------------------*/


/*
 *   Error return values.
 */

#define  E_NORMAL         0     /* No error occured ...                     */
#define  E_OBUFFULL      -1     /* Output buffer is full                    */
#define  E_NODATA        -2     /* No data available                        */
#define  E_EOF           -3     /* EOF from remote                          */
#define  E_RRESET        -4     /* Reset received from remote               */
#define  E_UA            -5     /* Unacceptable packet received, reset      */
#define  E_NOMEM         -6     /* Something failed due to lack of memory   */
#define  E_REFUSE        -7     /* Connection refused by remote             */
#define  E_BADSYN        -8     /* A SYN was received in the window         */
#define  E_BADHANDLE     -9     /* Bad connection handle used.              */
#define  E_LISTEN        -10    /* The connection is in LISTEN state        */
#define  E_NOCCB         -11    /* No free CCB's available                  */
#define  E_NOCONNECTION  -12    /* No connection matches this packet (TCP)  */
#define  E_CONNECTFAIL   -13    /* Failure to connect to remote port (TCP)  */
#define  E_BADCLOSE      -14    /* Invalid TCP_close() requested            */
#define  E_USERTIMEOUT   -15    /* A user function timed out                */
#define  E_CNTIMEOUT     -16    /* A connection timed out                   */
#define  E_CANTRESOLVE   -17    /* Can't resolve the hostname               */
#define  E_BADDNAME      -18    /* Domain name or dotted dec. bad format    */
#define  E_LOSTCARRIER   -19    /* The modem disconnected                   */
#define  E_NOHOSTNAME    -20    /* Hostname does not exist                  */
#define  E_DNSWORKLIMIT  -21    /* Resolver Work limit reached              */
#define  E_NONAMESERVER  -22    /* No nameservers could be found for query  */
#define  E_DNSBADFORMAT  -23    /* Bad format of DS query                   */
#define  E_UNREACHABLE   -24    /* Destination unreachable                  */
#define  E_DNSNOADDR     -25    /* No address records exist for host        */
#define  E_NOROUTINE     -26    /* Routine unavailable                      */
#define  E_LOCKED        -27    /* Locked by another application            */
#define  E_FRAGMENT      -28    /* Error during fragmentation               */
#define  E_TTLEXCEED     -29    /* Time To Live of an IP packet exceeded    */
#define  E_PARAMETER     -30    /* Problem with a parameter                 */
#define  E_BIGBUF        -31    /* Input buffer is too small for data       */
#define  E_FNAVAIL       -32    /* Function not available                   */
#define  E_LASTERROR      32    /* ABS of last error code in this list      */



/*--------------------------------------------------------------------------*/

