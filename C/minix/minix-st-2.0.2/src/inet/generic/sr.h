/*
sr.h

Copyright 1995 Philip Homburg
*/

#ifndef SR_H
#define SR_H

#define MAX_IOCTL_S	512

#define ETH_DEV		ETH_DEV0
#define IP_DEV		IP_DEV0

#define ETH_DEV0	0x01
#define IP_DEV0		0x02
#define TCP_DEV0	0x03
#define UDP_DEV0	0x04

#define ETH_DEV1	0x11
#define IP_DEV1		0x12
#define TCP_DEV1	0x13
#define UDP_DEV1	0x14

#define PSIP_DEV0	0x21
#define IP_DEV2		0x22
#define TCP_DEV2	0x23
#define UDP_DEV2	0x24

#define PSIP_DEV1	0x31
#define IP_DEV3		0x32
#define TCP_DEV3	0x33
#define UDP_DEV3	0x34

#define SR_CANCEL_IOCTL	1
#define SR_CANCEL_READ	2
#define SR_CANCEL_WRITE	3

/* Forward struct declarations */

struct acc;

/* prototypes */

typedef int  (*sr_open_t) ARGS(( int port, int srfd,
	get_userdata_t get_userdata, put_userdata_t put_userdata,
	put_pkt_t put_pkt ));
typedef void (*sr_close_t) ARGS(( int fd ));
typedef int (*sr_read_t) ARGS(( int fd, size_t count ));
typedef int (*sr_write_t) ARGS(( int fd, size_t count ));
typedef int  (*sr_ioctl_t) ARGS(( int fd, ioreq_t req ));
typedef int  (*sr_cancel_t) ARGS(( int fd, int which_operation ));

void sr_init ARGS(( void  ));
int sr_add_minor ARGS(( int minor, int port, sr_open_t openf,
	sr_close_t closef, sr_read_t sr_read, sr_write_t sr_write,
	sr_ioctl_t ioctlf, sr_cancel_t cancelf ));

#endif /* SR_H */


/*
 * $PchId: sr.h,v 1.6 1996/05/07 20:50:51 philip Exp $
 */
