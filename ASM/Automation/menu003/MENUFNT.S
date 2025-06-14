font	equ	2050
	move.l a7,a5
	move.l $4(a5),a5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	clr.w -(sp)
	move.w #$4a,-(sp)
	trap #1
	add.l #12,sp
	dc.w $a00a
	move.l #1,-(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp
	cmp.l #0,d0
	bne.s go
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	move.l d0,savesp
	addq.l #6,sp
	move.w #$12,-(sp)
	move.l #$30002,-(sp)
	trap #13
	addq.l #6,sp	
go	move.l #defpal,a1
	lea $ff8240,a0
	moveq.l #15,d0
loopp	move.w (a0)+,(a1)+
	dbf d0,loopp
	move.l $42e,sizeup
	move.w #1,-(sp)
	move.l #$ffffffff,-(sp)
	move.l #$ffffffff,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #$c,sp
	lea $ff8240,a0
	moveq.l #15,d0
ooo	clr.w (a0)+
	dbf d0,ooo
	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	clr.b $484
	bsr setint
	move.b #2,zero2
restart	lea message,a6
nextlet	move.b (a6)+,d0
	cmp.b #$ff,d0
	bne.s notend
	bra.s restart
notend	clr.w d5
	andi.l #$ff,d0
	sub.b #9,d0
	lea fontst,a1
	adda.l d0,a1
	lea build,a2
	moveq.l #7,d7
allchar	move.b (a1),(a2)+
	adda.l #$100,a1
	dbf d7,allchar
test0	cmpi.b #0,zero2
	bne.s sub1
	move.w #37,-(sp)
	trap #14
	addq.l #2,sp
	move.b #2,zero2
sub1	sub.b #1,zero2
key	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,sp
	tst.w d0
	bne keyhit
cont	moveq.l #0,d0
	lea build,a5
	move.l sizeup,a0
	sub.l #$800,a0
	moveq.l #7,d7
lines	move.l a0,-(sp)
	adda.l #$13c,a0
	move.b (a5),d1
	lsl.b #1,d1
	move.b d1,(a5)+
	moveq.l #$27,d6
cols	move.w (a0),d1
	roxl.w #1,d1
	move.w d1,(a0)
	move.w d1,$2(a0)
	subq.l #4,a0
	dbf d6,cols
	movea.l (a7)+,a0
	adda.l #$a0,a0
	dbf d7,lines
	addq.w #1,d5
	andi.w #7,d5
	bne test0
	bra nextlet
keyhit	sub.b #$30,d0
	cmp.b #0,d0
	bcs.s cont
	beq.s hz
	cmp.b #$7,d0
	bcc.s cont
	bra.s load
hz	eor.b #2,$ff820a
	bra.s cont
load	move.l #games,a0
notfo	sub.b #1,d0
	beq.s found
	add.l #$d,a0
	bra.s notfo
found	move.l a0,-(sp)
run	move.w #$2700,sr
	move.w #8,$454
	move.l save70,$70
xxxx	move.b #0,$fffa1b
	move.l save120,$120
	move.b xa07,$fffffa07
	move.b xa09,$fffffa09
	move.b xa13,$fffffa13
	move.b xa21,$fffffa21
	move.b #8,$fffa1b
	move.w #$2300,sr
dp	lea $ff8240,a0
	move.l #defpal,a1
	moveq.l #15,d0
lo	move.w (a1)+,(a0)+
	dbf d0,lo
	move.l (a7)+,a0
	move.l a0,fadd+2
	clr.w -(sp)
	move.l #$ffffffff,-(sp)
	move.l #$ffffffff,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	move.l #1,-(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp
	cmp.l #0,d0
	beq.s user
	move.l savesp,-(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp
user	lea $80000,a7
loadit	move.l #$60000,-(sp)
	move.l #$60000,-(sp)
fadd	move.l #0,-(sp)
	clr.w -(sp)
	move.w #$4b,-(sp)
	trap #1
	add.l #$10,sp
	clr.w -(sp)
	trap #1
	addq.l #2,sp
wait	bra.s wait
setint	move.l $120,save120
	move.l $70,save70
	move.b $fffa07,xa07
	move.b $fffa09,xa09
	move.b $fffa13,xa13
	move.b $fffa21,xa21
	move.l #pals,palsadd
	andi.b #$df,$fffffa09
	andi.b #$fe,$fffffa07
	move.l #int120,$120
	ori.b #1,$fffffa07
	ori.b #1,$fffffa13
	move.l #int70,$70
	rts
sizeup	dc.l $0
xa21	dc.b $0
toggle	dc.b $0
defpal	dc.l $0,$0,$0,$0,$0,$0,$0,$0
save120	dc.l $0	
int70	movem.l a0-a1/d0,-(sp)     
          move.b #0,$fffffa1b
oool	move.b #1,$fffffa21
	move.b #8,$fffffa1b
	move.b #$c8,count
	eori.b #1,toggle
	move.l #pals,palsadd
	cmpi.b #1,toggle
	beq.s fin
	move.l #pass,a0
	move.l #pals,a1
	moveq.l #$1a,d0
lllp	move.w (a1)+,(a0)+
	dbf d0,lllp
	move.w pass,pall
fin	movem.l (a7)+,a0-a1/d0
	dc.w $4ef9
save70	dc.l $0
palsadd	dc.l $0
savesp	dc.l $0
count	dc.b $0
xa07	dc.b $0
xa13	dc.b $0
xa09	dc.b $0
flash2	dc.w $0
flash	dc.w $0
int120	move.l a0,-(sp)
	move.l palsadd,a0
	move.w (a0)+,$ff8240
	move.w #0,$ff8246
	move.l a0,palsadd
	move.l (sp)+,a0
	subq.b #1,count
	cmpi.b #$c0,count
	ble.s tc8
	move.w flash2,flash
	andi.w #$777,flash
	move.w flash,$ff8246
tc8	cmpi.b #$c8,count
	bne.s miss
	addq.w #1,flash2
	clr.b $fffffa21
miss	bclr #0,$fffffa0f
	rte
	even
pass	dc.w $0
pals	dc.l $6000700,$7770777,$7007,$70777,$7770700,$6000000,$0
	dc.l $0,$0,$0,$0,$0
	dc.w $0,$0
pall	dc.w $0
first	dc.l $111,$2220333,$4440555,$6660777,$7770666
	dc.l $5550444,$3330222,$1110000
;	dc.w $0
	dc.l $101,$2020303,$4040505,$6060707,$7070606
	dc.l $5050404,$3030202,$1010000
;	dc.w $0
	dc.l $11,$220033,$440055,$660077,$770066
	dc.l $550044,$330022,$110000
;	dc.w $0
	dc.l $110,$2200330,$4400550,$6600770,$7700660
	dc.l $5500440,$3300220,$1100000
;         *******	dc.w $0
	dc.l $1,$20003,$40005,$60007,$70006
	dc.l $50004,$30002,$10000
;	dc.w $0
	dc.l $10,$200030,$400050,$600070,$700060
	dc.l $500040,$300020,$100000
;	dc.w $0
	dc.l $100,$2000300,$4000500,$6000700,$7000600
	dc.l $5000400,$3000200,$1000000
;	dc.w $0
	dc.l $111,$2220333,$4440555,$6660777,$7770666
	dc.l $5550444,$3330222,$1110000
;	dc.w $0
	dc.l $101,$2020303,$4040505,$6060707,$7070606
	dc.l $5050404,$3030202,$1010000
;	dc.w $0
	dc.l $11,$220033,$440055,$660077,$770066
	dc.l $550044,$330022,$110000
	dc.l $0	
endcols	dc.l $0
;               01234567890123456789012345678901234567 MM 23456789012345678901234567890123456789
text	dc.b $d,$a
	dc.b "                     LSD/WAS (NOT WAS) COMPACTED DISK No.5.",$D,$A,$A,$a
;                                   M       M          MM          M       M
	DC.B "W                      1      Into the Eagles Nest      1                      L",$d,$a,$a
	dc.b "A                      2  Trantor the Last Stormtrooper 2                      S",$d,$a,$a
	dc.b "S                      3            Extensor            3                      D",$d,$a,$a	
	dc.b "N                      4           Knightmare           4                      L",$d,$a,$a
	dc.b "O                      5             Plutos             5                      S",$d,$a,$a
	dc.b "T                      6             Virus              6                      D",$d,$a,$a
	dc.b "W                                                                              L",$d,$a,$a
	dc.b "A                                                                              S",$d,$a,$a
	dc.b "S                                                                              D",$d,$a,$a
	dc.b "                       0         Toggle 50/60hz         0",$d,$a,$0
games	dc.b "eagles.was",$0,$0,$0
game2	dc.b "trantor.was",$0,$0
game3	dc.b "extensor.was",$0
game4	dc.b "knight.lsd",$0,$0,$0
game5	dc.b "plutos.lsd",$0,$0,$0
game6	dc.b "virus.lsd",$0
store	dc.b $0
zero2	dc.b $0
	even
build	dc.l $0,$0,$0,$0
message	dc.b " "
	dc.b "WELL FOLKS! JUST WHAT YOU'VE ALL BEEN WAITING FOR, "
	dc.b "A COLOURFUL COMPACTED MENU WRITTEN BY WAS (NOT WAS). "
	dc.b "THE COMPACTOR WAS WRITTEN BY LSD WHOSE MEMBERS ARE "
	dc.b "OZZ, MARL, REBEL AND NEIL.B. BETWEEN US WE ARE "
	dc.b "COMPACTING EVERYTHING WE CAN AND AT THE SAME TIME "
	dc.b "WE ARE TRYING TO MAKE EVERYTHING RUN ON ALL "
	dc.b "VERSIONS OF THE OS AND ON 512K MACHINES WITHOUT "
	dc.b "REMOVING ANYTHING FROM THE ORIGINAL PROGRAM. "
	dc.b "SOME PEOPLE SEEM TO THINK SMALL IS REMOVING "
	DC.B "INTROS AND LOADING SCREENS BUT WE HAVE DECIDED "
	DC.B "TO KEEP THEM IN OUR VERSIONS. "
	DC.B "   NOW WHAT YOU PROBABLY HAVEN'T BEEN WAITING FOR! "
	DC.B "YES, YOU'VE GUESSED IT, THE GREETINGS !!! "
	DC.B "A BIG BIG BIG SUPER MEGA "
	DC.B "INTER-GALACTIC GREETING TO ................ "
	DC.B "NO! NOT YOU FOOL! ME OF COURSE... SORRY ABOUT "
	DC.B "THAT, I JUST HAD TO GET THE EGO TRIP OUT OF THE "
	DC.B "WAY. NOW WHERE WAS I? OH YES! A BIG HI TO IN NO "
	DC.B "SPECIAL ORDER - EHT WERC-24 , XET , WERC-TNT , "
	DC.B "700 , MAK , WERC ETYBAGIG , SCTS , SSOB , "
	DC.B "LANOITANRETNI XXX , EHT STNACILPER , AFOH , SSC "
	DC.B ", BCT , AMD , DOHPAZ , GRS , ENILTOH , SUIRIS , "
	DC.B "61 LEVEL , 9176 , LYRAD , MASTOLF , XAM DAM , "
	DC.B "NUGOHS , CCH , MAET-A ...... WELL, WHAT DID YOU "
	DC.B "EXPECT? I DID SAY 'IN NO SPECIAL ORDER'.        "
	dc.b $ff,$0
	even
	dc.b "font here"
fontst	ds.b font-9