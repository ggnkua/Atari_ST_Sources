* Programme de gestion clavier/joystick/souris
* Ecrit avec DevpacST 2
* ½ St‚phane CATALA (Belzebub/ST Connexion)
* ST Magazine 1991
* D‚finition des Macros
Send  Macro
  Lea     \1(A6),A0
  Moveq   #\1Len-1,D0
  Btst    #1,$FFFFFC00.w
  Beq.s   *-6
  Ifeq    '\2'-'+'
  Move.b  (A0)+,$FFFFFC02.w
  Dbra    D0,*-12
  Endc
  Ifeq    '\2'-'-'
  Move.b  0(A0,D0),$FFFFFC02.w
  Dbra    D0,*-14
  Endc
  Endm
Print Macro
  Move.w  #$2700,SR
  Pea     \1(A6)
  Move.w  #$9,-(A7)
  Trap    #1
  Addq.l  #6,A7
  Move.w  #$2300,SR
  Endm
* Mise en place de la routine Ikbd
  Clr.l   -(A7)
  Move.w  #$20,-(A7)
  Trap    #1
  Addq.l  #6,A7
  Move.w  #$2700,SR
  Lea     DataOffset(PC),A6
  Send    Boot,+
  Send    PauseOutput,+
  Send    ControllerExecute,+
  Send    Loader,-
  Send    Program,-
* Lancer D‚monstration
  Lea     Vbl(PC),A0
  Move.l  A0,$70.w
  Clr.b   $FFFFFA07.w
  Clr.b   $FFFFFA09.w
  Move.w  #$2300,SR
Print6301Data
  Print   Home
  Lea     Data6301(A6),A5
  Moveq   #19,D7
Read6301Data
  Move.b  (A5)+,D0
  Bsr     Ascii
  Move.b  D1,Hexa+1(A6)
  Bsr     Ascii
  Move.b  D1,Hexa(A6)
  Print   Hexa
  Dbra    D7,Read6301Data
  lea     (data6301+19)(a6),a5
  lea     1(a5),a4
  moveq   #15,d7
loooop
  move.b  -(a5),-(a4)
  dbra    d7,loooop
  Bra     Print6301Data
Ascii
  Move.b  D0,D1
  And.b   #$F,D1
  Add.b   #'0',D1
  Cmp.b   #'9',D1
  Ble.s   Decimal
  Add.b   #'A'-'0'-10,D1
Decimal
  Lsr.w   #4,D0
  Rts
Vbl
  Move.w  #$2700,SR
  Movem.l D0/A0,-(A7)
Transmit
  Btst    #1,$FFFFFC00.w
  Beq     Transmit
  Move.b  #4,$FFFFFC02.w
  Lea     Data6301(A6),A0
  Moveq   #3,D0
Input6301
  Btst    #0,$FFFFFC00.w
  beq     Input6301
  Move.b  $FFFFFC02.w,(A0)+
  Dbra    D0,Input6301
  Movem.l (A7)+,D0/A0
  Rte

* Donn‚es

DataOffset Equ *
Home      Equ (*-DataOffset)
  Dc.b    $1B,'H',0
Hexa      Equ (*-DataOffset)
  Dc.b    0,0,$A,$D,0
Data6301 Equ (*-DataOffset)
  Ds.b    20
PauseOutput Equ (*-DataOffset)
  Dc.b    $13
PauseOutputLen Equ (*-DataOffset)-PauseOutput
ControllerExecute Equ (*-DataOffset)
  Dc.b    $22,$00,$B1
ControllerExecuteLen Equ (*-DataOffset)-ControllerExecute
Boot      Equ (*-DataOffset)
  Dc.b $20,$00,$B0,$0B
  Dc.b $B9+LoaderLen          *B0
  Dc.b $0F                    *B1       sei
  Dc.b $9E,$AF                *B2       ldS  $AF
  Dc.b $DC,$11                *B4 Ready ldD  $11
  Dc.b $2A,$FC                *B6       bpl  Ready
  Dc.b $37                    *B8       pshB
  Dc.b $20,$F9                *B9       bra  Ready
BootLen Equ (*-DataOffset)-Boot
Loader Equ (*-DataOffset)
  Dc.b $00                    *BA       dc.b $0
  Dc.b $DC,$B4                *BB       ldD  $B4
  Dc.b $DD,$80                *BD       stD  $80
  Dc.b $DC,$B6                *BF       ldD  $B6
  Dc.b $DD,$82                *C1       stD  $82
  Dc.b $DC,$B8                *C3       ldD  $B8
  Dc.b $DD,$84                *C5       stD  $84
  Dc.b $86,$F9                *C7       ldaA #$F9
  Dc.b $97,$86                *C9       staA $86
  Dc.b $CC,$00,$01            *CB       ldD  #$1
  Dc.b $DD,$00                *CE       stD  $0
  Dc.b $43                    *D0       notA
  Dc.b $53                    *D1       notB
  Dc.b $97,$04                *D3       staA $4
  Dc.b $54                    *D4       lsrB
  Dc.b $DD,$06                *D5       stD  $6
  Dc.b $86,$40                *D7       ldaA #$40
  Dc.b $DD,$0B                *D9       stD  $B
  Dc.b $8E,$00,ProgramLen+$85 *DB       ldS #$85+ProgramLen
  Dc.b $7E,$00,$80            *DE       jmp  $80
LoaderLen Equ (*-DataOffset)-Loader
Program Equ (*-DataOffset)
  Dc.b $0D
  Dc.b $FF,$FF,$FF,$FF
  Dc.b $FF,$FF,$FF,$FF
  Dc.b $FF,$FF,$FF,$FF
  Dc.b $FF
  Dc.b $8E,$00,$82 *Ikbd   ldS     #JoyPort
  Dc.b $33         *       pulB
  Dc.b $5A         *KeySca decB
  Dc.b $2A,$26     *       bpl     Key
  Dc.b $D7,$03     *       staB    $3
  Dc.b $D7,$05     *       staB    $5
  Dc.b $DC,$0B     *       ldd     KeyBit
  Dc.b $48         *       lslA
  Dc.b $89,$00     *       adcA    #0
  Dc.b $5C         *       incB
  Dc.b $2A,$02     *       bpl     Ok
  Dc.b $30         *       tSX
  Dc.b $5F         *       clrB
  Dc.b $DD,$0B     *Ok     stD     KeyBit
  Dc.b $2A,$08     *       bpl     GetKey
  Dc.b $09         *       dex
  Dc.b $DC,$06     *       ldD     $6
  Dc.b $05         *       lslD
  Dc.b $C9,$00     *       adcB    #0
  Dc.b $DD,$06     *       stD     $6
  Dc.b $E6,$10     *GetKey ldaB    X,$10
  Dc.b $D8,$02     *       eorB    $2
  Dc.b $D4,$0B     *       andB    KeyBit
  Dc.b $27,$06     *       beq     Mouse
  Dc.b $E8,$10     *       eorB    X,$10
  Dc.b $E7,$10     *       staB    X,$10
  Dc.b $D6,$0C     *Key    ldaB    KeyNumber
  Dc.b $37         *Mouse  pshB
  Dc.b $5F         *       clrB
  Dc.b $D7,$03     *       staB    $3
  Dc.b $D7,$05     *       staB    $5
  Dc.b $86,$00     *       ldaA    #0
  Dc.b $16         *       tAB
  Dc.b $C4,$0A     *       andB    #$A
  Dc.b $10         *       sBA
  Dc.b $48         *       lslA
  Dc.b $54         *       lsrB
  Dc.b $1B         *       aBA
  Dc.b $D6,$07     *       ldaB    $7
  Dc.b $D7,$CA     *       staB    MousePort
  Dc.b $98,$CA     *       eorA    MousePort
  Dc.b $C4,$F0     *       andB    #$F0
  Dc.b $D8,$03     *       eorB    $3
  Dc.b $37         *       pshB
  Dc.b $34         *       deS
  Dc.b $33         *       pulB
  Dc.b $44         *       lsrA
  Dc.b $C2,$00     *       sbcB    #0
  Dc.b $44         *       lsrA
  Dc.b $C9,$00     *       adcB    #0
  Dc.b $37         *       pshB
  Dc.b $34         *       deS
  Dc.b $33         *       pulB
  Dc.b $44         *       lsrA
  Dc.b $C2,$00     *       sbcB    #0
  Dc.b $44         *       lsrA
  Dc.b $C9,$00     *       adcb    #0
  Dc.b $37         *       pshB
  Dc.b $DC,$11     *       ldD     $11
  Dc.b $2A,$A1     *       bpl     Ikbd
  Dc.b $7B,$20,$11 *Wait   bit     #$20,$11
  Dc.b $27,$FB     *       beq     Wait
  Dc.b $32         *       pulA
  Dc.b $97,$13     *       staA    $13
  Dc.b $5A         *       decB
  Dc.b $26,$F5     *       bne     Wait
  Dc.b $20,$98     *       bra     KeyScan
ProgramLen Equ (*-DataOffset)-Program

