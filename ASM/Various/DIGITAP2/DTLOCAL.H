/* Defines fÅr externe DSP-Modul */

#include <aes.h>

typedef unsigned int HDIALOG;

#define DSP1_0 8388607L
#define DSP0_5 4194304L

#define TRUE 1
#define FALSE 0


/*----------------------------------------------------
Teilt dem Hauptprogramm Informationen Åber das Modul mit:
void dtm_init(	Module_info *dtm_info,
								void *rsc, Rsc_info *rsc_info )
-----------------------------------------------------*/
#define dtm_init(dtm_info, rsc, rsc_info)\
		(*(glob->mh.sys->_dtm_init))(dtm_info, rsc, rsc_info)


/*------------------------------------------------------
Teilt dem Hauptprogramm Information Åber Regler mit:
int	dtm_init_poti(void *vglob, int potinr,
									int type, int parent, int slider, int value)
--------------------------------------------------------*/
#define dtm_init_poti(vglob, potinr, type, parent, slider, value)\
		(*(glob->mh.sys->_dtm_init_poti))(vglob, potinr, type, parent, slider, value)


/*---------------------------------------------------------
Wert aus Logarithmus-Tabelle holen
	wert: 0 bis 256
	return: 0 bis 1 in DSP-Format (0 bis DSP1_0)
long *log_tab_entry( int wert )
-----------------------------------------------------------*/
#define log_tab_entry(w) (*(glob->mh.sys->_log_tab_entry))(w)


/*---------------------------------------------------------
Pegel (0...max) aus RSC-Regler holen
	bei Angabe von Feld- und Slider-Grîûen und Slider-Position
	normiert auf max (maximal 24 Bit groû)
	Flag vertikal: TRUE wenn Regler unten 0 sein soll
long get_rsc_pegel( int f_size, int s_size, int s_posi, long max,
										int vertikal )
-----------------------------------------------------------*/
#define get_rsc_pegel( f_s, s_s, s_p, max, vert )\
		(*(glob->mh.sys->_get_rsc_pegel))( f_s, s_s, s_p, max, vert )


/*----------------------------------------------------------
Setzt Volume einer Line (berÅcksichtigt Pan):
	button:  TRUE wenn Line eingeschaltet
	vol:     LautstÑrke 0 ... 255
	line_nr: zu regelnde Line 
void set_line_volume( int button, int vol, int line_nr )
-----------------------------------------------------------*/
#define set_line_volume( button, vol, line_nr )\
		(*(glob->mh.sys->_set_line_volume))( button, vol, line_nr )


/*----------------------------------------------------------
Setzt Volume einer Line (berÅcksichtigt Vol):
	button:  TRUE wenn Line eingeschaltet
	pan:     Pan-Position 0(L) ... 127 ... 255(R)
	line_nr: zu regelnde Line 
void set_line_panorama( int button, int pan, int line_nr )
-----------------------------------------------------------*/
#define set_line_panorama( button, pan, line_nr )\
		(*(glob->mh.sys->_set_line_panorama))( button, pan, line_nr )


/*---------------------------------------------------------
VerÑndert ob_state im Resource
	wenn maske 0 wird nichts gesetzt
	set: 			-1 togglen, FALSE lîschen, TRUE setzen
	hdialog:	Dialog-Handle
	item:			Object-Index
	Return:		alter Status
int DialogState(HDIALOG hdialog, int item, int set, int maske)
---------------------------------------------------------*/
#define DialogState(hd, item, set, maske)\
		(*(glob->mh.sys->_DialogState))(hd, item, set, maske)


/*---------------------------------------------------------
VerÑndert ob_flags im Resource
	wenn maske 0 wird nichts gesetzt
	set: 			-1 togglen, FALSE lîschen, TRUE setzen
	hdialog:	Dialog-Handle
	item:			Object-Index
	Return:		alter Status
int DialogFlags(HDIALOG hdialog, int item, int set, int maske)
---------------------------------------------------------*/
#define DialogFlags(hd, item, set, maske)\
		(*(glob->mh.sys->_DialogFlags))(hd, item, set, maske)


/*---------------------------------------------------------
In 'hdialog' auf das Element 'index' den mit
'format' erzeugten String ausgeben wie
mit printf. Bei den Elementen G_TEXT, G_BOXTEXT,
G_FTEXT und G_FBOXTEXT wird auf
te_ptext ausgegben, sonst auf free_string
Return: wie printf
int DialogPrintf(HDIALOG hdialog, int item, LPSTR format, ...)
---------------------------------------------------------*/
#define	DialogPrintf (*(glob->mh.sys->_DialogPrintf))


/*---------------------------------------------------------
Malt Object
void draw_object( OBJECT *obj, int item )
---------------------------------------------------------*/
#define draw_object( obj, item )\
		(*(glob->mh.sys->_draw_object))( obj, item )


/*---------------------------------------------------------
wie gewohnt
---------------------------------------------------------*/
#define object_find( baum, anf_obj, tiefe, x, y )\
		(*(glob->mh.sys->_object_find))( baum, anf_obj, tiefe, x, y )


/*---------------------------------------------------------
Die Variable 'var' im DSP-Speicher ('memtype': 'X' oder 'Y')
setzen. 'size' ist Variablengrîûe.
void dm_setvar(int memtype, int var, long *value, int size)
---------------------------------------------------------*/
#define dm_setvar( memtype, var, value, size)\
		(*(glob->mh.sys->_dm_setvar))( memtype, var, value, size)


/*---------------------------------------------------------
Variable definieren, d.h. sich Speicherplatz geben lassen
typ: 'X', 'Y' fuer X/Y-Speicher
Return: 0 wenn nichts mehr frei, sonst Adresse
int dm_defvar(int typ, int adrsize, int size)
---------------------------------------------------------*/
#define dm_defvar(typ, adrsize, size)\
		(*(glob->mh.sys->_dm_defvar))(typ, adrsize, size)


/*---------------------------------------------------------
Modul 'modul' in den DSP linken
Variablenadressen und Konstante im Modul werden durch die
folgenden Parameter gesetzt, z.B. ADDER_QUELLE, 0x3c, ...
letzter Parameter muû < 0 sein
Return: Modulhandle oder <0 bei Fehler
int cdecl dm_load(void *vmodul, ...)
---------------------------------------------------------*/
#define dm_load (*(glob->mh.sys->_dm_load))


/*---------------------------------------------------------
Block im DSP-Speicher mit 'wert' besetzen
'memtyp': 'X' oder 'Y'
void dsp_setblock( int memtyp, int adr, long wert, int size)
---------------------------------------------------------*/
#define dsp_setblock( memtyp, adr, wert, size )\
		(*(glob->mh.sys->_dsp_setblock))( memtyp, adr, wert, size )

