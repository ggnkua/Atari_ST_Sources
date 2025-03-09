
; alloca() reserviert Platz auf dem Stack    
; Die aufrufende Funktion darf keine Regist- 
; ervariablen verwenden !                      

alloca:  move.l  (a7)+,a0  ; RÅcksprungadr.
         
         move.w  (a7),d0
         suba.l  d0,a7
         
         move.l  a7,d0
         addq.l  #2,d0
         
         jmp     (a0)
         
         

