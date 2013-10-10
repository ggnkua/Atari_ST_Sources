#include "firenews.h"
/********************************************************************/
/********************************************************************/
void init_path_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_path_win(void)\n");
Log(LOG_INIT,"Path Window Init\n");
#endif
  rsrc_gaddr(R_TREE,PATH,&path_win.dialog);
  strncpy(path_win.w_name,alerts[WN_PATH],MAXWINSTRING);
  path_win.attr=NAME|MOVE|CLOSE;
  path_win.icondata=NULL; /* &icons[ICON_FIRESTORM]; */
  path_win.i_x=100;
  path_win.i_y=100;
  path_win.status=WINDOW_CLOSED;
  path_win.type=TYPE_DIALOG;
  form_center(path_win.dialog, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter);
    
  Return;
}
/********************************************************************/
/* ™ppnar Path f”nstret                                             */
/********************************************************************/
void open_path_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"open_path_win(void)\n");
#endif

  strcpy(tempconf.nntpd,config.nntpd);
  strcpy(tempconf.editor,config.editor);
  strcpy(tempconf.maildata,config.maildata);
  strcpy(tempconf.newsdir,config.newsdir);
  strcpy(tempconf.signature,config.signature);
  tempconf.mailtype=config.mailtype;
  
  str2ted(path_win.dialog,PATH_NEWSDIR,config.newsdir);
  
  if(strrchr(config.editor,'\\')!=NOLL)
    str2ted(path_win.dialog,PATH_EDITOR,(char *)strrchr(config.editor,'\\')+1);
  else
    str2ted(path_win.dialog,PATH_EDITOR,"");

  if(strrchr(config.nntpd,'\\')!=NOLL)
    str2ted(path_win.dialog,PATH_NNTP,(char *)strrchr(config.nntpd,'\\')+1);
  else
    str2ted(path_win.dialog,PATH_NNTP,"");

  if(strrchr(config.signature,'\\')!=NOLL)
    str2ted(path_win.dialog,PATH_SIGNATUR,(char *)strrchr(config.signature,'\\')+1);
  else
    str2ted(path_win.dialog,PATH_SIGNATUR,"");

   if(strrchr(config.maildata,'\\')!=NOLL)
    str2ted(path_win.dialog,PATH_MAILDATA,(char *)strrchr(config.maildata,'\\')+1);
  else
    str2ted(path_win.dialog,PATH_MAILDATA,"");

  str2ted(path_win.dialog,PATH_STRINGSERV,config.stringserver);

  if(config.mailtype==MAILTYPE_ANTMAIL)
    str2ted(path_win.dialog,PATH_CHOOSE_MAIL,MAILTYPE_T_ANTMAIL);
  else if(config.mailtype==MAILTYPE_NEWSIE)
    str2ted(path_win.dialog,PATH_CHOOSE_MAIL,MAILTYPE_T_NEWSIE);
  else if(config.mailtype==MAILTYPE_INFITRA)
    str2ted(path_win.dialog,PATH_CHOOSE_MAIL,MAILTYPE_T_INFITRA);
  else if(config.mailtype==MAILTYPE_MYMAIL)
    str2ted(path_win.dialog,PATH_CHOOSE_MAIL,MAILTYPE_T_MYMAIL);
    
  open_nonmodal(&path_win,NULL);

  Return;
}

/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_path_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_path_win(...)\n");
#endif

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&path_win);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[SVAR_OBJECT])
    {
      case PATH_CHOOSE_MAIL:
        sprintf(tempvar.tempstring,"Mailclient|%s|%s|%s|-%s",MAILTYPE_T_ANTMAIL,MAILTYPE_T_NEWSIE,MAILTYPE_T_INFITRA,MAILTYPE_T_MYMAIL);
        tempconf.mailtype=popup(tempvar.tempstring,tempconf.mailtype,path_win.dialog,PATH_CHOOSE_MAIL,path_win.dialog[PATH_CHOOSE_MAIL].ob_spec);
        button(&path_win, PATH_CHOOSE_MAIL, CLEAR_STATE, SELECTED,TRUE);
        break;
      case PATH_NEWSDIR:
        strcpy(tempvar.lastpath,tempconf.newsdir);
        strcpy(tempvar.lastfile,"*.*");
        fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_NEWSDIR]);
        if(tempvar.tempcounter)
        {
          strcpy(tempconf.newsdir,tempvar.lastpath);
          ((char *)strrchr(tempconf.newsdir,'\\'))[1]='\0';
          str2ted(path_win.dialog,PATH_NEWSDIR,tempconf.newsdir);
          button(&path_win, PATH_NEWSDIR,UPDATE,NOLL,TRUE);
        }
        break;
      case PATH_EDITOR:
        if(strrchr(tempconf.editor,'\\')!=NOLL)
        {
          strcpy(tempvar.lastpath,tempconf.editor);
          ((char *)strrchr(tempvar.lastpath,'\\'))[1]='\0';
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,strrchr(tempconf.editor,'\\')+1);
        }
        else
        {
          strcpy(tempvar.lastpath,system_dir);
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,"");
        }
        fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_EDITOR]);
        if(tempvar.tempcounter)
        {
          strcpy(tempconf.editor,tempvar.lastpath);
          ((char *)strrchr(tempconf.editor,'\\'))[1]='\0';
          strcat(tempconf.editor,tempvar.lastfile);
          str2ted(path_win.dialog,PATH_EDITOR,tempvar.lastfile);
          button(&path_win, PATH_EDITOR,UPDATE,NOLL,TRUE);
        }
        break;
      case PATH_NNTP:
        if(strrchr(tempconf.nntpd,'\\')!=NOLL)
        {
          strcpy(tempvar.lastpath,tempconf.nntpd);
          ((char *)strrchr(tempvar.lastpath,'\\'))[1]='\0';
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,strrchr(tempconf.nntpd,'\\')+1);
        }
        else
        {
          strcpy(tempvar.lastpath,system_dir);
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,"");
        }
        fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_NNTP]);
        if(tempvar.tempcounter)
        {
          strcpy(tempconf.nntpd,tempvar.lastpath);
          ((char *)strrchr(tempconf.nntpd,'\\'))[1]='\0';
          strcat(tempconf.nntpd,tempvar.lastfile);
          str2ted(path_win.dialog,PATH_NNTP,tempvar.lastfile);
          button(&path_win, PATH_NNTP,UPDATE,NOLL,TRUE);
        }
        break;
      case PATH_MAILDATA:
        if(strrchr(tempconf.maildata,'\\')!=NOLL)
        {
          strcpy(tempvar.lastpath,tempconf.maildata);
          ((char *)strrchr(tempvar.lastpath,'\\'))[1]='\0';
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,strrchr(tempconf.maildata,'\\')+1);
        }
        else
        {
          strcpy(tempvar.lastpath,system_dir);
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,"");
        }
        if(tempconf.mailtype==MAILTYPE_ANTMAIL)
          fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_ANTMAIL]);
        else if(tempconf.mailtype==MAILTYPE_NEWSIE)
          fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_NEWSIE]);
        else if(tempconf.mailtype==MAILTYPE_INFITRA)
          fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_INFITRA]);
        else if(tempconf.mailtype==MAILTYPE_MYMAIL)
          fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_MYMAIL]);
        if(tempvar.tempcounter)
        {
          strcpy(tempconf.maildata,tempvar.lastpath);
          ((char *)strrchr(tempconf.maildata,'\\'))[1]='\0';
          strcat(tempconf.maildata,tempvar.lastfile);
          str2ted(path_win.dialog,PATH_MAILDATA,tempvar.lastfile);
          button(&path_win, PATH_MAILDATA,UPDATE,NOLL,TRUE);
        }
        break;
      case PATH_SIGNATUR:
        if(strrchr(tempconf.signature,'\\')!=NOLL)
        {
          strcpy(tempvar.lastpath,tempconf.signature);
          ((char *)strrchr(tempvar.lastpath,'\\'))[1]='\0';
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,strrchr(tempconf.signature,'\\')+1);
        }
        else
        {
          strcpy(tempvar.lastpath,system_dir);
          strcat(tempvar.lastpath,"*.*");
          strcpy(tempvar.lastfile,"");
        }
        fsel_exinput(tempvar.lastpath,tempvar.lastfile,(short *)&tempvar.tempcounter,(char *)alerts[FS_SIGNATURE]);
        if(tempvar.tempcounter)
        {
          strcpy(tempconf.signature,tempvar.lastpath);
          ((char *)strrchr(tempconf.signature,'\\'))[1]='\0';
          strcat(tempconf.signature,tempvar.lastfile);
          str2ted(path_win.dialog,PATH_SIGNATUR,tempvar.lastfile);
          button(&path_win,PATH_SIGNATUR,UPDATE,NOLL,TRUE);
        }
        break;
      case PATH_OK:
        strcpy(config.nntpd,tempconf.nntpd);
        strcpy(config.editor,tempconf.editor);
        ted2str(path_win.dialog,PATH_STRINGSERV,config.stringserver);
        
        if(strcmp(config.maildata, tempconf.maildata)||(config.mailtype!=tempconf.mailtype))
        {
          strcpy(config.maildata,tempconf.maildata);
          if(tempconf.mailtype==MAILTYPE_ANTMAIL)
            load_antmail();
          else if(tempconf.mailtype==MAILTYPE_NEWSIE)
            load_newsie();
          else if(tempconf.mailtype==MAILTYPE_INFITRA)
            load_infitra();
          else if(tempconf.mailtype==MAILTYPE_MYMAIL)
            load_mymail();
        }
        else
          strcpy(config.maildata,tempconf.maildata);
        config.mailtype=tempconf.mailtype;
        if(strcmp(config.newsdir,tempconf.newsdir))
        {
          if(msglist_win.status!=WINDOW_CLOSED)
            close_msglistwin();
          if(read_win.status!=WINDOW_CLOSED)
            close_readwin();
          if(sublist_win.status!=WINDOW_CLOSED)
            close_sublistwin();
          if(unsublist_win.status!=WINDOW_CLOSED)
            close_unsublistwin();
          close_dialog(&server_win);
          if(active.ungroups)
            free(active.ungroups),active .ungroups=NULL;
          free_list(&active.mlist);
          menu_ienable(menu_tree,MENU_REPLY_E,FALSE); 
          menu_ienable(menu_tree,MENU_REPLY_G,FALSE);
          menu_ienable(menu_tree,MENU_WRITE_NEW,FALSE); 
          menu_ienable(menu_tree,MENU_CHANGE_MESS,FALSE); 
          menu_ienable(menu_tree,MENU_SAVE_MESS,FALSE);
          menu_ienable(menu_tree,MENU_DEL_FLAGS,FALSE);
          menu_ienable(menu_tree,MENU_SET_FLAGS,FALSE);
          strcpy(config.newsdir,tempconf.newsdir);
          load_active();
        }  
        else
          strcpy(config.newsdir,tempconf.newsdir);
        strcpy(config.signature,tempconf.signature);
        button(&path_win, PATH_OK, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&path_win);
        break;
      case PATH_CANCEL:
        button(&path_win, PATH_CANCEL, CLEAR_STATE, SELECTED,FALSE);
        close_dialog(&path_win);
        break;
      default:;
    }
 
  Return;
}