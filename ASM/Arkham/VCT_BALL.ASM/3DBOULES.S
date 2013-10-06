****************
* vector balls *
****************

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 addq.l #6,sp

 bsr clr_all
 bsr precalcul

 clr.l -(sp)		Passe en superviseur
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,oldpile

 movem.l palette,d0-d7		Palette
 movem.l d0-d7,$ffff8240.w
 move.b #2,$ffff820a.w		Frequence
 move.b #0,$ffff8260.w		Resolution

 move.l #size+1,d0
 mulu.w #4,d0
 move.l d0,nbre

 move.w #$2700,sr		"Sequence interruption !"
 move.l $70.w,rvbl+2
 move.l #vbl,$70.w
 move.l #$ff01ff00,$fffa06
 move.l #$ff01ff00,$fffa12
 move.b #$08,$fffa1b
 move.b #$1,$fffa21
 move.l #timerb,$120.w
 move.w #$2300,sr

 move.b #1,calcflag		Precalcul positions
 movem.l yesp_palette,d0-d3
 movem.l d0-d3,$ffff8240.w
 move.b #$1f,$ffff8201.w
 move.b #$80,$ffff8203.w
 lea.l $90000,a6
 bsr vector_math
 clr.b calcflag
 bsr clr_all
 movem.l nop_palette,d0-d1
 movem.l d0-d1,$ffff8240.w

 lea.l $90000,a6	
prog 
 tst.b vblflag
 beq.s prog
 clr.b vblflag

 cmpi.b #$b9,$fffffc02.w
 beq end

 cmpa.l #$90000,a6
 bne nobleme
 move.l finrotate,a6
nobleme
 suba.l nbre,a6

* efface anciens bobs

 moveq.l #0,d1
 move.w #size,d0
clrbob
 movea.l ecr1,a1
 adda.w (a6)+,a1
 addq.l #2,a6
n set 0
 rept 13
 move.l d1,n(a1)
 move.l d1,n+8(a1)
n set n+$a0
 endr
 dbf d0,clrbob

 adda.l nbre,a6

 movea.l finrotate,a0
 cmpa.l a0,a6
 blo noprob
 suba.l #$90000,a0
 suba.l a0,a6
noprob

* affiche objet

 move.w #size,d2
 move.l a6,a2
affbobs
 movea.l ecr1,a1
 adda.w (a2)+,a1
 lea.l $80000,a0
 adda.w (a2)+,a0

n set 0
 rept 13
 move.l (a0)+,d0
 and.l d0,n(a1)
 move.l (a0)+,d0
 and.l d0,8+n(a1)
 move.l (a0)+,d0
 or.l d0,n(a1)
 move.l (a0)+,d0
 or.l d0,8+n(a1)
n set n+$a0
 endr
 dbf d2,affbobs

 move.l ecr1,a0
 move.l ecr2,ecr1
 move.l a0,ecr2

* move.w #$002,$ffff8240.w
 bra prog

	;;;;;;;;;;;;;;;;;;;;
	; fin du programme ;
	;;;;;;;;;;;;;;;;;;;;
end
 move.w #$2700,sr
rvbl move.l #0,$70.w
 move.l #$ff1eff64,$fffa06
 move.l #$ff1eff64,$fffa12
 move.w #$2300,sr
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 clr.l $4d2
 move.l oldpile,-(sp) 
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1		Retour au Gem  

*****************
* SOUS ROUTINES *
*****************

	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; efface 2 ecrans entier ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;

clr_all
 lea.l $1e0000,a0
 bsr clrscr		Serais-ce du recursif ??
 lea.l $1f8000,a0
clrscr		
 move.w #7999,d0
clrscr2 clr.l (a0)+
 dbf d0,clrscr2
 rts
 
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; precalcul des rotations;
	;;;;;;;;;;;;;;;;;;;;;;;;;; 

vector_math
 cmpi.b #$b9,$fffffc02.w
 beq end
 lea.l object,a0
 lea.l newecr,a1
 lea.l cosinus,a2
 move.w #size,d0
trans
 move.w (a0)+,d1	X
 move.w (a0)+,d2	Y
 move.w (a0)+,d3	Z

 move.w alpha,d7	Rotation X
 move.w d2,d4
 move.w d3,d5
 muls.w (a2,d7.w),d2
 muls.w 2(a2,d7.w),d3
 sub.w d3,d2
 asr.w #7,d2
 muls.w 2(a2,d7.w),d4
 muls.w (a2,d7.w),d5
 add.w d4,d5
 asr.w #7,d5
 move.w d5,d3

 move.w beta,d7		Rotation Y
 move.w d1,d4
 move.w d3,d5
 muls.w (a2,d7.w),d1
 muls.w 2(a2,d7.w),d3
 add.w d3,d1
 asr.w #7,d1
 muls.w (a2,d7.w),d5
 muls.w 2(a2,d7.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3 

 move.w gamma,d7	Rotation Z
 move.w d1,d4
 move.w d2,d5
 muls.w (a2,d7.w),d1
 muls.w 2(a2,d7.w),d2
 sub.w d2,d1
 asr.w #7,d1
 muls.w 2(a2,d7.w),d4
 muls.w (a2,d7.w),d5
 add.w d4,d5
 asr.w #7,d5
 move.w d5,d2 

 addi.w #160,d1		Calcul pts ecrans
 addi.w #100,d2
 move.w d1,(a1)+
 move.w d2,(a1)+
 move.w d3,(a1)+
* eor.w #$111,$ffff8240.w
 dbf d0,trans

 lea.l newecr,a0	Trie tableau Newecr
 move.w #size,d0
trie
 lea.l newecr,a1 
 move.w #size-1,d1
trie2
 move.w 4(a0),d2
 cmp.w 4(a1),d2
 ble trie3
 move.l (a0),d2
 move.l (a1),(a0)
 move.l d2,(a1)
 move.w 4(a0),d2
 move.w 4(a1),4(a0)
 move.w d2,4(a1)
trie3
 addq.l #6,a1
 dbf d1,trie2
 addq.l #6,a0
* eor.w #$111,$ffff8240.w
 dbf d0,trie

 move.w #size,d2	Convertit en Fast Fichier
 lea.l newecr,a2
calbobs
 move.w (a2)+,d0
 move.w (a2)+,d1
 addq.w #2,a2
 lea.l 0,a1
 mulu.w #160,d1
 adda.w d1,a1
 move.w d0,d1
 lsr.w d1
 andi.w #$ffff-7,d1
 adda.w d1,a1
 move.w a1,(a6)+
 adda.l ecr1,a1
 lsr.w #3,d1
 lsl.w #4,d1
 sub.w d1,d0
 mulu.w #13*16,d0
 move.w d0,(a6)+ 
* eor.w #$111,$ffff8240.w
 dbf d2,calbobs

 add.w #16,alpha		Augmente angles		
 cmp.w #1440,alpha
 blo nofinalpha
 clr.w alpha
nofinalpha
 add.w #4,beta
 cmp.w #1440,beta
 blo nofinbeta
 clr.w beta
 move.l a6,finrotate
 rts
nofinbeta
 add.w #16,gamma
 cmp.w #1440,gamma
 blo nofingamma
 clr.w gamma
nofingamma
* move.w #$002,$ffff8240.w	Flash !
 bra vector_math

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; precalcul des pos. des boules ;	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

precalcul
 lea.l $80000,a0
 moveq.w #15,d0
prebob
 lea.l bobs,a1
 moveq.w #12,d1
prebob2
 move.w (a1),d2
 or.w 2(a1),d2
 not.w d2
 move.w d2,(a0)+
 move.w d2,(a0)+
 move.w 4(a1),d2
 or.w 6(a1),d2
 not.w d2
 move.w d2,(a0)+
 move.w d2,(a0)+
 move.l (a1),(a0)+
 move.l 4(a1),(a0)+
 roxr.w (a1)
 roxr.w 4(a1) 
 roxr.w 2(a1)
 roxr.w 6(a1)
 addq.l #8,a1
 dbf d1,prebob2
 dbf d0,prebob
 rts

	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; routine d'interruptions ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;

timerb
 eor.w #$003,$ffff8240.w
 move.b #1,$fffa21
 bclr.b #0,$fffa0f
 rte

vbl
 clr.w $ffff8240.w
 movem.l d0-a6,-(sp)
 move.b #1,vblflag
 move.b #199,$fffa21
 tst.b calcflag
 bne.s vblcalc
 move.b ecr1+1,$ffff8201.w
 move.b ecr1+2,$ffff8203.w
 movem.l (sp)+,d0-a6
 rte

vblcalc		* Affichage du texte

postext
 lea.l text,a1

 subq.b #1,cmptxt
 bne no_fin_cmp
 move.b #7,cmptxt

new_alpha
 move.b (a1)+,d0
 andi.l #$ff,d0
 bne.s no_fin_txt
 lea.l text,a1
no_fin_txt 
 cmpi.b #1,d0
 bne.s nofinline
 add.l #$a0*18,posecr+2
 bra.s new_alpha
nofinline
 move.l a1,postext+2
 lea.l space,a0
 cmpi.b #32,d0
 beq posecr
 
 subi.b #65,d0
 mulu.w #84,d0
 lea.l font,a0
 adda.w d0,a0

posecr
 lea.l $1f8000+6*$a0,a1

 addq.l #8,a1
 subq.b #1,linecmp
 bne noline
 adda.l #18*$a0,a1
 move.b #20,linecmp
noline
 move.l a1,a2
 move.l posecr+2,a1
 move.l a2,posecr+2

 move.w #13,d0
affletter
 move.l (a0)+,(a1)
 move.w (a0)+,4(a1)
 lea.l $a0(a1),a1
 dbf d0,affletter

no_fin_cmp 
 movem.l (sp)+,d0-a6
 rte


****************
* section data *
****************

cmptxt even
 dc.b 1

linecmp even
 dc.b 20

text even
 DC.B 1,1
 dc.b "  HELLO EVERYBODY]  "
 dc.b " AND WELCOME TO THE "
 DC.B " VECTOR BALL DENTRO "
 DC.B "BY TCHOOM OF ANONYM["
 DC.B "    BUT NOW]IT^S    "
 DC.B " A LITTLE[[[[[[[[[[ "
 DC.B 0


oldpile even			Pile utilisateur
 dc.l 0

calcflag even			Flag de precalcul
 dc.b 0

vblflag even			Flag Vbl
 dc.b 0

nbre even			Taille de l'objet*4
 dc.l 0

finrotate even			Adresse de fin de rotation
 dc.l 0

ecr1 even
 dc.l $001f8000			Adresse des 2 
ecr2 even			differents ecrans
 dc.l $001e0000

palette even			No comment !
 dc.w $000,$033,$055,$077
 dc.w $222,$222,$222,$222
 dc.w $222,$222,$222,$222
 dc.w $222,$222,$222,$222

nop_palette even
 dc.w $000,$033,$055,$077
yesp_palette even
 dc.w $000,$606,$707,$717
 dc.w $727,$736,$745,$754

alpha even			Angles de rotations
 dc.w 0
beta even
 dc.w 0
gamma even
 dc.w 0

size equ 59		Taille de l'objet-1

object even			Datas de l'objet	

 dc.w -140,-20,0
 dc.w -130,-20,0
 dc.w -100,-20,0
 dc.w -90,-20,0
 dc.w -60,-20,0
 dc.w -50,-20,0
 dc.w -30,-20,0
 dc.w -10,-20,0
 dc.w 10,-20,0
 dc.w 30,-20,0
 dc.w 40,-20,0
 dc.w 60,-20,0
 dc.w 100,-20,0

 dc.w -140,-10,0
 dc.w -120,-10,0
 dc.w -100,-10,0
 dc.w -80,-10,0
 dc.w -60,-10,0
 dc.w -30,-10,0
 dc.w -10,-10,0
 dc.w 30,-10,0
 dc.w 60,-10,0
 dc.w 100,-10,0

 dc.w -140,0,0
 dc.w -130,0,0
 dc.w -100,0,0
 dc.w -90,0,0
 dc.w -60,0,0
 dc.w -50,0,0
 dc.w -30,0,0
 dc.w -10,0,0
 dc.w 10,0,0
 dc.w 30,0,0
 dc.w 40,0,0
 dc.w 60,0,0
 dc.w 80,0,0
 dc.w 100,0,0

 dc.w -140,10,0
 dc.w -100,10,0
 dc.w -80,10,0 
 dc.w -60,10,0
 dc.w -30,10,0
 dc.w -10,10,0
 dc.w 10,10,0
 dc.w 30,10,0
 dc.w 60,10,0
 dc.w 70,10,0
 dc.w 90,10,0
 dc.w 100,10,0

 dc.w -140,20,0
 dc.w -100,20,0
 dc.w -80,20,0
 dc.w -60,20,0
 dc.w -50,20,0
 dc.w -20,20,0
 dc.w 10,20,0
 dc.w 30,20,0
 dc.w 40,20,0
 dc.w 60,20,0
 dc.w 100,20,0

newobject even	
 ds.w (size+1)*3		Coordoonees apres rotation
newecr
 ds.w (size+1)*3 		Correspondance adresse ecran
space even
 ds.w 3*15


font even
 incbin font.dat
bobs even
 incbin bobs.dat		Boules
cosinus even
 incbin cosinus.dat		Table cosinus
