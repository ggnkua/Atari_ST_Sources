/*
 * File:        icmp.h
 * Purpose:     Handle Internet Control Message Protocol packets.
 *
 * Notes:       See RFC 792 "Internet Control Message Protocol"
 *              for more details.
 */

#ifndef _ICMP_H
#define _ICMP_H

/********************************************************************/

typedef struct
{
    uint32  unused;
    uint8   ih_dg;
} icmp_dest_unreachable;
#define ICMP_DEST_UNREACHABLE       (3) /* type */
#define ICMP_NET_UNREACHABLE        (0) /* code */
#define ICMP_HOST_UNREACHABLE       (1)
#define ICMP_PROTOCOL_UNREACHABLE   (2)
#define ICMP_PORT_UNREACHABLE       (3)
#define ICMP_FRAG_NEEDED            (4)
#define ICMP_ROUTE_FAILED           (5)

typedef struct
{
    uint32  unused;
    uint8   ih_dg;
} icmp_time_exceeded;
#define ICMP_TIME_EXCEEDED          (11)    /* type */
#define ICMP_TTL_EXCEEDED           (0)     /* code */
#define ICMP_FRAG_TIME_EXCEEDED     (1)

typedef struct
{
    uint8   pointer;
    uint8   unused1;
    uint16  unused2;
    uint8   ih_dg;
} icmp_parameter_problem;
#define ICMP_PARAMETER_PROBLEM      (12)    /* type */
#define ICMP_POINTER                (0)     /* code -- not */

typedef struct
{
    uint32  unused;
    uint8   ih_dg;
} icmp_source_quench;
#define ICMP_SOURCE_QUENCH          (4)     /* type */

typedef struct
{
    uint32  gateway_addr;
    uint8   ih_dg;
} icmp_redirect;
#define ICMP_REDIRECT               (5)     /* type */
#define ICMP_REDIRECT_NET           (0)     /* code */
#define ICMP_REDIRECT_HOST          (1)
#define ICMP_REDIRECT_TOS_NET       (2)
#define ICMP_REDIRECT_TOS_HOST      (3)

typedef struct
{
    uint16  identifier;
    uint16  sequence;
    uint8   data;
} icmp_echo;
#define ICMP_ECHO                   (8)     /* type */
#define ICMP_ECHO_REPLY             (0)     /* type */

typedef struct
{
    uint16  identifier;
    uint16  sequence;
} icmp_information;
#define ICMP_INFORMATION_REQUEST    (15)    /* type */
#define ICMP_INFORMATION_REPLY      (16)    /* type */

typedef struct
{
    uint16  identifier;
    uint16  sequence;
    uint32  originate_ts;
    uint32  receive_ts;
    uint32  transmit_ts;
} icmp_timestamp;
#define ICMP_TIMESTAMP              (13)    /* type */
#define ICMP_TIMESTAMP_REPLY        (14)    /* type */

typedef struct
{
    uint8   type;
    uint8   code;
    uint16  chksum;
    union
    {
        icmp_dest_unreachable       dest_unreachable;
        icmp_source_quench          source_quench;
        icmp_redirect               redirect;
        icmp_time_exceeded          time_exceeded;
        icmp_parameter_problem      parameter_problem;
        icmp_timestamp              timestamp;
        icmp_information            information;
        icmp_echo                   echo;
    } msg;
} icmp_message;

/********************************************************************/

/* Protocol Header information */
#define ICMP_HDR_OFFSET     (ETH_HDR_LEN + IP_HDR_SIZE)
#define ICMP_HDR_SIZE       8

void
icmp_handler(NIF *, NBUF *);

/********************************************************************/

#endif  /* _ICMP_H */
