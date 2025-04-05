{ PShell 1.1 - Shell fÅr Pascal+ 2.07 von Dirk Sabiwalsky 9/89 }

{$S20}

PROGRAM PShell;

CONST {$I GEMCONST.PAS}
      {$I PSHELL.I}
      OldPath  = 0;
      SetPath  = 1;
      Exec_Prg      = 4;
      Call_Compiler = 3;
      Call_Editor   = 2;
      Comp_Cancel   = 1;
      Comp_Ok       = 0;

TYPE {$I GEMTYPE.PAS}
     CString = PACKED ARRAY [0..255] OF CHAR;
     Str128 = STRING[128];
     C_Opt = RECORD
              List,Stack,No_Object,Range,Clear,Debug,Link,Pause : BOOLEAN;
              Link_File : Str128;
             END;
     PType = (PRG,TOS,TTP,ACC);
     L_Opt = RECORD
              L_PType : PType;
              Libs : ARRAY [1..20] OF STRING;
             END;
     Pars = RECORD
             C    : C_Opt;
             L    : L_Opt;
             Path,
             Name,
             EP,
             CP,
             LP,
             RS   : Str128;
            END;

VAR M_Main      : Menu_Ptr;
    D_Info,
    D_Env,
    D_COptions,
    D_LOptions  : Dialog_Ptr;
    SPath,SName,
    ParName,
    PrgName,
    APath,
    Ed_Path,
    Co_Path,
    Li_Path,
    RSC_Path    : Str128;
    First_FGet,
    Name_Known,
    Link_Ok     : BOOLEAN;
    Comp_Value,
    XDrive,
    W_Main      : INTEGER;
    Comp_Opt    : C_Opt;
    Link_Opt    : L_Opt;
    Env_Buffer  : LONG_INTEGER;

{$I GEMSUBS.PAS}
{$I GETFNAME.PAS}

VAR XPath : CString;

PROCEDURE adr_ltos(l : LONG_INTEGER; VAR s : CString);
EXTERNAL;

FUNCTION Getrez : INTEGER;
XBIOS(4);

FUNCTION Pexec (    load    : INTEGER;
                VAR pcspec  : CString;
                VAR pcmdln  : Str255;
                VAR penvstr : CString) : LONG_INTEGER;
GEMDOS($4B);

PROCEDURE Dsetdrv (newdrv : INTEGER);
GEMDOS($0E);

FUNCTION Dgetdrv : INTEGER;
GEMDOS($19);

PROCEDURE Dgetpath (VAR path : CString;
                    drive : INTEGER);
GEMDOS($47);

FUNCTION Dsetpath (VAR path : CString) : LONG_INTEGER;
GEMDOS($3B);

FUNCTION Malloc (nbytes : LONG_INTEGER) : LONG_INTEGER;
GEMDOS($48);

PROCEDURE Mfree (maddr : LONG_INTEGER);
GEMDOS($49);

FUNCTION UpCase(Ch : CHAR) : CHAR;
BEGIN
 IF Ch IN ['a'..'z']
  THEN UpCase:=Chr(Ord(Ch)-32)
  ELSE CASE Ch OF
        'Ñ' : UpCase:='é';
        'î' : UpCase:='ô';
        'Å' : UpCase:='ö';
        ELSE UpCase:=Ch;
       END;
END; { UpCase }

PROCEDURE Bee;
BEGIN
 Set_Mouse(M_Bee);
 Show_Mouse
END;

PROCEDURE No_Bee;
BEGIN
 Hide_Mouse;
 Set_Mouse(M_Arrow)
END;

PROCEDURE Box(x,y,b,h : INTEGER);
BEGIN
 Paint_Outline(FALSE);
 Paint_Color(1);
 Paint_Style(5);
 Paint_Rect(x,y,b,h)
END; { Box }

PROCEDURE Show_Info;
VAR Exit_Obj,
    Button   : INTEGER;
    Msg,Mask : Str128;
BEGIN
 REPEAT
  Set_DText(D_Info,PINAME,SName,SYSTEM_FONT,TE_LEFT);
  Center_Dialog(D_Info);
  Show_Mouse;
  Exit_Obj:=Do_Dialog(D_Info,0);
  Hide_Mouse;
  Obj_SetState(D_Info,Exit_Obj,NORMAL,TRUE);
  End_Dialog(D_Info);
  IF Exit_Obj=PICHOICE
   THEN BEGIN
         Mask:='*.PAS';
         Msg:='Choose Actual File';
         Show_Mouse;
         APath:=SPath;
         IF First_FGet
          THEN get_fname(SetPath,Msg,APath,Mask,SName,Button)
          ELSE get_fname(OldPath,Msg,APath,Mask,SName,Button);
         Hide_Mouse;
         IF Button=1
          THEN BEGIN
                SPath:=APath;
                Name_Known:=TRUE
               END;
         First_FGet:=FALSE;
        END
 UNTIL Exit_Obj=PIOK
END; { Show_Info }

PROCEDURE Fenster_Auf;
VAR W_Title  : Window_Title;
BEGIN
 W_Title:='DisabSoft';
 W_Main:=New_Window(None,W_Title,0,0,640,400);
 Open_Window(W_Main,0,0,0,0);
END; { Fenster_Auf }

PROCEDURE Make_Sourcename(VAR s : Str128);
VAR Msg,Mask : Str128;
    Button   : INTEGER;
BEGIN
 IF NOT Name_Known
  THEN BEGIN
         Mask:='*.PAS';
         Msg:='Choose Actual File';
         Show_Mouse;
         APath:=SPath;
         IF First_FGet
          THEN get_fname(SetPath,Msg,APath,Mask,SName,Button)
          ELSE get_fname(OldPath,Msg,APath,Mask,SName,Button);
         Hide_Mouse;
         IF Button=1
          THEN BEGIN
                SPath:=APath;
                Name_Known:=TRUE
               END;
         First_FGet:=FALSE;
       END;
 s:=SPath;
 IF s[Length(s)]<>'\' THEN s:=Concat(s,'\');
 s:=Concat(s,SName);
END; { Make_Sourcename }

PROCEDURE Init_Objects;
BEGIN
 Find_Menu(PMENU,M_Main);
 Find_Dialog(PINFO,D_Info);
 Find_Dialog(PCOPT,D_COptions);
 Find_Dialog(PLOPT,D_LOptions);
 Find_Dialog(PENV,D_Env);
END; { Init_Objects }

FUNCTION Execute(PName,PParam : Str255; EBuf : BOOLEAN) : LONG_INTEGER;
VAR EnvStr,CName : CString;
BEGIN
 Erase_Menu(M_Main);
 Close_Window(W_Main);
 Delete_Window(W_Main);
 Dsetdrv(XDrive);
 IF Dsetpath(XPath)<0 THEN;
 Exit_Gem;
 Show_Mouse;
 IF EBuf
  THEN BEGIN
        adr_ltos(Env_Buffer,EnvStr);
        EnvStr[4]:=#0;
        EnvStr[5]:=#0;
        EnvStr[6]:=#0;
        EnvStr[7]:=#0;
       END
  ELSE BEGIN
        EnvStr[0]:=#0;
        EnvStr[1]:=#0;
        EnvStr[2]:=#0;
        EnvStr[3]:=#0;
       END;
 make_cstring(PName,CName);
 PParam[Length(PParam)+1]:=#0;
 IF PName[Length(PName)] IN ['S','P']
  THEN BEGIN
        Hide_Mouse;
        Write(#27,'E',#27,'e');
       END;
 Execute:=Pexec(0,CName,PParam,EnvStr);
 IF PName[Length(PName)] IN ['S','P']
  THEN BEGIN
        Write(#27,'f');
        Show_Mouse;
       END;
 IF Init_Gem<>0 THEN BEGIN
                      WriteLn('GEM-Anwendung konnte nicht angemeldet werden ! <RETURN>');
                      ReadLn;
                      Halt
                     END;
 Init_Objects;
 Init_Mouse;
 Hide_Mouse;
 Fenster_Auf;
 Draw_Menu(M_Main)
END; { Execute }

FUNCTION Exec_Editor : INTEGER;
VAR PName,PParam : Str255;
    Result       : LONG_INTEGER;
BEGIN
 PName:=Ed_Path;
 Make_Sourcename(PParam);
 Result:=Execute(PName,PParam,FALSE);
 IF Result=1 THEN Exec_Editor:=Call_Compiler
             ELSE IF Result=2
                   THEN Exec_Editor:=Exec_Prg
                   ELSE Exec_Editor:=0
END; { Exec_Editor }

FUNCTION Error_Editor : INTEGER;
VAR PName,PParam : Str255;
    cs           : CString;
    Result       : LONG_INTEGER;
BEGIN
 PName:=Ed_Path;
 adr_cscopy(Env_Buffer,cs);
 make_pstring(cs,PParam);
 Result:=Execute(PName,PParam,FALSE);
 IF Result=1 THEN Error_Editor:=Call_Compiler
             ELSE IF Result=2
                   THEN Error_Editor:=Exec_Prg
                   ELSE Error_Editor:=0
END; { Exec_Editor }

PROCEDURE Exec_Compiler;
VAR PName,
    PParam : Str255;
    Result : LONG_INTEGER;
BEGIN
 PName:=Co_Path;
 Make_Sourcename(PParam);
 IF (Length(Comp_Opt.Link_File)=0) AND (NOT Comp_Opt.List)
  THEN PParam:=Concat(PParam,' /UGEM');
 IF NOT Comp_Opt.List THEN PParam:=Concat(PParam,' /GEM');
 IF Comp_Opt.Pause THEN PParam:=Concat(PParam,' /PAUSE');
 IF Comp_Opt.Debug THEN PParam:=Concat(PParam,' /DEBUG');
 IF NOT Comp_Opt.Stack THEN PParam:=Concat(PParam,' /NOCHECK');
 IF Comp_Opt.Range THEN PParam:=Concat(PParam,' /CHECK');
 IF Comp_Opt.Clear THEN PParam:=Concat(PParam,' /CLEAR');
 IF Comp_Opt.No_Object THEN PParam:=Concat(PParam,' /NOCODE');
 IF Comp_Opt.List THEN PParam:=Concat(PParam,' /LIST');
 IF Length(Comp_Opt.Link_File)>0
  THEN PParam:=Concat(PParam,' >',Comp_Opt.Link_File);
 Result:=Execute(PName,PParam,TRUE);
 IF Result=2
  THEN Comp_Value:=Call_Editor
  ELSE IF Result=0
        THEN Comp_Value:=Comp_Ok
        ELSE Comp_Value:=Comp_Cancel;
END; { Exec_Compiler }

PROCEDURE Exec_Linker;
VAR PName,s,
    PParam : Str255;
    i      : INTEGER;
    Result : LONG_INTEGER;
BEGIN
 PName:=Li_Path;
 Make_Sourcename(s);
 i:=Pos('.',s);
 IF i>0 THEN s[0]:=Chr(i-1);
 IF Link_Opt.L_PType=PRG THEN PParam:=Concat('! ',s,'.PRG=',s);
 IF Link_Opt.L_PType=TOS THEN PParam:=Concat('! ',s,'.TOS=',s);
 IF Link_Opt.L_PType=TTP THEN PParam:=Concat('! ',s,'.TTP=',s);
 IF Link_Opt.L_PType=ACC THEN PParam:=Concat('! ',s,'.ACC=',s);
 FOR i:=1 TO 20 DO
  IF Length(Link_Opt.Libs[i])>0
   THEN IF Length(Link_Opt.Libs[i])+Length(PParam)<230
         THEN PParam:=Concat(PParam,',',Link_Opt.Libs[i]);
 IF Link_Opt.L_PType IN [PRG,ACC]
  THEN PParam:=Concat(PParam,',PASGEM');
 PParam:=Concat(PParam,',PASLIB');
 Result:=Execute(PName,PParam,FALSE);
 Link_Ok:=(Result=0);
END; { Exec_Linker }

PROCEDURE Get_Env(VAR s : Str255; VAR d : INTEGER; VAR t : CString);
VAR i      : INTEGER;
    sdummy : Str255;
BEGIN
 IF Length(s)>=2
  THEN BEGIN
        IF (s[2]=':') AND (s[1] in ['A'..'P'])
         THEN BEGIN
               d:=Ord(UpCase(s[1]))-65;
               Delete(s,1,2);
              END;
        i:=Length(s);
        WHILE (i>1) AND (s[i]<>'\') DO i:=i-1;
        IF i>1
         THEN BEGIN
               sdummy:=Copy(s,1,i-1);
               Make_CString(sdummy,t);
               sdummy:=s;
               s:=Copy(sdummy,i+1,Length(sdummy)-i);
              END
         ELSE IF i=1
               THEN BEGIN
                     Delete(s,1,1);
                     sdummy:='\';
                     Make_CString(sdummy,t);
                    END;
       END;
END;

PROCEDURE Exec_Source;
VAR PName,
    PParam    : Str255;
    o_path    : CString;
    i,o_drive : INTEGER;
BEGIN
 IF Link_Opt.L_PType<>ACC
  THEN BEGIN
        Make_Sourcename(PName);
        i:=Pos('.',PName);
        IF i>0 THEN PName[0]:=Chr(i-1);
        IF Link_Opt.L_PType=PRG THEN PName:=Concat(PName,'.PRG');
        IF Link_Opt.L_PType=TOS THEN PName:=Concat(PName,'.TOS');
        IF Link_Opt.L_PType=TTP THEN PName:=Concat(PName,'.TTP');
        PParam:='';
        o_drive:=XDrive;
        o_path:=XPath;
        Get_Env(PName,XDrive,XPath);
        IF Execute(PName,PParam,FALSE)<0 THEN;
        XDrive:=o_drive;
        XPath:=o_path;
       END;
END; { Exec_Source }

PROCEDURE Exec_Program;
VAR Msg,Mask : Str128;
    PParam,
    PName    : Str255;
    o_path   : CString;
    Button,i,
    o_drive  : INTEGER;
BEGIN
 Show_Mouse;
 Msg:='Choose Program to Start';
 IF Link_Opt.L_PType IN [PRG,ACC] THEN Mask:='*.PRG';
 IF Link_Opt.L_PType=TOS THEN Mask:='*.TOS';
 IF Link_Opt.L_PType=TTP THEN Mask:='*.TTP';
 IF First_FGet
  THEN get_fname(SetPath,Msg,APath,Mask,PrgName,Button)
  ELSE get_fname(OldPath,Msg,APath,Mask,PrgName,Button);
 First_FGet:=FALSE;
 Hide_Mouse;
 IF (Button=1) AND (Length(PrgName)>0)
  THEN BEGIN
        PName:=APath;
        IF PName[Length(PName)]<>'\' THEN PName:=Concat(PName,'\');
        PName:=Concat(PName,Prgname);
        i:=Pos('.',PrgName);
        IF i>0 THEN Mask:=Copy(PrgName,i+1,Length(PrgName)-i)
               ELSE Mask:='';
        IF (Length(Mask)>0) AND ((Mask='PRG') OR (Mask='TOS') OR (Mask='TTP'))
         THEN BEGIN
               PParam:='';
               o_drive:=XDrive;
               o_path:=XPath;
               Get_Env(PName,XDrive,XPath);
               IF Execute(PName,PParam,FALSE)<0 THEN;
               XDrive:=o_drive;
               XPath:=o_path;
              END
       END;
END; { Exec_Program }

PROCEDURE Exec_RSC;
VAR PParam,
    PName    : Str255;
    o_path   : CString;
    Button,i,
    o_drive  : INTEGER;
BEGIN
 PParam:='';
 o_drive:=XDrive;
 o_path:=XPath;
 PName:=RSC_Path;
 Get_Env(PName,XDrive,XPath);
 IF Execute(PName,PParam,FALSE)<0 THEN;
 XDrive:=o_drive;
 XPath:=o_path;
END; { Exec_RSC }

PROCEDURE set_env;
VAR Exit_Obj : INTEGER;
    s        : Str255;
BEGIN
 s:=Ed_Path;
 Set_DEdit(D_Env,PENEDIT,'Editor:__________________________________________________',
                                'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                         s,SYSTEM_FONT,TE_LEFT);
 s:=Co_Path;
 Set_DEdit(D_Env,PENCOMP,'Compiler:________________________________________________',
                                  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                         s,SYSTEM_FONT,TE_LEFT);
 s:=Li_Path;
 Set_DEdit(D_Env,PENLINK,'Linker:__________________________________________________',
                                'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                         s,SYSTEM_FONT,TE_LEFT);
 s:=RSC_Path;
 Set_DEdit(D_Env,PENRSCED,'RSC-Editor:______________________________________________',
                                     'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                          s,SYSTEM_FONT,TE_LEFT);
 Center_Dialog(D_Env);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Env,0);
 Hide_Mouse;
 Obj_SetState(D_Env,Exit_Obj,NORMAL,FALSE);
 IF Exit_Obj<>PENEXIT
  THEN BEGIN
        Get_DEdit(D_Env,PENEDIT,s);
        Ed_Path:=s;
        Get_DEdit(D_Env,PENCOMP,s);
        Co_Path:=s;
        Get_DEdit(D_Env,PENLINK,s);
        Li_Path:=s;
        Get_DEdit(D_Env,PENRSCED,s);
        RSC_Path:=s;
       END;
 End_Dialog(D_Env)
END; { Set_Env }

PROCEDURE Compiler_Options;
VAR Exit_Obj : INTEGER;
    s        : Str255;
BEGIN
 s:=Comp_Opt.Link_File;
 Set_DEdit(D_COptions,PCLISTFN,
           'Listing-File:____________','XXXXXXXXXXXX',s,
           SYSTEM_FONT,TE_LEFT);
 IF Comp_Opt.List THEN Obj_SetState(D_COptions,PCLIST,SELECTED,FALSE)
                  ELSE Obj_SetState(D_COptions,PCLIST,NORMAL,FALSE);
 IF Comp_Opt.Stack THEN Obj_SetState(D_COptions,PCSTACK,SELECTED,FALSE)
                   ELSE Obj_SetState(D_COptions,PCSTACK,NORMAL,FALSE);
 IF Comp_Opt.No_Object THEN Obj_SetState(D_COptions,PCNOOBJ,SELECTED,FALSE)
                       ELSE Obj_SetState(D_COptions,PCNOOBJ,NORMAL,FALSE);
 IF Comp_Opt.Range THEN Obj_SetState(D_COptions,PCRANGE,SELECTED,FALSE)
                   ELSE Obj_SetState(D_COptions,PCRANGE,NORMAL,FALSE);
 IF Comp_Opt.Clear THEN Obj_SetState(D_COptions,PCCLEAR,SELECTED,FALSE)
                   ELSE Obj_SetState(D_COptions,PCCLEAR,NORMAL,FALSE);
 IF Comp_Opt.Debug THEN Obj_SetState(D_COptions,PCDEBUG,SELECTED,FALSE)
                   ELSE Obj_SetState(D_COptions,PCDEBUG,NORMAL,FALSE);
 IF Comp_Opt.Link THEN Obj_SetState(D_COptions,PCLINK,SELECTED,FALSE)
                  ELSE Obj_SetState(D_COptions,PCLINK,NORMAL,FALSE);
 IF Comp_Opt.Pause THEN Obj_SetState(D_COptions,PCPAUSE,SELECTED,FALSE)
                   ELSE Obj_SetState(D_COptions,PCPAUSE,NORMAL,FALSE);
 Center_Dialog(D_COptions);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_COptions,0);
 Hide_Mouse;
 Obj_SetState(D_COptions,Exit_Obj,NORMAL,FALSE);
 IF Exit_Obj<>PCEXIT
  THEN BEGIN
        Get_DEdit(D_COptions,PCLISTFN,s);
        Comp_Opt.Link_File:=s;
        Comp_Opt.List:=(Obj_State(D_COptions,PCLIST)=SELECTED);
        Comp_Opt.Stack:=(Obj_State(D_COptions,PCSTACK)=SELECTED);
        Comp_Opt.No_Object:=(Obj_State(D_COptions,PCNOOBJ)=SELECTED);
        Comp_Opt.Range:=(Obj_State(D_COptions,PCRANGE)=SELECTED);
        Comp_Opt.Clear:=(Obj_State(D_COptions,PCCLEAR)=SELECTED);
        Comp_Opt.Debug:=(Obj_State(D_COptions,PCDEBUG)=SELECTED);
        Comp_Opt.Link:=(Obj_State(D_COptions,PCLINK)=SELECTED);
        Comp_Opt.Pause:=(Obj_State(D_COptions,PCPAUSE)=SELECTED);
       END;
 End_Dialog(D_COptions)
END; { Compiler_Options }

PROCEDURE Linker_Options;
VAR Exit_Obj : INTEGER;
    s        : Str255;
BEGIN
 IF Link_Opt.L_PType=PRG THEN Obj_SetState(D_LOptions,PLPRG,SELECTED,FALSE)
                         ELSE Obj_SetState(D_LOptions,PLPRG,NORMAL,FALSE);
 IF Link_Opt.L_PType=TOS THEN Obj_SetState(D_LOptions,PLTOS,SELECTED,FALSE)
                         ELSE Obj_SetState(D_LOptions,PLTOS,NORMAL,FALSE);
 IF Link_Opt.L_PType=TTP THEN Obj_SetState(D_LOptions,PLTTP,SELECTED,FALSE)
                         ELSE Obj_SetState(D_LOptions,PLTTP,NORMAL,FALSE);
 IF Link_Opt.L_PType=ACC THEN Obj_SetState(D_LOptions,PLACC,SELECTED,FALSE)
                         ELSE Obj_SetState(D_LOptions,PLACC,NORMAL,FALSE);
 Set_DEdit(D_LOptions,PLL1,'____________','XXXXXXXXXXXX',Link_Opt.Libs[1],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL2,'____________','XXXXXXXXXXXX',Link_Opt.Libs[2],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL3,'____________','XXXXXXXXXXXX',Link_Opt.Libs[3],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL4,'____________','XXXXXXXXXXXX',Link_Opt.Libs[4],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL5,'____________','XXXXXXXXXXXX',Link_Opt.Libs[5],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL6,'____________','XXXXXXXXXXXX',Link_Opt.Libs[6],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL7,'____________','XXXXXXXXXXXX',Link_Opt.Libs[7],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL8,'____________','XXXXXXXXXXXX',Link_Opt.Libs[8],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL9,'____________','XXXXXXXXXXXX',Link_Opt.Libs[9],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL10,'____________','XXXXXXXXXXXX',Link_Opt.Libs[10],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL11,'____________','XXXXXXXXXXXX',Link_Opt.Libs[11],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL12,'____________','XXXXXXXXXXXX',Link_Opt.Libs[12],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL13,'____________','XXXXXXXXXXXX',Link_Opt.Libs[13],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL14,'____________','XXXXXXXXXXXX',Link_Opt.Libs[14],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL15,'____________','XXXXXXXXXXXX',Link_Opt.Libs[15],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL16,'____________','XXXXXXXXXXXX',Link_Opt.Libs[16],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL17,'____________','XXXXXXXXXXXX',Link_Opt.Libs[17],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL18,'____________','XXXXXXXXXXXX',Link_Opt.Libs[18],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL19,'____________','XXXXXXXXXXXX',Link_Opt.Libs[19],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_LOptions,PLL20,'____________','XXXXXXXXXXXX',Link_Opt.Libs[20],SYSTEM_FONT,TE_LEFT);
 Center_Dialog(D_LOptions);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_LOptions,0);
 Hide_Mouse;
 Obj_SetState(D_LOptions,Exit_Obj,NORMAL,FALSE);
 IF Exit_Obj<>PLEXIT
  THEN BEGIN
        IF Obj_State(D_LOptions,PLPRG)=SELECTED THEN Link_Opt.L_PType:=PRG;
        IF Obj_State(D_LOptions,PLTOS)=SELECTED THEN Link_Opt.L_PType:=TOS;
        IF Obj_State(D_LOptions,PLTTP)=SELECTED THEN Link_Opt.L_PType:=TTP;
        IF Obj_State(D_LOptions,PLACC)=SELECTED THEN Link_Opt.L_PType:=ACC;
        Get_DEdit(D_LOptions,PLL1,s); Link_Opt.Libs[1]:=s;
        Get_DEdit(D_LOptions,PLL2,s); Link_Opt.Libs[2]:=s;
        Get_DEdit(D_LOptions,PLL3,s); Link_Opt.Libs[3]:=s;
        Get_DEdit(D_LOptions,PLL4,s); Link_Opt.Libs[4]:=s;
        Get_DEdit(D_LOptions,PLL5,s); Link_Opt.Libs[5]:=s;
        Get_DEdit(D_LOptions,PLL6,s); Link_Opt.Libs[6]:=s;
        Get_DEdit(D_LOptions,PLL7,s); Link_Opt.Libs[7]:=s;
        Get_DEdit(D_LOptions,PLL8,s); Link_Opt.Libs[8]:=s;
        Get_DEdit(D_LOptions,PLL9,s); Link_Opt.Libs[9]:=s;
        Get_DEdit(D_LOptions,PLL10,s); Link_Opt.Libs[10]:=s;
        Get_DEdit(D_LOptions,PLL11,s); Link_Opt.Libs[11]:=s;
        Get_DEdit(D_LOptions,PLL12,s); Link_Opt.Libs[12]:=s;
        Get_DEdit(D_LOptions,PLL13,s); Link_Opt.Libs[13]:=s;
        Get_DEdit(D_LOptions,PLL14,s); Link_Opt.Libs[14]:=s;
        Get_DEdit(D_LOptions,PLL15,s); Link_Opt.Libs[15]:=s;
        Get_DEdit(D_LOptions,PLL16,s); Link_Opt.Libs[16]:=s;
        Get_DEdit(D_LOptions,PLL17,s); Link_Opt.Libs[17]:=s;
        Get_DEdit(D_LOptions,PLL18,s); Link_Opt.Libs[18]:=s;
        Get_DEdit(D_LOptions,PLL19,s); Link_Opt.Libs[19]:=s;
        Get_DEdit(D_LOptions,PLL20,s); Link_Opt.Libs[20]:=s
       END;
 End_Dialog(D_LOptions)
END; { Linker_Options }

PROCEDURE Write_Options;
VAR f        : File OF Pars;
    Msg,Mask : Str128;
    Button,i : INTEGER;
BEGIN
 Show_Mouse;
 Msg:='Write Options';
 Mask:='*.PAR';
 IF First_FGet
  THEN get_fname(SetPath,Msg,APath,Mask,ParName,Button)
  ELSE get_fname(OldPath,Msg,APath,Mask,ParName,Button);
 First_FGet:=FALSE;
 Hide_Mouse;
 IF (Button=1) AND (Length(ParName)>0)
  THEN BEGIN
        Bee;
        i:=Pos('.',ParName);
        IF i>0 THEN ParName[0]:=Chr(i-1);
        ParName:=Concat(ParName,'.PAR');
        IO_Check(FALSE);
        Rewrite(f,ParName);
        IF Io_Result<>0
         THEN Write(#7)
         ELSE BEGIN
               WITH f^ DO
               BEGIN
                C:=Comp_Opt;
                L:=Link_Opt;
                Path:=SPath;
                Name:=SName;
                EP:=Ed_Path;
                CP:=Co_Path;
                LP:=Li_Path;
                RS:=RSC_Path;
               END;
               Put(f);
               IF Io_Result<>0
                THEN Write(#7);
               Close(f)
              END;
              IO_Check(TRUE);
        No_Bee;
       END
END; { Write_Options }

PROCEDURE Write_Standards;
VAR f        : File OF Pars;
    Msg,Mask : Str128;
    Button,i : INTEGER;
BEGIN
 Bee;
 Io_Check(FALSE);
 Dsetdrv(XDrive);
 IF Dsetpath(XPath)<0 THEN;
 Rewrite(f,'STANDARDS.PAR');
 IF Io_Result<>0
  THEN Write(#7)
  ELSE BEGIN
        WITH f^ DO
        BEGIN
         C:=Comp_Opt;
         L:=Link_Opt;
         Path:=SPath;
         Name:=SName;
         EP:=Ed_Path;
         CP:=Co_Path;
         LP:=Li_Path;
         RS:=RSC_Path;
        END;
        Put(f);
        IF Io_Result<>0
         THEN Write(#7);
        Close(f)
       END;
 IO_Check(TRUE);
 No_Bee;
END; { Write_Standards }

PROCEDURE Read_Options;
VAR f         : File OF Pars;
    Msg,Mask  : Str128;
    Button,i  : INTEGER;
BEGIN
 Show_Mouse;
 Msg:='Read Options';
 Mask:='*.PAR';
 IF First_FGet
  THEN get_fname(SetPath,Msg,APath,Mask,ParName,Button)
  ELSE get_fname(OldPath,Msg,APath,Mask,ParName,Button);
 First_FGet:=FALSE;
 Hide_Mouse;
 IF (Button=1) AND (Length(ParName)>0)
  THEN BEGIN
        Bee;
        i:=Pos('.',ParName);
        IF i>0 THEN ParName[0]:=Chr(i-1);
        ParName:=Concat(ParName,'.PAR');
        IO_Check(FALSE);
        Reset(f,ParName);
        IF Io_Result<>0
         THEN Write(#7)
         ELSE BEGIN
               WITH f^ DO
               BEGIN
                Comp_Opt:=C;
                Link_Opt:=L;
                SPath:=Path;
                SName:=Name;
                Ed_Path:=EP;
                Co_Path:=CP;
                Li_Path:=LP;
                RSC_Path:=RS;
                Name_Known:=TRUE;
               END;
               Close(f)
              END;
        IO_Check(TRUE);
        No_Bee;
       END
END; { Read_Options }

PROCEDURE Load_Standards;
VAR f : File OF Pars;
BEGIN
 Bee;
 IO_Check(FALSE);
 Reset(f,'STANDARD.PAR');
 IF IO_Result=0
  THEN BEGIN
        WITH f^ DO
        BEGIN
         Comp_Opt:=C;
         Link_Opt:=L;
         SPath:=Path;
         SName:=Name;
         Ed_Path:=EP;
         Co_Path:=CP;
         Li_Path:=LP;
         RSC_Path:=RS;
         Name_Known:=TRUE;
        END;
        Close(f);
       END;
 IO_Check(TRUE);
 No_Bee;
END; { Load_Params }

PROCEDURE Handle_Menu(Entry : INTEGER; VAR Quit : BOOLEAN);
VAR Edit_Back : INTEGER;
BEGIN
 CASE Entry OF
  PEINFO  : Show_Info;
  PEEDIT  : BEGIN
             Edit_Back:=Exec_Editor;
             IF Edit_Back IN [Call_Compiler,Exec_Prg]
              THEN REPEAT
                    Exec_Compiler;
                    IF (Comp_Value=Comp_Ok) AND (Comp_Opt.Link)
                     THEN BEGIN
                           Exec_Linker;
                           IF (Edit_Back=Exec_Prg) AND Link_Ok
                            THEN Exec_Source;
                           Edit_Back:=0;
                          END
                     ELSE IF Comp_Value=Call_Editor
                           THEN Edit_Back:=Error_Editor
                           ELSE Edit_Back:=0
                   UNTIL (Comp_Value<>Call_Editor) OR (NOT (Edit_Back IN [Call_Compiler,Exec_Prg]));
            END;
  PECOMP  : BEGIN
             Edit_Back:=0;
             REPEAT
              Exec_Compiler;
              IF (Comp_Value=Comp_Ok) AND (Comp_Opt.Link)
               THEN BEGIN
                     Exec_Linker;
                     IF (Edit_Back=Exec_Prg) AND Link_Ok
                      THEN Exec_Source;
                     Edit_Back:=0;
                    END
               ELSE IF Comp_Value=Call_Editor
                     THEN Edit_Back:=Error_Editor
                     ELSE Edit_Back:=0
             UNTIL (Comp_Value<>Call_Editor) OR (NOT (Edit_Back IN [Call_Compiler,Exec_Prg]));
            END;
  PELINK  : Exec_Linker;
  PERUN   : REPEAT
             Exec_Compiler;
             Edit_Back:=0;
             IF Comp_Value=Comp_Ok
              THEN BEGIN
                    Exec_Linker;
                    IF Link_Ok
                     THEN Exec_Source;
                   END
              ELSE IF Comp_Value=Call_Editor
                    THEN Edit_Back:=Error_Editor
            UNTIL (Comp_Value<>Call_Editor) OR (NOT (Edit_Back IN [Call_Compiler,Exec_Prg]));
  PESTART : Exec_Source;
  PEEXEC  : Exec_Program;
  PERSC   : Exec_RSC;
  PEQUIT  : Quit:=TRUE;
  PECOPT  : Compiler_Options;
  PELOPT  : Linker_Options;
  PEENV   : Set_Env;
  PEREAD  : Read_Options;
  PEWRITE : Write_Options;
  PESTRD  : Write_Standards;
 END { CASE Entry }
END; { Handle_Menu }

PROCEDURE Handle_Keyboard(Key : INTEGER; VAR Quit : BOOLEAN);
BEGIN
 CASE Ord(UpCase(Chr(Key & $FF))) OF
  73 : Handle_Menu(PEINFO,Quit);   {  I }
  69 : Handle_Menu(PEEDIT,Quit);   {  E }
  67 : Handle_Menu(PECOMP,Quit);   {  C }
  76 : Handle_Menu(PELINK,Quit);   {  L }
  82 : Handle_Menu(PERUN,Quit);    {  R }
  83 : Handle_Menu(PESTART,Quit);  {  S }
  88 : Handle_Menu(PEEXEC,Quit);   {  X }
  05 : Handle_Menu(PERSC,Quit);    { ^E }
  81 : Handle_Menu(PEQUIT,Quit);   {  Q }
  03 : Handle_Menu(PECOPT,Quit);   { ^C }
  12 : Handle_Menu(PELOPT,Quit);   { ^L }
  16 : Handle_Menu(PEENV,Quit);    { ^P }
  18 : Handle_Menu(PEREAD,Quit);   { ^R }
  23 : Handle_Menu(PEWRITE,Quit);  { ^W }
  19 : Handle_Menu(PESTRD,Quit);   { ^S }
 END { CASE Key }
END; { Handle_Keyboard }

PROCEDURE Paint_Grey(x,y,b,h : INTEGER);
BEGIN
 IF (x>=0) AND (y>=0) AND (x+b<640) AND (y+h<400)
  THEN Box(x,y,b,h)
END; { Paint_Grey }

PROCEDURE Rahmen;
VAR Event,Taste,d,
    x2,y2,w2,h2   : INTEGER;
    Msg           : Message_Buffer;
    Quit          : BOOLEAN;
BEGIN
 Load_Standards;
 Fenster_Auf;
 Draw_Menu(M_Main);
 Quit:=FALSE;
 REPEAT
  Show_Mouse;
  Msg[0]:=0;
  REPEAT
   Event:=Get_Event(E_Message | E_Timer | E_Keyboard,1,1,1,$1000,
                    FALSE,0,0,0,0,FALSE,0,0,0,0,
                    Msg,Taste,d,d,d,d,d)
  UNTIL (   (Msg[0]=Mn_Selected)
         OR (Msg[0]=Wm_Redraw)
         OR ((Event & E_Keyboard)<>0));
  Hide_Mouse;
  IF Msg[0]=Mn_Selected
   THEN BEGIN
         Erase_Menu(M_Main);
         Handle_Menu(Msg[4],Quit);
         Draw_Menu(M_Main);
         Menu_Normal(M_Main,Msg[3])
        END
   ELSE IF Msg[0]=Wm_Redraw
         THEN BEGIN
               Erase_Menu(M_Main);
               first_rect(W_Main,x2,y2,w2,h2);
               begin_update;
               WHILE (w2<>0) OR (h2<>0) DO
               BEGIN
                IF rect_intersect(Msg[4],Msg[5],Msg[6],Msg[7],x2,y2,w2,h2)
                 THEN Paint_Grey(x2,y2,w2,h2);
                next_rect(W_Main,x2,y2,w2,h2);
               END;
               end_update;
               Draw_Menu(M_Main);
              END
         ELSE IF (Event & E_Keyboard)<>0
               THEN Handle_Keyboard(Taste,Quit)
 UNTIL Quit;
 Erase_Menu(M_Main);
 Close_Window(W_Main);
 Delete_Window(W_Main)
END; { Rahmen }

PROCEDURE Init_Vars;
VAR i : INTEGER;
BEGIN
 XDrive:=Dgetdrv;
 Dgetpath(XPath,0);
 beauty_path(XPath);
 make_pstring(XPath,SPath);
 APath:=SPath;
 SName:='SOURCE.PAS';
 First_FGet:=TRUE;
 Name_Known:=FALSE;
 WITH Comp_Opt DO
 BEGIN
  List:=FALSE;
  Stack:=FALSE;
  No_Object:=FALSE;
  Range:=FALSE;
  Clear:=FALSE;
  Debug:=FALSE;
  Link:=TRUE;
  Pause:=TRUE;
  Link_File:=''
 END;
 WITH Link_Opt DO
 BEGIN
  L_PType:=PRG;
  FOR i:=1 TO 20 DO Libs[i]:=''
 END;
 Ed_Path:='TEMPUS.PRG';
 Co_Path:='COMPILER.PRG';
 Li_Path:='LINKER.PRG';
 RSC_Path:='D:\RESOURCE\DRI\RCS.PRG';
END; { Init_Vars }

BEGIN
 IF Getrez<>2 THEN BEGIN
                    WriteLn('PShell lÑuft nur in hoher Auflîsung ! <RETURN>');
                    ReadLn;
                    Halt
                   END;
 Env_Buffer:=Malloc(1024);
 IF Env_Buffer<=0 THEN BEGIN
                        WriteLn('Zu wenig Speicher ! <RETURN>');
                        ReadLn;
                        Halt
                       END;
 IF Init_Gem<>0 THEN BEGIN
                      WriteLn('GEM-Anwendung konnte nicht angemeldet werden ! <RETURN>');
                      ReadLn;
                      Halt
                     END;
 IF NOT Load_Resource('PSHELL.RSC') THEN BEGIN
                                           WriteLn('Resource-Datei nicht gefunden ! <RETURN>');
                                           ReadLn;
                                           Halt
                                          END;
 Init_Objects;
 Init_Vars;
 Init_Mouse;
 Hide_Mouse;
 Rahmen;
 Show_Mouse;
 Exit_Gem
END.

