#include "firemail.h"
/********************************************************************/
/* Startar importering av e-mail till fidonet                       */
/********************************************************************/
int import(void)
{
  char buffer[MAXSTRING];
  int exit=FALSE,svar;
  
  tempvar.active_area=tempvar.old_area=FAIL;
  tempvar.e_space=FALSE;
  internetfile=fopen(config.i_source,"r");
  if(internetfile==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],config.i_source,"internet_to_fido()");
    log(NULL);
    return(FAIL);
  }
  rewind(internetfile);
  if(fgets(buffer,MAXSTRING,internetfile)==NULL)
    exit=FALSE;
  if(exit)
  {
    fclose(internetfile);
    sprintf(fel.text,alerts[E_READ_FILE],config.i_source,"internet_to_fido()");
    log(NULL);
    return(FAIL);
  }    
  for(exit=NOLL;exit<tempvar.num_areas;exit++)
    areasbbs[exit].type=NOLL;
  exit=FALSE;
  open_dialog(&mailconv_win);
  set_timer(NOLL);
  while(!exit)
  {
    if(!strncmp(buffer,M_FROM,strlen(M_FROM)))
    {
      if((svar=import_message(buffer,TRUE))==CONTMSG)
        while((svar=import_message(buffer,FALSE))==CONTMSG);
    }
    if(svar<=ENDMSGS)
      exit=TRUE;
  }
  set_timer(FAIL);

  if(internetfile!=NULL)
    fclose(internetfile);
  if(msgfile!=NOLL)
    fclose(msgfile);
  if(hdrfile!=NOLL)
    fclose(hdrfile);
  
  change_lednew();
  rename_import();
  close_dialog(&mailconv_win);
  return(TRUE);  
}

/********************************************************************/
/* Importerar ett meddelande                                        */
/********************************************************************/
int import_message(char *buffer,int newmsg)
{
  char     *dummy1,*dummy2,temp[MAXSTRING];
  int      contmsg=NEXTMSG,msgsize=0,exit=FALSE,counter;
  long int textsize=strlen(buffer)-1;
  
  check();
  tempvar.msg_com_end=FALSE;
  if(newmsg)
  {
    tempvar.mime=FALSE;
    strcpy(tempvar.kludge,"");
    strcat(tempvar.kludge,K_PID);
    strcat(tempvar.kludge,alerts[VERSION]);
    sprintf(temp,"\n%s%d:%d\%d.%d %s\n",K_REPLYTO,config.zone,config.net,config.node,config.point,MAILTO);
    strcat(tempvar.kludge,temp);
    strcpy(msgbuffer,tempvar.kludge);
    msgsize=strlen(msgbuffer);
    memset(header.from,NOLL,sizeof(header.from));
    memset(header.to,NOLL,sizeof(header.to));
    memset(header.subj,NOLL,sizeof(header.subj));
    memset(header.time,NOLL,sizeof(header.time));
    header.flags=F_LOCAL|F_RECEIVED;
    header.xflags=XF_GATED;
    header.mausflags=NOLL;
    header.temp_proc=NOLL;
    header.processed=PROC_FIREMAIL;
    header.fromzone=config.zone;
    header.fromnet=config.net;
    header.fromnode=config.node;
    header.frompoint=config.point;
    header.tozone=2;
    header.tonet=203;
    header.tonode=611;
    header.topoint=0;
    tempvar.route_found=FALSE;
    counter=NOLL;
    if((routedata1!=NULL)&&(tempvar.num_area1>0))
    {
      do
      {
        if(routedata1[counter].type==TYPEM_MFROM)
        {
          sscanf(buffer,"From %s ",temp);
          if(!strcmp(routedata1[counter].text,temp))
          {
            exit=NOLL;
            do
            {
              if(!strcmp(areasbbs[exit].area,routedata1[counter].area))
              {
                tempvar.active_area=exit;
                tempvar.route_found=TRUE;
              }
              else
                exit++;
            }while((exit<tempvar.num_areas)&&(!tempvar.route_found));
            exit=FALSE;
          }
        }
        counter++;
      }while((counter<tempvar.num_area1)&&(!tempvar.route_found));
    }
    counter=NOLL;
    if((!tempvar.route_found)&&(routedata2!=NULL)&&(tempvar.num_area2>0))
    {
      do
      {
        if(routedata2[counter].type==TYPEM_MFROM)
        {
          sscanf(buffer,"From %s ",temp);
          if(!strcmp(routedata2[counter].text,temp))
          {
            exit=NOLL;
            
            do
            {
              if(!strcmp(areasbbs[exit].area,routedata2[counter].area))
              {
                tempvar.active_area=exit;
                tempvar.route_found=TRUE;
              }
              else
                exit++;
            }while((exit<tempvar.num_areas)&&(!tempvar.route_found));
            exit=FALSE;
          }
        }
        counter++;
      }while((counter<tempvar.num_area2)&&(!tempvar.route_found));
    }
    if(!tempvar.route_found)
    {
      tempvar.active_area=NOLL;
      header.tozone=config.zone;
      header.tonet=config.net;
      header.tonode=config.node;
      header.topoint=config.point;
    }
    if(tempvar.active_area!=tempvar.old_area)
    {
      
      if(tempvar.old_area!=FAIL)
      {
        fclose(msgfile),fclose(hdrfile);
      }
      strcpy(temp,areasbbs[tempvar.active_area].text);
      strcat(temp,HEADEREXT);
      hdrfile=fopen(temp,"ab");
      if(hdrfile==NULL)
      {
        sprintf(fel.text,alerts[E_OPEN_FILE],temp,"new_message()");
        log(NULL);
        return(FAIL);
      }
      rewind(hdrfile);
      fseek(hdrfile,0,SEEK_END);
      
      strcpy(temp,areasbbs[tempvar.active_area].text);
      strcat(temp,MESSAGEEXT);
      msgfile=fopen(temp,"ab");
      if(msgfile==NULL)
      {
        fclose(hdrfile);
        sprintf(fel.text,alerts[E_OPEN_FILE],temp,"new_message()");
        log(NULL);
        return(FAIL);
      }
      rewind(msgfile);
      fseek(msgfile,0,SEEK_END);
    }
    tempvar.old_area=tempvar.active_area;
  }
  else
  {
    strcpy(msgbuffer,tempvar.kludge);
    strcat(msgbuffer,buffer);
    msgsize+=strlen(msgbuffer);
    tempvar.msg_com_end=TRUE;
  }
  check();
  while(!exit)
  {
    dummy1=fgets(buffer,MAXSTRING,internetfile);
    textsize=strlen(buffer)-1;
    
    if(dummy1==NULL)
      exit=TRUE,contmsg=ENDMSGS;
    else if(msgsize+textsize+1>MAXMSGSIZE)
      exit=TRUE,contmsg=CONTMSG;
    else if(!strncmp(buffer,M_FROM,strlen(M_FROM)))
      exit=TRUE,contmsg=NEXTMSG;
    else if(!tempvar.msg_com_end)
    {
      if(!strncmp(buffer,M_MIME,strlen(M_MIME)))
        tempvar.e_space=FALSE;
      else if(!strncmp(buffer,M_MCONT,strlen(M_MCONT)))
        tempvar.e_space=FALSE;
      else if(!strncmp(buffer,M_MTRAN,strlen(M_MTRAN)))
        tempvar.e_space=FALSE;
      else if(!strncmp(buffer,M_FROM2,strlen(M_FROM2)))
      {
        tempvar.e_space=FALSE;
        dummy1=buffer+textsize;
        while(isspace(*dummy1)) dummy1--;
        *(++dummy1);
        dummy1=dummy2=buffer+strlen(M_FROM2);
        while(*dummy2!=NOLL)
        {
          if(*dummy2=='(')
            dummy1=++dummy2;
          else if(*dummy2==')')
            *dummy2=NOLL;
          else if(*dummy2=='<')
            *dummy2=NOLL;
          else
            dummy2++;
        }
        strncpy(header.from,dummy1,sizeof header.from);
      }
      else if(!strncmp(buffer,M_SUBJECT,strlen(M_SUBJECT)))
      {
        tempvar.e_space=FALSE;
        dummy1=buffer+strlen(M_SUBJECT);
        dummy2=buffer+textsize;
        while(isspace(*dummy2)) dummy2--;
        *(++dummy2)=NOLL;
        strncpy(header.subj,dummy1,sizeof header.subj);
      }
      else if(!strncmp(buffer,M_MAILER,strlen(M_MAILER)))
      {
        tempvar.e_space=FALSE;
        strcat(msgbuffer,K_EID),strcat(tempvar.kludge,K_EID);
        dummy1=buffer+strlen(M_REPLY);
        while(isspace(*dummy1)) dummy1++;
        dummy2=buffer+textsize;
        while(isspace(*dummy2)) dummy2--;
        *(++dummy2)=NOLL;
        strcat(msgbuffer,dummy1),strcat(tempvar.kludge,dummy1);
        strcat(msgbuffer,"\n"),strcat(tempvar.kludge,"\n");;
        msgsize+=strlen(K_EID)+strlen(dummy1);
       }
      else if(!strncmp(buffer,M_REPLY,strlen(M_REPLY)))
      {
        tempvar.e_space=FALSE;
        strcat(msgbuffer,K_REPLYADDR),strcat(tempvar.kludge,K_REPLYADDR);
        sscanf(buffer,"%s %s",temp,temp+strlen(M_REPLY)+2);
        strcat(msgbuffer,temp+strlen(M_REPLY)+2),strcat(tempvar.kludge,temp+strlen(M_REPLY)+2);
        strcat(msgbuffer,"\n"),strcat(tempvar.kludge,"\n");
        msgsize+=strlen(K_REPLYADDR)+strlen(dummy1)+1;
      }
      else if(!strncmp(buffer,M_TO,strlen(M_TO)))
      {
        tempvar.e_space=TRUE;
        dummy1=buffer+strlen(M_TO);
        dummy2=buffer+textsize;
        while(isspace(*dummy2)) dummy2--;
        *(++dummy2)=NOLL;
        while(isspace(*dummy1)) dummy1++;
        strncpy(header.to,dummy1,sizeof header.to);
      }
      else if(!strncmp(buffer,M_DATE,strlen(M_DATE)))
      {
        tempvar.e_space=FALSE;
        sscanf(buffer,"%s %s %s %s %s %s",temp,temp+10,temp+20,temp+30,temp+40,temp+50);
        sprintf(header.time,"%s %s %s  %s",temp+20,temp+30,temp+42,temp+50);
      }
      else if(!strncmp(buffer,M_MSGID,strlen(M_MSGID)))
      {
      }
      else if(!strncmp(buffer,M_RECEIVED,strlen(M_RECEIVED)))
        tempvar.e_space=TRUE;
      else if(!strncmp(buffer,M_STATUS,strlen(M_STATUS)))
      {
        tempvar.e_space=FALSE;
        strncpy(mailconv_win.dialog[MAIL_FROM].ob_spec,header.from,SIZE_MAIL);
        strncpy(mailconv_win.dialog[MAIL_TO].ob_spec,header.to,SIZE_MAIL);
        strncpy(mailconv_win.dialog[MAIL_SUBJECT].ob_spec,header.subj,SIZE_MAIL);
        strncpy(mailconv_win.dialog[MAIL_AREA].ob_spec,areasbbs[tempvar.active_area].area,SIZE_MAIL);
        wind_get(mailconv_win.ident,WF_WORKXYWH,xy,xy+1,xy+2,xy+3);
        update(&mailconv_win,xy);  
        tempvar.msg_com_end=TRUE;
      }
      else if(isspace(buffer[NOLL])&&tempvar.e_space);
      else if((buffer[NOLL]=='\n')||( buffer[NOLL]=='\r'))
      {
        tempvar.e_space=FALSE;
        strncpy(mailconv_win.dialog[MAIL_FROM].ob_spec,header.from,SIZE_MAIL);
        strncpy(mailconv_win.dialog[MAIL_TO].ob_spec,header.to,SIZE_MAIL);
        strncpy(mailconv_win.dialog[MAIL_SUBJECT].ob_spec,header.subj,SIZE_MAIL);
        strncpy(mailconv_win.dialog[MAIL_AREA].ob_spec,areasbbs[tempvar.active_area].area,SIZE_MAIL);
        wind_get(mailconv_win.ident,WF_WORKXYWH,xy,xy+1,xy+2,xy+3);
        update(&mailconv_win,xy);  
        tempvar.msg_com_end=TRUE;
        if(mime.on)
          c_mime_2_pc8(&mime,buffer);
        strcat(msgbuffer,buffer);
        msgsize+=strlen(buffer);
        
      }
    }
    else
    {
      if(mime.on)
        c_mime_2_pc8(&mime,buffer);
      strcat(msgbuffer,buffer);
      msgsize+=strlen(buffer);
    }
  }
  check();

  fseek(msgfile,NOLL,SEEK_END);
  fseek(hdrfile,NOLL,SEEK_END);
  header.offset=ftell(msgfile);
  fwrite(msgbuffer,strlen(msgbuffer)+1,1,msgfile);
  header.msgsize=ftell(msgfile)-header.offset; 
  fwrite(&header,sizeof(HDRINFO),1,hdrfile);
  areasbbs[tempvar.active_area].type|=LF_NEW|LF_UNREAD;
  return(contmsg);
}
