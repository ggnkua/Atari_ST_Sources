;*************************************************************************
;** XBios-Erweiterung zur Verwaltung des 'Blitters'
;**
;**        1990 Friedel van Megen
;**
;**        (c) MAXON Computer  
;*************************************************************************

gemdos   equ   1
Cconws   equ   9  ;schreibe String
Cnecin   equ   8  ;Con in without echo
Ptermres equ   49 ;Terminate but stay resident
Malloc   equ   72 ;Etwas Speicher braucht der Comp...
Mfree equ   73

xbios equ   14
Supexec  equ   38 ;exec in Supervisormode
Physbase equ   2
Setscreen   equ   5
Blitmode equ   64 ;das wird sich Ñndern...

v_trp14  equ   $b8   ;Trap #14 Vektor

p_start  pea   copy_msg
   move.w   #Cconws,-(sp)
   trap  #gemdos
   addq.l   #6,sp 
   pea   inst_vec       ;nur noch Vektoren patchen
   move.w   #Supexec,-(sp)
   trap  #xbios
   addq.l   #6,sp
   move.w   #0,-(sp)       ;wir bleiben resident !
   move.l   #$100+p_end-p_start,-(sp)
   move.w   #Ptermres,-(sp)
   trap  #gemdos        ;Das war's.....


;********************************************************************
;** patch as patch can...
;********************************************************************
inst_vec move.l   v_trp14,sv_trp14  ;Trap #14 Vektor patchen
   move.l   #new_trp14,v_trp14
   rts

;********************************************************************
;** neuer TRAP #14 handler, XBRA-tauglich, Kennung 'PBIT'
;********************************************************************
   dc.l  'XBRA'
   dc.l  'PBIT'
sv_trp14 dc.l  0     ;savearea fÅr trap #14 vektor
new_trp14   move.l   a7,a0    ;welchen Stackpointer soll ich benutzen
   addq.l   #6,a0
   move.w   (sp),d1
   btst  #13,d1
   bne.s in_supm     ;ok, Supervisor
   move.l   usp,a0      ;Aufruf aus USER-Mode
in_supm  move.w   (a0)+,d0    ;Funktionscode
   cmp.w #Blitmode,d0   ;Soll ich was machen ??
   beq.s is_Xsw      ;JA ->
   move.l   sv_trp14,a0
   jmp   (a0)     ;dann eben nicht....
is_Xsw   move.w   mode,-(sp)  ;alter Modus des Blitters
   move.w   (a0)+,d0
   bmi.s end_xs1     ;Nur den Status holen...
   btst  #0,d0
   bne.s ein_sch     ;Blitter einschalten ->
   and.w #254,mode      ;'Blitter' ausschalten
   bra.s end_xs1
ein_sch  or.w  #1,mode     ;'Blitter' einschalten
   lea   sv_regs(pc),a0
   movem.l  a1-a7/d0-d7,-(a0)
   lea   stack_p,sp
   move.l   a0,-(sp)
   bsr   do_it    ;and now do some work...
end_ein  move.l   (sp)+,a0
   movem.l  (a0)+,a1-a7/d0-d7
end_xs1  clr.l d0
   move.w   (sp)+,d0
   rte

;********************************************************************
;** ein Beispiel DO_IT
;********************************************************************
do_it move.l   #32258,-(sp)   ;ein bisschen Speicher raffen...
   move.w   #Malloc,-(sp)
   trap  #gemdos
   lea   6(sp),sp
   tst.l d0
   beq   end_d_i     ;das ging daneben
   move.l   d0,-(sp)    ;schon mal was fÅr Mfree hinterlegen
   add.l #256,d0
   andi.l   #$ffffff00,d0
   move.l   d0,a6
   move.w   #Physbase,-(sp)
   trap  #xbios
   addq.l   #2,sp
   move.l   d0,sv_screen   ;Bildschirmadresse  zwischenspeichern
   move.w   #-1,-(sp)
   move.l   a6,-(sp)
   move.l   #-1,-(sp)
   move.w   #Setscreen,-(sp)  ;und neue setzen
   trap  #xbios
   lea   12(sp),sp
   or.w  #$700,sr
do_loop2 moveq.l  #4,d0
do_loop3 move.l   #-1,-4(a6,d0.l)   ;ein bischen die Zeit vertreiben...
   clr.l 0(a6,d0.l)
   addq.l   #4,d0
   cmp.w #32000,d0
   bne.s do_loop3
   move.l   #-1,-4(a6,d0.l)
   btst.b   #7,$fffc00  ;Tastatur ACIA
   beq.s do_loop2    ;immer noch keine Taste gedrÅckt ?
   move.b   $ffc02,d0
   and.w #$2300,sr
   move.w   #-1,-(sp)
   move.l   sv_screen,-(sp)
   move.l   #-1,-(sp)
   move.w   #Setscreen,-(sp)
   trap  #xbios      ;alten Bildschirm wieder herstellen
   lea   12(sp),sp
   move.w   #Mfree,-(sp)   ;der Rest liegt noch auf dem Stack
   trap  #gemdos
   addq.l   #6,sp
end_d_i  rts

;********************************************************************
;** DATA
;********************************************************************
mode  dc.w  3  ;Blitter ist da, und eingeschaltet
sv_screen   dc.l  0
sv_base  dc.l  0
   ds.l  18
sv_regs  ds.w  128
stack_p  ds.w  0
copy_msg dc.b  "Blitter-Sleeper V1.0",10,13
   dc.b  "(C) 1990 Friedel van Megen",13,10,0
p_end ds.w  1
   end


