;*********************************
;* Include fuer Falcon SSI-Port  *
;*********************************
		
			org p:$000c
			jsr datain
			
			org p:$0010
			jsr dataout
			
			org x:$0
			
in_l        dc 1		;Eingangsdaten linker Kanal
in_ls       dc 1
in_r        dc 1		;Eingangsdaten rechter Kanal
in_rs       dc 1
out_l       dc 1   	;Ausgangsdaten linker Kanal
out_r       dc 1   	;Ausgangsdaten rechter Kanal
temp        dc 1   	;X0-Save
temp1       dc 1    ;X1-Save
inflag      dc 1   	;links oder rechs lesen
outflag     dc 1   	;links oder rechts schreiben
sync				dc 0   	;Bit 0=1 -> Daten angekommen

					org	p:$40

init			MOVEP #$4100,X:$FFEC	;SSI Control-A
					MOVEP #$01F8,X:$FFE1	;Port C auf SSI schalten
					MOVEP #$F800,x:$FFED  ;SSI Control-B
          MOVEP X:$FFEB,X0
	        BTST  #4,X:$FFEE
		    	MOVEP #$000001,X:$FFE0
          MOVEP #$3000,X:$FFFF	;Interrupt-Priority
					ANDI  #$FC,MR					;Interrupts freigeben
					RTS
			
datain		BSET  #0,X:sync			;Daten werden empfangen		
					MOVE  x0,x:temp
					MOVE  x1,X:temp1
					JCLR  #0,X:inflag,do_lin
do_rin  	move  x:in_r,x1
          move  x1,x:in_rs
          MOVEP X:$FFEF,X1		;Daten vom SSI
					MOVE  X1,X:in_r
					BCLR  #0,X:inflag	
					MOVE  x:temp,x0
					MOVE  X:temp1,X1
					RTI
			
do_lin		move  x:in_l,x1
          move  x1,x:in_ls
          MOVEP X:$FFEF,X0		;Daten vom SSI
					MOVE  X0,X:in_l
					BSET  #0,X:inflag	
					MOVE  x:temp,x0
					MOVE  x:temp1,X1
					RTI

dataout		BSET  #1,x:sync			;Daten werden gesendet
					MOVE  X0,X:temp
					MOVE  X1,X:temp1
					JCLR  #0,X:outflag,do_lout
do_rout		MOVE  X:out_r,X1
					MOVEP X1,X:$FFEF		;Daten zum SSI
					BCLR  #0,X:outflag	
					MOVE  x0,x:temp
					MOVE  X:temp1,X1
					RTI
			
do_lout  	MOVE  X:out_l,X0
					MOVEP X0,X:$FFEF		;Daten zum SSI
					BSET  #0,X:outflag	
					MOVE  x:temp,x0
					MOVE  X:temp1,X1
					RTI

