UNIT AsmLib;

{*******************************************}
{* Die Unit AsmLib enthÑlt folgende        *}
{* Assembler-Routinen:                     *}
{*                                         *}
{*  procedure Do_Sound                     *}
{*  > ERZEUGT VERSCHIEDENE TONFOLGEN <     *}
{*                                         *}
{*  procedure XY_Size                      *}
{*  > ERMITTELT BILDSCHIRMAUFLôSUNG <      *}
{*                                         *}
{*  procedure Free_Mem                     *}
{*  > ERMITTELT GESAMTEN FREIEN SPEICHER < *}
{*                                         *}
{*  function Res_Mem                       *}
{*  > RESERVIERT SPEICHER <                *}
{*                                         *}
{*  function Desk_Akt                      *}
{*  > ERMITTELT OB DESKTOP AKTIV IST <     *}
{*                                         *}
{*  function F_Select                      *}
{*  > ERZEUGT DIE OPTIMALE FILESELECTBOX < *}
{*                                         *}
{*  procedure Screen                       *}
{*  > SICHERT/RETTET BILDSCHIRMINHALT <    *}
{*                                         *}
{*                                         *}
{*  (c) 1992 MAXON Computer                *}
{*  by JÅrgen Scherf                       *}
{*                                         *}
{*******************************************}

{---------------- GLOBALER TEIL -----------------}
Interface
{$F+,D+,R+,S+}

uses GemDecl,GemVDI;

  const                { GLOBALE CONST. DER UNIT }
    BIGBEN     = 10;          { Const. fÅr Sound }
    FEHLER     = 11;
    WARNUNG    = 12;
    SIGNAL     = 13;
    BIMBAM     = 14;
    S_XY       = 20;         { Const. fÅr Screen }
    R_XY       = 21;
    S_ALL      = 22;
    R_ALL      = 23;
    
  type                  { GLOBALE TYPEN DER UNIT }
    Str128     = String[128];
    Str40      = String[40];

    
  { FUNCTIONEN/PROCEDUREN DER UNIT BEKANNTMACHEN }
  procedure Do_Sound(nummer: integer);
  
  procedure XY_Size(VAR x,y,planes: integer);

  procedure Free_Mem(VAR frei,g_frei: LongInt);

  function Res_Mem(block: LongInt): Pointer;

  function Desk_Akt: boolean;

  function F_Select(VAR pfad,datei: Str128;
                     VAR titel: Str40): boolean;

  procedure Screen(modus,x,y,w,h: integer;
                   VAR scr_adr: LongInt);

{----------------- LOKALER TEIL -----------------}
Implementation   
{$F+,D+,R+,S+}

  const                 { LOKALE CONST. DER UNIT }
    AES_VDI    = 02;    { GEM-Aufruf fÅr AES/VDI }
    VDI        = 115;    { Funktionscode fÅr VDI }
    AES        = 200;    { Funktionscode fÅr AES }
    fs_inp     = 90;     { normale Fileselectbox }
    fs_exin    = 91;     { erweiterte    "       }
    Gemdos     = 01;             { GEMDOS-Aufruf }
    XBios      = 14;              { XBIOS-Aufruf }
    Dosound    = 32;         { Tonfolge ausgeben }
    Malloc     = 72;       { Speicherresevierung }
    Mfree      = 73;          { Speicherfreigabe }
    Mshrink    = 74; { Res. Speicher verkleinern }
    Supexec    = 38;             { XBIOS-Supexec }
    sysbase    = $4f2;   { Adr. der Var. SYSBASE }
    tos_102    = $102;        { TOS 1.02 Kennung }
    def_pd     = $602c; { Adr. PD bei TOS < 1.02 }
    Y_DOT      = -4;        { Offset fÅr Y-Pixel } 
    X_DOT      = -12;       { Offset fÅr X-Pixel } 
    A_INIT     = $a000;   { Adr. der Line-A Var. }
    CopRast    = 109;          { VDI COPY RASTER }
    GrfHand    = 77;           { AES GRAF_HANDLE }

  var                { LOKALE VARIABLEN DER UNIT }
    reg_A2               : LongInt;
    
    madr,mges,mblk       : LongInt;
    { VAR. FöR FREE_MEM & RES_MEM }
    akt_PD               : LongInt;
    { VAR. FöR AKT_PD }
    t_pfd,t_dat          : Array[0..128] of char;
    t_tit                : Array[0..40] of char;
    tos_ver              : integer;
    { VAR. FöR F_SELECT }
    akt_w,akt_h,akt_pl,
    handle,x2,y2         : integer;
    Mem_MFDB,Scr_MFDB    : MFDB;
    { VAR. FöR SCREEN }
    
{------------------------------------------------}
procedure Do_Sound(nummer: integer);
(* GIBT VERSCHIEDENE TONFOLGEN AUS *)
ASSEMBLER;

ASM
          (* PARAMETER AN REGISTER D1 *)
          move.w   nummer,d1

          (* KONTROLLE OB BIGBEN GEWöNSCHT *)
@sound1:  cmpi.w   #BIGBEN,d1          { Bigben? }
          bne      @sound2   { wenn nicht weiter }
          pea      @bigben    { Bigben auf Stack }
          bra      @go_sound { Tonfolge ausgeben }

          (* KONTROLLE OB FEHLER GEWöNSCHT *)
@sound2:  cmpi.w   #FEHLER,d1          { Fehler? }
          bne      @sound3   { wenn nicht weiter }
          pea      @fehler    { Fehler auf Stack }
          bra      @go_sound { Tonfolge ausgeben }

          (* KONTROLLE OB WARNUNG GEWöNSCHT *)
@sound3:  cmpi.w   #WARNUNG,d1        { Warnung? }
          bne      @sound4   { wenn nicht weiter }
          pea      @warnung  { Warnung auf Stack }
          bra      @go_sound { Tonfolge ausgeben }

          (* KONTROLLE OB SIGNAL GEWöNSCHT *)
@sound4:  cmpi.w   #SIGNAL,d1          { Signal? }
          bne      @sound5   { wenn nicht weiter }
          pea      @signal    { Signal auf Stack }
          bra      @go_sound { Tonfolge ausgeben }
          
          (* KONTROLLE OB BIMBAM GEWöNSCHT *)
@sound5:  cmpi.w   #BIMBAM,d1          { Bimbam? }
          bne      @return   { wenn nicht zurÅck }
          pea      @bimbam    { Bimbam auf Stack }

          (* SOUND ABSPIELEN *)
@go_sound:move.w   #Dosound,-(sp) { Funk.DOSOUND }
          trap     #XBios       { XBIOS aufrufen }
          addq.l   #6,sp      { Stack korrigieren}
          bra      @return   { Procedure beenden }

          (* SOUNDDATEN *)
@bigben:  DC.w $0810,$0900,$0a00,$0b01
          DC.w $0c00,$0d09,$07f8,$0015
          DC.w $0102,$0c48,$0d09,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$00a0
          DC.w $0d09,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$0057,$0d09,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$0081
          DC.w $0103,$0d09,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8206,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$0d09,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$0057,$0102
          DC.w $0d09,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$0015,$0d09,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$00a0
          DC.w $0d09,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8206,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8206
          DC.w $8203,$8203,$8203,$0015
          DC.w $0d09,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$00a0,$0d09,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$0057
          DC.w $0d09,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$0081,$0103,$0d09
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8206
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$0d09
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $0057,$0102,$0d09,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$0015
          DC.w $0d09,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$00a0,$0c60,$0d09
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$8203,$8203,$8203
          DC.w $8203,$07ff,$8200
@warnung: DC.w $0810,$0900,$0a00,$0b01
          DC.w $0c00,$0d09,$07f8,$00c0
          DC.w $0101,$0c0c,$0d09,$02c0
          DC.w $0301,$090c,$04a0,$0502
          DC.w $0a0c,$8206,$0d09,$8206
          DC.w $0d09,$8206,$0057,$0102
          DC.w $0c48,$0d09,$0257,$0302
          DC.w $0481,$0503,$8224,$0900
          DC.w $0a00,$8203,$07ff,$8200
@fehler:  DC.w $0800,$0900,$0a00,$0b01
          DC.w $0c00,$0d09,$07f8,$00c8
          DC.w $0100,$080c,$027b,$0301
          DC.w $090c,$04a3,$0502,$0a0c
          DC.w $8201,$00fd,$02c2,$0423
          DC.w $0503,$8201,$00c8,$027b
          DC.w $04a3,$0502,$8201,$00fd
          DC.w $02c2,$0423,$0503,$8201
          DC.w $00c8,$027b,$04a3,$0502
          DC.w $8201,$0800,$0900,$0a00
          DC.w $8201,$07ff,$8200
@signal:  DC.w $0810,$0900,$0a00,$0b01
          DC.w $0c00,$0d09,$07f8,$0015
          DC.w $0102,$0c80,$0d09,$8204
          DC.w $8204,$8204,$8204,$8204
          DC.w $8204,$8204,$8204,$8204
          DC.w $8204,$8204,$8204,$8204
          DC.w $8204,$8204,$8204,$8204
          DC.w $07ff,$8200
@bimbam:  DC.w $0810,$0900,$0a00,$0b01
          DC.w $0c00,$0d09,$07f8,$00c6
          DC.w $0100,$0c1c,$0d09,$8207
          DC.w $8207,$00f9,$0c54,$0d09
          DC.w $8207,$8207,$8207,$8207
          DC.w $8207,$8207,$8207,$07ff
          DC.w $8200

@return:                   { Procedure verlassen }

END;  {PROCEDURE SOUND }

{------------------------------------------------}
procedure XY_Size(VAR x,y,planes: integer); 
(* ERMITTELT DIE X- Y-AUFLôSUNG, UND FARBEBENEN *)
ASSEMBLER;

ASM
          (* XY-AUFLôSUNG UND PLANES ERMITTELN *)
          DC.w A_INIT          { Adr.Lina-A Var. }
          move.l   x,a1             { Adr. von x }
          move.w   X_DOT(a0),(a1)  { Pixelzahl X }
          move.l   y,a1             { Adr. von y }
          move.w   Y_DOT(a0),(a1)  { Pixelzahl Y }
          move.l   planes,a1   { Adr. von planes }
          move.w   (a0),(a1)        { Farbebenen }

END;  { PROCEDURE XY-SIZE }

{------------------------------------------------}
procedure Free_Mem(VAR frei,g_frei: LongInt);
(* LIEFERT GESAMTEN & GRôSSTEN FREIEN SPEICHER *)
ASSEMBLER;

ASM
          (* SPEICHERERMITTLUNG *)
          bsr      @MemFrei  { freier Speicher ? }
          cmpi.l   #0,d0  { noch Speicher frei ? }
          beq      @return    { nichts mehr frei }
          move.l   d0,mges      { Grîsse sichern }
          move.l   d0,mblk
          bsr      @MemRes    { Speicher belegen }
          move.l   d0,madr     { Adresse sichern }
          movea.l  d0,a1      { Adresse 1. Block }
@MemTest: move.l   d0,(a1)+       { Adr. ablegen }
          bsr      @MemFrei  { freier Speicher ? }
          cmpi.l   #0,d0  { noch Speicher frei ? }
          beq      @Free  { nein, dann freigeben }
          add.l    d0,mges     { freien Speicher }
                               { aufaddieren     }
          bsr      @MemRes    { Speicher belegen }
          bra      @MemTest  { nÑchster f. Block }

          (* BELEGTEN SPEICHER FREIGEBEN *)
@Free:    move.l   -(a1),-(sp)   { Adr. belegter }
                                 { Speicherblock }
          move.w   #Mfree,-(sp) { Funktion MFREE }
          trap     #Gemdos     { GEMDOS aufrufen }
          addq.l   #6,sp     { Stack korrigieren }
          move.l   madr,a0   { Adr. erster Block }
          cmpa.l   a0,a1   { alles freigegeben ? }
          bne      @Free            { noch nicht }
          bra      @return   { Procedure beenden }

          (* UP FREIER SPEICHER ABFRAGEN *)
@MemFrei: move.l   #-1,d0      { freier Speicher }
@MemRes:  move.l   d0,-(sp) 
          move.w   #Malloc,-(sp)  { Funk. MALLOC } 
          trap     #Gemdos     { GEMDOS aufrufen }
          addq.l   #6,sp     { Stack korrigieren }
          rts                { zurÅck zum Aufruf }

          (* ERGEBNISSE öBERGEBEN *)
@return:  move.l   frei,a0       { Adr. von FREI }
          move.l   g_frei,a1   { Adr. von G_FREI }
          move.l   mblk,(a0)   { freier Speicher }
          move.l   mges,(a1)     { gesamt freier }
                                 { Speicher      }
                           { Procedure verlassen }

END;  { PROCEDURE FREE_MEM }

{------------------------------------------------}
function Res_Mem(block: LongInt): Pointer;
(* RESERVIERT EINEN SPEICHERBLOCK *)
ASSEMBLER;

ASM
          (* SPEICHERERMITTLUNG *)
          clr.l    @result         { vorbesetzen }
          move.l   block,d1   { Param. Åbergeben }
          bsr      @MemFrei  { freier Speicher ? }
          move.l   d0,mblk      { Grîsse sichern }
          cmp.l    d1,d0         { gross genug ? }
          blt      @return   { nein, also zurÅck }
          bsr      @MemRes    { Speicher belegen }
          move.l   d0,madr     { Adresse sichern }
          movea.l  d0,a1      { Adresse 1. Block }
@MemTest: move.l   d0,(a1)+       { Adr. ablegen }
          bsr      @MemFrei  { freier Speicher ? }
          cmp.l    d1,d0         { gross genug ? }
          blt      @Malloc { nein, letzten Block }
                           { belegen             }
          move.l   d0,mblk      { Grîsse sichern }
          bsr      @MemRes       { Block belegen }
          bra      @MemTest  { nÑchster f. Block }
 
          (* BLOCK AM SPEICHERENDE BELEGEN *)
@Malloc:  sub.l    d1,mblk   { von Res. abziehen }
          move.l   mblk,-(sp)       { neue LÑnge }
          move.l   -4(a1),-(sp){ Adr.des Blockes }
          move.w   #0,-(sp)      { Nullparameter }
          move.w   #Mshrink,-(sp) { Funk.MSHRINK }
          trap     #Gemdos     { GEMDOS aufrufen }
          lea      12(sp),sp { Stack korrigieren }
          move.l   d1,d0     { Blockgrîsse an d0 }
          bsr      @MemRes       { Block belegen }
          move.l   d0,@result     { Adr. sichern }

          (* BELEGTEN SPEICHER FREIGEBEN *)
@Free:    move.l   -(a1),-(sp)   { Adr. belegter }
                                 { Speicherblock }
          move.w   #Mfree,-(sp) { Funktion MFREE }
          trap     #Gemdos     { GEMDOS aufrufen }
          addq.l   #6,sp     { Stack korrigieren }
          move.l   madr,a0   { Adr. erster Block }
          cmpa.l   a0,a1   { alles freigegeben ? }
          bne      @Free            { noch nicht }
          bra      @return   { Procedure beenden }

          (* UP FREIER SPEICHER ABFRAGEN *)
@MemFrei: move.l   #-1,d0      { freier Speicher }
@MemRes:  move.l   d0,-(sp) 
          move.w   #Malloc,-(sp)  { Funk. MALLOC } 
          trap     #Gemdos     { GEMDOS aufrufen }
          addq.l   #6,sp     { Stack korrigieren }
          rts                { zurÅck zum Aufruf }

@return:                    { Function verlassen }

END;  { FUNKTION RES_MEM }

{------------------------------------------------}
function Desk_Akt: boolean;
(* ERMITTELT OB DAS DESKTOP AKTIV IST *)
ASSEMBLER;

ASM
          (* KONTROLLE OB DESKTOP AKTIV *)
          clr.b    @result         { vorbesetzen }
          bsr      @PD_Test  { PD-Adr. ermitteln }
          movea.l  akt_PD,a0   { PD-Adr. nach a0 }
          cmpi.l   #0,$c(a0) { ProgrammlÑnge 0 ? }
          bne      @return { nein, nicht Desktop }
          move.b   #1,@result    { Desktop aktiv }
          bra      @return    { Funktion beenden }

          (* AKTUELLEN PD ABFRAGEN *)
@PD_Test: pea      @Akt_PD    { Adr. der Routine }
          move.w   #Supexec,-(sp) { Funk.SUPEXEC }
          trap     #XBios       { XBIOS aufrufen }
          addq.l   #6,sp     { Stack korrigieren }
          rts                { zurÅck zum Aufruf }
@Akt_PD:  movea.l  #sysbase,a0    { Adr. sysbase }
          movea.l  (a0),a0   { Adr. Systemheader }
          movea.l  #def_pd,a1  { Def.-PD nach a1 }
          cmpi.w   #tos_102,2(a0)   { TOS < 1.02 }
          bcs      @pd_adr  { ja, Def.-PD gÅltig }
          movea.l  40(a0),a1     { Zeiger auf PD }
@pd_adr:  move.l   (a1),akt_PD      { PD-Adresse }
          rts                { zurÅck zum Aufruf }

@return:                    { Function verlassen }

END;  { FUNCTION DESK_AKT }

{------------------------------------------------}
function F_Select(VAR pfad,datei: Str128;
                  VAR titel: Str40): boolean;
(* ERZEUGT DIE NORMALE ODER ERWEITERTE
   FILESELCTBOX (ABHéNGIG VON DER TOS-VERSION)  *)
ASSEMBLER;

ASM
          (* REGISTER A2 SICHERN *)
          move.l   a2,reg_A2  { Register sichern }
          clr.w    @result         { vorbesetzen }

          (* PFAD UND NAMEN INS TOS-FORMAT *)
          movea.l  pfad,a0     { Adr. Pfadstring }
          lea      t_pfd,a1    { Adr. TOS-String }
          bsr      @TosForm          { umwandeln }
          movea.l  datei,a0   { Adr. Dateistring }
          lea      t_dat,a1    { Adr. TOS-String }
          bsr      @TosForm          { umwandeln }

          (* KONTROLLE AUF TOS-VERSION >= 1.04 *)
          bsr      @TOS_Nr   { Versionsnr. holen }
          cmpi.w   #$0104,tos_ver   { V = 1.04 ? }
          bcc      @F_Exinp { ja, erweiterte Box }

          (* FILESELCTBOX OHNE TITELZEILE *)
          lea      control,a2 { Adr.control-Feld }
          move.w   #fs_inp,(a2)  { Feld besetzen }
          clr.w    2(a2)
          move.w   #2,4(a2) 
          move.w   #2,6(a2)
          clr.w    8(a2)
          lea      addrin,a2   { Adr.addrin-Feld }
          lea      t_pfd,a1          { Adr. Pfad }
          move.l   a1,(a2)           { Åbergeben }
          lea      t_dat,a1         { Adr. Datei }
          move.l   a1,4(a2)          { Åbergeben }
          bsr      @AESTrap       { AES aufrufen }
          bra      @button     { Werte Åbergeben }

          (* TITLESTRING INS TOS-FORMAT *)
@F_Exinp: movea.l  titel,a0   { Adr. Titelstring }
          lea      t_tit,a1    { Adr. TOS-String }
          bsr      @TosForm          { umwandeln }

          (* FILESELCTBOX MIT TITELZEILE *)
          lea      control,a2 { Adr.control-Feld }
          move.w   #fs_exin,(a2) { Feld besetzen }
          clr.w    2(a2)
          move.w   #2,4(a2) 
          move.w   #3,6(a2)
          clr.w    8(a2)
          lea      addrin,a2   { Adr.addrin-Feld }
          lea      t_pfd,a1          { Adr. Pfad }
          move.l   a1,(a2)           { Åbergeben }
          lea      t_dat,a1         { Adr. Datei }
          move.l   a1,4(a2)          { Åbergeben }
          lea      t_tit,a1         { Adr. Titel }
          move.l   a1,8(a2)          { Åbergeben }
          bsr      @AESTrap       { AES aufrufen }

          (* RöCKGABEWERTE öBERGEBEN *)
@button:  lea      intout,a2   { Adr.intout-Feld }
          move.w   (a2),d0         { RÅckmeldung }
          cmpi.w   #0,d0  { Fehler aufgetreten ? }
          beq      @return { ja,Funktion beenden }
          move.w   2(a2),d0         { betÑtigter }
          move.b   d0,@result  { Knopf Åbergeben }
          cmpi.w   #0,d0        { Knopf abfragen }
          beq      @return         { war ABBRUCH }

          (* PFAD- UND DATEINAMEN VERBINDEN *)
          movea.l  datei,a0   { Adr. Dateistring }
          lea      t_pfd,a1    { Adr. TOS-String }
          bsr      @StrForm     { Stringwandlung }
@ExtEntf: subq.w   #1,d0     
          cmpi.b   #'\',-(a0) { Backslash suchen }
          bne      @ExtEntf    { n.gef.-> weiter }
          addq.l   #1,a0    { Ende Pfadname gef. }
          addq.w   #1,d0   
          lea      t_dat,a1    { Adr. TOS-String }
@concat:  move.b   (a1)+,(a0)+  { Stringwandlung }
          addq.w   #1,d0    
          cmpi.b   #0,(a1)   { Ende Namen suchen }
          bne      @concat  { wenn nicht, weiter }
          move.b   d0,(a2)    { neue StringlÑnge }

          (* PFAD VON TOS-FORMAT -> STRING *)
          movea.l  pfad,a0     { Adr. Pfadstring }
          lea      t_pfd,a1    { Adr. Tos-String }
          bsr      @StrForm      { Stringwandeln }
          bra      @return    { Funktion beenden }

          (* UP TOS VERSIONSNUMMER ABFRAGEN *)
@TOS_Nr:  pea      @Load_Nr   { Adr. der Routine }
          move.w   #Supexec,-(sp) { Funk.SUPEXEC }
          trap     #XBios       { XBIOS aufrufen }
          addq.l   #6,sp     { Stack korrigieren }
          rts                { zurÅck zum Aufruf }
@Load_Nr: movea.l  #sysbase,a0    { Adr. sysbase }
          movea.l (a0),a0    { Adr. Systemheader }
          move.w   2(a0),tos_ver   { Versionsnr. }
          rts                { zurÅck zum Aufruf }

          (* UP AES AUFRUFEN *)
@AESTrap: lea      AES_pb,a0  { Adr.Parameterbl. }
          move.l   a0,d1        { Adr. Åbergeben }
          move.l   #AES,d0       { AES gewÅnscht }
          trap     #AES_VDI       { AES aufrufen }
          rts                { zurÅck zum Aufruf }

          (* UP STRING INS TOS-FORMAT BRINGEN *)
@TosForm: clr.l    d0         { Register lîschen }
          move.b   (a0)+,d0 { StringlÑnge n. d0  }
          cmpi.w   #0,d0     { StringlÑnge = 0 ? }
          beq      @Tos_Ret     { ja, UP beenden }
          subq.w   #1,d0   { um 1 Zeichen kÅrzen }
@looptos: move.b   (a0)+,(a1)+  { String Åbertr. }
          dbra     d0,@looptos { Schleife bis -1 }
          clr.b    (a1)     { Null-Byte anhÑngen }
@Tos_Ret: rts                { zurÅck zum Aufruf }

          (* UP TOS-FORMAT IN STRING WANDELN *)
@StrForm: clr.l    d0         { Register lîschen }
          movea.l  a0,a2       { Adr. des String }
          addq.l   #1,a0    { auf erstes Zeichen }
@loopstr: move.b   (a1)+,(a0)+ { Zeichen Åbertr. }
          addq.w   #1,d0      { ZeichenzÑhler +1 }
          cmpi.b   #0,(a1)        { Stringende ? }
          bne      @loopstr  { nein, dann weiter }
          move.b   d0,(a2)     { LÑnge eintragen }
          rts               

@return:  movea.l  reg_A2,a2    { Reg. a2 zurÅck }
                            { Funktion verlassen }
END;  { FUNCTION F_SELECT }

{------------------------------------------------}
Procedure Screen(modus,x,y,w,h: integer;
                 VAR scr_adr: LongInt);
(* SICHERT DEN ANGEGEBENEN ODER GESAMTEN BEREICH
   DES BILDSCHIRMINHALTS *)  
ASSEMBLER;

ASM
          (* XY-WERTE BILDSCHIRM ERMITTELN *)
          move.l   a2,reg_A2  { Register sichern }
          pea      akt_w    { Var.Adr. auf Stack }
          pea      akt_h
          pea      akt_pl
          jsr      XY_Size  { Procedure aufrufen }
          cmpi.w   #S_ALL,modus { ganzen Screen? }
          beq      @weiter     { ja, dann weiter }
          cmpi.w   #R_ALL,modus { ganzen Screen? }
          bne      @xy_x2y2 { nein, d. umrechnen }
@weiter:  clr.w    x         { Variablen lîschen }
          clr.w    y
          move.w   akt_w,w    { Bildschirmgrîsse }
          move.w   akt_h,h           { Åbergeben }
          subi.w   #1,w    { ein Pixel kÅrzen da }
          subi.w   #1,h   { Koordinaten bei Null }
                                      { beginnen }
          
          (* W,H NACH X2,Y2 WANDELN *)
@xy_x2y2: move.w   x,d0   { x-Koordinate nach d0 }
          add.w    w,d0     { Breite aufaddieren }
          move.w   d0,x2       { Ergebnis ist x2 }
          move.w   y,d0   { y-Koordinate nach d0 }
          add.w    h,d0       { Hîhe aufaddieren }
          move.w   d0,y2       { Ergebnis ist y2 }

          (* SICHERN ODER ZURöCKSCHREIBEN? *)
          cmpi.w   #R_ALL,modus     { Bildschirm }
          beq      @Restore          { ganz oder }
          cmpi.w   #R_XY,modus       { teilweise }
          beq      @Restore   { zurÅckschreiben? }

          (* SPEICHER FöR SICHERUNG ERMITTELN *)
@Mem_Bed: clr.l    d0             { d0 ablîschen }
          move.w   h,d0           { Hîhe nach d0 }
          mulu.w   w,d0          { Breite * Hîhe }
          asr.l    #3,d0  { drei Bit nach rechts }
                             { ergibt Byteanzahl }
          add.w    #2,d0      { Grîsse aufrunden }
          and.b    #$FE,d0      { auf Wortgrenze }
          move.w   akt_pl,d1  { Farbebenen an d1 }
@pl_mul:  cmpi.w   #1,d1      { eine Farbebene ? }
          beq      @mul_end    { ja, dann fertig }
          asl.l    #1,d0     { durch bitschieben }
          asr.w    #1,d1   { mit Anz. Farbebenen }
          bra      @pl_mul      { multiplizieren }
                    
          (* BENôTIGTEN SPEICHER RESERVIEREN *)
@mul_end: clr.l    -(sp)  { Raum fÅr RÅckmeldung }
          move.l   d0,-(sp)     { Speichergrîsse }
          jsr      Res_Mem   { Function aufrufen }
          move.l   scr_adr,a2 { Var.Adr. nach a2 }
          move.l   (sp)+,(a2)   { Adr. eintragen }
          cmp.l    #0,(a2)      { Speicher res.? }
          beq      @return     { nein, abbrechen }

          (* BILDSCHIRMINHALT SICHERN *)
          lea      ptsin,a2    { Adr. ptsin-Feld }
          move.w   x,(a2)      { x-Koord. Quelle }
          move.w   y,2(a2)     { y-Koord. Quelle }
          move.w   x2,4(a2)   { x2-Koord. Quelle }
          move.w   y2,6(a2)   { y2_Koord. Quelle }
          clr.w    8(a2)         { x-Koord. Ziel }
          clr.w    10(a2)        { y-Koord. Ziel }
          move.w   w,12(a2)     { x2-Koord. Ziel }
          move.w   h,14(a2)     { y2_Koord. Ziel }
          pea      Mem_MFDB     { Adr. Ziel-MFDB }
          pea      Scr_MFDB    { Adr. Quell-MFDB }
          bsr      @VroCpyf     { Block kopieren }
          addq.l   #8,sp     { Stack korrigieren }
          bra      @return   { Procedure beenden }

          (* BILDSCHIRMINHALT ZURöCKSCHREIBEN *)
@Restore: lea      ptsin,a2    { Adr. ptsin-Feld }
          clr.w    (a2)        { x-Koord. Quelle }
          clr.w    2(a2)       { y-Koord. Quelle }
          move.w   w,4(a2)    { x2-Koord. Quelle }
          move.w   h,6(a2)    { y2_Koord. Quelle }
          move.w   x,8(a2)       { x-Koord. Ziel }
          move.w   y,10(a2)      { y-Koord. Ziel }
          move.w   x2,12(a2)    { x2-Koord. Ziel }
          move.w   y2,14(a2)    { y2_Koord. Ziel }
          pea      Scr_MFDB     { Adr. Ziel-MFDB }
          pea      Mem_MFDB    { Adr. Quell-MFDB }
          bsr      @VroCpyf     { Block kopieren }
          addq.l   #8,sp     { Stack korrigieren }
          bra      @return   { Procedure beenden }

          (* AKTUELLES HANDLE ERMITTELN *)
@VroCpyf: lea      control,a2 { Adr.control-Feld }
          move.w   #GrfHand,(a2) { Feld besetzen }
          clr.w    2(a2)
          move.w   #5,4(a2)
          clr.w    6(a2)
          clr.w    8(a2)
          lea      AES_pb,a0  { Adr.Parameterbl. }
          move.l   a0,d1        { Adr. Åbergeben }
          move.l   #AES,d0       { AES gewÅnscht }
          trap     #AES_VDI       { AES aufrufen }
          lea      intout,a2   { Adr.intout-Feld }
          move.w   (a2),handle  { handle sichern }

          (* MFDB ZWISCHENSPEICHER AUSFöLLEN *)
          lea      Mem_MFDB,a2   { Adr. von MFDB }
          move.l   scr_adr,a1  { Var.Adr nach a1 }
          move.l   (a1),(a2) { Adr.res. Speicher }
          move.w   w,4(a2)  { Breite des Blockes }
          move.w   h,6(a2)    { Hîhe des Blockes }
          move.w   w,d0    { Pixelbreite nach d0 }
          divu.w   #16,d0    { Wortbreite bilden }
          move.w   d0,8(a2)   { Breite in Worten }
          clr.w    10(a2)    { gerÑteabh. Format }
          move.w   akt_pl,12(a2)   { Anz. Planes }

          (* MFDB BILDSCHIRM AUSFöLLEN *)
          lea      Scr_MFDB,a2   { Adr. von MFDB }
          clr.l    (a2)    { Nullpointer, autom. }
                       { MFDB Bildschirmspeicher }

          (* SPEICHERBEREICH KOPIEREN *)
          lea      control,a2 { Adr.control-Feld }
          move.w   #CopRast,(a2) { Feld besetzen }
          move.w   #4,2(a2)
          clr.w    4(a2)
          move.w   #1,6(a2)
          clr.w    8(a2)
          move.w   handle,12(a2)    { handle-Nr. }
          move.l   4(sp),14(a2) { Adr.Quell-MFDB }
          move.l   8(sp),18(a2)  { Adr.Ziel-MFDB }
          lea      intin,a2    { Adr. intin-Feld }
          move.w   #3,(a2)  { Ziel- = Quellpixel }
          lea      VDI_pb,a0 { Adr. Parameterbl. }
          move.l   a0,d1        { Adr. Åbergeben }
          move.w   #VDI,d0       { VDI gewÅnscht }
          trap     #AES_VDI       { VDI aufrufen }
          rts                { zurÅck zum Aufruf }

@return:  move.l   reg_A2,a2    { Reg. a2 zurÅck }
                           { Procedure verlassen }
END;  { PROCEDURE SCREEN }

{------------------------------------------------}

END.

