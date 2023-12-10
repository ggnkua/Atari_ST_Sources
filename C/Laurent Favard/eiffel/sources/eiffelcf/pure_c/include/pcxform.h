/*
 *		Formular and Desktop Icon, Management for Pure C Application:
 *
 *	Author  : FunShip
 *	File	: PCXForm.h
 *	Date    : 01 October 1991
 *		  (first version, very old...)
 *	Revision: 17 Juillet 1998
 *	Version : 1.00
 *	Release : 1.00
 *	Language: Pure C, Version du 3 Fevrier 1992 
 *	Origine : FRANCE
 *	
 *
 */

#ifndef	__XFORM__
#define __XFORM__	__XORM__

#include <aes.h>

/*
 * ---------------------------------- Constantes ------------------------------------
 */

#define	FORM_END		{0, NULL, NULL, NULL, NULL, NULL}		/* Form list end */
#define	BUREAU_END		{0,0,0,NULL,NULL,NULL,NULL,NULL}		/* Desktop list end */
#define	POPATTACH_END	{0,0,0,0,0}								/* PopMenu's list end  */
#define	POPEVENT_END	{0,0,NULL}								/* PopEvent's list end */

#define	NOTEXT		0			/* No Edit Field to specified */
#define	F_WIND		1			/* Formular in window */
#define	F_CLASSIC	0			/* Formular classic */

#define	NOWINDOW	-1			/* Formular without window */

#define	DESKTOP		0			/* Desktop window */

#define	ICON2ICON	1			/* Icon moved to another icon  */
#define	ICON2WIND	2			/* Icon moved to window        */

#define	SCROLL_LISTBOX	-1			/* Popup become a drop-down listbox */
									/* (AES 4.1 and above) */
/*
 * ---------------------------------- Structures --------------------------------------
 */

typedef	struct	{
					int	Object;									/* Object selected */
					void (*ProcClic)(void);						/* Procedure when left clic */
					void (*ProcDbClic)(void);						/* Procedure when left double clic */
					void (*ProcClicRight)(void);					/* Procedure when right clic */
					void (*ProcDbClicRight)(void);				/* Procedure when right double clic */
					void (*ProcMouseEnter)(void);					/* Procedure when mouse enter to the object */
					void (*ProcMouseExit)(void);					/* Procedure when mouse exit to the object  */					
				} Type_Form_List;

typedef	struct	{
					int	Object;									/* Order number Object */
					int	x;										/* position on desktop */
					int	y;
					char *Titre;									/* Icon Text */
					void (*ProcClic)(void);						/* Procedure when clic */
					void (*ProcDbClic)(void);						/* Procedure when double clic */
					void (*ProcClicDroit)(void);					/* Procedure when clic */
					void (*ProcDbClicDroit)(void);				/* Procedure when double clic */
					void (*Move2Icon)(int movment,int Object);	/* When Icon moved to Icon */
					void (*Move2Wind)(int movment,int Handle);	/* When Icon moved to Wind */
				} Type_Bureau_List;

typedef struct	{
					int	Popup;			/* The Popup Menu */
					int	Button;			/* Button where attach it */
					int	StartEntry;		/* Submenu Entry selected */
					int	ScrollEntry;	/* Submenu Entry scroll	*/
					int	UseChecked;		/* Use a check mark */
				} Type_Parameter_PopAttach;
		
typedef struct	{
					int	PopMenu;				/* The Sub-Menu */
					int	Entry;					/* Its Entry */
					void	(*Procedure)(void);	/* Process associated */
				} Type_Parameter_PopEvent;

typedef	struct	{
					int		Tree;
					void	(*routine)(int Item);					
				} TPopup;

typedef struct	{
					void	(*moved)(int handle);		
					void	(*redraw)(int handle);		
					void	(*closed)(int handle);		
					void	(*iconify)(int handle);		
					void	(*uniconify)(int handle);		
				} Type_UserEvent;

/* For the F_XOpen() new call */
typedef struct  {
		  			int				TreeName;												/* Objects Tree Name */
		  			char			*Title;													/* Formular's title */
		  			int				Mode;													/* Opening mode */
		  			int				FirstEdit;												/* First Editable Text Field */
		  			Type_Form_List	*List;													/* Event list */
		  			int				FormIcon;												/* Objects Tree Name Icon */
		  			int				Closer;													/* Allows close ? */
		  			int				Smaller;												/* Allows smaller ? */
		  			int				Type;													/* Modal/Modeless formulaire */

					int				x;
					int				y;						  
					/* Dialog Box's mouse definition */
					int				Mouse;													/* Mouse's Shape */
		  			MFORM			*MouseForm;												/* User Mouse's Shape */
				}	Type_Formular_Parameter;	
		
/*
 * ---------------------------------- Donn‚es -----------------------------------------
 */
 
extern int		F_NameObject;													/* child object selected */
extern int		F_Name;															/* Name of formular's tree */
extern OBJECT	*F_Address;														/* Address of formular's tree */

extern OBJECT	*DesktopAddress;												/* My own desktop */
extern int		I_Name;															/* Source Icone Name */

extern int		F_PopupName;													/* Name of Popup Menu Enable */
extern int		F_PopupEntry;													/* Name of Popup Entry selected */
extern int		F_PopupParent;

/*
 * --------------------- Publics Formular procedure -----------------
 */

int		F_Init(void);
int		F_Exit(void);
int		F_Open(int TreeName,char *Title,int Mode,int FirstEdit,Type_Form_List *List);
int		F_Close(int TreeName);
void	F_Event(void);
int		F_UserEvent(int TreeName, Type_UserEvent *UserEvent);

/* EXTENDED calls */

Type_Formular_Parameter	*F_GetParameter(void);
int		F_XOpen(Type_Formular_Parameter *Parameter);

/*
 * --------------------- Publics Pop-up procedures ------------------	
 */

void	F_Popup(int IdFormulaire,int IdObject, int Mouse_X, int Mouse_Y);
void	F_PopupXY( TPopup *Popup, int Mouse_X, int Mouse_Y);

int		F_PopAttach(int Formular,Type_Parameter_PopAttach *List);
int		F_PopEvent(Type_Parameter_PopEvent *List);
void	F_SetPopup(int size); 

/*
 * -------------------- Publics Desktop procedures ------------------	
 */
 
int		D_Open(int TreeDesk,Type_Bureau_List *List);
void	D_Close(void);

/*
 * ---------------------- Publics Tools procedures ------------------
 */

void	F_Selected(int TreeName,int Object, int State);
void	F_Disabled(int TreeName,int Object, int state);

void	F_WriteText(int TreeName,int Object,char *string);
void	F_ReadText(int TreeName,int Object,char *string);
int		F_LObject(int Tree,int Object);
int		F_HObject(int Tree,int Object);
void	F_RedrawObject(OBJECT *arbre,int index);
int		F_EstIconifie(int Handle);
void	F_FreeDraw(int Handle,void (*ProcedureDraw)(int x,int y,int w,int h));

#endif
