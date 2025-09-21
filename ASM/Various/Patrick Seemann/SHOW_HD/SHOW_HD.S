;*********************************************************************
; Show-Harddisk
; (Hard-)Disk-L„mpchen per Software
;
; Patrick Seemann, Landstr.122, CH-5430 Wettingen
; FIDO: 2:302/815.29
;
;*********************************************************************

                OUTPUT 'SHOW_HD.PRG'
                OPT F+

_v_bas_ad       EQU $0000044E           ; Adresse des Bildschirmspeichers
hdv_rw          EQU $00000476           ; Vektor auf Drive-Read/Write-Routine

;**************************************
; hier geht's los
start:
                bra.s   install         ; zur Installationsroutine springen

                >PART 'residente Routine'

                DC.L "XBRA"             ; XBRA-Kennung
                DC.L "SHHD"             ; Unsere Kennung (SHow-HardDisk)
                DC.L 0                  ; alter Vektor

our_job:
                movea.l line_a(PC),A0   ; Adresse der LineA-Vars
                move.w  -2(A0),D1       ; Bildschirmbreite (in Bytes)
                movea.l _v_bas_ad.w,A0  ; aktuelle Bildschirmadresse holen
                eori.b  #%01100000,(A0) ; in erster und
                eori.b  #%01100000,0(A0,D1.w) ; zweiter Zeile Bits invertieren

                move.l  (SP)+,return    ; Rcksprungadresse retten
                movea.l our_job-4(PC),A0 ; Adresse der alten Routine
                jsr     (A0)            ; ... und los geht's

                movea.l line_a(PC),A0   ; Basisadresse der LineA-Variablen
                move.w  -2(A0),D1       ; in D0 liegt Errorcode von read/write!!
                movea.l _v_bas_ad.w,A0  ; Bildschirmadresse holen
                eori.b  #%01100000,(A0) ; in erster und
                eori.b  #%01100000,0(A0,D1.w) ; zweiter Zeile Bits invertieren

                movea.l return(PC),A0   ; Rcksprungadresse holen
                jmp     (A0)            ; und springen

return:
                DC.L 0                  ; Zwischenspeichern der Rcksprungadresse
line_a:
                DC.L 0                  ; Basisadresse der LineA-Variablen
; Code bis hier bleibt resident
;**************************************

                ENDPART
install:        >PART 'installation'
                pea     connect(PC)     ; Vektor im Supervisormodus umbiegen
                move.w  #$0026,-(SP)    ; Supexec
                trap    #14             ; XBIOS
                addq.l  #6,SP           ; ...und aufr„umen

                DC.W $A000              ; Adresse der LineA-Vars holen
                move.l  D0,line_a       ; und speichern

                pea     msg(PC)         ; Hinweis ausgeben
                move.w  #9,-(SP)        ; Cconws
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; ...und aufr„umen

                clr.w   -(SP)           ; Rckgabewert 0
                move.l  #install-start+256,-(SP) ; Code resident halten
                move.w  #$0031,-(SP)    ; Ptermres
                trap    #1              ; GEMDOS

connect:
                move.l  hdv_rw.w,our_job-4 ; alte Adresse speichern
                move.l  #our_job,hdv_rw.w ; eigene Routine einh„ngen
                rts                     ; ...und zurck

                ENDPART

                DATA
                >PART 'info'
msg:
                DC.B 13,10
                DC.B " * Show-Harddisk wurde installiert *",13,10
                DC.B " * (C)Patrick Seemann <*> 91-03-25 *",13,10
                DC.B 0
                ENDPART

                END
