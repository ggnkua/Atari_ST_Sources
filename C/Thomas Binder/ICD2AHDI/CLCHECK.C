/*******************************************/
/* Modulname      : CLCHECK.C              */
/* (c)1993 by MAXON-Computer               */
/* Autor          : Thomas Binder          */
/*******************************************/

#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <portab.h>

/* Benîtigte Strukturen */

typedef struct
{
  char  dir_name[11];
  BYTE  dir_attr;
  BYTE  dir_dummy[10];
  UWORD dir_time;
  UWORD dir_date;
  UWORD dir_stcl;
  ULONG dir_flen;
} DIR; /* Format eines Directory-Eintrags */

/* Prototypen */

void err(void);
void correct_dir(DIR *dir, WORD entries);
void work_dir(DIR *dir, WORD entries,
  char *path);
void swap(UWORD *value);
void lswap(ULONG *value);

/* Globale Variablen */

WORD  drive;      /* Momentanes Laufwerk */
UWORD *fat;       /* Die Fat von drive */
BPB   *bpb;       /* Der BPB von drive */
DIR   *rootdir;   /* Rootdirectory von drive */
char  file[129];  /* Pfad der gefundenen Datei */
char  found;      /* Flag, ob Datei gefunden */
char  quit = 0;   /* Abbruchflag */

int main(int argc, char **argv)
{
  WORD  i, j,
        entries;
  char  path[257];
  
  if (argc == 1)
  {
    printf("Aufruf: clcheck <Laufwerk1> "
      "<Laufwerk2> ...\n\n");
    return(0);
  }

  /* Alle Åbergebenen Laufwerke durchgehen */
  for (j = 1; j < argc; j++)
  {
    drive = (int)(*argv[j] & ~32) - 65;
    
    printf("Laufwerk %c... ", drive + 65);

    /* BIOS-Parameterblock ermitteln */
    if ((bpb = Getbpb(drive)) == 0L)
      err();
    
    /* Test auf 16-Bit-Fat */
    if ((bpb->bflags & 1) != 1)
      err();
    
    /* Platz fÅr Wurzelverzeichnis anfordern */
    if ((rootdir = (DIR *)malloc((LONG)
      bpb->rdlen * (LONG)bpb->recsiz)) == 0L)
    {
      err();
    }
    
    /* Platz fÅr FAT anfordern */
    if ((fat = (UWORD *)malloc((LONG)bpb->fsiz *
      (LONG)bpb->recsiz)) == 0L)
    {
      free((void *)rootdir);
      err();
    }

    /* Wurzelverzeichnis einlesen */
    entries = (WORD)((LONG)bpb->rdlen *
      bpb->recsiz / 32);
    Rwabs(0, (void *)rootdir, bpb->rdlen,
      bpb->fatrec + bpb->fsiz, drive);

    /* FAT einlesen und nach Motorola wandeln */
    for (i = 0; i < bpb->numcl; fat[i++] = 0);
    Rwabs(0, (void *)fat, bpb->fsiz, bpb->fatrec,
      drive);
    for (i = 0; i < bpb->numcl; i++)
      swap(&fat[i]);

    /* Ist letzter Datencluster unbenutzt? */
    if (fat[bpb->numcl - 1])
    {
      sprintf(path, "%c:\\", drive + 65);
      /* Nein, Datei suchen */
      found = 0;
      work_dir(rootdir, entries, path);
      
      /* fehlerfrei? */
      if (!quit)
      {
        /* Datei gefunden? */
        if (found)
        {
          printf("der letzte Datencluster gehîrt"
            " zu: %s\n", file);
        }
        else
        {
          printf("der letzte Datencluster ist "
            "belegt/defekt, aber keiner Datei "
            "zugehîrig!\n");
        }
      }
    }
    else
    {
      printf("OK, letzter Datencluster "
        "unbenutzt!\n", drive + 65);
    }
  
    free((void *)rootdir);
    free((void *)fat);
  
    if (quit)
      err();
  }
  return(0);
}

/* Das Verzeichnis dir mit entries EintrÑgen
  absuchen */
void work_dir(DIR *dir, WORD entries, char *path)
{
  WORD  i, j;
  UWORD cl;
  ULONG clusts;
  DIR   *subdir;
  char  my_path[129];
  
  /* Intel-EintrÑge in Motorola-Format wandeln */
  correct_dir(dir, entries);
  
  /* Alle EintrÑge durchgehen */
  for (i = 0; i < entries; i++)
  {
    /* Eintrag nicht gelîscht und nicht
      Laufwerksname? */
    if ((dir[i].dir_name[0] != (char)0xe5) &&
      ((dir[i].dir_attr & 8) == 0))
    {
      cl = dir[i].dir_stcl;
      /* Ist Eintrag ein Ordner? */
      if (dir[i].dir_attr & 16)
      {
        if (dir[i].dir_name[0] != '.')
        {
          strcpy(my_path, path);
          for (j = 0; j < 8; j++)
          {
            if (dir[i].dir_name[j] != 32)
            {
              my_path[strlen(my_path) + 1] = 0;
              my_path[strlen(my_path)] =
                dir[i].dir_name[j];
            }
          }
          if (dir[i].dir_name[8] != 32)
          {
            strcat(my_path, ".");
            for (j = 8; j < 11; j++)
            {
              if (dir[i].dir_name[j] != 32)
              {
                my_path[strlen(my_path) + 1] = 0;
                my_path[strlen(my_path)] =
                  dir[i].dir_name[j];
              }
            }
          }
          strcat(my_path, "\\");
          
          if ((subdir = (DIR *)malloc((LONG)
            bpb->clsizb)) != 0L)
          {
            clusts = 0;
            while (cl < 0x8000U && !quit &&
              !found)
            {
              /* Ist Ordnercluster =
                letzter Cluster? */
              if (cl == bpb->numcl - 1)
              {
                strcpy(file, my_path);
                found = 1;
              }
                
              Rwabs(0, (void *)((LONG)subdir +
                clusts * (LONG)bpb->clsizb),
                bpb->clsiz, bpb->datrec +
                (cl - 2) * bpb->clsiz, drive);
              
              cl = fat[cl];
              clusts++;
              
              if (cl < 0x8000U)
              {
                subdir = (DIR *)realloc((void *)
                  subdir, (clusts + 1L) *
                  (LONG)bpb->clsizb);
                if (subdir == 0L)
                  quit = 1;
              }
            }
            if (!quit && !found)
            {
              work_dir(subdir, (WORD)(clusts *
                  (LONG)bpb->clsizb / 32L),
                  my_path);
              free(subdir);
            }
          }
          else
            quit = 1;
        }
      }
      else /* Eintrag ist also normale Datei */
      {
        if (dir[i].dir_name[0])
        {
          strcpy(my_path, path);
          for (j = 0; j < 8; j++)
          {
            if (dir[i].dir_name[j] != 32)
            {
              my_path[strlen(my_path) + 1] = 0;
              my_path[strlen(my_path)] =
                dir[i].dir_name[j];
            }
          }
          if (dir[i].dir_name[8] != 32)
          {
            strcat(my_path, ".");
            for (j = 8; j < 11; j++)
            {
              if (dir[i].dir_name[j] != 32)
              {
                my_path[strlen(my_path) + 1] = 0;
                my_path[strlen(my_path)] =
                  dir[i].dir_name[j];
              }
            }
          }
          
          while (cl < 0x8000U && !found)
          {
            /* Ist Dateicluster = letzter
              Datencluster? */
            if (cl == bpb->numcl - 1)
            {
              strcpy(file, my_path);
              found = 1;
            }
            
            cl = fat[cl];
            
          }
        }
      }
      if (quit || found)
        return;
    }
  }
}

/* Directory-EintrÑge nach Motorola wandeln */
void correct_dir(DIR *dir, WORD entries)
{
  WORD  i;
  
  for (i = 0; i < entries; i++)
  {
    swap(&dir[i].dir_time);
    swap(&dir[i].dir_date);
    swap(&dir[i].dir_stcl);
    lswap(&dir[i].dir_flen);
  }
}

/* 16-bit-Integer swappen (Intel -> Motorola) */
void swap(UWORD *value)
{
  *value = ((*value & 255) << 8) + (*value >> 8);
}

/* 32-bit-Integer swappen (Intel -> Motorola) */
void lswap(ULONG *value)
{
  UWORD high, low;
  
  low = (UWORD)(*value & 65535L);
  high = (UWORD)(*value >> 16);
  
  swap(&low);
  swap(&high);
  
  *value = ((LONG)low << 16) + (LONG)high;
}

/* Fehlermeldung */
void err(void)
{
  printf("Fehler aufgetreten!\n");
  exit(1);
}

/* Modulende */

