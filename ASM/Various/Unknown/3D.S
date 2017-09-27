   a_co1: equ 24 ;
   a_co2: equ 26 ;
   a_mode: equ 36 ;
   a_nil: equ 32  ;
   a_mask: equ 34 ;
   a_x1: equ 38   ;
   a_y1: equ 40   ;
   a_x2: equ 42   ;
   a_y2: equ 44   ;
   a_init: equ $a000 ;
   a_line: equ $a003 ;
   nolines: equ 8 ;
   text
   move.l   4(sp),a0      ;
   lea   stack,sp      ;
   move.l   $c(a0),d0      ;
   add.l   $14(sp),d0      ;
   add.l   $1c(sp),d0      ;
   move.l   d0,-(sp)      ;
   move.l   a0,-(sp)      ;
   move.l   #$4a0000,-(sp)      ;
   trap   #1         ;
   adda   #00000012,sp         ;
   nop                      ;
   pea vector               ;
   pea f_hand               ;
   move.l #0,-(sp)          ;
   trap #14                 ;
   adda #12,sp              ;
   move.w #0,-(sp)          ;fopen
   pea f_nam         ;
   move.w #$3d,-(sp)        ;
   trap #1                  ;
   move.l d0,f_hand         ;
   adda #8,sp             ;
   pea c_tab                ;
   move.l #720,-(sp)        ;
   move.w d0,-(sp)          ;
   move.w #$3f,-(sp)        ;
   trap #1                  ;
   adda #12,sp             ;
   move.w f_hand,-(sp)    ;
   move.w #$3e,-(sp)        ;
   trap #1                  ;
   adda #14,sp            ;
   dc.w a_init              ;
   move.l a0,line_base      ;
   clr.w d7                 ;
   move.w #$ffff,a_mask(a0) ;
   move.w #$ffff,a_nil(a0)  ;
   move.w #2,a_mode(a0)     ;
loop:
   moveq #nolines,d0       ;
   lea c_tab,a5             ;
   lea g_tab,a4             ;
   lea xy_tab,a6            ;
brekna:
   move.w (a4),(a6)         ;
   addi.w #120,(a6)
   move.w 4(a4),4(a6)       ;
   addi.w #120,4(a6)
   move.w 2(a4),d1          ;
   muls 0(a5,d7),d1         ;
   divs #10000,d1           ;
   move.w #100,2(a6)            ;
   sub.w d1,2(a6)          ;
   move.w 6(a4),d1          ;
   muls 0(a5,d7),d1         ;
   divs #10000,d1           ;
   move.w #100,6(a6)          ;
   sub.w d1,6(a6)           ;
   adda #8,a4             ;
   adda #8,a6             ;
   dbf d0,brekna           ;
   move.w #37,-(sp)         ;  Vsync
   trap #14                 ;
   adda #2,sp             ;
   move.l line_base,a6    ;
   cmpi.b #1,d6             ;
   bne draw                 ;
   lea xy_old,a5            ;
   moveq #nolines,d0       ;
radera:
   move.l (a5),a_x1(a6)     ;
   move.l 4(a5),a_x2(a6)    ;
   move.w d0,-(sp)          ;
   dc.w a_line              ;
   move.w (sp)+,d0          ;
   adda #8,a5             ;
   dbf d0,radera           ;
draw:
   moveq #1,d6             ;
   lea xy_tab,a5            ;
   moveq #nolines,d0       ;
rita:
   move.l (a5),a_x1(a6)     ;
   move.l 4(a5),a_x2(a6)    ;
   move.w d0,-(sp)          ;
   dc.w a_line          ;
   move.w (sp)+,d0          ;
   adda #8,a5             ;
   dbf d0,rita             ;
   lea xy_old,a6            ;
   lea xy_tab,a5            ;
   moveq #8,d0             ;
save:
   move.w (a5),(a6)         ;
   move.w 2(a5),2(a6)       ;
   move.w 4(a5),4(a6)       ;
   move.w 6(a5),6(a6)       ;
   adda #8,a5             ;
   adda #8,a6             ;
   dbf d0,save             ;
   addq.w #2,d7             ;
   cmpi.w #720,d7           ;
   bne loop                 ;
   clr.w d7                 ;
   jmp loop                 ;

vector:
   rts     ;
f_nam:
   dc.b "CTAB.DAT",0,0      ;
g_tab:
   dc.w 0,10,100,10     ;
   dc.w 50,10,50,-10    ;
   dc.w 125,10,125,-10  ;
   dc.w 125,10,175,0    ;
   dc.w 175,0,225,10    ;
   dc.w 225,10,225,-10  ;
   dc.w 250,10,250,-10  ;
   dc.w 250,-10,325,-10 ;
   dc.w 325,-10,325,10  ;

xy_old:
   ds.b 72                 ;
line_base
   ds.b 4                   ;
c_tab:
   ds.b 720                 ;
xy_tab:
   ds.b 72                  ;
f_hand:
   ds.b 4                   ;
   ds.b $100                ;
stack:

