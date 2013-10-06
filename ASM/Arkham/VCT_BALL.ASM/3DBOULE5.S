****************
* vector balls *
****************

size equ 24		Taille de l'objet-1

setscreen macro \1
 clr -(sp)
 pea \1
 pea \1
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp
 endm

 dc.w $a00a
 setscreen $1e0000
 setscreen $1f8000
 bsr precalcul

 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 movem.l palette,d0-d5
 movem.l d0-d5,$ffff8240.w
 movem.l palette+24,d0-d1
 movem.l d0-d1,$ffff8240+24.w

 move.l #size+1,d0
 mulu.w #4,d0
 move.l d0,nbre

 lea.l $90000,a6
 bsr vector_math
 clr.w $ffff8240.w

 lea.l $90000,a6
prog 
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp

 move.b ecr1+1,$ffff8201.w
 move.b ecr1+2,$ffff8203.w

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
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 setscreen $1f8000
 rts

*****************
* SOUS ROUTINES *
*****************
 
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

 move.l d0,-(sp)

 move.w alpha,d0	Rotation X
 move.w d2,d4
 move.w d3,d5
 muls.w (a2,d0.w),d2
 muls.w 2(a2,d0.w),d3
 sub.w d3,d2
 asr.w #7,d2
 muls.w 2(a2,d0.w),d4
 muls.w (a2,d0.w),d5
 add.w d4,d5
 asr.w #7,d5
 move.w d5,d3

 move.w beta,d0		Rotation Y
 move.w d1,d4
 move.w d3,d5
 muls.w (a2,d0.w),d1
 muls.w 2(a2,d0.w),d3
 add.w d3,d1
 asr.w #7,d1
 muls.w (a2,d0.w),d5
 muls.w 2(a2,d0.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3 

 move.w gamma,d0	Rotation Z
 move.w d1,d4
 move.w d2,d5
 muls.w (a2,d0.w),d1
 muls.w 2(a2,d0.w),d2
 sub.w d2,d1
 asr.w #7,d1
 muls.w 2(a2,d0.w),d4
 muls.w (a2,d0.w),d5
 add.w d4,d5
 asr.w #7,d5
 move.w d5,d2 

 move.l (sp)+,d0

 addi.w #160,d1		Calcul pts ecrans
 addi.w #100,d2
 move.w d1,(a1)+
 move.w d2,(a1)+
 move.w d3,(a1)+
 eor.w #$111,$ffff8240.w
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
 eor.w #$111,$ffff8240.w
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
 eor.w #$111,$ffff8240.w
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
 move.w #$220,$ffff8240.w	Flash !
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




****************
* section data *
****************

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
 dc.w $000,$022,$044,$077
 dc.w $222,$222,$222,$222
 dc.w $222,$222,$222,$222
 dc.w $222,$222,$222,$222

alpha even			Angles de rotations
 dc.w 0
beta even
 dc.w 0
gamma even
 dc.w 0

object even			Datas de l'objet	

 dc.w -40,-40,0+15
 dc.w -20,-40,0+15
 dc.w 0,-40,0+15
 dc.w 20,-40,0+15
 dc.w 40,-40,0+15

 dc.w -40,-20,0+15
 dc.w -20,-20,0+15
 dc.w 0,-20,0+15
 dc.w 20,-20,0+15
 dc.w 40,-20,0+15

 dc.w -40,0,0+15
 dc.w -20,0,0+15
 dc.w 0,0,0+15
 dc.w 20,0,0+15
 dc.w 40,0,0+15

 dc.w -40,20,0+15
 dc.w -20,20,0+15
 dc.w 0,20,0+15
 dc.w 20,20,0+15
 dc.w 40,20,0+15

 dc.w -40,40,0+15
 dc.w -20,40,0+15
 dc.w 0,40,0+15
 dc.w 20,40,0+15
 dc.w 40,40,0+15

newobject even	
 ds.w (size+1)*3		Coordoonees apres rotation
newecr
 ds.w (size+1)*3 		Correspondance adresse ecran

bobs even
 incbin bobs.dat		Boules
cosinus even
 incbin cosinus.dat		Table cosinus
