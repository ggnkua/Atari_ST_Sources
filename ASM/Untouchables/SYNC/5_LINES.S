;*******************************************************************
;*                                                                 *
;* Published in the Ledgers Disk Magazine Volume 8                 *
;*                                           Release Date : 1/2/92 *
;*                                                                 *
;*******************************************************************

; How to achieve a Sync-Scroller using just 5 or 6 scanlines!!!
; by Tony B of UNT.
;
; DO NOT READ UNLESS YOU UNDERSTAND SYNC-SCROLLING TECHNIQUE!!!
;
; As there is a lot to explain about HardWare scrolling the STF/M, i will
; keep this document in mind for those who have already written a lesser
; one, ie:- 10-20 scanlines!!!! If you want a full explanation then contact me
; through the mag's address.
;
; Basically this doc will tell you how to get 8 (yes eight!) different types
; of border combinations.
;
; A list of positions will follow:- The first number corresponds to MONO_1,
; the second to MONO_2, the third to FREQ_1, and so on ....
;
; Note that the 0 byte line (frequency change) will not work on some
; computers, and that the 0 byte line (monochrome) distorts the picture on
; most monitors and TV's ! There is a way, however, of getting the frequency
; version to work on all machines! Read on ...
;
; Adjust these values to suit the EQU's in the example code.
;
; 230		1,0,0,1,1,89,13,9
; 186		1,0,0,0,0,120,0,0
; 184		1,0,0,1,0,87,19,0
; 158		0,0,0,1,0,96,19,0
; 204	Freq	0,0,0,1,0,94,27,0
;	Mono	0,1,0,0,0,94,26,0
; 54		0,1,0,0,0,40,80,0
; 80		1,1,0,0,0,35,80,0
; 0 	Freq	0,0,0,1,0,14,112,0
;	Mono	0,1,0,0,0,6,114,0
;
; Now, if you want to be safe and not use the 0 byte scanline then you can
; get it working in 6 lines on all machines (I have!). However by adding
; the 0 byte scanline it is possible to have it running in just 5 scanlines!!
; (I found the 0 byte scanline is too dodgy on STE's !!!!?).
;
; This example code was swiped from some French magazine by GND of Torment.
; (Thanks Dave! Couldn't have done it without those 80 and 54 combinations).

mono_1		=	1	;example for a full scanline
mono_2		=	0
freq_1		=	0
freq_2		=	1
stable		=	1
nops_1		=	89
nops_2		=	13
nops_3		=	9

vbl	movem.l	d0-a6,-(sp)
	lea	$ffff8260,a0	;Res
	lea	$ffff820a,a1	;Hz
	lea	$ffff8209,a2	;video pointer (low-byte)
	moveq	#2,d0		;50Hz, High res
	moveq	#0,d1		;60Hz, Low res
	moveq	#9,d4		;number of lines to remove
	nop
	nop
sync	move.b	(a2),d5
	beq.s	sync
	neg	d5
	lsl.l	d5,d5
	moveq	#22,d5
wait	dbf	d5,wait
	nop
	nop
ovrscan
	ifne	mono_1
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)
	endc
	
	ifne	freq_1
	move.b	d1,(a1)
	move.b	d0,(a1)
	endc

	ifne	nops_1
	dcb.w	nops_1,$4e71
	endc

	ifne	mono_2
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)
	endc
	
	ifne	freq_2
	move.b	d1,(a1)
	move.b	d0,(a1)
	endc

	ifne	nops_2
	dcb.w	nops_2,$4e71
	endc
	
	ifne	stable
	move.b	d0,(a0)
	nop
	move.b	d1,(a0)
	endc

	ifne	nops_3
	dcb.w	nops_3,$4e71
	endc

	dbf	d4,ovrscan
	movem.l	(sp)+,d0-a6
	rte


; The next thing you will notice once you've written your new and
; improved scroll-routs, is that the 80 byte scanline fucks up on
; some STE's. The way around this is as follows .......
;
; 1) Always use immediate data -> absolute address (for all borders!).
; 2) Give it a medium res shock in between the MONO_1, ie:
;
; .....
;       move.b	#2,$ffff8260.w		;high res.
;       move.b	#1,$ffff8260.w		;yeaaarrgghh!!!
;       move.b	#0,$ffff8260.w		;back to low
; .....
;
; So waddya waiting for ??? When you get it working give us a mention
; in your demo .....
;
; Have fun calculating those sync values ......Tony !

