************************************
** MINI WORD PROCESSOR 7 JULY 1997**
************************************
CENTER:  MOVE.L   #PUT,-(SP)  * TEXTLINE
         MOVE     #9,-(SP)    * LOCATION OF TEXT INPUT
         TRAP     #1          * GEMDOS CALL
         ADD.L    #6,SP       * CORRECT THE STACK

START:   MOVEA.L  #LINE,A5    * SET POINTER

IN:      MOVE.W   #1,-(SP)    * CODE; CONIN
         TRAP     #1          * CALL GEMDOS
         ADDQ.L   #2,SP       * STACK CORRECTION

         MOVE.B   D0,(A5)+    * SAVE CHARACTER

         CMPI.B   #13,D0      * WAS CHARACTER A CR
         BNE      IN          * NO; NEXT CHARCTER

         MOVE.W   #13,-(SP)   * OUTPUT CR
         MOVE.W   #5,-(SP)    * CODE; WRITE CHAR TO PRINTER
         TRAP     #1          * CALL GEMDOS
         ADDQ.L   #4,SP       * STACK CORRECTION
   
         MOVE.W   #10,-(SP)   * OUTPUT LF
         MOVE.W   #5,-(SP)    * CODE; WRITE CHAR TO PRINTER
         TRAP     #1          * CALL GEMDOS
         ADDQ.L   #4,SP       * STACK CORRECTION

         MOVEA.L  #LINE,A5    * RESET POINTER

OUT:     MOVE.B   (A5)+,D7    * CHARACTER FROM BUFFER

         MOVE.W   D7,-(SP)    * OUTPUT
         MOVE.W   #5,-(SP)    * CODE WRITE CHAR TO PRINTER
         TRAP     #1          * CALL GEMDOS
         ADDQ.L   #4,SP       * STACK CORRECTION

         CMPI.B   #13,D7      * WAS CHARACTER A CR
         BNE      OUT         * NO; MORE OUTPUT

END:     MOVE.W   #20,-(SP)   * CODE: RETURN SLOWLY
         MOVE.W   #$4C,-(SP)
         TRAP     #1          * CALL GEMDOS

PUT:     DC.B     $1B,'Y**PLEASE TYPE HERE*',45,5,0
LINE:    DS.B     80          * 80 CHARACTER BUFFER

         END 