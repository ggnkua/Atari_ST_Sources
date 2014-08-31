/*
 *      layer.h             (c) Peter Rottengatter  1996
 *                              perot@pallas.amp.uni-hannover.de
 *
 *      Include this file to provide high level protocol interfacing to STinG
 */

#ifndef STING_LAYER_H
#define STING_LAYER_H

#ifndef MODULE_DRIVER
#define MODULE_DRIVER    "MODULE_LAYER"
#endif



/*--------------------------------------------------------------------------*/


#define  MAX_HANDLE    64    /* Number of handles assigned by PRTCL_request */



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
 *   CN functions structure for TCP and UDP
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
    int16      cdecl  (* PRTCL_get_parameters) (uint32, uint32 *, int16 *, uint16 *);
    int16      cdecl  (* PRTCL_request) (void *, CN_FUNCS *);
    void       cdecl  (* PRTCL_release) (int16);
    void *     cdecl  (* PRTCL_lookup) (int16, CN_FUNCS *);
    int16      cdecl  (* TIMER_call) (void cdecl (*) (void), int16);
    int32      cdecl  (* TIMER_now) (void);
    int32      cdecl  (* TIMER_elapsed) (int32);
    int32      cdecl  (* protect_exec) (void *, int32 cdecl (*) (void *));
    int16      cdecl  (* get_route_entry) (int16, uint32 *, uint32 *, void **, uint32 *);
    int16      cdecl  (* set_route_entry) (int16, uint32, uint32, void *, uint32);
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
#define PRTCL_get_parameters(w,x,y,z)    (*stx->PRTCL_get_parameters)(w,x,y,z)
#define PRTCL_request(x,y)               (*stx->PRTCL_request)(x,y)
#define PRTCL_release(x)                 (*stx->PRTCL_release)(x)
#define PRTCL_lookup(x,y)                (*stx->PRTCL_lookup)(x,y)
#define TIMER_call(x,y)                  (*stx->TIMER_call)(x,y)
#define TIMER_now()                      (*stx->TIMER_now)()
#define TIMER_elapsed(x)                 (*stx->TIMER_elapsed)(x)
#define protect_exec(x,y)                (*stx->protect_exec)(x,y)
#define get_route_entry(a,b,c,d,e)       (*stx->get_route_entry)(a,b,c,d,e)
#define set_route_entry(a,b,c,d,e)       (*stx->set_route_entry)(a,b,c,d,e)

#endif /* MOD_DRIVER */



/*--------------------------------------------------------------------------*/


#endif /* STING_LAYER_H */
