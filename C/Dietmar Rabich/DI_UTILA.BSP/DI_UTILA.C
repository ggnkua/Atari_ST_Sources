/*
 * Programm : DISKINFO
 * Modul    : DI_UTILA
 * Edit     : 07/01/90
 * Copyright: D. Rabich, DÅlmen
 * Funktion : Beispielprogramm Disk-Info Utility Ausgabe
 *            Dieses Beispielprogramm demonstriert, wie Disk-Info
 *            eigene Ausgaberoutinen hinzugefÅgt werden kînnen.
 *            Es bleibt dem Programmierer Åberlassen, auch noch
 *            spezielle Sortierroutinen vorzuschalten.
 * Entwickelt mit Turbo C 1.1 von Heimsoeth und Borland.
 * Das Beispielprogramm darf nur nach vorheriger Absprache mit
 * dem Autor als Grundlage benutzt werden!
 */

/* Importe */
# include <aes.h>
# include <string.h>
# include <stdio.h>

/* Messagetypen, die von Disk-Info und Disk-Info Utility Ausgabe benutzt */
/* werden                                                                */
# define CALL_FOUTPUT   0x4001  /* Aufruf von DI_UTILA             */
# define F_BEGIN        0x4002  /* DI_UTILA beginnt mit der Arbeit */
# define F_END          0x4003  /* DI_UTILA ist fertig             */

/* verschiedene Definitionen */
# define MAXSTRING          80

# define MAXDATA         10000L
# define MAXSUCHSTR          5

/* Aufbau der Dateibeschreibungen */
typedef union
{
  long size;           /* Dateigrîûe     */
  struct
  {
    int folders : 16,  /* Anzahl Ordner  */
        files   : 16;  /* Anzahl Dateien */
  } ff_spec;
} LENGTH_NUMBER;

typedef struct
{
  char          path[80],  /* Pfad, unter dem die Datei gefunden wurde      */
                name[14];  /* Name der Datei                                */
  LENGTH_NUMBER ln;        /* Datei: Grîûe                                  */
                           /* Ordner: Anzahl der Dateien und Ordner         */
  unsigned int  time,      /* Zeit                                          */
                date;      /* Datum                                         */
  int           is_folder; /* 0 = Datei, 1 = Ordner, 2 = Directoyeintrag    */
  unsigned char attribut;  /* Attribut (speziell: 0xFF kennzeichnet         */
                           /* Ordner oder Disknamen, mit dem gesucht wurde) */
} DATEIBESCHREIBUNG;

typedef DATEIBESCHREIBUNG DATEIDATEN[MAXDATA];

/* Parameter von Disk-Info                             */
/* Die Parameter dienen nur der Information und dÅrfen */
/* folglich nicht verÑndert werden!!!!!!!!!!!!!        */
typedef struct
{
  struct
  {
    unsigned int versch       : 1, /* verschachteln/ nicht verschachteln    */
                 date_format  : 2, /* Datumsformat                          */
                 sort_aufw    : 1, /* aufsteigend/ absteigend sortieren     */
                 sort_fold    : 1, /* Ordner getrennt betrachten            */
                 use_scrap    : 1, /* Scrap-Ablage nutzen                   */
                 dr_einzel    : 1, /* Einzelblatt                           */
                 dr_parallel  : 1, /* parallele Schnittstelle nutzen        */
                 change_eszet : 1, /* Eszet austauschen                     */
                 dat_ausg     : 2, /* Dateien/Ordner/Ordner&Dateien         */
                 out_form     : 2, /* Ausgabeform                           */
                 druck_form   : 3, /* Druckausgabeform                      */
                 dat_form     : 3, /* Dateiausgabeform                      */
                 sort_form    : 3, /* Sortierung                            */
                 auto_sort    : 1, /* automatische Sortierung               */
                 auto_rest    : 1, /* automatische Hintergrundrestaurierung */
                 nach_eing    : 2, /* Dialog nach der Eingabe               */
                 nach_sort    : 2, /* Dialog nach Sortierung                */
                 nach_ausg    : 2, /* Dialog nach Ausgabe                   */
                 dname_vorg   : 1, /* Diskettennamen zwangsweise vorgeben   */
                 datneu       : 1, /* Dateien neu anlegen                   */
                 show_scrap   : 1, /* Accessory-CLIPBRD aufrufen            */
                 rect         : 1, /* Rechtecke ausgeben                    */
                 show_path    : 1, /* Pfad-Spalte wird angezeigt            */
                 show_date    : 1, /* Datums-Spalte wird angezeigt          */
                 show_size    : 1, /* Grîûen-Spalte wird angezeigt          */
                 show_hidden  : 1; /* versteckte Dateien suchen             */
  } bits;
  int  z_label,                 /* Zeilen fÅr Label                         */
       z_tabelle,               /* Zeilen pro Seite fÅr Tabelle             */
       z_d_label,               /* bedruckbare Zeilen des Labels            */
       dr_init[16],             /* Initialisierung der Tabellenausgabe      */
       dr_label[16],            /* Initialisierung der Labelausgabe         */
       dr_reset[16],            /* Druckerreset                             */
       ext;                     /* ausgewÑhlte Vorauswahlmaske              */
  char tab_form[4],             /* Ausgabeform der Tabelle                  */
       suchstr[MAXSUCHSTR][14], /* Suchstring der Eingabe (nur 3 benutzt!)  */
       readpath[MAXSTRING],     /* Pfad zum Einlesen                        */
       laufwerk,                /* gewÑhltes Laufwerk                       */
       extensions[8][4],        /* Wahlextensions zum Einlesen              */
       masken[25][14],          /* EintrÑge in die Masken-Listbox           */
       pfade[16][10][40],       /* EintrÑge in die Pfade-Listbox            */
       folder_char,             /* Zeichen zur Kennzeichnung der Ordner     */
       dir_char;                /* Zeichen zur Kennzeichnung des Directorys */
  struct
  {
    unsigned int t_muster : 4,  /* Farbe der Muster im Dialogtitel          */
                 t_text   : 4,  /* Farbe des Texts im Dialogtitel           */
                 f_dir    : 4,  /* Farbe des Verzeichnis im Fenster         */
                 f_ordner : 4,  /* Farbe der Ordner im Fenster              */
                 f_datei  : 4;  /* Farbe der Dateien im Fenster             */
  } farben;
  struct
  {
    unsigned int titel    : 3;  /* Muster der Dialogtitel                   */
  } muster;
} PARAMETERBLOCK;

/* Informationsblock von Disk-Info */
typedef struct
{
  char           version[4];  /* z. Z. di04                              */
  long           datensaetze; /* Anzahl der DatensÑtze im Speicher       */
  DATEIDATEN     *dsets;      /* Pointer auf DatensÑtze                  */
  PARAMETERBLOCK *parameter;  /* Pointer auf Parameterblock              */
  char           *fsel_path;  /* Pfad fÅr File-Selector (ohne Wildcards) */
                              /* Nur dieser Pfad darf verÑndert werden!! */
} DI_INFOBLOCK;

/* Kommunikations-Nachricht */
typedef struct
{
  unsigned int msg_type,  /* Nachrichtentyp                          */
               msg_id,    /* ID des Versenders                       */
               msg_over;  /* öberlÑnge ( = 0 )                       */
  DI_INFOBLOCK *msg_sadr; /* Pointer auf Disk-Info Informationsblock */
  unsigned int msg_sp_id; /* Kennung ( z. Z. = 5000 )                */
  long     int msg_free;  /* unbenutzt                               */
} DI_UTILA_MSG;

/* globale Zeichenketten */
static char accname[]     = "  DI Utility A...",
            no_call[]     = "[0][Disk-Info Utility Ausgabe|"
                            "-------------------------|"
                            "Aufruf nur Åber Disk-Info|"
                            "Version 3.x!|"
                            "(c) by D. Rabich, DÅlmen][ OK ]",
            bad_version[] = "[0][Es liegt leider keine|"
                            "passende Disk-Info-Version|"
                            "vor.][ OK ]",
            disk_error[]  = "[0][Es ist ein Lese-|"
                            "oder Schreibfehler|"
                            "aufgetreten.][ OK ]";

/* Programm-ID */
static int prg_id;

/* Prototypen */
static void write_to_disk(DI_INFOBLOCK *di_infos);
static void work(int id, DI_INFOBLOCK *di_infos);

/* Beispielroutine, schreibt Dateinamen in eine Datei */
static void write_to_disk(DI_INFOBLOCK *di_infos)
{
  char         l_path[MAXSTRING],
               lokal_name[14];
  FILE         *output;
  long         j;
  int          exbutton, err;
  register int i;

  strcpy(l_path,di_infos->fsel_path);    /* File-Selector-Pfad nutzen */
  strcat(l_path,"*.TXT");

  wind_update(BEG_UPDATE);
  fsel_input(l_path, lokal_name, &exbutton);
  wind_update(END_UPDATE);

  if ((lokal_name[0] != 0) && exbutton ) /* Dateiname gefÅllt, OK? */
  {
    for( i = (int) strlen(l_path);
         (i > 0) && (l_path[i] != '\\');
         i-- );
    l_path[i+1] = 0;
    strcpy(di_infos->fsel_path, l_path);
    strcat(l_path, lokal_name);

    /* Datei îffnen */
    output = fopen (l_path, "w");

    /* Alles OK? Dann Ausgabe... */
    if (output != NULL)
    {
      graf_mouse(HOURGLASS, 0L);

      /* Namen schreiben */
      for(j = 0, err = 0;
          (j < di_infos->datensaetze) && (err!=EOF);
          j++)
        err=fprintf(output, "%s\n", (*(di_infos->dsets))[j].name);

      graf_mouse(ARROW, 0L);

      /* Fehler beim Schreiben? */
      if (err==EOF)
        form_alert(1, disk_error);

      /* Datei schlieûen */
      fclose(output);
    }
    else

     /* pauschal Diskfehler ausgeben */
     form_alert(1, disk_error);
  }
}

/* Arbeitsroutine                               */
/* Funktion: RÅckmeldung an Disk-Info,          */
/*           eigene Routine durchfÅhren,        */
/*           RÅckmeldung, sobald Arbeit beendet */
static void work(int id, DI_INFOBLOCK *di_infos)
{
  int          diskinfo_id;
  DI_UTILA_MSG message;

  if (!memcmp(di_infos->version, "di05", 4))
  {
    wind_update(BEG_UPDATE);               /* damit niemand dazwischenfunkt */
    diskinfo_id       = id;

    /* sofort zurÅckmelden, sonst meldet Disk-Info Timeout!      */
    message.msg_type  = F_BEGIN;           /* Nachricht aufbauen */
    message.msg_id    = prg_id;
    message.msg_sadr  = NULL;
    message.msg_sp_id = 0;
    message.msg_over  = 0;
    appl_write(diskinfo_id, 16, &message); /* senden             */

    /* eigene Routine */
    write_to_disk(di_infos);

    /* Fertigmeldung, sonst arbeitet Disk-Info nicht weiter!     */
    message.msg_type = F_END;              /* Nachricht aufbauen */
    appl_write(diskinfo_id, 16, &message); /* senden             */
    wind_update(END_UPDATE);
  }
  else

    /* Disk-Info-Version falsch, keine Kommunikation mîglich */
    form_alert(1, bad_version);
}

/* Hauptprogramm */
/* Der Accessorybetrieb ist nicht zwingend erforderlich. */
/* Bei Programmbetrieb ist jedoch dafÅr zu sorgen, daû   */
/* eine MenÅleiste erscheint, damit der Zugriff auf      */
/* Disk-Info gewÑhrleistet ist.                          */
void main(void)
{
  DI_UTILA_MSG message;

  if ((prg_id = appl_init()) != -1)
    if (menu_register(prg_id, accname) >= 0)
    {
      for(;;)
      {
        evnt_mesag((int*) &message);
        if (message.msg_type == AC_OPEN)
          form_alert(1, no_call);
        if ((message.msg_type == CALL_FOUTPUT) &&
            (message.msg_sp_id == 5000))
          work(message.msg_id, message.msg_sadr);
      }
    }

  for(;;)             /* Absturz verhindern */
    evnt_timer(0, 1);
}

/* (c) 1989 by D. Rabich */
