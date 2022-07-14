{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *        Unit  O V A L I D A T         *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        13.07.1992  *
 *      letztes Update am:  11.09.1997  *
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

unit OValidat;

interface

uses

	Objects,OTypes,OWindows;

type

	PFilterValidator       = ^TFilterValidator;
	TFilterValidator       = object(TValidator)
		public
		ValidChars: TCharSet;
		constructor Init(ValidCharSet: TCharSet);
		procedure Error; virtual;
		function IsValid(s: string): boolean; virtual;
		function IsValidInput(var s: string; SuppressFill: boolean): boolean; virtual;
	end;

	PRangeValidator        = ^TRangeValidator;
	TRangeValidator        = object(TFilterValidator)
		public
		Min,
		Max: longint;
		constructor Init(AMin,AMax: longint);
		procedure Error; virtual;
		function IsValid(s: string): boolean; virtual;
		function IsValidInput(var s: string; SuppressFill: boolean): boolean; virtual;
	end;

	PLookupValidator       = ^TLookupValidator;
	TLookupValidator       = object(TValidator)
		public
		function IsValid(s: string): boolean; virtual;
		function Lookup(s: string): boolean; virtual;
	end;

	PStringLookupValidator = ^TStringLookupValidator;
	TStringLookupValidator = object(TLookupValidator)
		public
		Strings: PStringCollection;
		constructor Init(AString: PStringCollection);
		destructor Done; virtual;
		procedure Error; virtual;
		function Lookup(s: string): boolean; virtual;
		procedure NewStringList(AString: PStringCollection); virtual;
	end;

	PPXPictureValidator    = ^TPXPictureValidator;
	TPXPictureValidator    = object(TValidator)
		public
		Pic: PString;
		constructor Init(APic: string; AutoFill: boolean);
		destructor Done; virtual;
		procedure Error; virtual;
		function IsValid(s: string): boolean; virtual;
		function IsValidInput(var s: string; SuppressFill: boolean): boolean; virtual;
		function Picture(var Input: string; AutoFill: boolean): TPicResult; virtual;
	end;



implementation

uses

	OProcs;


{ *** Objekt TFILTERVALIDATOR *** }

constructor TFilterValidator.Init(ValidCharSet: TCharSet);

	begin
		if not(inherited Init) then fail;
		Options:=voOnEdit;
		ValidChars:=ValidCharSet
	end;


procedure TFilterValidator.Error;

	begin
		if Application<>nil then
			with Application^ do
				begin
					if Attr.Country=FRA then
						Alert(Window,1,NOTE,'Caractäres invalides entrÇs.','  &OK  ')
					else if (Attr.Country=FRG) or (Attr.Country=SWG) then
						Alert(Window,1,NOTE,'Die Eingabe enthÑlt ungÅltige Zeichen.','  &OK  ')
					else
						Alert(Window,1,NOTE,'Invalid characters in input.','  &OK  ')
				end
	end;


function TFilterValidator.IsValid(s: string): boolean;
	var q  : integer;
	    vld: boolean;

	begin
		vld:=inherited IsValid(s);
		if vld then
			for q:=1 to length(s) do
				if not(s[q] in ValidChars) then vld:=false;
		IsValid:=vld
	end;


function TFilterValidator.IsValidInput(var s: string; SuppressFill: boolean): boolean;
	var q: integer;

	begin
		IsValidInput:=true;
		if length(s)>0 then
			for q:=1 to length(s) do
				if not(s[q] in ValidChars) then
					begin
						if upcase(s[q]) in ValidChars then s[q]:=upcase(s[q])
						else
							IsValidInput:=false
					end
	end;

{ *** TFILTERVALIDATOR *** }



{ *** Objekt TRANGEVALIDATOR *** }

constructor TRangeValidator.Init(AMin,AMax: longint);

	begin
		if not(inherited Init(['0'..'9','+','-'])) then fail;
		Options:=Options and not(voOnEdit);
		Min:=AMin;
		Max:=AMax;
		if Min>=0 then ValidChars:=ValidChars-['-']
	end;


procedure TRangeValidator.Error;

	begin
		if Application<>nil then
			with Application^ do
				begin
					if Attr.Country=FRA then
						Alert(Window,1,NOTE,' Valeur non comprise entre | '+ltoa(Min)+' et '+ltoa(Max)+'.','  &OK  ')
					else if (Attr.Country=FRG) or (Attr.Country=SWG) then
						Alert(Window,1,NOTE,' Wert ist nicht im Bereich | von '+ltoa(Min)+' bis '+ltoa(Max)+'.','  &OK  ')
					else
						Alert(Window,1,NOTE,' Value is not in the range | '+ltoa(Min)+' to '+ltoa(Max)+'.','  &OK  ')
			end
	end;


function TRangeValidator.IsValid(s: string): boolean;
	var value: longint;

	begin
		StrPTrim(s);
		if inherited IsValid(s) then
			begin
				value:=atol(s);
				IsValid:=(value>=Min) and (value<=Max)
			end
		else
			IsValid:=false
	end;


function TRangeValidator.IsValidInput(var s: string; SuppressFill: boolean): boolean;
	var value: longint;

	begin
		if inherited IsValidInput(s,SuppressFill) then
			begin
				value:=atol(s);
				IsValidInput:=(value>=Min) and (value<=Max)
			end
		else
			IsValidInput:=false
	end;

{ *** TRANGEVALIDATOR *** }



{ *** Objekt TLOOKUPVALIDATOR *** }

function TLookupValidator.IsValid(s: string): boolean;
	var vald: boolean;

	begin
		vald:=Lookup(s);
		if vald then
			if bTst(Options,voNotEmpty) then
				vald:=length(s)>0;
		IsValid:=vald
	end;


function TLookupValidator.Lookup(s: string): boolean;

	begin
		Lookup:=true
	end;

{ *** TLOOKUPVALIDATOR *** }



{ *** Objekt TSTRINGLOOKUPVALIDATOR *** }

constructor TStringLookupValidator.Init(AString: PStringCollection);

	begin
		if not(inherited Init) then fail;
		Strings:=AString
	end;


destructor TStringLookupValidator.Done;

	begin
		NewStringList(nil);
		inherited Done
	end;


procedure TStringLookupValidator.Error;

	begin
		if Application<>nil then
			with Application^ do
				begin
					if Attr.Country=FRA then
						Alert(Window,1,NOTE,'L''entrÇe n''est pas dans la liste valide.','  &OK  ')
					else if (Attr.Country=FRG) or (Attr.Country=SWG) then
						Alert(Window,1,NOTE,'Die Eingabe ist nicht gÅltig.','  &OK  ')
					else
						Alert(Window,1,NOTE,'Input not in valid-list.','  &OK  ')
			end
	end;


function TStringLookupValidator.Lookup(s: string): boolean;
	var dummy: longint;

	begin
		if Strings<>nil then Lookup:=Strings^.Search(@s,dummy)
		else
			Lookup:=false
	end;


procedure TStringLookupValidator.NewStringList(AString: PStringCollection);

	begin
		if Strings<>nil then Dispose(Strings,Done);
		Strings:=AString
	end;

{ *** TSTRINGLOOKUPVALIDATOR *** }



{ *** Objekt TPXPICTUREVALIDATOR *** }

constructor TPXPictureValidator.Init(APic: string; AutoFill: boolean);
	var dummy: string;

	begin
		inherited Init;
		Pic:=NewStr(APic);
		Options:=voOnAppend;
		if AutoFill then Options:=Options or voFill;
		dummy:='';
		if Picture(dummy,false)<>prEmpty then Status:=vsSyntax
	end;


destructor TPXPictureValidator.Done;

	begin
		DisposeStr(Pic);
		inherited Done
	end;


procedure TPXPictureValidator.Error;

	begin
		if Application<>nil then
			with Application^ do
				begin
					if Attr.Country=FRA then
						Alert(Window,1,NOTE,'EntrÇe non conforme Ö|'+Pic^,'  &OK  ')
					else if (Attr.Country=FRG) or (Attr.Country=SWG) then
						Alert(Window,1,NOTE,'Die Eingabe paût nicht auf|'+Pic^,'  &OK  ')
					else
						Alert(Window,1,NOTE,'Input does not conform to|'+Pic^,'  &OK  ')
			end
	end;


function TPXPictureValidator.IsValid(s: string): boolean;
	var res: TPicResult;

	begin
		res:=Picture(s,false);
		if bTst(Options,voNotEmpty) and ((res=prEmpty) or (length(s)=0)) then
			begin
				IsValid:=false;
				exit
			end;
		IsValid:=(Pic=nil) or (res=prComplete) or (res=prEmpty)
	end;


function TPXPictureValidator.IsValidInput(var s: string; SuppressFill: boolean): boolean;

	begin
		IsValidInput:=(Pic=nil) or (Picture(s,bTst(Options,voFill) and not(SuppressFill))<>prError)
	end;


function TPXPictureValidator.Picture(var Input: string; AutoFill: boolean): TPicResult;
	const special: set of char = [';','*','[',']','{','}',','];

	var q,k1,k2,mip: integer;
	    outp       : string;
	    ret        : TPicResult;

	function check(inpt,mask: string; var out: string): TPicResult;
		label _getph;

		var ph,aus             : string;
		    c,d,ip,mp,bis,letzt: integer;
		    gueltig            : boolean;
		    cnt                : longint;
		    r                  : TPicResult;

		begin
			{ AusfÅllen verhindern + AutoFill beachten... }
			k2:=0;
			c:=1;
			while c<=length(mask) do
				begin
					case mask[c] of
						';': inc(c);
						'[': inc(k2);
						']': dec(k2)
					end;
					inc(c)
				end;
			if k2<>0 then
				begin
					check:=prSyntax;
					exit
				end
			else
				check:=prIncomplete;
			aus:=out;
			mp:=1;
			ip:=1;
			while mp<=length(mask) do
				begin
					case mask[mp] of
						'}',']': begin
											 check:=prAmbiguous;
											 exit
								     end;
						',': begin
									 check:=prSyntax;
									 exit
						     end;
						';': begin
									 ph:=mask[mp+1];
									 inc(mp,2);
									 goto _getph
								 end;
						'*': begin
						       c:=mp+1;
						       cnt:=0;
						       while mask[c] in ['0'..'9'] do
						         begin
						           cnt:=cnt*10+ord(mask[c])-48;
						           inc(c)
						         end;
						       mp:=c;
						       inc(c);
						       letzt:=mp;
						       case mask[mp] of
						         '[': begin
						                check:=prSyntax;
						                exit
						              end;
						         '{': begin
						                bis:=1;
														while bis>0 do
															begin
																case mask[c] of
															  	';': inc(c);
																	'{': inc(bis);
																	'}': dec(bis)
																end;
																inc(c)
															end;
														letzt:=c-1
													end
						       end;
						       if (letzt=mp) or (letzt-mp>1) then
						         begin
								       if cnt=0 then
								         repeat
													 r:=check(StrPRight(inpt,length(inpt)+1-ip),copy(mask,mp,letzt+1-mp),aus);
													 if r=prComplete then inc(ip,mip-1)
								         until r<>prComplete
								       else
								         for d:=1 to cnt do
													 if check(StrPRight(inpt,length(inpt)+1-ip),copy(mask,mp,letzt+1-mp),aus)=prComplete then
													   inc(ip,mip-1)
								           else
								             begin
								               check:=prError;
								               exit
										         end
							       end;
									 mp:=c
								 end;
						'[': begin
									 c:=mp+1;
									 bis:=1;
									 while bis>0 do
										 begin
											 case mask[c] of
											   ';': inc(c);
												 '[': inc(bis);
												 ']': dec(bis)
											 end;
											 inc(c)
										 end;
									 if c-mp>2 then
										 if check(StrPRight(inpt,length(inpt)+1-ip),copy(mask,mp+1,c-mp-2),aus)=prComplete then
										   inc(ip,mip-1);
									 mp:=c
						     end;
						'{': begin
									 c:=mp+1;
									 bis:=1;
									 while bis>0 do
										 begin
											 case mask[c] of
											   ';': inc(c);
												 '{': inc(bis);
												 '}': dec(bis)
											 end;
											 inc(c)
										 end;
									 d:=mp+1;
									 letzt:=d;
									 bis:=1;
									 gueltig:=false;
									 while (bis>0) and not(gueltig) do
									   begin
											 case mask[d] of
											   ';': inc(d);
												 '{': inc(bis);
												 '}': dec(bis);
												 ',': if bis=1 then
												        if d-letzt>0 then
													        begin
													          if check(StrPRight(inpt,length(inpt)+1-ip),copy(mask,letzt,d-letzt),aus)=prComplete then
													            begin
													            	inc(ip,mip-1);
													              gueltig:=true
													            end;
													          letzt:=d+1
													        end
											 end;
											 inc(d)
									   end;
									 if not(gueltig) then
										 if d-letzt>1 then
									     begin
												 if check(StrPRight(inpt,length(inpt)+1-ip),copy(mask,letzt,d-letzt-1),aus)=prComplete then
												   inc(ip,mip-1)
							           else
							             begin
							               check:=prError;
							               exit
									         end
									     end;
									 mp:=c
						     end
					else
						begin
							ph:='';
							_getph:
							while not(mask[mp] in special) and (mp<=length(mask)) do
								begin
									ph:=ph+mask[mp];
									inc(mp)
								end;
							if length(inpt)+1-ip<length(ph) then bis:=length(inpt)-ip
							else
								bis:=length(ph)-1;
							for c:=0 to bis do
								begin
									case ph[c+1] of
										'#': if not(inpt[ip+c] in ['0'..'9']) then
												   begin
														 check:=prError;
														 exit
												   end
												 else
												 	aus:=aus+inpt[ip+c];
										'?': if not(UpChar(inpt[ip+c]) in ['A'..'Z','é','ô','ö']) then
													 begin
														 check:=prError;
														 exit
													 end
												 else
													 aus:=aus+inpt[ip+c];
										'&': if not(UpChar(inpt[ip+c]) in ['A'..'Z','é','ô','ö']) then
													 begin
														 check:=prError;
														 exit
													 end
												 else
													 aus:=aus+UpChar(inpt[ip+c]);
										'@': aus:=aus+inpt[ip+c];
										'!': aus:=aus+UpChar(inpt[ip+c])
									else
										begin
											if UpChar(ph[c+1])=UpChar(inpt[ip+c]) then aus:=aus+ph[c+1]
											else
												begin
													check:=prError;
													exit
												end
										end
									end
								end;
							if bis<length(ph)-1 then exit;
							inc(ip,bis+1)
						end
					end
				end;
			mip:=ip;
			out:=aus;
			check:=prComplete
		end;

	begin
		if Pic=nil then
			begin
				Picture:=prError;
				exit
			end;
		Picture:=prSyntax;
		q:=length(Pic^);
		if (q=0) or (q>253) then exit;
		k1:=0;
		while (Pic^[q]=';') and (q>0) do
			begin
				inc(k1);
				dec(q)
			end;
		if odd(k1) then exit;
		if StrPRight(Pic^,1)='*' then
			begin
				q:=length(pic^)-1;
				k1:=0;
				while (Pic^[q]=';') and (q>0) do
					begin
						inc(k1);
						dec(q)
					end;
				if not(odd(k1)) then exit
			end;
		q:=1;
		k1:=0;
		k2:=0;
		while q<=length(Pic^) do
			begin
				case Pic^[q] of
					';': inc(q);
					'{': inc(k1);
					'}': dec(k1);
					'[': inc(k2);
					']': dec(k2)
				end;
				inc(q)
			end;
		if (k1<>0) or (k2<>0) then exit;
		if length(Input)=0 then
			begin
				Picture:=prEmpty;
				exit
			end;
		outp:='';
		ret:=check(Input,'{'+Pic^+'}',outp);
		if mip<=length(Input) then ret:=prAmbiguous;
		if (ret=prComplete) or (ret=prIncomplete) then Input:=outp;
		Picture:=ret
	end;

{ *** Objekt TPXPICTUREVALIDATOR *** }

end.