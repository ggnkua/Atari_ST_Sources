/* MIDI Programming Tips
** by Steve Johns
** (C)Copyright 1990 by Antic Publishing, Inc.
*/

#include "osbind.h"
#include "stdio.h"

/*	If you swap the MIDI interrupt service routine as part of your program,
	you need to save the pointer to the old one so that you can restore it 
	when your program is done.  These two variables are of type "pointer 
	to function returning an integer". 
*/
int(*mvec)();		/* to hold old midivec and midisys vectors	*/
int(*msys)(); 	 	

/*	vectors will hold the pointer to the structure of system interrupt 
	vectors which is returned by Kbdvbase().
*/
kbdvecs *vectors; 	

/*	midi_buff will hold the pointer to the system MIDI buffer descriptor	*/
iorec *midi_buff;

int thruflag=0;		/*	0 for MIDI THRU off, 1 for MIDI THRU on				*/
int midithru();
#define CONSOLE 2
#define MIDI    3

main()
{
	char *oldmibuf;		/*	to save system MIDI buffer address	*/
	char *mymibuf;		/*	to hold user MIDI buffer address	*/
	int oldmsize;		/*	to save system MIDI buffer size		*/
	int mymsize;		/*	to hold user MIDI buffer size		*/
	
	char character;		/*	for user input to stop program		*/
	int  count;			/*	incoming byte counter				*/
	mymsize=32000;		/*	How about a 32k MIDI buffer?		*/
	count=0;	

 	vectors=(kbdvecs *)Kbdvbase();	/*	get pointer to system interrupt vectors	*/	
    midi_buff=(iorec *)Iorec(2);	/*  get pointer to MIDI buffer descriptor 	*/

	mvec=vectors -> midivec;		/*	save to restore on exit	*/
	msys=vectors -> midisys;		/*	save to restore on exit	*/

	oldmibuf=midi_buff->ibuf;		/* save old address of system MIDI buffer	*/
	oldmsize=midi_buff->ibufsiz;	/* save old size of system MIDI buffer		*/

	mymibuf=(char *)Malloc((long)mymsize); 	/*	get memory for user MIDI buffer	*/
	if(mymibuf==0){
		printf("Memory allocation problem.\n");
		printf("There are only %ld bytes of free memory.\n",Malloc(-1L));
		printf("Malloc() returned %ld.  Press any key to exit.\n",mymibuf);
		Bconin(2);
		exit();						/*	exit on malloc error			*/
	}

	(*midi_buff).ibuf = mymibuf; 	/* change address of buffer 	*/
	(*midi_buff).ibufsiz = mymsize; /* and size, too 				*/

	(*midi_buff).ibufhd = (*midi_buff).ibuftl;	/*	quick buffer clear	*/

	printf("%d byte MIDI buffer established.\n",(*midi_buff).ibufsiz);
	printf("Waiting for MIDI...(ESC to exit, C to clear screen)\n",(*midi_buff).ibufsiz);
	/*	this loop will display incoming MIDI bytes until ESC is pressed	*/
	while(character != 27){
		if(Bconstat(MIDI)){
			if(count<25){
				printf("%02x ",(int)Bconin(MIDI)&(0x000000FF));
				fflush(stdout);	
				count++;	
			}								
			if(count==25){
				printf("%02x \n",(int)Bconin(MIDI)&(0x000000FF));
				count=0;			
			}								
		}
		if(Bconstat(CONSOLE)) character=toupper( (int)Bconin(CONSOLE) );
		if (character=='C'){
			printf("\033E");		/*	clear screen	*/
			fflush(stdout);	
			printf("Waiting for MIDI...(ESC to exit, C to clear screen)\n",(*midi_buff).ibufsiz);
			character='\0';
			count=0;
		}
		if (character=='T'){
			printf("\033E");	/*	clear screen	*/
			fflush(stdout);	
			if(thruflag==0){
				thru_on();	
				thruflag=1;
			}
			else if(thruflag==1){
				thru_off();	
				thruflag=0;
			}
			character='\0';
			count=0;
		}
	}		

	(*midi_buff).ibuf = oldmibuf; 		/* restore old address of buffer */
	(*midi_buff).ibufsiz = oldmsize; 	/* and old size, too 			 */
	Mfree(mymibuf);						/* free user MIDI buffer memory	 */
	if(thruflag==1)	thru_off();			/* restore midivec, if nec.	     */					
}


asm	{
	;	Upon entrance:  A1 holds MIDI ACIA control address 
	;	A0 holds MIDI iorec address, D0 holds incoming MIDI byte
	;	since the existing ROM routine stomps on D1, we will use D1
	; 	ourselves first - the first 4 lines are the new code for the 
	;	thru function
	midithru:	
		move.b	(A1),D1				;	Get MIDI status
		btst	#1,D1				;	OK?
		beq		midithru			;	No, wait
		move.b	D0,2(A1)			;	Send midi byte input to midi out 
		move.w 8(A0),D1				;	tail index
		addq.w #1,D1				;	increment
		cmp.w  0x0004(A0),D1		;   End of buffer reached?
		bcs	   htot					;	No
		moveq  #0x00,D1				;   Buffer pointer back to buffer start
	htot:
		cmp.w	0x0006(A0),D1		;	Head equals tail?
		beq		thruend				;	Yes, buffer full
		move.l	0x0000(A0),A2		;	Buffer address
		move.b	D0,0x00(A2,D1.w)	;	Write byte in buffer
		move.w	D1,0x0008(A0)		;	New tail index
	thruend:
		rts							;   back to caller
	}

thru_on()
{	vectors=(kbdvecs *)Kbdvbase();
	mvec=vectors -> midivec;
	msys=vectors -> midisys;
	vectors -> midivec=midithru;	/* substituting our own routine	*/
	printf("MIDI thru enabled.\n");
}

thru_off()
{
	vectors -> midivec=mvec;	
	printf("MIDI thru disabled.\n");
}
