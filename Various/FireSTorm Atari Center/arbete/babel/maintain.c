#include <stdio.h>
#include <string.h>
#include <time.h>

#include "..\fire.h"
#include "babel.h"

#define MAXSTRING 255
#define MAXTIMELENGTH 18
#define STATUSLENGTH 80

extern ACTIVE active;
extern int program_exit;
/********************************************************************/
/* maintain() this routine should check the flags, etc...           */
/********************************************************************/
void maintain( void )
{
  GROUPS *group=0;

  status_line( "Maintain of Newsgroups has started" ,TRUE ,"","") ;
  active.group_num=0;
  
  while( active.group_num < active.num_of_groups )
  {
    group=get_entity(active.glist,active.group_num);
    if(!group)
      break;
    status_line( "" ,TRUE , active.servers[ group->serv_num ].name , group->groupname ) ;

    if(program_exit) break;
    check_old_date(group);
    if(program_exit) break;
    delete_dupes(group);
    if(program_exit) break;
    hard_delete(group);
    if(program_exit) break;
    make_comment(group);
    if(program_exit) break;
    /* continue with the next group */
    active.group_num++;
  }
}

/****************************************************************/
/* Check for old messages and soft-delete them                  */
/****************************************************************/
void check_old_date(GROUPS *group)
{
  char tempstring[MAXSTRING+1];
  FILE *readfile;
  NewsHeader *nh;
  int number_of_messages;
  
  number_of_messages=load_header(group->filename);
  if(!number_of_messages)
    return;
  status_line( "Deleting old messages" ,TRUE , active.servers[ group->serv_num ].name , group->groupname ) ;

  if((group->days)||(group->max_days)||(active.servers[group->serv_num].d_days)||(active.servers[group->serv_num].d_max_days))
  {
    char *tecken ;
    long days , max_days , msg_day ;
    struct tm *nu;
    int mdays[]={31,28,31,30,31,30,31,31,30,31,30,31};
    
    struct day
    {
      int year,
          month,
          day;
    } day1,day2;
    
    time(&msg_day);
    nu=localtime(&msg_day);
    day1.year=nu->tm_year+1900;
    day1.month=nu->tm_mon;
    day1.day=nu->tm_mday;
    
    if( ( group->days ) && ( ! active.servers[ group->serv_num ].d_days ) )
      days=group->days;
    else if( ( ! group->days ) && ( active.servers[ group->serv_num ].d_days ) )
      days = active.servers[ group->serv_num ].d_days;
    else if( group->days < active.servers[ group->serv_num ].d_days )
      days=group->days;
    else
      days=active.servers[group->serv_num].d_days;

    if( ( group->max_days ) && ( ! active.servers[ group->serv_num ].d_max_days ) )
      max_days=group->days;
    else if( ( ! group->max_days ) && ( active.servers[ group->serv_num ].d_max_days ) )
      max_days=active.servers[group->serv_num].d_max_days;
    else if( group->max_days < active.servers[ group->serv_num ].d_max_days )
      max_days=group->max_days;
    else
      max_days=active.servers[group->serv_num].d_max_days;

    if((max_days)&&(days)&&(max_days<days))
      day1.day-=max_days;
    else if((max_days)&&(days))
      day1.day-=days;
    else if( max_days )
      day1.day-=max_days;
    else
      day1.day-=days;

    while(day1.day<1)
    {
      day1.month--;
      if(day1.month<0)
        day1.month=11;
      day1.day+=mdays[day1.month];
    }

    sprintf(tempstring,"%s%s.%s",active.newsdir,group->filename,"inm");
    readfile=fopen(tempstring,"rb");
    if(!readfile)
      return;
    active.msg_num=0;
    while(active.msg_num < number_of_messages )
    {
      event_loop();
      if ( program_exit ) { break; }
      nh=get_entity(active.mlist,active.msg_num);
      if(!nh)
        break;
      if((nh->datetime.year==0)&&(nh->datetime.month==0)&&(nh->datetime.day==0)&&(nh->datetime.hour==0)&&(nh->datetime.min==0)&&(nh->datetime.sec==0))
      {
        fseek(readfile,nh->offset,SEEK_SET);
        while(fgets(tempstring,MAXSTRING,readfile))
        {
          tecken=strpbrk(tempstring,"\n\r");
          if(tecken)
            *tecken=0;
          if(tempstring[0]==0)
            break;
          if((tempstring[0]=='.')&&(tempstring[1]==0))
            break;
          if(!strncmp(tempstring,"Date: ",6))
          {
            int day=0,year=0,hour=0,min=0,sec=0,temp1;
            char month[4];
            month[3]=0;
            temp1=0;
            while( !isdigit( tempstring[ temp1 ] ) ) temp1++ ;
            sscanf( tempstring + temp1 , "%d %c%c%c %d %d:%d:%d" , &day , &month[ 0 ] , &month[ 1 ] , &month[ 2 ] , &year , &hour , &min , &sec ) ;
            month[0]=toupper(month[0]);
            month[1]=toupper(month[1]);
            month[2]=toupper(month[2]);
            if(year<50)
              nh->datetime.year=year+20;
            else if(year<100)
              nh->datetime.year=year-80;
            else
              nh->datetime.year=year-1980;
            nh->datetime.day=day;
            nh->datetime.hour=hour;
            nh->datetime.min=min;
            nh->datetime.sec=sec;
            if(!strcmp(month,"JAN"))
              nh->datetime.month=0;
            else if(!strcmp(month,"FEB"))
              nh->datetime.month=1;
            else if(!strcmp(month,"MAR"))
              nh->datetime.month=2;
            else if(!strcmp(month,"APR"))
              nh->datetime.month=3;
            else if(!strcmp(month,"MAY"))
              nh->datetime.month=4;
            else if(!strcmp(month,"JUN"))
              nh->datetime.month=5;
            else if(!strcmp(month,"JUL"))
              nh->datetime.month=6;
            else if(!strcmp(month,"AUG"))
              nh->datetime.month=7;
            else if(!strcmp(month,"OCT"))
              nh->datetime.month=8;
            else if(!strcmp(month,"SEP"))
              nh->datetime.month=9;
            else if(!strcmp(month,"NOV"))
              nh->datetime.month=10;
            else if(!strcmp(month,"DEC"))
              nh->datetime.month=11;
          }
        }  
      }
      day2.year=nh->datetime.year+1980;
      day2.month=nh->datetime.month;
      day2.day=nh->datetime.day;

      if(!nh->flags.keep)
      {
        if( day2.year < day1.year )
          nh->flags.deleted = TRUE;
        else if( day2.year == day1.year )
        {
          if( day2.month < day1.month )
            nh->flags.deleted = TRUE ;
          else if( day2.month == day1.month )
          {
            if( day2.day < day1.day )
              nh->flags.deleted = TRUE ;
          }
        }
      }
      active.msg_num++;
    }
    fclose(readfile);
  }
  save_header( group->filename, FALSE ) ;
  free_list( &active.mlist ) ;
  active.mlist=0;
}

/****************************************************************/
/* 2: Check for dupes                                           */
/****************************************************************/
void delete_dupes(GROUPS *group)
{
//  char statusstr[MAXSTRING+1];
//  char tempstring[MAXSTRING+1];
  int number_of_messages;
//  FILE *readfile;
//  NewsHeader *nh;

  number_of_messages=load_header(group->filename);
  if(!number_of_messages)
    return;
  status_line( "Deleting dupes (NA)" ,TRUE , active.servers[ group->serv_num ].name , group->groupname ) ;
  save_header( group->filename, FALSE ) ;
  free_list( &active.mlist ) ;
  active.mlist=0;
}

/****************************************************************/
/* 3: Hard-Delete soft-deleted message                          */
/****************************************************************/
void hard_delete(GROUPS *group)
{
  char statusstr[MAXSTRING+1];
  char tempstring[MAXSTRING+1],tempfile[MAXSTRING+1];
  FILE *readfile,*writefile;
  int deleting,number_of_messages;
  long next_offset;
  NewsHeader *nh;

  number_of_messages=load_header(group->filename);

  sprintf( statusstr, "Removing Deleted Messages") ;
  status_line( statusstr ,TRUE ,NULL,NULL) ;
  deleting=FALSE;
  active.msg_num=0;
  while(active.msg_num < number_of_messages )
  {
    event_loop();
    nh=get_entity(active.mlist,active.msg_num);
    if(!nh)
      break;
    if(nh->flags.deleted)
    {
      deleting=TRUE;
      break;
    }
    active.msg_num++;
  }
  if(deleting)
  {
    active.msg_num=0;
    sprintf(tempstring,"%s%s.%s",active.newsdir,group->filename,"inm");
    readfile=fopen(tempstring,"rb");
    if(!readfile)
      return;
    sprintf(tempstring,"%s12345687.984",active.newsdir);
    writefile=fopen(tempstring,"wb");
    if(!writefile)
      return;
    fseek(writefile,0,SEEK_SET);                                      /* 2 Fseeks, perheps one of the works? :)                              */
    fseek(writefile,0,SEEK_SET);
    next_offset=0;                                                    /* Reset the offset-counter                                            */
    while(active.msg_num < number_of_messages )
    {
      event_loop();
      nh=get_entity(active.mlist,active.msg_num);
      if(!nh)
        return;
      if(!(nh->flags.deleted))
      {
        fseek(readfile,nh->offset,SEEK_SET);
        nh->offset=next_offset;
        tempstring[0]=0;
        tempstring[1]=0;
        tempstring[2]=0;
        while(fgets(tempstring,MAXSTRING,readfile))
        {
          fputs(tempstring,writefile);
          if(strpbrk(tempstring,"\n\r"))
            *strpbrk(tempstring,"\n\r")=0;
          if(!strcmp(tempstring,"."))
            break;
        }
        fseek(writefile,0,SEEK_END);
        next_offset=ftell(writefile);
      }
      else
      {
        del_entity(&active.mlist,active.msg_num);
        if(active.msg_num<=group->msg_num)
          group->msg_num--;
        active.msg_num--;
        number_of_messages--;
      }
      active.msg_num++;
    }
    fclose(readfile);
    fclose(writefile);
    sprintf(tempstring,"%s%s.%s",active.newsdir,group->filename,"inm");
    remove(tempstring);
    sprintf(tempfile,"%s12345687.984",active.newsdir);
    rename(tempfile,tempstring);
    save_header( group->filename, FALSE ) ;
  }
  free_list( &active.mlist ) ;
  active.mlist=0;
}


/****************************************************************/
/* 2: Check for dupes                                           */
/****************************************************************/
void make_comment(GROUPS *group)
{
  char statusstr[ MAXSTRING +1 ];
  char tempstring[ MAXSTRING +1 ];
  int number_of_messages,counter,more_ref;
  char *msgids;
  char tempmsgid[ MAXSTRING + 1 ];
  FILE *readfile;
  NewsHeader *nh,*nh2;

  number_of_messages=load_header(group->filename);
  if(!number_of_messages)
    return;
  status_line( "Creating Comment Tree" ,TRUE , active.servers[ group->serv_num ].name , group->groupname ) ;
  msgids=Malloc(128*number_of_messages);
  memset(msgids,0,128*number_of_messages);
  if(!msgids)
  {
    return;
  }
  sprintf(tempstring,"%s%s.%s",active.newsdir,group->filename,"inm");
  readfile=fopen(tempstring,"rb");
  if(!readfile)
    return;
  active.msg_num=0;
  while(active.msg_num<number_of_messages)
  {
    event_loop();
    if ( program_exit ) { break; }

    nh=get_entity(active.mlist,active.msg_num);
    if(nh)
    {
      fseek(readfile,nh->offset,SEEK_SET);
      nh->i.parent=FAIL;
      nh->i.child=FAIL;
      nh->i.next=FAIL;
      nh->i.prev=FAIL;
      do
      {
        fgets(tempstring,MAXSTRING,readfile);
        if(strpbrk(tempstring,"\n\r"))
          *strpbrk(tempstring,"\n\r")=0;

        if (!strncmp(tempstring,"Message-ID: ",12))
        {
          tempstring[127+11]=0;
          sscanf(tempstring,"Message-ID: %s",statusstr);
          strncpy(msgids+128*active.msg_num,statusstr,128);
          *tempstring='\0';
        }
      }while ((*tempstring)&&(strcmp(tempstring,".")));
    }
    active.msg_num++;
  }
  active.msg_num=0;
  while(active.msg_num<number_of_messages)
  {
    event_loop();
    if ( program_exit ) { break; }
    
    nh=get_entity(active.mlist,active.msg_num);
    more_ref=FALSE;
    if(nh)
    {
      fseek(readfile,nh->offset,SEEK_SET);
      *tempstring=0;
      strcpy(tempmsgid,"");
      do
      {
        fgets(tempstring,MAXSTRING,readfile);
        if(*tempstring!=' ' && *tempstring!='	' && more_ref)
        {
          *tempstring=0;
          more_ref=FALSE;
        }
        
        if(strpbrk(tempstring,"\n\r"))
          *strpbrk(tempstring,"\n\r")=0;
        if ((!strncmp(tempstring,"References: ",12))||more_ref)
        {
		  more_ref=TRUE;
		  
          if(active.msg_num==709)
		    Log("<Ref>%s",tempstring);
          if((strrchr(tempstring,'<'))&&(strrchr(tempstring,'>')))
          {
            strrchr(tempstring,'>')[1]=0;
            strcpy(tempmsgid,strrchr(tempstring,'<'));
          }
        }
        if(*tempmsgid!=0 && !more_ref)
        {
          counter=0;
			
          while(counter<number_of_messages)
          {
            if(!strcmp(tempmsgid,msgids+128*counter))
            {
              nh->i.parent=counter;
              nh2=get_entity(active.mlist,counter);
              if(nh2)
              {
                if(nh2->i.child==FAIL)
                  nh2->i.child=active.msg_num;
                else
                {
                  counter=nh2->i.child;
                  nh2=get_entity(active.mlist,counter);
                  while(nh2->i.next!=FAIL)
                  {
                    counter=nh2->i.next;
                    nh2=get_entity(active.mlist,counter);
                  }
                  nh2->i.next=active.msg_num;
                  nh->i.prev=counter;
                }
              }
              counter=number_of_messages;
            }
            counter++;
          }
          *tempstring='\0';
        }
      }while ((*tempstring)&&(strcmp(tempstring,".")));
    }
    active.msg_num++;
  }
  Mfree(msgids),msgids=0;
  save_header( group->filename, FALSE ) ;
  free_list( &active.mlist ) ;
  active.mlist=0;
}
