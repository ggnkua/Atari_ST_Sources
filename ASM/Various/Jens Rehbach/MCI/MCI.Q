; MCI.Q
; 18.2.87
;
; Jens Rehbach
; BrÅckenweg 6
; 5632 Wermelskirchen 1


 text

sstart          move.l   a7,a5
                move.l   4(a5),a5
                move.l   32(a5),string
                move.l   $c(a5),d0
                add.l    $14(a5),d0
                add.l    $1c(a5),d0
                add.l    #$500,d0
                move.l   d0,d1
                add.l    a5,d1
                and.l    #-2,d1
                move.l   d1,a7
                move.l   d0,-(sp)
                move.l   a5,-(sp)
                clr.w    -(sp)
                move.w   #$4a,-(sp)
                trap     #1
                add.l    #12,sp
                tst.l    d0
                bne      no_mem

main            move.l   string(pc),a6
                move.b   (a6),d6
                beq      no_file        ;Kein Name angegeben
                and.w    #$ff,d6
                addq.l   #1,a6
                clr.b    0(a6,d6.w)
                pea      dta(pc)
                move.w   #$1a,-(sp)
                trap     #1             ;DTA Puffer einrichten
                addq.l   #6,sp
                move.w   #0,-(sp)
                move.l   a6,-(sp)
                move.w   #$4e,-(sp)
                trap     #1             ;LÑnge des Programms ermitteln
                addq.l   #8,sp
                tst.w    d0             ;Fehler?
                bne.s    not_exist      ;Ja: Datei neu anlegen
                move.l   dta+26(pc),length
                move.w   #2,-(sp)
                move.l   a6,-(sp)
                move.w   #$3d,-(sp)
                trap     #1             ;Open
                addq.l   #8,sp
                tst.w    d0
                bmi      file_error
                move.w   d0,fhandle
                moveq    #1,d7
                bra.s    reserve

not_exist       lea      neu_text(pc),a0    ;Datei neu anlegen
                bsr      print_line
                bsr      read_number    ;LÑnge erfragen
                move.l   d1,length
                clr.w    -(sp)
                move.l   a6,-(sp)
                move.w   #$3c,-(sp)
                trap     #1             ;Create
                addq.l   #8,sp
                tst.w    d0
                bmi      file_error
                move.w   d0,fhandle
                clr.l    d7
reserve         cmp.l    #$1ffff,length
                bhi      zu_lang        ;Mehr als 128kByte ==> Fehler
                move.l   length(pc),d0
                add.l    #16,d0
                move.l   d0,-(sp)
                move.w   #$48,-(sp)
                trap     #1             ;Speicher reservieren
                addq.l   #6,sp
                tst.l    d0
                bmi      no_mem
                move.l   d0,free
                tst.l    d7
                bne.s    load
                move.l   d0,a0
                move.l   length(pc),d0
loesche         move.b   #$ee,(a0)+
                subq.l   #1,d0
                bne      loesche
                bra.s    init_ein

load            move.l   free(pc),-(sp)
                move.l   length(pc),-(sp)
                move.w   fhandle(pc),-(sp)
                move.w   #$3f,-(sp)
                trap     #1             ;Datei laden
                add.l    #12,sp
                tst.l    d0
                bmi      file_error

init_ein        clr.w    max_zeile      ;max_zeile berechnen
                move.l   length(pc),d0
                move.l   d0,d1
                and.l    #%1111,d1
                beq.s    no_rest
                addq.w   #1,max_zeile
no_rest         asr.l    #4,d0
                add.w    d0,max_zeile

                lea      esc_e(pc),a0
                bsr      print_line
                move.w   #1,zeile
                move.l   free(pc),a6
                clr.w    printer
                tst.l    d7
                bne      p_menue

mainloop        bsr      nummer_aus
                moveq    #1,d2
next_block      cmp.b    #17,d2
                beq.s    get_check
                moveq    #2,d1
                bsr      read
                tst.w    d0
                bmi.s    back_
                addq.b   #1,d2
                move.b   d0,(a6)+
                moveq    #32,d0
                bsr      print_char
                bra      next_block
back_           cmp.b    #1,d2
                beq      next_block
                subq.b   #1,d2
                subq.l   #1,a6
backa           lea      back3(pc),a0
                bsr      print_line
                bra      next_block
get_check       lea      rev_on(pc),a0
                bsr      print_line
                moveq    #3,d1
                bsr      read
                tst.w    d0
                bpl.s    calc
                lea      rev_off(pc),a0
                bsr      print_line
                bra      back_

calc            move.w   d0,d5
                lea      rev_off(pc),a0
                bsr      print_line
                bsr      calc_check
                cmp.w    d1,d5
                beq.s    ok
                bsr      sound_w
                moveq    #17,d2
                bra      backa
ok              move.w   zeile(pc),d7
                cmp.w    max_zeile(pc),d7
                beq.s    save
                lea      newline(pc),a0
                bsr      print_line
                addq.w   #1,zeile
                bra      mainloop

save            clr.w    -(sp)
                move.w   fhandle(pc),-(sp)
                clr.l    -(sp)
                move.w   #$42,-(sp)
                trap     #1             ;Dateipointer auf Anfang
                add.l    #10,sp
                tst.l    d0
                bmi      file_error
                move.l   free(pc),-(sp)
                move.l   length(pc),-(sp)
                move.w   fhandle(pc),-(sp)
                move.w   #$40,-(sp)
                trap     #1             ;Datei abspeichern
                add.l    #12,sp
                tst.l    d0
                bmi      file_error
close           move.w   fhandle(pc),-(sp)
                move.w   #$3e,-(sp)
                trap     #1             ;Close
                addq.l   #4,sp
                tst.w    d0
                bmi      file_error
                clr.w    -(sp)
                trap     #1

dec_print:      movem.l  d0/d3-d4/a0-a1,-(sp) ;Gibt Zahl in d1.l mit
                asl.w    #2,d2                ;d2.w Stellen aus
                sub.w    #4,d2
                lea      tab10(pc),a1
next_digit      move.l   0(a1,d2.w),d4
                moveq    #-1,d3
loop            addq.w   #1,d3
                sub.l    d4,d1
                bcc      loop
                add.l    d4,d1
                add.w    #'0',d3
                move.w   d3,d0
                bsr      print_char
                subq.w   #4,d2
                bcc      next_digit
                movem.l  (sp)+,d0/d3-d4/a0-a1
                rts

read            movem.l  d2-d4/a0,-(sp)  ;Liest Dezimalzahl mit d1.b
                clr.b    d2              ;Stellen
                clr.w    d3
next            bsr      conin
                cmp.b    #'(',d0
                bne.s    not1
                moveq    #'A',d0
not1            cmp.b    #')',d0
                bne.s    not2
                moveq    #'B',d0
not2            cmp.b    #'/',d0
                bne.s    not3
                moveq    #'C',d0
not3            cmp.b    #'*',d0
                bne.s    not4
                moveq    #'D',d0
not4            cmp.b    #'-',d0
                bne.s    not5
                moveq    #'E',d0
not5            cmp.b    #'+',d0
                bne.s    not6
                moveq    #'F',d0
not6            cmp.b    #'0'-1,d0
                bls.s    test_back
                cmp.b    #'9',d0
                bhi.s    test_char
                move.b   d0,d4
                sub.b    #'0',d4
r1              bsr      print_char
                asl.w    #4,d3
                and.w    #$ff,d4
                add.w    d4,d3
                addq.b   #1,d2
                cmp.b    d1,d2
                bne      next
                move.w   d3,d0          ;Ergebnis nach d0.w
read_end        movem.l  (sp)+,d2-d4/a0
                rts
test_char       cmp.b    #'A'-1,d0
                bls      test_back
                cmp.b    #'F',d0
                bhi.s    test_c2
s1              move.b   d0,d4
                sub.b    #'A'-10,d4
                bra.s    r1
test_c2         cmp.b    #'a'-1,d0
                bls      test_back
                cmp.b    #'f',d0
                bhi      test_back
                sub.b    #32,d0
                bra.s    s1
test_back       cmp.b    #8,d0
                bne.s    test_help
                tst.b    d2
                bne.s    one_back
fehler          moveq    #-1,d0         ;Backspace an erster Ziffer
                bra      read_end       ;==> negativen Wert zurÅck
one_back        lsr.w    #4,d3          ;sonst eine Stelle zurÅck
                subq.b   #1,d2
                lea      back1(pc),a0
                bsr      print_line
                bra      next
test_help       swap     d0             ;Help gedrÅckt
                cmp.b    #$62,d0
                bne      next
                add.l    #20,sp         ;Ja: Register und PC vergessen
p_menue         lea      menue(pc),a0   ;und MenÅ ausgeben
                bsr      print_line
help_loop       bsr      conin
                cmp.b    #'5',d0
                beq      close
                cmp.b    #'1',d0
                beq      save
                cmp.b    #'2',d0
                beq.s    neue_zeile
                cmp.b    #'3',d0
                beq.s    list_1
                cmp.b    #'4',d0
                bne      help_loop
pr_list         bsr.s    neue_help      ;Listing auf Drucker
                move.w   #1,printer
                lea      cr(pc),a0
                bsr      print_line
                bsr.s    list_p
                lea      cr(pc),a0
                bsr      print_line
                clr.w    printer
                bra      p_menue

neue_zeile      bsr.s    neue_help      ;Eingabe ab neuer Zeile
                bra      mainloop

neue_help       lea      eingabe(pc),a0
                bsr      print_line
                bsr      read_number
                tst.l    d1
                bne.s    n1
                addq.l   #1,d1
n1              cmp.l    #$ffff,d1
                bhi      p_menue
                cmp.w    max_zeile(pc),d1
                beq.s    n1_1
                bcc      p_menue
n1_1            move.w   d1,zeile
                asl.l    #4,d1
                sub.l    #16,d1
                move.l   d1,a6
                add.l    free(pc),a6
                lea      esc_e(pc),a0
                bsr      print_line
                rts

list_1          bsr      neue_help      ;Listing auf Bildschirm
                lea      esc_e(pc),a0
                bsr      print_line
                bsr.s    list_p
                bra      p_menue

list_p          lea      status_z(pc),a0
                bsr      print_line
                move.l   string(pc),a0
                addq.l   #1,a0
                bsr      print_line
                lea      tab_length(pc),a0
                bsr      print_line
                move.l   length(pc),d1
                moveq    #6,d2
                bsr      dec_print
                lea      cr(pc),a0
                bsr      print_line
                moveq    #56,d5
line            move.b   #'-',d0
                bsr      print_char
                dbra     d5,line
list_loop       lea      cr(pc),a0
                bsr      print_line
                bsr      nummer_aus
                moveq    #15,d5
next_number     move.b   (a6)+,d1
                and.w    #$ff,d1
                moveq    #1,d2
                bsr      hex_print
                moveq    #32,d0
                bsr      print_char
                dbra     d5,next_number
                move.w   printer(pc),d5
                clr.w    printer
                lea      rev_on(pc),a0
                bsr      print_line
                move.w   d5,printer
                bsr      calc_check
                moveq    #2,d2
                bsr      hex_print
                move.w   printer(pc),d5
                clr.w    printer
                lea      rev_off(pc),a0
                bsr      print_line
                move.w   d5,printer
                move.w   zeile(pc),d7
                cmp.w    max_zeile(pc),d7
                beq.s    test_warte
                addq.w   #1,zeile
                tst.w    printer
                bne      list_loop
                move.w   #$0b,-(sp)
                trap     #1
                addq.l   #2,sp
                tst.w    d0
                beq      list_loop
                bsr.s    get_key
                bsr.s    get_key
                cmp.b    #32,d0
                beq      list_loop
list_end        rts
test_warte      tst.w    printer
                beq.s    get_key
                rts

get_key         bsr      conin
                rts

read_number     pea      buffer(pc)     ;Liest Dezimalzahl
                move.w   #$0a,-(sp)
                trap     #1             ;mit Readline
                addq.l   #6,sp
                lea      buffer(pc),a0
                clr.l    d1
                clr.w    d2
                subq.w   #1,d0
                bmi.s    end_read
ca_loop         move.b   2(a0,d2.w),d3
                sub.b    #'0',d3
                and.w    #$ff,d3
                mulu     #10,d1
                add.l    d3,d1
                addq.w   #1,d2
                dbra     d0,ca_loop
end_read        rts

sound_w         movem.l  d0/a0,-(sp)
                pea      s_data(pc)
                move.w   #32,-(sp)
                trap     #14
                addq.l   #6,sp
                moveq    #-1,d0
w_loop          dbra     d0,w_loop
                move.w   #$88,-(sp)
                move.w   #0,-(sp)
                move.w   #28,-(sp)
                trap     #14
                addq.l   #6,sp
                movem.l  (sp)+,d0/a0
                rts

nummer_aus      move.w   zeile(pc),d1
                moveq    #4,d2
                bsr      dec_print
                lea      punktfrei(pc),a0
                bsr      print_line
                rts

calc_check      sub.l    #16,a6
                move.w   zeile(pc),d1
                moveq    #1,d2
                moveq    #15,d3
c_loop          move.b   (a6)+,d4
                and.w    #$ff,d4
                mulu     d2,d4
                add.w    d4,d1
                addq.w   #1,d2
                dbra     d3,c_loop
                and.w    #$fff,d1
                rts
  
no_mem          lea      speicher(pc),a0
                bra.s    error_aus

no_file         lea      name(pc),a0
                bra.s    error_aus

file_error      lea      f_err(pc),a0
                bra.s    error_aus

print_error     lea      p_err(pc),a0
                bra.s    error_aus

zu_lang         lea      lang_t(pc),a0


error_aus       bsr.s    print_line
                bsr.s    conin
                clr.w    -(sp)
                trap     #1

print_char      and.w    #$ff,d0        ;Gibt ein Zeichen aus
                move.w   d0,-(sp)
                move.w   d0,-(sp)
                move.w   #2,-(sp)
                trap     #1
                addq.l   #4,sp
                move.w   (sp)+,d0
                tst.w    printer        ;auch auf Drucker?
                beq.s    end_pc         ;nein
                move.w   d0,-(sp)
                move.w   #5,-(sp)
                trap     #1
                addq.l   #4,sp
                tst.w    d0
                beq      print_error
end_pc          rts

print_line      move.b   (a0)+,d0
                tst.b    d0
                beq.s    end_pl
                move.l   a0,-(sp)
                bsr      print_char
                move.l   (sp)+,a0
                bra      print_line
end_pl          rts

conin           move.w   #7,-(sp)
                trap     #1
                addq.l   #2,sp
                rts

hex_print       cmp.w    #1,d2
                beq      h2
                ror.l    #4,d1
h2              ror.l    #4,d1
hexloop         bsr.s    hex_char
                rol.l    #4,d1
                dbra     d2,hexloop
                rts

hex_char        movem.l  d0-d1/a0,-(sp)
                and.w    #$f,d1
                lea      chars(pc),a0
                move.b   0(a0,d1.w),d0
                bsr.s    print_char
                movem.l  (sp)+,d0-d1/a0
                rts
 data

tab10           dc.l     1,10,100,1000,10000,100000
punktfrei       dc.b     ': ',0
cr              dc.b     10,13,0
newline         dc.b     10,13,7,0
rev_on          dc.b     27,'p',0
rev_off         dc.b     27,'q',0
back1           dc.b     8,27,'K',0
back3           dc.b     8,8,8,27,'K',0
esc_e           dc.b     27,'E',0
s_data          dc.b     0,0,1,3,7,$fe,8,15,$ff,0
neu_text        dc.b     'Datei wird neu angelegt.',10,13,'LÑnge: ',0
speicher        dc.b     27,'E','Nicht genug Speicher!',0
name            dc.b     'Dateiname nicht angegeben!',0
lang_t          dc.b     27,'E','Zu lang (max. 128KBytes)!',0
f_err           dc.b     27,'E','File-Error!',0
p_err           dc.b     27,'E','Printer-Error!',0
menue           dc.b     27,'E',27,'p','MCI by Jens Rehbach fÅr'
                dc.b     ' Happy Computer und 68000er',27,'q'
                dc.b     10,13,10,13,'1...Save',10,13,'2...Eingabe ab Zeile'
                dc.b     10,13,'3...Listing auf Bildschirm',10,13
                dc.b     '4...Listing auf Drucker',10,13
                dc.b     '5...Quit (ohne Save)',10,13,0
eingabe         dc.b     10,13,'Zeile: ',0
status_z        dc.b     'File: ',0
chars           dc.b     '0123456789ABCDEF'
tab_length      dc.b     '   LÑnge: ',0
buffer          dc.b     10,0
                ds.b     11

 bss

zeile           ds.w     1
max_zeile       ds.w     1
fhandle         ds.w     1
string          ds.l     1
length          ds.l     1
dta             ds.b     44
free            ds.l     1
printer         ds.w     1

 end
 