/*
 *				Module de gestion des fenetres.
 *
 *
 *	Author  : FunShip
 *	File    : LIBXWIND.H
 *	Date    : 28 November 1993
 *	Revision: 29 Juillet 1997
 *	Version : 1.00
 *	Release : 1.90
 *	Language: Pure C, Version du 3 Fevrier 1992 
 *	Origine	: FRANCE
 *
 *				- ATARI ST/STE/TT & Falcon -
 *				       - 1994,1996 -
 */

#ifndef	__LIBXWIND__
#define __LIBXWIND__ __LIBXWIND__

#include <PCXApp.h>

/*
 * -------------------------- Data structures and datas ----------------------------
 */

#define		W_TITLE_MAX		255
#define		W_INFO_MAX		255

#define		NOICON			-1										/* Window without icon picture */

#define 	MODELESS	0x0000
#define		MODAL		0x0001

typedef struct	{
					/* Window's data */
					char titre[W_TITLE_MAX];							/* its title */
					char info[W_INFO_MAX];								/* its information */
					int x;												/* initial position */
					int y;
					int w;												/* initial wide and heigth */
					int h;
					int attributs;										/* creating attributes */
					int type;											/* Modal/Modeless */
					
					/* Iconify's Data */
					int treename;									/* Formular icon name */
					int isiconify;									/* Is iconify window */
					
					/* Window's mouse definition */
					int		Mouse;									/* Mouse's Shape */
					MFORM		*MouseForm;								/* User Mouse's Shape */
					
					/* Window's users procedures */
					void (*op_close)(int);			
					void (*op_redraw)(int);
					void (*op_full)(int);
					void (*op_sized)(int);
					void (*op_uppage)(int);
					void (*op_downpage)(int);
					void (*op_upline)(int);
					void (*op_downline)(int);
					void (*op_rightpage)(int);
					void (*op_leftpage)(int);
					void (*op_rightcolum)(int);
					void (*op_leftcolum)(int);
					void (*op_vslider)(int,int);
					void (*op_hslider)(int,int);
					void (*op_iconify)(int);
					void (*op_uniconify)(int);
					void (*op_topped)(int);
					void (*op_moved)(int);
					
					void (*ClicLeft)(int);
					void (*ClicRight)(int);
				} Type_Parameter_Window;

extern	int	tabulation;										/* Tabulate lenght in text char */
extern	int	DesktopMenu,									/* Lines to menu */
		DesktopW,											/* Width of desktop */
		DesktopH;											/* Heigh of desktop */
extern	int	Red_x,Red_y,Red_w,Red_h;						/* current area is redrawing */

/*
 * ---------------------------------------------------------------------------------------
 *				Publics datas and types for menu management
 */

typedef	struct	{
					int	Item;					/* Menu item */
					int	State;					/* Initial State displaying */
					void	(*Procedure)(int WindowHandle);		/* Item's Method  */
				} Type_Window_Menu_List;

#define	INITIAL		0					/* No change the object's state */
#define WMENU_END	{0,0,NULL}				/* Menu's list end     */

extern	int	W_MenuItem;					/* Item selected */
extern	int	W_MenuModel;					/* Menu Model Tree Name */
extern	OBJECT	*W_MenuAddress;					/* Menu Instance Tree Address */

/*
 * ---------------------------------------------------------------------------------------
 *				Auto Window TOP mode
 */

typedef	struct	{
					int	AutoEnable;				/* {True,False} = Mode On/Off */
					int	OnlyWorkArea;				/* If mouse into work area */
					int	NoMouseMovement;			/* Don't top if mouse-mouvement */
				} Type_AutoTop;
		
		
/*
 * ------------------ Primitives gestion des fenetres publiques --------------------------
 */

int			W_Init(void);
int			W_Exit(void);
Type_Parameter_Window	*W_GetParameter(void);
void			W_Event(void);
int			W_Open(Type_Parameter_Window *parameter);
int			W_Close(int handle);
void			W_Redraw(int handle);
void			W_SetIconApp(int TreeName);

/*
 * ------------------------------ Clipping VDI functions --------------------------------
 */

void 			W_OnClip(int pxyarray[]);
void			W_OffClip(int pxyarray[]);

/*
 * -------------------------- Cursors and output procedures -----------------------------
 */
 
int			W_GLine(int handle);
int			W_GColums(int handle);
int			W_GMaxLine(int handle);
int			W_GMaxColum(int handle);
void			W_SLine(int handle,int ligne);
void			W_SColum(int handle,int colonne);

void			W_HomeCursor(int handle);
int			W_ClrScr(int handle);
int			W_Write(int handle,char *string);
int			W_Writeln(int handle,char *string);

/*	For compatibility with previous AADS v1.24 */
#define		W_Printf(handle, string)	W_Writeln(handle, string)

/*
 * ---------------------------------------------------------------------------------------
 *				Window-Menu Management Procedures
 */

OBJECT 			*W_MenuOpen(int WindowHandle, int MenuTreeName, Type_Window_Menu_List *List);
int 			W_MenuClose(int MenuTreeName);

int			W_MenuExist(int WindowHandle);
int 			W_WorkXYWH(int WindowHandle,int *Area_X,int *Area_Y,int *Area_W,int *Area_H);

int 			W_MnDisable(int WindowHandle,int Object);
int			W_MnEnable(int WindowHandle,int Object);
int			W_MnCheck(int WindowHandle,int Object);
int			W_MnUnCheck(int WindowHandle,int Object);

/*
 * ---------------------------------------------------------------------------------------
 *				Mouse procedure
 */

int			W_NewMouse(int WindowHandle,int Mouse, MFORM *MouseForm);

/*
 * ---------------------------------------------------------------------------------------
 *				Auto Window TOP procedure
 */

int			W_AutoTop(Type_AutoTop *AutoTop);

/*
 * ---------------------------------------------------------------------------------------
 *				Visual "clue" for the open/close window.
 */

void			W_VisualClue(int OnOff);

#endif
