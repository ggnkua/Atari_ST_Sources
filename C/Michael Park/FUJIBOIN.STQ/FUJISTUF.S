*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*                                                                         *
*  FujiStuf!  Written by Xanth Park.  23 Apr 86 (START mod: 27 Jun 86)    *
*                                                                         *
*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     *
*                                                                         *
*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*
*       Assembly stuff for FujiBoink!   5 Apr 86
*
*
globl   _inton
globl   _intoff
globl   _kolors
globl   _kolptr
globl   _fujiy
globl   _fflag
globl   _moov
globl   _kleer
globl   _kolbak

vbvec   =       $70
hbvec   =       $120
keyvec  =       $118
color0  =       $ffff8240
color4  =       color0+8
color5  =       color0+10
color6  =       color0+12
color7  =       color0+14

text

_moov:
~~_moov:
*       my 3-plane mover
*       void moov( src,dst,srcinc,dstinc,i,j )
msrc    =       8
mdst    =       12
msrcinc =       16
mdstinc =       18
mi      =       20
mj      =       22
link    a6,#-2
movem.l d0-d3/a0-a1,-(sp)       ; save regs.
move.l  msrc(a6),a0             ; src ptr
move.l  mdst(a6),a1             ; dst ptr
move.w  msrcinc(a6),d0          ; src increment
asl     #1,d0                   ;  * 2 bytes/word
move.w  mdstinc(a6),d1          ; dst increment
asl     #1,d1                   ;  * 2 bytes/word
move.w  mi(a6),d2               ; i count
move.w  mj(a6),-2(a6)           ; j count (copy)
moo0:
move.w  -2(a6),d3               ; j
moo1:
addq.l  #2,a1           ; dst++ (skip plane 0)
move.w  (a0)+,(a1)+     ; *dst++ = *src++ (plane 1)     
move.l  (a0)+,(a1)+     ; ditto, for planes 2 & 3.
dbra    d3,moo1         ; loop j+1 times...
adda.w  d0,a0           ; src += srcinc
adda.w  d1,a1           ; dst += dstinc
dbra    d2,moo0         ; loop i+1 times...
movem.l (sp)+,d0-d3/a0-a1       ; restore regs...
unlk    a6
rts

_kleer:
~~kleer:
*       my 3-plane zeroer
*       void kleer( dst, dstinc, i, j )
kdst    =       8
kdstinc =       12
ki      =       14
kj      =       16
link    a6,#-2
movem.l d1-d3/a1,-(sp)  ; save regs.
move.l  kdst(a6),a1     ; dst ptr
move.w  kdstinc(a6),d1  ; dst increment
asl     #1,d1           ;  * 2 bytes/word
move.w  ki(a6),d2       ; i count
move.w  kj(a6),-2(a6)   ; j count (copy)
kl0:
move.w  -2(a6),d3       ; j
kl1:
addq.l  #2,a1           ; dst++ (skip plane 0)
clr.w   (a1)+           ; *dst++ = 0 (plane 1)  
clr.l   (a1)+           ; ditto, for planes 2 & 3.
dbra    d3,kl1          ; loop j+1 times...
adda.w  d1,a1           ; dst += dstinc
dbra    d2,kl0          ; loop i+1 times...
movem.l (sp)+,d1-d3/a1  ; restore regs...
unlk    a6
rts

intenA  =       $fffffa07       ; interrupt enable for timer A
intenB  =       $fffffa09       ;     "       "     "    "   B
inservA =       $fffffa0f       ; in-service A
intmaskA =      $fffffa13       ; interrupt mask A
intmaskB =      $fffffa15       ;     "       "  B
contrlB =       $fffffa1b       ; timer B control
dataB   =       $fffffa21       ; timer B data

_inton:
*       enable interrupts
pea     setup   ;       ; call setup
move.w  #38,-(sp)       ;  in supervisor mode
trap    #14
addq.l  #6,sp           ; restore sp
rts

setup:
move.b  intenA,hold1    ; save
move.b  intenB,hold2    ;  68901
move.b  intmaskA,hold3  ;   registers
move.l  hbvec,hold4     ; and
move.l  keyvec,keysave  ;  old
move.l  vbvec,vbsave    ;   vectors

move.l  #mykey,keyvec   ; new keyboard vector
andi.b  #$df,intenB
andi.b  #$fe,intenA
move.l  #hblank,hbvec   ; new hblank vector
ori.b   #$01,intenA
ori.b   #$01,intmaskA
move.l  #vblank,vbvec   ; new vblank vector
rts

_intoff:
*       disable interrupts
pea     restore         ; call restore
move.w  #38,-(sp)       ;  in supervisor mode
trap    #14
addq.l  #6,sp
rts

restore:
move.b  hold1,intenA    ; restore
move.b  hold2,intenB    ;  68901
move.b  hold3,intmaskA  ;   registers
move.l  hold4,hbvec     ; and
move.l  keysave,keyvec  ;  old
move.l  vbsave,vbvec    ;   vectors
rts

mykey:
move    #$2500,sr       ; set IPL to 5
dc.w    $4ef9           ; "JMP"
keysave: ds.l   1       ;  through old vector

hb0:
*       count down yknt scan lines to top of fuji
dec.b   yknt
bnz     hxxx
move.l  newhbvec,hbvec
hxxx:
bclr    #0,inservA      ; clear interrupt
rte

hblank:
*       "real" hblank routine
*       stuffs rainbow colors and fuji side colors
move.l  a0,-(sp)
move.l  ix,a0

move.w  (a0),color4
move.w  (a0)+,color5
move.w  (a0),color6
move.w  (a0)+,color7

move.l  a0,ix
move.l  (sp)+,a0

dec.b   k72     ; after 72 lines
bne     h1      ;  turn off timer B
clr.b   dataB
h1:
bclr    #0,inservA      ; clear interrupt
rte

hback:
*       hblank routine for back of fuji
*       same as above, but no rainbow
move.l  a0,-(sp)
move.l  ix,a0
adda.w  #2,a0   ; skip rainbow color
move.w  (a0),color6
move.w  (a0)+,color7
move.l  a0,ix
move.l  (sp)+,a0
dec.b   k72
bne     hb1
clr.b   dataB
hb1:
bclr    #0,inservA      ; clear interrupt
rte

vblank:
move.b  #0,contrlB
move.b  #1,dataB        ; tell 68901 to generate hbi every scan line
move.b  #8,contrlB
move.b  #72,k72
move.l  #hb0,hbvec
tst.w   _fflag          ; fuji front or back?
beq     v0
move.l  #hblank,newhbvec;  ...front vector
bra     v1
v0:
move.l  #hback,newhbvec ;  ...back vector
v1:
move.w  _kolbak,color4
move.w  _kolbak,color5
move.b  _fujiy+1,yknt   ; yknt
dec.b   yknt            ;  = fujiy - 1
move.l  _kolptr,ix
dc.w    $4ef9           ; "JMP"
vbsave: ds.l    1       ;  through old vector

bss

_fujiy: ds.w    1
_fflag: ds.w    1
ix:     ds.l    1
hold1:  ds.w    1
hold2:  ds.w    1
hold3:  ds.w    1
hold4:  ds.l    1
newhbvec: ds.l  1
yknt    ds.b    1
k72     ds.b    1
end

