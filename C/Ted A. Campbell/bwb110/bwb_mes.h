/***************************************************************

        bwb_mes.h       Header File for Natural-Language-Specific
                        Text Messages for Bywater BASIC Interpreter

                        Copyright (c) 1992, Ted A. Campbell

                        Bywater Software
                        P. O. Box 4023
                        Duke Station
                        Durham, NC  27706

                        email: tcamp@acpub.duke.edu

        Copyright and Permissions Information:

        All U.S. and international copyrights are claimed by the
        author. The author grants permission to use this code
        and software based on it under the following conditions:
        (a) in general, the code and software based upon it may be
        used by individuals and by non-profit organizations; (b) it
        may also be utilized by governmental agencies in any country,
        with the exception of military agencies; (c) the code and/or
        software based upon it may not be sold for a profit without
        an explicit and specific permission from the author, except
        that a minimal fee may be charged for media on which it is
        copied, and for copying and handling; (d) the code must be
        distributed in the form in which it has been released by the
        author; and (e) the code and software based upon it may not
        be used for illegal activities.

***************************************************************/


#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

/* Define only one of the following as TRUE: if none is defined,
   standard ENGLISH will be taken as the default */

#define ENGLISH         TRUE		/* standard English */
#define POL_ENGLISH     FALSE		/* polite English messages */
#define IMP_ENGLISH	FALSE		/* impolite English messages */
#define LATIN		FALSE		/* Latin language messages */

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
#define MES_SIGNON      "Interpres et Crusta <Super Flumina> ad linguam BASIC, versionis"
#define MES_COPYRIGHT   "Iure proprio scriptoris (c) 1992, Eduardi de Campobello"
#define MES_LANGUAGE	"Cum nuntiis latinis ab ipso E. de C."
#define PROMPT          "bwBASIC:"
#define ERROR_HEADER    "ERRANT praecepta in ordine"
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
#endif

#if POL_ENGLISH
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Copyright (c) 1992, Ted A. Campbell"
#define MES_LANGUAGE	"Polite English messages courtesy of t.a.c."
#define PROMPT          "How may we help you?"
#define ERROR_HEADER    "Very sorry. There is a problem in line"
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
#endif

#if IMP_ENGLISH
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Watch it: Copyright (c) 1992, Ted A. Campbell"
#define MES_LANGUAGE	"Impolite English messages courtesy of Oscar the Grouch"
#define PROMPT          "(*sigh) What now?"
#define ERROR_HEADER    "YOU SCREWED UP at line"
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
#endif

/* Standard English is taken as a default: if MES_SIGNON is not defined by
   this time (i.e., by some other language definition), then
   the following standard English definitions are utilized. */

#ifndef MES_SIGNON
#define MES_SIGNON      "Bywater BASIC Interpreter/Shell, version"
#define MES_COPYRIGHT   "Copyright (c) 1992, Ted A. Campbell"
#define MES_LANGUAGE	"Default English-Language Messages"
#define PROMPT          "bwBasic:"
#define ERROR_HEADER    "ERROR in line"
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
#define ERR_OPSYS	"Error in operating system command"
#define ERR_ARGSTR	"Argument must be a string"
#define ERR_DEFCHAR	"Incorrect argument for variable definition"
#define ERR_MISMATCH	"Type mismatch"
#define ERR_DIMNOTARRAY	"Argument is not an array name"
#define ERR_OD		"Out of data"
#define ERR_OVERFLOW	"Overflow"
#define ERR_NF		"NEXT without FOR"
#define ERR_UF		"Undefined function"
#define ERR_DBZ		"Divide by zero"
#define ERR_REDIM	"Variable cannot be redimensioned"
#define ERR_OBDIM	"OPTION BASE must be called prior to DIM"
#define ERR_UC		"Unknown command"
#endif

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
extern char err_od[];
extern char err_overflow[];
extern char err_nf[];
extern char err_uf[];
extern char err_dbz[];
extern char err_redim[];
extern char err_obdim[];
extern char err_uc[];
