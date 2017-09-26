#include <stdio.h>
#include <tos.h>
#include <aes.h>
#include <hsmod.h>
#include <string.h>
#include <stdlib.h>

#define uchar unsigned char

int open_aux(char *path, long baud);
void out1(int h, long len, uchar *buf);
void out2(int h, long len, uchar *buf);

void main(void)
{
	long fhl, len;
	int h1, h2, fh;
	uchar	buf[100];
	int cnt=0;
	
	appl_init();
	
	h1=open_aux("U:\\DEV\\MODEM1", 19200l);
	h2=open_aux("U:\\DEV\\SERIAL2", 57600l);
	fhl=Fcreate("SER.LOG", 0);
	
	if((h1 < 0) || (h2 < 0) || (fhl < 0))
	{
		form_alert(1,"[3][Nixxe ”ffene Snittst„lle][Seisse]");
		Fclose(h1); Fclose(h2); Fclose((int)fhl);
		appl_exit();
		return;
	}
	
	fh=(int)fhl;
	
/*	Fwrite(h1, 33, "1 nach 2 Test ber mehrere Zeilen");
	Fwrite(h2, 35, "2 nach 1 Test auch ber hier und da");*/

while(cnt < 1000)
{
	do
	{
		len=0;
		do
		{
			fhl=Fread(h2, 100-len, &(buf[len]));
			if(fhl > 0)
			{
				Fwrite(h1, fhl, &(buf[len]));
			 len+=fhl;
			}
		}while((fhl > 0) && (len < 100));
		if(len > 0)
			out1(fh, len, buf);
	}while(fhl > 0);

	do
	{
		len=0;
		do
		{
			fhl=Fread(h1, 100-len, &(buf[len]));
			if(fhl > 0)
			{ 
				Fwrite(h2, fhl, &(buf[len]));
				len+=fhl;
			}
		}while((fhl > 0) && (len < 100));
		if(len > 0)
			out2(fh, len, buf);
	}while(fhl > 0);
	evnt_timer(100,0);
	/* ++cnt */
}

	Fclose(h1);
	Fclose(h2);
	Fclose(fh);
	appl_exit();
}

void out_line(int h, int len, uchar *buf)
{
	static char lin[36], num[4];
	int					 llen=8, ix=0, in, mlen=len;
	
	/* Hexdump */
	while(len)
	{
		if(buf[8-llen] < 16)
		{
			num[0]='0';
			in=1;
		}
		else in=0;
		itoa(buf[8-llen], &(num[in]), 16);
		strcat(num, " ");
		strcpy(&(lin[ix]), num);
		--len;
		--llen;
		ix+=3;
	}
	/* Bis tabpos auffllen */
	while(llen--)
		strcat(lin, "   ");
	
	/* Text */
	ix=24;
	len=0;
	while(len < mlen)
	{
		if(buf[len] < 32)
			lin[ix++]='.';
		else
			lin[ix++]=buf[len];
		++len;
	}

	while(len++ < 8)
		lin[ix++]=' ';
	lin[ix]=0;

	Fwrite(h, 24+8, lin);
	Fwrite(h, 2, "\r\n");
}

void out1(int h, long len, uchar *buf)
{
	int llen;
	
	while(len > 0)
	{
		if(len > 8) llen=8;
		else llen=(int)len;
		out_line(h, llen, buf);
		len-=8;
		buf+=8;
	}
}

void out2(int h, long len, uchar *buf)
{
	int llen;
	
	while(len > 0)
	{
		if(len > 8) llen=8;
		else llen=(int)len;
		/* Tab auf 2. Spalte */
		Fwrite(h, 34, "                                  ");
		out_line(h, llen, buf);
		len-=8;
		buf+=8;
	}
}


int open_aux(char *path, long baud)
{
	long hd, var, var2;
	int	 hdi;
	
	hd=Fopen(path, FO_RW);
	if(hd < 0)
		return((int)hd);

	hdi=(int)hd;	
	
	/* Parameter setzen */
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0) return((int)hd);
	
	var=baud;
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0) return((int)hd);

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0) return((int)hd);

	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;
	var2=TF_1STOP|TF_8BIT;
	if(baud != 9600)
		var2|=T_RTSCTS;
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0) return((int)hd);

	return(hdi);
}
