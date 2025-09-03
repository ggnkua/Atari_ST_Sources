;  
;   Hilfsroutinen fÅr das FONTEDIT.ACC in Assembler
;


        GLOBL    get_header,melde_font

        GLOBL    handle,head_6_6,head_8_8,head_8_16

;------------------------------------------------------------------
;   LINE A aufrufen um Adresse der Fontheadertabelle zu bestimmen
;   und neue LINE A Routine einbinden
;------------------------------------------------------------------

get_header:
        movem.l a2/d2,-(sp)
        dc.w    $A000
        move.l  a1,-(sp)        ; Adresse der alten Fonttabelle merken

        move.l  #a_neu,-(sp)    ; neuen Line A Vektor setzen
        move.w  #10,-(sp)       ; LINE A ist Vektor Nr. 10
        move.w  #5,-(sp)
        trap    #13
        add.l   #8,sp

        move.l  d0,L_ADR        ; Adr. alte LINE A Routine merken
        move.l  (sp)+,a0        ; Adr. der alten Fonttabelle zurÅckliefern

        movem.l (sp)+,a2/d2
        rts

;-------------------------------------------------------------------
;                        neue LINE A Routine
;-------------------------------------------------------------------

a_neu:  
        move.l  2(sp),a1        ; den Line A Aufruf fÅr Simulation 
        move.w  (a1),a_ret      ; kopieren

        addq.l  #2,a1 
        move.l  a1,2(sp)        ; RÅcksprung korrigieren

        pea     a_ret(pc)       ; Werte fÅr Simulation auf den Stack
        move.w  sr,-(sp)
        move.l  L_ADR,-(sp)     ; und in alte Lina A Routine springen
        rts

a_ret:  dc.w    0               ; Platz fÅr Line A Aufruf

        move.w  a_ret,d2
        cmp.w   #$A000,d2
        bne     a_end           ; kein $A000

        lea     f_tab,a1

a_end:  rte

;-------------------------------------------------------------------
;     Systemfont anmelden   8*16 bei s/w  -  8*8 bei Farbe
;-------------------------------------------------------------------

melde_font:
        movem.l d2-d7/a2-a6,-(sp)

        move.w  #4,-(sp)                ; Auflîsung bestimmen
        trap    #14
        addq.l  #2,sp

        move.l  #head_8_16,intin        ; 8*16 vorbelegen       

        cmp.w   #2,d0                   ; hohe Auflîsung ?
        beq     header_ok               ; Dann ist alles klar

        move.l  #head_8_8,intin         ; sonst 8*8 Font nehmen
header_ok:
                                        ; VDI esc 102 aufrufen
        move.l  #contrl,a5
        move.w  #5,(a5)
        clr.w   2(a5)
        clr.w   6(a5)
        move.w  #102,10(a5)
        move.w  handle,12(a5)
        
        move.l  #vdidat,d1
        move.w  #$73,d0
        trap    #2

        movem.l (sp)+,d2-d7/a2-a6

        rts           

;--------------------------------------------------------------------
;                 Daten und Felder fÅr VDI-Aufruf
;--------------------------------------------------------------------

        DATA

vdidat: dc.l    contrl
        dc.l    intin
        dc.l    intout
        dc.l    ptsin
        dc.l    ptsout

; Neue Tabelle mit den Adressen der Fontheader

f_tab:  dc.l    head_6_6
        dc.l    head_8_8
        dc.l    head_8_16
        dc.l    0

        BSS

contrl: ds.w    12
intin:  ds.w    10
intout: ds.w    10
ptsin:  ds.w    10
ptsout: ds.w    10

; Adresse der normalen LINE A Routine

L_ADR:  ds.l    1
        end
