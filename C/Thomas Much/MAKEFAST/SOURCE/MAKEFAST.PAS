program MakeFast;
  {$B-,D-,G-,I-,L-,N-,R-,S-,V-,X+}
  { Copyright (c)1992 by Softdesign Computer Software
                               written by Thomas Much }
  { wer sich eingehender mit den FastLoad-Flags beschÑftigen
    mîchte, sollte sich einmal das ST-STE-TT-Profibuch ansehen! }

  uses Gem,GObjects; { ObjectGEM immer als letzte Unit einbinden,
                       allerdings noch vor auf GObjects zugreifenden
                       Units! }

	const
	      {$I makefast.i}  { Konstanten fÅr die Dialogbox }

	      PH_FASTLOAD  = 1;       { die Fastload-Flags... }
	      PH_LOADALT   = 2;
	      PH_MALLOCALT = 4;

  type PH = record
							ph_branch  : word;     { Programmheader }
							ph_tlen    : longint;
							ph_dlen    : longint;
							ph_blen    : longint;
							ph_slen    : longint;
							ph_res1    : longint;
							ph_prgflags: longint;
							ph_absflag : word;
						end;

			 TMFApplication = object(TApplication)
			 										{ der neue Anwendungs-Objekt-TYP }
													procedure InitInstance; virtual;
  												procedure InitMainWindow; virtual;
  												procedure HandleAV(Pipe: Pipearray); virtual;
  											end;

			 PMFDialog  = ^TMFDialog;
			 TMFDialog = object(TDialog)
			 							 { der eigentliche Dialog }
										 ttmem                  : integer;
										 datei,pfad             : string;
										 st1,st2,st3,st4        : PStatic;
										 cb1,cb2,cb3            : PCheckBox;
										 pb1,pb2,pb3,pb4,pb5,pb6: PButton;
										 phrec                  : PH;
										 f                      : file of PH;
										 procedure GetWindowClass(var AWndClass: TWndClass); virtual;
										 procedure SetupWindow; virtual;
										 function ExitDlg(AnIndx: integer): boolean; virtual;
										 function OK: boolean; virtual;
										 function Help: boolean; virtual;
										 { neue Routinen... }
										 procedure UpdateAmount; virtual;
										 procedure DisableAll; virtual;
										 procedure Load(dname: string); virtual;
									 end;

  var MFApplication: TMFApplication;
  									 { das Anwendungs-Objekt;
  									   dies sollte das EINZIGE statische Objekt
  									   sein, alle anderen werden normalerweise
  									   dynamisch verwaltet! }


procedure MFResource; external; {$L mfrsc.o}
	{ die Resource wird ins Programm eingebunden (wichtig fÅr ACCs) }


procedure TMFApplication.InitInstance;

	begin
		{ wird eine Anwendung das erste Mal in den Speicher geladen,
		  wird die Methode InitApplication aufgerufen, die u.a. die
		  boolean-Variable FirstInstance setzt; danach wird InitInstance
		  aufgerufen;
		  wird die Anwendung ein zweites Mal geladen (z.B. zuerst als ACC
		  und dann als Prg), wird NUR diese Methode InitInstance von
		  dem Konstruktor Init aufgerufen! }
		InitResource(@MFResource);
		{ die im Prg eingebundene Resource wird initialisiert;
		  soll das RSC-File nachgeladen werden, wird statt InitResource()
		  einfach LoadResource(datei) aufgerufen }
		TApplication.InitInstance
		{ Standard-Initialisierungen, setzt Schnittstellenobjekt fÅr
		  <Control>+<Q>-Tastenkombination und ruft InitMainWindow auf }
	end;


procedure TMFApplication.InitMainWindow;
	var p: PMFDialog;

	begin
		{ InitMainWindow legt ein "ganz einfaches" GEM-Fenster an und wird
		  deshalb eigentlich immer Åberschrieben, um ein abgeleitetes Fenster-
		  objekt zu installieren;
		  dieser Aufruf ist insofern besonders, als daû wir kein FENSTER,
		  sondern einen DIALOG als "MainWindow" anmelden; dieser wird zwar
		  normalerweise in einem Fenster dargestellt, sollte allerdings kein
		  Fenster-Handle mehr verfÅgbar sein, macht ObjectGEM daraus auto-
		  matisch (zur Laufzeit) einen MODALEN Dialog! }
		p:=new(PMFDialog,Init(nil,'ObjectGEM MakeFast',MFDLG));
		{ der Dialog trÑgt sich selbstÑndig in die Fensterliste ein;
		  MainWindow zeigt immer auf das erste installierte TWindow-Objekt
		  (in diesem Fall auf einen Nachfahren);
		  dem Konstruktor wird das Parent-Objekt (in diesem Fall nil, es
		  existiert also kein Parent), der Fenstertitel und der Index des
		  Dialogbaums Åbergeben }
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
			{ irgendwas ist schiefgelaufen, nicht initialisieren;
			  ObjectGEM prÅft dann, wie und ob (ACCs!) das Programm
			  verlassen wird }
		else
			begin
				{ p zeigt auf den Dialog; nun werden die Schnittstellen-
				  objekte initialisiert; diese tragen sich in die Liste
				  der TControl-Objekte im Dialog-Objekt ein und werden
				  dadurch beim freigeben des Dialogs automatisch mitge-
				  lîscht }
				{ die RÅckgabe-Pointer werden gespeichert, um spÑter die
				  Objekte mit ihren eigenen Methoden zu modifizieren! }
				p^.st1:=new(PStatic,Init(p,MFNAME,20,false,'Zeigt den Namen des ausgewÑhlten|Programms (ohne Laufwerk+Pfad) an.'));
				{ einfacher Text, Åbergeben wird u.a. die max. LÑnge des Textes+1
				  (Nullbyte), einen boolean-Wert, der angibt, ob der Text unter-
				  strichen wird, und der String fÅr BubbleHelp (!);
				  bringen Sie den Mauscursor doch mal Åber einen Button und
				  drÅcken Sie dann <Help> ...!?!!! }
				p^.st2:=new(PStatic,Init(p,MFMINDT,0,false,'Gibt an, wieviel TT-RAM (Alternate|RAM) dem Programm genÅgt, wenn mehr|ST-RAM als TT-RAM vorhanden ist.'));
				p^.st3:=new(PStatic,Init(p,MFAMOUNT,8,false,'Gibt an, wieviel TT-RAM (Alternate|RAM) dem Programm genÅgt, wenn mehr|ST-RAM als TT-RAM vorhanden ist.'));
				p^.st4:=new(PStatic,Init(p,MFVER,39,false,'ObjectGEM MakeFast ist Freeware, d.h. Sie dÅrfen|das Programm kostenlos kopieren und benutzen.|énderungen am Programm sind nicht erlaubt!'));
				p^.cb1:=new(PCheckBox,Init(p,MFFAST,true,'Bestimmt das FastLoad-Flag.|Ist es gesetzt, wird beim Programmstart nur die BSS|gelîscht. Das Flag sollte bei mindestens je einem|Auto-Ordner-Programm und Accessory NICHT gesetzt sein!'));
				{ ankreuzbare Box; der boolean-Wert gibt an, ob die CheckBox
				  im "neuen" Stil gezeichnet wird; ist in der Resource das
				  CROSSED-Attribut gesetzt, wird statt des HÑkchens ein
				  Kreuzchen verwendet }
				p^.cb2:=new(PCheckBox,Init(p,MFPROG,true,'Das Programm darf in das (schnelle)|TT-RAM geladen werden. Vorsicht, wenn das Pro-|gramm z.B. den Bildschirmspeicher verschiebt!'));
				p^.cb3:=new(PCheckBox,Init(p,MFMEM,true,'Malloc()-Anforderungen des Programms dÅrfen aus dem|TT-RAM bedient werden. Vorsicht bei Programmen,|die z.B. den Bildschirmspeicher verschieben!'));
				p^.pb1:=new(PButton,Init(p,MFDATEI,id_No,true,'WÑhlt ein neues Programm|zum Bearbeiten aus.'));
				{ ein PushButton }
				p^.pb2:=new(PButton,Init(p,MFMAKE,id_No,true,'Schreibt die neuen Werte in|das ausgewÑhlte Programm.'));
				p^.pb3:=new(PButton,Init(p,MFOK,id_OK,true,'VerlÑût MakeFast.'));
				{ id_OK bedeutet, daû dies der OK-Button ist;
				  beim Anklicken wird dadurch die TDialog.OK-Methode aufgerufen }
				p^.pb4:=new(PButton,Init(p,MFLESS,id_No,false,'Vermindert den TT-RAM-Bedarf um 128 KB.'));
				p^.pb5:=new(PButton,Init(p,MFMORE,id_No,false,'Erhîht den TT-RAM-Bedarf um 128 KB.'));
				p^.pb6:=new(PButton,Init(p,MFHELP,id_Help,false,'Zeigt einen allgemeinen Hilfstext an.'));
				p^.st4^.SetText('VERSION 1.0 VOM 29.09.1992 (FREEWARE!)');
				{ Text setzen (TStatic-Methode) }
				p^.UpdateAmount;
				p^.DisableAll;
				if AppFlag then p^.MakeWindow
				{ wenn wir kein ACC sind, wird das Fenster sofort
				  geîffnet, sonst wartet ObjectGEM auf das Eintreffen
				  einer AC_OPEN-Message }
			end
	end;


procedure TMFApplication.HandleAV(Pipe: Pipearray);

	begin
		{ ObjectGEM verarbeitet AUTOMATISCH das AV- und XAcc-Protokoll }
		if (pipe[0]=VA_START) or (pipe[0]=VA_DRAGACCWIND) then
			PMFDialog(MainWindow)^.Load(Attr.rpTail^)
		{ beim Eintreffen dieser AV-Messages aktualisiert ObjectGEM
		  die Kommandozeile, die wir hier als neuen Programmnamen auffassen }
	end;


procedure TMFDialog.GetWindowClass(var AWndClass: TWndClass);

	begin
		TDialog.GetWindowClass(AWndClass);
		{ initialisiert die Dialog-Klasse;
		  wenn Sie dies vergessen, werden Sie die seltsamsten
		  SystemabstÅrze erleben (vertrauen Sie mir, ich weiû,
		  was ich erlebt habe...);
		  bei OOP kommt es oft vor, daû Vorfahren aufgerufen
		  werden; wann dies geschehen kann, muû oder unterbleiben
		  sollte, wird in der ObjectGEM-Dokumentation (bzw. in der
		  Online-Help) beschrieben sein }
		AWndClass.Style:=AWndClass.Style or cs_CreateOnAccOpen
		{ da wir einen Dialog als "Hauptfenster" verwenden, mÅssen
		  wir ObjectGEM sagen, daû dieser Dialog bei einer AC_OPEN-
		  Message (also bei Anwahl des Accessory-MenÅeintrags) ge-
		  îffnet werden soll; normalerweise werden in diesem Fall nur
		  Fenster geîffnet, da es recht stîrend ist, wenn alle irgend-
		  wann verwendeten Dialoge automatisch geîffnet werden;
		  andererseits kînnen Sie natÅrlich auch Fenster vom auto-
		  matischen ôffnen ausnehmen, indem Sie das Flag in der Fenster-
		  Klasse lîschen }
	end;


procedure TMFDialog.SetupWindow;

	begin
		{ diese Methode wird vom Init-Konstruktor des Dialogs aufgerufen }
		TDialog.SetupWindow;
		{ initialisiert Schnittstellenobjekte fÅr <Control>+<F>,
		  <Control>+<U> und <Control>+<W> }
		ttmem:=0;
		{ TT-RAM-Bedarf = minimal }
		datei:='';
		pfad:=''
		{ zu Anfang ist keine Datei geladen }
	end;


function TMFDialog.ExitDlg(AnIndx: integer): boolean;

	begin
		{ beim Anklicken eines PushButtons wird die EndDlg-Methode
		  aufgerufen; diese versucht, den Button einem Schnittstellen-
		  objekt zuzuordnen (z.B. wird beim OK-Button [id_OK] auto-
		  matisch die OK-Methode [s.u.] aufgerufen);
		  konnte kein solches Schnittstellenobjekt gefunden werden,
		  wird diese ExitDlg-Methode aufgerufen;
		  liefert sie true zurÅck, wird der Dialog daraufhin verlassen }
		case AnIndx of
			MFLESS: if ttmem>0 then
								begin
									dec(ttmem);
									{ TT-RAM-Bedarf um 128 KB verringern... }
									UpdateAmount
									{ ... und Bedarf anzeigen }
								end;
			MFMORE: if ttmem<15 then
								begin
									inc(ttmem);
									{ TT-RAM-Bedarf erhîhen }
									UpdateAmount
								end;
			MFDATEI: begin
								 datei:=FileSelect('PRG/APP/ACC/TOS/TTP AUSWéHLEN',pfad,'*.*');
								 { neue Datei auswÑhlen... }
								 Load(datei)
								 { ... und anzeigen }
							 end;
			MFMAKE: begin
								with phrec do
									begin
										ph_prgflags:=ph_prgflags and $0ffffff8;
										{ FastLoad-Flags zunÑchst ausmaskieren (lîschen)... }
										if cb1^.GetCheck=bf_Checked then
											ph_prgflags:=ph_prgflags or PH_FASTLOAD;
										if cb2^.GetCheck=bf_Checked then
											ph_prgflags:=ph_prgflags or PH_LOADALT;
										if cb3^.GetCheck=bf_Checked then
											ph_prgflags:=ph_prgflags or PH_MALLOCALT;
										PByte(@ph_prgflags)^:=PByte(@ph_prgflags)^ or (ttmem shl 4)
										{ ... und dann evtl. wieder setzen }
									end;
								reset(f);
								write(f,phrec);
								close(f);
								{ Datei aktualisieren }
								DisableAll
								{ nun ist keine Datei mehr aktiv }
							end
		end;
		ExitDlg:=false
		{ Dialog NICHT verlassen }
	end;


function TMFDialog.OK: boolean;

	begin
		Application^.Quit;
		{ Anwendung beenden (sobald der aktuelle Message-Loop
		  beendet ist)... }
		OK:=true
		{ ... und vorher den Dialog verlassen }
	end;


function TMFDialog.Help: boolean;

	begin
		form_alert(1,'[1][ Bringen Sie den Mauscursor| Åber das gewÅnschte Dialog-| element und drÅcken Sie die  | <Help>-Taste.][   OK   ]');
		{ Alertbox anzeigen (spÑter geschieht dies mit Alert(), die Boxen
		  kînnen dann auch nicht-modal sein) }
		Help:=false
		{ Dialogbox nicht verlassen }
	end;


procedure TMFDialog.UpdateAmount;
	const atxt : array [0..15] of string[7] =
							('128 KB','256 KB','384 KB','512 KB','640 KB','768 KB',
							 '896 KB','1 MB','1152 KB','1280 KB','1408 KB','1536 KB',
							 '1664 KB','1792 KB','1920 KB','2 MB');

	begin
		st3^.SetText(atxt[ttmem])
		{ TT-RAM-Bedarf anzeigen;
		  die TStatic-Methode SetText ruft automatisch die
		  von TControl geerbte Paint-Methode auf, die das Dialog-
		  element neu zeichnet, wenn der Dialog sichtbar ist }
	end;


procedure TMFDialog.DisableAll;

	begin
		st1^.Clear;
		{ Dateinamen lîschen... }
		st2^.Disable;
		st3^.Disable;
		cb1^.Disable;
		cb2^.Disable;
		cb3^.Disable;
		pb2^.Disable;
		pb4^.Disable;
		pb5^.Disable
		{ ... und alle Buttons etc. nicht anwÑhlbar machen }
	end;


procedure TMFDialog.Load(dname: string);
	var cmp: string[4];
	    p  : PDialog;

	begin
		if length(dname)>0 then
			if exist(dname) then
				begin
					{ nur bearbeiten, wenn die Datei existiert! }
					cmp:=StrRight(dname,4);
					if (cmp<>'.PRG') and (cmp<>'.APP') and (cmp<>'.TOS') and (cmp<>'.TTP') and (cmp<>'.ACC') then
						begin
							{ falscher Dateityp... }
							p:=new(PDialog,Init(@self,'Datei auswÑhlen',MFALERT));
							if p<>nil then
								begin
									new(PStatic,Init(p,MFATITLE,2,true,''));
									new(PButton,Init(p,MFAOK,id_OK,true,'WÑhlen Sie eine passende Datei aus!'));
									Application^.ExecDialog(p)
									{ TDialog-Objekte versuchen normalerweise, den Dialog in
									  einem Fenster darzustellen; durch den Aufruf von
									  ExecDialog() wird der Dialog zwangsweise MODAL abge-
									  arbeitet und danach automatisch freigegeben
									  (als RÅckgabe erhÑlt man den Index des angewÑhlten
									  Exit-Buttons, in diesem Fall nicht verwendet) }
								end
						end
					else
						begin
							if RPos('\',dname)>0 then
								begin
									st1^.SetText('Datei: '+StrRight(dname,length(dname)-RPos('\',dname)));
									{ nur den Dateinamen anzeigen (ohne Pfad) }
									pfad:=StrLeft(dname,RPos('\',dname))
									{ den Pfad merken wir uns dafÅr an dieser Stelle }
								end
							else
								begin
									st1^.SetText('Datei: '+dname);
									pfad:=''
									{... fÅr Dateien ohne Pfadangabe }
								end;
							{ Datei îffnen und aktuelle Werte auslesen... }
							assign(f,dname);
							reset(f);
							read(f,phrec);
							close(f);
							ttmem:=PByte(@phrec.ph_prgflags)^ shr 4;
							st2^.Enable;
							st3^.Enable;
							{ Texte aktivieren... }
							UpdateAmount;
							{ ... und neue Werte anzeigen }
							cb1^.Enable;
							if bTst(phrec.ph_prgflags,PH_FASTLOAD) then cb1^.Check
							else
								cb1^.Uncheck;
							{ es gibt zwar auch eine SetCheck-Methode, aber so
							  ist es doch recht Åbersichtlich! }
							cb2^.Enable;
							if bTst(phrec.ph_prgflags,PH_LOADALT) then cb2^.Check
							else
								cb2^.Uncheck;
							cb3^.Enable;
							if bTst(phrec.ph_prgflags,PH_MALLOCALT) then cb3^.Check
							else
								cb3^.Uncheck;
							pb2^.Enable;
							pb4^.Enable;
							pb5^.Enable
						end
				end
	end;


begin
  MFApplication.Init('MFST','MakeFast');
  { Anwendung initialisieren;
    Åbergeben wird ein Cookie (alle ObjectGEM-Anwendungen tragen sich
    nach Mîglichkeit fÅr die Dauer ihrer AusfÅhrung in den Cookie-Jar
    ein) und ein String, der bei einem ACC als MenÅeintrag verwendet
    wird }
  MFApplication.Run;
  { Programm ausfÅhren... }
  MFApplication.Done
  { ... und korrekt verlassen! }
end.