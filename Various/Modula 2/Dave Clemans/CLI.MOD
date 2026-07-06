(*
    A very simple command line interface for the Atari 520ST TOS.

    Syntax is a VERY small subset of the Bourne shell supplied with
    the Unix operating system.  Specifically:

	Each command is a seperate line.
	Each command consists of several words separated by white space.
	The first word is the command name.
	If a word matches "name=value" for some name and value, it is
	    variable assignment and not considered part of the command
	    line.
	A dollar sign followed by a variable name is replaced by the
	    value of the variable.
	Single quotes protect characters from all interpretation.
	Double quotes protect characters from all interpretation EXCEPT
	    for variable replacement.
	'*' and '?' wild card characters are supported, but only in the
	    "leaf" part of the filename.
	Input and output redirection is supported to and from disk files.
	The only variables with special meaning are:
	    PATH	command search path
	    SUFFIXES	supported command types
	  The elements in the PATH and SUFFIXES list are separated
	  by commas.
	The only built-in commands are:
	    .		temporarily read commands from file
	    cd		change directory
	    echo	print arguments on screen
	    meminfo	print some memory usage info; mainly for debugging
	    pwd		print name of current directory
	    set		list defined variables
		-v 	print lines as they are read
		-x	print lines as they are executed
	    version	print CLI and GEMDOS versions
    Control-D exits from the program.

    Dave Clemans, 2/86
*)
MODULE CLI;

(* Define our alphabet *)
IMPORT ASCII;

(* Get a string package *)
IMPORT String;

(* Define our storage interface *)
IMPORT Storage;

(* Get a filesystem interface *)
FROM Streams IMPORT Stream,StreamKinds,OpenStream,CloseStream,Read8Bit,EOS;

(* Get some conversion stuff *)
FROM M2Conversions IMPORT ConvertInteger,ConvertCardinal,ConvertAddrHex,
	ConvertAddrDec;

(* Get our screen/keyboard interface *)
FROM Terminal IMPORT Read,Write,WriteLn,WriteString;

(* Get some hardware dependent stuff *)
FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, REGISTER, SETREG, CODE;

(* Get the operating system stuff we need *)
IMPORT GEMVDIbase, VDIControls, VDIEscapes,
       GEMAESbase, AESGraphics, AESApplications, AESEvents, AESMenus,
       AESForms;
IMPORT GEMDOS;

CONST
    (* Our current version... *)
    CLIVersion = "CLI Version 1.0; dgc; 3/8/86";
    GEMDOSVersion = "GEMDOS Version ";

    (* Set non-zero if this build is for a desk accessory *)
    (* If a desk accessory, AESApplications, AESEvents, AESMenus *)
    (* must be IMPORTed. *)
    DeskAccessory = 1;
    (* Currently the run time startup code must be patched for *)
    (* a desk accessory written in Modula-2 to work, since desk *)
    (* are called by the system without having any stack whatsoever *)
    (* set up.  Basically, you just no-op out everything except the *)
    (* initialization of the base page address and insert in a stack *)
    (* pointer initialization to some area of memory that should *)
    (* hopefully be free.  I use 5FFF8, so the patch is: *)
    (*		2E 7C 00 05 FF F8	*)

    MaxStack = 7168;		(* Reserve this much space for a stack *)
    MaxHeap = 4096;		(* This much space for a heap area *)

    MaxLine = 256;		(* Maximum size of a command line *)

    VarStart = '$';		(* Start of a variable reference *)
    VarDefine = '=';		(* Signifies a variable definition *)
    Space = ' ';		(* A white space character *)
    Tab = ASCII.HT;		(* Another white space character *)
    SQuote = "'";		(* Fully protected quoted string *)
    DQuote = '"';		(* Partially protected quoted string *)
    LBracket = '{';		(* Start of bracketed variable reference *)
    RBracket = '}';		(* End of bracketed variable reference *)
    DriveSep = ':';		(* Separator between drive and pathname *)
    PathSep = '\';		(* Separator between parts of pathname *)
    PartSep = ',';		(* Separator between parts of PATH,SUFFIXES *)
    SuffixSep = '.';		(* Separator between file name and suffix *)

    Prompt = "$ ";		(* Constant prompts for now *)

    (* Error messages *)
    UnClosedString = "Missing single or double quote in command line.";
    LineTooLong = "Input line is too long; maximum length is 256 characters.";
    DirNotFound = "Directory not found.";
    CmdArgsTooLong = "Command arguments are too long; maximum is 127 chars.";
    FileNotFound = "File not found.";
    FileNotExecuted = "File could not be executed.";
    FlagNotFound = "Flag to command not known.";
    NotEnoughMemory = "Not enough memory available to run command.";
    NoMatch = "No match.";
    VariableNotTerminated = "Shell variable not terminated.";

    (* Built-in commands *)
    ChangeDirectory 	= "cd";
    EchoCommand 	= "echo";
    PrintDirectory 	= "pwd";
    SetCommand 		= "set";
    SourceCommand 	= ".";
    VersionCommand 	= "version";

    (* Pre-Defined shell variables *)
    PathVarName 	= "PATH";
    PathDefault 	= ",a:,a:\bin\";
    SuffixesVarName 	= "SUFFIXES";
    SuffixesDefault 	= ".ttp,.tos,.prg,.app";

TYPE
    CharSet = SET OF CHAR;
    Line = ARRAY[0..MaxLine-1] OF CHAR;
    VarPointer = POINTER TO Variable;
    CharPointer = POINTER TO Line;
    Variable = RECORD		(* Variable definition record *)
	name: CharPointer;	(* ... The variable name *)
	value: CharPointer;	(* ... The value of the variable *)
	link: VarPointer;	(* ... Next variable record *)
    END;
    PagePointer = POINTER TO ARRAY[0..1023] OF ADDRESS;

VAR
    LineBuffer, CommandName, CommandLine: Line;
    VarTop, VarBottom: VarPointer;
    FirstIndex, LastIndex, Counter: CARDINAL;
    Result: INTEGER;
    KeepGoing: BOOLEAN;
    ReadFromFile: BOOLEAN;
    PrintLinesRead: BOOLEAN;
    PrintLinesExecuted: BOOLEAN;
    SaveCh: CHAR;
    PathPointer: CharPointer;
    SuffixesPointer: CharPointer;
    FileStream: Stream;
    oldDTAaddr: ADDRESS;
    VDIHandle: INTEGER;
    WorkIn: GEMVDIbase.VDIWorkInType;
    WorkOut: GEMVDIbase.VDIWorkOutType;
    WidthChar, HeightChar, WidthFont, HeightFont: INTEGER;
    ScreenWidth, ScreenHeight: INTEGER;
    ApplId, MenuId, EventId: INTEGER;
    MsgBuf: ARRAY[0..7] OF INTEGER;
    Dummy: INTEGER;
    BlockAddr: ADDRESS;
    StackPage, OldStackPage: PagePointer;

(* Print a standard format error message *)
PROCEDURE ErrorMessage(VAR msg: ARRAY OF CHAR; rc: INTEGER);
VAR
    buffer: Line;
BEGIN
    WriteString("CLI: ");
    WriteString(msg);
    IF (rc < 0)
    THEN
	WriteString(" Status=");
	ConvertInteger(rc,1,buffer);
	WriteString(buffer);
    END;
    WriteLn;
END ErrorMessage;

(* Read an input line from the keyboard *)
PROCEDURE ReadLine;
VAR
    ch: CHAR;
    index, position, index1: CARDINAL;

PROCEDURE BackupCursor;
BEGIN
    Write(ASCII.BS);
    Write(Space);
    Write(ASCII.BS);
    position := position-1;
END BackupCursor;

PROCEDURE BackupOverTab;
BEGIN
    (* NOTE: first "tab" character already backed up over *)
    WHILE ((position MOD 8) # 0)
    DO
	BackupCursor;
    END;
END BackupOverTab;

PROCEDURE EchoCharacter(c: CHAR);
BEGIN
    Write(c);
    position := position+1;
END EchoCharacter;

PROCEDURE EchoTab;
BEGIN
    (* NOTE: first "tab" character already written *)
    WHILE ((position MOD 8) # 0)
    DO
	EchoCharacter(Space);
    END;
END EchoTab;

BEGIN		(* ReadLine *)
    index := 0;
    position := 0;
    LOOP
	Read(ch);
	IF (ASCII.CharIsPrintable(ch) OR (ch = Tab) OR (ch = ASCII.EOT))
	THEN
	    IF (ASCII.CharIsPrintable(ch))
	    THEN
		EchoCharacter(ch);
	    ELSIF (ch = Tab)
	    THEN
		EchoCharacter(Space);
		EchoTab;
	    END;
	    LineBuffer[index] := ch;
	    index := index+1;
	END;
	IF ((ch = ASCII.CR) OR (ch = ASCII.EOT))
	THEN
	    WriteLn;
	    EXIT;
	END;
	IF (ch = ASCII.BS)
	THEN
	    index := index-1;
	    BackupCursor;
	    IF (LineBuffer[index] = Tab)
	    THEN
		BackupOverTab;
	    END;
	END;
	IF (ch = ASCII.NAK)
	THEN
	    FOR index1 := index-1 TO 0 BY -1
	    DO
		BackupCursor;
		IF (LineBuffer[index1] = Tab)
		THEN
		    BackupOverTab;
		END;
	    END;
	    index := 0;
	    position := 0;
	END;
	IF (index >= TSIZE(Line)-1)
	THEN
	    ErrorMessage(LineTooLong,0);
	    EXIT;
	END;
    END;
    LineBuffer[index] := ASCII.NUL;
END ReadLine;

(* List all the defined shell variables *)
PROCEDURE ListVariables;
VAR
    ptr: POINTER TO Variable;
    index: CARDINAL;
BEGIN
    ptr := VarTop;
    WHILE (ptr # NIL)
    DO
	index := 0;
	WHILE (ptr^.name^[index] # ASCII.NUL)
	DO
	    Write(ptr^.name^[index]);
	    index := index+1;
	END;
	Write('=');
	index := 0;
	WHILE (ptr^.value^[index] # ASCII.NUL)
	DO
	    Write(ptr^.value^[index]);
	    index := index+1;
	END;
	WriteLn;
	ptr := ptr^.link;
    END;
END ListVariables;

(* Change the value of a shell variable that has special meaning *)
PROCEDURE ChangeDefaultVariable(varPtr: VarPointer);
VAR
    tempName,varName: Line;
BEGIN
    tempName := PathVarName;
    varName := varPtr^.name^;
    IF (String.Compare(tempName,varName) = String.Equal)
    THEN
	PathPointer := varPtr^.value;
	RETURN;
    END;
    tempName := SuffixesVarName;
    IF (String.Compare(tempName,varName) = String.Equal)
    THEN
	SuffixesPointer := varPtr^.value;
    END;
END ChangeDefaultVariable;

(* Define a shell variable *)
PROCEDURE DefineVariable(VAR name: ARRAY OF CHAR; VAR value: ARRAY OF CHAR);
VAR
    nameLen,valueLen: CARDINAL;
    varPtr: VarPointer;
BEGIN
    nameLen := String.Length(name);
    valueLen := String.Length(value);
    varPtr := VarTop;
    WHILE (varPtr # NIL)
    DO
	IF (String.Compare(name,varPtr^.name^) = String.Equal)
	THEN
	    Storage.DEALLOCATE(varPtr^.value,String.Length(varPtr^.value^)+1);
	    Storage.ALLOCATE(varPtr^.value,valueLen+1);
	    String.Assign(varPtr^.value^,value);
	    ChangeDefaultVariable(varPtr);
	    RETURN;
	END;
	varPtr := varPtr^.link;
    END;
    Storage.ALLOCATE(varPtr,TSIZE(Variable));
    Storage.ALLOCATE(varPtr^.name,nameLen+1);
    Storage.ALLOCATE(varPtr^.value,valueLen+1);
    varPtr^.link := NIL;
    String.Assign(varPtr^.name^,name);
    String.Assign(varPtr^.value^,value);
    IF (VarTop = NIL)
    THEN
	VarTop := varPtr;
	VarBottom := varPtr;
    ELSE
	VarBottom^.link := varPtr;
	VarBottom := varPtr;
    END;
    ChangeDefaultVariable(varPtr);
END DefineVariable;

(* Expand a shell variable *)
PROCEDURE ExpandVariable;
VAR
    index,length,offset: CARDINAL;
    varName, varValue: Line;
    varPtr: VarPointer;
BEGIN
    length := LastIndex+1;
    offset := 0;
    IF (LineBuffer[length] = LBracket)
    THEN
	WHILE ((length < TSIZE(Line)) AND (LineBuffer[length] # RBracket))
	DO
	    length := length+1;
	END;
	offset := 1;
    ELSE
	WHILE ((length < TSIZE(Line)) AND
	    (LineBuffer[length] IN CharSet{'a'..'z', 'A'..'Z', '_', '0'..'9'}))
	DO
	    length := length+1;
	END;
    END;
    IF (length = TSIZE(Line))
    THEN
	ErrorMessage(VariableNotTerminated,0);
	RETURN;
    END;
    String.Copy(LineBuffer,LastIndex+1+offset,length-LastIndex-1-offset,varName);
    String.Delete(LineBuffer,LastIndex,length-LastIndex+offset);
    length := String.Length(LineBuffer);
    varPtr := VarTop;
    WHILE (varPtr # NIL)
    DO
	IF (String.Compare(varName,varPtr^.name^) = String.Equal)
	THEN
	    index := String.Length(varPtr^.value^);
	    IF ((length+index) >= TSIZE(Line))
	    THEN
		ErrorMessage(LineTooLong,0);
		index := TSIZE(Line)-length-1;
	    END;
	    varValue := varPtr^.value^;
	    varValue[index] := ASCII.NUL;
	    IF (LineBuffer[LastIndex] = ASCII.NUL)
	    THEN
		String.Concat(LineBuffer,varValue,varName);
		String.Assign(LineBuffer,varName);
	    ELSE
		String.Insert(varValue,LineBuffer,LastIndex);
	    END;
	    LastIndex := LastIndex-1;
	    RETURN;
	END;
	varPtr := varPtr^.link;
    END;
    LastIndex := LastIndex-1;
END ExpandVariable;

(* Parse a word of a command *)
PROCEDURE CommandWord;
VAR
    index, counter, varSave: CARDINAL;
    wildCard: BOOLEAN;
    newWord: Line;
    varName, varValue: Line;

(* Get the possible expansions for a filename with wildcard characters *)
PROCEDURE expandWildcard;
VAR
    index: CARDINAL;
    result: INTEGER;
    DTA: ARRAY[0..43] OF CHAR;
    savePath: Line;
    drive, newdrive: CARDINAL;
    drivemap: LONGCARD;
    ch: CHAR;

(* Stick an expanded wildcard filename back into the command line *)
PROCEDURE gotFile(): BOOLEAN;
VAR
    counter, availLength, fileLength: CARDINAL;
    tempLine, tempFile: Line;
BEGIN
    index := String.Length(CommandLine);
    availLength := TSIZE(Line)-index-1;
    fileLength := 0;
    FOR counter := 0 TO 13
    DO
	IF ((DTA[30+counter] # Space) AND
	    ASCII.CharIsPrintable(DTA[30+counter]))
	THEN
	    tempLine[fileLength] := DTA[30+counter];
	    fileLength := fileLength+1;
	END;
    END;
    tempLine[fileLength] := ASCII.NUL;
    IF (tempLine[0] = '.')
    THEN
	RETURN TRUE;
    END;
    fileLength := fileLength+1;
    IF (savePath[0] # ASCII.NUL)
    THEN
	fileLength := fileLength+String.Length(savePath);
    END;
    IF (fileLength < availLength)
    THEN
	CommandLine[index] := Space;
	CommandLine[index+1] := ASCII.NUL;
	IF (savePath[0] = ASCII.NUL)
	THEN
	    String.Assign(tempFile,tempLine);
	ELSE
	    String.Concat(savePath,tempLine,tempFile);
	END;
	String.Concat(CommandLine,tempFile,tempLine);
	String.Assign(CommandLine,tempLine);
	RETURN TRUE;
    ELSE
	ErrorMessage(LineTooLong,0);
	RETURN FALSE;
    END;
END gotFile;

(* expandWildcard *)
BEGIN
    GEMDOS.GetDrv(drive);
    IF (newWord[1] = DriveSep)
    THEN
	ch := CAP(newWord[0]);
	IF ((ch < 'A') OR (ch > 'P'))
	THEN
	    ErrorMessage(DirNotFound,0);
	    RETURN;
	END;
	newdrive := ORD(ch) - ORD('A');
	GEMDOS.SetDrv(newdrive,drivemap);
    END;
    GEMDOS.SetDTA(ADR(DTA));
    index := String.Length(newWord);
    WHILE ((index > 0) AND (newWord[index] # PathSep) AND
	(newWord[index] # DriveSep))
    DO
	index := index-1;
    END;
    IF (index > 0)
    THEN
	String.Copy(newWord,0,index+1,savePath);
    ELSE
	savePath[0] := ASCII.NUL;
    END;
    FOR index := 0 TO 43
    DO
	DTA[index] := ASCII.NUL;
    END;
    GEMDOS.SFirst(newWord,22,result);
    IF (result >= 0)
    THEN
	IF (gotFile())
	THEN
	    LOOP
		FOR index := 30 TO 43
		DO
		    DTA[index] := ASCII.NUL;
		END;
		GEMDOS.SNext(result);
		IF (result < 0)
		THEN
		    EXIT;
		END;
		IF (gotFile() = FALSE)
		THEN
		    EXIT;
		END;
	    END;
	ELSE
	    ErrorMessage(NoMatch,result);
	END;
    END;
    GEMDOS.SetDrv(drive,drivemap);
END expandWildcard;

(* CommandWord *)
BEGIN
    String.Copy(LineBuffer,FirstIndex,LastIndex-FirstIndex,newWord);
    counter := 0;
    varSave := 0;
    wildCard := FALSE;
    WHILE (newWord[counter] # ASCII.NUL)
    DO
	CASE newWord[counter]
	OF
	    SQuote:
		String.Delete(newWord,counter,1);
		WHILE ((newWord[counter] # SQuote) AND
		    (newWord[counter] # ASCII.NUL))
		DO
		    counter := counter+1;
		END;
		IF (newWord[counter] = SQuote)
		THEN
		    String.Delete(newWord,counter,1);
		END;
		|
	    DQuote:
		String.Delete(newWord,counter,1);
		WHILE ((newWord[counter] # DQuote) AND
		    (newWord[counter] # ASCII.NUL))
		DO
		    counter := counter+1;
		END;
		IF (newWord[counter] = DQuote)
		THEN
		    String.Delete(newWord,counter,1);
		END;
		|
	    VarDefine:
		varSave := counter;
		|
	    '*', '?':
		wildCard := TRUE;
		|
	    ELSE
	END;
	IF (newWord[counter] # ASCII.NUL)
	THEN
	    counter := counter+1;
	END;
    END;
    IF (wildCard)
    THEN
	expandWildcard;
    ELSIF (varSave # 0)
    THEN
	String.Copy(newWord,0,varSave,varName);
	String.Copy(newWord,varSave+1,String.Length(newWord)-varSave-1,varValue);
	DefineVariable(varName,varValue);
    ELSE
	IF (CommandName[0] = ASCII.NUL)
	THEN
	    CommandName := newWord;
	ELSE
	    counter := String.Length(CommandLine);
	    CommandLine[counter] := Space;
	    counter := counter+1;
	    index := 0;
	    LOOP
		IF (counter >= TSIZE(Line)-1)
		THEN
		    ErrorMessage(LineTooLong,0);
		    EXIT;
		END;
		IF (newWord[index] = ASCII.NUL)
		THEN
		    EXIT;
		END;
		CommandLine[counter] := newWord[index];
		counter := counter+1;
		index := index+1;
	    END;
	    CommandLine[counter] := ASCII.NUL;
	END;
    END;
END CommandWord;

(* Try to execute either a built-in or a disk command *)
PROCEDURE CommandExecute;
VAR
    cmdFirst, cmdLast, sfxFirst, sfxLast: CARDINAL;
    pathname, pathname1, testCmd, testSfx: Line;
    pathSeen, suffixSeen: BOOLEAN;
    result: INTEGER;

(* Sequentially put parts of search path into "testCmd" *)
(* Return TRUE while that is possible, FALSE when list end reached *)
(* Depends on cmdFirst,cmdLast indexes *)
PROCEDURE nextPath(): BOOLEAN;
BEGIN
    IF (PathPointer^[cmdFirst] = ASCII.NUL)
    THEN
	testCmd[0] := ASCII.NUL;
	RETURN FALSE;
    END;
    cmdLast := cmdFirst;
    WHILE ((PathPointer^[cmdLast] # PartSep) AND
	(PathPointer^[cmdLast] # ASCII.NUL))
    DO
	cmdLast := cmdLast+1;
    END;
    IF ((cmdLast-cmdFirst) > 0)
    THEN
	String.Copy(PathPointer^,cmdFirst,cmdLast-cmdFirst,testCmd);
    ELSE
	testCmd[0] := ASCII.NUL;
    END;
    IF (PathPointer^[cmdLast] = PartSep)
    THEN
	cmdFirst := cmdLast+1;
    ELSE
	cmdFirst := cmdLast;
    END;
    RETURN TRUE;
END nextPath;

(* Sequentially put parts of suffix list into "testSfx" *)
(* Return TRUE while that is possible, FALSE when list end reached *)
(* Depends on sfxFirst,sfxLast indexes *)
PROCEDURE nextSfx(): BOOLEAN;
BEGIN
    IF (SuffixesPointer^[sfxFirst] = ASCII.NUL)
    THEN
	testSfx[0] := ASCII.NUL;
	RETURN FALSE;
    END;
    sfxLast := sfxFirst;
    WHILE ((SuffixesPointer^[sfxLast] # PartSep) AND
	(SuffixesPointer^[sfxLast] # ASCII.NUL))
    DO
	sfxLast := sfxLast+1;
    END;
    IF ((sfxLast-sfxFirst) > 0)
    THEN
	String.Copy(SuffixesPointer^,sfxFirst,sfxLast-sfxFirst,testSfx);
    ELSE
	testSfx[0] := ASCII.NUL;
    END;
    IF (SuffixesPointer^[sfxLast] = PartSep)
    THEN
	sfxFirst := sfxLast+1;
    ELSE
	sfxFirst := sfxLast;
    END;
    RETURN TRUE;
END nextSfx;

(* The "cd" command *)
(* Change to another disk directory *)
PROCEDURE doCD;
VAR
    index, index1: CARDINAL;
    dchar: CHAR;
    drive: CARDINAL;
    drivemap: LONGCARD;
BEGIN
    IF (CommandLine[2] = DriveSep)
    THEN
	dchar := CAP(CommandLine[1]);
	IF ((ORD(dchar) < ORD('A')) OR (ORD(dchar) > ORD('P')))
	THEN
	    ErrorMessage(DirNotFound,0);
	    RETURN;
	END;
	drive := ORD(dchar) - ORD('A');
	GEMDOS.SetDrv(drive,drivemap);
	index := 3;		(* Rest of pathname starts here *)
	IF (CommandLine[index] = ASCII.NUL)
	THEN
	    CommandLine[index] := PathSep;
	    CommandLine[index+1] := ASCII.NUL;
	END;
    ELSE
	GEMDOS.GetDrv(drive);
	index := 1;		(* Pathname starts here *)
    END;
    index1 := index;
    WHILE ((CommandLine[index1] # ASCII.NUL) AND
	(CommandLine[index1] # Space))
    DO
	index1 := index1+1;
    END;
    String.Copy(CommandLine,index,index1-index,pathname);
    IF (GEMDOS.SetPath(pathname) = FALSE)
    THEN
	ErrorMessage(DirNotFound,0);
    END;
END doCD;

(* The "echo" command *)
(* Print our arguments on the screen *)
PROCEDURE doECHO;
VAR
    index: CARDINAL;
BEGIN
    index := 1;	(* Skip leading byte; reserved for GEMDOS *)
    WHILE (CommandLine[index] # ASCII.NUL)
    DO
	Write(CommandLine[index]);
	index := index+1;
    END;
    WriteLn;
END doECHO;

(* The "pwd" command *)
(* Print the name of our working directory on the screen *)
PROCEDURE doPWD;
VAR
    index: CARDINAL;
    drive: CARDINAL;
    dchar: CHAR;
BEGIN
    GEMDOS.GetDrv(drive);
    GEMDOS.GetPath(pathname,drive+1);
    dchar := CHR(drive + ORD('A'));
    Write(dchar);
    Write(DriveSep);
    index := 0;
    WHILE (pathname[index] # ASCII.NUL)
    DO
	Write(pathname[index]);
	index := index+1;
    END;
    WriteLn;
END doPWD;

(* The "set" command *)
(* List all variables, or set some flags *)
PROCEDURE doSET;
VAR
    index: CARDINAL;
BEGIN
    index := 2;
    CASE CommandLine[1]
    OF
	'-':		(* Turn on some flags *)
	    WHILE ((CommandLine[index] # Space) AND
		(CommandLine[index] # ASCII.NUL))
	    DO
		CASE CommandLine[index]
		OF
		    'v':	(* Print lines as they are read *)
			PrintLinesRead := TRUE;
			|
		    'x':	(* Print lines as they are executed *)
			PrintLinesExecuted := TRUE;
			|
		    ELSE	(* Error *)
			ErrorMessage(FlagNotFound,0);
		END;
		index := index+1;
	    END;
	    |
	'+':		(* Turn off some flags *)
	    WHILE ((CommandLine[index] # Space) AND
		(CommandLine[index] # ASCII.NUL))
	    DO
		CASE CommandLine[index]
		OF
		    'v':	(* Print lines as they are read *)
			PrintLinesRead := FALSE;
			|
		    'x':	(* Print lines as they are executed *)
			PrintLinesExecuted := FALSE;
			|
		    ELSE	(* Error *)
			ErrorMessage(FlagNotFound,0);
		END;
		index := index+1;
	    END;
	    |
	ELSE		(* Just list variables *)
	    ListVariables;
    END;
END doSET;

(* The "." command *)
(* Temporarily take input from a file *)
PROCEDURE doSOURCE;
VAR
    index: CARDINAL;
BEGIN
    index := 1;
    WHILE ((CommandLine[index] # ASCII.NUL) AND
	(CommandLine[index] # Space))
    DO
	index := index+1;
    END;
    String.Copy(CommandLine,1,index-1,pathname);
    OpenStream(FileStream,pathname,READ,result);
    IF (result >= 0)
    THEN
	ReadFromFile := TRUE;
    ELSE
	ErrorMessage(FileNotFound,result);
    END;
END doSOURCE;

(* The "version" command *)
(* Print the version of this program and the OS *)
PROCEDURE doVERSION;
VAR
    ver: CARDINAL;
    buffer: Line;
BEGIN
    WriteString(CLIVersion);
    WriteLn;
    WriteString(GEMDOSVersion);
    GEMDOS.Version(ver);
    ConvertInteger(ver MOD 256,1,buffer);
    WriteString(buffer);
    Write('.');
    ConvertInteger(ver DIV 256,1,buffer);
    WriteString(buffer);
    WriteLn;
END doVERSION;

(* Try to execute the passed command, assuming that the global *)
(* CommandLine is correctly setup *)
(* Status of execution try returned as result *)
PROCEDURE tryEXEC(VAR command: ARRAY OF CHAR): INTEGER;
VAR
    result: INTEGER;
    envstr: ARRAY[0..0] OF CHAR;
BEGIN
    envstr[0] := ASCII.NUL;
    GEMDOS.Exec(GEMDOS.loadExecute,command,CommandLine,envstr,result);
    RETURN result;
END tryEXEC;

(* CommandExecute *)
BEGIN
    IF (PrintLinesExecuted)
    THEN
	WriteString("> ");
	cmdLast := 0;
	WHILE (CommandName[cmdLast] # ASCII.NUL)
	DO
	    Write(CommandName[cmdLast]);
	    cmdLast := cmdLast+1;
	END;
	cmdLast := 0;
	WHILE (CommandLine[cmdLast] # ASCII.NUL)
	DO
	    Write(CommandLine[cmdLast]);
	    cmdLast := cmdLast+1;
	END;
	WriteLn;
    END;

    (* Try builtin commands first *)
    (* The set command; list variables, set options, etc.; "set" *)
    testCmd := SetCommand;
    IF (String.Compare(testCmd,CommandName) = String.Equal)
    THEN
	doSET;
	RETURN;
    END;
    (* The source command; "." *)
    testCmd := SourceCommand;
    IF (String.Compare(testCmd,CommandName) = String.Equal)
    THEN
    	doSOURCE;
	RETURN;
    END;
    (* The echo command; "echo" *)
    testCmd := EchoCommand;
    IF (String.Compare(testCmd,CommandName) = String.Equal)
    THEN
	doECHO;
	RETURN;
    END;
    (* The change directory command; "cd" *)
    testCmd := ChangeDirectory;
    IF (String.Compare(testCmd,CommandName) = String.Equal)
    THEN
	doCD;
	RETURN;
    END;
    (* The print directory name command; "pwd" *)
    testCmd := PrintDirectory;
    IF (String.Compare(testCmd,CommandName) = String.Equal)
    THEN
	doPWD;
	RETURN;
    END;
    testCmd := VersionCommand;
    IF (String.Compare(testCmd,CommandName) = String.Equal)
    THEN
	doVERSION;
	RETURN;
    END;

    (* Now try to execute a disk file *)
    cmdLast := 1;
    WHILE (CommandLine[cmdLast] # ASCII.NUL)
    DO
	cmdLast := cmdLast+1;
    END;
    IF (cmdLast > 127)
    THEN
	ErrorMessage(CmdArgsTooLong,0);
	RETURN;
    END;
    CommandLine[0] := CHR(cmdLast-1);
    pathSeen := FALSE;
    suffixSeen := FALSE;
    cmdLast := 0;
    WHILE (CommandName[cmdLast] # ASCII.NUL)
    DO
	IF (CommandName[cmdLast] = DriveSep)
	THEN
	    pathSeen := TRUE;
	ELSIF (CommandName[cmdLast] = PathSep)
	THEN
	    pathSeen := TRUE;
	ELSIF (CommandName[cmdLast] = SuffixSep)
	THEN
	    suffixSeen := TRUE;
	END;
	cmdLast := cmdLast+1;
    END;
    cmdFirst := 0;
    cmdLast := 0;
    sfxFirst := 0;
    sfxLast := 0;
    IF (pathSeen AND suffixSeen)
    THEN
	result := tryEXEC(CommandName);
        IF (result < 0)
	THEN
	    ErrorMessage(FileNotExecuted,result);
	END;
	RETURN;
    ELSIF (pathSeen)
    THEN		(* Have to try different suffixes *)
	WHILE (nextSfx())
	DO
	    String.Concat(CommandName,testSfx,pathname);
	    result := tryEXEC(pathname);
	    IF ((result < 0) AND (result # GEMDOS.EFilNF))
	    THEN
		ErrorMessage(FileNotExecuted,result);
	    ELSIF (result >= 0)
	    THEN
		RETURN;		(* Everything worked??? *)
	    END;
	END;
	ErrorMessage(FileNotExecuted,result);
	RETURN;
    ELSIF (suffixSeen)
    THEN		(* Have to use search path *)
	WHILE (nextPath())
	DO
	    String.Concat(testCmd,CommandName,pathname);
	    result := tryEXEC(pathname);
	    IF ((result < 0) AND (result # GEMDOS.EFilNF))
	    THEN
		ErrorMessage(FileNotExecuted,result);
	    ELSIF (result >= 0)
	    THEN
		RETURN;		(* Everything worked??? *)
	    END;
	END;
	ErrorMessage(FileNotExecuted,result);
	RETURN;
    ELSE		(* Have to use search path, suffixes *)
	WHILE (nextPath())
	DO
	    sfxFirst := 0;
	    sfxLast := 0;
	    WHILE (nextSfx())
	    DO
		String.Concat(testCmd,CommandName,pathname1);
		String.Concat(pathname1,testSfx,pathname);
		result := tryEXEC(pathname);
		IF ((result < 0) AND (result # GEMDOS.EFilNF))
		THEN
		    ErrorMessage(FileNotExecuted,result);
		ELSIF (result >= 0)
		THEN
		    RETURN;		(* Everything worked??? *)
		END;
	    END;
	END;
	ErrorMessage(FileNotExecuted,result);
	RETURN;
    END;
END CommandExecute;

PROCEDURE doCLI;
TYPE
    saveArea = ARRAY[0..480] OF LONGCARD;
    saveAreaPtr = POINTER TO saveArea;
VAR
    saveBar: saveArea;
    saveAddr: saveAreaPtr;
    index: CARDINAL;
BEGIN
    AESGraphics.GrafMouse(GEMAESbase.MouseOff,NIL);

    (* Save the top of our screen *)
    CODE(3F3CH,2,4E4EH,548FH);	(* Get the address of our screen *)
    saveAddr := saveAreaPtr(REGISTER(0));
    FOR index := 0 TO 480
    DO
	saveBar[index] := saveAddr^[index];
    END;

    (* General initialization *)
    ReadFromFile := FALSE;
    PrintLinesRead := FALSE;
    PrintLinesExecuted := FALSE;
    GEMDOS.GetDTA(oldDTAaddr);

    (* GEM Initialization *)
    VDIControls.ClearWorkstation(VDIHandle);
    VDIControls.UpdateWorkstation(VDIHandle);
    VDIEscapes.EnterAlphaMode(VDIHandle);

    (* Simulate a "version" command to announce ourselves *)
    CommandName := VersionCommand;
    CommandLine[0] := ASCII.NUL;
    CommandExecute;

    (* Main Loop *)
    KeepGoing := TRUE;
    WHILE (KeepGoing)
    DO
	IF (ReadFromFile)
	THEN
	    IF (EOS(FileStream))
	    THEN
		ReadFromFile := FALSE;
		CloseStream(FileStream,Result);
		WriteString(Prompt);
		ReadLine;
	    ELSE
		Counter := 0;
		LOOP
		    Read8Bit(FileStream,SaveCh);
		    IF ((SaveCh # ASCII.CR) AND (SaveCh # ASCII.LF))
		    THEN
			LineBuffer[Counter] := SaveCh;
			Counter := Counter+1;
		    ELSIF (SaveCh = ASCII.CR)
		    THEN
			LineBuffer[Counter] := ASCII.NUL;
			EXIT;
		    END;
		END;
	    END;
	ELSE
	    WriteString(Prompt);
	    ReadLine;
	END;
	IF (PrintLinesRead)
	THEN
	    Counter := 0;
	    WHILE (LineBuffer[Counter] # ASCII.NUL)
	    DO
		Write(LineBuffer[Counter]);
		Counter := Counter+1;
	    END;
	    WriteLn;
	END;
	CommandName[0] := ASCII.NUL;
	CommandLine[0] := ASCII.NUL;
	CommandLine[1] := ASCII.NUL;
	FirstIndex := 0;
	LastIndex := 0;
	LOOP
	    CASE LineBuffer[LastIndex]
	    OF
		ASCII.EOT, ASCII.NUL, Tab, Space: (* End of word *)
		    SaveCh := LineBuffer[LastIndex];
		    IF (FirstIndex # LastIndex)
		    THEN
			CommandWord;
		    END;
		    IF (SaveCh = ASCII.EOT)
		    THEN
			KeepGoing := FALSE;
			EXIT;
		    END;
		    IF (SaveCh = ASCII.NUL)
		    THEN
			EXIT;
		    END;
		    WHILE (((LineBuffer[LastIndex+1] = Tab) OR
		        (LineBuffer[LastIndex+1] = Space)) AND
			(LastIndex < TSIZE(Line)))
		    DO
			LastIndex := LastIndex+1;
		    END;
		    FirstIndex := LastIndex+1;
		    |
		VarStart:		(* Shell variable *)
		    ExpandVariable;
		    |
		SQuote:			(* Single quote *)
		    Counter := LastIndex+1;
		    LOOP
			CASE LineBuffer[Counter]
			OF
			    ASCII.NUL:
				ErrorMessage(UnClosedString,0);
				EXIT;
				|
			    SQuote:
				EXIT;
				|
			    ELSE
			END;
			Counter := Counter+1;
		    END;
		    IF (LineBuffer[Counter] = ASCII.NUL)
		    THEN
			EXIT;
		    END;
		    LastIndex := Counter;
		    |
		DQuote:			(* Double quote *)
		    Counter := LastIndex+1;
		    LOOP
			CASE LineBuffer[Counter]
			OF
			    ASCII.NUL:
				ErrorMessage(UnClosedString,0);
				EXIT;
				|
			    VarStart:
				LastIndex := Counter;
				ExpandVariable;
				|
			    DQuote:
				EXIT;
				|
			    ELSE
			END;
			Counter := Counter+1;
		    END;
		    IF (LineBuffer[Counter] = ASCII.NUL)
		    THEN
			EXIT;
		    END;
		    LastIndex := Counter;
		    |
		ELSE			(* Normal character *)
	    END;
	    LastIndex := LastIndex+1;
	    IF (LastIndex >= TSIZE(Line))
	    THEN
		EXIT;
	    END;
	END;
	IF (CommandName[0] # ASCII.NUL)
	THEN
	    CommandExecute;
	END;
    END;
    GEMDOS.SetDTA(oldDTAaddr);	(* Old filename buffer *)

    (* GEM Termination *)
    VDIEscapes.ExitAlphaMode(VDIHandle);
    AESForms.FormDialogue(GEMAESbase.FormFinish,
	0,0,ScreenWidth,ScreenHeight,0,0,ScreenWidth,ScreenHeight);
    VDIControls.UpdateWorkstation(VDIHandle);

    (* Restore the top of our screen *)
    CODE(3F3CH,2,4E4EH,548FH);	(* Get the address of our screen *)
    saveAddr := saveAreaPtr(REGISTER(0));
    FOR index := 0 TO 480
    DO
	saveAddr^[index] := saveBar[index];
    END;

    AESGraphics.GrafMouse(GEMAESbase.MouseOn,NIL);
END doCLI;

(* CLI *)
BEGIN
    (* Try kludging around a runtime memory setup bug in the current *)
    (* version of Modula2-ST *)
    (* We'll leave "MaxStack" for stack space *)
    GEMDOS.Alloc(LONGCARD(MaxStack),BlockAddr);
    IF (LONGINT(BlockAddr) <= 0)
    THEN
	ErrorMessage(NotEnoughMemory,1);
	HALT;
    END;
    OldStackPage := PagePointer(REGISTER(14));
    (* The 72 in the next line, and the 18 words in the following loop *)
    (* are based on emperical observations of what the stack looks like *)
    (* immediately after a program starts running *)
    StackPage := PagePointer(LONGCARD(BlockAddr)+
	LONGCARD(MaxStack-72));
    FOR Counter := 0 TO 17
    DO
	StackPage^[Counter] := OldStackPage^[Counter];
    END;
    SETREG(14,ADDRESS(StackPage));
    SETREG(15,ADDRESS(StackPage));
    
    (* General initialization *)
    IF (Storage.CreateHeap(MaxHeap,FALSE) = FALSE)
    THEN
	ErrorMessage(NotEnoughMemory,0);
	HALT;
    END;
    String.InitStringModule;
    String.SetTerminator(ASCII.NUL);

    (* Set up shell variables *)
    VarTop := NIL;
    VarBottom := NIL;
    CommandName := PathVarName;
    CommandLine := PathDefault;
    DefineVariable(CommandName,CommandLine);
    CommandName := SuffixesVarName;
    CommandLine := SuffixesDefault;
    DefineVariable(CommandName,CommandLine);

    (* GEM Initialization *)
    VDIHandle := AESGraphics.GrafHandle(WidthChar,HeightChar,WidthFont,
	HeightFont) ;
    FOR Counter := 0 TO 9
    DO
	WorkIn[Counter] := 1;
    END;
    WorkIn[Counter] := 2;
    VDIControls.OpenVirtualWorkstation(WorkIn,VDIHandle,WorkOut);
    ScreenWidth := WorkOut[0];
    ScreenHeight := WorkOut[1];

    (* Set up as a desk accessory, or just run the shell... *)
    (* Whatever is desired. *)
    IF (DeskAccessory = 0)
    THEN
	doCLI;
    ELSE
	ApplId := AESApplications.ApplInitialise();
	MenuId := AESMenus.MenuRegister(ApplId,"  Tiny Shell");
	WHILE (TRUE)
	DO
	    EventId := AESEvents.EventMultiple(GEMAESbase.MesageEvent,
		0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		ADR(MsgBuf[0]), 0, 0,
		Dummy, Dummy, Dummy, Dummy, Dummy, Dummy);
	    IF (EventId = GEMAESbase.MesageEvent)
	    THEN
		CASE (MsgBuf[0])
		OF
		    GEMAESbase.AccessoryOpen:	(* Start a shell *)
			doCLI;
			|
		    GEMAESbase.AccessoryClose:	(* Really needed? *)
			|
		    ELSE
		END;
	    END;
	END;
    END;

    (* Clean up everything *)
    VDIControls.CloseVirtualWorkstation(VDIHandle);

END CLI.
