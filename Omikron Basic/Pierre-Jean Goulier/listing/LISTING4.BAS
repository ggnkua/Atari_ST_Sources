DIM A%(100,100)
Ptr= VARPTR(A%(0,0)):Nom$="A:\ESSAI.MAT"
Ti= TIMER
Load_Array(Ptr,Nom$)
PRINT "Temps :";( TIMER -Ti)/200
END
'
DEF PROC Load_Array(Ptr,Nom$)
  Get_Size(Ptr,Size,Addr)
  BLOAD Nom$,Addr
RETURN

