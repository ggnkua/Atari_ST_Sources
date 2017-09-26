 /*  Resource C-Header-File v1.95 fÅr ResourceMaster ab v2.06 by ARDISOFT  */

#define MENUE 0  /* menu */
#define MENUE_FILE_M 4  /* TITLE in tree MENUE */
#define MENUE_WORK_M 5  /* TITLE in tree MENUE */
#define MENUE_WINDOW_M 6  /* TITLE in tree MENUE */
#define MENUE_CONFIG_M 7  /* TITLE in tree MENUE */
#define MENUE_HELP_M 8  /* TITLE in tree MENUE */
#define MENUE_ABOUT 11  /* STRING in tree MENUE */
#define MENUE_NEW 20  /* STRING in tree MENUE */
#define MENUE_OPEN 21  /* STRING in tree MENUE */
#define MENUE_QUIT 23  /* STRING in tree MENUE */
#define MENUE_SESSION 25  /* STRING in tree MENUE */
#define MENUE_RX 27  /* STRING in tree MENUE */
#define MENUE_TX 28  /* STRING in tree MENUE */
#define MENUE_CUT 30  /* STRING in tree MENUE */
#define MENUE_COPY 31  /* STRING in tree MENUE */
#define MENUE_PASTE 32  /* STRING in tree MENUE */
#define MENUE_MARK_ALL 34  /* STRING in tree MENUE */
#define MENUE_HOTLIST 36  /* STRING in tree MENUE */
#define MENUE_KONTEXT 38  /* STRING in tree MENUE */
#define MENUE_CLOSE_WIND 40  /* STRING in tree MENUE */
#define MENUE_CLOSE_ALL_WIND 41  /* STRING in tree MENUE */
#define MENUE_CYC_WIND 43  /* STRING in tree MENUE */
#define MENUE_FULL_WIND 44  /* STRING in tree MENUE */
#define MENUE_CONFIG_GENERAL 46  /* STRING in tree MENUE */
#define MENUE_CONFIG_ICONNECT 47  /* STRING in tree MENUE */
#define MENUE_CONFIG_SESSION 48  /* STRING in tree MENUE */
#define MENUE_CONFIG_TRANSFER 49  /* STRING in tree MENUE */
#define MENUE_CONFIG_SAVE 51  /* STRING in tree MENUE */
#define MENUE_HELP_ABOUT 53  /* STRING in tree MENUE */
#define MENUE_HELP_HELP 55  /* STRING in tree MENUE */
#define MENUE_HELP_CONTENT 56  /* STRING in tree MENUE */
#define MENUE_HELP_INDEX 57  /* STRING in tree MENUE */

#define POPUP_TEXT 1  /* form/dial */
#define POPUP_TEXT_OPTIONS 1  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_RX 3  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_TX 4  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_COPY 6  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_PASTE 7  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_MARK_ALL 9  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_CLOSE 11  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_CYC_WIND 13  /* STRING in tree POPUP_TEXT */
#define POPUP_TEXT_FULL_WIND 14  /* STRING in tree POPUP_TEXT */
/* Terminalfenster */
#define POPUP_TEXT_HELP 16  /* STRING in tree POPUP_TEXT */

#define POPUP_HOTLIST 2  /* form/dial */

#define POPUP_OPTIONS 3  /* form/dial */
#define POPUP_OPTIONS_VIEW 1  /* STRING in tree POPUP_OPTIONS */
#define POPUP_OPTIONS_TELNET 2  /* STRING in tree POPUP_OPTIONS */
#define POPUP_OPTIONS_TERMINAL 3  /* STRING in tree POPUP_OPTIONS */
#define POPUP_OPTIONS_OTHER 4  /* STRING in tree POPUP_OPTIONS */

#define POPUP_EMULATION 4  /* form/dial */
#define POPUP_EMULATION_NVT 1  /* STRING in tree POPUP_EMULATION */
#define POPUP_EMULATION_VT52 2  /* STRING in tree POPUP_EMULATION */
#define POPUP_EMULATION_VT100 3  /* STRING in tree POPUP_EMULATION */

#define POPUP_COLOR 5  /* form/dial */

#define POPUP_KEY 6  /* form/dial */

#define POPUP_CURSOR 7  /* form/dial */
#define POPUP_CURSOR_NORMAL 1  /* STRING in tree POPUP_CURSOR */
#define POPUP_CURSOR_APPLICATION 2  /* STRING in tree POPUP_CURSOR */

#define POPUP_KEYPAD 8  /* form/dial */
#define POPUP_KEYPAD_NORMAL 1  /* STRING in tree POPUP_KEYPAD */
#define POPUP_KEYPAD_APPLICATION 2  /* STRING in tree POPUP_KEYPAD */

#define ICONIFY 9  /* form/dial */
#define ICONIFY_BOX 0  /* BOX in tree ICONIFY */
#define ICONIFY_ICON 1  /* CICON in tree ICONIFY */

#define ABOUT 10  /* form/dial */
#define MOT 2  /* STRING in tree ABOUT */
#define ABOUT_VERSION 4  /* STRING in tree ABOUT */
#define ABOUT_DATE 5  /* STRING in tree ABOUT */
#define ABOUT_DRACONIS 6  /* STRING in tree ABOUT */
#define ABOUT_ICONNECT 7  /* STRING in tree ABOUT */
#define ABOUT_SER 10  /* TEXT in tree ABOUT */
#define ABOUT_NAME 12  /* TEXT in tree ABOUT */
#define ABOUT_FIRMA 13  /* TEXT in tree ABOUT */
/* Schlieût den Dialog. */
#define ABOUT_OK 19  /* BUTTON in tree ABOUT */

#define UPDATE 11  /* form/dial */
#define UPDATE_SIZE_PARENT 2  /* BOX in tree UPDATE */
#define UPDATE_SIZE 3  /* STRING in tree UPDATE */
#define UPDATE_TIME_PARENT 5  /* BOX in tree UPDATE */
#define UPDATE_TIME 6  /* STRING in tree UPDATE */
#define UPDATE_CPS_PARENT 8  /* BOX in tree UPDATE */
#define UPDATE_CPS 9  /* STRING in tree UPDATE */
#define UPDATE_SLDR_BACK 10  /* FBOXTEXT in tree UPDATE */
#define UPDATE_SLDR 11  /* BOX in tree UPDATE */

#define OPTIONS 12  /* form/dial */
/* Hier wird die Schriftart sowie Schriftfarbe und Hintergrundfarbe eines Terminalfensters festgelegt. */
#define OPTIONS_VIEW 1  /* BUTTON in tree OPTIONS */
/* Zeichensatz, der fÅr die Darstellung in den Terminalfenstern benutzt wird. */
#define OPTIONS_FONTNAME 5  /* BUTTON in tree OPTIONS */
/* Farbe fÅr die Textdarstellung in den Terminalfenstern.|Auf bereits geîffnete Telnet-Sitzungen hat eine énderung keine Auswirkung. */
#define OPTIONS_FONTCOLOR_TEXT 6  /* STRING in tree OPTIONS */
#define OPTIONS_FONTCOLOR_BOX 7  /* BUTTON in tree OPTIONS */
#define OPTIONS_FONTCOLOR 8  /* BOX in tree OPTIONS */
/* Farbe des Hintergrunds der Terminalfenster.|Auf bereits geîffnete Telnet-Sitzungen hat eine énderung keine Auswirkung. */
#define OPTIONS_WINDOWCOLOR_TEXT 9  /* STRING in tree OPTIONS */
#define OPTIONS_WINDOWCOLOR_BOX 10  /* BUTTON in tree OPTIONS */
#define OPTIONS_WINDOWCOLOR 11  /* BOX in tree OPTIONS */
/* Anzahl der Zeilen, die maximal im Speicher gehalten werden sollen. */
#define OPTIONS_PUFLINES_TEXT 12  /* STRING in tree OPTIONS */
#define OPTIONS_PUFLINES 13  /* FTEXT in tree OPTIONS */
/* In dieser Kategorie wird der Name des Rechners und der Port eingegeben. */
#define OPTIONS_TELNET 14  /* BUTTON in tree OPTIONS */
/* Name des Rechners zu dem eine Telnet-Verbindung aufgebaut werden soll. */
#define OPTIONS_HOST_TEXT 18  /* STRING in tree OPTIONS */
#define OPTIONS_HOST 19  /* FTEXT in tree OPTIONS */
/* Nummer des Ports fÅr die Telnet-Verbindung.|Telnet-Server verwenden Åblicherweise den Port 23. */
#define OPTIONS_PORT_TEXT 20  /* STRING in tree OPTIONS */
#define OPTIONS_PORT 21  /* FTEXT in tree OPTIONS */
/* Hier wird die Emulation sowie die Grîûe in Spalten und Zeilen eines Terminalfensters festgelegt. */
#define OPTIONS_TERMINAL 22  /* BUTTON in tree OPTIONS */
/* Emulation, die in der Telnet-Sitzung verwendet wird.|Auf bereits geîffnete Telnet-Sitzungen hat eine énderung keine Auswirkung. */
#define OPTIONS_EMULATION_TEXT 27  /* STRING in tree OPTIONS */
#define OPTIONS_EMULATION 28  /* BUTTON in tree OPTIONS */
/* Anzahl der Spalten eines Termnalfensters. */
#define OPTIONS_COLUMNS_TEXT 29  /* STRING in tree OPTIONS */
#define OPTIONS_COLUMNS 30  /* FTEXT in tree OPTIONS */
/* Anzahl der Zeilen eines Terminalfenster. */
#define OPTIONS_ROWS_TEXT 31  /* STRING in tree OPTIONS */
#define OPTIONS_ROWS 32  /* FTEXT in tree OPTIONS */
/* Hier wird das Verhalten der Cursortasten zwischen normal und Applikation umgestellt. */
#define OPTIONS_CURSOR_TEXT 33  /* STRING in tree OPTIONS */
#define OPTIONS_CURSOR 34  /* BUTTON in tree OPTIONS */
/* Hier wird das Verhalten des Ziffernblocks zwischen numerisch und Applikation umgestellt. */
#define OPTIONS_KEYPAD_TEXT 35  /* STRING in tree OPTIONS */
#define OPTIONS_KEYPAD 36  /* BUTTON in tree OPTIONS */
/* In dieser Kategorie werden die Filter fÅr aus- und eingehende Zeichen und die AbstÑnde der Tabulatoren festgelegt. */
#define OPTIONS_OTHER 37  /* BUTTON in tree OPTIONS */
/* Hier wird der Zeichensatz festgelegt, der fÅr die Darstellung eingehender Zeichen verwendet wird (Filter fÅr eingehende Zeichen). */
#define OPTIONS_KEY_IMPORT_TEXT 41  /* STRING in tree OPTIONS */
#define OPTIONS_KEY_IMPORT 42  /* BUTTON in tree OPTIONS */
/* Hier wird festgelegt, wie Sonderzeichen versendet werden (Filter fÅr ausgehende Zeichen). */
#define OPTIONS_KEY_EXPORT_TEXT 43  /* STRING in tree OPTIONS */
#define OPTIONS_KEY_EXPORT 44  /* BUTTON in tree OPTIONS */
/* Weite der vertikalen und horizontalen Tabulatoren in Leerzeichen. Die Werte mÅssen jeweils grîûer als 0 sein. */
#define OPTIONS_TAB_TEXT 45  /* STRING in tree OPTIONS */
#define OPTIONS_TAB_H 46  /* FTEXT in tree OPTIONS */
#define OPTIONS_TAB_V 48  /* FTEXT in tree OPTIONS */
/* Von der Telnet-Sitzung wird ein Protokoll erstellt.|Das Verzeichnis in das Protokolle abgespeichert werden, legen Sie im Dialog 'Optionen: Allgemein' fest. */
#define OPTIONS_PROTOCOL 49  /* BUTTON in tree OPTIONS */

#define NEW 13  /* form/dial */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define NEW_KAT_TEXT 1  /* STRING in tree NEW */
#define NEW_KAT 2  /* BUTTON in tree NEW */
#define NEW_OPTIONS 4  /* BOX in tree NEW */
/* Ruft ein Popup-MenÅ mit den EintrÑgen der Hotlist auf. */
#define NEW_HOTLIST 5  /* BUTTON in tree NEW */
#define NEW_HOTLIST_I 6  /* CICON in tree NEW */
/* Schlieût den Dialog und îffnet eine Telnet-Sitzung. Sind die Angaben fÅr den Host oder fÅr den Port nicht korrekt oder unvollstÑndig, kann dieser Button nicht angeklickt werden. */
#define NEW_OK 7  /* BUTTON in tree NEW */
#define NEW_OK_I 8  /* CICON in tree NEW */
/* Schlieût den Dialog ohne eine Telnet-Sitzung zu îffnen. */
#define NEW_CANCEL 9  /* BUTTON in tree NEW */

#define TEXT 14  /* form/dial */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define TEXT_KAT_TEXT 1  /* STRING in tree TEXT */
#define TEXT_KAT 2  /* BUTTON in tree TEXT */
#define TEXT_OPTIONS 3  /* BOX in tree TEXT */
/* énderungen an den Parametern der Sitzung (z.B. Spalten und Zeilen) werden von Teli dem Server mitgeteilt. */
#define TEXT_REPORT_CHANGE 4  /* BUTTON in tree TEXT */
/* öbernimmt die aktuellen Einstellungen ohne den Dialog zu schlieûen */
#define TEXT_SET 5  /* BUTTON in tree TEXT */
/* Schlieût den Dialog und Åbernimmt die getÑtigten Einstellungen. */
#define TEXT_OK 6  /* BUTTON in tree TEXT */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define TEXT_CANCEL 7  /* BUTTON in tree TEXT */

#define HOTLIST 15  /* form/dial */
#define HOTLIST_ENTRY_UP 2  /* BOXCHAR in tree HOTLIST */
#define HOTLIST_ENTRY_BOX 3  /* IBOX in tree HOTLIST */
#define HOTLIST_ENTRY_0 4  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_1 5  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_2 6  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_3 7  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_4 8  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_5 9  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_6 10  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_7 11  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_8 12  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_9 13  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_10 14  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_11 15  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_12 16  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_13 17  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_14 18  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_15 19  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_BACK_V 20  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_SL_V 21  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_DOWN 22  /* BOXCHAR in tree HOTLIST */
#define HOTLIST_ENTRY_LEFT 23  /* BOXCHAR in tree HOTLIST */
#define HOTLIST_ENTRY_BACK_H 24  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_SL_H 25  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_RIGHT 26  /* BOXCHAR in tree HOTLIST */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define HOTLIST_KAT_TEXT 27  /* STRING in tree HOTLIST */
#define CSESSION_KAT_00 28  /* BUTTON in tree HOTLIST */
#define HOTLIST_KAT 29  /* BUTTON in tree HOTLIST */
#define HOTLIST_OPTIONS 31  /* BOX in tree HOTLIST */
/* Name des Hotlisteintrags. */
#define HOTLIST_ENTRY_NAME_TEXT 32  /* STRING in tree HOTLIST */
#define HOTLIST_ENTRY_NAME 33  /* FTEXT in tree HOTLIST */
/* FÅgt der Hotlist einen neuen Eintrag mit den obigen Parametern und Namen hinzu. */
#define HOTLIST_ADD 34  /* BUTTON in tree HOTLIST */
#define HOTLIST_ADD_I 35  /* CICON in tree HOTLIST */
/* éndert den selektierten Eintrag mit den obigen Parametern und Namen ab. */
#define HOTLIST_CHANGE 36  /* BUTTON in tree HOTLIST */
#define HOTLIST_CHANGE_I 37  /* CICON in tree HOTLIST */
/* Lîscht den selektierten Eintrag. */
#define HOTLIST_DEL 38  /* BUTTON in tree HOTLIST */
#define HOTLIST_DEL_I 39  /* CICON in tree HOTLIST */

#define CSESSION 16  /* form/dial */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define CSESSION_KAT_TEXT 1  /* STRING in tree CSESSION */
#define CSESSION_KAT 2  /* BUTTON in tree CSESSION */
#define CSESSION_OPTIONS 3  /* BOX in tree CSESSION */
/* Schlieût den Dialog und Åbernimmt die getÑtigten Einstellungen. */
#define CSESSION_OK 4  /* BUTTON in tree CSESSION */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define CSESSION_CANCEL 5  /* BUTTON in tree CSESSION */

#define CIC 17  /* form/dial */
/* IConnect wird beim ôffnen einer Telnet-Sitzung automatisch gestartet. */
#define CIC_ICONNECT_START 6  /* BUTTON in tree CIC */
/* Nach dem Start von IConnect wird unverzÅglich die Verbindung zum Internet hergestellt. */
#define CIC_ICONNECT_CONNECT 7  /* BUTTON in tree CIC */
#define CIC_ICONNECT_DISCONNECT 9  /* BUTTON in tree CIC */
#define CIC_ICONNECT_LAST 10  /* BUTTON in tree CIC */
#define CIC_ICONNECT_QUIT 11  /* BUTTON in tree CIC */
/* Schlieût den Dialog und Åbernimmt alle getÑtigten Einstellungen. */
#define CIC_OK 12  /* BUTTON in tree CIC */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define CIC_CANCEL 13  /* BUTTON in tree CIC */

#define CGENERAL 18  /* form/dial */
/* Je grîûer der Empfangspuffer ist, umso mehr Zeichen werden von Teli in einem Rutsch verarbeitet. Auf langsamen Rechnern empfiehlt sich eine Grîûe um die 16 Bytes. */
#define CGENERAL_RPUF_TEXT 2  /* STRING in tree CGENERAL */
#define CGENERAL_RPUF 3  /* FTEXT in tree CGENERAL */
/* Verzeichnis, in welchem die Protokolldateien gespeichert werden.|Ob von einer Telnet-Sitzungen ein Protokoll erstellt wird, legen Sie bei den Parameter (Kategorie Sonstiges) der jeweiligen Telnet-Sitzung fest. */
#define CGENERAL_PROTOCOL_TEXT 4  /* STRING in tree CGENERAL */
#define CGENERAL_PROTOCOL 5  /* FTEXT in tree CGENERAL */
/* Hat Teli eine Sitzung erfolgreich eingerichtet oder wird diese wieder geschlossen gibt Teli ein akustisches Signal. */
#define CGENERAL_PING 6  /* BUTTON in tree CGENERAL */
/* Beim Beenden von Teli werden die Optionen und die Hotlist gesichert. */
#define CGENERAL_SAVE 7  /* BUTTON in tree CGENERAL */
/* Schlieût den Dialog und Åbernimmt alle getÑtigten Einstellungen. */
#define CGENERAL_OK 8  /* BUTTON in tree CGENERAL */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define CGENERAL_CANCEL 9  /* BUTTON in tree CGENERAL */
/* Existiert bereits eine Protokolldatei von einer vorhergehenden Telnet-Sitzung, wird diese nicht gelîscht, sondern das Protokoll wird angehÑngt. */
#define CGENERAL_PROTOCOL_APPEND 10  /* BUTTON in tree CGENERAL */

#define CTRANSFER 19  /* form/dial */
/* Zugriffspfad fÅr das externe Empfangsprogramm. */
#define CTRANSFER_RX_TEXT 6  /* STRING in tree CTRANSFER */
#define CTRANSFER_RX 7  /* FTEXT in tree CTRANSFER */
/* Parameter fÅr das Empfangsprogramm. */
#define CTRANSFER_RX_DATA_TEXT 8  /* STRING in tree CTRANSFER */
#define CTRANSFER_RX_DATA 9  /* FTEXT in tree CTRANSFER */
/* Zugriffspfad fÅr das externe Sendeprogramm. */
#define CTRANSFER_TX_TEXT 10  /* STRING in tree CTRANSFER */
#define CTRANSFER_TX 11  /* FTEXT in tree CTRANSFER */
/* Parameter fÅr das Sendeprogramm. */
#define CTRANSFER_TX_DATA_TEXT 12  /* STRING in tree CTRANSFER */
#define CTRANSFER_TX_DATA 13  /* FTEXT in tree CTRANSFER */
/* Schlieût den Dialog und Åbernimmt alle getÑtigten Einstellungen. */
#define CTRANSFER_OK 14  /* BUTTON in tree CTRANSFER */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define CTRANSFER_CANCEL 15  /* BUTTON in tree CTRANSFER */

#define HELP 20  /* form/dial */
/* Inhaltsverzeichnis */
#define HELP_CONTENT 1  /* STRING in tree HELP */
/* Index */
#define HELP_INDEX 2  /* STRING in tree HELP */

#define ALERT 21  /* form/dial */
#define ALERT_LINE_0 1  /* STRING in tree ALERT */
#define ALERT_LINE_1 2  /* STRING in tree ALERT */
#define ALERT_LINE_2 3  /* STRING in tree ALERT */
#define ALERT_LINE_3 4  /* STRING in tree ALERT */
#define ALERT_LINE_4 5  /* STRING in tree ALERT */
#define ALERT_BUTTON_0 6  /* BUTTON in tree ALERT */
#define ALERT_BUTTON_1 7  /* BUTTON in tree ALERT */
#define ALERT_BUTTON_2 8  /* BUTTON in tree ALERT */
#define ALERT_ICON_0 9  /* CICON in tree ALERT */
#define ALERT_ICON_1 10  /* CICON in tree ALERT */
#define ALERT_ICON_2 11  /* CICON in tree ALERT */

#define ALERTS 22  /* form/dial */
#define WDLG_MISSING 1  /* STRING in tree ALERTS */
#define SOCKETS_NOT_INST 2  /* STRING in tree ALERTS */
#define SOCKETS_TOO_OLD 3  /* STRING in tree ALERTS */
#define DNS_FAILED 4  /* STRING in tree ALERTS */
#define SOCKET_FAILED 5  /* STRING in tree ALERTS */
#define CONNECT_FAILED 6  /* STRING in tree ALERTS */
#define DD_ONLY_TEXT 7  /* STRING in tree ALERTS */
#define DD_NO 8  /* STRING in tree ALERTS */
#define DD_FAILED 9  /* STRING in tree ALERTS */
#define DD_NO_TELNET_URL 10  /* STRING in tree ALERTS */
#define FONT_NOT_MONO 11  /* STRING in tree ALERTS */
#define ERROR_WRITING_CONFIG 12  /* STRING in tree ALERTS */
#define CLOSE_SESSION 13  /* STRING in tree ALERTS */
#define ICONNECT_LOST 14  /* STRING in tree ALERTS */
#define TAB_H 15  /* STRING in tree ALERTS */
#define TAB_V 16  /* STRING in tree ALERTS */
#define EDDI_MISSING 17  /* STRING in tree ALERTS */
#define KEYT_MISSING 18  /* STRING in tree ALERTS */
#define CONNECTION_CLOSED 19  /* STRING in tree ALERTS */
#define BITMAP_FAILED 20  /* STRING in tree ALERTS */
#define QUIT_APP 21  /* STRING in tree ALERTS */
#define NO_TELNET_URL 22  /* STRING in tree ALERTS */
#define TOO_OLD 23  /* STRING in tree ALERTS */
#define CODE_OK 24  /* STRING in tree ALERTS */
#define CODE_NOT_OK 25  /* STRING in tree ALERTS */
#define RX_START_FAILED 26  /* STRING in tree ALERTS */
#define TX_START_FAILED 27  /* STRING in tree ALERTS */
#define ICONNECT_NO_AV 28  /* STRING in tree ALERTS */
#define ICONNECT_NOT_DESKTOP 29  /* STRING in tree ALERTS */
#define ICONNECT_TOO_OLD 30  /* STRING in tree ALERTS */
#define ICONNECT_CONNECTION 31  /* STRING in tree ALERTS */
#define UPDATE_NONEWVERSION 32  /* STRING in tree ALERTS */
#define UPDATE_VERSION 33  /* STRING in tree ALERTS */
#define UPDATE_ERRTMPDIR 34  /* STRING in tree ALERTS */
#define UPDATE_ERRDOWNLOAD 35  /* STRING in tree ALERTS */
#define UPDATE_ERRINSTAL 36  /* STRING in tree ALERTS */
#define UPDATE_SUCESS 37  /* STRING in tree ALERTS */

#define TITLES 23  /* form/dial */
#define TITLE_WINDOW 1  /* STRING in tree TITLES */
#define TITLE_ABOUT 2  /* STRING in tree TITLES */
#define TITLE_NEW 3  /* STRING in tree TITLES */
#define TITLE_CIC 4  /* STRING in tree TITLES */
#define TITLE_ICON 5  /* STRING in tree TITLES */
#define TITLE_CSESSION 6  /* STRING in tree TITLES */
#define TITLE_GENERAL 7  /* STRING in tree TITLES */
#define TITLE_TEXT 8  /* STRING in tree TITLES */
#define TITLE_HOTLIST 9  /* STRING in tree TITLES */
#define TITLE_REG 10  /* STRING in tree TITLES */
#define TITLE_CTRANSFER 11  /* STRING in tree TITLES */
#define FSEL_RX 12  /* STRING in tree TITLES */
#define FSEL_TX 13  /* STRING in tree TITLES */
#define FSEL_PROTOCOL 14  /* STRING in tree TITLES */
#define ICON_BIG 15  /* CICON in tree TITLES */
#define ICON_SMALL 16  /* CICON in tree TITLES */
#define TITLE_UPDATE 17  /* STRING in tree TITLES */
#define FSEL_UPDATE_PATH 18  /* STRING in tree TITLES */

#define INFOS 24  /* form/dial */
#define TCP_GETHOSTBYNAME 1  /* STRING in tree INFOS */
#define TCP_CONNECT 2  /* STRING in tree INFOS */
#define TCP_INTERNET 3  /* STRING in tree INFOS */
#define TCP_DISCONNECT 4  /* STRING in tree INFOS */
#define TCP_ETABLISHED 5  /* STRING in tree INFOS */
#define UPDATE_INFO 6  /* STRING in tree INFOS */
#define UPDATE_DOWNLOAD 7  /* STRING in tree INFOS */
#define UPDATE_UPDATE 8  /* STRING in tree INFOS */
#define UPDATE_END 9  /* STRING in tree INFOS */
