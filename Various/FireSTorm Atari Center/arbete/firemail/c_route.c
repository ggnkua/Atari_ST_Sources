#include "firemail.h"

/********************************************************************/
/********************************************************************/
void init_routewin(void)
{
  short dummy;

  rsrc_gaddr(R_TREE,LIST,&listroute_win.dialog);
  strncpy(listroute_win.w_name,"Mail Routing List",MAXWINSTRING);
  listroute_win.attr=NAME|MOVE|CLOSE;
  listroute_win.icondata=NULL;
  listroute_win.status=WINDOW_CLOSED;
  form_center(listroute_win.dialog, &dummy, &dummy, &dummy, &dummy);

  rsrc_gaddr(R_TREE,ROUTING,&route_win.dialog);
  strncpy(route_win.w_name,"Mail Routing (to different Areas)",MAXWINSTRING);
  route_win.attr=NAME|MOVE|CLOSE;
  route_win.icondata=NULL;
  route_win.status=WINDOW_CLOSED;
  form_center(route_win.dialog, &dummy, &dummy, &dummy, &dummy);
}
/********************************************************************/
/* Hantering av routings-installations-f”nstret                     */
/********************************************************************/
void check_routewin(RESULT svar)
{
  char buffer[MAXSTRING];
  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&route_win);
    open_listroutewin();
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[0])
    {
      case ROUTE_MLIST_FROM:
        button(&route_win,ROUTE_MLIST_FROM,SET_STATE,SELECTED);
        button(&route_win,ROUTE_MLIST_FTXT,CLEAR_STATE,DISABLED);
        button(&route_win,ROUTE_MLIST_STXT,SET_STATE,DISABLED);
        break;
      case ROUTE_MLIST_SUBJ:
        button(&route_win,ROUTE_MLIST_SUBJ,SET_STATE,SELECTED);
        button(&route_win,ROUTE_MLIST_STXT,CLEAR_STATE,DISABLED);
        button(&route_win,ROUTE_MLIST_FTXT,SET_STATE,DISABLED);
        break;
      case ROUTE_AREA:
        tempvar.route_area=popup(arealist,tempvar.route_area,route_win.dialog,ROUTE_AREA,buffer);
        strcpy(route_win.dialog[ROUTE_AREA].ob_spec,buffer);
        button(&route_win, ROUTE_AREA, CLEAR_STATE, SELECTED);
        break;
      case ROUTE_TYPE:
        tempvar.route_type=popup(alerts[POP_ROUTE],tempvar.route_type,route_win.dialog,ROUTE_TYPE,buffer);
        strcpy(route_win.dialog[ROUTE_TYPE].ob_spec,buffer);
        if(tempvar.route_type==TYPE_MLIST)
        {
          button(&route_win, ROUTE_NEWS, SET_FLAGS, HIDETREE);
          button(&route_win, ROUTE_KILL, SET_FLAGS, HIDETREE);
          button(&route_win, ROUTE_MLIST, CLEAR_FLAGS, HIDETREE);
        }
        else if(tempvar.route_type==TYPE_NEWS)
        {
          button(&route_win, ROUTE_NEWS, CLEAR_FLAGS, HIDETREE);
          button(&route_win, ROUTE_MLIST, SET_FLAGS, HIDETREE);
          button(&route_win, ROUTE_KILL, SET_FLAGS, HIDETREE);
        }
        else if(tempvar.route_type==TYPE_KILL)
        {
          button(&route_win, ROUTE_KILL, CLEAR_FLAGS, HIDETREE);
          button(&route_win, ROUTE_NEWS, SET_FLAGS, HIDETREE);
          button(&route_win, ROUTE_MLIST, SET_FLAGS, HIDETREE);
        }
        button(&route_win, ROUTE_TYPE, CLEAR_STATE, SELECTED);
        break;         
      case ROUTE_CANCEL:
        button(&route_win, ROUTE_CANCEL, CLEAR_STATE, SELECTED);
        close_dialog(&route_win);
        open_listroutewin();
        break;
      case ROUTE_OK:
        menu_icheck(menu_tree,MENU_CONF_ROUTE,FALSE);
        menu_ienable(menu_tree,MENU_CONF_ROUTE,TRUE);
        button(&route_win, ROUTE_OK, CLEAR_STATE, SELECTED);
        if(tempvar.route_action==ROUTE_ADD)
        {
          if(routedata2==NULL)
          {
            routedata2=Malloc(ROUTE_MAX*sizeof(AREADATA));
            tempvar.num_area2=NOLL;
            if(routedata2==NULL)
            {
              sprintf(fel.text,alerts[E_ALLOC_MEM],"check_route()");
              log(NULL);
              return;
            }
          }
          tempvar.route_pointer=routedata2;
          tempvar.route_num=tempvar.num_area2++;
          tempvar.conf_change=TRUE;
        }
        
        if((tempvar.route_num<ROUTE_MAX)&&(tempvar.route_pointer!=NULL))
        {
          memset(tempvar.route_pointer[tempvar.route_num].area,NOLL,sizeof(tempvar.route_pointer[tempvar.route_num].area));
          memset(tempvar.route_pointer[tempvar.route_num].text,NOLL,sizeof(tempvar.route_pointer[tempvar.route_num].text));
          strcpy(tempvar.route_pointer[tempvar.route_num].area,areasbbs[tempvar.route_area].area);
          if(tempvar.route_type==TYPE_MLIST)
          {
            if(route_win.dialog[ROUTE_MLIST_FROM].ob_state&SELECTED)
            {
              tempvar.route_pointer[tempvar.route_num].type=TYPEM_MFROM;
              ted2str(route_win.dialog,ROUTE_MLIST_FTXT,tempvar.route_pointer[tempvar.route_num].text);
            }
            else if(route_win.dialog[ROUTE_MLIST_SUBJ].ob_state&SELECTED)
            {
              tempvar.route_pointer[tempvar.route_num].type=TYPEM_MSUBJ;
              ted2str(route_win.dialog,ROUTE_MLIST_STXT,tempvar.route_pointer[tempvar.route_num].text);
            }
          }
          else if(tempvar.route_type==TYPE_NEWS)
          {
            tempvar.route_pointer[tempvar.route_num].type=TYPEM_NEWS;
            ted2str(route_win.dialog,ROUTE_NEWS_TEXT,tempvar.route_pointer[tempvar.route_num].text);
          }
          else if(tempvar.route_type==TYPE_KILL)
          {
            tempvar.route_pointer[tempvar.route_num].type=TYPEM_KILL;
            ted2str(route_win.dialog,ROUTE_KILL_FROM,tempvar.route_pointer[tempvar.route_num].text);
          }
        }
        close_dialog(&route_win);
        open_listroutewin();
        break;
      case ROUTE_CLEAR:
        break;
      default:;
    }
  }
} 

/********************************************************************/
/********************************************************************/
void check_listroutewin(RESULT svar)
{
  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&listroute_win);
    menu_icheck(menu_tree,MENU_CONF_ROUTE,FALSE);
    menu_ienable(menu_tree,MENU_CONF_ROUTE,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[0])
    {
      case LIST_0:
      case LIST_1:
      case LIST_2:
      case LIST_3:
      case LIST_4:
      case LIST_5:
      case LIST_6:
      case LIST_7:
      case LIST_8:
      case LIST_9:
        button(&listroute_win, svar.data[0], CLEAR_STATE, SELECTED);
        tempvar.route_action=ROUTE_EDIT;
        tempvar.route_num=tempvar.route_offset+svar.data[0]-LIST_0;
        close_dialog(&listroute_win);
        open_routewin();
        break;
      case LIST_UP:
        button(&listroute_win, LIST_UP, CLEAR_STATE, SELECTED);
        break;         
      case LIST_DOWN:
        button(&listroute_win, LIST_DOWN, CLEAR_STATE, SELECTED);
        break;         
      case LIST_SLIDE:
        button(&listroute_win, LIST_SLIDE, CLEAR_STATE, SELECTED);
        break;
      case LIST_SLIDE_BACK:
        break;
      case LIST_EXIT:
        button(&listroute_win, LIST_EXIT, CLEAR_STATE, SELECTED);
        close_dialog(&listroute_win);
        menu_icheck(menu_tree,MENU_CONF_ROUTE,FALSE);
        menu_ienable(menu_tree,MENU_CONF_ROUTE,TRUE);
        break;
      case LIST_ADD:
        button(&listroute_win, LIST_ADD, CLEAR_STATE, SELECTED);
        tempvar.route_action=ROUTE_ADD;
        close_dialog(&listroute_win);
        open_routewin();
        break;
      case LIST_DELETE:
        button(&listroute_win, LIST_DELETE, CLEAR_STATE, SELECTED);
        break;
      default:;
    }
  }
}

/********************************************************************/
/********************************************************************/
void open_routewin(void)
{
  if(tempvar.route_action==ROUTE_ADD)
  {
    strcpy(route_win.dialog[ROUTE_AREA].ob_spec,areasbbs[tempvar.route_area].area);
    strcpy(route_win.dialog[ROUTE_TYPE].ob_spec,"Mlist");
    str2ted(route_win.dialog,ROUTE_MLIST_FTXT,"");
    str2ted(route_win.dialog,ROUTE_MLIST_STXT,"");
    str2ted(route_win.dialog,ROUTE_NEWS_TEXT,"");
    button(&route_win,ROUTE_MLIST_FTXT,SET_STATE,DISABLED);
    button(&route_win,ROUTE_MLIST_FROM,CLEAR_STATE,SELECTED);
    button(&route_win,ROUTE_MLIST_STXT,SET_STATE,DISABLED);
    button(&route_win,ROUTE_MLIST_SUBJ,CLEAR_STATE,SELECTED);
    button(&route_win,ROUTE_MLIST,CLEAR_FLAGS,HIDETREE);
    button(&route_win,ROUTE_NEWS,SET_FLAGS,HIDETREE);
    tempvar.route_type=TYPE_MLIST;
  }
  else if(tempvar.route_action==ROUTE_EDIT)
  {
    if(tempvar.route_num<tempvar.num_area1)
      tempvar.route_pointer=routedata1;
    else
      tempvar.route_pointer=routedata2,tempvar.route_num-=tempvar.num_area1;
    for(tempvar.route_area=NOLL;(tempvar.route_area<tempvar.num_areas)&&(strcmp(areasbbs[tempvar.route_area].area,tempvar.route_pointer[tempvar.route_num].area));tempvar.route_area++);
    if(tempvar.route_area==tempvar.num_areas)
      tempvar.route_area=NOLL;
    strcpy(route_win.dialog[ROUTE_AREA].ob_spec,tempvar.route_pointer[tempvar.route_num].area);
    if(tempvar.route_type=TYPEM_MSUBJ)
    {
      strcpy(route_win.dialog[ROUTE_TYPE].ob_spec,"Mlist");
      str2ted(route_win.dialog,ROUTE_MLIST_STXT,tempvar.route_pointer[tempvar.route_num].text);
      str2ted(route_win.dialog,ROUTE_MLIST_FTXT,"");
      str2ted(route_win.dialog,ROUTE_NEWS_TEXT,"");
      str2ted(route_win.dialog,ROUTE_KILL_FROM,"");
      button(&route_win,ROUTE_MLIST_STXT,CLEAR_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_SUBJ,SET_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST_FTXT,SET_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_FROM,CLEAR_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST,CLEAR_FLAGS,HIDETREE);
      button(&route_win,ROUTE_NEWS,SET_FLAGS,HIDETREE);
      button(&route_win,ROUTE_KILL,SET_FLAGS,HIDETREE);
      tempvar.route_type=TYPE_MLIST;
    }
    else if(tempvar.route_type=TYPEM_MFROM)
    {
      strcpy(route_win.dialog[ROUTE_TYPE].ob_spec,"Mlist");
      str2ted(route_win.dialog,ROUTE_MLIST_FTXT,tempvar.route_pointer[tempvar.route_num].text);
      str2ted(route_win.dialog,ROUTE_MLIST_STXT,"");
      str2ted(route_win.dialog,ROUTE_NEWS_TEXT,"");
      str2ted(route_win.dialog,ROUTE_KILL_FROM,"");
      button(&route_win,ROUTE_MLIST_STXT,SET_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_SUBJ,CLEAR_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST_FTXT,CLEAR_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_FROM,SET_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST,CLEAR_FLAGS,HIDETREE);
      button(&route_win,ROUTE_NEWS,SET_FLAGS,HIDETREE);
      button(&route_win,ROUTE_KILL,SET_FLAGS,HIDETREE);
      tempvar.route_type=TYPE_MLIST;
    }
    else if(tempvar.route_type=TYPEM_NEWS)
    {
      strcpy(route_win.dialog[ROUTE_TYPE].ob_spec,"News");
      str2ted(route_win.dialog,ROUTE_NEWS_TEXT,tempvar.route_pointer[tempvar.route_num].text);
      str2ted(route_win.dialog,ROUTE_MLIST_STXT,"");
      str2ted(route_win.dialog,ROUTE_MLIST_FTXT,"");
      str2ted(route_win.dialog,ROUTE_KILL_FROM,"");
      button(&route_win,ROUTE_MLIST_FTXT,SET_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_FROM,CLEAR_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST_STXT,SET_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_SUBJ,CLEAR_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST,SET_FLAGS,HIDETREE);
      button(&route_win,ROUTE_NEWS,CLEAR_FLAGS,HIDETREE);
      button(&route_win,ROUTE_KILL,SET_FLAGS,HIDETREE);
      tempvar.route_type=TYPE_NEWS;
    }
    else if(tempvar.route_type=TYPEM_KILL)
    {
      strcpy(route_win.dialog[ROUTE_TYPE].ob_spec,"News");
      str2ted(route_win.dialog,ROUTE_KILL_FROM,tempvar.route_pointer[tempvar.route_num].text);
      str2ted(route_win.dialog,ROUTE_MLIST_STXT,"");
      str2ted(route_win.dialog,ROUTE_MLIST_FTXT,"");
      str2ted(route_win.dialog,ROUTE_NEWS_TEXT,"");
      button(&route_win,ROUTE_MLIST_FTXT,SET_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_FROM,CLEAR_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST_STXT,SET_STATE,DISABLED);
      button(&route_win,ROUTE_MLIST_SUBJ,CLEAR_STATE,SELECTED);
      button(&route_win,ROUTE_MLIST,SET_FLAGS,HIDETREE);
      button(&route_win,ROUTE_NEWS,SET_FLAGS,HIDETREE);
      button(&route_win,ROUTE_KILL,CLEAR_FLAGS,HIDETREE);
      tempvar.route_type=TYPE_KILL;
    }
  }
  open_dialog(&route_win);
}
/********************************************************************/
/********************************************************************/
void open_listroutewin(void)
{
  int counter,dummy;
  char buffer[MAXSTRING];
  dummy=LIST_0;
  if(routedata1!=NULL)
  {
    for(counter=NOLL;(counter<tempvar.num_area1)&&(dummy<=LIST_9);counter++)
    {
      sprintf(buffer,"%d %s %s",routedata1[counter].type,routedata1[counter].text,routedata1[counter].area);
      if(dummy<=LIST_9)
      {
        button(&listroute_win, dummy, SET_FLAGS, SELECTABLE);
        button(&listroute_win, dummy, CLEAR_STATE, SELECTED);
        strncpy(listroute_win.dialog[dummy++].ob_spec,buffer,76);
      }
    }
  }
  if(routedata2!=NULL)
  {
    for(counter=NOLL;(counter<tempvar.num_area2)&&(dummy<=LIST_9);counter++)
    {
      sprintf(buffer,"%d %s %s",routedata2[counter].type,routedata2[counter].text,routedata2[counter].area);
      if(dummy<=LIST_9)
      {
        button(&listroute_win, dummy, SET_FLAGS, SELECTABLE);
        button(&listroute_win, dummy, CLEAR_STATE, SELECTED);
        strncpy(listroute_win.dialog[dummy++].ob_spec,buffer,76);
      }
    }
  }
  while(dummy<=LIST_9)
  {
    button(&listroute_win, dummy, CLEAR_FLAGS, SELECTABLE);
    button(&listroute_win, dummy, CLEAR_STATE, SELECTED);
    strcpy(listroute_win.dialog[dummy++].ob_spec,"");
  }
  open_dialog(&listroute_win);
}
  
/********************************************************************/
/* Test Function for showing existing routes                        */
/********************************************************************/
void show_routes(void)
{
  int counter;
  printf("Loaded Areas (#%d)\n",tempvar.num_area1);
  if(routedata1!=NULL)
    for(counter=NOLL;counter<tempvar.num_area1;counter++)
      printf("  %d, %s, %s\n",routedata1[counter].type,routedata1[counter].text,routedata1[counter].area),getch();
  printf("Added Areas (#%d)\n",tempvar.num_area2);
  if(routedata2!=NULL)
    for(counter=NOLL;counter<tempvar.num_area2;counter++)
      printf("  %d, %s, %s\n",routedata2[counter].type,routedata2[counter].text,routedata2[counter].area),getch();
}





















/* BACKUP
      case ROUTE_OK:
        menu_icheck(menu_tree,MENU_CONF_ROUTE,FALSE);
        menu_ienable(menu_tree,MENU_CONF_ROUTE,TRUE);
        button(&route_win, ROUTE_OK, CLEAR_STATE, SELECTED);
        if(tempvar.route_action==ROUTE_ADD)
        {
          if(routedata2==NULL)
          {
            routedata2=Malloc(100*sizeof(AREADATA));
            if(routedata2==NULL)
            {
              sprintf(fel.text,alerts[E_ALLOC_MEM],"check_route()");
              log(NULL);
            }
          }
          if((tempvar.num_area2<100)&&(routedata2!=NULL))
          {
            strcpy(routedata2[tempvar.num_area2].area,areasbbs[tempvar.route_area].area);
            if(tempvar.route_type==TYPE_MLIST)
            {
              if(route_win.dialog[ROUTE_MLIST_FROM].ob_state&SELECTED)
              {
                routedata2[tempvar.num_area2].type=TYPEM_MFROM;
                ted2str(route_win.dialog,ROUTE_MLIST_FTXT,routedata2[tempvar.num_area2].text);
              }
              else if(route_win.dialog[ROUTE_MLIST_SUBJ].ob_state&SELECTED)
              {
                routedata2[tempvar.num_area2].type=TYPEM_MSUBJ;
                ted2str(route_win.dialog,ROUTE_MLIST_STXT,routedata2[tempvar.num_area2].text);
              }
            }
            else if(tempvar.route_type==TYPE_NEWS)
            {
              routedata2[tempvar.num_area2].type=TYPEM_NEWS;
              ted2str(route_win.dialog,ROUTE_NEWS_TEXT,routedata2[tempvar.num_area2].text);
            }
            else if(tempvar.route_type==TYPE_KILL)
            {
              routedata2[tempvar.num_area2].type=TYPEM_KILL;
              ted2str(route_win.dialog,ROUTE_KILL_FROM,routedata2[tempvar.num_area2].text);
            }tempvar.num_area2++;
          }
        }
        else if(tempvar.route_action==ROUTE_EDIT)
        {
        
        }
        close_dialog(&route_win);
        open_listroutewin();
        break;
*/