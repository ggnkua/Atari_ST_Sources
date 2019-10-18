DIM name$(10),number$(10)
PRINT "Enter up to ten names, each followed by a telephone number"
count=1
WHILE count<11
  PRINT  
  INPUT "Enter a name (or f to finish): ",name$(count)
  IF name$(count)<>"f" THEN
    INPUT "Enter a telephone number: ",number$(count)
    count=count+1
  ELSE count=11
  END IF
WEND
lookup$=""
WHILE lookup$<>"f"
  PRINT
  INPUT "Enter a name to search for (or f to finish): ",lookup$
  IF lookup$<>"f" THEN
    found=0
    FOR count=1 TO 10
      IF INSTR(name$(count),lookup$)=1 THEN
        PRINT "The corresponding telephone number is ";number$(count)
        found=1
      END IF
    NEXT count
    IF found=0 THEN 
      PRINT "Sorry, no telephone number found for ";lookup$
    END IF
  END IF
WEND
PRINT
PRINT "End of run"
END
