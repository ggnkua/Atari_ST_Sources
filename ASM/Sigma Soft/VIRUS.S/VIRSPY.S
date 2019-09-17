;
;  VIR_SPY  V 1.4a
;  by  TSE
;  Gerrit Gehnen  
;  (c) 1992 MAXON Computer GmbH
;
; Virus-Spy : Protocols all attempts, to use the Gemdos functions
; FOPEN, FCREATE, PEXEC,SFIRST on the Printer with it.
; With this you can easily establish access to strange files( Infections )
; 
;
; Output:       FOPEN:  Read:   R Filename
;                       Write:  W Filename
;                       Update: U Filename
;               FCREATE:        C Filename
;               PEXEC:          E Filename (only with Load'n Go and Load)
;               SFIRST:         S Filename
;
; Kann durch nochmaligen Aufruf ein- und ausgeschaltet werden.
;
; Versionshistory (whoever's interested):
; 1.0 (March 88): first runnable Version
; 1.1 (April 88): Program shorter and Deactivates subsidiary program
; 1.2    ''     : SFIRST included with.
; 1.3 (3.7.88)  : Sibsidiary program dropped
; 1.4 (17.12.88): XBRA-Protocol
; 1.4a (30.1.89): XBRA-Installation improved and corrected

SUPER

FOPEN     equ $3d
FCREAT    equ $3c
EXEC      equ $4b
SFIRST    equ $4e
P_TERMRES equ $31




DEVICE    equ 0                         ; Device number: 0=Printer,2=Screen

CR        equ 13
LF        equ 10

                text
start:  bra             install
activ_flag:
                dc.w    0                   ; Program's own Flag for
                                            ; Activation function, can be
                                            ; externally manipulated via XBRA 

                dc.b    'XBRA'              ; XBRA-Formalism
                dc.b    '4SPY'
oldvect:ds.l    1


patch:  movea.l sp,a0                       ; Investigate,whether a Call from
                btst    #5,(a0)             ; the Supervisor mode has taken place.
                beq             from_user
                addq.l  #6,a0               ; yes: Add Offset
                bra             is_it_me
from_user:
                move.l  usp,a0

is_it_me:
                cmpi.w  #0,activ_flag       ; Am I allowed at all ?
                bne             exit
                cmpi.w  #FOPEN,(a0)         ; Yes I am !
                beq             los_op      ; Am I then actually meant ?
                cmpi.w  #FCREAT,(a0)
                beq             los_cr
                cmpi.w  #EXEC,(a0)
                beq             los_ex
                cmpi.w  #SFIRST,(a0)
                beq             los_sf
                bra             exit
                
los_ex: cmpi.w  #0,2(a0)                    ; Exec has been called:
                beq             con_ex      ; Ascertain, whether Load'n Go
                cmpi.w  #3,2(a0)            ; or Load gemeint ist
                bne             exit        ; when not, then if all is well nix
con_ex: move.b  #'E',d0                     ; sets Mode character
                movea.l 4(a0),a0            ; and Filenames
                bra             printstat

los_cr: move.b  #'C',d0                     ; Create has been called:
                bra             loscont     ; sets Mode to 'C' and gives
                                            ; further Filenames 

los_sf: move.b  #'S',d0                     ; Sfirst has been called:
                                            ; sets Mode to 'S' and gives
loscont:movea.l 2(a0),a0                    ; further Filenames
                bra             printstat

los_op: move.l  d1,-(sp)                    ; Open has been called:
                move.w  6(a0),d0            ; Ascertain Mode
                movea.l 2(a0),a0            ; Determine Address of the Names
                move.b  #'W',d1             ; Set Mode corresponding
                cmpi.w  #1,d0               ; to the call.
                beq             printd1
                move.b  #'R',d1
                cmpi.w  #0,d0
                beq             printd1
                move.b  #'U',d1

printd1:move.b  d1,d0                       ; Gives the Mode character in d1 
                move.l  (sp)+,d1
printstat:
                bsr             printchar   ; All elaborate also,
                move.b  #' ',d0             ; however, flexible for it...
                bsr             printchar   ; (Hyper-)Space output
                bsr             printstring
exit:   move.l  oldvect,-(sp)               ; .. and already ready
                rts                         ; Return to the Orginal-
                                            ; GEMDOS Routine

printchar:          
                movem.l d0-d2/a0-a2,-(sp)   ; Save Registers
                move.w  d0,-(sp)
                move.w  #DEVICE,-(sp)       ; and exit with it.
                move.w  #3,-(sp)
                trap    #13
                addq.l  #6,sp
                movem.l (sp)+,d0-d2/a0-a2
                rts       

printstring:        
                move.b  (a0)+,d0             ; Gives String,with which \0 quits
                cmpi.b  #0,d0                ; and places it to Address (a0) 
                beq             loopend
                bsr             printchar
                bra             printstring
loopend:move.b  #CR,d0                       ; Only now go in new line
                bsr             printchar    ; yet..
                move.b  #LF,d0
                bsr             printchar
                rts

install:pea.l   supinst                      ;Supermode for Vector access
                move.w  #38,-(sp)
                trap    #14
                addq.l  #6,sp
                move.w  activ_flag,d0         ; if it has already been installed,
                cmpi.w  #0,d0
                beq             not_inst
                clr.w   -(sp)
                trap    #1                    ; then what is already there?


supinst:lea.l   33*4,a1                       ; Fetch content of the Gemdos vectors
                movea.l (a1),a0               ; and test XBRA 
                movea.l a0,a2
find_next:
                cmpi.l  #'4SPY',-8(a2)        ; Am I already there ?
                beq             installed     ; ....unfortunately yes
                cmpi.l  #'XBRA',-12(a2)       ; Is there another XBRA-Program there?
                bne             war_nix
                move.l  -(a2),a2              ; in the chain
                bra             find_next     ; check next Program

war_nix:move.l  (a1),(oldvect)                ; No Vir_spy found !
                move.l  #patch,(a1)
                rts


installed:
                eori.w  #$ffff,-14(a2)        ; Set active flag in the Program
                eori.w  #$ffff,activ_flag     ; Set your Flag
                rts       


not_inst:         
                pea             message       ; Not yet installed !
                move    #9,-(a7)
                trap    #1
                addq.l  #6,a7
                clr.w   -(sp)
                move.l  #install-start+256,-(sp)  ; and make resident !
                move.w  #P_TERMRES,-(sp)      ; Gimmick: Installation program
                trap    #1                    ; has been removed !

                data

message:dc.b 'VIR-SPY 1.4a installed',CR,LF
                dc.b 'by TSE (Gerrit Gehnen)',CR,LF
                dc.b '(c) 1992 MAXON Computer GmbH',0

