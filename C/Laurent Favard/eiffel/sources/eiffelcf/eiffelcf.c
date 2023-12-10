/*
 *	--------------------------------------------------------------
 *	Eiffel Control Pannel, a setup utility for eiffel interface.
 *
 * 	Author  :	Laurent Favard, Didier Mequignon
 *	Date    :	10 April 2002
 *	Release :   1 November 2004
 *	Version :	1.10
 *	Country :	FRANCE
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *	--------------------------------------------------------------
 */

#include 	<stdio.h>
#include 	<stdlib.h>
#include	<ext.h>
#include	<string.h>
#include 	<tos.h>

#include 	<PCAads.h>
#include 	"eiffel_g.h"
#include 	"eiffel.h"
#include 	"update.h"

/*	--------------------------------------------------------------	*/

#define		ESC				0x01

#define		VERSDATE		"November 1, 2004"
#define		FILERSC			"eiffel_g.rsc"

#define		NON_ERROR		0			/* Errors codes */
#define		ERSC			1			/* Ressource error */
#define		ESCR			2			/* Screen error */

#define		LARGEURMIN		639			/* Display required */
#define		HAUTEURMIN		399

/*	--------------------------------------------------------------	*/

typedef	struct	{
					unsigned int	LevelHTemp;
					unsigned int	LevelLTemp;
					unsigned int	Rctn[12];
					unsigned int	Temp[12];
				} TTEMPParams;

typedef	struct	{
					unsigned int	WheelUp;
					unsigned int	WheelDown;
					unsigned int	WheelLeft;
					unsigned int	WheelRight;
					unsigned int	WheelScroll;
					unsigned int	Button3;
					unsigned int	Button4;
					unsigned int	Button5;
				} TMSParams;

typedef	struct	{
					unsigned int	f11;
					unsigned int	f12;
					unsigned int	PrintScreen;
					unsigned int	Scroll;
					unsigned int	Pause;
					unsigned int	WinLeft;
					unsigned int	WinRight;
					unsigned int	WinApp;
					unsigned int	VerrNum;
					unsigned int	AltGR;
					unsigned int	PageUp;
					unsigned int	PageDown;
					unsigned int	End;
					unsigned int	Russe;
					unsigned int	Set;
				} TKBParams;
				
/*	--------------------------------------------------------------	*/

static  TTEMPParams		TEMPParams;						/* Temperature block */
static	TMSParams		MSParams;						/* Mouse codes block */
static	TKBParams		KBParams;						/* Keyboard codes block */
static	int				Sortir		=	FALSE;
static	int				ActivePage	=	TABPAGEMS;

static	char			Path		[ PATH_LEN]				= "\0"; 						/* Chemin seulement */
static	char			PathName	[ PATH_LEN+FILENAME_LEN]= "\0"; 						/* Chemin + Nom de fichier */
static	char			PathNameInf	[ PATH_LEN+FILENAME_LEN]= "\0"; 						/* Chemin + Nom de fichier */
static	char			FileName	[ FILENAME_LEN]			= "eiffel.hex\0"; 				/* Nom de fichier seulement */
static	char			Extension	[ EXT_LEN]				= "*.hex\0";					/* Extension de fichiers */
static	char			FileNameUnShift	[ FILENAME_LEN]			= "unshift.inf\0"; 				/* Nom de fichier seulement */
static	char			FileNameShift	[ FILENAME_LEN]			= "shift.inf\0"; 				/* Nom de fichier seulement */
static	char			FileNameAltGr	[ FILENAME_LEN]			= "altgr.inf\0"; 				/* Nom de fichier seulement */
static	char			FileNameModifier	[ FILENAME_LEN]			= "modifier.inf\0"; 				/* Nom de fichier seulement */
static	char			ExtensionInf	[ EXT_LEN]				= "*.inf\0";					/* Extension de fichiers */
static	int				ValidHex	=	FALSE;

/*	--------------------------------------------------------------	*/

int						WHandle;

extern unsigned char shift[0x90];
extern unsigned char altgr[0x90];
extern unsigned char modifier[0x90];

/*	--------------------------------------------------------------	*/

static Type_Form_List									/* Form Info */
FormInfo[]=	{
				{ 0, NULL, NULL },
				FORM_END
			};

/*	--------------------------------------------------------------	*/
void OnMenuItem( int );
void OnExit	(void);
void OnAbout(void);
void OnMsProg(void);
void OnKbProg(void);
void OnLoadKb(void);
void OnInitKb(void);
void OnLoadHex(void);
void OnLoadShift(void);
void OnLoadAltGr(void);
void OnLoadModifier(void);
void OnUpdate(void);
void OnTempProg();
void OnSensProg();
void OnDefault(void);
void OnReset(void);
void OnScanSelect(void);
void OnTabCtrl( void );
/*	--------------------------------------------------------------	*/
static Type_Window_Menu_List
WMenu[]=		{
					{MNMS		,CHECKED, 	OnMenuItem},
					{MNKB		,INITIAL, 	OnMenuItem},
					{MNTEMP		,INITIAL, 	OnMenuItem},
					{MNUPD		,INITIAL, 	OnMenuItem},
					{MNPRGMS	,INITIAL,	OnMenuItem},
					{MNPRGKB	,INITIAL,	OnMenuItem},
					{MNPRGTEMP	,INITIAL,	OnMenuItem},
					{MNPRGSENSOR,INITIAL,	OnMenuItem},
					{MNPRGFL	,INITIAL,	OnMenuItem},
					{MNLOADHEX	,INITIAL,	OnMenuItem},
					{MNRESET	,INITIAL,	OnMenuItem},
					{MNABOUT 	,INITIAL, 	OnMenuItem},
					{MNQUIT 	,INITIAL, 	OnMenuItem},
					WMENU_END
				};
/*	--------------------------------------------------------------	*/
static Type_Form_List
FormMain[]=	    {
                    {QUIT		,OnExit		,NULL},
                    {ABOUT		,OnAbout	,NULL},
                    {PRGMS		,OnMsProg	,NULL},
                    {PRGKB		,OnKbProg	,NULL},
                    {LOADHEX	,OnLoadHex	,NULL},
                    {LOADSHIFT	,OnLoadShift	,NULL},
                    {LOADALTGR	,OnLoadAltGr	,NULL},
                    {LOADMOD	,OnLoadModifier	,NULL},
                    {LOADKB		,OnLoadKb	,NULL},
                    {INITKB		,OnInitKb	,NULL},
                    {PRGFL		,OnUpdate	,NULL},
                    {PRGTEMP	,OnTempProg	,NULL},
                    {PRGSENSOR	,OnSensProg	,NULL},
                    {RESET		,OnReset	,NULL},
                    {TABCTRLMS	,OnTabCtrl	,NULL},
                    {TABCTRLKB	,OnTabCtrl	,NULL},
                    {TABCTRLTEMP,OnTabCtrl	,NULL},
                    {TABCTRLUPD	,OnTabCtrl	,NULL},
                    FORM_END
			    };

/*	--------------------------------------------------------------	*/
static Type_Parameter_PopAttach							/* Attachement des Popups aux boutons */
ListPopAttach[]={
					/*	Concernant la souris */
                    {PPKEYS	,BUTTON3	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,BUTTON4  	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,BUTTON5   	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,WHEELUP	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,WHEELDN   	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,WHEELLT   	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,WHEELRT   	,SC_DEFAULT		,SCROLL_LISTBOX	,FALSE},
					/*	Consernant le clavier */
                    {PPKEYS	,F11		,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,F12	 	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,PRNT  		,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,SCROLL		,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,PAUSE   	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,WLEFT   	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,WRIGHT  	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                   	{PPKEYS	,WAPP  		,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,VERR   	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,ALTGR   	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS ,PAGEUP		,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,PAGEDN  	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,END     	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKEYS	,RUSSE2  	,SC_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    {PPKBSET	,KBSET  	,KB_DEFAULT	    ,SCROLL_LISTBOX	,FALSE},
                    POPATTACH_END
		        };

/*	--------------------------------------------------------------	*/
Type_Parameter_PopEvent									/* Attachement des call-backs ‚vŠnements */
ListPopEvent[]=	{
                    {PPKEYS,	SC_NONE		,OnScanSelect},
                    {PPKEYS,	SC_DEFAULT,OnScanSelect},
                    {PPKEYS,	SC_STATUS	,OnScanSelect},
                    {PPKEYS,	SC_ESC 		,OnScanSelect},
                    {PPKEYS,	SC_HELP 	,OnScanSelect},
                    {PPKEYS,	SC_UNDO  	,OnScanSelect},
                    {PPKEYS,	SC_RETURN	,OnScanSelect},
                    {PPKEYS,	SC_ARROWUP  ,OnScanSelect},
                    {PPKEYS,	SC_ARROWDN	,OnScanSelect},
                    {PPKEYS,	SC_ARROWLT	,OnScanSelect},
                    {PPKEYS,	SC_ARROWRT	,OnScanSelect},
                    {PPKBSET,	KB_DEFAULT	,OnScanSelect},
                    {PPKBSET,	KB_SET3	,OnScanSelect},
                    {PPKBSET,	KB_SET2	,OnScanSelect},
                    POPEVENT_END
  				};

/*	--------------------------------------------------------------	*/
void OnAbout(void)
/*
	Opening the About me formular
*/
{
    Type_Formular_Parameter	*Parameter;

    Parameter = F_GetParameter();
    if(Parameter != NULL)
    {
        Parameter->TreeName = FINFO;
        Parameter->Title	= "About...";							/* Formular's title */
        Parameter->Mode		= F_WIND;								/* Opening mode */
        Parameter->FirstEdit= NOTEXT;								/* First Editable Text */
        Parameter->List		= FormInfo;								/* Event list */
        Parameter->FormIcon = IINFO;
        if(F_XOpen(Parameter) != FALSE)
        {
            F_WriteText(FINFO,DATEVER,VERSDATE);
        }
    	free(Parameter);
    }
}
/*	--------------------------------------------------------------
	Ikbws( Len, Buffer ) envoit Len + 1 caracteres du Buffer !!
	--------------------------------------------------------------	*/
void sendReset( void )
/*	Send a Reset command to Eiffel, standard command IKBD */
{
	char	Buffer[ SZ_EIFRESET ];

	Buffer[ 0 ]	=	IKBD_RESET;
	Buffer[ 1 ]	=	0x01;
	Ikbdws( SZ_EIFRESET, Buffer );
	
	Kbshift(Kbshift(-1) & 0xFFEF); /* remove CAPSLOCK */
}

void sendScanCodesSet( void )
/*	Send the Scan-codes Set to Eiffel */
{
	char	Buffer[ SZ_PROGMS ];
	
	Buffer[ 0 ]	=	IKBD_PROGKB;
	Buffer[ 1 ]	=	(unsigned char)0xFF;
	Buffer[ 2 ]	=	(unsigned char)KBParams.Set;
	if(Buffer[2]==2 || Buffer[2]==3)
	{
		Ikbdws( SZ_PROGKB - 1, Buffer + 0 );
		delay(100);
	}
}
/*	--------------------------------------------------------------	*/
/*	Send a get temperature command to Eiffel, Temp cookie must be installed */
void getTemp( void )
{
	static int init=0;
	
	char	Buffer[ 1 ];
	unsigned char	*Infos;
    OBJECT			*Arbre;
	COOKIE *p;
	
	Buffer[ 0 ]	=	IKBD_GETTEMP;
	Ikbdws( 0, Buffer );
	if(init)
		delay( 2000 );
	else
		delay( 50 );
	if((p=get_cookie('Temp'))!=0)
    {
    	Infos=(unsigned char *)p->v.l;
    	rsrc_gaddr(R_TREE,FMAIN,&Arbre);
		sprintf(Arbre[ AFFTEMP ].ob_spec.tedinfo->te_ptext,"Temp: %02døC ADC: %03d RCTN: %05d Motor: %01d",
		Infos[0]&63,Infos[1],((unsigned int)Infos[5])*100,Infos[2]&1);
		if(!init)
		{
			if(Infos[3])
				itoa( (int)Infos[3]&63, Arbre[ LEVELHTEMP ].ob_spec.tedinfo->te_ptext, 10 );
			if(Infos[4])
				itoa( (int)Infos[4]&63, Arbre[ LEVELLTEMP ].ob_spec.tedinfo->te_ptext, 10 );
		}
    }
    init=1;
}
/*	--------------------------------------------------------------	*/
void sendProgTemp( unsigned int aOffset, unsigned int aValue )
/*	Send a temperature programming command to Eiffel:
	aOffset is the index of scan-code to program
	aValue is the new value to set
*/
{
	char	Buffer[ SZ_PROGTEMP ];
	
	Buffer[ 0 ]	=	IKBD_PROGTEMP;
	Buffer[ 1 ]	=	(unsigned char)aOffset;
	Buffer[ 2 ]	=	(unsigned char)aValue;

	Ikbdws( SZ_PROGTEMP - 1, Buffer + 0 );
    delay( 500 );
}
/*	--------------------------------------------------------------	*/
void sendProgMouse( unsigned int aOffset, unsigned int aValue )
/*	Send a mouse programming command to Eiffel:
	aOffset is the index of scan-code to program
	aValue is the new value to set
*/
{
	char	Buffer[ SZ_PROGMS ];
	
	Buffer[ 0 ]	=	IKBD_PROGMS;
	Buffer[ 1 ]	=	(unsigned char)aOffset;
	Buffer[ 2 ]	=	(unsigned char)aValue;

	Ikbdws( SZ_PROGMS - 1, Buffer + 0 );
    delay( 500 );
}
/*	--------------------------------------------------------------	*/
void sendProgKeyboard( unsigned int aOffset, unsigned int aValue )
/*	Send a keyboard programming command to Eiffel:
	aOffset is the index of scan-code to program
	aScanCode is the new value to set
*/
{
	char	Buffer[ SZ_PROGMS ];
	
	Buffer[ 0 ]	=	IKBD_PROGKB;
	Buffer[ 1 ]	=	(unsigned char)aOffset;
	Buffer[ 2 ]	=	(unsigned char)aValue;

	Ikbdws( SZ_PROGKB - 1, Buffer + 0 );
    delay( 100 );
}

/*	--------------------------------------------------------------	*/
/*	--------------------------------------------------------------	*/

int GetDefault( int aObjectParent )
/*	Retourne le scan-code par defaut affect‚ a la touche clavier ou a l'element souris */
{
	int	Code;
	switch( aObjectParent ) {
    	/*	get default value for mouse */
        case BUTTON3:	Code	=	DEF_BUTTON3;	break;
        case BUTTON4:	Code	=	DEF_BUTTON4;	break;
        case BUTTON5:	Code	=	DEF_BUTTON5;	break;
        case WHEELUP:  	Code	=	DEF_WHEELUP;	break;
        case WHEELDN:  	Code	=	DEF_WHEELDN;	break;
        case WHEELLT:  	Code	=	DEF_WHEELLT;	break;
        case WHEELRT:  	Code	=	DEF_WHEELRT;	break;
    	/*	get default value for keyboard */
        case F11:		Code	=	DEF_F11;		break;
        case F12:		Code	=	DEF_F12;		break;
        case PRNT:		Code	=	DEF_PRINTSCREEN;break;
        case SCROLL:  	Code	=	DEF_SCROLL;		break;
        case PAUSE:	  	Code	=	DEF_PAUSE;		break;
        case WLEFT:	  	Code	=	DEF_WINLEFT;	break;
        case WRIGHT:  	Code	=	DEF_WINRIGHT;	break;
        case WAPP:		Code	=	DEF_WINAPP;		break;
        case VERR:		Code	=	DEF_VERRNUM;	break;
        case ALTGR:		Code	=	DEF_ALTGR;		break;
        case PAGEUP:	Code	=	DEF_PAGEUP;		break;
        case PAGEDN:	Code	=	DEF_PAGEDN;		break;
        case END:		Code	=	DEF_END;		break;
        case RUSSE2:	Code	=	DEF_RUSSE;		break;
        case KBSET:		Code	=	0;				break;

        default:	   	break;
    }
    return	Code;
}
/*	--------------------------------------------------------------	*/
int GetScanCode( int aObjectParent, int aItem )
/*
	Retourne le scan-code a affecter a la touche clavier ou a l'element souris.
    Les SC_xx sont les scan-codes diposibles du menu deroulant.
*/
{
	int	Code;
	switch( aItem ) {
    	case SC_NONE:		Code	=	0x00;		break;	/* Pas de scan-code ! */
    	case SC_ARROWUP:	Code	=	0x48;		break;
    	case SC_ARROWDN:	Code	=	0x50;		break;
    	case SC_ARROWLT:	Code	=	0x4B;		break;
    	case SC_ARROWRT:	Code	=	0x4D;		break;
    	case SC_HELP:		Code	=	0x62;		break;
    	case SC_UNDO:		Code	=	0x61;		break;
    	case SC_ESC:		Code	=	0x01;		break;
    	case SC_RETURN:		Code	=	0x1C;		break;
    	case SC_STATUS:		Code	=	GetDefault( aObjectParent) + 0x80;	break;
    	case SC_DEFAULT:
    	default:			Code	=	GetDefault( aObjectParent );
    						break;
	}
    return	Code;
}
/*	--------------------------------------------------------------	*/
int GetScanCodesSet( int aObjectParent, int aItem )
{
	int	Code;
	switch( aItem ) {
		case KB_SET2:		Code	=	2;			break;	/* Scan-codes Set 2 */
		case KB_SET3:		Code	=	3;			break;	/* Scan-codes Set 3 */		
		case KB_DEFAULT:
    	default:			Code	=	GetDefault( aObjectParent );
    						break;
	}
    return	Code;
}
/*	--------------------------------------------------------------	*/
void DisplayDefault( void )
{
    OBJECT			*Arbre;

    /*	About mouse objects */
	ListPopAttach[ 0 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object BUTTON3 */
	ListPopAttach[ 1 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object BUTTON4 */
	ListPopAttach[ 2 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object BUTTON5 */
	ListPopAttach[ 3 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WHEELUP */
	ListPopAttach[ 4 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WHEELDN */
	ListPopAttach[ 5 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WHEELLT */
	ListPopAttach[ 6 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WHEELRT */

    rsrc_gaddr( R_TREE, FMAIN, &Arbre );
	itoa( DEF_WHREPEAT, Arbre[ REPEAT ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_LEVELHTEMP, Arbre[ LEVELHTEMP ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_LEVELLTEMP, Arbre[ LEVELLTEMP ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN1, Arbre[ RCTN1 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP1, Arbre[ TEMP1 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN2, Arbre[ RCTN2 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP2, Arbre[ TEMP2 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN3, Arbre[ RCTN3 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP3, Arbre[ TEMP3 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN4, Arbre[ RCTN4 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP4, Arbre[ TEMP4 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN5, Arbre[ RCTN5 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP5, Arbre[ TEMP5 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN6, Arbre[ RCTN6 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP6, Arbre[ TEMP6 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN7, Arbre[ RCTN7 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP7, Arbre[ TEMP7 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN8, Arbre[ RCTN8 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP8, Arbre[ TEMP8 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN9, Arbre[ RCTN9 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP9, Arbre[ TEMP9 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN10, Arbre[ RCTN10 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP10, Arbre[ TEMP10 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN11, Arbre[ RCTN11 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP11, Arbre[ TEMP11 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_RCTN12, Arbre[ RCTN12 ].ob_spec.tedinfo->te_ptext, 10 );
	itoa( DEF_TEMP12, Arbre[ TEMP12 ].ob_spec.tedinfo->te_ptext, 10 );

    /*	About mouse objects */
	ListPopAttach[ 7  ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object F11		*/
	ListPopAttach[ 8  ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object F12		*/
	ListPopAttach[ 9  ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object PRNT	*/
	ListPopAttach[ 10 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object SCROLL	*/
	ListPopAttach[ 11 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object PAUSE 	*/
	ListPopAttach[ 12 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WLEFT 	*/
	ListPopAttach[ 13 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WRIGHT	*/
    ListPopAttach[ 14 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object WAPP    */
    ListPopAttach[ 15 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object VERR    */
    ListPopAttach[ 16 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object ALTGR   */
    ListPopAttach[ 17 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object PAGEUP  */
    ListPopAttach[ 18 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object PAGEDN  */
    ListPopAttach[ 19 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object END     */
    ListPopAttach[ 20 ].StartEntry = SC_DEFAULT;            /*	Popup attach to this object RUSSE2  */
    
    ListPopAttach[ 21 ].StartEntry = KB_DEFAULT;            /*	Popup attach to this object KBSET  */
    
}
/*	--------------------------------------------------------------	*/
void SetDefault(void)
{
	TEMPParams.LevelHTemp 	=	DEF_LEVELHTEMP;
	TEMPParams.LevelLTemp 	=	DEF_LEVELLTEMP;
	TEMPParams.Rctn[0] 		=	DEF_RCTN1;
	TEMPParams.Temp[0] 		=	DEF_TEMP1;
	TEMPParams.Rctn[1] 		=	DEF_RCTN2;
	TEMPParams.Temp[1] 		=	DEF_TEMP2;
	TEMPParams.Rctn[2] 		=	DEF_RCTN3;
	TEMPParams.Temp[2] 		=	DEF_TEMP3;
	TEMPParams.Rctn[3] 		=	DEF_RCTN4;
	TEMPParams.Temp[3] 		=	DEF_TEMP4;
	TEMPParams.Rctn[4] 		=	DEF_RCTN5;
	TEMPParams.Temp[4] 		=	DEF_TEMP5;
	TEMPParams.Rctn[5] 		=	DEF_RCTN6;
	TEMPParams.Temp[5] 		=	DEF_TEMP6;
	TEMPParams.Rctn[6] 		=	DEF_RCTN7;
	TEMPParams.Temp[6] 		=	DEF_TEMP7;
	TEMPParams.Rctn[7] 		=	DEF_RCTN8;
	TEMPParams.Temp[7] 		=	DEF_TEMP8;
	TEMPParams.Rctn[8] 		=	DEF_RCTN9;
	TEMPParams.Temp[8] 		=	DEF_TEMP9;
	TEMPParams.Rctn[9] 		=	DEF_RCTN10;
	TEMPParams.Temp[9] 		=	DEF_TEMP10;
	TEMPParams.Rctn[10] 	=	DEF_RCTN11;
	TEMPParams.Temp[10] 	=	DEF_TEMP11;
	TEMPParams.Rctn[11] 	=	DEF_RCTN12;
	TEMPParams.Temp[11] 	=	DEF_TEMP12;
	
	MSParams.WheelUp 	=	DEF_WHEELUP;                  
	MSParams.WheelDown 	=	DEF_WHEELDN;                  
	MSParams.WheelLeft 	=	DEF_WHEELLT;                  
	MSParams.WheelRight =	DEF_WHEELRT;
	MSParams.Button3 	=	DEF_BUTTON3;
	MSParams.Button4 	=	DEF_BUTTON4;
	MSParams.Button5 	=	DEF_BUTTON5;
	MSParams.WheelScroll=	DEF_WHREPEAT;

	KBParams.f11		=	DEF_F11;
	KBParams.f12		=	DEF_F12;
	KBParams.PrintScreen=	DEF_PRINTSCREEN;
	KBParams.Scroll		=	DEF_SCROLL;
	KBParams.Pause		=	DEF_PAUSE;
	KBParams.WinLeft	=	DEF_WINLEFT;
	KBParams.WinRight	=	DEF_WINRIGHT;
	KBParams.WinApp		=	DEF_WINAPP;
	KBParams.VerrNum	=	DEF_VERRNUM;
	KBParams.AltGR		=	DEF_ALTGR;
	KBParams.PageUp		=	DEF_PAGEUP;
	KBParams.PageDown	=	DEF_PAGEDN;
	KBParams.End		=	DEF_END;
	KBParams.Russe		=	DEF_RUSSE;
	
	KBParams.Set		=	1;
}
/*	--------------------------------------------------------------	*/
void SwitchTab( int NewTabPage )
{
	OBJECT	*Arbre;
	int		x, y, w, h;
	
	rsrc_gaddr( R_TREE, FMAIN, &Arbre );
	
    Arbre[ NewTabPage ].ob_flags	&=	~HIDETREE;
    Arbre[ ActivePage ].ob_flags	|=	HIDETREE;

	switch (NewTabPage)
	{
		case TABPAGEUPD :
			Arbre[TABCTRLUPD].ob_state	&=	~SELECTED;
			Arbre[TABCTRLTEMP].ob_state	|=	SELECTED;
			Arbre[TABCTRLMS].ob_state	|=	SELECTED;
			Arbre[TABCTRLKB].ob_state	|=	SELECTED;
    		W_MnCheck	( WHandle, MNUPD );
		    W_MnUnCheck	( WHandle, MNTEMP );
		    W_MnUnCheck	( WHandle, MNMS );
		    W_MnUnCheck	( WHandle, MNKB );
		    W_MnEnable( WHandle, MNPRGFL );
		    W_MnDisable( WHandle, MNPRGKB );
		    W_MnDisable( WHandle, MNPRGMS );
		    W_MnDisable( WHandle, MNPRGTEMP );
		    W_MnDisable( WHandle, MNPRGSENSOR );
			break;
		case TABPAGETEMP :
			Arbre[TABCTRLTEMP].ob_state	&=	~SELECTED;
			Arbre[TABCTRLUPD].ob_state	|=	SELECTED;
			Arbre[TABCTRLMS].ob_state	|=	SELECTED;
			Arbre[TABCTRLKB].ob_state	|=	SELECTED;
    		W_MnCheck	( WHandle, MNTEMP );
		    W_MnUnCheck	( WHandle, MNUPD );
		    W_MnUnCheck	( WHandle, MNMS );
		    W_MnUnCheck	( WHandle, MNKB );
		    W_MnDisable( WHandle, MNPRGFL );
		    W_MnDisable( WHandle, MNPRGKB );
		    W_MnDisable( WHandle, MNPRGMS );
		    W_MnEnable( WHandle, MNPRGTEMP );
		    W_MnEnable( WHandle, MNPRGSENSOR );
			break;
		case TABPAGEMS :
			Arbre[TABCTRLTEMP].ob_state	|=	SELECTED;
			Arbre[TABCTRLUPD].ob_state	|=	SELECTED;
			Arbre[TABCTRLMS].ob_state	&=	~SELECTED;
			Arbre[TABCTRLKB].ob_state	|=	SELECTED;
		    W_MnUnCheck	( WHandle, MNUPD );
    		W_MnUnCheck	( WHandle, MNTEMP );
		    W_MnCheck	( WHandle, MNMS );
		    W_MnUnCheck	( WHandle, MNKB );
		    W_MnDisable( WHandle, MNPRGFL );
		    W_MnDisable( WHandle, MNPRGKB );
		    W_MnEnable( WHandle, MNPRGMS );
		    W_MnDisable( WHandle, MNPRGTEMP );
		    W_MnDisable( WHandle, MNPRGSENSOR );
			break;
		default :
			Arbre[TABCTRLTEMP].ob_state	|=	SELECTED;
			Arbre[TABCTRLMS].ob_state	|=	SELECTED;
			Arbre[TABCTRLUPD].ob_state	|=	SELECTED;
			Arbre[TABCTRLKB].ob_state	&=	~SELECTED;
		    W_MnUnCheck	( WHandle, MNUPD );
    		W_MnUnCheck	( WHandle, MNTEMP );
		    W_MnUnCheck	( WHandle, MNMS );
		    W_MnCheck	( WHandle, MNKB );
		    W_MnDisable( WHandle, MNPRGFL );
		    W_MnEnable( WHandle, MNPRGKB );
		    W_MnDisable( WHandle, MNPRGMS );
		    W_MnDisable( WHandle, MNPRGTEMP );
		    W_MnDisable( WHandle, MNPRGSENSOR );
			break;
	} 

    W_WorkXYWH( WHandle, &x, &y, &w, &h );
    objc_draw( Arbre, NewTabPage, 10, x, y, w, h);
    objc_draw( Arbre, TABCTRLTEMP, 1, x, y, w, h);
    objc_draw( Arbre, TABCTRLUPD, 1, x, y, w, h);
    objc_draw( Arbre, TABCTRLMS, 1, x, y, w, h);
    objc_draw( Arbre, TABCTRLKB, 1, x, y, w, h);

	switch (NewTabPage)
	{
		case TABPAGETEMP :
		case TABPAGEUPD : 
			Arbre[PRGMS].ob_state		|=	DISABLED;
			Arbre[PRGKB].ob_state		|=	DISABLED;
			break;
		case TABPAGEMS :
			Arbre[PRGMS].ob_state	&=	~DISABLED;
			Arbre[PRGKB].ob_state	|=	DISABLED;
			break;
		default :
			Arbre[PRGMS].ob_state	|=	DISABLED;
			Arbre[PRGKB].ob_state	&=	~DISABLED;
			break;
	}
	
	objc_draw( Arbre, PRGMS, 1, x, y, w, h);
	objc_draw( Arbre, PRGKB, 1, x, y, w, h);
	
    ActivePage	=	NewTabPage;
}

/*	--------------------------------------------------------------	*/
/*	--------------------------------------------------------------	*/

void OnExit(void)
{
	Sortir = TRUE;
}
/*	--------------------------------------------------------------	*/
void OnTabCtrl( void )
{
	switch( F_NameObject ) {
	
		case	TABCTRLTEMP:if( ActivePage != TABPAGETEMP )	SwitchTab( TABPAGETEMP );
							break;
		case	TABCTRLMS:	if( ActivePage != TABPAGEMS )	SwitchTab( TABPAGEMS );
							break;
		case	TABCTRLKB:	if( ActivePage != TABPAGEKB )	SwitchTab( TABPAGEKB );
							break;
		case	TABCTRLUPD:	if( ActivePage != TABPAGEUPD )	SwitchTab( TABPAGEUPD );
							break;
		default:			break;
	}
}
/*	--------------------------------------------------------------	*/
void OnScanSelect( void )
{
	switch( F_PopupParent )	{
        /*	scan-code selected for mouse */
    	case BUTTON3:	MSParams.Button3	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case BUTTON4:	MSParams.Button4	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case BUTTON5:	MSParams.Button5	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WHEELUP:  	MSParams.WheelUp	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WHEELDN:  	MSParams.WheelDown	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WHEELLT:  	MSParams.WheelLeft	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WHEELRT:  	MSParams.WheelRight	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
        /*	scan-code selected for keyboard */
    	case F11:		KBParams.f11		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case F12:		KBParams.f12		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case PRNT:		KBParams.PrintScreen=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case SCROLL:	KBParams.Scroll		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case PAUSE:		KBParams.Pause		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WLEFT:		KBParams.WinLeft	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WRIGHT:	KBParams.WinRight	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case WAPP:		KBParams.WinApp		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case VERR:		KBParams.VerrNum	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
    	case ALTGR:		KBParams.AltGR		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
        case PAGEUP:	KBParams.PageUp		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
        case PAGEDN:	KBParams.PageDown	=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
        case END:		KBParams.End		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
        case RUSSE2:	KBParams.Russe		=	GetScanCode( F_PopupParent, F_PopupEntry );	break;
        /* scan-codes Set for keyboard */
		case KBSET:		KBParams.Set		=	GetScanCodesSet( F_PopupParent, F_PopupEntry );	break;
    	default:	   	break;
	}
}
/*	--------------------------------------------------------------	*/
void OnMsProg(void)
/*	Mouse programming */
{
	OBJECT	*Arbre;

    graf_mouse( BUSYBEE, NULL );

	rsrc_gaddr(R_TREE,FMAIN,&Arbre);
	MSParams.WheelScroll	=	atoi(Arbre[ REPEAT ].ob_spec.tedinfo->te_ptext);
	MSParams.WheelScroll	=	( MSParams.WheelScroll > 0 && MSParams.WheelScroll <= 9 ) ? MSParams.WheelScroll : DEF_WHREPEAT;

	sendProgMouse( IDX_WHEELUP, MSParams.WheelUp );
	sendProgMouse( IDX_WHEELDN, MSParams.WheelDown );
	sendProgMouse( IDX_WHEELLT, MSParams.WheelLeft );
	sendProgMouse( IDX_WHEELRT, MSParams.WheelRight );              
	sendProgMouse( IDX_BUTTON3, MSParams.Button3 );                 
	sendProgMouse( IDX_BUTTON4, MSParams.Button4 );                 
	sendProgMouse( IDX_BUTTON5, MSParams.Button5 );                 
	sendProgMouse( IDX_WHREPEAT,MSParams.WheelScroll );             
                                                                    
	sendReset();                                                    
                                                                    
	graf_mouse( ARROW, NULL );                                      
}
/*	--------------------------------------------------------------	*/
void OnKbProg(void)
{
    graf_mouse( BUSYBEE, NULL );

    sendProgKeyboard( IDX_F11, 			KBParams.f11 );
    sendProgKeyboard( IDX_F12, 			KBParams.f12 );
    sendProgKeyboard( IDX_PRNTSCREEN, 	KBParams.PrintScreen );
    sendProgKeyboard( IDX_SCROLL, 		KBParams.Scroll );
    sendProgKeyboard( IDX_PAUSE, 		KBParams.Pause );
    sendProgKeyboard( IDX_WLEFT, 		KBParams.WinLeft );
    sendProgKeyboard( IDX_WRIGHT, 		KBParams.WinRight );
    sendProgKeyboard( IDX_WAPP, 		KBParams.WinApp );
    sendProgKeyboard( IDX_VERRN, 		KBParams.VerrNum );
    sendProgKeyboard( IDX_ALTGR, 		KBParams.AltGR );
    sendProgKeyboard( IDX_PAGEUP, 		KBParams.PageUp );
    sendProgKeyboard( IDX_PAGEDN,   	KBParams.PageDown );
    sendProgKeyboard( IDX_END, 			KBParams.End );
    sendProgKeyboard( IDX_RUSSE, 		KBParams.Russe );

	sendReset();
	graf_mouse( ARROW, NULL );
}
/*	--------------------------------------------------------------	*/
void OnInitKb(void)
{
    static unsigned char Tab_Scan_Codes[0x90]= {
    0x00, /* offset + 0x00  jamais utilise: "Error or Buffer Overflow" */
    0x00, /* offset + 0x01  jamais utilise */
    0x00, /* offset + 0x02  jamais utilise */
    0x00, /* offset + 0x03  jamais utilise */
    0x00, /* offset + 0x04  jamais utilise */
    0x00, /* offset + 0x05  jamais utilise */
    0x00, /* offset + 0x06  jamais utilise */
    0x3B, /* offset + 0x07 F1 */
    0x01, /* offset + 0x08 ESC */
    0x00, /* offset + 0x09  jamais utilise */
    0x00, /* offset + 0x0A  jamais utilise */
    0x00, /* offset + 0x0B  jamais utilise */
    0x00, /* offset + 0x0C  jamais utilise */
    0x0F, /* offset + 0x0D TABULATION */
    DEF_RUSSE, /* offset + 0x0E <2> ( a cote de & ) */
    0x3C, /* offset + 0x0F F2 */
    0x00, /* offset + 0x10  jamais utilise */
    0x1D, /* offset + 0x11 LEFT CTRL (Atari en n'a qu'un) */
    0x2A, /* offset + 0x12 LEFT SHFT */
    0x60, /* offset + 0x13 >< */
    0x3A, /* offset + 0x14 CAPS */
    0x10, /* offset + 0x15 A (lettre) */
    0x02, /* offset + 0x16 1 (chiffre UN ) */
    0x3D, /* offset + 0x17 F3 */
    0x00, /* offset + 0x18  jamais utilise */
    DEF_ALTGR, /* offset + 0x19 LEFT ALT (Atari en n'a qu'un) */
    0x2C, /* offset + 0x1A W */
    0x1F, /* offset + 0x1B S */
    0x1E, /* offset + 0x1C Q */
    0x11, /* offset + 0x1D Z */
    0x03, /* offset + 0x1E 2 */
    0x3E, /* offset + 0x1F F4 */
    0x00, /* offset + 0x20  jamais utilise */
    0x2E, /* offset + 0x21 C */
    0x2D, /* offset + 0x22 X */
    0x20, /* offset + 0x23 D */
    0x12, /* offset + 0x24 E */
    0x05, /* offset + 0x25 4 */
    0x04, /* offset + 0x26 3 */
    0x3F, /* offset + 0x27 F5 */
    0x00, /* offset + 0x28  jamais utilise */
    0x39, /* offset + 0x29 SPACE BAR */
    0x2F, /* offset + 0x2A V */
    0x21, /* offset + 0x2B F */
    0x14, /* offset + 0x2C T */
    0x13, /* offset + 0x2D R */
    0x06, /* offset + 0x2E 5 */
    0x40, /* offset + 0x2F F6 */
    0x00, /* offset + 0x30  jamais utilise */
    0x31, /* offset + 0x31 N */
    0x30, /* offset + 0x32 B */
    0x23, /* offset + 0x33 H */
    0x22, /* offset + 0x34 G */
    0x15, /* offset + 0x35 Y */
    0x07, /* offset + 0x36 6 */
    0x41, /* offset + 0x37 F7 */
    0x00, /* offset + 0x38  jamais utilise */
    DEF_ALTGR, /* offset + 0x39 RIGHT ALT GR (Atari en n'a qu'un) */
    0x32, /* offset + 0x3A <,> */
    0x24, /* offset + 0x3B J */
    0x16, /* offset + 0x3C U */
    0x08, /* offset + 0x3D 7 */
    0x09, /* offset + 0x3E 8 */
    0x42, /* offset + 0x3F F8 */
    0x00, /* offset + 0x40  jamais utilise */
    0x33, /* offset + 0x41 <;> */
    0x25, /* offset + 0x42 K */
    0x17, /* offset + 0x43 I */
    0x18, /* offset + 0x44 O (lettre O ) */
    0x0B, /* offset + 0x45 0 (chiffre ZERO ) */
    0x0A, /* offset + 0x46 9 */
    0x43, /* offset + 0x47 F9 */
    0x00, /* offset + 0x48  jamais utilise */
    0x34, /* offset + 0x49 <:> */
    0x35, /* offset + 0x4A <!> */
    0x26, /* offset + 0x4B L */
    0x27, /* offset + 0x4C M */
    0x19, /* offset + 0x4D P */
    0x0C, /* offset + 0x4E <)> */
    0x44, /* offset + 0x4F F10 */
    0x00, /* offset + 0x50  jamais utilise */
    0x00, /* offset + 0x51  jamais utilise */
    0x28, /* offset + 0x52 <—> */
    0x2B, /* offset + 0x53 <*> touche sur COMPAQ */
    0x1A, /* offset + 0x54 <^> */
    0x0D, /* offset + 0x55 <=> */
    0x62, /* offset + 0x56 F11          <= HELP ATARI (Fr) */
    DEF_PRINTSCREEN, /* offset + 0x57 PRINT SCREEN */
    0x1D, /* offset + 0x58 RIGHT CTRL   (Atari en n'a qu'un) */
    0x36, /* offset + 0x59 RIGHT SHIFT */
    0x1C, /* offset + 0x5A RETURN */
    0x1B, /* offset + 0x5B <$> */
    0x2B, /* offset + 0x5C <*> touche sur SOFT KEY */
    0x00, /* offset + 0x5D  jamais utilise */
    DEF_F12, /* offset + 0x5E F12          <= UNDO ATARI (Fr) */
    DEF_SCROLL, /* offset + 0x5F SCROLL */
    0x50, /* offset + 0x60 DOWN ARROW */
    0x4B, /* offset + 0x61 LEFT ARROW */
    DEF_PAUSE, /* offset + 0x62 PAUSE */
    0x48, /* offset + 0x63 UP ARROW */
    0x53, /* offset + 0x64 DELETE */
    0x55, /* offset + 0x65 END */
    0x0E, /* offset + 0x66 BACKSPACE */
    0x52, /* offset + 0x67 INSERT */
    0x00, /* offset + 0x68  jamais utilise */
    0x6D, /* offset + 0x69 KP 1 (UN) */
    0x4D, /* offset + 0x6A RIGHT ARROW */
    0x6A, /* offset + 0x6B KP 4 */
    0x67, /* offset + 0x6C KP 7 */
    DEF_PAGEDN, /* offset + 0x6D PAGE DOWN    (unused on Atari before) */
    0x47, /* offset + 0x6E CLEAR HOME */
    DEF_PAGEUP, /* offset + 0x6F PAGE UP      (unused on Atari before) */
    0x70, /* offset + 0x70 KP 0 (ZERO) */
    0x71, /* offset + 0x71 KP . */
    0x6E, /* offset + 0x72 KP 2 */
    0x6B, /* offset + 0x73 KP 5 */
    0x6C, /* offset + 0x74 KP 6 */
    0x68, /* offset + 0x75 KP 8 */
    DEF_VERRNUM, /* offset + 0x76 VERR NUM     (unused on Atari before) */
    0x65, /* offset + 0x77 KP / */
    0x00, /* offset + 0x78  jamais utilise */
    0x72, /* offset + 0x79 KP ENTER */
    0x6F, /* offset + 0x7A KP 3 */
    0x00, /* offset + 0x7B  jamais utilise */
    0x4E, /* offset + 0x7C KP + */
    0x69, /* offset + 0x7D KP 9 */
    0x66, /* offset + 0x7E KP * */
    DEF_SLEEP, /* offset + 0x7F SLEEP Eiffel 1.0.5 */
    0x00, /* offset + 0x80  jamais utilise */
    0x00, /* offset + 0x81  jamais utilise */
    0x00, /* offset + 0x82  jamais utilise */
    0x00, /* offset + 0x83  jamais utilise */
    0x4A, /* offset + 0x84 KP - */
    0x00, /* offset + 0x85  jamais utilise */
    0x00, /* offset + 0x86  jamais utilise */
    0x00, /* offset + 0x87  jamais utilise */
    0x00, /* offset + 0x88  jamais utilise */
    0x00, /* offset + 0x89  jamais utilise */
    0x00, /* offset + 0x8A  jamais utilise */
    DEF_WINLEFT, /*  offset + 0x8B LEFT WIN */
    DEF_WINRIGHT, /* offset + 0x8C RIGHT WIN */
    DEF_WINAPP, /*   offset + 0x8D POPUP WIN */
    0x00, /* offset + 0x8E  jamais utilise */
    0x00  /* offset + 0x8F  jamais utilise */
    };
    int i;
    
	if( form_alert( 1, "[3][ Init Eiffel keyboard table ? ][Ok|Cancel]" ) == 1 )
	{
	    graf_mouse( BUSYBEE, NULL );
   		for(i=0;i<0x90;i++)
      		sendProgKeyboard( i, (unsigned int)Tab_Scan_Codes[i] );
    	sendReset();
    	graf_mouse( ARROW, NULL );
    }
}
/*	--------------------------------------------------------------	*/
void OnLoadKb(void)
{
	static unsigned char Tab_Scan_Codes[0x90];
	int 					i,handle,val;
	long 					longueur, offset;
	void 					*buffer;
	unsigned char 			*ptr;
    
	if( form_alert( 1, "[3][ Load Eiffel keyboard table ? ][Ok|Cancel]" ) == 1 )
	{
		if(A_FileSelector( PathNameInf, FileNameUnShift, ExtensionInf, Path, "Select a INF file..."))
		{
			graf_mouse( BUSYBEE, NULL );
			if( ( handle=Fopen( PathNameInf, 0) ) < 0 )
				form_error(-handle-31);
			else
			{
				if ((longueur=Fseek(0L,handle,2))>=0)
				{
					Fseek(0L,handle,0);
					if ((buffer=Malloc(longueur))<0)
						form_error(-(int)buffer-31);
					else
					{
						if (Fread(handle,longueur,buffer)<0) /* lecture du .INF */
							form_error(-handle-31);
						else
						{
							offset=0;
							ptr=(unsigned char *)buffer;
							do
							{
								if(*ptr++ == ':') 
								{
									val=lect_hex(ptr);
									if(val>=0)
									{ 
										Tab_Scan_Codes[offset++]=val;
										ptr+=2;
									}
								}
							}
							while(offset<0x90 && (ptr < (unsigned char *)buffer+longueur));
						}
						Mfree(buffer);
					}
					Fclose(handle);
				}
			}
			for(i=0;i<0x90;i++)
				sendProgKeyboard( i, (unsigned int)Tab_Scan_Codes[i] );
			sendReset();
			graf_mouse( ARROW, NULL );
		}
	}
}
/*	--------------------------------------------------------------	*/
void OnLoadHex( void )
{
	OBJECT	*Arbre;
	int		i, x, y, w, h;
	
	rsrc_gaddr(R_TREE,FMAIN,&Arbre);

	ValidHex	=	A_FileSelector( PathName, FileName, Extension, Path, "Select a HEX file...");
	if( ValidHex ) {
		Arbre[LOADSHIFT].ob_state	&=	~DISABLED;
		Arbre[LOADALTGR].ob_state	&=	~DISABLED;
		Arbre[LOADMOD].ob_state	&=	~DISABLED;
		Arbre[PRGFL].ob_state	&=	~DISABLED;
		W_MnEnable( WHandle, MNPRGFL );
	  for(i=0;i<0x90;shift[i]=altgr[i]=modifier[i]=0,i++);
	}
	else {
		Arbre[LOADSHIFT].ob_state	|=	DISABLED;
		Arbre[LOADALTGR].ob_state	|=	DISABLED;
		Arbre[LOADMOD].ob_state	|=	DISABLED;
		Arbre[PRGFL].ob_state	|=	DISABLED;
		W_MnDisable( WHandle, MNPRGFL );
	}	

    W_WorkXYWH( WHandle, &x, &y, &w, &h );
    objc_draw( Arbre, LOADSHIFT, 1, x, y, w, h);
    objc_draw( Arbre, LOADALTGR, 1, x, y, w, h);
    objc_draw( Arbre, LOADMOD, 1, x, y, w, h);
    objc_draw( Arbre, PRGFL, 1, x, y, w, h);
}
/*	--------------------------------------------------------------	*/
void OnLoadShift( void )
{
	if( ValidHex )
	{
		if( form_alert( 1, "[3][ Load user Shift| table to the firmware ? ][Ok|Cancel]" ) == 1 )
		{
			if(A_FileSelector( PathNameInf, FileNameShift, ExtensionInf, Path, "Select a Shift.INF file..."))
			{
		   		graf_mouse( BUSYBEE, NULL );
		   		ChangeTable( PathNameInf, shift );
	    		graf_mouse( ARROW, NULL );
	    	}
	    }
	}
	else
		form_alert( 1, "[3][ Select a HEX file for Eiffel before ][ Ok ]" )	;
}
/*	--------------------------------------------------------------	*/
void OnLoadAltGr( void )
{
	if( ValidHex )
	{
		if( form_alert( 1, "[3][ Load user AltGr| table to the firmware ? ][Ok|Cancel]" ) == 1 )
		{
			if(A_FileSelector( PathNameInf, FileNameAltGr, ExtensionInf, Path, "Select a AltGr.INF file..."))
			{
		   		graf_mouse( BUSYBEE, NULL );
		   		ChangeTable( PathNameInf, altgr );
	    		graf_mouse( ARROW, NULL );
	    	}
	    }
	}
	else
		form_alert( 1, "[3][ Select a HEX file for Eiffel before ][ Ok ]" )	;
}
/*	--------------------------------------------------------------	*/
void OnLoadModifier( void )
{
	if( ValidHex )
	{
		if( form_alert( 1, "[3][ Load user Modidier| table to the firmware ? ][Ok|Cancel]" ) == 1 )
		{
			if(A_FileSelector( PathNameInf, FileNameModifier, ExtensionInf, Path, "Select a Modifier.INF file..."))
			{
		   		graf_mouse( BUSYBEE, NULL );
		   		ChangeTable( PathNameInf, modifier);
	    		graf_mouse( ARROW, NULL );
	    	}
	    }
	}
	else
		form_alert( 1, "[3][ Select a HEX file for Eiffel before ][ Ok ]" )	;
}
/*	--------------------------------------------------------------	*/
void OnUpdate( void )
{
	if( ValidHex ) {
		if( form_alert( 1, "[3][ Update now Eiffel firmware ? ][Ok|Cancel]" ) == 1 ) {
		    graf_mouse( BUSYBEE, NULL );
		    UpdateEiffel( PathName );
	    	graf_mouse( ARROW, NULL );
	    }
	}
	else {
		form_alert( 1, "[3][ Select a HEX file for Eiffel before ][ Ok ]" )	;
	}
}

/*	--------------------------------------------------------------	*/
void OnTempProg(void)
/*	Temperature programming */
{
	OBJECT	*Arbre;
	int		x, y, w, h;

    graf_mouse( BUSYBEE, NULL );

	rsrc_gaddr(R_TREE,FMAIN,&Arbre);
	TEMPParams.LevelHTemp	=	atoi(Arbre[ LEVELHTEMP ].ob_spec.tedinfo->te_ptext);
	TEMPParams.LevelHTemp	=	( TEMPParams.LevelHTemp <= 99 ) ? TEMPParams.LevelHTemp : DEF_LEVELHTEMP;
	TEMPParams.LevelLTemp	=	atoi(Arbre[ LEVELLTEMP ].ob_spec.tedinfo->te_ptext);
	TEMPParams.LevelLTemp	=	( TEMPParams.LevelLTemp <= 99 ) ? TEMPParams.LevelLTemp : DEF_LEVELLTEMP;

	sendProgTemp( IDX_LEVELHTEMP, TEMPParams.LevelHTemp );
	sendProgTemp( IDX_LEVELLTEMP, TEMPParams.LevelLTemp );

	getTemp();
    W_WorkXYWH( WHandle, &x, &y, &w, &h );
	objc_draw( Arbre, AFFTEMP, 1, x, y, w, h);
	                                                                                             
	graf_mouse( ARROW, NULL );                                      
}
/*	--------------------------------------------------------------	*/
void OnSensProg(void)
/*	Sensor programming */
{
	OBJECT	*Arbre;
	int i,j;
	static int tab_objc_rctn[12]={RCTN1,RCTN2,RCTN3,RCTN4,RCTN5,RCTN6,RCTN7,RCTN8,RCTN9,RCTN10,RCTN11,RCTN12};
	static int tab_objc_temp[12]={TEMP1,TEMP2,TEMP3,TEMP4,TEMP5,TEMP6,TEMP7,TEMP8,TEMP9,TEMP10,TEMP11,TEMP12};
	static int tab_valdef_rctn[12]={DEF_RCTN1,DEF_RCTN2,DEF_RCTN3,DEF_RCTN4,DEF_RCTN5,DEF_RCTN6,
	                                DEF_RCTN7,DEF_RCTN8,DEF_RCTN9,DEF_RCTN10,DEF_RCTN11,DEF_RCTN12};

    graf_mouse( BUSYBEE, NULL );

	rsrc_gaddr(R_TREE,FMAIN,&Arbre);
	for(i=j=0;i<12;i++,j+=2)
	{
		TEMPParams.Rctn[i]	=	atoi(Arbre[tab_objc_rctn[i]].ob_spec.tedinfo->te_ptext);
		TEMPParams.Rctn[i]	=	( TEMPParams.Rctn[i] <= 25500 ) ? TEMPParams.Rctn[i] : tab_valdef_rctn[i];
		TEMPParams.Temp[i]	=	atoi(Arbre[tab_objc_temp[i]].ob_spec.tedinfo->te_ptext);
		sendProgTemp( IDX_TAB_CTN+j, TEMPParams.Rctn[i]/100 );
		sendProgTemp( IDX_TAB_CTN+j+1, TEMPParams.Temp[i] );
	}
                                                                    
	graf_mouse( ARROW, NULL );                                      
}
/*	--------------------------------------------------------------	*/
void OnReset(void)
{
	sendScanCodesSet();
	sendReset();
}
/*	--------------------------------------------------------------	*/
void OnMenuItem( int aWinHandle )
{
	if(aWinHandle);
   	switch( W_MenuItem ) {
    	case	MNRESET:OnReset();
	    				break;

    	case	MNPRGMS:OnMsProg();
	    				break;

    	case	MNPRGKB:OnKbProg();
						break;

    	case	MNPRGTEMP:OnTempProg();
						break;

    	case	MNPRGSENSOR:OnSensProg();
						break;

    	case	MNLOADHEX:OnLoadHex();
						break;

    	case	MNPRGFL:OnUpdate();
						break;
						
    	case	MNMS:	if( ActivePage != TABPAGEMS )	SwitchTab( TABPAGEMS );
	    				break;

    	case	MNKB:	if( ActivePage != TABPAGEKB )	SwitchTab( TABPAGEKB );
	    				break;

		case	MNTEMP:	if( ActivePage != TABPAGETEMP )	SwitchTab( TABPAGETEMP );
	    				break;

		case	MNUPD:	if( ActivePage != TABPAGEUPD )	SwitchTab( TABPAGEUPD );
						break;
						
        case	MNQUIT:	OnExit();
                        break;

        case	MNABOUT:OnAbout();
                        break;
	}
}

/*	--------------------------------------------------------------	*/
/*	--------------------------------------------------------------	*/

void InitGUI( void )
{
	Type_Formular_Parameter	*Parameter;
	OBJECT					*Arbre;

    W_Init();							                        /* Init Window  */
    M_Init();							                        /* Init Menu    */
    F_Init();							                        /* Init Form    */
    graf_mouse(ARROW,NULL);				                        /* just for fun */
    W_SetIconApp(IAPPLI);				                        /* Set Icon Form Appli. */

	rsrc_gaddr( R_TREE, FMAIN, &Arbre );
    Arbre[ TABPAGEMS ].ob_flags		|=	HIDETREE;
    Arbre[ TABPAGEKB ].ob_flags		|=	HIDETREE;
    Arbre[ TABPAGETEMP ].ob_flags	|=	HIDETREE;
    Arbre[ TABPAGEUPD ].ob_flags	|=	HIDETREE;

	SetDefault();
	DisplayDefault();

	ActivePage	=	TABPAGEKB;
	SwitchTab( TABPAGEMS );

    F_PopAttach(FMAIN,ListPopAttach);							/* Attach Pop-ups */
    F_PopEvent(ListPopEvent);									/* Install Pop-events */

	getTemp();
	
    /*
    *	Opening Main formular
    */
    Parameter = F_GetParameter();
    if(Parameter != NULL)
    {
        Parameter->TreeName = FMAIN;
        Parameter->Title	= "Eiffel Control Pannel";			/* Formular's title */
        Parameter->Mode		= F_WIND;				            /* Opening mode */
        Parameter->FirstEdit= NOTEXT;				            /* First Editable Text */
        Parameter->List		= FormMain;				            /* Event list */
        Parameter->FormIcon = ISETUP;

        WHandle		=	F_XOpen(Parameter);
      	W_MenuOpen( WHandle, MMAIN , WMenu);

        free(Parameter);
    }
}
/*	--------------------------------------------------------------	*/
void ExitGUI( void )
{
    W_MenuClose( WHandle );
    F_Close(FINFO);
    F_Close(FMAIN);

    W_Exit();
    M_Exit();
    F_Exit();

    A_Close();							                        /* Close Application	*/
}
/*	--------------------------------------------------------------	*/
int main(void)
{
    if(!A_Open(FILERSC))
    {
        form_alert(1,"[1][ | file "FILERSC" not found ][ Ok ]");
        A_Close();
        return( -ERSC );										/* Quit immediatly */
    }
    if(VdiInfo.HauteurStation < HAUTEURMIN || VdiInfo.LargeurStation < LARGEURMIN)
    {
        form_alert(1,"[1][ Bad screen display | 640 x 400 required ][ Ok ]");
        A_Close();
        return( -ESCR );
    }

    InitGUI();							                    	/* Ouvre Main Form */
    Sortir = FALSE;
    do
    {
        A_WaitEvent();						                    /* Waiting an event	*/
        F_Event();							                    /* Form Event 		*/
        M_Event();							                    /* Menu Event		*/
        W_Event();							                    /* Window Event		*/
    }
    while(!Sortir);

	ExitGUI();
    return(NON_ERROR);					                        /* for the shell 	*/
}
/*	--------------------------------------------------------------	*/
