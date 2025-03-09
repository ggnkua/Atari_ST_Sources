;------------------------------------------------
; GEMDOS-Patch zur Manipulation von 
; Mxalloc-Aufrufen. Es wird der Parameter "mode"
; ersetzt, so daû bevorzugt alternatives RAM
; vergeben wird.
;
;                      Autor: Klaus Heyne
;                      (c) 1996 by MAXON-Computer
;------------------------------------------------
   GLOBL   install,kill
;------------------------------------------------
; Installation und Deinstallation des Patch
; Aufruf im Supervisor-Modus!
;------------------------------------------------
install:
   move.l  $0084.w,gemdos ; GEMDOS-Vektor retten
   move.l  #newtrap,$0084 ; und neue Routine 
   rts                    ; einklinken.    
        
kill:
   move.l  gemdos,$0084   ; Originalvektor
   rts                    ; zurÅckschreiben
;------------------------------------------------
; GEMDOS-Patch: Mxalloc(ST-RAM)-> Mxalloc(TT-RAM)
;------------------------------------------------
newtrap:           
   btst    #5,(SP)        ; Aufruf im 
   beq     nosuper        ; Supervisor-Modus ?
   lea     8(SP),A0       ; Dann Zeiger auf
   bra     newtrap2       ; Parameter setzen
nosuper:                  ; sonst Userstack-
   move.l  USP,A0         ; pointer holen
newtrap2:       
   move.w  (A0),D0        ; Funktionsnummer
   cmp.w   #$44,D0        ; Mxalloc ?
   bne     nopatch        ; Wenn ja,        
   move.w  #3,6(A0)       ; "mode" ersetzen (*)
nopatch:                
   move.l  gemdos(PC),A0  ; zum GEMDOS...
   jmp     (A0)
;------------------------------------------------
   DATA
;------------------------------------------------
gemdos:    DC.L 0       ; Platz fÅr GEMDOS-Vektor
;------------------------------------------------
; (*)  void  *Mxalloc( long amount, int mode );
;
; Die GEMDOS-Routine Mxalloc reserviert einen
; Speicherbereich der Grîûe amount. Der Parameter
; mode gibt an welche Speicherart angefordert
; werden soll:
;
;   0       ST-RAM
;   1       Alternatives RAM
;   2       egal, ST RAM bevorzugt
;   3       egal, alternatives RAM bevorzugt
;               
;  aus: Pure C - Online-Hilfe     
;------------------------------------------------
