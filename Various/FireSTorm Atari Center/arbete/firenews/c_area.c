#include "firenews.h"
char *sub_line(int line, char *string, int stringsize, short *effects, short *color);
char *sub_next(char *string, int stringsize, short *effects, short *color);
char *unsub_line(int line, char *string, int stringsize, short *effects, short *color);
char *unsub_next(char *string, int stringsize, short *effects, short *color);
/********************************************************************/
/********************************************************************/
void init_arealist_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_arealist_win(void)\n");
Log(LOG_INIT,"Grouplist (subsc&unsubs) init\n");
#endif
  strncpy(sublist_win.w_name,alerts[WN_AREALIST_OPEN],MAXWINSTRING);
  strncpy(sublist_win.w_info,"",MAXWINSTRING);
  sublist_win.attr=NAME|MOVE|CLOSE|SIZE|UPARROW|DNARROW|VSLIDE|INFO|FULLER|SMALLER;
  sublist_win.icondata=&icons[ICON_FIRESTORM];
  sublist_win.status=WINDOW_CLOSED;
  sublist_win.type=TYPE_LIST;
  sublist_win.text=&sublist_text;
  sublist_win.text->createline=&sub_line;
  sublist_win.text->createnext=&sub_next;
  sublist_win.text->dialog=0;
  sublist_win.text->sc_left=TRUE;
  sublist_win.text->sc_right=TRUE;
  sublist_win.text->sc_up=TRUE;
  sublist_win.text->sc_down=TRUE;

  strncpy(unsublist_win.w_name,alerts[WN_AREALIST_OPEN],MAXWINSTRING);
  strncpy(unsublist_win.w_info,"",MAXWINSTRING);
  unsublist_win.attr=NAME|MOVE|CLOSE|SIZE|UPARROW|DNARROW|VSLIDE|INFO|FULLER|SMALLER;
  unsublist_win.icondata=&icons[ICON_FIRESTORM];
  unsublist_win.status=WINDOW_CLOSED;
  unsublist_win.type=TYPE_LIST;
  unsublist_win.text=&unsublist_text;
  unsublist_win.text->createline=&unsub_line;
  unsublist_win.text->createnext=&unsub_next;
  unsublist_win.text->dialog=0;
  unsublist_win.text->sc_left=TRUE;
  unsublist_win.text->sc_right=TRUE;
  unsublist_win.text->sc_up=TRUE;
  unsublist_win.text->sc_down=TRUE;

  Return;
}

/********************************************************************/
/* ™ppnar Arealist-f”nstret                                         */
/********************************************************************/
void open_arealist_win(int which)
{
  tempvar.area_type=which;
#ifdef LOGGING
Log(LOG_FUNCTION,"open_arealist_win(int)\n");
Log(LOG_FUNCTION2,"int = %l\n",which);
#endif
  if(!active.servers) { Return; }

  if (which==GROUP_SUB)
  {
    if(sublist_win.status!=WINDOW_CLOSED)
    {
      wind_set(sublist_win.ident,WF_TOP,sublist_win.ident,NOLL,NOLL,NOLL);
      Return;
    }  
    sublist_win.text->num_of_rows=active.num_of_groups;
    sublist_win.text->select=active.serv_num;
    sublist_win.text->font_id=font.subid;
    sublist_win.text->font_size=config.subfontsize;
    open_dialog(&sublist_win,tempconf.subsw_xy);
  }
  else 
  {
    if(which==GROUP_NEW)
    {
      if(!load_grouplist(FALSE,FALSE))
      {
        Return;
      }
      sprintf(unsublist_win.w_info,"%d New Groups",active.num_of_unsub_groups);
      active.servers[active.serv_num].del_newgroup=TRUE;
    }
    else if(which==GROUP_NEWASK)
    {
      if(!load_grouplist(FALSE,TRUE))
      {
        Return;
      }
      sprintf(unsublist_win.w_info,"%d New Groups",active.num_of_unsub_groups);
      active.servers[active.serv_num].del_newgroup=TRUE;
      
    }
    else
    {
      if(!load_grouplist(TRUE,FALSE))
      {
        Return;
      }
      sprintf(unsublist_win.w_info,"%d Unsubscribed Groups",active.num_of_unsub_groups);
    }
    
    unsublist_win.text->num_of_rows=active.num_of_unsub_groups;
    unsublist_win.text->select=0;
    unsublist_win.text->font_id=font.unsubid;
    unsublist_win.text->font_size=config.unsubfontsize;
    open_dialog(&unsublist_win,tempconf.usubw_xy);
  }
  Return;
}

/********************************************************************/
/********************************************************************/
void close_sublistwin()
{
  if(sublist_win.status!=WINDOW_CLOSED)
  {
    if(sublist_win.status==WINDOW_OPENED)
      wind_get(sublist_win.ident,WF_CURRXYWH,&tempconf.subsw_xy[X],&tempconf.subsw_xy[Y],&tempconf.subsw_xy[W],&tempconf.subsw_xy[H]);
    else if(sublist_win.status==WINDOW_ICONIZED)
      wind_get(sublist_win.ident,WF_UNICONIFY,&tempconf.subsw_xy[X],&tempconf.subsw_xy[Y],&tempconf.subsw_xy[W],&tempconf.subsw_xy[H]);
    close_dialog(&sublist_win);
  }
}
/********************************************************************/
/********************************************************************/
void close_unsublistwin()
{
  if(unsublist_win.status!=WINDOW_CLOSED)
  {
    if(unsublist_win.status==WINDOW_OPENED)
      wind_get(unsublist_win.ident,WF_CURRXYWH,&tempconf.usubw_xy[X],&tempconf.usubw_xy[Y],&tempconf.usubw_xy[W],&tempconf.usubw_xy[H]);
    else if(unsublist_win.status==WINDOW_ICONIZED)
      wind_get(unsublist_win.ident,WF_UNICONIFY,&tempconf.usubw_xy[X],&tempconf.usubw_xy[Y],&tempconf.usubw_xy[W],&tempconf.usubw_xy[H]);
    close_dialog(&unsublist_win);
  }
}
/********************************************************************/
/* Hantering av arealist-f”nstret                                   */
/********************************************************************/
void check_arealist_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_arealist_win(RESULT)\n");
Log(LOG_FUNCTION2,"RESULT type= %l\n",svar.type);
#endif
  
  if(svar.type==WINDOW_CLICKED)
  {
    switch(svar.data[SVAR_WINDOW_MESSAGE])
    {
      case WM_CLOSED:
        if(svar.data[SVAR_WINDOW_ID]==sublist_win.ident)
        {
          close_sublistwin();
        }
        else if(svar.data[SVAR_WINDOW_ID]==unsublist_win.ident)
        {
          free(active.ungroups),active.ungroups=0;
          close_unsublistwin();
        }
        break;
      default:
        break;
    }
  }
  else if (svar.type==TEXT_CLICKED)
  {
    if(svar.data[SVAR_WINDOW_ID]==sublist_win.ident)
    {
      if((svar.data[SVAR_MOUSE_BUTTON]==MO_LEFT)&&(svar.data[SVAR_MOUSE_CLICKS]==2))
      {
        if(svar.data[SVAR_OBJECT]!=active.group_num)
        {
          free_list(&active.mlist);
        }
        active.group_num=svar.data[SVAR_OBJECT];
        if(read_win.status!=WINDOW_CLOSED)
          close_readwin();
        open_msglist_win();
      }
      else if(svar.data[SVAR_MOUSE_BUTTON]==MO_RIGHT)
      {
        switch(freepopup(alerts[P_SUB_AREA],-1,svar.data[SVAR_MOUSE_X],svar.data[SVAR_MOUSE_Y],NULL))
        {
          case 0:
            open_group_win(svar.data[SVAR_OBJECT]);
            break;
          case 1:
            del_entity(&active.glist,svar.data[SVAR_OBJECT]);
            active.num_of_groups--;
            sublist_win.text->num_of_rows=active.num_of_groups;
            redraw_window(&sublist_win);
            break;
        }
      }
    }
    else if(svar.data[SVAR_WINDOW_ID]==unsublist_win.ident)
    {
      GROUPS *g;
      int temp1,temp2;
      if((svar.data[SVAR_MOUSE_BUTTON]==MO_LEFT)&&(svar.data[SVAR_MOUSE_CLICKS]==2))
      {
        for(temp2=0;temp2<active.num_of_groups;temp2++)
        {
          g=get_entity(active.glist,temp2);
          if(!strcmp(active.ungroups[svar.data[SVAR_OBJECT]].groupname,g->groupname))
            temp1=TRUE;
        }
        if(!temp1)
        {
          g=new_entity(&active.glist,sizeof(GROUPS),config.group_alloc);
          if(!g)
          {
            sprintf(fel.text,alerts[E_ALLOC_MEM],"checkarealistwin(Add new group)");
            alertbox(1,fel.text);
            Return;
          }
          active.num_of_groups++;
          strncpy(g->groupname,active.ungroups[svar.data[SVAR_OBJECT]].groupname,ROWSIZE); g->groupname[ROWSIZE]=EOL;
          g->serv_num=active.serv_num;
          strncpy(g->description,active.ungroups[svar.data[SVAR_OBJECT]].description,ROWSIZE); g->description[ROWSIZE]=EOL;
          temp2=TRUE;
          create_groupfilename(g->groupname,tempvar.tempstring);
          strncpy(g->filename,tempvar.tempstring,ROWSIZE);
          sublist_win.text->num_of_rows=active.num_of_groups;
          redraw_window(&sublist_win);
          set_mark(&unsublist_win,svar.data[SVAR_OBJECT],TRUE);
        }
        else if(temp1)
        {
          temp1=FAIL;
          for(temp2=0;temp2<active.num_of_groups;temp2++)
          {
            g=get_entity(active.glist,temp2);
            if(!strcmp(active.ungroups[svar.data[SVAR_OBJECT]].groupname,g->groupname))
              temp1=temp2;
          }
          if(temp1!=FAIL)
          {
            del_entity(&active.glist,temp1);
            active.num_of_groups--;
            sublist_win.text->num_of_rows=active.num_of_groups;
            redraw_window(&sublist_win);
            set_mark(&unsublist_win,svar.data[SVAR_OBJECT],TRUE);
          }
        }
      }
    }
  }

  Return;
}
/********************************************************************/
/********************************************************************/
char *sub_line(int line, char *string, int stringsize, short *effects, short *color)
{

  *color=BLACK;
  *effects=NOLL;
  tempvar.line=line;
  active.tempgroup=get_entity(active.glist,tempvar.line);
  if(!active.tempgroup)
  {
    Return string;
  }
  if(!*active.tempgroup->description)
  {
    strncpy(string,active.tempgroup->groupname,stringsize-1);
    if(*active.servers[active.serv_num].d_desc)
    {
      strncat(string," (",stringsize-1);
      strncat(string,active.servers[active.serv_num].d_desc,stringsize-1);
      strncat(string,")",stringsize-1);
    }
  }
  else
  {
    strncpy(string,active.tempgroup->description,stringsize-1);
    strncat(string," (",stringsize-1);
    strncat(string,active.tempgroup->groupname,stringsize-1);
    strncat(string,")",stringsize-1);
  }

  Return string;
}
/********************************************************************/
/********************************************************************/
char *sub_next(char *string, int stringsize, short *effects, short *color)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"sub_next(...)\n");
Log(LOG_FUNCTION2,"int =%l\n",stringsize);
#endif
  tempvar.line++;

  Return sub_line(tempvar.line,string,stringsize,effects,color);
}

/********************************************************************/
/********************************************************************/
char *unsub_line(int line, char *string, int stringsize, short *effects, short *color)
{
  GROUPS *g;
#ifdef LOGGING
Log(LOG_FUNCTION,"unsub_line(int, char *, int)\n");
Log(LOG_FUNCTION2,"int[1] = %l\n",line);
Log(LOG_FUNCTION2,"int[1] = %l\n",stringsize);
#endif
  *color=BLACK;
  *effects=NOLL;
  tempvar.line=line;
  tempvar.temp1=FALSE;
  for(tempvar.temp2=0;tempvar.temp2<active.num_of_groups;tempvar.temp2++)
  {
    g=get_entity(active.glist,tempvar.temp2);
    if(!strcmp(active.ungroups[tempvar.line].groupname,g->groupname))
      tempvar.temp1=TRUE;
  }
  if(tempvar.temp1)
    strncpy(string,"S - ",stringsize-1);
  else
    strncpy(string,"    ",stringsize-1);
  strncat(string,active.ungroups[tempvar.line].groupname,stringsize-1);
  if(*active.ungroups[tempvar.line].description)
  {
    strncat(string," (",stringsize-1);
    strncat(string,active.ungroups[tempvar.line].description,stringsize-1);
    strncat(string,")",stringsize-1);
  }
  Return string;
}
/********************************************************************/
/********************************************************************/
char *unsub_next(char *string, int stringsize, short *effects, short *color)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"unsub_next(char *, int)\n");
Log(LOG_FUNCTION2,"int = %l\n",stringsize);
#endif
  tempvar.line++;

  Return unsub_line(tempvar.line,string,stringsize,effects,color);
}
