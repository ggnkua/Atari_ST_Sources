/* C-Header Dialog-Handler: MAIN_DIAL;
  Erzeugt durch DIAL_GEN V 1.01 (C) Uwe Kornnagel */

#ifndef __MAIN_DIAL__
	#define __MAIN_DIAL__

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h>
	#include <ext.h>
	#include <tos.h>
	#include <stdarg.h>
	
	#include<M_ALERTS.H>
	#include<M_APPL.H>
	#include<M_AREA.H>
	#include<M_ASCTAB.H>
	#include<M_DIALS.H>
	#include<M_EVENT.H>
	#include<M_FONTS.H>
	#include<M_MAKROS.H>
	#include<M_MESSAG.H>
	#include<M_MENUS.H>
	#include<M_POPUPS.H>
	#include<M_RANDOM.H>
	#include<M_RSC.H>
	#include<M_SYS.H>
	#include<M_TERMIN.H>
	#include<M_TIME.H>
	#include<M_UTILS.H>
	#include<M_WINDOW.H>
	#include<M_XTRNL.H>
	extern	void DoDIAL_OK( PtrDialpara dp );

	extern	int InitMAIN_DIAL( void );
	extern	int RunMAIN_DIAL( void );
	extern	void DoneMAIN_DIAL( void );
	extern void MAIN_DIAL_Info( char *newinfo );

#endif
