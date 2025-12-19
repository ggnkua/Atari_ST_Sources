.EXPORT XFinstat

* Because PureC binding is wrong (MOVE.L D0 instead of MOVE.W D0)
XFinstat:
  PEA.L  (A2)
  MOVE.W D0, -(A7)
  MOVE.W #$105,-(A7)
  TRAP   #1
  ADDQ.W #4,A7
  MOVEA.L (A7)+,A2
  RTS