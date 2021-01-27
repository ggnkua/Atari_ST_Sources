#include <prelude.h>
#include <NP_AES.H>
#include <VDI.H>
#include <TOS.H>

/*----------------------------------------------------------------------------------*/ 
/* Informationen ber die AES-Funktionen zurckliefern								*/
/* Funktionsergebnis:	diverse Flags												*/
/*	font_id:			ID des AES-Fonts											*/
/*	font_height:		H”he des AES-Fonts (fr vst_height())						*/
/*	hor_3d:				zus„tzlicher horizontaler beidseitiger Rand fr 3D-Objekte	*/
/*	ver_3d:				zus„tzlicher vertikaler beidseitiger Rand fr 3D-Objekte	*/
/*----------------------------------------------------------------------------------*/ 

extern GLOBAL aes_global;
extern int aes_handle;

int MagX,MagX_version,radio_bgcol;
MAGX_COOKIE *magic;
long *sstack;

typedef struct
{
	long id,val;
}
COOKIE;

bool get_cookie(long cookie, long *value)
{
	COOKIE *jar;

	(long)sstack = Super(0L);
	jar = *(COOKIE **)0x5a0L; /* JAR (long *)0x5a0L */
	Super(sstack);

	if (!jar)
		return FALSE;

	while(jar->id)
	{
		if (jar->id eq cookie)
		{
			if (value)
				*value = jar->val;
			return TRUE;
		}
		jar++;
	}
	return FALSE;
}

global
int	get_aes_info( int *font_id, int *font_height, int *hor_3d, int *ver_3d )
{
	int	work_out[57];
	int	attrib[10];
	int	pens;
	int	flags;
	
	vq_extnd( aes_handle, 0, work_out );
	vqt_attributes( aes_handle, attrib );

	flags = 0;
	pens = work_out[13];				/* Anzahl der Farbstifte */
	if (font_id)     *font_id     = attrib[0];		/* Standardfont */
	if (font_height) *font_height = attrib[7];		/* Standardh”he */
	*hor_3d     = 0;
	*ver_3d     = 0;
	radio_bgcol = 0;

	if ( appl_find( "?AGI" ) == 0 )		/* appl_getinfo() vorhanden? */
		flags |= GAI_INFO;

	if ( aes_global.version >= 0x0401 )	/* mindestens AES 4.01? (includes N_AES???) */
		flags |= GAI_INFO;

	MagX_version = 0;
	
	MagX  = get_cookie('MagX',(long *)&magic);

	if ( magic )						/* MagiC vorhanden? */
		if ( magic->aesvars )			/* MagiC-AES aktiv? */
		{
			MagX_version = magic->aesvars->version;	/* MagiC-Versionsnummer */
			flags |= GAI_MAGIC + GAI_INFO;
		}
		
	if ( flags & GAI_INFO )				/* ist appl_getinfo() vorhanden? */
	{
		int	ag1, ag2, ag3, ag4;

		if ( appl_getinfo( 0, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 0, Fonts */
		{
			if (font_id)     *font_id     = ag2;
			if (font_height) *font_height = ag1;
		}
		if ( appl_getinfo( 2, &ag1, &ag2, &ag3, &ag4 ) && ag3 )	/* Unterfunktion 2, Farben */
			flags |= GAI_CICN;

		if ( appl_getinfo( 7, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 7 */
			flags |= ag1 & 0x0f;

		if ( appl_getinfo( 12, &ag1, &ag2, &ag3, &ag4 ) && ( ag1 & 8 ))	/* AP_TERM? */
			flags |= GAI_APTERM;

		if ( appl_getinfo( 13, &ag1, &ag2, &ag3, &ag4 ))		/* Unterfunktion 13, Objekte */
		{
			if ( flags & GAI_MAGIC )			/* MagiC spezifische Funktion! */
				if ( ag4 & 0x08 )				/* G_SHORTCUT untersttzt ? */
					flags |= GAI_GSHORTCUT;
				
			if ( ag1 && ag2 )					/* 3D-Objekte und objc_sysvar() vorhanden? */
				if ( objc_sysvar( 0, AD3DVALUE, 0, 0, hor_3d, ver_3d ))	/* 3D-Look eingeschaltet? */
					if ( pens >= 16 )			/* mindestens 16 Farben? */
					{
						int	dummy;
						
						flags |= GAI_3D;
						objc_sysvar( 0, BACKGRCOL, 0, 0, &radio_bgcol, &dummy );
					}
		}
	}
	
	return  flags;
}
