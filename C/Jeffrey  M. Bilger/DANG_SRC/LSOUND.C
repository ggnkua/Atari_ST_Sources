extern long addr;
#include <osbind.h>


/* Loads up PLAY.PRG as TSR. and will call it with arguments.

   Now you can include sounds in the form of *.SND files in your code!
 
   Say you are writing a utility program and want to spice it up a bit.
   If the user entered a wrong command, you could play a .SND file 
   that says 'WHAT THE HELL ARE YOU DOING?' 
  
   It adds a nice touch.

   


  ** NOTE ** the format of the command line argument is 
             FILENAME.EXT xxxx

             where filename is the FILE.SND 
             and   xxxx     is the Freq. you want to play it as.

             ex:   HITHERE.SND 6500 

                   will play the file "hithere" at 6500Hz

    Thats all there is to it! Enjoy. Jeff Bilger TAMU 3/28/93 3:40am                        
*/


 
  
load_player_as_tsr()
{
  char   work[20];                      /* For conv. C to Pascal like string */

    
     addr = Pexec(3,"player",work,"");    /* load it as TSR */
                                          /* addr holds addr of its basepage*/
   printf("Loaded at:%lx\n",addr);

 
}



/********************************************************/
/* The COMMAND argument of Pexec requires that the string be in
   the Pascal-like format. ie 1st element in string holds the 
   length of the string.
*/

convert_string(dest , source )
char dest[];
char source[];

{

   dest[0] = strlen(source);          /* place length of string in 1st cell of array */
   strcpy(&dest[1],source);           /* copy rest of string */
  printf("length:%d %s\n",dest[0],dest);
}
  
/*********************************************/
/* this code will place a *.SND file in the Command
   line arg and play it

 */

invoke_tsr(a)
char a[];
{
 long cline;                            /* temp addr. Used to store new *.SND file in command line*/
 char *ptr;
 char   work[20];                      /* For conv. C to Pascal like string */
 int x;
 char ui;
  
  

  convert_string( work, a);          /* convert to Pascal like string */
      cline = addr;                  /* get addr of basepage */
      cline += 128;                  /* add 128 byte offset,so now
                                        cline points to Command_line*/
      ptr = (char *) cline;
printf("******ADDRS*******************\n");
printf("Loaded to:%lx\n",addr);
printf("Basepage%lx\n",ptr);
printf("******************************\n");     
   /* clear out command line */
  
    

      
      strcpy(cline,work);            /*copy new ttp info to command
                                       line. ie place string *.SND there */

   /** display command line **/
printf("*******CONTENTS*************************\n");
   printf("Contents of command line:\n");
   for(x=0;x<20;x++)
    printf("%d",*(ptr++));
  ptr = (char *) cline;
  printf("\n");
    for(x=0;x<15;x++)
    printf("%c",*(ptr++));
printf("****************************************\n");
    ptr = (char *) cline;
    
     scanf("%c",&ui);
   Pexec(4,"",(long *)addr,"");  /* invoke the TSR prg. We need to tell it */
                                 /* which one to invoke. We send the basepage addr*/
                                 /* of the prg we want to invoke. We send it*/
                                 /* to the command line string */     
                                 /* we must typecast it */
  
}
 
