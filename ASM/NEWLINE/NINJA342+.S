DEBUG_SHOWPREPARETIMING EQU 0
;
; Disassembly & Comments by GGN (started on 26/09/03)
; Using Turbo Assembler & Easyrider 4
; Note: In the part description a '-' denotes that the part is fully analysed
;

; Player notes:
; -------------
; Call modInitMachine (or jsr startofmoduleplayer) with these values loaded
; a0=module's address
; d0=requested replay frequency (in Hz)
;    Theoretically it can take any value from 4 to 21 kHz
;    (that is true for the (Mega)ST(E)/TT routines, dunno for Falcon yet)
; d1=volume control register
;    0=STF/M YM2149 7-bit replay with volume control
;    1=STF/M YM2149 8-bit replay with volume control
;    2=STF/M YM2149 8-bit replay without volume control
;    3=(Mega)STE/TT DMA 8-bit with volume control
;    4=(Mega)STE/TT DMA 8-bit without volume control
;    5=Falcon (DMA?) 8-bit with volume control
;    6=Falcon (DMA?) 8-bit without volume control
; d2=mute control register (a bit weird if you ask me, but it's here)
;    0=Don't mute any channel
;    1=Mute Channel 1 only
;    2=Mute Channel 2 only
;    3=Mute Channel 3 only
;    4=Mute Channel 4 only
;
; Then, call modInitInterrupts (or jsr startofmoduleplayer+4) when your
; code is ready to start executing, to set the interrupts and start the
; module replay
;
; Each VBL you are obliged to call modVBL (or jsr startofmoduleplayer+12)
; as to update the buffers
;
; Finally, before exiting call modStop (or jsr startofmoduleplayer+8) to
; restore interrupts & stop replay
;

                OPT X+

CM_ZUSATZ EQU 900       ;add. loop length added to every loopig sample

                TEXT
Begin:
                bra     modInitMachine
                bra     modInitInterrupts
                bra     modStop
                bra     modVBL
L0000:          DCB.W 4
                DC.B $00
L0001:          DC.B $00,$00,$00
modfadeoutflag: DC.B $00,$00
L0003:          DC.B $00,$00
modMachine:     DC.B $00,$00
L0005:          DC.B $00,'(',$00,$14,$00,$14,$00,$06
                DC.B $00,$06,$00,$01
                DC.B 'ProPlayer V3.2 (c) 1991/92 by NINJA III of NEWline - ST/STE/Falcon030 '
                DC.B $00,$00,$00,$00,$00,$00
                DCB.W 125
L0006:          DCB.W 8320

                ;>PART '-Init computer'
modInitMachine: bsr.s   moddetectmachine
                move.w  modMachine(PC),D7
                move.w  modmachineinitjmptab(PC,D7.w),D7
                jsr     modmachineinitjmptab(PC,D7.w)
                moveq   #0,D0
                move.w  modFreqNumber(PC),D0
                rts
modmachineinitjmptab:
                DC.W modinitSTF-modmachineinitjmptab ;STF/M
                DC.W L00175-modmachineinitjmptab ;STE
                DC.W L00175-modmachineinitjmptab ;MegaSTE
                DC.W L00175-modmachineinitjmptab ;TT
                DC.W L00205-modmachineinitjmptab ;Falcon
                ;ENDPART
                ;>PART '-Detect computer'
moddetectmachine:movem.l D0-A5,-(SP)
                move    SR,-(SP)
                move    #$2700,SR
                moveq   #0,D0           ;0=STF/M
                moveq   #0,D1
                movea.l SP,A1
                movea.l 8.w,A0
                lea     moddetectnomicrowire(PC),A4
                move.l  A4,8.w
                tst.w   $FFFF8922.w     ;microwire data register (STE/Falcon)
                moveq   #2,D0           ;2=STE
moddetectnomicrowire:lea moddetectnocache(PC),A4 ;MegaSTE cache/processor control
                move.l  A4,8.w
                move.b  $FFFF8E21.w,D1
                moveq   #4,D0           ;4=MegaSTE
moddetectnocache:lea    moddetectnoTTpal(PC),A4
                move.l  A4,8.w
                move.w  $FFFF8400.w,D7  ;TT palette registers
                moveq   #6,D0           ;6=TT
moddetectnoTTpal:lea    moddetectnovidel(PC),A4
                move.l  A4,8.w
                move.w  $FFFF9800.w,D7  ;Falcon VIDEL palette registers
                moveq   #8,D0           ;8=Falcon
moddetectnovidel:movea.l A1,SP
                move.l  A0,8.w
                lea     modMachine(PC),A0
                move.w  D0,(A0)
                move    (SP)+,SR
                movem.l (SP)+,D0-A5
                rts
                ;ENDPART
                ;>PART '-Init STF/M (YM output)'
modinitSTF:     lea     modAddress(PC),A6
                move.l  A0,(A6)         ;save start of module's address

                cmpi.w  #3,D1           ;d1>=3 on STF/M is meaningless
                blt.s   modInitSTF2     ;it is used on the other routines
                subq.w  #2,D1
modInitSTF2:    lea     modVolCtrlVal(PC),A6
                move.w  D1,(A6)         ;save volume control state

;    0=STF/M YM2149 7-bit replay with volume control
;    1=STF/M YM2149 8-bit replay with volume control
;    2=STF/M YM2149 8-bit replay without volume control
;    3=(Mega)STE/TT DMA 8-bit with volume control
;    4=(Mega)STE/TT DMA 8-bit without volume control
;    5=Falcon (DMA?) 8-bit with volume control
;    6=Falcon (DMA?) 8-bit without volume control
; if d1 was 0, now it's 0
; if d1 was 1, now it's 1
; if d1 was 2, now it's 2
; if d1 was 3, now it's 3
; if d1 was 4, now it's 2
; if d1 was 5, now it's 3
; if d1 was 6, now it's 4

                lea     modVolCtrlFlag(PC),A6
                st      (A6)            ;assume we don't need volume control
                cmpi.w  #2,D1           ;do we need volume control?
                beq.s   modInitSTF3     ;skip if not
                cmpi.w  #4,D1           ;falcon 8-bit w/o vol. control?
                bne.s   modInitSTF4     ;skip if yes
modInitSTF3:    sf      (A6)            ;signal that we need volume control

modInitSTF4:    andi.w  #7,D2           ;restrain d2 to range 0-7
                cmpi.b  #4,D2           ;mute channel 4?
                beq.s   modInitSTF5     ;if yes, skip
                andi.w  #3,D2           ;if not, restrain d2 to range 0-3
modInitSTF5:    lea     modPitchCtrlVal(PC),A6 ;meaning that we only use 0-4
                move.w  D2,(A6)         ;store mute value

                lea     modSMC(PC),A1   ;let's do some self-modifying code :)
                moveq   #3,D7           ;4 changes to be made
modInitSTF6:    subq.w  #1,D2           ;so what we do here is write some
                bne.s   modInitSTF7     ;branches to that code, except when
                move.w  #$600A,(A1)     ;d2<=0, in which case we insert a nop,
                bra.s   modInitSTF8     ;thus allowing that piece of code to run
modInitSTF7:    move.w  #$4E71,(A1)     ;effectively (un)muting that channel
modInitSTF8:    lea     12(A1),A1       ;point to next instruction to patch
                dbra    D7,modInitSTF6  ;and loop back

                andi.l  #$FFFF,D0       ;mask out crap
                cmp.w   #4000,D0        ;lower than 4 kHz requested?
                bcc.s   modInitSTF9     ;nope
                move.w  #4000,D0        ;yes, make it 4 kHz
modInitSTF9:    cmp.w   #21000,D0       ;higher than 21 kHz requested?
                bls.s   modInitSTFA     ;nope
                move.w  #21000,D0       ;yes, make it 21 kHz
modInitSTFA:    move.l  #614400,D5      ;614.4 kHz (maximum offered by timer D?)
                move.l  #12288,D4       ;12.288 kHz (=$3000)
                divu    D0,D5           ;calc timer divisor
                divu    D5,D4           ;convert it to timer's format?
                lea     modFreqHiByte(PC),A6
                move.w  D5,(A6)         ;store divisor
                move.w  D4,2(A6)        ;store timer divisor
                move.w  D0,-2(A6)       ;store freq number

                bsr     modGenFreqTab
                bsr     modGenAmplTab
                bsr     L0031
                rts
                ;ENDPART
                ;>PART 'Init (Mega)STE/TT (DMA output)'
L00175:         lea     modAddress(PC),A6
                move.l  A0,(A6)
                lea     modVolCtrlVal(PC),A6
                move.w  D1,(A6)
                lea     modVolCtrlFlag(PC),A6
                st      (A6)
                cmpi.w  #2,D1
                beq.s   L0018
                cmpi.w  #4,D1
                bne.s   L0019
L0018:          sf      (A6)
L0019:          lea     $FFFF8922.w,A6
                lea     $FFFF8924.w,A5
                lea     L0020(PC),A4
                lea     L0005(PC),A3
                clr.w   $FFFF8900.w
                move.w  (A4)+,(A5)
                bra.s   L001C
L001A:          add.w   (A3)+,D7
                move.w  D7,(A6)
L001B:          tst.w   (A6)
                bne.s   L001B
L001C:          move.w  (A4)+,D7
                bne.s   L001A
                move.w  modVolCtrlVal(PC),D1
                cmp.w   #3,D1
                bcs     modinitSTF
                lea     L001F(PC),A6
L001D:          tst.w   8(A6)
                beq.s   L001E
                move.w  (A6),D7
                sub.w   8(A6),D7
                lsr.w   #1,D7
                add.w   8(A6),D7
                cmp.w   D0,D7
                bcs.s   L001E
                addq.l  #8,A6
                bra.s   L001D
L001E:          lea     modFreqNumber(PC),A5
                move.w  (A6)+,(A5)
                move.w  (A6)+,$FFFF8920.w
                move.w  (A6)+,2(A5)
                move.w  (A6)+,4(A5)
                bsr     modGenFreqTab
                bsr     modGenAmplTab
                bsr     L0031
                rts
L001F:          DC.B $C3,$92,$00,$03,$00,$0C,$03,$E8
                DC.B 'a',$C9,$00,$02,$00,$18,$01,$F4
                DC.B '0',$E5,$00,$01,$00,'1',$00,$FA
                DC.B $18,'r',$00,$00,$00,'b',$00,'}'
                DC.B $00,$00
L0020:          DC.B $07,$FF,$04,$C0,$05,'@',$05,$00
                DC.B $04,$80,$04,'@',$04,$00,$00,$00
                ;ENDPART
                ;>PART 'Init Falcon (DSP output?)'
L00205:         lea     modAddress(PC),A6
                move.l  A0,(A6)
                cmp.w   #3,D1
                bcc.s   L0021
                moveq   #3,D1
L0021:          cmp.w   #4,D1
                bcs.s   L0022
                moveq   #4,D1
L0022:          lea     modVolCtrlVal(PC),A6
                move.w  D1,(A6)
                lea     modVolCtrlFlag(PC),A6
                st      (A6)
                cmpi.w  #2,D1
                beq.s   L0023
                cmpi.w  #4,D1
                bne.s   L0024
L0023:          sf      (A6)
L0024:          move.w  modVolCtrlVal(PC),D1
                cmp.w   #3,D1
                bcs     modinitSTF
                lea     L0026(PC),A6
L0025:          tst.w   8(A6)
                beq.s   L0027
                move.w  (A6),D7
                sub.w   8(A6),D7
                lsr.w   #1,D7
                add.w   8(A6),D7
                cmp.w   D0,D7
                bcs.s   L0027
                addq.l  #8,A6
                bra.s   L0025
L0026:          DC.B $C0,'0',$00,$01,$00,$0C,$03,$D7
                DC.B $80,' ',$00,$02,$00,$12,$02,$8F
                DC.B '`J',$00,$03,$00,$18,$01,$EC
                DC.B 'L',$F4,$00,$04,$00,$1F,$01,$89
                DC.B '@B',$00,$05,$00,'%',$01,'H'
                DC.B '0>',$00,$07,$00,'1',$00,$F6
                DC.B '&',$AC,$00,$09,$00,'>',$00,$C5
                DC.B ' :',$00,$0B,$00,'J',$00,$A4
                DC.B $00,$00
L0027:          lea     modFreqNumber(PC),A5
                move.w  (A6)+,(A5)
                move.w  (A6)+,6(A5)
                move.w  (A6)+,2(A5)
                move.w  (A6)+,4(A5)
                bsr.s   modGenFreqTab
                bsr.s   modGenAmplTab
                bsr     L0031
                rts
                ;ENDPART
                ;>PART '-Init sub #1:Generate freq tab'
modGenFreqTab:  moveq   #0,D0           ;clear crap
                move.w  modFreqHiByte(PC),D0 ;get frequency divisor
                lea     modFreqTab2(PC),A1 ;load destination buffer adr.
                lea     modFreqTab(PC),A0 ;load freq. table adr.
                move.w  #906,D6         ;907 values to proccess
modGenFreqTab2: move.l  (A0)+,D1        ;get value (32-bit)
                move.l  D1,D2           ;copy it to d1
                swap    D2              ;bring upper 16 bits to lower (for mulu)
                mulu    D0,D1           ;multiply by the freq. requested
                mulu    D0,D2           ;the same for the upper 16 bits
                move.l  D1,D3           ;copy result of lower 16 bits multipl.
                swap    D3              ;swap words
                add.w   D2,D3           ;add result of 16 upper bits
                swap    D3              ;swap words
                lsr.l   #8,D3           ;scale down by 8 bits
                move.l  D3,(A1)+        ;and save it to table
                dbra    D6,modGenFreqTab2 ;repeat
                rts
                ;ENDPART
                ;>PART '-Init sub #2: Gen.data for PSG'
modGenAmplTab:  lea     modAmplValPak(PC),A0 ;contains packed data for each channel
                lea     modAmplValUnpak(PC),A1 ;blank buffer
                move.w  modPitchCtrlVal(PC),D2
                move.w  #319,D3         ;we'll do 320 repeats...
                tst.w   D2              ;except if we don't have pitch control
                beq.s   modGenAmplTab2
                move.w  #$FF,D3         ;in that case, just 256 repeats

modGenAmplTab2: move.w  D3,D7           ;d7=loop counter
                move.w  (A0),D0         ;here we seem to fill the first 256 or
modGenAmplTab3: bsr.s   modGenAmplTab7  ;320 values of the table with silence
                dbra    D7,modGenAmplTab3 ;as the value in (a0) is 0

                moveq   #0,D4           ;clear d4
                move.w  #$FF,D7         ;256 repeats
modGenAmplTab4: move.w  (A0)+,D0        ;get packed word
                bsr.s   modGenAmplTab7  ;break it down into nibbles and store it
                tst.w   D2              ;do we have pitch control?
                bne.s   modGenAmplTab5  ;skip if not
                not.w   D4              ;flag=abs(flag-1)
                beq.s   modGenAmplTab5  ;if flag=0 then skip
                bsr.s   modGenAmplTab7  ;else store word again
modGenAmplTab5: dbra    D7,modGenAmplTab4 ;loop

                move.w  D3,D7           ;256 or 320 repeats
                move.w  -2(A0),D0       ;read the words in reverse order
modGenAmplTab6: bsr.s   modGenAmplTab7  ;store word
                dbra    D7,modGenAmplTab6 ;loop back

                rts

modGenAmplTab7: move.b  #8,(A1)         ;8 - Channel A amplitude control
                move.b  #9,2(A1)        ;9 -   -"-   B    -"-      -"-
                move.b  #10,4(A1)       ;10 -  -"-   C    -"-      -"-
                move.w  D0,D1           ;copy d0,d1
                andi.w  #$0F,D1         ;mask 4 upper bits
****** POSSIBLE BUG HERE - WHY STORE ON 6(A1) AND NOT ON 5(A1)???? ********
                move.b  D1,6(A1)        ;store bits 0-3 of d0 (Channel C)
                move.w  D0,D1           ;recopy d0 to d1
                lsr.w   #4,D1           ;mask 4 lower bits
                andi.w  #$0F,D1         ;(we could avoid this with a lsr.b)
                move.b  D1,3(A1)        ;store bits 4-7 of d0 (Channel B)
                move.w  D0,D1           ;copy d0,d1
                lsr.w   #8,D1           ;mask 8 lower bits
                andi.w  #$0F,D1         ;mask bits 20-31
                move.b  D1,1(A1)        ;store bits 8-11 of d0 (Channel A)
                addq.w  #8,A1           ;point to next slot
                rts
                ;ENDPART
                ;>PART 'Init sub #3:'

L0031:          movea.l modAddress(PC),A0
                lea     modValues(PC),A1 ;first, write standard mod format values
                move.w  #478,0(A1)      ;16*30=480-2 bytes for instrument names
                move.w  #600,2(A1)      ;40*15
                move.w  #15,4(A1)       ;no of instruments
                cmpi.l  #'FLT4',1080(A0) ;detect FLT4 module format
                beq.s   L0032           ;skip this if yes
                cmpi.l  #'M.K.',1080(A0) ;presumably "Mahoney-Kaktus"
                bne.s   L0033           ;skip if not
L0032:          move.w  #952,0(A1)      ;write extended mod format values
                move.w  #1084,2(A1)     ;patterns' size
                move.w  #31,4(A1)       ;no of instruments

L0033:          adda.w  0(A1),A0        ;skip module's instrument names
                moveq   #127,D0         ;128 positions to process
                moveq   #0,D1           ;zero d1 (max used pattern)
L0034:          move.l  D1,D2           ;move d1 to d2
                subq.w  #1,D0           ;one position less
L0035:          move.b  (A0)+,D1        ;get position's pattern
                cmp.b   D2,D1           ;is current pattern bigger than d1?
                bgt.s   L0034           ;loop back if yes
                dbra    D0,L0035        ;no, loop back

                addq.b  #1,D2           ;d2=last pattern used
                swap    D2              ;multiply by...
                lsr.l   #6,D2           ;...1024
                movea.l modAddress(PC),A0 ;reload module's address
                add.l   A0,D2           ;skip pattern data
                movea.l D2,A2           ;*(why not lea (a0,d2.l),a2???)
                lea     20(A0),A0       ;skip module's name
                move.w  4(A1),D7        ;load no. of instruments on d7
                subq.w  #1,D7           ;minus one
                adda.w  2(A1),A2        ;skip instrument names (a2=samp. start)
                movea.l A2,A3           ;copy a2 to a3
                movea.l A2,A4           ;and a4
L0036:          moveq   #0,D0           ;wipe crap
                move.w  22(A0),D0       ;get sample's length in words
                beq.s   L0038           ;skip all these if zero
                cmpi.w  #1,28(A0)       *dunno
                bne.s   L0037           *dunno
                clr.w   28(A0)          *dunno
L0037:          add.l   D0,D0           ;convert sample's length to bytes
                adda.l  D0,A3           ;point to next sample
                adda.l  D0,A4           ;(in a4 too)
                lea     900(A4),A4      ;900 extra bytes for a4 (for loop?)
L0038:          lea     30(A0),A0       ;point to next instrument
                dbra    D7,L0036        ;loop back
;> BUGABOO "? ^a4-^a3"                

 IFNE DEBUG_SHOWPREPARETIMING
 move.w #$700,$ffff8240.w
 ENDC
                move.w  #$FEFE,D4       ;mask bit 0 pattern
                move.w  #$8080,D5       ;change sign pattern
                move.w  modVolCtrlVal(PC),D7 ;do we need volume control?
                bne.s   L003A           ;no, run the other routine
L0039:          move.w  -(A3),D3        ;load sample word
                eor.w   D5,D3           ;change its sign
                and.w   D4,D3           ;mask out bit 0(for volume control,why?)
                move.w  D3,-(A4)        ;save it
                cmpa.l  A2,A3           ;are we done?
                bne.s   L0039           ;not yet
                bra.s   L003B           ;skip next routine

L003A:          move.w  -(A3),D3        ;load sample word
                eor.w   D5,D3           ;change its sign
                move.w  D3,-(A4)        ;save word
                cmpa.l  A2,A3           ;reached samples start?
                bne.s   L003A           ;not yet

L003B:          
 IFNE DEBUG_SHOWPREPARETIMING
 move.w #$70,$ffff8240.w
 ENDC
                movea.l modAddress(PC),A0 ;reload module's address (again?)
                lea     20(A0),A0       ;skip module's name
                lea     L00F1(PC),A5
                move.w  4(A1),D7        ;load no. of instruments in d7
                move.w  D7,D6           ;copy it to d6 too
                subq.w  #1,D7           ;decrease d7 by 1
L003C:          move.l  A4,D4           ;d4=samples' start adr.
                moveq   #0,D3           ;zero d3
                move.w  22(A0),D3       ;get smaple's length in words
                add.l   D3,D3           ;convert it to bytes
                bne.s   L003D           ;skip this if not zero
                clr.l   (A5)            ;it's zero, so mark it down
                clr.l   4(A5)
                clr.l   8(A5)
                clr.l   12(A5)
                bra     L0048           ;and skip the rest
L003D:          moveq   #0,D1
                move.w  28(A0),D1
                beq.s   L003F
                add.l   D1,D1
                moveq   #0,D0
                move.w  26(A0),D0
                cmpi.w  #$0F,D6
                beq.s   L003E
                add.l   D0,D0
L003E:          add.l   D1,D0
                bra.s   L0040
L003F:          move.l  D3,D0
L0040:          move.l  A3,(A5)
                move.l  D0,4(A5)
                clr.b   8(A5)
                move.b  25(A0),9(A5)
                moveq   #0,D1
                move.w  28(A0),D1
                add.l   D1,D1
                move.l  D1,10(A5)
                move.b  24(A0),D2
                andi.w  #$0F,D2
                mulu    #$48,D2
                move.w  D2,14(A5)
                tst.l   D1
                bne.s   L0043
                subq.l  #1,D0
L0041:          move.b  (A4)+,(A3)+
                dbra    D0,L0041
                move.w  #CM_ZUSATZ-1,D2
L0042:          move.b  #$80,(A3)+
                dbra    D2,L0042
                bra.s   L0048
L0043:          moveq   #0,D2
                move.w  26(A0),D2
                cmpi.w  #$0F,D6
                beq.s   L0044
                add.l   D2,D2
L0044:          move.l  A4,D5
                add.l   D2,D5
                add.l   D1,D2
                subq.l  #1,D2
L0045:          move.b  (A4)+,(A3)+
                dbra    D2,L0045
                move.w  #CM_ZUSATZ,D2
L0046:          movea.l D5,A2
                move.w  D1,D3
                subq.w  #1,D3
L0047:          move.b  (A2)+,(A3)+
                subq.w  #1,D2
                beq.s   L0048
                dbra    D3,L0047
                bra.s   L0046
L0048:          movea.l D4,A4
                moveq   #0,D0
                move.w  22(A0),D0
                add.w   D0,D0
                adda.l  D0,A4
                lea     16(A5),A5
                lea     30(A0),A0
                dbra    D7,L003C
 IFNE DEBUG_SHOWPREPARETIMING
 move.w #$07,$ffff8240.w
 ENDC

                lea     cm_voltab(PC),A0    ;load table's address
                lea     L00EE(PC),A2    ;load pointer's address
                lea     L0006(PC),A1    ;load "buffer to store crap" address
                move.l  A1,D0           ;move a1 to d0
                clr.b   D0              ;align it on a 256 byte boundary
                move.l  D0,(A2)         ;save address to pointer
                movea.l D0,A1           ;load it in a1 too
                moveq   #64,D5          ;65 times
L0049:          movem.w (A0)+,D0-D3     ;load 4 words
                move.w  #$FF,D6         ;256 loops
L004A:          move.b  D0,(A1)+        ;store lower 8 bits of d0
                add.w   D3,D1           ;add fractions?
                addx.w  D2,D0           ;and then add with extend?
                dbra    D6,L004A        ;and then loop back
                dbra    D5,L0049        ;and then loop back (echo!)

                movea.l L00EE(PC),A0    ;load previous buffer's address
                move.w  modVolCtrlVal(PC),D7 ;STFM 7-bit with volume control?
                bne.s   L004C           ;skip if not
                move.w  #$207F,D0       ;8320 loops
L004B:          moveq   #0,D1           ;clear d1
                move.b  (A0),D1         ;get byte
                lsl.w   #3,D1           ;multiply by 8
                move.w  D1,(A0)+        *save it as a word (wipes a byte each time)
                dbra    D0,L004B

L004C:          move.w  modVolCtrlVal(PC),D7
                cmpi.w  #3,D7           ;STE or Flacon with volume control?
                blt.s   L004E           ;skip if not
                move.w  #$207F,D0       ;8320 times to loop
L004D:          move.b  (A0),D1         ;get byte
                eori.b  #$80,D1         ;change sign again
                asr.b   #1,D1           ;divide by 2
                move.b  D1,(A0)+        ;save byte back
                move.b  (A0),D1         ;get byte
                eori.b  #$80,D1         ;change sign again
                asr.b   #1,D1           ;divide by 2
                move.b  D1,(A0)+        ;save byte back
                dbra    D0,L004D        ;and loop back

L004E:          move.w  modVolCtrlFlag(PC),D7
                bne.s   L0052
                lea     L00F1(PC),A5
                movea.l L00EE(PC),A4
                lea     modValues(PC),A1
                move.w  4(A1),D7
                subq.w  #1,D7
L004F:          move.l  (A5),D0
                beq.s   L0051
                movea.l D0,A0
                move.l  4(A5),D6
                addi.l  #CM_ZUSATZ,D6
                move.w  8(A5),D4
                lsl.w   #8,D4
L0050:          move.b  (A0),D4
                move.b  0(A4,D4.w),(A0)+
                subq.l  #1,D6
                bne.s   L0050
L0051:          lea     16(A5),A5
                dbra    D7,L004F

L0052:          
 move.w #$0,$ffff8240.w
                lea     modValues(PC),A0 ;load pointer
                move.b  #6,11(A0)       ;assume stanard values
                clr.b   10(A0)
                clr.b   8(A0)
                clr.w   6(A0)
                lea     modSamBufAdr(PC),A2 ;load pointers' address
                lea     modSamBuffers(PC),A3 ;load buffers' address
                move.l  A3,4(A2)        ;1st buffer in 2nd pointer
                lea     4000(A3),A3     ;point to 2nd buffer
                move.l  A3,(A2)         ;and store it into 1st pointer

                lea     CM_OPTIONS(PC),A5    ;load offsets table in a5
                move.w  modVolCtrlVal(PC),D0 ;select replay routine
                lsl.w   #4,D0           ;convert it to offset for table in a5
                lea     0(A5,D0.w),A4   ;get base address for table
                movea.l A5,A0           ;copy a5's address in a0
                adda.w  8(A4),A0        ;add offset for timer D routine
                lea     timerDvector(PC),A2
                move.l  A0,(A2)         ;and save it

                move.w  10(A4),D1       ;load initial buffer value
                move.w  modPitchCtrlVal(PC),D0 ;any muted channels?
                beq.s   L0053           ;skip if no
                mulu    #3,D1           ;if yes, make the initial value
                lsr.w   #2,D1           ;3/4ths of itself
L0053:          lea     modSamBuffers(PC),A3 ;load buffer's address
                move.w  #$03E7,D0       ;1000 repeats
L0054:          move.w  D1,(A3)+        ;store value
                move.w  D1,(A3)+
                move.w  D1,(A3)+
                move.w  D1,(A3)+
                dbra    D0,L0054        ;loop back

                move.w  modFreqTimerVal(PC),D0 * 614400*freq/12288=duplicates no
                movea.l A5,A0           ;load offsets base address to a0
                adda.w  (A4),A0         ;find address of routine to duplicate
                movea.l A0,A2           ;copy it to a2 too
                movea.l A5,A3           ;load offsets base address to a3
                adda.w  2(A4),A3        ;find end of routine
                lea     L00FD(PC),A1    ;save it here
                bsr.s   L0056           ;go duplicate it!

                move.w  modFreqTimerVal(PC),D0
                movea.l A5,A0           ;load offsets base address to a0
                adda.w  4(A4),A0        ;find address of 2nd routine
                movea.l A0,A2           ;copy it to a2 too
                movea.l A5,A3           ;load offsets base address to a3
                adda.w  6(A4),A3        ;find end of routine
                lea     L00FD(PC),A1    ;load same buffer
                lea     17184(A1),A1    ;but skip some bytes
                bsr.s   L0056           ;go duplicate again :)

                lea     L00F3(PC),A0
                lea     L00F0(PC),A2
                move.w  12(A4),(A2)
                lea     L00F2(PC),A3
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #3,D0
L0055:          move.l  A2,(A0)
                move.l  D1,4(A0)
                move.l  A2,8(A0)
                movem.l D1-D4,12(A0)
                clr.w   28(A0)
                lea     30(A0),A0
                movem.l D1-D3,(A3)
                lea     28(A3),A3
                dbra    D0,L0055
                lea     L0000(PC),A0
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)
                lea     L00ED(PC),A0
                clr.w   (A0)
                lea     L0003(PC),A0
                move.w  #$40,(A0)
                lea     modValues(PC),A0
                st      12(A0)
                rts

L0056:          move.w  (A0)+,(A1)+     ;copy code
                cmpa.l  A3,A0           ;reached the end of the routine?
                bne.s   L0056           ;not yet
                movea.l A2,A0           ;reload start of routine in a0
                dbra    D0,L0056        ;and loop back
                move.w  #$4E75,(A1)     ;put a 'rts' at the end
                rts
                ;ENDPART
                ;>PART '-Init Interrupts'
modInitInterrupts:move.w modMachine(PC),D7
                move.w  modInitInterJmpTab(PC,D7.w),D7
                jmp     modInitInterJmpTab(PC,D7.w)
modInitInterJmpTab:
                DC.W modInitInterSTF-modInitInterJmpTab ;STF/M
                DC.W modInitInterSTE-modInitInterJmpTab ;STE
                DC.W modInitInterSTE-modInitInterJmpTab ;MegaSTE
                DC.W modInitInterSTE-modInitInterJmpTab ;TT
                DC.W modInitInterFalc-modInitInterJmpTab ;Falcon
                ;ENDPART
                ;>PART '-Init Interrupts for STF/M'
modInitInterSTF:move    SR,-(SP)
                move    #$2700,SR
                lea     saveFMregs(PC),A0
                move.l  $0110.w,(A0)+   ;save timer D vector
                move.b  $FFFFFA09.w,(A0)+ ;save Interrupt Enable A
                move.b  $FFFFFA15.w,(A0)+ ;save Interrupe Enable b
                move.b  $FFFFFA1D.w,D0  ;save Interrupt Pending B
                andi.b  #$0F,D0         ;lower 4 bits only
                move.b  D0,(A0)+
                move.b  $FFFFFA17.w,(A0)+ ;save Vector register

                lea     $FFFF8800.w,A5  ;time to init the YM
                lea     modinitPSG(PC),A0 ;this dumps some values to the
modInitInterSTF1:tst.b  (A0)            ;chip and resets its voices, etc.
                bmi.s   modInitInterSTF2 ;I've seen this piece of code
                move.b  (A0)+,(A5)      ;in a lot of modplayers
                move.b  (A0)+,2(A5)
                bra.s   modInitInterSTF1

modInitInterSTF2:movea.l modSamBufAdr(PC),A6 ;load 1st buffer address
                andi.b  #$F0,$FFFFFA1D.w ;stop timer D
                ori.b   #1,$FFFFFA1D.w  ;timer D divisor=4
                move.b  modFreqLoByte(PC),$FFFFFA25.w ;load timerD data register
                move.l  timerDvector(PC),$0110.w ;load timer D vector
                moveq   #4,D0
                bset    D0,$FFFFFA09.w  ;enable timer D
                bset    D0,$FFFFFA15.w  ;update the mask too
                bclr    #3,$FFFFFA17.w  ;set automatic end-of-interrupt on
                move    (SP)+,SR
                rts
modinitPSG:     DC.B $0A,$00,$09,$00,$08,$00,$07,$FF
                DC.B $06,$00,$05,$00,$04,$00,$03,$00
                DC.B $02,$00,$01,$00,$00,$00,$FF,$FF
                ;ENDPART
                ;>PART 'Init Inters for (Mega)STE/TT'
modInitInterSTE:move.w  modVolCtrlVal(PC),D1
                cmp.w   #3,D1
                bcs     modInitInterSTF
                move    SR,-(SP)
                move    #$2700,SR
                lea     L00E9(PC),A0
                move.b  $FFFFFA17.w,(A0)
                bclr    #3,$FFFFFA17.w
                move    (SP)+,SR
                rts
                ;ENDPART
                ;>PART 'Init Interrupts for Falcon'
modInitInterFalc:move.w #$80,-(SP)
                trap    #$0E
                addq.l  #2,SP
                move.w  #1,-(SP)
                move.w  #$8C,-(SP)
                trap    #$0E
                addq.l  #4,SP
                move.w  #$10,-(SP)
                clr.w   -(SP)
                move.w  #$82,-(SP)
                trap    #$0E
                addq.l  #6,SP
                move.w  #$10,-(SP)
                move.w  #1,-(SP)
                move.w  #$82,-(SP)
                trap    #$0E
                addq.l  #6,SP
                move.w  #2,-(SP)
                move.w  #4,-(SP)
                move.w  #$82,-(SP)
                trap    #$0E
                addq.l  #6,SP
                move.l  modSamBufAdr(PC),D0
                moveq   #0,D1
                move.w  modFreqTimerVal(PC),D1
                add.l   D1,D0
                add.l   D1,D0
                move.l  D0,-(SP)
                move.l  modSamBufAdr(PC),-(SP)
                clr.w   -(SP)
                move.w  #$83,-(SP)
                trap    #$0E
                lea     12(SP),SP
                clr.w   -(SP)
                move.w  #$84,-(SP)
                trap    #$0E
                addq.l  #4,SP
                clr.w   -(SP)
                clr.w   -(SP)
                move.w  #$85,-(SP)
                trap    #$0E
                addq.l  #6,SP
                clr.w   -(SP)
                move.w  #$85,-(SP)
                trap    #$0E
                addq.l  #4,SP
                move.w  #1,-(SP)
                move.w  L00E7(PC),-(SP)
                clr.w   -(SP)
                move.w  #8,-(SP)
                clr.w   -(SP)
                move.w  #$8B,-(SP)
                trap    #$0E
                lea     12(SP),SP
                move.w  #1,-(SP)
                move.w  #1,-(SP)
                move.w  #$87,-(SP)
                trap    #$0E
                addq.l  #6,SP
                move.w  #3,-(SP)
                move.w  #$88,-(SP)
                trap    #$0E
                addq.l  #4,SP
                move    SR,-(SP)
                move    #$2700,SR
                lea     saveFMregs(PC),A0
                move.l  $013C.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                clr.b   (A0)+
                move.b  $FFFFFA17.w,(A0)+
                lea     modGPI7(PC),A0
                move.l  A0,$013C.w      ;GPI7 interrupt
                moveq   #7,D0
                bset    D0,$FFFFFA07.w
                bset    D0,$FFFFFA13.w
                bclr    #3,$FFFFFA17.w
                move    (SP)+,SR
                rts
                ;ENDPART
                ;>PART 'Stop Module&Restore Interrupts'
modStop:        move    SR,-(SP)
                move    #$2700,SR
                move.w  modMachine(PC),D7
                move.w  L005E(PC,D7.w),D7
                jmp     L005E(PC,D7.w)
L005E:          DC.B $00,$0A,$00,$2E,$00,$2E,$00,$2E
                DC.B $00,$46
                ;ENDPART
                ;>PART 'Restore Interrupts for STF/M'
L005F:          lea     saveFMregs(PC),A0
                move.l  (A0)+,$0110.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA15.w
                andi.b  #$F0,$FFFFFA1D.w
                move.b  (A0)+,D0
                or.b    D0,$FFFFFA1D.w
                move.b  (A0)+,$FFFFFA17.w
                move    (SP)+,SR
                rts
                ;ENDPART
                ;>PART 'Restore Ints for (Mega)STE/TT'
                move.w  modVolCtrlVal(PC),D1
                cmp.w   #3,D1
                bcs.s   L005F
                move.b  L00E9(PC),$FFFFFA17.w
                clr.w   $FFFF8900.w
                move    (SP)+,SR
                rts
                ;ENDPART
                ;>PART 'Restore Interrupts for Falcon'
                lea     saveFMregs(PC),A0
                move.l  (A0)+,$013C.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA13.w
                addq.l  #1,A0
                move.b  (A0)+,$FFFFFA17.w
                move    (SP)+,SR
                move.w  #1,-(SP)
                move.w  #$8C,-(SP)
                trap    #$0E
                addq.l  #4,SP
                move.w  #$81,-(SP)
                trap    #$0E
                addq.l  #2,SP
                rts
                ;ENDPART
                ;>PART '-VBL routine'
modVBL:         move.w  modMachine(PC),D6
                move.w  modVBLJumpTable(PC,D6.w),D6
                jmp     modVBLJumpTable(PC,D6.w)
modVBLJumpTable:
                DC.W L0062-modVBLJumpTable
                DC.W L00621-modVBLJumpTable
                DC.W L00621-modVBLJumpTable
                DC.W L00621-modVBLJumpTable
                DC.W L00622-modVBLJumpTable
                ;ENDPART
                ;>PART '-VBL for STF/M'
L0062:          lea     modSamBufAdr(PC),A0 ;get 1st buffer's addr
                move    SR,D0           ;save status reg
                move    #$2700,SR       ;kill all interrupts
                movea.l 4(A0),A6        ;play the 2nd buffer
                move.l  (A0),4(A0)      ;swap...
                move.l  A6,(A0)         ;...buffers
                move    D0,SR           ;restore status reg
                bra     modplayer
                ;ENDPART
                ;>PART 'VBL for (Mega)STE/TT'
L00621:         move.w  modVolCtrlVal(PC),D0
                cmpi.w  #3,D0
                bcs.s   L0062
                lea     modSamBufAdr(PC),A0
                move    SR,D0
                move    #$2700,SR
                movea.l 4(A0),A6
                move.l  (A0),4(A0)
                move.l  A6,(A0)
                clr.w   $FFFF8900.w
                move    D0,SR
                move.l  A6,D0
                move.l  D0,D1
                moveq   #0,D2
                move.w  modFreqTimerVal(PC),D2
                add.w   D2,D2
                addi.w  #$14,D2
                add.l   D2,D1
                move.b  D0,$FFFF8907.w
                lsr.l   #8,D0
                move.b  D0,$FFFF8905.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8903.w
                move.b  D1,$FFFF8913.w
                lsr.l   #8,D1
                move.b  D1,$FFFF8911.w
                lsr.w   #8,D1
                move.b  D1,$FFFF890F.w
                move.w  #1,$FFFF8900.w
                bra.s   modplayer
                ;ENDPART
                ;>PART 'VBL for Falcon'
L00622:         rts
                ;ENDPART
                ;>PART 'GPI7 routine for Falcon'
modGPI7:        movem.l D0-A6,-(SP)
                move    #$2300,SR
                lea     modSamBufAdr(PC),A0
                movea.l (A0),A6
                move.l  4(A0),(A0)+
                move.l  A6,(A0)
                move.l  A6,D0
                move.l  D0,D1
                moveq   #0,D2
                move.w  modFreqTimerVal(PC),D2
                lsl.l   #1,D2
                add.l   D2,D1
                bclr    #7,$FFFF8901.w
                move.b  D0,$FFFF8907.w
                lsr.l   #8,D0
                move.b  D0,$FFFF8905.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8903.w
                move.b  D1,$FFFF8913.w
                lsr.l   #8,D1
                move.b  D1,$FFFF8911.w
                lsr.w   #8,D1
                move.b  D1,$FFFF890F.w
                bsr.s   modplayer
                movem.l (SP)+,D0-A6
                rte
                ;ENDPART

modplayer:      lea     modfadeoutflag(PC),A1
                move.w  (A1),D0
                beq.s   L0065
                lea     L00ED(PC),A2
                addq.w  #1,(A2)
                move.w  (A2),D0
                cmp.w   (A1),D0
                bne.s   L0065
                clr.w   (A2)
                lea     L0003(PC),A0
                subq.w  #1,(A0)
                bpl.s   L0065
                clr.w   (A0)
L0065:          lea     L0000(PC),A0
                subq.w  #2,(A0)+
                bpl.s   L0066
                clr.w   -2(A0)
L0066:          subq.w  #2,(A0)+
                bpl.s   L0067
                clr.w   -2(A0)
L0067:          subq.w  #2,(A0)+
                bpl.s   L0068
                clr.w   -2(A0)
L0068:          subq.w  #2,(A0)+
                bpl.s   L0069
                clr.w   -2(A0)
L0069:          bsr     L00C0
                lea     modValues(PC),A3
                addq.b  #1,8(A3)
                move.b  8(A3),D0
                cmp.b   11(A3),D0
                blt.s   L006A
                clr.b   8(A3)
                bra.s   L006B
L006A:          lea     L00F3(PC),A2
                lea     L00F2(PC),A4
                bsr     cm_check_command
                lea     30(A2),A2
                lea     28(A4),A4
                bsr     cm_check_command
                lea     30(A2),A2
                lea     28(A4),A4
                bsr     cm_check_command
                lea     30(A2),A2
                lea     28(A4),A4
                bsr     cm_check_command
                rts
L006B:          movea.l modAddress(PC),A0
                movea.l A0,A2
                adda.w  0(A3),A2
                adda.w  2(A3),A0
                moveq   #0,D0
                moveq   #0,D1
                move.b  10(A3),D0
                move.b  0(A2,D0.w),D1
                swap    D1
                lsr.l   #6,D1
                add.w   6(A3),D1
                lea     L00F3(PC),A2
                lea     L00F2(PC),A4
                bsr.s   L006C
                lea     30(A2),A2
                lea     28(A4),A4
                bsr.s   L006C
                lea     30(A2),A2
                lea     28(A4),A4
                bsr.s   L006C
                lea     30(A2),A2
                lea     28(A4),A4
                bsr.s   L006C
                bra     L0075
L006C:          move.l  0(A0,D1.l),(A4)
                addq.l  #4,D1
                moveq   #0,D2
                move.b  2(A4),D2
                and.b   #$F0,D2
                lsr.b   #4,D2
                move.b  (A4),D0
                and.b   #$F0,D0
                or.b    D0,D2
                tst.b   D2
                beq.s   L006D
                cmp.w   4(A3),D2
                bhi     L00B0
                lea     L00F1(PC),A1
                subq.w  #1,D2
                lsl.w   #4,D2
                adda.w  D2,A1
                move.l  (A1)+,D3
                beq     L00B0
                move.l  D3,(A2)
                move.l  D3,8(A2)
                move.l  (A1)+,D4
                move.l  D4,12(A2)
                move.w  (A1)+,24(A2)
                add.l   D4,D3
                move.l  (A1)+,D4
                sub.l   D4,D3
                move.l  D3,16(A2)
                move.l  D4,20(A2)
                move.w  (A1)+,28(A2)
L006D:          move.w  (A4),D0
                and.w   #$0FFF,D0
                beq     L00B0
                move.b  2(A4),D0
                and.w   #$0FF0,D0
                cmp.w   #$0E50,D0
                beq.s   L006E
                move.b  2(A4),D0
                and.b   #$0F,D0
                cmp.b   #3,D0
                beq.s   L006F
                cmp.b   #5,D0
                beq.s   L006F
                cmp.b   #9,D0
                bne.s   L0070
                bsr     L00B0
                bra.s   L0070
L006E:          bsr     L00B3
                bra.s   L0070
L006F:          bsr     cm_set_portamento_tone
                bra     L00B0
L0070:          clr.l   4(A2)
                move.w  (A4),D0
                and.w   #$0FFF,D0
                move.w  28(A2),D3
                beq.s   L0072
                lea     cm_periods(PC),A1
                moveq   #$24,D2
L0071:          cmp.w   (A1)+,D0
                dbcc    D2,L0071
                move.w  -2(A1,D3.w),D0
L0072:          move.w  D0,4(A4)
                move.w  D0,26(A2)
                move.w  2(A4),D0
                and.w   #$0FF0,D0
                cmp.w   #$0ED0,D0
                beq     L00B0
                btst    #2,16(A4)
                bne.s   L0073
                clr.b   11(A4)
L0073:          btst    #6,16(A4)
                bne.s   L0074
                clr.b   15(A4)
L0074:          bra     L00B0
L0075:          addi.w  #$10,6(A3)
                move.b  13(A3),D0
                beq.s   L0076
                move.b  D0,14(A3)
                clr.b   13(A3)
L0076:          tst.b   14(A3)
                beq.s   L0077
                subq.b  #1,14(A3)
                beq.s   L0077
                subi.w  #$10,6(A3)
L0077:          tst.b   16(A3)
                beq.s   L0078
                sf      16(A3)
                moveq   #0,D0
                move.b  15(A3),D0
                clr.b   15(A3)
                lsl.w   #4,D0
                move.w  D0,6(A3)
L0078:          cmpi.w  #$0400,6(A3)
                bcs.s   L007B
L0079:          moveq   #0,D0
                move.b  15(A3),D0
                lsl.w   #4,D0
                move.w  D0,6(A3)
                clr.b   15(A3)
                clr.b   9(A3)
                addq.b  #1,10(A3)
                andi.b  #$7F,10(A3)
                move.b  10(A3),D1
                movea.l modAddress(PC),A1
                adda.w  0(A3),A1
                cmp.b   -2(A1),D1
                bne.s   L007B
                move.b  -1(A1),D1
                cmp.b   -2(A1),D1
                bcc.s   L007A
                move.b  D1,10(A3)
                bra.s   L007B
L007A:          clr.b   10(A3)
L007B:          tst.b   9(A3)
                bne.s   L0079
                lea     L0001(PC),A0
                move.b  10(A3),(A0)+
                move.w  6(A3),D0
                lsr.w   #4,D0
                move.w  D0,(A0)
                lea     L0000(PC),A0
                lea     L00F2(PC),A1
                lea     L00F3(PC),A2
                move.l  #$FFFFF000,D1
                bsr.s   L007C
                bsr.s   L007C
                bsr     L007C
L007C:          move.l  (A1),D2
                and.l   D1,D2
                beq.s   L007D
                move.w  24(A2),D0
                and.w   #$FE,D0
                move.w  D0,(A0)
L007D:          addq.w  #2,A0
                lea     28(A1),A1
                lea     30(A2),A2
                rts
cm_check_command:          
                bsr     cm_updatefunk
                move.w  2(A4),D0
                and.w   #$0FFF,D0
                beq.s   cm_no
                move.b  2(A4),D0
                and.w   #$0F,D0
                add.w   D0,D0
                move.w  cm_cmds(PC,D0.w),D0
                jmp     cm_cmds(PC,D0.w)
cm_no:          rts
;Sprungtabelle fr Kommandos (pc-relativ)
cm_cmds:
                DC.B $00,' ',$00,$82,$00,$B6,$01,$1A
                DC.B $01,$9E,$02,'j',$02,'p',$02,'v'
                DC.B $FF,$FE,$FF,$FE,$02,'6',$FF,$FE
                DC.B $FF,$FE,$FF,$FE,$03,'~',$FF,$FE
cm_arp:                
                moveq   #0,D0
                move.b  8(A3),D0
                divu    #3,D0
                swap    D0
                cmp.w   #0,D0
                beq.s   L0082
                cmp.w   #2,D0
                beq.s   L0081
                moveq   #0,D0
                move.b  3(A4),D0
                lsr.b   #4,D0
                bra.s   L0083
L0081:          moveq   #0,D0
                move.b  3(A4),D0
                and.b   #$0F,D0
                bra.s   L0083
L0082:          move.w  4(A4),D2
                bra.s   L0085
L0083:          add.w   D0,D0
                moveq   #0,D6
                move.w  4(A4),D6
                lea     cm_periods(PC),A1
                adda.w  28(A2),A1
                moveq   #$24,D3
L0084:          cmp.w   (A1)+,D6
                dbcc    D3,L0084
                move.w  -2(A1,D0.w),D2
L0085:          move.w  D2,26(A2)
                rts
cm_fine_prt_up:
                tst.b   8(A3)
                bne.s   cm_return2
                move.b  #$0F,12(A3)
                moveq   #0,D0
                move.b  3(A4),D0
                and.b   12(A3),D0
                move.b  #$FF,12(A3)
                sub.w   D0,4(A4)
                move.w  4(A4),D0
                cmp.w   #$71,D0
                bpl.s   cm_portupskip
                move.w  #$71,D0
cm_portupskip:  move.w  D0,26(A2)
cm_return2:     rts
cm_fine_prt_down:
                tst.b   8(A3)
                bne.s   cm_return2
                move.b  #$0F,12(A3)
cm_prt_down:                
                moveq   #0,D0
                move.b  3(A4),D0
                and.b   12(A3),D0
                move.b  #$FF,12(A3)
                add.w   D0,4(A4)
                move.w  4(A4),D0
                cmp.w   #$0358,D0
                bmi.s   cm_portdwnskip
                move.w  #$0358,D0
cm_portdwnskip: move.w  D0,26(A2)
                rts
cm_set_portamento_tone:
                move.w  (A4),D2
                and.w   #$0FFF,D2
                move.w  28(A2),D3
                beq.s   cm_notune2
                lea     cm_periods(PC),A1
                moveq   #$24,D0
cm_findtune2:   cmp.w   (A1)+,D2
                dbcc    D0,cm_findtune2
                move.w  -2(A1,D3.w),D2
cm_notune2:     move.w  D2,8(A4)
                move.w  4(A4),D0
                clr.b   6(A4)
                cmp.w   D0,D2
                beq.s   L008C
                bge.s   L008D
                move.b  #1,6(A4)
                rts
L008C:          clr.w   8(A4)
L008D:          rts
                move.b  3(A4),D0
                beq.s   L008E
                move.b  D0,7(A4)
                clr.b   3(A4)
L008E:          tst.w   8(A4)
                beq.s   L008D
                moveq   #0,D0
                move.b  7(A4),D0
                tst.b   6(A4)
                bne.s   L008F
                add.w   D0,4(A4)
                move.w  8(A4),D0
                cmp.w   4(A4),D0
                bgt.s   L0090
                move.w  D0,4(A4)
                clr.w   8(A4)
                bra.s   L0090
L008F:          sub.w   D0,4(A4)
                move.w  8(A4),D0
                cmp.w   4(A4),D0
                blt.s   L0090
                move.w  D0,4(A4)
                clr.w   8(A4)
L0090:          move.w  4(A4),D2
                move.b  17(A4),D0
                and.b   #$0F,D0
                beq.s   L0093
                moveq   #0,D0
                move.w  28(A2),D0
                lea     cm_periods(PC),A1
                adda.w  D0,A1
                moveq   #0,D0
L0091:          cmp.w   0(A1,D0.w),D2
                bcc.s   L0092
                addq.w  #2,D0
                cmp.w   #$48,D0
                bcs.s   L0091
                moveq   #$46,D0
L0092:          move.w  0(A1,D0.w),D2
L0093:          move.w  D2,26(A2)
                rts
                move.b  3(A4),D0
                beq.s   L0096
                move.b  10(A4),D2
                and.b   #$0F,D0
                beq.s   L0094
                and.b   #$F0,D2
                or.b    D0,D2
L0094:          move.b  3(A4),D0
                and.b   #$F0,D0
                beq.s   L0095
                and.b   #$0F,D2
                or.b    D0,D2
L0095:          move.b  D2,10(A4)
L0096:          move.b  11(A4),D0
                lea     L00DE(PC),A1
                lsr.w   #2,D0
                and.w   #$1F,D0
                moveq   #0,D2
                move.b  16(A4),D2
                and.b   #3,D2
                beq.s   L0099
                lsl.b   #3,D0
                cmp.b   #1,D2
                beq.s   L0097
                move.b  #$FF,D2
                bra.s   L009A
L0097:          tst.b   11(A4)
                bpl.s   L0098
                move.b  #$FF,D2
                sub.b   D0,D2
                bra.s   L009A
L0098:          move.b  D0,D2
                bra.s   L009A
L0099:          move.b  0(A1,D0.w),D2
L009A:          move.b  10(A4),D0
                and.w   #$0F,D0
                mulu    D0,D2
                lsr.w   #7,D2
                move.w  4(A4),D0
                tst.b   11(A4)
                bmi.s   L009B
                add.w   D2,D0
                bra.s   L009C
L009B:          sub.w   D2,D0
L009C:          move.w  D0,26(A2)
                move.b  10(A4),D0
                lsr.w   #2,D0
                and.w   #$3C,D0
                add.b   D0,11(A4)
                rts
L009D:          moveq   #0,D0
                move.b  3(A4),D0
                lsr.b   #4,D0
                tst.b   D0
                beq.s   L00A0
L009E:          add.w   D0,24(A2)
                cmpi.w  #$40,24(A2)
                ble.s   L009F
                move.w  #$40,24(A2)
L009F:          rts
L00A0:          move.b  3(A4),D0
                and.b   #$0F,D0
L00A1:          sub.w   D0,24(A2)
                bpl.s   L00A2
                clr.w   24(A2)
L00A2:          rts
                bsr     L008E
                bra.s   L009D
                bsr     L0096
                bra.s   L009D
                move.b  3(A4),D0
                beq.s   L00A5
                move.b  14(A4),D2
                and.b   #$0F,D0
                beq.s   L00A3
                and.b   #$F0,D2
                or.b    D0,D2
L00A3:          move.b  3(A4),D0
                and.b   #$F0,D0
                beq.s   L00A4
                and.b   #$0F,D2
                or.b    D0,D2
L00A4:          move.b  D2,14(A4)
L00A5:          move.b  15(A4),D0
                lea     L00DE(PC),A1
                lsr.w   #2,D0
                and.w   #$1F,D0
                moveq   #0,D2
                move.b  16(A4),D2
                lsr.b   #4,D2
                and.b   #3,D2
                beq.s   L00A8
                lsl.b   #3,D0
                cmp.b   #1,D2
                beq.s   L00A6
                move.b  #$FF,D2
                bra.s   L00A9
L00A6:          tst.b   15(A4)
                bpl.s   L00A7
                move.b  #$FF,D2
                sub.b   D0,D2
                bra.s   L00A9
L00A7:          move.b  D0,D2
                bra.s   L00A9
L00A8:          move.b  0(A1,D0.w),D2
L00A9:          move.b  14(A4),D0
                and.w   #$0F,D0
                mulu    D0,D2
                lsr.w   #6,D2
                move.w  24(A2),D0
                tst.b   15(A4)
                bmi.s   L00AA
                add.w   D2,D0
                bra.s   L00AB
L00AA:          sub.w   D2,D0
L00AB:          bpl.s   L00AC
                clr.w   D0
L00AC:          cmp.w   #$40,D0
                bls.s   L00AD
                moveq   #$40,D0
L00AD:          move.w  D0,24(A2)
                move.b  14(A4),D0
                lsr.w   #2,D0
                and.w   #$3C,D0
                add.b   D0,15(A4)
                rts
                moveq   #0,D0
                move.b  3(A4),D0
                beq.s   L00AE
                lsl.w   #7,D0
                move.w  D0,12(A4)
L00AE:          move.w  12(A4),D0
                cmp.l   12(A2),D0
                bge.s   L00AF
                move.l  D0,4(A2)
                rts
L00AF:          move.l  12(A2),4(A2)
                rts
L00B0:          bsr     cm_updatefunk
                move.b  2(A4),D0
                and.b   #$0F,D0
                beq.s   L00B1
                add.w   D0,D0
                lea     L00B2(PC),A1
                adda.w  0(A1,D0.w),A1
                jmp     (A1)
L00B1:          rts
L00B2:          DC.B $FC,$A0,$FC,$A0,$FC,$A0,$FC,$A0
                DC.B $FC,$A0,$FC,$A0,$FC,$A0,$FC,$A0
                DC.B $FC,$A0,$FF,$BE,$FC,$A0,$00,$AA
                DC.B $00,$BE,$00,$D0,$00,' ',$00,$F6
                DC.B $10,',',$00,$03,$C0,'|',$00,$F0
                DC.B $E6,'HC',$FA,$00,$08,$D2,$F1
                DC.B $00,$00,'N',$D1,$00,$C0,$FC,$E4
                DC.B $FD,$18,$00,' ',$00,'4',$00,'`'
                DC.B $01,'\',$00,'H',$FC,'l',$00,$EE
                DC.B $01,$1E,$01,'2',$01,'D',$00,$D6
                DC.B $01,$96,$01,$B2
                move.b  3(A4),D0
                and.b   #$0F,D0
                andi.b  #$F0,17(A4)
                or.b    D0,17(A4)
                rts
                move.b  3(A4),D0
                andi.b  #$0F,D0
                andi.b  #$F0,16(A4)
                or.b    D0,16(A4)
                rts
                illegal
                move.b  3(A4),D0
                andi.b  #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,16(A4)
                or.b    D0,16(A4)
                rts
L00B3:          move.b  3(A4),D0
                andi.w  #$0F,D0
                move.w  D0,D2
                lsl.w   #6,D0
                lsl.w   #3,D2
                add.w   D2,D0
                move.w  D0,28(A2)
                rts
                move.b  3(A4),D0
                subq.b  #1,D0
                move.b  D0,10(A3)
L00B4:          clr.b   15(A3)
                st      9(A3)
                rts
                move.b  3(A4),D0
                cmpi.b  #$40,D0
                bls.s   L00B5
                moveq   #$40,D0
L00B5:          move.b  D0,25(A2)
                rts
                moveq   #0,D0
                move.b  3(A4),D0
                move.w  D0,D2
                lsr.b   #4,D0
                mulu    #$0A,D0
                andi.b  #$0F,D2
                add.b   D2,D0
                cmpi.b  #$3F,D0
                bhi.s   L00B4
                move.b  D0,15(A3)
                st      9(A3)
                rts
                rts
                move.b  3(A4),D0
                andi.b  #$1F,D0
                beq.s   L00B6
                clr.b   8(A3)
                move.b  D0,11(A3)
L00B6:          rts
                move.b  3(A4),D0
                andi.w  #$0F,D0
                cmp.b   8(A3),D0
                bne.s   L00B6
                move.w  (A4),D0
                beq.s   L00B6
                clr.l   4(A2)
                rts
                moveq   #0,D0
                move.b  3(A4),D0
                andi.b  #$0F,D0
                beq.s   L00B8
                moveq   #0,D3
                move.b  8(A3),D3
                bne.s   L00B7
                move.w  (A4),D3
                andi.w  #$0FFF,D3
                bne.s   L00B8
                moveq   #0,D3
                move.b  8(A3),D3
L00B7:          divu    D0,D3
                swap    D3
                tst.w   D3
                bne.s   L00B8
                clr.l   4(A2)
L00B8:          rts
                tst.b   8(A3)
                bne.s   L00B8
                moveq   #0,D0
                move.b  3(A4),D0
                andi.b  #$0F,D0
                bra     L009E
                tst.b   8(A3)
                bne.s   L00B8
                move.b  3(A4),D0
                andi.w  #$0F,D0
                bra     L00A1
                move.b  3(A4),D0
                andi.w  #$0F,D0
                cmp.b   8(A3),D0
                bne.s   L00B8
                clr.w   24(A6)
                clr.w   26(A2)
                rts
                tst.b   8(A3)
                bne.s   L00BC
                move.b  3(A4),D0
                andi.w  #$0F,D0
                beq.s   L00BB
                tst.b   19(A4)
                beq.s   L00BA
                subq.b  #1,19(A4)
                beq.s   L00BC
L00B9:          move.b  18(A4),15(A3)
                st      16(A3)
                rts
L00BA:          move.b  D0,19(A4)
                bra.s   L00B9
L00BB:          move.w  6(A3),D0
                lsr.w   #4,D0
                move.b  D0,18(A4)
                rts
                tst.b   8(A3)
                bne.s   L00BC
                move.b  3(A4),D0
                andi.w  #$0F,D0
                tst.b   14(A3)
                bne.s   L00BC
                addq.b  #1,D0
                move.b  D0,13(A3)
L00BC:          rts
                tst.b   8(A3)
                bne.s   L00BE
                move.b  3(A4),D0
                andi.w  #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,17(A4)
                or.b    D0,17(A4)
                tst.b   D0
                beq.s   L00BE
cm_updatefunk:          moveq   #0,D0
                move.b  17(A4),D0
                lsr.b   #4,D0
                beq.s   L00BE
                lea     L00DD(PC),A1
                move.b  0(A1,D0.w),D0
                add.b   D0,20(A4)
                btst    #7,20(A4)
                beq.s   L00BE
                clr.b   20(A4)
                clr.l   4(A2)
                move.l  16(A2),(A2)
L00BE:          rts
L00BF:          DC.B $00,$00
L00C0:          moveq   #0,D6
                lea     L00BF(PC),A3
                sf      (A3)
                move.w  modVolCtrlVal(PC),D5
                cmp.w   #3,D5
                blt.s   modSMC
                movea.l L00F8(PC),A1
                lea     L00F3(PC),A2
                bsr.s   L00C3
                movea.l L00F8(PC),A1
                lea     L00F6(PC),A2
                bsr.s   L00C3
                sf      (A3)
                movea.l L00F8(PC),A1
                addq.l  #1,A1
                lea     L00F4(PC),A2
                bsr.s   L00C3
                movea.l L00F8(PC),A1
                addq.l  #1,A1
                lea     L00F5(PC),A2
                bsr.s   L00C3
                subq.l  #1,A1
                bra.s   L00C2
modSMC:         nop
                movea.l L00F8(PC),A1
                lea     L00F3(PC),A2
                bsr.s   L00C3
                nop
                movea.l L00F8(PC),A1
                lea     L00F4(PC),A2
                bsr.s   L00C3
                nop
                movea.l L00F8(PC),A1
                lea     L00F5(PC),A2
                bsr.s   L00C3
                nop
                movea.l L00F8(PC),A1
                lea     L00F6(PC),A2
                bsr.s   L00C3
L00C2:          move.w  -2(A1),D0
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                move.w  D0,(A1)+
                rts
L00C3:          move.l  L00EE(PC),D4
                movea.l (A2),A0
                move.l  4(A2),D3
                moveq   #0,D5
                move.w  24(A2),D5
                move.w  L0003(PC),D1
                cmpi.w  #$40,D1
                beq.s   L00C4
                mulu    D1,D5
                lsr.w   #6,D5
L00C4:          lsl.w   #8,D5
                add.l   D5,D4
                move.w  26(A2),D5
                add.w   D5,D5
                add.w   D5,D5
                lea     L00FB(PC),A4
                movem.w 0(A4,D5.w),D0/D2
                moveq   #0,D1
                move.w  modMachine(PC),D5
                cmp.w   #8,D5
                beq.s   L00CD
                tst.b   (A3)
                bne.s   L00C5
                st      (A3)
                lea     L00FD(PC),A4
                jsr     17184(A4)
                bra.s   L00C6
L00C5:          bsr     L00FD
L00C6:          tst.w   22(A2)
                bne.s   L00C8
                cmp.w   14(A2),D3
                bcs.s   L00C7
                move.l  12(A2),D3
                clr.w   26(A2)
L00C7:          move.l  D3,4(A2)
                rts
L00C8:          cmpa.l  16(A2),A0
                beq.s   L00CA
                cmp.w   14(A2),D3
                bcs.s   L00CC
L00C9:          sub.w   14(A2),D3
                cmp.w   14(A2),D3
                bcc.s   L00C9
                move.l  16(A2),(A2)
L00CA:          cmp.w   22(A2),D3
                bcs.s   L00CC
L00CB:          sub.w   22(A2),D3
                cmp.w   22(A2),D3
                bcc.s   L00CB
L00CC:          move.l  D3,4(A2)
                rts
L00CD:          move.w  modVolCtrlVal(PC),D5
                cmp.w   #3,D5
                bne.s   L00CF
                tst.b   (A3)
                bne.s   L00CE
                st      (A3)
                bsr     L00D4
                bra.s   L00C6
L00CE:          bsr     L00D2
                bra.s   L00C6
L00CF:          tst.b   (A3)
                bne.s   L00D0
                st      (A3)
                bsr     L00D8
                bra.s   L00C6
L00D0:          bsr     L00D6
                bra.s   L00C6
;----------------------------- Soundmode-Options (0-4) je 14 Bytes
; vorletztes Word = Pufferfllwert
; letztes Word = Wert fr das Nullsample
;qw Base eine einfache Methode
;                BASE DC.W,CM_OPTIONS
CM_OPTIONS:
; STF/M 7-bit, volume control
                DC.W r11-CM_OPTIONS,r11end-CM_OPTIONS,r12-CM_OPTIONS,r12end-CM_OPTIONS,modFMTimerD7-CM_OPTIONS,$1000,$8080,$00
; STF/M 8-bit, volume control
                DC.W r21-CM_OPTIONS,r21end-CM_OPTIONS,r22-CM_OPTIONS,r22end-CM_OPTIONS,modFMTimerD8-CM_OPTIONS,$0200,$8080,$00
; STF/M 8-bit, no volume control
                DC.W r31-CM_OPTIONS,r31end-CM_OPTIONS,r32-CM_OPTIONS,r32end-CM_OPTIONS,modFMTimerD8-CM_OPTIONS,$0200,$8080,$00
; (Mega)STE/TT
                DC.W r41-CM_OPTIONS,r41end-CM_OPTIONS,r42-CM_OPTIONS,r42end-CM_OPTIONS,-1,$00,$8080,$00
; Falcon
                DC.W r51-CM_OPTIONS,r51end-CM_OPTIONS,r52-CM_OPTIONS,r52end-CM_OPTIONS,-1,$00,$00,$00

;                DC.W $50,$5E,$5E,$6A,modFMTimerD7-L00D1,$1000,$8080,$00
;                DC.W $6A,$78,$78,$86,modFMTimerD8-L00D1,$0200,$8080,$00
;                DC.W $86,$90,$90,$9A,modFMTimerD8-L00D1,$0200,$8080,$00
;                DC.W $9E,$AE,$B8,$C6,$FFFF,$00,$8080,$00
;                DC.W $D0,$DC,$E6,$F0,$FFFF,$00,$00,$00

r11:            move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.w  (A4),D6
                add.w   D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
r11end:
r12:            move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.w  (A4),(A1)+
                add.w   D2,D1
                addx.w  D0,D3
r12end:

r21:            move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),D6
                add.w   D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
r21end:
r22:            move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),D6
                move.w  D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
r22end:

r31:            move.b  0(A0,D3.l),D6
                add.w   D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
r31end:
r32:            move.b  0(A0,D3.l),D6
                move.w  D6,(A1)+
                add.w   D2,D1
                addx.w  D0,D3
r32end:
L00D2:          move.w  modFreqTimerVal(PC),D5
r41:
L00D3:          move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),D6
                add.b   D6,(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
r41end:
                dbra    D5,L00D3
                rts
L00D4:          move.w  modFreqTimerVal(PC),D5
r42:
L00D5:          move.b  0(A0,D3.l),D4
                movea.l D4,A4
                move.b  (A4),(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
r42end:
                dbra    D5,L00D5
                rts
L00D6:          move.w  modFreqTimerVal(PC),D5
r51:
L00D7:          move.b  0(A0,D3.l),D6
                add.b   D6,(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
r51end:
                dbra    D5,L00D7
                rts
L00D8:          move.w  modFreqTimerVal(PC),D5
r52:
L00D9:          move.b  0(A0,D3.l),(A1)
                addq.w  #2,A1
                add.w   D2,D1
                addx.w  D0,D3
r52end:
                dbra    D5,L00D9
                rts

modFMTimerD7:   move.w  (A6)+,D7
                move.l  L00DB(PC,D7.w),(A5)
                move.l  modAmplValUnpak(PC,D7.w),D7
                movep.l D7,0(A5)
                rte

modFMTimerD8:   move.w  (A6)+,D7
                lsl.w   #3,D7
                move.l  L00DB(PC,D7.w),(A5)
                move.l  modAmplValUnpak(PC,D7.w),D7
                movep.l D7,0(A5)
                rte

modAmplValUnpak:DCB.W 2
L00DB:          DCB.W 4094
modAmplValPak:  ;>PART 'Ampliture vals for PSG chans'
                DC.B $00,$00,$02,$00,$02,$10,$03,$10
                DC.B $04,$10,$05,$10,$06,$00,$06,$10
                DC.B $06,'0',$07,$10,$07,' ',$07,'1'
                DC.B $07,'A',$08,$10,$08,' ',$08,'1'
                DC.B $08,'A',$09,$00,$09,$10,$09,'0'
                DC.B $09,'@',$09,'P',$09,'Q',$09,'S'
                DC.B $09,'b',$09,'c',$0A,$10,$0A,'0'
                DC.B $0A,'1',$0A,'P',$0A,'R',$0A,'S'
                DC.B $0A,'b',$0A,'p',$0A,'r',$0B,$10
                DC.B $0B,'0',$0B,'1',$0B,'A',$0B,'Q'
                DC.B $0B,'S',$0B,'b',$0B,'c',$0B,'r'
                DC.B $0B,'t',$0B,$80,$0B,$81,$0B,$83
                DC.B $0B,$84,$0B,$85,$0B,$91,$0B,$93
                DC.B $0B,$94,$0C,' ',$0C,'!',$0C,'A'
                DC.B $0C,'Q',$0C,'S',$0C,'b',$0C,'p'
                DC.B $0C,'r',$0C,'t',$0C,'u',$0C,$82
                DC.B $0C,$84,$0C,$85,$0C,$90,$0C,$92
                DC.B $0C,$94,$0C,$95,$0C,$96,$0C,$97
                DC.B $0C,$97,$0C,$A0,$0C,$A3,$0D,' '
                DC.B $0D,'1',$0D,'P',$0D,'R',$0D,'a'
                DC.B $0D,'p',$0D,'r',$0D,'t',$0D,'u'
                DC.B $0D,$82,$0D,$84,$0D,$90,$0D,$91
                DC.B $0D,$94,$0D,$95,$0D,$96,$0D,$97
                DC.B $0D,$A0,$0D,$A0,$0D,$A3,$0D,$A5
                DC.B $0D,$A6,$0D,$A7,$0D,$A8,$0D,$A8
                DC.B $0D,$A8,$0D,$B1,$0D,$B4,$0D,$B6
                DC.B $0D,$B7,$0D,$B7,$0D,$B8,$0D,$B8
                DC.B $0D,$B9,$0D,$B9,$0D,$B9,$0D,$BA
                DC.B $0D,$BA,$0D,$BA,$0D,$BA,$0D,$BA
                DC.B $0D,$C2,$0D,$C5,$0D,$C6,$0E,$00
                DC.B $0E,'1',$0E,'R',$0E,'b',$0E,'r'
                DC.B $0E,'u',$0E,$81,$0E,$85,$0E,$90
                DC.B $0E,$93,$0E,$96,$0E,$97,$0E,$98
                DC.B $0E,$98,$0E,$A2,$0E,$A6,$0E,$A7
                DC.B $0E,$A8,$0E,$A9,$0E,$A9,$0E,$A9
                DC.B $0E,$B3,$0E,$B7,$0E,$B8,$0E,$B9
                DC.B $0E,$B9,$0E,$BA,$0E,$BA,$0E,$BA
                DC.B $0E,$BA,$0E,$C0,$0E,$C0,$0E,$C0
                DC.B $0E,$C7,$0E,$C7,$0E,$C8,$0E,$C8
                DC.B $0E,$C9,$0E,$CA,$0E,$CA,$0E,$CA
                DC.B $0E,$CA,$0E,$CB,$0E,$CB,$0E,$CB
                DC.B $0E,$D0,$0E,$D0,$0E,$D0,$0E,$D7
                DC.B $0E,$D7,$0E,$D7,$0E,$D9,$0E,$D9
                DC.B $0E,$D9,$0E,$DA,$0E,$DA,$0E,$DA
                DC.B $0E,$DB,$0E,$DB,$0E,$DB,$0F,$00
                DC.B $0F,$00,$0F,$00,$0F,'p',$0F,'p'
                DC.B $0F,$90,$0F,$90,$0F,$90,$0F,$A0
                DC.B $0F,$A0,$0F,$A9,$0F,$B0,$0F,$B0
                DC.B $0F,$B0,$0F,$BA,$0F,$BA,$0F,$C0
                DC.B $0F,$C0,$0F,$C9,$0F,$C9,$0F,$CA
                DC.B $0F,$CA,$0F,$CA,$0F,$CB,$0F,$CB
                DC.B $0F,$CB,$0F,$CC,$0F,$CC,$0F,$CC
                DC.B $0F,$D0,$0F,$D0,$0F,$D0,$0F,$D0
                DC.B $0F,$D0,$0F,$D0,$0F,$D0,$0F,$DB
                DC.B $0F,$DB,$0F,$DB,$0F,$DB,$0F,$DB
                DC.B $0F,$DB,$0F,$DB,$0F,$DC,$0F,$DC
                DC.B $0F,$DC,$0F,$DC,$0F,$DC,$0F,$DC
                DC.B $0F,$DD,$0F,$DD,$0F,$DD,$0F,$DD
                DC.B $0F,$DD,$0F,$DD,$0F,$E0,$0F,$E0
                DC.B $0F,$E0,$0F,$E0,$0F,$E0,$0F,$E0
                DC.B $0F,$E0,$0F,$E0,$0F,$E0,$0F,$EC
                DC.B $0F,$EC,$0F,$EC,$0F,$EC,$0F,$EC
                DC.B $0F,$EC,$0F,$ED,$0F,$ED,$0F,$ED
                DC.B $0F,$ED,$0F,$ED,$0F,$ED,$0F,$ED
                ;ENDPART
L00DD:          ;>PART 'Unknown data (so far)'
                DC.B $00,$05,$06,$07,$08,$0A,$0B,$0D
                DC.B $10,$13,$16,$1A,' +@',$80
                ;ENDPART
L00DE:          ;>PART 'Unknown data (so far)'
                DC.B $00,$18,'1Jax',$8D,$A1
                DC.B $B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
                DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5
                DC.B $B4,$A1,$8D,'xaJ1',$18
                ;ENDPART
cm_voltab:      ;>PART 'Unknown data (so far)'
                DC.B $00,$80,$00,$00,$00,$00,$00,$00,$00,$79,$b0,$cf,$00,$00,$0c,$9f
                DC.B $00,$77,$0b,$ef,$00,$00,$11,$e9,$00,$74,$80,$ee,$00,$00,$16,$ff
                DC.B $00,$71,$f5,$54,$00,$00,$1c,$16,$00,$6f,$af,$96,$00,$00,$20,$a2
                DC.B $00,$6d,$3b,$fb,$00,$00,$25,$89,$00,$6b,$0d,$61,$00,$00,$29,$e6
                DC.B $00,$68,$9d,$d3,$00,$00,$2e,$c5,$00,$66,$6a,$15,$00,$00,$33,$2d
                DC.B $00,$64,$48,$8f,$00,$00,$37,$70,$00,$61,$f9,$99,$00,$00,$3c,$0e
                DC.B $00,$5f,$cc,$46,$00,$00,$40,$68,$00,$5d,$ce,$82,$00,$00,$44,$64
                DC.B $00,$5b,$b1,$39,$00,$00,$48,$9e,$00,$59,$72,$77,$00,$00,$4d,$1c
                DC.B $00,$57,$78,$72,$00,$00,$51,$10,$00,$55,$64,$7a,$00,$00,$55,$38
                DC.B $00,$53,$35,$3d,$00,$00,$59,$96,$00,$51,$61,$45,$00,$00,$5d,$3e
                DC.B $00,$4f,$7a,$34,$00,$00,$61,$0c,$00,$4d,$7f,$43,$00,$00,$65,$02
                DC.B $00,$4b,$6f,$a1,$00,$00,$69,$22,$00,$49,$4a,$77,$00,$00,$6d,$6c
                DC.B $00,$47,$9f,$ef,$00,$00,$70,$c1,$00,$45,$52,$f3,$00,$00,$75,$5b
                DC.B $00,$43,$89,$7e,$00,$00,$78,$ee,$00,$41,$b2,$1a,$00,$00,$7c,$9d
                DC.B $00,$3f,$cc,$5a,$00,$00,$80,$68,$00,$3d,$d7,$d0,$00,$00,$84,$51
                DC.B $00,$3b,$d4,$08,$00,$00,$88,$59,$00,$39,$c0,$8a,$00,$00,$8c,$80
                DC.B $00,$38,$55,$40,$00,$00,$8f,$56,$00,$36,$26,$82,$00,$00,$93,$b4
                DC.B $00,$33,$e6,$c0,$00,$00,$98,$33,$00,$32,$5d,$34,$00,$00,$9b,$46
                DC.B $00,$30,$cb,$b4,$00,$00,$9e,$69,$00,$2e,$62,$33,$00,$00,$a3,$3c
                DC.B $00,$2c,$bc,$1e,$00,$00,$a6,$89,$00,$2b,$0d,$82,$00,$00,$a9,$e6
                DC.B $00,$29,$56,$33,$00,$00,$ad,$54,$00,$27,$96,$04,$00,$00,$b0,$d5
                DC.B $00,$25,$cc,$c7,$00,$00,$b4,$67,$00,$23,$fa,$4e,$00,$00,$b8,$0c
                DC.B $00,$22,$1e,$68,$00,$00,$bb,$c4,$00,$20,$38,$e6,$00,$00,$bf,$8f
                DC.B $00,$1e,$49,$94,$00,$00,$c3,$6e,$00,$1c,$50,$41,$00,$00,$c7,$60
                DC.B $00,$1a,$4c,$b9,$00,$00,$cb,$67,$00,$18,$3e,$c6,$00,$00,$cf,$83
                DC.B $00,$17,$33,$d4,$00,$00,$d1,$99,$00,$15,$15,$dd,$00,$00,$d5,$d5
                DC.B $00,$12,$ec,$f3,$00,$00,$da,$27,$00,$11,$d4,$52,$00,$00,$dc,$58
                DC.B $00,$0f,$9a,$91,$00,$00,$e0,$cc,$00,$0e,$79,$64,$00,$00,$e3,$0e
                DC.B $00,$0c,$2e,$49,$00,$00,$e7,$a4,$00,$0b,$04,$4d,$00,$00,$e9,$f8
                DC.B $00,$08,$a7,$51,$00,$00,$ee,$b2,$00,$07,$74,$42,$00,$00,$f1,$18
                DC.B $00,$05,$04,$da,$00,$00,$f5,$f7,$00,$03,$c8,$70,$00,$00,$f8,$70
                DC.B $00,$01,$46,$0c,$00,$00,$fd,$75,$00,$00,$00,$00,$00,$01,$00,$00
                DC.B $00,$00,$00,$00,$00,$01,$00,$00
                ;ENDPART
cm_periods:     ;>PART 'Finetune periods'
                DC.W 856,808,762,720,678,640,604,570,538,508,480,453
                DC.W 428,404,381,360,339,320,302,285,269,254,240,226
                DC.W 214,202,190,180,170,160,151,143,135,127,120,113
; finetune 1
                DC.W 850,802,757,715,674,637,601,567,535,505,477,450
                DC.W 425,401,379,357,337,318,300,284,268,253,239,225
                DC.W 213,201,189,179,169,159,150,142,134,126,119,113
; finetune 2
                DC.W 844,796,752,709,670,632,597,563,532,502,474,447
                DC.W 422,398,376,355,335,316,298,282,266,251,237,224
                DC.W 211,199,188,177,167,158,149,141,133,125,118,112
; finetune 3
                DC.W 838,791,746,704,665,628,592,559,528,498,470,444
                DC.W 419,395,373,352,332,314,296,280,264,249,235,222
                DC.W 209,198,187,176,166,157,148,140,132,125,118,111
; finetune 4
                DC.W 832,785,741,699,660,623,588,555,524,495,467,441
                DC.W 416,392,370,350,330,312,294,278,262,247,233,220
                DC.W 208,196,185,175,165,156,147,139,131,124,117,110
; finetune 5
                DC.W 826,779,736,694,655,619,584,551,520,491,463,437
                DC.W 413,390,368,347,328,309,292,276,260,245,232,219
                DC.W 206,195,184,174,164,155,146,138,130,123,116,109
; finetune 6
                DC.W 820,774,730,689,651,614,580,547,516,487,460,434
                DC.W 410,387,365,345,325,307,290,274,258,244,230,217
                DC.W 205,193,183,172,163,154,145,137,129,122,115,109
; finetune 7
                DC.W 814,768,725,684,646,610,575,543,513,484,457,431
                DC.W 407,384,363,342,323,305,288,272,256,242,228,216
                DC.W 204,192,181,171,161,152,144,136,128,121,114,108
; finetune -8
                DC.W 907,856,808,762,720,678,640,604,570,538,508,480
                DC.W 453,428,404,381,360,339,320,302,285,269,254,240
                DC.W 226,214,202,190,180,170,160,151,143,135,127,120
; finetune -7
                DC.W 900,850,802,757,715,675,636,601,567,535,505,477
                DC.W 450,425,401,379,357,337,318,300,284,268,253,238
                DC.W 225,212,200,189,179,169,159,150,142,134,126,119
; finetune -6
                DC.W 894,844,796,752,709,670,632,597,563,532,502,474
                DC.W 447,422,398,376,355,335,316,298,282,266,251,237
                DC.W 223,211,199,188,177,167,158,149,141,133,125,118
; finetune -5
                DC.W 887,838,791,746,704,665,628,592,559,528,498,470
                DC.W 444,419,395,373,352,332,314,296,280,264,249,235
                DC.W 222,209,198,187,176,166,157,148,140,132,125,118
; finetune -4
                DC.W 881,832,785,741,699,660,623,588,555,524,494,467
                DC.W 441,416,392,370,350,330,312,294,278,262,247,233
                DC.W 220,208,196,185,175,165,156,147,139,131,123,117
; finetune -3
                DC.W 875,826,779,736,694,655,619,584,551,520,491,463
                DC.W 437,413,390,368,347,328,309,292,276,260,245,232
                DC.W 219,206,195,184,174,164,155,146,138,130,123,116
; finetune -2
                DC.W 868,820,774,730,689,651,614,580,547,516,487,460
                DC.W 434,410,387,365,345,325,307,290,274,258,244,230
                DC.W 217,205,193,183,172,163,154,145,137,129,122,115
; finetune -1
                DC.W 862,814,768,725,684,646,610,575,543,513,484,457
                DC.W 431,407,384,363,342,323,305,288,272,256,242,228
                DC.W 216,203,192,181,171,161,152,144,136,128,121,114
                ;ENDPART
modValues:      DS.W 1          ;total size of instruments' names
                DS.W 1          ;total of patterns
                DS.W 1          ;number of instruments
                DS.W 1
                DS.W 1
                DS.W 1
                DS.W 1
                DS.W 1
                DS.W 1
modAddress:     DC.L 0
;                DCB.W 2
modFreqNumber:  DC.B $00,$00    ;the frequency requested (in Hz)
modFreqHiByte:  DC.B $00
modFreqLoByte:  DC.B $00
modFreqTimerVal:DC.B $00,$00
L00E7:          DCB.W 3
saveFMregs:     DCB.W 3
                DC.B $00
L00E9:          DC.B $00
modVolCtrlVal:  DC.B $00,$00
modVolCtrlFlag: DC.B $00,$00
modPitchCtrlVal:DC.B $00,$00
L00ED:          DC.B $00,$00
L00EE:          DCB.W 2
timerDvector:   DCB.W 2
L00F0:          DC.B $80,$80
L00F1:          DCB.W 248
L00F2:          DCB.W 56
L00F3:          DCB.W 15
L00F4:          DCB.W 15
L00F5:          DCB.W 15
L00F6:          DCB.W 15
modSamBufAdr:   DCB.W 2
L00F8:          DCB.W 2
modSamBuffers:  DCB.W 4000
modFreqTab:     ;>PART 'General sample frequency table'
                DC.B $05,$D3,'zJ',$02,$E9,$BD,'%'
                DC.B $01,$F1,'(',$C3,$01,'t',$DE,$92
                DC.B $01,'*K',$A8,$00,$F8,$94,'a'
                DC.B $00,$D5,$11,'x',$00,$BA,'oI'
                DC.B $00,$A5,$B8,'A',$00,$95,'%',$D4
                DC.B $00,$87,$96,$C0,$00,'|J0'
                DC.B $00,'r',$BA,$A3,$00,'j',$88,$BC
                DC.B $00,'cn',$8D,$00,']7',$A4
                DC.B $00,'W',$BB,$E6,$00,'R',$DC,' '
                DC.B $00,'N',$7F,$B3,$00,'J',$92,$EA
                DC.B $00,'G',$05,$D2,$00,'C',$CB,'`'
                DC.B $00,'@',$D8,$CB,$00,'>%',$18
                DC.B $00,';',$A8,$BB,$00,'9]Q'
                DC.B $00,'7=k',$00,'5D^'
                DC.B $00,'3n%',$00,'1',$B7,'F'
                DC.B $00,'0',$1C,$B8,$00,'.',$9B,$D2
                DC.B $00,'-2@',$00,'+',$DD,$F3
                DC.B $00,'*',$9D,$18,$00,')n',$10
                DC.B $00,'(Oi',$00,$27,'?',$D9
                DC.B $00,'&>6',$00,'%Iu'
                DC.B $00,'$`',$A4,$00,'#',$82,$E9
                DC.B $00,'"',$AF,'~',$00,'!',$E5,$B0
                DC.B $00,'!$',$D9,$00,' le'
                DC.B $00,$1F,$BB,$CB,$00,$1F,$12,$8C
                DC.B $00,$1E,'p5',$00,$1D,$D4,']'
                DC.B $00,$1D,'>',$A2,$00,$1C,$AE,$A8
                DC.B $00,$1C,'$',$1E,$00,$1B,$9E,$B5
                DC.B $00,$1B,$1E,'&',$00,$1A,$A2,'/'
                DC.B $00,$1A,'*',$91,$00,$19,$B7,$12
                DC.B $00,$19,'G',$7F,$00,$18,$DB,$A3
                DC.B $00,$18,'sP',$00,$18,$0E,'\'
                DC.B $00,$17,$AC,$9B,$00,$17,'M',$E9
                DC.B $00,$16,$F2,' ',$00,$16,$99,' '
                DC.B $00,$16,'B',$C7,$00,$15,$EE,$F9
                DC.B $00,$15,$9D,$99,$00,$15,'N',$8C
                DC.B $00,$15,$01,$B8,$00,$14,$B7,$08
                DC.B $00,$14,'nc',$00,$14,$27,$B4
                DC.B $00,$13,$E2,$E9,$00,$13,$9F,$EC
                DC.B $00,$13,'^',$AD,$00,$13,$1F,$1B
                DC.B $00,$12,$E1,'$',$00,$12,$A4,$BA
                DC.B $00,$12,'i',$CE,$00,$12,'0R'
                DC.B $00,$11,$F8,'8',$00,$11,$C1,'t'
                DC.B $00,$11,$8B,$FA,$00,$11,'W',$BF
                DC.B $00,$11,'$',$B7,$00,$10,$F2,$D8
                DC.B $00,$10,$C2,$17,$00,$10,$92,'l'
                DC.B $00,$10,'c',$CE,$00,$10,'62'
                DC.B $00,$10,$09,$92,$00,$0F,$DD,$E5
                DC.B $00,$0F,$B3,'#',$00,$0F,$89,'F'
                DC.B $00,$0F,'`E',$00,$0F,'8',$1A
                DC.B $00,$0F,$10,$C0,$00,$0E,$EA,'.'
                DC.B $00,$0E,$C4,'a',$00,$0E,$9F,'Q'
                DC.B $00,$0E,'z',$F9,$00,$0E,'WT'
                DC.B $00,$0E,'4]',$00,$0E,$12,$0F
                DC.B $00,$0D,$F0,'e',$00,$0D,$CF,'Z'
                DC.B $00,$0D,$AE,$EB,$00,$0D,$8F,$13
                DC.B $00,$0D,'o',$CD,$00,$0D,'Q',$17
                DC.B $00,$0D,'2',$EC,$00,$0D,$15,'H'
                DC.B $00,$0C,$F8,'(',$00,$0C,$DB,$89
                DC.B $00,$0C,$BF,'g',$00,$0C,$A3,$BF
                DC.B $00,$0C,$88,$8E,$00,$0C,'m',$D1
                DC.B $00,$0C,'S',$85,$00,$0C,'9',$A8
                DC.B $00,$0C,' 6',$00,$0C,$07,'.'
                DC.B $00,$0B,$EE,$8B,$00,$0B,$D6,'M'
                DC.B $00,$0B,$BE,'q',$00,$0B,$A6,$F4
                DC.B $00,$0B,$8F,$D4,$00,$0B,'y',$10
                DC.B $00,$0B,'b',$A4,$00,$0B,'L',$90
                DC.B $00,$0B,'6',$D0,$00,$0B,'!c'
                DC.B $00,$0B,$0C,'H',$00,$0A,$F7,'|'
                DC.B $00,$0A,$E2,$FE,$00,$0A,$CE,$CC
                DC.B $00,$0A,$BA,$E4,$00,$0A,$A7,'F'
                DC.B $00,$0A,$93,$EE,$00,$0A,$80,$DC
                DC.B $00,$0A,'n',$0E,$00,$0A,'[',$84
                DC.B $00,$0A,'I:',$00,$0A,'71'
                DC.B $00,$0A,'%g',$00,$0A,$13,$DA
                DC.B $00,$0A,$02,$89,$00,$09,$F1,'t'
                DC.B $00,$09,$E0,$99,$00,$09,$CF,$F6
                DC.B $00,$09,$BF,$8B,$00,$09,$AF,'V'
                DC.B $00,$09,$9F,'X',$00,$09,$8F,$8D
                DC.B $00,$09,$7F,$F6,$00,$09,'p',$92
                DC.B $00,$09,'a_',$00,$09,'R]'
                DC.B $00,$09,'C',$8A,$00,$09,'4',$E7
                DC.B $00,$09,'&q',$00,$09,$18,')'
                DC.B $00,$09,$0A,$0C,$00,$08,$FC,$1C
                DC.B $00,$08,$EE,'V',$00,$08,$E0,$BA
                DC.B $00,$08,$D3,'G',$00,$08,$C5,$FD
                DC.B $00,$08,$B8,$DB,$00,$08,$AB,$DF
                DC.B $00,$08,$9F,$0A,$00,$08,$92,'['
                DC.B $00,$08,$85,$D1,$00,$08,'yl'
                DC.B $00,$08,'m*',$00,$08,'a',$0B
                DC.B $00,$08,'U',$10,$00,$08,'I6'
                DC.B $00,$08,'=~',$00,$08,'1',$E7
                DC.B $00,$08,'&p',$00,$08,$1B,$19
                DC.B $00,$08,$0F,$E1,$00,$08,$04,$C9
                DC.B $00,$07,$F9,$CF,$00,$07,$EE,$F2
                DC.B $00,$07,$E4,'3',$00,$07,$D9,$91
                DC.B $00,$07,$CF,$0C,$00,$07,$C4,$A3
                DC.B $00,$07,$BA,'U',$00,$07,$B0,'"'
                DC.B $00,$07,$A6,$0A,$00,$07,$9C,$0D
                DC.B $00,$07,$92,')',$00,$07,$88,'`'
                DC.B $00,$07,'~',$AF,$00,$07,'u',$17
                DC.B $00,$07,'k',$97,$00,$07,'b0'
                DC.B $00,$07,'X',$E0,$00,$07,'O',$A8
                DC.B $00,$07,'F',$87,$00,$07,'=|'
                DC.B $00,$07,'4',$88,$00,$07,'+',$AA
                DC.B $00,$07,'"',$E1,$00,$07,$1A,'.'
                DC.B $00,$07,$11,$90,$00,$07,$09,$07
                DC.B $00,$07,$00,$92,$00,$06,$F8,'2'
                DC.B $00,$06,$EF,$E6,$00,$06,$E7,$AD
                DC.B $00,$06,$DF,$88,$00,$06,$D7,'u'
                DC.B $00,$06,$CF,'v',$00,$06,$C7,$89
                DC.B $00,$06,$BF,$AF,$00,$06,$B7,$E6
                DC.B $00,$06,$B0,'0',$00,$06,$A8,$8B
                DC.B $00,$06,$A0,$F8,$00,$06,$99,'v'
                DC.B $00,$06,$92,$04,$00,$06,$8A,$A4
                DC.B $00,$06,$83,'T',$00,$06,'|',$14
                DC.B $00,$06,'t',$E4,$00,$06,'m',$C4
                DC.B $00,$06,'f',$B4,$00,$06,'_',$B3
                DC.B $00,$06,'X',$C2,$00,$06,'Q',$DF
                DC.B $00,$06,'K',$0C,$00,$06,'DG'
                DC.B $00,$06,'=',$90,$00,$06,'6',$E8
                DC.B $00,$06,'0N',$00,$06,')',$C2
                DC.B $00,$06,'#D',$00,$06,$1C,$D4
                DC.B $00,$06,$16,'q',$00,$06,$10,$1B
                DC.B $00,$06,$09,$D2,$00,$06,$03,$97
                DC.B $00,$05,$FD,'h',$00,$05,$F7,'E'
                DC.B $00,$05,$F1,'0',$00,$05,$EB,'&'
                DC.B $00,$05,$E5,')',$00,$05,$DF,'8'
                DC.B $00,$05,$D9,'S',$00,$05,$D3,'z'
                DC.B $00,$05,$CD,$AC,$00,$05,$C7,$EA
                DC.B $00,$05,$C2,'3',$00,$05,$BC,$88
                DC.B $00,$05,$B6,$E7,$00,$05,$B1,'R'
                DC.B $00,$05,$AB,$C7,$00,$05,$A6,'H'
                DC.B $00,$05,$A0,$D2,$00,$05,$9B,'h'
                DC.B $00,$05,$96,$07,$00,$05,$90,$B1
                DC.B $00,$05,$8B,'f',$00,$05,$86,'$'
                DC.B $00,$05,$80,$EC,$00,$05,'{',$BE
                DC.B $00,$05,'v',$9A,$00,$05,'q',$7F
                DC.B $00,$05,'ln',$00,$05,'gf'
                DC.B $00,$05,'bg',$00,$05,']r'
                DC.B $00,$05,'X',$86,$00,$05,'S',$A3
                DC.B $00,$05,'N',$C8,$00,$05,'I',$F7
                DC.B $00,$05,'E.',$00,$05,'@n'
                DC.B $00,$05,';',$B6,$00,$05,'7',$07
                DC.B $00,$05,'2`',$00,$05,'-',$C2
                DC.B $00,$05,')+',$00,$05,'$',$9D
                DC.B $00,$05,' ',$17,$00,$05,$1B,$98
                DC.B $00,$05,$17,'"',$00,$05,$12,$B3
                DC.B $00,$05,$0E,'L',$00,$05,$09,$ED
                DC.B $00,$05,$05,$95,$00,$05,$01,'D'
                DC.B $00,$04,$FC,$FB,$00,$04,$F8,$BA
                DC.B $00,$04,$F4,$7F,$00,$04,$F0,'L'
                DC.B $00,$04,$EC,' ',$00,$04,$E7,$FB
                DC.B $00,$04,$E3,$DC,$00,$04,$DF,$C5
                DC.B $00,$04,$DB,$B5,$00,$04,$D7,$AB
                DC.B $00,$04,$D3,$A8,$00,$04,$CF,$AC
                DC.B $00,$04,$CB,$B6,$00,$04,$C7,$C6
                DC.B $00,$04,$C3,$DD,$00,$04,$BF,$FB
                DC.B $00,$04,$BC,$1F,$00,$04,$B8,'I'
                DC.B $00,$04,$B4,'y',$00,$04,$B0,$AF
                DC.B $00,$04,$AC,$EC,$00,$04,$A9,'.'
                DC.B $00,$04,$A5,'w',$00,$04,$A1,$C5
                DC.B $00,$04,$9E,$19,$00,$04,'šs'
                DC.B $00,$04,$96,$D3,$00,$04,$93,'8'
                DC.B $00,$04,$8F,$A3,$00,$04,$8C,$14
                DC.B $00,$04,$88,$8A,$00,$04,$85,$06
                DC.B $00,$04,$81,$87,$00,$04,'~',$0E
                DC.B $00,$04,'z',$99,$00,$04,'w+'
                DC.B $00,$04,'s',$C1,$00,$04,'p]'
                DC.B $00,$04,'l',$FD,$00,$04,'i',$A3
                DC.B $00,$04,'fN',$00,$04,'b',$FE
                DC.B $00,$04,'_',$B3,$00,$04,'\m'
                DC.B $00,$04,'Y,',$00,$04,'U',$EF
                DC.B $00,$04,'R',$B8,$00,$04,'O',$85
                DC.B $00,$04,'LW',$00,$04,'I-'
                DC.B $00,$04,'F',$09,$00,$04,'B',$E8
                DC.B $00,$04,'?',$CD,$00,$04,'<',$B6
                DC.B $00,$04,'9',$A3,$00,$04,'6',$95
                DC.B $00,$04,'3',$8B,$00,$04,'0',$85
                DC.B $00,$04,'-',$84,$00,$04,'*',$88
                DC.B $00,$04,$27,$8F,$00,$04,'$',$9B
                DC.B $00,$04,'!',$AB,$00,$04,$1E,$BF
                DC.B $00,$04,$1B,$D7,$00,$04,$18,$F3
                DC.B $00,$04,$16,$13,$00,$04,$13,'8'
                DC.B $00,$04,$10,'`',$00,$04,$0D,$8C
                DC.B $00,$04,$0A,$BC,$00,$04,$07,$F0
                DC.B $00,$04,$05,'(',$00,$04,$02,'d'
                DC.B $00,$03,$FF,$A4,$00,$03,$FC,$E7
                DC.B $00,$03,$FA,'.',$00,$03,$F7,'y'
                DC.B $00,$03,$F4,$C7,$00,$03,$F2,$19
                DC.B $00,$03,$EF,'o',$00,$03,$EC,$C8
                DC.B $00,$03,$EA,'%',$00,$03,$E7,$86
                DC.B $00,$03,$E4,$EA,$00,$03,$E2,'Q'
                DC.B $00,$03,$DF,$BC,$00,$03,$DD,'*'
                DC.B $00,$03,$DA,$9C,$00,$03,$D8,$11
                DC.B $00,$03,$D5,$89,$00,$03,$D3,$05
                DC.B $00,$03,$D0,$84,$00,$03,$CE,$06
                DC.B $00,$03,$CB,$8C,$00,$03,$C9,$14
                DC.B $00,$03,$C6,$A0,$00,$03,$C4,'0'
                DC.B $00,$03,$C1,$C2,$00,$03,$BF,'W'
                DC.B $00,$03,$BC,$F0,$00,$03,$BA,$8B
                DC.B $00,$03,$B8,'*',$00,$03,$B5,$CB
                DC.B $00,$03,$B3,'p',$00,$03,$B1,$18
                DC.B $00,$03,$AE,$C2,$00,$03,$AC,'p'
                DC.B $00,$03,$AA,' ',$00,$03,$A7,$D4
                DC.B $00,$03,$A5,$8A,$00,$03,$A3,'C'
                DC.B $00,$03,$A0,$FF,$00,$03,$9E,$BE
                DC.B $00,$03,$9C,$7F,$00,$03,'šD'
                DC.B $00,$03,$98,$0B,$00,$03,$95,$D5
                DC.B $00,$03,$93,$A1,$00,$03,$91,'p'
                DC.B $00,$03,$8F,'B',$00,$03,$8D,$17
                DC.B $00,$03,$8A,$EE,$00,$03,$88,$C8
                DC.B $00,$03,$86,$A4,$00,$03,$84,$83
                DC.B $00,$03,$82,'e',$00,$03,$80,'I'
                DC.B $00,$03,'~0',$00,$03,'|',$19
                DC.B $00,$03,'z',$04,$00,$03,'w',$F3
                DC.B $00,$03,'u',$E3,$00,$03,'s',$D6
                DC.B $00,$03,'q',$CC,$00,$03,'o',$C4
                DC.B $00,$03,'m',$BE,$00,$03,'k',$BA
                DC.B $00,$03,'i',$B9,$00,$03,'g',$BB
                DC.B $00,$03,'e',$BE,$00,$03,'c',$C4
                DC.B $00,$03,'a',$CD,$00,$03,'_',$D7
                DC.B $00,$03,']',$E4,$00,$03,'[',$F3
                DC.B $00,$03,'Z',$04,$00,$03,'X',$18
                DC.B $00,$03,'V-',$00,$03,'TE'
                DC.B $00,$03,'R_',$00,$03,'P|'
                DC.B $00,$03,'N',$9A,$00,$03,'L',$BB
                DC.B $00,$03,'J',$DD,$00,$03,'I',$02
                DC.B $00,$03,'G)',$00,$03,'ER'
                DC.B $00,$03,'C}',$00,$03,'A',$AA
                DC.B $00,$03,'?',$D9,$00,$03,'>',$0A
                DC.B $00,$03,'<=',$00,$03,':r'
                DC.B $00,$03,'8',$A9,$00,$03,'6',$E2
                DC.B $00,$03,'5',$1D,$00,$03,'3Z'
                DC.B $00,$03,'1',$99,$00,$03,'/',$D9
                DC.B $00,$03,'.',$1C,$00,$03,',a'
                DC.B $00,$03,'*',$A7,$00,$03,'(',$EF
                DC.B $00,$03,$27,':',$00,$03,'%',$86
                DC.B $00,$03,'#',$D3,$00,$03,'"#'
                DC.B $00,$03,' u',$00,$03,$1E,$C8
                DC.B $00,$03,$1D,$1D,$00,$03,$1B,'t'
                DC.B $00,$03,$19,$CD,$00,$03,$18,$27
                DC.B $00,$03,$16,$83,$00,$03,$14,$E1
                DC.B $00,$03,$13,'A',$00,$03,$11,$A2
                DC.B $00,$03,$10,$05,$00,$03,$0E,'j'
                DC.B $00,$03,$0C,$D0,$00,$03,$0B,'8'
                DC.B $00,$03,$09,$A2,$00,$03,$08,$0D
                DC.B $00,$03,$06,'z',$00,$03,$04,$E9
                DC.B $00,$03,$03,'Y',$00,$03,$01,$CB
                DC.B $00,$03,$00,'>',$00,$02,$FE,$B4
                DC.B $00,$02,$FD,'*',$00,$02,$FB,$A2
                DC.B $00,$02,$FA,$1C,$00,$02,$F8,$98
                DC.B $00,$02,$F7,$15,$00,$02,$F5,$93
                DC.B $00,$02,$F4,$13,$00,$02,$F2,$94
                DC.B $00,$02,$F1,$17,$00,$02,$EF,$9C
                DC.B $00,$02,$EE,'"',$00,$02,$EC,$A9
                DC.B $00,$02,$EB,'2',$00,$02,$E9,$BD
                DC.B $00,$02,$E8,'I',$00,$02,$E6,$D6
                DC.B $00,$02,$E5,'e',$00,$02,$E3,$F5
                DC.B $00,$02,$E2,$86,$00,$02,$E1,$19
                DC.B $00,$02,$DF,$AE,$00,$02,$DE,'D'
                DC.B $00,$02,$DC,$DB,$00,$02,$DB,'s'
                DC.B $00,$02,$DA,$0D,$00,$02,$D8,$A9
                DC.B $00,$02,$D7,'E',$00,$02,$D5,$E3
                DC.B $00,$02,$D4,$83,$00,$02,$D3,'$'
                DC.B $00,$02,$D1,$C6,$00,$02,$D0,'i'
                DC.B $00,$02,$CF,$0E,$00,$02,$CD,$B4
                DC.B $00,$02,$CC,'[',$00,$02,$CB,$03
                DC.B $00,$02,$C9,$AD,$00,$02,$C8,'X'
                DC.B $00,$02,$C7,$05,$00,$02,$C5,$B3
                DC.B $00,$02,$C4,'a',$00,$02,$C3,$12
                DC.B $00,$02,$C1,$C3,$00,$02,$C0,'v'
                DC.B $00,$02,$BF,'*',$00,$02,$BD,$DF
                DC.B $00,$02,$BC,$95,$00,$02,$BB,'M'
                DC.B $00,$02,$BA,$05,$00,$02,$B8,$BF
                DC.B $00,$02,$B7,'z',$00,$02,$B6,'7'
                DC.B $00,$02,$B4,$F4,$00,$02,$B3,$B3
                DC.B $00,$02,$B2,'r',$00,$02,$B1,'3'
                DC.B $00,$02,$AF,$F5,$00,$02,$AE,$B9
                DC.B $00,$02,$AD,'}',$00,$02,$AC,'C'
                DC.B $00,$02,$AB,$09,$00,$02,$A9,$D1
                DC.B $00,$02,$A8,$9A,$00,$02,$A7,'d'
                DC.B $00,$02,$A6,'/',$00,$02,$A4,$FB
                DC.B $00,$02,$A3,$C8,$00,$02,$A2,$97
                DC.B $00,$02,$A1,'f',$00,$02,$A0,'7'
                DC.B $00,$02,$9F,$08,$00,$02,$9D,$DB
                DC.B $00,$02,$9C,$AE,$00,$02,$9B,$83
                DC.B $00,$02,'šY',$00,$02,$99,'0'
                DC.B $00,$02,$98,$08,$00,$02,$96,$E1
                DC.B $00,$02,$95,$BA,$00,$02,$94,$95
                DC.B $00,$02,$93,'q',$00,$02,$92,'N'
                DC.B $00,$02,$91,',',$00,$02,$90,$0B
                DC.B $00,$02,$8E,$EB,$00,$02,$8D,$CC
                DC.B $00,$02,$8C,$AE,$00,$02,$8B,$91
                DC.B $00,$02,$8A,'u',$00,$02,$89,'Y'
                DC.B $00,$02,$88,'?',$00,$02,$87,'&'
                DC.B $00,$02,$86,$0D,$00,$02,$84,$F6
                DC.B $00,$02,$83,$E0,$00,$02,$82,$CA
                DC.B $00,$02,$81,$B6,$00,$02,$80,$A2
                DC.B $00,$02,$7F,$8F,$00,$02,'~}'
                DC.B $00,$02,'}m',$00,$02,'|]'
                DC.B $00,$02,'{N',$00,$02,'z?'
                DC.B $00,$02,'y2',$00,$02,'x&'
                DC.B $00,$02,'w',$1A,$00,$02,'v',$10
                DC.B $00,$02,'u',$06,$00,$02,'s',$FD
                DC.B $00,$02,'r',$F5,$00,$02,'q',$EE
                DC.B $00,$02,'p',$E8,$00,$02,'o',$E2
                DC.B $00,$02,'n',$DE,$00,$02,'m',$DA
                DC.B $00,$02,'l',$D7,$00,$02,'k',$D5
                DC.B $00,$02,'j',$D4,$00,$02,'i',$D4
                DC.B $00,$02,'h',$D4,$00,$02,'g',$D6
                DC.B $00,$02,'f',$D8,$00,$02,'e',$DB
                DC.B $00,$02,'d',$DE,$00,$02,'c',$E3
                DC.B $00,$02,'b',$E8,$00,$02,'a',$EE
                DC.B $00,$02,'`',$F5,$00,$02,'_',$FD
                DC.B $00,$02,'_',$06,$00,$02,'^',$0F
                DC.B $00,$02,']',$19,$00,$02,'\$'
                DC.B $00,$02,'[0',$00,$02,'Z<'
                DC.B $00,$02,'YI',$00,$02,'XW'
                DC.B $00,$02,'Wf',$00,$02,'Vv'
                DC.B $00,$02,'U',$86,$00,$02,'T',$97
                DC.B $00,$02,'S',$A9,$00,$02,'R',$BB
                DC.B $00,$02,'Q',$CE,$00,$02,'P',$E2
                DC.B $00,$02,'O',$F7,$00,$02,'O',$0C
                DC.B $00,$02,'N"',$00,$02,'M9'
                DC.B $00,$02,'LQ',$00,$02,'Ki'
                DC.B $00,$02,'J',$82,$00,$02,'I',$9C
                DC.B $00,$02,'H',$B6,$00,$02,'G',$D1
                DC.B $00,$02,'F',$ED,$00,$02,'F',$0A
                DC.B $00,$02,'E',$27,$00,$02,'DE'
                DC.B $00,$02,'Cc',$00,$02,'B',$83
                DC.B $00,$02,'A',$A3,$00,$02,'@',$C3
                DC.B $00,$02,'?',$E5,$00,$02,'?',$07
                DC.B $00,$02,'>)',$00,$02,'=L'
                DC.B $00,$02,'<p',$00,$02,';',$95
                DC.B $00,$02,':',$BA,$00,$02,'9',$E0
                DC.B $00,$02,'9',$07,$00,$02,'8.'
                DC.B $00,$02,'7V',$00,$02,'6~'
                DC.B $00,$02,'5',$A8,$00,$02,'4',$D1
                DC.B $00,$02,'3',$FC,$00,$02,'3',$27
                DC.B $00,$02,'2S',$00,$02,'1',$7F
                DC.B $00,$02,'0',$AC,$00,$02,'/',$D9
                DC.B $00,$02,'/',$07,$00,$02,'.6'
                DC.B $00,$02,'-f',$00,$02,',',$96
                DC.B $00,$02,'+',$C6,$00,$02,'*',$F7
                DC.B $00,$02,'*)',$00,$02,')\'
                DC.B $00,$02,'(',$8F,$00,$02,$27,$C2
                DC.B $00,$02,'&',$F6,$00,$02,'&+'
                DC.B $00,$02,'%`',$00,$02,'$',$96
                DC.B $00,$02,'#',$CD,$00,$02,'#',$04
                DC.B $00,$02,'"<',$00,$02,'!t'
                DC.B $00,$02,' ',$AD,$00,$02,$1F,$E6
                DC.B $00,$02,$1F,' ',$00,$02,$1E,'['
                DC.B $00,$02,$1D,$96,$00,$02,$1C,$D1
                DC.B $00,$02,$1C,$0D,$00,$02,$1B,'J'
                DC.B $00,$02,$1A,$87,$00,$02,$19,$C5
                DC.B $00,$02,$19,$04,$00,$02,$18,'B'
                DC.B $00,$02,$17,$82,$00,$02,$16,$C2
                DC.B $00,$02,$16,$02,$00,$02,$15,'D'
                DC.B $00,$02,$14,$85,$00,$02,$13,$C7
                DC.B $00,$02,$13,$0A,$00,$02,$12,'M'
                DC.B $00,$02,$11,$91,$00,$02,$10,$D5
                DC.B $00,$02,$10,$1A,$00,$02,$0F,'_'
                DC.B $00,$02,$0E,$A5,$00,$02,$0D,$EB
                DC.B $00,$02,$0D,'2',$00,$02,$0C,'y'
                DC.B $00,$02,$0B,$C1,$00,$02,$0B,$09
                DC.B $00,$02,$0A,'R',$00,$02,$09,$9C
                DC.B $00,$02,$08,$E5,$00,$02,$08,'0'
                DC.B $00,$02,$07,'{',$00,$02,$06,$C6
                DC.B $00,$02,$06,$12,$00,$02,$05,'^'
                DC.B $00,$02,$04,$AB,$00,$02,$03,$F8
                DC.B $00,$02,$03,'F',$00,$02,$02,$94
                DC.B $00,$02,$01,$E3,$00,$02,$01,'2'
                DC.B $00,$02,$00,$81,$00,$01,$FF,$D2
                DC.B $00,$01,$FF,'"',$00,$01,$FE,'s'
                DC.B $00,$01,$FD,$C5,$00,$01,$FD,$17
                DC.B $00,$01,$FC,'i',$00,$01,$FB,$BC
                DC.B $00,$01,$FB,$10,$00,$01,$FA,'c'
                DC.B $00,$01,$F9,$B8,$00,$01,$F9,$0C
                DC.B $00,$01,$F8,'b',$00,$01,$F7,$B7
                DC.B $00,$01,$F7,$0D,$00,$01,$F6,'d'
                DC.B $00,$01,$F5,$BB,$00,$01,$F5,$12
                DC.B $00,$01,$F4,'j',$00,$01,$F3,$C3
                DC.B $00,$01,$F3,$1B,$00,$01,$F2,'u'
                DC.B $00,$01,$F1,$CE,$00,$01,$F1,'('
                DC.B $00,$01,$F0,$83,$00,$01,$EF,$DE
                DC.B $00,$01,$EF,'9',$00,$01,$EE,$95
                DC.B $00,$01,$ED,$F1,$00,$01,$ED,'N'
                DC.B $00,$01,$EC,$AB,$00,$01,$EC,$08
                DC.B $00,$01,$EB,'f',$00,$01,$EA,$C4
                DC.B $00,$01,$EA,'#',$00,$01,$E9,$82
                DC.B $00,$01,$E8,$E2,$00,$01,$E8,'B'
                DC.B $00,$01,$E7,$A2,$00,$01,$E7,$03
                DC.B $00,$01,$E6,'d',$00,$01,$E5,$C6
                DC.B $00,$01,$E5,'(',$00,$01,$E4,$8A
                DC.B $00,$01,$E3,$ED,$00,$01,$E3,'P'
                DC.B $00,$01,$E2,$B4,$00,$01,$E2,$18
                DC.B $00,$01,$E1,'|',$00,$01,$E0,$E1
                DC.B $00,$01,$E0,'F',$00,$01,$DF,$AB
                DC.B $00,$01,$DF,$11,$00,$01,$DE,'x'
                DC.B $00,$01,$DD,$DE,$00,$01,$DD,'E'
                DC.B $00,$01,$DC,$AD,$00,$01,$DC,$15
                DC.B $00,$01,$DB,'}',$00,$01,$DA,$E5
                DC.B $00,$01,$DA,'N',$00,$01,$D9,$B8
                DC.B $00,$01,$D9,'"',$00,$01,$D8,$8C
                DC.B $00,$01,$D7,$F6,$00,$01,$D7,'a'
                DC.B $00,$01,$D6,$CC,$00,$01,$D6,'8'
                DC.B $00,$01,$D5,$A4,$00,$01,$D5,$10
                DC.B $00,$01,$D4,'}',$00,$01,$D3,$EA
                DC.B $00,$01,$D3,'W',$00,$01,$D2,$C5
                DC.B $00,$01,$D2,'3',$00,$01,$D1,$A1
                DC.B $00,$01,$D1,$10,$00,$01,$D0,$7F
                DC.B $00,$01,$CF,$EF,$00,$01,$CF,'_'
                DC.B $00,$01,$CE,$CF,$00,$01,$CE,'?'
                DC.B $00,$01,$CD,$B0,$00,$01,$CD,'"'
                DC.B $00,$01,$CC,$93,$00,$01,$CC,$05
                DC.B $00,$01,$CB,'w',$00,$01,$CA,$EA
                DC.B $00,$01,$CA,']',$00,$01,$C9,$D0
                DC.B $00,$01,$C9,'D',$00,$01,$C8,$B8
                DC.B $00,$01,$C8,',',$00,$01,$C7,$A1
                DC.B $00,$01,$C7,$16,$00,$01,$C6,$8B
                DC.B $00,$01,$C6,$01,$00,$01,$C5,'w'
                DC.B $00,$01,$C4,$ED,$00,$01,$C4,'d'
                DC.B $00,$01,$C3,$DB,$00,$01,$C3,'R'
                DC.B $00,$01,$C2,$C9,$00,$01,$C2,'A'
                DC.B $00,$01,$C1,$BA,$00,$01,$C1,'2'
                DC.B $00,$01,$C0,$AB,$00,$01,$C0,'$'
                DC.B $00,$01,$BF,$9E,$00,$01,$BF,$18
                DC.B $00,$01,$BE,$92,$00,$01,$BE,$0C
                DC.B $00,$01,$BD,$87,$00,$01,$BD,$02
                DC.B $00,$01,$BC,'}',$00,$01,$BB,$F9
                DC.B $00,$01,$BB,'u',$00,$01,$BA,$F1
                DC.B $00,$01,$BA,'n',$00,$01,$B9,$EB
                DC.B $00,$01,$B9,'h',$00,$01,$B8,$E6
                DC.B $00,$01,$B8,'c',$00,$01,$B7,$E2
                DC.B $00,$01,$B7,'`',$00,$01,$B6,$DF
                DC.B $00,$01,$B6,'^',$00,$01,$B5,$DD
                DC.B $00,$01,$B5,']',$00,$01,$B4,$DC
                DC.B $00,$01,$B4,']',$00,$01,$B3,$DD
                DC.B $00,$01,$B3,'^',$00,$01,$B2,$DF
                DC.B $00,$01,$B2,'`',$00,$01,$B1,$E2
                DC.B $00,$01,$B1,'d',$00,$01,$B0,$E6
                DC.B $00,$01,$B0,'i',$00,$01,$AF,$EB
                DC.B $00,$01,$AF,'n',$00,$01,$AE,$F2
                DC.B $00,$01,$AE,'u',$00,$01,$AD,$F9
                DC.B $00,$01,$AD,'}',$00,$01,$AD,$02
                DC.B $00,$01,$AC,$87,$00,$01,$AC,$0C
                DC.B $00,$01,$AB,$91,$00,$01,$AB,$16
                DC.B $00,$01,$AA,$9C,$00,$01,$AA,'"'
                DC.B $00,$01,$A9,$A9,$00,$01,$A9,'/'
                DC.B $00,$01,$A8,$B6,$00,$01,$A8,'>'
                DC.B $00,$01,$A7,$C5,$00,$01,$A7,'M'
                DC.B $00,$01,$A6,$D5,$00,$01,$A6,']'
                DC.B $00,$01,$A5,$E6,$00,$01,$A5,'n'
                DC.B $00,$01,$A4,$F7
                ;ENDPART
L00FB:          DCB.W 2
modFreqTab2:    DCB.W 1814
L00FD:          DCB.W 16110
ZUEND:

;mod:            IBYTES '\MODPLYRS\1.MOD'
;                END
