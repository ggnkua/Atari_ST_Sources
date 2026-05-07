{                V I D E O - A R C H I V                 }
{  Video-Kassetten Verwaltungsprogramm fr den Atari ST  }
{         Version 3.0  Copyright (c) 25.07.1989          }
{       Frank Link  Schulweg 10  D-7545 H”fen/Enz        }
{          Entwickelt mit ST Pascal Plus V2.07           }

program video;

  const {$I gemconst.pas}
        {$I trixcons.pas}

  type {$I gemtype.pas}
       {$I trixtype.pas}

  var titel:array [1..5,1..501] of string[36];
      casstyp:array [1..500] of string[4];
      sz_anfang:array [1..5,1..500] of string[9];
      anmerkung_1,anmerkung_2:array [1..5,1..501] of string[18];
      kass,kass_1,nr,typ,sza,ti,ok,ok_1,ok_2,ok_3,ok_4,ok_5,
      weiter,weiter_1,weiter_2,weiter_3,weiter_4,weiter_5,
      ti_1,ti_2,ti_3,ti_4,ti_5,tit,hilfe,button,bo,no_tisu,
      mu_loe,mu_aen,mu_ein,mu_dru,mu_end,mu_kassu,mu_tisu,anm_1,anm_2,
      mu_lad,mu_spe,mu_an,no_an,mu_titel_1,mu_titel_2,an_1,an_2,state,
      a,x,y,xx,yy,ww,hh,mx,my,rez,fenster_1,fenster_2,key:integer;
      name,name_1,wind_name,wind_name_2,na_1,na_2:string[255];
      dialog,dialog_1,dialog_2,dialog_3,dialog_4,
      dialog_5,dialog_6,dialog_7:dialog_ptr;
      normpfad,v_name:string;
      msg:message_buffer;
      menu:menu_ptr;
      wa:boolean;


  {$I gemsubs.pas}

  {$I trixsubs.pas}
  

  function getrez:integer;

    xbios(4);


  function setprt(kon:integer):integer;
   
    xbios(33);


  function bcostat(geraet:integer):integer;

    bios(8);


  function dgetdrv:integer;

    gemdos($19);


  procedure dgetpath(var pathbuf:cstring; drv:integer);

    gemdos($47);


  procedure e_fehler;

    var hil:integer;
        hilf:string;
        
    begin
      hilf:='[1][Eingabefehler,|Kassetten Nr. aužer Bereich][  OK  ]';
      hil:=do_alert(hilf,1);
    end;


  procedure copyright;

    var prompt_item:integer;
        ausg:string;

    begin
      dialog:=new_dialog(6,0,0,40,12);
      prompt_item:=add_ditem(dialog,g_boxtext,none,11,1,18,2,1,$1180);
      ausg:='Video - Archiv';
      set_dtext(dialog,prompt_item,ausg,system_font,te_center);
      prompt_item:=add_ditem(dialog,g_text,none,0,4,40,1,0,$1180);
      ausg:='Public Domain  Version 3.0';
      set_dtext(dialog,prompt_item,ausg,system_font,te_center);
      prompt_item:=add_ditem(dialog,g_text,none,0,5,40,1,0,$1180);
      ausg:='Copyright  1989 Frank Link';
      insert(chr(189),ausg,11);
      set_dtext(dialog,prompt_item,ausg,system_font,te_center);
      prompt_item:=add_ditem(dialog,g_text,none,0,7,40,1,0,$1180);
      ausg:='Entwickelt mit ST Pascal Plus von CCD';
      set_dtext(dialog,prompt_item,ausg,small_font,te_center);
      ok_2:=add_ditem(dialog,g_button,selectable|exit_btn|default,
                      16,9,8,2,2,$1180);
      set_dtext(dialog,ok_2,'OK',system_font,te_center);
      center_dialog(dialog);
    end;


  procedure gross(var stri:string);

    var i:integer;

    begin
      for i:=1 to length(stri) do
        begin
          if (ord(stri[i])>=ord('a')) and (ord(stri[i])<=ord('z')) then
            begin
              stri[i]:=chr(ord(stri[i])-((ord('a')-ord('A'))));
            end
          else
            begin
              case stri[i] of
                '':stri[i]:='š';
                '„':stri[i]:='Ž';
                '”':stri[i]:='™';
              end;
            end;
        end;
    end;


  procedure eingeben;

    var prompt_item,xa,ya,ys,yh,yt,hil:integer;
        hilfs,hilf:string;
        name_x:string[9];
        we,wq,wr,yc,qa:boolean;

    begin
      dialog_1:=new_dialog(10,0,0,47,16);
      prompt_item:=add_ditem(dialog_1,g_text,none,2,1,15,1,0,$1180);
      set_dtext(dialog_1,prompt_item,'DATEN EINGEBEN',system_font,te_left);
      writev(hilfs,x);
      kass:=add_ditem(dialog_1,g_ftext,editable,2,3,45,1,0,$1180);
      set_dedit(dialog_1,kass,'Kassetten Nr.:......................... ___'
                ,'999',hilfs,system_font,te_left);
      typ:=add_ditem(dialog_1,g_ftext,editable,2,4,45,1,0,$1180);
      set_dedit(dialog_1,typ,'Kassetten Typ:........................ ____'
                ,'XXXX',casstyp[x],system_font,te_left);
      sza:=add_ditem(dialog_1,g_ftext,editable,2,6,45,1,0,$1180);
      set_dedit(dialog_1,sza,'Spielzeit:....................... _________'
                ,'XXXXXXXXX','',system_font,te_left);
      ti:=add_ditem(dialog_1,g_ftext,editable,2,8,45,1,0,$1180);
      set_dedit(dialog_1,ti,'Titel: ____________________________________',
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX','',system_font,te_left);
      an_1:=add_ditem(dialog_1,g_ftext,editable,2,10,45,1,0,$1180);
      set_dedit(dialog_1,an_1,'Anmerkung 1.Zeile:...... __________________',
                'XXXXXXXXXXXXXXXXXX','',system_font,te_left);
      an_2:=add_ditem(dialog_1,g_ftext,editable,12,11,33,1,0,$1180);
      set_dedit(dialog_1,an_2,'2.Zeile:...... __________________',
                'XXXXXXXXXXXXXXXXXX','',system_font,te_left);
      ok_1:=add_ditem(dialog_1,g_button,selectable|exit_btn|default,
                      6,13,8,2,2,$1180);
      set_dtext(dialog_1,ok_1,'OK',system_font,te_center);
      weiter:=add_ditem(dialog_1,g_button,selectable|exit_btn,
                        33,13,8,2,2,$1180);
      set_dtext(dialog_1,weiter,'ABBRUCH',system_font,te_center);
      center_dialog(dialog_1);
      button:=do_dialog(dialog_1,sza);
      if button = ok_1 then
        begin
          bo:=1;xa:=x;ya:=y;we:=true;wq:=true;wr:=true;
          get_dedit(dialog_1,kass,name);
          readv(name,x);
          if (x=0) or (x>500) then we:=false
          else
          if titel[5,x]<>'' then
            begin
              we:=false;
              wq:=false;
            end;
          get_dedit(dialog_1,ti,name);
          if name = '' then
            begin
              we:=false;
              wr:=false;
            end;
          if we = true then
            begin
              yc:=false;ys:=5;
              while yc = false do
                begin
                  ys:=ys-1;
                  if (titel[ys,x]<>'') or (ys=1) then yc:=true;
                end;
              yh:=1;qa:=false;
              while (yh <= 5) and (qa = false) do
                begin
                  get_dedit(dialog_1,sza,name);
                  if (name <= sz_anfang[yh,x]) or (sz_anfang[yh,x]='') then
                    begin
                      qa:=true;
                      for yt:=ys downto yh do
                        begin
                          sz_anfang[yt+1,x]:=sz_anfang[yt,x];
                          titel[yt+1,x]:=titel[yt,x];
                          anmerkung_1[yt+1,x]:=anmerkung_1[yt,x];
                          anmerkung_2[yt+1,x]:=anmerkung_2[yt,x];
                        end;
                      sz_anfang[yh,x]:=name;
                      get_dedit(dialog_1,ti,name_1);
                      titel[yh,x]:=name_1;
                      get_dedit(dialog_1,an_1,name_1);
                      anmerkung_1[yh,x]:=name_1;
                      get_dedit(dialog_1,an_2,name_1);
                      anmerkung_2[yh,x]:=name_1;
                    end;
                  get_dedit(dialog_1,typ,name);
                  casstyp[x]:=name;
                  yh:=yh+1;
                end;
            end
          else
            begin
              if wr = false then
                begin
                  hilf:='[1][Eingabefehler,|kein Titel][  OK  ]';
                  hil:=do_alert(hilf,1);
                end;
              if wq = false then
                begin
                  hilf:='[1][Eingabefehler,|Kassette voll][  OK  ]';
                  hil:=do_alert(hilf,1);
                end;
              if (x=0) or (x>500) then e_fehler;
              x:=xa;
              y:=ya;
            end;
        end;
      end_dialog(dialog_1);
      delete_dialog(dialog_1);
    end;


  procedure aendern;
  
    var p_item,p_it1,hil,nr_1,nr_2,nr_3,nr_4,nr_5,
        typ_1,sza_1,ti_1,a_1,a_2,yq,ok_6,weiter_6:integer;
        nam:string[255];
        hilf,hilf_1:string;

    function vergleich:boolean;
    
      begin
        vergleich:=true;
        get_dedit(dialog_7,typ_1,nam);
        if nam<>casstyp[x] then vergleich:=false;
        get_dedit(dialog_7,sza_1,nam);
        if nam<>sz_anfang[yq,x] then vergleich:=false;
        get_dedit(dialog_7,ti_1,nam);
        if nam<>titel[yq,x] then vergleich:=false;
        get_dedit(dialog_7,a_1,nam);
        if nam<>anmerkung_1[yq,x] then vergleich:=false;
        get_dedit(dialog_7,a_2,nam);
        if nam<>anmerkung_2[yq,x] then vergleich:=false;
      end;

    procedure eintragen;

      begin
        bo:=1;
        get_dedit(dialog_7,ti_1,nam);
        if nam<>'' then
          begin
            titel[yq,x]:=nam;
            get_dedit(dialog_7,typ_1,nam);
            casstyp[x]:=nam;
            get_dedit(dialog_7,sza_1,nam);
            sz_anfang[yq,x]:=nam;
            get_dedit(dialog_7,a_1,nam);
            anmerkung_1[yq,x]:=nam;
            get_dedit(dialog_7,a_2,nam);
            anmerkung_2[yq,x]:=nam;
          end
        else
          begin
            hilf:='[1][Eingabefehler,|kein Titel][  OK  ]';
            hil:=do_alert(hilf,1);
          end;
      end;

    begin
      hilf:='[1][Keine Daten vorhanden][  OK  ]';
      if titel[1,x]='' then hil:=do_alert(hilf,1)
      else
        begin
          yq:=1;
          dialog_7:=new_dialog(16,0,0,47,17);
          p_item:=add_ditem(dialog_7,g_text,none,2,1,13,1,0,$1180);
          set_dtext(dialog_7,p_item,'DATEN ŽNDERN',system_font,te_left);
          p_it1:=add_ditem(dialog_7,g_text,none,2,3,14,1,0,$1180);
          set_dtext(dialog_7,p_it1,'Titel Nummer:',system_font,te_left);
          nr_1:=add_ditem(dialog_7,g_button,selectable|radio_btn|exit_btn,
                          17,3,4,1,2,$1180);
          set_dtext(dialog_7,nr_1,'1',system_font,te_center);
          nr_2:=add_ditem(dialog_7,g_button,selectable|radio_btn|exit_btn,
                          23,3,4,1,2,$1180);
          set_dtext(dialog_7,nr_2,'2',system_font,te_center);
          nr_3:=add_ditem(dialog_7,g_button,selectable|radio_btn|exit_btn,
                          29,3,4,1,2,$1180);
          set_dtext(dialog_7,nr_3,'3',system_font,te_center);
          nr_4:=add_ditem(dialog_7,g_button,selectable|radio_btn|exit_btn,
                          35,3,4,1,2,$1180);
          set_dtext(dialog_7,nr_4,'4',system_font,te_center);
          nr_5:=add_ditem(dialog_7,g_button,selectable|radio_btn|exit_btn,
                          41,3,4,1,2,$1180);
          set_dtext(dialog_7,nr_5,'5',system_font,te_center);
          typ_1:=add_ditem(dialog_7,g_ftext,editable,2,5,45,1,0,$1180);
          set_dedit(dialog_7,typ_1,
                    'Kassetten Typ:........................ ____',
                    'XXXX',casstyp[x],system_font,te_left);
          sza_1:=add_ditem(dialog_7,g_ftext,editable,2,7,45,1,0,$1180);
          set_dedit(dialog_7,sza_1,
                    'Spielzeit:....................... _________',
                    'XXXXXXXXX',sz_anfang[yq,x],system_font,te_left);
          ti_1:=add_ditem(dialog_7,g_ftext,editable,2,9,45,1,0,$1180);
          set_dedit(dialog_7,ti_1,
                    'Titel: ____________________________________',
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',titel[yq,x],
                    system_font,te_left);
          a_1:=add_ditem(dialog_7,g_ftext,editable,2,11,45,1,0,$1180);
          set_dedit(dialog_7,a_1,
                    'Anmerkung 1.Zeile:...... __________________',
                    'XXXXXXXXXXXXXXXXXX',anmerkung_1[yq,x],
                    system_font,te_left);
          a_2:=add_ditem(dialog_7,g_ftext,editable,12,12,45,1,0,$1180);
          set_dedit(dialog_7,a_2,'2.Zeile:...... __________________',
                    'XXXXXXXXXXXXXXXXXX',anmerkung_2[yq,x],
                    system_font,te_left);
          ok_6:=add_ditem(dialog_7,g_button,selectable|exit_btn|default,
                          6,14,8,2,2,$1180);
          set_dtext(dialog_7,ok_6,'OK',system_font,te_center);
          weiter_6:=add_ditem(dialog_7,g_button,selectable|exit_btn,
                              33,14,8,2,2,$1180);
          set_dtext(dialog_7,weiter_6,'ABBRUCH',system_font,te_center);
          center_dialog(dialog_7);
          obj_setstate(dialog_7,nr_1,selected,false);
          if titel[2,x]='' then obj_setstate(dialog_7,nr_2,disabled,false);
          if titel[3,x]='' then obj_setstate(dialog_7,nr_3,disabled,false);
          if titel[4,x]='' then obj_setstate(dialog_7,nr_4,disabled,false);
          if titel[5,x]='' then obj_setstate(dialog_7,nr_5,disabled,false);
          button:=do_dialog(dialog_7,ti_1);
          while (button<>ok_6) and (button<>weiter_6) do
            begin
              if vergleich=false then
                begin
                  writev(hilf_1,yq);
                  hilf:=concat('[2][Ge„nderte Daten des|',hilf_1);
                  hilf:=concat(hilf,'. Titel eintragen][JA| NEIN ]');
                  hil:=do_alert(hilf,1);
                  if hil=1 then eintragen;
                end;
              if button=nr_1 then  yq:=1;
              if button=nr_2 then  yq:=2;
              if button=nr_3 then  yq:=3;
              if button=nr_4 then  yq:=4;
              if button=nr_5 then  yq:=5;
              set_dedit(dialog_7,typ_1,
                        'Kassetten Typ:........................ ____',
                        'XXXX',casstyp[x],system_font,te_left);
              set_dedit(dialog_7,sza_1,
                        'Spielzeit:....................... _________',
                        'XXXXXXXXX',sz_anfang[yq,x],system_font,te_left);
              set_dedit(dialog_7,ti_1,
                        'Titel: ____________________________________',
                        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',titel[yq,x],
                        system_font,te_left);
              set_dedit(dialog_7,a_1,
                        'Anmerkung 1.Zeile:...... __________________',
                        'XXXXXXXXXXXXXXXXXX',anmerkung_1[yq,x],
                        system_font,te_left);
              set_dedit(dialog_7,a_2,'2.Zeile:...... __________________',
                        'XXXXXXXXXXXXXXXXXX',anmerkung_2[yq,x],
                        system_font,te_left);
              obj_redraw(dialog_7,typ_1);
              obj_redraw(dialog_7,sza_1);
              obj_redraw(dialog_7,ti_1);
              obj_redraw(dialog_7,a_1);
              obj_redraw(dialog_7,a_2);
              button:=redo_dialog(dialog_7,ti_1);
            end;
          if button=ok_6 then eintragen;
          end_dialog(dialog_7);
          delete_dialog(dialog_7);
        end;
    end;


  procedure loeschen;

    var prompt_item,bb,ba:integer;

    procedure loe(no:integer);

      begin
        titel[no,x]:='';
        sz_anfang[no,x]:='';
        anmerkung_1[no,x]:='';
        anmerkung_2[no,x]:='';
      end;

    begin
      dialog_2:=new_dialog(9,0,0,24,13);
      prompt_item:=add_ditem(dialog_2,g_text,none,3,1,13,1,0,$1180);
      set_dtext(dialog_2,prompt_item,'DATEN L™SCHEN',system_font,te_left);
      ti_1:=add_ditem(dialog_2,g_button,selectable,3,3,8,1,2,$1180);
      set_dtext(dialog_2,ti_1,'Titel 1',system_font,te_center);
      ti_2:=add_ditem(dialog_2,g_button,selectable,3,5,8,1,2,$1180);
      set_dtext(dialog_2,ti_2,'Titel 2',system_font,te_center);
      ti_3:=add_ditem(dialog_2,g_button,selectable,3,7,8,1,2,$1180);
      set_dtext(dialog_2,ti_3,'Titel 3',system_font,te_center);
      ti_4:=add_ditem(dialog_2,g_button,selectable,3,9,8,1,2,$1180);
      set_dtext(dialog_2,ti_4,'Titel 4',system_font,te_center);
      ti_5:=add_ditem(dialog_2,g_button,selectable,3,11,8,1,2,$1180);
      set_dtext(dialog_2,ti_5,'Titel 5',system_font,te_center);
      ok:=add_ditem(dialog_2,g_button,selectable|exit_btn|default,
                    13,7,8,2,2,$1180);
      set_dtext(dialog_2,ok,'OK',system_font,te_center);
      weiter_5:=add_ditem(dialog_2,g_button,selectable|exit_btn,
                     13,10,8,2,2,$1180);
      set_dtext(dialog_2,weiter_5,'ABBRUCH',system_font,te_center);
      center_dialog(dialog_2);
      button:=do_dialog(dialog_2,a);
      if button = ok then
        begin
          bo:=1;
          if obj_state(dialog_2,ti_1) = 1 then loe(1);
          if obj_state(dialog_2,ti_2) = 1 then loe(2);
          if obj_state(dialog_2,ti_3) = 1 then loe(3);
          if obj_state(dialog_2,ti_4) = 1 then loe(4);
          if obj_state(dialog_2,ti_5) = 1 then loe(5);
          for bb:=1 to 4 do
            begin
              ba:=1;
              while (titel[bb,x]='') and (ba+bb<6) do
                begin
                  titel[bb,x]:=titel[bb+ba,x];
                  sz_anfang[bb,x]:=sz_anfang[bb+ba,x];
                  anmerkung_1[bb,x]:=anmerkung_1[bb+ba,x];
                  anmerkung_2[bb,x]:=anmerkung_2[bb+ba,x];
                  titel[bb+ba,x]:='';
                  sz_anfang[bb+ba,x]:='';
                  anmerkung_1[bb+ba,x]:='';
                  anmerkung_2[bb+ba,x]:='';
                  ba:=ba+1;
                end;
            end;
        end;    
      end_dialog(dialog_2);
      delete_dialog(dialog_2);
    end;


  procedure kassette;

    var prompt_item,na_hi:integer;

    begin
      dialog_3:=new_dialog(5,0,0,25,8);
      prompt_item:=add_ditem(dialog_3,g_text,none,2,1,16,1,0,$1180);
      set_dtext(dialog_3,prompt_item,'KASSETTE SUCHEN',system_font,te_left);
      kass_1:=add_ditem(dialog_3,g_ftext,editable,2,3,21,1,0,$1180);
      set_dedit(dialog_3,kass_1,'Kassetten Nr.:... ___','999','',
                system_font,te_left);
      ok_3:=add_ditem(dialog_3,g_button,selectable|exit_btn|default,
                      3,5,8,2,2,$1180);
      set_dtext(dialog_3,ok_3,'OK',system_font,te_center);
      weiter_2:=add_ditem(dialog_3,g_button,selectable|exit_btn,
                          14,5,8,2,2,$1180);
      set_dtext(dialog_3,weiter_2,'ABBRUCH',system_font,te_center);
      center_dialog(dialog_3);
      button:=do_dialog(dialog_3,kass_1);
      if button = ok_3 then
        begin
          get_dedit(dialog_3,kass_1,name);
          readv(name,na_hi);
          if (na_hi=0) or (na_hi>500) or (name='') then e_fehler
          else x:=na_hi;
        end;
      end_dialog(dialog_3);
      delete_dialog(dialog_3);
    end;


  procedure menu_1;

    var data_1:integer;

    begin
      menu:=new_menu(25,'  Video Info... ');
      mu_titel_1:=add_mtitle(menu,' Daten ');
      mu_titel_2:=add_mtitle(menu,' Suche ');
      mu_ein:=add_mitem(menu,mu_titel_1,'  Eingeben...   ');
      mu_aen:=add_mitem(menu,mu_titel_1,'  Žndern...     ');
      mu_loe:=add_mitem(menu,mu_titel_1,'  L”schen...    ');
      mu_dru:=add_mitem(menu,mu_titel_1,'  Drucken...    ');
      data_1:=add_mitem(menu,mu_titel_1,'----------------');
      menu_disable(menu,data_1);
      mu_lad:=add_mitem(menu,mu_titel_1,'  Laden...      ');
      mu_spe:=add_mitem(menu,mu_titel_1,'  Speichern...  ');
      data_1:=add_mitem(menu,mu_titel_1,'----------------');
      menu_disable(menu,data_1);
      mu_end:=add_mitem(menu,mu_titel_1,'  Ende...       ');
      mu_kassu:=add_mitem(menu,mu_titel_2,'  Kassette...  ');
      data_1:=add_mitem(menu,mu_titel_2,  '---------------');
      menu_disable(menu,data_1);
      mu_tisu:=add_mitem(menu,mu_titel_2, '  Titel...     ');
      no_tisu:=add_mitem(menu,mu_titel_2, '  Weiter       ');
      data_1:=add_mitem(menu,mu_titel_2,  '---------------');
      menu_disable(menu,data_1);
      mu_an:=add_mitem(menu,mu_titel_2,   '  Anmerkung... ');
      no_an:=add_mitem(menu,mu_titel_2,   '  Weiter       ');
      draw_menu(menu);
    end;


  procedure fenster;

    begin
      xx:=14;yy:=16*rez;ww:=612;hh:=125*rez;wind_name:=' Video-Archiv ';
      fenster_1:=new_window(g_name|g_uparrow|g_dnarrow|g_vslide,
                            wind_name,xx,yy,ww,hh);
      growbox(258,72*rez,61,12*rez,14,16*rez,612,125*rez);
      open_window(fenster_1,xx,yy,ww,hh);
    end;


  procedure fenster_b;

    begin
      xx:=14;yy:=148*rez;ww:=612;hh:=45*rez;wind_name_2:='Funktionstasten';
      fenster_2:=new_window(g_name,wind_name_2,xx,yy,ww,hh);
      growbox(258,168*rez,61,4*rez,14,148*rez,612,45*rez);
      open_window(fenster_2,xx,yy,ww,hh);
    end;


  procedure schreiben;

    var stri:string;
        hi,hi_1:integer;

    begin
      stri:='Kassetten Nr.:';
      text_style(outlined);
      draw_string(40,43*rez,stri);
      writev(stri,x);
      draw_string(186,43*rez,stri);
      stri:='Kassettentyp:';
      draw_string(409,43*rez,stri);
      draw_string(546,43*rez,casstyp[x]);
      text_style(thickened);
      stri:='Nr.';
      draw_string(19,65*rez,stri);
      stri:='Zeit';
      draw_string(58,65*rez,stri);
      stri:='Titel';
      draw_string(149,65*rez,stri);
      stri:='Anmerkung';
      draw_string(452,65*rez,stri);
      hi_1:=0;
      text_style(normal);
      for hi:=1 to 5 do
        begin
          if titel[hi,x] <> '' then
            begin
              writev(stri,hi);
              draw_string(27,(80+hi_1)*rez,stri);
              draw_string(58,(80+hi_1)*rez,sz_anfang[hi,x]);
              draw_string(149,(80+hi_1)*rez,titel[hi,x]);
              if rez = 1 then text_heigth(4) else text_heigth(6);
              draw_string(452,(80+hi_1-4)*rez,anmerkung_1[hi,x]);
              draw_string(452,(80+hi_1+2)*rez,anmerkung_2[hi,x]);
              if rez = 1 then text_heigth(6) else text_heigth(13);
            end;
          hi_1:=hi_1+14
        end;
    end;


  procedure linien;

    begin
      paint_color(black);
      paint_style(0);
      if rez = 2 then
        begin
          paint_rect(26,62,570,39);
          paint_rect(30,66,562,31);
          pline(15,68*rez,634,68*rez);
          pline(15,56*rez,634,56*rez);
          pline(140,56*rez,140,68*rez);
          pline(46,56*rez,46,68*rez);
          pline(442,56*rez,442,68*rez);
          pline(46,70*rez,46,140*rez);
          pline(140,70*rez,140,140*rez);
          pline(442,70*rez,442,140*rez);
        end
      else
        begin
          paint_rect(24,32,570,18);
          pline(25,33,25,49);
          pline(592,33,592,49);
          pline(15,55,634,55);
          pline(46,56,46,140);
          pline(47,56,47,140);
          pline(140,56,140,140);
          pline(141,56,141,140);
          pline(442,56,442,140);
          pline(443,56,443,140);
        end;
      pline(15,70*rez,634,70*rez);
      pline(15,84*rez,634,84*rez);
      pline(15,98*rez,634,98*rez);
      pline(15,112*rez,634,112*rez);
      pline(15,126*rez,634,126*rez);
    end;


  procedure linien_2;

    var st:string[10];

    begin
      pline(61,165*rez,619,165*rez);
      line_to(577,186*rez);
      line_to(19,186*rez);
      line_to(61,165*rez);
      pline(123,165*rez,81,186*rez);
      pline(185,165*rez,143,186*rez);
      pline(247,165*rez,205,186*rez);
      pline(309,165*rez,267,186*rez);
      pline(371,165*rez,329,186*rez);
      pline(433,165*rez,391,186*rez);
      pline(495,165*rez,453,186*rez);
      pline(557,165*rez,515,186*rez);
      text_heigth(4);
      st:='F1';draw_string(89,171*rez,st);
      st:='F2';draw_string(152,171*rez,st);
      st:='F3';draw_string(208,171*rez,st);
      st:='F4';draw_string(270,171*rez,st);
      st:='F5';draw_string(334,171*rez,st);
      st:='F6';draw_string(396,171*rez,st);
      st:='F7';draw_string(461,171*rez,st);
      st:='F8';draw_string(519,171*rez,st);
      st:='F10';draw_string(580,171*rez,st);
      st:='KASSETTE';draw_string(47,177*rez,st);
      st:='ZURUECK';draw_string(41,183*rez,st);
      st:='KASSETTE';draw_string(110,177*rez,st);
      st:='VOR';draw_string(104,183*rez,st);
      st:='DATEN';draw_string(178,177*rez,st);
      st:='LOESCHEN';draw_string(160,183*rez,st);
      st:='DATEN';draw_string(240,177*rez,st);
      st:='EINGEBEN';draw_string(222,183*rez,st);
      st:='DATEN';draw_string(304,177*rez,st);
      st:='DRUCKEN';draw_string(286,183*rez,st);
      st:='TITEL';draw_string(366,177*rez,st);
      st:='SUCHEN';draw_string(348,183*rez,st);
      st:='KASSETTE';draw_string(419,177*rez,st);
      st:='SUCHEN';draw_string(413,183*rez,st);
      st:='ANMERK.';draw_string(483,177*rez,st);
      st:='SUCHEN';draw_string(477,183*rez,st);
      st:='PROGRAMM';draw_string(544,177*rez,st);
      st:='ENDE';draw_string(538,183*rez,st);
      if rez = 1 then text_heigth(6) else text_heigth(13);
    end;


  procedure zeichnen(fenster_x,x0,y0,w0,h0:integer);

    var v2,v3,v4:integer;

    begin
      begin_update;
      hide_mouse;
      first_rect(fenster_x,xx,yy,ww,hh);
      while (ww<>0) and (hh<>0) do
        begin
          paint_style(solid);
          paint_color(white);
          if fenster_x = 2 then
            begin
              if rect_intersect(xx,yy,ww,hh,xx,yy,ww,hh) then
                begin
                  set_clip(xx,yy,ww,hh);
                  paint_rect(xx,yy,ww,hh);
                  set_wname(fenster_x,wind_name);
                  wind_set(2,wf_vslide,x*2,v2,v3,v4);
                  linien;
                  schreiben;
                end;
            end
          else 
            begin
              if rect_intersect(x0,y0,w0,h0,xx,yy,ww,hh) then
                begin
                  set_clip(xx,yy,ww,hh);
                  paint_rect(xx,yy,ww,hh);
                  set_wname(fenster_x,wind_name_2);
                  linien_2;
                end;
            end;  
          next_rect(fenster_x,xx,yy,ww,hh);
        end;
      show_mouse;
      end_update;
    end;


  procedure f_titel(mit:boolean);

    var prompt_item,wx,w,hil,hi_x:integer;
        wahr,wahr_1,t_fl:boolean;
        hi_1:string;

    begin
      wx:=x;
      t_fl:=true;
      if mit = true then
        begin
          dialog_4:=new_dialog(5,0,0,47,8);
          prompt_item:=add_ditem(dialog_4,g_text,none,2,1,16,1,0,$1180);
          set_dtext(dialog_4,prompt_item,'TITEL SUCHEN',system_font,te_left);
          tit:=add_ditem(dialog_4,g_ftext,editable,2,3,45,1,0,$1180);
          set_dedit(dialog_4,tit,'Titel: ____________________________________'
              ,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX','',system_font,te_left);
          ok_4:=add_ditem(dialog_4,g_button,selectable|exit_btn|default,
                          6,5,8,2,2,$1180);
          set_dtext(dialog_4,ok_4,'OK',system_font,te_center);
          weiter_3:=add_ditem(dialog_4,g_button,selectable|exit_btn,
                              33,5,8,2,2,$1180);
          set_dtext(dialog_4,weiter_3,'ABBRUCH',system_font,te_center);
          center_dialog(dialog_4);
          button:=do_dialog(dialog_4,tit);
          if button = ok_4 then
            begin
              get_dedit(dialog_4,tit,name);
              x:=0;
            end
          else t_fl:=false;
          end_dialog(dialog_4);
          delete_dialog(dialog_4);
        end;
      if t_fl = true then
        begin    
          wahr:=false;
          wahr_1:=false;
          if name = '' then wahr_1:=true;
          set_mouse(m_bee);
          while wahr = false do
            begin
              x:=x+1;
              for w:=1 to 5 do
                begin
                  if length(titel[w,x]) >= length(name) then
                    begin
                      hi_1:=titel[w,x];
                      gross(hi_1);
                      gross(name);
                      hi_x:=pos(name,hi_1);
                      if hi_x <> 0 then wahr:=true;
                    end;
                end;
              if x = 501 then
                begin
                  wahr:=true;
                  wahr_1:=true;
                end;
            end;
          set_mouse(m_arrow);  
          if wahr_1 = true then
            begin
              hil:=do_alert('[1][Titel nicht gefunden][  OK  ]',1);
              x:=wx;
            end;
          if (mit=false) and (wahr_1=false) then 
             zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
        end;   
    end;


  procedure f_anmerkung(mit:boolean);

    var pr_item,wx,w,hil,hi_x_1,hi_x_2:integer;
        wahr,wahr_1,a_fl:boolean;
        hi_1,hi_2:string[255];

    begin
      wx:=x;
      a_fl:=true;
      if mit = true then
        begin
          dialog_6:=new_dialog(6,0,0,41,9);
          pr_item:=add_ditem(dialog_6,g_text,none,2,1,16,1,0,$1180);
          set_dtext(dialog_6,pr_item,'ANMERKUNG SUCHEN',system_font,te_left);
          anm_1:=add_ditem(dialog_6,g_ftext,editable,2,3,37,1,0,$1180);
          set_dedit(dialog_6,anm_1,'Anmerkung 1.Zeile: __________________',
              'XXXXXXXXXXXXXXXXXX','',system_font,te_left);
          anm_2:=add_ditem(dialog_6,g_ftext,editable,12,4,27,1,0,$1180);
          set_dedit(dialog_6,anm_2,'2.Zeile: __________________',
              'XXXXXXXXXXXXXXXXXX','',system_font,te_left);
          ok_5:=add_ditem(dialog_6,g_button,selectable|exit_btn|default,
                          6,6,8,2,2,$1180);
          set_dtext(dialog_6,ok_5,'OK',system_font,te_center);
          weiter_4:=add_ditem(dialog_6,g_button,selectable|exit_btn,
                              27,6,8,2,2,$1180);
          set_dtext(dialog_6,weiter_4,'ABBRUCH',system_font,te_center);
          center_dialog(dialog_6);
          button:=do_dialog(dialog_6,anm_1);
          if button = ok_5 then
            begin
              get_dedit(dialog_6,anm_1,na_1);
              get_dedit(dialog_6,anm_2,na_2);
              x:=0;
            end
          else a_fl:=false;  
        end;
      if a_fl = true then
        begin  
          set_mouse(m_bee);
          wahr:=false;
          wahr_1:=false;
          if (na_1='') and (na_2='') then wahr_1:=true;
          while wahr = false do
            begin
              x:=x+1;
              for w:=1 to 5 do
                begin
                  if (length(anmerkung_1[w,x])>=length(na_1)) or
                     (length(anmerkung_2[w,x])>=length(na_2)) then
                    begin
                      hi_1:=anmerkung_1[w,x];
                      hi_2:=anmerkung_2[w,x];
                      gross(hi_1);
                      gross(hi_2);
                      gross(na_1);
                      gross(na_2);
                      hi_x_1:=pos(na_1,hi_1);
                      hi_x_2:=pos(na_2,hi_2);
                      if (na_1<>'') and (na_2<>'') then
                        begin
                          if (hi_x_1<>0) and (hi_x_2<>0) then wahr:=true;
                        end
                      else
                        if (hi_x_1<>0) or (hi_x_2<>0) then wahr:=true;
                    end;
                end;
              if x = 501 then
                begin
                  wahr:=true;
                  wahr_1:=true;
                end;
            end;
          set_mouse(m_arrow);
          if wahr_1 = true then
            begin
              hil:=do_alert('[1][Anmerkung nicht gefunden][  OK  ]',1);
              x:=wx;
            end;
          if (mit=false) and (wahr_1=false) then 
             zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
        end;
      if mit = true then
        begin
          end_dialog(dialog_6);
          delete_dialog(dialog_6);
        end;
    end;


  procedure do_cop;

    begin
      if obj_state(dialog,ok_2) & selected <> 0 then
        obj_setstate(dialog,ok_2,normal,false);
      button:=do_dialog(dialog,a);
      end_dialog(dialog);
    end;


  procedure nummer(var xi:integer);

    var wx:boolean;
        hil,hil_1:integer;

    begin
      wx:=false;
      hil:=500;
      while wx = false do
        begin
          for hil_1:=1 to 5 do
            begin
              if (titel[hil_1,hil]<>'') or (hil=1) then
                begin
                  xi:=hil;
                  wx:=true;
                end;
            end;
          hil:=hil-1;
        end;
    end;


  procedure clsvar;

    var ah,bh,ch:integer;

    begin
      nummer(ah);
      for bh:=1 to ah do
        begin
          casstyp[bh]:='';
          for ch:=1 to 5 do
            begin
              sz_anfang[ch,bh]:='';
              titel[ch,bh]:='';
              anmerkung_1[ch,bh]:='';
              anmerkung_2[ch,bh]:='';
            end;
        end;
    end;


  procedure umbenennen(x_name:string);

    var hil,hil_1,hil_2,hil_3:integer;
        fil_1,fil_2:text;
        name:string;
        ju:boolean;
    
    begin
      name:=x_name;
      ju:=false;
      hil:=length(name);
      if hil < 4 then hil_2:=1 else hil_2:=hil-3;
      for hil_1:=hil downto hil_2 do
        begin
          if name[hil_1] = '.' then
            begin
              ju:=true;
              hil_3:=hil_1;
            end;
        end;
      if ju = true then delete(name,hil_3,hil-hil_3+1);
      name:=concat(name,'.BAK');
      reset(fil_1,x_name);
      if io_result = 0 then 
        begin
          reset(fil_2,name);
          rename(fil_1,fil_2);
          close(fil_2);
        end;
      close(fil_1);            
    end;
    

  procedure speichern(file_na:string);

    var hil,hilf,xi,xi_1:integer;
        ziff:string[85];
        fil:text;

    begin
      nummer(xi);
      umbenennen(file_na);
      rewrite(fil,file_na);
      if io_result = 0 then
        begin
          writeln(fil,x);
          for hil:=1 to xi do
            begin
              writeln(fil,casstyp[hil]);
              for xi_1:=1 to 5 do
                begin
                  writeln(fil,sz_anfang[xi_1,hil]);
                  writeln(fil,titel[xi_1,hil]);
                  writeln(fil,anmerkung_1[xi_1,hil]);
                  writeln(fil,anmerkung_2[xi_1,hil]);
                end;
            end;
        end
      else
        begin
          ziff:='[1][Schreibfehler,|Diskette, Schreibschutz|';
          ziff:=concat(ziff,'und Datei berprfen][  OK  ]');
          hilf:=do_alert(ziff,1);
          wa:=false;
        end;
      close(fil);
    end;


  procedure laden(file_na:string);

    var xi,xi_1:integer;
        fil:text;

    begin
      xi:=1;
      reset(fil,file_na);
      if io_result = 0 then
        begin
          readln(fil,x);
          while not eof(fil) do
            begin
              readln(fil,casstyp[xi]);
              for xi_1:=1 to 5 do
                begin
                  readln(fil,sz_anfang[xi_1,xi]);
                  readln(fil,titel[xi_1,xi]);
                  readln(fil,anmerkung_1[xi_1,xi]);
                  readln(fil,anmerkung_2[xi_1,xi]);
                end;
              xi:=xi+1;
            end;
        end;
      close(fil);
    end;


  procedure ende;

    var ziff:string;
        hilf:integer;

    begin
      ziff:='[2][PROGRAMM ENDE| |Daten abspeichern ?][JA|NEIN|ABBRUCH]';
      hilf:=do_alert(ziff,bo);
      if hilf<>3 then wa:=true;
      if hilf=1 then
       begin
         set_mouse(m_bee);
         speichern(v_name);
         set_mouse(m_arrow);
       end;
    end;


  procedure ext(var name:string);
  
    var hil,hil_1,hil_2:integer;
        ju:boolean;
        
    begin
      ju:=false;
      hil:=length(name);
      if hil < 4 then hil_2:=1 else hil_2:=hil-3;
      for hil_1:=hil downto hil_2 do
        if name[hil_1] = '.' then ju:=true;
      if ju = false then name:=concat(name,'.DAT');
    end;    
          

  procedure do_laden;

    var ziff:string[95];
        hilf:integer;  
    
    begin
      ziff:='[1][DATEN LADEN| |Achtung, die aktuellen|Daten werden ';
      ziff:=concat(ziff,'gel”scht| ][OK|ABBRUCH]');
      hilf:=do_alert(ziff,1);
      if hilf = 1 then
        begin
          if get_in_file(normpfad,v_name) then
            begin
              set_mouse(m_bee);
              zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
              zeichnen(1,14,148*rez,612,45*rez);
              bo:=2;
              clsvar;
              ext(v_name);
              laden(v_name);
              set_mouse(m_arrow);
            end;
        end;    
    end;


  procedure do_speichern;

    begin
      if get_in_file(normpfad,v_name) then
        begin
          set_mouse(m_bee);
          zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
          zeichnen(1,14,148*rez,612,45*rez);
          bo:=2;
          ext(v_name);
          speichern(v_name);
          set_mouse(m_arrow);
        end;
    end;


  procedure alt_laden;

    var xi,xi_1,ha,hil:integer;
        hilfv:string[100];
        fil:text;

    begin
      hilfv:='[1][DATEN DER VERSION 1.X LADEN| |Achtung, die aktuellen|';
      hilfv:=concat(hilfv,'Daten werden gel”scht][OK|ABBRUCH]');
      hil:=do_alert(hilfv,1);
      if hil = 1 then 
        begin
          set_mouse(m_bee);
          bo:=2;
          clsvar;
          xi:=1;
          reset(fil,'VIDEO.ALT');
          if io_result = 0 then
            begin
              while not eof(fil) do
                begin
                  readln(fil,casstyp[xi]);
                  for xi_1:=1 to 5 do
                    begin
                      readln(fil,sz_anfang[xi_1,xi]);
                      readln(fil,titel[xi_1,xi]);
                      if titel[xi_1,xi] = ' ' then 
                        begin
                          titel[xi_1,xi]:='';
                          sz_anfang[xi_1,xi]:='';
                        end;  
                      ha:=length(titel[xi_1,xi]);
                      if ha > 36 then delete(titel[xi_1,xi],37,ha-36);
                    end;
                  xi:=xi+1;
                end;
            end
          else
            begin
              hilfv:='[3][Datei "VIDEO.ALT"|nicht gefunden][  OK  ]';
              hil:=do_alert(hilfv,1);
            end;  
          close(fil);
          set_mouse(m_arrow);
          x:=1;
          zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
        end;  
    end;


  procedure hardcopy;

    var prompt_item,lauf,lauf_1,druck_1,druck_2,ok_5,von,bis,w,wa,wx,xh,ik,
        hi_1,hi_2,hil_1,hil_2,hilf_1,wie_1,wie_2,wie_3,
        wie_4,wie_5,wie_6,fx,tes_1,tes_2:integer;
        hilfe_1,st_x,w_a:string;
        wo,hu,wahr_x,wahr_z:boolean;
        titel_x:array[1..5,1..501] of string[25];

    procedure h_print(sg:string;ind:integer);
      
      var lae:integer;
      
      begin
        write(sg);
        lae:=ind-length(sg);
        while lae > 0 do
          begin
            write(' ');
            lae:=lae-1;
          end;
      end;      

    procedure tit;
    
      var wxa:integer;

      begin
        for wxa:=1 to 3 do writeln;
        write(chr(27),chr(69));
        h_print('Nr.',5);
        h_print('Zeit',12);
        h_print('Titel',39);
        writeln('Anmerkung');
        write(chr(27),chr(70));
        for wxa:=1 to 93 do write(chr(45));
        writeln;
      end;  
        
    begin
      nummer(hilfe);
      writev(hilfe_1,hilfe);
      dialog_5:=new_dialog(12,0,0,28,15);
      prompt_item:=add_ditem(dialog_5,g_text,none,3,1,13,1,0,$1180);
      set_dtext(dialog_5,prompt_item,'DATEN DRUCKEN',
                system_font,te_left);
      druck_1:=add_ditem(dialog_5,g_ftext,editable,3,3,20,1,0,$1180);
      set_dedit(dialog_5,druck_1,'von Nr.:... ___','999','1',
                system_font,te_left);
      druck_2:=add_ditem(dialog_5,g_ftext,editable,3,4,20,1,0,$1180);
      set_dedit(dialog_5,druck_2,'bis Nr.:... ___','999',hilfe_1,
                system_font,te_left);
      wie_1:=add_ditem(dialog_5,g_button,selectable|radio_btn,
                       3,6,10,1,2,$1180);
      set_dtext(dialog_5,wie_1,'Liste A',system_font,te_center);
      wie_2:=add_ditem(dialog_5,g_button,selectable|radio_btn,
                       3,8,10,1,2,$1180);
      set_dtext(dialog_5,wie_2,'Liste B',system_font,te_center);
      wie_5:=add_ditem(dialog_5,g_button,selectable|radio_btn,
                       3,10,10,1,2,$1180);
      set_dtext(dialog_5,wie_5,'Liste C',system_font,te_center);
      wie_3:=add_ditem(dialog_5,g_button,selectable|radio_btn,
                       15,6,10,1,2,$1180);
      set_dtext(dialog_5,wie_3,'Etikett A',system_font,te_center);
      wie_4:=add_ditem(dialog_5,g_button,selectable|radio_btn,
                       15,8,10,1,2,$1180);
      set_dtext(dialog_5,wie_4,'Etikett B',system_font,te_center);
      wie_6:=add_ditem(dialog_5,g_button,selectable|radio_btn,
                       15,10,10,1,2,$1180);
      set_dtext(dialog_5,wie_6,'Etikett C',system_font,te_center);
      ok_5:=add_ditem(dialog_5,g_button,selectable|exit_btn|default,
                      3,12,8,2,2,$1180);
      set_dtext(dialog_5,ok_5,'OK',system_font,te_center);
      weiter_1:=add_ditem(dialog_5,g_button,selectable|exit_btn,
                          17,12,8,2,2,$1180);
      set_dtext(dialog_5,weiter_1,'ABBRUCH',system_font,te_center);
      center_dialog(dialog_5);
      obj_setstate(dialog_5,wie_1,selected,false);
      button:=do_dialog(dialog_5,druck_1);
      get_dedit(dialog_5,druck_1,name);
      if name <> '' then readv(name,von) else von:=0;
      get_dedit(dialog_5,druck_2,name);
      if name <> '' then readv(name,bis) else bis:=0;
      if button = ok_5 then
        begin
          tes_1:=setprt(-1);
          tes_1:=tes_1 & 16;
          if tes_1=16 then tes_1:=1;
          tes_2:=1;
          while (bcostat(tes_1)=0) and (tes_2<>2) do
            begin
              tes_2:=do_alert('[3][Drucker einschalten][OK|ABBRUCH]',1);
              if tes_2 = 2 then button:=weiter_1;
            end;
        end;
      if (von<>0) and (bis<>0) and (bis>=von) and (button=ok_5)
         and (von<501) and (bis<501) then
       begin
        set_mouse(m_bee);
        rewrite(output,'lst:');
        if obj_state(dialog_5,wie_6) = 1 then
          begin
            for w:=von to bis do
              begin
                wo:=true;
                for xh:=1 to 5 do
                  if titel[xh,w]<>'' then wo:=false;
                if wo = false then
                  begin
                    write(chr(27),chr(77));
                    write(chr(27),chr(71),chr(27),chr(15));
                    writeln('Kassette Nr.: ',w);
                    writeln;
                    for wa:= 1 to 5 do
                      begin
                        h_print(titel[wa,w],38);
                        writeln(sz_anfang[wa,w]);
                      end;
                    writeln(chr(18));
                    writeln(chr(27),chr(80),chr(27),chr(72));
                  end;
              end;
          end;
        if obj_state(dialog_5,wie_5) = 1 then
          begin
            write(chr(27),chr(77));
            tit;
            writeln;
            wa:=0;
            for w:=von to bis do
              begin
                if wa>=55 then 
                  begin
                    for xh:=wa to 65 do writeln;
                    wa:=0;
                    tit;
                    writeln;
                  end;
                hu:=false;
                for ik:=1 to 5 do
                  begin
                    if titel[ik,w] <> '' then
                      begin
                        hu:=true;
                        writev(w_a,w);
                        if ik = 1 then h_print(w_a,5) else write('     ');
                        h_print(sz_anfang[ik,w],12);
                        h_print(titel[ik,w],39);
                        h_print(anmerkung_1[ik,w],19);
                        writeln(anmerkung_2[ik,w]);
                        wa:=wa+1;
                      end;
                  end;
                if hu = true then
                  begin
                    wa:=wa+1;
                    writeln;
                  end;
              end;
            writeln;
            writeln;
            writeln(chr(27),chr(80));                  
          end;  
        if obj_state(dialog_5,wie_4) = 1 then
          begin
            write(chr(27),chr(65),chr(6));
            write(chr(27),chr(15));
            write(chr(27),chr(83),chr(1));
            for w:=von to bis do
              begin
                wo:=true;
                for xh:=1 to 5 do
                  if titel[xh,w]<>'' then wo:=false;
                if wo = false then
                  begin
                    for wa:= 1 to 5 do
                      begin
                        h_print(sz_anfang[wa,w],11);
                        h_print(titel[wa,w],38);
                        case wa of
                          1:write('NR.:');
                          2:write(w);
                          4:write('TYP:');
                          5:write(casstyp[w]);
                        end;  
                        writeln;
                      end;
                    for wa:=1 to 4 do writeln;  
                  end;
              end;
            write(chr(27),chr(84));
            write(chr(18),chr(27),chr(50));
          end;
        if obj_state(dialog_5,wie_3) = 1 then
          begin
            for w:=von to bis do
              begin
                wo:=true;
                for xh:=1 to 5 do
                  if titel[xh,w]<>'' then wo:=false;
                if wo = false then
                  begin
                    write(chr(27),chr(77),chr(27),chr(69));
                    write('KASSETTEN NR.:');
                    writev(w_a,w);
                    h_print(w_a,5);
                    writeln('KASSETTENTYP:',casstyp[w]);
                    for wx:=1 to 36 do write(chr(45));
                    write(chr(27),chr(70),chr(27),chr(80));
                    writeln(chr(27),chr(71),chr(27),chr(15));
                    for wa:= 1 to 5 do
                      begin
                        write(' ');
                        h_print(sz_anfang[wa,w],14);
                        writeln(titel[wa,w]);
                      end;
                    writeln(chr(18));
                    writeln(chr(27),chr(80),chr(27),chr(72));
                  end;
              end;
          end;
        if obj_state(dialog_5,wie_2) = 1 then
          begin
            wa:=0;
            for w:=von to bis do
              begin
                if wa>=61 then 
                  begin
                    for xh:=wa to 71 do writeln;
                    wa:=0;
                  end;
                write(chr(27),chr(14));
                write('KASSETTEN NR.:');
                writev(w_a,w);
                h_print(w_a,5);
                writeln('KASSETTENTYP:',casstyp[w]);
                write(chr(27),chr(77));
                for wx:=1 to 86 do write(chr(45));
                writeln;
                wa:=wa+2;
                for ik:=1 to 5 do
                  begin
                    if titel[ik,w] <> '' then
                      begin
                        h_print(sz_anfang[ik,w],11);
                        h_print(titel[ik,w],38);
                        h_print(anmerkung_1[ik,w],19);
                        writeln(anmerkung_2[ik,w]);
                        wa:=wa+1;
                      end;
                  end;
                wa:=wa+2;
                writeln;
                writeln(chr(27),chr(80));
              end;                
          end;  
        if obj_state(dialog_5,wie_1) = 1 then
          begin
            write(chr(27),chr(77));
            tit;
            lauf:=0;
            lauf_1:=0;
            for hi_1:=von to bis do
              begin
                for hi_2:=1 to 5 do
                  begin
                    st_x:=titel[hi_2,hi_1];
                    if st_x <> '' then
                      begin
                        lauf_1:=lauf_1+1;
                        gross(st_x);
                      end;
                    fx:=length(st_x);
                    if fx > 25 then delete(st_x,26,fx-25);
                    titel_x[hi_2,hi_1]:=st_x;
                  end;
              end;
            for hilf_1:=0 to lauf_1 do
              begin
                hi_1:=von-1;
                repeat
                  wahr_z:=false;
                  hi_1:=hi_1+1;
                  for hi_2:=1 to 5 do
                    begin
                      wahr_x:=true;
                      if titel_x[hi_2,hi_1]<>'' then
                        begin
                          hil_1:=von-1;
                          repeat
                            hil_1:=hil_1+1;
                            for hil_2:=1 to 5 do
                              begin
                                if titel_x[hil_2,hil_1]<>'' then
                                  begin
                                    if titel_x[hi_2,hi_1]>
                                       titel_x[hil_2,hil_1] then
                                      begin
                                        wahr_x:=false;
                                      end;
                                  end;
                              end;
                          until (hil_1=bis) or (wahr_x=false);
                          if wahr_x = true then
                            begin
                              wahr_z:=true;
                              writev(w_a,hi_1);
                              h_print(w_a,5);
                              h_print(sz_anfang[hi_2,hi_1],12);
                              h_print(titel[hi_2,hi_1],39);
                              h_print(anmerkung_1[hi_2,hi_1],19);
                              writeln(anmerkung_2[hi_2,hi_1]);
                              titel_x[hi_2,hi_1]:='';
                              lauf:=lauf+1;
                              if lauf = 60 then
                                begin
                                  lauf:=0;
                                  for wx:=1 to 7 do writeln;
                                  tit;
                                end;
                            end;
                        end;
                    end;
                until (hi_1=bis) or (wahr_z=true);
              end;
            writeln;
            writeln;
            writeln(chr(27),chr(80));
          end;
        rewrite(output,'con:');
        set_mouse(m_arrow);
       end
      else
       if button = ok_5 then e_fehler;
      end_dialog(dialog_5);
      delete_dialog(dialog_5);
    end;


  procedure auswahl;

    begin
      if msg[3]=3 then do_cop;
      if msg[3]=mu_titel_1 then
        begin
          if msg[4]=mu_ein then eingeben;
          if msg[4]=mu_aen then aendern;
          if msg[4]=mu_loe then loeschen;
          if msg[4]=mu_dru then hardcopy;
          if msg[4]=mu_lad then do_laden;
          if msg[4]=mu_spe then do_speichern;
          if msg[4]=mu_end then ende;
        end;
      if msg[3]=mu_titel_2 then
        begin
          if msg[4]=mu_kassu then kassette;
          if msg[4]=mu_tisu then f_titel(true);
          if msg[4]=no_tisu then f_titel(false);
          if msg[4]=mu_an then f_anmerkung(true);
          if msg[4]=no_an then f_anmerkung(false);
        end;
    end;


  procedure blaettern;

    begin
      case key of
        15104: if x > 1 then x:=x-1;
        15360: if x < 500 then x:=x+1;
        15616: loeschen;
        15872: eingeben;
        22272: aendern;
        16128: hardcopy;
        16384: f_titel(true);
        22784: f_titel(false);
        16640: kassette;
        16896: f_anmerkung(true);
        23296: f_anmerkung(false);
        17408: ende;
         5888: do_cop;
         7680: alt_laden;
         7936: do_speichern;
         9728: do_laden;
      end;
    end;
    
    
  procedure funk_taste;
  
    begin
      if (my>=165*rez) and (my<=186*rez) then
        begin
          if (mx>=40)  and (mx<102) then
            begin
              if x>1 then x:=x-1;
              zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
            end;
          if (mx>=102) and (mx<164) then
            begin
              if x<500 then x:=x+1;
              zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
            end;  
          if (mx>=164) and (mx<226) then loeschen;
          if (mx>=226) and (mx<288) then
            begin
              if (state=1) or (state=2) or (state=3) then aendern
              else eingeben;
            end;
          if (mx>=288) and (mx<350) then hardcopy;
          if (mx>=350) and (mx<412) then
            begin
              if (state=1) or (state=2) or (state=3) then f_titel(false)
              else f_titel(true);
            end;
          if (mx>=412) and (mx<474) then kassette;
          if (mx>=474) and (mx<536) then 
            begin
              if (state=1) or (state=2) or (state=3) then f_anmerkung(false)
              else f_anmerkung(true);
            end;
          if (mx>=536) and (mx<598) then ende;
        end;
    end;


  procedure pfeil;

    var va:boolean;

    begin
      if (msg[4]=2) and (x>1) then x:=x-1;
      if (msg[4]=3) and (x<500) then x:=x+1;
      va:=false;
      if (msg[4]=0) and (x>10) then
        begin
          x:=x-10;
          va:=true;
        end;
      if (msg[4]=0) and (x<11) and (va=false) then x:=1;
      va:=false;
      if (msg[4]=1) and (x<490) then
        begin
          x:=x+10;
          va:=true;
        end;
      if (msg[4]=1) and (x>490) and (va=false) then x:=500;
      zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
    end;


  procedure regler;

    var hi_x:integer;

    begin
      hi_x:=msg[4] div 2;
      if hi_x > 500 then hi_x:=500;
      if hi_x < 1 then hi_x:=1;
      x:=hi_x;
      zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
    end;
    
    
  procedure hole_path;

    var norm:cstring;
        drv:string; 

    begin
      drv:=chr(65+dgetdrv);
      dgetpath(norm,0);
      ctopstr(norm,normpfad);
      normpfad:=concat(drv,':',normpfad,'\*.DAT');
    end;


  procedure event_loop;

    var event,junk:integer;

    begin
      repeat
        event:=get_event(e_keyboard|e_message,
                         0,0,0,0,false,0,0,0,0,false,
                         0,0,0,0,msg,key,junk,junk,mx,my,state);
        if event = event & e_keyboard then
          begin
            blaettern;
            if (key=15104) or (key=15360) then                  
              zeichnen(2,msg[4],msg[5],msg[6],msg[7]);
          end
        else
          begin
            case msg[0] of
              mn_selected: auswahl;
              wm_redraw  : zeichnen(msg[3],msg[4],msg[5],msg[6],msg[7]);
              wm_arrowed : pfeil;
              wm_vslid   : regler;
              wm_topped  : funk_taste;
            end;
          end;
        menu_normal(menu,msg[3]);
      until wa;
    end;


  begin
    if init_gem >= 0 then
      begin
        if getrez <> 0  then
          begin
            x:=1;
            bo:=2;
            wa:=false;
            io_check(false);
            v_name:='VIDEO.DAT';
            laden(v_name);
            hole_path;
            copyright;
            menu_1;
            rez:=getrez;
            init_mouse;
            fenster_b;
            fenster;
            event_loop;
            close_window(fenster_1);
            shrinkbox(258,72*rez,61,12*rez,14,16*rez,612,125*rez);
            delete_window(fenster_1);
            close_window(fenster_2);
            shrinkbox(258,168*rez,61,4*rez,14,148*rez,612,45*rez);
            delete_window(fenster_2);
            delete_dialog(dialog);
            erase_menu(menu);
            delete_menu(menu);
            exit_gem;
          end
        else
          begin
            init_mouse;
            a:=do_alert('[3][ |Bitte mittlere|Aufl”sung verwenden][ OK ]',0);
            exit_gem;
          end;
      end;
  end.

