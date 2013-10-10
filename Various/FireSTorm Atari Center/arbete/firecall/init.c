#include "firecall.h"
#include <mintbind.h>
#include <dos.h>
#include <cookie.h>
#include <sersofst.h>
#include <basepage.h>
/********************************************************************/
/* Initierings-funktionen, h„rifr†n laddas alla configar,           */
/* Resurser in ,mm                                                  */
/********************************************************************/
int init(int argc, char *argv[]) /***********************************/
{
  
  if(!init_default(argc,argv)) return(FALSE);

  if(!init_appl()) return(FALSE);
  if(!init_rsc())  return(FALSE);

  if(!init_rsvf()) return(FALSE);
  if(!init_graph()) return(FALSE);
  if(!init_cfg(load_datafile(CONFIGFILE,(char **)&config,sizeof(CONFIG)))) return(FALSE);
  if(!init_mem()) return(FALSE);
  load_log();
  
  load_list();
    
  if(load_datafile(NUMFILE,(char **)&tempvar.num_list,NOLL)==NOLL)
   tempvar.num_list=NULL;

  if(!tempvar.registered)
  {
    open_dialog(&info_win,NULL);
    config->disabled=TRUE;
  }
  else
    init_port();
    
  if(!tempvar.accessory)
  {
    if(!open_menu(menu_tree, 1))
    {
      alertbox(1,MENU_ERROR);
      return(FALSE);
    } 
  }
  return(TRUE);
}

/********************************************************************/
/* S„tter upp en default initiation, med data och s† vidare         */
/********************************************************************/
int init_default(int argc,char *argv[]) /********************************************/
{
  memset(tempvar,NOLL,sizeof(VARIABLES));
  strcpy(system_dir,"A:");
  system_dir[0]=Dgetdrv()+'A';
  Dgetpath(system_dir+2,0);
  strcat(system_dir,"\\FIRECONF\\");
  strcpy(tempvar.message,"");
  tempvar.new_line=FALSE;
  tempvar.port_counter=FAIL;
  tempvar.portfile=FAIL;
  tempvar.accessory=FALSE;
  tempvar.popup_counter=NOLL;
  strcpy(tempvar.lastpath,system_dir);
  strcat(tempvar.lastpath,"*.LOG");
  strcpy(tempvar.lastfile,LOGFILE);
  strcpy(tempvar.message,"");

#ifdef LOGGING
  memset(log,NOLL,sizeof(LOGG));
  log.all=TRUE;
  log.on=TRUE;
#endif

  return TRUE;
}

/********************************************************************/
/* Initiates the Application                                        */
/********************************************************************/
int init_appl(void) /************************************************/
{
  ap_id=appl_init();
  if(ap_id==FAIL)
  {
    alertbox(1,APPL_ERROR);
    return(FALSE);
  }
  return(TRUE);
}

/********************************************************************/
/* Initiates the resourcefile                                       */
/********************************************************************/
int init_rsc()
{
  short dummy;
  char  filnamn[MAXSTRING];

  strcpy(filnamn,system_dir);
  if(screeny>15)
    strcat(filnamn,RESURS);
  else
    strcat(filnamn,RESURS2);
  dummy=rsrc_load(filnamn);
  if(!dummy)
  {
    alertbox(1,RESOURCE_ERROR);
    return(FALSE);
  }
  
  for(dummy=0; dummy<MAX_ALERTS; dummy++)
    rsrc_gaddr(R_STRING,dummy,&alerts[dummy]);	
  rsrc_gaddr(R_TREE,ICON,&icons);

  init_infowin();
  init_popupwin();
  init_setupwin();
  init_listwin();
  init_logwin();
  init_exportwin();

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
      alertbox(1,alerts[E_ALLOC_MEM]);
      return(FALSE);
    }
    strcpy(config->id,VERSION_CFG);
    strcpy(config->name,"FireSTorm (Name)");
    strcpy(config->adr1,"Streetadress");
    strcpy(config->adr2,"Postalcode, City");
    strcpy(config->adr3,"Country");
    strcpy(config->key,"Key");
    strcpy(config->messwait,alerts[T_MODEM_WAIT]);
    strcpy(config->portinit,alerts[T_MODEM_INIT]);
    strcpy(config->dialcommand,alerts[T_MODEM_DIAL]);
    strcpy(config->linecommand,alerts[T_MODEM_LINE]);
    strcpy(config->port,alerts[T_NO_PORT]);
    config->log_number=LOG_SIZE;
    config->port_speed=NOLL;
    config->disabled=TRUE;
    config->popup_time=10;
    tempvar.registered=FALSE;
  }
  if(!strcmp(config->id,"FC 0.75"))
  {
  // Konverterar fr†n gammal till ny
  }
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
   

  if(tempvar.portfile!=FAIL)
  {
    Fclose(tempvar.portfile),tempvar.portfile=FAIL;
  }
  menu_bar(menu_tree,0);
    
  if(tempvar.portfile!=FAIL)
    Fclose(tempvar.portfile),tempvar.portfile=FAIL;

  rsrc_free();
    
  free_list(&phonelist);

  if(ap_id!=NOLL)
    appl_exit();

}

/******************************************************************/
/* Initieringen av RSVF systemet, dvs h„mta port-namn, osv        */
/******************************************************************/
int init_rsvf(void)
{
  RSVF_OBJECT *object;
  int temp=NOLL;
  if(getcookie(RSVF,(long *)&object))
  {
    while(object!=NULL)
    {
      tempvar.port[temp]=object;
      object++,temp++;
      if(!(object->func&128))
      {
        object=(RSVF_OBJECT *)object->name;
      }
    }
    tempvar.port[temp]=NULL;
    return(TRUE);
  }
  else
  {
    alertbox(1,alerts[E_HSMODEM]);
    return(FALSE);
  }
}

/******************************************************************/
/* Allocates the needed memory                                    */
/******************************************************************/
int init_mem()
{

  logtext=Malloc(config->log_number*LENGTH_LOG);
  if(logtext==NULL)
  {
    alertbox(1,alerts[E_ALLOC_MEM]);
    return(FALSE);
  }
}

/******************************************************************/
/******************************************************************/
int init_acc(void)
{
  
  if(_pbase->p_parent==NULL)
  {
#ifdef LOGGING
Log("I am an Desc-Accessory");
#endif
  }
  return FALSE;
}