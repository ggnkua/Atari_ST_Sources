

; Example of using two or more tunes
; without label clashes etc.

; tunes must be assembled to disk
; as in example sources....

; see ex_tune1.s
; &   ex_tune2.s

; (these are incbin'ed as prg's)


; PRESS F1 TO PLAY TUNE 1
; PRESS F2 TO PLAY TUNE 2
; PRESS F3 FOR QUIET
; PRESS SPACE TO EXIT




 clr.l -(sp)	;that's just super
 move #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,sv



 dc.w $a000,$a00a	;hidenmauser

 move.b $484,key
 clr.b $484		;CLICK OFF

 move.b $ff8260,res	;SAVE RESOLUTION

 MOVEM.L $FF8240,D0-D7	;SAVE COLORS
 MOVEM.L D0-D7,SAVECOL

 JSR WTVB
 clr.b $ff8260		;low res

 jsr picture		;pic on screen



; the incbin'ed music files...
; ex_tune1.bin & ex_tune2.bin 
; are actually prg's but cannot
; be run from the desktop.

; I've used .BIN as the extender
; just so people don't try to
; run them, then delete them when
; they don't work!
; The extender doesn't matter.

; Here, before use they must be
; relocated, as follows




 LEA TUNE1,A0
 JSR RELOCATE

 LEA TUNE2,A0
 JSR RELOCATE



*-I'll have tune 2 playing as default.

 MOVE.L #TUNE2+$1c+10,$4de




*-*-*-*-* MAIN LOOP *-*-*-*-*



mainloop
 JSR WTVB


 move.b $fffc02,d0	;key press


********************
* wanna play tune 1?
********************

 cmp.b #59,d0	;f1 pressed?
 bne.s t2		;nope


 LEA TUNE1+$1c+10,A0	; yep
 cmp.l $4de,a0
 beq.s t2	;that's already playing dope 

*-reset tune to start (not necessary)

 move.l -4(a0),-10(a0)
 clr -6(a0)

 jsr quiet
 move.l a0,$4de		;play tune 1 in vbi slot. (like... jsr tune1+$1c+10)



********************
* wanna play tune 2?
********************
t2
 cmp.b #60,d0	;f2 pressed?
 bne.s t3		;no


 LEA TUNE2+$1c+10,a0	;yeah
 cmp.l $4de,a0
 beq.s t3		;that's already playing  

*-to reset tune to beginning (not necessary)

 move.l -4(a0),-10(a0)
 clr -6(a0)
 

 jsr quiet
 move.l a0,$4de		;play tune 1 in vbi slot. (like jsr tune1+$1c+10)



********************
* want some peace and quiet ?
********************

t3
 cmp.b #61,d0	;f3 pressed?
 bne.s t4	;nay


 clr.l $4de	;get rid of damn tune
 jsr quiet	;and hear the sound of silence...






*-Here would run your own program-*

t4

 jsr rotator



*-*-*-*-*-*-*-*

 cmp.b #128+57,$fffc02  ;exit ?
 bne mainloop		;uhuh




;EXIT  			;a ha


 clr.l $4de  ;switch off before exit or else...

 JSR WTVB
 jsr quiet

 MOVEM.L SAVECOL,D0-D7	RESTORE COLORS
 MOVEM.L D0-D7,$ff8240

 JSR WTVB
 move.b key,$484
 move.b res,$ff8260

 move.l sv,-(sp)
 move #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,sv

 clr -(sp)
 trap #1

sv dc.l 0
res dc.b 0
key dc.b 0

STAR DC.B 160,0

SAVECOL ds.l 8


;quiet, can you dig it ?

quiet
 lea $ff8800,a1
 move.l #$8000000,(a1)
 move.l #$9000000,(a1)
 move.l #$a000000,(a1)
 rts


*-*-*WAIT TILL VBI HAS JUST FINISHED
WTVB
 MOVE.B $469,D0
WT CMP.B $469,D0
 BEQ.S WT
 RTS

*-****	COLOUR ROTATOR  ****-*
rotator
 TST.B STAR
 BEQ.S XX
 SUBQ.B #1,STAR
 BRA.S XT

XX 
 ADD.B #64,STAR+1
 BCC.S XT

 LEA $FF8242,A0
 MOVE (A0),D7

 MOVEM.L 2(A0),D0-D6
 MOVEM.L D0-D6,(A0)
 MOVE D7,26(A0)
XT rts


*-* write degas pic and set cols *-*
picture
 MOVEM.L PIC+2,D0-D7
 MOVEM.L D0-D7,$FF8240

 LEA PIC+34,A0
 move.l $44e,A1
 MOVE #7999,D0

GDD MOVE.L (A0)+,(A1)+
 DBRA D0,GDD
 rts


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

 LEA   $1C(A0),A0	A0 Points to programs start adress
 move.l	A0,d1

 MOVE.L	A0,A1         
 MOVE.L	A1,A2         

 ADD.L	D0,A1		Get adress of RELOCATION TABLE
 MOVE.L	(A1)+,D0	Get the Long Word
 ADD.L	D0,A2         
 ADD.L	D1,(A2)	Relocate it
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


PIC	INCBIN A:\EXAMPLE.S\EXAMPLE.PI1
TUNE1	INCBIN A:\EXAMPLE.S\EX_TUNE1.BIN
TUNE2	INCBIN A:\EXAMPLE.S\EX_TUNE2.BIN
