/***************************************************************

        bwb_mes.h       Header File for Natural-Language-Specific
                        Text Messages for Bywater BASIC Interpreter

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

/****************************************************************

	The following Latin conventions are used:

	LATIN			ENGLISH

	acies datorum		array (of data)
        crusta			shell
	litteras		(character) string
	memoria mutabilis	RAM
	organum			device
	ordo			line
	praeceptum		command
	  praecepta		  program (commands)
	  praecepta interna	  operating system
	  praeceptellum		  function
	tabula			file

****************************************************************/

#if LATIN
#define MES_SIGNON      "Interpres <Super Flumina> ad linguam BASIC, versionis"
#define MES_COPYRIGHT   "Iure proprio scriptoris (c) 1993, Eduardi de Campobello"
#define MES_COPYRIGHT_2 "Iure proprio scriptoris (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE	"Cum nuntiis latinis ab ipso E. de C."
#define PROMPT          "bwBASIC: "
#define ERROR_HEADER    "ERRANT praecepta in ordine"
#define ERRD_HEADER     "ERRANT praecepta"
#define MATHERR_HEADER  "ERRANT praecepta"
#define MES_BREAK       "Intermittuntur praecepta in ordine"
#define ERR_OPENFILE    "Non patet tabula quod <%s> vocatur"
#define ERR_GETMEM      "Deest memoria mutabilis"
#define ERR_LINENO      "Non adicitur novus ordo praeceptorum"
#define ERR_LNNOTFOUND  "Non invenitur ordo praeceptorum <%d>"
#define ERR_LOADNOFN    "LOAD requirit nomen ad tabulam"
#define ERR_NOLN        "Non invenitur ordo praeceptorum"
#define ERR_NOFN        "Non invenitur nomen ad tabulam"
#define ERR_RETNOGOSUB  "RETURN sine GOSUB"
#define ERR_INCOMPLETE  "Praeceptum imcompletum"
#define ERR_ONNOGOTO    "ON sine GOTO sive GOSUB"
#define ERR_VALOORANGE  "Numerus in praeceptis excedit fines"
#define ERR_SYNTAX      "Non sequunter praecepta"
#define ERR_DEVNUM      "Numerus ad organum invalidum est"
#define ERR_DEV         "Errat organum"
#define ERR_OPSYS	"Errant praecepta interna"
#define ERR_ARGSTR	"Praeceptum requirit litteras"
#define ERR_DEFCHAR	"ad varium definiendum"
#define ERR_MISMATCH	"Non congruunt typus"
#define ERR_DIMNOTARRAY	"Praeceptum requirit nomen ad aciem datorum"
#define ERR_OD		"Desunt data"
#define ERR_OVERFLOW	"Data excedunt fines"
#define ERR_NF		"NEXT sine FOR"
#define ERR_UF		"Non definitur praeceptellum"
#define ERR_DBZ		"Non licet divisio ab nihilo"
#define ERR_REDIM	"Non licet varium iterum definiendum"
#define ERR_OBDIM	"Debet OPTION BASE procedere DIM"
#define ERR_UC		"Praeceptum incognitum est"
#define ERR_NOPROGFILE	"Tabula praeceptorum non invenitur"
#endif

#if POL_ENGLISH
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Copyright (c) 1993, Ted A. Campbell"
#define MES_COPYRIGHT_2 "Copyright (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE	"Polite English messages courtesy of t.a.c."
#define PROMPT          "How may we help you? "
#define ERROR_HEADER    "Very sorry. There is a problem in line"
#define ERRD_HEADER     "Very sorry. There is a problem"
#define MATHERR_HEADER  "We have a small problem"
#define MES_BREAK       "At your request, the program has been interrupted at line"
#define ERR_OPENFILE    "I'm afraid we have failed \nto open file %s."
#define ERR_GETMEM      "I'm afraid we have failed \nto find sufficient memory."
#define ERR_LINENO      "I'm afraid we have failed \nto link line number."
#define ERR_LNNOTFOUND  "I'm afraid that we \ncannot find line number %d."
#define ERR_LOADNOFN    "Could you perhaps specify \nwhich file you wish to be loaded?"
#define ERR_NOLN        "It would help greatly \nif there were a line number here."
#define ERR_NOFN        "It would help greatly \nif there were a file name here."
#define ERR_RETNOGOSUB  "Is it possible \nthat there is a RETURN without a GOSUB here?"
#define ERR_INCOMPLETE  "I'm afraid that the statement\nappears to be incomplete."
#define ERR_ONNOGOTO    "It appears that there is an ON \nwithout a corresponding GOTO or GOSUB statement."
#define ERR_VALOORANGE  "A value given here \nseems to be out of range."
#define ERR_SYNTAX      "Could it be \nthat there is a syntax error at this point?"
#define ERR_DEVNUM      "The device or file \nnumber here does not seem to be correct."
#define ERR_DEV         "There appears \nto have been an error addressing the file or device \nwhich you requested."
#define ERR_OPSYS	"A most unfortunate error \nseems to have been generated by the computer's operating system."
#define ERR_ARGSTR	"Could you perhaps \nsupply a string argument at this point?"
#define ERR_DEFCHAR	"The variable definition \nat this point appears to have an improper argument."
#define ERR_MISMATCH	"It would appear \nthat something in this statement is rather seriously mismatched."
#define ERR_DIMNOTARRAY	"Could you perhaps \nsupply an array name for the argument at this point?"
#define ERR_OD		"Oh dear, we seem to have no more data to read now."
#define ERR_OVERFLOW	"Subhuman devices \ndo have their limits, and we're afraid that at this point \nthe limits of Bywater BASIC have been exceeded."
#define ERR_NF		"There seems to be \na NEXT statement without a corresponding FOR statement. Could you check on it?"
#define ERR_UF		"It would appear \nthat the function named at this point has not been defined."
#define ERR_DBZ		"Unfortunately, \ndivision by zero can cause dreadful problems in a computer."
#define ERR_REDIM	"We're very sorry \nto say that a variable such as this cannot be redimensioned."
#define ERR_OBDIM	"It would be ever so helpful \nif the OPTION BASE statement were to be called prior to the DIM statement."
#define ERR_UC		"I'm afraid that \nwe are unable to recognize the command you have given here."
#define ERR_NOPROGFILE	"Very sorry, but \nwe simply must have a program file to interpret."
#endif

#if IMP_ENGLISH
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Watch it: Copyright (c) 1993, Ted A. Campbell"
#define MES_COPYRIGHT_2 "This means you: Copyright (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE	"Impolite English messages courtesy of Oscar the Grouch"
#define PROMPT          "(*sigh) What now? "
#define ERROR_HEADER    "YOU SCREWED UP at line"
#define ERRD_HEADER     "YOU SCREWED UP"
#define MATHERR_HEADER  "ANOTHER SCREWUP!"
#define MES_BREAK       "Only a geek like you would interrupt this program at line"
#define ERR_OPENFILE    "Ha ha! I can't open file %s. Too bad, sucker."
#define ERR_GETMEM      "There isn't near enough memory \nfor this lunacy."
#define ERR_LINENO      "You jerk: \nyou entered a non-existent line number."
#define ERR_LNNOTFOUND  "You total idiot.  \nLine number %d isn't there. HA!"
#define ERR_LOADNOFN    "Get out of here. \nNo way to load that file."
#define ERR_NOLN        "Dumb bozo: you need to put \na LINE NUMBER here. Hint: Can you count?"
#define ERR_NOFN        "Nerd of the year. \nYou forgot to enter a file name. \nWhy don't you learn BASIC and come back in a year?"
#define ERR_RETNOGOSUB  "Oh come on, total amateur. \nYou've got a RETURN without a GOSUB"
#define ERR_INCOMPLETE  "Dimwit. Why don't you \ncomplete the statement here for a change."
#define ERR_ONNOGOTO    "You failed again: \nON without a GOTO or GOSUB."
#define ERR_VALOORANGE  "Go home, beginner. \nThe value here is way out of range."
#define ERR_SYNTAX      "Sure sign of a fourth-rate programmer: \nThis makes no sense at all."
#define ERR_DEVNUM      "Way to go, space cadet. \nThe device (or file) number here is totally in orbit."
#define ERR_DEV         "HO! The file or device \n you requested says: DROP DEAD."
#define ERR_OPSYS	"You obviously don't know \nwhat this computer can or can't do."
#define ERR_ARGSTR	"Do you have big ears? \n(Like Dumbo?) You obviously need a string argument at this point."
#define ERR_DEFCHAR	"Amazing. Surely children \nknow how to form a corrent argument here."
#define ERR_MISMATCH	"No way, turkey. \nThe statement here is TOTALLY mismatched."
#define ERR_DIMNOTARRAY	"Incredible. Why don't you \nsuppy an ARRAY NAME where the prograqm calls for an ARRAY NAME? (Or just go home.)"
#define ERR_OD		"Have you ever studied BASIC before? \nYou've run out of data."
#define ERR_OVERFLOW	"Congratulations on writing a program \nthat totally exceeds all limits."
#define ERR_NF		"Go back to kindergarten: \nYou have a NEXT statement FOR."
#define ERR_UF		"Trash. Total trash. \nDefine your stupid functions before calling them."
#define ERR_DBZ		"Obviously, you'll never be a programmer. \nYou've tried division by zero here."
#define ERR_REDIM	"You just don't understand: \nyou cannot redimension this variable."
#define ERR_OBDIM	"Dork. You called OPTION BASE after DIM. \nLeave me alone."
#define ERR_UC		"What do you think this is? \nTry entering a BASIC command here."
#define ERR_NOPROGFILE	"Idiot.  No way this will run without a program file."
#endif

#if STD_RUSSIAN
#define MES_SIGNON      "iNTERPRETATOR Bywater BASIC, WERSIQ"
#define MES_COPYRIGHT   "Copyright (c) 1993, Ted A. Campbell"
#define MES_COPYRIGHT_2 "Copyright (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE    ""
#define PROMPT          "gOTOWO"
#define ERROR_HEADER    "o{ibka W STROKE"
#define MATHERR_HEADER  "o{ibka"
#define MES_BREAK       "pROGRAMMA PRERWANA W STROKE"
#define ERR_OPENFILE    "nE MOGU OTKRYTX FAJL %s"
#define ERR_GETMEM      "mALO PAMQTI"
#define ERR_LINENO      "nEWERNYJ NOMER STROKI"
#define ERR_LNNOTFOUND  "sTROKA %d NE NAJDENA"
#define ERR_LOADNOFN    "LOAD: NE ZADANO IMQ FAJLA"
#define ERR_NOLN        "oTSUTSTWUET NOMER STROKI"
#define ERR_NOFN        "oTSUTSTWUET IMQ FAJLA"
#define ERR_RETNOGOSUB  "RETURN BEZ GOSUB"
#define ERR_INCOMPLETE  "nEWER[ENNYJ OPERATOR"
#define ERR_ONNOGOTO    "ON BEZ GOTO ILI GOSUB"
#define ERR_VALOORANGE  "zNA^ENIE WNE DIAPAZONA"
#define ERR_SYNTAX      "sINTAKSI^ESKAQ O[IBKA"
#define ERR_DEVNUM      "nEWERNYJ NOMER USTROJSTWA"
#define ERR_DEV         "o[IBKA USTROJSTWA"
#define ERR_OPSYS       "o[IBKA W KOMANDE OPERACIONNOJ SISTEMY"
#define ERR_ARGSTR      "aRGUMENT DOLVEN BYTX STROKOJ"
#define ERR_DEFCHAR     "nEWERNYJ ARGUMENT W OPREDELENII PEREMENNOJ"
#define ERR_MISMATCH    "nESOOTWETSTWIE TIPOW"
#define ERR_DIMNOTARRAY "aRGUMENT NE IMQ MASSIWA"
#define ERR_OD          "nET DANNYH"
#define ERR_OVERFLOW    "pEREPOLNENIE"
#define ERR_NF          "NEXT BEZ FOR"
#define ERR_UF          "nEOPREDELENNAQ FUNKCIQ"
#define ERR_DBZ         "dELENIE NA NOLX"
#define ERR_REDIM       "nELXZQ MENQTX RAZMERNOSTX PEREMENNOJ"
#define ERR_OBDIM       "OPTION BASE DOLVNA BYTX WYZWANA DO DIM"
#define ERR_UC          "nEWERNAQ KOMANDA"
#define ERR_NOPROGFILE	"Program file not specified"
#endif

/* STD_GERMAN */

#if STD_GERMAN
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Copyright (c) 1993, Ted A. Campbell"
#define MES_COPYRIGHT_2 "Copyright (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE    "Ausgegeben auf Deutsch von Joerg Rieger"
#define PROMPT          "bwBASIC: "
#define ERROR_HEADER    "Irrtum in Zeile"
#define ERRD_HEADER     "IRRTUM"
#define MATHERR_HEADER  "IRRTUM"
#define MES_BREAK       "Programm unterbrochen in Zeile"
#define ERR_OPENFILE    "Datei %s kann nict geoeffnet werden"
#define ERR_GETMEM      "Speicher kann nicht gefunden werden"
#define ERR_LINENO      "Zeilennummer kann nicht verbunden werden"
#define ERR_LNNOTFOUND  "Zeilennummer %d nicht gefunden"
#define ERR_LOADNOFN    "LOAD: Keine Dateiname angegeben"
#define ERR_NOLN        "Keine Zeilennummer"
#define ERR_NOFN        "Keine Dateiname"
#define ERR_RETNOGOSUB  "RETURN ohne GOSUB"
#define ERR_INCOMPLETE  "Angabe nicht vollstaendig"
#define ERR_ONNOGOTO    "ON ohne GOTO oder GOSUB"
#define ERR_VALOORANGE  "Wert is ausserhalb des Grenzbereits"
#define ERR_SYNTAX      "Syntax-fehler"
#define ERR_DEVNUM      "Ungueltige Geraetnummer"
#define ERR_DEV         "Geraet irrtum"
#define ERR_OPSYS       "Irrtum in Anwenden des System-Befehls"
#define ERR_ARGSTR      "Das Argument muss geradlinig sein"
#define ERR_DEFCHAR     "Falsches Argument fuer eine Variable Definition"
#define ERR_MISMATCH    "Type verwechselt"
#define ERR_DIMNOTARRAY "Das Argument ist kein Feldname"
#define ERR_OD          "Keine Daten mehr vorhanden"
#define ERR_OVERFLOW    "Ueberflutung"
#define ERR_NF          "NEXT ohne FOR"
#define ERR_UF          "Funktion nicht definiert"
#define ERR_DBZ         "Teile durch Null"
#define ERR_REDIM       "Die Variable kann nicht neu dimensioniert werdern"
#define ERR_OBDIM       "OPTION BASE muss vor DIM aufgerufen werden"
#define ERR_UC          "Befehl unbekannt"
#define ERR_NOPROGFILE  "Programm Datei nicht angegeben"
#endif

/* ESPERANTO */

#if ESPERANTO
#define MES_SIGNON      "Bywater BASIC Tradukilo/SXelo, vario"
#define MES_COPYRIGHT   "Kopirajtita (c) 1993, Ted A. Campbell"
#define MES_COPYRIGHT_2 "Kopirajtita (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE    "Esperanta traduko farigxi per Ricxjo Muelisto."
#define PROMPT          "bwBASIC: "
#define ERROR_HEADER    "ERARO en vico"
#define ERRD_HEADER     "ERARO"
#define MATHERR_HEADER  "ERARO"
#define MES_BREAK       "Programo interrompita cxe vico"
#define ERR_OPENFILE    "Malsukcesis malfermi dosieron %s"
#define ERR_GETMEM      "Malsukcesis trovi memorajxo"
#define ERR_LINENO      "Malsukcesis ligi vicnumero"
#define ERR_LNNOTFOUND  "Vicnumero %d ne trovita"
#define ERR_LOADNOFN    "LOAD: dosiernomo ne specifita"
#define ERR_NOLN        "Ne estas vicnumero"
#define ERR_NOFN        "Ne estas dosiernomo"
#define ERR_RETNOGOSUB  "RETURN sen GOSUB"
#define ERR_INCOMPLETE  "Necompleta deklaro"
#define ERR_ONNOGOTO    "ON sen GOTO aux GOSUB"
#define ERR_VALOORANGE  "Valorajxo estas eksteretenda"
#define ERR_SYNTAX      "Sintakseraro"
#define ERR_DEVNUM      "Nevalida aparatnumero"
#define ERR_DEV         "Aparateraro"
#define ERR_OPSYS       "Eraro en funkcisistema ordono"
#define ERR_ARGSTR      "Argumento devas esti serio"
#define ERR_DEFCHAR     "Erara argumento por varianto difinajxo"
#define ERR_MISMATCH    "Tipa misparo"
#define ERR_DIMNOTARRAY "Argumento ne estas kolektonomo"
#define ERR_OD          "Ne havas pli da informoj"
#define ERR_OVERFLOW    "Ektroajxo"
#define ERR_NF          "NEXT sen FOR"
#define ERR_UF          "Nedifininta funkcio"
#define ERR_DBZ         "Dividu per nulo"
#define ERR_REDIM       "Varianto ne eble esti redimensigxinta"
#define ERR_OBDIM       "OPTION BASE devas uzigxi antaux ol DIM"
#define ERR_UC          "Nekonata ordono"
#define ERR_NOPROGFILE  "Programa dosiero ne specifita"
#endif

/* Standard English is taken as a default: if MES_SIGNON is not defined by
   this time (i.e., by some other language definition), then
   the following standard English definitions are utilized. */

#ifndef MES_SIGNON
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Copyright (c) 1993, Ted A. Campbell"
#define MES_COPYRIGHT_2 "Copyright (c) 1995-1997, Jon B. Volkoff"
#define MES_LANGUAGE    " "
#define PROMPT          "bwBASIC: "
#define ERROR_HEADER    "ERROR in line"
#define ERRD_HEADER     "ERROR"
#define MATHERR_HEADER  "ERROR"
#define MES_BREAK       "Program interrupted at line"
#define ERR_OPENFILE    "Failed to open file %s"
#define ERR_GETMEM      "Failed to find memory"
#define ERR_LINENO      "Failed to link line number"
#define ERR_LNNOTFOUND  "Line number %d not found"
#define ERR_LOADNOFN    "LOAD: no filename specified"
#define ERR_NOLN        "No line number"
#define ERR_NOFN        "No file name"
#define ERR_RETNOGOSUB  "RETURN without GOSUB"
#define ERR_INCOMPLETE  "Incomplete statement"
#define ERR_ONNOGOTO    "ON without GOTO or GOSUB"
#define ERR_VALOORANGE  "Value is out of range"
#define ERR_SYNTAX      "Syntax error"
#define ERR_DEVNUM      "Invalid device number"
#define ERR_DEV         "Device error"
#define ERR_OPSYS       "Error in operating system command"
#define ERR_ARGSTR      "Argument must be a string"
#define ERR_DEFCHAR     "Incorrect argument for variable definition"
#define ERR_MISMATCH    "Type mismatch"
#define ERR_DIMNOTARRAY "Argument is not an array name"
#define ERR_OD          "Out of data"
#define ERR_OVERFLOW    "Overflow"
#define ERR_NF          "NEXT without FOR"
#define ERR_UF          "Undefined function"
#define ERR_DBZ         "Divide by zero"
#define ERR_REDIM       "Variable cannot be redimensioned"
#define ERR_OBDIM       "OPTION BASE must be called prior to DIM"
#define ERR_UC          "Unknown command"
#define ERR_NOPROGFILE  "Program file not specified"
#endif

/****************************************************************

	BASIC Command Name Definitions

	The following definitions of command names are given in
	order to allow users to redefine BASIC command names.
	No alternatives are supplied.

****************************************************************/

#ifndef CMD_SYSTEM
#define CMD_SYSTEM	"SYSTEM"
#define CMD_QUIT	"QUIT"
#define CMD_REM		"REM"
#define CMD_LET		"LET"
#define CMD_PRINT	"PRINT"
#define CMD_INPUT	"INPUT"
#define CMD_GO          "GO"
#define CMD_GOTO        "GOTO"
#define CMD_GOSUB	"GOSUB"
#define CMD_RETURN	"RETURN"
#define CMD_ON		"ON"
#define CMD_IF		"IF"
#define CMD_WHILE	"WHILE"
#define CMD_WEND	"WEND"
#define CMD_WRITE	"WRITE"
#define CMD_END		"END"
#define CMD_FOR		"FOR"
#define CMD_NEXT	"NEXT"
#define CMD_STOP	"STOP"
#define CMD_DATA	"DATA"
#define CMD_READ	"READ"
#define CMD_RESTORE	"RESTORE"
#define CMD_DIM		"DIM"
#define CMD_OPTION	"OPTION"
#define CMD_OPEN	"OPEN"
#define CMD_CLOSE	"CLOSE"
#define CMD_GET		"GET"
#define CMD_PUT		"PUT"
#define CMD_LSET	"LSET"
#define CMD_RSET	"RSET"
#define CMD_FIELD	"FIELD"
#define CMD_LINE	"LINE"
#define CMD_DEF		"DEF"
#define CMD_VARS	"VARS"
#define CMD_CMDS	"CMDS"
#define CMD_FNCS	"FNCS"
#define CMD_CHDIR	"CHDIR"
#define CMD_MKDIR	"MKDIR"
#define CMD_RMDIR	"RMDIR"
#define CMD_KILL	"KILL"
#define CMD_ENVIRON	"ENVIRON"
#define CMD_LIST	"LIST"
#define CMD_LOAD	"LOAD"
#define CMD_RUN		"RUN"
#define CMD_SAVE	"SAVE"
#define CMD_DELETE	"DELETE"
#define CMD_NEW		"NEW"
#define CMD_DEFDBL	"DEFDBL"
#define CMD_DEFINT	"DEFINT"
#define CMD_DEFSNG	"DEFSNG"
#define CMD_DEFSTR	"DEFSTR"
#define CMD_MID		"MID$"
#define CMD_CALL	"CALL"
#define CMD_SUB		"SUB"
#define CMD_FUNCTION	"FUNCTION"
#define CMD_LABEL	"lAbEl"			/* not really used: set to an unlikely combination */
#define CMD_ELSE	"ELSE"
#define CMD_ELSEIF	"ELSEIF"
#define CMD_SELECT	"SELECT"
#define CMD_CASE	"CASE"
#define CMD_MERGE	"MERGE"
#define CMD_CHAIN	"CHAIN"
#define CMD_COMMON	"COMMON"
#define CMD_ERROR	"ERROR"
#define CMD_WIDTH	"WIDTH"
#define CMD_TRON	"TRON"
#define CMD_TROFF	"TROFF"
#define CMD_RANDOMIZE	"RANDOMIZE"
#define CMD_FILES	"FILES"
#define CMD_EDIT	"EDIT"
#define CMD_RENUM	"RENUM"
#define CMD_ERASE	"ERASE"
#define CMD_SWAP	"SWAP"
#define CMD_NAME	"NAME"
#define CMD_CLEAR	"CLEAR"
#define CMD_THEN	"THEN"
#define CMD_TO		"TO"
#define CMD_STEP	"STEP"
#define CMD_DO      "DO"
#define CMD_LOCATE  "LOCATE"
#define CMD_CLS     "CLS"
#define CMD_COLOR   "COLOR"
#define CMD_LOOP	"LOOP"
#define CMD_EXIT	"EXIT"
#define CMD_XUSING      "USING"
#define CMD_XFOR        "FOR"
#define CMD_XDO		"DO"
#define CMD_XUNTIL	"UNTIL"
#define CMD_XNUM    "NUM"
#define CMD_XUNNUM	"UNNUM"
#define CMD_XSUB	"SUB"
#define CMD_XTO		"TO"
#define CMD_XERROR	"ERROR"
#define CMD_XSUB	"SUB"
#define CMD_XFUNCTION	"FUNCTION"
#define CMD_XIF		"IF"
#define CMD_XSELECT	"SELECT"
#endif

/****************************************************************

	External Definitions for Error Messages

****************************************************************/

extern char err_openfile[];
extern char err_getmem[];
extern char err_noln[];
extern char err_nofn[];
extern char err_lnnotfound[];
extern char err_incomplete[];
extern char err_valoorange[];
extern char err_syntax[];
extern char err_devnum[];
extern char err_dev[];
extern char err_opsys[];
extern char err_argstr[];
extern char err_defchar[];
extern char err_mismatch[];
extern char err_dimnotarray[];
extern char err_retnogosub[];
extern char err_od[];
extern char err_overflow[];
extern char err_nf[];
extern char err_uf[];
extern char err_dbz[];
extern char err_redim[];
extern char err_obdim[];
extern char err_uc[];
extern char err_noprogfile[];



