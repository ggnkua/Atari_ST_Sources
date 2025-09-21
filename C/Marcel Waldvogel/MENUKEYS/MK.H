/********************************************************************\
* Headerdatei fr MENUKEYS.C                                         *
\********************************************************************/

/*
** Zuerst ein paar Konfigurationsflags, die bei Bedarf ge„ndert werden
** k”nnen.
*/

/*
** Das nachfolgende Flag entscheidet, ob ^2, ^6 und ^- speziell
** behandelt werden sollen. Sie werden (zumindest vom deutschen TOS)
** mit den v”llig unverst„ndlichen und unsystematischen ASCII-Codes
** 0, 30, 31 (respektive) versehen. (Auch im Zehnerblock)
** Sollte auf 1 gesetzt werden, damit diese Zeichen auch erkannt werden.
*/
#define KOMISCH		1

/*
** Das nachfolgende Flag entscheidet, ob CTRLLINKS, CTRLRECHTS und
** CTRLHOME so bleiben sollen (0) oder in z.B. LINKS | KEY_CTRL
** gewandelt werden sollen (1).
** Sollte aus Konsistenzgrnden auf 1 gesetzt werden.
*/
#define WANDLECONTROL	1

/*
** Das nachfolgende Flag entscheidet, ob bei Tasten aus dem Ziffernblock
** (ENTER ausgenommen, das schon einen eigenen Code hat) KEY_NUM
** gesetzt werden soll.
** Kann nach individuellen Wnschen vergeben werden.
*/
#define SET_NUMERIC	1

/*
** (mit Alt-Zehnerblock oder einem Makrorekorder eingegeben) KEY_NOSCAN
** gesetzt werden soll.
** Kann nach individuellen Wnschen vergeben werden.
*/
#define SET_NOSCAN	1

/*
** Das nachfolgende Flag entscheidet, ob die Variable keytab global
** existiert und vom Hauptprogramm gesetzt wurde (1), oder ob sie von
** key_decode() selbst ermittelt werden soll (0).
*/
#define GLOBKEYTAB	0


/*
** Die intern ben”tigten Scancodes
*/
#define SF1		0x54
#define SF10		0x5d
#define ALT1		0x78	/* Spezialbehandlung fr diese */
#define ALTAPOSTROPH	0x83	/* Tastenreihe */
#define NUMPLUS		0x4a	/* Einige Tasten im Ziffernblock */
#define NUMMINUS	0x4e
#define NUMKLAMMER	0x63
#define NUMPUNKT	0x71

#define ALTCHAR		'\007'	/* Alternate-Symbol als char */
#define ALTSTR		"\007"	/* Alternate-Symbol als String */
#define SHORTALTSTR	"A-"
#define LONGALTSTR	"Alt-"

#define SHIFTCHAR	'\001'	/* Shift-Symbol */
#define SHIFTSTR	"\001"
#define SHORTSHIFTSTR	"S-"
#define LONGSHIFTSTR	"Shift-"

#define CTRLCHAR	'^'	/* Ctrl-Symbol */
#define CTRLSTR		"^"
#define SHORTCTRLSTR	"C-"
#define LONGCTRLSTR	"Ctrl-"

#define SHORTNUMSTR	"N-"	/* Numerisches Feld */
#define LONGNUMSTR	"Num-"

#define CR		13
#define DEL		127

/*
** Noch ein Makro. Zeigt, ob dieser Scancode zum Ziffernblock geh”rt
** (gilt fr Num-"+-()/*7894561230.", nicht aber fr ENTER)
*/
#define ISNUMERIC(scan)	(scan == NUMPLUS || scan == NUMMINUS \
			|| scan >= NUMKLAMMER && scan <= NUMPUNKT)

/*
** Und noch ein Makro. Gibt an, ob der entsprechende Menpunkt/-titel
** berhaupt anw„hlbar ist (nicht DISABLED und nicht versteckt)
*/
#define AVAIL(obj) !(obj->ob_state & DISABLED || obj->ob_flags & HIDETREE)

