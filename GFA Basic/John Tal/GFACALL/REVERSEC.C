/*****************************************************************************
*
* reverse string function 
* For interface with GFA Basic 
* Compiled with Alcyon compiler
*
******************************************************************************/


reverse(str,len)
char *str;
int len;
{
 int c,i,j;

 for (i=0, j = len-1; i< j; i++, j--)
 {
   c = str[i];
   str[i] = str[j];
   str[j] = c;
  }
}

