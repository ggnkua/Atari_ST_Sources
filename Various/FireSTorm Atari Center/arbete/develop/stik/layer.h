/*
 *      layer.h             (c) Peter Rottengatter  1996
 *                              perot@pallas.amp.uni-hannover.de
 *
 *      Include this file to provide high level protocol interfacing to STiK
 */

#ifndef STIK_LAYER_H
#define STIK_LAYER_H

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
    uint16           date;           /* Compile date in GEMDOS format       */
    char             *author;        /* Name of programmer                  */
    int16            stat_dropped;   /* Statistics of dropped data units    */
    struct lay_desc  *next;          /* Next layer in driver chain          */
 } LAYER;



/*--------------------------------------------------------------------------*/


/*
 *   CN functions structure for TCP and UDP
 */

typedef  struct cn_funcs {
    int16  cdecl  (* CNkick) (int16);
    int16  cdecl  (* CNbyte_count) (int16);
    int16  cdecl  (* CNget_char) (int16);
    NDB *  cdecl  (* CNget_NDB) (int16);
    int16  cdecl  (* CNget_block) (int16, uint8 *, int16);
    CIB *  cdecl  (* CNgetinfo) (int16);
    int16  cdecl  (* CNgets) (int16, uint8 *, int16, uint8);
 } CN_FUNCS;



/*--------------------------------------------------------------------------*/


/*
 *   Just to satisfy compiler
 */

#ifndef STIK_PORT_H

typedef  struct port_desc {
    int  dummy;
 } PD_DUMMY;

#endif /* STIK_PORT_H */



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
    int16      cdecl  (* PRTCL_request) (CN_FUNCS *);
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


#endif /* STIK_LAYER_H */
