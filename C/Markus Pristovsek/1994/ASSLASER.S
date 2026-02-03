* Projekt: laser.s
* modified by Thomas Klingelhîfer
* improved by Markus Fritze
* last change: 20.05.1989
* Source is for the OMIKRON.Assembler
* An DVI_100 und Turbo C angepaût von markus pristovsek am 16.7.93 *

* Die Beispielroutine laser() gibt eine Grafikseite auf dem
* Atari SLM 804 aus
* der Lasercontroller wird automatisch gesucht !!!
* Eingabe: Zeiger auf Bitmap
* Bitmap hat 3386 Zeilen, jede Zeile ist genau 292 Bytes breit
* also 2336 Pixel

* Definitions
dmadata        EQU $FFFF8604.W
dmahigh        EQU $FFFF8609.W
dmamid         EQU $FFFF860B.W
dmalow         EQU $FFFF860D.W
gpip           EQU $FFFFFA01.W
flock          EQU $043E.W
_hz_200        EQU $04BA.W

EXPORT	print_laser, check_laser, kop2_1

                TEXT
; **** FÅr DVI_100 hinzugefÅgt 16.7.93 ****
; ******* Vergrîûert eine Zeile auf 2:1
; ******* Aufruf:  kop2_1( start, startbreite, ziel )
kop2_1:	MOVE.L	A2,	-(A7)
	LEA	tab_21,	A2
	SUBQ	#1,	D0
	MOVEQ	#0,	D1
	MOVEQ	#0,	D2
kl2_11:	MOVE.B	(A0)+,	D1	; Nur auf Speicherspar
	BEQ	kl2_12
	MOVE.B	D1,	D2	; nicht auf Tempo, da
	ANDI.B	#$0F,	D1	; nur fÅr Lupe nîtig
	LSR.B	#4,	D2
	MOVE.B	0(A2,D2),(A1)+
	MOVE.B	0(A2,D1),(A1)+
	DBRA	D0,	kl2_11
	MOVE.L	(A7)+,	A2
	RTS

kl2_12:
	CLR.W	(A1)+
	DBRA	D0,	kl2_11
	MOVE.L	(A7)+,	A2
	RTS


print_laser:    move.l  A0,D0
                movem.l D2-D7/A2-A6,-(SP)
                movea.l D0,A4           * save pointer
                pea     ikaus           * Keyboard off
                move.l  #$190000,-(SP)
                trap    #14
                addq.l  #8,SP
                clr.l   -(SP)
                move.w  #$20,-(SP)      * supervisor mode on
                trap    #1
                addq.l  #6,SP
                movea.l D0,A5
                bsr.s   print           * do the work...
                move.l  D0,D7
                move.l  A5,-(SP)
                move.w  #$20,-(SP)      * back to user mode
                trap    #1
                addq.l  #6,SP
                pea     ikein           * Keyboard on
                move.l  #$190000,-(SP)
                trap    #14
                addq.l  #8,SP
                move.l  D7,D0
laser2:         movem.l (SP)+,D2-D7/A2-A6
                rts

* Druckroutine print
* Eingabe: Zeiger auf Bitmap in A4
* verwendete Register: d0,d1,d2,d3,d4,d7,a0,a1

print:          lea     dmadata.w,A0
                lea     dmahigh.w,A1
                st      flock.w         * lock dma channel
*
* Command Phase
*
                move.w  #$88,2(A0)      * assert command signal
                move.w  controller,D0
                lsl.w   #5,D0
                or.w    #$0A,D0         * PRINT
                bsr     writcmnd        * command byte 0
                bne     prabrt
                moveq   #3,D2
send_loop:      moveq   #0,D0           * command byte 1-4
                bsr     writcmnd
                bne     prabrt
                dbra    D2,send_loop
                and.b   #$F7,D0         * command byte 5 (Bit 3 cleared)
                move.l  D0,(A0)
                moveq   #4,D1
                add.l   _hz_200.w,D1
codel:          cmp.l   _hz_200.w,D1    * wait a moment
                bge.s   codel
*
* Data out phase
*
                move.w  #$98,2(A0)      * reset fifo
                move.w  #$0198,2(A0)
                move.w  #$98,2(A0)
                move.w  #1,(A0)
                move.w  #$88,2(A0)
                move.l  A4,D0           * load initial band base
                move.l  D0,-(SP)
                move.b  3(SP),dmalow.w  * initialize dma base address
                move.b  2(SP),dmamid.w
                move.b  1(SP),dmahigh.w
                addq.l  #4,SP
                move.w  #$0192,2(A0)
                move.l  #$730112,(A0)   * write sector count, start dma
                clr.b   D3              * clear two-byte fifo adjust flag
                moveq   #16,D7          * do 15 more bands
                moveq   #32,D4          * for SUB.L #32,D0
                move    SR,D1           * save status register
                ori     #$0700,SR       * no interrupts, please
bdloop:         add.l   #200*292+32,D0  * get final adress + 32
                tst.w   D7              * last band?
                bne.s   bdwait          * No =>
                sub.l   #14*292,D0      * 186 lines instead of 200 lines
bdwait:         btst    #5,gpip.w       * check for premature status phase
                beq.s   forget          * abort and get status byte
                movep.w 2(A1),D2        * get current dma mid and low
                cmp.w   D2,D0           * compare to final adress
                bne.s   bdwait          * not there yet ?
                sub.l   D4,D0           * point to next band base
                tas.b   D3              * test two_byte fifo adjust flag
                bne.s   noadju          * do not adjust next base
                addq.l  #2,D0           * compensate for two-byte fifo
noadju:         move.l  D0,-(SP)
                move.b  3(SP),dmalow.w  * reinitialize dma base address
                move.b  2(SP),dmamid.w
                move.b  1(SP),dmahigh.w
                addq.l  #4,SP
                move.w  #$92,2(A0)      * reset fifo
                move.w  #$0192,2(A0)    * select sector count register
                move.l  #$730112,(A0)   * reload sector count register
                dbra    D7,bdloop       * more bands
                move    D1,SR           * restore status register
*
* status phase
*
stwait:         btst    #5,gpip.w       * wait for status byte
                bne.s   stwait
stbyte:         move.w  #$8A,2(A0)      * select status register
                move.w  (A0),D0         * read status byte
                moveq   #2,D1           * ca. 5 millisec delay
                add.l   _hz_200.w,D1    * nb minimum delay is 20 microsec
stdel:          cmp.l   _hz_200.w,D1
                bge.s   stdel
                clr.l   D0
                bra.s   prexit          * return status byte
prabrt:         moveq   #-1,D0          * return error flag
prexit:         sf      flock.w         * unlock dma channel
                rts
forget:         move    D1,SR
                bra.s   stbyte

*
* writcmnd
* write command byte to DMA controller
*
* inputs:       d0.l = data control words
*                       a0       = pointer to DMA controller (ff8604)
* outputs:      EQ   = successfull command write
*                       NE       = Error occured
* modified: d1
*
writcmnd:       swap    D0
                move.w  #$8A,D0
                move.l  D0,(A0)
                moveq   #2,D1           * ca. 5 millisec delay
                add.l   _hz_200.w,D1    * nb minimum delay is 20 microsec
wrdel:          cmp.l   _hz_200.w,D1
                bge.s   wrdel
                moveq   #40,D1          * 200 millisec timeout
                add.l   _hz_200.w,D1
writlp:         btst    #5,gpip.w
                beq.s   writok          * command byte acknowledged
                cmp.l   _hz_200.w,D1
                bge.s   writlp
                moveq   #-1,D1          * timeout - set error flag
writok:         rts

;inquiry(Device=D7)
inquiry_slm804: movem.l D1-A6,-(SP)
                st      $043E.w
                moveq   #0,D5
                lsl.b   #5,D7
                or.b    #$12,D7         ;Inquiry-Opcode
                pea     prn_name_buffer
                move.b  3(SP),$FFFF860D.w
                move.b  2(SP),$FFFF860B.w
                move.b  1(SP),$FFFF8609.w
                addq.l  #4,SP
                bsr.s   do_cmd
                beq.s   inquiry_slm8041
                or.b    #$80,D5
                bsr.s   do_cmd
                bra.s   inquiry_slm8042
inquiry_slm8041:moveq   #0,D0
inquiry_slm8042:sf      $043E.w
                movem.l (SP)+,D1-A6
                rts

do_cmd:         lea     $FFFF8604.w,A0
                move.w  #$98,2(A0)
                move.w  #$0198,2(A0)
                move.w  #$98,2(A0)
                move.w  #1,(A0)
                move.w  #$88,2(A0)
                move.w  D7,D0
                bsr     writcmnd        ;Befehlscode & Controller Number senden
                bne.s   do_cmd_error
                moveq   #3,D3
do_cmd1:        moveq   #0,D0           ;4 FÅllbytes senden (Device=0)
                bsr     writcmnd
                bne.s   do_cmd_error
                dbra    D3,do_cmd1
                move.w  D5,D0           ;Im zweiten Druchlauf $80
                bsr.s   send_byte
                bsr.s   get_status
                move.b  D0,D3
                bne.s   do_cmd_error
                tst.b   D5
                bpl.s   do_cmd_error

                moveq   #4,D2           ;5 Bytes holen
                moveq   #0,D0
do_cmd2:        bsr.s   get_status      ;Byte holen
                bne.s   do_cmd_error    ;Fehler, raus
                dbra    D2,do_cmd2      ;schon alle Bytes?
                moveq   #0,D2
                move.b  D0,D2           ;das letzte Byte war die StringlÑnge
                bra.s   do_cmd5
do_cmd4:        bsr.s   get_status      ;Byte holen
                bne.s   do_cmd_error    ;Fehler, raus
                move.b  D0,(A1)+        ;String merken
do_cmd5:        dbra    D2,do_cmd4      ;schon alle Bytes?

                moveq   #0,D0
                move.b  D3,D0           ;alten Status zurÅckholen
do_cmd_error:   rts

get_status:     moveq   #80,D1
                add.l   $04BA.w,D1
send_cmd2:      btst    #5,$FFFFFA01.w
                beq.s   send_cmd3
                cmp.l   $04BA.w,D1
                bge.s   send_cmd2
                moveq   #-1,D0
send_cmd3:      bne.s   do_command_err
                move.w  #$8A,2(A0)
                move.w  (A0),D0
                bsr.s   pause
                moveq   #0,D1
do_command_err: rts

send_byte:      swap    D0
                move.w  #$8A,D0
                move.l  D0,(A0)
pause:          move.l  D1,-(SP)
                moveq   #2,D1           * ca. 5 millisec delay
                add.l   _hz_200.w,D1    * nb minimum delay is 20 microsec
send_byte1:     cmp.l   _hz_200.w,D1
                bge.s   send_byte1
                move.l  (SP)+,D1
                rts

check_laser:    movem.l D1-A6,-(SP)
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1              ;Super(0L)
                addq.l  #6,SP
                move.l  D0,-(SP)
                moveq   #7,D7           ;Mit Device 7 anfangen
check_laser1:   lea     prn_name_buffer,A1
                bsr     inquiry_slm804
                tst.w   D0
                bne.s   check_laser3
                lea     slm_name,A0
check_laser2:   move.b  (A0)+,D0
                beq.s   check_laser4
                cmp.b   (A1)+,D0
                beq.s   check_laser2
check_laser3:   dbra    D7,check_laser1
                moveq   #-1,D7
check_laser4:   move.w  D7,controller
                move.w  #$20,-(SP)
                trap    #1              ;Super(OldStack)
                addq.l  #6,SP
                tst.l   D7
                smi     D0
                addq.b  #1,D0
                ext.w   D0              ;0=Fehler, 1=Ok
                movem.l (SP)+,D1-A6
                rts


                DATA
; *** Kopiertabelle 2:1 ***
tab_21:         DC.B	$00, $03, $0C, $0F, $30, $33, $3C, $3F
                DC.B	$C0, $C3, $CC, $CF, $F0, $F3, $FC, $FF

ikaus:          DC.B $13        ;IKBD aus
ikein:          DC.B $11        ;IKBD an
controller:     DC.W -1         ;Devicenummer 0-7 (-1: Fehler)
slm_name:       DC.B 'PAGE PRINTER',0

                BSS
prn_name_buffer:DS.B 128
                END
