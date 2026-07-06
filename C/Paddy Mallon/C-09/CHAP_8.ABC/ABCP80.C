/*  ABC p80 eg 8.5                  */
/*  EFFICIENCY                      */
/*  This program segment is from the original 'Small-C'        */
/*  it was found that this segment of code accounted for 25%
    of the execution time.ie any improvements made here could have  
    significant repercussions.
    These improvements were used to good effect in RATC.
    The improvements are not stand-alone, ie other functions are 
    involved ,particularly the 'findmac' function.
    The book ABC contains a complete listing of the RATC compiler 
    by Berry & Meekings in appendix 2. including the modified
    versions of the functions below along with the findmac 
    function. 
    If you are interested in this area I would suggest you get a 
    look at the book as it also allows you to implement RATC on 
    your machine if you can write in assembler.
*/
/****************
 * style = 42.0 *
 ****************/

alpha(c)
/* test if a given character is alphabetic */
     char c;
     {
          c=c&127;    /* strip off the  parity bit */
          return(  (( c>'a' & ( c<= 'z')) |
                   (( c>'A' & ( c<= 'Z')) |
                    ( c == '_')
                );
     }

numeric(c)
/* test if a given character is numeric   */
     char c;
     {
          c= c&127;
          return( ( c>= '0') & (c<= '9') );
     }

an(c)
/* test if a given character is alphanumeric   */
     char c;
     {
          return( ( alpha(c) ) |  (numeric(c) ) );
     }


