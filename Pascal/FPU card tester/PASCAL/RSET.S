fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1
_fpset1:  bsr     pascal
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$5480,fpcmd  ; FMOVE fÅr FP1 starten
          move.w  fpstat,d0     ; Status lesen und vergessen
          move.l  d1,fpop       ; Daten in FP1 schreiben
          move.l  d2,fpop
          rts 

        .globl _fpset2
_fpset2:  bsr     pascal
L2:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.w  #$5500,fpcmd  ; FMOVE fÅr FP2 starten
          move.w  fpstat,d0     ; Status lesen und vergessen
          move.l  d1,fpop       ; Daten in FP2 schreiben
          move.l  d2,fpop 
          rts 

pascal:   move.w  d4,d1         ; d4 kopieren nach d1
          and.l   #$000000ff,d1 ; Exponent isolieren
          add.w   #$037e,d1     ; und auf OSS Format bringen (falsche pos.)
          btst    #$1f,d3       ; Vorzeichen testen
          beq.s   pascal_2      ; +
          or.w    #$0800,d1     ; - setzen
pascal_2: and.l   #$0000ff00,d4 ; Exponenten aus Mantisse lîschen
          lsl.w   d4            ; mantisse um 1 Bit nach links
          roxl.l  d3            ; da Vorzeichen bereits erledigt ist
          lsl.w   #4,d1         ; Exponent in OSS Position bringen
          swap    d1
          move.l  d3,d2         ; kopieren oberen Teil der Mantisse
          lsr.l   #8,d3         ; in Position Bringen
          lsr.l   #4,d3         ; da die ersten 12 Bit OSS Exponent
          add.l   d3,d1         ; Mantisse und Exponent vereinen

          lsl.l   #4,d2         ; oberen 2. Teil der Mantisse in Position
          swap    d2            ; bringen
          and.l   #$fff00000,d2 ; und isolieren
          lsl.l   #4,d4         ; untern Teil der Mantisse in Position bringen
          add.l   d4,d2         ; untere Mantisse mit 2. Teil vereinen
          rts                   ; Daten stehen nun in d1-d2
        .end

