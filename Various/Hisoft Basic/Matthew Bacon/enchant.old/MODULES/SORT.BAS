
' [SORT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' Thanks go to Gary Bell for his initial development and advice regarding these
' sort routines - cheers 8-)

SUB sort (sort_array$(),BYVAL start_index,BYVAL stop_index)
STATIC dummy,i,dummy$

FOR dummy=start_index TO stop_index
	dummy$=sort_array$(dummy)
	FOR i=dummy-1 TO 1 STEP -1
		IF UCASE$(sort_array$(i))<UCASE$(dummy$) THEN EXIT FOR
		sort_array$(i+1)=sort_array$(i)
	NEXT i
	sort_array$(i+1)=dummy$
NEXT dummy
END SUB


SUB sort_multi (sort_array$(),BYVAL array_index,BYVAL start_index,BYVAL stop_index)
STATIC dummy,i,dummy$

FOR dummy=start_index TO stop_index
	dummy$=sort_array$(dummy,array_index)
	FOR i=dummy-1 TO 1 STEP -1
		IF UCASE$(sort_array$(i,array_index))<UCASE$(dummy$) THEN EXIT FOR
		sort_array$(i+1,array_index)=sort_array$(i,array_index)
	NEXT i
	sort_array$(i+1,array_index)=dummy$
NEXT dummy
END SUB

'[*END OF FILE*]
