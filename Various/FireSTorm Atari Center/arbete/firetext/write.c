#include "firetext.h"
#include <time.h>
/********************************************************************/
/* Startar skrivningen av en text i brev-basen                      */
/********************************************************************/
int write_text(char *filename)
{
  char  buffer[MAXSTRING];
  int   exit=FALSE,areanumber,counter;
  textfile=hdrfile=msgfile=NULL;
  
  textfile=fopen(filename,"r");
  if(textfile==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],filename,"write_text()");
    log(NULL);
    return(FAIL); 
  }
  areanumber=FAIL;
  if(t_textconf.override_area)
  {
    for(counter=NOLL;counter<tempvar.num_areas;counter++)
      if(!strcmp(areasbbs[counter].area,t_textconf.area))
        areanumber=counter;
    if(areanumber!=FAIL);
      if(!open_area(areanumber))
        return(FAIL);
  }
  if(fgets(buffer,MAXSTRING,textfile)==NULL)
  {
    fclose(hdrfile);
    fclose(msgfile);
    fclose(textfile);
    sprintf(fel.text,alerts[E_READ_FILE],filename,"write_text()");
    log(NULL);
    return(FAIL);
  }
  exit=NEXTMSG;
  open_dialog(&convert_win);
  while(exit!=ENDMSG)
  {
    if((exit=write_message(buffer,TRUE))==CONTMSG)
      while((exit=write_message(buffer,FALSE))==CONTMSG);
  }  
  
  if(textfile!=NULL)
    fclose(textfile);  
  if(hdrfile!=NULL)
    fclose(hdrfile);
  if(msgfile!=NULL)
    fclose(msgfile);

  if(exit==ENDMSG)
    change_lednew();
  close_dialog(&convert_win);
  return(TRUE);
}

/********************************************************************/
/* skriver en text i brev-basen                                     */
/********************************************************************/
int write_message(char *buffer, int newmsg)
{
  char      *dummy=buffer,temp[MAXSTRING];
  int       contmsg=ENDMSG,msgsize=NOLL,exit=FALSE,counter,itemp;
  long int  textsize=strlen(buffer);
  time_t    timedata;
  
  strcpy(msgbuffer,"");
  if(newmsg)
  {
    timedata=time(NULL);
    strcpy(tempvar.kludge,"");
    if(t_textconf.override_from)
    {
      strncpy(header.from,t_textconf.from,(int)sizeof(header.from));
      strncpy(convert_win.dialog[CONVERT_FROM].ob_spec,t_textconf.from,(int)sizeof(header.from));
      
    }
    else
    {
      strcpy(header.from,"");
      header.fromzone=2;
      header.fromnet=203;
      header.fromnode=611;
      header.frompoint=5;
    }

    if(t_textconf.override_to)
    {
      strncpy(header.to,t_textconf.to,(int)sizeof(header.to));
      strncpy(convert_win.dialog[CONVERT_TO].ob_spec,t_textconf.from,(int)sizeof(header.from));
    }
    else
    {
      strcpy(header.to,"");
      header.tozone=2;
      header.tonet=203;
      header.tonode=611;
      header.topoint=0;
    }
    if(t_textconf.override_subj)
    {
      strncpy(header.subj,t_textconf.subj,(int)sizeof(header.subj));
      strncpy(convert_win.dialog[CONVERT_SUBJECT].ob_spec,t_textconf.from,(int)sizeof(header.from));
    }
    else 
      strcpy(header.subj,"");

    strftime(temp,F_SIZE_TIME,"%d %b %y  %X",localtime(&timedata));
    strcpy(header.time,temp);
    header.stamp=timedata;
    header.flags=F_LOCAL;
    header.xflags=NOLL;
    header.mausflags=NOLL;
    header.temp_proc=NOLL;
    header.processed=NOLL;
    counter=NOLL;
    sprintf(temp,"%s%d:%d/%d.%d %8x\n%s%s\n",K_MSGID,header.fromzone,header.fromnet,header.fromnode,header.frompoint,timedata,K_PID,alerts[T_VERSION]);
    strcpy(tempvar.kludge,temp);
    strcpy(msgbuffer,tempvar.kludge);
    msgsize=strlen(msgbuffer);
    tempvar.msg_com_end=FALSE;
  }
  else
  {
    strcat(msgbuffer,tempvar.kludge);
    strcat(msgbuffer,buffer);
    msgsize+=strlen(buffer)+strlen(tempvar.kludge);
    tempvar.msg_com_end=TRUE;
  }
  while(!exit)
  {
    if(dummy==NULL)
    {
      exit=TRUE,contmsg=ENDMSG;
    }
    else if(msgsize+textsize>MAXMSGSIZE)
    {
      exit=TRUE,contmsg=CONTMSG;
    }
    else if(!tempvar.msg_com_end)
    {
      counter=textsize;
      while(buffer[counter]<' ')
        buffer[counter]=NOLL,textsize--,counter--;
      if(!strncmp(buffer,COM_FROM,strlen(COM_FROM)))
      {
        if(!t_textconf.override_from)
        {
          strcpy(t_textconf.from,buffer+strlen(COM_FROM));
          strncpy(header.from,t_textconf.from,(int)sizeof(header.from));
          strncpy(convert_win.dialog[CONVERT_FROM].ob_spec,t_textconf.from,(int)sizeof(header.from));
          button(&convert_win,CONVERT_FROM,CLEAR_FLAGS,HIDETREE);
        }
      }
      else if(!strncmp(buffer,COM_TO,strlen(COM_TO)))
      {
        if(!t_textconf.override_to)
        {
          strcpy(t_textconf.to,buffer+strlen(COM_TO));
          strncpy(header.to,t_textconf.to,(int)sizeof(header.to));
          strncpy(convert_win.dialog[CONVERT_TO].ob_spec,t_textconf.from,(int)sizeof(header.from));
          button(&convert_win,CONVERT_TO,CLEAR_FLAGS,HIDETREE);
        }
      }
      else if(!strncmp(buffer,COM_SUBJ,strlen(COM_SUBJ)))
      {
        if(!t_textconf.override_subj)
        {
          strcpy(t_textconf.subj,buffer+strlen(COM_SUBJ));
          strncpy(header.subj,t_textconf.subj,(int)sizeof(header.subj));
          strncpy(convert_win.dialog[CONVERT_SUBJECT].ob_spec,t_textconf.from,(int)sizeof(header.from));
          button(&convert_win,CONVERT_SUBJECT,CLEAR_FLAGS,HIDETREE);
        }
      }
      else if(!strncmp(buffer,COM_AREA,strlen(COM_AREA)))
      {
        if(!t_textconf.override_area)
        {
          sscanf(buffer,"%s %s",temp,temp);
          itemp=FAIL;
          for(counter=NOLL;counter<tempvar.num_areas;counter++)
            if(!strcmp(areasbbs[counter].area,temp))
              itemp=counter;
          if(itemp!=FAIL)
            open_area(itemp);
          strncpy(convert_win.dialog[CONVERT_AREA].ob_spec,areasbbs[counter].area,SIZE_MAIL);
          button(&convert_win,CONVERT_AREA,CLEAR_FLAGS,HIDETREE);
        }
      }
      else
      {
        tempvar.msg_com_end=TRUE;
        strcat(msgbuffer,buffer);
        strcat(msgbuffer,"\n");
        msgsize+=textsize+1;
      }
    }
    else
    {
      strcat(msgbuffer,buffer);
      msgsize+=textsize;
    }

    dummy=fgets(buffer,MAXSTRING,textfile);
    textsize=strlen(buffer);
  }
  fseek(msgfile,NOLL,SEEK_END);
  fseek(hdrfile,NOLL,SEEK_END);
  header.offset=ftell(msgfile);
  counter=strlen(msgbuffer);
  fwrite(msgbuffer,counter+1,1,msgfile);
  header.msgsize=counter; 
  fwrite(&header,sizeof(HDRINFO),1,hdrfile);

  return(contmsg);
}
