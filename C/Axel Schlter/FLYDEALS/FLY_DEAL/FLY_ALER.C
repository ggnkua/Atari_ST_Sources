/*
	FLY-DEAL Version 3.0 fÅr TOS 12.07.1992
	written '92 by Axel SchlÅter

	Eine neue Alertbox mit den Flydeals
*/

#include <string.h>
#include "fly_prot.h"   /* Alles was man so braucht .... */

int FLY_I0[]={
	0x0,0x0,0x0,0x0,0x0,0x700,0x0,0xF80,0x0,0xF80,0x0,0xF80,0x0,0xF80,0x0,0xF80, 
	0x0,0xF80,0x0,0xF80,0x0,0xF80,0x0,0xF80,0x79,0xEF9C,0xEFB,0xEFBC,0x1EFB,0xEFBC,
	0x1EFB,0xEF7C,0x16AA,0xAF7C,0x1EFB,0xEF7C,0xD75,0xDCBC,0x38E,0x37F8,0x1FFF,
	0xDFF8,0x1FFF,0x7FF0,0x1FFF,0xFFF0,0x1FFD,0xFFE0,0x1FFF,0xFFC0,0xFFD,0xFF80, 
	0x7FF,0xFE00,0x1FF,0xF400,0x15F,0xFC00,0x1FF,0xFC00,0x1FF,0xFC00,0x0,0x0};
int FLY_I1[]={
	0x0,0x0,0x1F,0xFE00,0x7F,0xFF80,0xFF,0xFFC0,0x1FF,0xFFE0,0x1F8,0x7E0,0x1F0,
	0x3E0,0x1F0,0x3E0,0xE0,0x3E0,0x0,0x7C0,0x0,0xFC0,0x0,0x1F80,0x0,0x3F00,0x0,
	0x7E00,0x0,0xFC00,0x1,0xF800,0x3,0xF000,0x3,0xE000,0x7,0xC000,0x7,0xC000, 
	0x7,0xC000,0x7,0xC000,0x7,0xC000,0x3,0x8000,0x0,0x0,0x0,0x0,0x0,0x0,0x7,0xC000, 
	0xF,0xE000,0xF,0xE000,0x7,0xC000,0x0,0x0};
int FLY_I2[]={
	0x7F,0xFE00,0xC0,0x300,0x1BF,0xFD80,0x37F,0xFEC0,0x6FF,0xFF60,0xDFF,0xFFB0, 
	0x1BFF,0xFFD8,0x37FF,0xFFEC,0x6FFF,0xFFF6,0xDFFF,0xFFFB,0xB181,0x860D,0xA081,0x205, 
	0xA4E7,0x3265,0xA7E7,0x3265,0xA3E7,0x3265,0xB1E7,0x3205,0xB8E7,0x320D,0xBCE7,0x327D, 
	0xA4E7,0x327D,0xA0E7,0x27D,0xB1E7,0x867D,0xBFFF,0xFFFD,0xDFFF,0xFFFB,0x6FFF,0xFFF6, 
	0x37FF,0xFFEC,0x1BFF,0xFFD8,0xDFF,0xFFB0,0x6FF,0xFF60,0x37F,0xFEC0,0x1BF,0xFD80, 
	0xC0,0x300,0x7F,0xFE00};

BITBLK  fly_bitblk []={FLY_I0,4,32,0,0,1,FLY_I1,4,32,0,0,1,FLY_I2,4,32,0,0,1};
OBJECT  fly_object []={
-1, 1,13, G_BOX, LASTOB,OUTLINED, 0x21100L, 0,0, 44,9,
5 , 2, 4, G_BOX,   NONE,NORMAL, 0xFF0100L,2,1,5,2,
3 ,-1,-1, G_IMAGE, HIDETREE,NORMAL,(long)&fly_bitblk[0],0,0,4,2,
4 ,-1,-1, G_IMAGE, HIDETREE,NORMAL,(long)&fly_bitblk[1],0,0,4,2,
1 ,-1,-1, G_IMAGE, HIDETREE,NORMAL,(long)&fly_bitblk[2],0,0,4,2,
6 ,-1,-1, G_STRING,HIDETREE,NORMAL,(long)"111111111111111111111111111111",9,1,30,1,
7 ,-1,-1, G_STRING,HIDETREE,NORMAL,(long)"111111111111111111111111111111",9,2,30,1,
8 ,-1,-1, G_STRING,HIDETREE,NORMAL,(long)"111111111111111111111111111111",9,3,30,1,
9 ,-1,-1, G_STRING,HIDETREE,NORMAL,(long)"111111111111111111111111111111",9,4,30,1,
10,-1,-1, G_STRING,HIDETREE,NORMAL,(long)"111111111111111111111111111111",9,5,30,1,
11,-1,-1, 0x121A,  HIDETREE|0x5, NORMAL,(long)"1234567890",2,7,12,1,
12,-1,-1, 0x121A,  HIDETREE|0x5, NORMAL,(long)"1234567890",16,7, 12,1,
13,-1,-1, 0x121A,  HIDETREE|0x5, NORMAL,(long)"1234567890",30,7, 12,1,
0 ,-1,-1, 0x1119,  0x60,OUTLINED, 0xFF1101L, 42,0, 2,1};

int FLY_alert(int DefButt,char Strings[])
{
	long *memsize;
	char *teil,SaveStr[200],
		 *text,*buttons;
	int  pos=0,image,exit;

	memcpy((void *)SaveStr,(void *)Strings,strlen(Strings));

	image  =atoi(strtok(SaveStr,(char*)"}")+1);
	text   =strtok(NULL,(char*)"}");
	buttons=strtok(NULL,(char*)"}");
	
	teil=strtok(text,(char*)"|")+1;
	while(teil!=NULL)
	{
		ALERT[TEXT1+pos].ob_flags&=~HIDETREE;
		ALERT[TEXT1+pos].ob_spec.free_string=teil;
		teil=strtok(NULL,(char*)"|");
		pos++;
	}
		
	pos=0;
	teil=strtok(buttons,(char*)"|")+1;
	while(teil!=NULL)
	{
		ALERT[BUTTON1+pos].ob_flags&=~HIDETREE;
		ALERT[BUTTON1+pos].ob_spec.free_string=teil;
		teil=strtok(NULL,(char*)"|");
		pos++;
	}
	
	if(image>0)
		{image--;ALERT[IACHTUNG+image].ob_flags&=~HIDETREE;}
	ALERT[BUTTON1+DefButt].ob_flags|=DEFAULT;
	
	memsize=FLY_deal_start(ALERT);
	
	exit=FLY_deal_do(0,memsize,RADIONOEXIT);
 	FLY_deal_stop(memsize);
	ALERT[exit].ob_state=NORMAL;
	
	for(pos=2;pos<13;pos++)
		ALERT[pos].ob_flags|=HIDETREE;
	ALERT[BUTTON1+DefButt].ob_flags&=~DEFAULT;
	ALERT[IACHTUNG+image].ob_flags|=HIDETREE;

	return(exit-10);
}

/*
	Prgrammteil zum Abfragen des Cookie's fÅr einen 
	Groûbildschirmsimulator
*/

int getcookie(long cookie,long *p_value)
{
	long oldstack,*cookiejar;
	
	oldstack=Super(0L);
	cookiejar=*((long **)0x5a0l);
	Super((void *)oldstack);
	
	if(!cookiejar) return(ERROR);
	
	do
	{
		if(cookiejar[0]==cookie)
		{
			if(p_value) *p_value=cookiejar[1];
			return(ALLES_OK);
		}
		else
		{
			cookiejar=&(cookiejar[2]);
		}
	}while(cookiejar[-2]);
	
	return(ERROR);
}	
			
int ask_for_infoscrn(int *x,int *y,int *b,int *h)
{
	INFOVSCR infoscrn;
	
	if ((getcookie(0x65534352L,(long*)&infoscrn))==ALLES_OK)
	{
		*x=infoscrn.X;	*y=infoscrn.Y;
		*b=infoscrn.W;	*h=infoscrn.H;
	
		return(ALLES_OK);
	}
	return(ERROR);
} 