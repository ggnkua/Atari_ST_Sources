/* ------------------------------------------------------------------- *
 * Module Version       : 2.03                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#ifndef __sysgem_module__
#define __sysgem_module__

/* ------------------------------------------------------------------- */

#ifndef __kernel__

/* ------------------------------------------------------------------- */

#ifdef __sysgem__
#error "SysGem.h darf noch nicht eingebunden werden!!!"
#endif

/* ------------------------------------------------------------------- */

#endif /* __kernel__ */

/* ------------------------------------------------------------------- */

#include <sys_gem2.h>
#ifndef __TOS
#include <tos.h>
#endif

/* ------------------------------------------------------------------- */

typedef struct
  {
    VOID   *( *Allocate        )( LONG size );
    VOID    ( *Dispose         )( VOID *ptr );
    BOOL    ( *AddSliderItem   )( OBJECT *tree, INT box, INT anz_items );
    BYTE   *( *AddToList       )( LONG win_id, BYTE *text );
    INT     ( *Alert           )( INT priority, INT def, BYTE *str );
    LONG    ( *AskModule       )( BYTE *name, INT cmd, VOID *ptr );
    BOOL    ( *BeginDialog     )( LONG win_id, OBJECT *tree, INT edit, BYTE *title );
    VOID    ( *BeginListUpdate )( LONG win_id );
    VOID    ( *CalcArea        )( OBJECT *tree, INT obj, RECT *r );
    BOOL    ( *CallOnlineHelp  )( BYTE *help );
    VOID    ( *CalcWinTrees    )( LONG win_id );
    INT     ( *CenterX         )( INT x1, INT x2, BYTE *text );
    INT     ( *CenterY         )( INT y1, INT y2 );
    VOID    ( *ChangeButton    )( OBJECT *tree, INT obj, BYTE *text );
    VOID    ( *CheckWindow     )( LONG win_id );
    BYTE   *( *ChgInList       )( LONG win_id, UINT line, BYTE *text );
    VOID    ( *ClearArea       )( AREA *p );
    VOID    ( *ClearEditFields )( OBJECT *tree );
    VOID    ( *ClipboardChanged)( VOID );
    VOID    ( *CloseAllWindows )( VOID );
    BOOL    ( *CloseWindow     )( INT handle );
    BOOL    ( *CloseWindowById )( LONG id );
    VOID    ( *CopyArea        )( INT vdi_handle, AREA *p, INT x, INT y );
    UINT    ( *CountKeywords   )( VOID );
    UINT    ( *CountLines      )( LONG win_id );
    INT     ( *CountWindows    )( VOID );
    INT     ( *Cycle           )( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret );
    INT     ( *CycleBack       )( OBJECT *tree, INT obj, OBJECT *pop_tree, INT first, INT last, INT *ret );
    VOID    ( *CycleWindow     )( BOOL show_window );
    BOOL    ( *DeSelSldItem    )( OBJECT *tree, INT box, BOOL draw );
    VOID    ( *DelCompleteList )( LONG win_id );
    BOOL    ( *DelConfig       )( BYTE *keyword );
    BOOL    ( *DelDialog       )( OBJECT *tree );
    BOOL    ( *DelInList       )( LONG win_id, UINT line );
    VOID    ( *DelXTimer       )( LONG id );
    VOID    ( *DialPosXY       )( BOOL center );
    VOID    ( *Disable3D       )( VOID );
    VOID    ( *DisableObj      )( OBJECT *tree, INT obj, BOOL draw );
    VOID    ( *DisableTimer    )( VOID );
    VOID    ( *DispatchEvents  )( VOID );
    LONG    ( *Display         )( BYTE *fname, BYTE *wname, BYTE *winfo, INT len, LONG win_id, INT x, INT y, INT w, INT h, APROC action );
    INT     ( *DoDialog        )( OBJECT *tree, INT edit, BYTE *title );
    INT     ( *DrawSlider      )( OBJECT *tree, INT hide, LONG p1, LONG p2, BOOL draw );
    VOID    ( *Enable3D        )( VOID );
    VOID    ( *EnableObj       )( OBJECT *tree, INT obj, BOOL draw );
    VOID    ( *EnableTimer     )( VOID );
    VOID    ( *EndAbacus       )( VOID );
    VOID    ( *EndClock        )( VOID );
    VOID    ( *EndCoffee       )( VOID );
    VOID    ( *EndDice         )( VOID );
    VOID    ( *EndDisc         )( VOID );
    VOID    ( *EndListUpdate   )( LONG win_id );
    VOID    ( *EndMessage      )( VOID );
    VOID    ( *EndStatus       )( VOID );
    VOID    ( *EndPaper        )( VOID );
    VOID    ( *EndRotor        )( VOID );
    VOID    ( *FastDrawSldBox  )( OBJECT *tree, INT box );
    INT     ( *FileSelect      )( BYTE *name, BYTE *path, BYTE *suffix, BYTE *title, BYTE *file_name );
    VOID    ( *FinishDialog    )( LONG win_id );
    BOOL    ( *FontExists      )( INT font_id );
    BOOL    ( *FontSelect      )( INT buttons, INT *id, INT *pt, BYTE *title, BYTE *example, BOOL internal, TPROC help_proc );
    VOID    ( *FrameTextColor  )( INT color );
    VOID    ( *FreeArea        )( AREA *p );
    BOOL    ( *GetConfig       )( BYTE *keyword, VOID *value );
    BOOL    ( *GetConfigPtr    )( BYTE *keyword, VOID *value, LONG *len );
    BOOL    ( *GetCookie       )( LONG id, VOID *value );
    INT     ( *GetFontId       )( BYTE *font_name );
    BYTE   *( *GetFontName     )( INT font_id );
    INT     ( *GetHandle       )( LONG win_id );
    INT     ( *GetLineHeight   )( LONG win_id );
    BYTE   *( *GetLinePtr      )( LONG win_id, UINT line );
    VOID   *( *GetListUserPtr  )( LONG win_id, UINT line );
    VOID    ( *GetParStruct    )( PARAMETER *par );
    INT     ( *GetParam        )( INT par );
    INT     ( *GetSliderItems  )( OBJECT *tree, INT box );
    INT     ( *GetTabPosition  )( LONG win_id, INT tab, BOOL pixel );
    BYTE   *( *GetText         )( OBJECT *tree, INT index, BYTE *text );
    INT     ( *GetTopWindow    )( VOID );
    LONG    ( *GetTopWindowId  )( VOID );
    VOID   *( *GetWinUser      )( LONG win_id );
    LONG    ( *GetWindowId     )( INT handle );
    LONG    ( *GetXTimerId     )( VOID );
    VOID   *( *GetXTimerUser1  )( VOID );
    VOID   *( *GetXTimerUser2  )( VOID );
    INT     ( *HandleDialog    )( LONG win_id );
    VOID    ( *HandleSysGem    )( VOID );
    VOID    ( *HideCursor      )( LONG win_id );
    VOID    ( *HideObj         )( OBJECT *tree, INT obj, BOOL draw );
    BOOL    ( *InitResource    )( OBJECT *rsc_tree, UINT num_obs, UINT num_trees, VOID *rgb_table, BOOL long_rsc );
    VOID    ( *InitXWindow     )( XWIN *xwin );
    BYTE   *( *InsInList       )( LONG win_id, UINT line, BYTE *text );
    BOOL    ( *LinkHorSlider   )( OBJECT *tree, INT box, INT left, INT right, INT show, INT hide );
    VOID    ( *LinkImage       )( LONG win_id, BITBLK *image, BYTE *text );
    BYTE   *( *LinkList        )( LONG win_id, BYTE *text );
    VOID    ( *LinkMainImage   )( BITBLK *image, BYTE *text );
    BOOL    ( *LinkOwnRedraw   )( OBJECT *tree, INT obj );
    BOOL    ( *LinkSlider      )( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buf, INT len, BOOL icons );
    BOOL    ( *LinkTree        )( LONG win_id, OBJECT *tree, LONG id, INT pos );
    BOOL    ( *UnLinkTree      )( LONG win_id, OBJECT *tree );
    INT     ( *Listbox         )( BYTE *strings, INT count, INT len, OBJECT *tree, INT box );
    LONG    ( *LoadConfig      )( BYTE *file_name );
    INT     ( *LoadResource    )( BYTE *rsc_name, BOOL long_rsc );
    BOOL    ( *LoadSysGemModul )( BYTE *name );
    BOOL    ( *ModulAvail      )( BYTE *name );
    VOID    ( *MoveScreen      )( INT vdi_handle, RECT *r, INT x, INT y );
    BOOL    ( *MultipleDialog  )( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, OBJECT *top, INT active, OBJECT *tree, INT edit, VOID *user, DPROC proc );
    BOOL    ( *NewArea         )( AREA *p );
    BOOL    ( *NewDialog       )( OBJECT *tree );
    VOID    ( *NormalFont      )( VOID );
    BOOL    ( *OpenLogWindow   )( LONG win_id, BYTE *title, BYTE *info, INT columns, INT rows, INT x, INT y, APROC action );
    INT     ( *OpenTextWindow  )( LONG id, BYTE *name, BYTE *info, OBJECT *menu, INT x, INT y, INT w, INT h, VOID *user, APROC action );
    INT     ( *OpenWindow      )( LONG id, BYTE *name, BYTE *info, INT flags, OBJECT *menu, INT align, BOOL part, INT scr_x, INT scr_y, LONG doc_x, LONG doc_y, INT x, INT y, INT w, INT h, VOID *user, RPROC redraw, APROC action );
    INT     ( *PopUp           )( OBJECT *tree, INT x, INT y, INT start, INT first );
    VOID    ( *ReSizeWindow    )( LONG win_id, RECT *size );
    VOID    ( *RectIntersect   )( RECT *r1, RECT *r2 );
    BOOL    ( *RectVisible     )( RECT *r );
    VOID    ( *RedrawArea      )( INT handle, RECT *area );
    VOID    ( *RedrawLine      )( LONG win_id, UINT line );
    VOID    ( *RedrawObj       )( OBJECT *tree, INT obj, INT depth, INT state, INT flag );
    VOID    ( *RedrawSliderBox )( OBJECT *tree, INT box );
    VOID    ( *RedrawTheSlider )( OBJECT *tree, INT box, BOOL draw );
    VOID    ( *RedrawWindow    )( INT handle );
    BOOL    ( *RemoveOwnRedraw )( OBJECT *tree, INT obj );
    VOID    ( *ResetSysFont    )( VOID );
    VOID    ( *RestoreArea     )( INT vdi_handle, AREA *p );
    OBJECT *( *RscAdr          )( INT tree_type, INT index );
    VOID    ( *RscFree         )( VOID );
    BOOL    ( *SaveArea        )( INT vdi_handle, AREA *p, RECT *r );
    LONG    ( *SaveConfig      )( BYTE *file_name );
    VOID    ( *ScrollSlider    )( OBJECT *tree, INT box, INT what );
    VOID    ( *ScrollWindow    )( INT handle, INT what );
    INT     ( *SearchProgram   )( BYTE *prg_name );
    INT     ( *SelectPrinter   )( VOID );
    BOOL    ( *SelectSldItem   )( OBJECT *tree, INT box, INT line, BOOL draw );
    VOID    ( *SendFontChanged )( INT font_id, INT font_pt );
    VOID    ( *Set3DAlertColor )( INT icn1, INT icn2, INT icn3 );
    VOID    ( *SetAccProc      )( TPROC acc_open, TPROC acc_close );
    VOID    ( *SetAlertColor   )( INT icn1, INT icn2, INT icn3 );
    VOID    ( *SetAlertTitle   )( BYTE *name );
    VOID    ( *SetButton       )( INT just );
    VOID    ( *SetClipping     )( RECT *r );
    BOOL    ( *SetConfig       )( BYTE *keyword, VOID *value, LONG len );
    VOID    ( *SetDispatchTime )( INT ms_low, INT ms_high );
    BOOL    ( *SetEditField    )( OBJECT *tree, INT field );
    VOID    ( *SetFont         )( INT font_id, INT pt );
    VOID    ( *SetFulledH      )( INT h );
    VOID    ( *SetFulledW      )( INT w );
    VOID    ( *SetFulledX      )( INT x );
    VOID    ( *SetFulledY      )( INT y );
    VOID    ( *SetIconRedraw   )( LONG win_id, IPROC proc );
    VOID    ( *SetIconifyName  )( BYTE *name );
    VOID    ( *SetLanguage     )( BOOL english );
    INT     ( *SetLineColor    )( LONG win_id, UINT line, INT color );
    INT     ( *SetLineEffect   )( LONG win_id, UINT line, INT effect );
    INT     ( *SetLineFlags    )( LONG win_id, UINT line, INT flags );
    BOOL    ( *SetLineIcon     )( LONG win_id, UINT line, OBJECT *tree, INT obj );
    INT     ( *SetLineUser     )( LONG win_id, UINT line, INT user );
    VOID    ( *SetLinkIconColor)( LONG win_id, INT color );
    VOID    ( *SetLinkTextColor)( LONG win_id, INT color );
    BOOL    ( *SetListTab      )( LONG win_id, INT pos, INT just );
    BOOL    ( *SetListUserPtr  )( LONG win_id, UINT line, VOID *user );
    VOID    ( *SetMonoEditFrame)( BOOL paint );
    VOID    ( *SetOnlineHelp   )( BYTE *prg_name1, BYTE *prg_name2, BYTE *file_name );
    VOID    ( *SetProcEvent    )( TPROC proc );
    VOID    ( *SetProcTimer    )( TPROC proc );
    VOID    ( *SetProgramName  )( BYTE *name );
    VOID    ( *SetReturn       )( BOOL like_sysgem );
    VOID    ( *CheckLogFont    )( BOOL check );
    INT     ( *SetSelColor     )( INT color );
    INT     ( *SetSelTextColor )( INT color );
    VOID    ( *SetSliderFont   )( OBJECT *tree, INT box, INT font_id, INT font_pt, BOOL draw );
    INT     ( *SetSliderPos    )( OBJECT *tree, INT box, INT pos, BOOL draw );
    BOOL    ( *SetSliderTab    )( OBJECT *tree, INT box, INT pos, INT just );
    VOID    ( *SetSysFont      )( INT font_id );
    VOID    ( *SetText         )( OBJECT *tree, INT index, BYTE *text );
    VOID    ( *SetTextColor    )( OBJECT *tree, INT obj, INT color );
    VOID    ( *SetTimer        )( INT ms_low, INT ms_high );
    VOID    ( *SetUnknownEvent )( UPROC proc );
    VOID    ( *SetWinBackground)( LONG win_id, INT color );
    VOID    ( *SetWinMaxSize   )( LONG win_id, INT w, INT h );
    VOID    ( *SetWinMinSize   )( LONG win_id, INT w, INT h );
    VOID    ( *SetWinUser      )( LONG win_id, VOID *user );
    BOOL    ( *SetWindowFont   )( LONG win_id, INT font_id, INT font_pt );
    VOID    ( *GetWindowFont   )( LONG win_id, INT *id, INT *pt );
    VOID    ( *SetWindowInfo   )( INT handle, BYTE *info );
    VOID    ( *SetWindowName   )( INT handle, BYTE *name );
    LONG    ( *SetWindowParm   )( INT handle, INT what, LONG value );
    VOID    ( *SetWindowTimer  )( LONG win_id, INT ms_low, INT ms_high );
    VOID    ( *SetXTimer       )( LONG id, TPROC proc, INT ms_low, INT ms_high, VOID *user1, VOID *user2 );
    VOID    ( *ShortCutColor   )( INT color );
    VOID    ( *ShowAbacus      )( VOID );
    VOID    ( *ShowClock       )( VOID );
    VOID    ( *ShowCoffee      )( VOID );
    VOID    ( *ShowCursor      )( LONG win_id );
    VOID    ( *ShowDice        )( VOID );
    VOID    ( *ShowDisc        )( VOID );
    VOID    ( *ShowMessage     )( BYTE *text );
    VOID    ( *ShowStatus      )( BYTE *text1, BYTE *text2, LONG p, LONG p100 );
    VOID    ( *ShowObj         )( OBJECT *tree, INT obj, BOOL draw );
    VOID    ( *ShowPaper       )( VOID );
    VOID    ( *ShowRotor       )( VOID );
    VOID    ( *SmallFont       )( VOID );
    LONG    ( *StartSysGemModul)( BYTE *name, VOID *p );
    INT     ( *StringHeight    )( VOID );
    INT     ( *StringWidth     )( BYTE *text );
    BOOL    ( *SysGem3D        )( VOID );
    BYTE   *( *SysGemVerStr    )( VOID );
    UINT    ( *SysGemVersion   )( VOID );
    VOID    ( *TakeEvent       )( INT event, INT x, INT y, INT state, INT kstate, INT key, INT clicks, INT *msg );
    VOID    ( *TellKeyStrokes  )( BOOL tell );
    INT     ( *TerminateSysGem )( VOID );
    BOOL    ( *TopWindow       )( INT handle );
    BOOL    ( *UnLinkSlider    )( OBJECT *tree, INT box );
    VOID    ( *UpdateAbacus    )( VOID );
    VOID    ( *UpdateClock     )( VOID );
    VOID    ( *UpdateCoffee    )( VOID );
    VOID    ( *UpdateDice      )( VOID );
    VOID    ( *UpdateDisc      )( VOID );
    VOID    ( *UpdatePaper     )( VOID );
    VOID    ( *UpdateRotor     )( VOID );
    VOID    ( *UseFastTimer    )( LONG win_id, BOOL enable );
    VOID    ( *UseOwnEditFields)( VOID );
    VOID    ( *UseRoundButtons )( BOOL use );
    BOOL    ( *VectorFont      )( INT font_id );
    VOID    ( *WaitAfterClose  )( BOOL wait );
    VOID    ( *WhiteArea       )( RECT *r, INT color );
    BOOL    ( *WindowDialog    )( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, BOOL shut, BOOL force, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc );
    BOOL    ( *xWindowDialog   )( LONG id, INT xpos, INT ypos, BYTE *name, BYTE *info, BOOL shut, BOOL force, OBJECT *tree, OBJECT *menu, INT edit, VOID *user, DPROC proc );
    BOOL    ( *WindowVisible   )( INT handle );
    VOID   *( *XWindow         )( XWIN *xwin );
    INT     ( *cmp_strings_dn  )( BYTE *str1, BYTE *str2 );
    INT     ( *cmp_strings_up  )( BYTE *str1, BYTE *str2 );
    UINT    ( *crc_16          )( BYTE *s, ULONG len );
    ULONG   ( *crc_32          )( BYTE *s, ULONG len );
    VOID    ( *do_qsort        )( LONG win_id, VPROC compare );
    VOID   *( *memcpy          )( VOID *dest, CONST VOID *src, size_t len );
    VOID   *( *memset          )( VOID *ptr, INT val, size_t len );
    BYTE   *( *strcat          )( BYTE *s1, CONST BYTE *s2 );
    BYTE   *( *strchr          )( CONST BYTE *s, INT c );
    INT     ( *strcmp          )( CONST BYTE *s1, CONST BYTE *s2 );
    BYTE   *( *strcpy          )( BYTE *s1, CONST BYTE *s2 );
    INT     ( *stricmp         )( CONST BYTE *s1, CONST BYTE *s2 );
    BYTE   *( *strncat         )( BYTE *s1, CONST BYTE *s2, size_t n );
    INT     ( *strncmp         )( CONST BYTE *s1, CONST BYTE *s2, size_t n );
    BYTE   *( *strncpy         )( BYTE *s1, CONST BYTE *s2, size_t n );
    INT     ( *strnicmp        )( CONST BYTE *s1, CONST BYTE *s2, size_t n );
    BYTE   *( *strrchr         )( CONST BYTE *s, INT c );
    VOID    ( *v_stext         )( INT color, INT x, INT y, BYTE *text );
    VOID    ( *v_xtext         )( INT color, INT x, INT y, BYTE *text );
    VOID    ( *wcls            )( LONG win_id );
    BYTE    ( *wgetchar        )( LONG win_id, INT x, INT y, INT *effect );
    VOID    ( *wgetxy          )( LONG win_id, INT *x, INT *y );
    VOID    ( *wposxy          )( LONG win_id, INT x, INT y );
    VOID    ( *wprintf         )( LONG win_id, BYTE *format, ... );
    BYTE   *( *xAddToList      )( LONG win_id, BYTE *text, VOID *user );
    BYTE   *( *xChgInList      )( LONG win_id, UINT line, BYTE *text, VOID *user );
    BYTE   *( *xInsInList      )( LONG win_id, UINT line, BYTE *text, VOID *user );
    BYTE   *( *xLinkList       )( LONG win_id, BYTE *text, VOID *user );
    BOOL    ( *xLinkSlider     )( OBJECT *tree, INT up, INT dn, INT show, INT hide, INT max, INT box, VOID *buf, INT len, BOOL icons, SPROC redraw );
    INT     ( *xListbox        )( BYTE *strings, INT count, INT len, OBJECT *tree, INT box, SPROC redraw );
    INT     ( *xPopUp          )( OBJECT *tree, INT obj, OBJECT *tree2, INT start, INT *first );
    BOOL    ( *xSetLineIcon    )( LONG win_id, UINT line, OBJECT *tree, INT obj );
    INT     ( *memcmp          )( CONST VOID *ptr1, CONST VOID *ptr2, size_t len );
    INT     ( *sprintf         )( BYTE *string, CONST BYTE *format, ... );
    size_t  ( *strlen          )( CONST BYTE *s );
    VOID    ( *BeginHelp       )( OBJECT *tree, INT obj, BYTE *text );
    VOID    ( *EndHelp         )( VOID );
    VOID    ( *EnableHelp      )( VOID );
    VOID    ( *DisableHelp     )( VOID );
    VOID    ( *SetHelpTime     )( INT count );
    VOID    ( *SetHelpColor    )( INT color );
    VOID    ( *DebugTheModule  )( INT x, INT y );
    VOID    ( *DebugTheConfig  )( INT x, INT y, INT w_char, INT h_char );
    VOID    ( *winsert         )( LONG win_id );
    BOOL    ( *xOpenLogWindow  )( LONG win_id, BYTE *title, BYTE *info, INT anz_trees, XTREE *trees, INT columns, INT rows, INT x, INT y, VOID *user, APROC action );
    INT     ( *graf_mouse      )( int gr_monumber, MFORM *gr_mofaddr );
    int     ( *sscanf          )( const char *, const char *, ... );
    LONG    ( *Supexec         )( long (*func)( ));
    VOID    ( *qsort           )( void *base, size_t nmemb, size_t size, int (*compar)( ));
    INT     ( *Fsfirst         )( const char *filename, int attr );
    INT     ( *Fsnext          )( VOID );
    DTA    *( *Fgetdta         )( VOID );
    VOID   *( *Mxalloc         )( long amount, int mode );
    INT     ( *rsrc_obfix      )( OBJECT *re_otree, int re_oobject );
    INT     ( *get_cpu         )( VOID );
    LONG    ( *get_longframe   )( VOID );
    INT     ( *get_mch         )( VOID );
    VOID    ( *SetOwner        )( LONG owner );
    LONG    ( *GetOwner        )( LONG win_id );
    VOID    ( *xSetText        )( OBJECT *tree, INT index, BYTE *text );
    BYTE   *( *GetModuleName   )( BYTE *real_name );
    FILE   *( *fopen           )( const char *, const char * );
    INT     ( *fclose          )( FILE * );
    INT     ( *fprintf         )( FILE *, const char *, ... );
    BYTE   *( *fgets           )( char *, int, FILE * );
    VOID    ( *SendSliderPos   )( BOOL send );
  } FUNCTIONS;

/* ------------------------------------------------------------------- */

#ifndef __kernel__

/* ------------------------------------------------------------------- */

#define Allocate                fkt->Allocate
#define Dispose                 fkt->Dispose
#define AddSliderItem           fkt->AddSliderItem
#define AddToList               fkt->AddToList
#define Alert                   fkt->Alert
#define AskModule               fkt->AskModule
#define BeginDialog             fkt->BeginDialog
#define BeginListUpdate         fkt->BeginListUpdate
#define CalcArea                fkt->CalcArea
#define CalcWinTrees            fkt->CalcWinTrees
#define CallOnlineHelp          fkt->CallOnlineHelp
#define CenterX                 fkt->CenterX
#define CenterY                 fkt->CenterY
#define ChangeButton            fkt->ChangeButton
#define CheckWindow             fkt->CheckWindow
#define ChgInList               fkt->ChgInList
#define ClearArea               fkt->ClearArea
#define ClearEditFields         fkt->ClearEditFields
#define ClipboardChanged        fkt->ClipboardChanged
#define CloseAllWindows         fkt->CloseAllWindows
#define CloseWindow             fkt->CloseWindow
#define CloseWindowById         fkt->CloseWindowById
#define CopyArea                fkt->CopyArea
#define CountKeywords           fkt->CountKeywords
#define CountLines              fkt->CountLines
#define CountWindows            fkt->CountWindows
#define Cycle                   fkt->Cycle
#define CycleBack               fkt->CycleBack
#define CycleWindow             fkt->CycleWindow
#define CheckLogFont            fkt->CheckLogFont
#define DeSelSldItem            fkt->DeSelSldItem
#define DelCompleteList         fkt->DelCompleteList
#define DelConfig               fkt->DelConfig
#define DelDialog               fkt->DelDialog
#define DelInList               fkt->DelInList
#define DelXTimer               fkt->DelXTimer
#define DialPosXY               fkt->DialPosXY
#define Disable3D               fkt->Disable3D
#define DisableObj              fkt->DisableObj
#define DisableTimer            fkt->DisableTimer
#define DispatchEvents          fkt->DispatchEvents
#define Display                 fkt->Display
#define DoDialog                fkt->DoDialog
#define DrawSlider              fkt->DrawSlider
#define Enable3D                fkt->Enable3D
#define EnableObj               fkt->EnableObj
#define EnableTimer             fkt->EnableTimer
#define EndAbacus               fkt->EndAbacus
#define EndClock                fkt->EndClock
#define EndCoffee               fkt->EndCoffee
#define EndDice                 fkt->EndDice
#define EndDisc                 fkt->EndDisc
#define EndListUpdate           fkt->EndListUpdate
#define EndMessage              fkt->EndMessage
#define EndStatus               fkt->EndStatus
#define EndPaper                fkt->EndPaper
#define EndRotor                fkt->EndRotor
#define FastDrawSldBox          fkt->FastDrawSldBox
#define FileSelect              fkt->FileSelect
#define FinishDialog            fkt->FinishDialog
#define FontExists              fkt->FontExists
#define FontSelect              fkt->FontSelect
#define FrameTextColor          fkt->FrameTextColor
#define FreeArea                fkt->FreeArea
#define GetConfig               fkt->GetConfig
#define GetConfigPtr            fkt->GetConfigPtr
#define GetCookie               fkt->GetCookie
#define GetFontId               fkt->GetFontId
#define GetFontName             fkt->GetFontName
#define GetHandle               fkt->GetHandle
#define GetLineHeight           fkt->GetLineHeight
#define GetLinePtr              fkt->GetLinePtr
#define GetListUserPtr          fkt->GetListUserPtr
#define GetParStruct            fkt->GetParStruct
#define GetParam                fkt->GetParam
#define GetSliderItems          fkt->GetSliderItems
#define GetText                 fkt->GetText
#define GetTabPosition          fkt->GetTabPosition
#define GetTopWindow            fkt->GetTopWindow
#define GetTopWindowId          fkt->GetTopWindowId
#define GetWinUser              fkt->GetWinUser
#define GetWindowId             fkt->GetWindowId
#define GetXTimerId             fkt->GetXTimerId
#define GetXTimerUser1          fkt->GetXTimerUser1
#define GetXTimerUser2          fkt->GetXTimerUser2
#define HandleDialog            fkt->HandleDialog
#define HandleSysGem            fkt->HandleSysGem
#define HideCursor              fkt->HideCursor
#define HideObj                 fkt->HideObj
#define InitResource            fkt->InitResource
#define InitXWindow             fkt->InitXWindow
#define InsInList               fkt->InsInList
#define LinkHorSlider           fkt->LinkHorSlider
#define LinkImage               fkt->LinkImage
#define LinkList                fkt->LinkList
#define LinkMainImage           fkt->LinkMainImage
#define LinkOwnRedraw           fkt->LinkOwnRedraw
#define LinkSlider              fkt->LinkSlider
#define LinkTree                fkt->LinkTree
#define UnLinkTree              fkt->UnLinkTree
#define Listbox                 fkt->Listbox
#define LoadConfig              fkt->LoadConfig
#define LoadResource            fkt->LoadResource
#define LoadSysGemModul         fkt->LoadSysGemModul
#define ModulAvail              fkt->ModulAvail
#define MoveScreen              fkt->MoveScreen
#define MultipleDialog          fkt->MultipleDialog
#define NewArea                 fkt->NewArea
#define NewDialog               fkt->NewDialog
#define NormalFont              fkt->NormalFont
#define OpenLogWindow           fkt->OpenLogWindow
#define xOpenLogWindow          fkt->xOpenLogWindow
#define OpenTextWindow          fkt->OpenTextWindow
#define OpenWindow              fkt->OpenWindow
#define PopUp                   fkt->PopUp
#define ReSizeWindow            fkt->ReSizeWindow
#define RectIntersect           fkt->RectIntersect
#define RectVisible             fkt->RectVisible
#define RedrawArea              fkt->RedrawArea
#define RedrawLine              fkt->RedrawLine
#define RedrawObj               fkt->RedrawObj
#define RedrawSliderBox         fkt->RedrawSliderBox
#define RedrawTheSlider         fkt->RedrawTheSlider
#define RedrawWindow            fkt->RedrawWindow
#define RemoveOwnRedraw         fkt->RemoveOwnRedraw
#define ResetSysFont            fkt->ResetSysFont
#define RestoreArea             fkt->RestoreArea
#define RscAdr                  fkt->RscAdr
#define RscFree                 fkt->RscFree
#define SaveArea                fkt->SaveArea
#define SaveConfig              fkt->SaveConfig
#define ScrollSlider            fkt->ScrollSlider
#define ScrollWindow            fkt->ScrollWindow
#define SearchProgram           fkt->SearchProgram
#define SelectPrinter           fkt->SelectPrinter
#define SelectSldItem           fkt->SelectSldItem
#define SendFontChanged         fkt->SendFontChanged
#define Set3DAlertColor         fkt->Set3DAlertColor
#define SetAccProc              fkt->SetAccProc
#define SetAlertColor           fkt->SetAlertColor
#define SetAlertTitle           fkt->SetAlertTitle
#define SetButton               fkt->SetButton
#define SetClipping             fkt->SetClipping
#define SetConfig               fkt->SetConfig
#define SetDispatchTime         fkt->SetDispatchTime
#define SetEditField            fkt->SetEditField
#define SetFont                 fkt->SetFont
#define SetFulledH              fkt->SetFulledH
#define SetFulledW              fkt->SetFulledW
#define SetFulledX              fkt->SetFulledX
#define SetFulledY              fkt->SetFulledY
#define SetIconRedraw           fkt->SetIconRedraw
#define SetIconifyName          fkt->SetIconifyName
#define SetLanguage             fkt->SetLanguage
#define SetLineColor            fkt->SetLineColor
#define SetLineEffect           fkt->SetLineEffect
#define SetLineFlags            fkt->SetLineFlags
#define SetLineIcon             fkt->SetLineIcon
#define SetLineUser             fkt->SetLineUser
#define SetLinkIconColor        fkt->SetLinkIconColor
#define SetLinkTextColor        fkt->SetLinkTextColor
#define SetListTab              fkt->SetListTab
#define SetListUserPtr          fkt->SetListUserPtr
#define SetMonoEditFrame        fkt->SetMonoEditFrame
#define SetOnlineHelp           fkt->SetOnlineHelp
#define SetProcEvent            fkt->SetProcEvent
#define SetProcTimer            fkt->SetProcTimer
#define SetProgramName          fkt->SetProgramName
#define SetReturn               fkt->SetReturn
#define SetSelColor             fkt->SetSelColor
#define SetSelTextColor         fkt->SetSelTextColor
#define SetSliderFont           fkt->SetSliderFont
#define SetSliderPos            fkt->SetSliderPos
#define SetSliderTab            fkt->SetSliderTab
#define SetSysFont              fkt->SetSysFont
#define SetText                 fkt->SetText
#define xSetText                fkt->xSetText
#define SetTextColor            fkt->SetTextColor
#define SetTimer                fkt->SetTimer
#define SetUnknownEvent         fkt->SetUnknownEvent
#define SetWinBackground        fkt->SetWinBackground
#define SetWinMaxSize           fkt->SetWinMaxSize
#define SetWinMinSize           fkt->SetWinMinSize
#define SetWinUser              fkt->SetWinUser
#define SetWindowFont           fkt->SetWindowFont
#define GetWindowFont           fkt->GetWindowFont
#define SetWindowInfo           fkt->SetWindowInfo
#define SetWindowName           fkt->SetWindowName
#define SetWindowParm           fkt->SetWindowParm
#define SetWindowTimer          fkt->SetWindowTimer
#define SetXTimer               fkt->SetXTimer
#define ShortCutColor           fkt->ShortCutColor
#define ShowAbacus              fkt->ShowAbacus
#define ShowClock               fkt->ShowClock
#define ShowCoffee              fkt->ShowCoffee
#define ShowCursor              fkt->ShowCursor
#define ShowDice                fkt->ShowDice
#define ShowDisc                fkt->ShowDisc
#define ShowMessage             fkt->ShowMessage
#define ShowStatus              fkt->ShowStatus
#define ShowObj                 fkt->ShowObj
#define ShowPaper               fkt->ShowPaper
#define ShowRotor               fkt->ShowRotor
#define SmallFont               fkt->SmallFont
#define StartSysGemModul        fkt->StartSysGemModul
#define GetModuleName           fkt->GetModuleName
#define StringHeight            fkt->StringHeight
#define StringWidth             fkt->StringWidth
#define SysGem3D                fkt->SysGem3D
#define SysGemVerStr            fkt->SysGemVerStr
#define SysGemVersion           fkt->SysGemVersion
#define TakeEvent               fkt->TakeEvent
#define TellKeyStrokes          fkt->TellKeyStrokes
#define TerminateSysGem         fkt->TerminateSysGem
#define TopWindow               fkt->TopWindow
#define UnLinkSlider            fkt->UnLinkSlider
#define UpdateAbacus            fkt->UpdateAbacus
#define UpdateClock             fkt->UpdateClock
#define UpdateCoffee            fkt->UpdateCoffee
#define UpdateDice              fkt->UpdateDice
#define UpdateDisc              fkt->UpdateDisc
#define UpdatePaper             fkt->UpdatePaper
#define UpdateRotor             fkt->UpdateRotor
#define UseFastTimer            fkt->UseFastTimer
#define UseOwnEditFields        fkt->UseOwnEditFields
#define UseRoundButtons         fkt->UseRoundButtons
#define VectorFont              fkt->VectorFont
#define WaitAfterClose          fkt->WaitAfterClose
#define WhiteArea               fkt->WhiteArea
#define WindowDialog            fkt->WindowDialog
#define xWindowDialog           fkt->xWindowDialog
#define WindowVisible           fkt->WindowVisible
#define XWindow                 fkt->XWindow
#define cmp_strings_dn          fkt->cmp_strings_dn
#define cmp_strings_up          fkt->cmp_strings_up
#define crc_16                  fkt->crc_16
#define crc_32                  fkt->crc_32
#define do_qsort                fkt->do_qsort
#define memcmp                  fkt->memcmp
#define memcpy                  fkt->memcpy
#define memset                  fkt->memset
#define sprintf                 fkt->sprintf
#define strcat                  fkt->strcat
#define strchr                  fkt->strchr
#define strcmp                  fkt->strcmp
#define strcpy                  fkt->strcpy
#define stricmp                 fkt->stricmp
#define strlen                  fkt->strlen
#define strncat                 fkt->strncat
#define strncmp                 fkt->strncmp
#define strncpy                 fkt->strncpy
#define strnicmp                fkt->strnicmp
#define strrchr                 fkt->strrchr
#define v_stext                 fkt->v_stext
#define v_xtext                 fkt->v_xtext
#define wcls                    fkt->wcls
#define wgetchar                fkt->wgetchar
#define wgetxy                  fkt->wgetxy
#define wposxy                  fkt->wposxy
#define wprintf                 fkt->wprintf
#define xAddToList              fkt->xAddToList
#define xChgInList              fkt->xChgInList
#define xInsInList              fkt->xInsInList
#define xLinkList               fkt->xLinkList
#define xLinkSlider             fkt->xLinkSlider
#define xListbox                fkt->xListbox
#define xPopUp                  fkt->xPopUp
#define xSetLineIcon            fkt->xSetLineIcon
#define BeginHelp               fkt->BeginHelp
#define EndHelp                 fkt->EndHelp
#define EnableHelp              fkt->EnableHelp
#define DisableHelp             fkt->DisableHelp
#define SetHelpTime             fkt->SetHelpTime
#define SetHelpColor            fkt->SetHelpColor
#define DebugTheModule          fkt->DebugTheModule
#define DebugTheConfig          fkt->DebugTheConfig
#define winsert                 fkt->winsert
#define graf_mouse              fkt->graf_mouse
#define sscanf                  fkt->sscanf
#define Supexec                 fkt->Supexec
#define qsort                   fkt->qsort
#define Fsfirst                 fkt->Fsfirst
#define Fsnext                  fkt->Fsnext
#define Fgetdta                 fkt->Fgetdta
#define Mxalloc                 fkt->Mxalloc
#define rsrc_obfix              fkt->rsrc_obfix
#define get_cpu                 fkt->get_cpu
#define get_longframe           fkt->get_longframe
#define get_mch                 fkt->get_mch
#define SetOwner                fkt->SetOwner
#define GetOwner                fkt->GetOwner
#define fopen                   fkt->fopen
#define fclose                  fkt->fclose
#define fprintf                 fkt->fprintf
#define fgets                   fkt->fgets
#define SendSliderPos           fkt->SendSliderPos

/* ------------------------------------------------------------------- */

#endif /* __kernel__ */

/* ------------------------------------------------------------------- */

#endif /* __sysgem_module__ */

/* ------------------------------------------------------------------- */
