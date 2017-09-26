#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "network.h"
#include <socket.h>
#include <sockinit.h>
#include <inet.h>
#include <in.h>
#include <netdb.h>
#include <sfcntl.h>

#include "resolver.h"

#define crlf Cconws("\r\n")
typedef struct
{
	long id, val;
}COOKIE;


int s, cs;
const char buf[1024];
void answer(sockaddr_in *ad);

void main(void)
{
	int adl;
	sockaddr_in ad;
	
	Cconws("test-dns, initializing...\r\n");
	
	if(sock_init()<0)
	{
		Cconws("test-dns: Slip not installed.\r\n");
		return;
	}

	s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if(s < 0)
	{
		Cconws("test-dns: Can\'t create socket.\r\n");
		return;
	}
	sfcntl(s, F_SETFL, O_NDELAY);
	ad.sin_port=53;
	ad.sin_addr=gethostid();
	adl=(int)sizeof(sockaddr_in);
	if(bind(s, &ad, adl) < 0)
	{
		Cconws("test-dns: Can\'t bind socket.\r\n");
		sclose(s);
		return;
	}

	Cconws("Ok, waiting.\r\n");
	do
	{
		do
		{
			cs=(int)recvfrom(s, buf, 1024, 0, &ad, &adl);
			if(cs <= 0)
			{
				/* Sleep 100 ms */
				Psemaphore(2, 'WAIT', 100);
/*				wait=clock()/10;
				while(clock()/10 == wait);*/
			}
		}while(cs <= 0);
		if(cs > 4)
		{
			answer(&ad);
			cs=5;
		}
	}while(cs > 4);
}

void answer(sockaddr_in *ad)
{
uchar *answ= /* -19 */
"\xc0\x0c\0\5\0\1\0\0\xdb\xf7\0\x11\5norse\3mcc\2ac\2uk\0" /* 47 */
"\xc0\x2b\0\1\0\1\0\0\xdb\xf7\0\4\x81\x45\x1\x1c" /* 63 */
"\xc0\x31\0\2\0\1\0\0\xdb\xf7\0\x9\6UTSERV\xc0\x31" /* 84 */
"\xc0\x31\0\2\0\1\0\0\xdb\xf7\0\x11\4ursa\3cns\5umist\xc0\x35" /* 113 */
"\xc0\x31\0\2\0\1\0\0\xdb\xf7\0\x10\6curlew\2cs\3man\xc0\x35" /* 141 */
"\xc0\x58\0\1\0\1\0\0\x8b\x7a\0\4\x82\x58\xc8\x06" /* 157 */
"\xc0\x6d\0\1\0\1\0\0\4\xc9\0\4\x82\x58\xd2\1" /* 173 */
"\xc0\x8a\0\1\0\1\0\1\x48\x39\0\4\x82\x58\xd\x7"; /* 189 */
int aslen=170;
	dns_header	*dsh, *in;
	uchar				*dst, *src=(uchar*)buf;
	rrec				*rec;
	int					total;
	
	in=(dns_header*)buf;

	Cconws("Incoming request.\r\n");

	dsh=malloc(sizeof(dns_header)+sizeof(rrec)+4+256);
	
	dsh->id=in->id;
	dsh->val1=0x80;
	dsh->val2=0x80;
	dsh->qdcount=1;
	dsh->ancount=2;
	dsh->nscount=3;
	dsh->arcount=3;
	
	/* Question */
	
	dst=(uchar*)&(dsh[1]);
	src+=sizeof(dns_header);
	cs-=(int)sizeof(dns_header);
	total=cs+(int)sizeof(dns_header)+aslen;
	while(cs--)
		*dst++=*src++;

	src=answ;
	while(aslen--)
		*dst++=*src++;		
/*
	rec=(rrec*)dst;
	rec->r_zone=0xc00c;
	rec->r_class=1;
	rec->r_type=1;
	rec->r_ttl=0x60000l;
	rec->r_size=4;
	*((long*)&(rec->r_data))=0x01020304l;

	dst=(uchar*)rec;
	dst+=sizeof(rrec)+4;
	rec=(rrec*)dst;
	rec->r_zone=0xc00c;
	rec->r_class=1;
	rec->r_type=5;
	rec->r_ttl=0x60000l;
	rec->r_size=12;
	dst=((uchar*)rec)+sizeof(rrec);
	strcpy(dst, "\03ali\03das\02as");
	total+=(int)sizeof(rrec)+12;
*/

	sendto(s, dsh, total, 0, ad, (int)sizeof(sockaddr_in));
	Cconws("answer sent\r\n");
	free(dsh);
}
