/*
 *			Fun Falcon 030 Release 1.41
 *			A simple application example with AADS.
 *				
 *	Author  : FunShip
 *	Date    : 28 January 1995
 *	Revision: 17 January 1996
 *	Version : 1.41
 *
 *	For ATARI Falcon030 Only, or another machine with a CrossBar.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <float.h>

#include "F:\Aads.030\Include\Falcon30.h"
#include "F:\Aads.030\Include\PCAADS.h"

#include "FUN__30F.h"

/*
 *	From Vumeter.c
 */
 
extern	void LevelDisplay(int x_rec,int y_rec,int w_rec,int h_rec);
extern	void QuickDisplay(void);

/*
 * ----------------------- Some definitions -------------------------------
 */

#define	XMIN		639			/* Resolution required */
#define	YMIN		399
#define	COLORS		16			/* numbers colors required */

#define	VERSNUMBER	"1.41"
#define	VERSDATE	"15011995"
#define	RESSOURCE	"Fun__30?.Rsc"

#define	TIMER		25			/* Time DownCount for timer */
#define	MIN		0x0000			/* minimal value Db */
#define	MAX		0x00F0			/* Max. value Db */
#define TAILLETAMPON	20L			/* Buffer size in bytes */
#define	PAS_DB		8			/* +/- 1.5 dB = +/- 8 */

#define	ACC_NAME	"  Fun Falcon030"	/* Name into desktop menu bar */

/*
 *	Variables globales
 */ 

static	char		WindowTitle[]="Fun Falcon 030";
static  int		Sortir;			/* to exit program */
static  int		LtAtten,		/* valeurs des gains */
			RtAtten,		/* et att‚nuations */
			LtGain,
			RtGain;
static	int		SourceAnalogique;	/* Source = Micro,PSGL/R */
static  int		dsp_on;			/* Use or not Dsp */

static  char db[16][5]	= {"00.0\0","01.5\0","03.0\0","04.5\0","06.0\0","07.5\0","09.0\0","10.5\0",
		    	   "12.0\0","13.5\0","15.0\0","16.5\0","18.0\0","19.5\0","21.0\0","22.5\0"};

	signed int	*Tampon;		/* DMA record area */
static	long		Tamponend;		
	OBJECT		*ArbreDisplay;		/* Arbre d'objets vu-mŠtres */
static	int		Handle;			/* Handle du formulaire principal */

static	int		NombreClicPhoto;	/* Pour la photo cach‚e */
		 
/*
 * --------------------- Descriptions des Formulaires ------------------
 */  

void Quitter(void);
void Dsp(void);
void Play(void);
void Stop(void);
void CursorVolume(void);
void CutChannel(void);


/*
 *	Note: the very first procedure (here 'cancel') will be call
 *	when you clic the Window's closer button also !!
 *	In this case, FM1CANCEL will be emulate
 */
Type_Form_List
MainList[]=	{	{QUITTER	,Quitter	,NULL},

			{BDSP		,Dsp		,NULL},
			{BPLAY	  	,Play		,NULL},
			{BSTOP	 	,Stop		,NULL},
			
			{CURSORLI	,CursorVolume	,NULL},
			{CURSORRI	,CursorVolume	,NULL},
			{CURSORLO	,CursorVolume	,NULL},
			{CURSORRO	,CursorVolume	,NULL},
			
			{LEFT		,CutChannel	,NULL},
			{RIGHT		,CutChannel	,NULL},
	
			FORM_END
		};

void Confirm(void);
void PhotoCachee(void);

Type_Form_List
InfoList[]=	{	{FORM2EXIT	,Confirm	,PhotoCachee},
			FORM_END
		};

/*
 * ------------------------------------------------------------------------------------
 *					Built-in menu
 */
 
void ExecMenu(int WindowHandle);

static Type_Window_Menu_List
MenuList[]=	{	
			{ABOUT	,INITIAL,ExecMenu},			/* Entry about me */
			{ENDE   ,INITIAL,ExecMenu},			/* Entry Quit */
			WMENU_END
		};

/*
 * --------------------------------- Primitives diverses ------------------------------
 */


void Afficher(int Cadran,int Valeur)
/*
	Affiche la valeurs des Gain et Attenuations dans les champs textes respectifs.

	Entree:	Cadran	= Numero d'ordre d'objet du champ
		Valeur	= Valeur de Gain/Attenuation tel que: 0x00X0
	Sortie: Rien
*/
{
  switch(Cadran)
  {
    case VLI:	F_WriteText(FMAIN,VLI,db[Valeur>>4]);
    		break;
    case VRI:	F_WriteText(FMAIN,VRI,db[Valeur>>4]);
    		break;
    case VLO:	F_WriteText(FMAIN,VLO,db[Valeur>>4]);
    		break;
    case VRO:	F_WriteText(FMAIN,VRO,db[Valeur>>4]);
    		break;
  }
}

/*
 * ------------------------ Methodes des objects graphiques ------------------------------
 */
 
void Confirm(void)
/*
	Ferme la fenetre information sur clic bouton 'Confirmer'

	Entree:	rien
	Sortie:	rien
*/
{
  OBJECT	*Arbre;
  
  rsrc_gaddr(R_TREE,FINFO,&Arbre);			/* Cache la photo */
  Arbre[PHOTO].ob_flags |= HIDETREE;
  F_Close(FINFO);
}

void PhotoCachee(void)
/*
	Lors d'un Double-Clic sur Confirmer de la fenetre information
*/
{
  OBJECT	*Arbre;
  
  if(NombreClicPhoto == 3)		/* Rendre la photo visible */
  {
      rsrc_gaddr(R_TREE,FINFO,&Arbre);	/* Bit cach‚ Off */
      Arbre[PHOTO].ob_flags &= ~HIDETREE;	
      F_RedrawObject(Arbre,PHOTO);	/* Redessiner la photo */
      NombreClicPhoto = 1;
  } 
  else					/* Compter le nombre de DbClics */
    NombreClicPhoto++;
}

void Quitter(void)
/*
	Ferme toutes les fenetres de l'application possible, qui pourrait etre ouvertes.

	Entree:	rien
	Sortie:	rien
*/
{
  Sortir = TRUE;
  F_Close(FMAIN);
  F_Close(FINFO);
}

void Information(void)
/*
	Ouvre la fenetre information du programme

	Entree:	rien
	Sortie:	rien
*/
{
  Type_Formular_Parameter	*Parameter;
  char				Title[1]="";
  int				Handle;
  
  Parameter = F_GetParameter();					/* Get block parameter */
  if(Parameter != NULL)
  {
    Parameter->TreeName = FINFO;
    Parameter->Title	= Title;				/* Formular's title */
    Parameter->Mode	= F_WIND;				/* Opening mode */
    Parameter->FirstEdit= NOTEXT;				/* First Editable Text */
    Parameter->List	= InfoList;				/* Event list */
    Parameter->FormIcon = IINFO;				/* Its icon */
    Parameter->Mouse	= MS_HELP;				/* Window's mouse cursor shape */
    Handle = F_XOpen(Parameter);
    if(Handle < 0)						/* fatal error */
      form_alert(1,"[3][ Unable to open the window ][Ok]");

    free(Parameter);
    F_WriteText(FINFO,VERSION,VERSNUMBER);
    F_WriteText(FINFO,DATEVER,VERSDATE);
  }
}

/*
 * ------------------------------------------------------------------------------------
 *				Handle the built-in menu
 */

void ExecMenu(int WindowHandle)
/*
	Handle built-in menu event selection.
*/
{
  if(WindowHandle == Handle)			/* if it's the main window */
  {
    switch(W_MenuItem)
    {
      case ABOUT:	Information();
      			break;
      case ENDE:	Quitter();
      			break;
      default:		break;
    }
  }
}


/*
 * ----------------- Gestion des boutons du panneau de commandes -----------------------
 */
 
void Dsp(void)
/*
	Active ou Inhibe l'utilisation du Dsp dans la matrice.
	Place le boolean Dsp_On sur Vrai et rapelle le traitement de Play.
*/
{
  dsp_on =~dsp_on;
  Play();
}

void Play(void)
/*
	Ordre de mise en marche du son, avec ou sans Dsp.
*/
{
  if(!dsp_on)						/* Matrice = <ADC,DAC> */
  {
    Devconnect(ADC,DAC+DMAREC,CLK25M,CLK50K,NOHANDSHAKE);
    F_UnSelect(FMAIN,BDSP);
  }
  else							/* Matrice = <ADC,DSP,DAC> */
  {
    Devconnect(ADC,DSPRECV,CLK25M,CLK50K,NOHANDSHAKE);
    Devconnect(DSPXMIT,DAC+DMAREC,CLK25M,CLK50K,NOHANDSHAKE);
    F_Select(FMAIN,BDSP);
  }
  Soundcmd(ADCINPUT,SourceAnalogique);			/* SourceAnalogique => ADC */
  Buffoper(OPER_REC | OPER_REC_LOOP);			/* Reactive le DMA record */
  
  F_Select(FMAIN,BPLAY);
  F_UnSelect(FMAIN,BSTOP);
}

void Stop(void)
/*
	Coupe le lecture de la SourceAnalogique sonore. Branche sur l'Additionner le PSG
	gauche et droite, en supprimant le micro.
	Stoppe le DMA Record et Inhibe le Timer event.
*/
{
  Soundcmd(ADCINPUT,PSGRT+PSGLT);			/* Cut off micro input */
  Buffoper(OPER_OFF);					/* Stop DMA record */

  Tampon[0]=0;
  Tampon[1]=0;
  
  F_Select(FMAIN,BSTOP);
  F_UnSelect(FMAIN,BPLAY);
}

/*
 * ---------------- Gestion du volume par le mouvement des curseurs ----------------
 */
 
int LireGain(int Boite, int Curseur)
/*
	Calcul le Gain ou Attenuation suivant la position des curseurs.
*/
{
  int		Gain,Position;
  OBJECT	*Arbre;
  
  rsrc_gaddr(FMAIN,R_TREE,&Arbre);
  Position = graf_slidebox(Arbre,Boite,Curseur,TRUE);
  Gain = ((int)(MAX-(int)((float)Position * (float)MAX /(float)1000)) & 0x00F0);
  return(Gain);
}

void PlaceCursor(int Gain,int Boite, int Curseur)
/*
	Place un curseur de volume a la position representant le gain ou l'attenuation
	en paramŠtre.
*/
{
  int		Position;
  OBJECT	*Arbre;
  
  rsrc_gaddr(FMAIN,R_TREE,&Arbre);
  Position = (int)( (float)1000 * ((float)MAX - (float)Gain) / (float)MAX );
  Arbre[Curseur].ob_y =(int)((float)((float)Position*(float)(Arbre[Boite].ob_height-Arbre[Curseur].ob_height)/ (float)1000));
  objc_draw(Arbre,Boite,3,Arbre->ob_x,Arbre->ob_y,Arbre->ob_width,Arbre->ob_height);
}

void CursorVolume(void)
/*
	Calcul les nouveaux Gains ou Attenuations suivant les mouvements des
	curseurs.
*/
{
  switch(F_NameObject)
  {
    case CURSORLO:	LtGain = LireGain(BOITELO,CURSORLO);
    			PlaceCursor(LtGain,BOITELO,CURSORLO);
			Afficher(VLO,LtGain);
			Soundcmd(LTGAIN,LtGain);
			break;
    case CURSORRO:	RtGain = LireGain(BOITERO,CURSORRO);
    			PlaceCursor(RtGain,BOITERO,CURSORRO);
			Afficher(VRO,RtGain);
			Soundcmd(RTGAIN,RtGain);
			break;
    case CURSORLI:	LtAtten = LireGain(BOITELI,CURSORLI);
    			PlaceCursor(LtAtten,BOITELI,CURSORLI);
			Afficher(VLI,LtAtten);
			Soundcmd(LTATTEN,LtAtten);
			break;
    case CURSORRI:	RtAtten = LireGain(BOITERI,CURSORRI);
    			PlaceCursor(RtAtten,BOITERI,CURSORRI);
			Afficher(VRI,RtAtten);
			Soundcmd(RTATTEN,RtAtten);
			break;
  }
}

void CutChannel(void)
/*
	Coupe la voie gauche ou droite suivant le bouton actionne.
*/
{
  switch(F_NameObject)
  {
    case LEFT:	if(SourceAnalogique & PSGLT)
    		{
    		  F_UnSelect(FMAIN,LEFT);
    		  SourceAnalogique &= ~PSGLT;
    		}
    		else
    		{
    		  F_Select(FMAIN,LEFT);
    		  SourceAnalogique |= PSGLT;
    		}
    		break;
    case RIGHT: if(SourceAnalogique & PSGRT)
    		{
    		  F_UnSelect(FMAIN,RIGHT);
    		  SourceAnalogique &= ~PSGRT;
    		}
    		else
    		{
    		  F_Select(FMAIN,RIGHT);
    		  SourceAnalogique |= PSGRT;
    		}
    		break;
    default:	break;
  }
  Play();
}

void TimerCode(void)
/*
	Cette proc‚dure est appel‚e par un ‚v‚nement Timer de A_Event().
	Elle s'occupe d'afficher les volumes d'entr‚es sur les Vu-MŠtres.
	Si la fenetre est en TOP on appel une proc‚dure d'affichage plus rapide
	mais qui ne tient pas compte de la liste des rectangles.
	
	Entr‚es:	Tampon = Buffer DMA record
			handle = handle de la fenetre porteuse
	Sorties:	rien
*/
{
  int	WindTop,Dummy;
  
  wind_get(DESKTOP,WF_TOP,&WindTop,&Dummy,&Dummy,&Dummy);
  if(WindTop == Handle && !F_EstIconifie(Handle))
    QuickDisplay();
  else
    F_FreeDraw(Handle,LevelDisplay);  
  
  Buffoper(OPER_REC);
}

/*
 * --------------------------- Corps du programme principal -------------------------------
 */

void InitSon(void)
/*
	Branche l'entree externe analogique sur l'ADC.
	Lit les valeurs initiales du systeme.
	Active un DMA record sur le tampon en boucle.
*/
{

  LtAtten = (int)Soundcmd(LTATTEN,0xFFFF);		/* Attenuation initiale ? */
  RtAtten = (int)Soundcmd(RTATTEN,0xFFFF);
  LtGain  = (int)Soundcmd(LTGAIN ,0xFFFF);		/* Gain initiale ? */
  RtGain  = (int)Soundcmd(RTGAIN ,0xFFFF);

  Setmode(STEREO16);					/* Stereo 16 bits */
  Settracks(TRACK0,TRACK0);
  Setmontracks(TRACK0);

  Setbuffer(BUFRECORD,Tampon,Tamponend);		/* Buffer de record */
  Buffoper(OPER_REC);					/* Activer une passe DMA */
}

void InitDisplay(void)
/*
	Affiche les gains et attenuations en dB initiaux au demarrage.
	Place les curseurs sur les bons niveaux.
*/
{
  Afficher(VLI,LtAtten);				/* Ecrire les valeurs textes */
  Afficher(VRI,RtAtten);
  Afficher(VLO,LtGain);
  Afficher(VRO,RtGain);
  PlaceCursor(LtAtten,BOITELI,CURSORLI);		/* Positionne les curseurs */
  PlaceCursor(RtAtten,BOITERI,CURSORRI);
  PlaceCursor(LtGain,BOITELO,CURSORLO);
  PlaceCursor(RtGain,BOITERO,CURSORRO); 
}

/*
 * ------------------------------------------------------------------------------------
 *				Main programs
 */

void Principal(void)
/*
	Main program as Aads application.
*/
{
  OBJECT			*Arbre;
  Type_Formular_Parameter	*Parameter;
    
  InitSon();							/* Initialise le son	*/
  Parameter = F_GetParameter();					/* Get block parameter */
  if(Parameter != NULL)
  {
    Parameter->TreeName = FMAIN;
    Parameter->Title	= WindowTitle;				/* Formular's title */
    Parameter->Mode	= F_WIND;				/* Opening mode */
    Parameter->FirstEdit= NOTEXT;				/* First Editable Text */
    Parameter->List	= MainList;				/* Event list */
    Parameter->FormIcon = IMAIN;				/* Its icon */
    Parameter->Mouse	= ARROW;				/* Window's mouse cursor shape */
    Handle = F_XOpen(Parameter);
    if(Handle < 0)						/* fatal error */
    {
      form_alert(1,"[3][ Unable to open the window ][Ok]");
      return;
    }
    else
      W_MenuOpen(Handle,MAINMENU,MenuList);			/* Opening the built-in menu */  
    free(Parameter);
  }
  else
  {
    form_error(8);						/* Not enough memory */
    return;							/* Exit from here */
  }

  InitDisplay();						/* Affiche Gain,Atten.	*/
  Play();

  rsrc_gaddr(R_TREE,FINFO,&Arbre);				/* Cache la photo */
  Arbre[PHOTO].ob_flags |= HIDETREE;
  NombreClicPhoto = 1;						/* Compte pour photo cach‚e */
  
  A_CycleTimer(0,TIMER);					/* Time to douwncount   */
  A_SetCodeTimer(TimerCode);
  A_OnTimer(); 

  Sortir	= FALSE;
  do
  {
    A_WaitEvent();					/* Waiting an event	*/
    if((A_Event & MU_MESAG) && (A_Message[0] == AC_CLOSE))
    {
      Quitter();
    }
    W_Event();						/* Window Event		*/
    F_Event();						/* Form Event 		*/
    M_Event();						/* Menu Event		*/
   }
  while(!Sortir);
  A_OffTimer();						/* Stopper le Timer 	*/
      
  Buffoper(OPER_OFF);					/* Stopper le DMA	*/
}

int main(void)
/*
	Main program to install it as a application or accessory.
*/
{
  int			Correct;
  int			acc_id;
  int			TamponMessage[8];
  Type_AutoTop		AutoTop;
    
  /*
   *	Verifie si l'environnement est correct
   *		Resolution & Machine
   */

  Correct = FALSE;
  if(!A_Open(RESSOURCE))
  {
    form_alert(1,"[0][ | Fun__30?.Rsc Not found ][Sorry]");
    Correct = FALSE;
  }
  else if(VdiInfo.LargeurStation < XMIN || VdiInfo.HauteurStation < YMIN)				/* Station VDI size required */
  {
    form_alert(1,"[0][ Fun Falcon 030 Error: | At least 640x400 ][Sorry]");
    Correct = FALSE;
  }
  else if(VdiInfo.NombreCouleurs < COLORS)								/* Number of colours */
  {
    form_alert(1,"[0][ Fun Falcon 030 Error:| At least 16 colors ][ok]");
    Correct = FALSE;
  }
  else if(!(MchInfo.Sound & MATRICE) || !(MchInfo.Sound & CODEC))					/* Sound system reqired */
  {
    form_alert(1,"[0][ Fun Falcon 030 Error: | Matrix and Codec required ][Sorry]");
    Correct = FALSE;
  }
  else
    Correct = TRUE;

  /*
   *	Initialisation d'AADS
   */  
  W_Init();  
  M_Init();
  F_Init();						/* Init Form    */
  W_SetIconApp(IAPPLI);					/* Application's global icon  */
  A_SetMouse(MS_ATARI,NULL);				/* Application's mouse */
  
  AutoTop.AutoEnable		= TRUE;			/* Mode enable */
  AutoTop.OnlyWorkArea		= FALSE;		/* Entire window */
  AutoTop.NoMouseMovement	= TRUE;			/* Don't top during movement */
  W_AutoTop(&AutoTop);					/* Auto topping window mode */
  
  /*
   *	Initialisation sp‚cifique
   */
  rsrc_gaddr(R_TREE,FMAIN,&ArbreDisplay);		/* Pour piloter les vu-mŠtres */
    
  dsp_on = FALSE;
  SourceAnalogique = MICRO;
  Soundcmd(ADCINPUT,SourceAnalogique);			/* Micro => ADC */

  Tampon = (signed int *)Malloc(TAILLETAMPON);		/* Alloue un petit tampon */
  Tamponend = (long)Tampon + TAILLETAMPON -2L;
  
  if(_app == 0)						/* L'appli. est un .ACC */
  {
    fprintf(stdout,"\n\n\033pAtari Fun Falcon 030 V1.4 accessory\n\033q");
    acc_id = menu_register(AesHandle,ACC_NAME);
    if(acc_id != -1)					/* Au moins une entr‚e de libre */
      fprintf(stdout,"Loading ok...\n");
    else
      fprintf(stdout,"Loading Failled, not enough menu entry\n");
    
    while(1)						/* Boucle infinie Acc‚ssoire */
    {
      evnt_mesag(TamponMessage);			/* Attendre un message */
      if(TamponMessage[4] == acc_id)
      {
        if(Correct)
        {
          switch(TamponMessage[0])
          {
            case AC_OPEN:	Principal();
            			break;
            case AC_CLOSE:	Quitter();
          			break;
            default:		break; 
          }
        }
        else
          form_alert(1,"[0][ Fun30 cannot run ][Sorry]");
      }
    }
  }
  else if(Correct)					/* L'appli. est un .PRG */
    Principal();
  else							/* Execution impossible */
    ;

  free(Tampon);
  W_MenuClose(Handle);					/* Close the window's menu */
  
  A_Close();
  W_Exit();  
  M_Exit();
  F_Exit();						/* Init Form    */
  
  return(0);
}

