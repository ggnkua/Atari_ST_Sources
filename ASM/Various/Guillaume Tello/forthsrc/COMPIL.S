;*************************************
;*                                   *
;* Data pour compilateur FORTH 92    *
;*                                   *
;*************************************
STE equ 0
LIB equ 1

	if STE=0
	   opt w+,P=68030,P=68882
   	OUTPUT "F:\FORTH\FORTH.LIB"
   else
   	opt w+,P=68000
   	OUTPUT "F:\FORTH\FORTHSTE.LIB"
   endif

NON MACRO
   dc.w 0
   ENDM

COPIE MACRO         ; debut, fin [ , flag-FORTH.LIB ]
   ifd   LIB
      if \#=3
         dc.w 3   ; si LIB et 3 arguments, pas de copie mais SAUT
      else
         dc.w ((\2-\1)/2-1)
         dc.w 2
      endif
   else
      dc.w ((\2-\1)/2-1)   ; nombre de mots moins 1 ( dbra )
      dc.w 2
   endif
   ENDM

SAUT MACRO
   dc.w 3
   ENDM
   
ASS MACRO
   dc.w \1
   ENDM
   
UP MACRO
   addq.l #4,a6
   ENDM

DW MACRO
   subq.l #4,a6
   ENDM

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

VCONTROL MACRO      ; fn,pts,int,subfn
   lea control(pc),a0
   move #\1,(a0)+
   move #\2,(a0)
   addq.l #4,a0
   move #\3,(a0)
   addq.l #4,a0
   move #\4,(a0)+
   move handle,(a0)
   ENDM

VDI MACRO
   move.l #vdipb,d1
   moveq #$73,d0
   trap #2
   ENDM

AES MACRO
   move.l #aespb,d1
   move.l #$c8,d0
   trap #2
   ENDM

ACONTROL MACRO         ;   fn,int,into,add
   lea control(pc),a0
   move #\1,(a0)+
   move #\2,(a0)+
   move #\3,(a0)+
   move #\4,(a0)+
   clr (a0)
   ENDM

GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM

   data
   even

aespb: dc.l control,global,intin,intout,addrin,addrout
vdipb: dc.l control,intin,ptsin,intout,ptsout
vdiedit: dc.l contedit,intedit,dum,dum,dum
chemin: dc.b "\\*.FOR",0,"                                        "
fichier: dcb.b 100,0

   even
avert: dc.b "[2][ Inserer la diquette     | … formater | dans le lecteur "
avertd: dc.b "A ][Ca y est|Annuler]",0
avert1: dc.b "[1][ L'imprimante n'est pas | | prete … recevoir. ]"
        dc.b "[Annuler|Imprimer]",0

   even

pilptr: dc.l pile+4096
retptr: dc.l retour+4096
base: dc.l 10
indptr: dc.l indice
ecran: dc.w 0
formptr: dc.l form+80
global: dc.l 0,0,0,0,0,0,0,0
sizeptr: dc.w 1
lstptr: dc.l arrptr+4
arrptr: dc.l lstdata
        dcb.l 10,0
lst: dc.l 0
remb: dc.l remdata
stt: dc.w 0
accuptr: dc.l accudat
isfast: dc.w 1
dpth: dc.w 53
dpthln: dc.w 52
dpthex: dc.w 50
pilbase: dc.l pile+4096
isret: dc.w 0

   bss
   even

topsav2:   ds.l 1
topsave:   ds.l 1
form:      ds.b 80
savpil:    ds.l 1
handle:    ds.w 1
i_handle:  ds.w 1
intin:     ds.w 128
intout:    ds.w 128
i_intout:  ds.w 128
addrin:    ds.l 64
addrout:   ds.l 64
ptsin:     ds.w 128
ptsout:    ds.w 128
contedit:  ds.w 13
vt_int:
intedit:   ds.w 514
dum:       ds.w 2
retour:    ds.l 1024
pile:      ds.l 1025
program:   ds.l 1
topprg:    ds.l 1
edbuf:     ds.b 1724
maxcol:    ds.w 1
mot:       ds.b 42
erreur:    ds.w 1
doesreg:   ds.l 2
regist:    ds.l 16
tamp:      ds.b 40
indice:    ds.l 128
pad:       ds.b 1028
dtabuf:    ds.b 44
linea:     ds.l 1
gdb:       ds.w 2
formbuf:   ds.l 1
uspile:    ds.l 1
lstdata:   ds.l 256
remdata:   ds.l 50
basesav:   ds.l 1
sttdata:   ds.b 1024
sttptr:    ds.l 1
accudat:   ds.b 1024
setdat:    ds.b 8198
setdeb:    ds.w 1
setnbr:    ds.w 1
muldat0:   ds.l 4
muldat1:   ds.w 5
muldat2:   ds.l 2
expy:      ds.w 1
exp:       ds.w 1
signe:     ds.w 1
affbuf:    ds.b 30
parbuf:    ds.b 20
save:      ds.l 3
chiffre:   ds.w 1
courant:   ds.w 1
cordx:     ds.w 5
cordy:     ds.w 5
cordz:     ds.w 5
cordt:     ds.w 5
cordn:     ds.w 1
cordd:     ds.w 1
cords:     ds.w 1
modulo:    ds.l 1
sgny:      ds.w 1
resol:     ds.w 2
szone:     ds.l 1
topmem:    ds.l 1
botmem:    ds.l 1
bitdat:    ds.b 76
bitdat2:   ds.b 76
ass:       ds.w 1
but:       ds.l 2
indexadr:  ds.l 1
indextab:  ds.b 128
fixn:      ds.w 1
mfdb_s:    ds.w 10
mfdb_d:    ds.w 10
copy_pts:  ds.w 8
mf1:       ds.w 18
mf2:       ds.w 18
end_keys:  ds.l 1
work_out:  ds.w 57
redrawdat: ds.w 6  ;  flag, handle, x,y,x',y'
aes_flag:  ds.w 1
_app_flag: ds.l 1
bspage:    ds.l 1
wd_table:  ds.l 20		; 20 dialogues en fenˆtres simultan‚s
			  ds.b $1000
_pile:     ds.w 1		

   text

   jmp initial

   dc.l adresse,ordres,dlcomp,indptr,lstptr
	dc.l 400		; nombre de Ko … laisser au systŠme!

debut: tst (a5)+
   bpl.s execution
   move -2(a5),d2
   cmp #-1,d2
   bne.s .ass_def
   move (a5)+,d0			; d‚finitions FORTH
   move.l #adresse,a0
   move.l (a5)+,d1
   lsl #2,d0
   move.l a5,0(a0,d0.w)
   add.l d1,a5
   bra.s debut
.ass_def:					; d‚finitions assembleur (avec >include)
	neg d2					; -2=1mot, -3=2mots...
	subq #1,d2
	move (a5)+,d0			; mot de d‚part
	move.l #adresse,a0
	lsl #2,d0
	add d0,a0				; dans le tableau
	move.l (a5)+,d1
	move.l a5,d3			; d‚but zone text
	add.l d1,a5				; pointe sur la s‚rie d'adresses
	bra.s .lb1
.lb0:
	move.l (a5)+,d0
	add.l d3,d0				; plus offset
	move.l d0,(a0)+		; dans le tableau
.lb1: dbf d2,.lb0
	bra.s debut	
execution: bsr execut
   bra.s debut

   dcb.b 554,0

   SAUT
fin: tst w_hand
   bmi.s .lb0          ; pas de fenetre ouverte
   bsr fastclose
.lb0:
	bsr ferme_vdi
   tst.b aes_flag
   beq.s .auto
   GEM_AES appl_exit
.auto:
   move #2,-(sp)
   move #15,-(sp)
   XBIOS 35,6
   move.l uspile,a7
   GEMDOS 0,2

ferme_vdi:
   move i_handle,d7
   bmi.s .pas_vdi			  ; i_handle<0 si VDI non ouvert
   GEM_VDI show_mouse
   move handle,i_handle
   GEM_VDI close_work     ; ferme la station vituelle
   move d7,i_handle
   tst.b aes_flag
   bne.s .aes
   move #2,cw_cont        ; station physique dans le dossier AUTO
.aes:
   GEM_VDI close_work     ; puis ferme l'externe
.pas_vdi:
	rts
	
	
execut:  move.l pilbase,slowexe+26
         tst isfast
         beq slowexe
fastexe: move (a5)+,d1
         lea adresse(pc),a1
         cmp #diko,d1
         bpl.s .lab1
         if STE=0
	         jsr ([adresse,pc,d1.w*4])
	      else
	      	move d1,d0
	      	asl #2,d0
	      	lea adresse,a0
	      	move.l 0(a0,d0.w),a0
	      	jsr (a0)
	      endif
         bra.s fastexe
.lab1:   move.l a5,-(a4)
			if STE=0
	         move.l (adresse,pc,d1.w*4),a5
	      else
	      	asl #2,d1
	      	lea adresse,a0
	      	move.l 0(a0,d1.w),a5
	      endif
         bra.s fastexe


slowexe: move (a5)+,d1
         lea adresse(pc),a1
         moveq #15,d0
         move.l joystick.l,a0
         and.b 19(a0),d0
         cmp.b #15,d0
         beq.s .break
         cmp.l #125125,a6
         bmi.s .bug
         cmp #diko,d1
         bpl.s .lab1
         if STE=0
	         jsr ([adresse,pc,d1.w*4])
	      else
	      	move d1,d0
	      	asl #2,d0
	      	lea adresse,a0
	      	move.l 0(a0,d0.w),a0
	      	jsr (a0)
	      endif
         bra.s slowexe
.lab1:   move.l a5,-(a4)
			if STE=0
	         move.l (adresse,pc,d1.w*4),a5
	      else
	      	asl #2,d1
	      	lea adresse,a0
	      	move.l 0(a0,d1.w),a5
	      endif 
         bra.s slowexe
.break:  pea .brktext(pc)
         bra.s .lab2
.bug:    pea .bug0(pc)
         move.l pilbase,a6
.lab2:   GEMDOS 9,6
         move.l a5,-(a6)
         rts
.brktext: dc.b 13,10,7,"  BREAK",13,10,0
.bug0:   dc.b 13,10,7," Erreur, pile vide",13,10,0
   even

GEM equ 1
   include "F:\forth\commun.s"

   NON
quit: addq.l #4,sp
   rts

   SAUT
format: move.l (a6)+,d7
   move.l (a6)+,d6
   move.l (a6)+,d5
   move.l (a6),d4
   move.b d4,d0
   add.b #'A',d0
   move.b d0,avertd
   ACONTROL 52,1,1,1
   move #2,intin
   move.l #avert,addrin
   AES
   move intout,d0
   cmp #2,d0
   bne.s .lb0
   rts
.lb0: move.l #11576,-(sp)
   GEMDOS 72,6
   move.l d0,formbuf
   bpl.s .lb1
   bra.s .fin
.bug: move.l formbuf,-(sp)
   GEMDOS 73,6
.fin: move.l d0,(a6)
   rts
.lb1: clr -(sp)
   move.w #3,-(sp)
   move.l #$0503,-(sp)
   add.l #11064,d0
   move.l d0,-(sp)
   XBIOS 18,14
   tst.l d0
   bmi.s .bug
   move.l formbuf,a3
   move.b d5,26+11064(a3)
   move.b d7,24+11064(a3)
   move.l d7,d0
   muls d6,d0
   muls d5,d0
   move.b d0,19+11064(a3)
   lsr.w #8,d0
   move.b d0,20+11064(a3)
   bra .lb3
.lb2: move.w #$e5e5,-(sp)
   move.l #$87654321,-(sp)
   move #1,-(sp)
   clr -(sp)
   move.w d6,-(sp)
   move.w d7,-(sp)
   move.w d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 10,26
   tst.l d0
   bmi.s .bug
   cmp #2,d5
   bne.s .lb3
   move.w #$e5e5,-(sp)
   move.l #$87654321,-(sp)
   move #1,-(sp)
   move #1,-(sp)
   move.w d6,-(sp)
   move.w d7,-(sp)
   move.w d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 10,26
   tst.l d0
   bmi .bug
.lb3: dbf d6,.lb2
   move.l a3,a0
   moveq #0,d0
   move #460,d1
.lb4: move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   dbf d1,.lb4
   move d7,-(sp)
   clr.l -(sp)
   move #1,-(sp)
   move d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 9,20
   tst.l d0
   bmi .bug
   cmp #2,d5
   bne.s .lb5
   move d7,-(sp)
   move #1,-(sp)
   clr -(sp)
   move #1,-(sp)
   move d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 9,20
   tst.l d0
   bmi .bug
.lb5: add.w #11064,a3
   move #1,-(sp)
   clr.l -(sp)
   move #1,-(sp)
   move d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 9,20
   bra .bug

   SAUT
word: lea ordres(pc),a0
   move.l #pad+2,a1
   move.l (a6),d0
   move.l a1,(a6)
   tst d0
   bmi.s .lb4
.lb1: subq #1,d0
   bmi.s .lb2
   move.b (a0)+,d1
   ext.w d1
   add.w d1,a0
   bra.s .lb1
.lb2: move.b (a0)+,d1
   ext.w d1
   subq #1,d1
.lb3: move.b (a0)+,(a1)+
   dbf d1,.lb3
.lb4: clr.b (a1)
   rts

assemblons:
	if STE=0
	   move.l (adresse,pc,d4.w*4),a4     ;  adresse du mot
	else
		lea adresse,a4
		add d4,a4
		add d4,a4
		add d4,a4
		move.l 0(a4,d4.w),a4
	endif
   tst d4
   bne.s .lb0
   move .emp(pc),(a2)+
   move.l d5,(a2)+
.sortie: rts
.lb0: cmp #diko,d4
   bpl .us
   move -2(a4),d2      ; code d'assemblage
   beq .bug1
   bmi .fin
   cmp.b #2,d2
   bne.s .lb2
   move -4(a4),d2      ; taille … copier en mots -1
.lb1: move (a4)+,(a2)+
   dbf d2,.lb1
   bra.s .sortie
.lb2: cmp.b #3,d2
   bne.s .lb3
.saut: move .type3(pc),(a2)+
   move.l a4,(a2)+
   rts
.lb3: cmp.b #12,d2
   bne.s .lb4
   move #$4e75,(a2)+
   rts
.lb4: cmp.b #17,d2       ; vdi ou aes
   bne.s .lb5
   addq.l #2,a4          ; passe l'opcode de sub
   sub (a4)+,d4          ; soustrait le d‚calage
   move .type17(pc),(a2)+
   move d4,(a2)+
   bra.s .saut
.lb5: cmp.b #6,d2
   bne.s .lb7
   lea .type6(pc),a4
.lb6: move (a4)+,(a2)+
   bne.s .lb6
   subq.l #2,a2
   move.l a2,-(a6)
   rts
.lb7: cmp.b #4,d2
   bne.s .lb9
   lea .type4(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4),(a2)+
   rts
.lb9: cmp.b #13,d2
   beq.s .lb9b
   cmp.b #10,d2
   bne.s .lb10
.lb9b: lea.l .type13(pc),a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l a2,-(a6)
   addq.l #4,a2
   rts
.lb10: cmp.b #14,d2
   bne.s .lb11
   move .type14(pc),(a2)+
   move.l (a6),a4
   move.l a2,(a6)
   addq.l #4,a2
   move.l a2,(a4)
   rts
.lb11: cmp.b #15,d2
   bne.s .lb12
   move.l (a6)+,a4
   move.l a2,(a4)
   rts
.lb12: cmp.b #5,d2
   bne.s .lb14
   lea .type5(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l (a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   move 2(a4),(a2)+
   rts
.lb14: cmp.b #16,d2
   bne.s .lb16
   lea .type16(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   rts
.lb16: cmp.b #7,d2
   bne.s .lb17
   move.l a2,-(a6)
   rts
.lb17: cmp.b #8,d2
   bne.s .lb18
   move .type14(pc),(a2)+
   move.l (a6)+,(a2)+
   rts
.lb18: cmp.b #9,d2
   bne.s .lb19
   lea .type13(pc),a4
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l (a6)+,(a2)+
   rts
.lb19: cmp.b #11,d2
   bne.s .lb20
   move .type14(pc),(a2)+
   move.l (a6)+,a4
   move.l (a6)+,(a2)+
   move.l a2,(a4)
   rts
.lb20: cmp.b #18,d2
   bne.s .lb21
   lea .type18(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   rts
.lb21: cmp.b #1,d2
   bne.s .lb23
   lea gblk-1476(pc),a4
   move #$4e41,d2
.lb22: 
	if STE=0
		lea 0(a4,d4.w*4),a4
	else
		add d4,a4
		add d4,a4
		add d4,a4
		add d4,a4
	endif
   lea .tos(pc),a5
   move.l (a5)+,(a2)+
   move (a5)+,(a2)+
   move.b (a4)+,d0
   move.b (a4)+,d1
   bmi.s .tos1
   ext.w d1
.tos0: btst d1,d0
   bne.s .tos2
   move.l 2(a5),(a2)+
   bra.s .tos3
.tos2: move (a5),(a2)+
.tos3: dbf d1,.tos0
.tos1: addq.l #6,a5
   move (a5)+,(a2)+
   move.b (a4)+,d0
   ext.w d0
   move d0,(a2)+
   move d2,(a2)+
   addq.l #2,a5
   move (a5)+,(a2)+
   move.l (a5)+,(a2)+
   tst.b (a4)
   beq.s .tos4
   move (a5),(a2)+
.tos4: rts
.lb23: cmp.b #21,d2
   bne.s .lb24
   lea bblk-1588(pc),a4
   move #$4e4d,d2
   bra.s .lb22
.lb24: cmp.b #22,d2
   bne.s .lb25
   lea xblk-1632(pc),a4
   move #$4e4e,d2
   bra.s .lb22
.lb25: cmp.b #19,d2
   bne.s .lb26
   bsr .ch
   lea .type19(pc),a5
   move (a5)+,(a2)+
   move.l a4,(a2)+
   addq.l #4,a5
   move.l (a5)+,(a2)+
   move.l (a5)+,(a2)+
   rts
.lb26: cmp.b #20,d2
   bne.s .lb27
   bsr .ch
   lea .type20(pc),a5
   move (a5),(a2)+
   addq.l #6,a5
   move.l a4,(a2)+
   move.l (a5)+,(a2)+
   move.l (a5)+,(a2)+
   move.l (a5),(a2)+
   rts
.lb27: cmp.b #23,d2
   bne.s .lb28
   clr.l -(a6)
   rts
.lb28: cmp.b #25,d2
   bne.s .lb281
   lea .type25(pc),a4
.lb280: move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l a2,-(a6)
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   rts
.lb281: cmp.b #33,d2
   bne.s .lb282
   lea .type33(pc),a4
   bra.s .lb280
.lb282: cmp.b #34,d2
   bne.s .lb283
   lea .type34(pc),a4
   bra.s .lb280
.lb283: cmp.b #35,d2
   bne.s .lb29
   lea .type35(pc),a4
   bra.s .lb280
.lb29: cmp.b #24,d2
   bne.s .lb31
.lb30: move.l (a6)+,d2
   beq .sortie
   move.l d2,a4
   move.l a2,(a4)
   bra.s .lb30
.lb31: cmp.b #26,d2
   bne.s .lb32
   lea .type26(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l a2,-(a6)
   rts
.lb32: cmp.b #27,d2
   bne.s .lb33
   lea .type27(pc),a4
   move.l (a4),(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #6,a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   subq #8,d2
   move d2,(a2)+
   move 2(a4),(a2)+
   rts
.lb33: cmp.b #28,d2
   beq .sortie
   cmp.b #29,d2
   bne.s .lb34
   move #$0696,(a2)+
   clr (a2)+
   move courant,(a2)+
   bra.s .exec
.lb34: cmp.b #30,d2
   bne.s .lb35
.exec: lea .type30(pc),a4
   moveq #6,d2
.exe0: move.l (a4)+,(a2)+
   dbf d2,.exe0
   rts
.lb35: cmp.b #32,d2
   bne.s .lb36
   move #$4eb9,(a2)+
   move.l #dlcomp,(a2)+
   move.l a2,-(a6)
   rts
.lb36: cmp.b #31,d2
   bne .bug
   lea .type31(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   rts
.fin: move #$4e75,(a2)+
   move.l a2,topprg
   move.l #but,a2
   move.l (a2)+,d0
   move.l (a2),-4(a2)
   move.l d0,(a2)
   move.l topsav2,a2
   clr ass
   rts
.us: asl #2,d4
   move.l  0(a3,d4.w),a4
   move (a4)+,d2
   cmp #437,d2
   bne.s .u1
   move #$4eb9,(a2)+
   move.l a4,(a2)+
   rts
.u1: cmp #140,d2
   bne.s .u2
   move .emp(pc),(a2)+
   move.l a4,(a2)+
   rts
.u2: cmp #141,d2
   bne.s .u3
   move .emp1(pc),(a2)+
   move.l a4,(a2)+
   rts
.u3: cmp #142,d2
   bne.s .u4
   lea .t142(pc),a5
   move.l (a5)+,(a2)+
   move (a5)+,(a2)+
   move.l a4,(a2)+
   addq.l #4,a5
   move (a5),(a2)+
   rts
.u4: cmp #143,d2
   bne.s .u5
   addq.l #4,a4
   move .emp(pc),(a2)+
   move.l a4,(a2)+
   rts
.u5: cmp #144,d2
   bne.s .u6
   lea .t144(pc),a5
   move.l (a5)+,(a2)+
   move.l (a4)+,(a2)+
   addq.l #4,a5
   move.l (a5)+,(a2)+
   move.l (a5)+,(a2)+
   move.l (a5)+,(a2)+
   move.l a4,(a2)+
   move 4(a5),(a2)+
   rts
.u6: cmp #145,d2
   bne.s .u7
   lea .t145(pc),a5
   move.l (a5)+,(a2)+
   move (a5)+,(a2)+
   move.l a4,(a2)+
   move.l 4(a5),(a2)+
   rts
.u7: cmp #628,d2
   bne.s .u8
   ext.l d4
   move .emp(pc),(a2)+
   move.l d4,(a2)+
   rts
.u8: cmp #706,d2
   bne.s .bug2
   lea .t706(pc),a5
   move.l (a5)+,(a2)+
   move (a5)+,(a2)+
   subq.l #2,a4
   move.l a4,(a2)+
   move 4(a5),(a2)+
   rts
.bug2: 
.bug1: lea ordres(pc),a0
   move.l #mot,a1
   move.b #13,(a1)+
   move.b #10,(a1)+
.blb1: subq #1,d4
   bmi.s .blb2
   move.b (a0)+,d2
   ext.w d2
   ext.l d2
   add.l d2,a0
   bra.s .blb1
.blb2: move.b (a0)+,d1
   ext.w d1
   subq #1,d1
.blb3: move.b (a0)+,(a1)+
   dbf d1,.blb3
   clr.b (a1)
   pea mot
   GEMDOS 9,6
.bug: move #1,erreur
   rts
.ch: move #$4ef9,(a2)+
   move.l a2,a4
   addq.l #4,a2
.ch1: move.b (a0)+,d0
   beq.s .ch3
   cmp.b #34,d0
   beq.s .ch2
   move.b d0,(a2)+
   bra.s .ch1
.ch2: clr.b (a2)+
   move.l a0,d0
   addq.l #1,d0
   bclr #0,d0
   move.l d0,a0
   move.l a2,d0
   addq.l #1,d0
   bclr #0,d0
   move.l d0,a2
   move.l d0,(a4)+
   rts
.ch3: move #1,erreur
   rts
.emp: move.l #2,-(a6)
.type3: dc.w $4eb9
.type17: move #100,d1
.type6: subq.l #8,a4
   move.l (a6)+,(a4)
   move.l (a6)+,4(a4)
   move.l #indptr,a1
   addq.l #4,(a1)
   move.l (a1),a2
   move.l a4,(a2)
   dc.w 0
.type4: addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type13
   addq.l #8,a4
   subq.l #4,indptr
.type13: tst.l (a6)+
   bne.s .type5
.type14: dc.w $4ef9,0,0
.type5: move.l (a6)+,d1
   ble.s .ttt5
   add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type16
.tt5: addq.l #8,a4
   subq.l #4,indptr
   bra.s .type16
.ttt5: add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bpl .type16
   bra.s .tt5
.type16: tst.l (a6)+
   beq.s .t16
   addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type18
.t16: move.l (a4),-(a6)
   addq.l #8,a4
   subq.l #4,indptr.l
.type18: move.l uspile,a7
   dc.w $4ef9
   dc.l debut
.t142: move.l (a6),d1
   asl.l #2,d1
   add.l #1212,d1
   move.l d1,(a6)
.t144: move.l (a6),d1
   move.l #1212,d2
   addq.l #1,d2
   bclr #0,d2
   addq.l #4,d2
   mulu d2,d1
   add.l #1212,d1
   move.l d1,(a6)
.t145: move.l (a6),d1
   asl.l #2,d1
   move.l #1212,a0
   move.l (a0,d1),(a6)
.t706: move.l (a6),d1
   add.l d1,d1
   add.l #1212,d1
   move.l d1,(a6)
.tos: move.l a7,topsave.l
   move.l (a6)+,-(a7)
   move.l (a6)+,d0
   move d0,-(a7)
   move #1212,-(a7)
   move.l topsave.l,a7
   move.l d0,-(a6)
.type19: move.l #1212,-(a7)
   move #9,-(a7)
   trap #1
   addq.l #6,a7
.type20: move.l #1212,a0
   move.l #pad+4,a1
   move.l a1,-(a6)
.t20: move.b (a0)+,(a1)+
   bne.s .t20
.type25: move.l (a6)+,d1
   cmp.l (a6),d1
   beq.s .t25
   dc.w $4ef9,0,0
.t25: UP
.type33: move.l (a6)+,d1
   cmp.l (a6),d1
   bne.s .t33
   dc.w $4ef9,0,0
.t33: UP
.type34: move.l (a6)+,d1
   cmp.l (a6),d1
   bmi.s .t34
   dc.w $4ef9,0,0
.t34: UP
.type35: move.l (a6)+,d1
   cmp.l (a6),d1
   bgt.s .t35
   dc.w $4ef9,0,0
.t35: UP
.type26: clr.l -(a4)
   move.l (a6)+,d0
   subq.l #1,d0
   swap d0
   move.l d0,-(a4)
.type27: subq #1,(a4)
   bcc .type30
   subq #1,2(a4)
   bcc .type30
   addq.l #8,a4
.type30: moveq #2,d0
   move.l (a6)+,d1
   cmp #diko,d1
   bpl.s .t30
   moveq #0,d0
.t30: asl #2,d1
   move.l #adresse,a1
   move.l  0(a1,d1.w),a1
   add.w d0,a1
   jsr (a1)
.emp1: move.l $fffff.l,-(a6)
.type31: move.l indptr,a1
   addq.l #4,(a1)
   subq.l #1,(a4)
   bne .typee1
   addq.l #8,a4
   subq.l #4,lstptr
   subq.l #4,indptr
.typee1: rts

ouvre_vdi:
	tst.b aes_flag
	bne.s .virtuel
	move #1,ow_cont			; station physique dans dossier AUTO
.virtuel:
   XBIOS 4,2
   add d0,ow_int
   GEM_VDI open_work
   move #100,ow_cont			; toujours virtuelle pour la deuxiŠme
   move ow_cont+12,d6
   GEM_VDI open_work
   move ow_cont+12,handle
   move d6,i_handle
   GEM_VDI hide_mouse
	rts
	
adresse:
 dc.l empile,vayab,const,array,string,charray,table,ret1,ret2,raff,dup2
 dc.l depth,drop,dup,over,pick,rzer,roll,rot,rpinit,wdmod
 dc.l rpaff,s0,spinit,wmod,spaff,swap,mul,mulw,wdiv,plus
 dc.l plm,moins,div,divm,inf0,eg0,sup0,sup,inf,egal
 dc.l plus1,moins1,plus2,moins2,mul2,div2,abs,and,max,min
 dc.l mod,neg,not,or,xor,loop,looppls,do,again,begin
 dc.l until,while,repeat,exit,case,of,else,endcase,if,else
 dc.l then,appl_find,i,j,k,leave,virg,0,pvirg,allot
 dc.l chsto,chplus,chegal,chinf,chsup,asc,bbase,chr,decimal,hex
 dc.l instr,len,left,mid,mlen,ppad,right,str,0,val
 dc.l sto,stop,stom,stop1,stom1,0,0,aff,rcl,0
 dc.l carsto,carrcl,0,cls,addrsto,0,0,bin,here,dupm
 dc.l dropm,fin,0,point,term,bl,cr,emit,expect,inkey
 dc.l input,inputc,key,spc,spcs,type,fin,disply,chain,var1
 dc.l cons1,arr1,str1,char1,tab1,quit,timer,dif,free,full
 dc.l pilaf,allot0,does,0,doesa,ifloop,0,0,0
 dc.l stform,diese,hold,dieses,edform
 dc.l call,0,0,0,0,0,0,top
 dc.l aess,vdii,ctrl,iin,pin,iout,pout,ain,aout,wrcl
 dc.l wsto,hdl,vctrl,actrl,seizeb,vint,ptinsto,aint,gmds,bioss
 dc.l xbioss,wvirg,ebw,ebl,ewl,puts,gets,fcr,fop,fcl
 dc.l frd,fwr,fgd,fdl,ffs,fnx,dta,fsd,fsk,fsk1
 dc.l fsk2,xv_opnwk,xv_updwk,_global,vq_aes,vsync,joyst,mouse,jx0,jy0
 dc.l fire0,jx1,jy1,fire1,mousx,mousy,mousk,hadr,super,user
 dc.l v_opnvwk,vst_load_fonts,vst_unload_fonts,vs_clip,v_pline,v_pmarker
 dc.l v_gtext,v_fillarea,v_contourfill,v_recfl,vswr_mode
 dc.l vs_color,vsl_type,vsl_udsty,vsl_width,vsl_color
 dc.l vsl_ends,vsm_type,vsm_height,vsm_color,vst_height
 dc.l vst_point,vst_rotation,vst_font,vst_color
 dc.l vst_effects,vst_alignment,vsf_interior,vsf_style
 dc.l vsf_color,vsf_perimeter,vsf_udpat,vsc_form,vex_timv
 dc.l v_show_c,vq_color,vqt_extent,vqt_width,vqt_name
 dc.l v_clsvwk,v_clrwk,v_hide_c,vq_key_s,vql_attributes
 dc.l vqm_attributes,vqf_attributes,vqt_attributes
 dc.l vqt_fontinfo,v_bar,v_arc,v_pieslice,v_circle
 dc.l v_ellipse,v_ellarc,v_ellpie,v_rbox,v_rfbox
 dc.l v_justified,vq_chcells,v_exit_cur,v_enter_cur
 dc.l v_curup,v_curdown,v_curright,v_curleft,v_curhome
 dc.l v_eeos,v_eeol,vs_curaddress,v_curtext,v_rvon
 dc.l v_rvoff,vq_curaddress,vq_tabstatus,v_hardcopy
 dc.l _appl_init,graf_handle,evnt_keybd
 dc.l rsrc_free,wind_get,_wind_create,_wind_open,wind_delete
 dc.l _wind_set,wind_find,_wind_update,_wind_calc
 dc.l evnt_button,evnt_mouse,evnt_timer,form_error
 dc.l _wind_close,graf_rubberbox,graf_dragbox,graf_movebox
 dc.l graf_growbox,graf_shrinkbox,graf_mkstate,evnt_dclick
 dc.l evnt_mesag,evnt_multi,appl_read,appl_write
 dc.l objc_draw,objc_find,objc_offset,objc_edit
 dc.l objc_change,rsrc_load,rsrc_saddr,form_do,form_dial
 dc.l form_center,form_alert,menu_icheck,menu_ienable
 dc.l menu_tnormal,menu_register,graf_watchbox,graf_slidebox
 dc.l graf_mouse,scrp_read,scrp_write,shel_get,shel_put
 dc.l shel_find,rsrc_gaddr,menu_text,fsel_input
 dc.l shel_read,shel_write,shel_envrn,format
 dc.l menu_bar,xcut,xplus
 rept 28
    dc.l blockgds
 endr
 rept 11
    dc.l blockbs
 endr
 rept 28
    dc.l blockxbs
 endr
 dc.l st,ass1,tt,count,pair,sizeb,sizeb,sizew,sizel
 dc.l timera,timerb,timerc,timerd
 dcb.l 24,0 
 dc.l sizeb,sizew,sizel
 dcb.l 75,0
 dc.l vdisto,aessto,pre1,pre2,pre3,pre4
 dc.l post1,post2,post3,post4,siz,cvirg,wmulsto,wdivsto,mulsto2
 dc.l divsto2,deces,segferme,segouvert,word,0,ndo,nloop,list,dolist
 dc.l lloop,remember,restore,0,0,bpt,dpt,opt,hpt,struct,pointer
 dc.l name,sizeof,schain,unchain,next,previous,screate,sdel,empty
 dc.l view,inchain,pchain,punchain,pinchain,ssto,0,fast,slow
 dc.l start,pushs,pushv,pushc,display,dir,ouvert,et,ferme,setof
 dc.l setplus,setfois,setmoins,card,setegal,setin,elmtrcl,elmtplus
 dc.l elmtmoins,elmtin,initset,pads,segment,et1,fplus,fmoins,ffois
 dc.l fdiv,fdup,fdrop,fpt,fval,empilfl,fswap,fover,fptpt,float
 dc.l frcl,fsto,fegal,fsup,appl_getinfo,sqr,fabs,appl_search,islast,appl_tplay,pempty
 dc.l 0,ltype,0,setsto,compset,pint,pstr,pflt,pset,pstruc
 dc.l rint,rstr,rflt,rset,rstruc,cmove,pee,sin,cos,tan,atn,fneg,inv
 dc.l carre,expo,loga,flint,intfl,sincos,power,int,frac,appl_trecord
 dc.l ffois2,round,sign,fsurr,rsurf,frot,fpick,vqt_devinfo,vm_filename
 dc.l v_meta_extents,vm_pagesize
 dc.l stallot,ttallot,play,difof,supof,infof,wvar,setable
 dc.l warray,war,0,setdigits,0,getfmt,then,andfl,andorpt,orfl
 dc.l pageclip,v_ftext,v_clear_disp_list,v_updwk,stack,st1,st2,current,stack0
 dc.l page,defp,setp,absolute,relative,fastcl,page0,fastop,desk,cache
 dc.l menu,setmenu,gemindex,strindex,dialogue,lastobj,child,parent
 rept 6
    dc.l objets
 endr
 rept 4
    dc.l boxtext
 endr
 dc.l image,userdef
 dc.l get_xywh,set_redraw,_redraw,_work_out,get_xyxy,vst_arbpt
 dc.l vqt_f_extent,vst_setsize,vst_skew
 dc.l icon,mfdbs,mfdbd,vr_trnfm,vrt_cpyfm,vro_cpyfm,topsur
 dc.l surtop,setplay,path,loadbin,savebin,setreplay,replay,replay_in
 dc.l replay_out,replay_end,cookie,vm_coords,v_opnwk,v_clswk,_page,0,0
 dc.l v_alpha_text,v_bez,v_bez_fill,v_bez_off,v_bez_on,v_bez_qual
 dc.l v_bit_image,v_fulshcache,v_fontinit,v_form_adv,v_ftext16,v_ftext_offset
 dc.l v_ftext_offset16,v_getbitmap_info,v_getoutline,v_get_pixel,v_loadcache
 dc.l v_output_window,v_pgcount,v_savecache,v_set_app_buff,v_write_meta
 dc.l vex_butv,vex_curv,vex_motv,vq_extnd,vq_gdos,_vq_mouse,vq_scan
 dc.l vqt_advance32,vqt_advance,vqt_cachesize,vqt_f_extent16,vqt_fontheader
 dc.l vqt_get_table,vqt_pairkern,vqt_trackkern,vst_arbpt32,vst_charmap
 dc.l vst_error,vst_kern,vst_scratch,vst_setsize32
 dc.l form_button,form_keybd,fsel_exinput,menu_attach,menu_istart,menu_popup
 dc.l menu_settings,objc_add,objc_delete,objc_order,objc_sysvar,rsrc_obfix
 dc.l rsrc_rcfix,wind_new,basepage,_app,reserve,nvmaccess,wdial_create,wdial_open
 dc.l wdial_close,wdial_formdo,wdial_change,wdial_evnt
 dc.l vq_margin,vq_driver_info,vq_bit_image,vs_page_info
 dc.l vs_crop,vq_image_type,nul_char,0	; trace_win
 dc.l 0,0,0,0,0								; de >include … >exec
adrfin: dcb.l 100,0

diko equ (adrfin-adresse)/4

initial:
	move.l a0,d0
	bne.s .accessoire
   move.l  4(a7),a5
   move.l a5,bspage
   move.l  $18(a5),d0
   add.l $1c(a5),d0
   add.l #$100,d0
   move.l #_pile,sp
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12
   moveq #1,d0
   move.l d0,_app_flag
   bra.s .init
.accessoire:
	clr.l _app_flag
	move.l #_pile,a7
.init:
   clr.l global
   GEM_AES appl_init
   tst global+2
   sne aes_flag			; aes flag … FF.b si AES pr‚sent
   tst.b aes_flag
   beq.s .auto
   GEM_AES mouse_form
   GEM_AES graf_hand
   move.l intout+2,fenetre0+12
   move intout,d7
   move d7,i_handle
   bsr ouvre_vdi
   bra.s .aes
.auto: 
	move #-1,i_handle			; signale pas d'ouverture
.aes:   
   move.l  #-1,-(sp)
   GEMDOS $48,6
   move.l  d0,d1
   lsr.l #2,d1
   sub.l d1,d0
   bclr #0,d0
   move.l  d0,d7
   move.l  d0,-(sp)
   GEMDOS $48,6
   move.l  d0,program
   move.l  d0,topprg
   add.l d0,d7
   subq.l #4,d7
   move.l  d7,topmem
   move.l  d7,botmem
   move.l  #1028,-(sp)
   GEMDOS $48,6
   move.l  d0,a0
   move.l  d0,szone
   clr.l (a0)+
   clr.l (a0)+
   moveq #-1,d0
   move.l  d0,(a0)
   move #1024,pad
   move #3,-(sp)
   move #15,-(sp)
   XBIOS 35,6
   clr.l remdata
   clr.b edbuf
   move.l  a7,uspile
   XBIOS 34,2
   add.l #60,d0
   move.l d0,joystick
   clr.l -(sp)
   GEMDOS 32,6
   move.l $4f2,a0
   move 2(a0),d4
   cmp #$0306,d4
   bne.s .lb0
   addq.l #2,joystick
.lb0: 
   jsr nova_init

   move.l d0,-(sp)
   GEMDOS 32,6
  
   move.l pilptr,a6
   move.l retptr,a4
   move.l #findata,a5
   addq.l #4,a5
   move #9,fixn
   
   jmp debut

ordres:
   dc.b 6,"[empl]",8,"variable",8,"constant",5,"array",6,"string"
   dc.b 6,"array$",5,"table",2,">r",2,"r>",2,"r@",4,"?dup"
   dc.b 5,"depth",4,"drop",3,"dup",4,"over",4,"pick",2,"r0"
   dc.b 4,"roll",3,"rot",3,"rp!",5,"w/mod",3,"rp@",2,"s0",3,"sp!"
   dc.b 4,"wmod",3,"sp@",4,"swap",1,"*",2,"w*",2,"w/",1,"+",2,"+-"
   dc.b 1,"-",1,"/",4,"/mod",2,"0<",2,"0=",2,"0>",1,">",1,"<",1,"="
   dc.b 2,"1+",2,"1-",2,"2+",2,"2-",2,"2*",2,"2/",3,"abs",3,"and"
   dc.b 3,"max",3,"min",3,"mod",6,"negate",3,"not",2,"or",3,"xor"
   dc.b 4,"loop",5,"+loop",2,"do",5,"again",5,"begin",5,"until"
   dc.b 5,"while",6,"repeat",4,"exit",4,"case",2,"of",5,"endof"
   dc.b 7,"endcase",2,"if",4,"else",4,"then",9,"appl_find",1,"i",1,"j"
   dc.b 1,"k",5,"leave",1,44,1,":",1,";",5,"allot",2,"$!",2,"$+"
   dc.b 2,"$=",2,"$<",2,"$>",3,"asc",4,"base",4,"chr$",7,"decimal"
   dc.b 3,"hex",5,"instr",3,"len",5,"left$",4,"mid$",4,"mlen"
   dc.b 3,"pad",6,"right$",4,"str$",1,"¹",3,"val",1,"!"
   dc.b 2,"+!",2,"-!",3,"1+!",3,"1-!",1,"¹",1,"¹",1,"?"
   dc.b 1,"@",1,"¹",2,"c!",2,"c@",4,"find",3,"cls",7,"addrin!"
   dc.b 1,"¹",1,"¹",3,"bin",4,"here",4,"dupm",5,"dropm"
   dc.b 6,"system",1,"¹",1,".",9,"?terminal",2,"bl",2,"cr",4,"emit"
   dc.b 6,"expect",5,"inkey",5,"input",6,"input$",3,"key"
   dc.b 5,"space",6,"spaces",4,"type",4,"quit",2,46,34,1,34
   dc.b 5,"[var]",5,"[cst]",5,"[arr]",5,"[str]",5,"[ar$]"
   dc.b 5,"[tab]",4,"[qt]",5,"timer",2,"<>"
   dc.b 4,"free",4,"full",2,".s",6,"allot0",6,":does>",4,";end"
   dc.b 7,"::does>",6,"ifloop",1,"¹",1,"¹",1,"¹"
   dc.b 2,"<#",1,"#",4,"hold",2,"#s",2,"#>",4,"call",1,"¹"
   dc.b 1,"¹",1,"¹",1,"¹",1,"¹",5,">comp",3,"top"
   dc.b 3,"aes",3,"vdi",7,"control",5,"intin",5,"ptsin",6,"intout"
   dc.b 6,"ptsout",6,"addrin",7,"addrout",2,"w@",2,"w!",6,"handle"
   dc.b 5,"vctrl",5,"actrl",4,"16b$",7,"vintin!",6,"ptsin!"
   dc.b 7,"aintin!",6,"gemdos",4,"bios",5,"xbios",2,"w",44,5,"extbw"
   dc.b 5,"extbl",5,"extwl",4,"puts",4,"gets",7,"fcreate",5,"fopen"
   dc.b 6,"fclose",5,"fread",6,"fwrite",7,"fgetdta",7,"fdelete"
   dc.b 6,"ffirst",5,"fnext",3,"dta",7,"fsetdta",5,"fseek",6,"fseek>"
   dc.b 6,"fseek<",8,"xv_opnwk",8,"xv_updwk",6,"global",6,"vq_aes"
   dc.b 5,"vsync",5,"joyst",5,"mouse",3,"jx0",3,"jy0",5,"fire0"
   dc.b 3,"jx1",3,"jy1",5,"fire1",6,"mousex",6,"mousey",6,"mousek"
   dc.b 6,"adress",5,"super",4,"user"
   dc.b 8,"v_opnvwk",14,"vst_load_fonts"
   dc.b 16,"vst_unload_fonts",7,"vs_clip",7,"v_pline",9,"v_pmarker"
   dc.b 7,"v_gtext",10,"v_fillarea",13,"v_contourfill",7,"v_recfl",9,"vswr_mode"
   dc.b 8,"vs_color",8,"vsl_type",9,"vsl_udsty",9,"vsl_width",9,"vsl_color"
   dc.b 8,"vsl_ends",8,"vsm_type",10,"vsm_height",9,"vsm_color",10,"vst_height"
   dc.b 9,"vst_point",12,"vst_rotation",8,"vst_font",9,"vst_color"
   dc.b 11,"vst_effects",13,"vst_alignment",12,"vsf_interior",9,"vsf_style"
   dc.b 9,"vsf_color",13,"vsf_perimeter",9,"vsf_udpat",8,"vsc_form",8,"vex_timv"
   dc.b 8,"v_show_c",8,"vq_color",10,"vqt_extent",9,"vqt_width",8,"vqt_name"
   dc.b 8,"v_clsvwk",7,"v_clrwk",8,"v_hide_c",8,"vq_key_s",14,"vql_attributes"
   dc.b 14,"vqm_attributes",14,"vqf_attributes",14,"vqt_attributes"
   dc.b 12,"vqt_fontinfo",5,"v_bar",5,"v_arc",10,"v_pieslice",8,"v_circle"
   dc.b 9,"v_ellipse",8,"v_ellarc",8,"v_ellpie",6,"v_rbox",7,"v_rfbox"
   dc.b 11,"v_justified",10,"vq_chcells",10,"v_exit_cur",11,"v_enter_cur"
   dc.b 7,"v_curup",9,"v_curdown",10,"v_curright",9,"v_curleft",9,"v_curhome"
   dc.b 6,"v_eeos",6,"v_eeol",13,"vs_curaddress",9,"v_curtext",6,"v_rvon"
   dc.b 7,"v_rvoff",13,"vq_curaddress",12,"vq_tabstatus",10,"v_hardcopy"
   dc.b 9,"appl_init",11,"graf_handle",10,"evnt_keybd"
   dc.b 9,"rsrc_free",8,"wind_get",11,"wind_create",9,"wind_open",11,"wind_delete"
   dc.b 8,"wind_set",9,"wind_find",11,"wind_update",9,"wind_calc"
   dc.b 11,"evnt_button",10,"evnt_mouse",10,"evnt_timer",10,"form_error"
   dc.b 10,"wind_close",14,"graf_rubberbox",12,"graf_dragbox",12,"graf_movebox"
   dc.b 12,"graf_growbox",14,"graf_shrinkbox",12,"graf_mkstate",11,"evnt_dclick"
   dc.b 10,"evnt_mesag",10,"evnt_multi",9,"appl_read",10,"appl_write"
   dc.b 9,"objc_draw",9,"objc_find",11,"objc_offset",9,"objc_edit"
   dc.b 11,"objc_change",9,"rsrc_load",10,"rsrc_saddr",7,"form_do",9,"form_dial"
   dc.b 11,"form_center",10,"form_alert",11,"menu_icheck",12,"menu_ienable"
   dc.b 12,"menu_tnormal",13,"menu_register",13,"graf_watchbox",13,"graf_slidebox"
   dc.b 10,"graf_mouse",9,"scrp_read",10,"scrp_write",8,"shel_get",8,"shel_put"
   dc.b 9,"shel_find",10,"rsrc_gaddr",9,"menu_text",10,"fsel_input"
   dc.b 9,"shel_read",10,"shel_write",10,"shel_envrn",6,"format"
   dc.b 8,"menu_bar",4,"exec",4,"exe+",6,"pterm0",8,"ptermres",5,"pterm"
   dc.b 5,"pexec",7,"dsetdrv",7,"dgetdrv",8,"dsetpath",8,"dgetpath"
   dc.b 5,"dfree",7,"dcreate",7,"ddelete",7,"frename",7,"fattrib"
   dc.b 7,"fduplic",6,"fforce",6,"malloc",5,"mfree",7,"mshrink",6,"cauxin"
   dc.b 7,"cauxout",7,"cprnout",6,"crawio",6,"cconws",6,"cconrs"
   dc.b 6,"cconis",6,"cprnos",6,"cauxis",6,"cauxos",8,"bconstat"
   dc.b 7,"bcostat",6,"bconin",7,"bconout",5,"rwabs",7,"mediach"
   dc.b 6,"drvmap",6,"getmpb",6,"getbpb",7,"kbshift",7,"setexec"
   dc.b 8,"physbase",7,"logbase",6,"getrez",9,"setscreen",10,"setpalette"
   dc.b 8,"setcolor",6,"floprd",6,"flopwr",7,"flopver",6,"mfpint"
   dc.b 7,"jdisint",8,"jenabint",7,"xbtimer",8,"kbdvbase",6,"midiws"
   dc.b 8,"giaccess",7,"dosound",8,"offgibit",7,"ongibit",6,"setprt"
   dc.b 6,"rsconf",5,"iorec",8,"initmous",6,"keytbl",8,"bioskeys"
   dc.b 6,"kbrate",6,"random",7,"supexec",6,"MFP_ST",5,"[ass]"
	dc.b 6,"MFP_TT",5,"count",4,"even",5,"delay",8,"auto_end",8,"soft_end"
	dc.b 10,"timer_stop",6,"timerA",6,"timerB",6,"timerC",6,"timerD"
 	rept 24
   dc.b 1,"¹"
   endr
   dc.b 2,".b",2,".w",2,".l"
   rept 75
   dc.b 1,"¹"
   endr
   dc.b 4,"vdi!",4,"aes!",3,"-(@",3,"-(!"
   dc.b 3,"+(@",3,"+(!",3,")-@",3,")-!",3,")+@",3,")+!",4,"size",2,"c"
   dc.b 44,3,"w*!",3,"w/!",3,"2*!",3,"2/!",3,"dcs",5,"<seg>",5,">seg<"
   dc.b 5,"word$",2,"::",3,"ndo",5,"nloop",4,"list",6,"dolist",5,"lloop"
   dc.b 8,"remember",7,"restore",1,"¹",1,"¹",2,"b.",2,"d.",2,"o."
   dc.b 2,"h.",6,"struct",8,"&pointer",5,"&name",6,"sizeof"
   dc.b 5,"chain",7,"unchain",4,"next",8,"previous",7,"screate"
   dc.b 7,"sdelete",5,"empty",2,"..",7,"inchain",6,"pchain"
   dc.b 8,"punchain",8,"pinchain",2,"s!",1,"¹",4,"fast",4,"slow"
   dc.b 5,"start",5,"pushs",5,"pushv",5,"pushc",7,"display",3,"dir"
   dc.b 2,"&(",1,"&",2,"&)",6,"&setof",4,"set+",4,"set*",4,"set-"
   dc.b 4,"card",4,"set=",5,"setin",5,"elmt@",5,"elmt+",5,"elmt-"
   dc.b 6,"elmtin",7,"initset",4,"pads",8,"&segment",3,"[&]",2,"f+"
   dc.b 2,"f-",2,"f*",2,"f/",4,"fdup",5,"fdrop",2,"f.",4,"fval"
   dc.b 4,"[fl]",5,"fswap",5,"fover",3,"f..",6,"&float",2,"f@",2,"f!"
   dc.b 2,"f=",2,"f>",12,"appl_getinfo",3,"sqr",4,"fabs",11,"appl_search",6,"islast"
   dc.b 10,"appl_tplay",6,"pempty",1,"¹",5,"ltype",1,"¹",4,"set!"
   dc.b 4,"-set",4,"int>",4,"str>",4,"flt>",4,"set>",6,"struc>",4,">int"
   dc.b 4,">str",4,">flt",4,">set",6,">struc",5,"cmove",2,"pi",3,"sin"
   dc.b 3,"cos",3,"tan",3,"atn",4,"fneg",3,"1/x",3,"x^2",3,"exp",3,"log"
   dc.b 4,"ftoi",4,"itof",6,"sincos",3,"x^y",3,"int",4,"frac"
   dc.b 12,"appl_trecord",5,"f*2^n",5,"round",4,"sign",3,"f>r",3,"r>f"
   dc.b 4,"frot",5,"fpick",11,"vqt_devinfo",11,"vm_filename"
   dc.b 14,"v_meta_extents",11,"vm_pagesize"
   dc.b 7,"stallot",7,"ttallot",4,"play",4,"<>of",3,">of",3,"<of"
   dc.b 5,"&wvar",7,"setable",7,"&warray",5,"[war]",1,"¹",9,"setdigits"
   dc.b 1,"¹",6,"getfmt",2,"->",5,"and->",3,"->.",4,"or->",8,"pageclip"
   dc.b 7,"v_ftext",17,"v_clear_disp_list",7,"v_updwk",6,"&stack",3,">st",3,"st>"
   dc.b 7,"current",6,"stack0",5,"&page",7,"defpage",7,"setpage",8,"absolute"
   dc.b 8,"relative",9,"fastclose",5,"page0",8,"fastopen",4,"desk",5,"cache",4,"menu"
   dc.b 7,"setmenu",8,"gemindex",8,"strindex",8,"dialogue",7,"lastobj"
   dc.b 7,"child<<",2,">>",3,"BOX",4,"IBOX",7,"BOXCHAR",6,"BUTTON"
   dc.b 6,"STRING",5,"TITLE",4,"TEXT",7,"BOXTEXT",5,"FTEXT",8,"FBOXTEXT"
   dc.b 5,"IMAGE",7,"USERDEF",8,"get_xywh",10,"set_redraw",6,"redraw",8,"work_out"
   dc.b 8,"get_xyxy",9,"vst_arbpt",12,"vqt_f_extent",11,"vst_setsize"
   dc.b 8,"vst_skew",4,"ICON"
   dc.b 5,"mfdbs",5,"mfdbd",8,"vr_trnfm",9,"vrt_cpyfm",9,"vro_cpyfm",4,"top>"
   dc.b 4,">top",7,"setplay",4,"path",7,"loadbin",7,"savebin",9,"setreplay"
   dc.b 6,"replay",9,"replay_in",10,"replay_out",10,"replay_end",7,"&cookie"
   dc.b 9,"vm_coords",7,"v_opnwk",7,"v_clswk",4,"page",1,"¹",1,"¹"
   dc.b 12,"v_alpha_text",5,"v_bez",10,"v_bez_fill",9,"v_bez_off",8,"v_bez_on"
 dc.b 10,"v_bez_qual",11,"v_bit_image",12,"v_fulshcache",10,"v_fontinit"
 dc.b 10,"v_form_adv",9,"v_ftext16",14,"v_ftext_offset",16,"v_ftext_offset16"
 dc.b 16,"v_getbitmap_info",12,"v_getoutline",11,"v_get_pixel",11,"v_loadcache"
 dc.b 15,"v_output_window",9,"v_pgcount",11,"v_savecache",14,"v_set_app_buff"
 dc.b 12,"v_write_meta",8,"vex_butv",8,"vex_curv",8,"vex_motv",8,"vq_extnd"
 dc.b 7,"vq_gdos",8,"vq_mouse",7,"vq_scan",13,"vqt_advance32",11,"vqt_advance"
 dc.b 13,"vqt_cachesize",14,"vqt_f_extent16",14,"vqt_fontheader",13,"vqt_get_table"
 dc.b 12,"vqt_pairkern",13,"vqt_trackkern",11,"vst_arbpt32",11,"vst_charmap"
 dc.b 9,"vst_error",8,"vst_kern",11,"vst_scratch",13,"vst_setsize32",11,"form_button"
 dc.b 10,"form_keybd",12,"fsel_exinput",11,"menu_attach",11,"menu_istart",10,"menu_popup"
 dc.b 13,"menu_settings",8,"objc_add",11,"objc_delete",10,"objc_order",11,"objc_sysvar"
 dc.b 10,"rsrc_obfix",10,"rsrc_rcfix",8,"wind_new",8,"basepage",4,"_app"
 dc.b 7,"reserve",9,"nvmaccess",13,"&wdial_create",10,"wdial_open",11,"wdial_close"
 dc.b 12,"wdial_formdo",12,"wdial_change",10,"wdial_evnt"
 dc.b 9,"vq_margin",14,"vq_driver_info",12,"vq_bit_image",12,"vs_page_info"
 dc.b 7,"vs_crop",13,"vq_image_type",9,"#nul_char",1,"¹",8,">include"
 dc.b 5,">true",6,">false",7,">export",5,">exec"
 dcb.b 3000,0

   even

gblk: dc.b 0,-1,0,0,1,1,49,0,0,0,76,0,%1110,3,75,1,0,0,14,1,0,-1,25,1,1,0,59,1
      dc.b 1,1,71,1,1,1,54,0,1,0,57,1,1,0,58,1,%110,2,86,1,1,2,67,1,0,0,69,1
      dc.b 0,1,70,1,1,0,72,1,1,0,73,1,%110,2,74,1,0,-1,3,1,0,0,4,0,0,0,5,1
      dc.b 0,0,6,1,1,0,9,0,1,0,10,1,0,-1,11,1,0,-1,17,1,0,-1,18,1,0,-1,19,1

bblk: dc.b 0,0,1,1,0,0,8,1,0,0,2,1,0,1,3,0,%10,4,4,1,0,0,9,1,0,-1,10,1
      dc.b 1,0,0,0,0,0,7,1,0,0,11,1,%10,1,5,0

xblk: dc.b 0,-1,2,1,0,-1,3,1,0,-1,4,1,%11,2,5,0,1,0,6,0,0,1,7,0,%11,6,8,1
      dc.b %11,6,9,1,%11,6,19,1,%10,1,13,0,0,0,26,0,0,0,27,0,%1000,3,31,0
      dc.b 0,-1,34,1,%10,1,12,0,0,1,28,1,1,0,32,0,0,0,29,0,0,0,30,0,0,0,33,1
      dc.b 0,5,15,0,0,0,14,1,%110,2,0,0,%111,2,16,0,0,-1,24,0,0,1,35,1
      dc.b 0,-1,17,1,1,0,38,0

   data
   even

; puissances de 10 de 10^-1 … 10^-256

negdata:  dc.l $3fb99999,$9999999a
          dc.l $3f847ae1,$47ae147a
          dc.l $3f1a36e2,$eb1c432c
          dc.l $3e45798e,$e2308c38
          dc.l $3c9cd2b2,$97d889b7
          dc.l $3949f623,$d5a8a729
          dc.l $32a50ffd,$44f4a72d
          dc.l $255bba08,$cf8c9771
          dc.l $0ac80628,$64ac6ef7

; puissances de 10 de 10^1 … 10^256

posdata: dc.l $40240000,0
         dc.l $40590000,0
         dc.l $40c38800,0
         dc.l $4197d784,0
         dc.l $4341c379,$37e08000
         dc.l $4693b8b5,$b5056e16
         dc.l $4d384f03,$e93ff9f3
         dc.l $5a827748,$f9301d2e
         dc.l $75154fdd,$7f73bf33

; nombres r‚els de 1 … 9

chdata:  dc.w $3ff0,$4000,$4008,$4010,$4014,$4018,$401c,$4020,$4022

; donn‚es pour le CORDIC

cordk:  dc.l $3fe36e9d,$b5086bcb
        dc.l $3ff351e8,$7200eec2
pi:     dc.w $4009,$21fb,$5444,$2d18
pisur2: dc.w $3ff9,$21fb,$5444,$2d18


findata: dc.l initial

 end
