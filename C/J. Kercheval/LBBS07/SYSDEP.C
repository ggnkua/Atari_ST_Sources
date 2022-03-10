/* 
 *	BBS Level Zero - System Dependant Functions
 *	(LazyBBS Project)
 *
 *	Public Domain: may be copied and sold freely
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef UNIX
#include <termios.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#define RZ_PROG		"rz"
#define SZ_PROG		"sz"
#endif

#ifdef ATARI
#include <ext.h>	/* sleep */
#define RZ_PROG		"rz.ttp"
#define SZ_PROG		"sz.ttp"
#endif

#include "bbs.h"
#include "sysdep.h"

/*
 *	DOWNLOAD routines
 */
 
#ifdef ATARI

int z_upload(char *a)
{
	char temp[BBSSTR];
	int ret;
	
	if(getcwd(temp,BBSSTR))
	{
		chdir(a);
		ret=forklp(RZ_PROG,RZ_PROG,NULL);
		if(!ret)
			ret=wait();
		chdir(temp);
	}
	return ret;
}

int z_download(char *a)
{
	int ret;
	
	ret=forklp(SZ_PROG,SZ_PROG,a,NULL);
	if(!ret)
		ret=wait();
	return ret;
}

#endif

/*
 *	ATARI ST Low level routines
 */

#ifdef ATARI

#include <osbind.h>

#ifndef WORD
#define WORD short
#endif /* WORD */

#define AUXDEVICE 1
#define CONDEVICE 2

int dupeio=0;
int aux_device=AUXDEVICE;

int sysdep_dupeio(char *s)
{
	if(atoi(s)>1)
		aux_device=atoi(s);
	dupeio++;
	sysdep_flushin();
	return BBSOK;
}

void sysdep_flushin(void )
{
	while(Bconstat(CONDEVICE)) Bconin(CONDEVICE);
	if(dupeio)
		while(Bconstat(aux_device)) Bconin(aux_device);
}

/* get char */

int sysdep_getchar(unsigned char *ret)
{
	if(Bconstat(CONDEVICE))
	{	
		*ret=(unsigned char) Bconin(CONDEVICE);
		return BBSOK;
	}
	if(dupeio)
	{
		if(Bconstat(aux_device))
		{
			*ret=(unsigned char) Bconin(aux_device);
			return BBSOK;
		}
	}
	
	return BBSFAIL;
}

void sysdep_putchar(unsigned char truc)
{
	while(Bcostat(CONDEVICE)==0) ; /* wait for readyness */
	Bconout(CONDEVICE,(WORD) truc);
		
	if(dupeio)
	{
		while(Bcostat(aux_device)==0)
		{
			if(sysdep_carrier()) /* don't lock */
				return;
		}
		
		Bconout(aux_device,(WORD) truc);
	}
}

/* watch carrier */

int sysdep_carrier() /* Steve Yellington */
{
    void *ssp;
    register WORD *mfp, status;
    mfp = ((WORD *) 0xFFFFFA00L);        /* base address of MFP */
    ssp = Super(NULL);                  /* enter supervisor mode */
    status = *mfp;                      /* get MFP status */
    Super(ssp);                         /* return to user mode */
    return((int)status & 0x0002); 			/* check for carrier */
}

/* hang up */

void sysdep_hangup(void )
{
	Ongibit(0x10);	  	/* dtr off */
	sleep(1);	 		/* wait one second */
	Offgibit(0xEF);    	/* dtr on */
}

#endif /* ATARI */

/*
 * 	UNIX sysdep io 
 */
  
#ifdef UNIX
  
int unix_line=-1;
  
int z_download(char *s)
{
 	char str[200];
 
 	sprintf (str, "%s %s", SZ_PROG, s);
 	return system (str);
}
 
int z_upload(char *s)
{
 	char str[200];
 
 	sprintf (str, "%s %s", RZ_PROG, s);
 	return system (str);
}
 
int sysdep_dupeio(char *device)
{
  	struct termios tios;
  	
  	unix_line=open(device,O_RDWR|O_NDELAY,0);
  	if(unix_line<0)
 		return BBSFAIL;
 	tcgetattr(unix_line,&tios);
 	tios.c_iflag|= IGNBRK;
 	tios.c_cflag|= B0 | CS8 | CREAD | CLOCAL | CRTSCTS;
 	tios.c_lflag|= NOFLSH+ECHO;
 	tios.c_lflag&= ~(ICANON+ECHOCTL);
 
  	if(tcsetattr(unix_line,TCSANOW,&tios))
  	{
  		perror("lazybbs - tcsetattr");
  		return BBSFAIL;
  	}
 	out_string("coucou\n");
 	return BBSOK;
}
  
void sysdep_flushin(void)
{
	int nbchar;
 	char c;
 	
 	if (unix_line!=-1) {
 		if(ioctl(unix_line,FIONREAD,&nbchar)<0)
 			perror("lazybbs - fionread");
 		while (nbchar--)
 			read(unix_line,&c,1);
 	}
 	if(ioctl(0,FIONREAD,&nbchar)<0)
 		perror("lazybbs - fionread");
 	while (nbchar--)
 		read(0,&c,1);
}
  
int sysdep_getchar(unsigned char *ret)
{
  	int nbchar=0;
  	
  	if(unix_line!=-1)
  	{
		if(ioctl(unix_line,FIONREAD,&nbchar)<0)
  			perror("lazybbs - fionread");	
  		if(nbchar>0)
 			if(read(unix_line,ret,1)==1) {
 				putchar(*ret); /* echo sur ligne locale */
  				return BBSOK;
 			}
  	}
 
 	/* if no unix_line or no char, check stdin */
 	
 	if(ioctl(0,FIONREAD,&nbchar)<0)
 		perror("lazybbs - fionread");	
 	if(nbchar>0)
 		if(read(0,ret,1)==1) {
 			if(unix_line!=-1)
 				write(unix_line,ret,1);	/* echo sur distant */
  			return BBSOK;
 		}
  	
  	return BBSFAIL;
}

void sysdep_putchar(unsigned char truc)
{
	putchar(truc);
	if(unix_line!=-1)
	{
		/* fixme? never block? */
		if(write(unix_line,&truc,1)==-1)
			perror("lazybbs - write sysdep error");
	}
}

int sysdep_carrier(void )
{
	int tmp=0;
	
	if(unix_line!=-1)
	{
		if(ioctl(unix_line,TIOCMGET,&tmp)<0)
			return 0;
		return ( (tmp & TIOCM_CD)==0 );
	}
	return 1;
}

void sysdep_hangup(void )
{
	int set_stat_line;
	
	if(unix_line!=-1)
	{
		set_stat_line=TIOCM_DTR;
		if(ioctl(unix_line,TIOCMBIC,&set_stat_line)<0)
			perror("lazybbs - dtr off");	
		sleep(1);
		set_stat_line=TIOCM_DTR;
		if(ioctl(unix_line,TIOCMBIS,&set_stat_line)<0)
			perror("lazybbs - dtr on");
	}
}

#endif /* UNIX */

/* eof */