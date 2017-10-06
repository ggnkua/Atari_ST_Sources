********************************************
**   STOS MAESTRO Extension Source code   **
**                                        **
**  (C)  New Dimensions / Mandarin  1989  **
**                                        **
**    Written By Jon Wheatman,  11/2/89   **
******************************************** LAST MOD:20/3/89
 
* Hi, francois, sorry not many labels in this one, but you should
* understand the play routine, if not look at the compiler extension
* thats documented.

* 16 Commands added to STOS

* SOUND INIT			; Sound Chip Initialisation
* SAMPLAY  (n)			; Play sample (N) in bank 5
* SAMSPEED MANUAL		; Set manual speed control
* SAMSPEED AUTO			; Set Auto speed search
* SAMSPEED (n)			; Set speed rate ( in Khz )
* SAMSTOP			; Stop Interupt routine playing
* SAMLOOP ON			; Set sample loop
* SAMLOOP OFF			; Clear Sample loop
* SAMDIR FORWARD		; Set direction of play to forward
* SAMDIR BACKWARD		; Set direction of play to backward
* SAMSWEEP ON			; set sweep effect
* SAMSWEEP OFF			; clear sweep effect
* SAMRAW (start),(end)		; Play Raw sample data in memory
* SAMRECORD (start),(end) 	; Record sample into memory
* SAMCOPY (start),(end),(dest)	; Copy memory to memory
* SAMMUSIC (n),(note)[#]	; Play sample (n) as a note
* SAMTHRU 			; Execute thru mode sampling
* SAMBANK (n)			; Set up memory bank



PSG	=$FF8800
        bra load                ; JUMP TO FIRST CALL AFTER LOAD
	even
        dc.b $80                ;Important!
tokens: dc.b "sound init",$80       ;EVEN tokens are INSTRUCTIONS
	dc.b "sample",$81
	dc.b "samplay",$82
	dc.b "samplace",$83
	dc.b "samspeed manual",$84
	dc.b "dummy",$85
	dc.b "samspeed auto",$86
	dc.b "dummy",$87
	dc.b "samspeed",$88 
	dc.b "dummy",$89
	dc.b "samstop",$8a
	dc.b "dummy",$8b
	dc.b "samloop off",$8c
	dc.b "dummy",$8d
	dc.b "samloop on",$8e
	dc.b "dummy",$8f
	dc.b "samdir forward",$90
	dc.b "dummy",$91
	dc.b "samdir backward",$92
	dc.b "dummy",$93
	dc.b "samsweep on",$94
	dc.b "dummy",$95
	dc.b "samsweep off",$96
	dc.b "dummy",$97
	dc.b "samraw",$98
	dc.b "dummy",$99
	dc.b "samrecord",$9a
	dc.b "dummy",$9b
	dc.b "samcopy",$9c
	dc.b "dummy",$9d
	dc.b "sammusic",$9e
	dc.b "dummy",$9f
	dc.b "samthru",$a0
	dc.b "dummy",$a1
	dc.b "sambank",$a2




	
	dc.b 0                  ;END of the table
	even
jumps:  dc.w 36                 ;Number of jumps
        dc.l saminit           ;Addresses in the program
	dc.l sample
	dc.l playsam
	dc.l getpos
	dc.l samspeedm
	dc.l dummy
	dc.l samspeeda
	dc.l dummy
	dc.l samspeed
	dc.l dummy
	dc.l samstop
	dc.l dummy
	dc.l samloopoff
	dc.l dummy
	dc.l samloopon
	dc.l dummy
	dc.l samdirf
	dc.l dummy
	dc.l samdirb
	dc.l dummy
	dc.l samsweepon
	dc.l dummy
	dc.l samsweepoff
	dc.l dummy
	dc.l samraw
	dc.l dummy
	dc.l samrec
	dc.l dummy
	dc.l samcopy
	dc.l dummy
	dc.l sammusic
	dc.l dummy
	dc.l samthru
	dc.l dummy
	dc.l sambank
	dc.l dummy




	even
welcome:dc.b 10,"STOS Maestro Commands Installed V2",0
        dc.b 10,"Extension STOS Maestro extraordinaire",0
        dc.b 0

myerrors:
	dc.b "Memory Bank does not contain sample data",0
	dc.b "Le banque de mmoire est ne contain pas le data du sample",0
	dc.b "Sample not found in bank",0
	dc.b "Le sample est ne trouve pas dans le banque cinq",0
	dc.b "Sample rate out of range ( 5 - 22 Khz )",0
	dc.b "Le rapide du sample est horrible ( 5 - 22 Khz )",0
	dc.b "Sample does not contain its play speed",0
	dc.b "Le Sample n'ai pas il joue rapide",0
	dc.b "End address must be higher than start address",0
	dc.b "Le fin address must be grander that begin address",0
	DC.B "Memory bank out of range",0
	dc.b "Le banque du mmoire est tres mal",0 

	even
table:	dc.l 0
load:   lea finprg,a0           ;A0---> end of the extension
        lea cold,a1             ;A1---> adress of COLD START routine
        rts
cold:   move.l a0,table         ;INPUT: basic table adress
        lea welcome,a0          ;OUTPUT:        A0= welcome message
        lea warm,a1             ;               A1= warm start
        lea tokens,a2           ;               A2= token table
        lea jumps,a3            ;               A3= jump table
        rts   
warm:   rts
graphics:       equ $50         ;graphic datas
ptsin:          equ $5c         ;GEM garbage
contrl:         equ $54
vdipb:          equ $68
autob1:         equ $90         ;autoback 1
autob2:         equ $94         ;autoback 2
xmax:           equ $24         ;X Maximum
ymax:           equ $28         ;Y
grh:            equ $44         ;GEM graphic handle

dummy:	move.l (sp)+,return
	bra syntax
integer:
        move.l (sp)+,a0         ;Return address
        tst.w d0                ;If no param---> syntax error
        beq syntax
        movem.l (sp)+,d2-d4     ;Get the param
        tst.b d2        
        bmi typemis             ;If string---> type mismatch
        beq.s endint            ;If integer--> OK
        movem.l d0/d1/d5/d6/d7/a0-a2,-(sp)  
        move.l table,a0         ;Address table
        move.l $04(a0),a0       ;Position 4 in table
        jsr (a0)                ;FL TO INT
        movem.l (sp)+,d0/d1/d5/d6/d7/a0-a2
endint: subq.w #1,d0
        jmp (a0) 

string:
        move.l (sp)+,a0

        tst.w d0                ;If no param---> syntax error
        beq syntax
        movem.l (sp)+,d2-d4     ;Get the param
        tst.b d2        
        bpl typemis             ;If not string---> type mismatch
        move.l d3,a2            ;adress of the string
        move.w (a2)+,d2         ;get length and point string

        subq.w #1,d0 
        jmp (a0)

adorbank:
        movem.l a0-a2,-(sp)
        move.l table,a0
        move.l $88(a0),a0       ;Have a look at the address table!
        jsr (a0)
        movem.l (sp)+,a0-a2
        rts
adorscreen:
        movem.l a0-a2,-(sp)
        move.l table,a0
        move.l $8c(a0),a0
        jsr (a0)
        movem.l (sp)+,a0-a2
        rts
syntax: moveq #12,d0
        bra.s error
typemis:moveq #19,d0
        bra.s error
foncall:moveq #13,d0
error:  move.l table,a0
        move.l $14(a0),a0
        jmp (a0)   

* Refere to compiler extension for labels, there both the same.

SAMINIT:
	MOVE.L (SP)+,RETURN
	CMP.W #0,D0
	BNE SYNTAX
	MOVE.L #SND_INIT,-(SP)
	MOVE.W #32,-(SP)
	TRAP #14
	ADDQ.L #6,SP
	BRA END

END:	MOVE.L RETURN,A0
	JMP (A0)

PLAYSAM:

	MOVE.L (SP)+,RETURN
	move.w #0,oknotm
access2:CMP.W #1,D0
	BNE SYNTAX
	BSR INTEGER
	MOVE.L D3,SPARAM
	move.l table,a0
	move.l $88(a0),a0
	move.w sampbank,d3
	jsr (a0)
	MOVEA.L D3,A1

	cmp.b #'M',(a1)
	bne notsbank
	cmp.b #'A',1(a1)
	bne notsbank
	cmp.b #'E',2(a1)
	bne notsbank
	cmp.b #'S',3(a1)
	bne notsbank
	cmp.b #'T',4(a1)
	bne notsbank
	cmp.b #'R',5(a1)
	bne notsbank
	cmp.b #'O',6(a1)
	bne notsbank
	cmp.b #'!',7(a1)
	bne notsbank

	move.l a1,-(sp)

* a1=start of memory bank
	CLR.W D7
LOOPPO:	ADDQ.L #8,A1
	ADDQ.W #1,D7
	CMPI.L #0,(A1)
	BNE LOOPPO
	SUBQ.W #1,D7
	MOVE.W D7,-(SP)

	MOVE.W (SP)+,D7
	MOVE.L (SP)+,A1
	MOVEA.L A1,A0

	MOVE.L SPARAM,D3

	CMPI.B #0,D3
	BEQ SAMPNFOUND
	CMP.B D7,D3
	BGT SAMPNFOUND

	ANDI.L #$FF,D3		; ISOLATE SAMPLE NUMBER 0-32
	LSL.W #3,D3             ; NUMBER=NUMBER * 8
	ADDA.L D3,A1		; ADD TO START OF BANK 
	ADDA.L (A1),A0          ; OFFSET TO START OF SAMPLE + BASE
	MOVE.L 4(A1),A1		; LENGTH
	
	
* A0.L = start address
* A1.L = LENGTH OF SAMPLE + 8

	SUBA.L #20,A1
	ADDA.L #8,A0
ACCESS:	MOVE.L A0,STARTADDR
	MOVE.L A1,LENGTH
	MOVE.L A0,STARTADDR2
	MOVE.L A1,LENGTH2

	MOVE.W SR,D7
	MOVE.W #$2700,SR
	CLR.B $FFFA19
	MOVE.B #1,$FFFA19
	CMP.W #1,AUTO_ON
	BNE NOTON
	CMP.B #'J',(A0)
	BNE NOTRATE
	CMP.B #'O',1(A0)
	BNE NOTRATE
	CMP.B #'N',2(A0)
	BNE NOTRATE
	MOVE.B 3(A0),D3
	AND.W #$FF,D3
	LEA HERTZ,A0
	MOVE.B 0(A0,D3.W),D3	 GET TIMER A DATA FOR SAMRATE
	ADD.B #19,D3
	MOVE.B D3,$FFFA1F
	BRA SKIPNXT

NOTON: 	CMP.W #0,OKNOTM
	BEQ OKNOTM1
	MOVE.B SPEED,$FFFA1F
	BRA SKIPNXT
OKNOTM1:MOVE.B SPEED,d3
	ADD.B #19,d3
	move.b d3,$FFFA1F
SKIPNXT:OR.B #$20,$FFFA13
	OR.B #$20,$FFFA07
	BCLR.B #3,$FFFA17
	CMP.W #1,TYPE
	BEQ TYPE1
	CMP.W #2,TYPE
	BEQ TYPE2
	CMP.W #3,TYPE 
	BEQ TYPE3
	CMP.W #4,TYPE
	BEQ TYPE4
	CMP.W #5,TYPE
	BEQ TYPE5
TYPE1:	MOVE.L #PLAYIRQ1,$134
	MOVE.W D7,SR
	BRA END
TYPE2:	MOVE.L #PLAYIRQ2,$134
	MOVE.L LENGTH,D0
	ADD.L D0,STARTADDR
	ADD.L D0,STARTADDR2
	MOVE.W D7,SR
	BRA END
TYPE3:	MOVE.L #PLAYIRQ3,$134
	MOVE.W D7,SR
	BRA END
TYPE4:	MOVE.L #PLAYIRQ4,$134
	MOVE.L LENGTH,D0
	ADD.L D0,STARTADDR
	ADD.L D0,STARTADDR2
	MOVE.W D7,SR
	BRA END
TYPE5:	MOVE.L #PLAYIRQ5,$134
	MOVE.W D7,SR
	BRA END
OUTOFIT:BCLR #5,$FFFA07
	MOVEM.L (SP)+,D7/A3
	RTE
NOTRATE:
	MOVE.W D7,SR
	MOVEQ.W #3,D0
	BRA DOERR2
notsbank:
	moveQ.w #0,d0
	bra doerr2
SAMPNFOUND:
	MOVEQ.W #1,D0
	BRA DOERR2
doerr2:
	move d0,d4
	lsl.w #1,d0
	lea myerrors,a2
	subq #1,d0
	bmi.s err2
err1:	tst.b (a2)+
	bne.s err1
	dbra d0,err1
err2:	
	move.l table,a1
	move.l $18(a1),a1
	jsr (a1)
	bra end


* FORWARD NORMAL PLAY ROUTINE *

PLAYIRQ1:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B (A3),D7
	SUBQ.L #1,LENGTH
	BEQ.S OUTOFIT
	ADDQ.L #1,STARTADDR
	ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE

* BACKWARD NORMAL PLAY ROUTINE *

PLAYIRQ2:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B (A3),D7
	SUBQ.L #1,LENGTH
	BEQ OUTOFIT
	SUBQ.L #1,STARTADDR
	ANDI.W #$FF,D7
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE

* FORWARD LOOP PLAY ROUTINE *

PLAYIRQ3:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B (A3),D7
	SUBQ.L #1,LENGTH
	BEQ.S OUTOFIT2
	ADDQ.L #1,STARTADDR
INTOIT2:ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT2:
	MOVE.L LENGTH2,LENGTH
	MOVE.L STARTADDR2,STARTADDR
	BRA INTOIT2

* BACKWARD LOOP PLAY ROUTINE *

PLAYIRQ4:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B (A3),D7
	SUBQ.L #1,LENGTH
	BEQ.S OUTOFIT3
	SUBQ.L #1,STARTADDR
INTOIT3:ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT3:
	MOVE.L LENGTH2,LENGTH
	MOVE.L STARTADDR2,STARTADDR
	BRA INTOIT3


* SWEEP PLAY ROUTINE *

PLAYIRQ5:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B (A3),D7
	SUBQ.L #1,LENGTH
	BEQ.S OUTOFIT4
	ADDQ.L #1,STARTADDR
INTOIT4:ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT4:
	MOVE.L LENGTH2,LENGTH
	MOVE.L #PLAYIRQ6,$134
	BRA INTOIT4

PLAYIRQ6:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B (A3),D7
	SUBQ.L #1,LENGTH
	BEQ.S OUTOFIT5
	SUBQ.L #1,STARTADDR
INTOIT5:ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	MOVE.B #8,PSG
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT5:
	MOVE.L LENGTH2,LENGTH
	MOVE.L #PLAYIRQ5,$134
	BRA INTOIT5

SAMSPEED:
	MOVE.L (SP)+,RETURN
	
	CMP.W #1,D0
	BNE SYNTAX

	BSR INTEGER

	CMP.W #23,D3
	BGE OUTSPEED
	CMP.W #5,D3
	BLT OUTSPEED

	

 	MOVE.W #0,AUTO_ON
	LEA HERTZ,A0
	MOVE.B 0(A0,D3.W),SPEED		; GET TIMER A DATA FOR SAMRATE


	MOVE.B SPEED,d3
	ADD.B #19,d3
	move.b d3,$FFFA1F

	BRA END

OUTSPEED:
	MOVEQ.W #2,D0
	BRA DOERR2

SAMSPEEDA:
	MOVE.L (SP)+,RETURN
	MOVE.W #1,AUTO_ON
	BRA END
SAMSPEEDM:
	MOVE.L (SP)+,RETURN
	MOVE.W #0,AUTO_ON
	BRA END

SAMSTOP:
	MOVE.L (SP)+,RETURN
	MOVE.W SR,D7
	MOVE.W #$2700,SR
	BCLR #5,$FFFA07
	BCLR #5,$FFFA0B
	BCLR #5,$FFFA0F
	BCLR #5,$FFFA13
	MOVE.W D7,SR
	BRA END

SAMLOOPOFF:
	MOVE.L (SP)+,RETURN
	CMPI.W #2,TYPE
	BLE.S NOTONSL
	CMPI.W #5,TYPE
	BEQ.S NOTONSL
	SUBQ.W #2,TYPE
NOTONSL:BRA END

SAMLOOPON:
	MOVE.L (SP)+,RETURN
	CMPI.W #5,TYPE
	BEQ END
	CMPI.W #3,TYPE
	BGE.S ALLRON
	ADDQ.W #2,TYPE
ALLRON:	BRA END
SWON2:	MOVE.W #3,TYPE
	BRA END

SAMDIRF:
	MOVE.L (SP)+,RETURN
	CMPI.W #5,TYPE
	BEQ END
	CMPI.W #1,TYPE
	BEQ END
	CMPI.W #3,TYPE
	BEQ END
	CMPI.W #2,TYPE
	BNE.S SAMDIRF2
	MOVE.W #1,TYPE
	BRA END
SAMDIRF2:MOVE.W #3,TYPE
	BRA END

SAMDIRB:
	MOVE.L (SP)+,RETURN
	CMPI.W #5,TYPE
	BEQ END
	CMPI.W #2,TYPE
	BEQ END
	CMPI.W #4,TYPE
	BEQ END
	CMPI.W #1,TYPE
	BNE.S SAMDIRB2
	MOVE.W #2,TYPE
	BRA END
SAMDIRB2:MOVE.W #4,TYPE
	BRA END

SAMSWEEPON:
	MOVE.W #5,TYPE
	BRA END
SAMSWEEPOFF:
	MOVE.W #1,TYPE
	BRA END


* SAMRAW start,end *
	
SAMRAW:
	MOVE.L (SP)+,RETURN
	CMP.W #2,D0
	BNE SYNTAX
	BSR INTEGER		; GET END ADDRESS
	MOVE.L D3,TEMPL
	BSR INTEGER		; GET START ADDRESS
	CMP.L TEMPL,D3
	BGE E_BEFORE_S		; END BEFORE START ERROR !
	MOVE.L D3,A0
	MOVE.L TEMPL,A1
	SUBA.L A0,A1		; CALC LENGTH ( END - START )
	BRA ACCESS		; PLAY ROUTINE

E_BEFORE_S:
	MOVEQ.W #4,D0
	BRA DOERR2
NOBANKS:
	MOVEQ.W #5,D0
	BRA DOERR2

* SAMREC start,end *

SAMREC:
	MOVE.L (SP)+,RETURN
	CMP.W #2,D0
	BNE SYNTAX
	BSR INTEGER		; GET END ADDR
	MOVE.L D3,TEMPL
	BSR INTEGER
	CMP.L TEMPL,D3
	BGE E_BEFORE_S		; END BEFORE START ERROR !
	MOVE.L D3,A0
	MOVE.L TEMPL,A1
	SUBA.L A0,A1		; CALC LENGTH ( END - START )
	MOVE.L A0,STARTADDR
	MOVE.L A1,LENGTH
	MOVE.L A0,STARTADDR2
	MOVE.L A1,LENGTH2
	MOVE.W SR,D7
	MOVE.W #$2700,SR
	CLR.B $FFFA19
	MOVE.B #1,$FFFA19
 	MOVE.B SPEED,d3
	ADD.B #19,d3
	move.b d3,$FFFA1F
	OR.B #$20,$FFFA13
	OR.B #$20,$FFFA07
	BCLR.B #3,$FFFA17
	MOVE.L #RECIRQ,$134
	MOVE.W D7,SR
	BRA END

RECIRQ:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR,A3
	MOVE.B $FB0001,D7
	MOVE.B D7,(A3)
	SUBQ.L #1,LENGTH
	BEQ.S ROUTOFIT
	ADDQ.L #1,STARTADDR
	ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
ROUTOFIT:
	BCLR #5,$FFFA07
	MOVEM.L (SP)+,D7/A3
	RTE

SAMPLE:
	MOVE.L (SP)+,RETURN
	CLR.L D3
	MOVE.B $FB0001,D3
	SUBI.B #$80,D3
	EXT.W D3
	EXT.L D3
	CLR.B D2
	BRA END

GETPOS:
	MOVE.L (SP)+,RETURN
	MOVE.L STARTADDR,D3
	SUB.L STARTADDR2,D3
	CLR.B D2
	BRA END
	


SAMCOPY:

	MOVE.L (SP)+,RETURN
	CMP.W #3,D0
	BNE SYNTAX
	BSR INTEGER
	MOVE.L D3,DESTC
	BSR INTEGER
	MOVE.L D3,ENDC
	BSR INTEGER
	MOVE.L D3,A0
	MOVE.L DESTC,A1
COPYL:	MOVE.B (A0)+,(A1)+
	CMPA.L ENDC,A0
	BLT.S COPYL
	BRA END

sammusic:
	move.l (sp)+,return
	bsr string
	and.b #255-32,(a2)	; letter in upper case !
	movea.l a2,a0
	lea convt,a1
tsloop:	cmp.b (a0)+,(a1)+
	bne nextonet
	cmp.b #1,d2
	beq outts
	cmp.b (a0)+,(a1)+
	bne nextonet2
	cmp.b #2,d2
	beq outts
	moveq.w #5,d0
	bra doerr2
outts:  move.b (a1),speed	; timer A data for speed control
 	MOVE.W #0,AUTO_ON
	MOVE.W #1,OKNOTM
	bra access2
 	
nextonet:addq.l #1,a1
nextonet2:addq.l #2,a1
	movea.l a2,a0
	cmp.b #0,(a1)
	bne tsloop	
	bra syntax

convt:	dc.b "C",98,0,0		; C  is at 16 Khz
	dc.b "C#",93,0		; C# is at 17 Khz
	dc.b "D",89,0,0		; D  is at 18 Khz
	dc.b "D#",83,0		; D# is at 19 Khz
	dc.b "E",79,0,0		; E  is at 20.5 Khz
	dc.b "F",75,0,0		; F  is at 22 Khz
	dc.b "F#",71,0		; F# is at 24 Khz
	dc.b "G",68,0,0		; G  is at 25 Khz
	dc.b "G#",65,0		; G# is at 12.5 Khz
	dc.b "A",59,0,0		; A  is at 13.5 Khz
	dc.b "A#",55,0		; A# is at 14.25 Khz
	dc.b "B",53,0		; B  is at 15 Khz
	dc.b 0,0,0,0	
	even


SAMTHRU:
	MOVE.L (SP)+,RETURN
	MOVE.W SR,D7
	MOVE.W #$2700,SR
	CLR.B $FFFA19
	MOVE.B #1,$FFFA19
 	MOVE.B SPEED,d3
	ADD.B #19,d3
	move.b d3,$FFFA1F
	OR.B #$20,$FFFA13
	OR.B #$20,$FFFA07
	BCLR.B #3,$FFFA17
	MOVE.L #THRUIRQ,$134
	MOVE.W D7,SR
	BRA END

THRUIRQ:
	MOVEM.L D7/A3,-(SP)
	MOVE.B $FB0001,D7
	ANDI.W #$FF,D7
	LEA VOLDAT2,A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE

sambank:
	MOVE.L (SP)+,RETURN
	CMP.W #1,D0
	BNE SYNTAX
	BSR INTEGER
	CMP.W #0,D3
	BEQ NOBANKS
	CMP.W #16,D3
	BGE NOBANKS
	MOVE.W D3,SAMPBANK
	BRA END
SAMPBANK:DC.W 5


	
DESTC:		DC.L 0
ENDC:		DC.L 0
TEMPL:		DC.L 0	
AUTO_ON:	DC.W 0
RETURN:	DC.L 0
STARTADDR:	DC.L 0
LENGTH:		DC.L 0
STARTADDR2:	DC.L 0
LENGTH2:	DC.L 0
TYPE:		DC.W 1
SPEED:		DC.B 45,0

	
SND_INIT:
	DC.B 0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,-1,8,0,9,0,10,0,11,0,$FF,0
	EVEN

* Volume table, has been changed to make sounds better, new version
* is in the compiler extension source, copy it to here if you want.

VOLDAT2:

        dc.l $08000000,$09000000,$0a000000,0
        dc.l $08000000,$09000000,$0a000000,0
        dc.l $08000000,$09000000,$0a000100,0
        dc.l $08000000,$09000100,$0a000100,0
        dc.l $08000000,$09000000,$0a000200,0
        dc.l $08000000,$09000000,$0a000200,0
        dc.l $08000000,$09000100,$0a000000,0
        dc.l $08000000,$09000200,$0a000200,0
        dc.l $08000000,$09000000,$0a000300,0
        dc.l $08000000,$09000000,$0a000300,0
        dc.l $08000300,$09000100,$0a000100,0
        dc.l $08000300,$09000200,$0a000000,0
        dc.l $08000300,$09000200,$0a000100,0
        dc.l $08000400,$09000000,$0a000000,0
        dc.l $08000400,$09000100,$0a000000,0
        dc.l $08000400,$09000200,$0a000000,0
        dc.l $08000500,$09000000,$0a000000,0
        dc.l $08000500,$09000000,$0a000100,0
        dc.l $08000500,$09000100,$0a000000,0
        dc.l $08000500,$09000100,$0a000100,0
        dc.l $08000500,$09000200,$0a000000,0
        dc.l $08000500,$09000300,$0a000000,0
        dc.l $08000600,$09000000,$0a000000,0
        dc.l $08000600,$09000000,$0a000000,0
        dc.l $08000600,$09000100,$0a000000,0
        dc.l $08000600,$09000100,$0a000000,0
        dc.l $08000600,$09000200,$0a000000,0
        dc.l $08000600,$09000100,$0a000100,0
        dc.l $08000600,$09000200,$0a000100,0
        dc.l $08000600,$09000200,$0a000200,0
        dc.l $08000700,$09000000,$0a000000,0
        dc.l $08000700,$09000000,$0a000000,0
        dc.l $08000700,$09000100,$0a000000,0
        dc.l $08000700,$09000100,$0a000000,0
        dc.l $08000700,$09000100,$0a000100,0
        dc.l $08000700,$09000200,$0a000000,0
        dc.l $08000700,$09000200,$0a000000,0
        dc.l $08000700,$09000200,$0a000100,0
        dc.l $08000700,$09000300,$0a000000,0
        dc.l $08000700,$09000300,$0a000000,0
        dc.l $08000700,$09000300,$0a000100,0
        dc.l $08000700,$09000300,$0a000200,0
        dc.l $08000700,$09000300,$0a000200,0
        dc.l $08000700,$09000300,$0a000300,0
        dc.l $08000800,$09000000,$0a000000,0
        dc.l $08000800,$09000100,$0a000000,0
        dc.l $08000800,$09000100,$0a000000,0
        dc.l $08000800,$09000100,$0a000100,0
        dc.l $08000800,$09000200,$0a000000,0
        dc.l $08000800,$09000200,$0a000100,0
        dc.l $08000800,$09000300,$0a000000,0
        dc.l $08000800,$09000300,$0a000000,0
        dc.l $08000800,$09000300,$0a000100,0
        dc.l $08000800,$09000300,$0a000200,0
        dc.l $08000800,$09000400,$0a000000,0
        dc.l $08000800,$09000400,$0a000000,0
        dc.l $08000800,$09000400,$0a000100,0
        dc.l $08000800,$09000400,$0a000100,0
        dc.l $08000800,$09000400,$0a000200,0
        dc.l $08000800,$09000400,$0a000200,0
        dc.l $08000900,$09000000,$0a000000,0
        dc.l $08000900,$09000000,$0a000100,0
        dc.l $08000900,$09000100,$0a000000,0
        dc.l $08000900,$09000100,$0a000100,0
        dc.l $08000900,$09000200,$0a000000,0
        dc.l $08000900,$09000200,$0a000100,0
        dc.l $08000900,$09000300,$0a000000,0
        dc.l $08000900,$09000300,$0a000000,0
        dc.l $08000900,$09000300,$0a000100,0
        dc.l $08000900,$09000300,$0a000200,0
        dc.l $08000900,$09000300,$0a000200,0
        dc.l $08000900,$09000300,$0a000300,0
        dc.l $08000900,$09000400,$0a000100,0
        dc.l $08000900,$09000400,$0a000200,0
        dc.l $08000900,$09000400,$0a000200,0
        dc.l $08000900,$09000400,$0a000300,0
        dc.l $08000900,$09000500,$0a000000,0
        dc.l $08000900,$09000500,$0a000000,0
        dc.l $08000900,$09000500,$0a000100,0
        dc.l $08000900,$09000500,$0a000100,0
        dc.l $08000900,$09000500,$0a000200,0
        dc.l $08000900,$09000500,$0a000300,0
        dc.l $08000900,$09000500,$0a000300,0
        dc.l $08000900,$09000500,$0a000400,0
        dc.l $08000900,$09000600,$0a000000,0
        dc.l $08000900,$09000600,$0a000000,0
        dc.l $08000900,$09000600,$0a000100,0
        dc.l $08000900,$09000600,$0a000200,0
        dc.l $08000900,$09000600,$0a000200,0
        dc.l $08000900,$09000600,$0a000100,0
        dc.l $08000a00,$09000100,$0a000100,0
        dc.l $08000a00,$09000100,$0a000100,0
        dc.l $08000a00,$09000200,$0a000000,0
        dc.l $08000a00,$09000200,$0a000000,0
        dc.l $08000a00,$09000200,$0a000100,0
        dc.l $08000a00,$09000200,$0a000100,0
        dc.l $08000a00,$09000200,$0a000200,0
        dc.l $08000a00,$09000300,$0a000100,0
        dc.l $08000a00,$09000300,$0a000200,0
        dc.l $08000a00,$09000400,$0a000000,0
        dc.l $08000a00,$09000400,$0a000100,0
        dc.l $08000a00,$09000400,$0a000200,0
        dc.l $08000a00,$09000400,$0a000200,0
        dc.l $08000a00,$09000400,$0a000200,0
        dc.l $08000a00,$09000500,$0a000000,0
        dc.l $08000a00,$09000500,$0a000000,0
        dc.l $08000a00,$09000500,$0a000100,0
        dc.l $08000a00,$09000500,$0a000200,0
        dc.l $08000a00,$09000500,$0a000200,0
        dc.l $08000a00,$09000500,$0a000300,0
        dc.l $08000a00,$09000600,$0a000000,0
        dc.l $08000a00,$09000600,$0a000000,0
        dc.l $08000a00,$09000600,$0a000100,0
        dc.l $08000a00,$09000600,$0a000100,0
        dc.l $08000a00,$09000600,$0a000200,0
        dc.l $08000a00,$09000600,$0a000200,0
        dc.l $08000a00,$09000600,$0a000300,0
        dc.l $08000a00,$09000600,$0a000300,0
        dc.l $08000a00,$09000600,$0a000400,0
        dc.l $08000a00,$09000600,$0a000500,0
        dc.l $08000a00,$09000600,$0a000600,0
        dc.l $08000b00,$09000000,$0a000000,0
        dc.l $08000b00,$09000100,$0a000000,0
        dc.l $08000b00,$09000100,$0a000100,0
        dc.l $08000b00,$09000200,$0a000000,0
        dc.l $08000b00,$09000200,$0a000100,0
        dc.l $08000b00,$09000300,$0a000000,0
        dc.l $08000b00,$09000300,$0a000100,0

        dc.l $08000b00,$09000300,$0a000100,0
        dc.l $08000b00,$09000300,$0a000200,0
        dc.l $08000b00,$09000300,$0a000300,0
        dc.l $08000b00,$09000400,$0a000000,0
        dc.l $08000b00,$09000400,$0a000100,0
        dc.l $08000b00,$09000400,$0a000200,0
        dc.l $08000b00,$09000400,$0a000300,0
        dc.l $08000b00,$09000500,$0a000000,0
        dc.l $08000b00,$09000500,$0a000100,0
        dc.l $08000b00,$09000500,$0a000200,0
        dc.l $08000b00,$09000500,$0a000300,0
        dc.l $08000b00,$09000500,$0a000400,0
        dc.l $08000b00,$09000600,$0a000000,0
        dc.l $08000b00,$09000600,$0a000100,0
        dc.l $08000b00,$09000600,$0a000200,0
        dc.l $08000b00,$09000600,$0a000200,0
        dc.l $08000b00,$09000600,$0a000300,0
        dc.l $08000b00,$09000600,$0a000300,0
        dc.l $08000b00,$09000600,$0a000400,0
        dc.l $08000b00,$09000600,$0a000400,0
        dc.l $08000b00,$09000600,$0a000500,0
        dc.l $08000b00,$09000600,$0a000500,0
        dc.l $08000b00,$09000700,$0a000000,0
        dc.l $08000b00,$09000700,$0a000000,0
        dc.l $08000b00,$09000700,$0a000100,0
        dc.l $08000b00,$09000700,$0a000100,0
        dc.l $08000b00,$09000700,$0a000200,0
        dc.l $08000b00,$09000700,$0a000200,0
        dc.l $08000b00,$09000700,$0a000300,0
        dc.l $08000b00,$09000700,$0a000300,0
        dc.l $08000b00,$09000700,$0a000400,0
        dc.l $08000b00,$09000700,$0a000400,0
        dc.l $08000b00,$09000700,$0a000500,0
        dc.l $08000b00,$09000700,$0a000500,0
        dc.l $08000b00,$09000800,$0a000000,0
        dc.l $08000b00,$09000800,$0a000100,0
        dc.l $08000b00,$09000800,$0a000100,0
        dc.l $08000b00,$09000800,$0a000200,0
        dc.l $08000b00,$09000800,$0a000200,0
        dc.l $08000b00,$09000800,$0a000200,0
        dc.l $08000b00,$09000800,$0a000300,0
        dc.l $08000b00,$09000800,$0a000300,0
        dc.l $08000b00,$09000800,$0a000300,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000c00,$09000000,$0a000000,0
        dc.l $08000c00,$09000100,$0a000000,0
        dc.l $08000c00,$09000100,$0a000100,0
        dc.l $08000c00,$09000200,$0a000000,0
        dc.l $08000c00,$09000200,$0a000100,0
        dc.l $08000c00,$09000200,$0a000100,0
        dc.l $08000c00,$09000200,$0a000200,0
        dc.l $08000c00,$09000200,$0a000200,0
        dc.l $08000c00,$09000300,$0a000000,0
        dc.l $08000c00,$09000300,$0a000100,0
        dc.l $08000c00,$09000400,$0a000000,0
        dc.l $08000c00,$09000400,$0a000100,0
        dc.l $08000c00,$09000400,$0a000100,0
        dc.l $08000c00,$09000400,$0a000200,0
        dc.l $08000c00,$09000400,$0a000300,0
        dc.l $08000c00,$09000500,$0a000000,0
        dc.l $08000c00,$09000500,$0a000100,0
        dc.l $08000c00,$09000500,$0a000200,0
        dc.l $08000c00,$09000500,$0a000200,0
        dc.l $08000c00,$09000500,$0a000300,0
        dc.l $08000c00,$09000500,$0a000300,0
        dc.l $08000c00,$09000500,$0a000400,0
        dc.l $08000c00,$09000500,$0a000400,0
        dc.l $08000c00,$09000600,$0a000000,0
        dc.l $08000c00,$09000600,$0a000000,0
        dc.l $08000c00,$09000600,$0a000100,0
        dc.l $08000c00,$09000600,$0a000100,0
        dc.l $08000c00,$09000600,$0a000200,0
        dc.l $08000c00,$09000600,$0a000300,0
        dc.l $08000c00,$09000600,$0a000300,0
        dc.l $08000c00,$09000600,$0a000300,0
        dc.l $08000c00,$09000700,$0a000000,0
        dc.l $08000c00,$09000700,$0a000100,0
        dc.l $08000c00,$09000700,$0a000200,0
        dc.l $08000c00,$09000700,$0a000200,0
        dc.l $08000c00,$09000700,$0a000300,0
        dc.l $08000c00,$09000700,$0a000300,0
        dc.l $08000c00,$09000700,$0a000300,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000700,$0a000500,0
        dc.l $08000c00,$09000700,$0a000500,0
        dc.l $08000c00,$09000700,$0a000500,0
        dc.l $08000c00,$09000800,$0a000000,0
        dc.l $08000c00,$09000800,$0a000000,0
        dc.l $08000c00,$09000800,$0a000100,0
        dc.l $08000c00,$09000800,$0a000100,0
        dc.l $08000c00,$09000800,$0a000200,0
        dc.l $08000c00,$09000800,$0a000200,0
        dc.l $08000c00,$09000800,$0a000300,0
        dc.l $08000c00,$09000800,$0a000300,0
        dc.l $08000c00,$09000800,$0a000400,0
        dc.l $08000c00,$09000800,$0a000400,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000800,$0a000600,0
        dc.l $08000c00,$09000800,$0a000600,0
        dc.l $08000c00,$09000900,$0a000000,0
        dc.l $08000c00,$09000900,$0a000000,0
        dc.l $08000c00,$09000900,$0a000100,0
        dc.l $08000c00,$09000900,$0a000200,0
        dc.l $08000c00,$09000900,$0a000200,0
        dc.l $08000c00,$09000900,$0a000300,0
        dc.l $08000c00,$09000900,$0a000300,0
        dc.l $08000c00,$09000900,$0a000400,0
        dc.l $08000c00,$09000900,$0a000400,0
        dc.l $08000c00,$09000900,$0a000500,0
        dc.l $08000c00,$09000900,$0a000500,0
        dc.l $08000c00,$09000900,$0a000600,0
        dc.l $08000c00,$09000900,$0a000600,0
        dc.l $08000c00,$09000900,$0a000700,0
        dc.l $08000c00,$09000900,$0a000700,0
        dc.l $08000c00,$09000900,$0a000700,0
        dc.l $08000c00,$09000900,$0a000800,0
        dc.l $08000c00,$09000900,$0a000800,0

hertz:	DC.B 0,0,0,0,0,113,91,75,63,54,47,41,36,32,28,25,22,20,18,16
	DC.B 14,13,11,10,9,8,7,6,5,4,3,2,1,0,0
	EVEN
OKNOTM:	DC.W 0


saved0:	dc.l 0
        dc.l 0
SPARAM:	DC.L 0
finprg: equ *
