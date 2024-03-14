; opt habs
; section code
; org $f000
 opt o+
; opt o5+
; opt o1+
 opt ow-

*********
*
* "Somewhere in Detroit, a dwarf is passing out"
*
*********

*** This version is 1 meg RUDE

* (This version of the source was for a crazy TT remix I did
* one weekend when the posse came to visit and we were all
* out of it; it featured a 40-second bank of digitised
* swearing and would come up with a suitably fruity phrase
* when you got killed sometimes. Far too rude for me to
* release, but you could always make your own).


*		Initialise Y table
*

 move.l #0,-(a7)
 move #$20,-(a7)
 trap #1
 add.l #6,a7

 move.l $42e,a0		;RAMtop
 move.l #$180000,a0
; move.l #$78000,a0	'must be this if half meg used
 sub.l #1000,a0
 move.l a0,smcend

 move.l #hsname,fname
 move.l #hiscores,faddr 
 move.l #160,flength
 jsr lode
 bpl load_ok
 move #39,d0
 lea hiscores,a0
 lea copies,a1
xfhst: move.l (a1)+,(a0)+
 dbra d0,xfhst

load_ok: lea permex,a0
 bsr expand
 move.l smcptr,old_smcptr
 move sr,d1			;if you do it like this
 and #%0101100011100000,d1	;the TT doesn't mind
 or.W #$2700,d1
 move d1,sr

 move.b #0,$ff8260
 move.b #0,$ff8260
 move.l #null,routine
 clr syncreq
 clr flags
 move #0,pmode
; bset #0,pmode
; bset #1,pmode
 lea ytab,a0	; Get data table position
 clr.l d0	; set offset to zero
 move #0,d1	; do 2K lines
yt_init: move.l d0,(a0)+	; place offset
 add #160,d0		; next line offset
 cmp #200,d1
 blt yt1
 sub #160,d0
yt1: add #1,d1
 cmp #2048,d1
 bne yt_init	; do all 200 lines

 move.l #game_pal,a0
 jsr setpal 
 move.l #lscreen,d0
 add.l #256,d0
 and.l #$ffff00,d0
 move.l d0,ascreen
 add.l #32256,d0
 move.l d0,bscreen
 add.l #32256,d0
 move.l #cowlogo+128,back_screen
; move.l d0,back_screen

 move.l #rantab,a4
 move #0,d0
irnd: move.b d0,(a4)+
 add #1,d0
 cmp #512,d0
 bne irnd 
 move.l #rantab,a3
 move #4000,d6	; do 4000 swaps
ini_rnd:
 movem.l d6/a3,-(a7)
 move #$11,-(a7)
 trap #14
 lea 2(a7),a7
 movem.l (a7)+,d6/a3
 move d0,d5
 and #$1ff,d5
 movem.l d5-d6/a3,-(a7)
 move #$11,-(a7)
 trap #14
 add.l #2,a7	; get ran# 2
 movem.l (a7)+,d5-d6/a3
 and #$1ff,d0
 move.b 0(a3,d0.w),d2
 move.b 0(a3,d5.w),0(a3,d0.w)
 move.b d2,0(a3,d5.w)
 dbra d6,ini_rnd


 move #$14,-(a7)
 move #4,-(a7)
 move #3,-(a7)
 trap #13
 lea 6(a7),a7		;set IKBD joy report on



 move #34,-(a7)
 trap #14
 lea 2(a7),a7		;get kbd base
 move.l d0,a0
; move.l 32(a0),old_kbd+2
 move.l #mouse_int,16(a0)	;install our kbd stuff
 move.l #joy_int,24(a0)

; move.l 32(a0),old_kbd+2
; move #$4ef9,old_kbd
 move.l #key_int,32(a0)


; move.l #old_keyvec+2,a1
; move.l key_vec,(a1)
; move.l #key_int,a0
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


 jsr init_sample



 move sr,d1
 and #%0101100011100000,d1
 or.W #$2200,d1
 move d1,sr


 move.l shipa,a0
 move #-500,(a0)
 move.l shipb,a0
 move #-500,(a0)
 move.l ascreen,d0
 lsr.l #8,d0
 lea $ff8201,a0
 movep.w d0,0(a0)
 movep.w d0,0(a0)
 move.l #cowlogo+4,a0
 jsr setpal 
 jsr setfwait

 bsr do_version
;zoko: add #1,$ff8240
; bra zoko
 lea skores,a0
 move #3,d0
clclcl: move.l #0,(a0)+
 dbra d0,clclcl
 move #1,melonman
restart: move.l #rrts,routine
 move #0,_demo
 move old_pmode,pmode
 move old_level,level
 bclr #4,pmode
 move.l #game_pal,a0
 jsr setpal 
 move #0,nowgrunt
 move #4,continues
 move #21,d0
 move #1,d1
 move #2,d2
 move #0,sampri
 jsr sonic


yel1: bsr setup_title
 bsr start_camfield
 move.l old_smcptr,smcptr
 move.l #titex,a0
 bsr expand
 move.l #tit_int,routine
 move.l #tit_draw,the_business
 move #0,freecount
camel: jsr opsprite
; cmp #3000,freecount
 cmp #3000,freecount
 bge do_attract
 btst.b #7,joydat
 beq ckcam
 btst #0,pmode
 beq allaa
 btst #1,pmode
 beq ckcam	;no joyfire in team!
allaa: move #1,joyfire
 bra startit
ckcam: btst.b #7,joydat+1
 beq camel
 move #0,joyfire
startit lea skores,a0
 move #3,d0
clclcl1: move.l #0,(a0)+
 dbra d0,clclcl1
 move.b pmode,d0
 and #1,d0
 move d0,clock
 move #0,level
demres: move.l #rrts,routine
;
;setup game screen


 move.l #titex,a0
 bsr contract
resume: move #0,docopy
 move #50,showmode
 move #0,clock
 move #0,shbase
 move #5,lives
 move #2,pclean
 move #140,ypos
 move #152,xpos
 tst _demo
 bne zooo_
 btst #0,pmode
 beq restart0
 move #132,xpos
zooo_: move #172,xpos2
 move #140,ypos2
restart0: move #20,d0
 move #1,d1
 move #30,d2
 jsr rsonic
 lea levtab,a0
 move #$0f,gcv
 move #0,boon
 move #0,bigfirep
 move #-1,bigfire
; move #1,bigfirep
; move #1,bigfire
g_l: move level,d0
 asl #2,d0
 move.l 0(a0,d0.w),d0
 bne gal0
 move #0,level
 add #1,clock
 add #1,shbase
 bra g_l 
gal0: move.l d0,a0
gali: tst.b (a0)
 bpl not_com			;not a command
 lea cmds,a1
 move.b (a0)+,d0
 ext d0
 neg d0
 sub #1,d0
 asl #2,d0
 move.l 0(a1,d0.w),a1
 jsr (a1)		;execute command
 bra gali

camode: dc.w 0

do_attract: move.l #titex,a0
 bsr contract

 move camode,d0
 add #1,camode
 lea atrax,a0
 and #3,d0
 asl #2,d0
 move.l 0(a0,d0.w),a0
 jmp (a0)

atrax: dc.l astory,ademo,acredits,ademo 

ademo: move level,old_level
 bsr rannum
 and #$3f,d0
 move d0,level
 move pmode,old_pmode
 move #0,pmode
 move #3,_demo
 move #0,brainshld
 move #0,grshld
 move #0,grmode
 bra demres
astory: bsr setfwait
 lea story,a0
 bsr scroll_out
 jsr show_scores
 bra restart 
acredits: bsr setfwait
 lea credits,a0
 bsr scroll_out
 bra restart

old_pmode: dc.w 0
old_level: dc.w 0

scroll:
;
;scroll screen bscreen to ascreen. d0=top of scroll scanline
;d1=bottom of scroll scanline (where buffer will appear); d2=scroll
;slot no., d3=# slots (width of scroll)

 sub d0,d1
 move.l ascreen,a0
 move.l bscreen,a3
 lea ytab,a4
 asl #2,d0
 move.l 0(a4,d0.w),d0
 add.l d0,a3
 add.l d0,a0		;right scanline
 asl #3,d2
 lea 0(a3,d2.w),a3
 lea 0(a0,d2.w),a0	;right slot
 lea 160(a3),a3
doscroll: move d3,d0
 move.l a0,a4
 move.l a3,a5
dosc1: move.l (a5)+,(a4)+
 move.l (a5)+,(a4)+
 dbra d0,dosc1
 lea 160(a0),a0
 lea 160(a3),a3
 sub #1,d1
 bne doscroll
 rts  
 

upd8: dc.w 0
drawscores:
 tst upd8
 beq rrts
 bsr show_wave
 move #0,upd8
 bsr show_lives
 btst #4,pmode
 beq viddal
 lea skores+8,a0
 move #32,d0
 bra show_score
viddal: lea skores,a0
 move #0,d0
 bra show_score

cscore: dc.l skores

doscore:
;
; score d0 points on digit d1, with wrap

 tst _demo
 bne rrts
 move boon,d2
swee0: movem d0-d2,-(a7)
 
swee: lea skores,a0
 btst #4,pmode
 beq katcha
 lea skores+8,a0
katcha: move d1,-(a7)
adka: add.b #1,0(a0,d1.w)
 cmp.b #10,0(a0,d1.w)
 bne nx_dig
 move.b #0,0(a0,d1.w)
 sub #1,d1
 cmp #3,d1	;going to 10,000
 bne rapla
; add #1,lives
 move #3,purq
 movem.l d0-d3/a0-a3,-(a7)
 move #25,d0
 move #1,d1
 move #6,d2
 jsr sonic
 movem.l (a7)+,d0-d3/a0-a3
rapla: tst d1
 bpl adka
 move (a7)+,d1
 bra swee

nx_dig: move (a7)+,d1
 dbra d0,swee
 movem (a7)+,d0-d2
 dbra d2,swee0
 move #1,upd8
 rts

cmds: dc.l setgspeed,setfragstuf,sbrain,stea,sebs,s16t,sgun,ssiz

ssiz: move.b (a0)+,d0
 and #$ff,d0
 move d0,gcadd
 rts

sgun: move.b (a0)+,d0
 asl #8,d0
 and.l #$ff00,d0
 move.l d0,gunvel
 move.b (a0)+,d0
 and #$ff,d0
 move d0,d1
 asl #8,d0
 and #$ff00,d0
 or d0,d1
 move d1,firate
 move.b (a0)+,d0
 and #$ff,d0
 move d0,strngth
 rts

s16t: move.b (a0)+,d0
 and #$ff,d0
 move d0,ts16
 move.b (a0)+,d0
 and #$ff,d0
 move d0,gruntsplit
 rts

sebs: move.b (a0)+,d0
 and #$ff,d0
 move d0,brainshld
 move.b (a0)+,d0
 and #$ff,d0
 move d0,d1
 asl #8,d0
 and #$ff00,d0
 or d0,d1
 move d1,mfr 
 rts

stea: move.b (a0)+,d0
 and #$ff,d0
 ext.l d0
 move.l d0,teapadd
 move.b (a0)+,d0
 and #$ff,d0
 move d0,teapstr
 rts

sbrain: move.b (a0)+,d0 
 move.b d0,d1
 and #$ff,d1
 rol #8,d0
 and #$ff00,d0
 or d1,d0
 move d0,brainfyr
 move.b (a0)+,d0
 and #$f,d0
 move d0,jiv
 move.b (a0)+,d0
 move.b d0,d1
 and #$ff,d1
 rol #8,d0
 and #$ff00,d0
 or d1,d0
 move d0,brainspd
 move.b (a0)+,d0
 move.l a0,-(a7)
 move #21,d0
 move #0,d1
 move #30,d2
 jsr rsonic
 move.l (a7)+,a0
 rts

setgspeed: move.b (a0)+,d0
 move clock,d1
 ext d0
 asl d1,d0
 move d0,tbspdx
 move.b (a0)+,d0
 ext d0
 asl d1,d0
 move d0,tbspdy
 rts 

setfragstuf: move.b (a0)+,d0
 ext d0
 move d0,grmode
 move.b (a0)+,d0
 ext d0
 move d0,grshld
 move.b (a0)+,d0
 ext d0
 move d0,frvel
 move.b (a0)+,d0
 ext d0
 move d0,gksmode
 rts

not_com: move.b (a0)+,_herd
 move.l a0,d0
gal: move.l d0,wptr
 tst docopy
 bne gallo
 move #1,docopy
 bsr set_p2
gallo: move #12,cucha
 btst #4,pmode
 beq gallo1
 btst #1,pmode
 bne gallo1
 move #94,cucha
gallo1: move.l #rrts,routine
; bsr enter_text
 move #14,nbulls
 move #160,xpos
 move #104,ypos
 btst #0,pmode
 beq yel2
 move #140,xpos
 move #180,xpos2
 move #104,ypos2
yel2: move #0,nllama
 move #69,afree
 move #7,nelec
 move #0,aon
 move #0,outcode
 move #0,sirius
 move #50,sirius2
 bsr ibulls
 bsr init_aliens
 bsr ex_wave
 move #0,trailp
 move #0,trailp2
 move #0,clap
 move #0,clap2
 lea trail,a0
 lea trail2,a1
 move #127,d0
itr: move xpos,(A0)
 move ypos,2(a0)
 move #0,4(a0)
 move xpos2,(a1)
 move ypos2,2(a1)
 move #0,4(a1)
 lea 8(a1),a1
 lea 8(a0),a0
 dbra d0,itr
 move baitim+4,baitim+2
 move baitim+2,baitim
 move.l #$0800,baispd
 move #0,fflip
 move #0,bouncy
 move #-1,ngrunts
 move.l back_screen,a0
 bsr cls
 move.l back_screen,a1
 move #2,d2
 move #0,d3
 move #8,d4
 move #318,d5
 move #198,d6
 bsr rect
 move.l back_screen,a1
 lea wasp,a0
 move #159,d0
 move #3,d1
 move #-1,d2
 bsr nyak
 move.l back_screen,scrscrn
 move #0,scrolling
 tst _herd
 beq notherd
 lea herdmes,a0
 bsr print
notherd: tst _demo
 beq not_dd
 lea demes,a0
 bsr print
not_dd: lea msgtab,a0
 move level,d0
sme: cmp #-1,(a0)
 beq smoo
 cmp (a0),d0
 beq domoo
 lea 8(a0),a0
 bra sme
domoo: move.l 4(a0),a0
 bsr print 
smoo: bsr xfrombak
 move #1,upd8
 bsr drawscores
 bsr swap_p2
 move #1,upd8
 bsr drawscores
 bsr swap_p2
 move #0,blight
 move #-1,blightf
 move.l #game_int,routine
 move.l #game_draw,the_business
 move #100,xllama
 move #100,xllama2
camel1: bsr opsprite
 bsr drawscores
 tst outcode
 beq camel1
 move.l #exes,a0
 bsr contract
 cmp #4,outcode
 bne no_warpy
 move.l #rrts,routine
 move.l bscreen,scrscrn
 lea warpmes,a0
 move #0,scrolling
 bsr print
 move #5,d0
 move #0,d1
 move #10,d2
 jsr sonic
tw: tst sampri
 bne tw
 add #5,level
 move #49,d0
 move #4,d1
 bsr doscore
 bra nxlvl

warpmes: dc.b '\g',0,70,'\c1\qwarp five levels',0,'\r\r'
	dc.b '\qbonus 50,000 points',0,'\e'  

herdmes: dc.b '\g',0,175,'\c1\qherd wave',0,'\e'
demes: dc.b '\g',0,185,'\c1\qdemo - press fire',0,'\e'


blight: dc.w 0
blightf: dc.w -1

no_warpy: cmp #3,outcode
 beq restart
 cmp #1,outcode
 beq declyve
 move #10,d0
 move.l #game_int,routine
thisis: move d0,-(a7)
 bsr opsprite
 move (a7)+,d0
 dbra d0,thisis
 move.l #null,routine
nxlvl: tst _demo
 beq wott
 sub #1,_demo
 beq restart
wott: move.l bscreen,a1
 move #0,d7
 move #94,d3
 move #102,d4
 move #224,d5
 move #104,d6
rectl: lea coltab,a0
 move 0(a0,d7.w),d2
; move #1,syncreq
;wfss: tst syncreq
; bne wfss
; movem.l d3-d7/a1,-(a7)
 bsr rect 
; movem.l (a7)+,d3-d7/a1
 add #2,d5
 add #2,d6
 add #2,d7
 and #6,d7
 sub #2,d4
 sub #2,d3
 bpl rectl
 move #0,d7
 move #94,d3
 move #102,d4
 move #224,d5
 move #104,d6
rectl1: clr d2
; movem.l d3-d7/a1,-(a7)
 bsr rect 
; movem.l (a7)+,d3-d7/a1
 add #2,d5
 add #2,d6
 sub #2,d4
 sub #2,d3
 bne rectl1
 
 bra restart0
coltab: dc.w 1,2,11,4

declyve: sub #1,lives
 bne allive
conta: btst #2,pmode
 beq game_over
 bsr swap_p2
 tst lives
 beq game_over
 bsr swap_p2 
allive: bsr regen_wave
 btst #2,pmode
 beq restart00
 bsr swap_p2		;do player 2 stuff
 tst lives
 bne grokki
 bsr swap_p2
grokki: move #50,showmode
 cmp #1,docopy
 bne restart00
 move #2,docopy
 bra restart0		;player 2 initial start is clean
restart00: move.l #oldwave,d0
 bra gal 
ibulls: lea bulls,a0
 move nbulls,d0
ib1: move #-1,(a0)
 lea 16(a0),a0
 dbra d0,ib1
 rts

docopy: dc.w 0
continues: dc.w 4

game_over: sub #1,continues
 beq really_game_over
 move.l bscreen,a0
 move #7999,d0
 move.l back_screen,a1
funi: move.l (a0)+,(a1)+
 dbra d0,funi
 bsr xfrombak
 move #9,contcount
 move #50,contsec
 move.l #drawcont,the_business
 move.l #intcont,routine
kkamel: bsr opsprite
 tst contsec
 bmi kik 
 tst contcount
 bpl kkamel
 move.l back_screen,a0
 move #7999,d0
 move.l bscreen,a1
funi2: move.l (a0)+,(a1)+
 dbra d0,funi2
 bra really_game_over

kik: move #5,lives
 move #5,lives+200
 bra allive

contcount: dc.w 0
contsec: dc.w 0

intcont: sub #1,contsec
 beq nexec
 btst #7,joydat+1
 beq rrts
 move #-1,contsec
 move.l #null,routine
 rts
nexec: move #50,contsec
 sub #1,contcount
 rts
 

setfwait: move #0,hurry
 move #-1,slspd
 move.l #fwait,routine
 rts

hurry: dc.w 0

fwait: btst.b #7,joydat+1
 beq splaye
 move #1,hurry
splaye: tst slspd
 bmi rrts
 sub #1,slspd
 bne rrts
 move slspd+2,slspd
 move.l slptr,a0
 move.b (a0)+,d1
 bne trusa
 move.l slbase,a0
 move.b (a0)+,d1
trusa: and #$ff,d1
 move.b (a0)+,d0
 and #$ff,d0
 move #2,d2
 move.l a0,slptr
 jmp sonic

slspd: dc.l 0
slptr: dc.l 0
slbase: dc.l 0

 rts


drawcont: lea conti,a0
 move #60,d1
 move #150,d0
 move #-1,d2
 bsr yak 
 lea nummies,a0
 move continues,d2
 asl #2,d2
 move.l 0(a0,d2.w),a0
 move #60,d1
 move #200,d0
 move #-1,d2
 bsr yak
 lea nummies,a0
 move contcount,d2
 bmi rrts
 asl #2,d2
 move.l 0(a0,d2.w),a0
 move #90,d1
 move #160,d0
 move #-1,d2
 bra yak

really_game_over: move.l bscreen,a1
 lea gover,a0
 move.l ascreen,a2
 move #160,d0
 move #90,d1
 move #-1,d2
 bsr yak
 move #30,d0
 move #1,d1
 move #8,d2
 jsr sonic	;cue Obi-Wan
wfsa: tst sampri
 bne wfsa
 move #-1,p1_pos
 move #-1,p2_pos
 bsr check_score
 btst #2,pmode
 beq restoo
 bsr swap_p2
 bsr check_score
restoo: bsr show_scores
 move.l #hiscores,faddr
 move.l #160,flength
 move.l #hsname,fname
 tst p1_pos
 bpl dossa
 tst p2_pos
 bmi restart
dossa: move #$80,$ff8606
 move #40,d7 		;this code is to read the
dsd: dbra d7,dsd	;disk controller I hope
 move $ff8604,d0
  move #40,d7 
dsd1: dbra d7,dsd1
 btst #6,d0
 bne restart
 bsr sayv
 bra restart


aon: dc.w 0
la_lec: dc.w 0
maxlec: dc.w 15

update_lex: move maxlec,d7
 move #1,d6
ud_lex: lea aliens,a6
 movem d6-d7,-(a7)
 move la_lec,d0
 and #$0f,d0
 asl #6,d0
 lea 0(a6,d0.w),a6 
 cmp.b #1,1(a6)
 bne nx_lex
 cmp #3,6(a6)
 bne nx_lex
 move #1,6(a6)
 bsr drawlec

; move #-1,d2
; bsr yak
 movem (a7)+,d6-d7
 sub #1,d6
 bpl nxudl
 add #1,la_lec 
 rts

nx_lex: movem (a7)+,d6-d7
nxudl: add #1,la_lec
 dbra d7,ud_lex
 rts


frate: dc.b 8,8
fflip: dc.w 0
xllama2: dc.w 0
fire: tst xllama
 bne rrts
 tst xllama2
 bne rrts
 sub.b #1,frate
 bpl rrts
 move.b frate+1,d0
; btst #0,pmode
; beq ususy
; asl.b #1,d0
ususy: move.b d0,frate
 tst sirius
 beq rrts
 btst #0,pmode
 beq noflip2
; btst #1,pmode
; bne noflip
 eor #1,fflip 
; beq noflip2
noflip: move nbulls,d0
 lea bulls,a0
ffi: tst (a0)
 bmi gotab
 lea 16(a0),a0
 dbra d0,ffi
 rts
gotab: move #60,12(a0)
 btst #0,pmode
 beq gotab1
; tst fflip
; beq gotab1
 move bxv2,4(a0)
 move byv2,6(a0)
 move bch2,8(A0)
 move ypos2,2(a0)
 move xpos2,(a0)
 tst fflip
 beq no_boon
 tst boon
 beq no_boon
; btst #1,pmode
; beq no_boon
 tst d0
 bmi no_boon
 lea bstuff,a1
 move top2,d1
 move.b 48(a1,d1.w),d2
 and #$ff,d2
 beq no_boon
ffi1: tst (a0)
 bmi gotab1
 lea 16(a0),a0
 dbra d0,ffi1
 bra no_boon
gotab1: move #60,12(a0)
 move.b 0(a1,d2.w),d3
 ext d3
 move d3,4(a0)
 move.b 16(a1,d2.w),d3
 ext d3
 move d3,6(a0)
 move.b 32(a1,d2.w),d3
 and #$ff,d3
 move d3,8(A0)
 move ypos2,2(a0)
 move xpos2,(a0)
 tst d0
 bmi no_boon
 move.b 64(a1,d1.w),d2
 and #$ff,d2
 beq no_boon
ffi2: tst (a0)
 bmi gotab2
 lea 16(a0),a0
 dbra d0,ffi2
 bra no_boon
gotab2: move #60,12(a0)
 move.b 0(a1,d2.w),d3
 ext d3
 move d3,4(a0)
 move.b 16(a1,d2.w),d3
 ext d3
 move d3,6(a0)
 move.b 32(a1,d2.w),d3
 and #$ff,d3
 move d3,8(A0)
 move ypos2,2(a0)
 move xpos2,(a0)

no_boon: move #14,d0
 move #0,d1
 move #1,d2
 jsr sonic

noflip2: move nbulls,d0
 lea bulls,a0
ffi12: tst (a0)
 bmi gotab12
 lea 16(a0),a0
 dbra d0,ffi12
 rts

gotab12: move #60,12(a0)
 move bxv,4(a0)
 move byv,6(a0)
 move bch,8(A0)
 move ypos,2(a0)
 move xpos,(a0)
 tst fflip
 bne no_boon2
 tst boon
 beq no_boon2
 tst d0
 bmi no_boon2
 lea bstuff,a1
 move top1,d1
 move.b 48(a1,d1.w),d2
 and #$ff,d2
 beq no_boon2
ffi3: tst (a0)
 bmi gotab3
 lea 16(a0),a0
 dbra d0,ffi3
 bra no_boon2
gotab3: move #60,12(a0)
 move.b 0(a1,d2.w),d3
 ext d3
 move d3,4(a0)
 move.b 16(a1,d2.w),d3
 ext d3
 move d3,6(a0)
 move.b 32(a1,d2.w),d3
 and #$ff,d3
 move d3,8(A0)
 move ypos,2(a0)
 move xpos,(a0)
 tst d0
 bmi no_boon2
 move.b 64(a1,d1.w),d2
 and #$ff,d2
 beq no_boon2
ffi4: tst (a0)
 bmi gotab4
 lea 16(a0),a0
 dbra d0,ffi4
 bra no_boon2
gotab4: move #60,12(a0)
 move.b 0(a1,d2.w),d3
 ext d3
 move d3,4(a0)
 move.b 16(a1,d2.w),d3
 ext d3
 move d3,6(a0)
 move.b 32(a1,d2.w),d3
 and #$ff,d3
 move d3,8(A0)
 move ypos,2(a0)
 move xpos,(a0)

no_boon2:
 move #14,d0
 move #0,d1
 move #1,d2
 jmp sonic

bulrun: lea bulls,a0
 lea aliens,a1
 move nbulls,d1
brun: move (a0),d0
 bmi nxbul
 tst bouncy
 beq nrange
 sub #1,12(a0)
 bmi dbkill
nrange: move #80,d3
 add 4(a0),d0
 cmp #8,d0
 ble bkill
 cmp #312,d0
 bge bkill
 move d0,(a0)
 move #96,d3  
 move 2(a0),d2
 add 6(a0),d2
 cmp #8,d2
 ble bkill
 cmp #192,d2
 bge bkill
 move d2,2(a0)
 bra bdet
nxbul: lea 16(a0),a0
 dbra d1,brun
 rts

bkill: tst bouncy
 bne bouncebull
dbkill: move #-1,(A0)
 bra nxbul

bouncebull: lea bstuff,a4
 move d3,d5
 move 4(a0),d2
 move 6(a0),d3		;get bullet velocities
skb: move.b 32(a4),d4	;get frame #
 lea 1(a4),a4
 and #$ff,d4
 beq skb		;loop if 0
 cmp 8(a0),d4	;check against frame #
 bne skb		;loop until frames match
 cmp.b -1(a4),d2
 bne skb
 cmp.b 15(a4),d3
 bne skb
 move.b -1(a4,d5.w),d5
 and #$ff,d5
 lea bstuff,a4
 move.b 0(a4,d5.w),d2
 ext d2
 move d2,4(a0)
 move.b 16(a4,d5.w),d2
 ext d2
 move d2,6(a0)
 move.b 32(a4,d5.w),d2
 and #$ff,d2
 move d2,8(a0)
 bra nxbul


bdet: move d1,d6
 and #1,d6
 move freecount,d5
 and #1,d5
 cmp d6,d5
 bne nxbul
 move.l a1,a2
 move #69,d6
bdet1: tst (a2)
 bmi nbdet
 tst 16(a2)
 beq nbdet
 tst blight
 beq sakv 
nxxl2: tst (a2)
 bmi nxxl
 tst 16(a2)
 beq nxxl
 move 62(a2),d0
 asl #2,d0
 lea baxvec,a3
 move.l 0(a3,d0.w),a3
 movem.l d1/d6/a0-a2,-(a7)
 jsr (A3)		;appropriate action
 movem.l (a7)+,d1/d6/a0-a2
nxxl: lea 64(a2),a2
 dbra d6,nxxl2
 move #0,BLIGHT
 bra nxbul

sakv: move 2(a2),d3	;alien X
 sub d0,d3
 bpl coli1
 neg d3
coli1: cmp #12,d3
 bgt nbdet	;X out of range
 move 12(a2),d4
 bpl bumma
 move #8,d4
 bra xgrik
bumma: asl #2,d4
 lea objex,a3
 move.l 0(a3,d4.w),a3
 move 4(a3),d4
; asr #1,d4
xgrik: move 4(a2),d3
 sub d2,d3
 bpl coli2
 neg d3
coli2: cmp d4,d3
 bgt nbdet
 tst bigfire
 bpl dracco
 move #-1,(a0)
dracco: move 62(a2),d0
 asl #2,d0
 lea baxvec,a3
 move.l 0(a3,d0.w),a3
 cmp.b #19,1(a2)
 beq not_counted
 move baitim+2,baitim
not_counted: movem.l d6/a2,-(a7)
 jsr (A3)		;appropriate action
 movem.l (a7)+,d6/a2
 bra nxbul
nbdet: lea 64(a2),a2
 dbra d6,bdet1
 bra nxbul

baispd: dc.l $0800

kia: cmp #140,d0
 bge stdkill
 tst bouncy
 bne zboon
 move #8,purq
 bra stdkill 

bokill: move #70,54(a2)
 move #20,56(a2)
 move.l 2(a2),50(a2) 
 move #60,d2
 tst sirius2
 beq zzzzyt
 move #160,d2
zzzzyt: bsr rannum
 cmp d2,d0
 bge kia
 tst bigfire
 bmi zippa
zboon: move #9,purq
 bra stdkill
zippa: move #4,purq	;chance for a Hot power up
stdkill: move 8(a0),d0	;get current bullet frame #
 sub #29,d0
 and #3,d0
 lea bidis,a3
 move.b 0(a3,d0.w),d0
 ext d0
 move d0,20(a2)	;set expansion mode
 move #-1,58(a2)
 cmp.b #1,1(a2)	;check for Electrode
 beq nosubbi	;dont dec alien ctr if true
 sub #1,aon
nosubbi: move (a2),d0
 and #$ff,d0
 asl #2,d0
 lea scors,a3
 lea 0(a3,d0.w),a3
 movem.l d1/a0-a2,-(A7)
 move (a3)+,d0
 move (a3)+,d1
 beq zerdig
 bsr doscore
zerdig: movem.l (a7)+,d1/a0-a2	;score points
 move #2,(a2)
 move #5,6(a2)
 move #0,16(a2)
 move.l #bflash,flashpoint
 movem.l d1/a0,-(A7)
 add #1,killcount
 cmp #200,killcount
 blt dope
 move purq,-(a7)
 move #0,killcount
 move #1,purq
 sub #1,pclean
 bne dope0
 cmp #90,level
 bge no_warp_please_were_British
 move #2,purq
no_warp_please_were_British: move #2,pclean
dope0: bsr power_up
 move (a7)+,purq
 bra zaaa
dope: tst purq
 beq nolove
 bsr power_up
 bra zaaa
nolove: move 60(A2),d0 
 move d0,d1
 and #$ff,d0
 asr #8,d1
 and #$ff,d1
 move #2,d2
 jsr sonic
zaaa: movem.l (a7)+,d1/a0 
 rts

astdkill: bra stdkill

killcount: dc.w 0


put: dc.w 196,240,242,244,246,248,250,256,258,288

power_up: cmp #2,outcode
 beq rrts
 move purq,d0
 clr purq
 sub #1,d0
 move d0,20(a2)
 asl #1,d0
 lea put,a4
 move #200,24(a2) 
 move 0(a4,d0.w),12(a2)
 move #13,6(a2)
 move #-1,58(a2)
 move.l #0,8(a2)
 move #$1c1c,(a2)	;make Love heart
 move 12(a2),22(a2)
 move #0,16(a2)
 add #1,aon
 move #26,d0
 move #2,d1
 move #4,d2
 bra sonic


dopower: move 2(a6),d0
 move 4(a6),d1
 move cxpos,d2
 move cypos,d3
 move #0,d6
 movem d0-d1,-(a7)
 bsr go_fur
 movem (a7)+,d0-d1
 sub d0,d4
 sub d1,d5
 move d4,8(a6)
 move d5,10(a6)
 sub #1,24(a6)
 bpl dopo1
 move #-1,(a6)
 sub #1,aon
 bra omoveit
dopo1: move freecount,d0
 asr #3,d0
 and #1,d0
 add 22(a6),d0
 move d0,12(a6)
 bsr hitllama
 beq omoveit
 sub #1,aon
 move #-1,(a6)
 lea powerups,a5
 move 20(a6),d0
 asl #2,d0
 move.l 0(a5,d0.w),a5
 jmp (a5)
omoveit: move freecount,d0
 asr #1,d0
 btst #0,d0
 bne rrts
 bra moveit



powerups: dc.l inlove,warpy,xlife,hotbul,way3,smbom,invis
	dc.l ibsh,bnus,llakillf

ibsh: move #1,bouncy
 rts
bouncy: dc.w 0

bnus: move #1,d0
 move #4,d1
 bra doscore

invis: move #500,inviso
 move #25,d0
 move #2,d1
 move #10,d2
 bsr sonic
 rts

smbom: move #1,blight
 move.l #smartflasf,flashpoint
 move #16,d0
 move #1,d1
 move #10,d2
 bra sonic

smartflasf: dc.w $777,$666,$555,$444,$333,$222,$111,0

hotbul: move #50,bigfire
 move #1,bigfirep
 rts
bigfirep: dc.w 0

way3: btst #0,pmode
 bne knoboo
 tst aon
 beq knoboo2 
 move #1,boon
knoboo: rts
knoboo2: move #5,purq
 rts
warpy: move #4,outcode
 rts

xlife: add #1,lives
 move #25,d0
 move #2,d1
 move #8,d2
 bsr sonic
 rts

inlove: move #800,luv
 move #28,d0
 move #2,d1
 move #8,d2
 bsr sonic
 rts


setveleq: movem.l d1/a0,-(A7)
 move #13,d0
 move #0,d1
 move #3,d2
 bsr sonic
 movem.l (a7)+,d1/a0
 sub #1,24(a2)
 bmi stdkill
 move 4(a0),d4
 asr #1,d4
 move d4,8(a2)
 move 6(a0),d4
 asr #1,d4
 move d4,10(a2)
 rts 

knokshield: 
 move.l #redfla,flashpoint
 sub #1,24(a2)

 bpl knokbak
 lea ksvex,a4
 move 30(a2),d0
 asl #2,d0
 move.l 0(a4,d0.w),a4
 jmp (a4)

knokbak: move 4(a0),d0
 asr #1,d0
 add 2(a2),d0
 cmp #8,d0
 blt kby
 cmp #312,d0
 bge kby 
 move d0,2(a2)
kby: move 6(a0),d0
 asr #1,d0
 add 4(a2),d0
 cmp #24,d0
 blt kbx
 cmp #184,d0
 bge kbx
 move d0,4(a2)
kbx: move #5,22(a2)		;make flash
baumb: movem.l d0-d2/a0-a2,-(A7)
 move #13,d0
 move #1,d1
 move #3,d2
 bsr sonic
 movem.l (a7)+,d0-d2/a0-a2 
 rts

blobgen: move.l a6,a2
 move #69,d3
 lea aliens,a4
lffa: tst (a4)
 bmi gffa
 lea 64(a4),a4
 dbra d3,lffa
 rts
gffa: move #18,6(a4)
 move #0,14(a4)
 movem d6-d7,-(a7)
 move #0,d3
 move #0,d4
 move.l #$0a00,d6
 move #145,d5
 move #0,d7
 bsr goblob
 move #-1,58(a4)
 move #12,60(a4)
 movem (a7)+,d6-d7
 rts
 
blob4: tst bigfire
 bpl stdkill
 bsr blo4
 bra stdkill
blo4: movem.l d6-d7,-(a7)
 move 4(a0),d4
 move 6(a0),d3
 asl #1,d4
 asl #1,d3
 move #131,d5
 move.l #$0600,d6
 move #0,d7
 bsr ginblob
 move #7,58(a4)
 neg d3
 bsr ginblob
 move #7,58(a4)
 neg d4
 bsr ginblob
 move #7,58(a4)
 neg d3
 bsr ginblob
 move #7,58(a4)
 bra cowy

knock32s: movem.l d0-d2/a0-a2,-(A7)
 move.l #redfla,flashpoint
 move #23,d0
 move #0,d1
 move #4,d2
 bsr sonic
 movem.l (a7)+,d0-d2/a0-a2
 sub.b #1,36(a2)
 bpl knock32
 move.b 37(a2),36(a2)
 lea aliens,a5
 move #69,d0
k32s: cmp #$1e1e,(a5)
 beq xtolamb
 cmp #$1d1d,(a5)
 beq snakill 
 lea 64(a5),a5
 dbra d0,k32s
snakill: move #-1,(a2)
 sub #1,aon
 rts
xtolamb: move.l a0,-(a7)
 move.l a5,a0
 move _herd,-(a7)
 move #1,_herd
 bsr illi
 move (a7)+,_herd
 move.l (a7)+,a0
 rts 
mflash: move #40,24(a2)
 rts 

knock32: move 4(a0),d4
 asl #2,d4
 move d4,20(a2)
 move 6(a0),d4
 asl #2,d4
 move d4,24(a2)
 move #5,48(a2)
; move.l #0,28(a2)
; move.l #0,32(a2)
 bra baumb

blob2: tst bigfire
 bpl stdkill
 bsr blo2
 bra stdkill
blo2: movem.l d6-d7,-(a7)
 move 4(a0),d4
 move 6(a0),d3
 asl #1,d4
 asl #1,d3
 move #127,d5
 move.l #$0400,d6
 move #5,d7
 bsr ginblob
 move #6,58(a4)
 neg d4
 neg d3
 bsr ginblob
 move #6,58(a4)
cowy: movem.l (a7)+,d6-d7
 rts
ginblob: lea aliens,a4
 move #69,d0
gseeka: tst (a4)
 bmi goblob
 lea 64(a4),a4
 dbra d0,gseeka
 rts
goblob: move #15,60(a4)	;sound FX on hit
 move #13,6(a4)		;constant update
 move #0,8(a4)		;dcol
 move #0,10(a4)		;dcol
 move d5,12(a4)	;gbase(8phase)
 move #2,14(a4)	;rez distance
 move #1,16(a4)		;detecol on/off
 move d3,20(a4)
 move #0,22(a4)	;32-bit X and Y speed
 move d4,24(a4)
 move #0,26(a4)
 move.l 2(a2),2(a4)	;get XY position
 move.l d6,28(a4)	;32-bit X and Y acceleration
 move.l d6,32(a4)
 move 12(a4),36(a4)
 move 2(a4),38(a4)	;32-bit position
 move #0,40(a4) 
 bsr rannum
 and #7,d0
 add #3,d0
 move d0,48(a4)
 move 4(a4),42(a4)
 move #0,44(a4)
 move d7,62(a4)		;Explosion Mode=STD.
 move #$1010,(a4)
 add #1,aon
 rts


ksvex: dc.l stdkill,frag4,splat4,shitshower,splat4b,imine
	dc.l ibbul,afirit,mutton,frag8,rok4,rok8
baxvec: dc.l stdkill,knokbak,bokill,knokshield,blob2,blob4
	dc.l knock32,setveleq,knock32s,mflash,stunt
	dc.l flblok,hmandy,hsaf,splitgrunt,kshield,astdkill
	dc.l hitent
bidis: dc.b 0,0,1,-1

raif: dc.w $700,$740,$770,$470,$070,$074,$077,$47,$7,4,0

mutton: move.l a0,-(a7)
 move.l a2,a0
 bsr imm
 sub #1,aon
 move.l (a7)+,a0
 rts

kshield: move.l #raif,flashpoint
 sub #1,36(a2)
 beq stdkill
 movem.l d1/d6/a0-a2,-(a7)
 move #32,d0
 move #3,d1
 move #4,d2
 bsr sonic
 movem.l (a7)+,d1/d6/a0-a2
 rts


splitgrunt: move.l a0,-(a7)
 lea aliens,a0
 move #0,d2
 move #69,d3
splig: tst (a0)
 bmi glig
spneg: lea 64(a0),a0
 dbra d3,splig
 move.l (a7)+,a0
 bra stdkill
glig: move #18,6(a0)
 move #0,14(a0)
 move.l 2(a2),2(a0)
 move 2(a0),38(a0)
 move 4(a0),42(a0)

 move #7,60(a0)	;sound FX on hit
 move fo,12(a0)
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
; move fo,12(a0)	;gbase(8phase)
 move #0,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0000,28(a0)	;32-bit X and Y acceleration
 move.l #$0000,32(a0)
 move #-1,36(a0)
 move #0,40(a0) 
 move #0,48(a0)
 move #0,44(a0)
 move teapstr,46(a0)
 move #10,62(a0)		;Explosion Mode=STUNT
 move #13,6(a0)		;constant update with laser draw
 move 12(a0),8(a0)
 move #$2828,(a0)
 add #1,aon

 move #-1,58(a0)
; bsr rannum
; and #$0f,d0
; sub #$07,d0
; add d0,2(a0)
; bsr rannum
; and #$07,d0
; sub #$03,d0
; add d0,4(a0)
; dbra d2,spneg
splokk: move.l (a7)+,a0
 bra stdkill
 

ibbul: tst bigfire
 bpl stdkill
 lea aliens,a4
 move #69,d0
ibbi: tst (a4)
 bmi gbi
 lea 64(a4),a4
 dbra d0,ibbi
 bra stdkill
gbi: move #18,6(a4)
 move #0,14(a4)
 move.l 2(a2),2(a4)
 move 4(a0),d0
 neg d0
 asr #1,d0
 move d0,8(a4)
 move 6(a0),d0
 neg d0
 asr #1,d0
 move d0,10(a4)
 move 8(a0),d0
 add #163,d0
 move d0,12(a4)
 move #13,6(a4)
 move #0,14(a4)
 move #0,16(a4)
 move #$0f0f,(a4)
 move #-1,58(a4)
 add #1,aon
 bra stdkill


imine: tst bigfire
 bpl stdkill
 lea aliens,a4
 move #69,d3
immi: tst (a4)
 bmi gmi
 lea 64(a4),a4
 dbra d3,immi
 bra stdkill
gmi: move.l 2(a2),2(a4) 
 move #13,6(a4)
 movem d0-d1,-(a7)
nrn: bsr rannum
 move d0,d1
 and #1,d0
 beq nrn 
 btst #1,d1
 beq deer
 neg d0
deer: btst #2,d1
 beq deer2
 move d0,8(a4)
 move #0,10(a4)
 bra deer3
deer2: move #0,8(a4)
 move d0,10(a4) 
 
deer3: movem (a7)+,d0-d1
 move #191,12(a4)
 move.l #0,14(a4)
 move #1,58(a4)
 move #$1b1b,(a4)
 bra stdkill




domine: bsr moveit
 bsr hitllama
 bne llakillf
 rts

buldraw: lea bulls,a3
 move nbulls,d5
buld: move (a3),d0
 bmi nxbd
 move 2(a3),d1
 move 8(a3),d2
 tst bigfire
 bmi longan
 add #158,d2
longan: asl #2,d2
 lea objex,a0
 move.l 0(a0,d2.w),a0
 move #-1,d2
 bsr syak
nxbd: lea 16(a3),a3
 dbra d5,buld
 rts

gapulse: dc.w $777,$707,$617,$527,$437,$347,$257,$167
	dc.w $077,$176,$275,$374,$473,$562,$671,$770
	
quads: dc.l 0
comfreq: dc.w 20

pauseint:
 add.l #$10000,sine2_base
 add.l #$4000,tent_ang
 move.b joydat+1,d0
 btst #7,joydat+1
 bne pa_fip0
 move d0,d1
 and #3,d1
 beq veejay
 move.l #$00001000,d2
 btst #1,d1
 beq pauii
 neg.l d2
pauii: add.l d2,a_inc
veejay: and #$0c,d0
 beq pa_fip
 move.l #$00000200,d2
 btst #3,d0
 beq snagl
 neg.l d2
snagl: add.l d2,r_inc
 bra pa_fip

pa_fip0: move d0,d1
 and #3,d1
 beq veejay1
 move.l #$00001000,d2
 btst #1,d1
 beq pauii1
 neg.l d2
pauii1: add.l d2,sine2_add
veejay1: and #$0c,d0
 beq pa_fip
 move.l #$8000,d2
 btst #3,d0
 beq snagl1
 neg.l d2
snagl1: add.l d2,sine2_amp
 bra pa_fip

pa_fip: move.b #'t',d0
 bsr iskey
 beq pafi1
 move.l #draw_tentacle,the_business
 rts
pafi1: move.b #'g',d0
 bsr iskey
 beq pafi2
 move.l #game_draw,the_business
 rts
pafi2: move.b #'o',d0
 bsr iskey
 beq pi2
 cmp.l #game_draw,the_business
 beq already_game
 move.l #game_draw,the_business
already_game: move.l #game_int,routine
 move.l #0,pauo
 rts
pi2: move.b #'h',d0
 bsr iskey
 beq noknobeither
 tst debo
 bne noknob
 move #1,debo
 bchg #1,$ff820a
 rts

debo: dc.w 0
debo2: dc.w 0
sonon: dc.w 0
noknobeither: move #0,debo
noknob: move.b #'s',d0
 bsr iskey
 beq naaak
 tst debo2
 bne naaak2
 move #1,debo2
 eor #1,sonon
 rts
naaak: move #0,debo2
naaak2:
 move kee,d0
 and #31,d0
 tst sampri
 bne rrts
 cmp #28,d0
 ble pi22
 move #27,d0
pi22: move #1,d1
 move #2,d2
 bra sonic

showmode: dc.w 0

game_int: tst showmode
 beq ganm
 sub #1,showmode
 
ganm: tst inviso
 beq gammm
 sub #1,inviso
 cmp #50,inviso
 bne gammm
 move #25,d0
 move #1,d1
 move #10,d2
 bsr rsonic
gammm: move.b #'p',d0
 bsr iskey
 beq gamin
 move.l #pauseint,routine
; move.l #draw_tentacle,the_business
 bsr rannum
 and #3,d0
 asl #2,d0
 lea pauos,a0
 move.l 0(A0,d0.w),pauo
 rts
gamin: move.b #'x',d0
 bsr iskey
 beq gamm1
 move #3,outcode
 rts
gamm1: tst sirius2
 bne gi11
 sub #1,luv
 sub #1,baitim
 bpl gi11
 move baitim+2,d0
 cmp #16,d0
 ble bunny
 asr #1,d0
bunny: move d0,baitim
 add.l #$0200,baispd
 bra gi11

 move #69,d0
 lea aliens,a0
ibb: tst (a0)
 bmi ibb1
 lea 64(a0),a0
 dbra d0,ibb
 bra gi11
ibb1: move #18,6(a0)
 move #0,14(a0)
 bsr iyy
gi11: tst spbon1
 bmi ataak
 sub #1,spbon1
ataak: tst spbon2
 bmi ataak2
 sub #1,spbon2
ataak2: tst fucking
 beq relations
 sub #1,fucking
 bne relations
 tst rude
 bne relations
 move #17,d0
 move #3,d1
 move #30,d2
 bsr sonic
relations: tst xllama
 beq relations0
 sub #2,xllama
relations0: tst xllama2
 beq real1
 sub #2,xllama2
real1: cmp #-200,xllama
 bne rel1
dec19: move.l #null,routine
 move #1,outcode
 rts
rel1: cmp #-200,xllama2
 beq dec19 
 tst xllama
 bmi rrts
 tst xllama2
 bmi rrts
 tst sirius
 beq rel2
 tst sirius2
 beq aakka
 sub #1,sirius2
aakka: tst aon
 bne rel2
 tst _herd
 beq no_herd
 tst nllama
 bne rel2 
no_herd: cmp #2,outcode
 beq rel2
 move #2,outcode
 move.l #null,routine
 move #20,d0
 move #0,d1
 move #30,d2
 add #1,level
 add #1,nowgrunt
 move nowgrunt,d3
 cmp maxgrunt,d3
 bne sonic
 move #0,nowgrunt
 bra sonic
rel2: btst #0,pmode
 beq rel22
 btst #1,pmode	;Player 2 control=computer if 0
 beq autocam	;camel is controlled by system
 move.b joydat,d0	;get from stick 0
 and #$0f,d0
 btst.b #7,joydat
 bne nosetb2
 lea bstuff,a0
 move.b 0(a0,d0.w),d1
 ext d1
 move.b 16(a0,d0.w),d2
 ext d2
 move.b 32(a0,d0.w),d3
 beq nosetb2
 move d0,top2
; btst #0,pmode
; beq whith
; asl #1,d1
; asl #1,d2
whith: move d1,bxv2
 move d2,byv2
 ext d3
 move d3,bch2
nosetb2: lea mstuff,a0
 move.b 0(a0,d0.w),d1
 ext d1
 btst #1,pmode
 bne nsl
 asl #1,d1
nsl: move d1,vx2
 move.b 16(a0,d0.w),d1
 ext d1
 btst #1,pmode
 bne nsl1
 asl #1,d1
nsl1: move d1,vy2
 move.b 32(a0,d0.w),d1
 beq ltsame2
 ext d1
 move d1,gbase2 
ltsame2: move.b 48(a0,d0.w),d3
 ext d3
 move d3,orie2
 move xpos2,d0
 add vx2,d0
 cmp #15,d0
 blt doy2
 cmp #304,d0
 bge doy2
 move d0,xpos2
doy2: move ypos2,d0
 add vy2,d0
 cmp #18,d0
 blt doxx2
 cmp #188,d0
 bge doxx2
 move d0,ypos2
doxx2: bra rel22


autocam: bsr droyd
 bra rel22
droyd: bsr p2con
 sub #1,comfreq
 bpl rrts
 move #20,comfreq
 move.l #0,quads	;clear quadrant count
 lea quads,a1
 move #69,d0	;max aliens
 lea aliens,a0	
grelly: tst (a0)	;on?
 bmi grelly1	;no
; tst #3,1(a0)	;Grunt?
 tst 16(a0)
 beq grelly1	;no
 move #0,d1	;quad thingy
 move xpos2,d2
 sub 2(a0),d2	;get pos of alien
 bpl gell1
 add #1,d1	;base is 1
gell1: move ypos2,d2
 sub 4(a0),d2	;vpos of alien
 bpl gell2
 add #2,d1
gell2: add.b #1,0(a1,d1.w)	;add quadrant counter
grelly1: lea 64(a0),a0		;next alien
 dbra d0,grelly			;do zem all
 move #0,d0
 move #-1,d1			;set Count and Current Max to 0
 move #0,d2
grelly2: move.b 0(a1,d0.w),d3
 and #$ff,d3
 cmp d2,d3
 ble grelly22
 move d3,d2			;new Max
 move d0,d1			;set CMax
grelly22: add #1,d0
 cmp #4,d0
 bne grelly2			;terms with d1=quadrant #
 tst d1
 bpl icarps
 move #0,d1	;quad thingy
 move xpos2,d2
 sub xpos,d2	;get pos of alien
 bpl gellm1
 add #1,d1	;base is 1
gellm1: move ypos2,d2
 sub ypos,d2	;vpos of alien
 bpl gell2
 add #2,d1

icarps: lea bdvals,a0
 move.b 0(a0,d1.w),d0		;get X val
 ext d0
; btst #0,pmode
; beq mothb
; asl #1,d0
mothb: move d0,bxv2
 move.b 4(a0,d1.w),d0
 ext d0
; btst #0,pmode
; beq mothb1
; asl #1,d0
;mothb1:
 move d0,byv2
 move.b 8(a0,d1.w),d0
 and #$ff,d0
 move d0,bch2
 lea top2s,a0
 move.b 0(a0,d1.w),d0
 and #$ff,d0
 move d0,top2
 rts

bdvals: dc.b -3,3,-3,3,-3,-3,3,3,32,31,31,32
top2s: dc.b 5,9,6,10
bxv2: dc.w 3
byv2: dc.w 3
bch2: dc.w 32
vx2: dc.w 0
vy2: dc.w 0
orie2: dc.w 0
top1: dc.w 0
top2: dc.w 0

rel22: tst _demo
 beq relplayr
 btst #7,joydat+1
 beq nfp
 move #1,_demo
 move #2,outcode
nfp: bsr droyd
 move bxv2,bxv
 move byv2,byv
 move bch2,bch
 move top2,top1
 move gbase2,gbase
 move vx2,vx
 move vy2,vy
 move xpos2,xpos
 move ypos2,ypos
 move top2,d0
 bra donedem
relplayr: move.b joydat+1,d0
 and #$0f,d0
 tst joyfire
 beq usuall
 move.b joydat,d0
 lea bstuff,a0
 move d0,top1
 move.b 0(a0,d0.w),d1
 ext d1
 move.b 16(a0,d0.w),d2
 ext d2
 move.b 32(a0,d0.w),d3
 move.b joydat+1,d0
 tst.b d3
 beq nosetb 
 bra mothb3

usuall: btst.b #7,joydat+1
 bne nosetb
donedem: lea bstuff,a0
 move d0,top1
 move.b 0(a0,d0.w),d1
 ext d1
 move.b 16(a0,d0.w),d2
 ext d2
 move.b 32(a0,d0.w),d3
 beq nosetb
; btst #0,pmode
; beq mothb3
; asl #1,d1
; asl #1,d2
mothb3:
 move d1,bxv
 move d2,byv
 ext d3
 move d3,bch
nosetb: lea mstuff,a0
 tst _demo
 bne ltsame
 move.b 0(a0,d0.w),d1
 ext d1
 move d1,vx
 move.b 16(a0,d0.w),d1
 ext d1
 move d1,vy
 move.b 32(a0,d0.w),d1
 beq ltsame
 ext d1
 move d1,gbase 
ltsame: move.b 48(a0,d0.w),d3
 ext d3
 move trailp,d1
 lea trail,a1
 move ypos,d2
; add #$28*30,d1
 add clap,d1
 move 2(a1,d1.w),yend
 move 0(a1,d1.w),xend

 move trailp,d1
 cmp 2(a1,d1.w),d2
 bne do_trall
 move xpos,d2
 cmp 0(a1,d1.w),d2
 beq no_trall
do_trall: add #8,d1
 and #$3f8,d1
 move xpos,0(a1,d1.w)
 move ypos,2(a1,d1.w)
 move d3,4(a1,d1.w)
 move d1,trailp 
no_trall: btst #0,pmode
 beq no_trall2
 move orie2,d3
 move trailp2,d1
 lea trail2,a1
 move ypos2,d2
 cmp 2(a1,d1.w),d2
 bne do_trall2
 move xpos2,d2
 cmp 0(a1,d1.w),d2
 beq no_trall2
do_trall2: add #8,d1
 and #$3f8,d1
 move xpos2,0(a1,d1.w)
 move ypos2,2(a1,d1.w)
 move d3,4(a1,d1.w)
 move d1,trailp2 
no_trall2: tst _demo
 bne doxx


 move xpos,d0
 add vx,d0
 cmp #15,d0
 blt doy
 cmp #304,d0
 bge doy
 move d0,xpos
doy: move ypos,d0
 add vy,d0
 cmp #18,d0
 blt doxx
 cmp #188,d0
 bge doxx
 move d0,ypos
doxx: bsr fire
 tst bigfire
 bmi gmik
 tst bigfirep
 bne gmik
 sub #1,bigfire
gmik: move #1,blightf
 bsr bulrun
 move #0,gcr
 bsr run_aliens
 move gcr,d0
 asr #1,d0
 cmp #3,d0
 bge mmjm
 move #3,d0
mmjm: move d0,gcv
 bsr make_wave
 rts

clap: dc.w 0
clap2: dc.w 0
vx: dc.w 0
vy: dc.w 0
bxv: dc.w -8
byv: dc.w 0
bch: dc.w 29
gbase: dc.w 1
xend: dc.w 0
yend: dc.w 0
_demo: dc.w 1

bflash: dc.w $777,0
flashpoint: dc.l 0
laflash: dc.w $777,$777,$003,$003,$770,$770,$003,$003
	dc.w $707,$003,$700,3,$070,3,$007,3
 dc.w $777,$777,$003,$003,$770,$770,$003,$003
	dc.w $707,$003,$700,3,$070,3,$007,3
 dc.w $777,$777,$003,$003,$770,$770,$003,$003
	dc.w $707,$003,$700,3,$070,3,$007,3
	dc.w 0

bstuff: dc.b 0,0,0,0,-3,-3,-3,0,3,3,3,0,0,0,0,0
	dc.b 0,-3,3,0,0,-3,3,0,0,-3,3,0,0,0,0,0
	dc.b 0,30,30,0,29,32,31,0,29,31,32,0,0,0,0,0
	dc.b 0,5,10,0,6,4,2,0,9,1,8,0,0,0,0,0
	dc.b 0,9,6,0,5,1,4,0,10,8,2,0,0,0,0,0
	dc.b 0,0,0,0,8,9,10,0,4,5,6,0,0,0,0,0
	dc.b 0,2,1,0,0,6,5,0,0,10,9,0,0,0,0,0

mstuff: dc.b 0,0,0,0,-1,-1,-1,0,1,1,1,0,0,0,0,0
	dc.b 0,-1,1,0,0,-1,1,0,0,-1,1,0,0,0,0,0
	dc.b 0,-9,-13,0,5,5,5,0,1,1,1,0,0,0,0,0
	dc.b 0,2,4,0,0,0,0,0,6,6,6,0,0,0,0,0

xllama: dc.w 0



game_draw: tst showmode
 beq nimmi
 bsr dra_mode
nimmi: bsr buldraw
 bsr draw_aliens
; bsr update_lex
 tst.l pauo
 beq zarjrat
 move.l pauo,a0
 move #160,d0
 move #70,d1
 move #-1,d2
 bsr yak
zarjrat: move xpos,d0
 move ypos,d1
 tst inviso
 beq zarjrat3
 lea invis3,a0
 movem d0-d1,-(a7)
 sub #15,d1
 move #-1,d2
 bsr yak
 movem (a7)+,d0-d1
zarjrat3: move gbase,d2
 bpl xitt
 neg d2
 move d1,d3
yitt: asr #1,d3
 and #3,d3
 add d2,d3
 add cucha,d3
 asl #2,d3
 lea objex,a0
 move.l 0(a0,d3.w),a0 
 move xllama,d3
 beq leadership
 bpl minki
 neg d3
minki: move #1,d2
 move #1,d4
 bsr syak
 neg d4
 bsr syak
 move #0,d4
 bra kayak
  
leadership: move #-1,d2
 tst spbon1
 bmi kayak
 bsr syak
 move xpos,d0
 move spbon1,d1
 lea spbone,a0
 bra kayak
xitt: move d0,d3
 bra yitt

kayak: bsr yak
 btst #0,pmode
 beq rrts
 btst #1,pmode
 bne ispp2
 move freecount,d0
 and #6,d0
 asl #1,d0
 lea droidz,a0
 move.l 0(a0,d0.w),a0
 move xpos2,d0
 move ypos2,d1
 bra leadership2

ispp2: move xpos2,d0
 move ypos2,d1
 tst inviso
 beq zarjrat4
 lea invis3,a0
 movem d0-d1,-(a7)
 sub #15,d1
 move #-1,d2
 bsr yak
 movem (a7)+,d0-d1
zarjrat4:
 move gbase2,d2
 bpl xitt2
 neg d2
 move d1,d3
yitt2: asr #1,d3
 and #3,d3
 add d2,d3
 add cucha2,d3
 asl #2,d3
 lea objex,a0
 move.l 0(a0,d3.w),a0 
 move xllama2,d3
 beq leadership2
 bpl minki2
 neg d3
minki2: move #1,d2
 move #1,d4
 bsr syak
 neg d4
 bsr syak
 move #0,d4
 bra yak
  
leadership2: move #-1,d2
 tst spbon2
 bmi yak
 bsr syak
 lea spbone,a0
 move xpos2,d0
 move spbon2,d1
 bra yak
xitt2: move d0,d3
 bra yitt2


cucha: dc.w 12
cucha2: dc.w 94
xpos2: dc.w 0
ypos2: dc.w 0
gbase2: dc.w 1

joy_int: move.b 1(a0),joydat ;%10001111
 move.b 2(a0),joydat+1	     ; F   RLUD
 rts

joydat: dc.w 0

setpal: lea $ff8240,a1
 move #15,d1
set_loop: move (a0)+,(a1)+
 dbra d1,set_loop
 rts

nelec: dc.w 17
delec: dc.w $0101



ranxy: bsr rannum
 and #$ff,d0
 move d0,d1
 bsr rannum
 and #$1f,d0
 add d0,d1
 add #16,d1
 move xpos,d2
 sub d1,d2
 bpl raa
 neg d2
raa: cmp #32,d2
 blt ranxy
 btst #0,pmode
 beq raah
 move xpos2,d2
 sub d1,d2
 bpl raah1
 neg d2
raah1: cmp #32,d2
 blt ranxy
raah: move d1,2(a0)
doyy: bsr rannum
 and #$7f,d0
 move d0,d1
 bsr rannum
 and #$f,d0
 add d0,d1
 add #18,d1
 move ypos,d2
 sub d1,d2
 bpl raa2
 neg d2
 cmp #32,d2
 blt doyy
raa2: btst #0,pmode
 beq raah3
 move ypos2,d2
 sub d1,d2
 bpl raah4
 neg d2
raah4: cmp #32,d2
 blt doyy
raah3: move d1,4(a0)
 rts


regen_wave: lea oldwave,a0
 move #24,d0
 move #-1,nelec
rgw: move.l #-1,(a0)+
 dbra d0,rgw		;clear out dummy-wave
 lea aliens,a0
 move #69,d0
rgw1: tst.b 1(a0)
 bpl rgw2
rgwn: lea 64(a0),a0
 dbra d0,rgw1
 rts
rgw2: move 58(a0),d1
 bmi rgwn
 move #30,d2
 lea oldwave,a1
rgw3: cmp.b (a1),d1	;same as already recorded?
 bne rgw4
 add.b #1,1(a1)		;increase tally
 bra rgwn
rgw4: tst.b (a1)		;-ve and therefor free?
 bmi rgw5		;yeah
 lea 2(a1),a1 	 
 dbra d2,rgw3
 bra rgwn
rgw5: move.b d1,(a1)
 move.b #0,1(a1)
 bra rgwn		;place nu 1

sirius: dc.w 0
make_wave:
; sub.b #1,delec
; bpl mw1
; move.b delec+1,delec
 tst nelec
 bmi mw2
 sub #1,nelec
 bsr getal
 bsr ranxy
 move #$0c,6(a0)
 move #0,8(a0)
 move #0,10(a0)
 move clex,12(a0)
 move #50,14(a0)
 move #0,16(a0)
 move #$0100,(a0)
 move #0,62(a0)
 move #13,60(a0)
 move #0,50(a0)
 move #-1,58(a0)
 sub #1,afree
 rts
mw2: tst ngrunts
 bmi mw3
 move level,d0
 tst _herd
 beq nhe1 
 bsr rannum
nhe1: and #3,d0
 asl #1,d0
 lea beastab,a3
 move 0(a3,d0.w),beasty
 sub #1,ngrunts
 bsr getal
 move #0,50(a0)
 move atype,58(a0)
 move.l agrunt,a1
 sub #1,afree
 jmp (a1)

illlama: bsr ranxy
illi: move #15,6(a0)
 move.l #0,8(A0)
 move beasty,12(a0)
 move #50,14(a0)
 tst _herd
 beq ill1
 move #2,14(a0)
ill1: move #0,16(a0)
 move.l #0,20(a0)
 move #0,24(a0)
 move #0,62(A0)
 move #9,60(a0)
 move beasty,48(a0)
 move #$0504,(a0)
 add #1,nllama
 add #1,tnllama
 rts

tnllama: dc.w 0
beasty: dc.w 0
beastab: dc.w 35,71,79,87

ifhg: bsr ranxy
 move #12,6(a0)
 bsr rannum
 and #3,d0
 sub #1,d0
 move d0,8(A0)
 bsr rannum
 and #3,d0
 sub #1,d0
 move d0,10(a0)
 move #60,12(a0)
 move #50,14(a0)
 move #0,16(a0)
 move #100,20(a0)
 move #300,22(a0)
 move #$0060,24(a0)
 move #3,26(a0)
 move 12(a0),28(a0)
 move #2,62(a0)
 move #2,60(a0)
 move #$0b0a,(a0)
 add #1,aon
 rts

outcode: dc.w 0
gruntsplit: dc.w 1

gco: dc.w 0

isfhg: bsr ranxy
 move #12,6(a0)
 bsr rannum
 and #3,d0
 sub #1,d0
 move d0,8(A0)
 bsr rannum
 and #3,d0
 sub #1,d0
 move d0,10(a0)
 move #290,12(a0)
 move #50,14(a0)
 move #0,16(a0)
 move #100,20(a0)
 move #30,22(a0)
 move #$0030,24(a0)
 move #20,26(a0)	;# possible hydrants
 move 12(a0),28(a0)
 move #2,62(a0)
 move #2,60(a0)
 move #$0b0a,(a0)
 add #1,aon
 rts

igrunt: bsr ranxy
igru: move #$01,6(a0)
 move #0,8(a0)
 move #0,10(a0)
 move #-1,12(a0)
 move #0,14(a0)
 move #1,16(a0)
 add #1,gco
 move gco,d0
 and #$1f,d0
 move d0,20(a0)
 move grshld,d0
 add shbase,d0
 move d0,24(a0)
 move gksmode,30(a0)
 move gruntsplit,32(a0)
 move grmode,62(a0)
 tst 62(a0)
 bne grampa
 move #3,62(a0)
 move #0,30(a0)
grampa: move #$0303,(a0)
 move #$0309,60(a0)
 move 40(a0),d0
 and #1,d0
 move nowgrunt,d1
 asl #1,d1
 or d0,d1
 asl #2,d1
 lea grunties,a4
 move.l 0(a4,d1.w),44(a0)
 add #1,aon
 rts

ikill: bsr ranxy
 move #12,6(a0)
 move #0,8(a0)
 move #0,10(a0)
 move #43,12(a0)
 move #2,14(a0)
 move #1,16(a0)
 move #$0807,(a0)
 move #-1,20(A0)
 move #0,22(a0) 
 move #1,62(a0)
; add #1,aon
 rts

ibug: bsr ranxy
 move #13,60(a0)	;sound FX on hit
 move #12,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #111,12(a0)	;gbase(8phase)
 move #2,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move #$0e07,(a0)	;DOBUG +rez
 move #-2,20(A0)	;TAQ
 move #0,22(a0)		; 
 move #1,24(a0)		;Shield Factor
 move #$0505,26(a0)		;Motion speed counter
 tst shbase
 beq letitlie
 move #$0202,26(a0) 
letitlie: move 12(a0),28(a0)	;copy of Gbase
 move #1,30(a0)		;action upon killing: 0=explode
 move #3,62(a0)		;Explosion Mode=Knockback + Shield
 add #1,aon
 rts

ibog: move #160,2(a0)
 move #30,4(a0)
 move #9,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #01,10(a0)		;dcol
 move #178,12(a0)	;gbase(8phase)
 move #0,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move #1,20(a0)		;flag: 1=closed
 move #100,24(a0)	;shield
 move #$1818,(a0)	;BOG 
 move #3,30(a0)		;3=SHITSHOWER
 move #3,62(a0)		;Explosion Mode=Shld/Knok
 add #1,aon
 rts

dobog: move #160,2(a6)
 move 20(a6),d0
 add #179,d0
 move d0,12(a6)
 bsr rannum
 cmp #5,d0
 bge dobo1
 eor #1,20(a6)		;open/close pan
dobo1: move 10(a6),d0
 add 4(a6),d0
 cmp #16,d0
 blt rree
 cmp #184,d0
 blt noree
rree: neg 10(a6)
 add 10(a6),d0
noree: move d0,4(a6)
 tst 20(a6)
 beq bog_open
 rts
bog_open: bsr rannum
 and #$ff,d0
 cmp #20,d0
 bge rrts
 move #69,d0
 lea aliens,a0
bogop: tst (a0)
 bmi boggot
 lea 64(a0),a0
 dbra d0,bogop
 rts
boggot: move.l 2(a6),2(a0)
 move #13,6(a0)
 move #0,14(a0)
roddy: bsr rannum
 and #3,d0
 sub #1,d0
 beq roddy
 move d0,8(a0)
 move #181,12(a0)
 bsr rannum
 and #3,d0
 sub #1,d0
 move d0,10(a0)
 move #1,14(a0)
 move #1,16(a0)
 move #-1,58(a0)
 move #0,62(a0)
 move #7,60(a0)
 move #$1919,(a0)
 add #1,aon
 movem.l d1/a0,-(A7)
 move #12,d0
 move #1,d1
 move #4,d2
 bsr sonic
 movem.l (a7)+,d1/a0
 rts

doroll: bsr hitllama
 bne llakill
 move freecount,d0
 asr #2,d0
 and #1,d0
 add #181,d0
 move d0,12(a6)
 bra movedge
 
doshit: bsr hitllama
 bne llakill
 move freecount,d0
 asr #2,d0
 and #3,d0
 add #183,d0
 move d0,12(a6)
 bra moveit


shitshower: movem.l d0-d4/a0-a4,-(a7)
 move #9,d4
 move #69,d3
 lea aliens,a0
shshow: tst (a0)
 bmi gosg1
 lea 64(a0),a0
 sub #1,d3
 bpl shshow
shend: movem.l (a7)+,d0-d4/a0-a4
 move #-1,(a2)
 sub #1,aon
 rts
gosg1: sub #1,d3
 move.l 2(a2),2(a0)
 move #13,6(a0)
roddy1: bsr rannum
 and #3,d0
 sub #1,d0
 beq roddy1
 move d0,8(a0)
 move #183,12(a0)
 bsr rannum
 and #3,d0
 neg d0
 move #12,60(a0)
 move d0,10(a0)
 move #1,14(a0)
 move #1,16(a0)
 move #-1,58(a0)
 move #4,30(a0)		;splat4 + bonus
 move #3,24(a0)
 move #7,62(a0)
 move #$1a1a,(a0)
 add #1,aon
 lea 64(a0),a0
 dbra d4,shshow
 bra shend

ispark: bsr ranxy
iss: move #9,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #175,12(a0)	;gbase(8phase)
 move #0,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move.b #-1,19(a0)	;tell immediate jink
 move.b #10,18(a0)	;jink probability
 move #0,20(a0)		;history pointer
 move.l 2(a0),d0
 move.l d0,22(a0)
 move.l d0,26(a0)
 move.l d0,30(a0)
 move.l d0,34(a0)	;init history
 move #$1717,(a0)	;SPARK 
 move #0,62(a0)		;Explosion Mode=Explode
 add #1,aon
 rts

dospark: bsr hitllama
 bne llakill
 move freecount,d0
 asr #1,d0
 and #3,d0
 add #171,d0
 move d0,12(a6)		;ani
 move 20(a6),d0		;hist ptr
 add #4,d0
 and #12,d0
 move 2(a6),22(a6,d0.w)	;X hist
 move 4(a6),24(a6,d0.w)	;Y hist
 move d0,20(a6)		;place pointer
 tst.b 19(a6)
 bpl dora
 move.b #0,19(a6)
 bra doji
dora: jsr rannum
 move.b 18(a6),d1
 and #$ff,d1
 cmp d1,d0
 bgt noji
doji: eor.b #1,19(a6)	;flip direction
 beq jivert		;0=vertical jink
 move #0,10(a6)
 move jiv,d0
 move cxpos,d1
 sub 2(a6),d1
 bpl doji1
 neg d0
doji1: move d0,8(a6)
 bra noji
jivert: move #0,8(a6)
 move jiv,d0
 move cypos,d1
 sub 4(a6),d1
 bpl doji2
 neg d0
doji2: move d0,10(a6)
noji: bra moveit


ifkil: bsr ranxy
 move #9,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #79,12(a0)	;gbase(8phase)
 move #0,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move #$0e0e,(a0)	;DOBUG 
 move #-1,20(A0)	;TAQ=Priority to Llamas
 move #0,22(a0)		; 
 move #4,24(a0)		;Shield Factor
 move #$0202,26(a0)		;Motion speed counter
 move 12(a0),28(a0)	;copy of Gbase
 move #0,30(a0)		;action upon killing: 0=Explode
 move #2,32(a0)		;mode: Mutate Llamas
 move brainfyr,34(a0)		;Firing try rate
 move #3,62(a0)		;Explosion Mode=Knockback + Shield
 add #1,aon
 rts


ink: bsr ranxy
 move #$0309,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #299,12(a0)	;gbase(8phase)
 move #0,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move #$0e0e,(a0)	; DOBUG 
 move #-1,20(A0)	;TAQ=Priority to Llamas
 move #0,22(a0)		; 
 move #4,24(a0)		;Shield Factor
 move #$0404,26(a0)		;Motion speed counter
 move 12(a0),28(a0)	;copy of Gbase
 move #0,30(a0)		;action upon killing: 0=Explode
 move #3,32(a0)		;mode: make nasty Power Up
 move brainfyr,34(a0)		;Firing try rate
 move #3,62(a0)		;Explosion Mode=Knockback + Shield
 add #1,aon
 rts

brainshld: dc.w 0

ibrane: bsr ranxy
 move #9,60(a0)	;sound FX on hit
 move #12,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #163,12(a0)	;gbase(8phase)
 move #40,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move #$1607,(a0)	;DOBUG +rez
 move #-1,20(A0)	;TAQ=Priority to Llamas
 move #0,22(a0)		; 
 move brainshld,24(a0)		;Shield Factor
 move brainspd,26(a0)		;Motion speed counter
 move 12(a0),28(a0)	;copy of Gbase
 move #0,30(a0)		;action upon killing: 0=Explode
 move #1,32(a0)		;mode: Mutate Llamas
 move brainfyr,34(a0)		;Firing try rate
 move #3,62(a0)		;Explosion Mode=Knockback + Shield
 add #1,aon
 rts

dobrane: sub.b #1,34(a6)
 bpl dobug
 move.b 35(a6),34(a6)
 bsr rannum
 and #$ff,d0
 cmp #4,d0
 bge dobug
 move #69,d0
 lea aliens,a0
lfpr: tst (a0)
 bmi gaag
 lea 64(a0),a0
 dbra d0,lfpr
 bra dobug
gaag: move.l 2(a6),2(a0)
 move #18,6(a0)
 move #0,14(a0)
 bsr iss		;gen a spark
 move #-1,58(a0)
 move #7,d0
 move #1,d1
 move #4,d2
 bsr sonic
 bra dobug

imut: bsr ranxy
imm: move #7,60(a0)	;sound FX on hit
 move #12,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #153,12(a0)	;gbase(8phase)
 move #8,14(a0)		;rez distance
 move #1,16(a0)		;detecol on/off
 move #$1507,(a0)	;DOBUG +rez
 move #-2,20(A0)	;TAQ
 move #0,22(a0)		; 
 move #0,24(a0)		;Shield Factor
 move #$0101,26(a0)		;Motion speed counter
 move 12(a0),28(a0)	;copy of Gbase
 move #2,30(a0)		;action upon killing: 2=SPLAT4
 move #3,62(a0)		;Explosion Mode=Knockback + Shield
 add #1,aon
 rts

domut: move 2(a6),d0
 sub cxpos,d0
 bpl dom1
 neg d0
dom1: move 4(a6),d1
 sub cypos,d1
 bpl dom2
 neg d1
dom2: add d1,d0
 cmp #30,d0
 bgt dobug
 cmp #12,sampri
 beq dobug
 move #12,d2
 move #2,d1
 move #30,d0
 bsr sonic

 bra dobug

iglob1: bsr ranxy
 move #127,d5
 move.l #$0400,d6
 move #5,d7
 bra iggie
iglob2: bsr ranxy
 move #131,d5
 move.l #$0600,d6
 move #0,d7
 bra iggie

iglob: bsr ranxy
 move #123,d5
 move.l #$0200,d6
 move #4,d7
 
iggie: move.l a0,a4
 move.l a0,a2
 move #0,d4
 move #0,d3
 bsr goblob
 move #0,48(a4)
 rts

 move #15,60(a0)	;sound FX on hit
 move #12,6(a0)		;constant update
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #123,12(a0)	;gbase(8phase)
 move #20,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0200,28(a0)	;32-bit X and Y acceleration
 move.l #$0200,32(a0)
 move 12(a0),36(a0)
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move 4(a0),42(a0)
 move #0,44(a0)
 move #0,48(a0)
 move #4,62(a0)		;Explosion Mode=STD.
 move #$1007,(a0)
 add #1,aon
 rts

iyy: bsr ranxy
 move #0,60(a0)	;sound FX on hit
 move #12,6(a0)		;rez then draw
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #137,12(a0)	;gbase(8phase)
 move #20,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l baispd,28(a0)	;32-bit X and Y acceleration
 move.l baispd,32(a0)
 move #$4040,36(a0)	;fire rate
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move #20,48(a0)	;hold time
 move 4(a0),42(a0)
 move #0,44(a0)
 move #7,46(a0)		;max # of projectiles
 move #0,62(a0)		;Explosion Mode=STD
 move #$1307,(a0)
 add #1,aon
 rts

doyiy: move freecount,d0
 asr #2,d0
 and #7,d0
 add #137,d0
 move d0,12(a6)
 tst 48(a6)
 bpl iraq
 sub.b #1,36(a6)
 bpl iraq
 sub #1,46(a6)
 bmi iraq
 move.b 37(a6),36(a6)
 bsr blobgen
 move #11,d0
 move #1,d1
 move #3,d2
 bsr sonic
iraq: bsr hitllama
 bne llakillf
 bra inert_gen

iblokr: bsr ranxy
 move #5,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant update
 bsr rannum
 and #$03,d0
 sub #1,d0
 move d0,8(a0)		;dcol
 bsr rannum
 and #$03,d0
 sub #1,d0
 move d0,10(a0)		;dcol
 move #149,12(a0)	;gbase(8phase)
 move #2,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move #4,24(a0)		;shield F
 move #7,62(a0)		;Explosion Mode=SETVELEQ
 move #$1414,(a0)
 add #1,aon
 rts

doblokr: tst sirius2
 bne rrts
 move freecount,d0
 asr #1,d0
 and #3,d0
 add #149,d0
 move d0,12(a6)
 bsr hitllama
 bne llakill
 bra moveit


ilazr: bsr ranxy
 move #15,60(a0)	;sound FX on hit
 move #2,6(a0)		;constant update with laser draw
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #135,12(a0)	;gbase(8phase)
 move #2,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0400,28(a0)	;32-bit X and Y acceleration
 move.l #$0400,32(a0)
 tst shbase
 beq letitlie1
 move.l #$0800,28(a0) 
 move.l #$0800,32(a0)
letitlie1:
 move #$0020,36(a0)
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move #0,48(a0)
 move 4(a0),42(a0)
 move #0,44(a0)
 bsr rannum
 and #$7f,d0
 add #$30,d0
 move d0,d1
 asl #8,d0
 or d1,d0
 move #$7070,46(a0)
 move #6,62(a0)		;Explosion Mode=KNOCK32
 move #$1111,(a0)
; add #1,aon
 rts

teapstr: dc.w 0
grspl: dc.l 0
gccur: dc.w 0
gcadd: dc.w $40

iftee: move #0,d0
 move #224,d4
 move #20,d5
 move #1,d6
 bsr ggb
 move #$0f0f,24(a0)
 move #$2121,(a0)
 rts

itent: move #17,6(a0)
 move.l #0,8(a0)
 move #326,12(a0)
 move #0,14(a0)
 move #1,16(a0)
 move #$2828,20(a0)
 move #50,22(a0)
 move #160,2(a0)
 move #100,4(a0)
 move #$041e,60(a0)
 move #17,62(a0)
 move #$2b2b,(a0)
 add #1,aon
 rts

hitent: move.l #raif,flashpoint
 movem.l d0-d2/a0-a2,-(a7)
 move #30,d0
 move #4,d1
 move #4,d2
 bsr sonic
 movem.l (a7)+,d0-d2/a0-a2
 sub #1,22(a2)
 bpl rrts
 move #18,6(a2)		;turn off tentie
 move #150,20(a2)
 move #$0404,22(a2)
 move #$2c2c,(a2)	;xform into XXXGEN
 rts 

sharpstrobe: dc.w $777,1,$777,0

xxxgen: sub.b #1,22(a6)
 bpl rrts
 move.b 23(a6),22(a6)
 move.l #sharpstrobe,flashpoint
 move #17,d0
 move #3,d1
 move #10,d2
 bsr sonic
 sub #1,20(a6)
 bpl xxxg1
 move #-1,(a6)
 sub #1,aon
 rts
xxxg1: bsr getal
 bpl rrts
 move #-1,58(a0)
 move #0,16(a0)
 move #13,12(a0)
 bsr rannum
 ext d0
 add #160,d0
 move d0,2(a0)
 bsr rannum
 ext d0
 asr #1,d0
 add #100,d0
 move d0,4(a0)
 move #327,12(a0)
 move #$0303,20(a0)
 move #$2d2d,(a0)
 add #1,aon
 rts

xxxrun: sub.b #1,20(a6)
 bpl rrts
 move.b 21(a6),20(a6)
 move 12(a6),d0
 add #1,d0
 cmp #330,d0
 beq klx
 move d0,12(a6)
 rts
klx: move #-1,(a6)
 sub #1,aon
 rts  
 

dotent: move.l #$fff00000,a_inc
 move.l #$4000,r_inc
 move.l #$140000,sine2_amp
 move.l #$20000,sine2_add
 tst sirius2
 bne rrts
 bsr hitllama
 bne llakill
 add.l #$10000,sine2_base
 add.l #$4000,tent_ang
 move hedex,2(a6)
 move hedey,4(a6)
 sub.b #1,20(a6)
 bpl rrts
 move.b 21(a6),20(a6)
 move #2,d5
 bsr getal
 bpl rrts
jugme: bsr rannum
 and #7,d0
 move #$1003,d1
 move.l 2(a6),2(a0)
 move #-1,58(a0)
 bsr iis
 bsr nal
 bpl rrts
 dbra d5,jugme  
 rts



hedex: dc.w 0
hedey: dc.w 0

iaro: bsr ranxy
 move #13,6(a0)
 move.l #0,8(a0)
 move #231,12(a0)
 move #0,14(a0)
 move #1,16(a0)
 move #1,22(a0)
 bsr rannum
 and #1,d0
 move d0,24(a0)
 move #0,20(a0)		;Mode: 0=horizontal seek
 move 2(a0),28(a0)
 move #0,30(a0)
 move 4(a0),32(a0)
 move #0,34(a0)		;generate 32bit position
 bsr rannum
 and #1,d0
 add #1,d0
 move d0,36(a0)
 bsr rannum
 asl #8,d0
 move d0,38(a0)		;generate 32bit vel 0-3 
 bsr rannum
 add #1,d0
 asl #4,d0
 move d0,40(a0)		;dcel
 move #11,62(a0)	;GSV #10
 move #$040b,60(a0)
 move #$2222,(a0)
 add #1,aon
 rts

doaro: bsr hitllama
 bne llakill
 tst sirius2
 bne rrts
 tst 26(a6)
 bmi doar11
 move freecount,d0
 asr #1,d0
 and #3,d0
 add #231,d0
 move d0,12(a6)
 sub #1,26(a6)
 rts
doar11: move #232,d1
 tst 20(a6)
 beq doar1
 move #231,d1	;d1 is the gbase and always shall be.
 tst 24(a6)
 bne doup
 add #2,d1
 move.l 32(a6),d2	;position.L
 add.l 36(a6),d2
 swap d2
 cmp #190,d2
 bge uaro
oky: move d2,4(a6)
 swap d2
 move.l d2,32(a6)
 bra earo
doup: move.l 32(a6),d2	;position.L
 sub.l 36(a6),d2
 swap d2
 cmp #16,d2
 bge oky
 bra uaro
doar1: tst 24(a6)
 bne dolf
 add #2,d1
 move.l 28(a6),d2	;position.L
 add.l 36(a6),d2
 swap d2
 cmp #312,d2
 bge uaro
okx: move d2,2(a6)
 swap d2
 move.l d2,28(a6)
 bra earo
dolf: move.l 28(a6),d2	;position.L
 sub.l 36(a6),d2
 swap d2
 cmp #16,d2
 bge okx
 bra uaro
earo: move d1,12(a6)
 move 40(a6),d0
 ext.l d0
 sub.l d0,36(a6)
 bpl rrts
uaro: bsr rannum
 and #1,d0
 add #1,d0
 move d0,36(a6)
 bsr rannum
 asl #8,d0
 move d0,38(a6)		;generate 32bit vel 0-3 
 bsr rannum
 add #1,d0
 asl #4,d0
 move d0,40(a6)		;dcel  
 eor #1,20(a6)
 beq setsgh
 move #0,d0
 move 4(a6),d1
 sub cypos,d1
 bmi uag1
 move #1,d0
uag1: move d0,24(a6)
 rts
setsgh: move #0,d0
 move 2(a6),d1
 sub cxpos,d1
 bmi uag1
 move #1,d0
 bra uag1

igblok: move gccur,d0	;4 blocks, this is degrees
 and #$ff,d0
 move.l #$00020000,grspl
 move #1,tbspdx
 move #1,tbspdy
 move #222,d4
 move #10,d5
 move #1,d6
 bsr ggb
 move #$2020,(a0)
 rts
ggb: move d0,d1
 lea sine,a1
 move.b 0(a1,d1.w),d2	;get X
 ext d2
 asr #1,d2		;+/-64
 add #160,d2
 move d2,2(a0)
 add.b #$40,d1
 move.b 0(a1,d1.w),d2
 ext d2
 asr #1,d2
 add #110,d2
 move d2,4(a0)
 move #13,6(a0)
 move.l #0,8(a0)
 move d4,12(a0)
 move #0,14(a0)
 move #1,16(a0)
 move.b d6,20(a0)
 move.b d0,21(a0)
 move d5,22(a0)
 move #$3030,24(a0)
 move #-1,26(a0)
; move #$2020,(a0)
; move #21,58(a0)
 move #11,62(a0)
 move #8,60(a0)
 move gcadd,d0
 add d0,gccur
nana2: add #1,aon
 rts

doftee: move.b 24(a6),d0
 asr #2,d0
 and #3,d0
 add #224,d0
 tst 26(a6)
 bmi dotee1
 move #228,d0
 sub #1,26(a6)
dotee1: move d0,12(a6)
 cmp.b #5,24(a6)
 bne dotee2
 move #229,d0
 move #2,d1
 move 2(a6),d2
 sub cxpos,d2
 bmi yoke
 neg d1
 add #1,d0
yoke: move #1,d3
 move 4(a6),d2
 sub cypos,d2
 bmi yoke1
 neg d3
yoke1: move d3,d2
 bsr s_makeproj
dotee2: sub.b #1,24(a6)
 bpl dospin
 move.b 25(a6),24(a6)
 bra dospin

dogblok: tst sirius2
 bne rrts
 sub.b #1,24(a6)
 bpl defekta
 move.b 25(a6),24(a6)
 bsr gengrunt
 move #-1,58(a0)
defekta: add.l #$00000040,grspl
 move grspl,tbspdx
 move grspl,tbspdy
 move #222,d0
 tst 26(a6)
 bmi dogb1
 sub #1,26(a6)
 move #223,d0
dogb1: move d0,12(a6)
dospin: move.b 20(a6),d0
 add.b d0,21(a6)
 move.b 21(a6),d0
 and #$ff,d0
 move d0,d1
 lea sine,a1
 move.b 0(a1,d1.w),d2	;get X
 ext d2
 asr #1,d2		;+/-64
 add #160,d2
 move d2,2(a6)
 add.b #$40,d1
 move.b 0(a1,d1.w),d2
 ext d2
 asr #1,d2
 add #110,d2
 move d2,4(a6)

 rts
 
flblok: move #$10,26(a2)
 move.l #redfla,flashpoint
 sub #1,22(a2)
 bmi stdkill
 movem.l d0-d2/a0-a2,-(a7)
 move #4,d0
 move #1,d1
 move #3,d2
 bsr sonic
 movem.l (a7)+,d0-d2/a0-a2
 rts
 

iro: move #280,fo
 bsr itt

 move #$2828,(a0)
 rts

ieyb: move #210,fo
 bra itt
ilik: move #214,fo
 bra itt
iski: move #218,fo
 bra itt
fo: dc.w 0
iteap: move #206,fo
itt: bsr ranxy
 move #7,60(a0)	;sound FX on hit
 move fo,12(a0)
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
; move fo,12(a0)	;gbase(8phase)
 move #0,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0000,28(a0)	;32-bit X and Y acceleration
 move.l #$0000,32(a0)
 move #-1,36(a0)
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move #0,48(a0)
 move 4(a0),42(a0)
 move #0,44(a0)
 move teapstr,46(a0)
 move #10,62(a0)		;Explosion Mode=STUNT
 move #13,6(a0)		;constant update with laser draw
 move 12(a0),8(a0)
 move #$1f1f,(a0)
 add #1,aon
 rts

teapadd: dc.l $00000004

gunvel: dc.l 0
firate: dc.w 0
strngth: dc.w 0

ibgun2: bsr ranxy
 move #2,10(a0)
 move #0,8(a0)		;Bullet veloc
 move #17,4(a0)	;Y pos is base of screen
 move #$0307,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant
 move #296,12(a0)	;gbase
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l gunvel,28(a0)	;32-bit X and Y acceleration
 move.l #$0000,32(a0)
 bra ibgu

ibgun3: bsr ranxy
 move #0,10(a0)
 move #2,8(a0)		;Bullet veloc
 move #8,2(a0)	
 move #$0307,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant
 move #297,12(a0)	;gbase
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0000,28(a0)	;32-bit X and Y acceleration
 move.l gunvel,32(a0)
 bra ibgu



ibgun4: bsr ranxy
 move #0,10(a0)
 move #-2,8(a0)		;Bullet veloc
 move #311,2(a0)	
 move #$0307,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant
 move #295,12(a0)	;gbase
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0000,28(a0)	;32-bit X and Y acceleration
 move.l gunvel,32(a0)
 bra ibgu

ibgun: bsr ranxy
 move #-2,10(a0)
 move #0,8(a0)		;Bullet veloc
 move #190,4(a0)	;Y pos is base of screen
 move #$0307,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant
 move #294,12(a0)	;gbase
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l gunvel,28(a0)	;32-bit X and Y acceleration
 move.l #$0000,32(a0)
ibgu: bsr rannum
 tst 30(a0)
 beq lipglos
 or d0,30(a0)
 bra tthou
lipglos: or d0,34(a0)
tthou: move #0,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move strngth,36(a0)	;shield factor
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move 4(a0),42(a0)
 move #0,44(a0)
 move firate,46(a0)
 move #15,62(a0)		;Explosion Mode=KSHIELD
 move #$2a2a,(a0)
 add #1,aon
 rts

mgun: bsr hitllama
 bne llakill
; bra inert_gen
 sub.b #1,46(a6)
 bpl inert_gen
 move.b 47(a6),46(a6)
 move #298,d0
 move 8(a6),d1
 move 10(a6),d2
 bsr s_makeproj
 bra inert_gen


doro: bsr doteap
 move freecount,d0
 asr #2,d0
 and #3,d0
 add #280,d0
 move d0,12(a6)
 rts


doteap: bsr hitllama
 bne llakill
 move.l teapadd,d0
 add.l d0,28(a6)
 add.l d0,32(a6)
 move 8(a6),d0
 move 2(a6),d1
 sub cxpos,d1
 bpl doti1
 add #1,d0
doti1: tst 36(a6)
 bmi doti2
 add #2,d0
 sub #1,36(a6)
doti2: move d0,12(a6) 
 bra inert_gen

stunt: sub #1,46(a2)
 bmi stdkill
 move.l #redfla,flashpoint
 move 2(a0),d4
 asl #2,d4
 move d4,20(a2)
 move 4(a0),d4
 asl #2,d4
 move d4,24(a2)
 move.l #$0200,28(a2)	;32-bit X and Y acceleration
 move.l #$0200,32(a2)
 move #20,36(a2)
 movem.l d0-d2/a0-a2,-(a7)
 move #7,d0
 move #1,d1
 move #3,d2
 bsr sonic
 movem.l (a7)+,d0-d2/a0-a2
 rts

bsinit: bsr ranxy
 move.l a0,a1		;pointer for following segs
 move #7,d0		;# segs
 move #32,d1
ksek: tst (a1)
 bmi ksek1
 lea 64(a1),a1
 bra ksek
ksek1: move.l 2(a0),2(a1)
 move #13,6(a1)
 move #198,12(a1)
 move #0,14(a1)
 move #1,16(a1)
 move #-1,58(a1)
 move d1,20(a1)
 move #-4,22(a1)
 move #-1,24(a1)
 move #9,62(a1)
 move #$1e1e,(A1)
 lea 64(a1),a1
 sub #4,d1
 dbra d0,ksek
dddk: tst (a1)
 bmi dddk1
 lea 64(a1),a1
 bra dddk
dddk1: move.l 2(a0),2(a1)
 move.l a1,a0

 move #7,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #204,12(a0)	;gbase(8phase)
 move #2,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0800,28(a0)	;32-bit X and Y acceleration
 move.l #$0800,32(a0)
 move #$0404,36(a0)	;head shield factor
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move #0,48(a0)
 move 4(a0),42(a0)
 move #0,44(a0)
 move.l #0,46(a0)
 move #0,8(a0)		;GHistory pointer
 move #$3030,10(a0)
 move #8,62(a0)		;Explosion Mode=KNOCK32s
 move #16,58(a0)
 move #$1d1d,(a0)
 add #1,aon
 lea ghist,a1
 move #63,d0
iggt: move.l 2(a0),(a1)+
 move 12(a0),(a1)+
 lea 2(a1),a1
 dbra d0,iggt
 rts

i16ton: move #160,2(a0)
 move #30,4(a0)
 move #271,12(a0)	;Stp Nd Fiir thingie
 move #13,6(a0)
 move.l #0,8(a0)
 move #0,14(a0)
 move #0,16(a0)	;dcol
 move #30,20(a0)	;Y pos
 move #0,22(a0)
 move.l #0,24(a0)	;Y vel
 move #2,28(a0)		;Mode 2=at rest
 move #$2626,(a0)	;start do16ton
; add #1,aon
 rts

ts16: dc.w 3

ibrolly: bsr ranxy
 move.l #$00020001,8(a0)
 move #272,12(a0)	;Stp Nd Fiir thingie
 move #13,6(a0)
 move #0,14(a0)
 move #0,16(a0)	;dcol
 move #0,20(a0)	;mode=closed
 move #$1010,22(a0)
 move #$2727,(a0)	;start do16ton
 add #1,aon
 rts

dobrolly: tst 20(a6)
 bne rrts
 bsr hitllama
 beq leit
 move #1,20(a6)
 move #273,12(a6)
 sub #1,aon
 rts
leit: bsr moveit
 sub.b #1,22(a6)
 bpl rrts
 move.b 23(a6),22(a6)
 move.l 2(a6),-(a7)
 bsr rannum
 btst #0,d0
 beq dootop
 bsr rannum
 ext d0
 asr #1,d0
 add #100,d0
 move d0,4(a6)
 move #303,2(a6)
aghia: move #274,d0
 move #-1,d1
 move #1,d2
 bsr s_makeproj
 move.l (a7)+,2(a6)
 rts
dootop: bsr rannum
 ext d0
 add #160,d0
 move d0,2(a6)
 move #20,4(a6)
 bra aghia


do16ton: tst sirius2
 bne rrts
 bsr hitllama
 bne llakill
 move freecount,d0
 move ts16,d1
 and d1,d0
 bne doffu
 cmp #1,20(a6)
 beq doffu
 move cxpos,d0
 move #1,d1
 sub 2(a6),d0
 bpl caist
 neg d1
caist: add d1,2(a6)
doffu: tst 28(a6)
 beq cardek

 move cxpos,d0
 sub 2(a6),d0
 bpl dss1
 neg d0
dss1: cmp #16,d0
 bgt rizzl
 move 4(a6),d0
 cmp cypos,d0
 bgt rizzl
 move.l #0,24(a6)
 move #0,28(a6)

rizzl: cmp #2,28(a6)
 beq rrts
do161: tst 28(a6)
 beq cardek
 sub.l #$10000,20(a6)
 cmp #30,20(a6)
 bgt do182
 move #2,28(a6)
do182: move 20(a6),4(a6)
 rts
cardek: move.l 24(a6),d0
 add.l d0,20(a6)
 add.l #$2000,24(a6)
 cmp #184,20(a6)		;*****<<
 blt do182
 move #1,28(a6) 
 move #17,d0
 move #3,d1
 move #5,d2
 bra sonic

ibait: bsr ranxy
 move #284,12(a0)
 move #0,22(a0)
 move #$0202,24(a0)
 move #$0202,26(a0)
 move.l #letha,28(a0)
 move #$3030,34(a0)
 bsr isaf1
 move #$2929,(a0)
 move #0,62(a0)
 move #$0200,60(a0)
 rts

mbait: tst sirius2
 bne rrts
 bsr hitllama
 bne llakill
 move freecount,d0
 asr #2,d0
 and #3,d0
 add #284,d0
 move d0,12(a6)
 bra gsaf

letha: move #9,20(a0)
 move #100,24(a0) 
 move #288,12(a0)
 move #0,14(a0)
 move #0,16(a0)
 move #13,6(a0)
 move #-1,58(a0)
 move.l #0,8(a0)
 move #$1c1c,(a0)	;make Love heart
 move 12(a0),22(a0)
 add #1,aon
 rts
icams: bsr ranxy
 move #275,12(a0)
 move #0,22(a0)	;gofur speed
 move #$0808,24(a0)	;stoptime
 move #$0707,26(a0)	;firerate
 move.l #flr,28(a0)	;init vector for homing rabbits
 move #$8080,34(a0)	;go-time
 bra isaf1

isaf: bsr ranxy
 move #268,12(a0)	;Stp Nd Fiir thingie
 move #0,22(a0)	;gofur speed
 move #$1010,24(a0)	;stoptime
 move #$0808,26(a0)	;firerate
 move.l #iih,28(a0)	;init vector for homing rabbits
 move #$7070,34(a0)	;go-time

isaf1: move #13,6(a0)
 move.l #0,8(a0)
 move #0,14(a0)
 move #1,16(a0)	;dcol
 move #1,20(a0)	;mode

 move 12(a0),32(a0)	;copy of Gbase

 move #-1,36(a0)	;flash time
 move.b #3,60(a0)
 move.b #6,61(a0)
 move #13,62(a0)
 move #$2525,(a0)	;start SAF
 add #1,aon
 rts

hsaf: tst sirius2
 bne rizll
 tst 20(a2)
 bne stdkill	;can kill if in this modus
rizll: move #10,36(a2)
 move 4(a0),d0
 asr #1,d0
 move d0,8(a2)
 move 6(a0),d0
 asr #1,d0
 move d0,10(a2)
 movem.l d0-d2/d6/a0,-(a7)
 move #7,d0
 move #3,d1
 move #4,d2
 bsr sonic
 movem.l (a7)+,d0-d2/d6/a0
 rts

dosaf: tst sirius2
 bne rrts
 bsr hitllama
 bne llakill
 move 32(a6),d1
 move 20(a6),d0
 beq dosaf0
 add #2,d1
 bra dosaf1
dosaf0: tst 36(a6)
 bmi dosaf1
 sub #1,36(a6)
 add #1,d1	;flashin'
dosaf1: move d1,12(a6)	;set Stop or Go frame
gsaf: tst 20(a6)	;check Mode
 beq gsafm		;do Motion Mode
 sub.b #1,26(a6)
 bne snottem
 move.b 27(a6),26(a6)
 move.l 28(a6),a0
 bsr gf
snottem: sub.b #1,24(a6)	;timer for stoptime
 bne rrts
 move.b 25(a6),24(a6)
 move 2(a6),d0
 move 4(a6),d1
 move cxpos,d2
 move cypos,d3
 move 22(a6),d6
 movem d0-d1,-(a7)
 bsr go_fur
 movem (a7)+,d0-d1
 sub d0,d4
 sub d1,d5
 move d4,8(a6)
 move d5,10(a6)	;set Motion Vector
 eor #1,20(a6)
 move #-1,36(a6)
 rts
gsafm: sub.b #1,34(a6)
 bne moveit
 move.b 35(a6),34(a6)
 eor #1,20(a6)
 rts

gf: tst sirius2
 bne rrts
 move.l a0,a1
 lea aliens,a0
 move #69,d0
gf1: tst (a0)
 bmi gf2
 lea 64(a0),a0
 dbra d0,gf1
 rts
gf2: move #18,6(a0)
 move #0,14(a0)
 move.l 2(a6),2(a0)
 jsr (a1)
 move #-1,58(a0)
 rts

flr: move d0,-(a7)
 move #278,d0
 move #-2,d1
 move #0,d2
 bsr makeproj
 move (a7)+,d0
 move.l a0,-(a7)
fip: tst (a0)
 bmi fip2
 lea 64(a0),a0
 dbra d0,fip
 move.l (a7)+,a0
 rts
fip2: move #279,d0
 move #1,d1
 move #0,d2
 bsr makeproj
 move.l (a7)+,a0
 rts

coswap: dc.w 0
_neg: dc.w 0
_x: dc.w 0
_ng: dc.w 0
dx: dc.w 0
dy: dc.w 0
xx: dc.w 0
_d: dc.w 0
incr1: dc.w 0
incr2: dc.w 0
xendu: dc.w 0
yy: dc.w 0

go_fur:
; Pass d0,d1 = position to fire from
; d2,d3 = point of aiming. 
; d6 = speed (step size towards goal)
;
; Routine returns d4,d5 = Updated position (so you can
; save the resultant offset if ewe want) and d6=1 if
; target has been reached.
;
 move #0,coswap ; clear coswap flag
qline2:
 move #-1,_neg	; set _NEG 0
 move d0,_x
 cmp d0,d2
 bpl qnosw
 move #1,_neg
 exg d0,d2		; and swap co-ords
qnosw:
 clr _ng		; NG flag
 move d2,d4
 sub d0,d4
 move d4,dx ; x-difference
 move d3,d5
 sub d1,d5
 bpl qyoke
 move #1,_ng	; set NG flag if y diff is -vo
 move d1,d5
 sub d3,d5
qyoke: move d5,dy ; y-difference
 cmp d4,d5
 bmi qbres4 ; x-diff is greater, so no CSW
 beq qbres4 ; or else, gradient is one
 tst _neg	; anomaly?
 bmi qyoke2
 exg d0,d2	; swap back 
qyoke2:
 exg d0,d1
 exg d2,d3
 move #1,coswap ; set swap flag
 bra qline2 ; go recalculate
qbres4:
 asl #1,d5 ; dy*2
 move d5,incr1 ; incr1=2*dy
 sub d4,d5
 move d5,_d ; d=2*dy-dx
 move dy,d5
 sub dx,d5
 asl #1,d5
 move d5,incr2 ; incr2=2*(dy-dx)
 move d0,xx
 move d1,yy
 move d2,xendu

qbresloop: move xx,d0	; get XX
 move xendu,d1		; get Xend
 cmp d1,d0
 bpl moo_e
moobo:
 add #1,xx		; inc 'xpos'
 add #1,_x
 tst _neg		; _NEG?
 bmi ninn
 sub #2,_x		; update 'real' X
ninn: move _d,d0		; 'd'
 bpl qbres2
 move incr1,d0	; 'incr1'
 add d0,_d
 bra qbres3
qbres2:tst _ng	; 'ng'
 beq qaaa
 sub #1,yy		; 'yy'
 bra qbbb
qaaa: add #1,yy	; 'yy'
qbbb: move incr2,d0	; incr2
 add d0,_d		; 'd'
qbres3:
 dbra d6,qbresloop	; do all Speed iterations
 move #0,d6
mooend:
 move _x,d4
 move yy,d5
 tst coswap
 beq mooe
 exg d4,d5
mooe: rts
moo_e:
 move #1,d4
 move #1,d5
 move #1,d6
 rts


itrn: bsr ranxy
iih: move #260,12(a0)	;Gobbit
itrg: move #13,6(a0)
 move.l #0,8(a0)
 move #0,14(a0)
 move #1,16(a0)	;dcol
 move #0,20(a0)	;vel as shift-up
 move #0,22(a0)	;cuurrent orient: <--
 move #$0120,24(a0)	;Turner timer
 move 12(a0),26(a0)	;copy of Gbase
 move.b #3,60(a0)
 move.b #26,61(a0)
 move #0,62(a0)
 move #$2424,(a0)	;start Turner
 add #1,aon
 rts



istrn: bsr ranxy
 bsr rannum
 and #$07,d0
 move #$0104,d1
iis: move #310,d2
 add d0,d2
 move d2,12(a0)
 move #13,6(a0)
 move.l #0,8(a0)
 move #0,14(a0)
 move #1,16(a0)	;dcol
 move #0,20(a0)	;vel as shift-up
 move d0,22(a0)	;cuurrent orient: <--
 move d1,24(a0)	;Turner timer
 move #310,26(a0)	;copy of Gbase
 move.b #4,60(a0)
 move.b #18,61(a0)
 move #0,62(a0)
 move #$2424,(a0)	;start Turner
 add #1,aon
 rts

dotrn: tst sirius2
 bne rrts
 bsr hitllama
 bne llakill
 sub.b #1,24(a6)
 bmi dooit
 move 22(a6),d1
 bra pFloy
dooit: move.b 25(a6),24(a6)
 move 2(a6),d0
 move 4(a6),d1
 move #0,d2
 sub cxpos,d0
 bpl dotu1
 bset #0,d2
dotu1: sub cypos,d1
 bpl dotu2
 bset #1,d2
dotu2: lea turno,a0
 move.b 0(a0,d2.w),d2	;get Turn offset
 and #$ff,d2		;required vector
 sub 22(a6),d2		;difference - sign is direction of turn
 move d2,d1
 tst d1
 bpl dotu3	;d2=sign, d1=abs val
 neg d1
dotu3: tst d2
 bmi botu1 
 cmp #4,d1
 bge nokikoki
 bra okikoki
botu1: cmp #4,d1	;if >4...
 ble okikoki
nokikoki: neg d2		;is quicker to turn other way
okikoki: move #1,d1
 tst d2
 bpl dotu4
 neg d1
dotu4: add 22(a6),d1
 and #$07,d1	;d1 is next vector
dfuk: move d1,22(a6)
pFloy: move d1,d0
 add 26(a6),d0
 move d0,12(a6)	;right grafik
 lea turndat,a0
 asl #1,d1
 move 0(a0,d1.w),8(a6)
 move 16(a0,d1.w),10(a6)	;right vel
 bra moveit

turno: dc.b 7,5,1,3
turndat: dc.w -1,-1,0,1,1,1,0,-1,0,1,1,1,0,-1,-1,-1

 
mfr: dc.w $3939 

imandy: bsr ranxy	;this is Screaming Mandy
 move #30,60(a0)	;sound FX on hit
 move #13,6(a0)		;constant
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #252,12(a0)	;gbase(8phase)
 move #0,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 bsr rannum
 or #$0300,d0
 and.l #$ffff,d0
 move.l d0,28(a0)	;32-bit X and Y acceleration
 bsr rannum
 or #$0600,d0
 and.l #$ffff,d0
 move.l d0,32(a0)
 move #$1818,36(a0)	;head shield factor
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move #0,48(a0)
 move 4(a0),42(a0)
 move #0,44(a0)
 move.l #0,46(a0)
 move mfr,8(a0)		;Fire rate
 move #12,62(a0)		;Explosion Mode=HMANDY
 move #$2323,(a0)
 add #1,aon
 rts

domandy: bsr hitllama
 bne llakill
 move 2(a6),d0
 move #252,d1
 sub cxpos,d0
 bpl oki_doke
 add #1,d1
oki_doke: move d1,12(a6)
 sub.b #1,8(a6)
 bpl inert_gen
 move.b 9(a6),8(a6)
 move 12(a6),d0
 tst sirius2
 bne rrts
 cmp #50,level
 bge doguided
 sub #252,d0
 beq ft_left
 move #254,d0
 move #1,d1
 bra ft_it
ft_left: move #255,d0
 move #-1,d1
ft_it: move #0,d2
 bsr s_makeproj
 bra inert_gen

doguided: movem.l d0-d7/a0-a6,-(a7)
 sub #252,d0
 beq fleff
 move #4,d0
 bra fuggy
fleff: move #0,d0
fuggy: move #$0004,d1
 bsr getal
 bpl ingen
 move #-1,58(a0)
 move.l 2(a6),2(a0)
 bsr iis
ingen: movem.l (a7)+,d0-d7/a0-a6
 bra inert_gen
 

hmandy: sub.b #1,36(a2)
 beq kmandy
 move.l #kiffa,flashpoint
 movem.l d0-d2/d6/a0,-(a7)
 move #30,d0
 move #3,d1
 move #4,d2
 bsr sonic
 movem.l (a7)+,d0-d2/d6/a0
 rts
kiffa: dc.w $777,0

kmandy: move #-1,(a2)
 sub #1,aon
 move.l #kaffa,flashpoint
 movem.l d0-d2/d6/a0,-(a7)
 move #30,d0
 move #1,d1
 move #6,d2
 bsr sonic
 movem.l (a7)+,d0-d2/d6/a0
 rts

kaffa: dc.w $777,7,$666,7,$555,7,$444,7,$333,7,$222,7,$111,7
 dc.w $770,$707,7,0

bco: dc.w 0

gengrunt: move #60,d0
 lea aliens,a0
bsl: tst (a0)
 bmi bsl1
 lea 64(a0),a0
 dbra d0,bsl
 bra bsm1
bsl1: move.l 2(a6),2(a0)
 move #18,6(a0)
 move #0,14(a0)
 bsr igru
 move #1,58(a0)
bsm1: rts

bsmove: bsr hitllama
 bne llakill
 sub.b #1,10(a6)
 bpl bsm0
 move.b 11(a6),10(a6)
 bsr gengrunt
bsm0: move 8(a6),d0
 asl #3,d0
 lea ghist,a0
 lea 0(a0,d0.w),a0
 move.l 2(a6),(a0)+
 move 12(a6),(a0)+
 add #1,8(a6)
 and #$3f,8(a6)
 move 8(a6),bco
 move #204,d0
 tst 20(a6)
 bpl bsm14
 move #202,d0
bsm14: move freecount,d1
 asr #2,d1
 and #1,d1
 add d0,d1
 move d0,12(a6)
 bra inert_gen

fomove: bsr hitllama
 bne llakill
 move bco,d0
 sub 20(a6),d0
 and #$3f,d0
 asl #3,d0
 lea ghist,a0
 move.l 0(a0,d0.w),2(a6)
 move 4(a0,d0.w),d0
 and #1,d0
 add #198,d0
 tst 24(a6)
 bmi fom
 add #2,d0
 sub #1,24(a6)
fom: move d0,12(a6)
 rts 
 
redfla: dc.w $700,1,$600,1,$500,1,$400,1,$770,0

iylazr: bsr ranxy
 move #15,60(a0)	;sound FX on hit
 move #3,6(a0)		;constant update with v. laser draw
 move #0,8(a0)		;dcol
 move #0,10(a0)		;dcol
 move #136,12(a0)	;gbase(8phase)
 move #2,14(a0)	;rez distance
 move #1,16(a0)		;detecol on/off
 move.l #0,20(a0)	;32-bit X and Y speed
 move.l #0,24(a0)
 move.l #$0400,28(a0)	;32-bit X and Y acceleration
 move.l #$0400,32(a0)
 move #$0020,36(a0)
 move 2(a0),38(a0)	;32-bit position
 move #0,40(a0) 
 move #0,48(a0)		;dead time
 move 4(a0),42(a0)
 move #0,44(a0)
 bsr rannum
 and #$7f,d0
 add #$30,d0
 move d0,d1
 asl #8,d0
 or d1,d0
 move #$7070,46(a0)
 move #6,62(a0)		;Explosion Mode=KNOCK32
 move #$1212,(a0)
; add #1,aon
 rts

fucking: dc.w 0
rude: dc.w 1		;flag RUDE=1 for complete Oh Fuck

swear: bsr rannum
 and #7,d0
 lea swearno,a4
 move.b 0(a4,d0.w),d0
 and #$ff,d0
 rts
 
swearno: dc.b 29,33,34,35,36,37,38,39

llakillf: cmp #2,outcode
 beq rrts
 tst inviso
 bne rrts
 tst _demo
 bne rrts
 move.l #laflash,flashpoint
 tst blight
 bne rrts
; move #29,d0
 bsr swear
 move #3,d1
 move #30,d2	;start to say 'oh fuck'
 bsr sonic
 move #0,fucking	;40 for 1meg
 bra llak
doylazr: tst.b 36(a6)
 beq glazr
 move 2(a6),d0
 sub xpos,d0
 bpl dola2
 neg d0
dola2: cmp #10,d0
 blt llakillf
 btst #1,pmode
 beq glazr
 move 2(a6),d0
 sub xpos2,d0
 bpl dola22
 neg d0
dola22: cmp #10,d0
 blt llakillf
 bra glazr
dolazr: tst.b 36(a6)
 beq glazr
 move 4(a6),d0
 sub ypos,d0
 bpl dola1
 neg d0
dola1: cmp #10,d0
 blt llakillf
 btst #1,pmode
 beq glazr
 move 4(a6),d0
 sub ypos2,d0
 bpl dola11
 neg d0
dola11: cmp #10,d0
 blt llakillf
glazr: tst.b 36(a6)
 beq dol_1
 sub.b #1,36(a6)
 bra inert_gen
dol_1: sub.b #1,46(a6)
 bne inert_gen
 move.b 47(a6),46(a6)
 move.b 37(a6),36(a6)
 move #0,d1
 move #8,d0
 move #7,d2
 bsr sonic
 bra inert_gen

doglob: move freecount,d0
 asr #2,d0
 and #3,d0
 add 36(a6),d0
 move d0,12(a6)		;do animation
 bsr hitllama
 bne llakill		;hit you
inert_gen: tst sirius2
 bne rrts
 tst 48(a6)
 bmi iego
 sub #1,48(a6)
 bra iego1
iego: move 2(a6),d0
 sub cxpos,d0
 move 4(a6),d1
 sub cypos,d1
 move.l 28(a6),d2
 tst d0
 bmi ieg1
 neg.l d2
ieg1: add.l d2,20(a6)
 move.l 32(a6),d2
 tst d1
 bmi ieg2
 neg.l d2
ieg2: add.l d2,24(a6)
iego1: move.l 20(a6),d0
 bpl ieger
 neg.l d0
ieger: move.l 28(a6),d1
 asl.l #5,d1
 cmp.l d1,d0
 ble ieger1
 tst 20(a6)
 bpl ieger0
 neg.l d1
ieger0: move.l d1,20(a6) 
ieger1: move.l 24(a6),d0
 bpl ieger2
 neg.l d0
ieger2: move.l 32(a6),d1
 asl.l #5,d1
 cmp.l d1,d0
 ble ieger3
 tst 24(a6)
 bpl ieger4
 neg.l d1
ieger4: move.l d1,24(a6) 
ieger3:
 move.l 20(a6),d0
 add.l 38(a6),d0
 swap d0
 cmp #8,d0
 ble ref_ix
 cmp #304,d0
 blt noref_ix
ref_ix: move.l #0,20(a6)
 move.l #0,d0
 bra statch
noref_ix: move d0,2(a6)
 swap d0
 move.l d0,38(a6)
statch: move.l 24(a6),d0
 add.l 42(a6),d0
 swap d0
 cmp #16,d0
 ble ref_iy
 cmp #183,d0
 blt noref_iy
ref_iy: move.l #0,24(a6)
 rts
noref_iy: move d0,4(a6)
 swap d0
 move.l d0,42(a6)
 rts

dobug: tst sirius2
 bne rrts 
 sub.b #1,26(a6)
 bpl rrts
 move.b 27(a6),26(a6)
 move 20(a6),d0	;target acquired?
 bpl gdokka
 cmp #-2,d0
 bne gseeek
 move cxpos,dummy_alien+2
 move cypos,dummy_alien+4
 bra gdokka
gseeek: move #0,d0
 lea aliens,a0
 move nllama,d1
 beq gshome
gseekal: cmp.b #5,1(a0)	;free Llama?
 beq ggotlla 
gkokal: lea 64(a0),a0
 add #1,d0
 bra gseekal
ggotlla: tst 24(a0)
 beq gygotlla
 sub #1,d1
 bne gkokal	;no target
gshome: move #-2,20(a6)	;do Seek Me instead
 rts
gygotlla: move #1,24(a0)	;blight Llama
 move d0,20(a6)		;set TAQ flag
 rts
gdokka: move 8(A6),d2
 bpl gdokka1
 neg d2
gdokka1: move 10(a6),d3
 bpl gdokka2
 neg d3
gdokka2: cmp d2,d3
 ble gx_ori
 move #2,d4
 tst 10(a6)
 bmi gdo_oriy
 add #2,d4
gdo_oriy: move 4(a6),d5
 asr #2,d5
 and #1,d5
 add d5,d4
 bra gorie
gx_ori: move #0,d4
 tst 8(a6)
 bmi gdo_orix
 move #6,d4
gdo_orix: move 2(a6),d5
 asr #2,d5
 and #1,d5
 add d5,d4
gorie:
goryx: add 28(a6),d4
 move d4,12(a6)
 cmp #-2,20(A6)
 bne gnuffun  
 lea dummy_alien,a0
 bra gkiil
gnuffun: asl #6,d0	;get llama target #
 lea aliens,a0
 lea 0(a0,d0.w),a0	;address llama
 cmp.b #5,1(a0)		;still free
 bne gseeek		;Llama killed or transformed- reseek
gkiil: bsr hitllama
 bne llakill
gdoki1: move 2(a0),d0
 sub 2(a6),d0
 move 4(a0),d1
 sub 4(A6),d1
 move d0,d2
 bpl gdkr0
 neg d2
gdkr0: move d1,d3
 bpl gdokr1
 neg d3
gdokr1: cmp #8,d2
 bge gapprai
 cmp #8,d3
 bge gapprai
 cmp #-2,20(a6)
 beq gyotsudama
 lea lamacts,a5
 move 32(a6),d2
 asl #2,d2
 move.l 0(a5,d2.w),a5
 jmp (a5)		;do something nasty to a llama

lamacts: dc.l kilit,mutit,firit,npurq

npurq: move #10,purq
 bra kilit 

mutit: sub #1,nllama
 bsr imm
 movem.l d1/a0,-(a7)
 move #26,d0
 move #0,d1
 move #3,d2
 bra xss

afirit: movem.l a1-a2/d1/d6,-(a7)
 move.l a2,a6
 bsr gfirit
 movem.l (a7)+,a1-a2/d1/d6
 bra stdkill 
 
firit: bsr gfirit
 bra kilit
gfirit: move.l a0,-(a7)
 move #235,d0
 move #-3,d1
 move #0,d2
 bsr s_makeproj
 move #236,d0
 move #-2,d1
 move #1,d3
 move ypos,d2
 sub 4(a6),d2
 bpl obscu
 neg d3
obscu: move d3,d2
 move d2,-(a7)
 bsr s_ma0
 move (a7)+,d2
 move #237,d0
 move #2,d1
 bsr s_ma0
 move #238,d0
 move #3,d1
 move #0,d2
 bsr s_ma0
 move.l (a7)+,a0
 rts


kilit: move #9,(a0)
 sub #1,nllama
 move #-1,58(a0)
gyotsudama: move #-1,20(a6)
 move #51,12(a0)
 move #20,20(a0)
 movem.l d1/a0,-(A7)
 move #0,d0
 move #1,d1
 move #4,d2
xss: bsr sonic
 movem.l (a7)+,d1/a0 
 rts

gapprai: cmp #3,d2
 ble gdokr21
 cmp #3,d3
 ble gdokr22
gshifka: asr #1,d0
 asr #1,d1
 asr #1,d2
 asr #1,d3
 bra gapprai
gdokr21: cmp #3,d3
 bgt gshifka
gdokr22: cmp #3,d2
 bgt gshifka
 move d0,8(A6)
 move d1,10(A6)
 add d0,2(a6)
 add d1,4(a6)
 rts

splat4b: movem.l d0-d4/a0-a4,-(a7)
 move #3,d0
 lea aliens,a0
 lea splat4dat,a1
 move #1,dobo
 bra air2 

frag8: movem.l d0-d4/a0-a4,-(a7)
 move #7,d0
 lea aliens,a0
 lea frag8dat,a1
 bra airs

splat4: tst bigfire
 bpl stdkill
 movem.l d0-d4/a0-a4,-(a7)
 move #3,d0
 lea aliens,a0
 lea splat4dat,a1
 bra airs

dobo: dc.w 0
frag4: tst bigfire
 bpl stdkill
 movem.l d0-d4/a0-a4,-(a7)
 move #3,d0		;4 frags to generate
 lea aliens,a0
 lea frag4dat,a1	;graph/orient/velocity data
airs: clr dobo
 move #59,d4
air2: tst (a0)
 bmi goti
 lea 64(a0),a0		;seek free alien
 sub #1,d4
 bpl air2
 bra zoop
goti: move.l 2(a2),2(a0)	;xfer XY position data
 sub #1,d4
 add #1,aon
 sub #1,afree
 move frvel,d2
 move #13,6(a0)	;continuous update
 move d0,d1
 asl #3,d1
 move 0(a1,d1.w),12(a0)	;frame base
 move 2(a1,d1.w),d3
 asl d2,d3
 move d3,8(a0)
 move 4(a1,d1.w),d3
 asl d2,d3
 move d3,10(a0)	;motion vector
 move #0,14(a0)
 move #1,16(a0)
 move #-1,58(a0)
 move #$0406,60(a0)
 move #16,62(a0)
 move #$0f,(a0)
 lea 64(a0),a0
 dbra d0,air2
zoop: movem.l (a7)+,d0-d4/a0-a4
 bra stdkill

s_makeproj: tst sirius2
 bne rrts
 tst d0
 beq rrts
s_ma0: move #69,d3
 lea aliens,a0
s_ma: tst (a0)
 bmi makeproj
 lea 64(a0),a0
 dbra d3,s_ma
 rts

makeproj: move.l 2(a6),2(a0)	;xfer XY position data
 add #1,aon
 sub #1,afree
 move #13,6(a0)	;continuous update
 move d0,12(a0)	;frame base
 move d1,8(a0)
 move d2,10(a0)	;motion vector
 move #0,14(a0)
 move #1,16(a0)
 move #0,50(a0)
 move #-1,58(a0)
 move #$0307,60(a0)
 move #0,62(a0)
 move #$0f,(a0)
 rts




frag4dat: dc.w 119,-1,-1,0,120,1,-1,0,121,1,1,0,122,-1,1,0  
splat4dat: dc.w 161,-1,0,0,161,-2,0,0,162,1,0,0,162,2,0,0
frag8dat: dc.w 298,0,-1,0,298,0,1,0,298,-1,0,0,298,1,0,0
	dc.w 298,-1,-1,0,298,1,1,0,298,-1,1,0,298,1,-1,0

movedge: bsr hitllama
 bne llakill
 bsr moveit
 tst bons
 beq rrts
movenn: move #-1,(a6)
 add #1,afree
 sub #1,aon
 rts

mw3: move.l wptr,a0
 move.b 1(a0),d0
 cmp.b #-1,d0
 beq mw4
 and #$ff,d0
 move d0,ngrunts
 move.b (a0),d0
 and #$ff,d0
 move d0,atype
 asl #2,d0
 lea llaunches,a1
 move.l 0(a1,d0.w),agrunt
 add.l #2,wptr
 rts
mw4: move #1,sirius
 move nllama,llamaco
mw1: rts

llamaco: dc.w 0

ngrunts: dc.w 12
sirius2: dc.w 0
agrunt: dc.l 0
atype: dc.w 0
getal: lea aliens,a0
 move #69,d3
gall: tst (a0)
 bmi frts
nal: tst d3
 bmi frifg
 lea 64(a0),a0
 dbra d3,gall
frifg: move #0,d3
 rts
frts: sub #1,d3
 move #0,50(a0)
 move #18,6(a0)
 move #0,14(a0)
 move #-1,d4
 rts


rok4: movem.l d0-d2/a0-a2,-(a7)
 bsr getal
 bpl erok
 move #1,d0
 move #$2004,d1
rok44: move.l 2(a2),2(a0)
 move #-1,58(a0)
 bsr iis
 bsr nal
 bpl erok
 add #2,d0
 cmp #8,d0
 blt rok44
erok: movem.l (a7)+,d0-d2/a0-a2
 bra stdkill
rok8: movem.l d0-d2/a0-a2,-(a7)
 bsr getal
 bpl erok
 move #0,d0
 move #$2004,d1
rok84: move.l 2(a2),2(a0)
 move #-1,58(a0)
 bsr iis
 bsr nal
 bpl erok
 add #1,d0
 cmp #8,d0
 blt rok84
 bra erok

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

vblank: movem.l d0-d7/a0-a6,-(a7)
 add #1,freecount
 tst syncreq
 beq vbl_1
 clr syncreq
vbl_1: move.l flashpoint,d0
 beq vbl2
 move.l d0,a0
 move (a0)+,d0
 bne makecol
 move #0,$ff8240
 move.l #0,flashpoint
 bra vbl2
makecol: move d0,$ff8240
 move.l a0,flashpoint
vbl2: tst melonman
 beq nfoi
 move freecount,d0
 and #$0f,d0
 asl #1,d0
 lea gapulse,a0
 move 0(a0,d0.w),$ff8242

nfoi: tst sampri
 beq freman
 move.l sa_pt,d0
 move.l cursrhi,d1
 tst _reverse
 bne okotti
 cmp.l d0,d1
 bpl freman
oknan: move #0,sampri
 move sr,d0
 move d0,-(a7)
 and #%0101100011100000,d0
 or.W #$2700,d0
 move d0,sr
; MOVE.W	#$2700,SR
 LEA	INULL,A0	REMOVE REPLAY INT.
 BSR	SETINT
 SF	INUSE
 move #0,_reverse
 move (a7)+,d0
 MOVE.W	d0,SR
 bra freman
okotti: cmp.l d0,d1
 bpl oknan

freman: move.l routine,a0
 jsr (a0)
 movem.l (a7)+,d0-d7/a0-a6
 rte

melonman: dc.w 0

setup_title: move #128,d0
 move #0,d1
 lea titty,a0
sut: move d0,(a0)+
 add #16,d0
 add #1,d1
 cmp #10,d1
 bne sut
 move #80,do_2
 move.l back_screen,a0
 bsr cls
 move.l back_screen,a1
 move #$0b,d2
 move #0,d3
 move #0,d4
 move #318,d5
 move #198,d6
 bsr rect
 move.l back_screen,a1
 lea coolc2,a0
 move #65,d0
 move #80,d1
 move #-1,d2
 move.l ascreen,a2
 bsr yak
 lea coolc1,a0
 move #257,d0
 move #80,d1
 move #-1,d2
 move.l back_screen,a1
 move.l ascreen,a2
 bsr yak 
 move.l back_screen,scrscrn
 bsr xfrombak
 rts

do_2: dc.w 80

tit_int: cmp #80,do_2
 bne tit3
 lea titty,a0
 move #9,d0
 move #0,d1
tit1: tst (a0)
 beq tit2
 bmi tit2
 move #1,d1
 sub #2,(a0)
 bmi doe
 bne tit2
doe:  movem.l d0-d1/a0,-(A7)
 move #2,d0
 move #1,d1
 move #2,d2
 bsr sonic
 movem.l (a7)+,d0-d1/a0 
tit2: lea 2(a0),a0
 dbra d0,tit1
 tst d1
 beq tit3
 rts
tit3: cmp #80,do_2
 bne tit33
 sub #1,do_2
 move #20,d0
 move #0,d1
 move #2,d2
 bra sonic
tit33: tst do_2
 beq rarts
 bmi rarts
 sub #1,do_2
 bne rrts
 move #17,d0
 move #1,d1
 move #2,d2
 bra sonic
rarts: bsr run_camfield
 move.b joydat+1,d0
 and #$0f,d0	;get joy data
 bne somky
 move #0,jdb
 bra nomky
somky: tst jdb
 bne nomky
 move d0,jdb
 move d0,d1
 and #$03,d1
 beq chomky	;u/d
 bchg #2,pmode
 bra nomky
chomky: and #8,d0
 beq isrighy
 move.b pmode,d0
 move d0,d1
 and #4,d1
 and #3,d0
 add #1,d0
 and #3,d0
 cmp #2,d0
 bne nimky
 add #1,d0
 bra nimky
isrighy: move.b pmode,d0
 move d0,d1
 and #4,d1
 and #3,d0
 sub #1,d0
 and #3,d0
 cmp #2,d0
 bne nimky
 sub #1,d0
nimky: or d0,d1
 move.b d1,pmode
 
nomky: move pmode,old_pmode
 rts
rrts: rts

jdb: dc.w 0 
tit_draw: lea titty,a3
 move #10,d4
 move #50,d0
 move #20,d1
 move #0,d5
ti_d: move.b 20(a3,d5.w),d6
 ext d6
 asl #2,d6
 lea objex,a0
 move.l 0(a0,d6.w),a0
 move d5,d6
 asl #1,d6
 tst 0(a3,d6.w)
 bmi ti_nx
 beq ti_fix
 move 0(a3,d6.w),d3
 move #1,d4
 cmp #128,d3
 bge ti_nx
 move #1,d2
 bsr syak
 neg d4
 bsr syak
ti_nx: add #1,d5
 add #24,d0
 cmp #10,d5
 bne ti_d 

 move do_2,d3
 bmi drqs
 beq fixlogo
 cmp #80,d3
 beq rrts
 move #2,d4
drawlogo: lea objex,a3
 move #1,d2
 move #44,d1
 move #130,d0
 move #8,d5
drawl: move d5,d6
 asl #2,d6
 move.l 0(a3,d6.w),a0
 bsr syak
 neg d4
 bsr syak
 neg d4
 add #16,d0
 add #1,d5
 cmp #13,d5
 bne drawl
 rts

drqs: move #120,d1
 move #155,d0
 move #-1,d2
 move freecount,d3
 asr #1,d3
 and #$0f,d3
 sub #$08,d3
 bpl drqs1
 neg d3
drqs1: add d3,d1
 lea qu1,a0
 bsr syak
 move #120,d1
 move freecount,d3
 asr #1,d3
 add #$08,d3
 and #$f,d3
 sub #$08,d3 
 bpl drqs4
 neg d3 
drqs4: add d3,d1
 lea qu2,a0
 bsr syak		;puzzled yak stuff
 lea plyr,a0
 btst #0,pmode
 beq drqs5		;player 1
 lea teem,a0
 btst #1,pmode
 bne drqs5		;team
 lea pldroid,a0
drqs5: move #156,d0
 move #95,d1
 bsr syak
 lea plone,a0
 btst #2,pmode
 beq freeq8
 lea pltwo,a0
freeq8: move #155,d0
 move #75,d1
 bsr syak
 bra draw_camfield

fixlogo: move.l a2,-(a7)
 move #-1,d2
 move #1,d3
 move #0,d4
 bsr drawlogo
 move.l bscreen,a1
 bsr drawlogo
 move.l back_screen,a1
 bsr drawlogo
 move.l ascreen,a1
 lea yakk,a0
 move #140,d1
 move #160,d0
 bsr vyak
 lea yakm,a0
 move #160,d1
 move #160,d0
 bsr vyak
 lea yaksign,a0
 move #160,d0
 move #180,d1
 bsr vyak
 move #-1,do_2
 move.l (a7)+,a2
 rts

vyak: move.l a2,-(a7)
 move #-1,d2
 move.l back_screen,a1
 bsr syak
 move.l bscreen,a1
 bsr syak
 move.l ascreen,a1
 bsr syak
 move.l (a7)+,a2
 rts

nyak: move.l bscreen,a2
 bra yak

ti_fix: move #-1,0(a3,d6.w)
 move #1,d2
 move #1,d3
 move #0,d4
 move.l a2,-(a7)
 bsr syak
 move.l bscreen,a1
 bsr syak
 move.l back_screen,a1
 bsr syak
 move.l ascreen,a1
 move.l (A7)+,a2
 bra ti_nx

syak: movem.l d0-d6/a0/a3-a5,-(a7)
 bsr yak
 movem.l (a7)+,d0-d6/a0/a3-a5
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
 cmp #0,d0
 bge mint
 move #0,d0
mint: cmp #199,d0
 ble mint2
 move #199,d0
mint2: move d0,ypos
 move.b xoff,d1
 ext d1
 move xpos,d0
 add d1,d0
 cmp #0,d0
 bge mint3
 move #0,d0
mint3: cmp #319,d0
 ble mint4
 move #319,d0
mint4: move d0,xpos
 movem (a7)+,d0-d1
 rts

h2oles: dc.w $3fff,$3fff,$cfff,$cfff,$f3ff,$f3ff,$fcff,$fcff
	dc.w $ff3f,$ff3f,$ffcf,$ffcf,$fff3,$fff3,$fffc,$fffc
b2its: dc.w $c000,$c000,$3000,$3000,$0c00,$0c00,$0300,$0300
	dc.w $00c0,$00c0,$0030,$0030,$000c,$000c,$0003,$0003
ct1: dc.w 0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1
ct2: dc.w 0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1
ct3: dc.w 0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1
ct4: dc.w 0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1

p2plot:
;
;Pixel plot (d0,d1) colour=d2 on ascreen pix size 2x1
;
 tst d0
 bmi rrts
 cmp #320,d0
 bge rrts
 tst d1
 bmi rrts
 cmp #200,d1
 blt p2plot1
 rts
p2plot1: move d2,d6		;save colour
 move d0,d2
 asl.w #2,d1
 move.l #ytab,a0
 move.l 0(a0,d1.w),d0
 move.w d2,d1
 and.l #$0ff0,d1
 asr.w #1,d1
 add.l d1,d0
; move udmode,(a2)+
; move #0,(a2)+
; move.l d0,(a2)+
; move #-500,(a2)
 add.l a1,d0
 move.w d2,d1
 asl #1,d1
 and #$001f,d1
 lea h2oles,a0
 move.w 0(a0,d1.w),d2
 lea b2its,a0
 move.w 0(a0,d1.w),d3
 lea ct4,a0
; move.w colour,d6
 asl.w #1,d6
 move.w 0(a0,d6.w),d4
 move.l d0,a3
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -32(a0,d6.w),d4
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -64(a0,d6.w),d4
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -96(a0,d6.w),d4
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 rts



rect:
;
;use p2plot to make a rectangle, colour d2, co-ords d3-d4/d5-d6

 move d3,d0
 move d4,d1
rect1: bsr sp2plot
 add #2,d0
 cmp d5,d0
 ble rect1
 move d3,d0
 move d6,d1
rect2: bsr sp2plot
 add #2,d0
 cmp d5,d0
 ble rect2
 move d3,d0
 move d4,d1
rect3: bsr sp2plot
 add #2,d1
 cmp d6,d1
 ble rect3
 move d5,d0
 move d4,d1
rect4: bsr sp2plot
 add #2,d1
 cmp d6,d1
 ble rect4
 rts

sp2plot: movem d0-d6,-(a7)
 bsr p2plot
 movem (a7)+,d0-d6
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
 move d1,(a2)+
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
 move.l the_business,a3
 jsr (a3)
 move #-500,(a2)
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
xals: move (a0)+,d1
 bmi xale
 move (a0)+,d0
 add #1,d1
; asl #1,d1
 move.l (a0)+,d2
 move.l bscreen,a1
 add.l d2,a1
 move.l back_screen,a2
 add.l d2,a2			;area to undraw
xals1: move.l a1,a3
 move.l a2,a4
 move d1,d2
xals2: move.l (a4)+,(a3)+	;undraw
 move.l (a4)+,(a3)+
 dbra d2,xals2			;16 bytes
 lea 160(a1),a1
 lea 160(a2),a2
 dbra d0,xals1			;8 lines of sprite
 bra xals

xale: move.l ascreen,d4
 move.l bscreen,ascreen
 move.l d4,bscreen
 move.l shipa,d4
 move.l shipb,shipa
 move.l d4,shipb
null: rts

do_ud: rts

yakN:
;
;Wonderful Amazingly Fast Any-bit Sprite Draw Thingie?


 move #0,d6	;d6 will be data skip offset
 move.l #0,a5	;extra eol-clip
 move 2(a0),d5	;d5 is total # slots of main sprite
 move 4(a0),d2
 asr #1,d2
 sub d2,d1
 move 6(a0),d2
 asr #1,d2
 sub d2,d0	;centre sprite co-ordinates

 move.l #0,d7	;First/Last Word maskies

 tst d0
 bpl f1s_1
 move d0,d4
 add 6(a0),d4	;add X width
 bmi rrts 	;still negative; return
 move d0,d4	;get X overhang
 neg d4
 sub #1,d4
 asr #4,d4	;get X slots overhang
 beq setfwm	;is only 1 slot, set FWM
 move d4,d6
 asl #3,d6	;get size of overhang, in bytes
 ext.l d6
 move.l d6,a5	;horizontal data skip per line
 sub d4,d5	;d5 is new sprite size

 and #$0f,d0
 sub #$10,d0 
setfwm: bset #31,d7	;set FWM=1
 bra f1s_2
f1s_1:

 cmp #320,d0
 bpl rrts
 move d0,d4
 move 2(a0),d6
 add #1,d6
 asl #4,d6
; add 6(a0),d4	;get X width
 add d6,d4
 move #0,d6
 sub #320,d4
 bmi f1s_2	;sprite is not split
 move d4,d6
 asr #1,d6
 and #$1f8,d6
 ext.l d6
 move.l d6,a5	;get EOL adder
 move #0,d6
 asr #4,d4
 sub d4,d5
 bset #30,d7	;set LWM=1
f1s_2:
 
 move d5,hlength	;save slivers length
 move 2(a0),d5		;get total sprite width
 add #1,d5
 asl #3,d5		;get # of bytes to skip on one scanline
 move 4(a0),d3
 tst d1
 bpl f1s_3
; sub #1,d1		;Y clip top of sprite
 neg d1
 cmp d3,d1		; check size of overhang
 bpl rrts		; larger than the sprite
 sub d1,d3
 move #0,d7
adlines: add d5,d7
 dbra d1,adlines	;skip top of sprite

 lea 0(a0,d7.w),a0	;skip the data
 move #1,d1		;force start to T.O.S
 bra f1s_4 
f1s_3: cmp #200,d1
 bpl rrts		;off bottom
 move d1,d2
 add d3,d2		;check bottom
 cmp #200,d2
 bmi f1s_4
 sub #199,d2
 sub d2,d3		;adjust DBRa 

f1s_4: move hlength,(a2)+		;this (X slot dbra)
 lea 0(a0,d6.w),a0	;skip any due to initial clipping
 move d0,d6		;get copy of X position
 and #$0f,d6		;get shift right count
 asr #1,d0
 and #$fff8,d0		;X offset
 ext.l d0
 asl #2,d1
 lea ytab,a4
 add.l 0(a4,d1.w),d0	;get screen offset


 lea 0(a1,d0.w),a4	;get start of screen plot ; d0 keeps offset
 move d3,d1		;get vertical DBRA
 move d1,(a2)+		;vert DBRA for undraw
 move.l d0,(a2)+	;the offset for undraw

 lea 12(a0),a0		;address the data
anywidth: move hlength,d7	;horizontal sliver DBRA
 move.l a4,a6
 bset #29,d7		;First Word flag
m1ultip: clr.l d2	;will be data 1
 clr.l d3		;will be data 2
 clr.l d4		;will be data 3
 clr.l d5		;will be data 4
 clr.l d0		;will be mask


 move (a0)+,d2
 move (a0)+,d3
 move (a0)+,d4
 move (a0)+,d5
 

 or.l d2,d0
 or.l d3,d0
 or.l d4,d0
 or.l d5,d0		;got positive mask in d0
 eor.l #-1,d0		;make an inverse mask


 ror.l d6,d0	;shift the mask
 ror.l d6,d2
 ror.l d6,d3
 ror.l d6,d4
 ror.l d6,d5	;.. and the data

 btst #29,d7	;First word?
 beq n1ofwm	;No
 bclr #29,d7	;clear flag
 btst #31,d7
 beq n1ofwm
 lea 8(a4),a4
 bra lwc

n1ofwm:
 and d0,(a4)
 or d2,(a4)+	;place the data for plane 1

 and d0,(a4)
 or d3,(a4)+	;plane 2
 and d0,(a4)
 or d4,(a4)+	;plane 3
 and d0,(a4)
 or d5,(a4)+	;plane 4

lwc: tst d7		;will be 0 on last word
 bne n1ext_blit

 btst #30,d7
 bne n1o_blit

n1ext_blit: swap d0
 swap d2
 swap d3
 swap d4
 swap d5	;get next word of data

 and d0,(a4)
 or d2,(a4)	;place the data for plane 1
 and d0,2(a4)
 or d3,2(a4)	;plane 2
 and d0,4(a4)
 or d4,4(a4)	;plane 3
 and d0,6(a4)
 or d5,6(a4)	;plane 4


n1o_blit:
 dbra d7,m1ultip
 add.l a5,a0
 move.l a6,a4  
 lea 160(a4),a4	;next scanline..
 dbra d1,anywidth
 rts		;bobbly doo dah

hlength: dc.w 0

yaku:
;
;unclipped, uncentred and unwashed (like Yak huh?)

 move.l #0,d7
 move 4(a0),d3
 bra fs_4

yak:
;
;Wonderful Amazingly Fast 16-bit Sprite Draw Thingie?



 tst d2
 bpl xyak
 tst 2(a0)
 bne yakN

 move 4(a0),d2
 asr #1,d2
 sub d2,d1
 move 6(a0),d2
 asr #1,d2
 sub d2,d0	;centre sprite co-ordinates

 tst (a0)
 beq ufs

; move.l #0,d7	;First/Last Word maskies

; cmp #-15,d0
; bmi rrts
; tst d0
; bpl fs_1
; bset #31,d7	;set FWM=1
; bra fs_2
;fs_1: cmp #320,d0
; bpl rrts
; cmp #304,d0
; bmi fs_2
; bset #30,d7	;set LWM=1
;fs_2:
 move 4(a0),d3
; cmp #1,d1
; bpl fs_3
; sub #1,d1		;Y clip top of sprite
; neg d1
; cmp d3,d1		; check size of overhang
; bpl rrts		; larger than the sprite
; sub d1,d3
; asl #3,d1		;# data to skip
; lea 0(a0,d1.w),a0	;skip the data
; move #28,d1		;force start to T.O.S
; bra fs_4 
;fs_3: cmp #200,d1
; bpl rrts		;off bottom
; move d1,d2
; add d3,d2		;check bottom
; cmp #200,d2
; bmi fs_4
; sub #199,d2
; sub d2,d3		;adjust DBRa 





fs_4: move d0,d6		;get copy of X position
 and #$0f,d6		;get shift right count
 asr #1,d0
 and #$fff8,d0		;X offset
 ext.l d0
 asl #2,d1
 lea ytab,a4
 add.l 0(a4,d1.w),d0	;get screen offset


 lea 0(a1,d0.w),a4	;get start of screen plot ; d0 keeps offset
 move d3,d1		;get vertical DBRA
 move #0,(a2)+		;X one iteration
 move d1,(a2)+
 move.l d0,(a2)+	;the offset for undraw

 lea 12(a0),a0		;address the data

multip: clr.l d2	;will be data 1
 clr.l d3		;will be data 2
 clr.l d4		;will be data 3
 clr.l d5		;will be data 4
 clr.l d0		;will be mask


 move (a0)+,d2
 move (a0)+,d3
 move (a0)+,d4
 move (a0)+,d5
 

 or.l d2,d0
 or.l d3,d0
 or.l d4,d0
 or.l d5,d0		;got positive mask in d0
 eor.l #-1,d0		;make an inverse mask


 ror.l d6,d0	;shift the mask
 ror.l d6,d2
 ror.l d6,d3
 ror.l d6,d4
 ror.l d6,d5	;.. and the data

; btst #31,d7
; beq nofwm
; lea 8(a4),a4
; bra next_blit

nofwm:
 and d0,(a4)
 or d2,(a4)+	;place the data for plane 1

 and d0,(a4)
 or d3,(a4)+	;plane 2
 and d0,(a4)
 or d4,(a4)+	;plane 3
 and d0,(a4)
 or d5,(a4)+	;plane 4



; btst #30,d7
; beq next_blit
; lea 8(a4),a4
; bra no_blit

next_blit: swap d0
 swap d2
 swap d3
 swap d4
 swap d5	;get next word of data

 and d0,(a4)
 or d2,(a4)+	;place the data for plane 1
 and d0,(a4)
 or d3,(a4)+	;plane 2
 and d0,(a4)
 or d4,(a4)+	;plane 3
 and d0,(a4)
 or d5,(a4)+	;plane 4

no_blit: lea 144(a4),a4	;next scanline..
 dbra d1,multip
 rts		;bobbly doo dah



undraw: move 4(a0),d2
 asr #1,d2
 sub d2,d1
 move 6(a0),d2
 asr #1,d2
 sub d2,d0	;centre sprite co-ordinates

 move d0,d6		;get copy of X position
 and #$0f,d6		;get shift right count
 asr #1,d0
 and #$fff8,d0		;X offset
 ext.l d0
 asl #2,d1
 lea ytab,a4
 add.l 0(a4,d1.w),d0	;get screen offset


 lea 0(a1,d0.w),a4	;get start of screen plot ; d0 keeps offset
 move 4(a0),d1		;get vertical DBRA

 lea 12(a0),a0		;address the data

multiper: clr.l d2	;will be data 1
 clr.l d3		;will be data 2
 clr.l d4		;will be data 3
 clr.l d5		;will be data 4
 clr.l d0		;will be mask


 move (a0)+,d2
 move (a0)+,d3
 move (a0)+,d4
 move (a0)+,d5
 

 or.l d2,d0
 or.l d3,d0
 or.l d4,d0
 or.l d5,d0		;got positive mask in d0
 eor.l #-1,d0		;make an inverse mask


 ror.l d6,d0	;shift the mask
 ror.l d6,d2
 ror.l d6,d3
 ror.l d6,d4
 ror.l d6,d5	;.. and the data



 and d0,(a4)+
; or d2,(a4)+	;place the data for plane 1

 and d0,(a4)+
; or d3,(a4)+	;plane 2
 and d0,(a4)+
; or d4,(a4)+	;plane 3
 and d0,(a4)+
; or d5,(a4)+	;plane 4




 swap d0
 swap d2
 swap d3
 swap d4
 swap d5	;get next word of data

 and d0,(a4)+
; or d2,(a4)+	;place the data for plane 1
 and d0,(a4)+
; or d3,(a4)+	;plane 2
 and d0,(a4)+
; or d4,(a4)+	;plane 3
 and d0,(a4)+
; or d5,(a4)+	;plane 4

 lea 144(a4),a4	;next scanline..
 dbra d1,multiper
 rts		;bobbly doo dah





yco: dc.w 0
xco: dc.w 0

xyak: tst 2(a0)
 bne yakN
 muls d3,d4
 move d4,d7
 swap d7
 move 6(a0),d5
 asr #1,d5
 sub d5,d0
 move 4(a0),d5
 asr #1,d5
 muls d5,d4
 sub d4,d0
 tst d2
 beq xya1

; centred expanded sprite

 cmp #1,d2
 bne topx
 move 4(a0),d4		;Y sprite size
 asr #1,d4		;half
; sub d4,d1		;centre sprite
 muls d3,d4
 sub d4,d1		;calc expansion
 bra xya1

topx: add 4(a0),d1
 move 4(a0),d4
 muls d3,d4
 sub d4,d1


xya1: and #2047,d1	;clip Y co-ord
 move d1,yco
 move d3,d7

; move 4(a0),d2
; asr #1,d2
; sub d2,d1
; move 6(a0),d2
; asr #1,d2
; sub d2,d0	;centre sprite co-ordinates

 move 4(a0),d1





 move d0,xco
 lea 12(a0),a0		;address the data



xdraw: move xco,d0
 bmi downapub
 cmp #304,d0
 bge downapub
 move d0,d6		;get copy of X position
 and #$0f,d6		;get shift right count
 asr #1,d0
 and #$fff8,d0		;X offset
 ext.l d0
; move.l d0,a5
 move yco,d3
 and #2047,d3
 asl #2,d3
 lea ytab,a4
 add.l 0(a4,d3.w),d0	;get screen offset
; add.l a5,d0		;add X offset
 move #0,(a2)+
 move #0,(a2)+	;single sliver
 move.l d0,(a2)+	;the offset for undraw
 lea 0(a1,d0.w),a4	;get start of screen plot ; d0 keeps offset
 bsr dsliv
downapub: add d7,yco 
 swap d7
 add d7,xco
 swap d7
 dbra d1,xdraw
 rts



dsliv:
;
;Draw single sliver of sprite, at screen (a4), data at (a0)
;d6=horizontal shift count

 clr.l d2	;will be data 1
 clr.l d3		;will be data 2
 clr.l d4		;will be data 3
 clr.l d5		;will be data 4
 clr.l d0		;will be mask


 move (a0)+,d2
 move (a0)+,d3
 move (a0)+,d4
 move (a0)+,d5
 

 or.l d2,d0
 or.l d3,d0
 or.l d4,d0
 or.l d5,d0		;got positive mask in d0
 eor.l #-1,d0		;make an inverse mask


 ror.l d6,d0	;shift the mask
 ror.l d6,d2
 ror.l d6,d3
 ror.l d6,d4
 ror.l d6,d5	;.. and the data

; btst #31,d7
; beq nofwm
; lea 8(a4),a4
; bra next_blit

;nofwm:
 and d0,(a4)
 or d2,(a4)+	;place the data for plane 1

 and d0,(a4)
 or d3,(a4)+	;plane 2
 and d0,(a4)
 or d4,(a4)+	;plane 3
 and d0,(a4)
 or d5,(a4)+	;plane 4



; btst #30,d7
; beq next_blit
; lea 8(a4),a4
; bra no_blit

 swap d0
 swap d2
 swap d3
 swap d4
 swap d5	;get next word of data

 and d0,(a4)
 or d2,(a4)+	;place the data for plane 1
 and d0,(a4)
 or d3,(a4)+	;plane 2
 and d0,(a4)
 or d4,(a4)+	;plane 3
 and d0,(a4)
 or d5,(a4)+	;plane 4

 lea 144(a4),a4	;next scanline..

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

rannum:
;
; Get a ran#, 0-255,in d0
;
 move.l a0,-(a7)
 move.l #rantab,a0
 move ranptr,d0
 move.b 0(a0,d0.w),d0
 and #$ff,d0
 add #1,ranptr
 and #$1ff,ranptr
 move.l (a7)+,a0
 rts

init_aliens: lea aliens,a0
 move #99,d0
i_als: move #-1,(a0)
 move #18,6(a0)
 move #0,14(a0)
 move #0,16(a0)
 move #0,50(a0)
 lea 64(a0),a0
 dbra d0,i_als
 rts

cxpos: dc.w 0
cypos: dc.w 0

run_aliens: lea aliens,a6
 move #69,d7
r_als: lea avex,a0
 tst (a6)
 bmi n_als
 move xpos,cxpos
 move ypos,cypos
 btst #1,pmode
 beq rr_al
 btst #0,d7
 beq rr_al
 move xpos2,cxpos
 move ypos2,cypos
rr_al:
 move.b 1(a6),d0
 and #$ff,d0
 asl #2,d0
 move.l 0(A0,d0.w),a0
 jsr (a0)
n_als: lea 64(a6),a6
 dbra d7,r_als
 rts

draw_aliens:  lea aliens,a6
 move #69,d7
d_als: lea dvex,a0
 tst (a6)
 bmi n_alsd
 move 6(a6),d0
 and #$ff,d0
 asl #2,d0
 move.l 0(A0,d0.w),a0
 movem.l d7/a6,-(a7)
 jsr (a0)
 movem.l (a7)+,d7/a6
 tst 50(a6)
 beq n_alsd
 move 50(a6),d0
 move 52(a6),d1
 move 54(a6),d2
 asl #2,d2
 lea objex,a0
 move.l 0(a0,d2.w),a0
 movem.l d7/a6,-(a7)
 move #-1,d2
 bsr yak
 movem.l (a7)+,d7/a6
 sub #1,56(a6)
 bne n_alsd
 move #0,50(a6)
n_alsd: lea 64(a6),a6
 dbra d7,d_als
 rts

doex: add #1,14(a6)
 cmp #15,14(a6)
 blt rrts
 move #-1,(a6)
 add #1,afree
 rts

dorez: sub #2,14(a6)
 bpl rrts
 move.b (a6),1(A6)
 add #1,6(a6)		;fix to back
 move #1,16(A6)		;set DC on
 rts

inviso: dc.w 0

dolec: bsr hitllama
 beq rrts
llakill: cmp #2,outcode
 beq rrts

 tst inviso
 bne rrts
 tst _demo
 bne rrts
 move.l #bflash,flashpoint
 tst blight
 bne rrts
llak:
 move #2,pclean
 and #2,d0
 bne kl2		;will be kill Player 2's llama
 move #-2,xllama
klcon: move #17,d0
 move #0,d1
 cmp #10,aon
 bge klc1
 move #0,fucking	;40 for 1meg
; move #29,d0
 bsr swear
 move #3,d1
 move #30,d2
 bra sonic
klc1: move #30,d2
 bra sonic
kl2: btst #1,pmode
 beq rrts
 move #-2,xllama2
 bra klcon
drawrez: move 2(a6),d0
 move 4(a6),d1
 move #1,d2
 move 14(A6),d3
 move #0,d4
dowit: lea objex,a0
 move 12(A6),d5
 bpl foob1
 move.l 44(a6),a0
 bra yak
foob1: asl #2,d5
 move.l 0(a0,d5.w),a0
 bra yak

drawdrez: bsr getograf
 move 20(a6),d4
 move #1,d2
 bra yak

getograf: move 2(a6),d0
 move 4(a6),d1
 move 14(A6),d3
 move #0,d4
 lea objex,a0
 move 12(A6),d5
 bpl foob2
 move.l 44(a6),a0
 rts
foob2:
 asl #2,d5
 move.l 0(a0,d5.w),a0
 rts 

drawlec: move 2(a6),d0
 move 4(a6),d1
; bra ufs

 move #2,6(a6)
 move #-1,d2
 lea objex,a0
 move 12(A6),d5
 bpl suez
 move.l 44(a6),a0
 bra suez1
suez: asl #2,d5
 move.l 0(a0,d5.w),a0
suez1: move.l back_screen,a1
 move.l a2,-(a7)
 bsr syak 
 move.l (a7)+,a2
 move.l ascreen,a1
 bra yak



unfad1: bsr getograf
 add #1,6(a6)
; bra ufs

 move.l back_screen,a1
 bsr undraw
 move.l ascreen,a1
 bra unfad2

ncams: dc.w 63

start_camfield: lea aliens,a0
 move ncams,d1
s_camf:
 move d1,d0
 sub #31,d0
 asl #1,d0
 add #160,d0
; asl #3,d0
; and #$ff,d0
; lea sine,a1
; move.b 0(a1,d0.w),d2
; ext d2
; asr #3,d2
; add #160,d2
 move d0,(a0)
 clr 2(a0)
 move d1,d0
 asl #2,d0
 and #$ff,d0
 lea sine,a1
; add.b #$40,d0
 move.b 0(a1,d0.w),d2
 ext d2
 asr #3,d2
 add #18,d2
 move d2,4(a0)
 clr 6(a0)
 bra peenix
 move d1,d0
 add #1,d0
 asl #1,d0
 move d0,4(a0)

 move #0,6(a0)
 move #160,(a0)
 clr 2(a0)
peenix: clr.l d2
 move d1,d2
 add #1,d2
 clr.l d3
 move #12,d3
 asl.l d3,d2
 move.l d2,8(a0)
 move.l #0,12(a0)
 move d1,d0
 asr #3,d0
 and #6,d0
 lea sops,a1
 move 0(a1,d0.w),16(a0) 
 lea 18(a0),a0
 dbra d1,s_camf
 rts

sops: dc.w 35,71,79,87

run_camfield: lea aliens,a0
 move ncams,d0
ru_c: move.l 4(a0),d1
 sub.l 12(a0),d1
 bpl ruc1
; add.l 12(a0),d1
; neg.l 12(a0)
 move.l #$fffe0000,12(a0)
 clr.l d1
; move.l d1,4(a0)
; neg.l 8(a0)

ruc1: move.l d1,4(a0)
 add.l #$0a00,12(a0)
 move.l (a0),d1
 add.l 8(a0),d1
 cmp.l #$1300000,d1
 bge refit
 cmp.l #$100000,d1
 bgt norefit
 sub.l #$100000,d1
 neg.l d1
 add.l #$100000,d1
 bra rlt
refit: sub.l #$1300000,d1
 neg.l d1
 add.l #$1300000,d1 
 
rlt: neg.l 8(a0)
norefit: move.l d1,(a0)
 lea 18(a0),a0
 dbra d0,ru_c
 rts

draw_camfield: lea aliens,a3
 move ncams,d7
drawcf: move (a3),d0
 asr #2,d0
 and #1,d0
 add 16(a3),d0
 tst 8(a3)
 bmi drawc1
 add #6,d0
drawc1: asl #2,d0
 lea objex,a0
 move.l 0(a0,d0.w),a0	;point to frame
 move (a3),d0
 move #192,d1
 sub 4(a3),d1
 movem.l d7/a3,-(a7)
 move #-1,d2
 bsr yak 
 movem.l (a7)+,d7/a3
 lea 18(a3),a3
 dbra d7,drawcf
 rts


unfad0:
 bsr getograf
 add #1,6(a6)
; bra ufs

 move.l back_screen,a1
 bsr undraw
 move.l bscreen,a1
 bsr getograf
 bsr undraw
 bsr getograf
 move.l ascreen,a1
 move #-1,d2
 bsr yak
 bra drawdrez

unfad2: bsr getograf
 add #1,6(a6)
; bra ufs

 move #-1,d2
 move.l ascreen,a1
 bra yak

lladraw: tst luv
 bmi stdraw
 move 2(a6),d0
 move 4(a6),d1
 lea luv2,a0
 sub #10,d1
 move #-1,d2
 bsr syak
 bra stdraw

drylazr: move 2(a6),d0
 move 4(a6),d1
 lea lazind,a0
 sub #10,d1
 move #-1,d2
 bsr yak
 tst.b 36(a6)
 beq stdraw
 move 2(a6),d0
 asr #1,d0
 and #$0ff8,d0
 move.l ytab+40,a0
 lea 0(a0,d0.w),a0
 move #0,(a2)+
 move #185,(a2)+
 move.l a0,(a2)+
 add.l a1,a0
 move 2(a6),d0
 and #$0f,d0
 move #$8000,d1
 ror d0,d1
 move #185,d0
dryl: or d1,(a0)
 lea 160(a0),a0
 dbra d0,dryl
 bra stdraw

sparkdraw: move 20(a6),d3	;hist pointer
 and #12,d3
 move #0,d4
 lea dotz,a4
 move #-1,d2
crappi: move.l 0(a4,d4.w),a0
 move 22(a6,d3.w),d0
 move 24(a6,d3.w),d1
 add #4,d3
 and #12,d3
 bsr syak
 add #4,d4
 cmp #16,d4
 bne crappi
 bra stdraw

dotz: dc.l dot1,dot2,dot3,dot4

drawlazr: move 2(a6),d0
 move 4(a6),d1
 lea lazind,a0
 sub #10,d1
 move #-1,d2
 bsr yak
 tst.b 36(a6)
 beq stdraw
 move 4(a6),d0	;Y pos
 asl #2,d0
 lea ytab,a0
 move.l 0(a0,d0.w),a0	;offset
; lea 8(a0),a0		;where
 move #19,(a2)+		;X size
 move #0,(a2)+		;Y size
 move.l a0,(a2)+	;offset
 add.l a1,a0
 or #$00ff,(a0)
 lea 8(a0),a0
 move #17,d0
drlzr: move #-1,(a0)
 lea 8(a0),a0
 dbra d0,drlzr
 or #$ff00,(a0)
stdraw: bsr getograf
; bra ufs
 move #-1,d2
 bra yak

ozdraw: bra draw_tentacle

cgrunt: dc.w 0
tbmotion: dc.w $0000
maxspd: dc.w $0202


move_grunts: sub.b #1,tbmotion
 bpl rrts
 move.b tbmotion+1,tbmotion
 tst sirius2
 bne rrts
 sub.b #1,maxspd
 bne rrts
 move.b maxspd+1,maxspd
 move cgrunt,d0
 cmp #99,d0
 ble doand
 sub #100,d0
 move d0,cgrunt
doand: move #2,d1
 move #69,d7
m_grus: lea aliens,a6
 movem d0-d1,-(a7)
 asl #6,d0
 lea 0(a6,d0.w),a6
 tst (a6)
 bmi ngruu
 cmp.b #3,1(a6)
 bne ngruu
 bsr doggie
 movem (a7)+,d0-d1
 add #1,d0
 cmp #100,d0
 blt stohl
 sub #100,d0
stohl: sub #1,d1
 bne m_grus
sxend: move d0,cgrunt
 rts
ngruu: movem (a7)+,d0-d1
 add #1,d0
 cmp #100,d0
 blt ngru1
 sub #100,d0
ngru1: dbra d7,m_grus
 rts 

p2taq: dc.w -1
zikx: dc.w 160
ziky: dc.w 100

p2con:
;
;Control Player 2's camel, making it seek Llamas or (if none) you

 tst sirius2
 beq rokeh
 move #-1,p2taq
 rts
rokeh:
 move freecount,d0
 and #1,d0
 bne rrts
 move p2taq,d0	;target acquired?
 bpl do_targ
; cmp #-2,d0
; bne get_targ
 move xend,dummy_alien+2
 move yend,dummy_alien+4
 tst _demo
 beq get_targ
 move freecount,d0
 and #$3f,d0
 bne szik 
 bsr rannum
 ext d0
 add #160,d0
 move d0,zikx
 bsr rannum
 ext d0
 asr #1,d0
 add #100,d0
 move d0,ziky
szik: move zikx,dummy_alien+2
 move ziky,dummy_alien+4

; bra do_targ
get_targ: move #0,d0
 lea aliens,a0
 move nllama,d1
 move #69,d2
 beq shome_c
 bmi shome_c
seekal_c: cmp.b #5,1(a0)	;free Llama?
 beq gotlla_c 
kokal_c: lea 64(a0),a0
 add #1,d0
 sub #1,d2
; cmp d0,d1
 beq shome_c
 bra seekal_c
shome_c: move #-2,p2taq	;do Seek Me instead
 bra do_targ
gotlla_c: move d0,p2taq		;set TAQ flag
 rts

do_targ: cmp #-2,p2taq
 bne nuffunc  
 lea dummy_alien,a0
 bra kiilc
nuffunc: asl #6,d0	;get llama target #
 lea aliens,a0
 lea 0(a0,d0.w),a0	;address llama
 cmp.b #5,1(a0)		;still free
 beq kiilc
 move #-1,p2taq
 bne get_targ		;Llama killed or transformed- reseek
kiilc:
; bsr hitllama
; bne llakill
doki1c: move 2(a0),d0
 sub xpos2,d0
 move 4(a0),d1
 sub ypos2,d1
 move d0,d2
 bpl dkr0c
 neg d2
dkr0c: move d1,d3
 bpl dokr1c
 neg d3
dokr1c: cmp #8,d2
 bge appraic
 cmp #8,d3
 bge appraic
; cmp #-2,p2taq
; beq yotsudamac
; move #9,(a0)
; sub #1,nllama
; move #-1,58(a0)
appraic: cmp #2,d2
 ble dokr21c
 cmp #1,d3
 ble dokr22c
shifkac: asr #1,d0
 asr #1,d1
 asr #1,d2
 asr #1,d3
 bra appraic
dokr21c: cmp #1,d3
 bgt shifkac
dokr22c: cmp #2,d2
 bgt shifkac
 move #5,gbase2
 move #0,orie2
 move d0,vx2
 bmi krisp
 move #1,gbase2
 move #6,orie2
krisp: move d1,vy2
 add d0,xpos2
 add d1,ypos2
 rts


nllama: dc.w 0

dummy_alien: ds.b 64

dokill: tst sirius2
 bne rrts 
 move freecount,d0
 and #7,d0
 bne rrts
 move 20(a6),d0	;target acquired?
 bpl dokka
 cmp #-2,d0
 bne seeek
 move cxpos,dummy_alien+2
 move cypos,dummy_alien+4
 bra dokka
seeek: move #0,d0
 lea aliens,a0
 move nllama,d1
 beq shome
seekal: cmp.b #5,1(a0)	;free Llama?
 beq gotlla 
kokal: lea 64(a0),a0
 add #1,d0
 bra seekal
gotlla: tst 24(a0)
 beq ygotlla
 sub #1,d1
 bne kokal	;no target
shome: move #-2,20(a6)	;do Seek Me instead
 rts
ygotlla: move #1,24(a0)	;blight Llama
 move d0,20(a6)		;set TAQ flag
 rts
dokka: move 8(A6),d2
 bpl dokka1
 neg d2
dokka1: move 10(a6),d3
 bpl dokka2
 neg d3
dokka2: cmp d2,d3
 ble x_ori
 move #2,d4
 tst 10(a6)
 bmi do_oriy
 add #2,d4
do_oriy: move 4(a6),d5
 asr #2,d5
 and #1,d5
 add d5,d4
 bra orie
x_ori: move #0,d4
 tst 8(a6)
 bmi do_orix
 move #6,d4
do_orix: move 2(a6),d5
 asr #2,d5
 and #1,d5
 add d5,d4
orie: tst 22(a6)
 beq oryx
 sub #1,22(a6)
 add #9,d4
oryx: add #43,d4
 move d4,12(a6)
 cmp #-2,20(A6)
 bne nuffun  
 lea dummy_alien,a0
 bra kiil
nuffun: asl #6,d0	;get llama target #
 lea aliens,a0
 lea 0(a0,d0.w),a0	;address llama
 cmp.b #5,1(a0)		;still free
 bne seeek		;Llama killed or transformed- reseek
kiil: bsr hitllama
 bne llakill
doki1: move 2(a0),d0
 sub 2(a6),d0
 move 4(a0),d1
 sub 4(A6),d1
 move d0,d2
 bpl dkr0
 neg d2
dkr0: move d1,d3
 bpl dokr1
 neg d3
dokr1: cmp #8,d2
 bge apprai
 cmp #8,d3
 bge apprai
 cmp #-2,20(a6)
 beq yotsudama
 move #9,(a0)
 sub #1,nllama
 move #-1,58(a0)
yotsudama: move #-1,20(a6)
 move #51,12(a0)
 move #20,20(a0)
 movem.l d1/a0,-(A7)
 move #23,d0
 move #2,d1
 move #6,d2
 bsr rsonic
 movem.l (a7)+,d1/a0 
 rts
apprai: cmp #3,d2
 ble dokr21
 cmp #3,d3
 ble dokr22
shifka: asr #1,d0
 asr #1,d1
 asr #1,d2
 asr #1,d3
 bra apprai
dokr21: cmp #3,d3
 bgt shifka
dokr22: cmp #3,d2
 bgt shifka
 move d0,8(A6)
 move d1,10(A6)
 add d0,2(a6)
 add d1,4(a6)
 rts

gcr: dc.w 0

dogrunt: add #1,gcr
 tst sirius2
 bne rrts 
doggie: bsr hitllama
 bne llakill
dogi1: sub #1,20(a6)
 bpl rrts
 move gcv,20(a6)
 move xpos,d0
 move ypos,d1
 btst #1,pmode
 beq whico
 btst #0,d7
 beq whico
 move xpos2,d0
 move ypos2,d1
whico: sub 2(a6),d0
 sub 4(A6),d1
 move d0,d2
 bpl dgr0
 neg d2
dgr0: move d1,d3
 bpl dogr1
 neg d3
dogr1: cmp tbspdx,d2
 ble dogr21
 cmp tbspdy,d3
 ble dogr22
shifa: asr #1,d0
 asr #1,d1
 asr #1,d2
 asr #1,d3
 bra dogr1
dogr21: cmp tbspdy,d3
 bgt shifa
dogr22: cmp tbspdx,d2
 bgt shifa
 move d0,8(a6)
 move d1,10(a6)
; move #8,6(a6)		;force Move And Update
 eor #1,40(a6)
 bra moveit



hitllama: tst xllama
 bne qq1
 move 2(a6),d0
 sub xpos,d0
 bpl aa1
 neg d0
aa1: cmp #16,d0 
 bge qq1
 move 4(a6),d0
 sub ypos,d0
 bpl bb1
 neg d0
bb1: cmp #10,d0
 bge qq1
 move #1,d0
 bra rr1
qq1: move #0,d0
 
rr1: tst xllama2
 bmi qq12
 btst #1,pmode
 beq qq12
 move 2(a6),d1		;Llama 2 detecol returns bit 1 of result
 sub xpos2,d1
 bpl aa12
 neg d1
aa12: cmp #16,d1 
 bge qq12
 move 4(a6),d1
 sub ypos2,d1
 bpl bb12
 neg d1
bb12: cmp #10,d1
 bge qq12
rr12: or #2,d0
qq12: tst d0
 rts  


fixx: move 2(a6),d0
 move 4(a6),d1
 move #3,6(a6)
; bra ufs

 move #-1,d2
 lea objex,a0
 move 12(A6),d5
 bpl foob3
 move.l 44(a6),a0
 bra yak
foob3:
 asl #2,d5
 move.l 0(a0,d5.w),a0
 bra yak

drawmove: move 40(a6),d0
 and #1,d0
 move nowgrunt,d1
 asl #1,d1
 or d0,d1
 asl #2,d1
 lea grunties,a4
 move.l 0(a4,d1.w),a0
 move 2(a6),d0
 move 4(a6),d1
 move #-1,d2
 bra yak

 move.l back_screen,a1
 move.l a2,-(a7)
 bsr syak 
 move.l (a7)+,a2
 move.l ascreen,a1
 bra yak

folla: move.l 30(a6),a0
 cmpa.l #trail2,a0
 bne teepee1
 move trailp2,d0
 bra teepee2
teepee1: move trailp,d0
teepee2: sub 20(a6),d0
 and #$3f8,d0
 lea 0(a0,d0.w),a0
 move (a0),2(A6)
 move 2(A0),4(a6)
 move 4(a0),d0
 beq setxx
 cmp #6,d0
 beq setxx
 move 4(a6),d1
ete: asr #2,d1
 and #1,d1
 add d1,d0
 add 48(a6),d0
 move d0,12(A6)
 rts
setxx: move 2(a6),d1
 bra ete

spbon: dc.w 0
spbon1: dc.w 0
spbon2: dc.w 0

dolla: move #0,16(a6)	;not a target!
***  hit_llama
 move 2(a6),d0
 sub xpos,d0
 bpl faa
 neg d0
faa: cmp #16,d0 
 bge qq
 move 4(a6),d0
 sub ypos,d0
 bpl bb
 neg d0
bb: cmp #10,d0
 bge qq
 move #1,d0
 bra rr
qq: move #0,d0
rr: btst #0,pmode
 beq qq2
 move 2(a6),d1
 sub xpos2,d1
 bpl aa2
 neg d1
aa2: cmp #16,d1 
 bge qq2
 move 4(a6),d1
 sub ypos2,d1
 bpl bb2
 neg d1
bb2: cmp #10,d1
 bge qq2
 or #2,d0

qq2: tst d0
 beq doll2
 move d0,-(a7)
 bsr rannum
 cmp #40,d0
 bge qq2qq
 move #6,purq
qq2qq: move (a7)+,d0
 sub #1,llamaco
 bne qq2q
 move #5,purq
 btst #0,pmode
 beq qq2q3
 move #7,purq
 move d0,-(a7)
 bsr rannum
 cmp #40,d0
 ble shilton
 move #8,purq
shilton: move (a7)+,d0
qq2q3: movem.l d0-d3/d7/a6,-(a7)
 move #26,d0
 move #1,d1
 move #6,d2
 bsr sonic
 move #0,d0
 move #4,d1
 bsr doscore
 movem.l (a7)+,d0-d3/d7/a6
 move #1,spbon
qq2q: btst #0,pmode
 beq qq21
 and #2,d0
 beq qq21		;hit was Player 1
 tst spbon
 beq arab1
 move ypos2,spbon2
 sub #10,spbon2
arab1: add #$28,clap2
 move clap2,20(a6)
 move.l #trail2,30(a6)
 btst #1,pmode
 beq fiveh
 move #24,d0
 move #6,d1
 bra skonn
fiveh: move #4,d0
 move #5,d1
skonn: movem.l d7/a6,-(a7)
 bsr doscore		;500 beasty bonus
 movem.l (a7)+,d7/a6
 bra donkky
 
qq21: move #4,d0
 move #5,d1
 movem.l d7/a6,-(a7)
 bsr doscore		;500 beasty bonus
 movem.l (a7)+,d7/a6
 move #80,d0
 move clock,d1
 asr d1,d0
 move d0,bigfire
 btst #1,pmode
 beq zzill
 move #40,d0
 move clock,d1
 asr d1,d0
 move d0,bigfire
zzill: tst spbon
 beq arab2
 move ypos,spbon1
 sub #10,spbon1
arab2: add #$28,clap
 move clap,20(a6)
 move.l #trail,30(a6)
donkky: move #-1,58(a6)
 move #0,spbon
 move #69,54(a6)
 move #20,56(a6)
 move.l 2(a6),50(a6) 
 sub #1,nllama
 move #80,d0
 move clock,d1
 asr d1,d0
 move d0,bigfire
 btst #1,pmode
 beq zzill2
 move #40,d0
 move clock,d1
 asr d1,d0
 move d0,bigfire
zzill2:
 move #6,(a6)
 move #23,d0		;was 5
 move #1,d1
 move #3,d2
 bra sonic
doll2: tst luv
 bpl dolove
 sub #1,20(a6)
 bpl doll1
 bsr rannum
 and #$0f,d0
 add #10,d0
 move d0,20(a6)
 bsr rannum
 and #7,d0
 asl #1,d0
 lea llavex,a0
 move 0(a0,d0.w),8(a6)
 move 16(a0,d0.w),10(a6)
 move 24(a0,d0.w),22(a6)
 bra doll1

dolove: move #1,d0
 move #6,d2
 move 2(a6),d1
 sub cxpos,d1
 bmi dolo1
 neg d0
 clr d2
dolo1: move d0,8(a6)
 move d2,22(a6)
 move #1,d0
 move 4(a6),d1
 sub cypos,d1
 bmi dolo2
 neg d0
dolo2: move d0,10(a6) 


 
doll1: move freecount,d0
 and #1,d0
 bne arka
 bsr moveit
arka: tst 8(a6)
 bne hor_or
 move 4(a6),d0
doan: asr #2,d0
 and #1,d0
 add 22(A6),d0
 add 48(a6),d0
 move d0,12(A6)
 rts

hor_or: move 2(A6),d0
 bra doan
  
bons: dc.w 0
moveit: clr bons
moveit0: move 2(a6),d0
 add 8(A6),d0
 cmp #8,d0
 blt refx
 cmp #312,d0
 ble moveity
refx: neg 8(a6)
 move #1,bons
 bra moveit0
moveity: move d0,2(a6)
myy: move 4(a6),d0
 add 10(a6),d0
 cmp #16,d0
 blt refy
 cmp #188,d0
 ble moveitz
refy: neg 10(a6)
 move #1,bons
 cmp #100,d0
 blt myy
 move #187,d0
 
moveitz: move d0,4(A6)
 rts

doskull: sub #1,20(a6)
 bpl rrts
 move #-1,(a6)
 add #1,afree
 rts

dofhg: bsr hitllama
 bne llakill
 move freecount,d0
 asr #1,d0
 and #3,d0
 add 28(a6),d0
 move d0,12(a6)
 tst sirius2
 bne rrts
 tst 22(a6)	;spawn timer
 bpl d1fhg
 sub.b #1,24(a6)	;launch interval timer
 bpl d2fhg
 move.b 25(a6),24(a6)	;reset LIT
 tst 26(a6)		;launch quota
 beq d2fhg		;allgone
; tst afree
; bmi d2fhg		;no als free
; beq d2fhg

 sub #1,26(A6)		;dec LQ
 bsr gaia
 bpl d2fhg
 move #64,12(a0)	;object # - fire hydrant
 move #0,20(a0)		;zero - acquires velocity straightaway
 move #$003f,22(a0)	;Fire freq
 move #$0c,(a0)		;activate hydrant
 add #1,aon
 movem.l d1/a0,-(A7)
 move #8,d0
 move #1,d1
 move #3,d2
 bsr sonic
 movem.l (a7)+,d1/a0 
 bra d2fhg
d1fhg: sub #1,22(a6)
d2fhg: sub #1,20(a6)
 bpl moveitslide
dv1: bsr rannum
 and #3,d0
 sub #1,d0
 beq dv1
 move d0,8(A6)
dv2: bsr rannum
 and #3,d0
 sub #1,d0
 beq dv2
 move d0,10(a6)
 bsr rannum
 and #$1f,d0
 add #$1f,d0
 move d0,20(a6)

moveitslide: move 8(a6),d0
 add 2(a6),d0
 cmp #8,d0
 ble msly
 cmp #312,d0
 bge msly
 move d0,2(A6)
msly: move 10(a6),d0
 add 4(a6),d0
 cmp #16,d0
 ble rrts
 cmp #192,d0
 bge rrts
 move d0,4(a6)
 rts
 
gaia: lea aliens,a0
 move #69,d3
skjj: tst (a0)
 bmi gally
 lea 64(a0),a0
 dbra d3,skjj		;get free alien
 move #0,d3
 rts
gally: sub #1,afree	;keep alien tally
 move.l 2(a6),2(a0)	;copy X and Y
 move.l #0,8(a0)	;zero X and Y velocity
 move #13,6(a0)		;instant full draw
 move #0,14(a0)
 move #1,16(a0)		;shootable
 move #0,62(a0)		;type 0 std xplsion
 move #0,50(a0)
 move #-1,58(A0)	;not part of std wave rez
 move #9,60(a0)
 move #-1,d3
 rts
*
afree: dc.w 0

dofhy: bsr hitllama
 bne llakill
 sub.b #1,22(a6)
 bpl dfhy1
 move.b 23(a6),22(a6)
 bsr gaia
 bpl dfhy1
 move #65,12(a0)
 move #2,d4
 move #1,d5
 bsr vec2u
 move d0,8(a0)
 move d1,10(a0)
 move #$0d,(a0)
 add #1,aon   
dfhy1: sub #1,20(a6)
 bpl moveit
 bsr rannum
 and #$7f,d0
 add #$20,d0
 move d0,20(a6)
 move #2,d4
 move #1,d5
 bsr vec2u
 move d0,8(a6)
 move d1,10(A6)
 rts

dofhyp: bsr hitllama
 bne llakill
 move freecount,d0
 asr #2,d0
 and #3,d0
 add #65,d0
 move d0,12(a6)
moveitk: move 8(a6),d0
 add 2(a6),d0
 cmp #8,d0
 ble mkk
 cmp #312,d0
 bge mkk
 move d0,2(A6)
 move 10(a6),d0
 add 4(a6),d0
 cmp #16,d0
 ble mkk
 cmp #192,d0
 bge mkk
 move d0,4(a6)
 rts
mkk: move #-1,(a6)
 add #1,afree
 sub #1,aon
 rts

vec2u: move cxpos,d0	;get vector towards U. max vel in d4
 sub 2(a6),d0
 move cypos,d1
 sub 4(A6),d1
 move d0,d2
 bpl vdgr0
 neg d2
vdgr0: move d1,d3
 bpl vdogr1
 neg d3
vdogr1: cmp d4,d2
 ble vdogr21
 cmp d5,d3
 ble vdogr22
vshifa: asr #1,d0
 asr #1,d1
 asr #1,d2
 asr #1,d3
 bra vdogr1
vdogr21: cmp d5,d3
 bgt vshifa
 rts
vdogr22: cmp d4,d2
 bgt vshifa
 rts

diginslot:
;
;write digit d1, in screen slot d0, on a/bscreen

 move.l ascreen,a1
 move.l bscreen,a2
 move.l back_screen,a4
 asl #4,d1		;8 words per digit
 lea numbers,a3		;get font defs
 lea 0(a3,d1.w),a3	;digit at a3
 move #0,d2		;ror count
 move #$ff,d3		;data mask
 btst #0,d0
 beq nior
 move #8,d2		;is 8 for odd slots
 move #$ff00,d3		;opposite data mask
nior: move #7,d4
 and #$fe,d0		;lose low bit of slot data
 asl #2,d0		;point to slot #
 lea 0(a1,d0.w),a1
 lea 0(a2,d0.w),a2	;point at screen
 lea 0(a4,d0.w),a4
nior1: move (a3)+,d5	;get data
 ror d2,d5		;align
 and d3,(a1)
 and d3,(a2)		;make hole
 and d3,(a4)
 or d5,(a1)
 or d5,(a2)		;slot data
 or d5,(a4)
 lea 160(a1),a1
 lea 160(a2),a2		;jack to next line
 lea 160(a4),a4
 dbra d4,nior1
 rts

laminslot:
;
;write llama in screen slot d0, on a/bscreen+bak

 lea lli1,a3
 btst #4,pmode
 beq isp11
 lea lli2,a3
isp11:  move.l ascreen,a1
 move.l bscreen,a2
 move.l back_screen,a4
 move #0,d2		;ror count
 move #$ff,d3		;data mask
 btst #0,d0
 beq niorq
 move #8,d2		;is 8 for odd slots
 move #$ff00,d3		;opposite data mask
niorq: move #7,d4
 and #$fe,d0		;lose low bit of slot data
 asl #2,d0		;point to slot #
 lea 4(a1,d0.w),a1
 lea 4(a2,d0.w),a2	;point at screen
 lea 4(a4,d0.w),a4
niorq1: move (a3)+,d5	;get data
 ror d2,d5		;align
 and d3,(a1)
 and d3,(a2)		;make hole
 and d3,(a4)
 or d5,(a1)
 or d5,(a2)		;slot data
 or d5,(a4)
 lea 160(a1),a1
 lea 160(a2),a2		;jack to next line
 lea 160(a4),a4
 dbra d4,niorq1
 rts

show_lives: move #9,d0
 btst #4,pmode
 beq shewl
 move #26,d0
shewl: move #4,d1
clssl: movem d0-d1,-(a7)
 bsr clrslot
 movem (a7)+,d0-d1
 add #1,d0
 dbra d1,clssl
 sub #5,d0
 move lives,d1
 sub #2,d1
 bmi showl
 cmp #4,d1
 ble skud
 move #4,d1
skud: movem d0-d1,-(a7)
 bsr laminslot
 movem (a7)+,d0-d1
 add #1,d0
 dbra d1,skud
showl: rts 

clrslot: move d0,d2
 move #$ff,d3
 btst #0,d2
 beq recce
 move #$ff00,d3
recce: move.l ascreen,a0
 move.l bscreen,a1
 move.l back_screen,a2
 and #$fe,d2
 asl #2,d2
 lea 4(a0,d2.w),a0
 lea 4(a1,d2.w),a1
 lea 4(a2,d2.w),a2
 move #7,d4
wrongs: and d3,(a0)
 and d3,(a1)
 and d3,(a2)
 lea 160(a0),a0
 lea 160(a1),a1
 lea 160(a2),a2
 dbra d4,wrongs
 rts

show_wave: move #16,d0
 btst #4,pmode
 beq showwa1
 move #22,d0
showwa1: move level,d1
 add #1,d1
 ext.l d1
 divu #10,d1
 cmp #9,d1
 ble showwa2
 move #9,d1
showwa2: movem.l d0-d1,-(A7)
 bsr diginslot
 movem.l (a7)+,d0-d1
 add #1,d0
 swap d1
 bra diginslot


show_score:
;
;display score at (a0) starting at slot d0

 move d0,d6
 and #$fe,d6
 asl #2,d6	;starting slot offset
 move #7,d7	;up to 8 digits
shsc1: move.b (a0)+,d1
 bne shsc2	;non-zero, display whole score left
 add #1,d0
 dbra d7,shsc1	;go for first nonzero
 sub #2,d0
 move #0,d1
 movem d0-d1,-(a7)
 bsr diginslot
 movem (a7)+,d0-d1
 add #1,d0
 bsr diginslot	;display a couple of token zeros
 bra xtobak
shsc2: and #$ff,d1
 movem d0-d1,-(a7)
 bsr diginslot
 movem (a7)+,d0-d1
 add #1,d0
 move.b (a0)+,d1
 dbra d7,shsc2
xtobak: rts
 move.l ascreen,a0
 move.l back_screen,a1
 lea 0(a1,d6.w),a1
 lea 0(a0,d6.w),a0
 move #7,d1
xtob1: move #3,d0
xtob2: move (a0)+,(a1)+
 lea 6(a0),a0
 lea 6(a1),a1
 dbra d0,xtob2
 lea 128(a0),a0
 lea 128(a1),a1
 dbra d1,xtob1
 rts

swap_p2: lea lives,a0
 lea p2space,a1
 move #49,d0
gasmask: move.l (a0),d1
 move.l (a1),(a0)+
 move.l d1,(a1)+
 dbra d0,gasmask
kopout: bchg #4,pmode
 rts

set_p2: btst #2,pmode
 beq rrts
 lea lives,a0
 lea p2space,a1
 move #49,d0
gmask1: move.l (a0)+,(a1)+
 dbra d0,gmask1
 rts

ufs:
;
; Ultra fast 16xn sprite routine.

 move #0,(a2)+		;X width=1
 move 4(a0),(a2)+		;Y height
 move d0,d2
 and #$0e,d2
 asl #1,d2		;SMC address offset
 asl #2,d1
 lea ytab,a3
 move.l 0(a3,d1.w),d3	;Y line offset
 asr #1,d0
 and #$fff8,d0		;X offset
 add d0,d3		;X+Y offset
 move.l d3,(a2)+	;address for undraw
 lea 0(a1,d3.w),a3	;real screen address
 move.l 8(a0),a0	;get SMC base
 move.l 0(a0,d2.w),a0	;get correct shift SMC
 jmp (a0)		;execute SMC


make_smc:
;
;Generate sprite code in SMCBUF for the sprite addressed by (a0).
;SMC-code is preshifted, and requires 44x8=352
;bytes per scanline for just a 16-pixel wide sprite. This makes
;it expensive but it is SHIT fast.

 tst smc_aborted
 bne rrts
 cmp #3,(a0)
 bne rrts		;Only do type-3
 tst 2(a0)
 bne rrts		;and only up to 16 pixels
 move.l smcptr,a1	;Get current SMC pointer
 move.l a1,a2
 lea 32(a2),a2		;a1 generates SMC bases; a2 is current addr.
 move #0,(a0)		;set=Type 0 <SMC/16>
 move.l a1,8(a0)	;provide SMC address
 move #0,d0		;ROL counter

m_smc0: move 4(a0),d1	;scanline DBRA
 lea 12(a0),a3		;data address
 move.l a2,(a1)+	;SMC address
m_smc1: move #1,d5	;bitplane counter
 cmp.l smcend,a2
 bge smc_abort
 move #$283c,(a2)	;move mask to d4
 move #$283c,22(a2)	;second-half
 move (a3),d2
 or 2(a3),d2
 or 4(a3),d2
 or 6(a3),d2		;get mask
 and.l #$ffff,d2
 eor.l #-1,d2		;negate it
 ror.l d0,d2		;rotate it
 move d2,2(a2)
 move d2,4(a2)
 swap d2
 move d2,24(a2)
 move d2,26(a2)		;mask is in SMC
 lea 6(a2),a4
m_smc: move #$c993,(a4)	;AND D4 instruction
 move #$c993,22(a4)	;for half 2
 move #$009b,2(a4)	;OR instruction
 move #$009b,24(a4) 
 clr.l d2
 clr.l d3
 move (a3)+,d2
 move (a3)+,d3		;get Planes 0/1
 ror.l d0,d2
 ror.l d0,d3
 move d2,d4		;Plane 0
 swap d4
 move d3,d4		;d4.L has planes 0/1 combined
 move.l d4,4(a4)	;data
 swap d2
 swap d3		;get secondhalf data
 move d2,d4
 swap d4
 move d3,d4
 move.l d4,26(a4)
 lea 8(a4),a4		;skip for 'planes 3 and 4
 dbra d5,m_smc		;do whole scanline
 lea 44(a2),a2		;skip past scanline block
 move.l #$47eb0090,(a2)+	;make LEA instruction
 dbra d1,m_smc1		;do all scanlines
 lea -4(a2),a2
 move #$4e75,(a2)+	;make RTS
 add #2,d0		;ROR count increment
 cmp #16,d0
 bne m_smc0		;iterate for all preshifts
 move.l a2,smcptr	;replace pointer
 rts			;finished.

smc_abort: move #1,smc_aborted
 move #3,(a0)
 rts

smc_aborted: dc.w 0

expand:
;
;Like PSI-Expand. Pass a0=list of sprites. Converts them to
;SMC-format and returns if -1 is encountered.

 move #0,smc_aborted
 move.l (a0)+,d0
 cmp.l #-1,d0
 beq rrts
 move.l a0,-(a7)
 move.l d0,a0
 bsr make_smc
 move.l (a7)+,a0
 bra expand

contract:
;
;Like PSI-Expand. Pass a0=list of sprites. Converts them to
;SMC-format and returns if -1 is encountered.

 move.l (a0)+,d0
 cmp.l #-1,d0
 beq rrts
 move.l d0,a1
 move #3,(a1)
 bra contract

lsize: dc.w 2,4,4,2,2,2,3,1

ex_wave: lea exes,a3 ;list of expanded sprites
 move #0,smc_abort
 move.l #-1,(a3)
 move.l old_smcptr,smcptr
 move nowgrunt,d1
 asl #3,d1
 lea grunties,a4
 lea 0(a4,d1.w),a4
 move.l (a4),a0
 move.l a0,(a3)+
 movem.l a0-a4,-(a7)
 bsr make_smc		;expand it
 movem.l (a7)+,a0-a4
 move.l 4(a4),a0
 movem.l a0-a4,-(a7)
 bsr make_smc		;expand it
 movem.l (a7)+,a0-a4
 move.l a0,(a3)+

 move level,d0
 and #3,d0
 asl #1,d0
 lea lex,a4
 move 0(a4,d0.w),d0
 move d0,clex
 lea objex,a4
 asl #2,d0
 move.l 0(a4,d0.w),a0
 movem.l a0-a3,-(a7)
 bsr make_smc
 movem.l (a7)+,a0-a3
 move.l a0,(a3)+

 move level,d0
 asl #2,d0
 lea levtab,a2
 move.l 0(a2,d0.w),a2	;address of level table
shada: move.b (a2)+,d0
 bpl nxxn
 ext d0
 neg d0
 sub #1,d0
 asl #1,d0
 lea lsize,a5
 move 0(a5,d0.w),d0
 lea 0(a2,d0.w),a2
 bra shada
nxxn: move.b (a2)+,d0	;get type #
 bmi ex_next
 sub.b #2,d0
 bmi ex_next
 and #$ff,d0
 asl #2,d0
 lea n_table,a0
 move 0(a0,d0.w),d1	;get gbase
 move 2(a0,d0.w),d0	;get # to expand
nxxn_l: lea objex,a0
 move d1,d2
 asl #2,d2
 move.l 0(a0,d2.w),a0	;sprite ID
 move.l a0,(a3)+	;in contract list
 movem.l d0-d3/a0-a3,-(a7)
 bsr make_smc		;expand it
 movem.l (a7)+,d0-d3/a0-a3
 add #1,d1
 dbra d0,nxxn_l		;expand all in this pair
 bra exoo
ex_next: tst.b (a2)
 bmi ex_end
exoo: lea 1(a2),a2 
 bra nxxn
ex_end: lea beastys,a2
 move level,d0
 and #3,d0
 asl #2,d0
 move.l 0(a2,d0.w),a2	;address of beastie rack
 move #7,d0
exeee: move.l (a2)+,a0
 move.l a0,(a3)+
 movem.l d0-d3/a0-a3,-(a7)
 bsr make_smc		;expand it
 movem.l (a7)+,d0-d3/a0-a3
 dbra d0,exeee
 lea would_be_nice,a2
ewbn: move.l (a2)+,a0
 cmp.l #-1,a0
 beq dep
 move.l a0,(a3)+
 movem.l d0-d3/a0-a3,-(a7)
 bsr make_smc		;expand it
 movem.l (a7)+,d0-d3/a0-a3
 bra ewbn
dep: move.l #-1,(a3)
 rts

scrolling: dc.w 0
clex: dc.w 33

print:
;
; Print a string, with imbedded control commands.
; Enter with the address of yer string in a0.
; Commands are preceded by a \ character. The following
; are recognized:
;
; \r  CR/LF
; \e  End printing
; \u, \d, \l, \r  Move print position up, down, left, right
; \s Set font # (follow with numeric)
; \g Go to screen position (follow with 2 numerics)
; \n Print current value of NUMVAL.S, no trailing spaces
; \c Set text colour; -ve = original bitmap
; \q Draw text as centred on current v. line until 0
; Before printing, set TXTMODE to hit the screen(s) you need
; and set TXT_X and TXT_Y to screen position (or use \g)
;
;

 move.l #font,a3	; a3 points to current font info
 move (a3),d5	; get vert step size
 move txt_x,d0
 move d0,retstart	; left margin preserve
 move txt_y,d1	; set up initial cursor position
 move #0,d4	; mask initially
pr_loop:
 move.b (a0)+,d2	; get the char
 beq endpr
 and #$ff,d2
 cmp.b #'\',d2	; control character?
 beq pr_control	; yes, go do control stuff
 movem.l d0-d4/a0-a2,-(a7)
justify: move d2,d3	; get next character
 asl #2,d3
 move.l 2(a3,d3.w),a1	; get sprite def
 add 2(a1),d0	; add xpos of next char
 cmp xmax_real,d0
 bpl unjustify
 move.b (a0)+,d2
 beq ijust
 cmp.b #' ',d2
 beq ijust
 cmp.b #'\',d2
 beq ijust
 bra justify
unjustify:   
 movem.l (a7)+,d0-d4/a0-a2
 move retstart,d0
 tst scrolling
 bne pr_enplus
 add d5,d1	; cr/lf
 cmp #182,d1
 bmi lspace
 tst botchk
 beq lspace
pr_enplus: move d0,txt_x
 move d1,txt_y
; move #1,d0
 rts
botchk: dc.w 0
lspace:
 cmp.b #'\',d2
 beq pr_control
 cmp.b #' ',d2	; Leading spaces after CR/lf discard
 bne maltape
 move.b (a0)+,d2
 bra lspace
ijust:
 movem.l (a7)+,d0-d4/a0-a2
maltape:
 bsr dprint	; handle the printing
 cmp xmax_real,d0	; screen edge?
 bmi pr_loop	; no, print next char
 add d5,d1	; down a line
 move retstart,d0	; force a CR
zik: cmp #182,d1
 bmi pr_loop
 tst botchk
 beq pr_loop
 bra pr_enplus	; carry on printing
pr_control:
 move.b (a0)+,d2 ; what u want me to do?
 cmp.b #'q',d2	; centred text via DCENTXT
 bne pr_c0
 movem.l d0-d7/a0-a6,-(a7)
 move txtcol,d2
 jsr dcentxt
 movem.l (a7)+,d0-d7/a0-a6
prc: move.b (a0)+,d2
 bne prc
 bra pr_loop
pr_c0:
 cmp.b #'r',d2
 bne pr_c1	; not RETURN
 move retstart,d0
 tst scrolling
 bne pr_enplus
 add d5,d1
 bra zik
pr_c1:
 cmp.b #'e',d2
 bne pr_c2	; not END
endpr: move d0,txt_x
 move d1,txt_y	; store cursor stuff
 move #0,scrolling
 tst botchk
 beq pwoo
 move #0,d0
pwoo: rts
pr_c2: cmp.b #'s',d2
 bne pr_c3		;look for SPRITE command
 movem.l d0-d7/a0-a6,-(a7)
 move.b (a0)+,d2
 move d2,d3
 asl #8,d3
 and #$ff00,d3
 move.b (a0)+,d2
 and #$ff,d2
 or d2,d3		;get object #
 asl #2,d3
 lea objex,a0
 move.l 0(a0,d3.w),a0	;object
 move 6(a0),d2
 move d2,aika
 asr #1,d2
; add d2,aika
 add d2,d0 
 move.l scrscrn,a1
 lea lscreen,a2
 move #-1,d2
 move #10,d1
 bsr yak
 movem.l (a7)+,d0-d7/a0-a6
 lea 2(a0),a0
 add aika,d0
 bra pr_loop
aika: dc.w 0
 
pr_c3: cmp.b #'u',d2
 bne not_up
 sub d5,d1
 bra pr_loop
not_up:
 cmp.b #'d',d2
 bne not_down
 add d5,d1
 bra pr_loop
not_down: cmp.b #'l',d2
 bne not_left
 sub d5,d0
 bra pr_loop
not_left: cmp.b #'i',d2
 bne not_right 
 add d5,d0
 bra pr_loop
not_right:
 cmp.b #'s',d2
 bne notsize
; move.b (a0)+,d2
; and #$0f,d2
; move d2,cfont
; asl #2,d2
; move.l #font_list,a3
; move.l 0(a3,d2.w),a3
; move (a3),d5
; bra pr_loop
notsize:
 cmp.b #'g',d2
 bne numm
 move.b (a0)+,d0
 and #$ff,d0
 move d0,retstart
 move.b (a0)+,d1
 and #$ff,d1
 bra pr_loop
numm:
 cmp.b #'c',d2
 bne nummi
 move.b (a0)+,d2
 and #$0f,d2
 move d2,txtcol
 bne pr_loop
 move #-1,txtcol
 bra pr_loop
nummi:
 cmp.b #'n',d2
 bne pr_loop
 move.l #num_buff,a2
 move numval,d6
 beq pr_loop
 and.l #$ffff,d6
 move #5,d7
 move.l d6,d2
skorp:
 cmp #10,d2
 bmi goka
 divs #10,d2
 swap d2
goka: add #$30,d2
 move.b d2,0(a2,d7.w)
 swap d2		; remainda is hi word
 tst d2
 beq gozero
 ext.l d2
 dbra d7,skorp  
gozero:
 move.b 0(a2,d7.w),d2
 and #$ff,d2
 move d2,d6
 asl #2,d6
 move.l 2(a3,d6.w),a1	; get sprite def
 move 2(a1),d6	; add xpos of next char
 movem.l d0-d7/a0-a3,-(a7)
 bsr dprint
 movem.l (a7)+,d0-d7/a0-a3
 add d6,d0
 add #1,d7
 cmp #6,d7
 bne gozero
 bra pr_loop
num_buff: ds.b 6

qad: dc.w 0


 	
dprint:
;
; Print a character according to TXTMODE
;
 movem.l d0-d5/a0-a3,-(a7)
 move d2,d6
 asl #2,d6	; point to char sprite image
 move.l 2(a3,d6.w),d6
 beq dpr4	; ignore non-defined chars
 move.l d6,a0	; sprite data start-point
 move 2(a0),qad	; pixels to add after char draw


 move.l scrscrn,a1
 movem.l d0-d4/a0,-(a7)
 bsr tdraw
 movem.l (a7)+,d0-d4/a0
dpr4: movem.l (a7)+,d0-d5/a0-a3
 add qad,d0
 move #0,qad
 rts

dcentxt:
 move.l a2,-(a7)
 move.l #aliens,a2
 move.l scrscrn,a1
 move d2,txtcol
 move #0,d2
 jsr centxt
 move.l (a7)+,a2
 rts

centxt:
;
; Draw centred line of text using current font
; Centred on line d1, text at (a0), screen at (a1)
; unDraw list (a2), text expansion factor d2. Text
; must be zero-terminated. Font # in cfont.
;
 move.l #font,a3
 move #0,d4		; d4 will be total width ctr
 move.l a0,a4
gsize: move.b (a0)+,d3
 beq gsize_ex
 and #$ff,d3
 asl #2,d3
 move.l 2(a3,d3.w),a5	; point to char data base
 add 2(a5),d4		; add normal X-offset
; add d2,d4		; add given expansion constant
 bra gsize		; loop until zero found
gsize_ex: move d4,last_c
gsize_e:
 asr #1,d4		; halve text size
 neg d4			; negate it
 add #160,d4		; and add to 160 to centre it
 move d4,d0		; is X-start of drawn text
drtex: move.b (a4)+,d3
 beq drtex_e 
 and #$ff,d3
 asl #2,d3
 move.l 2(a3,d3.w),a0	; get tex sprite
 movem.l d0-d2/a0-a1/a3-a4,-(a7)
 jsr tdraw
 movem.l (a7)+,d0-d2/a0-a1/a3-a4
 add 2(a0),d0
; add d2,d0
 bra drtex
drtex_e: rts		; drawn centred string 

tdraw:
;
; This is a special 16xn nonshifted sprite routine
; for drawing characters on the screen. It has been modified
; so that the chars will be drawn in original colours (TXTCOL<0)
; or in the colour specified if TXTCOL is not negative.
;
 move.l #ytab,a2	; ytab is vertical-offset table
 move 4(a0),d2	; vert size in scan lines
 lea 6(a0),a0
 move.l #8,a4	; all scanlines 8bytes long
 cmp ymint,d1	; check if y is onscreen
 bpl fw_top	; yes, no need to clip top of sprite
 move d1,d5	; working copy of y position
 add d2,d5	; move to bottom pos of sprite
 cmp ymint,d5	; bottom edge offscreen to top?
 bpl foff	; no
 rts		; yes
foff:
 move d1,d6	; copy of y position
 sub ymint,d6	; make limit relative to border
 neg d6		; how many scan lines above screen top?
 ext.l d6
 asl.l #3,d6	; multiply by 8
 add.l d6,a0	; move pointer up past redundant sprite data
 move ymint,d1	; sprite starts at y=0 now
 bra fi_2	; go do bottom-edge stuff
fw_top:
 move d1,d5	; copy of y position
 add d2,d5	; d5 is sprite maxheight
fi_2:
 cmp ymax,d5	; Sprite hanging off bottom?
 bmi fi_3	; No
 beq fi_3	; no
 cmp ymax,d1	; start off bottom?
 bmi finan	; no
 beq finan	; no
 rts		; yas.
finan:
 move ymax,d5	; make y max the bottom line
fi_3:
 sub d1,d5	; calc height of sprite in scanlines
 move d0,d6	; working copy of x position
 asr #4,d6	; reduce to 'slots'
 cmp xmax,d6	; off screen?
 bmi ffon	; no
 beq fn_sur	; no
 rts		; yes
fn_sur:
 move #1,right_suppress
 bra fxx	; extreme RHS, suppress right sprite
ffon:
 move #0,right_suppress
fxx: move #0,left_suppress	; clear left & right clip flags
 cmp xmin,d6	; LHS of image to be clipped?
 bpl fi_pos	; no
 add #1,d6	; check top slot
 cmp xmin,d6	; still off screen
 bpl fotoff	; no, draw hi words only
fFloyd: rts		; yes
fotoff:
 sub #1,d6		; leave d6 still with logikal slot
 move #1,left_suppress	; Suppress LHS of sprite
fi_pos:
fo_draw:
 move d1,d2	; get y-start
 asl #2,d2	; for offset into longword vector table..
 move.l 0(a2,d2.w),a3	; referenced by ytab
 add.l a3,a1	; a1 has screen y address
 move d6,d2	; fetch logical slot to start drawing sprite
 asl #3,d2	; eight bytes per slot
 ext.l d2	; extend to long..
 add.l d2,a1	; a1 now points to proper screenloke
 add.l d2,a3	; update backg screen ptr too
 move d0,d6	; get xpixel pos'n
 and #$f,d6	; find ro-offset
 move #0,d7	; assume positiv_shift
 cmp #8,d6	; wrap-over?
 bmi f_lid	; no
 move #16,d7
 sub d6,d7	; make left-shift-count
 move d7,d6
 move #1,d7	; tell sys is a shift-left-situation
f_lid: move.l a0,a5
f_loop: move.l a1,a6
 moveq.l #0,d0
 moveq.l #0,d1
 moveq.l #0,d2
 moveq.l #0,d3
 move (a5)+,d0
 move (a5)+,d1
 move (a5)+,d2
 move (a5)+,d3	; prefetch all grafik_data
 move txtcol,d4	; pure or text colour?
 bmi is_pure	; pure
 or d3,d0
 or d2,d0
 or d1,d0	; combine b'plane data
 move d0,d1
 move d0,d2
 move d0,d3	; redistribute it
 and #$f,d4	; limit it
 asl #3,d4	; mul by 8
 move.l #txtmsks,a4
 lea 0(a4,d4.w),a4	; point to colour-masks
 and (a4)+,d0
 and (a4)+,d1
 and (a4)+,d2
 and (a4),d3		; gen right 'plane colours
is_pure:
 tst d7		; left or right shift?
 bne lf_shf
 ror.l d6,d0
 ror.l d6,d1
 ror.l d6,d2
 ror.l d6,d3
 bra gmsk
lf_shf:
 rol.l d6,d0
 swap d0
 rol.l d6,d1
 swap d1
 rol.l d6,d2
 swap d2
 rol.l d6,d3
 swap d3
gmsk: move.l d0,d4
 or.l d1,d4
 or.l d2,d4
 or.l d3,d4		; generate shifted maskk
 eor.l #-1,d4		; negate the mask
 swap d6
 swap d7		; Free up d6 an' d7 for word use
 tst left_suppress	; LHS suppression?
 bne lsupr		; avoid de next bit
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d1,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d2,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d3,d6
 move d6,(a6)+
 bra nlsupr
lsupr:
 lea 8(a6),a6
nlsupr:
 tst right_suppress
 bne fxyt	; zoom to end if RHS-skip
 swap d0
 swap d1
 swap d2
 swap d3
 swap d4	; point to high wordz
 tst d4
 beq fxyt	; allow for no-shift case
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d1,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d2,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d3,d6
 move d6,(a6)+
fxyt:
 swap d6
 swap d7	; restore shift data
 lea 160(a1),a1
 dbra d5,f_loop	; do all scanlines of displayed image
 rts		; done.

clear_sbuffer: lea scroll_buffer,a6
 move #799,d0
clsb: move.l #0,(a6)+
 dbra d0,clsb
 rts

scr_c: dc.w 0
scr_addr: dc.l 0


scroll_out: move #1,scrolling
scrout: move #16,txt_x
 move #6,txt_y
 move.l #scroll_buffer,scrscrn
 bsr clear_sbuffer
 movem.l a1-a2,-(a7)
 bsr print
 movem.l (a7)+,a1-a2
 move #20,scr_c
 move.l #scroll_buffer+8,scr_addr
 move.l #skritt,the_business
 move.l a0,-(a7)
dool: bsr opsprite
 tst hurry
 bne doolq
 sub #1,scr_c
 bne dool
 move.l (a7)+,a0
 tst scrolling
 bne scrout
 rts

doolq: move.l (a7)+,a0
 rts


scroll_back: move #0,hurry
 move #199,scr_c
 move.l back_screen,scr_addr
 move.l #skritt_full,the_business
dool2: bsr opsprite
 tst hurry
 bne xfrombak
 sub #1,scr_c
 bne dool2
 bra xfrombak



skritt: move #2,d0
 move #197,d1
 move #1,d2
 move #17,d3
 bsr scroll
 move.l scr_addr,a4
 move #17,d1
xxyt: move.l (a4)+,(a0)+
 move.l (a4)+,(a0)+
 dbra d1,xxyt
 lea 16(a4),a4
 move.l a4,scr_addr
 rts



skritt_full: move #0,d0
 move #199,d1
 move #0,d2
 move #19,d3
 bsr scroll
 move.l scr_addr,a4
 move #19,d1
xxytf: move.l (a4)+,(a0)+
 move.l (a4)+,(a0)+
 dbra d1,xxytf
 move.l a4,scr_addr
 rts

do_version:
; move.l back_screen,a0
; bsr cls
; move.l back_screen,a0
; lea 152(a0),a0
; move.l #cowlogo+128,a1
; move #7959,d0
;do_ve: move.l (a1)+,(a0)+
; dbra d0,do_ve
 bsr xfrombak
 move #27,d0
 move #1,d1
 move #6,d2
 bsr sonic
 bsr wait_time
 move.l back_screen,a0
 bsr cls
 bsr xfrombak
ddk: btst.b #7,joydat+1
 bne ddk
 move.l #game_pal,a0
 bsr setpal
 lea version,a0
 move #0,hurry
 move #1,melonman
 bra scroll_out  

wait_time: move #1,syncreq
 move #1,d1
wssy: tst hurry
 bne rrts
 cmp syncreq,d1
 beq wssy
 bra wait_time



key_int: movem.l d0/a0,-(a7)
 lea $fffc00,a0
 move.b (a0),d0
 and #$ff,d0
 btst #7,d0
 beq kreik
rawk: move.b 2(a0),d0
 and #$ff,d0
 cmp #$f6,d0
 blt keemaybee
 cmp #$fe,d0
 bge setjr
 bra kreik
keemaybee: tst joyc
 bne rjoy 
 move.b d0,kee+1	;get code and stash
 btst #7,d0
 bne keyoff
 and #$7f,d0		;strip Key On stuff
 lea keymap,a0		;get ASCII conv table
 move.b 0(a0,d0.w),d0	;get ASCII of key
 lea keystat,a0
 move.b #1,0(a0,d0.w)	;set key on in table


krei2: movem.l (a7)+,d0/a0
 rts

kreik: movem.l (a7)+,d0/a0
 rts

old_kbd: dc.w 0,0,0

keyoff: and #$7f,d0
 lea keymap,a0		;get ASCII conv table
 move.b 0(a0,d0.w),d0	;get ASCII of key
 lea keystat,a0
 move.b #0,0(a0,d0.w)	;set key off in table
 bra krei2

setjr: sub #$fd,d0
 move d0,joyc
 bra kreik

rjoy: movem.l d1/a1,-(a7)
 move joyc,d1
 lea joydat-1,a1
 move.b d0,0(a1,d1.w)	;build joy packet
 movem.l (a7)+,d1/a1
 move #0,joyc
 bra kreik

iskey:
;
;New key read routine. Pass char to check for in d0,
;returns non-0 if char key is down. Is better than old stuff
;because it detects any number of key closures at one time,
;and includes the shift and control keys without having
;to use the BIOS. Uses two tables, KEYMAP which maps scan
;codes onto ASCII, and KEYSTAT which is maintained by the
;IKBD handler at key_int. Each table $80 bytes long.

 and #$7f,d0
 move d0,d1
 lea keystat,a0
 tst.b 0(a0,d0.w)
 beq rezero
 move #1,d0		;return true if key pressed
 rts
rezero: move #0,d0
 rts

sbprint: move.l scrscrn,-(a7)
 move.l a0,-(a7)
 bsr clear_sbuffer
 move.l (a7)+,a0
 move.l #scroll_buffer,scrscrn
 bsr print
 move.l (a7)+,scrscrn
 rts

dra_mode: lea plyr,a0
 btst #0,pmode
 beq drqsf5		;player 1
 lea teem,a0
 btst #1,pmode
 bne drqsf5		;team
 lea pldroid,a0
drqsf5: move #156,d0
 move #35,d1
 move #-1,d2
 bsr syak
 lea plone,a0
 btst #4,pmode
 beq freeqf8
 lea pltwo,a0
freeqf8: move #155,d0
 move #15,d1
 move #-1,d2
 bra syak
 
enter_text: move.l back_screen,a0
 move #0,scrolling
 lea enty,a1
 move #7,d0
hanz: move.b #'-',(a1)+
 dbra d0,hanz
 bsr cls
 move.l back_screen,a1
 move.l ascreen,a2
 bsr dra_mode
 lea coolc2,a0
 move #45,d0
 move #160,d1
 move #-1,d2
 move.l ascreen,a2
 bsr yak
 lea coolc1,a0
 move #277,d0
 move #160,d1
 move #-1,d2
 move.l back_screen,a1
 move.l ascreen,a2
 bsr yak 
 bsr clear_sbuffer
 move #1,line_update
 lea entxt,a0
 move.l back_screen,scrscrn
 bsr print
 move #1,txtcol
 lea enlegal,a1
 move #0,d3
kaah: bsr getloke
 move.b (a1)+,d2
 and #$ff,d2
 bsr dprint
 add #1,d3
 cmp #33,d3
 bne kaah
 bsr xfrombak
 move #0,entdig
 move.l the_business,-(a7)
 move.l routine,-(a7)
 move.l #draw_entry,the_business
 move.l #do_entry,routine
 move #0,cupos
 move #0,freecount
scheepi: bsr opsprite
 cmp #6000,freecount
 blt scheepi 
 move.l (a7)+,routine
 move.l (a7)+,the_business
 rts

line_update: dc.w 0
entdig: dc.w 0

draw_entry: move cupos,d3
 bsr getloke
 add #3,d0
 add #4,d1
 lea sbox,a0
 move #-1,d2
 bsr yak
 move #160*60,d0
 lea 0(a1,d0.w),a0
 move #479,d0
 lea scroll_buffer,a3
xlinny: move.l (a3)+,(a0)+
 dbra d0,xlinny
 tst line_update
 beq rrts
 move #0,line_update
 lea entxt1,a0
 bra sbprint	;print direct t'scroll buffer

do_entry: move.b joydat+1,d1
; btst #4,pmode
; beq do_e
; move.b joydat,d1		;get correct player joy
do_e: move freecount,d0
 and #$07,d0
 bne nocmo
 move d1,d2
 and #3,d2
 beq no_jud
 move #-11,d2
 btst #1,d1
 beq adit
 neg d2
adit: move cupos,d3
 add d2,d3
 bpl adit1
 add #33,d3
noiend: move d3,cupos
 move #7,d0
 move #4,d1
 move #2,d2
 move #0,freecount
 bra sonic
adit1: cmp #32,d3
 ble noiend
 sub #33,d3
 bra noiend
no_jud: move d1,d2
 and #$0c,d2
 beq nocmo
 move #-1,d2
 btst #3,d1
 beq no_j2
 neg d2
no_j2: bra adit  
nocmo: btst #7,d1
 beq quite
 tst bdb
 bne rrts
 move #1,bdb
 move #0,freecount
 move cupos,d0
 lea enlegal,a0
 move entdig,d1
 lea enty,a1
 move.b 0(a0,d0.w),d0	;get char
 cmp.b #'*',d0
 beq ent_okay
 cmp.b #'$',d0
 beq ent_delete
 move.b d0,0(a1,d1.w)
 add #1,d1
 cmp #8,d1
 bne quirt
 move #7,d1
quirt: move d1,entdig
 move #1,line_update
 move #1,d1
 move #24,d0
 move #10,d2
 bra sonic
ent_delete: tst d1
 beq rrts
 cmp #7,d1
 bne recog
 cmp.b #'-',0(a1,d1.w)
 beq recog
 move.b #'-',0(a1,d1.w)
 bra anabi
recog: sub #1,d1
 move.b #'-',0(a1,d1.w)
anabi: move d1,entdig
 move #1,line_update
 move #1,d1
 move #12,d0
 move #10,d2
 bra sonic
ent_okay: move #26,d0
 move #0,d1
 move #10,d2
 move #6000,freecount
 bra sonic

quite: move #0,bdb
 rts
cupos: dc.w 0
bdb: dc.w 0
getloke: move d3,d1
 ext.l d1
 divu #11,d1
 move.l d1,d0
 swap d0		;d0 has column, d1 has row
 move d0,d4
 asl #2,d4
 asl #4,d0
 add d4,d0
 add #55,d0
 asl #5,d1
 add #83,d1
 rts

entxt: dc.b '\g',0,170,'\c1\qcongratewelations!',0
	dc.b '\r\c2\qenter something wonderful:',0
	dc.b '\e'
enlegal: dc.b 'abcdefghijklmnopqrstuvwxyz !.?,$*'
entxt1: dc.b '\c3\g',0,0,'\q'
enty: dc.b '--------',0,'\e'
show_scores: bsr setfwait
 move.l #hssa,slptr
 move.l #hssa,slbase
 move.l #$00240024,slspd
 move #0,sampri
 move.l back_screen,a0
 bsr cls
 move.l back_screen,a1
 lea coolc2,a0
 move #45,d0
 move #160,d1
 move #-1,d2
 move.l ascreen,a2
 bsr yak
 lea coolc1,a0
 move #277,d0
 move #160,d1
 move #-1,d2
 move.l back_screen,a1
 move.l ascreen,a2
 bsr yak 
 move.l back_screen,scrscrn
 move.l #hiscm,a0
 bsr print
 move #30,d1
 lea hiscores,a0
 lea txcols,a1
xsk: bsr print_sline
 add #15,d1
 cmp #180,d1
 blt xsk 
 move.l back_screen,a1
 move #-1,d2
 move #160,d0
 move.l ascreen,a2
 move p1_pos,d1
 bmi scrubba
 move d1,d2
 asl #4,d1
 sub d2,d1
 lea tlla1,a0
 add #35,d1
 move #-1,d2
 bsr syak

scrubba: move p2_pos,d1
 bmi scrubba2
 move d1,d2
 asl #4,d1
 sub d2,d1
 lea caml2,a0
 add #35,d1
 move #-1,d2
 bsr syak
scrubba2: bsr scroll_back
 move #0,hurry
 move #0,freecount
 move.l hssa,a0
 move.l a0,a1
shosc: tst hurry
 bne abeee

fterm: cmp #1000,freecount
 blt shosc
abeee: move.l #rrts,routine
 rts

txcols: dc.w 1,2,3,4,7,6,8,9,11,12

joyfire: dc.w 0
hssa: dc.b 1,27,1,32,1,23,1,26,0

print_sline: move #80,d0
 move (a1)+,txtcol
 move #7,d3
p_sl: move.b (a0)+,d2
 cmp.b #'0',d2
 bne p_sl1
 dbra d3,p_sl
 bra p_sl2
p_sl1: bsr dprint
 move.b (a0)+,d2
 dbra d3,p_sl1
 lea -1(a0),a0
p_sl2: move #180,d0
 move #7,d3
p_sl3: move.b (a0)+,d2
 bsr dprint
 dbra d3,p_sl3
 rts 

p1_pos: dc.w -1
p2_pos: dc.w -1


check_score: lea skores,a0
 btst #4,pmode
 beq chks1
 lea skores+8,a0
chks1: lea hiscores,a1
 move #0,d1	;will be score no.
chks3: move #7,d0
 move.l a1,a2
 move.l a0,a3
chks2: move.b (a3)+,d2
 move.b (a2)+,d3
 sub.b #'0',d3
 cmp.b d2,d3
 blt got_score
 beq nxt_dig
nxt_score: lea 16(a1),a1
 add #1,d1
 cmp #10,d1
 bne chks3
 rts
nxt_dig: dbra d0,chks2
 bra nxt_score
got_score: btst #4,pmode
 bne setp2sc
 move d1,p1_pos
 cmp p2_pos,d1
 bgt drest
 add #1,p2_pos
 cmp #9,p2_pos
 ble drest
 move #-1,p2_pos
 bra drest 
setp2sc: move d1,p2_pos
 cmp p1_pos,d1
 bgt drest
 add #1,p1_pos
 cmp #9,p1_pos
 ble drest
 move #-1,p1_pos
drest: cmp #9,d1
 beq get_score
 move #8,d2
 sub d1,d2
 lea lastsc,a2
doli: move #3,d0
delicasi: move.l -16(a2),(a2)+
 dbra d0,delicasi
 lea -32(a2),a2
 dbra d2,doli
get_score: move #7,d0
gesc: move.b (a0)+,d1
 add.b #'0',d1
 move.b d1,(a1)+
 dbra d0,gesc
 move.l a1,-(a7)
 bsr enter_text
 move.l (a7)+,a1
 lea enty,a0
 move #7,d0
findfuk: cmp.b #'f',(a0)+
 beq maybef
anof: dbra d0,findfuk
 bra nofuck
maybef: cmp.b #'u',(a0)
 bne anof
 cmp.b #'c',1(a0)
 bne anof
 cmp.b #'k',2(a0)
 bne anof
 move #1,rude
nofuck: lea enty,a0
 move #7,d0
getxt: move.b (a0)+,d1
 cmp.b #'-',d1
 bne getx1
 move.b #' ',d1
getx1: move.b d1,(a1)+
 dbra d0,getxt
 rts 

;
; LODE and SAYV do the business on <fname>, at <faddr>,
; length <flength>


lode: move #2,-(a7)
 move #$707,$ff8240
 move.l fname,-(a7)
 move #$3d,-(a7)
 trap #1
 add.l #8,a7
 tst d0
 bpl llegl_handl
 bra no_lode
llegl_handl:
 move #$070,$ff8240
 move d0,fhandl
 move.l faddr,-(a7)
 move.l flength,-(a7)
 move d0,-(a7)
 move #$3f,-(a7)		; read HS table
 trap #1
 add.l #12,a7
 tst d0
 bmi no_lode
 move #$770,$ff8240
 move fhandl,-(a7)
 move #$3e,-(a7)
 trap #1
 add.l #4,a7
 move #0,d0
 rts
no_lode: move #-1,d0
 rts 


sayv: move #2,-(a7)
 move.l fname,-(a7)
 move #$3d,-(a7)
 trap #1
 add.l #8,a7
 tst d0
 bpl legl_handl
 move #0,-(a7)
 move.l fname,-(a7)
 move #$3c,-(a7)
 trap #1
 add.l #8,a7
 tst d0
 bmi no_lode
legl_handl:
 move d0,fhandl
 move.l faddr,-(a7)
 move.l flength,-(a7)
 move d0,-(a7)
 move #$40,-(a7)
 trap #1
 add.l #12,a7
 tst d0
 bmi no_lode
 move fhandl,-(a7)
 move #$3e,-(a7)
 trap #1
 add.l #4,a7
no_sayv: move #0,d0
 rts

fname: dc.l 0
fhandl: dc.w 0
flength: dc.l 0
faddr: dc.l 0   

hsname: dc.b 'scores.yak',0

 include i:\devdev.dev\tentacle.s
 
 include i:\devdev.dev\sasonix2.s



hiscm: dc.b '\g',10,5,'\c1\qbestest beastie blasters',0,'\e'


hiscores: dc.b '00050000inspiral'
	  dc.b '00045000carpets '
	  dc.b '00040000sheepish'
	  dc.b '00035000beasties'
	  dc.b '00030000incakola'
	  dc.b '00025000hal 9000'
	  dc.b '00020000rincwind'
	  dc.b '00015000skifreak'
	  dc.b '00010000unicorn '
lastsc:	  dc.b '00005000bactrian'

copies: dc.b '00050000inspiral'
	  dc.b '00045000carpets '
	  dc.b '00040000sheepish'
	  dc.b '00035000beasties'
	  dc.b '00030000incakola'
	  dc.b '00025000hal 9000'
	  dc.b '00020000rincwind'
	  dc.b '00015000skifreak'
	  dc.b '00010000unicorn '
	  dc.b '00005000bactrian'


cowlogo: incbin i:\yakky2.neo

joyc: dc.w 0
kee: dc.w 0
keymap: dc.b '~~1234567890-=<>qwertyuiop[]RCasdfghjkl;Q`S#'
	dc.b 'zxcvbnm,./T~A L1234567890~~H^~-{~}+~!~><~~~'
	dc.b '~~~~~~~~~\U?()/*7894561230.E~~~~~~~~~~~~~~'

keystat: ds.b 128

txt_x: dc.w 0
txt_y: dc.w 0
retstart: dc.w 0
xmax_real: dc.w 304
txtcol: dc.w 0
numval: dc.w 0
last_c: dc.w 0
scrscrn: dc.l 0
left_suppress: dc.w 0
right_suppress: dc.w 0
ymint: dc.w 0
ymax: dc.w 199
xmin: dc.w 0
xmax: dc.w 19
txtmsks: dc.w 0,0,0,0
 dc.w -1,0,0,0
 dc.w 0,-1,0,0
 dc.w -1,-1,0,0
 dc.w 0,0,-1,0
 dc.w -1,0,-1,0
 dc.w 0,-1,-1,0
 dc.w -1,-1,-1,0
 dc.w 0,0,0,-1
 dc.w -1,0,0,-1
 dc.w 0,-1,0,-1
 dc.w -1,-1,0,-1
 dc.w 0,0,-1,-1
 dc.w -1,0,-1,-1
 dc.w 0,-1,-1,-1
 dc.w -1,-1,-1,-1
scroll_buffer: ds.b 160*20

font: include i:\gamecore\fonte.s

testtxt: dc.b '\g',16,0,'\c1this is a test!!!\r\r'
	dc.b 'marys crying for her baby\rfor her baby doll\r'
	dc.b 'aaaaaaaaaaaahhhhhhhh commercial rain\r\r\r'
	dc.b '\c0inspiral carpets\r'
	dc.b '\c1inspiral carpets\r'
	dc.b '\c2inspiral carpets\r'
	dc.b '\c3inspiral carpets\r'
	dc.b '\c4inspiral carpets\r'
	dc.b '\r\rabcdefghijklmnopqrstuvwxyz\r'
	dc.b '0123456789 ? "llama" (goat) fuck!!'
	dc.b '\r\r\r\r\r\e'

version: dc.b '\c',15,'llamatron version 1.0\r\r\c1'
	dc.b 'this version at 20 march 1991\r\r\c2'
	dc.b '!!!read scroller at title screen for play details '
	dc.b '(wait 1 min for scroller to happen)\c2'
	dc.b '\r\r\c3use joystick to move beastie.  firing is '
	dc.b 'automatic in the direction of travel. you use the '
	dc.b 'fire button to lock the fire angle - so you can move '
	dc.b 'and fire in opposite directions at will.\r\r\c4'
	dc.b 'if you have a suitable arrangement of two joysticks, '
	dc.b 'you can play the game in original robotron style, with '
	dc.b 'the usual stick moving the llama and stick 2 aiming '
	dc.b 'the shots. press fire on stick 2 instead of stick 1 '
	dc.b 'to start a game in that mode.\r\r'
	dc.b 'within game press \c1p\c3 to pause the game. in the '
	dc.b 'pausemode \c1h\c3 toggles 50/60 hz, \c1s\c3 turns '
	dc.b 'samples on/off, \c1t\c3 displays an ozric tentacle '
	dc.b 'you can weird with all of joystick 1, \c1g\c3 redisplays '
	dc.b 'the game screen if you"ve been looking at the tentacle, '
	dc.b 'and \c1o\c3 unpauses the game!\r\r' 
	dc.b 'mission: rescue beasties and \c1kill\c3 everything else '
	dc.b '(where possible).\r\r\r'
	dc.b '\c2get beasties for bonus and \c1hot bullets\c2 - '
	dc.b 'they last for a couple of seconds and slice through all '
	dc.b 'enemies like a cat through butter.\r\r\r'
	dc.b 'collect \c1last \c2beastie for special bonus'
	dc.b '\r\r\r'
	dc.b 'collect \c1hearts\c2 to make all the little beasties '
	dc.b 'fall in love with you - they run towards you!\r\r'
	dc.b 'game makes 160-byte file for hiscores on yer current '
	dc.b 'dir.'
	dc.b '\r\c',15,'good luck!!!'
	dc.b '\r\r\r\r\r\r\r\r\r\r\r\r\e'

credits: dc.b '\c1\qllamatron:  2112',0,'\r\r\r'
	dc.b 'perpetrated by: \c3yak\c1\r'
	dc.b 'coded on: \c3devpac developer\c1\r'
	dc.b 'samples grabbed with: \c3replay-8\c1\r\r'
	dc.b 'guest appearences by: \c3m c urtis, '
	dc.b 'sween "e" todd and andy "rubber chicken" capon '
	dc.b 'on \c1"oh f. . !"\c3 sample\r\r'
	dc.b '\c1programmer entertained by: \c3inspiral carpets, '
	dc.b 'floyd, charlatans, faith no more, house of '
	dc.b 'love, inspiral carpets, lemmings, thunderstrike '
	dc.b '(pc vga version), buckley"s best bitter, pensarnau '
	dc.b 'pizza power, blizzard skis and salomon boots, ozric '
	dc.b 'tentacles, the grateful dead, the handy hendy bendy '
	dc.b 'mandy generator, devil crash on the pc engine, and '
	dc.b 'loads more funky stuff!\r\r\c1\qyak 1991',0,'\r\r\r\r\r\r\r\r\r\r\e'


story: dc.b '\c3in the space year'
 	dc.b ' \c12112 \c3 the \c2zzyaxians\c3 have '
	dc.b 'invaded our planet.  with an overwhelming '
	dc.b 'force of cybernetic and genetically-enhanced '
	dc.b '"\c1grunt\c3" soldiers, the fiends set about '
	dc.b 'systematically destroying every last sheep, goat, '
	dc.b 'camel and llama on the face of the planet.\r\r'
	dc.b '\c',12,'against this awesome force, we have a '
	dc.b 'devastating (and extremely furry) secret weapon. . .\r\r'
	dc.b '\c1\ql l a m a t r o n',0,'\r\r'
	dc.b '\g',104,6,'\s',0,13
	dc.b '\s',0,14,'\s',0,15,'\s',0,16,'\s',0,17,'\s',0,18
	dc.b '\s',0,19,'\s',0,20,'\r\r'
	dc.b '\g',16,6,'\c1llamatron\c8- bionic, telepathic, psychedelic '
	dc.b 'and completely ozric, the laser-spitting llamatron '
	dc.b 'is the best hope to defeat the zzyaxian hordes and '
	dc.b 'keep our beasties safe!\r\r\r'
	dc.b '\c1\qthe mission:',0,'\r\r\c',11,'-- rescue beasties '
	dc.b '(\s',0,35,'\s',0,72,'\s',0,85,'\s',0,88,')\r'

;	dc.b '(\s',0,12,'\s',0,13,'\s',0,14,'\s',0,15,')\r'

	dc.b '-- kill grunts (\s',0,239,'\s',0,34,'etc.)\r\r\r'
	dc.b '\c1\qyour enemies:',0,'\r\r'
	dc.b 'spikers:\c4 (\s',0,111,') fragment when shot\r\c1'
	dc.b 'fire hydrant generators:\c4 (\s',0,60,') do just that\r\c1'
	dc.b 'fire hydrant:\c4 (\s',0,64,') chase and fire at you\r\c1'
	dc.b 'bibblers:\c4 (\s',0,123,') split into wibblers (\s',0,127
	dc.b ') and fooberols (\s',0,131,')\r\c1'
	dc.b 'killers:\c4 (\s',0,43,' ) chase \s',0,36,'\s',0,79
	dc.b '\s',0,77,'\s',0,88,', and \c2kill \c4 them on contact!\s',0,51,'\r\c1'
	dc.b 'lazers:\c4 (\s',0,135,') generate plazma beam and '
	dc.b 'cannot be killed!\r'
	dc.b '\c1brains:\c4 (\s',0,168,' ) grab \s',0,35,'\s',0,80
	dc.b '\s',0,78,'\s',0,87,', and \c1mutate\c4 them into '
	dc.b 'mindless \c2zombeasts \s',0,153,' !\r'
	dc.b '\c1generator blocks:\c4 (\s',0,222,' ) armoured '
	dc.b 'and generate \s',0,239,'\s',0,34,'!\r'
	dc.b '\c1false teeth:\c4 (\s',0,224,') fly around firing '
	dc.b 'weird \s',0,229,' at you!\r'
	dc.b '\c1pointy thing:\c4 (\s',0,231,' ) take three shots '
	dc.b 'to kill, and tries to point out \s',0,15,'!!\r'
	dc.b '\c1alien in sheep"s clothing: \s',0,79,'\c4 '
	dc.b 'beware these in your herd \s',0,80,'\s',0,82,'\s',0,85
	dc.b ' because they splat"em!\r'
	dc.b '\r\c4\qbeware the sheepipede!!',0
	dc.b '\r\r\c1\qwatch out for the screaming mandy',0
	dc.b '\r\qcoz i"m sure it"s gonna get you',0
	dc.b '\r\qyeah!!',0
	dc.b '\r\r\r\r\c1-- many many more \s',0,13,'- threatening nasties '
	dc.b 'lurk in the higher levels. . .\r\r\r'
	dc.b '\c4'
	dc.b 'grab \s',0,35,'\s',0,80
	dc.b '\s',0,78,'\s',0,87,', and get \c1 hot bullets \c4'
	dc.b '\s',0,187,' and if you get the \c1 last beastie \c4'
	dc.b 'get a special bonus!\r\r'
	dc.b 'collect \s',0,196,' to make the \s',0,35,'\s',0,80
	dc.b '\s',0,78,'\s',0,87,' love you! they run towards '
	dc.b 'you while besotted!\r\r\r'
	dc.b '\c6collect the following for powerup. .\r\r'
	dc.b '\s',0,242,'\g',40,6,'. . . \c1extra \s',0,13,'\r'
	dc.b '\s',0,240,'\g',40,6,'. . . warp\c6 5 levels and \c150,000 '
	dc.b '\c6bbonus\r'
	dc.b '\s',0,244,'\g',40,6,'. . . \c1hot bullets\c6 till end of wave\r'
	dc.b '\s',0,246,'\g',40,6,'. . . 3-way firing and \c1double score!\r'
	dc.b '\s',0,248,'\g',40,6,'. . . \c1smart bomb\c6 damages '
	dc.b 'all enemies onscreen\r'
	dc.b '\s',0,250,'\g',40,6,'. . . gives period of \c1invincibility\c6'
	dc.b '\r'
	dc.b '\s',1,0,'\g',40,6,'. . . gives you \c1reflective shots\c6\r'
	dc.b '\s',1,2,'\g',40,6,'. . . pick this up for a \c1floyd bonus\c1\r'
	
	dc.b '\r\r\c6why not play team mode with a likeminded entity? '
	dc.b ' \s',0,13,' and \s',0,95,' make a killer team!\r\r\r'
	dc.b '\c2all alone?  \c1aaahh! \c2never mind - the \c4 droid '
	dc.b '\c2is always waiting and willing to be your partner!\r\r\r'
	dc.b '\c3alright then! get out there and grab those \s',0,36,'\s',0,79
	dc.b '\s',0,77,'\s',0,88,'!\r\r\c1\qgood luck',0
	dc.b '\r\r\qdeath to the zzyaxians!!',0,'\r\r'
	dc.b '\g',156,10,'\s',0,88,'\r'
	dc.b '\e'



exes: ds.l 200



sine: incbin i:\gamecore\sine.img

skores: dc.l 0,0,0,0

llavex: dc.w -1,-1,0,1,1,1,0,-1
	dc.w 0,-1,-1,-1,0,1,1,1
	dc.w 6,6,2,0,0,0,4,6


avex: dc.l dorez,dolec,doex,dogrunt,dorez,dolla,folla,dorez,dokill
	dc.l doskull,dorez,dofhg,dofhy,dofhyp,dobug,movedge,doglob
	dc.l dolazr,doylazr,doyiy,doblokr,domut,dobrane,dospark
	dc.l dobog,doroll,doshit,domine,dopower,bsmove,fomove
	dc.l doteap,dogblok,doftee,doaro,domandy,dotrn,dosaf
	dc.l do16ton,dobrolly,doro,mbait,mgun,dotent,xxxgen,xxxrun

dvex: dc.l drawrez,drawmove,drawlazr,drylazr,unfad0,drawdrez,drawdrez,drawdrez
	dc.l unfad1,unfad2,unfad2,drawmove,drawrez,stdraw,sparkdraw
	dc.l drawrez,lladraw,ozdraw,rrts

scors: dc.w 0,0,0,6,0,0,3,6,0,0,0,0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,4,0,5,0,6,0,4,0,0,3,7
	dc.w 0,0,0,0,4,5,1,5,4,5,0,4,0,6
	dc.w 0,4,0,0,5,4,0,0,0,0,1,6,0,0
	dc.w 0,5,0,4,0,4,3,6,4,4,1,5,3,5
	dc.w 0,0,0,0,3,5,4,5,4,4,0,3
friz: dc.w 7



mouse_pars: dc.l $01000101

shipa: dc.l shipdat
shipb: dc.l shipdat+8192
seed: dc.w $3141
key_vec equ $118

game_pal: dc.w $0000,$0717,$0700,$0750,$0770,$0D34,$00C0,$007C
 dc.w $0077,$00C7,$0223,$0007,$0507,$0775,$0777,$0555

n_table: dc.w 43,16,60,8,111,11,123,11,127,7,131,3,135,0,136,0
	dc.w 137,11,149,3,153,9,163,7,171,7,181,5,198,3
	dc.w 206,3,210,3,214,3,218,3,222,1,224,5,231,3
	dc.w 235,3,252,3,260,7,268,2,271,0,272,2,275,2
	dc.w 280,3,284,5,290,3,294,4,294,4,294,4,294,4
	dc.w 299,7,310,7,318,7

objex:  dc.l ls1,ls2,ls3,ls4,ls5,ls6,ls7,ls8		;7
	dc.l lg1,lg2,lg3,lg4,lg5,lla4,lla3,lla2		;15
	dc.l lla1,lla5,lla6,lla7,lla8,lla9,lla10,lla11	;23
	dc.l lla12,lla13,lla14,lla15,lla16,bul1,bul2,bul3	;31
	dc.l bul4,lec1,coke1,tlla1,tlla2,tlla3,tlla4,tlla5	;39
	dc.l tlla6,tlla7,tlla8,kil1,kil2,kil3,kil4,kil5		;47
	dc.l kil6,kil7,kil8,skull,kil9,kil10,kil11,kil12,kil13	;56
	dc.l kil14,kil15,kil16,fhg1,fhg2,fhg3,fhg4	;63
	dc.l fhy,fhyp1,fhyp2,fhyp3,fhyp4,fhb,thoub	;70
	dc.l goat1,goat2,goat3,goat4,goat5,goat6,goat7,goat8	;78
	dc.l ram1,ram2,ram3,ram4,ram5,ram6,ram7,ram8	;86
	dc.l caml1,caml2,caml3,caml4,caml5,caml6,caml7,caml8	;94
	dc.l p2cam1,p2cam2,p2cam3,p2cam4,p2cam5,p2cam6,p2cam7,p2cam8	;102
	dc.l p2cam9,p2cam10,p2cam11,p2cam12,p2cam13,p2cam14,p2cam15,p2cam16	;110
	dc.l bug1,bug2,bug3,bug4,bug5,bug6,bug7,bug8	;118
	dc.l spik1,spik2,spik3,spik4		;122
	dc.l glob1,glob2,glob3,glob4,glob5,glob6,glob7,glob8	;130
	dc.l glob9,glob10,glob11,glob12,lazr,ylazr	;136
	dc.l yy1,yy2,yy3,yy4,yy5,yy6,yy7,yy8,yyp1,yyp2,yyp3,yyp4	;148
	dc.l blokr1,blokr2,blokr3,blokr4	;152
	dc.l mutnt1,mutnt2,mutnt3,mutnt4,mutnt5,mutnt6,mutnt7,mutnt8	;160
	dc.l splat1,splat2,brane1,brane2,brane3,brane4,brane5	;167
	dc.l brane6,brane7,brane8,spark1,spark2,spark3,spark4	;174
	dc.l dot1,dot2,dot3,dot4,bog1,bog2,roll1,roll2,turd1,turd2	;184
	dc.l turd3,turd4,bul21,bul22,bul23,bul24,mine	;191
	dc.l bbul1,bbul2,bbul3,bbul4,luv1,luv2	;197
	dc.l bsh1,bsh2,bsh3,bsh4,bsh5,bsh6,bsh7,bsh8	;205
	dc.l teap1,teap2,teap3,teap4,eyb2,eyb1,eyb3,eyb3	;213
	dc.l lik2,lik1,lik3,lik3,ski2,ski1,ski3,ski3	;221
	dc.l gblok1,gblok2,fteeth1,fteeth2,fteeth3,fteeth2	;227
	dc.l fteeth4,gproj1,gproj2,aro1,aro2,aro3,aro4		;234
	dc.l lsplat1,lsplat2,lsplat3,lsplat4,robo1	;239
	dc.l wpod1,wpod2,lpod1,lpod2,hbike,hbike	;245
	dc.l f3way1,f3way2,smbom1,smbom2,invis1,invis2	;251
	dc.l mandy1,mandy2,mbuu1,mbuu2,bsi1,bsi2	;257
	dc.l bnus1,bnus2,trn1,trn2,trn3,trn4,trn5,trn6,trn7,trn8	;267
	dc.l saf1,saf2,saf3,w16ton,brolly1,brolly2,drop	;274
	dc.l camsaf1,camsaf2,camsaf3,camspit1,camspit2	;279
	dc.l ro1,ro2,ro3,ro4,bait1,bait2,bait3,bait4	;287
	dc.l scros1,scros2,sfhg1,sfhg2,sfhg3,sfhg2	;293
	dc.l sgun1,sgun2,sgun3,sgun4,gproj		;298
	dc.l nki1,nki2,nki3,nki4,nki5,nki6,nki7,nki8	;306
	dc.l nel1,nel2,nel3,strn1,strn2,strn3,strn4	;313
	dc.l strn5,strn6,strn7,strn8,tseg1,tseg2,tseg3,tseg4	;321
	dc.l tseg5,tseg6,tseg7,tseg8,thead,xxx1,xxx2,xxx3	;329
would_be_nice: dc.l lla4,lla3,lla2
	dc.l lla1,lla5,lla6,lla7,lla8,lla9,lla10,lla11
	dc.l lla12,lla13,lla14,lla15,lla16
	dc.l p2cam1,p2cam2,p2cam3,p2cam4,p2cam5,p2cam6,p2cam7,p2cam8
	dc.l p2cam9,p2cam10,p2cam11,p2cam12,p2cam13,p2cam14,p2cam15,p2cam16
	dc.l droi1,droi2,droi3,mine,bul21,bul22,bul23,bul24
	dc.l bbul1,bbul2,bbul3,bbul4,-1


beastie1: dc.l tlla1,tlla2,tlla3,tlla4,tlla5,tlla6,tlla7,tlla8
beastie2: dc.l goat1,goat2,goat3,goat4,goat5,goat6,goat7,goat8
beastie3: dc.l ram1,ram2,ram3,ram4,ram5,ram6,ram7,ram8
beastie4: dc.l caml1,caml2,caml3,caml4,caml5,caml6,caml7,caml8
beastys: dc.l beastie1,beastie2,beastie3,beastie4

grunties: dc.l robo1,robo2,coke1,coke2,zip1,zip2,yac1,yac2,jst1,jst2,inv1,inv2
	dc.l brg1,brg2,pln1,pln2,shp1,shp2,cher1,cher2,phon1,phon2
	dc.l tpyr1,tpyr2,smly1,smly2,tv1,tv2,kios1,kios2,fpac1,fpac2
	dc.l card1,card2,rizl1,rizl2,bulb1,bulb2,tea1,tea2
	dc.l kaf1,kaf2,rng1,rng2,msh1,msh2,chp1,chp2,tom1,tom2
	dc.l ban1,ban2,roll1,roll2
titex: 	dc.l goat1,goat2,goat3,goat4,goat5,goat6,goat7,goat8
	dc.l ram1,ram2,ram3,ram4,ram5,ram6,ram7,ram8
	dc.l caml1,caml2,caml3,caml4,caml5,caml6,caml7,caml8
	dc.l tlla1,tlla2,tlla3,tlla4,tlla5
	dc.l tlla6,tlla7,tlla8,-1
permex:	dc.l bul1,bul2,bul3
	dc.l bul4
	dc.l -1
old_smcptr: dc.l 0

titty: dc.w -1,-1,-1,-1,-1,-1,-1,-1,-1,-1 
	dc.b 0,0,1,2,1,3,4,5,6,7

skull: dc.w 3,0,15,15,0,0
	dc.w	$0FC0,$0000,$0000,$0000,$3FF0,$0000,$0000,$0000
	dc.w	$7FF8,$0000,$0000,$0000,$77B8,$0000,$0000,$0000
	dc.w	$E31C,$0000,$0000,$0000,$E31C,$0000,$0000,$0000
	dc.w	$6798,$0000,$0000,$0000,$7CF8,$0000,$0000,$0000
	dc.w	$7878,$0000,$0000,$0000,$1B60,$0000,$0000,$0000
	dc.w	$5FE8,$0000,$0000,$0000,$4FE8,$0000,$0000,$0000
	dc.w	$6A88,$0000,$0000,$0000,$6038,$0000,$0000,$0000
	dc.w	$3D70,$0000,$0000,$0000,$1FE0,$0000,$0000,$0000



ls2: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$3FFE,$0000,$0000,$1FFC,$2002,$0000
	dc.w	$0000,$1FFC,$2002,$0000,$0000,$1C1C,$23E2,$0000
	dc.w	$0000,$1C1C,$2222,$0000,$0000,$1C1C,$23E2,$0000
	dc.w	$0000,$1FFC,$2002,$0000,$0000,$1FFC,$2002,$0000
	dc.w	$0000,$3C1C,$43E2,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$8222,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$8222,$0000,$0000,$001C,$FE22,$0000
	dc.w	$0000,$001C,$0022,$0000,$0000,$0000,$003E,$0000

ls1: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$3E00,$0000,$0000,$1C00,$2200,$0000
	dc.w	$0000,$1C00,$2200,$0000,$0000,$1C00,$2200,$0000
	dc.w	$0000,$1C00,$2200,$0000,$0000,$1C00,$2200,$0000
	dc.w	$0000,$1C00,$2200,$0000,$0000,$1C00,$2200,$0000
	dc.w	$0000,$3C00,$4200,$0000,$0000,$7C00,$823C,$0000
	dc.w	$0000,$7C18,$83E4,$0000,$0000,$7FF8,$8004,$0000
	dc.w	$0000,$7FF8,$8004,$0000,$0000,$0000,$FFFC,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
ls3: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$3FFF,$0000,$0000,$1FFE,$2001,$0000
	dc.w	$0000,$1FFE,$2001,$0000,$0000,$1CCE,$2331,$0000
	dc.w	$0000,$1CCE,$2331,$0000,$0000,$1CCE,$2331,$0000
	dc.w	$0000,$1CCE,$2331,$0000,$0000,$1CCE,$2331,$0000
	dc.w	$0000,$3C0E,$43F1,$0000,$0000,$7C0E,$8211,$0000
	dc.w	$0000,$7C0E,$8211,$0000,$0000,$7C0E,$8211,$0000
	dc.w	$0000,$7C0E,$8271,$0000,$0000,$003E,$FE41,$0000
	dc.w	$0000,$003E,$0041,$0000,$0000,$0000,$007F,$0000
ls4: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$FFFF,$0000,$0000,$7FFE,$8001,$0000
	dc.w	$0000,$7FFE,$8001,$0000,$0000,$01C0,$FE3F,$0000
	dc.w	$0000,$01C0,$0220,$0000,$0000,$01C0,$0220,$0000
	dc.w	$0000,$01C0,$0220,$0000,$0000,$01C0,$0220,$0000
	dc.w	$0000,$03C0,$0420,$0000,$0000,$07C0,$0820,$0000
	dc.w	$0000,$07C0,$0820,$0000,$0000,$07C0,$0820,$0000
	dc.w	$0000,$07C0,$0820,$0000,$0000,$0000,$0FE0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
ls5: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$3FF8,$0000,$0000,$1FF8,$2004,$0000
	dc.w	$0000,$1FFC,$2002,$0000,$0000,$1C1C,$23E2,$0000
	dc.w	$0000,$1C1C,$2222,$0000,$0000,$1C18,$23E4,$0000
	dc.w	$0000,$1FF0,$2008,$0000,$0000,$1FF8,$2004,$0000
	dc.w	$0000,$3C1C,$43E2,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$8222,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$8222,$0000,$0000,$001C,$FE22,$0000
	dc.w	$0000,$001C,$0022,$0000,$0000,$0000,$003E,$0000
ls6: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$3FFE,$0000,$0000,$1FFC,$2002,$0000
	dc.w	$0000,$1FFC,$2002,$0000,$0000,$1C1C,$23E2,$0000
	dc.w	$0000,$1C1C,$2222,$0000,$0000,$1C1C,$2222,$0000
	dc.w	$0000,$1C1C,$2222,$0000,$0000,$1C1C,$2222,$0000
	dc.w	$0000,$3C1C,$4222,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$83E2,$0000,$0000,$7FFC,$8002,$0000
	dc.w	$0000,$7FFC,$8002,$0000,$0000,$0000,$FFFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
ls7: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$3FFE,$0000,$0000,$1FFC,$2002,$0000
	dc.w	$0000,$1FFC,$2002,$0000,$0000,$1C1C,$23E2,$0000
	dc.w	$0000,$1C1C,$2222,$0000,$0000,$1C1C,$2222,$0000
	dc.w	$0000,$1C1C,$2222,$0000,$0000,$1C1C,$2222,$0000
	dc.w	$0000,$3C1C,$4222,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$8222,$0000,$0000,$7C1C,$8222,$0000
	dc.w	$0000,$7C1C,$8222,$0000,$0000,$001C,$FE22,$0000
	dc.w	$0000,$001C,$0022,$0000,$0000,$0000,$003E,$0000
ls8: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0380,$0000
	dc.w	$0000,$0380,$0440,$0000,$0000,$07C0,$0820,$0000
	dc.w	$0000,$07C0,$0820,$0000,$0000,$0380,$0440,$0000
	dc.w	$0000,$0000,$0380,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0380,$0000,$0000,$0380,$0440,$0000
	dc.w	$0000,$07C0,$0820,$0000,$0000,$07C0,$0820,$0000
	dc.w	$0000,$0380,$0440,$0000,$0000,$0000,$0380,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

lg1: dc.w 3,0,21,15,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0001,$0001,$0000,$0002,$0002,$0002
	dc.w	$0000,$0004,$0004,$0004,$0001,$0008,$0008,$0008
	dc.w	$0003,$0010,$0010,$0010,$0000,$0020,$0020,$0020
	dc.w	$0000,$0040,$0040,$0040,$0000,$0080,$0080,$0080
	dc.w	$003F,$0100,$0100,$0100,$0070,$0200,$0200,$0200
	dc.w	$00F0,$0400,$0400,$0400,$01F0,$0800,$0800,$0800
	dc.w	$03FF,$1000,$1000,$1000,$0000,$2000,$2000,$2000
	dc.w	$0000,$4000,$4000,$4000,$7FFF,$FFFF,$FFFF,$FFFF
lg2: dc.w 3,0,21,15,0,0
	dc.w	$0000,$001F,$001F,$001F,$0000,$0020,$0020,$0020
	dc.w	$0000,$0040,$0040,$0040,$0000,$0080,$0080,$0080
	dc.w	$0006,$0100,$0100,$0100,$000E,$FE00,$FE00,$FE00
	dc.w	$001E,$0000,$0000,$0000,$003E,$0000,$0000,$0000
	dc.w	$FE0E,$0000,$0000,$0000,$FE0E,$0000,$0000,$0000
	dc.w	$FE0E,$0000,$0000,$0000,$060E,$0000,$0000,$0000
	dc.w	$060E,$0000,$0000,$0000,$060E,$0000,$0000,$0000
	dc.w	$FE0E,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$038E,$0000,$0000,$0000
	dc.w	$FFBF,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF
lg3: dc.w 3,0,21,15,0,0
	dc.w	$0000,$FE00,$FE00,$FE00,$0100,$0100,$0100,$0100
	dc.w	$0080,$0080,$0080,$0080,$0040,$0040,$0040,$0040
	dc.w	$0620,$0020,$0020,$0020,$0E00,$001F,$001F,$001F
	dc.w	$1E00,$0000,$0000,$0000,$3E00,$0000,$0000,$0000
	dc.w	$0E3F,$0000,$0000,$0000,$0E3F,$0000,$0000,$0000
	dc.w	$0E3F,$0000,$0000,$0000,$0E00,$0000,$0000,$0000
	dc.w	$0E00,$0000,$0000,$0000,$0E00,$0000,$0000,$0000
	dc.w	$0E3F,$0000,$0000,$0000,$0E30,$0000,$0000,$0000
	dc.w	$0E30,$0000,$0000,$0000,$0E30,$0000,$0000,$0000
	dc.w	$BFBF,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF
lg4: dc.w 3,0,21,15,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$C000,$C000,$C000
	dc.w	$2000,$2000,$2000,$2000,$1000,$1000,$1000,$1000
	dc.w	$8800,$0800,$0800,$0800,$C400,$0400,$0400,$0400
	dc.w	$E200,$0200,$0200,$0200,$3100,$0100,$0100,$0100
	dc.w	$3880,$0080,$0080,$0080,$3C40,$0040,$0040,$0040
	dc.w	$FE20,$0020,$0020,$0020,$0010,$0010,$0010,$0010
	dc.w	$0008,$0008,$0008,$0008,$01C4,$0004,$0004,$0004
	dc.w	$FFE2,$0002,$0002,$0002,$0001,$0001,$0001,$0001
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF
lg5: dc.w 3,0,21,15,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$8000,$8000,$8000,$8000,$C000,$C000,$C000,$C000
yakk: dc.w 3,1,14,19,0,0
	dc.w	$4200,$4200,$4200,$4200,$0000,$0000,$0000,$0000
	dc.w	$8100,$8100,$8100,$8100,$0000,$0000,$0000,$0000
	dc.w	$C300,$8100,$C300,$C300,$0000,$0000,$0000,$0000
	dc.w	$7E00,$7E00,$6600,$6600,$0000,$0000,$0000,$0000
	dc.w	$1860,$1860,$0000,$2400,$0000,$0000,$0000,$0000
	dc.w	$19FC,$19FC,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$1BFF,$1BFF,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$03FF,$03FF,$0000,$0000,$E000,$E000,$0000,$0000
	dc.w	$0FFF,$0FFF,$0000,$0000,$D000,$D000,$0000,$0000
	dc.w	$07FF,$06D1,$012E,$0000,$D000,$D000,$0000,$0000
	dc.w	$17D7,$1695,$0142,$0000,$8000,$8000,$0000,$0000
	dc.w	$1645,$1601,$0044,$0000,$A000,$A000,$0000,$0000
	dc.w	$1401,$1401,$0000,$0000,$A000,$A000,$0000,$0000
	dc.w	$1401,$1401,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$3C03,$3C03,$0000,$0000,$6000,$6000,$0000,$0000

yakm: dc.w 3,6,4,98,0,0
	dc.w	$0000,$0000,$E0E7,$E0E7,$0000,$0000,$4546,$4546
	dc.w	$0000,$0000,$773B,$773B,$0000,$0000,$BB83,$BB83
	dc.w	$0000,$0000,$BBB2,$BBB2,$0000,$0000,$BBAE,$BBAE
	dc.w	$0000,$0000,$C000,$C000,$0000,$0000,$A0A4,$A0A4
	dc.w	$0000,$0000,$4545,$4545,$0000,$0000,$4522,$4522
	dc.w	$0000,$0000,$2102,$2102,$0000,$0000,$AAAA,$AAAA
	dc.w	$0000,$0000,$A12A,$A12A,$0000,$0000,$A000,$A000
	dc.w	$0000,$0000,$E0F6,$E0F6,$0000,$0000,$5545,$5545
	dc.w	$0000,$0000,$67B3,$67B3,$0000,$0000,$3903,$3903
	dc.w	$0000,$0000,$BAAA,$BAAA,$0000,$0000,$A12A,$A12A
	dc.w	$0000,$0000,$A000,$A000,$0000,$0000,$A094,$A094
	dc.w	$0000,$0000,$5545,$5545,$0000,$0000,$44A2,$44A2
	dc.w	$0000,$0000,$0902,$0902,$0000,$0000,$32AA,$32AA
	dc.w	$0000,$0000,$A12A,$A12A,$0000,$0000,$A000,$A000
	dc.w	$0000,$0000,$A0F7,$A0F7,$0000,$0000,$7D76,$7D76
	dc.w	$0000,$0000,$77BB,$77BB,$0000,$0000,$B902,$B902
	dc.w	$0000,$0000,$2BB3,$2BB3,$0000,$0000,$B92E,$B92E
	dc.w	$0000,$0000,$A000,$A000

qu1: dc.w 3,0,5,10,0,0
	dc.w	$0000,$8020,$8020,$8020,$0000,$8020,$8020,$8020
	dc.w	$0000,$8020,$8020,$8020,$0000,$8020,$8020,$8020
	dc.w	$0000,$0000,$0000,$0000,$0000,$8020,$8020,$8020
qu2: dc.w 3,0,5,10,0,0
	dc.w	$0200,$0E00,$0E00,$0E00,$0000,$0200,$0200,$0200
	dc.w	$0200,$0600,$0600,$0600,$0000,$0400,$0400,$0400
	dc.w	$0000,$0000,$0000,$0000,$0000,$0400,$0400,$0400

lla1: dc.w 3,0,17,14,0,0
	dc.w	$0008,$0000,$0008,$0000,$0010,$0000,$0010,$0000
	dc.w	$0018,$0008,$0010,$0000,$003C,$001C,$0020,$0000
	dc.w	$0030,$0010,$0020,$0000,$0030,$0000,$0030,$0000
	dc.w	$C030,$C000,$0030,$0000,$2038,$2020,$0018,$0000
	dc.w	$3FF8,$00E0,$3F18,$0F00,$1FF8,$0000,$1FF8,$1E00
	dc.w	$1FF8,$0000,$1FF8,$0C00,$1FF0,$0C00,$13F0,$0000
	dc.w	$3828,$1800,$2028,$0000,$3428,$0000,$3428,$0000
	dc.w	$282C,$0000,$282C,$0000,$2824,$0000,$2824,$0000
	dc.w	$3026,$0000,$3026,$0000,$0C30,$0000,$0C30,$0000
lla2: dc.w 3,0,17,14,0,0
	dc.w	$0008,$0000,$0008,$0000,$0010,$0000,$0010,$0000
	dc.w	$0018,$0018,$0000,$0000,$003C,$001C,$0020,$0000
	dc.w	$0030,$0010,$0020,$0000,$8030,$8000,$0030,$0000
	dc.w	$4030,$4020,$0010,$0000,$4070,$4060,$0010,$0000
	dc.w	$7FF0,$01C0,$7E30,$1E00,$3FF0,$0000,$3FF0,$3C00
	dc.w	$3FF0,$0000,$3FF0,$1800,$7FE0,$1800,$67E0,$0000
	dc.w	$7068,$3000,$4068,$0000,$C828,$0000,$C828,$0000
	dc.w	$9030,$0000,$9030,$0000,$90B0,$0000,$90B0,$0000
	dc.w	$9090,$0000,$9090,$0000,$D818,$0000,$D818,$0000
lla3: dc.w 3,0,17,14,0,0
	dc.w	$0000,$0000,$0000,$0000,$0002,$0000,$0002,$0000
	dc.w	$0004,$0000,$0004,$0000,$0006,$0006,$0000,$0000
	dc.w	$000F,$0007,$0008,$0000,$000C,$0004,$0008,$0000
	dc.w	$401C,$4010,$000C,$0000,$A03C,$A030,$000C,$0000
	dc.w	$3FFC,$0060,$3F9C,$1F80,$1FF8,$0000,$1FF8,$1F00
	dc.w	$1FF8,$0000,$1FF8,$0E00,$1FF0,$0600,$19F0,$0000
	dc.w	$3C30,$0C00,$3030,$0000,$3018,$0000,$3018,$0000
	dc.w	$2408,$0000,$2408,$0000,$260C,$0000,$260C,$0000
	dc.w	$2026,$0000,$2026,$0000,$3030,$0000,$3030,$0000
lla4: dc.w 3,0,17,14,0,0
	dc.w	$0004,$0000,$0004,$0000,$0008,$0000,$0008,$0000
	dc.w	$000C,$000C,$0000,$0000,$001E,$000E,$0010,$0000
	dc.w	$0018,$0008,$0010,$0000,$0018,$0000,$0018,$0000
	dc.w	$0018,$0010,$0008,$0000,$E038,$E030,$0008,$0000
	dc.w	$BFF8,$A0E0,$1F18,$0F00,$1FF8,$0000,$1FF8,$1F00
	dc.w	$1FF8,$0000,$1FF8,$0C00,$1FF0,$0E00,$11F0,$0000
	dc.w	$3C38,$1C00,$2038,$0000,$3028,$0000,$3028,$0000
	dc.w	$2828,$0000,$2828,$0000,$2828,$0000,$2828,$0000
	dc.w	$2C2C,$0000,$2C2C,$0000,$3030,$0000,$3030,$0000
lla5: dc.w 3,0,17,14,0,0
	dc.w	$4000,$0000,$4000,$0000,$2000,$0000,$2000,$0000
	dc.w	$6000,$6000,$0000,$0000,$F000,$E000,$1000,$0000
	dc.w	$3000,$2000,$1000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$1000,$2000,$0000,$380E,$180E,$2000,$0000
	dc.w	$3FFA,$0E0A,$31F0,$01E0,$3FF0,$0000,$3FF0,$01F0
	dc.w	$3FF0,$0000,$3FF0,$0060,$1FF0,$00E0,$1F10,$0000
	dc.w	$3878,$0070,$3808,$0000,$2818,$0000,$2818,$0000
	dc.w	$2828,$0000,$2828,$0000,$2828,$0000,$2828,$0000
	dc.w	$6868,$0000,$6868,$0000,$1818,$0000,$1818,$0000
lla6: dc.w 3,0,17,14,0,0
	dc.w	$0000,$0000,$0000,$0000,$4000,$0000,$4000,$0000
	dc.w	$2000,$0000,$2000,$0000,$6000,$6000,$0000,$0000
	dc.w	$F000,$E000,$1000,$0000,$3000,$2000,$1000,$0000
	dc.w	$3802,$0802,$3000,$0000,$3C05,$0C05,$3000,$0000
	dc.w	$3FFC,$0600,$39FC,$01F8,$1FF8,$0000,$1FF8,$00F8
	dc.w	$1FF8,$0000,$1FF8,$0070,$0FF8,$0060,$0F98,$0000
	dc.w	$0C3C,$0030,$0C0C,$0000,$180C,$0000,$180C,$0000
	dc.w	$1024,$0000,$1024,$0000,$3064,$0000,$3064,$0000
	dc.w	$6404,$0000,$6404,$0000,$0C0C,$0000,$0C0C,$0000
lla7: dc.w 3,0,17,14,0,0
	dc.w	$4000,$0000,$4000,$0000,$2000,$0000,$2000,$0000
	dc.w	$6000,$6000,$0000,$0000,$F000,$E000,$1000,$0000
	dc.w	$3000,$2000,$1000,$0000,$3004,$0004,$3000,$0000
	dc.w	$3008,$1008,$2000,$0000,$3808,$1808,$2000,$0000
	dc.w	$3FF8,$0E00,$31F8,$01E0,$3FF0,$0000,$3FF0,$00F0
	dc.w	$3FF0,$0000,$3FF0,$0060,$1FF8,$0060,$1F98,$0000
	dc.w	$5838,$0030,$5808,$0000,$504C,$0000,$504C,$0000
	dc.w	$3024,$0000,$3024,$0000,$3424,$0000,$3424,$0000
	dc.w	$2424,$0000,$2424,$0000,$606C,$0000,$606C,$0000
lla8: dc.w 3,0,17,14,0,0
	dc.w	$2000,$0000,$2000,$0000,$1000,$0000,$1000,$0000
	dc.w	$3000,$2000,$1000,$0000,$7800,$7000,$0800,$0000
	dc.w	$1800,$1000,$0800,$0000,$1800,$0000,$1800,$0000
	dc.w	$1806,$0006,$1800,$0000,$3808,$0808,$3000,$0000
	dc.w	$3FF8,$0E00,$31F8,$01E0,$3FF0,$0000,$3FF0,$00F0
	dc.w	$3FF0,$0000,$3FF0,$0060,$1FF0,$0060,$1F90,$0000
	dc.w	$2838,$0030,$2808,$0000,$2858,$0000,$2858,$0000
	dc.w	$6828,$0000,$6828,$0000,$4828,$0000,$4828,$0000
	dc.w	$C818,$0000,$C818,$0000,$1860,$0000,$1860,$0000

lla9: dc.w 3,0,16,5,0,0
	dc.w	$4800,$0000,$4800,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$2000,$1000,$0000,$3000,$2000,$1000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7800,$3000,$4800,$4800
	dc.w	$FC00,$3000,$CC00,$0C00,$FC00,$0000,$FC00,$0400
	dc.w	$FC00,$0000,$FC00,$0000,$CC00,$0000,$CC00,$0000
	dc.w	$8400,$0000,$8400,$0000,$8400,$0000,$8400,$0000
	dc.w	$8400,$0000,$8400,$0000,$8400,$0000,$8400,$0000
	dc.w	$8400,$0000,$8400,$0000
lla10: dc.w 3,0,16,5,0,0
	dc.w	$0000,$0000,$0000,$0000,$4800,$0000,$4800,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$2000,$1000,$0000,$3000,$2000,$1000,$0000
	dc.w	$3000,$3000,$0000,$0000,$7800,$3000,$4800,$4800
	dc.w	$FC00,$0000,$FC00,$0C00,$FC00,$0000,$FC00,$0400
	dc.w	$FC00,$0000,$FC00,$0000,$8C00,$0000,$8C00,$0000
	dc.w	$8400,$0000,$8400,$0000,$8400,$0000,$8400,$0000
	dc.w	$0400,$0000,$0400,$0000,$8400,$0000,$8400,$0000
	dc.w	$8400,$0000,$8400,$0000
lla11: dc.w 3,0,16,5,0,0
	dc.w	$4800,$0000,$4800,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$2000,$1000,$0000,$3000,$3000,$0000,$0000
	dc.w	$3000,$3000,$0000,$0000,$7800,$3000,$4800,$4800
	dc.w	$CC00,$3000,$CC00,$3C00,$FC00,$0000,$FC00,$0400
	dc.w	$FC00,$0000,$FC00,$0000,$CC00,$0000,$CC00,$0000
	dc.w	$8400,$0000,$8400,$0000,$8400,$0000,$8400,$0000
	dc.w	$8400,$0000,$8400,$0000,$8400,$0000,$8400,$0000
	dc.w	$8400,$0000,$8400,$0000
lla12: dc.w 3,0,16,5,0,0
	dc.w	$0000,$0000,$0000,$0000,$4800,$0000,$4800,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$2000,$1000,$0000,$3000,$2000,$1000,$0000
	dc.w	$3000,$3000,$0000,$0000,$7800,$3000,$4800,$4800
	dc.w	$FC00,$0000,$FC00,$0C00,$FC00,$0000,$FC00,$0400
	dc.w	$FC00,$0000,$FC00,$0000,$C400,$0000,$C400,$0000
	dc.w	$8400,$0000,$8400,$0000,$8400,$0000,$8400,$0000
	dc.w	$8000,$0000,$8000,$0000,$8400,$0000,$8400,$0000
	dc.w	$8400,$0000,$8400,$0000
lla13: dc.w 3,0,16,5,0,0
	dc.w	$4800,$0000,$4800,$0000,$3000,$3000,$0000,$0000
	dc.w	$3000,$3000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$0000,$3000,$0000,$7800,$0000,$7800,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$FC00,$0000,$FC00,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$CC00,$0000,$CC00,$0000
	dc.w	$4800,$0000,$4800,$0000,$4800,$0000,$4800,$0000
	dc.w	$4800,$0000,$4800,$0000,$4800,$0000,$4800,$0000
	dc.w	$4800,$0000,$4800,$0000
lla14: dc.w 3,0,16,5,0,0
	dc.w	$0000,$0000,$0000,$0000,$4800,$0000,$4800,$0000
	dc.w	$3000,$3000,$0000,$0000,$3000,$3000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$0000,$3000,$0000,$7800,$0000,$7800,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$FC00,$0000,$FC00,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$CC00,$0000,$CC00,$0000
	dc.w	$4800,$0000,$4800,$0000,$4800,$0000,$4800,$0000
	dc.w	$0800,$0000,$0800,$0000,$4800,$0000,$4800,$0000
	dc.w	$4800,$0000,$4800,$0000
lla15: dc.w 3,0,16,5,0,0
	dc.w	$4800,$0000,$4800,$0000,$3000,$3000,$0000,$0000
	dc.w	$3000,$3000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$3000,$0000,$3000,$0000,$7800,$0000,$7800,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$FC00,$0000,$FC00,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$CC00,$0000,$CC00,$0000
	dc.w	$4800,$0000,$4800,$0000,$4800,$0000,$4800,$0000
	dc.w	$4800,$0000,$4800,$0000,$4800,$0000,$4800,$0000
	dc.w	$4800,$0000,$4800,$0000
lla16: dc.w 3,0,16,5,0,0
	dc.w 0,0,0,0
	dc.w	$4800,$0000,$4800,$0000,$3000,$3000,$0000,$0000
	dc.w	$3000,$3000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3000,$0000,$3000,$0000,$3000,$0000,$3000,$0000
	dc.w	$7800,$0000,$7800,$0000,$FC00,$0000,$FC00,$0000
	dc.w	$FC00,$0000,$FC00,$0000,$FC00,$0000,$FC00,$0000
	dc.w	$C800,$0000,$C800,$0000,$4800,$0000,$4800,$0000
	dc.w	$4800,$0000,$4800,$0000,$4000,$0000,$4000,$0000
	dc.w	$4800,$0000,$4800,$0000,$4800,$0000,$4800,$0000
bul1: dc.w 3,0,2,11,0,0
	dc.w	$7FE0,$7FE0,$7FE0,$7FE0,$0000,$FFF0,$FFF0,$FFF0
	dc.w	$7FE0,$7FE0,$7FE0,$7FE0
bul2: dc.w 3,0,11,2,0,0
	dc.w	$0000,$4000,$4000,$4000,$A000,$E000,$E000,$E000
	dc.w	$A000,$E000,$E000,$E000,$A000,$E000,$E000,$E000
	dc.w	$A000,$E000,$E000,$E000,$A000,$E000,$E000,$E000
	dc.w	$A000,$E000,$E000,$E000,$A000,$E000,$E000,$E000
	dc.w	$A000,$E000,$E000,$E000,$A000,$E000,$E000,$E000
	dc.w	$A000,$E000,$E000,$E000,$0000,$4000,$4000,$4000
bul3: dc.w 3,0,11,11,0,0
	dc.w	$0020,$0030,$0030,$0030,$0050,$0070,$0070,$0070
	dc.w	$00A0,$00E0,$00E0,$00E0,$0140,$01C0,$01C0,$01C0
	dc.w	$0280,$0380,$0380,$0380,$0500,$0700,$0700,$0700
	dc.w	$0A00,$0E00,$0E00,$0E00,$1400,$1C00,$1C00,$1C00
	dc.w	$2800,$3800,$3800,$3800,$5000,$7000,$7000,$7000
	dc.w	$A000,$E000,$E000,$E000,$4000,$C000,$C000,$C000

bul4: dc.w 3,0,11,11,0,0
	dc.w	$4000,$C000,$C000,$C000,$A000,$E000,$E000,$E000
	dc.w	$5000,$7000,$7000,$7000,$2800,$3800,$3800,$3800
	dc.w	$1400,$1C00,$1C00,$1C00,$0A00,$0E00,$0E00,$0E00
	dc.w	$0500,$0700,$0700,$0700,$0280,$0380,$0380,$0380
	dc.w	$0140,$01C0,$01C0,$01C0,$00A0,$00E0,$00E0,$00E0
	dc.w	$0050,$0070,$0070,$0070,$0020,$0030,$0030,$0030


bul21: dc.w 3,0,2,11,0,0
	dc.w	$0F00,$7FE0,$0000,$0000,$0600,$0000,$F9F0,$0000
	dc.w	$0F00,$7FE0,$0000,$0000


bul22: dc.w 3,0,11,2,0,0
	dc.w	$0000,$0000,$4000,$0000,$0000,$A000,$4000,$0000
	dc.w	$0000,$A000,$4000,$0000,$0000,$A000,$4000,$0000
	dc.w	$A000,$A000,$4000,$0000,$E000,$A000,$0000,$0000
	dc.w	$E000,$A000,$0000,$0000,$A000,$A000,$4000,$0000
	dc.w	$0000,$A000,$4000,$0000,$0000,$A000,$4000,$0000
	dc.w	$0000,$A000,$4000,$0000,$0000,$0000,$4000,$0000


bul23: dc.w 3,0,11,11,0,0
	dc.w	$0000,$0020,$0010,$0000,$0000,$0050,$0020,$0000
	dc.w	$0000,$00A0,$0040,$0000,$0100,$0140,$0080,$0000
	dc.w	$0280,$0280,$0100,$0000,$0700,$0500,$0000,$0000
	dc.w	$0E00,$0A00,$0000,$0000,$1400,$1400,$0800,$0000
	dc.w	$0800,$2800,$1000,$0000,$0000,$5000,$2000,$0000
	dc.w	$0000,$A000,$4000,$0000,$0000,$4000,$8000,$0000


bul24: dc.w 3,0,11,11,0,0
	dc.w	$0000,$4000,$8000,$0000,$0000,$A000,$4000,$0000
	dc.w	$0000,$5000,$2000,$0000,$0800,$2800,$1000,$0000
	dc.w	$1400,$1400,$0800,$0000,$0E00,$0A00,$0000,$0000
	dc.w	$0700,$0500,$0000,$0000,$0280,$0280,$0100,$0000
	dc.w	$0100,$0140,$0080,$0000,$0000,$00A0,$0040,$0000
	dc.w	$0000,$0050,$0020,$0000,$0000,$0020,$0010,$0000



topos: dc.w 3,19,6,319,0,0
	dc.w	$FCF0,$0000,$0000,$0000,$FCFE,$0000,$0000,$0000
	dc.w	$C0FE,$0000,$0000,$0000,$FEFE,$0000,$0000,$0000
	dc.w	$0101,$0101,$0000,$0000,$0101,$0101,$0000,$0000
	dc.w	$0100,$0100,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0101,$0101,$0000,$0000
	dc.w	$0101,$0101,$0000,$0000,$0100,$0100,$0000,$0000
	dc.w	$FCFE,$0000,$0000,$0000,$C0FE,$0000,$0000,$0000
	dc.w	$FEFE,$0000,$0000,$0000,$FEFE,$0000,$0000,$0000
	dc.w	$C430,$0000,$0000,$0000,$CCC6,$0000,$0000,$0000
	dc.w	$C0C0,$0000,$0000,$0000,$C0C6,$0000,$0000,$0000
	dc.w	$0303,$0303,$0000,$0000,$0303,$0303,$0000,$0000
	dc.w	$0300,$0300,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0077,$0000,$1175,$1175,$0000,$1175
	dc.w	$7000,$7000,$01DC,$7000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0181,$0181,$0000,$0000
	dc.w	$8181,$8181,$0000,$0000,$8180,$8180,$0000,$0000
	dc.w	$CCC6,$0000,$0000,$0000,$C0C0,$0000,$0000,$0000
	dc.w	$C0C6,$0000,$0000,$0000,$C6C6,$0000,$0000,$0000
	dc.w	$CC30,$0000,$0000,$0000,$0C06,$0000,$0000,$0000
	dc.w	$D8C0,$0000,$0000,$0000,$C006,$0000,$0000,$0000
	dc.w	$0109,$0109,$0000,$0000,$0909,$0909,$0000,$0000
	dc.w	$0908,$0908,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0055,$0000,$1155,$1155,$0000,$1155
	dc.w	$4000,$4000,$0154,$4000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$2121,$2121,$0000,$0000
	dc.w	$2121,$2121,$0000,$0000,$2100,$2100,$0000,$0000
	dc.w	$0C06,$0000,$0000,$0000,$D8C0,$0000,$0000,$0000
	dc.w	$C006,$0000,$0000,$0000,$C6C6,$0000,$0000,$0000
	dc.w	$D430,$0000,$0000,$0000,$FC1E,$0000,$0000,$0000
	dc.w	$FEFE,$0000,$0000,$0000,$FE06,$0000,$0000,$0000
	dc.w	$01F5,$01F5,$0000,$0000,$F5F5,$F5F5,$0000,$0000
	dc.w	$F5F4,$F5F4,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0055,$0000,$1575,$1575,$0000,$1575
	dc.w	$6000,$6000,$0154,$6000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$5F5F,$5F5F,$0000,$0000
	dc.w	$5F5F,$5F5F,$0000,$0000,$5F00,$5F00,$0000,$0000
	dc.w	$FC1E,$0000,$0000,$0000,$FEFE,$0000,$0000,$0000
	dc.w	$FE06,$0000,$0000,$0000,$FEFE,$0000,$0000,$0000
	dc.w	$E430,$0000,$0000,$0000,$C006,$0000,$0000,$0000
	dc.w	$1806,$0000,$0000,$0000,$C606,$0000,$0000,$0000
	dc.w	$01F1,$01F1,$0000,$0000,$F1F1,$F1F1,$0000,$0000
	dc.w	$F1F0,$F1F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0055,$0000,$1555,$1555,$0000,$1555
	dc.w	$4000,$4000,$0154,$4000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1F1F,$1F1F,$0000,$0000
	dc.w	$1F1F,$1F1F,$0000,$0000,$1F00,$1F00,$0000,$0000
	dc.w	$C006,$0000,$0000,$0000,$1806,$0000,$0000,$0000
	dc.w	$C606,$0000,$0000,$0000,$C606,$0000,$0000,$0000
	dc.w	$C430,$0000,$0000,$0000,$C6C6,$0000,$0000,$0000
	dc.w	$18C6,$0000,$0000,$0000,$C606,$0000,$0000,$0000
	dc.w	$0111,$0111,$0000,$0000,$1111,$1111,$0000,$0000
	dc.w	$1110,$1110,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0077,$0000,$1F52,$1F52,$0000,$1F52
	dc.w	$7000,$7000,$01DC,$7000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1111,$1111,$0000,$0000
	dc.w	$1111,$1111,$0000,$0000,$1100,$1100,$0000,$0000
	dc.w	$C6C6,$0000,$0000,$0000,$18C6,$0000,$0000,$0000
	dc.w	$C606,$0000,$0000,$0000,$C6C6,$0000,$0000,$0000
	dc.w	$FCF8,$0000,$0000,$0000,$FEFE,$0000,$0000,$0000
	dc.w	$18FE,$0000,$0000,$0000,$FE06,$0000,$0000,$0000
	dc.w	$0333,$0333,$0000,$0000,$3333,$3333,$0000,$0000
	dc.w	$3330,$3330,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1999,$1999,$0000,$0000
	dc.w	$9999,$9999,$0000,$0000,$9980,$9980,$0000,$0000
	dc.w	$FEFE,$0000,$0000,$0000,$18FE,$0000,$0000,$0000
	dc.w	$FE06,$0000,$0000,$0000,$FEFE,$0000,$0000,$0000

lec1: dc.w 3,0,10,15,0,0
	dc.w	$8000,$0000,$0000,$0000,$C000,$0000,$0000,$0000
	dc.w	$E000,$0000,$0000,$0000,$F000,$0000,$0000,$0000
	dc.w	$F800,$0000,$0000,$0000,$FC00,$0000,$0000,$0000
	dc.w	$FE00,$0000,$0000,$0000,$FF00,$0000,$0000,$0000
	dc.w	$FF80,$0000,$0000,$0000,$FFC0,$0000,$0000,$0000
	dc.w	$FFE0,$0000,$0000,$0000,$FFF0,$0000,$0000,$0000
	dc.w	$FFF8,$0000,$0000,$0000,$FFFC,$0000,$0000,$0000
	dc.w	$FFFE,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000



rob1: dc.w 3,0,10,15,0,0
	dc.w	$0000,$0600,$0900,$0000,$0000,$0000,$0F00,$0000
	dc.w	$0000,$0600,$0900,$0000,$0000,$7FE0,$0000,$0000
	dc.w	$0000,$FFF0,$0000,$0000,$0000,$C630,$0900,$0000
	dc.w	$0000,$C030,$0F00,$0000,$0000,$C930,$0600,$0000
	dc.w	$0000,$0600,$C930,$0000,$0000,$0F00,$0000,$0000
	dc.w	$0000,$0900,$1080,$0000,$0000,$0900,$1080,$0000
	dc.w	$0000,$0900,$1080,$0000,$0000,$0000,$1980,$0000
	dc.w	$0000,$0000,$1980,$0000,$0000,$0000,$39C0,$0000
tlla1: dc.w 3,0,11,9,0,0
	dc.w	$2000,$2000,$0000,$0000,$6000,$0000,$6000,$0000
	dc.w	$F000,$1000,$E000,$0000,$3000,$3000,$0000,$0000
	dc.w	$3000,$3000,$0000,$0000,$7180,$3180,$4000,$0000
	dc.w	$7F40,$3040,$4F00,$0F00,$7F00,$3C00,$4300,$0300
	dc.w	$3B00,$3B00,$0000,$0000,$3180,$3180,$0000,$0000
	dc.w	$3180,$3180,$0000,$0000,$7380,$7380,$0000,$0000
tlla2: dc.w 3,0,11,9,0,0
	dc.w	$2000,$2000,$0000,$0000,$3000,$3000,$0000,$0000
	dc.w	$7000,$1000,$6000,$0000,$F000,$1000,$E000,$0000
	dc.w	$1840,$1840,$0000,$0000,$18A0,$18A0,$0000,$0000
	dc.w	$3F80,$1C00,$2380,$0380,$3F80,$1F00,$2080,$0080
	dc.w	$1CC0,$1CC0,$0000,$0000,$1860,$1860,$0000,$0000
	dc.w	$3060,$3060,$0000,$0000,$E0E0,$E0E0,$0000,$0000
tlla3: dc.w 3,0,11,4,0,0
	dc.w	$5000,$5000,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$2000,$2000,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$2000,$2000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$2000,$0000,$2000,$2000,$7000,$2000,$5000,$5000
	dc.w	$7000,$7000,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$D000,$D000,$0000,$0000,$1800,$1800,$0000,$0000
tlla4: dc.w 3,0,11,4,0,0
	dc.w	$0000,$0000,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$2000,$2000,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$2000,$2000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$2000,$0000,$2000,$2000,$7000,$2000,$5000,$5000
	dc.w	$7000,$7000,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$5800,$5800,$0000,$0000,$C000,$C000,$0000,$0000
tlla5: dc.w 3,0,11,4,0,0
	dc.w	$5000,$5000,$0000,$0000,$2000,$0000,$2000,$0000
	dc.w	$2000,$0000,$2000,$0000,$0000,$0000,$0000,$0000
	dc.w	$2000,$2000,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$7000,$7000,$0000,$0000,$F800,$F800,$0000,$0000
	dc.w	$D800,$D800,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$D000,$D000,$0000,$0000,$1800,$1800,$0000,$0000
tlla6: dc.w 3,0,11,4,0,0
	dc.w	$0000,$0000,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$2000,$0000,$2000,$0000,$2000,$0000,$2000,$0000
	dc.w	$0000,$0000,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$7000,$7000,$0000,$0000,$F800,$F800,$0000,$0000
	dc.w	$D800,$D800,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$5800,$5800,$0000,$0000,$C000,$C000,$0000,$0000
tlla7: dc.w 3,0,11,9,0,0
	dc.w	$0080,$0080,$0000,$0000,$0180,$0180,$0000,$0000
	dc.w	$01C0,$0100,$00C0,$0000,$01E0,$0100,$00E0,$0000
	dc.w	$4300,$4300,$0000,$0000,$A300,$A300,$0000,$0000
	dc.w	$3F80,$0700,$3880,$3800,$3F80,$1F00,$2080,$2000
	dc.w	$6700,$6700,$0000,$0000,$C300,$C300,$0000,$0000
	dc.w	$C180,$C180,$0000,$0000,$E0E0,$E0E0,$0000,$0000
tlla8: dc.w 3,0,11,9,0,0
	dc.w	$0100,$0100,$0000,$0000,$0180,$0000,$0180,$0000
	dc.w	$03C0,$0200,$01C0,$0000,$0300,$0300,$0000,$0000
	dc.w	$0300,$0300,$0000,$0000,$6380,$6300,$0080,$0000
	dc.w	$BF80,$8300,$3C80,$3C00,$3F80,$0F00,$3080,$3000
	dc.w	$3700,$3700,$0000,$0000,$6300,$6300,$0000,$0000
	dc.w	$6300,$6300,$0000,$0000,$7380,$7380,$0000,$0000

mutnt1: dc.w 3,0,11,9,0,0
	dc.w	$0000,$2000,$2000,$0000,$4000,$6000,$6000,$0000
	dc.w	$0000,$F000,$F000,$0000,$0000,$B000,$B000,$0000
	dc.w	$0000,$3000,$3000,$0000,$4100,$7980,$7980,$0000
	dc.w	$4200,$7F40,$7F40,$0000,$1000,$7F40,$6F40,$0000
	dc.w	$1000,$3B00,$2B00,$0000,$0100,$3180,$3180,$0000
	dc.w	$2100,$3180,$1080,$0000,$7180,$7380,$0200,$0000


mutnt2: dc.w 3,0,11,9,0,0
	dc.w	$0000,$2000,$2000,$0000,$2000,$3000,$3000,$0000
	dc.w	$6000,$7000,$7000,$0000,$0000,$F000,$F000,$0000
	dc.w	$8000,$9840,$9840,$0000,$0080,$98A0,$98A0,$0000
	dc.w	$2100,$3FA0,$3FA0,$0000,$0000,$3F80,$3F80,$0000
	dc.w	$0000,$1FC0,$1FC0,$0000,$1080,$1CE0,$0CE0,$0000
	dc.w	$3040,$3460,$2460,$0000,$80A0,$E0E0,$6040,$0000


mutnt3: dc.w 3,0,11,4,0,0
	dc.w	$0000,$5000,$5000,$0000,$4000,$7000,$7000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$2000,$2000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$0000,$0000,$0000
	dc.w	$2000,$2000,$2000,$0000,$4000,$7000,$7000,$0000
	dc.w	$0000,$7000,$7000,$0000,$0000,$7000,$7000,$0000
	dc.w	$9000,$D000,$4000,$0000,$1000,$1800,$0800,$0000


mutnt4: dc.w 3,0,11,4,0,0
	dc.w	$0000,$5000,$5000,$0000,$1000,$7000,$7000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$2000,$2000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$0000,$0000,$0000
	dc.w	$2000,$2000,$2000,$0000,$1000,$7000,$7000,$0000
	dc.w	$0000,$7000,$7000,$0000,$0000,$7000,$7000,$0000
	dc.w	$4800,$5800,$1000,$0000,$4000,$C000,$8000,$0000


mutnt5: dc.w 3,0,11,4,0,0
	dc.w	$0000,$5000,$5000,$0000,$4000,$7000,$7000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$2000,$2000,$0000
	dc.w	$4000,$7000,$7000,$0000,$B000,$F800,$F800,$0000
	dc.w	$0800,$F800,$F800,$0000,$0000,$5800,$5800,$0000
	dc.w	$8000,$D000,$5000,$0000,$1800,$1800,$0000,$0000


mutnt6: dc.w 3,0,11,4,0,0
	dc.w	$0000,$5000,$5000,$0000,$1000,$7000,$7000,$0000
	dc.w	$0000,$2000,$2000,$0000,$2000,$0000,$2000,$0000
	dc.w	$0000,$2000,$2000,$0000,$0000,$2000,$2000,$0000
	dc.w	$1000,$7000,$7000,$0000,$6800,$F800,$F800,$0000
	dc.w	$8000,$F800,$F800,$0000,$0000,$D000,$D000,$0000
	dc.w	$0800,$5800,$5000,$0000,$C000,$C000,$0000,$0000


mutnt7: dc.w 3,0,11,9,0,0
	dc.w	$0000,$0080,$0080,$0000,$0080,$0180,$0180,$0000
	dc.w	$00C0,$01C0,$01C0,$0000,$0000,$01E0,$01E0,$0000
	dc.w	$0020,$4320,$4320,$0000,$2000,$A320,$A320,$0000
	dc.w	$1080,$BF80,$BF80,$0000,$0000,$3F80,$3F80,$0000
	dc.w	$0000,$7F00,$7F00,$0000,$2100,$E700,$E600,$0000
	dc.w	$4180,$C580,$C480,$0000,$A020,$E0E0,$40C0,$0000


mutnt8: dc.w 3,0,11,9,0,0
	dc.w	$0000,$0100,$0100,$0000,$0080,$0180,$0180,$0000
	dc.w	$0000,$03C0,$03C0,$0000,$0000,$0340,$0340,$0000
	dc.w	$0000,$0300,$0300,$0000,$2080,$6780,$6780,$0000
	dc.w	$1080,$BF80,$BF80,$0000,$0200,$BF80,$BD80,$0000
	dc.w	$0200,$3700,$3500,$0000,$2000,$6300,$6300,$0000
	dc.w	$2100,$6300,$4200,$0000,$6380,$7380,$1000,$0000


splat1: dc.w 3,0,5,7,0,0
	dc.w	$6000,$6000,$6000,$0000,$8000,$F800,$F800,$0000
	dc.w	$AC00,$FF00,$FF00,$0000,$1000,$FF00,$FF00,$0000
	dc.w	$0800,$F800,$F800,$0000,$2000,$6000,$6000,$0000
splat2: dc.w 3,0,5,7,0,0
	dc.w	$0600,$0600,$0600,$0000,$0100,$1F00,$1F00,$0000
	dc.w	$3500,$FF00,$FF00,$0000,$0800,$FF00,$FF00,$0000
	dc.w	$1000,$1F00,$1F00,$0000,$0400,$0600,$0600,$0000



yaksign: dc.w 3,1,22,17,0,0
	dc.w	$2001,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$5002,$2001,$2001,$2001,$8000,$0000,$0000,$0000
	dc.w	$8804,$7003,$7003,$7003,$4000,$8000,$8000,$8000
	dc.w	$4804,$3003,$3003,$3003,$8000,$0000,$0000,$0000
	dc.w	$4618,$3807,$3807,$3807,$8000,$0000,$0000,$0000
	dc.w	$21E1,$1E1E,$1E1E,$1E1E,$0000,$0000,$0000,$0000
	dc.w	$1002,$0FFC,$0FFC,$0FFC,$0000,$0000,$0000,$0000
	dc.w	$1002,$0FFC,$0FFC,$0FFC,$0000,$0000,$0000,$0000
	dc.w	$21E1,$1E1E,$1E1E,$1E1E,$0000,$0000,$0000,$0000
	dc.w	$4618,$3807,$3807,$3807,$8000,$0000,$0000,$0000
	dc.w	$4804,$3003,$3003,$3003,$8000,$0000,$0000,$0000
	dc.w	$8804,$7003,$7003,$7003,$4000,$8000,$8000,$8000
	dc.w	$9002,$6001,$6001,$6001,$4000,$8000,$8000,$8000
	dc.w	$9002,$6001,$6001,$6001,$4000,$8000,$8000,$8000
	dc.w	$9002,$6001,$6001,$6001,$4000,$8000,$8000,$8000
	dc.w	$9002,$6001,$6001,$6001,$4000,$8000,$8000,$8000
	dc.w	$8804,$7003,$7003,$7003,$4000,$8000,$8000,$8000
	dc.w	$4804,$3003,$3003,$3003,$8000,$0000,$0000,$0000
	dc.w	$4618,$3807,$3807,$3807,$8000,$0000,$0000,$0000
	dc.w	$21E1,$1E1E,$1E1E,$1E1E,$0000,$0000,$0000,$0000
	dc.w	$1002,$0FFC,$0FFC,$0FFC,$0000,$0000,$0000,$0000
	dc.w	$0C0C,$03F0,$03F0,$03F0,$0000,$0000,$0000,$0000
	dc.w	$03F0,$0000,$0000,$0000,$0000,$0000,$0000,$0000

kil1: dc.w 3,0,11,6,0,0
	dc.w	$2000,$3C00,$3C00,$3C00,$3800,$0600,$0600,$0600
	dc.w	$0000,$3E00,$3E00,$3E00,$3000,$3C00,$3C00,$3C00
	dc.w	$0000,$1800,$1800,$1800,$1800,$3C00,$3C00,$3C00
	dc.w	$3200,$3E00,$3E00,$3E00,$6300,$7F00,$7F00,$7F00
	dc.w	$0000,$3C00,$3C00,$3C00,$0400,$3C00,$3C00,$3C00
	dc.w	$0600,$3600,$3600,$3600,$0200,$6200,$6200,$6200
	dc.w	$0600,$C600,$C600,$C600
kil2: dc.w 3,0,11,6,0,0
	dc.w	$8000,$F000,$F000,$F000,$E000,$1800,$1800,$1800
	dc.w	$0000,$F800,$F800,$F800,$C000,$F000,$F000,$F000
	dc.w	$0000,$6000,$6000,$6000,$6000,$F000,$F000,$F000
	dc.w	$6000,$F000,$F000,$F000,$6000,$F000,$F000,$F000
	dc.w	$6000,$F000,$F000,$F000,$0000,$6000,$6000,$6000
	dc.w	$0000,$6000,$6000,$6000,$0000,$6000,$6000,$6000
	dc.w	$0000,$E000,$E000,$E000
kil3: dc.w 3,0,11,6,0,0
	dc.w	$0000,$3000,$3000,$3000,$0000,$7800,$7800,$7800
	dc.w	$0000,$7800,$7800,$7800,$4800,$7800,$7800,$7800
	dc.w	$0000,$3000,$3000,$3000,$8400,$FC00,$FC00,$FC00
	dc.w	$B400,$CC00,$CC00,$CC00,$8000,$F800,$F800,$F800
	dc.w	$3800,$7800,$7800,$7800,$4000,$4800,$4800,$4800
	dc.w	$4000,$4800,$4800,$4800,$C000,$C800,$C800,$C800
	dc.w	$0000,$0C00,$0C00,$0C00
kil4: dc.w 3,0,11,6,0,0
	dc.w	$0000,$3000,$3000,$3000,$0000,$7800,$7800,$7800
	dc.w	$0000,$7800,$7800,$7800,$4800,$7800,$7800,$7800
	dc.w	$0000,$3000,$3000,$3000,$8400,$FC00,$FC00,$FC00
	dc.w	$B400,$CC00,$CC00,$CC00,$0400,$7C00,$7C00,$7C00
	dc.w	$7000,$7800,$7800,$7800,$0800,$4800,$4800,$4800
	dc.w	$0800,$4800,$4800,$4800,$0C00,$4C00,$4C00,$4C00
	dc.w	$0000,$C000,$C000,$C000
kil5: dc.w 3,0,11,6,0,0
	dc.w	$4800,$7800,$7800,$7800,$7800,$0000,$0000,$0000
	dc.w	$0000,$7800,$7800,$7800,$4800,$7800,$7800,$7800
	dc.w	$0000,$3000,$3000,$3000,$8400,$FC00,$FC00,$FC00
	dc.w	$B400,$FC00,$FC00,$FC00,$8000,$F800,$F800,$F800
	dc.w	$3800,$7800,$7800,$7800,$4000,$4800,$4800,$4800
	dc.w	$4000,$4800,$4800,$4800,$C000,$C800,$C800,$C800
	dc.w	$0000,$0C00,$0C00,$0C00
kil6: dc.w 3,0,11,6,0,0
	dc.w	$4800,$7800,$7800,$7800,$7800,$0000,$0000,$0000
	dc.w	$0000,$7800,$7800,$7800,$4800,$7800,$7800,$7800
	dc.w	$0000,$3000,$3000,$3000,$8400,$FC00,$FC00,$FC00
	dc.w	$B400,$FC00,$FC00,$FC00,$0400,$7C00,$7C00,$7C00
	dc.w	$7000,$7800,$7800,$7800,$0800,$4800,$4800,$4800
	dc.w	$0800,$4800,$4800,$4800,$0C00,$4C00,$4C00,$4C00
	dc.w	$0000,$C000,$C000,$C000
kil7: dc.w 3,0,11,6,0,0
	dc.w	$0800,$7800,$7800,$7800,$3800,$C000,$C000,$C000
	dc.w	$0000,$F800,$F800,$F800,$1800,$7800,$7800,$7800
	dc.w	$0000,$3000,$3000,$3000,$3000,$7800,$7800,$7800
	dc.w	$3000,$7800,$7800,$7800,$3000,$7800,$7800,$7800
	dc.w	$3000,$7800,$7800,$7800,$0000,$3000,$3000,$3000
	dc.w	$0000,$3000,$3000,$3000,$0000,$3000,$3000,$3000
	dc.w	$0000,$3800,$3800,$3800
kil8: dc.w 3,0,11,6,0,0
	dc.w	$0400,$3C00,$3C00,$3C00,$1C00,$6000,$6000,$6000
	dc.w	$0000,$7C00,$7C00,$7C00,$0C00,$3C00,$3C00,$3C00
	dc.w	$0000,$1800,$1800,$1800,$1800,$3C00,$3C00,$3C00
	dc.w	$4C00,$7C00,$7C00,$7C00,$C600,$FE00,$FE00,$FE00
	dc.w	$0000,$3C00,$3C00,$3C00,$2000,$3C00,$3C00,$3C00
	dc.w	$6000,$6C00,$6C00,$6C00,$4000,$4600,$4600,$4600
	dc.w	$6000,$6300,$6300,$6300
kil9: dc.w 3,0,11,6,0,0
	dc.w	$3C00,$0000,$0000,$0000,$3E00,$0000,$0000,$0000
	dc.w	$3E00,$0000,$0000,$0000,$3C00,$0000,$0000,$0000
	dc.w	$1800,$0000,$0000,$0000,$3C00,$0000,$0000,$0000
	dc.w	$3E00,$0000,$0000,$0000,$7F00,$0000,$0000,$0000
	dc.w	$3C00,$0000,$0000,$0000,$3C00,$0000,$0000,$0000
	dc.w	$3600,$0000,$0000,$0000,$6200,$0000,$0000,$0000
	dc.w	$C600,$0000,$0000,$0000
kil10: dc.w 3,0,11,6,0,0
	dc.w	$F000,$0000,$0000,$0000,$F800,$0000,$0000,$0000
	dc.w	$F800,$0000,$0000,$0000,$F000,$0000,$0000,$0000
	dc.w	$6000,$0000,$0000,$0000,$F000,$0000,$0000,$0000
	dc.w	$F000,$0000,$0000,$0000,$F000,$0000,$0000,$0000
	dc.w	$F000,$0000,$0000,$0000,$6000,$0000,$0000,$0000
	dc.w	$6000,$0000,$0000,$0000,$6000,$0000,$0000,$0000
	dc.w	$E000,$0000,$0000,$0000
kil11: dc.w 3,0,11,6,0,0
	dc.w	$3000,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$FC00,$0000,$0000,$0000
	dc.w	$FC00,$0000,$0000,$0000,$F800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$4800,$0000,$0000,$0000
	dc.w	$4800,$0000,$0000,$0000,$C800,$0000,$0000,$0000
	dc.w	$0C00,$0000,$0000,$0000
kil12: dc.w 3,0,11,6,0,0
	dc.w	$3000,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$FC00,$0000,$0000,$0000
	dc.w	$FC00,$0000,$0000,$0000,$7C00,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$4800,$0000,$0000,$0000
	dc.w	$4800,$0000,$0000,$0000,$4C00,$0000,$0000,$0000
	dc.w	$C000,$0000,$0000,$0000
kil13: dc.w 3,0,11,6,0,0
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$FC00,$0000,$0000,$0000
	dc.w	$FC00,$0000,$0000,$0000,$F800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$4800,$0000,$0000,$0000
	dc.w	$4800,$0000,$0000,$0000,$C800,$0000,$0000,$0000
	dc.w	$0C00,$0000,$0000,$0000
kil14: dc.w 3,0,11,6,0,0
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$FC00,$0000,$0000,$0000
	dc.w	$FC00,$0000,$0000,$0000,$7C00,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$4800,$0000,$0000,$0000
	dc.w	$4800,$0000,$0000,$0000,$4C00,$0000,$0000,$0000
	dc.w	$C000,$0000,$0000,$0000
kil15: dc.w 3,0,11,6,0,0
	dc.w	$7800,$0000,$0000,$0000,$F800,$0000,$0000,$0000
	dc.w	$F800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$7800,$0000,$0000,$0000
	dc.w	$7800,$0000,$0000,$0000,$3000,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$3000,$0000,$0000,$0000
	dc.w	$3800,$0000,$0000,$0000
kil16: dc.w 3,0,11,6,0,0
	dc.w	$3C00,$0000,$0000,$0000,$7C00,$0000,$0000,$0000
	dc.w	$7C00,$0000,$0000,$0000,$3C00,$0000,$0000,$0000
	dc.w	$1800,$0000,$0000,$0000,$3C00,$0000,$0000,$0000
	dc.w	$7C00,$0000,$0000,$0000,$FE00,$0000,$0000,$0000
	dc.w	$3C00,$0000,$0000,$0000,$3C00,$0000,$0000,$0000
	dc.w	$6C00,$0000,$0000,$0000,$4600,$0000,$0000,$0000
	dc.w	$6300,$0000,$0000,$0000


fhg1: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0780,$0480
	dc.w	$0000,$0000,$0FC0,$0FC0,$0000,$0000,$1CE0,$1CE0
	dc.w	$0000,$0000,$1860,$0840,$0000,$0000,$1860,$0840
	dc.w	$0000,$0000,$1CE0,$1CE0,$0000,$0000,$0FC0,$0FC0
	dc.w	$0000,$0000,$0780,$0480,$0000,$0000,$0000,$0000
fhg2: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0000,$0300,$0000,$0000,$0000,$0780,$0780
	dc.w	$0000,$0000,$0FC0,$0FC0,$0000,$0000,$1CE0,$1CE0
	dc.w	$0000,$0000,$3870,$1860,$0000,$0000,$3870,$1860
	dc.w	$0000,$0000,$1CE0,$1CE0,$0000,$0000,$0FC0,$0FC0
	dc.w	$0000,$0000,$0780,$0780,$0000,$0000,$0300,$0000
fhg3: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0000,$0300,$0000,$0000,$0000,$0780,$0780
	dc.w	$0000,$0000,$0780,$0780,$0000,$0000,$1860,$1860
	dc.w	$0000,$0000,$3870,$1860,$0000,$0000,$3870,$1860
	dc.w	$0000,$0000,$1860,$1860,$0000,$0000,$0780,$0780
	dc.w	$0000,$0000,$0780,$0780,$0000,$0000,$0300,$0000
fhg4: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0000,$0300,$0000,$0000,$0000,$0780,$0780
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1020,$1020
	dc.w	$0000,$0000,$3030,$1020,$0000,$0000,$3030,$1020
	dc.w	$0000,$0000,$1020,$1020,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0780,$0780,$0000,$0000,$0300,$0000
fhy: dc.w 3,0,10,15,0,0
	dc.w	$0080,$0000,$0000,$0080,$0080,$0140,$0140,$0080
	dc.w	$02A0,$0140,$0140,$0080,$0490,$0360,$0360,$0490
	dc.w	$0410,$0000,$03E0,$0410,$2142,$0000,$0080,$0000
	dc.w	$17F4,$0000,$0000,$1634,$0FF8,$0410,$0000,$0F78
	dc.w	$1364,$0220,$0490,$17F4,$2632,$0410,$01C0,$07F0
	dc.w	$0140,$0000,$0000,$0140

fhyp1: dc.w 3,0,7,15,0,0
	dc.w	$0000,$0000,$0300,$0000,$0000,$0000,$0300,$0300
	dc.w	$0000,$0000,$0000,$0000,$0300,$0000,$1860,$0840
	dc.w	$0300,$0000,$1860,$0840,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0300,$0300,$0000,$0000,$0300,$0000
fhyp2: dc.w 3,0,7,15,0,0
	dc.w	$0000,$0000,$0180,$0000,$0000,$0000,$0180,$0180
	dc.w	$0000,$0000,$1800,$0800,$0300,$0000,$1800,$0800
	dc.w	$0300,$0000,$0060,$0040,$0000,$0000,$0060,$0040
	dc.w	$0000,$0000,$0600,$0600,$0000,$0000,$0600,$0000
fhyp3: dc.w 3,0,7,15,0,0
	dc.w	$0000,$0000,$0400,$0000,$0000,$0000,$0E40,$0600
	dc.w	$0000,$0000,$04E0,$04C0,$0300,$0000,$0040,$0040
	dc.w	$0300,$0000,$0800,$0800,$0000,$0000,$1C80,$0C80
	dc.w	$0000,$0000,$09C0,$0180,$0000,$0000,$0080,$0000
fhyp4: dc.w 3,0,7,15,0,0
	dc.w	$0000,$0000,$0600,$0000,$0000,$0000,$0600,$0600
	dc.w	$0000,$0000,$0060,$0040,$0300,$0000,$0060,$0040
	dc.w	$0300,$0000,$1800,$0800,$0000,$0000,$1800,$0800
	dc.w	$0000,$0000,$0180,$0180,$0000,$0000,$0180,$0000

fhb: dc.w 3,0,6,15,0,0
	dc.w	$F000,$0000,$0000,$0000,$8770,$0000,$0000,$0000
	dc.w	$E550,$0000,$0000,$0000,$1550,$0000,$0000,$0000
	dc.w	$1550,$0000,$0000,$0000,$9770,$0000,$0000,$0000
	dc.w	$E000,$0000,$0000,$0000

thoub: dc.w 3,0,6,15,0,0
	dc.w	$4000,$0000,$0000,$0000,$CEEE,$0000,$0000,$0000
	dc.w	$4AAA,$0000,$0000,$0000,$4AAA,$0000,$0000,$0000
	dc.w	$4AAA,$0000,$0000,$0000,$4EEE,$0000,$0000,$0000
	dc.w	$E000,$0000,$0000,$0000
goat1: dc.w 3,0,10,12,0,0
	dc.w	$0E00,$0E00,$0E00,$0E00,$1F00,$1F00,$1F00,$1F00
	dc.w	$1100,$3100,$3100,$3100,$2020,$7030,$5030,$7030
	dc.w	$08C0,$FFE0,$FFE0,$FFE0,$0000,$5FC0,$5FC0,$5FC0
	dc.w	$0100,$1FC0,$1FC0,$1FC0,$0200,$0EC0,$0EC0,$0EC0
	dc.w	$0000,$0840,$0840,$0840,$0000,$0840,$0840,$0840
	dc.w	$18C0,$0000,$18C0,$0000
goat2: dc.w 3,0,10,12,0,0
	dc.w	$1C00,$1C00,$1C00,$1C00,$3600,$3600,$3600,$3600
	dc.w	$6020,$6030,$6030,$6030,$0040,$6060,$6060,$6060
	dc.w	$28C0,$7FE0,$5FE0,$7FE0,$8000,$FFC0,$FFC0,$FFC0
	dc.w	$0100,$FFC0,$FFC0,$FFC0,$0200,$5EE0,$5EE0,$5EE0
	dc.w	$1000,$1870,$1870,$1870,$0000,$3010,$3010,$3010
	dc.w	$6030,$0000,$6030,$0000
goat3: dc.w 3,0,10,8,0,0
	dc.w	$2400,$2400,$2400,$2400,$6600,$7E00,$7E00,$7E00
	dc.w	$4200,$4200,$4200,$4200,$8100,$9900,$9900,$9900
	dc.w	$0000,$3C00,$3C00,$3C00,$0000,$3C00,$3C00,$3C00
	dc.w	$0800,$3C00,$3C00,$3C00,$0000,$2400,$2400,$2400
	dc.w	$0000,$2400,$2400,$2400,$6000,$0400,$6400,$0400
	dc.w	$0600,$0000,$0600,$0000
goat4: dc.w 3,0,10,8,0,0
	dc.w	$2400,$2400,$2400,$2400,$7E00,$7E00,$7E00,$7E00
	dc.w	$8100,$8100,$8100,$8100,$0000,$1800,$1800,$1800
	dc.w	$0000,$3C00,$3C00,$3C00,$0000,$3C00,$3C00,$3C00
	dc.w	$1000,$3C00,$3C00,$3C00,$0000,$2400,$2400,$2400
	dc.w	$0000,$2400,$2400,$2400,$0600,$2000,$2600,$2000
	dc.w	$6000,$0000,$6000,$0000
goat5: dc.w 3,0,10,8,0,0
	dc.w	$2400,$2400,$2400,$2400,$6600,$7E00,$7E00,$7E00
	dc.w	$4200,$5A00,$5A00,$5A00,$8100,$9900,$9900,$9900
	dc.w	$1800,$1800,$1800,$1800,$0000,$3C00,$3C00,$3C00
	dc.w	$0800,$3C00,$3C00,$3C00,$0000,$2400,$2400,$2400
	dc.w	$0000,$2400,$2400,$2400,$6000,$0400,$6400,$0400
	dc.w	$0600,$0000,$0600,$0000
goat6: dc.w 3,0,10,8,0,0
	dc.w	$2400,$2400,$2400,$2400,$7E00,$7E00,$7E00,$7E00
	dc.w	$8100,$9900,$9900,$9900,$0000,$1800,$1800,$1800
	dc.w	$1800,$1800,$1800,$1800,$0000,$3C00,$3C00,$3C00
	dc.w	$1000,$3C00,$3C00,$3C00,$0000,$2400,$2400,$2400
	dc.w	$0000,$2400,$2400,$2400,$0600,$2000,$2600,$2000
	dc.w	$6000,$0000,$6000,$0000
goat7: dc.w 3,0,10,12,0,0
	dc.w	$0380,$0380,$0380,$0380,$06C0,$06C0,$06C0,$06C0
	dc.w	$4060,$C060,$C060,$C060,$2000,$6060,$6060,$6060
	dc.w	$3140,$7FE0,$7FA0,$7FE0,$0010,$3FF0,$3FF0,$3FF0
	dc.w	$0800,$3FF0,$3FF0,$3FF0,$0400,$77A0,$77A0,$77A0
	dc.w	$0080,$E180,$E180,$E180,$0000,$80C0,$80C0,$80C0
	dc.w	$C060,$0000,$C060,$0000
goat8: dc.w 3,0,10,12,0,0
	dc.w	$0700,$0700,$0700,$0700,$0F80,$0F80,$0F80,$0F80
	dc.w	$0880,$08C0,$08C0,$08C0,$4040,$C0E0,$C0A0,$C0E0
	dc.w	$3100,$7FF0,$7FF0,$7FF0,$0000,$3FA0,$3FA0,$3FA0
	dc.w	$0800,$3F80,$3F80,$3F80,$0400,$3700,$3700,$3700
	dc.w	$0000,$2100,$2100,$2100,$0000,$2100,$2100,$2100
	dc.w	$3180,$0000,$3180,$0000
ram1: dc.w 3,0,10,12,0,0
	dc.w	$1C00,$0000,$1C00,$0000,$3600,$0000,$3600,$0000
	dc.w	$06E0,$70E0,$76E0,$70E0,$3658,$E9F8,$DFF8,$E9F8
	dc.w	$0C34,$73FC,$7FFC,$73FC,$0000,$1FF4,$1FF4,$1FF4
	dc.w	$1044,$1FF4,$1FF4,$1FF4,$03C0,$0FF0,$0FF0,$0FF0
	dc.w	$0220,$0A30,$0A30,$0A30,$0000,$0810,$0810,$0810
	dc.w	$1830,$0000,$1830,$0000
ram2: dc.w 3,0,10,12,0,0
	dc.w	$1C00,$0000,$1C00,$0000,$3600,$0000,$3600,$0000
	dc.w	$06E0,$70E0,$76E0,$70E0,$3650,$E9F8,$DFF8,$E9F8
	dc.w	$0C30,$73FC,$7FFC,$73FC,$0004,$1FF4,$1FF4,$1FF4
	dc.w	$1040,$1FF0,$1FF0,$1FF0,$03C8,$0FF8,$0FF8,$0FF8
	dc.w	$1220,$1A38,$1A38,$1A38,$0004,$300C,$300C,$300C
	dc.w	$6018,$0000,$6018,$0000
ram3: dc.w 3,0,10,6,0,0
	dc.w	$4800,$0000,$4800,$0000,$FC00,$3000,$FC00,$3000
	dc.w	$DC00,$7800,$FC00,$7800,$0000,$FC00,$FC00,$FC00
	dc.w	$B400,$FC00,$FC00,$FC00,$3000,$FC00,$FC00,$FC00
	dc.w	$8400,$FC00,$FC00,$FC00,$B400,$FC00,$FC00,$FC00
	dc.w	$1000,$5800,$5800,$5800,$0C00,$4C00,$4C00,$4C00
	dc.w	$C000,$C000,$C000,$C000
ram4: dc.w 3,0,10,6,0,0
	dc.w	$4800,$0000,$4800,$0000,$FC00,$3000,$FC00,$3000
	dc.w	$EC00,$7800,$FC00,$7800,$0000,$FC00,$FC00,$FC00
	dc.w	$B400,$FC00,$FC00,$FC00,$3000,$FC00,$FC00,$FC00
	dc.w	$8400,$FC00,$FC00,$FC00,$B000,$F800,$F800,$F800
	dc.w	$2000,$6800,$6800,$6800,$C000,$C800,$C800,$C800
	dc.w	$0C00,$0C00,$0C00,$0C00
ram5: dc.w 3,0,10,6,0,0
	dc.w	$4800,$0000,$4800,$0000,$4800,$3000,$7800,$3000
	dc.w	$CC00,$7800,$FC00,$7800,$4800,$FC00,$FC00,$FC00
	dc.w	$FC00,$FC00,$FC00,$FC00,$0000,$FC00,$FC00,$FC00
	dc.w	$9400,$FC00,$FC00,$FC00,$B400,$FC00,$FC00,$FC00
	dc.w	$1000,$5800,$5800,$5800,$0C00,$4C00,$4C00,$4C00
	dc.w	$C000,$C000,$C000,$C000
ram6: dc.w 3,0,10,6,0,0
	dc.w	$4800,$0000,$4800,$0000,$4800,$3000,$7800,$3000
	dc.w	$CC00,$7800,$FC00,$7800,$4800,$FC00,$FC00,$FC00
	dc.w	$FC00,$FC00,$FC00,$FC00,$0000,$FC00,$FC00,$FC00
	dc.w	$A400,$FC00,$FC00,$FC00,$B400,$FC00,$FC00,$FC00
	dc.w	$2000,$6800,$6800,$6800,$C000,$C800,$C800,$C800
	dc.w	$0C00,$0C00,$0C00,$0C00
ram7: dc.w 3,0,10,12,0,0
	dc.w	$00E0,$0000,$00E0,$0000,$01B0,$0000,$01B0,$0000
	dc.w	$1D80,$1C38,$1DB8,$1C38,$29B0,$7E5C,$7FEC,$7E5C
	dc.w	$30C0,$FF38,$FFF8,$FF38,$8000,$BFE0,$BFE0,$BFE0
	dc.w	$0820,$3FE0,$3FE0,$3FE0,$4F00,$7FC0,$7FC0,$7FC0
	dc.w	$1120,$7160,$7160,$7160,$8000,$C030,$C030,$C030
	dc.w	$6018,$0000,$6018,$0000
ram8: dc.w 3,0,10,12,0,0
	dc.w	$00E0,$0000,$00E0,$0000,$01B0,$0000,$01B0,$0000
	dc.w	$1D80,$1C38,$1DB8,$1C38,$69B0,$7E5C,$7FEC,$7E5C
	dc.w	$B0C0,$FF38,$FFF8,$FF38,$0000,$BFE0,$BFE0,$BFE0
	dc.w	$8820,$BFE0,$BFE0,$BFE0,$0F00,$3FC0,$3FC0,$3FC0
	dc.w	$1100,$3140,$3140,$3140,$0000,$2040,$2040,$2040
	dc.w	$3060,$0000,$3060,$0000
caml1: dc.w 3,0,9,12,0,0
	dc.w	$0000,$0000,$6000,$0000,$4100,$0100,$A000,$4000
	dc.w	$0380,$0380,$6000,$0000,$06C0,$06C0,$7120,$0000
	dc.w	$4100,$4100,$3ED0,$0000,$2010,$2010,$1FC0,$0000
	dc.w	$1000,$1000,$0F40,$0000,$0000,$0000,$0440,$0000
	dc.w	$0000,$0000,$0440,$0000,$0000,$0000,$0CC0,$0000
caml2: dc.w 3,0,9,12,0,0
	dc.w	$0000,$0000,$6000,$0000,$4100,$0100,$A000,$4000
	dc.w	$0388,$0388,$6000,$0000,$06C0,$06C0,$7130,$0000
	dc.w	$4100,$4100,$3EC0,$0000,$2000,$2000,$1FC0,$0000
	dc.w	$1000,$1000,$0F60,$0000,$0000,$0000,$0C30,$0000
	dc.w	$0000,$0000,$1810,$0000,$0000,$0000,$3030,$0000
caml3: dc.w 3,0,9,6,0,0
	dc.w	$0000,$0000,$5000,$0000,$0000,$0000,$7000,$0000
	dc.w	$6000,$6000,$1000,$0000,$7000,$7000,$0000,$0000
	dc.w	$D800,$D800,$2000,$0000,$0000,$0000,$F800,$0000
	dc.w	$0000,$0000,$5000,$0000,$0000,$0000,$5000,$0000
	dc.w	$0000,$0000,$5800,$0000,$0000,$0000,$C000,$0000
caml4: dc.w 3,0,9,6,0,0
	dc.w	$0000,$0000,$5000,$0000,$0000,$0000,$7000,$0000
	dc.w	$3000,$3000,$4000,$0000,$7000,$7000,$0000,$0000
	dc.w	$D800,$D800,$2000,$0000,$0000,$0000,$F800,$0000
	dc.w	$0000,$0000,$5000,$0000,$0000,$0000,$5000,$0000
	dc.w	$0000,$0000,$D000,$0000,$0000,$0000,$1800,$0000
caml5: dc.w 3,0,9,6,0,0
	dc.w	$0000,$0000,$5000,$0000,$0000,$0000,$7000,$0000
	dc.w	$7000,$7000,$0000,$0000,$0000,$0000,$7000,$0000
	dc.w	$8800,$8800,$7000,$0000,$0000,$0000,$F800,$0000
	dc.w	$0000,$0000,$F800,$0000,$0000,$0000,$5000,$0000
	dc.w	$0000,$0000,$5800,$0000,$0000,$0000,$C000,$0000
caml6: dc.w 3,0,9,6,0,0
	dc.w	$0000,$0000,$5000,$0000,$0000,$0000,$7000,$0000
	dc.w	$7000,$7000,$0000,$0000,$0000,$0000,$7000,$0000
	dc.w	$8800,$8800,$7000,$0000,$0000,$0000,$F800,$0000
	dc.w	$0000,$0000,$F800,$0000,$0000,$0000,$5000,$0000
	dc.w	$0000,$0000,$D000,$0000,$0000,$0000,$1800,$0000
caml7: dc.w 3,0,9,12,0,0
	dc.w	$0000,$0000,$0030,$0000,$0410,$0400,$0028,$0010
	dc.w	$8E00,$8E00,$0030,$0000,$1B00,$1B00,$6470,$0000
	dc.w	$0410,$0410,$1BE0,$0000,$0020,$0020,$1FC0,$0000
	dc.w	$0040,$0040,$3780,$0000,$0000,$0000,$6180,$0000
	dc.w	$0000,$0000,$40C0,$0000,$0000,$0000,$6060,$0000
caml8: dc.w 3,0,9,12,0,0
	dc.w	$0000,$0000,$0060,$0000,$0820,$0800,$0050,$0020
	dc.w	$1C00,$1C00,$0060,$0000,$3600,$3600,$48E0,$0000
	dc.w	$0820,$0820,$B7C0,$0000,$8040,$8040,$3F80,$0000
	dc.w	$0080,$0080,$2F00,$0000,$0000,$0000,$2200,$0000
	dc.w	$0000,$0000,$2200,$0000,$0000,$0000,$3300,$0000


gover: dc.w 3,4,10,77,0,0
	dc.w	$7F3F,$0000,$0000,$0000,$3FFB,$0000,$0000,$0000
	dc.w	$F81F,$0000,$0000,$0000,$EF37,$0000,$0000,$0000
	dc.w	$F7F0,$0000,$0000,$0000,$FFFF,$7F3F,$0000,$0000
	dc.w	$FFFF,$3FFB,$0000,$0000,$FC3F,$F81F,$0000,$0000
	dc.w	$FFFF,$EF37,$0000,$0000,$FFF8,$F7F0,$0000,$0000
	dc.w	$FFFF,$633B,$0000,$0000,$FFFF,$39BB,$0000,$0000
	dc.w	$F83F,$8019,$0000,$0000,$FFFF,$EF37,$0000,$0000
	dc.w	$FFF8,$0730,$0000,$0000,$FF7F,$603B,$0000,$0000
	dc.w	$FFFF,$39BB,$0000,$0000,$F83F,$8019,$0000,$0000
	dc.w	$FFFF,$EF37,$0000,$0000,$FFF8,$0730,$0000,$0000
	dc.w	$8080,$0000,$7F7F,$0000,$4244,$0000,$BDBB,$0000
	dc.w	$0425,$0000,$F818,$0000,$10C8,$0000,$EF37,$0000
	dc.w	$0804,$0000,$F7F8,$0000,$FFFF,$7379,$0000,$0000
	dc.w	$FFFF,$BDBB,$0000,$0000,$F83D,$C018,$0000,$0000
	dc.w	$FFFF,$EF37,$0000,$0000,$FFFC,$8798,$0000,$0000
	dc.w	$FFFF,$7379,$0000,$0000,$FFFF,$BDBB,$0000,$0000
	dc.w	$E03D,$C018,$0000,$0000,$FFFF,$EF77,$0000,$0000
	dc.w	$CFFC,$8798,$0000,$0000,$DDD7,$7379,$0000,$0000
	dc.w	$5755,$BDBB,$0000,$0000,$6035,$C018,$0000,$0000
	dc.w	$5DDD,$E767,$0000,$0000,$4D74,$8798,$0000,$0000
	dc.w	$8C86,$7379,$0000,$0000,$4244,$BDBB,$0000,$0000
	dc.w	$3827,$C018,$0000,$0000,$1898,$E767,$0000,$0000
	dc.w	$7864,$8798,$0000,$0000,$8086,$7F79,$0000,$0000
	dc.w	$4244,$BDBB,$0000,$0000,$0420,$F81F,$0000,$0000
	dc.w	$1818,$E7E7,$0000,$0000,$0864,$F798,$0000,$0000
	dc.w	$7F79,$0000,$0000,$0000,$BDBB,$0000,$0000,$0000
	dc.w	$F81F,$0000,$0000,$0000,$E7E7,$0000,$0000,$0000
	dc.w	$F798,$0000,$0000,$0000


conti: dc.w 3,4,10,75,0,0
	dc.w	$7FBF,$0000,$0000,$0000,$DFEF,$0000,$0000,$0000
	dc.w	$EE7F,$0000,$0000,$0000,$B8DF,$0000,$0000,$0000
	dc.w	$DFE0,$0000,$0000,$0000,$FFFF,$7FBF,$0000,$0000
	dc.w	$FFFF,$DFEF,$0000,$0000,$FFFF,$EE7F,$0000,$0000
	dc.w	$FDFF,$B8DF,$0000,$0000,$FFF0,$DFE0,$0000,$0000
	dc.w	$FFFF,$71B3,$0000,$0000,$FFFF,$DC63,$0000,$0000
	dc.w	$FFFF,$8E71,$0000,$0000,$FDFF,$B8DC,$0000,$0000
	dc.w	$FFF0,$18E0,$0000,$0000,$F9FF,$7033,$0000,$0000
	dc.w	$FEF7,$DC63,$0000,$0000,$DFFB,$8E71,$0000,$0000
	dc.w	$FDFF,$B8DC,$0000,$0000,$DFF0,$00E0,$0000,$0000
	dc.w	$844A,$0000,$7831,$0000,$2194,$0000,$DE63,$0000
	dc.w	$3086,$0000,$CF79,$0000,$4320,$0000,$BCDF,$0000
	dc.w	$3010,$0000,$CFE0,$0000,$FC7B,$7831,$0000,$0000
	dc.w	$FFF7,$DE63,$0000,$0000,$FFFF,$CF79,$0000,$0000
	dc.w	$FFFF,$BCDE,$0000,$0000,$DFE0,$0F00,$0000,$0000
	dc.w	$FC7B,$7831,$0000,$0000,$FFF7,$DE63,$0000,$0000
	dc.w	$FFFF,$CF79,$0000,$0000,$FFFF,$BCDE,$0000,$0000
	dc.w	$1F80,$0F00,$0000,$0000,$ADEA,$7831,$0000,$0000
	dc.w	$ABB6,$DE63,$0000,$0000,$BAAE,$CF79,$0000,$0000
	dc.w	$EBAB,$BCDE,$0000,$0000,$0F00,$0000,$0000,$0000
	dc.w	$864E,$79B1,$0000,$0000,$2194,$DE63,$0000,$0000
	dc.w	$3086,$CF79,$0000,$0000,$4321,$BCDE,$0000,$0000
	dc.w	$D080,$0F00,$0000,$0000,$8040,$7FBF,$0000,$0000
	dc.w	$2194,$DE63,$0000,$0000,$3086,$CF79,$0000,$0000
	dc.w	$4020,$BFDF,$0000,$0000,$3080,$CF00,$0000,$0000
	dc.w	$7FBF,$0000,$0000,$0000,$DE63,$0000,$0000,$0000
	dc.w	$CF79,$0000,$0000,$0000,$BFDF,$0000,$0000,$0000
	dc.w	$CF00,$0000,$0000,$0000



p2cam1: dc.w 3,0,17,15,0,0
	dc.w	$0004,$0004,$0000,$0000,$0508,$0508,$0000,$0000
	dc.w	$020C,$0208,$0000,$0004,$0F1E,$0F1E,$0000,$0000
	dc.w	$0790,$0798,$0000,$0000,$0798,$0798,$0000,$0000
	dc.w	$67DC,$67DC,$0000,$0000,$DFEC,$DFEC,$0000,$0000
	dc.w	$4FFC,$4FFC,$0000,$0000,$0FFC,$0FFC,$0000,$0000
	dc.w	$0CFC,$0DFC,$0000,$0000,$0C90,$0CD8,$0000,$0000
	dc.w	$1C14,$1C14,$0000,$0000,$1A14,$1A14,$0000,$0000
	dc.w	$1416,$1416,$0000,$0000,$1412,$1412,$0000,$0000
	dc.w	$1813,$1813,$0000,$0000,$0618,$0618,$0000,$0000

p2cam2: dc.w 3,0,17,15,0,0
	dc.w	$0002,$0002,$0000,$0000,$0284,$0284,$0000,$0000
	dc.w	$01A6,$01A4,$0000,$0002,$01C7,$01C7,$0000,$0000
	dc.w	$83C4,$83C6,$0000,$0000,$63CE,$63CE,$0000,$0000
	dc.w	$F7EE,$F7EE,$0000,$0000,$9FF6,$9FF6,$0000,$0000
	dc.w	$1FFE,$1FFE,$0000,$0000,$0FFC,$0FFC,$0000,$0000
	dc.w	$0CF8,$0DFC,$0000,$0000,$1C98,$1CD8,$0000,$0000
	dc.w	$1C1A,$1C1A,$0000,$0000,$320A,$320A,$0000,$0000
	dc.w	$240C,$240C,$0000,$0000,$242C,$242C,$0000,$0000
	dc.w	$2424,$2424,$0000,$0000,$3606,$3606,$0000,$0000

p2cam3: dc.w 3,0,17,15,0,0
	dc.w	$0142,$0142,$0000,$0000,$0184,$0184,$0000,$0000
	dc.w	$05C6,$05C4,$0000,$0002,$03CF,$03CF,$0000,$0000
	dc.w	$87CC,$87CE,$0000,$0000,$67EE,$67EE,$0000,$0000
	dc.w	$BFEE,$BFEE,$0000,$0000,$3FFC,$3FFC,$0000,$0000
	dc.w	$1FFC,$1FFC,$0000,$0000,$19F8,$1BF8,$0000,$0000
	dc.w	$1D30,$1DB0,$0000,$0000,$3C30,$3C30,$0000,$0000
	dc.w	$3018,$3018,$0000,$0000,$2408,$2408,$0000,$0000
	dc.w	$260C,$260C,$0000,$0000,$2026,$2026,$0000,$0000
	dc.w	$3030,$3030,$0000,$0000,0,0,0,0

p2cam4: dc.w 3,0,17,15,0,0
	dc.w	$0004,$0004,$0000,$0000,$0008,$0008,$0000,$0000
	dc.w	$024C,$0248,$0000,$0004,$018E,$018E,$0000,$0000
	dc.w	$05C8,$05CC,$0000,$0000,$03DC,$03DC,$0000,$0000
	dc.w	$03DC,$03DC,$0000,$0000,$37EC,$37EC,$0000,$0000
	dc.w	$DFFC,$DFFC,$0000,$0000,$4FFC,$4FFC,$0000,$0000
	dc.w	$0DF0,$0FF8,$0000,$0000,$0C5C,$0CDC,$0000,$0000
	dc.w	$1C3C,$1C3C,$0000,$0000,$1834,$1834,$0000,$0000
	dc.w	$1434,$1434,$0000,$0000,$1434,$1434,$0000,$0000
	dc.w	$1636,$1636,$0000,$0000,$1838,$1838,$0000,$0000

p2cam5: dc.w 3,0,17,15,0,0
	dc.w	$2000,$2000,$0000,$0000,$10A0,$10A0,$0000,$0000
	dc.w	$3040,$1040,$0000,$2000,$78F0,$78F0,$0000,$0000
	dc.w	$09E0,$19E0,$0000,$0000,$19E0,$19E0,$0000,$0000
	dc.w	$3BE6,$3BE6,$0000,$0000,$37FA,$37FA,$0000,$0000
	dc.w	$3FF2,$3FF2,$0000,$0000,$3FF0,$3FF0,$0000,$0000
	dc.w	$3F30,$3FB0,$0000,$0000,$0930,$1B30,$0000,$0000
	dc.w	$2838,$2838,$0000,$0000,$2858,$2858,$0000,$0000
	dc.w	$6828,$6828,$0000,$0000,$4828,$4828,$0000,$0000
	dc.w	$C818,$C818,$0000,$0000,$1860,$1860,$0000,$0000

p2cam6: dc.w 3,0,17,15,0,0
	dc.w	$4000,$4000,$0000,$0000,$2140,$2140,$0000,$0000
	dc.w	$6580,$2580,$0000,$4000,$E380,$E380,$0000,$0000
	dc.w	$23C1,$63C1,$0000,$0000,$73C6,$73C6,$0000,$0000
	dc.w	$77EF,$77EF,$0000,$0000,$6FF9,$6FF9,$0000,$0000
	dc.w	$7FF8,$7FF8,$0000,$0000,$3FF0,$3FF0,$0000,$0000
	dc.w	$1F30,$3FB0,$0000,$0000,$1938,$1B38,$0000,$0000
	dc.w	$5838,$5838,$0000,$0000,$504C,$504C,$0000,$0000
	dc.w	$3024,$3024,$0000,$0000,$3424,$3424,$0000,$0000
	dc.w	$2424,$2424,$0000,$0000,$606C,$606C,$0000,$0000

p2cam7: dc.w 3,0,17,15,0,0
	dc.w	$4280,$4280,$0000,$0000,$2180,$2180,$0000,$0000
	dc.w	$63A0,$23A0,$0000,$4000,$F3C0,$F3C0,$0000,$0000
	dc.w	$33E1,$73E1,$0000,$0000,$77E6,$77E6,$0000,$0000
	dc.w	$77FD,$77FD,$0000,$0000,$3FFC,$3FFC,$0000,$0000
	dc.w	$3FF8,$3FF8,$0000,$0000,$1F98,$1FD8,$0000,$0000
	dc.w	$0CB8,$0DB8,$0000,$0000,$0C3C,$0C3C,$0000,$0000
	dc.w	$180C,$180C,$0000,$0000,$1024,$1024,$0000,$0000
	dc.w	$3064,$3064,$0000,$0000,$6404,$6404,$0000,$0000
	dc.w	$0C0C,$0C0C,$0000,$0000,0,0,0,0

p2cam8: dc.w 3,0,17,15,0,0
	dc.w	$4000,$4000,$0000,$0000,$2000,$2000,$0000,$0000
	dc.w	$6480,$2480,$0000,$4000,$E300,$E300,$0000,$0000
	dc.w	$2740,$6740,$0000,$0000,$7780,$7780,$0000,$0000
	dc.w	$7780,$7780,$0000,$0000,$6FD8,$6FD8,$0000,$0000
	dc.w	$7FF6,$7FF6,$0000,$0000,$7FE4,$7FE4,$0000,$0000
	dc.w	$1F60,$3FE0,$0000,$0000,$7460,$7660,$0000,$0000
	dc.w	$7870,$7870,$0000,$0000,$5830,$5830,$0000,$0000
	dc.w	$5850,$5850,$0000,$0000,$5850,$5850,$0000,$0000
	dc.w	$D8D0,$D8D0,$0000,$0000,$3830,$3830,$0000,$0000

p2cam9: dc.w 3,0,16,6,0,0
	dc.w	$1000,$1000,$0000,$0000,$3800,$3800,$0000,$0000
	dc.w	$3800,$3800,$0000,$0000,$BA00,$BA00,$0000,$0000
	dc.w	$3800,$3800,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$DC00,$DC00,$0000,$0000,$3C00,$3C00,$0000,$0000
	dc.w	$7C00,$7C00,$0000,$0000,$6C00,$7C00,$0000,$0000
	dc.w	$2800,$6C00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000

p2cam10: dc.w 3,0,16,6,0,0
	dc.w	$0800,$0800,$0000,$0000,$1C00,$1C00,$0000,$0000
	dc.w	$1C00,$1C00,$0000,$0000,$5C00,$5C00,$0000,$0000
	dc.w	$3E00,$3E00,$0000,$0000,$2A00,$2A00,$0000,$0000
	dc.w	$6A00,$6A00,$0000,$0000,$6A00,$6A00,$0000,$0000
	dc.w	$7600,$7600,$0000,$0000,$6E00,$7E00,$0000,$0000
	dc.w	$2A00,$6E00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$6600,$6600,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$8C00,$8C00,$0000,$0000
	dc.w	$0600,$0600,$0000,$0000

p2cam11: dc.w 3,0,16,6,0,0
	dc.w	$1000,$1000,$0000,$0000,$3800,$3800,$0000,$0000
	dc.w	$3800,$3800,$0000,$0000,$BA00,$BA00,$0000,$0000
	dc.w	$3800,$3800,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$7600,$7600,$0000,$0000,$7800,$7800,$0000,$0000
	dc.w	$7C00,$7C00,$0000,$0000,$6C00,$7C00,$0000,$0000
	dc.w	$2800,$6C00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000

p2cam12: dc.w 3,0,16,6,0,0
	dc.w	$2000,$2000,$0000,$0000,$7000,$7000,$0000,$0000
	dc.w	$7000,$7000,$0000,$0000,$7400,$7400,$0000,$0000
	dc.w	$F800,$F800,$0000,$0000,$A800,$A800,$0000,$0000
	dc.w	$AC00,$AC00,$0000,$0000,$AC00,$AC00,$0000,$0000
	dc.w	$DC00,$DC00,$0000,$0000,$EC00,$FC00,$0000,$0000
	dc.w	$A800,$EC00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$CC00,$CC00,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$6200,$6200,$0000,$0000
	dc.w	$C000,$C000,$0000,$0000

p2cam13: dc.w 3,0,16,6,0,0
	dc.w	$1000,$1000,$0000,$0000,$3800,$3800,$0000,$0000
	dc.w	$3800,$3800,$0000,$0000,$8200,$8200,$0000,$0000
	dc.w	$7C00,$7C00,$0000,$2800,$3C00,$3C00,$0000,$0000
	dc.w	$4000,$5800,$0000,$0000,$5800,$5800,$0000,$0000
	dc.w	$5800,$5800,$0000,$0000,$6C00,$7C00,$0000,$0000
	dc.w	$2800,$6C00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000

p2cam14: dc.w 3,0,16,6,0,0
	dc.w	$0800,$0800,$0000,$0000,$1C00,$1C00,$0000,$0000
	dc.w	$1C00,$1C00,$0000,$0000,$8000,$8000,$0000,$0000
	dc.w	$7E00,$7E00,$0000,$2800,$3800,$3800,$0000,$0000
	dc.w	$0400,$3400,$0000,$0000,$3600,$3600,$0000,$0000
	dc.w	$3600,$3600,$0000,$0000,$6E00,$7E00,$0000,$0000
	dc.w	$2A00,$6E00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$6600,$6600,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$8C00,$8C00,$0000,$0000
	dc.w	$0600,$0600,$0000,$0000

p2cam15: dc.w 3,0,16,6,0,0
	dc.w	$1000,$1000,$0000,$0000,$3800,$3800,$0000,$0000
	dc.w	$3800,$3800,$0000,$0000,$3800,$3800,$0000,$0000
	dc.w	$0200,$0200,$0000,$0000,$FC00,$FC00,$0000,$2800
	dc.w	$3C00,$3C00,$0000,$0000,$4000,$5800,$0000,$0000
	dc.w	$5800,$5800,$0000,$0000,$6C00,$7C00,$0000,$0000
	dc.w	$2800,$6C00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$C600,$C600,$0000,$0000

p2cam16: dc.w 3,0,16,6,0,0
	dc.w	$2000,$2000,$0000,$0000,$7000,$7000,$0000,$0000
	dc.w	$7000,$7000,$0000,$0000,$0200,$0200,$0000,$0000
	dc.w	$FC00,$FC00,$0000,$2800,$3800,$3800,$0000,$0000
	dc.w	$4000,$5800,$0000,$0000,$D800,$D800,$0000,$0000
	dc.w	$D800,$D800,$0000,$0000,$EC00,$FC00,$0000,$0000
	dc.w	$A800,$EC00,$0000,$0000,$C600,$C600,$0000,$0000
	dc.w	$CC00,$CC00,$0000,$0000,$6C00,$6C00,$0000,$0000
	dc.w	$6C00,$6C00,$0000,$0000,$6200,$6200,$0000,$0000
	dc.w	$C000,$C000,$0000,$0000

PLYR: DC.W 3,1,30,29,0,0
	dc.w	$0000,$0038,$0038,$0038,$0000,$3800,$3800,$3800
	dc.w	$0000,$037E,$037E,$037E,$0000,$FE00,$FE00,$FE00
	dc.w	$0000,$07FF,$07FF,$07FF,$0000,$FF00,$FF00,$FF00
	dc.w	$0000,$1FFF,$1FFF,$1FFF,$0000,$FF00,$FF00,$FF00
	dc.w	$0000,$3FFF,$3FFF,$3FFF,$0000,$FFE0,$FFE0,$FFE0
	dc.w	$0000,$7FFF,$7FFF,$7FFF,$0000,$FFF0,$FFF0,$FFF0
	dc.w	$0000,$7FFF,$7FFF,$7FFF,$0000,$FFF8,$FFF8,$FFF8
	dc.w	$0780,$3FFF,$3FFF,$3FFF,$0780,$FFF8,$FFF8,$FFF8
	dc.w	$0467,$7FFF,$7C7F,$7FFF,$9C80,$FFF0,$FCF0,$FFF0
	dc.w	$033F,$FFFF,$FF3F,$FFFF,$F100,$FFF0,$F1F0,$FFF0
	dc.w	$01FF,$FFFF,$FFFF,$FFFF,$FE00,$FFF8,$FFF8,$FFF8
	dc.w	$003F,$7FFF,$7FEF,$7FFF,$F000,$FFFC,$DFFC,$FFFC
	dc.w	$003F,$7FFF,$7FFF,$7FFF,$F000,$FFFC,$FFFC,$FFFC
	dc.w	$003B,$3FFF,$3FFB,$3FFF,$7000,$FFF8,$7FF8,$FFF8
	dc.w	$003C,$1FFF,$1FFC,$1FFF,$F000,$FFF0,$FFF0,$FFF0
	dc.w	$002C,$3FFF,$3FEC,$3FFF,$D000,$FFC0,$DFC0,$FFC0
	dc.w	$0010,$3FFF,$3FF0,$3FFF,$2000,$FFE0,$3FE0,$FFE0
	dc.w	$000F,$7FFF,$7FFF,$7FFF,$C000,$FFE0,$FFE0,$FFE0
	dc.w	$0000,$3FFF,$3FFF,$3FFF,$0000,$FFE0,$FFE0,$FFE0
	dc.w	$0000,$0FFF,$0FFF,$0FFF,$0000,$FFC0,$FFC0,$FFC0
	dc.w	$0000,$07FF,$07FF,$07FF,$0000,$FF80,$FF80,$FF80
	dc.w	$0000,$01BF,$01BF,$01BF,$0000,$FF00,$FF00,$FF00
	dc.w	$0000,$003F,$003F,$003F,$0000,$DF00,$DF00,$DF00
	dc.w	$0000,$001F,$001F,$001F,$0000,$8600,$8600,$8600
	dc.w	$0000,$0007,$0007,$0007,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0E8E,$0000,$0000,$0000,$AEC0,$0000,$0000,$0000
	dc.w	$0A8A,$0000,$0000,$0000,$A8A0,$0000,$0000,$0000
	dc.w	$0E8E,$0000,$0000,$0000,$ECC0,$0000,$0000,$0000
	dc.w	$088A,$0000,$0000,$0000,$48A0,$0000,$0000,$0000
	dc.w	$08EA,$0000,$0000,$0000,$4EA0,$0000,$0000,$0000

teem: dc.w 3,3,31,53,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$3838,$3838,$3838,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0003,$0003,$0003
	dc.w	$0000,$7EFE,$7EFE,$7EFE,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0007,$0007,$0007
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$0000,$0000,$0000
	dc.w	$0000,$0038,$0038,$0038,$0000,$381F,$381F,$381F
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$0000,$0000,$0000
	dc.w	$0000,$037E,$037E,$037E,$0000,$FE3F,$FE3F,$FE3F
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
	dc.w	$0000,$07FF,$07FF,$07FF,$0000,$FF7F,$FF7F,$FF7F
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$F000,$F000,$F000
	dc.w	$0000,$1FFF,$1FFF,$1FFF,$0000,$FF7F,$FF7F,$FF7F
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$F800,$F800,$F800
	dc.w	$0000,$3FFF,$3FFF,$3FFF,$0007,$FFFF,$FFFF,$FFFF
	dc.w	$8007,$FFFF,$FFFF,$FFFF,$8000,$F800,$F800,$F800
	dc.w	$0000,$7FFF,$7FFF,$7FFF,$0004,$FFFF,$FFFC,$FFFF
	dc.w	$679C,$FFFF,$7FFC,$FFFF,$8000,$F000,$F000,$F000
	dc.w	$0000,$7FFF,$7FFF,$7FFF,$0003,$FFFF,$FFFF,$FFFF
	dc.w	$3FF1,$FFFF,$3FF1,$FFFF,$0000,$F000,$F000,$F000
	dc.w	$0780,$3FFF,$3FFF,$3FFF,$0701,$FFFF,$FFFF,$FFFF
	dc.w	$FFFE,$FFFF,$FFFF,$FFFF,$0000,$F800,$F800,$F800
	dc.w	$0467,$7FFF,$7C7F,$7FFF,$9C80,$FFFF,$FCFF,$FFFF
	dc.w	$3FF0,$FFFF,$EFDF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$033F,$FFFF,$FF3F,$FFFF,$F100,$FFFF,$F1FF,$FFFF
	dc.w	$3FF0,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$01FF,$FFFF,$FFFF,$FFFF,$FE00,$FFFF,$FFFF,$FFFF
	dc.w	$3B70,$FFFF,$FB7F,$FFFF,$0000,$F800,$F800,$F800
	dc.w	$003F,$7FFF,$7FEF,$7FFF,$F000,$FFFF,$DFFF,$FFFF
	dc.w	$3CF0,$FFFF,$FCFF,$FFFF,$0000,$F000,$F000,$F000
	dc.w	$003F,$7FFF,$7FFF,$7FFF,$F000,$FFFF,$FFFF,$FFFF
	dc.w	$2CD0,$FFFF,$ECDF,$FFFF,$0000,$C000,$C000,$C000
	dc.w	$003B,$3FFF,$3FFB,$3FFF,$7000,$FFFF,$7FFF,$FFFF
	dc.w	$1020,$FFFF,$F03F,$FFFF,$0000,$E000,$E000,$E000
	dc.w	$003C,$1FFF,$1FFC,$1FFF,$F000,$FFFF,$FFFF,$FFFF
	dc.w	$0FC0,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
	dc.w	$002C,$3FFF,$3FEC,$3FFF,$D000,$FFFF,$DFFF,$FFFF
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
	dc.w	$0010,$3FFF,$3FF0,$3FFF,$2000,$FFEF,$3FEF,$FFEF
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$C000,$C000,$C000
	dc.w	$000F,$7FFF,$7FFF,$7FFF,$C000,$FFE7,$FFE7,$FFE7
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$8000,$8000,$8000
	dc.w	$0000,$3FFF,$3FFF,$3FFF,$0000,$FFE1,$FFE1,$FFE1
	dc.w	$0000,$BFFF,$BFFF,$BFFF,$0000,$0000,$0000,$0000
	dc.w	$0000,$0FFF,$0FFF,$0FFF,$0000,$FFC0,$FFC0,$FFC0
	dc.w	$0000,$3FDF,$3FDF,$3FDF,$0000,$0000,$0000,$0000
	dc.w	$0000,$07FF,$07FF,$07FF,$0000,$FF80,$FF80,$FF80
	dc.w	$0000,$1F86,$1F86,$1F86,$0000,$0000,$0000,$0000
	dc.w	$0000,$01BF,$01BF,$01BF,$0000,$FF00,$FF00,$FF00
	dc.w	$0000,$0700,$0700,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$003F,$003F,$003F,$0000,$DF00,$DF00,$DF00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$001F,$001F,$001F,$0000,$8600,$8600,$8600
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0007,$0007,$0007,$01DD,$0000,$0000,$0000
	dc.w	$DF00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0091,$0000,$0000,$0000
	dc.w	$5500,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0099,$0000,$0000,$0000
	dc.w	$D500,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0091,$0000,$0000,$0000
	dc.w	$5100,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$009D,$0000,$0000,$0000
	dc.w	$5100,$0000,$0000,$0000,$0000,$0000,$0000,$0000

pldroid: dc.w 3,3,34,51,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0170,$03F0,$0170,$03F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0EFC,$0FFC,$0FFC,$0FFC,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3F3F,$3FBF,$39E7,$3FFF,$0000,$0000,$0000,$0000
	dc.w	$0000,$0038,$0038,$0038,$0000,$3800,$3800,$3800
	dc.w	$7E1F,$7F1F,$61E1,$7FFF,$8000,$C000,$8000,$C000
	dc.w	$0000,$037E,$037E,$037E,$0000,$FE00,$FE00,$FE00
	dc.w	$3E1F,$7E1F,$01E0,$7FFF,$8000,$8000,$8000,$8000
	dc.w	$0000,$07FF,$07FF,$07FF,$0000,$FF00,$FF00,$FF00
	dc.w	$F907,$FF3F,$C7D8,$FFFF,$C000,$C000,$C000,$C000
	dc.w	$0000,$1FFF,$1FFF,$1FFF,$0000,$FF00,$FF00,$FF00
	dc.w	$70A3,$FFFF,$0FBC,$FFFF,$8000,$C000,$0000,$C000
	dc.w	$0000,$3FFF,$3FFF,$3FFF,$0001,$FFE1,$FFE1,$FFE1
	dc.w	$FDFF,$FFFF,$FFFF,$FFFF,$E000,$E000,$E000,$E000
	dc.w	$0000,$7FFF,$7FFF,$7FFF,$0000,$FFF1,$FFF0,$FFF1
	dc.w	$BCFF,$FFFF,$BFFF,$FFFF,$2000,$E000,$2000,$E000
	dc.w	$0000,$7FFF,$7FFF,$7FFF,$0000,$FFF9,$FFF8,$FFF9
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$E000,$0000,$E000
	dc.w	$0780,$3FFF,$3FFF,$3FFF,$0780,$FFF9,$FFF8,$FFF9
	dc.w	$DCF7,$FFFF,$DFF7,$FFFF,$C000,$E000,$C000,$E000
	dc.w	$0467,$7FFF,$7C7F,$7FFF,$9C81,$FFF1,$FCF1,$FFF1
	dc.w	$FA7F,$FFFF,$FFC1,$FFFF,$4000,$E000,$4000,$E000
	dc.w	$033F,$FFFF,$FF3F,$FFFF,$F101,$FFF1,$F1F1,$FFF1
	dc.w	$FFFF,$FFFF,$C001,$FFFF,$2000,$E000,$2000,$E000
	dc.w	$01FF,$FFFF,$FFFF,$FFFF,$FE00,$FFF9,$FFF8,$FFF9
	dc.w	$FFFF,$FFFF,$C001,$FFFF,$0000,$E000,$0000,$E000
	dc.w	$003F,$7FFF,$7FEF,$7FFF,$F001,$FFFD,$DFFD,$FFFD
	dc.w	$7EFF,$FFFF,$7FC1,$FFFF,$A000,$E000,$A000,$E000
	dc.w	$003F,$7FFF,$7FFF,$7FFF,$F001,$FFFD,$FFFD,$FFFD
	dc.w	$FEB5,$FFFF,$C3F5,$FFFF,$C000,$E000,$C000,$E000
	dc.w	$003B,$3FFF,$3FFB,$3FFF,$7001,$FFF9,$7FF9,$FFF9
	dc.w	$BFFF,$FFFF,$8001,$FFFF,$A000,$E000,$A000,$E000
	dc.w	$003C,$1FFF,$1FFC,$1FFF,$F000,$FFF1,$FFF0,$FFF1
	dc.w	$FDFD,$FFFF,$C3FD,$FFFF,$4000,$E000,$4000,$E000
	dc.w	$002C,$3FFF,$3FEC,$3FFF,$D001,$FFC1,$DFC1,$FFC1
	dc.w	$FCFF,$FFFF,$FFFF,$FFFF,$E000,$E000,$E000,$E000
	dc.w	$0010,$3FFF,$3FF0,$3FFF,$2001,$FFE1,$3FE1,$FFE1
	dc.w	$FE77,$FFFF,$FFF6,$FFFF,$C000,$E000,$0000,$E000
	dc.w	$000F,$7FFF,$7FFF,$7FFF,$C000,$FFE1,$FFE0,$FFE1
	dc.w	$BFFD,$FFFF,$BFFC,$FFFF,$E000,$E000,$2000,$E000
	dc.w	$0000,$3FFF,$3FFF,$3FFF,$0001,$FFE1,$FFE1,$FFE1
	dc.w	$F9FB,$FFFF,$FFFA,$FFFF,$A000,$E000,$2000,$E000
	dc.w	$0000,$0FFF,$0FFF,$0FFF,$0000,$FFC0,$FFC0,$FFC0
	dc.w	$7CFF,$FFFF,$7FFE,$FFFF,$C000,$C000,$4000,$C000
	dc.w	$0000,$07FF,$07FF,$07FF,$0000,$FF80,$FF80,$FF80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$01BF,$01BF,$01BF,$0000,$FF00,$FF00,$FF00
	dc.w	$0C00,$0C00,$0C00,$0C00,$0000,$0000,$0000,$0000
	dc.w	$0000,$003F,$003F,$003F,$0000,$DF00,$DF00,$DF00
	dc.w	$1C06,$7C06,$7C06,$7C06,$0000,$0000,$0000,$0000
	dc.w	$0000,$001F,$001F,$001F,$0000,$8600,$8600,$8600
	dc.w	$FE07,$FE07,$FE07,$FE07,$0000,$C000,$C000,$C000
	dc.w	$0000,$0007,$0007,$0007,$0001,$0001,$0001,$0001
	dc.w	$010F,$FF0F,$010F,$FF0F,$E000,$E000,$E000,$E000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0010,$001F,$0010,$001F,$1000,$F000,$1000,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0747,$0000,$0000,$0000,$5760,$0000,$0000,$0000
	dc.w	$199D,$0000,$0000,$0000,$6000,$0000,$0000,$0000
	dc.w	$0545,$0000,$0000,$0000,$5451,$0000,$0000,$0000
	dc.w	$1555,$0000,$0000,$0000,$5000,$0000,$0000,$0000
	dc.w	$0747,$0000,$0000,$0000,$7663,$0000,$0000,$0000
	dc.w	$9595,$0000,$0000,$0000,$5000,$0000,$0000,$0000
	dc.w	$0445,$0000,$0000,$0000,$2451,$0000,$0000,$0000
	dc.w	$1555,$0000,$0000,$0000,$5000,$0000,$0000,$0000
	dc.w	$0475,$0000,$0000,$0000,$2750,$0000,$0000,$0000
	dc.w	$195D,$0000,$0000,$0000,$6000,$0000,$0000,$0000


plone: dc.w 3,0,19,12,0,0
	dc.w	$0070,$0000,$0000,$0000,$01B8,$0070,$0000,$0000
	dc.w	$0668,$01E0,$0010,$0000,$18E8,$07E0,$0010,$0000
	dc.w	$6788,$1F80,$0070,$0000,$98E8,$77E0,$0010,$0000
	dc.w	$78C8,$07C0,$0030,$0000,$09E8,$07E0,$0010,$0000
	dc.w	$09E8,$07E0,$0010,$0000,$09E8,$07E0,$0010,$0000
	dc.w	$09D8,$07D0,$0020,$0000,$08E8,$07E0,$0010,$0000
	dc.w	$09D8,$07D0,$0020,$0000,$08C8,$07C0,$0030,$0000
	dc.w	$08E8,$07E0,$0010,$0000,$08C8,$07C0,$0030,$0000
	dc.w	$09F8,$07F0,$0000,$0000,$09C8,$07C0,$0030,$0000
	dc.w	$08E8,$07E0,$0010,$0000,$07F0,$0000,$0000,$0000

pltwo: dc.w 3,1,19,18,0,0
	dc.w	$03FC,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0C3B,$03F8,$0004,$0000,$0000,$0000,$0000,$0000
	dc.w	$13CF,$0E3F,$0000,$0000,$8000,$0000,$0000,$0000
	dc.w	$2627,$181F,$0000,$0000,$4000,$0000,$8000,$0000
	dc.w	$5813,$300F,$0000,$0000,$2000,$0000,$C000,$0000
	dc.w	$9013,$600F,$0000,$0000,$A000,$8000,$4000,$0000
	dc.w	$9013,$600F,$0000,$0000,$A000,$8000,$4000,$0000
	dc.w	$B023,$601F,$0000,$0000,$A000,$8000,$4000,$0000
	dc.w	$5843,$303F,$0000,$0000,$C000,$8000,$0000,$0000
	dc.w	$308F,$007F,$0000,$0000,$4000,$0000,$8000,$0000
	dc.w	$013F,$00FF,$0000,$0000,$8000,$0000,$0000,$0000
	dc.w	$021C,$01FC,$0003,$0000,$8000,$0000,$0000,$0000
	dc.w	$045B,$03FA,$0004,$0000,$0000,$0000,$0000,$0000
	dc.w	$08F2,$07F0,$000C,$0000,$0000,$0000,$0000,$0000
	dc.w	$1174,$0FF0,$0008,$0000,$0000,$0000,$0000,$0000
	dc.w	$23D8,$1FD0,$0020,$0000,$0000,$0000,$0000,$0000
	dc.w	$47D0,$3FC0,$0020,$0000,$0000,$0000,$0000,$0000
	dc.w	$873F,$7F00,$00C0,$0000,$C000,$0000,$0000,$0000
	dc.w	$03FB,$FFFB,$0004,$0000,$2000,$0000,$C000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$C000,$0000,$0000,$0000

droi1: dc.w 3,0,10,12,0,0
	dc.w	$0000,$0000,$0F80,$0F80,$0000,$0400,$3FE0,$3FE0
	dc.w	$0000,$1000,$7FF0,$7FF0,$0700,$2700,$78F0,$7FF0
	dc.w	$0F80,$0880,$F078,$F8F8,$1FC0,$1040,$E038,$F078
	dc.w	$0F80,$0880,$F078,$F8F8,$0700,$0700,$78F0,$7FF0
	dc.w	$0000,$0000,$7FF0,$7FF0,$0000,$0000,$3FE0,$3FE0
	dc.w	$0000,$0000,$0F80,$0F80
droi2: dc.w 3,0,10,12,0,0
	dc.w	$0000,$0000,$1F00,$1F00,$0000,$0800,$7FC0,$7FC0
	dc.w	$0E00,$2E00,$F1E0,$FFE0,$1F00,$5100,$E0E0,$F1E0
	dc.w	$3F80,$2080,$C070,$E0F0,$3F80,$2080,$C070,$E0F0
	dc.w	$3F80,$2080,$C070,$E0F0,$1F00,$1100,$E0E0,$F1E0
	dc.w	$0E00,$0E00,$F1E0,$FFE0,$0000,$0000,$7FC0,$7FC0
	dc.w	$0000,$0000,$1F00,$1F00
droi3: dc.w 3,0,10,12,0,0
	dc.w	$0000,$0000,$0F80,$0F80,$0300,$0700,$3CE0,$3FE0
	dc.w	$0F80,$1880,$7070,$78F0,$1FC0,$3040,$6030,$7070
	dc.w	$3FE0,$2020,$C018,$E038,$3FE0,$2020,$C018,$E038
	dc.w	$3FE0,$2020,$C018,$E038,$1FC0,$1040,$6030,$7070
	dc.w	$0F80,$0880,$7070,$78F0,$0700,$0700,$38E0,$3FE0
	dc.w	$0000,$0000,$0F80,$0F80

wasp: dc.w 3,1,4,16,0,0
	dc.w	$8BAB,$8BAB,$0000,$8BAB,$8000,$8000,$0000,$8000
	dc.w	$8AAA,$8AAA,$0000,$8AAA,$0000,$0000,$0000,$0000
	dc.w	$ABAB,$ABAB,$0000,$ABAB,$0000,$0000,$0000,$0000
	dc.w	$AAAA,$AAAA,$0000,$AAAA,$0000,$0000,$0000,$0000
	dc.w	$FA93,$FA93,$0000,$FA93,$8000,$8000,$0000,$8000
numbers:

	dc.w	$FE00,$C600,$C600,$CE00,$CE00,$CE00,$CE00,$FE00
	dc.w	$1C00,$1C00,$1C00,$3C00,$3C00,$3C00,$3C00,$3C00
	dc.w	$FE00,$C600,$C600,$0600,$0600,$FE00,$F000,$FE00
	dc.w	$FE00,$CE00,$0E00,$7E00,$0E00,$0E00,$CE00,$FE00

	dc.w	$C600,$C600,$C600,$C600,$FE00,$0E00,$0E00
	dc.w	$0E00



	dc.w	$FE00,$E000,$E000,$FE00,$0E00,$0E00,$CE00,$FE00
	dc.w	$FE00,$C600,$C000,$FE00,$CE00,$CE00,$CE00,$FE00
	dc.w	$FE00,$C600,$0600,$0E00,$0E00,$0E00,$0E00,$0E00
	dc.w	$7E00,$6E00,$6E00,$FE00,$CE00,$CE00,$CE00,$FE00
	dc.w	$FE00,$C600,$C600,$C600,$C600,$FE00,$0E00,$0E00




	dc.w	$FF00,$C700,$C700,$CF00,$CF00,$CF00,$CF00,$FF00
	dc.w	$1C00,$1C00,$1C00,$3C00,$3C00,$3C00,$3C00,$3C00
	dc.w	$FF00,$C700,$C700,$0700,$0700,$FF00,$F000,$FF00
	dc.w	$FE00,$CE00,$0E00,$7F00,$0F00,$0F00,$CF00,$FF00
	dc.w	$FF00,$C700,$C700,$C700,$C700,$FF00,$0F00,$0F00
	dc.w	$FF00,$E000,$E000,$FF00,$0F00,$0F00,$CF00,$FF00
	dc.w	$FF00,$C700,$C000,$FF00,$CF00,$CF00,$CF00,$FF00
	dc.w	$FF00,$C700,$0700,$0F00,$0F00,$0F00,$0F00,$0F00
	dc.w	$7E00,$6E00,$6E00,$FF00,$CF00,$CF00,$CF00,$FF00
	dc.w	$FF00,$C700,$C700,$C700,$C700,$FF00,$0F00,$0F00





	dc.w	$FE00,$C600,$CE00,$D600,$E600,$C600,$FE00,$0000
	dc.w	$7800,$1800
	dc.w	$1800,$1800
	dc.w	$1800,$1800
	dc.w	$7C00,$0000
	dc.w	$FC00,$CC00
	dc.w	$0C00,$FC00
	dc.w	$C000,$C600
	dc.w	$FE00,$0000
	dc.w	$FE00,$C600
	dc.w	$0600,$1E00
	dc.w	$0600,$C600
	dc.w	$FE00,$0000
	dc.w	$E000,$C000
	dc.w	$D800,$FE00
	dc.w	$1800,$1800
	dc.w	$1800,$0000
	dc.w	$FE00,$C000
	dc.w	$C000,$FE00
	dc.w	$0600,$C600
	dc.w	$FE00,$0000
	dc.w	$FE00,$C600
	dc.w	$C000,$FE00
	dc.w	$C600,$C600
	dc.w	$FE00,$0000
	dc.w	$FE00,$C600
	dc.w	$0600,$1E00
	dc.w	$0600,$0600
	dc.w	$0600,$0000
	dc.w	$FE00,$C600
	dc.w	$C600,$FE00
	dc.w	$C600,$C600
	dc.w	$FE00,$0000
	dc.w	$FE00,$C600
	dc.w	$C600,$FE00
	dc.w	$0600,$C600
	dc.w	$FE00,$0000

lli1:	dc.w	$4000,$C000,$4000,$4200,$7D00,$7C00,$4400,$CC00
lli2:	dc.w	$0200,$0300,$0200,$4200,$BE00,$3E00,$2200,$3300

spbone: dc.w 3,1,11,18,0,0
	dc.w	$CEEA,$0000,$0000,$0000,$E000,$0000,$0000,$0000
	dc.w	$AAAA,$0000,$0000,$0000,$8000,$0000,$0000,$0000
	dc.w	$CAAA,$0000,$0000,$0000,$E000,$0000,$0000,$0000
	dc.w	$AAAA,$0000,$0000,$0000,$2000,$0000,$0000,$0000
	dc.w	$CEAE,$0000,$0000,$0000,$E000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0383,$2380,$0038,$0003,$8000,$0000,$0000,$8000
	dc.w	$0282,$2280,$0028,$0002,$8000,$0000,$0000,$8000
	dc.w	$0282,$2280,$0028,$0002,$8000,$0000,$0000,$8000
	dc.w	$0282,$2280,$0028,$0002,$8000,$0000,$0000,$8000
	dc.w	$0383,$2B80,$0038,$0003,$8000,$0000,$0000,$8000
	dc.w	$0000,$1000,$0000,$0000,$0000,$0000,$0000,$0000

coolc1: dc.w 3,5,84,88,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0006,$0000,$0006
	dc.w	$0000,$0300,$0000,$0300,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0018,$0000,$0018,$0000,$000E,$0000,$000E
	dc.w	$0000,$0600,$0000,$0600,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0018,$0000,$0018,$0000,$060C,$0000,$060C
	dc.w	$0000,$1E00,$0000,$1E00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$001C,$0000,$001C,$0000,$061C,$0008,$0614
	dc.w	$0000,$3C02,$0800,$3402,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$201C,$0000,$201C,$0000,$0E3C,$0010,$0E2C
	dc.w	$0000,$7C0E,$1800,$640E,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$301E,$0004,$301A,$0000,$1E7C,$0410,$1A6C
	dc.w	$0000,$FC3E,$3000,$CC3E,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$1C1F,$0004,$1C1B,$0000,$1EF9,$0C30,$12C9
	dc.w	$0000,$F8FC,$7010,$88EC,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$1E0F,$0006,$1E09,$0000,$3FFB,$0C70,$338B
	dc.w	$0000,$FBF8,$E060,$1B98,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0F8F,$0206,$0D89,$0000,$BFFF,$1CF3,$A30C
	dc.w	$0000,$FFF0,$E1E0,$1E10,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$07CF,$0307,$04C8,$0000,$FFFF,$1FE7,$E018
	dc.w	$0000,$FFE0,$E7C0,$1820,$0000,$7800,$0000,$7800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$03EF,$01C7,$0228,$0000,$FFFF,$3FFF,$C000
	dc.w	$0000,$FFCF,$FF80,$004F,$0000,$F000,$0000,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$03FF,$00E7,$0318,$0000,$FFFF,$BE00,$41FF
	dc.w	$0000,$FFFF,$1F03,$E0FC,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$01FF,$00F7,$0108,$003F,$FFFF,$E000,$1FC0
	dc.w	$0000,$FFFF,$073C,$F8C3,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FF,$007F,$0080,$07FF,$FFFF,$0000,$F800
	dc.w	$F000,$FFFE,$03F8,$0C06,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FF,$003C,$00C3,$7FFF,$FFFF,$0000,$8000
	dc.w	$F800,$FFF8,$01E0,$0618,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0001,$007F,$0000,$007E,$FFFF,$FFFF,$0000,$0000
	dc.w	$FC00,$FFF0,$01C0,$0230,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001F,$07FF,$0000,$07E0,$FF83,$FFFF,$0000,$007C
	dc.w	$FE00,$FFC0,$0000,$01C0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0003,$0000,$0003
	dc.w	$003F,$FFFF,$0000,$FFC0,$F008,$FFF7,$0000,$0FF7
	dc.w	$FE00,$FF80,$0000,$0180,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00FF,$0000,$00FF
	dc.w	$7DFE,$83FF,$0000,$8201,$01F0,$FE0F,$0000,$FE0F
	dc.w	$3F00,$FF80,$0000,$C080,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$01FF,$0000,$01FF
	dc.w	$00C0,$FFFF,$0000,$FF3F,$3FC7,$C03F,$0000,$C038
	dc.w	$BC00,$FFFF,$0000,$43FF,$0000,$FF00,$0000,$FF00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0100,$0000,$0100
	dc.w	$0007,$3FF8,$0000,$3FF8,$FF10,$00FF,$0000,$00EF
	dc.w	$003F,$FFFF,$0000,$FFC0,$FA00,$FF80,$0000,$0580
	dc.w	$0000,$0000,$0000,$0000,$0000,$0120,$0020,$0120
	dc.w	$001F,$0020,$0000,$0020,$FC7F,$03FF,$0000,$0380
	dc.w	$9FE0,$FFFF,$0000,$601F,$3F00,$FF80,$0000,$C080
	dc.w	$0000,$0000,$0000,$0000,$0000,$0140,$0040,$0140
	dc.w	$001F,$4020,$0000,$4020,$F1FF,$0FFF,$0000,$0E00
	dc.w	$8000,$FFFF,$0000,$7FFF,$3E00,$FF80,$0000,$C180
	dc.w	$0000,$0000,$0000,$0000,$0000,$0303,$0000,$0303
	dc.w	$000F,$E130,$0100,$E130,$C7F8,$3FFF,$0000,$3807
	dc.w	$07FF,$FFFF,$0000,$F800,$FE00,$FF00,$0000,$0100
	dc.w	$0000,$0000,$0000,$0000,$0000,$033F,$0000,$033F
	dc.w	$400F,$E210,$0200,$A210,$1FFB,$FFFF,$0000,$E004
	dc.w	$EFFF,$FFFF,$0000,$1000,$FC00,$FF00,$0000,$0300
	dc.w	$0000,$0000,$0000,$0000,$000F,$0FFF,$0000,$0FF0
	dc.w	$C004,$F01B,$0000,$301B,$7FFB,$FFFF,$0000,$8004
	dc.w	$CFFF,$FFFF,$0000,$3000,$E000,$FE00,$0000,$1E00
	dc.w	$0000,$0003,$0000,$0003,$00FF,$FFFF,$0000,$FF00
	dc.w	$E001,$F00F,$0000,$100E,$FFF9,$FFFF,$0000,$0006
	dc.w	$FFFE,$FFFF,$0000,$0001,$0000,$F800,$0000,$F800
	dc.w	$0000,$001F,$0000,$001F,$3FFF,$FFFF,$0000,$C000
	dc.w	$E000,$F85F,$0000,$185F,$FFFC,$FFFF,$0000,$0003
	dc.w	$FFC0,$FFFF,$0000,$003F,$0000,$C000,$0000,$C000
	dc.w	$000F,$007F,$0000,$0070,$FFFF,$FFFF,$0000,$0000
	dc.w	$F01A,$FBFF,$0000,$0BE5,$1FFE,$FFFF,$0000,$E001
	dc.w	$0000,$FFF8,$0000,$FFF8,$0000,$0000,$0000,$0000
	dc.w	$003F,$00FF,$0000,$00C0,$FFFF,$FFFF,$0000,$0000
	dc.w	$F8FF,$FFFF,$0000,$0700,$87FF,$FFFF,$0000,$7800
	dc.w	$E000,$FF80,$0000,$1F80,$0000,$0000,$0000,$0000
	dc.w	$007F,$00FF,$0000,$0080,$FFFF,$FFFF,$0000,$0000
	dc.w	$F7FF,$FFFF,$0000,$0800,$E3FF,$FFFF,$0000,$1C00
	dc.w	$FF80,$FFC0,$0000,$0040,$0000,$0000,$0000,$0000
	dc.w	$007F,$00FF,$0000,$0080,$FE7F,$FFFF,$0000,$0180
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF80,$FFE0,$0000,$0060,$0000,$0000,$0000,$0000
	dc.w	$007F,$00FF,$0000,$0080,$0F3F,$FFFF,$0000,$F0C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFC0,$FFF0,$0000,$0030,$0000,$0000,$0000,$0000
	dc.w	$0000,$01FF,$0000,$01FF,$079F,$FFFF,$0000,$F860
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFC0,$FFF0,$0000,$0030,$0000,$0000,$0000,$0000
	dc.w	$0183,$03FF,$0000,$027C,$C79F,$FFFF,$0000,$3860
	dc.w	$FFE0,$FFFF,$0000,$001F,$3FFF,$FFFF,$0000,$C000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$013F,$07FF,$0000,$06C0,$CF3F,$FFFF,$0000,$30C0
	dc.w	$FFC6,$FFFF,$0000,$0039,$0FFF,$FFFF,$0000,$F000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$027F,$0FFF,$0000,$0D80,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFE,$FFFF,$0000,$0001,$E7F0,$FFFF,$0000,$180F
	dc.w	$0180,$FFF0,$0000,$FE70,$0000,$0000,$0000,$0000
	dc.w	$04FF,$1FFF,$0000,$1B00,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$FFE1,$FFFF,$0000,$001E
	dc.w	$FC80,$FFF0,$0000,$0370,$0000,$0000,$0000,$0000
	dc.w	$0DFF,$1FFF,$0000,$1200,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFD,$FFFF,$0000,$0002,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFC0,$FFE0,$0000,$0020,$0000,$0000,$0000,$0000
	dc.w	$09FF,$1FFF,$0000,$1600,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFD,$FFFF,$0000,$0002,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$19FF,$3FFF,$0000,$2600,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF9,$FFFF,$0000,$0006,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0000,$0000,$0000,$0000
	dc.w	$1BFF,$3FFF,$0000,$2400,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF3,$FFFF,$0000,$000C,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF0,$FFF8,$0000,$0008,$0000,$0000,$0000,$0000
	dc.w	$1BFF,$3FFF,$0000,$2400,$FFFF,$FFFF,$0000,$0000
	dc.w	$E007,$FFFF,$0000,$1FF8,$FC3F,$FFFF,$0000,$03C0
	dc.w	$FFF0,$FFFC,$0000,$000C,$0000,$0000,$0000,$0000
	dc.w	$1BFF,$3FFF,$0000,$2400,$FFFF,$FFFF,$0000,$0000
	dc.w	$000F,$FFFF,$0000,$FFF0,$C01F,$FFFF,$0000,$3FE0
	dc.w	$FFF0,$FFFC,$0000,$000C,$0000,$0000,$0000,$0000
	dc.w	$08FF,$3FFF,$0000,$3700,$FFFC,$FFFF,$0000,$0003
	dc.w	$7FFF,$FFFF,$0000,$8000,$8FFF,$FFFF,$0000,$7000
	dc.w	$FFF0,$FFFC,$0000,$000C,$0000,$0000,$0000,$0000
	dc.w	$0003,$3FFF,$0000,$3FFC,$FFE1,$FFFF,$0000,$001E
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF0,$FFFC,$0000,$000C,$0000,$0000,$0000,$0000
	dc.w	$03F0,$1FFF,$0000,$1C0F,$3E0F,$FFFF,$0000,$C1F0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFFC,$0000,$001C,$0000,$0000,$0000,$0000
	dc.w	$0FFE,$7FFF,$0000,$7001,$007F,$FFFF,$0000,$FF80
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$3FFF,$7FFF,$0000,$4000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$3FFF,$FFFF,$0000,$C000
	dc.w	$FFF0,$FFF8,$0000,$0008,$0000,$0000,$0000,$0000
	dc.w	$3FFF,$FFFF,$0000,$C000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF0,$FFFF,$0000,$000F,$3FFF,$FFFF,$0000,$C000
	dc.w	$FFF0,$FFFC,$0000,$000C,$0000,$0000,$0000,$0000
	dc.w	$3FFF,$FFFF,$0000,$C000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE7,$FFFF,$0000,$0018,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF8,$FFFE,$0000,$0006,$0000,$0000,$0000,$0000
	dc.w	$3C07,$FFFF,$0000,$C3F8,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFCF,$FFFF,$0000,$0030,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFE,$0000,$0002,$0000,$0000,$0000,$0000
	dc.w	$007F,$7FFF,$0000,$7F80,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFDF,$FFFF,$0000,$0020,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFE,$0000,$0002,$0000,$0000,$0000,$0000
	dc.w	$003F,$38FF,$0000,$38C0,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$0000,$0000,$0000,$0000
	dc.w	$003F,$007F,$0000,$0040,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$0000,$0000,$0000,$0000
	dc.w	$000F,$007F,$0000,$0070,$FC07,$FFFF,$0000,$03F8
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$0000,$0000,$0000,$0000
	dc.w	$0003,$003F,$0000,$003C,$8023,$FFFF,$0000,$7FDC
	dc.w	$FFDF,$FFFF,$0000,$0020,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF0,$FFFF,$0000,$000F,$0000,$0000,$0000,$0000
	dc.w	$0000,$000F,$0000,$000F,$00FB,$F3FF,$0000,$F304
	dc.w	$FFBF,$FFFF,$0000,$0040,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF8,$FFFE,$0000,$0006,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FF7F,$FFFF,$0000,$0080,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$03FF,$07FF,$0000,$0400
	dc.w	$FE7F,$FFFF,$0000,$0180,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFE,$FFFF,$0000,$0001,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FEFF,$FFFF,$0000,$0100,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FEFF,$FFFF,$0000,$0100,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$013F,$03FF,$0000,$02C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$007F,$03FF,$0000,$0380
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFC,$FFFF,$0000,$0003,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$00FF,$01FF,$0000,$0100
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$8000,$E000,$0000,$6000
	dc.w	$0000,$0000,$0000,$0000,$00FF,$01FF,$0000,$0100
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$C000,$E000,$0000,$2000
	dc.w	$0000,$0000,$0000,$0000,$00FF,$01FF,$0000,$0100
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$C000,$F000,$0000,$3000
	dc.w	$0000,$0000,$0000,$0000,$00FF,$01FF,$0000,$0100
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$E000,$F000,$0000,$1000
	dc.w	$0000,$0000,$0000,$0000,$007F,$01FF,$0000,$0180
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$E000,$F800,$0000,$1800
	dc.w	$0000,$0000,$0000,$0000,$007F,$01FF,$0000,$0180
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$E000,$F800,$0000,$1800
	dc.w	$0000,$0000,$0000,$0000,$0067,$00FF,$0000,$0098
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$E000,$F800,$0000,$1800
	dc.w	$0000,$0000,$0000,$0000,$000F,$00FF,$0000,$00F0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$E000,$F800,$0000,$1800
	dc.w	$0000,$0000,$0000,$0000,$001F,$007F,$0000,$0060
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F000,$F800,$0000,$0800
	dc.w	$0000,$0000,$0000,$0000,$003F,$007F,$0000,$0040
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$8000,$F800,$0000,$7800
	dc.w	$0000,$0000,$0000,$0000,$003F,$00FF,$0000,$00C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F000,$FC00,$0000,$0C00
	dc.w	$0000,$0000,$0000,$0000,$003F,$00FF,$0000,$00C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F800,$FC00,$0000,$0400
	dc.w	$0000,$0000,$0000,$0000,$003F,$00FF,$0000,$00C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F800,$FC00,$0000,$0400
	dc.w	$0000,$0000,$0000,$0000,$003F,$00FF,$0000,$00C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F800,$FE00,$0000,$0600
	dc.w	$0000,$0000,$0000,$0000,$003F,$00FF,$0000,$00C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FC00,$FE00,$0000,$0200
	dc.w	$0000,$0000,$0000,$0000,$003F,$007F,$0000,$0040
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FC00,$FE00,$0000,$0200
	dc.w	$0000,$0000,$0000,$0000,$001F,$007F,$0000,$0060
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FC00,$FE00,$0000,$0200
	dc.w	$0000,$0000,$0000,$0000,$001F,$003F,$0000,$0020
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FC00,$FF00,$0000,$0300

coolc2: dc.w 3,6,85,96,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0003,$0000,$0003,$0000,$FE00,$0000,$FE00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$001F,$0000,$001F
	dc.w	$0000,$FFFF,$0000,$FEFF,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$00F8,$0000,$00E7,$FEFF,$0100,$0000,$FEFF
	dc.w	$0000,$F000,$0000,$F000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0067,$0F98,$0000,$0FE7
	dc.w	$FCFF,$0300,$0000,$FCFF,$E000,$1E00,$0000,$FE00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$03F7,$3C08,$0000,$3FF7,$FDFF,$0200,$0000,$FDFF
	dc.w	$E400,$1BC0,$0000,$E7C0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0FF7,$F008,$0000,$EFF7
	dc.w	$F9FF,$0600,$0000,$F9FF,$CF00,$30F0,$0000,$CFF0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0003,$0000,$0003
	dc.w	$67F7,$9808,$0000,$E7F7,$F9FF,$0600,$0000,$F9FF
	dc.w	$9FE0,$601C,$0000,$9FFC,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0001,$0006,$0000,$0007,$F7F3,$080C,$0000,$F7F3
	dc.w	$FBFF,$0400,$0000,$FBFF,$3FC0,$C038,$0000,$3FF8
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0003,$001C,$0000,$001F
	dc.w	$FBF3,$040C,$0000,$FBF3,$F3FE,$0C01,$0000,$F3FE
	dc.w	$7F00,$80E0,$0000,$7FE0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$000F,$0030,$0000,$003F,$F9F0,$060F,$0000,$F9FF
	dc.w	$F7FD,$0802,$0000,$F7FD,$FC00,$0380,$0000,$FF80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$0078,$0000,$0067
	dc.w	$FC00,$03FF,$0000,$FDFF,$01FB,$FE04,$0000,$F7FB
	dc.w	$F800,$0600,$0000,$FE00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0071,$018E,$0000,$01F1,$E0FF,$1FFF,$0000,$FF00
	dc.w	$E0B7,$FF48,$0000,$1FF7,$E000,$1C00,$0000,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$00FC,$0303,$0000,$03FC
	dc.w	$0FFF,$FFFF,$0000,$F000,$FF07,$FFF8,$0000,$00FF
	dc.w	$8000,$7000,$0000,$F000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01FC,$0603,$0000,$07FF,$7FFF,$FFFF,$0000,$8000
	dc.w	$FFF0,$FFFF,$0000,$000F,$0000,$C000,$0000,$C000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$03F0,$040F,$0000,$07FF
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFC,$FFFF,$0000,$0003
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0067,$0F9F,$0000,$0FF8,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFE,$FFFF,$0000,$0001,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$000F,$03FF,$0000,$03F0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$0000,$C000,$0000,$C000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001F,$003F,$0000,$0020,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$80FC,$E600,$0000,$6600
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$003F,$007F,$0000,$0040
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFF8,$FFFF,$0000,$0007
	dc.w	$01FE,$FE00,$0000,$FE00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0001,$0000,$0001
	dc.w	$0038,$C07F,$0000,$C047,$0FFF,$FFFF,$0000,$F000
	dc.w	$FFE0,$FE1F,$0000,$001F,$01FE,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$001F,$0000,$001F,$0033,$FFFF,$0000,$FFCC
	dc.w	$001F,$FFFF,$0000,$FFE0,$FFF0,$FC00,$0000,$0000
	dc.w	$01FF,$FE00,$0000,$FE00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$000F,$00FF,$0000,$00F0
	dc.w	$F800,$FFFF,$0000,$07FF,$7000,$FFFF,$0000,$8CFF
	dc.w	$3FF8,$F807,$0000,$C007,$03FF,$F000,$0000,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$007F,$03FF,$0000,$0380,$FFFC,$FFFF,$0000,$0003
	dc.w	$7C00,$FFFF,$0000,$8381,$07FF,$F803,$0000,$F800
	dc.w	$83FF,$E000,$0000,$6000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01F0,$3FFF,$0000,$3E0F
	dc.w	$01FF,$FFFF,$0000,$FE00,$FF00,$FFFF,$0000,$00E0
	dc.w	$0FFF,$F003,$0000,$0000,$C3FF,$F800,$0000,$3800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$07C3,$FFFF,$0000,$F83C,$C007,$FFFF,$0000,$3FF8
	dc.w	$FFC0,$FFFF,$0000,$0038,$0FFF,$F003,$0000,$0000
	dc.w	$F1FF,$FE00,$0000,$0E00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$03FF,$07FF,$0000,$0400
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFF0,$FFFF,$0000,$000F
	dc.w	$0FFF,$F003,$0000,$0000,$FC7F,$FF80,$0000,$0380
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01F1,$03F1,$0006,$0200,$FFF8,$FFFF,$0000,$0007
	dc.w	$3FFC,$FFFF,$0000,$C003,$0FFF,$F003,$0000,$C000
	dc.w	$FF07,$FFF8,$0000,$00F8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0070,$01F0,$0007,$0180
	dc.w	$FFE1,$FFFF,$0000,$001E,$FFFF,$FFFF,$0000,$0000
	dc.w	$0FFF,$F003,$0000,$F000,$FFE0,$FFFF,$0000,$001F
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$000E,$00FE,$0001,$00F0,$FE07,$FFFF,$0000,$01F8
	dc.w	$FFFF,$FFFF,$0000,$0000,$CFFF,$F003,$0000,$3000
	dc.w	$FFFE,$FFFF,$0000,$0001,$0000,$E000,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$0000,$003E,$0001,$003E
	dc.w	$007F,$FFFF,$0000,$FF80,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$F003,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$8000,$FC00,$0000,$7C00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0002,$0021,$0002,$00FF,$F3FF,$0000,$F300
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$F807,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F000,$FF00,$0000,$0F00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0021,$0000
	dc.w	$00FF,$03FF,$0000,$0300,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FC0F,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FE00,$FF80,$0000,$0180,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0021,$0000,$003F,$03FF,$0000,$03C0
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FF1F,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF80,$FFC0,$0000,$0040
	dc.w	$0000,$0000,$0000,$0000,$0008,$0008,$0021,$0000
	dc.w	$003F,$03FF,$0000,$03C0,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFC0,$FFE0,$0000,$0020,$0000,$0000,$0000,$0000
	dc.w	$0008,$000C,$0033,$0000,$01FF,$07FF,$0000,$0600
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF8F,$FFFF,$0000,$0070,$FFC0,$FFF0,$0000,$0030
	dc.w	$0000,$0000,$0000,$0000,$0008,$000C,$0012,$0000
	dc.w	$03FF,$0FFF,$0000,$0C00,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF3F,$FFFF,$0000,$00C0
	dc.w	$FFC0,$FFF0,$0000,$0030,$0000,$0000,$0000,$0000
	dc.w	$0008,$0008,$0000,$0000,$87FF,$8FFF,$0000,$0800
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FE78,$FFFF,$0000,$0187,$1D80,$FFF8,$0000,$E278
	dc.w	$0000,$0000,$0000,$0000,$0004,$0004,$0018,$0000
	dc.w	$C7FF,$CFFF,$0000,$0800,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FE70,$FFFE,$0000,$018E
	dc.w	$0400,$1FCC,$0000,$1BCC,$0000,$0000,$0000,$0000
	dc.w	$001E,$001E,$0021,$0000,$87FF,$8FFF,$0000,$0800
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF30,$FFFF,$0000,$00CF,$0600,$EF8C,$0000,$E98C
	dc.w	$0000,$0000,$0000,$0000,$003F,$003F,$0040,$0000
	dc.w	$07FF,$0FFF,$0000,$0800,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF3F,$FFFF,$0000,$00C0,$FFBF,$FFFF,$0000,$0040
	dc.w	$C200,$FFFC,$0000,$3DFC,$0000,$0000,$0000,$0000
	dc.w	$0022,$0022,$0000,$0000,$03FF,$1FFF,$0000,$1C00
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF3B,$FFFF,$0000,$00C4
	dc.w	$FFFF,$FFFF,$0000,$0000,$F218,$FFFF,$0000,$0DE7
	dc.w	$0000,$0000,$0000,$0000,$0022,$0022,$0000,$0000
	dc.w	$03FF,$3FFF,$0000,$3C00,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF3B,$FFFF,$0000,$00C4,$FFFF,$FFFF,$0000,$0000
	dc.w	$FA7C,$FFFF,$0000,$0583,$0000,$0000,$0000,$0000
	dc.w	$0011,$0011,$0022,$0000,$1FFF,$7FFF,$0000,$6000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF38,$FFFF,$0000,$00C7
	dc.w	$1FFF,$FFFF,$0000,$E000,$FCFE,$FFFF,$0000,$0301
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$1FFF,$7FFF,$0000,$6000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF39,$FFFF,$0000,$00C6,$C3FF,$FFFF,$0000,$3C00
	dc.w	$FE7E,$FFFF,$0000,$0181,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1FFF,$7FFF,$0000,$6000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFBC,$FFFF,$0000,$0043
	dc.w	$71FF,$FFFF,$0000,$8E00,$FE7E,$FFFF,$0000,$0181
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$1FFF,$7FFF,$0000,$6000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF9F,$FFFF,$0000,$0060,$783F,$FFFF,$0000,$87C0
	dc.w	$FF7E,$FFFF,$0000,$0081,$0000,$8000,$0000,$8000
	dc.w	$0000,$0000,$0000,$0000,$1FFF,$7FFF,$0000,$6000
	dc.w	$FFFF,$FFFF,$0000,$0000,$87C3,$FFFF,$0000,$783C
	dc.w	$FF0F,$FFFF,$0000,$00F0,$FF3C,$FFFF,$0000,$00C3
	dc.w	$0000,$8000,$0000,$8000,$0000,$0000,$0000,$0000
	dc.w	$17FF,$3FFF,$0000,$2800,$FFFF,$FFFF,$0000,$0000
	dc.w	$E0F1,$FFFF,$0000,$1F0E,$FFE3,$FFFF,$0000,$001C
	dc.w	$C102,$FFFF,$0000,$3EFD,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$07FF,$3FFF,$0000,$3800
	dc.w	$FFFF,$FFFF,$0000,$0000,$FC1F,$FFFF,$0000,$03E0
	dc.w	$FFF8,$FFFF,$0000,$0007,$1E0C,$FFFF,$0000,$E1F3
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$1FFF,$7FFF,$0000,$6000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF80,$FFFF,$0000,$007F,$1FFC,$FFFF,$0000,$E003
	dc.w	$7FFC,$FFFE,$0000,$8002,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$3FFF,$FFFF,$0000,$C000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFC0,$FFFF,$0000,$003F
	dc.w	$03C7,$FFFF,$0000,$FC38,$C1C0,$FFFE,$0000,$3E3E
	dc.w	$0000,$0000,$0000,$0000,$0000,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$8000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0030,$07FF,$0000,$07CF
	dc.w	$0008,$FFFE,$0000,$FFF6,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0000,$0001,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0008,$01FF,$0000,$01F7,$7FF0,$FFFC,$0000,$800C
	dc.w	$0000,$0000,$0000,$0000,$0000,$0001,$0000,$0001
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0003,$001F,$0000,$001C
	dc.w	$FC00,$FFF8,$0000,$03F8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0000,$0001,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0000,$0007,$0000,$0007,$0000,$FFE0,$0000,$FFE0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0001,$0000,$0001
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0000,$0001,$0000,$0001
	dc.w	$0000,$F800,$0000,$F800,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0000,$0001,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF20,$FFF0,$0000,$00D0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0001,$0000,$0001
	dc.w	$1FFF,$FFFF,$0000,$E000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF80,$FFF0,$0000,$0070,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0000,$0001,$7FFF,$FFFF,$0000,$8000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFC0,$FFE0,$0000,$0020
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0001,$0003,$0000,$0002
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$0007,$0000,$0004,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0003,$0007,$0000,$0004
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$0007,$0000,$0004,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0003,$0007,$0000,$0004
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$0007,$0000,$0004,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0001,$0007,$0000,$0006
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF20,$FFF0,$0000,$00D0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0001,$0003,$0000,$0002,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF80,$FFE0,$0000,$0060
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0001,$0003,$0000,$0002
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0003,$0000,$0003,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0003,$0000,$0003
	dc.w	$BFFF,$FFFF,$0000,$4000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0000,$0001,$3FFF,$FFFF,$0000,$C000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFF0,$FFF8,$0000,$0008
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0003,$0000,$0003
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF0,$FFF8,$0000,$0008,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$0007,$0000,$0004,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFF0,$FFF8,$0000,$0008
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0003,$000F,$0000,$000C
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFF0,$FFF8,$0000,$0008,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$000F,$0000,$0008,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFF0,$FFF8,$0000,$0008
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$001F,$0000,$0018
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF20,$FFF8,$0000,$00D8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$001F,$0000,$0018,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF00,$FFF0,$0000,$00F0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$001F,$0000,$0018
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFC0,$FFF0,$0000,$0030,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$001F,$0000,$0018,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF0,$0000,$0010
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$001F,$0000,$0018
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF8,$0000,$0018,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$001F,$0000,$0018,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFF8,$0000,$0018
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$001F,$0000,$0018
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFE0,$FFF0,$0000,$0010,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$001F,$0000,$0018,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFC0,$FFF0,$0000,$0030
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$000F,$0000,$0008
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFC0,$FFE0,$0000,$0020,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$000F,$0000,$0008,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF80,$FFC0,$0000,$0040
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$000F,$0000,$0008
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FF00,$FF80,$0000,$0080,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$000F,$000F,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF00,$FF00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000


robo1: dc.w 3,0,11,15,0,0
	dc.w	$0280,$03C0,$0380,$03C0,$02C0,$0180,$0180,$0180
	dc.w	$0280,$03C0,$0380,$03C0,$05F0,$1FF8,$1FF0,$1FF8
	dc.w	$0DF0,$1FF8,$1FF0,$1FF8,$0190,$1BD8,$1390,$1BD8
	dc.w	$0180,$1BC8,$1380,$1BC8,$0180,$13C0,$1380,$13C0
	dc.w	$03C0,$07E0,$07C0,$07E0,$0240,$0660,$0640,$0660
	dc.w	$0270,$0678,$0670,$0678,$0E00,$1E00,$1E00,$1E00



robo2: dc.w 3,0,11,15,0,0
	dc.w	$0280,$03C0,$0380,$03C0,$02C0,$0180,$0180,$0180
	dc.w	$0280,$03C0,$0380,$03C0,$05F0,$1FF8,$1FF0,$1FF8
	dc.w	$0DF0,$1FF8,$1FF0,$1FF8,$0190,$1BD8,$1390,$1BD8
	dc.w	$0190,$13D8,$1390,$13D8,$0180,$03C8,$0380,$03C8
	dc.w	$03C0,$07E0,$07C0,$07E0,$0240,$0660,$0640,$0660
	dc.w	$0E40,$1E60,$1E40,$1E60,$0070,$0078,$0070,$0078

jst1: dc.w 3,0,12,15,0,0
	dc.w	$0000,$0700,$0000,$0700,$0600,$0F80,$0600,$0F80
	dc.w	$0800,$1FC0,$0B80,$1FC0,$0B00,$1FC0,$0C80,$1FC0
	dc.w	$0000,$1FC0,$0700,$1FC0,$0000,$0F80,$0000,$0F80
	dc.w	$0400,$0700,$0400,$0700,$0200,$0380,$0200,$0380
	dc.w	$0200,$039C,$0200,$0380,$0000,$0000,$0000,$0000
	dc.w	$3800,$7FFE,$3800,$7FFE,$4000,$FFFF,$4000,$FFFF
	dc.w	$0000,$7FFE,$0000,$7FFE
jst2: dc.w 3,0,12,15,0,0
	dc.w	$0000,$01C0,$0000,$01C0,$0180,$03E0,$0180,$03E0
	dc.w	$0200,$07F0,$0270,$07F0,$0260,$07F0,$0290,$07F0
	dc.w	$0000,$07F0,$00F0,$07F0,$0000,$03E0,$0060,$03E0
	dc.w	$0100,$01C0,$0100,$01C0,$0200,$0380,$0200,$0380
	dc.w	$0200,$7380,$0200,$0380,$0000,$0000,$0000,$0000
	dc.w	$3800,$7FFE,$3800,$7FFE,$4000,$FFFF,$4000,$FFFF
	dc.w	$0000,$7FFE,$0000,$7FFE
inv1: dc.w 3,0,10,15,0,0
	dc.w	$0180,$07E0,$0780,$07E0,$1FF8,$3FFC,$3FF8,$3FFC
	dc.w	$2006,$FFFF,$FFFE,$FFFF,$6006,$F18F,$F086,$F18F
	dc.w	$6086,$FFFF,$F086,$FFFF,$7FFE,$FFFF,$FFFE,$FFFF
	dc.w	$0420,$0C30,$0C20,$0C30,$07E0,$0FF0,$0FE0,$0FF0
	dc.w	$1188,$33CC,$3388,$33CC,$4422,$CC33,$CC22,$CC33
	dc.w	$2244,$6666,$6644,$6666
inv2: dc.w 3,0,9,15,0,0
	dc.w	$00C0,$07E0,$07C0,$07E0,$1FF8,$3FFC,$3FF8,$3FFC
	dc.w	$2006,$FFFF,$FFFE,$FFFF,$6E76,$F18F,$F086,$F18F
	dc.w	$6006,$FFFF,$F086,$FFFF,$7FFE,$FFFF,$FFFE,$FFFF
	dc.w	$07C0,$0FF0,$0FC0,$0FF0,$1188,$33CC,$3388,$33CC
	dc.w	$4002,$C003,$C002,$C003,$1008,$300C,$3008,$300C
brg1: dc.w 3,0,9,15,0,0
	dc.w	$0B00,$0F00,$0000,$0000,$1EE0,$3FE0,$0000,$0000
	dc.w	$7FA0,$7FF0,$0000,$0000,$7FF0,$7FF0,$0000,$0000
	dc.w	$0000,$FFE8,$EAE8,$0000,$2540,$5AA0,$2540,$0000
	dc.w	$4A60,$3580,$4A60,$0000,$7FF0,$7FF0,$0000,$0000
	dc.w	$7FF0,$7FF0,$0000,$0000,$3FE0,$3FE0,$0000,$0000
brg2: dc.w 3,0,11,15,0,0
	dc.w	$0680,$0780,$0000,$0000,$3BC0,$3FE0,$0000,$0000
	dc.w	$2FF0,$7FF0,$0000,$0000,$7FF0,$7FF0,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$BFF8,$BAB8,$0000
	dc.w	$1520,$2AD0,$1520,$0000,$3290,$0D60,$3290,$0000
	dc.w	$0000,$0000,$0000,$0000,$7FF0,$7FF0,$0000,$0000
	dc.w	$7FF0,$7FF0,$0000,$0000,$3FE0,$3FE0,$0000,$0000

knb1: dc.w 3,0,9,15,0,0
	dc.w	$0C00,$0000,$0C00,$0000,$0000,$1C00,$0000,$0000
	dc.w	$1C00,$0000,$1C00,$0000,$1C00,$0000,$1C00,$0000
	dc.w	$1C00,$0000,$1C00,$0000,$1C00,$0000,$1C00,$0000
	dc.w	$7F00,$0000,$7F00,$0000,$F780,$0000,$F780,$0000
	dc.w	$F780,$0000,$F780,$0000,$6300,$0000,$6300,$0000
knb2: dc.w 3,0,12,15,0,0
	dc.w	$0600,$0000,$0600,$0000,$0000,$0E00,$0000,$0000
	dc.w	$0E00,$0000,$0E00,$0000,$0E00,$0000,$0E00,$0000
	dc.w	$0E00,$0000,$0E00,$0000,$0E00,$0000,$0E00,$0000
	dc.w	$0E00,$0000,$0E00,$0000,$1F00,$0000,$1F00,$0000
	dc.w	$7FC0,$0000,$7FC0,$0000,$FBE0,$0000,$FBE0,$0000
	dc.w	$FBE0,$0000,$FBE0,$0000,$FBE0,$0000,$FBE0,$0000
	dc.w	$71C0,$0000,$71C0,$0000

pln1: dc.w 3,0,13,15,0,0
	dc.w	$0000,$0300,$0300,$0000,$0000,$0600,$0600,$0000
	dc.w	$0000,$0C00,$0C00,$0000,$0000,$0C00,$0C00,$0000
	dc.w	$0800,$0F80,$0F80,$0000,$0800,$79C0,$79C0,$0000
	dc.w	$0800,$C800,$C800,$0000,$0800,$0F00,$0F00,$0000
	dc.w	$0800,$0980,$0980,$0000,$0000,$FF00,$0000,$0000
	dc.w	$0000,$7E00,$0000,$0000,$0000,$3C00,$0000,$0000
	dc.w	$0600,$2700,$2600,$2700,$6000,$E000,$E000,$E000
pln2: dc.w 3,0,13,15,0,0
	dc.w	$0000,$3000,$3000,$0000,$0000,$1800,$1800,$0000
	dc.w	$0000,$1800,$1800,$0000,$0000,$1BC0,$1BC0,$0000
	dc.w	$0800,$CF00,$CF00,$0000,$0800,$7800,$7800,$0000
	dc.w	$0800,$1F80,$1F80,$0000,$0800,$0C00,$0C00,$0000
	dc.w	$0800,$0800,$0800,$0000,$0000,$FF00,$0000,$0000
	dc.w	$0000,$7E00,$0000,$0000,$0000,$3C00,$0000,$0000
	dc.w	$6400,$E400,$E400,$E400,$0600,$0700,$0600,$0700
shp1: dc.w 3,0,10,15,0,0
	dc.w	$F000,$F000,$F000,$F000,$8DDE,$FDDE,$8DDE,$FDDE
	dc.w	$67F1,$7FFF,$67F1,$7FFF,$3FFE,$3FFE,$3FFE,$3FFE
	dc.w	$07F0,$07F0,$0490,$07F0,$07F0,$07F0,$07F0,$07F0
	dc.w	$06B0,$07F0,$06B0,$07F0,$0770,$07F0,$0770,$07F0
	dc.w	$0550,$07F0,$0550,$07F0,$0220,$03E0,$0220,$03E0
	dc.w	$03E0,$03E0,$03E0,$03E0

shp2: dc.w 3,0,11,15,0,0
	dc.w	$000F,$000F,$000F,$000F,$7BB1,$7BBF,$7BB1,$7BBF
	dc.w	$8FE6,$FFFE,$8FE6,$FFFE,$7FFC,$7FFC,$7FFC,$7FFC
	dc.w	$0FE0,$0FE0,$0920,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0
	dc.w	$0D60,$0FE0,$0D60,$0FE0,$0EE0,$0FE0,$0EE0,$0FE0
	dc.w	$0AA0,$0FE0,$0AA0,$0FE0,$0820,$0FE0,$0820,$0FE0
	dc.w	$0440,$07C0,$0440,$07C0,$07C0,$07C0,$07C0,$07C0


coke1: dc.w 3,0,11,15,0,0
	dc.w	$8E00,$FF80,$FE00,$FF80,$0200,$FF80,$0600,$0600
	dc.w	$0300,$FF80,$2700,$2700,$0100,$FF80,$A300,$A300
	dc.w	$0200,$FF80,$4600,$4600,$0200,$FF80,$4600,$4600
	dc.w	$0000,$7FC0,$5600,$5600,$0000,$7FC0,$5600,$5600
	dc.w	$0200,$7FC0,$1600,$1600,$0300,$7FC0,$6700,$6700
	dc.w	$0100,$7FC0,$0300,$0300,$2700,$3F80,$3F00,$3F80
coke2: dc.w 3,0,11,15,0,0
	dc.w	$4700,$7FC0,$7F00,$7FC0,$0100,$7FC0,$0300,$0300
	dc.w	$0180,$7FC0,$1380,$1380,$0080,$7FC0,$5180,$5180
	dc.w	$0100,$7FC0,$2300,$2300,$0000,$7FC0,$2600,$2600
	dc.w	$0000,$FF80,$AC00,$AC00,$0000,$FF80,$AC00,$AC00
	dc.w	$0400,$FF80,$2C00,$2C00,$0600,$FF80,$CE00,$CE00
	dc.w	$0200,$FF80,$0600,$0600,$4E00,$7F00,$7E00,$7F00




bug1: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0108,$0108,$0108,$0010,$1118,$1110,$1118
	dc.w	$C010,$D9B1,$D131,$19B1,$20A2,$6DF6,$29E6,$0DF6
	dc.w	$0464,$6DEC,$6DEC,$0D2C,$2648,$67FC,$67F8,$0404
	dc.w	$0BEC,$7FFC,$7FFC,$0004,$0F3C,$3FFC,$3FFC,$0000
	dc.w	$0408,$0408,$0408,$0408,$0408,$0C18,$0C18,$0C18
bug2: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0218,$0210,$0218,$0010,$2332,$2232,$2332
	dc.w	$0000,$19F2,$1162,$19F2,$C0A2,$DDE6,$D9E6,$1DE6
	dc.w	$0444,$6DCC,$2DCC,$0D0C,$2648,$67FC,$67F8,$0404
	dc.w	$0BEC,$7FFC,$7FFC,$0004,$0F3C,$3FFC,$3FFC,$0000
	dc.w	$0408,$050A,$0408,$050A,$0810,$1B36,$1830,$1B36
bug3: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0300,$0200,$0300,$0100,$0360,$0300,$0360
	dc.w	$0080,$01C0,$0180,$01C0,$0080,$0180,$0180,$0180
	dc.w	$0080,$0180,$0180,$0000,$0340,$07E0,$07E0,$0000
	dc.w	$06E0,$07E0,$07E0,$0000,$0CC0,$0FF0,$0FF0,$0000
	dc.w	$0240,$0240,$0240,$0240,$0000,$0240,$0040,$0240
bug4: dc.w 3,0,9,15,0,0
	dc.w	$0000,$00C0,$0040,$00C0,$0080,$06C0,$00C0,$06C0
	dc.w	$0100,$0380,$0180,$0380,$0100,$0180,$0180,$0180
	dc.w	$0100,$0180,$0180,$0000,$02C0,$07E0,$07E0,$0000
	dc.w	$0760,$07E0,$07E0,$0000,$0330,$0FF0,$0FF0,$0000
	dc.w	$0240,$0240,$0240,$0240,$0000,$0240,$0200,$0240
bug5: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0080,$0080,$0080,$0000,$0280,$0080,$0280
	dc.w	$0000,$0280,$0080,$0280,$0000,$0180,$0180,$0000
	dc.w	$0000,$03C0,$0180,$0000,$0240,$07E0,$07E0,$0000
	dc.w	$0660,$07E0,$07E0,$0000,$0330,$0FF0,$0FF0,$0000
	dc.w	$0240,$0240,$0240,$0240,$0000,$0240,$0200,$0240
bug6: dc.w 3,0,9,15,0,0
	dc.w	$0000,$0100,$0100,$0100,$0000,$0140,$0100,$0140
	dc.w	$0000,$01C0,$0180,$0040,$0000,$03C0,$0180,$0000
	dc.w	$0000,$0180,$0180,$0000,$0240,$07E0,$07E0,$0000
	dc.w	$0660,$07E0,$07E0,$0000,$0CC0,$0FF0,$0FF0,$0000
	dc.w	$0240,$0240,$0240,$0240,$0000,$0240,$0040,$0240
bug7: dc.w 3,0,9,15,0,0
	dc.w	$0000,$1080,$1080,$1080,$0800,$1888,$0888,$1888
	dc.w	$0803,$8D9B,$8C8B,$8D98,$4504,$6FB6,$6794,$6FB0
	dc.w	$2620,$37B6,$37B6,$34B0,$1264,$3FE6,$1FE6,$2020
	dc.w	$37D0,$3FFE,$3FFE,$2000,$3CF0,$3FFC,$3FFC,$0000
	dc.w	$1020,$1020,$1020,$1020,$1020,$1830,$1830,$1830
bug8: dc.w 3,0,9,15,0,0
	dc.w	$0000,$1840,$0840,$1840,$0800,$4CC4,$4C44,$4CC4
	dc.w	$0000,$4F98,$4688,$4F98,$4503,$67BB,$679B,$67B8
	dc.w	$2220,$33B6,$33B4,$30B0,$1264,$3FE6,$1FE6,$2020
	dc.w	$37D0,$3FFE,$3FFE,$2000,$3CF0,$3FFC,$3FFC,$0000
	dc.w	$1020,$50A0,$1020,$50A0,$0810,$6CD8,$0C18,$6CD8

spik1: dc.w 3,0,8,7,0,0
	dc.w	$0000,$8000,$8000,$8000,$4000,$4000,$4000,$4000
	dc.w	$2000,$7000,$6000,$7000,$1000,$3800,$3000,$3800
	dc.w	$0C00,$1C00,$1C00,$1C00,$0600,$1E00,$1E00,$1E00
	dc.w	$0300,$0F00,$0F00,$0F00,$0000,$0600,$0400,$0600
	dc.w	$0000,$0400,$0400,$0400
spik2: dc.w 3,0,8,7,0,0
	dc.w	$0000,$0100,$0100,$0100,$0200,$0200,$0200,$0200
	dc.w	$0400,$0E00,$0600,$0E00,$0800,$1C00,$0C00,$1C00
	dc.w	$3000,$3800,$3800,$3800,$6000,$7800,$7800,$7800
	dc.w	$C000,$F000,$F000,$F000,$0000,$6000,$2000,$6000
	dc.w	$0000,$2000,$2000,$2000
spik3: dc.w 3,0,8,7,0,0
	dc.w	$0000,$2000,$2000,$2000,$0000,$6000,$2000,$6000
	dc.w	$C000,$F000,$F000,$F000,$6000,$7800,$7800,$7800
	dc.w	$3000,$3800,$3800,$3800,$0800,$1C00,$0C00,$1C00
	dc.w	$0400,$0E00,$0600,$0E00,$0200,$0200,$0200,$0200
	dc.w	$0000,$0100,$0100,$0100
spik4: dc.w 3,0,8,7,0,0
	dc.w	$0000,$0400,$0400,$0400,$0000,$0600,$0400,$0600
	dc.w	$0300,$0F00,$0F00,$0F00,$0600,$1E00,$1E00,$1E00
	dc.w	$0C00,$1C00,$1C00,$1C00,$1000,$3800,$3000,$3800
	dc.w	$2000,$7000,$6000,$7000,$4000,$4000,$4000,$4000
	dc.w	$0000,$8000,$8000,$8000

glob1: dc.w 3,0,9,11,0,0
	dc.w	$0000,$0000,$0E00,$0E00,$1000,$0C00,$2F00,$1F00
	dc.w	$2C00,$1000,$5300,$7F00,$1380,$0000,$EC00,$F380
	dc.w	$6700,$0000,$1880,$6700,$0880,$0000,$3760,$0F80
	dc.w	$0040,$0000,$0FB0,$0FC0,$0080,$0200,$0F70,$0F80
	dc.w	$0600,$0180,$01E0,$0780,$0000,$0000,$0380,$0000
glob2: dc.w 3,0,12,13,0,0
	dc.w	$0000,$0000,$0180,$0180,$0200,$0000,$01C0,$03C0
	dc.w	$0000,$0180,$03C0,$01C0,$0480,$0200,$0360,$06E0
	dc.w	$0140,$0400,$1EB8,$1F78,$00BC,$0800,$7F40,$7FBC
	dc.w	$0090,$0000,$FF6C,$FF9C,$0050,$0000,$FFAC,$FFDC
	dc.w	$00A0,$0000,$7F58,$7FB8,$0F40,$0000,$10BC,$1F7C
	dc.w	$1840,$0090,$07BC,$18FC,$0080,$0060,$0778,$00F8
	dc.w	$0000,$0000,$00E0,$00E0
glob3: dc.w 3,0,12,13,0,0
	dc.w	$0000,$0000,$0380,$0380,$0800,$0100,$17C0,$0FC0
	dc.w	$0810,$0600,$37E0,$0FF0,$0410,$0800,$3BE8,$0FF0
	dc.w	$3324,$0800,$0CD8,$3BE4,$08C8,$1000,$7734,$78CC
	dc.w	$0210,$1000,$FDEC,$FE1C,$0210,$0000,$FDEC,$FE1C
	dc.w	$0400,$0020,$7BF8,$7C38,$09C0,$0010,$763C,$79FC
	dc.w	$1218,$0020,$6DE4,$73FC,$0420,$00C0,$1BD8,$07E0
	dc.w	$0020,$0000,$07C0,$07E0
glob4: dc.w 3,0,11,11,0,0
	dc.w	$1000,$0000,$0E00,$1E00,$0000,$0C00,$3FC0,$0FC0
	dc.w	$3400,$0800,$0BE0,$3FE0,$0B30,$1000,$34C0,$3BF0
	dc.w	$04C0,$1000,$7B30,$7CC0,$0C00,$0000,$F3F0,$FC00
	dc.w	$3200,$0000,$CDE0,$F200,$0500,$0000,$3AE0,$0700
	dc.w	$1900,$0000,$06C0,$1F00,$0080,$0400,$0F40,$0F80
	dc.w	$0040,$0300,$0FA0,$0FC0,$0000,$0000,$07C0,$07C0
glob5: dc.w 3,0,6,7,0,0
	dc.w	$0000,$0000,$0C00,$0000,$2200,$0C00,$1C00,$2E00
	dc.w	$0400,$1000,$FA00,$F600,$1400,$0000,$EB00,$F700
	dc.w	$2400,$0000,$5B00,$6700,$0200,$0000,$0C00,$0200
	dc.w	$0000,$0000,$0600,$0000
glob6: dc.w 3,0,7,8,0,0
	dc.w	$2000,$0000,$1000,$2000,$0000,$1000,$3F00,$3000
	dc.w	$0880,$2000,$7700,$7880,$0900,$2000,$F680,$F980
	dc.w	$1A00,$0100,$6580,$7B80,$3000,$0200,$0F80,$3380
	dc.w	$0200,$0000,$3D00,$0300,$0000,$0000,$1800,$0000
glob7: dc.w 3,0,9,10,0,0
	dc.w	$0000,$0000,$1C00,$0000,$4000,$1800,$3E00,$5800
	dc.w	$0040,$2000,$FF80,$E040,$1080,$0000,$EF60,$F0E0
	dc.w	$1100,$0000,$EEE0,$F1E0,$1100,$0080,$6EC0,$71C0
	dc.w	$1200,$0080,$6DC0,$73C0,$2200,$0100,$DD80,$E380
	dc.w	$C200,$0000,$3D80,$C380,$0180,$0000,$6200,$0180
glob8: dc.w 3,0,8,8,0,0
	dc.w	$0000,$0000,$7000,$7000,$0800,$3000,$F600,$F800
	dc.w	$0800,$4000,$F780,$F800,$08C0,$0000,$F700,$F8C0
	dc.w	$3100,$0000,$4EC0,$71C0,$0200,$0000,$1D80,$0380
	dc.w	$0200,$0000,$0D00,$0300,$0000,$0200,$0780,$0380
	dc.w	$0100,$0000,$0280,$0180
glob9: dc.w 3,0,5,6,0,0
	dc.w	$3000,$0000,$0000,$3000,$4800,$1000,$3000,$7800
	dc.w	$4400,$2000,$3800,$7C00,$4200,$0000,$3C00,$7E00
	dc.w	$8C00,$0000,$7000,$FC00,$7000,$0000,$0000,$7000
glob10: dc.w 3,0,6,7,0,0
	dc.w	$3000,$0000,$0000,$3000,$4E00,$3000,$3000,$7E00
	dc.w	$8100,$4000,$7E00,$FF00,$8100,$0000,$7E00,$FF00
	dc.w	$4100,$0400,$3E00,$7F00,$4600,$0800,$3800,$7E00
	dc.w	$3800,$0000,$0000,$3800
glob11: dc.w 3,0,9,8,0,0
	dc.w	$1C00,$0000,$0000,$1C00,$2200,$0000,$1C00,$3E00
	dc.w	$4100,$1800,$3E00,$7F00,$8080,$2000,$7F00,$FF80
	dc.w	$8080,$0000,$7F00,$FF80,$4080,$0200,$3F00,$7F80
	dc.w	$8080,$0000,$7F00,$FF80,$8300,$0000,$7C00,$FF00
	dc.w	$7400,$0000,$0800,$7C00,$0800,$0000,$0000,$0800
glob12: dc.w 3,0,8,8,0,0
	dc.w	$0400,$0000,$0000,$0400,$0A00,$0400,$0400,$0E00
	dc.w	$1100,$0800,$0E00,$1F00,$1080,$0800,$0F00,$1F80
	dc.w	$1100,$0000,$0E00,$1F00,$2200,$0000,$1C00,$3E00
	dc.w	$4200,$0400,$3C00,$7E00,$8400,$0800,$7800,$FC00
	dc.w	$7800,$0000,$0000,$7800
lazr: dc.w 3,0,7,13,0,0
	dc.w	$0000,$0300,$0000,$0300,$0000,$0300,$0000,$0300
	dc.w	$0300,$FFFC,$0300,$FFFC,$0400,$FFFC,$BFF4,$BFF4
	dc.w	$FFFC,$FFFC,$FFFC,$FFFC,$0300,$FFFC,$0300,$FFFC
	dc.w	$0300,$0300,$0300,$0300,$0000,$0300,$0000,$0300

ylazr: dc.w 3,0,9,7,0,0
	dc.w	$0800,$3C00,$1800,$3C00,$0800,$3C00,$0800,$2C00
	dc.w	$0800,$3C00,$1800,$3C00,$0800,$3C00,$1800,$3C00
	dc.w	$2E00,$FF00,$3E00,$FF00,$2E00,$FF00,$3E00,$FF00
	dc.w	$1800,$3C00,$1800,$3C00,$0800,$3C00,$1800,$3C00
	dc.w	$0800,$3C00,$0800,$2C00,$0800,$3C00,$1800,$3C00

yy1: dc.w 3,0,10,12,0,0
	dc.w	$0080,$0000,$0F00,$0000,$0260,$0000,$3D80,$0000
	dc.w	$0730,$0000,$78C0,$0000,$0230,$0000,$7DC0,$0000
	dc.w	$0078,$0000,$FF80,$0000,$07F8,$0000,$F800,$0000
	dc.w	$0FF8,$0000,$F000,$0000,$1DF0,$0000,$6200,$0000
	dc.w	$18F0,$0000,$6700,$0000,$0DE0,$0000,$3200,$0000
	dc.w	$0780,$0000,$0800,$0000
yy2: dc.w 3,0,11,12,0,0
	dc.w	$0000,$0000,$0E00,$0000,$0000,$0000,$3FC0,$0000
	dc.w	$0000,$0000,$7FE0,$0000,$01C0,$0000,$7E30,$0000
	dc.w	$09C0,$0000,$F630,$0000,$3E00,$0000,$41F0,$0000
	dc.w	$7F18,$0000,$80E0,$0000,$63F8,$0000,$1C00,$0000
	dc.w	$67F0,$0000,$1800,$0000,$2FF0,$0000,$1000,$0000
	dc.w	$1FE0,$0000,$0000,$0000,$0F80,$0000,$0000,$0000
yy3: dc.w 3,0,12,10,0,0
	dc.w	$0000,$0000,$0E00,$0000,$0000,$0000,$3F80,$0000
	dc.w	$0000,$0000,$7FC0,$0000,$0000,$3000,$4FC0,$0000
	dc.w	$0000,$7800,$87E0,$0000,$0000,$DC80,$2360,$0000
	dc.w	$0000,$8DC0,$7220,$0000,$0000,$DC80,$2360,$0000
	dc.w	$0000,$FC20,$03C0,$0000,$0000,$7E40,$0180,$0000
	dc.w	$0000,$7FC0,$0000,$0000,$0000,$3F80,$0000,$0000
	dc.w	$0000,$0E00,$0000,$0000

yy4: dc.w 3,0,12,12,0,0
	dc.w	$0000,$0000,$0280,$0000,$0000,$0E00,$01E0,$0000
	dc.w	$0000,$1F00,$00F0,$0000,$0000,$2300,$1CF0,$0000
	dc.w	$0000,$7300,$0CF8,$0000,$0000,$7B00,$04F8,$0000
	dc.w	$0000,$FF00,$00F8,$0000,$0000,$7EC0,$0130,$0000
	dc.w	$0000,$7CC0,$0330,$0000,$0000,$3CC0,$0330,$0000
	dc.w	$0000,$3C00,$03E0,$0000,$0000,$1E00,$01C0,$0000
	dc.w	$0000,$0600,$0000,$0000
yy5: dc.w 3,0,10,12,0,0
	dc.w	$0F00,$0F00,$0080,$0F00,$3D80,$3D80,$0260,$3D80
	dc.w	$78C0,$78C0,$0730,$78C0,$7DC0,$7DC0,$0230,$7DC0
	dc.w	$FF80,$FF80,$0078,$FF80,$FF00,$FF00,$00F8,$FF00
	dc.w	$F000,$F000,$0FF8,$F000,$6200,$6200,$1DF0,$6200
	dc.w	$6700,$6700,$18F0,$6700,$3200,$3200,$0DE0,$3200
	dc.w	$0000,$0800,$0780,$0800
yy6: dc.w 3,0,11,12,0,0
	dc.w	$0200,$0200,$0000,$0200,$0F80,$0F80,$0000,$0F80
	dc.w	$3FC0,$3FC0,$0000,$3FC0,$7FA0,$7FA0,$0040,$7FA0
	dc.w	$7F20,$7F20,$00D0,$7F20,$FE20,$FE20,$01D0,$FE20
	dc.w	$C7E0,$C7E0,$3818,$C7E0,$03E0,$03E0,$7C10,$03E0
	dc.w	$1DC0,$1DC0,$6238,$1DC0,$1C00,$1C00,$63F0,$1C00
	dc.w	$0000,$0000,$3FF0,$0000,$0000,$0000,$1FE0,$0000
	dc.w	$0000,$0000,$0380,$0000
yy7: dc.w 3,0,12,10,0,0
	dc.w	$0000,$0E00,$0E00,$0000,$0000,$3F80,$3F80,$0000
	dc.w	$0000,$7FC0,$7FC0,$0000,$0000,$4FC0,$7FC0,$0000
	dc.w	$0000,$87E0,$FFE0,$0000,$0000,$2760,$FFE0,$0000
	dc.w	$0000,$7620,$FFE0,$0000,$0000,$2760,$FFE0,$0000
	dc.w	$0000,$03C0,$FFE0,$0000,$0000,$0180,$7FC0,$0000
	dc.w	$0000,$0000,$7FC0,$0000,$0000,$0000,$3F80,$0000
	dc.w	$0000,$0000,$0E00,$0000
yy8: dc.w 3,0,12,12,0,0
	dc.w	$0000,$0300,$0300,$0000,$0000,$03C0,$1FC0,$0000
	dc.w	$0000,$01E0,$3FE0,$0000,$0000,$19E0,$7FE0,$0000
	dc.w	$0000,$19F0,$7FF0,$0000,$0000,$1BF0,$7FF0,$0000
	dc.w	$0000,$07F8,$FFF8,$0000,$0000,$06F0,$FFF0,$0000
	dc.w	$0000,$0670,$FFF0,$0000,$0000,$0620,$7FE0,$0000
	dc.w	$0000,$07C0,$7FC0,$0000,$0000,$0380,$3F80,$0000
	dc.w	$0000,$0000,$0A00,$0000
yyp1: dc.w 3,0,5,1,0,0
	dc.w	$0000,$C000,$0000,$C000,$C000,$C000,$C000,$C000
	dc.w	$0000,$C000,$C000,$C000,$0000,$C000,$C000,$C000
	dc.w	$C000,$C000,$C000,$C000,$0000,$C000,$0000,$C000
yyp2: dc.w 3,0,5,5,0,0
	dc.w	$0000,$3000,$0000,$3000,$3000,$3000,$3000,$3000
	dc.w	$4800,$FC00,$7800,$FC00,$4800,$FC00,$7800,$FC00
	dc.w	$3000,$3000,$3000,$3000,$0000,$3000,$0000,$3000
yyp3: dc.w 3,0,7,7,0,0
	dc.w	$0000,$1800,$0000,$1800,$1800,$1800,$1800,$1800
	dc.w	$1800,$1800,$1800,$1800,$6600,$FF00,$7E00,$FF00
	dc.w	$6600,$FF00,$7E00,$FF00,$1800,$1800,$1800,$1800
	dc.w	$1800,$1800,$1800,$1800,$0000,$1800,$0000,$1800
yyp4: dc.w 3,0,7,5,0,0
	dc.w	$0000,$3000,$0000,$3000,$3000,$3000,$3000,$3000
	dc.w	$3000,$3000,$3000,$3000,$4800,$FC00,$7800,$FC00
	dc.w	$4800,$FC00,$7800,$FC00,$3000,$3000,$3000,$3000
	dc.w	$3000,$3000,$3000,$3000,$0000,$3000,$0000,$3000
cher1: dc.w 3,0,10,11,0,0
	dc.w	$00C0,$05C0,$05C0,$0000,$0020,$07E0,$07E0,$0000
	dc.w	$0010,$0DF0,$0DF0,$0000,$0000,$1400,$1400,$0000
	dc.w	$0000,$2200,$2200,$0000,$0000,$2300,$2000,$0000
	dc.w	$0000,$2780,$2000,$0000,$0000,$6780,$0000,$0000
	dc.w	$0000,$F300,$0000,$0000,$0000,$F000,$0000,$0000
	dc.w	$0000,$6000,$0000,$0000
cher2: dc.w 3,0,10,10,0,0
	dc.w	$0180,$0BE0,$0BE0,$0000,$0040,$0FC0,$0FC0,$0000
	dc.w	$0000,$1B00,$1B00,$0000,$0000,$2400,$2400,$0000
	dc.w	$0000,$2200,$2200,$0000,$0000,$2100,$2100,$0000
	dc.w	$0000,$6100,$0100,$0000,$0000,$F180,$0000,$0000
	dc.w	$0000,$F3C0,$0000,$0000,$0000,$63C0,$0000,$0000
	dc.w	$0000,$0180,$0000,$0000
phon1: dc.w 3,0,11,13,0,0
	dc.w	$0000,$01F8,$0000,$0000,$0000,$0FFC,$0000,$0000
	dc.w	$0000,$3C1C,$0000,$0000,$0000,$6008,$0000,$0000
	dc.w	$0000,$F440,$0000,$0000,$0000,$EFE0,$0000,$0000
	dc.w	$0000,$5FF0,$0540,$0540,$0000,$1FF0,$0000,$0000
	dc.w	$0000,$1FF0,$0540,$0540,$0000,$1FF0,$0000,$0000
	dc.w	$0000,$1FF0,$0540,$0540,$0000,$1FF0,$0000,$0000
phon2: dc.w 3,0,11,13,0,0
	dc.w	$0000,$7E00,$0000,$0000,$0000,$FFC0,$0000,$0000
	dc.w	$0000,$E0F0,$0000,$0000,$0000,$4018,$0000,$0000
	dc.w	$0000,$08BC,$0000,$0000,$0000,$1FDC,$0000,$0000
	dc.w	$0000,$3FE8,$0A80,$0A80,$0000,$3FE0,$0000,$0000
	dc.w	$0000,$3FE0,$0A80,$0A80,$0000,$3FE0,$0000,$0000
	dc.w	$0000,$3FE0,$0A80,$0A80,$0000,$3FE0,$0000,$0000
smly1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0000,$07E0,$0000,$0420,$0420,$1BD8,$0000
	dc.w	$0A50,$0E70,$318C,$0420,$1188,$1FF8,$6006,$0E70
	dc.w	$0A50,$0E70,$718E,$0420,$0420,$0420,$FBDF,$0000
	dc.w	$0000,$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000
	dc.w	$0000,$0000,$FFFF,$0000,$1008,$300C,$CFF3,$2004
	dc.w	$0420,$1C38,$63C6,$1818,$0810,$0FF0,$700E,$07E0
	dc.w	$0000,$0000,$3FFC,$0000,$0000,$0000,$1FF8,$0000
	dc.w	$0000,$0000,$07E0,$0000
smly2: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0000,$07E0,$0000,$0420,$0420,$1BD8,$0000
	dc.w	$0A50,$0E70,$318C,$0420,$1188,$1FF8,$6006,$0E70
	dc.w	$1188,$1FF8,$6006,$0E70,$0A50,$0E70,$F18F,$0420
	dc.w	$0420,$0420,$FBDF,$0000,$0000,$0000,$FFFF,$0000
	dc.w	$0000,$0000,$FFFF,$0000,$1008,$300C,$CFF3,$2004
	dc.w	$0000,$1FF8,$6006,$1C38,$0000,$0FF0,$700E,$0E70
	dc.w	$0000,$07E0,$381C,$07E0,$0000,$0000,$1FF8,$0000
	dc.w	$0000,$0000,$07E0,$0000
tv1: dc.w 3,0,16,10,0,0
	dc.w	$0000,$0020,$0020,$0020,$0000,$0040,$0040,$0040
	dc.w	$0000,$C080,$C080,$C080,$0000,$3100,$3100,$3100
	dc.w	$0000,$0E00,$0E00,$0E00,$FFE0,$FFE0,$0000,$0000
	dc.w	$C060,$FFE0,$0000,$3F80,$8020,$FFE0,$1000,$7FC0
	dc.w	$8020,$FFE0,$2000,$7FC0,$8020,$FFE0,$0000,$7FC0
	dc.w	$8020,$FFE0,$0000,$7FC0,$8020,$FFE0,$0000,$7FC0
	dc.w	$C060,$FFE0,$0000,$3F80,$FFE0,$FFE0,$0000,$0000
	dc.w	$0000,$60C0,$0000,$60C0,$0000,$60C0,$0000,$00C0
	dc.w	$0000,$00C0,$0000,$0000
tv2: dc.w 3,0,16,10,0,0
	dc.w	$0000,$8000,$8000,$8000,$0000,$4000,$4000,$4000
	dc.w	$0000,$2060,$2060,$2060,$0000,$1180,$1180,$1180
	dc.w	$0000,$0E00,$0E00,$0E00,$FFE0,$FFE0,$0000,$0000
	dc.w	$C060,$FFE0,$0000,$3F80,$8020,$FFE0,$1000,$7FC0
	dc.w	$8020,$FFE0,$2000,$7FC0,$8020,$FFE0,$0000,$7FC0
	dc.w	$8020,$FFE0,$0000,$7FC0,$8020,$FFE0,$0000,$7FC0
	dc.w	$C060,$FFE0,$0000,$3F80,$FFE0,$FFE0,$0000,$0000
	dc.w	$0000,$60C0,$0000,$60C0,$0000,$60C0,$0000,$6000
	dc.w	$0000,$6000,$0000,$0000
kios1: dc.w 3,0,12,9,0,0
	dc.w	$0000,$1C00,$0000,$0000,$0000,$7F00,$0000,$0000
	dc.w	$0000,$FF80,$3E00,$3E00,$0000,$FF80,$0000,$0000
	dc.w	$3300,$FF80,$7700,$7700,$7700,$FF80,$7700,$7700
	dc.w	$0000,$FF80,$0000,$0000,$1980,$7FC0,$3B80,$3B80
	dc.w	$3B80,$7FC0,$3B80,$3B80,$0000,$7FC0,$0000,$0000
	dc.w	$1980,$7FC0,$3B80,$3B80,$3B80,$7FC0,$3B80,$3B80
	dc.w	$0000,$7FC0,$0000,$0000
kios2: dc.w 3,0,12,9,0,0
	dc.w	$0000,$1C00,$0000,$0000,$0000,$7F00,$0000,$0000
	dc.w	$0000,$FF80,$3E00,$3E00,$0000,$FF80,$0000,$0000
	dc.w	$3300,$FF80,$7700,$7700,$7700,$FF80,$7700,$7700
	dc.w	$0000,$FF80,$0000,$0000,$3300,$FF80,$7700,$7700
	dc.w	$7700,$FF80,$7700,$7700,$0000,$FF80,$0000,$0000
	dc.w	$3300,$FF80,$7700,$7700,$7700,$FF80,$7700,$7700
	dc.w	$0000,$FF80,$0000,$0000
fpac1: dc.w 3,0,9,6,0,0
	dc.w	$FE00,$FE00,$FE00,$FE00,$8200,$FE00,$FE00,$FE00
	dc.w	$8200,$FE00,$FE00,$FE00,$FE00,$FE00,$FE00,$FE00
	dc.w	$8E00,$FE00,$F200,$FE00,$9A00,$FE00,$E600,$FE00
	dc.w	$B200,$FE00,$CE00,$FE00,$E200,$FE00,$9E00,$FE00
	dc.w	$C200,$FE00,$BE00,$FE00,$FE00,$FE00,$FE00,$FE00
fpac2: dc.w 3,0,12,6,0,0
	dc.w	$1000,$1000,$0000,$0000,$5000,$5000,$0000,$0000
	dc.w	$EE00,$FE00,$BA00,$BA00,$8600,$FE00,$D200,$FA00
	dc.w	$AA00,$FE00,$D600,$D600,$AA00,$FE00,$D600,$D600
	dc.w	$FE00,$FE00,$FE00,$FE00,$8E00,$FE00,$F200,$FE00
	dc.w	$9A00,$FE00,$E600,$FE00,$B200,$FE00,$CE00,$FE00
	dc.w	$E200,$FE00,$9E00,$FE00,$C200,$FE00,$BE00,$FE00
	dc.w	$FE00,$FE00,$FE00,$FE00

blokr1: dc.w 3,0,14,15,0,0
		dc.w	$0000,$07E0,$0000,$0000,$07E0,$07E0,$0000,$0000
		dc.w	$0810,$0810,$07E0,$0810,$1818,$1818,$07E0,$1818
		dc.w	$381C,$300C,$07E0,$381C,$4662,$C003,$399C,$0000
		dc.w	$4422,$C003,$3BDC,$0000,$4002,$C003,$3FFC,$0000
		dc.w	$4422,$C003,$3BDC,$0000,$4662,$C003,$399C,$0000
		dc.w	$381C,$300C,$07E0,$381C,$1818,$1818,$07E0,$1818
		dc.w	$0810,$0810,$07E0,$0810,$07E0,$07E0,$0000,$0000
		dc.w	$0000,$07E0,$0000,$0000
blokr2: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0300,$0000,$0000,$0300,$0F00,$0000,$0000
	dc.w	$0C60,$3C64,$0380,$0060,$1078,$103C,$0F80,$0070
	dc.w	$2004,$2006,$1FF8,$2000,$20C4,$2006,$1F38,$2000
	dc.w	$3442,$2003,$0BBC,$3000,$4822,$4002,$37DC,$4000
	dc.w	$8024,$8004,$7FD8,$0004,$444C,$C004,$3BB0,$000C
	dc.w	$4308,$C008,$3CF0,$0008,$2008,$6008,$1FF0,$0008
	dc.w	$3C18,$7818,$03E0,$1C00,$0660,$0678,$0180,$0600
	dc.w	$0180,$01E0,$0000,$0000,$0000,$0080,$0000,$0000
blokr3: dc.w 3,0,14,13,0,0
	dc.w	$0000,$0800,$0000,$0000,$0800,$1820,$0000,$0000
	dc.w	$13A0,$33B0,$0C40,$0380,$2110,$6018,$1EE0,$0100
	dc.w	$4108,$C00C,$3EF0,$0000,$0300,$0000,$7CF8,$0000
	dc.w	$0048,$0008,$7FB0,$0008,$4878,$4008,$3780,$4018
	dc.w	$7848,$4008,$07B0,$6008,$4800,$4000,$37F8,$4000
	dc.w	$0708,$000C,$78F0,$0000,$4210,$C018,$3DE0,$0000
	dc.w	$2220,$6030,$1DC0,$0200,$1740,$3760,$0880,$0700
	dc.w	$0000,$1040,$0000,$0000
blokr4: dc.w 3,0,15,15,0,0
	dc.w	$0000,$00C0,$0000,$0000,$00C0,$00F0,$0000,$0000
	dc.w	$0630,$263C,$01C0,$0600,$1E08,$3C08,$01F0,$0E00
	dc.w	$2004,$6004,$1FF8,$0004,$2304,$6004,$1CF8,$0004
	dc.w	$422C,$C004,$3DD0,$000C,$4412,$4002,$3BEC,$0002
	dc.w	$2401,$2001,$1BFE,$2000,$3222,$2003,$0DDC,$3000
	dc.w	$10C2,$1003,$0F3C,$1000,$1004,$1006,$0FF8,$1000
	dc.w	$183C,$181E,$07C0,$0038,$0660,$1E60,$0180,$0060
	dc.w	$0180,$0780,$0000,$0000,$0000,$0100,$0000,$0000

card1: dc.w 3,0,14,11,0,0
	dc.w	$0000,$7FE0,$7FE0,$7FE0,$0000,$FFF0,$9FF0,$9FF0
	dc.w	$0000,$FFF0,$BFF0,$BFF0,$0000,$FFF0,$FFF0,$FFF0
	dc.w	$0000,$FFF0,$FFF0,$FFF0,$0000,$FFF0,$F6F0,$F6F0
	dc.w	$0000,$FFF0,$E070,$E070,$0000,$FFF0,$E070,$E070
	dc.w	$0000,$FFF0,$F0F0,$F0F0,$0000,$FFF0,$F9F0,$F9F0
	dc.w	$0000,$FFF0,$FFF0,$FFF0,$0000,$FFF0,$FFF0,$FFF0
	dc.w	$0000,$FFF0,$FFD0,$FFD0,$0000,$FFF0,$FF90,$FF90
	dc.w	$0000,$7FE0,$7FE0,$7FE0
card2: dc.w 3,0,14,11,0,0
	dc.w	$0000,$7FE0,$7FE0,$7FE0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$2AA0,$FFF0,$D550,$FFF0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$2AA0,$FFF0,$D550,$FFF0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$2AA0,$FFF0,$D550,$FFF0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$2AA0,$FFF0,$D550,$FFF0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$2AA0,$FFF0,$D550,$FFF0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$2AA0,$FFF0,$D550,$FFF0,$5540,$FFF0,$AAB0,$FFF0
	dc.w	$0000,$7FE0,$7FE0,$7FE0
tpyr1: dc.w 3,0,7,14,0,0
	dc.w	$0000,$0000,$0100,$0000,$0000,$0000,$0380,$0000
	dc.w	$0000,$0000,$07C0,$0000,$0FE0,$0FE0,$0000,$0000
	dc.w	$1C70,$1FF0,$0380,$0380,$3938,$3FF8,$06C0,$07C0
	dc.w	$7C7C,$7FFC,$0380,$0380,$FFFE,$FFFE,$0000,$0000
tpyr2: dc.w 3,0,7,14,0,0
	dc.w	$0000,$0000,$0100,$0000,$0000,$0000,$0380,$0000
	dc.w	$0000,$0000,$07C0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0FE0,$0FE0,$0000,$0000,$1C70,$1FF0,$0380,$0380
	dc.w	$3938,$3FF8,$06C0,$07C0,$7C7C,$7FFC,$0380,$0380
	dc.w	$FFFE,$FFFE,$0000,$0000
rizl1: dc.w 3,0,8,15,0,0
	dc.w	$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000,$3458
	dc.w	$FFFF,$0000,$0000,$575A,$FFFF,$0000,$0000,$36D8
	dc.w	$FFFF,$0000,$0000,$55DA,$FFFF,$0000,$0000,$544A
	dc.w	$FFFF,$0000,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$FFFF,$0000,$0000,$FFFF
rizl2: dc.w 3,0,8,15,0,0
	dc.w	$FFFF,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$FFFF,$0000,$0000,$FFFF,$C003,$3FFC,$3FFC,$FFFF
	dc.w	$8001,$7FFE,$3FFC,$FFFF,$BFFD,$7FFE,$3FFC,$FFFF
	dc.w	$FFFF,$3FFC,$3FFC,$FFFF,$FFFF,$0000,$0000,$FFFF
	dc.w	$FFFF,$0000,$0000,$FFFF
bulb1: dc.w 3,0,14,10,0,0
	dc.w	$1100,$1F00,$1F00,$1F00,$0A00,$3F80,$3B80,$3F80
	dc.w	$2080,$60C0,$60C0,$60C0,$8020,$C060,$C060,$C060
	dc.w	$4040,$D160,$CA60,$D160,$0000,$9120,$8420,$9120
	dc.w	$0000,$D160,$8020,$D160,$0000,$4A40,$4040,$4A40
	dc.w	$0000,$2480,$2080,$2480,$0000,$1500,$1100,$1500
	dc.w	$0000,$1500,$1100,$1500,$0700,$0700,$1800,$0000
	dc.w	$1800,$1800,$0700,$0000,$0700,$0700,$1800,$0000
	dc.w	$0600,$0E00,$0E00,$0E00
bulb2: dc.w 3,0,14,10,0,0
	dc.w	$1100,$1F00,$1F00,$1F00,$0A00,$3F80,$3B80,$3F80
	dc.w	$2080,$60C0,$60C0,$60C0,$8020,$C060,$C060,$C060
	dc.w	$4040,$D160,$C460,$D160,$0000,$9120,$8A20,$9120
	dc.w	$0000,$D160,$8020,$D160,$0000,$4A40,$4040,$4A40
	dc.w	$0000,$2480,$2080,$2480,$0000,$1500,$1100,$1500
	dc.w	$0000,$1500,$1100,$1500,$0700,$0700,$1800,$0000
	dc.w	$1800,$1800,$0700,$0000,$0700,$0700,$1800,$0000
	dc.w	$0600,$0E00,$0E00,$0E00
tea1: dc.w 3,0,10,14,0,0
	dc.w	$3F00,$3F00,$3F00,$3F00,$3FC8,$FFD8,$C0D8,$C0D8
	dc.w	$C7DC,$3F3C,$3F3C,$FFFC,$FFE4,$0024,$0024,$FFE4
	dc.w	$00C4,$FFC4,$C0C4,$C0C4,$13C4,$FFC4,$F3C4,$F3C4
	dc.w	$D3E4,$3F2C,$332C,$F3EC,$F3F8,$0C38,$0038,$F3F8
	dc.w	$33C0,$CCC0,$C0C0,$F3C0,$0780,$7F80,$7F80,$7F80
	dc.w	$0300,$3F00,$3F00,$3F00
tea2: dc.w 3,0,10,14,0,0
	dc.w	$0000,$03F0,$03F0,$03F0,$23FC,$6FFC,$6C0C,$6C0C
	dc.w	$1C7C,$F3F0,$F3F0,$FFFC,$0FFC,$9000,$9000,$9FFC
	dc.w	$000C,$8FFC,$8C0C,$8C0C,$001C,$8FFC,$8F3C,$8F3C
	dc.w	$4C1C,$D3F0,$D330,$DF3C,$0F3C,$70C0,$7000,$7F3C
	dc.w	$033C,$0CCC,$0C0C,$0F3C,$0078,$07F8,$07F8,$07F8
	dc.w	$00F0,$03F0,$03F0,$03F0
lazind: dc.w 3,0,11,15,0,0
	dc.w	$9DB6,$0000,$0000,$0000,$9525,$0000,$0000,$0000
	dc.w	$9DB6,$0000,$0000,$0000,$94A5,$0000,$0000,$0000
	dc.w	$D5B5,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$03C0,$0000,$0000,$0000,$03C0,$0000,$0000,$0000
	dc.w	$0FF0,$0000,$0000,$0000,$07E0,$0000,$0000,$0000
	dc.w	$03C0,$0000,$0000,$0000,$0180,$0000,$0000,$0000

brane1: dc.w 3,0,13,15,0,0
	dc.w	$05E0,$0480,$0000,$0FE0,$1DB4,$0490,$0000,$7FFC
	dc.w	$7ECE,$1A42,$0000,$FFFE,$6F5E,$2344,$0000,$FFFE
	dc.w	$6D7B,$2529,$0000,$FFFF,$5DFB,$4409,$0000,$7FFF
	dc.w	$1B3A,$0908,$0000,$1FFE,$06FC,$0228,$0000,$03FE
	dc.w	$05E4,$0060,$0218,$03C4,$0590,$0090,$0268,$0280
	dc.w	$0220,$0020,$05D0,$0580,$0100,$0000,$0280,$0280
	dc.w	$0100,$0000,$0200,$0200,$0200,$0000,$0100,$0100

brane2: dc.w 3,0,13,15,0,0
	dc.w	$05C0,$0480,$0000,$0FE0,$3DB0,$0490,$0000,$7FFC
	dc.w	$7EAE,$120A,$0000,$FFFE,$6D5E,$2550,$0000,$FFFE
	dc.w	$5AF7,$4A31,$0000,$FFFF,$5BB7,$4891,$0000,$7FFF
	dc.w	$1B7A,$0908,$0000,$1FFE,$06FC,$0228,$0000,$03FE
	dc.w	$05E4,$0060,$0218,$03C4,$0398,$0098,$0460,$0480
	dc.w	$0220,$0020,$05D8,$0580,$0210,$0010,$05E0,$0580
	dc.w	$0400,$0000,$0A00,$0A00,$0400,$0000,$0800,$0800

brane3: dc.w 3,0,13,15,0,0
	dc.w	$382C,$2024,$0000,$3E7C,$5DB2,$4920,$0000,$7FFE
	dc.w	$F7DD,$9795,$0000,$FFFF,$D9FF,$1120,$0000,$FFFF
	dc.w	$BF9B,$2799,$0000,$FFFF,$D9FF,$1102,$0000,$FFFF
	dc.w	$BFDB,$27D1,$0000,$FFFF,$BF9B,$A999,$0000,$FFFF
	dc.w	$6776,$4570,$0000,$7FFE,$3D74,$2554,$0280,$3C7C
	dc.w	$0920,$0920,$06C0,$0000,$07C0,$07C0,$0000,$0000
	dc.w	$0300,$0000,$0000,$0000,$0000,$0000,$0300,$0300

brane4: dc.w 3,0,13,15,0,0
	dc.w	$341C,$2404,$0000,$3E7C,$4DBA,$0492,$0000,$7FFE
	dc.w	$BBEF,$A9E9,$0000,$FFFF,$FF9B,$0488,$0000,$FFFF
	dc.w	$D9FD,$99E4,$0000,$FFFF,$FF9B,$4088,$0000,$FFFF
	dc.w	$DBFD,$8BE4,$0000,$FFFF,$D9FD,$9995,$0000,$FFFF
	dc.w	$6EE6,$0EA2,$0000,$7FFE,$2EBC,$2AA4,$0140,$3E3C
	dc.w	$0490,$0490,$0360,$0000,$03E0,$03E0,$0000,$0000
	dc.w	$00C0,$0000,$0000,$0000,$0000,$0000,$00C0,$00C0

brane5: dc.w 3,0,13,15,0,0
	dc.w	$341C,$2404,$0000,$3E7C,$4DBA,$0492,$0000,$7FFE
	dc.w	$BBEF,$89E1,$0000,$FFFF,$FF9B,$0088,$0000,$FFFF
	dc.w	$D9FD,$0984,$0000,$FFFF,$6EE6,$06A2,$0000,$7FFE
	dc.w	$2E3C,$2224,$01C0,$3FFC,$0528,$0408,$02D0,$02D0
	dc.w	$01B0,$0010,$0648,$0040,$02C0,$0200,$0130,$0120
	dc.w	$0080,$0000,$0060,$0060,$0040,$0000,$0080,$0080
	dc.w	$0040,$0000,$0080,$0080,$0000,$0000,$00C0,$00C0

brane6: dc.w 3,0,13,15,0,0
	dc.w	$2418,$2408,$0000,$3E7C,$597E,$081E,$0000,$7FFE
	dc.w	$BFEF,$91E1,$0000,$FFFF,$FDDB,$0488,$0000,$FFFF
	dc.w	$DDB9,$0988,$0000,$FFFF,$5EE6,$06A2,$0000,$7FFE
	dc.w	$2E7C,$2224,$0180,$3FBC,$0548,$0408,$0AB4,$02B0
	dc.w	$02B0,$0210,$0548,$0140,$0250,$0210,$05A8,$01A0
	dc.w	$0150,$0110,$02A0,$00A0,$0000,$0000,$00C0,$00C0
	dc.w	$0080,$0000,$0040,$0040,$0080,$0000,$0040,$0040
brane7: dc.w 3,0,13,15,0,0
	dc.w	$03A0,$0120,$0000,$07F0,$0DBC,$0920,$0000,$3FFE
	dc.w	$757E,$5048,$0000,$7FFF,$7AB6,$0AA4,$0000,$7FFF
	dc.w	$EF5A,$8C52,$0000,$FFFF,$EDDA,$8912,$0000,$FFFE
	dc.w	$5ED8,$1090,$0000,$7FF8,$3F60,$1440,$0000,$7FC0
	dc.w	$27A0,$0600,$1840,$23C0,$19C0,$1900,$0620,$0120
	dc.w	$0440,$0400,$1BA0,$01A0,$0840,$0800,$07A0,$01A0
	dc.w	$0020,$0000,$0050,$0050,$0020,$0000,$0010,$0010
brane8: dc.w 3,0,13,15,0,0
	dc.w	$07A0,$0120,$0000,$07F0,$2DB8,$0920,$0000,$3FFE
	dc.w	$737E,$4258,$0000,$7FFF,$7AF6,$22C4,$0000,$7FFF
	dc.w	$DEB6,$94A4,$0000,$FFFF,$DFBA,$9022,$0000,$FFFE
	dc.w	$5CD8,$1090,$0000,$7FF8,$3F60,$1440,$0000,$7FC0
	dc.w	$27A0,$0600,$1840,$23C0,$09A0,$0900,$1640,$0140
	dc.w	$0440,$0400,$0BA0,$01A0,$0080,$0000,$0140,$0140
	dc.w	$0080,$0000,$0040,$0040,$0040,$0000,$0080,$0080

spark1: dc.w 3,0,4,4,0,0
	dc.w	$0000,$A800,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$8800,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$A800,$0000,$0000
spark2: dc.w 3,0,6,6,0,0
	dc.w	$0000,$9200,$0000,$0000,$5400,$5400,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$4400,$C600,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$5400,$5400,$0000,$0000
	dc.w	$0000,$9200,$0000,$0000
spark3: dc.w 3,0,8,8,0,0
	dc.w	$0000,$8880,$0000,$0000,$4900,$4900,$0000,$0000
	dc.w	$0000,$0000,$2A00,$0000,$0000,$0000,$0000,$0000
	dc.w	$4100,$C180,$2200,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$2A00,$0000,$4900,$4900,$0000,$0000
	dc.w	$0000,$8880,$0000,$0000
spark4: dc.w 3,0,10,10,0,0
	dc.w	$0000,$8420,$0000,$0000,$4440,$4440,$0000,$0000
	dc.w	$0000,$0000,$2480,$0000,$1500,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$5140,$C060,$2080,$0000
	dc.w	$0000,$0000,$0000,$0000,$1500,$0000,$0000,$0000
	dc.w	$0000,$0000,$2480,$0000,$4440,$4440,$0000,$0000
	dc.w	$0000,$8420,$0000,$0000
dot1: dc.w 3,0,2,2,0,0
	dc.w	$0000,$0000,$4000,$0000,$4000,$0000,$A000,$0000
	dc.w	$0000,$0000,$4000,$0000
dot2: dc.w 3,0,2,2,0,0
	dc.w	$4000,$4000,$0000,$0000,$A000,$A000,$4000,$0000
	dc.w	$4000,$4000,$0000,$0000
dot3: dc.w 3,0,2,2,0,0
	dc.w	$0000,$4000,$0000,$0000,$4000,$E000,$0000,$0000
	dc.w	$0000,$4000,$0000,$0000
dot4: dc.w 3,0,2,2,0,0
	dc.w	$0000,$4000,$0000,$0000,$0000,$A000,$0000,$0000
	dc.w	$0000,$4000,$0000,$0000

bog1: dc.w 3,1,32,22,0,0
	dc.w	$7800,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$C000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$C0FC,$FF03,$FFFF,$FF03,$0000,$FC00,$FC00,$FC00
	dc.w	$83FF,$FC00,$FFFF,$FC00,$0000,$FC00,$CC00,$FC00
	dc.w	$EFCF,$F030,$FFFF,$F030,$C000,$3C00,$E400,$3C00
	dc.w	$9E01,$E1FE,$FFFF,$E1FE,$E000,$1C00,$FC00,$1C00
	dc.w	$FC00,$C3FF,$FFFF,$C3FF,$F000,$0C00,$FC00,$0C00
	dc.w	$7800,$47FF,$7FFF,$47FF,$7000,$8800,$F800,$8800
	dc.w	$7800,$07FF,$7FFF,$07FF,$7800,$8000,$F800,$8000
	dc.w	$7800,$00FC,$7800,$00FC,$7800,$0000,$7800,$0000
	dc.w	$7800,$00FC,$7800,$00FC,$7800,$0000,$7800,$0000
	dc.w	$7800,$00FC,$7800,$00FC,$7800,$0000,$7800,$0000
	dc.w	$3800,$00FC,$3800,$00FC,$7000,$0000,$7000,$0000
	dc.w	$3E01,$00FC,$3E01,$00FC,$F000,$0000,$F000,$0000
	dc.w	$1FFF,$0000,$1FFF,$0000,$E000,$0000,$E000,$0000
	dc.w	$0FFF,$0000,$0FFF,$0000,$C000,$0000,$C000,$0000
	dc.w	$03FF,$0303,$03FF,$0303,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FC00,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$E000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$F800,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$7000,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$6000,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$3C00,$3FFF,$3FFF,$3FFF,$0000,$F000,$F000,$F000
	dc.w	$0F00,$0FFF,$0FFF,$0FFF,$0000,$C000,$C000,$C000
	dc.w	$01C0,$01FE,$01FE,$01FE,$0000,$0000,$0000,$0000
	dc.w	$0080,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0048,$0078,$0078,$0078,$0000,$0000,$0000,$0000
	dc.w	$0078,$0078,$0078,$0078,$0000,$0000,$0000,$0000
	dc.w	$0080,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$00C0,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0380,$03FF,$03FF,$03FF,$0000,$0000,$0000,$0000
bog2: dc.w 3,1,32,22,0,0
	dc.w	$7800,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$C000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$C000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$8000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$C400,$FC00
	dc.w	$E000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$DC00,$FC00
	dc.w	$8000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$F000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$4000,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$3000,$3FFF,$3FFF,$3FFF,$0000,$F000,$F000,$F000
	dc.w	$0000,$00FC,$0000,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FC,$0000,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FC,$0000,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FC,$0000,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FC,$0000,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0000,$00FC,$0000,$00FC,$0000,$0000,$0000,$0000
	dc.w	$7FFF,$0000,$7FFF,$0000,$F800,$0000,$F800,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000,$FC00,$0000,$FC00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FC00,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$E000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$F800,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$7000,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$6000,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$3C00,$3FFF,$3FFF,$3FFF,$0000,$F000,$F000,$F000
	dc.w	$0F00,$0FFF,$0FFF,$0FFF,$0000,$C000,$C000,$C000
	dc.w	$01C0,$01FE,$01FE,$01FE,$0000,$0000,$0000,$0000
	dc.w	$0080,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0040,$0078,$0078,$0078,$0000,$0000,$0000,$0000
	dc.w	$0060,$0078,$0078,$0078,$0000,$0000,$0000,$0000
	dc.w	$0080,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$00C0,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0380,$03FF,$03FF,$03FF,$0000,$0000,$0000,$0000

roll1: dc.w 3,0,9,9,0,0
	dc.w	$4000,$0000,$0000,$7F80,$E000,$0000,$0000,$FFC0
	dc.w	$A000,$4000,$0000,$FFC0,$E000,$0000,$0000,$FFC0
	dc.w	$4000,$0000,$0000,$7F80,$3F80,$0000,$0000,$3F80
	dc.w	$0000,$0000,$0000,$3F80,$0000,$0000,$0000,$1FC0
	dc.w	$0000,$0000,$0000,$1FC0,$0000,$0000,$0000,$1FC0
roll2: dc.w 3,0,9,9,0,0
	dc.w	$4000,$0000,$0000,$7F80,$E000,$0000,$0000,$FFC0
	dc.w	$A000,$4000,$0000,$FFC0,$E000,$0000,$0000,$FFC0
	dc.w	$4000,$0000,$0000,$7F80,$3F80,$0000,$0000,$3F80
	dc.w	$0000,$0000,$0000,$3F80,$0000,$0000,$0000,$3F80
	dc.w	$0000,$0000,$0000,$7F00,$0000,$0000,$0000,$FE00
turd1: dc.w 3,0,10,7,0,0
	dc.w	$1E00,$1A00,$0400,$0000,$3F00,$3E00,$0100,$0000
	dc.w	$3F00,$3C00,$0300,$0000,$7F00,$1100,$6E00,$0000
	dc.w	$7F00,$1200,$6D00,$0000,$FE00,$4800,$B600,$0000
	dc.w	$FE00,$6C00,$9200,$0000,$FE00,$3400,$CA00,$0000
	dc.w	$7E00,$0800,$7600,$0000,$7E00,$6C00,$1200,$0000
	dc.w	$3800,$0000,$3800,$0000


turd2: dc.w 3,0,7,10,0,0
	dc.w	$7800,$1000,$6800,$0000,$FFC0,$C800,$37C0,$0000
	dc.w	$FFC0,$6340,$9C80,$0000,$FFE0,$E6C0,$1920,$0000
	dc.w	$FFE0,$F900,$06E0,$0000,$7FE0,$6340,$1CA0,$0000
	dc.w	$1FC0,$0640,$1980,$0000,$0700,$0000,$0700,$0000


turd3: dc.w 3,0,10,7,0,0
	dc.w	$1C00,$0000,$1C00,$0000,$7E00,$3600,$4800,$0000
	dc.w	$7E00,$1000,$6E00,$0000,$7F00,$2C00,$5300,$0000
	dc.w	$7F00,$3600,$4900,$0000,$7F00,$1200,$6D00,$0000
	dc.w	$FE00,$4800,$B600,$0000,$FE00,$8800,$7600,$0000
	dc.w	$FC00,$3C00,$C000,$0000,$FC00,$7C00,$8000,$0000
	dc.w	$7800,$5800,$2000,$0000


turd4: dc.w 3,0,7,10,0,0
	dc.w	$1C00,$0000,$1C00,$0000,$7F00,$4C00,$3300,$0000
	dc.w	$FFC0,$58C0,$A700,$0000,$FFE0,$13E0,$EC00,$0000
	dc.w	$FFE0,$6CE0,$9300,$0000,$7FE0,$58C0,$2720,$0000
	dc.w	$7FE0,$0260,$7D80,$0000,$03C0,$0100,$02C0,$0000


kaf1: dc.w 3,0,15,8,0,0
	dc.w	$0000,$0A80,$0A80,$0A80,$0280,$0A80,$0A80,$0A80
	dc.w	$0A80,$6A80,$4A80,$6A80,$4A80,$6A80,$4A80,$6A80
	dc.w	$4700,$EF80,$CF00,$EF80,$4300,$E780,$C700,$E780
	dc.w	$4000,$E300,$C200,$E300,$4200,$E300,$C200,$E300
	dc.w	$4200,$E300,$C200,$E300,$C200,$E300,$C200,$E300
	dc.w	$0200,$6300,$0200,$6300,$4200,$6300,$4200,$6300
	dc.w	$4200,$6300,$4200,$6300,$4000,$6000,$4000,$6000
	dc.w	$4000,$6000,$4000,$6000,$4000,$6000,$4000,$6000
kaf2: dc.w 3,0,15,8,0,0
	dc.w	$0000,$6000,$4000,$6000,$4000,$6000,$4000,$6000
	dc.w	$4000,$E000,$C000,$E000,$4000,$EA80,$CA80,$EA80
	dc.w	$4280,$EA80,$CA80,$EA80,$4A80,$EA80,$CA80,$EA80
	dc.w	$4A80,$EA80,$CA80,$EA80,$C700,$EF80,$CF00,$EF80
	dc.w	$0300,$6780,$0700,$6780,$4000,$6300,$4200,$6300
	dc.w	$4200,$6300,$4200,$6300,$4200,$6300,$4200,$6300
	dc.w	$4200,$6300,$4200,$6300,$4200,$6300,$4200,$6300
	dc.w	$0200,$0300,$0200,$0300,$0200,$0300,$0200,$0300
rng1: dc.w 3,0,12,13,0,0
	dc.w	$0000,$0000,$0FC0,$0000,$0790,$0790,$3860,$0000
	dc.w	$1878,$1878,$6000,$0000,$2018,$2018,$4000,$0000
	dc.w	$201C,$201C,$C000,$0000,$400C,$400C,$8000,$0000
	dc.w	$400C,$400C,$8000,$0000,$4004,$4004,$8008,$0000
	dc.w	$600C,$600C,$8010,$0000,$6008,$6008,$0010,$0000
	dc.w	$7818,$7818,$0060,$0000,$3E70,$3E70,$0180,$0000
	dc.w	$0FC0,$0FC0,$0000,$0000
rng2: dc.w 3,0,12,7,0,0
	dc.w	$0000,$0000,$3C00,$0000,$0200,$0200,$7C00,$0000
	dc.w	$0600,$0600,$6000,$0000,$0700,$0700,$E000,$0000
	dc.w	$0100,$0100,$C200,$0000,$0100,$0100,$C200,$0000
	dc.w	$0100,$0100,$C200,$0000,$0100,$0100,$C200,$0000
	dc.w	$4100,$4100,$8200,$0000,$6300,$6300,$8400,$0000
	dc.w	$6200,$6200,$0400,$0000,$6600,$6600,$1800,$0000
	dc.w	$3C00,$3C00,$0000,$0000
msh1: dc.w 3,0,11,10,0,0
	dc.w	$0000,$0800,$0400,$0000,$0000,$3D00,$0200,$0000
	dc.w	$0000,$6FC0,$1000,$0000,$0000,$47E0,$3800,$0000
	dc.w	$0000,$EF60,$1080,$0000,$0000,$7E20,$81C0,$0000
	dc.w	$0600,$3F40,$C680,$1F00,$0600,$0F00,$0600,$0F00
	dc.w	$0700,$0700,$0700,$0700,$0A00,$0F00,$0A00,$0F00
	dc.w	$0B00,$0F00,$0B00,$0F00,$0600,$0600,$0600,$0600
msh2: dc.w 3,0,11,11,0,0
	dc.w	$0000,$0400,$0200,$0000,$0000,$2600,$1980,$0000
	dc.w	$0000,$67C0,$1800,$0000,$0000,$7FE0,$8000,$0000
	dc.w	$0000,$7F60,$8080,$0000,$0000,$7E30,$01C0,$0000
	dc.w	$0600,$3F60,$0680,$1F00,$0600,$0F00,$0600,$0F00
	dc.w	$0700,$0700,$0700,$0700,$0A00,$0F00,$0A00,$0F00
	dc.w	$0D00,$0F00,$0D00,$0F00,$0400,$0600,$0400,$0600
chp1: dc.w 3,0,13,12,0,0
	dc.w	$0000,$3300,$0000,$3300,$0000,$7F80,$4080,$7F80
	dc.w	$4080,$7F80,$4080,$7F80,$0000,$3F00,$0000,$3F00
	dc.w	$1000,$7F80,$5080,$7F80,$4480,$7F80,$4480,$7F80
	dc.w	$1000,$3F00,$1000,$3F00,$0000,$FFC0,$C0C0,$FFC0
	dc.w	$54A0,$FFE0,$D4E0,$FFE0,$1040,$BF60,$9060,$BF60
	dc.w	$0010,$BF30,$8030,$BF30,$0020,$8030,$8030,$8030
	dc.w	$0008,$8018,$8018,$8018,$0000,$8000,$8000,$8000
chp2: dc.w 3,0,13,12,0,0
	dc.w	$0000,$0660,$0000,$0660,$0000,$0FF0,$0810,$0FF0
	dc.w	$0810,$0FF0,$0810,$0FF0,$0000,$07E0,$0000,$07E0
	dc.w	$0200,$0FF0,$0A10,$0FF0,$0890,$0FF0,$0890,$0FF0
	dc.w	$0200,$07E0,$0200,$07E0,$0000,$1FF8,$1818,$1FF8
	dc.w	$2A90,$3FF8,$3A98,$3FF8,$1200,$37E8,$3208,$37E8
	dc.w	$4000,$67E8,$6008,$67E8,$2000,$6008,$6008,$6008
	dc.w	$8000,$C008,$C008,$C008,$0000,$0008,$0008,$0008
tom1: dc.w 3,0,10,10,0,0
	dc.w	$0100,$01C0,$01C0,$0000,$0000,$1D80,$1D80,$0000
	dc.w	$0000,$7FC0,$0700,$0000,$0000,$FFE0,$2000,$2000
	dc.w	$0000,$FFE0,$4000,$4000,$0000,$FFE0,$0000,$0000
	dc.w	$0000,$FFC0,$0000,$0000,$0000,$FFC0,$0000,$0000
	dc.w	$0000,$7FC0,$0000,$0000,$0000,$3F80,$0000,$0000
	dc.w	$0000,$1F00,$0000,$0000
tom2: dc.w 3,0,10,10,0,0
	dc.w	$0400,$0700,$0700,$0000,$0000,$7600,$7600,$0000
	dc.w	$0000,$7FC0,$1C00,$0000,$0000,$FFE0,$2000,$2000
	dc.w	$0000,$FFE0,$4000,$4000,$0000,$FFE0,$0000,$0000
	dc.w	$0000,$7FE0,$0000,$0000,$0000,$7FE0,$0000,$0000
	dc.w	$0000,$7FC0,$0000,$0000,$0000,$3F80,$0000,$0000
	dc.w	$0000,$1F00,$0000,$0000
ban1: dc.w 3,0,10,5,0,0
	dc.w	$0000,$0C00,$0000,$0C00,$0000,$0800,$1000,$0800
	dc.w	$0000,$0000,$3000,$0000,$2000,$2000,$5000,$0000
	dc.w	$4000,$4000,$2000,$0000,$4000,$4000,$A000,$0000
	dc.w	$4000,$4000,$A000,$0000,$4000,$4000,$A000,$0000
	dc.w	$4000,$4000,$A000,$0000,$2000,$2000,$5000,$0000
	dc.w	$1000,$1000,$2000,$0000
ban2: dc.w 3,0,10,5,0,0
	dc.w	$0000,$C000,$0000,$C000,$0000,$4000,$2000,$4000
	dc.w	$0000,$0000,$3000,$0000,$1000,$1000,$2800,$0000
	dc.w	$0800,$0800,$1000,$0000,$0800,$0800,$1400,$0000
	dc.w	$0800,$0800,$1400,$0000,$0800,$0800,$1400,$0000
	dc.w	$0800,$0800,$1400,$0000,$1000,$1000,$2800,$0000
	dc.w	$2000,$2000,$1000,$0000
mine: dc.w 3,0,6,14,0,0
	dc.w	$0440,$0280,$0000,$0000,$0000,$0000,$0100,$0000
	dc.w	$3398,$0820,$0000,$0000,$0380,$0100,$0440,$0000
	dc.w	$3398,$0820,$0000,$0000,$0000,$0000,$0100,$0000
	dc.w	$0440,$0280,$0000,$0000

bbul1: dc.w 3,0,5,11,0,0
	dc.w	$0000,$0000,$2040,$0000,$1F80,$1F80,$6060,$0000
	dc.w	$79E0,$3FC0,$8010,$0000,$79E0,$3FC0,$8010,$0000
	dc.w	$1F80,$1F80,$6060,$0000,$0000,$0000,$2040,$0000
bbul2: dc.w 3,0,11,5,0,0
	dc.w	$0000,$0000,$3000,$0000,$3000,$0000,$4800,$0000
	dc.w	$3000,$3000,$CC00,$0000,$7800,$7800,$0000,$0000
	dc.w	$7800,$7800,$0000,$0000,$4800,$7800,$0000,$0000
	dc.w	$4800,$7800,$0000,$0000,$7800,$7800,$0000,$0000
	dc.w	$7800,$7800,$0000,$0000,$3000,$3000,$CC00,$0000
	dc.w	$3000,$0000,$4800,$0000,$0000,$0000,$3000,$0000
bbul3: dc.w 3,0,9,9,0,0
	dc.w	$0000,$0000,$0580,$0000,$0180,$0000,$0240,$0000
	dc.w	$0780,$0700,$0040,$0000,$0F00,$0F00,$0080,$0000
	dc.w	$1300,$1F00,$0040,$0000,$3200,$3E00,$8000,$0000
	dc.w	$3C00,$3C00,$4000,$0000,$7800,$3800,$8000,$0000
	dc.w	$6000,$0000,$9000,$0000,$0000,$0000,$6800,$0000
bbul4: dc.w 3,0,9,9,0,0
	dc.w	$0000,$0000,$6800,$0000,$6000,$0000,$9000,$0000
	dc.w	$7800,$3800,$8000,$0000,$3C00,$3C00,$4000,$0000
	dc.w	$3200,$3E00,$8000,$0000,$1300,$1F00,$0040,$0000
	dc.w	$0F00,$0F00,$0080,$0000,$0780,$0700,$0040,$0000
	dc.w	$0180,$0000,$0240,$0000,$0000,$0000,$0580,$0000

luv1: dc.w 3,0,5,7,0,0
	dc.w	$0000,$6600,$0000,$0000,$0000,$FF00,$4000,$4000
	dc.w	$0000,$FF00,$0000,$0000,$0000,$7E00,$0000,$0000
	dc.w	$0000,$3C00,$0000,$0000,$0000,$1800,$0000,$0000
luv2: dc.w 3,0,4,4,0,0
	dc.w	$0000,$5000,$0000,$0000,$0000,$F800,$4000,$4000
	dc.w	$0000,$F800,$0000,$0000,$0000,$7000,$0000,$0000
	dc.w	$0000,$2000,$0000,$0000
gnum1: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FFC0,$6380,$0000,$0000,$F7C0,$6380,$0000,$0000
	dc.w	$9840,$0000,$6780,$0000,$FFC0,$6780,$0000,$0000
	dc.w	$FFC0,$6780,$0000,$0000,$BAC0,$6780,$0000,$0000
	dc.w	$9840,$6780,$0000,$0000,$8040,$7F80,$0000,$0000
	dc.w	$7F80,$0000,$0000,$0000
gnum2: dc.w 3,0,10,12,0,0
	dc.w	$0E00,$0000,$0000,$0000,$1F00,$0E00,$0000,$0000
	dc.w	$1F00,$0E00,$0000,$0000,$1F00,$0E00,$0000,$0000
	dc.w	$2100,$0000,$1E00,$0000,$3F00,$1E00,$0000,$0000
	dc.w	$3F00,$1E00,$0000,$0000,$2B00,$1E00,$0000,$0000
	dc.w	$2100,$1E00,$0000,$0000,$2100,$1E00,$0000,$0000
	dc.w	$1E00,$0000,$0000,$0000
gnum3: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FFC0,$6380,$0000,$0000,$F7C0,$6380,$0000,$0000
	dc.w	$6440,$0000,$0380,$0000,$7FC0,$0380,$0000,$0000
	dc.w	$FFC0,$7F80,$0000,$0000,$AF80,$7800,$0000,$0000
	dc.w	$8640,$7980,$0000,$0000,$8040,$7F80,$0000,$0000
	dc.w	$7F80,$0000,$0000,$0000
gnum4: dc.w 3,0,10,12,0,0
	dc.w	$7F00,$0000,$0000,$0000,$FF80,$7F00,$0000,$0000
	dc.w	$FF80,$6700,$0000,$0000,$7F80,$0700,$0000,$0000
	dc.w	$4040,$0000,$3F80,$0000,$3FC0,$0780,$0000,$0000
	dc.w	$6FC0,$0780,$0000,$0000,$BAC0,$6780,$0000,$0000
	dc.w	$9840,$6780,$0000,$0000,$8040,$7F80,$0000,$0000
	dc.w	$7F80,$0000,$0000,$0000
gnum5: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FFC0,$6380,$0000,$0000,$F7C0,$6380,$0000,$0000
	dc.w	$9440,$0000,$6380,$0000,$FFC0,$6380,$0000,$0000
	dc.w	$FFE0,$7FC0,$0000,$0000,$7AC0,$0780,$0000,$0000
	dc.w	$0840,$0780,$0000,$0000,$0840,$0780,$0000,$0000
	dc.w	$0780,$0000,$0000,$0000
gnum6: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FF80,$7000,$0000,$0000,$FF80,$7000,$0000,$0000
	dc.w	$8040,$0000,$7F80,$0000,$7FC0,$0780,$0000,$0000
	dc.w	$6FC0,$0780,$0000,$0000,$DD40,$6780,$0000,$0000
	dc.w	$9840,$6780,$0000,$0000,$8040,$7F80,$0000,$0000
	dc.w	$7F80,$0000,$0000,$0000
gnum7: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FFC0,$6380,$0000,$0000,$FF80,$6000,$0000,$0000
	dc.w	$8040,$0000,$7F80,$0000,$FFC0,$6780,$0000,$0000
	dc.w	$FFC0,$6780,$0000,$0000,$DD40,$6780,$0000,$0000
	dc.w	$9840,$6780,$0000,$0000,$8040,$7F80,$0000,$0000
	dc.w	$7F80,$0000,$0000,$0000
gnum8: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FFC0,$6380,$0000,$0000,$67C0,$0380,$0000,$0000
	dc.w	$0840,$0000,$0780,$0000,$0FC0,$0780,$0000,$0000
	dc.w	$0FC0,$0780,$0000,$0000,$0D40,$0780,$0000,$0000
	dc.w	$0840,$0780,$0000,$0000,$0840,$0780,$0000,$0000
	dc.w	$0780,$0000,$0000,$0000
gnum9: dc.w 3,0,10,12,0,0
	dc.w	$3F00,$0000,$0000,$0000,$7F80,$3F00,$0000,$0000
	dc.w	$7F80,$3700,$0000,$0000,$7F80,$3700,$0000,$0000
	dc.w	$8040,$0000,$7F80,$0000,$FFC0,$6780,$0000,$0000
	dc.w	$FFC0,$6780,$0000,$0000,$DD40,$6780,$0000,$0000
	dc.w	$9840,$6780,$0000,$0000,$8040,$7F80,$0000,$0000
	dc.w	$7F80,$0000,$0000,$0000
gnum10: dc.w 3,0,10,12,0,0
	dc.w	$7F80,$0000,$0000,$0000,$FFC0,$7F80,$0000,$0000
	dc.w	$FFC0,$6380,$0000,$0000,$F7C0,$6380,$0000,$0000
	dc.w	$9440,$0000,$6380,$0000,$FFC0,$6380,$0000,$0000
	dc.w	$FFC0,$7F80,$0000,$0000,$7D40,$0780,$0000,$0000
	dc.w	$0840,$0780,$0000,$0000,$0840,$0780,$0000,$0000
	dc.w	$0780,$0000,$0000,$0000

pauo1: dc.w 3,1,26,30,0,0
	dc.w	$0080,$0080,$0080,$0080,$0000,$0000,$0000,$0000
	dc.w	$0104,$0104,$0104,$0104,$0000,$0000,$0000,$0000
	dc.w	$0204,$0204,$0204,$0204,$0000,$0000,$0000,$0000
	dc.w	$0202,$0202,$0202,$0202,$0000,$0000,$0000,$0000
	dc.w	$0101,$0101,$0101,$0101,$0000,$0000,$0000,$0000
	dc.w	$0001,$0001,$0001,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0FFF,$0FFF,$0FFF,$0FFF,$C000,$C000,$C000,$C000
	dc.w	$7FFF,$7FFF,$7800,$7800,$F800,$F800,$7800,$7800
	dc.w	$3FFF,$FFFF,$C000,$C000,$F000,$FC00,$0C00,$0C00
	dc.w	$0FFF,$FFFF,$F000,$F000,$C000,$FC00,$3C00,$3C00
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$01F8,$FDF8,$FDF8,$FDF8
	dc.w	$0000,$FFFF,$FFFF,$FFFF,$03FC,$FFFC,$FFFC,$FFFC
	dc.w	$8000,$FFFF,$FFFF,$FFFF,$060E,$FFFE,$FE1E,$FFFE
	dc.w	$F000,$FFFF,$FFFF,$FFFF,$3C04,$FE1E,$FC1C,$FE1E
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FC04,$FC0E,$FC0C,$FC0E
	dc.w	$FFFF,$88A8,$88A8,$88A8,$FC04,$8C0E,$8C0C,$8C0E
	dc.w	$FFFF,$AAAB,$AAAB,$AAAB,$FC0C,$BC3C,$BC3C,$BC3C
	dc.w	$FFFF,$88A8,$88A8,$88A8,$FC38,$9CF8,$9CF8,$9CF8
	dc.w	$FFFF,$BAAE,$BAAE,$BAAE,$FC70,$BFF0,$BFF0,$BFF0
	dc.w	$FFFF,$BA88,$BA88,$BA88,$FD80,$8FC0,$8F80,$8FC0
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FE00,$FF00,$FE00,$FF00
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FC00,$FC00,$FC00,$FC00
	dc.w	$7FFF,$FFFF,$7FFF,$FFFF,$F800,$FC00,$F800,$FC00
	dc.w	$0FFF,$FFFF,$0FFF,$FFFF,$C000,$FC00,$C000,$FC00
	dc.w	$0000,$7FFF,$0000,$7FFF,$0000,$F800,$0000,$F800
	dc.w	$0000,$0FFF,$0000,$0FFF,$0000,$C000,$0000,$C000

pauo2: dc.w 3,1,32,23,0,0
	dc.w	$0000,$0000,$FFFF,$0000,$0000,$0000,$FF00,$0000
	dc.w	$7FFF,$7FFF,$8000,$7FFF,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7FFF,$8000,$7FFF,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7FC3,$8000,$7FC3,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7F81,$8000,$7F81,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7F00,$8000,$7F00,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7F00,$8000,$7F00,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7F00,$8000,$7F00,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7F81,$8000,$7F81,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7FC3,$8000,$7FC3,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7800,$8000,$7800,$FF00,$1F00,$0000,$1E00
	dc.w	$7FFF,$7800,$8000,$7800,$FF00,$1F00,$0000,$1E00
	dc.w	$4454,$7BAB,$8000,$4000,$4700,$BF00,$0000,$0600
	dc.w	$5555,$7AAA,$8000,$5000,$DF00,$2F00,$0000,$0E00
	dc.w	$4454,$7BAB,$8000,$4000,$4F00,$BF00,$0000,$0E00
	dc.w	$5D57,$73A8,$8000,$5100,$5F00,$AF00,$0000,$0E00
	dc.w	$5D44,$73BB,$8000,$5100,$4700,$BF00,$0000,$0600
	dc.w	$7FFF,$6100,$8000,$6100,$FF00,$8700,$0000,$8600
	dc.w	$7FFF,$6300,$8000,$6300,$FF00,$C700,$0000,$C600
	dc.w	$7FFF,$6300,$8000,$6300,$FF00,$C700,$0000,$C600
	dc.w	$7FFF,$7F00,$8000,$7F00,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7E00,$8000,$7E00,$FF00,$7F00,$0000,$7E00
	dc.w	$7FFF,$7E00,$8000,$7E00,$FF00,$7F00,$0000,$7E00
	dc.w	$7FFF,$7E18,$8000,$7E18,$FF00,$7F00,$0000,$7E00
	dc.w	$7FFF,$7E18,$8000,$7E18,$FF00,$7F00,$0000,$7E00
	dc.w	$7FFF,$7C18,$8000,$7C18,$FF00,$3F00,$0000,$3E00
	dc.w	$7FFF,$7C18,$8000,$7C18,$FF00,$3F00,$0000,$3E00
	dc.w	$7FFF,$7C3C,$8000,$7C3C,$FF00,$3F00,$0000,$3E00
	dc.w	$7FFF,$783C,$8000,$783C,$FF00,$1F00,$0000,$1E00
	dc.w	$7FFF,$783C,$8000,$783C,$FF00,$1F00,$0000,$1E00
	dc.w	$7FFF,$7FFF,$8000,$7FFF,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7FFF,$8000,$7FFF,$FF00,$FF00,$0000,$FE00
	dc.w	$7FFF,$7FFF,$8000,$0000,$FF00,$FF00,$0000,$0000
pauo3: dc.w 3,1,26,18,0,0
	dc.w	$0000,$03E0,$03E0,$03E0,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0410,$07F0,$03E0,$03E0,$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$03E0,$07F0,$0410,$0410,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$4000,$4000,$4000,$4000
	dc.w	$EEAE,$0150,$0150,$0150,$E000,$0000,$0000,$0000
	dc.w	$AAA8,$0550,$0550,$0550,$8000,$0000,$0000,$0000
	dc.w	$EEAE,$0150,$0150,$0150,$C000,$0000,$0000,$0000
	dc.w	$8AA2,$0550,$0550,$0550,$8000,$0000,$0000,$0000
	dc.w	$8AEF,$0511,$0511,$0511,$E000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$8000,$8000,$8000,$8000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0000,$07F0,$07F0,$07F0,$0000,$0000,$0000,$0000
	dc.w	$0410,$07F0,$07F0,$07F0,$4000,$4000,$4000,$4000
	dc.w	$02A0,$03E0,$02A0,$02A0,$0000,$0000,$0000,$0000
	dc.w	$0040,$01C0,$0040,$01C0,$8000,$8000,$8000,$8000
	dc.w	$0002,$0022,$0002,$0022,$0000,$0000,$0000,$0000
pauo4: dc.w 3,1,32,21,0,0
	dc.w	$7800,$7FFF,$7FFF,$7FFF,$0000,$F800,$F800,$F800
	dc.w	$C000,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$C0FC,$FF03,$FFFF,$FF03,$0000,$FC00,$FC00,$FC00
	dc.w	$83FF,$FC00,$FFFF,$FC00,$0000,$FC00,$CC00,$FC00
	dc.w	$EFCF,$F030,$FFFF,$F030,$C000,$3C00,$E400,$3C00
	dc.w	$9E01,$E1FE,$FFFF,$E1FE,$E000,$1C00,$FC00,$1C00
	dc.w	$FC00,$C3FF,$FFFF,$C3FF,$F000,$0C00,$FC00,$0C00
	dc.w	$7800,$47FF,$7FFF,$47FF,$7000,$8800,$F800,$8800
	dc.w	$7800,$07FF,$7FFF,$07FF,$7800,$8000,$F800,$8000
	dc.w	$7800,$00FC,$7800,$00FC,$7800,$0000,$7800,$0000
	dc.w	$7800,$00FC,$7800,$00FC,$7800,$0000,$7800,$0000
	dc.w	$7800,$00FC,$7800,$00FC,$7800,$0000,$7800,$0000
	dc.w	$3800,$00FC,$3800,$00FC,$7000,$0000,$7000,$0000
	dc.w	$3E01,$00FC,$3E01,$00FC,$F000,$0000,$F000,$0000
	dc.w	$1FFF,$0000,$1FFF,$0000,$E000,$0000,$E000,$0000
	dc.w	$0FFF,$0000,$0FFF,$0000,$C000,$0000,$C000,$0000
	dc.w	$03FF,$0303,$03FF,$0303,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FC00,$FFFF,$FFFF,$FFFF,$0000,$FC00,$FC00,$FC00
	dc.w	$FBAB,$C454,$C454,$C454,$B800,$4400,$4400,$4400
	dc.w	$FAAA,$D555,$D555,$D555,$2000,$DC00,$DC00,$DC00
	dc.w	$7BAB,$4454,$4454,$4454,$B000,$4800,$4800,$4800
	dc.w	$62A8,$5D57,$5D57,$5D57,$A000,$5800,$5800,$5800
	dc.w	$3EBB,$1D44,$1D44,$1D44,$B800,$4000,$4000,$4000
	dc.w	$0F00,$0FFF,$0FFF,$0FFF,$0000,$C000,$C000,$C000
	dc.w	$01C0,$01FE,$01FE,$01FE,$0000,$0000,$0000,$0000
	dc.w	$0080,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0048,$0078,$0078,$0078,$0000,$0000,$0000,$0000
	dc.w	$0078,$0078,$0078,$0078,$0000,$0000,$0000,$0000
	dc.w	$0080,$00F8,$00F8,$00F8,$0000,$0000,$0000,$0000
	dc.w	$00C0,$00FC,$00FC,$00FC,$0000,$0000,$0000,$0000
	dc.w	$0380,$03FF,$03FF,$03FF,$0000,$0000,$0000,$0000

bsh1: dc.w 3,0,12,14,0,0
	dc.w	$0000,$3B30,$3B30,$3B30,$20A0,$7FF8,$7FF8,$7FF8
	dc.w	$0100,$FFFC,$FFFC,$FFFC,$2900,$7FFC,$7FFC,$7FFC
	dc.w	$4490,$7FFC,$7FFC,$7FFC,$0408,$FFFC,$FFFC,$FFFC
	dc.w	$0800,$7FF8,$7FF8,$7FF8,$0000,$0E30,$0E30,$0E30
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0C30,$0000,$0C30
	dc.w	$0000,$1C38,$0000,$1C38,$0000,$1818,$0000,$1818
	dc.w	$0000,$1818,$0000,$1818
bsh2: dc.w 3,0,12,14,0,0
	dc.w	$0000,$3B30,$3B30,$3B30,$20A0,$7FF8,$7FF8,$7FF8
	dc.w	$0100,$FFFC,$FFFC,$FFFC,$2900,$7FFC,$7FFC,$7FFC
	dc.w	$4490,$7FFC,$7FFC,$7FFC,$0408,$FFFC,$FFFC,$FFFC
	dc.w	$0800,$7FF8,$7FF8,$7FF8,$0000,$0E30,$0E30,$0E30
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0C30,$0000,$0C30
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0C30,$0000,$0C30
	dc.w	$0000,$0C30,$0000,$0C30
bsh3: dc.w 3,0,12,14,0,0
	dc.w	$3B30,$0000,$0000,$0000,$7FF8,$0000,$0000,$0000
	dc.w	$FFFC,$0000,$0000,$0000,$7FFC,$0000,$0000,$0000
	dc.w	$7FFC,$0000,$0000,$0000,$FFFC,$0000,$0000,$0000
	dc.w	$7FF8,$0000,$0000,$0000,$0E30,$0000,$0000,$0000
	dc.w	$0C30,$0000,$0000,$0000,$0C30,$0000,$0000,$0000
	dc.w	$1C38,$0000,$0000,$0000,$1818,$0000,$0000,$0000
	dc.w	$1818,$0000,$0000,$0000
bsh4: dc.w 3,0,12,14,0,0
	dc.w	$3B30,$0000,$0000,$0000,$7FF8,$0000,$0000,$0000
	dc.w	$FFFC,$0000,$0000,$0000,$7FFC,$0000,$0000,$0000
	dc.w	$7FFC,$0000,$0000,$0000,$FFFC,$0000,$0000,$0000
	dc.w	$7FF8,$0000,$0000,$0000,$0E30,$0000,$0000,$0000
	dc.w	$0C30,$0000,$0000,$0000,$0C30,$0000,$0000,$0000
	dc.w	$0C30,$0000,$0000,$0000,$0C30,$0000,$0000,$0000
	dc.w	$0C30,$0000,$0000,$0000
bsh5: dc.w 3,1,17,18,0,0
	dc.w	$0380,$0380,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$16C0,$1EC0,$1800,$1800,$0000,$0000,$0000,$0000
	dc.w	$50C0,$7CC0,$6C00,$7C00,$0000,$0000,$0000,$0000
	dc.w	$C180,$FD80,$FC00,$FC00,$0000,$0000,$0000,$0000
	dc.w	$7400,$FC00,$7C00,$FC00,$0000,$0000,$0000,$0000
	dc.w	$1200,$1F9B,$1F9B,$1F9B,$0000,$8000,$8000,$8000
	dc.w	$10A0,$1FFF,$1FFF,$1FFF,$8000,$C000,$C000,$C000
	dc.w	$1010,$1FFF,$1FFF,$1FFF,$0000,$E000,$E000,$E000
	dc.w	$0812,$1FFF,$1FFF,$1FFF,$8000,$C000,$C000,$C000
	dc.w	$1124,$1FFF,$1FFF,$1FFF,$4000,$C000,$C000,$C000
	dc.w	$0204,$0FFF,$0FFF,$0FFF,$0000,$E000,$E000,$E000
	dc.w	$0002,$03FF,$03FF,$03FF,$0000,$C000,$C000,$C000
	dc.w	$0000,$018E,$018E,$018E,$0000,$0000,$0000,$0000
	dc.w	$0000,$0186,$0000,$0186,$0000,$0000,$0000,$0000
	dc.w	$0000,$0186,$0000,$0186,$0000,$0000,$0000,$0000
	dc.w	$0000,$0186,$0000,$0186,$0000,$0000,$0000,$0000
	dc.w	$0000,$0186,$0000,$0186,$0000,$0000,$0000,$0000
	dc.w	$0000,$0186,$0000,$0186,$0000,$0000,$0000,$0000
bsh6: dc.w 3,1,16,19,0,0
	dc.w	$0380,$0380,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$16C0,$1EC0,$1800,$1800,$0000,$0000,$0000,$0000
	dc.w	$50C0,$7CC0,$6C00,$7C00,$0000,$0000,$0000,$0000
	dc.w	$C180,$FD80,$FC00,$FC00,$0000,$0000,$0000,$0000
	dc.w	$7500,$FFCD,$7FCD,$FFCD,$0000,$C000,$C000,$C000
	dc.w	$C850,$CFFF,$CFFF,$CFFF,$4000,$E000,$E000,$E000
	dc.w	$0808,$0FFF,$0FFF,$0FFF,$0000,$F000,$F000,$F000
	dc.w	$0409,$0FFF,$0FFF,$0FFF,$4000,$E000,$E000,$E000
	dc.w	$0892,$0FFF,$0FFF,$0FFF,$2000,$E000,$E000,$E000
	dc.w	$0102,$07FF,$07FF,$07FF,$0000,$F000,$F000,$F000
	dc.w	$0001,$01FF,$01FF,$01FF,$0000,$E000,$E000,$E000
	dc.w	$0000,$00C7,$00C7,$00C7,$0000,$0000,$0000,$0000
	dc.w	$0000,$00C3,$0000,$00C3,$0000,$0000,$0000,$0000
	dc.w	$0000,$00C3,$0000,$00C3,$0000,$0000,$0000,$0000
	dc.w	$0000,$01C3,$0000,$01C3,$0000,$8000,$0000,$8000
	dc.w	$0000,$0181,$0000,$0181,$0000,$8000,$0000,$8000
	dc.w	$0000,$0181,$0000,$0181,$0000,$8000,$0000,$8000
bsh7: dc.w 3,1,17,18,0,0
	dc.w	$0038,$0038,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$006D,$006F,$0003,$0003,$0000,$0000,$0000,$0000
	dc.w	$0061,$0067,$0006,$0007,$4000,$C000,$C000,$C000
	dc.w	$0030,$0037,$0007,$0007,$6000,$E000,$E000,$E000
	dc.w	$0005,$0007,$0007,$0007,$C000,$E000,$C000,$E000
	dc.w	$0009,$3B3F,$3B3F,$3B3F,$0000,$0000,$0000,$0000
	dc.w	$20A1,$7FFF,$7FFF,$7FFF,$0000,$0000,$0000,$0000
	dc.w	$0101,$FFFF,$FFFF,$FFFF,$0000,$0000,$0000,$0000
	dc.w	$2902,$7FFF,$7FFF,$7FFF,$0000,$0000,$0000,$0000
	dc.w	$4491,$7FFF,$7FFF,$7FFF,$0000,$0000,$0000,$0000
	dc.w	$0408,$FFFE,$FFFE,$FFFE,$0000,$0000,$0000,$0000
	dc.w	$0800,$7FF8,$7FF8,$7FF8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0E30,$0E30,$0E30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
bsh8: dc.w 3,1,16,19,0,0
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0036,$0037,$0001,$0001,$8000,$8000,$8000,$8000
	dc.w	$0030,$0033,$0003,$0003,$A000,$E000,$6000,$E000
	dc.w	$0018,$001B,$0003,$0003,$3000,$F000,$F000,$F000
	dc.w	$000A,$3B3F,$3B3F,$3B3F,$E000,$F000,$E000,$F000
	dc.w	$20A1,$7FFF,$7FFF,$7FFF,$3000,$3000,$3000,$3000
	dc.w	$0101,$FFFF,$FFFF,$FFFF,$0000,$0000,$0000,$0000
	dc.w	$2902,$7FFF,$7FFF,$7FFF,$0000,$0000,$0000,$0000
	dc.w	$4491,$7FFF,$7FFF,$7FFF,$0000,$0000,$0000,$0000
	dc.w	$0408,$FFFE,$FFFE,$FFFE,$0000,$0000,$0000,$0000
	dc.w	$0800,$7FF8,$7FF8,$7FF8,$0000,$0000,$0000,$0000
	dc.w	$0000,$0E30,$0E30,$0E30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
	dc.w	$0000,$0C30,$0000,$0C30,$0000,$0000,$0000,$0000
	dc.w	$0000,$1C38,$0000,$1C38,$0000,$0000,$0000,$0000
	dc.w	$0000,$1818,$0000,$1818,$0000,$0000,$0000,$0000
	dc.w	$0000,$1818,$0000,$1818,$0000,$0000,$0000,$0000

teap1: dc.w 3,0,7,13,0,0
	dc.w	$0000,$0100,$0000,$0000,$0000,$C7C0,$0000,$0000
	dc.w	$0000,$6018,$0000,$0000,$0000,$6FE4,$0000,$0000
	dc.w	$0000,$7C64,$0380,$0000,$0000,$3EE8,$0100,$0000
	dc.w	$0000,$0EF0,$0100,$0000,$0000,$07C0,$0000,$0000
teap2: dc.w 3,0,7,13,0,0
	dc.w	$0000,$0200,$0000,$0000,$0000,$0F8C,$0000,$0000
	dc.w	$0000,$6018,$0000,$0000,$0000,$9FD8,$0000,$0000
	dc.w	$0000,$98F8,$0700,$0000,$0000,$5DF0,$0200,$0000
	dc.w	$0000,$3DC0,$0200,$0000,$0000,$0F80,$0000,$0000
teap3: dc.w 3,0,16,14,0,0
	dc.w	$0000,$0100,$0000,$0000,$0000,$1F00,$0000,$0000
	dc.w	$0000,$0700,$0000,$0000,$0000,$0180,$0000,$0000
	dc.w	$5000,$500C,$5000,$5000,$0000,$0012,$0000,$0000
	dc.w	$0800,$0872,$0800,$0800,$4000,$41DC,$4020,$4000
	dc.w	$8000,$833C,$80C0,$8000,$0000,$01DC,$0020,$0000
	dc.w	$0000,$07F8,$0000,$0000,$0000,$0FE0,$0000,$0000
	dc.w	$0000,$0C00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0400,$0400,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0080,$0080,$0000,$0000
teap4: dc.w 3,0,16,14,0,0
	dc.w	$0000,$0100,$0000,$0000,$0000,$01F0,$0000,$0000
	dc.w	$0000,$01C0,$0000,$0000,$0000,$0300,$0000,$0000
	dc.w	$0014,$6014,$0014,$0014,$0000,$9000,$0000,$0000
	dc.w	$0020,$9C20,$0020,$0020,$0004,$7704,$0804,$0004
	dc.w	$0002,$7982,$0602,$0002,$0000,$7700,$0800,$0000
	dc.w	$0000,$3FC0,$0000,$0000,$0000,$0FE0,$0000,$0000
	dc.w	$0000,$0060,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0040,$0040,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0200,$0200,$0000,$0000
eyb1: dc.w 3,0,5,8,0,0
	dc.w	$0800,$1F00,$0A00,$1B00,$1100,$3F80,$1B00,$3B80
	dc.w	$0280,$FF80,$1600,$1780,$0080,$3F80,$2800,$2980
	dc.w	$0500,$1F80,$1700,$1780,$0600,$0F00,$0600,$0700
eyb2: dc.w 3,0,5,8,0,0
	dc.w	$0800,$7C00,$2800,$6C00,$4400,$FE00,$6C00,$EE00
	dc.w	$A000,$FF80,$3400,$F400,$8000,$FE00,$0A00,$CA00
	dc.w	$5000,$FC00,$7400,$F400,$3000,$7800,$3000,$7000
eyb3: dc.w 3,0,11,13,0,0
	dc.w	$0540,$1FE0,$0540,$1560,$11B0,$3FF0,$19B0,$19B0
	dc.w	$4000,$7FF8,$6FA0,$6FA0,$4788,$FFFC,$5858,$DFDC
	dc.w	$8FC4,$FFFC,$B024,$BFE4,$4FC8,$FCFC,$5038,$5CF8
	dc.w	$EFCC,$FCFC,$F03C,$FCFC,$2FC4,$FFFC,$3034,$3FF4
	dc.w	$6798,$FFFC,$6878,$EFFC,$6848,$7FF8,$6FC8,$6FC8
	dc.w	$3370,$3FF0,$3370,$3370,$0EC0,$1FE0,$0EC0,$1EE0
lik1: dc.w 3,0,10,15,0,0
	dc.w	$0F80,$0F80,$0000,$0000,$3FE0,$3FE0,$0000,$0000
	dc.w	$7FF8,$7E78,$0180,$0180,$7FFC,$7EBC,$0140,$01C0
	dc.w	$FFF4,$FF3C,$00C8,$00C0,$FF80,$FFF8,$0078,$0000
	dc.w	$FF60,$FFE0,$0080,$0000,$7FC0,$7FDC,$0000,$0000
	dc.w	$7FC0,$7FDE,$0000,$0000,$3FE0,$3FE3,$0000,$0000
	dc.w	$0F80,$0F81,$0000,$0000
lik2: dc.w 3,0,10,15,0,0
	dc.w	$01F0,$01F0,$0000,$0000,$07FC,$07FC,$0000,$0000
	dc.w	$1FFE,$1E7E,$0180,$0180,$3FFE,$3D7E,$0280,$0380
	dc.w	$2FFF,$3CFF,$1300,$0300,$01FF,$1FFF,$1E00,$0000
	dc.w	$06FF,$07FF,$0100,$0000,$03FE,$3BFE,$0000,$0000
	dc.w	$03FE,$7BFE,$0000,$0000,$07FC,$C7FC,$0000,$0000
	dc.w	$01F0,$81F0,$0000,$0000
lik3: dc.w 3,0,11,12,0,0
	dc.w	$0F80,$0F80,$0000,$0000,$3FE0,$3FE0,$0000,$0000
	dc.w	$6E30,$73F0,$1DC0,$1DC0,$5CD0,$7BF0,$2720,$3FE0
	dc.w	$FA38,$E7F8,$1DC0,$1DC0,$EDB8,$FFF8,$1240,$0000
	dc.w	$D258,$FFF8,$2DA0,$0000,$78F0,$78F0,$0000,$0000
	dc.w	$7070,$7770,$0000,$0000,$3060,$3FE0,$0000,$0000
	dc.w	$0000,$0F80,$0000,$0000,$0000,$0700,$0000,$0000
ski1: dc.w 3,0,9,12,0,0
	dc.w	$0000,$0200,$0000,$0000,$0000,$0180,$0000,$0000
	dc.w	$00C0,$0100,$00C0,$0000,$0000,$0000,$0300,$0000
	dc.w	$0680,$0080,$0180,$0600,$0700,$0300,$0000,$0400
	dc.w	$0F00,$0C00,$1000,$0300,$3300,$3000,$0800,$0300
	dc.w	$0008,$0608,$0000,$0600,$C930,$C930,$36C0,$0000
ski2: dc.w 3,0,9,12,0,0
	dc.w	$0000,$0200,$0000,$0000,$0000,$0C00,$0000,$0000
	dc.w	$1800,$0400,$1800,$0000,$0000,$0000,$0600,$0000
	dc.w	$0B00,$0800,$0C00,$0300,$0700,$0600,$0000,$0100
	dc.w	$0780,$0180,$0040,$0600,$0660,$0060,$0080,$0600
	dc.w	$8000,$8300,$0000,$0300,$6498,$6498,$1B60,$0000
ski3: dc.w 3,0,11,11,0,0
	dc.w	$0000,$0400,$0000,$0000,$0000,$0600,$0000,$0000
	dc.w	$4620,$4920,$0600,$0000,$C630,$C030,$0600,$0000
	dc.w	$C030,$C030,$0F80,$0000,$C030,$C030,$1F40,$0000
	dc.w	$C030,$C030,$2F00,$0000,$CF30,$C030,$0000,$0F00
	dc.w	$DFB0,$C030,$0000,$1F80,$F0F0,$C030,$0000,$30C0
	dc.w	$E070,$C030,$0000,$2040,$C030,$C030,$0000,$0000

gblok1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$7FFE,$7FFE,$7FFE,$7FFE,$FFFF,$FFFE,$FFFF
	dc.w	$6002,$FFFF,$E006,$FFFF,$6002,$FFFF,$EFFE,$F007
	dc.w	$7002,$FFFF,$FFFE,$FFC7,$7FC2,$CFFF,$CFFE,$CFE7
	dc.w	$7C62,$FFFF,$FC7E,$FFFF,$7BBE,$DFFF,$DBFE,$DFFF
	dc.w	$76BE,$FFEF,$F6EE,$FEEF,$6CBE,$FFEB,$ECEA,$FCEB
	dc.w	$58BE,$FFEB,$D8EA,$F8EB,$5FBE,$FFEF,$DFEE,$FFEF
	dc.w	$607E,$FFFF,$FFFE,$FFFF,$7FFE,$FFFF,$FFFE,$FFFF
	dc.w	$0000,$7FFE,$0000,$7FFE
gblok2: dc.w 3,0,14,15,0,0
	dc.w	$7FFE,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0FF8,$0000,$0FF8
	dc.w	$FFFF,$0038,$0000,$0038,$FFFF,$0018,$0000,$0018
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0380,$0000,$0380
	dc.w	$FFFF,$0780,$0000,$0780,$FFFF,$0F80,$0000,$0F80
	dc.w	$FFFF,$1F80,$0000,$1F80,$FFFF,$1F80,$0000,$1F80
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$7FFE,$0000,$0000,$0000

fteeth1: dc.w 3,0,12,15,0,0
	dc.w	$7FFE,$0000,$7FFE,$0000,$9FF9,$6006,$FFFF,$6006
	dc.w	$1991,$F66F,$FFFF,$F66F,$1111,$FFFF,$FFFF,$FFFF
	dc.w	$0110,$FFFF,$6FF6,$FFFF,$0000,$0FF0,$0660,$0FF0
	dc.w	$0000,$F00F,$6006,$F00F,$1001,$FFFF,$F66F,$FFFF
	dc.w	$1111,$FFFF,$FFFF,$FFFF,$9119,$6FF6,$FFFF,$6FF6
	dc.w	$F99F,$0660,$FFFF,$0660,$3FFC,$0000,$3FFC,$0000
	dc.w	$07E0,$0000,$07E0,$0000

fteeth2: dc.w 3,0,14,15,0,0
	dc.w	$7FFE,$0000,$7FFE,$0000,$9FF9,$6006,$FFFF,$6006
	dc.w	$1991,$F66F,$FFFF,$F66F,$1111,$FFFF,$FFFF,$FFFF
	dc.w	$0110,$FFFF,$6FF6,$FFFF,$0000,$0FF0,$0660,$0FF0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$F00F,$6006,$F00F,$1001,$FFFF,$F66F,$FFFF
	dc.w	$1111,$FFFF,$FFFF,$FFFF,$9119,$6FF6,$FFFF,$6FF6
	dc.w	$F99F,$0660,$FFFF,$0660,$3FFC,$0000,$3FFC,$0000
	dc.w	$07E0,$0000,$07E0,$0000

fteeth3: dc.w 3,0,16,15,0,0
	dc.w	$7FFE,$0000,$7FFE,$0000,$9FF9,$6006,$FFFF,$6006
	dc.w	$1991,$F66F,$FFFF,$F66F,$1111,$FFFF,$FFFF,$FFFF
	dc.w	$0110,$FFFF,$6FF6,$FFFF,$0000,$0FF0,$0660,$0FF0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$F00F,$6006,$F00F,$1001,$FFFF,$F66F,$FFFF
	dc.w	$1111,$FFFF,$FFFF,$FFFF,$9119,$6FF6,$FFFF,$6FF6
	dc.w	$F99F,$0660,$FFFF,$0660,$3FFC,$0000,$3FFC,$0000
	dc.w	$07E0,$0000,$07E0,$0000

fteeth4: dc.w 3,0,16,15,0,0
	dc.w	$07E0,$0000,$07E0,$0000,$3EFC,$0100,$3EFC,$0000
	dc.w	$E115,$1EEA,$E775,$0660,$0100,$FDFF,$6DE6,$6DE6
	dc.w	$1101,$F55F,$F54F,$F54F,$0001,$8153,$8043,$8153
	dc.w	$0000,$8001,$0000,$8001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0300,$0200,$0300
	dc.w	$0100,$9303,$0302,$9303,$1101,$DF0F,$DF0F,$DF0F
	dc.w	$1111,$FE8F,$F71F,$F60F,$9A71,$658E,$FA77,$6006
	dc.w	$7FFA,$0004,$7FFA,$0000

gproj1: dc.w 3,0,10,15,0,0
	dc.w	$0F00,$0F00,$0F00,$0F00,$11E0,$11E0,$11E0,$11E0
	dc.w	$0030,$0030,$0030,$0030,$C008,$CE18,$0E00,$0E10
	dc.w	$63DC,$7FFC,$1C00,$1C20,$7FFE,$7FFE,$0000,$0008
	dc.w	$1FFF,$7FFF,$6000,$6000,$0F34,$7FF6,$70C0,$70C0
	dc.w	$1A10,$3BF0,$21E0,$21E0,$5818,$5818,$0000,$0000
	dc.w	$5C5C,$5C5C,$0000,$0000
gproj2: dc.w 3,0,10,15,0,0
	dc.w	$00F0,$00F0,$00F0,$00F0,$0788,$0788,$0788,$0788
	dc.w	$0C00,$0C00,$0C00,$0C00,$1003,$1873,$0070,$0870
	dc.w	$3BC6,$3FFE,$0038,$0438,$7FFE,$7FFE,$0000,$1000
	dc.w	$FFF8,$FFFE,$0006,$0006,$2CF0,$6FFE,$030E,$030E
	dc.w	$0858,$0FDC,$0784,$0784,$181A,$181A,$0000,$0000
	dc.w	$3A3A,$3A3A,$0000,$0000

aro1: dc.w 3,0,14,15,0,0
	dc.w	$0180,$0000,$0000,$0000,$0240,$0180,$0000,$0000
	dc.w	$0420,$03C0,$0000,$0000,$0FF0,$07E0,$0000,$0000
	dc.w	$1FF8,$0FF0,$0000,$0000,$3FFC,$1FF8,$0000,$0000
	dc.w	$4002,$0000,$3FFC,$0000,$8001,$0000,$7FFE,$0000
	dc.w	$FC3F,$0000,$03C0,$0000,$0420,$0000,$03C0,$0000
	dc.w	$0420,$0000,$03C0,$0000,$0420,$03C0,$03C0,$03C0
	dc.w	$0420,$03C0,$03C0,$03C0,$0420,$03C0,$03C0,$03C0
	dc.w	$07E0,$0000,$0000,$0000


aro2: dc.w 3,0,15,14,0,0
	dc.w	$0180,$0000,$0000,$0000,$0280,$0000,$0100,$0000
	dc.w	$0480,$0000,$0300,$0000,$0C80,$0400,$0300,$0000
	dc.w	$1C80,$0C00,$0300,$0000,$3CFE,$1C00,$0300,$0000
	dc.w	$5C02,$3C1C,$03FC,$001C,$9C02,$7C1C,$03FC,$001C
	dc.w	$9C02,$7C1C,$03FC,$001C,$5C02,$3C1C,$03FC,$001C
	dc.w	$3CFE,$1C00,$0300,$0000,$1C80,$0C00,$0300,$0000
	dc.w	$0C80,$0400,$0300,$0000,$0480,$0000,$0300,$0000
	dc.w	$0280,$0000,$0100,$0000,$0180,$0000,$0000,$0000



aro3: dc.w 3,0,14,15,0,0
	dc.w	$07E0,$0000,$0000,$0000,$0420,$03C0,$03C0,$03C0
	dc.w	$0420,$03C0,$03C0,$03C0,$0420,$03C0,$03C0,$03C0
	dc.w	$0420,$0000,$03C0,$0000,$0420,$0000,$03C0,$0000
	dc.w	$FC3F,$0000,$03C0,$0000,$8001,$0000,$7FFE,$0000
	dc.w	$4002,$0000,$3FFC,$0000,$3FFC,$1FF8,$0000,$0000
	dc.w	$1FF8,$0FF0,$0000,$0000,$0FF0,$07E0,$0000,$0000
	dc.w	$0420,$03C0,$0000,$0000,$0240,$0180,$0000,$0000
	dc.w	$0180,$0000,$0000,$0000


aro4: dc.w 3,0,15,14,0,0
	dc.w	$0300,$0000,$0000,$0000,$0280,$0000,$0100,$0000
	dc.w	$0240,$0000,$0180,$0000,$0260,$0040,$0180,$0000
	dc.w	$0270,$0060,$0180,$0000,$FE78,$0070,$0180,$0000
	dc.w	$8074,$7078,$7F80,$7000,$8072,$707C,$7F80,$7000
	dc.w	$8072,$707C,$7F80,$7000,$8074,$7078,$7F80,$7000
	dc.w	$FE78,$0070,$0180,$0000,$0270,$0060,$0180,$0000
	dc.w	$0260,$0040,$0180,$0000,$0240,$0000,$0180,$0000
	dc.w	$0280,$0000,$0100,$0000,$0300,$0000,$0000,$0000



lsplat1: dc.w 3,0,5,15,0,0
	dc.w	$0000,$0000,$7800,$0000,$6200,$6E00,$9180,$0000
	dc.w	$3621,$3FFF,$C000,$0000,$190A,$1F3F,$E0C0,$0000
	dc.w	$3400,$3F00,$C080,$0000,$1800,$1800,$6000,$0000
lsplat2: dc.w 3,0,5,7,0,0
	dc.w	$0000,$0000,$6000,$0000,$6000,$7800,$8000,$0000
	dc.w	$7000,$7300,$8C00,$0000,$3000,$3F00,$C000,$0000
	dc.w	$2000,$3000,$C800,$0000,$0000,$0000,$6000,$0000
lsplat3: dc.w 3,0,5,7,0,0
	dc.w	$0000,$0000,$0600,$0000,$0600,$1E00,$0100,$0000
	dc.w	$0E00,$CE00,$3100,$0000,$0C00,$FC00,$0300,$0000
	dc.w	$0400,$0C00,$1300,$0000,$0000,$0000,$0600,$0000
lsplat4: dc.w 3,0,5,15,0,0
	dc.w	$0000,$0000,$001E,$0000,$0046,$0076,$0189,$0000
	dc.w	$846C,$FFFC,$0003,$0000,$5098,$FCF8,$0307,$0000
	dc.w	$002C,$00FC,$0103,$0000,$0018,$0018,$0006,$0000
wpod1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4402,$4402,$4402
	dc.w	$0002,$C803,$4802,$C803,$0EE1,$8003,$8001,$8003
	dc.w	$0BA1,$8441,$8001,$8001,$0AA1,$8541,$8001,$8001
	dc.w	$0AA1,$8541,$8001,$8001,$0821,$C7C3,$8001,$C003
	dc.w	$0FE2,$C00B,$400A,$C00B,$0002,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
wpod2: dc.w 3,0,12,14,0,0
	dc.w	$0000,$0FE0,$07C0,$0FE0,$0030,$1C70,$1830,$1C70
	dc.w	$0008,$2008,$2008,$2008,$0004,$4804,$4804,$4804
	dc.w	$0EE2,$C006,$8002,$C006,$0BA2,$8442,$8002,$8002
	dc.w	$0AA2,$8542,$8002,$8002,$0AA2,$8542,$8002,$8002
	dc.w	$0802,$C7E6,$8022,$C026,$0FE4,$4004,$4004,$4004
	dc.w	$2008,$2018,$2008,$2018,$1830,$1C70,$1830,$1C70
	dc.w	$07C0,$0FE0,$07C0,$0FE0
lpod1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0202,$4802,$4802,$4802
	dc.w	$0702,$D203,$5002,$D003,$0F01,$8603,$8001,$8003
	dc.w	$07F1,$8201,$8001,$8001,$07F9,$83F1,$8001,$8001
	dc.w	$07F1,$83E1,$8001,$8001,$07F1,$C223,$8001,$C003
	dc.w	$0FF2,$C66B,$400A,$C00B,$0662,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
lpod2: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0202,$4802,$4802,$4802
	dc.w	$0702,$D203,$5002,$D003,$0F11,$8603,$8001,$8003
	dc.w	$07F9,$8211,$8001,$8001,$07F1,$83E1,$8001,$8001
	dc.w	$07F9,$83F1,$8001,$8001,$0FF9,$C613,$8001,$C003
	dc.w	$1E72,$CC3B,$400A,$C00B,$0E22,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0

hbike: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4822,$4812,$4802
	dc.w	$0002,$D053,$5022,$D003,$0001,$80A3,$8041,$8003
	dc.w	$0181,$8141,$8001,$8001,$0181,$8281,$8001,$8001
	dc.w	$0101,$8501,$8201,$8001,$0001,$CA03,$8401,$C003
	dc.w	$0002,$C40B,$480A,$C00B,$0002,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0

f3way1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4802,$4A02,$4802
	dc.w	$0002,$D503,$5202,$D003,$0001,$8543,$8221,$8003
	dc.w	$0001,$85A1,$8241,$8001,$0001,$8041,$8281,$8001
	dc.w	$0001,$8071,$8001,$8001,$0001,$C003,$80F9,$C003
	dc.w	$0002,$C07B,$400A,$C00B,$0002,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
f3way2: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4802,$4802,$4802
	dc.w	$0002,$D003,$5802,$D003,$0001,$9403,$8801,$8003
	dc.w	$0001,$9501,$8881,$8001,$0001,$9681,$8901,$8001
	dc.w	$0001,$8101,$8A01,$8001,$0001,$C1C3,$8001,$C003
	dc.w	$0002,$C00B,$43EA,$C00B,$0002,$41D2,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
smbom1: dc.w 3,0,13,15,0,0
	dc.w	$00E0,$00E0,$00E0,$00E0,$0110,$0712,$0110,$0710
	dc.w	$0008,$1FC8,$0008,$1FC8,$0003,$FFF3,$0004,$FFF0
	dc.w	$0000,$7FE0,$0000,$7F80,$0000,$7FF1,$1040,$1E40
	dc.w	$1860,$7FF0,$2080,$38E0,$1860,$FFF8,$2080,$38E0
	dc.w	$0000,$FFF8,$1040,$1040,$0000,$FFF8,$0000,$0840
	dc.w	$0000,$7FF0,$0000,$3030,$0000,$7FF0,$0000,$0FC0
	dc.w	$0000,$3FE0,$0000,$0000,$0000,$0F80,$0000,$0000
smbom2: dc.w 3,0,13,15,0,0
	dc.w	$00C2,$00CA,$00C0,$00C0,$0120,$0720,$0124,$0720
	dc.w	$0018,$1FD9,$0018,$1FD8,$0000,$FFF0,$0000,$FFF0
	dc.w	$0000,$7FE0,$0000,$7F80,$0000,$7FF0,$1040,$1E40
	dc.w	$30C0,$7FF0,$0820,$38E0,$30C0,$FFF8,$0820,$38E0
	dc.w	$0000,$FFF8,$1040,$1040,$0000,$FFF8,$0000,$0840
	dc.w	$0000,$7FF8,$0000,$3030,$0000,$7FF0,$0000,$0FC0
	dc.w	$0000,$3FE0,$0000,$0700,$0000,$0F80,$0000,$0000

invis1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$07E2,$4802,$4802,$4802
	dc.w	$0422,$D3C3,$5002,$D003,$07E1,$8183,$8001,$8003
	dc.w	$03C1,$8181,$8001,$8001,$0241,$8001,$8181,$8001
	dc.w	$03C1,$8181,$8001,$8001,$07E1,$C183,$8001,$C003
	dc.w	$0422,$C3CB,$400A,$C00B,$07E2,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
invis2: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4FE2,$4802,$4802
	dc.w	$03C2,$D423,$5002,$D003,$07E1,$8663,$8001,$8003
	dc.w	$03C1,$8241,$8001,$8001,$0181,$8001,$8241,$8001
	dc.w	$03C1,$8241,$8001,$8001,$07E1,$C663,$8001,$C003
	dc.w	$03C2,$C42B,$400A,$C00B,$0002,$47F2,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
invis3: dc.w 3,0,8,5,0,0
	dc.w	$FC00,$0000,$0000,$0000,$8400,$7800,$0000,$0000
	dc.w	$FC00,$3000,$0000,$0000,$7800,$3000,$0000,$0000
	dc.w	$4800,$0000,$3000,$0000,$7800,$3000,$0000,$0000
	dc.w	$FC00,$3000,$0000,$0000,$8400,$7800,$0000,$0000
	dc.w	$FC00,$0000,$0000,$0000
mandy1: dc.w 3,1,23,28,0,0
	dc.w	$0000,$0000,$0000,$0000,$0000,$1000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1000,$7800,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$2800,$EE00,$1000,$0000
	dc.w	$0000,$0001,$0000,$0000,$5600,$C780,$2800,$0000
	dc.w	$0001,$0003,$0000,$0000,$B980,$81C0,$4600,$0000
	dc.w	$0002,$0006,$0001,$0000,$3E40,$0060,$C180,$0000
	dc.w	$0005,$000C,$0002,$0000,$FFD0,$0010,$0020,$0000
	dc.w	$000B,$0078,$0004,$0000,$FFD0,$0018,$0020,$0000
	dc.w	$019B,$0398,$0064,$0000,$FFE0,$0008,$0010,$0000
	dc.w	$046F,$0C08,$0390,$0000,$FFE8,$0008,$0010,$0000
	dc.w	$0BFF,$1A08,$0400,$0000,$FFE8,$0008,$0010,$0000
	dc.w	$13FF,$7000,$0C00,$0000,$FFC8,$0008,$0030,$0000
	dc.w	$1FFF,$E000,$0000,$0000,$FF90,$0010,$0060,$0000
	dc.w	$13FF,$7000,$0C00,$0000,$FFC8,$0008,$0030,$0000
	dc.w	$0BFF,$1A08,$0400,$0000,$FFE8,$0008,$0010,$0000
	dc.w	$046F,$0C08,$0390,$0000,$FFE8,$0008,$0010,$0000
	dc.w	$019B,$0398,$0064,$0000,$FFE0,$0008,$0010,$0000
	dc.w	$000B,$0078,$0004,$0000,$FFD0,$0018,$0020,$0000
	dc.w	$0005,$000C,$0002,$0000,$FFD0,$0010,$0020,$0000
	dc.w	$0002,$0006,$0001,$0000,$3E40,$0060,$C180,$0000
	dc.w	$0001,$0003,$0000,$0000,$B980,$81C0,$4600,$0000
	dc.w	$0000,$0001,$0000,$0000,$5600,$C780,$2800,$0000
	dc.w	$0000,$0000,$0000,$0000,$2800,$EE00,$1000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1000,$7800,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$1000,$0000,$0000
mandy2: dc.w 3,1,23,28,0,0
	dc.w	$0000,$0040,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0040,$00F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$00A0,$03B8,$0040,$0000,$0000,$0000,$0000,$0000
	dc.w	$0350,$0F1C,$00A0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0CEC,$1C0E,$0310,$0000,$0000,$0000,$0000,$0000
	dc.w	$13E2,$3003,$0C1C,$0000,$0000,$0000,$0000,$0000
	dc.w	$5FFD,$4001,$2002,$0000,$0000,$8000,$0000,$0000
	dc.w	$5FFE,$C000,$2001,$0000,$8000,$F000,$0000,$0000
	dc.w	$3FFE,$8000,$4001,$0000,$CC00,$CE00,$3000,$0000
	dc.w	$BFFF,$8000,$4000,$0000,$B100,$8180,$4E00,$0000
	dc.w	$BFFF,$8000,$4000,$0000,$FE80,$82C0,$0100,$0000
	dc.w	$9FFF,$8000,$6000,$0000,$FE40,$0070,$0180,$0000
	dc.w	$4FFF,$4000,$3000,$0000,$FFC0,$0038,$0000,$0000
	dc.w	$9FFF,$8000,$6000,$0000,$FE40,$0070,$0180,$0000
	dc.w	$BFFF,$8000,$4000,$0000,$FE80,$82C0,$0100,$0000
	dc.w	$BFFF,$8000,$4000,$0000,$B100,$8180,$4E00,$0000
	dc.w	$3FFE,$8000,$4001,$0000,$CC00,$CE00,$3000,$0000
	dc.w	$5FFE,$C000,$2001,$0000,$8000,$F000,$0000,$0000
	dc.w	$5FFD,$4001,$2002,$0000,$0000,$8000,$0000,$0000
	dc.w	$13E2,$3003,$0C1C,$0000,$0000,$0000,$0000,$0000
	dc.w	$0CEC,$1C0E,$0310,$0000,$0000,$0000,$0000,$0000
	dc.w	$0350,$0F1C,$00A0,$0000,$0000,$0000,$0000,$0000
	dc.w	$00A0,$03B8,$0040,$0000,$0000,$0000,$0000,$0000
	dc.w	$0040,$00F0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0040,$0000,$0000,$0000,$0000,$0000,$0000

mbuu1: dc.w 3,0,4,13,0,0
	dc.w	$07E0,$07E0,$07E0,$07E0,$F000,$FFF8,$F7F8,$FFF8
	dc.w	$F7FC,$FFFC,$F7FC,$FFFC,$07F0,$FFF8,$07F8,$FFF8
	dc.w	$0000,$07E0,$0000,$07E0
mbuu2: dc.w 3,0,4,13,0,0
	dc.w	$1F80,$1F80,$1F80,$1F80,$003C,$7FFC,$7FBC,$7FFC
	dc.w	$FFBC,$FFFC,$FFBC,$FFFC,$3F80,$7FFC,$7F80,$7FFC
	dc.w	$0000,$1F80,$0000,$1F80
bsi1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4802,$4802,$4802
	dc.w	$0002,$D003,$5002,$D003,$0039,$8003,$8001,$8003
	dc.w	$0045,$8001,$8039,$8001,$0025,$8001,$8019,$8001
	dc.w	$0455,$8001,$8029,$8001,$0AA9,$C003,$8441,$C003
	dc.w	$0542,$C00B,$428A,$C00B,$0282,$4012,$4112,$4012
	dc.w	$2104,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
bsi2: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4802,$4802,$4802
	dc.w	$0002,$D003,$5002,$D003,$0001,$8003,$8001,$8003
	dc.w	$1001,$8001,$8001,$8001,$28E1,$8001,$9001,$8001
	dc.w	$1511,$8001,$88E1,$8001,$0A91,$C003,$8461,$C003
	dc.w	$0552,$C00B,$42AA,$C00B,$02A2,$4012,$4112,$4012
	dc.w	$2104,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
bnus1: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4802,$4802,$4802
	dc.w	$0202,$D203,$5202,$D203,$0401,$87FF,$8701,$8703
	dc.w	$00FF,$9FFF,$9F01,$9F01,$0F81,$EF81,$EFFF,$EF81
	dc.w	$1F81,$9FFF,$9FFF,$9F81,$1FFD,$DFFF,$9FC1,$DFFF
	dc.w	$0002,$C00B,$400A,$C00B,$0002,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0
bnus2: dc.w 3,0,14,15,0,0
	dc.w	$0000,$0FF0,$07E0,$0FF0,$0000,$1C38,$1818,$1C38
	dc.w	$0004,$300C,$2004,$300C,$0002,$4802,$4802,$4802
	dc.w	$0042,$D043,$5042,$D043,$0081,$80FF,$80E1,$80E3
	dc.w	$001F,$83FF,$83E1,$83E1,$01F1,$8DF1,$8DFF,$8DF1
	dc.w	$01F1,$B1FF,$B1FF,$B1F1,$03FD,$C3FF,$83F9,$C3FF
	dc.w	$0002,$C00B,$400A,$C00B,$0002,$4012,$4012,$4012
	dc.w	$2004,$300C,$2004,$300C,$1818,$1C38,$1818,$1C38
	dc.w	$07E0,$0FF0,$07E0,$0FF0

trn1: dc.w 3,0,10,15,0,0
	dc.w	$00F0,$00F0,$00F0,$00F0,$0788,$0788,$0788,$0788
	dc.w	$0C00,$0C00,$0C00,$0C00,$1003,$1873,$0070,$0870
	dc.w	$3BC6,$3FFE,$0038,$0438,$7FFE,$7FFE,$0000,$1000
	dc.w	$FFF8,$FFFE,$0006,$0006,$2CF0,$6FFE,$030E,$030E
	dc.w	$0858,$0FDC,$0784,$0784,$181A,$181A,$0000,$0000
	dc.w	$3A3A,$3A3A,$0000,$0000
trn2: dc.w 3,0,14,13,0,0
	dc.w	$04C0,$04C0,$0400,$0400,$1880,$1880,$1800,$1800
	dc.w	$31C0,$31C0,$3000,$3000,$6080,$67E0,$6760,$6760
	dc.w	$61C0,$6FE0,$6E20,$6E20,$CFA8,$CFF8,$C050,$C050
	dc.w	$CFF4,$CFF4,$C000,$C000,$9F38,$9F38,$8000,$8000
	dc.w	$9EB0,$FFB0,$0100,$6100,$F820,$FF20,$0700,$0700
	dc.w	$F800,$FE00,$0600,$4600,$E900,$ED00,$0400,$0400
	dc.w	$E400,$E400,$0000,$0000,$8E00,$8E00,$0000,$0000
	dc.w	$0C00,$0C00,$0000,$0000
trn3: dc.w 3,0,15,10,0,0
	dc.w	$1000,$1000,$0000,$0000,$1C60,$1F60,$0300,$0300
	dc.w	$0C00,$0F80,$0380,$0380,$46E0,$4FE0,$4900,$4900
	dc.w	$87E0,$9FE0,$9800,$9800,$8720,$9F20,$9800,$9800
	dc.w	$8F80,$9F80,$9000,$9000,$CF00,$CF80,$C080,$C080
	dc.w	$4E00,$4F80,$4180,$4180,$4E20,$4FA0,$4180,$4180
	dc.w	$6700,$6F80,$6080,$6880,$2FE0,$3FE0,$2000,$3000
	dc.w	$1E60,$1E60,$0000,$0400,$0F20,$0F20,$0000,$0000
	dc.w	$0600,$0700,$0000,$0000,$0200,$0200,$0000,$0000
trn4: dc.w 3,0,13,14,0,0
	dc.w	$0200,$0200,$0000,$0000,$0500,$0500,$0000,$0000
	dc.w	$0380,$0780,$0400,$0400,$07C0,$1FC0,$1800,$1800
	dc.w	$AA00,$BE00,$1400,$1400,$FE80,$FE80,$0000,$0000
	dc.w	$2F10,$3FD0,$10C0,$10C0,$0784,$1FE4,$1860,$1860
	dc.w	$878E,$9FFE,$9870,$9870,$47F6,$4FF6,$4800,$4800
	dc.w	$61E0,$61E0,$6000,$6000,$3878,$38F8,$3800,$3880
	dc.w	$1E78,$1EF8,$1E00,$1EA0,$07FC,$07FC,$0700,$0700
trn5: dc.w 3,0,10,15,0,0
	dc.w	$5C5C,$5C5C,$0000,$0000,$5818,$5818,$0000,$0000
	dc.w	$1A10,$3BF0,$21E0,$21E0,$0F34,$7FF6,$70C0,$70C0
	dc.w	$1FFF,$7FFF,$6000,$6000,$7FFE,$7FFE,$0000,$0008
	dc.w	$63DC,$7FFC,$1C00,$1C20,$C008,$CE18,$0E00,$0E10
	dc.w	$0030,$0030,$0030,$0030,$11E0,$11E0,$11E0,$11E0
	dc.w	$0F00,$0F00,$0F00,$0F00
trn6: dc.w 3,0,14,13,0,0
	dc.w	$00C0,$00C0,$0000,$0000,$01C4,$01C4,$0000,$0000
	dc.w	$009C,$009C,$0000,$0000,$025C,$02DC,$0080,$0080
	dc.w	$007C,$01FC,$0180,$0188,$107C,$13FC,$0380,$0380
	dc.w	$35E4,$37FC,$0200,$0218,$73E4,$73E4,$0004,$0004
	dc.w	$BFCC,$BFCC,$000C,$000C,$57CC,$7FCC,$280C,$280C
	dc.w	$0E18,$1FD8,$11D8,$11D8,$0418,$1F98,$1B98,$1B98
	dc.w	$0E30,$0E30,$0030,$0030,$0660,$0660,$0060,$0060
	dc.w	$0C80,$0C80,$0080,$0080
trn7: dc.w 3,0,15,10,0,0
	dc.w	$0800,$0800,$0000,$0000,$0C00,$1C00,$0000,$0000
	dc.w	$9E00,$9E00,$0000,$0000,$CF00,$CF00,$0000,$0400
	dc.w	$FE80,$FF80,$0080,$0180,$1CC0,$3EC0,$20C0,$22C0
	dc.w	$8E40,$BE40,$3040,$3040,$0E40,$3E40,$3040,$3040
	dc.w	$1E60,$3E60,$2060,$2060,$3E20,$3F20,$0120,$0120
	dc.w	$9C20,$9F20,$0320,$0320,$FC20,$FF20,$0320,$0320
	dc.w	$EC40,$FE40,$1240,$1240,$0600,$3E00,$3800,$3800
	dc.w	$C700,$DF00,$1800,$1800,$0100,$0100,$0000,$0000
trn8: dc.w 3,0,13,14,0,0
	dc.w	$7FC0,$7FC0,$01C0,$01C0,$3CF0,$3EF0,$00F0,$0AF0
	dc.w	$3C38,$3E38,$0038,$0238,$0F0C,$0F0C,$000C,$000C
	dc.w	$DFC4,$DFE4,$0024,$0024,$E3C2,$FFF2,$1C32,$1C32
	dc.w	$43C0,$4FF0,$0C30,$0C30,$11E8,$17F8,$0610,$0610
	dc.w	$02FE,$02FE,$0000,$0000,$00AA,$00FA,$0050,$0050
	dc.w	$07C0,$07F0,$0030,$0030,$0380,$03C0,$0040,$0040
	dc.w	$0140,$0140,$0000,$0000,$0080,$0080,$0000,$0000

saf1: dc.w 3,0,12,13,0,0
	dc.w	$0000,$0000,$0FC0,$0000,$0790,$0790,$3860,$0000
	dc.w	$1FF8,$1FF8,$6000,$0000,$3878,$3878,$4780,$0000
	dc.w	$3B7C,$387C,$C480,$0000,$601C,$601C,$9FE0,$0000
	dc.w	$6CDC,$601C,$9320,$0000,$6014,$6014,$9FE8,$0000
	dc.w	$7B6C,$786C,$8490,$0000,$7868,$7868,$0790,$0000
	dc.w	$7F98,$7F98,$0060,$0000,$3E70,$3E70,$0180,$0000
	dc.w	$0FC0,$0FC0,$0000,$0000
saf2: dc.w 3,0,12,13,0,0
	dc.w	$0000,$0000,$0FC0,$0000,$0790,$0000,$3860,$0000
	dc.w	$1FF8,$0000,$6000,$0000,$3878,$0000,$4780,$0000
	dc.w	$3B7C,$0000,$C480,$0000,$601C,$0000,$9FE0,$0000
	dc.w	$6CDC,$0000,$9320,$0000,$6014,$0000,$9FE8,$0000
	dc.w	$7B6C,$0000,$8490,$0000,$7868,$0000,$0790,$0000
	dc.w	$7F98,$0000,$0060,$0000,$3E70,$0000,$0180,$0000
	dc.w	$0FC0,$0000,$0000,$0000
saf3: dc.w 3,0,10,11,0,0
	dc.w	$0000,$3FC0,$0000,$0000,$1F80,$3FC0,$0000,$0000
	dc.w	$1080,$F0F0,$0F00,$0000,$76E0,$F0F0,$0900,$0000
	dc.w	$4020,$C030,$3FC0,$0000,$59A0,$C030,$2640,$0000
	dc.w	$4020,$C030,$3FC0,$0000,$76E0,$F0F0,$0900,$0000
	dc.w	$1080,$F0F0,$0F00,$0000,$1F80,$3FC0,$0000,$0000
	dc.w	$0000,$3FC0,$0000,$0000
w16ton: dc.w 3,1,21,31,0,0
	dc.w	$0002,$0003,$0002,$0003,$0000,$E000,$0000,$E000
	dc.w	$0000,$0006,$0004,$0006,$2000,$3000,$2000,$3000
	dc.w	$0000,$000C,$0008,$000C,$1000,$1800,$1000,$1800
	dc.w	$0008,$000C,$0008,$000C,$1000,$1800,$1000,$1800
	dc.w	$0008,$000C,$0008,$000C,$0000,$1800,$1000,$1800
	dc.w	$0004,$0006,$0004,$0006,$0000,$3000,$2000,$3000
	dc.w	$00FF,$07FF,$07FF,$07FF,$FFE0,$FFE0,$FFE0,$FFE0
	dc.w	$0000,$07FF,$0400,$07FF,$0000,$FFE0,$0000,$FFE0
	dc.w	$0000,$07FF,$0438,$07FF,$0000,$FFE0,$1E00,$FFE0
	dc.w	$0800,$0FFF,$0818,$0FFF,$0000,$FFF0,$3000,$FFF0
	dc.w	$0800,$0FFF,$0818,$0FFF,$0000,$FFF0,$3E00,$FFF0
	dc.w	$1000,$1FFF,$1018,$1FFF,$0000,$FFF8,$3300,$FFF8
	dc.w	$1000,$1FFF,$1018,$1FFF,$0000,$FFF8,$3300,$FFF8
	dc.w	$1000,$1FFF,$103C,$1FFF,$0000,$FFF8,$1E00,$FFF8
	dc.w	$2000,$3FFF,$2000,$3FFF,$0000,$FFFC,$0000,$FFFC
	dc.w	$2000,$3FFF,$3FBE,$3FFF,$0000,$FFFC,$C678,$FFFC
	dc.w	$2000,$3FFF,$2632,$3FFF,$0000,$FFFC,$E6C0,$FFFC
	dc.w	$4000,$7FFF,$4632,$7FFF,$0000,$FFFE,$F660,$FFFE
	dc.w	$4000,$7FFF,$4632,$7FFF,$0000,$FFFE,$DE30,$FFFE
	dc.w	$8000,$FFFF,$8632,$FFFF,$0000,$FFFF,$CE18,$FFFF
	dc.w	$8000,$FFFF,$863E,$FFFF,$0000,$FFFF,$C6F0,$FFFF
	dc.w	$8000,$FFFF,$8000,$FFFF,$0000,$FFFF,$0000,$FFFF

brolly1: dc.w 3,0,18,15,0,0
	dc.w	$0000,$0080,$0000,$0080,$0080,$0080,$0080,$0080
	dc.w	$0000,$01C0,$0080,$0080,$0000,$0180,$0040,$0000
	dc.w	$0000,$0180,$0040,$0000,$0000,$0100,$00C0,$0000
	dc.w	$0000,$0360,$0080,$0000,$0000,$0260,$0180,$0000
	dc.w	$0000,$02E0,$0100,$0000,$0000,$02E0,$0100,$0000
	dc.w	$0000,$00E0,$0300,$0000,$0000,$01E0,$0200,$0000
	dc.w	$0000,$03C0,$0020,$0000,$0000,$0380,$0060,$0000
	dc.w	$0000,$0180,$0040,$0000,$0080,$0080,$0080,$0080
	dc.w	$01C0,$01C0,$0000,$01C0,$0DC0,$0DC0,$0000,$0DC0
	dc.w	$0780,$0780,$0000,$0780
brolly2: dc.w 3,0,18,15,0,0
	dc.w	$0000,$0080,$0000,$0080,$0080,$0080,$0080,$0080
	dc.w	$0000,$0080,$0080,$0080,$0000,$06E0,$0100,$0000
	dc.w	$0000,$1E78,$0180,$0000,$0000,$3C3C,$03C0,$0000
	dc.w	$0000,$7C3E,$03C0,$0000,$0000,$F81F,$07E0,$0000
	dc.w	$0080,$8891,$04A0,$0080,$0080,$0080,$0080,$0080
	dc.w	$0080,$0080,$0080,$0080,$0080,$0080,$0080,$0080
	dc.w	$0080,$0080,$0080,$0080,$0080,$0080,$0080,$0080
	dc.w	$0080,$0080,$0080,$0080,$0080,$0080,$0080,$0080
	dc.w	$01C0,$01C0,$0000,$01C0,$0DC0,$0DC0,$0000,$0DC0
	dc.w	$0780,$0780,$0000,$0780
drop: dc.w 3,0,7,8,0,0
	dc.w	$0080,$0080,$0000,$0080,$0200,$0000,$0000,$0200
	dc.w	$0C00,$0800,$0000,$0C00,$0800,$0000,$0000,$1800
	dc.w	$1800,$0000,$0000,$7800,$3000,$1000,$0000,$F000
	dc.w	$7000,$1000,$0000,$F000,$6000,$2000,$0000,$6000

camsaf1: dc.w 3,0,11,15,0,0 
	dc.w	$6006,$6006,$0000,$0000,$300C,$300C,$0000,$0000
	dc.w	$700E,$700E,$0000,$2004,$F00F,$F00F,$0000,$0000
	dc.w	$700E,$F00F,$0000,$0000,$381C,$381C,$0000,$0000
	dc.w	$381C,$381C,$0000,$0000,$1C38,$3C3C,$0000,$0000
	dc.w	$1FF8,$1FF8,$0000,$0000,$07E0,$1FF8,$0000,$0000
	dc.w	$03C0,$07E0,$0000,$0000,$0180,$03C0,$0000,$0000
camsaf2: dc.w 3,0,11,15,0,0
	dc.w	$8811,$8811,$0000,$0000,$700E,$700E,$0000,$0000
	dc.w	$700E,$2004,$0000,$0000,$2004,$700E,$0000,$0000
	dc.w	$500A,$700E,$0000,$0000,$381C,$381C,$0000,$0000
	dc.w	$381C,$381C,$0000,$0000,$1C38,$3C3C,$0000,$0000
	dc.w	$1FF8,$1FF8,$0000,$0000,$07E0,$1FF8,$0000,$0000
	dc.w	$03C0,$07E0,$0000,$0000,$0180,$03C0,$0000,$0000
camsaf3: dc.w 3,0,11,15,0,0
	dc.w	$0840,$0840,$0000,$0000,$3030,$3030,$0000,$0000
	dc.w	$7038,$7038,$0000,$2010,$F03C,$F03C,$0000,$0000
	dc.w	$3030,$3030,$0000,$0000,$F87C,$F87C,$0000,$0000
	dc.w	$3870,$3870,$0000,$0000,$3CF0,$3CF0,$0000,$0000
	dc.w	$1FE0,$3FF0,$0000,$0000,$0FC0,$1FE0,$0000,$0000
	dc.w	$0780,$0FC0,$0000,$0000,$0300,$0780,$0000,$0000
camspit1: dc.w 3,0,4,8,0,0
	dc.w	$3800,$1800,$0000,$7800,$7E00,$0E00,$0000,$FE00
	dc.w	$7F80,$3F80,$0000,$FF80,$7E00,$0E00,$0000,$FE00
	dc.w	$3800,$1800,$0000,$7800
camspit2: dc.w 3,0,4,8,0,0
	dc.w	$0E00,$0C00,$0000,$0F00,$3F00,$3800,$0000,$3F80
	dc.w	$FF00,$FE00,$0000,$FF80,$3F00,$3800,$0000,$3F80
	dc.w	$0E00,$0C00,$0000,$0F00
ro1: dc.w 3,0,12,15,0,0
	dc.w	$0100,$0100,$0100,$0100,$0380,$0200,$0280,$0280
	dc.w	$0100,$0000,$0100,$0100,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0180,$0180,$0180,$0180
	dc.w	$0380,$0240,$0240,$0240,$0640,$0420,$05A0,$0420
	dc.w	$0640,$0420,$05A0,$0420,$0380,$0240,$0240,$0240
	dc.w	$4002,$4182,$4182,$4182,$E007,$8004,$A005,$A005
	dc.w	$4002,$0000,$4002,$4002
ro2: dc.w 3,0,13,12,0,0
	dc.w	$4000,$4000,$4000,$4000,$E000,$8000,$A000,$A000
	dc.w	$4000,$0000,$4000,$4000,$0000,$0000,$0000,$0000
	dc.w	$0C00,$0C00,$0C00,$0C00,$1C00,$1200,$1200,$1200
	dc.w	$3E10,$2D10,$2110,$2110,$3E38,$2D20,$2128,$2128
	dc.w	$1C10,$1200,$1210,$1210,$0000,$0C00,$0C00,$0C00
	dc.w	$0000,$0000,$0000,$0000,$4000,$4000,$4000,$4000
	dc.w	$E000,$8000,$A000,$A000,$4000,$0000,$4000,$4000
ro3: dc.w 3,0,12,14,0,0
	dc.w	$0004,$0004,$0004,$0004,$400E,$4008,$400A,$400A
	dc.w	$E184,$8180,$A184,$A184,$4380,$0240,$4240,$4240
	dc.w	$0640,$05A0,$0420,$0420,$0640,$05A0,$0420,$0420
	dc.w	$0380,$0240,$0240,$0240,$0000,$0180,$0180,$0180
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0080,$0080,$0080,$0080,$01C0,$0100,$0140,$0140
	dc.w	$0080,$0000,$0080,$0080
ro4: dc.w 3,0,12,15,0,0
	dc.w	$0010,$0010,$0010,$0010,$0038,$0020,$0028,$0028
	dc.w	$0010,$0000,$0010,$0010,$0000,$0000,$0000,$0000
	dc.w	$0180,$0180,$0180,$0180,$0380,$0240,$0240,$0240
	dc.w	$47C0,$45A0,$4420,$4420,$E7C0,$85A0,$A420,$A420
	dc.w	$4380,$0240,$4240,$4240,$0000,$0180,$0180,$0180
	dc.w	$0000,$0000,$0000,$0000,$0008,$0008,$0008,$0008
	dc.w	$001C,$0010,$0014,$0014,$0008,$0000,$0008,$0008

bait1: dc.w 3,0,5,14,0,0
	dc.w	$0000,$0FE0,$01E0,$0000,$0000,$3FF8,$07F8,$0000
	dc.w	$1FFE,$FC7E,$1C7E,$0000,$0000,$7FFC,$1FFC,$0000
	dc.w	$0000,$3FF8,$0FF8,$0000,$0000,$1FF0,$07F0,$0000
bait2: dc.w 3,0,5,14,0,0
	dc.w	$0000,$0FE0,$0CE0,$0000,$0000,$3FF8,$39F8,$0000
	dc.w	$F3FE,$FFC6,$F3C6,$0000,$0000,$7FFC,$79FC,$0000
	dc.w	$0000,$3FF8,$39F8,$0000,$0000,$1FF0,$1CF0,$0000
bait3: dc.w 3,0,5,14,0,0
	dc.w	$0000,$0FE0,$0E60,$0000,$0000,$3FF8,$3F38,$0000
	dc.w	$FFDE,$C7FE,$C7DE,$0000,$0000,$7FFC,$7F3C,$0000
	dc.w	$0000,$3FF8,$3F38,$0000,$0000,$1FF0,$1E70,$0000
bait4: dc.w 3,0,5,14,0,0
	dc.w	$0000,$0FE0,$0F00,$0000,$0000,$3FF8,$3FC0,$0000
	dc.w	$FFF0,$FC7E,$FC70,$0000,$0000,$7FFC,$7FF0,$0000
	dc.w	$0000,$3FF8,$3FE0,$0000,$0000,$1FF0,$1FC0,$0000
scros1: dc.w 3,0,11,11,0,0
	dc.w	$0E00,$0000,$0000,$0000,$1500,$0000,$0000,$0000
	dc.w	$1F00,$0000,$0000,$0000,$1B00,$0000,$0000,$0000
	dc.w	$0E40,$0000,$0000,$0000,$1160,$0000,$0000,$0000
	dc.w	$4E80,$0000,$0000,$0000,$F100,$0000,$0000,$0000
	dc.w	$0E00,$0000,$0000,$0000,$0580,$0000,$0000,$0000
	dc.w	$1870,$0000,$0000,$0000,$0820,$0000,$0000,$0000
scros2: dc.w 3,0,11,11,0,0
	dc.w	$0700,$0000,$0000,$0000,$0A80,$0000,$0000,$0000
	dc.w	$0F80,$0000,$0000,$0000,$0D80,$0000,$0000,$0000
	dc.w	$2700,$0000,$0000,$0000,$6880,$0000,$0000,$0000
	dc.w	$1720,$0000,$0000,$0000,$08F0,$0000,$0000,$0000
	dc.w	$0700,$0000,$0000,$0000,$1A00,$0000,$0000,$0000
	dc.w	$E180,$0000,$0000,$0000,$4100,$0000,$0000,$0000
sfhg1: dc.w 3,0,9,9,0,0
	dc.w	$0C00,$0000,$0000,$0000,$1E00,$0000,$0000,$1E00
	dc.w	$3F00,$0000,$0000,$3F00,$7380,$0000,$0000,$7380
	dc.w	$E1C0,$0000,$0000,$6180,$E1C0,$0000,$0000,$6180
	dc.w	$7380,$0000,$0000,$7380,$3F00,$0000,$0000,$3F00
	dc.w	$1E00,$0000,$0000,$1E00,$0C00,$0000,$0000,$0000
sfhg2: dc.w 3,0,9,9,0,0
	dc.w	$0C00,$0000,$0000,$0000,$1E00,$0000,$0000,$1E00
	dc.w	$1E00,$0000,$0000,$1E00,$6180,$0000,$0000,$6180
	dc.w	$E1C0,$0000,$0000,$6180,$E1C0,$0000,$0000,$6180
	dc.w	$6180,$0000,$0000,$6180,$1E00,$0000,$0000,$1E00
	dc.w	$1E00,$0000,$0000,$1E00,$0C00,$0000,$0000,$0000
sfhg3: dc.w 3,0,9,9,0,0
	dc.w	$0C00,$0000,$0000,$0000,$1E00,$0000,$0000,$1E00
	dc.w	$0000,$0000,$0000,$0000,$4080,$0000,$0000,$4080
	dc.w	$C0C0,$0000,$0000,$4080,$C0C0,$0000,$0000,$4080
	dc.w	$4080,$0000,$0000,$4080,$0000,$0000,$0000,$0000
	dc.w	$1E00,$0000,$0000,$1E00,$0C00,$0000,$0000,$0000
sgun1: dc.w 3,0,8,14,0,0
	dc.w	$0000,$0100,$0100,$0100,$0100,$0380,$0300,$0380
	dc.w	$0100,$0380,$0300,$0380,$0100,$0FE0,$0FE0,$0FE0
	dc.w	$0C60,$3FF8,$3C78,$3FF8,$2388,$FC7E,$E04E,$E44E
	dc.w	$3C78,$7FFC,$7FF8,$7FFC,$1FF0,$3FF8,$3FF0,$3FF8
	dc.w	$0000,$1FF0,$1000,$1FF0
sgun2: dc.w 3,0,14,8,0,0
	dc.w	$0000,$0400,$0400,$0400,$0000,$0600,$0400,$0600
	dc.w	$0600,$0F00,$0E00,$0F00,$0300,$0F80,$0B00,$0B80
	dc.w	$0B00,$1F80,$1B00,$1B80,$0B00,$1F80,$1F00,$1F80
	dc.w	$0500,$7B80,$1300,$7B80,$7500,$FB80,$F300,$FB80
	dc.w	$0500,$7B80,$7300,$7B80,$0B00,$1F80,$1B00,$1F80
	dc.w	$0B00,$1F80,$1B00,$1B80,$0300,$0F80,$0B80,$0B80
	dc.w	$0600,$0F00,$0F00,$0F00,$0000,$0600,$0600,$0600
	dc.w	$0000,$0400,$0400,$0400
sgun3: dc.w 3,0,8,14,0,0
	dc.w	$0000,$1FF0,$0010,$1FF0,$1FF0,$3FF8,$1FF8,$3FF8
	dc.w	$3C78,$7FFC,$3FFC,$7FFC,$2388,$FC7E,$E40E,$E44E
	dc.w	$0C60,$3FF8,$3C78,$3FF8,$0100,$0FE0,$0FE0,$0FE0
	dc.w	$0100,$0380,$0180,$0380,$0100,$0380,$0180,$0380
	dc.w	$0000,$0100,$0100,$0100
sgun4: dc.w 3,0,14,8,0,0
	dc.w	$0000,$1000,$1000,$1000,$0000,$3000,$3000,$3000
	dc.w	$3000,$7800,$7800,$7800,$6000,$F800,$E800,$E800
	dc.w	$6800,$FC00,$6C00,$EC00,$6800,$FC00,$6C00,$FC00
	dc.w	$5000,$EF00,$6700,$EF00,$5700,$EF80,$6780,$EF80
	dc.w	$5000,$EF00,$6400,$EF00,$6800,$FC00,$7C00,$FC00
	dc.w	$6800,$FC00,$6C00,$EC00,$6000,$F800,$6800,$E800
	dc.w	$3000,$7800,$3800,$7800,$0000,$3000,$1000,$3000
	dc.w	$0000,$1000,$1000,$1000
gproj: dc.w 3,0,8,8,0,0
	dc.w	$0800,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$1C00,$1800,$1C00,$0C00,$3E00,$3C00,$3E00
	dc.w	$9C80,$3600,$3400,$3600,$1C00,$3E00,$3C00,$3E00
	dc.w	$1800,$1C00,$1800,$1C00,$0000,$0000,$0000,$0000
	dc.w	$0800,$0000,$0000,$0000

sbox: dc.w 3,1,19,17,0,0
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$F000,$0000,$0000
	dc.w	$7FFF,$FFFF,$0000,$0000,$E000,$F000,$0000,$0000
	dc.w	$4000,$C000,$3FFF,$0000,$2000,$3000,$C000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$2000,$0000,$2000,$3000,$4000,$0000
	dc.w	$4000,$C000,$3FFF,$0000,$2000,$3000,$C000,$0000
	dc.w	$7FFF,$FFFF,$0000,$0000,$E000,$F000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$F000,$0000,$0000

zip1: dc.w 3,0,20,12,0,0
	dc.w	$0000,$0080,$0000,$0080,$0000,$0100,$0000,$0100
	dc.w	$0000,$0500,$0000,$0500,$0000,$0300,$0000,$0300
	dc.w	$0000,$0FC0,$0000,$0300,$0000,$0B40,$0000,$0000
	dc.w	$0300,$3C80,$0300,$0000,$0780,$C000,$0780,$0000
	dc.w	$0FC0,$0000,$0FC0,$0000,$0FC0,$0000,$0FC0,$0000
	dc.w	$0300,$0CC0,$0300,$0CC0,$0FC0,$1020,$0FC0,$1020
	dc.w	$5768,$0CC0,$5BA8,$0CC0,$7FF8,$0000,$7FF8,$0000
	dc.w	$7FF8,$0000,$7FF8,$0000,$3D70,$0280,$3D70,$0280
	dc.w	$3FF0,$0000,$3FF0,$0000,$3FF0,$0000,$3FF0,$0000
	dc.w	$35B0,$0FC0,$37B0,$0FC0,$1DE0,$0300,$1FE0,$0300
	dc.w	$0FC0,$0000,$0FC0,$0000
zip2: dc.w 3,0,22,12,0,0
	dc.w	$0000,$0200,$0000,$0200,$0000,$0200,$0000,$0200
	dc.w	$0000,$0100,$0000,$0100,$0000,$0700,$0000,$0700
	dc.w	$0000,$8FC0,$0000,$0300,$0000,$6B40,$0000,$0000
	dc.w	$0300,$1C80,$0300,$0000,$0780,$0000,$0780,$0000
	dc.w	$0FC0,$0000,$0FC0,$0000,$0300,$0CC0,$0300,$0CC0
	dc.w	$0FC0,$0000,$0FC0,$0000,$0300,$1CE0,$0FC0,$1CE0
	dc.w	$5768,$0CC0,$5BA8,$0CC0,$7FF8,$0000,$7FF8,$0000
	dc.w	$7FF8,$0000,$7FF8,$0000,$3D70,$0280,$3D70,$0280
	dc.w	$3FF0,$0000,$3FF0,$0000,$3FF0,$0000,$3FF0,$0000
	dc.w	$35B0,$0FC0,$37B0,$0FC0,$3130,$0FC0,$3330,$0FC0
	dc.w	$37B0,$0840,$37B0,$0840,$1FE0,$0000,$1FE0,$0000
	dc.w	$0FC0,$0000,$0FC0,$0000
yac1: dc.w 3,0,11,10,0,0
	dc.w	$4040,$4040,$4040,$4040,$8220,$8220,$8020,$8020
	dc.w	$9520,$9520,$8020,$8020,$CE60,$CE60,$C060,$C060
	dc.w	$7FC0,$7FC0,$60C0,$60C0,$3F80,$3F80,$2080,$3180
	dc.w	$1F00,$1F00,$0000,$0000,$1F00,$1F00,$0000,$0000
	dc.w	$0E00,$0E00,$0000,$0000,$0400,$0E00,$0000,$0000
	dc.w	$1100,$1100,$0000,$0000,$0E00,$0E00,$0000,$0000
yac2: dc.w 3,0,13,10,0,0
	dc.w	$4040,$4040,$4040,$4040,$8220,$8220,$8020,$8020
	dc.w	$9520,$9520,$8020,$8020,$CE60,$CE60,$C060,$C060
	dc.w	$7FC0,$7FC0,$60C0,$60C0,$3F80,$3F80,$2080,$3B80
	dc.w	$1F00,$1F00,$0000,$0000,$1F00,$1F00,$0000,$0000
	dc.w	$0E00,$0E00,$0000,$0000,$0400,$0E00,$0000,$0000
	dc.w	$0A00,$0E00,$0E00,$0E00,$1100,$1100,$0000,$0000
	dc.w	$1B00,$1F00,$0E00,$0E00,$0E00,$0E00,$0000,$0000

nki1: dc.w 3,0,15,8,0,0
	dc.w	$0080,$0000,$0000,$0000,$0000,$0100,$0000,$0000
	dc.w	$0000,$0200,$0000,$0000,$2000,$2200,$1C00,$0000
	dc.w	$3800,$0000,$0600,$0000,$0000,$0000,$3E00,$0000
	dc.w	$3000,$3000,$0C00,$0000,$0000,$0000,$1800,$0000
	dc.w	$1800,$1800,$2400,$0000,$3200,$3200,$0C00,$0000
	dc.w	$6300,$6300,$1C00,$0000,$0000,$0000,$3C00,$0000
	dc.w	$0400,$0400,$3800,$0000,$0600,$0600,$3000,$0000
	dc.w	$0200,$0200,$6000,$0000,$0600,$0600,$C000,$0000

nki2: dc.w 3,0,15,8,0,0
	dc.w	$0000,$0000,$0000,$0000,$0080,$0000,$0000,$0000
	dc.w	$0000,$0100,$0000,$0000,$2000,$2200,$1C00,$0000
	dc.w	$3800,$0000,$0600,$0000,$0000,$0000,$3E00,$0000
	dc.w	$3000,$3000,$0C00,$0000,$0000,$0000,$1800,$0000
	dc.w	$1800,$1800,$2400,$0000,$1800,$1800,$2400,$0000
	dc.w	$1800,$1800,$2400,$0000,$1800,$1800,$2400,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0000,$1800,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0000,$3800,$0000

nki3: dc.w 3,0,15,8,0,0
	dc.w	$0000,$0000,$0000,$0000,$4800,$0000,$0000,$0000
	dc.w	$0000,$4800,$0000,$0000,$0000,$4800,$3000,$0000
	dc.w	$0000,$0000,$7800,$0000,$0000,$0000,$7800,$0000
	dc.w	$4800,$4800,$3000,$0000,$0000,$0000,$3000,$0000
	dc.w	$8400,$8400,$7800,$0000,$B400,$8400,$4800,$0000
	dc.w	$8000,$8000,$7800,$0000,$3800,$3800,$4000,$0000
	dc.w	$4000,$4000,$0800,$0000,$4000,$4000,$0800,$0000
	dc.w	$C000,$C000,$0800,$0000,$0000,$0000,$0C00,$0000

nki4: dc.w 3,0,15,8,0,0
	dc.w	$4800,$0000,$0000,$0000,$0000,$4800,$0000,$0000
	dc.w	$0000,$4800,$0000,$0000,$0000,$4800,$3000,$0000
	dc.w	$0000,$0000,$7800,$0000,$0000,$0000,$7800,$0000
	dc.w	$4800,$4800,$3000,$0000,$0000,$0000,$3000,$0000
	dc.w	$8400,$8400,$7800,$0000,$B400,$8400,$4800,$0000
	dc.w	$0400,$0400,$7800,$0000,$7000,$7000,$0800,$0000
	dc.w	$0800,$0800,$4000,$0000,$0800,$0800,$4000,$0000
	dc.w	$0C00,$0C00,$4000,$0000,$0000,$0000,$C000,$0000

nki5: dc.w 3,0,15,8,0,0
	dc.w	$0000,$0000,$0000,$0000,$4800,$0000,$0000,$0000
	dc.w	$0000,$4800,$0000,$0000,$4800,$4800,$3000,$0000
	dc.w	$7800,$0000,$0000,$0000,$0000,$0000,$7800,$0000
	dc.w	$4800,$4800,$3000,$0000,$0000,$0000,$3000,$0000
	dc.w	$8400,$8400,$7800,$0000,$B400,$B400,$4800,$0000
	dc.w	$8000,$8000,$7800,$0000,$3800,$3800,$4000,$0000
	dc.w	$4000,$4000,$0800,$0000,$4000,$4000,$0800,$0000
	dc.w	$C000,$C000,$0800,$0000,$0000,$0000,$0C00,$0000

nki6: dc.w 3,0,15,8,0,0
	dc.w	$4800,$0000,$0000,$0000,$0000,$4800,$0000,$0000
	dc.w	$0000,$4800,$0000,$0000,$4800,$4800,$3000,$0000
	dc.w	$7800,$0000,$0000,$0000,$0000,$0000,$7800,$0000
	dc.w	$4800,$4800,$3000,$0000,$0000,$0000,$3000,$0000
	dc.w	$8400,$8400,$7800,$0000,$B400,$B400,$4800,$0000
	dc.w	$0400,$0400,$7800,$0000,$7000,$7000,$0800,$0000
	dc.w	$0800,$0800,$4000,$0000,$0800,$0800,$4000,$0000
	dc.w	$0C00,$0C00,$4000,$0000,$0000,$0000,$C000,$0000

nki7: dc.w 3,0,15,8,0,0
	dc.w	$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
	dc.w	$0000,$4000,$0000,$0000,$0200,$2200,$1C00,$0000
	dc.w	$0E00,$0000,$3000,$0000,$0000,$0000,$3E00,$0000
	dc.w	$0600,$0600,$1800,$0000,$0000,$0000,$0C00,$0000
	dc.w	$0C00,$0C00,$1200,$0000,$0C00,$0C00,$1200,$0000
	dc.w	$0C00,$0C00,$1200,$0000,$0C00,$0C00,$1200,$0000
	dc.w	$0000,$0000,$0C00,$0000,$0000,$0000,$0C00,$0000
	dc.w	$0000,$0000,$0C00,$0000,$0000,$0000,$0E00,$0000

nki8: dc.w 3,0,15,8,0,0
	dc.w	$8000,$0000,$0000,$0000,$0000,$4000,$0000,$0000
	dc.w	$0000,$2000,$0000,$0000,$0200,$2200,$1C00,$0000
	dc.w	$0E00,$0000,$3000,$0000,$0000,$0000,$3E00,$0000
	dc.w	$0600,$0600,$1800,$0000,$0000,$0000,$0C00,$0000
	dc.w	$0C00,$0C00,$1200,$0000,$2600,$2600,$1800,$0000
	dc.w	$6300,$6300,$1C00,$0000,$0000,$0000,$1E00,$0000
	dc.w	$1000,$1000,$0E00,$0000,$3000,$3000,$0600,$0000
	dc.w	$2000,$2000,$0300,$0000,$3000,$3000,$0180,$0000

nel1: dc.w 3,0,9,9,0,0
	dc.w	$FFC0,$0000,$0000,$C0C0,$00C0,$0000,$0000,$0040
	dc.w	$FEC0,$0000,$0000,$C600,$C6C0,$0000,$0000,$8200
	dc.w	$C6C0,$0000,$0000,$0000,$D6C0,$0000,$0000,$0000
	dc.w	$D6C0,$0000,$0000,$0200,$DEC0,$0000,$0000,$0600
	dc.w	$C0C0,$0000,$0000,$8040,$FFC0,$0000,$0000,$C0C0
nel2: dc.w 3,0,11,11,0,0
	dc.w	$0900,$0000,$0000,$0000,$1980,$0000,$0000,$0000
	dc.w	$39C0,$0000,$0000,$0000,$70E0,$0000,$0900,$0000
	dc.w	$E970,$0900,$1080,$0000,$0000,$0600,$0000,$0000
	dc.w	$0000,$0600,$0000,$0000,$E970,$0900,$1080,$0000
	dc.w	$70E0,$0000,$0900,$0000,$39C0,$0000,$0000,$0000
	dc.w	$1980,$0000,$0000,$0000,$0900,$0000,$0000,$0000
nel3: dc.w 3,0,13,15,0,0
	dc.w	$6000,$0000,$0000,$0000,$3000,$0000,$0000,$0000
	dc.w	$5000,$0000,$0000,$0000,$F000,$0000,$0000,$0000
	dc.w	$3000,$0000,$0000,$0000,$381E,$0000,$0000,$0000
	dc.w	$3FF3,$0000,$0000,$0000,$3DD6,$0000,$0000,$0000
	dc.w	$1770,$0000,$0000,$0000,$1AF0,$0000,$0000,$0000
	dc.w	$1D60,$0000,$0000,$0000,$1860,$0000,$0000,$0000
	dc.w	$1860,$0000,$0000,$0000,$38E0,$0000,$0000,$0000

strn1: dc.w 3,0,4,7,0,0
		dc.w	$3F00,$3F00,$3900,$3900,$4000,$7900,$7F00,$7900
		dc.w	$9F00,$7F00,$7900,$7900,$7F00,$7F00,$7900,$7900
		dc.w	$0000,$3F00,$0000,$3900
strn2: dc.w 3,0,6,6,0,0
	dc.w	$1000,$1800,$0800,$0800,$2C00,$2C00,$1400,$0400
	dc.w	$5C00,$7E00,$6000,$6200,$B800,$FE00,$F000,$F000
	dc.w	$B000,$FC00,$F000,$F800,$2000,$F800,$E000,$F800
	dc.w	$C000,$7000,$4000,$7000
strn3: dc.w 3,0,7,4,0,0
	dc.w	$B000,$F800,$F000,$F800,$B000,$B800,$4000,$0000
	dc.w	$B000,$B800,$4000,$0000,$B000,$F800,$F000,$F800
	dc.w	$B000,$F800,$F000,$F800,$9000,$F800,$F000,$F800
	dc.w	$5000,$7000,$7000,$7000,$2000,$0000,$0000,$0000
strn4: dc.w 3,0,6,6,0,0
	dc.w	$0000,$3000,$0000,$2000,$6000,$7800,$4000,$4000
	dc.w	$7000,$FC00,$8000,$8C00,$B800,$BE00,$5800,$1E00
	dc.w	$5C00,$7E00,$3C00,$3E00,$2200,$3E00,$3E00,$3E00
	dc.w	$1A00,$1C00,$1C00,$1C00
strn5: dc.w 3,0,4,7,0,0
	dc.w	$0000,$FC00,$0000,$9C00,$FE00,$FE00,$9E00,$9E00
	dc.w	$F900,$FE00,$9E00,$9E00,$0200,$9E00,$FE00,$9E00
	dc.w	$FC00,$FC00,$9C00,$9C00
strn6: dc.w 3,0,6,6,0,0
	dc.w	$0600,$1C00,$0400,$1C00,$0800,$3E00,$0E00,$3E00
	dc.w	$1A00,$7E00,$1E00,$3E00,$3A00,$FE00,$1E00,$1E00
	dc.w	$7400,$FC00,$0C00,$8C00,$6800,$6800,$5000,$4000
	dc.w	$1000,$3000,$2000,$2000
strn7: dc.w 3,0,7,4,0,0
	dc.w	$2000,$0000,$0000,$0000,$5000,$7000,$7000,$7000
	dc.w	$4800,$F800,$7800,$F800,$6800,$F800,$7800,$F800
	dc.w	$6800,$F800,$7800,$F800,$6800,$E800,$1000,$0000
	dc.w	$6800,$E800,$1000,$0000,$6800,$F800,$7800,$F800
strn8: dc.w 3,0,6,6,0,0
	dc.w	$B000,$7000,$7000,$7000,$8800,$F800,$F800,$F800
	dc.w	$7400,$FC00,$7800,$F800,$3A00,$FA00,$3400,$F000
	dc.w	$1C00,$7E00,$0200,$6200,$0C00,$3C00,$0400,$0400
	dc.w	$0000,$1800,$0000,$0800
tseg1: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$07E0,$0000,$03E8,$03E8,$1C10,$0000
	dc.w	$0E38,$0E38,$3004,$0000,$0C0E,$0C0E,$7000,$0000
	dc.w	$1802,$1802,$6004,$0000,$3807,$1807,$C000,$0000
	dc.w	$1003,$1003,$6000,$0000,$0003,$0003,$0000,$0000
	dc.w	$0001,$0003,$0000,$0000,$0003,$0003,$0000,$0000
	dc.w	$0003,$8007,$0000,$0000,$0002,$0006,$0000,$0000
	dc.w	$0004,$400E,$0000,$0000,$0010,$303C,$0000,$0000
	dc.w	$05C0,$1FF8,$0000,$0000,$0000,$07E0,$0000,$0000
tseg2: dc.w 3,0,15,15,0,0
	dc.w	$01F0,$01F0,$0600,$0000,$07FC,$07FC,$1800,$0000
	dc.w	$0C1E,$0C1E,$3000,$0000,$1002,$1006,$6000,$0000
	dc.w	$1003,$1007,$6000,$0000,$3001,$3003,$4000,$0000
	dc.w	$3001,$3003,$C000,$0000,$1000,$1003,$E000,$0000
	dc.w	$3800,$3803,$C000,$0000,$3800,$1803,$4000,$0000
	dc.w	$0000,$0003,$7000,$0000,$0004,$0006,$0000,$0000
	dc.w	$0008,$000E,$0000,$0000,$0010,$001C,$0000,$0000
	dc.w	$0000,$0078,$0000,$0000,$0000,$05C0,$0000,$0000
tseg3: dc.w 3,0,15,15,0,0
	dc.w	$07E0,$07E0,$0000,$0000,$1F70,$1FF8,$0000,$0000
	dc.w	$1408,$143C,$2800,$0000,$7000,$700E,$0000,$0000
	dc.w	$2004,$2006,$4000,$0000,$6000,$6007,$8000,$0000
	dc.w	$4002,$4003,$8000,$0000,$4002,$4003,$8000,$0000
	dc.w	$4002,$4003,$8000,$0000,$6000,$6003,$8000,$0000
	dc.w	$3002,$3003,$C000,$0000,$3C00,$3C02,$4000,$0000
	dc.w	$0E00,$0E06,$7000,$0000,$0400,$0004,$3A00,$0000
	dc.w	$0000,$0008,$1E00,$0000,$0000,$0020,$0400,$0000
tseg4: dc.w 3,0,15,15,0,0
	dc.w	$0E00,$0FE0,$0000,$0000,$3800,$3FF8,$0000,$0000
	dc.w	$6010,$781C,$0000,$0000,$6008,$600E,$0000,$0000
	dc.w	$E004,$E006,$0000,$0000,$C000,$C002,$0000,$0000
	dc.w	$C000,$C003,$0000,$0000,$C000,$C001,$0000,$0000
	dc.w	$C000,$C001,$0000,$0000,$4000,$4000,$8000,$0000
	dc.w	$6000,$6001,$8000,$0000,$20C0,$20C0,$4000,$0000
	dc.w	$1FC0,$1FC0,$6020,$0000,$06C0,$0680,$3920,$0000
	dc.w	$0000,$0000,$1FE0,$0000,$0000,$0000,$0380,$0000
tseg5: dc.w 3,0,15,15,0,0
	dc.w	$0000,$07E0,$0000,$0000,$03A0,$1FF8,$0000,$0000
	dc.w	$0800,$3C0C,$0000,$0000,$2000,$7002,$0000,$0000
	dc.w	$4000,$6000,$0000,$0000,$C000,$E001,$0000,$0000
	dc.w	$C000,$C000,$0000,$0000,$8000,$C000,$0000,$0000
	dc.w	$C000,$C000,$0000,$0000,$C008,$C008,$0006,$0000
	dc.w	$E01C,$E018,$0003,$0000,$4018,$4018,$2006,$0000
	dc.w	$7030,$7030,$000E,$0000,$1C70,$1C70,$200C,$0000
	dc.w	$17C0,$17C0,$0838,$0000,$0000,$0000,$07E0,$0000

tseg6: dc.w 3,0,15,15,0,0
	dc.w	$0000,$03A0,$0000,$0000,$0000,$1E00,$0000,$0000
	dc.w	$0800,$3800,$0000,$0000,$1000,$7000,$0000,$0000
	dc.w	$2000,$6000,$0000,$0000,$0000,$C000,$000E,$0000
	dc.w	$001C,$C018,$0002,$0000,$001C,$C01C,$0003,$0000
	dc.w	$0008,$C008,$0007,$0000,$800C,$C00C,$0003,$0000
	dc.w	$800C,$C00C,$0002,$0000,$C008,$E008,$0006,$0000
	dc.w	$4008,$6008,$0006,$0000,$7830,$7830,$000C,$0000
	dc.w	$3FE0,$3FE0,$0018,$0000,$0F80,$0F80,$0060,$0000
tseg7: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0400,$0020,$0000,$0000,$1000,$0078,$0000
	dc.w	$0020,$2000,$005C,$0000,$0070,$6070,$000E,$0000
	dc.w	$003C,$403C,$0002,$0000,$400C,$C00C,$0003,$0000
	dc.w	$0006,$C006,$0001,$0000,$4002,$C002,$0001,$0000
	dc.w	$4002,$C002,$0001,$0000,$4002,$C002,$0001,$0000
	dc.w	$0006,$E006,$0001,$0000,$2004,$6004,$0002,$0000
	dc.w	$000E,$700E,$0000,$0000,$1028,$3C28,$0014,$0000
	dc.w	$0EF8,$1FF8,$0000,$0000,$07E0,$07E0,$0000,$0000
tseg8: dc.w 3,0,15,15,0,0
	dc.w	$0000,$0000,$01C0,$0000,$0000,$0000,$07F8,$0000
	dc.w	$0360,$0160,$049C,$0000,$03F8,$03F8,$0406,$0000
	dc.w	$0304,$0304,$0002,$0000,$0006,$8006,$0001,$0000
	dc.w	$0002,$0002,$0001,$0000,$0003,$8003,$0000,$0000
	dc.w	$0003,$8003,$0000,$0000,$0003,$C003,$0000,$0000
	dc.w	$0003,$4003,$0000,$0000,$2007,$6007,$0000,$0000
	dc.w	$1006,$7006,$0000,$0000,$0806,$381E,$0000,$0000
	dc.w	$001C,$1FFC,$0000,$0000,$0070,$07F0,$0000,$0000
thead: dc.w 3,1,28,24,0,0
	dc.w	$0008,$0008,$0000,$0008,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$001C,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$001C,$0000,$0000,$0000,$0000
	dc.w	$003E,$0036,$0000,$0036,$0000,$0000,$0000,$0000
	dc.w	$007F,$0063,$0000,$0077,$0000,$0000,$0000,$0000
	dc.w	$007F,$0041,$0000,$0077,$0000,$0000,$0000,$0000
	dc.w	$00FF,$00A2,$0000,$00E3,$8000,$8000,$0000,$8000
	dc.w	$00F7,$0084,$0008,$00C1,$8000,$8000,$0000,$8000
	dc.w	$00FF,$008C,$0000,$00C1,$8000,$8000,$0000,$8000
	dc.w	$01FF,$0100,$0000,$0180,$C000,$4000,$0000,$C000
	dc.w	$01BF,$0120,$0040,$0180,$4000,$4000,$8000,$0000
	dc.w	$01CD,$0189,$0032,$01C0,$C000,$C000,$0000,$C000
	dc.w	$03F3,$03E3,$000C,$03E1,$E000,$E000,$0000,$E000
	dc.w	$047F,$0440,$0380,$0400,$F000,$3000,$0000,$F000
	dc.w	$039F,$0210,$0C60,$0000,$C800,$0800,$3000,$0000
	dc.w	$0FEF,$0808,$1010,$0400,$9400,$0400,$6800,$1000
	dc.w	$3FEF,$3808,$0010,$3C00,$7A00,$4A00,$8400,$1800
	dc.w	$7F1B,$701A,$00E4,$7C00,$7B00,$4300,$8400,$1900
	dc.w	$7EEC,$6088,$0113,$7000,$FB00,$8300,$0400,$0100
	dc.w	$FFF7,$C004,$0008,$E000,$FB80,$0180,$0400,$0380
	dc.w	$7FF7,$6004,$0008,$7000,$E700,$0700,$1800,$0300
	dc.w	$0FF7,$0004,$F008,$0800,$DE00,$1600,$2000,$0E00
	dc.w	$33CF,$3008,$0C30,$2000,$FE00,$0600,$0000,$0E00
	dc.w	$1C3F,$1C20,$03C0,$1800,$FC00,$0C00,$0000,$1C00
	dc.w	$1FFF,$1800,$0000,$1C00,$FC00,$0C00,$0000,$1C00
	dc.w	$0FFF,$0C00,$0000,$0C08,$F800,$1800,$0000,$1800
	dc.w	$07FF,$0400,$0000,$071C,$F000,$1000,$0000,$7000
	dc.w	$03FF,$0308,$0000,$03FF,$E000,$6000,$0000,$E000
	dc.w	$01F7,$01F7,$0000,$01F7,$C000,$C000,$0000,$C000

xxx1: dc.w 3,1,31,31,0,0
	dc.w	$0000,$0000,$0002,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0001,$0000,$0000,$0000,$C000,$0000
	dc.w	$0000,$0000,$0001,$0000,$0000,$0000,$8000,$0000
	dc.w	$0000,$000C,$0003,$0000,$0000,$7C00,$8000,$0000
	dc.w	$0000,$0050,$0001,$0000,$0000,$0400,$8000,$0000
	dc.w	$0000,$0074,$0003,$0000,$0000,$7700,$8000,$0000
	dc.w	$0000,$01F8,$0007,$0000,$0000,$1D00,$C000,$0000
	dc.w	$0000,$035E,$0001,$0000,$0000,$17C0,$E000,$0000
	dc.w	$0002,$02FE,$0001,$0000,$6000,$7D40,$8000,$0000
	dc.w	$000E,$0B4E,$0031,$0000,$7800,$7BA0,$8000,$0000
	dc.w	$0000,$0BC0,$003F,$0000,$1800,$1AE0,$E400,$0000
	dc.w	$0000,$0EC0,$003F,$0000,$0A00,$0BA8,$F400,$0000
	dc.w	$0060,$04E0,$031F,$0000,$0700,$07E8,$F800,$0000
	dc.w	$0040,$1C40,$61BF,$0000,$0300,$0358,$FCA4,$0000
	dc.w	$0000,$0000,$3FFF,$0000,$0380,$0380,$FC7A,$0000
	dc.w	$0000,$0000,$FFFF,$0000,$0000,$0000,$FFFC,$0000
	dc.w	$0000,$0000,$FFFF,$0000,$0000,$0000,$FFFE,$0000
	dc.w	$0000,$0000,$4FFF,$0000,$0380,$03F4,$FC08,$0000
	dc.w	$0000,$3D00,$00FF,$0000,$0000,$0000,$FF40,$0000
	dc.w	$0000,$0780,$007F,$0000,$0100,$01F8,$FE00,$0000
	dc.w	$0070,$0EF0,$000F,$0000,$0F00,$0F50,$F000,$0000
	dc.w	$0008,$0FC8,$0037,$0000,$0A00,$0BE0,$F400,$0000
	dc.w	$0018,$07B8,$0007,$0000,$0000,$00D0,$FE00,$0000
	dc.w	$0008,$0AF8,$0007,$0000,$3800,$3F80,$C000,$0000
	dc.w	$0000,$01BC,$0003,$0000,$2000,$35C0,$8000,$0000
	dc.w	$0000,$02D6,$0001,$0000,$0000,$3C00,$C000,$0000
	dc.w	$0000,$003E,$0001,$0000,$0000,$2F00,$C000,$0000
	dc.w	$0000,$0030,$0003,$0000,$0000,$0000,$C000,$0000
	dc.w	$0000,$000C,$0003,$0000,$0000,$2C00,$C000,$0000
	dc.w	$0000,$0000,$0001,$0000,$0000,$0000,$8000,$0000
	dc.w	$0000,$0000,$0001,$0000,$0000,$0000,$C000,$0000
	dc.w	$0000,$0000,$0003,$0000,$0000,$0000,$0000,$0000

xxx2: dc.w 3,1,31,31,0,0
	dc.w	$0000,$0021,$0000,$0000,$0000,$8200,$0000,$0000
	dc.w	$0000,$0221,$0000,$0000,$0000,$8400,$0000,$0000
	dc.w	$0000,$0A0F,$0000,$0000,$8000,$F8C0,$0000,$0000
	dc.w	$0001,$247F,$0000,$0000,$C000,$FF10,$0000,$0000
	dc.w	$000F,$00FF,$0000,$0000,$7000,$7F20,$8000,$0000
	dc.w	$003E,$21FE,$0001,$0000,$7C00,$7F8C,$8000,$0000
	dc.w	$0078,$53F8,$0007,$0000,$3E00,$3FC0,$C000,$0000
	dc.w	$01E0,$27E0,$001F,$0000,$0F80,$0FE0,$F000,$0000
	dc.w	$0180,$8F80,$007F,$0000,$0380,$03F6,$FC00,$0000
	dc.w	$0302,$1F03,$00FC,$0000,$01C0,$01F8,$FE00,$0000
	dc.w	$070C,$1F0D,$00F0,$0000,$C1E0,$C1F8,$3E00,$0000
	dc.w	$0604,$9E2E,$01D0,$0000,$B0E0,$F0F8,$0F00,$0000
	dc.w	$0E28,$3E38,$01C0,$0000,$00F0,$00FC,$3F00,$0000
	dc.w	$0C00,$3C10,$03E0,$0000,$1870,$B87C,$0780,$0000
	dc.w	$0C40,$3C50,$0380,$0000,$0030,$203C,$0FC0,$0000
	dc.w	$3040,$F064,$0F80,$0000,$0838,$083F,$37C0,$0000
	dc.w	$1800,$F820,$07C0,$0000,$2858,$285F,$07A0,$0000
	dc.w	$0C00,$3C28,$0380,$0000,$0830,$083C,$17C0,$0000
	dc.w	$0C00,$3C01,$03F0,$0000,$3070,$707C,$0F80,$0000
	dc.w	$0E30,$BE3A,$01C0,$0000,$10F0,$90FC,$6F00,$0000
	dc.w	$0614,$1E15,$01E8,$0000,$40E0,$40F8,$3F00,$0000
	dc.w	$0706,$3F06,$00F9,$0000,$81E0,$81FB,$7E00,$0000
	dc.w	$0300,$5F00,$00FF,$0000,$01C0,$01F9,$FE00,$0000
	dc.w	$0180,$0F80,$007F,$0000,$0380,$03F8,$FC00,$0000
	dc.w	$01E0,$4FE0,$001F,$0000,$0F80,$0FE4,$F000,$0000
	dc.w	$0078,$13F8,$0007,$0000,$3E00,$3FC0,$C000,$0000
	dc.w	$003D,$11FD,$0002,$0000,$7C00,$7F90,$8000,$0000
	dc.w	$000E,$02FE,$0001,$0000,$F000,$FF08,$0000,$0000
	dc.w	$0003,$047F,$0000,$0000,$8000,$FE08,$0000,$0000
	dc.w	$0001,$008F,$0000,$0000,$8000,$F100,$0000,$0000
	dc.w	$0001,$01A1,$0000,$0000,$8000,$88C0,$0000,$0000
	dc.w	$0000,$0031,$0000,$0000,$0000,$8C00,$0000,$0000
xxx3: dc.w 3,1,31,31,0,0
	dc.w	$0000,$0008,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$4000,$0000,$0000
	dc.w	$0000,$0113,$0000,$0000,$0000,$0200,$0000,$0000
	dc.w	$0000,$0000,$0001,$0000,$C000,$C800,$0000,$0000
	dc.w	$0016,$0056,$0001,$0000,$0000,$0600,$6000,$0000
	dc.w	$0010,$0130,$000A,$0000,$1A00,$1A40,$6400,$0000
	dc.w	$0000,$0800,$0089,$0000,$0000,$0080,$1200,$0000
	dc.w	$0080,$0080,$0020,$0000,$0100,$01C0,$1400,$0000
	dc.w	$0180,$5980,$0000,$0000,$0000,$0008,$0280,$0000
	dc.w	$0600,$1600,$0100,$0000,$0060,$0060,$0C80,$0000
	dc.w	$0000,$0000,$0400,$0000,$0000,$0010,$0240,$0000
	dc.w	$1000,$3000,$0600,$0000,$0020,$0028,$0080,$0000
	dc.w	$0800,$A800,$0080,$0000,$0000,$0000,$01D0,$0000
	dc.w	$0000,$0000,$0C00,$0000,$0010,$0012,$0000,$0000
	dc.w	$0800,$0800,$0500,$0000,$0000,$0006,$0030,$0000
	dc.w	$1800,$5800,$0100,$0000,$0010,$0018,$0100,$0000
	dc.w	$1000,$5000,$0800,$0000,$0008,$0008,$0070,$0000
	dc.w	$0000,$8000,$0C00,$0000,$0010,$0010,$0000,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0001,$00D0,$0000
	dc.w	$0800,$0800,$2600,$0000,$0010,$0018,$0020,$0000
	dc.w	$0000,$0000,$0000,$0000,$0010,$0012,$0020,$0000
	dc.w	$1400,$1400,$0200,$0000,$0000,$0000,$0590,$0000
	dc.w	$0400,$8400,$0200,$0000,$0030,$0038,$04C0,$0000
	dc.w	$0A00,$3A00,$0180,$0000,$0000,$0022,$0200,$0000
	dc.w	$0800,$1800,$0700,$0000,$0040,$0062,$0B00,$0000
	dc.w	$0080,$0080,$0078,$0000,$00C0,$00C0,$3A00,$0000
	dc.w	$0200,$6200,$012D,$0000,$0080,$00C8,$5900,$0000
	dc.w	$0040,$0040,$000D,$0000,$0900,$0940,$7200,$0000
	dc.w	$0060,$0B60,$0019,$0000,$3000,$3C20,$0000,$0000
	dc.w	$0004,$019C,$0000,$0000,$8000,$C000,$0000,$0000
	dc.w	$0000,$0089,$0000,$0000,$0000,$4900,$0000,$0000
	dc.w	$0000,$0024,$0000,$0000,$0000,$0000,$0000,$0000



lex: dc.w 33,307,308,309

pauos: dc.l pauo1,pauo2,pauo3,pauo4
pauo: dc.l 0

nummies: dc.l gnum1,gnum2,gnum3,gnum4,gnum5,gnum6,gnum7,gnum8,gnum9,gnum10


maxgrunt: dc.w 27


lives: dc.w 0
nowgrunt: dc.w 0
level: dc.w 0
tbspdx: dc.w 10
tbspdy: dc.w 10
_herd: dc.w 0
gcv: dc.w $0f
boon: dc.w 0
grmode: dc.w 0
grshld: dc.w 0
frvel: dc.w 0
gksmode: dc.w 1
jiv: dc.w 2
brainfyr: dc.w 0
brainspd: dc.w 0
luv: dc.w 1
purq: dc.w 0
pclean: dc.w 2
shbase: dc.w 0
 ds.b 62
oldwave: ds.b 100
p2space: ds.b 200
droidz: dc.l droi1,droi2,droi3,droi2

nbulls: dc.w 31

baitim: dc.w 220,220,220

clock: dc.w 0
bigfire: dc.w -1

msgtab: dc.w 99,0
	dc.l msg_01
	dc.w 98,0
	dc.l msg_02
	dc.w 0,0
	dc.l msg_03
	dc.w 4,0
	dc.l msg_04
	dc.w 16,0
	dc.l msg_05
	dc.w -1

msg_01: dc.b '\g',0,60,'\c1\qyou"re awesome!!',0
	dc.b '\r\qgrab these bonus beasties!',0
	dc.b '\r\r\qnow it gets harder. . .',0,'\e'

msg_02: dc.b '\g',0,60,'\c1\qthe ozric tentacle',0,'\e'

msg_03: dc.b '\g',0,60,'\c1\qkill grunts',0,'\r\qgrab beasties',0,'\e'

msg_04: dc.b '\g',0,60,'\c1\qbrains grab beasties',0
	dc.b '\r\qto make zombeasts!',0,'\e'

msg_05: dc.b '\g',0,60,'\c1\qin a herd wave',0,'\r\qyou must grab all beasties',0,'\e'


wave1: dc.b -8,$40,-1,1,1,-2,0,0,0,0,-5,0,$30,0,0,0,1,30,-1,-1
wave2: dc.b 0,0,1,1,33,-1,-1
wave3: dc.b 0,0,1,1,40,4,0,-1,-1
wave4: dc.b -1,2,2,0,0,2,3,0,1,33,-1,-1
wave5: dc.b -3,7,1,6,0,0,0,5,13,5,1,20,-1,-1
wave6: dc.b 0,0,3,3,1,1,30,4,1,-1,-1
wave7: dc.b -1,2,2,0,0,2,3,1,1,33,25,0,-1,-1
wave8: dc.b -1,2,3,0,0,3,3,1,2,1,1,35,4,4,-1,-1
wave9: dc.b 0,0,4,2,10,1,30,29,0,-1,-1
wave10: dc.b -3,5,1,5,0,0,0,5,13,9,1,20,3,0,-1,-1
wave11: dc.b 0,0,0,5,5,8,0,1,10,-1,-1
wave12: dc.b -1,2,2,-6,7,0,0,0,3,28,0,1,30,4,8,-1,-1
wave13: dc.b -1,3,3,0,0,4,2,1,3,3,1,14,4,6,-1,-1
wave14: dc.b -1,3,4,0,0,2,5,1,1,30,23,0,25,0,-1,-1
wave15: dc.b -3,4,1,4,0,0,0,5,13,10,1,4,3,1,4,3,-1,-1
wave16: dc.b 0,0,5,4,15,5,3,1,10,-1,-1
wave17: dc.b -1,4,4,1,1,7,0,15,2,7,4,4,8,0,-1,-1
wave18: dc.b 0,0,1,3,15,4,2,5,2,1,10,-1,-1
wave19: dc.b 0,10,3,7,10,0,10,1,10,29,1,-1,-1
wave20: dc.b -3,3,1,3,0,0,0,8,13,10,1,5,3,2,5,2,-1,-1
wave21: dc.b 0,0,5,1,40,8,0,9,0,-1,-1
wave22: dc.b -1,5,5,0,0,0,11,5,1,15,5,3,4,3,-1,-1
wave23: dc.b -1,5,5,-2,3,0,0,1,0,0,4,1,20,3,2,23,1,-1,-1
wave24: dc.b -2,0,0,0,0,0,0,5,21,3,3,2,-1,-1
wave25: dc.b -2,3,0,0,2,-3,7,1,4,0,0,0,5,13,5,1,20,-1,-1
wave26: dc.b -2,3,0,0,5,-1,4,4,1,0,7,1,30,-1,-1
wave27: dc.b -1,2,2,-2,3,1,0,0,-6,3,0,0,0,3,28,0,1,30,5,4,-1,-1
wave28: dc.b -2,0,0,0,0,-1,2,2,0,0,2,3,1,1,33,4,2,-1,-1
wave29: dc.b -2,0,0,0,0,-1,4,5,0,0,4,15,0,12,5,1,15,29,0,-1,-1
wave30: dc.b -2,3,0,0,5,-3,10,2,5,0,0,0,5,13,9,1,20,-1,-1
wave31: dc.b -2,0,0,0,0,-1,3,3,0,0,1,16,0,2,5,-1,-1
wave32: dc.b -2,0,0,0,0,-4,2,1,-1,3,3,0,0,3,17,10,1,20,3,3,-1,-1
wave33: dc.b -2,0,0,0,0,-1,8,8,0,0,0,1,50,-1,-1
wave34: dc.b -2,3,0,0,6,-1,2,2,0,0,0,1,30,-1,-1
wave35: dc.b -4,8,2,-1,4,4,-3,8,2,5,0,0,0,5,20,9,1,9,13,9,3,0,-1,-1
wave36: dc.b 1,0,10,5,3,8,1,9,1,1,10,-1,-1
wave37: dc.b -2,3,1,0,0,-1,3,3,0,0,5,22,0,1,25,-1,-1
wave38: dc.b -1,4,4,0,0,3,25,0,1,30,3,2,-1,-1
wave39: dc.b -4,6,1,-1,3,4,0,0,1,19,15,1,20,8,0,3,1,29,2,-1,-1
wave40: dc.b -1,3,3,-4,12,4,-3,8,1,3,0,0,0,10,13,4,24,3,23,5,1,10,-1,-1
wave41: dc.b -2,0,0,0,0,-1,2,2,0,0,4,23,7,1,15,12,2,3,5,-1,-1
wave42: dc.b -2,0,0,0,0,-1,4,4,0,0,3,25,1,1,30,4,4,-1,-1
wave43: dc.b 1,0,5,1,30,4,2,-1,-1
wave44: dc.b -1,3,3,-4,12,3,0,0,16,24,5,20,4,1,6,-1,-1
wave45: dc.b -1,6,6,-4,12,4,-3,8,1,3,0,0,0,10,13,9,3,8,-1,-1
wave46: dc.b -1,8,8,0,0,0,26,9,1,30,-1,-1
wave47: dc.b -1,8,8,0,26,29,1,4,-1,-1
wave48: dc.b 1,0,11,27,2,9,1,3,1,-1,-1
wave49: dc.b -2,0,0,0,0,-4,4,1,-1,6,6,0,0,2,18,10,1,20,5,1,4,2,-1,-1
wave50: dc.b -3,8,0,3,0,-5,2,$10,-1,5,5,0,0,10,13,8,25,0,-1,-1
wave51: dc.b -2,3,0,0,5,-1,10,8,0,0,3,1,30,-1,-1
wave52: dc.b -2,3,2,0,0,-1,3,3,0,0,3,27,1,1,40,-1,-1
wave53: dc.b -1,2,2,-2,3,1,0,0,-6,1,0,0,0,3,28,0,1,30,23,7,-1,-1
wave54: dc.b -2,0,0,0,0,-1,6,6,0,0,4,29,4,1,20,26,7,-1,-1
wave55: dc.b -3,8,1,5,0,-5,4,$10,-1,5,5,0,0,6,13,8,29,1,1,10,-1,-1
wave56: dc.b -2,0,0,0,0,-1,6,6,0,0,4,30,3,27,2,1,25,-1,-1
wave57: dc.b -5,1,6,-4,$8,1,0,0,4,31,14,25,0,-1,-1
wave58: dc.b -4,8,0,-1,4,4,-2,14,0,0,0,-6,3,4,0,0,4,1,20,28,0,29,2,-1,-1
wave59: dc.b -4,8,0,-1,4,4,-2,14,0,0,0,-6,3,4,0,0,4,21,1,8,1,-1,-1
wave60: dc.b -3,$10,1,2,0,-5,20,10,0,0,40,13,1,-1,-1
wave61: dc.b 0,0,4,32,1,11,12,2,12,-1,-1
wave62: dc.b -1,6,6,-2,3,1,0,0,0,0,4,33,1,1,30,-1,-1
wave63: dc.b -1,4,4,-2,3,0,0,7,0,0,4,33,3,1,30,-1,-1
wave64: dc.b -5,1,80,0,0,0,25,5,-1,-1
wave65: dc.b -5,2,80,-3,30,1,4,0,1,0,9,13,13,33,1,32,1,-1,-1
wave66: dc.b -1,8,8,-2,3,0,0,2,0,0,9,22,0,21,2,32,8,-1,-1
wave67: dc.b -7,8,16,10,-1,8,8,-2,0,0,0,2,0,0,9,34,1,1,30,-1,-1
wave68: dc.b -7,8,16,10,-1,8,8,-2,0,0,0,2,0,0,2,10,7,34,0,35,0,1,30,-1,-1
wave69: dc.b -7,8,16,10,-4,8,0,2,0,0,0,2,10,7,36,0,37,0,19,30,-1,-1
wave70: dc.b -5,2,80,-3,30,1,4,0,0,0,9,13,13,9,3,-1,-1
wave71: dc.b -1,8,8,-2,3,3,0,2,0,0,1,3,8,1,30,17,10,-1,-1 
wave72: dc.b -7,12,40,10,-2,3,1,0,1,-1,4,5,0,0,4,15,0,12,5,1,15,37,0,36,0,-1,-1
wave73: dc.b -7,12,20,10,1,0,13,35,2,8,2,-1,-1
wave74: dc.b -1,7,7,-2,3,0,0,8,0,0,3,1,40,-1,-1
wave75: dc.b -3,4,1,1,0,-1,7,7,-2,3,0,0,8,-7,4,15,10,0,0,3,1,10,34,0,35,0,9,2,13,7,-1,-1
wave76: dc.b -1,5,5,-2,0,0,0,0,-7,8,4,10,0,0,3,35,0,28,0,4,20,1,10,-1,-1
wave77: dc.b -1,5,5,-2,3,2,0,0,-7,8,4,10,0,0,9,38,9,1,20,-1,-1
wave78: dc.b -1,5,5,-2,0,0,0,0,-7,4,12,1,0,34,1,35,1,36,1,37,1,1,20,3,3,-1,-1
wave79: dc.b -1,5,5,-2,0,0,0,0,-7,14,20,5,0,34,3,1,20,33,3,-1,-1
wave80: dc.b -3,1,1,4,0,-7,14,8,5,-5,4,8,0,0,10,35,0,13,7,25,0,-1,-1
wave81: dc.b -8,$10,-1,6,6,-2,3,1,0,0,0,0,10,21,7,-1,-1
wave82: dc.b -1,6,6,-2,3,0,0,9,0,0,4,1,27,-1,-1
wave83: dc.b -1,6,6,-2,3,0,0,9,0,0,4,1,17,3,8,-1,-1
wave84: dc.b -4,8,2,-1,4,2,-2,3,10,0,9,0,0,4,1,17,17,4,18,4,19,4,-1,-1
wave85: dc.b -1,10,10,-5,6,30,-2,3,0,0,9,-3,7,1,4,0,0,0,5,13,12,1,20,-1,-1
wave86: dc.b 1,0,15,8,5,9,5,-1,-1
wave87: dc.b 0,4,30,5,10,-1,-1
wave88: dc.b 0,12,40,-1,-1
wave89: dc.b 0,5,30,-1,-1
wave90: dc.b -3,110,1,1,0,-5,120,20,0,0,10,3,30,13,0,-1,-1
wave91: dc.b -1,3,3,-2,3,0,0,10,0,0,1,1,30,-1,-1
wave92: dc.b -1,3,3,-2,3,0,0,10,-5,0,20,0,0,5,25,0,30,0,23,4,1,20,-1,-1
wave93: dc.b -1,3,5,-2,3,0,0,10,0,0,5,38,4,1,20,-1,-1
wave94: dc.b -1,2,2,-7,2,50,10,-2,3,0,0,10,0,0,5,16,0,34,0,35,0,36,0,37,0,-1,-1
wave95: dc.b -3,0,4,2,0,-5,40,20,0,0,10,13,0,-1,-1
wave96: dc.b -1,3,3,-2,3,0,0,11,0,0,1,1,30,-1,-1
wave97: dc.b -1,2,2,-2,3,0,0,11,0,0,6,1,10,2,15,-1,-1
wave98: dc.b -1,2,2,-2,3,0,0,11,0,0,4,1,10,33,10,8,0,9,0,-1,-1
wave99: dc.b -7,6,20,5,0,40,0,34,0,35,0,36,0,37,0,-1,-1
wave100: dc.b 1,0,60,-1,-1
 even


levtab: dc.l wave1,wave2,wave3,wave4,wave5,wave6,wave7,wave8
	dc.l wave9,wave10,wave11,wave12,wave13,wave14,wave15,wave16
	dc.l wave17,wave18,wave19,wave20,wave21,wave22,wave23
	dc.l wave24,wave25,wave26,wave27,wave28,wave29,wave30,wave31
	dc.l wave32,wave33,wave34,wave35,wave36,wave37,wave38
	dc.l wave39,wave40,wave41,wave42,wave43,wave44,wave45
	dc.l wave46,wave47,wave48,wave49,wave50,wave51,wave52
	dc.l wave53,wave54,wave55,wave56,wave57,wave58,wave59
	dc.l wave60,wave61,wave62,wave63,wave64,wave65,wave66
	dc.l wave67,wave68,wave69,wave70,wave71,wave72,wave73
	dc.l wave74,wave75,wave76,wave77,wave78,wave79,wave80
	dc.l wave81,wave82,wave83,wave84,wave85,wave86,wave87
	dc.l wave88,wave89,wave90,wave91,wave92,wave93,wave94
	dc.l wave95,wave96,wave97,wave98,wave99,wave100,0




llaunches: dc.l illlama,igrunt,ikill,ifhg,ibug,iglob,iglob1,iglob2
	dc.l ilazr,iylazr,iyy,iblokr,imut,ibrane,ispark,ibog
	dc.l bsinit,iteap,ieyb,ilik,iski,igblok,iftee,iaro
	dc.l ifkil,imandy,itrn,isaf,i16ton,ibrolly,icams
	dc.l iro,ibait,isfhg,ibgun,ibgun2,ibgun3,ibgun4
	dc.l ink,istrn,itent

ghist: ds.b 1024

smcend: dc.l 0
pmode: dc.w 0
smcptr: dc.l smcbuf
trailp: dc.w 0
trailp2: dc.w 2
xpos: dc.w 0
ypos equ xpos+2
buttons equ ypos+2
xoff equ buttons+2
yoff equ xoff+2
ytab equ yoff+2
shipdat equ ytab+8192
colval equ shipdat+16384
back_screen equ colval+2
ascreen equ back_screen+4
bscreen equ ascreen+4
syncreq equ bscreen+4
the_business equ syncreq+2
routine equ the_business+4
freecount equ routine+4 
flags equ freecount+2
aliens equ flags+2
score equ aliens+8192
udscore equ score+8
bulls equ udscore+2
rantab equ bulls+512
ranptr equ rantab+512
trail equ ranptr+4
trail2 equ trail+1024
wptr equ trail2+1024
lscreen equ wptr+4
smcbuf equ lscreen+65512















