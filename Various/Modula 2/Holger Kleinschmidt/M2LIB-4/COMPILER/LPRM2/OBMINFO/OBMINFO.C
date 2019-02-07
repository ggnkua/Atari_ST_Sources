/* 12-Sep-94, Holger Kleinschmidt
 */

#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define HEAD_SEC   1
#define IMPORT_SEC 2
#define CODE_SEC   3
#define DATA_SEC   4

#define HEAD_LEN   0x22

/* Kopf einer globalen Prozedur:
 *
 * modBase: DS.L 1
 * ...
 * PROLOG0:
 *   move.l  a4,-(sp)
 *   movea.l modBase(pc),a4
 *
 * PROLOG1:
 *   link    a6,#<localvar>
 *
 * Ende einer globalen Prozedur. Je nach Groesse der Parameter gibt
 * es drei Varianten:
 *
 * Allen gemeinsam ist:
 *
 * EPILOG0:
 *   unlk    a6
 *   movea.l (sp)+,a4
 *
 * Danach wird nach der Groesse der Parameter unterschieden:
 * Keine Parameter:
 * EPILOG1:
 *   rts
 *
 * Maximal acht Byte Parameter:
 * EPILOG2:
 *   movea.l (sp)+,a0
 *   addq.l  #<params>,sp
 *   jmp     (a0)
 *
 * Mehr als acht Byte Parameter:
 * EPILOG3:
 *   movea.l (sp)+,a0
 *   lea     <params>(sp),sp
 *   jmp     (a0)
 *
 *
 * Bei Modulprioritaet werden Prozeduren und Modulinitialisierungen
 * geklammert (NACH dem Prozedurprolog und VOR dem Epilog):
 *
 * ENTER:
 *   move   sr,d0      privilegiert ab 68010!
 *   move.w d0,-(sp)
 *   andi.w #$f8ff,d0
 *   ori.w  #$0x00,d0  x: Modulprioritaet = Interruptlevel
 *   trap   #11        Supervisor ein
 *   move   d0,sr
 *
 * LEAVE:
 *   move.w (sp),d0
 *   trap   #11
 *   move   d0,sr
 *
 *
 * Eine globale Prozedur hat folgenden Aufbau:
 *
 * PROLOG0
 * PROLOG1
 * [ENTER]
 * ...
 * [LEAVE]
 * EPILOG0
 * EPILOG1 | EPILOG2 | EPILOG3
 */

/* move sr,d0 */
#define PRIVINIT_D1 0x40c0

#define MODULE_PRIO(_pc) \
((codeStart[_pc+5] == PRIVINIT_D1) ? (codeStart[_pc+10] >> 8) : 0)

#define INITTEST_LEN 12
#define INITTEST_LEN_PRIV 23

/* Initialisierung eines importierten Moduls:
 *
 * movea.l <module>(a4),a3
 * movea.l (a3),a3
 * jsr     (a3)
 */
#define INITIMP_LEN 4

/* Vorwaertsdeklaration:
 *
 * bra <forwardproc>
 */
#define FORWARD_D1 0x6000
#define FORWARD_LEN 2

#define IS_FORWARD(_pc) \
  ((codeStart[_pc]   == FORWARD_D1) && \
   (codeStart[_pc+1] >  0))


#define PROLOG_D1 0x2f0c
#define PROLOG_D2 0x287a
#define PROLOG_D3 0x4e56
#define PROLOG_LEN 5

#define IS_PROLOG(_pc) \
  ((codeStart[_pc]   == PROLOG_D1) && \
   (codeStart[_pc+1] == PROLOG_D2) && \
   (codeStart[_pc+2] == -((_pc + 4) << 1)) && \
   (codeStart[_pc+3] == PROLOG_D3) && \
   (codeStart[_pc+4] <= 0))


#define EPILOG_D1 0x4e5e
#define EPILOG_D2 0x285f
#define EPILOG_D3 0x4e75
#define EPILOG_D4 0x205f
#define EPILOG_D5_MASK 0xf0ff
#define EPILOG_D5 0x508F
#define EPILOG_D6 0x4fef
#define EPILOG_D7 0x4ed0

/* Prozedurepilog beginnt immer damit: */
#define IS_EPILOG0(_pc) \
  ((codeStart[_pc]   == EPILOG_D1) && \
   (codeStart[_pc+1] == EPILOG_D2))

/* Epilog einer Prozedur ohne Parameter */
#define IS_EPILOG1(_pc) \
  (codeStart[_pc] == EPILOG_D3)

/* Epilog bei maximal acht Bytes Parameter */
#define IS_EPILOG2(_pc) \
  ((codeStart[_pc] == EPILOG_D4) && \
   ((codeStart[_pc+1] & EPILOG_D5_MASK) == EPILOG_D5) && \
   (codeStart[_pc+2] == EPILOG_D7))

/* Epilog bei mehr als acht Bytes Parameter */
#define IS_EPILOG3(_pc) \
  ((codeStart[_pc]   == EPILOG_D4) && \
   (codeStart[_pc+1] == EPILOG_D6) && \
   (codeStart[_pc+3] == EPILOG_D7))

#define EPILOG0_LEN 2

#define EPILOG1_LEN 1
#define EPILOG2_LEN 3
#define EPILOG3_LEN 4

/* Modulende wie Prozedurende ohne Parameter
 *
 * unlk    a6
 * movea.l (sp)+,a4
 * rts
 */
#define MODULEND_LEN (EPILOG0_LEN + EPILOG1_LEN)


/* Lokaler Prozedurprolog:
 *
 * link a6,#<localvar>
 */
#define LPROLOG_LEN 2

#define IS_LPROLOG(_pc) \
  ((codeStart[_pc]   == PROLOG_D3) && \
   (codeStart[_pc+1] <= 0))


/* Lokaler Prozedurepilog, zwei Arten.
 *
 * unlk    a6
 * movea.l (sp)+,a0
 * 1: addq.l  #<para>,sp
 *    jmp     (a0)
 * 2: lea     <para>(sp),sp
 *    jmp     (a0)
 */
#define IS_LEPILOG0(_pc) \
  ((codeStart[_pc]   == EPILOG_D1) && \
   (codeStart[_pc+1] == EPILOG_D4))

#define IS_LEPILOG1(_pc) \
  ((codeStart[_pc] & EPILOG_D5_MASK) == EPILOG_D5) && \
   (codeStart[_pc+1] == EPILOG_D7))

#define IS_LEPILOG2(_pc) \
  ((codeStart[_pc]   == EPILOG_D6) && \
   (codeStart[_pc+2] == EPILOG_D7))

#define LEPILOG0_LEN 2

#define LEPILOG1_LEN 2
#define LEPILOG2_LEN 3


/* bsr <proc> */
#define CALL 0x6100

#define PCOFS(_pc) ((codeStart[_pc+1] >> 1) + 1)
#define PCADR(_pc) (&codeStart[_pc] + (codeStart[_pc+1] >> 1) + 1)

#define RELADR(_adr) ((long)(_adr) - (long)obm)

typedef struct {
  short id;
  short len;
} Section;

typedef char ModuleName[16];
typedef long ModuleBase;
typedef long Entry;

typedef struct {
  unsigned short day;
  unsigned short minute;
  unsigned short millisecond;
} ModuleVersion;

typedef struct {
  ModuleName    modName;
  ModuleVersion version;
} ModuleId;

typedef struct {
  Section   head;
  short     res;
  ModuleId  id;
  short     codeLen;
  short     varLen;
  short     constLen;
  short     numOfProcs;
  short     numOfMods;
  Section   import;
} ModuleHead;


typedef enum {init, mmodule,
              gproc, gmodule, gforward,
              lproc, lmodule, lforward
             } BlockType;

typedef struct {
  short from;
  short to;
} BlockAdr;

typedef struct {
  BlockType btype;
  short     nr;
  BlockAdr  head;
  BlockAdr  end;
} Block;

#define MAXBLOCK 1023



char  *obm;
FILE  *out = NULL;
Block blocks[MAXBLOCK+1];


void
WriteVersion (const ModuleVersion version)
{
  fprintf(out, "%04x %04x %04x = %02u.%02u.%02u, %02u:%02u:%02u.%03u",
          version.day, version.minute, version.millisecond,
          version.day & 0x1f,
          (version.day >> 5) & 0x0f,
          (version.day >> 9) + 1900,
          version.minute / 60,
          version.minute % 60,
          version.millisecond / 1000,
          version.millisecond % 1000);
}

void
WriteName (const ModuleName name)
{
  char tmp[17] = "";

  fprintf(out, "%s", strncat(tmp, name, 16));
}

inline void
WriteAddress (const void *adr)
{
  fprintf(out, "$%05lx: ", RELADR(adr));
}

void
WriteId (const ModuleId *id)
{
  WriteAddress(&id->modName);
  fprintf(out, "Modulname : ");
  WriteName(id->modName);
  fprintf(out, "\n");
  WriteAddress(&id->version);
  fprintf(out, "  Version : ");
  WriteVersion(id->version);
  fprintf(out, "\n");
}

void
WriteSection (const Section *sec)
{
  fprintf(out, "\n\n");
  WriteAddress(&sec->id);
  fprintf(out, "##  Sektionstyp: %d\n", sec->id);
  WriteAddress(&sec->len);
  fprintf(out, "##SektionslÑnge: %d Bytes\n", sec->len);
}

void
fatal (const char *msg)
{
  fprintf(stderr, "obminfo: %s\n", msg);
  exit(1);
}

void
main (int argc, char *argv[])
{
  ModuleHead   *module;
  ModuleId     *importTab;
  short        *codeStart, *modInit, *modBody, PC, MAXPC, proc=1, pc, forward;
  short        monitor;
  ModuleBase   *modBase;
  Entry        *procTab, *modTab;
  char         *stringTab;
  int          infile, entry, slen, refTabLen, impIdx, blockIdx;
  long         moduleOffset, baseOffset;
  char         tmp[20];
  struct stat  st;


  switch (argc)
  {
    case 3:  if ((out = fopen(argv[2], "w")) == NULL)
               fatal("Fehler beim ôffnen der Ausgabedatei");
             /* kein break */
    case 2:  if ((infile = open(argv[1], O_RDONLY)) < 0)
               fatal("Fehler beim ôffnen der Eingabedatei");
             else if (fstat(infile, &st) < 0) {
               close(infile);
               fatal("Fehler beim ôffnen der Eingabedatei");
             }
             else if ((obm = malloc(st.st_size)) == NULL) {
               close(infile);
               fatal("Nicht genÅgend Speicher");
             }
             else if (read(infile, obm, st.st_size) != st.st_size) {
               close(infile);
               free(obm);
               fatal("Fehler beim Lesen");
             }
             close(infile);
             if (out == NULL) out = stdout;
             break;

    default: fprintf(stderr, "usage: obminfo infile [outfile]\n");
             exit(1);
  }

  module = (ModuleHead *)obm;

  if ((module->head.id   != HEAD_SEC) ||
      (module->head.len  != HEAD_LEN) ||
      (module->import.id != IMPORT_SEC))
  {
    close(infile);
    free(obm);
    fatal("Keine OBM-Datei");
  }

  fprintf(out, "Datei: %s\n", argv[1]);

  moduleOffset = 0;
  while (1)
  {
    blockIdx     = 0;

    importTab  = (ModuleId *)((char *)module + sizeof(ModuleHead));
    modBase    = (ModuleBase *)((char *)importTab + module->import.len + sizeof(Section));
    baseOffset = (char *)modBase - obm;
    codeStart  = (short *)((char *)modBase + sizeof(ModuleBase));
    procTab    = (Entry *)((char *)modBase + module->codeLen + sizeof(Section));
    modTab     = (Entry *)((char *)procTab + module->numOfProcs * sizeof(Entry));
    stringTab  = (char *)modTab + module->numOfMods * sizeof(Entry);

    refTabLen  = (module->numOfProcs + module->numOfMods) * sizeof(Entry);

    monitor    = MODULE_PRIO(0); /* Modulprioritaet angegeben? */
    fprintf(out, "ModulprioritÑt: %d\n", monitor);

    WriteSection(&module->head);
    fprintf(out, "=============\n");
    fprintf(out, "= Modulkopf =\n");
    fprintf(out, "=============\n\n");
    WriteId(&module->id);
    WriteAddress(&module->codeLen);
    fprintf(out, "%5d Bytes Code\n", module->codeLen);
    WriteAddress(&module->varLen);
    fprintf(out, "%5d Bytes Variablen\n", module->varLen);
    WriteAddress(&module->constLen);
    fprintf(out, "%5d Bytes Stringkonstanten\n", module->constLen);
    WriteAddress(&module->numOfProcs);
    fprintf(out, "%2d exportierte Prozeduren (+ Modulinitialisierung)\n",
                 module->numOfProcs - 1);
    WriteAddress(&module->numOfMods);
    fprintf(out, "%2d explizit importierte Module (+ System und selbst)\n",
                 module->numOfMods - 2);

    WriteSection(&module->import);
    fprintf(out, "===========\n");
    fprintf(out, "= Importe =\n");
    fprintf(out, "===========\n\n");
    for (entry = 0; entry < module->numOfMods - 1; entry++)
      WriteId(&importTab[entry]);


    WriteSection((Section *)((char *)modBase - sizeof(Section)));
    fprintf(out, "===============\n");
    fprintf(out, "= Codesegment =\n");
    fprintf(out, "===============\n\n");

    WriteAddress(modBase);
    fprintf(out, "Modulbasis\n\n");

    fprintf(out, "Initialisierung\n");
    fprintf(out, "---------------\n");
    WriteAddress(codeStart);
    fprintf(out, "Initialisierungstest\n\n");

    if (monitor)
      PC = INITTEST_LEN_PRIV;
    else
      PC = INITTEST_LEN;

    MAXPC = ((module->codeLen) >> 1) - 2;

    for (entry = 0; entry < module->numOfMods - 1; entry++)
    {
      WriteAddress(&codeStart[PC]);
      impIdx = codeStart[PC+1] / sizeof(Entry) - module->numOfProcs - 1;
      WriteName(importTab[impIdx].modName);
      fprintf(out, ".INIT ausfÅhren\n");
      PC += INITIMP_LEN;
    }
    fprintf(out, "\n");

    fprintf(out, "Programmcode\n");
    fprintf(out, "------------\n");

    if (!IS_FORWARD(PC))
    {
      /* Keine Prozedurdefinitionen */
      blocks[blockIdx].btype     = mmodule;
      blocks[blockIdx].head.from = PC;
      blocks[blockIdx].end.from  = MAXPC - MODULEND_LEN;
      blockIdx++;

      modBody = &codeStart[PC];
    }
    else
    {
      forward = 1;
      modInit = PCADR(PC); /* naechste Modulinitialisierung */
      modBody = modInit;   /* vorl. Startadr. des Modulrumpfes */

      blocks[blockIdx].btype     = init;
      blocks[blockIdx].head.from = PC;
      blockIdx++;
      PC += FORWARD_LEN;

      while (PC < MAXPC)
      {
        if (&codeStart[PC] == modInit)
        {
          /* Beginn einer Modulinitialisierung */
          blocks[blockIdx].btype     = gmodule;
          blocks[blockIdx].head.from = PC;

          /* Modulinitialisierung endet mit einer Prozedurdefinition
           * oder dem Ende des Modulrumpfes.
           */
          while ((PC < MAXPC) && !IS_PROLOG(PC))
            PC++;

          if (PC < MAXPC)
          {
            /* Ist nicht der Modulrumpf, evtl. FORWARD-Deklarationen
             * vor dem Beginn der Prozedurdeklaration gehoeren nicht mehr
             * zur Modulinitialisierung. Die Modulinitialisierung endet
             * mit dem ersten Sprung zur naechsten Modulinitialisierung.
             */
            do {
              PC -= FORWARD_LEN;
            } while (IS_FORWARD(PC));
            PC += FORWARD_LEN;

            blocks[blockIdx].end.from = PC;
            blockIdx++;

            modInit = PCADR(PC); /* naechste Modulinitialisierung */
            PC += FORWARD_LEN;
          }
          else
          {
            /* Ende des Modulrumpfes erreicht */
            blocks[blockIdx].btype    = mmodule;
            blocks[blockIdx].end.from = PC - MODULEND_LEN;
            blockIdx++;
            break; /* Schluss */
          }
        }

        if (forward)
        {
          /* FORWARD-Deklarationen vor der naechsten Prozedurdefinition */
          while (PC < MAXPC && IS_FORWARD(PC))
          {
            blocks[blockIdx].btype     = gforward;
            blocks[blockIdx].head.from = PC;
            blockIdx++;
            PC += FORWARD_LEN;
          }
          forward = 0;
        }

        if (PC < MAXPC && IS_PROLOG(PC))
        {
          /* Start einer Prozedurdefinition */
          blocks[blockIdx].btype     = gproc;
          blocks[blockIdx].nr        = proc++;
          blocks[blockIdx].head.from = PC;
          PC += PROLOG_LEN;

          /* Das Ende der Prozedurdefinition suchen */
          while (PC < MAXPC)
          {
            if (IS_EPILOG0(PC))
            {
              /* Das Ende einer Prozedur kann unterschiedliche Laengen
               * besitzen, je nach Anzahl der Parameter.
               */
              pc = PC;
              PC += EPILOG0_LEN;
              if (IS_EPILOG1(PC))
                PC += EPILOG1_LEN;
              else if (IS_EPILOG2(PC))
                PC += EPILOG2_LEN;
              else if (IS_EPILOG3(PC))
                PC += EPILOG3_LEN;
              else {
                /* War kein Prozedurende, weitersuchen */
                PC--;
                continue;
              }

              blocks[blockIdx].end.from = pc;
              blocks[blockIdx].end.to   = PC;
              blockIdx++;
              modBody = &codeStart[PC];
              forward = 1;
              break;
            }
            else
              PC++;
          }
        }
        else
          PC++;
      }
    }

    for (entry = 0; entry < blockIdx; entry++)
    {
/*      fprintf(out, "$%x\n", blocks[entry].head.from * 2 + 4);*/
      WriteAddress(&codeStart[blocks[entry].head.from]);
      if (blocks[entry].btype == gproc)
      {
        fprintf(out, "PROCEDURE proc%d\n", blocks[entry].nr);
        WriteAddress(&codeStart[blocks[entry].head.from+PROLOG_LEN]);
        fprintf(out, "\n");
        WriteAddress(&codeStart[blocks[entry].end.from]);
        fprintf(out, "END proc%d\n", blocks[entry].nr);
        WriteAddress(&codeStart[blocks[entry].end.to]);
        proc++;
      }
      else if (blocks[entry].btype == init)
      {
        fprintf(out, "nÑchster Modulrumpf: $%05lx",
                     RELADR(PCADR(blocks[entry].head.from)));
      }
      else if (blocks[entry].btype == gforward)
      {
        fprintf(out, "FORWARD PROCEDURE an Adresse: $%05lx",
                     RELADR(PCADR(blocks[entry].head.from)));
      }
      else if (blocks[entry].btype == mmodule)
      {
        fprintf(out, "MAIN MODULE BEGIN\n");
        if (blocks[entry].head.from == blocks[entry].end.from)
          fprintf(out, "        (* empty *)\n");
        else
          fprintf(out, "\n");
        WriteAddress(&codeStart[blocks[entry].end.from]);
        fprintf(out, "MODULE END\n");
        WriteAddress(&codeStart[blocks[entry].end.from+MODULEND_LEN]);
      }
      else if (blocks[entry].btype == gmodule)
      {
        fprintf(out, "MODULE BEGIN\n");
        if (blocks[entry].head.from == blocks[entry].end.from)
          fprintf(out, "        (* empty *)\n");
        else
          fprintf(out, "\n");
        WriteAddress(&codeStart[blocks[entry].end.from]);
        fprintf(out, "MODULE END\n");
        WriteAddress(&codeStart[blocks[entry].end.from]);
        fprintf(out, "nÑchster Modulrumpf: $%05lx\n",
                     RELADR(PCADR(blocks[entry].end.from)));
      }
      else
        fprintf(out, "????\n");

      fprintf(out, "\n");
    }

    WriteSection((Section *)((char *)procTab - sizeof(Section)));
    fprintf(out, "================\n");
    fprintf(out, "= Datensegment =\n");
    fprintf(out, "================\n\n");

    fprintf(out, "Sprungtabellen:\n");
    fprintf(out, "---------------\n");

    fprintf(out, "Exportierte Codesequenzen:\n");
    fprintf(out, "..........................\n");
    for (entry = 0; entry < module->numOfProcs; entry++)
    {
      WriteAddress(&procTab[entry]);
      sprintf(tmp, "$%x(a3) -->", entry * sizeof(Entry));
      fprintf(out, "%13s $%05lx # $%05lx, ", tmp, procTab[entry],procTab[entry] + baseOffset);
      if (entry)
        fprintf(out, "%3d. exportierte Prozedur\n", entry);
      else
        fprintf(out, "Modulinitialisierung\n");
    }

    fprintf(out, "\n");
    fprintf(out, "Module:\n");
    fprintf(out, ".......\n");

    for (entry = 0; entry < module->numOfMods; entry++)
    {
      WriteAddress(&modTab[entry]);
      sprintf(tmp, "$%x(a4)", (entry + module->numOfProcs) * sizeof(Entry));
      fprintf(out, "%9s, ", tmp);
      if (entry == 0)
        fprintf(out, "eigene Referenztabelle\n");
      else if (entry == module->numOfMods - 1)
        fprintf(out, "Laufzeitsystem (\"System\")\n");
      else
      {
        fprintf(out, "%3d. importiertes Modul (\"", entry);
        WriteName(importTab[entry-1].modName);
        fprintf(out, "\")\n");
      }
    }

    fprintf(out, "\n\n");
    fprintf(out, "Stringkonstanten\n");
    fprintf(out, "----------------\n");
    slen = 0;
    while (slen < module->constLen)
    {
      WriteAddress(&stringTab[slen]);
      sprintf(tmp, "$%x(a4) -->", refTabLen + slen);
      fprintf(out, "%13s \"%s\"\n", tmp, &stringTab[slen]);
      slen += strlen(&stringTab[slen]);
      if (slen & 1)
        slen++;
      else
        slen += 2;
    }

    moduleOffset = stringTab + module->constLen - obm;
    module       = (ModuleHead *)(stringTab + module->constLen);

    if (st.st_size - moduleOffset < 10L)
      break;

    fprintf(out, "\n\n");
    fprintf(out, "***********************************\n");
    fprintf(out, "* Es folgen noch weitere Module ! *\n");
    fprintf(out, "***********************************\n\n");
  }
  free(obm);
  if (out != stdout) fclose(out);
  exit(0);
}
