DEFINT a-z
	OPEN "saved.d56" FOR INPUT AS #1
	elements=LOF(1)\6
	a$=INPUT$(elements*6,#1)
	CLOSE #1
	DIM c&(elements*2)
	FOR i=0 TO elements*2-1
				c&(i)=CVL(CHR$(0)+MID$(a$,i*3+1,3))
	NEXT i
	FOR i=0 TO elements-1
		PRINT c&(i*2)*2+c&(i*2+1)/&h800000
	NEXT i
	
	