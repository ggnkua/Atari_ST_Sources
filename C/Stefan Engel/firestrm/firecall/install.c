#include "firecall.h"
#include <dos.h>
/********************************************************************/
/********************************************************************/
#define INSTALL
#define VERSION_070    "FC 0.70"
#define VERSION_072    "FC 0.72"
/********************************************************************/
/********************************************************************/
typedef struct
{
  int                type;
  char               data1[255],
                     data2[255];
}EVENT_072;

typedef struct
{
  char               name[SIZE_NAME],
                     info1[SIZE_NAME],
                     info2[SIZE_NAME],
                     info3[SIZE_NAME],
                     date[SIZE_TIME],
                     number[SIZE_NUMB];
  int                times,
                     flags;
}PHONE_067;

typedef struct
{
  char               name[SIZE_NAME],
                     adr1[SIZE_NAME],
                     adr2[SIZE_NAME],
                     adr3[SIZE_NAME],
                     key[SIZE_NAME],
                     messwait[SIZE_NAME],
                     portinit[SIZE_NAME],
                     port[13];
  int                log_number;
  int                save_exit   :1;
  int                export_type;                     
}CONFIG_067;

typedef struct
{
  char               id[SIZE_ID],
                     name[SIZE_NAME],
                     adr1[SIZE_NAME],
                     adr2[SIZE_NAME],
                     adr3[SIZE_NAME],
                     key[SIZE_NAME],
                     messwait[SIZE_NAME],
                     portinit[SIZE_NAME],
                     dialcommand[SIZE_NAME],
                     linecommand[SIZE_NAME],
                     port[13];
  int                log_number;
  int                save_exit   :1;
  int                export_type;                     
}CONFIG_070;
/********************************************************************/
/********************************************************************/
char       system_dir[MAXSTRING];
char       *data,*data2;
CONFIG     new_config;
PHONE_DATA *new_phone;

/********************************************************************/
/* Huvud-funktionen, dvs den funktion som startar upp allt          */
/********************************************************************/
int main(int argc, char *argv[])
{
  init_default(argc, argv);
  printf("*************************************************\n");
  printf("** FireSTorm Caller installation Procedure     **\n");
  printf("** Programmed by: Christian Andersson          **\n");
  printf("*************************************************\n");
  convert_config(load_datafile(CONFIGFILE,(char **)&data,NOLL));
  convert_phone(load_datafile(DATAFILE,(char **)&data,NOLL));
  printf("\nPress any key to exit\n");
  getch();
  return(NOLL);
}

/********************************************************************/
/********************************************************************/
int init_default(int argc, char *argv[])
{
  strcpy(system_dir,"A:");
  system_dir[0]=Dgetdrv()+'A';
  Dgetpath(system_dir+2,0);
  strcat(system_dir,"\\FIRECONF\\");
  return(TRUE);
}

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
    printf("Could not open file:%s\n",namn);
    return(FALSE);
  }
  rewind(file);
  fseek(file,NOLL,SEEK_END);
  size=ftell(file);
  rewind(file);
  if((fsize!=NOLL)&&(fsize!=size))
  {
    fclose(file);
    printf("Could not find the size of the file: %s\n",namn);
    return(FAIL);
  }
  if(*memory==NULL)
    *memory=(char *)Malloc(size);
  if(*memory==NULL)
  {
    fclose(file);
    printf("Could not allocate enough memory for file: %s\n",namn);
    return(FAIL);
  }
  if(fread(*memory,1,size,file)!=size)
  {
    fclose(file);
    printf("Could not read from file: %s\n",namn);
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
    printf("could not open file: %s\n",namn);
    return(FALSE);
  }
  rewind(file);
  fseek(file,NOLL,SEEK_END);
  if(fwrite(memory,1,fsize,file)!=fsize)
  {
    fclose(file);
    printf("Could not write to file: %s\n",namn);
    return(FALSE); 
  }

  fclose(file);
  return(TRUE);
}

/********************************************************************/
/********************************************************************/
int convert_config(long size)
{
  strcpy(new_config.id,VERSION_CFG);
  if(size==FAIL)
  {
    printf("Installation aborted\n");
    return(FALSE);
  }
  else if(size==FALSE)
  {
    printf("creating a (%s) config\n",VERSION_CFG);
    strcpy(new_config.name,"FireSTorm (Name)");
    strcpy(new_config.adr1,"Streetadress");
    strcpy(new_config.adr2,"Postalcode, City");
    strcpy(new_config.adr3,"Country");
    strcpy(new_config.key,"Key");
    strcpy(new_config.messwait,"NMBR = ");
    strcpy(new_config.portinit,"atz");
    strcpy(new_config.dialcommand,"atdt");
    strcpy(new_config.linecommand,"ath1");
    strcpy(new_config.port,"no port");
    new_config.port_speed=0;
    new_config.log_number=LOG_SIZE;
    new_config.save_exit=FALSE;
    new_config.export_type=NOLL;
    save_datafile(TRUE,CONFIGFILE,(char *)&new_config,sizeof(CONFIG));
  }
  else if(!strcmp(((CONFIG *)data)->id,VERSION_CFG))
  {
    printf("The Config is of the right type (%s), no need to convert\n",VERSION_CFG);
  }
  else if((!strcmp(((CONFIG *)data)->id,VERSION_070))||(size==sizeof(CONFIG_067)))
  {
    printf("converting a ( %s ) config to an ( %s ) config\n",VERSION_070,VERSION_CFG);
    strcpy(new_config.name,((CONFIG_070 *)data)->name);
    strcpy(new_config.adr1,((CONFIG_070 *)data)->adr1);
    strcpy(new_config.adr2,((CONFIG_070 *)data)->adr2);
    strcpy(new_config.adr3,((CONFIG_070 *)data)->adr3);
    strcpy(new_config.key,((CONFIG_070 *)data)->key);
    strcpy(new_config.portinit,((CONFIG_070 *)data)->portinit);
    strcpy(new_config.messwait,((CONFIG_070 *)data)->messwait);
    strcpy(new_config.dialcommand,((CONFIG_070 *)data)->dialcommand);
    strcpy(new_config.linecommand,((CONFIG_070 *)data)->linecommand);
    strcpy(new_config.port,((CONFIG_070 *)data)->port);
    new_config.port_speed=19200;
    new_config.log_number=((CONFIG_070*)data)->log_number;
    new_config.save_exit=((CONFIG_070*)data)->save_exit;
    new_config.export_type=((CONFIG_070*)data)->export_type;
    save_datafile(TRUE,CONFIGFILE,(char *)&new_config,sizeof(CONFIG));
  }
  else if(size==sizeof(CONFIG_067))
  {
    printf("converting a ( <=0.67 ) config to an (%s) config\n",VERSION_CFG);
    strcpy(new_config.name,((CONFIG_067 *)data)->name);
    strcpy(new_config.adr1,((CONFIG_067 *)data)->adr1);
    strcpy(new_config.adr2,((CONFIG_067 *)data)->adr2);
    strcpy(new_config.adr3,((CONFIG_067 *)data)->adr3);
    strcpy(new_config.key,((CONFIG_067 *)data)->key);
    strcpy(new_config.portinit,((CONFIG_067 *)data)->portinit);
    strcpy(new_config.messwait,((CONFIG_067 *)data)->messwait);
    strcpy(new_config.port,((CONFIG_067 *)data)->port);
    strcpy(new_config.dialcommand,"atdt");
    strcpy(new_config.linecommand,"ath1");
    new_config.port_speed=19200;
    new_config.log_number=((CONFIG_067*)data)->log_number;
    new_config.save_exit=((CONFIG_067*)data)->save_exit;
    new_config.export_type=((CONFIG_067*)data)->export_type;
    save_datafile(TRUE,CONFIGFILE,(char *)&new_config,sizeof(CONFIG));
  }
  else
  {
    printf("Unknown Config-type\n");
    printf("ID=%s\n",((CONFIG *)data)->id);
  }
  
  if(data!=NULL)
    Mfree(data);
  return(TRUE);
}

/********************************************************************/
/********************************************************************/
int convert_phone(long size)
{
  long phone_num,counter;
  data2=Malloc(SIZE_ID+phone_num*sizeof(PHONE_DATA));
  if(data2==NULL)
  {
    printf("Error allocating memory for new datafile\n");
    return(FALSE);
  }
  strcpy(data2,VERSION_DTA);
  new_phone=(PHONE_DATA *)(data2+SIZE_ID);
  if(size==FAIL)
  {
    printf("No Caller database to convert\n");
  }
  else if(!strcmp(data,VERSION_DTA))
  {
    printf("The database is of the right type (%s), no need to convert\n",data);
  }
  else if(!strcmp(data,VERSION_070))
  {
    printf("converting a (%S) database to an (%s) database\n",VERSION_070,VERSION_DTA);
    phone_num=(size-SIZE_ID)/sizeof(PHONE_067);
    save_datafile(TRUE,DATAFILE,(char *)data2,SIZE_ID+phone_num*sizeof(PHONE_DATA));
    for(counter=NOLL;counter<phone_num;counter++)
    {
      strcpy(new_phone[counter].name,((PHONE_067 *)data)[counter].name);
      strcpy(new_phone[counter].info1,((PHONE_067 *)data)[counter].info1);
      strcpy(new_phone[counter].info2,((PHONE_067 *)data)[counter].info2);
      strcpy(new_phone[counter].info3,((PHONE_067 *)data)[counter].info3);
      strcpy(new_phone[counter].date,((PHONE_067 *)data)[counter].date);
      strcpy(new_phone[counter].number,((PHONE_067 *)data)[counter].number);
      new_phone[counter].times=((PHONE_067 *)data)[counter].times;
      new_phone[counter].flags=((PHONE_067 *)data)[counter].flags;
      new_phone[counter].event_num=NOLL;
    }    
  }
  else if(size%sizeof(PHONE_067)==NOLL)
  {
    phone_num=size/sizeof(PHONE_067);
    printf("converting a ( <=0.67 ) database to an (%s) database\n",VERSION_DTA);
    for(counter=NOLL;counter<phone_num;counter++)
    {
      strcpy(new_phone[counter].name,((PHONE_067 *)data)[counter].name);
      strcpy(new_phone[counter].info1,((PHONE_067 *)data)[counter].info1);
      strcpy(new_phone[counter].info2,((PHONE_067 *)data)[counter].info2);
      strcpy(new_phone[counter].info3,((PHONE_067 *)data)[counter].info3);
      strcpy(new_phone[counter].date,((PHONE_067 *)data)[counter].date);
      strcpy(new_phone[counter].number,((PHONE_067 *)data)[counter].number);
      new_phone[counter].times=((PHONE_067 *)data)[counter].times;
      new_phone[counter].flags=((PHONE_067 *)data)[counter].flags;
    }
    save_datafile(TRUE,DATAFILE,(char *)data2,SIZE_ID+phone_num*sizeof(PHONE_DATA));
  }
  else
  {
    printf("Unknown Database-type\n");
    printf("ID=%s\n",data);
  }
  if(data!=NULL)
    Mfree(data);
  if(data2!=NULL)
    Mfree(data2-SIZE_ID);
  return(FALSE);
}