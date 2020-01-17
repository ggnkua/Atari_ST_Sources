* Ballsitix disk dumping using the games own code
* This is the easy rider disassembled Ballistix bootsector loads 8 sectors to $30000
* We have to change a few things in order for the game sector loadng code for us to dump the whole disk.


dest=$80000

	lea	Begin,a0
	lea	dest,a1
	move.l	#ZUEND-Begin,d0
reloc	move.b	(a0)+,(a1)+
	dbf	d0,reloc

	move.w	#$4e75,loader2	* RTS

	jsr	loader1

	clr.w	-(a7)
	trap	#1


Begin:
      JMP	L0000
      DC.B      'psyclaps.dat',$00,$00
      DC.B      'TEXTLOGO.DAT',$00,$00
      DC.B      'AN ST GAME BY'
      DC.B      '*  GAME'
      DC.B      ' CONCEPT'
      DC.B      '   24444'
      DC.B      '44444444'
      DC.B      '44444MAR'
      DC.B      'TIN  EDM'
      DC.B      'ONDSON22'
      DC.B      '24444444'
      DC.B      '44444444'
      DC.B      '44 ST PR'
      DC.B      'OGRAMMIN'
      DC.B      'G2444444'
      DC.B      '44444444'
      DC.B      '4NICK CH'
      DC.B      'AMBERLAI'
      DC.B      'N2444444'
      DC.B      '44444444'
      DC.B      'PAUL HOW'
      DC.B      'ARTH2244'
      DC.B      '44444444'
      DC.B      '44444GRA'
      DC.B      'PHICS AN'
      DC.B      'D SOUND2'
      DC.B      '44444444'
      DC.B      '44444444'
      DC.B      '4MARTIN '
      DC.B      'EDMONDSO'
      DC.B      'N2244444'
      DC.B      '44444444'
      DC.B      'ADDITION'
      DC.B      'AL244444'
      DC.B      '4444GRAP'
      DC.B      'HICS2444'
      DC.B      '44444444'
      DC.B      '44444444'
      DC.B      '44444444'
      DC.B      '4444TONY'
      DC.B      ' EDMONDS'
      DC.B      'ON*  PRE'
      DC.B      'PARE TO '
      DC.B      'PLAY*',$00,$00,$00 
      DS.W      16
      DC.B      $05,'C',$04,'2',$03,' ',$04,'D' 
      DC.B      $03,'3',$02,'"',$07,$00,$02,$10 
      DC.B      $02,$13,$02,'#',$03,'4',$04,'E' 
      DC.B      $05,'V',$06,'g',$07,'w',$00,$00 
      DS.W      6 
      DC.B      $01,$00,$01,$00,$00,$00,$00,$00 
      DS.W      4 
      DC.B      $01,$11,$00,$00,$01,$00,$00,$00 
      DS.W      4 
      DC.B      $02,$00,$02,$00,$01,$00,$00,$00 
      DS.W      3 
      DC.B      $01,$11,$02,'"',$00,$00,$02,$00 
      DC.B      $01,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$03,$00,$03,$00,$02,$00 
      DS.W      3 
      DC.B      $01,$11,$02,'"',$03,'3',$00,$00 
      DC.B      $03,$10,$02,$00,$01,$00,$00,$00 
      DC.B      $00,$00,$01,$00,$04,$00,$04,$00 
      DC.B      $03,$00,$00,$00,$00,$00,$01,$11 
      DC.B      $02,'"',$03,'3',$04,'D',$00,$00 
      DC.B      $04,'!',$03,$10,$02,$00,$01,$00 
      DC.B      $00,$00,$02,$00,$05,$00,$05,$11 
      DC.B      $04,$00,$00,$00,$01,$11,$02,'"' 
      DC.B      $03,'3',$04,'D',$05,'U',$00,$00 
      DC.B      $05,'2',$04,'!',$03,$10,$02,$00 
      DC.B      $01,$00,$03,$00,$06,$00,$06,'"' 
      DC.B      $05,$00,$01,$11,$02,'"',$03,'3' 
      DC.B      $04,'D',$05,'U',$06,'f',$00,$00 
      DC.B      $06,'C',$05,'2',$04,'!',$03,$10 
      DC.B      $02,$00,$04,$00,$07,$00,$07,'3' 
      DC.B      $06,$00,$02,'"',$03,'3',$04,'D' 
      DC.B      $05,'U',$06,'f',$07,'w',$00,$00 
      DC.B      $02,'"',$03,'3',$04,'D',$05,'U' 
      DC.B      $02,$10,$03,'!',$04,'2',$05,'C' 
      DC.B      $06,'T',$02,'#',$03,'4',$04,'E' 
      DC.B      $05,'V',$06,'g',$07,'w',$00,$00 
      DC.B      $01,$11,$02,'"',$03,'3',$04,'D' 
      DC.B      $01,$00,$02,$10,$03,'!',$04,'2' 
      DC.B      $05,'C',$01,$12,$02,'#',$03,'4' 
      DC.B      $04,'E',$05,'V',$06,'f',$00,$00 
      DC.B      $00,$00,$01,$11,$02,'"',$03,'3' 
      DC.B      $00,$00,$01,$00,$02,$10,$03,'!' 
      DC.B      $04,'2',$01,$01,$01,$12,$02,'#' 
      DC.B      $03,'4',$04,'E',$05,'U',$00,$00 
      DS.W      2 
      DC.B      $01,$11,$02,'"',$00,$00,$00,$00 
      DC.B      $01,$00,$02,$10,$03,'!',$00,$00 
      DC.B      $00,$01,$01,$12,$02,'#',$03,'4' 
      DC.B      $04,'D',$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00,$01,$11,$00,$00,$00,$00 
      DC.B      $00,$00,$01,$00,$02,$10,$00,$00 
      DC.B      $00,$00,$00,$01,$01,$12,$02,'#' 
      DC.B      $03,'3',$00,$00,$00,$00,$00,$00 
      DS.W      6 
      DC.B      $01,$00,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$01,$01,$12,$02,'"',$00,$00 
      DS.W      3 
      DC.B      $00,$10,$00,$00,$00,$00,$00,$00 
      DS.W      6 
      DC.B      $00,$01,$01,$11,$00,$00,$04,'D' 
      DC.B      $05,'U',$02,$12,$03,'#',$04,'4' 
      DC.B      $05,'E',$06,'V',$07,'g',$07,$00 
      DC.B      $07,'#',$07,'4',$07,'E',$07,'V' 
      DC.B      $03,'3',$07,'w',$00,$00,$03,'3' 
      DC.B      $04,'D',$01,$01,$02,$12,$03,'#' 
      DC.B      $04,'4',$05,'E',$06,'V',$06,$00 
      DC.B      $06,$12,$06,'#',$06,'4',$06,'E' 
      DC.B      $02,'"',$06,'f',$00,$00,$02,'"' 
      DC.B      $03,'3',$00,$00,$01,$01,$02,$12 
      DC.B      $03,'#',$04,'4',$05,'E',$05,$00 
      DC.B      $05,$01,$05,$12,$05,'#',$05,'4' 
      DC.B      $01,$11,$05,'U',$00,$00,$01,$11 
      DC.B      $02,'"',$00,$00,$00,$00,$01,$01 
      DC.B      $02,$12,$03,'#',$04,'4',$04,$00 
      DC.B      $04,$00,$04,$01,$04,$12,$04,'#' 
      DC.B      $00,$00,$04,'D',$00,$00,$00,$00 
      DC.B      $01,$11,$00,$00,$00,$00,$00,$00 
      DC.B      $01,$01,$02,$12,$03,'#',$03,$00 
      DC.B      $03,$00,$03,$00,$03,$01,$03,$12 
      DC.B      $00,$00,$03,'3',$00,$00,$00,$00 
      DS.W      5 
      DC.B      $01,$01,$02,$12,$02,$00,$02,$00 
      DC.B      $02,$00,$02,$00,$02,$01,$00,$00 
      DC.B      $02,'"',$00,$00,$00,$00,$00,$00 
      DS.W      5 
      DC.B      $01,$01,$01,$00,$01,$00,$01,$00 
      DC.B      $01,$00,$01,$00,$00,$00,$01,$11 
      MOVE.L    #0,$683F8 
      MOVE.L    #$79C30,$683FC
      JSR       $306C4
      MOVEA.L   #$69AD0,A2
      MOVEA.L   #$7C118,A3
      MOVE.L    #$D,D4
      MOVE.L    #$35,D5 
      JSR       $30C28
      RTS 

L0000:CMPI.W    #$6589,D0 
      BNE       L0000 
      CMPI.W    #$7801,D2 
      BNE       L0000 
      MOVEA.L   #$80000,A7
      MOVE.W    #0,-(A7)
      MOVE.L    #$78000,-(A7) 
      MOVE.L    #$78000,-(A7) 
      MOVE.W    #5,-(A7)
      TRAP      #$E 
      ADDA.L    #$C,A7
      CMPI.W    #$1206,D3 
      BNE       L0000 
      JSR       $30B56
      LEA       $12000,A0 
L0001:MOVE.L    #0,(A0)+
      CMPA.L    #$2F000,A0
      BLT       L0001 
      LEA       $40000,A0 
L0002:MOVE.L    #0,(A0)+
      CMPA.L    #$7FD00,A0
      BLT       L0002 

loader1	JSR       $80B66
loader2	JSR       $30B80

      JSR       $305E6
      JSR       $3060C
      JSR       $30632
      JSR       $30A46
      JSR       $307A4
      JSR       $307A4
      JSR       $307A4
      JSR       $30ACE
      JSR       $30B56
      JSR       $30BDE
      JSR       $307BE
      CMPI.L    #$67934691,$2F500 
      BNE       L0000 
      JSR       $30454
      MOVE.L    #$E,$683F8
      JSR       $30936
      JSR       $307A4
      JSR       $307A4
      JSR       $307A4
      JSR       $309BE
      JSR       $30BDE
      JSR       $307BE
      JSR       $30B56
      JSR       $30786
      JSR       $30B9A
      JSR       $30BDE
      JSR       $309AE
      JSR       $306B2
      MOVE.L    #$51400,D7
      JSR       $307D8
      JSR       $30B56
      JSR       $30786
      JSR       $30662
      JSR       $309AE
      JSR       $307A4
      JMP       $30C8A
      RTS 
      LEA       $58000,A0 
      LEA       $79B88,A1 
      MOVE.W    #$22,D1 
L0003:MOVE.W    #$25,D0 
L0004:MOVE.L    (A0)+,(A1)+ 
      DBF       D0,L0004
      ADDA.L    #8,A1 
      DBF       D1,L0003
      RTS 
      LEA       $59C38,A0 
      LEA       $7CEE8,A1 
      MOVE.W    #$16,D1 
L0005:MOVE.W    #$15,D0 
L0006:MOVE.L    (A0)+,(A1)+ 
      DBF       D0,L0006
      ADDA.L    #$48,A1 
      DBF       D1,L0005
      RTS 
      LEA       $594C8,A0 
      LEA       $7B1A0,A1 
      MOVE.W    #$21,D1 
L0007:MOVE.W    #$D,D0
L0008:MOVE.L    (A0)+,(A1)+ 
      DBF       D0,L0008
      ADDA.L    #$68,A1 
      DBF       D1,L0007
      RTS 
      DC.B      'load.dat'
      DC.B      $00,$00 
      MOVEA.L   #$6B058,A2
      MOVEA.L   #$7A810,A3
      MOVE.L    #$11,D4 
      MOVE.L    #$32,D5 
      JSR       $30C28
      RTS 
      MOVE.L    #$7B200,$683FC
      JSR       $306C4
      JSR       $30936
      JSR       $307A4
      JSR       $309BE
      JSR       $30BDE
      JSR       $309AE
      RTS 
      MOVE.L    #$41A08,$683FC
      JSR       $306C4
      RTS 
L0009:CLR.L     D6
      MOVE.L    $683F8,D7 
      LEA       $30022,A0 
      MOVE.B    0(A0,D7.L),D6 
      ADDI.L    #1,D7 
      MOVE.L    D7,$683F8 
      CMPI.B    #$2A,D6 
      BEQ       L000A 
      ADDI.L    #8,$683FC 
      JSR       $3070C
      MOVEA.L   $683FC,A3 
      JSR       $30772
      BRA       L0009 
L000A:RTS 
      CMPI.B    #$20,D6 
      BNE       L000B 
      MOVEA.L   #$69A40,A2
      RTS 
L000B:CMPI.B    #$32,D6 
      BNE       L000C 
      MOVE.L    $683FC,D1 
      ADDI.L    #$1038,D1 
      MOVE.L    D1,$683FC 
      MOVEA.L   #$69A40,A2
      RTS 
L000C:CMPI.B    #$34,D6 
      BNE       L000D 
      MOVE.L    $683FC,D1 
      SUBI.L    #$10,D1 
      MOVE.L    D1,$683FC 
      MOVEA.L   #$69A40,A2
      RTS 
L000D:SUBI.B    #$41,D6 
      MULU      #$90,D6 
      ADDI.L    #$68600,D6
      MOVEA.L   D6,A2 
      RTS 
      MOVE.L    #1,D4 
      MOVE.L    #$12,D5 
      JSR       $30C28
      RTS 
      MOVE.W    #-1,-(A7) 
      MOVE.L    #$78000,-(A7) 
      MOVE.L    #$70000,-(A7) 
      MOVE.W    #5,-(A7)
      TRAP      #$E 
      ADDA.L    #$C,A7
      RTS 
      CLR.L     D7
L000E:JSR       $30BFC
      ADDI.L    #1,D7 
      CMPI.L    #$3C,D7 
      BNE       L000E 
      RTS 
      CLR.L     D7
L000F:JSR       $30BFC
      ADDI.L    #1,D7 
      CMPI.L    #$19,D7 
      BNE       L000F 
      RTS 
      MOVE.L    #$78500,D5
      MOVE.L    #$70800,D3
      MOVEA.L   #$39D00,A2
      JSR       $30874
      MOVEA.L   D5,A3 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
L0010:MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      JSR       $30880
L0011:MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      CMPA.L    D4,A3 
      BNE       L0011 
      SUBA.L    #$7260,A2 
      JSR       $30874
      MOVEA.L   D5,A3 
      CMPA.L    D7,A2 
      BNE       L0010 
      RTS 
      EXG       D3,D5 
      MOVE.L    D5,D4 
      ADDI.L    #$7300,D4 
      RTS 
      MOVE.L    D5,D2 
      SUBI.L    #$500,D2
      MOVE.W    #-1,-(A7) 
      MOVE.L    D2,-(A7)
      MOVE.L    #$70000,-(A7) 
      MOVE.W    #5,-(A7)
      TRAP      #$E 
      ADDA.L    #$C,A7
      RTS 
      MOVE.L    #$30274,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30254,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30234,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30214,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$301F4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$301D4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$301B4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      JSR       $30B56
      RTS 
      MOVE.L    #$30354,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30334,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30314,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$302F4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$302D4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$302B4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30294,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      RTS 
      MOVE.L    #$30294,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$302B4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$302D4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$302F4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30314,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30334,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30354,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      RTS 
      MOVE.L    #$30434,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30414,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$303F4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$303D4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$303B4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30394,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30374,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      RTS 
      MOVE.L    #$30374,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30394,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$303B4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$303D4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$303F4,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30414,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30C06
      MOVE.L    #$30434,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      RTS 
      MOVE.L    #$30174,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      RTS 

* here we change the start track and number of sectors to load
* so we can dump the whole disk
* a5 is the buffer address on entry
* and a5 is the end address when finished
* stick a breakpoint here and dump the disk when finished loading
* save the file from $90000 to A5-1

      MOVE.W    #0,D0 		* track
      MOVE.W    #1,D1 		* sector
      MOVE.W    #790,D2		* all sectors
      LEA       $90000,a5	* our buffer
      JSR       $80F0E		* sector loader
      RTS 

      LEA       $58000,A5 	
      MOVE.W    #4,D0 
      MOVE.W    #6,D1 
      MOVE.W    #$13,D2 
      JSR       $30F0E		* sector loader
      RTS 

      LEA       $34234,A0 
      SUBA.L    #$4000,A0 
      MOVE.W    #$14,D0 
      ASL.W     #2,D0 
      SUBA.W    D0,A0 
      SUBA.L    #$238,A0
      MOVE.W    #$2210,D0 
      MOVE.W    #4,D1 
      ADD.W     D1,D0 
      MOVE.W    D0,(A0) 
      LEA       $39800,A3 
L0012:MOVE.L    #0,(A3)+
      MOVE.L    #0,(A3)+
      CMPA.L    #$60900,A3
      BLE       L0012 
      RTS 
      LEA       $70300,A3 
L0013:MOVE.L    #0,(A3)+
      MOVE.L    #0,(A3)+
      CMPA.L    #$7FD00,A3
      BLE       L0013 
      RTS 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      RTS 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      RTS 
      CLR.L     D2
      CLR.L     D3
      MOVE.L    A3,D7 
L0014:CLR.L     D2
L0015:MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      ADDQ.W    #1,D2 
      CMP.W     D2,D4 
      BNE       L0015 
      ADDQ.W    #1,D3 
      ADDI.L    #$A0,D7 
      MOVEA.L   D7,A3 
      CMP.W     D5,D3 
      BNE       L0014 
      RTS 
      MOVEA.L   #$80000,A7
      MOVE.L    #0,-(A7)
      MOVE.L    #0,-(A7)
      MOVE.L    #0,-(A7)
      TRAP      #$E 
      ADDA.L    #$C,A7
      MOVE.W    #0,-(A7)
      MOVE.L    #-1,-(A7) 
      MOVE.L    #-1,-(A7) 
      MOVE.W    #5,-(A7)
      TRAP      #$E 
      ADDA.L    #$C,A7
      JSR       $30D28
maingame
	MOVE.W    #$C,D0
       	MOVE.W    #8,D1 
        MOVE.W    #$5C,D2 
        MOVEA.L   #$9f000,A5 
        JSR       $80F0E
mainend MOVE.W    #1,D0 
      JSR       $1582A
      MOVE.W    #1,D0 
      JMP       $15800

      DC.B      'game.dat'
      DC.B      $00,$00,'ricoch'
      DC.B      'et.NEO',$00,$00
      DC.B      $00,$A0,$03,$C0,$02,$80,$01,$E0 
      DC.B      $01,$E0,$01,'@',$01,'@',$01,'@' 
      DC.B      $00,$A0,$00,$A0,$00,$A0,$00,$A0 
      DC.B      $00,$A0,$00,$A0,$00,$A0,$00,$A0 
      DC.B      $00,$A0,$00,$A0,$00,$A0,$00,$A0 
      DC.B      $00,$A0,$00,$A0,$00,$A0,$00,$A0 
      DC.B      $00,$A0,$00,$A0,$00,$A0,$00,$A0 
      DC.B      $00,$A0,$00,$A0,$00,$A0,$00,$A0 
      DC.B      $00,$A0,$00,$A0,$01,'@',$01,'@' 
      DC.B      $01,'@',$01,$E0,$01,$E0,$02,$80 
      DC.B      $03,$C0,$00,$A0 
      JSR       $30D84
      JMP       $30D54
      DC.B      $00,$00,$02,'1',$01,'!',$05,$00 
      DC.B      $02,'"',$06,'f',$03,'3',$02,'!' 
      DC.B      $03,'2',$04,'C',$05,'T',$03,'B' 
      DC.B      $06,'e',$04,'D',$05,'U',$03,'E' 
      MOVE.W    #$3E7F,D0 
      LEA       $70300,A0 
L0016:MOVE.L    #0,(A0)+
      DBF       D0,L0016
      MOVE.L    #$30D34,-(A7) 
      MOVE.W    #6,-(A7)
      TRAP      #$E 
      ADDQ.L    #6,A7 
      JSR       $30DA2
      JSR       $30DCA
      RTS 
      MOVE.W    #6,D0 
      MOVE.W    #5,D1 
      MOVE.W    #$3F,D2 
      LEA       $58000,A5 
      JSR       $30F0E
      JSR       $30ED8
      MOVEA.L   #$66C60,A2
      MOVEA.L   #$76660,A3
      MOVE.L    #$66C60,D2
      MOVE.L    #$76660,D3
      MOVE.L    #$6B1C0,D5
      MOVEA.L   #0,A4 
      CLR.L     D7
      RTS 
L0017:JSR       $30E42
      JSR       $30DF0
      CLR.L     D7
      JSR       $30DFC
      JSR       $30E2E
      CMPI.L    #$7FD00,D3
      BNE       L0017 
      RTS 
      MOVEA.L   D2,A2 
      MOVEA.L   D3,A3 
      JSR       $30E4C
      RTS 
L0018:LEA       $30CD4,A4 
      ADDI.L    #2,D7 
      MOVE.W    0(A4,D7.L),D6 
      SUB.L     D6,D5 
      MOVEA.L   D5,A2 
      ADDA.L    #$A0,A3 
      JSR       $30E4C
      CMPI.L    #$50,D7 
      BNE       L0018 
      ADDI.L    #$2BC0,D5 
      RTS 
      DC.B      $06,$82,$00,$00,$00,$A0,$06,$83 
      DC.B      $00,$00,$00,$A0,$06,$85,$00,$00 
      DC.B      $00,$A0 
      RTS 
      MOVE.W    #$25,-(A7)
      TRAP      #$E 
      ADDQ.L    #2,A7 
      RTS 
      CMPA.L    #$7FC60,A3
      BGT       L0019 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
      MOVE.L    (A2)+,(A3)+ 
L0019:SUBA.L    #$A0,A2 
      SUBA.L    #$A0,A3 
      RTS 
      MOVE.W    #$2000,D0 
      LEA       $16000,A0 
L001A:MOVE.W    (A0),D4 
      MOVE.W    $38000,D6 
      EOR.W     D6,D4 
      MOVE.W    $38002,D6 
      EOR.W     D6,D4 
      MOVE.W    D4,(A0)+
      DBF       D0,L001A
      RTS 
      LEA       $68600,A1 
      LEA       $58000,A0 
L001B:MOVE.B    (A0)+,D0
      CMPI.B    #-1,D0
      BEQ       L001C 
      MOVE.B    D0,(A1)+
      JMP       $80F02		* relocation change
L001C:CLR.L     D1
      MOVE.B    (A0)+,D1
L001D:MOVE.B    D0,(A1)+
      SUBQ.W    #1,D1 
      BNE       L001D 
      CMPA.L    #$70300,A1
      BLT       L001B 
      RTS 

L001E:JSR       $80F1E	* changed here when we relocate to $80000
      CMPI.W    #0,D2 
      BNE       L001E 
      RTS 

      MOVE.W    #$B,D7
      SUB.W     D1,D7 
      MOVE.W    D0,D5 
      MOVE.W    D1,D6 
      CMP.W     D7,D2 
      BGE       L001F 
      MOVE.W    D2,D7 
L001F:SUB.W     D7,D2 
      MOVE.W    D7,D4 
      JSR       $80F4C	* changed to relocation to $80000
      ASL.W     #7,D7 
      ASL.W     #2,D7 
      CLR.L     D6
      MOVE.W    D7,D6 
      ADDA.L    D6,A5 
      ADDQ.W    #1,D0 
      MOVE.W    #1,D1 
      RTS 

      MOVEM.W   D0-D2,-(A7) * floprd
      MOVE.W    D4,-(A7)
      MOVE.W    #0,-(A7)
      MOVE.W    D5,-(A7)
      MOVE.W    D6,-(A7)
      MOVE.W    #0,-(A7)
      MOVE.L    #0,-(A7)
      MOVE.L    A5,-(A7)
      MOVE.W    #8,-(A7)
      TRAP      #$E 
      ADDA.L    #$14,A7 
      MOVEM.W   (A7)+,D0-D2 
      RTS 

      DC.B      '?<',$00,$09,'?<',$00,$00 
      DC.B      '?<',$00,$00,'?<',$00,$02 
      DC.B      '?<',$00,$00,'/<',$00,$00 
      DC.B      $00,$00,'/<',$00,$03,$00,$00
      DC.B      '?<',$00,$09,'NN',$DF,$FC 
      DC.B      $00,$00,$00,$14,'J',$FC,$00,$00 
      DC.B      $00,$00 
ZUEND
	bss
