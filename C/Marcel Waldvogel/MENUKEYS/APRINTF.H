/*
** Prototypen und Konstantendefinitionen fÅr a[rsc]printf()
**
** V1.1, (c) 1990, 1991 Marcel Waldvogel
*/

#define APRINTF_BUFSIZE 200
/* 5*30 Bytes Text, 3*10 Bytes Buttons plus noch ein bisschen ZugemÅse */

int aprintf(int button, char *format, ...);
/*
** Wie [sf]printf, der Output kommt allerdings in einen Alert mit
** Defaultbutton button. RÅckgabewert: gewÑhlter Button.
*/

int afreeprintf(int button, int freenum, ...);
/*
** Wie aprintf, nimmt aber keinen konstanten Formatstring, sondern den
** Index des zustÑndigen Alertstrings aus der Resourcedatei entgegen.
*/

void aprintf_prepare(char *buf);
/*
** Verdoppelt im String alle '|' und ']'.
** VORSICHT: Dadurch kann der String u.U. bis doppelt so lang werden!
*/
