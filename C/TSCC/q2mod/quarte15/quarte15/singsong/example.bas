rem $option K10
library "gemdos"
DEF SEG 0
defint i
deflng l

REM	FIRST ALLOCATE SPACE FOR BOTH SONG AND VOICESET
lsong&=fnmalloc&(10000)
lvoice&=fnmalloc&(200000)

REM POKE IN BODGE CODE CAUSE HISOFTS PEXEC DOESN'T WORK
for l&=lsong to lsong+56 step 2
	read i%
	pokew l,i%
	print hex$(peekw(l-2)),
	next l
print
print lsong&
call loc lsong&
lprog& = peekl(lsong+34)
REM	LPROG IS NOW SET UP AS BELOW
REM lprog&=fnpexec%(3,"a:\singsong.prg","","")

REM DISPLAY THE ADRESSES SO I NO IF IT'S GOING TO WORK
print lsong&,lvoice&,hex$(lprog&)

REM LOAD IN THE SONG AND THE VOICESET
bload "A:\DEMO1.4V",lsong
bload "A:\VOICE.SET",lvoice

REM SET UP POINTER TO SONG
pokel lprog+256+12,lsong

REM SET UP POINTER TO VOICESET
pokel lprog+256+16,lvoice

REM CALL PLAY BACK ROUTINE
call loc lprog+256


REM DATA FOR PEXEC CODE
DATA	&H487A,&H0034
DATA	&H487A,&H0030
DATA	&H487A,&H001F
DATA	&H3F3C,&H0003
DATA	&H3F3C,&H004B
DATA	&H4E41
DATA	&HDEFC,&H0010
DATA	&H41fa,&H0006
DATA	&H2080
DATA	&H4E75

REM	RETURN = OFFSET($20)
DATA	&H0000,&H0000
REM FILENAME = 'SINGSONG.PRG',0,0
DATA	&H0000,&H0053,&H494e,&H4753,&H4f4e,&H472E,&H5052,&H4700
REM	NULL
DATA	&H0000,&H0000	

