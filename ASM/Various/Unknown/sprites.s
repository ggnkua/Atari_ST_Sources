; Schnelle Spriteroutine
; aus ST-Magazin
; *** MAIN ***
main:        
             clr.l     -(sp)            ; Supervisormodus einschalten
             move.w    #$20,-(sp)
             trap      #1
             addq.l    #6,sp
             move.l    d0,ssp

             bsr       init
             bsr       scr_init

             lea.l     spr_img(pc),a0   ; welches Sprite ?
             lea.l     sprite(pc),a1    ; wohin shiften ?
             bsr       shift


             move.l    #xtab,xpos       ; X-Koo und Y-Koo init.
             move.l    #ytab,ypos

             move.l    #vbl,$4d2        ; PRG in VBL-Vektor einhÑngen(unsauber)
             move.w    #7,-(sp)         ; auf Taste warten
             trap      #1
             addq.l    #2,sp
             clr.l     $4d2             ; Routine wieder ausklinken


             move.w    #1,-(sp)         ; alte Bildschirmadressen
             moveq.l   #-1,d0           ; und Auflîsung
             move.l    d0,-(sp)         ; restaurieren
             move.l    d0,-(sp)
             move.w    #5,-(sp)
             trap      #14
             lea.l     12(sp),sp

             move.l    ssp,-(sp)        ; wieder in User-Modus gehen
             move.w    #$20,-(sp)
             trap      #1
             addq.l    #6,sp

             clr.l     -(sp)            ; Programm beenden
             trap      #1

; Diese Routine wird bei jedem neuen Bildschirmaufbau aufgerufen
vbl:         movem.l   d0-d7/a0-a6,-(sp)          ; Register retten

             lea.l     sve_buf(pc),a0
             bsr       rm_spr           ; Sprite wieder vom Bildschirm lîschen

             movea.l   xpos,a2          ; neue X-Position holen
             move.w    (a2)+,d0
             tst.w     (a2)             ; ist die Tabelle schon zu Ende ?
             bpl       weiterx
             lea.l     xtab,a2          ; wenn ja, dann wieder von vorn
weiterx:     move.l    a2,xpos

             movea.l   ypos,a2          ; neue Y-Position holen
             move.w    (a2)+,d1
             tst.w     (a2)
             bpl       weitery
             lea.l     ytab,a2
weitery:     move.l    a2,ypos

             lea.l     sprite(pc),a0    ; und an neue Position setzen
             lea.l     sve_buf(pc),a1
             bsr       set_spr

             movem.l   (sp)+,d0-d7/a0-a6          ; Register wieder herstellen
             rts                        ; und Routine beenden

; *** main

; *** SET_SPR ***

; d0=X-Pos.  d1=Y-Pos.  a0=Spr.adr.  a1=Spr.buf.

set_spr:     movea.l   screen(pc),a2    ; Logbase
             lsl.w     #5,d1            ; mal 160
             move.w    d1,d2
             add.w     d1,d1
             add.w     d1,d1
             add.w     d2,d1
             move.w    d0,d2            ; X-Position merken
             lsr.w     #1,d0            ; X-Position
             andi.b    #$f8,d0          ; umrechnen
             add.w     d0,d1            ; X+Y
             adda.w    d1,a2            ; zum Offset
             andi.w    #$000f,d2        ; Anzahl Rotationen
             lsl.w     #6,d2            ; mal 320(LÑnge
             move.w    d2,d0            ; eines Shifts)
             add.w     d2,d2
             add.w     d2,d2
             add.w     d0,d2
             adda.w    d2,a0            ; Sprite in diesem Shift setzen

; Hier wird der Hintergrund gerettet:

             movea.l   a2,a3            ; Register schonen
             move.l    a2,(a1)+         ; Adresse merken
             moveq.l   #15,d0           ; 16 Zeilen retten
sve_loop:    move.l    (a3)+,(a1)+
             move.l    (a3)+,(a1)+
             move.l    (a3)+,(a1)+
             move.l    (a3)+,(a1)+
             lea.l     144(a3),a3       ; nÑchste Zeile
             dbra      d0,sve_loop

; Jetzt muû die jeweilige Zeile ausmaskiert werden:

             moveq.l   #15,d5           ; 16 Zeilen
set_loop:    movem.l   (a0)+,d0-d4      ; Maske 1. Zeile
             movea.l   a2,a3
             and.w     d0,(a3)+
             and.w     d0,(a3)+
             and.w     d0,(a3)+
             and.w     d0,(a3)+
             swap.w    d0
             and.w     d0,(a3)+
             and.w     d0,(a3)+
             and.w     d0,(a3)+
             and.w     d0,(a3)+

; Jetzt muû das Sprite gesetzt weren:

             lea.l     8(a2),a3
             or.l      d1,(a2)+
             or.l      d2,(a2)+
             or.l      d3,(a2)+
             or.l      d4,(a2)+

; nÑchste Zeile adressieren:

             lea.l     144(a2),a2
             dbra      d5,set_loop
             rts       

; *** set_spr

; *** RM_SPR ***

rm_spr:      move.l    (a0)+,d0         ; Zieladresse
             beq.s     quit_rm_spr      ; =0 dann raus!
             movea.l   d0,a1
             moveq.l   #15,d0
rm_spr_loop: 
             movem.l   (a0)+,d1-d4      ; Hintergrunddaten lesen
             move.l    d1,(a1)+         ; Hintergrunddaten schreiben
             move.l    d2,(a1)+
             move.l    d3,(a1)+
             move.l    d4,(a1)+
             lea.l     144(a1),a1
             dbra      d0,rm_spr_loop   ; nÑchste Zeile
quit_rm_spr: rts       

; *** rm_spr

; *** SHIFT ***

shift:       movem.l   d0-d7/a0-a3,-(sp)          ; Register retten
             movea.l   a0,a2            ; zum restaurieren
             movea.l   a1,a3            ; der Register
             moveq.l   #15,d0           ; Anzahl Sprites
cp_sh_loop:  moveq.l   #15,d1           ; Anzahl Zeilen
cp_sh_loop1: move.w    (a0)+,(a1)+      ; 1 Maske
             clr.w     (a1)+            ; kopieren
             move.l    (a0)+,(a1)+      ; 4 Bitplanes
             move.l    (a0)+,(a1)+      ; kopieren
             clr.l     (a1)+            ; fÅr's geshiftete
             clr.l     (a1)+
             dbra      d1,cp_sh_loop1   ; nÑchste Zeile
             movea.l   a2,a0            ; retstaurieren
             dbra      d0,cp_sh_loop    ; nÑchster Sprite
             movea.l   a3,a1            ; restaurieren

; Nachdem das Sprite in seiner Ursprungsform ( plus den 4 leeren
; Bitplanes, in die hineingeshiftet wird) kopiert wurde,folgt
; nun der Shiftvorgang.

             moveq.l   #1,d7            ; Anzahl Rotationen
             moveq.l   #15,d6           ; Anzahl Sprites
loop_spr:    moveq.l   #15,d5
loop_line:   move.l    (a1),d0
             lsr.l     d7,d0
             swap.w    d0               ; mÅûte sonst beim Setzen erfolgen
             not.l     d0
             move.l    d0,(a1)
             lea.l     20(a1),a1        ; nÑchste Zeile
             dbra      d5,loop_line
             addq.w    #1,d7            ; +1 Rotation
             dbra      d6,loop_spr
             movea.l   a3,a1

             lea.l     320(a1),a1       ; erstes Sprite Åbergehen
             moveq.l   #14,d0           ; 15 Sprites
             moveq.l   #1,d7            ; Anzahl Rotationen
sh_loop:     bsr.s     shift_one        ; ein Sprite shiften
             addq.l    #1,d7            ; eine Rotation mehr
             lea.l     320(a1),a1       ; nÑchstes Sprite
             dbra      d0,sh_loop

             movem.l   (sp)+,d0-d7/a0-a3
             rts       

shift_one:   movem.l   d0-d4/a1,-(sp)
             moveq.l   #15,d4           ; 16 Zeilen
shift_one_loop:        addq.l           #4,a1     ; Maske Åbergehen
             movem.w   (a1),d0-d3
             swap.w    d0               ; oberes Word
             swap.w    d1               ; lîschen
             swap.w    d2
             swap.w    d3
             clr.w     d0
             clr.w     d1
             clr.w     d2
             clr.w     d3
             lsr.l     d7,d0
             lsr.l     d7,d1
             lsr.l     d7,d2
             lsr.l     d7,d3
             movem.w   d0-d3,8(a1)
             swap.w    d0
             swap.w    d1
             swap.w    d2
             swap.w    d3
             movem.w   d0-d3,(a1)
             lea.l     16(a1),a1        ; nÑchste Zeile
             dbra      d4,shift_one_loop
             movem.l   (sp)+,d0-d4/a1
             rts       

; *** shift

; *** SCR_INIT ***

scr_init:    movem.l   d0-d2/a0-a2,-(sp)
             clr.w     -(sp)            ; niedrige Auflîsung
             moveq.l   #-1,d0
             move.l    d0,-(sp)
             move.l    d0,-(sp)
             move.w    #5,-(sp)
             trap      #14
             lea.l     12(sp),sp

             movea.l   screen(pc),a0
             movea.l   screen1(pc),a1
             move.w    #1999,d0
cls_loop:    move.l    #$a5432145,(a0)  ; irgend ein Hintergrund
             move.l    (a0)+,(a1)+
             move.l    #$56744764,(a0)
             move.l    (a0)+,(a1)+
             move.l    #$074635da,(a0)
             move.l    (a0)+,(a1)+
             move.l    #$537a85f2,(a0)
             move.l    (a0)+,(a1)+
             dbra      d0,cls_loop
             pea       colors(pc)       ; eigene Farben
             move.w    #6,-(sp)
             trap      #14
             addq.l    #6,sp
             movem.l   (sp)+,d0-d2/a0-a2
             rts       

; *** scr_init

; *** VSYNC ***
vsync:       movem.l   d0-d2/a0-a2,-(sp)
             moveq.l   #37,d0           ; wartet auf den nÑchsten
             move.w    d0,-(sp)         ; Bildschirmaufbau
             trap      #14
             addq.l    #2,sp
             movem.l   (sp)+,d0-d2/a0-a2
             rts       

; *** vsync

; *** INIT ***
init:        
             move.w    #2,-(sp)         ; Physbase ermitteln
             trap      #14
             addq.l    #2,sp
             lea.l     screen(pc),a0
             move.l    d0,(a0)
             move.w    #3,-(sp)         ; Logbase ermitteln
             trap      #14
             addq.l    #2,sp
             lea.l     screen1(pc),a0
             move.l    d0,(a0)
             rts       

; *** init
             .DATA 
; *** DATA ***
colors:      .DC.w $0000,$0700,$0730,$0750,$0660,$0470,$70,$75
             .DC.w $77,$57,$27,$0007,$0507,$0707,$0704,$7777
; ab hier kommen die Spritedaten:
spr_img:     .DC.w $07c0,$0000,$0000,$07c0,$0000  ; kleiner Smiley
             .DC.w $1ff0,$0000,$0000,$1ff0,$0000
             .DC.w $3ff8,$0e70,$0e70,$3ff8,$0e70
             .DC.w $7ffc,$0e70,$0e70,$7ffc,$0e70
             .DC.w $fffe,$0c30,$0c30,$fdbe,$0c30
             .DC.w $fffe,$0810,$0810,$f99e,$0810
             .DC.w $fffe,$0000,$0000,$dff6,$0000
             .DC.w $fffe,$0000,$0000,$cfe6,$0000
             .DC.w $fffe,$0000,$0000,$e7ce,$0000
             .DC.w $fffe,$0000,$0000,$f01e,$0000
             .DC.w $7ffc,$03c0,$0000,$783c,$0000
             .DC.w $3ff8,$0700,$0080,$38b8,$0080
             .DC.w $1ff0,$0700,$0100,$1930,$0100
             .DC.w $0fc0,$0700,$0100,$0900,$0100
             .DC.w $07c0,$0700,$0100,$0100,$0100
             .DC.w $0380,$0380,$0000,$0000,$0000

; dies sind die X- und Y-Tabellen:
xtab:        .DC.w 100,104,107,109,110,111,110,109,107,104,-1
ytab:        .DC.w 100,104,107,109,110,111,111,110,109,107,104,-1
; *** data
             .BSS 
; *** BSS
sprite:      .DS.b (64+256)*16          ; (Maske+Bitplanes)*Shifts
screen:      .DS.l 1   ; logischer und
screen1:     .DS.l 1   ;physikalischer Screen
sve_buf:     .DS.l 260 ; 1 Sprite (Adresse+Hintergrund)
ssp:         .DS.l 1
xpos:        .DS.l 1
ypos:        .DS.l 1
; *** bss

             .END 

