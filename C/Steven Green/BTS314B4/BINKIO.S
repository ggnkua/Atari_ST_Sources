; History of DRIVER.S (BINKLEY.IO)        (Please set tab=2!)
;
; Following versions (c) St.Slabihoud
;
; 0.9x - beta testversions
; 1.00 - first official driver (only for ST)
; 1.01 - some improvements
; 1.02 - more functions implemented
; 1.03 - TT and STE support
; 1.04 - Falcon support? Hope it works...
; 1.05 - Reading/Writing from/to SCCs with a little bus delay (nop)
; 1.06 - Fast-Sendbyte-Routines (by Uwe Zerbe) removed
; 1.07 - No Bcostat() in SENDBYTE/SENDCHARS any more
; 1.08 - Faster code
; 1.09 - Longer delay
; 1.09a- Fast IO-Driver (Fwrite 2)
; 1.10 - IO-Driver
; 1.11 - Interrups disabled

          MC68000
          SUPER
            
MFPPORT1  EQU    0x00fffa01
MFPPORT2  EQU    0x00fffa81
SCCA_CNT  EQU    0xFFFF8C81
SCCB_CNT  EQU    0xFFFF8C85

;  This code is called once to get the address of the jumptable.
; It is also allowed to print a small intro.

; Do not forget to save register A2 - PureC needs it!

start:        movem.l  d1-d7/a1-a6,-(sp)
              pea      init(pc)
              move.w  #9,-(sp)
              trap    #1
              addq.w  #6,sp
              pea      get_hardware(pc)
              move.w  #38,-(sp)
              trap    #14
              addq.w  #6,sp
              tst.w    d0
              bne.s    no_st
              pea      _st(pc)
              bra.s    jump
no_st:        subq.w  #1,d0
              bne.s    no_ste
              pea      _ste(pc)
              bra.s    jump
no_ste:        subq.w  #1,d0
              bne.s    no_tt
              pea      _tt(pc)
              bra.s    jump
no_tt:        subq.w  #1,d0
              bne.s    no_falcon
              pea      _falc(pc)
              bra.s    jump
no_falcon:    pea      _unkn(pc)
jump:          move.w  #9,-(sp)
              trap    #1
              addq.w  #6,sp
              pea      _end(pc)
              move.w  #9,-(sp)
              trap    #1
              addq.w  #6,sp
              movem.l  (sp)+,d1-d7/a1-a6
              lea      tabelle(pc),a0
              move.l  a0,d0
              rts

get_hardware:  move.l  $5a0.w,a0
              move.l  a0,d0        * No Cookie-Jar found -> ST
              beq.s    ende
loop:          cmp.l    #'_MCH',(a0)
              bne.s    not_found
              move.l  4(a0),d0
              bra.s    ende
not_found:    addq.w  #8,a0
              move.l  -8(a0),d0
              bne.s    loop
              moveq    #0,d0
ende:          swap    d0
              lea      HARDWARE(pc),a0
              move.w  d0,(a0)
              rts
            
; Jumptable: Some functions are called in the SupervisorMode!

;  0 - get dcd status (<>0 : carrier detected)
;  4 - get cts status (<>0 : cts detected)
;  8 - send a byte to seriel port (d0.w : character)
; 12 - send chars to seriel port (a0.l : address, d0.l : number of bytes,
;                                  d1.w : CD check)
; 16 - set defaultport, only called if TOS support Bconmap (d0.w : Port n)
; 20 - read a character from seriel port
; 24 - characters available from seriel port?
; 28 - possible to send a character?
; 32 - peek a byte from seriel buffer (do not read it)
; 36 - turn DTR on
; 40 - turn DTR off
; 44 - Nothing to send?

tabelle:
          bra.w    get_dcd        *  0      Called in supervisor
          bra.w    get_cts        *  4         "    "      "
          bra.w    sendbyte      *  8
          bra.w    sendchars      * 12
          bra.w    set_new_port  * 16
          bra.w    modemin        *  20
          bra.w    charavail      * 24
          bra.w    outfull        * 28
          bra.w    peekbyte      * 32
          bra.w    dtr_on        * 36    Called in supervisor
          bra.w    dtr_off        * 40       "    "      "
          bra.w    outempty      * 44
          dc.l    0              * 48    reserved
          dc.l    0              * 52       "
          dc.l    0              * 56       "
          dc.l    0              * 60       "
          dc.l    0              * 64       "
          dc.l    0              * 68       "
          dc.l    0              * 72       "
          dc.l    0              * 76       "

; Following variables are set by Binkley (Read-Only)
;
; VERSION is the external driver version!
; PORT is the portnumber set in BINKLEY.CFG with "Port".
;   TT    1 = MFP   (Modem-1)
;        2 = SCC-B (Modem-2)
;        3 = TTMFP (Serial-1) (not usable for Binkley)
;        4 = SCC-A (Serial-2)
;  STE  1 = MFP   (Modem-1)
;        2 = SCC-B (Modem-2)
;        3 = SCC-A (Serial-2)
;  F030 2 = SCC-B (Modem-2)
; HARDCTS
;      FALSE (0) Do not use HardCTS
;      TRUE  (1) Use HardCTS control
; TIME_RELEASE
;      Address of "time_release"-function in BT.
; HARDWARE ("_MCH"-Cookie)
;     0 = ST,MEGA-ST
;     1 = STE,MEGA-STE
;     2 = TT
;      3 = Falcon

VERSION:      dc.w    0x0111        * 80
PORT:          dc.w    0              * 82 read-only
HARDCTS:      dc.w    0              * 84 read-only
TIME_RELEASE:  dc.l    0              * 86 read-only
HARDWARE:      dc.w    0              * 90 read-only

init:  dc.b  13,10
      dc.b  ' ~~~~~~~~~~~~~~~~~~-~~~~~~~~~~~~~~~ ',13,10
      dc.b  ' | External Binkley-Driver V1.11  | ',13,10
      dc.b  ' | (c) St.Slabihoud 1993,1994     | ',13,10
      dc.b  ' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ',13,10,0
_st:  dc.b  ' | Binkley uses ST hardware       | ',13,10,0
_ste:  dc.b  ' | Binkley uses STE hardware      | ',13,10,0
_tt:  dc.b  ' | Binkley uses TT hardware       | ',13,10,0
_falc:dc.b  ' | Binkley uses Falcon hardware   | ',13,10,0
_unkn:dc.b  ' | Unknown hardware               | ',13,10,0
_end:  dc.b  ' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ',13,10,13,10,0
      EVEN


; ************************* SEND BYTE *****************************

; Send character to RS232
; Call with character in D0.w

sendbyte:
    pea      (a2)
    move.w  d0,-(a7)

    move.w  HARDCTS(pc),d0
    beq.s   senddirect
    pea      h_cts(pc)      ; HardCTS
    move.w  #$26,-(a7)
    trap    #14
    addq.w  #6,a7
senddirect:

    pea      $00030001
    trap    #13            ; Bconout
    addq.w  #6,a7

    move.l  (a7)+,a2
    rts


; ************************* SEND CHARS ****************************

; Calling with Buffer in A0.l
;                Bytes in D0.l
;                CD-Check in D1 (0=FALSE,1=TRUE)

sendchars:
    movem.l d6/d7/a2/a6,-(a7)

    move.l  a0,a6        ; Buffer
    move.l  d0,d6        ;  Counter
    move.w  d1,d7        ; CD check

    bra.s    endloop
sendloop:
    moveq    #0,d0
    move.b  (a6)+,d0
    move.w  d0,-(a7)    ; push SendByte

    move.w  HARDCTS(pc),d0
    beq.s   senddirect2
    pea      h_cts(pc)    ; HardCTS
    move.w  #$26,-(a7)
    trap    #14
    addq.w  #6,a7
senddirect2:

    pea      $00030001
    trap    #13          ;  Bconout
    addq.w  #6,a7        ; pop D0!

;    tst.w   d7          ; check CD    ==> Can be ignored! <==
;    beq.s   endloop      ; No
;    pea      get_dcd(pc)  ; check CD
;    move.w  #$26,-(a7)
;    trap    #14
;    addq.w  #6,a7
;    tst.w   d0
;    beq.s   carrierlost  ; Carrier lost
endloop:
    subq.l  #1,d6
    bpl.s    sendloop

carrierlost:
    movem.l (a7)+,d6/d7/a2/a6
    rts


h_cts:
    move.w  d3,-(a7)            ; HardCTS-Function
    move.b  d0,d3
    move.w  HARDCTS(pc),d1
    beq.b   h_ctsend            ; No HardCTS --> Exit
    bra.b   h_cts1
h_cts2:
    pea      (a2)
    move.w  #11,-(sp)      ; Cconis
    trap    #1
    addq.w  #2,sp
    move.l  (sp)+,a2
    tst.w   d0
    bne.b   h_ctsend
    move.l  TIME_RELEASE(pc),a0
    jsr      (a0)
h_cts1:
    bsr      get_cts
    tst.w    d0
    beq.b    h_cts2
h_ctsend:
    move.b  d3,d0
    move.w  (a7)+,d3
     rts

; Calling with portnumber in D0.w ("Port n")
; This function is only called, when your TOS supports "Bconmap".

set_new_port:
    subq.w  #1,d0      * 1=ST-Port
    beq.s    port6
    subq.w  #1,d0      * 2=SCC-B
    beq.s    port7
    subq.w  #1,d0      * 3=TTMFP, 3=SCC-A on a STE!
    beq.s    port8
    subq.w  #1,d0      * 4=SCC-A
    beq.s    port9
    rts                * Unknown port
port6:
    moveq    #6,d0
    bra.s    set_it
port7:
    moveq    #7,d0
    bra.s    set_it
port8:
    moveq    #8,d0
    bra.s    set_it
port9:
    moveq    #9,d0
set_it:
    pea      (a2)
    move.w  d0,-(sp)
    move.w  #44,-(sp)
    trap    #14
    addq.w  #4,sp
    move.l  (sp)+,a2
    rts

; Read a character
; Returns value in D0.w

modemin:
    pea      (a2)
    pea      $00020001
    trap    #13
    addq.w  #4,sp
    move.l  (sp)+,a2
    and.l    #$ff,d0
    rts

; If a character available?

charavail:
    pea      (a2)
    pea      $00010001
    trap    #13
    addq.w  #4,sp
    move.l  (sp)+,a2
    rts

outfull:
    pea      (a2)
    pea      $00080001
    trap    #13
    addq.w  #4,sp
    move.l  (sp)+,a2
    not.l    d0
    rts

;  Return the next character in the RS232 input buffer
;  but don't actually take it.
; Return -1 if buffer was empty

peekbyte:
    pea      (a2)
    clr.w    -(sp)
    move.w  #14,-(sp)
    trap    #14
    addq.w  #4,sp
    move.l  (sp)+,a2
    move.l  d0,a0
    move.w  6(a0),d0
    cmp.w    8(a0),d0
    bne.s    peek2
    moveq    #-1,d0
    rts
peek2:
    move.w  6(a0),d0
    addq.w  #1,d0
    cmp.w    4(a0),d0
    blo.s    peek3
    clr.w    d0
peek3:
    move.l  (a0),a0
    move.b  (a0,d0.w),d0
    and.w    #255,d0
    rts


outempty:
    pea      (a2)
    clr.w    -(sp)
    move.w  #14,-(sp)
    trap    #14
    addq.w  #4,sp
    move.l  (sp)+,a2
    move.l  d0,a0
    lea      $e(a0),a0      ; Output-Buffer
    move.w  6(a0),d0
    cmp.w    8(a0),d0
    beq.s    outempty1
    moveq    #0,d0
    rts
outempty1:
    moveq    #1,d0
    rts

; ******************************************************************

; Set DTR on
  
dtr_on:
    move.w  sr,d1
    or.w    #$700,sr

    move.w  PORT(pc),d0
    tst.w    d0
    beq.s    on_mfpport1
    subq.w  #1,d0
    beq.s    on_mfpport1
    subq.w  #1,d0
    beq.s    on_sccb_cnt

    lea      HARDWARE(pc),a0
    cmp.w    #1,(a0)          * STE-Hardware?
    beq.s    on_ste

    subq.w  #1,d0
;    beq.s    on_mfpport2

on_ste:
    subq.w  #1,d0
    beq.s    on_scca_cnt
    move.w  d1,sr
    rts

on_mfpport1:
    pea      (a2)
    move.w  #0xe7,-(sp)
    move.w  #29,-(sp)
    trap    #14
    addq.w  #4,sp
    move.l  (sp)+,a2
    move.w  d1,sr
    rts
;on_mfpport2:
;    move.w  d1,sr
;    rts
on_sccb_cnt:
    move.b  #5,SCCB_CNT
    nop
    nop
    nop
    move.b  #$ea,SCCB_CNT
    move.w  d1,sr
    rts
on_scca_cnt:
    move.b  #5,SCCA_CNT
    nop
    nop
    nop
    move.b  #$ea,SCCA_CNT
    move.w  d1,sr
    rts

dtr_off:
    move.w  sr,d1
    or.w    #$700,d1

    move.w  PORT(pc),d0
    tst.w    d0
    beq.s    off_mfpport1
    subq.w  #1,d0
    beq.s    off_mfpport1
    subq.w  #1,d0
    beq.s    off_sccb_cnt

    lea      HARDWARE(pc),a0
    cmp.w    #1,(a0)          * STE-Hardware?
    beq.s    off_ste

    subq.w  #1,d0
;    beq.s    off_mfpport2

off_ste:
    subq.w  #1,d0
    beq.s    off_scca_cnt
    move.w  d1,sr
    rts
off_mfpport1:
    pea      (a2)
    move.w  #0x18,-(sp)
    move.w  #30,-(sp)
    trap    #14
    addq.w  #4,sp
    move.l  (sp)+,a2
    move.w  d1,sr
    rts
;off_mfpport2:
;    move.w  d1,sr
;    rts
off_sccb_cnt:
    move.b  #5,SCCB_CNT
    nop
    nop
    nop
    move.b  #$6a,SCCB_CNT
    move.w  d1,sr
    rts
off_scca_cnt:
    move.b  #5,SCCA_CNT
    nop
    nop
    nop
    move.b  #$6a,SCCA_CNT
    move.w  d1,sr
    rts

; Get carrier detect signal

get_dcd:
    move.w  sr,d1
    or.w    #$700,sr

    move.w  PORT(pc),d0
    tst.w    d0
    beq.s    dcd_mfpport1
    subq.w  #1,d0
    beq.s    dcd_mfpport1    * (Modem-1)
    subq.w  #1,d0
    beq.s    dcd_sccb_cnt    * (Modem-2)

    lea      HARDWARE(pc),a0
    cmp.w    #1,(a0)          * STE-Hardware?
    beq.s    dcd_ste

    subq.w  #1,d0
;    beq.s    dcd_mfpport2    * (Seriell-1) returns no CD

dcd_ste:
    subq.w  #1,d0
    beq.s    dcd_scca_cnt    * (Seriell-2)
    moveq.l  #8,d0
    move.w  d1,sr
    rts

dcd_mfpport1:
    moveq.l  #0,d0
    move.b  MFPPORT1,d0      * ~dcd & 2
    not.b    d0
    and.b    #2,d0
    move.w  d1,sr
    rts
;dcd_mfpport2:
;    moveq.l  #0,d0
;    move.b  MFPPORT2,d0      * ~dcd & 2
;    not.b    d0
;    and.b    #2,d0
;    move.w  d1,sr
;    rts
dcd_sccb_cnt:
    moveq.l  #0,d0
    move.b  #0,SCCB_CNT
    nop
    nop
    nop
    move.b  SCCB_CNT,d0      * dcd & 8
    and.b    #8,d0
    move.w  d1,sr
    rts
dcd_scca_cnt:
    moveq.l  #0,d0
    move.b  #0,SCCA_CNT
    nop
    nop
    move.b  SCCA_CNT,d0      * dcd & 8
    and.b    #8,d0
    move.w  d1,sr
    rts

; Get CTS signal

get_cts:
    move.w  sr,d1
    or.w    #$700,d1

    move.w  PORT(pc),d0
    tst.w    d0
    beq.s    cts_mfpport1
    subq.w  #1,d0
    beq.s    cts_mfpport1
    subq.w  #1,d0
    beq.s    cts_sccb_cnt

    lea      HARDWARE(pc),a0
    cmp.w    #1,(a0)          * STE-Hardware?
    beq.s    cts_ste

    subq.w  #1,d0
;    beq.s    cts_mfpport2    * (Seriell-1) returns no CTS

cts_ste:
    subq.w  #1,d0
    beq.s    cts_scca_cnt
    moveq.l  #8,d0
    move.w  d1,sr
    rts

cts_mfpport1:
    moveq.l  #0,d0
    move.b  MFPPORT1,d0      * ~cts & 4
    not.b    d0
    and.b    #4,d0
    move.w  d1,sr
    rts
;cts_mfpport2:
;    moveq.l  #0,d0
;    move.b  MFPPORT2,d0      * ~cts & 4
;    not.b    d0
;    and.b    #4,d0
;    move.w  d1,sr
;    rts
cts_sccb_cnt:
    moveq.l  #0,d0
    move.b  #0,SCCB_CNT
    nop
    nop
    nop
    move.b  SCCB_CNT,d0      * cts & 0x20
    and.b    #0x20,d0
    move.w  d1,sr
    rts
cts_scca_cnt:
    moveq.l  #0,d0
    move.b  #0,SCCA_CNT
    nop
    nop
    move.b  SCCA_CNT,d0      * cts & 0x20
    and.b    #0x20,d0
    move.w  d1,sr
    rts


