/*
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <tos.h>
#define GLOBAL
#include "global.h"

/*
 *	Init decoder  (force MPEG-1 parameters)
 */

void initdecoder(void)
{
  mb_width = (horizontal_size+15)/16;
  mb_height = (vertical_size+15)/16;
  coded_picture_width = 16*mb_width;
  coded_picture_height = 16*mb_height;
  lumframe = (unsigned char *)calloc(1,(long) coded_picture_width*coded_picture_height);
  chromframe = (unsigned char *)calloc(1,(long) coded_picture_width*coded_picture_height/2);
  init_mb_addr_inc();
  init_display();
}

void go(void)
{ int first = 1; 
  do
  { lseek(ld_infile,0l,0);
    initbits();
    while (getheader())
    {	
	  	if (first)
		{	initdecoder();
			first = 0;
		}
    	if (Cconis() != 0)
		  return;
        getpicture();
    }
  }
  while (1);
}

static char buffer[16000];	

int main(int argc,char *argv[])
{ 
  void *old_stack;
  long xav,yav;

  old_stack =(void *) Super(0); 
  (void) Dsp_Lock();

  init_biggie();
  while(Cconis() != 0);
  Bconout( 2,27 );
  Bconout( 2,'E' );
  Bconout( 2,27 );
  Bconout( 2,'f' );
  puts("        PLAYMPEG v0.4\x9e      ");
  puts("        by Martin GRIFFiths 1994");
  (void) Dsp_Available(&xav,&yav);
  (void) Dsp_Reserve(xav,yav);
  if  (Dsp_LoadProg("PLAYMPEG.LOD",(int) Dsp_RequestUniqueAbility(),&buffer[0]) < 0)
  {    		puts("        Cound not open PLAYMPEG.LOD DSP Module");
		puts("        Press any key.");
	  	Cnecin();
		exit(1);
  }
  if ((ld_infile=open(argv[1],O_RDONLY))<0)
  { 	puts("        Could not open MPEG file");
	puts("        Press any key.");
  	Cnecin();
	exit(1);
  }


  puts("        Press any key.");
  Cnecin();

  initbits();
  startcode();
  if (showbits(32) != SEQ_START_CODE)
  {  puts("This not a valid MPEG system or video stream\n");
     exit(1);  
  }

  go();	

  close(ld_infile);
  exit_display();
  Dsp_Unlock();
  Super(old_stack);
  return 0;
}

