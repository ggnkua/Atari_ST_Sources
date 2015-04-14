           ilabel tos\tos.l
             move.l 4(a7),a5        ;Start of Basepage
             move.l $c(a5),d7
             add.l $14(a5),d7
             add.l $1c(a5),d7
             add.l #1280,d7         ;FÅr Stack und Basepage
             andi.b #$fe,d7
             lea -104(a5,d7.l),a7
             pea speitop            ;Adresse Bildschirm und Memtop
             move #38,-(sp)
             trap #14               ;base enthÑlt log. Bildspeicher
             adda.l #6,sp
             sub.l #100000,d0
             move.l d0,memtop
             move.l d0,memend
             move.l memtop,datstart
             sub.l #$10000,datstart ;64 K fÅr Datei
             sub.l a5,d0
           setblock d0,(a5)
             move.l a7,a3
             lea vdipb+20,a7        ;VDI und AES-Zeiger setzen
             pea ptsout
             pea intout
             pea ptsin
             pea intin
             pea contrl
             pea addrout
             pea addrin
             pea intout
             pea intin
             pea global
             pea contrl
             pea vdipb
             pea aespb
             move.l a3,a7
           appl_init ap_id
           graf_handle gr_handle
           v_opnvwk work_in,handle,work_out
           getrez
             move d0,rez            ;Auflîsung
             bne.s mem
             lea aufl,a2
             bsr formalert
             bra ende
mem          add.l a5,d7
             move.l d7,diskpuff
             add.l #65536,d7
             move.l d7,druckcod0    ;Beginn Treibercode
             add.l #256,d7
             move.l d7,druckcod1
             add.l #480,d7
             lea txtstart,a0
             moveq #8,d6            ;Start fÅr 8 Texte
ll           move.l d7,(a0)+        ;& Txttop setzen
             dbra d6,ll
             move.l memtop,d0
             sub.l d7,d0
             subq.l #4,d0
             move.l d0,free         ;freier Textspeicher
           logbase
             lea zielbl,a0          ;Zielblock Bittransfer erstellen
             move.l d0,(a0)         ;Bildspeicherbasis
             move rez,d1
             eori #3,d1
             move d1,12(a0)         ;Ebenenzahl fÅr Bitblocktransfer
             move d1,32(a0)
             move #400,d0
             divu d1,d0
             move d0,6(a0)          ;Rasterhîhe
             move #640,4(a0)        ;Breite in Pixel
             move #40,8(a0)         ;und Worten
             bsr setwrmod1
           curdrv                   ;Aktives Laufwerk
             move d0,aktdisk
loadrsc    rsrc_load rscfile,d0
             bne.s baumad
             lea norsc,a2
             bsr formalert          ;Fehler beim Laden des Rsrc-Files
             bra ende
baumad       bsr mausf0
             moveq #0,d7
             lea baum,a5
getaddr    rsrc_gaddr #0,d7,d0,(a5)
             addq #4,a5
             addq #1,d7
             cmp #16,d7
             bne.s getaddr
             moveq #13,d7
             lea baum+8,a5
ncent        move.l (a5)+,a0
           form_center (a0),d0,work_0 ;auûer desk & menÅ zentrieren
             dbra d7,ncent
             move #0,akthand
             moveq #4,d4
             lea work_0,a4
             bsr wiget
             move.l baum+4,a3
             move.l (a4),20(a3)     ;in Desktopformular eintragen
             move.l -(a4),16(a3)
             move 6(a4),d0
             sub #26,d0
             moveq #12,d7
l0           move d0,42(a3)         ;Y-Position der Tasten setzen
             lea 24(a3),a3
             dbra d7,l0
           drvmap                   ;angeschlossene Laufwerke
             move d0,drives
             move d0,d7
             move.l baum+28,a6      ;Fileselektor
             moveq #0,d6
             move.l #48,d5
diskda       btst d6,d7
             bne.s enab             ;Disk nicht vorhanden
             move #8,10(a6,d5.l)    ;disable
enab         add #24,d5
             addq #1,d6
             cmp #16,d6
             bne.s diskda
             move.l 592(a6),slx     ;Sliderkoordinaten
             move.l 596(a6),slw
             lea intin+4,a0
             move.l baum+4,(a0)+
             clr (a0)
             moveq #14,d0
             bsr wiset              ;Desktop anmelden
           form_dial #3,work_0,work_0,d0 ;und darstellen
             move.l baum,a0
           menu_bar #1,(a0),d0      ;Menueleiste aufbauen
             move work_0+2,d4       ;menh
             move work_0+6,d5       ;Maximale Fensterhîhe
             lea fenkoor,a2
             move d4,34(a2)         ;Maûe fÅr Wi_ful
             move d5,38(a2)
             sub #26,d5
             moveq #3,d7
             lea wihand,a5
l00          move d4,2(a2)          ;Maûe fÅr Wind_open
             move d5,6(a2)
           scf_aes 100,5,1,0,0      ;Wind_create
             lea intin,a3
             move #4079,(a3)+
             move.l work_0,(a3)+    ;mit maximalen Maûen anmelden
             move.l work_0+4,(a3)+
           aes
             move intout,(a5)+      ;Wihandle
             subq #8,d5
             addq.l #8,a2
             dbra d7,l00
             lea info,a1
             lea noinfo,a2
             bsr suchfile
             bne.s treiber
             bsr openin             ;Info datei holen
             bne.s treiber
             move.l diskpuff,a0     ;info einlesen
             cmpi.l #$5659,(a0)     ;Info richtig ?
             bne.s treiber
             lea infst,a1
             move.l bytes,d0
             bsr copy1
             bsr closedisk
treiber      move #287,d0           ;Initialisierung Druckercodes
             move.l druckcod0,a0    ;256 Steuercodes +32 öbersetzungen
l4           move.b #1,(a0)+
             dbra d0,l4
             move #223,d0           ;öbersetzungen 32 bis 255
             move.b #32,d1          ;Space
l5           move.b #2,(a0)+
             move.b d1,(a0)+
             addq.b #1,d1           ;nÑchstes Zeichen
             dbra d0,l5
             lea prtfile,a1
             lea noprt,a2
             bsr suchfile
             bne tpuff              ;kein Treiber
             bsr openin             ;Druckertreiber holen
             bne tpuff
             bsr closedisk
             move.l bytes,d0        ;LÑnge Treibertext
             move.l diskpuff,a0
             moveq #0,d7            ;wenn d7=2 -> Treiber fertig
nexwor       move.l a0,a6           ;Zeilenanfang sichern
             lea crlf,a1
             bsr suchwort           ;Zeile holen
             bmi treiberror         ;Fehlerhafter Treiber
             cmpi.b #42,(a6)
             beq.s nexwor           ;Kommentarzeile
             move.l a0,a5           ;momentane Werte sichern
             move.l d0,bytes
             move.l a6,a0
             lea aktwort,a1         ;Ablageort
l7           bsr dezbin             ;nach Zahl suchen
             tst d2
             beq.s l8               ;keine Zahl
             cmp #256,d0            ;Zahlen >255 nicht erlaubt
             bpl treiberror
             move.b d0,(a1)+        ;Zahl speichern
             cmp.b #-6,d1           ;Ende Code ?
             bne.s l7               ;Nein, nÑchste holen
l8           cmp.b #-6,d1
             bne.s treiberror       ;keine Zahl und nicht '*'
             move.l a1,d5
             sub.l #aktwort,d5      ;LÑnge der Eintragung
             moveq #0,d6
             move.b aktwort,d6      ;Nummer
             move.l druckcod0,a0    ;Beginn Codetabelle
             lea druckcod1,a2
             tst d7
             beq.s l9
             move.l druckcod1,a0    ;2. Tabelle nehmen
             addq.l #4,a2
l9           bsr codeort            ;Speicherort und alte LÑnge holen
             move.l a0,a4
             move.b d5,(a4)+        ;LÑnge Speichern
             add.l d0,a0
             sub.l d5,d0            ;LÑngendifferenz
             beq.s eintrag
             neg.l d0
             bsr transfer0
eintrag      lea aktwort+1,a0       ;Code
l10          subq.b #1,d5
             beq.s l11
             move.b (a0)+,(a4)+     ;Åbertragen
             bra.s l10
l11          move.b aktwort,d0
             cmp.b #255,d0
             bne.s l12
             addq #1,d7
             cmp #2,d7
             beq.s treibfert
l12          move.l a5,a0           ;Zeiger zurÅck
             move.l bytes,d0
             bra nexwor
treiberror   lea treibfehl,a2
             move.l a6,a0
             lea 24(a2),a1
             moveq #16,d0
             bsr copy1
             bsr formalert
             bra tpuff
treibfert    bset #3,flag
gerade       lea txtstart,a2
             move.l (a2),d0
             btst #0,d0
             beq.s gra            ;Adressen sind gerade
             subq.l #1,free
meven        addq.l #1,(a2)+
             cmpa.l #txttop,a2
             ble.s meven
gra          move.l baum+52,a1      ;richtige Knîpfe im Formular
             move.l #128,d2         ;Grafik anpassen einschalten
             moveq #101,d7
             lea prttab,a2
             moveq #0,d4
gra0         move d7,d6
             moveq #0,d1
             move d1,d3
             bsr codeort0
gra1         subq #1,d0
             beq.s gra2
             move.b 1(a0),d3
             add d3,d1
             addq.l #1,a0
             bra.s gra1
gra2         lea gradicht,a0
             bsr suchword
             bne.s gra3
             move d1,(a2,d4.l)
             addq #8,d4
             move.l a0,d0
             sub.l #gradicht,d0
             mulu #12,d0
             add.l d2,d0
             move.l #$150000,(a1,d0.l)
             cmp #8,d4
             bne.s gra3
             move #1,2(a1,d0.l)
             move #136,d5
             mulu (a2),d5
             divu #80,d5
             ext.l d5
             move.l d5,4(a2)        ;Zeilenabstand in hîchster Auflîsung
gra3         addq #1,d7
             cmp #106,d7
             bne.s gra0
             moveq #106,d6
             bsr codeort0
             move.b 1(a0),d0
             move d0,-2(a2)         ;Nadelzahl
             moveq #12,d7
             cmp #8,d0
             beq.s gra4
             moveq #30,d7
gra4         move d7,d6
             lsr #1,d6
             moveq #0,d4
gra5         move (a2,d4.l),d0      ;Auflîsung
             beq.s tpuff
             ext.l d0
             divu #6,d0
             ext.l d0
             add d6,d0              ;aufrunden
             divu d7,d0
             bne.s gra6
             moveq #1,d0
gra6         tst d4
             bne.s gra7
             move d0,d3
             bra.s gra8
gra7         move d3,d1
             addq #1,d1
             sub d0,d1
             mulu d5,d1
             move.l d1,4(a2,d4.l)   ;Zeilenabstand im Grafikdruckpuffer
gra8         mulu d7,d0
             move d0,2(a2,d4.l)     ;Grafikzeilen/Druckzeile
             addq #8,d4
             bra.s gra5
tpuff        move #37,fen
             bsr tstrep
prÅtrenn     tst trenn              ;Trennhilfe ?
             bne.s prÅabs           ;ja
             move #40,fen
             bsr mencheck0
prÅabs       tst abs                ;Return=Absatz ?
             beq.s retzei
             move #38,fen
             bsr mencheck1
retzei       tst rzeil
             beq.s ascs
             move #39,fen
             bsr mencheck1
ascs         tst ascsp              ;als Ascii sichern ?
             beq.s schri
             move #23,fen
             bsr mencheck1
schri        cmpi #2,rez
             beq.s schrset
             moveq #74,d5           ;bei mittlerer Auflîsung ist
             moveq #74,d6           ;keine Umschaltung der
             bsr menchange0         ;Schriftgrîûe mîglich
             move #4,schrhî
             move #8,zlabst
             move #6,txth
             bra.s prgst
schrset      move schrhî,d1
             move #36,fen
             bsr zgschr
prgst        bsr txtop
event      kbshift #-1
             and #16,d0
             cmp cap,d0
             beq.s ereignis
             move d0,cap
             moveq #0,d1
             tst d0
             beq.s ev0
             moveq #1,d1
ev0          moveq #1,d2
             bsr deskchange
ereignis     moveq #51,d0
             bsr evmult
             move.l 16(a0),mausx
             btst #4,d7
             bne mesag
             btst #1,d7
             bne.s button
             btst #0,d7
             bne tasten
             btst #2,d7
             bne.s mouse
             lea mx,a1
             tst maus
             bne.s mous             ;Maus ist eingeschaltet
             move (a1),d0
             cmp 16(a0),d0
             bne.s shm              ;x-Position verÑndert
             move 2(a1),d0
             cmp 18(a0),d0
             beq.s mous             ;keine PositionsÑnderung
shm          move #1,maus
             bsr mausan
mous         move.l 16(a0),(a1)     ;Koordinaten Åbertragen
             bra event
mouse        bsr butfree
             bra event
button     wind_find mausx,mausy,d0
             bne welches            ;Fenster gefunden
             move.l baum+4,a0
           objc_find #0,#1,mausx,mausy,(a0),d1
             beq mouse              ;kein Desktopobjekt
butfound     cmp #1,d1
             beq mouse              ;Caps-Lock
             cmp #12,d1
             beq.s einf_Åber
             bhi.s feabs
             tst wiakt
             bmi mouse
             moveq #70,d2
             sub d1,d2              ;d2=59,...,68 (Funktionstastencode)
             bsr ed1                ;Editor aufrufen
             bra mouse
einf_Åber    move #41,fen
             bsr hileinf
             bra mouse
feabs        tst -30(a6)
             beq mouse
             lea aktwort,a0
             bchg #7,(a0)
             bsr plret
             bra mouse
welches      move mausy,d1
             move mausx,d0
             cmp -26(a6),d1         ;ymax
             bhi mouse              ;auûerhalb der ArbeitsflÑche
             lea xmax,a0
             move (a0),d2
             subq #8,d2
             cmp d2,d0              ;xmax
             bhi mouse
             cmp 4(a0),d0           ;xstart
             blt mouse
             sub 4(a0),d0
             lsr #3,d0              ;durch 8 teilen
             add -4(a6),d0
             move d0,kpos
             lea aktwort,a5
             cmp -2(a0),d1          ;horlin
             ble linÑnd             ;Lineal
             bsr butzeile           ;Zeile unter kursor bestimmen
             move d4,nzeile         ;Zeilennummer
             move d2,mausx1         ;y-Position
             moveq #32,d0
             bsr evmult
             tst 20(a0)
             bne.s bilder           ;Button ist noch gedrÅckt
             bsr setkur             ;Kursor versetzen
             bra mouse
bilder       move kpos,d3
             move nzeile,d4
             bsr grafik             ;Grafik unter Pfeil ?
             bne butblock           ;nein
             move -14(a6),index
             lea 5(a0,d2.l),a0
             pea (a0)
             bsr neuhead            ;Kopf erneuern
             move.l (a7)+,a0
             move 8(a0),d5          ;Bildnummer
             bsr bildnr             ;IMG-Adresse holen
             move.l a3,suchadr
             move.l d0,ersadr
             lea mausx,a2
             move (a0),d0           ;kpos
             sub -4(a6),d0          ;first
             lsl #3,d0              ;mal 8
             add xstart,d0
             move d0,(a2)           ;mausx
             move 2(a0),d0          ;Bildbreite
             lsl #3,d0              ;in Pixel
             move d0,4(a2)
             move mausx1,d1         ;ykur der gewÑhlten Zeile
             move 4(a0),d0          ;Zeilennummer in Grafik
             sub d0,d4              ;von Textzeilennummer abziehen
             move d4,zeinr          ;erste Zeile der Grafik
             addq #1,d0
             mulu zlabst,d0
             sub d0,d1
             move d1,2(a2)          ;mausy
             move 6(a0),d0
             addq #1,d0             ;Zeilenzahl der Grafik
             mulu zlabst,d0
             move d0,6(a2)          ;In mausx ist jetzt die Grîûe des
                                    ;Grafikrechteckes gespeichert
             move 4(a0),d0
             cmp 6(a0),d0           ;letzte Grafikzeile ?
             bne.s bildmov
             move (a0),d0
             add 2(a0),d0
             cmp kpos,d0            ;Bytebox ganz rechts unten ?
             bne.s bildmov
             bsr growbild           ;Bildgrîûe Ñndern
             bra event
bildmov      bsr movbild            ;Bild bewegen
             bra event
linÑnd       bsr linec              ;Lineal Ñndern
             bra mouse
butblock     bsr blockset           ;Block markieren
             bra event
mesag        lea fen,a1
             move (a0),d0
             move 6(a0),d7          ;menÅ-titel,wihandle
             move.l 8(a0),(a1)      ;objekt-index,x/y usw
             move.l 12(a0),4(a1)    ;breite/hîhe
             cmp #10,d0
             bne fenst
             move d7,mentit
             cmp #3,d7              ;MenÅinfo ?
             beq copyr
jump         tst wiakt
             bmi.s jup
             bsr zeilÅ
jup          move fen,d0
             sub #20,d0             ;20=Text îffnen
             lea jumptab0,a0        ;Basis der Sprungtabelle
             bsr indjump            ;Programmteil anspringen
             tst wiakt
             bmi.s mennorm
             bsr aktzeile
mennorm      move.l baum,a0
           menu_tnormal mentit,#1,(a0),d0
             bra mouse
copyr        lea ha,a2
             bsr formalert          ;Meldung von wem
             bra.s mennorm
fenst        bsr fenhandle
             bne mouse              ;kein Programmfenster
             move mbuff,d0
             sub #20,d0             ;20=Redraw
             beq.s fnst
             move d0,-(a7)
             bsr zeilÅber
             move (a7)+,d0
fnst         lea jumptab1,a0
             bsr indjump
             bra event
tasten       btst #2,23(a0)
             beq.s tst0
             and.l #255,d2
             subq #1,d2
             cmp #25,d2
             bhi event
             tst wiakt
             bpl.s tst3
             cmp.b #6,d2
             beq.s tst4
             cmp.b #14,d2
             beq.s tst4
             cmp.b #16,d2
             beq.s tst4
             bra event
tst3         bsr zeilÅ
tst4         move d2,d0
             lea jumptab5,a0
             bsr indjump
             tst wiakt
             bmi event
             bsr aktzeile
             bra event
tst0         bsr editor
             bra event

prgend       moveq #6,d6
             lea txtstart,a0
pe           addq #1,d6
             cmp #9,d6
             beq.s svdt
             move.l (a0)+,a1
             cmp.l (a0),a1
             beq.s pe
             tst 62(a1)
             beq.s pe
             tst 62(a1)
             beq.s pe
             lea fin,a2             ;Programm beenden
             bsr formalert
             beq mennorm
svdt         tst verwnam
             beq.s finis
             bsr savedat
finis        move.l baum,a6
           menu_bar #0,(a6),d0      ;MenÅleiste lîschen
           rsrc_free d0             ;Rsc-Speicher freigeben
             moveq #4,d7
             lea wihand,a6
del        wind_delete (a6),d0
             addq.l #2,a6
             dbra d7,del
ende       gem_exit

           include MIN_VERW.Q
           include MIN_EDIT.Q
           include MIN_DISK.Q
           include MIN_SUB1.Q
           include MIN_SUB2.Q
           include MIN_SUB3.Q
           include MIN_TEXT.Q
           include MIN_BLOC.Q
           include MIN_EXTR.Q

 DATA 
 align
jumptab0   dc.l txtop,txtsi,txtsias,txtasc,ret,prginfo,ret
           dc.l dislosch,datinf,ordner,renam,ret,prgend,ret
           dc.l hilkopf,ret,hilpix,hilpuf,hilabs,hilrzei,extrenn
           dc.l hileinf,ret,hilzenz,hilord,hileinr,hillink,hilzent,hilblo
           dc.l ret,txtwahl,txtlay,txtsuch,txtdruck,txtzeilab,txtpic
           dc.l ret,gozeil,blgosei,ret,txtklsei,txtkltxt,txtkltab,ret
           dc.l bloanf,bloend,ret,blolad,blosich,blodruck,bloord
           dc.l blover,blokop,bllosch,ret,bldemark,blgoblan,blgoend,ret
           dc.l exflos,extast,statprg,ret,exbrief,exaufn,exsuch
jumptab1   dc.l redraw,topped,wiclose,full,arrow,hslid,vslid
           dc.l size,wimove
jumptab3 dc.l sidup,siddown,zeilup,zeildown,sidleft,sidright,spalleft
         dc.l spalright
jumptab4 dc.l edret,fu1,fu1,fu1,fu4,fu4,fu6,fu6,fu6,fu6,fu10
         dc.l edret,edret,clrho,pfauf,edret,minus,pfli,edret,pfre
         dc.l plus,edret,pfab,edret,insert,delete
jumptab5 dc.l txtzeilab,bloanf,blokop,blodruck,bloend,txtsuch,hilpix,ret
         dc.l hileinr,ret,hilkopf,txtlay,bldemark,hilord,txtop,txtdruck
         dc.l prgend,suchrep,txtsi,hilein,hileinf,blover,txtwahl
         dc.l ret,ret,hilzenz
steuer0    dc.b 8,1,4,128,64,10,12,17,6
           dc.b 20,24,28,32,36,60,64,68,72
notast     dc.b 13,14,27,28,41,53,54,55,58,59,0,0
infst      dc.l $5659
tastbel dc.b 27,"1234567890û'",28,29,"qwertzuiopÅ+",13,1,"asdfghjklîÑ#"
       dc.b 1,"~yxcvbnm,.-",1,1,1,32,"<",30,31,"()/*7894561230.",13,0
      dc.b 27,33,34,"›$%&/()=?`",28,29,"QWERTZUIOPö*",13,0,"ASDFGHJKLôé^"
       dc.b 0,"|YXCVBNM;:_",0,0,0,32,62,30,31,"()/*7894561230.",13
      dc.b 27,0,0,0,0,0,0,0,0,0,0,0,0,28,29,0,0,0,229,0,0,237,0,0,227,64,0
      dc.b 13,0,224,231,235,0,0,233,196,0,230,"[]",0,0,0,0,0,189,194,225
       dc.b 0,0,0,0,0,0,0,0,32,0,30,31,"()/*7894561230.",13
      dc.b 27,0,0,0,0,0,0,0,0,0,0,0,0,28,29,0,0,238,228,0,0,236,0,0,0
       dc.b "\",0,13,0,0,0,0,0,0,0,0,0,0,"{}",0,0,0,0,234,226,0,0,0
       dc.b 0,0,0,0,0,0,0,32,0,30,31,"()/*7894561230.",13
 align
floskeln   dc.b "Dies ist eine Probe fÅr die Floskeltasten"
           ds.b 25
           dc.b "Floskeltaste Nr. 2"
           ds.b 580
futas      dc.b 0,0,0,0,0,0,1,0,0,0   ;Zustand der Desktasten
           ds.b 10
 align
extent dc.b "\*.TXT",0,0,"\*.DOC",0,0,"\*.TAB",0,0,"\*.IMG",0,0,"\*.*",0,0,0,0
       dc.b "\*.DAT",0,0,"\*.",0,0,0,0,0,"\*.",0,0,0,0,0,"\*.",0,0,0,0,0
extnr      dc.l 0,40,24,32
trenn      dc.w 1
abs        dc.w 1
rzeil      dc.w 0
tstpu      dc.w 1
ascsp      dc.w 0
lin        dc.w 1
schrhî     dc.w 6
seitenm    dc.l 70,2,3,2,5,10,5,0
txtdefvar  dc.w 0,0,0,58,1,1,2,1,1,65,0,2,1,2,1,0,0,0,0,0
ueber0     dc.b 0,8,0,0,0,2,0,65,6,0
           dc.b 0,8,0,0,0,2,0,65,6,0
neuzeil    dc.b 0,8,0,0,0,2,0,65,6,0
grazeil dc.b 0,24,0,0,0,2,0,136,6,28,0,0,0,16,0,0,0,0,0,0,0,0,0,0,28,0
autodat    dc.w 0
verwkn     dc.w 4,7,10,11,12,13,15,16,17,18,19,22,23
verwlist   dc.w 5,11,6,20,8,6,9,4,4,11,7,54,10,7,11,47,12,60,13,60,0
mench      dc.w 76,75,77,68,69,70,73,71,72,21,22,23,50,53
           dc.w 34,37,38,39,41,43,44,45,46,47,48,51
           dc.w 52,54,55,57,58,60,61,62,64,65,67,36
fenkoor    dc.w 0,19,616,360
           dc.w 16,19,608,350
           dc.w 32,19,600,340
           dc.w 48,19,592,330
           dc.w 0,19,640,380
wiop       dc.l -1,-1,-1,-1  ;sel eintragen
maus       dc.w 1
wiakt      dc.w -1
wiarb      dc.w -1
sel        dc.l -1
psel       dc.l -1
blan       dc.w -1
blen       dc.w -1
blanx      dc.w -1
blenx      dc.w -1
blsel      dc.l -1
maus1      dc.w 1
mflag      dc.w 55
firstzei   dc.w 2
zlabst     dc.w 12
crlf       dc.b 13,10,0
trennzei   dc.b " !,-.:;?~",0
vokal      dc.b "AaEeIiOoUuYyéÑôîöÅ",0
konson     dc.b "BbCcDdFfGgHhJjKkLlMmNnPpQqRrSsTtVvWwXxZzû",0
txth       dc.w 6
 align
gradicht   dc.w 60,80,90,120,180,240,360,0
doppelv    dc.b "ieaaeeooauaieieuÑuioou",0,0
doppelk    dc.b "blbr",0,0
           dc.b "sch",0
rscfile    dc.b "MINITEXT.RSC",0,0
info       dc.b "MINITEXT.INF",0,0
prtfile    dc.b "PRT?????.COD",0
txtnam     dc.b " Text: ",0
dtinf      dc.b " Info zu: ",0
einr       dc.b " EinrÅckung:     ",0
schr8      dc.b " Kleinschrift       ^ G",0
schr16     dc.b " Groûschrift        ^ G",0
abseit     dc.b "ab Seite ",0
abzeil     dc.b "ab Zeile ",0
 align
filesel    dc.b "     Text laden     ",0
           dc.b "     Bild laden     ",0
           dc.b "    Text sichern    ",0
           dc.b "   Datei lîschen   ",0,0
           dc.b "  Datei umbenennen  ",0
           dc.b " Ordner einrichten ",0,0
           dc.b "  Datei-Info holen  ",0
           dc.b "  Verwaltung laden  ",0
tabul dc.b "[..................................................................."
      dc.b "...................................................................."
      dc.b "....................................................................]",0
aufl dc.b "[3][Falsche Auflîsung | |Mittlere Auflîsung einstellen|und neu starten][ OK ]",0
fin        dc.b "[2][|énderungen sichern ?][ Ja |Nein]",0
norsc dc.b "[3][  - MINITEXT.RSC -| |kann nicht geladen werden.][Abbruch]",0
noinfo     dc.b "[1][| | Info-Datei fehlt][ OK ]",0
noprt      dc.b "[1][|Druckertreiber fehlt][ OK ]",0
treibfehl  dc.b "[1][ |Treiberfehler bei|                 ][ OK ]",0
ha       dc.b "[1][|Entwurf und AusfÅhrung| |   Bernd Hofmann][ OK ]",0
besetzt    dc.b "[3][|Alle DatensÑtze sind belegt][ OK ]",0
nowin      dc.b "[3][|Alle Fenster sind belegt][ OK ]",0
neutxt     dc.b "[1][| | Neues Dokument !][ OK |Abbruch]",0
readerr    dc.b "[3][Fehler beim îffnen|oder lesen der Datei][ OK ]",0
nofile     dc.b "[1][Datei wurde nicht gefunden][ OK ]",0
ramfull    dc.b "[3][Nicht genug Platz| |fÅr diese Zeile][ OK ]",0
nobl dc.b "[3][Bitte, in Grafiken| |keine Blockoperationen][ OK ]",0
schiebe dc.b "[3][Ein Block lÑût sich nicht| |in sich selbst verschieben][ OK ]",0
voll       dc.b "[3][|Zu wenig Speicherplatz][ OK ]",0
asclad dc.b "[2][Falsches Textformat| |als ASCII-Text laden ?][ Ja |Nein]",0
operr      dc.b "[3][Fehler beim ôffnen der Datei][ OK ]",0
nograf     dc.b "[1][Ausschnitt wurde nicht gefunden][ OK ]",0
ohngraf dc.b "[3][Nur Texte ohne Grafik| |kînnen zugeladen werden][ OK ]",0
auflî dc.b "[3][|Dieses Bild wurde in anderer|Auflîsung erstellt][ OK ]",0
neublatt dc.b "[1][Bitte ein neues Blatt| |in den Drucker einfÅhren][ OK ]",0
wenden dc.b "[1][Vorderseite ist Åbertragen| |Bitte, BlÑtter wenden][ OK ]",0
nodruck dc.b "[3][Drucker ist nicht bereit !|Bitte, ÅberprÅfen][ OK |Abbruch]",0
notreib    dc.b "[3][|Druckertreiber fehlt !][Abbruch]",0
drstop     dc.b "[2][| | Ausdruck abbrechen ?][Abbruch|Weiter]",0
suchweit   dc.b "[2][| | Weiter suchen ?][ Ja |Nein]",0
ersetze dc.b "[2][|        Ersetzen ?        ][  Ja  | Nein |Abbruch]",0
suchend    dc.b "[1][|  Fertig ! ][ OK ]",0
killtxt    dc.b "[2][|Ganzen Text lîschen ?][ Ja |Nein]",0
kills      dc.b "[2][|Ganze Seite lîschen ?][ Ja |Nein]",0
diegraf    dc.b "[2][| | Dieses Bild ?][ Ja |Nein]",0
neuverw    dc.b "[1][| | Neue Datei !][ OK |Abbruch]",0
nichtda    dc.b "[1][| |  Nicht gefunden !][ OK ]",0
blgr dc.b "[3][|Block ist zu groû !][ OK ]",0
hardd      dc.b "HARDDISK",0,0,0,13,10
 align
 BSS
mx         ds.l 1
wihand     ds.w 5
work_0     ds.w 4
work_arb   ds.w 4
akttab     ds.b 264
grkl       ds.w 1
idfl       ds.w 1
allfl      ds.w 1
suchadr    ds.l 1
ersadr     ds.l 1
aktdisk    ds.w 1
drives     ds.w 1
diskhand   ds.w 1
dta        ds.l 1
bytes      ds.l 1
rest       ds.l 1
txtzg      ds.l 1
filezg     ds.l 1
slx        ds.w 1
sly        ds.w 1
slw        ds.w 1
slh        ds.w 1
mausf      ds.w 1
erstobj    ds.w 1
editobj    ds.w 1
index      ds.w 1
inindex    ds.w 1    ;Index Text
stellen    ds.w 1    ;Stellenzahl fÅr Bin-Stringwandlung
baumnr     ds.l 1
baumadr    ds.l 1
cap        ds.w 1
mbuff      ds.w 16
puffer     ds.l 256 ;Arbeitsspeicher
kopfz      ds.b 300
fuûz       ds.b 300
fen        ds.w 6
rez        ds.w 1   ;Auflîsung
base       ds.l 1   ;Startadresse Bildspeicher
zielbl     ds.w 10  ;Blocktransfer
quellbl    ds.w 10
aktwort    ds.b 4096;Puffer fÅr aktuelle Textzeile
leer       ds.b 80
baum       ds.l 30
diskpuff   ds.l 1
nadeln     ds.w 1
prttab     ds.w 22  ;5*8 Byte fÅr Auflîsungen + Endemarke
druckcod0  ds.l 1
druckcod1  ds.l 1
txtstart   ds.l 8   ;8 Marken Dateibeginn
txttop     ds.l 1   ;Ende benutzter Textspeicher
aktbeginn  ds.l 1   ;Start aktueller Textspeicher
aktend     ds.l 1   ;Dito Ende
free       ds.l 1   ;freier Speicherraum = memtop-txttop
fenster    ds.b 240 ;Fensternamen
name       ds.b 482 ;Dateinamen 8*60 Byte
datstart   ds.l 1   ;Beginn Verwaltungsdatei
memtop     ds.l 1   ;Grenze fÅr txttop
memend     ds.l 1   ;absolute Speichergrenze
pfad       ds.b 48
verwnam    ds.b 60
vdatnam    ds.b 14
datei      ds.b 60
cliparr    ds.w 4
clplst     ds.w 4
akthand    ds.w 1
mentit     ds.w 1
opnfl      ds.w 1
;Maûe fÅr Fensterverwaltung
mausx      ds.w 1
mausy      ds.w 1
           ds.w 2
mausx1     ds.w 1
mausy1     ds.w 1
moment     ds.w 4  ;Zwischenspeicher Fenstervariablen
seitx      ds.w 1
vertlin    ds.w 1
horlin     ds.w 1
xmax       ds.w 1
ymax       ds.w 1
xstart     ds.w 1
ystart     ds.w 1
xkur       ds.w 1
ykur       ds.w 1
xkur1      ds.w 1
ykur1      ds.w 1
fenbr      ds.w 1
fenho      ds.w 1
fenauf     ds.w 32
xres       ds.w 1
horsch     ds.w 1
scrh       ds.w 1
scrv       ds.w 1
altgr      ds.w 1
altpos     ds.w 1
;Textverwaltung
lentxt     ds.l 1  ;LÑnge der Textzeile
lenasc     ds.w 1  ;Zahl der Ascii-Zeichen
kptxt      ds.l 1  ;absolute Kursorposition
kpos       ds.w 1  ;Zwischenspeicher Kursorposition
nzeile     ds.w 1  ;Nummer der neuen Zeile
zeinr      ds.w 1  ;Nummer des Zeichens,das ausgegeben wird
zeile      ds.w 1  ;Ablage fÅr aktuelle Zeilennummer
zeirest    ds.l 1  ;LÑnge Zeilenrest bei Zeilenumbruch abs.
ascrest    ds.w 1  ;LÑnge Zeilenrest in ASCII-Zeichen
absatz     ds.w 1
yversatz   ds.w 1  ;Versatz fÅr Indexschriften
trfl       ds.w 1  ;Flag fÅr Trennmîglichkeit
wrfl       ds.w 1
;MenÅverwaltung
einrÅ      ds.w 1
blocks     ds.w 1
zentr      ds.w 1
flag       ds.w 1
;Drucken
abst       ds.w 1
nlq        ds.w 1  ;nlq=2 dann LetterqualitÑt
einzel     ds.w 1  ;Einzelblatt
zweis      ds.w 1  ;zweiseitig drucken
erste      ds.w 1  ;erste Druckseite
letzte     ds.w 1  ;letzte Druckseite
exemp      ds.w 1  ;Exemplare
prt        ds.w 1  ;Drucker bereit ?
aktseite   ds.w 1  ;Nr der Druckseite
druckad    ds.l 1  ;Adresse der Druckzeile
druckl     ds.l 1  ;LÑnge derselben
raza       ds.w 1  ;Randgrîûe
kopf       ds.l 1  ;Adresse Kopfzeile
fuû        ds.l 1  ;Adresse Fuûzeile
slen       ds.w 1
nxtstart   ds.l 1  ;Beginn nÑchster Text
zeilhî     ds.w 1  ;Hîhe aktuelle Zeile
 end
 