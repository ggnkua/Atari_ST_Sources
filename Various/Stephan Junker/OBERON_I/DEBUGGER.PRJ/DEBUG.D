DEFINITION MODULE DEBUG;

EXPORT QUALIFIED
    MENU, DESK, FILE, WINDOWS, INFO, MODPATH, SAVEPAR, QUIT, ERRORMSG, 
    MODLIST, CALLIST, TYPEBOX, TYPESTRING, MORETYPE, CLEARTYPE, TYPEOK, 
    TYPEXIT;

CONST
    MENU       = 0; (* menu *)
    DESK       = 3; (* TITLE in tree MENU *)
    FILE       = 4; (* TITLE in tree MENU *)
    WINDOWS    = 5; (* TITLE in tree MENU *)
    INFO       = 8; (* STRING in tree MENU *)
    MODPATH    = 17; (* STRING in tree MENU *)
    SAVEPAR    = 18; (* STRING in tree MENU *)
    QUIT       = 20; (* STRING in tree MENU *)
    ERRORMSG   = 22; (* STRING in tree MENU *)
    MODLIST    = 23; (* STRING in tree MENU *)
    CALLIST    = 24; (* STRING in tree MENU *)

    TYPEBOX    = 1; (* form/dialog *)
    TYPESTRING = 1; (* FTEXT in tree TYPEBOX *)
    MORETYPE   = 11; (* BUTTON in tree TYPEBOX *)
    CLEARTYPE  = 12; (* BUTTON in tree TYPEBOX *)
    TYPEOK     = 13; (* BUTTON in tree TYPEBOX *)
    TYPEXIT    = 14; (* BUTTON in tree TYPEBOX *)

END DEBUG.
