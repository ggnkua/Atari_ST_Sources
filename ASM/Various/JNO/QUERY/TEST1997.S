*THIS PROGRAM CAN BE USED BY ANYONE  JNO*




PRINT_STRING:
         PEA      NEWLINE
         MOVE.W   #9,-(SP)
         TRAP     #1
         ADDQ.L   #6,SP

         PEA      STRING
         MOVE.W   #9,-(SP)
         TRAP     #1
         ADDQ.L   #6,SP

WAIT_FOR_KEYPRESS:
         MOVE.W   #8,-(SP)
         TRAP     #1
         ADDQ.L   #2,SP

TERMINATE:
         MOVE.W   #0,-(SP)
         MOVE.W   #$4C,-(SP)
         TRAP     #1

DATA:
NEWLINE: DC.B $1B,'Y',45,45,0    *THIS CODE $1B WHERE DOES IT COME FROM*

STRING:  DC.B '*TO ALL THAT READ THIS MESSAGE HAPPY NEW YEAR 1997*.'
         
         DC.B $D,$A,0

         END