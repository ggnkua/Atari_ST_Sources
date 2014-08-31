/***********************************************/
/* Modulname      : MINI1.C                    */
/* Autor          : Thomas Binder              */
/* Zweck:         : Miniprogramm, das aus      */
/*                  GAMEFIX heraus gespeichert */
/*                  werden kann und wie "OK/   */
/*                  Booten" wirkt, also einen  */
/*                  "Magic Pack" im Speicher   */
/*                  anlegt und dann einen      */
/*                  Reset auslîst.             */
/* Compiler       : Pure C 1.0                 */
/* Erstellt am    : 28.08.1993                 */
/* Letzte énderung: 03.09.1993                 */
/***********************************************/

#include <tos.h>
#include <portab.h>
#include <falcon.h>
#include "gamefix.h"

/* Prototypen */
LONG reset(void);
LONG get_ram(void);

/* Globale Variablen */
extern WORD mtype;
WORD magic_pack[1280];

void main(void)
{
    WORD    i, j,
            sum,
            first,
            checkpos,
            pos;
    LONG    help;
    ULONG   ram;
    
    /* Ramgrîûe des F030 bestimmen */
    ram = (ULONG)Supexec(get_ram);
    /* Monitortyp auslesen */
    mtype = mon_type();
    /* Startadresse der GEMDOS-Routine fÅr */
    /* die alte Bildschirmadresse und des */
    /* PMMU-Baums bestimmen */
    if (ramsizes[settings[_RAMCONFIG]] == ram)
    {
        gdrout = (WORD *)0x600L;
        rootpointer[1] = 0x700L;
        if (!Super((void *)1L))
            Super(0L);
    }
    else
    {
        gdrout = (WORD *)(ram - 256LU);
        rootpointer[1] = ram - 512LU;
    }
    /* PMMU-Baum kopieren */
    for (i = 0; i < 64; i++)
    {
        if ((new_pmmu_tree[i] / 65536LU) ==
            0xffffLU)
        {
            /* Bei entsprechend gekennzeich- */
            /* netem Eintrag den richtigen */
            /* Offset berechnen */
            new_pmmu_tree[i] =
                rootpointer[1] +
                (new_pmmu_tree[i] & 65535LU);
        }
        else
        {
            /* Sollen Daten- und Befehlscache */
            /* ausgeschaltet werden, im PMMU- */
            /* Baum Cache-Inhibit-Flag setzen */
            if (!settings[_DATACACHE] &&
                !settings[_INSTCACHE])
            {
                new_pmmu_tree[i] |= 64LU;
            }
        }
        ((LONG *)rootpointer[1])[i] =
            new_pmmu_tree[i];
    }
    /* GEMDOS-Routine kopieren (egal, ob sie */
    /* gebraucht wird, oder nicht */
    for (i = 0; _gemdos[i] != (WORD)0xabcd; i++)
        gdrout[i] = _gemdos[i];
    gdrout += 6L;
    help = (LONG)magic_pack;
    /* Beginn des Magic Pack bestimmen (muû */
    /* auf 512-Byte-Grenze fallen). Die Magic */
    /* Packs sind Åbrigens offiziell nicht */
    /* dokumentiert, sie sollten also nur sehr */
    /* selten benutzt werden */
    if (help % 512L)
        help += 512L - (help % 512L);
    first = pos = (WORD)((help -
        (LONG)magic_pack) / 2L);
    /* Erster Long-Wert im Magic Pack muû */
    /* 0x12123456 sein */
    magic_pack[pos++] = 0x1212;
    magic_pack[pos++] = 0x3456;
    /* Im zweiten Long-Wert muû die */
    /* Anfangsadresse des Packs stehen */
    magic_pack[pos++] = (WORD)(help >> 16);
    magic_pack[pos++] = (WORD)(help & 65535L);
    /* Assembler-Routine kopieren */
    for (i = 0; mpack[i] != (WORD)0xabcd; i++)
        magic_pack[pos + i] = mpack[i];
    /* 16-Bit-PrÅfsumme Åber den Magic Pack */
    /* bilden */
    for (j = sum = 0; j < 256; sum +=
        magic_pack[first + j++]);
    /* Checksumme so Ñndern, daû die */
    /* PrÅfsumme 0x5678 ergibt (sonst wird */
    /* der Magic Pack nicht ausgefÅhrt) */
    checkpos = (pos << 1) +
        (WORD)((LONG)&checksum - (LONG)mpack);
    magic_pack[checkpos >> 1] += (0x5678 - sum);
    /* Reset auslîsen */
    Supexec(reset);
}
/* Modulende */
