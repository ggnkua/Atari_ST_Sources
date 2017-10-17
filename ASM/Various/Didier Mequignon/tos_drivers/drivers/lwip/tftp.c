/*
 * TFTP library 
 * copyright (c) 2004 Vanden Berghen Frank  
 *
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License version 2.1 as published by the Free Software Foundation
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

#include <osbind.h> /* The client can be used _only_ by the TOS */
#include <string.h> /* because TOS trap cannot be used out of CT68KLIB ! */
#include "config.h"
#include "net.h"
#include "sockets.h"
#include "tftp.h"

#ifdef NETWORK
#ifdef LWIP

#define TIMEOUT 2 /* seconds */
#define NUMBERTIMEOUT 3 /* retries */

#define SEGSIZE 512         /* data segment size */
#define PKTSIZE SEGSIZE+4   /* full packet size */

/*
 * Error codes.
 */
#define	EUNDEF		0		/* not defined */
#define	ENOTFOUND	1		/* file not found */
#define	EACCESS		2		/* access violation */
#define	ENOSPACE	3		/* disk full or allocation exceeded */
#define	EBADOP		4		/* illegal TFTP operation */
#define	EBADID		5		/* unknown transfer ID */
#define	EEXISTS		6		/* file already exists */
#define	ENOUSER		7		/* no such user */

/*
 * Packet types.
 */
#define	RRQ	1         /* read request */
#define	WRQ	2         /* write request */
#define	DATA 3        /* data packet */
#define	ACK	4         /* acknowledgement */
#define	ERROR 5 			/* error code */

struct tftphdr
{
	short	th_opcode;			/* packet type */
	union
	{
		unsigned short tu_block;	/* block # */
		short tu_code;		/* error code */
		char tu_stuff[1];		/* request packet stuff */
	} th_u;
	char th_data[1];			/* data or error string */
} __attribute__((packed));

#define	th_block	th_u.tu_block
#define	th_code		th_u.tu_code
#define	th_stuff	th_u.tu_stuff
#define	th_msg		th_data

static char buf[PKTSIZE], ackbuf[PKTSIZE];
static char tftp_string_error[1024];

extern void ltoa(char *buf, long n, unsigned long base);

static int create_socket(int type, int *ptr_port)
{
	int desc, len = sizeof(struct sockaddr_in);
	static struct sockaddr_in address;
	if((desc = socket(AF_INET, type, 0)) == -1)
	{
		strcat(tftp_string_error, "TFTP: cannot create socket");
		return -1;
	}
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = htonl(INADDR_ANY);
	address.sin_port = htons(*ptr_port);
	if(bind(desc, (struct sockaddr *)&address, len) == -1)
	{
		strcat(tftp_string_error, "TFTP: cannot bind socket");
		close(desc);
		return -1;
	}
	return desc;
};

int tftp_receive(struct sockaddr_in *to1, char *name, char *mode, short handle, long *length)
{
	char *dat, *cp;
	struct tftphdr *dp, *ap;
	int i, size, n, ntimeout, peer, nextBlockNumber;
	struct timeval tv;
	fd_set lecture;
	struct sockaddr_in from, to=*to1;
	socklen_t fromlen=sizeof(from), tolen=fromlen;
	*tftp_string_error = '\0';
	*length = 0;
	dp = (struct tftphdr *)buf;
	ap = (struct tftphdr *)ackbuf;
	dat = (char*)&dp->th_data[0];
	cp = (char*)&ap->th_stuff[0];
	i = 0;
	if((peer = create_socket(SOCK_DGRAM, &i)) < 0)
		return -1;
	ap->th_opcode = htons((unsigned short)RRQ);
	strcpy(cp, name);
	cp += strlen(name);
	*cp++ = '\0';
	strcpy(cp, mode);
	cp += strlen(mode);
	*cp++ = '\0';
	size = (unsigned long)cp-(unsigned long)ackbuf;
	nextBlockNumber = 1; 
	do 
	{    
		ntimeout = 0;
		do
		{
			if(ntimeout == NUMBERTIMEOUT)
			{
				strcat(tftp_string_error, "TFTP: could not make connection to server");
				close(peer);
				return -1;
			}
			if(sendto(peer, ap, size, 0, (struct sockaddr *)&to, tolen) != size)
			{
				strcat(tftp_string_error, "TFTP: write ACK error");
				close(peer);
				return -1;
			}
			do
			{
				n = -1;
				FD_ZERO(&lecture);
				FD_SET(peer, &lecture); 
				tv.tv_sec = TIMEOUT;
				tv.tv_usec = 0;
				if((i = select(FD_SETSIZE, &lecture, NULL, NULL, &tv)) == -1)
				{
					strcat(tftp_string_error, "TFTP: select error");
					close(peer);
					return -1;
				}
				if((i > 0) && (FD_ISSET(peer, &lecture) != 0))
					n = recvfrom(peer, dp, PKTSIZE, 0, (struct sockaddr *)&from, &fromlen);
			}
			while((n < 0) && (i > 0));
			if(i > 0)
			{
				to.sin_port = from.sin_port;
				dp->th_opcode = ntohs((unsigned short)dp->th_opcode);            
				dp->th_block = ntohs((unsigned short)dp->th_block);
				if(dp->th_opcode != DATA) 
				{
					if(dp->th_opcode == ERROR)
					{
						char buf[10];
						strcat(tftp_string_error, "TFTP Error #");
						ltoa(buf, dp->th_code, 10);
						strcat(tftp_string_error, buf);
						strcat(tftp_string_error, ": ");
						strcat(tftp_string_error, dp->th_data);
					}
					close(peer);
					return -1;
				}
				if((int)dp->th_block < nextBlockNumber)
				{
					/* Re-ACK this packet */
					ap->th_block = htons(dp->th_block);
					ap->th_opcode = htons((unsigned short)ACK);
					if(sendto(peer, ap, 4, 0,(struct sockaddr *)&to, tolen) != size)
					{
						strcat(tftp_string_error, "TFTP: write Re-ACK error");
						close(peer);
						return -1;
					}
					continue;
				}
				else if((int)dp->th_block != nextBlockNumber)
				{
#if 0
					/* This is NOT the block number expected */
					char buffer[10];
					strcat(tftp_string_error, "TFTP: block number error, ACK expected: ");
          ltoa(buffer, nextBlockNumber, 10);
					strcat(tftp_string_error, buffer);
					strcat(tftp_string_error,", ACK received: ");
          ltoa(buffer, (int)dp->th_block, 10);
					strcat(tftp_string_error, buffer);
					strcat(tftp_string_error, "\r\n");
					close(peer);
					return -1;
#else
					continue;
#endif
				}
			}
			ntimeout++;
		}
		while((int)dp->th_block != nextBlockNumber);
		ap->th_block = htons((unsigned short)nextBlockNumber);
		ap->th_opcode = htons((unsigned short)ACK);
		size = 4;
		if(n-4 > 0)
		{
			*length += (long)(n-4);
			i = Fwrite(handle, n-4, dat);
			if(i < 0)
			{
				close(peer);
				return i;
			}
		}
		nextBlockNumber++;
	}
	while(n == PKTSIZE);
	/* send the "final" ack */
	sendto(peer, ap, 4, 0,(struct sockaddr *)&to, tolen);
	close(peer);
	return 0;
};

int tftp_send(struct sockaddr_in *to1, char *name, char *mode, short handle)
{
	char *dat, *cp;
	struct tftphdr *dp, *ap;
	int i, size, Oldsize=PKTSIZE, n, ntimeout, peer, nextBlockNumber;
	struct timeval tv;
	fd_set lecture;
	struct sockaddr_in from, to=*to1;
	socklen_t fromlen=sizeof(from), tolen=fromlen;
	*tftp_string_error = '\0';
	dp = (struct tftphdr *)buf;
	ap = (struct tftphdr *)ackbuf;
	dat = (char*)&dp->th_data[0];
	cp = (char*)&dp->th_stuff[0];
	i = 0;
	if((peer = create_socket(SOCK_DGRAM, &i)) < 0)
		return -1;
	dp->th_opcode=htons((unsigned short)WRQ);
	strcpy(cp, name);
	cp += strlen(name);
	*cp++ = '\0';
	strcpy(cp, mode);
	cp += strlen(mode);
	*cp++ = '\0';
	size = (unsigned long)cp-(unsigned long)buf;
	nextBlockNumber = 0;
	do 
	{    
		ntimeout = 0;
		do
		{
			if(ntimeout == NUMBERTIMEOUT)
			{
				strcat(tftp_string_error, "TFTP: could not make connection to server");
				close(peer);
				return -1;
			}
			if(sendto(peer, dp, size, 0, (struct sockaddr *)&to, tolen) != size)
			{
				strcat(tftp_string_error, "TFTP: write error");
				close(peer);
				return -1;
			}
			do
			{
				n = -1;
				FD_ZERO(&lecture);
				FD_SET(peer, &lecture); 
				tv.tv_sec = TIMEOUT;
				tv.tv_usec = 0;
				if((i = select(FD_SETSIZE, &lecture, NULL, NULL, &tv)) == -1)
				{
					strcat(tftp_string_error, "TFTP: select error");
					close(peer);
					return -1;
				}
				if((i > 0) && (FD_ISSET(peer, &lecture) != 0))
					n = recvfrom(peer, ap, PKTSIZE, 0, (struct sockaddr *)&from, (socklen_t *)&fromlen);
			}
			while((n < 0) && (i > 0));
			if(i > 0)
			{
				to.sin_port=from.sin_port;
				ap->th_opcode = ntohs((unsigned short)ap->th_opcode);
				ap->th_block = ntohs((unsigned short)ap->th_block);
				if(ap->th_opcode != ACK)
				{
					if(ap->th_opcode == ERROR)
					{
						char buf[10];
						strcat(tftp_string_error, "TFTP Error #");
						ltoa(buf, ap->th_code, 10);
						strcat(tftp_string_error, buf);
						strcat(tftp_string_error, ": ");
						strcat(tftp_string_error, ap->th_data);
					}
					close(peer);
					return -1;
				}
				if((int)ap->th_block < nextBlockNumber)
				{
					/* Re-ACK this packet */
					dp->th_block = htons(ap->th_block);
					dp->th_opcode = htons((unsigned short)ACK);
					if(sendto(peer, dp, 4, 0,(struct sockaddr *)&to, tolen) != size)
					{
						strcat(tftp_string_error, "TFTP: write Re-ACK error");
						close(peer);
						return -1;
					}
					continue;
				}
				else if((int)ap->th_block != nextBlockNumber)
				{
#if 0
					/* This is NOT the block number expected */
					char buffer[10];
					strcat(tftp_string_error, "TFTP: block number error, ACK expected: ");
          ltoa(buffer, nextBlockNumber, 10);
					strcat(tftp_string_error, buffer);
					strcat(tftp_string_error,", ACK received: ");
          ltoa(buffer, (int)ap->th_block, 10);
					strcat(tftp_string_error, buffer);
					strcat(tftp_string_error, "\r\n");
					close(peer);
					return -1;
#else
					continue;
#endif
				}
			}
			ntimeout++;
		}
		while((int)ap->th_block != nextBlockNumber);
		if((size < PKTSIZE) && (nextBlockNumber != 0))
			break; // all is sent in the 1er data packet
		nextBlockNumber++;
		dp->th_block=htons((unsigned short)nextBlockNumber);
		if(nextBlockNumber == 1)
		{
			dp->th_opcode = htons((unsigned short)DATA);
			i = Fread(handle, SEGSIZE, dat);
			if(i >= 0)
				size = i;
			else
				size = 0;
		}
		else 
		{
			Oldsize = size;
			if(Oldsize == PKTSIZE)
			{
				i = Fread(handle, SEGSIZE, dat);
				if(i >= 0)
					size = i;
				else
					size = 0;
			}   
			else
				i = 0;
		}
		if(i <= 0)
		{
			close(peer);
			return i;
		}
		size += 4;
	}
	while(Oldsize == PKTSIZE);
	close(peer);
	return 0;
}

char *tftp_get_error(void)
{
	return(tftp_string_error);
}

#endif /* LWIP */
#endif /* NETWORK */
