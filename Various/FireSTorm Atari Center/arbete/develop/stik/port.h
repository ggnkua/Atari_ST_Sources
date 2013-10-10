/*
 *      port.h              (c) Peter Rottengatter  1996
 *                              perot@pallas.amp.uni-hannover.de
 *
 *      Include this file to provide port interfacing to STiK
 */

#ifndef STIK_PORT_H
#define STIK_PORT_H

#ifndef MODULE_DRIVER
#define MODULE_DRIVER    "MODULE_LAYER"
#endif



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
 *   Port driver descriptor.
 */

typedef  struct drv_desc {
    int16 cdecl  (* set_state) (PORT *, int16);  /* Setup and shutdown port */
    void  cdecl  (* send) (PORT *);              /* Send pending packets    */
    void  cdecl  (* receive) (PORT *);           /* Receive pending packets */
    char             *name;     /* Name of driver                           */
    char             *version;  /* Version of driver in "xx.yy" format      */
    uint16           date;      /* Compile date in GEMDOS format            */
    char             *author;   /* Name of programmer                       */
    struct drv_desc  *next;     /* Next driver in driver chain              */
 } DRIVER;



/*--------------------------------------------------------------------------*/


/*
 *   Link Type Definitions
 */

#define  L_SER_PTP    1           /*   Serial point to point type link      */
#define  L_PAR_PTP    2           /* Parallel point to point type link      */
#define  L_SER_BUS    3           /*   Serial            bus type link      */
#define  L_PAR_BUS    4           /* Parallel            bus type link      */
#define  L_SER_RING   5           /*   Serial           ring type link      */
#define  L_PAR_RING   6           /* Parallel           ring type link      */



/*--------------------------------------------------------------------------*/


/*
 *   Module driver structure / functions
 */

#ifndef MOD_DRIVER
#define MOD_DRIVER

typedef  struct stx {
    char *     module;      /* Specific string that can be searched for     */
    char *     author;      /* Any string                                   */
    char *     version;     /* Format `00.00' Version:Revision              */
    void       cdecl  (* set_dgram_ttl) (IP_DGRAM *);
    int16      cdecl  (* check_dgram_ttl) (IP_DGRAM *);
    int16      cdecl  (* load_routing_table) (void);
    int32      cdecl  (* set_sysvars) (int16, int16);
    void       cdecl  (* query_chains) (void **, void **, void **);
    int16      cdecl  (* IP_send) (uint32, uint32, uint8, uint16, uint8, uint8, uint16,
                                   void *, uint16, void *, uint16);
    IP_DGRAM * cdecl  (* IP_fetch) (int16);
    int16      cdecl  (* IP_handler) (int16, int16 cdecl (*) (IP_DGRAM *), int16);
    void       cdecl  (* IP_discard) (IP_DGRAM *, int16);
    int16      cdecl  (* PRTCL_announce) (int16);
    int16      cdecl  (* PRTCL_get_parameters) (uint32, uint32 *, int16 *);
    int16      cdecl  (* PRTCL_request) (void *);
    void       cdecl  (* PRTCL_release) (int16);
 } STX;

extern STX *stx;


/*
 *   Definitions of module driver functions for direct use
 */

#define set_dgram_ttl(x)                 (*stx->set_dgram_ttl)(x)
#define check_dgram_ttl(x)               (*stx->check_dgram_ttl)(x)
#define load_routing_table()             (*stx->load_routing_table)()
#define set_sysvars(x,y)                 (*stx->set_sysvars)(x,y)
#define query_chains(x,y,z)              (*stx->query_chains)(x,y,z)
#define IP_send(a,b,c,d,e,f,g,h,i,j,k)   (*stx->IP_send)(a,b,c,d,e,f,g,h,i,j,k)
#define IP_fetch(x)                      (*stx->IP_fetch)(x)
#define IP_handler(x,y,z)                (*stx->IP_handler)(x,y,z)
#define IP_discard(x,y)                  (*stx->IP_discard)(x,y)
#define PRTCL_announce(x)                (*stx->PRTCL_announce)(x)
#define PRTCL_get_parameters(x,y,z)      (*stx->PRTCL_get_parameters)(x,y,z)
#define PRTCL_request(x)                 (*stx->PRTCL_request)(x)
#define PRTCL_release(x)                 (*stx->PRTCL_release)(x)

#endif /* MOD_DRIVER */



/*--------------------------------------------------------------------------*/


#endif /* STIK_PORT_H */
