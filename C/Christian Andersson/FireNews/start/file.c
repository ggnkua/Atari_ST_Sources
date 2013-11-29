#include "firemail.h"
/********************************************************************/
/* Laddar in en datafil till minnet och reserverar plats            */
/********************************************************************/
long int load_datafile(char *namn, char **memory,long int fsize)
{
  char     temp[MAXSTRING];
  FILE     *file;
  long int size;
  
  strcpy(temp,system_dir);
  strcat(temp,namn);
  file=fopen(temp,"rb");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],namn,"load_datafile()");
    log(NULL);
    return(FAIL);
  }
  rewind(file);
  fseek(file,NOLL,SEEK_END);
  size=ftell(file);
  rewind(file);
  if((fsize!=NOLL)&&(fsize!=size))
  {
    fclose(file);
    sprintf(fel.text,alerts[E_READ_FILE],namn,"load_datafile()");
    log(NULL);
    return(FAIL);
  }
  if(*memory==NULL)
    *memory=(char *)Malloc(size);
  if(*memory==NULL)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_ALLOC_MEM],"load_datafile()");
    log(NULL);
    return(FAIL);
  }
  if(fread(*memory,1,size,file)!=size)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_READ_FILE],namn,"load_datafile()");
    log(NULL);
    return(FAIL); 
  }

  fclose(file);
  if(fsize!=NOLL)
    return(TRUE);
  else
    return(size);
}

/********************************************************************/
/* Sparar en Datafil fr†n minnet                                    */
/********************************************************************/
int save_datafile(int type, char *namn, char *memory,long int fsize)
{
  char     temp[MAXSTRING];
  FILE     *file;
  
  if(memory==NULL)
  {
    return(FALSE);
  }

  strcpy(temp,system_dir);
  strcat(temp,namn);
  if(type)
    file=fopen(temp,"wb");
  else
    file=fopen(temp,"ab");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],namn,"save_datafile()");
    log(NULL);
    return(FALSE);
  }
  rewind(file);
  fseek(file,NOLL,SEEK_END);
  if(fwrite(memory,1,fsize,file)!=fsize)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_WRITE_FILE],namn,"save_datafile()");
    log(NULL);
    return(FALSE); 
  }

  fclose(file);
  return(TRUE);
}