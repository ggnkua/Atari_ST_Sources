DATA "RSC_TO_S -- Version 1.00   by Keith Baines  3rd January 1993"

'
' Program to Convert Wercs RSC and HRD files as assembler source code
' This version accepts command line file name and needs Basic 2
'

' Install as Devpac tool with the following parameters:
'
'
'




' COMPILER OPTIONS
'
' L20  - Leave 20K for the file selector and alerts
' Y+   - Don't open a window
' R32  - Need big stack for recursive Quick Sort Routine
'

REM $OPTION L20,Y+,R32

  DEFINT A-Z

  LIBRARY "GEMAES","GEMVDI"
  
  CONST TRUE=-1
  CONST FALSE=0

  COMMON SHARED TAB$,DC_B$,DC_W$,DC_L$,EQU$
  
  
  TAB$=CHR$(9)  
  DC_B$=TAB$+"DC.B"+TAB$
  DC_W$=TAB$+"DC.W"+TAB$
  DC_L$=TAB$+"DC.L"+TAB$
  EQU$=TAB$+"EQU"+TAB$

'
' Object Types
'
  
  CONST G_BOX=20
  CONST G_TEXT=21
  CONST G_BOXTEXT=22
  CONST G_IMAGE=23
  CONST G_PROGDEF=24
  CONST G_IBOX=25
  CONST G_BUTTON=26
  CONST G_BOXCHAR=27
  CONST G_STRING=28
  CONST G_FTEXT=29
  CONST G_FBOXTEXT=30
  CONST G_ICON=31
  CONST G_TITLE=32


'
' RSC file Header Entries
'
  
  CONST Version	= 0
  CONST First_Tree	= 1
  CONST First_TED	= 2
  CONST First_ICON	= 3
  CONST First_BITBLK= 4
  CONST List_FStrs	= 5
  CONST First_String= 6
  CONST First_IMG	= 7
  CONST List_FImgs	= 8
  CONST List_Trees	= 9
  CONST No_Objects	= 10
  CONST No_trees	= 11
  CONST No_TEDs	= 12
  CONST No_ICONs	= 13
  CONST No_BITBLKs	= 14
  CONST No_FStrs	= 15
  CONST No_FImgs	= 16
  CONST RSC_Length	= 17   

  DIM X(11),Y(10)

  CALL Prepare
  CALL Dump
  NewLine
  NewLine
  Comment "==== End of File ===="
  PutString ";"  
  CLOSE #1

  PRINT
  GetAnyKey FALSE
  STOP -1


'
' Get the input file name and load resource
' and header files.
'

SUB Prepare
   STATIC P$,F$,F2$,dummy,T,N0$,P0$,CmdFlag
   
   IF COMMAND$<>"" THEN
     CmdFlag=TRUE
 		 F$=COMMAND$
 		 IF RINSTR(F$,".")<=RINSTR(F$,"\") THEN
 		   F$=F$+".RSC"
 		 END IF
 	 ELSE
 	   CmdFlag=FALSE
     P$="A:\*.RSC"
     F$=FNGetFile$("Select Input File",P$,"")
     IF F$="" THEN STOP -1
   END IF

   IF RIGHT$(F$,4)<>".RSC" THEN
     ErrorQuit "[ | File type must | be .RSC | ]"
   END IF

   F$=LEFT$(F$,LEN(F$)-3)
   
   IF NOT FEXISTS(F$+"RSC") THEN
      ErrorQuit "[ | File "+N0$+"RSC | not found | ]"
   END IF
   
   IF CmdFlag THEN
     F2$=F$+"RS"
   ELSE
     T=RINSTR(F$,"\")
     P0$=LEFT$(F$,T)+"*."
     N0$=MID$(F$,T+1)
     F2$=FNGetFile$("Enter Name of Output File",P0$+"RS",N0$+"RS")
   END IF

   IF F2$="" THEN STOP -1

   IF FEXISTS(F2$) THEN
      T=RINSTR(F2$,"\")
      ContinueCheck "[ | Overwrite existing | file "+MID$(F2$,T+1)+" ? ]"
   END IF

   PrepOutput F2$

   LoadResource F$+"RSC"

   Do_Header_File F$+"HRD"

   NewLine

   MainTitle "Resource data from file "+F$+"RSC"

END SUB



'
' Read .HRD file, save tree, free string and free image names
'
SUB Do_Header_File(FH$)
   SHARED TreeNames$(),FreeStrNames$(),FreeImgNames$()
   SHARED RSC_buffer()

   LOCAL VERS,LANG,TYPE,T_Index,O_Index,NAM$,dummy

   DIM TreeNames$(RSC_buffer(No_Trees))
   DIM FreeStrNames$(RSC_buffer(No_FStrs))
   DIM FreeImgNames$(RSC_buffer(No_FImgs))
   
   IF NOT FEXISTS(FH$) THEN
      PRINT " ***"
      PRINT " *** No Header File"
      PRINT " ***"
      EXIT SUB
   END IF
   
   OPEN FH$ FOR INPUT AS #2
   
   PRINT " ***"
   PRINT " ***  Reading Header File: "+FH$

   Get_Header VERS,0,LANG,0,0,0,0
   IF VERS<>1 THEN
      PRINT " ***  Wrong version number - not using file"
      PRINT " ***"
      EXIT SUB
   END IF
   IF LANG<>16 THEN
      PRINT " ***  Not an assembly language header file - not used"
      PRINT " ***"
      EXIT SUB
   END IF

   PRINT " ***"

   DO
      GET_DATA TYPE,0,T_Index,O_Index,NAM$
      SELECT CASE TYPE
         CASE 0,1
            TreeNames$(T_Index)=NAM$
         CASE 2,3
            FreeStrNames$(T_Index)=NAM$
         CASE 4
            FreeImgNames$(T_Index)=NAM$
         CASE 6
            EXIT LOOP
         CASE ELSE
            :
      END SELECT
   LOOP
   NewLine
   CLOSE #2
END SUB
   
   
'
' Read header record from .HRD header file
'
SUB Get_Header(V,N,L,S,C,Z,T)
   LOCAL T$
   T$=INPUT$(8,#2)
   V=CVI(MID$(T$,1,2))
   N=ASC(MID$(T$,3,1))
   L=ASC(MID$(T$,4,1))
   S=ASC(MID$(T$,5,1))
   C=ASC(MID$(T$,6,1))
   Z=ASC(MID$(T$,7,1))
   T=ASC(MID$(T$,8,1))
END SUB


'
' Read data or EOF record from .HRD file
'
SUB Get_Data(TYP,T,TI,OI,N$)
   LOCAL T$
   T$=INPUT$(6,#2)
   TYP=ASC(MID$(T$,1,1))
   T=ASC(MID$(T$,2,1))
   TI=CVI(MID$(T$,3,2))
   OI=CVI(MID$(T$,5,2))
   N$=""
   IF TYP <>6 THEN
      T$=INPUT$(1,#2)
      DO UNTIL T$=CHR$(0)
         N$=N$+T$
         T$=INPUT$(1,#2)
      LOOP
   END IF
END SUB





'
' Open output file and write header information
'

SUB PrepOutput(F$)
   STATIC T$
   SHARED Display_Flag

   OPEN F$ FOR OUTPUT AS #1
   Display_Flag = (1=form_alert(1,"[2][ | ECHO Output to Screen | ][ YES | NO ]"))

   RESTORE
   READ T$

   WINDOW OPEN 2," "+T$+" ",PEEKW(SYSTAB+58),PEEKW(SYSTAB+60),PEEKW(SYSTAB+62),PEEKW(SYSTAB+64),1
   CLS
   MOUSE -1

   RESTORE
   READ T$
   Comment T$

   Comment ""
   Comment MID$(DATE$,4,3)+MID$(DATE$,1,3)+MID$(DATE$,7)

   NewLine
   PutDefn "G_BOX",20
   PutDefn "G_TEXT",21
   PutDefn "G_BOXTEXT",22
   PutDefn "G_IMAGE",23
   PutDefn "G_PROGDEF",24
   PutDefn "G_IBOX",25
   PutDefn "G_BUTTON",26
   PutDefn "G_BOXCHAR",27
   PutDefn "G_STRING",28
   PutDefn "G_FTEXT",29
   PutDefn "G_FBOXTEXT",30
   PutDefn "G_ICON",31
   PutDefn "G_TITLE",32
   NewLine
   PutDefn "NONE",0
   PutDefn "SELECTABLE",1
   PutDefn "DEFAULT",2
   PutDefn "EXIT",4
   PutDefn "EDITABLE",8
   PutDefn "RBUTTON",16
   PutDefn "LASTOB",32
   PutDefn "TOUCHEXIT",64
   PutDefn "HIDDEN",128
   PutDefn "INDIRECT",256
   NewLine
   PutDefn "NORMAL",0
   PutDefn "SELECTED",1
   PutDefn "CROSSED",2
   PutDefn "CHECKED",4
   PutDefn "DISABLED",8
   PutDefn "OUTLINED",16
   PutDefn "SHADOWED",32
   NewLine
   
   
END SUB

SUB PutDefn(C$,V)
   PutString C$+EQU$+FNNum$(V)
   NewLine
END SUB




'
' Load Resource file into Buffer
'

SUB LoadResource(F$)
   SHARED RSC_Buffer()
   STATIC T$,I,L,L&
   
   OPEN F$ FOR INPUT AS #2
   T$=INPUT$(36,#2)
   CLOSE #2
   
   L=CVI(MID$(T$,35,2))\2+1
   
   IF 2&*L+10000&>FRE("") THEN
      ErrorQuit " File Too Large | To Load "
   END IF
   
   PRINT " ***"
   PRINT " ***  Reading Resource File: "+F$
   PRINT " ***"


   DIM RSC_Buffer(L)
   
   BLOAD F$,VARPTR(RSC_Buffer(0))
   
END SUB
   
   
   
   
   



'
' Outputs RSC data as assembler.
'

SUB Dump
   STATIC I,T
   LOCAL Order(9,1)
   SHARED RSC_Buffer()

' Decide order for subroutines to dump file in correct order
   
   Order(0,0)=RSC_buffer(List_Trees)
   Order(1,0)=RSC_buffer(List_FStrs)
   Order(2,0)=RSC_buffer(List_FImgs)
   Order(3,0)=RSC_buffer(First_Tree)
   Order(4,0)=RSC_buffer(First_TED)
   Order(5,0)=RSC_buffer(First_BITBLK)
   Order(6,0)=RSC_buffer(First_ICON)
   Order(7,0)=RSC_buffer(First_String)
   Order(8,0)=RSC_buffer(First_IMG)
   Order(9,0)=RSC_buffer(RSC_Length)
   
   FOR I=0 TO 9
      Order(I,1)=I
   NEXT I
   
   QSORT 10,1,Order()

   DumpHeader
   
   FOR I=0 TO 8
      T=Order(I,1)
      SELECT CASE T
         CASE 0
            ListTrees
         CASE 1
            ListFreeStrings 
         CASE 2
            ListFreeImages
         CASE 3
            DumpObjects
         CASE 4
            DumpTED
         CASE 5
            DumpBITBLK
         CASE 6
            DumpICON
         CASE 7
            DumpStrings
         CASE 8
            DumpImages
      END SELECT
   NEXT I
   
END SUB
   
  

SUB DumpHeader
   
   SubTitle "RSC File Header"
   
   HeaderLine1 Version,      "RSC File Version"
   HeaderLine2 First_Tree,   "Start of Objects"
   HeaderLine2 First_TED,    "Start of TEDINFOs"
   HeaderLine2 First_ICON,   "Start of ICONBLKs"
   HeaderLine2 First_BITBLK, "Start of BITBLKs"
   HeaderLine2 List_FStrs,   "List of free strings"
   HeaderLine2 First_String, "Start of string data"
   HeaderLine2 First_IMG,    "Start of bit image data"
   HeaderLine2 List_FImgs,   "List of free images"
   HeaderLine2 List_Trees,   "List of Trees"
   HeaderLine1 No_Objects,   "Number of Objects"
   HeaderLine1 No_trees,     "Number of Trees"
   HeaderLine1 No_TEDs,      "Number of TEDINFOs"
   HeaderLine1 No_ICONs,     "Number of ICONBLKs"
   HeaderLine1 No_BITBLKs,   "Number of BITBLKs"
   HeaderLine1 No_FStrs,     "Number of Free STrings"
   HeaderLine1 No_FImgs,     "Number of Free Images"
   HeaderLine2 RSC_Length,   "RSC File Length"
   
   NewLine
END SUB

SUB HeaderLine1(I,T$)
   SHARED RSC_buffer()
   PutString DC_W$+FNNum$(RSC_Buffer(I))+TAB$+TAB$+T$
   NewLine
END SUB


SUB HeaderLine2(I,T$)
   SHARED RSC_buffer()
   PutString DC_W$+FNHexNum$(RSC_Buffer(I))+TAB$+TAB$+T$
   NewLine
END SUB




SUB ListTrees
   SHARED RSC_buffer(),TreeNames$()
   SubTitle "List Of Trees"
   DumpList RSC_buffer(List_Trees),TreeNames$(),RSC_buffer(No_trees),"tr_"
END SUB


SUB ListFreeStrings
   SHARED RSC_buffer(),FreeStrNames$()
   IF RSC_buffer(No_FStrs)>0 THEN
      SubTitle "List Of Free Strings"
      DumpList RSC_buffer(List_FStrs),FreeStrNames$(),RSC_buffer(No_FStrs),"fs_"
   END IF
END SUB

SUB ListFreeImages
   SHARED RSC_buffer(),FreeImgNames$()
   IF RSC_buffer(No_FImgs)>0 THEN
      SubTitle "List Of Free IMAGES"
      DumpList RSC_buffer(List_FImgs),FreeImgNames$(),RSC_buffer(No_FImgs),"fi_"
   END IF
END SUB


SUB DumpList(F,Nam$(1),N,Prefix$)
   SHARED RSC_buffer()
   STATIC I

   PutString "LIST_"+HEX$(F)

   IF N=0 THEN
      PutString DC_L$+"0"
      NewLine
   ELSE
      FOR I=0 TO N-1
         PutString DC_L$+Prefix$
         IF Nam$(I)="" THEN
            PutString FNNum$(I)
         ELSE
            PutString Nam$(I)
         END IF
         NewLine
      NEXT I
   END IF
   NewLine
END SUB

SUB DumpObjects
   SHARED RSC_buffer()
   SHARED TreeNames$()
   STATIC T,I,TYP,NEWTREE,F,N,OBJCOUNT,X
   
   F=RSC_buffer(First_Tree)\2
   N=RSC_buffer(No_Objects)
   
   NEWTREE=TRUE
   OBJCOUNT=0
   T=F
   SubTitle "Trees"
   FOR I=1 TO N
      IF NEWTREE THEN
         X=FNFindTree(T)
         IF X>=0 THEN
            IF TreeNames$(X)<>"" THEN
               PutString "tr_"+TreeNames$(X)
            ELSE
               PutString "tr_"+FNNum$(X)
            END IF
            NewLine
         END IF
         NEWTREE=FALSE
      ELSE
         PutString ";  Object "+FNNum$(OBJCOUNT)
         NewLine
      END IF
      INCR OBJCOUNT
      TYP=RSC_buffer(T+3)
      PutString DC_W$
      PutString FNNum$(RSC_buffer(T))+","
      PutString FNNum$(RSC_buffer(T+1))+","
      PutString FNNum$(RSC_buffer(T+2))+","
      DumpType TYP
      PutString DC_W$+FNFlag$(RSC_buffer(T+4))
      NewLine
      PutString DC_W$+FNStatus$(RSC_buffer(T+5))
      NewLine
      SELECT CASE TYP
         CASE G_BOX,G_IBOX,G_BOXCHAR
            DumpWords T+6,2
         CASE G_BUTTON,G_STRING,G_TITLE
            PutString DC_L$+"STR_"+HEX$(RSC_buffer(T+7))
            NewLine
         CASE G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT
            PutString DC_L$+"TED_"+HEX$(RSC_buffer(T+7))
            NewLine
         CASE G_IMAGE
            PutString DC_L$+"BITBLK_"+HEX$(RSC_buffer(T+7))
            NewLine
         CASE G_ICON
            PutString DC_L$+"ICON_"+HEX$(RSC_buffer(T+7))
            NewLine
         CASE G_PROGDEF
            PutString DC_L$+"0"
            NewLine
         CASE ELSE
            DumpWords T+6,2
      END SELECT
      DumpWords T+8,4
      IF RSC_buffer(T+4) AND &H20 THEN
         NEWTREE=TRUE
         OBJCOUNT=0
         NewLine
         NewLine
      END IF
      T=T+12
   NEXT I
END SUB

DEF FNFlag$(W)
   LOCAL T$
   IF W=0 THEN
      FNFlag$="NONE"
      EXIT SUB
   ELSE
      T$=""
      IF W AND 1 THEN
         T$=T$+"+SELECTABLE"
      END IF
      IF W AND 2 THEN
         T$=T$+"+DEFAULT"
      END IF
      IF W AND 4 THEN
         T$=T$+"+EXIT"
      END IF
      IF W AND 8 THEN
         T$=T$+"+EDITABLE"
      END IF
      IF W AND 16 THEN
         T$=T$+"+RBUTTON"
      END IF
      IF W AND 32 THEN
         T$=T$+"+LASTOB"
      END IF
      IF W AND 64 THEN
         T$=T$+"+TOUCHEXIT"
      END IF
      IF W AND 128 THEN
         T$=T$+"+HIDDEN"
      END IF
      IF W AND 256 THEN
         T$=T$+"+INDIRECT"
      END IF
      IF W AND &HFE00 THEN
         T$=T$+"+"+FNHexNum$(W AND &HFE00)
      END IF
      FNFlag$=MID$(T$,2)
   END IF
END DEF

DEF FNStatus$(W)
   LOCAL T$
   IF W=0 THEN
      FNStatus$="NORMAL"
      EXIT SUB
   ELSE
      T$=""
      IF W AND 1 THEN
         T$=T$+"+SELECTED"
      END IF
      IF W AND 2 THEN
         T$=T$+"+CROSSED"
      END IF
      IF W AND 4 THEN
         T$=T$+"+CHECKED"
      END IF
      IF W AND 8 THEN
         T$=T$+"+DISABLED"
      END IF
      IF W AND 16 THEN
         T$=T$+"+OUTLINED"
      END IF
      IF W AND 32 THEN
         T$=T$+"+SHADOWED"
      END IF
      IF W AND &HFFC0 THEN
         T$=T$+"+"+FNHexNum$(W AND &HFFC0)
      END IF
      FNStatus$=MID$(T$,2)
   END IF
END DEF


SUB DumpType(TYP)
   LOCAL T
   IF TYP AND &HFF00 THEN
      PutString FNHexNum$(TYP AND &HFF00)+"+"
   END IF
   T=TYP AND &HFF
   SELECT CASE T
      CASE G_BOX
         PutString "G_BOX"
      CASE G_TEXT
         PutString "G_TEXT"
      CASE G_BOXTEXT
         PutString "G_BOXTEXT"
      CASE G_IMAGE
         PutString "G_IMAGE"
      CASE G_PROGDEF
         PutString "G_PROGDEF"+TAB$+"*** ProgDef must be patched at run-time"
         NewLine
         PutString DC_W$
      CASE G_IBOX
         PutString "G_IBOX"
      CASE G_BUTTON
         PutString "G_BUTTON"
      CASE G_BOXCHAR
         PutString "G_BOXCHAR"
      CASE G_STRING
         PutString "G_STRING"
      CASE G_FTEXT
         PutString "G_FTEXT"
      CASE G_FBOXTEXT
         PutString "G_FBOXTEXT"
      CASE G_ICON
         PutString "G_ICON"
      CASE G_TITLE
         PutString "G_TITLE"
      CASE ELSE
         PutString FNNum$(T)+TAB$+"*** ERROR - UNKNOWN TYPE ***"
   END SELECT
   NewLine
END SUB




SUB DumpTED
   SHARED RSC_buffer()
   STATIC I,T,N
   
   T=RSC_buffer(First_TED)\2
   N=RSC_buffer(No_TEDs)
   
   IF N=0 THEN EXIT SUB
   
   SubTitle "TEDINFOs"
   FOR I=1 TO N
      PutString "TED_"+HEX$(2*T)+DC_L$
      PutString "STR_"+HEX$(RSC_buffer(T+1))+","
      PutString "STR_"+HEX$(RSC_buffer(T+3))+","
      PutString "STR_"+HEX$(RSC_buffer(T+5))
      NewLine
      DumpWords T+6,8
      NewLine
      T=T+14
   NEXT I
   NewLine
END SUB
   

SUB DumpBITBLK
   SHARED RSC_buffer(),FreeImgNames$()
   STATIC T,I,J,N,X
   
   T=RSC_buffer(First_BITBLK)\2
   N=RSC_buffer(No_BITBLKs)

   IF N=0 THEN EXIT SUB

   SubTitle "BITBLKs"

   FOR I=1 TO N
   
      X=FNFindFreeImage(T)
      IF X>=0 THEN
         IF FreeImgNames$(X)<>"" THEN
            PutString "fi_"+FreeImgNames$(X)
         ELSE
            PutString "fi_"+FNNum$(X)
         END IF
         NewLine
      END IF
 
      PutString "BITBLK_"+HEX$(2*T)+DC_L$
      PutString "IMG_"+HEX$(RSC_buffer(T+1))
      NewLine
      DumpWords T+2,5
      NewLine
      T=T+7
   NEXT I
   NewLine
END SUB
   
SUB DumpICON
   SHARED RSC_buffer()
   STATIC T,I,J,N

   T=RSC_buffer(First_ICON)\2
   N=RSC_buffer(No_ICONs)
   
   IF N=0 THEN EXIT SUB

   SubTitle "ICONBLKs"

   FOR I=1 TO N
      PutString "ICON_"+HEX$(2*T)+DC_L$
      PutString "IMG_"+HEX$(RSC_buffer(T+1))+","
      PutString "IMG_"+HEX$(RSC_buffer(T+3))+","
      PutString "STR_"+HEX$(RSC_buffer(T+5))
      NewLine
      DumpWords T+6,6
      DumpWords T+12,5
      NewLine
      T=T+17
   NEXT I
   NewLine
END SUB
      
SUB DumpWords(F,N)
   SHARED RSC_buffer()
   STATIC J
   PutString DC_W$
   FOR J=0 TO N-2
      PutString FNHexNum$(RSC_buffer(F+J))+","
   NEXT J
   PutString FNHexNum$(RSC_buffer(F+N-1))
   NewLine
END SUB



      

SUB DumpStrings
   SHARED RSC_buffer()
   STATIC P&,Q&,L,Start,Finish
   
   Start=RSC_buffer(First_String)\2
   Finish=RSC_buffer(First_IMG)\2
   
   IF Start>=Finish THEN EXIT SUB

   SubTitle "String Data"
   
   P&=VARPTR(RSC_buffer(Start))
   Q&=VARPTR(RSC_buffer(Finish))
   L=2*Start
   
   
   WHILE P&<Q&
      DumpOneString P&,L
   WEND
   
END SUB



SUB DumpOneString(P&,L)
   STATIC X,FIRST,QUOTE
   SHARED FreeStrNames$(),RSC_buffer()
   
   X=FNFindFreeStr(P&)

   IF X>=0 THEN
      NewLine
      IF FreeStrNames$(X)<>"" THEN
         PutString "fs_"+FreeStrNames$(X)
      ELSE
         PutString "fs_"+FNNum$(X)
      END IF
   ELSE
      PutString "STR_"+HEX$(L)
   END IF
   
   PutString DC_B$
   FIRST=TRUE
   QUOTE=FALSE
   DO
      X=PEEKB(P&)
      IF X>=ASC(" ") AND X<>ASC("'") THEN
         IF NOT QUOTE THEN
            IF FIRST THEN
               PutString "'"
               FIRST=FALSE
            ELSE
               PutString ",'"
            END IF
            QUOTE=TRUE
         END IF
         PutString CHR$(X)
      ELSE
         IF QUOTE THEN
            PutString "'"
            QUOTE=FALSE
         END IF
         IF FIRST THEN
            FIRST=FALSE
         ELSE
            PutString ","
         END IF
         PutString FNNum$(X)
      END IF
      INCR P&
      INCR L
   LOOP UNTIL X=0
   NewLine
END SUB

DEF FNFindTree(T)
   FNFindTree=FNFindInList(2*T,List_Trees,No_Trees)
END DEF
               
DEF FNFindFreeStr(P&)
   SHARED RSC_buffer()
   FNFindFreeStr=FNFindInList(P&-VARPTR(RSC_buffer(0)),List_FStrs,No_FStrs)
END DEF
   
DEF FNFindFreeImage(P)
   FNFindFreeImage=FNFindInList(2*P,List_FImgs,No_FImgs)
END DEF
   
DEF FNFindInList(D,First,No)
   SHARED RSC_buffer()
   STATIC I,T,N

   T=RSC_buffer(First)\2+1
   N=RSC_buffer(No)-1
   
   FOR I=0 TO N
      IF RSC_buffer(T)=D THEN
         FNFindInList=I
         EXIT DEF
      END IF
      T=T+2
   NEXT I
   FNFindInList=-1
END DEF

   
      

SUB DumpImages
   SHARED RSC_buffer()
   STATIC P,X,I,W,H,N,ImgList()
   STATIC FI,NI,FB,NB
   
   FI=RSC_buffer(First_ICON)\2
   NI=RSC_buffer(No_ICONs)
   FB=RSC_buffer(First_BITBLK)\2
   NB=RSC_buffer(No_BITBLKs)
   
   IF (NI=0) AND (NB=0) THEN EXIT SUB
   
   DIM ImgList(2*NI+NB-1,2)
   
   SubTitle "Bit Image Data"
   
   N=0
   P=FI
   FOR I=1 TO NI
      ImgList(N,0)=RSC_buffer(P+1)
      ImgList(N,1)=RSC_buffer(P+11)\16
      ImgList(N,2)=RSC_buffer(P+12)
      INCR N
      ImgList(N,0)=RSC_buffer(P+3)
      ImgList(N,1)=RSC_buffer(P+11)\16
      ImgList(N,2)=RSC_buffer(P+12)
      INCR N
      P=P+17
   NEXT I
   
   P=FB
   FOR I=1 TO NB
      ImgList(N,0)=RSC_buffer(P+1)
      ImgList(N,1)=RSC_buffer(P+2)\2
      ImgList(N,2)=RSC_buffer(P+3)
      INCR N
      P=P+7
   NEXT I
   
   QSORT N,2,ImgList()
   
   FOR I=0 TO N-1
      DumpOneImage ImgList(I,0),ImgList(I,1),ImgList(I,2)
   NEXT I
   
   
END SUB

SUB DumpOneImage(P,W,H)
   SHARED RSC_buffer()
   STATIC T,I,J

   T=P\2

   Comment STR$(W*16)+" Wide by"+STR$(H)+" High"
   
   PutString "IMG_"+HEX$(P)
   FOR I=1 TO H
      PutString DC_W$
      FOR J=1 TO W-1
         PutString FNHexNum$(RSC_buffer(T))
         IF (J MOD 8 = 0) THEN
            NewLine
            PutString DC_W$
         ELSE
            PutString ","
         END IF
         INCR T
      NEXT J
      PutString FNHexNum$(RSC_buffer(T))
      INCR T
      NewLine
   NEXT I
   NewLine
END SUB


'
' Get number as string without initial space
'
DEF FNNum$(N)
   IF N<0 THEN
      FNNum$=STR$(N)
   ELSE
      FNNum$=MID$(STR$(N),2)
   END IF
END DEF

'
' Get number as Hex string with leading $ sign
'
DEF FNHexNum$(N)
   FNHexNum$="$"+HEX$(N)
END DEF



'
' Use the file selector to get a file name
' and validate it.
'   
DEF FNGetFile$(BYVAL Prompt$,VARPTR path$,filename$)
STATIC r,dummy,button
	dummy=form_alert(1,"[0][ | "+Prompt$+"  | ][OK]")
   fsel_input path$,filename$,button
   FNGetFile$=""
   IF button=0 THEN
      EXIT DEF
   ELSEIF filename$="" OR LEFT$(filename$,1)="." THEN
      dummy=form_alert(1,"[3][ A file name is required ][OK]")
      EXIT DEF
   ELSEIF INSTR(filename$,"*")>0 OR INSTR(filename$,"?")>0 THEN
      dummy=form_alert(1,"[3][ Ambiguous file name not allowed ][OK]")
      EXIT DEF
   END IF

   r=RINSTR(path$,"\")
   IF r=0 THEN
      path$=path$+"\"
      r=LEN(path$)
   END IF
   FNGetFile$=left$(path$,r)+filename$
END DEF


   
'
' Output string to screen and/or file
'
SUB PutString(S$)
   STATIC I,C$
   SHARED Display_Flag
   PRINT #1,S$;
   IF Display_Flag THEN
      FOR I=1 TO LEN(S$)
         C$=MID$(S$,I,1)
         IF C$<>TAB$ THEN
            PRINT C$;
         ELSE
            PRINT SPACE$(12 - ((POS(0)-1) MOD 12));
         END IF
      NEXT I
   END IF
END SUB

SUB MainTitle(T$)
   STATIC L
   L=LEN(T$)+6
   NewLine
   NewLine
   PutString STRING$(L,"*")
   NewLine
   PutString "** "+T$+" **"
   NewLine
   PutString STRING$(L,"*")
   NewLine
   NewLine
END SUB

SUB SubTitle(T$)
   STATIC L
   L=LEN(T$)+2
   NewLine
   NewLine
   PutString ";"+STRING$(L,"-")+";"
   NewLine
   PutString "; "+T$+" ;"
   NewLine
   PutString ";"+STRING$(L,"-")+";"
   NewLine
   NewLine
END SUB

SUB Comment(T$)
   PutString "; "+T$
   NewLine
END SUB

SUB Warn(T$)
   SHARED Display_Flag

   PRINT #1
   PRINT #1,"***"
   PRINT #1,"*** WARNING - "+T$+" ***"
   PRINT #1,"***"
   
   PRINT
   PRINT " ***"
   PRINT " *** WARNING - "+T$+" ***"
   PRINT " ***"
   
   IF Display_Flag THEN CALL GetAnyKey(TRUE)
   
END SUB
   


SUB NewLine
   SHARED Display_Flag
   PRINT #1,
   IF Display_Flag THEN
      PRINT
      IF INKEY$<>"" THEN
         WHILE INKEY$<>"":WEND
         GetAnyKey TRUE
      END IF
   END IF
END SUB

SUB GetAnyKey(F)
   STATIC K$

   PRINT "=== Press any key to continue ===";
   IF F THEN PRINT "  ([Esc] to cancel.)";
	LOCATE ,1
	

   DO
      K$=INKEY$
   LOOP UNTIL K$<>""
   
   PRINT SPACE$(60);
	LOCATE ,1

   IF F AND (K$=CHR$(27)) THEN 
      Comment "Program Cancelled - File Incomplete"
      STOP -1
   END IF
   
END SUB


   
SUB ErrorQuit(M$)
   LOCAL dummy
   dummy=form_alert(1,"[3]"+M$+"[ QUIT ]")
   STOP -1
END SUB

SUB ContinueCheck(M$)
   IF form_alert(1,"[2]"+M$+"[ CONTINUE | CANCEL ]") <> 1 THEN
      STOP -1
   END IF
END SUB



'
' Recursive Quick Sort (Adapted from K & P S/W Tools in Pascal)
' for array of image addresses and sizes
'

SUB QSORT(N,R,A(2))
   CALL RQUICK(0,N-1,R,A())
END SUB 'QSORT

SUB RQUICK(LO,HI,R,A(2))
   LOCAL I,J,PIVOT
   IF LO<HI THEN
      I=LO
      J=HI
      PIVOT=J
      DO
         WHILE (I<J) AND FNCompare(A(I,0),A(PIVOT,0))<=0
            INCR I
         WEND
         WHILE (J>I) AND FNCompare(A(J,0),A(PIVOT,0))>=0
            DECR J
         WEND
         IF (I<J) THEN
            CALL Exchange(I,J,R,A())
         END IF
      LOOP UNTIL I>=J
   
      CALL Exchange(I,HI,R,A())
   
      IF (I-LO) < (HI-J) THEN
         CALL RQUICK(LO,I-1,R,A())
         CALL RQUICK(I+1,HI,R,A())
      ELSE
         CALL RQUICK(I+1,HI,R,A())
         CALL RQUICK(LO,I-1,R,A())
      END IF
   END IF
END SUB 'RQUICK
						
DEF FNCompare(X,Y)
   
   IF X=Y THEN
      FNCompare=0
   ELSEIF X<Y THEN
      FNCompare=-1
   ELSE
      FNCompare=1
   END IF
END DEF

SUB Exchange(I,J,R,A(2))
   STATIC K
   FOR K=0 TO R
      SWAP A(I,K),A(J,K)
   NEXT K
END SUB
