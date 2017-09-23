program Jutility;
{$X+} {$B-}
uses gem, tos, dos;

const 
    	FORM1    =   0; (* Formular/Dialog *)
    	F_CREATE =   2; (* BUTTON in Baum FORM1 *)
    	D_INFO   =   4; (* BUTTON in Baum FORM1 *)
    	EXIT1    =   5; (* BUTTON in Baum FORM1 *)
    	INFO     =   6; (* BUTTON in Baum FORM1 *)
    	DELETE   =   7; (* BUTTON in Baum FORM1 *)
		CALC     =   8; (* BUTTON in Baum FORM1 *)
		Freeram  =   9; (* STRING in Baum FORM1 *)

    	FORM2    =   1; (* Formular/Dialog *)
    	FNAME    =   2; (* FTEXT in Baum FORM2 *)
    	F_LEN    =   3; (* TEXT in Baum FORM2 *)
    	EXIT2    =   4; (* BUTTON in Baum FORM2 *)
    	LAENGE   =   5; (* TEXT in Baum FORM2 *)
    	ONLY_R   =   6; (* BUTTON in Baum FORM2 *)
    	F_DATE   =  10; (* TEXT in Baum FORM2 *)
    	F_TIME   =  11; (* TEXT in Baum FORM2 *)
		R_AND_W  =  12; (* BUTTON in Baum FORM2 *)

    	FORM3    =   2; (* Formular/Dialog *)
    	EXIT3    =   6; (* BUTTON in Baum FORM3 *)

		FORM4    =   3; (* Formular/Dialog *)
		RECHNE   =   2; (* BUTTON in Baum FORM4 *)
		AND_EN   =   4; (* BUTTON in Baum FORM4 *)
		EXIT4    =   5; (* BUTTON in Baum FORM4 *)
		RESULT   =   6; (* FTEXT in Baum FORM4 *)
		OR_EN    =   7; (* BUTTON in Baum FORM4 *)
		PLUS     =   8; (* BUTTON in Baum FORM4 *)
		MINUS    =   9; (* BUTTON in Baum FORM4 *)
		MAL      =  10; (* BUTTON in Baum FORM4 *)
		GETEILT  =  11; (* BUTTON in Baum FORM4 *)
		ZAHL1    =  13; (* FTEXT in Baum FORM4 *)
		ZAHL2    =  14; (* FTEXT in Baum FORM4 *)
		DIV_EN   =  15; (* BUTTON in Baum FORM4 *)
		MOD_EN   =  16; (* BUTTON in Baum FORM4 *)
		DEZIS    =  17; (* FTEXT in Baum FORM4 *)

		Resourcefilename='JUTILITY.RSC';
	 	 
var button, event, ap_id, menu_id, error, stellen : integer;
	 Filename, f_name, f_name2, path : string;
	 ok : boolean;	
	
procedure event_loop;
	(* wartet darauf, daû Accessory-Eintrag angeklickt wird *)
	var 	mg_buff 	: ARRAY_8;
begin
	repeat
		event:= evnt_mesag(mg_buff);
	until (mg_buff[0]=ac_open);
end;

function get_obj_state(t : aestreeptr; o : integer): integer;
begin
	(* Ermittel Status eines Objektes *)
	get_obj_state:=t^[o].ob_state;
end;

procedure set_obj_state(t : aestreeptr; o, s : integer);
begin
	(* éndert Status eines Objektes *)
	t^[o].ob_state:=s;
end;

function hndl_form(obj: integer) : integer;
	(* Stellt Dialogbox dar und gibt den gedrÅckten Knopf zurÅck.*)
var
	answer, oldstate : integer;
	x, y, w, h : integer;
	tree : pointer;

	procedure hide_form(obj:integer);
	begin
		form_center(tree, x, y, w, h);
		form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
	end;

	procedure show_form(obj:integer);
	begin
		form_center(tree, x, y, w, h);
		form_dial(FMD_START, x, y, w, h, x, y, w, h);
		objc_draw(tree, 0, max_depth, x, y, w, h);
	end;

begin
	rsrc_gaddr(R_TREE, obj, tree);
	graf_mouse( M_OFF, NIL ); (* Maus aus *)
	show_form(obj);
	graf_mouse( M_ON, NIL ); (* Maus wieder an *)
	answer := form_do(tree, 0);
	hide_form(obj);
	(* Status des Exit-Knopfes wieder zurÅcksetzen *)
	set_obj_state(tree,answer,get_obj_state(tree, answer) and (not selected));
	hndl_form:=answer;	
end;

procedure Show_Infobox;
	var tree : pointer;
begin
	rsrc_gaddr(r_tree, 1, tree);
	hndl_form(form3);
end;

procedure freier_speicher;
	var memptr : pointer;
		frei : longint;
		infostring, freistr : string;
begin
	memptr:=MALLOC(-1);
	frei:=LONGINT(memptr);
	str(frei,freistr);
	Infostring:='[1][Freier Speicher: | '+freistr+' Bytes ][ OK ]';
	form_alert(1,infostring)
end;

procedure Rechner;
	var i, d, wahl : longint;
		 tree: pointer;
		 a,b,c : real;
		 s1, s2, s3, s4 : string;			

function hole_zahl(s : string) : real;
	var zahl, teil2 : real;
		teil1, faktor :longint;
		i, kommapos, stellen : integer;
begin
	teil1:=0; teil2:=0; kommapos:=0; stellen:=0; faktor:=1;
	for i:=1 to length(s) do
	begin
		if (s[i]>='0') and (s[i]<='9') and (kommapos=0) then
		teil1:=teil1*10+ord(s[i])-48;
		if (s[i]='.') and (kommapos=0) then 
			kommapos:=i;
	end;
	if kommapos<>0 then 
	begin
		for i:=kommapos to length(s) do
		begin
			if (s[i]>='0') and (s[i]<='9') then
			begin
				stellen:=stellen+1;
				teil2:=teil2*10+ord(s[i])-48;
			end;
		end;
	end;
	for i:=1 to stellen do faktor:=faktor*10;
	teil2:=teil2/faktor;
	zahl:=teil1+teil2;
	hole_zahl:=zahl;
end;

begin
	a:=0.0;
	b:=0.0;
	c:=0.0;
	s1:='';
	s2:='';
	s3:='';
	s4:='04';
	rsrc_gaddr(R_TREE, form4, tree);
	SetPtext( tree, zahl1, s1);
	SetPtext( tree, zahl2, s2);
	SetPtext( tree, result, s3);
	SetPtext( tree, dezis, s4);
	repeat
		str(a:9,s1);
		str(b:9,s2);
		str(stellen:2,s4);
		wahl:=hndl_form(form4);
		if wahl=Rechne then 
		begin
			stellen:=0;
			getptext(tree, zahl1, s1);
			getptext(tree, zahl2, s2);
			getptext(tree, dezis, s4);
			a:=hole_Zahl(s1);
			b:=hole_zahl(s2);
			stellen:=trunc(hole_zahl(s4));
			if stellen>17 then stellen:=17;
			if stellen<0 then stellen:=0;
			if get_obj_state(tree, and_en)=selected then						
				c:=(trunc(a) and trunc(b))
			else 
			if get_obj_state(tree, or_en)=selected then
				c:=(trunc(a) or trunc(b))			
			else
			if get_obj_state(tree, plus)=selected then
				c:=a+b
			else
			if get_obj_state(tree, minus)=selected then
				c:=a-b
			else
			if get_obj_state(tree, mal)=selected then
				c:=a*b
			else
			if get_obj_state(tree, geteilt)=selected then
			begin
				if b<>0 then
					c:=a/b
				else
					form_alert(1,'[1][ Division durch Null ][ OK ]');
			end
			else
			if get_obj_state(tree, mod_en)=selected then
			begin
				if b<>0 then
					c:=trunc(a) mod trunc(b)
				else	
					form_alert(1,'[1][ Division durch Null ][ OK ]');
			end
			else
			if get_obj_state(tree, div_en)=selected then
			begin
				if b>0 then
				c:=trunc(a) div trunc(b)
			end;
			if ((c<2147483647.0) and (c=trunc(c))) then 
			begin
				d:=trunc(c);
				str(d:19, s3);				
			end
			else
				str(c:19:stellen, s3);
			if length(s3)<20 then
				setptext(tree,result,s3)
			else 
				form_alert(1,'[1][ öberlauf! | Zahl nicht darstellbar ][ OK ]');				
		end;
	until wahl=exit4;
end;

function SelectFile(titel : String) : String;
	var   dir : DirStr;
   ext : ExtStr;
   name : NameStr;
begin
   if GEM_pb.global[0] >= $0140 then
       fsel_exinput( path, f_name, button, titel )
   else
       fsel_input( path, f_name, button );
   if button = 0 then
       SelectFile := ''
   else begin
       FSplit( path, dir, name, ext );
       SelectFile := dir + f_name;
   end;
	path:=dir+'*.*';	
end;	

procedure datei_delete;
begin
	error:=fdelete(f_name);
	if error<>0 then
			button:=form_alert(1,'[1][ Datei '+f_name+' | konnte nicht | gelîscht werden ][ Pech ]')
	else
			button:=form_alert(1,'[1][ Datei '+f_name+' | wurde gelîscht ][ Tja ]');
end;

procedure folder_create;
	var   dir : DirStr;
   ext : ExtStr;
   name : NameStr;
	ordner_name : String;
begin
	FSplit( path, dir, name, ext );
	ordner_name:=dir+f_name;
	error:=Dcreate(ordner_name);
	if error=0 then
				button:=form_alert(1,'[1][ Ordner | '+ordner_name+' | wurde angelegt ][ Gut so ]')
	else
				button:=form_alert(1,'[1][ Ordner | '+ordner_name+' | konnte nicht | angelegt werden ][ Nanu ]');
end;	

procedure umbenennen(oldname, newname : string);
	var   dir : DirStr;
   ext : ExtStr;
   name : NameStr;
	file1, file2 : string;
begin
	FSplit( path, dir, name, ext );
	file1:=dir+oldname;
	file2:=dir+newname;
	error:=Frename(file1, file2);
	if error<>0 then
		button:=form_alert(1,'[1][ Datei '+oldname+' | konnte nicht in | '+newname+'  umbenannt werden ][ Pech ]');	
end;

function ermittle_datei_uhrzeit(dt : DateTime) : string;
	var i, hour, minute, second  : integer;
		dummystr, uhrzeit : string;
begin
		str(dt.hour:2,uhrzeit);
		str(dt.min:2,dummystr);
		uhrzeit:=uhrzeit+':'+dummystr;
		str(dt.sec:2,dummystr);
		uhrzeit:=uhrzeit+':'+dummystr;
		for i:=1 to length(uhrzeit) do
		begin
			if uhrzeit[i]=' ' then uhrzeit[i]:='0';
		end;
		ermittle_datei_uhrzeit:=uhrzeit;
end;

function ermittle_datei_datum(dt : DateTime) : string;
	var i, day, month, year : integer;
		dummystr, date : string;
begin
		str(dt.day:2,date);
		str(dt.month:2,dummystr);
		date:=date+'.'+dummystr;
		str(dt.year:2,dummystr);
		date:=date+'.'+dummystr;
		for i:=1 to length(date) do
		begin
			if date[i]=' ' then date[i]:='0';
		end;
		ermittle_datei_datum:=date;
end;

procedure datei_info;
var F, attr, i : integer;
	time, dateilaenge : longint;
	DaTi : DateTime;
	t : Text;
	tree : pointer;
	lenstr : string;
begin
	f_name2:=f_name;
	rsrc_gaddr(R_TREE, form2, tree);
	attr:=fattrib(Filename,0,0); (* Ermittle Dateiattribute *)
	attr:=(attr and 1);	(* Schreibschutz aktiv ? *)
	F:=Fopen(Filename,FO_READ);
	if (F>=0) then
	begin
		dateilaenge:=Fseek(0,F,2); 
		error:=Fclose(F);
		str(dateilaenge,lenStr);
		lenStr:=lenStr+' Bytes';
      Assign(t,Filename);
		Reset(t);
		GetFTime(t,time);
		UnpackTime( time, DaTi );
		SetPtext( tree, FNAME, f_name2); 
		SetPtext( tree, F_DATE, ermittle_datei_datum(DaTi));
		SetPtext( tree, F_TIME, ermittle_datei_uhrzeit(DaTi));		
		SetPtext( tree, F_LEN, lenStr);
		(* Falls Datei schreibgeschÅtzt, so invertiere das Feld "Nur Lesen"
			ansonsten das Feld Lesen/Schreiben *)
		if attr=0 then
		begin
			set_obj_state(tree, r_and_w, 1);
			set_obj_state(tree, only_r, 0)
		end
		else
		begin
			set_obj_state(tree, r_and_w, 0);
			set_obj_state(tree, only_r, 1); 
		end;
		Hndl_Form( form2 ); (* Datei-Infobox aufrufen *)
		(* Ermittle den Dateinamen nach Verlassen der Box *)
		GetPtext( tree, FNAME, f_name2 );
		for i:=1 to length(f_name2) do
			if f_name2[i]=' ' then f_name2[i]:='_';
		if get_obj_state(tree, only_r)=selected then (* Fileattribut geÑndert? *)
			fattrib(Filename,1,1) 
		else 
			fattrib(Filename,1,0);
		if (f_name2<>f_name) and (length(f_name2)>0) then (* Dateiname geÑndert? *)
			umbenennen(f_name, f_name2);
		Close( t );
	end	
	else
	begin
		if F=-33 then
			form_alert(1,'[1][ Datei nicht gefunden ][ Pech ]')
		else
			form_alert(1,'[1][ Datei konnte nicht | geîffnet werden ][ Pech ]')
	end;
end;

procedure hauptschleife;
	var wahl : integer;
begin
	wind_update(beg_update);
	repeat
		wahl:=hndl_form(form1);
		case wahl of 
			info: show_infobox;
			delete: 
			begin
				f_name:=SelectFile('Lîsche Datei');
				if (button=1) and (f_name<>'') then datei_delete;
			end;
			f_create: 
			begin
				Filename:=SelectFile('Ordner anlegen');
				if (button=1) and (f_name<>'') then
				folder_create;
			end;
			calc:
			begin
				Rechner;
			end;
			d_info: 
			begin
				Filename:=SelectFile('Datei-Info');
				if (button=1) and (f_name<>'') then
				datei_info;		
			end;
			freeram:
			begin
				freier_speicher;
			end;
		end;
	until wahl=exit1;
	wind_update(end_update);
	graf_mouse(ARROW, NIL);
end;


begin
	Filename:='';
   path := FExpand( '' ) + '*.*';   { Aktuelles Verzeichnis }
   f_name := '';
	ok:=false;
	stellen:=4;
	ap_id:=appl_init;
	if ap_id>=0 then 
	begin
		graf_mouse(ARROW, NIL);
		error:=rsrc_load(Resourcefilename);
		if error=1 then ok:=true;
		if appflag and ok then
		begin
			(* als Programm gestartet *)
			hauptschleife;
			appl_exit;
		end
		else
		begin
			(* als Accessory gestartet *)
	      menu_id := menu_register( ap_id, '  Disk-Jutility');
			while menu_id>=0 do
			begin
		      event_loop;
				if ok then hauptschleife;
			end;
		end;
	END;
	if not(appflag) then
		(* Endlosschleife, da Accessories nicht terminieren dÅrfen *)
		WHILE TRUE DO
			event_loop;
end. 