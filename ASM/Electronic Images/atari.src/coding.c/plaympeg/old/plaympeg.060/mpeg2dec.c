/*
 *		PLAYMPEG v0.6
 *		(c) 1994 Martin Griffiths
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <ext.h>

/*#define DEBUG*/

enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};

int ld_infile;
extern char *ld_rdptr;
short old_vid_mode;
static void *old_phy_base;
static void *old_log_base;
void *Phy_base;
void *Log_base;
int montype;
long	bitlength;
extern void SETVGA();
extern void SETTV();

#define SCREENSIZE ( (256 + ( (long) 320*256*2)))

unsigned char SCREEN1[SCREENSIZE];
unsigned char SCREEN2[SCREENSIZE];

void wait_key(void)
{
  Cconws(" Press any key.\x0a\x0d");
  while (Cconis() !=0)  Cnecin();
  Cnecin();
}

void do_exit(int n)
{		char *error[] =	{	" Cound not open PLAYMPEG.LOD DSP Module\x0a\x0d",
							" Could not open MPEG file\x0a\x0d",
							" NOT a valid MPEG file\x0a\x0d",
							" Sorry, PLAYMPEG does not run in Mono!\x0a\x0d",
							" Read error, reading MPEG file!\x0a\x0d"
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
	old_vid_mode = Vsetmode(-1);
	old_phy_base = ( void *) Physbase();
	old_log_base = ( void *) Logbase();
	Phy_base = (void *) ( (long) (SCREEN1+256)  & 0xffffff00);
	Log_base = (void *) ( (long) (SCREEN2+256)  & 0xffffff00);
    if ( (montype = mon_type()) == STmono)
    	do_exit(4);
	Setscreen(Log_base,Phy_base,-1);
}

void  init_display(void)
{
	switch (montype)
	{	
		case VGAcolor:
#ifndef DEBUG
			SETVGA();
#endif
			break;
		
		case TVcolor:
		case STcolor:
#ifndef DEBUG
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
	Vsetmode(old_vid_mode);
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
extern long go();

static char buffer[16000];	

#define REGISTERED

int main(int argc,char *argv[])
{ 
  void *old_stack;
  long flength,res;
  Cconws("\33E\33f PLAYMPEG - Falcon DSP version 0.6.\x0a\x0d");
#ifndef REGISTERED
  Cconws(        " (Unregistered Grayscale ONLY Version.)\x0a\x0d");
#endif
  Cconws(        " (c) 1994 Martin GRIFFiths\x0a\x0d");
#ifndef REGISTERED
#define LODNAME "PLAYGRAY.LOD"
#else
#define LODNAME "PLAYCOLR.LOD"
#endif
  if  (Dsp_LoadProg(LODNAME,(int) Dsp_RequestUniqueAbility(),&buffer[0]) < 0)
      	do_exit(1);
  if ((ld_infile=Fopen(argv[1],FO_READ))<0)
  	 	do_exit(2);

  flength = filelength(ld_infile);
  bitlength = flength * 8;
  ld_rdptr = malloc(flength+16);
  ld_rdptr = (unsigned char *) ((long) (ld_rdptr+15) & 0xfffffff0);
  if (Fread(ld_infile,flength,ld_rdptr) != flength)
  {	Fclose(ld_infile);
  	do_exit(4);
  }
  Fclose(ld_infile);
#ifndef REGISTERED
  delay(3000l);  
#endif
  alloc_display();

  res = Supexec(*go); 
  exit_display();
  if (res)
  	do_exit(3);
  show_fps();
  
  return 0;
}

