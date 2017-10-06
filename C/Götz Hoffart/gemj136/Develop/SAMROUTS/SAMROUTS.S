; Sample-Abspielroutinen, Sample-Packer und Sample-Konvertierroutinen
; (c) by Jîrg Hahne (joerg_hahne@ka2.maus.de)
; leicht abgeÑndert von Gîtz Hoffart (Gîtz Hoffart @ FR, goetz@hoffart.de)
;
; Abspiel-Routinen
; ----------------
; play_init():      ST-Abspielroutine Installieren
; play_exit():      ST-Abspielroutine Deinstallieren
; play_sam():       STE-Sample auf ST abspielen
; stop_sam():       Abspielen auf ST beenden
; ste_play_sam():   STE-Sample auf STE abspielen
; ste_ready_sam():  
; ste_stop_sam():   Abspielen auf STE beenden

; Konvertier-Routinen
; -------------------
; convert8_sam():    Sample konvertieren
; convert16_sam():    Sample konvertieren
; fix_sam():        Sample von 16 auf 8 Bit konvertieren

                EXPORT play_init,play_exit,play_sam,stop_sam ;Symbole
                EXPORT ste_play_sam,ste_ready_sam,ste_stop_sam
                EXPORT convert8_sam,convert16_sam,fix_sam
                EXPORT sam_flag
;               EXPORT st_pack_sam,st_depack_sam,ste_pack_sam,ste_depack_sam

                TEXT

iera equ $fffffa07
imra equ $fffffa13
tacr equ $fffffa19
tadr equ $fffffa1f
isra equ $fffffa0f
giselect equ $ffff8800
giread equ $ffff8800
giwrite equ $ffff8802

; Abspiel-Routinen ;
; PLAY INIT                                                                   ;
; Deklaration in C: VOID play_init(VOID);                                     ;
; Funktion: Abspielroutine fÅr STs installieren.                              ;
;
play_init:
                movem.l D0-D2/A0-A2,-(SP)
;------------------------ Timer A Init ----------------------------------------
                pea     play_init0(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   play_init3
play_init0:
;------------------------------- alte Werte merken ----------------------------
                move.l  $0134.w,old_timer_a ;Timer A-Vektor merken
                move.b  iera.w,old_iera ;MFP-Register merken
                move.b  imra.w,old_imra

                move.b  tacr.w,old_tacr ;Timer A-Control-Register merken

                clr.b   tacr.w          ;Timer A stoppen
                bset    #5,iera.w       ;Timer A einschalten
                bset    #5,imra.w

                move.l  #play_init2,$0134.w ;Test-Timer A-Vektor setzen
                clr.w   timer_flag      ;Flag lîschen
                move.b  #%111,tacr.w    ;Timer A starten
play_init1:
                tst.w   timer_flag      ;Timer A aufgetreten?
                beq.s   play_init1
;------------------------------- neue Werte setzen ----------------------------
                move.l  #timer_a,$0134.w ;Timer A-Vektor setzen

                rts
;--------------------------------- Test-Timer A -------------------------------
play_init2:
                clr.b   tacr.w          ;Timer A stoppen

                move.b  tadr.w,old_tadr ;Timer A-Data-Register merken
                move.w  #1,timer_flag   ;Flag setzen

                move.b  #%11011111,isra.w

                rte

timer_flag:     DS.W 1                  ;Timer A-Flag

; Soundchip Init ;
play_init3:
                pea     play_init4(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   play_init5
play_init4:
                move.b  #7,giselect.w   ;Register 7 anwÑhlen
                move.b  giread.w,D0     ;Wert lesen
                move.b  D0,old_r7       ;Wert merken

                ori.b   #%111111,D0     ;Ton aus
                move.b  D0,giwrite.w    ;Wert schreiben

                rts

old_r7:         DS.B 1                  ;altes Soundchip-Register 7
                EVEN
play_init5:
                movem.l (SP)+,D0-D2/A0-A2

                rts

; alte Parameter ;
old_iera:       DS.B 1                  ;altes Interrupt Enable Register A
old_imra:       DS.B 1                  ;altes Interrupt Mask Register A

old_timer_a:    DS.L 1                  ;alter Timer A Vektor
old_tacr:       DS.B 1                  ;altes Timer A-Control-Register
old_tadr:       DS.B 1                  ;altes Timer A-Data-Register

					EVEN

;
; PLAY EXIT                                                                   ;
;                                                                             ;
; Deklaration in C: VOID play_exit(VOID);                                     ;
;                                                                             ;
; Funktion: Abspielroutine fÅr STs deinstallieren.                            ;
;
play_exit:
                movem.l D0-D2/A0-A2,-(SP)

                pea     play_exit0(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   play_exit4
; Timer A Exit ;
play_exit0:
                clr.b   tacr.w          ;Timer A stoppen

                move.b  old_iera(PC),iera.w ;alte MFP-Register setzen
                move.b  old_imra(PC),imra.w

                move.l  old_timer_a(PC),$0134.w ;alte Timer A-Werte setzen
                move.b  old_tadr(PC),tadr.w
                move.b  old_tacr(PC),tacr.w
; Soundchip-Register restaurieren ;
                lea     giselect.w,A0   ;A0: Soundchip-Adresse

                moveq   #0,D0
play_exit1:
                move.b  D0,(A0)         ;Register anwÑhlen

                cmpi.w  #7,D0           ;Register 7?
                bne.s   play_exit2

                move.b  old_r7(PC),2(A0) ;Wert setzen
                bra.s   play_exit3
play_exit2:
                clr.b   2(A0)           ;Register zurÅcksetzen
play_exit3:
                addq.w  #1,D0           ;nÑchstes Register
                cmpi.w  #14,D0          ;14 Register
                blt.s   play_exit1

                rts
play_exit4:
                movem.l (SP)+,D0-D2/A0-A2

                rts
;
; PLAY SAMPLE                                                                 ;
;                                                                             ;
; Deklaration in C: VOID cdecl play_sam(BYTE *start, LONG length, WORD freq); ;
;                                                                             ;
; Funktion: Abspielen eines Samples im STE-Format ab 'start' mit der LÑnge    ;
;           'length' und der Frequenz 'freq' auf STs.                         ;
;                                                                             ;
;           Der Wert von 'freq' lÑût sich folgendermaûen berechnen:           ;
;             freq = 614400 Hz / Frequenz                                     ;
;                                                                             ;
;           Den Rechenzeitverbrauch errechnet man so: (nur 68000/8 MHz)       ;
;             Rechenzeit = freq ; (2 / 625)                                   ;
;                                                                             ;
;           ACHTUNG ! Die Routine funktioniert nicht auf FALCONs !            ;
;
play_sam:
                movea.l SP,A0
                movem.l D0-D2/A1-A2,-(SP)

                move.l  4+4(A0),D0      ;D0: LÑnge (Offset 4)
                move.w  4+8(A0),D1      ;D1: Frequenz (Offset 8)
                movea.l 4+0(A0),A0      ;A0: Startadresse (Offset 0)

                move.l  A0,sam_adr      ;Sample-Adresse setzen

                adda.l  D0,A0
                subq.l  #1,A0           ;A0: Sample-Endadresse
                move.l  A0,sam_end      ;Sample-Endadresse setzen

                pea     timer_a(PC)     ;Vektor
                move.w  D1,-(SP)        ;Data Register
                move.w  #1,-(SP)        ;Control Register
                move.w  #0,-(SP)        ;Timer A
                move.w  #$1F,-(SP)      ;Xbtimer (XBIOS 31)
                trap    #14
                lea     $0C(SP),SP
                
                bset    #0,sam_flag     ;Sample-Abspiel-Flag setzen

                movem.l (SP)+,D0-D2/A1-A2

                rts
; Interrupt-Routine ;
timer_a:
                move.l  D0,-(SP)        ;Register retten                   [14]
                pea     (A0)            ;                                  [12]

                movea.l sam_adr(PC),A0  ;A0: Sampleadresse                 [16]
                moveq   #0,D0           ;                                   [4]
                move.b  (A0)+,D0        ;D0: Samplewert                     [8]
                move.l  A0,sam_adr      ;neue Sampleadresse merken         [16]

                cmpa.l  sam_end(PC),A0  ;Ende?                            [18]
                bcs.s   timer_a0        ;                                   [8]

                clr.b   tacr.w          ;Timer A stoppen
                bclr    #0,sam_flag     ;Sample-Abspiel-Flag lîschen
timer_a0:
                lsl.w   #4,D0           ;Offset berechnen (D0 ; 16)     [8+2;4]
                lea     sam_tab(PC,D0.w),A0 ;A0: Tabellenadresse           [12]

                move.l  (A0)+,giselect.w ;LautstÑrkewerte eintragen        [24]
                move.l  (A0)+,giselect.w ;                                 [24]
                move.l  (A0)+,giselect.w ;                                 [24]

                movea.l (SP)+,A0        ;Register restaurieren             [12]
                move.l  (SP)+,D0        ;                                  [12]

                move.b  #%11011111,isra.w ;                                [16]

                rte         				 ; [20]

sam_adr:        DS.L 1                  ;Sample-Adresse
sam_end:        DS.L 1                  ;Sample-Endadresse
sam_flag:       DC.B 0                  ;Sample-Abspiel-Flag
                EVEN

sam_tab:
include "samtab.i"
						EVEN


;
; STOP SAMPLE                                                                 ;
;                                                                             ;
; Deklaration in C: VOID stop_sam(VOID);                                      ;
;                                                                             ;
; Funktion: Stoppen der Abspielroutine fÅr STs.                               ;
;

stop_sam:
                movem.l D0-D2/A0-A2,-(SP)

                pea     stop_sam0(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   stop_sam1
stop_sam0:
                clr.b   tacr.w          ;Timer A stoppen
                bclr    #0,sam_flag     ;Sample-Abspiel-Flag lîschen

                rts
stop_sam1:
                movem.l (SP)+,D0-D2/A0-A2

                rts
;
; STE PLAY SAMPLE                                                             ;
;                                                                             ;
; C: VOID ste_play_sam(BYTE *start, LONG length, WORD freq, WORD mode); ;
;                                                                             ;
; Funktion: Abspielen eines Samples im STE-Format ab 'start' mit der LÑnge    ;
;           'length' und der Frequenz 'freq' durch die STE-DMA-Soundhardware. ;
;           'mode' bestimmt, ob in Mono oder Stereo abgespielt werden soll.   ;
;                                                                             ;
;           Folgende Werte von 'freq' sind mîglich:                           ;
;             0:  6258 Hz                                                     ;
;             1: 12517 Hz                                                     ;
;             2: 25033 Hz                                                     ;
;             3: 50066 Hz                                                     ;
;                                                                             ;
;           Werte fÅr 'mode':                                                 ;
;             0: Stereo-Modus                                                 ;
;             1: Mono-Modus                                                   ;
;                                                                             ;
;           ACHTUNG ! Die Routine funktioniert nur auf STEs; auf STs stÅrzt   ;
;           das Programm ab !                                                 ;
;
ste_play_sam:
                move.l  SP,stack        ;SP merken
                movem.l D0-D3/A1-A2,-(SP)

                pea     ste_play_sam0(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   ste_play_sam1
ste_play_sam0:
                movea.l stack(PC),A0
                move.l  4+4(A0),D0      ;D0: LÑnge (Offset 4)
                move.w  4+8(A0),D1      ;D1: Frequenz (Offset 8)
                move.w  4+10(A0),D2     ;D2: Modus (Offset 10)
                movea.l 4+0(A0),A0      ;A0: Startadresse (Offset 0)

                clr.b   sndmactl.w      ;DMA-Sound aus

                move.l  A0,D3           ;D3: Startadresse
                move.b  D3,sndbaslo.w   ;Startadresse eintragen
                lsr.l   #8,D3
                move.b  D3,sndbasmi.w
                lsr.l   #8,D3
                move.b  D3,sndbashi.w

                add.l   A0,D0
                subq.l  #1,D0           ;D0: Endadresse
                move.b  D0,sndendlo.w   ;Endadresse eintragen
                lsr.l   #8,D0
                move.b  D0,sndendmi.w
                lsr.l   #8,D0
                move.b  D0,sndendhi.w

                andi.w  #%11,D1         ;nur zwei Frequenz-Bits

                andi.w  #%1,D2          ;nur ein Modus-Bit
                lsl.w   #7,D2           ;Bit verschieben
                or.w    D2,D1           ;Bit verknÅpfen

                move.b  D1,sndmode.w    ;Sound-Mode-Control setzen

                move.b  #%1,sndmactl.w  ;DMA-Sound ein

                rts
ste_play_sam1:
                movem.l (SP)+,D0-D3/A1-A2

                rts

stack:          DS.L 1                  ;Stack-Pointer

sndmactl        EQU $FFFF8901           ;Sound-DMA-Control-Register

sndbashi        EQU $FFFF8903           ;Frame-Start-Adresse (High-Byte)
sndbasmi        EQU $FFFF8905           ;Frame-Start-Adresse (Middle-Byte)
sndbaslo        EQU $FFFF8907           ;Frame-Start-Adresse (Low-Byte)

sndendhi        EQU $FFFF890F           ;Frame-End-Adresse (High-Byte)
sndendmi        EQU $FFFF8911           ;Frame-End-Adresse (Middle-Byte)
sndendlo        EQU $FFFF8913           ;Frame-End-Adresse (Low-Byte)

sndmode         EQU $FFFF8921           ;Sound-Mode-Control

;
; STE READY SAMPLE
;
; Deklaration in C: BOOLEAN ste_ready_sam(VOID);
;
; Funktion: Abfrage, ob das Sample abgespielt wurde.
;
ste_ready_sam:
                movem.l D1-D2/A0-A2,-(SP)  
                
                pea     ste_ready_sam0(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   ste_ready_sam3             
ste_ready_sam0:
                btst    #0,sndmactl.w   ;DMA-Sound aus?
                bne.s   ste_ready_sam1
                
                moveq   #-1,D0          ;TRUE zurÅckgeben
                bra.s   ste_ready_sam2
ste_ready_sam1:
                moveq   #0,D0           ;FALSE zurÅckgeben
ste_ready_sam2:
                rts
ste_ready_sam3:
                movem.l (SP)+,D1-D2/A0-A2
                
                rts

;
; STE STOP SAMPLE                                                             ;
;                                                                             ;
; Deklaration in C: VOID ste_stop_sam(VOID);                                  ;
;                                                                             ;
; Funktion: Stoppen der Abspielroutine fÅr STEs.                              ;
;                                                                             ;
;           ACHTUNG ! Die Routine funktioniert nur auf STEs; auf STs stÅrzt   ;
;           das Programm ab !                                                 ;
;
ste_stop_sam:
                movem.l D0-D2/A0-A2,-(SP)

                pea     ste_stop_sam0(PC)
                move.w  #$26,-(SP)      ;Supexec (XBIOS 38)
                trap    #14
                addq.l  #6,SP

                bra.s   ste_stop_sam1
ste_stop_sam0:
                clr.b   sndmactl.w      ;DMA-Sound aus

                rts
ste_stop_sam1:
                movem.l (SP)+,D0-D2/A0-A2

                rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONVERT 8 SAMPLE                                                            ;
;                                                                             ;
; Deklaration in C: VOID cdecl convert8_sam(BYTE *start, LONG length);        ;
;                                                                             ;
; Funktion: Konvertiert ein Sample ab 'start' mit der LÑnge 'length' vom      ;
;           ST-Format ins STE-Format und umgekehrt.                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convert8_sam:
                movea.l SP,A0
                movem.l D0-D2/A1,-(SP)

                move.l  4+4(A0),D0      ;D0: LÑnge (Offset 4)
                movea.l 4+0(A0),A0      ;A0: Startadresse (Offset 0)

                tst.l   D0              ;LÑnge = 0?
                ble.s   convert8_sam3

                move.l  #$80808080,D1   ;D1: Konvertierungs-Long
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Gerade Adresse ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                move.l  A0,D2           ;D2: Sampleadresse
                btst    #0,D2           ;Adresse gerade?
                beq.s   convert8_sam0

                eor.b   D1,(A0)+        ;Byte konvertieren (Bit 7 invertieren)
                subq.l  #1,D0           ;RestlÑnge - 1
convert8_sam0:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Sample konvertieren ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                cmpi.l  #4,D0           ;RestlÑnge < 4?
                blt.s   convert8_sam2

                move.l  D0,D2
                andi.l  #$FFFFFFFC,D2   ;D2: LÑnge der Longs
                lea     0(A0,D2.l),A1   ;A1: Endadresse
convert8_sam1:
                eor.l   D1,(A0)+        ;Long kovertieren
                cmpa.l  A1,A0           ;Ende?
                bcs.s   convert8_sam1

                sub.l   D2,D0           ;RestlÑnge korrigieren
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Bytes ausgleichen ;;;;;;;;;;;;;;;;;;;;;;;;;;;
convert8_sam2:
                tst.l   D0              ;Fertig?
                beq.s   convert8_sam3

                eor.b   D1,(A0)+        ;Byte konvertieren
                subq.l  #1,D0           ;RestlÑnge - 1

                bra.s   convert8_sam2
convert8_sam3:
                movem.l (SP)+,D0-D2/A1

                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONVERT 16 SAMPLE                                                           ;
;                                                                             ;
; Deklaration in C: VOID cdecl convert16_sam(BYTE *start, LONG length);       ;
;                                                                             ;
; Funktion: Konvertiert ein Sample ab 'start' mit der LÑnge 'length' vom      ;
;           ST-Format ins STE-Format und umgekehrt.                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convert16_sam:
                movea.l SP,A0
                movem.l D0-D2/A1,-(SP)

                move.l  4+4(A0),D0      ;D0: LÑnge (Offset 4)
                movea.l 4+0(A0),A0      ;A0: Startadresse (Offset 0)

                tst.l   D0              ;LÑnge = 0?
                ble.s   convert16_sam2

;                move.l  #$80808080,D1   ;D1: Konvertierungs-Long
                move.l  #$80008000,D1   ;D1: Konvertierungs-Long
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Sample konvertieren ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                cmpi.l  #4,D0           ;RestlÑnge < 4?
                blt.s   convert16_sam1

                move.l  D0,D2
                andi.l  #$FFFFFFFC,D2   ;D2: LÑnge der Longs
                lea     0(A0,D2.l),A1   ;A1: Endadresse
convert16_sam0:
                eor.l   D1,(A0)+        ;Long konvertieren
                cmpa.l  A1,A0           ;Ende?
                bcs.s   convert16_sam0

                sub.l   D2,D0           ;RestlÑnge korrigieren
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Words ausgleichen ;;;;;;;;;;;;;;;;;;;;;;;;;;;
                tst.l   D0              ;Fertig?
                beq.s   convert16_sam2
convert16_sam1:
                eor.w   D1,(A0)+        ;Word konvertieren
convert16_sam2:
                movem.l (SP)+,D0-D2/A1

                rts
;
; FIX SAMPLE                                                                  ;
;                                                                             ;
; Deklaration in C: VOID cdecl fix_sam(BYTE ;start, BYTE ;dest, LONG length); ;
;                                                                             ;
; Funktion: Konvertiert ein 16-Bit Sample ab 'start' mit der LÑnge 'length'   ;
;           nach 'dest' zu einem 8-Bit Sample.                                ;
;
fix_sam:
                movea.l SP,A0
                movem.l D0/A0-A2,-(SP)

                movea.l 4+4(A0),A2      ;A2: Ziel-Adresse (Offset 4)
                move.l  4+8(A0),D0      ;D0: LÑnge (Offset 8)
                movea.l 4+0(A0),A0      ;A0: Quell-Start-Adresse (Offset 0)

                lea     0(A0,D0.l),A1   ;A1: Quell-End-Adresse
fix_sam0:
                move.b  (A0)+,(A2)+     ;Byte kopieren
                addq.l  #1,A0           ;Adresse erhîhen

                cmpa.l  A1,A0           ;Ende?
                bcs.s   fix_sam0

                movem.l (SP)+,D0/A0-A2

                rts

                END
