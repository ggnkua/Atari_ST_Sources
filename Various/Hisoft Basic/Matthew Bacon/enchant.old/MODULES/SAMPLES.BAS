
' [SAMPLES.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DIM SHARED sampleinfo$(15)

FUNCTION SampleInfoAVR (BYVAL file$,saminfo$())
STATIC myfile,length&,sample&,dummy,dummy$,hertz&

file$=UCASE$(FILE$) : myfile=FREEFILE
OPEN file$ FOR INPUT AS #myfile
	length&=LOF(myfile)
	sample&=malloc&(length&)
	IF sample&=0 THEN
		junk=form_alert (1,"[1][  "+MyProgram$+": |  Out of memory. ][ OK ]")
		SampleInfoAVR=0 : EXIT FUNCTION
	ELSE
		BLOAD #myfile,sample&,length&
	END IF
CLOSE #myfile

IF SPEEKB(sample&)+SPEEKB(sample&+1)+SPEEKB(sample&+2)+SPEEKB(sample&+3)<>273 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  This file is not an AVR |  audio file.][ OK ]")
	SampleInfoAVR=1 : EXIT FUNCTION
ELSE
	dummy$=""
	FOR dummy=4 TO 11
		dummy$=dummy$+CHR$(SPEEKB(sample&+dummy))
	NEXT dummy
	saminfo$(0)=dummy$    ' Name of sample, encoded in AVR file

	IF SPEEKW(sample&+12)=&hFFFF THEN  ' Is sample in stereo or mono?
		saminfo$(1)="Stereo"
	ELSE
		saminfo$(1)="Mono"
	END IF

	saminfo$(2)=LTRIM$(STR$(SPEEKW(sample&+14))) ' sample resolution 8,12 or 16 (bits)

	IF SPEEKW(sample&+16)=&hFFFF THEN  ' signed -127 to 128 / unsigned 0 to 255
		saminfo$(3)="Signed"
	ELSE
		saminfo$(3)="Unsigned"
	END IF

	IF SPEEKW(sample&+18)=&hFFFF THEN  ' looping
		saminfo$(4)="Looped"
	ELSE
		saminfo$(4)="Not looped"
	END IF

	IF SPEEKW(sample&+20)=&hFFFF THEN  ' MIDI assigned note (base note)
		saminfo$(5)="No midinote defined"
	ELSE
		saminfo$(5)=LTRIM$(STR$(SPEEKB(sample&+21)))
	END IF

	IF SPEEKB(sample&+22)=&hFF THEN  ' replay speed
		saminfo$(6)="No reply speed defined"
	ELSE
		saminfo$(6)=LTRIM$(STR$(SPEEKB(sample&+22)))
	END IF

	hertz&=(SPEEKL(sample&+23)*0.00390625)
	saminfo$(7)=LTRIM$(STR$(hertz&))

	saminfo$(8)=LTRIM$(STR$(SPEEKL(sample&+26)))  'sample size in bytes

	IF SPEEKL(sample&+30)=&h0 THEN  ' loop position
		saminfo$(9)="No loop start defined"
	ELSE
		saminfo$(9)=LTRIM$(STR$(SPEEKL(sample&+30)))
	END IF
	saminfo$(10)=LTRIM$(STR$(SPEEKL(sample&+34)))

	saminfo$(11)=""
	FOR dummy=64 TO 127
		saminfo$(11)=saminfo$(11)+CHR$(SPEEKB(sample&+dummy))
	NEXT dummy
END IF
junk=mfree(sample&)
SampleInfoAVR=-1
END FUNCTION


FUNCTION SampleHeader (BYVAL file1$,BYVAL file2$,BYVAL file3$)
STATIC myfile,length&,sample&,sample2&

myfile=FREEFILE
OPEN file1$ FOR INPUT AS #myfile
	sample&=malloc&(129)
	IF sample&=0 THEN
		junk=form_alert (1,"[1][  "+MyProgram$+": |  Out of memory. ][ OK ]")
		SampleHeader=0 : EXIT FUNCTION
	ELSE
		BLOAD #myfile,sample&,129
	END IF
CLOSE #myfile

myfile=FREEFILE
OPEN file2$ FOR INPUT AS #myfile
	length&=LOF(myfile)
	sample2&=malloc&(length&)
	IF sample2&=0 THEN
		junk=form_alert (1,"[1][  "+MyProgram$+": |  Out of memory. ][ OK ]")
		junk=mfree(sample&) : SampleHeader=0 : EXIT FUNCTION
	ELSE
		BLOAD #myfile,sample2&,length&
	END IF
CLOSE #myfile

myfile=FREEFILE
OPEN file3$ FOR OUTPUT AS #myfile
	BSAVE #myfile,sample&,128
	BSAVE #myfile,sample2&,length&-128
CLOSE #myfile
junk=mfree(sample&) : junk=mfree(sample2&)
SampleHeader=-1
END FUNCTION


FUNCTION SamplePlay (BYVAL file$,BYVAL flag,freq&,BYVAL over_rate)
STATIC result,myfile,length&,sample&,a!,b!,c!,d!,over_rate,hardware!
STATIC sample2&,length2&,s_step!,f_step!,sign_me,junk&,dummy

IF RIGHT$(file$,3)="AVR" THEN
	REDIM PRESERVE sampleinfo$(15)
	result=SampleInfoAVR (file$,sampleinfo$())
END IF

myfile=FREEFILE
OPEN file$ FOR INPUT AS #myfile
	length&=LOF(myfile)
	sample&=malloc&(length&)
	IF sample&=0 THEN
		junk=form_alert (1,"[1][  "+MyProgram$+": |  Out of memory. ][ OK ]")
		SamplePlay=-1 : EXIT FUNCTION
	ELSE
		BLOAD #myfile,sample&,length&
	END IF
CLOSE #myfile

IF RIGHT$(file$,3)="AVR" THEN
	IF sampleinfo$(3)="Unsigned" THEN sign_me=127
	SELECT CASE freq&
	CASE 6258 : freq&=6258
	CASE 8195 : freq&=8195
	CASE 9834 : freq&=9834
	CASE 12292 : freq&=12292
	CASE 12517 : freq&=12517
	CASE 16490 : freq&=16490
	CASE 20770 : freq&=20770
	CASE 24585 : freq&=24585
	CASE 25033 : freq&=25033
	CASE 33880 : freq&=33880
	CASE 49170 : freq&=49170
	CASE 50066 : freq&=50066
	CASE ELSE
		flag=0
		SELECT CASE freq&
		CASE <=6258 : hardware!=6.258/2
		CASE <=12517 : hardware!=12.517/2 : flag=flag+1
		CASE <=25033 : hardware!=25.033/2 : flag=flag+2
		CASE ELSE : hardware!=50.066/2 : flag=flag+3
		END SELECT
		IF sampleinfo$(1)="Mono" THEN flag=flag+128
		IF sampleinfo$(2)="12" THEN flag=flag+64
		IF sampleinfo$(2)="16" THEN flag=flag+64

		a!=(hardware!*2)/(freq&/1000)
		b!=a!*(length&-128)
		c!=(length&-128)/over_rate
		d!=over_rate/((b!/c!)-over_rate)

		sample2&=malloc&(b!+150)
		length2&=0
		IF sample2&=0 THEN
			junk=form_alert (1,"[1][  "+MyProgram$+": |  Out of memory. ][ OK ]")
			junk=mfree(sample&) : SamplePlay=-1 : EXIT FUNCTION
		ELSE
			f_step!=1
			FOR s_step!=0 TO length&-1
				SPOKEB (sample2&+length2&),SPEEKB(sample&+s_step!)-sign_me
				IF s_step!>=127 THEN
					IF (s_step!-127)=CINT(d!*f_step!) THEN
						INCR length2&
						SPOKEB (sample2&+length2&),SPEEKB(sample&+s_step!)-sign_me
						INCR f_step!
					END IF
				END IF
				INCR length2&
			NEXT
			sample&=sample2&
			length&=(length2&-1)

			SPOKEW &hFF8902,sample&/&h10000  'Frame start address (high)
			SPOKEW &hFF8904,sample&/&h100    'Frame start address (mid)
			SPOKEW &hFF8906,sample& AND &hFF  'Frame start address (low)
			SPOKEW &hFF890E,(sample&+length&)/&h10000  'Frame end address (high)
			SPOKEW &hFF8910,(sample&+length&)/&h100    'Frame end address (mid)
			SPOKEW &hFF8912,(sample&+length&) AND &hFF  'Frame end address (low)

			SPOKEB &hFF8901,0  ' stop playback sample
			SPOKEW &hFF8900,&h0400
			SPOKEB &hFF8901,1  ' playback sample

			FOR dummy=0 TO 10000
			NEXT
			junk=mfree(sample&) : junk=mfree(sample2&)
			SamplePlay=0 : EXIT FUNCTION
		END IF
	END SELECT

	IF GETCOOKIE ("SAM"+CHR$(0),junk&) THEN
		result=WavePlay (flag,freq&,sample&,length&)
		SamplePlay=result
	END IF
ELSE
	SELECT CASE freq&
	CASE <=6258 : freq&=6258
	CASE <=8195 : freq&=8195
	CASE <=9834 : freq&=9834
	CASE <=12292 : freq&=12292
	CASE <=12517 : freq&=12517
	CASE <=16490 : freq&=16490
	CASE <=20770 : freq&=20770
	CASE <=24585 : freq&=24585
	CASE <=25033 : freq&=25033
	CASE <=33880 : freq&=33880
	CASE <=49170 : freq&=49170
	CASE <=50066 : freq&=50066
	CASE ELSE : freq&=25033
	END SELECT

	IF GETCOOKIE ("SAM"+CHR$(0),junk&) THEN
		result=WavePlay (flag,freq&,sample&,length&)
		SamplePlay=result
	END IF
	junk=mfree(sample&)
END IF
END FUNCTION

'[*END OF FILE*]
