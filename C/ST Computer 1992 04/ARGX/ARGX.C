/*
 * ARGX.C
 *
 * Modul zur automatischen Expansion von Kommandozeilen-Parametern.
 * Expandiert Wildcards, beruecksichtigt Anfuehrungszeichen, und
 * wertet I/O-Umleitungs-Direktiven aus.
 */

/*
 * Zunaechst der obligatorische Standardkram...
 */
#include "stdstuff.h"

/*
 * Dann das GEMDOS-Binding, dh. die Schnittstelle zu DOS-Funktionen
 * wie Fsfirst(), Fsnext(), usw. Unser Compiler muss ausserdem eine
 * Variable namens `_base' oder dergl. erzeugen, die zur Laufzeit die
 * Adresse der Basepage des Programms enthaelt.
 *
 * Systemabhaengig! Als Beispiel fuer ein Nicht-Sozobon-C-System sind
 * hier die noetigen #ifdef's und #define's fuer Turbo-C zu sehen.
 */
#ifdef __TURBOC__
#include <tos.h>
#define _base _BasPag
#else
#include <osbind.h>
#endif

/*
 * Codes fuer I/O-Umleitungs-Symbole
 */
#define INPUT   1               /* < infile */
#define OUTPUT  2               /* > outfile */
#define APPEND  3               /* >> appendfile */
#define NONE    0               /* nix von alledem */

/*
 * Die 3 Argumente fuer das, was der arme Benutzer fuer die Funktion
 * main() haelt.
 */
static int Argc;                /* Anzahl der Argumente + 1 */
static char **Argv;             /* Array der Argument-Strings */
static char **Env;              /* Array der Environment-Strings */

/*
 * Funktions-Vorwaerts-Deklarationen. ANSI-Compiler werden mit
 * Prototypen, der Rest der Welt mit K&R Funktions-Deklarationen
 * versorgt.
 */
static char *wildmatch FUNC((char *patt));
static void sort FUNC((char **argv));
static void addarg FUNC((char *arg));
static char *savestr FUNC((char *p));
static char *xmalloc FUNC((unsigned n));
static char *xrealloc FUNC((char *p, unsigned n));

/*
 * Unsichtbar fuer den Benutzer: Die "wahre" Funktion main(). Unser
 * Header "argx.h" benennt kurzerhand die vom Benutzer geschriebene
 * Funktion main() in main_() um, so dass sein Programm tatsaechlich
 * immer HIER startet.
 */
void main()
{
    extern struct basepage          /* auch `Process Descriptor' genannt */
    {
        char    *p_lowtpa;
        char    *p_hitpa;
        char    *p_tbase;
        long    p_tlen;
        char    *p_dbase;
        long    p_dlen;
        char    *p_bbase;
        long    p_blen;
        char    *p_dta;
        struct basepage *p_parent;  /* Basepage des Elternprozesses */
        long    p_reserved1;
        char    *p_env;             /* Zeiger auf Environment-Strings */
        char    p_devx[6];
        char    p_reserved2;
        char    p_defdrv;
        long    p_reserved3[18];
        char    p_cmdlin[128];      /* GEMDOS-Kommandozeile */
    } *_base;                       /* zeigt auf unsere eigene Basepage */
    char linebuf[128];              /* Puffer fuer Kommandozeile */
    char wordbuf[128];              /* Puffer fuer 1 extrahiertes Wort */
    int io;                         /* welches I/O-Symbol wars? */
    bool iswild;                    /* wild expandieren oder nicht? */
    register char c, d, *p, *q;     /* fleissige Helferlein */
    register int i, n;              /* Maedchen fuer alles */

    /*
     * Die Adressen der Environment-Strings packen wir in ein
     * NULL-terminiertes Array, wie sich das gehoert, und ignorieren
     * dabei souveraen eventuellen ARGV-Kram.
     */
    n = 0;
    if ((p = _base->p_env) != NULL)
        while (*p != '\0' && strncmp(p, "ARGV=", 5) != 0)
        {
            while (*p++ != '\0')
                ;
            n++;
        }
    Env = (char **)xmalloc(sizeof(char *) * (n + 1));
    p = _base->p_env;
    for (i = 0; i < n; i++)
    {
        Env[i] = p;
        while (*p++ != '\0')
            ;
    }
    Env[n] = NULL;

    /*
     * Nun beginnen wir mit dem Bau unseres Argument-Arrays.
     */
    Argc = 0;
    Argv = NULL;
    addarg("");                         /* provisor. Wert fuer Argv[0] */

    /*
     * GEMDOS-Kommandozeilen-Puffer kopieren
     */
    p = _base->p_cmdlin;                /* GEMDOS-Puffer Adresse */
    n = *p++;                           /* Laengen-Byte auslesen */
    strncpy(linebuf, p, 127);           /* den Rest kopieren */
    linebuf[127] = '\0';                /* und mit NUL abschliessen */
    if (n >= 0 && n < 127)              /* wenn Laengen-Wert sinnvoll */
        linebuf[n] = '\0';              /*   dorthin noch ne NUL */

    /*
     * Zeilenpuffer-Inhalt auswerten
     */
    p = linebuf;                        /* Auf die Plaetze... */
    c = *p++;                           /* fertig... */
    for (;;)                            /* los! */
    {
        /*
         * Leerzeichen ueberspringen
         */
        while (c != '\0' && isspace(c))
            c = *p++;

        /*
         * Gegebenenfalls I/O-Umleitungs-Symbol einlesen
         */
        if (c == '<')
            io = INPUT, c = *p++;
        else if (c != '>')
            io = NONE;
        else if ((c = *p++) == '>')
            io = APPEND, c = *p++;
        else
            io = OUTPUT;
        if (io != NONE)
            /*
             * Leerzeichen hinter I/O-Symbol ueberspringen
             */
            while (c != '\0' && isspace(c))
                c = *p++;

        /*
         * Nicht vergessen: Abbruch bei NUL-Zeichen
         */
        if (c == '\0')
            break;

        /*
         * Nun 1 Wort vom Zeilen- in den Wortpuffer uebertragen.
         * Dabei auf Anfuehrungs- und Wildcard-Zeichen achten.
         */
        iswild = FALSE;                 /* wird TRUE bei Wildcards */
        q = wordbuf;                    /* da soll unser Wort hin */
        while (c != '\0' && !isspace(c))
        {
            if (c == '\'' || c == '"')
            {
                /*
                 * Anfuehrungszeichen gefunden: Alles bis zum
                 * naechsten Anfuehrungszeichen der gleichen Sorte
                 * woertlich uebernehmen.
                 */
                d = c;
                while ((c = *p++) != '\0' && c != d)
                    *q++ = c;
                if (c == '\0')
                    /*
                     * Fehlendes abschliessendes Gaensefuesschen
                     * hoeflich ignorieren.
                     */
                    break;
            }
            else
            {
                /*
                 * Sonst Zeichen direkt uebernehmen.
                 * Ggf. Wildcard-Alarm ausloesen.
                 */
                if (c == '*' || c == '?')
                    iswild = TRUE;
                *q++ = c;
            }
            c = *p++;                   /* naechstes Zeichen holen */
        }
        *q = '\0';                      /* Wort abschliessen */

        /*
         * Wenn des so erhaltene Wort leer ist (zB. bei ""
         * in der Kommandozeile): ignorieren.
         */
        if (*wordbuf == '\0')
            continue;

        /*
         * I/O-Umleitung oder Wildcard-Expansion ausfuehren
         * und ggf. resultierende Argumente in argv[] ablegen.
         */
        if (io == INPUT)
            freopen(wordbuf, "r", stdin);   /* < infile */
        else if (io == OUTPUT)
            freopen(wordbuf, "w", stdout);  /* > outfile */
        else if (io == APPEND)
            freopen(wordbuf, "a", stdout);  /* >> appendfile */
        else if (iswild && (q = wildmatch(wordbuf)) != NULL)
        {
            /*
             * Wildcard-Suche lieferte einen passenden Namen:
             * Hole alle uebrigen passenden Namen und ordne die
             * resultierende Liste alphabetisch.
             */
            n = Argc;                   /* ab hier wird sortiert */
            do
                addarg(q);
            while ((q = wildmatch(NULL)) != NULL);
            sort(&Argv[n]);
        }
        else
            /*
             * Wildcard-Suche war erfolglos, oder mutwillig durch
             * Anfuehrungszeichen verhindert worden: Wort direkt
             * an Argumentliste anhaengen.
             */
            addarg(wordbuf);
    }

    /*
     * Wenn moeglich, setzen wir das nullte Argument auf den Namen,
     * unter dem unser Programm gestartet wurde, den wir uns auf
     * etwas verschlungenen Pfaden besorgen muessen.
     */
    if ((p = (char *)_base->p_parent) != NULL)
    {
        p = *(char **)(p + 0x7C);
        p = *(char **)(p + 0x36);
        *Argv = strlwr(savestr(p));    /* kopiert & kleingeschrieben */
    }

    /*
     * Schliesslich koennen wir nach unserer fleissigen Vorarbeit
     * den User mit einer voll expandierten Argumentliste in seinem
     * main() begluecken.
     */
    main_(Argc, Argv, Env);
    exit(0);
}

/*
 * Routine zur Wildcard-Expansion. Liefert entweder naechsten
 * auf das angegebene Muster `patt' passenden Eintrag, oder NULL
 * wenn nichts mehr gefunden worden konnte. Bei patt != NULL wird
 * eine neue Suche gestartet, ansonsten eine schon begonnene Suche
 * fortgesetzt.
 */
static char *wildmatch(patt)
char *patt;
{
    static struct dta
    {
        char d_reserved[21];
        char d_attr;
        short d_time;
        short d_date;
        long d_size;
        char d_name[14];
    } dta[1];                   /* unsere DTA */
    static char buf[256];       /* Puffer fuer (vollen) Dateinamen */
    static char *name;          /* zeigt auf Namen hinter Pfad-Praefix */
    register char c, *p, *q;    /* dies & das */
    register int err;           /* Fehlercode von Fsfirst()/Fsnext() */

    if (patt != NULL)
    {
        /*
         * Suche mit neuem Muster starten: Muster in unseren privaten
         * Puffer kopieren. Guenstige Gelegenheit, um dabei alle
         * Unix'schen Vorwaertsschraegstriche nach links umzuklappen,
         * so wie es GEMDOS mag.
         */
        p = buf;
        for (q = patt; (c = *q) != '\0'; q++)
        {
            if (p >= buf + sizeof(buf) - 16)
                return NULL;                /* Puffer zu klein */
            *p++ = (c == '/') ? '\\' : c;   /* Schraegstriche umklappen */
        }
        *p = '\0';

        /*
         * Vom String-Ende beginnend, das Ende des Pfad-Praefixes
         * suchen (markiert durch Backslash oder Laufwerk-Doppelpunkt)
         * und merken, damit wir spaeter die gefundenen Dateinamen dort
         * hinschreiben koennen.
         */
        while (p != buf && strchr("\\:", p[-1]) == NULL)
            p--;
        name = p;

        /*
         * Nun gehts wieder nach rechts: Kucken, ob das Muster einen
         * Punkt enthaelt. Wenn ja, so lassen. Wenn nicht, dann * am
         * Ende durch *.* ersetzen (Billig-Emulation von Unix-Wildcards).
         */
        while ((c = *p) != '\0' && c != '.')
            p++;
        if (c == '\0' && p != name && p[-1] == '*')
            strcpy(p, ".*");

        /*
         * Suche mit DOS-Funktionen starten.
         */
        Fsetdta(dta);
        err = Fsfirst(buf, 0);
    }
    else
        /*
         * Schon begonnene Suche fortsetzen.
         */
        err = Fsnext();

    if (err != 0)
        /*
         * Keine weiteren Dateien gefunden, oder Muster war Schrott.
         */
        return NULL;

    /*
     * Gefundenen Namen hinter Pfad-Praefix ablegen und vollen
     * Namen (in Kleinschreibweise) zurueckliefern.
     */
    strcpy(name, dta->d_name);
    return strlwr(buf);
}

/*
 * NULL-terminierten argv[] alphabetisch sortieren.
 * Ginge sicherlich auch mit Quicksort, aber wen kuemmert's.
 */
static void sort(argv)
char **argv;
{
    char *arg, **argp;

    for (; *(argp = argv) != NULL; argv++)
        while (*++argp != NULL)
            if (strcmp(*argp, *argv) < 0)
            {
                arg = *argv;
                *argv = *argp;
                *argp = arg;
            }
}

/*
 * Ge-malloc()te Kopie eines Strings an Argv[] anhaengen.
 * Sorgt automatisch fuer abschliessende NULL.
 */
static void addarg(arg)
char *arg;
{
    Argv = (char **)xrealloc(Argv, sizeof(char *) * (Argc + 2));
    Argv[Argc] = (arg == NULL) ? NULL : savestr(arg);
    Argv[++Argc] = NULL;
}

/*
 * Ge-malloc()te Kopie von einem String machen.
 */
static char *savestr(p)
char *p;
{
    return strcpy(xmalloc(strlen(p) + 1), p);
}

/*
 * Speicher per malloc() reservieren.
 * Bei Fehlschlag Programm mit Meldung abbrechen.
 */
static char *xmalloc(n)
unsigned n;
{
    return xrealloc(NULL, n);
}

/*
 * Speicher per malloc() reservieren oder per realloc() vergroessern.
 * Bei Fehlschlag Programm mit Meldung abbrechen.
 */
static char *xrealloc(p, n)
char *p;
unsigned n;
{
    p = (p == NULL) ? malloc(n) : realloc(p, n);
    if (p == NULL)
    {
        fputs("Memory full\n", stderr);
        exit(1);
    }
    return p;
}

