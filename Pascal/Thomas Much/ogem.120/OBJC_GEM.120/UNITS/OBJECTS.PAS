{**************************************
 *  O b j e c t G E M   Version 1.20  *
 *  Copyright 1992-94 by Thomas Much  *
 **************************************
 *        Unit  O B J E C T S         *
 **************************************
 *    Softdesign Computer Software    *
 *    Thomas Much, Gerwigstraûe 46,   *
 *  76131 Karlsruhe, (0721) 62 28 41  *
 *         Thomas Much @ KA2          *
 *  UK48@ibm3090.rz.uni-karlsruhe.de  *
 **************************************
 *    erstellt am:        13.07.1992  *
 *    letztes Update am:  29.05.1994  *
 **************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

  ObjectGEM wird mit dem _vollstÑndigen_ Quelltext ausgeliefert, d.h.
  jeder kann sich die Unit selbst compilieren, womit die extrem lÑstigen
  KompatibilitÑtsprobleme mit den PP-Releases beseitigt sind.
  ObjectGEM ist und bleibt aber trotzdem SHAREWARE, d.h. wer die Biblio-
  thek regelmÑûig benutzt, muû sich REGISTRIEREN lassen. DafÅr gibt es
  die neueste Version und - gegen einen geringen Aufpreis - auch ein
  gedrucktes Handbuch.

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


{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

unit Objects;

interface

uses

	OTypes;

type

	PObject           = ^TObject;
	TObject           = object
		public
		constructor Init;
		procedure Free;
		destructor Done; virtual;
	end;

	PCollection       = ^TCollection;
	TCollection       = object(TObject)
		public
		Items: PItemList;
		Count,
		Limit,
		Delta: longint;
		constructor Init(ALimit,ADelta: longint);
		destructor Done; virtual;
		function At(Index: longint): pointer; virtual;
		procedure AtDelete(Index: longint); virtual;
		procedure AtFree(Index: longint); virtual;
		procedure AtInsert(Index: longint; Item: pointer); virtual;
		procedure AtPut(Index: longint; Item: pointer); virtual;
		procedure Delete(Item: pointer); virtual;
		procedure Error(Code,Info: longint); virtual;
		procedure DeleteAll; virtual;
		function FirstThat(Test: PIterationFunc): pointer;
		procedure ForEach(Action: PIterationProc);
		procedure Free(Item: pointer);
		procedure FreeAll; virtual;
		procedure FreeItem(Item: pointer); virtual;
		function IndexOf(Item: pointer): longint; virtual;
		procedure Insert(Item: pointer); virtual;
		function LastThat(Test: PIterationFunc): pointer; virtual;
		procedure Pack; virtual;
		procedure SetLimit(ALimit: longint); virtual;
	end;

	PSortedCollection = ^TSortedCollection;
	TSortedCollection = object(TCollection)
		public
		Duplicates: boolean;
		constructor Init(ALimit,ADelta: longint);
		function IndexOf(Item: pointer): longint; virtual;
		procedure Insert(Item: pointer); virtual;
		function Compare(Key1,Key2: pointer): integer; virtual;
		function KeyOf(Item: pointer): pointer; virtual;
		function Search(Key: pointer; var Index: longint): boolean; virtual;
	end;

	PStringCollection = ^TStringCollection;
	TStringCollection = object(TSortedCollection)
		public
		constructor Init(ALimit,ADelta: longint);
		procedure FreeItem(Item: pointer); virtual;
		function Compare(Key1,Key2: pointer): integer; virtual;
	end;

	PStrCollection    = ^TStrCollection;
	TStrCollection    = object(TStringCollection)
		public
		procedure FreeItem(Item: pointer); virtual;
		function Compare(Key1,Key2: pointer): integer; virtual;
	end;



implementation

uses

	Strings,OProcs;


{ *** Objekt TOBJECT *** }

constructor TObject.Init;

  begin
  end;


procedure TObject.Free;

	begin
		dispose(PObject(@self),Done)
	end;


destructor TObject.Done;

  begin
  end;

{ *** TOBJECT *** }



{ *** Objekt TCOLLECTION *** }

constructor TCollection.Init(ALimit,ADelta: longint);

	begin
		if not(inherited Init) then fail;
		Items:=nil;
		Count:=0;
		Limit:=0;
		Delta:=ADelta;
		if Delta<0 then Delta:=0;
		SetLimit(ALimit)
	end;


destructor TCollection.Done;

	begin
		FreeAll;
		SetLimit(0);
		inherited Done
	end;


function TCollection.At(Index: longint): pointer;

	begin
		if (Index<0) or (Index>=Count) then
			begin
				At:=nil;
				Error(coIndexError,Index)
			end
		else
			At:=Items^[Index]
	end;


procedure TCollection.AtDelete(Index: longint);
	var q: longint;

	begin
		if (Index<0) or (Index>=Count) then Error(coIndexError,Index)
		else
			begin
				if Index<Count-1 then
					for q:=Index to (Count-2) do Items^[q]:=Items^[q+1];
				dec(Count)
			end
	end;


procedure TCollection.AtFree(Index: longint);
	var p: pointer;

	begin
		p:=At(Index);
		AtDelete(Index);
		FreeItem(p)
	end;


procedure TCollection.AtInsert(Index: longint; Item: pointer);
	var q: longint;

	begin
		if (Index<0) or (Index>Count) then Error(coIndexError,Index)
		else
			begin
				if Count=Limit then SetLimit(Limit+Delta);
				if Count<Limit then
					begin
						if Index<Count then
							for q:=Count downto Index+1 do Items^[q]:=Items^[q-1];
						Items^[Index]:=Item;
						inc(Count)
					end
				else
					if Delta=0 then Error(coIndexError,Index)
			end
	end;


procedure TCollection.AtPut(Index: longint; Item: pointer);

	begin
		if (Index<0) or (Index>=Count) then Error(coIndexError,Index)
		else
			Items^[Index]:=Item
	end;


procedure TCollection.Delete(Item: pointer);

	begin
		AtDelete(IndexOf(Item))
	end;


procedure TCollection.Error(Code,Info: longint);

	begin
		case Code of
			coIndexError: write('Index Range Error (',Info,') ');
			coOverflow:   write('Collection Overflow (',Info,') ')
		end;
		runerror(212-Code)
	end;


procedure TCollection.DeleteAll;

	begin
		Count:=0
	end;


function TCollection.FirstThat(Test: PIterationFunc): pointer;
	var q : longint;
	    p : pointer;
	    cl: IterationFunc;

	begin
		FirstThat:=nil;
		cl:=IterationFunc(Test);
		if Count>0 then
			for q:=0 to Count-1 do
				begin
					p:=At(q);
					if p<>nil then
						if cl(p) then
							begin
								FirstThat:=p;
								exit
							end
				end
	end;


procedure TCollection.ForEach(Action: PIterationProc);
	var q : longint;
	    p : pointer;
	    cl: IterationProc;

	begin
		cl:=IterationProc(Action);
		if Count>0 then
			for q:=0 to Count-1 do
				begin
					p:=At(q);
					if p<>nil then cl(p)
				end
	end;


procedure TCollection.Free(Item: pointer);

	begin
		Delete(Item);
		FreeItem(Item)
	end;


procedure TCollection.FreeAll;
	var q: longint;

	begin
		if Count>0 then
			for q:=0 to Count-1 do FreeItem(At(q));
		Count:=0
	end;


procedure TCollection.FreeItem(Item: pointer);

	begin
		if Item<>nil then PObject(Item)^.Free
	end;


function TCollection.IndexOf(Item: pointer): longint;
	var q: longint;

	begin
		IndexOf:=-1;
		if Count>0 then
			for q:=0 to Count-1 do
				if Item=At(q) then
					begin
						IndexOf:=q;
						exit
					end
	end;


procedure TCollection.Insert(Item: pointer);

	begin
		AtInsert(Count,Item)
	end;


function TCollection.LastThat(Test: PIterationFunc): pointer;
	var q : longint;
	    p : pointer;
	    cl: IterationFunc;

	begin
		LastThat:=nil;
		cl:=IterationFunc(Test);
		if Count>0 then
			for q:=Count-1 downto 0 do
				begin
					p:=At(q);
					if p<>nil then
						if cl(p) then
							begin
								LastThat:=p;
								exit
							end
				end
	end;


procedure TCollection.Pack;
	label _again;

	var low,cur,pc,q: longint;

	begin
		if Count>0 then
			begin
				pc:=Count-1;
				low:=0;
				_again:
				while (Items^[low]<>nil) and (low<pc) do inc(low);
				cur:=low;
				while (Items^[cur]=nil) and (cur<pc) do inc(cur);
				if cur<pc then
					begin
						for q:=low to cur-1 do Items^[q]:=Items^[q+1];
						Items^[cur]:=nil;
						goto _again
					end;
				low:=0;
				while (low<Count) and (Items^[low]<>nil) do inc(low);
				Count:=low
			end;
		SetLimit(0)
	end;


procedure TCollection.SetLimit(ALimit: longint);
	var dummy: PItemList;
	    q    : longint;

	begin
		if ALimit<Count then ALimit:=Count;
		if ALimit>MaxCollectionSize then ALimit:=MaxCollectionSize;
		if ALimit<>Limit then
			begin
				dummy:=nil;
				if ALimit>0 then getmem(dummy,ALimit shl 2);
				if (dummy<>nil) or (ALimit=0) then
					begin
						if (Items<>nil) and (dummy<>nil) and (Count>0) then
							for q:=0 to Count-1 do dummy^[q]:=Items^[q];
						if Items<>nil then freemem(Items,Limit shl 2);
						Limit:=ALimit;
						Items:=dummy
					end
				else
					if ALimit>Limit then Error(coOverflow,ALimit)
			end
	end;

{ *** TCOLLECTION *** }



{ *** Objekt TSORTEDCOLLECTION *** }

constructor TSortedCollection.Init(ALimit,ADelta: longint);

	begin
		if not(inherited Init(ALimit,ADelta)) then fail;
		Duplicates:=false
	end;


function TSortedCollection.IndexOf(Item: pointer): longint;
	var i: longint;

	begin
		if Search(KeyOf(Item),i) then IndexOf:=i
		else
			IndexOf:=-1
	end;


procedure TSortedCollection.Insert(Item: pointer);
	var i: longint;

	begin
		if not(Search(KeyOf(Item),i)) then AtInsert(i,Item)
		else
			begin
				if Duplicates then AtInsert(i,Item)
				else
					begin
						FreeItem(At(i));
						AtPut(i,Item)
					end;
			end
	end;


function TSortedCollection.Compare(Key1,Key2: pointer): integer;

	begin
		Compare:=0;
		Abstract
	end;


function TSortedCollection.KeyOf(Item: pointer): pointer;

	begin
		KeyOf:=Item
	end;


function TSortedCollection.Search(Key: pointer; var Index: longint): boolean;
	var cur,low,high: longint;

	begin
		Search:=false;
		if Count>0 then
			begin
				low:=0;
				high:=Count-1;
				cur:=high shr 1;
				repeat
					case Compare(Key,KeyOf(At(cur))) of
						0: begin
								 Index:=cur;
								 Search:=true;
								 exit
							 end;
						1: if low=high then
								 begin
									 Index:=cur+1;
									 exit
								 end
							 else
								 begin
									 low:=cur+1;
									 if low>high then low:=high;
									 cur:=(low+high) shr 1
								 end;
						-1: if low=high then
									begin
										Index:=cur;
										exit
									end
								else
									begin
										high:=cur-1;
										if high<low then high:=low;
										cur:=(low+high) shr 1
									end
					end
				until false
			end
		else
			Index:=0
	end;

{ *** TSORTEDCOLLECTION *** }



{ *** Objekt TSTRINGCOLLECTION *** }

constructor TStringCollection.Init(ALimit,ADelta: longint);

	begin
		if not(inherited Init(ALimit,ADelta)) then fail;
		Duplicates:=true
	end;


procedure TStringCollection.FreeItem(Item: pointer);

	begin
		DisposeStr(PString(Item))
	end;


function TStringCollection.Compare(Key1,Key2: pointer): integer;

	begin
		if PString(Key1)^>PString(Key2)^ then Compare:=1
		else
			if PString(Key1)^<PString(Key2)^ then Compare:=-1
			else
				Compare:=0
	end;

{ *** TSTRINGCOLLECTION *** }



{ *** Objekt TSTRCOLLECTION *** }

procedure TStrCollection.FreeItem(Item: pointer);

	begin
		ChrDispose(PChar(Item))
	end;


function TStrCollection.Compare(Key1,Key2: pointer): integer;

	begin
		Compare:=Sgn(StrComp(Key1,Key2))
	end;

{ *** TSTRCOLLECTION *** }


end.