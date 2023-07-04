


;DO NOT TRY TO ASSEMBLE AND RUN THIS
;IT IS ASSEMBLED TO DISK AND BIN-LOADED
;AND CALLED FROM BASIC.

;This source ok for Fast Basic.


; Example of using two or more tunes
; from BASIC.

; If you only want one tune, then it
; may be easier for you to put the tune
; in an auto folder and refer to my
; general instructions.



; If you want tunes other than these 
; then you'll have to assemble them
; exactly like the 2 examples.

; see ex_tune1.s
; &   ex_tune2.s

; (these are incbin'ed as prg's into this source.)

; When you've assembled this source
; to disk, you will have to binary
; load the object file in BASIC, to
; a reserved or known safe area, on
; an even address e.g $75000 is even.
; $75001 isn't. (in case you didn't know)


;Then you call the address you
;binary loaded it to, PLUS 2.

;you poke the load address with 0
;for your fist tune, 1 for the second
;and 255 for silence.




;I don't know if your basic runs in
;supervisor so if this doesn't work
;remove marked areas (asterisks)




START
 DC.B 0,1

 movem.l d0-d7/a0-a6,-(sp) ;safe side

**************************
 clr.l -(sp)	;that's just super
 move #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,d7
**************************

 
 lea start+1(pc),a6
 tst.b (a6)
 beq.s done


 LEA TUNE1(PC),A0
 BSR RELOCATE

 LEA TUNE2(PC),A0
 BSR RELOCATE



 clr.b (a6)


done 
 cmp.b #255,-1(a6)
 beq.s quiet	;silence


 tst.b -1(a6)  ;0
 bne.s tu1

; bsr quiet
 lea tune1+$1c+10(pc),a0
 move.l a0,$4de		start tune

 bra.s exit



tu1		;not zero so tune2
; bsr quiet
 lea tune2+$1c+10(pc),a0
 move.l a0,$4de


exit
**************************
 move.l D7,-(sp)
 move #$20,-(sp)
 trap #1
 addq.l #6,sp
**************************

 movem.l (sp)+,d0-d7/a0-a6 ;safe side


;may have to change this RTS ,but I doubt it.
;...BACK TO BASIC.

; clr -(sp)
; trap #1

 rts		;ok for Fastbasic.




quiet
 clr.l $4de	;music off please

 move.b $469,d6
ddd cmp.b $469,d6
 beq.s ddd

 lea $ff8800,a1
 move.l #$8000000,(a1)
 move.l #$9000000,(a1)
 move.l #$a000000,(a1)
 bra.s exit


 even

* Relocate music so we can run it here
*
* Don't worry if you dont understand 
* this routine, it just changes all
* absolute addresses in a prg, it's
* the same routine as the o.s. uses
* when running a prg from the desktop.


RELOCATE
 MOVE.L	2(A0),D0	Length of PROGRAM 
 ADD.L	6(A0),D0
 ADD.L	14(A0),D0	Length of SYMBOL TABLE

; D0 contains relative position of RELOCATION TABLE

 add.l #$1C,A0	A0 Points to programs start adress
 move.l	A0,d1

 MOVE.L	A0,A1         
 MOVE.L	A1,A2         

 ADD.L	D0,A1		Get adress of RELOCATION TABLE
 MOVE.L	(A1)+,D0	Get the Long Word
 ADD.L	D0,A2         
 ADD.L	D1,(A2)		Relocate it
 CLR.L	D0            

REL
 MOVE.B	(A1)+,D0	Get next byte from table
 BEQ.S	FIN		Is it the end (zero)
 CMP.B   #1,D0		1 is a 254 jump
 BEQ.S	QJUMP		If it is then do it
 ADD.L	D0,A2		If not find next absolute adress
 ADD.L	D1,(A2)		and relocate it
 BRA.S	REL		Continue until the zero is found
QJUMP
 ADD.L	#254,A2		Jump 254 bytes
 BRA.S	REL		and continue

FIN rts

TUNE1	INCBIN A:\EXAMPLE.S\EX_TUNE1.BIN
 even
TUNE2	INCBIN A:\EXAMPLE.S\EX_TUNE2.BIN
 even
