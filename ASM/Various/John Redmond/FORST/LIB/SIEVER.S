DECIMAL
: TASK ;

8190 CONSTANT SIZE

: DO-PRIME

{  5 REGS P Q PRIMECOUNT LOOPCOUNT LIMIT  SIZE LOCBUFF FLAGS }

   FLAGS SIZE 1 FILL
   
   FLAGS SIZE + TO LIMIT
   0 TO PRIMECOUNT   0 TO LOOPCOUNT
   
   BEGIN
      FLAGS LOOPCOUNT + C@
      IF LOOPCOUNT 2* 3 +  TO P
         FLAGS P + LOOPCOUNT +  TO Q
         Q LIMIT <
         IF
           BEGIN
            0 Q C!
            P ADDTO Q
            Q LIMIT < NOT
           UNTIL 
         THEN 
         1 ADDTO PRIMECOUNT 
      THEN
   1 ADDTO LOOPCOUNT 
   LOOPCOUNT SIZE  =   UNTIL 
   PRIMECOUNT . ." primes " 
;

: PRIMES  { 1 REGARG CNT }
  FOR CNT  DO-PRIME  NEXT ;
