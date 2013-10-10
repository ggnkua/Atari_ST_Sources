; +-------------------------------------------------------------------------+
; | Transformiert Punkte mit DSP.                                           |
; | Beinhaltet optional auch kleinen FlÑchenhandler, der FlÑchen sortiert.  |
; +-------------------------------------------------------------------------+
; | Coded 1994 (Mai/Juni) Jochen Knaus aka BDCannibal...                    |
; | Aber viele andere Dinge entstanden auch im Juni/Mai: Urlaub, Abi, PMOD- |
; | Manager, Gouraudfilling, PMOD-Umwandlungen alter Routinen und und und...|
; +-------------------------------------------------------------------------+

; Version:    0.13
; Update:     6.8.1994
; Update B:   9.1.1995
; Coderight:  Jochen Knaus, BDCannibal/AURA

;*****************************************************************************
; Parallelroutine Programmierkonventionen:
;             - <d7>, <a6> darf nicht benutzt werden.
;             - <sr> darf nicht verÑndert werden.
;*****************************************************************************

;*****************************************************************************
; Vorgehen beim Parallelbetrieb:
;                Hauptprogramm    +--- RTS-Adresse sichern, DSP starten
;                               jsr            
;          +------Transform-----+     Parallelroutine starten
;          |          |    +-----+             
;          |          |           |     DSP-IRQ unterbricht, holt Daten,
;          |          |                rettet P-Rout-Adresse (Stack), RÅck-
;                               |     sprung ins H-Prg
;          |          |           |             |
;          |          |           +------------+
;          +-----NÑchster Tranform
;                     |
;             Parallelrout fertig?
;                    / \
;                ja /   \ nein
;                  /     \
;                  |      Parallelroutine bis zum Ende -+
;                  \     /          |                    |
;                   \   /           +-------------------+
;                    \+/
;                     |
;             Hauptprogramm mit DSP-Daten und P-Routinendaten
;*****************************************************************************

              MC68030
              MODUL   "F:\LIB\DSP3DSYS.INC"
              OPT     D-,O+
              ORG     0

IVR           EQU     255                   ; DSP-Interruptnr. in MC-Vectortab
IRQ_SWITCH    EQU     0                     ; 0: IRQs wÑhrend DatenÅbertragung
                                            ; ausmaskieren ? Leave: sr=$2300 !
s_tra:        bra.w   init_dsp              ; DSP-resetten und Prg laden
              bra.w   transform             ; Transformieren.
              bra.w   trans_faces           ; Transformieren und Polyhandler.
              bra.w   init_parallel         ; Parallelprogramm installieren.
              bra.w   fin_p_prg             ; Beendet P-Prg.

              DC.B    'PMOD'                ; Kennung
              DC.B    'DSP-Tran&Polyh.',0   ; Modulnamen
              DC.B    'BDCannibal/AURA',0   ; Autor.
              DC.B    '04930195'            ; Erstes Datum, Letztes Update
              DC.B    '001130D-'            ; Version xx.yy / 68020 / DSP
              DC.B    '--------'

              INCLUDE "f:\pool.030\macros\dsp_host.q"
ads:          INLINE  "f:\pool.dsp\ads\dsp_sys.inl"     ; AURA-DSP-System
trans:        INLINE  "f:\lib\sources\dsp_3d\sys3d.ads" ; DSP-3D-System

PAR_START     MACRO                         ; Startet Parallelverarbeitung.
              movea.l irq_adr(pc),a6        ; a6 ist lokales Register
              move.l  \1,(a6)               ; Interrupt installieren
              lea     dsp_reg(pc),a6        ; Register DSP-Proggy.
              movem.l d0-a5,(a6)
              movem.l parallel_reg(pc),d0-a5    ; Regs. des P-Prgs.
              ENDM

PAR_GO        MACRO                         ; Parallelproggy abfetzen.
              move.l  #$ff,$ffff9800.w
              bset    #0,$ffffa200.w        ; DSP-Receive-Irq an.
              move    d7,ccr                ; Flags setzen
              jmp     ([parallel_adr.w,pc]) ; P-Routine starten
              ENDM

PAR_ENDE      MACRO                         ; Beendet Parallelverarbeitung.
              move    ccr,d7                ; Flags retten
              bclr    #0,$ffffa200.w        ; DSP-Irq aus.
              lea     parallel_reg(pc),a6   ; Register sichern
              movem.l d0-a5,(a6)
              movem.l dsp_reg(pc),d0-a5     ; Register DSP-Programm.

              move.l  #$ffffffff,$ffff9800.w
              lea     parallel_adr(pc),a6   ; <rte> Adr. = nÑchste P-Routinen
              move.l  2(sp),(a6)            ; Einsprungadresse.
              move.l  rte_adr(pc),2(sp)     ; RÅcksprung ins Hauptproggy.
              ENDM

SAVE_RTE      MACRO                         ; Returnadr. ins Hauptprogramm
              lea     rte_adr(pc),\1        ; sichern und diesen "jsr"
              move.l  (sp)+,(\1)            ; ausgleichen.
              ENDM

IRQ_AUS       MACRO
                IFEQ  IRQ_SWITCH
                  move  #$2700,sr
                ENDIF
              ENDM

IRQ_EIN       MACRO
                IFEQ  IRQ_SWITCH
                  move  #$2300,sr
                ENDIF
              ENDM

; ========================================================================
; Initialisiert DSP mit Transformationsproggy. 
; Parameter:  d0.w    == 0 : ADS installieren.
;                     != 0 : ADS bereits installiert.
; ========================================================================
init_dsp:     tst.w   d0                ; ADS komplett installieren ?
              bne.s   .no_inst_ads      ; Nein (z.B. wegen Moduleplayers)

              bsr.w   ads               ; ADS installieren.

.no_inst_ads: lea     trans(pc),a0      ; Transformationsprogramm starten.
              bsr.w   (ads+4)

              movec   vbr,a0
              lea     IVR*4(a0),a0      ; Adresse des Vektors.
              lea     dsp_ir(pc),a1
              andi.b  #$fc,$ffffa200.w  ; DSP-Interrupts disablen.
              move.b  #IVR,$ffffa203.w  ; DSP-Interruptnummer (MC-Vectabelle)
              move.l  a1,(a0)           ; DSP-Interrupt installieren.

              lea     irq_adr(pc),a1    ; Interruptadresse
              move.l  a0,(a1)

              lea     parallel_adr(pc),a0   ; Parallelprozeû defaultmÑûig
              clr.l   (a0)+             ; unterbinden.
              clr.l   (a0)

              lea     parallel(pc),a0   ; Kein paralleler Prozeû aktiv.
              clr.w   (a0)
              rts

;=============================================================================
; Transformiert Punkte und berechnet die FlÑchenreihenfolge...
; Transmode NUR 2 (px/py)...

; d1.w - Offset Urpunkte.
; d2.w - Offset Zielpunkte.
; d7.w - Anzahl FlÑchen.
; a4.l - Reihenfolgebuffer.
; a5.l - Polygonstrukturenpointer. (*1)
; a6.l - Parablock.

; Return:
; d0.w - Anzahl sichtbarer FlÑchen.

; (*1):       0.l     - Polygondaten Poly a
;             4.l     - Punktearrayoffset Poly a

; Aufgrund der Stackstruktur kînnen KEINE Register gesichert werden.
;=============================================================================
trans_faces:  SAVE_RTE     a3           ; RÅcksprungadr. sichern
              IRQ_AUS                   ; ggf. Interrupt ausmaskieren.

              move.w  d7,-(sp)
              moveq   #2,d0             ; Mode 2 Standart.
              bsr.w   send_pa_po        ; Parameter und Punkte senden.
              clr.l   d7                ; d7.high = 0
              move.w  (sp)+,d7          ; d7.low  = Anzahl FlÑchen

              lea     $ffffa204.w,a2    ; DSP-Transbase (high-word)
              lea     $ffffa206.w,a3    ; DSP-Transbase (low-word)

              TX_DSP_Lahs  d7,a2        ; Anz. FlÑchen an DSP.
              beq.w   forget_rest       ; Keine FlÑchen: Nur Punkte abholen.

              subq.w  #1,d7
send_faces:   WAIT_DSP_W                ; Transmithandshake
              move.l  (a5)+,a0          ; Polygonadr.
              move.l  (a5)+,d1          ; Punkteoff. Weltkoo.array
              addq.l  #4,a0             ; Farbe uninteressant
              move.w  (a0)+,d0          ; Anz. Punkte minus 1
              addq.w  #1,d0             ; Anz. Punkte
              TX_DSP_La    d1,a2        ; Weltkoo.off.
              TX_DSP_Wahs  d0,a3        ; Anz. Eckpunkte an DSP
              neg.w   d0
              addq.w  #8,d0
              jmp     (send_dsp_eck.b,pc,d0.w*2)

send_dsp_eck:                           ; Eckpunktnummern Åbertragen.
              REPEAT
              TX_DSP_Wa    (a0)+,a3
              UNTIL   #(8-1)            ; Nach letztem geht DSP ab.
              dbra    d7,send_faces     ; NÑchstes Polygon...

              tst.w   parallel(pc)      ; Parallelprozeû ?
              beq.s   no_para_d_re

              lea     dsp_ready(pc),a5  ; Interruptadresse
              IRQ_EIN
              PAR_START    a5           ; Parallelprogramm lauffÑhig...
              PAR_GO                    ; ...und starten
dsp_ready:    PAR_ENDE                  ; Parallelprogrammstatus sichern.
              IRQ_AUS
              bra.s   .no_wait_dsp      ; Kein Warten auf DSP mehr, Daten
                                        ; MöSSEN da sein (Irq-Request).
no_para_d_re: 
              WAIT_DSP                  ; Ohne Parallelproggy einfach warten.
.no_wait_dsp:

              RX_DSP_Wa    d0,a3        ; d0 = Anz. sichtbarer FlÑchen.
              move.w  d0,d7
              move.w  d0,d1
              asr.w   #3,d0
              ble.s   rest_visibles
              subq.w  #1,d0
              WAIT_DSP                  ; Sicherheitshandshake.
visibles:     REPEAT
              RX_DSP_Wa    (a4)+,a3     ; Identifys der sichtbaren FlÑchen
              UNTIL   #(8-1)
              dbra    d0,visibles       ; holen.

rest_visibles:
              moveq   #7,d0
              and.w   d0,d1
              ble.s   forget_rest
              eor.w   d0,d1
              jmp     (rest_vs.b,pc,d1.w*2) ; Ohne Handshake: 4 Bytes   
rest_vs:      REPEAT
              RX_DSP_Wa    (a4)+,a3
              UNTIL   #(7-1)

forget_rest:  moveq   #2,d0                 ; Nur px/py holen
              bsr.w   get_points            ; Punkte empfangen.

              IRQ_EIN

              tst.w   parallel(pc)
              bne.s   ciau_rte2
              move.w  d7,d0
              jmp     ([rte_adr.w,pc])
ciau_rte2:    move.w  d7,d0
              rte                           ; Das war ein Interrupt!

; ========================================================================
; Transformiert Punkte im gewÅnschten Modus.

; d0.w - Transformationsmodus
; d1.w - Offset Urpunkte (fÅr Shadinginfos etc...)
; d2.w - Offset Zielpunkte
; a6.l - Parablock
; ========================================================================
transform:    SAVE_RTE     a5           ; Returnadr. sichern
              IRQ_AUS

              bsr.w   send_pa_po        ; Parameter und Punkte senden.

              moveq   #0,d7             ; Keine FlÑchen->Objekthandler aus.
              TX_DSP_Lhs   d7           ; DSP ab.

              tst.w   parallel(pc)      ; Parallelprozeû ?
              beq.s   no_para_gets

              lea     gets(pc),a5       ; Interruptadresse
              IRQ_EIN
              PAR_START    a5           ; Parallelprogramm lauffÑhig...
              PAR_GO                    ; ...und starten
gets:         PAR_ENDE                  ; Parallelprogrammstatus sichern.
              IRQ_AUS
              bra.s   .no_wait_dsp_
no_para_gets: WAIT_DSP                  ; Warten (ohne Parallelprozeû!)
.no_wait_dsp_:
              bsr.s   get_points        ; Transformierte Punkte vom DSP.
              IRQ_EIN

              tst.w   parallel(pc)      ; Parallel erfordert anderen Ausstieg.
              bne.s   ciau_rte
              jmp     ([rte_adr.w,pc])
ciau_rte:     rte                       ; ZurÅck ins Hauptprogramm !

; Parameter und Punkte senden.
; a6.l Parameter
send_pa_po:   LEA_HOST_W   a2
              LEA_HOST_L   a3
              ext.l   d0                ; d0 Highword lîschen.
              ext.l   d1
              ext.l   d2
              move.w  (a6)+,d7          ; Anzahl Punkte.
              move.l  (a6)+,a0          ; Punktearrayadr.
              move.l  (a6)+,a1          ; Destinationadr.
              TX_DSP_Lahs  d0,a3        ; Modus.
              TX_DSP_Wa    d7,a2        ; Anzahl Punkte.
              TX_DSP_Wa    (a6)+,a2     ; Alle Winkel Åbertragen.
              TX_DSP_Wa    (a6)+,a2
              TX_DSP_Wa    (a6)+,a2     
              movem.w (a6)+,d3-d5       ; eve. auch negativ.
              TX_DSP_La    d3,a3        ; Beobachter bzw. Translation
              TX_DSP_La    d4,a3        ; rÅberschaufeln.
              TX_DSP_La    d5,a3

              subq.w  #1,d7             ; Alle Punkte rÅberschaufeln.
              move.w  d7,d6
tx_pnts_3:    movem.w (a0)+,d3-d5       ; 16-Bit Vars, extended auf 32 Bit.
              TX_DSP_La    d3,a3        ; 32 Bit Åbertragen, damit auch neg.
              TX_DSP_La    d4,a3        ; Zahlen korrekt auf 24 Bit gesetzt
              TX_DSP_La    d5,a3        ; werden.
              adda.l  d1,a0
              dbra    d7,tx_pnts_3
              rts

; Punkte vom DSP-holen:
; d0.w - Mode
; d2.w - Offset Destinationpunkte
; d6.w - Anzahl - 1
get_points:   subq.w  #2,d0             ; Nur 2 Koordinaten zurÅck ?
              beq.s   rx_pnts_2

rx_pnts_3:    RX_PNT3D_W   a1           ; 3 Werte / Punkt zurÅck.
              adda.l  d2,a1
              dbra    d6,rx_pnts_3
              rts

rx_pnts_2:    RX_PNT2D_W   a1           ; 2 Werte / Punkt zurÅck.
              adda.l  d2,a1
              dbra    d6,rx_pnts_2
              rts

; Parallelroutine im Handler initialisieren.
; Auf dem Stack:      Adr. Routine:     0.l - Keine Parallelverarbeitung.
init_parallel:
              lea     parallel_reg(pc),a6   ; Register sichern.
              clr.w   d7                ; CCR lîschen.
              movem.l d0-a5,(a6)
              lea     parallel_adr(pc),a6   ; Startadresse laden.
              lea     parallel(pc),a5
              clr.w   d6                ; Parallelflag.
              
              move.l  4(sp),a0          ; Routinenadresse
              move.l  a0,d0
              sne     d6
              bne.s   install_user      ; Adr. != NULL --> Userrout

              lea     dummy(pc),a0      ; Dummyrout installieren.

install_user: move.l  a0,(a6)           ; Liegt auf dem Stack.
              move.w  d6,(a5)           ; Parallelflag.
              rtd     #4                ; Startadresse Åbergehen.

; Beendet das P-Programm mit voller Rechenzeit, nachdem vom Hauptpro-
; gramm das Beendetflag gesetzt wurde.
; Parameter:  keine
fin_p_prg:    tst.w   parallel(pc)      ; öberhaupt P-Prg angemeldet ?
              bne.s   _fin_p_prg

              rts

_fin_p_prg:   movem.l parallel_reg(pc),d0-a5    ; Register
              move    d7,ccr                    ; Flags
              jmp     ([parallel_adr.w,pc])     ; PRG beenden.

dummy:        bra.s   dummy             ; Endloschleife.
dsp_ir:       rte                       ; Dummyinterrupt

dsp_reg:      DS.L    15,0              ; Registerbuffer des DSP-Prgs.
parallel:     DC.W    0                 ; Parallelbetriebsflag
parallel_reg: DS.L    15,0              ; Register des Paralelprogramms
parallel_adr: DC.L    0                 ; Adr. momentaner Stand P-Prg.
rte_adr:      DC.L    0                 ; RÅcksprungadresse DSP-Rout
irq_adr:      DC.L    0                 ; Interruptadresse