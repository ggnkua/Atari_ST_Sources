/* Mit diesem Programm wird der Linker des LPR-Systems (LINKER.OBM)
 * gepatched. Im einzelnen werden folgende Punkte geaendert:
 *
 * o Die erzeugten Programme enthalten einen Startup-Code, der die
 *   Programmierung von ACCs ermoeglicht (mit dem geaenderten GEMX)
 *
 * o Stack und Heapgroesse der erzeugten Programme lassen sich voreinstellen
 *   (Besonders fuer ACCs wichtig, aber auch sonst)
 *
 * o Das Fastload-Flag und die beiden anderen Flags fuer das Alternate-RAM
 *   lassen sich setzen oder loeschen.
 *
 * Die hier gemachten Einstellungen gelten dann fuer alle vom Linker
 * erzeugten Programme; sollen bestimmte Einstellungen nur fuer ein
 * bestimmtes Programm gelten, ist FIXPRG.TOS zu verwenden.
 *
 * Benutzung: FIXLINK.TOS und (eine Kopie von) LINKER.OBM werden in dasselbe
 *            Verzeichnis kopiert, anschliessend wird FIXLINK.TOS durch
 *            Doppelclick (oder von einer Shell) gestartet, worauf die
 *            angeforderten Werte eingegeben werden muessen.
 *            Bei Fehlern erscheint eine entsprechende Meldung.
 *
 * !!!!! Bei Benutzung des Programms MUSS das neue GEMX benutzt werden!!!!!!
 *
 * (gcc -O2 fixlink.c -o fixlink.tos -liio; strip -k fixlink.tos)
 *
 * 02-Jul-93, Holger Kleinschmidt
 * 27-Nov-93, -"-, ACC-Patch
 * 07-Feb-95, hk
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <st-out.h>

#define OFSPATCHBUF 0x0CCCL

#define OLDSTACK 11
#define OLDHEAP 13

#define NEWSTACK 0
#define NEWHEAP 1
#define NEWFLAGS 2

#define OLDCMP 0x47ee
#define NEWCMP 0x600c

#define MINSTACKSIZE 8L
#define MINHEAPSIZE 8L


/*
; LINKER.OBM original
000CCC 47EEFFE4             LEA     -$1C(A6),A3   ; Programm-Header:
000CD0 36BC601A             MOVE.W  #$601A,(A3)   ;   short ph_branch
000CD4 242CFF96             MOVE.L  -$6A(A4),D2
000CD8 27420002             MOVE.L  D2,$2(A3)     ;   long  ph_tlen
000CDC 242CFF92             MOVE.L  -$6E(A4),D2
000CE0 27420006             MOVE.L  D2,$6(A3)     ;   long  ph_dlen
;
000CE4 42AB000A             CLR.L   $A(A3)        ;   long  ph_blen
000CE8 42AB000E             CLR.L   $E(A3)        ;   long  ph_slen
000CEC 42AB0012             CLR.L   $12(A3)       ;   long  ph_res1
000CF0 42AB0016             CLR.L   $16(A3)       ;   long  ph_prgflags
000CF4 426B001A             CLR.W   $1A(A3)       ;   long  ph_absflag
;
000CF8 47EEFFCC             LEA     -$34(A6),A3   ; ExtInfo:
000CFC 36BC6000             MOVE.W  #$6000,(A3)   ;   <branch>
000D00 377C001A0002         MOVE.W  #$1A,$2(A3)   ;   <offset>
000D06 277C00004E200004     MOVE.L  #$4E20,$4(A3) ;   <stacksize>
000D0E 277C000027100008     MOVE.L  #$2710,$8(A3) ;   <heapsize>
000D16 42AB000C             CLR.L   $C(A3)        ;   reserved1
000D1A 42AB0010             CLR.L   $10(A3)       ;   reserved2
000D1E 42AB0014             CLR.L   $14(A3)       ;   reserved3

Patch:
--------------------------------
  bra.s   init
stacksize:
  DC.L 20000
heapsize:
  DC.L 10000
prgflags:
  DC.L $00000000
init:
  lea     -$001c(A6),A3
  move.w  #$601a,(A3)+
  move.l  -$006a(A4),(A3)+
  move.l  -$006e(A4),(A3)+
  move.l  stacksize(PC),D2
  add.l   heapsize(PC),D2
  move.l  D2,(A3)+
  clr.l   (A3)+
  clr.l   (A3)+
  move.l  prgflags(PC),(A3)+
  clr.w   (A3)+

; Hier wird der ExtInfo-Record belegt:
  lea     -$0034(A6),A3
  move.l  #$600c0000,(A3)+
  move.l  stacksize(PC),(A3)+
  move.l  heapsize(PC),(A3)+
  move.l  #$00002008,(A3)+
  move.l  #$670a4fe8,(A3)+
  move.l  #$00fc6004,(A3)+
*/
/* Neuer Inhalt des ExtInfo-Records:
   bra.s   tstacc
patch1:
   DC.W    0
stackSize:
   DS.L    1
heapSize:
   DS.L    1
patch2:
   DC.W    0
tstacc:
   move.l  a0,d0        ; ACC ?
   beq.s   init         ; B: nein
   lea     256-4(a0),sp ; Stack in Kommandozeile
   bra.s   init
   DS.L 1
 init:
*/

struct buffer {
  short b1;
  long  b2[3];
  short b3;
  long  b4[17];
  short b5;
} buf, newbuf = {0x600c,
                 {0x00000000L,0x00000000L,0x00000000L},
                 0x47ee,
                 {0xffe436fcL,0x601a26ecL,0xff9626ecL,0xff92243aL,
                  0xffe2d4baL,0xffe226c2L,0x429b429bL,0x26faffdcL,
                  0x425b47eeL,0xffcc26fcL,0x600c0000L,0x26faffc4L,
                  0x26faffc4L,0x26fc0000L,0x200826fcL,0x670a4fe8L,
                  0x26fc00fcL},
                  0x6004};

int Linker;

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
  (void)close(Linker);
  fatal1(msg);
};


void
main()
{
  char  z[10];
  short old;
  long  stack, heap, flags = 0L;


  if((Linker = open("LINKER.OBM", O_RDWR)) < 0)
    fatal1("LINKER.OBM nicht im gleichen Verzeichnis oder schreibgeschtzt");
  else if(  (lseek(Linker, OFSPATCHBUF, SEEK_SET) != OFSPATCHBUF)
          ||(read(Linker, &buf, sizeof(buf)) != sizeof(buf)))
    fatal2("Fehler beim Lesen von LINKER.OBM");
  else if ((buf.b1 != OLDCMP) && (buf.b1 != NEWCMP))
    fatal2("LINKER.OBM hat nicht die ben”tigte Version");
  else
  {
    old = buf.b1 == OLDCMP;
    printf("Stackgr”že in kB (Minimum = %ldkB, bisher:%ldkB): ",
            MINSTACKSIZE, (old?buf.b4[OLDSTACK]:buf.b2[NEWSTACK]) >> 10L);
    scanf("%ld", &stack);
    printf("Heapgr”že in kB (Minimum = %ldkB, bisher:%ldkB): ",
            MINHEAPSIZE, (old?buf.b4[OLDHEAP]:buf.b2[NEWHEAP]) >> 10L);
    scanf("%ld", &heap);

    if (stack < MINSTACKSIZE)
      stack = MINSTACKSIZE;
    if (heap < MINHEAPSIZE)
      heap = MINHEAPSIZE;

    printf("Fastload-Flag setzen (n=nein, bisher:%s)? ",
           old ? "nein" : buf.b2[NEWFLAGS]&F_FASTLOAD ? "ja" : "nein");
    scanf("%s", z);
    if (strncmp("n", z, 1)) flags |= F_FASTLOAD;

    printf("Ins Alt-RAM laden (n=nein, bisher:%s)? ",
           old ? "nein" : buf.b2[NEWFLAGS]&F_ALTLOAD ? "ja" : "nein");
    scanf("%s", z);
    if (strncmp("n", z, 1)) flags |= F_ALTLOAD;

    printf("Malloc vom Alt-RAM (n=nein, bisher:%s)? ",
           old ? "nein" : buf.b2[NEWFLAGS]&F_ALTALLOC ? "ja" : "nein");
    scanf("%s", z);
    if (strncmp("n", z, 1)) flags |= F_ALTALLOC;


    newbuf.b2[NEWSTACK] = stack << 10L;
    newbuf.b2[NEWHEAP]  = heap << 10L;
    newbuf.b2[NEWFLAGS] = flags;

    if(  (lseek(Linker, OFSPATCHBUF, SEEK_SET) != OFSPATCHBUF)
       ||(write(Linker, &newbuf, sizeof(newbuf)) != sizeof(newbuf)))
      fatal2("Fehler beim Schreiben von LINKER.OBM");
    else
    {
      printf("\nLINKER.OBM wurde gepatched!\n\n");
      printf("Stack = %ldkB\nHeap = %ldkB\nFastLoad = %s\nAltLoad = %s\n\
FastMalloc = %s\n\nTaste...", stack, heap,
flags & F_FASTLOAD ? "ja" : "nein",
flags & F_ALTLOAD ? "ja" : "nein",
flags & F_ALTALLOC ? "ja" : "nein");

      (void)close(Linker);
      fflush(stdin);
      getchar();
    }
  }
  exit(0);
}

