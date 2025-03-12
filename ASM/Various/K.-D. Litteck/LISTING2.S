; OBJECT.O
; Unterprogramm fÅr GFA-Bas-sembler 
; mit GFA-Assembler 1.5
; K.-D. Litteck  Juni 1991

 
; Labels als global deklarieren
  .GLOBL write
  .GLOBL read


  .TEXT 


;Unterroutine write 
write:         

; Testwert vom Stack holen
  move.l   4(sp),d0  
; Anzahl der Longwords vom Stack
  move.l   8(sp),d1 
; Startadresse vom Stack
  movea.l  12(sp),a0  


long_t: 
; Testwert in Speicher
  move.l  d0,(a0)+
; ZÑhler dekrementieren
  subq.l  #1,d1
; Ist ZÑhler 0 ?
  bne.s   long_t

; RÅcksprung zum Basic-Programm
  rts        



; Unterroutine read 


read:          

;adresse von fehler%
  movea.l 4(sp),a1 
  move.l  8(sp),d0  ;testwert%
  move.l  12(sp),d1 ;anz%
  movea.l 16(sp),a0 ;adr%

; d5 als FehlerzÑhler lîschen
  moveq.l #0,d5   

long:
  cmp.l   (a0)+,d0  ; Vergleich
; Bei Fehler kein Sprung
  beq.s   weiter

  addq.l  #1,d5     ; Fehler erhîhen

weiter:
  subq.l  #1,d1     ; ZÑhler dekrement
  bne.s   long      ; ZÑhler 0 ?
  

; Wert des FehlerzÑhlers zurÅck
; in die Basic-Variable fehler%
  move.l  d5,(a1)


  rts        

; Falls im GFA-Basic Programm noch
; mehr Assembler-Routinen verwendet
; werden, so mÅûen diese hier folgen,
; da der GFA-Basic Linker nur eine
; Objectdatei verarbeiten kann.


  .END 

