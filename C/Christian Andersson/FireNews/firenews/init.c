#include "firenews.h"
#include <mintbind.h>
#include <dos.h>
/********************************************************************/
/* Initierings-funktionen, h„rifr†n laddas alla configar,           */
/* Resurser in ,mm                                                  */
/********************************************************************/
int init(int argc, char *argv[]) /***********************************/
{
  if(!init_default(argc,argv)) {Return FALSE;}
#ifdef LOGGING
Log(LOG_FUNCTION,"init(...) (first log-able row in init(...) function\n");
#endif
  if(!init_appl())                 {Return FALSE;}
  if(!init_graph())                {Return FALSE;}
  if(!init_rsc())                  {Return FALSE;}
  load_config();
  if(!init_font())                 {Return FALSE;}
  load_active();  
  if(config.mailtype==MAILTYPE_ANTMAIL)
    load_antmail();
  else if(config.mailtype==MAILTYPE_NEWSIE)
    load_newsie();
 else if(config.mailtype==MAILTYPE_INFITRA)
   load_infitra();
 else if(config.mailtype==MAILTYPE_MYMAIL)
   load_mymail();
   
#ifdef LOGGING
Log(LOG_INIT,"Opening the Menu\n");
#endif
  if(!open_menu(menu_tree, 1))
  {
    strcpy(fel.text,MENU_ERROR);
    alertbox(1,fel.text);
    Return FALSE;
  } 
  if(!tempvar.registered)
    open_nonmodal(&info_win,NULL);
  else
  {
    open_arealist_win(GROUP_NEWASK);
    if(config.open_group)
      open_arealist_win(GROUP_SUB);
    if(config.open_msg)
      open_msglist_win(active.group_num);
  }
  Return TRUE;
}

/********************************************************************/
/* S„tter upp en default initiation, med data och s† vidare         */
/********************************************************************/
int init_default(int argc, char *argv[]) /********************************************/
{
  memset(&tempvar,NOLL,sizeof(VARIABLES));
  memset(&active,NOLL,sizeof(ACTIVE));
  memset(&font,NOLL,sizeof(FONT));
  tempvar.tempcounter=NOLL;
  while(tempvar.tempcounter<argc)
  {
    tempvar.temp1=NOLL;
    while(argv[tempvar.tempcounter][tempvar.temp1]!=NOLL)
    {
      argv[tempvar.tempcounter][tempvar.temp1]=toupper(argv[tempvar.tempcounter][tempvar.temp1]);
      tempvar.temp1++;
    }
#ifdef LOGGING
    memset(&log,NOLL,sizeof(LOGG));
    if(!strcmp(argv[tempvar.tempcounter],COMMAND_LOG))
    {
      log.on=TRUE;
      Log(LOG_GENERAL,"*****************************************\n");
      Log(LOG_GENERAL,"* FireSTorm News Reader has now Started *\n");
      Log(LOG_GENERAL,"*****************************************\n");
      Log(LOG_GENERAL,"FireNews V%s\n",VERSION);
      if(tempvar.tempcounter+1<argc)
      {
        if(argv[tempvar.tempcounter+1][0]!='-')
        {
          strncpy(log.what,argv[++tempvar.tempcounter],LOG_MAXTYPES);
          Log(LOG_GENERAL,"Logging %s types\n",log.what);
        }
        else
        { 
          log.all=TRUE;
          Log(LOG_GENERAL,"Logging: Everything\n");
        }
      }
      else
      {
        log.all=TRUE;
        Log(LOG_GENERAL,"Logging: Everything\n");
      }
    }
#endif
    tempvar.tempcounter++;
  }
#ifdef LOGGING
//  log.on=TRUE;
  if(log.on)
  {
    tempvar.tempcounter=NOLL;
    while(tempvar.tempcounter<argc)
    {
      Log(LOG_INIT,"argv[%d]=%s\n",tempvar.tempcounter,argv[tempvar.tempcounter]);
      tempvar.tempcounter++;
    }
  }
#endif
  Return TRUE;
}

/********************************************************************/
/* Initiates the Application                                        */
/********************************************************************/
int init_appl(void) /************************************************/
{
  char args[MAXSTRING];
  char progname[9];  
  int flag;
  char *temp_s;
  char *addr;
  
#ifdef LOGGING
Log(LOG_FUNCTION,"init_appl(void)\n");
Log(LOG_INIT,"Application init\n");
#endif

  ap_id=appl_init();
  if(ap_id==FAIL)
  {
    strcpy(fel.text,APPL_ERROR);
#ifdef LOGGING
Log(LOG_ERROR,"Application Init error!\n");
#endif
    alertbox(1,fel.text);
    Return FALSE;
  }
  Pdomain(1);
#ifdef LOGGING
Log(LOG_INIT,"appl-ID=%l\n",ap_id);
#endif

  flag = shel_read(system_dir, args);
  if  (!flag)
{
#ifdef LOGGING
Log(LOG_INIT,"shell_read, did not work :( %d\n",flag);
#endif
    return (FALSE);
}
#ifdef LOGGING
Log(LOG_INIT,"path returned by shell_read: %s\n",system_dir);
#endif
  temp_s = (char *)strrchr(system_dir, '\\');
  if  (temp_s == NULL)
{
#ifdef LOGGING
Log(LOG_INIT,"there was no end '\\' in the pathname\n",flag);
#endif
    return (FALSE);
}
  *temp_s++ = 0;
  strncpy(progname, temp_s, 8);
  strcat(system_dir, "\\fireconf\\");
  progname[8] = 0;
  temp_s = (char *)strchr(progname, '.');
  if(temp_s)
    *temp_s = 0;
  while (strlen(progname) < 8)
    strcat(progname, " ");

  if((!strcmp(progname,"LC5     "))||(system_dir[0]==0))
  {
#ifdef LOGGING
Log(LOG_INIT,"could not use path provided from shell-read, resorting to a different method\n",flag);
#endif
    strcpy(system_dir,"A:");
    system_dir[0]=Dgetdrv()+'A';
    Dgetpath(system_dir+2,0);
    strcat(system_dir,"\\fireconf\\");
  }
  
#ifdef LOGGING
Log(LOG_INIT,"Getting the name of the AV-Server\n",flag);
#endif
  flag=shel_envrn(&addr,"AVSERVER=");
  if(!addr)
{
#ifdef LOGGING
Log(LOG_INIT,"NO AVSERVER enviroment string found\n");
#endif
    if(appl_find("AVSERVER")>=0)
    {
#ifdef LOGGING
Log(LOG_INIT,"AVSERVER Application found\n");
#endif
      strcpy(avserver,"AVSERVER");
    }
    if(appl_find("THING   ")>=0)
    {
#ifdef LOGGING
Log(LOG_INIT,"THING Application found\n");
#endif
      strcpy(avserver,"THING   ");
    }
    if(appl_find("GEMINI  ")>=0)
    {
#ifdef LOGGING
Log(LOG_INIT,"GEMINI Application found\n");
#endif
      strcpy(avserver,"GEMINI  ");
    }

    if(avserver[0]==0)
    {
#ifdef LOGGING
Log(LOG_INIT,"NO AVSERVER application found\n");
#endif
      strcpy(avserver,"");
    }
  }
  else
  {
#ifdef LOGGING
Log(LOG_INIT,"AVSERVER: %d (%s)\n",flag,addr);
#endif
    strcpy(avserver,addr);
    while (strlen(avserver) < 8)
      strcat(avserver, " ");
  }  
  flag=appl_find(avserver);
  if (flag==ap_id)
    strcpy(avserver,"");
  Return TRUE;
}

/********************************************************************/
/* Initiates the resourcefile                                       */
/********************************************************************/
int init_rsc(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_rsc(void)\n");
Log(LOG_INIT,"Init Resource\n");
#endif
//  rsrc_free();

  strcpy(tempvar.lastpath,system_dir);
  if(screeny>15)
  {
#ifdef LOGGING
Log(LOG_INIT,"Resource: High\n");
#endif
    strcat(tempvar.lastpath,RESURS);
  }
  else
  {
#ifdef LOGGING
Log(LOG_INIT,"Resource: Low\n");
#endif
//    strcat(tempvar.lastpath,RESURS);
    strcat(tempvar.lastpath,RESURS2);
  }
  

#ifdef LOGGING
Log(LOG_INIT,"Loading Resource: %s\n",tempvar.lastpath);
#endif
  tempvar.tempcounter=load_resource(tempvar.lastpath);
  if(!tempvar.tempcounter)
  {
    strcpy(fel.text,RESOURCE_ERROR);
    alertbox(1,fel.text);;
#ifdef LOGGING
Log(LOG_ERROR,"Could Not load the resource: %s\n",tempvar.lastpath);
#endif
    Return FALSE;
  }
  
  for(tempvar.tempcounter=0; tempvar.tempcounter<MAX_ALERTS; tempvar.tempcounter++)
    rsrc_gaddr(R_STRING,tempvar.tempcounter,&alerts[tempvar.tempcounter]);	
  icons=NULL;
  rsrc_gaddr(R_TREE,ICON,&icons);

#ifdef LOGGING
Log(LOG_INIT,"Init windows\n");
#endif
  init_info_win();
  init_arealist_win();
  init_font_win();
  init_path_win();
  init_server_win();
  init_read_win();  
  init_msglist_win();
  init_user_win();
  init_group_win();
  init_flags_win();
  init_switch_win();
#ifdef LOGGING
Log(LOG_INIT,"Init Menu\n");
#endif
  rsrc_gaddr(R_TREE,MENU,&menu_tree);
  menu_ienable(menu_tree,MENU_REPLY_G,FALSE); 
  menu_ienable(menu_tree,MENU_REPLY_E,FALSE); 
  menu_ienable(menu_tree,MENU_WRITE_NEW,FALSE); 
  menu_ienable(menu_tree,MENU_OPEN_MESS,FALSE);
  menu_ienable(menu_tree,MENU_CHANGE_MESS,FALSE); 
  Return TRUE;
}

/********************************************************************/
/* Init Default config                                              */
/********************************************************************/
void init_config()
{
  memset(&config,NOLL,sizeof(CONFIG));
  
  strcpy(config.name,"FireSTorm");
  strcpy(config.adr1,"Streetadress");
  strcpy(config.adr2,"Postalcode, City");
  strcpy(config.adr3,"Country");
  strcpy(config.key,"Key");
  strcpy(config.stringserver,"STRNGSRV");
  strcpy(config.replystring1,alerts[T_REPLY_MESSAGE1]);
  strcpy(config.replystring2,alerts[T_REPLY_MESSAGE2]);
  config.subsw_xy[X]=screenx;
  config.subsw_xy[Y]=screeny;
  config.subsw_xy[W]=screenw;
  config.subsw_xy[H]=screenh;
  memcpy(config.readw_xy,config.subsw_xy,sizeof(config.subsw_xy));
  memcpy(config.usubw_xy,config.subsw_xy,sizeof(config.subsw_xy));
  memcpy(config.msglw_xy,config.subsw_xy,sizeof(config.subsw_xy));
  memcpy(config.servw_xy,config.subsw_xy,sizeof(config.subsw_xy));
  config.readfontsize=0;
  config.msglfontsize=0;
  config.subfontsize=0;
  config.unsubfontsize=0;
  config.servfontsize=0;
  font_name(1,config.readfontname);
  font_name(1,config.msglfontname);
  font_name(1,config.subfontname);
  font_name(1,config.unsubfontname);
  font_name(1,config.servfontname);
  config.save_window=TRUE;
  config.save_exit=TRUE;
  config.open_group=FALSE;
  config.open_msg=FALSE;
  config.message_alloc=MESSAGE_ALLOC;
  config.group_alloc=GROUP_ALLOC;
  config.mailtype=MAILTYPE_ANTMAIL;
}
/********************************************************************/
/********************************************************************/
int init_font(void)
{
 short atrib[10];
#ifdef LOGGING
Log(LOG_FUNCTION,"init_font(void)\n");
Log(LOG_INIT,"Init Font-system\n");
#endif

  font.readid=font_id(config.readfontname);                         /* find the ID for the font in the read window                */
  if(config.readfontsize==NOLL)                                     /* If the Size of the font = ZERO                             */
  {
    vst_font(graf_id,font.readid);                                   /* Use the font                                               */
    vqt_attributes(graf_id,atrib);                                   /* Ask for the default size                                   */
    config.readfontsize=atrib[7];                                   /* And use that from now on                                   */
  }
  font.msglid=font_id(config.msglfontname);                         /* find the ID for the font in the message list window        */
  if(config.msglfontsize==NOLL)                                     /* ...                                                        */
  {
    vst_font(graf_id,font.msglid);
    vqt_attributes(graf_id,atrib);
    config.msglfontsize=atrib[7];
  }
  font.subid=font_id(config.subfontname);                           /* find the ID for the font in the subscribed groups window   */
  if(config.subfontsize==NOLL)                                      /* ...                                                        */
  {
    vst_font(graf_id,font.subid);
    vqt_attributes(graf_id,atrib);
    config.subfontsize=atrib[7];
  }
  font.unsubid=font_id(config.unsubfontname);                       /* find the ID for the font in the unsubscribed groups-window */
  if(config.unsubfontsize==NOLL)                                    /* ...                                                        */
  {
    vst_font(graf_id,font.unsubid);
    vqt_attributes(graf_id,atrib);
    config.unsubfontsize=atrib[7];
  }
  font.servid=font_id(config.servfontname);                         /* find the ID for the font in the server list window         */
  if(config.servfontsize==NOLL)                                     /* ...                                                        */
  {
    vst_font(graf_id,font.servid);
    vqt_attributes(graf_id,atrib);
    config.servfontsize=atrib[7];
  }
 
 vst_font(graf_id,NOLL);
 Return TRUE;
}
/********************************************************************/
/* Avinitierar alla initieringar                                    */
/********************************************************************/
void deinit(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"deinit()\n");
#endif
  
  close_readwin();
  close_msglistwin();
  close_sublistwin();
  close_unsublistwin();
  close_dialog(NULL);
  
  deinit_graph();

  menu_bar(menu_tree,0);
  
  if(icons)
    rsrc_free();
    
  if(ap_id!=NOLL)
    appl_exit();

  if(active.servers!=NULL)
  {
    for(tempvar.tempcounter=0;tempvar.tempcounter<active.num_of_servers;tempvar.tempcounter++)
    {
      if(active.servers[tempvar.tempcounter].del_newgroup)
      {
        strcpy(tempvar.lastpath,config.newsdir);
        strcat(tempvar.lastpath,active.servers[tempvar.tempcounter].file);
        strcat(tempvar.lastpath,GROUPNEWEXT);
        Fdelete(tempvar.lastpath);
      }
    }
    free(active.servers),active.servers=NOLL;
  }
  free(&active.glist);
  free_list(&active.mlist);
  if(active.msg_text!=NOLL)
    free(active.msg_text),active.msg_text=NOLL;
  if(active.ungroups!=NOLL)
    free(active.ungroups),active.ungroups=NOLL;
}

