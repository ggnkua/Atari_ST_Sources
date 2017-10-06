DEFINT a-z
LIBRARY "WAVEPLAY","GEMAES","GEMDOS"
DIM SHARED junk,junk!,junk&,myprogram$

'$include f:\enchant\modules\samples.bas
'$option q100

' Original binding by Scott Sanders / SDS.
' Extra comments by Anthony Jacques / KPP.
' HiSoft BASIC conv.  by Paul Jones / PJCO

CONST WP_STEREO%=&h01
CONST WP_MONO%=&h00

CONST WP_8BIT%=&h00
CONST WP_16BIT%=&h02

' SAM can use AFM if installed
CONST WP_NOUSEDSP%=&h00
CONST WP_USEDSP%=&h04

' Falcon compatible frequencies
CONST ACT_CLK50K&=49170
CONST ACT_CLK33K&=33880
CONST ACT_CLK25K&=24585
CONST ACT_CLK20K&=20770
CONST ACT_CLK16K&=16490
CONST ACT_CLK12K&=12292
CONST ACT_CLK10K&=9834
CONST ACT_CLK8K&=8195

' STe/TT Rates
CONST TT_CLK50K&=50066
CONST TT_CLK25K&=25033
CONST TT_CLK12K&=12517
CONST TT_CLK6K&=6258    ' NOTE: this isn't valid on a Falcon

' both = 'SAM'+chr$(0)
CONST SAM_COOKIE&=&h53414D00
CONST APP_GLOBAL&=&h53414D00

' the 'application globals' used for system-wide sounds.
CONST AG_FIND%=0
CONST AG_REPLACE%=1
CONST AG_CUT%=2
CONST AG_COPY%=3
CONST AG_PASTE%=4
CONST AG_DELETE%=5
CONST AG_HELP%=6
CONST AG_PRINT%=7
CONST AG_SAVE%=8
CONST AG_ERROR%=9
CONST AG_QUIT%=10

' SAA cookie.
CONST GLOB&=&h474c4f42

' Application Macros
CONST START_APP%=0
CONST WIND_CYCLE%=1
CONST WIND_ARRANGE%=2
CONST CON_HELP%=3
CONST ICONISE%=4
CONST ICONISE_ALL%=5
CONST UNICONISE%=6
CONST INFO%=7
CONST SELECT_ALL%=8
CONST DESELECT_ALL%=9
CONST TOGGLE%=10
CONST CALL_FONTSEL%=11
CONST CALL_ASCII%=12
CONST CALL_COLOUR%=13


sam_present=GETCOOKIE ("SAM"+CHR$(0),junk&)
IF sam_present THEN
	result=SamplePlay ("G:\samples\alien.AVR",WP_MONO+WP_8BIT,16889,8)
	PRINT result
	result=SamplePlay ("G:\samples\alien.AVR",WP_MONO+WP_8BIT,ACT_CLK12K&,8)
	PRINT result
	EXIT IF

	PRINT "sam_cookie&=0"
	PRINT "app_gloal&=1"
	PRINT "glob&=2"
	INPUT "Choose Cookie";a
	IF a=0 THEN cookie&=sam_cookie&
	IF a=1 THEN cookie&=app_gloal&
	IF a=2 THEN cookie&=glob&

	FOR i=0 TO 10
'		junk=waveplayglobal (i) : PRINT i,junk
'		junk=WavePlayMacro (cookie&,i) : PRINT i,junk
'		junk=WavePlayMacro ("GLOB",i) : PRINT i,junk
'		junk=WavePlayMacro ("EHCT",i) : PRINT i,junk
		FOR wait&=0 TO 100000
		NEXT wait&
	NEXT i
END IF

DO
LOOP UNTIL INKEY$<>""


PRINT "          WavePlay example          "

myfile=FREEFILE
OPEN "G:\samples\alien.avr" FOR INPUT AS #myfile
length&=LOF(myfile)
sample&=malloc&(length&)
BLOAD "G:\samples\alien.avr",sample&
CLOSE #myfile

result=WavePlay (WP_MONO+WP_8BIT,ACT_CLK12K&,sample&,length&)
PRINT "WavePlay returns",result
