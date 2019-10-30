DIM A%(100,100)
FOR I%=0 TO 100
  FOR J%=0 TO 100
    A%(I%,J%)= RND($8000)
  NEXT J%
NEXT I%
Ti= TIMER
OPEN "O",1,"A:\ESSAI.MAT"
FOR I%=0 TO 100
  FOR J%=0 TO 100
    PRINT #1,A%(I%,J%)
  NEXT J%
NEXT I%
CLOSE
PRINT "Temps : ";( TIMER -Ti)/200

