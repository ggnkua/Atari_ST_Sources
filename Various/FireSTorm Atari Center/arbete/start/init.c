#include "firemail.h"
/********************************************************************/
/* Initierings-funktionen, h„rifr†n laddas alla configar,           */
/* Resurser in ,mm                                                  */
/********************************************************************/
int init(int argc, char *argv[]) /***********************************/
{
  int size;
  init_default();
  if(!init_appl()) return(FALSE);
  if(!init_graf()) return(FALSE);
  if(!init_rsc())  return(FALSE);
  if(!init_cfg(load_datafile(CONFIGFILE,(char **)&config,sizeof(CONFIG)))) return(FALSE);

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
  tempvar.num_areas=tempvar.num_area1=tempvar.num_area2=NOLL;
  tempvar.num_user=NOLL;
  tempvar.areasbbs=TRUE;
  tempvar.route_num=NOLL;
  tempvar.route_area=NOLL;
  tempvar.route_type=NOLL;
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
 
  wind_get(DESK,WF_FULLXYWH,&screenx,&screeny,&screenw,&screenh);
  graf_mouse(ARROW,NULL);
  graf_id=graf_handle(&dummy, &dummy, &dummy, &dummy);
//  for(dummy=0;dummy<=10;dummy++)
//    work_in[dummy]=1;
//  work_in[10]=2;
//  v_opnvwk(work_in, &graf_id, work_out);

//  if(work_out[13]<16)
//  {
//  }
//  else
//  {
//  }
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
  
  rsrc_gaddr(R_TREE,MAILCONV,&mailconv_win.dialog);
  strncpy(mailconv_win.w_name,"",MAXWINSTRING);
  mailconv_win.attr=NAME|MOVE|CLOSE;
  mailconv_win.icondata=NULL;
  mailconv_win.status=WINDOW_CLOSED;
  form_center(mailconv_win.dialog, &dummy, &dummy, &dummy, &dummy);


  init_pathwin();
  init_userwin();
  init_infowin();
  init_routewin();
    
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
    }
    strcpy(config->name,"FireSTorm");
    strcpy(config->adr1,"Streetadress");
    strcpy(config->adr2,"Postalcode, City");
    strcpy(config->adr3,"Country");
    strcpy(config->key,"Key");
    strcpy(config->i_source,"G:\\DOWNLOAD\\DI3CHR.000");
    strcpy(config->i_destination,"G:\\UPLOAD\\DI3CHR");
    strcpy(config->areasbbsfile,"G:\\MAILER\\AREAS.BBS");
    strcpy(config->lednewfile,"G:\\MAILER\\LED.NEW");
    strcpy(config->adress,"2:203/611.5");
  }
  str2ted(path_win.dialog,PATH_AREASBBS,config->areasbbsfile);
  str2ted(path_win.dialog,PATH_LEDNEW,config->lednewfile);
  str2ted(path_win.dialog,PATH_INMAIL,config->i_source);
  str2ted(path_win.dialog,PATH_OUTMAIL,config->i_destination);
  button(&path_win,PATH_UUDECODE,SET_STATE,DISABLED);
  button(&path_win,PATH_DE_COMMAND,SET_STATE,DISABLED);
  button(&path_win,PATH_EN_COMMAND,SET_STATE,DISABLED);
  button(&path_win,PATH_INBOUND,SET_STATE,DISABLED);
  button(&path_win,PATH_OUTBOUND,SET_STATE,DISABLED);
  check_key(TRUE);
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

  if(routedata1!=NULL)
    Mfree(routedata1);
  if(routedata2!=NULL)
    Mfree(routedata2);
  if(userdata!=NULL)
    Mfree(userdata);
  if(areasbbs!=NULL)
    Mfree(areasbbs);
  if(arealist!=NULL)
    Mfree(arealist);
    
}

