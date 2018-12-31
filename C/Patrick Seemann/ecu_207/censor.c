/* --------------------------------------------------------------------
   Module:     CENSOR.C
   Subject:    Mail-Filter fÅr Llegada
   Author:     ho
   Started:    03.11.1991  19:41:20
   Modified:   03.05.1992  12:11:15
   --------------------------------------------------------------------
   94-04-03ps  #CONTIUNE
               *-Wildcard am Pattern-Ende wird richtig bearbeitet
               %n in LIST-String fÅgt \n ein
   --------------------------------------------------------------------
   03.05.1992  Flags() jetzt in PARAM.C
   05.03.1992  Fehler bei der Flag-Erkennung (Flags()) beseitigt
   -------------------------------------------------------------------- */



/* --------------------------------------------------------------------
   Includes
   -------------------------------------------------------------------- */
#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(__TOS__)
   #include <ext.h>
#else
   #include <dir.h>
#endif

#include "defines.h"

#include "global.h"
#include "llegadef.h"


/* --------------------------------------------------------------------
   Types
   -------------------------------------------------------------------- */
typedef           
   struct ADDRESS       
   {
      WORD  zone;
      WORD  net;
      WORD  node;
      WORD  point;
   }  ADDRESS;

typedef
   struct RULE
   {
      struct RULE  *pNext;
      unsigned MatchFrom:1;
      unsigned MatchTo:1;
      unsigned Delete:1;
      unsigned Continue:1;
      WORD     NewSetFlags;
      WORD     NewResetFlags;
      WORD     OldSetFlags;
      WORD     OldResetFlags;
      ADDRESS  From;
      ADDRESS  To;
      char *pFrom;
      char *pTo;
      char *pSubject;
      char *pMessage;
      char *pArea;
      char *pNewArea;
      char *pPath;
      char *pNewFrom;
      char *pNewTo;
      char *pReply;
      char *pListName;
      char *pListTemplate;
      int AreaNameLength;
   }  RULE;



/* --------------------------------------------------------------------
   Variables
   -------------------------------------------------------------------- */
static struct
       {
         int   total;
         int   deleted;
         int   copied;
         int   passed;
         int   extracted;
         int   replies;
         int   listed;
       } Censored = { 0 };

static RULE *pReplyRule; 
static char *pFilename;
static char *pCurrentArea;
static char pLimits[] = " \t\n:";
static char szSeparator[] = "----------------------------------------"
                            "----------------------------------------";
RULE  *pFirstRule = NULL;



/* --------------------------------------------------------------------
   FlushRule -- trÑgt die angegebene Regel in die Liste aller Regeln
   ein. Voraussetzung ist, da· `*save' TRUE ist. Nach dem Speichern der
   Regel wird `*save' gelîscht, so da· ein Regel nicht mehrfach gespei-
   chert wird.
   -------------------------------------------------------------------- */
void FlushRule(BOOL *save, RULE *rule)
{
   if (*save)
   {
      RULE *p = malloc(sizeof *p);
      if (p == NULL)
      {
         ShowError("FlushRule", szOutOfMemory);
      }
      else
      {
         *p = *rule;
         p->pNext = pFirstRule;
         pFirstRule = p;
      }
      memset(rule, 0, sizeof(RULE));
   }
   *save = FALSE;
}



/* --------------------------------------------------------------------
   GetAddressPattern -- wandelt einen String, der eine Adresse angibt,
   in vier int's um, und speichert sie in `*adr'. Der String mu· die
   Form

      [zone:][net/][node][.point]

   haben. Nicht angegebene Bestandteile werden durch -1 ersetzt. Bei
   Vergleichen im weiteren Verlauf des Programms wird bei nicht defi-
   nierten Feldern immer Gleichheit angenommen. Wenn also bei Verglei-
   chen nur ein Node, nicht aber seine Points erkannt werden sollen,
   dann mu· bei der Node-Adresse die Pointnummer .0 explizit angegeben
   werden. Eine Ausnahme bildet die Zone. Als Zone wird immer die
   Default-Zone verwendet. Wenn Vergleiche mit allen Zonen Gleichheit
   liefern sollen, mu· 65535: als Zone angegeben werden.
   -------------------------------------------------------------------- */
static BOOL GetAddressPattern(ADDRESS *adr, char *s)
{
   WORD  x;

   x = 0;
   adr->net = adr->node = adr->point = -1;
   while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   if (*s == ':')
   {
      if (x) adr->zone = x;
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   }
   else
      adr->zone = DEFAULT_ZONE;

   if (*s == '/')
   {
      if (x) adr->net = x;
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   }

   if (x) adr->node = x;

   if (*s == '.')
   {
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
      adr->point = x;
   }

   return *s == '\0';
}



/* --------------------------------------------------------------------
   StripQuotes -- entfernt evtl. vorhandene Quotes und liefert die
   Adresse einer Kopie des Arguments. Das schlie·ende Quote des Argu-
   ments wird durch ein 0-Byte ersetzt. FÅhrende Blanks werden nicht
   Åbergangen. Das Quote mu· das erste Zeichen des Strings sein. Wenn
   ein Quote vorhanden ist, wird der String bis zum schlie·enden Quote
   kopiert. Nach dem zweiten Quote stehende Zeichen werden ignoriert.
   Quotes, denen ein Backslash vorangeht, beenden den String nicht.

   Die Kopie wird mit strdup() auf dem Heap erzeugt. Der Speicher
   sollte also mit free() wieder freigegeben werden, bevor die Adresse
   verloren geht.
   -------------------------------------------------------------------- */
char *StripQuotes(char *p)
{
   char *q;
   
   if (*p != '"' && *p != '\'' || *(p + 1) == '\0') return strdup(p);
   for (q = p + 1; *q && *q != *p; ++q)
   {
      if (*q == '\\' && *(q + 1)) ++q;
   }
   *q = 0;
   return strdup(p + 1);
}



/* --------------------------------------------------------------------
   ParsePattern
   -------------------------------------------------------------------- */
static void ParsePattern(char **dst, char *src)
{
   if (*dst != NULL) free(*dst);
   *dst = strdup(src);
   if (*dst == NULL)
   {
      ShowError(pFilename, szOutOfMemory);
      exit(5);
   }
}



/* --------------------------------------------------------------------
   ParseString
   -------------------------------------------------------------------- */
static void ParseString(char **dst, char *src)
{
   if (*dst != NULL) free(*dst);
   *dst = StripQuotes(src);
   if (*dst == NULL)
   {
      ShowError(pFilename, szOutOfMemory);
      exit(5);
   }
}



/* --------------------------------------------------------------------
   ReadRules -- lie·t die angegeben Datei und bildet die Liste aller
   Rules. ReadRules liefert TRUE, wenn eine Liste gebildet wurde,
   und FALSE bei einem fatalen Fehler.
   -------------------------------------------------------------------- */
BOOL ReadRules(char *pName)
{
   FILE     *fp;
   BOOL     LongLine;
   int      LineNo;
   char     line[128];
   char     *p;
   char     *q;
   char     *r;
   RULE     Rule;
   BOOL     SaveRule;

   fp = fopen(pFilename = pName, "r");
   if (fp == NULL)
   {
      ShowError(pName, strerror(errno));
      return FALSE;
   }

   LongLine = FALSE;
   LineNo   = 0;

   SaveRule = FALSE;
   memset(&Rule, 0, sizeof Rule);

   while (fgets(line, (int) sizeof (line), fp) != NULL)
   {
      p = strchr(line, '\n');
      if (LongLine)
      {           /* --------------------------------------------------
                     Die zuletzt gelesene Zeile enthielt kein Zeilen-
                     ende. Der jetzige Inhalt von line gehîrt also noch
                     zu dieser Zeile. Auf keinen Fall darf versucht
                     werden, ihn als neuen Befehl zu interpretieren. Es
                     mu· allerdings damit gerechnet werden, da· das
                     Zeilenende auch jetzt noch nicht erreicht wird.
                     -------------------------------------------------- */
         LongLine = p == NULL;
         continue;
      }

      ++LineNo;
      if (p == NULL)
      {           /* --------------------------------------------------
                     Die Zeile enthÑlt kein Zeilenende. Entweder ist
                     sie zu lang, oder in der letzten Zeile der Datei
                     fehlt das Zeilenende. Alles, was Åber 128 Zeichen
                     hinausgeht, wird ignoriert. Trotzdem sollte der
                     Benutzer wissen, da· etwas nicht stimmt.
                     -------------------------------------------------- */
         char msg[80];
         sprintf(msg, "line %d too long", LineNo);
         ShowError(pName, msg);
         LongLine = TRUE;
      }

      p = line + strspn(line, pLimits);
      if (*p == '\0' || *p == '\n' || *p == ';') continue;

      q  = p + strcspn(p, pLimits);
      if (*q != '\0') *q++ = '\0';
      q += strspn(q, pLimits);
      if (*q == '\n') *q = '\0';
      r = strchr(q, 0);
      while (--r >= q && strchr(pLimits, *r) != NULL) *r = '\0';

                  /* --------------------------------------------------
                     p ist die Adresse des SchlÅsselworts. Das SchlÅs-
                       selwort ist 0-terminiert.
                     q enthÑlt die Adresse des Arguments. FÅhrende
                       Leerzeichen und Tabs wurden Åbersprungen.
                     r enthÑlt die Adresse des letzten signifikanten
                       Zeichens des Arguments. Blanks und Tabs am Ende
                       wurden entfernt.
                     --------------------------------------------------
                     Solange nur Bedingungen gelesen werden, werden sie
                     erst einmal gespeichert. Wenn eine Aktion gelesen
                     wurde, wird ein Flag gesetzt, da· bei der nÑchsten
                     Bedingung eine neue Regel beginnt. SaveRule ent-
                     hÑlt dieses Flag. FlushRule() schreibt die zuletzt
                     beschriebene Regel wenn nîtig, und lîscht dieses
                     Flag.
                     -------------------------------------------------- */
      switch (tolower(*p))
      {
         case 'a':
                  /* --------------------------------------------------
                     AREA areaname
                     -------------------------------------------------- */
            FlushRule(&SaveRule, &Rule);
            ParseString(&Rule.pArea, q);
            Rule.AreaNameLength = (int) strlen (q);
            break;

         case 'b':
            /* --------------------------------------------------------
               BITS bitnames
               -------------------------------------------------------- */
            FlushRule(&SaveRule, &Rule);
            Rule.OldSetFlags = 0;
            Rule.OldResetFlags = 0;
            q = strtok(q, pLimits);
            while (q != NULL)
            {
               if (*q == '!') Rule.OldResetFlags |= Flags(q + 1);
                         else Rule.OldSetFlags   |= Flags(q);
               q = strtok(NULL, pLimits);
            }
            break;

         case 'f':
                  /* --------------------------------------------------
                     FROM pattern
                     FROM #address
                     -------------------------------------------------- */
            FlushRule(&SaveRule, &Rule);
            if (*q == '#')
            {
               ADDRESS x;
               if (GetAddressPattern(&x, q + 1))
               {
                  Rule.MatchFrom = TRUE;
                  Rule.From      = x;
               }
            }
            else
            {
               ParsePattern(&Rule.pFrom, q);
            }
            break;

         case 'm':
                  /* --------------------------------------------------
                     MESSAGE pattern
                     -------------------------------------------------- */
            FlushRule(&SaveRule, &Rule);
            ParsePattern(&Rule.pMessage, q);
            break;

         case 's':
                  /* --------------------------------------------------
                     SUBJECT pattern
                     -------------------------------------------------- */
            FlushRule(&SaveRule, &Rule);
            ParsePattern(&Rule.pSubject, q);
            break;

         case 't':
                  /* --------------------------------------------------
                     TO pattern
                     TO #address
                     -------------------------------------------------- */
            FlushRule(&SaveRule, &Rule);
            if (*q == '#')
            {
               ADDRESS x;
               if (GetAddressPattern(&x, q + 1))
               {
                  Rule.MatchTo = TRUE;
                  Rule.To      = x;
               }
            }
            else
            {
               ParsePattern(&Rule.pTo, q);
            }
            break;

         case '#':
                  /* --------------------------------------------------
                     Aktionen
                     -------------------------------------------------- */
            switch (tolower(*(p + 1)))
            {
               case 'a':
                  /* --------------------------------------------------
                     #AREA areaname
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  ParseString(&Rule.pNewArea, q);
                  break;

               case 'b':
                  /* --------------------------------------------------
                     #BITS bitnames
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  Rule.NewSetFlags = 0;
                  Rule.NewResetFlags = 0;
                  q = strtok(q, pLimits);
                  while (q != NULL)
                  {
                     if (*q == '!') Rule.NewResetFlags |= Flags(q + 1);
                               else Rule.NewSetFlags   |= Flags(q);
                     q = strtok(NULL, pLimits);
                  }
                  break;

               case 'c':
                  /* --------------------------------------------------
                     #CONTINUE
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  Rule.Continue = TRUE;
                  break;

               case 'd':
                  /* --------------------------------------------------
                     #DELETE
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  Rule.Delete = TRUE;
                  break;

               case 'f':
                  /* --------------------------------------------------
                     #FROM newname
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  ParseString(&Rule.pNewFrom, q);
                  break;

               case 'l':
                  /* --------------------------------------------------
                     #LIST name template
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  if (Rule.pListName != NULL) free(Rule.pListName);
                  if (Rule.pListTemplate != NULL)
                  {
                     free(Rule.pListTemplate);
                     Rule.pListTemplate = NULL;
                  }
                  Rule.pListName = StripQuotes(q);
                  if (Rule.pListName == NULL)
                  {
                     ShowError(pName, szOutOfMemory);
                     break;
                  }
                  q = strchr(q, 0) + 1;
                  if (q >= r)
                  {
                     char msg[128];
                     sprintf(msg, "%s %s: no list template", p, Rule.pListName);
                     ShowError(pName, msg);
                     free(Rule.pListName);
                     Rule.pListName = NULL;
                     break;
                  }
                  Rule.pListTemplate = StripQuotes(q + strspn(q, pLimits));
                  if (Rule.pListTemplate == NULL)
                  {
                     free(Rule.pListName);
                     Rule.pListName = NULL;
                     ShowError(pName, szOutOfMemory);
                     break;
                  }
                  break;

               case 'r':
                  /* --------------------------------------------------
                     #REPLY messagename
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  ParseString(&Rule.pReply, q);
                  break;

               case 't':
                  /* --------------------------------------------------
                     #TO newname
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  ParseString(&Rule.pNewTo, q);
                  break;

               case 'w':
                  /* --------------------------------------------------
                     #WRITE path
                     -------------------------------------------------- */
                  SaveRule = TRUE;
                  ParseString(&Rule.pPath, q);
                  break;

               default:
                  {
                     char msg[80];
                     sprintf(msg, "line %d: '%s': unknown command", LineNo, p);
                     ShowError(pName, msg);
                  }
                  break;
            }
            break;

         default:
            {
               char msg[80];
               sprintf(msg, "line %d: '%s': unknown condition", LineNo, p);
               ShowError(pName, msg);
            }
            break;
      }
   }

   FlushRule(&SaveRule, &Rule);

   {              /* --------------------------------------------------
                     Bedingt durch die Art, in der die Liste gebildet
                     wurde, hat zur Folge, da· die letzte Regel am An-
                     fang der Liste steht. Da das fÅr den normalen An-
                     wender vermutlich nur schwer zu durchschauen ist,
                     wird die Liste besser umgedreht.
                     -------------------------------------------------- */
      RULE *p = pFirstRule;

      pFirstRule = NULL;
      while (p != NULL)
      {
         RULE *q = p->pNext;
         p->pNext = pFirstRule;
         pFirstRule = p;
         p = q;
      }
   }

   fclose(fp);
   return TRUE;
}



/* --------------------------------------------------------------------
   MakeTempName -- erzeugt einen noch nicht vorhandenen Dateinamen.

   pName       Puffer, in den der Dateiname geschrieben werden soll
   pTemplate   Muster fÅr den Dateinamen. Der Name kann Laufwerk und
               Pfad enthalten. Das Muster mu· eine Folge von Fragezei-
               chen enthalten. Diese Fragezeichen werden nacheinander
               durch 0..0, 0..1, ... ersetzt, bis ein noch nicht vor-
               handener Name erzeugt ist.
   -------------------------------------------------------------------- */
BOOL MakeTempName(char *pName, char *pTemplate)
{
   struct ffblk ffblk;
   char *p;
   char *q;
   int  n;

   strcpy(pName, pTemplate);
   p = strchr(pName, '?');
   if (p == NULL) return FALSE;
   for (q = p, n = 0; *q == '?'; *q++ = '0', n++);

   while (findfirst(pName, &ffblk, 0) == 0)
   {
      for (q = p + n; q-- > p && *q == 'Z'; *q = '0');
      if (q < p) return FALSE;
      *q = (*q == '9') ? 'A' : *q + 1;
   }

   return TRUE;
}



/* --------------------------------------------------------------------
   matchString -- prÅft, ob `pattern' ein Teilstring von `string' ist.
   `limit' ist ein zusÑtzliches Endzeichen des Patterns. Im Pattern ha-
   ben die folgenden Zeichen eine besondere Bedeutung:

   <  Das Pattern mu· am Anfang des Strings oder unmittelbar nach einem
      Zeilenende (0x0A) stehen.
   >  Das Pattern mu· am Ende des Strings oder unmittelbar vor einem
      Zeilenende (0x0A) stehen.
   ?  An dieser Stelle kann ein beliebiges Zeichen stehen.
   *  An dieser Stelle kann ein beliebiger Teilstring stehen.
   \  Das folgende Zeichen wird nicht als Sonderzeichen oder Endzeichen
      behandelt. Sinnvoll sind die Kombinationen \<, \>, \?, \*, \\,
      \" und \'. Andere Kombinationen sind allerdings nicht verboten.

   Wenn als Endzeichen " verwendet wird, werden Gro·- und Kleinbuchsta-
   ben unterschieden. Bei ' nicht.

   Bei mehrzeiligen Strings kann es evtl. zu Problemen kommen, wenn das
   Pattern am Zeilenanfang stehen mu·, und Wildcards enthÑlt. Es ist
   dann nicht gewÑhrleistet, da· der festen Teile vor und nach den
   Wildcards in der selben Zeile stehen.
   -------------------------------------------------------------------- */
static BOOL matchString(const char *pattern, const char *string, int limit)
{
   BOOL  anchored;
   BOOL  nocase = limit == '\'';

   if (pattern == NULL) return TRUE;
#pragma warn -pia
   if (anchored = (*pattern == '<')) ++pattern;
#pragma warn .pia
   if (*pattern == 0) return TRUE;

   for (;;)
   {
      const char *p = pattern;
      const char *s = string;

      for (;;)
      {
         if (*p == 0 || *p == limit
            || *p == '>' && (*(p + 1) == 0 || *(p + 1) == limit) && *s == 0)
            return TRUE;
         if (*p == '*')
         {
            pattern  = p + 1;
            string   = s;
            anchored = FALSE;
            break;
         }
         if (*s == 0) return FALSE;
         if (*p != '?')
         {
            if (*p == '\\' && *(p + 1)) ++p;
            if (nocase ? tolower(*p) != tolower(*s) : *p != *s)
            {
               if (anchored)
               {
                  string = strchr(string, '\n');
                  if (string == NULL) return FALSE;
               }
               ++string;
               break;
            }
         }
         ++p, ++s;
      }
   }
}



/* --------------------------------------------------------------------
   Pattern-Interpreter -- wie man an der Art, in der das alles hier
   mitten im Code steht, leicht sieht, wurde der Teil erst einige Zeit
   spÑter so implementiert.

   thisChar enthÑlt stets die Adresse des nÑchsten zu bearbeitenden
   Zeichens. Sobald ein Zeichen verarbeitet wurde, mu· der Zeiger mit
   nextChar() auf das nÑchste signifikante Zeichen gesetzt werden.

   Syntax:

   expression::   term;
                  expression, "|", term.

   term::         factor;
                  term, "&", factor.

   factor::       string;
                  "(", expression, ")";
                  "!", factor.

   Alle Interpreter-Routinen haben als Parameter den String, den sie
   mit dem Pattern vergleichen sollen, und ein Flag, das angibt, ob sie
   die Vergleiche tatsÑchlich ausfÅhren sollen, oder ob sie nur einen
   Teil des Patterns Åberspringen sollen. Eine echte 'Short-Circuit-
   Evaluation' ist dadurch zwar auch nicht mîglich, aber man spart we-
   nigstens die Vergleiche von Pattern und String.

   Die Funktionen liefern TRUE, wenn der untersuchte Teilausdruck wahr
   ist, und FALSE sonst. Wenn ein Teilausdruck nur Åbersprungen werden
   soll (skip != 0), wird immer TRUE zurÅckgegeben.
   -------------------------------------------------------------------- */
static BOOL matchOR(const char *, BOOL);
static const char *thisChar = NULL;



/* --------------------------------------------------------------------
   nextChar -- setzt thisChar auf das nÑchste signifikante Zeichen.
   Leerzeichen und TABs werden Åbersprungen. Am Zeilenende bleibt
   thisChar auf dem 0-Byte stehen.
   -------------------------------------------------------------------- */
void nextChar(void)
{
   if (*thisChar)
   {
      do
      {
         ++thisChar;
      }
      while (*thisChar && (*thisChar == ' ' || *thisChar == '\t'));
   }
}


/* --------------------------------------------------------------------
   matchNOT -- Interpreter fÅr "factor"
   -------------------------------------------------------------------- */
static BOOL matchNOT(const char *string, BOOL skip)
{
   BOOL neg = FALSE;
   BOOL res = TRUE;
   
   while (*thisChar == '!')
   {
      nextChar();
      neg = !neg;
   }
   if (*thisChar == '(')
   {
      nextChar();
      res = matchOR(string, skip);
      if (*thisChar == ')') nextChar();
   }
   else if (*thisChar == '"' || *thisChar == '\'')
   {
      char limit = *thisChar;
      if (!skip) res = matchString(thisChar + 1, string, limit);
      do
      {
         if (*thisChar == '\\' && *(thisChar + 1) == limit) ++thisChar;
         ++thisChar;
      }
      while (*thisChar && *thisChar != limit);
      nextChar();
   }
   
   return skip | (neg ? !res : res);
}



/* --------------------------------------------------------------------
   matchAND -- Interpreter fÅr "term"
   -------------------------------------------------------------------- */
static BOOL matchAND(const char *string, BOOL skip)
{
   BOOL res = matchNOT(string, skip);
   while (*thisChar == '&')
   {
      nextChar();
      res &= matchNOT(string, skip | !res);
   }
   return skip | res;
}



/* --------------------------------------------------------------------
   matchOR -- Interpreter fÅr "factor"
   -------------------------------------------------------------------- */
static BOOL matchOR(const char *string, BOOL skip)
{
   BOOL res = matchAND(string, skip);
   while (*thisChar == '|')
   {
      nextChar();
      res |= matchAND(string, skip | res);
   }
   return skip | res;
}



/* --------------------------------------------------------------------
   match -- prÅft, ob ein String einem Pattern genÅgt.
   -------------------------------------------------------------------- */
static BOOL match(const char *pattern, const char *string)
{
   if (pattern == NULL) return TRUE;
   if (string == NULL) return FALSE;
   
   thisChar = pattern + strspn(pattern, " \t");
   return matchOR(string, FALSE);
}



/* --------------------------------------------------------------------
   MatchMessage  -- prÅfen, ob eine Regel auf eine Mail zutrifft.

   pRule       Beschreibung der anzuwendenden Regel
   pHeader     Adresse des Message-Headers
   pMessage    
   pAreaName
   -------------------------------------------------------------------- */
static BOOL MatchMessage(RULE *pRule, MSG_HEADER *pHeader,
                         char *pMessage, char *pAreaName)
{
   if ((pRule->OldSetFlags & pHeader->wFlags) != pRule->OldSetFlags)
      return FALSE;
   if ((pRule->OldResetFlags & pHeader->wFlags) != 0)
      return FALSE;

   if (pRule->MatchFrom)
   {
      if (pRule->From.zone  != (WORD) -1 && pRule->From.zone  != pHeader->wFromZone
      ||  pRule->From.net   != (WORD) -1 && pRule->From.net   != pHeader->wFromNet
      ||  pRule->From.node  != (WORD) -1 && pRule->From.node  != pHeader->wFromNode
      ||  pRule->From.point != (WORD) -1 && pRule->From.point != pHeader->wFromPoint)
      {
         return FALSE;
      }
   }

   if (pRule->MatchTo)
   {
      if (pRule->To.zone  != (WORD) -1 && pRule->To.zone  != pHeader->wToZone
      ||  pRule->To.net   != (WORD) -1 && pRule->To.net   != pHeader->wToNet
      ||  pRule->To.node  != (WORD) -1 && pRule->To.node  != pHeader->wToNode
      ||  pRule->To.point != (WORD) -1 && pRule->To.point != pHeader->wToPoint)
      {
         return FALSE;
      }
   }

   if (!match(pRule->pFrom,    pHeader->szFrom)
   ||  !match(pRule->pTo,      pHeader->szTo)
   ||  !match(pRule->pSubject, pHeader->szSubject)
   ||  !match(pRule->pMessage, pMessage))
   {
      return FALSE;
   }

   if (pRule->pArea != NULL && *pRule->pArea)
   {
      if (!*pAreaName) return stricmp(pRule->pArea, "netmail") == 0;
      if (stricmp(pRule->pArea, pAreaName) != 0) return FALSE;
   }

   return TRUE;
}


/* --------------------------------------------------------------
   Template fÅr ListeneintrÑge:

   %nc fÅgt ein Feld des Headers in den Listeneintrag ein. `n'
   gibt an, wie lang der Eintrag hîchstens sein darf. Wenn er
   kÅrzer als n Zeichen ist, wird das Feld mit Leerzeichen auf-
   gefÅllt. Eine Ausnahme isr n==0. In diesem Fall wird das Feld
   so breit gemacht wie unbedingt notwendig. `c' bezeichnet das
   Feld, das eingetragen werden soll. Folgende Werte sind mîglich

   %A    Areaname
   %D    Datum/Zeit, als die Msg geschrieben wurde
   %F    Name des Absenders
   %I    @INTL
   %M    @MSGID
   %O    Origin-Zeile
   %P    @PID
   %R    @REPLY
   %S    Subject-Line
   %T    Name des EmpfÑngers
   %d    datum/zeit, als die Msg importiert wurde
   %f    Adresse des Absenders
   %l    LÑnge des Msg
   %o    Adresse aus Origin-Zeile
   %s    'Source' -- in Netmails %f, in Echomails %o
   %t    Adresse des EmpfÑngers
   -------------------------------------------------------------- */
static void WriteTemplate(FILE *fp, char *p,
                          MSG_HEADER *pHeader, char *pMessage, char *pAreaName)
{
   char  msgbuf[256];

   while (*p)
   {
      if (*p == '%')
      {
         int n = 0;
         BOOL neg;
         
         ++p;
#pragma warn -pia
         if (neg = (*p == '-')) ++p;
#pragma warn .pia
         while (isdigit(*p)) n = 10 * n + (*p++ - '0');

         switch (*p++)
         {
            case '\0':
               --p;
               break;

            case 'A':   /* Areaname */
               strcpy(msgbuf, pAreaName);
               break;

            case 'D':   /* Datum/Zeit, als die Msg geschrieben wurde */
               strcpy(msgbuf, pHeader->szDate);
               break;

            case 'F':   /* Name des Absenders */
               strcpy(msgbuf, pHeader->szFrom);
               break;

            case 'I':   /* @INTL */
               {
                  char *p;
                  p = strstr(pMessage, "\1INTL");
                  if (p != NULL)
                  {
                     char *q = msgbuf;
                     p += 5;
                     if (*p == ':') ++p;
                     while (*p == ' ') ++p;
                     while (*p && *p != '\n') *q++ = *p++;
                     *q = '\0';
                  }
               }
               break;

            case 'M':   /* @MSGID */
               {
                  char *p;
                  p = strstr(pMessage, "\1MSGID");
                  if (p != NULL)
                  {
                     char *q = msgbuf;
                     p += 6;
                     if (*p == ':') ++p;
                     while (*p == ' ') ++p;
                     while (*p && *p != '\n') *q++ = *p++;
                     *q = '\0';
                  }
               }
               break;

            case 'O':   /* Origin-Zeile */
               {
                  char *p;
                  p = strstr(pMessage, "\n * Origin");
                  if (p != NULL)
                  {
                     char *q = msgbuf;
                     p += 10;
                     if (*p == ':') ++p;
                     while (*p == ' ') ++p;
                     while (*p && *p != '\n') *q++ = *p++;
                     *q = '\0';
                  }
               }
               break;

            case 'P':   /* @PID */
               {
                  char *p;
                  p = strstr(pMessage, "\1PID");
                  if (p != NULL)
                  {
                     char *q = msgbuf;
                     p += 4;
                     if (*p == ':') ++p;
                     while (*p == ' ') ++p;
                     while (*p && *p != '\n') *q++ = *p++;
                     *q = '\0';
                  }
               }
               break;


            case 'R':   /* @REPLY */
               {
                  char *p;
                  p = strstr(pMessage, "\1REPLY");
                  if (p != NULL)
                  {
                     char *q = msgbuf;
                     p += 6;
                     if (*p == ':') ++p;
                     while (*p == ' ') ++p;
                     while (*p && *p != '\n') *q++ = *p++;
                     *q = '\0';
                  }
               }
               break;


            case 'S':   /* Subject-Line */
               strcpy(msgbuf, pHeader->szSubject);
               break;

            case 'T':   /* Name des EmpfÑngers */
               strcpy(msgbuf, pHeader->szTo);
               break;

            case 'd':   /* datum/zeit, als die Msg importiert wurde */
               strcpy(msgbuf, ctime((time_t *) &pHeader->lDate));
               break;

            case 'l':   /* LÑnge des Msg */
               sprintf(msgbuf, "%ld", strlen(pMessage));
               break;

            case 'n':   /* Zeilenumbruch */
               sprintf (msgbuf, "\n");
               break;
               
            case 's':   /* %f in Netmail, %o in Echomail */
               if (pAreaName == NULL || *pAreaName == '\0')
               {
            case 'f':   /* Adresse des Absenders */
               sprintf(msgbuf, "%d:%d/%d.%d",
                  pHeader->wFromZone, pHeader->wFromNet,
                  pHeader->wFromNode, pHeader->wFromPoint);
               break;
               }
               else
               {
            case 'o':   /* Adresse aus Origin-Zeile */
               {
                  char *p = strstr(pMessage, "\n * Origin");
                  if (p != NULL)
                  {
                     do ++p; while (*p && *p != '\n');
                     do --p; while (*p != '\n' && *p != '(');
                     if (*p++ == '(')
                     {
                        char *q = msgbuf;
                        while (*p && *p != '\n' && *p != ')')
                           *q++ = *p++;
                        *q = '\0';
                     }
                     else
                     {
                        msgbuf[0] = '\0';
                     }
                  }
               }
               }
               break;

            case 't':   /* Adresse des EmpfÑngers */
               sprintf(msgbuf, "%d:%d/%d.%d",
                  pHeader->wToZone, pHeader->wToNet,
                  pHeader->wToNode, pHeader->wToPoint);
               break;

            default:
               msgbuf[0] = 0;
               break;
         }
         if (n) fprintf(fp, neg ? "%-*.*s" : "%*.*s", n, n, msgbuf);
            else fprintf(fp, "%s", msgbuf);
      }
      else
      {
         fputc(*p++, fp);
      }
   }
}



static BOOL CreateListEntry(RULE *pRule, MSG_HEADER *pHeader, char *pMessage,
                            char *pAreaName)
{
   FILE *fp = fopen(pRule->pListName, "a");
   if (fp == NULL)
   {
      ShowError(pRule->pListName, strerror(errno));
   }
   else
   {
      WriteTemplate(fp, pRule->pListTemplate, pHeader, pMessage, pAreaName);
      fputc('\n', fp);
      fclose(fp);
      ++Censored.listed;
   }

   return TRUE;
}



static BOOL WriteTemplateText(FILE *fp, MSG_HEADER *hdr, char *msg, char *area)
{
   FILE *fpTemplate;
   char *pTemplate;
   long size;

   fpTemplate = fopen(pReplyRule->pReply, "r");
   if (fpTemplate == NULL)
   {
      ShowError(pReplyRule->pReply, strerror(errno));
      return FALSE;
   }
   fseek(fpTemplate, 0, SEEK_END);
   size = ftell(fpTemplate);

   pTemplate = calloc(size + 1, 1);
   if (pTemplate == NULL)
   {
      fclose(fpTemplate);
      ShowError(pReplyRule->pReply, szOutOfMemory);
      return FALSE;
   }
   fseek(fpTemplate, 0, SEEK_SET);
   size = fread(pTemplate, 1, size, fpTemplate);
   fclose(fpTemplate);
   pTemplate[size] = '\0';

   WriteTemplate(fp, pTemplate, hdr, msg, pCurrentArea);

   fwrite("", 1, 1,  fp);
   ++Censored.replies;

   {
      time_t tm = time(NULL);

      strcpy(hdr->szTo, hdr->szFrom);
      strcpy(hdr->szFrom, szTearline);
      if (strnicmp(hdr->szSubject, "re:", 3) != 0)
      {
         int i = (int) sizeof (hdr->szSubject) - 1;
         
         hdr->szSubject[i] = '\0';
         i -= 4;
         while (--i >= 0) hdr->szSubject[i + 4] = hdr->szSubject[i];
         memcpy(hdr->szSubject, "Re: ", 4);
      }
      strftime(hdr->szDate,
               sizeof hdr->szDate,
               "%d %b %y  %H:%M:%S",
               gmtime(&tm));
      hdr->lDate        = tm;
      hdr->wFlags       = MF_PRIVATE | MF_KILLIFSENT | MF_LOCAL;
      hdr->wMagic       = 0;
      {
         BOOL  badAddress = TRUE;

         if (area == NULL || *area == '\0')
         {
            hdr->wToZone  = hdr->wFromZone;
            hdr->wToNet   = hdr->wFromNet;
            hdr->wToNode  = hdr->wFromNode;
            hdr->wToPoint = hdr->wFromPoint;
            badAddress = FALSE;
         }
         else
         {
            char *p = strstr(msg, "\n * Origin");
            if (p != NULL)
            {
               do ++p; while (*p && *p != '\n');
               do --p; while (*p != '\n' && *p != '(');
               if (*p++ == '(')
               {
                  Get4dAddress(p,
                               &hdr->wToZone,
                               &hdr->wToNet,
                               &hdr->wToNode,
                               &hdr->wToPoint,
                               NULL);
                  badAddress = FALSE;
               }
            }
         }

         hdr->wFromZone  = pNetmailArea->pHost->BossZone;
         hdr->wFromNet   = pNetmailArea->pHost->BossNet;
         hdr->wFromNode  = pNetmailArea->pHost->BossNode;
         hdr->wFromPoint = pNetmailArea->pHost->Point;
         if (badAddress) hdr->wFlags |= MF_HOLD;
      }
   }

   return TRUE;
}



static BOOL CreateTextMessage(RULE *pRule, MSG_HEADER *pHeader, char *pMessage)
{
   char szOutput[FILENAME_MAX];

   if (MakeTempName(szOutput, pRule->pPath))
   {
      FILE *fp = fopen(szOutput, "w");

      if (fp != NULL)
      {
         fprintf(fp, "From:    %s [%d:%d/%d.%d]\n",
                     pHeader->szFrom,
                     pHeader->wFromZone,
                     pHeader->wFromNet,
                     pHeader->wFromNode,
                     pHeader->wFromPoint);
         fprintf(fp, "To:      %s [%d:%d/%d.%d]\n",
                     pHeader->szTo,
                     pHeader->wToZone,
                     pHeader->wToNet,
                     pHeader->wToNode,
                     pHeader->wToPoint);
         fprintf(fp, "Subject: %s\n", pHeader->szSubject);
         fprintf(fp, "Date:    %s\n", pHeader->szDate);
         fprintf(fp, "%s\n", szSeparator);
         fprintf(fp, "%s", pMessage);
         fclose(fp);
         ++Censored.extracted;
      }
      else
      {
         ShowError(szOutput, strerror(errno));
         return FALSE;
      }
   }
   else
   {
      return FALSE;
   }

   return TRUE;
}


/* --------------------------------------------------------------------
   ProcessMessage -- fÅhrt Aktionen auf Msg aus
   
   OUT: delete   TRUE   Msg nicht in Originalarea schreiben
   
   RETURNS:      TRUE   Msg mit weiteren Rules testen/bearbeiten
                 FALSE  weitere Rules nicht beachten
   ------------------------------------------------------------------ */ 
static BOOL ProcessMessage(RULE *pRule, MSG_HEADER *pHeader,
                           char *pMessage, char *pAreaName,
                           BOOL *delete)
{
   *delete = pRule->Delete;

   ++Censored.total;

   if (pRule->pNewTo   != NULL) strcpy(pHeader->szTo,   pRule->pNewTo);
   if (pRule->pNewFrom != NULL) strcpy(pHeader->szFrom, pRule->pNewFrom);

   if (pRule->pNewArea != NULL)
   {
      if (WriteMessage(WritePlainText, pHeader, pMessage, pRule->pNewArea))
         ++Censored.copied;
      else
         *delete = FALSE;
   }

   if (pRule->pListName != NULL)
      *delete &= CreateListEntry(pRule, pHeader, pMessage, pAreaName);

   if (pRule->pPath != NULL)
      *delete &= CreateTextMessage(pRule, pHeader, pMessage);

   pHeader->wFlags = (pHeader->wFlags | pRule->NewSetFlags)
                   & ~pRule->NewResetFlags;

   if (pRule->pReply != NULL)
   {
      MSG_HEADER Header = *pHeader;
      pReplyRule = pRule;
      pCurrentArea = pAreaName;
      WriteMessage(WriteTemplateText, &Header, pMessage, "");
   }

   if (*delete) ++Censored.deleted;
          else ++Censored.passed;

   return pRule->Continue;
}



/* --------------------------------------------------------------------
   CensorMessage -- vergleicht eine Mail mit allen EintrÑgen in der
   Regel-Liste. Wenn eine passende Rule gefunden wird, werden die darin
   angegebenen Operationen ausgefÅhrt. Die folgenden Regeln werden dann
   nicht weiter beachtet.

   CensorMessage liefert TRUE, wenn die Mail in ihre normale Area ge-
   schrieben werden mu·, und FALSE, wenn sie nicht mehr geschrieben
   werden darf.
   -------------------------------------------------------------------- */
BOOL
CensorMessage(MSG_HEADER *pHeader, char *pMessage, char *pAreaName) {

    RULE *p;
    BOOL keep, delete, cont;

    /* Msg normalerweise nicht lîschen */
    keep = TRUE;

    for (p = pFirstRule; p != NULL; p = p->pNext) {
        if (MatchMessage (p, pHeader, pMessage, pAreaName)) {
            cont = ProcessMessage (p, pHeader, pMessage, pAreaName, &delete);
            if (delete) keep = FALSE;
            if (!cont) break;
        }
    }

    return keep;
}


/* ---------------------------------------------------------------------
   CensorStats
   --------------------------------------------------------------------- */
void CensorStats(void)
{
   char  msg[80];
 
   if (Censored.total != 0)
   {  
      sprintf(msg, "processed by Censor: %d", Censored.total);
      WriteLogfile(msg);
      if (Censored.deleted)
      {
         sprintf(msg, "            deleted: %d", Censored.deleted);
         WriteLogfile(msg);
      }
      if (Censored.copied)
      {
         sprintf(msg, "             copied: %d", Censored.copied);
         WriteLogfile(msg);
      }
      if (Censored.passed)
      {
         sprintf(msg, "             passed: %d", Censored.passed);
         WriteLogfile(msg);
      }
      if (Censored.extracted)
      {
         sprintf(msg, "          extracted: %d", Censored.extracted);
         WriteLogfile(msg);
      }
      if (Censored.replies)
      {
         sprintf(msg, "            replies: %d", Censored.replies);
         WriteLogfile(msg);
      }
      if (Censored.listed)
      {
         sprintf(msg, "             listed: %d", Censored.listed);
         WriteLogfile(msg);
      }
   }
}
