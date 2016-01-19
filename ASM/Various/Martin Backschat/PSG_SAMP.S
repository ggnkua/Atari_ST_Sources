;*************************************************************************
;*
;* 6 bit PSG-digiplayer ST-COMPUTER 8-9/88 M.Backschat
;*
;* version: 21. MŽR 1995 by J.oppermann@fb1.fhtw-berlin.de
;*
;* (void) F_DIGITAL(d0='frequency',a0=start,a1=end);
;*
;* ATTENTION NEED TO CALL SUPERVISOR-MODE BEFORE !
;* ALL REGISTERS WILL BE CHANGED AFTERWARDS !
;*
;* this one is nice, but a bit tricky !
;* you'll need 8bit samples(not sure if unsigned), d0=30 causes a sampling
;* rate at 20100Hz, but that's just a MFP-timer-delay.
;* the key-ping you shall switch off earlier, and it seems to affect
;* the 1st sample played (I'd be glad if somebody could tell me how to
;* avoid that noise) i've written a .prg that plays that samples using
;* a fileselector(i'm going to put that on ftp :)
;* that quallity is astounishingly 'good', a bit noisy an low, but maybe
;* it would help to 'gain' the values in the table.
;* pitily the routine won't work on a F030 (again i'd be happy to know why)
;* Avalon seems to use a full 8bit table, who likes can 'enhance' the
;* table to 8bit and delete the 6bit mask - line in the code ...
;* but Martin Backschat claimed that this wouldn't not improve much ...
;* who knows ...
;*
;*************************************************************************
 TEXT

F_DIGITAL:
 clr.b   $484              ;key-repeat & -klick off

 movem.l d0/a0/a1,-(sp)    ;save parameter

 pea     PSGTAB            ;digi-preparation-table
 move.w  #$20,-(sp)        ;DOSOUND !
 trap    #14               ;XBIOS
 addq.l  #6,sp

 movem.l (sp)+,d0/a0/a1

F_TIMERINIT:
 move    #$2700,sr         ;no irq's nomore
 lea     DIGIVOL6,a3       ;speakers table-basis-adr
 lea     $FF8800,a5        ;PSG adr

 lea     $FFFA00,a6        ;MFP adr
 move.b  d0,$25(a6)        ;timer start value (2457600\20100 Hz)\4 = 30
 move.b  $1D(a6),d7        ;TIMER-pre-divider
 and.b   #$F0,d7           ; .
 ori.b   #1,d7             ; .
 move.b  d7,$1D(a6)        ; .
 bset    #4,9(a6)          ;timer's able for irq

F_PLAY:
  move.b  (a0)+,d0          ;get a sample-byte
  cmp.l   a0,a1             ;reached last sample ?
  beq.s   F_TIMEROLD        ;the end

  andi.b  #%11111100,d0     ;only 6 bits
  move    d0,d7
  add     d0,d7
  add     d0,d7             ;3 * for digivol-table offset
  movem.l 0(a3,d7),d5-d7    ;get speaker datas
  movem.l d5-d7,(a5)        ;write to PSG

F_SYNC:
  btst    #4,$d(a6)         ;wait for timer D (sync)
  beq.s   F_SYNC
  bclr    #4,$D(a6)         ;set timer again
 bra     F_PLAY            ;carry on ...

F_TIMEROLD:
 move.b  $1D(a6),d7        ;stop timer
 and.b   #$F0,d7
 move.b  d7,$1D(a6)
 bclr    #4,9(a6)
 move    #$2300,sr         ;allow irq's

 rts                       ;back to the caller !!!


PSGTAB:
 dc.b    0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0,7,$3f,8,0,9,0,10,0,$ff,0

DIGIVOL6:
 dc.l  $08000000,$09000000,$0A000000
 dc.l  $08000000,$09000000,$0A000200
 dc.l  $08000000,$09000000,$0A000300
 dc.l  $08000200,$09000200,$0A000200
 dc.l  $08000500,$09000000,$0A000000
 dc.l  $08000500,$09000200,$0A000000
 dc.l  $08000600,$09000100,$0A000000
 dc.l  $08000600,$09000200,$0A000100
 dc.l  $08000700,$09000100,$0A000000
 dc.l  $08000700,$09000200,$0A000000
 dc.l  $08000700,$09000300,$0A000100
 dc.l  $08000800,$09000000,$0A000000
 dc.l  $08000800,$09000200,$0A000000
 dc.l  $08000800,$09000300,$0A000100
 dc.l  $08000800,$09000400,$0A000100
 dc.l  $08000900,$09000000,$0A000000
 dc.l  $08000900,$09000200,$0A000000
 dc.l  $08000900,$09000300,$0A000100
 dc.l  $08000900,$09000400,$0A000100
 dc.l  $08000900,$09000500,$0A000000
 dc.l  $08000900,$09000500,$0A000200
 dc.l  $08000900,$09000600,$0A000000
 dc.l  $08000900,$09000600,$0A000200
 dc.l  $08000A00,$09000200,$0A000000
 dc.l  $08000A00,$09000200,$0A000200
 dc.l  $08000A00,$09000400,$0A000100
 dc.l  $08000A00,$09000500,$0A000000
 dc.l  $08000A00,$09000500,$0A000200
 dc.l  $08000A00,$09000600,$0A000100
 dc.l  $08000A00,$09000600,$0A000300
 dc.l  $08000B00,$09000100,$0A000000
 dc.l  $08000B00,$09000200,$0A000100
 dc.l  $08000B00,$09000300,$0A000100
 dc.l  $08000B00,$09000400,$0A000100
 dc.l  $08000B00,$09000500,$0A000100
 dc.l  $08000B00,$09000600,$0A000000
 dc.l  $08000B00,$09000600,$0A000200
 dc.l  $08000B00,$09000700,$0A000000
 dc.l  $08000B00,$09000700,$0A000100
 dc.l  $08000B00,$09000700,$0A000300
 dc.l  $08000B00,$09000700,$0A000400
 dc.l  $08000B00,$09000800,$0A000100
 dc.l  $08000B00,$09000800,$0A000300
 dc.l  $08000B00,$09000800,$0A000400
 dc.l  $08000B00,$09000800,$0A000500
 dc.l  $08000B00,$09000900,$0A000100
 dc.l  $08000C00,$09000200,$0A000000
 dc.l  $08000C00,$09000200,$0A000200
 dc.l  $08000C00,$09000400,$0A000100
 dc.l  $08000C00,$09000500,$0A000000
 dc.l  $08000C00,$09000500,$0A000300
 dc.l  $08000C00,$09000600,$0A000000
 dc.l  $08000C00,$09000600,$0A000200
 dc.l  $08000C00,$09000700,$0A000000
 dc.l  $08000C00,$09000700,$0A000300
 dc.l  $08000C00,$09000700,$0A000400
 dc.l  $08000C00,$09000800,$0A000000
 dc.l  $08000C00,$09000800,$0A000300
 dc.l  $08000C00,$09000800,$0A000400
 dc.l  $08000C00,$09000800,$0A000500
 dc.l  $08000C00,$09000900,$0A000000
 dc.l  $08000C00,$09000900,$0A000300
 dc.l  $08000C00,$09000900,$0A000400
 dc.l  $08000C00,$09000900,$0A000500

;************************************************************************
