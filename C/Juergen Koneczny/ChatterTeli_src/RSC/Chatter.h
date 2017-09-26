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
#define MENUE_CUT 25  /* STRING in tree MENUE */
#define MENUE_COPY 26  /* STRING in tree MENUE */
#define MENUE_PASTE 27  /* STRING in tree MENUE */
#define MENUE_MARK_ALL 29  /* STRING in tree MENUE */
#define MENUE_HOTLIST 31  /* STRING in tree MENUE */
#define MENUE_CLOSE_WIND 33  /* STRING in tree MENUE */
#define MENUE_CLOSE_ALL_WIND 34  /* STRING in tree MENUE */
#define MENUE_CYC_WIND 36  /* STRING in tree MENUE */
#define MENUE_FULL_WIND 37  /* STRING in tree MENUE */
#define MENUE_CONFIG_GENERAL 39  /* STRING in tree MENUE */
#define MENUE_CONFIG_ICONNECT 40  /* STRING in tree MENUE */
#define MENUE_CONFIG_SESSION 41  /* STRING in tree MENUE */
#define MENUE_CONFIG_SAVE 43  /* STRING in tree MENUE */
#define MENUE_HELP_ABOUT 45  /* STRING in tree MENUE */
#define MENUE_HELP_HELP 47  /* STRING in tree MENUE */
#define MENUE_HELP_CONTENT 48  /* STRING in tree MENUE */
#define MENUE_HELP_INDEX 49  /* STRING in tree MENUE */

#define POPUP_HOTLIST 1  /* form/dial */

#define POPUP_OPTIONS 2  /* form/dial */
#define POPUP_OPTIONS_COLORS 1  /* STRING in tree POPUP_OPTIONS */
#define POPUP_OPTIONS_SESSION 2  /* STRING in tree POPUP_OPTIONS */
#define POPUP_OPTIONS_OTHER 3  /* STRING in tree POPUP_OPTIONS */
#define POPUP_OPTIONS_FONTS 4  /* STRING in tree POPUP_OPTIONS */

#define POPUP_COLOR 3  /* form/dial */

#define POPUP_COLOURTABLE 4  /* form/dial */
#define COLOURTABLE_MYSELF 1  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_MSGWITHNICK 2  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_OP_MSG 3  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_SERVER_MSG 4  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_MSG 5  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_ACTION 6  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_AWAY_MSG 7  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_MSG_BACK 8  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_INPUT 10  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_INPUT_BACK 11  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_CHANNEL 13  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_CHANNEL_BACK 14  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_USER 16  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_USER_VOICE 17  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_USER_OP 18  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_USER_IRCOP 19  /* STRING in tree POPUP_COLOURTABLE */
#define COLOURTABLE_USER_BACK 20  /* STRING in tree POPUP_COLOURTABLE */

#define POPUP_IRC 5  /* form/dial */
#define IRC_MSG 1  /* STRING in tree POPUP_IRC */
#define IRC_DCCCHAT 2  /* STRING in tree POPUP_IRC */
#define IRC_DCCTX 3  /* STRING in tree POPUP_IRC */
#define IRC_INVITE 5  /* STRING in tree POPUP_IRC */
#define IRC_OP 7  /* STRING in tree POPUP_IRC */
#define IRC_DEOP 8  /* STRING in tree POPUP_IRC */
#define IRC_VOICE 10  /* STRING in tree POPUP_IRC */
#define IRC_DEVOICE 11  /* STRING in tree POPUP_IRC */
#define IRC_KICK 13  /* STRING in tree POPUP_IRC */
#define IRC_BAN 14  /* STRING in tree POPUP_IRC */
#define IRC_KICKBAN 15  /* STRING in tree POPUP_IRC */
#define IRC_DEBAN 16  /* STRING in tree POPUP_IRC */
#define IRC_CTCP 18  /* STRING in tree POPUP_IRC */

#define POPUP_CTCP 6  /* form/dial */

#define ICONIFY 7  /* form/dial */
#define ICONIFY_BOX 0  /* BOX in tree ICONIFY */
#define ICONIFY_ICON 1  /* CICON in tree ICONIFY */

#define WCHAT 8  /* form/dial */
#define WCHAT_CHANNEL 1  /* IBOX in tree WCHAT */
/* ôffnet einen Dialog, mit dem Sie einen Teilnehmer in einen Channel einladen kînnen. */
#define WCHAT_INVITE 2  /* BOXTEXT in tree WCHAT */
/* ôffnet einen Dialog, mit dem Sie die Modi fÅr den Channel einstellen kînnen. */
#define WCHAT_CHANNELMODE 3  /* BOXTEXT in tree WCHAT */
/* ôffnet einen Dialog, mit dem Sie das Thema des Channels Ñndern kînnen. */
#define WCHAT_TOPIC 4  /* BOXTEXT in tree WCHAT */
/* ôffnet das Fenster fÅr die Teilnehmerliste. */
#define WCHAT_WHO 5  /* BOXTEXT in tree WCHAT */
#define WCHAT_CONSOLE 6  /* IBOX in tree WCHAT */
/* ôffnet einen Dialog, mit dem Sie eine automatische Anwort auf Nachrichten von Teilnehmern setzen kînnen. */
#define WCHAT_AWAY 15  /* BOXTEXT in tree WCHAT */
/* ôffnet das Fenster fÅr die Channelliste. */
#define WCHAT_LIST 16  /* BOXTEXT in tree WCHAT */
/* ôffnet einen Dialog, mit dem Sie die Teilnehmer-Modi fÅr sich einstellen kînnen. */
#define WCHAT_USERMODE 17  /* BOXTEXT in tree WCHAT */
/* ôffnet einen Dialog, mit dem Sie Ihren Nickname Ñndern kînnen. */
#define WCHAT_NICK 18  /* BOXTEXT in tree WCHAT */
/* Ruft einen Konfigurationsdialog auf. */
#define WCHAT_INFO 7  /* CICON in tree WCHAT */
/* Mitteilungsfenster */
#define WCHAT_HELP 8  /* CICON in tree WCHAT */
#define WCHAT_OUTPUT_PARENT2 11  /* BOX in tree WCHAT */
#define WCHAT_OUTPUT_PARENT1 9  /* IBOX in tree WCHAT */
#define WCHAT_OUTPUT 10  /* USERDEF in tree WCHAT */
#define WCHAT_INPUT_PARENT2 14  /* BOX in tree WCHAT */
#define WCHAT_INPUT_PARENT1 12  /* IBOX in tree WCHAT */
#define WCHAT_INPUT 13  /* BOX in tree WCHAT */
#define WCHAT_USER 19  /* IBOX in tree WCHAT */
#define WCHAT_DCC 20  /* IBOX in tree WCHAT */

#define WCHANNEL 9  /* form/dial */
#define WCHANNEL_UPDATE_PARENT 1  /* IBOX in tree WCHANNEL */
/* Fordert die Liste der Channels beim IRC-Server neu an.|Diese Aktion benîtigt mehrere Minuten. */
#define WCHANNEL_UPDATE 2  /* CICON in tree WCHANNEL */
/* ôffnet ein Channelfenster. */
#define WCHANNEL_OPEN 3  /* BUTTON in tree WCHANNEL */
#define WCHANNEL_OPEN_I 4  /* CICON in tree WCHANNEL */
#define WCHANNEL_EDIT 5  /* FTEXT in tree WCHANNEL */
/* Channelliste */
#define WCHANNEL_HELP 6  /* CICON in tree WCHANNEL */
#define WCHANNEL_OUTPUT_PARENT2 7  /* BOX in tree WCHANNEL */
#define WCHANNEL_OUTPUT_PARENT1 8  /* IBOX in tree WCHANNEL */
#define WCHANNEL_OUTPUT 9  /* USERDEF in tree WCHANNEL */
#define WCHANNEL_CHANNEL 10  /* BOXTEXT in tree WCHANNEL */
#define WCHANNEL_CHANNEL_SORT 11  /* ICON in tree WCHANNEL */
#define WCHANNEL_N 12  /* BOXTEXT in tree WCHANNEL */
#define WCHANNEL_N_SORT 13  /* ICON in tree WCHANNEL */
#define WCHANNEL_TOPIC 14  /* BOXTEXT in tree WCHANNEL */

#define WNAMES 10  /* form/dial */
#define WNAMES_WIDTH 1  /* IBOX in tree WNAMES */
/* Fordert die Liste der Teilnehmer beim IRC-Server neu an. */
#define WNAMES_UPDATE 2  /* CICON in tree WNAMES */
/* ôffnet einen privaten Chat Åber das DCC-Protokoll mit einem (selektierten) Teilnehmer. */
#define WNAMES_DCCCHAT 3  /* BOXTEXT in tree WNAMES */
/* ôffnet einen privaten Chat mit einem (selektierten) Teilnehmer Åber den IRC-Server. */
#define WNAMES_MSG 4  /* BOXTEXT in tree WNAMES */
/* Gibt einem (selektierten) Teilnehmer die Rechte eines Verwalters des Channels. */
#define WNAMES_OP 5  /* BOXTEXT in tree WNAMES */
/* Verbannt einen (selektierten) Teilnehmer aus dem Channel. */
#define WNAMES_BAN 6  /* BOXTEXT in tree WNAMES */
/* Wirft einen (selektierten) Teilnehmer aus dem Channel.|Halten Sie beim Klick die Shift-Taste gedrÅckt, kînnen Sie einen Kommentar eingeben. */
#define WNAMES_KICK 7  /* BOXTEXT in tree WNAMES */
/* Gibt einem (selektierten) Teilnehmer das Schreibrecht. */
#define WNAMES_VOICE 8  /* BOXTEXT in tree WNAMES */
/* Ruft ein Popup mit einigen CTCP-Kommandos auf. */
#define WNAMES_CTCP 9  /* BOXTEXT in tree WNAMES */
/* ôffnet einen Dialog, mit dem Sie Dateien Åber das DCC-Protokoll zu einen (selektierten) Teilnehmer senden kînnen. */
#define WNAMES_DCCFILE 10  /* BOXTEXT in tree WNAMES */
/* LÑdt einen (selektierten) Teilnehmer in einen Channel ein. */
#define WNAMES_INVITE 11  /* BOXTEXT in tree WNAMES */
/* Entzieht einem (selektierten) Teilnehmer die Rechte eines Channel-Verwalters. */
#define WNAMES_DEOP 12  /* BOXTEXT in tree WNAMES */
/* Macht die Verbannung eines (selektierten) Teilnehmer aus dem Channel rÅckgÑngig. */
#define WNAMES_DEBAN 13  /* BOXTEXT in tree WNAMES */
/* Wirft einen (selektierten) Teilnehmer aus dem Channel und verbannt ihn.|Halten Sie beim Klick die Shift-Taste gedrÅckt, kînnen Sie einen Kommentar eingeben. */
#define WNAMES_BANKICK 14  /* BOXTEXT in tree WNAMES */
/* Entzieht einem (selektierten) Teilnehmer das Schreibrecht. */
#define WNAMES_DEVOICE 15  /* BOXTEXT in tree WNAMES */
#define WNAMES_SWITCH_PARENT 16  /* BOX in tree WNAMES */
/* Schaltet die Liste zwischen verschiedenen Darstellungen um. */
#define WNAMES_SWITCH 17  /* CICON in tree WNAMES */
/* Teilnehmerliste */
#define WNAMES_HELP 18  /* CICON in tree WNAMES */
#define WNAMES_OUTPUT_PARENT2 19  /* BOX in tree WNAMES */
#define WNAMES_OUTPUT_PARENT1 20  /* IBOX in tree WNAMES */
#define WNAMES_NICKNAME 21  /* BOXTEXT in tree WNAMES */
#define WNAMES_NICKNAME_SORT 22  /* ICON in tree WNAMES */
#define WNAMES_USERNAME 23  /* BOXTEXT in tree WNAMES */
#define WNAMES_USERNAME_SORT 24  /* ICON in tree WNAMES */
#define WNAMES_REALNAME 25  /* BOXTEXT in tree WNAMES */
#define WNAMES_REALNAME_SORT 26  /* ICON in tree WNAMES */
#define WNAMES_CHANNELS 27  /* BOXTEXT in tree WNAMES */
#define WNAMES_CHANNELS_SORT 28  /* ICON in tree WNAMES */
#define WNAMES_SERVER 29  /* BOXTEXT in tree WNAMES */
#define WNAMES_SERVER_SORT 30  /* ICON in tree WNAMES */
#define WNAMES_HOST 31  /* BOXTEXT in tree WNAMES */
#define WNAMES_HOST_SORT 32  /* ICON in tree WNAMES */
#define WNAMES_IDLE 33  /* BOXTEXT in tree WNAMES */
#define WNAMES_IDLE_SORT 34  /* ICON in tree WNAMES */
#define WNAMES_OUTPUT 35  /* USERDEF in tree WNAMES */

#define INFOD 11  /* form/dial */
#define OPTIONS_OTHER_02 2  /* BUTTON in tree INFOD */
/* Anzahl der Zeilen, die in dieses Mitteilungsfenster puffern. */
#define INFOD_NLINES_TEXT 5  /* STRING in tree INFOD */
#define INFOD_NLINES 6  /* FTEXT in tree INFOD */
/* Das Mitteilungsfenster speichert ein Protokoll.|Das Verzeichnis in das Protokolle abgespeichert werden, legen Sie im Dialog 'Optionen: Allgemein' fest. */
#define INFOD_LOG 7  /* BUTTON in tree INFOD */
#define INFOD_IRC 8  /* BUTTON in tree INFOD */
/* Chatter antwortet auf PING mit einem PONG und verhindert damit, daû der Server die Verbindung beendet. */
#define INFOD_PINGPONG 11  /* BUTTON in tree INFOD */
/* Chatter antwortet auf CTCP-Anfragen anderer Clients. */
#define INFOD_CTCP 12  /* BUTTON in tree INFOD */
/* Schlieût den Dialog und Åbernimmt die getÑtigten Einstellungen. */
#define INFOD_OK 13  /* BUTTON in tree INFOD */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define INFOD_CANCEL 14  /* BUTTON in tree INFOD */

#define NIU 12  /* form/dial */
#define NIU_NICKNAME 3  /* STRING in tree NIU */
#define NIU_NEW 6  /* FTEXT in tree NIU */
/* Richtet die Sitzung mit dem neuem Nickname ein. */
#define NIU_OK 7  /* BUTTON in tree NIU */
/* Schlieût den Dialog ohne eine IRC-Sitzung zu îffnen. */
#define NIU_CANCEL 8  /* BUTTON in tree NIU */

#define NN 13  /* form/dial */
#define NN_NEW 3  /* FTEXT in tree NN */
/* Setzt den neuen Nickname. */
#define NN_OK 4  /* BUTTON in tree NN */
/* Schlieût den Dialog ohne den Nickname zu Ñndern. */
#define NN_CANCEL 5  /* BUTTON in tree NN */

#define KICK 14  /* form/dial */
#define KICK_BAN 5  /* IBOX in tree KICK */
#define KICK_BANKICK 7  /* IBOX in tree KICK */
#define KICK_NICK 10  /* FTEXT in tree KICK */
#define KICK_COMMENT 11  /* IBOX in tree KICK */
/* Mit diesem Text wird der Teilnehmer aus dem Channel geworfen. */
#define KICK_TEXT 12  /* FTEXT in tree KICK */
/* Schlieût den Dialog und Ñndert den Status des angegebenen Teilnehmers. */
#define KICK_OK 14  /* BUTTON in tree KICK */
/* Schlieût den Dialog ohne den Status eines Teilnehmers zu Ñndern. */
#define KICK_CANCEL 15  /* BUTTON in tree KICK */
#define KICK_DEBAN 16  /* IBOX in tree KICK */
#define KICK_KICK 3  /* IBOX in tree KICK */

#define OP 15  /* form/dial */
#define OP_OP 3  /* IBOX in tree OP */
#define OP_DEOP 5  /* IBOX in tree OP */
#define OP_NICK 8  /* FTEXT in tree OP */
/* Schlieût den Dialog und Ñndert den Status des angegebenen Teilnehmers. */
#define OP_OK 9  /* BUTTON in tree OP */
/* Schlieût den Dialog ohne den Status eines Teilnehmers zu Ñndern. */
#define OP_CANCEL 10  /* BUTTON in tree OP */
#define OP_DEVOICE 11  /* IBOX in tree OP */
#define OP_VOICE 14  /* IBOX in tree OP */

#define AWAY 16  /* form/dial */
#define AWAY_TEXT 4  /* FTEXT in tree AWAY */
/* Schlieût den Dialog und setzt die automatische Anwort. */
#define AWAY_OK 5  /* BUTTON in tree AWAY */
/* Schlieût den Dialog ohne die automatische Antwort zu verÑndern. */
#define AWAY_CANCEL 6  /* BUTTON in tree AWAY */

#define CMODE 17  /* form/dial */
#define CMODE_INVITE_SET 5  /* BUTTON in tree CMODE */
#define CMODE_INVITE 6  /* BUTTON in tree CMODE */
#define CMODE_NOTINVITE 7  /* BUTTON in tree CMODE */
#define CMODE_LIMIT_SET 9  /* BUTTON in tree CMODE */
#define CMODE_LIMIT 10  /* BUTTON in tree CMODE */
#define CMODE_NOTLIMIT 11  /* BUTTON in tree CMODE */
#define CMODE_LIMIT_N 12  /* FTEXT in tree CMODE */
#define CMODE_MOD_SET 14  /* BUTTON in tree CMODE */
#define CMODE_MOD 15  /* BUTTON in tree CMODE */
#define CMODE_NOTMOD 16  /* BUTTON in tree CMODE */
#define CMODE_MES_SET 18  /* BUTTON in tree CMODE */
#define CMODE_MES 19  /* BUTTON in tree CMODE */
#define CMODE_NOTMES 20  /* BUTTON in tree CMODE */
#define CMODE_PRIVAT_SET 22  /* BUTTON in tree CMODE */
#define CMODE_PRIVAT 23  /* BUTTON in tree CMODE */
#define CMODE_NOTPRIVAT 24  /* BUTTON in tree CMODE */
#define CMODE_SECRET_SET 26  /* BUTTON in tree CMODE */
#define CMODE_SECRET 27  /* BUTTON in tree CMODE */
#define CMODE_NOTSECRET 28  /* BUTTON in tree CMODE */
#define CMODE_TOPIC_SET 30  /* BUTTON in tree CMODE */
#define CMODE_TOPIC 31  /* BUTTON in tree CMODE */
#define CMODE_NOTTOPIC 32  /* BUTTON in tree CMODE */
/* Schlieût den Dialog und setzt die angegebenen Modi. */
#define CMODE_OK 33  /* BUTTON in tree CMODE */
/* Schlieût den Dialog ohne die Modi zu Ñndern. */
#define CMODE_CANCEL 34  /* BUTTON in tree CMODE */

#define UMODE 18  /* form/dial */
#define UMODE_VISIBLE_SET 5  /* BUTTON in tree UMODE */
#define UMODE_VISIBLE 6  /* BUTTON in tree UMODE */
#define UMODE_NOTVISIBLE 7  /* BUTTON in tree UMODE */
#define UMODE_NOTICE_SET 9  /* BUTTON in tree UMODE */
#define UMODE_NOTICE 10  /* BUTTON in tree UMODE */
#define UMODE_NOTNOTICE 11  /* BUTTON in tree UMODE */
#define UMODE_WALLOPS_SET 13  /* BUTTON in tree UMODE */
#define UMODE_WALLOPS 14  /* BUTTON in tree UMODE */
#define UMODE_NOTWALLOPS 15  /* BUTTON in tree UMODE */
/* Schlieût den Dialog und setzt die angegebenen Modi. */
#define UMODE_OK 16  /* BUTTON in tree UMODE */
/* Schlieût den Dialog ohne die Modi zu Ñndern. */
#define UMODE_CANCEL 17  /* BUTTON in tree UMODE */

#define INVITE 19  /* form/dial */
#define INVITE_NICK 3  /* FTEXT in tree INVITE */
#define INVITE_CHANNEL 5  /* FTEXT in tree INVITE */
/* Schlieût den Dialog und lÑdt den Teilnehmer in den Channel ein. */
#define INVITE_OK 7  /* BUTTON in tree INVITE */
/* Schlieût den Dialog ohne den Teilnehmer einzuladen. */
#define INVITE_CANCEL 8  /* BUTTON in tree INVITE */

#define TOPIC 20  /* form/dial */
#define TOPIC_TEXT 3  /* FTEXT in tree TOPIC */
/* Schlieût den Dialog und setzt das angegebene Thema fÅr den Channel. */
#define TOPIC_OK 4  /* BUTTON in tree TOPIC */
/* Schlieût den Dialog ohne das Thema des Channels zu Ñndern. */
#define TOPIC_CANCEL 5  /* BUTTON in tree TOPIC */

#define INVITED 21  /* form/dial */
#define ALERT_ICON_0_00 1  /* CICON in tree INVITED */
#define INVITED_NICK 3  /* STRING in tree INVITED */
#define INVITED_NICK_00 4  /* STRING in tree INVITED */
#define INVITED_CHANNEL 5  /* STRING in tree INVITED */
#define INVITED_CHANNEL_00 6  /* STRING in tree INVITED */
/* ôffnet den Channel, in den Sie eingeladen wurden. */
#define INVITED_OK 7  /* BUTTON in tree INVITED */
#define WCHANNEL_OPEN_I_00 8  /* CICON in tree INVITED */
/* Schlieût den Dialog ohne den Channel, in den Sie eingeladen wurden, zu îffnen. */
#define INVITED_CANCEL 9  /* BUTTON in tree INVITED */

#define MSG 22  /* form/dial */
#define MSG_NICK 3  /* FTEXT in tree MSG */
/* Schlieût den Dialog ohne den direkten Chat einzurichten. */
#define MSG_ABORT 4  /* BUTTON in tree MSG */
#define MSG_DCCCHAT 5  /* STRING in tree MSG */
/* Schlieût den Dialog und îffnet ein Fenster zum Chatten mit dem Teilnehmer. */
#define MSG_OK 6  /* BUTTON in tree MSG */
#define MSG_OK_I 7  /* CICON in tree MSG */
#define MSG_CHAT 8  /* IBOX in tree MSG */

#define GET 23  /* form/dial */
#define GET_NICK 2  /* STRING in tree GET */
#define GET_FILE 5  /* STRING in tree GET */
#define GET_SIZE 7  /* STRING in tree GET */
/* Unter diesem Namen wird die Datei abgespeichert. */
#define GET_NEW 9  /* FTEXT in tree GET */
/* Schlieût den Dialog und empfÑngt die Datei. */
#define GET_OK 10  /* BUTTON in tree GET */
/* Schlieût den Dialog ohne die Datei zu empfangen. */
#define GET_CANCEL 11  /* BUTTON in tree GET */

#define PUT 24  /* form/dial */
#define PUT_NICK 2  /* FTEXT in tree PUT */
/* Dateitransfer */
#define PUT_HELP 3  /* CICON in tree PUT */
#define PUT_PACKET_SIZE 5  /* FTEXT in tree PUT */
#define PUT_OUTPUT_PARENT2 6  /* BOX in tree PUT */
#define PUT_OUTPUT_PARENT1 7  /* IBOX in tree PUT */
#define PUT_OUTPUT 8  /* USERDEF in tree PUT */
#define PUT_SIZE 9  /* BOXTEXT in tree PUT */
#define PUT_SIZE_SORT 10  /* ICON in tree PUT */
#define PUT_NAME 11  /* BOXTEXT in tree PUT */
#define PUT_NAME_SORT 12  /* ICON in tree PUT */
#define PUT_OUTPUT_BOTTOM 13  /* BOX in tree PUT */
#define PUT_N 15  /* STRING in tree PUT */
#define PUT_SIZEOVERALL 17  /* STRING in tree PUT */
#define PUT_BOTTOM 18  /* BOX in tree PUT */
/* Schlieût den Dialog ohne die Datei(en) zu senden. */
#define PUT_CANCEL 19  /* BUTTON in tree PUT */
/* Schlieût den Dialog und sendet die Datei(en). */
#define PUT_OK 20  /* BUTTON in tree PUT */
#define PUT_OK_I 21  /* CICON in tree PUT */
/* ôffnet die Dateiauswahl, um eine Datei der Liste hinzuzufÅgen.|Sie kînnen Dateien auch per Drag&Drop der Liste hinzufÅgen. */
#define PUT_ADD 22  /* BUTTON in tree PUT */
#define PUT_ADD_I 23  /* CICON in tree PUT */
/* Lîscht die selektierte(n) Datei(en) aus der Liste. */
#define PUT_DEL 24  /* BUTTON in tree PUT */
#define PUT_DEL_I 25  /* CICON in tree PUT */

#define DATA 25  /* form/dial */
#define DATA_FILE 2  /* STRING in tree DATA */
#define DATA_SIZE_PARENT 4  /* BOX in tree DATA */
#define DATA_SIZE 5  /* STRING in tree DATA */
#define DATA_TIME_PARENT 7  /* BOX in tree DATA */
#define DATA_TIME 8  /* STRING in tree DATA */
#define DATA_CPS_PARENT 10  /* BOX in tree DATA */
#define DATA_CPS 11  /* STRING in tree DATA */
#define DATA_SLDR_BACK 12  /* FBOXTEXT in tree DATA */
#define DATA_SLDR 13  /* BOX in tree DATA */

#define CTCP 26  /* form/dial */
#define CTCP_NICKNAME 4  /* FTEXT in tree CTCP */
#define CTCP_CMD 6  /* FTEXT in tree CTCP */
/* Ruft ein Popup mit einigen CTCP-Kommandos auf. */
#define CTCP_POPUP 7  /* BUTTON in tree CTCP */
/* Schlieût den Dialog und setzt das CTCP-Kommando ab. */
#define CTCP_OK 8  /* BUTTON in tree CTCP */
/* Schlieût den Dialog ohne das CTCP-Kommando aabzusetzen. */
#define CTCP_CANCEL 9  /* BUTTON in tree CTCP */

#define OPTIONS 27  /* form/dial */
/* In dieser Kategorie werden die Farben fÅr verschiedene Mitteilungen, die Hintergrundfarben der Fenster und fÅr Channels und Teilnehmer festgelegt. */
#define OPTIONS_COLORS 1  /* BUTTON in tree OPTIONS */
#define OPTIONS_CBOX_PARENT 6  /* BOX in tree OPTIONS */
#define OPTIONS_CTEXT 7  /* USERDEF in tree OPTIONS */
#define OPTIONS_CBOX 8  /* USERDEF in tree OPTIONS */
#define OPTIONS_CBOX_SLDR_UP 9  /* BOXCHAR in tree OPTIONS */
#define OPTIONS_CBOX_SLDR_BACK 10  /* BOX in tree OPTIONS */
#define OPTIONS_CBOX_SLDR 11  /* BOX in tree OPTIONS */
#define OPTIONS_CBOX_SLDR_DOWN 12  /* BOXCHAR in tree OPTIONS */
/* In dieser Kategorie werden die ZeichensÑtze fÅr die Eingabezeile, Mitteilungen, Channel-Liste und Teilnehmer-Liste festgelegt. */
#define OPTIONS_FONTS 13  /* BUTTON in tree OPTIONS */
/* Zeichensatz fÅr die Eingabezeile der Mitteilungsfenster. */
#define OPTIONS_FONTNAME_INPUT 18  /* BUTTON in tree OPTIONS */
/* Zeichensatz fÅr die Darstellung der Mitteilungen. */
#define OPTIONS_FONTNAME_OUTPUT 20  /* BUTTON in tree OPTIONS */
/* Zeichensatz fÅr die Darstellung der Channel-Liste. */
#define OPTIONS_FONTNAME_CHANNEL 22  /* BUTTON in tree OPTIONS */
/* Zeichensatz fÅr die Darstellung der Teilnehmer-Liste. */
#define OPTIONS_FONTNAME_USER 24  /* BUTTON in tree OPTIONS */
/* In dieser Kategorie werden die Daten fÅr eine IRC-Sitzung festgelegt. */
#define OPTIONS_SESSION 25  /* BUTTON in tree OPTIONS */
#define ICON_SMALL_00 27  /* CICON in tree OPTIONS */
/* Name des Rechners zu dem eine IRC-Sitzung aufgebaut werden soll. */
#define OPTIONS_HOST_TEXT 29  /* STRING in tree OPTIONS */
#define OPTIONS_HOST 30  /* FTEXT in tree OPTIONS */
/* Nummer des Ports fÅr die IRC-Sitzung.|IRC-Server verwenden Åblicherweise den Port 6666 oder 6667. */
#define OPTIONS_PORT_TEXT 31  /* STRING in tree OPTIONS */
#define OPTIONS_PORT 32  /* FTEXT in tree OPTIONS */
/* Der Name unter dem Sie in den Channels erscheinen und angesprochen werden kînnen. Ein bestimmter Nickname kann nicht von zwei Teilnehmern gleichzeitig benutzt werden. */
#define OPTIONS_NICKNAME_TEXT 33  /* STRING in tree OPTIONS */
#define OPTIONS_NICKNAME 34  /* FTEXT in tree OPTIONS */
#define OPTIONS_USERNAME_TEXT 35  /* STRING in tree OPTIONS */
#define OPTIONS_USERNAME 36  /* FTEXT in tree OPTIONS */
#define OPTIONS_REALNAME_TEXT 37  /* STRING in tree OPTIONS */
#define OPTIONS_REALNAME 38  /* FTEXT in tree OPTIONS */
#define OPTIONS_OTHER 39  /* BUTTON in tree OPTIONS */
/* Anzahl der Zeilen, die die Mitteilungsfenster puffern. */
#define OPTIONS_NLINES_TEXT 43  /* STRING in tree OPTIONS */
#define OPTIONS_NLINES 44  /* FTEXT in tree OPTIONS */
/* Die hier angegebenen Channels werden nach einem erfolgreichen Verbindungsaufbau geîffnet.|Mehrere Channels werden mit einem Komma getrennt. */
#define OPTIONS_AUTOJOIN_TEXT 45  /* STRING in tree OPTIONS */
#define OPTIONS_AUTOJOIN 46  /* FTEXT in tree OPTIONS */
/* Chatter antwortet auf PING mit einem PONG und verhindert damit, daû der Server die Verbindung beendet. */
#define OPTIONS_OTHER_PINGPONG 47  /* BUTTON in tree OPTIONS */
/* Chatter antwortet auf CTCP-Anfragen anderer Clients. */
#define OPTIONS_OTHER_CTCP 48  /* BUTTON in tree OPTIONS */
/* Von der Sitzung werden Protokolle erstellt.|Das Verzeichnis in das Protokolle abgespeichert werden, legen Sie im Dialog 'Optionen: Allgemein' fest. */
#define OPTIONS_LOG 49  /* BUTTON in tree OPTIONS */

#define ABOUT 28  /* form/dial */
#define MOT 2  /* STRING in tree ABOUT */
#define ABOUT_VERSION 4  /* STRING in tree ABOUT */
#define ABOUT_DATE 5  /* STRING in tree ABOUT */
#define ABOUT_ICONNECT 6  /* STRING in tree ABOUT */
#define ABOUT_DRACONIS 7  /* STRING in tree ABOUT */
/* Schlieût den Dialog. */
#define ABOUT_OK 18  /* BUTTON in tree ABOUT */

#define UPDATE 29  /* form/dial */
#define UPDATE_SIZE_PARENT 2  /* BOX in tree UPDATE */
#define UPDATE_SIZE 3  /* STRING in tree UPDATE */
#define UPDATE_TIME_PARENT 5  /* BOX in tree UPDATE */
#define UPDATE_TIME 6  /* STRING in tree UPDATE */
#define UPDATE_CPS_PARENT 8  /* BOX in tree UPDATE */
#define UPDATE_CPS 9  /* STRING in tree UPDATE */
#define UPDATE_SLDR_BACK 10  /* FBOXTEXT in tree UPDATE */
#define UPDATE_SLDR 11  /* BOX in tree UPDATE */

#define NEW 30  /* form/dial */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define NEW_KAT_TEXT 1  /* STRING in tree NEW */
#define NEW_KAT 2  /* BUTTON in tree NEW */
#define NEW_OPTIONS 4  /* BOX in tree NEW */
/* Ruft ein Popup-MenÅ mit den EintrÑgen der Hotlist auf. */
#define NEW_HOTLIST 5  /* BUTTON in tree NEW */
#define NEW_HOTLIST_I 6  /* CICON in tree NEW */
/* Schlieût den Dialog und îffnet eine IRC-Sitzung. */
#define NEW_OK 7  /* BUTTON in tree NEW */
#define NEW_OK_I 8  /* CICON in tree NEW */
/* Schlieût den Dialog ohne eine IRC-Sitzung zu îffnen. */
#define NEW_CANCEL 9  /* BUTTON in tree NEW */

#define HOTLIST 31  /* form/dial */
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
#define HOTLIST_ENTRY_16 20  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_17 21  /* TEXT in tree HOTLIST */
#define HOTLIST_ENTRY_BACK_V 22  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_SL_V 23  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_DOWN 24  /* BOXCHAR in tree HOTLIST */
#define HOTLIST_ENTRY_LEFT 25  /* BOXCHAR in tree HOTLIST */
#define HOTLIST_ENTRY_BACK_H 26  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_SL_H 27  /* BOX in tree HOTLIST */
#define HOTLIST_ENTRY_RIGHT 28  /* BOXCHAR in tree HOTLIST */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define HOTLIST_KAT_TEXT 29  /* STRING in tree HOTLIST */
#define HOTLIST_KAT 30  /* BUTTON in tree HOTLIST */
#define HOTLIST_OPTIONS 32  /* BOX in tree HOTLIST */
/* Name des Hotlist-Eintrags. */
#define HOTLIST_ENTRY_NAME_TEXT 33  /* STRING in tree HOTLIST */
#define HOTLIST_ENTRY_NAME 34  /* FTEXT in tree HOTLIST */
/* FÅgt der Hotlist einen neuen Eintrag mit den obigen Parametern und Namen hinzu. */
#define HOTLIST_ADD 35  /* BUTTON in tree HOTLIST */
#define HOTLIST_ADD_I 36  /* CICON in tree HOTLIST */
/* éndert den selektierten Eintrag mit den obigen Parametern und Namen ab. */
#define HOTLIST_CHANGE 37  /* BUTTON in tree HOTLIST */
#define HOTLIST_CHANGE_I 38  /* CICON in tree HOTLIST */
/* Lîscht den selektierten Eintrag. */
#define HOTLIST_DEL 39  /* BUTTON in tree HOTLIST */
#define HOTLIST_DEL_I 40  /* CICON in tree HOTLIST */

#define CIC 32  /* form/dial */
/* IConnect wird beim ôffnen einer IRC-Sitzung automatisch gestartet. */
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

#define CSESSION 33  /* form/dial */
/* Wechselt zwischen den verschiedenen Kategorien. */
#define CSESSION_KAT_TEXT 1  /* STRING in tree CSESSION */
#define CSESSION_KAT 2  /* BUTTON in tree CSESSION */
#define CSESSION_OPTIONS 3  /* BOX in tree CSESSION */
/* Schlieût den Dialog und Åbernimmt alle getÑtigten Einstellungen. */
#define CSESSION_OK 4  /* BUTTON in tree CSESSION */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define CSESSION_CANCEL 5  /* BUTTON in tree CSESSION */

#define CGENERAL 34  /* form/dial */
#define OPTIONS_OTHER_00 2  /* BUTTON in tree CGENERAL */
/* Verzeichnis in dem empfangene Dateien abgespeichert werden. */
#define CGENERAL_DOWNLOAD_TEXT 6  /* STRING in tree CGENERAL */
#define CGENERAL_DOWNLOAD 7  /* FTEXT in tree CGENERAL */
/* Verzeichnis aus dem Dateien gesendet werden. */
#define CGENERAL_UPLOAD_TEXT 8  /* STRING in tree CGENERAL */
#define CGENERAL_UPLOAD 9  /* FTEXT in tree CGENERAL */
/* Verzeichnis in dem die Protokolle gespeichert werden. */
#define CGENERAL_LOG_TEXT 10  /* STRING in tree CGENERAL */
#define CGENERAL_LOG 11  /* FTEXT in tree CGENERAL */
/* Existiert bereits eine Protokolldatei von einer vorhergehenden IRC-Sitzung, wird diese nicht gelîscht, sondern das Protokoll wird angehÑngt. */
#define CGENERAL_LOG_APPEND 12  /* BUTTON in tree CGENERAL */
#define OPTIONS_OTHER_03 13  /* BUTTON in tree CGENERAL */
/* Das Fenster fÅr die Channelliste wird nach einem erfolgreichen Verbindungsaufbau automatisch geîffnet. */
#define CGENERAL_AUTOCHANNEL 17  /* BUTTON in tree CGENERAL */
/* Das Fenster fÅr die Teilnehmerliste wird beim Betreten eines Channels automatisch geîffnet. */
#define CGENERAL_AUTONAMES 18  /* BUTTON in tree CGENERAL */
#define OPTIONS_OTHER_01 19  /* BUTTON in tree CGENERAL */
/* Wurde eine freie Stelle gefunden, so wird das Fenster in die linke obere Ecke dieser Stelle plaziert, anstatt zentriert. */
#define CGENERAL_WINDOWTOPLEFT 20  /* BUTTON in tree CGENERAL */
/* Die intelligente Plazierung tritt nur dann in Kraft, wenn an der Original-Position kein Platz mehr wÑre. */
#define CGENERAL_WINDOWONLY 21  /* BUTTON in tree CGENERAL */
/* Die Fenster werden beim ôffnen automatisch an einer mîglichst gÅnstigen Stelle plaziert. Falls gesetzt berÅcksichtigt Chatter auch $SCREENBORDER. */
#define CGENERAL_WINDOW 23  /* BUTTON in tree CGENERAL */
#define OPTIONS_OTHER_04 24  /* BUTTON in tree CGENERAL */
/* Die Farben und ZeichensÑtze fÅr die Fenster werden von frÅheren Sitzungen Åbernommen. Hatten Sie einen Channel also schonmal geîffnet, ignoriert Chatter die Einstellungen der 'Hotlist' oder aus 'Neue Sitzung îffnen'. */
#define CGENERAL_OVERWRITE 28  /* BUTTON in tree CGENERAL */
/* In den Mitteilungsfenstern wird Ihr Nickname vor Ihren Mitteilungen gesetzt. */
#define CGENERAL_OWNNICK 29  /* BUTTON in tree CGENERAL */
/* Wird Ihr Nickname von einem anderen Teilnehmer geschrieben, bringt Chatter das entsprechende Mitteilungsfenster in den Vordergrund. */
#define CGENERAL_TOPWITHNICK 30  /* BUTTON in tree CGENERAL */
/* In den Mitteilungsfenstern werden Zeichen-Smileys mit Icons dargestellt.|FÅr die SmIcons wird NVDI 5 benîtigt! */
#define CGENERAL_SMICONS 31  /* BUTTON in tree CGENERAL */
/* Beim Beenden von Chatter werden die Optionen und die Hotlist gesichert. */
#define CGENERAL_SAVE 33  /* BUTTON in tree CGENERAL */
/* Schlieût den Dialog und Åbernimmt die getÑtigten Einstellungen. */
#define CGENERAL_OK 34  /* BUTTON in tree CGENERAL */
/* Schlieût den Dialog und verwirft die getÑtigten Einstellungen. */
#define CGENERAL_CANCEL 35  /* BUTTON in tree CGENERAL */

#define HELP 35  /* form/dial */
/* Inhaltsverzeichnis */
#define HELP_CONTENT 1  /* STRING in tree HELP */
/* Index */
#define HELP_INDEX 2  /* STRING in tree HELP */

#define ALERT 36  /* form/dial */
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

#define ALERTS 37  /* form/dial */
#define WDLG_MISSING 1  /* STRING in tree ALERTS */
#define SOCKETS_NOT_INST 2  /* STRING in tree ALERTS */
#define SOCKETS_TOO_OLD 3  /* STRING in tree ALERTS */
#define DNS_FAILED 4  /* STRING in tree ALERTS */
#define SOCKET_FAILED 5  /* STRING in tree ALERTS */
#define CONNECT_FAILED 6  /* STRING in tree ALERTS */
#define DD_ONLY_TEXT 7  /* STRING in tree ALERTS */
#define DD_NO 8  /* STRING in tree ALERTS */
#define DD_FAILED 9  /* STRING in tree ALERTS */
#define ERROR_WRITING_CONFIG 10  /* STRING in tree ALERTS */
#define CLOSE_SESSION 11  /* STRING in tree ALERTS */
#define ICONNECT_NO_AV 12  /* STRING in tree ALERTS */
#define ICONNECT_NOT_DESKTOP 13  /* STRING in tree ALERTS */
#define ICONNECT_LOST 14  /* STRING in tree ALERTS */
#define ICONNECT_TOO_OLD 15  /* STRING in tree ALERTS */
#define EDDI_MISSING 16  /* STRING in tree ALERTS */
#define KEYT_MISSING 17  /* STRING in tree ALERTS */
#define CONNECTION_CLOSED 18  /* STRING in tree ALERTS */
#define QUIT_APP 19  /* STRING in tree ALERTS */
#define SL_ERROR 20  /* STRING in tree ALERTS */
#define CLOSE_CHANNEL 21  /* STRING in tree ALERTS */
#define ERROR_WRITING_CHANNEL 22  /* STRING in tree ALERTS */
#define ERROR_WRITING_IRC 23  /* STRING in tree ALERTS */
#define ERROR_WRITING_USER 24  /* STRING in tree ALERTS */
#define TOO_OLD 25  /* STRING in tree ALERTS */
#define CHANNEL_WINDOW_BUSY 26  /* STRING in tree ALERTS */
#define WINDOW_WILL_CLOSED 27  /* STRING in tree ALERTS */
#define MEMORY 28  /* STRING in tree ALERTS */
#define ALERT_BANNEDFROMCHAN 29  /* STRING in tree ALERTS */
#define ALERT_CHANOPRIVSNEEDED 30  /* STRING in tree ALERTS */
#define ALERT_USERONCHANNEL 31  /* STRING in tree ALERTS */
#define ALERT_KICK 32  /* STRING in tree ALERTS */
#define ALERT_NOTONCHANNEL 33  /* STRING in tree ALERTS */
#define ALERT_NOSUCHNICK 34  /* STRING in tree ALERTS */
#define ALERT_NOSUCHCHANNEL 35  /* STRING in tree ALERTS */
#define ALERT_INVITEONLYCHAN 36  /* STRING in tree ALERTS */
#define ALERT_CHANNELISFULL 37  /* STRING in tree ALERTS */
#define ALERT_CANNOTSENDTOCHAN 38  /* STRING in tree ALERTS */
#define ALERT_TOOMANYCHANNELS 39  /* STRING in tree ALERTS */
#define ALERT_USERNOTINCHANNEL 40  /* STRING in tree ALERTS */
#define ICONNECT_CONNECTION 41  /* STRING in tree ALERTS */
#define ALERT_UNKNOWNMODE 42  /* STRING in tree ALERTS */
#define ALERT_UMODEUNKOWNFLAG 43  /* STRING in tree ALERTS */
#define ALERT_CLOSE_USER 44  /* STRING in tree ALERTS */
#define ALERT_ASK_DCCCHAT 45  /* STRING in tree ALERTS */
#define ALERT_SAVE_ERROR 46  /* STRING in tree ALERTS */
#define ALERT_CANCEL_DCCDATA 47  /* STRING in tree ALERTS */
#define ALERT_ERROR_DCCDATA 48  /* STRING in tree ALERTS */
#define ALERT_FILE_EXIST 49  /* STRING in tree ALERTS */
#define ALERT_READ_ERROR 50  /* STRING in tree ALERTS */
#define DEMO_EXPIRED 51  /* STRING in tree ALERTS */
#define UPDATE_NONEWVERSION 52  /* STRING in tree ALERTS */
#define UPDATE_VERSION 53  /* STRING in tree ALERTS */
#define UPDATE_ERRTMPDIR 54  /* STRING in tree ALERTS */
#define UPDATE_ERRDOWNLOAD 55  /* STRING in tree ALERTS */
#define UPDATE_ERRINSTAL 56  /* STRING in tree ALERTS */
#define UPDATE_SUCESS 57  /* STRING in tree ALERTS */
#define CHANNELPARTY 58  /* STRING in tree ALERTS */
#define ALERT_ERROR_LOG 59  /* STRING in tree ALERTS */

#define TITLES 38  /* form/dial */
#define TITLE_WINDOW 1  /* STRING in tree TITLES */
#define TITLE_ABOUT 2  /* STRING in tree TITLES */
#define TITLE_NEW 3  /* STRING in tree TITLES */
#define TITLE_CIC 4  /* STRING in tree TITLES */
#define TITLE_ICON 5  /* STRING in tree TITLES */
#define TITLE_CSESSION 6  /* STRING in tree TITLES */
#define TITLE_GENERAL 7  /* STRING in tree TITLES */
#define TITLE_HOTLIST 8  /* STRING in tree TITLES */
#define FSEL_DOWNLOAD 9  /* STRING in tree TITLES */
#define FSEL_UPLOAD 10  /* STRING in tree TITLES */
#define FSEL_NEWDOWNLOAD 11  /* STRING in tree TITLES */
#define FSEL_PUTADD 12  /* STRING in tree TITLES */
#define FSEL_LOG 13  /* STRING in tree TITLES */

#define INFOS 39  /* form/dial */
#define TCP_GETHOSTBYNAME 1  /* STRING in tree INFOS */
#define TCP_CONNECT 2  /* STRING in tree INFOS */
#define TCP_INTERNET 3  /* STRING in tree INFOS */
#define TCP_DISCONNECT 4  /* STRING in tree INFOS */
#define TCP_ETABLISHED 5  /* STRING in tree INFOS */
#define SORT_CHANNELS 6  /* STRING in tree INFOS */
#define N_CHANNELS 7  /* STRING in tree INFOS */
#define READ_CHANNELS 8  /* STRING in tree INFOS */
#define WRITE_CHANNELS 9  /* STRING in tree INFOS */
#define CLOSE_IRC 10  /* STRING in tree INFOS */
#define GET_CHANNELS 11  /* STRING in tree INFOS */
#define N_USERS 12  /* STRING in tree INFOS */
#define TCP_WAITFORACK 13  /* STRING in tree INFOS */
#define UPDATE_INFO 14  /* STRING in tree INFOS */
#define UPDATE_DOWNLOAD 15  /* STRING in tree INFOS */
#define UPDATE_UPDATE 16  /* STRING in tree INFOS */
#define UPDATE_END 17  /* STRING in tree INFOS */

#define ICONS 40  /* form/dial */
#define ICON_SMALL 1  /* CICON in tree ICONS */
#define SORT_AB 2  /* ICON in tree ICONS */
#define SORT_AUF 3  /* ICON in tree ICONS */
#define SORT_NO 4  /* ICON in tree ICONS */
#define ICON_BIG 5  /* CICON in tree ICONS */

#define SMICONS 41  /* form/dial */
