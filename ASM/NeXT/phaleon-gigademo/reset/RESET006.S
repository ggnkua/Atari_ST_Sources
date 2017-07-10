* illegal
finale = 0
tempo =0
*scroll
scrvbl = 1
nb_car_gere = 100

init_disk=0
write=1

* pour les etoiles
nb_plan = 2
nb_star = 70
precision = 10
max_speed = 10
nb_vbl_pre = 1
xmin = 16
xmax = xmin+288
ymin = 0
ymax = ymin+200

*app
n_max_pt = 30000
nb_par = 120
vit_par=$800
bgt
 ifeq finale
 pea debut
 move #$26,-(sp)
 trap #14
 addq #6,sp
 clr -(sp)
 trap #1
 elseif
drive_use = ($600+12+640+4) *2
 org $5000
 jsr debut
 move #$2700,sr
 move.l $4.w,a0
 jmp (a0)
 endc

wait macro
 move d0,-(sp)
 move #\1-1,d0
.\@
 vsync
 dbra d0,.\@
 move (sp)+,d0
 endm
wait1 macro
.\@
 vsync
 dbra d0,.\@
 endm

 include strkmit6.s 
 include starrese.s
 include decrunch.s
 include app2.s

debut
 move sr,-(sp)
 move #$2700,sr
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,s_colors
 clr.b $ffff8260.w
 
 move.l #ecran+256,d0
 sf d0
 move.l d0,a6
 move.l d0,ecr
 add.l #32000,d0
 move.l d0,ecrb
 move #(64000/4)-1,d7
.cleen
 clr.l (a6)+
 dbra d7,.cleen

 bsr init_all
 move.b $fffffa07.w,s_a07
 move.b $fffffa09.w,s_a09
 move.b $fffffa13.w,s_a13
 move.b $fffffa15.w,s_a15
 move.b $fffffa17.w,s_a17
 move.b $fffffa19.w,s_a19
 move.b $fffffa1f.w,s_a1f
 move.l $70.w,s_70
 move.l $134.w,s_134
 move.l $118.w,s_118
 move.l #n70,$70.w
 move.b #$40,$fffffa17.w
 clr.b $fffffa07.w
 clr.b $fffffa09.w

********
* move.l #$31415926,$426.w
* move.l #reset_restet,$42a.w
 clr.l $426.w
 lea ($ffff8240+4*2).w,a0
 moveq #(16-4)/2-1,d7
.kj
 move.l (a1)+,(a0)+
 dbra d7,.kj
 jsr init
 move.l #animation,adr_animation
 clr scrollapp
 st starapp
 move #$2300,sr
 clr.b $ffff820a.w
 move.b #1,$ffff8260.w
 vsync
 clr.b $ffff820a.w
 clr.b $ffff8260.w
 vsync
 move.b #2,$ffff820a.w
 
.loop_vbl0
 move.l adr_animation,a2

 move.l (a2)+,a0
 cmp.l #-2,a0
 bne.s .paslogo
 move.l a2,a0
 bsr applogo
 add.l #3*4+3*2,adr_animation
 tst d7
 bmi .suite_demo
 bra.s .loop_vbl0
.paslogo

 cmp.l #-3,a0
 bne.s .pas_scroll
 move.l (a2)+,a0
 bsr scroll
 addq.l #8,adr_animation
 tst d7
 bmi .suite_demo
 bra.s .loop_vbl0
.pas_scroll

 cmp.l #-1,a0
 beq .suite_demo
 move.l (a2)+,a1

 lea ($ffff8240+4*2).w,a3
 moveq #6-1,d7
.instal_colors
 move.l (a2)+,(a3)+
 dbra d7,.instal_colors
 bsr init_par
 
.loop_vbl1
 vsync
 bsr app
 ifne tempo
 move #$500,$ffff8240.w
 dcb 25,$4e71
 move #$0,$ffff8240.w
 endc
 cmp #nb_par,d4
 beq.s .suite1
*
*
 cmp.b #$39,$fffffc02.w
 beq .suite_demo
 bra.s .loop_vbl1

.suite1
 move.l adr_animation,a0
 move 4*2+6*4(a0),d0
 wait1
 move.l #coord+2,ou_suite_par
.loop_vbl2
 vsync
 bsr appeff
 tst d7
 bmi .suite_demo
 tst d4
 bne.s .suite2
*
 cmp.b #$39,$fffffc02.w
 beq .suite_demo
 bra.s .loop_vbl2
.suite2
 wait 20
 add.l #4*2+2+6*4,adr_animation
 bra .loop_vbl0

.suite_demo
 bsr cls
 vsync
 lea ($ffff8240+4*2).w,a0
 move #$700,d0
 moveq #12-1,d7
.coul
 move d0,(a0)+
 dbra d7,.coul
 clr shift * met en minuscule par deflaut
 clr keyb
 clr nb_car
 move #$2700,sr
 move.l #n118,$118.w
 move.b #$40,$fffffa17.w
 bset #6,$fffffa15.w
 bset #6,$fffffa09.w
* bclr #6,$fffffa11.w
.find
 btst #0,$fffffc00.w
 beq.s .fint
.find1
 tst.b $fffffc02.w
 btst #4,$fffffa01.w
 beq.s .find1
 bra.s .find
.fint
 move #$2300,sr
 lea present,a0
 bsr printfont
 move.b #$12,$fffffc02.w

 lea name,a0
 bsr printfont
 lea namei,a0
 bsr input

 lea crew,a0
 bsr printfont
 lea crewi,a0
 bsr input

 lea town,a0
 bsr printfont
 lea towni,a0
 bsr input

 lea country,a0
 bsr printfont
 lea countryi,a0
 bsr input

 lea remarq,a0
 bsr printfont
 lea remarqi,a0
 bsr input

 ifeq finale
 move #1<<1,n_drive
 elseif
 move drive_use,d0
 add d0,d0
 move d0,n_drive 
 endc
.verifie_boot
 bsr boot_read
 tst d1
 bmi.s .erre
 lea buffer_disk,a0
 cmp.l #"Phal",2(a0)
 beq.s .suiy
.suiy0
 bsr cls
 lea pas_disk,a0
 bsr printfont
 bsr take_car
 bra.s .verifie_boot 
.erre
 bsr cls
 lea erreur_disk,a0
 bsr printfont
 bsr take_car
 bra.s .verifie_boot 
.suiy
 cmp #"_1",6(a0)
 bne.s .suiy0

 ifeq init_disk
.reg
 bsr disk_read
 tst d1
 beq.s .pas_erre
 bsr cls
 lea pas_disk,a0
 bsr printfont
 bsr take_car
 bra.s .reg
.pas_erre
 bsr eor_disk
 elseif
 clr.l buffer_disk
 endc
 bsr put_on_buffer
 tst d0
 beq .wrg
 bsr cls
 lea plus_place,a0
 bsr printfont
.wrg
 ifne write
 bsr eor_disk
 bsr disk_write
 tst d1
 beq.s .pas_errew
 bsr cls
 lea erreur_diskw,a0
 bsr printfont
 bsr take_car
 bsr eor_disk
 bra.s .wrg
.pas_errew
 bsr eor_disk
 endc
** maintenant le scroll !! va va eter wizzz....
* 1 : couper la $118
* ifne finale  * finale est pas encore gere
* bclr #6,$fffffa09.w
* bclr #6,$fffffa15.w
* endc
 lea coord,a0
 lea ecran,a1
 moveq #0,d0
.cl
 move.l d0,(a0)+
 cmp.l a1,a0
 blt.s .cl

 lea nb_adept,a0
 moveq #0,d0
 move buffer_disk,d0
 bsr converti_numberd

 lea coord,a2
 lea coord,a1
 lea scroll_message,a0
 bsr printbuffer

 move buffer_disk+2,d7
 beq .rien
 subq #1,d7
 lea buffer_disk+4,a6
 moveq #1,d6
.hyui
 move d7,-(sp)
 bsr prep_lines
 move (sp)+,d7
 dbra d7,.hyui
.rien
* commentaire de fin
 lea finscroll,a0
 bsr printbuffer

 lea 32*100(a2),a2
 sub.l #coord,a2
 move.l a2,d0
 divu #32,d0
 move d0,scrollmax
 bsr cls
 move.l #$6130613,couleur_scroll
 move #1,scrollval
 ifeq scrvbl-1
 move #1,scrollapp
 elseif
 move #2,scrollapp
 endc
.wat
 vsync
 move scrollmax,d0
 ifeq scrvbl-2
 add d0,d0
 endc
 cmp scrollval,d0
 bne.s .plus_wait
 move #1,scrollval
 clr scrollval
 ifeq scrvbl-1
 move #1,scrollapp
 elseif
 move #2,scrollapp
 endc
.plus_wait 
 ifeq finale
 cmp.b #$39,$fffffc02.w
 bne.s .wat
 elseif
 bra.s .wat
 endc
fin_demo
 move #$2700,sr
 move.b #$8,$fffffc02.w
 movem.l s_colors,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.b s_a07,$fffffa07.w
 move.b s_a09,$fffffa09.w
 move.b s_a13,$fffffa13.w
 move.b s_a15,$fffffa15.w
 move.b s_a17,$fffffa17.w
 move.b s_a19,$fffffa19.w
 move.b s_a1f,$fffffa1f.w
 move.l s_70,$70.w
 move.l s_134,$134.w
 move.l s_118,$118.w
 jsr fin
 move.l #$08080000,$ffff8800.w
 move.l #$09090000,$ffff8800.w
 move.l #$0a0a0000,$ffff8800.w
* move.b #$14,$fffffc02.w
 move (sp)+,sr
 rts

eor_disk
 moveq #$1c,d0
 move #(20*512)-1,d7
 lea buffer_disk,a0
.ero
 eor.b d0,(a0)+
 addq #1,d0
 dbra d7,.ero
 rts
printbuffer
.loopi
 moveq #0,d0
 move.b (a0)+,d0
 beq.s .finp
 cmp #1,d0
 bne.s .pas_saut
 lea 32*8(a2),a2
 move.l a2,a1
 bra.s .loopi
.pas_saut
 bsr converti
 bsr print_letterbuffer
 addq #1,a1
 bra.s .loopi
.finp
 rts

prep_lines
 pea (a1)
 lea linebuffer,a0
 move #34*6-1,d7
.yreh
 move.b #" ",(a0)+
 dbra d7,.yreh
 lea linebuffer,a0
 move #$0101,32(a0)
 move #$0101,34+32(a0)
 move #$0101,34*2+32(a0)
 move #$0101,34*3+32(a0)
 move #$0101,34*4+32(a0)
 move #$0101,34*5+32(a0)
 move #$0100,34*5+32+2(a0)
*
 lea linebuffer,a0
 move.b #"N",(a0)+
 move.b #".",(a0)+
 lea linebuffer+3,a0
 move.l d6,d0
 bsr converti_numberd
 lea linebuffer+9,a0
 lea name+2,a1
 bsr copy
 addq #1,a0
 move.l a6,a1
 bsr copy
 move.l a1,a6

 lea linebuffer+34+9,a0
 lea crew+2,a1
 bsr copy
 addq #1,a0
 move.l a6,a1
 bsr copy
 move.l a1,a6
 lea linebuffer+34*2+9,a0
 lea town+2,a1
 bsr copy
 addq #1,a0
 move.l a6,a1
 bsr copy
 move.l a1,a6
 lea linebuffer+34*3+9,a0
 lea country+2,a1
 bsr copy
 addq #1,a0
 move.l a6,a1
 bsr copy
 move.l a1,a6
 lea linebuffer+34*4,a0
 move.l a6,a1
 moveq #32+1-10,d0
.tyu
 subq #1,d0
 tst.b (a1)+
 bne.s .tyu
 lsr d0
 add d0,a0
 lea rem,a1
 bsr copy
 addq #1,a0
 move.l a6,a1
 bsr copy
 move.l a1,a6
**** 
 move.l (sp)+,a1
 lea linebuffer,a0
 bsr printbuffer
 addq #1,d6
 rts
copy
 move.b (a1)+,d0
 beq.s .fi
 move.b d0,(a0)+
 bra.s copy
.fi
 rts
linebuffer ds.l (34*6)/4+3
 even
*name dc.b 9,9,"Name :",0
*crew dc.b 9,11,"Crew :",0
*town dc.b 9,13,"Town :",0
*country dc.b 9,15,"Country :",0
*remarq dc.b 5,18,"Remarks about this GIGA-Demo :",0





converti_numberd
 pea (a1)
 moveq #-1,d1
 move.l a0,a1
.conv
 and.l #$ffff,d0
 addq #1,d1
 divu #10,d0
 swap d0
 move.b .val(pc,d0.w),(a1)+
 swap d0
 tst d0
 bne.s .conv
 lsr d1
.loop
 move.b (a0),d0
 move.b -(a1),(a0)+
 move.b d0,(a1)
 dbra d1,.loop
 move.l (sp)+,a1
 rts
.val dc.b "0123456789"
n118
 movem.l a0/d0,-(sp)
.yo
 btst #0,$fffffc00.w
 beq.s .pas_inscrit
 lea buffer_car,a0
 move nb_car,d0
 cmp #nb_car_gere,d0
 bge.s .pas_inscrit
 add d0,a0
 move.b $fffffc02.w,d0
 move.b d0,(a0)
 addq #1,nb_car
.pas_inscrit
 btst #4,$fffffa01.w
 beq.s .yo
 movem.l (sp)+,a0/d0
 rte
*reset_restet
* move #$2700,sr
* clr.l $426.w
* clr.l $42a.w
* clr.b $fffffa07.w
* clr.b $fffffa09.w
* move.l $0.w,a7
* move.l $4.w,a0
* jmp (a0)

n70
 movem.l d0-a6,-(sp)

 jsr routine_calcul
 addq #1,cp_vbl

 tst.b starapp
 beq .pas_star
 cmp.b #$ff,starapp
 beq .pas_couleur

 tst.b starapp
 bgt.s .positif
 move $ffff8242.w,d0
 and #$777,d0
 tst d0
 beq.s .pas_c0
 sub #$111,$ffff8242.w
.pas_c0
 move $ffff8244.w,d0
 and #$777,d0
 tst d0
 beq.s .pas_c1
 sub #$111,$ffff8244.w
.pas_c1
 move $ffff8246.w,d0
 and #$777,d0
 tst d0
 beq.s .pas_c2
 sub #$111,$ffff8246.w
 bra.s .pas_couleur
.pas_c2
 sf starapp
 bra.s .pas_couleur
.positif
 move $ffff8242.w,d0
 and #$777,d0
 cmp #$333,d0
 bge.s .pas_c0a
 add #$111,$ffff8242.w
.pas_c0a
 move $ffff8244.w,d0
 and #$777,d0
 cmp #$444,d0
 bge.s .pas_c1a
 add #$111,$ffff8244.w
.pas_c1a
 move $ffff8246.w,d0
 and #$777,d0
 cmp #$777,d0
 bge.s .pas_c2a
 add #$111,$ffff8246.w
 bra.s .pas_couleur
.pas_c2a
 st starapp
.pas_couleur
 bsr star
.pas_star

 tst scrollapp
 beq .pas_scroll
* test ds a0
 lea coord,a0
 move.l ecr,a1
 lea 8*2+4(a1),a1



 move scrollapp,d7
 ifeq scrvbl-2
 lsr d7
 endc
 cmp #200,d7
 bge.s .lii
 clr scrollval
 addq #1,scrollapp
 move #200,d6
 sub d7,d6
 mulu #160,d6
 add.l d6,a1
 bra.s .lii1
.lii
 moveq #0,d0
 move scrollval,d0
 ifeq scrvbl-2
 lsr d0
 endc
 lsl.l #5,d0
 add.l d0,a0
 addq #1,scrollval
.lii1
 subq #1,d7
.aff
x set 0
 rept 16
 move (a0)+,x(a1)
x set x+8
 endr
 lea 160(a1),a1
 dbra d7,.aff

 lea ($ffff8240+4*2).w,a0
couleur_scroll=*+2
 move.l #$5670567,d0
 rept 6
 move.l d0,(a0)+
 endr
.pas_scroll




 change_ecr
 movem.l (sp)+,d0-a6
 rte


valeur_default
 dc.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789?_.!"
valeur_espace dc.b " ",0
 even

scroll
 lea coord,a1
 move #((ecran-coord)/8)-2,d7
 moveq #0,d0
.clr
 move.l d0,(a1)+
 move.l d0,(a1)+
 dbra d7,.clr 

 lea coord,a1
 moveq #1,d7
 moveq #-1,d6
.loopl
 move.b (a0)+,d0
 beq .finl
 cmp.b #1,d0
 bne.s .pas_saut
.saut
 moveq #-1,d6
 addq #1,d7
 lea 16*2*18(a1),a1
.pas_saut
 lea valeur_default,a2
.cherchel
 move.b (a2)+,d1
 beq.s .arg
 cmp.b d1,d0
 bne.s .cherchel
 sub.l #valeur_default+1,a2
 move.l a2,d0
 bra.s .pas_arg
.arg
 moveq.l #valeur_espace-valeur_default,d0
.pas_arg 
 addq #1,d6
* on affiche ds le buffer
 lea font,a2
 lsl #5,d0
 add d0,a2
 move d6,d1
 add d1,d1
 move.l a1,a3
 add d1,a3
x set 0
 rept 16
 move (a2)+,x(a3)
x set x+16*2
 endr
 bra .loopl
.finl
 addq #5,d7
 mulu #18,d7
 move d7,scrollmax
 lea 16*18*2(a1),a1
 move #(16*2*180)/4-1,d7
.clerrrr
 clr.l (a1)+
 dbra d7,.clerrrr

 ifeq scrvbl-1
 move #1,scrollapp
 elseif
 move #2,scrollapp
 endc
 vsync
 moveq #0,d7
.wait
 wait 1
 move scrollmax,d0
 ifeq scrvbl-2
 add d0,d0
 endc
 cmp scrollval,d0
 beq.s .plus_wait
 cmp.b #$39,$fffffc02.w
 beq.s .squiz_meme
 bra.s .wait
.plus_wait
 clr scrollapp
 moveq #0,d7
 rts
.squiz_meme
 moveq #-1,d7
 clr scrollapp
 rts


printfont *a0 mess *d0:x *d1:y
 moveq #0,d0
 move.b (a0)+,d0
 moveq #0,d1
 move.b (a0)+,d1
 move.l ecr,a1
 move.l ecrb,a2
 move d1,d2
 mulu #160*10,d2
 add d2,a1
 add d2,a2
 move d0,d2
 and #$fffe,d2
 add d2,d2
 add d2,d2
 add d2,a1
 add d2,a2
 btst #0,d0
 beq.s .pas_impaire
 addq #1,a1
 addq #1,a2
.pas_impaire
.loop
 vsync
 moveq #0,d0
 move.b (a0)+,d0
 beq.s .fin_print
 cmp.b #1,d0
 bne.s .pas_saut
 move.l ecr,a1
 move.l ecrb,a2
 addq #1,d1
 move d1,d2
 mulu #160*10,d2
 add d2,a1
 add d2,a2
 bra.s .loop
.pas_saut
 bsr converti
 bsr print_letter
 move a1,d0
 btst #0,d0
 beq.s .aj0
 addq #6,a1
 addq #6,a2
.aj0
 addq #1,a1
 addq #1,a2
 bra.s .loop
.fin_print
 rts

print_letter
 pea (a0)
 lea pfont,a0
 lsl #3,d0
 add d0,a0
x set 4
 rept 8
 move.b (a0),x(a2)
 move.b (a0)+,x(a1)
x set x+160
 endr
 move.l (sp)+,a0
 rts

print_letterbuffer
 pea (a0)
 lea pfont,a0
 lsl #3,d0
 add d0,a0
x set 0
 rept 8
 move.b (a0)+,x(a1)
x set x+32
 endr
 move.l (sp)+,a0
 rts


fntc dc.b " ABCDEFGHIJKLMNOPQRSTUVWXYZ!?.,0123456789%#'",$22,"ý&î„‰‹”°± ‚…Š—ƒˆŒ“–ž´$‡():-+/*ï=abcdefghijklmnopqrstuvwxyz",0
 even
converti
 movem.l a0/d1-d2,-(sp)
 lea fntc,a0
 moveq #0,d1
.con
 move.b (a0)+,d2
 beq.s .fin_ark
 cmp.b d0,d2
 beq.s .fin
 addq #1,d1
 bra.s .con
.fin
 move d1,d0
 movem.l (sp)+,a0/d1-d2
 rts
.fin_ark
 moveq #0,d0
 movem.l (sp)+,a0/d1-d2
 rts

input
 moveq #0,d7
 move.b (a0)+,d7
 lea 2(a0),a1
 move d7,d0
 beq.s .fg
 subq #1,d0
.fg
 clr.b (a1)+
 dbra d0,.fg 
 moveq #0,d6

.loopi
 move d7,-(sp)
 bsr print_i
 bsr take_car
 move (sp)+,d7

 cmp #1,d0
 beq.s .endinput 

 cmp #2,d0
 bne.s .pas_backspace
 tst d6
 beq.s .loopi
 move.b #" ",2-1(a0,d6.w)
 bsr print_i
 subq #1,d6
 bra.s .loopi
.pas_backspace

 cmp #3,d0
 bne.s .pas_shift
 eor #1,shift
 bra.s .loopi
.pas_shift

 cmp #4,d0
 bne.s .pas_keyb
 eor #1,keyb
 bra.s .loopi
.pas_keyb

 cmp d7,d6
 beq.s .loopi
 move.b d0,2(a0,d6.w)
 addq #1,d6
 bra.s .loopi
.endinput 
 rts
print_i
 pea (a0)
 lea carin,a1
 move.b (a0)+,(a1)
 add.b d6,(a1)+
 move.b (a0)+,(a1)+
 tst d6
 beq.s .pas_sub
 move.b -1(a0,d6.w),(a1)+
 bra.s .sub
.pas_sub
 move.b (a0,d6.w),(a1)+
.sub
 clr.b (a1)+
 lea carin,a0
 bsr printfont
 move.l (sp)+,a0
 rts
cls
 move.l ecr,a0
 move.l ecrb,a1
 move #(20*200)-1,d7
 moveq #0,d0
.effs
 move.l d0,4(a0)
 move.l d0,4(a1)
 addq #8,a0
 addq #8,a1
 dbra d7,.effs
 rts

carin
 ds.l 10
 even
take_car
 tst nb_car
 beq.s take_car
 subq #1,nb_car
 lea buffer_car,a6
 move.b (a6),d0
 moveq #nb_car_gere-2,d7
.decale
 move.b 1(a6),(a6)+
 dbra d7,.decale 
 cmp.b #$2a,d0
 beq.s .suite
 cmp.b #$aa,d0
 beq.s .suite
 cmp.b #$36,d0
 beq.s .suite
 cmp.b #$b6,d0
 beq.s .suite
 btst #7,d0
 bne.s take_car
.suite
 and #$7f,d0
 tst shift
 bne .maj
 tst keyb
 bne.s .english
 move.b .conv_car(pc,d0.w),d0
 rts
.english
 move.b .conv_care(pc,d0.w),d0
 rts
.conv_car
 dc.b 0,1,"&‚",22,27,"(",0,"Š!‡…)",0,2,0,"azertyuiop",0,"$",1,0,"qsdfghjklm%"
 dc.b "-",3,0,"wxcvbn,;:=",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
.conv_care
 dc.b 0,1,"1234567890",0,0,2,0,"qwertyuiop",0,"$",1,0,"asdfghjkl,%"
 dc.b "-",3,0,"zxcvbnm;:=",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
 even
.maj
 tst keyb
 bne.s .english1
 move.b .conv_carmaj(pc,d0.w),d0
 rts
.english1
 move.b .conv_carmaje(pc,d0.w),d0
 rts
.conv_carmaj
 dc.b 0,1,"1234567890",0,0,2,0,"AZERTYUIOP",0,"$",1,0,"QSDFGHJKLM%"
 dc.b "-",3,0,"WXCVBN?./+",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
.conv_carmaje
 dc.b 0,1,"&‚",22,27,"(",0,"Š!‡…)",0,2,0,"QWERTYUIOP",0,"$",1,0,"ASDFGHJKL?%"
 dc.b "-",3,0,"ZXCVBNM./+",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
* 1 return
* 2 back space
* 3 shift ou capslock
 even
shift ds.w 1


 even
nb_car ds.w 1
buffer_car ds.b nb_car_gere
 even
 include fdcr.s
 include fdcw.s




put_on_buffer
 lea buffer_disk+2,a0
 move (a0)+,d7
* nb de personne deja insrites
 beq.s .pas_cherche_debut
 move d7,d6
 mulu #5,d6
 subq #1,d6
.cherche
 tst.b (a0)+
 bne.s .cherche
 dbra d6,.cherche
.pas_cherche_debut
 moveq #0,d0 * 0 si pas erreur 
 lea namei+3,a1
 bsr clear_and_put
 lea crewi+3,a1
 bsr clear_and_put
 lea towni+3,a1
 bsr clear_and_put
 lea countryi+3,a1
 bsr clear_and_put
 lea remarqi+3,a1
 bsr clear_and_put
 tst d1
 bne.s .pas_place
 addq #1,buffer_disk+2
.pas_place
 addq #1,buffer_disk
 rts

clear_and_put
.clear0
 move.l a1,a2
 cmp.b #" ",(a2)+
 bne.s .clear1a	
 move.l a2,a3
.clear0a
 move.b (a3)+,-2(a3)
 bne.s .clear0a
 bra.s .clear0
.clear1a
 move.l a1,a2
.clear
 tst.b (a2)+
 bne.s .clear
 subq #1,a2
.clear1
 cmp.b #" ",-(a2)
 bne.s .put
 clr.b (a2)
 bra.s .clear1
.put
 cmp.l #buffer_disk+512*20,a0
 bge.s .put1
 move.b (a1)+,(a0)+
 bne.s .put
 rts
.put1
 moveq #-1,d0
 rts

 data
* 15 car pour le nom
present
 dc.b 7,1,"Press F1 to switch between",1
 dc.b "   French keyboard / English keyboard",1
 dc.b " Shift or Capslock to switch Lcase/Ucase",1
 dc.b "  Esc, Return or Enter to validate ...",1,1
 dc.b "     If you want to put your name on",1
 dc.b "      the disk , please enter :",0
namei dc.b 15,16,9,"               ",0
name dc.b 9,9,"Name :",0
crewi dc.b 15,16,11,"               ",0
crew dc.b 9,11,"Crew :",0
towni dc.b 15,16,13,"               ",0
town dc.b 9,13,"Town :",0
countryi dc.b 16,18,15,"               ",0
country dc.b 9,15,"Country :",0
remarqi dc.b 18,11,19,"                                       ",0
remarq dc.b 5,18,"Remarks about this GIGA-Demo :",0
rem dc.b "Remarks:",0
 even
pas_disk dc.b 5,9,"Please Insert PHALEON Disk 1",1
     dc.b "         <Press a key to retry>",0
erreur_disk dc.b 13,9,"Disk Error !!",1
     dc.b "         <Press a key to retry>",0
erreur_diskw 
         dc.b 5,9,"Please insert PHALEON Disk1",1,1
        dc.b "         UNPROTECTED !!!!!",1,1
        dc.b "      <Press a key to retry>",0
plus_place dc.b 2,6,"Sorry , not enough room",1
          dc.b "   to put your name on the disk",0

scroll_message 
*dc.b "                                "
 dc.b "     Well you are number "
nb_adept dc.b "       ",1,1,1
 dc.b "  who is watching this copy of",1,1,1
 dc.b "     THE PHALEON GIGA-DEMO !",1,1,1
 dc.b "           Enjoy it !",1,1,1,1
 dc.b "   Now the names of the first",1,1,1
 dc.b "    people who have watched",1,1,1
 dc.b "             it ....",1,1,1,1,0
finscroll
*dc.b "                                "
 dc.b 1,1,1,1
 dc.b "   This demo is a Shareware !!",1,1,1
 dc.b " so, if you had fun with it ,",1,1,1
 dc.b " please send a little money to",1,1,1
 dc.b "          our address :",1,1,1,1,1
 dc.b "              NEXT",1,1,1
 dc.b "        6 rue George Sand",1,1,1
 dc.b "          49100  ANGERS",1,1,1
 dc.b "             -FRANCE-",1,1,1,1,1
 dc.b "  Instead you will deserve our",1,1,1
 dc.b "     eternal gratefulness !!",1,1,1,1
 dc.b "        You can phone MIT at",1,1,1
 dc.b "         (16)-41-43-17-84",1,1,1
 dc.b "         to contact us ....",1,1,1,1,1,1

 dc.b " If some of the screens done by",1,1,1
 dc.b "  other crews pleased you , you",1,1,1
 dc.b "can contact them at the addresses",1,1,1
 dc.b "given below and send them money",1,1,1
 dc.b "          as well ...",1,1,1,1

*dc.b "                                "
 dc.b "         AGGRESSION",1,1,1
 dc.b "         Tieranetie",1,1,1
 dc.b "           3-5A5",1,1,1
 dc.b "         04230 KERAVA",1,1,1
 dc.b "          -FINLAND-",1,1,1,1,1

 dc.b "         MYSTIC (LTK)",1,1,1
 dc.b "       KORNSTAEDT Leif",1,1,1
 dc.b "     34 Allee du Riverot",1,1,1
 dc.b "       31770 COLOMIERS",1,1,1
 dc.b "            -FRANCE-",1,1,1,1,1

 dc.b "       DNT-CREW (Reek)",1,1,1
 dc.b "        PETIT Patrick",1,1,1
 dc.b "    10 Allee de la Vanoise",1,1,1
 dc.b "    94400 VITRY sur SEINE",1,1,1
 dc.b "            -FRANCE-",1,1,1,1,1
 
*dc.b "                                "
 dc.b "          DELTA FORCE",1,1,1
 dc.b "          PLK 136681 E",1,1,1
 dc.b "        7050 WAIBLINGEN",1,1,1
 dc.b "           -GERMANY-",1,1,1,1,1

 dc.b "              ACF",1,1,1
 dc.b "         PLK 055247 C",1,1,1
 dc.b "         2120 LUNBURG",1,1,1
 dc.b "           -GERMANY-",1,1,1,1,1

 dc.b "         THE FRAGGLES",1,1,1
 dc.b "         DUCASSE Denis",1,1,1
 dc.b "       24 rue Paul Bruel",1,1,1
 dc.b "         95380 LOUVRES",1,1,1
 dc.b "           -FRANCE-",1,1,1,1,1
 

 dc.b "           LONE WOLF",1,1,1
 dc.b "         DUGAST Xavier",1,1,1
 dc.b "       2 Square Lavoisier",1,1,1
 dc.b "     78330 FONTENAY le FLEURY",1,1,1
 dc.b "            -FRANCE-",1,1,1,1,1
 
 dc.b "          TSB /Enygma",1,1,1
 dc.b "             BP 66",1,1,1
 dc.b "         59420 MOUVAUX",1,1,1
 dc.b "            -FRANCE-",1,1,1,1,1

 dc.b "              TCR",1,1,1
 dc.b "          CHANAL Cedric",1,1,1
 dc.b "     145 Avenue du Comte de Nice",1,1,1
 dc.b "         34080 MONTPELLIER",1,1,1
 dc.b "            -FRANCE-",1,1,1,1,1

 dc.b "             FOXX",1,1,1
 dc.b "        LAATSCH Marcus",1,1,1
 dc.b "         Sedan Straáe",1,1,1
 dc.b "       5D 2350 NEWMUNSTRE",1,1,1
 dc.b "           -GERMANY-",1,1,1,1,1
 
 dc.b "      NEWLINE -Ti Eytsch-",1,1,1
 dc.b "         PLK 127317 C",1,1,1
 dc.b "       W-4800 BIELEFELD",1,1,1
 dc.b "           -GERMANY-",1,1,1,1

 dc.b "    ALBEDO 0.12-CHAOTIC MOTION",1,1,1
 dc.b "       FRANCOIS Jeremie",1,1,1
 dc.b "     8 rue des Chataigniers",1,1,1
 dc.b "      49460 MONTREUIL JUIGNE",1,1,1
 dc.b "            -FRANCE-",1,1,1,1,1
 


 dc.b "    See you soon in another",1,1
 dc.b "         Dimension ...",1,1,1
 dc.b "      Press Reset to quit.",0
 even
animation
 dc.l ecr0,ecr1  * debut et fin des datas d'animations
 dc.l $03170317,$03170317,$03170317,$03170317,$03170317,$03170317
 dc 120  * temps d'attente entre la fin de l'apparition de son effacement

 dc.l -2
 dc.l nextl    * adr graphic logo
 dc.w 14,143
 dc.l nextpal * pallette logo
 dc 100 * nb de vbl d'attente

 dc.l ecr1,ecr2  * debut et fin des datas d'animations
 dc.l $00530053,$00530053,$00530053,$00530053,$00530053,$00530053
 dc 100  * temps d'attente entre la fin de l'apparition de son effacement

 dc.l ecr2,ecr3  * debut et fin des datas d'animations
 dc.l $06120612,$06120612,$06120612,$06120612,$06120612,$06120612
 dc 100  * temps d'attente entre la fin de l'apparition de son effacement

 dc.l ecr3,ecr4  * debut et fin des datas d'animations
 dc.l $06340634,$06340634,$06340634,$06340634,$06340634,$06340634
 dc 100  * temps d'attente entre la fin de l'apparition de son effacement

 dc.l -3,text0

 dc.l ecr4,ecr5  * debut et fin des datas d'animations
 dc.l $02350235,$02350235,$02350235,$02350235,$02350235,$02350235
 dc 100  * temps d'attente entre la fin de l'apparition de son effacement

 dc.l ecr5,ecrh  * debut et fin des datas d'animations
 dc.l $02620262,$02620262,$02620262,$02620262,$02620262,$02620262
 dc 100  * temps d'attente entre la fin de l'apparition de son effacement

 dc.l ecrh,fin_ecr  * debut et fin des datas d'animations
 dc.l $06240624,$06240624,$06240624,$06240624,$06240624,$06240624
 dc 100  * temps d'attente entre la fin de l'apparition de son effacement

 DC.L -3,TEXT1

 dc.l -1 * fin de boucle

nextl incbin next.dat
nextpal incbin next.pal

 even
pfont ds.b 8
 incbin pfont.dat
 even
* effets
* 0 de haut en bas
* 1 random complet
* 2 bas puis random haut
* 3  haut et bas en meme temps 1 pixels sur 2
* 4 descente en random de faible amplitude
* 5 gauche et droite en meme temps : long de precalcul
ecr0
 dc.w 0
 incbin ecr0.pak
ecr1
 dc.w 2
 incbin ecr1.pak
ecr2
 dc.w 3
 incbin ecr2.pak
ecr3
 dc.w 4
 incbin ecrg.pak
ecr4
 dc.w 2
 incbin ecr3.pak
ecr5
 dc.w 4
 incbin ecr4.pak
ecrh
 dc.w 4
 incbin ecrh.pak
fin_ecr

****************** CODERS  ***************    
text0
 dc.b 1
 dc.b "   . CODERS .  ",1,1
 dc.b "   __________  ",1,1,1,1
 dc.b "    AN COOL    ",1,1
 dc.b "     AXEL      ",1,1
 dc.b "BANANAFISHBONES",1,1
 dc.b "    BIGFOOT    ",1,1
 dc.b "     CHUCK     ",1,1
 dc.b "    DBUG II    ",1,1
 dc.b "    DJAYBEE    ",1,1
 dc.b "    EPSILON    ",1,1
 dc.b "   GWEZHENEG   ",1,1
 dc.b "   HIMALAYA    ",1,1
 dc.b "      IKI      ",1,1
 dc.b "     JACKY     ",1,1
 dc.b "     JINX      ",1,1
 dc.b "      LEM      ",1,1
 dc.b "      LTK      ",1,1
 dc.b "   MAJOR FATAL ",1,1
 dc.b "      MIT      ",1,1
 dc.b "   MOON CACTUS ",1,1
 dc.b "   MR SPIRIT   ",1,1
 dc.b "    NUCLEUS    ",1,1
 dc.b "    NULLOS     ",1,1
 dc.b "      RAY      ",1,1
 dc.b "     SAMOS     ",1,1
 dc.b "  SEVENTH SON  ",1,1
 dc.b "    SLAYER     ",1,1
 dc.b "    STERCUS    ",1,1
 dc.b "   TI EYTSCH   ",1,1
 dc.b "    VULCAN     ",1,1
 dc.b "    XOK-XOK    ",1,1
 dc.b " ZARATHOUSTRA  ",1,1
 dc.b 1,1,1,1,1
***************** GRAPISTES ***************
 dc.b "  . GFX - MEN .",1,1
 DC.B "  _____________",1,1,1,1
 dc.b "    AGENT T    ",1,1
 dc.b "    AN COOL    ",1,1
 dc.b "      ATM      ",1,1
 dc.b "    BIGFOOT    ",1,1
 dc.b "  BLACK NINJA  ",1,1
 dc.b "    BOULDOG    ",1,1
 dc.b "    CHROMIX    ",1,1
 dc.b "    DBUG II    ",1,1
 dc.b "     DEEL      ",1,1
 dc.b "    DJAYBEE    ",1,1
 dc.b "  DRAGON EYES  ",1,1
 dc.b "   FIDO DIDO   ",1,1
 dc.b "    GRIZZO     ",1,1
 dc.b "     HOOK      ",1,1
 dc.b "  JUDGE DREDD  ",1,1
 dc.b " JUMPING JACK F",1,1
 dc.b "   LANCELOT    ",1,1
 dc.b "  MOON CACTUS  ",1,1
 dc.b "   NUCLEUS     ",1,1
 dc.b "     PIPS      ",1,1
 dc.b "  PIXELKILLER  ",1,1
 dc.b "    PULSAR     ",1,1
 dc.b "     PWYLL     ",1,1
 dc.b "  QUICKSILVER  ",1,1
 dc.b "      RAY      ",1,1
 dc.b "    SKAVEN     ",1,1
 dc.b " THE INNOVATOR ",1,1
 dc.b "    VULCAN     ",1,1
 dc.b "   WILFRIED    ",1,1
 dc.b "    X MAN      ",1,1
 dc.b "   XOK-XOK     ",1,1
 dc.b " ZARATHOUSTRA  ",1,1
 
******************* MUSCIENS ****************
 DC.B 1,1,1
 DC.B " . MUSICIANS . ",1,1
 DC.B " _____________ ",1,1,1,1
 dc.b "    AN COOL    ",1,1
 dc.b "    ATOMIX     ",1,1
 dc.b "  BLACK MONKS  ",1,1
 dc.b "    CHROMIX    ",1,1
 dc.b "   COUNT ZERO  ",1,1
 dc.b "    ENEMIES    ",1,1
 dc.b "      FFT      ",1,1
 dc.b "     JEDI      ",1,1     
 dc.b "      LAP      ",1,1
 dc.b "      LTK      ",1,1
 dc.b "    MAD MAX    ",1,1
 dc.b "  NIGHTLIGHT   ",1,1
 dc.b "  NINJA TURTLE ",1,1
 dc.b "   RED SKIN    ",1,1
 dc.b "  ROMEO KNIGHT ",1,1
 dc.b "DAVID WHITTAKER",1,1
 DC.B 1,1,1,1
 DC.B 0
text1
 dc.b "   GREETINGS   ",1
 DC.B "               ",1,1,1,1
 dc.b "   LONE WOLF   ",1
 DC.B "  NO PHALEON   ",1
 DC.B " WITHOUT YOU !!",1,1
 DC.B "  DELTA FORCE  ",1,1
 DC.B "   THE UNION   ",1,1
 DC.B "     FOXX      ",1,1
 DC.B " EX-REPLICANTS ",1,1
 DC.B "EXPOSE SOFTWARE",1,1
 DC.B "      CAT      ",1,1
 DC.B "    ETIENNE    ",1
 DC.B "  YOUR STE...  ",1,1
 DC.B " ST CONNEXION  ",1,1
 DC.B " THE LOST BOYS ",1,1
 DC.B "      MCS      ",1
 DC.B "ALCOHOL IS GOOD",1
 DC.B "   FOR YOU !!  ",1,1
 DC.B "      ACF      ",1,1
 DC.B "      HMD      ",1,1
 DC.B "      ULM      ",1,1
 DC.B "    MISFITS    ",1
 DC.B "SORRY THERE WAS",1
 DC.B " NO ROOM TO PUT",1
 DC.B "  YOUR SCREEN  ",1,1
 DC.B "  AGGRESSION   ",1,1
 DC.B "  RIPPED OFF   ",1,1
 DC.B "EX-AENIGMATICA ",1,1
 DC.B "    LEGACY     ",1,1
 DC.B "  MEGABUSTERS  ",1,1
 DC.B "    ELECTRA    ",1,1
 DC.B "    MYSTIC     ",1,1
 DC.B "    NEWLINE    ",1,1
 DC.B "CHAOTIC MOTION ",1,1
 DC.B "    FASHION    ",1,1
 DC.B "    ALBEDO     ",1,1
 DC.B "    DNT CREW   ",1,1
 DC.B "      NAOS     ",1,1
 DC.B "     MCODER    ",1,1
 DC.B "    NEWLINE    ",1,1
 DC.B "   NEW SYSTEM  ",1,1
 DC.B "      TCR      ",1,1
 DC.B "      TSB      ",1,1
 DC.B "    MJJ PROD   ",1,1
 DC.B "   FIREHAWKS   ",1,1
 DC.B "  NIGHT FORCE  ",1,1
 DC.B "  DYNAMIC DUO  ",1,1
 DC.B "      TNC      ",1,1
 DC.B "    HYSTERIA   ",1,1
 DC.B "      ICS      ",1,1
 DC.B "ALLIANCEGERMANY",1,1
 DC.B "      TEX      ",1,1
 DC.B "THE BUSHWACKERS",1,1
 DC.B "      OVR      ",1,1
 DC.B "      TRB      ",1,1
 DC.B "      TCB      ",1,1
 DC.B "  ART OF CODE  ",1,1
 DC.B "      SYNC     ",1,1
 DC.B "     OMEGA     ",1,1
 DC.B "    EQUINOX    ",1,1
 DC.B "   MAD VISION  ",1,1
 DC.B "  POLTERGEIST  ",1,1
 DC.B "    PHALANX    ",1,1
 DC.B "     VECTOR    ",1,1
 DC.B "      ZUUL     ",1,1
 DC.B "      TRIO     ",1,1
 DC.B "   BLACK CATS  ",1,1
 DC.B "    DEFCON 4   ",1,1
 DC.B " EX-PENDRAGONS ",1,1
 dc.b "  INNER CIRCLE ",1,1
 DC.B "   AUTOMATION  ",1,1
 DC.B "    SUPERIOR   ",1,1
 DC.B "      VMAX     ",1,1
 DC.B "   FUNVISION   ",1,1
 DC.B "    OXYGENE    ",1,1
 DC.B "  RESPECTABLES ",1,1
 DC.B "      BMT      ",1,1
 DC.B "   VEGETABLES  ",1,1
 DC.B "     UNDEAD    ",1,1
 DC.B "  CYBERNETICS  ",1,1
 DC.B "   ALCOHOLICA  ",1,1
 dc.b 1,1,1
 dc.b "NO GREETINGS TO",1,1
 dc.b "   - FUZION -  ",1,1
 DC.B 1,1,0
 
 
 
  even

font incbin font.dat
 section bss
s_colors ds.l 8
ecr ds.l 1
ecrb ds.l 1
var_random ds.l 1

* etoiles (starfield)
starapp ds.w 1
adr_animation ds.l 1
eras_buf1 ds.l 1
eras_buf2 ds.l 1
eras ds.l nb_star*2
buffer_star ds.l 6*nb_star
merde ds.l 2
tablex ds.w precision*(320+2*max_speed)
tabley ds.w precision*(200+2*max_speed)
buffer_disk ds.l (512*20)/4
* evid
cp_vbl ds.w 1
s_70 ds.l 1
s_134 ds.l 1
s_118 ds.l 1
s_a07 ds.b 1
s_a09 ds.b 1
s_a13 ds.b 1
s_a15 ds.b 1
s_a17 ds.b 1
s_a19 ds.b 1
s_a1f ds.b 1
 even

* scroll
scrollapp ds.w 1
scrollval ds.w 1
scrollmax ds.w 1

n_drive ds.w 1
* logo
ou_suite_par ds.l 1
table_t ds.w nb_par*3
teclat ds.w (nb_par*3)*2
eclat ds.l 1
eclat1 ds.l 1
keyb ds.w 1
* a ne pas separer
coord ds.l n_max_pt
coord_depack ds.l 2000
 ds.l (70000)/4
ecran ds.l ((32000*2)+256)/4