bgt
 opt p+,w+,o-
 move #0,d0
 lea type_loader(pc),a0
 move d0,(a0)
unit = 1 * unite de depart normalement au boot drive A
finale1 = 1
* 1 = A  ; 2 : B

prg = $5000
adr_charge_loader = $80000-220000
adr_charge_decruncher = $80000-65000
adr_charge_change = $5000

adr_h_decruncher= $f3800
adr_h_loader    = $f3800+(20)*512  * t_loader = 80*512
adr_h_dungeon   = $80000

xp = $600 * 4
yp = ($600+4) * 4
di = ($600+4+4) * 4
map_connue = ($600+12) * 640

hauteur_flacon =($600+12+640) * 2
nb_drive = ($600+12+640+2) *2
drive_use = ($600+12+640+4) *2
flag_ste = ($600+12+640+6) *2
flag_zik = ($600+12+640+8) *2
x_monstre  = ($600+12+640+10) *2
y_monstre  = ($600+12+640+12) *2
d_monstre  = ($600+12+640+14) *2
flag_cheat = ($600+12+640+16) *2
type_clavier=($600+12+640+18) *2

eora macro
 move.l a0,-(sp)
 lea \2(pc),a0
 eor \1,(a0)
 move.l (sp)+,a0
 endm

clear macro
 lea \1(pc),a0
 clr (a0)
 endm
 
print macro
 move.l a0,-(sp)
 bsr intall_ecr
 move.l (sp)+,a0
 lea \1(pc),a0
 bsr print_line
 endm

print1 macro
 lea \1,a0
 bsr print_line
 endm

wait_key macro
.\@
 stop #$2300
 stop #$2300
 move.b $fffffc00.w,d0
 btst #0,d0
 bne.s .\@@
 btst #5,d0
 beq.s .\@
.\@@
 move.b $fffffc02.w,d0
 btst #7,d0
 beq.s .\@
 bclr #7,d0
 and #$ff,d0
 lea table_car(pc),a0
 add d0,a0
 move.b (a0),d0
 endm

supexec macro
  pea \1(pc)
  move #$26,-(sp)
  trap #14
  addq #6,sp
  endm

maj macro
 cmp.b #"a",d0
 blt.s .\@
 cmp.b #"z",d0
 bgt.s .\@
 sub.b #"a"-"A",d0
.\@
 endm
  
bgt1
 ifeq finale1
 pea mess(pc)
 move #9,-(sp)
 trap #1
 addq #6,sp
 move #7,-(sp)
 trap #1
 addq #2,sp
 supexec debut_executeur
 clr -(sp)
 trap #1
mess dc.b 10,13,10,13,10,13,"    INSERER PHALEON DISK 1",10,13,10,13,"       & PRESS A KEY .....",0
 even
debut_executeur

 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,adr_ecr
 endc
 move $4a6.w,nb_drive
 
 lea xcoord(pc),a0
 clr (a0)
 lea ycoord(pc),a0
 clr (a0)

********************** attention ici tout change , car
********************** si l'on est en mode disk acces direct
********************** on va se retrouver reloge en $1000 !!
 move #$2700,sr
 move.l #"YOYO",adr_h_dungeon
 move.l #"YOYO",adr_h_decruncher
 move.l #"YOYO",adr_h_loader
 move.l #"YOYO",adr_h_dungeon+4
 move.l #"YOYO",adr_h_decruncher+4
 move.l #"YOYO",adr_h_loader+4
* a supprimer en le mettant sur disk
 move #unit,drive_use

 clr.b $fffffa07.w
 clr.b $fffffa09.w
 lea rte(pc),a0
 move.l a0,$70.w
 move #$2300,sr
 move.b #2,$ffff820a.w
 move.b #1,$ffff8260.w
 stop #$2300
 clr.b $ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w

 move #$2700,sr
* voi si c'est un 1040
 move.l #"1040",$80000
 move.l $80000,d0
 cmp.l #"1040",d0
 bne.s .pas_1040

 lea ordre_decruncher(pc),a0
 move #$4e71,(a0)
 lea ordre_loader(pc),a0
 move #$4e71,(a0)
 lea .instruc_1040(pc),a0
 move #$4e71,(a0)

 lea .ordre_dungeon(pc),a0
 move #$4e71,(a0)
.pas_1040 
*recopie valeur dungeon
 movem .dungeon_disk(pc),d0-d3
 lea .real_dungeon(pc),a0
 movem d0-d3,(a0)


 lea .pas_change_context0(pc),a0
 lea $1000.w,a1
 move.l #finprg-.pas_change_context0,d0
.copy0
 move.l (a0)+,(a1)+
 subq.l #4,d0
 tst.l d0
 bpl.s .copy0
 move #$2300,sr



********* test si ste
 clr flag_ste
 lea $ffff820d.w,a0
 move.b #$2e,(a0)
 cmpi.b #$2e,(a0)
 bne.s .pas_ste
 move.b #$7a,(a0)
 cmpi.b #$7a,(a0)
 bne.s .pas_ste
 clr.b (a0)
 st flag_ste
 st flag_zik
 bra.s .ste
.pas_ste
 clr flag_zik
.ste
************************


 move.w #16,x_monstre   * Dans la salle aux faux murs    disk 3
 move.w #09,y_monstre
 move.w #01,d_monstre
 clr.b flag_cheat
 move.b #1,type_clavier
 move.l #0,di
 move.l #31,xp
 move.l #39,yp
 lea map_connue,a0
 move #(8*20)-1,d7
.loiklkoi
 clr.l (a0)+
 dbra d7,.loiklkoi
 move #4,hauteur_flacon * initalise hauteur_flacon pour le decruncher
* installe reset
 move.l #$31415926,$426.w
 move.l #$1000,$42a.w
*
 jmp $1004.w

.copy1
 bra.s .suite
.dungeon_disk
 dc 0414,0032,0003,0
.suite
.pas_change_context0
 bra.s .reset
 bra.s .retour
 bra .load_menu
.reset
 move #$2700,sr
 lea $5000.w,a7
 bsr color
 reset
 reset
 move.b #2,$ffff820a.w
 bsr reinst
 bsr cls
 lea $5000,a7
 bsr choc
 bsr efface_merde
 moveq #0,d0
 bsr change_disk
 lea numero_screen(pc),a0
 move #-2,(a0)
 lea test_retour(pc),a0
 move #-1,(a0)
 movem .reslof(pc),d0-d3
 bra .loaudu
.reslof
 dc 0197,0012,0006,0
.retour
* la c le retour du menu
 lea numero_screen(pc),a0
 move d0,(a0)
 lea $5000.w,a7
 bsr color
 bsr choc
 bra .suiter
.load_menu
 move #$2700,sr
 lea $5000.w,a7
 bsr color
 reset
 reset
 move.b #2,$ffff820a.w
 bsr reinst
 bsr cls
 lea $5000,a7
 bsr choc
 bsr efface_merde
.ordre_dungeon
 bra.s .dungeon_520

 cmp.l #$46fc2700,adr_h_dungeon
 beq.s .dungeon_deja_present
 bsr .load_dungeon
 lea $5000.w,a7
 bsr decruncher
 move.l taille(pc),d7
 lea taille_dungeon(pc),a0
 move.l d7,(a0)
 lsr.l #4,d7
 lea adr_h_dungeon,a0
 lea $5000.w,a1
.loopi1
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 dbra d7,.loopi1
 bra fin_jump_5000
.dungeon_deja_present

 lea adr_h_dungeon,a1
 lea $5000.w,a0
 move.l taille_dungeon(pc),d7
 lsr.l #4,d7
.loopi2
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 dbra d7,.loopi2
 bra fin_jump_5000

.dungeon_520
 bsr .load_dungeon
 lea $5000.w,a7
 bsr decruncher
 bra fin_jump_5000

.load_dungeon
 lea retour_load_dungeon(pc),a0
 move.l (sp)+,(a0)

 moveq #0,d0
 bsr change_disk

 bsr cls
 movem .real_dungeon(pc),d0-d3
 move drive_use,d4
 add d4,d4
 or d4,d3
 lea numero_screen(pc),a0
 move #-1,(a0)
 bsr loader
retour_load_dungeon=*+2
 jmp $78945612
.real_dungeon
 dcb.w 4,$9654
.suiter
 move #$2700,sr
 reset
 reset
 move.b #2,$ffff820a.w
 bsr reinst
 bsr cls
 lea $5000.w,a7

 bsr efface_merde

 lea numero_screen(pc),a0
 moveq #0,d0
 move (a0),d0
 lea .map_work(pc),a1
 add d0,d0
 add d0,a1
 move (a1),d0
 tst.b d0
 beq.s .pas_ste_ecr
 tst.b flag_ste
 bne .pas_ste_ecr
.ermde
 bsr reinst
 bsr cls
 print .pas_machine
 move.l #$777,$ffff8240.w
 move #$2300,sr
 move #100,d7
.lopi
 stop #$2300
 dbra d7,.lopi
 clr.l $ffff8240.w
 jmp $1004.w
.pas_ste_ecr
 lsr #8,d0
 tst.b d0
 beq .pas_1040_ecr
.instruc_1040
 bra.s .ermde
 bra .pas_1040_ecr
.pas_machine dc.b 10,10,10,10,10,10,10,10,10,"     Sorry this screen doesn't work ",10,"           on your computer !!!",0
 even
.map_work
* 1040?,ste?
 dc.b 0,0 *acf
 dc.b 0,0 *agression
 dc.b 0,0 *chaotic1
 dc.b 0,0 *chaotic2
 dc.b 0,0 *deltaforce
 dc.b 0,0 *futur minds
 dc.b 0,0 *fraggles
 dc.b 0,0 *hmd
 dc.b 0,0 *legacy
 dc.b 0,0 *megabusters
 dc.b 0,0 *mjj_prod
 dc.b 0,0 *mystic
 dc.b 0,0 *naos
 dc.b 0,0 *newline
 dc.b 0,0 *nsm
 dc.b 0,0 *tcb
 dc.b 0,0 *tcr
 dc.b 0,1 *tsb
 
 dc.b 1,0 *aenogmat
 dc.b 0,0 *chaotic 3
 dc.b 0,0 *dnt_crerw
 dc.b 0,0 *firehawks
 dc.b 1,0 *foxx
 dc.b 0,0 *fullball
 dc.b 0,0 *krom
 dc.b 0,0 *lem
 dc.b 0,0 *night_force
 dc.b 0,0 *tnc1

 dc.b 0,0 *expose
 dc.b 0,0 *budnext
 dc.b 0,0 *mine
 dc.b 0,0 * tnc 2
 dc.b 0,1 *illusion
 dc.b 0,0 *lamer test
.pas_1040_ecr

 moveq #1,d0
 lea numero_screen(pc),a0
 cmp #16,(a0)
 ble.s .disk2
 moveq #2,d0
 cmp #27,(a0)
 ble.s .disk2
 moveq #3,d0
 cmp #32,(a0)
 ble.s .disk2
 moveq #0,d0
.disk2

 bsr change_disk

 bsr cls

 move #$2300,sr

 bsr cls

 lea test_retour(pc),a0
 clr (a0)
 move numero_screen(pc),d0
 lsl #3,d0
 lea disk2(pc),a0
 add d0,a0
 movem (a0),d0-d3
.loaudu
 move drive_use,d4
 add d4,d4
 or d4,d3

 lea n_scr(pc),a0
 move d0,(a0)
 bsr loader

 move #$2700,sr
n_scr = *+2
 move #$6545,d0
 and.l #$ffff,d0
 lea prg,a0
 move.l (a0)+,d1
 mulu #(512/4),d0
 move.l d0,d7
 subq.l #1,d7

 moveq #0,d0
.poiu
 add.l (a0)+,d0
 subq.l #1,d7
 bne.s .poiu

 and.l #$3fffffff,d0
 move.l d1,d2
 and.l #$3fffffff,d1
 cmp.l d0,d1
 beq.s .suito
 move #$2700,sr
 lea $5000.w,a7
 jmp $1004.w
.suito
 swap d2
 moveq #15,d0
 btst d0,d2
 beq.s .pas_decrunch
 lea $5000.w,a7
 bsr decruncher
.pas_decrunch

 move #$2700,sr
 lea prg,a0
taille = *+2
 add.l #$99999999,a0
 lea (8+6)*4(a0),a0
 lea taille1(pc),a1
 move.l a0,(a1)
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 move.l d0,a1
 move.l d0,a2
 move.l d0,a3
 move.l d0,a4
 move.l d0,a5
 move.l d0,a6
 lea $80000,a0
.cleen
 movem.l d0-d7/a1-a6,-(a0)
taille1=*+2
 cmp.l #$78894565,a0
 bgt.s .cleen
 
 lea test_retour(pc),a0
 tst (a0)
 bne fin_jump_5000
 lea prg,a0
.p
 cmp #"NE",(A0)+
 bne.s .p
 cmp.l #"XTBA",(a0)
 bne.s .p
 cmp #"CK",4(a0)
 bne.s .p
 subq #2,a0
 move.l #$4ef81004,(a0)+
 move.l #$4e714e71,(a0)+
 bra fin_jump_5000

trap1
 movem.l d1-a6,-(sp)

 cmp #$20,6+14*4(sp)
 bne.s .pas_super_viseur
 move.l a7,d0
 bra.s fin_trap
.pas_super_viseur

 bra.s fin_trap


trap14
 movem.l d1-a6,-(sp)
 cmp #$11,6+14*4(sp)
 bne.s pas_random
 tst.l $eb0.w
 bne.s .lab0
 move.l $4ba.w,d0
 moveq #16,d1
 asl.l d1,d0
 or.l $4ba.w,d0
 move.l d0,$eb0.w
.lab0

 moveq #0,d2
 move.l $eb0.w,d7
 move.l #$44bf19d3,d6
 tst.l d7
 bge.s .lab1
 neg.l d7
 moveq #1,d2
.lab1
 move d7,d0
 mulu d6,d0
 move.l d0,d5
 swap d7
 move d7,d0
 swap d7
 mulu d6,d0
 swap d6
 move d6,d1
 mulu d7,d1
 add d1,d0
 swap d5
 add d0,d5
 swap d5
 move.l d5,d0
 tst d2
 bne.s .lab2
 neg.l d2
.lab2
 addq.l #1,d0
 move.l d0,$eb0.w
 asr.l #8,d0
 and.l #$ffffff,d0 
fin_trap
 movem.l (sp)+,d1-a6
rte
 rte
pas_random
 cmp #5,6+14*4(sp)
 bne.s .pas_set_screen
 move.l 6+2+4+14*4(sp),d0
 lea $ffff8201.w,a0
 lsr.l #8,d0
 movep d0,(a0)
 moveq #0,d0
 bra fin_trap
.pas_set_screen
 
 cmp #$26,6+14*4(sp)
 bne.s .passupexec
 move.l 6+2+14*4(sp),a0
 jsr (a0)
 bra fin_trap
.passupexec
 
 bra fin_trap
fin_copy

color
 lea $ffff8240.w,a0
 moveq #7,d0
.color
 clr.l (a0)+
 dbra d0,.color
 rts

efface_merde
 movem.l d0-a0,-(sp)
** efface merde
 lea prg,a0
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
.lou0
 movem.l d0-d7,(a0)
 lea 8*4(a0),a0
 cmp.l #$78000,a0
 blt.s .lou0
 movem.l (sp)+,d0-a0
 rts

reinst
 move.b #$3,$fffffc00.w
 move.b #$96,$fffffc00.w
.lop
 tst.b $fffffc02.w
 btst #4,$fffffa01.w
 beq.s .lop
 btst #0,$fffffc00.w
 bne.s .lop
 move.b #$12,$fffffc02.w

 tst.b flag_ste
 beq.s .pas_ste_regle
 move #$7ff,$ffff8924.w
 move #1256,d0  ; Master
 bsr .teste_masque
 move #1364,d0  ; V Gauche 
 bsr .teste_masque
 move #1300,d0  ; V Droit
 bsr .teste_masque
 move #1152+6,d0  ; Aigues
 bsr .teste_masque
 move #1088+6,d0  ; Basses
 bsr .teste_masque
 move #1025,d0  ; Mixage
 bsr .teste_masque
.pas_ste_regle
 bra.s .suity
.teste_masque 
 cmp.w #$7ff,$ffff8924.w
 bne .teste_masque
 move.w d0,$ffff8922.w
 rts
.suity

 lea rte(pc),a0
 move.l a0,$70.w
 move.l #$08080000,$ffff8800.w
 move.l #$09090000,$ffff8800.w
 move.l #$0a0a0000,$ffff8800.w
 move.l #$0707ffff,$ffff8800.w
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 st $fffffa13.w
 st $fffffa15.w
 move.b #$40,$fffffa17.w
 lea rte(pc),a0
 move.l a0,$70.w

 lea $ffff8800.w,a6
 moveq #0,d3
 bsr drive
 bsr cls
 rts

choc
 stop #$2300
 clr.b $ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 stop #$2300
 clr.b $ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 rts


intall_ecr
 lea adr_ecr(pc),a0
 move.l #$78000,d0
 move.l d0,(a0)
 lea $ffff8201.w,a0
 lsr.l #8,d0
 movep d0,(a0)
 rts

cls
 bsr intall_ecr
cls1
 lea fnt(pc),a0
 lea adr_car(pc),a1
 move.l a0,(a1)
 clear xcoord
 clear ycoord
 move #3999,d6
 move.l adr_ecr(pc),a0
 moveq #0,d0
.cls
 move.l d0,(a0)+
 move.l d0,(a0)+
 dbra d6,.cls
 rts
fnt incbin tosfnt.dat
 even 
print_line
adr_car = *+2
 move.l #$87492345,a1
adr_ecr = *+2
 move.l #$87459621,a2
 move ycoord(pc),d7
 move d7,d6
 mulu #160*8,d6
 add d6,a2
 move xcoord(pc),d1

.boucle
 moveq #0,d0
 move.b (a0)+,d0
 beq .fin_print

 cmp #10,d0
 bne.s .pas_return
 addq #1,d7
 cmp #25,d7
 blt.s .pas_return0
 subq #1,d7
 move.l adr_ecr(pc),a3
 lea 160*8(a3),a4
 move #3840-1,d6
.loppp
 move.l (a4)+,(a3)+
 move.l (a4)+,(a3)+
 dbra d6,.loppp
 moveq #0,d0
 move #159,d6
.loppp1
 move.l d0,(a3)+
 move.l d0,(a3)+
 dbra d6,.loppp1
.pas_return0
 move.l adr_ecr(pc),a2
 move d7,d6
 mulu #160*8,d6
 add d6,a2
 moveq #0,d1
 bra .boucle
.pas_return

 lea 0(a1,d0.w),a3
 lea 0(a2,d1.w),a4
 moveq #7,d6
.print_cr
 move.b (a3),(a4)
 lea 256(a3),a3
 lea 160(a4),a4
 dbra d6,.print_cr

 btst #0,d1
 beq.s .add0 
 addq #6,d1
.add0
 addq #1,d1
 bra .boucle 
.fin_print
 lea ycoord(pc),a1
 move d7,(a1)
 lea xcoord(pc),a1
 move d1,(a1)
 rts


change_disk
 lea choix_drive(pc),a0
 move d0,(a0)

 lea change(pc),a1
 lea fin_change(pc),a2
 lea adr_charge_change,a0
.loopi
 move.l (a1)+,(a0)+
 cmp.l a2,a1
 blt.s .loopi

 lea adr_charge_change,a0
 bsr depack
 bsr cls
choix_drive = *+2
 move #$7896,d0
 jsr adr_charge_change
 rts


loader
 lea adr_retour(pc),a0
 move.l (sp)+,(a0)

 lea type_loader(pc),a0
 tst (a0)
 bne.s .okay_boin
 movem.l d0-a6,-(sp)
 print .loading
 bsr dega
 movem.l (sp)+,d0-a6
 lea prg,a0
 bsr load_from_disk
 bsr degb
 bra retour_loader
.loading dc.b 10,10,10,10,10,10,10,10,10,10,"               LOADING !!",0
 even
.okay_boin


* donne ds d0-d3 charge tt en $5000
 movem d0-d3,-(sp)

ordre_loader
 bra.s .load_loader

* verifie si loader , change et decrunch tjrs en haut de memoire
 bsr verifie_haut

 lea adr_h_loader,a1
 lea adr_charge_loader,a0
 move #((512*80)/4),d7
.loopi
 move.l (a1)+,(a0)+
 dbra d7,.loopi
 bra.s .depack_loader
.load_loader
 lea adr_charge_loader,a0
 moveq #80,d0
 moveq #74,d1
 moveq #1,d2
 moveq #1,d3
 move drive_use,d4
 add d4,d4
 or d4,d3
 bsr load_from_disk
.depack_loader

 lea adr_charge_loader,a0
 bsr depack

 movem (sp)+,d0-d3

 movem d0-d3,adr_charge_loader+4
numero_screen = *+2
 move #$7894,adr_charge_loader+2
 addq #3,adr_charge_loader+2

 bsr cls
 bsr choc

 moveq #0,d7
 lea adr_charge_loader,a7
 jsr adr_charge_loader
retour_loader
adr_retour = *+2
 jmp $78946230



verifie_haut
 lea adr_h_decruncher+4,a0
 move.l #(100*512/4)-1,d7
 moveq #0,d0
.ver
 add.l (a0)+,d0
 subq.l #1,d7
 bne.s .ver
 move.l adr_h_decruncher,d1
 beq.s .pas_okay
 cmp.l d0,d1
 beq.s .okay
.pas_okay
 lea adr_h_decruncher,a0
 moveq #20+80,d0
 moveq #72,d1
 moveq #1,d2
 moveq #1,d3
 move drive_use,d4
 add d4,d4
 or d4,d3
 bsr load_from_disk

.okay
 rts

dega
 moveq #6,d0
.dega
 stop #$2300
 stop #$2300
 add #$111,$ffff8242.w
 dbra d0,.dega
 rts

degb
 moveq #6,d0
.degb
 stop #$2300
 stop #$2300
 sub #$111,$ffff8242.w
 dbra d0,.degb
 rts


decruncher
 lea adr_retour1(pc),a0
 move.l (sp)+,(a0)

 lea type_loader(pc),a0
 tst (a0)
 bne.s .okay_boin
 bsr cls1
 print .decrunch
 bsr dega
 lea prg,a0
 bsr depack
 bsr degb
 bra retour_decruncher
.decrunch dc.b 10,10,10,10,10,10,10,10,10,10,"             DECRUNCHING !!",0
 even
.okay_boin


ordre_decruncher
 bra.s .load_decruncher

*verfie si tt est en haut de memoire
 bsr verifie_haut

 lea adr_h_decruncher,a1
 lea adr_charge_decruncher,a0
 move #((512*20)/4),d7
.loopi1
 move.l (a1)+,(a0)+
 dbra d7,.loopi1
 bra.s .depack_decruncher
.load_decruncher
 lea adr_charge_decruncher,a0
 moveq #20,d0
 moveq #72,d1
 moveq #1,d2
 moveq #1,d3
 move drive_use,d4
 add d4,d4
 or d4,d3
 bsr load_from_disk
.depack_decruncher

 lea adr_charge_decruncher,a0
 bsr depack
 lea taille(pc),a0
 jsr adr_charge_decruncher

retour_decruncher
adr_retour1 = *+2
 jmp $78946230
 

fin_jump_5000
 move #$2700,sr
 bsr reinst
 lea rte(pc),a0
 move.l a0,$60.w
 move.l a0,$64.w
 move.l a0,$68.w
 move.l a0,$6c.w
 move.l a0,$70.w
 move.l a0,$74.w
 move.l a0,$78.w
 move.l a0,$7c.w
*
 move.l a0,$8.w
 move.l a0,$c.w
 move.l a0,$10.w
 move.l a0,$14.w
 move.l a0,$1c.w
 move.l a0,$20.w
 move.l a0,$28.w
 move.l a0,$2c.w
*
 lea $100.w,a1
 moveq #15,d7
.oui
 move.l a0,(a1)+
 dbra d7,.oui
 lea $80.w,a1
 moveq #15,d7
.cv
 move.l a0,(a1)+
 dbra d7,.cv
 lea trap14(pc),a0
 move.l a0,$b8.w
 lea trap1(pc),a0
 move.l a0,$84.w
 lea $5000,a7
 bsr cls
 
 move #$2300,sr
 move.b #0,$ffff8260.w
 stop #$2300
 clr.b $ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 stop #$2300
 stop #$2300
 stop #$2300
 move.b #$11,$fffffc02.w
 stop #$2300
 stop #$2300
 move.b #$16,$fffffc02.w
 stop #$2300
 stop #$2300
 move.b $fffffc02.w,d0
 stop #$2300
 stop #$2300
 move.b $fffffc02.w,d0
 move.b #$12,$fffffc02.w
 stop #$2300
 jmp $5000.w
 
 include fdc???1.s

 include decrunch.s
 even

data
change incbin change.pak
fin_change
 even

insert dc.b "Insert data disk in Unit A or B , then press A or B.",0
 even

table_car
 dc.b "  1234567890)-  azertyuiop^$  qsdfghjklm—` #wxcvbn,;:=               " * jusqu'a f10
 dc.b "     -   +                 <  ()/*7894561230.                        "
 even

disk2
 include disk2.s
 include disk3.s
 include disk4.s
 dc 0115,0012,0003,1
 even
taille_dungeon ds.l 1
test_retour ds.w 1
type_loader ds.w 1
ycoord ds.w 1
xcoord ds.w 1
finprg
