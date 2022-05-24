/*
 *		PLAY AVI v0.1
 *		(c) 1994 Martin Griffiths
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include "avi.h"

extern LONG Is_AVI_File(char *);
extern long go();
extern long Save_Rez();
extern long Restore_Rez();
enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};
int ld_infile;
short old_vid_mode;
static void *old_phy_base;
static void *old_log_base;
void *Phy_base;
void *Log_base;
int montype;
extern void SETVGA();
extern void SETTV();

#define SCREENSIZE ( (256 + ( (long) 480*400*2)))

unsigned char SCREEN1[SCREENSIZE];
unsigned char SCREEN2[SCREENSIZE];

void wait_key(void)
{
  Cconws(" Press any key.\x0a\x0d");
  while (Cconis() !=0)  Cnecin();
  Cnecin();
}

void do_exit(int n)
{		char *error[] =	{			" No AVI file specified!\x0a\x0d",
							" Could not open file\x0a\x0d",
							" NOT a valid AVI file\x0a\x0d",
							" Sorry, PLAY AVI does not run in Mono!\x0a\x0d",
						};
		Cconws(error[n-1]);
		wait_key();
		exit(n);
}


void alloc_display(void)
{	register long i;
	register char *ptr1 = &SCREEN1[0], *ptr2 = &SCREEN2[0];
	for (i = 0; i < SCREENSIZE ; i++)
	{	*ptr1++ = 0;
		*ptr2++ = 0;
	}
	old_phy_base = ( void *) Physbase();
	old_log_base = ( void *) Logbase();
	Phy_base = (void *) ( (long) (SCREEN1+256)  & 0xffffff00);
	Log_base = (void *) ( (long) (SCREEN2+256)  & 0xffffff00);
    if ( (montype = mon_type()) == STmono)
    	do_exit(4);
	Supexec(*Save_Rez);
}

void  init_display(void)
{
	switch (montype)
	{	
		case VGAcolor:
#ifndef DEBUG
			Setscreen(Log_base,Phy_base,-1);
			SETVGA();
#endif
			break;
		
		case TVcolor:
		case STcolor:
#ifndef DEBUG
			Setscreen(Log_base,Phy_base,-1);
			SETTV();
#endif
			break;
		
	}
}


void exit_display()
{
	Vsync();
	Setscreen(old_log_base,old_phy_base,-1);
#ifndef DEBUG
	Supexec(*Restore_Rez);
#endif
	Vsync();
}

void show_fps(void)
{	static char num[] = "\33E\33f Average FPS:  .  \x0a\x0d";
	extern long start_time,end_time,frame_count;
 	long fps= (frame_count*200*100)/(end_time-start_time);
	num[17]=(fps/1000) + '0';
	fps %= 1000;	
	num[18]=(fps/100) + '0';
	fps %= 100;	
	num[20]=(fps/10) + '0';
	fps %= 10;	
	num[21]=fps + '0';
	Cconws(num);
	wait_key();
}

#define REGISTERED

int main(int argc,char *argv[])
{ 
  void *old_stack;
  long flength,res;
  Cconws("\33E\33f PLAY AVI v0.1\x0a\x0d");
#ifndef REGISTERED
  Cconws(        " (Unregistered Unoptimised Version.)\x0a\x0d");
  Cconws(        " (c) 1994 Martin GRIFFiths\x0a\x0d");
  delay(5000l);  
#else
  Cconws(        " (Registered Optimised Version).\x0a\x0d");
  Cconws(        " (c) 1994 Martin GRIFFiths\x0a\x0d");
#endif

  if (argc == 1)
  	do_exit(1);

  switch (Is_AVI_File(argv[1]))
  { 	case FALSE:
  			do_exit(3);
		case XA_NOFILE:
  			do_exit(2);
  		default:
  		case TRUE:
  			break;
  }
  
  alloc_display();
  
  return 0;
}

