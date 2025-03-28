{***********************************}
{   INFIX ---> UPN-Notation V 1.0   }
{                                   }
{   Peter Hilbring                  }
{   Dietrich-Ottmarstraáe 16        }
{   W-4782 Erwitte                  }
{                                   }
{ Programmiert in MAXON-PASCAL V1.5 }
{ (c) 1992 MAXON-Computer           }
{***********************************}
{                                   }
{ Listing #2 : INIT_GEM.I           }
{                                   }
{ Initialisierung des GEM           }
{                                   }
{***********************************}

procedure fatal_error(msg : string);
var
    s : integer;
begin
    msg:='[3]['+msg+'][ ENDE ]'#0;
    s:=form_alert(1,msg[1]);
    if (appflag) then
        halt(0)
    else
        while true do
            evnt_mesag(msgbuf)
end;

function init_gem : boolean;
var
    workin  : intin_array;
    workout : workout_array;
    dummy   : integer;
begin
    aes_handle:=appl_init;
    if (aes_handle>=0) then
    begin
        vdi_handle:=graf_handle(dummy, dummy,
                    charboxheight, dummy);
        for dummy:=0 to 9 do
            workin[dummy]:=1;
        workin[10]:=2;
        v_opnvwk(workin, vdi_handle, workout);
        x_res:=workout[0]+1;
        y_res:=workout[1]+1
    end;
    init_gem:=aes_handle>=0
end;

procedure end_gem;
begin
    v_clsvwk(vdi_handle);
    appl_exit
end;

function init_resource(resourcename : string)
         : boolean;
begin
    shel_find(resourcename);
    rsrc_load(resourcename[1]);
    if (gemerror=0) then
        init_resource:=false
    else
        init_resource:=true
end;

