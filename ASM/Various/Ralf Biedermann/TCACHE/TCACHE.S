* festplattencache
* ralf biedermann nach einer idee von
* julian reschke
                TEXT
                OUTPUT 'C:\AUTO\TCACHE.PRG'
                OPT F+
                >PART 'konstanten'
;ID Speed Cache Ralf Biedermann
id              EQU 'SCRB'
hdv_rw          EQU $00000476
                ENDPART
                >PART 'initialisieren'
anfang:         bra     start
;cache initialisieren
init:           clr.w   (A6)+           ;drive lîschen
                dbra    D0,init
;fÅr ptermres vorbereiten
                moveq   #0,D0           ;lÑnge des cachespeichers holen
                move.w  memory(PC),D0
                add.l   #2,D0           ;wegen dbra korigieren +1 sicher ist sicher
                lsl.l   #8,D0           ;*512
                add.l   D0,D0
                movea.l cache_adr(PC),A6 ;adresse des speicher fÅr die sektoren
                adda.l  D0,A6           ;ende des benutzten speichers
                move.l  A6,puffer       ;puffer fÅr vorhersehendes lesen
                adda.l  #$00001000,A6   ;4K sollten reichen
                clr.w   -(SP)
                suba.l  basepage(PC),A6 ;zu reservierenden speicher berechnen
                move.l  A6,-(SP)
;neuen vektor einbinden
                pea     xbrainit(PC)
                move.w  #$0026,-(SP)    ;supexec
                trap    #$0E            ;XBIOS
                addq.l  #6,SP
;programm verlassen aber resident halten
                move.w  #$0031,-(SP)    ;Ptermres
                trap    #1              ;GEMDOS
                illegal                 ;damit im falle eines fehlers kein unglÅck passiert
;vektor mit xbra einbinden
xbrainit:       movea.l hdv_rw.w,A0     ;alte adresse der r/w-adress
                lea     old_adr(PC),A6  ;speicher fÅr alte adresse
                move.l  A0,(A6)         ;alte adresse merken
xbra_loop:      cmpi.l  #'XBRA',-12(A0) ;xbra-protokoll vorhanden
                bne.s   xbra_exit       ;nein
                move.l  -8(A0),D0       ;alte xbra-id
                cmp.l   id_space(PC),D0 ;ist xbra von scache
                bne.s   xbra_eloop      ;nein
                lea     text_sd(PC),A6  ;text ausgeben das scache schon da ist
                bra     abbort          ;abbrechen
xbra_eloop:     movea.l -4(A0),A0       ;zeiger auf nÑchsten xbra
                bne.s   xbra_loop
xbra_exit:      lea     new_adr(PC),A0  ;neue r/w-adresse
                move.l  A0,hdv_rw       ;in hdv_rw einbinden
                rts
                ENDPART
                >PART 'eigentliche cache routinen'
;einige variablen
puffer:         DC.L 0
space:          DC.L 0,0,0,0            ;einige freie plÑtze
register:       DS.L 16                 ;platz um register zu sichern
basepage:       DC.L 0                  ;adresse erstes byte nach ende tpa
cache_adr:      DC.L 0                  ;adresse des cachespeichers fÅr die sektoren
cache_count:    DC.L 0                  ;adresse des cachespeichers fÅr die zÑhler
cache_drive:    DC.L 0                  ;adresse des cachespeichers fÅr das laufwerk
count:          DC.L 0                  ;zÑhler fÅr cachebelegung
prefetch:       DC.W 4                  ;ziemlich gut fÅr megafile30
drv_map:        DC.W %0000000000111100  ;alle unterstÅtzten laufwerke nur CDEF
memory:         DC.W $0040              ;benutzter speicher 64 kbyte
cache_adress:   DC.L 0
flag:           DC.W 0
no_update:      DC.L 0
reads:          DC.L 0
hits:           DC.L 0
writes:         DC.L 0
                DC.B 'XBRA'
id_space:       DC.L id
old_adr:        DC.L 0
new_adr:        tst.w   flag            ;aktiv?
                bne.s   no_cache        ;nein
                moveq   #15,D1          ;max 16 laufwerke
                and.w   $000E(SP),D1    ;laufwerk holen
                move.w  drv_map(PC),D0  ;unterstÅtzte laufwerke holen
                btst    D1,D0           ;wird dieses laufwerk unterstÅtzt
                beq.s   no_cache        ;nein
                move.w  $000A(SP),D1    ;sektorcount = 0
                beq.s   no_cache        ;ja
                move.w  4(SP),D0        ;rwflag
                btst    #3,D0           ;absolut oder relativ
                beq.s   cache           ;nur relativ wird unterstÅtzt
                and.w   #1,D0           ;write ?
                beq.s   no_cache        ;nein
;cache lîschen nur beim schreiben
                move.w  memory(PC),D1
                lea     start(PC),A0
clr_loop:       clr.w   (A0)+           ;sektoradresse lîschen
                dbra    D1,clr_loop
no_cache:       movea.l old_adr(PC),A0
                jmp     (A0)
cache:          movem.l D2-D7/A1-A6,register
                and.w   #1,D0           ;read oder write
                bne     write           ;write
;lesen
                addq.l  #1,reads
                cmpi.w  #1,D1           ;count = 1
                bne.s   no_cache        ;wird nicht unterstÅtzt
                addq.l  #1,count        ;zÑhler erhîhen
                move.w  $000C(SP),D2    ;sektornummer
                beq.s   no_cache
                move.w  $000E(SP),D3    ;drive
                bsr     search
                bne     read_new
                addq.l  #1,hits
                move.l  count(PC),(A2)  ;sektor mit count markieren
                movea.l 6(SP),A0        ;pufferadresse
                move.l  A0,D0           ;zieladresse
                and.w   #1,D0           ;gerade ?
                bne.s   copy_one_odd    ;nein
;nur einen sektor langwortweise kopieren
copy_one_even:  bsr.s   copy_even
no_error:       movem.l register(PC),D2-D7/A1-A6
                moveq   #0,D0
                rts
;nur einen sektor byteweise kopieren
copy_one_odd:   bsr.s   copy_odd
                moveq   #0,D0
error:          movem.l register(PC),D2-D7/A1-A6
                rts
;einen sektor langwortweise kopieren ziemlich schnell
copy_even:
regs            REG D0-D7/A1-A2/A4-A6
regs1           REG D0-D7/A4-A6
                movem.l (A3)+,regs
                movem.l regs,(A0)
                movem.l (A3)+,regs
                movem.l regs,$0034(A0)
                movem.l (A3)+,regs
                movem.l regs,$0068(A0)
                movem.l (A3)+,regs
                movem.l regs,$009C(A0)
                movem.l (A3)+,regs
                movem.l regs,$00D0(A0)
                movem.l (A3)+,regs
                movem.l regs,$0104(A0)
                movem.l (A3)+,regs
                movem.l regs,$0138(A0)
                movem.l (A3)+,regs
                movem.l regs,$016C(A0)
                movem.l (A3)+,regs
                movem.l regs,$01A0(A0)  ;einen kompletten Sektor Åbertragen
                movem.l (A3)+,regs1
                movem.l regs1,$01D4(A0)
                lea     512(A0),A0
                rts

;einen sektor byteweise kopieren nicht ganz so schnell
copy_odd:       moveq   #$1F,D0
copy_odd_loop:  REPT 16
                move.b  (A3)+,(A0)+
                ENDR
                dbra    D0,copy_odd_loop
                rts

;suchen ob der gesuchte sektor schon im cache ist
search:         move.w  memory(PC),D0
                lea     start(PC),A0
                movea.l cache_drive(PC),A1
search_loop:    cmp.w   (A0)+,D2        ;vergleich ob sektornummer stimmt
                dbeq    D0,search_loop
                bne.s   search_exit
                move.w  memory(PC),D4   ;anzahl der sektoren-1
                sub.w   D0,D4           ;anzahl der durchsuchten sektoren
                add.w   D4,D4           ;2 byte pro eintrag
                cmp.w   0(A1,D4.w),D3   ;ist der sektor auch auf diesem drive
                dbeq    D0,search_loop
                bne.s   search_exit
                subq.l  #2,A0           ;adresse sektornummer
                adda.w  D4,A1           ;adresse drive
                movea.l cache_count(PC),A2
                movea.l cache_adr(PC),A3
                add.w   D4,D4           ;*4
                adda.w  D4,A2           ;adresse auf count fÅr diesen sektor
                ext.l   D4
                lsl.l   #7,D4           ;*512
                adda.l  D4,A3           ;adresse auf cacheadresse
                moveq   #0,D0
search_exit:    rts

;den Ñltesten sektor im cache suchen um ihn zu Åberschreiben
;oder falls vorhanden einen freien platz suchen
search_old:     move.w  memory(PC),D1
                movea.l cache_count(PC),A2
                lea     start(PC),A0
                moveq   #-1,D0
search_old_loop:tst.w   (A0)+           ;ist platz belegt ?
                beq.s   search_frei     ;nein
                cmp.l   (A2)+,D0
                bcs.s   ist_neuer
                move.w  D1,D5
                move.l  -4(A2),D0
ist_neuer:      dbra    D1,search_old_loop
                lea     start(PC),A0
                movea.l cache_drive(PC),A1
                movea.l cache_count(PC),A2
                movea.l cache_adr(PC),A3
                moveq   #0,D4
                move.w  memory(PC),D4
                sub.w   D5,D4           ;nummer des gefundenen eintrages
                add.w   D4,D4
                adda.w  D4,A0           ;adresse der nummer
                adda.w  D4,A1           ;adresse des drives
                add.w   D4,D4
                adda.w  D4,A2           ;adresse von count
                lsl.l   #7,D4
                adda.l  D4,A3           ;adresse vom block
                rts
search_frei:    move.w  memory(PC),D4
                subq.l  #2,A0           ;platz fÅr drive
                sub.w   D1,D4           ;nummer des eintrages
                add.w   D4,D4
                movea.l cache_drive(PC),A1
                adda.w  D4,A1           ;adresse des drives
                movea.l cache_adr(PC),A3
                ext.l   D4
                lsl.l   #8,D4           ;*512
                adda.l  D4,A3           ;adresse des speicherbereichs
                rts

;neuen sektor lesen und in cache eintragen
read_new:       movea.l SP,A0
                move.l  $000C(A0),-(SP) ;sektornummer und drive
                move.w  prefetch(PC),-(SP) ;anzahl der zu lesenden sektoren
                move.l  puffer(PC),-(SP) ;pufferadresse
                move.w  4(A0),-(SP)     ;rwflag
                movea.l old_adr(PC),A0  ;alte routine
                jsr     (A0)
                lea     $000C(SP),SP    ;stack korigieren
                tst.l   D0              ;fehler?
                bne.s   read_new_one    ;ja nochmal einfach versuchen
;zuerst den sektor ans programm Åbergeben
                movea.l puffer(PC),A3   ;adresse vom ersten sektor
                movea.l 6(SP),A0        ;adresse des programmpuffers
                move.l  A0,D0
                and.w   #1,D0           ;gerade oder ungerade adresse
                beq.s   read_new_even   ;gerade
                bsr     copy_odd        ;ungerade kopieren
                bra.s   read_new_cache  ;sektoren in cache eintragen
read_new_even:  bsr     copy_even       ;gerade kopieren
;jetzt alle sektoren in cache eintragen
read_new_cache: move.w  prefetch(PC),D7 ;anzahl der gelesenen sektoren-1
                subq.w  #1,D7
                movea.l puffer(PC),A5   ;pufferadresse fÅr ersten sektor
                move.w  $000C(SP),D2    ;sektornummer
                move.w  $000E(SP),D3    ;drive
                bra.s   read_new_loop0  ;der erste ist nicht im cache
read_new_loop:  bsr     search          ;ist sektor eventuell schon in cache
                beq.s   read_new_loop1  ;ja
read_new_loop0: bsr     search_old      ;Ñltesten sektor suchen
read_new_loop1: addq.l  #1,count        ;zÑhler erhîhen
                move.w  D2,(A0)         ;sektornummer in cache eintragen
                move.w  D3,(A1)         ;drive in cache eintragen
                move.l  count(PC),(A2)  ;count in cache eintragen
                movea.l A3,A0           ;hier soll der inhalt hin
                movea.l A5,A3           ;hier stehen die daten
                movem.l D2-D3/D7,-(SP)
                bsr     copy_even       ;sektor kopieren
                movem.l (SP)+,D2-D3/D7
                movea.l A3,A5           ;adresse des nÑchsten sektors
                addq.w  #1,D2           ;nummer des nÑchsten sektors
                dbra    D7,read_new_loop
                moveq   #0,D0           ;keine fehler
                movem.l register(PC),D2-D7/A1-A6
                rts                     ;zurÅck
read_new_one:   movea.l SP,A0
                move.l  $000C(A0),-(SP) ;sektornummer und drive
                move.l  $0008(A0),-(SP) ;low-adress und count
                move.l  $0004(A0),-(SP) ;rwflag und high-adress
                movea.l old_adr(PC),A0  ;sektor lesen
                jsr     (A0)            ;alte routine
                lea     $000C(SP),SP    ;stack korigieren
                tst.w   D0              ;fehler
                bne     error           ;ja
                bsr     search_old      ;platz suchen um sektor einzutragen
                move.w  $000C(SP),(A0)  ;sektornummer in cache eintragen
                move.w  $000E(SP),(A1)  ;drive in cache eintragen
                move.l  count(PC),(A2)  ;count in cache eintragen
                movea.l A3,A0           ;adresse im cache
                movea.l 6(SP),A3        ;pufferadresse
                move.l  A3,D0           ;ist pufferadresse gerade
                and.w   #1,D0
                bne     copy_one_odd    ;nein
                bra     copy_one_even   ;ja

;sektor(en) schreiben
write:          addq.l  #1,writes
                cmp.w   #1,D1           ;count 1 ?
                beq.s   write_one       ;ja

;mehrere sektoren schreiben
;alle zu schreibenden sektoren aus cache entfernen
                move.w  $000C(SP),D2    ;sektornummer
                move.w  $000E(SP),D3    ;drive
writem_loop:    bsr     search          ;sektor im cache suchen
                bne.s   writem_loop1    ;nicht gefunden
                clr.w   (A0)            ;lîschen
writem_loop1:   addq.w  #1,D2           ;nÑchste sektornummer erstellen
                subq.w  #1,D1
                bne.s   writem_loop
                bra     no_cache

;einen sektor schreiben
;zuerst testen ob sektor in cache
;wenn ja prÅfen ob Åberhaupt verÑndert
write_one:      clr.l   space           ;lîschen fÅr nohit
                move.w  $000C(SP),D2    ;sektornummer
                beq     no_cache        ;sektor 0 (bootsektor) wird nicht gepuffert
                move.w  $000E(SP),D3    ;drive
                bsr     search          ;sektor suchen
                bne.s   write_oneoc     ;schreiben ohne cache
                movem.l A0/A2,space     ;adressen sichern falls fehler
                movea.l $0006(SP),A0    ;pufferadresse
                move.l  A0,D1           ;testen ob adresse gerade
                and.w   #1,D1
                bne.s   wo_loop_odd     ;ungerade
                moveq   #127,D0         ;128 langworte
                movem.l A0/A3,space+8   ;sichern fÅr spÑter
wo_loop:        cmpm.l  (A0)+,(A3)+     ;puffer mit cache vergleichen
                dbne    D0,wo_loop
                tst.w   D0
                bpl.s   wo_loop1
                addq.l  #1,no_update    ;einen sektor gespart
                bra     no_error
wo_loop1:       movem.l space+8(PC),A0/A3 ;register wiederholen
                exg     A0,A3           ;quelle und ziel vertauschen
                bsr     copy_even       ;einen sektor kopieren
                bra.s   write_oneoc     ;doch schreiben
wo_loop_odd:    move.w  #511,D0         ;128 langworte
                movem.l A0/A3,space+8   ;sichern fÅr spÑter
wo_loop2:       cmpm.b  (A0)+,(A3)+     ;puffer mit cache vergleichen
                dbne    D0,wo_loop2
                tst.w   D0
                bpl.s   wo_loop3
                addq.l  #1,no_update    ;einen sektor gespart
                bra     no_error
wo_loop3:       movem.l space+8(PC),A0/A3 ;register wiederholen
                exg     A0,A3           ;quelle und ziel vertauschen
                bsr     copy_odd        ;einen sektor kopieren
write_oneoc:    movea.l SP,A0
                move.l  $000C(A0),-(SP) ;sektornummer und drive
                move.l  $0008(A0),-(SP) ;low-adress und count
                move.l  $0004(A0),-(SP) ;rwflag und high-adress
                movea.l old_adr(PC),A0  ;alte routine aufrufen
                jsr     (A0)
                lea     $000C(SP),SP
                move.l  space(PC),D1    ;flag ob sektor in cache
                beq.s   write_one_new   ;nein
;falls fehler sektor unkenntlich machen
                addq.l  #1,count        ;zÑhler erhîhen
                movea.l space+4(PC),A2  ;adressen holen
                move.l  count(PC),(A2)  ;count updaten
                tst.w   D0              ;fehler
                beq     error           ;nein
                movea.l D1,A0           ;adresse auf sektornummer
                clr.w   (A0)            ;bei fehler lîschen
                bra     no_error        ;ende
;neuen sektor in cache eintragen
write_one_new:  tst.w   D0              ;fehler
                bne     error
                bsr     search_old      ;platz suchen um sektor einzutragen
                move.w  $000C(SP),(A0)  ;sektornummer in cache eintragen
                move.w  $000E(SP),(A1)  ;drive in cache eintragen
                move.l  count(PC),(A2)  ;count in cache eintragen
                movea.l A3,A0           ;adresse im cache
                movea.l 6(SP),A3        ;pufferadresse
                move.l  A3,D0           ;ist pufferadresse gerade
                and.w   #1,D0
                bne     copy_one_odd    ;nein
                bra     copy_one_even   ;ja
                ENDPART
                >PART 'startroutine'
;start des initilisierungsprogramms
start:          movea.l 4(SP),A6        ;basepage
                move.l  A6,basepage     ;basepage eintragen
                move.l  4(A6),D7        ;ende tpa
                sub.l   (A6),D7         ;ende tpa - anfang tpa = free memory
                lsr.l   #8,D7           ;in kb umwandeln
                lsr.l   #2,D7
                sub.w   #$0080,D7       ;128 kb freihalten
                and.w   #$FFFC,D7       ;nur vierer schritte
                move.w  D7,free_mem     ;zahl eintragen
                lea     new_stack(PC),SP ;stack einrichten
                lea     text_main(PC),A6 ;begrÅûungstext ausgeben
                bsr.s   tout
                move.w  #$000A,-(SP)    ;drvmap
                trap    #$0D            ;BIOS
                addq.l  #2,SP
                move.w  D0,drives
                move.w  #$000B,-(SP)    ;kbshift
                trap    #$0D            ;BIOS
                addq.l  #2,SP
                tst.w   D0              ;sondertaste gedrÅckt ?
                bne     change          ;ja

;cache einrichten
check:          lea     text_nl(PC),A6  ;text kein laufwerk
                move.w  drv_map(PC),D1  ;sind laufwerke angemeldet
                beq     abbort          ;nein
                move.w  drives(PC),D0   ;sind drives vorhanden ?
                not.w   D0
                lea     text_lnv(PC),A6 ;text laufwerk nicht vorhanden
                and.w   D0,D1
                bne.s   abbort          ;nein
                lea     text_ns(PC),A6  ;text kein speicher angegeben
                lea     memory(PC),A5
                move.w  (A5),D0         ;ist speicher gewÑhlt ?
                beq.s   abbort          ;nein
                cmp.w   free_mem(PC),D0 ;ist genug speicher vorhanden
                ble.s   install         ;ja
                lea     text_srn(PC),A6 ;text speicher reicht nicht
                bsr.s   tout
                move.w  free_mem(PC),(A5) ;freier speicher = neuer speicher
                bra     change          ;voreinstellungen Ñndern

;text ausgeben pointer auf text in A6
tout:           move.l  A6,-(SP)
                move.w  #9,-(SP)        ;Cconws
                trap    #1              ;GEMDOS
                addq.w  #6,SP
                rts

;parameter in ordnung also installieren
install:        lea     text_ci(PC),A5  ;gewÑhlten speicher in text eintragen
                bsr.s   mem_to_ascii
                lea     memory(PC),A5   ;gewÑhlter speicher in KB
                moveq   #0,D0
                move.w  (A5),D0
                add.w   D0,D0           ;gewÑhlter speicher in sektoren
                subq.w  #1,D0           ;fÅr dbra
                move.w  D0,(A5)         ;merken fÅr spÑtere benutzung
                addq.w  #1,D0
                lea     start(PC),A5    ;start des programms wird cacheadresse
                add.l   D0,D0           ;2 byte pro eintrag
                adda.l  D0,A5           ;adresse fÅr cache_drive
                lea     cache_drive(PC),A6
                move.l  A5,(A6)
                adda.l  D0,A5           ;adresse fÅr cache_count
                lea     cache_count(PC),A6
                move.l  A5,(A6)
                add.l   D0,D0           ;4 byte pro eintrag
                adda.l  D0,A5           ;adresse fÅr cache_adr
                lea     cache_adr(PC),A6
                move.l  A5,(A6)
                lea     text_ci(PC),A6  ;text cache installiert
                bsr.s   tout
                move.w  memory(PC),D0   ;anzahl der sektoren
                lea     start(PC),A6    ;start des cachedrives
                move.l  A6,cache_adress ;adresse merken fÅr scache.acc
                bra     init

;installation abbrechen
abbort_fbs:     lea     text_fbs(PC),A6
abbort:         bsr.s   tout
                clr.w   -(SP)
                trap    #1

;gewÑhlten speicher in ascii umwandeln
mem_to_ascii:   move.w  memory(PC),D7
                lea     tabelle(PC),A6
mem_to_ascii_l: move.w  (A6)+,D6
                move.w  D7,D5
                divu    D6,D5
                move.b  D5,(A5)
                addi.b  #$30,(A5)+
                mulu    D6,D5
                sub.w   D5,D7
                tst.w   (A6)
                bne.s   mem_to_ascii_l
                rts

;voreinstellungen Ñndern
change:         lea     text_skb(PC),A5 ;gewÑhlten speicher umwandeln
                bsr.s   mem_to_ascii
                lea     text_l(PC),A6   ;text laufwerke
                bsr     tout
                bsr     drv_to_char     ;gewÑhlte laufwerke ausgeben
                lea     text_s(PC),A6   ;gewÑhlten speicher ausgeben
                bsr     tout
                move.w  prefetch(PC),D0
                add.b   #'0',D0
                move.b  D0,text_pre
                lea     text_p(PC),A6   ;text von prefetch
                bsr     tout
                bsr.s   key_in          ;tastatur abfragen
                cmp.b   #$61,D0         ;<'a'
                blt.s   more_mem        ;ja
                cmp.b   #$70,D0         ;>'p'
                bgt.s   more_mem        ;ja
                sub.b   #$61,D0         ;statt 'a'..'p'
                lea     drv_map(PC),A6  ;besser 0.14
                move.w  (A6),D1         ;status des gedrÅckten laufwerks Ñndern
                bchg    D0,D1
                and.w   drives(PC),D1   ;nur vorhandene laufwerke nehmen
                move.w  D1,(A6)
                bra.s   change          ;weiter mit den Ñnderungen

;gewÑhlten speicher erhîhen
more_mem:       lea     memory(PC),A6
                cmp.b   #$2B,D0         ;'+' gedrÅckt ?
                bne.s   less_mem        ;nein
                move.w  (A6),D0
                cmp.w   free_mem(PC),D0 ;speichergrenze erreicht ?
                beq.s   change          ;ja
                addq.w  #4,D0           ;um 4K erhîhen
                move.w  D0,(A6)
                bra.s   change          ;weiter mit den Ñnderungen
;gewÑhlten speicher verringern
less_mem:       cmp.b   #$2D,D0         ;'-' gedrÅckt ?
                bne.s   change_pre      ;nein
                move.w  (A6),D0         ;gewÑhlter speicher = 0 ?
                beq.s   change          ;ja
                subq.w  #4,D0           ;um 4K verringern
                move.w  D0,(A6)
                bra.s   change          ;weiter mit den Ñnderungen

;prefetch verÑndern
change_pre:     cmp.b   #'2',D0         ;taste < 2 gedrÅckt ?
                blt.s   change_ok       ;ja
                cmp.b   #'8',D0         ;taste > 8 gedrÅckt
                bhi.s   change_ok
                move.b  D0,text_pre     ;zahl als text eintragen
                sub.b   #'0',D0         ;ASCII in zahl Åbertragen
                and.w   #$00FF,D0       ;nur unteres byte
                move.w  D0,prefetch
                bra     change

;tastatur ohne echo abfragen
key_in:         move.w  #7,-(SP)        ;Crawcin
                trap    #1              ;GEMDOS
                addq.l  #2,SP
                rts

;Ñnderungen abgeschlossen
change_ok:      lea     text_t(PC),A6   ;text space oder enter
                bsr     tout
change_ok_loop: bsr.s   key_in          ;tastatur abfragen
                cmp.b   #$20,D0         ;'SPACE' gedrÅckt
                beq     check           ;ja installieren aber nicht speichern
                cmp.b   #$0D,D0         ;'ENTER' gedrÅckt
                bne.s   change_ok_loop  ;nein weiter warten

;erst Ñnderungen abspeichern und dann installieren
;path auf ordner "AUTO" setzen
                pea     ordner(PC)
                move.w  #$003B,-(SP)    ;Dsetpath
                trap    #1              ;GEMDOS
;SCACHE2 îffnen
                move.w  #2,-(SP)
                pea     name(PC)
                move.w  #$003D,-(SP)    ;Fopen
                trap    #1              ;GEMDOS
                lea     $000E(SP),SP
                lea     text_nf(PC),A6  ;text datei nicht gefunden
                tst.l   D0              ;fehler
                blt     abbort          ;ja
                move.w  D0,file_id      ;id sichern
                clr.w   -(SP)
                move.w  D0,-(SP)
                move.w  #prefetch-anfang+28,D0 ;offset zum start der drei variablen
                move.l  D0,-(SP)
                move.w  #$0042,-(SP)    ;Fseek
                trap    #1              ;GEMDOS
                lea     $000A(SP),SP
                tst.l   D0
                blt     abbort_fbs
                pea     prefetch(PC)    ;ab prefetch
                moveq   #6,D0           ;6 byte speichern
                move.l  D0,-(SP)
                move.w  file_id(PC),-(SP)
                move.w  #$0040,-(SP)    ;Fwrite
                trap    #1              ;GEMDOS
                lea     $000C(SP),SP
                tst.l   D0
                blt     abbort_fbs
                move.w  file_id(PC),-(SP)
                move.w  #$003E,-(SP)    ;Fclose
                trap    #1              ;GEMDOS
                addq.l  #4,SP
                tst.l   D0
                blt     abbort_fbs
                lea     text_vg(PC),A6  ;text voreinstellungen gesichert
                bsr     tout
                bra     check           ;installieren

;alle angewÑhlten laufwerke als buchstaben ausgeben
drv_to_char:    move.w  drv_map(PC),D5
                moveq   #$41,D6
drv_to_char_l:  btst    #0,D5
                beq.s   no_drv
                move.w  D6,-(SP)
                move.w  #2,-(SP)        ;Cconout
                trap    #1              ;GEMDOS
                addq.l  #4,SP
no_drv:         addq.l  #1,D6
                lsr.w   #1,D5
                cmp.w   #$0051,D6
                bne.s   drv_to_char_l
                rts
                ENDPART
                >PART 'daten'
text_main:      DC.B $0D,$0A,'TurboCache    Version 2.0',$0D,$0A
                DC.B 'Ω Ralf Biedermann',$0D,$0A,0
text_nl:        DC.B 'Kein Laufwerk ausgewÑhlt.',$0D,$0A,0
text_lnv:       DC.B 'Laufwerk nicht vorhanden.',$0D,$0A,0
text_ns:        DC.B 'Kein Speicher fÅr Puffer angegeben.',$0D,$0A,0
text_ci:        DC.B '0000 KB Cache installiert.',$0D,$0A,0
text_l:         DC.B 'Laufwerke (C...P):',0
text_s:         DC.B ', Speicher (+ oder -):'
text_skb:       DC.B '0000 KB  ',0
text_p:         DC.B 'Prefetch (2..8):'
text_pre:       DC.B '0 ',$0D,0
text_t:         DC.B $0A,'LEERTASTE: Weiter, RETURN: Parameter sichern',$0D,$0A,0
ordner:         DC.B 'auto',0
name:           DC.B 'tcache.prg',0
text_nf:        DC.B 7,'Datei \auto\tcachet.prg nicht gefunden.',$0D,$0A,0
text_fbs:       DC.B 7,'Fehler beim Sichern!',$0D,$0A,0
text_srn:       DC.B 7,'Speicher reicht nicht!',$0D,$0A,0
text_sd:        DC.B 7,'TCache schon da!',$0D,$0A,0
text_vg:        DC.B 'Voreinstellungen gesichert...',$0D,$0A,0
tabelle:        DC.W 1000,100,10,1,0
                ENDPART
                >PART 'bss'
                BSS
file_id:        DS.B 2
free_mem:       DS.B 2
drives:         DS.B 2
                DS.B $0190
new_stack:

                END
                ENDPART
                END
