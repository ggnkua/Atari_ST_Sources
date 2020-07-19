; ####################################################
; ## CURSOR-Funktionen. Modul fÅr VT100EMU          ## Letzte Bearbeitung:
; ## alle Routinen werden mit rts abgeschlossen     ## 12.3.1995
; ## VerÑnderte Register: d5                        ##
; ####################################################

CLR_HOME:    bsr  clear_screen
CURSOR_HOME: move   status(a6),d0     ; Origin-Mode on (Region) ?
             btst   #6,d0
             beq.s  \noregion
             move   reg_top(a6),cursor_y(a6)
             bra.s  RETURN
\noregion    clr  cursor_y(a6)
RETURN:      clr  cursor_x(a6)
             rts
                                             ; ORIGIN Mode ?
PRINT_AT:    lea   varwert1(pc),a0
             move  (a0),cursor_y(A6)
             move  2(a0),cursor_x(A6)
             subq  #1,cursor_x(a6)
             subq  #1,cursor_y(a6)
             rts
CURSOR_LEFT:
BSP:         tst   cursor_x(A6)
             beq.s \ret
             subq  #1,cursor_x(A6)
\ret         rts


CURSOR_RIGHT: move cursor_x(a6),d5
             cmp max_curx(a6),d5
             beq.s cret
             addq #1,cursor_x(a6)
cret         rts

NEWLINE:     clr    cursor_x(a6)
CURSOR_DOWN_scroll:
LINEFEED:    move   cursor_y(a6),d1
             move   status(a6),d0     ; Origin-Mode on (Region) ?
             btst   #6,d0
             beq.s  \noregion         ; nein, dann hierher
             cmp    reg_bot(A6),d1    ; Cursor am unteren Rand ?
             beq    MULTISCROLLUP            ; Ja, Region hochscrollen
             blt.s  \doit                     ; Cursor innerhalb bereich
                                     ; nein, dann noch ganzen Screen checken
                                    ; (sollte nicht vorkommen) kann auch iognoriert werden
\noregion    cmp    max_cury(a6),d1 ; Cursor am unteren Rand ?
             beq    SCROLL_UP                 ; Ja, ganzen Screen hochscrollen
\doit        addq   #1,cursor_y(A6)           ; Nein, gehe eins nach unten
             rts

CURSOR_UP_scroll:  subq  #1,cursor_y(a6)
             bge.s  cret          ; Noch im Bildschirm ?
             clr  cursor_y(a6)    ; Nein, dann scrollen
             BRA   SCROLL_DOWN

CURSOR_DOWN: move   cursor_y(a6),d1
             move   status(a6),d0     ; Origin-Mode on (Region) ?
             btst   #6,d0
             beq.s  \noregion
             cmp    reg_bot(a6),d1 ; Cursor am unteren Rand ?
             beq.s  \ret            ; Ja, nixtun
             blt.s  \doit           ; Cursor innerhalb bereich
                                    ; nein, dann noch ganzen Screen checken
                                    ; (sollte nicht vorkommen) kann auch iognoriert werden
\noregion    cmp    max_cury(a6),d1 ; Cursor am unteren Rand ?
             beq.s  \ret            ; Ja, nixtun
\doit        addq   #1,cursor_y(A6) ; Nein, gehe eins nach unten
\ret         rts

CURSOR_UP:   subq   #1,cursor_y(a6)
             bge.s  \ret             ; Noch auf Screen ?
             clr    cursor_y(a6)
\ret         rts

curnup:     move varwert1(pc),d5
            tst  d5
            BnE.s  \1        ; 0, DANN EINEN Schritt
            moveq #1,D5
\1          sub   d5,cursor_y(a6)
            rts

curndown:   move varwert1(pc),d5
            tst   d5
            bne.s  \1
            moveq  #1,D5
\1          add  d5,cursor_y(a6)
            rts

curnleft:   move varwert1(pc),d5
            tst    d5
            bne.s  \1
            moveq  #1,D5
\1          sub d5,cursor_x(a6)
            rts

curnright:  move varwert1(pc),d5
            tst d5
            bne.s \1
            moveq #1,D5
\1          add   d5,cursor_x(a6)
            rts

SAVECURSP:    move cursor_x(A6),(curxs-esc_vars)(a6)
              move cursor_y(A6),(curys-esc_vars)(a6)
              move style(a6),(cur_s_flgs-esc_vars)(a6)
              rts
RESTORECURSP: move curxs(pc),cursor_x(A6)
              move curys(pc),cursor_y(A6)
              move cur_s_flgs(pc),style(a6)
              rts

CURSOR_ON:   sf  (cursor_o_o_flg-esc_vars)(a6)
             rts
CURSOR_OFF:  st  (cursor_o_o_flg-esc_vars)(a6)
             rts

HIDE_CURSOR: tst.b (cursor_s_h_flg-esc_vars)(a6) ; Cursor gar nicht an ?
             beq.s \ret
             sf    (cursor_s_h_flg-esc_vars)(a6)
             tst.b (cursor_v_l_flg-esc_vars)(a6) ; Cursor von Interrupt Åberhaupt
             bne.s cccu                          ; gerade zu sehen ?
\ret         rts
SHOW_CURSOR: tst.b (cursor_o_o_flg-esc_vars)(a6) ; soll Cursor eingeschaltet werden ?
             bne.s \ret                          ; nein, dann tue nichts
             tst.b (cursor_s_h_flg-esc_vars)(a6) ; Ist Cursor schon an ?
             bne.s \ret                          ; Ja, dann tue nichts
             bsr.s cccu                          ; Cursor darstellen (invertiere Curpos)
             st (cursor_v_l_flg-esc_vars)(a6)    ; Interrupt darf beginnen
             st (CURSOR_S_H_FLG-esc_vars)(a6)    ; merke
\ret         rts

; ############################################
; ## Funktion invertiert Cursorposition.    ##
; ## VerÑnderte Register: d0,d1,a0          ##
; ## nur Supervisormodus !                  ##
; ############################################
CCCu:   move.l $44e,a0
        move   cursor_y(a6),d1
        MULU   #80*16,D1
        lea    (a0,d1.w),a0
        move   cursor_x(a6),d1
        lea    (a0,d1.w),a0
        not.b     (a0)
        not.b   80(a0)
        not.b  160(a0)
        not.b  240(a0)
        not.b  320(a0)
        not.b  400(a0)
        not.b  480(a0)
        not.b  560(a0)
        not.b  640(a0)
        not.b  720(a0)
        not.b  800(a0)
        not.b  880(a0)
        not.b  960(a0)
        not.b  1040(a0)
        not.b  1120(a0)
        not.b  1200(a0)
        rts

N_H_TAB:     move  varwert1(pc),d5
             tst   d5
             beq.s \1      ; Null ? dann einmal
             subq  #1,d5
\1           BSR.s H_TAB
             dbra  d5,\1
             rts

H_TAB:       move   cursor_x(a6),d0
             cmp    max_curx(A6),d0
             beq.s  \ret
             lea    X_TABS(pc),a0       ; D5 tabu !
             lea    (a0,d0.w),a0
             MOvE.B (A0)+,D2
\k           move.b (a0)+,d2
             addq   #1,d0
             cmp    max_curx(A6),d0
             beq.s  \x
             cmp.b  #"o",d2
             bne.s  \k
\x           move   d0,cursor_x(A6)
\ret         rts

N_B_TAB:     move varwert1(pc),d5
             tst d5
             beq.s \1      ; Null ? dann einmal
             subq  #1,d5
\1           BSR.s B_TAB
             dbra  d5,\1
             rts

B_TAB:       move   cursor_x(A6),d0     ; D5 tabu !
             tst    d0                  ; = 0 ?
             beq.s  \ret
             lea    X_tabs(pc),a0
             lea    (a0,d0.w),a0
             subq.l  #1,a0
\bk          subq.l  #1,a0
             move.b (a0),d2
             subq   #1,d0
             tst    d0                  ; =0
             beq.s  \b
             cmp.b  #"o",d2
             bne.s  \bk
\b           move   d0,cursor_x(A6)
\ret         rts

N_V_TAB:     move varwert1(pc),d5
             tst d5
             beq.s \1      ; Null ? dann einmal
             subq  #1,d5
\1           BSR.s V_TAB
             dbra  d5,\1
             rts

V_TAB:       move   cursor_y(a6),d0
             cmp    max_cury(a6),d0  ; Cursor in unterster Zeile ?
             beq.s  \ret           ; Ja, ende
             lea    Y_TABS(pc),a0                  ; D5 tabu !
             lea    (a0,d0.w),a0
             move.b (a0)+,d2         ; ab nÑchser Zeile
\yk          move.b (a0)+,d2
             addq   #1,d0
             cmp    max_cury(a6),d0 ; Jetzt ganz unten ?
             beq.s  \y              ; Ja, ende
             cmp.b  #'o',d2         ; Ist es Tab-Position ?
             bne.s  \yk          ; Nein, weiter
\y           move   d0,cursor_y(a6)
\ret         rts

; INitialisiert Tabulatoren: V-tabs lîschen und bei H-Tab jeden 8ten setzen
; 1. Tab kommt an Position 9 (bei Rand=1)

inittabs     lea    x_tabs(pc),a0
             move   max_curx(a6),d0
             addq   #1,d0
             lsr    #3,d0         ; /8
             subq   #1,d0         ; wegen dbra
             clr.b  (a0)+         ; erste Pos kein tab
\hook        clr.b  (a0)+
             clr.l  (a0)+
             clr.w  (a0)+

             move.b #'o',(a0)+
             dbra   d0,\hook
CLR_VTABS    move   max_cury(a6),d0
             lea    y_tabs(pc),a0
\hook        clr.b  (a0)+
             dbra   d0,\hook
             rts

; #########Tabulatorfunktionen###############
tab_m:      move  varwert1(pc),d6
            tst   d6
            beq.s clr_tab
            cmp   #3,d6
            beq.s clr_tabs
            rts

CLR_TABS     bsr.s  clr_Vtabs
CLR_HTABS    move   max_curx(a6),d0
             lea    x_tabs(pc),a0
\hook        clr.b  (a0)+
             dbra   d0,\hook
             rts
SET_VTAB     lea    y_tabs(pc),a0
             move   cursor_y(a6),d0
             move.b #'o',(a0,d0)
             rts
SET_TAB      bsr.s  set_vtab
SET_HTAB     lea    x_tabs(pc),a0
             move   cursor_x(a6),d0
             move.b #'o',(a0,d0)
             rts
CLR_VTAB     lea    y_tabs(pc),a0
             move   cursor_y(a6),d0
             clr.b  (a0,d0)
             rts
clr_TAB      bsr.s  clr_vtab
clr_HTAB     lea    x_tabs(pc),a0
             move   cursor_x(a6),d0
             clr.b  (a0,d0)
             rts


   bss
curxs:      ds.w 1
curys:      ds.w 1
cur_s_flgs: ds.w 1

X_TABS:     ds.b 82
Y_TABS:     ds.b 26
                 align
   text

   end
 