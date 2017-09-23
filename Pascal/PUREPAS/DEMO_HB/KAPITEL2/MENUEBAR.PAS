PROGRAM Menue_bar;
{$X+}

	USES geminit, gem;

	CONST	Resourcefile = 'MENU_BAR.RSC';
			MENUE    =   0; (* Menuebaum *)
			INFO     =   8; (* STRING in Baum MENUE *)
			LADEN    =  17; (* STRING in Baum MENUE *)
			QUIT     =  19; (* STRING in Baum MENUE *)
			CUT      =  21; (* STRING in Baum MENUE *)
			COPY     =  22; (* STRING in Baum MENUE *)
			PASTE		=	23; (* STRING in Baum MENUE *)
			
	VAR	ap_id, error, wahl : INTEGER;
			tree : pointer;

procedure mouse_on;
begin
	graf_mouse( M_ON, NIL );
end;

procedure mouse_off;
begin
	graf_mouse( M_OFF, NIL );
end;

FUNCTION event_loop : INTEGER;
	VAR msgbuff:array_8;
		dummy:integer;
BEGIN
	REPEAT
		evnt_multi( MU_MESAG, 0, 0, 0, 0, 0,
								0, 0, 0, 0, 0, 0, 0, 0,
								msgbuff,	0,0,
								dummy, dummy, dummy,
								dummy, dummy, dummy );
	UNTIL msgbuff[0]=MN_selected;
	menu_tnormal( tree,	msgbuff[3], 1);
	event_loop:=msgbuff[4];	
END;

PROCEDURE main;
BEGIN
	error:=rsrc_load(Resourcefile);
	IF error=0 THEN
		form_alert(1,'[1][ Fehler beim Laden | der RSC-Datei ][ Pech ]')
	ELSE
	BEGIN
		rsrc_gaddr(R_TREE, MENUE, tree);
		mouse_off;
		menu_bar( tree, 1 );
		mouse_on;
		graf_mouse( ARROW, NIL );
		REPEAT
			wahl:=event_loop;
			GotoXY(10,10);			
			WRITELN('Titelnummer= ', wahl,'  ');
		UNTIL wahl=quit;
		mouse_off;
		menu_bar( tree, 0 );
		mouse_on;
		rsrc_free( );
		IF error=0 THEN
			form_alert(1,'[1][ Fehler bei der | Freigabe des RSC-Speichers ][ Pech ]');
	END;
END;

BEGIN
	IF initgem=true THEN
		main;
END.