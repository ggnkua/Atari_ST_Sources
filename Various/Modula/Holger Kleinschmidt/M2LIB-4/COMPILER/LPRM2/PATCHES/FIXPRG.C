/* Mit diesem Programm koennen die Einstellungen, die FIXLINK global fuer
 * alle Programme durch Patchen des Linkers vornimmt, individuell fuer jedes
 * LPR-Programm vorgenommen werden (Einzelheiten in FIXLINK.C).
 *
 * Benutzung: Nach dem Starten von FIXPRG.TOS muss nach der Aufforderung
 *            der vollstaendige Pfadname (falls sich die Datei nicht im
 *            aktuellen Verzeichnis befindet) der zu patchenden LPR-
 *            Programmdatei angegeben werden, alles weitere wie bei FIXLINK.
 *
 * !!!!! Bei Benutzung des Programms MUSS das neue GEMX benutzt werden!!!!!!
 *
 * 03-Jun-95, Holger Kleinschmidt
 */
/* gcc -O2 -mshort fixprg.c -o fixprg.tos -liio; strip -k fixprg.tos */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <macros.h>
#include <st-out.h>

struct {
  /* Standard GEMDOS-Header */
  short ph_branch;
  long  ph_tlen;
  long  ph_dlen;
  long  ph_blen;
  long  ph_slen;
  long  ph_res1;
  long  ph_prgflags;
  short ph_absflag;

  /* LPR-Erweiterungen */

#define BRANCH 0x600C

  short lpr_branch;
  short lpr_patch1;

#define MINSTACKSIZE 8L
#define MINHEAPSIZE 8L

  long  lpr_stacksize;
  long  lpr_heapsize;

  short lpr_patch2;

#define TSTACC1 0x2008
#define TSTACC2 0x670A4FE8L
#define TSTACC3 0x00FC6004L

/* move.l  a0,d0
   beq.s   init
   lea     256-4(a0),sp
   bra.s   init
   DS.L 1
 init:
*/
  short lpr_reserved1;
  long  lpr_reserved2;
  long  lpr_reserved3;

  /* Der Rest ist fuer Ueberpruefung, ob auch wirklich ein LPR-Programm
   * vorliegt.
   */
#define TSTLPR1 0x2F0C287AL
#define TSTLPR2 0xFFF84E56L

  long  lpr_start0;
  long  lpr_start1;
  long  lpr_start2;
} buf;

int fd;


void
fatal1 (char *msg)
{
  printf("\033p*** "); printf(msg); printf("! Taste...\033q\r\n");
  fflush(stdin);
  getchar();
  exit(1);
}

void
fatal2 (char *msg)
{
  (void)close(fd);
  fatal1(msg);
};


void
main()
{
  char  z[10];
  char  file[128];
  long  stack, heap, flags = 0L;


  printf("LPR-Programmdatei: ");
  scanf("%s", file);

  if((fd = open(file, O_RDWR)) < 0)
    fatal1("Fehler beim ™ffnen der Datei");
  else if((read(fd, &buf, sizeof(buf)) != sizeof(buf)))
    fatal2("Fehler beim Lesen der Datei");
  else if((buf.lpr_start1 != TSTLPR1) || (buf.lpr_start2 != TSTLPR2))
    fatal2("Datei ist kein LPR-Programm");
  else
  {
    printf("Stackgr”že in kB (bisher = %ldkB): ", buf.lpr_stacksize / 1024L);
    scanf("%ld", &stack);
    printf("Heapgr”že in kB (bisher = %ldkB): ", buf.lpr_heapsize / 1024L);
    scanf("%ld", &heap);
    if (abs(stack) < MINSTACKSIZE)
      if (stack < 0L)
        stack = -MINSTACKSIZE;
      else
        stack = MINSTACKSIZE;

    if (abs(heap) < MINHEAPSIZE)
      if (heap < 0L)
        heap = -MINHEAPSIZE;
      else
        heap = MINHEAPSIZE;

    printf("Fastload-Flag setzen (n=nein, bisher:%s)? ",
           buf.ph_prgflags & F_FASTLOAD ? "ja" : "nein");
    scanf("%s", z);
    if (strncmp("n", z, 1)) flags |= F_FASTLOAD;

    printf("Ins Alt-RAM laden (n=nein, bisher:%s)? ",
           buf.ph_prgflags & F_ALTLOAD ? "ja" : "nein");
    scanf("%s", z);
    if (strncmp("n", z, 1)) flags |= F_ALTLOAD;

    printf("Malloc vom Alt-RAM (n=nein, bisher:%s)? ",
           buf.ph_prgflags & F_ALTALLOC ? "ja" : "nein");
    scanf("%s", z);
    if (strncmp("n", z, 1)) flags |= F_ALTALLOC;

    buf.ph_prgflags   = flags;
    buf.lpr_heapsize  = heap * 1024L;
    buf.lpr_stacksize = stack * 1024L;
    buf.ph_blen       = abs(buf.lpr_heapsize) + abs(buf.lpr_stacksize);
    buf.lpr_branch    = BRANCH;
    buf.lpr_reserved1 = TSTACC1;
    buf.lpr_reserved2 = TSTACC2;
    buf.lpr_reserved3 = TSTACC3;

    if(   (lseek(fd, 0L, SEEK_SET) != 0L)
       || (write(fd, &buf, sizeof(buf)) != sizeof(buf)))
      fatal2("Fehler beim Schreiben der Datei");
    else {
      printf("\nDatei wurde gepatched!\n\n");
      printf("Stack = %ldkB\nHeap = %ldkB\nFastLoad = %s\nAltLoad = %s\n\
FastMalloc = %s\n\nTaste...", stack, heap,
flags & F_FASTLOAD ? "ja" : "nein",
flags & F_ALTLOAD ? "ja" : "nein",
flags & F_ALTALLOC ? "ja" : "nein");

      (void)close(fd);
      fflush(stdin);
      getchar();
    }
  }
  exit(0);
}
