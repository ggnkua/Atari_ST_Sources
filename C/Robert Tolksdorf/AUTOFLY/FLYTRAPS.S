;  flytrap.s
;
;  by Robert Tolksdorf
;  (c) 1991 MAXON Computer
;
;  Routinen, mit denen AUTOFLY in GEM eingebunden wird.
;  TRAP #2 leitet die AES-Aufrufe form_do und form_dial ggfs.
;  auf unsere Funktionen um.
;  TRAP #1 installiert TRAP #2, falls wegen AUTO-Start noetig
;  und prueft, ob ein Pterm, Pterm0 oder Ptermres stattfindet.
;  TRAP #13 korrigiert TRAP #2 bei einem Pterm, Pterm0 oder
;  Ptermres.
;
         IMPORT   my_fm_dial, my_fm_do, rom_start
         IMPORT   stackcorr, geminstalled, callcount
         IMPORT   firstformdo, restorevalid
         EXPORT   XB_VEC2, my_gem_handler, XB_VEC13, aes_save
         EXPORT   my_bios_handler, XB_VEC1, my_gemdos_handler
         EXPORT   my_exec_os, XB_VECEX
         EXPORT   restore_vec, first_restore, normal_restore
         EXPORT   vq_aes
         TEXT

; die Trap #2 Adresse
GEMTRAP        =  $88

/* Kommt mit unveraendertem D0 zurueck, wenn AES noch nicht
   initialisiert ist. Ansonsten enth„lt D0.W eine 0. */
vq_aes:
         MOVE.W   #$C9,D0
         TRAP  #2
         RTS

; XBRA-Kopf
XB_MAGIC2:  DC.L  "XBRARTAF"
XB_VEC2: DC.L  0

; jeder AES/VDI-Call landet hier
my_gem_handler:
         CMPI.B   #$C8,D0           ; ist es ein AES-Call
         BNE      standard_call     ; nein -> normal weiter
         
do_aes_call:         
         MOVE.L   A0,-(A7)       ; A0 sichern
         MOVE.L   A1,-(A7)       ; A1 sichern
         MOVEA.L  D1,A0          ; AES-Parmblock-Adr holen
         MOVEA.L  (A0),A1           ; Control-Adresse holen
         CMPI.W   #50, (A1)         ; form_do Call ?
         BEQ      a_form_do         ; ja -> zu unserer Routine

         CMPI.W   #51,(A1)       ; form_dial Call ?
         BNE      continue_standard ; nein -> zum normalen GEM-Call  

         MOVEA.L  8(A0),A1       ; IntIn-Adress holen
         CMPI.W   #1, (A1)       ; FMD_GROW ?
         BEQ      continue_standard
         CMPI.W   #2, (A1)       ; FMD_SHRINK ?
         BNE      a_form_dial

continue_standard:
         MOVE.L   (A7)+,A1
         MOVE.L   (A7)+,A0
         
standard_call:
         MOVE.L   XB_VEC2(PC),-(A7) ; zum normalen GEM-Vektor
         RTS

a_form_dial:
         TST.W (A1)           ; FMD_START=0 !
         BNE      fmd_finish
         TST.W callcount
         BMI      call_it           ; bei -1 ausfhren
         ADDQ.W   #1,callcount      ; sonst vermerken
         BRA      continue_standard

fmd_finish:
         TST.W callcount
         BEQ      test_restore      ; bei 0 ausfhren
         BMI      continue_standard ; bei -1 weiter
         SUBQ.W   #1,callcount      ; sonst vermerken
         BRA      continue_standard

test_restore:
         SUBQ.W   #1,callcount
         TST.W restorevalid      ; bei 0 zur normalen
         BEQ      continue_standard ; Routine
         
call_it:
         MOVE.L   A7,A0
         MOVE.L   #my_sstack-4,A7
         MOVE.L   A0,-(A7)       ; auf unseren Stack
         MOVE.L   USP,A0
         MOVE.L   A0,-(A7)       ; auf unseren Stack
         MOVE.L   #my_ustack-4,A0
         MOVE.L   A0,USP
         
;  Parameter nach TC-Konvention aus IntIn kopieren
         MOVEM.L  D1-D7/A2-A6,-(A7)
         MOVE.W   (A1),D0           ; flag
         BSR      my_fm_dial        ; unser form_dial
         MOVEM.L (A7)+,D1-D7/A2-A6
         BRA      return            ; fertig

a_form_do:
         TST.W callcount         ; nur bei 0
         BNE      continue_standard

         MOVEA.L  16(A0), A1        ; *tree holen
         MOVEA.L  (A1),A1
         TST.W firstformdo       ; erstes form_do nach FMD_START ?
         BNE      do_it          ; bei !=0 erstes Mal
         
test_tree:
         CMPA.L   formtree(PC),A1      ; gleiches *tree
         BNE      continue_standard ; nein -> nicht fliegen
         
do_it:
         MOVE.L   A1, formtree      ; *tree speichern
         CLR.W firstformdo
         MOVE.L   A0, temp_save
         MOVE.L   A7,A0
         MOVE.L   #my_sstack-4,A7
         MOVE.L   A0,-(A7)       ; auf unseren Stack
         MOVE.L   USP,A0
         MOVE.L   A0,-(A7)       ; auf unseren Stack
         MOVE.L   #my_ustack-4,A0
         MOVE.L   A0,USP
         MOVE.L   temp_save(PC),A0
         
         MOVEM.L  D1-D7/A2-A6,-(A7)
;  Parameter nach TC-Konvention aus IntIn und AddrIn kopieren
         MOVEA.L  8(A0),A1       ; IntIn-Adress holen
         MOVE.W   (A1),D0           ; start_fld
         MOVEA.L  16(A0),A1         ; AddrIn-adress holen
         MOVE.L   (A1),A0           ; *tree

dontstore:
         BSR      my_fm_do       ; unser form_do
         MOVEM.L  (A7)+,D1-D7/A2-A6

return:
         MOVE.L   D1,A0          ; AES-Parmblock-Adr holen
         MOVE.L   12(A0),A0         ; IntOut-Adress holen
         MOVE.W   D0,(A0)           ; Ergebnis ablegen
         
         MOVE.L   (A7)+,A0       ; alter USP (von unserem Stack)
         MOVE.L   A0,USP
         MOVE.L   (A7)+,A7       ; alter SSP (von unserem Stack)
         
         MOVE.L   (A7)+,A1       ; vom normalen Stack
         MOVE.L   (A7)+,A0
         RTE                     ; und fertig !
         
; XBRA-Kopf
XB_MAGICEX: DC.L  "XBRARTAF"
XB_VECEX:   DC.L  0

my_exec_os:
         MOVE.W   #1,geminstalled      ; AES ist jetzt da
         MOVE.L   XB_VECEX(PC),-(A7)   ; weiter
         RTS

; XBRA-Kopf
XB_MAGIC1:  DC.L  "XBRARTAF"
XB_VEC1: DC.L  0

my_gemdos_handler:
         MOVE.L   A0, temp_save     ; A0 sichern
         MOVE.L   A7,A0
         ADD.L stackcorr(PC),A0
         BTST.B   #5,(A7)           ; supervisor?
         BNE      called_in_super
         MOVE.L   USP, A0

called_in_super:
; stackcorr
         TST.W (A0)           ; PTERM0 (#0) ??
         BEQ      save_gemtrap      ; ja -> sichern
         CMPI.W   #76,(A0)       ; PTERM ??
         BEQ      save_gemtrap      ; ja -> sichern
         CMPI.W   #49,(A0)       ; PTERMRES ??
         BNE      do_gemdos         ; auch nicht -> weiter

save_gemtrap:
         MOVE.L   GEMTRAP, aes_save ; TRAP #2 sichern
         MOVE.W   #-1,callcount     ; anderes Programm !

do_gemdos:
         MOVE.L   temp_save(PC),A0  ; A0 restaurieren
         MOVE.L   XB_VEC1(PC),-(A7)
         RTS

; XBRA-Kopf
XB_MAGIC13: DC.L  "XBRARTAF"
XB_VEC13:   DC.L  0

; jeder Bios-Call landet hier
my_bios_handler:
         BTST.B   #5,(A7)
         BEQ      do_bios           ; nur Superaufrufe interessant

         MOVE.L   A0,temp_save      ; A0 sichern
         MOVE.L   A7,A0
         ADD.L stackcorr(PC),A0
         
         CMPI.L   #$00050101,(A0)      ; Setexc(101,...) ?
         BNE      cont_bios         ; anderer Vektor

         MOVE.L   4(A0),A0       ; neuer Vektor in's ROM ?
         CMPA.L   rom_start(PC),A0
         BLT      cont_bios         ; nicht ins ROM

         MOVE.L   2(SP),return_sav  ; trap-return Adresse sichern
         MOVE.L   restore_vec(PC),2(SP)   ; unseren Restore einmogeln

cont_bios:
         MOVE.L   temp_save(PC),A0  ; A0 restaurieren
         
do_bios:
         MOVE.L   XB_VEC13(PC),-(A7)   ; zum alten Bios-Vektor
         RTS

aes_save:      DS.L  1
return_sav:    DS.L  1
temp_save:     DS.L  1
restore_vec:   DS.L  1
formtree:      DS.L  1

first_restore:
         TST.W geminstalled      ; AES installiert ?
         BEQ      cont           ; nein -> weiter

         MOVE.L   GEMTRAP, XB_VEC2  ; ja -> AUTOFLY installieren
         MOVE.L   #my_gem_handler, aes_save
         MOVE.L   #normal_restore, restore_vec  ; restore „ndern
         
normal_restore:
         MOVE.L   aes_save(PC), GEMTRAP   ; TRAP #2 sichern
cont:
         MOVE.L   return_sav(PC), -(A7)   ; weiter
         RTS

         BSS
         DS.L  512
my_sstack:
         DS.L  512
my_ustack:

         END


