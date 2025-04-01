/********************************************************************
 * Modul	: common.c												*
 * Projekt	: Speedy												*
 * Aufgabe	: Allgmeine Routinen									*
 *==================================================================*
 * Autor	: Erik Dick												*
 * Datum	: 17. August 1993										*
 *------------------------------------------------------------------*
 * Computer	: Atari ST												*
 * Compiler	: Pure-C												*
 * Optionen	: -----													*
 *------------------------------------------------------------------*
 * Datum	: 17. August 1993										*
 *==================================================================*
 * Copyright: E. Dick  & Maxon Computer GMBH						*
 ********************************************************************/

#include <aes.h>
#include <stddef.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>

#include "font.h"
#include "common.h"

/****************************** DEFINES *****************************/

#define COOKIE_PTR  0x5A0L
#define SYSBASE		0x4F2L

/****************************** TYPEDEFS ****************************/

typedef struct
{
	char magic[4];
	long value;
} COOKIE_ENTRY;

typedef struct
{
	char	magic[4];
	int	release;
} SPD_COOKIE;

typedef struct
{
	char	*in_dos;					/* Adresse der DOS- Semaphore */
	int		*dos_time;					/* Adresse der DOS- Zeit      */
	int		*dos_date;					/* Adresse des DOS- Datums    */
	long	res1;						/*                            */
	long	res2;						/*                            */
	long	res3;						/* ist 0L                     */
	void	*act_pd;					/* Laufendes Programm         */
	long	res4;						/*                            */
	int		res5;						/*                            */
	void	res6;						/*                            */
	void	res7;						/* interne DOS- Speicherliste */
	void	(*resv_intmem)();			/* DOS- Speicher erweitern    */
	long	(*etv_critic)();			/* etv_critic des GEMDOS      */
	char *	((*err_to_str)(char e));	/* Umrechnung Code->Klartext  */
	long	res8;						/*                            */
	long	res9;						/*                            */
	long	res10;						/*                            */
} DOSVARS;

typedef struct
{
	long	magic;						/* muû $87654321 sein         */
	void	*membot;					/* Ende der AES- Variablen    */
	void	*aes_start;					/* Startadresse               */
	long	magic2;						/* ist 'MAGX'                 */
	long	date;						/* Erstelldatum               */
	void	(*chgres)(int res, int txt);/* Auflîsung Ñndern           */
	long	(**shel_vector)(void);		/* residentes Desktop         */
	char	*aes_bootdrv;				/* von hieraus wurde gebootet */
	int		*vdi_device;				/* vom AES benutzter Treiber  */

	void	**nvdi_workstation;			/* Keine offiziellen AESVARS	*/
	int		*shelw_doex;
	int		*shelw_isgr;
	int		version;
	int		release;
} AESVARS;

/* Cookie MagX --> */

typedef struct
{
	long	config_status;
	DOSVARS	*dosvars;
	AESVARS	*aesvars;
} MAGX_COOKIE;

/***************************** FUNCTIONS ****************************/

/*-----------------------------------------------------------------------------*
	Name			search_cookie

	Beschreibung	Sucht einen Cookie im Cookie-Jar

	Parameter		char		*magic		Zeiger auf die Cookie-Kennung

	Ergebnis		NULL, wenn der Cookie nicht gefunden wurde, sonst der Zeiger
					auf den Cookie
 *-----------------------------------------------------------------------------*/

COOKIE_ENTRY *search_cookie(char *magic)
{
	long save_sp;
	COOKIE_ENTRY	*ptr;

	save_sp = (long)Super(0L);
	ptr = *(COOKIE_ENTRY**)COOKIE_PTR;
	if(ptr != NULL)
	{
		while(	*((long *) ptr->magic) != 0  &&
				strncmp((char*)ptr,magic,4))
			ptr++;
		if( *((long *) ptr->magic) == 0 )
			ptr = NULL;
	}
	Super((char*)save_sp);

	return(ptr);
}

/*-----------------------------------------------------------------------------*
	Name			OSVersion

	Beschreibung	Ermittelt die Betriebsystemversion. Die Funktion muû via 
					Supexec() ausgefÅhrt werden.

	Ergebnis		Die Betriebssystemversion
 *-----------------------------------------------------------------------------*/

long OSVersion(void)
{
	SYSHDR	*syshdr;

	syshdr = (SYSHDR*) *(long*) SYSBASE;
	return((long) syshdr->os_version);
}

/*-----------------------------------------------------------------------------*
	Name			OSDate

	Beschreibung	Ermittelt das Betriebsystemdatum. Die Funktion muû via 
					Supexec() ausgefÅhrt werden.

	Ergebnis		Das Betriebssystemdatum
 *-----------------------------------------------------------------------------*/

long OSDate(void)
{
	SYSHDR	*syshdr;

	syshdr = (SYSHDR*) *(long*) SYSBASE;
	return(syshdr->os_gendat);
}

/*-----------------------------------------------------------------------------*
	Name			speedo_active

	Beschreibung	PrÅft ob Speedo-GDOS aktiv ist

	Ergebnis		0 (FALSE) Speedo nicht aktiv
					1 (TRUE)  Speedo aktiv
 *-----------------------------------------------------------------------------*/

int speedo_active(void)
{
	COOKIE_ENTRY	*cookie;
	int				ret_val = 0;
	SPD_COOKIE		*spd;

	if((cookie = search_cookie("FSMC")) != NULL)
	{
		spd = (SPD_COOKIE *) cookie->value;
		if(	strncmp(spd->magic,"_SPD",4) == 0)
		{
			ret_val = spd->release;
		}
	}
	return ret_val;
}

/*-----------------------------------------------------------------------------*
	Name			magix_active

	Beschreibung	PrÅft ob und welche Mag!X-Version aktiv ist.

	Ergebnis			0 kein Magix
						1 Magix Version 1.x
						2 Magix Version 2.x
 *-----------------------------------------------------------------------------*/

int magix_active(void)
{
	COOKIE_ENTRY	*cookie;
	int				ret_val = 0;
	MAGX_COOKIE		*magx;

	if((cookie = search_cookie("MagX")) != NULL)
	{
		magx = (MAGX_COOKIE *) cookie->value;
		if(	magx->aesvars->magic == 0x87654321L
			&& magx->aesvars->magic2 == 0x4D414758L)
		{
			ret_val = magx->aesvars->version;
		}
	}
	return ret_val;
}

/*-----------------------------------------------------------------------------*
	Name			mtos_active

	Beschreibung	PrÅft ob und welche MultiTOS-Version aktiv ist.

	Ergebnis		0 kein MultiTOS
					!= 0 Versionslevel
 *-----------------------------------------------------------------------------*/

int mtos_active(void)
{
	int	ret_val = 0;
	COOKIE_ENTRY *cookie;

	if((cookie = search_cookie("MiNT")) != NULL)
	{
		if(cookie->value > 0100L)
		{
			if(_GemParBlk.global[0] >= 0x0400)
				ret_val = (int) cookie->value;
		}
	}

	return(ret_val);
}

/*-----------------------------------------------------------------------------*
	Name			Clip

	Beschreibung	Setzen oder RÅcksetzen des Clippings.

	Parameter		int			ScreenVHandle
											Der VDI-Handle der Bildschirm-
											Workstation.
					RECT		*Rect		Das Rechteck das betrachtet werden
											soll.
					int			Mode		Ein- oder Ausschalten (-> vs_clip)

	Ergebnis
 *-----------------------------------------------------------------------------*/

void Clip(int ScreenVHandle,RECT *Rect,int Mode)
{
	int	pxy[4];

	pxy[0] = Rect->X;
	pxy[1] = Rect->Y;
	pxy[2] = Rect->X + Rect->W-1;
	pxy[3] = Rect->Y + Rect->H-1;
	
	vs_clip(ScreenVHandle,Mode,pxy);
}

/*-----------------------------------------------------------------------------*
	Name			Intersect

	Beschreibung	Berechnet die Schnittmenge zweier Åbergebener Rechtecke.

	Parameter		RECT		*Rect1		Das erste Rechteck
					RECT		*Rect2		Das zweite Rechteck
											Ist auch Ausgabeparameter und ent-
											hÑlt nach dem Funktionsaufruf, ein
											Rechteck mit der Schnittmenge der
											Åbergebenen RECTs.

	Ergebnis		TRUE, wenn die Schnittmenge	ein legales Rechteck bildet.
					FALSE, sonst.
  *-----------------------------------------------------------------------------*/

int Intersect(RECT *Rect1, RECT *Rect2)
{
   int x, y, w, h;

   x = max(Rect1->X,Rect2->X);
   y = max(Rect1->Y,Rect2->Y);
   w = min(	Rect1->X + Rect1->W,
   			Rect2->X + Rect2->W);
   h = min(	Rect1->Y + Rect1->H,
   			Rect2->Y + Rect2->H);

   Rect2->X = x;
   Rect2->Y = y;
   Rect2->W = w - x;
   Rect2->H = h - y;

   return ( (w > x) && (h > y) );
}

/*-----------------------------------------------------------------------------*
	Name			set_system_font

	Beschreibung	Setzt den Systemzeichensatz des AES.

	Parameter		RECT		*Rect1		Das erste Rechteck
					RECT		*Rect2		Das zweite Rechteck
											Ist auch Ausgabeparameter und ent-
											hÑlt nach dem Funktionsaufruf, ein
											Rechteck mit der Schnittmenge der
											Åbergebenen RECTs.

	Ergebnis		TRUE, wenn die Schnittmenge	ein legales Rechteck bildet.
					FALSE, sonst.
  *-----------------------------------------------------------------------------*/

void set_system_font( int VDI_Handle )
{
	int dum,
		font_id = 0,
		font_height = 0,
		font_type = 0;
	
	if(KNOWS_APPL_GETINFO)
	{
		appl_getinfo(0,&font_height,&font_id,&font_type,&dum);
		if(vst_font(VDI_Handle,font_id) != font_id)
		{
			if(vq_gdos() && vst_load_fonts(VDI_Handle,0))
				vst_font(VDI_Handle,font_id);
		}
		vst_height(VDI_Handle,font_height,&CharW,&CharH,&CellW,&CellH);
	}
	else
	{
		vst_font(VDI_Handle,1);
		vst_point(VDI_Handle,10,&CharW,&CharH,&CellW,&CellH);
	}
}

/*-----------------------------------------------------------------------------*
	Name			slider_calc_size

	Beschreibung	Berechnet die Slidergrîûe

	Parameter		int		Winddim		Ausdehnung des Fensters (Workarea)
					long	Contdim		Ausdehnung des Inhaltes

	Ergebnis		Die Grîûe des Sliders (1..1000)
 *-----------------------------------------------------------------------------*/

int slider_calc_size(int Winddim,long Contdim)
{
	int		ret_val = 1000;

	if(Winddim < Contdim)
	{
		ret_val = max( 1,(int) (((long) Winddim * 1000L) / Contdim) );
	}

	return(ret_val);
}

/*-----------------------------------------------------------------------------*
	Name			slider_calc_pos

	Beschreibung	Berechnet die Sliderposition

	Parameter		int		Winddim		Ausdehnung des Fensters (Workarea)
					long	Contdim		Ausdehnung des Inhaltes
					long	Offset		Distanz zum Anfang des Inhalts

	Ergebnis		Die Position des Sliders (1..1000)
 *-----------------------------------------------------------------------------*/

int slider_calc_pos(int Winddim,long Contdim,long Offset)
{
	int		ret_val = 0;

	if(Winddim < Contdim)
	{
		ret_val = min(1000,(int)(((Offset * 1000L) / (Contdim - (long) Winddim))));
	}

	return(ret_val);
}

/*-----------------------------------------------------------------------------*
	Name			slider_get_pos

	Beschreibung	Berechnet die Position innerhalb des Inhalts abhÑngig von
					der Åbergebenen Sliderposition.

	Parameter		int		Winddim		Ausdehnung des Fensters (Workarea)
					long	Contdim		Ausdehnung des Inhaltes
					int	Position	Die Sliderposition

	Ergebnis		Die Position innerhalb des Inhaltes
 *-----------------------------------------------------------------------------*/

long slider_get_pos(int Winddim,long Contdim,int Position)
{
	long	ret_val = 0;
	long	invisible = Contdim-Winddim;

	if(Winddim < Contdim)
	{
		ret_val = (invisible * Position) / 1000L;
	}

	return(ret_val);
}

/*-----------------------------------------------------------------------------*
	Name			isinrect

	Beschreibung	PrÅft ob eine X/Y-Position in einem Rechteck liegt

	Parameter		int		px,py		Die Koordinaten
					RECT	*Rect		Das zu prÅfenden Rechteck

	Ergebnis		Liegt der Punkt im Rechteck
 *-----------------------------------------------------------------------------*/

int isinrect(int px,int py,RECT *Rect)
{
	if(	(px >= Rect->X) &&
		(px <= Rect->X+Rect->W-1) &&
		(py >= Rect->Y) &&
		(py <= Rect->Y+Rect->H-1))
	{
		return( TRUE );
	}
	else
	{
		return( FALSE );
	}
}

/********************************************************************************
 *							E N D - O F - F I L E								*
 ********************************************************************************/
