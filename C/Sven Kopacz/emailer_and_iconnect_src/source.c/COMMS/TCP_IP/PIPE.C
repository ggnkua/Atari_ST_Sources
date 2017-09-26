#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <string.h>

#include "network.h"
#include "tcp.h"
#include "ip.h"

#define	S_END	192
#define	S_ESC	219
#define S_ESC_END 220
#define S_ESC_ESC 221

	/* Faster Flag-access */
	#define FURG ((tcph->flags & URG) > 0)
	#define FACK ((tcph->flags & ACK) > 0)
	#define FPSH ((tcph->flags & PSH) > 0)
	#define FRST ((tcph->flags & RST) > 0)
	#define FSYN ((tcph->flags & SYN) > 0)
	#define FFIN ((tcph->flags & FIN) > 0)

ulong	sseq=0x3deb9000l;

uint eac(ulong sum)
{/* Do end-arround carry */
	uint csum;
	
	while((csum=(uint)((ulong)sum>>16)) != 0)
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
		csum+=*ubuf++;
	
	return(~eac(csum) & 0xffff);
}

uint calc_tcp_crc(void *buf, int bytes)
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
	
	if(words*2 < bytes) /* Odd: Calculate the last byte */
		csum+=*ubuf & 0xff00;
	
	return(~eac(csum) & 0xffff);
}


void init_tpch(tcp_crc_header *tp, int sp, int dp, ulong ack)
{
	tp->src_ip=0x05060708l;
	tp->dst_ip=0x01020304l;
	tp->zero=0;
	tp->protocol=6;	/* protocol=TCP */
	tp->tcp_len=(int)sizeof(tcp_header);
	
	tp->tcph.src_port=sp;
	tp->tcph.dst_port=dp;
	tp->tcph.seq_nr=sseq;
	tp->tcph.ack_nr=ack;
	tp->tcph.data_offset=(int)sizeof(tcp_header)/4;
	tp->tcph.reserved=0;
	
	tp->tcph.window=0x1000;
	tp->tcph.crc=0;
	tp->tcph.urg_pnt=0;
}

void answer(int fh, long len, uchar *buf)
{
	static uchar buf2[1024];
	char		alert[256], *ans="202 Answer";
	ip_header iph, *iin;
	tcp_header *tcph;
	tcp_crc_header tp;
	uint			head_len;
	uchar			*buf3;
	int 			len2, c, msglen, answ;
	uchar x;

	answ=0;
	/* UnSlip */
	for(len2=0,c=0; c < len; ++c)
	{
		x=buf[c];
		switch(x)
		{
			case S_END:
				if(len2 > 0)
					c=(int)len;
			break;
			case S_ESC:
				x=buf[++c];
				switch(x)
				{
					case S_ESC_END:
						x=S_END;
					break;
					case S_ESC_ESC:
						x=S_ESC;
					break;
				}
			/* No break here->fall into default */
			default:
				buf2[len2++]=x;
			break;
		}
	}
	iin=(ip_header*)buf2;
	tcph=(tcp_header*)(buf2+(iin->version_IHL & 15)*4);

	msglen=iin->total_len-(iin->version_IHL & 15)*4-(tcph->data_offset*4);

	tp.src_ip=iin->dst_ip;
	tp.dst_ip=iin->src_ip;
	tp.zero=0;
	tp.protocol=6;	/* protocol=TCP */
	tp.tcp_len=(int)sizeof(tcp_header);
	
	tp.tcph.src_port=tcph->dst_port;
	tp.tcph.dst_port=tcph->src_port;
	tp.tcph.seq_nr=sseq;
	tp.tcph.ack_nr=tcph->seq_nr+msglen;
	tp.tcph.data_offset=(int)sizeof(tcp_header)/4;
	tp.tcph.reserved=0;
	
	tp.tcph.window=0x1000;
	tp.tcph.crc=0;
	tp.tcph.urg_pnt=0;

	if(FSYN)
	{
		tp.tcph.flags=ACK|SYN;
		++sseq;
		tp.tcph.ack_nr++;
		form_alert(1,"[1][SYN received.][Ok]");
	}
	else if(FFIN)
	{
		tp.tcph.flags=ACK|FIN;
		tp.tcph.ack_nr++;
		++sseq;
		form_alert(1,"[1][FIN received.][Ok]");
	}
	else if(FRST)
	{
		form_alert(1,"[1][RST received.][Ok]");
		return;
	}
	else
	{
		if(msglen > 0)
		{
			strcpy(alert, "[1][Message received:|");
			strncat(alert, ((char*)tcph)+tcph->data_offset*4, msglen);
			alert[msglen+strlen("[1][Message received:|")]=0;
			strcat(alert, "][Ok]"); 
			answ=1;
			sseq+=strlen(ans);
		}
		else
		{
			if(FACK)
				form_alert(1, "[1][Empty ACK received][Ok]");
			else
				form_alert(1, "[1][Empty Message received][Ok]");
			return;
		}
		form_alert(1,alert);
		tp.tcph.flags=ACK;
	}

	tp.tcph.crc=calc_tcp_crc(&tp, (int)sizeof(tcp_crc_header));
	
	head_len=(uint)sizeof(ip_header);

	iph.version_IHL=(4<<4)+(head_len/4);
	iph.TOS=0;
	iph.total_len=head_len+(int)sizeof(tcp_header)+answ*(int)strlen(ans);
	iph.id=0xa423;
	iph.flags_frag_off=0;
	iph.TTL=0x34;
	iph.protocol=6;
	iph.crc=0;
	iph.src_ip=tp.src_ip;
	iph.dst_ip=tp.dst_ip;
	
	iph.crc=calc_ip_crc(&iph, head_len/2);

	
	len=sizeof(tcp_header)+sizeof(ip_header)+answ*(int)strlen(ans);
	buf3=malloc(len);
	*((ip_header*)buf3)=*(&iph);
	*((tcp_header*)((buf3+sizeof(ip_header))))=*(&(tp.tcph));
	if(answ)
		strcpy((char*)buf3+sizeof(tcp_header)+sizeof(ip_header), ans);
	/* SLipOut*/
	len2=0;
	buf2[len2++]=S_END;
	for(c=0; c < len; ++c)
	{
		buf2[len2]=*buf3++;
		switch(buf2[len2])
		{
			case S_END:
				buf2[len2++]=S_ESC;
				buf2[len2]=S_ESC_END;
			break;
			case S_ESC:
				buf2[len2++]=S_ESC;
				buf2[len2]=S_ESC_ESC;
			break;
		}
		++len2;
	}
	buf2[len2++]=S_END;
	free(buf3);
	
	Fwrite(fh, len2, buf2);
}

void main(void)
{
	long fhl, len;
	int fh;
	uchar buf[1024];
	
	appl_init();
	fhl=Fopen("U:\\DEV\\SERIAL2",FO_RW);
	if(fhl < 0)
	{
		form_alert(1,"[3][Nix Pipe][Oh]");
		appl_exit();
		return;
	}
	
	fh=(int)fhl;

	while(1)
	{
		len=0;
		do
		{
			fhl=Fread(fh, 1024-len, &(buf[len]));
			if(fhl > 0)
				len+=fhl;
		}while(fhl > 0);
		if(len > 0)
		{
			answer(fh, len, buf);
/*			break;*/
		}
		evnt_timer(100,0);
	}
	Fclose(fh);
	appl_exit();
}

