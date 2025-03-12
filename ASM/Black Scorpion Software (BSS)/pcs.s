*-----------------------------------------------------------------------*
*                   'PCS' display module               *
*-----------------------------------------------------------------------*
*               (C) 1992  Douglas Little             *
*-----------------------------------------------------------------------*

   OPT   O+,W-

Devpac2_Pro      ; if this option does not work, take it out!
         ; (Devpac2 Pro's dcb.? command is back to front and
         ; can cause problems. If the assembler jams up,
         ; comment this option out and try again.

*-----------------------------------------------------------------------*
*   STANDARD HARDWARE EQUATES                     *
*-----------------------------------------------------------------------*

LineADD      =   160
PHYS_MED      =   $FFFF8201
PHYS_TOP      =   $FFFF8203
COLOUR      =   $FFFF8240
FREQ         =   $FFFF820A

MFP         =   $FFFFFA00
ENABLE_A      =   MFP+$07      ; int enable A
ENABLE_B      =   MFP+$09      ; int enable B
PENDING_A      =   MFP+$0B      ; int pending A
PENDING_B      =   MFP+$0D      ; int pending B
IN_SERVICE_A   =   MFP+$0F      ; int in-service A
IN_SERVICE_B   =   MFP+$11      ; int in-service B
MASK_A      =   MFP+$13      ; int mask A
MASK_B      =   MFP+$15      ; int mask B
VECTOR      =   MFP+$17      ; MFP vector base
CTRL_A      =   MFP+$19      ; MFP timer A control
CTRL_B      =   MFP+$1B      ; MFP timer B control
DATA_A      =   MFP+$1F      ; timer A data
DATA_B      =   MFP+$21      ; timer B data

HBI_VEC      =   $68         ; Hblank timer
VBI_VEC      =   $70         ; VBI
KBD_VEC      =   $118         ; IKBD
TIMER_A      =   $134         ; General timer
TIMER_B      =   $120         ; Raster timer

BLIT         =   $FFFF8A00
halftone      =   BLIT+00   16*16 pattern mask
src_xinc      =   BLIT+32   increment of next source word (-128 -> +127)
src_yinc      =   BLIT+34   increment of next source line (-128 -> +127)
src_addr      =   BLIT+36   source data address
endmask1      =   BLIT+40   mask for first word in line (or only word)
endmask2      =   BLIT+42   mask for middle words in line
endmask3      =   BLIT+44   mask for last word in line
dst_xinc      =   BLIT+46   increment of next dest. word (-128 -> +127)
dst_yinc      =   BLIT+48   increment of next dest. line (-128 -> +127)
dst_addr      =   BLIT+50   destination screen address
x_size      =   BLIT+54   x-size   (number of words to go)
y_size      =   BLIT+56   y_size   (number of lines to go)
HOP         =   BLIT+58   halftone operation...
blit_op      =   BLIT+59   logic operations
blit_stat      =   BLIT+60   blitter chip status registers
skew         =   BLIT+61   offset bit shift (byte, 0 > +-15)

*-----------------------------------------------------------------------*
*   USEFUL MACROS                           *
*-----------------------------------------------------------------------*

push   macro
   move.\0   \1,-(sp)
   endm
   
pop   macro
   move.\0   (sp)+,\1
   endm

pushall      macro
   movem.l   d0-d7/a0-a6,-(sp)
   endm
   
popall      macro
   movem.l   (sp)+,d0-d7/a0-a6
   endm

delay   macro               ; wait for #n VBI's
   lea      TIMER(pc),a5
   move.w   #\1,(a5)
.wz\@   tst.w      (a5)
   bne.s      .wz\@
   endm

*-----------------------------------------------------------------------*

sync      macro            ; clock-cycle timing macro
      IFEQ      NARG-1   ; please don't read this, especially
      IFD      Devpac2_Pro
      dcb.w      \1,$4E71   ; if you are a fan of high level
      ELSEIF
      dcb.w      $4E71,\1
      ENDC
      ELSEIF         ; coding!
      IFLT      \1-3-3
      IFD      Devpac2_Pro
      dcb.w      \1,$4E71
      ELSEIF
      dcb.w      $4E71,\1
      ENDC
      ELSEIF
      move.w   #(\1-3)/3-1,\2
.wc\@      dbra      \2,.wc\@
Calc      set      (\1-3)-((\1-3)/3)*3
      IFGT      Calc
      IFD      Devpac2_Pro
      dcb.w      Calc,$4E71   ; if you are a fan of high level
      ELSEIF
      dcb.w      $4E71,Calc   ; if you are a fan of high level
      ENDC
      ENDC
      ENDC
      ENDC
      endm

*-----------------------------------------------------------------------*

CODE:         bra.s   START

VARIABLES:
TIME:         ds.w   1      ; number of seconds to display picture
DATA:         ds.l   1      ; source file
BIT1:         ds.l   1      ; screen 1 address
PAL1:         ds.l   1      ; palette 1 address
BIT2:         ds.l   1      ; screen 2 address
PAL2:         ds.l   1      ; palette 2 address

OLD_SCR      ds.l   1
TIMER:      ds.w   1
INTERLACE:      ds.b   1
HERZ:         ds.b   1

OLD_PAL      ds.w   16
VECTORS:      ds.b   40

*-----------------------------------------------------------------------*

START:lea      VARIABLES(pc),a6
   move.w   d0,(a6)+
   move.l   a0,(a6)+
   move.l   a1,(a6)+
   move.l   a2,(a6)+
   move.l   a3,(a6)+
   move.l   a4,(a6)+
   bsr      EMPTY_BUFFER         ; clear keyboard buffer
   bsr      INIT_VECTORS         ; store old vector setup
   bsr.s      DISPLAY_PCS            ; show off fancy piccy
   bsr      RESET_VECTORS
   bsr      EMPTY_BUFFER
   rts
   
*-----------------------------------------------------------------------*
*   DISPLAY 'PCS' ROUTINES START HERE                  *
*-----------------------------------------------------------------------*

DISPLAY_PCS:            ; show one of my own snazzy 'PCS' pics.
   bsr      SAVE_SCREEN_SETUP   ; init screen for piccy, saving old one
   move.l   DATA(pc),a0      ; get address of file
   bsr      UNPACK_PCS      ; unpack picture onto screen(s).
   delay      8         ; wait for 10 vbi's (in case of 50/60Hz
   bsr      ENHANCED_DISPLAY   ; switch). Turn on display interrupt.
   move.w   TIME(pc),d1
   mulu      #50,d1
   subq.l   #1,d1
.loop   cmp.b      #57,$FFFFFC02.w   ; wait for 
   beq.s      .out
   lea      TIMER(pc),a6
   addq      #1,(a6)      ; wait for 1 VBI
.wtv   tst.w      (a6)
   bne.s      .wtv
   subq.l   #1,d1         ; decrement wait-counter.
   bpl.s      .loop
.out   bsr      STANDARD_DISPLAY   ; when done, remove display interrupt.
   bsr      KILL_PALETTE
   bsr      REPLACE_SCREEN_SETUP
   rts

SAVE_SCREEN_SETUP:
   lea      COLOUR.w,a0      ; store old colours
   lea      OLD_PAL(pc),a1
   moveq      #8-1,d0
.lp   move.l   (a0)+,(a1)+
   dbra      d0,.lp
   move.l   $FFFF8200.w,d0   ; store old screen address
   lsl.w      #8,d0
   and.l      #$00FFFFFF,d0
   lea      OLD_SCR(pc),a0
   move.l   d0,(a0)
   bsr      KILL_PALETTE   ; black screen
   move.l   BIT1(pc),a0      ; clear screen 1
   bsr      CLS
   move.l   BIT2(pc),a0      ; clear screen 2
   bsr      CLS   
   rts
   
REPLACE_SCREEN_SETUP:
   bsr      KILL_PALETTE   ; black screen
   move.l   BIT1(pc),a0      ; clear screen 1
   bsr      CLS
   move.l   BIT2(pc),a0      ; clear screen 2
   bsr      CLS   
   move.l   OLD_SCR(pc),d0
   lsr.w      #8,d0
   move.l   d0,$FFFF8200.w
   lea      OLD_PAL(pc),a0
   lea      COLOUR.w,a1      ; store old colours
   moveq      #8-1,d0
.lp   move.l   (a0)+,(a1)+
   dbra      d0,.lp
   rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   UNPACK A 'PCS' PICTURE                        *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

         rsreset
PCS_width      rs.w   1   ; usually 320 for now
PCS_height      rs.w   1   ; usually 200 for now
PCS_interlace   rs.b   1   ; PCS-ST/E = 0 : SuperHam and Pchrome <> 0
PCS_ste      rs.b   1   ; uses ste palette? 50/60Hz?
PCS_start      rs.b   0   ; end of file header

;---------------------------------------------------------------------------
;      bit list...    (PCS_interlace)
;      bit 0      :   if clear > XOR screen1 with screen2
;      bit 1      :   if clear > XOR palette1 with palette2
;      bit 2      :   if set   > interlace on, use bits 0+1,
;               otherwise ignore bits 0+1.
;
;   1.   if bit 2 is CLEAR then ignore bits 0+1.
;   2.   if bit 2 is SET and bit 0 is CLEAR then XOR
;      screen 1 with screen 2 after decompression. (delta-compression)
;   3.   if bit 2 is SET and bit 1 is CLEAR then XOR
;      palette 1 with palette 2 after decompression.
;---------------------------------------------------------------------------
;      bit list...    (PCS_ste)
;      bit 0      :   if set > use 50Hz otherwise use 60Hz
;      bit 1      :   if set > then pic uses STE palette of 4096.
;
;   1.   if bit 0 is SET then the picture requires 50Hz,
;      otherwise set to 60Hz (STE or not)
;   2.   if bit 1 is SET, then piccy uses 4096 colour palette.
;---------------------------------------------------------------------------
;
;   There are 2 or 4 compressed chunks in each file - 1 bitmap and
;   1 palette for each screen, with 2 screens if it's interlaced.
;
;   The body of a chunk is a 2-byte value (not necessarily on a word
;   boundary) holding the number of control bytes in that compressed
;   chunk. This is followed by a big list of control bytes and data.
;
;   The bitmaps are horizontally byte-run compressed (like Degas)
;   but wrap around the screen instead of terminating on each scanline
;   (unlike Degas, more like Tiny). The screen planes are compressed
;   entirely separately, (the whole of plane 0 followed by the whole
;   of plane 1 etc.) without a break in the compression. It is just
;   one big string of data. If the screen was empty, the entire data
;   would consist of a control byte 0 (get a word), a control word
;   of 32000 (number of repeats), and a byte of 0 (byte to repeat).
;   The palette is compressed the same way, but using compressed words
;   instead of bytes.
;
;       For a given control byte, x: (as Tiny standard)
;
;
;     x < 0   Absolute value specifies the number of unique bytes/words to
;             fetch directly (from 1 to 127)
;
;     x = 0   1 word is taken which specifies the number of times to repeat
;          the next data byte/word fetched (from 128 to 32767)
;
;     x = 1   1 word is taken which specifies the number of unique
;          bytes/words to be fetched directly (from 128 - 32767)
;
;     x > 1   Specifies the number of times to repeat the next byte/word
;             fetched (from 2 to 127)

UNPACK_PCS:
   lea      INTERLACE(pc),a5
   sf      (a5)
   lea      PCS_start(a0),a1   ; get past file header
   move.l   a0,a6         ; keep for later
   lea      HERZ(pc),a5
   clr.b      (a5)         ; set to 60Hz for now
   btst.b   #0,PCS_ste(a6)   ; check real picture frequency,
   beq.s      .hz60         ; if 60Hz, then leave as it is
.hz50   move.b   #2,(a5)      ; otherwise must be 50Hz
.hz60   move.b   (a5),FREQ.w      ; set up freq.
   move.l   BIT1(pc),a0      ; get dest address of bitmap 1
   bsr.s      UNPACK_BITMAP   ; unpack it onto screen
   move.l   PAL1(pc),a0      ; same with palette
   bsr      UNPACK_PALETTE   ; unpack it.
   tst.b      PCS_interlace(a6)   ; check for interlaced mode
   beq.s      .done         ; if not, skip past it
   lea      INTERLACE(pc),a5
   st      (a5)         ; set INTERLACE to TRUE.
   move.l   BIT2(pc),a0      ; now unpack second screen and
   bsr.s      UNPACK_BITMAP   ; palette in the same way
   move.l   PAL2(pc),a0
   bsr      UNPACK_PALETTE
   bsr      XOR_BITMAP      ; do delta-decompression if needed
   bsr      XOR_PALETTE      ; on bitmap2 or palette2
.done   lea      PAL1(pc),a5
   add.l      #32,(a5)      ; skip past first 16 colours
   lea      PAL2(pc),a5
   add.l      #32,(a5)      ; in palette banks (used in top border)
   rts
   
UNPACK_BITMAP:            ; decompress a bitmap.
   moveq      #0,d6
   move.w   #40,d2
   move.w   #200,d3
   moveq      #5,d4
   move.b   (a1)+,d7
   lsl.w      #8,d7
   move.b   (a1)+,d7
.Main   moveq      #0,d0
   subq      #1,d7
   bmi.s      .esc
   move.b   (a1)+,d0
   bmi.s      .B_block_copy
   beq.s      .W_run_length
   cmp.b      #1,d0
   beq.s      .W_block_copy
   bra.s      .B_run_length
.W_run_length
   move.b   (a1)+,d0
   lsl.w      #8,d0
   move.b   (a1)+,d0
.B_run_length
   subq      #1,d0
   move.b   (a1)+,d1
.run   move.b   d1,(a0,d6)
   addq      #1,d6
   and.w      #1,d6
   bne.s      .ok
   addq      #8,a0
.ok   subq      #1,d2            ; drop 1 line
   bne.s      .fine
   moveq      #40,d2
   subq      #1,d3
   bne.s      .fine
   move.w   #200,d3
   lea      2-32000(a0),a0
   subq      #1,d4
   beq.s      .esc
.fine   dbra      d0,.run
   bra.s      .Main
.esc   rts
.B_block_copy
   neg.b      d0
   bra.s      .nw
.W_block_copy
   move.b   (a1)+,d0
   lsl.w      #8,d0
   move.b   (a1)+,d0
.nw   subq      #1,d0
.blk   move.b   (a1)+,d1
   move.b   d1,(a0,d6)
   addq      #1,d6
   and.w      #1,d6
   bne.s      .ok2
   addq      #8,a0
.ok2   subq      #1,d2            ; drop 1 line
   bne.s      .fin2
   moveq      #40,d2
   subq      #1,d3
   bne.s      .fin2
   move.w   #200,d3
   lea      2-32000(a0),a0
   subq      #1,d4
   beq.s      .esc
.fin2   dbra      d0,.blk
   bra      .Main

UNPACK_PALETTE:            ; decompress a palette
   move.b   (a1)+,d7
   lsl.w      #8,d7
   move.b   (a1)+,d7
.Main   moveq      #0,d0
   subq      #1,d7
   bmi.s      .esc
   move.b   (a1)+,d0
   bmi.s      .B_block_copy
   beq.s      .W_run_length
   cmp.b      #1,d0
   beq.s      .W_block_copy
   bra.s      .B_run_length
.W_run_length
   move.b   (a1)+,d0
   lsl.w      #8,d0
   move.b   (a1)+,d0
.B_run_length
   subq      #1,d0
   move.b   (a1)+,d1
   lsl.w      #8,d1
   move.b   (a1)+,d1
.run   move.w   d1,(a0)+
   dbra      d0,.run
   bra.s      .Main
.esc   rts
.B_block_copy
   neg.b      d0
   bra.s      .nw
.W_block_copy
   move.b   (a1)+,d0
   lsl.w      #8,d0
   move.b   (a1)+,d0
.nw   subq      #1,d0
.blk   move.b   (a1)+,d1
   lsl.w      #8,d1
   move.b   (a1)+,d1
   move.w   d1,(a0)+
   dbra      d0,.blk
   bra.s      .Main

XOR_BITMAP:                  ; delta decompression on bitmap.
   btst.b   #0,PCS_interlace(a6)
   bne.s      .nox
   pushall
   move.l   BIT1(pc),a0
   move.l   BIT2(pc),a1
   move.w   #32000/4-1,d0
.blop   move.l   (a0)+,d1
   eor.l      d1,(a1)+
   dbra      d0,.blop
   popall
.nox   rts

XOR_PALETTE:                  ; delta decompression on palette.
   btst.b   #1,PCS_interlace(a6)
   bne.s      .nox
   pushall
   move.l   PAL1(pc),a0
   move.l   PAL2(pc),a1
   move.w   #16*(3*199+1)-1,d0
.clop   move.w   (a0)+,d1
   eor.w      d1,(a1)+
   dbra      d0,.clop
   popall
.nox   rts

*-----------------------------------------------------------------------*
*   COLOUR SWITCHING ROUTINE                     *
*-----------------------------------------------------------------------*
*   This is the actual screen-display interrupt and setup code      *
*-----------------------------------------------------------------------*

SCANLINE      =   $700
VIDEO_COUNTER   =   $FFFF8209

STE_HAM:
   btst      #1,FREQ.w
   bne.s      .hz50
   move.b   #32-10,SCANLINE.w
.hz60   pea      SCAN_COUNTER_60HZ(pc)
   bra.s      .done
.hz50   move.b   #62-10,SCANLINE.w
   pea      SCAN_COUNTER_50HZ(pc)
.done   pop.l      HBI_VEC.w
   move.w   #$2100,sr
   pushall
   move.l   PAL2(pc),a0
   lea      2*(1-16)(a0),a0
   lea      2+COLOUR.w,a1
   move.w   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
   move.l   (a0)+,(a1)+
.wait   tst.b      SCANLINE.w
   bne.s      .wait
   move.w   #$2300,sr
.read   btst      #0,$FFFFFC00.w
   beq.s      .out
   move.b   $FFFFFC02.w,d0
   bra.s      .read
.out   lea      TIMER(pc),a0
   tst.w      (a0)
   ble.s      .rte
   subq      #1,(a0)
.rte   move.l   PAL1(pc),d0
   lea      INTERLACE(pc),a0
   tst.b      (a0)
   beq.s      .nin1
   lea      PAL1(pc),a0
   move.l   PAL2(pc),(a0)
.nin1   lea      PAL2(pc),a0
   move.l   d0,(a0)
   move.l   BIT1(pc),d0
   lea      INTERLACE(pc),a0
   tst.b      (a0)
   beq.s      .nin2
   lea      BIT1(pc),a0
   move.l   BIT2(pc),(a0)
.nin2   lea      BIT2(pc),a0
   move.l   d0,(a0)
.nint   lsr.w      #8,d0
   move.l   d0,$FFFF8200.w
.skip   popall
   rte

SCAN_COUNTER_50HZ:
   subq.b   #1,SCANLINE.w
   ble.s      SCREEN_RASTER_50HZ
   rte
   
SCREEN_RASTER_50HZ:
   move.w   #$2700,sr
   movem.l   d0-a6,-(sp)
   lea      (.ssp)+2(pc),a6
   move.l   a7,(a6)
   lea      VIDEO_COUNTER.w,a6
   moveq      #0,d0
   moveq      #64,d7
.wait   move.b   (a6),d0
   beq.s      .wait
   sub.w      d0,d7
   lsl.w      d7,d0
   sync      55,d0
   move.l   PAL2(pc),a7
   rept      199
   movem.l   (a7)+,d0-a6
   movem.l   d0-d7,COLOUR.w
   movem.l   a0-a6,COLOUR.w
   move.l   (a7)+,28+COLOUR.w
   lea      COLOUR.w,a0
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.w   #0,COLOUR.w
   move.l   (a7)+,(a0)+
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   endr
.ssp   move.l   #0,a7
   movem.l   (sp)+,d0-a6
   pea      ARTE(pc)
   pop.l      HBI_VEC.w   
   move.b   #$23,(sp)
ARTE:   rte

SCAN_COUNTER_60HZ:
   subq.b   #1,SCANLINE.w
   ble.s      SCREEN_RASTER_60HZ
   rte
   
SCREEN_RASTER_60HZ:
   move.w   #$2700,sr
   movem.l   d0-a6,-(sp)
   lea      (.ssp)+2(pc),a6
   move.l   a7,(a6)
   lea      VIDEO_COUNTER.w,a6
   moveq      #0,d0
   moveq      #64,d7
.wait   move.b   (a6),d0
   beq.s      .wait
   sub.w      d0,d7
   lsl.w      d7,d0
   sync      54,d0
   move.l   PAL2(pc),a7   
   rept      199
   movem.l   (a7)+,d0-a6
   movem.l   d0-d7,COLOUR.w
   movem.l   a0-a6,COLOUR.w
   move.l   (a7)+,28+COLOUR.w
   lea      COLOUR.w,a0
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.l   (a7)+,(a0)+
   move.w   #0,COLOUR.w
   move.l   (a7)+,(a0)+
   nop
   nop
   nop
   nop
   nop
   nop
   endr
.ssp   move.l   #0,a7
   movem.l   (sp)+,d0-a6
   pea      ARTE(pc)
   pop.l      HBI_VEC.w   
   move.b   #$23,(sp)
   rte
   
*-----------------------------------------------------------------------*
*   INITIALISE PCS DISPLAY INTERRUPT                  *
*-----------------------------------------------------------------------*

ENHANCED_DISPLAY:
   move.b   #$12,$FFFFFC02.w      ; turn off the mouse 'cos it
   move.w   #$2700,sr
   pea      STE_HAM(pc)
   pop.l      VBI_VEC.w
   move.w   #$2300,sr
   rts

STANDARD_DISPLAY:
   move.w   #$2700,sr
   pea      NEW_VBI(pc)
   pop.l      VBI_VEC.w
   move.w   #$2300,sr
   move.b   #$8,$FFFFFC02.w      ; turn off the mouse 'cos it
   rts

*-------------------------------------------------------------------------*

INIT_VECTORS:
   lea      VECTORS(pc),a0
   move.l   USP,a1
   move.l   a1,(a0)+
   move.l   HBI_VEC.w,(a0)+
   move.l   VBI_VEC.w,(a0)+
   move.l   KBD_VEC.w,(a0)+
   move.l   TIMER_A.w,(a0)+
   move.l   TIMER_B.w,(a0)+
   move.b   ENABLE_A.w,(a0)+
   move.b   ENABLE_B.w,(a0)+
   move.b   MASK_A.w,(a0)+
   move.b   MASK_B.w,(a0)+
   move.b   DATA_A.w,(a0)+
   move.b   DATA_B.w,(a0)+
   move.b   CTRL_A.w,(a0)+
   move.b   CTRL_B.w,(a0)+
   move.b   VECTOR.w,(a0)+
   move.b   FREQ.w,(a0)+
   move.w   #$2700,sr
   pea      NEW_VBI(pc)
   pop.l      VBI_VEC.w
   move.b   #0,ENABLE_A.w
   move.b   #1<<6,ENABLE_B.w   ; leave IKBD alone
   move.w   #$2300,sr
   rts
   
RESET_VECTORS:
   move.w   #$2700,sr
   lea      VECTORS(pc),a0
   move.l   (a0)+,a1
   move.l   a1,USP
   move.l   (a0)+,HBI_VEC.w
   move.l   (a0)+,VBI_VEC.w
   move.l   (a0)+,KBD_VEC.w
   move.l   (a0)+,TIMER_A.w
   move.l   (a0)+,TIMER_B.w
   move.b   (a0)+,ENABLE_A.w
   move.b   (a0)+,ENABLE_B.w
   move.b   (a0)+,MASK_A.w
   move.b   (a0)+,MASK_B.w
   move.b   (a0)+,DATA_A.w
   move.b   (a0)+,DATA_B.w
   move.b   (a0)+,CTRL_A.w
   move.b   (a0)+,CTRL_B.w
   move.b   (a0)+,VECTOR.w
   move.b   (a0)+,FREQ.w
   move.w   #$2300,sr
   rts

NEW_VBI:
   push.l   a0
   lea      TIMER(pc),a0
   tst.w      (a0)
   ble.s      .rte
   subq      #1,(a0)
.rte   pop.l      a0
   rte

*-------------------------------------------------------------------------*

EMPTY_BUFFER:
   pushall
   bsr.s      FLUSH      ; flush the IKBD properly (sorry, GEM!)
.bak   push.w   #11
   trap      #1
   addq      #2,sp
   tst.l      d0
   beq.s      .out
   push.w   #7
   trap      #1
   addq      #2,sp
   bra.s      .bak
.out   popall
   rts

FLUSH:push.w   d7
.read   btst      #0,$FFFFFC00.w   ; empty hardware ikbd buffer
   beq.s      .out
   move.b   $FFFFFC02.w,d7
   bra.s      .read
.out   pop.w      d7
   rts

KILL_PALETTE:
   moveq      #8-1,d7
   lea      COLOUR.w,a0
.lp   clr.l      (a0)+
   dbra      d7,.lp      ; empty out palette
   rts

CLS:   move.w   #32000/4-1,d0
.loop   clr.l      (a0)+
   dbra      d0,.loop
   rts

