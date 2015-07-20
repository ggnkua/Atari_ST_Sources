Semi-commented XBIOS DSP disassembly v0.1

Steve Tattersall (tat/avena) 1997

This should be used in conjunction with my article in Maggie 24.

It contains  a  partially-commented  disassembly  of  all  XBIOS calls
dealing with  the  DSP  and  shows  how  the  professionals  used  the
hardware. It will be more extensively commented in future editions.



TOS 4.04 English


 TEXT
Begin:

XBIOS 96: DoBlock
E05114   Lab00:MOVEA.L   4(A7),A0
E05118         MOVE.L    8(A7),D0
E0511C         MOVEA.L   12(A7),A1
E05120         MOVE.L    16(A7),D1
E05124         TST.L     D0
E05126         BEQ       Lab03
E0512A         SUBQ.W    #1,D0
E0512C   Lab01:BTST      #1,$FFFFA202.W
E05132         BEQ.S     Lab01
E05134   Lab02:MOVE.B    (A0)+,$FFFFA205.W
E05138         MOVE.B    (A0)+,$FFFFA206.W
E0513C         MOVE.B    (A0)+,$FFFFA207.W
E05140         DBF       D0,Lab02
E05144   Lab03:TST.L     D1
E05146         BEQ       Lab06
E0514A         SUBQ.W    #1,D1
E0514C   Lab04:BTST      #0,$FFFFA202.W
E05152         BEQ.S     Lab04
E05154   Lab05:MOVE.B    $FFFFA205.W,(A1)+
E05158         MOVE.B    $FFFFA206.W,(A1)+
E0515C         MOVE.B    $FFFFA207.W,(A1)+
E05160         DBF       D1,Lab05
E05164   Lab06:RTS

XBIOS 97: BLkHandshake

E05166   Lab07:MOVEA.L   4(A7),A0
E0516A         MOVE.L    8(A7),D0
E0516E         MOVEA.L   12(A7),A1
E05172         MOVE.L    16(A7),D1
E05176         TST.L     D0
E05178         BEQ       Lab09
E0517C         SUBQ.W    #1,D0
E0517E   Lab08:BTST      #1,$FFFFA202.W
E05184         BEQ.S     Lab08
E05186         MOVE.B    (A0)+,$FFFFA205.W
E0518A         MOVE.B    (A0)+,$FFFFA206.W
E0518E         MOVE.B    (A0)+,$FFFFA207.W
E05192         DBF       D0,Lab08
E05196   Lab09:TST.L     D1
E05198         BEQ       Lab0B
E0519C         SUBQ.W    #1,D1
E0519E   Lab0A:BTST      #0,$FFFFA202.W
E051A4         BEQ.S     Lab0A
E051A6         MOVE.B    $FFFFA205.W,(A1)+
E051AA         MOVE.B    $FFFFA206.W,(A1)+
E051AE         MOVE.B    $FFFFA207.W,(A1)+
E051B2         DBF       D1,Lab0A
E051B6   Lab0B:RTS

XBIOS 98: BLkUnpacked

E051B8         MOVEA.L   4(A7),A0
E051BC         MOVE.L    8(A7),D0
E051C0         MOVEA.L   12(A7),A1
E051C4         MOVE.L    16(A7),D1
E051C8         TST.L     D0
E051CA         BEQ       Lab0E
E051CE         SUBQ.W    #1,D0
E051D0   Lab0C:BTST      #1,$FFFFA202.W
E051D6         BEQ.S     Lab0C
E051D8   Lab0D:MOVE.L    (A0)+,$FFFFA204.W
E051DC         DBF       D0,Lab0D
E051E0   Lab0E:TST.L     D1
E051E2         BEQ       Lab11
E051E6         SUBQ.W    #1,D1
E051E8   Lab0F:BTST      #0,$FFFFA202.W
E051EE         BEQ.S     Lab0F
E051F0   Lab10:MOVE.L    $FFFFA204.W,(A1)+
E051F4         DBF       D1,Lab10
E051F8   Lab11:RTS

XBIOS 123: BLkWords

E051FA         MOVEA.L   4(A7),A0
E051FE         MOVE.L    8(A7),D0
E05202         MOVEA.L   12(A7),A1
E05206         MOVE.L    16(A7),D1
E0520A         TST.L     D0
E0520C         BEQ       Lab14
E05210         SUBQ.W    #1,D0
E05212   Lab12:BTST      #1,$FFFFA202.W
E05218         BEQ.S     Lab12
E0521A   Lab13:MOVE.W    (A0)+,D2
E0521C         EXT.L     D2
E0521E         MOVE.L    D2,$FFFFA204.W
E05222         DBF       D0,Lab13
E05226   Lab14:TST.L     D1
E05228         BEQ       Lab17
E0522C         SUBQ.W    #1,D1
E0522E   Lab15:BTST      #0,$FFFFA202.W
E05234         BEQ.S     Lab15
E05236   Lab16:MOVE.B    $FFFFA206.W,(A1)+
E0523A         MOVE.B    $FFFFA207.W,(A1)+
E0523E         DBF       D1,Lab16
E05242   Lab17:RTS

XBIOS 124: BlkBytes

E05244         MOVEA.L   4(A7),A0
E05248         MOVE.L    8(A7),D0
E0524C         MOVEA.L   12(A7),A1
E05250         MOVE.L    16(A7),D1
E05254         TST.L     D0
E05256         BEQ       32(PC)               Lab1A
E0525A         SUBQ.W    #1,D0
E0525C   Lab18:BTST      #1,$FFFFA202.W
E05262         BEQ.S     -8(PC)               Lab18
E05264   Lab19:MOVE.B    #0,$FFFFA205.W
E0526A         MOVE.B    #0,$FFFFA206.W
E05270         MOVE.B    (A0)+,$FFFFA207.W
E05274         DBF       D0,Lab19
E05278   Lab1A:TST.L     D1
E0527A         BEQ       24(PC)               Lab1D
E0527E         SUBQ.W    #1,D1
E05280   Lab1B:BTST      #0,$FFFFA202.W
E05286         BEQ.S     -8(PC)               Lab1B
E05288   Lab1C:MOVE.B    $FFFFA206.W,D2
E0528C         MOVE.B    $FFFFA207.W,(A1)+
E05290         DBF       D1,Lab1C
E05294   Lab1D:RTS

XBIOS 101: IOStream

E05296         MOVE.L    4(A7),$16F8.L
E0529E         MOVE.L    8(A7),$16FC.L
E052A6         MOVE.L    12(A7),$1700.L
E052AE         MOVE.L    16(A7),$1704.L
E052B6         MOVE.L    20(A7),$1708.L
E052BE         MOVE.L    24(A7),$1710.L
E052C6         MOVEA.L   $1710.L,A0
E052CC         MOVE.L    #0,(A0)
E052D2         MOVE.L    $1700.L,D0
E052D8         SUBQ.W    #1,D0
E052DA         MOVEA.L   $16F8.L,A0
E052E0   Lab1E:MOVE.B    (A0)+,$FFFFA205.W
E052E4         MOVE.B    (A0)+,$FFFFA206.W
E052E8         MOVE.B    (A0)+,$FFFFA207.W
E052EC         DBF       D0,Lab1E
E052F0         MOVE.L    A0,$16F8.L
E052F6         MOVE.L    #$E0530C,$3FC.W
E052FE         MOVE.B    #$FF,$FFFFA203.W
E05304         ORI.B     #1,$FFFFA200.W
E0530A         RTS

Host Interrupt #1:

E0530C         MOVEM.L   A0/D0,-(A7)
E05310         MOVE.L    $1704.L,D0
E05316         SUBQ.W    #1,D0
E05318         MOVEA.L   $16FC.L,A0
E0531E   Lab1F:MOVE.B    $FFFFA205.W,(A0)+
E05322         MOVE.B    $FFFFA206.W,(A0)+
E05326         MOVE.B    $FFFFA207.W,(A0)+
E0532A         DBF       D0,Lab1F
E0532E         MOVE.L    A0,$16FC.L
E05334         MOVEA.L   $1710.L,A0
E0533A         ADDQ.L    #1,(A0)
E0533C         MOVE.L    (A0),D0
E0533E         CMP.L     $1708.L,D0
E05344         BNE       14(PC)               Lab20
E05348         ANDI.B    #$FE,$FFFFA200.W
E0534E         JMP       $E05378
E05354   Lab20:MOVE.L    $1700.L,D0
E0535A         SUBQ.W    #1,D0
E0535C         MOVEA.L   $16F8.L,A0
E05362   Lab21:MOVE.B    (A0)+,$FFFFA205.W
E05366         MOVE.B    (A0)+,$FFFFA206.W
E0536A         MOVE.B    (A0)+,$FFFFA207.W
E0536E         DBF       D0,Lab21
E05372         MOVE.L    A0,$16F8.L
E05378         MOVEM.L   (A7)+,A0/D0
E0537C         RTE

XBIOS 99: InStream

E0537E         MOVE.L    4(A7),$16F8.L
E05386         MOVE.L    8(A7),$1700.L
E0538E         MOVE.L    12(A7),$1708.L
E05396         MOVE.L    16(A7),$1710.L
E0539E         MOVEA.L   $1710.L,A0
E053A4         MOVE.L    #0,(A0)
E053AA         MOVE.L    $1700.L,D0
E053B0         BEQ       22(PC)               Lab22
E053B4         MOVE.L    #$E05416,$3FC.W
E053BC         MOVE.B    #$FF,$FFFFA203.W
E053C2         ORI.B     #2,$FFFFA200.W
E053C8   Lab22:RTS

XBIOS 100: OutStream

E053CA         MOVE.L    4(A7),$16FC.L
E053D2         MOVE.L    8(A7),$1704.L
E053DA         MOVE.L    12(A7),$170C.L
E053E2         MOVE.L    16(A7),$1714.L
E053EA         MOVEA.L   $1714.L,A0
E053F0         MOVE.L    #0,(A0)
E053F6         MOVE.L    $1704.L,D0
E053FC         BEQ       22(PC)               Lab23
E05400         MOVE.L    #$E05416,$3FC.W
E05408         MOVE.B    #$FF,$FFFFA203.W
E0540E         ORI.B     #1,$FFFFA200.W
E05414   Lab23:RTS

Host Interrupt #2:

E05416         MOVEM.L   A0/D0,-(A7)
E0541A         BTST      #0,$FFFFA202.W
E05420         BEQ       74(PC)               Lab25
E05424         MOVE.L    $1704.L,D0
E0542A         SUBQ.W    #1,D0
E0542C         MOVEA.L   $16FC.L,A0
E05432   Lab24:MOVE.B    $FFFFA205.W,(A0)+
E05436         MOVE.B    $FFFFA206.W,(A0)+
E0543A         MOVE.B    $FFFFA207.W,(A0)+
E0543E         DBF       D0,Lab24
E05442         MOVE.L    A0,$16FC.L
E05448         MOVEA.L   $1714.L,A0
E0544E         ADDI.L    #1,(A0)
E05454         MOVE.L    (A0),D0
E05456         CMP.L     $170C.L,D0
E0545C         BNE       80(PC)               Lab27
E05460         ANDI.B    #$FE,$FFFFA200.W
E05466         JMP       $E054AE
E0546C   Lab25:MOVE.L    $1700.L,D0
E05472         SUBQ.W    #1,D0
E05474         MOVEA.L   $16F8.L,A0
E0547A   Lab26:MOVE.B    (A0)+,$FFFFA205.W
E0547E         MOVE.B    (A0)+,$FFFFA206.W
E05482         MOVE.B    (A0)+,$FFFFA207.W
E05486         DBF       D0,Lab26
E0548A         MOVE.L    A0,$16F8.L
E05490         MOVEA.L   $1710.L,A0
E05496         ADDI.L    #1,(A0)
E0549C         MOVE.L    (A0),D0
E0549E         CMP.L     $1708.L,D0
E054A4         BNE       8(PC)                Lab27
E054A8         ANDI.B    #$FD,$FFFFA200.W
E054AE   Lab27:MOVEM.L   (A7)+,A0/D0
E054B2         RTE

XBIOS 102: RemoveInterrupts

E054B4         MOVE.W    4(A7),D0
E054B8         NOT.B     D0
E054BA         AND.B     D0,$FFFFA200.W
E054BE         RTS

XBIOS 103: GetWordSize

E054C0         MOVE.W    #3,D0                  ;always returns 24bits
E054C4         RTS

XBIOS 126: SetVector

E054C6         MOVE.L    #0,$16F0.L
E054D0         MOVE.L    #0,$16F4.L
E054DA         MOVE.L    4(A7),D0
E054DE         BEQ       Lab28
E054E2         MOVE.L    D0,$16F0.L
E054E8         MOVE.L    #$E05520,$3FC.W
E054F0         MOVE.B    #$FF,$FFFFA203.W
E054F6         ORI.B     #1,$FFFFA200.W
E054FC   Lab28:MOVE.L    8(A7),D0
E05500         BEQ       Lab29
E05504         MOVE.L    D0,$16F4.L
E0550A         MOVE.L    #$E05520,$3FC.W
E05512         MOVE.B    #$FF,$FFFFA203.W
E05518         ORI.B     #2,$FFFFA200.W
E0551E   Lab29:RTS

Host Interrupt #3:

E05520         MOVEM.L   A0-A2/D0-D2,-(A7)
E05524         BTST      #0,$FFFFA202.W
E0552A         BEQ       Lab2A
E0552E         MOVE.L    $16F0.L,D0
E05534         BEQ       Lab2A
E05538         MOVEA.L   D0,A0
E0553A         MOVEQ     #0,D0
E0553C         MOVE.B    $FFFFA205.W,D0
E05540         ROL.L     #8,D0
E05542         MOVE.B    $FFFFA206.W,D0
E05546         ROL.L     #8,D0
E05548         MOVE.B    $FFFFA207.W,D0
E0554C         MOVE.L    D0,-(A7)
E0554E         JSR       (A0)
E05550         ADDQ.L    #4,A7
E05552   Lab2A:BTST      #1,$FFFFA202.W
E05558         BEQ       Lab2B
E0555C         MOVE.L    $16F4.L,D0
E05562         BEQ       Lab2B
E05566         MOVEA.L   D0,A0
E05568         JSR       (A0)
E0556A         TST.L     D0
E0556C         BEQ       Lab2B
E05570         SWAP      D0
E05572         MOVE.B    D0,$FFFFA205.W
E05576         ROL.L     #8,D0
E05578         MOVE.B    D0,$FFFFA206.W
E0557C         ROL.L     #8,D0
E0557E         MOVE.B    D0,$FFFFA207.W
E05582   Lab2B:MOVEM.L   (A7)+,A0-A2/D0-D2
E05586         RTE

E05588         MOVE.L    4(A7),D0
E0558C         BEQ       Lab31
E05590   Lab2C:BTST      #1,$FFFFA202.W
E05596         BEQ.S     Lab2C
E05598         MOVEA.L   12(A7),A0
E0559C         SUB.W     #1,D0
E055A0   Lab2D:MOVE.W    (A0),D1
E055A2         MOVE.L    2(A0),D2
E055A6         SUBQ.L    #1,D2
E055A8         MOVEA.L   6(A0),A1
E055AC         CMP.W     #0,D1
E055B0         BEQ       Lab2E
E055B4         CMP.W     #1,D1
E055B8         BEQ       Lab2F
E055BC         CMP.W     #2,D1
E055C0         BEQ       Lab30
E055C4         JMP       $E0567C
E055CA   Lab2E:MOVE.L    (A1)+,$FFFFA204.W
E055CE         DBF       D2,Lab2E
E055D2         JMP       $E055FE
E055D8   Lab2F:MOVE.W    (A1)+,D1
E055DA         EXT.L     D1
E055DC         MOVE.L    D1,$FFFFA204.W
E055E0         DBF       D2,Lab2F
E055E4         JMP       $E055FE
E055EA   Lab30:MOVE.B    #0,$FFFFA205.W
E055F0         MOVE.B    #0,$FFFFA206.W
E055F6         MOVE.B    (A1)+,$FFFFA207.W
E055FA         DBF       D2,Lab30
E055FE         LEA       10(A0),A0
E05602         DBF       D0,Lab2D
E05606   Lab31:MOVE.L    8(A7),D0
E0560A         BEQ       Lab37
E0560E   Lab32:BTST      #0,$FFFFA202.W
E05614         BEQ.S     Lab32
E05616         MOVEA.L   16(A7),A0
E0561A         SUB.W     #1,D0
E0561E   Lab33:MOVE.W    (A0),D1
E05620         MOVE.L    2(A0),D2
E05624         SUBQ.L    #1,D2
E05626         MOVEA.L   6(A0),A1
E0562A         CMP.W     #0,D1
E0562E         BEQ       Lab34
E05632         CMP.W     #1,D1
E05636         BEQ       Lab35
E0563A         CMP.W     #2,D1
E0563E         BEQ       Lab36
E05642         JMP       $E0567C
E05648   Lab34:MOVE.L    $FFFFA204.W,(A1)+
E0564C         DBF       D2,Lab34
E05650         JMP       $E05674
E05656   Lab35:MOVE.B    $FFFFA206.W,(A1)+
E0565A         MOVE.B    $FFFFA207.W,(A1)+
E0565E         DBF       D2,Lab35
E05662         JMP       $E05674
E05668   Lab36:MOVE.B    $FFFFA206.W,D1
E0566C         MOVE.B    $FFFFA207.W,(A1)+
E05670         DBF       D2,Lab36
E05674         LEA       10(A0),A0
E05678         DBF       D0,Lab33
E0567C   Lab37:RTS
E0567E         LINK      A6,#$FFFA
E05682         MOVEM.L   A5/D7,-(A7)
E05686         JSR       LabA4
E0568A         MOVEQ     #0,D7
E0568C         LEA       $1720.L,A5
E05692         BRA.S     Lab39
E05694   Lab38:CLR.L     (A5)
E05696         CLR.W     10(A5)
E0569A         MOVE.L    D7,D0
E0569C         ADDI.W    #$17,D0
E056A0         MOVE.W    D0,8(A5)
E056A4         ADDQ.W    #1,D7
E056A6         ADDA.W    #$C,A5
E056AA   Lab39:CMPA.L    #$1780,A5
E056B0         BCS.S     Lab38
E056B2         MOVE.L    #$7EA8,D0
E056B8         MOVE.L    D0,$1784.L
E056BE         MOVE.L    D0,$1780.L
E056C4         CLR.L     $1788.L
E056CA         MOVEQ     #0,D0
E056CC         MOVE.W    D0,$178C.L     ; ability
E056D2         MOVE.W    D0,$178E.L
E056D8         MOVE.W    #$8000,$1790.L
E056E0         MOVE.W    D0,-(A7)
E056E2         PEA       $52.W
E056E6         PEA       $E4A9C4
E056EC         JSR       Lab86          ; call ExecBoot
E056F0         MOVEQ     #0,D0
E056F2         MOVE.L    D0,(A7)
E056F4         MOVE.L    D0,-(A7)
E056F6         PEA       $98.W
E056FA         PEA       $E4AABA
E05700         JSR       Lab00
E05704         MOVEM.L   -14(A6),A5/D7
E0570A         UNLK      A6
E0570C         RTS

XBIOS 115: FlushSubroutines

E0570E         LINK      A6,#$FFFC
E05712         MOVE.L    A5,-(A7)
E05714         LEA       $1720.L,A5
E0571A         BRA.S     10(PC)               Lab3B
E0571C   Lab3A:CLR.L     (A5)
E0571E         CLR.W     10(A5)
E05722         ADDA.W    #$C,A5
E05726   Lab3B:CMPA.L    #$1780,A5
E0572C         BCS.S     -18(PC)              Lab3A
E0572E         MOVE.L    $1784.L,$1780.L
E05738         CLR.W     $178E.L
E0573E         MOVEA.L   (A7)+,A5
E05740         UNLK      A6
E05742         RTS


XBIOS 116: LoadSubroutine

E05744         LINK      A6,#$FFF8
E05748         MOVEM.L   A5/D5-D7,-(A7)
E0574C         MOVE.L    12(A6),D7
E05750         MOVE.W    16(A6),D6
E05754         CMPI.L    #$400,D7
E0575A         BLE.S     Lab3C
E0575C         MOVEQ     #0,D0
E0575E         BRA       Lab42
E05762   Lab3C:MOVE.L    $1788.L,D0
E05768         ADD.L     D7,D0
E0576A         MOVE.L    $1780.L,D1
E05770         CMP.L     D1,D0
E05772         BLE.S     Lab3D
E05774         MOVEQ     #0,D0
E05776         BRA       Lab42
E0577A   Lab3D:MOVE.W    $178E.L,D0
E05780         EXT.L     D0
E05782         MULS.L    #$C,D0
E0578A         LEA       $1720.L,A0
E05790         ADDA.L    D0,A0
E05792         MOVEA.L   A0,A5
E05794         TST.L     (A5)
E05796         BEQ.S     Lab40
E05798         MOVE.L    (A5),D0
E0579A         MOVE.L    D0,D2
E0579C         SUBQ.L    #1,D2
E0579E         SUB.L     D1,D0
E057A0         SUBQ.L    #1,D0
E057A2         MOVE.L    D0,-(A7)
E057A4         MOVE.L    $1784.L,-(A7)
E057AA         MOVE.L    D2,-(A7)
E057AC         JSR       Lab8C
E057B0         LEA       12(A7),A7
E057B4         MOVE.W    $178E.L,D0
E057BA         EXT.L     D0
E057BC         MULS.L    #$C,D0
E057C4         LEA       $1720.L,A0
E057CA         MOVEA.L   A0,A1
E057CC         ADDA.L    D0,A1
E057CE         MOVE.L    4(A1),D5
E057D2         MOVEA.L   A0,A5
E057D4         BRA.S     Lab3F
E057D6   Lab3E:ADD.L     D5,(A5)
E057D8         MOVE.W    8(A5),-(A7)
E057DC         MOVE.L    (A5),-(A7)
E057DE         JSR       Lab96
E057E2         ADDQ.W    #6,A7
E057E4         ADDA.W    #$C,A5
E057E8   Lab3F:CMPA.L    #$1780,A5
E057EE         BCS.S     Lab3E
E057F0         ADD.L     D5,$1780.L
E057F6   Lab40:MOVE.L    $1780.L,D0
E057FC         SUB.L     D7,D0
E057FE         MOVE.L    D0,D1
E05800         ADDQ.L    #1,D1
E05802         MOVE.W    $178E.L,D2
E05808         EXT.L     D2
E0580A         MULS.L    #$C,D2
E05812         LEA       $1720.L,A0
E05818         ADDA.L    D2,A0
E0581A         MOVE.L    D1,(A0)
E0581C         MOVE.L    D7,4(A0)
E05820         MOVE.W    D6,10(A0)
E05824         MOVE.L    D0,$1780.L
E0582A         MOVE.W    8(A0),-(A7)
E0582E         MOVE.L    D1,-(A7)
E05830         JSR       Lab96
E05834         JSR       Lab90
E05838         JSR       Lab8E
E0583C         MOVE.W    $178E.L,D0
E05842         EXT.L     D0
E05844         MULS.L    #$C,D0
E0584C         LEA       $1720.L,A0
E05852         ADDA.L    D0,A0
E05854         MOVE.L    4(A0),(A7)
E05858         MOVE.L    (A0),-(A7)
E0585A         JSR       Lab8B
E0585E         MOVEQ     #0,D0
E05860         MOVE.L    D0,(A7)
E05862         MOVE.L    D0,-(A7)
E05864         MOVE.L    D7,-(A7)
E05866         MOVE.L    8(A6),-(A7)
E0586A         JSR       Lab00
E0586E         LEA       22(A7),A7
E05872         MOVE.W    $178E.L,D6
E05878         ADDQ.W    #1,$178E.L
E0587E         CMPI.W    #8,$178E.L
E05886         BLT.S     Lab41
E05888         CLR.W     $178E.L
E0588E   Lab41:MOVE.L    D6,D0
E05890         EXT.L     D0
E05892         MULS.L    #$C,D0
E0589A         LEA       $1720.L,A0
E058A0         ADDA.L    D0,A0
E058A2         MOVE.W    8(A0),D0
E058A6   Lab42:MOVEM.L   (A7)+,A5/D5-D7
E058AA         UNLK      A6
E058AC         RTS

XBIOS 111: LodToBinary

E058AE   Lab43:LINK      A6,#0
E058B2         MOVE.L    8(A6),-(A7)
E058B6         BSR       1236(PC)             Lab81
E058BA         ADDQ.W    #4,A7
E058BC         TST.W     D0
E058BE         BNE.S     4(PC)                Lab44
E058C0         MOVEQ     #$FF,D0
E058C2         BRA.S     26(PC)               Lab45
E058C4   Lab44:MOVE.L    12(A6),-(A7)
E058C8         BSR       1124(PC)             Lab79
E058CC         BSR       1424(PC)             Lab85
E058D0         MOVE.L    $17CE.L,D0
E058D6         DIVS.L    #3,D0
E058DE   Lab45:UNLK      A6
E058E0         RTS

XBIOS 108: LoadProg

E058E2         LINK      A6,#$FFFC
E058E6         MOVE.L    D7,-(A7)
E058E8         MOVE.L    14(A6),D7      ;
E058EC         MOVEA.L   D7,A0
E058EE         MOVE.L    A0,-(A7)       ;destination code address
E058F0         MOVE.L    8(A6),-(A7)    ;addd of .LOD file name
E058F4         MOVE.L    A0,12(A7)      ;remember the address for
                                        ;                  later
E058F8         BSR.S     Lab43          ;call XBIOS 111, LodToBinary
E058FA         ADDQ.W    #8,A7
E058FC         MOVE.L    D0,D7          ;call returns with length of
                                        ;code in D0, or -1 for fail
E058FE         TST.L     D7             ;did it succeed?
E05900         BLE.S     Lab46

E05902         MOVE.W    12(A6),D0
E05906         MOVE.W    D0,$178C.L     ;save the ability
E0590C         MOVE.W    D0,-(A7)       ;ability
E0590E         MOVE.L    D7,-(A7)       ;size of code
E05910         MOVE.L    10(A7),-(A7)   ;position of created code
E05914         BSR       Lab49          ;call XBIOS 109, ExecProg
E05918         LEA       10(A7),A7

E0591C   Lab46:MOVEQ     #$FF,D0        ; did it return -1?
E0591E         CMP.L     D0,D7
E05920         BNE.S     Lab47          ; if not -1, succeeds
E05922         MOVEQ     #$FF,D0
E05924         BRA.S     Lab48
E05926   Lab47:MOVEQ     #0,D0          ; return 0
E05928   Lab48:MOVE.L    (A7)+,D7
E0592A         UNLK      A6
E0592C         RTS

XBIOS 109: ExecProg

E0592E   Lab49:LINK      A6,#0
E05932         MOVE.W    16(A6),-(A7)   ;"ability"
E05936         PEA       $47.W          ;Length of XBIOS code
E0593A         PEA       $E4AC82        ;address of bootcode
E05940         JSR       Lab86          ;call ExecBoot
E05944         MOVEQ     #0,D0
E05946         MOVE.L    D0,(A7)
E05948         MOVE.L    D0,-(A7)
E0594A         MOVE.L    12(A6),-(A7)
E0594E         MOVE.L    8(A6),-(A7)
E05952         JSR       Lab07
E05956         JSR       Lab9A
E0595A         MOVE.W    16(A6),$178C.L ;saves the ability
E05962         UNLK      A6
E05964         RTS

E05966   Lab4A:LINK      A6,#$FFFC
E0596A         MOVEM.L   A4-A5/D5-D7,-(A7)
E0596E         MOVEA.L   8(A6),A5
E05972         MOVEA.L   12(A6),A4
E05976         MOVE.W    16(A6),D7
E0597A         MOVEQ     #1,D6
E0597C         MOVEQ     #0,D5
E0597E         BRA.S     28(PC)               Lab4D
E05980   Lab4B:MOVE.B    0(A4,D5.W),D0
E05984         MOVE.B    0(A5,D5.W),D1
E05988         MOVE.L    D1,D2
E0598A         CMP.B     D0,D2
E0598C         BEQ.S     12(PC)               Lab4C
E0598E         ADDI.B    #$20,D0
E05992         CMP.B     D0,D1
E05994         BEQ.S     4(PC)                Lab4C
E05996         MOVEQ     #0,D6
E05998         BRA.S     6(PC)                Lab4E
E0599A   Lab4C:ADDQ.W    #1,D5
E0599C   Lab4D:CMP.W     D7,D5
E0599E         BLT.S     -32(PC)              Lab4B
E059A0   Lab4E:MOVE.L    D6,D0
E059A2         MOVEM.L   (A7)+,A4-A5/D5-D7
E059A6         UNLK      A6
E059A8         RTS
E059AA   Lab4F:LINK      A6,#$FFFE
E059AE         MOVEQ     #$5F,D0
E059B0         MOVEA.L   $17CA.L,A0
E059B6         CMP.B     (A0),D0
E059B8         BNE.S     10(PC)               Lab50
E059BA         ADDQ.L    #1,$17CA.L
E059C0         MOVEQ     #1,D0
E059C2         BRA.S     2(PC)                Lab51
E059C4   Lab50:MOVEQ     #0,D0
E059C6   Lab51:UNLK      A6
E059C8         RTS
E059CA   Lab52:LINK      A6,#$FFF6
E059CE         MOVEM.L   A4-A5/D7,-(A7)
E059D2         MOVEQ     #0,D7
E059D4         LEA       $E4AD82,A5
E059DA         LEA       $E4AD9A,A4
E059E0         BRA.S     28(PC)               Lab54
E059E2   Lab53:MOVE.W    (A4),-(A7)
E059E4         MOVE.L    (A5),-(A7)
E059E6         MOVE.L    $17CA.L,-(A7)
E059EC         BSR       -136(PC)             Lab4A
E059F0         LEA       10(A7),A7
E059F4         TST.W     D0
E059F6         BNE.S     12(PC)               Lab55
E059F8         ADDQ.W    #1,D7
E059FA         ADDQ.W    #4,A5
E059FC         ADDQ.W    #2,A4
E059FE   Lab54:MOVEQ     #6,D0
E05A00         CMP.W     D0,D7
E05A02         BLT.S     -34(PC)              Lab53
E05A04   Lab55:MOVE.L    D7,D0
E05A06         MOVEM.L   (A7)+,A4-A5/D7
E05A0A         UNLK      A6
E05A0C         RTS
E05A0E   Lab56:LINK      A6,#$FFFE
E05A12         BRA.S     6(PC)                Lab58
E05A14   Lab57:ADDQ.L    #1,$17CA.L
E05A1A   Lab58:MOVEQ     #$D,D0
E05A1C         MOVEA.L   $17CA.L,A0
E05A22         CMP.B     (A0),D0
E05A24         BEQ.S     8(PC)                Lab59
E05A26         CMPA.L    $17C2.L,A0
E05A2C         BLS.S     -26(PC)              Lab57
E05A2E   Lab59:MOVEA.L   $17CA.L,A0
E05A34         MOVEA.L   A0,A1
E05A36         CMPA.L    $17C2.L,A1
E05A3C         BHI.S     6(PC)                Lab5A
E05A3E         ADDQ.L    #2,$17CA.L
E05A44   Lab5A:UNLK      A6
E05A46         RTS
E05A48   Lab5B:LINK      A6,#$FFF8
E05A4C         MOVEM.L   D4-D7,-(A7)
E05A50         MOVE.W    #$1000,D7
E05A54         MOVEQ     #0,D6
E05A56         MOVEQ     #0,D5
E05A58         BRA.S     90(PC)               Lab60
E05A5A   Lab5C:MOVEA.L   $17CA.L,A0
E05A60         MOVE.B    (A0),D0
E05A62         MOVEQ     #$30,D1                        ;"0"
E05A64         CMP.B     D1,D0
E05A66         BCS.S     18(PC)               Lab5D
E05A68         MOVEQ     #$39,D1                        ;"9"
E05A6A         CMP.B     D1,D0
E05A6C         BHI.S     12(PC)               Lab5D
E05A6E         MOVEQ     #0,D1
E05A70         MOVE.B    D0,D1
E05A72         MOVE.L    D1,D4
E05A74         SUBI.W    #$30,D4                        ;"0"
E05A78         BRA.S     34(PC)               Lab5F
E05A7A   Lab5D:MOVEQ     #$41,D1                        ;"A"
E05A7C         CMP.B     D1,D0
E05A7E         BCS.S     18(PC)               Lab5E
E05A80         MOVEQ     #$46,D1                        ;"F"
E05A82         CMP.B     D1,D0
E05A84         BHI.S     12(PC)               Lab5E
E05A86         MOVEQ     #0,D1
E05A88         MOVE.B    D0,D1
E05A8A         MOVE.L    D1,D4
E05A8C         SUBI.W    #$37,D4
E05A90         BRA.S     10(PC)               Lab5F
E05A92   Lab5E:MOVEQ     #0,D1
E05A94         MOVE.B    D0,D1
E05A96         MOVE.L    D1,D4
E05A98         SUBI.W    #$57,D4
E05A9C   Lab5F:ADDQ.L    #1,$17CA.L
E05AA2         MOVE.L    D4,D0
E05AA4         MULS      D7,D0
E05AA6         ADD.W     D0,D6
E05AA8         MOVE.L    D7,D0
E05AAA         EXT.L     D0
E05AAC         DIVS      #$10,D0
E05AB0         MOVE.L    D0,D7
E05AB2         ADDQ.W    #1,D5
E05AB4   Lab60:MOVEQ     #4,D0
E05AB6         CMP.W     D0,D5
E05AB8         BLT.S     -96(PC)              Lab5C
E05ABA         MOVE.L    D6,D0
E05ABC         MOVEM.L   (A7)+,D4-D7
E05AC0         UNLK      A6
E05AC2         RTS
E05AC4   Lab61:LINK      A6,#0
E05AC8         MOVE.L    $17CE.L,D0
E05ACE         MOVEA.L   $17D2.L,A0
E05AD4         ADDA.L    D0,A0
E05AD6         MOVE.B    9(A6),(A0)
E05ADA         MOVE.B    11(A6),1(A0)
E05AE0         ADDQ.L    #3,$17CE.L
E05AE6         MOVE.B    13(A6),2(A0)
E05AEC         ADDQ.L    #1,$17DA.L
E05AF2         UNLK      A6
E05AF4         RTS
E05AF6   Lab62:LINK      A6,#$FFF8
E05AFA         MOVEM.L   A5/D6-D7,-(A7)
E05AFE         MOVE.B    9(A6),D7
E05B02         MOVEQ     #0,D0
E05B04         MOVEA.L   $17D2.L,A0
E05B0A         MOVE.L    $17CE.L,D1
E05B10         MOVE.B    D0,0(A0,D1.L)
E05B14         MOVE.B    D0,1(A0,D1.L)
E05B18         MOVE.L    D1,D2
E05B1A         ADDQ.L    #2,D2
E05B1C         MOVEA.L   A0,A1
E05B1E         ADDA.L    D2,A1
E05B20         MOVEA.L   A1,A5
E05B22         MOVE.L    D1,D6
E05B24         ADDQ.L    #3,D6
E05B26         MOVEQ     #$50,D1
E05B28         CMP.B     D1,D7
E05B2A         BNE.S     10(PC)               Lab63
E05B2C         MOVE.L    D6,$17CE.L
E05B32         MOVE.B    D0,(A5)
E05B34         BRA.S     30(PC)               Lab65
E05B36   Lab63:MOVEQ     #$58,D1
E05B38         CMP.B     D1,D7
E05B3A         BNE.S     12(PC)               Lab64
E05B3C         MOVE.L    D6,$17CE.L
E05B42         MOVE.B    #1,(A5)
E05B46         BRA.S     12(PC)               Lab65
E05B48   Lab64:MOVE.L    D6,D1
E05B4A         MOVE.B    #2,(A5)
E05B4E         MOVE.L    D1,$17CE.L
E05B54   Lab65:MOVEA.L   $17CE.L,A0
E05B5A         ADDQ.L    #1,$17CE.L
E05B60         MOVEA.L   $17D2.L,A1
E05B66         MOVE.L    A0,D1
E05B68         MOVE.B    D0,0(A1,D1.L)
E05B6C         BSR       -294(PC)             Lab5B
E05B70         EXT.L     D0
E05B72         MOVE.L    D0,D1
E05B74         ASR.L     #8,D1
E05B76         MOVEA.L   $17D2.L,A0
E05B7C         MOVE.L    $17CE.L,D2
E05B82         MOVE.B    D1,0(A0,D2.L)
E05B86         MOVE.B    D0,1(A0,D2.L)
E05B8A         CLR.L     $17DA.L
E05B90         MOVE.L    D2,D0
E05B92         ADDQ.L    #2,D0
E05B94         ADDQ.L    #5,$17CE.L
E05B9A         MOVE.L    D0,$17D6.L
E05BA0         BSR       -404(PC)             Lab56
E05BA4         MOVEM.L   (A7)+,A5/D6-D7
E05BA8         UNLK      A6
E05BAA         RTS
E05BAC   Lab66:LINK      A6,#$FFF4
E05BB0         MOVEM.L   D3-D7,-(A7)
E05BB4         MOVEQ     #0,D7
E05BB6         BRA.S     106(PC)              Lab6D
E05BB8   Lab67:MOVEQ     #0,D5
E05BBA         MOVEQ     #$10,D4
E05BBC         MOVEQ     #0,D6
E05BBE         BRA.S     86(PC)               Lab6C
E05BC0   Lab68:MOVEA.L   $17CA.L,A0
E05BC6         MOVE.B    (A0),D0
E05BC8         MOVEQ     #$30,D1
E05BCA         CMP.B     D1,D0
E05BCC         BCS.S     12(PC)               Lab69
E05BCE         MOVEQ     #$39,D2
E05BD0         CMP.B     D2,D0
E05BD2         BHI.S     6(PC)                Lab69
E05BD4         MOVEQ     #$D0,D3
E05BD6         ADD.B     D0,D3
E05BD8         BRA.S     22(PC)               Lab6B
E05BDA   Lab69:MOVEQ     #$41,D1
E05BDC         CMP.B     D1,D0
E05BDE         BCS.S     12(PC)               Lab6A
E05BE0         MOVEQ     #$46,D1
E05BE2         CMP.B     D1,D0
E05BE4         BHI.S     6(PC)                Lab6A
E05BE6         MOVEQ     #$C9,D3
E05BE8         ADD.B     D0,D3
E05BEA         BRA.S     4(PC)                Lab6B
E05BEC   Lab6A:MOVEQ     #$A9,D3
E05BEE         ADD.B     D0,D3
E05BF0   Lab6B:ADDQ.L    #1,$17CA.L
E05BF6         MOVEQ     #0,D0
E05BF8         MOVE.B    D4,D0
E05BFA         MOVEQ     #0,D1
E05BFC         MOVE.B    D3,D1
E05BFE         MULS      D0,D1
E05C00         MOVEQ     #0,D0
E05C02         MOVE.B    D5,D0
E05C04         ADD.W     D1,D0
E05C06         MOVE.L    D0,D5
E05C08         MOVEQ     #0,D0
E05C0A         MOVE.B    D4,D0
E05C0C         EXT.L     D0
E05C0E         DIVS      #$10,D0
E05C12         MOVE.L    D0,D4
E05C14         ADDQ.W    #1,D6
E05C16   Lab6C:MOVEQ     #2,D0
E05C18         CMP.W     D0,D6
E05C1A         BLT.S     -92(PC)              Lab68
E05C1C         MOVE.B    D5,-11(A6,D7.W)
E05C20         ADDQ.W    #1,D7
E05C22   Lab6D:MOVEQ     #3,D0
E05C24         CMP.W     D0,D7
E05C26         BLT.S     -112(PC)             Lab67
E05C28         MOVEQ     #0,D0
E05C2A         MOVE.B    -11(A6),D0
E05C2E         MOVEQ     #0,D1
E05C30         MOVE.B    -10(A6),D1
E05C34         MOVEQ     #0,D2
E05C36         MOVE.B    -9(A6),D2
E05C3A         MOVE.W    D2,-(A7)
E05C3C         MOVE.W    D1,-(A7)
E05C3E         MOVE.W    D0,-(A7)
E05C40         BSR       -382(PC)             Lab61
E05C44         MOVEM.L   -32(A6),D3-D7
E05C4A         UNLK      A6
E05C4C         RTS
E05C4E   Lab6E:LINK      A6,#$FFFE
E05C52         BRA.S     34(PC)               Lab71
E05C54   Lab6F:ADDQ.L    #1,$17CA.L
E05C5A   Lab70:MOVEQ     #$20,D0
E05C5C         MOVEA.L   $17CA.L,A0
E05C62         CMP.B     (A0),D0
E05C64         BEQ.S     -18(PC)              Lab6F
E05C66         MOVEQ     #$D,D0
E05C68         MOVEA.L   $17CA.L,A0
E05C6E         CMP.B     (A0),D0
E05C70         BEQ.S     4(PC)                Lab71
E05C72         BSR       -200(PC)             Lab66
E05C76   Lab71:MOVEQ     #$D,D0
E05C78         MOVEA.L   $17CA.L,A0
E05C7E         CMP.B     (A0),D0
E05C80         BNE.S     -40(PC)              Lab70
E05C82         UNLK      A6
E05C84         RTS
E05C86   Lab72:LINK      A6,#0
E05C8A         MOVE.W    8(A6),D0
E05C8E         LEA       $E4AD9A,A1
E05C94         LEA       (0.B,A1,D0.W*2),A0
E05C98         MOVEA.L   $17CA.L,A1
E05C9E         ADDA.W    (A0),A1
E05CA0         MOVE.L    A1,$17CA.L
E05CA6         UNLK      A6
E05CA8         RTS
E05CAA   Lab73:LINK      A6,#$FFFE
E05CAE         MOVEQ     #1,D0
E05CB0         MOVE.W    D0,-(A7)
E05CB2         BSR.S     -46(PC)              Lab72
E05CB4         ADDQ.W    #2,A7
E05CB6         BRA.S     6(PC)                Lab75
E05CB8   Lab74:ADDQ.L    #1,$17CA.L
E05CBE   Lab75:MOVEQ     #$20,D0
E05CC0         MOVEA.L   $17CA.L,A0
E05CC6         CMP.B     (A0),D0
E05CC8         BEQ.S     -18(PC)              Lab74
E05CCA         MOVEQ     #0,D0
E05CCC         MOVEA.L   $17CA.L,A0
E05CD2         MOVE.B    (A0),D0
E05CD4         ADDQ.L    #2,$17CA.L
E05CDA         MOVE.W    D0,-(A7)
E05CDC         BSR       -488(PC)             Lab62
E05CE0         ADDQ.W    #2,A7
E05CE2         BRA.S     22(PC)               Lab78
E05CE4   Lab76:MOVEQ     #$D,D0
E05CE6         MOVEA.L   $17CA.L,A0
E05CEC         CMP.B     (A0),D0
E05CEE         BNE.S     6(PC)                Lab77
E05CF0         BSR       -740(PC)             Lab56
E05CF4         BRA.S     4(PC)                Lab78
E05CF6   Lab77:BSR       -170(PC)             Lab6E
E05CFA   Lab78:BSR       -850(PC)             Lab4F
E05CFE         TST.W     D0
E05D00         BEQ.S     -30(PC)              Lab76
E05D02         MOVE.L    $17D6.L,D0
E05D08         MOVEA.L   $17D2.L,A0
E05D0E         ADDA.L    D0,A0
E05D10         CLR.B     (A0)
E05D12         MOVE.L    $17DA.L,D1
E05D18         MOVE.L    D1,D2
E05D1A         ASR.L     #8,D2
E05D1C         MOVE.B    D2,1(A0)
E05D20         ADDQ.L    #3,$17D6.L
E05D26         MOVE.B    D1,2(A0)
E05D2A         UNLK      A6
E05D2C         RTS
E05D2E   Lab79:LINK      A6,#$FFFE
E05D32         MOVE.L    D7,-(A7)
E05D34  A      MOVE.L    $17C6.L,$17CA.L
E05D3E         MOVE.L    8(A6),$17D2.L
E05D46         CLR.L     $17CE.L
E05D4C         BRA.S     4(PC)                Lab7B
E05D4E   Lab7A:BSR       -834(PC)             Lab56
E05D52   Lab7B:BSR       -938(PC)             Lab4F
E05D56         TST.W     D0
E05D58         BEQ.S     -12(PC)              Lab7A
E05D5A         BRA.S     30(PC)               Lab80
E05D5C   Lab7C:MOVE.L    D7,D0
E05D5E         SUBQ.W    #1,D0
E05D60         BNE.S     6(PC)                Lab7D
E05D62         BSR       -186(PC)             Lab73
E05D66         BRA.S     18(PC)               Lab80
E05D68   Lab7D:BSR       -860(PC)             Lab56
E05D6C         BRA.S     4(PC)                Lab7F
E05D6E   Lab7E:BSR       -866(PC)             Lab56
E05D72   Lab7F:BSR       -970(PC)             Lab4F
E05D76         TST.W     D0
E05D78         BEQ.S     -12(PC)              Lab7E
E05D7A   Lab80:BSR       -946(PC)             Lab52
E05D7E         MOVE.L    D0,D7
E05D80         MOVEQ     #5,D0
E05D82         CMP.W     D0,D7
E05D84         BNE.S     -42(PC)              Lab7C
E05D86         MOVE.L    (A7)+,D7
E05D88         UNLK      A6
E05D8A         RTS
E05D8C   Lab81:LINK      A6,#$FFF6
E05D90         MOVEM.L   A4-A5/D7,-(A7)
E05D94         MOVEA.L   8(A6),A5
E05D98         MOVEQ     #$2F,D0
E05D9A         MOVE.W    D0,-(A7)
E05D9C         TRAP      #1
E05D9E         ADDQ.W    #2,A7
E05DA0         MOVE.L    D0,D7
E05DA2         PEA       $1792.L
E05DA8         MOVEQ     #$1A,D0
E05DAA         MOVE.W    D0,-(A7)
E05DAC         TRAP      #1
E05DAE         ADDQ.W    #6,A7
E05DB0         CLR.W     -(A7)
E05DB2         MOVE.L    A5,-(A7)
E05DB4         MOVEQ     #$4E,D0
E05DB6         MOVE.W    D0,-(A7)
E05DB8         TRAP      #1
E05DBA         ADDQ.W    #8,A7
E05DBC         MOVEQ     #$FF,D1
E05DBE         CMP.L     D1,D0
E05DC0         BGT.S     18(PC)               Lab82
E05DC2         MOVEA.L   D7,A0
E05DC4         MOVE.L    A0,-(A7)
E05DC6         MOVEQ     #$1A,D0
E05DC8         MOVE.W    D0,-(A7)
E05DCA         TRAP      #1
E05DCC         ADDQ.W    #6,A7
E05DCE         MOVEQ     #0,D0
E05DD0         BRA       132(PC)              Lab84
E05DD4   Lab82:MOVE.L    $17AC.L,D0
E05DDA         MOVE.L    D0,$17BE.L
E05DE0         MOVE.L    D0,-(A7)
E05DE2         MOVEQ     #$48,D0
E05DE4         MOVE.W    D0,-(A7)
E05DE6         TRAP      #1
E05DE8         ADDQ.W    #6,A7
E05DEA         MOVEA.L   D7,A4
E05DEC         MOVE.L    D0,$17C6.L
E05DF2         TST.L     D0
E05DF4         BNE.S     14(PC)               Lab83
E05DF6         MOVE.L    A4,-(A7)
E05DF8         MOVEQ     #$1A,D1
E05DFA         MOVE.W    D1,-(A7)
E05DFC         TRAP      #1
E05DFE         ADDQ.W    #6,A7
E05E00         MOVEQ     #0,D0
E05E02         BRA.S     82(PC)               Lab84
E05E04   Lab83:CLR.W     -(A7)
E05E06         MOVE.L    A5,-(A7)
E05E08         MOVEQ     #$3D,D0
E05E0A         MOVE.W    D0,-(A7)
E05E0C         TRAP      #1
E05E0E         ADDQ.W    #8,A7
E05E10         MOVE.W    D0,12(A7)
E05E14         MOVE.L    $17C6.L,-(A7)
E05E1A         MOVE.L    $17AC.L,-(A7)
E05E20         MOVE.W    D0,-(A7)
E05E22         MOVEQ     #$3F,D1
E05E24         MOVE.W    D1,-(A7)
E05E26         TRAP      #1
E05E28         LEA       12(A7),A7
E05E2C         MOVE.W    12(A7),-(A7)
E05E30         MOVEQ     #$3E,D0
E05E32         MOVE.W    D0,-(A7)
E05E34         TRAP      #1
E05E36         ADDQ.W    #4,A7
E05E38         MOVEA.L   $17C6.L,A0
E05E3E         ADDA.L    $17AC.L,A0
E05E44         MOVE.L    A0,$17C2.L
E05E4A         MOVE.L    A4,-(A7)
E05E4C         MOVEQ     #$1A,D0
E05E4E         MOVE.W    D0,-(A7)
E05E50         TRAP      #1
E05E52         ADDQ.W    #6,A7
E05E54         MOVEQ     #1,D0
E05E56   Lab84:MOVEM.L   (A7)+,A4-A5/D7
E05E5A         UNLK      A6
E05E5C         RTS
E05E5E   Lab85:LINK      A6,#$FFFE
E05E62         MOVE.L    $17C6.L,-(A7)
E05E68         MOVEQ     #$49,D0
E05E6A         MOVE.W    D0,-(A7)
E05E6C         TRAP      #1
E05E6E         ADDQ.W    #6,A7
E05E70         UNLK      A6
E05E72         RTS

XBIOS 110: ExecBoot

E05E74   Lab86:MOVE      SR,$17E0.L             ;save status register
E05E7A         MOVE      #$2700,SR              ;reset the DSP
E05E7E         MOVE.B    #$E,$FFFF8800.W        ;by setting bit 4
E05E84         MOVE.B    $FFFF8800.W,D0         ;of port A to 0
E05E88         ANDI.B    #$EF,D0                ;for 1/100 of a second
E05E8C         MOVE.B    D0,$FFFF8802.W
E05E90         ORI.B     #$10,D0
E05E94         MOVE.B    D0,$FFFF8802.W         ;set bit 4 to 1
E05E98         MOVE      $17E0.L,SR
E05E9E         MOVE.L    $4BA.W,D0              ;$4BA - 200Hz system
E05EA2         ADDQ.L    #2,D0                  ;clock
E05EA4   Lab87:MOVE.L    $4BA.W,D1
E05EA8         CMP.L     D0,D1                  ;finished countdown?
E05EAA         BLT.S     Lab87
E05EAC         MOVE      SR,$17E0.L             ;restore status register

E05EB2         MOVE      #$2700,SR              ;set bit 4 low again
E05EB6         MOVE.B    #$E,$FFFF8800.W
E05EBC         MOVE.B    $FFFF8800.W,D0
E05EC0         ANDI.B    #$EF,D0
E05EC4         MOVE.B    D0,$FFFF8802.W
E05EC8         MOVE      $17E0.L,SR             ;restore status register
                                                ;DSP bootpatch now expects
                                                ;$200 dsp-words via the
                                                ;host port
E05ECE         MOVE.L    8(A7),D0               ;d0=Length of bootprog
E05ED2         MOVE.L    #$200,D1
E05ED8         SUB.L     D0,D1                  ;d1=$200-Length
E05EDA         SUB.L     #1,D0
E05EE0         MOVEA.L   4(A7),A0               ;a0=addr of boot code
E05EE4   Lab88:MOVE.B    (A0)+,$FFFFA205.W
E05EE8         MOVE.B    (A0)+,$FFFFA206.W
E05EEC         MOVE.B    (A0)+,$FFFFA207.W
E05EF0         DBF       D0,Lab88
E05EF4         MOVE.L    D1,D1
E05EF6         BEQ       Lab8A
E05EFA         SUB.L     #1,D1
E05F00   Lab89:MOVE.B    #0,$FFFFA205.W         ;send zero bytes to
E05F06         MOVE.B    #0,$FFFFA206.W         ;fill up the $200
E05F0C         MOVE.B    #0,$FFFFA207.W
E05F12         DBF       D1,Lab89
E05F16   Lab8A:RTS

E05F18   Lab8B:MOVE.B    5(A7),$FFFFA205.W
E05F1E         MOVE.B    6(A7),$FFFFA206.W
E05F24         MOVE.B    7(A7),$FFFFA207.W
E05F2A         MOVE.B    9(A7),$FFFFA205.W
E05F30         MOVE.B    10(A7),$FFFFA206.W
E05F36         MOVE.B    11(A7),$FFFFA207.W
E05F3C         RTS

E05F3E   Lab8C:MOVE.B    #$96,$FFFFA201.W
E05F44   Lab8D:BTST      #7,$FFFFA201.W
E05F4A         BNE.S     -8(PC)               Lab8D
E05F4C         MOVE.B    5(A7),$FFFFA205.W
E05F52         MOVE.B    6(A7),$FFFFA206.W
E05F58         MOVE.B    7(A7),$FFFFA207.W
E05F5E         MOVE.B    9(A7),$FFFFA205.W
E05F64         MOVE.B    10(A7),$FFFFA206.W
E05F6A         MOVE.B    11(A7),$FFFFA207.W
E05F70         MOVE.B    13(A7),$FFFFA205.W
E05F76         MOVE.B    14(A7),$FFFFA206.W
E05F7C         MOVE.B    15(A7),$FFFFA207.W
E05F82         RTS
E05F84   Lab8E:MOVE.B    #$95,$FFFFA201.W
E05F8A   Lab8F:BTST      #7,$FFFFA201.W
E05F90         BNE.S     -8(PC)               Lab8F
E05F92         RTS
E05F94   Lab90:MOVE.B    #$95,$FFFFA201.W
E05F9A   Lab91:BTST      #7,$FFFFA201.W
E05FA0         BNE.S     -8(PC)               Lab91
E05FA2         MOVE.B    #0,$FFFFA205.W
E05FA8         MOVE.B    #0,$FFFFA206.W
E05FAE         MOVE.B    #$2E,$FFFFA207.W
E05FB4         MOVE.B    #0,$FFFFA205.W
E05FBA         MOVE.B    #0,$FFFFA206.W
E05FC0         MOVEQ     #$10,D0
E05FC2         MOVE.B    D0,$FFFFA207.W
E05FC6         SUBQ.W    #1,D0
E05FC8         LEA       $17F7.L,A0
E05FCE   Lab92:MOVE.B    (A0)+,$FFFFA205.W
E05FD2         MOVE.B    (A0)+,$FFFFA206.W
E05FD6         MOVE.B    (A0)+,$FFFFA207.W
E05FDA         DBF       D0,Lab92
E05FDE         RTS

XBIOS 118: RunSubroutine

E05FE0         MOVE.W    4(A7),D0
E05FE4         MOVE.W    D0,D1
E05FE6         CMP.B     #$17,D0
E05FEA         BLT       Lab93
E05FEE         CMP.B     #$1E,D0
E05FF2         BGT       Lab93
E05FF6         SUB.W     #$17,D1
E05FFA         MULS      #6,D1
E05FFE         ADD.W     #3,D1
E06002         LEA       $17F7.L,A0
E06008         ADDA.W    D1,A0
E0600A         MOVE.B    (A0)+,$FFFFA205.W
E0600E         MOVE.B    (A0)+,$FFFFA206.W
E06012         MOVE.B    (A0)+,$FFFFA207.W
E06016         ORI.B     #$80,D0
E0601A         MOVE.B    D0,$FFFFA201.W
E0601E         MOVE.W    #0,D0
E06022         BRA       Lab94
E06026   Lab93:MOVE.W    #$FFFF,D0
E0602A   Lab94:RTS

XBIOS 112: TriggerHC

E0602C         MOVE.W    4(A7),D0
E06030         ORI.B     #$80,D0
E06034         MOVE.B    D0,$FFFFA201.W
E06038         RTS

XBIOS 104: Lock
E0603A         MOVE.W    $17DE.L,D0
E06040         BNE       Lab95
E06044         MOVE.W    #$FFFF,D1
E06048         MOVE.W    D1,$17DE.L
E0604E   Lab95:RTS

XBIOS 105: UnLock
E06050         MOVE.W    #0,$17DE.L
E06058         RTS

E0605A   Lab96:MOVE.L    4(A7),D0
E0605E         MOVEQ     #0,D1
E06060         MOVE.W    8(A7),D1
E06064         SUB.W     #$17,D1
E06068         MULS      #6,D1
E0606C         ADD.W     #4,D1
E06070         LEA       $17F7.L,A0
E06076         ADDA.W    D1,A0
E06078         MOVE.W    D0,(A0)+
E0607A         RTS

Xbios 106: Available
E0607C         MOVEA.L   4(A7),A0
E06080         MOVEA.L   8(A7),A1
E06084         MOVE.L    #$3EFF,(A1)
E0608A         MOVE.L    $1780.L,D0
E06090         SUB.L     #$4000,D0
E06096         MOVE.L    D0,(A0)
E06098         RTS

XBIOS 107: Reserve

E0609A         MOVE.L    4(A7),D0
E0609E         ADD.L     #$4000,D0
E060A4         MOVE.L    $1780.L,D1
E060AA         CMP.L     D1,D0
E060AC         BGT       32(PC)               Lab97
E060B0         MOVE.L    D0,$1788.L
E060B6         MOVE.L    8(A7),D0
E060BA         CMP.L     #$3EFF,D0
E060C0         BGT       12(PC)               Lab97
E060C4         MOVE.W    #0,D0
E060C8         JMP       $E060D2
E060CE   Lab97:MOVE.W    #$FFFF,D0
E060D2         RTS

XBIOS 113: RequestUniqueAbility

E060D4         MOVE.W    $1790.L,D0
E060DA         ADD.W     #1,D0
E060DE         MOVE.W    D0,$1790.L
E060E4         RTS

XBIOS 114: GetProgAbility

E060E6         MOVE.W    $178C.L,D0             ;get ability
E060EC         RTS

XBIOS 117: InqSubrAbility

E060EE         MOVE.W    4(A7),D1
E060F2         LEA       $1720.L,A0
E060F8         MOVEQ     #$16,D0
E060FA   Lab98:ADDQ.W    #1,D0
E060FC         CMP.W     10(A0),D1
E06100         BEQ       18(PC)               Lab99
E06104         LEA       12(A0),A0
E06108         CMP.L     #$1E,D0
E0610E         BNE.S     -22(PC)              Lab98
E06110         MOVE.W    #0,D0
E06114   Lab99:RTS
E06116   Lab9A:LEA       $17E2.L,A1
E0611C         MOVEQ     #$18,D0
E0611E         SUBQ.W    #1,D0
E06120   Lab9B:BTST      #1,$FFFFA202.W
E06126         BEQ.S     -8(PC)               Lab9B
E06128         MOVE.B    (A1)+,$FFFFA205.W
E0612C         MOVE.B    (A1)+,$FFFFA206.W
E06130         MOVE.B    (A1)+,$FFFFA207.W
E06134         DBF       D0,Lab9B
E06138         RTS

XBIOS 119: HF0

E0613A         MOVE.W    4(A7),D1
E0613E         CMP.W     #$FFFF,D1
E06142         BEQ       38(PC)               Lab9D
E06146         CMP.W     #1,D1
E0614A         BNE       12(PC)               Lab9C
E0614E         BSET      #3,$FFFFA200.W
E06154         BRA       38(PC)               Lab9E
E06158   Lab9C:CMP.W     #0,D1
E0615C         BNE       30(PC)               Lab9E
E06160         BCLR      #3,$FFFFA200.W
E06166         BRA       20(PC)               Lab9E
E0616A   Lab9D:MOVE.W    #0,D0
E0616E         BTST      #3,$FFFFA200.W
E06174         BEQ       6(PC)                Lab9E
E06178         MOVE.W    #1,D0
E0617C   Lab9E:RTS

XBIOS 120: HF1

E0617E         MOVE.W    4(A7),D1
E06182         CMP.W     #$FFFF,D1
E06186         BEQ       38(PC)               LabA0
E0618A         CMP.W     #1,D1
E0618E         BNE       12(PC)               Lab9F
E06192         BSET      #4,$FFFFA200.W
E06198         BRA       38(PC)               LabA1
E0619C   Lab9F:CMP.W     #0,D1
E061A0         BNE       30(PC)               LabA1
E061A4         BCLR      #4,$FFFFA200.W
E061AA         BRA       20(PC)               LabA1
E061AE   LabA0:MOVE.W    #0,D0
E061B2         BTST      #4,$FFFFA200.W
E061B8         BEQ       6(PC)                LabA1
E061BC         MOVE.W    #1,D0
E061C0   LabA1:RTS

XBIOS 121: HF2

E061C2         MOVE.W    #0,D0
E061C6         BTST      #3,$FFFFA202.W
E061CC         BEQ       6(PC)                LabA2
E061D0         MOVE.W    #1,D0
E061D4   LabA2:RTS

XBIOS 122: HF3

E061D6         MOVE.W    #0,D0
E061DA         BTST      #4,$FFFFA202.W
E061E0         BEQ       6(PC)                LabA3
E061E4         MOVE.W    #1,D0
E061E8   LabA3:RTS

XBIOS 125: HStat

E061EA         MOVE.B    $FFFFA202.W,D0
E061EE         MOVE.B    $FFFFA201.W,D1
E061F2         RTS
