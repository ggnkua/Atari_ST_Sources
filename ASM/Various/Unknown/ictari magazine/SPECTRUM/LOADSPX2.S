* this routine loads one spectrum pic and shows on screen

flock     equ     $43E
_vbl_list equ     $4CE
video_adr equ     $FF8209 
palette   equ     $FF8240 

          movea.l a7,a5 
          movea.l #stack,a7     ;SP
          movea.l 4(a5),a5      ;calculate memory size
          move.l  $C(a5),d0 
          add.l   $14(a5),d0
          add.l   $1C(a5),d0
          addi.l  #$100,d0
          move.l  d0,-(a7)
          move.l  a5,-(a7)
          move.w  #0,-(a7)          
          move.w  #$4A,-(a7)    ;Mshrink 
          trap    #1
          add.l   #12,a7 

          move.w  #2,-(a7)      ;Physbase
          trap    #14           
          addq.l  #2,a7 
          move.l  d0,physbase   ;save physical screen address

          move.l  #m_off,-(a7)  ;Zeiger auf $12
          move.w  #0,-(a7)      ;send one byte to keyboard
          move.w  #$19,-(a7)    ;ikbdws  
          trap    #14           ;mouse off
          addq.l  #8,a7 

          move.l  #save_pal,-(a7) ;save palette
          move.w  #$26,-(a7)      ;and 60 Hz on
          trap    #14
          addq.l  #4,a7 

          move.w  #4,-(a7)        ;get resolution
          trap    #14
          addq.l  #2,a7 
          move.w  d0,rez          ;low resolution ?

          beq     low_res       
          move.w  #0,-(a7)        ;No, then set low resolution
          move.l  #-1,-(a7)     
          move.l  #-1,-(a7)
          move.w  #5,-(a7)
          trap    #14
          add.l   #12,a7 

low_res:   move.l  #c_pal,-(a7)  ;clear color palette
          move.w  #$26,-(a7)    ;exec in supervisor mode
          trap    #14
          addq.l  #6,a7 

*-------------- read picture file ---------------------------

          lea     picfile,a5
          move.w  #0,-(a7)      ;read only
          move.l  a5,-(a7)      ;filename
          move.w  #$3D,-(a7)    ;and open
          trap    #1
          addq.l  #8,a7

          tst.w   d0            ;Fopen was successful ?
          bmi     error         ;No, exit

          move.w  d0,handle     ;read header
          move.l  #header,-(a7) 
          move.l  #12,-(a7)     ;12 Bytes
          move.w  handle,-(a7)
          move.w  #$3F,-(a7) 
          trap    #1
          add.l   #14,a7 

          tst.l   d0            ;error in Fread ?
          bmi     error         ;Yes, exit
          cmp.l   #12,d0        ;all 12 bytes read ?
          bne     error         ;No, exit

          cmpi.w  #$5350,header ;check magic, ASCII 'SP'.. ($10EA8)
          bne     error

          move.l  #chunk1,-(a7) ;address of picture data
          move.l  size1,-(a7)   ;length of picture data
          move.w  handle,-(a7)  ;and read
          move.w  #$3F,-(a7)
          trap    #1
          add.l   #12,a7 

          tst.l   d0            ;error in Fread ?
          bmi     error         ;yes, exit

          cmp.l   size1,d0      ;all bytes read ?
          bne     error         ;no, exit

          move.l  #chunk2,-(a7) ;address of color data
          move.l  size2,-(a7)   ;length of color data
          move.w  handle,-(a7)  ;and read
          move.w  #$3F,-(a7)
          trap    #1
          add.l   #12,a7 

          tst.l   d0
          bmi     error
          cmp.l   size2,d0      ;all bytesread ?
          bne     error

          move.w  handle,-(a7)  ;close file
          move.w  #$3E,-(a7)
          trap    #1
          addq.l  #4,a7 

          tst.w   d0            ;error in Fclose ?
          bmi     error

          bsr     decode        ;decompress picture data

          move.l  #init,-(a7)   ;install new VBL
          move.w  #$26,-(a7)
          trap    #14
          addq.l  #6,a7 

dispwait: move.w  #2,-(a7)          
          move.w  #1,-(a7)      ;Bconstat: is a key pressed ?
          trap    #13
          addq.l  #4,a7 

          tst.w   d0
          beq     dispwait      ;no, continue waiting


error:
          move.l  #restvbl,-(a7)        ;restore old VBL
          move.w  #$26,-(a7)
          trap    #14
          addq.l  #6,a7 

er_exit:  move.w  rez,d0 
          beq     ist_lo
          move.w  d0,-(a7)      ;restore old resolution
          move.l  #-1,-(a7)
          move.l  #-1,-(a7)
          move.w  #5,-(a7)
          trap    #14
          add.l   #12,a7

ist_lo:   move.l  #oldpal,-(a7) ;restore old color palette
          move.w  #6,-(a7)
          trap    #14
          addq.l  #6,a7 

          move.l  #m_on,-(a7)   ;mouse on
          move.w  #0,-(a7)          
          move.w  #$19,-(a7)
          trap    #14 
          addq.l  #8,a7 

          clr.w   -(a7)      ;exit programm
          trap    #1
          rts
*------------------------------------------------------------
save_pal: lea     palette,a0    ;save palette
          lea     oldpal,a1 
          move.w  #15,d7
copypal:  move.w  (a0)+,(a1)+ 
          dbf     d7,copypal 

          move.b  $ffff820a,d7  ;get Syncmode
          and.b    #$fd,d7      ;switch to 60 Hz
          move.b  d7,$FFFF820a  ;write new mode
          rts 
*------------------------------------------------------------
c_pal:    lea     palette,a0    ;clear palette
          move.w  #15,d7
c_pal_lp: clr.w   (a0)+ 
          dbf     d7,c_pal_lp 
          rts
*-------------------------------------------------------------
init:
          move.l  _vbl_list,vbl 
          move.l  #new_vbl,_vbl_list
          rts 
restvbl:
          move.l  vbl,_vbl_list 
          rts 

*------------------------- decompress picture data -----------

decode:   lea     chunk1,a0     ;decompress picture data
          movea.l physbase,a1 
          move.w  #1,d1         ;d1: distance 1st Byte to the 2nd Byte in a word of a plane
          move.w  #7,d7         ;d7: distance 2nd Byte in a word to the 1st in the next word of the same plane
          lea     32000(a1),a2  ;a2: end of the screen memory
          lea     8(a2),a3      ;end-label
nxtplane: lea     -31840(a2),a1 ;minus 31840, that means 199 lines back

expand:   move.b  (a0)+,d6      ;get byte from chunk
          ext.w   d6            ;extend to word size: if D6>=0, then
          bmi     negativ       ;get D6 bytes direct from file
exp_lp:   move.b  (a0)+,(a1)    ;positive number: next byte to screen
          adda.w  d1,a1         ;next byte of *this* Plane
          exg     d1,d7         ;exchange the distance 1 and 7
          dbf     d6,exp_lp 
          bra     weiter

negativ:  neg.w   d6            ;d6:=-d6+1
          addq.w  #1,d6
          move.b  (a0)+,d0      ;get one byte from chunk
exp2_lp:  move.b  d0,(a1)       ;and repeat *this* Byte D6 times
          adda.w  d1,a1 
          exg     d1,d7 
          dbf     d6,exp2_lp 

weiter:   cmpa.l  a2,a1         ;end of picture data ?
          bcs     expand        ;No, continue

          bne     abort         ;Hu ? Something's wrong!
          addq.l  #2,a2         ;one more plane
          cmpa.l  a3,a2         ;8(A2) already reached ?
          bcs     nxtplane

          move.l  a0,d0         ;first address after the chunk
          addq.l  #1,d0         ;add 1
          bclr.l  #0,d0         ;and make even
          subi.l  #chunk1,d0    ;calculate absolute size
          cmp.l   size1,d0      ;are they equal ?
          bne     abort         ;No: something's wrong !

          lea     chunk2,a0     ;decompress color data
          lea     colreg,a1 
          move.w  #596,d7       ;199 lines with 3 palettes = 597 palettes
          clr.w   d0            ;d0: black
nxtregs:  move.w  #13,d6        ;14 colors, color 0 and 15: black
          move.w  (a0)+,d1      ;get control byte from color chunk
          lsr.w   #1,d1         ;least significant bit: don't care
          move.w  d0,(a1)+      ;black one time
inner:    lsr.w   #1,d1         ;test bits from right to left
          bcc     Bit_0         ;set bits show used colors

          move.w  (a0)+,(a1)+   ;get next byte
          dbf     d6,inner
          bra     common        ;loop finished

Bit_0:    move.w  d0,(a1)+      ;get black
          dbf     d6,inner 

common:   move.w  d0,(a1)+      ;most significant bit black, too
          dbf     d7,nxtregs    ;get next set of registers
          suba.l  #chunk2,a0    ;check length
          cmpa.l  size2,a0      ;ok ?
abort:     rts 

*-------------------- Coded for 60 Hz !! ----------------------
new_vbl: 
          tst.w   flock         ;time critical code
          bne     short         ;Yes, then short cut
          move    sr,-(a7)
          ori     #$700,sr      ;disable interrupts

          lea     palette,a4    ;hardware palette
          lea     video_adr,a5  ;video address counter
          lea     delay,a6      ;delay table
          lea     colrs,a3      ;color table
          move.w  #198,d7       ;199 lines
          clr.l   d0            ;clear for later address calculation
wt_low:   tst.b   (a5)          ;video addresse, lowbyte=0 ?
          beq     wt_low        ;wait for the end of VBL

          move.b  (a5),d0       ;lowbyte of video address + buffer
          add.l   d0,a6 
          jmp     (a6)          ;and synchronise

delay:   	NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
 		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
setcolor:  nop
          lea     (a4),a0       ;set a0-a2 to the palette register
          lea     (a4),a1 
          lea     (a4),a2 

          move.l  (a3)+,(a0)+   ;load first picture palette
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 

          move.l  (a3)+,(a1)+   ;load second picture palette
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 

          move.l  (a3)+,(a2)+   ;load third picture palette
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          dbf     d7,setcolor   ;repeat at all 199 times

;one more line
          lea     (a4),a0       ;set A0-A2 to the palette register
          lea     (a4),a1 
          lea     (a4),a2 
          move.l  (a3)+,(a0)+   ;load first picture palette
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 

          move.l  (a3)+,(a1)+   ;load second picture palette
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 

          move.l  (a3)+,(a2)+   ;load third picture palette
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 
          move.l  (a3)+,(a2)+ 

;and oooonce again
          lea     (a4),a0       ;set a0-a2 to the palette register
          lea     (a4),a1 
          lea     (a4),a2 
          lea     -19040(a3),a4 ;go 19040 Bytes back
          nop                   ;(198 lines)
          nop 
          move.l  (a3)+,(a0)+   ;first picture palette
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 
          move.l  (a3)+,(a0)+ 

          move.l  (a3)+,(a1)+   ;second picture palette
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 
          move.l  (a3)+,(a1)+ 

          move.l  (a4)+,(a2)+   ;attention: these are the colors from
          move.l  (a4)+,(a2)+   ;199 lines ago
          move.l  (a4)+,(a2)+ 
          move.l  (a4)+,(a2)+ 
          move.l  (a4)+,(a2)+ 
          move.l  (a4)+,(a2)+ 
          move.l  (a4)+,(a2)+ 
          move.l  (a4)+,(a2)+ 
          move    (a7)+,sr      ;enable interrupts
short:     rts 

picfile:  dc.b    'madonna.spc',0
m_on:     dc.b    8
m_off:    dc.b    18

          section bss
          even

physbase: ds.l    1
rez:      ds.l    1
vbl:      ds.l    1
oldpal:   ds.l    8
header:   ds.l    1
size1:    ds.l    1
size2:    ds.l    1
handle:   ds.w    1

chunk1:   ds.b    $7F7C         ;buffer for picture data
chunk2:   ds.b    $45F6         ;buffer for color data
colreg:   ds.w    16            ;area for color register
colrs:    ds.b    $4A80

         ds.w    200           ;Stack
stack:   ds.w    1
