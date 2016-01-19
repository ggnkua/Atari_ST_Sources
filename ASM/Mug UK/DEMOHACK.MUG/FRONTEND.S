;
; Frontend for programs - based on some hack by Zippy of TMB
; ----------------------------------------------------------
;
; Place packed program filename into incbin


start	jmp	reloc

program	incbin	'e:\pd_list.prg'
	even

reloc	CLR.L     -(A7) 
	MOVE.W    #$20,-(A7) 	;SUPER
	TRAP      #1
L0026	ADDQ.L    #6,A7 
	MOVE.L    D0,8.W		; store it somewhere safe !!

;	CLR.W     $FFFF8240.W 
;	MOVE.W    #$777,$FFFF825E.L 

	PEA       text(PC) 
	MOVE.W    #9,-(A7) 	;CCONWS 
	TRAP      #1
	ADDQ.L    #6,A7

	MOVE.W    #7,-(A7) 	;CRAWCIN
	TRAP      #1
	ADDQ.L    #2,A7 

	LEA       program,A0
	MOVEA.L   A0,A1
	SUBA.L    #$22,A1 

r_loop	MOVE.L    (A0)+,(A1)+ 
	CMPA.L    #reloc,a0 
	BLT.B     r_loop

	MOVE.L    8.W,-(A7) 
	MOVE.W    #$20,-(A7) 	;SUPER
	TRAP      #1
	ADDQ.L    #6,A7 

	JMP       start-$1c		; run original program

text  DC.B      27,'E',27,'f',27,'w'
      DC.B      '++++++++++++++++++++++++++++++++++++++++',10,13
      DC.B      '+                                      +',10,13
      DC.B      '+ The MEDWAY BOYS bring you:           +',10,13
      DC.B      '+                                      +',10,13
      DC.B      '+ HEAD OVER HEELS                      +',10,13
      DC.B      '+                                      +',10,13
      DC.B      '++++++++++++++++++++++++++++++++++++++++',10,13
      DC.B      '+                                      +',10,13
      DC.B      '+ Cracked and Packed by ZIPPY          +',10,13
      DC.B      '+ Original Supplied by GINO            +',10,13
      DC.B      '+                                      +',10,13
      DC.B      '++++++++++++++++++++++++++++++++++++++++',10,13
      DC.B      '+                                      +',10,13
      DC.B      '+ This will probably be my last ever   +',10,13
      DC.B      '+ work on the ST !!!!                  +',10,13
      DC.B      '+ First Vapour, now Zippy leave the ST +',10,13
      DC.B      '+ scene. I think R.AL is probably the  +',10,13
      DC.B      '+ best hacker left out there now.....  +',10,13
      DC.B      '+ so look to him for the best work !!  +',10,13
      DC.B      '+ Sorry I had to finish on such a crap +',10,13
      DC.B      '+ game, but I don',39,'t think there will   +',10,13 
      DC.B      '+ be anything decent out before I have +',10,13
      DC.B      '+ to start my new job on Monday !!     +',10,13
      DC.B      '+                                      +',10,13
      DC.B      '++++++++++++++++++++++++++++++++++++++++',0,0

