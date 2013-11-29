/*      drivers.h        (c) Steve Adam 1995   steve@netinfo.com.au
 *
 *      Data types etc. for access to STiK TCP/IP drivers.
 */

#ifndef STIK_DRIVERS_H
#define STIK_DRIVERS_H

/*  Data types used throughout STiK  */

typedef int int16;
typedef unsigned int uint16;
typedef long int32;
typedef unsigned long uint32;

#ifndef TRUE
#define TRUE    1
#endif
#ifndef FALSE
#define FALSE   0
#endif

/* STIK global configuration structure */
typedef struct config {
    uint32  client_ip;          /*  IP address of client (local) machine    */
    uint32  provider;           /*  IP address of provider, or 0L           */
    uint16  ttl;                /*  Default TTL for normal packets          */
    uint16  ping_ttl;           /*  Default TTL for `ping'ing               */
    uint16  mtu;                /*  Default MTU (Maximum Transmission Unit) */
    uint16  mss;                /*  Default MSS (Maximum Segment Size)      */
    uint16  in_packet_size;     /*  Max size of new inbound packets         */
    uint16  df_bufsize;         /*  Size of defragmentation buffer to use   */
    uint16  rcv_window;         /*  TCP receive window                      */
    uint16  def_rtt;            /*  Initial RTT time in ms                  */
    int16   time_wait_time;     /*  How long to wait in `TIME_WAIT' state   */
    int16   unreach_resp;       /*  Response to unreachable local ports     */
    int32   cn_time;            /*  Time connection was made                */
    int16   cd_valid;           /*  Is Modem CD a valid signal??            */
} CONFIG;


/* Driver access structure/functions	*/
#define MAGIC   "STiKmagic"
#define CJTAG   "STiK"

typedef struct drv_header {     /* ptr to header part of driver struct  */
    char *module;
    char *author;
    char *version;
} DRV_HDR;

typedef struct drv_list {
    char magic[10];                         /* Magic number.  To be decided */
    DRV_HDR * cdecl (*get_dftab)(char *);   /* Get Driver Function Table fn */
    int16     cdecl (*ETM_exec)(char *);    /* Execute a STiK module        */
    CONFIG    *cfg;
} DRV_LIST;

extern DRV_LIST *drivers;

#define get_dftab(x)    (*drivers->get_dftab)(x)
#define ETM_exec(x)     (*drivers->ETM_exec)(x)
#define stik_cfg        (drivers->cfg)


#endif   /* STIK_DRIVERS_H */
