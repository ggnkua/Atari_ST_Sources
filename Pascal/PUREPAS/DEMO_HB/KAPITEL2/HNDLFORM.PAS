PROGRAM Handle_Form;
{$X+}
(* Ger《t um GEM-Dialogboxen darzustellen *)

USES geminit, gem;

CONST Resourcefilename = 'OLI_UTIL.RSC';
		formular = 0;
		
VAR	error, wahl : INTEGER;
		tree : Pointer;

FUNCTION get_obj_state(t : aestreeptr; o : INTEGER) : INTEGER;
BEGIN
	(* Ermittel Status eines Objektes *)
	get_obj_state:=t^[o].ob_state;
END;

PROCEDURE set_obj_state(t : aestreeptr; o, s : INTEGER);
BEGIN
	(* 始dert Status eines Objektes *)
	t^[o].ob_state:=s;
END;

FUNCTION hndl_form(obj: INTEGER) : INTEGER;

	(* Stellt Dialogbox dar und gibt den gedr…kten Knopf zur…k.*)

	VAR	answer  : INTEGER;
			x, y, w, h : INTEGER;

	PROCEDURE hide_form(obj:INTEGER);
	(* L敗cht Formular vom Bildschirm *)
	BEGIN
		form_center(tree, x, y, w, h);
		form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
	END;

	PROCEDURE show_form(obj:INTEGER);
	(* Zeichnet Formular *)
	BEGIN
		form_center(tree, x, y, w, h);
		form_dial(FMD_START, x, y, w, h, x, y, w, h);
		objc_draw(tree, 0, max_depth, x, y, w, h);
	END;

BEGIN
	rsrc_gaddr(R_TREE, FORMULAR, tree); (* Adresse des Formulars ermitteln *)
	graf_mouse( M_OFF, NIL ); (* Maus vor Zeichnen ausschalten *)
	show_form(FORMULAR); 
	graf_mouse( M_ON, NIL ); (* Maus wieder einschalten *)
	answer := form_do(tree, 0); (* Dialog dem GEM ｜erlassen *)
	hide_form(FORMULAR); (* weg mit der Box *)
	(* Exit-Button wieder deselektieren *)
	set_obj_state(tree,answer,get_obj_state(tree, answer) and (not selected));
	hndl_form:=answer;	
END;

PROCEDURE hauptschleife;
BEGIN
	wahl:=hndl_form(formular);
	WRITE('Gedr…kter Knopf hatte die Objektnummer : ');
	WRITELN(wahl);
	WRITELN;WRITELN('Dr…ke Taste...');
	REPEAT UNTIL Keypressed;
END;

(* Hauptprogramm *)

BEGIN
	IF apid>=0 THEN (* apid kommt aus GEMINIT *)
	BEGIN
		graf_mouse(ARROW, NIL); (* Mauspfeil einschalten *)
		error:=rsrc_load(Resourcefilename); (* Resourcedatei laden *)
		IF error=1 THEN
		BEGIN
			hauptschleife;
			error:=rsrc_free();
			IF error=0 THEN
					form_alert(1,'[1][ Fehler bei der | Freigabe des RSC-Speichers ][ Pech ]');
		END
		ELSE
			form_alert(1,'[1][ Resource-Datei konnte nicht | geladen werden ][ Pech ]');
		appl_exit;
	END;
END.