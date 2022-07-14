{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *             Unit  O D B              *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        23.05.1994  *
 *      letztes Update am:  19.03.1998  *
 ****************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

	ObjectGEM ist Freeware, d.h. jeder darf die Units verwenden, ohne
	fÅr die damit entwickelten Programme Lizenzen o.Ñ. zahlen zu mÅssen,
	so lange alle Dateien _zusammen_ und _unverÑndert_ (!) weitergegeben
	werden.
	
	Ich freue mich natÅrlich trotzdem Åber kleine Aufmerksamkeiten wie
	Belegexemplare, originelle T-Shirts (L oder XL) sowie grÅnen Tee
	aus Japan :-)

  WICHTIG: Wer den Quelltext verÑndert und dann Probleme beim Compilieren,
  AusfÅhren o.Ñ. hat, kann nicht damit rechnen, daû ich den Fehler suche;
  tritt der Fehler allerdings auch mit dem Original-Quelltext auf, wÅrde
  ich mich Åber eine genaue Fehlerbeschreibung freuen. VerÑnderte Quell-
  texte dÅrfen _nicht_ weitergegeben werden, dies wÑre ein Verstoû gegen
  das Copyright!

  Wer beim Durchstîbern des Textes auf vermeintliche Fehler oder verbesse-
  rungswÅrdige Stellen trifft (von letzterem gibt es sicherlich noch viele),
  kann mir dies gerne mitteilen - ich habe auch ich nichts gegen kostenlos
  zur VerfÅgung gestellte optimierte Routinen (sofern sich jemand die MÅhe
  macht). Wer in anderen Projekten, die nicht in direkter Konkurrenz zu
  ObjectGEM stehen, einzelne Routinen verwenden mîchte, wendet sich bitte
  an mich (ein solcher Austausch sollte kein Problem sein).

  Wer sich auf nicht dokumentierte "implementation"- oder "private"-Eigen-
  schaften verlÑût, darf sich nicht Åber InkompatibilitÑten zu spÑteren
  Versionen wundern; wer meint, eine DokumentationslÅcke entdeckt zu haben,
  kann mir dies gerne mitteilen.

  Kleine Info zum Schluû: Als "default tabsize" verwende ich 2. Wer drei
  Punkte ("...") im Quelltext entdeckt, hat eine Stelle gefunden, an der
  ich z.Z. arbeite ;-)

  "Mîge die OOP mit Euch sein!"
}


{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit ODB;

interface

uses

	OTypes,Objects;

type

	PXBase = ^TXBase;

	PXBField = ^TXBField;
	TXBField = object(TObject)
		public
		Parent: PXBase;
		constructor Init(AParent: PXBase; flName: string; flType: char; flLen,flFloat,bOffs: integer);
		destructor Done; virtual;
		function GetName: string;
		function GetType: char;
		function GetLength: integer;
		function GetFloatpt: integer;
		function IsString: boolean;
		function IsNumber: boolean;
		function IsLogical: boolean;
		function IsDate: boolean;
		function IsMemo: boolean;
		function GetString: string;
		function GetNumber: real;
		function GetLogical: integer;
		function GetDate: string;
		function Previous: PXBField;
		function Next: PXBField;
		private
		fldname : string;
		bufoffs,
		fldfloat,
		fldlen  : integer;
		fldtype : char;
		nxt,
		prev   : PXBField
	end;

	TXBase = object(TObject)
		public
		Fields: PXBField;
		constructor Init;
		constructor InitFile(dbFile: string);
		destructor Done; virtual;
		function Open(dbFile:string): boolean;
		procedure Close;
		function IsOpen: boolean;
		function GetFilename: string;
		function GetMaxRecords: longint;
		function GetMaxFields: integer;
		function GetFieldByNumber(fNum: longint): PXBField;
		function GetPosition: longint;
		function GotoRecord(Nr: longint): boolean;
		function GotoBeginning: boolean;
		function GotoEnd: boolean;
		function Skip(Delta: longint): boolean;
		function GetRecord: boolean;
		function IsEOF: boolean;
		function HasMemos: boolean;
		private
		dsanz,
		dslen,
		dspos,
		bufsize,
		f0pos,
		feldanz : longint;
		hdl     : integer;
		version : byte;
		memos,
		bufvalid,
		openflag: boolean;
		filename: string;
		buf     : PByteArray;
		function bread(buffer: pointer; count: longint): boolean;
		function SwapLong(l: longint): longint;
	end;
	
	PCompoundFile = ^TCompoundFile;
	TCompoundFile = object(TObject)
		public
		constructor Init;
		constructor InitFile(comFile: string);
		constructor InitHandle(comFile: string; comHnd: integer);
		destructor Done; virtual;
		function Open(comFile:string): boolean;
		procedure Close;
		function IsOpen: boolean;
		private
		comfname: string;
		byfile,
		openflag: boolean;
		comhdl  : integer;
		maxblock,
		num_of_bbd_blocks,
		root_startblock,
		sbd_startblock,
		blocknr,
		comsize          : longint;
		bbd_list         : PLongintArray;
		block            : array [0..511] of byte;
		function GetLong(idx: integer): longint;
		function ReadBlock(bnr: longint): boolean;
		function GetNextBlockNr(bnr: longint): longint;
		function ReadHeader: boolean;
	end;



implementation

uses

	Tos,OProcs;

const

	CF_ENDOFCHAIN = -2;

type

	TDB2HEADER = record
		version: byte;
		records: array [0..1] of byte;
		datum  : array [1..3] of byte;
		recordb: array [0..1] of byte
	end;

	TDB34HEADER = record
		version: byte;
		datum  : array [1..3] of byte;
		records: longint;
		headerb,
		recordb: word;
		reserve: array [0..19] of byte
	end;

	TFELD2 = record
		fname : array [0..10] of char;
		ftyp  : char;
		laenge: byte;
		dummy : array [0..1] of byte;
		komma : byte
	end;

	TFELD34 = record
		fname : array [0..10] of char;
		ftyp  : char;
		dummy1: array [0..3] of byte;
		laenge,
		komma : byte;
		dummy2: array [0..1] of byte;
		id    : byte;
		dummy3: array [0..10] of byte
	end;


{ *** Objekt TXBFIELD *** }

constructor TXBField.Init(AParent: PXBase; flName: string; flType: char; flLen,flFloat,bOffs: integer);
	var p: PXBField;

	begin
		if not(inherited Init) then fail;
		Parent:=AParent;
		if Parent=nil then
			begin
				inherited Done;
				fail
			end;
		nxt:=nil;
		prev:=nil;
		fldname:=flName;
		fldtype:=flType;
		fldlen:=flLen;
		fldfloat:=flFloat;
		bufoffs:=bOffs;
		if Parent^.Fields=nil then Parent^.Fields:=@self
		else
			begin
				p:=Parent^.Fields;
				while p^.nxt<>nil do p:=p^.nxt;
				p^.nxt:=@self;
				prev:=p
			end
	end;


destructor TXBField.Done;

	begin
		if (prev=nil) and (nxt=nil) then Parent^.Fields:=nil
		else
			begin
				if prev=nil then Parent^.Fields:=nxt
					else prev^.nxt:=nxt;
				if nxt<>nil then nxt^.prev:=prev
			end;
		inherited Done
	end;


function TXBField.GetName: string;

	begin
		GetName:=fldname
	end;


function TXBField.GetType: char;

	begin
		GetType:=fldtype
	end;


function TXBField.GetLength: integer;

	begin
		GetLength:=fldlen
	end;


function TXBField.GetFloatpt: integer;

	begin
		GetFloatpt:=fldfloat
	end;


function TXBField.IsString: boolean;

	begin
		IsString:=(GetType='C')
	end;


function TXBField.IsNumber: boolean;

	begin
		IsNumber:=(GetType='N') or (GetType='F')
	end;


function TXBField.IsLogical: boolean;

	begin
		IsLogical:=(GetType='L')
	end;


function TXBField.IsDate: boolean;

	begin
		IsDate:=(GetType='D')
	end;


function TXBField.IsMemo: boolean;

	begin
		IsMemo:=(GetType='M')
	end;


function TXBField.GetString: string;

	begin
		if not(parent^.bufvalid) then GetString:=''
		else
			if IsString or IsNumber then GetString:=StrPTrimF(StrLPas(@Parent^.buf^[bufoffs],Min(GetLength,255)))
			else
				GetString:=''
	end;


function TXBField.GetNumber: real;
	var i: integer;

	begin
		if not(Parent^.bufvalid) then GetNumber:=0.0
		else
			if not(IsNumber) then GetNumber:=0.0
			else
				GetNumber:=atof(StrLPas(@Parent^.buf^[bufoffs],GetLength))
	end;


function TXBField.GetLogical: integer;

	begin
		if not(IsLogical) or not(Parent^.bufvalid) then GetLogical:=xb_False
		else
			if Parent^.buf^[bufoffs]=ord('?') then GetLogical:=xb_Neutral
			else
				if chr(Parent^.buf^[bufoffs]) in ['t','T','j','J'] then GetLogical:=xb_True
				else
					GetLogical:=xb_False
	end;


function TXBField.GetDate: string;
	var ttxt: string;

	begin
		if not(IsDate) or not(Parent^.bufvalid) then GetDate:=''
		else
			begin
				ttxt:=StrPTrimF(StrLPas(@Parent^.buf^[bufoffs],GetLength));
				if length(ttxt)<>8 then GetDate:=''
				else
					GetDate:=StrPRight(ttxt,2)+'.'+StrPMid(ttxt,5,2)+'.'+StrPLeft(ttxt,4)
			end
	end;


function TXBField.Previous: PXBField;

	begin
		Previous:=prev
	end;


function TXBField.Next: PXBField;

	begin
		Next:=nxt
	end;

{ *** TXBFIELD *** }



{ *** Objekt TXBASE *** }

constructor TXBase.Init;

	begin
		if not(inherited Init) then fail;
		Fields:=nil;
		openflag:=false;
		bufvalid:=false;
		memos:=false;
		filename:='';
		feldanz:=0;
		dsanz:=0;
		dspos:=0;
		buf:=nil
	end;


constructor TXBase.InitFile(dbFile: string);

	begin
		if not(Init) then fail;
		if not(Open(dbFile)) then fail
	end;


destructor TXBase.Done;

	begin
		Close;
		inherited Done
	end;


function TXBase.Open(dbFile: string): boolean;
	label _error;

	var res   : longint;
	    bpos,
	    q     : integer;
	    kopf2 : TDB2HEADER;
	    kopf34: TDB34HEADER;
	    feld2 : TFELD2;
	    feld34: TFELD34;

	begin
		Open:=false;
		Close;
		if length(dbFile)=0 then exit;
		res:=fopen(dbFile,FO_READ);
		if res<0 then exit;
		hdl:=integer(res);
		buf:=GetMemBuffer(4096,4096,bufsize);
		if buf=nil then goto _error;
		if bread(@version,1) then goto _error;
		if (version<>$02) and ((version and $03)<>$03) and ((version and $03)<>$01) then goto _error;
		if fseek(0,hdl,0)<>0 then goto _error;
		memos:=bTst(version,$80);
		version:=version and $03;
		if version=$02 then
			begin
				if bread(@kopf2,sizeof(kopf2)) then goto _error;
				dsanz:=kopf2.records[0] or (kopf2.records[1] shl 8);
				dslen:=kopf2.recordb[0] or (kopf2.recordb[1] shl 8);
				feldanz:=0;
				bpos:=1;
				if bread(buf,1) then goto _error;
				while (buf^[0]<>$0d) do
					begin
						if fseek(-1,hdl,1)<0 then goto _error;
						if bread(@feld2,sizeof(feld2)) then goto _error;
						if feld2.fname[0]<>#0 then
							new(PXBField,Init(@self,StrLPas(feld2.fname,11),feld2.ftyp,feld2.laenge,feld2.komma,bpos));
						inc(bpos,feld2.laenge);
						inc(feldanz);
						if bread(buf,1) then goto _error
					end;
				if not(Between(feldanz,1,32)) then goto _error;
				if fseek(520,hdl,0)<>520 then goto _error
			end
		else
			begin
				if bread(@kopf34,sizeof(kopf34)) then goto _error;
				dsanz:=SwapLong(kopf34.records);
				dslen:=swap(kopf34.recordb);
				feldanz:=((swap(kopf34.headerb)-1) div 32)-1;
				if version=$01 then
					begin
						if not(Between(feldanz,1,255)) then goto _error;
					end
				else
					if not(Between(feldanz,1,128)) then goto _error;
				bpos:=1;
				for q:=1 to feldanz do
					begin
						if bread(@feld34,sizeof(feld34)) then goto _error;
						new(PXBField,Init(@self,StrLPas(feld34.fname,11),feld34.ftyp,feld34.laenge,feld34.komma,bpos));
						inc(bpos,feld34.laenge)
					end
			end;
		if bread(buf,1) then goto _error;
		if buf^[0]<>$0d then goto _error;
		if version=$02 then
			begin
				if bread(buf,1) then goto _error;
				if buf^[0]<>$00 then
					if fseek(-1,hdl,1)<0 then goto _error;
				f0pos:=fseek(0,hdl,1)
			end
		else
			begin
				if fseek(0,hdl,1)>swap(kopf34.headerb) then goto _error
				else
					f0pos:=fseek(swap(kopf34.headerb),hdl,0)
			end;
		if f0pos<0 then goto _error;
		dspos:=0;
		filename:=dbFile;
		openflag:=true;
		Open:=true;
		exit;
		_error:
		while Fields<>nil do Fields^.Free;
		if buf<>nil then
			begin
				freemem(buf,bufsize);
				buf:=nil
			end;
		feldanz:=0;
		memos:=false;
		dsanz:=0;
		fclose(hdl)
	end;


procedure TXBase.Close;

	begin
		if not(IsOpen) then exit;
		fclose(hdl);
		while Fields<>nil do Fields^.Free;
		if buf<>nil then
			begin
				freemem(buf,bufsize);
				buf:=nil
			end;
		filename:='';
		feldanz:=0;
		dsanz:=0;
		dspos:=0;
		bufvalid:=false;
		memos:=false;
		openflag:=false
	end;


function TXBase.IsOpen: boolean;

	begin
		IsOpen:=openflag
	end;


function TXBase.GetFilename: string;

	begin
		GetFilename:=filename
	end;


function TXBase.GetMaxRecords: longint;

	begin
		GetMaxRecords:=dsanz
	end;


function TXBase.GetMaxFields: integer;

	begin
		GetMaxFields:=feldanz
	end;


function TXBase.GetFieldByNumber(fNum: longint): PXBField;
	var pxbf: PXBField;

	begin
		pxbf:=Fields;
		while (pxbf<>nil) and (fNum>0) do
			begin
				dec(fNum);
				pxbf:=pxbf^.Next
			end;
		GetFieldByNumber:=pxbf
	end;


function TXBase.GetPosition: longint;

	begin
		GetPosition:=dspos
	end;


function TXBase.GotoRecord(Nr: longint): boolean;
	var ret: longint;

	begin
		if not(IsOpen) then
			begin
				GotoRecord:=false;
				exit
			end;
		if Nr<0 then Nr:=0
		else
			if Nr>GetMaxRecords then Nr:=GetmaxRecords;
		ret:=fseek(f0pos+Nr*dslen,hdl,0);
		if ret<0 then GotoRecord:=false
		else
			begin
				dspos:=Nr;
				GotoRecord:=true
			end
	end;


function TXBase.GotoBeginning: boolean;

	begin
		GotoBeginning:=GotoRecord(0)
	end;


function TXBase.GotoEnd: boolean;

	begin
		GotoEnd:=GotoRecord(GetMaxRecords)
	end;


function TXBase.Skip(Delta: longint): boolean;

	begin
		if Delta=0 then Skip:=true
		else
			Skip:=GotoRecord(GetPosition+Delta)
	end;


function TXBase.GetRecord: boolean;

	begin
		if not(IsOpen) then GetRecord:=false
		else
			if bread(buf,dslen) then
				begin
					bufvalid:=false;
					GetRecord:=false
				end
			else
				begin
					inc(dspos);
					bufvalid:=true;
					GetRecord:=true
				end
	end;


function TXBase.IsEOF: boolean;

	begin
		IsEOF:=(dspos>=GetMaxRecords)
	end;


function TXBase.HasMemos: boolean;

	begin
		HasMemos:=memos
	end;

{ private }


function TXBase.bread(buffer: pointer; count: longint): boolean;

	begin
		bread:=(fread(hdl,count,buffer)<>count)
	end;


function TXBase.SwapLong(l: longint): longint;

	begin
		SwapLong:=longint(swap(HiWord(pointer(l)))) or (longint(swap(LoWord(pointer(l)))) shl 16)
	end;

{ *** TXBASE *** }



{ *** Objekt TCOMPOUNDFILE *** }

constructor TCompoundFile.Init;

	begin
		if not(inherited Init) then fail;
		openflag:=false;
		byfile:=false
	end;


constructor TCompoundFile.InitFile(comFile: string);

	begin
		if not(Init) then fail;
		if not(Open(comFile)) then fail
	end;


constructor TCompoundFile.InitHandle(comFile: string; comHnd: integer);

	begin
		if not(Init) then fail;
		comfname:=comFile;
		comhdl:=comHnd;
		if not(ReadHeader) then fail;
	end;


destructor TCompoundFile.Done;

	begin
		Close;
		inherited Done
	end;


function TCompoundFile.Open(comFile:string): boolean;
	var ret: longint;

	begin
		Open:=false;
		if IsOpen then exit;
		comfname:=comFile;
		ret:=fopen(comfname,FO_READ);
		if ret<0 then exit;
		comhdl:=integer(ret);
		if not(ReadHeader) then
			begin
				fclose(comhdl);
				exit
			end;
		byfile:=true;
		Open:=true
	end;


procedure TCompoundFile.Close;

	begin
		if not(IsOpen) then exit;
		if byfile then
			begin
				fclose(comhdl);
				byfile:=false
			end;
		if num_of_bbd_blocks>0 then freemem(bbd_list,num_of_bbd_blocks shl 2);
		openflag:=false
	end;


function TCompoundFile.IsOpen: boolean;

	begin
		IsOpen:=openflag
	end;


	{ private }


function TCompoundFile.GetLong(idx: integer): longint;

	begin
		GetLong:=(longint(block[idx+3]) shl 24)+(longint(block[idx+2]) shl 16)+(longint(block[idx+1]) shl 8)+longint(block[idx])
	end;


function TCompoundFile.ReadBlock(bnr: longint): boolean;

	begin
		if bnr<>blocknr then
			begin
				ReadBlock:=false;
				if fseek(bnr*512+512,comhdl,0)<0 then exit;
				if fread(comhdl,512,@block)<>512 then exit;
				blocknr:=bnr
			end;
		ReadBlock:=true
	end;


function TCompoundFile.GetNextBlockNr(bnr: longint): longint;
	var bidx: longint;

	begin
		GetNextBlockNr:=CF_ENDOFCHAIN;
		if bnr=CF_ENDOFCHAIN then exit;
		bidx:=bnr div 128;
		if (bidx<0) or (bidx>=num_of_bbd_blocks) then exit;
		if not(ReadBlock(bbd_list^[bidx])) then exit;
		GetNextBlockNr:=GetLong((bnr mod 128)*4)
	end;


function TCompoundFile.ReadHeader: boolean;
	label _fehler;

	var q: longint;

	begin
		ReadHeader:=false;
		comsize:=GetFileSize(comfname,comhdl);
		if (comsize mod 512)<>0 then exit;
		blocknr:=-2;
		if not(ReadBlock(-1)) then exit;
		if (block[0]<>$d0) or (block[1]<>$cf) or (block[2]<>$11) or
		   (block[3]<>$e0) or (block[4]<>$a1) or (block[5]<>$b1) or
		   (block[6]<>$1a) or (block[7]<>$e1) then exit;
		maxblock:=((comsize-1) div 512)-1;
		num_of_bbd_blocks:=GetLong($2c);
		root_startblock:=GetLong($30);
		sbd_startblock:=GetLong($3c);
		if num_of_bbd_blocks>0 then
			begin
				getmem(bbd_list,num_of_bbd_blocks shl 2);
				if bbd_list=nil then exit;
				for q:=0 to num_of_bbd_blocks-1 do bbd_list^[q]:=GetLong($4c+q);
			end;

		writeln('maxblock:          ',maxblock); { !!! }
		writeln('num_of_bbd_blocks: ',num_of_bbd_blocks); { !!! }
		writeln('root_startblock:   ',root_startblock); { !!! }
		writeln('sbd_startblock:    ',sbd_startblock); { !!! }
		for q:=0 to num_of_bbd_blocks-1 do
			writeln('bbd_list[',q,']:       ',bbd_list^[q]); { !!! }
		q:=root_startblock;
		write('Root-Chain:        ',q,' ');
		while q<>CF_ENDOFCHAIN do
			begin
				q:=GetNextBlockNr(q);
				write(q,' ')
			end;
		writeln;

		{ !!! }

		openflag:=true;
		ReadHeader:=true;
		exit;
		_fehler:
		{ bbd_list[] freigeben !!! }
	end;

{ *** TCOMPOUNDFILE *** }

end.