#include "fido.h"

char    mime_2_pc8[][2]={"E4","E5","F6","”","20","C4",""};
char    pc8_2_mime[]={'„','†','”','\n','Ž','\0'};
/********************************************************************/
/********************************************************************/
void c_mime_2_pc8(MIME *mime,char *buffer)
{
  int counter,mimechar,done=TRUE;

  if(mime->cont_char_set==MIME_CHAR_UNKNOWN)
  {
    for(counter=0; buffer[counter]!=NOLL; counter++)
    {
      if(buffer[counter]=='=')
      {
        mimechar=NOLL;
        done=FALSE;
        while(!done)
        {
          if(!strncmp(buffer+counter+1,mime_2_pc8[mimechar],2))
            done=TRUE;
          else if(mime_2_pc8[mimechar][0]==NOLL)
            done=TRUE;
          else
            mimechar++;
        }
        if(mime_2_pc8[mimechar]!=NOLL)
        {
          strcpy(buffer+counter+1,buffer+counter+3);
          buffer[counter]=pc8_2_mime[mimechar];
        }
      }
    }  
  }
}