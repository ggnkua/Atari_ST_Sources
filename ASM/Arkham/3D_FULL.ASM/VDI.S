;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;
; essai de 3d surface pleine precalculee ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialise les donnees vdi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

contrl macro \1,\2
 move.w #\2,contrl+\1*2
 endm
intin macro \1,\2
 move.w #\2,intin+\1*2
 endm
ptsin macro \1,\2
 move.w #\2,ptsin+\1*2
 endm
vdisys macro
 jsr vdi
 endm

* fixe le clipping de l'ecran 1

 contrl 0,129
 contrl 1,2
 contrl 3,1
 contrl 6,1
 intin 0,1
 ptsin 0,0
 ptsin 1,0
 ptsin 2,319
 ptsin 3,199
 vdisys

* motifs de remplissage

 contrl 0,23
 contrl 1,0
 contrl 3,1
 contrl 6,1
 intin 0,1
 vdisys

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp) 
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$333,$ffff8242.w
 move.w #$444,$ffff8244.w
 move.w #$555,$ffff8246.w

 lea.l $90000,a6
 jsr precalcul

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; et on commence l'animation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l $90000,a6

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 lea.l $1f8000+32+20*$a0,a0
 move.w #140,d0
aff_sprite
n set 0
 rept 11
 move.l (a6)+,n(a0)
n set n+8
 endr
 lea.l $a0(a0),a0
 dbf d0,aff_sprite

 cmpa.l #$90000+11*4*141*90,a6
 blo nofin_a6
 lea.l $90000,a6
nofin_a6

 cmpi.b #$62,$fffffc02.w
 bne no_help
 move.w #$145,$ffff8240.w
no_help
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts
 
precalcul

 cmpi.b #$b9,$fffffc02.w
 beq end
 clr.w $ffff8240.w

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; traitement des faces en 3d ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l face,a0
 lea.l new_face,a1
 lea.l ordre_face,a5
 move.w #nbre_face,d0
traite_face
 move.l a1,(a5)+
 clr.w (a5)			; on reset la moy. des z
 move.l (a0)+,(a1)+		; couleurs
 move.l (a0)+,(a1)+
 move.w (a0)+,d7
 move.w d7,(a1)+
 
traite_face2
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

; rotation X

 move.w alpha,d4
 lea.l cosinus,a2
 move.w d2,d5
 move.w d3,d6
 muls.w (a2,d4.w),d2
 muls.w 2(a2,d4.w),d3
 add.w d3,d2
 asr.w #7,d2
 muls.w (a2,d4.w),d6
 muls.w 2(a2,d4.w),d5
 sub.w d5,d6
 asr.w #7,d6
 move.w d6,d3

; rotation Y

 move.w beta,d4
 move.w d1,d5
 move.w d3,d6
 muls.w (a2,d4.w),d1
 muls.w 2(a2,d4.w),d3
 add.w d3,d1
 asr.w #7,d1
 muls.w (a2,d4.w),d6
 muls.w 2(a2,d4.w),d5
 sub.w d5,d6
 asr.w #7,d6
 move.w d6,d3

 addi.w #92,d1
 addi.w #72,d2

 move.w d1,(a1)+
 move.w d2,(a1)+
 add.w d3,(a5)

 dbf d7,traite_face2 
 sub.w d3,(a5)+

 dbf d0,traite_face

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; on trie les faces avant de les afficher ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l ordre_face,a0	Trie tableau ordre_face
 move.w #nbre_face,d0
trie
 lea.l ordre_face,a1 
 move.w #nbre_face-1,d1
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
 dbf d0,trie

;;;;;;;;;;;;;;;;;;;;;;;;
; affiche les faces 3d ;
;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l ordre_face,a5
 move.w #nbre_face,d0
aff_face
 move.l (a5)+,a0
 addq.l #2,a5
 addq.l #8,a0

 movem.l d0-a6,-(sp)
 contrl 0,25
 contrl 1,0
 contrl 3,1
 contrl 6,1
 intin 0,1
 vdisys
 movem.l (sp)+,d0-a6

 lea.l contrl,a1
 move.w #9,(a1)
 move.w (a0),2(a1)
 move.w #0,6(a1)
 move.w #1,12(a1)

 lea.l ptsin,a1
 move.w (a0)+,d1
aff_face2
 move.l (a0)+,(a1)+
 dbf d1,aff_face2
 movem.l d0-a6,-(sp)
 jsr vdi
 movem.l (sp)+,d0-a6
 dbf d0,aff_face

stop_tout
 cmpi.b #$36,$fffffc02.w
 beq stop_tout

 lea.l $1f8000,a0
 move.w #140,d0
 moveq.l #0,d1
clr_ecr
n set 0
 rept 11
 move.l n(a0),(a6)+
 move.l d1,n(a0)
n set n+8
 endr
 lea.l $a0(a0),a0
 dbf d0,clr_ecr

 addi.w #4*4,alpha
 cmpi.w #1440,alpha
 blo.w nofin_alpha
 clr.w alpha
nofin_alpha

 addi.w #4*4,beta
 cmpi.w #1440,beta
 blo.w nofin_beta
 clr.w beta
 rts
nofin_beta
 
 bra precalcul

vdi move.l #vdipb,d1
 moveq.w #115,d0
 trap #2
 rts

alpha even
 dc.w 0
beta even
 dc.w 0

motif even
 dc.w $ffff,$ffff,$ffff,$ffff

nbre_face equ 6-1

face even
 dc.w 1,0,0,0	
 dc.w 4		
 dc.w -50,-50,-50
 dc.w 50,-50,-50
 dc.w 50,50,-50
 dc.w -50,50,-50
 dc.w -50,-50,-50
 dc.w 1,0,0,0	
 dc.w 4		
 dc.w -50,-50,50
 dc.w 50,-50,50
 dc.w 50,50,50
 dc.w -50,50,50
 dc.w -50,-50,50
 dc.w 1,1,0,0,4
 dc.w -50,-50,-50
 dc.w -50,-50,50
 dc.w -50,50,50
 dc.w -50,50,-50
 dc.w -50,-50,-50
 dc.w 1,1,0,0,4
 dc.w 50,-50,-50
 dc.w 50,-50,50
 dc.w 50,50,50
 dc.w 50,50,-50
 dc.w 50,-50,-50
 dc.w 0,1,0,0,4
 dc.w 50,50,50
 dc.w 50,50,-50
 dc.w -50,50,-50
 dc.w -50,50,50
 dc.w 50,50,50
 dc.w 0,1,0,0,4
 dc.w 50,-50,50
 dc.w 50,-50,-50
 dc.w -50,-50,-50
 dc.w -50,-50,50
 dc.w 50,-50,50

vdipb dc.l contrl,intin,ptsin,intout,ptsout
contrl ds.w 12
intin ds.w 128
intout ds.w 128
ptsin ds.w 128
ptsout ds.w 128

new_face even
 ds.w 500

ordre_face even
 ds.w 3*(nbre_face+2)

cosinus even
 incbin cosinus.dat
