#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include "network.h"
#include "ip.h"
#include "tcp.h"
#include "udp.h"

/*char *text="220 info2 FTP server (Version wu-2.4(3) Mon Nov 7 05:06:58 MET 1994) ready.\r\n";*/
/*char *text="USER NAME ANONYMOUS";*/
/*char *text="";*/

char *text="220 hermes.rus.uni-stuttgart.de 5.67a8/IDA-1.5 Sendmail is ready at Thu, 16 May 1996 23:57:31 +0200\r\n";
/*char *text="421 Timeout (900 seconds): closing control connection.\r\n";*/
/*char *text="221 hermes.rus.uni-stuttgart.de closing connection\r\n";*/

uint eac(ulong sum)
{/* Do end-arround carry */
	ulong csum;

	while((csum=sum>>16) != 0)
		sum=csum+(sum & 0xffffl);
	return((uint)(sum & 0xffffl));
}

uint calc_ip_crc(void *buf, int words)
{
/*
 * Generic checksum computation routine.
 * Returns the one's complement of the 16 bit one's complement sum over
 * the `words' words starting at `buf'.
 */
	register uint	 *ubuf, count;
	register ulong csum=0;
	
	count=(uint)words;	/* To get it as a register variable */
	ubuf=(uint*)buf;
	
	while(count--)
		csum+=(long)*ubuf++;
	
	return(~eac(csum) & 0xffff);
}

int calc_tcp_crc(void *buf, int bytes)
{
/*
 * Generic checksum computation routine.
 * Returns the one's complement of the 16 bit one's complement sum over
 * the `bytes'/2 words starting at `buf'.
 * On odd bytes, a zero byte is padded
 */
	register uint		*ubuf, words;
	register ulong	csum=0;
	
	words=bytes/2;

	ubuf=(uint*)buf;
	
	while(words--)
		csum+=*ubuf++;
	
	if(bytes & 1) /* Odd: Calculate the last byte */
	{
		csum+=(*ubuf & 0xff00);
	}
	
	return(~eac(csum) & 0xffff);
}

void init_tpch(tcp_crc_header *tp)
{
	tp->src_ip=0x81450146l;
	tp->dst_ip=0x81451faal;
	tp->zero=0;
	tp->protocol=6;	/* protocol=TCP */
	tp->tcp_len=(int)sizeof(tcp_header)+(int)strlen(text);
	
	tp->tcph.src_port=0x19;
	tp->tcph.dst_port=0x400;
	tp->tcph.seq_nr=0x4e05a201l;
	tp->tcph.ack_nr=0x00171571l;
	tp->tcph.data_offset=(int)sizeof(tcp_header)/4;
	tp->tcph.reserved=0;
	
	tp->tcph.window=0x1000;
	tp->tcph.crc=0;
	tp->tcph.urg_pnt=0;
}

int tcp_send_syn(void)
{
	tcp_crc_header *tp;
	int len;
	char *buf, *t=text;
	
	tp=(tcp_crc_header*)malloc(sizeof(tcp_crc_header)+strlen(text));
	init_tpch(tp);
	tp->tcph.flags=0x18; /* ACK */
	buf=((char*)tp)+sizeof(tcp_crc_header);
	len=(int)strlen(text);
	while(len--)
		*buf++=*t++;
	tp->tcph.crc=calc_tcp_crc(tp, (int)sizeof(tcp_crc_header)+(int)strlen(text));
	
	len=(int)Fcreate("CSUM.OUT",0);
	Fwrite(len, sizeof(tcp_crc_header)+strlen(text), tp);
	Fclose(len);
	return(tp->tcph.crc);
}

int	udp_zock(void)
{

int src_port=0x35;
int dst_port=0x407; 
ulong my_ip=0x8145011cl; 
ulong dst_ip=0x81451facl;
int len=0xd2-8;
uchar *buf="\0\x8\x80\x80\0\1\0\2\0\3\0\3\3www\3mcc\2ac\2uk\0\0\1\0\1"
"\xc0\x0c\0\5\0\1\0\0\xdb\xf7\0\x11\5norse\3mcc\2ac\2uk\0"
"\xc0\x2b\0\1\0\1\0\0\xdb\xf7\0\4\x82\x58\xc8\x16"
"\xc0\x31\0\2\0\1\0\0\xdb\xf7\0\x9\6UTSERV\xc0\x31"
"\xc0\x31\0\2\0\1\0\0\xdb\xf7\0\x11\4ursa\3cns\5umist\xc0\x35"
"\xc0\x31\0\2\0\1\0\0\xdb\xf7\0\x10\6curlew\2cs\3man\xc0\x35"
"\xc0\x58\0\1\0\1\0\0\x8b\x7a\0\4\x82\x58\xc8\x06"
"\xc0\x6d\0\1\0\1\0\0\4\xc9\0\4\x82\x58\xd2\1"
"\xc0\x8a\0\1\0\1\0\1\x48\x39\0\4\x82\x58\xd\x7";

/*
int src_port=0x666;
int dst_port=0x35; 
ulong dst_ip=0x8145011cl; 
ulong my_ip=0x81451fabl;
int len=0x36-8;
uchar *buf="\xcc\x9\0\0\0\1\0\0\0\0\0\0\3www\xainformatik\xauni-bremen\2de\0\0\1\0\1";
*/
udp_crc_header	*uch;

	udp_header			*uph;
	uchar						*cbuf;
	int							clen=len, ierr;
	uint						ip_len, bcrc;
	

	ip_len=(uint)len+(uint)sizeof(udp_header);
	clen=(int)sizeof(udp_crc_header)+len;
	uch=(udp_crc_header*)malloc(clen);
	if(uch==NULL)
		return(-1);
	
	uch->src_ip=my_ip;
	uch->dst_ip=dst_ip;
	uch->zero=0;
	uch->protocol=17;
	uch->len=len+8;

	uph=&(uch->uph);
	uph->src_port=src_port;
	uph->dst_port=dst_port;
	uph->len=len+8;
	uph->crc=0;
	
	cbuf=((uchar*)uch)+sizeof(udp_crc_header);
	while(len--)
		*cbuf++=*buf++;
	
	bcrc=uph->crc=calc_tcp_crc(uch, clen);
	
	free(uch);
	return(bcrc);
}

void main(void)
{
	ip_header *iph;
	uint			head_len, len;
	uint			opt_len=0;
	char			num[32];
	char			alert[246];
	
	head_len=(uint)sizeof(ip_header)+opt_len;
	len=40-head_len+(int)strlen(text);
	iph=(ip_header*)malloc(head_len+len);
	if(iph==NULL) return;

	iph->version_IHL=(4<<4)+(head_len/4);
	iph->TOS=0x10;
	iph->total_len=head_len+len;
	iph->id=0x1def;
	iph->flags_frag_off=0;
	iph->TTL=0x3b;
	iph->protocol=6;
	iph->crc=0;
	iph->src_ip=0x8145120fl;
	iph->dst_ip=0x81451fb6l;

	
	iph->crc=calc_ip_crc(iph, head_len/2);

	appl_init();
/*	strcpy(alert, "[1][IP-PrÅfsumme:|");
	strcat(alert, ltoa((ulong)iph->crc, num, 16));
	strcat(alert, "][OK]");
	form_alert(1,alert);*/

	strcpy(alert, "[1][UDP-PrÅfsumme:|");
	strcat(alert, itoa(udp_zock(), num, 16));
	strcat(alert, "][OK]");
	form_alert(1,alert);

	appl_exit();

	free(iph);
}
