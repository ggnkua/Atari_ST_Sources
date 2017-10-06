/*
 *	WinDom: Librarie FileSelector
 *			routines d‚riv‚es de fsel_inp.c par Olivier Scheel
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "globals.h"
#include "fsel.h"
#include "cookie.h"
/* Get definition of DTA */
/* #ifdef __SOZOBONX__ */
/*	#include <atari.h> */
/* #endif */

/* Types
 */
typedef  char str17[17];
typedef  char str128[128];


SLCT_STR *slct = NULL;
long     *fsel = NULL;

/* ------------------------------------------------------------------------- */
/* ----- fsel_check -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
** int fsel_check(void)
**
** Function:    Checks whether a FSEL-cookie is present.
**
** Parameters:  None
**
** Return:      TRUE  FSEL-cookie present
**              FALSE -----"----- not present.
**
** ------------------------------------------------------------------------- */

int fsel_check(void)
{
   if(!fsel)
		get_cookie( FSEL_COOKIE, (long *) &fsel);
   return(fsel ? TRUE : FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_check -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
** int slct_check(unsigned int version)
**
** Function:   Checks whether Selectric is installed and if it 
**             has the minimum version number required
**
** Parameters: Version contains the version number to be checked
**             (a '>=' test is done!!)
**
** Return:     TRUE  Selectric is installed and the 
**                   version number is OK.    
**             FALSE Either not installed or too low 
**                   a version number.
**
** ------------------------------------------------------------------------- */

int slct_check( UWORD version) {
   if(fsel_check()) {
      slct = (SLCT_STR *)fsel;
      if(slct->id != SLCT_COOKIE)
         slct = 0L;
   }
   if(slct && (slct->version >= version))
      return(TRUE);
   else
      return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_extpath ------------------------------------------------------ */
/* ------------------------------------------------------------------------- */
/*
** int slct_extpath(int ext_num, char *ext[], int path_num, char *paths[])
**
** Function:   Sets user-defined extensions and paths, that are
**             then used by Selectric. The extensions and paths 
**             must be set before each Selectric call!
**
 Parameters:  ext_num     Number of the extensions
**            *ext[]      The extensions
**            path_num    Number of paths
**            *paths[]    The paths
**
** Return:    TRUE   Selectric is installed
**            FALSE  Selectric is not installed
**
** ------------------------------------------------------------------------- */

int slct_extpath(int ext_num, char *(*ext)[], int path_num, char *(*paths)[]) {
	if(slct_check(0x0100)) {
		slct->num_ext = ext_num;
		slct->ext = ext;
		slct->num_paths = path_num;
		slct->paths = paths;
		return(TRUE);
	} else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_morenames ---------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
** int slct_morenames(int mode, int num, void *ptr)
**
** Function:   Initialises Selectric in a way that it knows 
**             that more than one name may be returned.
**
** Parameters:  mode   Gives the mode type. At present the
**                     following modes are present:
**                   0  Return files in the pointer list.
**                   1    -"-  files in a single string.
**                 num  Maximum number of names that are to 
**                      be returned.
**                *ptr  The poiter to the corresponding 
**                      structure.
**
** Return:     TRUE   Selectric is installed
**             FALSE  Selectric is not installed
**
** ------------------------------------------------------------------------- */

int slct_morenames(int mode, int num, void *ptr)
{
   if(slct_check(0x0100))
   {
      slct->comm |= CMD_FILES_OUT;
      if(mode)
         slct->comm |= CFG_ONESTRING;
      slct->out_count = num;
      slct->out_ptr = ptr;
      return(TRUE);
   }
   else
      return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_first -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
** int slct_first(DTA *mydta, int attr)
**
** Function:   If the communication-Byte has been set to 
**             CFG_FIRSTNEXT, then one can obtain the first
**             selected name with its corresponding attributes
**             via this function.
**
** Parameter:  mydta  The DTA in which the information is to 
**                    be stored.
**             attr   The attributes (see also Fsfirst). Selectric
**                    combines both attributes with AND and checks
**                    for != 0.
**
** Return:     0   OK
**            -49  No further files
**            -32  Function not present (Version < 1.02)
**
** ------------------------------------------------------------------------- */

int slct_first(DTA *mydta, int attr)
{
   if(slct_check(0x0102))
      return(slct->get_first(mydta, attr));
   else
      return(-32);
}

/* ------------------------------------------------------------------------- */
/* ----- slct_next --------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
** int slct_next(DTA *mydta)
**
** Function:   After the first name is returned by slct_first(),
**             one can get further names via this function.
**
** Parameters:  mydta (see above).
**
** Return:      see above.
**
** ------------------------------------------------------------------------- */

int slct_next(DTA *mydta) {
   if(slct_check(0x0102))
      return(slct->get_next(mydta));
   else
      return(-32);
}

/* ------------------------------------------------------------------------- */
/* ----- release_dir ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
** int release_dir(void)
**
** Function:    Releases the directory again (important!).
**
** Parameters:  None
**
** Return:     TRUE   Directory could be released.
**             FALSE  Error
**
** ------------------------------------------------------------------------- */

int slct_release(void) {
   if(slct_check(0x0102))
      return(slct->release_dir());
   else
      return(-32);
}

/* Pr‚paration d'une liste pour
 * les s‚lecteurs de fichiers.
 * Retourne le nombre de chaines.
 */

int conv_var( char *str) {
	int num = 1;
	
	while( *str) {
		if( *str == ';') {
			*str = '\0';
			num ++;
		}
		str ++;
	}
	return num;
}

/*
 *	path: buffer de 200 octets
 * 			"c:"
 *			"c:\\"
 *			"c:\\auto"
 *			"c:\\auto\\"
 *			""
 *  name: buffer de 14 octets
 *
 *  avant l'appel path contient le r‚pertoire
 *  et name le nom par d‚faut
 *	si *path = 0, on cherche dans le r‚pertoire courant
 *  si *ext = 0, on utilise *.* comme mask
 *
 *  aprŠs l'appel path contient le repertoire final
 *  et name le nom final.
 *
 *  Peut servir pour choisir des fichiers ou des r‚pertoires
 *
 *	Nouveau : paramŠtres lpath et lext (ainsi que
 *				les autres pr‚selections)
 */


int FselInput( char *path, char *name, char *ext, char *title,
	/* Actif que pour les s‚lecteurs flsx */
	char *lpath, char *lext) {

	INT16 res, dum;
	int npath, nmask;
	char *p;
	char *paths=NULL, *mask=NULL;
	char buf[FILE_SIZE];

	/* protection against the case ext==NULL */
	if (!ext) ext="";

	/* Trouver le r‚pertoire courant (si besoin) */
	if( *path == '\0') {
		path[0] = 'A' + Dgetdrv();
		path[1] = ':';
		Dgetpath( path + 2, 0);
	}
	add_slash( path);

	if( (app.aes4 & AES4_FSLX && !(CONF(app)->flag & NOMAGICFSEL)) ||
		slct_check(0x0100) ) {
		int len;
		/* La liste des r‚pertoires */	
	
		/* calcul de la taille de la chaŒne */
		len = (int)strlen( path)+1;
		len += (lpath?(int)strlen(lpath):0)+1;
		shel_envrn( &p, "HOME=");
		if( p && *p) len += (int)strlen( p) + 1;
		if( ConfInquire( "windom.fsel.path", "%S", buf)>0 && *buf)
			len += (int)strlen(buf)+1;
		shel_envrn( &p, "FSELPATH=");
		if( p && *p) len += (int)strlen( p)+1;
		paths = malloc( len*sizeof(char));
		if( paths == NULL) return -1;
		*paths = '\0';

		/* remplissage */
		strcat( paths, path);
		strcat( paths, ";");
		if( lpath) {
			strcat( paths, lpath);
			strcat( paths, ";");
		}
		shel_envrn( &p, "HOME=");
		if( p && *p) {
			strcat( paths, p);
			add_slash( paths);
			strcat( paths, ";");		
		}	
		if( ConfInquire( "windom.fsel.path", "%S", buf)>0 && *buf) {
			strcat( paths, buf);
			strcat( paths, ";");
		}
		shel_envrn( &p, "FSELPATH=");
		if( p && *p) {
			strcat( paths, p);
			strcat( paths, ";");		
		}
		/* conversion de la liste */
		npath = conv_var(paths);
	
		/* La liste des masques */	
	
		/* calcul de la taille de la chaine */
				
		len = (int)strlen( (*ext)?ext:"*") + 1;
		len += (lext?(int)strlen(lext):0)+1;
		if( ConfInquire( "windom.fsel.mask", "%S", buf)>0 && *buf)
			len += (int)strlen(buf)+1;
		shel_envrn( &p, "FSELMASK=");
		if( p && *p) len += (int)strlen( p)+1;
		mask = malloc( len*sizeof(char));
		if( mask == NULL) {
			free( paths);
			return -1;
		}
		*mask = '\0';

		/* remplissage */
		strcat( mask, (*ext)?ext:"*");
		strcat( mask, ";");
		if( lext) {
			strcat( mask, lext);
			strcat( mask, ";");
		}
		if( ConfInquire( "windom.fsel.mask", "%S", buf)>0 && *buf) {
			strcat( mask, buf);
			strcat( mask, ";");
		}
		if( p && *p) {
			strcat( mask, p);
			strcat( mask, ";");		
		}
		/* conversion de la liste */
		nmask = conv_var(mask);
	}

	/* Fonctions FSLX (MagiC 5 & BoxKite 2) dispo ? */

	if( app.aes4 & AES4_FSLX && !(CONF(app)->flag & NOMAGICFSEL)) {
		/* version fenetre */
		INT16 handle;
		INT16 sortmode = 0;
		void *fslx;
		EVNT ev;
		int evnt_res;
		EVNTvar old;
		WINDOW *win;
						
		/* Version en fenˆtre */

		MenuDisable();		
		fslx = fslx_open(
				title,
				-1,-1,
				&handle, /* handle fenetre */
				path, 256,
				name, 65,
				mask,
				0L,			/* kein Filter */
				paths,
				0 			/*SORTBYNAME*/,
				0 			/*GETMULTI */ );
		
		/* La fenˆtre est cr‚‚: on en fait une fenˆtre
		 * WinDom */
		
		win = WindAttach( handle);
		WindSet( win, WF_BEVENT, B_MODAL, 0, 0, 0);
		
		old = evnt;
		evnt.bclick = 2;
		evnt.bmask = evnt.bstate = 1;
		do {
		 	ev.mwhich = EvntWindom( MU_KEYBD|MU_BUTTON|MU_MESAG);
		 	ev.mx = evnt.mx;
		 	ev.my = evnt.my;
		 	ev.mbutton = evnt.mbut;
		 	ev.kstate = evnt.mkstate;
		 	ev.key = evnt.keybd;
		 	ev.mclicks = evnt. nb_click;
		 	
		 	for( dum = 0; dum < 8; dum++)
		 		ev.msg[dum] = evnt.buff[dum];
		 	
		 	
			evnt_res = fslx_evnt( fslx, &ev, path, name,
								  &res, &dum, 
								  &sortmode, &p);
		} while( evnt_res);
		evnt = old;
		fslx_close(fslx);

		/* Fermeture fenˆtre */
		win -> status &= ~WS_OPEN;
		WindClose( win);
		win->handle = -1;
		WindDelete( win);
		MenuEnable();
	} else {
		long dum;
		if( !get_cookie( MiNT_COOKIE, &dum)
			&& !get_cookie( MAGX_COOKIE, &dum))	strupr( ext);
		strcat( path, (*ext)?ext:"*.*");

		/* Il faudra traiter le cas de Freedom */
		/* Selectric dispo ? */

		if( slct_check(0x0100)) {
			char **pmask;
			char **ppath;

 			pmask = (char **)Galloc(sizeof(char *)*nmask);
 			for( dum=0,p=mask; dum<nmask; dum++, p += strlen(p)+1) {
 				pmask[dum] = (char *)Galloc( sizeof(char)*17);
 				strcpy( pmask[dum], p);
 			}
 			ppath = (char **)Galloc(sizeof(char *)*npath);
 			for( dum=0,p=paths; dum<npath; dum++, p += strlen(p)+1) {
  				ppath[dum] = (char *)Galloc( sizeof(char)*128);				
 				strcpy(ppath[dum], p);
 			}
			/* On installe les chemins et mask */
		/* 	slct_extpath( nmask,  &pmask, npath, &ppath);*/
			slct->num_ext 	= nmask;
			slct->ext 		= pmask;
			slct->num_paths = npath;
			slct->paths 	= ppath;

			/* Appel du s‚lecteur */
			fsel_exinput( path, name, &res, title);
			for( dum=0; dum<npath; Mfree( pmask[dum++]));
			Mfree(pmask);
			for( dum=0; dum<npath; Mfree( ppath[dum++]));
			Mfree(ppath);
		} else
		/* Selecteur du TOS 1.04 dispo ? */
		if( *title && vq_tos() >= 0x0104 )
	 		fsel_exinput( path, name, &res, title);
		else
		/* Selecteur standard */
			fsel_input( path, name, &res);
	}
	p = strrchr( path , '\\');
	*(p+1) = '\0';

	if( paths) {
		free( paths);
		free( mask);
	}
	return res;
}

/* EOF */
