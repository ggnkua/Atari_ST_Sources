;**** This subroutine can be used to 'fixup' the pointers in ****
;**** a rescource file the way AES rscr_load does. The file  ****
;**** must be in standard GEM format (see 'Resource File     ****
;**** Header Information' in the AES manual)                 ****

fixrsc:
 clr.l d0                   ;* enter with addr of rescource in a0 *
 move 20(a0),d0             ;num of objs
 beq .4
 subq #1,d0
 move.l a0,a1
 clr.l d1
 move 2(a0),d1              ;obj offset
 add.l d1,a1                ;address of first obj
.1:
 move 6(a1),d1              ;obj type
 cmp #20,d1                 ;box?
 beq .2
 cmp #25,d1                 ;ibox?
 beq .2
 cmp #27,d1                 ;boxchar?
 beq .2
 move.l 12(a1),d1           ;objspec offset
 add.l a0,d1                ;addr
 move.l d1,12(a1)           ;put back as addr
.2:
 moveq #3,d1
 lea 16(a1),a1              ;x
 move.l hwchar,d4           ;width & height of char
.3:
 swap d4
 move.b (a1),d2             ;pixel offset
 ext.w d2
 move (a1),d3               ;char offset
 ext.w d3
 mulu d4,d3                 ;char times w/h
 add d2,d3                  ;pixel
 move d3,(a1)+              ;put it back
 dbra d1,.3
 dbra d0,.1
.4:
 move 24(a0),d0             ;num of teds
 beq .7
 subq #1,d0
 clr.l d1
 move.l a0,a1
 move 4(a0),d1              ;first ted offset
 add.l d1,a1                ;addr
.5:
 moveq #2,d1
.6:
 move.l (a1),d2
 add.l a0,d2
 move.l d2,(a1)+
 dbra d1,.6
 add.l #16,a1
 dbra d0,.5
.7:
 move 26(a0),d0             ;num of icnblks
 beq .10
 subq #1,d0
 clr.l d1
 move.l a0,a1
 move 6(a0),d1              ;first icnblk offset
 add.l d1,a1                ;addr
.8:
 moveq #2,d1
.9:
 move.l (a1),d2
 add.l a0,d2
 move.l d2,(a1)+
 dbra d1,.9
 add.l #22,a1
 dbra d0,.7
.10:
 move 28(a0),d0             ;num of bitblks
 beq .12
 subq #1,d0
 clr.l d1
 move.l a0,a1
 move 8(a0),d1              ;bitblk offset
 add.l d1,a1                ;addr
.11:
 move.l (a1),d1
 add.l a0,d1
 move.l d1,(a1)
 add.l #14,a1
 dbra d0,.11
.12:
 move 30(a0),d0             ;num of free strings
 beq .14
 subq #1,d0
 clr.l d1
 move.l a0,a1
 move 10(a0),d1             ;string pointer table offset
 add.l d1,a1                ;addr
.13:
 move.l (a1),d1
 add.l a0,d1
 move.l d1,(a1)+
 dbra d0,.13
.14:
 move 32(a0),d0             ;num of free images
 beq .16
 subq #1,d0
 clr.l d1
 move.l a0,a1
 move 16(a0),d1             ;image pointer table
 add.l d1,a1                ;addr
.15:
 move.l (a1),d1
 add.l a0,d1
 move.l d1,(a1)+
 dbra d0,.15
.16:
 move 22(a0),d0             ;num of trees
 beq .18
 subq #1,d0
 clr.l d1
 move.l a0,a1
 move 18(a0),d1             ;tree pointer table offset
 add.l d1,a1                ; plus resource address = tree pointer
;                               table address (this should be stored
;                                in the aes global array 'ap_ptree')
.17:
 move.l (a1),d1             ;fixup tree addresses
 add.l a0,d1
 move.l d1,(a1)+
 dbra d0,.17
.18:
 rts

hwchar: ds.w 1              ;char width & height returned in int_out(1)
hhchar: ds.w 1              ;  & int_out(2) from graf_handle call
