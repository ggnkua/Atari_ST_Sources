/***********************************************/
/* Modulname      : ICD2AHDI.C                 */
/* (c)1993 by MAXON-Computer                   */
/* Autor          : Thomas Binder              */
/***********************************************/

#include <stdio.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>

/* Benîtigte Strukturen */

typedef struct
{
  UBYTE p_flag;   /* Flag, Bit 0: aktiv ja/nein,
                    Bit 8: bootbar ja/nein */
  char  p_id[3];  /* Kennung, "GEM", "BGM" oder
                    "XGM" */
  LONG  p_st,     /* Start der Partition relativ
                    zum Rootsektor */
        p_siz;    /* Grîûe der Partition in 512-
                    Byte-Sektoren */
} PINFO; /* Partitionseintrag im Rootsektor */

typedef struct
{
  WORD  puns;
  BYTE  pun[16];
  LONG  part_start[16];
  LONG  P_cookie;
  LONG  *P_cookptr;
  UWORD P_version;
  UWORD P_max_sector;
  LONG  reserved[16];
} PUN_INFO; /* AHDI-Informationsstruktur, siehe
              auch Profibuch */

/* Erweitertes Rwabs fÅr 32-bit-Sektornummer */
#define R_wabs(a,b,c,d,e,f) bios(4,a,b,c,d,e,f)

/* Fehlertypen */
#define OK 0
#define RERR 1
#define WERR 2
#define MEMORY 3
#define NOICD 4
#define NOTMTFOUR 5
#define ILLEGAL 6
#define NOBOOT 7
#define NOBSL 8
#define NOAHDI 9

/* Prototypen */

void get_parts(LONG sektor);
void err(WORD error);
void remove_cluster(WORD part);
void create_xgm(WORD part);
void create_new_root(void);
WORD check_ahdi(void);

/* Globale Variablen */

WORD  target;
UBYTE *root;
PINFO *part_table = 0L;
WORD  parts;
LONG  first_xgm = -1L;

void main(void)
{
  WORD  i;
  char  type[3],
        answer[3];
  
  printf("ICD-nach-AHDI-Rootsektor-Wandler\n");
  printf("von Thomas Binder\n\n");
  
  /* Speicher fÅr 512-Byte-Sektor reservieren */
  if ((root = (UBYTE *)malloc(512L)) == 0L)
    err(MEMORY);
  
  /* Speicher fÅr 1 Partionsinfo reservieren */
  if ((part_table = (PINFO *)malloc(
    sizeof(PINFO))) == 0L)
  {
    err(MEMORY);
  }
  
  /* Auf AHDI 3.0-kompatiblen Treiber testen */
  if (check_ahdi())
    err(NOAHDI);

  /* GerÑtenummer erfragen */
  do
  {
    printf("Bitte Festplatte wÑhlen! (0..7: "
      "ACSI-GerÑte 0-7, 8..15: SCSI-GerÑte "
      "0-7,\n");
    printf("  16/17: IDE-GerÑte 0/1)\n");
    printf("GerÑtenummer? ");
    scanf("%d", &target);
    printf("\n");
    
    if ((target < 0) || (target > 17))
      printf("Illegale GerÑtenummer!\n\n");
  } while ((target < 0) || (target > 17));
  
  /* Rootsektor lesen und auf ICD checken */
  if (Rwabs(8, (void *)root, 1, 0, 2 + target))
    err(RERR);

  strncpy(type, ((PINFO *)&root[0x156])->p_id,3);
  if ((strncmp(type, "GEM", 3)) && (strncmp(type,
    "BGM", 3)) && (strncmp(type, "XGM", 3)))
  {
    err(NOICD);
  }
  
  parts = 0;
  get_parts(0);
  
  if (parts < 5)
    err(NOTMTFOUR);
  
  printf("Folgende Partitionen auf GerÑt %d "
    "gefunden:\n\n", target);
  printf(" #   Start   Grîûe  Typ  Aktiv\n");
  printf("------------------------------\n");
  for (i = 0; i < parts; i++)
  {
    printf("%2d%8ld%8ld  %c%c%c  %s\n", i + 1,
      part_table[i].p_st, part_table[i].p_siz,
      part_table[i].p_id[0],
      part_table[i].p_id[1],
      part_table[i].p_id[2],
      (part_table[i].p_flag & 1) ? " Ja" :
      "Nein");
  }
  
  do
  {
    printf("\nWurde fÅr die Partitionen #3 bis "
      "#%d CLCHECK befragt (j/n)? ", parts - 1);

    fgets(answer, 1, stdin);
    answer[0] &= ~32;
    
  } while ((answer[0] != 'J') && (answer[0]
    != 'N'));
  
  if (answer[0] == 'N')
    err(OK);
  
  do
  {
    printf("\nGerÑt %d in AHDI-Format wandeln "
      "(j/n)? ", target);

    fgets(answer, 1, stdin);
    answer[0] &= ~32;
    
  } while ((answer[0] != 'J') && (answer[0]
    != 'N'));
  printf("\n");
  
  if (answer[0] == 'N')
    err(OK);
  
  for (i = 2; i < (parts - 1); i++)
  {
    printf("Entferne letzten Datencluster von "
      "Partition #%d... ", i + 1);
    remove_cluster(i);
    printf("\n");
  }
  printf("\n");
  
  for (i = 2; i < (parts - 1); i++)
  {
    printf("Erzeuge XGM-Sektor am Ende von "
      "Partition #%d... ", i + 1);
    create_xgm(i);
    printf("\n");
  }
  
  printf("\nErzeuge leere Bad-Sector-List... ");
  memset((void *)root, 0, 512L);
  root[3] = 0xa5;
  if (R_wabs(9, (void *)root, 1, -1, 2 + target,
    first_xgm - 1))
  {
    err(WERR);
  }
  
  printf("\n\nErzeuge neuen Rootsektor... ");
  create_new_root();
  err(OK);
}

/* Neuen 1. Rootsektor mit XGM-Eintrag und BSL-
  Zeiger erzeugen */
void create_new_root(void)
{
  WORD  i;
  LONG  size;
  
  /* Alten Rootsektor lesen */
  if (Rwabs(8, (void *)root, 1, 0, 2 + target))
    err(RERR);
  
  /* Grîûe aller mit XGM verketteten Partionen
    zusammenrechnen */
  size = 0;
  for (i = 3; i < parts; i++)
    size += part_table[i].p_siz + 1;
  
  /* XGM-Eintrag im Rootsektor erzeugen */
  ((PINFO *)&root[0x1EA])->p_flag = 1;
  strncpy(((PINFO *)&root[0x1EA])->p_id,
    "XGM", 3);
  ((PINFO *)&root[0x1EA])->p_st = first_xgm;
  ((PINFO *)&root[0x1EA])->p_siz = size;
  
  /* Bad-Sector-List-Zeiger eintragen */
  *(LONG *)&root[0x1F6] = first_xgm - 1;
  *(LONG *)&root[0x1FA] = 1;
  
  /* Alte ICD-Partition #5 im Rootsektor
    lîschen */
  *(LONG *)&root[0x156] = 0L;
  
  /* Neuen Rootsektor schreiben */
  if (Rwabs(9, (void *)root, 1, 0, 2 + target))
    err(WERR);
}

/* Am Ende von Partion Nummer part XGM-Rootsektor
  fÅr part + 1 erzeugen */
void create_xgm(WORD part)
{
  LONG  sektor;
  
  /* Sektor fÅr XGM-Rootsektor errechnen (eins
    vor part + 1) */
  sektor = part_table[part + 1].p_st - 1;
  
  /* Ersten XGM-Rootsektor merken wegen AHDI-
    Patent... */
  if (part == 2)
    first_xgm = sektor;
  
  /* Leeren Sektor erzeugen */
  memset((void *)root, 0, 512L);
  
  /* Zeiger auf part + 1 einrichten */
  ((PINFO *)&root[0x1C6])->p_flag =
    part_table[part + 1].p_flag;
  strncpy(((PINFO *)&root[0x1C6])->p_id, 
    part_table[part + 1].p_id, 3);
  ((PINFO *)&root[0x1C6])->p_st = 1;
  ((PINFO *)&root[0x1C6])->p_siz =
    part_table[part + 1].p_siz;
  
  /* Wenn noch nîtig, nÑchste XGM-Verkettung
    einrichten */
  if (part != parts - 2)
  {
    ((PINFO *)&root[0x1D2])->p_flag = 1;
    strncpy(((PINFO *)&root[0x1D2])->p_id,
      "XGM", 3);
    ((PINFO *)&root[0x1D2])->p_st =
      part_table[part + 2].p_st - 1 - first_xgm;
    ((PINFO *)&root[0x1D2])->p_siz =
      part_table[part + 2].p_siz + 1;
  }
  
  /* XGM-Rootsektor schreiben */
  if (R_wabs(9, (void *)root, 1, -1, 2 + target,
    sektor))
  {
    err(WERR);
  }
}

/* Bei Partition Nummer part letzten Datencluster
  entfernen */
void remove_cluster(WORD part)
{
  UWORD bps,
        spc,
        nsects;
  
  /* Bootsektor von Partition part einlesen */
  if (R_wabs(8, (void *)root, 1, -1, 2 + target,
    part_table[part].p_st))
  {
    err(RERR);
  }
  
  /* bps-, spc- und nsects-EintrÑge des
    Bootsektors ermitteln */
  bps = (*((UBYTE *)&root[0x0c]) << 8) +
    *((UBYTE *)&root[0x0b]);
  spc = (UWORD)*((UBYTE *)&root[0x0d]);
  nsects = (*((UBYTE *)&root[0x14]) << 8) +
    *((UBYTE *)&root[0x13]);
  
  /* Abbruch, wenn unmîgliche Werte */
  if ((bps % 512) || (bps < 512) || (spc == 0))
    err(NOBOOT);
  
  /* Abbruch, wenn kein Platz fÅr Bad-Sector-
    List am Ende von Partition 3 */
  if ((part == 2) && ((bps * spc) < 1024))
    err(NOBSL);
  
  /* Letzten Datencluster "wegzaubern" */
  nsects -= spc;
  *((UBYTE *)&root[0x14]) = nsects >> 8;
  *((UBYTE *)&root[0x13]) = nsects & 255;
  part_table[part].p_siz -= spc * (bps / 512);

  /* Manipulierten Bootsektor zurÅckschreiben */
  if (R_wabs(9, (void *)root, 1, -1, 2 + target,
    part_table[part].p_st))
  {
    err(WERR);
  }
}

/* öbergebenen Sektor lesen und Partitionsinfo
  auswerten */
void get_parts(LONG sektor)
{
  WORD  pos,
        i, j;
  char  type[3];
  
  /* Sektor einlesen */
  if (R_wabs(8, (void *)root, 1, -1, 2 + target,
    sektor))
  {
    err(RERR);
  }
  
  /* Erst EintrÑge 1 - 4 (j = 0), dann 5 - 12
    (j = 1) auswerten (ICD-Rootsektorformat) */
  for (j = 0; j < 2; j++)
  {
    pos = (j == 0) ? 0x1C6 : 0x156;
    
    for (i = 0; i < ((j == 0) ? 4 : 8); i++)
    {
      /* Aufhîren, wenn 1. Langwort des Eintrags
        = 0 */
      if (*(LONG *)&root[pos] == 0L)
        return;

      /* Auf erlaubten Partitionstyp testen */
      strncpy(type, ((PINFO *)&root[pos])->p_id,
        3);
      if ((strncmp(type, "GEM", 3)) &&
        (strncmp(type, "BGM", 3)) &&
        (strncmp(type, "XGM", 3)))
      {
        err(ILLEGAL);
      }
      
      if (strncmp(type, "XGM", 3))
      {
        /* Auswerten, wenn kein XGM-Verweis */
        strncpy(part_table[parts].p_id, type, 3);
        part_table[parts].p_flag =
          ((PINFO *)&root[pos])->p_flag;
        part_table[parts].p_st =
          ((PINFO *)&root[pos])->p_st + sektor;
        part_table[parts].p_siz =
          ((PINFO *)&root[pos])->p_siz;
        
        if ((part_table = realloc((void *)
          part_table, (++parts + 1) *
          sizeof(PINFO))) == 0L)
        {
          err(MEMORY);
        }
      }
      else
      {
        /* XGM-Verkettung folgen */
        if (first_xgm == -1L)
        {
          first_xgm =
            ((PINFO *)&root[pos])->p_st;
          get_parts(((PINFO *)&root[pos])->p_st +
            sektor);
        }
        else
        {
          get_parts(((PINFO *)&root[pos])->p_st +
            first_xgm);
        }
      }
  
      pos += 12;
    }
  }
}

/* Testen, ob AHDI 3.0-kompatibler Treiber aktiv
  ist */
WORD check_ahdi(void)
{
  PUN_INFO  *p;
  LONG      osp;
  
  /* PUN_INFO-Pointer auslesen */
  if ((osp = Super((void *)1L)) == 0L)
    osp = Super(0L);
  p = *((PUN_INFO **)(0x516L));
  if (osp != -1L)
    Super((void *)osp);
  
  /* Checken, ob AHDI-Treiber >= 3.0 aktiv ist */
  if ((p) && (p->P_cookie == 'AHDI') &&
    (p->P_cookptr == &(p->P_cookie)) &&
    (p->P_version >= 0x300))
  {
    return(0);
  }
  return(1);
}

/* Fehlermeldung ausgeben und Speicher
  freigeben */
void err(WORD error)
{
  switch (error)
  {
    case RERR:
      printf("Lesefehler bei GerÑt %d!\n",
        target);
      break;
    case WERR:
      printf("Schreibfehler bei GerÑt %d!\n",
        target);
      break;
    case MEMORY:
      printf("Kein Speicher mehr frei!\n");
      break;
    case NOICD:
      printf("Festplatte nicht mit ICD "
        "formatiert oder hat weniger als 5 "
        "Partitionen!\n");
      break;
    case NOTMTFOUR:
      printf("Festplatte hat weniger als 5 "
        "Partitionen!\n");
      break;
    case ILLEGAL:
      printf("Illegale Partitionskennung!\n");
      break;
    case NOBOOT:
      printf("Bootsektor enthÑlt unsinnige "
        "Werte!\n");
      break;
    case NOBSL:
      printf("Partition #4 muû mindestens 1024 "
        "Bytes pro Cluster haben!\n");
      break;
    case NOAHDI:
      printf("Es muû ein AHDI 3.0-kompatibler "
        "Treiber aktiv sein!\n");
  }
  
  /* Speicher freigeben, falls belegt */
  if (root != 0L)
    free((void *)root);
  if (part_table != 0L)
    free((void *)part_table);
  
  exit(error);
}

/* Modulende */

