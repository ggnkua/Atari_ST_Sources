#include "firenews.h"
void fix_comment(int parent, int child);
/********************************************************************/
/* Routines for writing messages                                    */
/********************************************************************/
int create_new_message(char *subject)
{
  FILE  *tempfile,*sigfile=NULL;
  long  file=FAIL,oldtime=NOLL,newtime=NOLL;

  tempfile=fopen(TEMP_MESSAGE,"w");
  if(tempfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"Create_new_message: Could not open temporary message file.\n");
#endif
    Return FALSE;
  }

  active.tempgroup=get_entity(active.glist,active.group_num);
  fprintf(tempfile,MSG_HEAD_FROM,config.real_name,config.email);
  fprintf(tempfile,MSG_HEAD_DATE,timestamp((char *)tempvar.tempstring));
  fprintf(tempfile,MSG_HEAD_GROUP,active.tempgroup->groupname);
  fprintf(tempfile,MSG_HEAD_SUBJ,subject);
  fprintf(tempfile,MSG_HEAD_MSGID,msgid((char *)tempvar.tempstring));
  if(config.replyto[0])
    fprintf(tempfile,MSG_HEAD_REPLY,config.real_name,config.replyto);

  if((config.homepage[0])&&(tempvar.registered))
    fprintf(tempfile,MSG_HEAD_XURL,config.homepage);
  if(tempvar.registered)
    fprintf(tempfile,MSG_HEAD_READ,VERSION,"");
  else
  {
    fprintf(tempfile,MSG_HEAD_XURL,HOMEPAGE);
    fprintf(tempfile,MSG_HEAD_READ,VERSION,"(Unregistered)");
  }
  fprintf(tempfile,MSG_HEAD_ORG,config.organization);

  fprintf(tempfile,"\n\n\n");

  if(config.signature[NOLL]!=NOLL)
  {
    sigfile=fopen(config.signature,"r");
    if(sigfile!=NULL)
    {
      fprintf(tempfile,"--\n");
      while(fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)!=NOLL)
        fputs(tempvar.tempstring,tempfile);
    }
#ifdef LOGGING
    else
      Log(LOG_ERROR,"create_new_message: Could not open Signature file.\n");
#endif
  }    
  
  fclose(tempfile);
  if(sigfile!=NULL)
    fclose(sigfile);

  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short *)&oldtime,file,NOLL);
    Fclose(file);
  }
  execute(config.editor,TEMP_MESSAGE,FALSE);
  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short *)&newtime,file,NOLL);
    Fclose(file);
  }

  if((oldtime!=newtime) /*&&(oldtime!=NOLL)&&(newtime!=NOLL)*/)
  {
    if(alertbox(1,alerts[Q_QUEUE_GROUP])==1)
      tmp2msgbase(FAIL);
    if(Fdelete(TEMP_MESSAGE)!=0)
    {
#ifdef LOGGING
      Log(LOG_ERROR,"Create_new_message: Could not delete temporary message file.\n");
#endif
    }
  }
  
  Return TRUE;
}

/********************************************************************/
/********************************************************************/
int create_reply_group(int msg_num)
{
  FILE  *tempfile,*sigfile;
  char  subject[ROWSIZE+1]="",references[MAXSTRING+1]="";
  char  email[ROWSIZE+1]="",oldmsgid[ROWSIZE+1]="",name[ROWSIZE+1]="",date[ROWSIZE+1]="";
  long  file=FAIL,oldtime=NOLL,newtime=NOLL;
  int   exit;

  active.tempmessage=get_entity(active.mlist,msg_num);

  tempfile=fopen(TEMP_MESSAGE,"w");
  if(tempfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"Create_reply_message:Could not open temporary message file.\n");
#endif
    Return FALSE;
  }
  active.tempgroup=get_entity(active.glist,active.group_num);

  strcpy(tempvar.tempstring,config.newsdir);
  strcat(tempvar.tempstring,active.tempgroup->filename);
  strcat(tempvar.tempstring,MESSAGEEXT);
  sigfile=fopen(tempvar.tempstring,"rb");
  if(sigfile==NOLL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"Create_reply_message: Could not open message-base file.\n");
#endif
    fclose(tempfile);
    Return FALSE;
  }

  fseek(sigfile,active.tempmessage->offset,SEEK_SET);
  fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile);
  tempvar.tempstring[strcspn(tempvar.tempstring,"\n\r")]=NOLL;
  while(tempvar.tempstring[NOLL]!=NOLL)
  {
    if(!strncmp(tempvar.tempstring,MSG_HEAD_DATE,strcspn(MSG_HEAD_DATE," \n\r")))
    {
    
    }
    if(!strncmp(tempvar.tempstring,MSG_HEAD_SUBJ,strcspn(MSG_HEAD_SUBJ," \n\r")))
    {
      tempvar.temp1=strcspn(MSG_HEAD_SUBJ," \n\r");
      tempvar.temp2=strcspn(tempvar.tempstring,"\n\r");
      tempvar.tempstring[tempvar.temp2]=NOLL;
      strcpy(subject,tempvar.tempstring+tempvar.temp1+1);
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_REF,strcspn(MSG_HEAD_REF," \n\r")))
    {
      tempvar.temp1=strcspn(MSG_HEAD_REF," \n\r");
      tempvar.temp2=strlen(tempvar.tempstring);
      tempvar.tempstring[tempvar.temp2]=NOLL;
      strncpy(references,tempvar.tempstring+tempvar.temp1+1,MAXSTRING);
     }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_MSGID,strcspn(MSG_HEAD_MSGID," \n\r")))
    {
      tempvar.temp1=strcspn(tempvar.tempstring," \n\r");
      strncpy(oldmsgid,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
      tempvar.temp2=strcspn(oldmsgid," \n\r");
      oldmsgid[tempvar.temp2]=NOLL;
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_FROM,strcspn(MSG_HEAD_FROM," \n\r")))
    {
      if(strchr(tempvar.tempstring,'('))
      {
        tempvar.temp1=strcspn(tempvar.tempstring,"(");
        strncpy(name,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(name,")");
        name[tempvar.temp2]=NOLL;
      }
      else if(strchr(tempvar.tempstring,'<'))
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(name,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(name,"<");
        name[tempvar.temp2]=NOLL;
      }
      else 
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(name,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(name," ");
        name[tempvar.temp2]=NOLL;
      }
    }
    fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile);
    tempvar.tempstring[strcspn(tempvar.tempstring,"\n\r")]=NOLL;
  }
  fprintf(tempfile,MSG_HEAD_FROM,config.real_name,config.email);
  fprintf(tempfile,MSG_HEAD_DATE,timestamp((char *)tempvar.tempstring));
  fprintf(tempfile,MSG_HEAD_GROUP,active.tempgroup->groupname);
  if(!strncmp(subject,MSG_SUBJECT_RE,strlen(MSG_SUBJECT_RE)))
  {
    fprintf(tempfile,MSG_HEAD_SUBJ,subject);
  }
  else
  {
    strcpy(tempvar.tempstring,MSG_SUBJECT_RE);
    strcat(tempvar.tempstring,subject);
    fprintf(tempfile,MSG_HEAD_SUBJ,tempvar.tempstring);
  }
  fprintf(tempfile,MSG_HEAD_MSGID,msgid((char *)tempvar.tempstring));
  references[MAXSTRING-strlen(tempvar.tempstring)-strlen(MSG_HEAD_REF)-1]=NOLL;
  tempvar.temp2=(int)((long)strrchr(references,'>')-(long)references);
  tempvar.temp1=(int)((long)strrchr(references,'<')-(long)references);
  if((tempvar.temp2<tempvar.temp1)&&(tempvar.temp2>NOLL))
    references[tempvar.temp1]=NOLL;

  if(config.replyto[0])
    fprintf(tempfile,MSG_HEAD_REPLY,config.real_name,config.replyto);
  fprintf(tempfile,MSG_HEAD_REF,references,oldmsgid);
  if((config.homepage[0])&&(tempvar.registered))
    fprintf(tempfile,MSG_HEAD_XURL,config.homepage);
  if(tempvar.registered)
    fprintf(tempfile,MSG_HEAD_READ,VERSION,"");
  else
  {
    fprintf(tempfile,MSG_HEAD_XURL,HOMEPAGE);
    fprintf(tempfile,MSG_HEAD_READ,VERSION,"(Unregistered)");
  }
  if(config.organization[0])
    fprintf(tempfile,MSG_HEAD_ORG,config.organization);
  fprintf(tempfile,"\n");

  oldtime=strlen(config.replystring1);
  newtime=0;
  while( newtime < oldtime )
  {
    if( config.replystring1[ newtime ] == '%' )
    {
      newtime++;
      if( config.replystring1[ newtime ] == 'm' )
        fprintf( tempfile , "%s" , oldmsgid);
      else if( config.replystring1[ newtime ] == 'e' )
        fprintf( tempfile , "%s" , email);
      else if( config.replystring1[ newtime ] == 'n' )
        fprintf( tempfile , "%s" , name );
      else if( config.replystring1[ newtime ] == 's' )
        fprintf( tempfile , "%s" , subject );
      else if( config.replystring1[ newtime ] == 'd' )
        fprintf( tempfile , "%s" , date );
      else if( config.replystring1[ newtime ] == 'r' )
        fputc( '\n' , tempfile );
      else if( config.replystring1[ newtime ] == 'g' )
        fprintf( tempfile , "%s" , active.tempgroup->groupname );
      else if( config.replystring1[ newtime ] == '%' )
        fputc( '%' , tempfile );
    }
    else
      fputc(config.replystring1[newtime],tempfile);
    newtime++;
  }

  fseek(sigfile,active.tempmessage->offset,SEEK_SET);
  exit=FALSE;
  while(exit!=TRUE)
  {
    if(fgets((char*)tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)==NOLL)
      exit=TRUE;
    else if(tempvar.tempstring[NOLL]=='.'&&(tempvar.tempstring[1]=='\n'||tempvar.tempstring[1]=='\r'))
      exit=TRUE;
    if(!exit)
    {
      tempvar.temp1=strcspn(tempvar.tempstring,"\r");
      tempvar.tempstring[tempvar.temp1]='\n';
      tempvar.tempstring[tempvar.temp1+1]=NOLL;
      if(tempvar.tempstring[NOLL]=='>')
        fprintf(tempfile,">");
      else
        fprintf(tempfile,"> ");
      fprintf(tempfile,tempvar.tempstring);
    } 
  }
  fclose(sigfile);sigfile=NULL;
  fprintf(tempfile,"\n");
  if(config.signature[NOLL]!=NOLL)
  {
    sigfile=fopen(config.signature,"r");
    if(sigfile!=NULL)
    {
      fprintf(tempfile,"--\n");
      while(fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)!=NOLL)
        fputs(tempvar.tempstring,tempfile);
    }
#ifdef LOGGING
    else
      Log(LOG_ERROR,"Create_reply_message: Could not open Signature file.\n");
#endif
  }    
  
  fclose(tempfile),tempfile=NULL;
  if(sigfile!=NULL)
    fclose(sigfile),sigfile=NULL;

  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short*)&oldtime,file,NOLL);
    Fclose(file);
  }
  execute(config.editor,TEMP_MESSAGE,FALSE);
  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short *)&newtime,file,NOLL);
    Fclose(file);
  }

  if((oldtime!=newtime)&&(oldtime!=NOLL)&&(newtime!=NOLL))
  if(alertbox(1,alerts[Q_QUEUE_GROUP])==1)
  {
    {
      change_flag(msg_num,MSG_FLAG_REP,TRUE);
      tmp2msgbase(msg_num);
    }
    if(Fdelete(TEMP_MESSAGE)!=0)
    {
#ifdef LOGGING
      Log(LOG_ERROR,"Create_reply_message: Could not Delete temporary message.\n");
#endif
    }
  }

  Return TRUE;
}

/********************************************************************/
/********************************************************************/
int create_forward_message(int msg_num)
{
  FILE  *tempfile,*sigfile;
  char  subject[MAXSTRING]="",references[MAXSTRING]="";
  char  from[ROWSIZE]="",oldmsgid[ROWSIZE];
  long  file=FAIL,oldtime=NOLL,newtime=NOLL;
  int   exit;

  active.tempmessage=get_entity(active.mlist,msg_num);

  tempfile=fopen(TEMP_MESSAGE,"w");
  if(tempfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"Create_forward_message:Could not open temporary message file.\n");
#endif
    Return FALSE;
  }
  active.tempgroup=get_entity(active.glist,active.group_num);

  strcpy(tempvar.tempstring,config.newsdir);
  strcat(tempvar.tempstring,active.tempgroup->filename);
  strcat(tempvar.tempstring,MESSAGEEXT);
  sigfile=fopen(tempvar.tempstring,"rb");
  if(sigfile==NOLL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"Create_forward_message: Could not open message-base file.\n");
#endif
    fclose(tempfile);
    Return FALSE;
  }

  fseek(sigfile,active.tempmessage->offset,SEEK_SET);
  fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile);
  tempvar.tempstring[strcspn(tempvar.tempstring,"\n\r")]=NOLL;
  while(tempvar.tempstring[NOLL]!=NOLL)
  {
    if(!strncmp(tempvar.tempstring,MSG_HEAD_SUBJ,strcspn(MSG_HEAD_SUBJ," \n\r")))
    {
      tempvar.temp1=strcspn(MSG_HEAD_SUBJ," \n\r");
      tempvar.temp2=strcspn(tempvar.tempstring,"\n\r");
      tempvar.tempstring[tempvar.temp2]=NOLL;
      strcpy(subject,tempvar.tempstring+tempvar.temp1+1);
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_REF,strcspn(MSG_HEAD_REF," \n\r")))
    {
      tempvar.temp1=strcspn(MSG_HEAD_REF," \n\r");
      tempvar.temp2=strlen(tempvar.tempstring);
      tempvar.tempstring[tempvar.temp2]=NOLL;
      strncpy(references,tempvar.tempstring+tempvar.temp1+1,MAXSTRING);
     }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_MSGID,strcspn(MSG_HEAD_MSGID," \n\r")))
    {
      tempvar.temp1=strcspn(tempvar.tempstring," \n\r");
      strncpy(oldmsgid,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
      tempvar.temp2=strcspn(oldmsgid," \n\r");
      oldmsgid[tempvar.temp2]=NOLL;
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_FROM,strcspn(MSG_HEAD_FROM," \n\r")))
    {
      if(strchr(tempvar.tempstring,'('))
      {
        tempvar.temp1=strcspn(tempvar.tempstring,"(");
        strncpy(from,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from,")");
        from[tempvar.temp2]=NOLL;
      }
      else if(strchr(tempvar.tempstring,'<'))
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from,"<");
        from[tempvar.temp2]=NOLL;
      }
      else /* if(from[NOLL]=NOLL) */
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from," ");
        from[tempvar.temp2]=NOLL;
      }
    }
    fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile);
    tempvar.tempstring[strcspn(tempvar.tempstring,"\n\r")]=NOLL;
  }
  fprintf(tempfile,MSG_HEAD_FROM,config.real_name,config.email);
  fprintf(tempfile,MSG_HEAD_DATE,timestamp((char *)tempvar.tempstring));
  fprintf(tempfile,MSG_HEAD_GROUP,active.tempgroup->groupname);
  if(!strncmp(subject,MSG_SUBJECT_RE,strlen(MSG_SUBJECT_RE)))
  {
    fprintf(tempfile,MSG_HEAD_SUBJ,subject);
  }
  else
  {
    strcpy(tempvar.tempstring,MSG_SUBJECT_RE);
    strcat(tempvar.tempstring,subject);
    fprintf(tempfile,MSG_HEAD_SUBJ,tempvar.tempstring);
  }
  fprintf(tempfile,MSG_HEAD_MSGID,msgid((char *)tempvar.tempstring));
  references[MAXSTRING-strlen(tempvar.tempstring)-strlen(MSG_HEAD_REF)-1]=NOLL;
  tempvar.temp2=(int)((long)strrchr(references,'>')-(long)references);
  tempvar.temp1=(int)((long)strrchr(references,'<')-(long)references);
  if((tempvar.temp2<tempvar.temp1)&&(tempvar.temp2>NOLL))
    references[tempvar.temp1]=NOLL;

  if(config.replyto[0])
    fprintf(tempfile,MSG_HEAD_REPLY,config.real_name,config.replyto);
  fprintf(tempfile,MSG_HEAD_REF,references,oldmsgid);
  if((config.homepage[0])&&(tempvar.registered))
    fprintf(tempfile,MSG_HEAD_XURL,config.homepage);
  if(tempvar.registered)
    fprintf(tempfile,MSG_HEAD_READ,VERSION,"");
  else
  {
    fprintf(tempfile,MSG_HEAD_XURL,HOMEPAGE);
    fprintf(tempfile,MSG_HEAD_READ,VERSION,"(Unregistered)");
  }
  if(config.organization[0])
    fprintf(tempfile,MSG_HEAD_ORG,config.organization);
  fprintf(tempfile,"\n");

//  fprintf(tempfile,alerts[REPLY_MESSAGE1],oldmsgid,from);
  fseek(sigfile,active.tempmessage->offset,SEEK_SET);
  exit=FALSE;
  while(exit!=TRUE)
  {
    if(fgets((char*)tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)==NOLL)
      exit=TRUE;
    else if(tempvar.tempstring[NOLL]=='.'&&(tempvar.tempstring[1]=='\n'||tempvar.tempstring[1]=='\r'))
      exit=TRUE;
    if(!exit)
    {
      tempvar.temp1=strcspn(tempvar.tempstring,"\r");
      tempvar.tempstring[tempvar.temp1]='\n';
      tempvar.tempstring[tempvar.temp1+1]=NOLL;
      if(tempvar.tempstring[NOLL]=='>')
        fprintf(tempfile,">");
      else
        fprintf(tempfile,"> ");
      fprintf(tempfile,tempvar.tempstring);
    } 
  }
  fclose(sigfile);sigfile=NULL;
  fprintf(tempfile,"\n");
  if(config.signature[NOLL]!=NOLL)
  {
    sigfile=fopen(config.signature,"r");
    if(sigfile!=NULL)
    {
      fprintf(tempfile,"--\n");
      while(fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)!=NOLL)
        fputs(tempvar.tempstring,tempfile);
    }
#ifdef LOGGING
    else
      Log(LOG_ERROR,"Create_reply_message: Could not open Signature file.\n");
#endif
  }    
  
  fclose(tempfile),tempfile=NULL;
  if(sigfile!=NULL)
    fclose(sigfile),sigfile=NULL;

  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short*)&oldtime,file,NOLL);
    Fclose(file);
  }
  execute(config.editor,TEMP_MESSAGE,FALSE);
  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short *)&newtime,file,NOLL);
    Fclose(file);
  }

  if((oldtime!=newtime)&&(oldtime!=NOLL)&&(newtime!=NOLL))
  if(alertbox(1,alerts[Q_QUEUE_GROUP])==1)
  {
    {
      change_flag(msg_num,MSG_FLAG_REP,TRUE);
      tmp2msgbase(msg_num);
    }
    if(Fdelete(TEMP_MESSAGE)!=0)
    {
#ifdef LOGGING
      Log(LOG_ERROR,"Create_reply_message: Could not Delete temporary message.\n");
#endif
    }
  }

  Return TRUE;
}/********************************************************************/
/* puts the temp-message into the message-base, and into the memory */
/********************************************************************/
int tmp2msgbase(int msg_num)
{

  FILE *hdrfile,*msgfile,*tempfile;
  long msgoffset=NOLL,linecount=NOLL;

  active.tempgroup=get_entity(active.glist,active.group_num);
  sprintf(tempvar.tempstring,"%s%s%s",config.newsdir,active.tempgroup->filename,HEADEREXT);
  hdrfile=fopen(tempvar.tempstring,"ab+");
  if(hdrfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"tmp2msgbase: Could not open Header file.\n");
#endif
    Return FALSE;
  }
  rewind(hdrfile);
  fseek(hdrfile,NOLL,SEEK_END);
  if(ftell(hdrfile)==0)
  {
    sprintf(tempvar.tempstring,"%s%s",NEWSID,NEWSVER);
    fwrite(tempvar.tempstring,8,1,hdrfile);
  }

  sprintf(tempvar.tempstring,"%s%s%s",config.newsdir,active.tempgroup->filename,MESSAGEEXT);
  msgfile=fopen(tempvar.tempstring,"ar+");
  if(msgfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"tmp2msgbase: Could not open message-base file.\n");
#endif
    fclose(hdrfile);
    Return FALSE;
  }
  rewind(msgfile);
  fseek(msgfile,NOLL,SEEK_END);
  msgoffset=ftell(msgfile);
 
  tempfile=fopen(TEMP_MESSAGE,"r");
  if(tempfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"tmp2msgbase: Could not open temporary messagefile.\n");
#endif
    fclose(msgfile);
    fclose(hdrfile);
    Return FALSE;
  }

  linecount=FAIL;
  while(fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,tempfile)!=NOLL)
  {
    if(((tempvar.tempstring[NOLL]=='\n')||(tempvar.tempstring[NOLL]=='\r'))&&(linecount==FAIL))
      linecount=FALSE;
    if(linecount!=FAIL)
      linecount++;
  }
  rewind(tempfile);

  fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,tempfile);
  while((tempvar.tempstring[NOLL]!='\n')&&(tempvar.tempstring[NOLL]!='\r'))
  {
    if(!strncmp(tempvar.tempstring,MSG_HEAD_SUBJ,strcspn(MSG_HEAD_SUBJ," \n\r")))
    {
      tempvar.temp1=strcspn(tempvar.tempstring," \n\r");
      strncpy(tempvar.temprow1,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
      tempvar.temp2=strcspn(tempvar.temprow1,"\n\r");
      tempvar.temprow1[tempvar.temp2]=NOLL;
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_FROM,strcspn(MSG_HEAD_FROM," \n\r")))
    {
      if(tempvar.temp1=strchr(tempvar.tempstring,'('))
      {
        strncpy(tempvar.temprow2,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(tempvar.temprow2,")");
        tempvar.temprow2[tempvar.temp2]=NOLL;
      }
      else if(strchr(tempvar.tempstring,'<'))
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(tempvar.temprow2,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(tempvar.temprow2,"<");
        tempvar.temprow2[tempvar.temp2]=NOLL;
      }
    }

    fputs(tempvar.tempstring,msgfile);
    fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,tempfile);
  }

  active.tempmessage=new_entity(&active.mlist,sizeof(NewsHeader),config.message_alloc);
  if(!active.tempmessage)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"tmp2msgbase: Could not create message in memory.\n");
#endif
    fclose(hdrfile);
    fclose(msgfile);
    fclose(tempfile);
    Return FALSE;
  }
  strncpy(active.tempmessage->from,tempvar.temprow2,NEWS_FROMSIZE-1);
  active.tempmessage->from[NEWS_FROMSIZE-1]='\0';
  strncpy(active.tempmessage->subject,tempvar.temprow1,NEWS_SUBJECTSIZE-1);
  active.tempmessage->subject[NEWS_SUBJECTSIZE-1]='\0';
  active.tempmessage->offset=msgoffset;
  active.tempmessage->flags.outgoing=TRUE;
  active.tempmessage->flags.requested=FALSE;
  active.tempmessage->flags.replied=FALSE;
  active.tempmessage->flags.header_only=FALSE;
  active.tempmessage->flags.deleted=FALSE;
  active.tempmessage->flags.keep=FALSE;
  active.tempmessage->flags.new=FALSE;

  active.num_of_messages++;
  if(msglist_win.status!=WINDOW_CLOSED)
    msglist_win.text->num_of_rows++;
  
  fprintf(msgfile,MSG_HEAD_LINES,++linecount);
    
  fputs(tempvar.tempstring,msgfile);
  while(fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,tempfile)!=NOLL)
  {
    if(!strcmp(tempvar.tempstring,".\n"))
      break;
    fputs(tempvar.tempstring,msgfile);
  }
  fputs("\n.\n",msgfile);
  active.tempmessage->length=ftell(msgfile)-active.tempmessage->offset;
  fwrite(active.tempmessage,sizeof(NewsHeader),1,hdrfile);
  
  fclose(tempfile);
  fclose(msgfile);
  fclose(hdrfile);

  if(msg_num!=FAIL)
    fix_comment(msg_num,active.num_of_messages-1);

  if(msg_num!=FAIL)
  {
    top_of_document();
  }
  if(msglist_win.status!=WINDOW_CLOSED)
    redraw_window(&msglist_win);
  Return TRUE;
}
/********************************************************************/
/* returnes the timestamp                                           */
/********************************************************************/
char *timestamp(char *text)
{
  unsigned long tid;

  time(&tid);
  strftime(text,ROWSIZE,"%d %b %Y %X",localtime(&tid));
  Return text;
}

/********************************************************************/
/* returns the message id                                           */
/********************************************************************/
char * msgid(char *idtext)
{
  unsigned long tid;

  time(&tid);
  strncpy(tempvar.temprow1,config.email,strcspn(config.email,"@"));
  tempvar.temprow1[strcspn(config.email,"@")]=NOLL;
  sprintf(idtext,"<FN_%08x_%s@%s>",tid,tempvar.temprow1,active.servers[active.serv_num].name);
  Return idtext;
}

/********************************************************************/
/********************************************************************/
int create_reply_email(int msg_num)
{
  FILE  *tempfile,*sigfile;
  char  subject[MAXSTRING]="",from_email[MAXSTRING]="",from_date[ROWSIZE]="",date[ROWSIZE]="";
  char  from_name[ROWSIZE]="",from_reply[MAXSTRING]="",from_file[MAXSTRING]="",from_msgid[MAXSTRING]="";
  long  file=0,oldtime=NOLL,newtime=NOLL;
  unsigned long tid;
  int   exit;

  active.tempmessage=get_entity(active.mlist,msg_num);

  tempfile=fopen(TEMP_MESSAGE,"w");
  if(tempfile==NULL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"create_reply_email: Could not open temporary message file.\n");
#endif
    Return FALSE;
  }

  active.tempgroup=get_entity(active.glist,active.group_num);
  
  sprintf(tempvar.tempstring,"%s%s%s",config.newsdir,active.tempgroup->filename,MESSAGEEXT);
  sigfile=fopen(tempvar.tempstring,"rb");
  if(sigfile==NOLL)
  {
#ifdef LOGGING
    Log(LOG_ERROR,"create_reply_email: Could not open message-base file.\n");
#endif
    fclose(tempfile);
    Return FALSE;
  }
  fseek(sigfile,active.tempmessage->offset,SEEK_SET);
  fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile);
  while((tempvar.tempstring[NOLL]!='\n')&&(tempvar.tempstring[NOLL]!='\r'))
  {
    if(!strncmp(tempvar.tempstring,MSG_HEAD_SUBJ,strcspn(MSG_HEAD_SUBJ," \n\r")))
    {
      tempvar.temp1=strcspn(MSG_HEAD_SUBJ," \n\r");
      tempvar.temp2=strcspn(tempvar.tempstring,"\n\r");
      tempvar.tempstring[tempvar.temp2--]=NOLL;
      while(isspace(tempvar.tempstring[tempvar.temp2])) tempvar.tempstring[tempvar.temp2--]=0;
      strcpy(subject,tempvar.tempstring+tempvar.temp1+1);
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_FROM,strcspn(MSG_HEAD_FROM," \n\r")))
    {
      if(strchr(tempvar.tempstring,'('))
      {
        tempvar.temp1=strcspn(tempvar.tempstring,"(");
        strncpy(from_name,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_name,")");
        from_name[tempvar.temp2--]=NOLL;
        while(isspace(from_name[tempvar.temp2])) from_name[tempvar.temp2--]=0;
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from_email,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_email,"(");
        from_email[tempvar.temp2--]=NOLL;
        while(isspace(from_email[tempvar.temp2])) from_email[tempvar.temp2--]=0;
        
      }
      else if(strchr(tempvar.tempstring,'<'))
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from_name,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_name,"<");
        from_name[tempvar.temp2--]=NOLL;
        while(isspace(from_name[tempvar.temp2])) from_name[tempvar.temp2--]=0;
        tempvar.temp1=strcspn(tempvar.tempstring,"<");
        strncpy(from_email,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_email,">");
        from_email[tempvar.temp2--]=NOLL;
        while(isspace(from_email[tempvar.temp2])) from_email[tempvar.temp2--]=0;
      }
      else
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from_name,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_name," \n\r");
        from_name[tempvar.temp2--]=NOLL;
        while(isspace(from_name[tempvar.temp2])) from_name[tempvar.temp2--]=0;
        strcpy(from_email,from_name);
      }
    }
    else if(!strncmp(tempvar.tempstring,MSG_HEAD_REPLY,strcspn(MSG_HEAD_REPLY," \n\r")))
    {
      if(strchr(tempvar.tempstring,'('))
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from_reply,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_reply,"(");
        from_reply[tempvar.temp2--]=NOLL;
        while(isspace(from_reply[tempvar.temp2])) from_reply[tempvar.temp2--]=0;
      }
      else if(strchr(tempvar.tempstring,'<'))
      {
        tempvar.temp1=strcspn(tempvar.tempstring,"<");
        strncpy(from_reply,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_reply,">");
        from_reply[tempvar.temp2--]=NOLL;
        while(isspace(from_reply[tempvar.temp2])) from_reply[tempvar.temp2--]=0;
      }
      else
      {
        tempvar.temp1=strcspn(tempvar.tempstring," ");
        strncpy(from_reply,tempvar.tempstring+tempvar.temp1+1,ROWSIZE);
        tempvar.temp2=strcspn(from_reply," \n\r");
        from_reply[tempvar.temp2--]=NOLL;
        while(isspace(from_reply[tempvar.temp2])) from_reply[tempvar.temp2--]=0;
      }
    }
    fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile);
  }
  timestamp((char *)date);
  if(config.mailtype!=MAILTYPE_INFITRA)
  {
    if(config.mailtype!=MAILTYPE_ANTMAIL)
    {
      fprintf(tempfile,MSG_HEAD_FROM,config.real_name,config.email);
    }
    if(from_reply[0])
      fprintf(tempfile,MSG_HEAD_TO,from_reply);
    else
      fprintf(tempfile,MSG_HEAD_TO,from_email);
 
    if(config.mailtype!=MAILTYPE_ANTMAIL)
    {
      fprintf(tempfile,MSG_HEAD_DATE,date);
    }
    if(!strncmp(subject,MSG_SUBJECT_RE,strlen(MSG_SUBJECT_RE)))
    {
      fprintf(tempfile,MSG_HEAD_SUBJ,subject);
    }
    else
    {
      strcpy(tempvar.tempstring,MSG_SUBJECT_RE);
      strcat(tempvar.tempstring,subject);
      fprintf(tempfile,MSG_HEAD_SUBJ,tempvar.tempstring);
    }
    if(config.mailtype!=MAILTYPE_ANTMAIL)
    {
      fprintf(tempfile,MSG_HEAD_MSGID,msgid((char *)tempvar.tempstring));
      if(config.replyto[0])
        fprintf(tempfile,MSG_HEAD_REPLY,config.real_name,config.replyto);
      if((config.homepage[0])&&(tempvar.registered))
        fprintf(tempfile,MSG_HEAD_XURL,config.homepage);
      if(tempvar.registered)
        fprintf(tempfile,MSG_HEAD_READ,VERSION,"");
      else
      {
        fprintf(tempfile,MSG_HEAD_READ,VERSION,"(Unregistered)");
        fprintf(tempfile,MSG_HEAD_XURL,HOMEPAGE);
      }
      if(config.organization[0])
        fprintf(tempfile,MSG_HEAD_ORG,config.organization);
    }
    fprintf(tempfile,"\n");
  }

  oldtime=strlen(config.replystring2);
  newtime=0;
  while(newtime<oldtime)
  {
    if( config.replystring2[ newtime ] == '%' )
    {
      newtime++;
      if( config.replystring2[ newtime ] == 'm' )
        fprintf( tempfile , "%s" , from_msgid );
      else if( config.replystring2[ newtime ] == 'e' )
        fprintf( tempfile , "%s" , from_email);
      else if( config.replystring2[ newtime ] == 'n' )
        fprintf( tempfile,"%s" , from_name );
      else if( config.replystring2[ newtime ] == 's' )
        fprintf( tempfile,"%s",subject);
      else if( config.replystring2[ newtime ] == 'd' )
        fprintf( tempfile,"%s",from_date);
      else if( config.replystring2[ newtime ] == 'r' )
        fputc( '\n',tempfile);
      else if( config.replystring2[ newtime ] == 'g' )
        fprintf( tempfile,"%s",active.tempgroup->groupname);
      else if( config.replystring2[ newtime ] == '%' )
        fputc( '%',tempfile);
    }
    else
      fputc(config.replystring2[newtime],tempfile);
    newtime++;
  }

  fseek(sigfile,active.tempmessage->offset,SEEK_SET);
  exit=FALSE;
  while(exit!=TRUE)
  {
    if(fgets((char*)tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)==NOLL)
      exit=TRUE;
    else if(tempvar.tempstring[NOLL]=='.'&&(tempvar.tempstring[1]=='\n'||tempvar.tempstring[1]=='\r'))
      exit=TRUE;
    if(!exit)
    {
      tempvar.temp1=strcspn(tempvar.tempstring,"\r");
      tempvar.tempstring[tempvar.temp1]='\n';
      tempvar.tempstring[tempvar.temp1+1]=NOLL;
      if(tempvar.tempstring[NOLL]=='>')
        fprintf(tempfile,">");
      else
        fprintf(tempfile,"> ");
      fprintf(tempfile,tempvar.tempstring);
    } 
  }
  fclose(sigfile);sigfile=NULL;
  fprintf(tempfile,"\n");
  if(config.mailtype!=MAILTYPE_INFITRA)
  {
    if(config.signature[NOLL]!=NOLL)
    {
      sigfile=fopen(config.signature,"r");
      if(sigfile!=NULL)
      {
        fprintf(tempfile,"--\n");
        while(fgets(tempvar.tempstring,MAXSTRING+ROWSIZE,sigfile)!=NOLL)
        {
          fputs(tempvar.tempstring,tempfile);
        }
      }
#ifdef LOGGING
      else
        Log(LOG_ERROR,"create_reply_email: Could not open signature file.\n");
#endif
    }    
    if(sigfile!=NULL)
      fclose(sigfile),sigfile=NOLL;
  }
  fclose(tempfile),tempfile=NOLL;
  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short*)&oldtime,file,NOLL);
    Fclose(file);
  }
  execute(config.editor,TEMP_MESSAGE,FALSE);
  file=Fopen(TEMP_MESSAGE,NOLL);
  if(file>NOLL)
  {
    Fdatime((short *)&newtime,file,NOLL);
    Fclose(file);
  }

  if((oldtime!=newtime)&&(oldtime!=NOLL)&&(newtime!=NOLL))
  {
    if(alertbox(1,alerts[Q_QUEUE_EMAIL])==1)
    {
      change_flag(msg_num,MSG_FLAG_REP,TRUE);
      if(config.mailtype==MAILTYPE_ANTMAIL)
      {
        strcpy(tempvar.lastpath,tempvar.mailpath);
        strcat(tempvar.lastpath,ANT_OUT_PATH);
        time(&tid);
        sprintf(tempvar.tempstring,"%08x",tid);
        strcat(tempvar.lastpath,tempvar.tempstring);
        sigfile=fopen(tempvar.lastpath,"w");
        if(!sigfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open message-file to copy.\n");
#endif
          Return FALSE;
        }
        tempfile=fopen(TEMP_MESSAGE,"r");
        if(!tempfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open temporary message for copying.\n");
#endif
          fclose(sigfile);
          Return FALSE;
        }
        while(fgets(tempvar.tempstring,MAXSTRING,tempfile)!=NOLL)
        {
          fputs(tempvar.tempstring,sigfile);
        }
        fclose(tempfile);
        fclose(sigfile);
      }
      else if(config.mailtype==MAILTYPE_NEWSIE)
      {
        int num_lines=0;
        strcpy(tempvar.lastpath,tempvar.mailpath);
        time(&tid);
        sprintf(tempvar.tempstring,"%08x.txt",tid);
        strcat(tempvar.lastpath,tempvar.tempstring);
        sigfile=fopen(tempvar.lastpath,"w");
        strcpy(from_file,tempvar.lastpath);
        if(!sigfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open message-file to copy.\n");
#endif
          Return FALSE;
        }
        tempfile=fopen(TEMP_MESSAGE,"r");
        if(!tempfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open temporary message for copying.\n");
#endif
          fclose(sigfile);
          Return FALSE;
        }
        while(fgets(tempvar.tempstring,MAXSTRING,tempfile)!=NOLL)
        {
          fputs(tempvar.tempstring,sigfile);
          num_lines++;
        }
        fclose(tempfile);
        fclose(sigfile);
        tempfile=fopen(config.maildata,"a");
        if(!tempfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open Newsie Outbox.\n");
#endif
          Return FALSE;
        }
        fprintf(tempfile," Q 	");
        fprintf(tempfile,"%s	",subject);
        fprintf(tempfile,"%s	",from_name);
        if(from_reply[0])
          fprintf(tempfile,"%s	",from_reply);
        else
          fprintf(tempfile,"%s	",from_email);
        fprintf(tempfile,"%s	",date);
        fprintf(tempfile,"%s	",from_file);
        fprintf(tempfile,"%d\n",num_lines);
      }
      else if(config.mailtype==MAILTYPE_INFITRA)
      {
        strcpy(tempvar.lastpath,tempvar.mailpath);
        time(&tid);
        sprintf(tempvar.tempstring,"%08x.msn",tid);
        strcat(tempvar.lastpath,tempvar.tempstring);
        sigfile=fopen(tempvar.lastpath,"w");
        strcpy(from_file,tempvar.tempstring);
        if(!sigfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open message-file to copy.\n");
#endif
          Return FALSE;
        }
        tempfile=fopen(TEMP_MESSAGE,"r");
        if(!tempfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open temporary message for copying.\n");
#endif
          fclose(sigfile);
          Return FALSE;
        }
        while(fgets(tempvar.tempstring,MAXSTRING,tempfile)!=NOLL)
          fputs(tempvar.tempstring,sigfile);
        fclose(tempfile);
        fclose(sigfile);
        tempfile=fopen(config.maildata,"a");
        if(!tempfile)
        {
#ifdef LOGGING
          Log(LOG_ERROR,"create_reply_email: Could not open Newsie Outbox.\n");
#endif
          Return FALSE;
        }
        fprintf(tempfile,INFITRA_START);
        fprintf(tempfile,INFITRA_FROM,config.real_name,config.email);
        if(from_reply[0])
          fprintf(tempfile,INFITRA_TO,from_name,from_reply);
        else
          fprintf(tempfile,INFITRA_TO,from_name,from_email);
        fprintf(tempfile,INFITRA_SUBJECT,subject);
        fprintf(tempfile,INFITRA_DATE,date);
        fprintf(tempfile,INFITRA_STATE_QUEU);
        fprintf(tempfile,INFITRA_ATTACH);
//        fprintf(tempfile,INFITRA_ENCODE);
//        fprintf(tempfile,INFITRA_CHARSET);
        fprintf(tempfile,INFITRA_BODY,from_file);
      }
      else if(config.mailtype==MAILTYPE_MYMAIL)
      {
      }
    }
  }

  if(Fdelete(TEMP_MESSAGE))
  {
#ifdef LOGGING
    Log(LOG_ERROR,"create_reply_email: Could not delete temporary message.\n");
#endif
  }

  Return TRUE;
}

/********************************************************************/
/* Place a message as an child to an other message                  */
/********************************************************************/
void fix_comment(int parent, int child)
{
  NewsHeader *p;
  int prev=FAIL;
  FILE *hdr=NULL;
  
  active.tempgroup=get_entity(active.glist,active.group_num);
  if (!active.tempgroup)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not get group-information\n");
    #endif
    Return;
  }
  sprintf(tempvar.tempstring,"%s%s%s",config.newsdir,active.tempgroup->filename,HEADEREXT);
  hdr=fopen(tempvar.tempstring,"rb+");
  if(!hdr)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not open Headerfile\n");
    #endif
    Return;
  }

printf("3\n");getch();
  if(parent!=FAIL)
  {
    p=get_entity(active.mlist,parent);
    if(p->i.child!=FAIL)
    {
      prev=p->i.child;
      p=get_entity(active.mlist,p->i.child);
      while(p->i.next)
      {
        prev=p->i.next;
        p=get_entity(active.mlist,p->i.next);
      }
      p->i.next=child;
      fseek(hdr,SIZE_ID+prev*sizeof(NewsHeader),SEEK_SET);
      if(fwrite(p,sizeof(NewsHeader),1,hdr)!=1)
      {
        #ifdef LOGGING
        Log(LOG_ERROR,"Could not write changes to headerfile (fix_comment for prev)\n");
        #endif
      }
    }
    else
    {
      p->i.child=child;
      fseek(hdr,SIZE_ID+parent*sizeof(NewsHeader),SEEK_SET);
      if(fwrite(p,sizeof(NewsHeader),1,hdr)!=1)
      {
        #ifdef LOGGING
        Log(LOG_ERROR,"Could not write changes to headerfile (fix_comment for parent)\n");
        #endif
      }
    }
    p->i.next=child;
  }
  p=get_entity(active.mlist,child);
  p->i.parent=parent;
  p->i.prev=prev;
  p->i.next=FAIL;
  p->i.child=FAIL;

  fseek(hdr,SIZE_ID+child*sizeof(NewsHeader),SEEK_SET);
  if(fwrite(p,sizeof(NewsHeader),1,hdr)!=1)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not write changes to headerfile (fix_comment for child)\n");
    #endif
  }
  fclose(hdr);
  
  return;
}