/* ===================================================================== */

/* Title:   Atari ST Encrypt/Decipher Utility - version 1.00             

   Author:  Paul Overaa                                                  

   Date:    24th May 1990                                                

   Notes:   I'm not an ST programmer, so some of  these notes are
            to help me as much as you... 

            Firstly, the compiled program has to  be  stored with
            a .TTP  extension  so that  the  command line  can be
            collected. 

            Secondly, if you want to deal with  larger files just 
            alter the  BUFFER_SIZE define value.  Better still...
            re-write using a  dynamic buffer  so program attempts
            to use all available memory before it gives up !

            Thirdly I was not sure what the current 'ST compiler'
            situation  is like  as far as  either  ANSII C versus 
            K&R C, or the ST's binary file handling, goes.  I did
            not want line-feeds being translated to  LF-CR  pairs  
            so I've opted for using binary files coupled with the 
            UNIX type read/write functions. 

            Lastly, the open() statements return -1 on failure. I
            have tested against EOF  which is fine for the ST but
            be careful...  if  you  port to a system which uses a 
            different EOF value check the  value that is returned
            when an open() call fails. 

*/

/* --------------------------------------------------------------------- */
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

#define NORMAL_EOF          1
#define WRONG_PARAMETERS    2
#define NO_SOURCE           3
#define OVERSIZE_FILE       4
#define NO_DEST             5
#define WRITE_ERROR         6

#define BUFFER_SIZE         5000
#define S_MODE              O_RDONLY|O_BINARY
#define D_MODE              O_CREAT|O_TRUNC|O_WRONLY|O_BINARY

static int *message[] = {
   "ST Encrypt/Decipher Utility v1.00 (Paul Andreas Overaa) 1990\n",
   "Function complete",
   "Usage... <SourceFile> <DestinationFile> <Key(NoSpaces)>",
   "Sorry... cannot find your source file",
   "Sorry... source file>5000 bytes maximum",
   "Sorry... couldn't open destination file",
   "Destination write-error has occured (no space ?)",
   " - ANY KEY to continue\n" 
   };  

/* --------------------------------------------------------------------- */

main(argc, argv)
	
int argc; char *argv[];

{

int source_fh, dest_fh, read_count, write_count; 
int key_length, position=0, exit_flag=NORMAL_EOF;
register int i;
char buffer[BUFFER_SIZE+1];

printf("%s",message[0]); 

if(argc!=4) {exit_flag=WRONG_PARAMETERS;}
        
else { 
      
      if ((source_fh=open(argv[1],S_MODE))==EOF) {exit_flag=NO_SOURCE;}
   
       else {
            
            if((dest_fh=open(argv[2],D_MODE))==EOF) {exit_flag=NO_DEST;}
      
             else {

                  key_length=strlen(argv[3]);

                  read_count=read(source_fh,buffer,BUFFER_SIZE);   

                  /* Up to this point all that we've done is to work
                     our way down a  'nested test scheme'  trying to
                     open the required files.  Since we have arrived
                     here the source file exists... so now it can be
                     encoded (or decoded) and saved.
                   */              
                  
                  if (read_count<BUFFER_SIZE)
                     
                     {
                     
                      for (i=0;i<read_count;i++) 
                  
                           { /* Here's the magic function... */

                           buffer[i]=buffer[i]^
                           (argv[3][position%key_length]+position%256);

                           position++;

                           }                   

                      } else {exit_flag=OVERSIZE_FILE;}

                  write_count=write(dest_fh,buffer,read_count);

                  close(dest_fh);

                  if (read_count!=write_count) exit_flag=WRITE_ERROR;                   

                  }
       
            close(source_fh);       
   
            }
     
    }

if (exit_flag!=1) unlink(argv[2]);

printf("%s%s",message[exit_flag],message[7]);
getchar(); /* Wait for user to quit */

} 

/* ====================================================================== */




