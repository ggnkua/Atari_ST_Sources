;***********************
;****    MK FADE    ****
;***********************
;a0=@src palette
;a1=@dest palette
;a2=@storage for 33 palettes (33*16*2 bytes)
;KILLS d0-d7,a0-a4

;Converts STe colors to normal mode and vice versa
;IN   \1.w=STe color
;     \2.w=$777
;OUT  \1.w=normal color
STECOLOR2NORMAL MACRO
  and.w     \1,\2     ;\2= 0r1r2r3 0g1g2g3 0b1b2b3
  sub.w     \2,\1     ;\1=r4 0 0 0g4 0 0 0b4 0 0 0
  lsr.w     #3,\1
  add.w     \2,\2
  add.w     \2,\1     ;\1=r1r2r3r4g1g2g3g4b1b2b3b4
 ENDM

;IN   \1.w=normal color
;     \2.w=$eee
;OUT  \1.w=STe color
NORMAL2STECOLOR MACRO
  and.w     \1,\2     ;\2=r1r2r3 0g1g2g3 0b1b2b3 0
  sub.w     \2,\1     ;\1= 0 0 0 r4 0 0 0g4 0 0 0b4
  lsl.w     #3,\1
  lsr.w     #1,\2
  add.w     \2,\1     ;\1=r4r1r2r3g4g1g2g3b4b1b2b3
 ENDM

;IN   \1.w=color in normal mode
;OUT  \1.l=RED<<16
;     \2.l=GREEN<<16
;     \3.l=BLUE<<16
SEPARATECOMPONENTS MACRO
  moveq.l   #$f,\3
  and.l     \1,\3     ;\3=B
  swap.w    \3        ;\3=B<<16
  lsr.w     #4,\1
  moveq.l   #$f,\2
  and.l     \1,\2     ;\2=G
  swap.w    \2        ;\2=G<<16
  lsr.w     #4,\1     ;\1=R
  swap.w    \1
  clr.w     \1        ;\1=R<<16
 ENDM
  
;a0=@src palette
;a1=@dest palette
;a2=@storage for 33 palettes (33*16*2 bytes)
;KILLS d0-d7,a0-a4
MKFADE
  moveq.l   #15,d7    
MkFadeOneColor
  move.w    (a0)+,d0
  move.w    (a1)+,d3
  move.w    d0,(a2)
;convert STe colors to normal format then separate RGB components
  move.w    #$777,d1      
  move.w    d1,d4
  STECOLOR2NORMAL d0,d1
  STECOLOR2NORMAL d3,d4
  SEPARATECOMPONENTS d0,d1,d2 ;d0=R<<16, d1=G<<16, d2=B<<16
  SEPARATECOMPONENTS d3,d4,d5 ;d3=R<<16, d4=G<<16, d5=B<<16
;compute dest-src
  sub.l     d0,d3     ;d3=dR<<16
  sub.l     d1,d4     ;d4=dG<<16
  sub.l     d2,d5     ;d5=dB<<16
  asr.l     #5,d3
  move.l    d3,a3     ;a3=dR<<11
  asr.l     #5,d4
  move.l    d4,a4     ;a4=dG<<11
  asr.l     #5,d5     ;d5=dB<<11
  moveq.l   #31,d6
MkFadeOneStep  
  add.l     a3,d0     ;R+=dR
  add.l     a4,d1     ;G+=dG
  add.l     d5,d2     ;B+=dB
  move.l    d0,d3
  swap.w    d3
  lsl.w     #4,d3
  swap.w    d1
  add.w     d1,d3
  swap.w    d1
  lsl.w     #4,d3
  swap.w    d2
  add.w     d2,d3     ;d3=RGB, normal format
  swap.w    d2
  move.w    #$eee,d4
  NORMAL2STECOLOR d3,d4
  add.w     #16*2,a2
  move.w    d3,(a2)
  dbra d6,MkFadeOneStep
  sub.w     #32*16*2-2,a2
  dbra d7,MkFadeOneColor
  rts
 