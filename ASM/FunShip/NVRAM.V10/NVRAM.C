/*
 *
 *		    Boot Utility Setup for the ATARI TT & Falcon30 computer
 *				Change the NVRAM contents. 			     
 *
 * 	Author  : FunShip
 *	File    : Nvram.C
 *	Date    : 23 October 1995
 *	Release : 24 October 1995
 *	Version : 1.00
 *	Country : FRANCE
 *			
 *
 *			  - Copyright Atari FunShip (c) 1995 -
 *	 		        - ATARI TT & Falcon -
 * -----------------------------------------------------------------------------------------
 */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

/*
 * ---------------------------------------------------------------------------------------
 *				Special file to include
 */

#include "F:\Aads.030\Include\PcAads.h"
#include "NVRam__F.h"

/*
 * ---------------------------------------------------------------------------------------
 *				Defines du programme
 */

#define		VERSNUMBER		"1.00"
#define		VERSDATE		"24101995"
#define		FILERSC			"NVRAM__?.Rsc"

#define		NON_ERROR		0			/* Errors codes */
#define		RSC_ERROR		-1			/* Ressource error */
#define		SCR_ERROR		-2			/* Screen error */
#define		MCH_ERROR		-3			/* Machine error */

#define		LARGEURMIN		639			/* Display required */
#define		HAUTEURMIN		399

#define		NVM_READ		0			/* NVM opcode */
#define		NVM_WRITE		1
#define		NVM_RESET		2

#define		SYSNONE			0x00			/* System preference */
#define		SYSTOS			0x80
#define		SYSUNIX			0x40

#define		COUL2			0			/* Colors preference */
#define		COUL4			1
#define		COUL16			2
#define		COUL256			3
#define		COULNTC			4

#define		COLUM40			0x0004			/* Columns preference */
#define		COLUM80			0x0008

#define		VPAL			0x0020			/* PAL/NTSC */

#define		VVGA			0x0010			/* VGA/RGB */

#define		VERTFLAG		0x0100			/* Interleace/DoubleLine */
#define		STMODES			0x0080			/* St Modes */
#define		FULLSCREEN		0x0040			/* Overscan */

/*
 * ---------------------------------------------------------------------------------------
 *				Privates types declarations
 */

typedef	struct	{
		  unsigned int	BootPreference;
		  char		Reserved1[4];
		  unsigned char	Language;
		  unsigned char	Keyboard;
		  unsigned char	DateTime;
		  char		Separator;
		  unsigned char	BootDelay;
		  char		Reserved2[3];
		  unsigned int	VideoMode;
		} Type_NVRam;

/*
 * ---------------------------------------------------------------------------------------
 *			Bugs fixed in Pure-C compiler Feb 03 1992 !!!!
 *			
 */

#ifdef		__TOS

#undef		NVMaccess
#define		NVMaccess(opcode,offset,count,buffer)	xbios(0x2E,opcode,offset,count,buffer)

#endif

/*
 * ---------------------------------------------------------------------------------------
 *				Privates Datas and Structures;
 */

static	int		Sortir;				/* Boolean to exit program */
static	int		NombreClicPhoto;		/* Picture counter */

static	Type_NVRam	NVRam;				/* The NVRAM copie */
static	OBJECT		*Messages;			/* Messages Tree Objects */

/*
 * ---------------------------------------------------------------------------------------
 *				Information Formular
 */

void AboutOk(void);	
void PhotoCachee(void);

static Type_Form_List						/* Form Info */
FormInfo[]=	{	{INFOK,AboutOk,PhotoCachee},
			FORM_END
		};

/*
 * ---------------------------------------------------------------------------------------
 *				Main Setup Formular
 */

void AboutMe(void);
void Quitter(void);
void CycleHoraire(void);
void Change(void);
void Reset(void);
void Video(void);

static Type_Form_List						/* Main Form Setup */
FormMain[]=	{	
			{CANCEL		,Quitter,NULL},		/* Exit */
			{ABOUT		,AboutMe,NULL},		/* Call about me */
			{OK		,Change	,NULL},		/* Write config and exit */
			{RESET		,Reset	,NULL},
			{C12H		,CycleHoraire,NULL},
			{C24H		,CycleHoraire,NULL},
			
			{PAL		,Video,NULL},
			{NTSC		,Video,NULL},
			
			{VGA		,Video,NULL},
			{RVB		,Video,NULL},
			
			{INTERLEACE	,Video,NULL},
			{OVERSCAN	,Video,NULL},
			{MODEST		,Video,NULL},
			
			{COL40		,Video,NULL},
			{COL80		,Video,NULL},
			
			FORM_END
		};

/*
 * ---------------------------------------------------------------------------------------
 *				Description Popups
 */

static Type_Parameter_PopAttach					/* Popup menu */
ListPopAttach[]={
		  {PCLAVIER,KEYBOARD  ,KBD	,SCROLL_LISTBOX,TRUE},
		  {PLANGUE ,LANGUAGE  ,LGD	,SCROLL_LISTBOX,TRUE},
		  {PFORMAT ,FORMAT    ,FMT0	,SCROLL_LISTBOX,TRUE},
		  {PPREF   ,PREFERENCE,PREFTOS  ,SCROLL_LISTBOX,TRUE},
		  {PCOULEUR,COULEUR   ,COL2     ,SCROLL_LISTBOX,TRUE},		  
		  POPATTACH_END
	        };

void Keyboard(void);
void Language(void);
void FormatHoraire(void);
void Preference(void);
void Couleur(void);

Type_Parameter_PopEvent						/* Popups Event list */
ListPopEvent[]=	{	
		  {PCLAVIER,KBFR ,Keyboard},
		  {PCLAVIER,KBGB ,Keyboard},
		  {PCLAVIER,KBD  ,Keyboard},
		  {PCLAVIER,KBSP ,Keyboard},
		  {PCLAVIER,KBI  ,Keyboard},
		  {PCLAVIER,KBUSA,Keyboard},
		  {PCLAVIER,KBCHF,Keyboard},
		  {PCLAVIER,KBCHD,Keyboard},
		  
		  {PLANGUE ,LGF  ,Language},
		  {PLANGUE ,LGD  ,Language},
		  {PLANGUE ,LGGB ,Language},
		  {PLANGUE ,LGSP ,Language},
		  {PLANGUE ,LGI  ,Language},
		  {PLANGUE ,LGUSA,Language},
		  {PLANGUE ,LGCHF,Language},
		  {PLANGUE ,LGCHD,Language},
		  
		  {PFORMAT ,FMT0,FormatHoraire},
		  {PFORMAT ,FMT1,FormatHoraire},
		  {PFORMAT ,FMT2,FormatHoraire},
		  {PFORMAT ,FMT3,FormatHoraire},
		  
		  {PPREF   ,PREFNONE,Preference},
		  {PPREF   ,PREFTOS ,Preference},
		  {PPREF   ,PREFUNIX,Preference},
		  
		  {PCOULEUR,COL2  ,Couleur},
		  {PCOULEUR,COL4  ,Couleur},
		  {PCOULEUR,COL16 ,Couleur},
		  {PCOULEUR,COL256,Couleur},
		  {PCOULEUR,COLNTC,Couleur},
		  
  		  POPEVENT_END  			
  		};  				   

/*
 * ---------------------------------------------------------------------------------------
 *				
 */

void PhotoCachee(void)
/*
	Called by Double-Clic on Exit button of about me window
*/
{
  OBJECT	*Arbre;
  
  if(NombreClicPhoto == 3)				/* Rendre la photo visible */
  {
      rsrc_gaddr(R_TREE,FINFO,&Arbre);			/* Bit cach‚ Off */
      Arbre[FUNSHIP].ob_flags &= ~HIDETREE;	
      F_RedrawObject(Arbre,FUNSHIP);			/* Redessiner la photo */
      NombreClicPhoto = 1;
  } 
  else							/* Compter le nombre de DbClics */
    NombreClicPhoto++;
}

void AboutMe(void)
/*
	Opening the About me formular
*/
{
  Type_Formular_Parameter	*Parameter;
  
  Parameter = F_GetParameter();
  if(Parameter != NULL)
  {
    Parameter->TreeName = FINFO;
    Parameter->Title	= Messages[MSG1].ob_spec.free_string;				/* Formular's title */
    Parameter->Mode	= F_WIND;				/* Opening mode */
    Parameter->FirstEdit= NOTEXT;				/* First Editable Text */
    Parameter->List	= FormInfo;				/* Event list */
    Parameter->FormIcon = IINFO;
    if(F_XOpen(Parameter) != FALSE)
    {
      F_WriteText(FINFO,VERSION,VERSNUMBER);
      F_WriteText(FINFO,DATEVER,VERSDATE);
    }
    free(Parameter);
  }
}

void AboutOk(void)
/*
	Procedure called when the OK button of About me is clicked.
*/
{
  OBJECT	*Arbre;
  
  rsrc_gaddr(R_TREE,FINFO,&Arbre);				/* Tree address */
  Arbre[FUNSHIP].ob_flags |= HIDETREE;				/* Hide photo */
  F_Close(FINFO);
}

void Quitter(void)
/*
	Exit program without altear the NVRAM content.
*/
{
  Sortir = TRUE;
}

void Change(void)
/*
	Change the NVRAM content with the new values selected and quit program.
*/
{
  OBJECT	*Arbre;
  
  rsrc_gaddr(R_TREE,FMAIN,&Arbre); 
  /*	
   *	Reading the Boot Delay in second and separator character
   */
  NVRam.BootDelay = atoi(Arbre[DELAY].ob_spec.tedinfo->te_ptext);
  NVRam.Separator = Arbre[CAR].ob_spec.tedinfo->te_ptext[0];

  if(NVMaccess(NVM_WRITE,0,(int)sizeof(NVRam),&NVRam)<FALSE)	/* Copy NVRam contents */  
    form_alert(1,Messages[MSG2].ob_spec.free_string);		/* < 0 => Access Error */
  Sortir = TRUE;
}

void Reset(void)
/*
	RESET the NVRAM content with the new values selected and quit program.
*/
{
  if(NVMaccess(NVM_RESET,0,(int)sizeof(NVRam),&NVRam)<FALSE)	/* Copy NVRam contents */  
    form_alert(1,Messages[MSG3].ob_spec.free_string);		/* < 0 => Access Error */
  Sortir = TRUE;
}

/*
 * ---------------------------------------------------------------------------------------
 *				
 */
 
void Video(void)
/*
	Change the NVRam.VideoMode part of structure to set the active colors number.
	This affect only the bits 9,8,7,6,5,4,3. 

*/
{
  OBJECT	*Arbre;
  
  rsrc_gaddr(R_TREE,FMAIN,&Arbre);
  switch(F_NameObject)
  {
    /*	Pal or Ntsc display mode
     */
    case PAL:	NVRam.VideoMode |= VPAL;				/* Bit = 1 */
    		F_Select(FMAIN,PAL);
    		F_UnSelect(FMAIN,NTSC);
    		F_RedrawObject(Arbre,PAL);
    		F_RedrawObject(Arbre,NTSC);
    		break;
    case NTSC:	NVRam.VideoMode &= ~VPAL;				/* Bit = 0 */
    		F_Select(FMAIN,NTSC);
    		F_UnSelect(FMAIN,PAL);
    		F_RedrawObject(Arbre,PAL);
    		F_RedrawObject(Arbre,NTSC);
    		break;
    /*	Vga or Rvb screen monitor type
     */
    case VGA:	NVRam.VideoMode |= VVGA;				/* Bit = 1 */
    		F_Select(FMAIN,VGA);
    		F_UnSelect(FMAIN,RVB);
    		F_RedrawObject(Arbre,VGA);
    		F_RedrawObject(Arbre,RVB);
    		break;
    case RVB:	NVRam.VideoMode &= ~VVGA;				/* Bit = 0 */
    		F_Select(FMAIN,RVB);
    		F_UnSelect(FMAIN,VGA);
    		F_RedrawObject(Arbre,VGA);
    		F_RedrawObject(Arbre,RVB);
    		break;
    /*	80 Columns or 40 Columns mode
     */
    case COL80:	NVRam.VideoMode |= COLUM80;				/* Bit = 1 */
    		F_Select(FMAIN,COL80);
    		F_UnSelect(FMAIN,COL40);
    		F_RedrawObject(Arbre,COL80);
    		F_RedrawObject(Arbre,COL40);
    		break;
    case COL40:	NVRam.VideoMode &= ~COLUM80;				/* Bit = 0 */
    		F_Select(FMAIN,COL40);
    		F_UnSelect(FMAIN,COL80);
    		F_RedrawObject(Arbre,COL80);
    		F_RedrawObject(Arbre,COL40);
    		break;
    /* Double line on VGA display OR Interleace mode on RVB Display enabled or not
     */
    case INTERLEACE:	if(NVRam.VideoMode & VERTFLAG)			/* If bit = 1 */
    			{
    			  NVRam.VideoMode &= ~VERTFLAG;			/* Bit <= 0 */
    			  F_UnSelect(FMAIN,INTERLEACE);
    			  F_RedrawObject(Arbre,INTERLEACE);
    			}
    			else						/* Else bit = 0 */
    			{
    			  NVRam.VideoMode |= VERTFLAG;			/* Bit <= 1 */
    			  F_Select(FMAIN,INTERLEACE);
    			  F_RedrawObject(Arbre,INTERLEACE);
    			}
    			break;
    /*	Bit Compatibility ST Modes
     */
    case MODEST:if(NVRam.VideoMode & STMODES)				/* If bit = 1 */
    		{
    		  NVRam.VideoMode &= ~STMODES;				/* Bit <= 0 */
    		  F_UnSelect(FMAIN,MODEST);
    		  F_RedrawObject(Arbre,MODEST);
    		}
    		else							/* Else bit = 0 */
    		{	
    		  NVRam.VideoMode |= STMODES;				/* Bit <= 1 */
    		  F_Select(FMAIN,MODEST);
    		  F_RedrawObject(Arbre,MODEST);
    		}
    		break;
    /*	Bit Overscan
     */
    case OVERSCAN:	if(NVRam.VideoMode & FULLSCREEN)		/* If bit = 1 */
	    		{
    			  NVRam.VideoMode &= ~FULLSCREEN;		/* Bit <= 0 */
    			  F_UnSelect(FMAIN,OVERSCAN);
    			  F_RedrawObject(Arbre,OVERSCAN);    
    			}
	    		else						/* Else bit = 0 */
    			{	
    			  NVRam.VideoMode |= FULLSCREEN;		/* Bit <= 1 */
    			  F_Select(FMAIN,OVERSCAN);
    			  F_RedrawObject(Arbre,OVERSCAN);
    			}
    			break;
    			
  }
}

void Couleur(void)
/*
	Change the NVRam.VideoMode part of structure to set the active colors number.
	This affect only the three LSB bits 0,1 and 2.
*/
{
  switch(F_PopupEntry)
  {
    case COL2:		NVRam.VideoMode = (NVRam.VideoMode & 0xFFF8) | COUL2;
    			break;
    case COL4:		NVRam.VideoMode = (NVRam.VideoMode & 0xFFF8) | COUL4;
    			break;
    case COL16:		NVRam.VideoMode = (NVRam.VideoMode & 0xFFF8) | COUL16;
    			break;
    case COL256:	NVRam.VideoMode = (NVRam.VideoMode & 0xFFF8) | COUL256;
    			break;
    case COLNTC:	NVRam.VideoMode = (NVRam.VideoMode & 0xFFF8) | COULNTC;
    			break;
    default:		form_alert(1,Messages[MSG4].ob_spec.free_string);
    			NVRam.VideoMode = (NVRam.VideoMode & 0xFFF8) | COUL2;
    			break;
  }
}

void Keyboard(void)
/*
	Change the NVRam.Language part of structure to set the active keyboard.
*/
{
  switch(F_PopupEntry)
  {
    case KBUSA:		NVRam.Keyboard = KEYB_USA;
    			break;
    case KBD:		NVRam.Keyboard = KEYB_D;
    			break;
    case KBFR:		NVRam.Keyboard = KEYB_F;
    			break;
    case KBGB:		NVRam.Keyboard = KEYB_GB;
    			break;
    case KBSP:		NVRam.Keyboard = KEYB_SP;
    			break;
    case KBI:		NVRam.Keyboard = KEYB_I;
    			break;
    case KBCHD:		NVRam.Keyboard = KEYB_CHD;
    			break;
    case KBCHF:		NVRam.Keyboard = KEYB_CHF;
    			break;
    default:		form_alert(1,Messages[MSG5].ob_spec.free_string);
    			ListPopAttach[1].StartEntry = KEYB_GB;
    			break;
  }
}

void Language(void)
/*
	Change the NVRam.Language part of structure to set the active language.
*/
{
  switch(F_PopupEntry)
  {
    case LGUSA:		NVRam.Language = LG_USA;
    			break;
    case LGD:		NVRam.Language = LG_D;
    			break;
    case LGF:		NVRam.Language = LG_F;
    			break;
    case LGGB:		NVRam.Language = LG_GB;
    			break;
    case LGSP:		NVRam.Language = LG_SP;
    			break;
    case LGI:		NVRam.Language = LG_I;
    			break;
    case LGCHD:		NVRam.Language = LG_CHD;
    			break;
    case LGCHF:		NVRam.Language = LG_CHF;
    			break;
    default:		form_alert(1,Messages[MSG6].ob_spec.free_string);
    			ListPopAttach[1].StartEntry = LGGB;
    			break;
  }
}

void CycleHoraire(void)
/*
	Change the NVRam.DateTime part of structure to set the date format.(12h/24h)
	This affect only the bit 5.	
*/
{
  OBJECT	*Arbre;
  
  rsrc_gaddr(R_TREE,FMAIN,&Arbre);
  switch(F_NameObject)
  {
    case C12H:		F_Select(FMAIN,C12H);
    			F_UnSelect(FMAIN,C24H);
    			F_RedrawObject(Arbre,C12H);
    			F_RedrawObject(Arbre,C24H);
    			NVRam.DateTime &= 0xEF;				/* Bit5 = 0 */
    			break;
    case C24H:		F_Select(FMAIN,C24H);
    			F_UnSelect(FMAIN,C12H);
    			F_RedrawObject(Arbre,C12H);
    			F_RedrawObject(Arbre,C24H);
    			NVRam.DateTime |= 0x10;				/* Bit5 = 1 */
    			break;
  }
}
void FormatHoraire(void)
/*
	Change the NVRam.DateTime part of structure to set the date format.(J/M/A)
	This affect only the LSB bits 0,1 and 2.
*/
{
  switch(F_PopupEntry)
  {
    case FMT0:		NVRam.DateTime = (NVRam.DateTime & 0xF8) | DATE_MJA;
    			break;
    case FMT1:		NVRam.DateTime = (NVRam.DateTime & 0xF8) | DATE_JMA;		
    			break;
    case FMT2:		NVRam.DateTime = (NVRam.DateTime & 0xF8) | DATE_AMJ;
    			break;
    case FMT3:		NVRam.DateTime = (NVRam.DateTime & 0xF8) | DATE_AJM;
    			break;
    default:		form_alert(1,Messages[MSG7].ob_spec.free_string);
    			break;
  }
}

void Preference(void)
/*
	Change the NVRam.BootPreference part of structure to set the system preference.
*/
{
  switch(F_PopupEntry)
  {
    case PREFNONE:	NVRam.BootPreference = SYSNONE;
    			break;
    case PREFUNIX:	NVRam.BootPreference = SYSUNIX;
    			break;
    case PREFTOS:	NVRam.BootPreference = SYSTOS;
    			break;
    default:		form_alert(1,Messages[MSG8].ob_spec.free_string);
    			break;
  }
}

/*
 * ---------------------------------------------------------------------------------------
 *				Access Programs to NVRam
 */

void InterpreteNVRAM(void)
/*
	InterprŠte le contenu de la structure NVRAM en initialisant
	correctement le formulaire pour la repr‚senation graphique.
*/
{
  OBJECT	*Arbre;
  
  /*
   *	NVRAM access reading
   */
  if(NVMaccess(NVM_READ,0,(int)sizeof(NVRam),&NVRam)<FALSE)	/* Copy NVRam contents */  
    form_alert(1,Messages[MSG9].ob_spec.free_string);		/* < 0 => Access Error */

  /*
   *	Interpretation of NVRam contents
   */  
  switch(NVRam.BootPreference)					/* System Selected */
  {
    case SYSNONE:	ListPopAttach[3].StartEntry = PREFNONE;
    			break;
    case SYSTOS:	ListPopAttach[3].StartEntry = PREFTOS;
    			break;
    case SYSUNIX:	ListPopAttach[3].StartEntry = PREFUNIX;
    			break;
    default:		ListPopAttach[3].StartEntry = PREFNONE;
    			break;
  }       
  switch(NVRam.DateTime & 0x03)					/* Datetime format */
  {
    case DATE_MJA:	ListPopAttach[2].StartEntry = FMT0;
    			break;
    case DATE_JMA:	ListPopAttach[2].StartEntry = FMT1;
    			break;
    case DATE_AMJ:	ListPopAttach[2].StartEntry = FMT2;
    			break;
    case DATE_AJM:	ListPopAttach[2].StartEntry = FMT3;
    			break;
    default:		form_alert(1,Messages[MSG10].ob_spec.free_string);
    			ListPopAttach[2].StartEntry = FMT0;
    			break;
  }
  switch(NVRam.Language)					/* Language Enabled */
  {
    case LG_USA:	ListPopAttach[1].StartEntry = LGUSA;
    			break;
    case LG_D:		ListPopAttach[1].StartEntry = LGD;
    			break;
    case LG_F:		ListPopAttach[1].StartEntry = LGF;
    			break;
    case LG_GB:		ListPopAttach[1].StartEntry = LGGB;
    			break;
    case LG_SP:		ListPopAttach[1].StartEntry = LGSP;
    			break;
    case LG_I:		ListPopAttach[1].StartEntry = LGI;
    			break;
    case LG_CHD:	ListPopAttach[1].StartEntry = LGCHD;
    			break;
    case LG_CHF:	ListPopAttach[1].StartEntry = LGCHF;
    			break;
    default:		form_alert(1,Messages[MSG11].ob_spec.free_string);
    			ListPopAttach[1].StartEntry = LGGB;
    			break;
  }
  switch(NVRam.Keyboard)					/* Keyboard Enabled */
  {
    case KEYB_USA:	ListPopAttach[0].StartEntry = KBUSA;
    			break;
    case KEYB_D:	ListPopAttach[0].StartEntry = KBD;
    			break;
    case KEYB_F:	ListPopAttach[0].StartEntry = KBFR;
    			break;
    case KEYB_GB:	ListPopAttach[0].StartEntry = KBGB;
    			break;
    case KEYB_SP:	ListPopAttach[0].StartEntry = KBSP;
    			break;
    case KEYB_I:	ListPopAttach[0].StartEntry = KBI;
    			break;
    case KEYB_CHD:	ListPopAttach[0].StartEntry = KBCHD;
    			break;
    case KEYB_CHF:	ListPopAttach[0].StartEntry = KBCHF;
    			break;
    default:		form_alert(1,Messages[MSG12].ob_spec.free_string);
    			ListPopAttach[1].StartEntry = LGGB;
    			break;
  }
  
  rsrc_gaddr(R_TREE,FMAIN,&Arbre);
  
  /*	Boot Delay in second */
  itoa(NVRam.BootDelay,Arbre[DELAY].ob_spec.tedinfo->te_ptext,10);

  /*	Separator character */
  Arbre[CAR].ob_spec.tedinfo->te_ptext[0] = NVRam.Separator ? NVRam.Separator : '/';
  
  /*	Hours cycle */
  if( (NVRam.DateTime >> 4) & 0x01)				/* 24 Hours format */
    Arbre[C24H].ob_state |= SELECTED;
  else								/* 12 Hours format */
    Arbre[C12H].ob_state |= SELECTED;
    
  /*
   *	Video mode analyse
   */
  switch(NVRam.VideoMode & 0x07)				/* Colors analyse */
  {
    case COUL2:		ListPopAttach[4].StartEntry = COL2;
    			break;
    case COUL4:		ListPopAttach[4].StartEntry = COL4;
    			break;
    case COUL16:	ListPopAttach[4].StartEntry = COL16;
    			break;
    case COUL256:	ListPopAttach[4].StartEntry = COL256;
    			break;
    case COULNTC:	ListPopAttach[4].StartEntry = COLNTC;
    			break;
    default:		form_alert(1,Messages[MSG13].ob_spec.free_string);
    			ListPopAttach[4].StartEntry = COL2;
    			break;
  }
  if(NVRam.VideoMode & VPAL)						/* PAL/NTSC */
    Arbre[PAL].ob_state |= SELECTED;
  else
    Arbre[NTSC].ob_state |= SELECTED;
 
  if(NVRam.VideoMode & VVGA)						/* PAL/NTSC */
    Arbre[VGA].ob_state |= SELECTED;
  else
    Arbre[RVB].ob_state |= SELECTED;

  if(NVRam.VideoMode & COLUM80)						/* 40/80 Columns */
    Arbre[COL80].ob_state |= SELECTED;
  else
    Arbre[COL40].ob_state |= SELECTED;
  
  if(NVRam.VideoMode & VERTFLAG)					/* DBLine/Interleace */
    Arbre[INTERLEACE].ob_state |= SELECTED;

  if(NVRam.VideoMode & STMODES)						/* Compatible ST */
    Arbre[MODEST].ob_state |= SELECTED;

  if(NVRam.VideoMode & FULLSCREEN)					/* Overscan */
    Arbre[OVERSCAN].ob_state |= SELECTED;
  
}

/*
 * ---------------------------------------------------------------------------------------
 *				Programmes principaux
 */

void Ouverture(void)
/*
	Main procedure: Call reading of NVRam and opening the main formular
*/
{
  Type_Formular_Parameter	*Parameter;

  /*
   *	Configure all formular's objects
   */
  InterpreteNVRAM();

  /*
   *	Install all Popups menu to Fmain formular
   */
  F_PopAttach(FMAIN,ListPopAttach);				/* Attach Pop-ups */
  F_PopEvent(ListPopEvent);					/* Install Pop-events */
  
  /*
   *	Opening Main formular
   */
  Parameter = F_GetParameter();
  if(Parameter != NULL)
  {
    Parameter->TreeName = FMAIN;
    Parameter->Title	= Messages[MSG14].ob_spec.free_string;				/* Formular's title */
    Parameter->Mode	= F_WIND;				/* Opening mode */
    Parameter->FirstEdit= CAR;					/* First Editable Text */
    Parameter->List	= FormMain;				/* Event list */
    Parameter->FormIcon = ISETUP;
    F_XOpen(Parameter);
    free(Parameter);
  }
}

int main(void)
/*
	Main C procedure to configure all GEM interface.
*/
{
  OBJECT			*Arbre;
  
  if(!A_Open(FILERSC))
  {
    form_alert(1,"[1][ | NVRam__?.Rsc not found ][ Ok ]");
    A_Close();
    return(RSC_ERROR);						/* Quit immediatly */
  }
  if(VdiInfo.HauteurStation < HAUTEURMIN || VdiInfo.LargeurStation < LARGEURMIN)		
  {
    form_alert(1,"[1][ Bad Screen Rezolution | 640 x 400 needed ][ Ok ]");
    A_Close();
    return(SCR_ERROR);
  } 
  if(MchInfo.Machine < TT)
  {
    form_alert(1,"[3][ TT Computer and up only ][Ok]");
    A_Close();
    return(MCH_ERROR);
  }
  W_Init();							/* Init Window  */
  M_Init();							/* Init Menu    */
  F_Init();							/* Init Form    */
  graf_mouse(ARROW,NULL);					/* just for fun */
  W_SetIconApp(IAPPLI);						/* Set Icon Form Appli. */

  /*
   *	Calcul l'adresse de l'arbre d'objets des messages en langue actulle.
   *	Et cache la photo cach‚e...
   */
  rsrc_gaddr(R_TREE,MESSAGES,&Messages);			/* Message tree address */
  
  rsrc_gaddr(R_TREE,FINFO,&Arbre);				/* Form info tree adr */
  Arbre[FUNSHIP].ob_flags |= HIDETREE;				/* Hide my own photo */
  NombreClicPhoto = 0;
  
  Ouverture();							/* Ouvre Main Form */
  /*
   *		Event loop
   */
  Sortir = FALSE;
  do
  {
    A_WaitEvent();						/* Waiting an event	*/
    F_Event();							/* Form Event 		*/
    M_Event();							/* Menu Event		*/
    W_Event();							/* Window Event		*/
  }
  while(!Sortir);

  F_Close(FINFO);						/* Ferme les formulaires*/
  F_Close(FMAIN);
  
  W_Exit();
  M_Exit();						
  F_Exit();						
  
  A_Close();							/* Close Application	*/
  return(NON_ERROR);						/* for the shell 	*/
}
