;-------------------------------------------
; HARDWARE SCROLLING DEMO FOR STE..
;
;       CALLED:
;       THE QUITE BIG DEMO..
;
;       CODING BY:
;       THE CAPED CRUSADER.
;       UNDERCOVER ELEPHANT.
;
;       GRAFIX BY:
;       MR PIXAR.
;
;       STARTED:
;       4/9/92
;       FINISHED:
;       9/9/92- Never!!!
;       ACTUALLY FINISHED:
;       21/12/92
;
;       FEATURES:
;       VERTICALLY OVERSCAN.
;       25Khz PRO-TRACKER PLAYER
;       320*230 SCROLLING WINDOW CONTROLLED BY THE MOUSE.
;       16*16 FONT SCROLLER IN THE LOWER BORDER.
;
;       CPU TIME:
;       ABOUT 52% USED.
;
;-------------------------------------------
; 20090203	AjB		Run from Desktop
;					Tested on STeem 3.2
;					Assembles ok with Devpac 3
;-------------------------------------------
DESK			equ	1	; Desktop Version ON-OFF

	include fbdef.s
	include fbdesk.s
	opt O+
	opt OW-

;EQUATES...
;
ORG_ADR:        EQU     $3000
PDS_ON:         EQU     0
;
MOUSE_ON:       EQU     1
KHZ_245:        EQU     1
;
;
SCREEN:         EQU     $F8000
;
backcol         EQU     $002
forecol         EQU     $dde
delay           EQU     7
HSCROLL:        EQU     $FFFF8265
LINEWID:        EQU     $FFFF820F
VBASELO:        EQU     $FFFF820D
BUFFWIDTH:      EQU     960
BUFFHIEGHT:     EQU     600
SCRNWIDTH:      EQU     320
SCRNHIEGHT:     EQU     230
SCROLLINE:      EQU     (160*8)

                IFNE    KHZ_245
bufsize         EQU     500
dmamask         EQU     %00000010
freqconst       EQU     $8EFE3B
                ELSE
bufsize         EQU     250
dmamask         EQU     %00000001
freqconst       EQU     $8EFE3B*2
                ENDC

;-------------------------------------------
; THE MACROS..
;
FRMINT:         macro
                move.w  d0,-(a7)
                move.w  #1,d0
                clr.w   vcount
wframe\@:       cmp.w   vcount,d0
                bne.s   wframe\@
                move.w  (a7)+,d0
                endm

;-------------------------------------------
;
			ifeq	DESK
                ORG     ORG_ADR
			endc

START:
	ifne	DESK
		desk_start
	endc
			
realstart:      
				MOVE.L  A7,STORE_STACK

		LEA     $FFFF8240,A0
                REPT    16
                MOVE.W  #BACKCOL,(A0)+
                ENDR

                move.b  #0,$ffff820a            ; Low Res
                
                LEA     STACK,A7
        
                JSR     makevoltab              ;
                JSR     makefrqtab              ;NEW MUSIC PLAYER
                JSR     mt_init                 ;
                JSR     start_music             ;

                MOVE.B  HSCROLL.W,OLDHSCROLL
                MOVE.B  LINEWID.W,OLDLINEWID

		BSR	STORE_SYS
		
                MOVE.W #$2700,SR
                
                clr.b   $fffffa1b.w
                or.b    #1,$fffffa07.w
                or.b    #1,$fffffa13.w

                move.l  #a_int,$134.w
                or.b    #%00100000,$fffffa07.w
                or.b    #%00100000,$fffffa13.w
                move.b  #0,$fffffa19.w

		; 2009 Turn of Timer C, it stuffs things up for us
		ifne DESK
			bclr	#5,$fffffa09.w
			bclr	#5,$fffffa15.w
		endc

                IFNE    MOUSE_ON
                 BSR    ABSOLUTE_MOUSE_INIT
                 MOVE.L #ABSOLUTE_MOUSE_INTERRUPT,$118.W
                 BSET   #6,$FFFFFA09.W
                 BSET   #6,$FFFFFA15.W
                ENDC
                
                MOVE.L  #HBL,$120.W
                MOVE.L  #VBL,$70.W
                BCLR.B  #3,$FFFFFA17.W
                MOVE.W  #$2300,SR

                move.w  #delay,counter
                movem.l palette,d0-d7
                movem.l d0-d7,MAINPAL

                IFNE    MOUSE_ON
MAIN_LOOP:      FRMINT

                BSR     SCAN_FIRES              
                BEQ     EXIT

                BSR     OURMAUS
                BRA.S   MAIN_LOOP
                ELSE

MAIN_LOOP:      FRMINT
                CMP.B   #$4D,$FFFFFC02
                BNE.S   .NXT
                ADDQ.B  #1,MOUSEDATAX

.NXT:           CMP.B   #$4B,$FFFFFC02
                BNE.S   .NXT2
                SUBQ.B  #1,MOUSEDATAX

.NXT2:          CMP.B   #$50,$FFFFFC02
                BNE.S   .NXT3
                ADDQ.B  #1,MOUSEDATAY

.NXT3:          CMP.B   #$48,$FFFFFC02
                BNE.S   .NOKEY
                SUBQ.B  #1,MOUSEDATAY

.NOKEY:         CMP.B   #$F,$FFFFFC02
                BNE.S   .NUT
                BRA.S   MAIN_LOOP2

.NUT            BSR     OURMAUS
                CMP.B   #$39,$FFFFFC02
                BEQ     EXIT
                BRA.S   MAIN_LOOP


MAIN_LOOP2:     FRMINT
                CMP.B   #$4D,$FFFFFC02
                BNE.S   .NXT
                ADDQ.B  #1,MOUSEDATAX
                BRA.S   .DO_KEY
                
.NXT:           CMP.B   #$4B,$FFFFFC02
                BNE.S   .NXT2
                SUBQ.B  #1,MOUSEDATAX
                BRA.S   .DO_KEY
                
.NXT2:          CMP.B   #$50,$FFFFFC02
                BNE.S   .NXT3
                ADDQ.B  #1,MOUSEDATAY
                BRA.S   .DO_KEY
                
.NXT3:          CMP.B   #$48,$FFFFFC02
                BNE.S   .NOKEY
                SUBQ.B  #1,MOUSEDATAY
                BRA.S   .DO_KEY
                
.NOKEY:         CLR.W   MOUSEDATAX
                CLR.W   MOUSEDATAY

                CMP.B   #$F,$FFFFFC02
                BNE.S   .DO_KEY
                BRA     MAIN_LOOP

.DO_KEY:        BSR     OURMAUS
                CMP.B   #$39+80,$FFFFFC02
                BEQ     EXIT
                BRA     MAIN_LOOP2
                ENDC

;---------------------------------------------
; EXIT DEMO TO PDS OR NORMAL...
;
EXIT:           MOVE.W  #$2700,SR
                BSR     STOP_MUSIC

                MOVE.B  OLDHSCROLL,HSCROLL.W
                MOVE.B  OLDLINEWID,LINEWID.W
                
		BSR	RESET_SYS

                MOVEQ   #$8,D0
                BSR     WRITE_IKBD              ; RESUME MOUSE HANDLER
                
                MOVE.L  STORE_STACK,A7
                
                CLR.W   $FFFF8240

	ifne	DESK
		desk_stop
	endc

		RTS
		
;------------------------------------------------------

OLDHSCROLL      DS.W    1
OLDLINEWID      DS.W    1
                                
;------------------------------------------------------
; STORE AND RESTORE THE SYSTEM...
;
STORE_SYS:	LEA	SYS_TEMP(PC),A0
		MOVE	#$2700,SR
		MOVE.L	$68.W,(A0)+
		MOVE.L	$70.W,(A0)+
		MOVE.L	$110.W,(A0)+
		MOVE.L	$114.W,(A0)+
		MOVE.L	$120.W,(A0)+
		MOVE.L	$134.W,(A0)+
		MOVE.B	$FFFFFA07.W,(A0)+
		MOVE.B	$FFFFFA09.W,(A0)+
		MOVE.B	$FFFFFA13.W,(A0)+
		MOVE.B	$FFFFFA15.W,(A0)+
		MOVE.B	$FFFFFA19.W,(A0)+
		MOVE.B	$FFFFFA1B.W,(A0)+
		MOVE.B	$FFFFFA1D.W,(A0)+
		MOVE.B	$FFFFFA1F.W,(A0)+
		MOVE.B	$FFFFFA21.W,(A0)+
		MOVE.B	$FFFFFA25.W,(A0)+
		MOVE.B	$FFFF820A.W,(A0)+
		MOVE.B	$FFFF8260.W,(A0)+
		MOVE.L	$FFFF8200.W,(A0)+
		MOVE	SR,(A0)+
		MOVE	#$2300,SR
		MOVEM.L	$FFFF8240.W,D0-D7
		MOVEM.L	D0-D7,(A0)
		RTS

RESET_SYS:	MOVE	#$2700,SR
		LEA	SYS_TEMP(PC),A0
		MOVE.L	(A0)+,$68.W
		MOVE.L	(A0)+,$70.W
		MOVE.L	(A0)+,$110.W
		MOVE.L	(A0)+,$114.W
		MOVE.L	(A0)+,$120.W
		MOVE.L	(A0)+,$134.W
		MOVE.B	(A0)+,$FFFFFA07.W
		MOVE.B	(A0)+,$FFFFFA09.W
		MOVE.B	(A0)+,$FFFFFA13.W
		MOVE.B	(A0)+,$FFFFFA15.W
		MOVE.B	(A0)+,$FFFFFA19.W
		MOVE.B	(A0)+,$FFFFFA1B.W
		MOVE.B	(A0)+,$FFFFFA1D.W
		MOVE.B	(A0)+,$FFFFFA1F.W
		MOVE.B	(A0)+,$FFFFFA21.W
		MOVE.B	(A0)+,$FFFFFA25.W
		MOVE.B	(A0)+,$FFFF820A.W
		MOVE.B	(A0)+,$FFFF8260.W
		MOVE.L	(A0)+,$FFFF8200.W
		MOVE	#$2300,SR
		MOVE	(A0)+,SR
		MOVEM.L	(A0)+,D0-D7
		MOVEM.L	D0-D7,$FFFF8240.W
		RTS

SYS_TEMP:	DS.W	37
		EVEN

STORE_STACK:	DS.L	1
		EVEN

;-------------------------------------------
; THE VERTICAL BLANK...
;
VBL:            
				move.b  #0,$fffffa19.w
                move.l  #a_int,$134.w
                move.b  #99,$fffffa1f.w
                move.b  #4,$fffffa19.w

                clr.b   $fffffa1b.w
                move.l  #hbl,$120.w
                move.b  #227,$fffffa21.w
                move.b  #8,$fffffa1b.w

                IFNE    MOUSE_ON

                 ADDQ.L #1,$466.W
                 MOVE.L D0,-(SP)
                 MOVE   #13,D0
                 JSR    WRITE_IKBD
                 MOVE.L (SP)+,D0

                ENDC

                MOVEM.L A0-A6/D0-D7,-(A7)

                MOVE.L  MAINPAL,$FFFF8240
                MOVE.L  MAINPAL+4,$FFFF8240+4
                MOVE.L  MAINPAL+8,$FFFF8240+8
                MOVE.L  MAINPAL+12,$FFFF8240+12
                MOVE.L  MAINPAL+16,$FFFF8240+16
                MOVE.L  MAINPAL+20,$FFFF8240+20
                MOVE.L  MAINPAL+24,$FFFF8240+24
                MOVE.L  MAINPAL+28,$FFFF8240+28

                ;MOVE.W #$F00,$FFFF8240
                
		move.w #$2700,sr	; 2009. Best mask IRQs whilst stuffing the registers

                MOVE.W  XMOUSE,D0
                AND.W   #15,D0
                MOVE.B  D0,HSCROLL.W
                TST.B   D0
                BNE     .NON0
                MOVE.B  #160,LINEWID.W
                BRA     .JOIN
.NON0:          MOVE.B  #156,LINEWID.W

.JOIN:          LEA     BIGBUFF,A0
                MOVE.W  YMOUSE,D0
                MULU    #3*160,D0
                ADDA.L  D0,A0
                MOVE.W  XMOUSE,D0
                ASR.W   #1,D0
                AND.W   #$FFF8,D0
                ADDA.W  D0,A0

                MOVE.L  A0,VBLTEMP
                MOVE.B  VBLTEMP+1,$FFFF8205.W
                MOVE.B  VBLTEMP+2,$FFFF8207.W
                MOVE.B  VBLTEMP+3,$FFFF8209.W

		move.w #$2300,sr	; 2009. Best mask IRQs whilst stuffing the registers

                JSR     DO_MUSIC                ;MUST BE BEFORE COLOURS....
                ;MOVE.W #$F0,$FFFF8240
                BSR     DO_HSCROLL              ;THE SCROLLER.
                ;MOVE.W #$F,$FFFF8240
                BSR     DO_CYCLE                ;COLOUR CYCLING
                ;MOVE.W #$002,$FFFF8240
                
                ADDQ.W  #1,VCOUNT
                MOVEM.L (A7)+,A0-A6/D0-D7
                RTE

VBLTEMP:        DS.L    1
                EVEN
                
MAINPAL:        DS.W    16
                EVEN

DO_CYCLE:       subq.w  #1,counter
                bne.s   skip_cycle
                move.w  #delay,counter
                lea     MAINPAL+2,a0
                move.w  offset,d0
                move.w  #backcol,0(a0,d0.w)
                addq.w  #2,d0
                cmp.w   #28,d0
                bne.s   skip
                moveq   #0,d0
skip            move.w  d0,offset
                move.w  #forecol,0(a0,d0.w)
skip_cycle:     RTS

;---------------------------------------------------------
; THE ACTUAL HARDWARE SCROLL ROUTINE...
;
SCROLL_X:       DC.W    0
SCROLL_PT:      DC.L    SCROLL_BUF
CHAR_C:         DC.W    0

DO_HSCROLL:     TST.W   SCROLL_X
                BNE.s   .scroll_ok
                BSR     PRINT_XXX

.SCROLL_OK:     move.l  scrnpt1,d0
                moveq   #0,d1
                move.w  scroll_x(pc),d1
                move.w  d1,d2
                lsr.w   #1,d1
                and.w   #-8,d1
                add.l   d1,d0
                move.w  #96,d7
                and.w   #15,d2
                beq     .ok
                sub.w   #4,d7
.ok             sub.l   #128,d0                         ;336

                MOVE.B  D0,SCRL1+3
                ASR.W   #8,D0
                MOVE.B  D0,SCRL2+3
                SWAP    D0
                MOVE.B  D0,SCRL3+3

                Move.b  d2,scrl4+3
                move.b  d7,scrl5+3
                addq.w  #2,scroll_x
                and.w   #15,scroll_x
                RTS

SCROLL_PT1      DC.L    SCROLL_TEXT
SCROLL_PT2      DC.L    SCROLL_TEXT

print_XXX:      clr.w   d0
                move.l  scroll_pt1(pc),a0
                move.b  (a0)+,d0
                bne     .textok
                lea     SCROLL_TEXT,a0
                move.b  (a0)+,d0
.TEXTOK         move.l  a0,scroll_pt1

                move.l  scrnpt1,a1
                LEA     SCROLLINE(A1),A1
                bsr     print_char2
        
                clr.w   d0
                move.l  scroll_pt2(pc),a0
                move.b  (a0)+,d0
                bne     .textok1
                lea     SCROLL_TEXT,a0
                move.b  (a0)+,d0

.textok1        move.l  a0,scroll_pt2
                move.l  scrnpt1,a1
                LEA     SCROLLINE(A1),A1
                add.l   #160+16,a1                      ;+32
                bsr     print_char2

                add.l   #8,scrnpt1
                addq.w  #1,char_c
                cmp.w   #22,char_c                      ;+24
                bne     .xt
                move.l  #scroll_buf,scrnpt1
                clr.w   char_c
.xt             rts
        
print_char      lea     SCROLL_font,a2
                sub.b   #32,d0
                mulu    #384,d0
                add.l   d0,a2
ii              set     0
                rept    32
                move.l  (a2)+,ii(a1)
                move.w  (a2)+,ii+4(a1)
                move.l  (a2)+,ii+8(a1)
                move.w  (a2)+,ii+12(a1)
ii              set     ii+352                  ; +8
                endr
                rts

print_char2:    lea     SCROLL_font,a2
                sub.b   #32,d0
                mulu    #128,d0
                add.l   d0,a2
II              SET     0
                REPT    16
                MOVE.L  (A2)+,D4
                MOVE.L  (A2)+,D5
                ;MOVE.W (A2),D6
                ;MOVE.W (A2),D7
                MOVE.L  D4,II(A1)
                MOVE.L  D5,II+4(A1)
II              SET     II+352                  ; +8
                ENDR
                RTS

;---------------------------------------------------------
; BORDER SHITE...
;
a_int:          move.b  #0,$fffffa19.w
                move.l  #remtop1,$68.w
                move.w  #$2700,sr
                stop    #$2100
                rte

remtop1:        move.l  #RAINBOW,$68.w
                stop    #$2100
                rte

RAINBOW:        move.w  #$2700,sr
                move.l  #caan,$68.w
                move.w  d0,-(sp)
                move.w  #23,d0
wait:           dbra    d0,wait
                move.b  #0,$ff820a
                rept    24
                nop
                endr
                move.b  #2,$ff820a
                move.w  (sp)+,d0
caan:           rte


hbl:            clr.b   $fffffa1b.w
                move.l  #hbl2,$120.w
                move.b  #1,$fffffa21.w
                move.b  #8,$fffffa1b.w
                stop    #$2500
                rte

hbl2:           move.l  #hsht,$120.w
                move.w  #$2700,sr
                move.l  d0,-(sp)
                moveq   #$24,d0
wsix:           dbf     d0,wsix
                move.b  #0,$ff820a
                moveq   #2,d0
wfif:           dbf     d0,wfif
                move.b  #2,$ff820a
                move.l  (sp)+,d0
hsht:           
                MOVE.L  #CLEAR_SCRLPAL,$120.W
                CLR.b   $fffffa1b.w
                move.b  #2,$fffffa21.w
                move.b  #8,$fffffa1b.w
                rte


CLEAR_SCRLPAL:  MOVE.B  #0,$FFFFFA1B.W
                MOVE.B  #1,$FFFFFA21.W
                MOVE.L  #$0000000,$FFFF8240
                MOVE.L  #$0000000,$FFFF8244
                MOVE.L  #$0000000,$FFFF8248
                MOVE.L  #$0000000,$FFFF824C
                MOVE.L  #$0000000,$FFFF8250
                MOVE.L  #$0000000,$FFFF8254
                MOVE.L  #$0000000,$FFFF8258
                MOVE.L  #$0000000,$FFFF825C
                MOVE.L  #SCRLHBL,$120.W
                MOVE.B  #8,$FFFFFA1B.W
                RTE

SCRLHBL:        ;CLR.B  $FFFFFA1B.W

                ;MOVE.B #1,$FFFFFA21.w

scrl1:          move.b  #0,$ffff8209.w          ; VIDADDR
scrl2:          move.b  #0,$ffff8207.w
scrl3:          move.b  #0,$ffff8205.w
scrl4:          move.b  #0,$ffff8265.w          ; HSCROLL
scrl5:          move.b  #0,$ffff820f.w          ; LINEWID

                MOVE.L  #COL_CHANGE,$120.W
                ;MOVE.B #8,$FFFFFA1B.W
                RTE

COL_CHANGE:     MOVE.L  SCROLLPAL,$ffff8240.w           ;SECOND PALETTE
                MOVE.L  SCROLLPAL+4,$FFFF8244.W
                MOVE.L  SCROLLPAL+8,$FFFF8248.W
                MOVE.L  SCROLLPAL+12,$FFFF824C.W

                ;CLR.B  $FFFFFA1B.W	
                RTE

;-----------------------------------------------------------------------------
; Oberje's Mouse Code ( Thanks griff! )
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; SCAN BUTTONS - ANY BUTTON TO EXIT
;-----------------------------------------------------------------------------
SCAN_FIRES:
        MOVE.B MOUSEXY+1,D0
        MOVE.B D0,D1
        LSR.W #2,D1
        OR.W D1,D0
        NOT.B D0
        AND.B #%1,D0
        TST.B D0
        RTS

;-----------------------------------------------------------------------------
; INITIALISE MOUSE
;-----------------------------------------------------------------------------
MOUSE_XMAX              EQU     (BUFFWIDTH-SCRNWIDTH)
MOUSE_YMAX              EQU     (BUFFHIEGHT-SCRNHIEGHT)

ABSOLUTE_MOUSE_INIT:
                MOVE #$15,D0    
                BSR WRITE_IKBD          ; END JOYSTICK AUTO MODE
                MOVE #9,D0
                BSR WRITE_IKBD          ; SELECT MOUSE ABSOLUTE MODE
                MOVE #(MOUSE_XMAX>>8),D0
                BSR WRITE_IKBD          ; MAX X
                MOVE #(MOUSE_XMAX&$FF),D0
                BSR WRITE_IKBD
                MOVE #(MOUSE_YMAX>>8),D0
                BSR WRITE_IKBD
                MOVE #(MOUSE_YMAX&$FF),D0
                BSR WRITE_IKBD          ; MAX Y

SET_MOUSE:      MOVEQ #$E,D0
                BSR WRITE_IKBD          ; SET INTERNAL COORDS
                MOVE #0,D0
                BSR WRITE_IKBD          ; NULL
                MOVE #0,D0
                BSR WRITE_IKBD          ;
                MOVE #0,D0
                BSR WRITE_IKBD          ; X = 0
                MOVE #0,D0
                BSR WRITE_IKBD
                MOVE #0,D0              ; Y = 0
                BSR WRITE_IKBD

                MOVE #$D,D0                     ; READ ABSOLUTE MOUSE POSITION
                BSR WRITE_IKBD
                RTS
        
;-----------------------------------------------------------------------------
; MOUSE HANDLER BY GRIFF & OBERJE & THE CREEPER
;-----------------------------------------------------------------------------
ABSOLUTE_MOUSE_INTERRUPT:
KEY_ROUT:       MOVE #$2500,SR                  ; IPL 5
                MOVE D0,-(SP)                   ; SAVE REG
                MOVE.B $FFFFFC00.W,D0           ; BYTE
                BTST #7,D0                      ; NOT A BYTE
                BEQ.S END                       
                BTST #0,D0                      ; ERROR?
                BEQ.S END
KEY_READ:       MOVE.B $FFFFFC02.W,D0           ; D0=BYTE
                CMP.B #$F7,D0                   ; MOUSE PACKET?
                BEQ.S START_MOUSE               ; YEP -->
                MOVE.B D0,KEY                   ; SAVE KEYVAL
END:            MOVE (SP)+,D0
ENDI:           BCLR #6,$FFFFFA11.W
                RTE

KEY             DC.W    0

START_MOUSE:    
                MOVE.L  #MOUSEB1,$118.W         ; NEXT ROUT
                BRA.S   END
MOUSEB1:        MOVE.L  #MOUSEB2,$118.W
                MOVEM.W D0-D1,-(A7)
                MOVE.B  $FFFFFC02.W,D0
                MOVE.B  D0,D1
                LSR.B   #1,D1
                EOR.B   D1,D0
                EOR.B   D0,NEWMOUSEX-1          ; BYTE 2 IS BUTTON STATUS

                MOVEM.W (A7)+,D0-D1
                BRA.S   ENDI

MOUSEB2:        MOVE.L  #MOUSEB3,$118.W
                MOVE.B  $FFFFFC02.W,NEWMOUSEX   ; BYTE 3 IS X HIGH
                BRA.S   ENDI

MOUSEB3:        MOVE.L  #MOUSEB4,$118.W         ; BYTE 4 IS X LOW
                MOVE.B  $FFFFFC02.W,NEWMOUSEX+1
                BRA.S   ENDI

MOUSEB4:        MOVE.L  #MOUSEB5,$118.W         ; BYTE 5 IS Y HIGH
                MOVE.B  $FFFFFC02.W,NEWMOUSEX+2
                BRA.S   ENDI

MOUSEB5:        MOVE.L  #KEY_ROUT,$118.W                ; BYTE 6 IS Y LOW
                MOVE.B  $FFFFFC02.W,NEWMOUSEX+3

                MOVE.W  NEWMOUSEX,MOUSEX
                MOVE.W  NEWMOUSEY,MOUSEY

                MOVE.W  NEWMOUSEXY,MOUSEXY

                BRA     ENDI

;-----------------------------------------------------------------------------
; WRITE D0 TO IKBD
;-----------------------------------------------------------------------------
WRITE_IKBD:     BTST.B  #1,$FFFFFC00.W
                BEQ.S   WRITE_IKBD
                MOVE.B  D0,$FFFFFC02.W
                RTS

;-----------------------------------------------------------------------------
; FLUSH IKBD
;-----------------------------------------------------------------------------
FLUSH           BTST.B  #0,$FFFFFC00.W
                BEQ.S   FLOK
                MOVE.B  $FFFFFC02.W,D0
                BRA.S   FLUSH
FLOK            RTS

;-----------------------------------------------------------------------------
; ASK MOUSE FOR POSITION!!!
;-----------------------------------------------------------------------------
MOUSE_VBI:
                ADDQ.L  #1,$466.W

                MOVE.L  D0,-(SP)

                MOVE    #$D,D0
                BSR     WRITE_IKBD

                MOVE.L  (SP)+,D0

                RTE

MOUSEXY         DC.W    0
MOUSEX          DC.W    0
MOUSEY          DC.W    0

NEWMOUSEXY      DC.W    0
NEWMOUSEX       DC.W    0
NEWMOUSEY       DC.W    0

;-----------------------------------------------------------------------------
; OURMOUS - Oberje's Patch
;-----------------------------------------------------------------------------
OURMAUS:
                MOVE.W  MOUSEX,XMOUSE
                MOVE.W  MOUSEY,YMOUSE
                RTS

;------------------------------------------------------------------
; THE MUSIC ROUTINE GOES HERE..
;
                DC.B    " MUSIC PLAYER "
                EVEN
                
MWDATA          EQU     $FFFF8922
MWMASK          EQU     $FFFF8924

MICROWIRE:      move.w  #$7FF,MWMASK.w
                move.w  d0,MWDATA.w
.wait           cmp.w   #$7FF,MWMASK.w
                bne.s   .wait
                rts

;-----------------------------------------------------------------------
; The actual music player...
;
start_music:    ;MOVE.W #$2700,SR
                LEA     SUPER_SWITCH(PC),A0
                MOVE.L  A0,$B0.W
                
                LEA.L   setsam_dat(PC),A6
                MOVE.W  #$7ff,$ffff8924
                MOVEQ   #3,D6
.mwwritx        CMP.W   #$7ff,$ffff8924
                BNE.S   .mwwritx                        ; setup the PCM chip
                MOVE.W  (A6)+,$ffff8922
                DBF     D6,.mwwritx
                CLR.B   $FFFF8901.W
                MOVE.B  #dmamask,$FFFF8921.W    ; set khz
                BSR     Set_DMA
.exitste        ;MOVE.W #$2300,SR
                RTS

SUPER_SWITCH:   BCHG    #5,(SP)
                RTE
                
Set_DMA         MOVE.L  stebuf_ptrs(PC),A0
                MOVE.L  stebuf_ptrs+4(PC),stebuf_ptrs
                MOVE.L  A0,stebuf_ptrs+4
                LEA     temp(PC),A6
                MOVE.L  A0,(A6)                 
                MOVE.B  1(A6),$ffff8903.W
                MOVE.B  2(A6),$ffff8905.W       ; set start of buffer
                MOVE.B  3(A6),$ffff8907.W
                LEA     (bufsize*2)(A0),A0
                MOVE.L  A0,(A6)
                MOVE.B  1(A6),$ffff890f.W
                MOVE.B  2(A6),$ffff8911.W       ; set end of buffer
                MOVE.B  3(A6),$ffff8913.W
                MOVE.B  #1,$FFFF8901.W          ; start STE dma.
                RTS
                
; Setup for ST (YM2149 replay via interrupts)

temp:           dc.l    0
setsam_dat:     dc.w    %0000000011010100       ;mastervol
                dc.w    %0000010010000110       ;treble
                dc.w    %0000010001000110       ;bass
                dc.w    %0000000000000001       ;mixer

stop_music:     CLR.B $FFFF8901.W               ; stop STE dma.
                RTS 

; Create the 65 volume lookup tables

makevoltab:     MOVE.L  #vol_tab+256,D0
                CLR.B   D0
                MOVE.L  D0,A0
                MOVE.L A0,voltab_ptr
                LEA 16640(A0),A0
                MOVEQ #$40,D0 
.lp1            MOVE.W #$FF,D1 
.lp2            MOVE.W D1,D2 
                EXT.W D2
                MULS D0,D2 
                ASR.L #7,D2
                MOVE.B D2,-(A0)
                DBF D1,.lp2
                DBF D0,.lp1
                RTS 

; Create the Frequency lookup table.

makefrqtab:     LEA freqtabs(PC),A0
                MOVE.W #$30,D1 
                MOVE.W #$36F,D0
                MOVE.L #freqconst,D2 
.lp             SWAP D2
                MOVEQ #0,D3 
                MOVE.W D2,D3 
                DIVU D1,D3 
                MOVE.W D3,D4 
                SWAP D4
                SWAP D2
                MOVE.W D2,D3 
                DIVU D1,D3 
                MOVE.W D3,D4 
                MOVE.L D4,(A0)+
                ADDQ.W #1,D1 
                DBF D0,.lp
                RTS 
freqtab         DS.W 96
freqtabs        DS.W 1760

; Vbl buffer maker and sequencer

do_music        LEA ch1s(PC),A0
                LEA ch3s(PC),A2
                MOVE.L stebuf_ptrs(PC),A4
                BSR do2channels
                BSR do2channels

                MOVE.L stebuf_ptrs(PC),A4
                LEA 1(A4),A4
                LEA ch2s(PC),A0
                LEA ch4s(PC),A2
                BSR do2channels
                BSR do2channels

                BSR Set_DMA
                BSR mt_music 
                RTS

; Create two channels of data.

do2channels     TRAP    #12
                MOVE.L SP,oldsp
                LEA freqtab(PC),A5
                MOVE.L A4,A7                    ; A7-> samp buffer
.vc2            MOVEM.W aud_per(A2),D6/D7       ; freq(amiga period)/vol
                ADD.W D6,D6
                ADD.W D6,D6
                MOVEM.W 0(A5,D6.W),D6/A4        ; freq whole.w/freq frac.w
                EXT.L D7
                ASL.W #8,D7
                ADD.L voltab_ptr(PC),D7         ; -> volumetable 
                MOVEQ #0,D4
                MOVE.W curoffywhole(A2),D4
                MOVE.W curoffy_frac(A2),D5
                MOVE.L vcaddr(A2),A6
.vc1            MOVEM.W aud_per(A0),D2/D3       ; freq(amiga period)/vol
                ADD.W D2,D2
                ADD.W D2,D2
                MOVEM.W 0(A5,D2.W),D2/A3        ; freq whole.w/freq frac.w
                EXT.L D3
                ASL.W #8,D3
                ADD.L voltab_ptr(PC),D3         ; -> volumetable 
                MOVEQ #0,D0
                MOVE.W curoffywhole(A0),D0
                MOVE.W curoffy_frac(A0),D1
                MOVE.L vcaddr(A0),A1
                REPT bufsize/2
                ADD.W A3,D1
                ADDX.W D2,D0
                ADD.W A4,D5                     ; shift freq    
                ADDX.W D6,D4    
                MOVE.B (A1,D0.L),D3
                MOVE.L D3,A5 
                MOVE.B (A5),D3                  ; first byte(volume converted)
                MOVE.B (A6,D4.L),D7
                MOVE.L D7,A5
                ADD.B (A5),D3                   ; +second byte(volume converted) 
                MOVE.B D3,(A7)+                 ; store
                ENDR
                CMP.L endoffy(A0),D0
                BLT.S .ok1
                SUB.W suboffy(A0),D0
.ok1            MOVE.W D0,curoffywhole(A0)
                MOVE.W D1,curoffy_frac(A0)
                CMP.L endoffy(A2),D4
                BLT.S .ok2
                SUB.W suboffy(A2),D4
.ok2            MOVE.W D4,curoffywhole(A2)
                MOVE.W D5,curoffy_frac(A2)
                MOVE.L A7,A4
                MOVE.L oldsp(PC),SP
                TRAP    #12
                RTS

                RSRESET
vcaddr          RS.L 1
endoffy         RS.L 1
suboffy         RS.W 1
curoffywhole    RS.W 1
curoffy_frac    RS.W 1
aud_addr        RS.L 1
aud_len         RS.W 1
aud_per         RS.W 1
aud_vol         RS.W 1

oldsp           DC.L 0
stebuf_ptrs     DC.L stebuf1
                DC.L stebuf2
stebuf1:        DS.W bufsize 
stebuf2:        DS.W bufsize 

; Hardware-registers & data --
ch1s
grf1lc          DC.L stebuf1
grf1len         DC.L 0
grf1rpt         DC.W 0
grf1pos         DC.W 0
grf1frc         DC.W 0
ch1t
aud1lc          DC.L dummy
aud1len         DC.W 0
aud1per         DC.W 0
aud1vol         DC.W 0
                DS.W 3

ch2s
grf2lc          DC.L stebuf1
grf2len         DC.L 0
grf2rpt         DC.W 0
grf2pos         DC.W 0
grf2frc         DC.W 0
ch2t
aud2lc          DC.L dummy
aud2len         DC.W 0
aud2per         DC.W 0
aud2vol         DC.W 0
                DS.W 3

ch3s
grf3lc          DC.L stebuf1
grf3len         DC.L 0
grf3rpt         DC.W 0
grf3pos         DC.W 0
grf3frc         DC.W 0
ch3t
aud3lc          DC.L dummy
aud3len         DC.W 0
aud3per         DC.W 0
aud3vol         DC.W 0
                DS.W 3

ch4s
grf4lc          DC.L stebuf1
grf4len         DC.L 0
grf4rpt         DC.W 0
grf4pos         DC.W 0
grf4frc         DC.W 0
ch4t
aud4lc          DC.L dummy
aud4len         DC.W 0
aud4per         DC.W 0
aud4vol         DC.W 0
                DS.W 3

shfilter        DC.W 0
dmactrl         DC.W 0

dummy           DC.L 0,0,0,0

;********************************************  ; 100% FIXED VERSION
;* ----- Protracker V1.1B Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1991  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

n_note          EQU     0  ; W
n_cmd           EQU     2  ; W
n_cmdlo         EQU     3  ; B
n_start         EQU     4  ; L
n_length        EQU     8  ; W
n_loopstart     EQU     10 ; L
n_replen        EQU     14 ; W
n_period        EQU     16 ; W
n_finetune      EQU     18 ; B
n_volume        EQU     19 ; B
n_dmabit        EQU     20 ; W
n_toneportdirec EQU     22 ; B
n_toneportspeed EQU     23 ; B
n_wantedperiod  EQU     24 ; W
n_vibratocmd    EQU     26 ; B
n_vibratopos    EQU     27 ; B
n_tremolocmd    EQU     28 ; B
n_tremolopos    EQU     29 ; B
n_wavecontrol   EQU     30 ; B
n_glissfunk     EQU     31 ; B
n_sampleoffset  EQU     32 ; B
n_pattpos       EQU     33 ; B
n_loopcount     EQU     34 ; B
n_funkoffset    EQU     35 ; B
n_wavestart     EQU     36 ; L
n_reallength    EQU     40 ; W

mt_init LEA     MT_DATA,A0
        MOVE.L  A0,mt_SongDataPtr
        LEA     mt_SampleStarts(PC),A1
        MOVE.L  A0,A3
        MOVEQ   #31-1,D0
mtloop3 MOVE.L  $26(A0),A2              ; get sample offset
        ADD.L   A3,A2                   ; add base of module
        MOVE.L  A2,(A1)+                ; store sample address
        LEA     30(A0),A0
        DBRA    D0,mtloop3
        MOVEQ   #0,D0
        MOVE.B  #6,mt_speed
        MOVE.B  D0,mt_counter
        MOVE.B  D0,mt_SongPos
        MOVE.B  D0,mt_PBreakPos 
        MOVE.B  D0,mt_PosJumpFlag       
        MOVE.B  D0,mt_PBreakFlag        
        MOVE.B  D0,mt_LowMask   
        MOVE.B  D0,mt_PattDelTime       
        MOVE.B  D0,mt_PattDelTime2      
        MOVE.B  D0,mt_PattDelTime2+1
        MOVE.W  D0,mt_DMACONtemp        
        MOVE.W  D0,mt_PatternPos
        MOVE.W  D0,dmactrl
        RTS

mt_music
        ADDQ.B  #1,mt_counter
        MOVE.B  mt_counter(PC),D0
        CMP.B   mt_speed(PC),D0
        BLO.S   mt_NoNewNote
        CLR.B   mt_counter
        TST.B   mt_PattDelTime2
        BEQ.S   mt_GetNewNote
        BSR.S   mt_NoNewAllChannels
        BRA     mt_dskip

mt_NoNewNote
        BSR.S   mt_NoNewAllChannels
        BRA     mt_NoNewPosYet

mt_NoNewAllChannels
        LEA     ch1t(PC),A5
        LEA     mt_chan1temp(PC),A6
        BSR     mt_CheckEfx
        LEA     ch2t(PC),A5
        LEA     mt_chan2temp(PC),A6
        BSR     mt_CheckEfx
        LEA     ch3t(PC),A5
        LEA     mt_chan3temp(PC),A6
        BSR     mt_CheckEfx
        LEA     ch4t(PC),A5
        LEA     mt_chan4temp(PC),A6
        BRA     mt_CheckEfx

mt_GetNewNote
        MOVE.L  mt_SongDataPtr(PC),A0
        LEA     12(A0),A3
        LEA     952(A0),A2      ;pattpo
        LEA     1084(A0),A0     ;patterndata
        MOVEQ   #0,D0
        MOVEQ   #0,D1
        MOVE.B  mt_SongPos(PC),D0
        MOVE.B  (A2,D0.W),D1
        ASL.L   #8,D1
        ASL.L   #2,D1
        ADD.W   mt_PatternPos(PC),D1
        CLR.W   mt_DMACONtemp

        LEA     ch1t(PC),A5
        LEA     mt_chan1temp(PC),A6
        BSR.S   mt_PlayVoice
        LEA     ch2t(PC),A5
        LEA     mt_chan2temp(PC),A6
        BSR.S   mt_PlayVoice
        LEA     ch3t(PC),A5
        LEA     mt_chan3temp(PC),A6
        BSR.S   mt_PlayVoice
        LEA     ch4t(PC),A5
        LEA     mt_chan4temp(PC),A6
        BSR.S   mt_PlayVoice
        BRA     mt_SetDMA

mt_PlayVoice
        TST.L   (A6)
        BNE.S   mt_plvskip
        BSR     mt_PerNop
mt_plvskip
        MOVE.L  (A0,D1.L),(A6)
        ADDQ.L  #4,D1
        MOVEQ   #0,D2
        MOVE.B  n_cmd(A6),D2
        AND.B   #$F0,D2
        LSR.B   #4,D2
        MOVE.B  (A6),D0
        AND.B   #$F0,D0
        OR.B    D0,D2
        TST.B   D2
        BEQ     mt_SetRegs
        MOVEQ   #0,D3
        LEA     mt_SampleStarts(PC),A1
        MOVE    D2,D4
        SUBQ.L  #1,D2
        ASL.L   #2,D2
        MULU    #30,D4
        MOVE.L  (A1,D2.L),n_start(A6)
        MOVE.W  (A3,D4.L),n_length(A6)
        MOVE.W  (A3,D4.L),n_reallength(A6)
        MOVE.B  2(A3,D4.L),n_finetune(A6)
        MOVE.B  3(A3,D4.L),n_volume(A6)
        MOVE.W  4(A3,D4.L),D3 ; Get repeat
        TST.W   D3
        BEQ.S   mt_NoLoop
        MOVE.L  n_start(A6),D2  ; Get start
        ASL.W   #1,D3
        ADD.L   D3,D2           ; Add repeat
        MOVE.L  D2,n_loopstart(A6)
        MOVE.L  D2,n_wavestart(A6)
        MOVE.W  4(A3,D4.L),D0   ; Get repeat
        ADD.W   6(A3,D4.L),D0   ; Add replen
        MOVE.W  D0,n_length(A6)
        MOVE.W  6(A3,D4.L),n_replen(A6) ; Save replen
        MOVEQ   #0,D0
        MOVE.B  n_volume(A6),D0
        MOVE.W  D0,8(A5)        ; Set volume
        BRA.S   mt_SetRegs

mt_NoLoop
        MOVE.L  n_start(A6),D2
        ADD.L   D3,D2
        MOVE.L  D2,n_loopstart(A6)
        MOVE.L  D2,n_wavestart(A6)
        MOVE.W  6(A3,D4.L),n_replen(A6) ; Save replen
        MOVEQ   #0,D0
        MOVE.B  n_volume(A6),D0
        MOVE.W  D0,8(A5)        ; Set volume
mt_SetRegs
        MOVE.W  (A6),D0
        AND.W   #$0FFF,D0
        BEQ     mt_CheckMoreEfx ; If no note
        MOVE.W  2(A6),D0
        AND.W   #$0FF0,D0
        CMP.W   #$0E50,D0
        BEQ.S   mt_DoSetFineTune
        MOVE.B  2(A6),D0
        AND.B   #$0F,D0
        CMP.B   #3,D0   ; TonePortamento
        BEQ.S   mt_ChkTonePorta
        CMP.B   #5,D0
        BEQ.S   mt_ChkTonePorta
        CMP.B   #9,D0   ; Sample Offset
        BNE.S   mt_SetPeriod
        BSR     mt_CheckMoreEfx
        BRA.S   mt_SetPeriod

mt_DoSetFineTune
        BSR     mt_SetFineTune
        BRA.S   mt_SetPeriod

mt_ChkTonePorta
        BSR     mt_SetTonePorta
        BRA     mt_CheckMoreEfx

mt_SetPeriod
        MOVEM.L D0-D1/A0-A1,-(SP)
        MOVE.W  (A6),D1
        AND.W   #$0FFF,D1
        LEA     mt_PeriodTable(PC),A1
        MOVEQ   #0,D0
        MOVEQ   #36,D7
mt_ftuloop
        CMP.W   (A1,D0.W),D1
        BHS.S   mt_ftufound
        ADDQ.L  #2,D0
        DBRA    D7,mt_ftuloop
mt_ftufound
        MOVEQ   #0,D1
        MOVE.B  n_finetune(A6),D1
        MULU    #36*2,D1
        ADD.L   D1,A1
        MOVE.W  (A1,D0.W),n_period(A6)
        MOVEM.L (SP)+,D0-D1/A0-A1

        MOVE.W  2(A6),D0
        AND.W   #$0FF0,D0
        CMP.W   #$0ED0,D0 ; Notedelay
        BEQ     mt_CheckMoreEfx

        MOVE.W  n_dmabit(A6),dmactrl
        BTST    #2,n_wavecontrol(A6)
        BNE.S   mt_vibnoc
        CLR.B   n_vibratopos(A6)
mt_vibnoc
        BTST    #6,n_wavecontrol(A6)
        BNE.S   mt_trenoc
        CLR.B   n_tremolopos(A6)
mt_trenoc
        MOVE.L  n_start(A6),(A5)        ; Set start
        MOVE.W  n_length(A6),4(A5)      ; Set length
        MOVE.W  n_period(A6),D0
        MOVE.W  D0,6(A5)                ; Set period
        MOVE.W  n_dmabit(A6),D0
        OR.W    D0,mt_DMACONtemp
        BRA     mt_CheckMoreEfx
 
mt_SetDMA
        MOVE.W  mt_DMACONtemp(PC),D0

        btst    #0,d0                   ;-------------------
        beq.s   wz_nch1                 ;
        move.l  aud1lc(pc),grf1lc       ;
        moveq   #0,d1                   ;
        moveq   #0,d2                   ;
        move.w  aud1len(pc),d1          ;
        move.w  mt_chan1temp+$0E(pc),d2 ;
        add.l   d2,d1                   ;
        move.l  d1,grf1len              ;
        move.w  d2,grf1rpt              ;
        clr.w   grf1pos                 ;

wz_nch1 btst    #1,d0                   ;
        beq.s   wz_nch2                 ;
        move.l  aud2lc(pc),grf2lc       ;
        moveq   #0,d1                   ;
        moveq   #0,d2                   ;
        move.w  aud2len(pc),d1          ;
        move.w  mt_chan2temp+$0E(pc),d2 ;
        add.l   d2,d1                   ;
        move.l  d1,grf2len              ;
        move.w  d2,grf2rpt              ;
        clr.w   grf2pos                 ;

wz_nch2 btst    #2,d0                   ;
        beq.s   wz_nch3                 ;
        move.l  aud3lc(pc),grf3lc       ;
        moveq   #0,d1                   ;
        moveq   #0,d2                   ;
        move.w  aud3len(pc),d1          ;
        move.w  mt_chan3temp+$0E(pc),d2 ;
        add.l   d2,d1                   ;
        move.l  d1,grf3len              ;
        move.w  d2,grf3rpt              ;
        clr.w   grf3pos                 ;

wz_nch3 btst    #3,d0                   ;
        beq.s   wz_nch4                 ;
        move.l  aud4lc(pc),grf4lc       ;
        moveq   #0,d1                   ;
        moveq   #0,d2                   ;
        move.w  aud4len(pc),d1          ;
        move.w  mt_chan4temp+$0E(pc),d2 ;
        add.l   d2,d1                   ;
        move.l  d1,grf4len              ;
        move.w  d2,grf4rpt              ;
        clr.w   grf4pos                 ;-------------------

wz_nch4

;       LEA     $DFF000,A5
;       LEA     mt_chan4temp(PC),A6
;       MOVE.L  n_loopstart(A6),$D0(A5)
;       MOVE.W  n_replen(A6),$D4(A5)
;       LEA     mt_chan3temp(PC),A6
;       MOVE.L  n_loopstart(A6),$C0(A5)
;       MOVE.W  n_replen(A6),$C4(A5)
;       LEA     mt_chan2temp(PC),A6
;       MOVE.L  n_loopstart(A6),$B0(A5)
;       MOVE.W  n_replen(A6),$B4(A5)
;       LEA     mt_chan1temp(PC),A6
;       MOVE.L  n_loopstart(A6),$A0(A5)
;       MOVE.W  n_replen(A6),$A4(A5)

mt_dskip
        ADD.W   #16,mt_PatternPos
        MOVE.B  mt_PattDelTime,D0
        BEQ.S   mt_dskc
        MOVE.B  D0,mt_PattDelTime2
        CLR.B   mt_PattDelTime
mt_dskc TST.B   mt_PattDelTime2
        BEQ.S   mt_dska
        SUBQ.B  #1,mt_PattDelTime2
        BEQ.S   mt_dska
        SUB.W   #16,mt_PatternPos
mt_dska TST.B   mt_PBreakFlag
        BEQ.S   mt_nnpysk
        SF      mt_PBreakFlag
        MOVEQ   #0,D0
        MOVE.B  mt_PBreakPos(PC),D0
        CLR.B   mt_PBreakPos
        LSL.W   #4,D0
        MOVE.W  D0,mt_PatternPos
mt_nnpysk
        CMP.W   #1024,mt_PatternPos
        BLO.S   mt_NoNewPosYet
mt_NextPosition 
        MOVEQ   #0,D0
        MOVE.B  mt_PBreakPos(PC),D0
        LSL.W   #4,D0
        MOVE.W  D0,mt_PatternPos
        CLR.B   mt_PBreakPos
        CLR.B   mt_PosJumpFlag
        ADDQ.B  #1,mt_SongPos
        AND.B   #$7F,mt_SongPos
        MOVE.B  mt_SongPos(PC),D1
        MOVE.L  mt_SongDataPtr(PC),A0
        CMP.B   950(A0),D1
        BLO.S   mt_NoNewPosYet
        CLR.B   mt_SongPos
mt_NoNewPosYet  
        TST.B   mt_PosJumpFlag
        BNE.S   mt_NextPosition
        RTS

mt_CheckEfx
        BSR     mt_UpdateFunk
        MOVE.W  n_cmd(A6),D0
        AND.W   #$0FFF,D0
        BEQ.S   mt_PerNop
        MOVE.B  n_cmd(A6),D0
        AND.B   #$0F,D0
        BEQ.S   mt_Arpeggio
        CMP.B   #1,D0
        BEQ     mt_PortaUp
        CMP.B   #2,D0
        BEQ     mt_PortaDown
        CMP.B   #3,D0
        BEQ     mt_TonePortamento
        CMP.B   #4,D0
        BEQ     mt_Vibrato
        CMP.B   #5,D0
        BEQ     mt_TonePlusVolSlide
        CMP.B   #6,D0
        BEQ     mt_VibratoPlusVolSlide
        CMP.B   #$E,D0
        BEQ     mt_E_Commands
SetBack MOVE.W  n_period(A6),6(A5)
        CMP.B   #7,D0
        BEQ     mt_Tremolo
        CMP.B   #$A,D0
        BEQ     mt_VolumeSlide
mt_Return2
        RTS

mt_PerNop
        MOVE.W  n_period(A6),6(A5)
        RTS

mt_Arpeggio
        MOVEQ   #0,D0
        MOVE.B  mt_counter(PC),D0
        DIVS    #3,D0
        SWAP    D0
        CMP.W   #0,D0
        BEQ.S   mt_Arpeggio2
        CMP.W   #2,D0
        BEQ.S   mt_Arpeggio1
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        LSR.B   #4,D0
        BRA.S   mt_Arpeggio3

mt_Arpeggio1
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #15,D0
        BRA.S   mt_Arpeggio3

mt_Arpeggio2
        MOVE.W  n_period(A6),D2
        BRA.S   mt_Arpeggio4

mt_Arpeggio3
        ASL.W   #1,D0
        MOVEQ   #0,D1
        MOVE.B  n_finetune(A6),D1
        MULU    #36*2,D1
        LEA     mt_PeriodTable(PC),A0
        ADD.L   D1,A0
        MOVEQ   #0,D1
        MOVE.W  n_period(A6),D1
        MOVEQ   #36,D7
mt_arploop
        MOVE.W  (A0,D0.W),D2
        CMP.W   (A0),D1
        BHS.S   mt_Arpeggio4
        ADDQ.L  #2,A0
        DBRA    D7,mt_arploop
        RTS

mt_Arpeggio4
        MOVE.W  D2,6(A5)
        RTS

mt_FinePortaUp
        TST.B   mt_counter
        BNE.S   mt_Return2
        MOVE.B  #$0F,mt_LowMask
mt_PortaUp
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   mt_LowMask(PC),D0
        MOVE.B  #$FF,mt_LowMask
        SUB.W   D0,n_period(A6)
        MOVE.W  n_period(A6),D0
        AND.W   #$0FFF,D0
        CMP.W   #113,D0
        BPL.S   mt_PortaUskip
        AND.W   #$F000,n_period(A6)
        OR.W    #113,n_period(A6)
mt_PortaUskip
        MOVE.W  n_period(A6),D0
        AND.W   #$0FFF,D0
        MOVE.W  D0,6(A5)
        RTS     
 
mt_FinePortaDown
        TST.B   mt_counter
        BNE     mt_Return2
        MOVE.B  #$0F,mt_LowMask
mt_PortaDown
        CLR.W   D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   mt_LowMask(PC),D0
        MOVE.B  #$FF,mt_LowMask
        ADD.W   D0,n_period(A6)
        MOVE.W  n_period(A6),D0
        AND.W   #$0FFF,D0
        CMP.W   #856,D0
        BMI.S   mt_PortaDskip
        AND.W   #$F000,n_period(A6)
        OR.W    #856,n_period(A6)
mt_PortaDskip
        MOVE.W  n_period(A6),D0
        AND.W   #$0FFF,D0
        MOVE.W  D0,6(A5)
        RTS

mt_SetTonePorta
        MOVE.L  A0,-(SP)
        MOVE.W  (A6),D2
        AND.W   #$0FFF,D2
        MOVEQ   #0,D0
        MOVE.B  n_finetune(A6),D0
        MULU    #36*2,D0
        LEA     mt_PeriodTable(PC),A0
        ADD.L   D0,A0
        MOVEQ   #0,D0
mt_StpLoop
        CMP.W   (A0,D0.W),D2
        BHS.S   mt_StpFound
        ADDQ.W  #2,D0
        CMP.W   #36*2,D0
        BLO.S   mt_StpLoop
        MOVEQ   #35*2,D0
mt_StpFound
        MOVE.B  n_finetune(A6),D2
        AND.B   #8,D2
        BEQ.S   mt_StpGoss
        TST.W   D0
        BEQ.S   mt_StpGoss
        SUBQ.W  #2,D0
mt_StpGoss
        MOVE.W  (A0,D0.W),D2
        MOVE.L  (SP)+,A0
        MOVE.W  D2,n_wantedperiod(A6)
        MOVE.W  n_period(A6),D0
        CLR.B   n_toneportdirec(A6)
        CMP.W   D0,D2
        BEQ.S   mt_ClearTonePorta
        BGE     mt_Return2
        MOVE.B  #1,n_toneportdirec(A6)
        RTS

mt_ClearTonePorta
        CLR.W   n_wantedperiod(A6)
        RTS

mt_TonePortamento
        MOVE.B  n_cmdlo(A6),D0
        BEQ.S   mt_TonePortNoChange
        MOVE.B  D0,n_toneportspeed(A6)
        CLR.B   n_cmdlo(A6)
mt_TonePortNoChange
        TST.W   n_wantedperiod(A6)
        BEQ     mt_Return2
        MOVEQ   #0,D0
        MOVE.B  n_toneportspeed(A6),D0
        TST.B   n_toneportdirec(A6)
        BNE.S   mt_TonePortaUp
mt_TonePortaDown
        ADD.W   D0,n_period(A6)
        MOVE.W  n_wantedperiod(A6),D0
        CMP.W   n_period(A6),D0
        BGT.S   mt_TonePortaSetPer
        MOVE.W  n_wantedperiod(A6),n_period(A6)
        CLR.W   n_wantedperiod(A6)
        BRA.S   mt_TonePortaSetPer

mt_TonePortaUp
        SUB.W   D0,n_period(A6)
        MOVE.W  n_wantedperiod(A6),D0
        CMP.W   n_period(A6),D0
        BLT.S   mt_TonePortaSetPer
        MOVE.W  n_wantedperiod(A6),n_period(A6)
        CLR.W   n_wantedperiod(A6)

mt_TonePortaSetPer
        MOVE.W  n_period(A6),D2
        MOVE.B  n_glissfunk(A6),D0
        AND.B   #$0F,D0
        BEQ.S   mt_GlissSkip
        MOVEQ   #0,D0
        MOVE.B  n_finetune(A6),D0
        MULU    #36*2,D0
        LEA     mt_PeriodTable(PC),A0
        ADD.W   D0,A0
        MOVEQ   #0,D0
mt_GlissLoop
        CMP.W   (A0,D0.W),D2
        BHS.S   mt_GlissFound                   
        ADDQ.W  #2,D0
        CMP.W   #36*2,D0
        BLO.S   mt_GlissLoop
        MOVEQ   #35*2,D0
mt_GlissFound
        MOVE.W  (A0,D0.W),D2
mt_GlissSkip
        MOVE.W  D2,6(A5) ; Set period
        RTS

mt_Vibrato
        MOVE.B  n_cmdlo(A6),D0
        BEQ.S   mt_Vibrato2
        MOVE.B  n_vibratocmd(A6),D2
        AND.B   #$0F,D0
        BEQ.S   mt_vibskip
        AND.B   #$F0,D2
        OR.B    D0,D2
mt_vibskip
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$F0,D0
        BEQ.S   mt_vibskip2
        AND.B   #$0F,D2
        OR.B    D0,D2
mt_vibskip2
        MOVE.B  D2,n_vibratocmd(A6)
mt_Vibrato2
        MOVE.B  n_vibratopos(A6),D0
        LEA     mt_VibratoTable(PC),A4
        LSR.W   #2,D0
        AND.W   #$001F,D0
        MOVEQ   #0,D2
        MOVE.B  n_wavecontrol(A6),D2
        AND.B   #$03,D2
        BEQ.S   mt_vib_sine
        LSL.B   #3,D0
        CMP.B   #1,D2
        BEQ.S   mt_vib_rampdown
        MOVE.B  #255,D2
        BRA.S   mt_vib_set
mt_vib_rampdown
        TST.B   n_vibratopos(A6)
        BPL.S   mt_vib_rampdown2
        MOVE.B  #255,D2
        SUB.B   D0,D2
        BRA.S   mt_vib_set
mt_vib_rampdown2
        MOVE.B  D0,D2
        BRA.S   mt_vib_set
mt_vib_sine
        MOVE.B  0(A4,D0.W),D2
mt_vib_set
        MOVE.B  n_vibratocmd(A6),D0
        AND.W   #15,D0
        MULU    D0,D2
        LSR.W   #7,D2
        MOVE.W  n_period(A6),D0
        TST.B   n_vibratopos(A6)
        BMI.S   mt_VibratoNeg
        ADD.W   D2,D0
        BRA.S   mt_Vibrato3
mt_VibratoNeg
        SUB.W   D2,D0
mt_Vibrato3
        MOVE.W  D0,6(A5)
        MOVE.B  n_vibratocmd(A6),D0
        LSR.W   #2,D0
        AND.W   #$003C,D0
        ADD.B   D0,n_vibratopos(A6)
        RTS

mt_TonePlusVolSlide
        BSR     mt_TonePortNoChange
        BRA     mt_VolumeSlide

mt_VibratoPlusVolSlide
        BSR.S   mt_Vibrato2
        BRA     mt_VolumeSlide

mt_Tremolo
        MOVE.B  n_cmdlo(A6),D0
        BEQ.S   mt_Tremolo2
        MOVE.B  n_tremolocmd(A6),D2
        AND.B   #$0F,D0
        BEQ.S   mt_treskip
        AND.B   #$F0,D2
        OR.B    D0,D2
mt_treskip
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$F0,D0
        BEQ.S   mt_treskip2
        AND.B   #$0F,D2
        OR.B    D0,D2
mt_treskip2
        MOVE.B  D2,n_tremolocmd(A6)
mt_Tremolo2
        MOVE.B  n_tremolopos(A6),D0
        LEA     mt_VibratoTable(PC),A4
        LSR.W   #2,D0
        AND.W   #$001F,D0
        MOVEQ   #0,D2
        MOVE.B  n_wavecontrol(A6),D2
        LSR.B   #4,D2
        AND.B   #$03,D2
        BEQ.S   mt_tre_sine
        LSL.B   #3,D0
        CMP.B   #1,D2
        BEQ.S   mt_tre_rampdown
        MOVE.B  #255,D2
        BRA.S   mt_tre_set
mt_tre_rampdown
        TST.B   n_vibratopos(A6)
        BPL.S   mt_tre_rampdown2
        MOVE.B  #255,D2
        SUB.B   D0,D2
        BRA.S   mt_tre_set
mt_tre_rampdown2
        MOVE.B  D0,D2
        BRA.S   mt_tre_set
mt_tre_sine
        MOVE.B  0(A4,D0.W),D2
mt_tre_set
        MOVE.B  n_tremolocmd(A6),D0
        AND.W   #15,D0
        MULU    D0,D2
        LSR.W   #6,D2
        MOVEQ   #0,D0
        MOVE.B  n_volume(A6),D0
        TST.B   n_tremolopos(A6)
        BMI.S   mt_TremoloNeg
        ADD.W   D2,D0
        BRA.S   mt_Tremolo3
mt_TremoloNeg
        SUB.W   D2,D0
mt_Tremolo3
        BPL.S   mt_TremoloSkip
        CLR.W   D0
mt_TremoloSkip
        CMP.W   #$40,D0
        BLS.S   mt_TremoloOk
        MOVE.W  #$40,D0
mt_TremoloOk
        MOVE.W  D0,8(A5)
        MOVE.B  n_tremolocmd(A6),D0
        LSR.W   #2,D0
        AND.W   #$003C,D0
        ADD.B   D0,n_tremolopos(A6)
        RTS

mt_SampleOffset
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        BEQ.S   mt_sononew
        MOVE.B  D0,n_sampleoffset(A6)
mt_sononew
        MOVE.B  n_sampleoffset(A6),D0
        LSL.W   #7,D0
        CMP.W   n_length(A6),D0
        BGE.S   mt_sofskip
        SUB.W   D0,n_length(A6)
        LSL.W   #1,D0
        ADD.L   D0,n_start(A6)
        RTS
mt_sofskip
        MOVE.W  #$0001,n_length(A6)
        RTS

mt_VolumeSlide
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        LSR.B   #4,D0
        TST.B   D0
        BEQ.S   mt_VolSlideDown
mt_VolSlideUp
        ADD.B   D0,n_volume(A6)
        CMP.B   #$40,n_volume(A6)
        BMI.S   mt_vsuskip
        MOVE.B  #$40,n_volume(A6)
mt_vsuskip
        MOVE.B  n_volume(A6),D0
        MOVE.W  D0,8(A5)
        RTS

mt_VolSlideDown
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
mt_VolSlideDown2
        SUB.B   D0,n_volume(A6)
        BPL.S   mt_vsdskip
        CLR.B   n_volume(A6)
mt_vsdskip
        MOVE.B  n_volume(A6),D0
        MOVE.W  D0,8(A5)
        RTS

mt_PositionJump
        MOVE.B  n_cmdlo(A6),D0
        SUBQ.B  #1,D0
        MOVE.B  D0,mt_SongPos
mt_pj2  CLR.B   mt_PBreakPos
        ST      mt_PosJumpFlag
        RTS

mt_VolumeChange
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        CMP.B   #$40,D0
        BLS.S   mt_VolumeOk
        MOVEQ   #$40,D0
mt_VolumeOk
        MOVE.B  D0,n_volume(A6)
        MOVE.W  D0,8(A5)
        RTS

mt_PatternBreak
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        MOVE.L  D0,D2
        LSR.B   #4,D0
        MULU    #10,D0
        AND.B   #$0F,D2
        ADD.B   D2,D0
        CMP.B   #63,D0
        BHI.S   mt_pj2
        MOVE.B  D0,mt_PBreakPos
        ST      mt_PosJumpFlag
        RTS

mt_SetSpeed
        MOVE.B  3(A6),D0
        BEQ     mt_Return2
        CLR.B   mt_counter
        MOVE.B  D0,mt_speed
        RTS

mt_CheckMoreEfx
        BSR     mt_UpdateFunk
        MOVE.B  2(A6),D0
        AND.B   #$0F,D0
        CMP.B   #$9,D0
        BEQ     mt_SampleOffset
        CMP.B   #$B,D0
        BEQ     mt_PositionJump
        CMP.B   #$D,D0
        BEQ.S   mt_PatternBreak
        CMP.B   #$E,D0
        BEQ.S   mt_E_Commands
        CMP.B   #$F,D0
        BEQ.S   mt_SetSpeed
        CMP.B   #$C,D0
        BEQ     mt_VolumeChange
        BRA     mt_PerNop

mt_E_Commands
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$F0,D0
        LSR.B   #4,D0
        BEQ.S   mt_FilterOnOff
        CMP.B   #1,D0
        BEQ     mt_FinePortaUp
        CMP.B   #2,D0
        BEQ     mt_FinePortaDown
        CMP.B   #3,D0
        BEQ.S   mt_SetGlissControl
        CMP.B   #4,D0
        BEQ     mt_SetVibratoControl
        CMP.B   #5,D0
        BEQ     mt_SetFineTune
        CMP.B   #6,D0
        BEQ     mt_JumpLoop
        CMP.B   #7,D0
        BEQ     mt_SetTremoloControl
        CMP.B   #9,D0
        BEQ     mt_RetrigNote
        CMP.B   #$A,D0
        BEQ     mt_VolumeFineUp
        CMP.B   #$B,D0
        BEQ     mt_VolumeFineDown
        CMP.B   #$C,D0
        BEQ     mt_NoteCut
        CMP.B   #$D,D0
        BEQ     mt_NoteDelay
        CMP.B   #$E,D0
        BEQ     mt_PatternDelay
        CMP.B   #$F,D0
        BEQ     mt_FunkIt
        RTS

mt_FilterOnOff
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #1,D0
        ASL.B   #1,D0
        AND.B   #$FD,shfilter
        OR.B    D0,shfilter
        RTS     

mt_SetGlissControl
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        AND.B   #$F0,n_glissfunk(A6)
        OR.B    D0,n_glissfunk(A6)
        RTS

mt_SetVibratoControl
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        AND.B   #$F0,n_wavecontrol(A6)
        OR.B    D0,n_wavecontrol(A6)
        RTS

mt_SetFineTune
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        MOVE.B  D0,n_finetune(A6)
        RTS

mt_JumpLoop
        TST.B   mt_counter
        BNE     mt_Return2
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        BEQ.S   mt_SetLoop
        TST.B   n_loopcount(A6)
        BEQ.S   mt_jumpcnt
        SUBQ.B  #1,n_loopcount(A6)
        BEQ     mt_Return2
mt_jmploop      MOVE.B  n_pattpos(A6),mt_PBreakPos
        ST      mt_PBreakFlag
        RTS

mt_jumpcnt
        MOVE.B  D0,n_loopcount(A6)
        BRA.S   mt_jmploop

mt_SetLoop
        MOVE.W  mt_PatternPos(PC),D0
        LSR.W   #4,D0
        MOVE.B  D0,n_pattpos(A6)
        RTS

mt_SetTremoloControl
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        LSL.B   #4,D0
        AND.B   #$0F,n_wavecontrol(A6)
        OR.B    D0,n_wavecontrol(A6)
        RTS

mt_RetrigNote
        MOVE.L  D1,-(SP)
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        BEQ.S   mt_rtnend
        MOVEQ   #0,D1
        MOVE.B  mt_counter(PC),D1
        BNE.S   mt_rtnskp
        MOVE.W  (A6),D1
        AND.W   #$0FFF,D1
        BNE.S   mt_rtnend
        MOVEQ   #0,D1
        MOVE.B  mt_counter(PC),D1
mt_rtnskp
        DIVU    D0,D1
        SWAP    D1
        TST.W   D1
        BNE.S   mt_rtnend
mt_DoRetrig
        MOVE.W  n_dmabit(A6),dmactrl    ; Channel DMA off
        MOVE.L  n_start(A6),(A5)        ; Set sampledata pointer
        MOVE.W  n_length(A6),4(A5)      ; Set length
        MOVE.W  n_dmabit(A6),D0
        BSET    #15,D0
        MOVE.W  D0,dmactrl

        MOVE.L  n_loopstart(A6),(A5)
        MOVE.L  n_replen(A6),4(A5)
mt_rtnend
        MOVE.L  (SP)+,D1
        RTS

mt_VolumeFineUp
        TST.B   mt_counter
        BNE     mt_Return2
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$F,D0
        BRA     mt_VolSlideUp

mt_VolumeFineDown
        TST.B   mt_counter
        BNE     mt_Return2
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        BRA     mt_VolSlideDown2

mt_NoteCut
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        CMP.B   mt_counter(PC),D0
        BNE     mt_Return2
        CLR.B   n_volume(A6)
        MOVE.W  #0,8(A5)
        RTS

mt_NoteDelay
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        CMP.B   mt_counter,D0
        BNE     mt_Return2
        MOVE.W  (A6),D0
        BEQ     mt_Return2
        MOVE.L  D1,-(SP)
        BRA     mt_DoRetrig

mt_PatternDelay
        TST.B   mt_counter
        BNE     mt_Return2
        MOVEQ   #0,D0
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        TST.B   mt_PattDelTime2
        BNE     mt_Return2
        ADDQ.B  #1,D0
        MOVE.B  D0,mt_PattDelTime
        RTS

mt_FunkIt
        TST.B   mt_counter
        BNE     mt_Return2
        MOVE.B  n_cmdlo(A6),D0
        AND.B   #$0F,D0
        LSL.B   #4,D0
        AND.B   #$0F,n_glissfunk(A6)
        OR.B    D0,n_glissfunk(A6)
        TST.B   D0
        BEQ     mt_Return2
mt_UpdateFunk
        MOVEM.L D1/A0,-(SP)
        MOVEQ   #0,D0
        MOVE.B  n_glissfunk(A6),D0
        LSR.B   #4,D0
        BEQ.S   mt_funkend
        LEA     mt_FunkTable(PC),A0
        MOVE.B  (A0,D0.W),D0
        ADD.B   D0,n_funkoffset(A6)
        BTST    #7,n_funkoffset(A6)
        BEQ.S   mt_funkend
        CLR.B   n_funkoffset(A6)

        MOVE.L  n_loopstart(A6),D0
        MOVEQ   #0,D1
        MOVE.W  n_replen(A6),D1
        ADD.L   D1,D0
        ADD.L   D1,D0
        MOVE.L  n_wavestart(A6),A0
        ADDQ.L  #1,A0
        CMP.L   D0,A0
        BLO.S   mt_funkok
        MOVE.L  n_loopstart(A6),A0
mt_funkok
        MOVE.L  A0,n_wavestart(A6)
        MOVEQ   #-1,D0
        SUB.B   (A0),D0
        MOVE.B  D0,(A0)
mt_funkend
        MOVEM.L (SP)+,D1/A0
        RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable 
        dc.b   0, 24, 49, 74, 97,120,141,161
        dc.b 180,197,212,224,235,244,250,253
        dc.b 255,253,250,244,235,224,212,197
        dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
        dc.w    856,808,762,720,678,640,604,570,538,508,480,453
        dc.w    428,404,381,360,339,320,302,285,269,254,240,226
        dc.w    214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
        dc.w    850,802,757,715,674,637,601,567,535,505,477,450
        dc.w    425,401,379,357,337,318,300,284,268,253,239,225
        dc.w    213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
        dc.w    844,796,752,709,670,632,597,563,532,502,474,447
        dc.w    422,398,376,355,335,316,298,282,266,251,237,224
        dc.w    211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
        dc.w    838,791,746,704,665,628,592,559,528,498,470,444
        dc.w    419,395,373,352,332,314,296,280,264,249,235,222
        dc.w    209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
        dc.w    832,785,741,699,660,623,588,555,524,495,467,441
        dc.w    416,392,370,350,330,312,294,278,262,247,233,220
        dc.w    208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
        dc.w    826,779,736,694,655,619,584,551,520,491,463,437
        dc.w    413,390,368,347,328,309,292,276,260,245,232,219
        dc.w    206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
        dc.w    820,774,730,689,651,614,580,547,516,487,460,434
        dc.w    410,387,365,345,325,307,290,274,258,244,230,217
        dc.w    205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
        dc.w    814,768,725,684,646,610,575,543,513,484,457,431
        dc.w    407,384,363,342,323,305,288,272,256,242,228,216
        dc.w    204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
        dc.w    907,856,808,762,720,678,640,604,570,538,508,480
        dc.w    453,428,404,381,360,339,320,302,285,269,254,240
        dc.w    226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
        dc.w    900,850,802,757,715,675,636,601,567,535,505,477
        dc.w    450,425,401,379,357,337,318,300,284,268,253,238
        dc.w    225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
        dc.w    894,844,796,752,709,670,632,597,563,532,502,474
        dc.w    447,422,398,376,355,335,316,298,282,266,251,237
        dc.w    223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
        dc.w    887,838,791,746,704,665,628,592,559,528,498,470
        dc.w    444,419,395,373,352,332,314,296,280,264,249,235
        dc.w    222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
        dc.w    881,832,785,741,699,660,623,588,555,524,494,467
        dc.w    441,416,392,370,350,330,312,294,278,262,247,233
        dc.w    220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
        dc.w    875,826,779,736,694,655,619,584,551,520,491,463
        dc.w    437,413,390,368,347,328,309,292,276,260,245,232
        dc.w    219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
        dc.w    868,820,774,730,689,651,614,580,547,516,487,460
        dc.w    434,410,387,365,345,325,307,290,274,258,244,230
        dc.w    217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
        dc.w    862,814,768,725,684,646,610,575,543,513,484,457
        dc.w    431,407,384,363,342,323,305,288,272,256,242,228
        dc.w    216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp    dc.l    0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp    dc.l    0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp    dc.l    0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp    dc.l    0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr  dc.l 0

mt_speed        dc.b 6
mt_counter      dc.b 0
mt_SongPos      dc.b 0
mt_PBreakPos    dc.b 0
mt_PosJumpFlag  dc.b 0
mt_PBreakFlag   dc.b 0
mt_LowMask      dc.b 0
mt_PattDelTime  dc.b 0
mt_PattDelTime2 dc.b 0,0

mt_PatternPos   dc.w 0
mt_DMACONtemp   dc.w 0

voltab_ptr      DC.L 0
vol_tab         DS.B 256
                DS.B 16640

                EVEN



;------------------------------------------------------------
; THE DATA FOR THE DEMO INCLUDING PALS, GFX, MUSIC ETC..
;
palette         dc.w    backcol,backcol,backcol,backcol
                dc.w    backcol,backcol,backcol,backcol
                dc.w    backcol,backcol,backcol,backcol
                dc.w    backcol,backcol,backcol,forecol

SCROLLPAL:      dc.w    $000,$100,$200,$300,$C00,$D00,$E00,$F00
                dc.w    $FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF

;----------------------------------------------------------------------
; 
SCROLL_FONT:    INCBIN  "QUITEBIG.DAT\QUITEBIG.FNT"
                EVEN
                
SCROLL_TEXT:    DC.B    "                     Greetings and welcome to The Quite Big Demo by The Fingerbobs.    "
                DC.B    "Credits for this demo are as follows...        "
                DC.B    "Coding - The Caped Crusader.  "
                DC.B    "Gobsmacking Grafix - Mr Pixar.  "
                DC.B    "Music - Dr. Awesome (Crusaders).  "
                DC.B    "Additional Routines - The Phantom(no top border).  "
                DC.B    "Griff(Music player).  "
                DC.B    "Undercover Elephant(Colour Cycler).  "
                DC.B    "Mouse Routine & Fixxes - Oberje'   "
                DC.B    "World Class Hurling - The Creeper   "
                DC.B    "Mummified Corpse Impressions - Oberje'   "
                DC.B    "Impure Thoughts AND Nefarious Intentions - Occulus   "
                DC.B    "Gratuitous Drinking - All except TCC ( Boring sod! )   "
                DC.B    "Scroll Text by Mr Pixar = Occulus = TCC = Oberje' and The Creeper.  "
                DC.B    "Okay if you want to see the Purpose of this Demo Why not move the "
                DC.B    "mouse about a little bit?       Well cool eh.. "
                DC.B    "     That reminds me to leave this screen you have to Press Either of "
                dc.b    "the Mouse Buttons that was Oberje's Idea...    "
                DC.B    "This demo was coded at Ripped Off's - Great British ST Party '92.  "
                DC.B    "It is to be included on their Party Demo Disk. Ok, Now that the waffle "
                DC.B    "is over with I'll hand over to Mr. Pixar for the rest of the text "
                ;
                ; Johns text...
                ;
                dc.b ". . . . . . . . . . . . . . Howdy Doody there, fellow wobbly bobbly "
                dc.b "people!  It's your big old Uncle Pixar here, welcoming all you "
                dc.b "movers & shakers, hackers & breakers to this all-new, all-"
                dc.b "singing, all-dancing, all-for-one-and-one-for-all, all-you-need-"
                dc.b "is-love, love-is-all-you-need, sort of Demo.  Yes, Scrollmonsters, "
                dc.b "this is your old bob-buddie, Mr Pixar tappin' his delicate digits "
                dc.b "for you dudes out there in Viewerland - and I'm damn sure "
                dc.b "I don't need to tell you what that means. That's right folks "
                dc.b "it means those Yobs with the Bobs, those blokes with the pokes, "
                dc.b "those dudes in the nude,  yes those Nutters with St-St-St-St-"
                dc.b "Stutters, Oberje (Da big boss man) and The Caped Crusader have been "
                dc.b "pounding the 68000 again.... So tape up your windows.... lock up your "
                dc.b "daughters.... and put the cat out, for The Shower with the Power, The "
                dc.b "Bunch that's out to Lunch  -  T h e    F I N G E R B O B S ! "
                dc.b "    . . . . Now that's what I call an intro. What do you reckon TCC? You "
                dc.b "don't think I undersold us, do you? . . . . Well dude, I've got to give "
                dc.b "you a point for trying. I mean at least you gave it a shot. You bounced "
                dc.b "it around, you ran it up the flagpole, pushed the boat out then threw it "
                dc.b "against the wall to see what stuck - But you've got to face it dude, it's "
                dc.b "a bit on the bland side. It's got no style, finesse, wit, content or any " 
                dc.b "redeeming features or sheep what-so-ever . . . . . Come again? . . . . "
                dc.b "It's got no style, finesse, wit, content, or any redeeming features or "
                dc.b "sheep what-so-ever . . . . . . . . . . . . You want sheep? . . . Yes. Now "
                dc.b "go away and don't come back until you've got me a nice intro with some "
                dc.b "nice fluffy sheep in it . . . . . . . . . A sheep intro?!  But this is "
                dc.b "the Quite Big demo?! .... Oh well, "
                dc.b "the man gets what the man wants - A sheep intro he says.... and make it "
                dc.b "good he says. Sheeeesh! ..... No, Sheep!...... Okay Dokay dude, your the "
                dc.b "man with the pointy stick!. . . . . . . . . . . . . . Time Passes . . . "
                dc.b "(Copyright INFOCOM - all rights reserved) . . . . . . . . . . Time "
                dc.b "Passes . . . (Again) . . . . (in case you missed it first time.) . . . "
                dc.b ". . . . . . . . Tum-te-tum... Glad to see your still with us, I must "
                dc.b "apologise for this break in transmission. This was caused by a whacked out "
                dc.b "programming dude (that if you asked me wouldnt know a good intro if he "
                dc.b "found it in his timing tables - philistines the lot of em). Anyway, "
                dc.b "I would like to take advantage of this little break in the proceedings "
                dc.b "to introduce you to the Fingerbobs... In the Blue corner we have the "
                dc.b "Programmers: Oberje, The Caped Crusader, The Creeper and Undercover "
                dc.b "Elephant. In the Red Corner, on lead mouse & "
                dc.b "keyboards, the Fingerbobs (reset) resident piss(ed) artist & "
                dc.b "part-time scrolltext guru, yours truly, Mr Pixar.  Now somewhere in "
                dc.b "between this, in that netherworld of uncertainty lies the man they "
                dc.b "call... Oculus.  Nobody's quite sure what his job is, but he sure "
                dc.b "drinks a lot.  As is by now traditional I've been out-numbered by"
                dc.b "those programming chaps, so they've chained me to 1st Word with the "
                dc.b "usual threats of no sleep or coffee until I bust 100K.  Well folks "
                dc.b "some things to look forward to in this near two hour scroller "
                dc.b "include (1) The end.    (2) The Man in a seafood restaurant joke     "
                dc.b "(3) Alternative Acronyms    (4) Some stuff about Sex, Drugs & "
                dc.b "Rock 'n' Roll (that should keep you reading)    and maybe some "
                dc.b "greets at the end (it's kinda traditional).  But firstly a "
                dc.b "little warning to any of you un-initiated folks out "
                dc.b "there in viewerland that have never read a Fingerbobs scroller "
                dc.b "before.  It's sort of like Bill & Ted meet Salvador Dali.....in the "
                dc.b "pub. They all have a few beers, have an excellent time whilst "
                dc.b "falling down a lot. They generally however, acomplish very little.   "
                dc.b "Anyway, if you miss any of it, count yourself lucky - It could "
                dc.b "have been worse.  Oh well, Im almost ready with my Big Sheep Intro so we "
                dc.b "will resume our scheduled programming as soon as possible, in the meantime "
                dc.b "heres some music.... Do Wop, Do Widdy Widdy. Do Wop, Do Wah Do Wah. Tiddly "
                dc.b "Bop do Wah. Skiddly Diddly Do Wop Do Wah - - - On behalf of "
                dc.b "Ice-Cream-U-Like and Hot-Dogs-R-Us we would like to remind you that "
                dc.b "refreshments are available in the foyer at grossly inflated prices - "
                dc.b "thank you. - - - Do Wah Do Wah, Tiddly Widdly... Hi guys, apologises for "
                dc.b "breaking in mid 'Tiddly Widdly' but I couldn't keep this from you any "
                dc.b "longer. It is with great melodramatics that I give you the world's first, "
                dc.b "only and (let's hope) last Quite Big Sheep demo - (intro).... AHhemmm.... Hi there "
                dc.b "Scrollmonsters!  Blah Blah Blah - Me Pixar... Blah Blah Blah... Oberje "
                dc.b "and TCC... Blah Blah Blah... Secret Base... Blah Blah Blah... by the old "
                dc.b "clock tower... Blah Blah Drone... The Heap with the Sheep! ... Blah Blah "
                dc.b "... The Bams with the Lambs. Yes, The Posse with Flossie! - T h e   "
                dc.b "F I N G E R B O B S ! . . . . . Okay dudes, marks out of ten and go easy "
                dc.b "on the complex numbers!  . . . . . . . I'll give it 1 but I can't dance "
                dc.b "to it. . . . . Yes you can, Tippety Tappety, Tippety Tappety, Tap Tap "
                dc.b ". . . . I'll still give it one (ooer - Viz) but YOU cant dance to it. "
                dc.b ". . . . . . . rumble rumble . . . Thats it! . . . rumble rumble . . . I've "
                dc.b "had enough . . . Rumble Rumble . . . no more wimpy intros . . . Rumble "
                dc.b "Crash . . . No more farting around! . . . Rumble Thump . . . No more "
                dc.b ". . . RUMBLE THRUMBLE . . . MR NICE GUY! -  Get me . . . RUMBLE BOING . . . "
                dc.b "Some . . . BOING ZINNNNG . . .  C  O  F  F  E  E !   -   Glug Glug Glug... "
                dc.b "Cue Popeye Theme tune... ",27,"I'm Pixar the Scrolltext man, and Pissed Off is "
                dc.b "what I am!   If you don't like my scroller, I'll punch out your molars - "
                dc.b "I'm Pixar the Scrolltext Man." - This is the all new Mr Pixar, a Lean, "
                dc.b "Mean, Scrolltext Machine - No Platitudes, Just Attitude. Yes dudes, you "
                dc.b "heard it here first on Fingerbobs FM, the station for the nation, and "
                dc.b "we're comin' atcha live and direct from the Fingerbobs Central Galactic "
                dc.b "Command Centre... . . . Oberje! He's trippin' again. I think you'd better "
                dc.b "punch his lights out... . . . Yes, the Faction with the Action... . . . "
                dc.b "Sorry big dude, this is for your own good... . . . The Psycho Head "
                dc.b "Bastards with Go-Faster Rasters  -  C L A N G !  (Frying Pan on head at "
                dc.b "high speed noise). . . . . ZZZZZZ  Z Z Z Z.. Z.. Z.. z... z... z...... "
                dc.b "   It's a funny old world. . . . . . . . . .   It's amazing the things "
                dc.b "you begin to think about when your bestest ST buddies assault you, "
                dc.b "blindfold you, drug you with some suspect smelling roll-up and then chain "
                dc.b "you up in a sensory deprivation tank. I mean, I'm sure they mean well "
                dc.b "but I can't help feeling like the guy in ",27,"Altered States",27,"...   "
                dc.b "So, here anyway is the latest random "
                dc.b "ramblings from salt water central.  The first thing really, that "
                dc.b "crossed my mind (other than, 'far out, man') was what should I "
                dc.b "should call this little prose with the pose.  I had considered "
                dc.b "'Tales from the tank' or even 'Thoughts from the pot', but I "
                dc.b "finally settled for 'Dear Diary'.  Or so I thought.  In the end I "
                dc.b "kinda flipped out and addressed it Dear Dairy.  Having said that, "
                dc.b "the milkman must've liked it coz he's started delivering free "
                dc.b "yoghurts. I suppose I should really tell him..... Anyway as you can see "
                dc.b "it's a funny old world. The reason I've arrived at "
                dc.b "this conclusion is based on a number of things I've been thinking about "
                dc.b "whilst in 'the tank'. As you'll no doubt remember we touched briefly on "
                dc.b "the subject of sheep (You probably wish we hadn't) earlier in the text "
                dc.b "and it was during this short interlude that one or two of lifes eternal "
                dc.b "questions crossed my mind. Namely, 'How does a shepherd stay awake when "
                dc.b "counting his sheep?' and If we count sheep to get to sleep, 'What do sheep "
                dc.b "count?'  'Can sheep count?'  'Do we care?'  'Do they care?'  The bulk of "
                dc.b "these questions fall into that ever popular "
                dc.b "'Why are wrong numbers never engaged?' catagory. "
                dc.b "However some are less easy to catagorise such as the old chicken an egg "
                dc.b "problem.   ie. 'What came first, the chicken or the egg?'   Well if you "
                dc.b "ask me,  (go on, you know you want to)  I really don't care which came "
                dc.b "first but I've a pretty good idea which came last - namely, the chicken "
                dc.b "omellette. Very tasty and surprisingly good value, one of the cheapest "
                dc.b "and tastiest forms of genicide...  I remember a good one that Undercover "
                dc.b "Elephant used to ask was this, 'Why is there only one Monoplies "
                dc.b "Commission?'   . . . . Frightening really, yet a perfectly valid "
                dc.b "question. It is but one of thousands that have cropped up over the years "
                dc.b "in pubs, at parties and in gutters whilst in that well-happy-but-not-"
                dc.b "quite-blacking-out stage of the evening (or morning - Yo Lee dude!). You "
                dc.b "know the bit, when all the beer nuts and twiglets have gone and the "
                dc.b "last gallant survivors are nursing the dregs of a bottle of Jack and "
                dc.b "somewhere in the hazy background someone has safely managed to accurately "
                dc.b "juggle 'Dark Side of the Moon' onto the turntable.   It was after a few "
                dc.b "of these little, 'research practicals' that I came to the decision that "
                dc.b "life is really just one massive .IFF animation file.  Also the Frame-Rate "
                dc.b "varies inversely with the number of Alcohol Units consumed.  Ahhemm. "
                dc.b "Allow me demonstrate. Firstly, it is generally accepted in animation "
                dc.b "circles that 20 to 25 frames per second is the norm. This is true for "
                dc.b "your average sober/boring person, however after about 5 or 6 pints (10 to "
                dc.b "12 units) you should notice lifes frame rate beginning to drop to "
                dc.b "somewhere in the region of 10 to 12 (if your lucky) frames per second. "
                dc.b "If / By the time you reach 10 to 12 pints you should be   (1) Down to one "
                dc.b "frame per second    (2) Very unwell    (3) Unable to continue counting "
                dc.b "successfully. Proof positive, I'm sure you'll agree.  I guess I must just "
                dc.b "be another one of lifes bar-room philosophers, a few beers and you can "
                dc.b "change the world (a few more and you can't be trusted to safely change "
                dc.b "beer glasses)...   Another thing that continues to amaze me about drunks "
                dc.b "is that no matter how wasted they are, they can still find their way home "
                dc.b "from ANYWHERE!  It must therefore follow that if you are lost in a strange "
                dc.b "place and you want to get home - don't use the old, ask a policeman "
                dc.b "tactic, just nip into Oddbins and polish off a crate of Super-Strength-"
                dc.b "Thunder-Chunder. This will have the double advantage of kicking in your "
                dc.b "homing instincts and secondly you really wont care where the hell you are "
                dc.b "anyway! So just remember folks, if you get lost, don't ask a policeman, "
                dc.b "ask a beer!    I suppose you could turn it into an Olympic Sport. You "
                dc.b "simply take a campus-load of students to a mystery pub and get them "
                dc.b "wasted (this shouldn't be too hard) then all you do is tag them (staple a "
                dc.b "beer mat to them or something) and then let them out into the wild. The "
                dc.b "first one home wins a beer.  Oh yeah, that reminds me of another of "
                dc.b "lifes little mysteries - Why is it, that after 22 pints of Mega-Strength "
                dc.b "German Imported  (or 1 pint of Orkney Skull Splitter!) you'll quite "
                dc.b "happily eat ANYTHING!  You'll eat the sort of stuff that would KILL "
                dc.b "you if you were sober!  And your not put off be the thought of walking "
                dc.b "(or crawling) for ten miles through the psycho-head part of town on the "
                dc.b "off chance that the 'Light of Bengal Indian Carry Out' will still be open "
                dc.b "when you get there. Even after you've queued for an hour you'll probably "
                dc.b "end up ordering number 37 which will invariably taste like 'broken glass "
                dc.b "and lava in a napalm sauce' -  But, by this time your sensory nervous "
                dc.b "system has packed in completely, so you won't notice...... until "
                dc.b "tomorrow...   H  A  N  G  O  V  E  R    !  !  !   ...Your mouth tastes like "
                dc.b "a badgers bum.  Your tongue is 10 times the size of your mouth.  You've "
                dc.b "got variable speed scroller-head and all you can smell is broken glass "
                dc.b "and lava in a napalm sauce.  Oh no..... not again.  You've emptied your "
                dc.b "carry-out over your best 'Beer-Monsters On Tour' T-shirt..... For a while "
                dc.b "you sift through all the clues whilst gazing at the ceiling. The ceiling "
                dc.b "looks like Trip-a-tron. Staring vacantly you put all the clues together "
                dc.b "and come to the monumentous decision.... It must be Sunday.    "
                dc.b ".... This is all very true except when it's actually Saturday afternoon. One "
                dc.b "particular Saturday afternoon to be precise (let's call it the 22nd of "
                dc.b "June ) and I'm still trying to sleep off the effects of a rather good "
                dc.b "Mama's Boys concert-cum-beer-sesh' from the Friday. Anyway, here was I in "
                dc.b "a rather fragile condition when who arrives at the door?  None other than "
                dc.b "me old bob-buddie, Oberje.  And wotz-ee-got?  A brand spanking (ooer - "
                dc.b "Viz) new Tecno mouse for yours truly. ...Oh man, what a horrible position "
                dc.b "to be in (ooer - again). A funky new mouse to play with but if I move an "
                dc.b "inch I could spend the rest of the afternoon speaking to Ralph and Huey "
                dc.b "on the great white telephone.  But as fate would have it my head stopped "
                dc.b "spinning by dinner time (although dinner was the last thing on my mind) "
                dc.b "and I was able to boot up Deluxe Paint and test drive this custom rodent. "
                dc.b "Wow, what a difference! The problem now is that I can never go back to an "
                dc.b "Atari mouse. I managed to knock up a font and a piccy of Olaf (a one "
                dc.b "foot high, stuffed Viking that Undercover Elephant brought back from his "
                dc.b "hols). - WARNING - WARNING - Scrollerhead will be settling in about now "
                dc.b "so to allow you time to rest your eyes there will now be a short pause " 
                dc.b ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . "
                dc.b ". . . . . . . . . . . . Poz . . . Thank you. Short pause, get it! "
                dc.b "   Oh well, theres no pleasing some folk. No, it wasnt a typo, it "
                dc.b "was a joke (thinly disguised as a typo).  However I "
                dc.b "do feel it's only fair to warn you now that there may be one or "
                dc.b "two more little typos (that's a Speling misstaick 2 U) at some later "
                dc.b "stages of this scroller.  Now I'll try and go back "
                dc.b "and fix 'em but if you see any you'll have to shout out really "
                dc.b "loud, coz your old Uncle Pixar's getting on a bit and his hearing "
                dc.b "ain't too good.  I blaim this heavy metal music.  Bring back "
                dc.b "national service, that's what I say.  Why in my day you could "
                dc.b "take a girl to the pictures, buy a can of cresta and a packet of "
                dc.b "spangles (or pacers) and still have change left for a tram home.  "
                dc.b "Bloody kids, I blame the parents.  Now where was I, Oh yeah,  The "
                dc.b "reason for my mind wandering is the fact that I'm pretending to "
                dc.b "type this into the monitor whilst actually watching re-runs of "
                dc.b "Gabriela Sabatini (try spelling that one right after 3 wine gums) "
                dc.b "in the women's finals of Wimbeldon '91 on the TV.   Very "
                dc.b "distracting, I'm sure you'll agree....  new balls please.  Bzzzp, "
                dc.b "Crackle, Pop - Now, now, we don't want any smut in this scroller, "
                dc.b "there should be plenty more of that in the other scrollers if the "
                dc.b "last Inner Circle Demo is anything to go by. So we'll have no "
                dc.b "mentions of PEEKs and POKEs just to get a cheap laugh.  We know "
                dc.b "that the sort of people that read a Fingerbobs scroller are not "
                dc.b "the sort of people that would go smirk, giggle, giggle, tee-he at "
                dc.b "the slightest mention of PEEK into ADDRESS ......  or are they?   "
                dc.b "What do you reckon TCC?  Has our audience got minds, dirtier than "
                dc.b "the Bombay sewer system?  Only time will tell.  Well, as a little "
                dc.b "experiment we want you to listen to some simple phrases.  Simply "
                dc.b "shout out either,  (a) I don't see anything funny in that.  or  "
                dc.b "(b) OOOOER - sounds a bit rude!   Ready?  Okay, here goes with "
                dc.b "Phrase number one -  'I was up all night POKEing Jet Set Willy.' "
                dc.b ". . . . . Not bad, mainly (a)'s but I suspect that many of you "
                dc.b "are old speccy owners so we'll move on to Suspect Phrase No. 2 -  "
                dc.b "'She was only an Admiral's daughter.... etc.'  boom, boom... em, "
                dc.b "I mean let's look at the votes.  Just as I thought, ALL (b)'s.  "
                dc.b "Well there's only one thing I can say to that.  Fair enough lads, "
                dc.b "I had a sneaking suspicion that you were all closet Viz readers "
                dc.b "anyway.  Oh well so much for good taste and morals, I guess the "
                dc.b "only thing that shifts a Fingerbobs scroller is SEX and BEER.  "
                dc.b "But preferably not at the same time as this can cause one or two "
                dc.b "problems.  Oh bugger.... I'm off again.  Why is it that every "
                dc.b "time I write a scroller, all I ever talk about is sex and beer.  "
                dc.b "But hey, If it ain't broke, don't fix it!  So dudes, without "
                dc.b "further ado, I give you the Fingerbobs Sex and Beer scroller "
                dc.b "number IV......   Roll up!  Roll up! Smoke 'em if you got 'em.  "
                dc.b "Steal 'em if you ain't.  Grab a partner.  If you can't grab a "
                dc.b "partner, grab a beer - and settle down in front of your ST for a "
                dc.b "trip-a-tron down memory-location lane.  Now I don't know which "
                dc.b "machines you dudes all started on (If I did I could make a "
                dc.b "fortune selling the film rights and doing talk shows, but alas I "
                dc.b "don't), but does anybody out there remember a time when you could "
                dc.b "pick a copy of PCW and not see any ads for the spectrum!  Now "
                dc.b "that's going back quite a way.  I'm going back to the days of "
                dc.b "Choplifter on the Apple II and Hungry Horace on the Speccy.  The "
                dc.b "days of Gridrunner on the Vic 20, Zalaga and Frak on the BBC "
                dc.b "Micro.  Yes folks, this is where it all began... Does anyone "
                dc.b "remember this one... 1010101001010101010010101001010101.  Of "
                dc.b "course you do!  It's the loader for Manic Miner.  That reminds "
                dc.b "me, any fans of ol' Speccy games... watch this space for a "
                dc.b "Fingerbobs exclusive announcement - more later (if you're very "
                dc.b "good and promise to eat all your vegetables).  Where woz I?  Oh "
                dc.b "yeah I reckon you must be pretty bored by now considering I "
                dc.b "haven't discussed sex or beer for at least 2K.  To remedy this "
                dc.b "I've channel-hopped to MTV which has provoked quite a heated "
                dc.b "discussion here in Fingerbobs mission control. The question on "
                dc.b "everybody's lips is, who is MTV's sexiest VJ.  Let's see now, I "
                dc.b "have to admit that I have the absolute wah-wah mega-hots for "
                dc.b "Kristiane Backer.  Undercover Elephant has a soft spot for Pip " 
                dc.b "Dann (he didn't however elaborate on which soft spot he had for "
                dc.b "her).  Occulus goes for Rebecca de Ruvo (but we reckon he's on "
                dc.b "heat at the moment and would go for anything... But it looks like " 
                dc.b "The only things we all agree on is that Maiken Wexo should never "
                dc.b "have left and Terry Christian should never have been born.  "
                dc.b "Hmmmm... While we're on the subject of hot babes I think it's "
                dc.b "time you dudes helped me out.  You see I'm faced with a "
                dc.b "frightening dilemma. I've got a chronic case of the burbling wah "
                dc.b "wah's for this girl I know.  Fair enough dude, I hear you say, "
                dc.b "but why is that a problem to a such a super-hung monster-stud "
                dc.b "passion-wagon like yourself. Well I appreciate the observation "
                dc.b "but listen up bob-buddies, there's a catch.... She's an AMIGA "
                dc.b "owner.  Oh man, totally bogus.  Now what does a good dude do now.  "
                dc.b "Well guys, I thought about it long and hard, then I washed my "
                dc.b "hands, sat down and wrote a letter to the one person on the "
                dc.b "planet who knows everything about everything...  Mr CPU, Unix "
                dc.b "guru, Root incarnate... Kenn Garroch.  It always amazes me that "
                dc.b "our Kenn knows everything from how to re-configure a Cray 3, to "
                dc.b "programming virtual reality environments on a ZX80.  There's "
                dc.b "nothing our Kenn doesn't know about (except perhaps printing "
                dc.b "programs without at bug in them - cynical Ed).  It is a little "
                dc.b "known fact though that our Kenn, or K.E.N.N. as it is more "
                dc.b "correctly spelt is actually short for Kingsize Enormous Neural "
                dc.b "Network.  Funnily enough G.A.R.R.O.C.H. actually stands for (God, "
                dc.b "And Relatively Right On Cool Hacker).  As your no doubt aware the "
                dc.b "world of computers is full of acronyms and jargon and indeed "
                dc.b "there is already a lot of Computer Language Already Published "
                dc.b "(C.L.A.P.).  In fact anyone coming in contact with computers for "
                dc.b "any length of time is bound to pick up a bit of the C.L.A.P. so "
                dc.b "for the sake of any of you kids who are new to the game your nice "
                dc.b "old Uncle Pixar (the one with the puppies), has compiled a list "
                dc.b "of common acronyms and their meanings, so eyes down and no "
                dc.b "cheating:    V.B.L.  is a  Very Big Lager - N.T.S.C. stands for "
                dc.b "Nine Teen Southern Comforts - V.D.U. is a Very Drunken User  "
                dc.b "and lastly  D.T.P.  stands for Drink Ten Pints.  There you go "
                dc.b "kiddies, your dear old Uncle Pixar does it again. That's enough "
                dc.b "for today but maybe later (if your very good) your nice Uncle "
                dc.b "Oculus will teach you some more. Either that or we'll play find the "
                dc.b "sweeties.... Sheesh, I'm a sad bastard really but hey, you knew "
                dc.b "that already!     SEX!    - Just checking your still "
                dc.b "awake. If your very good I'll be handing out endurance medals (and "
                dc.b "sleeping bags) at the end of the scrolltext. A quick click on the old "
                dc.b "stats box tells me that I'm currently running at 25K of mindless "
                dc.b "rambling. That's just over 4000 words dont ya know. I didn't know I could "
                dc.b "keep it up for so long for so long (ooer - guess who).  I think I'll get "
                dc.b "a job in politics. Yes folks, I know I can count on your vote coz when "
                dc.b "elected I promise to lengthen licencing hours, increase the ST pallette "
                dc.b "to 256 million colours and add a really ace chip that can produce fractal "
                dc.b ", ray-traced, virtual-reality. And for the programmers out there I'll"
                dc.b "make sure that every ST gets a free FALCON board that runs at a billion "
                dc.b "MIPS - honest. So vote Pixar - you know it makes sense.  Okay, now "
                dc.b "where was I.  Oh, yeah, I guess it's time for..... the joke. To "
                dc.b "let you understand, Hogamany came and went, the drams were "
                dc.b "flowing and with the usual mixture of much falling over, singing "
                dc.b "out of tune and kebab munching, the new year was rung in.  During "
                dc.b "this shocking drunken ritual I was told the following joke.  I'll "
                dc.b "apologise in advance to any European readers coz it's unlikely "
                dc.b "you'll get it, so how about nipping into the fridge and bringing "
                dc.b "us all down a beer or four?  Okay dokay dudes settle down coz "
                dc.b "this one takes a minute or too...  A man goes into a fish "
                dc.b "restaurant (as you do).  He sits down and the waiter introduces "
                dc.b "himself (in a hammed up French accent if you can manage one) -  "
                dc.b "'Good eve-en-ing sir.  My name is Jervaise and I will be your "
                dc.b "wait-er for this eve-en-ing. What would you like to order'. The "
                dc.b "man thinks for a minute then asks, 'Do you serve squid?'.  'Why "
                dc.b "certainly', replies Jervaise, 'We have several wild squid, in "
                dc.b "this tank over here'.  The man surveys the tank for a minute and "
                dc.b "says, 'I want that green squid on the bottom, the one with the "
                dc.b "big furry moustache.'  -  Jervaise becomes agitated at this and "
                dc.b "asks the man to select another squid as the one with the "
                dc.b "moustache belongs to the kitchen dishwasher. The man soon "
                dc.b "becomes adamant that the green squid with the moustache is the "
                dc.b "one for him. After much argument Jervaise backs down and agrees "
                dc.b "to speak to the dishwasher about the squid.  Hans, The "
                dc.b "restaurants German dishwasher, comes out to speak to the man "
                dc.b "about his green wild squid.  After a short conversation with the "
                dc.b "man he to backs down and the man has the squid with the moustache "
                dc.b "for his evening meal...    Huh?  Is that it? -   Well yes, but "
                dc.b "the moral of this story is this... (to be sung to the tune of the "
                dc.b "Fairy Liquid ad...)  -  'Hans that do dishes can be soft as "
                dc.b "Jervaise, with wild green furry lipped squid.'.... Groan, moan, "
                dc.b "yes it's awful but you should hear it when your wasted, it's "
                dc.b "great.  Talking of wasted, this little scroller is being finished "
                dc.b "off at the GBISTP , that's the Great British International ST "
                dc.b "Party to those of you who weren't there.  We've been hanging out "
                dc.b "in Bradford with Stick, Bilbo and about 70 other ST dudes all "
                dc.b "tapping out funky demos, smoking, drinking and blowing chunks. "
                dc.b "Anyway, to explain about what happened last night here's my good "
                dc.b "bob-buddie, Occulus - take it away Oci-babes.......             "
                dc.b "After the five hour trip to St Helens to pick up The Creeper.... "
                dc.b "The pizzas are late!..It's 6:50. They were meant to be here at "
                dc.b "6:30.....Where the !*$& are they!....7:20..Pizza "
                dc.b "frenzy!!!!!! That felt so good for most of us who had some food "
                dc.b "... Sorry about the southern fried chicken. Pixar told me that "
                dc.b "he really began to enjoy it once he had emptied his stomach in "
                dc.b "the nearest pub and had his second Jack Daniels of the evening... "
                dc.b "But wait things got better...The pub (with no name) held a "
                dc.b "stupendous competition with a fantastic first prize.....A T-shirt "
                dc.b "(Max Cider???) and six bottles of the fine vintage alcoholic "
                dc.b "(and thats what really matters, isn't it boys and girls!) apple "
                dc.b "beverage. Who won? Some down on his luck alcoholic that just "
                dc.b "happened to be attending this ST party....So much for the local "
                dc.b "brains or lack of them...Anyway "
                dc.b "my mind wanders....At closing time we got directions from the two "
                dc.b "barmaids (I don't think the other guys knew quite how old they "
                dc.b "were - Occulus - but I didn't care too much anyway) to a place "
                dc.b "that sold drinks til one AM ....Party on dudes! (Those that could "
                dc.b "handle the pace that is. The last thing I heard from Pixar, "
                dc.b "Oberje and the Ceeper was that they were leaving me 'cause I "
                dc.b "was 'Well in'...If only!..Some stupid mother*!œ'er who had had "
                dc.b "way too much to drink f!*^'d things up and I ended up making sure "
                dc.b "that the  A#$%*^&œ got home after bumping into me numerous "
                dc.b "times... By the way Oberje remember your favourite song of the "
                dc.b "evening 'Jailhouse rock'...ha!..ha!..ha!...Oh and the trick pool "
                dc.b "shots...Last thing I heard of them when I got back to the ST "
                dc.b "party was that the three 'Bobs were semi-comatose not long "
                dc.b "after they got back..Well its now I think it's time that I went "
                dc.b "and got some ZZZZZZs myself...This is TCC here it's about 3:30 AM "
                dc.b "on the saturday morning and I ain't been to bed since I woke up "
                dc.b "at home on thursday morning...Think I'll give it another bash "
                dc.b "(sleeping that is, so till later) TDL... "
                dc.b "News Flash.......Occulus here again and it's later on on Saturday "
                dc.b "morning... I had a brief account of The Creepers entry back at "
                dc.b "the ST party last night... Step One - Fall up the stairs. Step "
                dc.b "Two - Find a comfy spot to sleep under a table. Step Three - Oh "
                dc.b "$*!% where's the toilet I think I'm going to ..Blargh! Step Four "
                dc.b "- Lie comatose in various places until conciousness returns "
                dc.b "fully.... I just had to share that bit with y'all. Anyway it's "
                dc.b "all 100% truth no extra additives and don't believe Pixar when he "
                dc.b "pretends that I made it all up..who would need to make up stuff "
                dc.b "with real true life stories like that!..."
                dc.b ".......... Hi digerydudes, it's your sad old uncle Pixie-poos "
                dc.b "back at the keyboard.  Thanks there to our on the job (em spot) "
                dc.b "reporter, Mr Occulus.  Pulitzer material I'm sure.  I have to "
                dc.b "admit that his bit has been written but I'm not getting to see it "
                dc.b "till the demo goes out, but whatever he says, trust me boys and "
                dc.b "girls, It's a damn lie!  Well, it's now 4.00pm on Sunday 6th of "
                dc.b "September and we've got one hour left to finish this screen - "
                dc.b "I've just been updated by TCC on the program progress and it "
                dc.b "looks as though we should make it.... Ha Ha.  If your one of "
                dc.b "those wealthy eccentric types who enjoys nothing more than to "
                dc.b "send complete strangers, vast sums of cash in easy-2-carry bags "
                dc.b "then heres an address for you.... Mr Pixar,    Flat 10,   138 "
                dc.b "Hutcheon Street,     Aberdeen,     "
                dc.b "Scotland,    AB2 3RX,   U.K.    However, there is a bit of a problem with "
                dc.b "this coz some BASTARD is stealing my mail! I'm only getting about 30% of "
                dc.b "all the letters that are being sent to me. So if you want to take your "
                dc.b "chances and run the gauntlet of pilfering posties, nicking neighbours and "
                dc.b "thieving thieves you would be well advised to mark it 'Letter Bomb - do "
                dc.b "not bend' or 'Handle with care - Nuclear shit' or even better, make it "
                dc.b "look like junk mail coz it usually gets through!  Anyway, I wish you the "
                dc.b "best of luck. Failing that you can get to me through either Oberje or the "
                dc.b "Caped Crusader, or better still, throw a little something on your greets "
                dc.b "list.  Right, For more waffle (and I ain't talkin' Maple syrup), "
                dc.b "Its over to Occulus, our "
                dc.b "man on the spot (don't know which spot, but there you go).... "
                dc.b "I'm on this spot over here...the one near the coffee! I think "
                dc.b "that it's almost time for another cup 'cause I only had three "
                dc.b "this hour. The highlight of today had to be our search for "
                dc.b "breakfast (if you can call it that at McDonalds), well our first "
                dc.b "meal after waking up whatever time it was. Trekking through the "
                dc.b "rain-drenched streets of Bradford using our ancient skills of "
                dc.b "foraging...just like in the stone-age..speaking of which that "
                dc.b "reminds me of Quattro who was in the stoney age last night. I bet "
                dc.b "he's suffering from lots of short-term memory loss not like "
                dc.b "myself..that never happens to me.....that never happens to me.... "
                dc.b "that never happens to me....now what was I talking about....Oh "
                dc.b "yeah! My two favourite things...violence and sex..put them "
                dc.b "together and what have you got...sexy violence...nah..violent "
                dc.b "sex..that's more like it..burble burble..They're coming to take "
                dc.b "me away ha! ha! They're coming to take me away...... "
                dc.b "Oberje on the Mike! Time for a quick, independant and completely "
                dc.b "truthfull (ha!) account of the fabulous Ripped Off Copy Party........    "
                dc.b "For me it begins with "
                dc.b "the arrival of 'the lads' in the hire-car. This car was of course "
                dc.b "too small to hold all 4 'bobs "
                dc.b "and their massive 'equipment' ( ooh-err Missus ). However after "
                dc.b "many weeks of travelling though shark infested forrests and leafy "
                dc.b "green oceans the Fingerbobs arrived "
                dc.b "at the venue.  This was Thursday, the remainder of the day was " 
                dc.b "fairly quiet as we arrived "
                dc.b "after the pubs had shut. The next day was better however much "
                dc.b "more entertaining, we had pizza ( eventually! - it was very late ) "
                dc.b "and in the early evening the "
                dc.b "Fingerbobs went for a 'quick bevvie' about 7 o'clock. "
                dc.b "This involved going to a little pub called 'The New Miller'. Once "
                dc.b "there we proceded to drink ALL their Jack Daniels.  We did a stupid "
                dc.b "quiz & played some pool. "
                dc.b "Finally leaving when the pub shut, but being directed to attend the "
                dc.b "'Lock,Stock & Barrel' by "
                dc.b "the barmaids in 'The New Miller'. This place was okay but Pixar, "
                dc.b "Creeper & myself were all too drunk to remain more than 2 drinks. "
                dc.b "We left, leaving Occulus to try "
                dc.b "and fulfill his own nefarious intentions. Arrival back at the Party "
                dc.b "proved too exciting for "
                dc.b "me so I crawled into my sleeping bag and let warm snuggly-wuggly sleep "
                dc.b "take me.......   but only after The Creeper had stopped making those "
                dc.b "awful 'hurling' noises "
                dc.b "from next door.   Only an hour passed before I awoke although at the time "
                dc.b "I was convinced I "
                dc.b "had been asleep for 12 hours!  However it turned out I was just too "
                dc.b "pissed to have any perception of time. After assurances from Griff I "
                dc.b "retired again. The next "
                dc.b "day heralded the approach of A BASTARD HANGOVER! I felt pretty awful, "
                dc.b "but when the cafe "
                dc.b "downstairs opened we poured in and devoured a large quantity of coffee "
                dc.b "- thank the lord. I dont recall much of the rest of that day because of "
                dc.b "some short-term "
                dc.b "memory loss, several other people were similarly afflicted. I doubt many "
                dc.b "people here at the "
                dc.b "Party escaped this sad state of affairs. We definately did something on "
                dc.b "Saturday though.  .......Oh god I'm sooooooo f**king tired I can barely "
                dc.b "keep my bleeding "
                dc.b "( literaly ) eyes open!   Anyhow its Sunday now, so the previous text "
                dc.b "brings us up to date. "
                dc.b "Now thats done, all that remains is to say anything you read in other "
                dc.b "scrolltexts from this Party - Its all a goddamn lie!!!!!!!!!       "
                dc.b "Oh no! Thats our man "
                dc.b "Stick on the P.A warning of the minimal 45 minutes remaining for all "
                dc.b "demos to be finished!  "
                dc.b "TCC and The Phantom are across the room quickly writing the demo "
                dc.b "screen! I expect they'll need this text soon.  There is one more day "
                dc.b "of the party remaining, "
                dc.b "but I'll be leaving after the compo-voting.... "

                dc.b "Say Yo Yo Yo! This is MC Pixar comin' atcha undead and direct from the "
                dc.b "Great British International ST Party... Before I sign off, a few last "
                dc.b "greets to some folks that paid me to see their name in lights... "
                dc.b "Firstly a big whopping great hello to the dudes "
                dc.b "from the Shoppe, namely Undercover Elephant, Pol, Occulus and ARD,  The "
                dc.b "AD&D gang, namely Herbatious Greenfingers, Lyra, Grond, Grog and Tyrone. "
                dc.b "Big funky hello's to Stick, Bilbo, Griff, Phantom & Boggit. A "
                dc.b "hugely immense howz-it-hangin' to all me co-members of the Inner Circle "
                dc.b "and all the French Zuul dudes.   A big wave to the TCB dudes, "
                dc.b "looking forward to your Last Temptation demo!   Thank You's go to Oberje "
                dc.b "for the new mouse,  Gary for putting up with us in Glasgow, time after time! "
                dc.b "And although it's extremely unlikely that he's reading this, ta-very-much "
                dc.b "to the dude that jump-started Occulus's car in the car park after AC/DC. "
                dc.b "A big wobbling thanks to Electronic Arts for bringing Deluxe Paint to "
                dc.b "the ST. A frighteningly loud thanx to Faith No More, Guns n Roses and "
                dc.b "Pearl Jam for the best gigs of the year.  A staggeringly large way-"
                dc.b "to-go to Yak for bringing Llamatron into the world!  A small but "
                dc.b "perfectly formed Cheers to Nescafe and Jack Daniels for being their when "
                dc.b "I needed you.  Also a quick Yo to the cool dude at ST Format who had the "
                dc.b "staggeringly good taste to put a screenshot from the Fingerbobs screen in "
                dc.b "their review of the Decade Demo. And to finish a huge double-barreled "
                dc.b "all-the-best to anyone I missed out (sorry folks).  Well, "
                dc.b "Things are kinda winding down "
                dc.b "now so I hope you enjoy all the party demos especially the Untouchables "
                dc.b "Rainbow demo - Excellent stuff guys!    But before I close the "
                dc.b "lid of 'the tank'for the last time, we would all like to thank "
                dc.b "Stick & Bilbo of Ripped Off for putting the party together - "
                dc.b "before we get any more of the aforementioned 'snuggly-wuggly "
                dc.b "sleep',  I think we can go over one last time to"
                dc.b "a man outstanding in his field (sheep field, I think), "
                dc.b "Yes folks, You know he's MAD, We all know he's BAD, God knows "
                dc.b "he's SAD!  The man who loves you with more than "
                dc.b "just his heart.... Yes,  He's off his trolley,  He's out of his tree  "
                dc.b "and He's in your face!  It's Doc Oc himself.......  Occulus!   "
	    	dc.b "Well hey it's great to be back, I'd just like to thank the Academy, "
                dc.b " my family...oh sorry! Wrong speech. Well anyway, Here are "
                dc.b "some more explanations for those of you out there that are confused "
                dc.b "by the multitude of abbreviations used in the Atari world: ACIA - "
                dc.b "Alcohol can Induce Amnesia, ASCII - Alcoholic Software Consumer Ideas "
                dc.b "Interface, ATARI - Alcoholic Tattooed Arseholes Rendered Imobile, "
                dc.b "BIOS - Bourbon Incites Offensive Sex, BPB - Beer Panic Button, "
                dc.b "CD - Can't Drink, DD - Dangerous Drunks, DMA - Demand More Alcohol, "
                dc.b "DS - Drink Stolichnaya (Vodka that is), DSP - Down Sixteen Pints, "
                dc.b "FALCON - Fantastic Alcohol Loosens Chat On Nudes, FD - Fat Drunkards, "
                dc.b "HD - Hardened Drinkers, MB - Mostly Bollocks, MFP - My Five Pints, "
                dc.b "PAL - Pour Alcoholic Liquid, RAM - Real Ale Man, SCSI - Southern "
                dc.b "Comfort Slaughters Intellectuals, SS - (Well there's actually two "
                dc.b "theories about this one down at' Bobs Central) Suicidal Software or "
                dc.b "Safe Sex (the latter being my personal favourite!), STE - Sober Teetotal "
                dc.b "Eunuchs, STFM - Sink Ten Foaming Mouthfulls, TOS - Try Ouija Sessions "
                dc.b "(You get about the same kind of response with either one), TRAP - "
                dc.b "Try Real Ale Punters, VGA - Very Good Alcohol (You mean that someone "
                dc.b "has found BAD alcohol?), YAMAHA - Your Average Male Alcoholic Has Answers "
                dc.b "(not always the right ones, but who cares!) I hope this helps all of you out "
                dc.b "there and remember if you have any questions about any more abbreviations "
                dc.b "don't hesitate to call your good old uncle Occi, 'cause you can rely "
                dc.b "on me to keep you straight. And remember just because all of your friends use "
                dc.b "gerbils doesn't mean that you have to, after all it's better to be original "
                dc.b "so try something a bit out of the ordinary.........like women, I've been told "
                dc.b "that they are a lot more fun.....Anyway the party's over so it's time to go"
                dc.b "..........and find another!.......................",0
 
;----------------------------------------------------------------------

counter         ds.w    1
offset          ds.w    1

SCRNPT1:	DC.L	SCROLL_BUF+352
		EVEN

		DS.B	352
SCROLL_BUF:	DS.B	20000
		EVEN

BIGBUFF:        INCBIN  "QUITEBIG.DAT\QUITEBIG.GFX"
                EVEN
                
                DS.L    256
STACK           DS.L    1

VCOUNT:         DS.W    1

MOUSEDATAY:     DS.W    1
MOUSEDATAX:     DS.W    1
XMOUSE          DS.W    1
YMOUSE          DS.W    1

SHITE:          DS.W    1

mt_data:        incbin  "QUITEBIG.DAT\DELERIA.MOP"
                END
                END
