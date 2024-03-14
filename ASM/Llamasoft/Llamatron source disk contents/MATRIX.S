; opt habs
; section code
; org $f000
; opt o+
; opt o5+
; opt o1+
; opt ow-

*********
*
* MATRIX - 3.5K complete ST game by Yak
*
*********

*		Initialise Y table
*

 move.l #0,-(a7)
 move #$20,-(a7)
 trap #1
 add.l #6,a7
 move.b #0,$ff8260
 move.b #0,$ff8260
 move.l #null,routine
 clr syncreq
 clr flags
 lea ytab,a0	; Get data table position
 clr.l d0	; set offset to zero
 move #199,d1	; do 200 lines
yt_init: move.l d0,(a0)+	; place offset
 add #160,d0		; next line offset
 dbra d1,yt_init	; do all 200 lines

 move.l #game_pal,a0
 jsr setpal 
 move.l #lscreen,d0
 add.l #256,d0
 and.l #$ffff00,d0
 move.l d0,ascreen
 add.l #32256,d0
 move.l d0,bscreen
 add.l #32256,d0
 move.l d0,back_screen
 move.l #mouse_int,-(a7)
 move.l #mouse_pars,-(a7)
 move #1,-(a7)
 clr -(A7)
 trap #14
 add.l #$c,a7
; move.l #old_keyvec+2,a1
; move.l key_vec,(a1)
; move.l #key_handler,a0
; move.l a0,key_vec 
; move.l #hblank,-(a7)
; and.b #$fe,$fffa07
; and.b #$df,$fffa09
; move #1,-(a7)
; move #8,-(a7)
; move #1,-(a7)
; move #31,-(a7)
; trap #14
; add.l #12,a7
 move.l #vblank,$70


 move #$3200,sr
 move.l shipa,a0
 move.l #-500,(a0)
 move.l shipb,a0
 move.l #-500,(a0)
 clr.l score
 clr.l score+4
 move.b #5,lives
 bsr.w make_grid
 move.b #1,udscore
 bsr.w do_ud
 move.l ascreen,d0
 lsr.l #8,d0
 lea $ff8201,a0
 movep.w d0,0(a0)
 movep.w d0,0(a0)
 bra.w res1

restart: move #$3030,tbzap
 move time+2,time
 move #30,afree
 clr.b lfreq
 clr.b snlen
 clr.b segfreq
 clr.b level
 bsr.w slev
 clr.l score
 clr.l score+4
 move.b #5,lives
 bsr.w make_grid
 move.b #1,udscore
 lea dframe,a0
 move #249,d0
prete: clr.l (a0)+
 dbra d0,prete			;clear DC screen
 move #140,ypos
 move #152,xpos
 bsr.w rannum
 and #$03,d0
 add #1,d0
 move d0,zxvel
 bsr.w rannum
 and #1,d0
 add #1,d0
 move d0,zyvel
 lea aliens,a0
 move #1023,d0
clail: clr.l (a0)+
 dbra d0,clail
 move #-1,bulx			;bullet is off
 move.l #game_int,routine

camel: jsr opsprite
 cmp.b #0,lives
 beq.w restarto
 jmp camel

slev: move.b level,d0
 and #3,d0
 ext d0
 lea lcols,a0
 asl #1,d0
 move 0(a0,d0.w),$ff8244
 asl #1,d0
 lea ldata,a0
 lea 0(a0,d0.w),a0
 move.b (a0)+,d0
 move.b level,d1
 asr.b #3,d1
 add.b d1,d0
 move.b d0,speed
 clr.b snlen
 move.b (a0)+,snlen+1
 move.b (a0)+,lfreq+1
 move.b (a0)+,segfreq+1
 bsr.w rannum
 and.b #$1f,d0
 add.b #$20,d0
 move.b d0,tbzap+1
 rts

lcols: dc.w $700,$407,$007,$730
ldata: dc.b 2,6,100,4,3,15,100,2,4,3,50,2,4,10,70,3
;	dc.b 4,10,50,4,6,2,40,3,8,10,50,2,8,7,10,1
restarto: bsr.w opsprite
res1: btst #1,buttons
 bne res1
res2: btst.b #1,buttons
 bne.w restart
 bra res2
ee: rte

make_grid: move.l back_screen,a0
 bsr.w cls
 lea grid1,a0
 move.l back_screen,a1
 move #16,d0
forss: move #10,d1
forss0: move #2,d2
 move.l ascreen,a2
 bsr.w monoplane
 add #8,d1
 cmp #192,d1
 blt forss0
 add #16,d0
 cmp #312,d0
 blt forss
 bsr.w xfrombak
 rts


setpal: lea $ff8240,a1
 move #15,d1
set_loop: move (a0)+,(a1)+
 dbra d1,set_loop
 rts

draw_game:

 bsr.w draw_aliens
 tst bulx
 bmi drag
 move bulx,d0
 move buly,d1
 move #7,d2
 lea bull,a0
 bsr.w monoplane

;
; draw zappers
drag: clr d0
 move yzapp,d1
 lea yzap,a0
 move #7,d2
 bsr.w monoplane
 move #192,d1
 move xzapp,d0
 lea xzap,a0
 bsr.w monoplane
 btst #0,flags
 beq dps 
 move #8,d2
 move #8,d1
 move pipx,d0
; move freecount,d3
; and #4,d3
; asl #2,d3
 lea vbolt1,a0
; lea 0(a0,d3.w),a0
; move d3,-(a7)
dvbol: bsr.w monoplane
 add #8,d1
 cmp #192,d1
 blt dvbol
; move (a7)+,d3
 move zxpos,d0
 move pipy,d1
 lea hbolt1,a0
 bsr.w monoplane
dps:
;
;draw player ship
 btst #1,flags
 beq dusu_ship
 move freecount,d3
 asl #2,d3
 move #7,d2
graet: move xpos,d0
 move ypos,d1
 lea boom,a0
graet1: sub d3,d0
 bsr cmonoplane
 sub d3,d1
 bsr cmonoplane
 add d3,d0
 bsr cmonoplane
 add d3,d0
 bsr cmonoplane
 add d3,d1
 bsr cmonoplane
 add d3,d1
 bsr cmonoplane
 sub d3,d0
 bsr cmonoplane
 sub d3,d0
 bsr cmonoplane
 sub #8,d3
 bmi.w rrts
 sub #1,d2
 bne graet
 rts

cmonoplane: tst d0
 bmi.w rrts
 cmp #304,d0
 bge.w rrts
 tst d1
 bmi.w rrts
 cmp #192,d1
 bge.w rrts
 move d3,-(a7)
 bsr.w monoplane 
 move (a7)+,d3
 rts
dusu_ship: move xpos,d0
 move ypos,d1
 lea ship,a0
 move #4,d2
 jmp monoplane

vblank: movem.l d0-d7/a0-a6,-(a7)
 tst syncreq
 beq vbl_1
 clr syncreq
vbl_1: move.l routine,a0
 jsr (a0)
 movem.l (a7)+,d0-d7/a0-a6
 rte

game_int: sub #1,time
 bpl gint1
 add.b #1,level
 add.b #1,lives
 cmp.b #9,lives
 blt rushh
 move.b #8,lives
rushh: move.b #1,udscore
 bsr.w slev 
 move time+2,time
gint1: add #1,freecount
 btst #1,flags
 beq rush
 btst.b #6,freecount+1
 beq rush
 clr freecount
 bclr #1,flags		;life loss
 clr.b buttons
 sub.b #1,lives
 move.b #1,udscore
rush: move freecount,$ff8250
; lea colours,a0
; move freecount,d0
; and #3,d0
; asl #1,d0
; move 0(a0,d0.w),$ff8250
 move oxpos,d0
 move oypos,d1
 bsr.w gdframe2
 clr.b (a1)
 move xpos,d0
 move d0,oxpos
 move ypos,d1
 move d1,oypos
 bsr.w gdframe2
 move.b #-2,(a1)
 btst.b #1,buttons
 beq suppo
 btst #1,flags
 bne suppo
 tst bulx
 bpl suppo
 move ypos,buly
 move xpos,bulx
suppo: tst bulx
 bmi suppo1
 move bulx,d0
 move buly,d1
 bsr.w gdframe2
 clr.b (a1)
 clr.b -1(a1)
 sub #8,buly
 cmp #8,buly
 bge suppo0
 move #-1,bulx			;bullet off at top o' screen
 bra suppo1
suppo0: move bulx,d0
 move buly,d1
 bsr.w gdframe2
 move.b #-1,(a1)		;-1 means 'bullet'
 move.b #-1,-1(a1)
suppo1: bsr.w run_aliens
 btst #0,flags
 beq not_zapping
 add #7,zxpos
 move pipx,d0
 asr #4,d0
 move xpos,d1
 asr #4,d1
 cmp d0,d1
 beq.w winit_shipzap
 move zxpos,d0
 cmp d0,d1
 bne nothit
 move ypos,d1
 asr #4,d1
 move pipy,d2
 asr #4,d2
 cmp d1,d2
 bne nothit
winit_shipzap: bsr.w init_shipzap
 move zxpos,d0
nothit: cmp pipx,d0
 ble gi_0
 bclr #0,flags 
 bsr.w aseek
 beq gi_0		;no aliens left
 move zxpos,d0
 move pipy,d1
 bsr.w make_pod
not_zapping: sub.b #1,tbzap
 bpl gi_0
 move.b tbzap+1,tbzap
 move #8,zxpos
 move xzapp,pipx
 move yzapp,pipy
 bset #0,flags		;turn on zapper
gi_0: move xzapp,d0
 add zxvel,d0
 cmp #295,d0
 blt gi_1
 move #8,d0
gi_1: move d0,xzapp
 move yzapp,d0
 add zyvel,d0
 cmp #184,d0
 blt gi_2
 move #8,d0
gi_2: move d0,yzapp
gi_3: tst.b snlen		;snake started?
 beq slfreq
 sub.b #1,segfreq
 bpl.w rrts
 move.b segfreq+1,segfreq
 sub.b #1,snlen
 bra lama


slfreq: sub.b #1,lfreq
 bpl.w rrts
 move.b lfreq+1,lfreq
 move.b snlen+1,d0
 add.b #3,d0
 ext d0
 cmp afree,d0
 bge.w rrts
 bclr #3,flags
 bsr.w rannum
 btst #0,d0
 beq laba
 bset #3,flags
laba: move.b snlen+1,snlen
lama: bsr.w aseek
mseg: move #16,2(a0)
 move #8,4(a0)
 move.l #seg,6(a0)
 move #5,14(a0)
 clr 18(a0)
 move.b speed,19(a0)
 clr 20(a0)
 move #3,(a0) 
 btst.b #2,level
 beq wwa
 move 18(a0),20(a0)
wwa: btst.b #3,flags
 beq.w rrts
 move #304,2(a0)
 neg 18(a0)
 rts

make_pod: move d0,2(a0)
 move d1,4(a0)
 move.l #pod1,6(a0)
 move #$2020,10(a0)
 move #3,12(a0)
 move #6,14(a0)
 move #1,(a0)
 bsr.w gdframe
 move.b #1,(a1)
 rts

aseek: tst afree
 bne gneek
 clr d2
 rts
gneek: lea aliens,a0
ase: tst (a0)
 beq gse
 lea 64(a0),a0
 bra ase
gse: sub #1,afree
 move #1,d2
 rts

mouse_int: btst #1,flags
 bne.w rrts
 move.b (a0),buttons
 move.b 1(a0),xoff
 move.b 2(a0),yoff
 movem d0-d1,-(a7)
 move.b yoff,d1
 neg.b d1
 ext d1
 move ypos,d0
 add d1,d0
 cmp #80,d0
 bge mint
 move #80,d0
mint: cmp #183,d0
 ble mint2
 move #183,d0
mint2: move d0,ypos
 move.b xoff,d1
 ext d1
 move xpos,d0
 add d1,d0
 cmp #8,d0
 bge mint3
 move #8,d0
mint3: cmp #303,d0
 ble mint4
 move #303,d0
mint4: move d0,xpos
 movem (a7)+,d0-d1
 rts

hblank:
;
; Hblanc routine to maintain d_lists
;
; move colval,$ff8242
; movem.l d1-d2/a1,-(A7)
; move.l colipt,a1
; move (a1)+,colval
; move (a1)+,d1
; add d1,dli_lline+2
;dli_lline: clr d2
;dli_col: move.l a1,colipt
; clr.b $fffa1b
; cmp #200,d2
; bmi cow24
; bclr.b #0,$fffa0f
; movem.l (a7)+,d1-d2/a1
; bclr.b #0,$fffa0f
; rte
;cow24: move.b d1,$fffa21
; move.b #8,$fffa1b
; bclr.b #0,$fffa0f
; movem.l (a7)+,d1-d2/a1
; rte

;key_handler: move #$2500,sr
;old_keyvec: jmp $0


monoplane:
;
;Single-bitplane sprite routine.
;pass a0=address of sprite def
;d0,d1=XY co-ordinates; d2=colour

 movem.l d0-d1/a0,-(a7)
 asl #2,d1
 lea ytab,a4
 move.l 0(a4,d1.w),d1	;get screen offset
 lea 0(a1,d1.w),a4	;get start of screen plot
 move friz,d1		;get vertical DBRA
 move d0,d4		;get copy of X position
 and #$0f,d4		;get shift right count
 asr #1,d0
 and #$1f8,d0
 lea 0(a4,d0.w),a4	;get real screen loke
 move.l a4,d0
 sub.l a1,d0
 move.l d0,(a2)+
monop: clr.l d0
 move (a0)+,d0	;get first data word
 ror.l d4,d0	;shift the data
 move.l d0,d3
 eor.l #-1,d3	;make a mask 
 and d3,(a4)
 and d3,2(a4)
 and d3,4(a4)
 and d3,6(a4)
 swap d3
 and d3,8(a4)
 and d3,10(a4)
 and d3,12(a4)
 and d3,14(a4)	;mask out hole fur data
 btst #0,d2	;plane 1?
 beq not_pl1
 or d0,(a4)	;place the data
 swap d0
 or d0,8(a4)	;place word 2 of data..
 swap d0
not_pl1: btst #1,d2	;plane 2?
 beq not_pl2
 or d0,2(a4)	;place the data
 swap d0
 or d0,10(a4)	;place word 2 of data..
 swap d0
not_pl2: btst #2,d2	;plane 2?
 beq not_pl3
 or d0,4(a4)	;place the data
 swap d0
 or d0,12(a4)	;place word 2 of data..
 swap d0
not_pl3: btst #3,d2	;plane 2?
 beq not_pl4
 or d0,6(a4)	;place the data
 swap d0
 or d0,14(a4)	;place word 2 of data..
 swap d0
not_pl4: lea 160(a4),a4	;next scanline..
 dbra d1,monop
 movem.l (a7)+,d0-d1/a0
 rts		;bobbly doo dah

xfrombak: move.l ascreen,a0
 move #7999,d0
 move.l back_screen,a1
 move.l bscreen,a2
scls4: move.l (a1),(a0)+
 move.l (a1)+,(a2)+
 dbra d0,scls4
 rts

cls: move #7999,d0
cls1: clr.l (a0)+
 dbra d0,cls1
 rts

opsprite: move.l ascreen,a1
 move.l shipa,a2
 bsr.w draw_game
 move.l #-500,(a2)
 tst.b udscore
 beq.w flip
 bsr.w do_ud
flip: tst syncreq
 bne flip 
 move.l ascreen,d0
 lsr.l #8,d0
 lea $ff8201,a0
 movep.w d0,0(a0)
 movep.w d0,0(a0)
 move #1,syncreq
 move #1,d0 
_welp: cmp syncreq,d0
 beq _welp
 move.l shipb,a0
xals: move.l (a0)+,d0
 bmi xale
 move.l bscreen,a1
 add.l d0,a1
 move.l back_screen,a2
 add.l d0,a2			;area to undraw
 move #7,d0
xals1: move #3,d1
xals2: move.l (a2)+,(a1)+	;undraw
 dbra d1,xals2			;16 bytes
 lea 144(a1),a1
 lea 144(a2),a2
 dbra d0,xals1			;8 lines of sprite
 bra xals

xale: move.l ascreen,d4
 move.l bscreen,ascreen
 move.l d4,bscreen
 move.l shipa,d4
 move.l shipb,shipa
 move.l d4,shipb
null: rts

do_ud: move.l back_screen,a0
 move.l a0,a1
 move #319,d0
csa: clr.l (a0)+
 dbra d0,csa
 lea score,a3
 move #7,d3
 move #20,d0
 move #0,d1
 move #8,d2
; move #3,friz
xscor: lea numbers,a0
 move.b (a3)+,d4
 ext d4
 asl #4,d4
 lea 0(a0,d4.w),a0
 movem.l d3/a3,-(a7)
 move.l bscreen,a2
 bsr.w monoplane
 movem.l (a7)+,d3/a3
 add #16,d0
 dbra d3,xscor
; move #7,friz
 move #170,d0
 clr d1
 move #4,d2
 lea ship,a0
 move.b lives,d3
 ext d3
 sub #1,d3
 bmi fifc
difcon: move d3,-(a7)
 bsr.w monoplane
 add #16,d0
 move (a7)+,d3
 dbra d3,difcon
 
fifc: move.l ascreen,a0
 move.l bscreen,a2
 move #319,d0
tsc: move.l (a1),(a2)+
 move.l (a1)+,(a0)+
 dbra d0,tsc

 clr.b udscore
 rts

scorer: lea score,a4
 add.b d1,0(a4,d0.w)
resig: cmp.b #10,0(a4,d0.w)
 blt scora1
 sub.b #10,0(a4,d0.w)
 sub #1,d0
 bmi scora1
 add.b #1,0(a4,d0.w)
 bra resig 
scora1: move.b #1,udscore
 rts

rannum: move seed,d0
 mulu #1509,d0
 add #41,d0
 move d0,seed
rrts: rts

run_aliens: lea aliens,a0
 move #30,d7
r_als: tst (a0)
 bne g_al
n_als: lea 64(a0),a0
 dbra d7,r_als
 rts
g_al: lea avex,a1
 move (a0),d0
 sub #1,d0
 asl #2,d0
 move.l 0(a1,d0.w),a1
 jsr (a1)
 bra n_als

draw_aliens: lea aliens,a3
 move #30,d7
r_alsd: tst (a3)
 bne g_ald
n_alsd: lea 64(a3),a3
 dbra d7,r_alsd
 rts
g_ald: move.l 6(a3),a0
 move 2(a3),d0
 move 4(a3),d1
 move 14(a3),d2
 movem.l d7/a3,-(A7)
 bsr.w monoplane
 movem.l (a7)+,d7/a3
 bra n_alsd

runrok: bsr.w hit_ship
 bpl rrok
 cmp.b #-1,(a1)
 bne.w akill
 move #-1,bulx
rrok: move 4(a0),d0
 add #4,d0
 cmp #192,d0
 bge.w akill
 move d0,4(a0)
 bra.w rp1

init_shipzap: btst #1,flags
 bne.w rrts
 clr freecount
 bset #1,flags
 rts

hit_ship: bsr.w gdframe
 tst.b (a1)
 bpl.w rrts
 cmp.b #-2,(a1)
 bne.w tend
 move.l a1,-(a7)
; bsr.w akill
 bsr.w init_shipzap
 move.l (a7)+,a1
 move.b #-2,(a1) 
tend: tst.b (a1)
 rts

runpod: bsr.w hit_ship
 bpl.w okok
 cmp.b #-1,(a1)
 bne.w akill
 move bulx,d0
 move buly,d1
 bsr.w gdframe2
 clr.b (a1)		
 move #-1,bulx
 sub.l #16,6(a0)
 add #1,12(a0)
 move #7,d0
 move #1,d1
 bsr.w scorer
 cmp #4,12(a0)
 bge akill
 rts

okok: clr.b (a1)
 sub.b #1,10(a0)
 bpl rp1
 move.b 11(a0),10(a0)
 add.l #16,6(a0)
 sub #1,12(a0)
 bpl rp1
 move #2,(a0)
 move #7,14(a0)
 move.l #bomb,6(a0)
 rts
 


akill: clr (a0)
 add #1,afree
 rts
rp1: bsr gdframe
 move.b 1(a0),(a1) 
 rts

gdframe: move 4(a0),d2
 and #$f8,d2		;cell # times 8
 move d2,d3
 asl #2,d3		;cell times 32 
 add d2,d3		;cell times 40
 move 2(a0),d2
 asr #4,d2
 add d2,d3		;d3 has grid offset
 lea dframe,a1
 lea 0(a1,d3.w),a1	;a1 has cell #
 rts

gdframe2: and #$f8,d1
 move d1,d2
 asl #2,d2
 add d1,d2
 asr #4,d0
 add d0,d2
 lea dframe,a1
 lea 0(a1,d2.w),a1
 rts

runseg:
runhed: move freecount,d0
 asl #2,d0
 and #$30,d0
 lea seg,a1
 lea 0(a1,d0.w),a1
 move.l a1,6(a0)
 bsr.w hit_ship
 bpl runh1
; cmp.b #-1,(a1)
; beq rh1
; sub #1,afree
rh1: move #6,d0
 move #5,d1
 bsr.w scorer
 move 2(a0),d0
 move 4(a0),d1
 bra.w make_pod

turnX: neg 18(a0)
 tst 20(a0)
 bne runh2		;no line add if nonzero Y veloc
 add #8,4(a0)
runh1:
runh2: move 18(a0),d0
 bmi goleft
 add 2(a0),d0
 cmp #304,d0
 bge turnx
 bra move1
goleft: add 2(a0),d0
 cmp #8,d0
 blt turnx
move1: move d0,2(a0)
 move 20(a0),d0
 bpl godown
 add 4(a0),d0
 cmp #8,d0
 bge move2
bouns: neg 20(a0)
 add 20(a0),d0
 bra move2
godown: add 4(a0),d0
 cmp #184,d0
 ble move2
 tst 20(a0)
 bne bouns
 move 18(a0),d1
 bmi move11
 neg d1
move11: move d1,20(a0)
move2: move d0,4(a0)
 bsr.w gdframe
 cmp.b #1,(a1)
 beq turnx
 bra.w rp1  

;colours: dc.w $700,$760

avex: dc.l runpod,runrok,runhed

grid1:	dc.w	$0300,$0300,$0300,$FFFF,$0300,$0300,$0300,$0300
ship:	dc.w	$2108,$0380,$26C8,$AEEA,$5BB4,$C7C6,$FFFE,$6C6C


bull:	dc.w	$0300,$0780,$0780,$0300,$0300,$0300,$0300,$0300
seg:	dc.w	$03F8,$000E,$3FF3,$FCFF,$FF3F,$CFFC,$7000,$1FC0
	dc.w	$01F8,$067C,$19FC,$0738,$1CE0,$3F98,$3F60,$1F80
	dc.w	$0FC0,$1BE0,$1B28,$1BEC,$0A6C,$03EC,$03F8,$01C0
	dc.w	$1F80,$3E60,$3F98,$1CE0,$0738,$19FC,$06FC,$01F8
numbers:
; dc.w	$1FF8,$000C,$300C,$1FF8,$07C0,$00C0,$00C0,$3FFC
;	dc.w	$3FF0,$3018,$03F0,$3FFC,$3FF8,$000C,$01FC,$3FF8
;	dc.w	$3000,$30C0,$1FFC,$00C0,$3FFC,$3E00,$01FC,$3FF8
;	dc.w	$1FFC,$3000,$3FFC,$1FF8,$3FFC,$003C,$01E0,$0F00
;	dc.w	$1FF8,$3F00,$00FC,$1FF8,$1FF8,$3FFC,$000C,$3FF8

	dc.w	$3FFC,$000C,$303C,$30CC,$330C,$3C0C,$3FFC,$0000
	dc.w	$0F00,$0000,$0300,$0300,$0300,$0300,$0FC0,$0000
	dc.w	$3FFC,$000C,$000C,$1FFC,$1800,$1806,$1FFE,$0000
	dc.w	$3FFC,$000C,$000C,$03FC,$000C,$300C,$3FFC,$0000
	dc.w	$1800,$00C0,$38C0,$3FF8,$00C0,$00C0,$00C0,$0000
	dc.w	$3FFE,$0006,$3000,$3FF8,$000C,$600C,$7FF8,$0000
	dc.w	$1FF8,$000C,$3000,$3FF8,$300C,$300C,$1FF8,$0000
	dc.w	$3FFC,$300C,$0030,$00C0,$0300,$0300,$0300,$0000
	dc.w	$1FF8,$000C,$300C,$1FF8,$300C,$300C,$1FF8,$0000
	dc.w	$1FF8,$000C,$300C,$1FFC,$000C,$700C,$3FF8,$0000




friz: dc.w 7
yzap:	dc.w	$FF80,$3400,$4FE0,$13BF,$13BF,$4FE0,$3400,$FFC0
xzap:	dc.w	$0180,$1188,$03C0,$1668,$3FFC,$2DB4,$381C,$1008
hbolt1:	dc.w	$0000,$0600,$870C,$CD9F,$68F3,$3860,$1000,$0000
vbolt1:	dc.w	$0180,$0700,$0E00,$03C0,$0070,$001C,$0030,$00E0
;vbolt2:	dc.w	$00C0,$0060,$0038,$0060,$03C0,$0F00,$0380,$0180
pod1:	dc.w	$0000,$0000,$0000,$0180,$0180,$0000,$0000,$0000
pod3:	dc.w	$0000,$0180,$03C0,$07E0,$07E0,$03C0,$0180,$0000
pod5:	dc.w	$0810,$05A0,$0240,$07E0,$07E0,$0240,$05A0,$0810
pod6:	dc.w	$0990,$0660,$0660,$0990,$0990,$0660,$0660,$0990
bomb:	dc.w	$1008,$1818,$1DB8,$17E8,$02C0,$03C0,$02C0,$0180
boom:	dc.w	$3006,$0030,$6300,$000C,$3180,$0030,$CC03,$00C0



mouse_pars: dc.l $01000101

time: dc.w 3000,3000
shipa: dc.l shipdat
shipb: dc.l shipdat+4096
xzapp: dc.w 8
yzapp: dc.w 8
seed: dc.w $3141
afree: dc.w 50
key_vec equ $118
xpos: dc.w 0
game_pal: dc.w $0,$007,$700,$707,$070,$077,$770,$777
 dc.b -1
ypos equ xpos+32
buttons equ ypos+2
xoff equ buttons+2
yoff equ xoff+2
ytab equ yoff+2
shipdat equ ytab+800
colval equ shipdat+8192
back_screen equ colval+2
ascreen equ back_screen+4
bscreen equ ascreen+4
syncreq equ bscreen+4
the_business equ syncreq+2
zxvel equ the_business+4
zyvel equ zxvel+2
routine equ zyvel+2
freecount equ routine+4 
flags equ freecount+2
tbzap equ flags+2
zxpos equ tbzap+2
aliens equ zxpos+2
dframe equ aliens+4096
pipx equ dframe+1024
pipy equ pipx+2
bulx equ pipy+2
buly equ bulx+2
oxpos equ buly+2
oypos equ oxpos+2
lfreq equ oypos+2
snlen equ lfreq+2
segfreq equ snlen+2
laddr equ segfreq+2
score equ laddr+4
udscore equ score+8
lives equ udscore+2
level equ lives+2
speed equ level+2
lscreen equ speed+2














