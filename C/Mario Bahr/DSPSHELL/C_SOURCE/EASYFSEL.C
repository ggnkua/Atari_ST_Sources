/******************************************************************
 * Routine zum leichten und AES-VersionsabhÑngigen Aufruf der GEM *
 * Fileselectorbox inklusive Routinen zum Umgang mit Dateien      *
 ******************************************************************/
#include <aes.h>
#include <vdi.h>
#include "powergem.h"
#include <ext.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include <portab.h>

#ifndef _BYTE_
typedef unsigned char byte;
#endif

/* Funktionsprototypen */
boolean easy_fsel(char *pfad,char *dateiname,char *text);
void build_filname(char *dest,char *pfad,char *dateiname);
void extract_filename(char *pfad,char *dateiname,char *source);
char *swap_extension(char *dateiname,char *ext);
boolean check_extension(char *datei_name,char *ext);
boolean exist_file(const char *dateiname);
char *get_akt_path(char *path);
void set_new_path(char *path);
boolean get_cookie(char *cookiename,long *cookie_value);

/****************************************************************
 * Zeigt eine FSELBOX je nach AES-Version an und Åbernimmt Aus- * 
 * wertung														*
 * Input: pfad: Pfad der aufzurufenden Datei					*
 *        dateiname: Dateiname								    *
 *        text: Infotext fÅr fselextinput()						*
 * Output:TRUE oder FALSE										*  
 ****************************************************************/
boolean easy_fsel(char *pfad,char *dateiname,char *text)
{
int button,result;
long c_wert=0; 
extern GEMPARBLK _GemParBlk;
/* je nach AES_Version FSELBOX  aufrufen */
if(_GemParBlk.global[0]<0x0014 && get_cookie("FSEL",&c_wert)==FALSE)
	{
	result=fsel_input(pfad,dateiname,&button);
	}
else
	result=fsel_exinput(pfad,dateiname,&button,text);
blank( 0,0,0,0,0); /* REDRAW */
/* Wenn Fehler aufgetreten oder Abbruch gewÑhlt: */
if(result==0 || button==0)
	return FALSE;
else 
	return TRUE;
}
/****************************************************************
 * Bastelt Pfad und Dateiname zusammen 							*
 * Input: dest: Zeiger auf Zielstring							*
 *        pfad: Pfadname										*
 *        dateiname: Dateiname									*
 ****************************************************************/
void build_filname(char *dest,char *pfad,char *dateiname)
{
char *xyz;
strcpy(dest,pfad);
xyz=strrchr(dest,(int)'\\');
if(xyz)	
	strcpy(++xyz,dateiname);
}
/***************************************************************
 * Extrahiert Pfad und Dateiname aus String					   *
 * Input: pfad: Zeiger fÅr Zielpfad							   *
 * 		  dateiname: Zeiger fÅr Zieldateiname				   *
 *        source:  Zeiger auf Pfaddateistring				   *		
 ***************************************************************/
void extract_filename(char *pfad,char *dateiname,char *source)
{
char *xyz;
strcpy(pfad,source);
xyz=strrchr(pfad,(int)'\\');
if(xyz)
	strcpy(dateiname,xyz+1);

strcpy(pfad,source);
*xyz=0x0;
}
/***************************************************************
 * Tauscht aktuelles Extension aus							   *
 * Input: dateiname Dateiname mit altem Extension              *
 *        ext 		neues Extension (ohne PUNKT !!!			   *		
 ***************************************************************/
char *swap_extension(char *dateiname,char *ext)
{
char *xyz;
xyz=strrchr(dateiname,(int)'.');
if(xyz) 
	{
	if(ext[0] != 0x0) 
		strcpy(++xyz,ext);
	else
		strcpy(xyz,ext);
	}
else		/* Keine Endung */
	{
	if(ext[0] != 0x0) 
		{
		strcat(dateiname,"." );
		strcat(dateiname,ext);
		}
	}
return(dateiname);
}
/***************************************************************
 * Vergleicht Extension  									   *
 * Input: datei_name mit seine Extension					   *
 * 		  vergleichendes Extension							   *			
 * Output:TRUE oder FALSE									   * 
 ***************************************************************/
boolean check_extension(char *datei_name,char *ext)
{
char *xyz;
xyz=strrchr(datei_name,(int)'.');
if(xyz) 
	{
	if(!strnicmp( ++xyz,ext,3))
		return TRUE;
	}
else		/* Keine Endung */
	{
	if(ext[0] == 0x0) 
		return TRUE;
	}
return FALSE;
}
/****************************************************************
 * PrÅft ob die Datei schon existiert 							*
 * Input: dateiname: Dateiname									*
 ****************************************************************/
boolean exist_file(const char *dateiname)
{
if(Fsfirst(dateiname,FA_READONLY|FA_HIDDEN|FA_ARCHIVE|FA_SYSTEM)==0)
	return TRUE;
else
	return FALSE;
}	
/****************************************************************
 * Gibt aktuelles Laufwerk und dessen Pfad zurÅck 			    *
 * Input: path: Zeiger auf String 								*
 * Output: Zeiger auf aktuelle Laufwerk und Directory			*
 ****************************************************************/
char *get_akt_path(char *path)
{
strcpy(path," :");
path[0]='A'+ getdisk();	/* Laufwerk  */
getcurdir(0,path+2);	/* Directory */	 
strcpy(path+strlen(path),"\\*.*");
return(path);
}
/****************************************************************
 * Setzt neues Laufwerk und dessen Pfad			 			    *
 * Input: path: Zeiger auf Pfad 								*
 ****************************************************************/
void set_new_path(char *path)
{
char lw;

if(path[1]== ':')
	{
	lw=path[0]-'A';
	setdisk((int)lw);
	chdir(path+2);
	}
else
	{
	lw=getdisk();
	setdisk((int)lw);
	chdir(path+2);
	}
}
/****************************************************************
 * Sucht nach einem Cookie, und liefert es bei Erfolg zurÅck    *
 * Input: cookie_name: Name des zu suchenden ...				*
 * 		  cookie_value: Zeiger auf den spÑteren Inhalt des      *
 * 						COOKIES									*
 * Output: TRUE und Inhalt oder FALSE							*
 ****************************************************************/
boolean get_cookie(char *cookiename,long *cookie_value)
{
long old_stack;
long *cookiejar;
old_stack=Super(0L);
cookiejar= *((long **)0x5A0L); /* Zeiger auf Cookie holen */ 
Super((void *)old_stack);
if(!cookiejar)return FALSE;		/* Cookie vorhanden ? */	

do
	{
	/* gesuchtes COOKIE ? */
	if(!strncmp((char *)cookiejar,cookiename,4)) 
		{
		if(cookie_value)
			{
			*cookie_value=cookiejar[1];
			return TRUE;
			}
		}
	else
		cookiejar= &(cookiejar[2]);
	} while(cookiejar[0]); /* solange nicht NULL-COOKIE */
return FALSE;
}
/* EOF */		