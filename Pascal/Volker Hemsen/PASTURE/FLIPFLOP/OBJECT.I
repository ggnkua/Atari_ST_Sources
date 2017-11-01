{ Prototypes - G:\FLIPFLOP\OBJECT.I }

procedure copy_c_to_c(von,nach:String_ptr);
	external;
function do_popup(var parent:tree_ptr;child:integer;popup:tree_ptr;first:integer):integer;
	external;
procedure set_popup(parent:tree_ptr;child:integer;popup:tree_ptr;first:integer);
	external;
function form_button(t:tree_ptr;ob,clks:integer;var nob:integer):boolean;
	external;
function form_keybd2(t:tree_ptr;ob,nob,char:integer;var pnob,pchar:integer):boolean;
	external;
