;***************************************************************
;*                                                             *
;* FINEXT.ASM: extend keyboard functions for Scandinavian kb   *
;* installs itself in the keyboard interrupt                   *
;* valid for TOS 20/11/1985                                    *
;*                                                             *
;* TOS version dependent (marked with **):                     *
;*     addr. for kbshifts: A5D (TOS 20.06.85 D)                *
;*                         E1B (TOS 20.11.85 GB)               *
;*                         E1B (TOS 06.02.86 D)                *
;*                         E61 (TOS 1.2 22.04.87 D "Blitter")  *
;*                                                             *
;* Version for K-SEKA-Assembler                                *
;* THIS PROGRAM IS IN THE PUBLIC DOMAIN                        *
;* FINEXT is modified from KBEXT(v 2.02 )                      *
;* 24.04.88                                                    * 
;* Arto Vesterinen                                             *
;***************************************************************

          code
 alku:    BRA      .L install
kbint:
          MOVE.L    TOSvec(pc),A0
          JSR       (A0)           ;* jump to TOS routine
          BRA.S     go
timerint:
          MOVE.W    4(A7),D0
          MOVE.W    D0,-(A7)       ;* copy argument
          MOVE.L    TMRvec(pc),A0
          JSR       (A0)           ;* call etv_timer
          ADDQ.L    #2,A7
go:
          MOVE.L    IOrec(pc),A0
          MOVE.L    (A0),A2        ;* get address of io-buffer
          MOVE.W    8(A0),D1       ;* tail index
          CMP.W     OLDtail(pc),D1     ;* test if changed
          BEQ.S     rturn
          LEA       OLDtail(pc),A1
          MOVE.W    D1,(A1)        ;* save tail index at OLDtail
          MOVE.B    $E1B.w,d2        ;* get kbshifts (** TOS dependent)
          BTST      #3,D2          ;* ALT set?
          BEQ.S     rturn          ;* if 0, return
          MOVE.W    0(A2,D1.W),D0  ;* get...
          AND.W     #$7F,D0        ;* ...key code
          LEA       ALTtabl(pc),A1     ;* get translation table
          BTST      #2,D2          ;* CTRL set?
          BEQ.S     goahead         
          CLR.W     D0             ;* then set char to NUL
          BRA.S     store
goahead:
          AND.B     #$13,D2        ;* test SHIFT l/r and CapsL
          BEQ.S     goon           ;* if none set
          ADD.L    #128,A1        ;* use second table (ALT&SHIFT)
goon:
          MOVE.B    0(A1,D0.W),D0  ;* translate
store:
          MOVE.W    D0,2(A2,D1.W)  ;* store char code
rturn:
          RTS
TOSvec:
          DC.L      0
TMRvec:
          DC.L      0
IOrec:
          DC.L      0
OLDtail:
          DC.W      -1
tag:
          DC.B      'F','I','N','E','X','T','/','R','W',0
;*
;* here are the keyboard tables for normal, SHIFT,
;*                                  and normal with CAPS LOCK
;*                                  ALT, ALT&SHIFT
;* you find them in the compiled program after the tag "KBEXT/RW"
;*
;* to change the keyboard layout, use the "normal" table as a
;* guide for the keys (the layout is for a UK keyboard)
;* and insert the ATARI/ASCII codes of the characters you want.
;* NOTE:
;* with ALT, the positions 02 ('1') ... 09 ('8') move to
;* 78 ... 7F,
;* and 0A ('9') ... 0D ('=') to 00 ... 03 (should be 80 ... 83)
;* these rearrangements are done BY THE PROGRAM, so: fill the
;* tables according to the normal keycode position.
;*
normal:
          DC.B      $00,$1B,'1','2','3','4','5','6' ;* 00 Esc
          DC.B      '7','8','9','0','+',"'",$08,$09 ;* 08 BS,TAB
          DC.B      'q','w','e','r','t','y','u','i' ;* 10
          DC.B      'o','p','Ü','Å',$0D,$00,'a','s' ;* 18 CR
          DC.B      'd','f','g','h','j','k','l','î' ;* 20
          DC.B      'Ñ','*',$00,'~','z','x','c','v' ;* 28 '
          DC.B      'b','n','m',',','.','-',$00,$00 ;* 30
          DC.B      $00,' ',$00,$00,$00,$00,$00,$00 ;* 38
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 40
          DC.B      $00,$00,'-',$00,$00,$00,'+',$00 ;* 48
          DC.B      $00,$00,$00,$7F,$00,$00,$00,$00 ;* 50 DEL
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 58
          DC.B      '<',$00,$00,"(",')','/','*','7' ;* 60 \
          DC.B      '8','9','4','5','6','1','2','3' ;* 68
          DC.B      '0','.',$0D,$00,$00,$00,$00,$00 ;* 70 Enter
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 78
shiftblk:
          DC.B      $00,$1B,'!','"','#','$','%','&' ;* 00
          DC.B      '/','(',')','=','?','`',$08,$09 ;* 08
          DC.B      'Q','W','E','R','T','Y','U','I' ;* 10
          DC.B      'O','P','è','ö',$0D,$00,'A','S' ;* 18
          DC.B      'D','F','G','H','J','K','L','ô' ;* 20
          DC.B      'é','^',$00,'|','Z','X','C','V' ;* 28
          DC.B      'B','N','M',';',':','_',$00,$00 ;* 30
          DC.B      $00,' ',$00,$00,$00,$00,$00,$00 ;* 38
          DC.B      $00,$00,$00,$00,$00,$00,$00,'7' ;* 40 Clr
          DC.B      '8',$00,$0E,'4',$00,'6',$0F,$00 ;* 48 up,k-,left,right,k+
          DC.B      '2',$00,'0',$7F,$00,$00,$00,$00 ;* 50 down,insert
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 58
          DC.B      '>',$00,$00,$08,$09,$0A,$0B,$17 ;* 60
          DC.B      $18,$19,$14,$15,$16,$11,$12,$13 ;* 68
          DC.B      $10,$1A,$0D,$00,$00,$00,$00,$00 ;* 70
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 78
capslock:
          DC.B      $00,$1B,'1','2','3','4','5','6' ;* 00
          DC.B      '7','8','9','0','+',"'",$08,$09 ;* 08
          DC.B      'Q','W','E','R','T','Y','U','I' ;* 10
          DC.B      'O','P','è','ö',$0D,$00,'A','S' ;* 18
          DC.B      'D','F','G','H','J','K','L','ô' ;* 20
          DC.B      'é','*',$00,'~','Z','X','C','V' ;* 28
          DC.B      'B','N','M',',','.','-',$00,$00 ;* 30
          DC.B      $00,' ',$00,$00,$00,$00,$00,$00 ;* 38
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 40
          DC.B      $00,$00,'-',$00,$00,$00,'+',$00 ;* 48
          DC.B      $00,$00,$00,$7F,$00,$00,$00,$00 ;* 50
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 58
          DC.B      '<',$00,$00,'(',')','/','*','7' ;* 60
          DC.B      '8','9','4','5','6','1','2','3' ;* 68
          DC.B      '0','.',$0D,$00,$00,$00,$00,$00 ;* 70
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 78
ALTtabl:
          DC.B      $00,$1B,$BB,$AB,$9C,$AC,$BF,$BD ;* 00
          DC.B      $DF,$A9,$AA,$F7,$F1,$BA,$00,$00 ;* 08
          DC.B      $91,$B4,$89,$8A,$E7,$98,$D1,$F5 ;* 10
          DC.B      $A7,$E3,'@',$E1,$00,$00,$E0,$E5 ;* 18
          DC.B      $EB,$9F,$DF,$D3,$C0,$D5,$D7,$5B ;* 20
          DC.B      $5D,$F8,$00,$82,$B0,$B1,$87,$DE ;* 28
          DC.B      $9E,$A4,$E6,$E8,$B3,$FF,$00,$00 ;* 30
          DC.B      $00,$20,$00,$00,$00,$00,$00,$00 ;* 38
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 40
          DC.B      $00,$00,$DA,$00,$00,$00,$DB,$00 ;* 48
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 50
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 58
          DC.B      $F3,$00,$00,$A0,$83,$85,$A6,$A1 ;* 60
          DC.B      $8C,$8D,$A3,$96,$97,$A2,$93,$95 ;* 68
          DC.B      $DC,$FC,$00,$00,$00,$00,$00,$00 ;* 70
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 78
;* ALT & SHIFT
          DC.B      $00,$1B,$AD,$B9,$DD,$9B,$9D,$BE ;* 00
          DC.B      $F6,$AE,$AF,$F0,$A8,$FA,$00,$00 ;* 08
          DC.B      $92,$B5,$EE,$88,$E9,$8B,$D2,$F4 ;* 10
          DC.B      $EA,$BC,$5C,$9F,$00,$00,$B6,$E4 ;* 18
          DC.B      $7F,$ED,$E2,$D4,$C1,$D6,$D8,$7B ;* 20
          DC.B      $7D,$F9,$00,$90,$B7,$B8,$80,$FB ;* 28
          DC.B      $D9,$A5,$D0,$EC,$B2,$CB,$00,$00 ;* 30
          DC.B      $00,$20,$00,$00,$00,$00,$00,$00 ;* 38
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 40
          DC.B      $00,$00,$C9,$00,$00,$00,$CD,$00 ;* 48
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 50
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 58
          DC.B      $F2,$00,$00,$C2,$C3,$C4,$C5,$C6 ;* 60
          DC.B      $C7,$C8,$CA,$CB,$CC,$CE,$FD,$FE ;* 68
          DC.B      $CF,$EF,$00,$00,$00,$00,$00,$00 ;* 70
          DC.B      $00,$00,$00,$00,$00,$00,$00,$00 ;* 78
pglength:
          DC.L      0
install:
          MOVE.L   4(A7),A5       ;* basepage
          LEA       pglength(PC),A0
          LEA       install(PC),A1
          MOVE.L    A1,D0
          SUB.L     A5,D0          ;* calculate length
          MOVE.L    D0,(A0)
          MOVE.L    D0,-(A7)       ;* length
          MOVE.L    A5,-(A7)       ;* start
          CLR.W     -(A7)
          MOVE.W    #$4A,-(A7)
          TRAP      #1             ;* SETBLOCK, reserve storage
          LEA       12(A7),A7
          CLR.W     -(A7)          ;* read file DEFAULT.KBD
          PEA       file1(PC)
          MOVE.W    #$3D,-(A7)     ;* open
          TRAP      #1
          ADDQ.L    #8,A7
          TST.W     D0
          BMI.S     nodefault
          PEA       normal(PC)     ;* table address for read
          MOVE.L    #384,-(A7)     ;* length
          MOVE.W    D0,-(A7)       ;* handle 
          MOVE.W    #$3F,-(A7)     ;* read
          TRAP      #1
          LEA       12(A7),A7
          MOVE.W    handle(PC),-(A7)
          MOVE.W    #$3E,-(A7)     ;* close
          TRAP      #1
          ADDQ.L    #4,A7
nodefault:
          CLR.W     -(A7)          ;* read file ALT.KBD
          PEA       file2(PC)
          MOVE.W    #$3D,-(A7)     ;* open
          TRAP      #1
          ADDQ.L    #8,A7
          TST.W     D0
          BMI.S     noaltfile
          LEA       handle(PC),A0  ;* file handle
          MOVE.W    D0,(A0)
          PEA       ALTtabl(PC)    ;* table address for read
          MOVE.L    #256,-(A7)     ;* length
          MOVE.W    D0,-(A7)       ;* handle 
          MOVE.W    #$3F,-(A7)     ;* read
          TRAP      #1
          LEA       12(A7),A7
          MOVE.W    handle(PC),-(A7)
          MOVE.W    #$3E,-(A7)     ;* close
          TRAP      #1
          ADDQ.L    #4,A7
noaltfile:
          LEA       ALTtabl(PC),A0 ;* rearrange ALT-Codes
          MOVE.L    $02(A0),$78(A0)
          MOVE.L    $06(A0),$7C(A0)
          MOVE.L    $0A(A0),(A0)
          MOVE.L    $082(A0),$0F8(A0) ;* same for ALT SHIFT
          MOVE.L    $086(A0),$0FC(A0)
          MOVE.L    $08A(A0),$080(A0)
          MOVE.W    #1,-(A7)
          MOVE.W    #14,-(A7)
          TRAP      #14            ;* get iorec(1)
          ADDQ.L    #4,A7
          LEA       IOrec(PC),A0
          MOVE.L    D0,(A0)        ;* save pointer to kbd-iorec
          PEA       CAPSLOCK(PC)
          PEA       SHIFTBLK(PC)
          PEA       NORMAL(PC)
          MOVE.W    #$10,-(A7)
          TRAP      #$E
          ADD.L     #$E,A7
          MOVE.W    #34,-(A7)
          TRAP      #14            ;* Kbdvbase()
          ADDQ.L    #2,A7
          MOVE.L    D0,A1          ;* A1 = addr(kbdvbase)
          LEA       TOSvec(PC),A0
          MOVE.L    32(A1),(A0)    ;* save interrupt routine address
          LEA       kbint(PC),A0
          MOVE.L    A0,32(A1)      ;* install new interrupt vector
          CLR.L     -(A7)
          MOVE.W    #$20,-(A7)
          TRAP      #1             ;* Super
          ADDQ.L    #6,A7
          LEA       TMRvec(PC),A0
          MOVE.L    $400.W,(A0)      ;* save etv_timer routine address
          LEA       timerint(PC),A0
          MOVE.L    A0,$400.W        ;* install new interrupt vector
          MOVE.L    D0,-(A7)
          MOVE.W    #$20,-(A7)
          TRAP      #1
          ADDQ.L    #6,A7
          CLR.W     -(A7)          ;* return code
          MOVE.L    pglength(PC),-(A7) ;* program length
          MOVE.W    #$31,-(A7)     ;* Ptermres
          TRAP      #1             ;* reserve storage and end
          RTS                      ;* never reached
handle:   DC.W      0
file1:    DC.B      $5C,'AUTO',$5C
          DC.B      'DEFAULT.KBD',$00
file2:    DC.B      $5C,'AUTO',$5C
          DC.B      'ALT.KBD',$00
even
dc.l alku
          END

