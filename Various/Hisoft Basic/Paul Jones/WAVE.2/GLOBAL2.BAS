DEFINT a-z
LIBRARY "WAVEPLAY","GEMDOS"
'$option l100

sam_present=GETCOOKIE ("SAM"+CHR$(0),junk&)
IF sam_present THEN
	myfile=FREEFILE
	OPEN "G:\SAMPLES\ALIEN.AVR" FOR INPUT AS #myfile
		length&=LOF(myfile)
		sample&=malloc&(length&)
		IF sample&=0 THEN
			PRINT "Out of memory"
		ELSE
			BLOAD #myfile,sample&,length&
		END IF
	CLOSE #myfile

	rate&=16490
	PRINT sample&,length&,rate&
    result=WavePlay (1,rate&,sample&,length&)
	PRINT result

	CONST GLOB&=&h474c4f42
	junk=waveplayglobal (0) : PRINT i,junk
	FOR i&=0 TO 400000
	NEXT
	junk=WavePlayMacro (glob&,1) : PRINT i,junk
END IF
