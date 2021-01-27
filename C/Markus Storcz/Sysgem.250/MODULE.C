/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <string.h>
#include        <stdio.h>
#include        <stdlib.h>
#include        <stdarg.h>
#include        <tos.h>
#include        <ext.h> 

/* ------------------------------------------------------------------- */

#include        "sys_mod2.h"

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

INT     sgm_lcmd        = 0;
LONG    sgm_lret        = 0L;

/* ------------------------------------------------------------------- */

LOCAL   VOID    SetFunctions    ( VOID );

/* ------------------------------------------------------------------- */

typedef struct
  {
    UINT        ph_branch;
    LONG        ph_tlen;
    LONG        ph_dlen;
    LONG        ph_blen;
    LONG        ph_slen;
    LONG        ph_res1;
    LONG        ph_prgflags;
    UINT        ph_absflag;
    UINT        ph_prg_start;           /* Dummy fr Einsprungaddr.    */
  } MY_PH;

/* ------------------------------------------------------------------- */

typedef struct
  {
    LONG        offset;
    BYTE        info [];
  } RELOC_INFO;

/* ------------------------------------------------------------------- */

LOCAL   FUNCTIONS       fkt;

/* -------------------------------------------------------------------
 * Reloziert den geladenen Programmcode
 * ------------------------------------------------------------------- */

LOCAL BYTE *Relocate ( VOID *buffer )

{
  MY_PH         *image;
  RELOC_INFO    *reloc;
  LONG          *toreloc;
  BYTE          *info;
  LONG          dbase;
  LONG          bbase;
  LONG          tbase;
  BYTE          offset;

  image         = (MY_PH *) buffer;
  tbase         = (LONG)( &image->ph_prg_start );
  dbase         = tbase + image->ph_tlen;
  bbase         = dbase + image->ph_dlen;

  if ( image->ph_absflag != 0 ) return ((BYTE *) tbase );

  reloc         = (RELOC_INFO *) bbase;
  toreloc       = (LONG *)( tbase + reloc->offset );
  info          = reloc->info;
  *toreloc     += tbase;

  forever
    {
      if ( *info == 0 ) break;
      offset = *info++;
      if ( offset == 1 )
        {
          toreloc = (LONG *)((LONG)( toreloc ) + 254L );
        }
      else
        {
          toreloc = (LONG *)((LONG)( toreloc ) + (LONG)( offset ));
          *toreloc += tbase;
        }
    }
	
	ClearCache();			/* [GS] */
	
  return ((BYTE *) tbase );
}

/* ------------------------------------------------------------------- */

LOCAL LONG TestModule ( BYTE *name )

{
  MY_PH            ph;
  LONG          res;
  LONG          len;
  BYTE          s [200];

	if(strstr(name,".sgm")==NULL && strstr(name,".SGM")==NULL)  /* [GS] */
	  sprintf ( s, "%s%s.sgm", sysgem.module_path, name );   		/* [GS]  */
	else																												/* [GS] 	*/
	  sprintf ( s, "%s%s", sysgem.module_path, name );					/* [GS] */
  res = Fopen ( s, FO_READ );
  if ( res >= 0L )
    {
      len = Fread ((INT)( res ), sizeof ( ph ) - 2L, &ph );
      if ( len == sizeof ( ph ) - 2L )
        {
          Fclose ((INT)( res ));
          if ( ph.ph_branch == 0x601a )
            {
              len = sizeof ( ph ) + ph.ph_tlen + ph.ph_dlen + ph.ph_blen + ph.ph_slen;
              if ( ph.ph_tlen <= 0L )
                {
                  return ( 0L );
                }
              return ( len );
            }
          return ( 0L );
        }
      Fclose ((INT)( res ));
    }
  return ( 0L );
}

/* ------------------------------------------------------------------- */

LOCAL BYTE *LoadModule ( BYTE *name, LONG *buf_len )

{
  struct stat   fs;
  LONG          res;
  LONG          mlen;
  LONG          len;
  BYTE          *buf;
  BYTE          s [200];

  *buf_len = 0L;
  mlen  = TestModule ( name );
  if ( mlen <= 0L ) return ( NULL );

	if(strstr(name,".sgm")==NULL && strstr(name,".SGM")==NULL)  /* [GS] */
	  sprintf ( s, "%s%s.sgm", sysgem.module_path, name );			/* [GS] */
	else																												/* [GS] 	*/
	  sprintf ( s, "%s%s", sysgem.module_path, name );					/* [GS] */
	
  if ( stat ( s, &fs ) == 0 )
    {
      if ( fs.st_size <= sizeof ( MY_PH )) return ( NULL );
      if ( mlen       <= fs.st_size   ) return ( NULL );
      buf = (BYTE *) Allocate ( mlen );
      if ( buf != NULL )
        {
          res = Fopen ( s, FO_READ );
          if ( res >= 0L )
            {
              len = Fread ((INT)( res ), fs.st_size, buf );
              if ( len == fs.st_size )
                {
                  Fclose ((INT)( res ));
                  *buf_len = mlen;
                  return ( buf );
                }
              Fclose ((INT)( res ));
              Dispose ( buf );
            }
          else
            {
              Dispose ( buf );
            }
        }
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

LOCAL MODULE *IsLoaded ( BYTE *name )

{
  MODULE        *mod;

  if ( name == NULL ) return ( NULL );
  mod = sysgem.module;
  while ( mod != NULL )
    {
      if ( stricmp ( name, mod->name ) == 0 )
        {
          return ( mod );
        }
      mod = mod->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

BYTE *GetModuleName ( BYTE *real_name )

{
  MODULE        *mod;

  if ( real_name == NULL ) return ( NULL );
  mod = sysgem.module;
  while ( mod != NULL )
    {
      if ( stricmp ( real_name, mod->mod_name ) == 0 )
        {
          return ( mod->name );
        }
      mod = mod->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

VOID SetModuleDebugProc ( YPROC proc )

{
  sysgem.spy_module = proc;
}

/* ------------------------------------------------------------------- */

LOCAL LONG SendToModule ( BYTE *name, INT cmd, INT user, VOID *p )

{
  IDENTIFY      ident;
  MODULE        *mod;
  LONG          i;
  LONG          own;

  i = 0L;
  mod = IsLoaded ( name );
  if ( mod == NULL ) return ( i );

  if ( sysgem.spy_module != NULL )
    {
      sysgem.spy_module ( SGM_ENTER, mod, cmd, user, p, i );
    }

  own = (LONG)( &mod->name [0] );
  SetOwner ( own );

  switch ( cmd )
    {
      case SGM_IDENTIFY : ident.name   = NULL;
                          ident.author = NULL;
                          mod->start ( cmd, 0, &ident );
                          mod->mod_autor   = ident.author;
                          mod->mod_name    = ident.name;
                          break;
      case SGM_INIT     : SetOwner ( own );
                          i = mod->start ( cmd, 0, &fkt );
                          SetOwner ( own );
                          break;
      case SGM_START    : SetOwner ( own );
                          i = mod->start ( cmd, 0, p );
                          SetOwner ( own );
                          break;
      case SGM_QUIT     : SetOwner ( own );
                          mod->start ( cmd, 0, NULL );
                          Dispose   ( mod->buffer );
                          DeletePtr ( &sysgem.module, mod );
                          SetOwner ( own );
                          break;
      case SGM_USER     : SetOwner ( own );
                          i = mod->start ( cmd, user, p );
      default           : SetOwner ( own );
                          break;
    }
  if ( sysgem.spy_module != NULL )
    {
      sysgem.spy_module ( SGM_LEAVE, mod, cmd, user, p, i );
    }

  SetOwner ( sysgem.prg_id );

  sgm_lcmd = cmd;
  sgm_lret = i;
  return ( i );
}

/* ------------------------------------------------------------------- */

LONG AskModule ( BYTE *name, INT cmd, VOID *ptr )

{
  return ( SendToModule ( name, SGM_USER, cmd, ptr ));
}

/* ------------------------------------------------------------------- */

BOOL ModulAvail ( BYTE *name )

{
  return ( IsLoaded ( name ) != NULL );
}

/* ------------------------------------------------------------------- */

LONG StartSysGemModul ( BYTE *name, VOID *p )

{
  return ( SendToModule ( name, SGM_START, 0, p ));
}

/* ------------------------------------------------------------------- */

BOOL LoadSysGemModul ( BYTE *name )

{
  MODULE        *mod;

  if ( ! sysgem.mod_init )
    {
      SetFunctions ();
      sysgem.mod_init = TRUE;
    }

  if ( IsLoaded ( name ) == NULL )
    {
      sysgem.term_module = TermSysGemModul;

      mod = (MODULE *) Allocate ( sizeof ( MODULE ));
      if ( mod != NULL )
        {
          strncpy ( mod->name, name, 18L );
          mod->buffer = LoadModule ( name, &mod->buf_len );
          if ( mod->buffer != NULL )
            {
              mod->start = (SGM_PROC) Relocate ( mod->buffer );
              if ( mod->start == NULL )
                {
                  Dispose ( mod->buffer );
                  Dispose ( mod );
                  return  ( FALSE );
                }
              InsertPtr ( &sysgem.module, mod );
              SendToModule ( name, SGM_IDENTIFY, 0, NULL );
              if (( mod->mod_autor == NULL ) || ( mod->mod_name == NULL ))
                {
                  DeletePtr ( &sysgem.module, mod );
                  Dispose ( mod->buffer );
                  Dispose ( mod );
                  return ( FALSE );
                }
              SendToModule ( name, SGM_INIT, 0, NULL );
              return ( TRUE );
            }
          else
            {
              Dispose ( mod );
            }
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL GetModuleInfo ( INT nr, BYTE *name, BYTE *mod_name, BYTE *mod_author )

{
  INT           i;
  MODULE        *mod;

  if ( nr < 0 )
    {
      mod = IsLoaded ( name );
      if ( mod != NULL )
        {
          if ( mod_name   != NULL ) sprintf ( mod_name,   "%-40.40s", mod->mod_name   );
          if ( mod_author != NULL ) sprintf ( mod_author, "%-40.40s", mod->mod_autor );
          return ( TRUE );
        }
    }
  else
    {
      i = 0;
      mod = sysgem.module;
      while ( mod != NULL )
        {
          if ( i == nr )
            {
              if ( mod_name   != NULL ) sprintf ( mod_name,   "%-40.40s", mod->mod_name   );
              if ( mod_author != NULL ) sprintf ( mod_author, "%-40.40s", mod->mod_autor );
              if ( name       != NULL ) sprintf ( name,       "%s",       mod->name );
              return ( TRUE );
            }
          mod = mod->next;
          i++;
        }
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

VOID SetModulePath ( BYTE *path )

{
  strncpy ( sysgem.module_path, path, 126L );
}

/* ------------------------------------------------------------------- */

VOID TermSysGemModul ( BYTE *name )

{
  SendToModule ( name, SGM_QUIT, 0, NULL );
}

/* ------------------------------------------------------------------- */

LOCAL VOID SetFunctions ( VOID )

{
  fkt.Allocate               = Allocate;
  fkt.Dispose                = Dispose;
  fkt.AddSliderItem          = AddSliderItem;
  fkt.AddToList              = AddToList;
  fkt.Alert                  = Alert;
  fkt.AskModule              = AskModule;
  fkt.BeginDialog            = BeginDialog;
  fkt.BeginListUpdate        = BeginListUpdate;
  fkt.CalcArea               = CalcArea;
  fkt.CalcWinTrees           = CalcWinTrees;
  fkt.CallOnlineHelp         = CallOnlineHelp;
  fkt.CenterX                = CenterX;
  fkt.CenterY                = CenterY;
  fkt.ChangeButton           = ChangeButton;
  fkt.CheckWindow            = CheckWindow;
  fkt.ChgInList              = ChgInList;
  fkt.ClearArea              = ClearArea;
  fkt.ClearEditFields        = ClearEditFields;
  fkt.ClipboardChanged       = ClipboardChanged;
  fkt.CloseAllWindows        = CloseAllWindows;
  fkt.CloseWindow            = CloseWindow;
  fkt.CloseWindowById        = CloseWindowById;
  fkt.CopyArea               = CopyArea;
  fkt.CountKeywords          = CountKeywords;
  fkt.CountLines             = CountLines;
  fkt.CountWindows           = CountWindows;
  fkt.Cycle                  = Cycle;
  fkt.CycleBack              = CycleBack;
  fkt.CycleWindow            = CycleWindow;
  fkt.DeSelSldItem           = DeSelSldItem;
  fkt.DelCompleteList        = DelCompleteList;
  fkt.DelConfig              = DelConfig;
  fkt.DelDialog              = DelDialog;
  fkt.DelInList              = DelInList;
  fkt.DelXTimer              = DelXTimer;
  fkt.DialPosXY              = DialPosXY;
  fkt.Disable3D              = Disable3D;
  fkt.DisableObj             = DisableObj;
  fkt.DisableTimer           = DisableTimer;
  fkt.DispatchEvents         = DispatchEvents;
  fkt.Display                = Display;
  fkt.DoDialog               = DoDialog;
  fkt.DrawSlider             = DrawSlider;
  fkt.Enable3D               = Enable3D;
  fkt.EnableObj              = EnableObj;
  fkt.EnableTimer            = EnableTimer;
  fkt.EndAbacus              = EndAbacus;
  fkt.EndClock               = EndClock;
  fkt.EndCoffee              = EndCoffee;
  fkt.EndDice                = EndDice;
  fkt.EndDisc                = EndDisc;
  fkt.EndListUpdate          = EndListUpdate;
  fkt.EndMessage             = EndMessage;
  fkt.EndPaper               = EndPaper;
  fkt.EndRotor               = EndRotor;
  fkt.FastDrawSldBox         = FastDrawSldBox;
  fkt.FileSelect             = FileSelect;
  fkt.FinishDialog           = FinishDialog;
  fkt.FontExists             = FontExists;
  fkt.FontSelect             = FontSelect;
  fkt.FrameTextColor         = FrameTextColor;
  fkt.FreeArea               = FreeArea;
  fkt.GetConfig              = GetConfig;
  fkt.GetConfigPtr           = GetConfigPtr;
  fkt.GetCookie              = GetCookie;
  fkt.GetFontId              = GetFontId;
  fkt.GetFontName            = GetFontName;
  fkt.GetHandle              = GetHandle;
  fkt.GetInt								 = GetInt;												/* [GS] */
  fkt.GetLineHeight          = GetLineHeight;
  fkt.GetLinePtr             = GetLinePtr;
  fkt.GetListUserPtr         = GetListUserPtr;
  fkt.GetLong								 = GetLong;												/* [GS] */
  fkt.GetParStruct           = GetParStruct;
  fkt.GetParam               = GetParam;
  fkt.GetSliderItems         = GetSliderItems;
  fkt.GetText                = GetText;
  fkt.GetTopWindow           = GetTopWindow;
  fkt.GetTopWindowId         = GetTopWindowId;
  fkt.GetWinUser             = GetWinUser;
  fkt.GetWindowId            = GetWindowId;
  fkt.GetXTimerId            = GetXTimerId;
  fkt.GetXTimerUser1         = GetXTimerUser1;
  fkt.GetXTimerUser2         = GetXTimerUser2;
  fkt.HandleDialog           = HandleDialog;
  fkt.HandleSysGem           = HandleSysGem;
  fkt.HideCursor             = HideCursor;
  fkt.HideObj                = HideObj;
  fkt.InitResource           = InitResource;
  fkt.InitXWindow            = InitXWindow;
  fkt.InsInList              = InsInList;
  fkt.LinkHorSlider          = LinkHorSlider;
  fkt.LinkImage              = LinkImage;
  fkt.LinkList               = LinkList;
  fkt.LinkMainImage          = LinkMainImage;
  fkt.LinkOwnRedraw          = LinkOwnRedraw;
  fkt.LinkSlider             = LinkSlider;
  fkt.LinkTree               = LinkTree;
  fkt.UnLinkTree             = UnLinkTree;
  fkt.Listbox                = Listbox;
  fkt.LoadConfig             = LoadConfig;
  fkt.LoadResource           = LoadResource;
  fkt.LoadSysGemModul        = LoadSysGemModul;
  fkt.ModulAvail             = ModulAvail;
  fkt.MoveScreen             = MoveScreen;
  fkt.MultipleDialog         = MultipleDialog;
  fkt.NewArea                = NewArea;
  fkt.NewDialog              = NewDialog;
  fkt.NormalFont             = NormalFont;
  fkt.OpenLogWindow          = OpenLogWindow;
  fkt.xOpenLogWindow         = xOpenLogWindow;
  fkt.OpenTextWindow         = OpenTextWindow;
  fkt.OpenWindow             = OpenWindow;
  fkt.PopUp                  = PopUp;
  fkt.ReSizeWindow           = ReSizeWindow;
  fkt.RectIntersect          = RectIntersect;
  fkt.RectVisible            = RectVisible;
  fkt.RedrawArea             = RedrawArea;
  fkt.RedrawLine             = RedrawLine;
  fkt.RedrawObj              = RedrawObj;
  fkt.RedrawSliderBox        = RedrawSliderBox;
  fkt.RedrawTheSlider        = RedrawTheSlider;
  fkt.RedrawWindow           = RedrawWindow;
  fkt.RemoveOwnRedraw        = RemoveOwnRedraw;
  fkt.ResetSysFont           = ResetSysFont;
  fkt.RestoreArea            = RestoreArea;
  fkt.RscAdr                 = RscAdr;
  fkt.RscFree                = RscFree;
  fkt.SaveArea               = SaveArea;
  fkt.SaveConfig             = SaveConfig;
  fkt.ScrollSlider           = ScrollSlider;
  fkt.ScrollWindow           = ScrollWindow;
  fkt.SearchProgram          = SearchProgram;
  fkt.SelectPrinter          = SelectPrinter;
  fkt.SelectSldItem          = SelectSldItem;
  fkt.SendFontChanged        = SendFontChanged;
  fkt.Set3DAlertColor        = Set3DAlertColor;
  fkt.SetAccProc             = SetAccProc;
  fkt.SetAlertColor          = SetAlertColor;
  fkt.SetAlertTitle          = SetAlertTitle;
  fkt.SetButton              = SetButton;
  fkt.SetClipping            = SetClipping;
  fkt.SetConfig              = SetConfig;
  fkt.SetDispatchTime        = SetDispatchTime;
  fkt.SetEditField           = SetEditField;
  fkt.SetFont                = SetFont;
  fkt.SetFulledH             = SetFulledH;
  fkt.SetFulledW             = SetFulledW;
  fkt.SetFulledX             = SetFulledX;
  fkt.SetFulledY             = SetFulledY;
  fkt.SetIconRedraw          = SetIconRedraw;
  fkt.SetIconifyName         = SetIconifyName;
	fkt.SetInt								 = SetInt;												/* [GS] */
  fkt.SetLanguage            = SetLanguage;
  fkt.SetLineColor           = SetLineColor;
  fkt.SetLineEffect          = SetLineEffect;
  fkt.SetLineFlags           = SetLineFlags;
  fkt.SetLineIcon            = SetLineIcon;
  fkt.SetLineUser            = SetLineUser;
  fkt.SetLinkIconColor       = SetLinkIconColor;
  fkt.SetLinkTextColor       = SetLinkTextColor;
  fkt.SetListTab             = SetListTab;
  fkt.SetListUserPtr         = SetListUserPtr;
	fkt.SetLong								 = SetLong;												/* [GS] */
  fkt.SetMonoEditFrame       = SetMonoEditFrame;
  fkt.SetOnlineHelp          = SetOnlineHelp;
  fkt.SetProcEvent           = SetProcEvent;
  fkt.SetProcTimer           = SetProcTimer;
  fkt.SetProgramName         = SetProgramName;
  fkt.SetReturn              = SetReturn;
  fkt.SetSelColor            = SetSelColor;
  fkt.SetSelTextColor        = SetSelTextColor;
  fkt.SetSliderFont          = SetSliderFont;
  fkt.SetSliderPos           = SetSliderPos;
  fkt.SetSliderTab           = SetSliderTab;
  fkt.SetSysFont             = SetSysFont;
  fkt.SetText                = SetText;
  fkt.xSetText               = xSetText;
  fkt.SetTextColor           = SetTextColor;
  fkt.SetTimer               = SetTimer;
	fkt.SetULong							 = SetULong;											/* [GS] */
  fkt.SetUnknownEvent        = SetUnknownEvent;
  fkt.SetWinBackground       = SetWinBackground;
  fkt.SetWinMaxSize          = SetWinMaxSize;
  fkt.SetWinMinSize          = SetWinMinSize;
  fkt.SetWinUser             = SetWinUser;
  fkt.SetWindowFont          = SetWindowFont;
  fkt.SetWindowInfo          = SetWindowInfo;
  fkt.SetWindowName          = SetWindowName;
  fkt.SetWindowParm          = SetWindowParm;
  fkt.SetWindowTimer         = SetWindowTimer;
  fkt.SetXTimer              = SetXTimer;
  fkt.ShortCutColor          = ShortCutColor;
  fkt.ShowAbacus             = ShowAbacus;
  fkt.ShowClock              = ShowClock;
  fkt.ShowCoffee             = ShowCoffee;
  fkt.ShowCursor             = ShowCursor;
  fkt.ShowDice               = ShowDice;
  fkt.ShowDisc               = ShowDisc;
  fkt.ShowMessage            = ShowMessage;
  fkt.ShowStatus             = ShowStatus;
  fkt.EndStatus              = EndStatus;
  fkt.ShowObj                = ShowObj;
  fkt.ShowPaper              = ShowPaper;
  fkt.ShowRotor              = ShowRotor;
  fkt.SmallFont              = SmallFont;
  fkt.StartSysGemModul       = StartSysGemModul;
  fkt.StringHeight           = StringHeight;
  fkt.StringWidth            = StringWidth;
  fkt.SysGem3D               = SysGem3D;
  fkt.SysGemVerStr           = SysGemVerStr;
  fkt.SysGemVersion          = SysGemVersion;
  fkt.TakeEvent              = TakeEvent;
  fkt.TellKeyStrokes         = TellKeyStrokes;
  fkt.TerminateSysGem        = TerminateSysGem;
  fkt.TopWindow              = TopWindow;
  fkt.UnLinkSlider           = UnLinkSlider;
  fkt.UpdateAbacus           = UpdateAbacus;
  fkt.UpdateClock            = UpdateClock;
  fkt.UpdateCoffee           = UpdateCoffee;
  fkt.UpdateDice             = UpdateDice;
  fkt.UpdateDisc             = UpdateDisc;
  fkt.UpdatePaper            = UpdatePaper;
  fkt.UpdateRotor            = UpdateRotor;
  fkt.UseFastTimer           = UseFastTimer;
  fkt.UseOwnEditFields       = UseOwnEditFields;
  fkt.UseRoundButtons        = UseRoundButtons;
  fkt.VectorFont             = VectorFont;
  fkt.WaitAfterClose         = WaitAfterClose;
  fkt.WhiteArea              = WhiteArea;
  fkt.WindowDialog           = WindowDialog;
  fkt.xWindowDialog          = xWindowDialog;
  fkt.WindowVisible          = WindowVisible;
  fkt.XWindow                = XWindow;
  fkt.cmp_strings_dn         = cmp_strings_dn;
  fkt.cmp_strings_up         = cmp_strings_up;
  fkt.crc_16                 = crc_16;
  fkt.crc_32                 = crc_32;
  fkt.do_qsort               = do_qsort;
  fkt.memcmp                 = memcmp;
  fkt.memcpy                 = memcpy;
  fkt.memset                 = memset;
  fkt.sprintf                = sprintf;
  fkt.strcat                 = strcat;
  fkt.strchr                 = strchr;
  fkt.strcmp                 = strcmp;
  fkt.strcpy                 = strcpy;
  fkt.stricmp                = stricmp;
  fkt.strlen                 = strlen;
  fkt.strncat                = strncat;
  fkt.strncmp                = strncmp;
  fkt.strncpy                = strncpy;
  fkt.strnicmp               = strnicmp;
  fkt.strrchr                = strrchr;
  fkt.v_stext                = v_stext;
  fkt.v_xtext                = v_xtext;
  fkt.wcls                   = wcls;
  fkt.wgetchar               = wgetchar;
  fkt.wgetxy                 = wgetxy;
  fkt.wposxy                 = wposxy;
  fkt.wprintf                = wprintf;
  fkt.xAddToList             = xAddToList;
  fkt.xChgInList             = xChgInList;
  fkt.xInsInList             = xInsInList;
  fkt.xLinkList              = xLinkList;
  fkt.xLinkSlider            = xLinkSlider;
  fkt.xListbox               = xListbox;
  fkt.xPopUp                 = xPopUp;
  fkt.xSetLineIcon           = xSetLineIcon;
  fkt.BeginHelp              = BeginHelp;
  fkt.EndHelp                = EndHelp;
  fkt.EnableHelp             = EnableHelp;
  fkt.DisableHelp            = DisableHelp;
  fkt.SetHelpTime            = SetHelpTime;
  fkt.SetHelpColor           = SetHelpColor;
  fkt.CheckLogFont           = CheckLogFont;
  fkt.GetTabPosition         = GetTabPosition;
  fkt.GetWindowFont          = GetWindowFont;
  fkt.DebugTheModule         = DebugTheModule;
  fkt.DebugTheConfig         = DebugTheConfig;
  fkt.winsert                = winsert;
  fkt.graf_mouse		         = graf_mouse;
  fkt.Supexec                = Supexec;
  fkt.qsort                  = qsort;
  fkt.Fsfirst                = Fsfirst;
  fkt.Fsnext                 = Fsnext;
  fkt.Fgetdta                = Fgetdta;
  fkt.Mxalloc                = Mxalloc;
  fkt.rsrc_obfix             = rsrc_obfix;
  fkt.sscanf                 = sscanf;
  fkt.get_cpu                = get_cpu;
  fkt.get_longframe          = get_longframe;
  fkt.get_mch                = get_mch;
  fkt.SetOwner               = SetOwner;
  fkt.GetOwner               = GetOwner;
  fkt.GetModuleName          = GetModuleName;
  fkt.fopen                  = fopen;
  fkt.fclose                 = fclose;
  fkt.fprintf                = fprintf;
  fkt.fgets                  = fgets;
  fkt.fseek									 = fseek;									/* [GS] */
  fkt.fread									 = fread;									/* [GS] */
  fkt.fwrite								 = fwrite;								/* [GS] */
  fkt.SendSliderPos          = SendSliderPos;
  fkt.ChangeDialog           = ChangeDialog;					/* [GS] */
}

/* ------------------------------------------------------------------- */
