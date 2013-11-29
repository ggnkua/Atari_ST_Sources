#include "firenews.h"
#include <dos.h>
#include "..\info\vaproto\vaproto.h"
#undef NOLL

void create_commentlist(void);
void create_comment_next(NewsHeader *, int, int);

/********************************************************************/
/* Laddar in en datafil till minnet och reserverar plats            */
/********************************************************************/
long load_datafile(char *path,char *namn, char **memory,long int fsize)
{
  char     temp[MAXSTRING+1];
  FILE     *file;
  long int size;
  
  if(path==NULL)
    strcpy(temp,system_dir);
  else
    strcpy(temp,path);
    
  strcat(temp,namn);
  file=fopen(temp,"rb");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],namn,"load_datafile(1)");
    alertbox(1,fel.text);
    Return FAIL;
  }
  rewind(file);
  fseek(file,0,SEEK_END);
  size=ftell(file);
  rewind(file);
  if((fsize!=0)&&(fsize!=size))
  {
    fclose(file);
    sprintf(fel.text,alerts[E_READ_FILE],namn,"load_datafile(2)");
    alertbox(1,fel.text);
    Return FAIL;
  }
  if(*memory==NULL)
    *memory=(char *)calloc(1,size+1);
  if(*memory==NULL)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_ALLOC_MEM],"load_datafile(3)");
    alertbox(1,fel.text);
    Return FAIL;
  }
  if(fread(*memory,1,size,file)!=size)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_READ_FILE],namn,"load_datafile(4)");
    alertbox(1,fel.text);
    Return FAIL; 
  }
  fclose(file);
  if(fsize)
  {
    Return TRUE;
  }
  else
  {
    Return size;
  }
}

/********************************************************************/
/* Sparar en Datafil fr†n minnet                                    */
/********************************************************************/
int save_datafile(int type, char *path, char *namn, char *memory,long int fsize)
{
  char     temp[MAXSTRING+1];
  FILE     *file;
  short data[8];
  
  if(memory==NULL)
  {
    Return FALSE;
  }

  if(path==NULL)
    strcpy(temp,system_dir);
  else
    strcpy(temp,path);

  strcpy(message,temp);
  strcat(temp,namn);
  if(type)
    file=fopen(temp,"wb");
  else
    file=fopen(temp,"ab");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],namn,"save_datafile()");
    alertbox(1,fel.text);
    Return FALSE;
  }
  rewind(file);
  fseek(file,0,SEEK_END);
  if(fwrite(memory,1,fsize,file)!=fsize)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_WRITE_FILE],namn,"save_datafile()");
    alertbox(1,fel.text);
    Return FALSE; 
  }

  ext_id = appl_find( avserver );
  if( ext_id > FAIL)
  {
    data[0]=(short)AV_PATH_UPDATE;
    data[1]=(short)ap_id;
    data[2]=(short)0;
    data[3]=(short)message >> 16;
    data[4]=(short)message & 0xffff;
    data[5]=(short)0;
    data[6]=(short)0;
    data[7]=(short)0;
    appl_write(ext_id,16,data);
  }
  fclose(file);
  Return TRUE;
}

/********************************************************************/
/* Ladda in active filen i minnet                                   */
/********************************************************************/
int load_active(void)
{

  FILE *file;
  int group=FALSE;
  if(!config.newsdir[0])
  {
    Return FAIL;
  }

  strcpy(tempvar.lastpath,config.newsdir);
  strcat(tempvar.lastpath,ACTIVEFILE);
  file=fopen(tempvar.lastpath,"r");
  if(!file)
  {
    Return FAIL;
  }

  if(active.servers!=NULL)
    free(active.servers),active.servers=NULL;
  free(&active.glist);
  free_list(&active.mlist);
  memset(&active,0,sizeof(ACTIVE));

  while(fgets(tempvar.tempstring,MAXSTRING,file))
  {
    strncpy(tempvar.temprow1,tempvar.tempstring+strspn(tempvar.tempstring," 	"),ROWSIZE);
    tempvar.temprow1[ROWSIZE]=0;
    if(!strncmp(ACTIVE_SERVER,tempvar.tempstring,strcspn(ACTIVE_SERVER," \n\r")))
      active.num_of_servers++;
    else if(!strncmp(ACTIVE_NEW,tempvar.temprow1,strcspn(ACTIVE_NEW," \n\r")))
      active.num_of_servers++;
    else if(!strncmp(ACTIVE_GROUP,tempvar.temprow1,strcspn(ACTIVE_GROUP," \n\r")))
      active.num_of_groups++;
  }

  rewind(file);
  
  if(!active.num_of_servers)
  {
    fclose(file);
    Return FALSE;
  }
  
  active.servers=(SERVERS *)calloc(active.num_of_servers,sizeof(SERVERS));
  if(!active.servers)
  {
    fclose(file);
    Return FALSE;
  }
  active.tempserver=&active.servers[active.serv_num];

  while(fgets(tempvar.tempstring,MAXSTRING,file))
  {
    strncpy(tempvar.temprow1,tempvar.tempstring+strspn(tempvar.tempstring," 	"),ROWSIZE);
    tempvar.temprow1[ROWSIZE]=0;
    if(!strncmp(ACTIVE_TIMEI,tempvar.temprow1,strcspn(ACTIVE_TIMEI," \n\r")))
    {
      sscanf(tempvar.temprow1,ACTIVE_TIMEI,&active.time);
    }
    else if(!strncmp(ACTIVE_SERVER,tempvar.temprow1,strcspn(ACTIVE_SERVER," \n\r")))
    {
      group=FALSE;
      active.tempserver=&active.servers[active.serv_num];
      sscanf(tempvar.temprow1,ACTIVE_SERVER,active.tempserver->name,active.tempserver->file);
      active.serv_num++;
    }
    else if(!strncmp(ACTIVE_NEW,tempvar.temprow1,strcspn(ACTIVE_NEW," \n\r")))
    {
      group=FALSE;
      active.tempserver=&active.servers[active.serv_num];
      sscanf(tempvar.temprow1,ACTIVE_NEW,active.tempserver->name);
      active.serv_num++;
    }
    else if(!strncmp(ACTIVE_GET_GROUP,tempvar.temprow1,strcspn(ACTIVE_GET_GROUP," \n\r")))
      active.tempserver->get_new_group=TRUE;
    else if(!strncmp(ACTIVE_GET_DESC,tempvar.temprow1,strcspn(ACTIVE_GET_DESC," \n\r")))
      active.tempserver->get_description=TRUE;
    else if(!strncmp(ACTIVE_DATE,tempvar.temprow1,strcspn(ACTIVE_DATE," \n\r")))
    {
      if(group)
        sscanf(tempvar.temprow1,ACTIVE_DATE,active.tempgroup->date,active.tempgroup->time,active.tempgroup->zone);
      else
        sscanf(tempvar.temprow1,ACTIVE_DATE,active.tempserver->date,active.tempserver->time,active.tempserver->zone);
    }
    else if(!strncmp(ACTIVE_GROUP,tempvar.temprow1,strcspn(ACTIVE_GROUP," \n\r")))
    {
      group=TRUE;
      active.tempgroup=new_entity(&active.glist,sizeof(GROUPS),active.num_of_groups);
      if(!active.tempgroup)
      {
        fclose(file);
        free_list(&active.glist);
        Return FALSE;
      }
      sscanf(tempvar.temprow1,ACTIVE_GROUP,active.tempgroup->groupname,active.tempgroup->filename,&(active.tempgroup->group_message));
      active.tempgroup->serv_num=active.serv_num-1;
      active.group_num++;
    }
    else if(!strncmp(ACTIVE_CURRENT,tempvar.temprow1,strcspn(ACTIVE_CURRENT," \n\r")))
    {
      if(group)
        sscanf(tempvar.temprow1,ACTIVE_CURRENT,&(active.tempgroup->msg_num));
    }
    else if(!strncmp(ACTIVE_DESC,tempvar.temprow1,strcspn(ACTIVE_DESC," \n\r")))
    {
      tempvar.temp1=strcspn(tempvar.temprow1," \n\r");
      tempvar.temp2=tempvar.temp1+strspn(tempvar.temprow1+tempvar.temp1," 	");
      tempvar.temprow1[strcspn(tempvar.temprow1,"\n\r")]=EOL;
      if(group)
      {
        strncpy(active.tempgroup->description,tempvar.temprow1+tempvar.temp2,ROWSIZE);
        active.tempgroup->description[ROWSIZE]=EOL;
      }
      else
      {
        strncpy(active.tempserver->d_desc,tempvar.temprow1+tempvar.temp2,ROWSIZE);
        active.tempserver->d_desc[ROWSIZE]=EOL;
      }
    }
    else if(!strncmp(ACTIVE_MAILTO,tempvar.temprow1,strcspn(ACTIVE_MAILTO," \n\r")))
    {
      tempvar.temp1=strcspn(tempvar.temprow1," \n\r");
      tempvar.temp2=tempvar.temp1+strspn(tempvar.temprow1+tempvar.temp1," 	");
      tempvar.temprow1[strcspn(tempvar.temprow1,"\n\r")]=EOL;
      if(group)
      {
        strncpy(active.tempgroup->mailto,tempvar.temprow1+tempvar.temp2,ROWSIZE);
        active.tempgroup->mailto[ROWSIZE]=EOL;
      }
      else
      {
        strncpy(active.tempserver->d_mailto,tempvar.temprow1+tempvar.temp2,ROWSIZE);
        active.tempserver->d_mailto[ROWSIZE]=EOL;
      }
    }
    else if(!strncmp(ACTIVE_DAYS,tempvar.temprow1,strcspn(ACTIVE_DAYS," \n\r")))
    {
      if(group)
        sscanf(tempvar.temprow1,ACTIVE_DAYS,&(active.tempgroup->days));
      else
        sscanf(tempvar.temprow1,ACTIVE_DAYS,&(active.tempserver->d_days));
    }
    else if(!strncmp(ACTIVE_MDAYS,tempvar.temprow1,strcspn(ACTIVE_MDAYS," \n\r")))
    {
      if(group)
        sscanf(tempvar.temprow1,ACTIVE_MDAYS,&(active.tempgroup->max_day));
      else
        sscanf(tempvar.temprow1,ACTIVE_MDAYS,&(active.tempserver->d_max_days));
    }
    else if(!strncmp(ACTIVE_HONLY,tempvar.temprow1,strcspn(ACTIVE_HONLY," \n\r")))
    {
      if(group)
        active.tempgroup->f_header=TRUE;
      else
        active.tempserver->d_f_header=TRUE;
    }
    else if(!strncmp(ACTIVE_RONLY,tempvar.temprow1,strcspn(ACTIVE_RONLY," \n\r")))
    {
      if(group)
        active.tempgroup->f_ronly=TRUE;
      else
        active.tempserver->d_f_ronly=TRUE;
    }
    else if(!strncmp(ACTIVE_RESCAN,tempvar.temprow1,strcspn(ACTIVE_RESCAN," \n\r")))
    {
      if(group)
        active.tempgroup->f_rescan=TRUE;
      else
        active.tempserver->d_f_rescan=TRUE;
    }
  }
  fclose(file);
  if(active.group_num)
    active.glist->used=active.group_num;
  menu_ienable(menu_tree,MENU_AREA_SUBSCR,TRUE);
  menu_ienable(menu_tree,MENU_AREA_OPEN,TRUE);
  menu_ienable(menu_tree,MENU_OPEN_MESS,TRUE);
  active.group_num=0;
  active.serv_num=0;
  active.msg_num=0;
  Return TRUE;
}

/********************************************************************/
/* Save ACTIVE file                                                 */
/********************************************************************/
int save_active(void)
{
  FILE *file;
  SERVERS *server;
  GROUPS  *group;
  short data[8];
  
  if(!config.newsdir[0])
  {
    Return FAIL;
  }
  strcpy(tempvar.lastpath,config.newsdir);
  strcat(tempvar.lastpath,ACTIVEFILE);
  strcat(tempvar.lastpath,".OLD");
  remove(tempvar.lastpath);
  strcpy(tempvar.lastfile,config.newsdir);
  strcat(tempvar.lastfile,ACTIVEFILE);
  rename(tempvar.lastfile,tempvar.lastpath);
  
  strcpy(tempvar.lastpath,config.newsdir);
  strcat(tempvar.lastpath,ACTIVEFILE);
  file=fopen(tempvar.lastpath,"w");
  if(!file)
  {
    Return FAIL;
  }
  server=active.servers;
  if(active.time>0)
    fprintf(file,ACTIVE_TIMEO,'+',active.time);
  else if(active.time<0)
    fprintf(file,ACTIVE_TIMEO,'-',-active.time);
  
  for(tempvar.temp1=0; tempvar.temp1<active.num_of_servers;tempvar.temp1++)
  {
    if(!server->file[0])
      fprintf(file,ACTIVE_NEW,server->name);
    else
      fprintf(file,ACTIVE_SERVER,server->name,server->file);
    fprintf(file,"	"),fprintf(file,ACTIVE_DATE,server->date,server->time,server->zone);
    if(server->get_new_group)
      fprintf(file,"	"),fprintf(file,ACTIVE_GET_GROUP);
    if(server->get_description)
      fprintf(file,"	"),fprintf(file,ACTIVE_GET_DESC);
    
    if(server->d_desc[0])
      fprintf(file,"	"),fprintf(file,ACTIVE_DESC,server->d_desc);
    if(server->d_mailto[0])
      fprintf(file,"	"),fprintf(file,ACTIVE_MAILTO,server->d_mailto);
    if(server->d_days)
      fprintf(file,"	"),fprintf(file,ACTIVE_DAYS,server->d_days);
    if(server->d_max_days)
      fprintf(file,"	"),fprintf(file,ACTIVE_MDAYS,server->d_max_days);
    if(server->d_f_header)
      fprintf(file,"	"),fprintf(file,ACTIVE_HONLY);
    if(server->d_f_ronly)
      fprintf(file,"	"),fprintf(file,ACTIVE_RONLY);
    if(server->d_f_rescan)
      fprintf(file,"	"),fprintf(file,ACTIVE_RESCAN);
    for(tempvar.temp2=0;tempvar.temp2<active.num_of_groups;tempvar.temp2++)
    {
      group=get_entity(active.glist,tempvar.temp2);
      if(group)
      {
        if(group->serv_num==tempvar.temp1)
        {
          fprintf(file,"	"),fprintf(file,ACTIVE_GROUP,group->groupname,group->filename,group->group_message);
          if((group->date[0])&&(group->time[0]))
            fprintf(file,"		"),fprintf(file,ACTIVE_DATE,group->date,group->time,group->zone);
          if(group->description[0])
            fprintf(file,"		"),fprintf(file,ACTIVE_DESC,group->description);
          if(group->mailto[0])
            fprintf(file,"		"),fprintf(file,ACTIVE_MAILTO,group->mailto);
          if(group->days)
            fprintf(file,"		"),fprintf(file,ACTIVE_DAYS,group->days);
          if(group->max_day)
            fprintf(file,"		"),fprintf(file,ACTIVE_MDAYS,group->max_day);
          if(group->msg_num)
            fprintf(file,"		"),fprintf(file,ACTIVE_CURRENT,group->msg_num);
          if(group->f_header)
            fprintf(file,"		"),fprintf(file,ACTIVE_HONLY);
          if(group->f_ronly)
            fprintf(file,"		"),fprintf(file,ACTIVE_RONLY);
          if(group->f_rescan)
            fprintf(file,"		"),fprintf(file,ACTIVE_RESCAN);
        }
      }
    }
    server++;
  }
  ext_id = appl_find( avserver );
  if( ext_id > FAIL)
  {
    strcpy(message,config.newsdir);
    data[0]=(short)AV_PATH_UPDATE;
    data[1]=(short)ap_id;
    data[2]=(short)0;
    data[3]=(short)message >> 16;
    data[4]=(short)message & 0xffff;
    data[5]=(short)0;
    data[6]=(short)0;
    data[7]=(short)0;
    appl_write(ext_id,16,data);
  }
  fclose(file);
  Return TRUE;
}

/********************************************************************/
/* Execute program                                                  */
/********************************************************************/
int execute(char program[MAXSTRING],char command[MAXSTRING],int multi)
{
  char comstring[MAXSTRING+1];

  if(!multi)
  {
//    hide_dialog(NULL);
    strncpy(comstring," ",MAXSTRING);
    comstring[MAXSTRING]=EOL;
    strncat(comstring,command,MAXSTRING);
    comstring[MAXSTRING]=EOL;
    Pexec(0,program,comstring,NULL);
    menu_bar(menu_tree, 1);
    redraw_window(NULL);
//    unhide_dialog(NULL);  
  }
  Return TRUE;
}

/********************************************************************/
/* Laddar in delar av Ant-Mail:s anv„ndar-info                      */
/********************************************************************/
int load_antmail(void)
{
  FILE *antmail;
  char *test;

  if(config.mailtype!=MAILTYPE_ANTMAIL)
  {
    Return FALSE;
  }
  if(!config.maildata[0])
  {
    Return FALSE;
  }
  strcpy(tempvar.lastpath,config.maildata);
  antmail=fopen(tempvar.lastpath,"r");
  if(!antmail)
  {
    Return FALSE;
  }
  tempvar.tempcounter=0;
  while(fgets(tempvar.tempstring,MAXSTRING,antmail))
  {
    if(tempvar.tempcounter==ANT_PATH_NUM)
    {
      test=(char*)strrchr(tempvar.tempstring,(int)'\\');
      if(test)
        test[1]=EOL;
      else
        tempvar.tempstring[0]=0;
      strcpy(tempvar.mailpath,tempvar.tempstring);
    }
      
    tempvar.tempcounter++;
  }
  fclose(antmail);
  Return TRUE;
}

/********************************************************************/
/********************************************************************/
int load_newsie(void)
{
  if(config.mailtype!=MAILTYPE_NEWSIE)
  {
    Return FALSE;
  }
  if(!config.maildata[0])
  {
    Return FALSE;
  }
  strcpy(tempvar.mailpath,config.maildata);
  ((char *)strrchr(tempvar.mailpath,'\\'))[1]='\0';
  Return TRUE;
}

/********************************************************************/
/********************************************************************/
int load_infitra(void)
{
  if(config.mailtype!=MAILTYPE_INFITRA)
  {
    Return FALSE;
  }
  if(!config.maildata[0])
  {
    Return FALSE;
  }
  strcpy(tempvar.mailpath,config.maildata);
  ((char *)strrchr(tempvar.mailpath,'\\'))[1]='\0';
  Return TRUE;
}

/********************************************************************/
/********************************************************************/
int load_mymail(void)
{
  if(config.mailtype!=MAILTYPE_MYMAIL)
  {
    Return FALSE;
  }
  if(!config.maildata[0])
  {
    Return FALSE;
  }
  Return FALSE;
}

/********************************************************************/
/* Laddar ett meddelande till visar f”nstret                        */
/********************************************************************/
int load_message()
{
  FILE *file;
  long mem;
  char *pointer;
  int count1;
  
  mem=(long)Malloc(-1);
  active.tempgroup=get_entity(active.glist,active.group_num);
  strcpy(tempvar.lastpath,config.newsdir);
  strcat(tempvar.lastpath,active.tempgroup->filename);
  strcat(tempvar.lastpath,MESSAGEEXT);
  file=fopen(tempvar.lastpath,"rb");
  if(file==NULL)
  {
#ifdef LOGGING
Log(LOG_ERROR,"could not open file: %s",tempvar.lastpath);
#endif
    Return FAIL;
  }
 
  active.tempmessage=get_entity(active.mlist,active.msg_num);
  if(!active.tempmessage)
  {
#ifdef LOGGING
Log(LOG_ERROR,"could not get current message-info: %d",active.msg_num);
#endif
    close(file);
    Return FAIL;
  }
  if(active.msg_text)
    free(active.msg_text),active.msg_text=NULL;
  active.msg_text=(char *)calloc(1,active.tempmessage->length+1);
  if(!active.msg_text)
  {
#ifdef LOGGING
Log(LOG_ERROR,"Could not allocate enough memory: %l",active.tempmessage->length+1);
#endif
    fclose(file);
    Return FAIL;
  }

  fseek(file,active.tempmessage->offset,SEEK_SET);
  tempvar.temp1=fread(active.msg_text,1,active.tempmessage->length,file);
  if(tempvar.temp1!=active.tempmessage->length)
  {
#ifdef LOGGING
Log(LOG_ERROR,"Problem loading in message: %l",tempvar.temp1);
#endif
    free(active.msg_text),active.msg_text=NULL;
    fclose(file);
    Return FAIL;
  }
  active.msg_text[active.tempmessage->length]=EOL;
  pointer=active.msg_text;
  strcpy(tempvar.homepage,"");
  count1=0;
  while(1)
  {
    while((*pointer!='\n')&&(*pointer!='\r'))
    {
      if(count1<MAXSTRING)
        tempvar.tempstring[count1++]=*pointer;
      pointer++;
    }
    if((*pointer=='\r')||(*pointer=='\n'))
    {
      if(*(pointer-1)=='\n')
      {
        active.body_text=pointer;
        break;
      }

      tempvar.tempstring[count1]=0;
      if(!strncmp(MSG_HEAD_XURL,tempvar.tempstring,strcspn(MSG_HEAD_XURL," \n\r")+1))
      {
        sscanf(tempvar.tempstring,MSG_HEAD_XURL,tempvar.homepage);
      }
      pointer++;
      count1=0;
    }
  }
  fclose(file);
  
  active.tempgroup->msg_num=active.msg_num;
  
  Return TRUE;
}

/********************************************************************/
/* Sparar ett brev som fil                                          */
/********************************************************************/
int save_message(int msg_num)
{
  FILE *msg,*out;
  int  exit=FALSE;
  long size,readsize,writesize;
  short data[8];  
  sprintf(tempvar.lastpath,"%s%s",config.newsdir,"*.*");
  strcpy(tempvar.lastfile,"temp.msg");
  tempvar.tempcounter=0;
  fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_SAVE_MESS]);
  if(tempvar.tempcounter==FALSE)
  {
    Return FALSE;
  }
  ((char *)strrchr(tempvar.lastpath,'\\'))[1]='\0';
  strcpy(message,tempvar.lastpath);
  strcat(tempvar.lastpath,tempvar.lastfile);
  out=fopen(tempvar.lastpath,"w");
  if(!out)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],tempvar.lastfile,"save_message()");
    alertbox(1,fel.text);
    Return FALSE;
  }
  active.tempgroup=get_entity(active.glist,active.group_num);
  sprintf(tempvar.lastpath,"%s%s%s",config.newsdir,active.tempgroup->filename,MESSAGEEXT);
  msg=fopen(tempvar.lastpath,"rb");
  if(!msg)
  {
    fclose(out);
    strcat(tempvar.lastfile,active.tempgroup->filename);
    strcat(tempvar.lastfile,MESSAGEEXT);
    sprintf(fel.text,alerts[E_OPEN_FILE],tempvar.lastfile,"save_message");
    alertbox(1,fel.text);
    Return FALSE;
  }

  active.tempmessage=get_entity(active.mlist,msg_num);
  if(!active.tempmessage)
  {
    fclose(out);
    fclose(msg);
    Return FALSE;
  }

  fseek(msg,active.tempmessage->offset,SEEK_SET);
  size=active.tempmessage->length;
  
  while(!exit)
  {
    if(size>MAXSTRING+ROWSIZE)
      readsize=fread(tempvar.tempstring,1,MAXSTRING+ROWSIZE,msg);
    else
      readsize=fread(tempvar.tempstring,1,size,msg);
    if(!readsize && size)
    {
      strcat(tempvar.lastfile,active.tempgroup->filename);
      strcat(tempvar.lastfile,MESSAGEEXT);
      sprintf(fel.text,alerts[E_READ_FILE],tempvar.lastfile,"save_message");
      alertbox(1,fel.text);
      fclose(msg);
      fclose(out);
      Return FALSE;
    }
    writesize=fwrite(tempvar.tempstring,1,readsize,out);
    if(writesize!=readsize)
    {
      sprintf(fel.text,alerts[E_WRITE_FILE],tempvar.lastfile,"save_message");
      alertbox(1,fel.text);
      fclose(msg);
      fclose(out);
      Return FALSE;
    }
    size=size-readsize;
    if(size<=0)
      exit=TRUE;
  }

  ext_id = appl_find( avserver );
  if( ext_id > FAIL)
  {
    data[0]=(short)AV_PATH_UPDATE;
    data[1]=(short)ap_id;
    data[2]=(short)0;
    data[3]=(short)message >> 16;
    data[4]=(short)message & 0xffff;
    data[5]=(short)0;
    data[6]=(short)0;
    data[7]=(short)0;
    appl_write(ext_id,16,data);
  }
  
  fclose(msg);
  fclose(out);
  Return TRUE;
}

/********************************************************************/
/* Laddar in headern till gruppen                                   */
/********************************************************************/
int load_header(const int group_num)
{
  FILE *file;
  long size=0;
  active.tempgroup=get_entity(active.glist,group_num);
  if(!active.tempgroup)
  {
    active.num_of_messages=0;
    active.msg_num=0;
    Return FALSE;
  }
  
  sprintf(tempvar.tempstring,"%s%s%s",config.newsdir,active.tempgroup->filename,HEADEREXT);
  file=fopen(tempvar.tempstring,"rb");
  if(!file)
  {
    active.num_of_messages=0;
    active.msg_num=0;
    Return FALSE;
  }
  rewind(file);
  fseek(file,0,SEEK_END);
  size=ftell(file);
  rewind(file);
  
  if(!fread(tempvar.tempstring,4,1,file))
  {
    active.num_of_messages=0;
    active.msg_num=0;
    fclose(file);
    Return FALSE;
  }
  tempvar.tempstring[4]='\0';
  if(strcmp(NEWSID,tempvar.tempstring))
  {
    active.num_of_messages=0;
    active.msg_num=0;
    fclose(file);
    Return FALSE;
  }
  if(!fread(tempvar.tempstring,4,1,file))
  {
    active.num_of_messages=0;
    active.msg_num=0;
    fclose(file);
    Return FALSE;
  }
  tempvar.tempstring[4]='\0';
  if(strcmp(NEWSVER,tempvar.tempstring))
  {
    fclose(file);
    return(FALSE);
  }
  free_list(&active.mlist);
  free_list(&active.clist);
  size-=8;
  active.num_of_messages=size/sizeof(NewsHeader);
  active.msg_num=0;
  active.tempmessage=new_entity(&active.mlist,sizeof(NewsHeader),active.num_of_messages);
  if(!active.tempmessage)
  {
    active.num_of_messages=0;
    active.msg_num=0;
    fclose(file);
    Return FALSE;
  }
  while( fread( active.tempmessage , sizeof( NewsHeader ) , 1 , file ) )
  {
    active.tempmessage->flags.prog_spec_0=FALSE;
    active.tempmessage->flags.prog_spec_1=FALSE;
    active.tempmessage->flags.prog_spec_2=FALSE;
    active.tempmessage->flags.prog_spec_3=FALSE;
    active.tempmessage->flags.prog_spec_4=FALSE;
    active.tempmessage->flags.prog_spec_5=FALSE;
    active.tempmessage->flags.prog_spec_6=FALSE;
    active.tempmessage->flags.prog_spec_7=FALSE;
    active.tempmessage->flags.prog_spec_8=FALSE;
    active.tempmessage->flags.prog_spec_9=FALSE;
    active.msg_num++;
    active.tempmessage=new_entity( &active.mlist , sizeof( NewsHeader ) , active.num_of_messages ) ;
    if(!active.tempmessage)
    {
      fclose(file);
      Return FALSE;
    }
  }
  del_entity(&active.mlist,active.msg_num);
  active.num_of_messages=active.msg_num;
  if(active.tempgroup->msg_num<active.msg_num)
    active.msg_num=active.tempgroup->msg_num;
  else
  {
    active.msg_num--;
    active.tempgroup->msg_num=active.msg_num;
  }
  fclose(file);
  if(config.show_comment)
    create_commentlist();
  Return TRUE;
}

/********************************************************************/
/********************************************************************/
int load_grouplist(int which,int ask)
{
  char *memory, *pointer,*startline;
  int temp;
  FILE *file;

  if(active.ungroups)
    free(active.ungroups),active.ungroups=NULL;

  strcpy(tempvar.lastpath,config.newsdir);
  strcat(tempvar.lastpath,active.servers[active.serv_num].file);
  if(which)
    strcat(tempvar.lastpath,GROUPEXT);
  else
    strcat(tempvar.lastpath,GROUPNEWEXT);
  file=fopen(tempvar.lastpath,"rb");
  if(!file)
  {
    if(!which)
      menu_ienable(menu_tree,MENU_AREA_NEW,FALSE);
    if(unsublist_win.status!=WINDOW_CLOSED)
      close_unsublistwin();
    Return FALSE;
  }
  fseek(file,0,SEEK_END);
  tempvar.temp1=ftell(file);
  if(tempvar.temp1<=0)
  {
    if(!which)
      menu_ienable(menu_tree,MENU_AREA_NEW,FALSE);
    fclose(file);
    if(unsublist_win.status!=WINDOW_CLOSED)
      close_unsublistwin();
    Return FALSE;
  }
  if(!which)
    menu_ienable(menu_tree,MENU_AREA_NEW,TRUE);
  if(ask)
  {
    if(alertbox(1,alerts[Q_LOOK_NEW_GROUP])==2)
    {
      fclose(file);
      if(unsublist_win.status!=WINDOW_CLOSED)
        close_unsublistwin();
      Return FALSE;
    }
  }
  memory=(char *)calloc(1,tempvar.temp1+1);
  if(memory==NULL)
  {
    fclose(file);
    if(unsublist_win.status!=WINDOW_CLOSED)
      close_unsublistwin();
    Return FALSE;
  }
  rewind(file);
  if(fread(memory,1,tempvar.temp1,file)!=tempvar.temp1)
  {
    Mfree(memory);
    fclose(file);
    if(unsublist_win.status!=WINDOW_CLOSED)
      close_unsublistwin();
    Return FALSE;
  }
  fclose(file);
  memory[tempvar.temp1]=EOL;

  pointer=memory;
  active.num_of_unsub_groups=0;
  while(*pointer)
  {
    if(*pointer=='\n')
      active.num_of_unsub_groups++;
    pointer++;
  }
  active.ungroups=(UNGROUPS *)calloc(active.num_of_unsub_groups+1,sizeof(UNGROUPS));
  if(!active.ungroups)
  {
    free(memory);
    fclose(file);
    if(unsublist_win.status!=WINDOW_CLOSED)
      close_unsublistwin();
    Return FALSE;
  }
  temp=0;
  pointer=startline=memory;
  while(*pointer)
  {
    if(*pointer=='\n')
    {
      *(pointer-1)=0;
      strncpy(active.ungroups[temp].groupname,startline,ROWSIZE);
      startline=pointer+1;
      temp++;
    }
    pointer++;
  }
  free(memory);
  
  return(TRUE);
}
/********************************************************************/
/* create_groupfilename: skapar ett nytt filnam f”r denna grupp     */
/********************************************************************/
char* create_groupfilename(char *groupname,char *filename)
{
  GROUPS *g;
  int temp1,temp2=TRUE;
  char *strptr=filename;
  for(temp1=0; groupname[temp1]!=EOL;temp1++)
  { 
    if(temp2)
    {
      *strptr++=groupname[temp1];
      temp2=FALSE;
    }
    else if(groupname[temp1]=='.')
      temp2=TRUE;
  }  
  *strptr=EOL;
  filename[7]=EOL;
  do
  {
    temp1=FALSE;
    for(temp2=0;temp2<active.num_of_groups;temp2++)
    {
      g=get_entity(active.glist,temp2);
      if(!strcmp(filename,g->filename))
      {
        temp1=TRUE;
        strptr = &( filename[ strlen( filename ) - 1 ] ) ;
        if( isdigit( *strptr ) )
        {
          /* Increment number if there already is one */
          (*strptr)++ ;
        }
        else
        {
          /* Add a 1 to the end */
          strcat( filename, "1" ) ;
        }
      }
    }
  }while(temp1);
  Return filename;
}

/********************************************************************/
/* load_config: Loads a text-based config into the system           */
/********************************************************************/
int load_config()
{
  char     temp[MAXSTRING+1],data[MAXSTRING+1];
  int      d1,d2,d3,d4;
  FILE     *file;

  init_config();

  sprintf(temp,"%s%s",system_dir,CONFIGFILE);
  file=fopen(temp,"r");
  if(file)
  {
    while(fgets(temp,MAXSTRING,file))
    {
      if(!strncmp(CONFIG_NAME,temp,strcspn(CONFIG_NAME," \n\r")+1))
      {
        strcpy(config.name,strchr(temp,'{')+1);
        ((char *)strrchr(config.name,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_ADRESS1,temp,strcspn(CONFIG_ADRESS1," \n\r")+1))
      {
        strcpy(config.adr1,strchr(temp,'{')+1);
        ((char *)strrchr(config.adr1,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_ADRESS2,temp,strcspn(CONFIG_ADRESS2," \n\r")+1))
      {
        strcpy(config.adr2,strchr(temp,'{')+1);
        ((char *)strrchr(config.adr2,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_ADRESS3,temp,strcspn(CONFIG_ADRESS3," \n\r")+1))
      {
        strcpy(config.adr3,strchr(temp,'{')+1);
        ((char *)strrchr(config.adr3,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_KEY,temp,strcspn(CONFIG_KEY," \n\r")+1))
      {
        strcpy(config.key,strchr(temp,'{')+1);
        ((char *)strrchr(config.key,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_EDITOR,temp,strcspn(CONFIG_EDITOR," \n\r")+1))
      {
        strcpy(config.editor,strchr(temp,'{')+1);
        ((char *)strrchr(config.editor,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_NNTPD,temp,strcspn(CONFIG_NNTPD," \n\r")+1))
      {
        strcpy(config.nntpd,strchr(temp,'{')+1);
        ((char *)strrchr(config.nntpd,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_SIG,temp,strcspn(CONFIG_SIG," \n\r")+1))
      {
        strcpy(config.signature,strchr(temp,'{')+1);
        ((char *)strrchr(config.signature,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_MAILTYPE,temp,strcspn(CONFIG_MAILTYPE," \n\r")+1))
      {
        strcpy(data,strchr(temp,'{')+1);
        ((char *)strrchr(data,'}'))[0]='\0';
        if(!strcmp(data,MAILTYPE_T_ANTMAIL))
          config.mailtype=MAILTYPE_ANTMAIL;
        else if(!strcmp(data,MAILTYPE_T_NEWSIE))
          config.mailtype=MAILTYPE_NEWSIE;
        else if(!strcmp(data,MAILTYPE_T_INFITRA))
          config.mailtype=MAILTYPE_INFITRA;
        else if(!strcmp(data,MAILTYPE_T_MYMAIL))
          config.mailtype=MAILTYPE_MYMAIL;
      }
      else if(!strncmp(CONFIG_MAILFILE,temp,strcspn(CONFIG_MAILFILE," \n\r")+1))
      {
        strcpy(config.maildata,strchr(temp,'{')+1);
        ((char *)strrchr(config.maildata,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_NEWS,temp,strcspn(CONFIG_NEWS," \n\r")+1))
      {
        strcpy(config.newsdir,strchr(temp,'{')+1);
        ((char *)strrchr(config.newsdir,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_EMAIL,temp,strcspn(CONFIG_EMAIL," \n\r")+1))
      {
        strcpy(config.email,strchr(temp,'{')+1);
        ((char *)strrchr(config.email,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_REPLY,temp,strcspn(CONFIG_REPLY," \n\r")+1))
      {
        strcpy(config.replyto,strchr(temp,'{')+1);
        ((char *)strrchr(config.replyto,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_STRINGSRV,temp,strcspn(CONFIG_STRINGSRV," \n\r")+1))
      {
        strcpy(data,strchr(temp,'{')+1);
        ((char *)strrchr(data,'}'))[0]='\0';
        strncpy(config.stringserver,data,SIZE_ID);
        config.stringserver[SIZE_ID]=0;
      }
      else if(!strncmp(CONFIG_REPLYSTR1,temp,strcspn(CONFIG_REPLYSTR1," \n\r")+1))
      {
        strcpy(config.replystring1,strchr(temp,'{')+1);
        ((char *)strrchr(config.replystring1,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_REPLYSTR2,temp,strcspn(CONFIG_REPLYSTR2," \n\r")+1))
      {
        strcpy(config.replystring2,strchr(temp,'{')+1);
        ((char *)strrchr(config.replystring2,'}'))[0]='\0';
      }
       else if(!strncmp(CONFIG_HOMEPAGE,temp,strcspn(CONFIG_HOMEPAGE," \n\r")+1))
      {
        strcpy(config.homepage,strchr(temp,'{')+1);
        ((char *)strrchr(config.homepage,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_REALNAME,temp,strcspn(CONFIG_REALNAME," \n\r")+1))
      {
        strcpy(config.real_name,strchr(temp,'{')+1);
        ((char *)strrchr(config.real_name,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_ORG,temp,strcspn(CONFIG_ORG," \n\r")+1))
      {
        strcpy(config.organization,strchr(temp,'{')+1);
        ((char *)strrchr(config.organization,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_USUBFONT,temp,strcspn(CONFIG_USUBFONT," \n\r")+1))
      {
        sscanf(temp,CONFIG_USUBFONT,&d1,config.unsubfontname);
        config.unsubfontsize=d1;
        strcpy(config.unsubfontname,strchr(temp,'{')+1);
        ((char *)strrchr(config.unsubfontname,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_SUBFONT,temp,strcspn(CONFIG_SUBFONT," \n\r")+1))
      {
        sscanf(temp,CONFIG_SUBFONT,&d1,config.subfontname);
        config.subfontsize=d1;
        strcpy(config.subfontname,strchr(temp,'{')+1);
        ((char *)strrchr(config.subfontname,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_MSGLFONT,temp,strcspn(CONFIG_MSGLFONT," \n\r")+1))
      {
        sscanf(temp,CONFIG_MSGLFONT,&d1,config.msglfontname);
        config.msglfontsize=d1;
        strcpy(config.msglfontname,strchr(temp,'{')+1);
        ((char *)strrchr(config.msglfontname,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_READFONT,temp,strcspn(CONFIG_READFONT," \n\r")+1))
      {
        sscanf(temp,CONFIG_READFONT,&d1,config.readfontname);
        config.readfontsize=d1;
        strcpy(config.readfontname,strchr(temp,'{')+1);
        ((char *)strrchr(config.readfontname,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_SERVFONT,temp,strcspn(CONFIG_SERVFONT," \n\r")+1))
      {
        sscanf(temp,CONFIG_SERVFONT,&d1,config.servfontname);
        config.servfontsize=d1;
        strcpy(config.servfontname,strchr(temp,'{')+1);
        ((char *)strrchr(config.servfontname,'}'))[0]='\0';
      }
      else if(!strncmp(CONFIG_USUBWIND,temp,strcspn(CONFIG_USUBWIND," \n\r")+1))
      {
        sscanf(temp,CONFIG_USUBWIND,&d1,&d2,&d3,&d4);
        config.usubw_xy[X]=d1;
        config.usubw_xy[Y]=d2;
        config.usubw_xy[W]=d3;
        config.usubw_xy[H]=d4;
      }
      else if(!strncmp(CONFIG_SUBWIND,temp,strcspn(CONFIG_SUBWIND," \n\r")+1))
      {
        sscanf(temp,CONFIG_SUBWIND,&d1,&d2,&d3,&d4);
        config.subsw_xy[X]=d1;
        config.subsw_xy[Y]=d2;
        config.subsw_xy[W]=d3;
        config.subsw_xy[H]=d4;
      }
      else if(!strncmp(CONFIG_MSGLWIND,temp,strcspn(CONFIG_MSGLWIND," \n\r")+1))
      {
        sscanf(temp,CONFIG_MSGLWIND,&d1,&d2,&d3,&d4);
        config.msglw_xy[X]=d1;
        config.msglw_xy[Y]=d2;
        config.msglw_xy[W]=d3;
        config.msglw_xy[H]=d4;
      }
      else if(!strncmp(CONFIG_READWIND,temp,strcspn(CONFIG_READWIND," \n\r")+1))
      {
        sscanf(temp,CONFIG_READWIND,&d1,&d2,&d3,&d4);
        config.readw_xy[X]=d1;
        config.readw_xy[Y]=d2;
        config.readw_xy[W]=d3;
        config.readw_xy[H]=d4;
      }
      else if(!strncmp(CONFIG_SERVWIND,temp,strcspn(CONFIG_SERVWIND," \n\r")+1))
      {
        sscanf(temp,CONFIG_SERVWIND,&d1,&d2,&d3,&d4);
        config.servw_xy[X]=d1;
        config.servw_xy[Y]=d2;
        config.servw_xy[W]=d3;
        config.servw_xy[H]=d4;
      }
      else if(!strncmp(CONFIG_SAVEXIT,temp,strcspn(CONFIG_SAVEXIT," \n\r")+1))
      {
        sscanf(temp,CONFIG_SAVEXIT,&d1);
        config.save_exit=d1;
      }
      else if(!strncmp(CONFIG_SAVEWIND,temp,strcspn(CONFIG_SAVEWIND," \n\r")+1))
      {
        sscanf(temp,CONFIG_SAVEWIND,&d1);
        config.save_window=d1;
      }
      else if(!strncmp(CONFIG_USECOMM,temp,strcspn(CONFIG_USECOMM," \n\r")+1))
      {
        sscanf(temp,CONFIG_USECOMM,&d1);
        config.use_comment=d1;
      }
      else if(!strncmp(CONFIG_SHOWCOMM,temp,strcspn(CONFIG_SHOWCOMM," \n\r")+1))
      {
        sscanf(temp,CONFIG_SHOWCOMM,&d1);
        config.show_comment=d1;
      }
      else if(!strncmp(CONFIG_RESCAN,temp,strcspn(CONFIG_RESCAN," \n\r")+1))
      {
        sscanf(temp,CONFIG_RESCAN,&d1);
        config.rescan_sub=d1;
      }
      else if(!strncmp(CONFIG_HIDEUUE,temp,strcspn(CONFIG_HIDEUUE," \n\r")+1))
      {
        sscanf(temp,CONFIG_HIDEUUE,&d1);
        config.hide_uue=d1;
      }
      else if(!strncmp(CONFIG_HIDEUEND,temp,strcspn(CONFIG_HIDEUEND," \n\r")+1))
      {
        sscanf(temp,CONFIG_HIDEUEND,&d1);
        config.hide_uuend=d1;
      }
      else if(!strncmp(CONFIG_HIDEHEAD,temp,strcspn(CONFIG_HIDEHEAD," \n\r")+1))
      {
        sscanf(temp,CONFIG_HIDEHEAD,&d1);
        config.hide_header=d1;
      }
      else if(!strncmp(CONFIG_QUOTEHEAD,temp,strcspn(CONFIG_QUOTEHEAD," \n\r")+1))
      {
        sscanf(temp,CONFIG_QUOTEHEAD,&d1);
        config.quote_header=d1;
      }
      else if(!strncmp(CONFIG_OPENGROUP,temp,strcspn(CONFIG_OPENGROUP," \n\r")+1))
      {
        sscanf(temp,CONFIG_OPENGROUP,&d1);
        config.open_group=d1;
      }
      else if(!strncmp(CONFIG_OPENMSG,temp,strcspn(CONFIG_OPENMSG," \n\r")+1))
      {
        sscanf(temp,CONFIG_OPENMSG,&d1);
        config.open_msg=d1;
      }
      else if(!strncmp(CONFIG_FKEYVA,temp,strcspn(CONFIG_FKEYVA," \n\r")+1))
      {
        sscanf(temp,CONFIG_FKEYVA,&d1);
        config.fkey_va=d1;
      }
      else if(!strncmp(CONFIG_UNKNOWN,temp,strcspn(CONFIG_UNKNOWN," \n\r")+1))
      {
        sscanf(temp,CONFIG_UNKNOWN,&d1);
        config.unknown_aes=d1;
      }
    }
  }

  
  if(config.readw_xy[X]+config.readw_xy[W]>screenx+screenw)
    config.readw_xy[X]=screenx+screenw-config.readw_xy[W];
  if(config.readw_xy[X]<screenx)
    config.readw_xy[X]=screenx,tempvar.conf_change=TRUE;
  if(config.readw_xy[X]+config.readw_xy[W]>screenw+screenx)
    config.readw_xy[W]=screenw+screenx-config.readw_xy[X],tempvar.conf_change=TRUE;
  if(config.readw_xy[Y]+config.readw_xy[H]>screeny+screenh)
    config.readw_xy[Y]=screeny+screenh-config.readw_xy[H];
  if(config.readw_xy[Y]<screeny)
    config.readw_xy[Y]=screeny,tempvar.conf_change=TRUE;
  if(config.readw_xy[Y]+config.readw_xy[H]>screenh+screeny)
    config.readw_xy[H]=screeny+screenh-config.readw_xy[Y],tempvar.conf_change=TRUE;

  if(config.subsw_xy[X]+config.subsw_xy[W]>screenx+screenw)
    config.subsw_xy[X]=screenx+screenw-config.subsw_xy[W];
  if(config.subsw_xy[X]<screenx)
    config.subsw_xy[X]=screenx,tempvar.conf_change=TRUE;
  if(config.subsw_xy[X]+config.subsw_xy[W]>screenw+screenx)
    config.subsw_xy[W]=screenw+screenx-config.subsw_xy[X],tempvar.conf_change=TRUE;
  if(config.subsw_xy[Y]+config.subsw_xy[H]>screeny+screenh)
    config.subsw_xy[Y]=screeny+screenh-config.subsw_xy[H];
  if(config.subsw_xy[Y]<screeny)
    config.subsw_xy[Y]=screeny,tempvar.conf_change=TRUE;
  if(config.subsw_xy[Y]+config.subsw_xy[H]>screenh+screeny)
    config.subsw_xy[H]=screeny+screenh-config.subsw_xy[Y],tempvar.conf_change=TRUE;

  if(config.usubw_xy[X]+config.usubw_xy[W]>screenx+screenw)
    config.usubw_xy[X]=screenx+screenw-config.usubw_xy[W];
  if(config.usubw_xy[X]<screenx)
    config.usubw_xy[X]=screenx,tempvar.conf_change=TRUE;
  if(config.usubw_xy[X]+config.usubw_xy[W]>screenw+screenx)
    config.usubw_xy[W]=screenw+screenx-config.usubw_xy[X],tempvar.conf_change=TRUE;
  if(config.usubw_xy[Y]+config.usubw_xy[H]>screeny+screenh)
    config.usubw_xy[Y]=screeny+screenh-config.usubw_xy[H];
  if(config.usubw_xy[Y]<screeny)
    config.usubw_xy[Y]=screeny,tempvar.conf_change=TRUE;
  if(config.usubw_xy[Y]+config.usubw_xy[H]>screenh+screeny)
    config.usubw_xy[H]=screeny+screenh-config.usubw_xy[Y],tempvar.conf_change=TRUE;

  if(config.msglw_xy[X]+config.msglw_xy[W]>screenx+screenw)
    config.msglw_xy[X]=screenx+screenw-config.msglw_xy[W];
  if(config.msglw_xy[X]<screenx)
    config.msglw_xy[X]=screenx,tempvar.conf_change=TRUE;
  if(config.msglw_xy[X]+config.msglw_xy[W]>screenw+screenx)
    config.msglw_xy[W]=screenw+screenx-config.msglw_xy[X],tempvar.conf_change=TRUE;
  if(config.msglw_xy[Y]+config.msglw_xy[H]>screeny+screenh)
    config.msglw_xy[Y]=screeny+screenh-config.msglw_xy[H];
  if(config.msglw_xy[Y]<screeny)
    config.msglw_xy[Y]=screeny,tempvar.conf_change=TRUE;
  if(config.msglw_xy[Y]+config.msglw_xy[H]>screenh+screeny)
    config.msglw_xy[H]=screeny+screenh-config.msglw_xy[Y],tempvar.conf_change=TRUE;

  if(config.servw_xy[X]+config.servw_xy[W]>screenx+screenw)
    config.servw_xy[X]=screenx+screenw-config.servw_xy[W];
  if(config.servw_xy[X]<screenx)
    config.servw_xy[X]=screenx,tempvar.conf_change=TRUE;
  if(config.servw_xy[X]+config.servw_xy[W]>screenw+screenx)
    config.servw_xy[W]=screenw+screenx-config.servw_xy[X],tempvar.conf_change=TRUE;
  if(config.servw_xy[Y]+config.servw_xy[H]>screeny+screenh)
    config.servw_xy[Y]=screeny+screenh-config.servw_xy[H];
  if(config.servw_xy[Y]<screeny)
    config.servw_xy[Y]=screeny,tempvar.conf_change=TRUE;
  if(config.servw_xy[Y]+config.servw_xy[H]>screenh+screeny)
    config.servw_xy[H]=screeny+screenh-config.servw_xy[Y],tempvar.conf_change=TRUE;

  tempvar.registered=check_key(TRUE);

  memcpy(tempconf.readw_xy,config.readw_xy,sizeof(config.readw_xy));
  memcpy(tempconf.msglw_xy,config.msglw_xy,sizeof(config.msglw_xy));
  memcpy(tempconf.usubw_xy,config.usubw_xy,sizeof(config.usubw_xy));
  memcpy(tempconf.subsw_xy,config.subsw_xy,sizeof(config.subsw_xy));
  memcpy(tempconf.servw_xy,config.servw_xy,sizeof(config.servw_xy));

  tempconf.msglfontsize=config.msglfontsize;
  tempconf.readfontsize=config.readfontsize;
  tempconf.subfontsize=config.subfontsize;
  tempconf.unsubfontsize=config.unsubfontsize;
  tempconf.servfontsize=config.servfontsize;
  if(file)
    fclose(file);
  else
    save_config();
  Return TRUE;
}
/********************************************************************/
/********************************************************************/
int save_config()
{
  char     temp[MAXSTRING+1];
  FILE     *file;
  short    data[8];
  
  if(msglist_win.status!=WINDOW_CLOSED)
    wind_get(msglist_win.ident,WF_CURRXYWH,&tempconf.msglw_xy[X],&tempconf.msglw_xy[Y],&tempconf.msglw_xy[W],&tempconf.msglw_xy[H]);
  if(read_win.status!=WINDOW_CLOSED)
    wind_get(read_win.ident,WF_CURRXYWH,&tempconf.readw_xy[X],&tempconf.readw_xy[Y],&tempconf.readw_xy[W],&tempconf.readw_xy[H]);
  if(sublist_win.status!=WINDOW_CLOSED)
    wind_get(sublist_win.ident,WF_CURRXYWH,&tempconf.subsw_xy[X],&tempconf.subsw_xy[Y],&tempconf.subsw_xy[W],&tempconf.subsw_xy[H]);
  if(unsublist_win.status!=WINDOW_CLOSED)
    wind_get(unsublist_win.ident,WF_CURRXYWH,&tempconf.usubw_xy[X],&tempconf.usubw_xy[Y],&tempconf.usubw_xy[W],&tempconf.usubw_xy[H]);
  if(config.save_window)
  {
    memcpy(config.readw_xy,tempconf.readw_xy,sizeof(config.readw_xy));
    memcpy(config.msglw_xy,tempconf.msglw_xy,sizeof(config.msglw_xy));
    memcpy(config.usubw_xy,tempconf.usubw_xy,sizeof(config.usubw_xy));
    memcpy(config.subsw_xy,tempconf.subsw_xy,sizeof(config.subsw_xy));
    memcpy(config.servw_xy,tempconf.servw_xy,sizeof(config.servw_xy));
  }
  sprintf(temp,"%s%s",system_dir,CONFIGFILE);
  file=fopen(temp,"w");
  if(file)
  {
    fprintf(file,CONFIG_NAME,config.name);
    fprintf(file,CONFIG_ADRESS1,config.adr1);
    fprintf(file,CONFIG_ADRESS2,config.adr2);
    fprintf(file,CONFIG_ADRESS3,config.adr3);
    fprintf(file,CONFIG_KEY,config.key);
    fprintf(file,CONFIG_EDITOR,config.editor);
    fprintf(file,CONFIG_NNTPD,config.nntpd);
    fprintf(file,CONFIG_SIG,config.signature);

    if(config.mailtype==MAILTYPE_ANTMAIL)
      fprintf(file,CONFIG_MAILTYPE,MAILTYPE_T_ANTMAIL);
    else if(config.mailtype==MAILTYPE_NEWSIE)
      fprintf(file,CONFIG_MAILTYPE,MAILTYPE_T_NEWSIE);
    else if(config.mailtype==MAILTYPE_INFITRA)
      fprintf(file,CONFIG_MAILTYPE,MAILTYPE_T_INFITRA);
    else if(config.mailtype==MAILTYPE_MYMAIL)
      fprintf(file,CONFIG_MAILTYPE,MAILTYPE_T_MYMAIL);

    fprintf(file,CONFIG_MAILFILE,config.maildata);
    fprintf(file,CONFIG_STRINGSRV,config.stringserver);
    fprintf(file,CONFIG_REPLYSTR1,config.replystring1);
    fprintf(file,CONFIG_REPLYSTR2,config.replystring2);
    fprintf(file,CONFIG_NEWS,config.newsdir);
    fprintf(file,CONFIG_EMAIL,config.email);
    fprintf(file,CONFIG_REPLY,config.replyto);
    fprintf(file,CONFIG_REALNAME,config.real_name);
    fprintf(file,CONFIG_ORG,config.organization);
    fprintf(file,CONFIG_HOMEPAGE,config.homepage);
    fprintf(file,CONFIG_USUBFONT,config.unsubfontsize,config.unsubfontname);
    fprintf(file,CONFIG_SUBFONT,config.subfontsize,config.subfontname);
    fprintf(file,CONFIG_MSGLFONT,config.msglfontsize,config.msglfontname);
    fprintf(file,CONFIG_READFONT,config.readfontsize,config.readfontname);
    fprintf(file,CONFIG_SERVFONT,config.servfontsize,config.servfontname);
    fprintf(file,CONFIG_USUBWIND,config.usubw_xy[X],config.usubw_xy[Y],config.usubw_xy[W],config.usubw_xy[H]);
    fprintf(file,CONFIG_SUBWIND,config.subsw_xy[X],config.subsw_xy[Y],config.subsw_xy[W],config.subsw_xy[H]);
    fprintf(file,CONFIG_MSGLWIND,config.msglw_xy[X],config.msglw_xy[Y],config.msglw_xy[W],config.msglw_xy[H]);
    fprintf(file,CONFIG_READWIND,config.readw_xy[X],config.readw_xy[Y],config.readw_xy[W],config.readw_xy[H]);
    fprintf(file,CONFIG_SERVWIND,config.servw_xy[X],config.servw_xy[Y],config.servw_xy[W],config.servw_xy[H]);
    fprintf(file,CONFIG_SAVEXIT,config.save_exit);
    fprintf(file,CONFIG_SAVEWIND,config.save_window);
    fprintf(file,CONFIG_USECOMM,config.use_comment);
    fprintf(file,CONFIG_SHOWCOMM,config.show_comment);
    fprintf(file,CONFIG_RESCAN,config.rescan_sub);
    fprintf(file,CONFIG_HIDEUUE,config.hide_uue);
    fprintf(file,CONFIG_HIDEUEND,config.hide_uuend);
    fprintf(file,CONFIG_HIDEHEAD,config.hide_header);
    fprintf(file,CONFIG_QUOTEHEAD,config.quote_header);
    fprintf(file,CONFIG_OPENGROUP,config.open_group);
    fprintf(file,CONFIG_OPENMSG,config.open_msg);
    fprintf(file,CONFIG_FKEYVA,config.fkey_va);
    fprintf(file,CONFIG_UNKNOWN,config.unknown_aes);
    tempvar.conf_change=FALSE;

    ext_id = appl_find( avserver );
    if( ext_id > FAIL)
    {
      strcpy(message,system_dir);
      data[0]=(short)AV_PATH_UPDATE;
      data[1]=(short)ap_id;
      data[2]=(short)0;
      data[3]=(short)message >> 16;
      data[4]=(short)message & 0xffff;
      data[5]=(short)0;
      data[6]=(short)0;
      data[7]=(short)0;
      appl_write(ext_id,16,data);
    }
    Return TRUE;
  }
  else
    Return FALSE;
}

/********************************************************************/
/********************************************************************/
void create_commentlist()
{
  long msg_num=0;
  NewsHeader *nh;
  free_list(&active.clist);
  while(msg_num<active.num_of_messages)
  {
    nh=get_entity(active.mlist,msg_num);
    if(!nh->flags.prog_spec_0)
      create_comment_next(nh,0,msg_num);
    msg_num++;
  }
}

/********************************************************************/
/********************************************************************/
void create_comment_next(NewsHeader *nh,int depth,int msg_num)
{
  CommentList *cl;
  if(nh)
  {
    nh->flags.prog_spec_0=TRUE;
    cl=new_entity(&active.clist,sizeof(CommentList),active.num_of_messages);
    if(cl)
    {
      cl->msg_num=msg_num;
      cl->depth=depth;
      if(nh->i.child!=FAIL)
        create_comment_next(get_entity(active.mlist,nh->i.child),depth+1,nh->i.child);
      if(nh->i.next!=FAIL)
        create_comment_next(get_entity(active.mlist,nh->i.next),depth,nh->i.next);
    }
  }
}