; Wrap Mouse
; Mouse-Routinen
;
; (c)1992 by Richard Kurz
; Vogelherdbogen 62
; 7992 Tettnang
; Fido 2:241/7232
;
; FÅr's TOS-Magazin
;
; Erstellt mit Pure Assembler
;

; Wir geben bekannt

export  new_mouse,old_mouse,new_dos,old_dos
export  set_mouse
import  stackcorr,chk_mouse,do_switch,end_switch

;********************************************************************
; die neue Mausroutine!

    dc.b    'XBRA'
    dc.b    'WrAp'
old_mouse:
    dc.l    1
new_mouse:
    movem.l d0-A6,-(SP)
    bsr     chk_mouse;
    movem.l (SP)+,d0-A6
    move.l  old_mouse(PC),-(sp)
    rts

set_mouse:
    move.l  a0,-(sp)
    move.l  old_mouse(PC),a1
    jsr (a1)
    move.l  (sp)+,a0
    rts

;********************************************************************
; Neuer GEMDOS-Trap fÅr switch!

    dc.b 'XBRA' 
    dc.b 'WrAp'
old_dos:            
    dc.l 0     
new_dos:       
    move.l  sp,a0
    add.l   stackcorr(PC),a0
    btst.b  #5,(sp)
    bne.s   dos_do
    move.l  usp,a0
dos_do:
    cmpi.w  #75,(a0)
    bne.s   end_dos
    movem.l d0-a6,-(sp)
    movea.l 4(a0),a0
    bsr do_switch
    tst.w   d0
    beq.s   not_found
    movem.l (sp)+,d0-a6
    move.l  2(sp),dos_return
    move.l  #ende_pexec,2(sp)
    bra.s   end_dos
not_found:  
    movem.l (sp)+,d0-a6
end_dos:
    move.l  old_dos(pc),-(sp)
    rts  

ende_pexec:
    movem.l d0-a6,-(sp)
    bsr end_switch
    movem.l (sp)+,d0-a6
    move.l  dos_return(pc),-(sp)
    rts
    
dos_return:
    dc.l    1
