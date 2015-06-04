fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpget1          ; globale Definitionen aus fget.s
_fpget1:
L1:       cmp.w   #$0802,fpstat ; warten auf MC68881 bereitschaft
          bne.s   L1
          move.w  #$7480,fpcmd  ; FP1 abhohlen
          move.w  fpstat,d0     ; Status lesen und vergessen
L2:       cmp.w   #$b208,fpstat ; warten auf MC68881 bereitschaft fÅr Funktion
          bne.s   L2
          move.l  fpop,d0       ; dann Werte abhohlen
          move.l  fpop,d1
          bra.s   pascal        ; und auf Pascal Format bringen
          rts

        .globl _fpget2          ; globale Definitionen aus fget.s
_fpget2:
L3:       cmp.w   #$0802,fpstat ; warten auf MC68881 bereitschaft
          bne.s   L3
          move.w  #$7500,fpcmd  ; FP2 abhohlen
          move.w  fpstat,d0     ; Status lesen und vergessen
L4:       cmp.w   #$b208,fpstat ; warten auf MC68881 bereitschaft fÅr Funktion
          bne.s   L4
          move.l  fpop,d0       ; dann Werte abholen
          move.l  fpop,d1
                                ; und auf Pascal Format bringen
pascal:   move.l  d0,d3         ; kopiere d0 -> d2
          move.l  d0,d4         ; auch nach d4 fÅr Vorzeichen
          swap    d3            ; tausche oberen 16 Bit gegen untere
          lsr.w   #4,d3         ; Exponent in Position schieben
          add.w   #$82,d3       ; OSS Exp = (DRI exp + #$82) & #$ff
          and.w   #$00ff,d3
          and.l   #$000fffff,d0 ; Exponent lîschen
          lsr.l   d0            ; Auf Pascal Mantisse bringen
          roxr.l  d1 
          move.l  d1,d2         ; untere Mantisse nach d2
          and.l   #$000ff000,d2 ; untere Mantisse isolieren
          lsr.l   #4,d2         ; und in position bringen
          add.w   d2,d3         ; mit exponenten vereinen
          move.l  d0,d2         ; obere Mantisse nach d2
          lsl.l   #8,d2         ; 12 bit nach links schieben
          lsl.l   #4,d2
          and.l   #$fff00000,d1 ; reset der oberen Mantisse isolieren
          lsr.l   #4,d1         ; 20 bit nach rechts schieben
          swap    d1
          add.l   d1,d2         ; obere Mantisse vereinen
          btst.l  #$1f,d4       ; Vorzeichentest
          beq.s   pascal_2      ; jetzt noch das Vorheichen
          or.l    #$80000000,d2 ; Minus setzen
pascal_2: move.l  d2,d0         ; real Wert OSS zur verfÅgung stellen
          move.w  d3,d1 
          rts

        .end
