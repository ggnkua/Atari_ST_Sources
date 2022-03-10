/*
**	Keyword defs of IOSmail 0.85 and higher.
**
**	Keyword binairy outfit.
*/

#define	COMMAND	0xFEFE
#define SYSOP	0xFEFD
#define ADRES	0xFEFC
#define NETMAIL	0xFEFB
#define LOGFILE	0xFEFA
#define	LOGLEVEL	0xFEF9
#define NOLOG	0xFEF8
#define NODISP	0xFEF7
#define MAILTEMP	0xFEF6
#define PKTTEMP		0xFEF5
#define OUTBOUND	0xFEF4
#define INBOUND		0xFEF3
#define KNINBOUND	0xFEF2
#define PRINBOUND	0xFEF1
#define TRASHAREA	0xFEF0
#define ARCHIVER	0xFEEF
#define LZHARC		0xFEEE
#define ZIPARC		0xFEED
#define ARCARC		0xFEEC
#define ARJARC		0xFEEB
#define APPLZONE	0xFEEA
#define BINKLEY		0xFEE9
#define THEBOX		0xFEE8
#define PASSWORD	0xFEE7
#define BOSS		0xFEE6
#define COPYAREA	0xFEE5
#define MOVEAREA	0xFEE4
#define COPYPOINT	0xFEE3
#define FDATABASE	0xFEE2
#define FDGETFROM	0xFEE1
#define MINPKTSIZE	0xFEE0
#define NONETMAILP	0xFEDF
#define REDIRECTN	0xFEDE
#define ADDAKA		0xFEDD
#define PATHCHECK	0xFEDC
#define NOZONE		0xFEDB
#define NICEOUTPUT	0xFEDA
#define QBBSLASTRD	0xFED9
#define MINDISKSPC	0xFED8
#define MINMSGS		0xFED7
#define MAXMSGS		0xFED6
#define DEFDAYS		0xFED5
#define COMPACTMSG	0xFED4
#define KEEPPRIVATE	0xFED3
#define KILLS		0xFED2
#define MSGREPORT	0xFED1
#define REALNAME	0xFED0
#define KILLALL		0xFECF
#define COPYPVTMAIL	0xFECE
#define PACKKNOWN	0xFECD
#define AREAFIX		0xFECC
#define CAPTURE		0xFECB
#define SAVELOCAL	0xFECA
#define SAVESCREEN	0xFEC9
#define ARC_FOR		0xFEC8
#define MOVE_MAIL	0xFEC7
#define HOLD_FOR	0xFEC6
#define ROUTE		0xFEC5
#define FILE_TO		0xFEC4
#define PREPARE_POL	0xFEC3
#define HOLD_POLL	0xFEC2
#define CRASH_TO	0xFEC1
#define HOLD_MAX	0xFEC0
#define HOLD_DEL	0xFEBF
#define FILE_MAX	0xFEBE
#define EVENT		0xFEBD
#define STARTLABEL	0xFEBC
#define ENDOFLABEL	0xFEBB
#define NO_LABEL	0xFEBA
#define KILLFROM	0xFEB9

#define E_OL		0xFAFF	/*	End Of Line		*/
#define E_OS		0xFAFE	/*	End Of String	*/
#define E_STR		0xFAFD	/*	Empty string	*/

/*
**	Areas.Bbs binairy outfit.
*/

#define MAINORGIN	0xF0FF	/*	Main origin line	*/
#define AREA_PATH	0xF0FE	/*	Path to area		*/
#define AREA_NAME	0xF0FD	/*	Name of area		*/
#define AREA_ORG	0xF0FC	/*	Area orgin			*/
#define NODES_CON	0xF0FB	/*	Nodes connected		*/
