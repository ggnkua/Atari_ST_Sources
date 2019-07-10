start:
         pea      install(pc)      ; superexec to set int vector
         move.w   #38,-(a7)        ; and initialize midi ACIA
         trap     #14
         addq.l   #6,a7
         clr.w    -(a7)
         move.l   #$400,-(a7)      ; reserve space, keep process
         move.w   #$31,-(a7)
         trap     #1               ; done
install:
         pea      handler(pc)
         move.l   (a7)+,$118       ; pointer keyboard/midi intrpt
         move.b   #3,$fffffc04     ; master reset midi acia
         move.b   #$96,$fffffc04   ; set for /64, 8bit, 1 s, no parity
         rts
handler: 
         movem.l  d0-d7/a0-a6,-(sp); save registers
         lea      $0,a5            ; clear a5 ( base page pointer )
more:    jsr      midisrv
         move.l   $dec(a5),a2      ; get keyboard addr
         jsr      (a2)             ; service keyboard
         btst     #4,$fffffa01     ; still interrupt
         beq.s    more             ; yes
         bclr     #6,$fffffa11     ; clear int service bit
         movem.l  (sp)+,d0-d7/a0-a6
         rte
midisrv: move.b   d0,-(sp)
         move.l   $de8(a5),a2      ; get midi addr
         jsr      (a2)             ; service midi
         move.b   (sp)+,d3         ; see if we got something
         cmp.b    d0,d3            ; kludge to check for input
         bne.s    doit
         rts
doit:    andi.l   #$ff,d0
         move.l   d0,d3
         cmp.b    #$55,d0          ; ignore codes below $56
         bls      done
         cmp.b    #$8d,d0          ; prevent alt insert
         bne.s    noinsr           ; to avoid crashing!
         btst     #3,$e1b          ; is it alt?
         beq      lookup           ; nope
         bra      done             ; yes, toss it
noinsr:  cmp.b    #$b4,d0          ; is it metronome?
         bne.s    norept
         move.l   oldkey,d0        ; repeat last key
         bra      almost
norept:  cmp.b    #$bf,d3          ; is it tilde - modify keyboard
         bne.s    notilde
         move.w   #$01,d0          ; make it esc
         bra      almost
notilde: cmp.b    #$c9,d3          ; is it <>
         bne.s    nogtlt
         move.w   #$29,d0          ; make it tilde
         bra      almost
nogtlt:  cmp.b    #$bc,d3          ; is it backsp
         bne.s    notdel
         btst     #0,$e1b          ; is it shifted
         bne.s    notdel
         move.w   #$53,d0          ; make it del
         bra      almost
notdel:  cmp.b    #$ad,d3          ; handle shift codes
         bmi      lookup
         cmp.b    #$bb,d3
         bpl      lookup           ; nope
         move.b   $e1b,d2          ; get shift mask
         cmp.b    #$af,d3          ; is it shift
         bpl.s    arnd1
         eori.b   #3,d2            ; toggle shift bits
         bra.s    arnd5
arnd1:   cmp.b    #$b0,d3
         bpl.s    arnd2
         bchg     #2,d2            ; toggle ctrl bit
         bra.s    arnd5
arnd2:   cmp.b    #$b1,d3
         bpl.s    arnd3
         bchg     #4,d2            ; toggle caps lock bit
         bra.s    arnd5
arnd3:   cmp.b    #$b2,d3
         bpl.s    arnd4
         bset     #3,d2            ; set alt bit
         bra.s    arnd5
arnd4:   cmp.b    #$b4,d3          ; all ups
         bpl.s    arnd5
         andi.b   #$f0,d2          ; clear shift,ctrl, and alt bits
arnd5:   move.b   d2,$e1b          ; save new shift status
         bra.s    done
lookup:  lea      table(pc),a0     ; convert dec to st scan code
         sub.w    #$56,d3
         and.l    #$ff,d3
         asl.l    #1,d3
         adda.l   d3,a0
         move.w   (a0),d0
almost:  move.l   #$db0,a0         ; point to kbd iorec addr
         lea      $0,a5
         move.l   d0,oldkey
         jsr      $fc2aa6          ; get scan code in buffer
         bclr     #3,$e1b          ; clear alt shift
done:    rts
table:   dc.w     $3b,$3c,$3d,$3e,$3f,0,0,0,0,0,0,0,0,0 ; function keys
         dc.w     $40,$41,$42,$43,$44,0,0,0,0,0,0,0,0
         dc.w     $54,$55,$56,$57,0,0,0,0,0,0,0   ; shifted funct keys
         dc.w     $58,$59,0,0,$5a,$5b,$5c,$5d,0,0,0,0,0,0
         dc.w     $62,$0e,$61,$52,$0e,$47,0,0     ; keys abv cursor pad
         dc.w     $70,0,$71,$72,$6d,$6e,$6f,$6a   ; numeric keypad
         dc.w     $6b,$6c,$4e,$67,$68,$69,$4a
         dc.w     $63,$64,$65,$66,0,0             ; pf keys
         dc.w     $4b,$4d,$50,$48                 ; cursor keys
         dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         dc.w     $0e,$1c,$0f,$29,$02,$10,$1e,$2c,0 ; main keyboard
         dc.w     $03,$11,$1f,$2d,0,0,$04,$12,$20,$2e
         dc.w     0,$05,$13,$21,$2f,$39,0,$06,$14,$22,$30
         dc.w     0,$07,$15,$23,$31,0,$08,$16,$24,$32,0
         dc.w     $09,$17,$25,$33,0,$0a,$18,$26,$34,0
         dc.w     $0b,$19,0,$27,$35,0,$0d,$1b,$2b,0
         dc.w     $0c,$1a,$28,0,0,0
oldkey:  dc.l     0
         end

