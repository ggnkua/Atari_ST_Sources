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
{ Listing #4 : SCRAP.I              }
{                                   }
{ Routinen zur Clipboard-Verwaltung }
{                                   }
{***********************************}

function init_clipbrd : boolean;
var
    p           : integer;
    akt_drive   : integer;
    path        : string;
    envdir      : string;
    _drvbits    : longint absolute $04c2;
    new_drive   : integer;
    userstack   : pointer;
begin
    scrp_read(sc_rpscrap[1]);
    sc_rpscrap[0]:=#255;
    sc_rpscrap[0]:=chr(pos(#0,sc_rpscrap));
    if length(sc_rpscrap) = 1 then
    begin
        akt_drive := getdrive;
        envdir:=getenv('CLIPBRD');
        if (length(envdir)>0) then
            sc_rpscrap:=envdir
        else
        begin
            userstack:=super(nil);
            if (bittest(2,_drvbits)) then
                new_drive:=2
            else
                new_drive:=0;
            userstack:=super(userstack);
            sc_rpscrap := chr(new_drive+65)+
                          ':\CLIPBRD\'
        end;
        if(sc_rpscrap[length(sc_rpscrap)]<>'\')
            then sc_rpscrap:=sc_rpscrap+'\';
        sc_rpscrap:=sc_rpscrap+#0;
        scrp_write(sc_rpscrap[1]);
        new_drive:=ord(sc_rpscrap[1])-65;
        path:='';
        for p:=3 to length(sc_rpscrap)-2 do
            path:=path+sc_rpscrap[p];
        setdrive(new_drive);
        mkdir(path);
        if ((doserror<E_OK) and
            (doserror<>EACCDN)) then
        begin
            sc_rpscrap:=#0;
            scrp_write(sc_rpscrap[1])
        end
        else
        begin
            findfirst(path,Directory,dosdata);
            if (doserror<E_OK) then
            begin
                sc_rpscrap:=#0;
                scrp_write(sc_rpscrap[1])
            end
        end;
        setdrive(akt_drive);
    end;
    scrp_read(sc_rpscrap[1]);
    if (length(sc_rpscrap)>1) then
        init_clipbrd:=true
    else
        init_clipbrd:=false
end;

function check_clipbrd : boolean;
var
    akt_drive : integer;
    new_drive : integer;
begin
    scrp_read(sc_rpscrap[1]);
    akt_drive := getdrive;
    new_drive:=ord(sc_rpscrap[1]);
    if (new_drive>=97) then
        new_drive:=new_drive-32;
    new_drive:=new_drive-65;
    setdrive(new_drive);
    chdir(sc_rpscrap);
    findfirst('SCRAP.TXT',AnyFile,dosdata);
    if (doserror=E_OK) then
        check_clipbrd:=true
    else
        check_clipbrd:=false
end;

procedure clip_2_infix;
var
    textf     : text;
    dir       : dirstr;
    akt_drive : integer;
    new_drive : integer;
    data      : string;
    dummy     : integer;
begin
    scrp_read(sc_rpscrap[1]);
    akt_drive := getdrive;
    new_drive:=ord(sc_rpscrap[1]);
    if (new_drive>=97) then
        new_drive:=new_drive-32;
    new_drive:=new_drive-65;
    setdrive(new_drive);
    chdir(sc_rpscrap);
    findfirst('SCRAP.*',AnyFile,dosdata);
    if (doserror=E_OK) then
    begin
        reset(textf,dosdata.name);
        if (ioresult=0) then
        begin
            if not(eof(textf)) then
                    readln(textf,data);
            close(textf);
            eingabe:=copy(data,1,80)+#0;
            if (length(eingabe) div 42=0) then
                move(eingabe[1], dialog_adr^
                     [INF_1].ob_spec.tedinfo^.
                     te_ptext^, length
                     (eingabe)-1)
            else
            begin
                data:=copy(eingabe, 1, 40)+#0;
                move(data[1], dialog_adr^
                     [INF_1].ob_spec.tedinfo^.
                     te_ptext^, 40);
                move(eingabe[41], dialog_adr^
                     [INF_2].ob_spec.tedinfo^.
                     te_ptext^, length
                     (eingabe)-41)
            end;
            objc_draw(dialog_adr, INF_1, $7fff,
                      0, 0, 0, 0);
            objc_draw(dialog_adr, INF_2, $7fff,
                      0, 0, 0, 0)
        end
        else
        begin
            err:='|Žrger mit dem Clipboard!';
            err:='[3]['+err+'][ ENDE ]'#0;
            dummy:=form_alert(1, err[1])
        end
    end;
    chdir(dir);
    setdrive(akt_drive)
end;

procedure upn_2_clip;
var
    textf     : text;
    dir       : dirstr;
    akt_drive : integer;
    new_drive : integer;
    dummy     : integer;
begin
    scrp_read(sc_rpscrap[1]);
    akt_drive := getdrive;
    new_drive:=ord(sc_rpscrap[1]);
    if (new_drive>=97) then
        new_drive:=new_drive-32;
    new_drive:=new_drive-65;
    setdrive(new_drive);
    chdir(sc_rpscrap);
    mkdir('$$$');
    if ((doserror=E_OK)or(doserror=EACCDN))then
    begin
        findfirst('SCRAP.*',AnyFile,dosdata);
        while (doserror=E_OK) do
        begin
            erase(dosdata.name);
            findnext(dosdata)
        end;
        rewrite(textf,'SCRAP.TXT');
        if (ioresult=0) then
        begin
            writeln(textf, upn);
            close(textf);
        end
        else
        begin
            err:='Žrger mit dem Clipboard';
            err:='[3]['+err+'][ ENDE ]'#0;
            dummy:=form_alert(1, err[1])
        end;
    rmdir('$$$')
    end;
    chdir(dir);
    setdrive(akt_drive)
end;

