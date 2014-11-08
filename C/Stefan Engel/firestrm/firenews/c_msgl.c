#include "firenews.h"

char *msg_line(int line, char *string, int stringsize, short *effects, short *color);
char *msg_next(char *string, int stringsize, short *effects, short *color);
/********************************************************************/
/* Initiering av message-list-f”nstret                              */
/********************************************************************/
void init_msglist_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_msglist_win(void)\n");
Log(LOG_INIT,"Messagelist Window Init\n");
#endif
  strncpy(msglist_win.w_name,alerts[WN_READ],MAXWINSTRING);
  strncpy(msglist_win.w_info,"",MAXWINSTRING);
  msglist_win.attr=NAME|MOVE|CLOSE|SIZE|UPARROW|DNARROW|VSLIDE|INFO|FULLER|SMALLER;
  msglist_win.icondata=&icons[ICON_FIRESTORM];
  msglist_win.status=WINDOW_CLOSED;
  msglist_win.type=TYPE_LIST;
  msglist_win.text=&msglist_text;
  msglist_win.text->createline=&msg_line;
  msglist_win.text->createnext=&msg_next;
  msglist_win.text->sc_left=TRUE;
  msglist_win.text->sc_right=TRUE;
  msglist_win.text->sc_up=TRUE;
  msglist_win.text->sc_down=TRUE;

  rsrc_gaddr(R_TREE,MSGL_TOP,&msglist_win.text->dialog);
//  msglist_win.text->dialog=NOLL;

 Return;
}

/********************************************************************/
/* ™ppnar read-f”nstret                                             */
/********************************************************************/
void open_msglist_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"open_msglist_win(void)\n");
  Log(LOG_WINDOW,"Opening message-list window\n");
#endif

  if((active.mlist)&&(msglist_win.status!=WINDOW_CLOSED))
  {
    open_dialog(&msglist_win,tempconf.msglw_xy);
    Return;
  }
  else
  {
    load_header(active.group_num);
    msglist_win.text->num_of_rows=active.num_of_messages;
    msglist_win.text->num_of_cols=80;
    msglist_win.text->offset_y=0;
    msglist_win.text->offset_x=0;
  }
  active.tempgroup=get_entity(active.glist,active.group_num);
  if(!active.tempgroup)
    msglist_win.text->select=0;
  else
    msglist_win.text->select=msg2list(active.tempgroup->msg_num);
  active.tempmessage=get_entity(active.mlist,list2msg(msglist_win.text->select));
  if(active.tempmessage)
  {
    if(active.tempmessage->flags.touched)
    {
      change_flag(list2msg(msglist_win.text->select),MSG_FLAG_TOUCHED,FALSE);
      set_mark(&msglist_win,msglist_win.text->select,TRUE);
    }
  }
  sprintf(tempvar.tempstring,"#%4d %s",active.num_of_messages,active.tempgroup->groupname);
  strncpy(msglist_win.w_info,tempvar.tempstring,MAXWINSTRING);

  menu_ienable(menu_tree,MENU_SAVE_MESS,TRUE); 
  if(!active.tempgroup->f_ronly)
  {
    menu_ienable(menu_tree,MENU_REPLY_G,TRUE); 
    menu_ienable(menu_tree,MENU_WRITE_NEW,TRUE); 
//    menu_ienable(menu_tree,MENU_CHANGE_MESS,TRUE); 
  }
  else
  {
    menu_ienable(menu_tree,MENU_REPLY_G,FALSE); 
    menu_ienable(menu_tree,MENU_WRITE_NEW,FALSE); 
    menu_ienable(menu_tree,MENU_CHANGE_MESS,FALSE); 
  }
  
  if(tempvar.mailpath[NOLL])
    menu_ienable(menu_tree,MENU_REPLY_E,TRUE); 
  menu_ienable(menu_tree,MENU_DEL_FLAGS,TRUE);
  menu_ienable(menu_tree,MENU_SET_FLAGS,TRUE);
  active.msg_num=active.tempgroup->msg_num;
  msglist_win.text->font_id=font.msglid;
  msglist_win.text->font_size=config.msglfontsize;
  open_dialog(&msglist_win,tempconf.msglw_xy);
  
  Return;
}

/********************************************************************/
/********************************************************************/
void close_msglistwin()
{
  active.tempgroup=get_entity(active.glist,active.group_num);
  if(!active.tempgroup)
  {
    Return;
  }
  active.tempgroup->msg_num=list2msg(msglist_win.text->select);
  if (msglist_win.status!=WINDOW_CLOSED)
  {
    if(msglist_win.status==WINDOW_OPENED)
      wind_get(msglist_win.ident,WF_CURRXYWH,&tempconf.msglw_xy[X],&tempconf.msglw_xy[Y],&tempconf.msglw_xy[W],&tempconf.msglw_xy[H]);
    else if(msglist_win.status==WINDOW_ICONIZED)
      wind_get(msglist_win.ident,WF_UNICONIFY,&tempconf.msglw_xy[X],&tempconf.msglw_xy[Y],&tempconf.msglw_xy[W],&tempconf.msglw_xy[H]);
    close_dialog(&msglist_win);
  }
  menu_ienable(menu_tree,MENU_REPLY_E,FALSE); 
  menu_ienable(menu_tree,MENU_REPLY_G,FALSE);
  menu_ienable(menu_tree,MENU_WRITE_NEW,FALSE); 
  menu_ienable(menu_tree,MENU_CHANGE_MESS,FALSE); 
  menu_ienable(menu_tree,MENU_SAVE_MESS,FALSE);
  menu_ienable(menu_tree,MENU_DEL_FLAGS,FALSE);
  menu_ienable(menu_tree,MENU_SET_FLAGS,FALSE);
}
/********************************************************************/
/* Hantering av read-f”nstret                                       */
/********************************************************************/
void check_msglist_win(const RESULT svar)
{
  
#ifdef LOGGING
Log(LOG_FUNCTION,"check_msglist_win(...)\n");
  Log(LOG_WINDOW,"checking message-list window\n");
#endif
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_msglistwin();
    if(read_win.status!=WINDOW_CLOSED)
      close_readwin(); 
  }
  else if(svar.type==TEXT_CLICKED)
  {
    if((svar.data[SVAR_MOUSE_BUTTON]==MO_LEFT)&&(svar.data[SVAR_MOUSE_CLICKS]==1))
    {
      active.tempmessage=get_entity(active.mlist,list2msg(svar.data[SVAR_OBJECT]));
      if(active.tempmessage)
      {
        if(active.tempmessage->flags.touched)
        {
          change_flag(list2msg(svar.data[SVAR_OBJECT]),MSG_FLAG_TOUCHED,FALSE);
          set_mark(&msglist_win,svar.data[SVAR_OBJECT],TRUE);
        }
      }
    }
    if((svar.data[SVAR_MOUSE_BUTTON]==MO_LEFT)&&(svar.data[SVAR_MOUSE_CLICKS]==2))
    {
      active.msg_num=list2msg(svar.data[SVAR_OBJECT]);
      open_read_win();
    }
    else if (svar.data[SVAR_MOUSE_BUTTON]==MO_RIGHT)
    {
      active.tempmessage=get_entity(active.mlist,list2msg(svar.data[SVAR_OBJECT]));
      if(active.tempmessage)
      {
        if(active.tempmessage->flags.touched)
        {
          change_flag(list2msg(svar.data[SVAR_OBJECT]),MSG_FLAG_TOUCHED,FALSE);
          set_mark(&msglist_win,svar.data[SVAR_OBJECT],TRUE);
        }
      }
      switch(freepopup(alerts[P_LIST_ENTRY],-1,svar.data[SVAR_MOUSE_X],svar.data[SVAR_MOUSE_Y],NULL))
      {
        case 0:  /* View Message */
          active.msg_num=list2msg(svar.data[SVAR_OBJECT]);
          open_read_win();
          break;
        case 1:  /* Reply via E-mail) */
          create_reply_email(list2msg(svar.data[SVAR_OBJECT]));
          break;
        case 2:  /* Reply in group */
          create_reply_group(list2msg(svar.data[SVAR_OBJECT]));
          break;
        case 3:  /* Seperator */
          break;
        case 4:  /* Add name to adressbook */
          break;
        case 5:  /* Delete Message */
          change_flag(list2msg(svar.data[SVAR_OBJECT]),MSG_FLAG_DEL,TRUE);
          set_mark(&msglist_win,svar.data[SVAR_OBJECT],TRUE);
          break;
        case 6:  /* Save Message */
          save_message(list2msg(svar.data[SVAR_OBJECT]));
          break;
        case 7:  /* Seperator */
          break;
        case 8: /* Set/Del Flags */
          open_flags_win(FLAGS_SETDEL_LIST);
          break;
      }
    }
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case MSGL_REPLY_G:
        create_reply_group(list2msg(msglist_win.text->select));
        button(&msglist_win, MSGL_REPLY_G, CLEAR_STATE, SELECTED,TRUE);
        break;
      case MSGL_REPLY_E:
        create_reply_email(list2msg(msglist_win.text->select));
        button(&msglist_win, MSGL_REPLY_E, CLEAR_STATE, SELECTED,TRUE);
        break;
      case MSGL_SAVE:
        save_message(list2msg(msglist_win.text->select));
        button(&msglist_win, MSGL_SAVE, CLEAR_STATE, SELECTED,TRUE);
        break;
      case MSGL_FORWARD_G:
        button(&msglist_win, MSGL_FORWARD_G, CLEAR_STATE, SELECTED,TRUE);
        break;
      case MSGL_FORWARD_E:
        button(&msglist_win, MSGL_FORWARD_E, CLEAR_STATE, SELECTED,TRUE);
        break;
    }
  }
  Return;
}

/********************************************************************/
/* Skapa en text-Rad till Listan                                    */
/********************************************************************/
char *msg_line(int line, char *string, int stringsize, short *effects, short *color)
{
  int tempint;
  NewsHeader *nh;
  CommentList *cl;
  char from[ROWSIZE],subject[ROWSIZE];
#ifdef LOGGING
  Log(LOG_FUNCTION,"msg_line(...)\n");
#endif

  tempvar.line=line;
  nh=get_entity(active.mlist,list2msg(tempvar.line));
  if(!nh)
  {
    Return string;
  }

  *color=BLACK;
  *effects=NOLL;
  strcpy(tempvar.temprow1,"");
  if(nh->flags.new)
    strcat(tempvar.temprow1,MSG_FLAG_NEW),*color=RED;
  if(nh->flags.replied)
    strcat(tempvar.temprow1,MSG_FLAG_REP);
  if(nh->flags.deleted)
    strcat(tempvar.temprow1,MSG_FLAG_DEL),*effects|=SHADOW;
  if(nh->flags.keep)
    strcat(tempvar.temprow1,MSG_FLAG_KEEP);
  if(nh->flags.header_only)
    strcat(tempvar.temprow1,MSG_FLAG_HEAD),*effects|=SKEWED;
  if(nh->flags.requested)
    strcat(tempvar.temprow1,MSG_FLAG_REQ);
  if(nh->flags.outgoing)
    strcat(tempvar.temprow1,MSG_FLAG_OUT),*effects|=THICKENED;
  if(nh->flags.touched)
    *color=BLUE;

  strcpy(tempvar.temprow2,"");
  if(config.show_comment)
  {
    cl=get_entity(active.clist,tempvar.line);
    if(cl)
    {
      NewsHeader *temp_nh;
      tempint=cl->depth;
      
      tempvar.temprow2[tempint+1]='\0';
      temp_nh=get_entity(active.mlist,cl->msg_num);
      while(tempint>0)
      {
        tempint--;
        if(temp_nh)
        {
          if(temp_nh->i.next!=FAIL)
          {
            if(tempint==cl->depth-1)
            {
              if(temp_nh->i.child!=FAIL)
                tempvar.temprow2[tempint+1]='Â';
              else
                tempvar.temprow2[tempint+1]='Ä';
              tempvar.temprow2[tempint]='Ã';
            }
            else
              tempvar.temprow2[tempint]='³';
          }
          else
          {
            if(tempint==cl->depth-1)
            {
              if(temp_nh->i.child!=FAIL)
                tempvar.temprow2[tempint+1]='Â';
              else
                tempvar.temprow2[tempint+1]='Ä';
              
              tempvar.temprow2[tempint]='À';
            }
            else
              tempvar.temprow2[tempint]=' ';
          }
          temp_nh=get_entity(active.mlist,temp_nh->i.parent);
        }
      }
    }
  }
#ifdef LOGGING
  Log(LOG_WINDOW,"  flags   =%s\n",tempvar.temprow1);
  Log(LOG_WINDOW,"  from    =%s\n",nh->from);
  Log(LOG_WINDOW,"  subject =%s\n",nh->subject);
#endif

  sprintf(string,"%-6s %s%-5d %-31s %-41s",tempvar.temprow1,tempvar.temprow2,list2msg(tempvar.line)+1,nh->from,nh->subject);
  Return string;
}

/********************************************************************/
/* Skapa en Text-Rad till Listan, baserad p† tidigare v„rde         */
/********************************************************************/
char *msg_next(char *string,int stringsize,short *effects,short *color)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"msg_next(...)\n");
#endif
  tempvar.line++;
  Return msg_line(tempvar.line,string,stringsize,effects,color);
}

/********************************************************************/
/********************************************************************/
int list2msg(int com)
{
  CommentList *cl;

#ifdef LOGGING
Log(LOG_FUNCTION,"list2msg(...)\n");
#endif

  if(config.show_comment)
  {
    cl=get_entity(active.clist,com);
    if(!cl)
    {
      Return com;
    }
    else
    {
      Return cl->msg_num;
    }
  }
  else
  {
    Return com;
  }
}
/********************************************************************/
/********************************************************************/
int msg2list(int msg)
{
  CommentList *cl;
  int com=0;

#ifdef LOGGING
Log(LOG_FUNCTION,"msg2list(...)\n");
#endif

  if(config.show_comment)
  {
    while(com<active.num_of_messages)
    {
      cl=get_entity(active.clist,com);
      if(cl)
      {
        if(cl->msg_num==msg)
        {
          Return com;
        }
      }
      com++;
    }
  }
  Return msg;
}