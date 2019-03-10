/*
    SPEAK.TOS  -- Speak text from the standard input

    This program uses STSPEECH.TOS to speak text from the standard
    input. Using file indirection, text files may also be spoken even
    though the results may be somewhat unpredictable.

    THIS PROGRAM IS FOR NON-PROFIT USE ONLY!!!!!!!!! 

    This program uses two entry points into STSPEECH that allow
    speech generation under program control. The process works
    as follows...

	Load  "STSPEECH.TOS" into memory using the Mode 3 option
        of the Pexec Gemdos call. If successful, this call will
        return the address of the base page of the loaded program.
        Add 0x100 to this to get the first byte of the executable
        code. (Note: STSPEECH.TOS must be in the same directory as
	SPEAK.TOS)

	In order to disable the prompting of STSPEECH, two RTS
	instructions are placed so that two subroutines are
	created. The first starts at 0x32 bytes after the program
	address and converts text in STSPEECH's internal buffer
	to phonemes. The second at 0x88 bytes after the program
	address generates speech from the phonomes.

        Read text into the input buffer that STSPEECH uses. This
	buffer is in the format that Cconrs() uses. So the first
        byte of the buffer must be the length of the buffer (in
	this case, 0xfe). The second byte must be the length of
	input line.

	Call the subroutines for phoneme and speech generation.

        
        Note: The code may look a little convoluted due to the
	necessity of saving pointers that Megamax depends on and
	are destroyed by STSPEECH.	

        Written by:

		Steve Bate, November 1986
		ARPA: smb.mdc@office-1.arpa
	        AURA BBS: (314) 928-0598  (ST BBS, 20 Meg of downloads)

*/

#include <stdio.h>
#include <osbind.h>

long _STKSIZ = 4096L;

char rts[2] = {0x4e,0x75};

main (argc,argv)
int argc;
char *argv[];
{

    long base;
    register char *program,*buffer;

    base = Pexec(3,"stspeech.tos",NULL,NULL);
    if (base < 0) exit(1);

    program = (char *)(base + 0x100);

    strncpy(program + 0x0e,rts,2);
    strncpy(program + 0x6c,rts,2);

    buffer = program + 0x6eee;

    while(fgets(buffer+2,0xfe,stdin)) {
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
}
   
    
