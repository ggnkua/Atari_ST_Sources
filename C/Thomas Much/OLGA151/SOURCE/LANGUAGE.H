/***************************
 * language.h              *
 ***************************
 ***************************
 * [1998-06-16, tm]        *
 * - first C version       *
 ***************************/

#ifndef LANGUAGE_H
#define LANGUAGE_H


#define OLGAVERSIONSTR "1.51"
#define OLGAREVISION   "1.5"
#define OLGADATE       "1998-06-16"


#ifdef ENGLISH

#define MESSAGE_INFNOTFOUND  "[3][OLGA-Manager:| |File \"olga.inf\" not found.  ][  OK  ]"
#define MESSAGE_MULTITASKING "Bitte unter einem|Multitasking-Betriebssystem|verwenden.][  OK  ]"
#define MESSAGE_COPYRIGHT    "    by Thomas_Much@ka2.maus.de|"
#define MESSAGE_APPS         " OLGA-Application(s)|"
#define MESSAGE_DOCS         " Document(s)|"
#define MESSAGE_LINKS        " Link(s)][  OK  ]"

#define STRING_MENUENTRY     "  OLGA manager "
#define STRING_LEVEL         "Level %i  OEP %i %i  "

#define DEBUG_ACTIVATED      "OLGA activated...\n"
#define DEBUG_DEACTIVATED    "... OLGA deactivated.\n"


#else


#define MESSAGE_INFNOTFOUND  "[3][OLGA-Manager:| |Datei \"olga.inf\" nicht gefunden. ][  OK  ]"
#define MESSAGE_MULTITASKING "Bitte unter einem|Multitasking-Betriebssystem|verwenden.][  OK  ]"
#define MESSAGE_COPYRIGHT    "   von Thomas_Much@ka2.maus.de|"
#define MESSAGE_APPS         " OLGA-Applikation(en)|"
#define MESSAGE_DOCS         " Dokument(e)|"
#define MESSAGE_LINKS        " VerknÅpfung(en)][  OK  ]"

#define STRING_MENUENTRY     "  OLGA-Manager "
#define STRING_LEVEL         "Stufe %i  OEP %i %i  "

#define DEBUG_ACTIVATED      "OLGA aktiviert...\n"
#define DEBUG_DEACTIVATED    "... OLGA deaktiviert.\n"

#endif
#endif
