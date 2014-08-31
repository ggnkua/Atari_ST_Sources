                OPT F+                  ;Fast-Load (siehe 68000er 11/89)
                OUTPUT 'TCACHACC.ACC'
                >PART 'accessory instalieren'
************************************************************************
* main() - Accessory installieren                                      *
************************************************************************
                TEXT
start:          lea     start-256(PC),A0 ;Stack wegen ACC nicht nutzbar (Basepage)
                lea     own_stack(PC),SP ;Eigenen Stack einrichten
                tst.l   $24(A0)         ;ACC oder PRG?
                sne     app             ;0=ACC, -1=PRG
                beq.s   start1          ;ACC => kein Setblock

                movea.l SP,A1
                suba.l  #start-256,A1   ;Programml„nge
                move.l  A1,-(SP)        ;L„nge des Starters
                move.l  A0,-(SP)        ;Basepageadr des Starters
                move.l  #$4A0000,-(SP)
                trap    #1              ;Setblock()
                lea     12(SP),SP

start1:         move.l  #$0A000100,D0
                bsr     aes             ;appl_init()
                move.w  D0,appl_id
                tst.b   app             ;PRG?
                bne.s   start2          ;Ja! =>

                move.w  appl_id(PC),int_in
                move.l  #accname,addr_in
                move.l  #$23010101,D0
                bsr     aes             ;menu_register()


start2:         lea     _tree_main(PC),A0
                moveq   #33,D7          ;34 Objekte im Baum
start3:         move.w  D7,int_in       ;die Objektnummer
                move.l  A0,addr_in      ;Adresse des Baumes
                move.l  #$72010101,D0
                bsr     aes             ;rsrc_obfix()
                dbra    D7,start3

                move.l  #_tree_main,addr_in ;RSC-Adr
                move.l  #$36000501,D0
                bsr     aes             ;form_center()
                move.l  int_out+2(PC),xobj
                move.l  int_out+6(PC),wobj

                tst.b   app             ;PRG?
                bne.s   do_it           ;dann direkt starten
                ENDPART
                >PART 'warteschleife fr acc'
************************************************************************
* Warteschleife des Accessories auf Aufruf                             *
************************************************************************
multi:          lea     evnt_buff(PC),A0
                move.l  A0,addr_in
                move.l  #$17000101,D0
                bsr     aes             ;evnt_message
                cmpi.w  #40,(A0)        ;ACC_OPEN?
                bne.s   multi
                bsr.s   do_it
                bra.s   multi
                ENDPART
                >PART 'eigentliche routine'
************************************************************************
* Programm ausfhren                                                   *
************************************************************************
do_it:          bsr     get_data        ;daten von scache holen
                tst.l   adress          ;ist cache da?
                bne.s   do_it1          ;ja

                moveq   #0,D0
                lea     no_cache(PC),A0 ;kein cache da
                bsr     form_alert
                bra.s   multi

do_it1:         move.w  #1,int_in
                move.l  #$6B010100,D0
                bsr     aes             ;wind_update() - Update fr andere sperren

                lea     int_in(PC),A0
                clr.w   (A0)+
                move.l  xobj(PC),(A0)+
                move.l  wobj(PC),(A0)
                move.l  #$64050100,D0
                bsr     aes             ;wind_create()
                move.w  D0,wi_handle

                lea     int_in(PC),A0
                move.w  D0,(A0)+
                move.l  xobj(PC),(A0)+
                move.l  wobj(PC),(A0)
                move.l  #$65050101,D0
                bsr     aes             ;wind_open()


                bsr.s   output          ;Dialog mit Benutzer fhren

                move.w  wi_handle(PC),int_in
                move.l  #$66010100,D0
                bsr     aes             ;wind_close()

                move.w  wi_handle(PC),int_in
                move.l  #$67010100,D0
                bsr     aes             ;wind_delete()

                clr.w   int_in
                move.l  #$6B010100,D0
                bsr     aes             ;wind_update() - Update wieder freigeben
                tst.b   app             ;ACC?
                beq     multi           ;dann zurck
                clr.w   -(SP)
                trap    #1              ;sonst Pterm0()
                ENDPART
                >PART 'dialog'
************************************************************************
* Dialog mit dem Benutzer fuehren                                      *
************************************************************************
output:         bsr     arrow           ;graf_mouse(ARROW) - Mausform setzen

;ende normal
                clr.w   _ob_32+10

;w„hlbare laufwerke anzeigen
                move.w  #10,-(SP)
                trap    #13             ;Drvmap
                addq.l  #2,SP
                lea     _ob_4+10(PC),A0 ;erste laufwerkskennung
                lsr.w   #2,D0           ;laufwerk a+b nicht vorhanden
                moveq   #13,D7          ;14 laufwerke untersuchen
drvm_loop:      clr.w   (A0)            ;normal als standard
                btst    #0,D0
                bne.s   edrvm_loop      ;laufwerk ist da
                move.w  #8,(A0)         ;laufwerk ist nicht w„hlbar
edrvm_loop:     lsr.w   #1,D0           ;n„chstes laufwerk
                lea     24(A0),A0       ;n„chstes objekt
                dbra    D7,drvm_loop

;gew„hlte Laufwerke anzeigen
                move.w  drv_map(PC),D0  ;gew„hlte laufwerke holen
                lea     _ob_4+10(PC),A0 ;erste laufwerkskennung
                lsr.w   #2,D0           ;laufwerk a+b nicht vorhanden
                moveq   #13,D7          ;14 laufwerke untersuchen
drvn_loop:      btst    #0,D0
                beq.s   edrvn_loop      ;laufwerk ist nicht da
                move.w  #1,(A0)         ;laufwerk ist gew„hlt
edrvn_loop:     lsr.w   #1,D0           ;n„chstes laufwerk
                lea     24(A0),A0       ;n„chstes objekt
                dbra    D7,drvn_loop

;prefetch anzeigen
                lea     _ob_19+10(PC),A0 ;2 sektoren prefetch
                moveq   #6,D7           ;7 m”glichkeiten
prefetch_loop:  clr.w   (A0)            ;normal
                lea     24(A0),A0       ;n„chstes objekt
                dbra    D7,prefetch_loop
                lea     _ob_19+10(PC),A0 ;erstes prefetch
                move.w  prefetch(PC),D0 ;anzahl der prefetches
                subq.w  #2,D0           ;mindestens 2
                mulu    #24,D0          ;l„nge objekt
                move.w  #1,0(A0,D0.l)

;cachegr”že anzeigen
                moveq   #0,D0
                move.w  memory(PC),D0   ;anzahl der sektoren - 1
                addq.l  #1,D0           ;anzahl der sektoren
                lsr.l   #1,D0           ;anzahl in KB
                moveq   #3,D4           ;4 ziffern
                lea     memory_str(PC),A0 ;zeiger auf string
                lea     itoa5(PC),A1    ;fr 4 ziffern
                bsr     itoa            ;integer to ascii

;lesezugriffe anzeigen
                move.l  reads(PC),D0    ;anzahl der lesezugriffe
                moveq   #5,D4           ;6 ziffern
                lea     reads_str(PC),A0 ;zeiger auf string
                lea     itoa6(PC),A1    ;fr 6 ziffern
                bsr     itoa

;schreibzugriffe anzeigen
                move.l  writes(PC),D0   ;anzahl der lesezugriffe
                moveq   #5,D4           ;6 ziffern
                lea     writes_str(PC),A0 ;zeiger auf string
                lea     itoa6(PC),A1    ;fr 6 ziffern
                bsr     itoa

;treffer lesezugriffe anzeigen
                move.l  hits(PC),D0     ;anzahl der lesezugriffe
                moveq   #5,D4           ;6 ziffern
                lea     hits_str(PC),A0 ;zeiger auf string
                lea     itoa6(PC),A1    ;fr 6 ziffern
                bsr     itoa

;treffer schreibzugriffe anzeigen
                move.l  no_updates(PC),D0 ;anzahl der lesezugriffe
                moveq   #5,D4           ;6 ziffern
                lea     no_updates_str(PC),A0 ;zeiger auf string
                lea     itoa6(PC),A1    ;fr 6 ziffern
                bsr     itoa

;aktiv oder passiv anzeigen
                lea     _ob_33+10(PC),A0 ;
                move.w  #1,(A0)         ;angew„hlt
                tst.w   flag            ;ist aktiv ?
                beq.s   aktiv           ;ja
                clr.w   (A0)            ;passiv

aktiv:          move.l  #_tree_main,addr_in
                lea     int_in(PC),A0
                clr.w   (A0)+
                move.w  #33,(A0)+
                move.l  xobj(PC),(A0)+
                move.l  wobj(PC),(A0)
                move.l  #$2A060101,D0
                bsr     aes             ;objc_draw(dialog,0,8,xobj,yobj,wobj,hobj)

                move.l  #_tree_main,addr_in ;Dialogschleife beginnen
                move.w  #0,int_in
                move.l  #$32010101,D0
                bsr     aes             ;form_do(dialog,GROESSE)
                move.b  D0,wahl
;daten an cache bergeben
;aktiv oder passiv
                movea.l adress(PC),A5   ;pointer auf cache
                clr.w   -30(A5)         ;aktivieren
                tst.w   _ob_33+10       ;aktivbutton
                bne.s   get_prefetch    ;ja
;cache l”schen
                not.w   -30(A5)         ;passiv
                movea.l cache_adr(PC),A0 ;zeiger auf cachesektornummer
                move.w  memory(PC),D7   ;anzahl der sektoren-1
nc_loop:        clr.w   (A0)+           ;l”schen
                dbra    D7,nc_loop
get_prefetch:   lea     _ob_19+10(PC),A0 ;pointer auf ersten prefetch
                moveq   #2,D6           ;z„hler fr prefetch min=2
                moveq   #6,D7           ;maximal 7 buttons
pr_loop:        tst.w   (A0)            ;ist gew„hlt ?
                bne.s   epr_loop        ;ja
                addq.w  #1,D6           ;1 prefetch mehr
                lea     24(A0),A0       ;n„chstes objekt
                dbra    D7,pr_loop
epr_loop:       move.w  D6,-40(A5)      ;prefetch eintragen
;gew„hlte laufwerke eintragen
                lea     _ob_4+10(PC),A0 ;erstes laufwerk
                moveq   #13,D7          ;max 14 laufwerke
                moveq   #0,D6           ;drivemap
                moveq   #2,D5           ;drive
drvmap_loop:    cmpi.w  #1,(A0)         ;laufwerk gew„hlt?
                bne.s   no_drive
                bset    D5,D6           ;laufwerk eintragen
                bra.s   edrvmap_loop
no_drive:       movea.l cache_drive(PC),A1 ;
                movea.l cache_adr(PC),A2
                move.w  memory(PC),D4   ;anzahl der sektoren-1
no_drive_loop:  cmp.w   (A1)+,D5        ;ist es dieses laufwerk ?
                bne.s   eno_drive_loop  ;nein
                clr.w   (A2)            ;eintrag l”schen
eno_drive_loop: addq.l  #2,A2
                dbra    D4,no_drive_loop
edrvmap_loop:   addq.w  #1,D5           ;n„chstes laufwerk
                lea     24(A0),A0
                dbra    D7,drvmap_loop
                move.w  D6,-38(A5)      ;neue drivemap eintragen
                rts
                ENDPART
                >PART 'unterprogramme'
************************************************************************
* Zahl in D0 dezimal nach A0 ausgeben                                  *
************************************************************************
itoa:           moveq   #' ',D5         ;Fllzeichen (vor der Zahl)
itoa1:          move.l  -(A1),D3
                moveq   #$D0,D2
itoa2:          sub.l   D3,D0
                dbmi    D2,itoa2
                neg.b   D2
                cmp.b   #'0',D2         ;Eine Null?
                beq.s   itoa4           ;dann vorher aber testen
                moveq   #'0',D5         ;Ab nun drfen Nullen ausgegeben werden
itoa3:          move.b  D2,(A0)+
                add.l   D3,D0
                dbra    D4,itoa1
                rts
itoa4:          move.b  D5,D2           ;Ersatzzeichen fr evtl.Fhrungsnull
                tst.w   D4              ;letzte Position?
                bne.s   itoa3           ;Nein => normal ausgeben
                move.b  #'0',(A0)       ;sonst unbedingt eine Null ausgeben
                rts

                DC.L 1,10,100,1000      ;fr vier stellen
itoa5:          DC.L 10000,100000       ;fr sechs stellen
itoa6:

************************************************************************
* form_alert A0 mit Default D0 aufrufen                                *
************************************************************************
form_alert:     movem.l D0/A0,-(SP)
                bsr.s   arrow
                movem.l (SP)+,D0/A0
                move.w  D0,int_in
                move.l  A0,addr_in
                move.l  #$34010101,D0
                bra.s   aes             ;form_alert()

************************************************************************
* Mausform = Pfeil (normal)                                            *
************************************************************************
arrow:          moveq   #0,D0
                move.w  D0,int_in
                move.l  #$4E010101,D0

************************************************************************
* Mein eigener kleiner AES-Aufruf                                      *
* D0=Die ersten 4 Eintr„ge im int_in-Array (Bytebreite!)               *
************************************************************************
aes:            movem.l D1-A6,-(SP)     ;besser retten, man kann nie wissen
                lea     contrl(PC),A0
                clr.l   (A0)
                clr.l   4(A0)           ;int_in-Array l”schen
                movep.l D0,1(A0)        ;und die neuen Daten eintragen
                lea     aes_para_blk(PC),A0
                move.l  A0,D1
                move.w  #$C8,D0
                trap    #2              ;AES aufrufen
                moveq   #0,D0
                move.w  int_out(PC),D0
                movem.l (SP)+,D1-A6
                rts

;unterprogramm um daten von scache zu holen
get_data:       pea     get_it(PC)
                move.w  #$26,-(SP)
                trap    #14
                addq.l  #6,SP
                rts
get_it:         clr.l   reads
                clr.l   hits
                clr.l   writes
                clr.l   no_updates
                clr.w   flag
                clr.l   cache_adr
                clr.w   memory
                clr.w   drv_map
                clr.w   prefetch
                clr.l   adress
                clr.l   cache_drive
                movea.l $0476,A0
getdatal:       cmpi.l  #'XBRA',-12(A0)
                bne.s   exitgetdata
                cmpi.l  #'SCRB',-8(A0)
                beq.s   endgetdata
                movea.l -4(A0),A0
                bra.s   getdatal
endgetdata:     move.l  -16(A0),writes
                move.l  -20(A0),hits
                move.l  -24(A0),reads
                move.l  -28(A0),no_updates
                move.w  -30(A0),flag
                move.l  -34(A0),cache_adr
                move.w  -36(A0),memory
                move.w  -38(A0),drv_map
                move.w  -40(A0),prefetch
                move.l  -48(A0),cache_drive
                move.l  A0,adress       ;adresse von xbra merken
exitgetdata:    rts

                ENDPART
                >PART 'data'
************************************************************************
* Hier beginnt der DATA-Bereich                                        *
************************************************************************
************************************************************************
* Nun ein paar wichtige Daten                                          *
************************************************************************
                DATA
aes_para_blk:   DC.L contrl
                DC.L global
                DC.L int_in
                DC.L int_out
                DC.L addr_in
                DC.L addr_out

************************************************************************
* Ein paar allgemeine Variablendefinitionen                            *
************************************************************************
accname:        DC.B '  Tcache... ',0
                ENDPART
                >PART 'Alert-Strings'
no_cache:       DC.B '[0][ TCACHE | nicht installiert ][Schade]',0,0
                ENDPART
                >PART 'RSC-Definitionen'

* erzeugt von Rsc2S v1.01 ½ 1990 by Andreas Alich

_g_box          EQU 20
_g_ibox         EQU 25
_g_button       EQU 26
_g_boxchar      EQU 27
_g_string       EQU 28

_tree_main:
_ob_0:
                DC.W -1,1,33,_g_box
                DC.B 0,%0
                DC.B 0,%10000
                DC.B 0,2,%10001,%0
                DC.W 4,1,46,17
_ob_1:
                DC.W 3,2,2,_g_ibox
                DC.B 0,%0
                DC.B 0,%10000
                DC.B 0,1,%10001,%10110000
                DC.W 3,1,39,2049
_ob_2:
                DC.W 1,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_2
                DC.W 2,0,34,2049
_ob_3:
                DC.W 4,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_3
                DC.W 1027,3074,10,1
_ob_4:
                DC.W 5,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'C',0,%10001,%0
                DC.W 4,5,4,1
_ob_5:
                DC.W 6,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'D',0,%10001,%0
                DC.W 8,5,4,1
_ob_6:
                DC.W 7,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'E',0,%10001,%0
                DC.W 4,6,4,1
_ob_7:
                DC.W 8,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'F',0,%10001,%0
                DC.W 8,6,4,1
_ob_8:
                DC.W 9,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'G',0,%10001,%0
                DC.W 4,7,4,1
_ob_9:
                DC.W 10,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'H',0,%10001,%0
                DC.W 8,7,4,1
_ob_10:
                DC.W 11,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'I',0,%10001,%0
                DC.W 4,8,4,1
_ob_11:
                DC.W 12,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'J',0,%10001,%0
                DC.W 8,8,4,1
_ob_12:
                DC.W 13,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'K',0,%10001,%0
                DC.W 4,9,4,1
_ob_13:
                DC.W 14,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'L',0,%10001,%0
                DC.W 8,9,4,1
_ob_14:
                DC.W 15,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'M',0,%10001,%0
                DC.W 4,10,4,1
_ob_15:
                DC.W 16,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'N',0,%10001,%0
                DC.W 8,10,4,1
_ob_16:
                DC.W 17,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'O',0,%10001,%0
                DC.W 4,11,4,1
_ob_17:
                DC.W 18,-1,-1,_g_boxchar
                DC.B 0,%1
                DC.B 0,%0
                DC.B 'P',0,%10001,%0
                DC.W 8,11,4,1
_ob_18:
                DC.W 19,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_18
                DC.W 4,2060,23,1
_ob_19:
                DC.W 20,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '2',0,%10001,%0
                DC.W 4,14,4,1
_ob_20:
                DC.W 21,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '3',0,%10001,%0
                DC.W 8,14,4,1
_ob_21:
                DC.W 22,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '4',0,%10001,%0
                DC.W 12,14,4,1
_ob_22:
                DC.W 23,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '5',0,%10001,%0
                DC.W 16,14,4,1
_ob_23:
                DC.W 24,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '6',0,%10001,%0
                DC.W 20,14,4,1
_ob_24:
                DC.W 25,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '7',0,%10001,%0
                DC.W 24,14,4,1
_ob_25:
                DC.W 26,-1,-1,_g_boxchar
                DC.B 0,%10001
                DC.B 0,%0
                DC.B '8',0,%10001,%0
                DC.W 28,14,4,1
_ob_26:
                DC.W 27,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_26
                DC.W 25,7,19,1
_ob_27:
                DC.W 28,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_27
                DC.W 22,8,22,1
_ob_28:
                DC.W 29,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_28
                DC.W 16,9,28,1
_ob_29:
                DC.W 30,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_29
                DC.W 27,5,16,1
_ob_30:
                DC.W 31,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_30
                DC.W 14,10,30,1
_ob_31:
                DC.W 32,-1,-1,_g_string
                DC.B 0,%0
                DC.B 0,%0
                DC.L _str_31
                DC.W 4,3331,8,1
_ob_32:
                DC.W 33,-1,-1,_g_button
                DC.B 0,%111
                DC.B 0,%0
                DC.L _str_32
                DC.W 34,14,9,1
_ob_33:
                DC.W 0,-1,-1,_g_button
                DC.B 0,%100001
                DC.B 0,%1
                DC.L _str_33
                DC.W 34,12,9,1

_str_2:         DC.B 'Statistik von TCACHE  (c) RBsoft91',0
_str_3:         DC.B 'zu puffern',0
_str_18:        DC.B 'Anzahl von Leseprefetch',0
_str_26:        DC.B 'Lesezugriffe:'
reads_str:      DC.B '000000',0
_str_27:        DC.B 'Schreibzugriffe:'
writes_str:     DC.B '000000',0
_str_28:        DC.B 'gesparte Lesezugriffe:'
hits_str:       DC.B '000000',0
_str_29:        DC.B 'Cachegr”že:'
memory_str:     DC.B '0000K',0
_str_30:        DC.B 'gesparte Scheibzugriffe:'
no_updates_str: DC.B '000000',0
_str_31:        DC.B 'Laufwerk',0
_str_32:        DC.B 'ENDE',0
_str_33:        DC.B 'AKTIV',0

                ENDPART
                >PART 'bss'
************************************************************************
* Und ordentlich BSS-Bereich                                           *
************************************************************************
                BSS
bss_start:
writes:         DS.L 1
hits:           DS.L 1
reads:          DS.L 1
no_updates:     DS.L 1
flag:           DS.W 1
cache_adr:      DS.L 1
memory:         DS.W 1
drv_map:        DS.W 1
prefetch:       DS.W 1
adress:         DS.L 1
cache_drive:    DS.L 1

global:         DS.W 15
contrl:         DS.W 12
int_in:         DS.W 128
int_out:        DS.W 128
addr_in:        DS.L 128
addr_out:       DS.L 128
evnt_buff:      DS.W 8
xobj:           DS.W 2
wobj:           DS.W 2
wi_handle:      DS.W 1
appl_id:        DS.W 1

wahl:           DS.B 1
app:            DS.B 1                  ;0=ACC, -1=PRG
                DS.L 128                ;jedem Programm seinen eigenen Stack
own_stack:      DS.L 0
bss_ende:
                ENDPART
                END
