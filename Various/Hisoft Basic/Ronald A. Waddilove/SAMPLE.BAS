REM Play a Digisound sample
REM By R.A.Waddilove
REM $OPTION Y+

LIBRARY "GEMAES","GEMDOS"

dummy%=FNform_alert%(1,"[3][Digital sounds created| with Digisound from  |    Alpha Systems][Wow!]")
dummy%=FNform_alert%(1,"[3][Sounds played with portions|of software copyright Alpha|    Systems (c) 1987][Understood]")

DIM asm%(1500)		:' space for code
DIM sdata%(20000)	:' space for sample

pgm& = VARPTR(asm%(0))
BLOAD "basplay.exe",pgm&
pgm& = pgm& + 28

DO
	sample$ = FNfilename$		:'get sample filename
	start& = VARPTR(sdata%(0))	:'get start of sample buffer
	BLOAD sample$,start&		:'load sample data into buffer
	POKEL pgm&+6,start&			:'set start of sample data
	REM Length = size of sample file - 648 (envelope data)
	POKEL pgm&+10,15000			:'set sample length (not very important)
	REM Speed:  5k=7  8k=6  10k=5  16k=4  20k=3  25k=2  32k=1  40k=0
	speed%=3 + FNform_alert%(2,"[3][select replay speed][16k|10k|8k]")
	POKEL pgm&+14,speed%		:'set sample speed
	CALL LOC pgm&				:'play sample
	FOR i% = 0 TO 20000	STEP 4	:'clear sample buffer
		POKEL start&+i%,0
	NEXT
LOOP UNTIL FNform_alert%(1,"[3][Another one?][Yes|No]") = 2
SYSTEM

DEF FNfilename$
path$ = CHR$(65+FNdgetdrv%) + ":\*.SND"
ok% = 0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$ = LEFT$(path$,LEN(path$)-1)
WEND
FNfilename$ = path$+name$
END DEF
