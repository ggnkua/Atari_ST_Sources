/*
 *		PLAYMPEG v0.75
 *		(c) 1994/95 Martin Griffiths
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include "mpegstrm.h"

#define BUFFERSIZE (8192)

extern long go();
extern long Save_Rez();
extern long Restore_Rez();
extern char playcolr[];
extern char playgray[];
extern long playcolr_size;
extern long playgray_size;

enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};
int saved_res;

int ld_infile;
extern char *ld_rdptr;
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

void exit_display()
{
	if (saved_res)
	{	Vsync();
		Setscreen(old_log_base,old_phy_base,-1);
			Supexec(*Restore_Rez);
		Vsync();
	}
}



void wait_key(void)
{
  Cconws(" Press any key.\x0a\x0d");
  while (Cconis() !=0)  Cnecin();
  Cnecin();
}


void do_exit(int n)
{	char *error[] =	{	" Could not open MPEG file\x0a\x0d",
							" NOT a valid MPEG file\x0a\x0d",
							" Sorry, PLAYMPEG does not run in Mono!\x0a\x0d",
							" Read error, reading MPEG file!\x0a\x0d"
						};
	exit_display();
	Cconws(error[n-1]);
	wait_key();
	exit(n);
}


void Init_Buffer(void)
{	long ret;
	Fseek(0l,ld_infile,0);
 	if ((ret = Fread(ld_infile,BUFFERSIZE+4,ld_rdptr)) != BUFFERSIZE+4)
  	{ 	if (ret < 0)
  		{	do_exit(4);
  		}
		while (ret <= BUFFERSIZE)
		{	ld_rdptr[ret++] = 0x00;	
			ld_rdptr[ret++] = 0x00;
			ld_rdptr[ret++] = 0x01;	/* seq end code */
			ld_rdptr[ret++] = 0xb7;
		}
  	}	
}

void Refill_Buffer(void)
{	long ret;
	ld_rdptr[0] = ld_rdptr[BUFFERSIZE];
	ld_rdptr[1] = ld_rdptr[BUFFERSIZE+1];
	ld_rdptr[2] = ld_rdptr[BUFFERSIZE+2];
	ld_rdptr[3] = ld_rdptr[BUFFERSIZE+3];
	if ((ret = Fread(ld_infile,BUFFERSIZE,ld_rdptr+4)) != BUFFERSIZE)
 	{ 	if (ret < 0)
  		{	do_exit(4);
  		}
  		while (ret <= BUFFERSIZE)
		{	ld_rdptr[ret++] = 0x00;	
			ld_rdptr[ret++] = 0x00;
			ld_rdptr[ret++] = 0x01;	/* seq end code */
			ld_rdptr[ret++] = 0xb7;
		}
		
  	}
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
    	do_exit(3);
	Setscreen(Log_base,Phy_base,-1);
	Vsync();
	Supexec(*Save_Rez); saved_res = 1;
}

void  init_display(void)
{
	switch (montype)
	{	
		case VGAcolor:
			SETVGA();
			break;
		
		case TVcolor:
		case STcolor:
			SETTV();
			break;
		
	}
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

int registered = 1;

int main(int argc,char *argv[])
{ 
	char *dsp_code_ptr;
	long dsp_code_size,res;
	void *old_stack;
	if  (registered)
	{	dsp_code_ptr = playcolr;
		dsp_code_size = playcolr_size/3;
	} else
	{	dsp_code_ptr = playgray;
		dsp_code_size = playgray_size/3;
	}
  	Cconws("\33E\33f PLAYMPEG - Falcon DSP version 0.75.\x0a\x0d");
  	if (registered)
  	 	Cconws(        " (Registered Colour Version).\x0a\x0d");
  	else
	  	Cconws(        " (Unregistered Grayscale ONLY Version.)\x0a\x0d");
  	Cconws(        " (c) 1994,95 Martin GRIFFiths\x0a\x0d");
  	if (!registered)
	  	delay(3000l);  

	Dsp_ExecProg(dsp_code_ptr,dsp_code_size,(int) Dsp_RequestUniqueAbility());

  	if ((ld_infile=Fopen(argv[1],FO_READ))<0)
  		do_exit(1);
  	ld_rdptr = malloc(BUFFERSIZE+16+4);
  	ld_rdptr = (unsigned char *) ((long) (ld_rdptr+15) & 0xfffffff0);
 
  	alloc_display();

  	res = Supexec(*go); 
  	Fclose(ld_infile); 
  	if (res)
  		do_exit(2);

  exit_display();

  show_fps();
  
  return 0;
}

