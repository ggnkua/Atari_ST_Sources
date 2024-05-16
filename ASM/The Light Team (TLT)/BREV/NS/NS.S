; *****************************************************************
; *  NORTH STAR MUZAK, RIPPED BY THE DISKBUSTER OF THE LIGHT TEAM *
; *       COMPOSED BY BEN DAGLIESH, AND IT'S QUITE GOOD!!!        *
; *****************************************************************

 PEA MUZAK
 MOVE.W #38,-(SP)
 TRAP #14
 ADDQ.L #6,SP

 PEA MUZAKOFF
 MOVE.W #38,-(SP)
 TRAP #14
 ADDQ.L #6,SP

 CLR.W -(SP)
 TRAP #1

MUZAK:
 LEA BUFFER,A0
 LEA $2AAA6,A1
 MOVE.L #8199,D5
LOOP:
 MOVE.B (A1)+,(A0)+
 DBRA D5,LOOP

 LEA MUSIC,A0
 LEA $2AAA6,A1
 MOVE.L #8199,D5
LOOP2:
 MOVE.B (A0)+,(A1)+
 DBRA D5,LOOP2

 MOVEQ #2,D0
 JSR $2AAA6
 MOVE.L #$2AB06,$4D2
 RTS

MUZAKOFF:
 MOVE.W #7,-(SP)
 TRAP #1
 ADDQ.L #2,SP

 CLR.L $4D2
 
 LEA $2AAA6,A0
 LEA BUFFER,A1
 MOVE.L #8199,D5
LOOP3:
 MOVE.B (A1)+,(A0)+
 DBRA D5,LOOP3
 RTS

MUSIC:             INCBIN NS.MUS
BUFFER:            DS.B 8200
VSAVE:             DC.L 0
 END
