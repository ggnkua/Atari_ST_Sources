* -------------------------------------------------- *
*
*               XFORMDO.LIB Version 1.2
*
*          geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Headerdatei: XFORM.I
* Version: 1.0
* Datum: 14.9.1991
* -------------------------------------------------- *

        SECTION TEXT

        ABSSET  0

***
* globale Variabeln
***
gl_vhandle:     ds.w    1       *VDI-Handle
gl_gr_cw:       ds.w    1       *Zeichenbreite
gl_gr_ch:       ds.w    1       *Zeichenhîhe
gl_gr_bw:       ds.w    1       *Boxbreite
gl_gr_bh:       ds.w    1       *Boxhîhe
gl_max_w:       ds.w    1       *max. Rasterbreite
gl_max_h:       ds.w    1       *max. Rasterhîhe
gl_gr_res:      ds.w    1       *TRUE = X:Y = 1:1
gl_planes:      ds.w    1       *Anzahl der Ebenen

gl_biton:       ds.l    1       Zeiger auf Bitblk fÅr
gl_bitoff:      ds.l    1       runde Buttons...

gl_undobuff:    ds.b    256     Undobuffer
gl_keytab:      ds.l    1       Adresse auf Umwandlungstabellen
gl_moflags:     ds.w    1       Mausmeldung
gl_dinfo:       ds.l    1       Zeiger auf DINFO-Struktur

        IFD     ASS

gl_contrl:      ds.w     15
gl_global:      ds.w     15
gl_intin:       ds.w     128
gl_intout:      ds.w     45
gl_ptsout:      ds.w     128
gl_addrin:      ds.l     2
gl_addrout:     ds.l     1
gl_ptsin:       ds.w     128

        ELSE

gl_contrl:      ds.w     15
gl_intin:       ds.w     15
gl_intout:      ds.w     45
gl_ptsout:      ds.w     12
gl_addrin:      ds.l     2
gl_addrout:     ds.l     1
gl_ptsin:       ds.w     30

        ENDIF

gl_default:     ds.w    1       Defaultobjekt abhÑngig vom
gl_inddefault:  ds.w    1       Textobjekt
gl_aktivkom:    ds.w    1       Aktivierungskombination

ed_objptr:      ds.l    1       Zeiger auf Objekt
ed_obj:         ds.w    1       Objektnummer
ed_index:       ds.w    1       Index

gl_size         EQU     *       LÑnge
