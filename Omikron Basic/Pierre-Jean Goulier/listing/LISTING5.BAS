DIM A%(10)
PRINT "Tirage et sort..."
FOR I%=0 TO 10
  A%(I%)= RND(100)
  PRINT A%(I%);
NEXT I%
PRINT
'
Ptr= VARPTR(A%(0))
Get_Size(Ptr,Size,Addr)
PRINT : PRINT "Transfert..."
Transfert(10,Size,Addr)
'
PRINT : PRINT : PRINT "Reste..."
FOR I%=0 TO 10
  PRINT T%(I%);
NEXT I%
END
'
DEF PROC Transfert(N%,Size,Addr)
  DIM T%(N%)
  LOCAL Ptr= VARPTR(T%(0))
  LOCAL Addr1= LPEEK(Ptr)+ LPEEK( SEGPTR +20)
  MEMORY_MOVE Addr,Size TO Addr1
  FOR I%=0 TO N%
    PRINT T%(I%);
  NEXT I%
  MAT CLEAR T%(N%)
RETURN

