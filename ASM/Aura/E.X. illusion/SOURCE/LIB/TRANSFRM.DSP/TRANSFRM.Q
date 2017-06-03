              ORG     $00
              MC68030
              OPT     D-,O+
              MODUL   "f:\lib\dsp_tran.inc"

s_tra:        bra.w   init_dsp
              bra.w   transform

              DC.B    'PMOD'                ; Kennung
              DC.B    'DSP-Tranform...',0   ; Modulnamen
              DC.B    'BDCannibal/AURA',0   ; Autor.
              DC.B    '04930694'            ; Erstes Datum, Letztes Update
              DC.B    '030120D-'            ; Version xx.yy / 68020 / DSP
              DC.B    '--------'

              INCLUDE "f:\pool.030\macros\dsp_host.q"
ads:          INCLUDE "f:\pool.dsp\ads\dsp_sys.q"
trans:        INLINE  "f:\pool.dsp\transpro.20b\trans.ads"

init_dsp:     bsr.w   ads               ; ADS installieren.
              lea     trans(pc),a0      ; Transformationsprogramm starten.
              bra.w   ads+4

; ========================================================================
; Transformiert Punkte im gewÅnschten Modus.

; d0.w - Transformationsmodus
; d1.w - Offset Urpunkte (fÅr Shadinginfos etc...)
; d2.w - Offset Zielpunkte
; a6.l - Parablock
; ========================================================================
transform:    movem.l d6/d7/a0/a1,-(sp)

              ext.l   d0                ; d0 Highword lîschen.
              ext.l   d1
              ext.l   d2
              move.w  (a6)+,d7          ; Anzahl Punkte.
              move.l  (a6)+,a0          ; Punktearrayadr.
              move.l  (a6)+,a1          ; Destinationadr.
              TX_DSP_Lhs   d0           ; Modus.
              TX_DSP_W     d7           ; Anzahl Punkte.
              TX_DSP_W     (a6)+        ; Alle Winkel Åbertragen.
              TX_DSP_W     (a6)+
              TX_DSP_W     (a6)+        
              movem.w (a6)+,d3-d5       ; eve. auch negativ.
              TX_DSP_L     d3           ; Beobachter bzw. Translation
              TX_DSP_L     d4           ; rÅberschaufeln.
              TX_DSP_L     d5

              subq.w  #1,d7             ; Alle Punkte rÅberschaufeln.
              move.w  d7,d6
tx_pnts_3:    movem.w (a0)+,d3-d5       ; 16-Bit Vars, extended auf 32 Bit.
              TX_DSP_L     d3           ; 32 Bit Åbertragen, damit auch neg.
              TX_DSP_L     d4           ; Zahlen korrekt auf 24 Bit gesetzt
              TX_DSP_L     d5           ; werden.
              adda.l  d1,a0
              dbra    d7,tx_pnts_3

              WAIT_DSP                  ; Warten, bis Koords zurÅck.

              subq.w  #2,d0             ; Nur 2 Koordinaten zurÅck ?
              beq.s   rx_pnts_2

rx_pnts_3:    RX_PNT3D_W   a1           ; 3 Werte / Punkt zurÅck.
              adda.l  d2,a1
              dbra    d6,rx_pnts_3

              movem.l (sp)+,d6/d7/a0/a1
              rts

rx_pnts_2:    RX_PNT2D_W   a1           ; 2 Werte / Punkt zurÅck.
              adda.l  d2,a1
              dbra    d6,rx_pnts_2

              movem.l (sp)+,d6/d7/a0/a1
              rts
s_end: