* AUTO program to select medium
* or low resolution screen mode
* By R.A.Waddilove
* (c) Atari St User

  PEA prompt(PC)   Print prompt
  MOVE.W #9,-(A7)
  TRAP #1          BDOS 9
  ADD.L #6,A7      Tidy stack
input
  MOVE.W #8,-(A7)  Wait for key
  TRAP #1          BDOS 8
  ADD.L #2,A7      Tidy stack
  AND.W #$DF,D0    Force upper case
  CMP.W #'L',D0    L pressed?
  BEQ low          Yes
  CMP.W #'M',D0    M pressed?
  BNE input        No - goto input
  MOVE.W #1,-(A7)  Set medium res.
  BRA exit         Skip next bit
low
  MOVE.W #0,-(A7)  Set low res.
exit
  MOVE.L #-1,-(A7) Dummy parameter
  MOVE.L #-1,-(A7) Dummy parameter
  MOVE.W #5,-(A7)
  TRAP #14         XBIOS 5
  ADD.L #12,A7     Tidy stack
  MOVE.W #0,-(A7)  Return to Desktop
  TRAP #1          BDOS 1

prompt
  DC.B "*****************",13,10
  DC.B "*               *",13,10
  DC.B "* Medium or Low *",13,10
  DC.B "*  resolution?  *",13,10
  DC.B "*               *",13,10
  DC.B "* Press  M or L *",13,10
  DC.B "*               *",13,10
  DC.B "*****************",13,10
  DC.B 0
  EVEN
  END
