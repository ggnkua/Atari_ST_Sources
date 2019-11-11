/* ===================================================================== */

/*             Command line 'Bit7' clear textfile utility                */             

/* --------------------------------------------------------------------- */
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

#define FILE_END_OK         1
#define PARAM_FAULT         2
#define SOURCE_MISSING      3
#define FILE_TOO_BIG        4
#define NO_NEW_FILE         5
#define ERROR_ON_WRITING    6

#define BUFF_SIZE           5000
#define S_MODE              O_RDONLY|O_BINARY
#define D_MODE              O_CREAT|O_TRUNC|O_WRONLY|O_BINARY

static int *text_string[] = {
   "ST Bit7 Stripper Utility by Paul Overaa) \n",
   "New file is now available",
   "Usage... <SourceFile> <DestinationFile>",
   "Sorry... cannot find source file",
   "Sorry... source file>5000 bytes maximum",
   "Sorry... couldn't open destination file",
   "Write-error - are you out of disk space ?",
   " - ANY KEY to exit\n" 
   };  

/* --------------------------------------------------------------------- */

main(argc, argv)
	
int argc; char *argv[];

{

int source_fh, dest_fh, source_count, dest_count, state_flag=FILE_END_OK;
register int i; char buffer[BUFF_SIZE+1];




printf("%s",text_string[0]); 

if(argc!=4) {state_flag=PARAM_FAULT;}
        
else { 
      
      if ((source_fh=open(argv[1],S_MODE))==EOF) {state_flag=SOURCE_MISSING;}
   
       else {
            
            if((dest_fh=open(argv[2],D_MODE))==EOF) {state_flag=NO_NEW_FILE;}
      
             else {

                  source_count=read(source_fh,buffer,BUFF_SIZE);   
  
                  if (source_count<BUFF_SIZE)
                     
                     {

                      for (i=0;i<source_count;i++) buffer[i]=buffer[i]&0x7F;
                    
                      } else {state_flag=FILE_TOO_BIG;}

                  dest_count=write(dest_fh,buffer,source_count);

                  close(dest_fh);

                  if (source_count!=dest_count) state_flag=ERROR_ON_WRITING;                   

                  }
       
            close(source_fh);       
   
            }
     
    }

if (state_flag!=1) unlink(argv[2]);

printf("%s%s",text_string[state_flag],text_string[7]);
getchar(); 

} 

/* ====================================================================== */




