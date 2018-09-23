debug=0
*
*
* On va faire un raster en TrueColor, STABLE.
* 
*
*
;
;
; Quelques constantes pour les modes vid‚os
;
;
col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256

mode=coltc+l40+tv+pal

 pea superviseur
 move #$26,-(sp)
 trap #14
 addq #6,sp
;
; Et quitte
; 
 clr -(sp)
 trap #1



 
superviseur 
 move.l #ecran+4,d0
 and #-1-%11,d0
 move.l d0,‚cran
 
 ifeq debug
;
; R‚cupŠre la r‚solution courante et l'adresse de la m‚moire
; vid‚o
;
 move #-1,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 move d0,old_video
 
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,old_adresse

;
; Valide ma propre r‚solution
; et mon propre ecran
; 
 move #mode,-(sp)
 move #3,-(sp)
 move.l ‚cran,-(sp)
 move.l ‚cran,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc

 bsr installe_hbl

 bsr affichage
 
 move #7,-(sp)
 trap #1
 addq #2,sp

 bsr supprime_hbl
  
;
; Restaure tout
; 
 ifeq debug
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc
 rts


installe_hbl
 bsr vsync
 bsr vsync
 bsr vsync
 bsr vsync
 move sr,d0
 move #$2700,sr
 move.l $70.w,sauve_70
 move.l #routine_vbl,$70.w	Installe la VBL
 move.l $120.w,sauve_120
 move.l #routine_hbl,$120.w
 move.b $ffff8a07.w,sauve_iera
 move.b $ffff8a09.w,sauve_ierb
 move.b $ffff8a13.w,sauve_imra
 move.b $ffff8a15.w,sauve_imrb
 move.b $ffff8a17.w,sauve_vr
 move.b $ffff8a1b.w,sauve_tbcr
 move.b $ffff8a21.w,sauve_tbdr
 bset #0,$fffffa07.w
 bset #0,$fffffa13.w
 move d0,sr
 bsr vsync
 bsr vsync
 bsr vsync
 bsr vsync
 rts

 
supprime_hbl
 bsr vsync
 bsr vsync
 bsr vsync
 bsr vsync
 bsr vsync
 move sr,d0
 move #$2700,sr
 move.l sauve_70,$70.w
 move.l sauve_120,$120.w
 move.b sauve_iera,$ffff8a07.w
 move.b sauve_ierb,$ffff8a09.w
 move.b sauve_imra,$ffff8a13.w
 move.b sauve_imrb,$ffff8a15.w
 move.b sauve_vr,$ffff8a17.w
 move.b sauve_tbcr,$ffff8a1b.w
 move.b sauve_tbdr,$ffff8a21.w
 move d0,sr
 bsr vsync
 bsr vsync
 bsr vsync
 bsr vsync
 rts


vsync
 movem.l d0-a6,-(sp)
 move #37,-(sp)
 trap #14
 addq #2,sp
 movem.l (sp)+,d0-a6
 rts

 
routine_hbl
 not.l $ffff9800.w
 clr.b $fffffa1b.w 
 bclr #0,$fffffa0f.w
 rte
  

routine_vbl
* movem.l d0-a6,-(sp)	Sauve les registres

*****
 move.l #-1,$ffff9800.w
 clr.b $fffffa1b.w
 move.b #50,$fffffa21.w
 move.b #8,$fffffa1b.w
*****
   
* movem.l (sp)+,d0-a6	Restaure les registres
 jmp ([sauve_70])	On r‚ex‚cute la VBL systŠme... *** Hum...!




affichage
 move.l ‚cran,a0
 move #0,d0
 move.l #320*200-1,d0
.loop
 move d0,(a0)+
 subq #1,d0
 bne .loop
 rts
  
 section DATA 

 section BSS

old_video	ds.w 1 
old_adresse	ds.l 1
‚cran		ds.l 1

sauve_pile		ds.l 1
sauve_vbl 		ds.l 1
sauve_hbl 		ds.l 1
sauve_logique		ds.l 1
sauve_physique		ds.l 1
sauve_st_rez		ds.w 1 
sauve_falcon_rez	ds.w 1
masque      		ds.l 1
s_a7        		ds.l 1
sauve_70    		ds.l 1
sauve_120		ds.l 1
sauve_iera		ds.w 1
sauve_ierb		ds.w 1
sauve_imra		ds.w 1
sauve_imrb		ds.w 1
sauve_vr		ds.w 1
sauve_tbcr		ds.w 1
sauve_tbdr		ds.w 1


 ds.l 10000
ecran		ds.l 128000/4
buffer		ds.l 128000/4
 ds.l 10000

 end
 