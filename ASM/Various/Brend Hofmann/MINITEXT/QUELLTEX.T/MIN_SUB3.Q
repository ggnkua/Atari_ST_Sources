;Eingabe aus Formular
lies         move.b #0,(a1)         ;Ergebnis lîschen
lies1        bsr txtadr
             cmpi.b #64,(a0)        ;@ ?
             beq fehler
             tst.b (a0)
             beq fehler
ls           bra copy
;Adresse Te_ptext
txtadr       bsr baumadress
             moveq #24,d0
             mulu d2,d0             ;d2 bleibt erhalten
             move.l 12(a0,d0.l),a0  ;Tedinfo
             move.l (a0),a0         ;Tep_text
tart         rts
;Adresse Te_ptmplt
tempadr      bsr baumadress
             mulu #24,d2
             move.l 12(a0,d2.l),a0
             move.l 4(a0),a0
             rts
;Schrift in Formular
txtin        bsr.s txtadr
             exg a0,a1
             bra copy
;welcher Button ?
selindex     bsr.s baumadress
             moveq #0,d0
             ext.l d1
             add.l d1,a0            ;erstes Objekt
teste        move (a0),d1
             andi #1,d1
             bne.s selret           ;gefunden
             lea 24(a0),a0          ;nÑchstes objekt
             addq #1,d0
             bra.s teste
selret       rts

baumadress   lea baum,a0
             add.l baumnr,a0
             move.l (a0),a0
             rts
;Button setzen
setbut       ext.l d1
             mulu #24,d0
             bsr.s baumadress
loe          andi #254,10(a0,d1.l)
             cmp d1,d0
             bne.s nebut
             ori #1,10(a0,d1.l)
nebut        add #24,d1
             cmp d2,d1
             bne.s loe
             rts

formalert  form_alert #1,(a2),d0
             move d0,-(a7)
             bsr mausmaf
             move (a7)+,d0
             cmp #1,d0
             rts
;String aus Formular Zahl wandeln
binout       move inindex,d2
binout1      bsr txtadr             ;Stringadresse im Formular
             bra dezbin             ;Integer wandeln
;Zahl als String in Formular eintragen
binin        move inindex,d2
             bsr txtadr             ;Textadresse im Formular
             move.l d5,d0           ;Zahl nach d0
             bra formzahl1
;Mausformen
mausf0       moveq #0,d0
             bra.s schalte
mausf2       moveq #2,d0
             bra.s schalte
mausf3       moveq #3,d0
             bra.s schalte
mausf4       moveq #4,d0
             bra.s schalte
mausf5       moveq #5,d0
             bra.s schalte
mausaus      move #256,d0
             bra.s schalt0
mausan       move #257,d0
             bra.s schalt0
mausmaf      move mausf,d0
schalte      move d0,mausf
schalt0    graf_mouse d0,work_0,d0
             rts

setwrmod4    moveq #4,d0
             bra.s setwrmod
setwrmod3    moveq #3,d0
             bra.s setwrmod
setwrmod2    moveq #2,d0
             bra.s setwrmod
setwrmod1    moveq #1,d0
setwrmod   vswr_mode handle,d0,d0
             rts

clipan       moveq #1,d0
setclip    vs_clip handle,d0,cliparr
             rts


bar        scf_vdi 11,2,0,handle    ;v_bar
             move #1,10(a3)
           vdi
             rts

recfl      scf_vdi 114,2,0,handle
           vdi
             rts

vslpara      move.l (a7)+,a4
           scf_vdi 17,0,1,handle    ;color
             move (a7)+,intin
           vdi
           scf_vdi 15,0,1,handle    ;Type
             move (a7)+,intin
           vdi
           scf_vdi 16,1,0,handle    ;width
             lea ptsin,a0
             move (a7)+,(a0)+
             clr (a0)
           vdi
           scf_vdi 108,0,2,handle   ;ends
             move.l (a7)+,intin
           vdi
             pea (a4)
             rts

vsfpara      move.l (a7)+,a4        ;RÅcksprung holen
           scf_vdi 25,0,1,handle    ;color
             move (a7)+,intin
           vdi
           scf_vdi 104,0,1,handle   ;perimeter
             move (a7)+,intin
           vdi
           scf_vdi 23,0,1,handle    ;interior
             move (a7)+,intin
           vdi
           scf_vdi 24,0,1,handle    ;style
             move (a7)+,intin
           vdi
             pea (a4)
             rts

polyl        bsr mausaus
             lea mausx,a0
             lea ptsin,a1
             move.l (a0),(a1)+
             move 4(a0),(a1)+
             move 2(a0),(a1)+
             move.l 4(a0),(a1)+
             move (a0),(a1)+
             move 6(a0),(a1)+
             move.l (a0),(a1)
             moveq #5,d0
             bsr polyline
             bra mausan

polyline     lea contrl,a3
             move #6,(a3)+
             move d0,(a3)
             clr 4(a3)
             move handle,10(a3)
           vdi
             rts

txtheight  vst_height handle,d0,puffer
             rts

txteffect0   moveq #0,d5
txteffect    move txth,d0            ;Schrifthîhe
             move #192,d1
             and d5,d1
             beq.s txteffect1
             moveq #4,d0
txteffect1   move d5,d6
             and #63,d5
             bsr.s txtheight
txteff     vst_effects handle,d5,d5
             move d6,d5
             rts

mkstate    graf_mkstate d0,mausx1,mausy1,d0,d1
             rts

butfree      bsr.s mkstate
             tst d0
             bne.s butfree
             rts

lassobox     move.l #0,-(a7)
             move #1,-(a7)
             move.l #$10003,-(a7)
             bsr vslpara
             bsr setwrmod3
rbb          bsr polyl
             moveq #32,d0
             bsr evmult
             bsr polyl
             lea mbuff+16,a0
             move.l (a0),mausx+4
             tst 4(a0)
             bne.s rbb
             bra setwrmod1
;MenÅeintrÑge freigeben - sperren
menchange0   moveq #0,d2
             bra.s men0
menchange1   moveq #1,d2
men0         move.l baum,a5
men1         lea mench,a0
             add.l d5,a0
             move (a0),d0
           menu_ienable d0,d2,(a5),d0
             addq #2,d5
             cmp d5,d6
             bge.s men1
             rts
;Formular zeichnen
draw         tst maus
             bne.s dr
             bsr mausan
             move #1,maus
dr           moveq #0,d0
             bsr schalt0            ;Maus=Pfeil
             bsr rettsch            ;Bildschirm retten

drawt      scf_aes 42,6,1,1,0
             bsr baumadress
             move.l a0,baumadr
             lea intin,a3
             move erstobj,(a3)+
             move #3,(a3)+
             move.l work_0,(a3)+
             move.l work_0+4,(a3)
             move.l a0,addrin
           aes
             move intout,d0
             rts
;Formular zeichnen & verwalten
formular     bsr.s draw
             bsr.s formdo
             bsr holsch
             cmp #2,d2              ;Abbruch ?
             beq fehler
             bra ok

formdo       bsr.s formdo0
obchange0    moveq #0,d1
obchange   scf_aes 47,8,1,1,0       ;Objc_Change
             lea intin,a3
             move d2,(a3)+
             move #0,(a3)+
             move.l work_0,(a3)+
             move.l work_0+4,(a3)+
             move d1,(a3)+
             move #1,(a3)
             move.l baumadr,addrin
           aes
             move intout,d0
             rts

formdo0    scf_aes 50,1,1,1,0
             move editobj,intin
             move.l baumadr,addrin
           aes
             move intout,d2         ;Exitindex
             rts

oboffs       bsr baumadress
           objc_offset d2,(a0),d0,d0,d1
             rts

wiset      scf_aes 105,6,1,0,0
             lea intin,a3
             move akthand,(a3)+
             move d0,(a3)
           aes
             rts

wiget      scf_aes 104,2,5,0,0
             move akthand,intin
             move d4,intin+2
           aes
             move.l intout+2,(a4)+
             move.l intout+6,(a4)
             rts

wiup3        move #3,intin
             bra.s wiup
wiup2        move #2,intin
             bra.s wiup
wiup1        move #1,intin
             bra.s wiup
wiup0        move #0,intin
wiup       scf_aes 107,1,1,0,0
           aes
             rts

mentxt       move.l baum,a0
           menu_text fen,(a0),(a2),d0
             rts

mencheck0    moveq #0,d0
             bra.s mencheck
mencheck1    moveq #1,d0
mencheck     move.l baum,a0
           menu_icheck fen,d0,(a0),d0
             rts

deskchange   move akthand,-(a7)
             move #0,akthand
             move.l baum+4,a0
             lea 10(a0),a0
             moveq #24,d0
             mulu d2,d0
             move d1,(a0,d0.l)      ;Status setzen
             lea clplst,a4
             moveq #11,d4
             bsr wiget
dc0          tst (a4)
             bne.s dc1
             tst 2(a4)
             beq.s dcret
dc1          subq.l #4,a4
           scf_aes 42,6,1,1,0       ;objc_draw
             lea intin,a3
             move d2,(a3)+
             clr (a3)+
             move.l (a4)+,(a3)+
             move.l (a4),(a3)
             move.l baum+4,addrin
           aes
             lea clplst,a4
             moveq #12,d4
             bsr wiget
             bra.s dc0
dcret        move (a7)+,akthand
             rts

dragbox    scf_aes 71,8,3,0,0
           aes
             lea intout,a3
             move (a3)+,d0
             move (a3)+,d1
             move (a3),d2
             rts

evmult     evnt_multi d0,#2,#1,#1,maus1,work_arb,#0,work_0,#75,mbuff,d7,mbuff+16,d2,d1
;RöCKGABE: D7 EREIGNIS,D2 TASTENCODE,D1 KLICKS,MBUFF MESSAG,MBUFF+16/18
;X/Y MAUS , MBUF+20 STATUS BUTTONS , MBUFF+22 KEYSTATUS
             lea mbuff,a0
             rts

linec        tst d0
             beq mouse              ;Kursorposition 0
             add #12,d1
             cmp -2(a0),d1
             ble.s lz1
lÑ0          ext.l d0
             addq #1,d0
             cmp 4(a5),d0
             beq.s llÑnge           ;LineallÑnge Ñndern
             subq #1,d0
             lea tabul,a0
             eori.b #44,(a0,d0.l)
lz           bsr lineal
lz1          rts
llÑnge       subq #1,d0
             sub -4(a6),d0
             lsl #3,d0
             add xstart,d0
             lea intin,a1
             move #8,(a1)+          ;Hîhe
             move #12,(a1)+         ;Breite
             move d0,(a1)+          ;X
             lea xmax,a0
             move -2(a0),d0
             sub #12,d0
             move d0,(a1)+          ;Y
             move -4(a0),(a1)+      ;X
             move d0,(a1)+          ;Y
             move (a0),d0
             sub 4(a0),d0
             move d0,(a1)+          ;Breite
             move #12,(a1)          ;Hîhe
             bsr dragbox
             sub xstart,d1
             cmp #16,d1
             bgt.s ll0
             moveq #16,d1
ll0          lsr #3,d1
             addq #1,d1
             add -4(a6),d1
             cmp #19,d1
             bgt.s ll1
             moveq #20,d1
ll1          move d1,4(a5)
             move d1,-18(a6)
             move d1,d5
             move -14(a6),d6        ;aktuelle Zeile
             bsr txtort
ll2          move d5,4(a0)          ;LineallÑnge Åbernehmen
             cmp -24(a6),d6
             beq lz
             add.l d0,a0
             move (a0)+,d0
             addq #1,d6
             bra.s ll2

blockset     bsr zeilÅber
             move nzeile,d1
             bsr txtort1
             cmp.b #28,7(a0)        ;Grafik in Zeile ?
             beq mouse              ;ja
             bsr kursor
             move nzeile,blan
             move kpos,blanx
             lea mausx,a2
             move.l (a2),4(a2)
             bsr lassobox
             move 4(a2),d5
             sub xstart,d5
             move 6(a2),d1
             bsr butzeile
             move d4,d1
             bsr txtort1
             cmp.b #28,7(a0)
             bne.s bs
             move #-1,blan
             rts
bs           move d4,blen
             lsr #3,d5
             add -4(a6),d5
             move d5,blenx
             bsr anfend
             move #65,fen
             bsr mencheck1          ;HÑckchen
             move #64,fen
             bsr mencheck1
             bra ble0

growbild     move (a2),d0
             add d0,4(a2)           ;statt Breite und Hîhe wird
             move 2(a2),d0          ;der Punkt rechts unten
             add d0,6(a2)           ;benîtigt
             bsr lassobox
             move 6(a2),d1
             bsr butzeile
             lea grazeil+14,a1
             move 4(a2),d0          ;x-rechts
             sub (a2),d0            ;x-links
             cmp #16,d0
             bgt.s bd
             move #16,d0            ;mindestens 16 pixel
bd           lsr #3,d0              ;Breite in Byte
             move (a1),d1           ;kpos
             add d0,d1
             cmp #136,d1
             ble.s bd00
             move #136,d0
             sub (a1),d0
bd00         move d0,2(a1)          ;in Kopf eintragen
             move 6(a2),d0          ;das gleiche fÅr die Hîhe
             sub 2(a2),d0
             move zlabst,d1         ;Mindesthîhe
             cmp d1,d0
             bgt.s bd0
             move d1,d0
bd0          ext.l d0
             divu d1,d0             ;vorlÑufige Hîhe in Zeilen
             move 6(a1),d3          ;bisherige Hîhe in Zeilen
             move.l suchadr,a0      ;IMG-Adresse
             pea (a0)
             move 14(a0),d2         ;Pixelhîhe der IMG
             ext.l d2
             move.l d2,d1
             divu d0,d1             ;Pixel/Zeile
             divu d1,d2             ;Zeilenzahl
             cmp.l #$ffff,d2        ;Teilungsrest ?
             bgt.s bd1              ;ja
             subq #1,d2             ;sonst eine Zeile weniger
bd1          move d2,6(a1)          ;Zahl im neuen Header speichern
             move d1,10(a0)
             move 8(a1),d5         ;Bildnummer
             move zeinr,-14(a6)     ;erste Bildzeile
             bsr killbild           ;alte Bildheader entfernen
             move zeinr,d7
             move d7,-14(a6)
             add grazeil+20,d7
             sub -24(a6),d7
             bmi.s bd3
bd2          move.l aktend,a1
             bsr zeilin
             dbra d7,bd2
bd3          bsr bildneu            ;Neue Header eintragen
             move.l (a7)+,a2        ;IMG-Adresse
             bsr neuadr             ;hier muû -36(a6) korrigiert werden
             move.l sel,d0
             cmp.l blsel,d0
             bne mb3
             move blan,d0
             bsr inblock
             beq mb3
             bra mbd

movbild      bsr mausf4
             lea intin,a0
             move -4(a6),d0
             lsl #3,d0
             move xstart,d1
             sub d0,d1
             move d1,8(a0)          ;x Begrenzungrechteck
             move -10(a6),d0        ;erste Zeile auf Bildschirm
             subq #2,d0
             mulu zlabst,d0
             move ystart,d1
             sub d0,d1
             cmp #-200,d1
             bgt.s mb
             move #-200,d1
mb           move d1,10(a0)         ;y Begrenzung
             move #$440,12(a0)      ;Breite
             move #800,14(a0)       ;Hîhe
             move.l (a2),4(a0)      ;Grafikposition
             move.l 4(a2),(a0)      ;Grîûe
             bsr dragbox
             lea grazeil+10,a0
             sub mausx,d1           ;alter x-Wert von neuem abz.
             ext.l d1
             divs #8,d1             ;in Byte
             add 4(a0),d1           ;+ alte Bildposition
             move d1,4(a0)          ;neue Position
             sub mausy,d2           ;analog fÅr y verfahren
             ext.l d2
             divs zlabst,d2
             add zeinr,d2
             cmp #1,d2
             bgt.s mb1
             moveq #2,d2            ;erste textzeile
mb1          cmp -24(a6),d2
             ble.s mb2
             move -24(a6),d2        ;hîchstens Textende zulassen
mb2          move d2,zeile          ;neuer Beginn
             move zeinr,-14(a6)
             move 12(a0),d5         ;Bildnr.
             move 10(a0),d3         ;Zeilenzahl
             bsr killbild           ;header entfernen
             move zeile,d7
             move d7,-14(a6)
             add grazeil+20,d7
             sub -24(a6),d7
             bmi.s mb2b
mb2a         move.l aktend,a1
             bsr zeilin
             dbra d7,mb2a
mb2b         bsr bildneu            ;neuer header
             move.l sel,d0
             cmp.l blsel,d0
             bne.s mb3
             move zeile,d1
             move blan,d0
             bsr inblock
             bne.s mbd              ;Grafik wurde in Block verschoben
             move zeile,d1
             move blen,d0
             bsr inblock
             beq.s mb3
mbd          bsr demark
mb3          bsr mausf0
             move index,-14(a6)     ;aktuelle Zeile
             move #1,-6(a6)
             bra neuscreen

inblock      cmp d1,d0
             blt ok                 ;nicht im Block
             add puffer+10,d1
             cmp d1,d0
             bgt ok
             bra fehler

beginn       lea txtstart,a0
             move.l psel,d0
             add.l d0,a0
             move.l (a0)+,a2        ;Startadresse
             move.l (a0),d2         ;Adresse nÑchster Text
             cmp.l sel,d0
             bne.s begret           ;nicht aktiver Text
             move.l aktend,d2       ;reales Textende
begret       move.l d2,nxtstart
             rts

lprint       move.l d2,-(a7)        ;Zeiger auf Buchstaben
lpr          clr -(a7)
             move #8,-(a7)
             trap #13
             addq.l #4,a7
             tst d0
             beq.s lpr
             and #255,d4
             move d4,-(a7)          ;Zeichen
             clr -(a7)              ;Printer
             move #3,-(a7)          ;conout
             trap #13
             addq.l #6,a7
             move.l (a7)+,d2
             rts

prtsteu0     move.l druckcod0,a0
             bra.s prtst
prtsteu1     move.l druckcod1,a0
prtst        bsr codeort
             addq.l #1,a0           ;Codebeginn
ps0          subq #1,d0
             beq.s psret
             move.b (a0)+,d4        ;Zeichen holen
             pea (a0)
             move d0,-(a7)
             bsr.s lprint           ;ausgeben
             move (a7)+,d0
             move.l (a7)+,a0
             bra.s ps0
psret        rts

rand         moveq #80,d6
             bsr.s prtsteu0         ;Normalschrift Pica
             move raza,d5
             moveq #32,d4
             bra.s rnd1
rnd0         bsr.s lprint
rnd1         dbra d5,rnd0
             rts

druckstop  constat
             tst d0                 ;Taste ?
             beq ok                 ;nein
           conin
             cmp.b #27,d0           ;Escape ?
             bne ok                 ;nein
             pea (a2)
             lea drstop,a2
             bsr formalert
             move.l (a7)+,a2
             cmp #2,d0              ;weiter ?
             rts

newl         move abst,d0
             move 2(a5),d3
             cmp d3,d0              ;Abstand Ñndern ?
             beq.s newl0            ;nein
vsch         bsr.s setvs            ;Abstand merken und setzen
newl0        moveq #4,d6
             bra prtsteu0

setvs        move d3,abst
             moveq #0,d6
             bsr prtsteu0
             moveq #1,d6
             bsr codeort0
             move.b 1(a0),d4
             mulu d3,d4
             lsr #1,d4              ;Pixelzahl fÅr Vorschub
             bra lprint

vrs          bsr.s newl0
vrs1         dbra d7,vrs
             rts

prtzeile     bsr rand
             bsr schrift            ;richtige Schriftart
             bsr txtbeginn
             bsr.s druckzeil        ;Text
             cmp.b #28,7(a5)
             bne.s newl
             bra prtgraf            ;Grafik

druckzeil    move.b (a5,d2.l),d6
             and #255,d6
             beq.s dzret            ;fertig
             cmp #27,d6
             bne.s pz1
             addq #1,d2
             move.b (a5,d2.l),d5    ;Kommando holen
             bsr setschr            ;auswerten und ausfÅhren
             bra.s pz2
pz1          cmp #31,d6
             bne.s pz
             addq #1,d6
pz           bsr prtsteu1           ;Zeichen ausgeben
pz2          addq #1,d2
             bra.s druckzeil
dzret        rts

prtgraf      pea (a2)
             lea puffer,a2
             clr.l 8(a2)            ;grîûte Pixelbreite
             clr.l 12(a2)           ;DurchlÑufe,gleiche Zeilen
             moveq #7,d2
             lea prttab,a4
             move 2(a4),d0          ;hîchste Zeilenzahl
             mulu 6(a4),d0          ;* Zeilenbreite=Puffergrîûe
             move.l diskpuff,a0
             bsr clrpuff            ;Zeilenpuffer lîschen
pg           move 13(a5,d2.l),d5    ;Bildnummer
             bsr bildnr             ;Adresse Bilddaten nach a3
             move 12(a3),d0         ;Zeichnungsoriginalbreite in Byte
             move d0,bytes          ;wegen 'depac'
             lsl #3,d0
             move d0,18(a2)         ;in Pixel
             move 8(a3),d1          ;Auflîsung
             move 7(a5,d2.l),d0     ;gewÅnschte Bildbreite
             mulu d1,d0
             divu #10,d0
             move d0,20(a2)         ;gewÅnschte Breite in Pixel
             move (a4),d0           ;hîchstmîgliche dichte
             divu d1,d0
             move d0,16(a2)         ;Pixelabstand
             lea (a4),a0
pg0          cmp (a0),d1
             addq.l #8,a0
             bne.s pg0
             move -6(a0),d0         ;theoretische Zeilenzahl
             moveq #12,d1
             cmp #8,-2(a4)
             beq.s pg1
             moveq #30,d1
pg1          divu d1,d0
             cmp 12(a2),d0
             ble.s pg2
             move d0,12(a2)         ;DruckdurchlÑufe
pg2          move d1,28(a2)         ;Pixel/Druckzeile als Teiler
             move 5(a5,d2.l),d0     ;linker Bildrand
             move d0,d1
             add 7(a5,d2.l),d0      ;+ Bildbreite
             mulu (a4),d0           ;* Auflîsung
             divu #10,d0            ;Pixelbreite Bild
             mulu (a4),d1
             divu #80,d1
             add.l diskpuff,d1
             move.l d1,4(a2)        ;Beginn der Datenablage
             cmp.l 8(a2),d0
             ble.s pg3
             move.l d0,8(a2)        ;hîchste Pixelzahl
pg3          lea 16(a3),a0          ;Beginn Daten
             move 10(a3),d6         ;Bildzeilen/Druckzeile
             mulu 9(a5,d2.l),d6     ;*Zeilennr.=Zeilen zu Åberlesen
             move d6,30(a2)
             mulu 12(a3),d6         ;*Bytebreite=Byte zu Åberlesen
           bne pg3a
           move (a0),d0
           bne pg4
           move.b 3(a0),d0
           addq.l #4,a0
           bra pg3b
pg3a             bsr imgadr             ;Adresse IMG-Anteils
             beq.s pg4
pg3b             move d0,14(a2)         ;Zahl gleicher Zeilen
pg4          move.l a0,(a2)         ;Beginn des IMG-Anteils
             moveq #0,d7            ;ZeilenzÑhler
pg5          move 10(a3),d6         ;tatsÑchliche Zeilenzahl
             mulu d7,d6             ;d7<=2(a4)-1
             move 2(a4),d0
             subq #1,d0
             divu d0,d6             ;tatsÑchliche Zeilennr
             move 14(a3),d0         ;Bildhîhe
             sub 30(a2),d0          ;Bildanfangswert
             cmp d6,d0
             ble.s pg8              ;Zeilennr. zu groû
             move.l (a2),a0         ;Defaultadresse
             sub 14(a2),d6
             ble.s pg7              ;gleich erste Zeile
             tst 14(a2)
             beq.s pg6
             bsr grzend             ;Zeilende suchen
pg6          mulu 12(a3),d6
             bsr imgadr
pg7          lea aktwort+512,a1     ;Ziel fÅr depac
             bsr depac              ;Zeile entpacken
             lea aktwort+512,a0     ;Quelle
             move.l 4(a2),a1        ;Ablageort
             bsr prtpac             ;Zeile in Druckerspeicher schreiben
             move.l 4(a4),d0
             add.l d0,4(a2)         ;nÑchste Zeile
             addq #1,d7
             cmp 2(a4),d7
             bne.s pg5
pg8          add.l 1(a5,d2.l),d2
             cmp.b #28,(a5,d2.l)
             beq pg
             move 28(a2),d0
             moveq #4,d4            ;Nadeln fÅr Rest
             move -2(a4),d3         ;Nadelzahl
             cmp #8,d3
             beq.s pg9
             moveq #6,d4
pg9          move d4,24(a2)         ;Nadeln fÅr Zeilenrest
             move d3,26(a2)         ;aktuelle Nadelzahl
             move 2(a4),d1          ;hîchstmîgliche Zeilenzahl
             mulu 6(a4),d1          ;* Pufferbreite
             divu d0,d1             ;/ Pixel pro Textzeile
             move.l d1,4(a2)        ;Zeilenabstand beim Auslesen
             move 2(a4),d1          ;36 oder 60 (bei CP-80 nur 24)
             divu d0,d1             ;durch 12 oder 30
             mulu d3,d1             ;mal 8 oder 24
             mulu 6(a4),d1          ;mal Pufferbreite
             move.l d1,32(a2)       ;Offset fÅr Bildzeilenrest
             move.l diskpuff,d1
             move.l d1,a3           ;Quelle
             add.l #$be00,d1
             move.l d1,(a2)         ;Zielpuffer
prg          move 12(a2),22(a2)     ;DurchlÑufe
prg0         moveq #10,d6           ;'CR'
             bsr prtsteu0
             move raza,d5
             moveq #32,d4
             bsr rnd1
             move.l (a2),a1         ;Zielpuffer
             moveq #0,d7            ;PixelzÑhler waagrecht
prg1         move.l a3,a0           ;Quelle
             move 26(a2),d6         ;Nadelzahl
             moveq #7,d5            ;PixelzÑhler Ergebnis
             moveq #0,d4            ;Ergebnis
             move d7,d3
             lsr #3,d3              ;Spaltenoffset (a0,d3.l)=Quellbyte
             ext.l d3
             move d7,d1
             and #7,d1
             eori #7,d1             ;Pixel in der Spalte
prg2         btst d1,(a0,d3.l)      ;Quellbit lesen
             beq.s prg3
             bset d5,d4             ;Bit in Ergebnis setzen
prg3         add.l 4(a2),a0         ;nÑchste Quellzeile
             subq #1,d6             ;nÑchste Nadel
             beq.s prg4             ;alle Nadeln fertig
             subq #1,d5
             bpl.s prg2             ;nÑchste Zeile
             move.b d4,(a1)+        ;Ergebnis Speichern
             moveq #0,d4            ;nÑchstes Byte bei 24-Nadel
             moveq #7,d5
             bra.s prg2
prg4         move.b d4,(a1)+        ;eine Senkrechte fertig
             move -2(a4),d4
             cmp #8,d4
             beq.s prg4a
             cmp 26(a2),d4          ;bei 24-Nadeldrucker werden fÅr
             beq.s prg4a            ;rest zwar nur 6 nadeln benutzt
             move.b #0,(a1)+        ;aber/Spalte mÅssen 3 byte gesandt
             move.b #0,(a1)+        ;werden
prg4a        addq #1,d7             ;nÑchste Senkrechte
             cmp 10(a2),d7
             bne.s prg1             ;Druckzeile noch nicht fertig
prg5         tst.b -(a1)            ;Nullbytes am Ende nicht senden
             beq.s prg5
             addq.l #1,a1
             move.l a1,d7
             sub.l (a2),d7
             ble.s prg7             ;keine Werte
             moveq #100,d6
             bsr prtsteu0           ;Graphikmodus ein
             move d7,d6             ;bytezahl retten
             cmp #8,-2(a4)          ;8 Nadeln ?
             beq.s prg5a
             addq #2,d7             ;bei 24-Nadeldrucker
             divu #3,d7             ;Spaltenzahl angeben
             move d7,d6
             mulu #3,d6
prg5a        move.b d7,d4
             bsr lprint             ;lowbyte Anzahl
             move d7,d4
             lsr #8,d4
             bsr lprint             ;highbyte Anzahl
             pea (a3)
             move.l (a2),a3
             subq #1,d6
prg6         move.b (a3)+,d4        ;Zeile ausgeben
             bsr lprint
             dbra d6,prg6
             move.l (a7)+,a3
prg7         moveq #2,d6
             bsr prtsteu0
             moveq #1,d4
             bsr lprint             ;Vorschub um 1 Pixel
             add.l 4(a4),a3         ;nÑchster Durchlauf
             subq #1,22(a2)         ;noch ein Durchlauf ?
             bne prg0
             move -2(a4),d0         ;Nadelzahl
             cmp 26(a2),d0
             bne.s prpiend
             move 24(a2),26(a2)     ;Restnadelzahl
             moveq #2,d6
             bsr prtsteu0
             moveq #24,d4
             sub 12(a2),d4
             bsr lprint             ;Vorschub um 24 minus Durchl.
             move.l diskpuff,a3
             add.l 32(a2),a3        ;Beginn Zeilenrest
             bra prg
prpiend      moveq #2,d6
             bsr prtsteu0
             moveq #12,d4
             cmp #8,-2(a4)          ;8 Nadeldr. ?
             beq.s prg8
             moveq #6,d4
prg8         sub 12(a2),d4
             bsr lprint             ;restlicher Vorschub
             move.l (a7)+,a2
             moveq #10,d6           ;'CR'
             bsr prtsteu0
             rts

imgadr       moveq #0,d0
             bsr holbz              ;Beginn der richtigen Zeile suchen
             bne.s ia1              ;Bytes
             move.b (a0)+,d0        ;Zeilen
             mulu 12(a3),d0         ;*Bytebreite
             cmp.l d0,d6
             bge.s ia               ;es sind weitere Zeilen zu Åberlesen
             sub d6,d0
             divu 12(a3),d0
             rts                    ;fertig
ia           bsr grzend             ;Zeilenende suchen
             move d1,d0
ia1          sub.l d0,d6
             bne.s imgadr           ;noch d6 Bytes
             tst.b (a0)             ;prÅfen:folgen gleiche Zeilen ?
             bne ok
             tst.b 1(a0)
             bne ok
             addq.l #3,a0           ;0,0,FF Åberlesen
             move.b (a0)+,d0        ;es folgen d0 gleiche Zeilen
             rts

grzend       move 12(a3),d3
             move d0,d1             ;Bytezahl fÅr gleiche Zeilen
ia0          bsr holbz
             sub d0,d3
             bne.s ia0              ;kein Zeilenende
             rts

prtpac       movem.l d2/d7,-(a7)
             moveq #0,d1
             moveq #-1,d5           ;PixelzÑhler
             move 20(a2),d6         ;Maximale Pixelbreite
             move 18(a2),d2         ;Bildbreite
             move 16(a2),d7         ;Pixelabstand
             moveq #7,d4            ;Zielpixel
pp           moveq #0,d3            ;Ergebnis
pp1          addq #1,d5
             cmp d6,d5
             bne.s pp2
             or.b (a1),d3
             move.b d3,(a1)
             movem.l (a7)+,d2/d7
             rts
pp2          move d2,d0             ;Originalbr.
             mulu d5,d0             ;mal ZÑhler
             divu d6,d0             ;Zielbreite
             move d0,d1
             lsr #3,d1              ;Quelle in Byte
             and #7,d0
             eori #7,d0             ;Quellpixel
             btst d0,(a0,d1.l)
             beq.s pp3              ;Bit nicht gesetzt
             bset d4,d3
pp3          sub d7,d4              ;nÑchster Zielbit
             bpl.s pp1
             addq #8,d4
             or.b (a1),d3           ;mit bisherigem Ergebnis verkn.
             move.b d3,(a1)+        ;und zurÅckschreiben
             bra.s pp

 end
 