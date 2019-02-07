{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{
****************************************************************************
*                 ----------------------                                   *
*  Data Store -- | D4 | Global Variables                                   *
*                 ----------------------                                   *
****************************************************************************

                    *****    Number Of Record Variables    *****
}
     SortCount   : short_integer ;
     OR_Search,
     SortFlag    : boolean ;
     WindNum     : short_integer ;
     WindName    : array[1..MaxWind] of Window_Title ;
     WindInfo    : array[1..MaxWind] of Window_Title ;
     RecNo       : array[1..MaxWind] of short_integer ;
     TotalRec    : array[1..MaxWind] of short_integer ;
     TotScrRec   : short_integer ;
     F_RecNo     : array[1..MaxWind] of short_integer ;
     F_TotalRec  : array[1..MaxWind] of short_integer ;

     LabLine,
     RepLine,
     RepWidth    : short_integer ;
     LabSpace    : array[1..2] of short_integer ;
     PrtInit     : array[1..5] of Str20 ; 
     PrtFlag     : array[1..5] of boolean ;
     DecReal     : short_integer ;

     FormatStr,
     AlertStr    : Str255 ;
     Result      : short_integer ;

    { Memory Management Variables }
     MaxMem,       { Maximum memory available, in bytes }
     DataRecSize,  { Size of a Data Store Record, in bytes }
     PtrRecSize,   { Size of a Data Pointer Record, in bytes }
     ScrRecSize    { Size of a Screen Data Record, in bytes }
                   : long_integer ;

    { True if current data base has been altered, otherwise false }
     EditFlag    : array[1..MaxWind] of boolean ;
     D_EditFlag  : array[1..MaxWind] of boolean ;
     R_EditFlag  : boolean ;
     R_LoadFlag  : boolean ;

    { True if Memory is full }
     FullMemory  : boolean ;

    { Default PathName for Screen file operations }
     DefPathScr : Path_Name ;

    { Default PathName for Data file operations }
     DefPathDat : Path_Name ;
     DefPathTxt : Path_Name ;
     DefPathPrt : Path_Name ;

     HelpFileName : Path_Name ;

    { Default Filename for Screen file operations }
     DefFileScr : Path_Name ;

    { Default Filename for Data file operations }
     DefFileDat : Path_Name ;
     DefFileTxt : Path_Name ;
     DefFilePrt : Path_Name ;
{
                    *****    Global Control Variables    *****
}
    { Boolean flag to signal exit from the main control loop in the main
      program procedure  }
     ExitPrompt  : boolean ;

    { File designtor for output to Printer }
     Printer     : text ;

    { File Designation for Data (D3) Storage Files  }
     DataStorage : file of Str50 ;

    { File Designation for Screen Info (D1) Storage Files }
     ScrnStore   : file of ScrInfo ;

    { Short Circuit Redraw routines to prevent 2X redraws }
     ShortDraw   : boolean ;
    { Call UpdateInfoLine if no other action going on, 
      BUT only if Update needed }
     UpdateFlag  : boolean ;

    { SearchFlag is used to distiguish between Search Set-Up and actual
      Search Routine }
     SearchFlag  : boolean ;
{
****************************************************************************
*                 -------------                                            *
*  Data Store -- | D3 | Data                                               *
*                 -------------                                            *
****************************************************************************
  TYPE Declarations
  ---- ------------
    DataPtr  = ^DataInfo ;
    DataInfo = record
}
    D_FirstRec   : array[1..MaxWind] of DataPtr ;
    D_CurrentRec : array[1..MaxWind] of DataPtr ;
    D_LastRec    : array[1..MaxWind] of DataPtr ;
    D_OrderFirst : array[1..MaxWind] of DataPtr ;

    DelItem      : DataPtr ;
    D_DataRec    : DataStorePtr ;
{
****************************************************************************
*                 ------------------                                       *
*  Data Store -- | D2 | Screen                                             *
*                 ------------------                                       *
****************************************************************************
    Screen Variables to position Cursor during Design Phase and other
    global variables required by the Draw_Mod and Res_Mod procedures.
}
     { Current X-Cursor Location : For Design Mode Cursor Position }
    XCur,

     { Current Y-Cursor Location : For Design Mode Cursor Position }
    YCur : short_integer ;

     { x and y are the coordinants of the top left corner of the current
               Window
       w and h are the width and height of the current window }
    x, y, 
    w, h : short_integer ;

     { Spacing is the number of pixels between lines on the screen }
    Spacing : short_integer ;

    RW_Offset  : short_integer ;
    PL_Offset  : short_integer ;

     { Resolution of the screen }
    Resolution : short_integer ;

     { Menu Variables : used in the SetUpMenu Procedure in Res_Mod }
    MenuItem   : GemMenu ;
    InfoMenu   : Menu_Ptr ;
    Mode       : short_integer ;
    P_Mode     : short_integer ;

{
****************************************************************************
*                 ------------------                                       *
*  Data Store -- | D1 | Design Specs                                       *
*                 ------------------                                       *
****************************************************************************
  TYPE Declarations
  ---- ------------
    ScrPtr  = ^ScrInfo ;
    ScrInfo = record
}
    S_FirstRec   : array[1..MaxWind] of ScrPtr ;
    S_CurrentRec : array[1..MaxWind] of ScrPtr ;
    S_LastRec    : array[1..MaxWind] of ScrPtr ;
    
   { C => Compare Records -- used in Database merge operations -- AND -- }
   { C => Search Records -- used to track Search Criteria =, <, >, etc.  }
   { C => Sort Records -- used to track Ascend or Descend  }
    C_FirstRec : IntPtr ;
    C_LastRec  : IntPtr ;
    C_CurRec   : IntPtr ;

   { F=> Search Records -- used in Search and Sort operations }
    F_FirstRec : IntPtr ;
    F_LastRec  : IntPtr ;
    F_CurRec   : IntPtr ;

    F_SaveRec  : IntPtr ;
