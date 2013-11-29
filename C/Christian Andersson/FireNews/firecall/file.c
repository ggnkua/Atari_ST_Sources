#include "firecall.h"
#include <dos.h>
/********************************************************************/
/* Laddar in en datafil till minnet och reserverar plats            */
/********************************************************************/
long int load_datafile(char *namn, char **memory,long int fsize)
{
  char     temp[MAXSTRING];
  FILE     *file;
  long int size;
  
  sprintf(temp,"%s%s",system_dir,namn);
  file=fopen(temp,"rb");
  if(file==NULL)
  {
    sprintf(temp,alerts[E_OPEN_FILE],namn,"load_datafile");
    alertbox(1,temp);
    return(FAIL);
  }
  rewind(file);
  fseek(file,NOLL,SEEK_END);
  size=ftell(file);
  rewind(file);
  if((fsize!=NOLL)&&(fsize!=size))
  {
    fclose(file);
    alertbox(1,alerts[E_READ_FILE]);
    return(FAIL);
  }
  if(*memory==NULL)
    *memory=(char *)Malloc(size);
  if(*memory==NULL)
  {
    fclose(file);
    alertbox(1,alerts[E_ALLOC_MEM]);
    return(FAIL);
  }
  if(fread(*memory,1,size,file)!=size)
  {
    fclose(file);
    alertbox(1,alerts[E_READ_FILE]);
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

  sprintf(temp,"%s%s",system_dir,namn);
  if(type)
    file=fopen(temp,"wb");
  else
    file=fopen(temp,"ab");
  if(file==NULL)
  {
    alertbox(1,alerts[E_OPEN_FILE]);
    return(FALSE);
  }
  rewind(file);
  fseek(file,NOLL,SEEK_END);
  if(fwrite(memory,1,fsize,file)!=fsize)
  {
    fclose(file);
    alertbox(1,alerts[E_WRITE_FILE]);
    return(FALSE); 
  }

  fclose(file);
  return(TRUE);
}

/********************************************************************/
/* load_list() Laddar in Nummer-Listan                              */
/********************************************************************/
void load_list(void)
{
  FILE *file;
  char temp[MAXSTRING];
  PHONE_DATA *real_dta;
  
  sprintf(temp,"%s%s",system_dir,DATAFILE);
  file=fopen(temp,"rb");
  if(!file)
    return ;

  if(!fread(temp,SIZE_ID,1,file))
  {
    fclose(file);
    return;
  }
  temp[9]=0;

  tempvar.num_phones=0;
  if(strcmp(temp, VERSION_DTA))
  {
    convert_list(file,temp);
    fclose(file);
    return ;
  }

  real_dta=new_entity(&phonelist,sizeof(PHONE_DATA),SIZE_ALLOC);
  if(!real_dta)
  {
    // ERROR
    fclose(file);
    return;
  }
//printf("load_list  : reading first data\n");
  while(fread(real_dta,sizeof(PHONE_DATA),1,file))
  {
    tempvar.num_phones++;
    real_dta=new_entity(&phonelist,sizeof(PHONE_DATA),SIZE_ALLOC);
    if(!real_dta)
    {
      // ERROR
      fclose(file);
      return;
    }
//printf("load_list  : reading next data\n");
  }
//printf("load_list  : no new data to read\n");
  fclose(file);
  del_entity(&phonelist,tempvar.num_phones);
} 
/********************************************************************/
/* save_list() Sparar ut nummer listan till disk                    */
/********************************************************************/
int save_list(void)
{
  FILE *file;
  int number=0;
  PHONE_DATA *real_dta;
  char temp[MAXSTRING];

  sprintf(temp,"%s%s",system_dir,DATAFILE);
  file=fopen(temp,"wb");
  if(!file)
    return FALSE;

  fwrite(VERSION_DTA,SIZE_ID,1,file);
  while(number<tempvar.num_phones)
  {
//printf("Loop2 %d\n",number);
     real_dta=get_entity(phonelist,number);
     if(real_dta)
       fwrite(real_dta,sizeof(PHONE_DATA),1,file);
     else
       break;
     number++;
  }
  return TRUE;
}
/********************************************************************/
/* converts from an old list to an new list                         */
/********************************************************************/
#include "fireold.h"
void convert_list(FILE *file, char *version)
{
  PHONE_DATA *real_dta;
  if(!strcmp(version,VERSION_DATA_0_73))
  {
    PHONE_DATA_0_73 temp_dta;

    while(fread(&temp_dta,sizeof(PHONE_DATA_0_73),1,file))
    {
      real_dta=new_entity(&phonelist,sizeof(PHONE_DATA),SIZE_ALLOC);
      if(!real_dta)
      {
        // ERROR
        return;
      }
      tempvar.num_phones++;
      memcpy(real_dta->name,temp_dta.name,SIZE_NAME);
      memcpy(real_dta->info1,temp_dta.info1,SIZE_NAME);
      memcpy(real_dta->info2,temp_dta.info2,SIZE_NAME);
      memcpy(real_dta->info3,temp_dta.info3,SIZE_NAME);
      memcpy(real_dta->date,temp_dta.date,13);
      memcpy(real_dta->number,temp_dta.number,SIZE_NUMB);
      strcpy(real_dta->notefile,"");
      real_dta->times=temp_dta.times;
      real_dta->flags=temp_dta.flags;
      real_dta->event_num=temp_dta.event_num;
    }
  }
}