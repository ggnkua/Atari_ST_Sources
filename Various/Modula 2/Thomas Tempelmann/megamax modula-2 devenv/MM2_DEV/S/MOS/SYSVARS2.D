DEFINITION MODULE SysVars2;

(*  --------------------------------------------------------------------------
 *  System-Version: MOS 2.2
 *  Version       : 1.0
 *  Text-Version  : V#005
 *  Modul-Halter  : Dirk Steins
 *  Copyright Dezember 1990 by Dirk Steins
 *  --------------------------------------------------------------------------
 *  DS  : Dirk Steins
 *  TT  : Ter Tempelmann
 *  --------------------------------------------------------------------------
 *  Datum    Autor  Version  Bemerkung (Arbeitsbericht)
 *
 *  03.12.90 DS     0.1      Erste Definitionen
 *  04.12.90 DS     1.0      Alle Defintionen fertig
 *  06.12.90 TT     1.0      Kleine Korrekturen
 *)

(* Systemvariable nach dem Profibuch
 * Bezeichnungen nach
 *      Atari ST Profi Buch
 *      Jankowski, Rabich, Reschke
 *      Sybex-Verlag
 *
 * Mehr Informationen zu den Variablen gibt es ebenfalls in diesem
 * genanntem Werk.
 *
 * In diesem Modul sind die Systemvariablen nicht als Adressen
 * wie im Modul SysVars aufgefÅhrt, sondern direkt als absolut
 * adressierte Variablen.
 * Auf die Variablen darf nur aus dem Supervisormodus zugegriffen
 * werden, da sonst ein Bus-Error ("Zugriff auf unbekannte Adr.")
 * erfolgt. Verwenden Sie dazu z.B. die Funktionen des Moduls "SysUtil1".
 *)

FROM SYSTEM     IMPORT ADDRESS, BYTE;

FROM SysTypes   IMPORT BBS, PtrBP, PtrOSHeader;

FROM GrafBase   IMPORT PtrPalette;

TYPE PtrVBL     = POINTER TO ARRAY [0..MAX(SHORTCARD)] OF ADDRESS;

     PtrMD      = POINTER TO MD;
     MD         = RECORD
                    m_link  : PtrMD;
                    m_start : ADDRESS;
                    m_length: LONGCARD;
                    m_own   : PtrBP;
                  END;
     
     PtrHDInfo  = POINTER TO HDInfo;
     HDInfo     = RECORD
                    puns        : SHORTCARD;
                    pun         : ARRAY [0..15] OF BYTE;
                    partStart   : ARRAY [0..15] OF LONGCARD;
                    cookie      : LONGCARD;
                    cookiePtr   : ADDRESS;
                    versionNum  : SHORTCARD;
                    maxSectSize : SHORTCARD;
                    reserverd   : ARRAY [0..15] OF LONGCARD;
                  END;
                  
     PtrBCB     = POINTER TO BCB;
     BCB        = RECORD
                    n_link      : PtrBCB;       (* nÑchster BCB         *)
                    bufdrv      : SHORTINT;     (* Laufwerksnummer      *)
                    buftyp      : SHORTINT;     (* FAT- od. Dir-Buffer  *)
                    bufrec      : SHORTINT;     (* Recordnummer         *)
                    dirty       : SHORTINT;     (* Schreibzugriff hat
                                                 * stattgefunden        *)
                    dm          : ADDRESS;      (* Zeiger auf DMD       *)
                    bufr        : ADDRESS;      (* Zeiger auf Buffer    *)
                  END;
                  
     LBITSET    = SET OF [0..31];
     
     cookie     = RECORD
                    id          : ARRAY[0..3] OF CHAR;
                    value       : LONGCARD;
                  END;

VAR
    
 etv_timer  [$400] : ADDRESS;  (* Interrupt-Vektor des System-Timers *)
 etv_critic [$404] : ADDRESS;  (* Vektor fÅr den Critical-Error-Handler *)
 etv_term   [$408] : ADDRESS;  (* Interrupt-Vektor fÅr Prozeûbeendigungen *)
 etv_xtra   [$40c] : ARRAY [0..4] OF ADDRESS;
                               (* 5 reservierte Vektoren *)
 memvalid   [$420] : LONGCARD; (* = $752019f3 heiût, Speicherkonfiguration *)
                               (* ist gÅltig (nach RESET)                  *)
                               (* siehe auch memval2, memval3 und memcntrl *)
 memcntrl   [$424] : SHORTINT; (* Unteres Nibble des Schattenregisters des *)
                               (* Speicherkontroll-Registers ($ff8001)     *)
 resvalid   [$426] : LONGCARD; (* = $31415926 => bei RESET Åber resvector  *)
                               (*                springen                  *)
 resvector  [$42a] : ADDRESS;  (* siehe resvalid                           *)
 phystop    [$42e] : ADDRESS;  (* Zeigt auf 1. Byte Åber phys. Ende des RAM *)
 _membot    [$432] : ADDRESS;  (* Anfang des unter GEMDOS freien Speichers  *)
 _memtop    [$436] : ADDRESS;  (* Ende   des unter GEMDOS freien Speichers  *)
 memval2    [$43a] : LONGCARD; (* = $237698aa , gilt in Verbindung mit memval *)
 flock      [$43e] : SHORTINT; (* fÅr Sperren des DMA-Zugriffs             *)
 seekrate   [$440] : SHORTINT; (* Default-Werte fÅr die Floppy-Steprate    *)
 _timer_ms  [$442] : SHORTINT; (* Zeit in ms, die zwischen zwei System-Timer *)
                               (* Interrupts liegt, normalerweise 20 ms    *)
 _fverify   [$444] : SHORTINT; (* 0: kein Verify nach Floppy-Schreiben     *)
 _bootdev   [$446] : SHORTINT; (* legt das Boot-Laufwerk nach dem nÑchstem *)
                               (* RESET fest                               *)
 palmode    [$448] : SHORTINT; (* fÅr Fernsehnorm: FALSE=60Hz, sonst 50Hz  *)
 defshiftmd [$44a] : SHORTINT; (* Default Farb-Auflîsung: 0=320*200,1=640*200*)
 sshiftmd   [$44c] : BYTE;     (* Shadow des Shifter-Modus-Registers       *)
 _v_bas_ad  [$44e] : ADDRESS;  (* Zeiger auf den Anfang des Bildspeichers  *)
 vblsem     [$452] : SHORTINT; (* TRUE= VBL-Handler aktiviert              *)
 nvbls      [$454] : SHORTINT; (* Anzahl der EintrÑge in _vblqueue         *)
 _vblqueue  [$456] : PtrVBL;   (* Zeiger auf Tabelle mit Adressen der VBL- *)
                               (* Routinen. 1. Vektor immer Mausbewegung!! *)
 colorptr   [$45a] : PtrPalette; (* Zeiger auf Farbpalette nach nÑchstem VBL *)
                               (* (kann auch 0 sein, dann passiert nichts) *)
 screenpt   [$45e] : ADDRESS;  (* Zeiger auf Start des Bildschirms nach    *)
                               (* nÑchstem VBlank. (kann auch NIL sein)    *)
 _vbclock   [$462] : LONGCARD; (* Anzahl der bereits erfolgten VBlanks     *)
 _frclock   [$466] : LONGCARD; (* wie _vbclock, wird nur nicht durch vblsem *)
                               (* gestoppt                                 *)
 hdv_init   [$46a] : ADDRESS;  (* Vektor fÅr Init der logischen Drives     *)
 swv_vec    [$46e] : ADDRESS;  (* Vektor auf Routine bei Wechsel           *)
                               (* Mono <-> Color, normalerweise auf RESET  *)
 hdv_bpb    [$472] : ADDRESS;  (* Vektor fÅr GetBPB auf logischen Drives   *)
 hdv_rw     [$476] : ADDRESS;  (* Vektor fÅr Lesen/Schreiben auf log. Drives *)
 hdv_boot   [$47a] : ADDRESS;  (* Vek. fÅr Lesen des Bootsectors auf log. "  *)
 hdv_mediach[$47e] : ADDRESS;  (* Vek. fÅr Wechselstatus auf log. Drive    *)
 _cmdload   [$482] : BOOLEAN;  (* <>0 : Lade COMMAND.COM statt GEM nach Boot *)
 conterm    [$484] : BBS;      (* Attributbits fÅr CON:                    *)
 trp14ret   [$486] : ADDRESS;  (* Interne RÅcksprungadresse bei TRAP #14   *)
 criticret  [$48a] : ADDRESS;  (* Interne RÅcksprungadresse                *)
 themd      [$48e] : PtrMD;    (* MD-Struktur des GEMDOS. Nicht Ñndern!    *)
 _____md    [$49e] : PtrMD;    (* Platz fÅr weiteren MD                    *)
 savptr     [$4a2] : ADDRESS;  (* Zeiger auf BIOS Register-Stack           *)
 _nflops    [$4a6] : SHORTINT; (* Anzahl der angemeldeten Disk-Drives      *)
 con_state  [$4a8] : LONGCARD; (* Interner zeiger fÅr Bildschirmausgaben   *)
 sav_row    [$4ac] : SHORTINT; (* Speicher fÅr Cursor-Position             *)
 sav_context[$4ae] : ADDRESS;  (* Zeiger auf Speicherbereich fÅr Regs und  *)
                               (* Stack-Daten bei Exceptions (norm. $380)  *)
 _bufl      [$4b2] : ARRAY[0..1] OF PtrBCB;
                               (* Zeiger auf Buffer-Control-Blocks(BCB)    *)
 _hz_200    [$4ba] : LONGCARD; (* Bisherige Anzahl der 200Hz-Interrupts    *)
 the_env    [$4be] : ADDRESS;  (* Standard Environment Zeiger (unbenutzt)  *)
 _drvbits   [$4c2] : LBITSET;  (* Bit-Feld der angemeldeten Drives         *)
 _dskbufp   [$4c6] : ADDRESS;  (* Zeiger auf 1K-Puffer fÅr Disk-I/O        *)
 _autopath  [$4ca] : ADDRESS;  (* Zeiger auf Zugriffspfad fÅr AUTO-Ordner  *)
 _vbl_list  [$4ce] : ARRAY [0..6] OF ADDRESS;
                               (* UrsprÅngliche Liste der VBL-Routinen      *)
 _dumpflg   [$4ee] : SHORTINT; (* ZÑhler fÅr ALT-HELP-TastendrÅcke          *)
 _prtabt    [$4f0] : SHORTINT; (* Flag fÅr Abbruch des Druckvorgangs        *)
 _sysbase   [$4f2] : PtrOSHeader; (* Zeiger auf TOS-Header                  *)
 _shell_p   [$4f6] : ADDRESS;  (* Zeiger auf Kommandoeingabe-Routine einer  *)
                               (* Command-Shell. Im ROM nicht benutzt       *)
 end_os     [$4fa] : ADDRESS;  (* Zeiger auf 1. nicht vom TOS benutztes Byte*)
 exec_os    [$4fe] : ADDRESS;  (* Zeiger auf Shell-Programm nach Init von   *)
                               (* GEMDOS. Normalerweise AES und Desktop     *)
 scr_dump   [$502] : ADDRESS;  (* Zeiger auf Hardcopy-Routine               *)
 
 (* Die folgenden Variablen sind erst ab TOS 1.2 (Blitter-TOS) vorhanden
  *)
 
 prv_lsto   [$506] : ADDRESS;  (* Zeiger auf Routine fÅr Status der Drucker-*)
                               (* Schnittstelle. Ebenfalls fÅr Hardcopy     *)
 prv_lst    [$50a] : ADDRESS;  (* Zeiger auf Routine fÅr Ausgabe auf Drucker-*)
                               (* Schnittstelle. Ebenfalls fÅr Hardcopy     *)
 prv_auxo   [$50e] : ADDRESS;  (* Zeiger auf Routine fÅr Status der RS232-  *)
                               (* Schnittstelle. Ebenfalls fÅr Hardcopy     *)
 prv_aux    [$512] : ADDRESS;  (* Zeiger auf Routine fÅr Ausgabe auf RS232- *)
                               (* Schnittstelle. Ebenfalls fÅr Hardcopy     *)
 pun_ptr    [$516] : PtrHDInfo;(* Zeiger auf HDINFO-Struktur                *)
 memval3    [$51A] : LONGCARD; (* Siehe memval und memval2. Magic=$5555aaaa *)
 
 _longframe [$59E] : INTEGER;  (* Stackoffset bei Exceptions                *)
 
 (* Die folgenden Variablen sind erst ab TOS 1.6 (STE, TT) vorhanden
  *)
 
 _p_cookies [$5A0] : POINTER TO ARRAY[0..MAX(SHORTCARD)] OF cookie;
                               (* Zeiger auf CookieJar - ggf. Null          *)
 
 bell_hook  [$5AC] : ADDRESS;  (* Adresse fÅr 'Glocken'-Ton. Zeigt auf
                                * normale Prozedur, die mit RTS beendet
                                * werden muû. Kann Original aufrufen
                                *)
 kcl_hook   [$5B0] : ADDRESS;  (* Adresse fÅr 'Key-Click'-Ton. éhnlich
                                * bell_hook, sollte nur sehr kurz sein.
                                *)

 (* Die folgenden zwei sind noch nicht offiziell, sondern nur aus dem
  * SysMon entnommen, wahrscheinlich TT-Only
  *)
 
 fmemtop    [$5A4] : ADDRESS; (* Memtop fÅr Fast-RAM (TT-only!)             *)
 fmemvalid  [$5A8] : ADDRESS; (* Memvalid fÅr Fast-RAM. Magic nicht bekannt *)

END SysVars2.
