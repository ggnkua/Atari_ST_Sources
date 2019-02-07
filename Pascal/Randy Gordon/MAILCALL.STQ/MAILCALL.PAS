{*****************************************************************
 ***   MailCall   by Randy Gordon, D.D.S.                      ***
 ***   START, The ST Quarterly   Winter 1986                   ***
 *****************************************************************
 ***       Copyright 1986 ANTIC Publishing                     ***
 ***           NOT part of the public-domain                   ***
 *****************************************************************}

PROGRAM copy_pas ;

CONST
    {$I gemconst.pas}
    chunk_size = 15000;
    fn_length = 21 ;
    max = 175;  {  MAX NUMBER OF RECORDS  }

TYPE
    {$I gemtype.pas}
    data = PACKED record  { use array of records to keep database in memory }
        fname : packed array [1..15] of char;
        lname : packed array [1..15] of char;
        title : packed array [1..10] of char;
        address : packed array [1..25] of char;
        city : packed array [1..20] of char;
        state : packed array [1..2] of char;
        zip : packed array [1..10] of char;
        hphone : packed array [1..14] of char;
        wphone : packed array [1..14] of char;
        extra : packed array [1..25] of char
      end;
    buffer_type = PACKED ARRAY [ 1..max] OF data ;
    file_name_type = PACKED ARRAY [ 1..80 ] OF char ;
    otype = packed array [1..60] of char;

VAR
    buf : buffer_type ;
    i, in_file, out_file : integer ;
    info_file,name : file_name_type ;
    info_st,name_st,path_st : str255;
    jes : long_integer;
    c : char;
    obuf : otype;
    menu : menu_ptr;
    blank_item,select_title,field_title,option_title,main_title : integer;
    fname_item,lname_item,address_item,city_item,state_item,zip_item : integer;
    wphone_item,hphone_item,extra_item,search_item,edit_item : integer;
    p_range_item,delete_item,sort_item,add_item,print_item,dial_item : integer;
    foward_item,back_item,quit_item,printout_item,dialout_item : integer;
    res,service_type,save_item,leave_item,title_item,dummy,event : integer;
    msg : message_buffer;
    dial_b_str,mci_str,d_name_str,f,l : string[255];
    f_str,l_str,t_str,a_str,c_str,s_str,z_str,h_str,w_str,e_str : str255;
    record_number,p_item,b_l_item,blank_line,before_line,x,y,w,h,des : integer;
    one_flag,work_flag,redraw_flag,title_flag,save_flag : boolean;
    temp : data;
    w_title : window_title;
    new_item,file_title,load_item,store_item,x3,y3,w3,h3 : integer;
    {$I gemsubs.pas}


  FUNCTION getrez : integer;
    XBIOS( 4 );

  PROCEDURE bconout(dev : integer ; c : char);
    BIOS( 3 );

  FUNCTION current_disk : integer;
    GEMDOS( $19 );

  FUNCTION gem_create( VAR name : file_name_type ; mode : integer ) : integer;
    GEMDOS( $3C ) ;

  FUNCTION gem_open( VAR name : file_name_type ; mode : integer ) : integer;
    GEMDOS( $3D ) ;

  PROCEDURE gem_close( handle : integer ) ;
    GEMDOS( $3E ) ;

  FUNCTION gem_read( handle : integer ; nbytes : long_integer ;
                VAR buf : buffer_type ) : long_integer ;
    GEMDOS( $3F ) ;

  FUNCTION gem2_read( handle : integer ; nbytes : long_integer ;
                VAR buf : otype ) : long_integer ;
    GEMDOS( $3F ) ;

  FUNCTION gem_write( handle : integer ; nbytes : long_integer ;
                VAR buf : buffer_type ) : long_integer ;
    GEMDOS( $40 ) ;

  FUNCTION gem2_write( handle : integer ; nbytes : long_integer ;
                VAR buf : otype ) : long_integer ;
    GEMDOS( $40 ) ;

  PROCEDURE gem_seek( nbytes : long_integer ; handle, mode : integer ) ;
    GEMDOS( $42 ) ;

  PROCEDURE auxout( letter : char );
    GEMDOS( $04 );

  FUNCTION conin : char;
    GEMDOS($07);

  PROCEDURE printout(character : char);
    GEMDOS($05);

  FUNCTION printout_stat : long_integer;
    GEMDOS($11);

  PROCEDURE rsconf(baud,ctrl,ucr,rsr,tsr,scr : integer );
    XBIOS(15);

  PROCEDURE edit( num : integer );
    FORWARD;

  PROCEDURE paper_record;
    FORWARD;

  PROCEDURE convert( VAR ps : Str255 ; VAR cs : file_name_type ) ;

    VAR                   { convert string to valid GEM filename }
      i : Integer ;            { must end in chr(0) }

    BEGIN
      FOR i := 1 TO Length( ps ) DO
        cs[i] := ps[i] ;
      cs[ length(ps)+1 ] := Chr(0) ;
    END ;

PROCEDURE my_window;   { about program dialog under desk heading in menu }

VAR dialog : dialog_ptr;
    prompt_item,cancel,date_item,edit_item,ok_btn,button : integer;
    a,prompt2_item,prompt3_item,edit2_item,edit3_item,date2_item : integer;
    c,d,e,f,g : string[255];

BEGIN
        e:='Copyright  ';
        e[length(e)]:=chr(189);
        f:=' 1986';
        g:=concat(e,f);
        dialog := New_Dialog( 10, 0, 0, 40, 14 ) ;
        prompt3_item := Add_DItem( dialog,G_text,None,9,1,22,1,0,$1180) ;
        Set_DText( dialog, prompt3_item, 'Mail Call version 1.00',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog,G_text,None,11,4,18,1,0,$1180) ;
        Set_DText( dialog, prompt_item, g,
                        System_Font, TE_Center ) ;
        prompt3_item := Add_DItem( dialog,G_text,None,12,5,16,1,0,$1180) ;
        Set_Dtext( dialog, prompt3_item, 'ANTIC Publishing',
                        System_Font, TE_Center ) ;
        prompt2_item := Add_DItem( dialog,G_text,None,9,2,23,1,0,$1180) ;
        Set_DText( dialog, prompt2_item, 'by Randy Gordon D.D.S.',
                        System_Font, TE_Center ) ;
        date2_item := Add_DItem( dialog,G_text,None,5,7,30,1,0,$1180) ;
        Set_DText( dialog, date2_item, 'Written in OSS Personal Pascal',
                        System_Font, TE_Center ) ;
        date_item := Add_DItem( dialog,G_text,None,2,8,37,1,0,$1180) ;
        e:='Portions Copyright  ';
        e[length(e)]:=chr(189);
        f:=' 1986 OSS + CCD';
        g:=concat(e,f);
        Set_DText( dialog, date_item, g,
                        System_Font, TE_Center ) ;
        edit2_item := Add_DItem( dialog,G_text,None,7,9,25,1,0,$1180) ;
        Set_DText( dialog, edit2_item, 'Used by Permission of OSS',
                        System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                       17, 11, 6, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, 0 ) ;
        end_dialog(dialog);
        delete_dialog(dialog);

END;

PROCEDURE option_save;   { save print and dialing options }

VAR choice,count,extra_count : integer;
    l_count : long_integer;

BEGIN
        obuf[1]:=chr(ord('0')+blank_line);
        obuf[2]:=chr(13);
        obuf[3]:=chr(ord('0')+before_line);
        obuf[4]:=chr(13);
        if title_flag then     { title_flag is set to print title }
           obuf[5]:='1';       { in front of first name in mailing label }
        if not title_flag then
           obuf[5]:='0';
        obuf[6]:=chr(13);
        if work_flag then    { work_flag if set will cause the work }
           obuf[7]:='1';             { number to be dialed }
        if not work_flag then
           obuf[7]:='0';
        obuf[8]:=chr(13);
        if service_type=1 then   { service_type deceides which type of }
           obuf[9]:='1';       { telephone service to dial }
        if service_type=2 then
           obuf[9]:='2';
        if service_type=3 then
           obuf[9]:='3';
        obuf[10]:=chr(13);
        if one_flag then
           obuf[11]:='1';
        if not one_flag then
           obuf[11]:='0';
        obuf[12]:=chr(13);
        extra_count:=13;
        for count:=1 to length(dial_b_str) do begin  { dial_b_string is the }
           obuf[extra_count]:=dial_b_str[count];   { code sent to the modem }
           extra_count:=extra_count+1;        { Before the number is dialed }
         end;
        obuf[extra_count]:=chr(13);
        extra_count:=extra_count+1;
        for count:=1 to length(mci_str) do begin   { mci_str is the alter. }
           obuf[extra_count]:=mci_str[count];    { dialing codes  }
           extra_count:=extra_count+1;
         end;
        obuf[extra_count]:=chr(13);
       out_file:=gem_create(info_file,0);   { open file called info_file }
       if out_file >=0 then
            l_count:=gem2_write(out_file,50,obuf); { save 50 char to this file}
      gem_close(out_file);               { close file }
        menu_normal(menu,option_title);

END;

PROCEDURE menu_bar;    { main menu bar }

BEGIN
        menu:=new_menu(21,' About Program ');
        main_title:=add_mtitle(menu,' Main ');
        file_title:=add_mtitle(menu,' File ');
        select_title:=add_mtitle(menu,' Select ');
        option_title:=add_mtitle(menu,' Options ');
        search_item:=add_mitem(menu,main_title,'  Search       ');
        edit_item:=add_mitem(menu,main_title,'  Edit         ');
        delete_item:=add_mitem(menu,main_title,'  Delete       ');
        add_item:=add_mitem(menu,main_title,'  Add          ');
        p_item:=add_mitem(menu,main_title,'  Print Range  ');
        b_l_item:=add_mitem(menu,main_title,'---------------');
        leave_item:=add_mitem(menu,main_title,'  Quit ....    ');
        load_item:=add_mitem(menu,file_title,'  Load new file  ');
        store_item:=add_mitem(menu,file_title,'  Save changes   ');
        new_item:=add_mitem(menu,file_title,'  Start new file ');
        dialout_item:=add_mitem(menu,select_title,'  Dial          ');
        printout_item:=add_mitem(menu,select_title,'  Print label   ');
        p_range_item:=add_mitem(menu,select_title,'  Print record  ');
        print_item:=add_mitem(menu,option_title,'  Print Options    ');
        dial_item:=add_mitem(menu,option_title,'  Dialing Options  ');
        save_item:=add_mitem(menu,option_title,'  Save Options     ');
        menu_disable(menu,b_l_item);
        draw_menu(menu);

END;

PROCEDURE main_off;      { deselect main & file items }

BEGIN
        menu_disable(menu,search_item);
        menu_disable(menu,delete_item);
        menu_disable(menu,add_item);
        menu_disable(menu,leave_item);
        menu_disable(menu,load_item);
        menu_disable(menu,store_item);
        menu_disable(menu,new_item);
        menu_disable(menu,p_item);
END;

PROCEDURE select_off;   { deselect select item menu options }

BEGIN
        menu_disable(menu,dialout_item);
        menu_disable(menu,printout_item);
        menu_disable(menu,p_range_item);
END;


PROCEDURE main_on;    { reenable main & file menu options }

BEGIN
        menu_enable(menu,search_item);
        menu_enable(menu,delete_item);
        menu_enable(menu,add_item);
        menu_enable(menu,leave_item);
        menu_enable(menu,load_item);
        menu_enable(menu,store_item);
        menu_enable(menu,new_item);
        menu_enable(menu,p_item);
END;

PROCEDURE select_on;     { reenable select options }

BEGIN
        menu_enable(menu,dialout_item);
        menu_enable(menu,printout_item);
        menu_enable(menu,p_range_item);
END;

PROCEDURE init_string;   { initialize record to ' '  not really necessary }

VAR count : integer;

BEGIN
           for count:=1 to max do
           begin
              with buf[count] do begin
                fname:='               ';
                lname:='               ';
                title:='          ';
                address:='                         ';
                city:='                    ';
                state:='  ';
                zip:='          ';
                hphone:='              ';
                wphone:='              ';
                extra:='                         ';
              end   { with }
           end;   { for }
END;

PROCEDURE save_file(VAR name : file_name_type);  { save file }

VAR  handle,choice  : integer;
     l_count : long_integer;

BEGIN
      handle:=gem_create(name,0);
      if handle<0 then begin
       choice:=do_alert('[1][Can not open file|Terminating program][ OK ]',1);
       halt;
      end;

      l_count:=gem_write(handle,record_number*154,buf);
      gem_close(handle)

END;

FUNCTION add_dialog : boolean;  { dialog to add records }

VAR dialog : dialog_ptr;
    edit2_item,prompt_item,cancel,date_item,edit_item,ok_btn,button : integer;
    edit3_item,edit4_item,edit5_item,edit6_item,edit7_item,edit8_item,
    edit9_item,edit10_item,f_item,l_item,t_item,a_item,c_item,s_item,
    z_item,hp_item,wp_item,e_item,n_item : integer;

BEGIN
        dialog := New_Dialog( 24, 0, 0, 40, 18 ) ;
        n_item := Add_DItem( dialog,G_text,None,11,1,19,1,0,$1180) ;
        Set_DText( dialog, n_item, d_name_str,
                        System_Font, TE_Center ) ;
        f_item := Add_DItem( dialog,G_text,None,1,3,13,1,0,$1180) ;
        Set_DText( dialog, f_item, 'First Name : ',
                        System_Font, TE_Center ) ;
        edit_item := Add_DItem( dialog, G_fText,None, 15, 3,15, 1, 0, $1180 );
        Set_Dedit( dialog, edit_item, '_______________','aXXXXXXXXXXXXXX',
                       f_str, System_Font, TE_Center ) ;
        l_item := Add_DItem( dialog, G_Text, None, 1, 4, 12, 1, 0, $1180 );
        Set_Dtext( dialog, l_item, 'Last Name : ',
                        System_Font, TE_Center ) ;
        edit2_item := Add_DItem( dialog, G_fText,None, 14,4,15, 1, 0, $1180 );
        Set_Dedit( dialog, edit2_item, '_______________','aXXXXXXXXXXXXXX',
                        l_str,System_Font, TE_Center ) ;
        t_item := Add_DItem( dialog, G_Text, None, 1, 5, 8, 1, 0, $1180 );
        Set_Dtext( dialog, t_item, 'Title : ',
                        System_Font, TE_Center ) ;
        edit3_item := Add_DItem( dialog, G_fText,None, 10,5,10, 1, 0, $1180 );
        Set_Dedit( dialog, edit3_item, '__________','aXXXXXXXXX',
                        t_str,System_Font, TE_Center ) ;
        a_item := Add_DItem( dialog, G_Text, None, 1, 6, 10, 1, 0, $1180 );
        Set_Dtext( dialog, a_item, 'Address : ',
                        System_Font, TE_Center ) ;
        edit4_item := Add_DItem( dialog, G_fText,None, 12,6,25, 1, 0, $1180 );
        Set_Dedit( dialog, edit4_item, '_________________________',
             'XXXXXXXXXXXXXXXXXXXXXXXXX',a_str,System_Font, TE_Center ) ;
        c_item := Add_DItem( dialog, G_Text, None, 1, 7, 7, 1, 0, $1180 );
        Set_Dtext( dialog, c_item, 'City : ',
                        System_Font, TE_Center ) ;
        edit5_item := Add_DItem( dialog, G_fText,None, 9, 7,20, 1, 0, $1180 );
        Set_Dedit( dialog, edit5_item, '____________________',
             'aXXXXXXXXXXXXXXXXXXX',c_str,System_Font, TE_Center ) ;
        s_item := Add_DItem( dialog, G_Text, None, 1, 8, 8, 1, 0, $1180 );
        Set_Dtext( dialog, s_item, 'State : ',
                        System_Font, TE_Center ) ;
        edit6_item := Add_DItem( dialog, G_fText,None, 10, 8,2, 1, 0, $1180 );
        Set_Dedit( dialog, edit6_item, '__','aa',
                        s_str,System_Font, TE_Center ) ;
        z_item := Add_DItem( dialog,G_text,None,1,9,6,1,0,$1180) ;
        Set_DText( dialog, z_item, 'Zip : ',
                        System_Font, TE_Center ) ;
        edit7_item := Add_DItem( dialog, G_fText,None, 8, 9,10, 1, 0, $1180 );
        Set_Dedit( dialog, edit7_item, '__________','nnnnnnnnnn',
                       z_str, System_Font, TE_Center ) ;
        hp_item := Add_DItem( dialog,G_text,None,1,10,13,1,0,$1180) ;
        Set_DText( dialog, hp_item, 'Home Phone : ',
                        System_Font, TE_Center ) ;
        edit8_item := Add_DItem( dialog, G_fText,None, 15,10,14, 1, 0, $1180 );
        Set_Dedit( dialog, edit8_item, '______________','XXXXXXXXXXXXXX',
                       h_str, System_Font, TE_Center ) ;
        wp_item := Add_DItem( dialog,G_text,None,1,11,13,1,0,$1180) ;
        Set_DText( dialog, wp_item, 'Work Phone : ',
                        System_Font, TE_Center ) ;
        edit9_item := Add_DItem( dialog, G_fText,None, 15,11,14, 1, 0, $1180 );
        Set_Dedit( dialog, edit9_item, '______________','XXXXXXXXXXXXXX',
                       w_str, System_Font, TE_Center ) ;
        e_item := Add_DItem( dialog, G_Text, None, 1, 12, 8, 1, 0, $1180 );
        Set_Dtext( dialog, e_item, 'Extra : ',
                        System_Font, TE_Center ) ;
        edit10_item:= Add_DItem( dialog, G_fText,None, 10,12,25, 1, 0, $1180 );
        Set_Dedit( dialog, edit10_item, '_________________________',
             'XXXXXXXXXXXXXXXXXXXXXXXXX',e_str,System_Font, TE_Center ) ;
        cancel := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                       26, 15, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, cancel, 'Cancel', System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                       6, 15, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, edit_item ) ;
        if button=cancel then
           add_dialog:=false;
        if button=ok_btn then
           add_dialog:=true;
        get_dedit(dialog,edit_item,f_str);
        get_dedit(dialog,edit2_item,l_str);
        get_dedit(dialog,edit3_item,t_str);
        get_dedit(dialog,edit4_item,a_str);
        get_dedit(dialog,edit5_item,c_str);
        get_dedit(dialog,edit6_item,s_str);
        get_dedit(dialog,edit7_item,z_str);
        get_dedit(dialog,edit8_item,h_str);
        get_dedit(dialog,edit9_item,w_str);
        get_dedit(dialog,edit10_item,e_str);
        end_dialog(dialog);
        delete_dialog(dialog);
END;

PROCEDURE o_window;     { open main window }

BEGIN
  w_title:=concat(' ',name_st,' ');
  des:=new_window(g_close|g_name|g_uparrow|g_dnarrow|g_vslide|g_move|g_size|
                 g_full ,w_title,0,0,0,0);
  open_window(des,0,0,0,0);
  work_rect(des,x,y,w,h);
  set_clip(x,y,w,h);

END;

PROCEDURE c_window;       { close main window }

BEGIN
        close_window(des);
        delete_window(des);
END;

PROCEDURE print( i : integer );      {  prints record titles }
                { res takes care of medium and high resolution diff }
BEGIN
            hide_mouse;
            work_rect(des,x,y,w,h);
            paint_color(0);
            paint_style(1);
            paint_rect(x,y,w,h);
            text_style(thickened);
            draw_mode(1);
            draw_string(x+288,y+res*2,'Record #');
            draw_string(x+80,y+5*res,'First Name :');
            draw_string(x+80,y+6*res,'Last Name :');
            draw_string(x+80,y+7*res,'Title :');
            draw_string(x+80,y+8*res,'Address :');
            draw_string(x+80,y+9*res,'City :');
            draw_string(x+80,y+10*res,'State :');
            draw_string(x+80,y+11*res,'Zip Code :');
            draw_string(x+80,y+12*res,'Home Phone :');
            draw_string(x+80,y+13*res,'Work Phone :');
            draw_string(x+80,y+14*res,'Extra :');
            text_style(normal);
            draw_mode(1);
            show_mouse;
END;

PROCEDURE show( i : integer);   { print actual record - i equals record # }

VAR num_str : PACKED array [1..3] of char;

BEGIN
            hide_mouse;
            draw_string(x+352,y+res*2,'   ');
            if i>100 then
             BEGIN
                 num_str[1]:=chr(ord('0')+trunc(i/100));
                 num_str[2]:=chr(ord('0')+trunc((i mod 100)/10));
            num_str[3]:=chr(ord('0')+((i mod 100)-(trunc((i mod 100)/10)*10)));
             END;
            if i=100 then
               num_str:='100';
            if (i>=10) and (i<100) then begin
               num_str[1]:=' ';
               num_str[2]:=chr(ord('0')+trunc(i/10));
               num_str[3]:=chr(ord('0')+(i mod 10));
             end;
            if (i>=0) and (i<10) then begin
               num_str[1]:=' ';
               num_str[2]:=' ';
               num_str[3]:=chr(ord('0')+i);
             end;
            draw_string(x+352,y+res*2,num_str);
            with buf[i] do begin
                draw_string(x+184,y+5*res,fname);
                draw_string(x+176,y+6*res,lname);
                draw_string(x+144,y+7*res,title);
                draw_string(x+160,y+8*res,address);
                draw_string(x+136,y+9*res,city);
                draw_string(x+144,y+10*res,state);
                draw_string(x+168,y+11*res,zip);
                draw_string(x+184,y+12*res,hphone);
                draw_string(x+184,y+13*res,wphone);
                draw_string(x+144,y+14*res,extra);
          end;   { with }
          show_mouse;
END;

PROCEDURE sort;  { bubble sort - exchanges whole records }

VAR  window,d,x1,y1,w1,h1,c : integer;
     wstr : string[80];
     sort_flag : boolean;

BEGIN
        hide_mouse;
        wstr:='randy';  { not used }
        window:=new_window(0,wstr,0,0,0,0); { small window that shows sorting }
        open_window(window,200,res*10,250,res*6);
        work_rect(window,x1,y1,w1,h1);
        set_clip(x1,y1,w1,h1);
        draw_mode(1);
        paint_style(26);
        paint_color(1);
        paint_rect(x1,y1,w1,h1);
        paint_style(1);
        paint_color(0);
        draw_string(x1+64,y1+res*3,'Sorting .....');
        show_mouse;
        REPEAT    { repeat exchanges until sort_flag=false }
           sort_flag:=false; { initalize sort_flag }
           for c:=1 to (record_number-1) do
             begin
                 if buf[c+1].lname<buf[c].lname then
                    begin
                        temp:=buf[c+1];
                        buf[c+1]:=buf[c];
                        buf[c]:=temp;
                        sort_flag:=true;
                    end;
                 if buf[c+1].lname=buf[c].lname then
                    begin
                      if buf[c+1].fname<buf[c].fname then begin
                        temp:=buf[c+1];
                        buf[c+1]:=buf[c];
                        buf[c]:=temp;
                        sort_flag:=true;
                      end
                    end
              end;
          UNTIL (not sort_flag); { if sort_flag=false then records in order }
        close_window(window);
        delete_window(window);

END;

FUNCTION paper_number(str : str255) : integer;

VAR  print_flag : boolean;   { search backward through fields to find the }
     count : integer;        { first non blank. This is the true length   }
                             { of this field. Needed for printing         }
BEGIN
        print_flag:=false;
        count:=length(str);
        REPEAT
                if str[count] <> ' ' then
                        print_flag:=true;
                count:=count-1;
        UNTIL (print_flag=true) or (count=0);
        if print_flag then begin
                count:=count+1;
                paper_number:=count;
          end;
        if not print_flag then
          paper_number:=count;

END;

PROCEDURE paper;   { print one mailing label  }

LABEL 1;

VAR    temp_str : str255;
       oop,count : integer;
       a : long_integer;

BEGIN
        a:=printout_stat;  { check printer status }
        if a=0 then begin
           count:=do_alert('[3][Printer not turned on][ OK ]',1);
           goto 1;
         end;
           for oop:=1 to before_line do   { print left margin }
                printout(' ');       { set by print option dialog }
        if title_flag then begin    { if title_flag set then print title }
        temp_str:=buf[i].title;
        count:=paper_number(temp_str);
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(' ');
         end;
        temp_str:=buf[i].fname;
        count:=paper_number(temp_str); { print first name and space }
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(' ');
        temp_str:=buf[i].lname;      { print last name and go to next line }
        count:=paper_number(temp_str);
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(chr(10));
            printout(chr(13));
           for oop:=1 to before_line do   { left margin for second line }
                printout(' ');
        temp_str:=buf[i].address;  { print address    }
        count:=paper_number(temp_str);
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(chr(10));
            printout(chr(13));
           for oop:=1 to before_line do    { left margin for third line }
                printout(' ');
        temp_str:=buf[i].city;      { print city and , and space }
        count:=paper_number(temp_str);
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(',');
            printout(' ');
        temp_str:=buf[i].state;   { print state and space }
        count:=paper_number(temp_str);
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(' ');
        temp_str:=buf[i].zip;   { print zip code }
        count:=paper_number(temp_str);
        for oop:=1 to count do
            printout(temp_str[oop]);
            printout(chr(10));
            printout(chr(13));
        for oop:=1 to blank_line do begin   { print spacing between labels }
            printout(chr(10));         { as set by print options dialog }
            printout(chr(13));
         end;
     1: menu_normal(menu,select_title);

END;

FUNCTION p_dialog : boolean;  { print range of labels dialog }

LABEL 1;

VAR dialog : dialog_ptr;
    prompt_item,cancel,date_item,edit_item,ok_btn,button : integer;
    event,dummy,date2_item,edit2_item,counter,prompt2_item : integer;
    prompt3_item,date3_item,date4_item : integer;
    c,d : string[255];
    a : long_integer;
    msg : message_buffer;
    l_flag : boolean;

BEGIN
        c:='';
        d:='';
        dialog := New_Dialog( 13, 0, 0, 40, 13 ) ;
        prompt_item := Add_DItem( dialog,G_text,None,5,1,31,1,0,$1180) ;
        Set_DText( dialog, prompt_item, 'Enter First Letter of Last Name',
                        System_Font, TE_Center ) ;
        prompt2_item := Add_DItem( dialog,G_text,None,8,2,19,1,0,$1180) ;
        Set_DText( dialog, prompt2_item, '     to Print Range',
                        System_Font, TE_Center ) ;
        date_item := Add_DItem( dialog, G_Text, None, 5, 4, 8, 1, 0, $1180 );
        Set_Dtext( dialog, date_item, 'Start : ',
                        System_Font, TE_Center ) ;
        edit_item := Add_DItem( dialog, G_fText,None, 13, 4,1, 1, 0, $1180 );
        Set_Dedit( dialog, edit_item, '_','a','',
                        System_Font, TE_Center ) ;
        date2_item := Add_DItem( dialog, G_Text, None, 28, 4, 6, 1, 0, $1180 );
        Set_Dtext( dialog, date2_item, 'End : ',
                        System_Font, TE_Center ) ;
        edit2_item := Add_DItem( dialog, G_fText,None, 34, 4,1, 1, 0, $1180 );
        Set_Dedit( dialog, edit2_item, '_','a','',
                        System_Font, TE_Center ) ;
        prompt3_item := Add_DItem( dialog,G_text,None,12,6,16,1,0,$1180) ;
        Set_DText( dialog, prompt3_item, 'Select one below',
                        System_Font, TE_Center ) ;
        date3_item := Add_DItem( dialog, G_Button, Selectable|radio_btn,
                       10, 8, 9, 1, 2, $1180 ) ;
        Set_DText( dialog, date3_item, 'LABELS', System_Font, TE_Center ) ;
        date4_item := Add_DItem( dialog, G_Button, Selectable|radio_btn,
                       20, 8, 9, 1, 2, $1180 ) ;
        Set_DText( dialog, date4_item, 'RECORDS', System_Font, TE_Center ) ;
        obj_setstate(dialog,date3_item,1,false);
        cancel := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                       26, 10, 8, 2, 6, $1180 ) ;
        Set_DText( dialog, cancel, 'Cancel', System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                       6, 10, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, edit_item ) ;
        if button=ok_btn then begin
            ok_btn:=obj_state(dialog,date3_item);
            if ok_btn=1 then
               l_flag:=true;  { print labels }
            ok_btn:=obj_state(dialog,date4_item);
            if ok_btn=1 then
               l_flag:=false;  { print records }
            get_dedit(dialog,edit_item,c);
            get_dedit(dialog,edit2_item,d);
            if length(c)=0 then
               goto 1;
            if c[1] in ['a'..'z'] then   { convert lower to upper case }
               c[1]:=chr(ord(c[1])-32);  { first letter of name is always }
            if d[1] in ['a'..'z'] then      { upper case a dictated by }
               d[1]:=chr(ord(d[1])-32);     { add new record dialog   }
            if length(d)=0 then
               d[1]:=c[1];   { if only start letter is given then let end }
            if c[1]>d[1] then  { letter also be the same -ie: print one letter}
               goto 1;
            p_dialog:=true;
            a:=printout_stat;  { check printer status }
            if a=0 then begin
              counter:=do_alert('[3][Printer not turned on][ OK ]',1);
              goto 1;
            end;
            for counter:=1 to record_number do  {loop through all records }
              BEGIN
   event:=get_event(e_keyboard|e_timer,1,1,1,0,false,0,0,0,0,false,0,0,0,0,msg,
                           dummy,dummy,dummy,dummy,dummy,dummy);
                  if (event & e_keyboard)>0 then
                     goto 1;  { if press key then stop printing }
                  if buf[counter].lname[1] in [c[1]..d[1]] then
                     BEGIN     { if first letter of last name is in range }
                        i:=counter;    { then print label using paper }
                        if l_flag then
                         paper;
                        if not l_flag then
                         paper_record;
                     END;
              END;
        end;
        if button=cancel then
     1:     p_dialog:=false;
        end_dialog(dialog);
        delete_dialog(dialog);
END;

PROCEDURE dial;   { send dial codes to the modem }

LABEL 1;

VAR count,a : integer;

BEGIN
        if (not (work_flag) and (buf[i].hphone='              ')) or
        ((work_flag) and (buf[i].wphone='              ')) then
           BEGIN
             a:=do_alert('[2][No Phone number present][ OK ]',1);
             goto 1;
           END;
        if service_type=1 then  { send alt dial codes }
         begin
             for count:=1 to length(dial_b_str) do
                 bconout(1,dial_b_str[count]);
             for count:=1 to length(mci_str) do
                 bconout(1,mci_str[count]);
             if work_flag then begin
             for count:=1 to 14 do
                 bconout(1,buf[i].wphone[count]);
              end;
             if not work_flag then begin
             for count:=1 to 14 do
                 bconout(1,buf[i].hphone[count]);
              end;
             bconout(1,chr(13));
         end;
        if service_type=2 then   { send AT&T dial codes }
          begin
             for count:=1 to length(dial_b_str) do
                 bconout(1,dial_b_str[count]);
             if one_flag then
                 bconout(1,'1');
             if work_flag then begin
             for count:=1 to 14 do
                 bconout(1,buf[i].wphone[count]);
              end;
             if not work_flag then begin
             for count:=1 to 14 do
                 bconout(1,buf[i].hphone[count]);
              end;
             bconout(1,chr(13));
          end;
        if service_type=3 then   { send local dial codes  }
           begin
             for count:=1 to length(dial_b_str) do
                 bconout(1,dial_b_str[count]);
             if work_flag then begin
                 count:=1;
                 a:=0;
                 REPEAT   { bypass first three numbers for local dialing }
                     if buf[i].wphone[count] in ['0'..'9'] then
                        a:=a+1;
                     count:=count+1;
                 UNTIL (a=3);
                 for a:=count to 14 do
                    bconout(1,buf[i].wphone[a]);
                 bconout(1,chr(13));
              end;
             if not work_flag then begin
                 count:=1;
                 a:=0;
                 REPEAT
                     if buf[i].hphone[count] in ['0'..'9'] then
                        a:=a+1;
                     count:=count+1;
                 UNTIL (a=3);
                 for a:=count to 14 do
                    bconout(1,buf[i].hphone[a]);
                 bconout(1,chr(13));
              end
           end;
      1: menu_normal(menu,select_title);

END;

PROCEDURE foward;  { move foward one record }

BEGIN
                  i:=i+1;
                  if i=record_number+1 then i:=1; { if last record then show }
                  work_rect(des,x,y,w,h);           { first record next }
                  set_clip(x,y,w,h);
                  show(i);     { show new record }
                 wind_set(des,wf_vslide,(round((1000/record_number)*i)),0,0,0);
                  if i=1 then
                     wind_set(des,wf_vslide,1,0,0,0); { set slides bar }
END;

PROCEDURE back;  { move back one record }

BEGIN
                  i:=i-1;
                  if i<1 then i:=1; { 1 is first record can't be less }
                    work_rect(des,x,y,w,h);
                    set_clip(x,y,w,h);
                    show(i);     { show new record }
                 wind_set(des,wf_vslide,(round((1000/record_number)*i)),0,0,0);
                  if i=1 then
                    wind_set(des,wf_vslide,1,0,0,0); {set slider bar}

END;

FUNCTION search_dialog : char;  { search dialog - get first and last name }
                                 { to search for }
VAR dialog : dialog_ptr;
    edit2_item,prompt_item,cancel,date_item,edit_item,ok_btn,button : integer;

BEGIN
        dialog := New_Dialog( 4, 0, 0, 40, 13 ) ;
        prompt_item := Add_DItem( dialog,G_text,None,10,1,16,1,0,$1180) ;
        Set_DText( dialog, prompt_item, 'Enter First Name',
                        System_Font, TE_Center ) ;
        edit_item := Add_DItem( dialog, G_fText,None, 10, 3,15, 1, 0, $1180 );
        Set_Dedit( dialog, edit_item, '_______________','aaaaaaaaaaaaaaa',
                       '', System_Font, TE_Center ) ;
        date_item := Add_DItem( dialog, G_Text, None, 10, 5, 15, 1, 0, $1180 );
        Set_Dtext( dialog, date_item, 'Enter Last Name',
                        System_Font, TE_Center ) ;
        edit2_item := Add_DItem( dialog, G_fText,None, 10, 7,15, 1, 0, $1180 );
        Set_Dedit( dialog, edit2_item, '_______________','aaaaaaaaaaaaaaa',
                        '',System_Font, TE_Center ) ;
        cancel := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                       26, 9, 8, 2, 6, $1180 ) ;
        Set_DText( dialog, cancel, 'Cancel', System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                       6, 9, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, edit_item ) ;
        if button=ok_btn then begin
            get_dedit(dialog,edit_item,f);
            get_dedit(dialog,edit2_item,l);
            search_dialog:='0';
            menu_normal(menu,main_title);
        end;
        if button=cancel then begin
            search_dialog:='1';
            menu_normal(menu,main_title);
        end;
        end_dialog(dialog);
        delete_dialog(dialog);
END;

FUNCTION get_name : boolean; { search through records to look for match of }
                             { first and last name }
LABEL 2,3;

VAR c : char;
    count,a,d,upper : integer;
    match : boolean;
    fir,las : str255;

BEGIN
        match:=false;
        c:=search_dialog;
        if c='1' then begin   { cancel button pressed }
           get_name:=false;
           goto 2;
         end;
        count:=0;
        REPEAT
            count:=count+1;
            a:=1;
            with buf[count] do begin
                 if l='' then
                    goto 3;
                 fir:=l;  { use temp strings for last name fields }
                 las:=lname;
                 for upper:=1 to length(fir) do  { convert to temp upper case }
                     if fir[upper] in ['a'..'z'] then
                          fir[upper]:=chr(ord(fir[upper])-32);
                 for upper:=1 to length(las) do
                     if las[upper] in ['a'..'z'] then
                          las[upper]:=chr(ord(las[upper])-32);
                 while (fir[a]=las[a]) do  { check for full or partial match }
                     begin
                         if (a=length(fir)) and (a<15) and (las[a+1]=' ') then
                              begin
                                  match:=true;
                              end;
                         if (a=length(fir)) and (a=15) then
                              begin
                                  match:=true;
                              end;
                         if (a=length(fir)) then
                              begin
                                  match:=true;
                              end;
                         if match=true then  { if match last name then check }
                          begin              { for first name }
                            3:  fir:=f;   { again use temp strings and convert}
                                las:=fname;    { to upper case   }
                                for upper:=1 to length(fir) do
                                  if fir[upper] in ['a'..'z'] then
                                    fir[upper]:=chr(ord(fir[upper])-32);
                                for upper:=1 to length(las) do
                                  if las[upper] in ['a'..'z'] then
                                    las[upper]:=chr(ord(las[upper])-32);
                                d:=1;
                                if f='' then { no first name given so bypass }
                                  begin      { check for first name }
                                    get_name:=true;
                                    goto 2;
                                  end;  { check for first name match }
                                while (fir[d]=las[d]) do
                                    begin
                         if (d=length(fir)) and (d<15) and (las[d+1]=' ') then
                              begin
                                  get_name:=true;
                                  goto 2;
                              end;
                         if (d=length(fir)) and (d=15) then
                              begin
                                  get_name:=true;
                                  goto 2;
                              end;
                         if (d=length(fir)) then
                              begin
                                  get_name:=true;
                                  goto 2;
                              end;
                          d:=d+1;
                          match:=false;
                          end { match }
                          end; { while }
                         a:=a+1;
                     end
            end;
        UNTIL (count=record_number);  { go through all reords }
        a:=do_alert('[1][No Match Found][ OK ]',1);  { no match found }
        get_name:=false;
     2: i:=count; { set i to record that matched - i=active record }

END;

PROCEDURE option_dial;  { dialing option dialog }

VAR dialog : dialog_ptr;
    prompt_item,cancel,date_item,edit_item,ok_btn,button : integer;
    a,prompt2_item,prompt3_item,edit2_item,edit3_item,date2_item : integer;
    date4_item,date3_item,prompt4_item,prompt5_item,r5_item  : integer;
    prompt6_item,r6_item,prompt7_item : integer;
    c,d : string[255];

BEGIN
        dialog := New_Dialog( 18, 0, 0, 40, 22 ) ;
        prompt3_item := Add_DItem( dialog,G_text,None,10,1,18,1,0,$1180) ;
        Set_DText( dialog, prompt3_item, 'Dial Options Menu',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog,G_text,None,3,3,34,1,0,$1180) ;
        Set_DText( dialog, prompt_item, 'Enter Hayes Command (ie:ATS7=11DT)',
                        System_Font, TE_Center ) ;
        edit_item := Add_DItem( dialog, G_fText,None, 7, 4,10, 1, 0, $1180 );
        Set_Dedit( dialog, edit_item, '__________','XXXXXXXXXX',dial_b_str,
                        System_Font, TE_Center ) ;
        prompt2_item := Add_DItem( dialog,G_text,None,3,6,35,1,0,$1180) ;
        Set_DText( dialog, prompt2_item, 'Alt. Long Distance Carriers (ALDC)',
                        System_Font, TE_Center ) ;
        prompt7_item := Add_DItem( dialog,G_text,None,5,7,31,1,0,$1180) ;
        Set_DText( dialog, prompt7_item, 'Enter code (ie:527-0600,,12345)',
                        System_Font, TE_Center ) ;
        edit2_item := Add_DItem( dialog, G_fText,None, 7,8,17, 1, 0, $1180 );
        Set_Dedit( dialog, edit2_item, '_________________','XXXXXXXXXXXXXXXXX',
                        mci_str,System_Font, TE_Center ) ;
        prompt4_item := Add_DItem( dialog,G_text,None,15,10,10,1,0,$1180) ;
        Set_DText( dialog, prompt4_item, 'Select One',
                        System_Font, TE_Center ) ;
        date_item := Add_DItem( dialog, G_Button, Selectable|radio_btn,
                       5, 12, 7, 2, 2, $1180 ) ;
        Set_DText( dialog, date_item, 'ALDC', System_Font, TE_Center ) ;
        date2_item := Add_DItem( dialog, G_Button, Selectable|radio_btn,
                       16, 12, 7, 2, 2, $1180 ) ;
        Set_DText( dialog, date2_item, 'AT&T', System_Font, TE_Center ) ;
        date3_item := Add_DItem( dialog, G_Button, Selectable|radio_btn,
                       28, 12, 7, 2, 2, $1180 ) ;
        Set_DText( dialog, date3_item, 'Local', System_Font, TE_Center ) ;
        prompt5_item := Add_DItem( dialog,G_text,None,3,15,26,1,0,$1180) ;
        Set_DText( dialog, prompt5_item, 'Select to dial work number',
                        System_Font, TE_Center ) ;
        r5_item := Add_DItem( dialog, G_Button, touch_exit,
                       30, 15, 2, 1, 1, $1180 ) ;
        Set_DText( dialog, r5_item, ' ', System_Font, TE_Center ) ;
        obj_setstate(dialog,r5_item,0,false);
        if work_flag then
           obj_setstate(dialog,r5_item,4,false);
        if service_type=1 then
           obj_setstate(dialog,date_item,1,false);
        if service_type=2 then
           obj_setstate(dialog,date2_item,1,false);
        if service_type=3 then
           obj_setstate(dialog,date3_item,1,false);
        prompt6_item := Add_DItem( dialog,G_text,None,3,17,27,1,0,$1180) ;
        Set_DText( dialog, prompt6_item, 'Add ''1'' before AT&T number?',
                        System_Font, TE_Center ) ;
        r6_item := Add_DItem( dialog, G_Button, touch_exit,
                       31, 17, 2, 1, 1, $1180 ) ;
        Set_DText( dialog, r6_item, ' ', System_Font, TE_Center ) ;
        obj_setstate(dialog,r6_item,0,false);
        if one_flag then
           obj_setstate(dialog,r6_item,4,false);
        cancel := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                       26, 19, 8, 2, 6, $1180 ) ;
        Set_DText( dialog, cancel, 'Cancel', System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                       6, 19, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, edit_item ) ;
         while (button=r5_item) or (button=r6_item) do begin
          if button=r5_item then
           BEGIN
            a:=obj_state(dialog,r5_item);
            if a=4 then begin
               obj_setstate(dialog,r5_item,0,true);
             end;
            if a<>4 then  begin
               obj_setstate(dialog,r5_item,4,true);
             end;
           END;
          if button=r6_item then
           BEGIN
            a:=obj_state(dialog,r6_item);
            if a=4 then begin
               obj_setstate(dialog,r6_item,0,true);
             end;
            if a<>4 then  begin
               obj_setstate(dialog,r6_item,4,true);
             end;
           END;
            button:=redo_dialog(dialog,edit_item);
          end;
        if button=ok_btn then begin
            get_dedit(dialog,edit_item,dial_b_str);
            get_dedit(dialog,edit2_item,mci_str);
            a:=obj_state(dialog,r5_item);
            if a=4 then
               work_flag:=true;
            if a<>4 then
               work_flag:=false;
            a:=obj_state(dialog,r6_item);
            if a=4 then
               one_flag:=true;
            if a<>4 then
               one_flag:=false;
            a:=obj_state(dialog,date_item);
            if a=1 then
               service_type:=1;
            a:=obj_state(dialog,date2_item);
            if a=1 then
               service_type:=2;
            a:=obj_state(dialog,date3_item);
            if a=1 then
               service_type:=3;
        end;
        end_dialog(dialog);
        delete_dialog(dialog);
        menu_normal(menu,option_title);
END;

PROCEDURE option_print; { printer option dialog }

VAR dialog : dialog_ptr;
    prompt_item,cancel,date_item,edit_item,ok_btn,button : integer;
    a,prompt2_item,prompt3_item,edit2_item,edit3_item,date2_item : integer;
    c,d : string[255];

BEGIN
        c:=chr(ord('0')+before_line);  { convert integer to char }
        d:=chr(ord('0')+blank_line);
        dialog := New_Dialog( 10, 0, 0, 40, 13 ) ;
        prompt3_item := Add_DItem( dialog,G_text,None,10,1,18,1,0,$1180) ;
        Set_DText( dialog, prompt3_item, 'Print Options Menu',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog,G_text,None,3,3,26,1,0,$1180) ;
        Set_DText( dialog, prompt_item, 'Enter # spaces to indent :',
                        System_Font, TE_Center ) ;
        edit_item := Add_DItem( dialog, G_fText,None, 30, 3,1, 1, 0, $1180 );
        Set_Dedit( dialog, edit_item, '_','9',c,
                        System_Font, TE_Center ) ;
        prompt2_item := Add_DItem( dialog,G_text,None,3,5,30,1,0,$1180) ;
        Set_DText( dialog, prompt2_item, 'Enter # lines between labels :',
                        System_Font, TE_Center ) ;
        edit2_item := Add_DItem( dialog, G_fText,None, 34,5,1, 1, 0, $1180 );
        Set_Dedit( dialog, edit2_item, '_','9',d,
                        System_Font, TE_Center ) ;
        date2_item := Add_DItem( dialog,G_text,None,7,7,14,1,0,$1180) ;
        Set_DText( dialog, date2_item, 'Print Titles ?',
                        System_Font, TE_Center ) ;
        date_item := Add_DItem( dialog, G_button, touch_exit,
                       22, 7, 2, 1, 1, $1180 ) ;
        Set_DText( dialog, date_item, ' ',
                        System_Font, TE_Center ) ;
        obj_setstate(dialog,date_item,0,false);
        if title_flag then begin
             obj_setstate(dialog,date_item,4,false);
          end;
        cancel := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                       26, 10, 8, 2, 6, $1180 ) ;
        Set_DText( dialog, cancel, 'Cancel', System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                       6, 10, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, edit_item ) ;
          while button=date_item do begin
            a:=obj_state(dialog,date_item);
            if a=4 then begin
               obj_setstate(dialog,date_item,0,true);
             end;
            if a<>4 then  begin
               obj_setstate(dialog,date_item,4,true);
             end;
            button:=redo_dialog(dialog,edit_item);
          end;
         if button=ok_btn then begin
            get_dedit(dialog,edit_item,c);
            get_dedit(dialog,edit2_item,d);
            a:=obj_state(dialog,date_item);
            if a=4 then
               title_flag:=true;
            if a<>4 then
               title_flag:=false;
            blank_line:=ord(d[1])-ord('0');
            before_line:=ord(c[1])-ord('0');
        end;
        end_dialog(dialog);
        delete_dialog(dialog);
        menu_normal(menu,option_title);

END;

PROCEDURE paper_record;

LABEL 1;

VAR counter : integer;
    a : long_integer;
    who_str : str255;

PROCEDURE action( name : str255 );

VAR counter : integer;

BEGIN
            for counter:=1 to before_line do
               printout(' ');
            for counter:=1 to length(name) do
               printout(name[counter]);
            printout(chr(10));
            printout(chr(13));
END;

BEGIN
            a:=printout_stat;  { check printer status }
            if a=0 then begin
              counter:=do_alert('[3][Printer not turned on][ OK ]',1);
              goto 1;
            end;
            with buf[i] do begin   {                                       }
              who_str:=fname;    {                                     }
              who_str:=concat('First Name : ',who_str);
              action(who_str);
              who_str:=lname;
              who_str:=concat('Last Name : ',who_str);
              action(who_str);
              who_str:=title;
              who_str:=concat('Title : ',who_str);
              action(who_str);
              who_str:=address;
              who_str:=concat('Address : ',who_str);
              action(who_str);
              who_str:=city;
              who_str:=concat('City : ',who_str);
              action(who_str);
              who_str:=state;
              who_str:=concat('State : ',who_str);
              action(who_str);
              who_str:=zip;
              who_str:=concat('Zip Code : ',who_str);
              action(who_str);
              who_str:=hphone;
              who_str:=concat('Home Phone : ',who_str);
              action(who_str);
              who_str:=wphone;
              who_str:=concat('Work Phone : ',who_str);
              action(who_str);
              who_str:=extra;
              who_str:=concat('Extra : ',who_str);
              action(who_str);
         end; { with }
         for counter:=1 to blank_line do
              BEGIN
               printout(chr(10));
               printout(chr(13));
              END;
         1: menu_normal(menu,select_title);
END;

PROCEDURE search; { routine for searching for specific item }

LABEL 1;

VAR  s : boolean;

BEGIN
        s:=get_name;  { get name to search for }
        if s=false then  { if cancel then skip to end }
           goto 1;
        o_window;    { open window }
        print(i);  { print titles }
        show(i);   { print record }  { set slider bar }
        wind_set(des,wf_vslide,(round((1000/record_number)*i)),0,0,0);
        if i=1 then
          wind_set(des,wf_vslide,1,0,0,0);
   event:=get_event(e_message,0,0,0,0,false,0,0,0,0,false,0,0,0,0,msg,
                           dummy,dummy,dummy,dummy,dummy,dummy);
        main_off;    { deselect main title bar }
        select_on;   { enable select title bar }
        REPEAT    { get message event }
          event:=get_event(e_message,0,0,0,0,false,0,0,0,0,false,0,0,0,0,msg,
                           dummy,dummy,dummy,dummy,dummy,dummy);
          if (msg[3]=select_title) and (msg[4]=printout_item) then
                paper; { if printer then print label }
          if (msg[3]=select_title) and (msg[4]=p_range_item) then
                 paper_record;
          if (msg[3]=main_title) and (msg[4]=edit_item) then
             BEGIN
                edit(1);
             END;
          if (msg[3]=select_title) and (msg[4]=dialout_item) then
                dial;  { if dial then dial number }
          if (msg[3]=option_title) and (msg[4]=print_item) then
                option_print;  { call printer option dialog }
          if (msg[3]=option_title) and (msg[4]=dial_item) then
                option_dial;  { call dial option dialog }
          if (msg[3]=option_title) and (msg[4]=save_item) then
                option_save;  { call save option item }
          if (msg[3]=3) and (msg[4]=10) then begin  { about program called }
           my_window;
           menu_normal(menu,3);
          end;
          if (msg[0]=wm_arrowed) and (msg[4]=3) then
                foward;  { down arrow selected }
          if (msg[0]=wm_arrowed) and (msg[4]=2) then
                back;   { up arrow selected }
          if (msg[0]=wm_arrowed) and (msg[4]=0) then
             BEGIN   { upper grey area selected - go back by ten's }
                  i:=i-10;
                  if i<=0 then i:=1;
                  work_rect(des,x,y,w,h);
                  set_clip(x,y,w,h);
                  show(i);
                 wind_set(des,wf_vslide,(round((1000/record_number)*i)),0,0,0);
                  if i=1 then
                     wind_set(des,wf_vslide,1,0,0,0);
             END;
          if (msg[0]=wm_arrowed) and (msg[4]=1) then
             BEGIN  { lower grey area selected - go foward by ten's }
                  i:=i+10;
                  if i>record_number then i:=record_number;
                  work_rect(des,x,y,w,h);
                  set_clip(x,y,w,h);
                  show(i);
                 wind_set(des,wf_vslide,(round((1000/record_number)*i)),0,0,0);
                  if i=1 then
                     wind_set(des,wf_vslide,1,0,0,0);
             END;
          if msg[0]=wm_vslid then begin { slider bar selected }
               i:=round((msg[4]/(1000/record_number)));
               wind_set(des,wf_vslide,(round((1000/record_number)*i)),0,0,0);
               if i=0 then
                i:=1;
               work_rect(des,x,y,w,h);
               set_clip(x,y,w,h);
               print(i);
               show(i);
            end;
          if (msg[0]=wm_topped) then  { new window to move to the top }
             bring_to_front(msg[3]);
          if (msg[0]=wm_fulled) then begin  { window fulled box selected }
               border_rect(msg[3],x3,y3,w3,h3);
               wind_get(msg[3],wf_fullxywh,x,y,w,h);
               if ((x=x3) and (y=y3) and (w=w3) and (h=h3)) then
                  wind_get(msg[3],wf_prevxywh,x,y,w,h);
               set_wsize(msg[3],x,y,w,h);
            end;
          if (msg[0]=wm_sized) or (msg[0]=wm_moved) then { window sized or}
               set_wsize(msg[3],msg[4],msg[5],msg[6],msg[7]); { moved selected}
          if (msg[0]=wm_redraw) then begin { redraw window message }
               begin_update;   { freeze window }
               first_rect(msg[3],x3,y3,w3,h3);  { find first rect to redraw }
               WHILE (w3<>0) and (h3<>0) do  {if zero then no rect to redraw }
               begin
                if rect_intersect(msg[4],msg[5],msg[6],msg[7],x3,y3,w3,h3) then
                   begin  { find intersection of rect }
                      set_clip(x3,y3,w3,h3);  { set clipping and redraw }
                      print(i);
                      show(i);
                   end;
                next_rect(msg[3],x3,y3,w3,h3);  { find next rect and redraw }
               end;
              end_update;
              work_rect(msg[3],x,y,w,h);
              set_clip(x,y,w,h);
            end;
    UNTIL (msg[0]=wm_closed);  { loop through event until close box activated }
        c_window;  { close window }
     1: main_on;    { reselect main titles and deselect select titles }
        select_off;
        menu_normal(menu,select_title);

END;

PROCEDURE space_record; { Clears out one record with spaces }

BEGIN
       with buf[i] do begin
        fname:='               ';
        lname:='               ';
        title:='          ';
        address:='                         ';
        city:='                    ';
        state:='  ';
        zip:='          ';
        hphone:='              ';
        wphone:='              ';
        extra:='                         ';
      end
END;

PROCEDURE edit;    { edit record }

LABEL 1,2;

VAR s : boolean;
    d : integer;

BEGIN
        if num=1 then
           goto 2;
        s:=get_name; { find name to edit }
        if s=false then    { cancel - bypass rest }
           goto 1;
     2: with buf[i] do begin   { place all fields of record in strings }
              f_str:=fname;    { this will show as default in dialog }
              l_str:=lname;
              t_str:=title;
              a_str:=address;
              c_str:=city;
              s_str:=state;
              z_str:=zip;
              h_str:=hphone;
              w_str:=wphone;
              e_str:=extra;
         end; { with }
        d_name_str:='Edit Record';
        s:=add_dialog;   { call add dialog }
        if s=true then begin { check for valid record below }
        if (f_str='') or (l_str='') or(f_str[1]=' ')or(l_str[1]=' ')then begin
              d:=do_alert('[3][Not a valid record !!][ OK ]',1);
              goto 1;
            end;
           space_record;  { clear out record with blanks }
        with buf[i] do begin  { copy strings into respective record fields }
        for d:=1 to length(f_str) do
            fname[d]:=f_str[d];
        for d:=1 to length(l_str) do
            lname[d]:=l_str[d];
        for d:=1 to length(t_str) do
            title[d]:=t_str[d];
        for d:=1 to length(a_str) do
            address[d]:=a_str[d];
        for d:=1 to length(c_str) do
            city[d]:=c_str[d];
        for d:=1 to length(s_str) do
            state[d]:=s_str[d];
        for d:=1 to length(z_str) do
            zip[d]:=z_str[d];
        for d:=1 to length(h_str) do
            hphone[d]:=h_str[d];
        for d:=1 to length(w_str) do
            wphone[d]:=w_str[d];
        for d:=1 to length(e_str) do
            extra[d]:=e_str[d];
        if (fname[1] in ['a'..'z']) then
            fname[1]:=chr(ord(fname[1])-32);
        if (lname[1] in ['a'..'z']) then
            lname[1]:=chr(ord(lname[1])-32);
        if (title[1] in ['a'..'z']) then
            title[1]:=chr(ord(title[1])-32);
        if (city[1] in ['a'..'z']) then
            city[1]:=chr(ord(city[1])-32);
        if (state[1] in ['a'..'z']) then
            state[1]:=chr(ord(state[1])-32);
        if (state[2] in ['a'..'z']) then
            state[2]:=chr(ord(state[2])-32);
        end;  { with }
           sort;
           save_flag:=true;
       end; { if d=true }
    1:  menu_normal(menu,main_title);

END;

FUNCTION  d_dialog : boolean;  { delete this record dialog }

  VAR
    dialog : Dialog_Ptr ;
    button,
    ok_btn,
    cancel_btn,
    prompt_item,
    date_item,dummy : integer ;

BEGIN
        dialog := New_Dialog( 4, 27,18, 26, 6 ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 2, 1, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, '  Delete this record?',
                        System_Font, TE_Left ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                        2, 3, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'YES', System_Font, TE_Center ) ;
        cancel_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|default,
                        16, 3, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, cancel_btn, 'NO', System_Font, TE_Center ) ;
        button := Do_Dialog( dialog,0 ) ;
        if button=ok_btn then
            d_dialog:=true;
        if button=cancel_btn then
            d_dialog:=false;
        end_dialog(dialog);
        delete_dialog(dialog);
END;

PROCEDURE delete;

LABEL 1;

VAR s : boolean;
    a : integer;

BEGIN
        s:=get_name;    { get name }
        if s=false then  { cancel and goto end }
          goto 1;
        o_window;     { open window }
        print(i);    { print record }
        show(i);
        main_off;      { deselect all menu items - only want to see record }
        select_off;       { and deceide if it should be deleted }
        s:=d_dialog;      { call up delete this record dialog }
        if s then begin    { if yes then move last record to the deleted pos. }
           buf[i]:=buf[record_number];
              with buf[record_number] do begin { clear last record with blanks}
                fname:='               ';
                lname:='               ';
                title:='          ';
                address:='                         ';
                city:='                    ';
                state:='  ';
                zip:='          ';
                hphone:='              ';
                wphone:='              ';
                extra:='                         ';
              end;   { with }
           record_number:=record_number-1;  { subtract 1 from record # }
           sort;    { sort the database }
           save_flag:=true;    { set save_flag }
         end;
        c_window;   { close window }
     1: main_on;    { put main titles back on }
        menu_normal(menu,select_title);

END;


PROCEDURE add;

LABEL 1,2;

VAR s : boolean;
    d : integer;
    alert_str : str255;

BEGIN
    alert_str:='[3][  Must have valid|first and last name][ OK ]';
    2:  f_str:='';   { initialize all strings to blanks }
        l_str:='';
        t_str:='';
        a_str:='';
        c_str:='';
        s_str:='';
        z_str:='';
        h_str:='';
        w_str:='';
        e_str:='';
        if record_number=max then begin  { see if we are at last record }
            d:=do_alert('[3][All records are full][ OK ]',1);
            goto 1;
            end;
        d_name_str:='Add New Record';
        s:=add_dialog;  { call up add dialog }
        if s=true then begin { check to see if it is a valid record }
         if (f_str='') or (l_str='') or(f_str[1]=' ')or(l_str[1]=' ')then begin
              d:=do_alert(alert_str,1);
              goto 2;
            end;
           record_number:=record_number+1;  { increment record_number }
           i:=record_number; { set i to record_number }
           space_record;   { clear out this record with blanks }
        with buf[i] do begin   { copy strings to record }
        for d:=1 to length(f_str) do
            fname[d]:=f_str[d];
        for d:=1 to length(l_str) do
            lname[d]:=l_str[d];
        for d:=1 to length(t_str) do
            title[d]:=t_str[d];
        for d:=1 to length(a_str) do
            address[d]:=a_str[d];
        for d:=1 to length(c_str) do
            city[d]:=c_str[d];
        for d:=1 to length(s_str) do
            state[d]:=s_str[d];
        for d:=1 to length(z_str) do
            zip[d]:=z_str[d];
        for d:=1 to length(h_str) do
            hphone[d]:=h_str[d];
        for d:=1 to length(w_str) do
            wphone[d]:=w_str[d];
        for d:=1 to length(e_str) do
            extra[d]:=e_str[d];
        if (fname[1] in ['a'..'z']) then
            fname[1]:=chr(ord(fname[1])-32);
        if (lname[1] in ['a'..'z']) then
            lname[1]:=chr(ord(lname[1])-32);
        if (title[1] in ['a'..'z']) then
            title[1]:=chr(ord(title[1])-32);
        if (city[1] in ['a'..'z']) then
            city[1]:=chr(ord(city[1])-32);
        if (state[1] in ['a'..'z']) then
            state[1]:=chr(ord(state[1])-32);
        if (state[2] in ['a'..'z']) then
            state[2]:=chr(ord(state[2])-32);
        end;  { with }
       sort;
       save_flag:=true;
       goto 2;
       end; { if s=true }
      1:  menu_normal(menu,main_title);

END;

PROCEDURE do_menu; { menu choices when no window is open }

LABEL 1,2,6 ;

VAR a : integer;
    b : boolean;
    alert_str,initfile_str : str255;

BEGIN
        if (msg[3]=main_title) and (msg[4]=search_item) then {search selected}
          BEGIN
             if record_number>0 then
                search;
             menu_normal(menu,main_title);
          END;
        if (msg[3]=main_title) and (msg[4]=edit_item) then  { edit selected }
          BEGIN
             if record_number>0 then
                edit(0);
             menu_normal(menu,main_title);
          END;
        if (msg[3]=main_title) and (msg[4]=delete_item) then { delete selected}
          BEGIN
             if record_number>0 then
                delete;
             menu_normal(menu,main_title);
          END;
        if (msg[3]=main_title) and (msg[4]=add_item) then  { add selected }
          BEGIN
             if (name_st<>'') then
                add;
             menu_normal(menu,main_title);
          END;
        if (msg[3]=option_title) and (msg[4]=print_item) then  {print dialog}
                option_print;
        if (msg[3]=option_title) and (msg[4]=dial_item) then { dial dialog }
                option_dial;
        if (msg[3]=option_title) and (msg[4]=save_item) then { save options }
                option_save;
        if (msg[3]=file_title) and (msg[4]=store_item) then  {save database}
            BEGIN
               if name_st='' then
                 goto 6;
    alert_str:=concat('[2][save changes made to| |  ',name_st,'][ YES | NO ]');
               a:=do_alert(alert_str,1);
               if a=1 then
                 BEGIN
                   save_file(name);
                   save_flag:=false;
                 END;
           6:  menu_normal(menu,file_title);
            END;
        if (msg[3]=file_title) and (msg[4]=load_item) then  {load new database}
            BEGIN
               if save_flag then
                 BEGIN
    alert_str:=concat('[2][save changes made to| |  ',name_st,'][ YES | NO ]');
                    a:=do_alert(alert_str,1);
                      if a=1 then
                        BEGIN
                          save_file(name);
                          save_flag:=false;
                        END;
                 END;
               a:=current_disk; { find current drive }
               path_st:=concat(chr(a+65),':\*.DAT');  { pathname string }
               initfile_str:='';    { init file name in dialog }
               if get_in_file(path_st,initfile_str) then  {GEM selector box}
                  BEGIN
                    name_st:=initfile_str;
                    convert(name_st,name);  {convert string to valid GEM name}
                    init_string;   { initialze database to blanks }
                    record_number:=0;  { initialize record_number }
                    save_flag:=false;  { initialize save_flag }
                    in_file  := gem_open( name, 0 ) ; { load file name }
                    if in_file<0 then
                     BEGIN
                       name_st:='';   { not valid file name so set to null }
                       goto 1;
                     END;
                    jes:=gem_read(in_file,max*154+1,buf ); {load in data file}
                    record_number:=int(long_round(jes/154));{find record num.}
                    if ((jes mod 154)<>0) then {check for valid file }
                      BEGIN
                        dummy:=do_alert('[1][Not Valid Data File][ OK ]',1);
                        record_number:=0;  { if not then init to 0 }
                        name_st:='';   { and set name to null }
                      END;
                1:  gem_close( in_file );   { close file }
                  END;
               menu_normal(menu,file_title);
            END;
        if (msg[3]=file_title) and (msg[4]=new_item) then  {start new file}
            BEGIN
               if save_flag then   {save changes to file in memory}
                 BEGIN
    alert_str:=concat('[2][save changes made to| |  ',name_st,'][ YES | NO ]');
                    a:=do_alert(alert_str,1);
                      if a=1 then
                        BEGIN
                          save_file(name);
                          save_flag:=false;
                        END;
                 END;
               a:=current_disk;
               path_st:=concat(chr(a+65),':\*.DAT');  { pathname string }
               initfile_str:='';
               if get_in_file(path_st,initfile_str) then
                  BEGIN
                     name_st:=initfile_str;
                     convert(name_st,name);
                     init_string;
                     record_number:=0;
                     save_flag:=false;
                     save_file(name);
                  END;
           2:  menu_normal(menu,file_title);
            END;
        if (msg[3]=main_title) and (msg[4]=p_item) then {print range labels}
         BEGIN
          if record_number>0 then { only print if database in memory }
            BEGIN
               b:=p_dialog;   { call print dialog }
               if b then
                 BEGIN
                    ;
                 END;
               menu_normal(menu,main_title);
            END;
          menu_normal(menu,main_title);
         END;
        if (msg[3]=3) and (msg[4]=10) then begin   { about prog. dialog }
           my_window;
           menu_normal(menu,3);
        end
END;

PROCEDURE event_loop;

VAR  a : integer;
     alert_str : str255;

BEGIN
        REPEAT  { loop through event until quit is selected }
          event:=get_event(e_message,0,0,0,0,false,0,0,0,0,false,0,0,0,0,msg,
                           dummy,dummy,dummy,dummy,dummy,dummy);
          do_menu; { main menu screen without an open window }
        UNTIL (msg[3]=main_title) and (msg[4]=leave_item);
        if save_flag then begin {quit selected and save_flag on - save changes}
    alert_str:=concat('[2][save changes made to| |  ',name_st,'][ YES | NO ]');
        a:=do_alert(alert_str,1);
        if a=1 then
           save_file(name); { save the changes to file name }
        end
END;

PROCEDURE put_back;   { load MAILCALL.INF and put values into variables }

TYPE rex = packed array [1..20] of char;

VAR count,scount : integer;
    t1,t2 : rex;

BEGIN
        blank_line:=ord(obuf[1])-ord('0');  { convert char to integer }
        before_line:=ord(obuf[3])-ord('0');
        if obuf[5]='1' then
                title_flag:=true;
        if obuf[5]='0' then
                title_flag:=false;
        if obuf[7]='1' then
                work_flag:=true;
        if obuf[7]='0' then
                work_flag:=false;
        if obuf[9]='1' then
                service_type:=1;
        if obuf[9]='2' then
                service_type:=2;
        if obuf[9]='3' then
                service_type:=3;
        if obuf[11]='1' then
                one_flag:=true;
        if obuf[11]='0' then
                one_flag:=false;
        dial_b_str:='';
        t1:='                    ';
        count:=13;
        scount:=1;
        while (obuf[count]<>chr(13)) do
          begin
                t1[scount]:=obuf[count];
                count:=count+1;
                scount:=scount+1;
          end;
        dial_b_str:=t1;
        t2:='                    ';
        mci_str:='';
        count:=count+1;
        scount:=1;
        while (obuf[count]<>chr(13)) do
          begin
                t2[scount]:=obuf[count];
                count:=count+1;
                scount:=scount+1;
          end;
        mci_str:=t2;

END;

BEGIN
    if init_gem >=0 then  { initialize gem }
       BEGIN
          init_mouse;  { initialize mouse }
          save_flag:=false; { init save flag to off }
          res:=getrez;   { check resolution }
          if res=1 then
             res:=8;  { medium resolution }
          if res=2 then
             res:=16;  { high resolution }
          if res=0 then  { low resolution not supported }
           BEGIN
             dummy:=do_alert('[3][Does not Support Low Resolution][ OK ]',1);
             halt;
           END;
          menu_bar;  { main menu bar }
          select_off;    { turn off select items }
          name_st:='MAILCALL.DAT';  { initialize file names }
          convert(name_st,name);
          info_st:='MAILCALL.INF';
          convert(info_st,info_file);
          init_string;  { initialize memory }
          record_number:=0;  { initialize record_number }
          in_file  := gem_open( name, 0 ) ;  { load in default file if pres. }
          IF in_file >= 0 THEN
            BEGIN
             jes:=gem_read(in_file,max*154,buf ) ;  { load in data file }
             record_number:=int(long_round(jes/154));
            END;
          gem_close(in_file);
          blank_line:=3;   { these are set by the print option }
          before_line:=0;  { default settings }
          title_flag:=true;
          dial_b_str:='ATS7=11DT';
          mci_str:='';
          work_flag:=false;
          service_type:=1;
          one_flag:=true;
          out_file:=gem_open(info_file,0); { load in MAILCALL.INF if pres. }
          if out_file>=0 then begin
             jes:=gem2_read(out_file,50,obuf);
             put_back;  { put info into variables }
           end;
          gem_close(out_file);
          rsconf(9,-1,-1,-1,-1,-1);  { init rs-232 to 300 baud }
          event_loop;   { call main event loop }
        erase_menu(menu);   { done then erase menu }
        exit_gem;         { exit gem }
       END { main loop }
END.


