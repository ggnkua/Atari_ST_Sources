************************************************* 
*                    ST-CACHE                   * 
*                                               * 
*             Version 2.71 ,  05/90             * 
*                                               * 
*         FÅr:  - TOS 1.0 vom 06.02.1986        * 
*               - TOS 1.2 vom 22.04.1987        * 
*               - TOS 1.4 vom 06.04.1989        * 
*               - TOS 1.6 vom 19.06.1989        * 
*               - TOS 1.6 vom 29.07.1989        * 
*                                               * 
*         Sprache:  GST Macro-Assembler         * 
*                                               * 
*                Matthias AndrÑ                 * 
*                Freundstr. 48                  * 
*                8750 Aschaffenburg             * 
*                                               * 
************************************************* 
; 
 SECTION   st_cache 
; 
start:
 lea       stack,sp     ; Stackadresse setzen 
 bsr       appl_init    ; Anwendung anmelden
 bsr       rsrc_load    ; RSC-File laden
 tst.b     fehler       ; Fehler aufgetreten ?
 bne.s     do_box 
 clr.w     d0 
 clr.w     d1 
 bsr       rsrc_gaddr 
 tst.b     fehler       ; Fehler ?
 bne.s     do_box 
 move.l    addrout,rsrcaddr ; Adresse RSC-Daten 
 bsr       form_center  ; RSC-Box zentrieren
 bsr       init         ; Cache initialisieren
 tst.b     fehler 
 bne.s     do_box 
 bsr       menu_register ; Accessory eintragen
; 
acc_loop: 
 bsr       evnt_mesag 
 cmp.w     #40,ev_buff  ; Accessory gewÑhlt ? 
 bne.s     acc_loop     ; nein, zurÅck
 move.w    ev_buff+8,d0 
 cmp.w     acc_id,d0    ; Cache-Accessory ? 
 bne.s     acc_loop     ; nein, ein anderes 
do_box: 
 bsr.s     main         ; ja, RSC-Box bearbeiten
 bra.s     acc_loop     ; und zurÅck an Anfang
; 
main: 
 lea       err_txt,a0   ; Adresse Fehlermeldung 
 tst.b     fehler       ; Installationsfehler ? 
 bne.l     form_alert   ; ja, Meldung und zurÅck
; 
 bsr       write_size   ; Cache-Grîsse schreiben
 clr.w     d0 
 bsr       form_dial    ; Bildbereich reservieren 
 moveq.l   #1,d0        ; sich vergrîsserndes 
 bsr       form_dial    ; Rechteck und
 bsr       obj_draw     ; Abfrage-Box zeichnen
 bsr       form_do      ; bearbeiten
 bsr       get_size     ; Cachegrîsse lesen 
 bsr       reserve      ; Speicher reservieren
 move.l    rsrcaddr,a1  ; Adresse RSC-Daten 
 move.w    #$30,466(a1) ; Ok-Button 'normal'
 move.l    buffer,a0    ; Adresse kopiertes ROM 
 add.w     f_load,a0    ; +Offset f. Fastload 
 move.b    #$10,(a0)    ; Seek ohne Verify
 cmp.w     #$11,394(a1) ; Fastload an ? 
 beq.s     main5        ; ja, weiter
 move.b    #$14,(a0)    ; nein, Seek mit Verify 
main5:
 cmp.w     #$31,442(a1) ; Cachedaten lîschen ?
 bne.s     main6        ; nein, weiter
 bsr       cache_del    ; ja, lîschen 
main6:
 move.w    #$30,442(a1) ; Lîsch-Button 'normal' 
 move.w    #3,laufwerk  ; Cache beide Drive's 
 cmp.w     #$11,154(a1) ; Cache Drive A an ?
 beq.s     main7        ; ja, weiter
 and.w     #2,laufwerk  ; nein, Cache aus 
 clr.w     d3           ; und von Drive A 
 bsr       disc_changed ; die Cachedaten lîschen
main7:
 cmp.w     #$11,178(a1) ; Cache Drive B an ?
 beq.s     main8        ; ja, weiter
 and.w     #1,laufwerk  ; nein, Cache aus 
 moveq.l   #1,d3        ; und von Drive B 
 bsr       disc_changed ; die Cachedaten lîschen
main8:
 clr.w     sperre       ; Sperre Drive A und B an 
 cmp.w     #$11,106(a1) ; Sperre Drive A an ? 
 beq.s     main9        ; ja, weiter
 move.w    #1,sperre    ; nein, ausschalten 
main9:
 cmp.w     #$11,202(a1) ; Sperre Drive B an ? 
 beq.s     main10       ; ja, weiter
 or.w      #2,sperre    ; nein, ausschalten 
main10: 
 moveq.l   #3,d0        ; sich verkleinerndes 
 bsr       form_dial    ; Rechteck zeichnen 
 moveq.l   #2,d0        ; Bildbereich freigeben 
 bra.l     form_dial    ; und zurÅck
; 
; Umwandlung von 'maxsec' fÅr Grîssenangabe 
write_size: 
 moveq.l   #2,d0
 clr.w     d1 
 bsr       rsrc_gaddr 
 move.l    addrout,a1 
 move.l    (a1),a1      ; Adresse Grîssenangabe 
 addq.l    #3,a1
 move.w    maxsec,d0    ; Anzahl der Sektoren 
 lsr.w     #1,d0        ; durch 2 = Grîsse in Kb
 ext.l     d0           ; auf Langwortbreite
 moveq.l   #2,d1        ; 3 Stellen 
ws_loop:
 divu      #10,d0       ; Grîsse durch 10 
 swap      d0           ; Rest in d0.w
 add.b     #'0',d0      ; + ASCII-CODE von '0'
 move.b    d0,-(a1)     ; Ziffer schreiben
 clr.w     d0           ; Rest lîschen
 swap      d0           ; und wieder tauschen 
 dbra.w    d1,ws_loop   ; nÑchste Ziffer
 rts
; 
getsysbase: 
 move.l    $4f2,a0
 move.l    a0,sysbase   ; Startadresse TOS
 cmp.w     #$102,2(a0)  ; TOS-Version < 1.2 ? 
 blt.s     pd_ok        ; ja, weiter
 move.l    40(a0),pd    ; Process-Descriptor
pd_ok:
 tst.w     $4a6         ; mind. eine Floppy ? 
 bne.s     gs_end       ; ja, weiter
 move.b    #1+48,fehler ; nein, Fehler
gs_end: 
 rts                    ; und zurÅck
; 
init: 
 pea       getsysbase   ; getsysbase-Routine
 move.w    #38,-(sp)    ; im Supervisormodus
 trap      #14          ; ausfÅhren 
 addq.l    #6,sp
 tst.b     fehler       ; Fehler ?
 beq.s     init_1       ; nein, weiter
 rts                    ; ja, zurÅck
init_1: 
 move.l    sysbase,a4   ; TOS-Startadresse in a4
 move.l    a4,d4        ; und d4
 move.l    $18(a4),d1   ; TOS Erstellungsdatum
 lea       tos_adr(pc),a3 ; Start Adressentabelle 
 move.w    (a3)+,d2     ; Anzahl Adressblîcke 
adr_loop: 
 cmp.l     (a3)+,d1     ; gleiches Datum ?
 bne.s     nxt_vers     ; nein, weitersuchen
 cmp.l     (a3),d4      ; gleiche 'sysbase' ? 
 beq.s     patch        ; ja, patchen 
nxt_vers: 
 lea       20(a3),a3    ; nÑchster Adressblock
 dbra.w    d2,adr_loop
 move.b    #2+48,fehler ; TOS-Version unbekannt 
 rts                    ; zurÅck
; 
patch:
 addq.l    #4,a3        ; a3 auf Anfang Patch-Adr.
 move.w    (a3)+,trap14 ; Adresse Trap-Handler
 move.w    (a3)+,f_load ; Adresse 'Fastload-Byte' 
 move.w    (a3)+,rw_abs ; Adresse 'rwabs'-Routine 
 cmpa.w    #$6100,a4    ; Disketten-TOS 1.0  ?
 beq.s     patch_d      ; ja, weiter
 move.l    #$2070,-(sp) ; nein, ca. 8 Kb fÅr Kopie
 move.w    #$48,-(sp) 
 trap      #1           ; anfordern (Malloc)
 addq.l    #6,sp
 tst.l     d0           ; Ok ?
 bpl.s     copy_tos     ; ja, weiter
 move.b    #3+48,fehler ; nein, Fehler
 rts                    ; und zurÅck
patch_d:
 move.l    a4,d0        ; Startadresse Disk.-TOS
copy_tos: 
 move.l    d0,buffer    ; Startadresse merken 
 pea       copy         ; Floppyroutinen aus
 move.w    #38,-(sp)    ; TOS kopieren (ROM-TOS)
 trap      #14          ; (im Supervisormodus)
 addq.l    #6,sp
 move.l    buffer,a2    ; Startadresse der Kopie
 move.l    a2,d2
 move.l    a2,a1        ; (im TOS: 'jsr flopver') 
 add.w     (a3)+,a1     ; Adresse relozieren
 sub.l     d4,(a1)      ;    "        " 
 add.l     d2,(a1)      ;    "        " 
 move.l    a2,a1        ; (im TOS: 'jsr floprd')
 add.w     (a3)+,a1     ; Adresse relozieren
 sub.l     d4,(a1)      ;    "        " 
 add.l     d2,(a1)      ;    "        " 
 move.l    (a1),flp_rd  ; Adresse floprd merken 
 move.l    a2,a1        ; (im TOS: 'jsr flopwr')
 add.w     (a3)+,a1     ; Adresse relozieren
 sub.l     d4,(a1)      ;    "        " 
 add.l     d2,(a1)      ;    "        " 
 move.l    (a1),flp_wr  ; Adresse flopwr merken 
 move.l    #flopwr,(a1) ; eigene Routine setzen 
 move.l    a2,a1        ; (im TOS: 'jsr floprd' ) 
 add.w     (a3)+,a1     ; Adresse relozieren
 sub.l     d4,(a1)      ;    "        " 
 add.l     d2,(a1)      ;    "        " 
 move.l    #floprd,(a1) ; eigene Routine setzen 
 move.l    a2,a1
 add.w     (a3),a1
 move.l    #floprd,(a1)+ ; Trap #14 FLOPRD- und 
 move.l    #flopwr,(a1) ; FLOPWR-Routinen umlegen 
; Auswertung der Cache-Steuerdatei
 pea       dta
 move.w    #$1a,-(sp) 
 trap      #1           ; DTA setzen
 addq.l    #6,sp
 clr.w     -(sp)
 pea       f_name       ; Steuerdatei-Name lesen
 move.w    #$4e,-(sp) 
 trap      #1 
 addq.l    #8,sp
 lea       dta+30,a0   ; Adresse Steuerdatei-Name 
 tst.w     d0          ; Name auf Disk gefunden ? 
 beq.s     sf_found    ; ja, weiter 
 lea       filename,a0 ; nein, Voreinstellung 
sf_found: 
 moveq.l   #8,d7        ; in max. 9 Stellen 
fn_loop:
 cmp.b     #'.',(a0)+   ; '.' suchen
 dbeq.w    d7,fn_loop 
; Grîssenangabe aus der Steuerdatei einlesen
 move.l    a0,a1
 lea       -1(a0),a2
 bsr       wandel 
; und weitere Informationen daraus verarbeiten
 clr.w     laufwerk 
 move.l    rsrcaddr,a1
 moveq.l   #3,d7
cdefloop: 
 move.b    -(a2),d0 
 cmp.b     #'V',d0      ; 'V' in Dateiname ?
 bne.s     cdef1
 move.w    #$11,418(a1) ; ja, Verify an 
cdef1:
 cmp.b     #'A',d0      ; 'A' in Dateiname ?
 bne.s     cdef2
 move.w    #$11,154(a1) ; ja, Cache an, Drive A 
 or.w      #1,laufwerk
cdef2:
 cmp.b     #'B',d0      ; 'B' in Dateiname ?
 bne.s     cdef3
 move.w    #$11,178(a1) ; ja, Cache an, Drive B 
 or.w      #2,laufwerk
cdef3:
 cmp.b     #'F',d0      ; 'F' in Dateiname ?
 bne.s     cdef4
 move.w    #$11,394(a1) ; ja, Fastload an 
 move.l    buffer,a0    ; in Adresse des
 add.w     f_load,a0    ; "Fastload"-Bytes
 move.b    #$10,(a0)    ; Seek ohne Verify
cdef4:                  ; setzen
 cmp.b     #'_',d0      ; Abbruch bei '_' 
cdefnxt:
 dbeq.w    d7,cdefloop  ; nÑchstes Zeichen
; 
reserve:
 move.w    oldmxsec,d0  ; Cache-Grîsse
 cmp.w     maxsec,d0    ; geÑndert ?
 bne.s     res1         ; ja, weiter
 rts                    ; nein, Abbruch 
res1: 
 move.w    #-1,oldmxsec 
 tst.l     stat         ; schon RAM reserviert ?
 beq.s     no_mfree     ; nein, weiter
 bsr       mfree        ; ja, altes RAM freigeben 
 clr.l     stat         ; alte Adresse lîschen
no_mfree: 
 tst.w     maxsec       ; Cachegrîsse <> 0 Kb 
 bne.s     reserv1      ; Ja, weiter
no_cache: 
 move.l    rsrcaddr,a0
 move.w    #$10,154(a0) ; Cache Drive A 
 move.w    #$10,178(a0) ; und Drive B aus 
 clr.w     laufwerk 
 rts
reserv1:
 move.l    #-1,-(sp)    ; wieviel RAM ist frei ?
 move.w    #$48,-(sp) 
 trap      #1           ; Malloc (als Abfrage)
 addq.l    #6,sp
 sub.l     #10000,d0    ; 10000 Bytes min. Rest ? 
 bmi.s     res_err      ; nicht genug, Fehler 
 divu      #516,d0
 cmp.w     #2,d0        ; mindestens 2 Sektoren ? 
 blt.s     res_err      ; nein, zur Fehlermeldung 
 cmp.w     maxsec,d0    ; Grîsse mîglich ?
 bge.s     reserv2      ; ja, weiter
 move.w    d0,maxsec    ; max. Grîsse nehmen
reserv2:
 move.w    maxsec,d0    ; Cachegrîsse 
 mulu      #516,d0      ; * Grîsse Cachesektor
 add.l     #4872+255,d0 ; + Statistikbedarf 
 clr.b     d0           ; auf 256 Byte-Grenze 
 bsr.s     malloc       ; Speicher reservieren
 move.l    d0,stat      ; Startadresse merken 
 add.l     #4872,d0 
 move.l    d0,cache     ; Anfang Cachesektoren
 move.w    maxsec,oldmxsec
 bra.l     cache_del    ; Cache initialisieren
;                         und zurÅck
res_err:
 clr.w     maxsec       ; keine Cachesektoren 
 bra.s     no_cache     ; Cache Drive A+B aus 
; 
; spezielles Malloc fÅr Accessories 
malloc: 
 movem.l   d1-d5/a0-a3/a5,-(sp) 
 move.l    d0,d4
 move.l    pd,a5     ; Adresse Process-Descriptor 
 move.l    (a5),d5   ; Process-Descriptor (PD)
 move.l    #start-256,(a5) ; eigenen einsetzen
 move.l    #-1,-(sp)
 move.w    #$48,-(sp)   ; Wieviel RAM ist frei ?
 trap      #1 
 sub.l     d4,d0        ; - gewÅnschte LÑnge
 move.l    d0,2(sp)     ; wieder auf Stack
 trap      #1           ; Speicher reservieren
 move.l    d0,a3        ; Startadresse merken 
 move.l    d4,2(sp)     ; restl. Speicherblock
 trap      #1           ; am Speicherende reserv. 
 addq.l    #6,sp
 move.l    d0,d4        ; Startadresse merken 
 move.l    a3,-(sp)     ; ersten Block
 move.w    #$49,-(sp) 
 trap      #1           ; wieder freigeben
 addq.l    #6,sp
 move.l    d5,(a5)      ; alten PD einsetzen
 move.l    d4,d0        ; Startadresse nach d0
 movem.l   (sp)+,d1-d5/a0-a3/a5 
 rts
; spezielles Mfree
mfree:
 movem.l   d1-d2/d5/a0-a3/a5,-(sp)
 move.l    pd,a5
 move.l    (a5),d5      ; akt. PD merken
 move.l    #start-256,(a5) ; eigenen PD einsetzen 
 move.l    stat,-(sp)   ; Cachespeicher 
 move.w    #$49,-(sp) 
 trap      #1           ; freigeben 
 addq.l    #6,sp
 move.l    d5,(a5)      ; alten PD zurÅckholen
 movem.l   (sp)+,d1-d2/d5/a0-a3/a5
 rts
; 
copy: 
 move.l    a4,a0        ; Startadresse TOS
 move.l    buffer,a1    ; Zieladresse im RAM
 cmp.l     a0,a1        ; Disketten-TOS ? 
 beq.s     eintrag      ; ja, weiter
 move.w    #2075,d7     ; nein, ca. 8 Kbytes TOS
bb_loop:
 move.l    (a0)+,(a1)+  ; kopieren
 dbra.w    d7,bb_loop 
eintrag:
 move.w    #$476,a0     ; 'rwabs'-Vektor
 move.l    (a0),old_rwabs ; merken
 move.l    #rwabs,(a0)  ; eigene Routine setzen 
 move.l    8(a0),old_mediach ; 'mediach'-Vektor 
 move.l    #mediach,8(a0) ; eigene Routine setzen 
 move.l    buffer,a1
 add.w     trap14,a1
 move.l    a1,$b8       ; Trap #14 umlegen
 rts
;
; Grîssenangabe aus RSC-File lesen
get_size: 
 moveq.l   #2,d0
 clr.w     d1 
 bsr       rsrc_gaddr 
 move.l    addrout,a1 
 move.l    (a1),a1      ; Adresse Grîssenangabe 
wandel: 
 moveq.l   #2,d1        ; 3 Stellen (max. 999)
 clr.w     d2 
 moveq.l   #0,d0        ; Zahl lîschen
w_loop: 
 move.b    (a1)+,d2     ; Zeichen holen 
 cmp.b     #48,d2       ; Zeichen < '0' ? 
 blt.s     w_end
 cmp.b     #57,d2       ; > '9' ? 
 bgt.s     w_end
 sub.b     #48,d2       ; - ASC('0')
 add.w     d2,d0        ; Einerstelle addieren
 mulu      #10,d0       ; *10 
w_end:
 dbra.w    d1,w_loop    ; nÑchste Stelle
 divu      #10,d0       ; durch 10 = Grîsse in Kb 
 add.w     d0,d0        ; *2
 move.w    d0,maxsec    ; = Anzahl Cachesektoren
 rts
; 
; Einsprung aus 'floprd'
cache_out:
 lea       regsave,a0 
 movem.l   d1-d3/a1-a3,-(a0)
 move.w    drive,d2     ; Laufwerk
 addq.w    #1,d2
 and.w     laufwerk,d2  ; Cache von Drive aus ? 
 beq.s     cr_end       ; ja, Abbruch 
 bsr       get_para     ; Parameter holen 
 move.l    stat,a3      ; Statistikadresse
 add.w     d1,a3        ; Offset addieren 
c_outloop:
 move.l    cache,a1     ; Adresse Cachesektoren 
 lea       -514(a1),a1  ; zurÅcksetzen
 move.w    maxsec,d2    ; Anzahl Sektoren 
 subq.w    #1,d2        ; minus 1 
cout1:
 lea       516(a1),a1 
 cmp.w     (a1),d1      ; Sektor in Cache ? 
 dbeq.w    d2,cout1 
 bne.s     cr_end       ; nein, dann Ende 
co_found: 
 addq.l    #2,a1
 addq.b    #1,-4(a1)    ; Statistik +1
 move.l    8(sp),a2     ; Bufferadresse 
 move.l    a2,d3
 bsr.s     fastcopy 
nxt_sec:
 addq.b    #1,(a3)     ; Statistik +1 
 bsr       stat_reset  ; StatistikÅberlauf ?
 addq.l    #4,a3       ; nÑchste Statistikadresse 
 addq.w    #4,d1       ; nÑchste relative Statistikadresse
 add.l     #512,8(sp)  ; Bufferadresse+512
 addq.w    #1,18(sp)   ; Sektor-Nr. plus 1
 subq.w    #1,24(sp)   ; Anzahl Sektoren minus 1
 bne.s     c_outloop   ; war's das ?
 moveq.l   #0,d0       ; Ok 
cr_end: 
 movem.l   (a0)+,d1-d3/a1-a3
 rts
;
fastcopy: 
 btst      #0,d3        ; Ist a2 (d3) gerade ?
 bne.s     bytecopy     ; nein, dann Bytecopy 
 moveq.l   #15,d3 
longcopy: 
 move.l    (a1)+,(a2)+  ; 512 Bytes aus Buffer in 
 move.l    (a1)+,(a2)+  ; Cache schreiben 
 move.l    (a1)+,(a2)+
 move.l    (a1)+,(a2)+
 move.l    (a1)+,(a2)+
 move.l    (a1)+,(a2)+
 move.l    (a1)+,(a2)+
 move.l    (a1)+,(a2)+
 dbra.w    d3,longcopy
 rts
; Byteweises Kopieren (fÅr ungerade Adressen) 
bytecopy: 
 moveq.l   #63,d3 
f_bcloop: 
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 move.b    (a1)+,(a2)+
 dbra.w    d3,f_bcloop
 rts
; 
get_para:             ; Parameter vom Stack holen 
 subq.w    #1,d2
 add.w     d2,d2        ; Laufwerk*2
 add.w     26(sp),d2    ; +Seite
 move.w    22(sp),d1    ; Sektor
 subq.w    #1,d1
 lsl.w     #2,d1        ; *4
 add.w     d2,d1        ; +Laufwerk+Seite 
 move.w    24(sp),d2    ; Track 
 mulu      #14*4,d2     ; *14 Sektoren
 add.w     d2,d1        ; +Sektoradresse
 rts
; 
; Einsprung aus 'floprd'
cache_in: 
 sf        write        ; Leseoperation 
 bra.s     cinstart 
; Einsprung aus 'flopwr'
cache2in: 
 st        write        ; Schreiboperation
cinstart: 
 lea       regsave,a0 
 movem.l   d0-d7/a1-a4/a6,-(a0) 
 move.w    drive,d2     ; Laufwerk
 addq.w    #1,d2
 and.w     laufwerk,d2  ; Cache von Drive aus ? 
 beq.l     sc_end       ; ja, Abbruch 
 tst.b     write        ; Schreiboperation ?
 bne.s     c1in         ; ja, Sperre ignorieren 
 and.w     sperre,d2    ; Cache gesperrt ?
 beq.l     sc_end       ; ja, Abbruch 
c1in: 
 bsr.s     get_para     ; Parameter holen 
 move.l    stat,a4      ; Statistikadresse
 add.w     d1,a4        ; Offset addieren 
 move.w    24(sp),d5    ; Anzahl der Sektoren 
 subq.w    #1,d5        ; -1 (fÅr Schleife) 
 move.l    8(sp),a3     ; Bufferadresse 
c_inloop: 
 addq.b    #1,(a4)      ; Statistik+1 
 bsr       stat_reset   ; StatistikÅberlauf ? 
; 
 tst.b     write        ; Leseoperation ? 
 beq.s     c_read       ; dann, weiter
; *** nur bei Schreiboperationen ***
 move.l    cache,a2     ; Adresse Cachesektoren 
 lea       -514(a2),a2  ; zurÅcksetzen
 move.w    maxsec,d2    ; Anzahl Sektoren 
 subq.w    #1,d2        ; minus 1 
cin1: 
 lea       516(a2),a2 
 cmp.w     (a2),d1      ; Sektor im Cache ? 
 dbeq.w    d2,cin1      ; nein, nÑchsten testen 
 bne.s     nxt_ci       ; nichts, nÑchster Sektor 
 move.l    #$FFFF,-2(a2) ; Cachesektor lîschen
 bra.s     nxt_ci       ; nÑchster Sektor 
; *** nur bei Leseoperationen *** 
c_read: 
 move.b    (a4),d4      ; Statistikwert 
 cmp.b     min_stat,d4  ; > Statistik-Minimum ? 
 ble.s     nxt_ci       ; nein, nÑchster Sektor 
 move.b    d4,d6
 move.w    maxsec,d7    ; ges. Anzahl Sektoren
 subq.w    #1,d7
 move.l    cache,a2     ; Anfang Cachesektoren
 lea       -516(a2),a2  ; eine SektorlÑnge zurÅck 
secloop:
 lea       516(a2),a2   ; nÑchster Sektor 
 cmp.b     (a2),d6      ; Sektorstatistikwert <= Cachestatistikwert ? 
 dbgt.w    d7,secloop 
 tst.w     d7          ; alle Sektoren getestet ? 
 bmi.s     scl_end     ; ja, dann weiter
 move.b    (a2),d6     ; Statistikwert Åbernehmen 
 bne.s     sc_belegt   ; Sektor belegt ?
 clr.b     min_stat    ; Statistik-Minimum auf 0
 bra.s     sc_copy     ; und ab zum Kopieren
sc_belegt:
 move.l    a2,a6
 subq.w    #1,d7       ; SektorzÑhler -1
 bpl.s     secloop     ; schon alle Sektoren ?
scl_end:
 move.b    d6,min_stat ; Statistik-Minimum
 cmp.b     d4,d6       ; Sektor gefunden ?
 bge.s     nxt_ci      ; nein 
 move.l    a6,a2       ; ja, Sektoradresse merken 
sc_copy:
 move.b    (a4),(a2)   ; Statistikwert vor Cache-Sektor schreiben 
 move.w    d1,2(a2)    ; und auch die relative Statistikadressse
 move.l    a3,a1       ; Bufferadresse
 move.l    a1,d3       ; nach d3
 addq.l    #4,a2       ; Start der Cachedaten 
 bsr       fastcopy    ; Buffer in Cache kopieren 
nxt_ci: 
 addq.l    #4,a4       ; nÑchste Statistikadresse 
 addq.w    #4,d1       ; nÑchste relative Statistikadresse
 lea       512(a3),a3  ; Bufferadresse +512 
 dbra.w    d5,c_inloop ; nÑchster Sektor
sc_end: 
 movem.l   (a0)+,d0-d7/a1-a4/a6 
 rts
; 
; Daten einer gewechselten Diskette lîschen 
disc_changed: 
 tst.w     maxsec       ; Cachegrîsse=0 ? 
 beq.s     dc_end       ; dann Abbruch
 move.l    stat,a0      ; Statistikadresse
 add.w     d3,d3        ; Drive-Nr. *2
 add.w     d3,a0        ; Basisadresse von Drive
dc_anf: 
 clr.b     min_stat    ; Statistikminimum auf 0 
 move.w    #1217,d2    ; 1218 *2 Statistiksektoren
dc_del: 
 clr.w     (a0)         ; Statistikwerte lîschen
 addq.w    #4,a0        ; nÑchster Sektor 
 dbra.w    d2,dc_del
; Verwaltungsdaten vor den Cachesektoren lîschen
 move.l    cache,a0     ; Adresse Cachesektoren 
 move.w    maxsec,d1    ; Anzahl Sektoren 
 subq.w    #1,d1        ; minus 1 
 move.l    #$FFFF,d2    ; d2 vorbelegen 
 cmp.b     #2,d3        ; Drive 2 ? 
 beq.s     drive_2      ; ja, Daten lîschen 
drive_1:
 btst      #1,3(a0)    ; Cachedaten Drive 1 ? 
 bne.s     d1_nxt      ; nein, weiter 
 move.l    d2,(a0)     ; Statistik=0, 
;                        rel. Statistikadresse=-1 
d1_nxt: 
 lea       516(a0),a0  ; nÑchster Sektor
 dbra.w    d1,drive_1 
 bra.s     dc_end 
drive_2:
 btst      #1,3(a0)    ; Cachedaten Drive 2 ? 
 beq.s     d2_nxt      ; nein, weiter 
 move.l    d2,(a0)     ; Statistik=0, 
;                        rel. Statistikadresse=-1 
d2_nxt: 
 lea       516(a0),a0  ; nÑchster Sektor
 dbra.w    d1,drive_2 
dc_end: 
 rts
; 
cache_del:              ; Alle Cachedaten lîschen 
 tst.w     maxsec       ; Cachegrîsse=0 ? 
 beq.s     cd_end       ; dann Abbruch
 movem.l   d0/d7/a1,-(sp) 
 move.l    stat,a1      ; Statistikadresse
 move.w    #1217,d7     ; 4872 Statistiksektoren
; 87 Tracks * 14 Sektoren * 2 Drives * 2 Seiten 
cd_del:                 ; Statistik lîschen 
 clr.l     (a1)+        ; (4 Bytes = 4 Sektoren)
 dbra.w    d7,cd_del
 move.l    cache,a1     ; Adresse Cachesektoren 
 move.w    maxsec,d7    ; Anzahl Cachesektoren
 subq.w    #1,d7        ; minus 1 (fÅr Schleife)
 move.l    #$FFFF,d0    ; d0 vorbelegen 
ccloop: 
 move.l    d0,(a1)      ; Daten lîschen 
 lea       516(a1),a1   ; nÑchster Sektor 
 dbra.w    d7,ccloop
 clr.b     min_stat     ; Statistikminimum auf 0
 movem.l   (sp)+,d0/d7/a1 
cd_end: 
 rts
;
; bei öberlauf eines Statistikwertes alle 
; Statistikwerte wieder auf 1 setzen
stat_reset: 
 bpl.s     sr_end       ; Statistikwert positiv ? 
;                         dann Abbruch
 tst.w     maxsec       ; Cachegrîsse=0 ? 
 beq.s     sr_end       ; dann Abbruch
 movem.l   d0-d1/a0-a1,-(sp)
 move.l    stat,a0      ; Statistikadresse
 move.l    cache,a1     ; Adresse Cachesektoren 
 move.w    maxsec,d0    ; Anzahl Cachesektoren
 subq.w    #1,d0        ; minus 1 (fÅr Schleife)
sr_loop:
 tst.w     (a1)         ; Sektor nicht belegt ? 
 beq.s     sr_nxt       ; dann nÑchster Sektor
 move.w    #$100,(a1)+  ; Statistikwert auf 1 
 move.w    (a1)+,d1     ; rel. Statistikadresse 
 move.b    #1,(a0,d1.w) ; Tabellenwert=1
sr_nxt: 
 dbra.w    d0,sr_loop   ; nÑchster Sektor 
 movem.l   (sp)+,d0-d1/a0-a1
 clr.b     min_stat     ; Statistikminimum auf 0
sr_end: 
 rts
; 
floprd: 
 move.l    (sp),retfloprd ; Returnadresse merken
 move.w    12(sp),drive ; Laufwerks-Nr. holen 
 bsr       cache_out    ; Sektor(en aus Cache 
 tst.w     d0           ; alles eingelesen ?
 beq.s     flprdend     ; ja, dann Ende 
 move.l    #frd_nxt,(sp) ; neue Returnadresse 
 move.l    flp_rd,a0    ; in TOS-'floprd'-Routine 
 jmp       (a0)         ; springen
frd_nxt:
 move.l    retfloprd,-(sp) ; alte Returnadresse 
 bsr       cache_in     ; nein,Sektor(en einlesen 
flprdend: 
 rts
; 
flopwr: 
 move.l    (sp),retflopwr ; Returnadresse merken
 move.w    12(sp),d0      ; Laufwerks-Nr. holen 
 move.w    d0,drive 
 clr.w     $444           ; '_fverify' lîschen
 move.l    rsrcaddr,a0
 cmp.w     #$11,418(a0)   ; Verify an ? 
 seq       $444         ; dann '_fverify' setzen
 move.l    #fwr_nxt,(sp) ; neue Returnadresse 
 move.l    flp_wr,a0    ; in TOS-'flopwr'-Routine 
 jmp       (a0)         ; springen
fwr_nxt:
 move.l    retflopwr,-(sp) ; alte Returnadresse 
 bsr       cache2in     ; Cachesektoren lîschen 
flpwrend: 
 rts
; 
 dc.b 'XBRA','ST-C'     ; "XBRA"-Kennung
old_mediach:
 dc.l 0                 ; alte 'mediach'-Adresse
mediach:
 move.l    (sp),retmediach ; Returnadresse merken 
 move.l    #mdc_nxt,(sp)   ; neue Returnadresse 
 move.l    old_mediach,a0  ; TOS-'mediach'
 jmp       (a0)            ; anspringen 
mdc_nxt:
 move.l    retmediach,-(sp) ; alte Returnadresse
 cmp.w     #1,d0        ; Diskette gewechselt ? 
 ble.s     mdc_end      ; nein, Ende
 move.w    4(sp),d3     ; Drive-Nr. holen 
 bra.l     disc_changed ; Cachedaten lîschen
mdc_end:
 rts
; 
 dc.b 'XBRA','ST-C'     ; "XBRA"-Kennung
old_rwabs:
 dc.l 0                 ; alte 'rwabs'-Adresse
rwabs:
 move.l    (sp),retrwabs ; Returnadresse merken 
 move.l    #rwabs0,(sp)  ; neue Returnadresse 
 move.l    buffer,a0
 add.w     rw_abs,a0    ; in TOS-'rwabs'-Routine
 jmp       (a0)         ; springen
rwabs0: 
 move.l    retrwabs,-(sp) ; alte Returnadresse
 cmp.l     #-15,d0      ; Fehler 'unbek. GerÑt' ? 
 bne.s     rwabs1       ; nein, weiter
 move.l    old_rwabs,a0 ; alte Routine anspringen 
 jmp       (a0) 
rwabs1: 
 move.w    14(sp),d3    ; Drive-Nr. nach d3 
 cmp.w     #-14,d0      ; Diskette gewechselt ? 
 beq.l     disc_changed ; ja, Cachedaten lîschen
 rts
; 
; Einige GEM-Aufrufe: 
form_center:
 move.w    #54,contrl 
 move.l    #5,contrl+2
 move.l    #$10000,contrl+6 
 move.l    rsrcaddr,addrin
 bsr       aes
 move.l    intout+2,size
 move.l    intout+6,size+4
 rts
form_dial:
 move.w    #51,contrl 
 move.l    #$90001,contrl+2 
 move.l    #$10000,contrl+6 
 move.w    d0,intin 
 clr.l     intin+2
 clr.l     intin+6
 move.l    size,intin+10
 move.l    size+4,intin+14
 bra.s     aes
form_do:
 move.w    #50,contrl 
 move.l    #$10001,contrl+2 
 move.l    #$10000,contrl+6 
 move.w    #9,intin 
 move.l    rsrcaddr,addrin
 bra.s     aes
form_alert: 
 move.w    #52,contrl 
 move.l    #$10001,contrl+2 
 move.l    #$10000,contrl+6 
 move.w    #1,intin 
 move.l    a0,addrin
aes:
 move.l    #aespb,d1
 move.l    #$C8,d0
 trap      #2 
 rts
obj_draw: 
 move.w    #42,contrl 
 move.l    #$60001,contrl+2 
 move.l    #$10000,contrl+6 
 move.l    #4,intin 
 move.l    size,intin+4 
 move.l    size+4,intin+8 
 move.l    rsrcaddr,addrin
 bra.s     aes
evnt_mesag: 
 move.w    #23,contrl 
 move.l    #1,contrl+2
 move.l    #$10000,contrl+6 
 move.l    #ev_buff,addrin
 bra.s     aes
menu_register:
 move.w    #35,contrl 
 move.l    #$10001,contrl+2 
 move.l    #$10000,contrl+6 
 move.w    ap_id,intin
 move.l    #acc_name,addrin 
 bsr       aes
 move.w    intout,acc_id ; Accessory-Nr. merken 
 rts
rsrc_load:
 move.w    #110,contrl
 move.l    #$1,contrl+2 
 move.l    #$10000,contrl+6 
 move.l    #rsrcname,addrin 
 bsr       aes
 tst.w     intout       ; Fehler ?
 bne.s     rsrclend     ; nein, Ende
 move.b    #4+48,fehler ; Fehlernummer
rsrclend: 
 rts
rsrc_gaddr: 
 move.w    #112,contrl
 move.l    #$20001,contrl+2 
 move.l    #$1,contrl+6 
 move.w    d0,intin 
 move.w    d1,intin+2 
 bsr       aes
 tst.w     intout       ; Fehler ?
 bne.s     rg_end       ; nein, Ende
 move.b    #5+48,fehler ; Fehlernummer
rg_end: 
 rts
appl_init:
 move.w    #10,contrl 
 move.l    #1,contrl+2
 clr.l     contrl+6 
 bsr       aes
 move.w    intout,ap_id 
 rts
; 
retfloprd  dc.l 0 
retflopwr  dc.l 0 
retmediach dc.l 0 
retrwabs   dc.l 0 
rsrcaddr dc.l 0 
pd       dc.l $602C 
sysbase  dc.l 0 
tos_adr  dc.w 5     ; Anzahl der Adressblîcke - 1 
adr_1_0  dc.l $02061986,$FC0000 
         dc.w $748,$1B8F,$10D2,$1260
         dc.w $13C8,$1232,$1296,$7F0
adr_1_0d dc.l $02061986,$6100 
         dc.w $4D6,$191D,$E60,$FEE
         dc.w $1156,$FC0,$1024,$57E 
adr_1_2  dc.l $04221987,$FC0000 
         dc.w $7F2,$1D8F,$12B6,$1444
         dc.w $15AC,$1416,$147A,$89A
adr_1_4  dc.l $04061989,$FC0000 
         dc.w $7C4,$1517,$1A24,$1BAE
         dc.w $1CF4,$1B82,$1BE2,$86C
adr_1_6  dc.l $06191989,$E00000 
         dc.w $862,$15DB,$1AE8,$1C72
         dc.w $1DB8,$1C46,$1CA6,$922
adr_1_6n dc.l $07291989,$E00000 
         dc.w $93A,$16DF,$1BFC,$1D86
         dc.w $1ECC,$1D5A,$1DBA,$9FA
trap14   dc.w 0 
flp_rd   dc.l 0 
flp_wr   dc.l 0 
rw_abs   dc.w 0 
f_load   dc.w 0 
drive    dc.w 0 
oldmxsec dc.w -1
maxsec   dc.w 0 
sperre   dc.w 3 
laufwerk dc.w 0 
ap_id    dc.w 0 
acc_id   dc.w -1
acc_name dc.b '  ST-CACHE ',0 
f_name   dc.b '\STC_*.*',0
rsrcname dc.b '\ST_CACHE.RSC',0 
err_txt  dc.b 91,'1]' 
         dc.b 91,'ST-CACHE Version 2.71| |' 
         dc.b 'Fehler #'
fehler   dc.b 0 
         dc.b ' bei Installation|aufgetreten...]' 
         dc.b 91,'  Ok  ]',0
write    dc.b 0 
min_stat dc.b 0 
; 
; * Voreinstellung (Format wie Steuerdatei-Name): 
filename dc.b 'STC_ABVF.128'
; 
size     dc.l 0,0 
buffer   dc.l 0 
stat     dc.l 0 
cache    dc.l 0 
aespb    dc.l contrl,global,intin 
         dc.l intout,addrin,addrout 
contrl   ds.w 11
global   ds.w 15
intin    ds.w 128 
intout   ds.w 128 
addrin   ds.w 128 
addrout  ds.w 128 
ev_buff  ds.l 4 
dta      ds.b 44
         ds.l 12
regsave  ds.b $100
stack:
 END
