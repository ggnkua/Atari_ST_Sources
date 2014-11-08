#include "firecall.h"
int compare_phonedata(const void *phone1,const void *phone2,const int sort_what);
/********************************************************************/
/********************************************************************/
void init_listwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,LIST,&list_win.dialog);
  strncpy(list_win.w_name,alerts[WN_LIST],MAXWINSTRING);
  list_win.attr=NAME|MOVE|CLOSE;
  list_win.icondata=NULL;
  list_win.status=WINDOW_CLOSED;
  list_win.type=TYPE_DIALOG;
  list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_ADD];
  form_center(list_win.dialog, &dummy, &dummy, &dummy, &dummy);
  
}
/********************************************************************/
/********************************************************************/
void open_listwin()
{
  make_list();
  open_dialog(&list_win,NULL);
}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_listwin(RESULT svar)
{
  int counter=NOLL;
   
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    menu_icheck(menu_tree,MENU_LIST_OWIND,FALSE); 
    menu_ienable(menu_tree,MENU_LIST_OWIND,TRUE); 
    close_dialog(&list_win);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    if(svar.data[SVAR_OBJECT]>=LIST_MIN && svar.data[SVAR_OBJECT]<=LIST_MAX)
    {
      if(svar.data[SVAR_MOUSE_CLICKS]==1)
      {
        if(list_win.dialog[svar.data[SVAR_OBJECT]].ob_state&SELECTED)
          list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_EDIT];
        else
          list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_ADD];
        button(&list_win, LIST_ADD_EDIT, UPDATE, NOLL,TRUE);
      }
      else
      {
        tempvar.phonedata=get_entity(phonelist,tempvar.offset_list+svar.data[SVAR_OBJECT]-LIST_MIN);
        open_popupwin(PC_LISTVIEW,NULL);
      }
    }
    else
    {
      switch(svar.data[SVAR_OBJECT])
      {
        case LIST_ADD_EDIT:
          tempvar.phonedata=NULL;
          for(counter=LIST_MIN;counter<=LIST_MAX;counter++)
            if(list_win.dialog[counter].ob_state&SELECTED)
              tempvar.phonedata=get_entity(phonelist,tempvar.offset_list+counter-LIST_MIN);
          if(tempvar.phonedata)
            open_popupwin(PC_LISTEDIT,NULL);
          else
            open_popupwin(PC_NEW,NULL);
          button(&list_win,LIST_ADD_EDIT,CLEAR_STATE,SELECTED,TRUE);
          break;
        case LIST_OK:
          button(&list_win, LIST_OK, CLEAR_STATE, SELECTED,TRUE);
          menu_icheck(menu_tree,MENU_LIST_OWIND,FALSE); 
          menu_ienable(menu_tree,MENU_LIST_OWIND,TRUE); 
          close_dialog(&list_win);
          break;
        case LIST_SLIDE_UP:
          tempvar.offset_list--;
          make_list();
          button(&list_win, LIST_SLIDE_UP, CLEAR_STATE, SELECTED,TRUE);
          list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_ADD];
          button(&list_win, LIST_ADD_EDIT, UPDATE, NOLL,TRUE);
          break;
        case LIST_SLIDE_DOWN:
          if(tempvar.offset_list<(tempvar.num_phones))
          {
            tempvar.offset_list++;
          }
          make_list();
          button(&list_win, LIST_SLIDE_DOWN, CLEAR_STATE, SELECTED,TRUE);
          list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_ADD];
          button(&list_win, LIST_ADD_EDIT, UPDATE, NOLL,TRUE);
          break;
        case LIST_SLIDE_DRAG:
          tempvar.offset_list=list_win.dialog[LIST_SLIDE_DRAG].ob_y*(tempvar.num_phones)/list_win.dialog[LIST_SLIDE_BACK].ob_height;
          make_list();
          list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_ADD];
          button(&list_win, LIST_ADD_EDIT, UPDATE, NOLL,TRUE);
          break;
        case LIST_EXPORT:
          open_exportwin(TRUE);
          menu_icheck(menu_tree,MENU_LIST_OWIND,FALSE); 
          menu_ienable(menu_tree,MENU_LIST_OWIND,TRUE); 
          close_dialog(&list_win);
          button(&list_win, LIST_EXPORT, CLEAR_STATE, SELECTED,TRUE);
          break;
        case LIST_DELETE:
          if(alertbox(1,alerts[Q_DELETE_ONE])==1)
          {
            for(counter=LIST_MIN;counter<=LIST_MAX;counter++)
              if(list_win.dialog[counter].ob_state&SELECTED)
              {
                del_entity(&phonelist,tempvar.offset_list+counter-LIST_MIN);
                tempvar.num_phones--;
                if((tempvar.num_phones<tempvar.offset_list+LIST_MAX-LIST_MIN)&&(tempvar.offset_list>0))
                  tempvar.offset_list--;
              }
            make_list();
          }
          list_win.dialog[LIST_ADD_EDIT].ob_spec=alerts[T_ADD];
          button(&list_win, LIST_ADD_EDIT, UPDATE, NOLL,TRUE);
          button(&list_win, LIST_DELETE, CLEAR_STATE, SELECTED,TRUE);
          break;
        case LIST_SORT:
          counter=alertbox(1,alerts[Q_SORT]);
          if (counter==1)
            sort_list(phonelist,compare_phonedata,SORT_ORDER_DOWN,SORT_NAME);
          else if(counter==2)
            sort_list(phonelist,compare_phonedata,SORT_ORDER_DOWN,SORT_NUMBER);
          make_list();
          button(&list_win, LIST_SORT, CLEAR_STATE, SELECTED,TRUE);
          break;
        default:
          break;
      }
    }
  }
}
/********************************************************************/
/********************************************************************/
void make_list()
{
  PHONE_DATA *temp;
  int counter=tempvar.offset_list;
  char text[ROWSIZE];
  
  while(counter-tempvar.offset_list<LIST_MAX-LIST_MIN+1)
  {
    if (counter>=tempvar.num_phones)
      temp=NULL;
    else
      temp=get_entity(phonelist,counter);
    if(temp)
    {
      sprintf(text,"%20s  %s",temp->number,temp->name);
      str2ted(list_win.dialog,LIST_MIN+counter-tempvar.offset_list,text);
      button(&list_win,LIST_MIN+counter-tempvar.offset_list,CLEAR_STATE,DISABLED,FALSE);
      button(&list_win,LIST_MIN+counter-tempvar.offset_list,CLEAR_STATE,SELECTED,FALSE);
    }
    else
    {
      str2ted(list_win.dialog,LIST_MIN+counter-tempvar.offset_list,"");
      button(&list_win,LIST_MIN+counter-tempvar.offset_list,SET_STATE,DISABLED,FALSE);
      button(&list_win,LIST_MIN+counter-tempvar.offset_list,CLEAR_STATE,SELECTED,FALSE);
    }
    counter++;
  }
  if(tempvar.num_phones>LIST_MAX-LIST_MIN+1)
  {
    list_win.dialog[LIST_SLIDE_DRAG].ob_height=list_win.dialog[LIST_SLIDE_BACK].ob_height*(LIST_MAX-LIST_MIN+1)/(tempvar.num_phones);
    list_win.dialog[LIST_SLIDE_DRAG].ob_y=list_win.dialog[LIST_SLIDE_BACK].ob_height*(tempvar.offset_list)/(tempvar.num_phones);
    button(&list_win,LIST_SLIDE_DRAG,CLEAR_STATE,DISABLED,FALSE);
    button(&list_win,LIST_SLIDE_BACK,CLEAR_STATE,DISABLED,TRUE);
  }
  if(tempvar.offset_list!=NOLL)
    button(&list_win,LIST_SLIDE_UP,CLEAR_STATE,DISABLED,TRUE);
  else
    button(&list_win,LIST_SLIDE_UP,SET_STATE,DISABLED,TRUE);
  if((tempvar.num_phones-tempvar.offset_list>LIST_MAX-LIST_MIN+1)||(tempvar.offset_list+LIST_MAX-LIST_MIN+1<tempvar.num_phones))
    button(&list_win,LIST_SLIDE_DOWN,CLEAR_STATE,DISABLED,TRUE);
  else
    button(&list_win,LIST_SLIDE_DOWN,SET_STATE,DISABLED,TRUE);
  
  button(&list_win,LIST_BACKGROUND,UPDATE,NOLL,TRUE);
}

/********************************************************************/
/********************************************************************/
int compare_phonedata(const void *phone1,const void *phone2,const int sort_what)
{
  switch(sort_what)
  {
    case SORT_NAME:
      return strcmp(((PHONE_DATA *)phone1)->name,((PHONE_DATA *)phone2)->name);
      break;
    case SORT_NUMBER:
      return strcmp(((PHONE_DATA *)phone1)->number,((PHONE_DATA *)phone2)->number);
      break;
    default:
      return 0;
      break;
  }
}