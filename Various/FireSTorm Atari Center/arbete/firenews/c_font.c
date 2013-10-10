#include "firenews.h"
/********************************************************************/
/********************************************************************/
void init_font_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_font_win(void)\n");
Log(LOG_INIT,"Font Window\n");
#endif
  rsrc_gaddr(R_TREE,FONT_SELECT,&font_win.dialog);
  strncpy(font_win.w_name,alerts[WN_FONT_SELECT],MAXWINSTRING);
  font_win.attr=NAME|MOVE|CLOSE;
  font_win.icondata=&icons[ICON_FIRESTORM];
  font_win.i_x=100;
  font_win.i_y=100;
  font_win.status=WINDOW_CLOSED;
  font_win.type=TYPE_DIALOG;
  form_center(font_win.dialog, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter);

  Return;    
}
/********************************************************************/
/* ”ppnandet av font-v„ljar-f”nstret                                */
/********************************************************************/
void open_font_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"open_font_win(void)\n");
#endif
  strcpy(tempconf.readfontname,config.readfontname);
  strcpy(tempconf.msglfontname,config.msglfontname);
  strcpy(tempconf.subfontname,config.subfontname);
  strcpy(tempconf.unsubfontname,config.unsubfontname);
  tempconf.readfontsize=config.readfontsize;
  tempconf.msglfontsize=config.msglfontsize;
  tempconf.subfontsize=config.subfontsize;
  tempconf.unsubfontsize=config.unsubfontsize;
  str2ted(font_win.dialog,FONT_READ_NAME,config.readfontname);
  str2ted(font_win.dialog,FONT_MSGL_NAME,config.msglfontname);
  str2ted(font_win.dialog,FONT_SUB_NAME,config.subfontname);
//  str2ted(font_win.dialog,FONT_READ_NAME,config.readfontname);
  open_dialog(&font_win,NULL);

  Return;
}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_font_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_font_win(...)\n");
#endif
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&font_win);
    menu_icheck(menu_tree,MENU_SETUP_FONT,FALSE);
    menu_ienable(menu_tree,MENU_SETUP_FONT,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[SVAR_OBJECT])
    {
      case FONT_READ_NAME:
        font.readid=font_popup(font.readid,font_win.dialog,FONT_READ_NAME,tempconf.readfontname,NULL);
        str2ted(font_win.dialog,FONT_READ_NAME,tempconf.readfontname);
        set_text_font(&read_win,font.readid,tempconf.readfontsize,TRUE);
        break;
      case FONT_MSGL_NAME:
        font.msglid=font_popup(font.msglid,font_win.dialog,FONT_MSGL_NAME,tempconf.msglfontname,NULL);
        str2ted(font_win.dialog,FONT_MSGL_NAME,tempconf.msglfontname);
        set_text_font(&msglist_win,font.msglid,tempconf.msglfontsize,TRUE);
        break;
      case FONT_SUB_NAME:
        font.subid=font_popup(font.subid,font_win.dialog,FONT_SUB_NAME,tempconf.subfontname,NULL);
        str2ted(font_win.dialog,FONT_SUB_NAME,tempconf.subfontname);
        set_text_font(&sublist_win,font.subid,tempconf.subfontsize,TRUE);
        break;
      case FONT_MSGL_SIZE:
        tempconf.msglfontsize=fontsize_popup(font.msglid,tempconf.msglfontsize,font_win.dialog,FONT_MSGL_SIZE,NULL);
        set_text_font(&msglist_win,-1,tempconf.msglfontsize,TRUE);
        break;
      case FONT_READ_SIZE:
        tempconf.readfontsize=fontsize_popup(font.readid,tempconf.readfontsize,font_win.dialog,FONT_READ_SIZE,NULL);
        set_text_font(&read_win,-1,tempconf.readfontsize,TRUE);
        break;
      case FONT_SUB_SIZE:
        tempconf.subfontsize=fontsize_popup(font.subid,tempconf.subfontsize,font_win.dialog,FONT_SUB_SIZE,NULL);
        set_text_font(&sublist_win,-1,tempconf.subfontsize,TRUE);
        break;
      case FONT_OK:
        if(font.readid!=font_id(config.readfontname))
        {
          strcpy(config.readfontname,tempconf.readfontname);
          tempvar.conf_change=TRUE;
        }
        if(font.msglid!=font_id(config.msglfontname))
        {
          strcpy(config.msglfontname,tempconf.msglfontname);
          tempvar.conf_change=TRUE;
        }
        if(font.subid!=font_id(config.subfontname))
        {
          strcpy(config.subfontname,tempconf.subfontname);
          tempvar.conf_change=TRUE;
        }
        button(&font_win, FONT_OK, CLEAR_STATE, SELECTED,TRUE);
        config.readfontsize=tempconf.readfontsize;
        config.msglfontsize=tempconf.readfontsize;
        config.subfontsize=tempconf.readfontsize;
        close_dialog(&font_win);
        menu_icheck(menu_tree,MENU_SETUP_FONT,FALSE);
        menu_ienable(menu_tree,MENU_SETUP_FONT,TRUE);
        break;
      case FONT_CANCEL:
        if(font.readid!=font_id(config.readfontname))
        {
          font.readid=font_id(config.readfontname);
          set_text_font(&read_win,font.readid,config.readfontsize,TRUE);
        }
        if(font.msglid!=font_id(config.msglfontname))
        {
          font.msglid=font_id(config.msglfontname);
          set_text_font(&msglist_win,font.msglid,config.msglfontsize,TRUE);
        }
        if(font.subid!=font_id(config.subfontname))
        {
          font.subid=font_id(config.subfontname);
          set_text_font(&sublist_win,font.subid,config.subfontsize,TRUE);
        }
        button(&font_win, FONT_CANCEL, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&font_win);
        break;
      default:;
    }

  Return;
}