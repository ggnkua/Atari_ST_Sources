main:
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 lea pointeursuperviseur(pc),a0
 move.l d0,(a0)
 move.w #1,-(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp
 moveq.l #0,d0
 move.b $ff8201,d0
 lsl.w #8,d0
 move.b $ff8203,d0
 lsl.l #8,d0
 movea.l d0,a0
 move.w #$1f40,d0
efface:
 clr.l (a0)+
 dbra d0,efface
 lea $ff8240,a0
 move.w #7,d7
noir:
 clr.l (a0)+
 dbra d7,noir
 pea texte(pc)
 move.w #9,-(sp)
 trap #1
 addq.l #6,sp
 move.b -$5f9,d5
 move.b -$5f7,d7
 clr.b -$5f9
 clr.b -$5f7
 move.b #2,$ff820a
 lea -$7dc0,a3
 lea finpalette(pc),a2
 lea couleurun(pc),a4
 lea couleurdeux(pc),a5
 moveq #0,d2
 moveq #0,d4
 moveq #0,d0
 move.l $68,a0
 move.l $70,a6
 lea hbl(pc),a1
 move.l a1,$68
 lea vbl(pc),a1
 move.l a1,$70
 lea debutpalette(pc),a1
 and.w #$f8ff,sr
finprovisoire:
 cmpi.b #$b9,$fffc02
 beq sortie
 cmpi.b #$39,$fffc02
 beq sortie
 jmp finprovisoire(pc)
hbl:
 move.w #$14,d1
compteur:
 dbra d1,compteur
 cmpi.w #$fff,(a4)
 bne encore
 lea couleurun(pc),a4
encore:
 cmpi.w #$fff,(a5)
 bne suite
 lea couleurdeux(pc),a5
suite:
 addq.w #1,d3
 cmp.w #160,d3
 bcc second
 cmpi.w #$fff,(a1)
 bne enjambe
 lea debutpalette(pc),a1
enjambe:
 move.w (a1)+,(a3)
 jmp onyva(pc)
second:
 cmpi.w #$fff,(a2)
 bne reenjambe
 lea debutpalette(pc),a2
reenjambe:
 move.w (a2)+,(a3)
onyva:
 move.w (a5)+,6(a3)
 move.w (a4)+,2(a3)
 rte
vbl:
 moveq #0,d3
 lea debutpalette(pc),a1
 lea finpalette(pc),a2
 lea couleurun(pc),a4
 lea couleurdeux(pc),a5
 adda.l d4,a4
 adda.l d2,a1
 adda.l d6,a5
 suba.l d2,a2
 addq.l #2,d2
 addq.l #2,d6
 addq.b #1,d0
 cmpi.b #2,d0
 ble grand
 moveq.l #0,d0
 addq.l #2,d4
grand:
 cmpi.w #$fff,2(a1)
 bne redessus
 moveq #0,d2
redessus:
 cmpi.w #$fff,4(a4)
 bne glof
 moveq #0,d4
glof:
 cmpi.w #$fff,2(a5)
 bne prout
 moveq #0,d6
prout:
 rte
sortie:
 or.w #$300,sr
 move.b d7,-$5f7
 move.b d5,-$5f9
 move.l a0,$68
 move.l a6,$70
 clr.w $ff8240
 and.w #$f8ff,sr
 clr -(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move #5,-(sp)
 trap #14
 adda.l #12,sp
 move #$777,$ff8240
 move.l pointeursuperviseur(pc),-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr.l -(a7)
 trap #1
pointeursuperviseur:
 dc.l 0
 dc.w $fff
debutpalette:
 dc.w $003
 dc.w $003
 dc.w $004
 dc.w $004
 dc.w $005
 dc.w $005
 dc.w $006
 dc.w $006
 dc.w $007
 dc.w $007
 dc.w $006
 dc.w $006
 dc.w $005
 dc.w $005
 dc.w $004
 dc.w $004
 dc.w $003
 dc.w $003
finpalette:
 dc.w $000
 dc.w $fff
 dc.w $fff
couleurun:
 dc.w $000
 dc.w $100
 dc.w $200
 dc.w $300
 dc.w $400
 dc.w $500
 dc.w $600
 dc.w $700
 dc.w $000
 dc.w $110
 dc.w $220
 dc.w $330
 dc.w $440
 dc.w $550
 dc.w $660
 dc.w $770
 dc.w $000
 dc.w $010
 dc.w $020
 dc.w $030
 dc.w $040
 dc.w $050
 dc.w $060
 dc.w $070
 dc.w $000
 dc.w $011
 dc.w $022
 dc.w $033
 dc.w $044
 dc.w $055
 dc.w $066
 dc.w $077
 dc.w $000
 dc.w $001
 dc.w $002
 dc.w $003
 dc.w $004
 dc.w $005
 dc.w $006
 dc.w $007
 dc.w $000
 dc.w $101
 dc.w $202
 dc.w $303
 dc.w $404
 dc.w $505
 dc.w $606
 dc.w $707
bas:
 dc.w $000
 dc.w $fff
 dc.w $fff
couleurdeux:
 dc.w $720
 dc.w $730
 dc.w $740
 dc.w $750
 dc.w $760
 dc.w $770
 dc.w $670
 dc.w $570
 dc.w $470
 dc.w $370
 dc.w $270
 dc.w $072
 dc.w $073
 dc.w $074
 dc.w $075
 dc.w $076
 dc.w $077
 dc.w $067
 dc.w $057
 dc.w $047
 dc.w $037
 dc.w $027
 dc.w $207
 dc.w $307
 dc.w $407
 dc.w $507
 dc.w $607
 dc.w $707
 dc.w $706
 dc.w $705
 dc.w $704
 dc.w $703
 dc.w $702
 dc.w $fff
texte:
 dc.b 27,102,27,69,10,10,10,10,10,10,"   Welcome to populus ! This is just a HBL's page to say you that it's another",10,13
 dc.b "TUC crack and that some of good compilation will fill your littles blues disks.",10,13
 dc.b "If this copy came of a single side floopy disk, there isn't muzax on it.",10,13
 dc.b "I'm very sorry, and I promise you that I will make another version ...",10,13
 dc.b "        Members of this best group are : the Child ( the autor of this crack and",10,13
 dc.b "the best swapper never seen in the world ), the Cia ( the ex-swapper who seem to",10,13
 dc.b "be asleep many month ago ), the Warrior ( who is learning the 68000 language ),",10,13
 dc.b "and me ( the famous AL cracker ), the autor of this HBL's page and the LM code",10,13
 dc.b "expert of this incredible group. Greeting to the Union, to Equinox, to the",10,13
 dc.b "replicants ( hey guys ! What are you saying about a little walk in your bal ? ),",10,13
 dc.b "to the numerous folks who are calling me on the SM1*ST ( my bal is PIRATEAL ),",10,13
 dc.b "and to all the Child's contacts ( too many for being written here ... ).",10,10,13
 dc.b "               To play, crash your head on your spazebar ...",0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dats:
 dc.l 0,0,0,0,0,0,0,0
nom1:
 dc.b 'pop.tuc',0
nom2:
 dc.b 'level2.dat',0
nom3:
 dc.b 'way.dat',0
header1:
 dc.w 0
rien:
 dc.l 0
header2:
 dc.l 0
numero:
 dc.b $20
numero2:
 dc.b $31,0,0
 dc.l 0
 ds.l 30
decodage:
 move.w #499,d0
 lea main(pc),a0
benoui:
 eori.l #$12345678,(a0)+ 
 dbra d0,benoui
 pea main(pc)
 rts
 end
