#include "firetext.h"
#include <dos.h>
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

/********************************************************************/
/* Laddar in areas.bbs filen till minnet                            */
/********************************************************************/
int load_areasbbs(char *memory)
{
  FILE *areasfile;
  char buffer[MAXSTRING],temp1[MAXSTRING],temp2[MAXSTRING];
  int counter;
  long int size=NOLL;

  areasfile=fopen(config->areasbbsfile,"r");
  if(areasfile==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],config->areasbbsfile,"load_areasbbs()");
    log(NULL);
    return(FALSE);
  }
  fgets(buffer,MAXSTRING,areasfile);
  while(fgets(buffer,MAXSTRING,areasfile)!=NULL)
  {
    sscanf(buffer,"%s",temp1);
    if(isalpha(*temp1))
    {
      tempvar.num_areas++;
    }
  }
  rewind(areasfile);
  areasbbs=Malloc(tempvar.num_areas*sizeof(AREADATA));
  if(areasbbs==NULL)
  {
    fclose(areasfile);
    sprintf(fel.text,alerts[E_ALLOC_MEM],"load_areasbbs()");
    log(NULL);
    return(FALSE);
  }
  counter=NOLL;
  fgets(buffer,MAXSTRING,areasfile);
  size+=strlen("Choose Area");
  size++;
  while(fgets(buffer,MAXSTRING,areasfile)!=NULL)
  {
    sscanf(buffer,"%s %s ",temp1,temp2);
    if(isalpha(*temp1))
    {
      size++;
      areasbbs[counter].newmsg=NOLL;
      strncpy(areasbbs[counter].text,temp1,MAXSTRING);
      strncpy(areasbbs[counter].area,temp2,ROWSIZE);
      if(strlen(temp2)<SIZE_AREA)
        size+=strlen(temp2);
      else
        size+=SIZE_AREA;
      counter++;
    }
  }
  size++;
  arealist=Malloc(size);
  if(arealist!=NULL)
  {
    strcpy(arealist,"Choose Area");
    for(counter=0;counter<tempvar.num_areas;counter++)
      strcat(arealist,"|"),strncat(arealist,areasbbs[counter].area,SIZE_AREA);
  }
  
  return(TRUE);
}

/********************************************************************/
/********************************************************************/
int open_area(int areanumber)
{
  char temp[MAXSTRING];
  
  strcpy(temp,areasbbs[areanumber].text);
  strcat(temp,HEADEREXT);
  hdrfile=fopen(temp,"ab");
  if(hdrfile==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],temp,"open_area()");
    log(NULL);
    return(FALSE);
  }
  rewind(hdrfile);
  fseek(hdrfile,0,SEEK_END);
  strcpy(temp,areasbbs[areanumber].text);
  strcat(temp,MESSAGEEXT);
  msgfile=fopen(temp,"ab");
  if(msgfile==NULL)
  {
    fclose(hdrfile);
    fclose(textfile);
    sprintf(fel.text,alerts[E_OPEN_FILE],temp,"open_area()");
    log(NULL);
    return(FALSE);
  }
  rewind(msgfile);
  fseek(msgfile,0,SEEK_END);
  return(TRUE);
}

/********************************************************************/
/* Loads the LED.NEW file and changes it depending on what areas    */
/* Messages has been imported in.                                   */
/********************************************************************/
int change_lednew()
{
  FILE *lednewfile;
  char area[MAXSTRING];
  int exit=FALSE,temp,counter;
  int messnum,areaflag;
  
  lednewfile=fopen(config->lednewfile,"r");
  if(lednewfile==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],config->lednewfile,"change_lednew(read)");
    log(NULL);
    return(FAIL);
  }
  
  areamnums=Malloc(tempvar.num_areas*sizeof(int));
  if(areamnums==NULL)
  {
    fclose(lednewfile);
    sprintf(fel.text,alerts[E_ALLOC_MEM],"change_lednew()");
    log(NULL);
    return(FALSE);
  }
  counter=NOLL;
  exit=FALSE;
  while(!exit)
  {
    temp=fscanf(lednewfile,"%s  %d %d",area,&messnum,&areaflag);
    if(temp==3)
    {
      areamnums[counter]=messnum;
      areasbbs[counter].newmsg|=areaflag;
      counter++;
    }
    else
      exit=TRUE;
  }
  fclose(lednewfile);
  lednewfile=fopen(config->lednewfile,"w");
  if(lednewfile==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],config->lednewfile,"change_lednew(write)");
    log(NULL);
    return(FAIL);
  }
  for(counter=NOLL;counter<tempvar.num_areas;counter++)
  {
    if(counter!=NOLL)
    {
      fputc('\n',lednewfile);
      fprintf(lednewfile,"%s  %d %d",areasbbs[counter].area,areamnums[counter],areasbbs[counter].newmsg);
    }
    else
    {
      fprintf(lednewfile,"%s  %d %d",LN_NETMAIL,areamnums[counter],areasbbs[counter].newmsg);
    }
  }
  Mfree(areamnums);
  fclose(lednewfile);
}