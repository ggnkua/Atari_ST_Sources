/*      transprt.h        (c) Steve Adam 1995   steve@netinfo.com.au
 *
 *      Include this file to use functions from the tcp module.
 *      ie: tcp/udp, etc....
 */

#ifndef STIK_TRANSPRT_H
#define STIK_TRANSPRT_H

#ifndef   STIK_DRIVERS_H
#include  "drivers.h"
#endif /* STIK_DRIVERS_H */

#define TRANSPORT_DRIVER    "TRANSPORT_TCPIP"
#define TCP_DRIVER_VERSION	"01.05"

/* TCP connection states    */
#define TCLOSED     0   /* No connection.  Null, void, absent, .....        */
#define TLISTEN     1   /* Wait for remote request.  Not used here.         */
#define TSYN_SENT   2   /* Connect request sent.  Await matching request    */
#define TSYN_RECV   3   /* Wait for connection ACK.  (Listener only??)      */
#define TESTABLISH  4   /* Connection is established.  Handshake completed  */
#define TFIN_WAIT1  5   /* Await termination request or acknowledgement     */
#define TFIN_WAIT2  6   /* Await termination request.                       */
#define TCLOSE_WAIT 7   /* Await termination request from local user        */
#define TCLOSING    8   /* Await termination acknowledge from remote TCP    */
#define TLAST_ACK   9   /* Await acknowledgement of terminate request sent  */
#define TTIME_WAIT 10   /* Delay to ensure remote has received term' ACK    */

/* TCP and connection ERROR states. */
#define E_NORMAL        0   /* No error occured...                      */
#define E_OBUFFULL     -1   /* Output buffer is full                    */
#define E_NODATA       -2   /* No data available.                       */
#define E_EOF          -3   /* EOF from remote..						*/
#define E_RRESET       -4   /* RST received from remote.                */
#define E_UA           -5   /* RST.  Other end sent unacceptable pkt    */
#define E_NOMEM        -6   /* Something failed due to lack of memory   */
#define E_REFUSE       -7   /* Connection refused by remote             */
#define E_BADSYN       -8   /* A SYN was received in the window         */
#define E_BADHANDLE    -9   /* Bad connection handle used.              */
#define E_CLOSED       -10  /* The connection is closed (EOF)           */
#define E_NOCCB        -11  /* No free CCB's available                  */
#define E_NOCONNECTION -12  /* No connection matches this packet. (TCP) */
#define E_CONNECTFAIL  -13  /* Failure to connect to remote port. (TCP) */
#define E_BADCLOSE     -14  /* Invalid TCP_close() requested            */
#define E_USERTIMEOUT  -15  /* A user function timed out                */
#define E_CNTIMEOUT    -16  /* A the connection timed out               */
#define E_CANTRESOLVE  -17  /* Can't resolve the hostname               */
#define E_BADDNAME     -18  /* Domain name or Dotted Dec.  bad format   */
#define E_LOSTCARRIER  -19  /* The modem disconnected                   */
#define E_NOHOSTNAME   -20  /* Hostname does not exist                  */
#define E_DNSWORKLIMIT -21  /* Resolver Work limit reached              */
#define E_NONAMESERVER -22  /* No nameservers could be found for query  */
#define E_DNSBADFORMAT -23  /* Bad format of DS query                   */
#define E_UNREACHABLE  -24  /* Destination unreachable                  */
#define E_DNSNOADDR    -25  /* No address records exist for host        */
#define E_LASTERROR     25	/* ABS of last error code in this list      */

/* FLagbox Flag definitions	(max 64 flags...) */
#define FL_do_resolve	0
#define FL_housekeep	1


/* Input queue structures   */

typedef struct ndb {    /*  Network Data Block.  For data delivery      */
    char        *ptr;   /* Pointer to base of block. (For KRfree();)    */
    char        *ndata; /* Pointer to next data to deliver              */
    uint16      len;    /* Length of remaining data.                    */
    struct ndb  *next;  /* Next NDB in chain or NULL                    */
} NDB;


/*  Transport structure/functions   */

typedef struct tpl {
    char    *module;    /* specific string that can be searched for */
    char    *author;    /* Any string                               */
    char    *version;   /* Format `00.00' Version:Revision          */
    char  * cdecl (*KRmalloc)(int32);
    void    cdecl (*KRfree)(char *);
    int32   cdecl (*KRgetfree)(int16 x);
    char  * cdecl (*KRrealloc)(char *, int32);
    char  * cdecl (*get_err_text)(int16);
    char  * cdecl (*getvstr)(char *);
    int16   cdecl (*carrier_detect)(void);
    int16   cdecl (*TCP_open)(uint32, int16, int16, uint16);
    int16   cdecl (*TCP_close)(int16, int16);
    int16   cdecl (*TCP_send)(int16, char *, int16);
    int16   cdecl (*TCP_wait_state)(int16, int16, int16);
    int16   cdecl (*TCP_ack_wait)(int16, int16);
    int16   cdecl (*UDP_open)(uint32, int16);
    int16   cdecl (*UDP_close)(int16);
    int16   cdecl (*UDP_send)(int16, char *, int16);
    int16   cdecl (*CNkick)(int16);
    int16   cdecl (*CNbyte_count)(int16);
    int16   cdecl (*CNget_char)(int16);
    NDB   * cdecl (*CNget_NDB)(int16);
    int16   cdecl (*CNget_block)(int16, char *, int16);
    void    cdecl (*housekeep)(void);
    int16   cdecl (*resolve)(char *, char **, uint32 *, int16);
    void    cdecl (*ser_disable)(void);
    void    cdecl (*ser_enable)(void);
    int16	cdecl (*set_flag)(int16);
    void	cdecl (*clear_flag)(int16);
    uint16  cdecl (*CNgetport)(int16);
} TPL;

extern TPL *tpl;

#define KRmalloc(x)             (*tpl->KRmalloc)(x)
#define KRfree(x)               (*tpl->KRfree)(x)		
#define KRgetfree(x)            (*tpl->KRgetfree)(x)
#define KRrealloc(x,y)          (*tpl->KRrealloc)(x,y)
#define get_err_text(x)         (*tpl->get_err_text)(x)
#define getvstr(x)              (*tpl->getvstr)(x)
#define carrier_detect()        (*tpl->carrier_detect)()
#define TCP_open(h,p,t,o)       (*tpl->TCP_open)(h,p,t,o)
#define TCP_close(x,y)          (*tpl->TCP_close)(x,y)
#define TCP_send(x,y,z)         (*tpl->TCP_send)(x,y,z)
#define TCP_wait_state(x,y,z)   (*tpl->TCP_wait_state)(x,y,z)
#define TCP_ack_wait(x,y)       (*tpl->TCP_ack_wait)(x,y)
#define UDP_open(x,y)           (*tpl->UDP_open)(x,y)
#define UDP_close(x)            (*tpl->UDP_close)(x)
#define UDP_send(x,y,z)         (*tpl->UDP_send)(x,y,z)
#define CNkick(x)               (*tpl->CNkick)(x)
#define CNbyte_count(x)         (*tpl->CNbyte_count)(x)
#define CNget_char(x)           (*tpl->CNget_char)(x)
#define CNget_NDB(x)            (*tpl->CNget_NDB)(x)
#define CNget_block(x,y,z)      (*tpl->CNget_block)(x,y,z)
#define housekeep()             (*tpl->housekeep)()
#define resolve(w,x,y,z)        (*tpl->resolve)(w,x,y,z)
#define ser_disable()           (*tpl->ser_disable)()
#define ser_enable()            (*tpl->ser_enable)()
#define set_flag(x)             (*tpl->set_flag)(x)
#define clear_flag(x)           (*tpl->clear_flag)(x)
#define CNgetport(x)            (*tpl->CNgetport)(x)

#endif /* STIK_TRANSPRT_H */
