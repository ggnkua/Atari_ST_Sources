DIM book$(2,10)
FOR count=1 TO 10
  READ book$(1,count),book$(2,count)
NEXT count
lookup$=""
WHILE lookup$<>"f"
  PRINT
  INPUT "Enter a name to search for (or f to finish): ",lookup$
  IF lookup$<>"f" THEN
    found=0
    FOR count=1 TO 10
      IF INSTR(book$(1,count),lookup$)=1 THEN
        PRINT "The corresponding telephone number is ";book$(2,count)
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
DATA Fred,"0345 435373",Ann,"01 435 7363",John,"0657 234522"
DATA Sue,"021 546 6747",Larry,"0456 423536",Pam,"031 546 7347"
DATA Steve,"0563 536378",Rose,"0646 242526",Mike,"021 534 6346"
DATA Jill,"0384 523623"
END
