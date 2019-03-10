/*
	   heythere.c

           written by:
		Randy Hosler    26 SEP 1990
		randyh@hpsadpk

	   adapted from code written by:
		Steve Bate, November 1986
		ARPA: smb.mdc@office-1.arpa
	        AURA BBS: (314) 928-0598  (ST BBS, 20 Meg of downloads)
*/

#include <stdio.h>
#include <osbind.h>

main (argc,argv)
int argc;
char *argv[];
{
    long base;
    
    base = Pexec(3, "stspeech.tos", NULL, NULL);    
    if (base < 0) exit(1);

    speak("hay there, world", base);
}


/* speak function - takes pointer to char for text to speak 
   and long for base address of stspeech.tos                */

long _STKSIZ = 4096L;

char rts[2] = {0x4e,0x75};

speak(speechin, base)
char *speechin;
long base;
{
    register char *program,*buffer;

    program = (char *)(base + 0x100);

    strncpy(program + 0x0e,rts,2);
    strncpy(program + 0x6c,rts,2);

    buffer = program + 0x6eee;

    strcpy(buffer+2, speechin);
       *buffer = 0xfe;
       *(buffer+1) = (char)strlen(buffer+2)-1;

       /* 
          STSPEECH will respeak the last line if the current
          input line is a '\n'. The '\n' is replaced by a 
	  space to defeat this redundant speech on double spaced
          files.
       */

       if (!*(buffer+1)) strncpy(buffer+1,"\1 \0",3);

       asm("movem.l	a4-a6,-(sp)");
       asm("move.l	a3,-(sp)");
       asm("jsr	50(a3)");
       asm("move.l	(sp),a3");
       asm("jsr	136(a3)");
       asm("move.l	(sp)+,a3");
       asm("movem.l	(sp)+,a4-a6");

       buffer = program + 0x6eee;

}
   
    
