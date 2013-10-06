                                                                                                                                                                                                                                                          
     
;*** FONTCONVERTER
;*** (W) 18.04.1995 by Tarzan Boy of STAX


font_high       EQU 8


                TEXT

                bsr.s   pic_laden
                bsr     pic_to_font

                suba.l  #font,A6
                move.l  A6,font_bytes

                bsr     font_speichern

                bsr     print_ok

out:
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP

                clr.w   -(SP)
                trap    #1


pic_laden:      
                move.w  #0,-(SP)
                pea     pic_file(PC)
                move.w  #61,-(SP)
                trap    #1
                addq.l  #8,SP
                tst.w   D0
                bmi.s   file_open_error
                move.w  D0,handle

                pea     pic(PC)
                move.l  #128256,-(SP)
                move.w  handle(PC),-(SP)
                move.w  #63,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bmi.s   file_read_error

                move.w  handle(PC),-(SP)
                move.w  #62,-(SP)
                trap    #1
                addq.l  #4,SP
                tst.w   D0
                bmi.s   file_close_error

                rts

file_open_error:pea     open_error_txt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                bra.s   out

file_read_error:pea     read_error_txt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                bra.s   out

file_close_error:
                pea     close_error_txt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                bra.s   out

open_error_txt: DC.B "Fehler beim ™ffnen der Bilddatei",13,10,0
read_error_txt: DC.B "Fehler beim Lesen der Bilddatei",13,10,0
close_error_txt:DC.B "Fehler beim Schliessen der Bilddatei",13,10,0


pic_to_font:    

                lea     font,A6
                lea     pic+256(PC),A4

                movea.l A4,A2
                move.w  #31,D6
copy_1:
                bsr.s   copy_letter
                lea     16(A4),A4
                dbra    D6,copy_1

                move.w  #font_high,D0
                mulu    #640,D0
                adda.l  D0,A2

                movea.l A2,A4

                move.w  #31-4,D6
copy_2:
                bsr.s   copy_letter
                lea     16(A4),A4
                dbra    D6,copy_2

                rts

;---------------

copy_letter:
                moveq   #font_high-1,D1
                moveq   #0,D2
                moveq   #0,D3

copy_line_loop:
                moveq   #7,D0
copy_loop:
                move.w  0(A4,D2.w),(A6)+
                addq.w  #2,D2
                dbra    D0,copy_loop

                addi.w  #640,D3
                move.w  D3,D2

no_zusatz:
                dbra    D1,copy_line_loop

                rts



font_speichern: 
                clr.w   -(SP)
                pea     font_file(PC)
                move.w  #60,-(SP)
                trap    #1
                addq.l  #8,SP
                tst.w   D0
                bmi.s   file_create_error
                move.w  D0,handle

                pea     font
                move.l  font_bytes(PC),-(SP)
                move.w  handle(PC),-(SP)
                move.w  #64,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bmi.s   file_write_error

                move.w  handle(PC),-(SP)
                move.w  #62,-(SP)
                trap    #1
                addq.l  #4,SP

                rts

file_create_error:
                pea     create_error_txt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                bra     out

file_write_error:
                pea     write_error_txt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                bra     out

create_error_txt:
                DC.B "Fehler beim Erstellen der Fontdatei",13,10,0
write_error_txt:DC.B "Fehler beim Schreiben der Fontdatei",13,10,0


print_ok:       
                pea     ok_text(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                rts

ok_text:        DC.B "Der Font konnte erfolgreich konvertiert werden.",0


                DATA

pic_file:       DC.B "g:\running\tru\fn_8x8-2.tru",0
font_file:      DC.B "g:\running\fnt\fn_8x8-2.fnt",0


max_breite:     DC.W 0

                BSS

handle:         DS.W 1
font_bytes:     DS.L 1

pic:            DS.L 50000
font:           DS.L 50000
                END
