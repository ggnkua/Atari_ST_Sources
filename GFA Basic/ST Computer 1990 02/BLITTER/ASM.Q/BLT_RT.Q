;******************************************************************************
;* BLT_RT - Demonstrations-Programm zum horizontalem Scrollen mit dem Blitter *
;******************************************************************************
;
src_xinc:   EQU $FF8A20               ;zuerst werden alle benîtigten Blitter-
src_yinc:   EQU $FF8A22               ;Register mit Namen bezeichnet (sonst
src_addr:   EQU $FF8A24               ;findet da ja keiner mehr durch):
endmask1:   EQU $FF8A28
endmask2:   EQU $FF8A2A
endmask3:   EQU $FF8A2C
dst_xinc:   EQU $FF8A2E
dst_yinc:   EQU $FF8A30
dst_addr:   EQU $FF8A32
x_count:    EQU $FF8A36
y_count:    EQU $FF8A38
hop:        EQU $FF8A3A
op:         EQU $FF8A3B
line_num:   EQU $FF8A3C
skew:       EQU $FF8A3D
;------------------------------------------------------------------------------
            bsr       go_super        ;ggf. in den Supervisormodus schalten
;------------------------------------------------------------------------------
            movea.l   4(sp),a6        ;Bildschirm-Adresse vom Stack holen
            move.w    #639,d0         ;640mal um 1 Pixel nach rechts schieben
rt_loop:    move.w    #2,src_xinc     ;Quell-Datenworte haben 2 Bytes Abstand
            move.w    #2,src_yinc     ;Zl-Ende und -Anfang haben 2 Byte Abstand
            move.l    a6,src_addr     ;Adresse des Quell-Bildschirms
            move.w    #$7FFF,endmask1 ;erstes Datenwort nur Bit 0-14 bearbeiten
            move.w    #$FFFF,endmask2 ;mittlere Datenworte komplett bearbeiten
            move.w    #$FFFF,endmask3 ;letztes Datenwort komplett bearbeiten
            move.w    #2,dst_xinc     ;Ziel-Datenworte haben 2 Bytes Abstand
            move.w    #2,dst_yinc     ;Zl-Ende und -Anfang haben 2 Byte Abstand
            move.l    a6,dst_addr     ;Adresse des Ziel-Bildschirms
            move.w    #40,x_count     ;Bitblock hat 40 Worte pro Zeile
            move.w    #400,y_count    ;Bitblock hat 400 Zeilen
            move.b    #2,hop          ;nur Source-Daten kopieren
            move.b    #3,op           ;Modus 3 = Replace
            move.b    #1,skew         ;um 1 Bit nach rechts verschieben
            move.b    #192,line_num   ;Blitter mit gesetztem HOG-Bit starten
            dbra      d0,rt_loop
            rts                       ;zurÅck zum Hauptprogramm...
;------------------------------------------------------------------------------
go_super:   pea       1               ;CPU-Status abfragen
            move.w    #32,-(sp)       ;Super
            trap      #1              ;GEMDOS-Aufruf
            addq.l    #6,sp           ;Stack korrigieren
            cmpi.l    #-1,d0          ;d0=-1 ?
            beq.s     super_rts       ;JA: CPU ist bereits im Supervisor-Modus
            pea       0               ;NEIN: CPU in Supervisor-Modus schalten
            move.w    #32,-(sp)       ;Super
            trap      #1              ;GEMDOS-Aufruf
            addq.l    #6,sp           ;Stack korrigieren
super_rts:  rts
;------------------------------------------------------------------------------
            END

