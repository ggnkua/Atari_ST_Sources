/*
**
** Dies ist der Assembler-Teil des CD-XFS fuer MagiX
** Entwickelt mit PASM.
**
** (C) Andreas Kromke 1997
**
**
*/

     INCLUDE "MGX_XFS.INC"


/*
*
* Dies ist die šbergabestruktur zwischen
* dem Assembler- Teil des XFS und dem C-Teil.
* Der C- Teil bekommt seine Parameter
* ber den Stack ("cdecl"-Konvention), damit beliebige
* Compiler verwendet werden k”nnen.
*
*/

     XREF cdecl_cdxfs		; XFS-Sprungtabelle
     XREF cdecl_cddev		; Dateitreiber


/*
*
* Dies sind die eigentlichen Treiber, die ber eine
* Assemblerschnittstelle mit dem MagiX- Kernel und
* ber eine C-Schnittstelle mit dem MAC-Teil
* kommunizieren.
*
*/

     XDEF	cdxfs			; Hier ist das XFS
     XDEF cddev			; Hier der Dateitreiber


cdxfs:
 DC.B     'FTP_XFS',0              ; Name
 DC.L     0                        ; n„chstes XFS
 DC.L     0                        ; Flags
 DC.L     0					; xfs_init
 DC.L     cdxfs_sync
 DC.L     cdxfs_pterm
 DC.L     cdxfs_garbcoll
 DC.L     cdxfs_freeDD
 DC.L     cdxfs_drv_open
 DC.L     cdxfs_drv_close
 DC.L     cdxfs_path2DD
 DC.L     cdxfs_sfirst
 DC.L     cdxfs_snext
 DC.L     cdxfs_fopen
 DC.L     cdxfs_fdelete
 DC.L     cdxfs_link
 DC.L     cdxfs_xattr
 DC.L     cdxfs_attrib
 DC.L     cdxfs_chown
 DC.L     cdxfs_chmod
 DC.L     cdxfs_dcreate
 DC.L     cdxfs_ddelete
 DC.L     cdxfs_DD2name
 DC.L     cdxfs_dopendir
 DC.L     cdxfs_dreaddir
 DC.L     cdxfs_drewinddir
 DC.L     cdxfs_dclosedir
 DC.L     cdxfs_dpathconf
 DC.L     cdxfs_dfree
 DC.L     cdxfs_wlabel
 DC.L     cdxfs_rlabel
 DC.L     cdxfs_symlink
 DC.L     cdxfs_readlink
 DC.L     cdxfs_dcntl


cddev:
 DC.L     cddev_close
 DC.L     cddev_read
 DC.L     cddev_write
 DC.L     cddev_stat
 DC.L     cddev_seek
 DC.L     cddev_datime
 DC.L     cddev_ioctl
 DC.L     cddev_getc
 DC.L     cddev_getline
 DC.L     cddev_putc



**********************************************************************
*
* void xfs_sync( a0 = DMD *d )
*

cdxfs_sync:
 move.l   a0,-(sp)
 move.l	cdecl_cdxfs+xfs_sync,a0
 jsr      (a0)
 addq.l   #4,sp
 rts


**********************************************************************
*
* void xfs_pterm( a0 = DMD *d, a1 = PD *pd )
*
* Ein Programm wird gerade terminiert. Das XFS kann alle von diesem
* Programm belegten Ressourcen freigeben.
* Alle Ressourcen, von dem der Kernel wei (d.h. ge”ffnete Dateien)
* sind bereits vom Kernel freigegeben worden.
*

cdxfs_pterm:
 move.l   a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_pterm,a0
 jsr      (a0)
 addq.l   #8,sp
 rts


**********************************************************************
*
* long xfs_garbcoll( a0 = DMD *dir )
*
* Sucht nach einem unbenutzten FD
* Rckgabe TRUE, wenn mindestens einer gefunden wurde.
*

cdxfs_garbcoll:
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_garbcoll,a0
 jsr      (a0)
 addq.l   #4,sp
 rts


**********************************************************************
*
* void xfs_freeDD( a0 = DD *dir )
*
* Der Kernel hat den Referenzz„hler des DD auf 0 dekrementiert.
* Die Struktur kann jetzt freigegeben werden.
*

cdxfs_freeDD:
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_freeDD,a0
 jsr      (a0)
 addq.l   #4,sp
 rts


**********************************************************************
*
* long xfs_drv_open( a0 = DMD *dmd )
*
* Initialisiert den DMD.
* Diskwechsel auf der MAC-Seite sind z.Zt. noch nicht m”glich,
* daher wird bereits hier ein E_OK geliefert.
*

cdxfs_drv_open:
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_drv_open,a0
 jsr      (a0)
 addq.l   #4,sp
 rts


**********************************************************************
*
* long xfs_drv_close( a0 = DMD *dmd, d0 = int mode)
*
* mode == 0:   Frage, ob schlieen erlaubt, ggf. schlieen
*         1:   Schlieen erzwingen, mu E_OK liefern
*

cdxfs_drv_close:
 move.l	a0,-(sp)
 move.w	d0,-(sp)
 move.l	cdecl_cdxfs+xfs_drv_close,a0
 jsr      (a0)
 addq.l   #6,sp
 rts


**********************************************************************
*
* DD * xfs_path2DD( a0 = DD * reldir,
*                    a1 = char *pathname,
*                    d0 = int  mode )
*
* d1 ist der Pfad ohne Laufwerk
* -> d0 = DD *dir     oder Fehlercode
* -> d1 = char *fname
*
* Wandelt den Pfadnamen, der relativ zu <reldir> gegeben ist, in
* einen DD um.
*
* mode == 0: pathname zeigt auf eine beliebige Datei. Gib den DD
*            zurck, in dem die Datei liegt.
*            gib in a0 einen Zeiger auf den isolierten Dateinamen
*            zurck.
*         1: pathname ist selbst ein Verzeichnis, gib dessen DD
*            zurck, a0 ist danach undefiniert.
*
* Rckgabe:
*  d0 = DD des Pfades, Referenzz„hler entsprechend erh”ht
*  d1 = Rest- Dateiname ohne beginnenden '\'
* oder
*  d0 = ELINK
*  d1 = Restpfad ohne beginnenden '\'
*  a0 = DD des Pfades, in dem der symbolische Link liegt. Dies ist
*       wichtig bei relativen Pfadangaben im Link.
*  a1 = NULL
*            Der Pfad stellt den Parent des Wurzelverzeichnisses
*            dar, der Kernel kann, wenn das Laufwerk U: ist, auf
*            U:\ zurckgehen.
*  a1 = Pfad des symbolischen Links. Der Pfad enth„lt einen
*            symbolischen Link, wom”glich auf ein
*            anderes Laufwerk. Der Kernel mu den Restpfad <a0>
*            relativ zum neuen DD <a0> umwandeln.
*            a1 zeigt auf ein Wort fr die Zeichenkettenl„nge
*            (gerade Zahl auf gerader Adresse, inkl. EOS),
*            danach folgt die Zeichenkette. Der Puffer kann
*            flchtig sein, der Kernel kopiert den Pfad um.
*
*
* z.Zt. werden keine SymLinks untersttzt. Auch der Parent eines
* Wurzelverzeichnisses wird nicht korrekt behandelt.
* Es w„re sinnvoll, einen šberblick ber alle angeforderten DDs zu haben, um
* einer bereits referenzierten dirID keinen neuen Deskriptor anfordern
* zu mssen, sondern einfach den Referenzz„hler zu erh”hen.
*

cdxfs_path2DD:
 clr.l	-(sp)				; Platz fr Rckgabe Symlink
 clr.l	-(sp)				; Platz fr Rckgabe Symlink-DD
 clr.l	-(sp)				; Platz fr Rckgabe Restpfad
 pea		8(sp)				; &symlink
 pea		8(sp)				; &dd
 pea		8(sp)				; &restpfad
 move.w	d0,-(sp)				; mode
 move.l	a1,-(sp)				; pathname
 move.l	a0,-(sp)				; reldir
 move.l	cdecl_cdxfs+xfs_path2DD,a0
 jsr      (a0)
 adda.w   #22,sp
 move.l	(sp)+,d1				; restpfad
 move.l	(sp)+,a0				; Symlink-DD
 move.l	(sp)+,a1				; Symlink
 rts


**********************************************************************
*
* long xfs_sfirst(a0 = DD *d, a1 = char *name, d0 = DTA *dta,
*                  d1 = int attrib)
*
* Rckgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

cdxfs_sfirst:
 clr.l	-(sp)
 pea		(sp)
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_sfirst,a0
 jsr      (a0)
 adda.w	#18,sp
 move.l	(sp)+,a0
 rts


**********************************************************************
*
* long xfs_snext(a0 = DTA *dta, a1 = DMD *d)
*
* Rckgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

cdxfs_snext:
 clr.l	-(sp)
 pea		(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_snext,a0
 jsr      (a0)
 adda.w	#12,sp
 move.l	(sp)+,a0
 rts


**********************************************************************
*
* d0 = FD * xfs_fopen(a0 = DD *d, a1 = char *name, d0 = int omode,
*                      d1 = int attrib )
*
* ™ffnet und/oder erstellt Dateien, ™ffnet den Dateitreiber.
* Der Open- Modus ist vom Kernel bereits in die interne
* MagiX- Spezifikation konvertiert worden.
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel bernommen.
*
* Rckgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*

cdxfs_fopen:
 clr.l	-(sp)
 pea		(sp)
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_fopen,a0
 jsr      (a0)
 adda.w	#18,sp
 move.l	(sp)+,a0
 rts


*********************************************************************
*
* long xfs_fdelete(a0 = DD *d, a1 = char *name)
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel bernommen.
*
* Rckgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*
* Es drfen keine SubDirs oder Labels gel”scht werden.
*

cdxfs_fdelete:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_fdelete,a0
 jsr      (a0)
 addq.l	#8,sp
 rts


**********************************************************************
*
* long xfs_link(a0 = DD *altdir, a1 = DD *neudir,
*                   d0 = char *altname, d1 = char *neuname,
*				d2 = int flag)
*
* d2 = 1: Flink
* d2 = 0: Frename
*

cdxfs_link:
 move.w	d2,-(sp)
 move.l	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_link,a0
 jsr      (a0)
 adda.w	#18,sp
 rts


**********************************************************************
*
* long xfs_xattr( a0 = DD *dir, a1 = char *name, d0 = XATTR *xa,
*                  d1 = int mode )
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurck)
*         1:   Folge nicht  (d.h. erstelle XATTR fr den Link)
*

cdxfs_xattr:
 move.l	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_xattr,a0
 jsr      (a0)
 adda.w	#16,sp
 rts


**********************************************************************
*
* long xfs_attrib( a0 = DD *dir, a1 = char *name, d0 = int mode,
*                   d1 = int attrib )
*
* Rckgabe:    >= 0      Attribut
*              <  0      Fehler
*
* mode == 0:   Lies Attribut
*         1:   Schreibe Attribut
*

cdxfs_attrib:
 move.w	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_attrib,a0
 jsr      (a0)
 adda.w	#12,sp
 rts


**********************************************************************
*
* long xfs_chown( a0 = DD *dir, a1 = char *name, d0 = int uid,
*                  d1 = int gid )
*
* Rckgabe:    == 0      OK
*              <  0      Fehler
*

cdxfs_chown:
 move.w	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_chown,a0
 jsr      (a0)
 adda.w	#12,sp
 rts


**********************************************************************
*
* long xfs_chmod( a0 = DD *dir, a1 = char *name, d0 = int mode )
*
* Rckgabe:    == 0      OK
*              <  0      Fehler
*

cdxfs_chmod:
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_chmod,a0
 jsr      (a0)
 adda.w	#10,sp
 rts


**********************************************************************
*
* long xfs_dcreate(a0 = DD *d, a1 = char *name, d0 = int mode )
*
* mode wird hier ignoriert
*

cdxfs_dcreate:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dcreate,a0
 jsr      (a0)
 addq.l	#8,sp
 rts


**********************************************************************
*
* long xfs_ddelete( a0 = DD *d )
*
* Der DD darf nicht freigegeben werden (bleibt ge-lock-t!)
*

cdxfs_ddelete:
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_ddelete,a0
 jsr      (a0)
 addq.l	#4,sp
 rts


**********************************************************************
*
* long xfs_DD2name(a0 = DD *d, a1 = char *buf, d0 = int buflen)
*
* Wandelt DD in einen Pfadnamen um
*

cdxfs_DD2name:
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_DD2name,a0
 jsr      (a0)
 adda.w	#10,sp
 rts


**********************************************************************
*
* FD *xfs_dopendir( a0 = DD *d, d0 = int tosflag )
*

cdxfs_dopendir:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dopendir,a0
 jsr      (a0)
 addq.l	#6,sp
 rts


**********************************************************************
*
* long xfs_dreaddir( a0 = void *dh, d0 = int len, a1 = char *buf,
*                     d1 = XATTR *xattr, d2 = long *xr )
*
* Fšr Dreaddir (xattr = NULL) und Dxreaddir
*

cdxfs_dreaddir:
 move.l	d2,-(sp)
 move.l	d1,-(sp)
 move.l	a1,-(sp)
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dreaddir,a0
 jsr      (a0)
 adda.w	#18,sp
 rts


**********************************************************************
*
* long xfs_drewinddir( a0 = FD *d )
*

cdxfs_drewinddir:
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_drewinddir,a0
 jsr      (a0)
 addq.l	#4,sp
 rts


**********************************************************************
*
* long xfs_dclosedir( a0 = FD *d )
*

cdxfs_dclosedir:
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dclosedir,a0
 jsr      (a0)
 addq.l	#4,sp
 rts


**********************************************************************
*
* long xfs_dpathconf( a0 = DD *d, d0 = int which )
*
* mode = -1:   max. legal value for n in Dpathconf(n)
*         0:   internal limit on the number of open files
*         1:   max. number of links to a file
*         2:   max. length of a full path name
*         3:   max. length of an individual file name
*         4:   number of bytes that can be written atomically
*         5:   information about file name truncation
*              0 = File names are never truncated; if the file name in
*                  any system call affecting  this  directory  exceeds
*                  the  maximum  length (returned by mode 3), then the
*                  error value ERANGE is  returned  from  that  system
*                  call.
*
*              1 = File names are automatically truncated to the maxi-
*                  mum length.
*
*              2 = File names are truncated according  to  DOS  rules,
*                  i.e. to a maximum 8 character base name and a maxi-
*                  mum 3 character extension.
*         6:   0 = case-sensitiv
*              1 = nicht case-sensitiv, immer in Groschrift
*              2 = nicht case-sensitiv, aber unbeeinflut
*
*      If  any  of these items are unlimited, then 0x7fffffffL is
*      returned.
*

cdxfs_dpathconf:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dpathconf,a0
 jsr      (a0)
 addq.l	#6,sp
 rts


**********************************************************************
*
* long cdxfs_dfree( a0 = DD_FD *dir, a1 = long buf[4] )
*

cdxfs_dfree:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dfree,a0
 jsr      (a0)
 addq.l	#8,sp
 rts


**********************************************************************
*
* long xfs_wlabel( a0 = DD *d, a1 = char *name )
*

cdxfs_wlabel:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_wlabel,a0
 jsr      (a0)
 addq.l	#8,sp
 rts


**********************************************************************
*
* long xfs_rlabel( a0 = DD *d, a1 = char *name,
*                   d0 = char *buf, d1 = int len )
*

cdxfs_rlabel:
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_rlabel,a0
 jsr      (a0)
 adda.w	#14,sp
 rts


**********************************************************************
*
* long xfs_symlink( a0 = DD *d, a1 = char *name, d0 = char *to )
*
* erstelle symbolischen Link
*

cdxfs_symlink:
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_symlink,a0
 jsr      (a0)
 adda.w	#12,sp
 rts


**********************************************************************
*
* long xfs_readlink( a0 = DD *d, a1 = char *name, d0 = char *buf,
*                     d1 = int buflen )
*
* Lies symbolischen Link
*

cdxfs_readlink:
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_readlink,a0
 jsr      (a0)
 adda.w	#14,sp
 rts


**********************************************************************
*
* long xfs_dcntl( a0 = DD *d, a1 = char *name, d0 = int cmd,
*                  d1 = long arg )
*
* Fhrt Spezialfunktionen aus
*

cdxfs_dcntl:
 move.l	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cdxfs+xfs_dcntl,a0
 jsr      (a0)
 adda.w	#14,sp
 rts



**********************************************************************
**********************************************************************
*
* Dateitreiber
*
**********************************************************************
**********************************************************************
*
* long dev_read(a0 = FD *file, d0 = long count, a1 = char *buffer)
*

cddev_read:
 move.l	a1,-(sp)
 move.l	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cddev+dev_read,a0
 jsr      (a0)
 adda.w	#12,sp
 rts


**********************************************************************
*
* long dev_write(a0 = FD *file, d0 = long count, a1 = char *buffer)
*

cddev_write:
 move.l	a1,-(sp)
 move.l	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cddev+dev_write,a0
 jsr      (a0)
 adda.w	#12,sp
 rts


**********************************************************************
*
* long dev_getc( a0 = FD *f, d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rckgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*           0x0000FF1A bei EOF
*

cddev_getc:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_cddev+dev_getc,a0
 jsr      (a0)
 addq.l	#6,sp
 rts


**********************************************************************
*
* long dev_getline( a0 = FD *f, a1 = char *buf, d1 = long size,
*                      d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rckgabe: Anzahl gelesener Bytes oder Fehlercode
*

cddev_getline:
 move.w   d0,-(sp)                 ; mode
 move.l   d1,-(sp)                 ; size
 move.l   a1,-(sp)                 ; buf
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_getline,a0
 jsr      (a0)
 lea      14(sp),sp
 rts


**********************************************************************
*
* long dev_putc( a0 = FD *f, d0 = int mode, d1 = long value )
*
* mode & 0x0001:    cooked
*
* Rckgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*

cddev_putc:
 move.l   d1,-(sp)                 ; val
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_putc,a0
 jsr      (a0)
 lea      10(sp),sp
 rts


**********************************************************************
*
* long dev_stat(a0 = FD *f, a1 = long *unselect,
*                  d0 = int rwflag, d1 = long apcode)
*

cddev_stat:
 move.l   d1,-(sp)                 ; apcode
 move.w   d0,-(sp)                 ; rwflag
 move.l   a1,-(sp)                 ; unsel
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_stat,a0
 jsr      (a0)
 lea      14(sp),sp
 rts


**********************************************************************
*
* long dev_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

cddev_seek:
 move.w   d1,-(sp)                 ; mode
 move.l   d0,-(sp)                 ; where
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_seek,a0
 jsr      (a0)
 lea      10(sp),sp
 rts


**********************************************************************
*
* long dev_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*

cddev_ioctl:
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; cmd
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_ioctl,a0
 jsr      (a0)
 lea      10(sp),sp
 rts


**********************************************************************
*
* long long dev_datime(a0 = FD *file, a1 = int d[2], d0 = int set)
*

cddev_datime:
 move.w   d0,-(sp)                 ; set
 move.l   a1,-(sp)                 ; d
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_datime,a0
 jsr      (a0)
 lea      10(sp),sp
 rts


**********************************************************************
*
* long long dev_close(a0 = FD *file)
*
* schreibt alles zurck, ruft den Dateitreiber auf und gibt ggf.
* den FD frei.
*

cddev_close:
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_cddev+dev_close,a0
 jsr      (a0)
 addq.l   #4,sp
 rts

     END
