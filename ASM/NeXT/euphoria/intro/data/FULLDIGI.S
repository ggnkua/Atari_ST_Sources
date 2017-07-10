taille_mesure=32
vitesse=6
music
 movem.l a0-a4/d0-d3,-(sp)
* bon je vais utiliser un minimum de registre , en autre :
*  a0 \ vaccants
*  a1 /
*  a2 : ffff8800 ne plus toucher } seulemnt si vas a soundengine
*  a3 : ffff8802 ne plus toucher } sinon libre
 lea $ffff8800.w,a2
 lea $ffff8802.w,a3 

 lea dec_sam(pc),a0
 subq.b #1,(a0)
 bne.s vbl2
 move.b #1,(a0)
 lea ech_nul(pc),a0
 move.l a0,usp
vbl2
 lea compteur_vitesse(pc),a0
 subq #1,(a0)
 bne soundengine
 bsr read_note
 movem.l (sp)+,a0-a4/d0-d3
 rts

init_read_note 
 lea position_pattern(pc),a6
 move.w num_pattern_debut_music,(a6)
read_note
 lea position_pattern(pc),a1
 lea infos_voies(pc),a0
*
 move voie_2+pos_sequence(a0),d0
 cmpi #taille_mesure,d0
 bne.s .mesure_pas_fini
*
 move.w num_pattern_fin_music(pc),d0
 cmp (a1),d0
 bne.s .pas_fin_music
 move num_pattern_debut_music(pc),(a1)
 bra.s .saute_ajout
.pas_fin_music
 addq #1,(a1)
.saute_ajout
 clr pos_sequence(a0)
 clr pos_sequence+voie_2(a0)
 clr pos_sequence+voie_3(a0)


*************************************************
.mesure_pas_fini
 moveq #0,d7

 move (a1),d7
 lea partition_pattern(pc),a1
 mulu #12,d7  * chaque pattern fait 12 octets
 adda d7,a1

 moveq #3-1,d7
superloop
 move.b (a1)+,seq(a0)
 move.b (a1)+,transposition(a0)
 move.b (a1)+,nul6(a0)
 move.b (a1)+,d1 * ??


 moveq #0,d1
 move.b seq(a0),d1
 mulu #taille_mesure,d1
 lea mesure(pc),a2
 add d1,a2
 add pos_sequence(a0),a2
 move.l a2,sequence(a0)
 move.l a2,a3
 
 moveq #0,d0
 move.b 1(a2),son(a0)
 beq.s .pas_de_son
 move.b nul6(a0),d0
 add.b d0,son(a0)


***************************** gestion des sons ******
.pas_de_son 

 move.b son(a0),d0
 bne.s z1

 tst.b flag_son(a0)
 bne.s r1

z1
 lea table_offset_adr_son(pc),a2
 and #$ff,d0
 add d0,d0
 add d0,a2
 move.w (a2),offset_adr_son(a0)
 move.b #1,flag_son(a0)
r1 
 
*****************************


 moveq #0,d0
 move.b (a3),d0
 beq.s fin_gestion_voie

 add.b transposition(a0),d0
 move.b d0,note(a0)
 
 lea frequence(pc),a2
 add d0,d0
 add d0,a2
 move.w (a2),frequenc(a0)

fin_gestion_voie
 addq.w #2,pos_sequence(a0) * on passe a la voie suivante
 lea taille_info(a0),a0

 dbra d7,superloop

 lea compteur_vitesse(pc),a6 *reinitialise la vitesse
 move.w #vitesse,(a6)
 rts





soundengine
 lea infos_voies(pc),a1
 tst.b flag_son(a1)
 beq.s .pas_effet_voie_1
 moveq #0,d2
 bsr gere_effet
.pas_effet_voie_1

 lea infos_voies+voie_2(pc),a1
 tst.b flag_son(a1)
 beq.s .pas_effet_voie_2
 moveq #1,d2
 bsr gere_effet
.pas_effet_voie_2

 lea infos_voies+voie_3(pc),a1
 tst.b flag_son(a1)
 beq.s .pas_effet_voie_3
 moveq #2,d2
 bsr gere_effet
.pas_effet_voie_3

 lea registre(pc),a0
 movem.l (a0)+,d0-d3
 movep.l d0,(a2)
 movep.l d1,(a2)
 movep.l d2,(a2)
 movep.l d3,(a2)
 movem.l (sp)+,a0-a4/d0-d3
 rts


drum 
 move.l a0,-(sp)
 move.l usp,a0
 move.b #9,$ffff8800.w
 move.b (a0)+,$ffff8802.w
 move.l a0,usp
 move.l (sp)+,a0
fdrum
 rte

save_instore
 move.b #7,$ffff8800.w
 move.b $ffff8800.w,(a0)+
 lea   drum(pc),a1
 move.l a1,$134.w 
 move.l  #$707ffff,$ffff8840.w
 move.l usp,a0
 move.l a0,s_usp
 rts 

restore
 move.l #$08080000,$ffff8800.w
 move.l #$09090000,$ffff8800.w
 move.l #$0a0a0000,$ffff8800.w
 rts 

* recapitulatif , commande du son :
*2* $f0: volume (1)
*2* $f1: fixe le poid faible de la periode
*      de l'envelloppe , met le poid fort
*       a 0. met volume au maximum
*2* $f2: fixe la frequence du generateur de bruit
*2* $f6: boucle ds le son 


gere_effet
 lea table_offset_adr_son(pc),a0
 add offset_adr_son(a1),a0        * a0: adr du son

effet_boucle
 cmp.b #-1,(a0)   * fin son?
 beq ret_force1

 cmpi.b #$f0,(a0)  * volume
 bne.s .pas_volume
 moveq #8,d0
 add d2,d0
 move.b d0,(a2)
 move.b 1(a0),(a3)
 addq #2,offset_adr_son(a1)
 addq.l #2,a0
 bra.s effet_boucle
.pas_volume


 cmpi.b #$f1,(a0)  * periode
 bne.s .pas_periode
 moveq #8,d0
 add d2,d0
 move.b d0,(a2)
 move.b #16,(a3)
 move.b #11,(a2)
 move.b 1(a0),(a3)
 move.l #$0c0c0000,(a2)
 move.l #$0d0d0808,(a2)
 addq.w #2,offset_adr_son(a1)
 bra fin_effet
.pas_periode

 cmpi.b #$f2,(a0)  * frequence generateur de bruit
 bne.s .pas_freq_bruit
 move.b 1(a0),d0
 lea reg7(pc),a0
 move.b d0,-2(a0)
 move d2,d0
 bset d0,(a0)
 addq #3,d0
 bclr d0,(a0)
 addq #2,offset_adr_son(a1)
 bra fin_effet

.pas_freq_bruit

 cmpi.b #$f3,(a0)
 bne.s f4
 moveq #0,d0
 move.b 1(a0),d0
 add.w d0,frequenc(a1)
 addq #2,offset_adr_son(a1)
 bra fin_effet

f4
 cmpi.b #$f4,(a0)  *frequence son
 bne.s f5
 moveq #0,d0
 move.b 1(a0),d0
 sub d0,frequenc(a1)
 addq #2,offset_adr_son(a1)
 bra fin_effet

f5
 cmpi.b #$f5,(a0) * fixe la frequence d'un son
 bne.s f6
 moveq #0,d0
 move.b note(a1),d0
 add.b 1(a0),d0
 and #$7f,d0
 add d0,d0
 lea frequence(pc),a0
 add d0,a0
 move (a0),frequenc(a1)
 addq #2,offset_adr_son(a1)
 bra fin_effet

f6
 cmpi.b #$f6,(a0)  * boucle ds le son
 bne.s f7
 moveq #0,d0
 move.b 1(a0),d0
 sub d0,offset_adr_son(a1)
 bra tt
 
f7 
f8 
f9 
fa 
fb 
fc 
fd

 cmpi.b #$fd,(a0)
 bne fe
 moveq #0,d0
 move.b 1(a0),d1
 lea reg7(pc),a0
 bset d2,(a0)

 move.b note(a1),d0
 lea frequence(pc),a0
 add #$30,d0
 and #$7f,d0
 add d0,d0
 add d0,a0

 move.b #11,(a2)  * periode enveloppe
 move.b 1(a0),(a3)  *<- poid faivle
 move.l #$0c0c0000,(a2)  *
 move.b #13,(a2)  *<- poid fort
 move.b d1,(a3)
 moveq #8,d1
 add d2,d1
 move.b d1,(a2)
 move.b #16,(a3)   * ^ a max

 addq.w #2,offset_adr_son(a1)
 bra.s  fin_effet

fe 
e0
 cmpi.b #$e0,(a0)  ;fait
 bne.s f00
 moveq #0,d0
 move.b 1(a0),d0
 move.b 2(a0),d1
 lea reg7(pc),a0
 bset d2,(a0)
 lea liste_sample(pc),a0
 add d0,d0
 add d0,d0
 add d0,a0
 move.l (a0),a0
 move.l a0,usp

 lea dec_sam(pc),a0
 move.b d1,(a0)

 addq #3,offset_adr_son(a1)
 bra.s fin_effet

f00
 cmpi.b #$00,(a0)
 bne.s f01
 addq #1,offset_adr_son(a1)
 bra.s fin_effet

f01
 cmpi.b #$01,(a0)
 bne.s f02
 lea reg7(pc),a0
 bclr d2,(a0)
 move d2,d0
 addq #3,d0
 bset d0,(a0)
 addq #1,offset_adr_son(a1)
 bra gere_effet

f02
 cmpi.b #$02,(a0)
 bne.s ret_force1
 clr.b note(a1)
 addq #1,offset_adr_son(a1)
 addq.l #1,a0
 bra effet_boucle
 
fin_effet 
 move frequenc(a1),d0
 lea manu(pc),a0
 move.w d0,(a0)

 lea reg0(pc),a0
 add d2,d2
 add d2,d2
 add d2,a0
 move.b d0,(a0)
 move.b manu(pc),2(a0)

tt
 rts

ret_force1
 move.w frequenc(a1),d0
 lea manu(pc),a0
 move.w d0,(a0)

 lea reg0(pc),a0
 move d2,d7
 add d2,d2
 add d2,d2
 add d2,a0
 move.b d0,(a0)
 move.b manu(pc),2(a0)

 clr.b flag_son(a1)

 lea reg7(pc),a0
 addq #3,d7
 bset d7,(a0)
 rts

************ taille des bloc info sur chaque voie
 rsreset
pos_sequence rs.w 1       *0
transposition rs.b 1      *2
seq rs.b 1                *3
sequence rs.l 1           *4
note rs.b 1               *8
son rs.b 1                *9
offset_adr_son rs.w 1     *10
frequenc rs.w 1           *12
flag_son rs.b 1           *14
nul6 rs.b 1               *15

taille_info rs.b 0

voie_1=taille_info*0
voie_2=taille_info*1
voie_3=taille_info*2
infos_voies ds.b taille_info*3

* !! il fo ke le rs soit paire

s_usp ds.l 1
s_mfp ds.w 6
 even
manu ds.w 1
dec_sam ds.w 1
compteur_vitesse ds.w 1
drum_ou_synthe dc.b 0
 even
registre
 dc.b 0
reg0 dc.b 0
 dc.b 1
reg1 dc.b 0
 dc.b 2
reg2 dc.b 0
 dc.b 3
reg3 dc.b 0
 dc.b 4
reg4 dc.b 0
 dc.b 5
reg5 dc.b 0
 dc.b 6
reg6 dc.b 0
 dc.b 7
reg7 dc.b %11111000

frequence
 dc.w $eee,$e17
 dc.w $d4d,$c8e,$bd9,$b2f
 dc.w $a8e,$9f7,$967,$8e0 
 dc.w $861,$7e8,$777,$70b 
 dc.w $6a6,$647,$5ec,$597 
 dc.w $547,$4fb,$4b3,$470 
 dc.w $430,$3f4,$3bb,$385 
 dc.w $353,$323,$2f6,$2cb 
 dc.w $2a3,$27d,$259,$238 
 dc.w $218,$1fa,$1dd,$1c2 
 dc.w $1a9,$191,$17b,$165 
 dc.w $151,$13e,$12c,$11c 
 dc.w $10c,$fd,$ee,$e1 
 dc.w $d4,$c8,$bd,$b2  
 dc.w $a8,$9f,$96,$8e  
 dc.w $86,$7e,$77,$70  
 dc.w $6a,$64,$5e,$59  
 dc.w $54,$4f,$4b,$47  
 dc.w $43,$3f,$3b,$38
 dc.w $35,$32,$2f,$2c  
 dc.w $2a,$27,$25,$23
 dc.w $21,$1f,$1d,$1c
 dc.w $1a,$19,$17,$16  
 dc.w $15,$13,$12,$11
 dc.w $10,$f
data_lap_musix

 even
sam0 dc.b 00
 even
sam1 incbin data\a
 even
sam2 incbin data\b
  even


liste_sample
 dc.l sam0
 dc.l sam1
 dc.l sam2
  
 even

table_offset_adr_son
 dc.w son0-table_offset_adr_son
 dc.w son1-table_offset_adr_son
 dc.w son2-table_offset_adr_son
 dc.w son3-table_offset_adr_son
 dc.w son4-table_offset_adr_son
 dc.w son5-table_offset_adr_son
 dc.w son6-table_offset_adr_son
 dc.w son7-table_offset_adr_son
 dc.w son8-table_offset_adr_son
 dc.w son9-table_offset_adr_son
 dc.w sona-table_offset_adr_son
 dc.w sonb-table_offset_adr_son
 dc.w sonc-table_offset_adr_son
 dc.w sond-table_offset_adr_son
 dc.w sone-table_offset_adr_son
 dc.w sonf-table_offset_adr_son
 dc.w son10-table_offset_adr_son
 dc.w son11-table_offset_adr_son
 dc.w son12-table_offset_adr_son
 dc.w son13-table_offset_adr_son
 dc.w son14-table_offset_adr_son
 dc.w son15-table_offset_adr_son
 dc.w son16-table_offset_adr_son
 dc.w son17-table_offset_adr_son
 dc.w son18-table_offset_adr_son
 dc.w son19-table_offset_adr_son
 dc.w son1a-table_offset_adr_son
 even
son0 dc.b $ff,0
son1 dc.b $e0,01,3,$ff
son2 dc.b $e0,02,4,$ff
son3 dc.b $f0,12,$f2,00,01,$f0,0,$ff
son4 dc.b $fd,14,1,$f5,12,0,0,$f0,0,$ff
son5 dc.b 01,$f0,0,$ff
son6 dc.b 01,$f0,13,$f5,$18
 dc.b $f0,12,$f5,0,0,0,0
 dc.b $f0,11,0,0,0
 dc.b $f0,10,0,0,0
 dc.b $f0,9,0,0,0
 dc.b $f0,8,0,0,0
 dc.b $f0,0,$ff,0
son7 dc.b $f0,11,$f5,24,$f5,36
 dc.b $f0,11,$f5,24,$f5,36
 dc.b $f0,0,$ff,0
son8 dc.b $f0,10,$f5,24,$f5,36
 dc.b $f0,10,$f5,24,$f5,36
 dc.b $f0,0,$ff,0
son9 dc.b $f0,09,$f5,24,$f5,36
 dc.b $f0,09,$f5,24,$f5,36
 dc.b $f0,0,$ff,0
sona dc.b $f0,08,$f5,24,$f5,36
 dc.b $f0,08,$f5,24,$f5,36
 dc.b $f0,0,$ff,0
sonb dc.b $e0,02,4,$f2,0,0,0,0,1,$ff
sonc dc.b $e0,02,4,$f2,2,0,0,0,1,$ff
sond dc.b $e0,02,4,$f2,4,0,0,0,1,$ff
sone dc.b $e0,02,4,$f2,6,0,0,0,1,$ff
sonf dc.b $e0,02,4,$f2,8,0,0,0,1,$ff
son10 dc.b $e0,02,4,$f2,10,0,0,0,1,$ff
son11 dc.b $e0,02,4,$f2,12,0,0,0,1,$ff
son12 dc.b $e0,01,3,0,0,0,$fd,$08,$ff,0
son13 dc.b $f0,11,$f5,24,$f5,0
 dc.b 0,0,0,0
 dc.b $f4,1,0,$f4,1,0,$f3,2,0,0
 dc.b $f4,1,0,0,$f4,2,0,$f3,2,0,0,$f3,1,0
 dc.b $f6,14,$ff,0
son14 dc.b $f0,11,$f3,4,$f6,2
son15 dc.b $f1,0,1,$f4,2,$f6,2,$ff
son16 dc.b 01,$e0,01,3,$ff,0
son17 dc.b $f0,12,$f5,36,$f5,0,$f0,0,$ff,0
son18 dc.b $f0,12,$f5,36,$f5,24,$f5,00,$f0,0,$ff,0
son19 dc.b $f0,12,$f5,36,$f5,24,$f5,12,$f5,0,$f0,0,$ff,0
son1a dc.b $f4,1,0,0,0,0,$f6,6,$ff,0

partition_pattern
debut_zik
  dc.w $0,$0,$100,$0,$0,$0
  dc.w $0,$0,$100,$0,$0,$0

  dc.w $20c+0,$300,$300,$0,$200,$500
  dc.w $20c+0,$300,$300,$0,$200,$500
  dc.w $20c-2,$300,$300,$0,$2fe,$500
  dc.w $20c-2,$300,$300,$0,$2fe,$500
  dc.w $20c-3,$300,$300,$0,$2fd,$500
  dc.w $20c-5,$300,$300,$0,$2fb,$500

  dc.w $20c+0,$300,$400,$0,$200,$400
  dc.w $20c+0,$300,$400,$0,$000,$000
  dc.w $20c-2,$300,$4fe,$0,$200,$400
  dc.w $20c-2,$300,$4fe,$0,$000,$000
  dc.w $20c-3,$300,$405,$0,$200,$400
  dc.w $20c-5,$300,$407,$0,$000,$000

  dc.w $20c+0,$300,$400,$0,$700,$1200
  dc.w $20c+0,$300,$400,$0,$800,$1200
  dc.w $20c-2,$300,$4fe,$0,$700,$1200
  dc.w $20c-2,$300,$4fe,$0,$800,$1200
  dc.w $20c-3,$300,$405,$0,$705,$1200
  dc.w $20c-5,$300,$407,$0,$900,$1200

  dc.w 0,0,$600,$0,$0,$0
  dc.w $530,$1400,$600,$0,$0,$0

  dc.w $bf4,$1600,$a00,$0,$b00,$1600
  dc.w $bf4,$1600,$a00,$0,$b00,$1600
  dc.w $bf4,$1700,$a00,$0,$b00,$1700
  dc.w $bf4,$1800,$a00,$0,$b00,$1800

  dc.w $c24,$1200,$100,$0,$c18,$1200
  dc.w $d24,$1200,$100,$0,$d18,$1200

  dc.w $20c+0,$300,$400,$0,$e18,$1200
  dc.w $20c+0,$300,$400,$0,$51f+24,$1200
  dc.w $20c-2,$300,$4fe,$0,$51d+24,$1200
  dc.w $20c-2,$300,$4fe,$0,$f0c,$1200
  dc.w $20c-3,$300,$405,$0,$51f+24,$1200
  dc.w $20c-5,$300,$407,$0,$1024+12,$1200

  dc.w $20c+0,$300,$400,$0,$1124,$1200
  dc.w $20c+0,$300,$400,$0,$524+10,$1900
  dc.w $20c-2,$300,$4fe,$0,$1224,$1200
  dc.w $20c-2,$300,$4fe,$0,$524+12,$1200
  dc.w $20c-3,$300,$405,$0,$130c,$1200
  dc.w $20c-5,$300,$407,$0,$140c,$1200
fin_zik

num_pattern_debut_music  dc.w (debut_zik-debut_zik)/12 * numero du 1er pattern de la zik
num_pattern_fin_music    dc.w (fin_zik-debut_zik)/12-1 * numero du dernier pattern de la zik
position_pattern ds.w 1  * position  actuelle

mesure
p0 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
p1 dc.w 1,3,2,3
 dc.w 2,1,1,1
 dc.w 3,1,2,3
 dc.w 2,1,3,2
p2 dc.w $0c01,$0c01,$1801,$0c01
 dc.w $1801,$0c01,$0c01,$0c01
 dc.w $0c01,$0c01,$1801,$0c01
 dc.w $1801,$1801,$0c01,$1801
p3 dc.w 1,3,3,3
 dc.w 2,1,1,1
 dc.w 3,3,3,3
 dc.w 2,3,3,2
p4 dc.w 1,$0c06,$0c07,$0c08
 dc.w 2,1,1,1
 dc.w $0c06,$0c07,$1008,$1009
 dc.w 2,$1306,$1307,$1308
p5 dc.w $0c01,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
p6 dc.w $16,$03,$03,$03
 dc.w $0b,$0c,$16,$0d
 dc.w $0e,$16,$0f,$16
 dc.w $10,$16,$11,$16
p7 dc.w $3001,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w $2e01,$3001,$2e01,$3001
p8 dc.w $2b01,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w $2901,$2701,$2601,$2401
p9 dc.w $3701,0,0,0
 dc.w 0,0,0,0
 dc.w $3702,0,0,0
 dc.w 0,0,0,0
pa dc.w 1,3,3,3
 dc.w 2,1,3,1
 dc.w 1,3,3,3
 dc.w 2,1,1,1
pb dc.w $1801,$1801,$1801,$1801
 dc.w $1801,$1801,$1801,$1801
 dc.w $1801,$1801,$1801,$1801
 dc.w $1801,$1801,$1801,$1801
pc dc.w $1801,0,0,$1601
 dc.w 0,0,$1301,0
 dc.w $1601,0,0,$1301
 dc.w 0,0,$1101,0
pd dc.w $1301,0,0,$1101
 dc.w 0,0,$1301,0
 dc.w $0f01,0,0,$1101
 dc.w 0,0,$0f01,0
pe dc.w $1801,0,$1b01,0
 dc.w $1d01,0,$1f01,0
 dc.w $2201,0,$2401,0
 dc.w $2701,0,$2901,0
pf dc.w $3301,$3501,0,$3301
 dc.w $3501,0,$3301,$3501
 dc.w 0,$3301,$3501,0
 dc.w $3301,$3501,0,$3301
p10 dc.w $1601,0,0,$1301
 dc.w 0,0,$1101,0
 dc.w $0f01,0,0,$1101
 dc.w 0,0,$0f01,0
p11 dc.w $1801,$1601,$1b01,$1601
 dc.w $1d01,$1601,$1f01,$1601
 dc.w $2201,$1601,$1f01,$1601
 dc.w $1d01,$1601,$1b01,$1601
p12 dc.w $1801,$1601,$1801,$1601
 dc.w $1801,$1601,$1801,$1601
 dc.w $1801,$1601,$1801,$1601
 dc.w $1801,$1601,$1801,$1601
p13 dc.w $3501,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,$3301,$3501
p14 dc.w $3701,0,0,0
 dc.w 0,0,0,0
 dc.w 0,0,0,0
 dc.w $3501,$3301,$3001,$0c03
lapend
ech_nul ds.b 122