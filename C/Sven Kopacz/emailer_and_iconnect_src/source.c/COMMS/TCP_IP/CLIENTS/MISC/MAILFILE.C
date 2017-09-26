/* mailfile */
/* send a file as mail */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <sockinit.h>
#include <socket.h>
#include <sfcntl.h>
#include <types.h>
#include <sockios.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <atarierr.h>
#include <sockerr.h>
#include <ext.h>

#define TOUT_SEK 300
#define MAL_BLOCK 8192

/* Console output */
#define Con(a) Cconws(a)
#define crlf Con("\r\n")

char	from[256],to[256],subj[256];
int		make_header=1, low_ascii=1, high_warning=1;
uchar	*buf, *outbuf=NULL;

void request(ulong ip, int port, char *msg);

void numout(long num)
{
	char nus[32];
	Con(ltoa(num, nus, 10));
}

long msglen(char *msg)
{
	long l=0;
	while(msg[l++]);
	return(l-1);
}

void help(void)
{
	Con("usage:");crlf;
	Con("mailfile {-<o> }<file>[ <from>[ <to>[ <subject>]]]");crlf;
	Con("  -<o>     Options:");crlf;
	Con("           -h supress header generation");crlf;
	Con("           -8 allow 8-bit ascii");crlf;
	Con("           -7 force 7-bit ascii");crlf;
	Con(" <file>    the file to send");crlf;
	Con(" <from>    your eMail-adress");crlf;
	Con(" <to>      the recipients address");crlf;
	Con(" <subject> the subject");crlf;
	Con("Mailfile will prompt you for omitted parameters.");crlf;
	crlf;
	Con("If -h ist not set, a header containing the Date (asctime),");crlf;
	Con("From, To and Subject will be generated.");
	Con("If -h is set, <subject> will be ignored and mailfile won\'t");crlf;
	Con("ask for it if omitted.");crlf;
	Con("If -8 is set, <file> won\'t be scanned.");crlf;
	Con("If -7 is set, characters larger than Ascii 127 in <file>");crlf;
	Con("will silently be replaced by the space character (Ascii 32).");crlf;
	Con("If -7 is not set and <file> contains Ascii > 127, mailfile");crlf;
	Con("will also replace them but ask you, if you still want to");crlf;
	Con("send the file.");crlf;
}

int get_reply(int s)
{/* Return class of reply, e.g. 250=class 2 */
	int			ret, reply=-1;
	char		buf[501];
	fd_set	mask;
	timeval	tout;

	/* Wait for TOUT_SEK seconds for reply, try every second */
	tout.tv_sec=TOUT_SEK;
	tout.tv_usec=0;

	sfcntl(s,F_SETFL,O_NDELAY);
	
	do
	{
		FD_ZERO(&mask);
		FD_SET(s, &mask);
		ret=select(s+1, &mask, NULL, NULL, &tout);
		if(ret==0)
		{
			Con("no reply.");crlf;
			sclose(s);
			return(-1);
		}
		
		ret=(int)sread(s, buf, 500);
		if(ret < 0)
		{
			Con("error receiving message: ");
			switch(ret)
			{
				case ENOTCONN: Con("connection broke down.");break;
				case EPIPE: Con("connection closing.");break;
				case ENSMEM: Con("insufficient memory.");break;
				default: numout(ret);
			}
			shutdown(s,2);
			sclose(s);
			return(-1);
		}
		
		if(ret==0)
		{
			Con("received empty reply.");crlf;
			shutdown(s,2);
			sclose(s);
			return(-1);
		}
		
		if(reply==-1)
			reply=atoi(buf);
			
		/* Show message */
		buf[ret]=0;
		Con(buf);
	}while((buf[ret-1]!=10)&&(buf[ret-2]!=13));
	return(reply/100);
}

int send_a_line(int s, char *msg, int cr, int echo)
{
	int ret;
	long msglength=msglen(msg);
	int	 wblock=10000;
	
	if(echo)
		Con(msg);
	

	while(msglength)
	{	
		if(msglength < wblock)
			wblock=(int)msglength;
		msglength-=wblock;
		ret=swrite(s, msg, wblock);
		msg+=wblock;
		if(ret < 0)
		{
			Con("error sending message: ");
			switch(ret)
			{
				case ENOTCONN: Con("connection broke down.");break;
				case EPIPE: Con("connection closing.");break;
				case ENSMEM: Con("insufficient memory.");break;
				default: numout(ret);
			}
			shutdown(s,2);
			sclose(s);
			return(-1);
		}
	}
	
	if(cr)
	{
		if(echo)
			crlf;
		ret=swrite(s, "\r\n", 2);
		if(ret < 0)
		{
			Con("error sending message: ");
			switch(ret)
			{
				case ENOTCONN: Con("connection broke down.");break;
				case EPIPE: Con("connection closing.");break;
				case ENSMEM: Con("insufficient memory.");break;
				default: numout(ret);
			}
			shutdown(s,2);
			sclose(s);
			return(-1);
		}
	}
	return(0);
}

int send_string(int s, char *msg, int cr)
{
	return(send_a_line(s,msg,cr,1));
}

void Conperc(long todo, long done)
{
	long perc;
	
	/* Step back 4 */
	Con("\33D\33D\33D\33D");
	/* Calc percent */
	perc=(done*100)/todo;
	numout(perc);
	Con("%");
	/* Step ahead */
	if(perc<100)
		Con(" ");
	if(perc<10)
		Con(" ");
}

int prepare(int s, char *out)
{/* Write to one block and send whenever full */
	#define SBUFSIZ 4096
	static char block[SBUFSIZ];
	static long used=0;
	
	if(out==NULL) /* flush buffer */
	{
		if(used==0) return(0);
		return(send_a_line(s,block,0,0));
	}
	if(used+strlen(out)+3 > SBUFSIZ)
	{/* Send and clear */
		if(send_a_line(s,block, 0, 0)<0) return(-1);
		used=0;
	}

	if(used==0) block[0]=0;
	
	if(out[0]=='.')
	{	strcat(block,"."); ++used;}
	strcat(block,out);
	used+=strlen(out);
	strcat(block,"\r\n");
	used+=2;
	return(0);
}

int send_message(int s, long len)
{
	long lstart, lpos;
	char	*tstr;
	time_t	tim;
	time(&tim);
	
	if(make_header)
	{
		if(send_string(s,"Date: ",0)<0)return(-1);
		tstr=ctime(&tim);
		/* Cut off traling \n */
		tstr[strlen(tstr)-1]=0;
		if(send_string(s,tstr,1)<0) return(-1);
		if(send_string(s,"From: ",0)<0)return(-1);
		if(send_string(s,from,1)<0)return(-1);
		if(send_string(s,"Subject: ",0)<0)return(-1);
		if(send_string(s,subj,1)<0)return(-1);
		if(send_string(s,"To: ",0)<0)return(-1);
		if(send_string(s,to,1)<0)return(-1);
		if(send_string(s,"\r\n",0)<0)return(-1);
	}
		
	Con("Sending mail...0%  ");
	lstart=lpos=0;
	while(lpos < len)
	{
		if((buf[lpos]==13)||(buf[lpos]==10))
		{
			buf[lpos++]=0;
			if(prepare(s,(char*)&(buf[lstart]))<0)
			{crlf; return(-1);}
			while((lpos<len)&&((buf[lpos]==13)||(buf[lpos]==10)))++lpos;
			lstart=lpos;
			Conperc(len, lpos);
		}
		else
			++lpos;
	}
	Con("\33D\33D\33D\33D100%");
	crlf;
	if(lstart < len)
	/* Didn't stop with CR/LF */
	if(prepare(s,(char*)&(buf[lstart]))<0)
	{crlf; return(-1);}
	/* Flush buffer */
	if(prepare(s,NULL) < 0){crlf;return(-1);}
	Con("ok.");crlf;
	return(0);
}


int prepare_old(char *out)
{/* Write all in one block and send when finished */
	static long bufsiz=0, is_siz=0;
	
	bufsiz+=strlen(out)+2;
	if(out[0]=='.')++bufsiz;
	
	if(bufsiz > is_siz)
		is_siz=bufsiz+MAL_BLOCK;
		
	if(outbuf==NULL)
	{	outbuf=malloc(is_siz); outbuf[0]=0;}
	else
		outbuf=realloc(outbuf, is_siz);

	if(outbuf==NULL) return(-1);
	
	if(out[0]=='.')
		strcat((char*)outbuf,".");
	strcat((char*)outbuf,out);
	strcat((char*)outbuf,"\r\n");
	return(0);
}
int send_message_old(int s, long len)
{
	long lstart, lpos;
	char	*tstr;
	time_t	tim;
	time(&tim);
	
	if(make_header)
	{
		if(send_string(s,"Date: ",0)<0)return(-1);
		tstr=ctime(&tim);
		/* Cut off traling \n */
		tstr[strlen(tstr)-1]=0;
		if(send_string(s,tstr,1)<0) return(-1);
		if(send_string(s,"From: ",0)<0)return(-1);
		if(send_string(s,from,1)<0)return(-1);
		if(send_string(s,"Subject: ",0)<0)return(-1);
		if(send_string(s,subj,1)<0)return(-1);
		if(send_string(s,"To: ",0)<0)return(-1);
		if(send_string(s,to,1)<0)return(-1);
		if(send_string(s,"\r\n",0)<0)return(-1);
	}
		
	Con("preparing mail...0%  ");
	lstart=lpos=0;
	while(lpos < len)
	{
		if((buf[lpos]==13)||(buf[lpos]==10))
		{
			buf[lpos++]=0;
			if(prepare_old((char*)&(buf[lstart]))<0)
			{Con("Insufficient memory");crlf; return(-1);}
			while((lpos<len)&&((buf[lpos]==13)||(buf[lpos]==10)))++lpos;
			lstart=lpos;
			Conperc(len, lpos);
		}
		else
			++lpos;
	}
	Con("\33D\33D\33D\33D100%");
	crlf;
	if(lstart < len)
	/* Didn't stop with CR/LF */
	if(prepare_old((char*)&(buf[lstart]))<0)
	{Con("Insufficient memory");crlf; return(-1);}
	Con("Sending mail...");
	if(send_a_line(s, (char*)outbuf, 0, 0)<0) return(-1);
	Con("ok.");crlf;
	return(0);
}

void sendfile(ulong ip, int port, long flen)
{
	sockaddr_in sad;
	int	s, ret;

	s=socket(AF_INET, SOCK_STREAM, 0);

	if(s < 0)
	{
		Con("can\'t open socket.\r\n");
		return;
	}

	/* connect to remote host */
	Con("[connecting...");
	sad.sin_family=AF_INET;
	sad.sin_port=port;
	sad.sin_addr=ip;
	ret=connect(s, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		Con("not successfull]");crlf;
		switch(ret)
		{
			case EADDRINUSE: Con("Connection in use."); break;
			case ENSMEM: Con("Insufficient memory.");break;
			case ENETDOWN: Con("No socket server active.");break;
			case ETIMEDOUT: Con("timeout");break;
			case ECONNREFUSED: Con("refused");break;
			default: Con("error ");numout(ret);Con(" occured.");
		}
		crlf;
		sclose(s);
		return;
	}
	Con("ok]");crlf;
	
	/* Wait for OK response */
	if(get_reply(s)!=2){sclose(s); return;} /* 220 expected */
	
	/* Send the message */
	if(send_string(s,"MAIL FROM:",0)<0) return;
	if(send_string(s,from,1)<0) return;
	if(get_reply(s)!=2){shutdown(s, 2);sclose(s); return;} /* 250 */
	
	if(send_string(s,"RCPT TO:",0)<0) return;
	if(send_string(s,to,1)<0) return;
	if(get_reply(s)!=2){shutdown(s, 2);sclose(s); return;} /*250/51*/
	
	if(send_string(s,"DATA",1)<0) return;
	if(get_reply(s)!=3){shutdown(s, 2);sclose(s); return;} /* 354 */

	if(send_message(s,flen)<0) return;
	crlf;
	
	if(send_string(s,"\r\n.\r\n",0)<0) return;
	if(get_reply(s)!=2){shutdown(s, 2);sclose(s); return;} /* 250 */

	if(send_string(s,"QUIT",1)<0) return;
	get_reply(s);
	shutdown(s,2);
	sclose(s);
}

void prompt(char *req, char *dst)
{
	Con(req);
	if(gets(dst)==NULL)	/* user wants to abort */
	{crlf;Con("mailfile aborted.");crlf;exit(0);}
	crlf;
}

long scanfile(char *path)
{
	int fh=(int)Fopen(path, FO_READ);
	long	len, ret;
	
	if(fh < 0){Con("Can\'t open ");Con(path);crlf;exit(1);}
	len=Fseek(0,fh,2);
	if(len < 0){Fclose(fh);Con("error ");numout(len);Con(" on Fseek");crlf;exit(1);}
	ret=Fseek(0,fh,0);
	if(ret < 0){Fclose(fh);Con("error ");numout(len);Con(" on Fseek");crlf;exit(1);}
	buf=malloc(len+1);
	if(buf==NULL){Fclose(fh);Con("insufficient memory.");crlf;exit(1);}
	ret=Fread(fh, len, buf);
	Fclose(fh);
	if(ret < 0){free(buf);Con("error ");numout(len);Con(" on Fread");crlf;exit(1);}
	if(ret < len){free(buf);Con("Can\'t read all data in file");crlf;exit(1);}

	buf[len]=0;
	
	if(low_ascii)
	{
		fh=0;
		for(ret=0; ret < len; ++ret)
			if(buf[ret] & 128) {buf[ret]=32; fh=1;}
		
		if(fh && high_warning)
		{
			Con("Characters > 127 in file where replaced by space.");crlf;
			Con("Send file anyway? (y/n)");
			if((getche() & 95)=='N'){free(buf); exit(0);}
			crlf;
		}
	}
	return(len);
}

void main(int argc, char *argv[])
{
	int			d;
	long		flen;
	char		*host;
	hostent	*he;
	servent	*se;

	Con("Mail File v0.1 12.02.1997 Sven Kopacz");crlf;

	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				Con("rtcp: Sockets not installed.\r\n");
				Con("Put SOCKETS.PRG in the AUTO-folder.\r\n");
			break;
			case SE_NSUPP:
				Con("rtcp: SOCKETS.PRG is too old.\r\n");
			break;
		}
		return;
	}
	
	/* Help needed? */
	if(argc < 2)
	{
		help();
		return;
	}

	d=1;
	while(((char*)argv[d])[0]=='-')
	{
		switch(((char*)argv[d])[1])
		{
			case 'h': case 'H':
				make_header=0;
			break;
			case '8':
				low_ascii=0;
			break;
			case '7':
				high_warning=0;
			break;
			default:
				help();
				return;
		}
		++d;
	}

	flen=scanfile((char*)argv[d++]);
	if(argc > d) strcpy(from,(char*)argv[d++]);
	else prompt("From:", from);
	if(argc > d) strcpy(to,(char*)argv[d++]);
	else prompt("To:", to);
	if(argc > d) strcpy(subj,(char*)argv[d]);
	else prompt("Subject:", subj);
	
	/* Destination host */
	host=strchr(to, '\@');
	if(host==NULL)
	{
		Con("missing \'\@\' in destination address");
		return;
	}

	++host;	/* point to char after @ */
	
	he=gethostbyname(host);
	if(he==NULL)
	{
		Con("host ");
		Con((char*)argv[1]);
		Con(" was not found.");
		crlf;
		return;
	}

	if(!he->h_addr_list[0])
	{
		Con("host ");Con((char*)argv[1]);
		Con(" was not resolved to an IP address.");
		crlf;
		return;
	}
	
	/* number of port */
	se=getservbyname("smtp", "tcp");
	if(se==NULL)
	{
		Con("service \'smtp\' unknown.");
		crlf;
		return;
	}
		
	Con("[");Con(host);Con("=");
	Con(inet_ntoa(*(ulong*)(he->h_addr_list[0])));
	Con("]");crlf;
	sendfile(*(ulong*)(he->h_addr_list[0]), se->s_port, flen);
	crlf;
	if(outbuf!=NULL) free(outbuf);
	free(buf);
}

