; ***************************************************************
; *  ACCMalloc / ACCMfree: 'dauerhaftes' ACC-Malloc per Trick!  *
; ***************************************************************
; * Autor: Lutz Prežler, Ahornweg 11, 2904 Hatten								*
; ***************************************************************
; * (c) 1992 MAXON Computer GmbH																*
; ***************************************************************

; *****************
; * ACCMalloc: entspr. Malloc; Parameterbergabe anders:
; * IN:     d4.l: amount
; * OUT:    d4.l: maret
; * USES:   d0-d2/a0-a2
; *****************
ACCMalloc:  movem.l   a3-a5,-(sp)  ; Regs retten
            clr.l     -(sp)        ; in Supervisormodus
            move.w    #$20,-(sp)   ; Super
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            move.l    d0,-(sp)     ; alten SSP auf Stack
            bsr       Get_act_pd   ; act_pd -> a4
            movea.l   (a4),a5      ; akt. PD
            move.l    #TextStart-256,(a4)   ; eigener PD
; ** Das Label TextStart muž vor dem ersten Befehl im Text-Segment  **
; ** stehen (evtl. umbenennen). #TextStart-256 ist dann die Adresse **
; ** der eigenen Basepage. N”tig, da bei ACC Basepageadr. nicht auf **
; ** dem Stack liegt.                                               **
            moveq.l   #-1,d0       ; gr”žter
            move.l    d0,-(sp)     ; Speicherblock
            move.w    #$48,-(sp)   ; Malloc
            trap      #1           ; GEMDOS
            sub.l     d4,d0        ; - L„nge
            move.l    d0,2(sp)     ; als Parameter
            trap      #1           ; GEMDOS (Malloc)
            movea.l   d0,a3
            move.l    d4,2(sp)     ; gewnschte L„nge
            trap      #1           ; GEMDOS (Malloc)
            addq.l    #6,sp
            move.l    d0,d4        ; Rckgabewert
            move.l    a3,-(sp)     ; Speicherblock
            move.w    #$49,-(sp)   ; Mfree
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            move.l    a5,(a4)      ; alter PD
            move.w    #$20,-(sp)   ; Super (SSP auf Stack)
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            movem.l   (sp)+,a3-a5  ; Regs zurck
            rts       

; *****************
; * ACCMfree: entspr. Mfree; Parameterbergabe anders:
; * IN:     d4.l: saddr
; * OUT:    d4.l: mfret
; * USES:   d0-d2/a0-a2
; *****************
ACCMfree:   movem.l   a3-a5,-(sp)  ; Regs retten
            clr.l     -(sp)        ; in Supervisormodus
            move.w    #$20,-(sp)   ; Super
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            move.l    d0,-(sp)     ; alten SSP auf Stack
            bsr       Get_act_pd   ; act_pd -> a4
            movea.l   (a4),a5      ; akt. PD
            move.l    #TextStart-256,(a4)   ; eigener PD
;           ( *** siehe ACCMalloc! *** )
            move.l    d4,-(sp)     ; Adresse
            move.w    #$49,-(sp)   ; Mfree
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            move.l    d0,d4        ; Rckgabewert
            move.l    a5,(a4)      ; alter PD
            move.w    #$20,-(sp)   ; Super (SSP auf Stack)
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            movem.l   (sp)+,a3-a5  ; Regs zurck
            rts       

; *****************
; * Get_act_pd
; * IN:     Supervisormodus
; * OUT:    a4: act_pd-Adresse  (a0: sysbase)
; *****************
Get_act_pd: movea.l   $4f2,a0      ; sysbase
            movea.l   #$602c,a4    ; Default-act_pd
            cmpi.w    #$102,2(a0)  ; TOS-Version >= 1.2?
            blt       Get_actpdx   ; nein
            movea.l   40(a0),a4    ; act_pd holen
Get_actpdx: rts       
