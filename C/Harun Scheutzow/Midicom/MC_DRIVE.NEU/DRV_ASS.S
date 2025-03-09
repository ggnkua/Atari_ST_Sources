.EXPORT	INTC

OWN_ID			EQU 'MICO'
SSHIFTMD		EQU $044C
MIDSTAT			EQU $FFFFFC04   ;STATUS UND STEUERREGISTER ACIA(MIDI)
MIDDATA			EQU $FFFFFC06
BUSY			EQU $0100
HZ200			EQU $04BA

					.EXPORT	INST_2
INST_2:     movem.l D1-A6,-(SP)        ;REGISTER RETTEN
			move.w	SSHIFTMD,d1
            cmp.w	installed,d1
            beq.s	is_ok
            bsr.s   SMIDI2
            move.w	SSHIFTMD,installed
is_ok:      movem.l (SP)+,D1-A6        ;REGISTER ZURUECKSCHREIBEN
            rts

                .EXPORT INSTALL
INSTALL:        move.l  A0,RCB
                move.w  D0,RCBSIZE
                lea     RCB,A0

*extern void MIDEIN();
               .EXPORT MIDEIN
MIDEIN:			move.w  #0,RCBREAD
                move.w  #0,RCBWRITE
                move.w	#0,INTC
                rts

*ACIA => 8 BIT/ gerade PARITY / 1 STOP-BIT / IRQ ENABLED
SMIDI2:        move.l	d0,-(SP)

                move.w  #34,-(SP)
                trap    #14             ;KBDVBASE (XBIOS 34)
                addq.l  #2,SP
                move.l  D0,KBDVBASE
				move.l	(SP)+,d0
				movea.l KBDVBASE,A0 ;A0 hat Adresse der KBD-Vektoren

				move.l  28(A0),SAVMIDI
				move.l  #BSNEU,28(A0)

				move.l  $08(A0),OLDERR
				move.l  #MIDERR,$08(A0)


inst_maus:		btst	#0,d0
				beq		inst_ikbd				
				move.l  16(A0),SAVMOUSE
				move.l  #MOUSE,16(A0)
					
inst_ikbd:		btst	#1,d0
				beq		inst_ILV
				move.l  32(A0),SAVIKBD
				move.l  #IKBD,32(A0)
					
inst_ILV:		btst	#2,d0
				beq		no_il5
				dc.w	$A000
			   	lea     -$3e(a0),a1
			   	movea.l	(a1),a0
			   	cmp.l	#'XBRA',-12(a0)
		   		beq.s	no_il5
				move.l  (a1),old_n_tim
				move.l  #next_tim,(a1)

no_il5:			move.b  #$95,MIDSTAT    ;midi-Acia init
				move.l  #_SBUFF,SCB
				rts


               DC.B 'XBRA'
               DC.B 'MICO'
old_n_tim:		DC.L	0
next_tim:		ori.w		#$0700,SR
				andi.w		#$FDFF,SR
				move.l		old_n_tim,-(SP)
				rts

				DC.B 'XBRA'
				DC.B 'MICO'
SAVMOUSE:		DC.L 0
MOUSE:			movem.l		D2,-(SP)
				bsr.s		BSN
EMOUS:			movem.l		(SP)+,D2
				move.l		SAVMOUSE,-(SP)
				rts	

               DC.B 'XBRA'
               DC.B 'MICO'
SAVIKBD:	      DC.L 0
IKBD:				movem.l	D2,-(SP)
               bsr.s		BSN
			      movem.l	(SP)+,D2
					move.l	SAVIKBD,-(SP)
               rts

               DC.B 'XBRA'
               DC.B 'MICO'
SAVMIDI:       DC.L 0
BSNEU:         move.b  MIDSTAT,D2
               btst    #$07,D2         ; interrupt durch MIDI?
               beq.s   ENEU            ; wenn nein dann ende
BSNEU2:        btst    #0,D2           ; ja, durch Empfang?
               bne.s   BSNEU1
               move.w  SSEMA,D0
               beq.s   ENEU
               btst    #1,D2
               beq.s   ENEU
               bsr.s   MSENDER          ; wenn nichts empfangen, darf ich senden
               bra.s   BSN
BSNEU1:        andi.b  #$70,D2         ; sonst Fehlerstatus abfragen
               or.b    D2,INTC
               bra.s   MREADER          ; und auslesen
ENEU:		   	rts

BSN:           move.b  MIDSTAT,D2
               btst    #0,D2           ; ja, durch Empfang?
               bne.s   BSN1
               rts
BSN1:          andi.b  #$70,D2         ; sonst Fehlerstatus abfragen
               or.b    D2,INTC
               bra.s   MREADER          ; und auslesen

MSENDER:        movem.l D1/A1-A2,-(SP)
               lea     SCB,A1
               move.w  8(A1),D1        ;getzeiger
               cmp.w   6(A1),D1        ;pushzeiger
               beq.s   NOSEND
               movea.l (A1),A2
               move.b  0(A2,D1.w),MIDDATA ;byte to ACIA
               addi.w  #1,8(A1)
               move.w  4(A1),D1
               cmp.w   8(A1),D1
               bne.s   SEND1
               move.w  #0,8(A1)
               bra.s   SEND1
NOSEND:        move.w  #0,SSEMA
               move.b  #$95,MIDSTAT    ;midi-Acia init
SEND1:         movem.l (SP)+,D1/A1-A2
               rts

MREADER:        movem.l D0-D1/A0,-(SP)
               movea.l RCB,A0
               move.w  RCBSIZE,D0
               move.w  RCBWRITE,D1
               addq.w  #1,D1
               cmp.w   D1,D0
               bne.s   READ1
               moveq   #0,D1
READ1:         move.b  MIDDATA,0(A0,D1.w)
               move.w  D1,RCBWRITE
               movem.l (SP)+,D0-D1/A0
               rts

               DC.B 'XBRA'
               DC.B 'MICO'
OLDERR:        DC.L 0
MIDERR:        ori.b   #$02,INTC
               rts
*ABFRAGE AUF FEHLER WAEHREND DES EMPFANGS (UEBERLAUF DER ACIA)
*extern void MSEND(int LEN,zw_buffer *BUFF);

               .EXPORT MSEND
MSEND:         move.l	A0,BUFFAD       ;Datenbereich
               move.w 	D0,COUN1        ;anzahl Bytes zu Åbertragen
               movem.l	D2-D4/A0/A2-A3,-(SP)        ;REGISTER RETTEN
				
					bsr.s   PACKS
MBACK:         movem.l (SP)+,D2-D4/A0/A2-A3        ;REGISTER ZURUECKSCHREIBEN
               rts

*SENDESCHLEIFE FUER MIDI
PACKS:         moveq   #0,D0	
               move.w  COUN1,D0    ;D0= LEN
               movea.l BUFFAD,A1   ;A1= ^ARRAY OF BYTE
               lea     SCB,A2
               movea.l (A2),A3         ;Sendepuffer
               move.w  4(A2),D3        ;size
               move.w  D0,D0
               beq.s   EPACK           ; GOTO ENDE
			   move.w  #-15,D1
				
PLOOP0:        move.w  6(A2),D2        ;schreibzeiger
               move.w  8(A2),D4        ;lesezeiger
PLOOP1:        move.b  (A1),0(A3,D2.w)
               addq.w  #1,D2
               cmp.w   D2,D4
               beq.s   PLOOP0
               cmp.w   D2,D3
               bne.s   PBYTE
               moveq   #0,D2
PBYTE:         move.w  D2,6(A2)
               addq.w  #1,D1
               bne.s   PLOOP2
			   move.w  SSEMA,d1
			   bne.s   msreset	
               move.w  #1,SSEMA
               move.b  #$B5,MIDSTAT    ;midi-Acia init
               bra.s   PLOOP2
msreset:       move.w  #-15,d1
PLOOP2:        addq.l  #1,A1
               dbcs    D0,PLOOP1
               move.w  #1,SSEMA
               move.b  #$B5,MIDSTAT    ;midi-Acia init
EPACK:         rts

installed:		DC.W 0
INTC:          DC.W 0
KBDVBASE:      DC.L 0
BUFFAD:        DC.L 0
COUN1:         DC.W 0
* control-Block fÅr MIDI-Senden
SCB:           DC.L 0
SCBSIZE:       DC.W 16990
SCBWRITE:      DC.W 0
SCBREAD:       DC.W 0
scblow:        dc.w 0
scbhigh:       dc.w 0
SSEMA:         DC.W 0
* control fÅr midi-Empfang
RCB:           DC.L 0
RCBSIZE:       DC.W 0
RCBREAD:       DC.W 0
RCBWRITE:      DC.W 0
rcblow:        dc.w 0
rcbhigh:       dc.w 0
.BSS
_SBUFF:        DS.L 4250

					END
