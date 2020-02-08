/* errdef.h / 04.07.91 / MATRIX /  WA	*/
/*          / 25.11.91 			/  HG	*/


# define ERRor "error"


/* general error codes		*/
							
ERRdef ( OK,			"ok" 										),
ERRdef ( NotOK,			"not ok" 									),

/* date format strings	*/

ERRdef ( ILLdateFormat,	"- illegal date format in text table : %%%c, allowed : %%d, %%m, %%y" ),
ERRdef ( TXdateFormat,	"%d. %m 19%y" ),
ERRdef ( TXjan,			"Jan." ),
ERRdef ( TXfeb,			"Feb." ),
ERRdef ( TXmar,			"MÑrz" ),
ERRdef ( TXapr,			"April" ),
ERRdef ( TXmay,			"Mai" ),
ERRdef ( TXjun,			"Juni" ),
ERRdef ( TXjul,			"Juli" ),
ERRdef ( TXaug,			"Aug." ),
ERRdef ( TXsep,			"Sept." ),
ERRdef ( TXoct,			"Okt." ),
ERRdef ( TXnov,			"Nov." ),
ERRdef ( TXdec,			"Dez." ),

/* Copyright header */

ERRdef ( MATgraphTCxx,	"MatGraph - TCxx" ),


/* display parameter errors	*/
							
ERRdef ( VRAMover,		"out of video memory" ),
ERRdef ( ILLframeX,		"illegal X-frame ( horizontal frequency )"	),
ERRdef ( ILLframeY,		"illegal Y-frame ( vertical frequency )"	),
ERRdef ( ILLzoomY,		"illegal Y-zoom value"						),
ERRdef ( NOoddInterlFY,	"interlaced Y-frame must be odd"			),
ERRdef ( ILLbpp,		"illegal bit per pixel value" 				),

/* command/argument errors	*/
							
ERRdef ( NOnumber,		"numeric parameter expected" 				),
ERRdef ( NOargs,		"no argument left as command parameter" 	),
ERRdef ( RANGEerror,	"range error"								),
ERRdef ( ILLcommand,	"illegal command"							),

/* system errors			*/
							
ERRdef ( NOmemory,		"out of system memory"						),
ERRdef ( FILEnotFound,	"file not found"							),

/*..... unsorted, sort in and 'make all' ..........*/

ERRdef ( NOramdac,		"no ramdac installed"						),
ERRdef ( NOargMemory,	"too many commands/arguments"				),
ERRdef ( READerror,		"file read error"							),
ERRdef ( NOinfo,		"tc-xbios not installed"					),
ERRdef ( NOTinitialised,"board not initialised"						),
ERRdef ( NOprogSpace,	"no program space allocated"				),
ERRdef ( PROGtooLarge,	"program too large"							),
ERRdef ( NOprogLoaded,	"no program loaded"							),
ERRdef ( NOgspHalt,		"gsp still running"					),
ERRdef ( CMDabort,		"command aborted"							),
ERRdef ( NOvarRef,		"variable expected"							),
ERRdef ( TOOmanyPar,	"too many parameters for command"			),
ERRdef ( ILLparSyntax,	"illegal parameter syntax"					),
ERRdef ( NOdefRef,		"definition name expected"					),
ERRdef ( GETpathError,	"can't get path"							),
ERRdef ( SETpathError,	"can't set path"							),
ERRdef ( EXECerror,		"program execution error"					),
ERRdef ( FORvarUndef,	"for variable undefined"					),
ERRdef ( CALLstackOver,	"call stack overflow, too deep nesting"		),
ERRdef ( CALLstackUnder,"call stack underflow, return unexpected"	),

ERRdef ( ILLramDacID,	"illegal ramdac id"							),

ERRdef ( I2CnotFree,	"i2c bus not released"						),
ERRdef ( I2CsdaFix,		"i2c bus data line fix"						),
ERRdef ( I2CnoACK,		"no ACK from i2c slave"						),

ERRdef ( PIXclkHigh,	"pixel clock too high for bit per pixel value"	),
ERRdef ( FILEopenError,	"can't open file"							),
ERRdef ( FILEcreateError,	"can't create file"							),
ERRdef ( SETdriveError,	"can't set drive"							),

ERRdef ( NOhwAccess,	"no board found"							),
ERRdef ( FILEwriteError,"file write error"							),

ERRdef ( DISKinfoError,	"can't get drive info"						),

ERRdef ( NOgspRun,		"gsp not running"							),
ERRdef ( NOmoduleActive,"no kernel module active"					),
ERRdef ( NObreakCode,	"no break code defined ( nmi trap )"		),
ERRdef ( MODparFew,		"too few module parameters"					),
ERRdef ( MODparMany,	"too many module parameters"				),
ERRdef ( KERNisLoaded,	"kernel already loaded"						),
ERRdef ( KERNnotLoaded,	"kernel not loaded"							),
ERRdef ( MODillNumber,	"illegal module number"						),
ERRdef ( MODnotDefined,	"module not defined"						),
ERRdef ( MODillParSize,	"illegal module parameter size"				),

ERRdef ( VRAMoutside,	"address outside of video memory"			),
ERRdef ( VRAMstructEmpty,"ref to memory descriptor block empty"		),
ERRdef ( VRAMnoSlot,	"out of video memory ( no free slot )"		),
ERRdef ( VRAMsmallSlot,	"out of video memory ( free slot too small	)" ),

ERRdef ( VMEMbadRW,		"can't read or write memory"				),
ERRdef ( VMEMbadR,		"can't read memory"							),
ERRdef ( VMEMbadW,		"can't write memory"						),
ERRdef ( VMEMcheckError,"memory test error"							),
ERRdef ( VMEMresOver,	"resolution too high for memory size"		),

ERRdef ( CXSnotFound,	"no *.CXS info file in \\MATRIX\\CXX"			),
ERRdef ( NO_ID,			"no ID in CXX-file"							),
ERRdef ( ILL_ID,		"illegal ID in CXX-file"					),
ERRdef ( ID_NOT_FOUND,	"ID not found in CXX-file"					),
ERRdef ( ILL_LINE,		"illegal line in CXX-file"					),
ERRdef ( INC_ERROR,		"too many nested includes in CXX-file"		),
ERRdef ( KERNnotInit,	"graphic kernel not initialised"			),
ERRdef ( NOclock,		"clock not running"							),
ERRdef ( VMEMbadSize,	"illegal size of memory found"				),
ERRdef ( VMEMclk1mb,	"max. TC clock at TC1006 (1MB) is 32 MHz"	),
ERRdef ( WRONGeclClock,	"wrong ECL clock selected"					),
ERRdef ( BIOSisInstalled,"BIOS already installed"					),
ERRdef ( ILLclut,		"no 15/16 bit per pixel option"				),
ERRdef ( ILLzoomX,		"illegal X-zoom value"						),
ERRdef ( NOThdtv,		"hdtv mode not selected"					),
ERRdef ( CANTrename,	"can't rename file"							),
ERRdef ( CANTdeleteDir,	"can't delete directory"					),
ERRdef ( CANTdeleteFile,"can't delete file"							),
ERRdef ( CANTmakeDir,	"can't create directory"					),

ERRdef ( NOvdiDriver,	"VDI for 2 and 4 bits/pixel not available"	),
ERRdef ( CLKsynthError,	"clock synthesizer error"					),
ERRdef ( CLKrangeError,	"clock outside of legal range"				),


/*-- TCXXINFO --*/

ERRdef ( WASinstalled,	"TCxx - Info war bereits installiert !"		),
ERRdef ( COOKIEnotInstd,"Cookie kann nicht installiert werden !"	),
ERRdef ( PRESSreturn,	"Weiter mit RETURN !"						),

ERRdef ( NOaddressPar,	"no address parameter"						),
ERRdef ( ILLoption,		"illegal option"							),
ERRdef ( ILLaddressPar,	"illegal address parameter"					),
ERRdef ( USAGE,			"usage"										),

/*...... different messages ...............*/

ERRdef ( NOkernelMatch,		"no kernel found for this memory konfiguration"	),
ERRdef ( MODinfoNotAvail,	"module info not available"				),
ERRdef ( GSPackTimeOut,		"gsp acknowledge time out"				),

ERRdef ( CMDfileNotFound,	"* command file %s not found\n" 		),
ERRdef ( FILEexistOvwrYN,	"file %s exists, overwrite Y(es)/[no] ] ? >" ),
ERRdef ( TXserialNumber,	"serial number"							),
ERRdef ( TXmonochrome,		" monochrom"							),
ERRdef ( TXnColors,			" %d Farben"							),
ERRdef ( TX15Bpp,			" Low Quality True Color ( 15 bit, 5:5:5 )"	),
ERRdef ( TX16Bpp,			" Low Quality True Color ( 16 bit, 5:6:5 )"	),
ERRdef ( TX24Bpp, 			" True Color ( 24 bit )"				),
ERRdef ( TX32Bpp, 			" True Color ( 24 + 8 bit Overlay )"	),
ERRdef ( TXillBpp,			" %d bit ( illegal ? )"					),
ERRdef ( TXwarning,			"Warning"								),
ERRdef ( TXresXxYmono,		"Auflîsung : %d x %d monochrom"			),
ERRdef ( IXinstallAbort,	"*** Installation abgebrochen\n"		),
ERRdef ( TXkeybHelp, 		"\n- Hilfe zur Tastaturbedienung mit 'Help'\n\n"	),
ERRdef ( FILEexistOvwrite,	"Datei %s existiert, Åberschreiben ?"	),
ERRdef ( TXdispMono,		"Darstellung monochrom ( schwarz / weiss )"	),
ERRdef ( TXdisp8bpp,		"Darstellung 256 Farben - 8 Bit / Pixel" ),
ERRdef ( TXdisp16bpp,		"Darstellung 65.535 Farben - 16 Bit / Pixel" ),
ERRdef ( TXdisp24bpp,		"Darstellung True Color -  16.7 Mill. Farben" ),
ERRdef ( TX3bnc,			"3-fach BNC - Kabel zum Bildschirm ( Comp. Sync )" ),
ERRdef ( TXsubD,			"SUB-D - Kabel zum Bildschirm ( Sep. Sync )" ),
ERRdef ( TXsysMode,			"System Modus : Start auf Systemschirm" ),
ERRdef ( TXdualMode,		"Dual Modus : Start auf Systemschirm, MatScreen bleibt aktiv" ),
ERRdef ( TXmatscrMode,		"Start auf MatScreen" ),
ERRdef ( TXundo,			"Standard-Parameter einstellen" ),
ERRdef ( TXsaveFxAsStd,		"F%c als Standard-Einstellung speichern" ),
ERRdef ( TXnoParFile,		"Achtung : Keine Parameterdatei vorhanden" ),
ERRdef ( TXsaveSelPar, 		"GewÑhlte Parameter sichern" ),
ERRdef ( TXtestPic, 		"Einstellung testen, danach weiter mit Leertaste oder Undo" ),
ERRdef ( TXbootConfig,		"Bootkonfiguration editieren / laden ( s. READ.ME - Datei ) " ),
ERRdef ( TXhelpInfo,		"Ausgabe Infobox + Tasten auf Systemschirm" ),
ERRdef ( TXselectFile,		"Datei %s anwÑhlen" ),
ERRdef ( TXdeleteFile,		"Datei %s lîschen" ),
ERRdef ( TXsaveFile,		"Einstellung auf %s speichern" ),
ERRdef ( TXabortToDial,		"Abbruch, zurÅck zum Start-Dialog" ),
ERRdef ( TXeditHelp,		"Editieren : Klick ESC Home \004 \003 Back Del Ins Undo Return" ),
ERRdef ( TXdispParSelect,	"Bildparameter - Auswahl" ),
ERRdef ( TXcantSetDefault,	"Can't set default parameter" ),
ERRdef ( TXerror,			"Error"							),
ERRdef ( QUfileDelete,		"Datei %s lîschen ?" 			),
ERRdef ( CANTdeleteDefault,	"Standard-Datei kann nicht gelîscht werden !" ),
ERRdef ( TXkeyUsage,		"Tastenbedienung"			),
ERRdef ( TXnoParFiles,		"- Keine Parameterdateien vorhanden\n" ),
ERRdef ( TXnoDialNest,		"- Nesting dialog not allowed\n" ),
ERRdef ( CANTloadRSC,		"Can't load RSC file" ),
ERRdef ( MSGconfig,			"Konfiguration" ),
ERRdef ( MSGtcxxParam,		"TCXX-Parameter" ),
ERRdef ( MSGautoProgs,		"AUTO-Programme" ),
ERRdef ( MSGaccessories,	"Accessories" ),
ERRdef ( ILLinput,			"Falsche Eingabe" ),
ERRdef ( NOfileType,		"Dateiname '%s' hat keinen Typ ( name.typ )" ),
ERRdef ( FILEnameNotFound,	"Datei '%s' nicht gefunden" ),
ERRdef ( FILEnotOpen,		"Datei '%s' kann nicht geîffnet werden !" ),
ERRdef ( FILEduplicate,		"Datei '%s' existiert schon" ),
ERRdef ( RENAMEerror,		"Fehler beim Umbennen von '%s'" ),
ERRdef ( CANTcreate,		"Datei '%s' kann nicht erzeugt werden !" ),
ERRdef ( YESchar,			"J" ),
ERRdef ( NOchar,			"N" ),
ERRdef ( MSGupdate,			"Update : " ),


/*
ERRdef ( 	),
*/
