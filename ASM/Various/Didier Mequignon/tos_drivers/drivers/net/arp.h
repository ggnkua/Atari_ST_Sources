/*
 * File:        arp.h
 * Purpose:     ARP definitions.
 *
 * Notes:
 */

#ifndef _ARP_H
#define _ARP_H

/********************************************************************/

/*
 * This data definition is defined for Ethernet only!
 */
typedef struct
{
    uint16      ar_hrd;
    uint16      ar_pro;
    uint8       ar_hln;
    uint8       ar_pln;
    uint16      opcode;
    uint8       ar_sha[6];  /* ethernet hw address */
    uint8       ar_spa[4];  /* ip address */
    uint8       ar_tha[6];  /* ethernet hw address */
    uint8       ar_tpa[4];  /* ip address */
} arp_frame_hdr;

#define ARP_HDR_LEN     sizeof(arp_frame_hdr)

/*
 * ARP table entry definition.  Note that this table only designed
 * with Ethernet and IP in mind.
 */
#define MAX_HWA_SIZE    (6) /* 6 is enough for Ethernet address */
#define MAX_PA_SIZE     (4) /* 4 is enough for Protocol address */
typedef struct
{
    uint16  protocol;
    uint8   hwa_size;
    uint8   hwa[MAX_HWA_SIZE];
    uint8   pa_size;
    uint8   pa[MAX_PA_SIZE];
    int     longevity;
} ARPENTRY;
#define MAX_ARP_ENTRY   (10)

typedef struct
{
    unsigned int    tab_size;
    ARPENTRY        table[MAX_ARP_ENTRY];
} ARP_INFO;

#define ARP_ENTRY_EMPTY (0)
#define ARP_ENTRY_PERM  (1)
#define ARP_ENTRY_TEMP  (2)


#define ETHERNET        (1)
#define ARP_REQUEST     (1)
#define ARP_REPLY       (2)

#define ARP_TIMEOUT     (1)     /* Timeout in seconds */

/* Protocol Header information */
#define ARP_HDR_OFFSET  ETH_HDR_LEN

/********************************************************************/

uint8 *
arp_get_mypa (void);

uint8 *
arp_get_myha (void);

uint8 *
arp_get_broadcast (void);

void
arp_merge (ARP_INFO *, uint16, int, uint8 *, int, uint8 *, int);

void
arp_remove (ARP_INFO *, uint16, uint8 *, uint8 *);

void
arp_request (NIF *, uint8 *);

void
arp_handler (NIF *, NBUF *);

uint8 *
arp_resolve (NIF *, uint16, uint8 *);

void
arp_init (ARP_INFO *);

/********************************************************************/

#endif  /* _ARP_H */
