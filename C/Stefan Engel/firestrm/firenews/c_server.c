#include "firenews.h"
char *srv_line(int line, char *string, int stringsize, short *effects, short *color);
char *srv_next(char *string, int stringsize, short *effects, short *color);
/********************************************************************/
/********************************************************************/
void init_server_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_server_win()\n");
Log(LOG_INIT,"Server Window Init\n");
#endif
  rsrc_gaddr(R_TREE,SERVER,&server_win.dialog);
  strncpy(server_win.w_name,alerts[WN_SERVER],MAXWINSTRING);
  server_win.attr=NAME|MOVE|CLOSE|SIZE|UPARROW|DNARROW|VSLIDE|FULLER|SMALLER;
  server_win.icondata=&icons[ICON_FIRESTORM];
  server_win.i_x=100;
  server_win.i_y=100;
  server_win.status=WINDOW_CLOSED;
  server_win.type=TYPE_LIST;
  server_win.text=&server_text;
  server_win.text->createline=&srv_line;
  server_win.text->createnext=&srv_next;
  server_win.text->sc_left=TRUE;
  server_win.text->sc_right=TRUE;
  server_win.text->sc_up=TRUE;
  server_win.text->sc_down=TRUE;

//  rsrc_gaddr(R_TREE,MESSAGE_TOP,&msglist_win.text->dialog);
  server_win.text->dialog=NOLL;
    
  Return;
}
/********************************************************************/
/*                                                                  */
/********************************************************************/
void open_server_win(void)
{
/*

  if(server_win.status!=WINDOW_CLOSED)
  {
    open_dialog(&server_win,config.servw_xy);
    Return;
  }
  else
  {
    server_win.text->select=active.serv_num;
    server_win.text->font_id=font.msglid;
    server_win.text->num_of_cols=80;
    server_win.text->num_of_rows=active.num_of_servers
    server_win.text->offset_y=0;
    server_win.text->offset_x=0;
  }
  open_dialog(&server_win,config.servw_xy);
*/
}

/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_server_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_server_win()\n");
#endif

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&server_win);
  }
  Return;
}

/********************************************************************/
/* Skapa en text-Rad till Listan                                    */
/********************************************************************/
char *srv_line(int line, char *string, int stringsize, short *effects, short *color)
{
#ifdef LOGGING
  Log(LOG_FUNCTION,"srv_line(...)\n");
#endif

  *color=BLACK;
  *effects=NOLL;
  tempvar.line=line;

  strcpy(tempvar.temprow1,active.servers[line]);

  sprintf(string,"%s",tempvar.temprow1);
  Return string;
}

/********************************************************************/
/* Skapa en Text-Rad till Listan, baserad p† tidigare v„rde         */
/********************************************************************/
char *srv_next(char *string,int stringsize, short *effects, short *color)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"msg_next(...)\n");
#endif
  tempvar.line++;
  Return srv_line(tempvar.line,string,stringsize,effects,color);
}
