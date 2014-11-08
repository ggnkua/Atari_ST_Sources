
;*** Vorzeichen tauschen ***
.globl _swtchsign
_swtchsign:
      move.l   4(sp),a0
      move.l   8(sp),a1
      cmpi.w   #2,12(sp)      ; 16-Bit ?
      bne      eightbit
      move.l   #$80008000,d0  ; Bei 16-Bit nur jedes 2. Byte „ndern
      bra      swtchthem
eightbit:
      move.l   #$80808080,d0
swtchthem:
      eor.l    d0,(a0)+
      cmpa.l   a0,a1
      bhs      swtchthem
      rts
