/* Copyright 1990 by Antic Publishing, Inc. */ 


   Header file to make C look more like FORTRAN  */

#define THEN {
#define DO {
#define ENDIF }
#define ELSE } else
#define ENDDO }
#define REPEAT }
#define ENDCASE }
#define ENDSWITCH }

#define  EQ  ==
#define  LT  <
#define  GT  >
#define  LE  <=
#define  GE  >=
#define  NE  !=
#define  NOT  !
#define  OR  ||
#define  AND  &&
#define  MOD  %

#define TRUE 1
#define FALSE 0
#define YES 1
#define NO 0
#define OFF 0
#define ON 1

#define LOGICAL short

#define CR 13
#define LF 10
#define FF 12
#define NULL 0
#define ESC 27
#define ESCAPE 27
#define TAB 9
#define SPACE 32
#define BLANK 32
#define BELL 7

#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<=(b)?(a):(b))
#define abs(x)   ((x)<0?-(x):(x))
