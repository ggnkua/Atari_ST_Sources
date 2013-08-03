;--------------------------------------------------------------
Calc_Tables:
		BSR	Calc_Colour_Table
		RTS

;--------------------------------------------------------------
; We can do the tables in a much easier manner:
Calc_Colour_Table:
		LEA	Colour_Table,A0
		MOVEQ	#32-1,D7		;red count
		LEA	Feedback_Table_Red,A1
.CalcLoop1:
		MOVE.W	(A1)+,D1
		MOVEQ	#32-1,D6		;green count
		LEA	Feedback_Table_Green,A2
.CalcLoop2:
		MOVE.W	(A2)+,D2
		OR.W	D1,D2
		MOVEQ	#64-1,D5		;blue count * 2...green bottom not used!
		LEA	Feedback_Table_Blue,A3
.CalcLoop3:
		MOVE.W	(A3)+,D3
		OR.W	D2,D3
		MOVE.W	D3,(A0)+
		DBF	D5,.CalcLoop3
		DBF	D6,.CalcLoop2
		DBF	D7,.CalcLoop1
		RTS

;--------------------------------------------------------------
Feed	MACRO
		  IFEQ Direction
			DC.W	\1*00,\1*00		;,\1*00,\1*00
			DC.W	\1*01,\1*02,\1*03,\1*04
			DC.W	\1*05,\1*06,\1*07,\1*08
			DC.W	\1*09,\1*10,\1*11,\1*12
			DC.W	\1*13,\1*14,\1*15,\1*16
			DC.W	\1*17,\1*18,\1*19,\1*20
			DC.W	\1*21,\1*22,\1*23,\1*23
			DC.W	\1*23,\1*23,\1*23,\1*23
			DC.W	\1*23,\1*23		;,\1*23
		  ELSE	
			DC.W	\1*12,\1*12
			DC.W	\1*12,\1*12,\1*12,\1*12
			DC.W	\1*12,\1*12,\1*12,\1*12
			DC.W	\1*12,\1*13,\1*14,\1*15
			DC.W	\1*16,\1*17,\1*18,\1*19
			DC.W	\1*20,\1*21,\1*22,\1*23
			DC.W	\1*24,\1*24,\1*25,\1*26
			DC.W	\1*27,\1*28,\1*29,\1*30
			DC.W	\1*30,\1*30		;,\1*31,\1*31
		  ENDC
		ENDM


Feedback_Table_Red:
		Feed	$0800
Feedback_Table_Green:
		Feed	$0040
Feedback_Table_Blue:
		Feed	$0001
		Feed	$0001


		section	bss
		IFNE	Motion_Blur_Mode
Colour_Table		DS.W	65536
		ENDC
		section	text
