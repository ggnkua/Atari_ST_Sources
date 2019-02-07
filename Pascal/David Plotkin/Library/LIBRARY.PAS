{       	Madam Librarian, Last Revised 9/13/88	}
{		by David Plotkin			}
{		Copyright 1990 Antic Publishing		}
{							}
{		Portions Copyright 1986 OSS & CCD	}
{		Used by permission of OSS		}

PROGRAM MagIndex;

  {$I gemsubs}
   
  TYPE
    SStr = String[80];
    EStr = String[20];
    Txtfile = File of Text;
    Adrptr = ^Adrlist;
    Adrlist =
      RECORD
            Next: Adrptr;
            Article: String[70];
            Author: String[69];
            Magazine: String[20];
            Issue: String[15];
            Page: String[12];
            Tipe: String[29];
            Lnguage: String[25];
            Descr1: String[64];
            Descr2: String[77];
            Descr3: String[77];
            Descr4: String[77];
      END; { RECORD }

  VAR
    Tmag: String[20];    {holds last entered magazine}
    TIssue: String[15];  {holds last entered issue}
    Front,Dp,Pp,
    Adrs: Adrptr;
    linecount,   {keep track of lines printed}
    event,nevent,      {variable for Get_Event call}
    DTitle,DArticle,DAuthor,DMag,DIssue,DPage,DPrev,
    DDescr1,DDescr2,DDescr3,DDescr4,DType,DLang,DCancel,DOk,
    DNext,DDelete,DPrint,  {variables for main dialog box}
    NDName,NDCancel,NDOK,NDNot,  {Variables for Name Dialog box}
    PDTitle,PDLines,PDSpaces,PDLup,PDLdown,PDSup,PDSdown,
    PDLtext,PDStext,PDOK,PDCancel, {variables for Print opt dialog}
    PDMargins,PDMup,PDMdown,PDMtext,
    Spces,Lynes,Margins,Nst,
    width,height, {current window width and height}
    dummy,dum,        {a dummy, dummy!}
    window,    {window handle}
    xw,yw,     {y and x coordinates of window working area}
    wchar,hchar,hhchar,   {width and height of a character}
    mx,my,     {mouse x and y coordinates}
    Indx,Printflag,Numrec,Lmy,Current,
    title1,Regitem,Sumitem,Proptitem,Printitem,Psitem, {the menu items}
    Insertitem,VCDitem,Resetitem,Doneitem: Integer; {the menu items}
    dum1,dum2,dum3,title2,Aitem,Citem,Ditem,Mitem,Witem, {menu items}
    Titem, Litem, {menu items}
    title3,Loaditem,Saveitem, {menu items}
    Rectop,Titleitem,Titlestatus,Conditem,Condstatus,
    Top,Selection,key: Integer;
    Adrfile: Txtfile;
    Pathname,Filename: Path_Name;
    My_Menu: Menu_ptr;
    Fileselect,Alldone: Boolean;
    Wind_name: Str255;   {The window name string}
    msg: Message_Buffer;
    Nname: Str255;
    Info,Search,PrOpt: Dialog_Ptr;
    Choice,pushed: Tree_Index;
    PrintString: Str255;   {the string to send to the printer}
    Alertstring: String[80];
    Dumstring: Str255;
    EndOfHeap: ^Long_Integer;

 PROCEDURE Io_Check (on : Boolean);
  EXTERNAL;

 FUNCTION Io_Result : Integer;
  EXTERNAL;

 PROCEDURE Obj_Draw(dial:Dialog_Ptr;start,depth,x,y,w,h:Integer);
  EXTERNAL;

 PROCEDURE Set_Up_MainDialog;
      BEGIN {Set_Up_MainDialog}
        Info:=New_Dialog(20,0,0,78,17);
        DTitle:=Add_DItem(Info,G_Text,None,14,1,40,1,0,256); {Title setup}
        Set_DText(Info,DTitle,'     INSERT      ',System_Font,TE_Center);
        DArticle:=Add_DItem(Info,G_FText,None,1,2,77,1,0,$180); {Title setup}
        Set_DEdit(Info,DArticle,
'Title: _____________________________________________________________________',
       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
       '',System_Font,TE_Left);
        DAuthor:=Add_DItem(Info,G_FText,None,1,3,77,1,0,$180); {Author name}
        Set_DEdit(Info,DAuthor,
'Author: ____________________________________________________________________',
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        '',System_Font,TE_Left);
        DMag:=Add_DItem(Info,G_FText,None,1,4,30,1,0,$180); {Magazine setup}
        Set_DEdit(Info,DMag,'Magazine: ____________________',
                  'XXXXXXXXXXXXXXXXXXXX','',System_Font,TE_Left);
        DIssue:=Add_DItem(Info,G_FText,None,32,4,22,1,0,$180); {Issue setup}
        Set_DEdit(Info,DIssue,'Issue: _______________',
                  'XXXXXXXXXXXXXXX','',System_Font,TE_Left);
        DPage:=Add_DItem(Info,G_FText,None,55,4,18,1,0,$180); {Page setup}
        Set_DEdit(Info,DPage,'Page: ____________','XXXXXXXXXXXX',
                  '',System_Font,TE_Left);
        DType:=Add_DItem(Info,G_FText,None,1,5,35,1,0,$180); {type setup}
        Set_DEdit(Info,DType,'Type: _____________________________',
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX','',System_Font,TE_Left);
        DLang:=Add_DItem(Info,G_FText,None,40,5,35,1,0,$180); {language setup}
        Set_DEdit(Info,DLang,'Language: _________________________',
        'XXXXXXXXXXXXXXXXXXXXXXXXX','',System_Font,TE_Left);
        DDescr1:=Add_DItem(Info,G_FText,None,1,6,77,1,0,$180); {Descript setup}
        Set_DEdit(Info,DDescr1,
'Description: _______________________________________________________________',
             'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
             '',System_Font,TE_Left);
        DDescr2:=Add_DItem(Info,G_FText,None,1,7,77,1,0,$180); {Descript setup}
        Set_DEdit(Info,DDescr2,
'____________________________________________________________________________',
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        '',System_Font,TE_Left);
        DDescr3:=Add_DItem(Info,G_FText,None,1,8,77,1,0,$180); {Descript setup}
        Set_DEdit(Info,DDescr3,
'____________________________________________________________________________',
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        '',System_Font,TE_Left);
        DDescr4:=Add_DItem(Info,G_FText,None,1,9,77,1,0,$180); {Descript setup}
        Set_DEdit(Info,DDescr4,
'____________________________________________________________________________',
'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        '',System_Font,TE_Left);
        DCancel:=Add_DItem(Info,G_Button,Selectable|Exit_Btn,1,12,8,2,1,256);
        Set_DText(Info,DCancel,' CANCEL ',System_Font,TE_Center);
        DOK:=Add_DItem(Info,G_Button,Selectable|Exit_Btn|Default,
                       10,12,4,2,1,256);
        Set_DText(Info,DOK,' OK ',System_Font,TE_Center);
        DNext:=Add_DItem(Info,G_Button,Selectable|Exit_Btn,15,12,6,2,1,256);
        Set_DText(Info,DNext,' NEXT ',System_Font,TE_Center);
        DDelete:=Add_DItem(Info,G_Button,Selectable|Exit_Btn,22,12,8,2,1,256);
        Set_DText(Info,DDelete,' DELETE ',System_Font,TE_Center);
        DPrint:=Add_DItem(Info,G_Button,Selectable|Exit_Btn,31,12,7,2,1,256);
        Set_DText(Info,DPrint,' PRINT ',System_Font,TE_Center);
        DPrev:=Add_DItem(Info,G_Button,Selectable|Exit_Btn,39,12,10,2,1,256);
        Set_DText(Info,DPrev,' PREVIOUS ',System_Font,TE_Center);
      END;  {Set_Up_MainDialog}

  PROCEDURE Do_About_Dialog;  {do the 'about' dialog box}
   VAR  dialog : Dialog_Ptr;
        dummy,line1,line2,line3,line4,line5,width,ht,ok : Integer;
        button : Tree_Index;
   BEGIN  {Do_About_Dialog}
    width:=39;
    ht:=11;
    dialog:=New_Dialog(10,0,0,width,ht);
    line1:=Add_DItem(dialog,G_Text,None,2,1,width,1,0,256);
    Set_DText(dialog,line1,'Madam Librarian v 1.0 9/13/88',
              System_Font,TE_Center);
    line2:=Add_DItem(dialog,G_Text,None,2,2,width-2,1,0,256);
    Set_DText(dialog,line2,'By David Plotkin',System_Font,TE_Center);
    line4:=Add_DItem(dialog,G_Text,None,2,3,width-2,1,0,256);
    Set_DText(dialog,line4,'½ 1989 Antic Publishing',System_Font,TE_Center);
    line3:=Add_DItem(dialog,G_Text,None,2,5,width-2,1,0,256);
    Set_DText(dialog,line3,'Portions ½ 1986 OSS & CCD',System_Font,TE_Center);
    line5:=Add_DItem(dialog,G_Text,None,2,6,width-2,1,0,256);
    Set_DText(dialog,line5,'Used by permission of OSS',System_Font,TE_Center);
    ok:=Add_DItem(dialog,G_Button,Selectable|Exit_Btn|Default,
                  14,8,6,2,-1,$1180);
    Set_DText(dialog,ok,' OK ',System_Font,TE_Center);
    Center_Dialog(dialog);
    button:=Do_Dialog(dialog,0);
    End_Dialog(dialog);
    Delete_Dialog(dialog);
   END;  {Do_About_Dialog}

 PROCEDURE Set_Up_NameDialog;

      BEGIN {Set_Up_NameDialog}
        Search:=New_Dialog(3,0,0,78,6);
        NDName:=Add_DItem(Search,G_FText,None,1,1,77,1,0,$180); {Name setup}
        Set_DEdit(Search,NDName,
'Match : ____________________________________________________________________',
       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        '',System_Font,TE_Left);
        NDCancel:=Add_DItem(Search,G_Button,Selectable|Exit_Btn,
                            5,3,10,2,1,256);
        Set_DText(Search,NDCancel,' CANCEL ',System_Font,TE_Center);
        NDOK:=Add_DItem(Search,G_Button,Selectable|Exit_Btn|Default,
                        25,3,10,2,1,256);
        Set_DText(Search,NDOK,' OK ',System_Font,TE_Center);
        NDNot:=Add_DItem(Search,G_Button,Selectable,45,3,10,2,1,256);
        Set_DText(Search,NDNot,' NOT ',System_Font,TE_Center);
      END;  {Set_Up_NameDialog}

 PROCEDURE Print_Opt_Dialog;
  VAR arrow : STRING[1];
  BEGIN {Print_Opt_Dialog}
   PrOpt:=New_Dialog(18,0,0,36,10);
   PDTitle:=Add_DItem(PrOpt,G_Text,None,11,1,20,1,0,$1180);
   Set_DText(PrOpt,PDTitle,' PRINT OPTIONS ',System_Font,TE_Left);
   PDLText:=Add_DItem(PrOpt,G_String,None,1,3,18,1,0,0);
   Set_DText(PrOpt,PDLText,'Blank lines        ',System_Font,TE_Left);
   arrow:=' ';
   PDLup:=Add_DItem(PrOpt,G_Button,Touch_Exit,20,3,2,1,0,0);
   arrow[1]:=chr(1); {up arrow}
   Set_DText(PrOpt,PDLup,arrow,System_Font,TE_Center);
   PDLines:=Add_DItem(PrOpt,G_BoxText,Normal,22,3,3,1,-1,$1180);
   Set_DText(PrOpt,PDLines,' 2',System_Font,TE_Center);
   PDLdown:=Add_DItem(PrOpt,G_Button,Touch_Exit,25,3,2,1,0,0);
   arrow[1]:=chr(2); {down arrow}
   Set_DText(PrOpt,PDLdown,arrow,System_Font,TE_Center);
   PDSText:=Add_DItem(PrOpt,G_String,None,1,4,18,1,0,0);
   Set_DText(PrOpt,PDSText,'Blank spaces(left) ',System_Font,TE_Left);
   PDSup:=Add_DItem(PrOpt,G_Button,Touch_Exit,20,4,2,1,0,0);
   arrow[1]:=chr(1);
   Set_DText(PrOpt,PDSup,arrow,System_Font,TE_Center);
   PDSpaces:=Add_DItem(PrOpt,G_BoxText,Normal,22,4,3,1,-1,$1180);
   Set_DText(PrOpt,PDSpaces,' 0',System_Font,TE_Center);
   PDSdown:=Add_DItem(PrOpt,G_Button,Touch_Exit,25,4,2,1,0,0);
   arrow[1]:=chr(2);
   Set_DText(PrOpt,PDSdown,arrow,System_Font,TE_Center);
   PDMtext:=Add_DItem(PrOpt,G_String,None,1,5,18,1,0,0);
   Set_DText(PrOpt,PDMtext,'Top/bottom margins ',System_Font,TE_Left);
   PDMUp:=Add_DItem(PrOpt,G_Button,Touch_Exit,20,5,2,1,0,0);
   arrow[1]:=chr(1);
   Set_DText(PrOpt,PDMUp,arrow,System_Font,TE_Center);
   PDMargins:=Add_DItem(PrOpt,G_BoxText,Normal,22,5,3,1,-1,$1180);
   Set_DText(PrOpt,PDMargins,' 4',System_Font,TE_Center);
   PDMdown:=Add_DItem(PrOpt,G_Button,Touch_Exit,25,5,2,1,0,0);
   arrow[1]:=chr(2);
   Set_DText(PrOpt,PDMdown,arrow,System_Font,TE_Center);
   PDOK:=Add_DItem(PrOpt,G_Button,Selectable|Exit_Btn|Default,10,7,4,2,0,0);
   Set_DText(PrOpt,PDOK,' OK ',System_Font,TE_Center);
   PDCancel:=Add_DItem(PrOpt,G_Button,Selectable|Exit_Btn,16,7,8,2,0,0);
   Set_DText(PrOpt,PDCancel,' Cancel ',System_Font,TE_Center);
  END; {Print_Opt_Dialog}


 PROCEDURE Set_Up_Menus;  {set up the menus}
  BEGIN  {Set_Up_Menus}
   My_menu:=New_Menu(30,' About Madm Libr ');
   title3:=Add_MTitle(My_Menu,' File    ');
   title1:=Add_MTitle(My_Menu,' Options ');
   title2:=Add_MTitle(My_Menu,' Match   ');
   Loaditem:=Add_MItem(My_Menu,title3,'  Load     ');
   Saveitem:=Add_MItem(My_Menu,title3,'  Save     ');
   Doneitem:=Add_MItem(My_Menu,title3,'  Quit     ');
   Regitem:=Add_MItem(My_Menu,title1,'  Regular        ');
   Sumitem:=Add_MItem(My_Menu,title1,'  Summary        ');
   Titleitem:=Add_MItem(My_Menu,title1,'  Titles         ');
   Conditem:=Add_MItem(My_Menu,title1, '  Condensed      ');
   dum1:=Add_MItem(My_Menu,title1,'-----------------');
   Proptitem:=Add_MItem(My_Menu,title1,'  Print Options  ');
   Printitem:=Add_MItem(My_Menu,title1,'  Print All      ');
   Psitem:=Add_MItem(My_Menu,title1,'  Print Some     ');
   dum2:=Add_MItem(My_Menu,title1,'-----------------');
   Menu_Check(My_Menu,Regitem,True); {check the regular format}
   Insertitem:=Add_MItem(My_Menu,title1,'  Insert       ^I');
   VCDitem:=Add_MItem(My_Menu,title1,'  View/Chg/Del ^V');
   Resetitem:=Add_MItem(My_Menu,title1,'  Reset line cnt ');
   Menu_Disable(My_Menu,dum1);
   Menu_Disable(My_Menu,dum2);
   Aitem:=Add_MItem(My_Menu,title2,'  Article      ');
   Citem:=Add_MItem(My_Menu,title2,'  Page         ');
   Ditem:=Add_MItem(My_Menu,title2,'  Description  ');
   Mitem:=Add_MItem(My_Menu,title2,'  Magazine     ');
   Witem:=Add_MItem(My_Menu,title2,'  Author       ');
   Titem:=Add_MItem(My_Menu,title2,'  Type         ');
   Litem:=Add_MItem(My_Menu,title2,'  Language     ');
   Menu_Check(My_Menu,Aitem,True);
   Draw_Menu(My_Menu)
  END;  {Set_Up_Menus}

 PROCEDURE Check_Margins(P:Adrptr);
  VAR lp,tp,btm,rl : Integer;
  BEGIN {Check_Margins}
   tp:=(Margins DIV 2);
   btm:=66-(Margins DIV 2);
   rl:=1; {for summary format}
   IF Printflag=0 THEN BEGIN {regular format}
    rl:=4;
    IF P^.Descr1<>'' THEN rl:=rl+1; {increase record length}
    IF P^.Descr2<>'' THEN rl:=rl+1; {if description lines used}
    IF P^.Descr3<>'' THEN rl:=rl+1;
    IF P^.Descr4<>'' THEN rl:=rl+1;
   END; {regular format}
   IF linecount>=btm-(rl-1) THEN BEGIN {bottom}
    FOR lp:=linecount TO 66 DO
     Writeln(Adrfile); {put in bottom margin}
    linecount:=0;
   END; {bottom}
   IF linecount=0 THEN BEGIN {top}
    FOR lp:=1 to tp DO
     Writeln(Adrfile); {put in top margin}
    linecount:=tp+1;
   END; {top}
  END; {Check_Margins}

 PROCEDURE LPrint(P:Adrptr);
  VAR lp,blanks,marg : Integer;
      bspces : STRING[80];
   BEGIN {Lprint}
     Rewrite(Adrfile,'PRN:');  {Attach Adrfile to Printer}
     IF Condstatus=0 THEN WRITE(Adrfile,Chr(18))
      ELSE WRITE(Adrfile,Chr(15));
     Check_Margins(P);
     bspces:='';
     IF Spces>0 THEN
      FOR lp:=1 to Spces DO BEGIN {build string}
       bspces[0]:=chr(lp);
       bspces:=Concat(bspces,' ');
      END; {build string}
     IF Printflag=0 THEN {regular}
      IF Titlestatus=0 THEN
       Printstring:=Concat(bspces,P^.Article)
      ELSE
       Printstring:=Concat(bspces,'Article: ',P^.Article)
     ELSE {summary-ignore extra lines}
      PrintString:=Concat(bspces,P^.Article,'  ',P^.Magazine,'  ',P^.Issue);
     Writeln(Adrfile,PrintString);  {Print it}
     linecount:=linecount+1;
     IF Printflag=0 THEN BEGIN {balance of regular format}
      IF Titlestatus=0 THEN
       Writeln(Adrfile,Concat(bspces,P^.Author))
      ELSE
       Writeln(Adrfile,Concat(bspces,'Author: ',P^.Author));
      linecount:=linecount+1;
      IF Titlestatus=0 THEN
       Printstring:=Concat(bspces,P^.Magazine,'  ',P^.Issue,'  ',P^.Page)
      ELSE BEGIN {build string}
      Printstring:=Concat(bspces,'Magazine: ',P^.Magazine,' Issue: ',P^.Issue);
       Printstring:=Concat(Printstring,' Page: ',P^.Page);
      END; {build string}
      Writeln(Adrfile,Printstring);
      linecount:=linecount+1;
      IF Titlestatus=0 THEN
       Printstring:=Concat(bspces,P^.Tipe,'   ',P^.Lnguage)
      ELSE
       Printstring:=Concat(bspces,'Type: ',P^.Tipe,' Language: ',P^.Lnguage);
      Writeln(Adrfile,Printstring);
      linecount:=linecount+1;
      IF P^.Descr1<>'' THEN BEGIN {Descr1 used}
       Writeln(Adrfile,Concat(bspces,P^.Descr1));
       linecount:=linecount+1;
      END; {Descr1 used}
      IF P^.Descr2<>'' THEN BEGIN {Descr2 used}
       Writeln(Adrfile,Concat(bspces,P^.Descr2));
       linecount:=linecount+1;
      END; {Descr2 used}
      IF P^.Descr3<>'' THEN BEGIN {Descr3 used}
       Writeln(Adrfile,Concat(bspces,P^.Descr3));
       linecount:=linecount+1;
      END; {Descr3 used}
      IF P^.Descr4<>'' THEN BEGIN {Descr4 used}
       Writeln(Adrfile,Concat(bspces,P^.Descr4));
       linecount:=linecount+1;
      END; {Descr4 used}
      blanks:=Lynes;
      lp:=1; marg:=66-(Margins DIV 2);
      WHILE (lp<=blanks) AND (linecount<=marg) DO BEGIN {blank lines}
       Writeln(Adrfile);
       lp:=lp+1; linecount:=linecount+1;
      END; {blank lines}
     END; {balance of regular format}
   END;  {LPrint}

PROCEDURE PlaceData;
  VAR lp,Prntlyne : Integer;
      P: Adrptr;
   BEGIN  {PlaceData}
    Text_Color(1);
    Line_Color(1);
    IF Front <>NIL THEN BEGIN {records in window}
     P:=Front; RecTop:=1;
     WHILE (P<>NIL) AND (RecTop<Top) DO BEGIN {Find top record}
      P:=P^.Next; RecTop:=RecTop+1;
     END; {Find top record}
     Prntlyne:=1;
     WHILE (Prntlyne<23) AND (P<>NIL) DO BEGIN {Put on screen}
      Draw_String(wchar+xw,Prntlyne*hchar+yw,P^.Article);
      Prntlyne:=Prntlyne+1;
      P:=P^.Next;
     END; {Put on screen}
    END; {records in window}
   END;  {PlaceData}

 PROCEDURE Do_Redraw( handle,x0,y0,w0,h0 : integer; bckgrnd : Boolean );

   {These will hold the size of the current redraw rectangle in redraw list. }
   VAR x,y,w,h : Integer ;

   BEGIN  {Do_Redraw}
    Work_Rect(handle,xw,yw,Width,height);    {get the right window!}
    Begin_Update;           {Tell GEM we are updating}
    Hide_Mouse ;        {Hide mouse so we don't mess up the screen}
    Draw_Mode(1);       {Replace mode drawing}
    Paint_Style( Solid );   {draw with no pattern}
    Paint_Color( White ) ;  {Clearing each rectangle with white}
    First_Rect( handle,x,y,w,h ) ;
    WHILE (w <> 0) AND (h <> 0) DO
     BEGIN
      IF Rect_Intersect( x0,y0,w0,h0,x,y,w,h ) THEN
        BEGIN
         Set_Clip( x,y,w,h ) ;
         IF bckgrnd = True THEN   {redraw background if window was hidden}
           Paint_Rect( xw,yw,Width,Height ) ;     { First clear to white...}
         Frame_Rect( xw,yw,Width,Height ) ;   { Then draw rectangle outline }
         PlaceData;  {actual redraw routine}
        END ; { IF }
      Next_Rect( handle,x,y,w,h ) ;
     END ; {WHILE}
    Show_Mouse ;           {OK, we can redraw the mouse,too,}
    End_Update;             {tell GEM were done}
    Set_Clip(xw,yw,width,height);
   END ;    {Do_Redraw}

PROCEDURE Print_All;  {print out the records}
 VAR P: Adrptr;
 BEGIN  {Print_All}
  IF Front=Nil THEN
   dummy:=Do_Alert('[1][Nothing to Print][OK]',1)
  ELSE BEGIN  {print it}
   Set_Mouse(M_Bee);
   LPrint(Front);
   P:=Front;
   While (P^.Next<>Nil) DO BEGIN {Traverse and Print}
    P:=P^.Next;
    LPrint(P)
   END;  {Traverse and Print}
   Set_Mouse(M_Arrow);
  END;  {print it}
 END;  {Print_All}

PROCEDURE Delete (Nnext: Adrptr);
  VAR P,Q:Adrptr;
      Deleted: Boolean;
   BEGIN {Delete}
     Deleted:=False;
     IF Front = NIL THEN
       dummy:=Do_Alert('[1][Nothing to Delete][OK]',1)
     ELSE
       IF Front^.Next=Nnext THEN
         BEGIN {Delete first element}
           Front:=Front^.Next;
           Deleted:=True;
           Numrec:=Numrec-1;
         END {Delete first element}
       ELSE
         BEGIN {Search list for element to delete}
           P:=Front;
           Q:=Front;
           WHILE (P^.NEXT<>NIL) AND (Deleted=False)
            DO
             BEGIN {Traverse and Delete}
               P:=P^.Next;
               IF P^.Next=Nnext THEN
                 BEGIN {Delete Adrs}
                   Q^.Next:=P^.Next; {skip over current element-deleted!}
                   Deleted:=True;
                   Numrec:=Numrec-1;
                   IF Top>1 THEN Top:=Top-1;
                 END {Delete Adrs}
               ELSE
                 Q:=P
             END {Traverse and Delete};
           IF Deleted=False THEN
             dummy:=Do_Alert('[1][NO SUCH ARTICLE][OK]',1)
         END  {Search list for element to delete}
   END; {Delete}

 PROCEDURE See_It(P:Adrptr ; Heading:EStr ; Srch:Boolean);
  VAR xit,match : Boolean;
      Q,R : Adrptr;
  BEGIN  {See_It}
   REPEAT
    Center_Dialog(Info);
    Obj_SetState(Info,DCancel,Normal,False);
    Obj_SetState(Info,DOK,Normal,False);
    Obj_SetState(Info,DDelete,Normal,False);
    Obj_SetState(Info,DNext,Normal,False);
    Obj_SetState(Info,DPrint,Normal,False);
    Obj_SetState(Info,DPrev,Normal,False);
    IF Heading='     INSERT      ' THEN
     BEGIN {change buttons}
      Obj_SetState(Info,DNext,Disabled,False);
      Obj_SetState(Info,DDelete,Disabled,False);
      Obj_SetState(Info,DPrev,Disabled,False);
      P^.Magazine:=TMag;
      P^.Issue:=TIssue;
     END;  {change buttons}
    Set_DText(Info,DTitle,Heading,System_Font,TE_Center);  {put in title}
    Set_DText(Info,DArticle,P^.Article,System_Font,TE_Center);{update fields}
    Set_DText(Info,DAuthor,P^.Author,System_Font,TE_Center);
    Set_DText(Info,DMag,P^.Magazine,System_Font,TE_Center);
    Set_DText(Info,DIssue,P^.Issue,System_Font,TE_Center);
    Set_DText(Info,DPage,P^.Page,System_Font,TE_Center);
    Set_DText(Info,DType,P^.Tipe,System_Font,TE_Center);
    Set_DText(Info,DLang,P^.Lnguage,System_Font,TE_Center);
    Set_DText(Info,DDescr1,P^.Descr1,System_Font,TE_Center);
    Set_DText(Info,DDescr2,P^.Descr2,System_Font,TE_Center);
    Set_DText(Info,DDescr3,P^.Descr3,System_Font,TE_Center);
    Set_DText(Info,DDescr4,P^.Descr4,System_Font,TE_Center);
    pushed:= Do_Dialog(Info,DArticle);
    IF (pushed<>DCancel) AND (pushed<>DDelete) THEN
     BEGIN  {Get information}
      Get_DEdit(Info,DArticle,Dumstring); {put the edited fields in the}
      P^.Article:=Dumstring;
      Get_DEdit(Info,DAuthor,Dumstring);
      P^.Author:=Dumstring;
      Get_DEdit(Info,DMag,Dumstring);  {proper strings}
      P^.Magazine:=Dumstring;
      TMag:=Dumstring;
      Get_DEdit(Info,DIssue,Dumstring);
      P^.Issue:=Dumstring;
      TIssue:=Dumstring;
      Get_DEdit(Info,DPage,Dumstring);
      P^.Page:=Dumstring;
      Get_DEdit(Info,DType,Dumstring);
      P^.Tipe:=Dumstring;
      Get_DEdit(Info,DLang,Dumstring);
      P^.Lnguage:=Dumstring;
      Get_DEdit(Info,DDescr1,Dumstring);
      P^.Descr1:=Dumstring;
      Get_DEdit(Info,DDescr2,Dumstring);
      P^.Descr2:=Dumstring;
      Get_DEdit(Info,DDescr3,Dumstring);
      P^.Descr3:=Dumstring;
      Get_DEdit(Info,DDescr4,Dumstring);
      P^.Descr4:=Dumstring;
     END;    {Get Information}
    IF pushed=DDelete THEN
     BEGIN  {delete element}
      dum:=Do_Alert('[3][DELETE RECORD|Are you sure?][ YES | NO ]',0);
      IF dum=1 THEN
       Delete(P^.Next)
     END;    {delete element}
    IF pushed=DPrint THEN
     LPrint(P);
    End_Dialog(Info);
    IF (pushed=DNext) THEN BEGIN {Next}
     P:=P^.Next;
     IF (Srch=True) THEN BEGIN {find next match}
      xit:=False;
      LOOP
       IF (P=NIL) THEN xit:=True;
       IF (P<>NIL) THEN
        CASE Nst OF
         0:
         IF ((Pos(Nname,P^.Article)<>0) AND (Selection=1)) OR
          ((Pos(Nname,P^.Page)<>0) AND (Selection=2)) OR
          ((Pos(Nname,P^.Descr1)<>0) AND (Selection=3)) OR
          ((Pos(Nname,P^.Magazine)<>0) AND (Selection=4)) OR
          ((Pos(Nname,P^.Author)<>0) AND (Selection=5)) OR
          ((Pos(Nname,P^.Tipe)<>0) AND (Selection=6)) OR
          ((Pos(Nname,P^.Lnguage)<>0) AND (Selection=7)) THEN
         xit:=True;
         1:
         IF ((Pos(Nname,P^.Article)=0) AND (Selection=1)) OR
          ((Pos(Nname,P^.Page)=0) AND (Selection=2)) OR
          ((Pos(Nname,P^.Descr1)=0) AND (Selection=3)) OR
          ((Pos(Nname,P^.Magazine)=0) AND (Selection=4)) OR
          ((Pos(Nname,P^.Author)=0) AND (Selection=5)) OR
          ((Pos(Nname,P^.Tipe)=0) AND (Selection=6)) OR
          ((Pos(Nname,P^.Lnguage)=0) AND (Selection=7)) THEN
         xit:=True;
        END; {Case}
       EXIT IF xit=True;
       P:=P^.Next;
      END; {Loop}
     END; {find next match}
    END; {Next}
    IF (pushed=DPrev) THEN BEGIN {Previous}
     IF P=Front THEN P:=NIL;
     IF (P<>NIL) AND (srch=False) THEN BEGIN {back up one}
      Q:=Front;  R:=Front; match:=True;
      REPEAT
       R:=R^.Next;
       IF R<>P THEN Q:=R;
      UNTIL (R=P);
      P:=Q;  {point P to previous record}
     END;  {back up one}
     IF (P<>NIL) AND (srch=True) THEN BEGIN {find prev. match}
      Q:=Front;  R:=Front;  match:=False;
      REPEAT
       xit:=False;
       LOOP
        CASE Nst OF
         0:
         IF ((Pos(Nname,R^.Article)<>0) AND (Selection=1)) OR
          ((Pos(Nname,R^.Page)<>0) AND (Selection=2)) OR
          ((Pos(Nname,R^.Descr1)<>0) AND (Selection=3)) OR
          ((Pos(Nname,R^.Magazine)<>0) AND (Selection=4)) OR
          ((Pos(Nname,R^.Author)<>0) AND (Selection=5)) OR
          ((Pos(Nname,R^.Tipe)<>0) AND (Selection=6)) OR
          ((Pos(Nname,R^.Lnguage)<>0) AND (Selection=7)) THEN
         xit:=True;
         1:
         IF ((Pos(Nname,R^.Article)=0) AND (Selection=1)) OR
          ((Pos(Nname,R^.Page)=0) AND (Selection=2)) OR
          ((Pos(Nname,R^.Descr1)=0) AND (Selection=3)) OR
          ((Pos(Nname,R^.Magazine)=0) AND (Selection=4)) OR
          ((Pos(Nname,R^.Author)=0) AND (Selection=5)) OR
          ((Pos(Nname,R^.Tipe)=0) AND (Selection=6)) OR
          ((Pos(Nname,R^.Lnguage)=0) AND (Selection=7)) THEN
         xit:=True;
        END; {Case}
        EXIT IF xit=True;
        R:=R^.Next;
       END;  {Loop}
       IF R<>P THEN BEGIN {again}
        Q:=R;  R:=R^.Next;
        xit:=False;
        match:=True; {found match before P}
       END;  {again}
      UNTIL (R=P);
      IF (match=True) THEN BEGIN {match found}
       P:=Q;  {update pointer}
      END  {match found}
      ELSE P:=NIL;
     END; {find previous match}
    END; {Previous}
   UNTIL ((pushed<>DNext) AND (pushed<>DPrint) AND (pushed<>DPrev)) OR (P=NIL);
  END; {See_It}

 PROCEDURE Select_Print(P:Adrptr);
   VAR xit: Boolean;
   BEGIN {Select_Print}
    REPEAT
     LPrint(P);
     P:=P^.Next;
     xit:=False;
     LOOP
      IF (P=NIL) THEN xit:=True;
      IF (P<>NIL) THEN
       CASE Nst OF
        0:
        IF ((Pos(Nname,P^.Article)<>0) AND (Selection=1)) OR
         ((Pos(Nname,P^.Page)<>0) AND (Selection=2)) OR
         ((Pos(Nname,P^.Descr1)<>0) AND (Selection=3)) OR
         ((Pos(Nname,P^.Magazine)<>0) AND (Selection=4)) OR
         ((Pos(Nname,P^.Author)<>0) AND (Selection=5)) OR
         ((Pos(Nname,P^.Tipe)<>0) AND (Selection=6)) OR
         ((Pos(Nname,P^.Lnguage)<>0) AND (Selection=7)) THEN
        xit:=True;
        1:
        IF ((Pos(Nname,P^.Article)=0) AND (Selection=1)) OR
         ((Pos(Nname,P^.Page)=0) AND (Selection=2)) OR
         ((Pos(Nname,P^.Descr1)=0) AND (Selection=3)) OR
         ((Pos(Nname,P^.Magazine)=0) AND (Selection=4)) OR
         ((Pos(Nname,P^.Author)=0) AND (Selection=5)) OR
         ((Pos(Nname,P^.Tipe)=0) AND (Selection=6)) OR
         ((Pos(Nname,P^.Lnguage)=0) AND (Selection=7)) THEN
        xit:=True;
       END; {Case}
      EXIT IF xit=True;
      P:=P^.Next;
     END; {Loop}
    UNTIL (P=NIL);
   END; {Select_Print}

 PROCEDURE Print_Some;
  VAR printed : Boolean;
      P : Adrptr;
  BEGIN {Print_Some}
   printed:=False;
   IF Front=NIL THEN
    dummy:=Do_Alert('[1][Nothing to Print][ OK ]',1)
   ELSE BEGIN {Something to print}
    Set_Mouse(M_Bee);
    CASE Nst OF
     0:
     IF ((Pos(Nname,Front^.Article)<>0) AND (Selection=1)) OR
      ((Pos(Nname,Front^.Page)<>0) AND (Selection=2)) OR
      ((Pos(Nname,Front^.Descr1)<>0) AND (Selection=3)) OR
      ((Pos(Nname,Front^.Magazine)<>0) AND (Selection=4)) OR
      ((Pos(Nname,Front^.Author)<>0) AND (Selection=5)) OR
      ((Pos(Nname,Front^.Tipe)<>0) AND (Selection=6)) OR
      ((Pos(Nname,Front^.Lnguage)<>0) AND (Selection=7)) THEN
      BEGIN {print first element}
       Select_Print(Front);
       printed:=True;
      END; {print first element}
     1:
     IF ((Pos(Nname,Front^.Article)=0) AND (Selection=1)) OR
      ((Pos(Nname,Front^.Page)=0) AND (Selection=2)) OR
      ((Pos(Nname,Front^.Descr1)=0) AND (Selection=3)) OR
      ((Pos(Nname,Front^.Magazine)=0) AND (Selection=4)) OR
      ((Pos(Nname,Front^.Author)=0) AND (Selection=5)) OR
      ((Pos(Nname,Front^.Tipe)=0) AND (Selection=6)) OR
      ((Pos(Nname,Front^.Lnguage)=0) AND (Selection=7)) THEN
      BEGIN {print first element}
       Select_Print(Front);
       printed:=True;
      END; {print first element}
    END; {Case}
    IF (printed=False) THEN BEGIN {search list for element to print}
     P:=Front;
     WHILE (P^.Next<>NIL) AND (printed=False) DO BEGIN {Traverse}
      P:=P^.Next;
       CASE Nst OF
        0:
        IF ((Pos(Nname,P^.Article)<>0) AND (Selection=1)) OR
         ((Pos(Nname,P^.Page)<>0) AND (Selection=2)) OR
         ((Pos(Nname,P^.Descr1)<>0) AND (Selection=3)) OR
         ((Pos(Nname,P^.Magazine)<>0) AND (Selection=4)) OR
         ((Pos(Nname,P^.Author)<>0) AND (Selection=5)) OR
         ((Pos(Nname,P^.Tipe)<>0) AND (Selection=6)) OR
         ((Pos(Nname,P^.Lnguage)<>0) AND (Selection=7)) THEN
         BEGIN {print current element}
          Select_Print(P);
          printed:=True;
         END; {print current element}
        1:
        IF ((Pos(Nname,P^.Article)=0) AND (Selection=1)) OR
         ((Pos(Nname,P^.Page)=0) AND (Selection=2)) OR
         ((Pos(Nname,P^.Descr1)=0) AND (Selection=3)) OR
         ((Pos(Nname,P^.Magazine)=0) AND (Selection=4)) OR
         ((Pos(Nname,P^.Author)=0) AND (Selection=5)) OR
         ((Pos(Nname,P^.Tipe)=0) AND (Selection=6)) OR
         ((Pos(Nname,P^.Lnguage)=0) AND (Selection=7)) THEN
         BEGIN {print current element}
          Select_Print(P);
          printed:=True;
         END; {print current element}
       END; {Case}
     END; {Traverse}
     IF printed=False THEN
      dummy:=Do_Alert('[1][NO SUCH ARTICLE][ OK ]',1);
    END; {search list for element to print}
   Set_Mouse(M_Arrow);
   END; {Something to print}
  END; {Print_Some}

 PROCEDURE View;
   VAR P: Adrptr;
    Viewed: Boolean;
   BEGIN {View}
    Viewed:= False;
    IF Front= Nil THEN
     BEGIN  {nothing to see}
      dummy:=Do_Alert('[1][Nothing to View][OK]',1);
     END  {nothing to see}
     ELSE BEGIN {something to see}
      CASE Nst OF
       0:
       IF ((Pos(Nname,Front^.Article)<>0) AND (Selection=1)) OR
        ((Pos(Nname,Front^.Page)<>0) AND (Selection=2)) OR
        ((Pos(Nname,Front^.Descr1)<>0) AND (Selection=3)) OR
        ((Pos(Nname,Front^.Magazine)<>0) AND (Selection=4)) OR
        ((Pos(Nname,Front^.Author)<>0) AND (Selection=5)) OR
        ((Pos(Nname,Front^.Tipe)<>0) AND (Selection=6)) OR
        ((Pos(Nname,Front^.Lnguage)<>0) AND (Selection=7)) THEN
        BEGIN {View first element}
         See_It(Front,'  VIEW/CHG/DEL   ',True);
          Viewed:= True
        END;  {View first element}
       1:
       IF ((Pos(Nname,Front^.Article)=0) AND (Selection=1)) OR
        ((Pos(Nname,Front^.Page)=0) AND (Selection=2)) OR
        ((Pos(Nname,Front^.Descr1)=0) AND (Selection=3)) OR
        ((Pos(Nname,Front^.Magazine)=0) AND (Selection=4)) OR
        ((Pos(Nname,Front^.Author)=0) AND (Selection=5)) OR
        ((Pos(Nname,Front^.Tipe)=0) AND (Selection=6)) OR
        ((Pos(Nname,Front^.Lnguage)=0) AND (Selection=7)) THEN
        BEGIN {View first element}
         See_It(Front,'  VIEW/CHG/DEL   ',True);
          Viewed:= True;
        END;  {View first element}
      END;  {Case}
      IF (Viewed=False) THEN BEGIN  {search list for element to view}
        P:= Front;
        WHILE (P^.Next<>NIL) AND (Viewed=False) DO
         BEGIN {Traverse and view}
          P:=P^.Next;
          CASE Nst OF
           0:
           IF ((Pos(Nname,P^.Article)<>0) AND (Selection=1)) OR
            ((Pos(Nname,P^.Page)<>0) AND (Selection=2)) OR
            ((Pos(Nname,P^.Descr1)<>0) AND (Selection=3)) OR
            ((Pos(Nname,P^.Magazine)<>0) AND (Selection=4)) OR
            ((Pos(Nname,P^.Author)<>0) AND (Selection=5)) OR
            ((Pos(Nname,P^.Tipe)<>0) AND (Selection=6)) OR
            ((Pos(Nname,P^.Lnguage)<>0) AND (Selection=7)) THEN
            BEGIN {View current element}
             See_It(P,'  VIEW/CHG/DEL   ',True);
             Viewed:= True
            END;  {View current element}
           1:
           IF ((Pos(Nname,P^.Article)=0) AND (Selection=1)) OR
            ((Pos(Nname,P^.Page)=0) AND (Selection=2)) OR
            ((Pos(Nname,P^.Descr1)=0) AND (Selection=3)) OR
            ((Pos(Nname,P^.Magazine)=0) AND (Selection=4)) OR
            ((Pos(Nname,P^.Author)=0) AND (Selection=5)) OR
            ((Pos(Nname,P^.Tipe)=0) AND (Selection=6)) OR
            ((Pos(Nname,P^.Lnguage)=0) AND (Selection=7)) THEN
            BEGIN {View current element}
             See_It(P,'  VIEW/CHG/DEL   ',True);
             Viewed:= True;
            END;  {View current element}
          END;  {Case}
         END; {Traverse and view}
          IF Viewed=False THEN
           BEGIN  {not there}
            dummy:=Do_Alert('[1][NO SUCH ARTICLE][OK]',1);
           END    {not there}
       END;  {search list for element to view}
     END; {something to see}
   END; {View}

  PROCEDURE Setup;
  { Put the window on the screen}
   BEGIN {Setup}
     Wind_name:=' Madam Librarian ';
     Window:=New_Window(G_Name|G_Close|G_Move|G_UpArrow|G_DnArrow|G_VSlide,
             wind_name,0,0,0,0);
     Open_Window(window,0,0,0,0);
     Work_Rect(window,xw,yw,width,height);
     Wind_Set(window,WF_VSlide,1,0,0,0);
     Wind_Set(window,WF_VSlSize,1000,0,0,0)
   END;  {Setup}

  PROCEDURE Insert(Adrs: Adrptr);
   VAR P,Q:Adrptr;
       insrt:Boolean;
   BEGIN {Insert}
    insrt:=False;  {not inserted yet}
    Adrs^.Next:=NIL;
    IF Front=NIL THEN BEGIN  {begin the list}
     Front:=Adrs;
     insrt:=True;
     Numrec:=Numrec+1;
     Pp:=Front;
    END;  {begin the list}
    IF (Pp^.Article <= Adrs^.Article) AND (insrt=FALSE) THEN BEGIN {next}
     Pp^.Next:=Adrs;  {attach at end}
     Pp:=Adrs;
     insrt:=True;
     Numrec:=Numrec+1;
    END;  {next}
    IF (insrt=False) THEN BEGIN  {put in}
     IF (Front^.Article>Adrs^.Article) AND (insrt=False) THEN BEGIN {front}
      Adrs^.Next:=Front;
      Front:=Adrs;
      insrt:=True;
      Numrec:=Numrec+1;
     END; {front}
     IF (Front^.Article=Adrs^.Article) AND (insrt=False) THEN
      IF Front^.Author>Adrs^.Author THEN BEGIN {same-insert at front}
       Adrs^.Next:=Front;
       Front:=Adrs;
       insrt:=True;
       Numrec:=Numrec+1;
      END;  {same-insert at front}
     IF insrt=False THEN BEGIN {insert in middle}
      P:=Front;
      Q:=Front;
      WHILE (P^.Next<>NIL) AND (P=Q) DO BEGIN {Traverse}
       P:=P^.Next;
       IF P^.Article>Adrs^.Article THEN BEGIN {attach}
        Q^.Next:=Adrs;
        Adrs^.Next:=P;
        insrt:=True;
        Numrec:=Numrec+1;
       END; {attach}
       IF P^.Article=Adrs^.Article THEN
        IF P^.Author>Adrs^.Author THEN BEGIN {same-attach}
         Q^.Next:=Adrs;
         Adrs^.Next:=P;
         insrt:=True;
         Numrec:=Numrec+1;
        END; {same-attach}
       IF insrt=False THEN
        Q:=P
      END;  {Traverse}
      IF (P^.Next=NIL)AND(P^.Article<=Adrs^.Article)AND(insrt=False) THEN BEGIN
       P^.Next:=Adrs; {attach at end}
       Pp:=Adrs;
       Numrec:=Numrec+1;
      END;
     END;  {insert in middle}
    END; {put in}
   END; {Insert}

 PROCEDURE Readfile;
  VAR Indx: Integer;
      Adrs: Adrptr;
  BEGIN {Readfile}
   RESET(Adrfile,Filename);
   Set_Mouse(M_Bee);
   WHILE NOT EOF(Adrfile) DO
    BEGIN {Read Address}
     New(Adrs);
     Readln(Adrfile,Adrs^.Article);
     Readln(Adrfile,Adrs^.Author);
     Readln(Adrfile,Adrs^.Magazine);
     Readln(Adrfile,Adrs^.Issue);
     Readln(Adrfile,Adrs^.Page);
     Readln(Adrfile,Adrs^.Tipe);
     Readln(Adrfile,Adrs^.Lnguage);
     Readln(Adrfile,Adrs^.Descr1);
     Readln(Adrfile,Adrs^.Descr2);
     Readln(Adrfile,Adrs^.Descr3);
     Readln(Adrfile,Adrs^.Descr4);
     Insert(Adrs)
    END; {Read Address}
    Set_Mouse(M_Arrow)
  END; {Readfile}

PROCEDURE Writefile;
  VAR P: Adrptr;
      Indx: Integer;
  BEGIN {Writefile}
    Set_Mouse(M_Bee);
    Rewrite(Adrfile,Filename);
    P:=Front;
    WHILE P<>NIL DO
      BEGIN {Write Address}
        Writeln(Adrfile,P^.Article);
        Writeln(Adrfile,P^.Author);
        Writeln(Adrfile,P^.Magazine);
        Writeln(Adrfile,P^.Issue);
        Writeln(Adrfile,P^.Page);
        Writeln(Adrfile,P^.Tipe);
        Writeln(Adrfile,P^.Lnguage);
        Writeln(Adrfile,P^.Descr1);
        Writeln(Adrfile,P^.Descr2);
        Writeln(Adrfile,P^.Descr3);
        Writeln(Adrfile,P^.Descr4);
        P:=P^.Next
      END; {Write Address}
      Set_Mouse(M_Arrow)
  END; {Writefile }

  PROCEDURE Get_Print_Options;
   VAR button,new_spaces,new_lines,new_margins,i : Integer;

   PROCEDURE Set_Number(index,n:Integer);
    VAR s : STRING[2];
    BEGIN {Set_Number}
     s[0]:=chr(2);
     s[1]:=chr(n DIV 10+ord('0'));
     s[2]:=chr(n MOD 10+ord('0'));
     Set_DText(PrOpt,index,s,System_Font,TE_Center);
    END; {Set_Number}

    PROCEDURE init_options;
     BEGIN {init_options}
      Set_Number(PDSpaces,Spces);
      Set_Number(PDLines,Lynes);
      Set_Number(PDMargins,Margins);
      new_spaces:=Spces;
      new_lines:=Lynes;
      new_margins:=Margins;
     END; {init_options}

    PROCEDURE Change_Value(index,delta:Integer;VAR value:Integer;
                           min,max:Integer);
     VAR n,x,y,w,h:Integer;
     BEGIN {Change_Value}
      n:=value+delta;
      IF (n>=min) AND (n<=max) THEN BEGIN {check range}
       value:=n; {pass back value}
       Set_Number(index,n);
       Work_Rect(0,x,y,w,h);
       Obj_Draw(PrOpt,index,0,x,y,w,h);
      END; {check range}
     END; {Change_Value}

     BEGIN {Get_Print_Options}
      Center_Dialog(PrOpt);
      init_options;
      button:=Do_Dialog(PrOpt,0);
      WHILE (button<>PDOK) AND (button<>PDCancel) DO BEGIN {chg parameters}
       IF button=PDLup THEN Change_Value(PDLines,1,new_lines,0,66)
       ELSE IF button=PDLdown THEN Change_Value(PDLines,-1,new_lines,0,66)
       ELSE IF button=PDSup THEN Change_Value(PDSpaces,1,new_spaces,0,80)
       ELSE IF button=PDSdown THEN Change_Value(PDSpaces,-1,new_spaces,0,80)
       ELSE IF button=PDMup THEN Change_Value(PDMargins,2,new_margins,2,60)
       ELSE IF button=PDMdown THEN Change_Value(PDMargins,-2,new_margins,2,60);
       button:=Redo_Dialog(PrOpt,0);
      END; {chg parameters}
      Obj_SetState(PrOpt,button,Normal,false); {return exit btn to normal}
      End_Dialog(PrOpt);
      IF button=PDOK THEN BEGIN {update variables}
       Lynes:=new_lines;
       Spces:=new_spaces;
       Margins:=new_margins;
      END; {update variables}
     END; {Get_Print_Options}

  PROCEDURE Adjust_Slider;
   VAR Size,Place: Integer;
   BEGIN {Adjust Slider}
    IF Numrec<=22 THEN Size:=1000
    ELSE Size:=Round((22/Numrec)*1000);
    IF (Top=1) OR (Numrec<=22) THEN Place:=1
    ELSE Place:=Round((Top/Numrec)*1000);
    Wind_Set(window,WF_VSlSize,Size,0,0,0);
    Wind_Set(window,WF_VSlide,Place,0,0,0);
   END; {Adjust Slider}

  PROCEDURE SetCheck(d1,d2,d3,d4,d5,d6,d7 : Boolean);
   BEGIN {SetCheck}
    Menu_Check(My_Menu,Aitem,d1);
    Menu_Check(My_Menu,Citem,d2);
    Menu_Check(My_Menu,Ditem,d3);
    Menu_Check(My_Menu,Mitem,d4);
    Menu_Check(My_Menu,Witem,d5);
    Menu_Check(My_Menu,Titem,d6);
    Menu_Check(My_Menu,Litem,d7);
   END; {SetCheck}

  BEGIN  {MagIndex}
   IF Init_Gem >= 0 THEN
    BEGIN
     Init_Mouse;
     Top:=1; Numrec:=0; Selection:=1; Nst:=0; Titlestatus:=0;
     linecount:=0; Spces:=0; Lynes:=2; Margins:=8;Condstatus:=0;
     Printflag:=0;  {0-Regular; 1-Summary}
     Sys_Font_Size(wchar,hchar,dummy,hhchar);
     Setup;
     Set_Up_Menus;  {set up the menus}
     Do_Redraw(window,xw,yw,width,height,True);
     Set_Up_MainDialog;
     Set_Up_NameDialog;
     Print_Opt_Dialog;
     Pathname:='\*.MGI';
     Fileselect:=True;
     Front:=NIL; Alldone:=False;
     Do_Redraw(window,xw,yw,width,height,True);
     Adjust_Slider;
     Mark(EndofHeap);
     WHILE (Alldone=False) DO BEGIN {Update list}
       {wait for button up, then down, then up again!}
      nevent:= Get_Event(E_Button,1,0,1,0,False,0,0,0,0,False,
                         0,0,0,0,msg,dum,dum,dum,mx,my,dum);
   event:= Get_Event(E_Button|E_Message|E_keyboard,1,1,1,0,False,0,0,0,0,False,
                        0,0,0,0,msg,key,dum,dum,mx,my,dum);
      nevent:= Get_Event(E_Button,1,0,1,0,False,0,0,0,0,False,
                         0,0,0,0,msg,dum,dum,dum,mx,my,dum);
      IF event&E_Message<>0 THEN BEGIN{message processing}
       IF msg[0]=WM_Closed THEN BEGIN {user wants to close window}
        Alertstring:='[1][Want to Quit?|(Saved your work?)][ Yes | No ]';
        dum:=Do_Alert(Alertstring,1);
        IF (dum=1) THEN Alldone:=True;
       END; {user wants to close window}
       IF msg[0]=WM_Moved THEN  {user wants to move window}
        BEGIN  {Move}
         Set_WSize(msg[3],msg[4],msg[5],msg[6],msg[7]);
        END;   {Move}
       IF msg[0]=WM_Topped THEN  {user wants to be front window}
        Bring_To_Front(msg[3]);
       IF msg[0]=WM_Redraw THEN {window needs redrawing}
        Do_Redraw(msg[3],msg[4],msg[5],msg[6],msg[7],True);
       IF msg[0]=WM_Arrowed THEN BEGIN {Scroll}
        IF msg[4]=0 THEN BEGIN {Page up}
         Top:=Top-22;
         IF (Top<1) THEN Top:=1;
        END; {Page up}
        IF msg[4]=1 THEN BEGIN {Page down}
         Top:=Top+22;
         IF (Top>Numrec-21) THEN Top:=Numrec-21;
        END; {Page down}
        IF msg[4]=2 THEN BEGIN {Row up}
         Top:=Top-1;
         IF (Top<1) THEN Top:=1;
        END; {Row up}
        IF msg[4]=3 THEN BEGIN {Row down}
         Top:=Top+1;
         IF (Top>Numrec-21) THEN Top:=Numrec-21;
        END; {Row down}
        Adjust_Slider;
        Do_Redraw(window,xw,yw,width,height,True);
       END; {Scroll}
       IF msg[0]=WM_VSlid THEN BEGIN {Scroll bar}
        Top:=Round((msg[4]/1000)*Numrec);
        IF Top<1 THEN Top:=1;
        IF Top>Numrec-21 THEN Top:=Numrec-21;
        Wind_Set(window,WF_VSlide,msg[4],0,0,0);
        Do_Redraw(window,xw,yw,width,height,True);
       END; {Scroll bar}
       IF msg[0]=MN_Selected THEN BEGIN  {menu processing}
        IF msg[3]=3 THEN  {About Dialog was selected}
         Do_About_Dialog;
        IF msg[3]=title1 THEN BEGIN {Menu options}
         IF (msg[4]=Regitem) AND (Printflag=1) THEN BEGIN {Select regular form}
          Printflag:=0;
          Menu_Check(My_Menu,Sumitem,False);
          Menu_Check(My_Menu,Regitem,True)
         END;  {Select regular form}
         IF (msg[4]=Sumitem) AND (Printflag=0) THEN BEGIN {Select Summary}
          Printflag:=1;
          Menu_Check(My_Menu,Sumitem,True);
          Menu_Check(My_Menu,Regitem,False)
         END;  {Select Summary}
         IF (msg[4]=Titleitem) THEN BEGIN {Titles}
          IF Titlestatus=0 THEN BEGIN {Zero}
           Titlestatus:=1;
           Menu_Check(My_Menu,Titleitem,True);
          END {Zero}
          ELSE BEGIN {One}
           Titlestatus:=0;
           Menu_Check(My_Menu,Titleitem,False);
          END; {One}
         END; {Titles}
         IF (msg[4]=Conditem) THEN BEGIN {Condensed}
          IF Condstatus=0 THEN BEGIN {Zero}
           Condstatus:=1;
           Menu_Check(My_Menu,Conditem,True);
          END {Zero}
          ELSE BEGIN {One}
           Condstatus:=0;
           Menu_Check(My_Menu,Conditem,False);
          END; {One}
         END; {Condensed}
         IF (msg[4]=Proptitem) THEN Get_Print_Options;
         IF (msg[4]=Insertitem) THEN BEGIN {Read, insert}
          New(Adrs);
          Adrs^.Article:='';
          See_It(Adrs,'     INSERT      ',False);
          IF pushed<>DCancel THEN BEGIN {Put in}
           Insert(Adrs);
           Do_Redraw(window,xw,yw,width,height,True);
           Adjust_Slider;
          END; {Put in}
         END; {Read,insert}
         IF (msg[4]=Printitem) THEN BEGIN {Print out list}
          IF Printflag=0 THEN
  Alertstring:='[2][Print out all Records|in Regular Format][OK|Cancel]'
          ELSE
  Alertstring:='[2][Print out all Records|in Summary Format][OK|Cancel]';
          dum:=Do_Alert(Alertstring,1);
          IF dum=1 THEN
           Print_All
         END; {Print out list}
         IF msg[4]=Psitem THEN BEGIN {print some}
          Center_Dialog(Search);
          Obj_SetState(Search,NDCancel,Normal,False);
          Obj_SetState(Search,NDOK,Normal,False);
          Set_DText(Search,NDName,'',System_Font,TE_Left);
          Choice:=Do_Dialog(Search,NDName);
          End_Dialog(Search);
          IF Choice<>NDCancel THEN BEGIN {print}
           Nst:=Obj_State(Search,NDNot);
           Get_DEdit(Search,NDName,Nname);
           Print_Some;
          END; {print}
         END; {print some}
         IF (msg[4]=VCDitem) THEN BEGIN {get title, view}
          Center_Dialog(Search);
          Obj_SetState(Search,NDCancel,Normal,False);
          Obj_SetState(Search,NDOK,Normal,False);
          Set_DText(Search,NDName,'',System_Font,TE_Left);
          Choice:=Do_Dialog(Search,NDName);
          End_Dialog(Search);
          IF Choice<> NDCancel THEN BEGIN {View record}
           Nst:=Obj_State(Search,NDNot);
           Get_DEdit(Search,NDName,Nname);
           View;
           Do_Redraw(window,xw,yw,width,height,True);
           Adjust_Slider;
          END;  {View Record}
         END; {get title, view}
         IF (msg[4]=Resetitem) THEN linecount:=0;
        END;  {Menu options}
        If msg[3]=title2 THEN BEGIN {Match menu items}
         IF (msg[4]=Aitem) AND (Selection<>1) THEN BEGIN {match Article}
          Selection:=1;
          SetCheck(True,False,False,False,False,False,False);
         END; {Match Article}
         IF (msg[4]=Citem) AND (Selection<>2) THEN BEGIN {match Page}
          Selection:=2;
          SetCheck(False,True,False,False,False,False,False);
         END; {Match Page}
         IF (msg[4]=Ditem) AND (Selection<>3) THEN BEGIN {match Descript.}
          Selection:=3;
          SetCheck(False,False,True,False,False,False,False);
         END; {Match Descript.}
         IF (msg[4]=Mitem) AND (Selection<>4) THEN BEGIN {match Magazine}
          Selection:=4;
          SetCheck(False,False,False,True,False,False,False);
         END; {Match Magazine}
         IF (msg[4]=Witem) AND (Selection<>5) THEN BEGIN {match Author}
          Selection:=5;
          SetCheck(False,False,False,False,True,False,False);
         END; {Match Author}
         IF (msg[4]=Titem) AND (Selection<>6) THEN BEGIN {match Type}
          Selection:=6;
          SetCheck(False,False,False,False,False,True,False);
         END; {match type}
         IF (msg[4]=Litem) AND (Selection<>7) THEN BEGIN {match language}
          Selection:=7;
          SetCheck(False,False,False,False,False,False,True);
         END; {match language}
        END; {Match menu items}
        IF msg[3]=title3 THEN BEGIN {file menu items}
         IF msg[4]=Loaditem THEN BEGIN {load}
          IF Front<>NIL THEN BEGIN {warning}
           dum:=0;
Alertstring:='[3][Warning!! Current File|Will be erased][Proceed|Cancel]';
           dum:=Do_Alert(Alertstring,1);
          END; {warning}
          IF (Front=NIL) OR (dum=1) THEN BEGIN {ok to load}
           Fileselect:=Get_In_File(Pathname,Filename);
           IF Fileselect=True THEN BEGIN {Got a name}
            RELEASE(EndOfHeap);
            Front:=NIL; Numrec:=0; Top:=1;
            Readfile;
            Do_Redraw(window,xw,yw,width,height,True);
            Adjust_Slider;
           END; {got a name}
          END; {ok to load}
         END; {load}
         IF msg[4]=Saveitem THEN
          IF Front=NIL THEN
           dum:=Do_Alert('[1][Nothing to save!][ OK ]',1)
         ELSE BEGIN {save it}
          Fileselect:=Get_In_File(Pathname,Filename);
          IF Fileselect=True THEN Writefile;
         END; {Save it}
         IF (msg[4]=Doneitem) THEN BEGIN; {all done}
          Alertstring:='[1][Want to Quit?|(Saved your work?)][ Yes | No ]';
          dum:=Do_Alert(Alertstring,1);
          IF (dum=1) THEN Alldone:=True;
         END; {all done}
        END; {file menu items}
        Menu_Normal(My_Menu,msg[3])
       END  {menu processing}
      END;  {message processing}
      IF event&E_Button<>0 THEN
       BEGIN {Button Processing}
        Work_Rect(window,xw,yw,width,height);
        Lmy:=(my-yw) DIV hchar;
        IF (Lmy>=0) AND (mx>=xw) AND (Top+Lmy<=Numrec)
        AND (Lmy<22) THEN BEGIN {valid}
         Paint_Style(Solid); Paint_Color(1); Draw_Mode(3);
         Hide_Mouse;
         Paint_Rect(xw,(Lmy-1)*hchar+yw+hhchar,width,hchar);
         Show_Mouse;
         Draw_Mode(1);
         Dp:=Front; Current:=1;
         WHILE (Current<Top+Lmy) AND (Dp<>NIL) DO BEGIN {find record}
          Current:=Current+1;
          Dp:=Dp^.Next;
         END; {find record}
         See_It(Dp,'  VIEW/CHG/DEL   ',False);
         Do_Redraw(window,xw,yw,width,height,True);
         Adjust_Slider;
        END; {Valid}
       END; {Button processing}
       IF event&E_keyboard<>0 THEN BEGIN {key processing}
        IF (key=5897) THEN BEGIN {control-I}
         New(Adrs);
         Adrs^.Article:='';
         See_It(Adrs,'     INSERT      ',False);
         IF pushed<>DCancel THEN BEGIN {Put in}
          Insert(Adrs);
          Do_Redraw(window,xw,yw,width,height,True);
          Adjust_Slider;
         END; {Put in}
        END; {control-I}
        IF (key=12054) THEN BEGIN{control-V}
         Center_Dialog(Search);
         Obj_SetState(Search,NDCancel,Normal,False);
         Obj_SetState(Search,NDOK,Normal,False);
         Set_DText(Search,NDName,'',System_Font,TE_Left);
         Choice:=Do_Dialog(Search,NDName);
         End_Dialog(Search);
         IF Choice<> NDCancel THEN BEGIN {View record}
          Nst:=Obj_State(Search,NDNot);
          Get_DEdit(Search,NDName,Nname);
          View;
          Do_Redraw(window,xw,yw,width,height,True);
          Adjust_Slider;
         END;  {View Record}
        END; {control-V}
        IF (key=18432) THEN BEGIN {Up arrow}
         Top:=Top-1;
         IF (Top<1) THEN Top:=1;
        END; {Up arrow}
        IF (key=20480) THEN BEGIN {down arrow}
         Top:=Top+1;
         IF (Top>Numrec-21) THEN Top:=Numrec-21
        END;  {down arrow}
        IF (key=18488) THEN BEGIN {Shift Up arrow}
         Top:=Top-22;
         IF (Top<1) THEN Top:=1;
        END;  {Shift Up arrow}
        IF (key=20530) THEN BEGIN {Shift down arrow}
         Top:=Top+22;
         IF (Top>Numrec-21) THEN Top:=Numrec-21
        END;  {Shift down arrow}
        IF (key=18432) OR (key=20480) OR (key=18488) OR (key=20530) THEN
         BEGIN  {window was scrolled}
          Adjust_Slider;
          Do_Redraw(window,xw,yw,width,height,True);
         END; {window was scrolled}
       END; {key processing}
     END; {Update list}
      Close_Window(window);
      Delete_Window(window);
      Erase_Menu(My_Menu);
      Delete_Menu(My_Menu);
      Exit_Gem ;
    END ;
  END. {MagIndex}

