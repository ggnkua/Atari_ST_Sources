
;Turbo Packer by Wolfgang Mayerle in 1990  -  Version 9.9.1990

               movea.l   4(sp),a0       ;
               lea.l     stack,sp       ;
               lea.l     buf,a6         ;
               move.l    4(a0),d0       ;
               subi.l    #$2000,d0      ;
               move.l    d0,d1          ;
               sub.l     (a0),d0        ;
               sub.l     a6,d1          ;
               subi.l    #$8000,d1      ;
               move.l    d1,max_length  ;
               move.l    d0,-(sp)       ;Speicher freigeben
               move.l    a0,-(sp)       ;
               clr.w     -(sp)          ;
               move.w    #$4a,-(sp)     ;
               trap      #1             ;
               lea.l     12(sp),sp      ;
               lea.l     source_path,a0 ;
               lea.l     dest_path,a1   ;
               move.l    #'A:\*',d0     ;
               move.l    d0,(a0)+       ;
               move.l    d0,(a1)+       ;
               move.w    #'.*',d0       ;
               move.w    d0,(a0)+       ;
               move.w    d0,(a1)+       ;
               not.w     success        ;
               .DC.w $a00a              ;

menu1:         lea.l     name_fs,a0     ;MenÅ
               clr.b     (a0)           ;
               lea.l     menu,a0        ;
               bsr       print          ;
               clr.w     d5             ;
               move.b    source_path,d5 ;
               bsr       conout+4       ;
               lea.l     drive2,a0      ;
               bsr       print          ;
               clr.w     d5             ;
               move.b    dest_path,d5   ;
               bsr       conout+4       ;
menu4:         lea.l     skiptext1,a0   ;
               tst.w     skipflag       ;
               beq.s     *+6            ;
               lea.l     skiptext2(pc),a0
               bsr       print          ;
menu3:         lea.l     cr_off,a0      ;
               bsr       print          ;
menu2:         bsr       getkey         ;
               cmpi.w    #'P',d0        ;
               beq       pack_file      ;
               cmpi.w    #'C',d0        ;
               beq       create         ;
               cmpi.w    #'D',d0        ;
               beq.s     drives         ;
               cmpi.w    #'S',d0        ;
               beq.s     switch         ;
               cmpi.w    #'I',d0        ;
               beq.s     info           ;
               cmpi.w    #'Q',d0        ;
               bne.s     menu2          ;
               .DC.w $a009              ;
               clr.w     -(sp)          ;
               trap      #1             ;

info:          lea.l     info_txt,a0    ;Info ausgeben
               bsr       print          ;
               bsr       getkey         ;
               bra       menu1          ;

switch:        not.w     skipflag       ;Switch skipflag
               bra.s     menu4          ;

drives:        lea.l     drive1,a0      ;Laufwerke auswÑhlen
               bsr       print          ;
               move.w    #$a,-(sp)      ;Drive-Map
               trap      #13            ;
               addq.l    #2,sp          ;
               move.l    d0,d3          ;
               lea.l     source_path,a3 ;
               bsr.s     drives1        ;
               bmi.s     drives3        ;
               lea.l     drive2,a0      ;
               bsr       print          ;
               lea.l     dest_path,a3   ;
               bsr.s     drives1        ;
drives3:       bra       menu3          ;
drives1:       bsr       getkey         ;
               move.w    d0,d5          ;
               subi.w    #'A',d0        ;
               bmi.s     drives2        ;
               btst      d0,d3          ;
               beq.s     drives1        ;
               move.b    d5,(a3)        ;
               bsr       conout+4       ;
               moveq.l   #0,d0          ;
drives2:       rts                      ;

pack_file:     lea.l     load,a0        ;Option File packen
               bsr       print          ;
               bsr       file_source    ;
               beq       menu1          ;
               clr.w     autoflag       ;
               lea.l     name_fs,a0     ;
               tst.b     (a0)           ;
               bne.s     no_auto        ;
               addq.w    #1,autoflag    ;
               bsr       cr_path        ;
               beq       menu1          ;
               bsr       set_source     ;
               movea.l   a3,a0          ;
               addq.l    #1,a0          ;
no_auto:       clr.w     -(sp)          ;Sfirst
               pea       (a0)           ;
               .DC.w $a009              ;
               move.w    #$4e,-(sp)     ;
               trap      #1             ;
               addq.l    #8,sp          ;
               tst.w     d0             ;
               bmi       error          ;
auto2:         .DC.w $a00a              ;
               lea.l     loading,a0     ;File laden
               bsr       msg_name       ;
               move.l    length,d0      ;
               cmp.l     max_length,d0  ;
               bgt       o_o_memory     ;
               cmpi.l    #1025,d0       ;
               blt       skipfile       ;
               bsr       read           ;
               bmi       error          ;
               .DC.w $a00a              ;
               cmpi.l    #'TPWM',(a6)   ;
               bne.s     nodouble       ;
               lea.l     doubletrouble,a0
               bra       skip2          ;
nodouble:      clr.w     execflag       ;
               cmpi.w    #$601a,(a6)    ;Auswahl des Packverfahrens
               beq.s     exec_file1     ;
               lea.l     data_file,a0   ;
               bsr       print          ;
               bra       start_pack     ;
exec_file1:    lea.l     exec_file,a0   ;
               bsr       print          ;
exec_file2:    bsr       getkey         ;
               move.w    d0,d5          ;
               cmpi.w    #'D',d5        ;
               beq.s     data_file3     ;
               cmpi.w    #'E',d5        ;
               bne.s     exec_file2     ;
data_file3:    bsr       conout+4       ;
               cmpi.w    #'D',d5        ;
               beq       start_pack     ;
yes_symb:      lea.l     $1c(a6),a3     ;Symboltabelle ggf. rauswerfen
               adda.l    2(a6),a3       ;
               adda.l    6(a6),a3       ;a3: Zeiger auf Symbol-Tabelle
               movea.l   a3,a4          ;
               adda.l    $e(a6),a4      ;a4: Zeiger auf Relozier-Tabelle
               movea.l   a6,a5          ;
               adda.l    d6,a5          ;a5: Zeiger auf Ende
               cmpa.l    a3,a4          ;
               beq.s     no_symb        ;
               move.b    (a4)+,(a3)+    ;
               cmpa.l    a5,a4          ;
               blt.s     *-4            ;
               sub.l     $e(a6),d6      ;
               clr.l     $e(a6)         ;
               lea.l     symbols,a0     ;
               bsr       print          ;
               bra.s     yes_symb       ;
no_symb:       move.l    a5,d0          ;Relo-Tab in Ordnung?
               sub.l     a4,d0          ;
               moveq.l   #4,d1          ;
               cmp.l     d1,d0          ;
               bge.s     test_bytes     ;
               clr.l     (a4)+          ;
               bra.s     calc_relo      ;
test_bytes:    tst.l     (a4)+          ;
               beq.s     calc_relo      ;
               cmpa.l    a5,a4          ;
               beq.s     corr           ;
               tst.b     (a4)+          ;
               beq.s     calc_relo      ;
               bra.s     *-8            ;
corr:          clr.b     (a4)+          ;
calc_relo:     move.l    a4,d0          ;
               sub.l     a6,d0          ;
               cmp.l     d0,d6          ;
               beq.s     relo_ok        ;
               move.l    d0,d6          ;
               lea.l     relo,a0        ;
               bsr       print          ;
relo_ok:       addq.w    #1,execflag    ;
start_pack:    lea.l     packing,a0     ;Packen
               bsr       msg_name       ;
               lea.l     text12,a0      ;
               bsr       print          ;
               bsr       packer         ;
               beq       o_o_memory     ;
               cmpi.w    #-5,d3         ;
               bgt       skipfile       ;
               tst.w     autoflag       ;
               bne.s     auto1          ;
               lea.l     result,a0      ;Ergebnis ausgeben
               bsr       print          ;
               bsr       prtdec         ;
               bsr       file_dest      ;
               beq       menu1          ;
               lea.l     name_fs,a0     ;
               lea.l     name,a1        ;
               tst.b     (a0)           ;
               beq       menu1          ;
               move.b    (a0)+,(a1)+    ;
               bne.s     *-2            ;
auto1:         lea.l     saving,a0      ;File speichern
               bsr       msg_name       ;
               .DC.w $a009              ;
               bsr       createf        ;
               bmi       error          ;
               tst.w     execflag       ;
               beq.s     data_file2     ;
               addq.l    #1,d6          ;Data-Teil bei Exec-Programmen gerade
               bclr      #0,d6          ;
               move.l    d6,length_p    ;LÑnge gepackt in Overhead schreiben
               addq.l    #4,d6          ;+4 fÅr Relo-Tab
               lea.l     ent1,a0        ;
               move.l    #ent2-ent1-4,d0
               bsr       write          ;
               bra.s     exec_file3     ;
data_file2:    lea.l     code,a0        ;
               moveq.l   #4,d0          ;
               bsr       write          ;
exec_file3:    lea.l     length_up,a0   ;
               moveq.l   #4,d0          ;
               bsr       write          ;
               movea.l   a6,a0          ;
               move.l    d6,d0          ;
               bsr       write          ;
               move.l    d0,-(sp)       ;
               bsr       close          ;
               cmp.l     (sp)+,d6       ;
               bne       error          ;
               .DC.w $a00a              ;
               lea.l     cls,a0         ;
               bsr       print          ;
               bra.s     packnext       ;
skipfile:      lea.l     skipped,a0     ;
skip2:         bsr       print          ;
               moveq.l   #4,d0          ;
               moveq.l   #-1,d1         ;
               dbra      d1,*           ;
               dbra      d0,*-6         ;
               tst.w     autoflag       ;
               beq       packnext       ;
               tst.w     skipflag       ;
               beq       packnext       ;
               lea.l     copying,a0     ;
               bsr       msg_name       ;
               bsr       read           ;
               bmi       error          ;
               bsr       createf        ;
               bmi       error          ;
               movea.l   a6,a0          ;
               move.l    d6,d0          ;
               bsr       write          ;
               move.l    d0,-(sp)       ;
               bsr       close          ;
               cmp.l     (sp)+,d6       ;
               bne       error          ;
packnext:      tst.w     autoflag       ;
               beq       pack_file      ;
               bsr       set_source     ;
               .DC.w $a009              ;
               move.w    #$4f,-(sp)     ;
               trap      #1             ;
               addq.l    #2,sp          ;
               tst.w     d0             ;
               beq       auto2          ;
               cmpi.w    #-49,d0        ;
               bne       error          ;
               .DC.w $a00a              ;
               bra       menu1          ;
o_o_memory:    lea.l     memory,a0      ;Zu wenig freier Speicher
               bsr       print          ;
               bsr       getkey         ;
               bra.s     packnext       ;
read:          .DC.w $a009              ;File laden
               bsr       set_source     ;
               clr.w     -(sp)          ;
               pea       name           ;
               move.w    #$3d,-(sp)     ;
               trap      #1             ;
               addq.l    #8,sp          ;
               move.w    d0,d7          ;
               bmi       error1         ;
               pea       (a6)           ;
               pea       $ffffff        ;
               move.w    d7,-(sp)       ;
               move.w    #$3f,-(sp)     ;
               trap      #1             ;
               lea.l     12(sp),sp      ;
               move.l    d0,d6          ;
               bsr.s     close          ;
               bmi.s     error1         ;
               tst.l     d6             ;
error1:        rts                      ;
createf:       bsr       set_dest       ;Neues File erstellen
               clr.w     -(sp)          ;
               pea       name           ;
               move.w    #$3c,-(sp)     ;
               trap      #1             ;
               addq.l    #8,sp          ;
               move.w    d0,d7          ;
               rts                      ;
close:         move.w    d7,-(sp)       ;File schliessen
               move.w    #$3e,-(sp)     ;
               trap      #1             ;
               addq.l    #4,sp          ;
               tst.l     d0             ;
               rts                      ;

create:        bsr       cr_path        ;DECOMP.PRG erstellen
               beq       menu1          ;
               .DC.w $a009              ;
               clr.w     -(sp)          ;
               pea       decomp         ;
               move.w    #$3c,-(sp)     ;
               trap      #1             ;
               addq.l    #8,sp          ;
               move.w    d0,d7          ;
               bmi       error          ;
               lea.l     ent3,a0        ;
               move.l    #top-ent3+4,d6 ;
               move.l    d6,d0          ;
               bsr       write          ;
               move.l    d0,-(sp)       ;
               move.w    d7,-(sp)       ;
               move.w    #$3e,-(sp)     ;
               trap      #1             ;
               addq.l    #4,sp          ;
               cmp.l     (sp)+,d6       ;
               bne.s     error          ;
               .DC.w $a00a              ;
               bra       menu1          ;

error:         .DC.w $a00a              ;I/O Fehler
               lea.l     io_error,a0    ;
               bsr       print          ;
               bsr       getkey         ;
               bra       menu1          ;

cr_path:       lea.l     name_fs,a5     ;Destination-Pfad setzen und ggf.
               lea.l     select_dd,a0   ; Ordner erstellen
               bsr       print          ;
               bsr       file_dest      ;
               beq.s     dest_path1     ;
               tst.b     (a5)           ;
               beq.s     dest_path2     ;
               .DC.w $a009              ;
               pea       (a5)           ;Makedir
               move.w    #$39,-(sp)     ;
               trap      #1             ;
               addq.l    #6,sp          ;
               move.w    d0,-(sp)       ;
               .DC.w $a00a              ;
               tst.w     (sp)+          ;
               bne.s     dest_path1     ;
               addq.l    #1,a3          ;
               move.b    (a5)+,(a3)+    ;
               bne.s     *-2            ;
               subq.l    #1,a3          ;
               move.b    #'\',(a3)+     ;
               move.b    #'*',(a3)+     ;
               move.b    #'.',(a3)+     ;
               move.b    #'*',(a3)+     ;
               clr.b     (a3)           ;
               bsr       set_path       ;
dest_path2:    moveq.l   #1,d0          ;
               rts                      ;
dest_path1:    moveq.l   #0,d0          ;
               rts                      ;

file_source:   bsr.s     set_source     ;Source/Destination-Fileselectbox
               bra.s     *+4            ;
file_dest:     bsr.s     set_dest       ;
               bsr.s     fileselect     ;
               beq.s     *+4            ;
               bra.s     set_path       ;
               rts                      ;

fileselect:    move.l    a4,addrin      ;Fileselect-Box aufrufen
               .DC.w $a009              ;
               move.l    #aespara,d1    ;
               move.w    #$c8,d0        ;
               trap      #2             ;
               .DC.w $a00a              ;
               lea.l     cls,a0         ;
               bsr       print          ;
               pea       dta            ;Set dta
               move.w    #$1a,-(sp)     ;
               trap      #1             ;
               addq.l    #6,sp          ;
               tst.w     intout+2       ;Abbruch?
               rts                      ;

set_source:    lea.l     source_path,a4 ;Source/Destination-Pfad setzen
               bra.s     set_path       ;
set_dest:      lea.l     dest_path,a4   ;
set_path:      movea.l   a4,a3          ;Laufwerk und Pfad setzen/Åbernehmen
               clr.w     d0             ;
               move.b    (a3),d0        ;
               subi.b    #$41,d0        ;
               move.w    d0,-(sp)       ;
               move.w    #$e,-(sp)      ;
               trap      #1             ;
               addq.l    #4,sp          ;
               tst.b     (a3)+          ;
               bne.s     *-2            ;
               cmpi.b    #'\',-(a3)     ;
               bne.s     *-4            ;
               move.b    1(a3),-(sp)    ;
               clr.b     1(a3)          ;
               pea       (a4)           ;
               move.w    #$3b,-(sp)     ;
               trap      #1             ;
               addq.l    #6,sp          ;
               move.b    (sp)+,1(a3)    ;
               rts                      ;

getkey:        move.w    #7,-(sp)       ;Auf Taste warten
               trap      #1             ;
               addq.l    #2,sp          ;
               bclr      #5,d0          ;
               rts                      ;

write:         pea       (a0)           ;File schreiben
               move.l    d0,-(sp)       ;
               move.w    d7,-(sp)       ;
               move.w    #$40,-(sp)     ;
               trap      #1             ;
               lea.l     12(sp),sp      ;
               rts                      ;

msg_name:      bsr       print          ;Print Message und Name
               lea.l     name,a0        ;
print:         pea       (a0)           ;Text ausgeben
               move.w    #9,-(sp)       ;
               trap      #1             ;
               addq.l    #6,sp          ;
               rts                      ;

prtdec:        moveq.l   #' ',d5        ;Wert in d3 als Dezimalzahl ausgeben
               ext.l     d3             ;
               bpl.s     *+6            ;
               moveq.l   #'-',d5        ;
               neg.l     d3             ;
               bsr.s     conout+4       ;
               move.l    d3,d5          ;
               cmpi.w    #99,d5         ;
               ble.s     *+4            ;
               moveq.l   #99,d5         ;
               divu.w    #10,d5         ;
               bsr.s     conout         ;
               swap.w    d5             ;
conout:        addi.w    #$30,d5        ;Ziffer in d5 ausgeben
               move.w    d5,-(sp)       ;
               move.w    #2,-(sp)       ;
               trap      #1             ;
               addq.l    #4,sp          ;
               rts                      ;

;Packer-----------------------------------------------------------------------

packer:        movem.l   d0-d5/a0-a5,-(sp)
               movea.l   a6,a0          ;Endadresse errechnen
               lea.l     0(a0,d6.l),a1  ;
               movea.l   a0,a2          ;Aktuell ungepackt = Startadresse
               movea.l   a1,a3          ;Aktuell gepackt = Endadresse
               move.l    d6,length_up   ;LÑnge in Entpacker eintragen
               clr.l     a4             ;Tab noch nicht initialisiert

next2:         moveq.l   #0,d5          ;Packbyte lîschen
               moveq.l   #7,d6          ;ZÑhler fÅr Packbyte setzen
               movea.l   a3,a5          ;Adresse fÅr Packbyte merken
               addq.l    #1,a3          ;Aktuell gepackt um eins erhîhen
next:          move.l    a1,d0          ;Wenn am Ende, dann aufhîren
               sub.l     a2,d0          ;
               beq       endall         ;
               moveq.l   #3,d1          ;Wenn nichts mehr zum Packen Åbrig,
               cmp.l     d1,d0          ; dann auch nicht versuchen
               blt       great          ;
               movem.l   a0-a3,-(sp)    ;
               move.l    a2,d0          ;Ggf. Tab (neu) initialisieren
               sub.l     a4,d0          ;
               cmpi.l    #$8000,d0      ;
               blt       ok1            ;
               lea.l     -$fff(a2),a4   ;Kleinstmîgliche Zugriffsadresse
               cmpa.l    a4,a0          ; berechnen
               blt.s     *+4            ;
               movea.l   a0,a4          ;
               lea.l     tab_buf,a0     ;
               bsr       cr_tab         ;
               movea.l   a0,a1          ;Adress-Tab erstellen
               adda.l    #$20002,a1     ;
               movea.l   a4,a2          ;
               moveq.l   #0,d0          ;
               moveq.l   #0,d1          ;
               moveq.l   #0,d2          ;
cr_tab3:       move.b    (a2)+,d1       ;
               lsl.w     #8,d1          ;
               move.b    (a2),d1        ;
               movea.l   d1,a3          ;
               adda.l    a3,a3          ;
               adda.l    a0,a3          ;
               move.w    (a3),d2        ;
               addq.w    #2,(a3)        ;
               move.w    d0,0(a1,d2.l)  ;
               addq.w    #1,d0          ;
               bpl       cr_tab3        ;
               bsr       cr_tab         ;
               movem.l   (sp),a0-a3     ;

ok1:           move.l    a2,d0          ;Kleinstmîgliche Zugriffsadresse
               subi.l    #$fff,d0       ; berechnen
               cmpa.l    d0,a0          ;
               blt.s     *+4            ;
               move.l    a0,d0          ;
               sub.l     a4,d0          ;Offset zu Tab-Start berechnen
               lea.l     tab_buf,a3     ;
               moveq.l   #0,d4          ;Stelle in Tab berechnen, ab der
               move.b    (a2),d4        ; die Adressen stehen, in denen
               lsl.w     #8,d4          ; das gesuchte 'Wort' vorkommt
               move.b    1(a2),d4       ;
               add.l     d4,d4          ;
               movea.l   a3,a0          ;
               adda.l    #$20002,a0     ;
               movea.l   a0,a1          ;
               moveq.l   #0,d1          ;
               move.w    0(a3,d4.l),d1  ;
               adda.l    d1,a0          ;
               cmp.w     (a0)+,d0       ;Adresse muss in erlaubtem Bereich
               bgt.s     *-2            ; sein
               subq.l    #2,a0          ;FÅr spÑteres Suchen unerlaubte
               move.l    a0,d0          ; Adressen gleich ausschliessen
               sub.l     a1,d0          ;DafÅr neuen Offset-Wert
               move.w    d0,0(a3,d4.l)  ; zurÅckschreiben
               moveq.l   #0,d0          ;
               addq.l    #2,a4          ;
               addq.l    #2,a2          ;
               move.b    (a2)+,d3       ;öberprÅfen, ob rentabel (erst ab 3)
over:          movea.l   a4,a1          ;
               adda.w    (a0)+,a1       ;
               cmp.b     (a1)+,d3       ;
               bne.s     over           ;
               cmpa.l    a2,a1          ;Wenn gleiches Byte identisch ist,
               beq.s     auswert        ; dann zur Auswertung
               moveq.l   #2,d1          ;Schauen, wieviele Bytes Åbereinstimmen
               moveq.l   #15,d2         ; (maximale Anzahl = 18)
again:         addq.w    #1,d1          ;
               move.b    -3(a2,d1.w),d4 ;
               cmp.b     (a1)+,d4       ;
               dbne      d2,again       ;
               cmp.w     d0,d1          ;Die beste Sequenz wird gespeichert
               bls.s     over           ;
               move.w    d1,d0          ;
               movea.l   a1,a3          ;
               tst.w     d2             ;Wenn keine bessere mîglich, dann
               bpl.s     over           ; auch zur Auswertung

auswert:       move.l    a3,d1          ;Pack-Code erstellen
               movem.l   (sp)+,a0-a3    ;
               subq.l    #2,a4          ;
               tst.w     d0             ;Falls unrentabel, dann nicht nehmen
               beq.s     great          ;
               add.w     d5,d5          ;Packbyte * 2
               sub.l     d0,d1          ;
               subq.l    #1,d1          ;
               move.l    a1,d4          ;Genau bis zum Ende packen
               sub.l     a2,d4          ;
               cmp.l     d4,d0          ;
               blt.s     *+4            ;
               move.w    d4,d0          ;
               subq.w    #3,d0          ;
               sub.l     a2,d1          ;Versatz berechnen
               neg.l     d1             ;
               lea.l     3(a2,d0.w),a2  ;Aktuell ungepackt erhîhen
               addq.w    #1,d5          ;Bit fÅr 'gepackt' setzen
               move.w    d1,d2          ;Anzahl der Bytes und Versatz in
               lsr.w     #4,d2          ; richtiges Format bringen und
               andi.w    #$f0,d2        ; nach aktuell gepackt schreiben
               or.w      d2,d0          ;
               move.b    d0,(a3)+       ;
               move.b    d1,(a3)+       ;
               bra.s     *+6            ;

great:         add.w     d5,d5          ;Packbyte * 2
               move.b    (a2)+,(a3)+    ;Byte einfach Åbernehmen
               dbra      d6,next        ;Bei Bedarf Packbyte schreiben
               move.b    d5,(a5)        ; und Text ausgeben
               movem.l   d0-d4/a0-a4,-(sp)
               move.l    a2,d3          ;d3,d5: LÑnge des bisher ungepackten
               sub.l     a0,d3          ;
               move.l    a1,d4          ;d4: GesamtlÑnge ungepackt
               sub.l     a0,d4          ;
               lsr.l     #4,d3          ;Beide Register / 16, um auf
               move.l    d3,d5          ; Wortformat zu kommen
               lsr.l     #4,d4          ;
               mulu.w    #100,d3        ;d3=d3/d4*100
               divu.w    d4,d3          ;
               lea.l     success,a0     ;Neue Werte erst ausgeben, wenn
               cmp.w     (a0),d3        ; erste Prozentzahl anders als ist
               beq.s     same           ; vorherige
               moveq.l   #0,d4          ;
               tst.w     d5             ;Wenn bisher weniger als 16 Bytes
               beq.s     block          ; gepackt wurden, muss Divisionsbefehl
               move.l    a3,d4          ; geblockt werden
               sub.l     a1,d4          ;d4: LÑnge des bisher gepackten
               lsr.l     #4,d4          ;
               mulu.w    #100,d4        ;
               divu.w    d5,d4          ;d4=d4/d5*100-100
               subi.w    #100,d4        ;
block:         movem.w   d3/d4,(a0)     ;Werte speichern und ausgeben
               lea.l     text1,a0       ;
               bsr       print          ;
               bsr       prtdec         ;
               lea.l     text2,a0       ;
               bsr       print          ;
               move.w    d4,d3          ;
               bsr       prtdec         ;
same:          movem.l   (sp)+,d0-d4/a0-a4
               move.l    a4,d4          ;öberflÅssigen (= bereits gepackten)
               lea.l     -$1000(a2),a4  ; ungepackten Code Åberschreiben
               movea.l   a6,a5          ;
               move.l    a4,d1          ;
               btst      #0,d1          ;
               beq.s     *+4            ;
               addq.l    #1,a4          ;
               move.l    a4,d0          ;
               sub.l     a6,d0          ;
               cmpi.l    #$8000,d0      ;
               blt.s     noovwrt        ;
               move.l    (a4)+,(a5)+    ;
               cmpa.l    a3,a4          ;
               blt.s     *-4            ;
               suba.l    d0,a0          ;
               suba.l    d0,a1          ;
               suba.l    d0,a2          ;
               suba.l    d0,a3          ;
               sub.l     d0,d4          ;
noovwrt:       movea.l   d4,a4          ;
               move.l    a3,d4          ;
               sub.l     a6,d4          ;
               cmp.l     max_length,d4  ;
               blt       next2          ;Und weiterpacken...
               move.w    #50,success+2  ;Keinen Stuû packen...
               bra.s     overflow       ;

endall:        subq.l    #1,a3          ;Ggf. Packbyte richtigstellen und
               cmpi.w    #7,d6          ; schreiben
               beq.s     endall1        ;
               addq.l    #1,a3          ;
               addq.w    #1,d6          ;
               lsl.w     d6,d5          ;
               move.b    d5,(a5)        ;
endall1:       move.l    a3,d6          ;LÑnge des gepackten Codes berechnen
               sub.l     a1,d6          ;
               move.l    d6,d0          ;
               movea.l   a6,a2          ;
               move.b    (a1)+,(a2)+    ;Code herunterkopieren
               subq.l    #1,d0          ;
               bne.s     *-4            ;
               moveq.l   #4,d0          ;Relo-Tab lîschen
               clr.b     (a2)+          ;
               dbra      d0,*-2         ;
overflow:      movem.l   (sp)+,d0-d5/a0-a5
               move.w    success+2,d3   ;Erfolg nach d3
               cmpi.w    #50,d3         ;
               rts                      ;

cr_tab:        lea.l     2(a0),a1       ;
               move.w    #$fff,d0       ;HÑufigkeits-Tab lîschen
               moveq.l   #0,d1          ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               move.l    d1,(a1)+       ;
               dbra      d0,*-16        ;
               lea.l     2(a0),a1       ;HÑufigkeits-Tab erstellen
               movea.l   a4,a2          ;
               move.w    #$7fff,d0      ;
               moveq.l   #0,d1          ;
cr_tab1:       move.b    (a2)+,d1       ;
               lsl.w     #8,d1          ;
               move.b    (a2),d1        ;
               movea.l   d1,a3          ;
               adda.l    a3,a3          ;
               adda.l    a1,a3          ;
               addq.w    #2,(a3)        ;
               dbra      d0,cr_tab1     ;
               clr.w     -(a1)          ;Offset-Tab erstellen
               move.w    #$1fff,d0      ;
cr_tab2:       move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               move.w    (a1)+,d1       ;
               add.w     d1,(a1)        ;
               dbra      d0,cr_tab2     ;
               rts                      ;

;Entpacker fÅr Exec-Programme-------------------------------------------------

ent1:          .DC.w $601a              ;Overhead
               .DC.l ent2-ent1-$1c      ;
length_p:      .DC.l 0,0,0,0,0          ;
               .DC.w 0

               movea.l   4(sp),a3       ;Basepage
               movea.l   $8(a3),a2      ;
               suba.w    #$1c,a2        ;Start ungepackt
               move.l    length_up,d1   ;LÑnge ungepackt
               movea.l   a2,a6          ;
               adda.l    d1,a6          ;Ende ungepackt
               movea.l   a6,a1          ;
               adda.w    #32000,a1      ;Ende gepackt (oben)
               move.l    a1,d1          ;
               movea.l   $18(a3),a0     ;Ende gepackt (unten)
               move.l    $14(a3),d0     ;LÑnge gepackt
               move.b    -(a0),-(a1)    ;
               subq.l    #1,d0          ;
               bne.s     *-4            ;
               movea.l   a2,a4          ;Start ungepackt
               lea.l     decomp3,a0     ;
               addq.l    #1,d1          ;
               bclr      #0,d1          ;
               movea.l   d1,a5          ;
               move.w    #(ent2-decomp3)/2-1,d0
               move.w    (a0)+,(a5)+    ;
               dbra      d0,*-2         ;
               movea.l   d1,a5          ;
               jmp       (a5)           ;

decomp3:       move.b    (a1)+,d2       ;Packbyte holen
               moveq.l   #7,d3          ;
decomp2:       add.b     d2,d2          ;
               bcc.s     decomp1        ;
               move.b    (a1)+,d4       ;
               moveq.l   #0,d5          ;
               move.b    d4,d5          ;
               andi.w    #$f,d4         ;
               addq.w    #2,d4          ;
               lsl.w     #4,d5          ;
               move.b    (a1)+,d5       ;
               movea.l   a4,a5          ;
               suba.w    d5,a5          ;
               move.b    (a5)+,(a4)+    ;
               dbra      d4,*-2         ;
               bra.s     *+4            ;
decomp1:       move.b    (a1)+,(a4)+    ;
               cmpa.l    a4,a1          ;Bei öberschneidung aufhÑngen
               blt.s     *              ;
               cmpa.l    a4,a6          ;
               dbls      d3,decomp2     ;
               bgt.s     decomp3        ;
               lea.l     2(a2),a4       ;Overhead +2
               addq.l    #8,a3          ;Basepage +8
               movea.l   (a3)+,a1       ;Start Text
               movea.l   a1,a0          ;
               move.l    (a4)+,d1       ;LÑnge Text
               move.l    d1,(a3)+       ;
               adda.l    d1,a1          ;Start Data
               move.l    a1,(a3)+       ;
               move.l    (a4)+,d1       ;LÑnge Data
               move.l    d1,(a3)+       ;
               adda.l    d1,a1          ;Start Bss
               move.l    a1,(a3)+       ;
               move.l    (a4)+,d0       ;LÑnge Bss
               move.l    d0,(a3)+       ;
               moveq.l   #6,d1          ;Overhead lîschen
               clr.l     (a2)+          ;
               dbra      d1,*-2         ;
               move.l    a0,d1          ;Start Text
               movea.l   a1,a2          ;Start Relo-Tab/Bss
               move.l    (a2)+,d2       ;
               beq.s     relo1          ;
relo2:         adda.l    d2,a0          ;
               moveq.l   #0,d2          ;
               add.l     d1,(a0)        ;
relo3:         move.b    (a2)+,d2       ;
               beq.s     relo1          ;
               cmpi.w    #1,d2          ;
               bne.s     relo2          ;
               lea.l     $fe(a0),a0     ;
               bra.s     relo3          ;
relo1:         movea.l   d1,a0          ;Speicher nach Programm lîschen
               lea.l     clear_mem,a2   ;
               lea.l     -$10(a0),a3    ;
               move.l    (a2)+,(a3)     ;
               move.l    (a2)+,4(a3)    ;
               lea.l     ent2,a2        ;
               jmp       (a3)           ;
clear_mem:     clr.l     (a1)+          ;
               cmpa.l    a2,a1          ;
               blt.s     *-4            ;
               jmp       (a0)           ;

length_up:     .DC.l 0

ent2:          

;Entpacker fÅr Data-Programme------------------------------------------------

ent3:          .DC.w $601a              ;Overhead
               .DC.l top-ent3-$1c       ;
               .DC.l 0,0,0,0,0          ;
               .DC.w 0

               pea       inst           ;
               move.w    #$26,-(sp)     ;
               trap      #14            ;
               adda.l    #6,sp          ;
               clr.w     -(sp)          ;
               trap      #1             ;

inst:          cmpi.l    #$12123456,$600
               beq.s     l_rts          ;
               move.w    #$b,-(sp)      ;Bei Taste nicht installieren
               trap      #1             ;
               addq.l    #2,sp          ;
               tst.w     d0             ;
               beq.s     *+4            ;
l_rts:         rts                      ;
               movea.w   #$42e,a1       ;Phystop heruntersetzen
               movea.l   (a1),a0        ;
               subq.w    #1,(a1)        ;
               suba.w    #$5600,a0      ;Sicherheitspuffer
               lea.l     addr,a1        ;
               move.l    a0,(a1)        ; und merken
               lea.l     new,a1         ;
               move.w    #(top-new)/2-1,d0
               move.w    (a1)+,(a0)+    ;Programm hochkopieren
               dbra      d0,*-2         ;
               lea.l     install,a0     ;Hauptprogramm in residenten
               movea.w   #$600,a1       ; Bereich kopieren und resetfest
               move.w    #$fe,d0        ; machen
               move.w    #$5678,d1      ;
nail:          move.w    (a0),(a1)+     ;
               sub.w     (a0)+,d1       ;
               dbra      d0,nail        ;
               move.w    d1,(a1)        ;
reset:         movea.l   4,a0           ;Reset
               jmp       (a0)           ;

install:       .DC.l $12123456,$600     ;

               move.w    #$b,-(sp)      ;Bei Taste deaktivieren
               trap      #1             ;
               addq.l    #2,sp          ;
               tst.w     d0             ;
               beq.s     install1       ;
               clr.l     $420           ;
               movea.l   4,a0           ;
               jmp       (a0)           ;
install1:      pea       text           ;
               move.w    #9,-(sp)       ;
               trap      #1             ;
               addq.l    #6,sp          ;
               movea.l   addr,a0        ;
               movea.l   $84,a1         ;
               move.l    a0,$84         ;
               adda.w    #old-new+2,a0  ;
               move.l    a1,(a0)        ;
               move.l    a1,$90         ;
               rts                      ;

text:          .DC.b 13,10,'DECOMP.PRG resident',13,10,0
               .EVEN 

addr:          .DC.l 0

new:           move.w    (sp),d0        ;
               movem.l   d1-d7/a0-a6,-(sp)
               lea.l     vars,a6        ;
               lea.l     62(sp),a0      ;Zeiger in a0 auf Parameter
               btst      #13,d0         ;
               bne.s     *+4            ;
               move.l    usp,a0         ;
               cmpi.w    #$3d,(a0)      ;Open?
               beq       open           ;
               cmpi.w    #$3f,(a0)      ;Fread?
               beq       fread          ;
               cmpi.w    #$42,(a0)      ;Seek?
               beq       seek           ;
normal:        movem.l   (sp)+,d1-d7/a0-a6
old:           jmp       $12345678      ;Nichts dergleichen

open:          clr.w     (a6)           ;Open
               move.l    4(a0),-(sp)    ;
               move.l    (a0),-(sp)     ;
               trap      #4             ;
               addq.l    #8,sp          ;
               move.w    d0,2(a6)       ;
               bmi.s     l_rte          ;
               lea.l     buf1,a0        ;
               clr.l     (a0)           ;
               movea.l   a0,a5          ;
               moveq.l   #8,d0          ;
               bsr       fread4         ;
               moveq.l   #0,d0          ;
               cmpi.l    #'TPWM',(a5)+  ;
               bne.s     unpacked       ;
               move.l    (a5)+,8(a6)    ;
               addq.w    #1,(a6)        ;
               moveq.l   #8,d0          ;
unpacked:      bsr.s     init           ;
               move.w    2(a6),d0       ;
l_rte:         movem.l   (sp)+,d1-d7/a0-a6
               rte                      ;
fread4:        pea       (a0)           ;Bytes normal lesen
               move.l    d0,-(sp)       ;
               move.w    2(a6),-(sp)    ;
               move.w    #$3f,-(sp)     ;
               trap      #4             ;
               lea.l     $c(sp),sp      ;
               rts                      ;
init:          clr.l     4(a6)          ;File-Pointer auf 0 setzen
               clr.l     12(a6)         ;
               clr.w     d1             ;
               bsr.s     seek4          ;
               lea.l     16(a6),a0      ;Register fÅr Entpacker lîschen
               clr.l     (a0)+          ;
               clr.l     (a0)+          ;
               clr.l     (a0)           ;
               not.w     (a0)           ;
               rts                      ;
seek4:         move.w    d1,-(sp)       ;FP normal setzen
               move.w    2(a6),-(sp)    ;
               move.l    d0,-(sp)       ;
               move.w    #$42,-(sp)     ;
               trap      #4             ;
               lea.l     $a(sp),sp      ;
               rts                      ;

seek:          move.w    2(a6),d0       ;Seek
               cmp.w     6(a0),d0       ;
               bne       normal         ;<- Kann zu Komplikationen kommen,
               tst.w     (a6)           ;   falls mehrere Files gleichzeitig
               beq       normal         ;   geîffnet sind (ehemals 'bne tmfo')!
               move.l    4(a6),d4       ;
               move.w    8(a0),d3       ;
               addq.l    #2,a0          ;
               ext.l     d3             ;
               beq.s     seek0          ;
               subq.w    #1,d3          ;
               beq.s     seek1          ;
               move.l    8(a6),d3       ;
               tst.l     (a0)           ;
               bne.s     seek0          ;
               move.l    d3,4(a6)       ;
               bra.s     seek_over      ;
seek1:         move.l    d4,d3          ;
seek0:         add.l     (a0),d3        ;d3: gewÅnschter File-Pointer
               cmp.l     d4,d3          ;d4: aktueller FP
               bge.s     fp_higher      ;
               moveq.l   #8,d0          ;
               bsr.s     init           ;
fp_higher:     sub.l     4(a6),d3       ;d3: Anzahl noch zu lesender Bytes
               beq.s     seek_over      ;
seeking:       movea.w   #$1000,a0      ;
               cmp.l     a0,d3          ;
               bge.s     *+4            ;
               movea.l   d3,a0          ;
               pea       buf3           ;
               pea       (a0)           ;
               move.w    2(a6),-(sp)    ;
               move.w    #$3f,-(sp)     ;
               trap      #1             ;
               lea.l     $c(sp),sp      ;
               tst.l     d0             ;
               beq.s     seek_over      ;
               sub.l     d0,d3          ;
               bne.s     seeking        ;
seek_over:     move.l    4(a6),d0       ;
               bra       l_rte          ;
;tmfo:          addq.w    #1,$ffff8240   ;Zu viele offene Files
;               bra.s     tmfo           ;

fread:         move.w    2(a6),d0       ;Fread
               cmp.w     2(a0),d0       ;
               bne       normal         ;(Siehe Seek)
               tst.w     (a6)           ;
               beq       normal         ;
               move.l    4(a0),d0       ;
               ble       l_rte          ;
               move.l    8(a6),d1       ;
               sub.l     4(a6),d1       ;
               cmp.l     d1,d0          ;
               blt.s     *+4            ;
               move.l    d1,d0          ;
               movea.l   8(a0),a0       ;
               movea.l   a0,a1          ;a0: Start ungepackt
               movea.l   a0,a2          ;a1: Ende ungepackt
               adda.l    d0,a1          ;a2: Aktuell ungepackt
               movem.w   16(a6),d0-d5   ;a3: Aktuell gepackt
               lea.l     buf3,a3        ;a4: Ende RÅckbezugspuffer
               suba.w    d5,a3          ;
               lea.l     buf1,a4        ;
               adda.w    d0,a4          ;
               lea.l     buf3-2,a5      ;d6: buf3-2
               move.l    a5,d6          ;
               lea.l     buf2,a5        ;d7: buf2
               move.l    a5,d7          ;
               tst.w     d4             ;Falls in Sequenz abgebrochen, dann
               bpl       rest           ; jetzt fortsetzen
check:         cmpa.l    d6,a3          ;Noch genÅgend gepackter Code
               ble       enough         ; vorhanden (min. 2 Bytes)?
               move.l    d6,d5          ;
               sub.l     a3,d5          ;
               addq.l    #2,d5          ;
               tst.w     14(a6)         ;
               beq.s     no_eof         ;
               tst.w     d5             ;
               beq       new_buf1       ;
               bra       enough         ;
no_eof:        move.l    a1,d0          ;d0: Grîsse des freien Speichers
               sub.l     a2,d0          ;
               movea.l   a2,a5          ;a5: Aktuell ungepackt  oder
               move.l    #$2800,d3      ;    Start Sicherheitspuffer
               cmp.l     d3,d0          ;    (Lade-Adresse)
               bgt.s     *+6            ;
               move.l    d3,d0          ;
               movea.l   d7,a5          ;
               move.l    a5,d3          ;Code laden
               add.l     d5,d3          ;
               movem.l   d1/d2/a0-a2,-(sp)
               move.w    12(a6),d1      ;
               eor.w     d3,d1          ;
               btst      #0,d1          ;
               beq.s     adrfast        ;
               addq.l    #1,a5          ;
               addq.l    #1,d3          ;
               subq.l    #1,d0          ;
adrfast:       move.b    (a3),(a5)      ;
               movea.l   d3,a0          ;
               sub.l     d5,d0          ;
               bsr       fread4         ;
               add.l     d0,d3          ;
               move.w    d0,d1          ;
               andi.w    #1,d1          ;
               eor.w     d1,12(a6)      ;
               tst.l     d0             ;
               bmi.s     *              ;
               seq       d0             ;
               ext.w     d0             ;
               move.w    d0,14(a6)      ;
               movem.l   (sp)+,d1/d2/a0-a2
               movea.l   d3,a6          ;
cut:           lea.l     buf3,a3        ;
               cmpa.l    a5,a6          ;
               beq       check1         ;
               move.w    #$27ff,d0      ;
               move.b    -(a6),-(a3)    ;
               cmpa.l    a5,a6          ;
               dbeq      d0,*-4         ;
               beq       check1         ;
               movea.l   a1,a3          ;
               move.l    a6,d0          ;
               sub.l     a5,d0          ;
co2:           subq.l    #1,d0          ;
               bmi       check1         ;
co1:           move.b    -(a6),-(a3)    ;
               dbra      d0,co1         ;
               addq.w    #1,d0          ;
               bra.s     co2            ;
check1:        lea.l     vars,a6        ;
               bra       check          ;
enough:        moveq.l   #-20,d0        ;Droht öberschneidung?
               add.l     a3,d0          ;
               sub.l     a2,d0          ;
               bpl.s     no_cut         ;
               cmpa.l    a2,a3          ;(Wenn a2 in Seek-Puffer)
               blt.s     no_cut         ;
               movem.l   d1/d2/a0-a2,-(sp)
               moveq.l   #1,d1          ;
               move.l    #-$2800,d0     ;
               bsr       seek4          ;
               movem.l   (sp)+,d1/d2/a0-a2
               movea.l   a3,a5          ;Code hochkopieren
               movea.l   a1,a6          ;
               bra.s     cut            ;
get_pb:        moveq.l   #8,d1          ;
               move.b    (a3)+,d2       ;d1: Packbyte-Count
               cmpa.l    a3,a1          ;d2: Packbyte
               bne       check          ;d3: Versatz
               movea.l   d7,a3          ;d4: LÑnge der Sequenz
               bra       check          ;
no_cut:        subq.w    #1,d1          ;Entpacken
               bmi.s     get_pb         ;
               add.b     d2,d2          ;
               bcc.s     no_seq         ;
               move.b    (a3)+,d4       ;
               cmpa.l    a3,a1          ;
               bne.s     *+4            ;
               movea.l   d7,a3          ;
               moveq.l   #0,d3          ;
               move.b    d4,d3          ;
               andi.w    #$f,d4         ;
               addq.w    #2,d4          ;
               lsl.w     #4,d3          ;
               move.b    (a3)+,d3       ;
               cmpa.l    a3,a1          ;
               bne.s     *+4            ;
               movea.l   d7,a3          ;
rest:          movea.l   a2,a5          ;
               suba.w    d3,a5          ;
               cmpa.l    a0,a5          ;
               bge.s     in_range       ;
               suba.l    a0,a5          ;
               adda.l    a4,a5          ;
n_i_range:     move.b    (a5)+,(a2)+    ;
               cmpa.l    a1,a2          ;
               beq.s     new_buf1       ;
               cmpa.l    a4,a5          ;
               dbeq      d4,n_i_range   ;
               subq.w    #1,d4          ;
               bmi       check          ;
               movea.l   a0,a5          ;
in_range:      move.b    (a5)+,(a2)+    ;
               cmpa.l    a1,a2          ;
               dbeq      d4,in_range    ;
               bne       check          ;
               bra.s     new_buf1       ;
no_seq:        move.b    (a3)+,(a2)+    ;
               cmpa.l    a3,a1          ;
               bne.s     *+4            ;
               movea.l   d7,a3          ;
               cmpa.l    a1,a2          ;
               bne       check          ;
new_buf1:      subq.w    #1,d4          ;RÅckbezugspuffer erstellen
               lea.l     -$1000(a2),a5  ;
               lea.l     buf1,a6        ;
               move.l    a5,d5          ;
               sub.l     a0,d5          ;d5: LÑnge ungepackt -$1000
               bpl.s     simple_buf1    ;
               move.l    a4,d0          ;
               sub.l     a6,d0          ;
               add.w     d0,d5          ;d5: Unterschied zu einem $1000 Bytes
               cmpi.w    #$800,d5       ;
               ble.s     merge          ;    grossen RÅckbezugspuffer
               movea.l   a6,a5          ;
               adda.w    d5,a5          ;
               sub.w     d5,d0          ;
               subq.w    #1,d0          ;
               move.b    (a5)+,(a6)+    ;
               dbra      d0,*-2         ;
               bra.s     *+4            ;
merge:         movea.l   a4,a6          ;
               movea.l   a0,a5          ;
simple_buf1:   move.b    (a5)+,(a6)+    ;
               cmpa.l    a2,a5          ;
               blt.s     *-4            ;
               lea.l     buf1,a5        ;
               suba.l    a5,a6          ;
               move.l    a6,d0          ;
               lea.l     buf3,a5        ;
               suba.l    a3,a5          ;
               move.l    a5,d5          ;
               lea.l     vars,a6        ;
               movem.w   d0-d5,16(a6)   ;
               move.l    a2,d0          ;TatsÑchliche LÑnge berechnen
               sub.l     a0,d0          ;
               add.l     d0,4(a6)       ;File-Pointer richtigstellen
               bra       l_rte          ;

top:           

vars:          
;packflag:           .w ->   (a6)
;handle:             .w ->  2(a6)
;fp:                 .l ->  4(a6)
;max:                .l ->  8(a6)
;adrflag:            .w -> 12(a6)
;eof:                .w -> 14(a6)
;reg_save:           .w, 6 mal -> 16(a6)

buf1           equ vars+30              ;RÅckbezugspuffer, $1800 Bytes
buf2           equ buf1+$1800           ;Sicherheitspuffer, $2800 Bytes
buf3           equ buf2+$2800           ;Seek-Puffer, $1000 Bytes

               .DC.l 0

;-----------------------------------------------------------------------------

               .DATA 

cls:           .DC.b 27,'E',0

menu:          .DC.b 27,'E',10,'Turbo Packer by Wolfgang Mayerle in 1990',13,10
               .DC.b 10
               .DC.b ' Options: Pack Files',13,10
               .DC.b '          Create DECOMP.PRG',13,10
               .DC.b '          Drives',13,10
               .DC.b '          Switch skipflag',13,10
               .DC.b '          Info',13,10
               .DC.b '          Quit'
drive1:        .DC.b 27,'Y',43,32,'Drives: Source ',27,'e',0
drive2:        .DC.b ', Destination ',0
skiptext1:     .DC.b 27,'Y',45,32,'Ignore skipped files.',0
skiptext2:     .DC.b 27,'Y',45,32,'Copy skipped files.  ',0
cr_off:        .DC.b 27,'f',0

info_txt:      .DC.b 27,'E',10
               .DC.b 'Turbo Packer stellt einen extrem leistungsfÑhigen, schnellen und kompatiblen',13,10
               .DC.b 'Packer dar. Mit ihm lassen sich im Gegensatz zu herkîmmlichen Packern auch',13,10
               .DC.b 'Programme packen, die laufend gebraucht werden.',13,10
               .DC.b 'Das Programm heiût Turbo Packer, weil er sowohl beim Packvorgang selbst als',13,10
               .DC.b 'auch beim Entpacken extrem schnelle Algorithmen benutzt. Dies zeigt sich z.B.',13,10
               .DC.b 'darin, daû manche gepackte Programme von Diskette schneller geladen werden',13,10
               .DC.b 'als ungepackte.',13,10
               .DC.b 'Eine genaue Bedienungsanleitung finden Sie im TOS-Magazin.',13,10,10
               .DC.b '<Taste>',0

load:          .DC.b 27,'E',10,'Select File or Directory to load (from).',0

select_dd:     .DC.b 27,'E',10,'Select Directory to save to.',0

loading:       .DC.b 27,'E',10,'Loading ',0

data_file:     .DC.b 13,10,10,'Recognized as Data-File.',0
exec_file:     .DC.b 13,10,10,'Recognized as Exec-File.',13,10
               .DC.b 'Pack it as Exec- or Data-File? ',0

symbols:       .DC.b 13,10,10,'Symbols erased.',0
relo:          .DC.b 13,10,10,'Relocation Table corrected.',0

packing:       .DC.b 13,10,10,'Packing ',0

text12:        .DC.b 13,10,10,'Already packed                   : ',27,'j   %'
               .DC.b 13,10,'Relation pack_difference/unpacked:    %',0
text1:         .DC.b 27,'k',27,'j',0
text2:         .DC.b 27,'k',27,'j',10,0

result:        .DC.b 27,'E',10,'Result: ',27,'j   %',27,'k',0

saving:        .DC.b 27,'E',10,'Saving ',0

doubletrouble: .DC.b 13,10,10,'File already packed.',0
skipped:       .DC.b 13,10,10,'File skipped.',0
copying:       .DC.b 13,10,10,'Copying ',0

io_error:      .DC.b 27,'E',10,'I/O-Error. Check Drive and press a key.',0
memory:        .DC.b 13,10,10,10,'Insufficient memory. Press a key.',0

decomp:        .DC.b 'DECOMP.PRG',0

               .EVEN 

aespara:       .DC.l contol,0,0,intout,addrin
contol:        .DC.w 90,0,2,2,0
addrin:        .DC.l 0,name_fs
intout:        .DC.w 0,0

code:          .DC.b 'TPWM'

               .BSS 

source_path:   .DS.b 128
dest_path:     .DS.b 128

name_fs:       .DS.b 14

dta:           .DS.b 26
length:        .DS.l 1
name:          .DS.b 14

max_length:    .DS.l 1
skipflag:      .DS.w 1
autoflag:      .DS.w 1
execflag:      .DS.w 1

success:       .DS.w 2
               .DS.b 1000
stack:         
tab_buf:       .DS.b $30002
buf:           


