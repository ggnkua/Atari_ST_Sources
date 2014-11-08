#include "firetext.h"
/********************************************************************/
/* Initierings-funktionen, h„rifr†n laddas alla configar,           */
/* Resurser in ,mm                                                  */
/********************************************************************/
int init() /***********************************/
{
  init_default();
  if(!init_appl()) return(FALSE);
  if(!init_graf()) return(FALSE);
  if(!init_rsc())  return(FALSE);
  if(!init_cfg(load_datafile(CONFIGFILE,(char **)&config,sizeof(CONFIG)))) return(FALSE);
  
  if(!load_areasbbs((char *)&areasbbs))
  {
    tempvar.areasbbs=FALSE;
  }
  if(!tempvar.registered)
    open_dialog(&info_win);
  if(tempvar.arg_menu)
  {
    if(!open_menu(menu_tree, 1))
    {
      strcpy(fel.text,MENU_ERROR);
      log(NULL);
      return(FALSE);
    } 
  }

  return(TRUE);
}

/********************************************************************/
/* S„tter upp en default initiation, med data och s† vidare         */
/********************************************************************/
void init_default(void) /********************************************/
{
  strcpy(system_dir,"A:");
  system_dir[0]=Dgetdrv()+'A';
  Dgetpath(system_dir+2,0);
  strcat(system_dir,"\\FIRECONF\\");
  tempvar.arg_menu=TRUE;
  tempvar.sel_area=NOLL;
  tempvar.date_com=NOLL;
}

/********************************************************************/
/* Initiates the Application                                        */
/********************************************************************/
int init_appl(void) /************************************************/
{
  ap_id=appl_init();
  if(ap_id==FAIL)
  {
    strcpy(fel.text,APPL_ERROR);
    log(NULL);
    return(FALSE);
  }
  return(TRUE);
}

/********************************************************************/
/* Initiates the Grafic libraries                                   */
/********************************************************************/
int init_graf(void) /************************************************/
{
  short dummy;
 
  init_graph();
  return(TRUE);
}

/********************************************************************/
/* Initiates the resourcefile                                       */
/********************************************************************/
int init_rsc()
{
  short dummy;
  char  filnamn[MAXSTRING];

  rsrc_free(); 
  strcpy(filnamn,system_dir);
  if(screeny>15)
    strcat(filnamn,RESURS);
  else
    strcat(filnamn,RESURS2);
  dummy=rsrc_load(filnamn);
  if(!dummy)
  {
    strcpy(fel.text,RESOURCE_ERROR);
    log(NULL);
    return(FALSE);
  }
  
  for(dummy=0; dummy<MAX_ALERTS; dummy++)
    rsrc_gaddr(R_STRING,dummy,&alerts[dummy]);	
  
  init_pathwin();
  init_infowin();
  init_writewin();
  init_convertwin();
  init_autodatewin();
  rsrc_gaddr(R_TREE,MENU,&menu_tree);
  return(TRUE);
}

/********************************************************************/
/* Initierar configurationen p† ett ordentligt s„tt                 */
/********************************************************************/
int init_cfg(long int size)
{
  if(size<NOLL)
  {
    config=(CONFIG *)Malloc(sizeof(CONFIG));
    if(config==NULL)
    {
      sprintf(fel.text,alerts[E_ALLOC_MEM],"init_cfg()");
      log(NULL);
      return(FALSE);
    }
    strcpy(config->name,"FireSTorm");
    strcpy(config->adr1,"Streetadress");
    strcpy(config->adr2,"Postalcode, City");
    strcpy(config->adr3,"Country");
    strcpy(config->key,"Key");
    strcpy(config->areasbbsfile,"G:\\MAILER\\AREAS.BBS");
    strcpy(config->lednewfile,"G:\\MAILER\\LED.NEW");
    strcpy(config->lastpath,system_dir);
    strcat(config->lastpath,"*.TXT");
    strcpy(config->lastfile,"");
    tempvar.registered=FALSE;
  }
  str2ted(path_win.dialog,PATH_AREASBBS,config->areasbbsfile);
  str2ted(path_win.dialog,PATH_LEDNEW,config->lednewfile);
  tempvar.registered=check_key(TRUE);
  if(size<NOLL)
    save_datafile(TRUE,CONFIGFILE,(char *)config,sizeof(CONFIG));
  
  return(TRUE);
}
/********************************************************************/
/* Avinitierar alla initieringar                                    */
/********************************************************************/
void deinit(void)
{
  if(graf_id!=NOLL)
   v_clsvwk(graf_id);
   
  if(tempvar.arg_menu)
    menu_bar(menu_tree,0);
    
  rsrc_free();
    
  if(ap_id!=NOLL)
    appl_exit();

  if(areasbbs!=NULL)
    Mfree(areasbbs);
  if(arealist!=NULL)
    Mfree(arealist);
    
}

