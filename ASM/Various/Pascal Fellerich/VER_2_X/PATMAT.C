#include <stddef.h>
#include <string.h>

/***********************************************************************
**                                                                    **
**   Function    :  patmat                                            **
**                                                                    **
**   Purpose     :  Pattern Matching                                  **
**                                                                    **
**   Usage       :  Pass two string pointers as parameters.The first  **
**                  being a raw string & the second a pattern the raw **
**                  string is to be matched against.If the raw string **
**                  matches the pattern,then the function returns a   **
**                  1,else it returns a 0.                            **
**                                                                    **
**                  e.g  patmat("abcdefghi","*ghi") returns a 1.      **
**                       patmat("abcdefghi","??c??f*") returns a 1.   **
**                       patmat("abcdefghi","*dh*") returns a 0.      **
**                       patmat("abcdefghi","*def") returns a 0.      **
**                                                                    **
**                  The asterisk is a wild card to allow any charac-  **
**                  ters from its first appearance to the next spec-  **
**                  ific character.The character ? is a wild card     **
**                  for only one character in the position it appears.**
**                  Combinations such as "*?" or "?*" or "**" are     **
**                  illegal for obvious reasons & the functions may   **
**                  goof,though I think it will still work.           **
**                                                                    **
**   Author      :  Sreenath Chary              Nov 29 1988           **
**                                                                    **
**   Logic       :  The only simple way I could devise is to use      **
**                  recursion.Each character in the pattern is        **
**                  taken & compared with the character in the raw    **
**                  string.If it matches then the remaining amount    **
**                  of the string & the remaining amount of the       **
**                  pattern are passed as parameters to patmat again  **
**                  until the end of the pattern.If at any stage      **
**                  the pattern does not match,then we go back one    **
**                  level & at this level if the previous character   **
**                  was a asterisk in the pattern,we hunt again from  **
**                  where we left off,otherwise we return back one    **
**                  more level with a not found & the process goes    **
**                  on till the first level call.                     **
**                                                                    **
**                  Only one character at a time is considered,except **
**                  when the character is an asterisk.You'll get the  **
**                  logic as the program unfolds.                     **
**                                                                    **
***********************************************************************/

int patmat(char *raw,char *pat)
{
   int  i, slraw;

   if ((*pat == '\0') && (*raw == '\0'))    /*  if it is end of both  */
     return( 1 ) ;                          /*  strings,then match    */
   if (*pat == '\0')                        /*  if it is end of only  */
     return( 0 ) ;                          /*  pat tehn mismatch     */
   if (*pat == '*')                         /* if pattern is a '*'    */
    { if (*(pat+1) == '\0')                 /*    if it is end of pat */
         return( 1 ) ;                      /*    then match          */
      for(i=0,slraw=strlen(raw);i<=slraw;i++)/*    else hunt for match*/
        if ((*(raw+i) == *(pat+1)) ||       /*         or wild card   */
            (*(pat+1) == '?'))
         if (patmat(raw+i+1,pat+2) == 1)    /*      if found,match    */
              return( 1 ) ;                 /*        rest of pat     */
    }
   else
    { if (*raw == '\0')                     /*  if end of raw then    */
         return( 0 ) ;                      /*     mismatch           */
      if ((*pat == '?') || (*pat == *raw))  /*  if chars match then   */
        if (patmat(raw+1,pat+1) == 1)       /*  try & match rest of it*/
           return( 1 ) ;
    }
   return( 0 ) ;                            /*  no match found        */
}
