/********************************************************************/
/* Modulname      : GAMEFIX.C                                       */
/* Autor          : Thomas Binder                                   */
/* Zweck          : Verbesserung der AbwÑrtskompatibilitÑt des      */
/*                  Falcon030. Einstellprogramm mit GEM-Bedienung,  */
/*                  das auch das Abspeichern kleiner Startpro-      */
/*                  gramme ermîglicht.                              */
/* Compiler       : Pure C 1.0                                      */
/* Erstellt am    : 10.08.1993                                      */
/* Letzte énderung: 03.09.1993                                      */
/********************************************************************/

#include <aes.h>
#include <tos.h>
#include <falcon.h>
#include <portab.h>
#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include "gamefix.rsh"
#include "gamefix.h"
#include "mini1.hex"
#include "mini2.hex"

/* Prototypen */
LONG reset(void);
LONG get_settings(void);
LONG set(void);
WORD do_dialog(OBJECT *tree, WORD sobj,
    WORD (*action)(OBJECT *tree, WORD obj));
WORD handle_savedial(OBJECT *tree, WORD obj);
WORD handle_maindial(OBJECT *tree, WORD obj);
void cross(OBJECT *tree, WORD obj);
void set_atten(WORD redraw);
void boot(void);
void save(void);
WORD do_save(char *rout, LONG size);
WORD take_settings(void);
void put_settings(void);
WORD tree_walk(OBJECT *tree, WORD start,
WORD (*action)(OBJECT *tree, WORD obj));
WORD adapt_size(OBJECT *tree, WORD obj);
WORD fileselect(char *path, char *name,
    WORD *button, char *title);
WORD exist(char *file);
WORD get_cookie(ULONG cookie, ULONG *value);
#define MIN(a, b) ((a) < (b) ? (a) : (b))

/* Globale Variablen */
ULONG   ram;
WORD    magic_pack[1280],
        rbuts[] = {RAM512K, RAM1MB,
            RAM2MB, RAM4MB},
        volume,
        char_w, char_h;
char    path[129];

WORD main(void)
{
    WORD    old_ltatten,
            old_rtatten,
            button,
            end = 0,
            i, j,
            dummy;
    ULONG   _mch = 0;
    
    if (appl_init() < 0)
        return(0);
    /* Resourcen skalieren */
    rsrc_init();
    /* Testen, ob Rechner ein F030 ist */
    if ((!get_cookie('_MCH', &_mch)) || (_mch < 0x30000L))
    {
        form_alert(1, NOFALCON);
        appl_exit();
        return(0);
    }
    /* Testen, ob Multitasking-AES laufen */
    if (_GemParBlk.global[1] != 1)
    {
        form_alert(1, STOSONLY);
        appl_exit();
        return(0);
    }
    graf_mouse(ARROW, NULL);
    graf_handle(&char_w, &char_h, &dummy, &dummy);
    /* Aktuellen Pfad holen */
    sprintf(path, "%c:", (char)(Dgetdrv() + 65));
    Dgetpath(&path[2], 0);
    strcat(path, "\\*.PRG");
    /* Ramgrîûe des F030 und aktuelle Einstellungen holen */
    ram = (ULONG)Supexec(get_settings);
    /* Feststellen, welche Ramgrîûe maximal genommen werden darf */
    for (i = 3; (ram <= ramsizes[i]) && (i > 1); i--)
    {
        MAINDIAL[rbuts[i]].ob_state |= DISABLED;
        MAINDIAL[rbuts[i] + 1].ob_state |= DISABLED;
    }
    /* Feststellen, welche Ramgrîûe mindestens genommen werden muû */
    /* (wegen Magic Pack) */
    for (j = 0; (ULONG)magic_pack >=
        ramsizes[j]; j++)
    {
        MAINDIAL[rbuts[j]].ob_state |= DISABLED;
        MAINDIAL[rbuts[j] + 1].ob_state |= DISABLED;
    }
    /* Abbruch, wenn Mindeswert > Maximalwert */
    if (j > i)
    {
        form_alert(1, NORAM);
        appl_exit();
        return(0);
    }
    /* Aktuelle Einstellungen in Dialog eintragen */
    MAINDIAL[rbuts[i]].ob_state |= SELECTED;
    volume = 15 - (WORD)(MIN((old_ltatten =
        (WORD)soundcmd(LTATTEN, -1)),
        old_rtatten = (WORD)soundcmd(RTATTEN, -1)) / 16);
    set_atten(0);
    MAINDIAL[DCACHE].ob_state = (settings[_DATACACHE] *
        CROSSED) | SELECTED;
    MAINDIAL[ICACHE].ob_state = (settings[_INSTCACHE] *
        CROSSED) | SELECTED;
    MAINDIAL[CPU8MHZ].ob_state = (settings[_CPU8MHZ] *
        CROSSED) | SELECTED;
    MAINDIAL[BLIT8MHZ].ob_state = (settings[_BLIT8MHZ] *
        CROSSED) | SELECTED;
    MAINDIAL[STEBUS].ob_state = (settings[_BUSMODE] *
        CROSSED) | SELECTED;
    MAINDIAL[SPEAKER].ob_state = (settings[_SPEAKER] *
        CROSSED) | SELECTED;
    MAINDIAL[TIMERA].ob_state = (settings[_TIMERA] *
        CROSSED) | SELECTED;
    MAINDIAL[MFPI7].ob_state = (settings[_MFPI7] *
        CROSSED) | SELECTED;
    MAINDIAL[SCRADR].ob_state |= CROSSED;
    do
    {
        /* Dialog bearbeiten */
        if ((button = do_dialog(MAINDIAL,
            0, handle_maindial)) != OK)
        {
            if (button == ABBRUCH)
            {
                /* LautstÑrke auf alten Wert zurÅcksetzen */
                soundcmd(LTATTEN, old_ltatten);
                soundcmd(RTATTEN, old_rtatten);
                end = 1;
            }
            else
            {
                /* Das Feld settings entsprechend den Einstellungen */
                /* Dialog belegen */
                put_settings();
                /* Speicherroutine aufrufen */
                save();
            }
        }
        else
        {
            /* settings-Feld belegen */
            put_settings();
            /* Booten oder öbernehmen? */
            if (form_alert(1, BOOTEN) == 1)
                boot();
            else
                end = take_settings();
        }
    } while (!end);
    /* Programm abmelden und tschÅû */
    appl_exit();
    return(0);
}

/* Hier werden die Miniprogramme gespeichert */
void save(void)
{
    WORD    cont,
            i;
    char    title[41], name[129];
    
    /* Welcher Miniprogrammtyp soll's denn sein? */
    cont = do_dialog(SAVEDIAL, 0, handle_savedial);
    if (cont != SAVEOK)
        return;
    if (SAVEDIAL[BOOTPRG].ob_state & SELECTED)
    {
        /* Warnung ausgeben, wenn 1 MB-Rechner mit 1 MB konfiguriert */
        /* werden soll, weil dabei der PMMU-Baum nicht geschÅtzt */
        /* werden kann */
        if ((ram <= 0x100000LU) &&
            settings[_RAMCONFIG])
        {
            if (settings[_SCRBASE])
                cont = (do_dialog(WARNING1, 0, 0L) == W1OK);
            else
                cont = (do_dialog(WARNING4, 0, 0L) == W4OK);
            if (!cont)
                return;
        }
        /* Programmtyp "mini1" speichern */
        if (do_save(mini1, sizeof(mini1)))
            form_alert(1, DISKERR);
    }
    else
    {
        /* Warnung ausgeben, daû bei Programmen, die nicht booten */
        /* sollen, die Ramkonfiguration unberÅcksichtigt bleibt */
        /* und somit kein sicherer Platz fÅr den PMMU-Baum da ist */
        cont = (do_dialog(WARNING2, 0, 0L)
            == W2OK);
        if (!cont)
            return;
        /* Soll das Einstellprogramm ein Programm nachladen? */
        if (form_alert(1, LOADONE) == 1)
        {
            /* Wenn ja, welches? */
            sprintf(name, "");
            sprintf(title, "Nachzuladendes Programm wÑhlen!");
            if (fileselect(path, name, &cont, title))
            {
                if (!cont)
                    return;
                for (i = 0; ((WORD *)mini2)[i]
                    != (WORD)0xabce; i++);
                strcpy(&mini2[--i * 2], name);
            }
            else
                return;
        }
        /* Programmtyp "mini2" speichern */
        if (do_save(mini2, sizeof(mini2)))
            form_alert(1, DISKERR);
    }
}

/* Routine zum Schreiben eines Miniprogramms */
WORD do_save(char *rout, LONG size)
{
    WORD    i, j,
            handle,
            save;
    char    name[129], title[41];
    
    /* Werte aus settings-Feld in Programm eintragen */
    for (i = 0; ((WORD *)rout)[i] != (WORD)0xabdc; i++);
    for (j = 0; j < 11; j++)
        ((WORD *)rout)[++i] = settings[j];
    /* GewÅnschten Namen erfragen */
    sprintf(title, "Name des Miniprogramms wÑhlen!");
    sprintf(name, "");
    if (fileselect(path, name, &save, title))
        if (save)
        {
            /* Nachfragen, ob ein existierendes File Åberschrieben */
            /* werden soll */
            if (exist(name))
            {
                if (form_alert(1, FEXISTS) == 2)
                    return(0);
            }
            /* Datei anlegen und Routine hineinschreiben */
            handle = (WORD)Fcreate(name, 0);
            if (handle < 0)
                return(1);
            Fwrite(handle, size, (void *)rout);
            Fclose(handle);
        }
    return(0);
}

/* Magic Pack anlegen und Reset auslîsen */
void boot(void)
{
    WORD    i, j,
            sum,
            first,
            cont,
            checkpos,
            pos;
    LONG    help;
    
    /* Warnung ausgeben, wenn 1 MB-Rechner mit 1 MB konfiguriert */
    /* werden soll, weil dabei der PMMU-Baum nicht geschÅtzt */
    /* werden kann */
    if ((ram <= 0x100000LU) &&
        settings[_RAMCONFIG])
    {
        if (settings[_SCRBASE])
            cont = (do_dialog(WARNING1, 0, 0L) == W1OK);
        else
            cont = (do_dialog(WARNING4, 0, 0L) == W4OK);
         if (!cont)
            return;
    }
    /* Warnung vor Reset */
    if (form_alert(1, RESET) == 2)
        return;
    /* Startadresse der GEMDOS-Routine fÅr die alte Bildschirmadresse */
    /* und des PMMU-Baums bestimmen */
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
            /* Bei entsprechend gekennzeichnetem Eintrag den richtigen */
            /* Offset berechnen */
            new_pmmu_tree[i] =
                rootpointer[1] +
                (new_pmmu_tree[i] & 65535LU);
        }
        else
        {
            /* Sollen Daten- und Befehlscache ausgeschaltet werden, im */
            /* PMMU-Baum Cache-Inhibit-Flag setzen */
            if (!settings[_DATACACHE] &&
                !settings[_INSTCACHE])
            {
                new_pmmu_tree[i] |= 64LU;
            }
        }
        ((LONG *)rootpointer[1])[i] =
            new_pmmu_tree[i];
    }
    /* GEMDOS-Routine kopieren (egal, ob sie gebraucht wird, oder nicht */
    for (i = 0; _gemdos[i] != (WORD)0xabcd; i++)
        gdrout[i] = _gemdos[i];
    gdrout += 6L;
    /* Beginn des Magic Pack bestimmen (muû auf 512-Byte-Grenze fallen) */
    /* Die Magic Packs sind Åbrigens offiziell nicht dokumentiert, sie */
    /* sollten also nur sehr selten benutzt werden */
    help = (LONG)magic_pack;
    if (help % 512L)
        help += 512L - (help % 512L);
    first = pos = (WORD)((help - (LONG)magic_pack) / 2L);
    /* Erster Long-Wert im Magic Pack muû 0x12123456 sein */
    magic_pack[pos++] = 0x1212;
    magic_pack[pos++] = 0x3456;
    /* Im zweiten Long-Wert muû die Anfangsadresse des Packs stehen */
    magic_pack[pos++] = (WORD)(help >> 16);
    magic_pack[pos++] = (WORD)(help & 65535L);
    /* Assembler-Routine kopieren */
    for (i = 0; mpack[i] != (WORD)0xabcd; i++)
        magic_pack[pos + i] = mpack[i];
    /* 16-Bit-PrÅfsumme Åber den Magic Pack bilden */
    for (j = sum = 0; j < 256; sum += magic_pack[first + j++]);
    checkpos = (pos << 1) +
        (WORD)((LONG)&checksum - (LONG)mpack);
    /* Checksumme so Ñndern, daû die PrÅfsumme 0x5678 ergibt (sonst */
    /* wird der Magic Pack nicht ausgefÅhrt) */
    magic_pack[checkpos >> 1] += (0x5678 - sum);
    /* Reset auslîsen */
    Supexec(reset);
}

/* Einstellungen direkt Åbernehmen */
WORD take_settings(void)
{
    WORD goon;
    
    /* Warnung ausgeben, daû beim öbernehmen die Ramkonfiguration */
    /* nicht berÅcksichtigt wird und daher auch der PMMU-Baum nicht */
    /* gesichert werden kann. Auûerdem bleibt die alte Bildschirm- */
    /* adresse, falls gewÅnscht, hier nur bis zum nÑchsten Auflî- */
    /* sungswechsel per Desktop erhalten */
    if (settings[_SCRBASE])
    {
        /* Alte Bildschirmadresse ist nur bei aktiven ST-Modus mîglich */
        if (!(Vsetmode(-1) & STMODES))
        {
            form_alert(1, NOSTMODE);
            return(0);
        }
        goon = (do_dialog(WARNING3, 0, 0L)
            == W3OK);
    }
    else
    {
        goon = (do_dialog(WARNING2, 0, 0L)
            == W2OK);
    }
    /* Einstellroutine aufrufen */
    if (goon)
        Supexec(set);
    return(goon);
}

/* Einstellungen aus dem Dialog in das Feld settings Åbernehmen */
void put_settings(void)
{
    WORD i;
    
    settings[_DATACACHE] = 0x3100 *
        !(!(MAINDIAL[DCACHE].ob_state & CROSSED));
    settings[_INSTCACHE] = 0x11 *
        !(!(MAINDIAL[ICACHE].ob_state & CROSSED));
    for (i = 0; i < 4; i++)
    {
        if (MAINDIAL[rbuts[i]].ob_state & SELECTED)
        {
            settings[_RAMCONFIG] = i;
            break;
        }
    }
    settings[_CPU8MHZ] =
        !(MAINDIAL[CPU8MHZ].ob_state & CROSSED);
    settings[_BLIT8MHZ] = 4 *
        !(MAINDIAL[BLIT8MHZ].ob_state & CROSSED);
    settings[_BUSMODE] = 32 *
        !(MAINDIAL[STEBUS].ob_state & CROSSED);
    settings[_SPEAKER] = 64 *
        !(MAINDIAL[SPEAKER].ob_state & CROSSED);
    settings[_SCRBASE] =
        MAINDIAL[SCRADR].ob_state & CROSSED;
    settings[_TIMERA] =
        !(!(MAINDIAL[TIMERA].ob_state & CROSSED));
    settings[_MFPI7] =
        !(!(MAINDIAL[MFPI7].ob_state & CROSSED));
    settings[_VOLUME] = (15 - volume) * 16;
}

/* LautstÑrke einstellen */
void set_atten(WORD redraw)
{
    WORD x, y, w, h;
    
    MAINDIAL[VOLUME].ob_x = volume * char_w;
    sprintf(MAINDIAL[VOLUME].ob_spec.tedinfo->te_ptext,
        "%d", volume);
    /* Soll der Slider neu gezeichnet werden? */
    if (redraw)
    {
        objc_offset(MAINDIAL, SLIDER, &x, &y);
        w = MAINDIAL[SLIDER].ob_width;
        h = MAINDIAL[SLIDER].ob_height;
        objc_draw(MAINDIAL, SLIDER, 1,
                    x, y, w, h);
    }
    /* Wenn der "Live"-Button gewÑhlt ist, die LautstÑrke auch */
    /* tatsÑchlich aktivieren */
    if (MAINDIAL[LIVE].ob_state & CROSSED)
    {
        soundcmd(LTATTEN, (15 - volume) * 16);
        soundcmd(RTATTEN, (15 - volume) * 16);
    }
}

/* Universelle Dialogverwaltungsroutine, ruft nach solange nach jedem */
/* form_do action auf, bis dieses 0 zurÅckgibt */
WORD do_dialog(OBJECT *tree, WORD sobj,
    WORD (*action)(OBJECT *tree, WORD obj))
{
    WORD    x, y, w, h,
            cont,
            obj;

    wind_update(BEG_UPDATE);
    wind_update(BEG_MCTRL);
    /* Grîûe der "billigen" Checkboxen und Radiobuttons anpassen */
    /* (billig deswegen, weil ohne G_USERDEF-Objekte gearbeitet */
    /* wird) */
    tree_walk(tree, 0, adapt_size);
    /* Dialog zentrieren und zeichnen */
    form_center(tree, &x, &y, &w, &h);
    form_dial(FMD_START, x, y, w, h, x, y, w, h);
    objc_draw(tree, ROOT, MAX_DEPTH,
        x, y, w, h);
    do
    {
        /* Dialog bearbeiten, und ggf. die Åbergebene Reaktionsroutine */
        /* aufrufen */
        obj = form_do(tree, sobj);
        if (action != NULL)
            cont = (*action)(tree, obj);
        else
            cont = 0;
    } while (cont);
    /* Wenn das letzte Objekt noch selektiert ist, den Status zurÅck- */
    /* setzen */
    if ((tree[obj].ob_flags & SELECTABLE) &&
        (tree[obj].ob_state & SELECTED))
    {
        tree[obj].ob_state &= ~SELECTED;
    }
    /* Dialog beenden und zuletzt gewÑhltes Objekt zurÅckgeben */
    form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
    wind_update(END_MCTRL);
    wind_update(END_UPDATE);
    return(obj);
}

/* Routine, die auf das Anklicken eines Objektes im Speichern-Dialog */
/* reagiert. Wird von do_dialog aufgerufen */
WORD handle_savedial(OBJECT *tree, WORD obj)
{
    /* Doppelklick-Bit entfernen */
    obj &= 0x7fff;
    /* Auf das Anklicken des Radiobutton-Textes reagieren */
    if (tree[obj].ob_type == G_STRING)
        cross(tree, obj - 1);
    /* RÅckgabewert 0, wenn "Speichern" oder "Abbruch" angeklickt */
    /* wurde (do_dialog wird dadurch beendet) */
    return(!(tree[obj].ob_flags & EXIT));
}

/* Routine zum Verwalten des Hauptdialogs, wird von do_dialog aufgerufen */
WORD handle_maindial(OBJECT *tree, WORD obj)
{
    WORD    raw,
            x, y, w, h,
            old_volume,
            dummy,
            x2, y2;
    
    /* Doppelklick-Bit merken und entfernen */
    raw = obj;
    obj &= 0x7fff;
    /* Nur etwas machen, wenn angeklicktes Objekt nicht dekativiert war */
    /* (form_do bzw. intern form_button hat da je nach Objekttyp so */
    /* seine Probleme) */
    if (!(tree[obj].ob_state & DISABLED))
    {
        /* Wenn es ein Radiobutton- oder Checkbox-Text war, den */
        /* dazugehîrigen Button bearbeiten */
        if (tree[obj].ob_type == G_STRING)
            cross(tree, obj - 1);
        /* Checkboxen ankreuzen, wenn sie angeklickt wurden */
        if (tree[obj].ob_type == (0xfe00|G_BOX))
            cross(tree, obj);
        /* Verschieben des Sliders, wenn das LautstÑrke-Feld angeklickt */
        /* wurde */
        if (obj == VOLUME)
        {
            objc_offset(tree, VOLUME,
                &x, &y);
            w = tree[SLIDER].ob_width;
            h = tree[SLIDER].ob_height;
            objc_offset(tree, SLIDER,
                &x2, &y2);
            graf_dragbox(tree[VOLUME].ob_width,
                tree[VOLUME].ob_height,
                x, y, x2, y2, w, h,
                &x, &y);
            volume = (x - x2) / char_w;
            set_atten(1);
        }
        /* Wurde auf den Sliderhintergrund geklickt, entsprechend */
        /* reagieren */
        if (obj == SLIDER)
        {
            wind_update(BEG_MCTRL);
            graf_mkstate(&x, &y, &dummy, &dummy);
            objc_offset(tree, VOLUME, &x2, &y2);
            do
            {
                old_volume = volume;
                if (x < x2)
                {
                    if (volume >= 3)
                        volume -= 3;
                    else
                        volume = 0;
                }
                else
                {
                    if (volume <= 12)
                        volume += 3;
                    else
                        volume = 15;
                }
                if (old_volume != volume)
                {
                    set_atten(1);
                    evnt_timer(80, 0);
                }
            } while (!(evnt_multi(MU_TIMER|MU_BUTTON, 1, 1, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 1, 0,
                &x, &y, &dummy, &dummy, &dummy, &dummy) &
                MU_BUTTON));
            wind_update(END_MCTRL);
        }
        /* Bei den Auf- bzw. Ab-Pfeilen die LautstÑrke um eins erhîhen */
        /* bzw. verringern. Bei Doppelklick auf 15 bzw. 0 setzen */
        if ((obj == UP) && (volume < 15))
        {
            if (obj != raw)
                volume = 15;
            else
                volume++;
            set_atten(1);
            evnt_timer(80, 0);
        }
        if ((obj == DOWN) && volume)
        {
            if (obj != raw)
                volume = 0;
            else
                volume--;
            set_atten(1);
            evnt_timer(80, 0);
        }
    }
    /* 0 zurÅckgeben, wenn ein Button mit gesetzen Exit-Flag gewÑhlt */
    /* wurde (OK, Abbruch oder Speichern). do_dialog wird dadurch */
    /* beendet */
    return(!(tree[obj].ob_flags & EXIT));
}

/* Checkboxen ankreuzen oder Radiobuttons invertieren (letzteres wird */
/* dann gebraucht, wenn nur der Text des Buttons gewÑhlt wurde) */
void cross(OBJECT *tree, WORD obj)
{
    WORD    x, y, w, h,
            draw = 1,
            dummy;
    
    objc_offset(tree, obj, &x, &y);
    w = tree[obj].ob_width;
    h = tree[obj].ob_height;
    /* Bei Radiobutton form_button aufrufen, sonst den Ankreuz-Status */
    /* invertieren */
    if (tree[obj].ob_flags & RBUTTON)
    {
        form_button(tree, obj, 1, &dummy);
        draw = 0;
    }
    else
        tree[obj].ob_state ^= CROSSED;
    /* Ggf. Objekt neuzeichnen */
    if (draw)
    {
        objc_draw(tree, obj, 0, x, y, w, h);
        evnt_button(1, 1, 0, &dummy, &dummy,
            &dummy, &dummy);
    }
}

/* Routine zum Durchwandern des Objektbaumes tree, ab Objekt start. */
/* Bei jedem Objekt wird action aufgerufen, wenn action 0 zurÅckgibt, */
/* wird abgebrochen */
WORD tree_walk(OBJECT *tree, WORD start,
    WORD (*action)(OBJECT *tree, WORD obj))
{
    WORD    i,
            cont;
    
    for (i = tree[start].ob_head, cont = 1;
        (i != start) && (i != -1) && cont;
        i = tree[i].ob_next)
    {
        cont = (*action)(tree, i);
        if (cont)
            cont = tree_walk(tree, i, action);
    }
    return(cont);
}

/* Routine zum Anpassen der Grîûen von Radiobuttons und Checkboxen, wird */
/* von tree_walk aufgerufen */
WORD adapt_size(OBJECT *tree, WORD obj)
{
    if (tree[obj].ob_type == (0xff00 | G_BOX))
    {
        tree[obj].ob_width--;
        tree[obj].ob_height--;
        tree[obj].ob_type = 0xfe00|G_BOX;
    }
    return(1);
}

/* Universelle Fileselektor-Routine, gleiche Parameter wie bei */
/* fsel_exinput. name enthÑlt nachher allerdings den kompletten */
/* Pfadnamen, nicht nur den Namen selbst, deshalb genÅgend Platz */
/* fÅr name reservieren. Es wird automatisch geprÅft, ob fsel_exinput */
/* aufgerufen werden kann. Auûerdem wird eine Meldung ausgegeben, wenn */
/* fsel_(ex)input einen Fehler gemeldet hat. */
WORD fileselect(char *path, char *name, WORD *button, char *title)
{
    char    temp1[129], temp2[129];
    WORD    i, fsel_ok;
    
    /* PrÅfen, ob fsel_exinput aufgerufen werden kann, dabei wird auch */
    /* der FSEL-cookie geprÅft, der z.B. von SELECTRIC angelegt wird */
    if (((_GemParBlk.global[0] >= 0x0140) &&
        (_GemParBlk.global[0] < 0x0200)) ||
        (_GemParBlk.global[0] >= 0x0300) || get_cookie('FSEL', 0L))
    {
        fsel_ok = fsel_exinput(path, name, button, title);
    }
    else
        fsel_ok = fsel_input(path, name, button);
    
    if (fsel_ok)
    {
        /* Wurde OK geklickt, kompletten Zugriffspfad fÅr name */
        /* zusammensetzen */
        if (*button)
        {
            strcpy(temp1, path);
            
            i = (WORD)strlen(temp1) - 1;
            
            while ((temp1[i] != '\\') && (i >= 0))
                temp1[i--] = 0;
            
            strcpy(temp2, name);
            strcpy(name, temp1);
            strcat(name, temp2);
        }
    }
    else
    {
        form_alert(1, "[3][Fehler bei Dateiauswahl|aufgetreten!]"
                    "[Abbruch]");
    }
    return(fsel_ok);
}

/* öberprÅfen, ob Åbergebenes File existiert (RÅckgabewert 1), oder */
/* nicht (RÅckgabewert 0) */
WORD exist(char *file)
{
    DTA     disk_buf;
    WORD    ret;

    graf_mouse(BUSYBEE, 0L);
    
    Fsetdta(&disk_buf);
    ret = !Fsfirst(file, 0x17);
    
    graf_mouse(ARROW, 0L);
    
    return(ret);
}

/* öberprÅft, ob der Cookie cookie vorhanden ist und schreibt dessen */
/* Wert dann in value. RÅckgabewert 0, wenn der Cookie nicht vorhanden */
/* ist, sonst 1 */
WORD get_cookie(ULONG cookie, ULONG *value)
{
    LONG    *jar,
            old_stack;
    
    if (Super((void *)1L) == 0L)
    {
        old_stack = Super(0L);
        jar = *((LONG **)0x5a0L);
        Super((void *)old_stack);
    }
    else
        jar = *(LONG **)0x5a0;
    
    if (jar == 0L)
        return(0);
    
    while (jar[0])
    {
        if (jar[0] == cookie)
        {
            if (value != 0L)
                *value = jar[1];
            
            return(1);
        }
        
        jar += 2;
    }
    return(0);
}
/* Modulende */
