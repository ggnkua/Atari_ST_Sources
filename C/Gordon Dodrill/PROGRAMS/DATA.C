/*    DATA.C   DATA.C    DATA.C    DATA.C    DATA.C    DATA.C

DATA INITIALIZE AND CALCULATE      XXXX     X    XXXXX    X
                                   X   X   X X     X     X X
May 27, 1986                       X   X  X   X    X    X   X
                                   X   X  X   X    X    X   X
                                   X   X  XXXXX    X    XXXXX
                                   X   X  X   X    X    X   X
                                   XXXX   X   X    X    X   X
*/
#include "ctype.h"
#include "struct.def"
extern struct vars allvars[];
extern char inline[];
extern int col;
extern int errcode,colerr;
extern char strngout[];
extern int valattr;

/* ****************************************************** initdata */
/* This function is used to initialize all of the variables to the */
/* starting values including their variable names.                 */
initdata(pnt)
struct vars *pnt;
{
int index;
    for (index = 0;index < 6;++index){
       (pnt+index)->varname[0] = 'A' + index;
       (pnt+index)->varname[1] = 0;
       (pnt+index)->outtype = 'F';
       (pnt+index)->value = 0.0;
    }
    for (index = 6;index < 12;++index){
       (pnt+index)->varname[0] = 'I' + index - 6;
       (pnt+index)->varname[1] = 0;
       (pnt+index)->outtype = 'D';
       (pnt+index)->value = 0;
    } 
    (pnt+4)->value = 2.718281828459045;
    (pnt+5)->value = 3.141592653589793;
    (pnt+11)->value = 16777215;
}

/* ******************************************************* getnames */
/* This function reads in a new list of variable names to be used   */
/* in place of the names A to F. This is only as a convenience for  */
/* the user, so he can use more meaningful names.                   */
getnames()
{
char var,index;
char dummy[80];

   col = 1;                      /* skip over and ignore the # sign */
   do {
      if (inline[col] == ' ') col++;   /* ignore all leading blanks */
      else {
         var = inline[col] - 'A';
         if ((var >= 0) && (var <= 5)) {             /* A through F */
            col++;
            if (inline[col] != '-') {           /* should be a dash */
               errchk(14);
               errout();
               return;
            }
            col++;
            for (index = 0;index < 6;index++)
               if (isalpha(inline[col]) || isdigit(inline[col])) {
                  dummy[index] = inline[col];
                  dummy[index + 1] = 0;
                  col++;
               }
            if (index > 0) {
               strcpy(allvars[var].varname,dummy);
               strcpy(strngout,"      ");         /* this is for    */
               strngout[6-strlen(dummy)] = 0;     /* leading blanks */
               strcat(strngout,dummy);
               strngdis(var + 1,1,valattr); 
            }
         }
         else if ((var >= 8) && (var <= 13)) {       /* I through N */
            col++;
            if (inline[col] != '-') {           /* should be a dash */
               errchk(14);
               errout();
               return;
            }
            col++;
            if ((inline[col] == 'O') || (inline[col] == 'D') ||
                (inline[col] == 'H') || (inline[col] == 'X')) {
               var -= 2;
               allvars[var].outtype = inline[col];
               col++;
            }
            else {
               errchk(15);
               errout();
               return;
            }
         }
         else {                            /* unknown variable name */
            errchk(3);
            errout();
            return;
         }
      }
   } while (inline[col] && (errcode == 0));
}

/* ******************************************************* calcdata */
/* This is the function that actually does the work of deciding     */
/* what calculations need to be done. The method used is described  */
/* in detail below.                                                 */
/*    Three variables and two operators are         number1         */
/*    stored as per the list. "op1" is always         op1           */
/*    a plus or minus, and op2 is always a          number2         */
/*    multiplication or divide. If a plus or          op2           */
/*    minus is found for op2, number1 and           number3         */
/*    number2 are combined according to op1                         */
/*    and the result becomes number1, the new op2 becomes op1, and  */
/*    number3 becomes number2. If op2 is either a multiplication or */
/*    divide, number2 and number3 are combined according to op2 and */
/*    the result is placed in number2. When a parentheses is found, */
/*    a recursive call is made and the expression in the parenthe-  */
/*    ses is evaluated. A bit of study will be very fruitful in     */
/*    understanding this operation.                                 */
calcdata(newval)
double *newval;
{
double number1,number2,number3,getnum();
char op1,op2,getop();
   number1 = 0.0;
   op1 = '+';
   number2 = 0.0;
   while (inline[col] == ' ') col++;               /* ignore blanks */
                                        /* check for unary operator */
   if ((inline[col] == '+') || (inline[col] == '-')) {
      op1 = inline[col];
      col++;
   }

   number2 = getnum();          /* (inline[col]== 0 ) = End of line */
                                /* (inline[col]=='$') = End of line */
   if ((inline[col] == 0) || (inline[col] =='$')) {
      calcdat(&number1,&op1,&number2);
      *newval = number1;
      return;
   }
   for (;;){
      op2 = getop(); 
      col++;
                               /* check for end of line  0, ), or $ */
      if (op2 == '$') op2 = 0;        /* force a $ to lool like eol */
      if ((op2 == 0) || (op2 == ')')) {
         col++;
         calcdat(&number1,&op1,&number2);
         *newval = number1;
         return;
      }
      number3 = getnum();
      if ((op2 == '*') || (op2 == '/')){
         calcdat(&number2,&op2,&number3);
      }
      else{
         calcdat(&number1,&op1,&number2);
         op1 = op2;
         number2 = number3;
      }
   } /* end of infinite for loop */   
}

/* ******************************************************** calcdat */
/* This function actually does the calculations described in the    */
/* function above.                                                  */
calcdat(number1,op1,number2)
double *number1,*number2;
char *op1;
{
   switch (*op1) {
      case '*' : *number1 = (*number1)*(*number2);
                 break;
      case '/' : if (*number2 == 0.0) {
                     errchk(10);
                     break;
                 }
                 *number1 = (*number1)/(*number2);
                 break;
      case '+' : *number1 = *number1 + *number2;
                 break;
      case '-' : *number1 = *number1 - *number2;
                 break;
      default  : break;
   }
   return;
}

/* ********************************************************* getnum */
/* This is the workhorse of the program. It actually scans the data */
/* input field and converts the data into numbers which are in the  */
/* internal format of the computer so the calculations can be done. */
double getnum()
{
int index,i,decpt;
double newval;
char name[7];
double sqrt(), exp(), log(), sin(), cos(), atan();

   while (inline[col] == ' ') col++;               /* ignore blanks */

   index = inline[col];
   if (index == '('){
       col++;
       calcdata(&newval);                         /* recursive call */
       col--;
       return(newval);
   }

   decpt = 0;                         /* search for a decimal point */
   i = col;
   index = inline[i];
   while ((index >= '0') && (index <= '9')) {
      i++;
      index = inline[i];
      if (index == '.') decpt = 1;
   }

   index = inline[col];
   if (((index > '0') && (index <= '9')) ||
       ((index == '0') && (decpt == 1))  ||
        (index == '.')) {                        /* floating number */
      newval = 0.0;
      while ((index >= '0') && (index <= '9')) {
         newval = 10.0*newval + (index - '0');
         col++;
         index = inline[col];
      }
      if (index == '.') {
         double const = 0.1;
         col++;
         index = inline[col];
         while ((index >= '0') && (index <= '9')) {
            newval = newval + (index - '0') * const;
            const = const * .1;
            col++;
            index = inline[col];
         }
      }
      return(newval);
   }                                /* end of floating point number */

   if (index == '0') {                      /* octal or hexadecimal */
      col++;
      index = inline[col];
      if ((index == 'x') || (index == 'X')){         /* hexadecimal */
         col++;
         index = inline[col];
         newval = 0.0;
         while (((index >= '0') && (index <= '9')) ||
                ((index >= 'A') && (index <= 'F')) ||
                ((index >= 'a') && (index <= 'f'))) {
            switch (index) {
               case '0':
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
               case '8':
               case '9':i = index - '0';
                        break;
               case 'A':
               case 'B':
               case 'C':
               case 'D':
               case 'E':
               case 'F':i = index - 'A' + 10;
                        break;
               case 'a':
               case 'b':
               case 'c':
               case 'd':
               case 'e':
               case 'f':i = index - 'a' + 10;
                        break;
               default :break;
            }
            newval = 16.0*newval + i;
            col++;
            index = inline[col];
         }
      return(newval);
      }                                  /* end of hexadecimal 'if' */

      else {                                               /* octal */
         newval = 0.0;
         while ((index >= '0') && (index <= '7')) {
            newval = 8.0*newval + (index - '0');
            col++;
            index = inline[col];
         }
      return(newval);
      }                                      /* end of octal 'else' */
    
   }                         /* end of octal or hexadecimal numbers */   

                                  /* find variable or function name */
   if ((inline[col] >= 'A') && (inline[col] <= 'Z')) {
      name[0] = inline[col++];
      i = 1;
      while ((((inline[col] >= 'A') && (inline[col] <= 'Z')) ||
             ((inline[col] >= '0') && (inline[col] <= '9'))) &&
             (i <= 5)) {           /* continue var or function name */
         name[i++] = inline[col++];
      }
      name[i] = 0;                                    /* name found */

      if (inline[col] == '('){                     /* function call */
         col++;
         if (strcmp(name,"ABS") == 0) {
            calcdata(&newval);
            if (newval < 0.0) newval = -newval;
         }
         else if (strcmp(name,"SQRT") == 0) {
            calcdata(&newval);
            if (newval < 0.0) {
               errchk(5);                     /* Neg value for SQRT */
               newval = 0.0;
            }
            else newval = sqrt(newval);
         }
         else if (strcmp(name,"FACT") == 0) {
            calcdata(&newval);
            if (newval < 0.0) {
               errchk(16);                    /* Neg value for FACT */
               newval = 0.0;
            }
            else {
            double count;
            int howmany;
               count = newval;
               newval = 1.0;
               for (howmany = count;howmany > 1;howmany--) {
                  count = howmany;
                  newval = newval * count;
               }
            }
         }
         else if (strcmp(name,"EXP") == 0) {
            calcdata(&newval);
            newval = exp(newval);
         }
         else if (strcmp(name,"LOG") == 0) {
            calcdata(&newval);
            if (newval < 0.0) {
               errchk(7);                      /* Neg value for LOG */
               newval = 0.0;
            }
            else newval = log(newval);
         }
         else if (strcmp(name,"SIN") == 0){
            calcdata(&newval);
            newval = sin(newval);
         }
         else if (strcmp(name,"COS") == 0){
            calcdata(&newval);
            newval = cos(newval);
         }
         else if (strcmp(name,"ATAN") == 0){
            calcdata(&newval);
            newval = atan(newval);
         }
         else {
            errchk(6);                        /* function not found */
            newval = 0.0;
         }  
         col--;
         return(newval);
      }                                     /* end of function call */

      else {                                       /* variable name */
         for (i = 0;i < 12;i++) {
            if ((strcmp(name,allvars[i].varname)) == 0) {
               newval = allvars[i].value;
               return(newval);
            }
         }
         errchk(3);                           /* variable not found */
         newval = 0.0;
         return(newval);
      }                                     /* end of variable call */

   }                            /* end of variable or function call */     
   errchk(9);
   return(0.0);                               /* invalid data found */
}

/* ********************************************************** getop */
/* A call to this function expects to find an operator, end of line */
/* or a close parenthesis.                                          */
char getop()
{
   while (inline[col] == ' ') col++;               /* ignore blanks */
   switch (inline[col]){
      case '$':
      case ')':
      case  0 :
      case '+':
      case '-':
      case '*':
      case '/': break;
      default : errchk(4);                      /* invalid operator */
   }
   return(inline[col]);
}

/* ********************************************************* errchk */
/* The error code is stored by this function and the cursor column  */
/* is adjusted in an attempt to put the cursor near the error that  */
/* caused the problem.                                              */
errchk(err)
int err;
{
   if(errcode) return;                       /* error already found */
   else {                         /* only the first error is stored */
      errcode = err;                      /* store the error number */
      switch (err){
         case 2  : 
         case 4  :
         case 8  :
         case 9  :
         case 10 :
         case 11 :
         case 12 : colerr = col;
                   break;
         case 1  :
         case 3  : colerr = col - 1;
                   break;
         case 6  : colerr = col - 2;
                   break;
         case 5  :
         case 7  : colerr = col - 3;
                   break;
         default : colerr = col;
      }
   }
}
