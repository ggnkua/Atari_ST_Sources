1 DIM A%(100,100)
2 FOR I%=0 TO 100
3   FOR J%=0 TO 100
4     A%(I%,J%)= RND($8000)
5   NEXT J%
6 NEXT I%
7 '
8 Ptr= VARPTR(A%(0,0)):Nom$="A:\ESSAI.MAT"
9 †Ti= TIMER
10 Save_Array(Ptr,Nom$)
11 PRINT "Temps :";( TIMER -Ti)/200
12 END
13 '
14 DEF PROC Save_Array(Ptr,Nom$)
15  Get_Size(Ptr,Size,Addr)
16  BSAVE Nom$,Addr,Size
17 RETURN
18 '
19 DEF PROC Get_Size(Ptr,R Size,R Addr)
20  LOCAL Ptr1= LPEEK(Ptr)
21  LOCAL Header= LPEEK( SEGPTR +20-50* COMPILER )
22  Addr=Ptr1+ LPEEK( SEGPTR +20)
23  REPEAT
24    Size= LPEEK(Header)+4+4* COMPILER 
25    Header=Header+Size
26  UNTIL Header>=Addr
27  Size=Header-Addr
28 RETURN

