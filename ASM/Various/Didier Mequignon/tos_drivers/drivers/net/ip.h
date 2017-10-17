/*
 * File:        ip.h
 * Purpose:     Definitions for the Internet Protocol, IP.
 *
 * Notes:       See RFC 791 "DARPA Internet Program Protocol
 *              Specification" for more details.
 */

#ifndef _IP_H
#define _IP_H

/********************************************************************/

/* 32-bit IP Addresses */
typedef uint8 IP_ADDR[4];

/* Pointer to an IP Address */
typedef uint8 IP_ADDR_P[];

/* Definition of an IP packet header */
typedef struct
{
    uint8       version_ihl;
    uint8       service_type;
    uint16      total_length;
    uint16      identification;
    uint16      flags_frag_offset;
    uint8       ttl;
    uint8       protocol;
    uint16      checksum;
    IP_ADDR     source_addr;
    IP_ADDR     dest_addr;
    uint8       options;    /* actually an array of undetermined length */
} ip_frame_hdr;

/* Macros for accessing an IP datagram.  */
#define IP_VERSION(a)   ((a->version_ihl & 0x00F0) >> 4)
#define IP_IHL(a)       ((a->version_ihl & 0x000F))
#define IP_SERVICE(a)   (a->service_type)
#define IP_LENGTH(a)    (a->total_length)
#define IP_IDENT(a)     (a->identification)
#define IP_FLAGS(a)     ((a->flags_frag_offset & 0x0000E000) >> 13)
#define IP_FRAGMENT(a)  ((a->flags_frag_offset & 0x00001FFF))
#define IP_TTL(a)       (a->ttl)
#define IP_PROTOCOL(a)  (a->protocol)
#define IP_CHKSUM(a)    (a->checksum)
#define IP_SRC(a)       (&a->source_addr[0])
#define IP_DEST(a)      (&a->dest_addr[0])
#define IP_OPTIONS(a)   (&a->options)
#define IP_DATA(a)      (&((uint8 *)a)[IP_IHL(a) * 4])

/* Defined IP protocols */
#define IP_PROTO_ICMP   (1)
#define IP_PROTO_UDP    (17)

/* Protocol Header information */
#define IP_HDR_OFFSET   ETH_HDR_LEN
#define IP_HDR_SIZE     20  /* no options */

/********************************************************************/

typedef struct
{
    IP_ADDR         myip;
    IP_ADDR         gateway;
    IP_ADDR         netmask;
    IP_ADDR         broadcast;
    unsigned int    rx;
    unsigned int    rx_unsup;
    unsigned int    tx;
    unsigned int    err;
} IP_INFO;

/********************************************************************/

void
ip_handler (NIF *, NBUF *);

uint16
ip_chksum (uint16 *, int);

int
ip_send (NIF *, 
        uint8 *,    /* destination IP */
        uint8 *,    /* source IP */
        uint8,      /* protocol */
        NBUF *      /* buffer descriptor */);

void
ip_init (IP_INFO *, IP_ADDR_P, IP_ADDR_P, IP_ADDR_P);

uint8 *
ip_get_myip (IP_INFO *);

uint8 *
ip_resolve_route (NIF *, IP_ADDR_P);

/********************************************************************/

#endif  /* _IP_H */
