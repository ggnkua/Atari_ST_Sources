        .globl sndoff   ; used by keybd.s
        .globl  SineWave,SineEnd

*       PSG and DMA sound
 
*       May 24,91:   cleared the variable 'cursnd' corrupted by ram test
*       Oct 13, 89:  smooth waveforms, split sampling frequency changes
*               among tests, reduce treble, bass output further.
*       Aug 23, 89:  reduce max output of treble, bass
*       July 29, 89: add dma sound: volume, balance, freq attenuation
*               treble first, sine waves, more vol levels
*       Feb 2, 86       edit for madmac
*       Oct 17, 86      do 1 cycle, don't wait for key
*       Oct 14, 86      print channel being output

* 19JUL92 : RWS : Re-Hacked upon for new SDMA sound stuff. This may
;               mostly go away when my SDMA test is better
;               unfortunately we still need an op to test the speaker.

*       Output sound: sweep thru audible range each 3 channels

*       Frequency to start=(2MHz/16)/1250=100Hz. 1250=$4e2
freqhi  equ     4
freqlo  equ     $e2

        .text

*******************************
*       Output sound
*       Fout=Fclk/16TP where TP is decimal equiv of tone period reg. contents
*       Fclk=2MHz. TP=coarse tune reg. (TP11-TP8) + fine tune reg. (TP7-TP0)

audiotst:
        RTCCLEARPASS #t_AUDIO
        lea     audiom,a5
        bsr     dsptst
        
*--- 1.19
	move.b	#$0e,psgsel
	move.b	psgrd,d0
	bclr	#6,d0
	move.b	d0,psgwr

;;RWS.TPE        bclr.b  #5,SPControl    ; RWS.T turn off berrs FOR REV 3 BOARDS

*audio0:
        bsr     sndoff          ;shut off psg

        move.l  #20000,d0
aud1:   dbra    d0,aud1         ;wait silently

*       set volume and tone and mix
;       move    #@350,d0        ;master volume = max
; RWS/X bsr     voltone
;       move    #lfvol+db0,d0   ;left volume = max 
; RWS/X bsr     voltone
;       move    #rtvol+db0,d0   ;right volume = max
; RWS/X bsr     voltone
;       move    #treble+flat,d0 ;treble = flat
; RWS/X bsr     voltone
;       move    #bass+flat,d0   ;bass = flat
; RWS/X bsr     voltone
;       move    #$1,d0          ;mix = dma + psg
; RWS/X bsr     voltone

*       First channel--start of loop
        moveq   #0,d2           ;d2=0,1,2=>A,B,C

*       Loop here each channel
chans:  bsr     dspchn
        moveq   #freqhi,d7      ;starting freq.
        moveq   #freqlo,d6

        move.w  #$0001,DACRECCTRL
        move.w  #$0111,DATAMXSRC
        move.w  #$6111,DATAMXREC
        move.w  #$0300,AUXACTRL
        move.w  #$0000,AUXBCTRL
        move.w  #$0303,CLOCKSCALE
        move.b  #$8D,psgsel              ; enable speaker
        move.b  #$00,psgwr

*       Loop here each freq.
sweep:  bsr     nxtsound

        move.l  #1000,d3
aud2:   dbra    d3,aud2         ;wait each freq.

        movea.l #tonetb3,a0
        move.b  0(a0,d2),psgsel ;select current amplitude reg.
        move.b  #0,psgwr        ;shut off sound

*       Decrement period of tone
        subq.b  #1,d6   
        bcc.s   sound1
        subq.b  #1,d7
sound1: tst     d7
        bne.s   sweep           ;loop for low byte of freq.

        cmpi.b  #9,d6           ;quit at 125k/8=15 kHz
        bne.s   sweep           ;loop for high byte of freq.
*       -------------

        addq.b  #1,d2           ;next channel
        cmpi.b  #3,d2
        blt     chans           ;do next channel

*-------------------------------
*       Loop complete for 3 channels, do dma sound
*audret:
        bsr     sndoff

        move.w  #$0002,DACRECCTRL
        move.w  #$0111,DATAMXSRC
        move.w  #$0111,DATAMXREC
        move.w  #$0880,AUXBCTRL
        move.w  #$0000,AUXACTRL
        move.w  #$0303,CLOCKSCALE
 ;      move.b  #$D,psgsel              ; enable speaker
;       move.b  #$00,psgwr
*~
;        bsr     dmasnd          ;test dma sound
*~
        bset    #autoky,consol  ;return immed to menu

        RTCSETPASS #t_AUDIO     ; somebody sat through it...
;;RWS.TPE        bset.b  #5,SPControl    ; RWS.T turn berrs back on FOR REV 3 BOARDS

        rts

*-------------------------------
*       Shut off sound
sndoff: move.b  #8,psgsel       ;chan A
        move.b  #0,psgwr
        move.b  #9,psgsel       ;chan B
        move.b  #0,psgwr
        move.b  #10,psgsel      ;chan C
        move.b  #0,psgwr

        rts

*--------------------------------
*       Enable sound, set tone period and amplitude
*       Entry:  d6=fine tune
*               d7=coarse tune
*               d2=channel: 0=A, 1=B, 2=C
*       Uses:   d3,a0,a1,a2
nxtsound:
        lea     psgsel,a1
        lea     psgwr,a2
        move.b  #7,(a1)         ;select mixer
        movea.l #tonetb1,a0
        move.b  0(a0,d2),(a2)   ;enable sound
        movea.l #tonetb2,a0
        move.b  0(a0,d2),d3     ;get register offset
        move.b  d3,(a1)
        move.b  d6,(a2)         ;set fine tune
        addq.b  #1,d3
        move.b  d3,(a1)
        move.b  d7,(a2)         ;set coarse tune
        movea.l #tonetb3,a0
        move.b  0(a0,d2),(a1)
        move.b  #12,(a2)        ;set amplitude
        rts
  
*       same as above but max volumne
nxtsound1:
        lea     psgsel,a1
        lea     psgwr,a2
        move.b  #7,(a1)         ;select mixer
        movea.l #tonetb1,a0
        move.b  0(a0,d2),(a2)   ;enable sound
        movea.l #tonetb2,a0
        move.b  0(a0,d2),d3     ;get register offset
        move.b  d3,(a1)
        move.b  d6,(a2)         ;set fine tune
        addq.b  #1,d3
        move.b  d3,(a1)
        move.b  d7,(a2)         ;set coarse tune
        movea.l #tonetb3,a0
        move.b  0(a0,d2),(a1)
        move.b  #$f,(a2)        ;set amplitude
        rts     

*-------------------------------
*       Display channel
*       d2=channel 0,1,2
dspchn: movem.l d0-d7,-(a7)
        lea     audmsg,a6
        lsl     #2,d2
        move.l  0(a6,d2),a5
        bsr     escjs
        moveq   #0,d0
        moveq   #1,d1
        bsr     move_cursor
        bsr     dspmsg
        bsr     escks
        movem.l (a7)+,d0-d7
        rts
.if 0
*------------------------------
*       Test DMA sound drivers
*       Output waveforms for verification using oscilloscope (also
*       aural verification).

*       29 July 89: use sine waves where possible
*       1. mono 1 kHz at 4 sample rate, 5 volume levels
*       2. stereo 1k/500 Hz at 4 sample rates, 5 volume levels
*       3. mono 50 Hz from -12dB attenuation to +12dB
*       4. mono 12 kHz from -12dB attenuation to +12dB

rtvol   equ     %100000000
lfvol   equ     %101000000
dbn40   equ     0
dbn20   equ     %01010
db0     equ     %10100
treble  equ     %010000000
bass    equ     %001000000
dbn12   equ     0
flat    equ     %0110
dbp12   equ     %1100

dmasnd: move.l  (a7)+,templ     ;save stack pointer
        lea     dsndm,a5
        bsr     dsptst
        moveq   #15,d0
        bsr     disint          ;shut off mono/sound int
*                                (mono int handler does reset)
*       set volume and tone and mix
;       move    #lfvol+db0,d0   ;left volume = max 
; RWS/X bsr     voltone
;       move    #rtvol+db0,d0   ;right volume = max
; RWS/X bsr     voltone
;       move    #treble+flat,d0 ;treble = flat
; RWS/X bsr     voltone
;       move    #bass+flat,d0   ;bass = flat
; RWS/X bsr     voltone
;       move    #$2,d0          ;mix = dma only
; RWS/X bsr     voltone

*       copy sound data to RAM
        lea     m1k3,a0         ;table in ROM
        move.l  #$40000,a1      ;somewhere in RAM
        move    #sdatend-m1k3,d7
sdcopy: move    (a0)+,(a1)+
        dbra    d7,sdcopy

*********************************************************
*       1 kHz tone created by highest sample rate
*       change main volume
*       repeat until keystroke
        clr     d0
        move    #1,d1
        lea     snd4mm,a5
        bsr     dspmsg
snd4m0: clr     volume
snd4m1: move    volume,d1
        lea     mstvol,a0
        move    0(a0,d1),d0
; RWS/X bsr     voltone         ;set volume
snd4m:  lea     sndmono,a1
        move.l  (a1)+,a0        ;sound data
        move.l  (a1)+,d1        ;duration
        move.w  (a1)+,d0        ;mode
        bsr     sound           ;play 
        bne     snderr

        bsr     constat         ;any key?
        tst     d0
        bne.s   snd4md

        add     #2,volume
        cmp     #volinc,volume
        bne.s   snd4m1          ;next volume level
        bra.s   snd4m0          ;start over

snd4md:
        bsr     conin
        cmpi.b  #esc,d0
        beq     sndx

**********************************************************
*       stereo tone created by highest sample rate
*       change right/left channel volume
*       repeat until keystroke
        lea     snd4sm,a5
        bsr     dspmsg
        move    #@350,d0        ;master volume = max
; RWS/X bsr     voltone
snd4s0: clr     volume
snd4s1: move    volume,d1
        lea     vol_lf,a0
        move    0(a0,d1),d0
; RWS/X bsr     voltone         ;set volume left
        lea     vol_rt,a0
        move    0(a0,d1),d0     ;set volume right
; RWS/X bsr     voltone
snd4s:  lea     sndster,a1
        move.l  (a1)+,a0        ;sound data
        move.l  (a1)+,d1        ;duration
        move.w  (a1)+,d0        ;mode
        bsr     sound           ;play 
        bne     snderr

        bsr     constat         ;any key?
        tst     d0
        bne.s   snd4sd

        add     #2,volume
        cmp     #volinc,volume
        bne.s   snd4s1          ;next volume level
        bra.s   snd4s0          ;start over

snd4sd:
        bsr     conin
        cmpi.b  #esc,d0
        beq     sndx
        
******************************************
*       12 kHz at varied volume

        lea     trebm,a5
        bsr     dspmsg
        clr     volume
;       move    #@350,d0        ;master volume = max
; RWS/X bsr     voltone
;       move    #lfvol+db0,d0   ;left volume = max 
; RWS/X bsr     voltone
;       move    #rtvol+db0,d0   ;right volume = max
; RWS/X bsr     voltone

snd12k: lea     tontrb,a0
        move    volume,d1
        move    0(a0,d1),d0
        add     #treble,d0
; RWS/X bsr     voltone         ;set volume
        lea     sndtrb,a1
        move.l  (a1)+,a0        
        move.l  (a1)+,d1        ;duration
        move    (a1)+,d0        ;mode
        bsr     sound

        bsr     constat
        tst     d0
        bne.s   snd12x

        add     #2,volume
        cmp     #tonend,volume
        bne     snd12k
        clr     volume
        bra.s   snd12k

snd12x: bsr     conin
        cmpi.b  #esc,d0
        beq     sndx

*****************************************
*       50 Hz at varied volume
*       uses four sampling rates
        lea     bassm,a5
        bsr     dspmsg
        clr     volume
        clr     cursnd

*       loop for volume and sample rate
snd50:  lea     tonbas,a0
        move    volume,d1
        move    0(a0,d1),d0     ;get attenuation
        add     #bass,d0
; RWS/X bsr     voltone         ;set tone level

        move    cursnd,d3
        mulu    #10,d3          ;# bytes in table
        lea     sndbas,a1
        move.l  0(a1,d3),a0
        move.l  4(a1,d3),d1
        move.w  8(a1,d3),d0
        bsr     sound           ;output sound

        add     #1,cursnd
        cmp     #2,cursnd
        bne.s   snd50
        clr     cursnd
        add     #2,volume
        cmp     #tonend,volume
        bne.s   snd50k0
        clr     volume
snd50k0:
        bsr     constat
        tst     d0
        beq.s   snd50

        bsr     conin
.endif
********************************
*       all done
sndx:     lea     donemsg,a5
          moveq     #66,d0
          moveq     #0,d1
;RWS.T    bra       dsppos
        bsr     dsppos

wtm_sgx: move    #300,d1         ;very brief delay so all msg readable
wtm_sg0x:                        ;300*2.5ms=1/2 sec plus
        bsr     wait
        dbra    d1,wtm_sg0x

;       move    #@300,d0        ;master volume = min
; RWS/X bsr     voltone
        moveq   #15,d0          ;re-enable mono/sound int
        bsr     enabint

        RTCSETPASS #t_AUDIO     ; somebody sat through it...
;;RWS.TPE        bset.b  #5,SPControl    ; RWS.T turn berrs back on FOR REV 3 BOARDS

        move.l  templ,-(a7)     ;restore caller return address
        rts                     ;return to caller

;snderr: lea     snderm,a5
 ;       bsr     dspmsg
  ;      bra.s   sndx

**************
* generate red/green noise for pass/fail tests
*
*
***
gensnd: bsr     chkred
        bne.s   gensnd1         ;don't bra if red
        bsr     redsound        ;pulsate red sound        
        rts
gensnd1:
        bsr     grnsound        ;single pulse green sound
        rts

grnsound:
        bsr     yespeak         ;speaker on
;       move    #%011101000,d0  ;master volume = max
; RWS/X bsr     voltone
;       move    #lfvol+db0,d0   ;left volume = max 
; RWS/X bsr     voltone
;       move    #rtvol+db0,d0   ;right volume = max
; RWS/X bsr     voltone
;        move    #treble+flat,d0 ;treble = flat
;       ; RWS/X bsr     voltone
;        move    #bass+flat,d0   ;bass = flat
;       ; RWS/X bsr     voltone
;       move    #$1,d0          ;mix = dma + psg
; RWS/X bsr     voltone

        moveq   #0,d2           ;d2=0,1,2=>A,B,C
        moveq   #freqhi,d7      ;starting freq.
        moveq   #freqlo,d6
 
        bsr     nxtsound1        ;start sound

grnsnd: move    #100,d1         ;very brief delay
grsnd:  bsr     wait            ;200*2.5ms=1/2 sec.
        dbra    d1,grsnd
        bsr     nospeak         ;turn off speaker
        rts
***
***
redsound:
;        bsr     yespeak
        moveq   #0,d2           ;start channel A
swep0:  moveq   #freqhi,d7      ;starting freq.
        moveq   #freqlo,d6

;       move    #%011101000,d0  ;master volume = max
; RWS/X bsr     voltone
;       move    #lfvol+db0,d0   ;left volume = max 
; RWS/X bsr     voltone
;       move    #rtvol+db0,d0   ;right volume = max
; RWS/X bsr     voltone
;       move    #$1,d0          ;mix = dma + psg
; RWS/X bsr     voltone

swep:   bsr     nxtsound1

        move.l  #100,d3
ad2:    dbra    d3,ad2          ;wait each freq.

        movea.l #tonetb3,a0
        move.b  0(a0,d2),psgsel ;select current amplitude reg.
        move.b  #0,psgwr        ;shut off sound

*       Decrement period of tone
        subq.b  #1,d6   
        bcc.s   soond1
        subq.b  #1,d7
soond1: tst     d7
        bne.s   swep            ;loop for low byte of freq.

        cmpi.b  #9,d6           ;quit at 125k/8=15 kHz
        bne.s   swep            ;loop for high byte of freq.

        addq.b  #1,d2           ;next channel
        cmpi.b  #3,d2
        blt     swep0           ;do next pulse

        bsr     nospeak
        rts

nospeak:
        move.l  d1,-(sp)
        move.b  #giporta,psgsel ; select port on GI chip
        move.b  psgrd,d1        ; get current bits
        bclr    #7,d1           ; or-in our new bit
        move.b  d1,psgwr        ; and write 'em back out there
        move.l  (sp)+,d1
;        bsr     sndoff         ;sorry, external speaker in mega's
        rts
yespeak:
        move.l  d1,-(sp)
        move.b  #giporta,psgsel ; select port on GI chip
        move.b  psgrd,d1        ; get current bits
        or.b    #$80,d1         ; or-in our new bit
        move.b  d1,psgwr        ; and write 'em back out there
        move.l  (sp)+,d1
        rts

.if 0
************************************
* DMA sound test code by Allan Pratt

*************************************************************************
*
* mwwrite: write a value to the MicroWire bitstream.  This will wait
* forever for the data to shift out; you'd better be sure that the
* MicroWire interface works.
*
* 18FEB92 : RWS : Changed to work with SDMA rev A or B. 
* 19JUL92 : RWS : removed all semblance of real code.

* ARGUMENTS: value to write in D0  

* REGISTERS: Vol/Tone chip address (10) is added to d0
* all other registers preserved

mwmask          equ     $ffff8924
mwdata          equ     $ffff8922

MWMASK          equ     $7ff            ; 11 bits

mwwrite:
;       move.w  #MWMASK,mwmask          ; write mask register
;       move.w  d0,mwdata               ; write data register
;       
;.loop1:
;       cmp.w   #MWMASK,mwmask          ; wait for mask to start shifting
;       beq     .loop1
;.loop2: cmp.w   #MWMASK,mwmask          ; wait for mask to read as written
;       bne     .loop2
        rts

************************************************************************
*
* voltone: write a 9-bit command to the volume/tone controller.
* Uses mwwrite, above.
*
* ARGUMENTS: D0=value to write.
* All registers preserved.
* 

* 19JUL92 : RWS : hacked out for now.

voltone::
;       or.w    #%0000010000000000,d0
        bra     mwwrite                         ; let mwwrite's RTS return.

************************************************************************
*
* sound: causes something to come out of the DMA sound.  See notes above.
*
* ARGUMENTS:    A0.L -> data to play (first long of the data is its length)
*               D0.B =  DMA sound mode (incl stereo/mono bit)
*               D1.L =  number of cycles to play
*
* USES: all registers, plus Timer B and Timer A.
*
* RETURNS: Zero in D0.l for success, or the number of cycles which
* WEREN'T played by the time five seconds have gone by.
* This routine ALWAYS returns after at most five seconds.
*
* ASSUMES: MFP works, but interrupts need not work.  No interrupts
* are used.  (The interrupts are enabled but masked, and the "pending"
* bits are polled to simulate interrupts.)
*
* Also assumes that A0 is word-aligned, and that (A0) is even (that is,
* mono sounds must have an even number of samples).  Assumes further
* that the sound chip actually exists, i.e. won't cause a bus error.
*
* Leaves Timer A totally disabled before returning.
*

SND     = $ffff8900

sound::
        movem.l d0-d7/a0-a6,-(sp)
        lea.l   SND,a5
        move.w  #0,(a5)         ; zap the sound so it's quiet
        move.w  d0,$20(a5)      ; set the mode register (rate + mono/stereo)
        move.l  (a0)+,d3        ; length of sound in bytes
        move.l  a0,d2           ; start addr of sound data
        add.l   d2,d3           ; d3 = end addr of sound

; disable timers A and B; disable, mask, then enable timer A & B interrupts.

        lea     mfp,a0
        move.b  #$10,tacr(a0)   ; reset & disable Timer A
        move.b  #$10,tbcr(a0)   ; reset & disable Timer B

        and.b   #%11011110,iera(a0)     ; clear Timer A & Timer B enable bits
        and.b   #%11011110,imra(a0)     ; clear mask bits (0=masked)
        move.b  #%11011110,ipra(a0)     ; clear "pending" bits to be sure
        or.b    #%00100001,iera(a0)     ; set enable bits (1=enabled)
        and.b   #%11101111,aer(a0)      ; set active-edge to 0 (falling)


; set up Timer A in event count mode,
; and set up d6 as the lesser of d1 and 256.  When Timer A fires,
; d6 is subtracted from d1, and if the result is zero we're done.
; If not zero, the lesser of d6 and d1 is put in d6 and Timer A,
; and the cycle repeats.

        move.b  #8,tacr(a0)     ; program Timer A in event-count mode.

; subtract one from number of cycles because the last thing we do
; is start one last trip through the sound data before returning.
        subq.l  #1,d1

; program Timer A for min(256,ncycles)
        move.l  #$100,d6
        cmp.l   d6,d1
        bpl.s   .settimera      ; leave $100 in d6 if d1 > $100
        move.l  d1,d6           ; else put d1 in d6 so d1-d6 = 0.
.settimera:
        move.b  d6,tadr+mfp

; start the sound!

        movep.l d3,$d(a5)       ; set end addr before start addr
        asl.l   #8,d2           ; shift d2 left so movep is right
        movep.l d2,$3(a5)       ; set start addr
        move.w  #3,(a5)         ; start 'er up!

; program Timer B for five seconds. Its raw clock rate is 2.4576MHz,
; so if we use /200 and program the timer to time out every 256 ticks,
; we need to see 240 timeouts for five seconds.

        move.b  #0,tbdr+mfp     ; timer B data reg: 0 means 256.
        move.w  #240,d7         ; d7 is timeout countdown
        move.b  #7,tbcr+mfp             ; start Timer B at /200

;
; this is the main loop.
;
; while (1) {
;       if (Timer A int pending) {
;               kill the pending bit;
;               d1 -= d6
;               if (d1 == 0) {
;                       /* we're done; clean up & return */
;                       stop TA;
;                       set HW play mode to 1, to play one last time;
;                       place a zero in d0 for successful return;
;                       return;
;               else {
;                       d6 = min(d6,d1);
;                       stop TA;
;                       tadr = d6;
;                       start TA;
;               }
;       }
;       if (Timer B int pending) {
;               kill the pending bit
;               d7 -= 1;
;               if (d7 == 0) {
;                       /* time out; clean up & return */
;                       stop Timer A, read out its value, add to d1,
;                               place the result in d0 for failed return;
;                       set HW play mode to 0, to stop now;
;                       return;
;       }
; }

loop:
        btst.b  #5,ipra+mfp     ; Timer A pending?
        beq.s   .notimera       ; nope.
        move.b  #%11011111,ipra+mfp     ; yup: kill the pending bit
        sub.l   d6,d1           ; d1 -= d6
        bne.s   .notzero        ; if (d1 != 0) goto notzero

* Timer A just fired and d1 is zero, meaning we're done!
        move.b  #0,tacr+mfp             ; stop timer A
        move.b  #0,tbcr+mfp     ; stop timer B
        move.w  #1,SND          ; set HW to play once more
        moveq.l #0,d0           ; zero d0: successful finish.
        bra     sndrtn

* Timer A fired, but it's not the last time.
.notzero:
        cmp.l   d6,d1           ; (d6 is $100; is that > d1?)
        bpl.s   .used6          ; yes, so use d6
        move.l  d1,d6           ; no, so use d1 (that way d1-d6=0)
.used6: move.b  #0,tacr+mfp             ; stop before reloading counter
        move.b  d6,tadr+mfp     ; reload counter
        move.b  #8,tacr+mfp             ; start (in event-count mode)
* fall through to .notimera

.notimera:
        btst.b  #0,ipra+mfp             ; Timer B pending?
        beq     loop            ; no, just loop
        move.b  #%11111110,ipra+mfp     ; yes, kill the pending bit
        subq.l  #1,d7           ; decrement timeout loop counter
        bne     loop            ; if (d7 != 0) go back and loop

* Timer B fired for the last time -- this is a timeout condition.
        move.b  #0,tacr+mfp             ; stop timer A
        move.b  tadr,d6         ; get its counter value (hi 3 bytes d6=0)
        move.w  #0,SND          ; stop the sound
        move.b  #0,tbcr+mfp     ; stop timer B

* set d0 = (d1 - (256-d6)) which is how many times the sound DIDN'T play.

        move.l  #$100,d0
        sub.l   d6,d0
        sub.l   d0,d1
        move.l  d1,d0
sndrtn: movem.l (sp)+,d0-d7/a0-a6
        rts
.endif
        .data
        .even

*       table of sound data,duration,mode
*       monoaural
*       this table should point to RAM (40000)
sndmono:
        dc.l    m1k3-m1k3+$40000,800
        dc.w    $83

*       stereo
sndster:
;        dc.l    s1k5_3-m1k3+$40000,800
 ;       dc.w    $2

*       treble
sndtrb:
;	dc.l    hz12k-m1k3+$40000,3000
 ;       dc.w    $83

*       bass at 2 sampling rates
sndbas:
;        dc.l    hz50_0-m1k3+$40000,10
 ;       dc.w    $80
  ;      dc.l    hz50_1-m1k3+$40000,10
   ;     dc.w    $81

*
*       sound data
*       the first longword is the number of bytes to follow
*       the following bytes consitute the waveform
*       +127 is max amplitude, -128 is min amplitude
*       e.g. 127,-128,127,-128 is a square wave of highest possible
*       frequency for a given sample rate.

*
* Rate          Result (pitch & time per cycle)
*  0            ~1KHz, 1/1000 sec
*  1            ~2KHz, 1/2000 sec
*  2            ~4KHz, 1/4000 sec
*  3            ~8KHz, 1/8000 sec

m1k3::  dc.l    48
SineWave:       dc.b    0,17,33,49,64,77,90,101,110,116,123,126
        dc.b    127,126,123,116,110,101,90,77,64,49,33,17
        dc.b    0,-17,-33,-49,-64,-77,-90,-100,-110,-116,-123,-126
        dc.b    -127,-126,-123,-117,-110,-101,-90,-77,-64,-49,-33,-17
SineEnd:
*       stereo 1k/500 Hz @ mode 2 sampling      
;s1k5_3:: dc.l   96
 ;       dc.b    0,0,16,33,33,63,49,90,63,110,77,123
  ;      dc.b    90,127,101,123,110,110,117,90,123,63,125,33
   ;     dc.b    127,0,126,-33,124,-63,117,-90,110,-110,101,-123
    ;    dc.b    90,-128,77,-123,63,-110,49,-90,33,-63,16,-33
     ;   dc.b    0,0,-16,33,-33,63,-49,90,-63,110,-77,123
      ;  dc.b    -90,127,-101,123,-110,110,-117,90,-123,63,-125,33
       ; dc.b    -128,0,-126,-33,-124,-63,-119,-90,-111,-110,-100,-123
       ; dc.b    -90,-128,-77,-123,-63,-110,-52,-90,-33,-63,-16,-33

*       12 kHz square wave in mode 3
;hz12k:  dc.l    8
 ;       dcb.b   2,127
  ;      dcb.b   2,-128
   ;     dcb.b   2,127
    ;    dcb.b   2,-128

*       50 Hz sine wave in mode 0
;hz50_0: dc.l    120
 ;       dc.b    0,7,13,20,26,33,39,45,52,58
  ;      dc.b    63,69,75,80,85,90,94,99,103,107
   ;     dc.b    110,113,116,118,121,123,124,125,126,126
    ;    dc.b    127,127,126,125,124,123,121,118,116,113
     ;   dc.b    110,107,103,99,94,90,85,80,75,69
      ;  dc.b    63,58,52,45,39,33,26,20,13,7
       ; dc.b    0,-7,-13,-20,-26,-33,-39,-45,-52,-58
;        dc.b    -63,-69,-75,-80,-85,-90,-94,-99,-103,-107
 ;       dc.b    -110,-113,-116,-118,-121,-123,-125,-126,-127,-127
  ;      dc.b    -128,-128,-127,-126,-125,-124,-123,-121,-118,-116
   ;     dc.b    -110,-107,-103,-99,-94,-90,-85,-80,-75,-69
    ;    dc.b    -63,-58,-52,-45,-39,-33,-26,-20,-13,-7

*       50 Hz sine wave in mode 1
;hz50_1: dc.l    240
 ;       dc.b    0,3,7,10,13,17,20,23,26,30
  ;      dc.b    33,36,39,42,45,48,52,55,58,61
   ;     dc.b    63,65,69,72,75,77,80,83,85,88
    ;    dc.b    90,92,94,96,99,101,103,104,107,109
     ;   dc.b    110,112,113,114,116,117,118,119,120,121
      ;  dc.b    122,122,123,123,124,124,125,125,126,126
       ; dc.b    127,127,126,126,125,125,124,124,123,123
;        dc.b    121,120,119,118,117,116,114,113,112,111
 ;       dc.b    110,109,107,104,103,101,99,96,94,92
  ;      dc.b    90,88,85,83,80,77,75,72,69,65
   ;     dc.b    63,61,58,55,52,48,45,42,39,36
    ;    dc.b    33,30,26,23,20,17,13,10,7,3
     ;   dc.b    0,-3,-7,-10,-13,-17,-20,-23,-26,-30
      ;  dc.b    -33,-36,-39,-42,-45,-48,-52,-55,-58,-61
       ; dc.b    -63,-65,-69,-72,-75,-77,-80,-83,-85,-88
;        dc.b    -90,-92,-94,-96,-99,-101,-103,-104,-107,-109
 ;       dc.b    -110,-112,-113,-114,-116,-117,-118,-119,-120,-121
  ;      dc.b    -122,-122,-123,-123,-124,-124,-125,-125,-126,-126
   ;     dc.b    -127,-127,-126,-126,-125,-125,-124,-124,-123,-123
    ;    dc.b    -121,-120,-119,-118,-117,-116,-114,-113,-112,-111
     ;   dc.b    -110,-109,-107,-104,-103,-101,-99,-96,-94,-92
      ;  dc.b    -90,-88,-85,-83,-80,-77,-75,-72,-69,-65
       ; dc.b    -63,-61,-58,-55,-52,-48,-45,-42,-39,-36
        ;dc.b    -33,-30,-26,-23,-20,-17,-13,-10,-7,-3

sdatend equ     *

        .even
*       Tone, noise enable are active low
*                A   B   C
tonetb1: dc.b   $fe,$fd,$fb     ;enable/mixer register values
tonetb2: dc.b   0,2,4           ;tone period register offsets
tonetb3: dc.b   8,9,10          ;amplitude register offsets

;mstvol: dc.w    @300,@320,@330,@340,@344,@350,@350,@350 ;low to high
;vol_lf: dc.w    @500,@510,@512,@514,@520,@524,@524,@524 ;low to high
;vol_rt: dc.w    @424,@424,@424,@420,@414,@412,@410,@400 ;high to low
;volinc  equ     *-vol_rt

;tontrb: dc.w    7,7,7,7,6,5,4,3,2,1
;tonbas: dc.w    6,6,6,6,6,5,4,3,2,1
;tonend  equ     *-tonbas

audiom: dc.b    'Listen for low to high sweep:',cr,lf,eot
audmsg: dc.l    chn1,chn2,chn3
chn1:   dc.b    'Channel A',eot
chn2:   dc.b    'Channel B',eot
chn3:   dc.b    'Channel C',eot

        
;dsndm:  dc.b  'Testing DMA sound. Check waveforms with oscilloscope.',cr,lf,eot
;snderm: dc.b    'DMA sound timed-out',cr,lf,eot
;snd4mm: dc.b    cr,lf,'Mono 1 kHz tone',cr,lf,eot
;snd4sm: dc.b    'Stereo 1 kHz/500 Hz tones',cr,lf,eot
;trebm:  dc.b    'Treble attenuation',cr,lf,eot
;bassm:  dc.b    'Bass attenuation',cr,lf,eot
donemsg: dc.b  'DONE!',eot

