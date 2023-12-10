/*
 *		Menu Manager for Pure C Application:
 *		For used GEM menu more easily...
 *
 *	Author  : FunShip
 *	File	: PCXmenu.c
 *	Date    : 01 October 1991
 *	Revision: 18 November 1994
 *	Version : 2.00
 *	Release : 1.00
 *	Language: Pure C, Version du 3 Fevrier 1992 
 *	Origine : FRANCE
 *	
 *	ATARI, 1991,92,93,94 -
 */

#ifndef	__PCXMENU__
#define __PCXMENU__	__PCXMENU__

#include <PCXApp.h>

/*
 * --------------------- User's constants definitions ---------------------
 */
 
#define	INITIAL		0		/* No change the object's state */

#define MENU_END	{0,0,NULL}	/* Menu's list end     */
#define	SUBATTACH_END	{0,0,0,0,0}	/* SubMenu's list end  */
#define	SUBEVENT_END	{0,0,NULL}	/* SubEvent's list end */

/*
 * ---------------------------- Publics Type ------------------------------
 */

typedef struct	{
		  int	Entry;			/* The Entry of Menu */
		  int	State;			/* its Initial state */
		  
		  void (*Procedure)(void);	/* Process associated */
		} Type_Parameter_Menu;
		
typedef struct	{
		  int	SubMenu;		/* The Sub-Menu */
		  int	ParentEntry;		/* Entry where attach it */
		  int	StartEntry;		/* Submenu Entry selected */
		  int	ScrollEntry;		/* Submenu Entry scroll	*/
		  int	UseChecked;		/* Use a check mark */
		} Type_Parameter_SubAttach;
		
typedef struct	{
		  int	SubMenu;		/* The Sub-Menu */
		  int	Entry;			/* Its Entry */
		  
		  void (*Procedure)(void);	/* Process associated */
		} Type_Parameter_SubEvent;

/*
 * ---------------------------- Publics Datas -----------------------------
 */

/* 
   When an object entry is selected, you could get its Object's tree
   address and its number Entry
 */
   
extern OBJECT	*M_Address;			/* Given Current Tree Menu */
extern int	M_Name;				/* Given Name Menu */
extern int	M_Entry;			/* Given Current Entry */

/*
 * --------------------------- Tools procedures ---------------------------
 */

void	M_SetSubMenu(int Size);
int	M_Checked(int Tree,int Entry);
int	M_UnChecked(int Tree,int Entry);
int	M_Enable(int Tree,int Entry);
int	M_Disable(int Tree,int Entry);
int	M_Change(int Tree,int Entry,char *string);
	
/*
 * ------------------------ Management procedures -------------------------
 */
	
int	M_Init(void);
int	M_Exit(void);
int	M_Open(int Tree,Type_Parameter_Menu *Liste);
int	M_Close(int Tree);
int	M_SubAttach(int Tree,Type_Parameter_SubAttach *Liste);
int	M_SubEvent(int RootTree,Type_Parameter_SubEvent *Liste);
void	M_Event(void);

#endif