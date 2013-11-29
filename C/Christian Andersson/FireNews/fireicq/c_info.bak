#include "fireicq.h"
/********************************************************************/
/********************************************************************/
void init_info_win(void)
{
	short dummy = 0;
	char string[ MAXSTRING ];
	
	#ifdef LOGGING
	Log( LOG_FUNCTION , "init_info_win(void)\n" );
	Log( LOG_INIT , "Initiating Info and Register Windows\n" );
	#endif

	rsrc_gaddr( R_TREE , INFORMATION , &info_win.dialog );
	strncpy( info_win.w_name , alerts[ WN_INFORMATION ] , MAXWINSTRING );
	info_win.attr = NAME | MOVE | CLOSE | SMALLER;
	info_win.icondata = NULL; // &icons[ ICON_FIRESTORM ];
	info_win.i_x = -1;
	info_win.i_y = -1;
	info_win.status = WINDOW_CLOSED;
	info_win.type = TYPE_DIALOG;
	form_center( info_win.dialog , &dummy , &dummy , &dummy , &dummy );
	sprintf( string , alerts[ T_VERSION ] , VERSION );
	str2ted( info_win.dialog , INFO_VERSION , string );
	#ifdef LOGGING 
		( ( OBJECT * )info_win.dialog )[ INFO_LOGGING ].ob_flags &= ~HIDETREE;
	#else
		(( OBJECT * )info_win.dialog )[ INFO_LOGGING ].ob_flags |= HIDETREE;
	#endif    

	rsrc_gaddr( R_TREE , REGISTER , &register_win.dialog );
	strncpy( register_win.w_name , alerts[ WN_REGISTER ] , MAXWINSTRING );
	register_win.attr = NAME | MOVE | CLOSE;
	register_win.icondata = NULL; // &icons[ ICON_FIRESTORM ];
	register_win.status = WINDOW_CLOSED;
	register_win.type = TYPE_DIALOG;
	form_center( register_win.dialog , &dummy , &dummy , &dummy , &dummy );
	str2ted( register_win.dialog , REG_NAME , "Unregistered" );
	str2ted( register_win.dialog , REG_ADR1 , "" );
	str2ted( register_win.dialog , REG_ADR2 , "" );
	str2ted( register_win.dialog , REG_ADR3 , "" );
	str2ted( register_win.dialog , REG_KEY , "" );

	Return;
}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
int check_info_win(const RESULT svar)
{
	#ifdef LOGGING
	Log(LOG_FUNCTION,"check_info_win(...)\n");
	#endif

	if( ( svar.type == WINDOW_CLICKED ) && ( svar.data[ SVAR_WINDOW_MESSAGE ] == WM_CLOSED ) )
	{
		close_dialog(&info_win);
		#ifdef USE_MENU
			menu_icheck(menu_tree,MENU_INFO,FALSE);
			menu_ienable(menu_tree,MENU_INFO,TRUE);
		#endif
	}
	else if(svar.type==DIALOG_CLICKED)
	{
		switch(svar.data[SVAR_OBJECT])
		{
			case INFO_OK:
				button(&info_win, INFO_OK, CLEAR_STATE, SELECTED,TRUE);
				close_dialog(&info_win);
				#ifdef USE_MENU
					menu_icheck(menu_tree,MENU_INFO,FALSE);
					menu_ienable(menu_tree,MENU_INFO,TRUE);
				#endif
				break;
			case INFO_REGISTER:
				button(&info_win, INFO_REGISTER, CLEAR_STATE, SELECTED,TRUE);
				close_dialog(&info_win);
				open_nonmodal(&register_win,NULL);
				break;
			default:;
		}
	}

	Return FALSE;
}

/********************************************************************/
/* Handling of the Registration window                              */
/********************************************************************/
void check_register_win(const RESULT svar)
{
	short xy[ 4 ];
	
	#ifdef LOGGING
	Log(LOG_FUNCTION,"check_register_win(...)\n");
	#endif

	if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
	{
		close_dialog(&register_win);
		#ifdef USE_MENU
			menu_icheck(menu_tree,MENU_INFO,FALSE); 
			menu_ienable(menu_tree,MENU_INFO,TRUE); 
		#endif
	}
 	else if(svar.type==DIALOG_CLICKED)
	{
		switch(svar.data[SVAR_OBJECT])
		{
			case REG_EXIT:
				button(&register_win, REG_EXIT, CLEAR_STATE, SELECTED,TRUE);
				close_dialog(&register_win);
				#ifdef USE_MENU
					menu_icheck(menu_tree,MENU_INFO,FALSE); 
        			menu_ienable(menu_tree,MENU_INFO,TRUE); 
        		#endif
				break;
			case REG_REGISTER:
				if(check_key(FALSE))
				{
					tempvar.registered=TRUE;
					button(&register_win, REG_REGISTER, CLEAR_STATE, SELECTED,TRUE);
					close_dialog(&register_win);
					#ifdef USE_MENU
						menu_icheck(menu_tree,MENU_INFO,FALSE); 
						menu_ienable(menu_tree,MENU_INFO,TRUE); 
					#endif
					tempvar.config_changed=TRUE;
				}
				else
				{
					tempvar.registered=FALSE;
					button(&register_win, REG_REGISTER, CLEAR_STATE, SELECTED,TRUE);
				}
				break;
			case REG_LOAD_KEY:
				load_reg_file();
				button(&register_win, REG_LOAD_KEY, CLEAR_STATE, SELECTED,TRUE);
				wind_get(register_win.ident,WF_WORKXYWH,&xy[0],&xy[1],&xy[2],&xy[3]);
				update_dialog(&register_win,xy);
				break;
			default:;
		}
	}

	Return;
}

/********************************************************************/
/* Loading of the register.txt file                                 */
/********************************************************************/
int load_reg_file(void)
{
	FILE	*file;
	short	dummy = 0;
	char	string[ MAXSTRING ];
	
	#ifdef LOGGING
	Log( LOG_FUNCTION , "load_reg_file(void)\n" );
	#endif

  strcpy( tempvar.lastpath , system_dir );
  strcat( tempvar.lastpath , "*.DAT" );
  strcpy( tempvar.lastfile , "REGISTER.DAT" );
  fsel_exinput( tempvar.lastpath , tempvar.lastfile , &dummy , alerts[ FS_REGISTER ] );
  if( !dummy )
  {
    Return FALSE;
  }
  strcpy( strrchr( tempvar.lastpath , '\\' ) + 1 , tempvar.lastfile );

  file = fopen( tempvar.lastpath , "rb" );
  if( file == NULL )
  {
    sprintf(tempvar.errorstring,alerts[E_OPEN_FILE],tempvar.lastpath,"load_reg_file()");
    alertbox(1,tempvar.errorstring);
    Return FALSE;
  }

  fgets( string , MAXSTRING , file );
  while( ( string[ strlen( string ) -1 ] == '\n' ) || ( string[ strlen( string ) -1 ] == '\r' ) ) string[ strlen( string ) -1 ] = NOLL;
  str2ted( register_win.dialog , REG_NAME , string );
  fgets(string,MAXSTRING,file);
  while((string[strlen(string)-1]=='\n')||(string[strlen(string)-1]=='\r')) string[strlen(string)-1]=NOLL;
  str2ted(register_win.dialog,REG_ADR1,string);
  fgets(string,MAXSTRING,file);
  while((string[strlen(string)-1]=='\n')||(string[strlen(string)-1]=='\r')) string[strlen(string)-1]=NOLL;
  str2ted(register_win.dialog,REG_ADR2,string);
  fgets(string,MAXSTRING,file);
  while((string[strlen(string)-1]=='\n')||(string[strlen(string)-1]=='\r')) string[strlen(string)-1]=NOLL;
  str2ted(register_win.dialog,REG_ADR3,string);
  fgets(string,MAXSTRING,file);
  while((string[strlen(string)-1]=='\n')||(string[strlen(string)-1]=='\r')) string[strlen(string)-1]=NOLL;
  str2ted(register_win.dialog,REG_KEY,string);

  fclose(file);
  Return TRUE;
}

/********************************************************************/
/* Check the key against the important information                  */
/********************************************************************/
int check_key(const int first)
{
  char *data[4],*testkey;
  char validkeys[]=VALIDKEY;
  char key[27];
  int  sum=0, oldsum=0;
  int  count[4]={0,0,0,0},
       count1,count2,
       maxcount=strlen(validkeys);
#ifdef LOGGING
Log(LOG_FUNCTION,"check_key(...)\n");
#endif

  if(first)
  {
     str2ted(register_win.dialog,REG_NAME,config.name);
     str2ted(register_win.dialog,REG_KEY,config.key);
     str2ted(register_win.dialog,REG_ADR1,config.adr1);
     str2ted(register_win.dialog,REG_ADR2,config.adr2);
     str2ted(register_win.dialog,REG_ADR3,config.adr3);
  }
  else
  {
    ted2str(register_win.dialog,REG_NAME,config.name);
    ted2str(register_win.dialog,REG_KEY,config.key);
    ted2str(register_win.dialog,REG_ADR1,config.adr1);
    ted2str(register_win.dialog,REG_ADR2,config.adr2);
    ted2str(register_win.dialog,REG_ADR3,config.adr3);
  }
  data[0]=(char *)((TEDINFO *)((OBJECT*)register_win.dialog)[REG_NAME].ob_spec)->te_ptext;
  data[1]=(char *)((TEDINFO *)((OBJECT*)register_win.dialog)[REG_ADR1].ob_spec)->te_ptext;
  data[2]=(char *)((TEDINFO *)((OBJECT*)register_win.dialog)[REG_ADR2].ob_spec)->te_ptext;
  data[3]=(char *)((TEDINFO *)((OBJECT*)register_win.dialog)[REG_ADR3].ob_spec)->te_ptext;

  testkey=(char *)((TEDINFO *)((OBJECT*)register_win.dialog)[REG_KEY].ob_spec)->te_ptext;

/* Kod f”r att fixa fram key-koden */

  for(count1=0;count1<26;count1++)
  {
    for(count2=0,sum=0; count2<4; count2++)
    {
      if(data[count2][count[count2]]==NOLL)
        count[count2]=NOLL;
      sum+=data[count2][count[count2]];
      count[count2]++;
    }
    sum+=oldsum;
    sum=sum%maxcount;
    key[count1]=validkeys[sum];
    oldsum=sum;
  }
  key[count1]=NOLL;

/* slut p† key-fixar koden */

  if(!strcmp(key,testkey))
  { 
    ((OBJECT*)info_win.dialog)[INFO_OK].ob_width=((OBJECT*)info_win.dialog)[INFO_REGISTER].ob_x+((OBJECT*)info_win.dialog)[INFO_REGISTER].ob_width-((OBJECT*)info_win.dialog)[INFO_OK].ob_x;
    ((OBJECT*)info_win.dialog)[INFO_REGISTER].ob_flags|=HIDETREE;
    ((OBJECT*)info_win.dialog)[INFO_REGISTERED].ob_flags&=~HIDETREE;
    str2ted(info_win.dialog,INFO_USERNAME,((TEDINFO *)((OBJECT*)register_win.dialog)[REG_NAME].ob_spec)->te_ptext);
    Return TRUE;
  }
  else
  {
    str2ted(info_win.dialog,INFO_USERNAME,alerts[T_UNREGISTERED]);
    ((OBJECT*)info_win.dialog)[INFO_REGISTERED].ob_flags|=HIDETREE;
    Return FALSE;
  }    
}