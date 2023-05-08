;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Load & Run - Wgrywanie i uruchamianie programu		  	  |
;|  																	  |
;| autor: Van Eijik		    											  |
;| uwagi: Procedura load moze byc uzyta osobna, tak samo jak i procedura  |
;|        relokujaca program.											  |
;*------------------------------------------------------------------------*

LOAD:			move.l	#FILENAME1,FILENAME
				move.l 	#DTA,-(sp)		* bufor danych
				move.w 	#$1a,-(sp)
				trap 	#1
				addq.l 	#6,sp
				move.w 	#0,-(sp)		* sprawdzenie czy plik istnieje
				move.l 	FILENAME,-(sp)	
				move.w 	#$4e,-(sp)
				trap 	#1
				add.l	#8,sp
				tst 	d0
				bne 	ERROR
				move.w 	#2,-(sp)		* otworzenie pliku
				move.l 	#DTA+30,-(sp)
				move.w 	#$3d,-(sp)
				trap 	#1
				addq.l 	#8,sp
				tst.w 	d0
				bmi 	ERROR
				move.w 	d0,HANDLE		* wgrywanie pliku
				move.l 	#DATA,-(sp)
				move.l 	#1000000,-(sp)
				move.w 	HANDLE,d0
				move.w 	d0,-(sp)
				move.w 	#$3f,-(sp)
				trap 	#1
				add.l 	#12,sp
				tst.l 	d0
				bmi 	ERROR

				jsr		RELOKUJ
	
				jmp		DATA

*-+---------------------------------------------------------------------+-*

ERROR:			clr.l	-(sp)
				trap	#1
				rts
HANDLE:			ds.w 1
				even
FILENAME:		dc.l	1
				even
FILENAME1:		dc.b 	'a:\artykuly.prg',0
				even
DTA:			ds.b 	44
				even
STARY:			dc.l	1
				even

*-+---------------------------------------------------------------------+-*

RELOKUJ:		MOVE.L  #DATA,A0    Start of HEADER 
				MOVE.L  2(A0),D0      Length of PROGRAM 
				ADD.L   6(A0),D0      
				ADD.L   14(A0),D0     Length of SYMBOL TABLE
				ADD.L   #$1C,A0       A0 Points to programs start adress
				MOVE.L  A0,A1         
				MOVE.L  A1,A2         
				MOVE.L  #DATA+$1c,D1    This is the adress we relocate the program
				ADD.L   D0,A1         Get adress of RELOCATION TABLE
				MOVE.L  (A1)+,D0      Get the Long Word
				ADD.L   D0,A2         
				ADD.L   D1,(A2)       Relocate it
				CLR.L   D0            
mRELO:			MOVE.B  (A1)+,D0      Get next byte from table
				BEQ     mRELEND        Is it the end (zero)
				CMP.B   #1,D0         1 is a 254 jump
				BEQ     mJUMP          If it is then do it
				ADD.L   D0,A2         If not find next absolute adress
				ADD.L   D1,(A2)       and relocate it
				BRA     mRELO          Continue until the zero is found
mJUMP:			ADD.L   #254,A2       Jump 254 bytes
				BRA     mRELO          and continue
mRELEND:		rts

*-+---------------------------------------------------------------------+-*

DATA:
