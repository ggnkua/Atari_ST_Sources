' MIDI Master Drummer by David Snow - 3/28/90 10:45 pm
' (c) 1990 Antic Publishing, Inc.
' LDW BASIC Compiler (c) 1987 Logical Design Works, Inc.

defwrd a-z
old=switch(0)
randomize(0)
mouse 256
on error goto error_trap

if systab(0)=4 then               'check screen resolution
     alert 3," |MIDI Master Drummer runs in|high and medium resolution.",1,"Abort",ok
     end
endif

xbios 2: physbase%=status
xbios 4: res=status

dim static pat_ary(38215)
dim static pat_params(99,4)
dim static asm(2000)
dim static pat_buffer(384)
dim static sector_buffer(256)
dim static ptch(16)
dim static chnl(16)
dim static stat(16)
dim static note_density(16)
dim static accent_prob(16)
dim static quant_prob(16)
dim static quant_val(16)
dim static dfree_buffer(8)
dim drum_name$(16)
dim phrases$(16)
dim song$(16)

greeting=1
gosub billboard

dim logbase(16000)
logbase%=varptr(logbase(0))
xbios 5,logbase%,physbase%,res

on systab(0) gosub hires_text,medres_text

for n=0 to 6: read note$(0,n): next
     data C#,D#,F,F#,G#,A#,C
note$(0,2)="F ": note$(0,6)="C "
for n=0 to 6: read note(0,n): next
     data 37,39,41,42,44,46,48
for n=0 to 6: read d$: note$(1,n)=d$+" ": next
     data C,D,E,F,G,A,B
for n=0 to 6: read note(1,n): next
     data 36,38,40,41,43,45,47
for n=0 to 3: read param_coord(n): next
     data 64,296,472,592

pat_ary%=varptr(pat_ary(0))
pat_params%=varptr(pat_params(0,0))
asm%=varptr(asm(0))
pat_buffer%=varptr(pat_buffer(0))
sector_buffer%=varptr(sector_buffer(0))
stat%=varptr(stat(0))
chnl%=varptr(chnl(0))
ptch%=varptr(ptch(0))
dfree_buffer%=varptr(dfree_buffer(0))
msflg=0
msflg%=varptr(msflg)
phr_prt=0
phr_prt%=varptr(phr_prt)
end_flg=0
end_flg%=varptr(end_flg)
key=0
key%=varptr(key)
mflg=0
mflg%=varptr(mflg)
mtcl=24

pulse_clocks=6                     'MIDI clocks per pulse (pulse=pulse mode)
quarter_pulses=4                   'pulses per quarter note (pulse=pulse mode)
btcl=24                            'MIDI clocks per quarter note
bpm=93                             'beats per minute

tmpo=264                           'interrupts per MIDI clock
tmpo%=varptr(tmpo)
t_arw=496
t_arw%=varptr(t_arw)
t_flg=0
t_flg%=varptr(t_flg)
old_t_pos(0)=496
old_t_pos(2)=496
old_t_pos(3)=496

bs_vl=72
bs_vl%=varptr(bs_vl)
phrase_vel=72
v_arow=145
v_arow%=varptr(v_arow)
v_flg=0
v_flg%=varptr(v_flg)
old_v_pos(2)=145
old_v_pos(3)=145
accent_char=57
accent_char%=varptr(accent_char)

file_size%(1)=800
file_size%(2)=76430
file_size%(3)=1970

trk_stat$(1)=chr$(8)                    '1=track enabled (record and play)
trk_stat$(2)="M"                        '2=track muted
trk_stat$(3)="S"                        '3=track selected

copy_source$(2)="phrase"
copy_source$(3)="part"

file_ext$(1)=".CFG"
file_ext$(2)=".PAT"
file_ext$(3)=".SNG"
file_ext$(4)=".MID"

edit_alert$(0)="Desk accessories activated| |   (Edit mode disabled)"
edit_alert$(1)="      Edit mode enabled| |(Desk accessories deactivated)"
midi_start$(0)="MIDI start disabled"
midi_start$(1)="MIDI start selected"
enable$(0)="  Enable edit      "
enable$(1)="  Enable desk      "
met_alert$(0)="Metronome disabled"
met_alert$(1)="Metronome enabled"

gemdos &h19                        'get current drive
drive_no=status

getdir$=space$(128)
getdir%=peek_l(varptr(getdir$))
gemdos &h47,getdir%,0              'get current subdirectory

n=0
while peek_b(getdir%+n)<>0
     n=n+1
wend

dir_name$=chr$(drive_no+65)+":"+left$(getdir$,n)+"\*____"
kill_name$=chr$(drive_no+65)+":"+left$(getdir$,n)+"\*.*"

menu 1,0,1," Desk "
menu 1,1,1,"  Master Drummer    "
menu 2,0,1," File "
menu 2,1,1,"  Load file   "
menu 2,2,1,"  Save file   "
menu 2,3,0,"--------------"
menu 2,4,1,"  Delete file "
menu 2,5,0,"--------------"
menu 2,6,1,"  Format disk "
menu 2,7,0,"--------------"
menu 2,8,1,"  Quit        "
menu 3,0,1," Mode "
menu 3,1,0,"  Pattern "
menu 3,2,1,"  Phrase  "
menu 3,3,1,"  Song    "
menu 4,0,1," Edit "
menu 4,1,1
menu 4,2,0,"-------------------"
menu 4,3,1,"  Backup pattern   "
menu 4,4,1,"  Retrieve pattern "
menu 4,5,0,"-------------------"
menu 4,6,1,"  Shift pulses     "
menu 4,7,0,"-------------------"
menu 4,8,1,"  Copy pattern     "
menu 4,9,1,"  Copy meter       "
menu 4,10,0,"-------------------" 
menu 4,11,1,"  Accent velocity  "
menu 4,12,0,"-------------------"
menu 4,13,1,"  Erase pattern(s) "
menu 5,0,1," Randomize "
menu 5,1,1,"  Generate Tracks "
menu 5,2,0,"------------------"
menu 5,3,1,"  Set Parameters  "
menu 6,0,1," Clock "
menu 6,1,2,"  Internal       "
menu 6,2,1,"  External       "
menu 6,3,0,"-----------------"
menu 6,4,1,"  MIDI start     "
menu 6,5,0,"-----------------"
menu 6,6,2,"  Pulse=pulse    "
menu 6,7,1,"  Beat=beat      "
menu 6,8,0,"-----------------"
menu 6,9,1,"  Resolution     "
menu 6,10,0,"-----------------"
menu 6,11,1,"  Auto-set tempo "
menu 6,12,0,"-----------------"
menu 6,13,1,"  Metronome      "
menu 6,14,1,"  Clocks/click   "
menu 7,0,1," Help "
menu 7,1,1,"  Key functions "

exit_file$="MSTRDRUM.BIN"
gosub open_file
if error_code<0 then
     xbios 5,physbase%,physbase%,res
     alert 3,"MSTRDRUM.BIN file missing!",1,"Abort",ok
     end
endif
bload exit_file$,asm%           'load machine code module
gem_array%=gb
call asm%(0,gem_array%)         'initialize gem/vdi array pointer tables
call asm%(8,pat_ary%)           'initialize patterns, phrases, and song parts
for n=1 to 16
     phrases$(n)=""
     song$(n)=""
next

exit_file$="DEFAULT.CFG"
gosub open_file
if error_code>=0 then
     gosub load_config
else
     gosub default_configuration
endif

exit_file$="DEFAULT.PAT"
gosub open_file
if error_code>=0 then
     gosub load_pats
else
     gosub default_patterns
endif

exit_file$="DEFAULT.SNG"
gosub open_file
if error_code>=0 then gosub load_phrase

gosub enable_edit

' * * * * * WINDOW 0 - PATTERNS * * * * *
titlew 0,config_name$
openw 0,0,0,634,400,1
mouse 256
active_w=0

print "Pattern:    ";chr$(2);"  ";chr$(1);"         Pulses/Beat:        Beats/Measure:      Measures:"
print "Instrument    Note Ch En";
gosub top_border

y=window(15)+2\systab(0)
for n=1 to 18
     linef 0,y,195,y
     y=y+window(15)
next

y=18*window(15)+3\systab(0)
linef 0,y,632,y

y=window(15)+2\systab(0)
z=18*window(15)+2\systab(0)
linef 107,y,107,z
linef 147,y,147,z
linef 171,y,171,z
linef 195,y,195,z

if systab(0)=1 then                     'hires pattern window:
     color ,1,,,                             'draw keyboard
     for n=10 to 234 step 56
          box fill n+6,318,n+10,335
          box fill n+14,318,n+18,335
          box fill n+30,318,n+34,335
          box fill n+38,318,n+42,335
          box fill n+46,318,n+50,335
     next
     for n=10 to 290 step 8
          box n,318,n+8,348
     next
     linef 14,348,14,352,301,352,301,322,298,322
     fill 15,349

     box 310,318,366,348                          'draw play button
     button 1,1,"PLAY",314,322,49,23
     linef 314,348,314,352,369,352,369,322,366,322
     fill 315,349

     box 378,318,622,348                          'draw tempo bar
     linef 382,348,382,352,625,352,625,322,622,322
     fill 383,349
     size=1: gosub vst_point
     strin$="TEMPO": c%=384: r%=362
     gosub v_gtext
     gosub hires_text
     for n=387 to 611 step 8
          linef n,342,n,345
     next
     color ,,,4,2: fill 1,326
elseif systab(0)=2 then                 'medres pattern window
     color ,1,,,                             'draw keyboard
     for n=10 to 234 step 56
          box fill n+6,163,n+10,168
          box fill n+14,163,n+18,168
          box fill n+30,163,n+34,168
          box fill n+38,163,n+42,168
          box fill n+46,163,n+50,168
     next
     for n=10 to 290 step 8
          box n,163,n+8,174
     next
                                        'draw play button
     button 1,1,"PLAY",314,165,49,8

                                        'draw tmpo bar
     box 378,163,622,174
     for n=387 to 611 step 8
          linef n,173,n,173
     next

     color ,,,4,2
     fill 1,165
     fill 300,165
     fill 376,165
     fill 623,165
endif

gosub update_t_arrow
gosub init_config
gosub pat_redraw
gosub backup_pattern
gosub grid_redraw
config_flg=0
pat_flg=0
reset

' * * * * * WINDOW 2 - PHRASES * * * * *
openw 2,0,0,634,400,0
active_w=2
gosub button_bar
reset
for n=1 to 16
     y=(n-1)*20\systab(0)+7\systab(0)
     button n,1," PHRASE "+right$(str$(n),2),16,y,112,window(15)-1,1
next

' * * * * * WINDOW 3 - SONG * * *  *
openw 3,0,0,634,400,0
active_w=3
gosub button_bar
reset
for n=1 to 16
     y=(n-1)*20\systab(0)+7\systab(0)
     button n,1," PART "+right$(str$(n),2),16,y,112,window(15)-1,1
next

closew 1
xbios 5,physbase%,physbase%,res
erase logbase

activew 0
redraw 0
active_w=0
mouse 257

on dialog gosub dialog_trap
on menu gosub menu_trap
dialog on: menu on

while 1
     if active_w=0 then
          if config_flg then
               config_flg=0
               gosub init_config
               reset
          elseif pat_flg>0 then
               if pat_flg=1 then gosub backup_pattern  'if pat_flg=2 then redraw without backup
               pat_flg=0
               gosub pat_redraw
               gosub grid_redraw
               reset
          endif
     elseif active_w=2 or active_w=3 then
          if phrase_flg then
               phrase_flg=0
               gosub phrase_redraw
          endif
     endif

     '$event off
     bios 11,-1
     while status_w and 4
          bios 1,2
          if status_w<>0 then
               bios 2,2
               key=status\65536
               if active_w<>1 then gosub common_menu
               if active_w=0 then
                    if key=&h48 and patnbr<98 then     'up arrow
                         patnbr=patnbr+1
                         gosub get_pattern
                    elseif key=&h50 and patnbr>0 then  'down arrow
                         patnbr=patnbr-1
                         gosub get_pattern
                    elseif key=&h52 then               'insert=backup pattern
                         gosub do_backup
                    elseif key=&h77 then               'clr/home=retrieve pattern
                         gosub retrieve_pattern
                    elseif key=&h0e then               'backspace=shift pulses
                         gosub shift
                    elseif key=&h73 then               '<- = copy pattern
                         gosub copy
                    elseif key=&h74 then               '-> = copy meter
                         gosub meter
                    elseif key=&h22 then               'g=generate track
                         gosub generate
                    elseif key=&h19 then               'p=randomization parameters
                         gosub set_params
                    elseif key>&h3a and key<&h3f then  'F1-F4=pattern parameters
                         gosub end_edit
                         act_field=key-26
                         edit field act_field
                    elseif key=&h3f then               'F5=configuration name
                         gosub end_edit
                         gosub title_change
                    elseif key>&h01 and key<=&h0a then '1-9=change accent velocity
                         accent_char=key+&h2f
                         call asm%(9,accent_char)
                    endif
               elseif active_w=2 or active_w=3 then
                    if key=&h48 then
                         act_field=act_field-1
                         if act_field<1 then act_field=16
                         edit field act_field
                    elseif key=&h50 then
                         act_field=act_field+1
                         if act_field>16 then act_field=1
                         edit field act_field
                    endif
               endif
               key=0
          endif
          bios 11,-1
     wend

     if tap_flag then
          tap_flag=0
          gosub tap_tempo
     endif

     '$event on
     ask mouse x,y,b
     if systab(0)=1 and y<-19 then
          if x>14 and x<401 then act_menu=1
     elseif systab(0)=2 and y<-11 then
          if x>14 and x<401 then act_menu=1
     endif
     if act_menu=0 then
          if b<>0 and edit_enable=1 then gosub mouse_trap
     else
          if b and 1 then
               act_menu=0
               while b and 1
                    ask mouse x,y,b
               wend
          endif
     endif
wend

     common_menu:
          if active_w<>0 and key=&h6d then   '1=pattern mode
               gosub make_pats
          elseif active_w<>2 and key=&h6e then
               gosub phrases                 '2=phrase mode
          elseif active_w<>3 and key=&h6f then
               gosub song                    '3=song mode
          elseif key=&h1f then               's=save file
               file_action=2
               gosub ask_file
          elseif key=&h26 then               'l=load file
               file_action=1
               gosub ask_file
          elseif key=&h10 then               'q=quit
               gosub quit_program
          elseif key=&h61 then               'undo=enable edit toggle
               gosub enable_edit
               alert 1,edit_alert$(edit_enable),1,"OK",ok
          elseif key=&h53 then               'delete=erase pattern
               gosub cclear
          elseif key=&h63 then               'numeric ( =internal clock
               gosub master
               alert 1,"Internal clock selected",1,"OK",ok
          elseif key=&h64 then               'numeric ) =external clock
               gosub slave
               alert 1,"External clock selected",1,"OK",ok
          elseif key=&h65 then               'numeric / =MIDI start toggle
               gosub set_start
               alert 1,midi_start$(midi_start),1,"OK",ok
          elseif key=&h66 then               'numeric * =pulse/pulse
               alert 1,"Pulse=pulse",1,"OK",ok
               gosub pulse_pulse
          elseif key=&h4a then               'numeric - =beat/beat
               alert 1,"Beat=beat",1,"OK",ok
               gosub beat_beat
          elseif key=&h4e then               'numeric + =resolution
               gosub clock_res
          elseif key=&h70 then               'numeric 0 =auto_set tempo
               gosub tap_tempo
          elseif key=&h1a then               '[=metronome toggle
               gosub met_select
               alert 1,met_alert$(mflg),1,"OK",ok
          elseif key=&h1b then               ']=set metronome resolution
               gosub met_res
          elseif key=&h62 then               'help=help
               gosub help_window
          endif
          return

init_config:
     mouse 256
     titlew 0,config_name$
     for act_field=1 to 16
          gosub get_name
     next

     gotoxy 14,p_index+2: print " ";
     gotoxy 14,2: print chr$(3);
     for p_index=0 to 15
          gosub get_ptch
     next
     p_index=0

     for act_field=17 to 32
          gosub get_channel
     next
     act_field=0

     if systab(0)=1 then
          r%=88
     elseif systab(0)=2 then
          r%=48
     endif
     c%=180
     for s_index=0 to 15
          gosub get_status: r%=r%+window(15)
     next
     mouse 257
     return

mouse_trap:
     '$event off
     if active_w=0 then
          call asm%(1,patnbr,plttl%,pat_ary%,stat%,chnl%,ptch%,clks,msflg%,phr_prt%,end_flg%,t_arw%,tmpo%,bs_vl%,t_flg%,v_arow%,v_flg%,r%,key%,btcl)
          mouse 256
          if systab(0)=1 then
               '* HIGH RESOLUTION - WINDOW 0
               if y<1 and y>-19 then
                    gosub title_change
               elseif y<19 and y>0 and x>91 and x<132 then
                                        'change pattern number with arows
                    if x<108 then
                         if patnbr>0 then patnbr=patnbr-1
                    elseif x>115 then
                         if patnbr<98 then patnbr=patnbr+1
                    endif
                    gosub get_pattern
               elseif y>36 and y<309 then
                    r%=17*((y-3)\17)+54      'y position for v_qtext
                    if x<105 then
                                        'copy track to track
                                                  'graf_dragbox
                         mouse 257
                         gem_intin(0)=106              'width of moveable rectangle
                         gem_intin(1)=16               'height of moveable rectangle
                         gem_intin(2)=2                'starting x location
                         gem_intin(3)=r%-13            'starting y location
                         gem_intin(4)=1                'x of bordering rectangle
                         gem_intin(5)=58               'y of bordering rectangle
                         gem_intin(6)=106              'width of bordering rectangle
                         gem_intin(7)=288              'height of bordering rectangle
                         gemsys(71)                    'Opcode p.372 (8-5)
                         source_index=(y-37)\17
                         dest_index=(gem_intout(2)-49)\17
                         if source_index<>(dest_index-1) then
                              source_ptr%=pat_ary%+768*patnbr+48*source_index
                              dest_ptr%=pat_ary%+768*patnbr+48*(dest_index-1)
                              color ,1,,8,2
                              drawmode 3
                              if dest_index<1 then
                                                  'erase track
                                   y=source_index*17+36
                                   box fill -1,y,107,y+17
                                   copy_alert$="Erase "+drum_name$(source_index+1)
                                   alert 3,copy_alert$,2,"Yes|Cancel",ok
                                   if ok=1 then
                                        for pulse%=0 to 47
                                             poke_b source_ptr%+pulse%,0
                                        next
                                        track_ptr%=source_ptr%
                                        drum=source_index
                                        drawmode 1
                                        gosub draw_track
                                   endif
                              else
                                                  'copy track
                                   y=(dest_index-1)*17+36
                                   box fill -1,y,107,y+17
                                   copy_alert$="Copy "+drum_name$(source_index+1)
                                   alert 2,copy_alert$,1,"Yes|Cancel",ok
                                   if ok=1 then
                                        for pulse%=0 to 47
                                             poke_b dest_ptr%+pulse%,peek_b(source_ptr%+pulse%)
                                        next
                                        track_ptr%=dest_ptr%
                                        drum=dest_index-1
                                        drawmode 1
                                        gosub draw_track
                                   endif
                              endif
                              drawmode 3
                              color ,0,,,
                              box fill -1,y,107,y+17
                              drawmode 1
                              color ,1,,,
                         endif
                    elseif x>107 and x<145 then
                                        'select drum for ptch entry
                         gotoxy 14,p_index+2
                         print " ";
                         p_index=(y-37)\17
                         gotoxy 14,p_index+2
                         print chr$(3);
                    endif
               elseif y>317 and y<349 then
                    if x>9 and x<298 then
                         octave=(x-10)\56
                         if y<336 then
                                   'service black keys
                              bank=0
                              n_index=((x-16)\8) mod 7
                         elseif y>335 then
                                   'service white keys
                              bank=1
                              n_index=((x-10)\8) mod 7
                         endif
                         ptch(p_index)=note(bank,n_index)+12*octave
                         gotoxy 15,p_index+2
                         print note$(bank,n_index);right$(str$(octave+1),1);
                         out 3,144+chnl(p_index): out 3,ptch(p_index): out 3,96
                         mouse 257
                         while b<>0: ask mouse x,y,b: wend
                         out 3,144+chnl(p_index): out 3,ptch(p_index): out 3,0
                    endif
               endif
               reset
               mouse 257
          elseif systab(0)=2 then
               '* MEDIUM RESOLUTION - WINDOW 0
               if y<-1 and y>-11 then
                    gosub title_change
               elseif y<10 and y>0 and x>91 and x<132 then
                                        'change pattern number with arows
                    if x<108 then
                         if patnbr>0 then patnbr=patnbr-1
                    elseif x>115 then
                         if patnbr<98 then patnbr=patnbr+1
                    endif
                    gosub get_pattern
               elseif y>19 and y<163 then
                    r%=9*((y-2)\9)+29      'y position for v_qtext
                    if x<105 then
                                        'copy track to track
                                                  'graf_dragbox
                         mouse 257
                         gem_intin(0)=106              'width of moveable rectangle
                         gem_intin(1)=8                'height of moveable rectangle
                         gem_intin(2)=2                'starting x location
                         gem_intin(3)=r%-5             'starting y location
                         gem_intin(4)=1                'x of bordering rectangle
                         gem_intin(5)=33               'y of bordering rectangle
                         gem_intin(6)=106              'width of bordering rectangle
                         gem_intin(7)=153              'height of bordering rectangle
                         gemsys(71)                    'Opcode p.372 (8-5)
                         source_index=(y-20)\9
                         dest_index=(gem_intout(2)-26)\9
                         if source_index<>(dest_index-1) then
                              source_ptr%=pat_ary%+768*patnbr+48*source_index
                              dest_ptr%=pat_ary%+768*patnbr+48*(dest_index-1)
                              color ,1,,8,2
                              drawmode 3
                              if dest_index<1 then
                                                  'erase track
                                   y=source_index*9+19
                                   box fill -1,y,107,y+9
                                   copy_alert$="Erase "+drum_name$(source_index+1)
                                   alert 3,copy_alert$,2,"Yes|Cancel",ok
                                   if ok=1 then
                                        for pulse%=0 to 47
                                             poke_b source_ptr%+pulse%,0
                                        next
                                        track_ptr%=source_ptr%
                                        drum=source_index
                                        drawmode 1
                                        gosub draw_track
                                   endif
                              else
                                                  'copy track
                                   y=(dest_index-1)*9+19
                                   box fill -1,y,107,y+9
                                   copy_alert$="Copy "+drum_name$(source_index+1)
                                   alert 2,copy_alert$,1,"Yes|Cancel",ok
                                   if ok=1 then
                                        for pulse%=0 to 47
                                             poke_b dest_ptr%+pulse%,peek_b(source_ptr%+pulse%)
                                        next
                                        track_ptr%=dest_ptr%
                                        drum=dest_index-1
                                        drawmode 1
                                        gosub draw_track
                                   endif
                              endif
                              drawmode 3
                              color ,0,,,
                              box fill -1,y,107,y+9
                              drawmode 1
                              color ,1,,,
                         endif
                    elseif x>107 and x<145 then
                                        'select drum for ptch entry
                         gotoxy 14,p_index+2
                         print " ";
                         p_index=(y-20)\9
                         gotoxy 14,p_index+2
                         print chr$(3);
                    endif
               elseif y>163 and y<174 then
                    if x>9 and x<298 then
                         octave=(x-10)\56
                         if y<169 then
                                   'service black keys
                              bank=0
                              n_index=((x-16)\8) mod 7
                         elseif y>169 then
                                   'service white keys
                              bank=1
                              n_index=((x-10)\8) mod 7
                         endif
                         ptch(p_index)=note(bank,n_index)+12*octave
                         gotoxy 15,p_index+2
                         print note$(bank,n_index);right$(str$(octave+1),1);
                         out 3,144+chnl(p_index): out 3,ptch(p_index): out 3,96
                         mouse 257
                         while b<>0: ask mouse x,y,b: wend
                         out 3,144+chnl(p_index): out 3,ptch(p_index): out 3,0
                    endif
               endif
               reset
               mouse 257
          endif
     elseif active_w=2 or active_w=3 then
          call asm%(6,patnbr,plttl%,pat_ary%,stat%,chnl%,ptch%,clks,msflg%,phr_prt%,end_flg%,t_arw%,tmpo%,bs_vl%,t_flg%,v_arow%,v_flg%,r%,key%,btcl)
          if systab(0)=1 then
               '* HIGH RESOLUTION - WINDOWS 2 AND 3
               if x>13 and x<=127 and y>5 and y<=323 then
                                   'copy phrase-to-phrase or part-to-part
                    gem_intin(0)=113              'width of moveable rectangle
                    gem_intin(1)=18               'height of moveable rectangle
                    gem_intin(2)=15               'starting x location
                    gem_intin(3)=((y-6)\20)*20+26 'starting y location
                    gem_intin(4)=17               'x of bordering rectangle
                    gem_intin(5)=26               'y of bordering rectangle
                    gem_intin(6)=113              'width of bordering rectangle
                    gem_intin(7)=319              'height of bordering rectangle
                    gemsys(71)                    'Opcode p.372 (8-5)

                    source_field=(y-6)\20+1
                    dest_field=(gem_intout(2)-14)\20+1
                    if source_field<>dest_field then
                         color ,1,,8,2
                         drawmode 3
                         y=(dest_field-1)*20+6
                         box fill 15,y,128,y+17
                         copy_alert$="Copy "+copy_source$(active_w)+str$(source_field)
                         alert 2,copy_alert$,1,"Yes|Cancel",ok
                         if ok=1 then
                              if active_w=2 then
                                   phrases$(dest_field)=edit$(source_field)
                                   edit field close dest_field
                                   edit field dest_field,phrases$(dest_field),160,y+1,469,16,3
                              elseif active_w=3 then
                                   song$(dest_field)=edit$(source_field)
                                   ' CLOSE edit field close dest_field
                                   edit field dest_field,song$(dest_field),160,y+1,469,16,3
                              endif
                         endif
                         drawmode 3
                         color ,0,,,
                         box fill 15,y,128,y+17
                         drawmode 1
                         color ,1,,,
                    endif
               endif
          elseif systab(0)=2 then
               '* MEDIUM RESOLUTION - WINDOWS 2 AND 3
               if x>13 and x<=127 and y>1 and y<=162 then
                                   'copy phrase-to-phrase or part-to-part
                    gem_intin(0)=113              'width of moveable rectangle
                    gem_intin(1)=9                'height of moveable rectangle
                    gem_intin(2)=15               'starting x location
                    gem_intin(3)=((y-2)\10)*10+13 'starting y location
                    gem_intin(4)=17               'x of bordering rectangle
                    gem_intin(5)=14               'y of bordering rectangle
                    gem_intin(6)=113              'width of bordering rectangle
                    gem_intin(7)=159              'height of bordering rectangle
                    gemsys(71)                    'Opcode p.372 (8-5)

                    source_field=(y-2)\10+1
                    dest_field=(gem_intout(2)-8)\10+1
                    if source_field<>dest_field then
                         color ,1,,8,2
                         drawmode 3
                         y=(dest_field-1)*10+2
                         box fill 15,y,128,y+9
                         copy_alert$="Copy "+copy_source$(active_w)+str$(source_field)
                         alert 2,copy_alert$,1,"Yes|Cancel",ok
                         if ok=1 then
                              if active_w=2 then
                                   phrases$(dest_field)=edit$(source_field)
                                   edit field close dest_field
                                   edit field dest_field,phrases$(dest_field),160,y+1,469,8,3
                              elseif active_w=3 then
                                   song$(dest_field)=edit$(source_field)
                                   edit field close dest_field
                                   edit field dest_field,song$(dest_field),160,y+1,469,8,3
                              endif
                         endif
                         drawmode 3
                         color ,0,,,
                         box fill 15,y,128,y+9
                         drawmode 1
                         color ,1,,,
                    endif
               endif
          endif
     endif
     '$event on
     return

          tap_tempo:
               '$event off
               if slave then
                    alert 1,"You can't auto-set|tempo in slave mode.",1,"Cancel",ok
               else
                    mouse 256
                    gosub open_dialog
                    gosub box_it
                    gotoxy 6,1
                    print "Tap numeric 0 key twice";
                    gotoxy 4,8-systab(0)
                    print "(Hit any other key to abort)";
                    box 56,64\systab(0),224,94\systab(0)
                    gotoxy 8,4
                    print "Auto-set tempo: ";
                    if inp(2)<>48 then
                         mouse 257
                         closew 1
                         return
                    endif
                    print chr$(9)
                    gotoxy 23,4
                    mark_1%=timer
                    if inp(2)<>48 then
                         mouse 257
                         closew 1
                         return
                    endif
                    mark_2%=timer
                    beat_duration%=mark_2%-mark_1%
                    bpm=(1/(beat_duration%/200))*60
                    if bpm<1 then
                         bpm=1
                    elseif bpm>240 then
                         bpm=240
                    endif
                    print bpm
                    if active_w=0 then
                         gosub tempo_delay
                         closew 1
                         mouse 257
                         tmpo=int(((24400*24)/btcl)/bpm)
                         t_flg=1
                         gosub play_button
                    elseif active_w=2 then
                         gosub tempo_delay
                         closew 1
                         mouse 257
                         play_phrase$=edit$(act_field)
                         if upper$(left$(play_phrase$,1))="T" then
                              play_phrase$=play_phrase$+" "
                              e=1
                              while mid$(play_phrase$,e,1)<>" "
                                   e=e+1
                              wend
                              e=e+1
                              play_phrase$=mid$(play_phrase$,e,len(play_phrase$)-e)
                         endif
                         gosub get_tmpostring
                         play_phrase$="T"+right$(tmpo$,len(tmpo$)-1)+" "+play_phrase$
                         edit field close act_field
                         edit field act_field,play_phrase$,160,y,469,window(15)-1,3
                         edit field act_field

                    elseif active_w=3 then
                         gosub tempo_delay
                         closew 1
                         mouse 257
                         song$(act_field)=edit$(act_field)
                         if upper$(left$(song$(act_field),1))="T" then
                              song$(act_field)=song$(act_field)+" "
                              e=1
                              while mid$(song$(act_field),e,1)<>" "
                                   e=e+1
                              wend
                              e=e+1
                              song$(act_field)=mid$(song$(act_field),e,len(song$(act_field))-e)
                         endif
                         gosub get_tmpostring
                         song$(act_field)="T"+right$(tmpo$,len(tmpo$)-1)+" "+song$(act_field)
                         edit field close act_field
                         edit field act_field,song$(act_field),160,y,469,window(15)-1,3
                         edit field act_field
                    endif
               endif
               return
               '$event on

               get_tmpostring:
                    '$event off
                    tmpo$=str$(int(bpm))
                    y=(act_field-1)*20\systab(0)+7\systab(0)
                    return
                    '$event on

               tempo_delay:
                    '$event off
                    delay%=timer+100
                    while delay%>timer
                         if inp(-2)<>0 then trash=inp(2)
                    wend
                    return
                    '$event off

          title_change:
               gosub open_dialog
               gosub box_it
               active_w=1
               gotoxy 9,1
               print "CONFIGURATION NAME"
               edit field 1,config_name$,12,64\systab(0),258,20\systab(0),1
               edit field 1
               button 1,1,"Ok",54,122\systab(0),72,20\systab(0),3
               button 2,1,"Cancel",162,122\systab(0),72,20\systab(0),1
               on dialog gosub new_title
               menu off
               return

          new_title:
               on dialog(0) gosub title_btn,dummy,title_ret
               return

               title_btn:
                    button dialog(1),2
                    if dialog(1)=1 then config_name$=edit$(1)
                    gosub end_title
                    return

               title_ret:
                    button 1,2
                    config_name$=edit$(1)
                    gosub end_title
                    return

                    end_title:
                         reset clear 1
                         closew 1
                         active_w=0
                         titlew 0,config_name$
                         menu on
                         on dialog gosub dialog_trap
                         return

          get_pattern:
               edit field close 33
               edit field 33,right$(str$(pat_params(patnbr,0)),2),64,4-systab(0),16,window(15)-1,3
               gosub pat_redraw
               gosub backup_pattern
               gosub grid_redraw
               return

          update_t_arrow:
               if systab(0)=1 then
                    r%=377
               elseif systab(0)=2 then
                    r%=192
               endif
               c%=old_t_pos(active_w): strin$=" "
               gosub v_gtext
               c%=t_arw: strin$=chr$(2)
               gosub v_gtext
               old_t_pos(active_w)=t_arw
               return

          update_v_arrow:
               if systab(0)=1 then
                    r%=377
               elseif systab(0)=2 then
                    r%=192
               endif
               c%=old_v_pos(active_w): strin$=" "
               gosub v_gtext
               c%=v_arow: strin$=chr$(2)
               gosub v_gtext
               old_v_pos(active_w)=v_arow
               return

          v_gtext:
               contrl(0)=8              'Opcode TEXT function
               contrl(1)=1              'Number of ptsin points
               b_wrk001%=len(strin$)
               contrl(3)=b_wrk001%      'Length of input string
               for b_wrk002%=0 to b_wrk001%-1     'Conversion of input string
                    intin(b_wrk002%)=asc(mid$(strin$,b_wrk002%+1,1))
               next
               ptsin(0)=c%              'Coordinates
               ptsin(1)=r%              'of text display
               vdisys
               return

dialog_trap:
     on dialog(0) gosub play_button,act_edit,ret_enter,redraw_w,dummy,dummy
     return

     clear_queue:
          for x=1 to 4: z=dialog(0): next
          return

     play_button:
          '$event off
          button 1,2
          fcode=2
          gosub end_edit

     restart_pat:
          end_flg=0
          while end_flg=0
               gosub play_pat
          wend
          if end_flg=2 then restart_pat
          call asm%(3)

          call asm%(10,accent_char%)    'update accent symbol
          if accent_char=62 then accent_char=57
          menu 6,13,mflg+1              'update metronome status

          button 1,1
          gosub mouse_loop
          reset
          gosub clear_queue
          return
          '$event on

          play_pat:
               '$event off
               if unit=0 then
                    clks=pulse_clocks
               else
                    clks=(btcl\pat_params(patnbr,1))
               endif
               plttl%=pat_params(patnbr,1)*pat_params(patnbr,2)*pat_params(patnbr,3)-1
call asm%(fcode,patnbr,plttl%,pat_ary%,stat%,chnl%,ptch%,clks,msflg%,phr_prt%,end_flg%,t_arw%,tmpo%,bs_vl%,t_flg%,v_arow%,v_flg%,r%,key%,btcl,mtcl,mflg%)

               return
               '$event on

     act_edit:
          gosub end_edit
          act_field=dialog(2)
          edit field act_field
          return

     ret_enter:
          if act_field=0 then
               gosub play_button
          else
               gosub end_edit
          endif
          return

     end_edit:
          if act_field>0 then
               if act_field<17 then
                                   'enter drum name
                    drum_name$(act_field)=edit$(act_field)+space$(13-len(edit$(act_field)))
                    gosub no_cursor
                    gosub get_name
               elseif act_field<33 then
                                   'enter drum channel
                    channel=val(edit$(act_field))
                    if channel>0 and channel<17 then chnl((act_field-17))=channel-1
                    gosub no_cursor
                    gosub get_channel
               elseif act_field<37 then
                                   'update pattern parameters
                    param_index=act_field-33
                    param_val=val(edit$(act_field))
                    if param_val<>pat_params(patnbr,param_index) then
                         on param_index+1 gosub chk_number,chk_pulses,chk_beats,chk_meas
                         if pat_params(patnbr,1)*pat_params(patnbr,2)*pat_params(patnbr,3)>48 then
                              gosub check_p_total
                         endif
                         if param_index=0 then
                              gosub pat_redraw
                              gosub backup_pattern
                         else
                              gosub fix_field
                         endif
                         gosub grid_redraw
                    else
                         gosub fix_field
                    endif
               endif
               act_field=0
               reset
          endif
          return

     no_cursor:
          edit field 36
          edit field close 36
          edit field 36,right$(str$(pat_params(patnbr,3)),2),param_coord(3),4-systab(0),16,window(15)-1,3
          gosub top_border
          return

     fix_field:
          edit field close act_field
          edit field act_field,right$(str$(pat_params(patnbr,param_index)),2),param_coord(param_index),4-systab(0),16,window(15)-1,3
          gosub top_border
          return

          chk_number:
               if param_val>0 and param_val<100 then patnbr=param_val-1
               return

          chk_pulses:
               if param_val>0 and param_val<25 then pat_params(patnbr,1)=param_val
               return

          chk_beats:
               if param_val>0 and param_val<49 then pat_params(patnbr,2)=param_val
               return

          chk_meas:
               if param_val>0 and param_val<49 then pat_params(patnbr,3)=param_val
               return

          check_p_total:
               while pat_params(patnbr,1)*pat_params(patnbr,2)*pat_params(patnbr,3)>48
                    if pat_params(patnbr,3)>1 then
                         pat_params(patnbr,3)=pat_params(patnbr,3)-1
                    else
                         pat_params(patnbr,2)=pat_params(patnbr,2)-1
                    endif
               wend
               edit field close 35
               edit field 35,right$(str$(pat_params(patnbr,2)),2),param_coord(2),4-systab(0),16,window(15)-1,3
               edit field close 36
               edit field 36,right$(str$(pat_params(patnbr,3)),2),param_coord(3),4-systab(0),16,window(15)-1,3
               return

          get_name:
               if systab(0)=1 then
                    z=37
               elseif systab(0)=2 then
                    z=20
               endif
               y=(act_field-1)*window(15)+z
               edit field act_field,drum_name$(act_field),1,y,104,window(15)-1,3
               return

          get_ptch:
               octave=(ptch(p_index)-36)\12
               note_val=ptch(p_index)-(octave*12)
               for bank=0 to 1
                    for n_index=0 to 6
                         if note_val=note(bank,n_index) then
                              gotoxy 15,p_index+2
                              print note$(bank,n_index);right$(str$(octave+1),1);
                              return
                         endif
                    next
               next
               return

          get_channel:
               if systab(0)=1 then
                    z=37
               elseif systab(0)=2 then
                    z=20
               endif
               y=(act_field-17)*window(15)+z
               chan$=right$(str$(chnl((act_field-17))+1),2)
               edit field act_field,chan$,152,y,16,window(15)-1,3
               return

          get_status:
               strin$=trk_stat$(stat(s_index))
               gosub v_gtext
               return

     redraw_w:
          if supress_redraw=1 then
               supress_redraw=0
          else
               redraw dialog(4)
               if active_w=2 or active_w=3 then
                    gosub update_t_arrow
                    gosub update_v_arrow
               endif
          endif
          return

     dummy:
          return

top_border:
     linef 0,window(15)+2\systab(0),632,window(15)+2\systab(0)
     linef 0,window(15)+3\systab(0),632,window(15)+3\systab(0)
     linef 0,2*window(15)+1,632,2*window(15)+1
     return

pat_redraw:
     '$event off
     mouse 256
     gosub clear_grid
                                        'update pat_params
     for update=0 to 3
          edit field close update+33
          edit field update+33,right$(str$(pat_params(patnbr,update)),2),param_coord(update),4-systab(0),16,window(15)-1,3
     next
     gosub top_border     
                                        'place notes on grid (even those outside of measure)
     if systab(0)=1 then
          y=88
     elseif systab(0)=2 then
          y=48
     endif
     for drum=0 to 15
          pat_ptr%=pat_ary%+768*patnbr+48*drum
          for pulse%=0 to 47
               velocity=peek_b(pat_ptr%+pulse%)
               if velocity<>0 then
                    if velocity=1 then
                         strin$=chr$(11)
                    elseif velocity>1 and velocity<28 then
                         strin$=chr$((velocity-1)\3+48)
                    elseif velocity=28 then
                         strin$=">"
                    endif
                    c%=(pulse%*9)+198
                    r%=(drum*window(15))+y
                    gosub v_gtext
               endif
          next
     next
     erase_flg=1
     mouse 257
     return
     '$event on

     backup_pattern:
          '$event off
          for update=0 to 3
               backup_params(update)=pat_params(patnbr,update)
          next

          pat_ptr%=pat_ary%+768*patnbr
          for index%=0 to 767
               poke_b pat_buffer%+index%,peek_b(pat_ptr%+index%)
          next
          return
          '$event on

     retrieve_pattern:
          '$event off
          for update=0 to 3
               pat_params(patnbr,update)=backup_params(update)
          next

          pat_ptr%=pat_ary%+768*patnbr
          for index%=0 to 767
               poke_b pat_ptr%+index%,peek_b(pat_buffer%+index%)
          next
          gosub pat_redraw
          gosub grid_redraw
          reset
          return
          '$event on

grid_redraw:
     '$event off
     mouse 256
     if erase_flg=0 then
          color ,0,0,,
          if systab(0)=1 then
               y=21: z=34
          elseif systab(0)=2 then
               y=11: z=18
          endif
          box fill 196,y,628,z

          if systab(0)=1 then      'erase pulse/beat/measure lines
               y=36: z=308
          elseif systab(0)=2 then
               y=19: z=162
          endif
          for n=205 to 628 step 9
               linef n,y,n,z
          next

          for n=y to z step window(15)
               linef 197,n,628,n   'erase horizontal lines
          next
          color ,1,1,,
     endif

     if systab(0)=1 then
          y=36: z=308
     elseif systab(0)=2 then
          y=19: z=162
     endif
                                             'resize and redraw
     r_bound=196+9*pat_params(patnbr,1)*pat_params(patnbr,2)*pat_params(patnbr,3)
     if r_bound=196 then
          erase_flg=1
          mouse 257
          return
     endif

     erase_flg=0
                                        'pulses
     if pat_params(patnbr,1)>1 then
          linepat 3
          for n=205 to r_bound step 9
               linef n,y,n,z
          next
     endif
                                        'beats
     if pat_params(patnbr,2)>1 then
          linepat 7,21845
          size=1: gosub vst_point
          m=1
          for n=196 to r_bound step 9*pat_params(patnbr,1)
               if (pat_params(patnbr,1)>2 or pat_params(patnbr,2)>2) and m>1 and n<r_bound then
                    strin$=str$(m)
                    c%=n-2
                    if systab(0)=1 then
                         r%=71
                    elseif systab(0)=2 then
                         r%=39
                    endif
                    gosub v_gtext
               endif
               linef n,y,n,z
               m=(m mod pat_params(patnbr,2))+1
          next
     endif
                                        'measures
     linepat 1: drawmode 2
     size=9: gosub vst_point
     m=1
     for n=196 to r_bound step 9*pat_params(patnbr,1)*pat_params(patnbr,2)
          if n<r_bound then
               strin$=str$(m)
               c%=n-6
               if systab(0)=1 then
                    r%=71
               elseif systab(0)=2 then
                    r%=39
               endif
               gosub v_gtext
          endif
          linef n,y,n,z
          m=(m+1) mod 10
     next
     on systab(0) gosub hires_text,medres_text
     drawmode 1
                                        'horizontal lines
     if systab(0)=2 then gosub top_border

     for n=y to z step window(15)
          linef 196,n,r_bound,n
     next
     mouse 257
     return
     '$event on

     hires_text:
          size=10
          gosub vst_point
          return

     medres_text:
          size=9
          gosub vst_point
          return

     vst_point:
          contrl(0)=107
          contrl(1)=0
          contrl(3)=1
          intin(0)=size
          vdisys
          return

     vst_effects:
          contrl(0)=106
          contrl(1)=0
          contrl(3)=1
          intin(0)=effect
          vdisys
          return

     clear_grid:                             'clear grid/notes
          color ,0,0,,
          if systab(0)=1 then
               y=21: z=34
          elseif systab(0)=2 then
               y=11: z=18
          endif
          box fill 197,y,628,z

          if systab(0)=1 then
               y=36: z=308
          elseif systab(0)=2 then
               y=20: z=162
          endif
          box fill 197,y,628,z
          color ,1,1,,
          return

     phrase_redraw:
          mouse 256
          for n=1 to 16
               edit field close n
               y=(n-1)*20\systab(0)+7\systab(0)
               if active_w=2 then
                    edit field n,phrases$(n),160,y,469,window(15)-1,3
               elseif active_w=3 then
                    edit field n,song$(n),160,y,469,window(15)-1,3
               endif
          next
          edit field 1
          act_field=1
          mouse 257
          return

menu_trap:
     if active_w=0 then gosub end_edit
     on menu(0) gosub desk,do_file,mode,do_edit,rrandom,clock,help
     return

     desk:
          if menu(1)=1 then
               save_w=active_w
               active_w=1
               gosub billboard
               button 1,1,"Ok",120,152\systab(0),48,20\systab(0),3
               menu off
               on dialog gosub billboard_dialog
          endif
          return

               billboard_dialog:
                    on dialog(0) gosub end_billboard,dummy,end_billboard
                    return

                    end_billboard:
                         button 1,2
                         closew 1
                         active_w=save_w
                         menu on
                         gosub select_trap
                         return

     billboard:
          openw 1,176,108\systab(0),288,194\systab(0),0
          gosub box_it

          effect=1: gosub vst_effects
          gotoxy 6,2
          print "MIDI Master Drummer 1.0"

          effect=0: gosub vst_effects
          gotoxy 11,4
          print "by David Snow"
          gotoxy 3,6
          print "½ 1990 Antic Publishing, Inc."

          effect=0: gosub vst_effects
          if greeting=1 then
               greeting=0
               effect=4: gosub vst_effects
               gotoxy 3,10-systab(0)
               print "program set-up in progress..."
               effect=0: gosub vst_effects
          endif
          return

     do_file:
          file_action=menu(1)
          on file_action gosub ask_file,ask_file,dummy,kill_file,dummy,format,dummy,quit_program
          return

          ask_file:
               gosub open_dialog
               save_w=active_w
               active_w=1
               gotoxy 13,0
               if file_action=1 then
                    print "LOAD FILE:"
               else
                    print "SAVE FILE:"
               endif
               if save_w=0 then
                    pat_file_btn=3
                    songfile_btn=1
               elseif save_w=2 or save_w=3 then
                    pat_file_btn=1
                    songfile_btn=3
               endif
               button 1,1,"CONFIGURATION",84,24\systab(0),120,16\systab(0),1
               button 2,1,"PATTERNS",84,51\systab(0),120,16\systab(0),pat_file_btn
               button 3,1,"PHRASES/SONG",84,78\systab(0),120,16\systab(0),songfile_btn
               button 4,file_action-1,"MIDI FILE",84,105\systab(0),120,16\systab(0),1
               button 5,1,"CANCEL",84,132\systab(0),120,16\systab(0),1
               menu off
               on dialog gosub pick_file
               return

               pick_file:
                    on dialog(0) gosub file_btn,dummy,default_fbtn,dummy,dummy
                    return

                    file_btn:
                         file_type=dialog(1)
                         button dialog(1),2
                         gosub file_business
                         return

                    default_fbtn:
                         if save_w=0 then
                              file_type=2
                         elseif save_w=2 or save_w=3 then
                              file_type=3
                         endif
                         button file_type,2
                         gosub file_business
                         return

                    file_business:
                         if file_type<5 then
                              dir_name$=left$(dir_name$,len(dir_name$)-4)+file_ext$(file_type)
                              sel_file$=""
                         file_retry:
                              ask file dir_name$,sel_file$,exit_file$,ok
                              if ok=1 then
                                   if sel_file$="" then file_retry
                                   n=1
                                   while n<len(sel_file$) and mid$(sel_file$,n,1)<>"."
                                        n=n+1
                                   wend
                                   ext_len=len(sel_file$)+1-n
                                   if ext_len=1 then
                                        exit_file$=exit_file$+file_ext$(file_type)
                                   else
                                        exit_file$=left$(exit_file$,len(exit_file$)-ext_len)+file_ext$(file_type)
                                   endif
                                   if file_action=1 then
                                        gosub open_file     'does file exist?
                                        if error_code<0 then
                                             goto file_retry
                                        else
                                             on file_type gosub load_config,load_pats,load_phrase
                                        endif
                                   else
                                        check_disk:
                                        bios 4,2,sector_buffer%,1,1,asc(left$(dir_name$,1))-65
                                        if status_w<>0 then
                                             alert 3,"Disk error.",1," OK ",exit_val
                                        else
                                             bios 4,3,sector_buffer%,1,1,asc(left$(dir_name$,1))-65
                                             error_code=status_w
                                             if error_code=0 then
                                                  mouse 256
                                                  closew 1
                                                  gosub open_dialog
                                                  gosub box_it
                                                  gemdos &h36,dfree_buffer%,asc(left$(dir_name$,1))-64
                                                  dfree_space%=(peek_l(dfree_buffer%))*(peek_l(dfree_buffer%+8))*(peek_l(dfree_buffer%+12))
                                                  if file_type<4 then
                                                       if dfree_space%>file_size%(file_type) then
                                                            gosub parse_filename
                                                            on file_type gosub save_config,save_pats,save_phrase
                                                       else
                                                            alert 3,"Disk full.",1," Cancel ",exit_val
                                                       endif
                                                  else
                                                       gotoxy 2,3
                                                       print "Converting song to MIDI file..."
                                                       gotoxy 2,4
                                                       print "(press ESC to abort)"
                                                       gosub save_smf
                                                  endif
                                                  mouse 257
                                             elseif error_code<>-13 then
                                                  alert 3,"Disk error.",1," OK ",exit_val
                                             endif
                                        endif
                                   endif
                              endif
                         endif
                         closew 1
                         active_w=save_w
                         redraw active_w
                         if active_w<>0 then
                              gosub update_t_arrow
                              gosub update_v_arrow
                         endif
                         gosub clear_queue
                         gosub select_trap
                         menu on
                         return

                    parse_filename:
                         n=len(exit_file$)
                         while mid$(exit_file$,n,1)<>"\"
                              n=n-1
                         wend
                         n=len(exit_file$)-n
                         clearw 1
                         gosub box_it
                         gotoxy (29-n)\2,4
                         print "Saving ";right$(exit_file$,n)
                         return

                    select_trap:
                         if active_w=0 then
                              on dialog gosub dialog_trap
                         elseif active_w=2 then
                              on dialog gosub phrase_dialog
                         elseif active_w=3 then
                              on dialog gosub song_dialog
                         endif
                         return

               load_config:
                    config_flg=1
                    open "I",#1,exit_file$
                    input#1,config_name$
                    for n=0 to 15
                         input#1,drum_name$(n+1),ptch(n),chnl(n),stat(n),note_density(n),accent_prob(n),quant_prob(n),quant_val(n)
                    next
                    close
                    return

                load_pats:
                    pat_flg=1
                    bload exit_file$,pat_ary%
                    index%=0
                    for p=0 to 98
                         for n=0 to 3
                              pat_params(p,n)=peek_b(pat_ary%+76032+index%)
                              index%=index%+1
                         next
                    next
                    unit=peek_b(pat_ary%+76032+index%)
                    menu 6,6,2-unit
                    menu 6,7,1+unit
                    return

                load_phrase:
                    if save_w<>0 then phrase_flg=1
                    open "I",#1,exit_file$
                    for n=1 to 16
                         input#1,phrases$(n),song$(n)
                    next
                    close
                    return

               save_config:
                    open "O",#1,exit_file$
                    write# 1,config_name$
                    for n=0 to 15
                         write# 1,drum_name$(n+1),ptch(n),chnl(n),stat(n),note_density(n),accent_prob(n),quant_prob(n),quant_val(n)
                    next
                    close
                    return

               save_pats:
                    index%=0
                    for p=0 to 98
                         for n=0 to 3
                              poke_b pat_ary%+76032+index%,pat_params(p,n)
                              index%=index%+1
                         next
                    next
                    poke_b pat_ary%+76032+index%,unit
                    bsave exit_file$,pat_ary%,76430
                    return

               save_phrase:
                    open "O",#1,exit_file$
                    for n=1 to 16
                         write# 1,phrases$(n),song$(n)
                    next
                    close
                    return

               save_smf:
'CREATE AND SAVE STANDARD MIDI FILE
     '$event off
     save_number=patnbr
     max_size%=fre(0)-&h400
     dim smf_buffer(max_size%\2)
     smf_buffer%=varptr(smf_buffer(0))
     numerator=0
     click_clocks=0

' SET UP SMF HEADER CHUNK
     poke_b smf_buffer%,asc("M")
     poke_b smf_buffer%+1,asc("T")
     poke_b smf_buffer%+2,asc("h")
     poke_b smf_buffer%+3,asc("d")

     poke_l smf_buffer%+4,6                  ' length of header data
                                             ' header data:
     poke_w smf_buffer%+8,0                  '    SMF format 0
     poke_w smf_buffer%+10,1                 '    1 track
     poke_w smf_buffer%+12,btcl              '    clocks/quarter note

' SET UP TRACK CHUNK
     poke_b smf_buffer%+14,asc("M")
     poke_b smf_buffer%+15,asc("T")
     poke_b smf_buffer%+16,asc("r")
     poke_b smf_buffer%+17,asc("k")

     poke_l smf_buffer%+18,0                 ' dummy length of track data

     delta_time%=0                           ' reset delta time counter
     smf_index%=22                           ' index to first track event
' START SONG LOOP
     for part=1 to 16
          if song$(part)<>"" then
               part$=song$(part)+" "
               for s=1 to len(part$)
                    f=s
                    while mid$(part$,f,1)<>" "
                         f=f+1
                    wend
                    if mid$(part$,s,1)="t" or mid$(part$,s,1)="T" then
                         bpm=val(mid$(part$,s+1,f-s))
                         if bpm>0 and bpm<241 then
                              gosub set_smf_tmpo
                         endif
                         s=f
                    elseif mid$(part$,s,1)="v" or mid$(part$,s,1)="V" then
                         new_vel=val(mid$(part$,s+1,f-s))
                         if new_vel>0 and new_vel<100 then
                              bs_vl=new_vel
                         endif
                         s=f
                    elseif upper$(mid$(part$,s,1))="R" and val(mid$(part$,s+1,f-s))>1 then
                         if part_repeat=0  then
                              part_repeat=val(mid$(part$,s+1,f-s))
                         endif
                         if part_repeat=1 then
                              part_repeat=0
                              s=f
                         else
                              part_repeat=part_repeat-1
                              s=len(part$)
                              part=part-1
                         endif
                    else
                         play_phrase$=phrases$(val(mid$(part$,s,f-s)))+" "
                         s=f
' START PHRASE LOOP
                         if play_phrase$<>"" then
                              for n=1 to len(play_phrase$)
                                   e=n
                                   while mid$(play_phrase$,e,1)<>" "
                                        e=e+1
                                   wend
                                   if mid$(play_phrase$,n,1)="t" or mid$(play_phrase$,n,1)="T" then
                                        bpm=val(mid$(play_phrase$,n+1,e-n))
                                        if bpm>0 and bpm<241 then
                                             gosub set_smf_tmpo
                                        endif
                                        n=e
                                   elseif mid$(play_phrase$,n,1)="v" or mid$(play_phrase$,n,1)="V" then
                                        new_vel=val(mid$(play_phrase$,n+1,e-n))
                                        if new_vel>0 and new_vel<100 then
                                             bs_vl=new_vel
                                        endif
                                        n=e
                                   elseif upper$(mid$(play_phrase$,n,1))="R" and val(mid$(play_phrase$,n+1,e-n))>1 then
                                        if phrase_repeat=0 then
                                             phrase_repeat=val(mid$(play_phrase$,n+1,e-n))
                                        endif
                                        if phrase_repeat=1 then
                                             phrase_repeat=0
                                             n=e
                                        else
                                             phrase_repeat=phrase_repeat-1
                                             n=0
                                        endif
                                   else
                                        patnbr=val(mid$(play_phrase$,n,e-n))-1
                                        n=e
' START PATTERN LOOP
                                        if inkey$=chr$(27) then
                                             alert 2,"Abort MIDI file conversion?",2," Yes | No ",exit_val
                                             if exit_val=1 then
                                                  erase smf_buffer
                                                  patnbr=save_number
                                                  return
                                             endif
                                        endif
                                        if smf_index%>=max_size% then
                                             alert 3,"Not enough memory for|MIDI file conversion.",1," Cancel ",exit_val
                                             erase smf_buffer
                                             patnbr=save_number
                                             return
                                        endif
                                        if patnbr>-1 and patnbr<99 then
                                             if unit=0 then
                                                  clks=6
                                             else
                                                  clks=(24\pat_params(patnbr,1))
                                             endif

                                             if pat_params(patnbr,2)<>numerator or clks*pat_params(patnbr,1)<>click_clocks then
                                                  numerator=pat_params(patnbr,2)
                                                  click_clocks=clks*pat_params(patnbr,1)
                                                  poke_b smf_buffer%+smf_index%,&h00     'delta time
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,&hff     'meta event
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,&h58
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,&h04
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,numerator
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,4
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,click_clocks
                                                  smf_index%=smf_index%+1
                                                  poke_b smf_buffer%+smf_index%,8
                                                  smf_index%=smf_index%+1
                                             endif

                                             plttl%=pat_params(patnbr,1)*pat_params(patnbr,2)*pat_params(patnbr,3)-1
                                             for pulse=0 to plttl%
                                                  for drum=0 to 15
                                                       pulse_pointer%=pat_ary%+768*patnbr+48*drum+pulse
                                                       if stat(drum)<>2 and peek_b(pulse_pointer%)<>0 then
                                                            gosub delta_conversion
                                                            poke_b smf_buffer%+smf_index%,144+chnl(drum)
                                                            smf_index%=smf_index%+1
                                                            poke_b smf_buffer%+smf_index%,ptch(drum)
                                                            smf_index%=smf_index%+1
                                                            poke_b smf_buffer%+smf_index%,bs_vl+peek_b(pulse_pointer%)
                                                            smf_index%=smf_index%+1
                                                       endif
                                                  next

                                                  delta_time%=delta_time%+clks
                                                  for drum=0 to 15
                                                       pulse_pointer%=pat_ary%+768*patnbr+48*drum+pulse
                                                       if stat(drum)<>2 and peek_b(pulse_pointer%)<>0 then
                                                            gosub delta_conversion
                                                            poke_b smf_buffer%+smf_index%,144+chnl(drum)
                                                            smf_index%=smf_index%+1
                                                            poke_b smf_buffer%+smf_index%,ptch(drum)
                                                            smf_index%=smf_index%+1
                                                            poke_b smf_buffer%+smf_index%,0
                                                            smf_index%=smf_index%+1
                                                       endif
                                                  next

                                             next
                                        endif
' END PHRASE LOOP
                                   endif
                              next
                         endif
' END SONG LOOP
                    endif
               next
          endif
     next

' AFFIX END-OF-TRACK META-EVENT
     poke_b smf_buffer%+smf_index%,&h00      'delta time
     smf_index%=smf_index%+1
     poke_b smf_buffer%+smf_index%,&hff      'meta event
     smf_index%=smf_index%+1
     poke_b smf_buffer%+smf_index%,&h2f
     smf_index%=smf_index%+1
     poke_b smf_buffer%+smf_index%,&h00
     smf_index%=smf_index%+1

' CALCULATE LENGTH OF TRACK DATA
     poke_l smf_buffer%+18,smf_index%-22

' SAVE MIDI FILE
     if dfree_space%>smf_index% then
          gosub parse_filename
          bsave exit_file$,smf_buffer%,smf_index%
     else
          alert 3,"Disk full.",1," Cancel ",exit_val
     endif
     erase smf_buffer
     patnbr=save_number
     return

' DELTA TIME VARIABLE-LENGTH QUANTITY CONVERSION
     delta_conversion:
          vlq_buffer%=0
          vlq_pointer%=varptr(vlq_buffer%)
          poke_b vlq_pointer%+3,delta_time% and &h7f
          pointer_offset%=2
          delta_time%=delta_time%\&h80
          while delta_time%<>0
               poke_b vlq_pointer%+pointer_offset%,delta_time% or &h80
               pointer_offset%=pointer_offset%-1
               delta_time%=delta_time%\&h80
          wend
          pointer_offset%=pointer_offset%+1
          while pointer_offset%<4
               poke_b smf_buffer%+smf_index%,peek_b(vlq_pointer%+pointer_offset%)
               smf_index%=smf_index%+1
               pointer_offset%=pointer_offset%+1
          wend
          return

          set_smf_tmpo:
               smf_tmpo%=(60/bpm)*1000000
               smf_tmpo_ptr%=varptr(smf_tmpo%)

               poke_b smf_buffer%+smf_index%,&h00      'delta time
               smf_index%=smf_index%+1
               poke_b smf_buffer%+smf_index%,&hff      'meta event
               smf_index%=smf_index%+1
               poke_b smf_buffer%+smf_index%,&h51
               smf_index%=smf_index%+1
               poke_b smf_buffer%+smf_index%,&h03
               smf_index%=smf_index%+1
               poke_b smf_buffer%+smf_index%,peek_b(smf_tmpo_ptr%+1)
               smf_index%=smf_index%+1
               poke_b smf_buffer%+smf_index%,peek_b(smf_tmpo_ptr%+2)
               smf_index%=smf_index%+1
               poke_b smf_buffer%+smf_index%,peek_b(smf_tmpo_ptr%+3)
               smf_index%=smf_index%+1
               return
               '$event on

               kill_file:
                    ok=1
                    while ok
                         sel_file$=""
                         ask file kill_name$,sel_file$,exit_file$,ok
                         if ok=1 and sel_file$<>"" then
                              gosub open_file
                              if error_code>=0 then
                                   alert 3,"Delete file?",1," Yes | No ",ok
                                   if ok=1 then kill exit_file$
                              endif
                         endif
                    wend
                    return

               format:
                    alert 3,"Formatting will ERASE all data|on the disk.  Click on OK if|you don't mind losing the data.",2,"  OK  |  Cancel  ",ok
                    if ok=1 then
                         gosub format_options
                         save_w=active_w
                         active_w=1
                         menu off
                         on dialog gosub format_dialog
                    endif
                    return

                    format_options:
                         gosub open_dialog
                         gotoxy 9,0
                         print "FORMAT FLOPPY DISK"
                         button 1,2-format_drive,"Drive A",24,36\systab(0),112,20\systab(0),1
                         button 2,format_drive+1,"Drive B",152,36\systab(0),112,20\systab(0),1
                         button 3,2-format_side,"Single-sided",24,76\systab(0),112,20\systab(0),1
                         button 4,format_side+1,"Double-sided",152,76\systab(0),112,20\systab(0),1
                         button 5,1,"FORMAT",24,116\systab(0),112,20\systab(0),1
                         button 6,1,"EXIT",152,116\systab(0),112,20\systab(0),3
                         return

                    format_dialog:
                         on dialog(0) gosub format_btn,dummy,format_ret
                         return

                         format_btn:
                              button dialog(1),2
                              on dialog(1) gosub drive_a,drive_b,single_side,double_side,do_format,end_format
                              return

                              drive_a:
                                   button 2,1
                                   format_drive=0
                                   return

                              drive_b:
                                   button 1,1
                                   format_drive=1
                                   return

                              single_side:
                                   button 4,1
                                   format_side=0
                                   return

                              double_side:
                                   button 3,1
                                   format_side=1
                                   return

                              do_format:
                                   '$event off
                                   mouse 256
                                   closew 1
                                   gosub open_dialog
                                   gosub box_it
                                   gotoxy 9,2
                                   print "Formatting disk..."
                                   dim temp_buffer(8196)
                                   temp_buffer%=varptr(temp_buffer(0))
                                   for side=0 to format_side
                                        gotoxy 14,4
                                        print "Side";side+1
                                        for track=0 to 79
                                             gotoxy 13,6
                                             print "Track";track
                                             xbios 10,temp_buffer%,0,format_drive,9,track,side,1,&h87654321,&he5e5
                                             error_code=status_w
                                             if error_code<0 then
                                                  alert 3,"Formatting error!",1," Abort ",ok
                                                  track=79
                                                  side=format_side
                                             endif
                                        next track
                                   next side
                                   closew 1

                                   if error_code=0 then
                                        for track=0 to 1
                                             xbios 10,temp_buffer%,0,format_drive,9,track,0,1,&h87654321,0
                                        next
                                        ' * PRODUCE BOOT SECTOR * * * * *
                                        xbios 18,temp_buffer%,&h1000000,format_side+2,0
                                        ' * WRITE BOOT SECTOR * * * * * *
                                        xbios 9,temp_buffer%,0,format_drive,1,0,0,1

                                        gemdos &h36,dfree_buffer%,format_drive+1
                                        dfree_space%=(peek_l(dfree_buffer%))*(peek_l(dfree_buffer%+8))*(peek_l(dfree_buffer%+12))
                                        alert$="There are"+str$(dfree_space%)+" bytes|available to user.| "
                                        alert 1,alert$,1," OK ",ok
                                   endif

                                   erase temp_buffer
                                   gosub format_options
                                   mouse 257
                                   return
                                   '$event on

                         end_format:
                              active_w=save_w
                              closew 1
                              menu on
                              gosub select_trap
                              return

                         format_ret:
                              button 6,2
                              gosub end_format
                              return

               quit_program:
                    alert 3,"Exit Master Drummer... | |Are you sure?",1,"Yes|No",ok
                    if ok=1 then
                         call asm%(11)  'restore spurious interrupt vector
                         end
                    endif
                    return

     do_edit:
          on menu(1) gosub enable_edit,dummy,do_backup,retrieve_pattern,dummy,shift,dummy,copy,meter,dummy,accent_vel,dummy,cclear
          return

          enable_edit:
               edit_enable=edit_enable xor 1
               for item=3 to 8
                    menu 1,item,1-edit_enable
               next
               menu 4,1,1,enable$(edit_enable)
               return

          do_backup:
               gosub backup_pattern
               alert 0," Backup accomplished ",1," Ok ",ok
               return

          copy:
               gosub open_dialog
               gosub box_it
               active_w=1
               valid_data=0
               n$=right$(str$((patnbr+1) mod 99+1),2)
               gotoxy 8,1
               print "Copy current pattern"
               gotoxy 12,2
               print "to pattern(s):";
               edit field 1,n$,77,70\systab(0),16,16\systab(0),3
               gotoxy 17,4: print "to";
               edit field 2,n$,190,70\systab(0),16,16\systab(0),3
               button 1,1,"Copy",56,110\systab(0),55,24\systab(0),3
               button 2,1,"Cancel",169,110\systab(0),55,24\systab(0),1
               menu off
               on dialog gosub copy_trap
               edit field 2
               return

               copy_trap:
                    on dialog(0) gosub copy_btn,copy_field,default_btn,dummy,dummy
                    return

                    copy_btn:                'service buttons
                         button dialog(1),2
                         if dialog(1)=1 then gosub do_copy
                         if dialog(1)=2 or valid_data then gosub end_editwindow
                         return

                    end_editwindow:
                         closew 1
                         active_w=0
                         menu on
                         on dialog gosub dialog_trap
                         return

                    copy_field:              'activate copy field
                         edit field dialog(2)
                         return

                    default_btn:             'default button (do copy)
                         button 1,2
                         gosub do_copy
                         if valid_data then gosub end_editwindow
                         return

                         do_copy:
                              low_pat=val(edit$(1))-1
                              hi_pat=val(edit$(2))-1
                              if low_pat>-1 and low_pat<99 and hi_pat>-1 and hi_pat<99 then
                                   mouse 256
                                   valid_data=1
                                   if low_pat>hi_pat then swap hi_pat,low_pat
                                   source_ptr%=pat_ary%+768*patnbr
                                   for dest_pat=low_pat to hi_pat
                                        dest_ptr%=pat_ary%+768*(dest_pat)
                                        for index%=0 to 767
                                             poke_b dest_ptr%+index%,peek_b(source_ptr%+index%)
                                        next 
                                        for n=1 to 3
                                             pat_params(dest_pat,n)=pat_params(patnbr,n)
                                        next
                                   next
                                   mouse 257
                              else
                                   gosub over_range
                              endif
                              return

                              over_range:
                                   alert 3,"Pattern numbers range|    from 1 to 99",1," OK ",exit_val
                                   button 1,1
                                   return

          meter:
               gosub open_dialog
               gosub box_it
               active_w=1
               valid_data=0
               n$=right$(str$((patnbr+1) mod 99+1),2)
               gotoxy 9,1
               print "Copy current meter"
               gotoxy 12,2
               print "to pattern(s):";
               edit field 1,n$,77,70\systab(0),16,16\systab(0),3
               gotoxy 17,4: print "to";
               edit field 2,n$,190,70\systab(0),16,16\systab(0),3
               button 1,1,"Copy",56,110\systab(0),55,24\systab(0),3
               button 2,1,"Cancel",169,110\systab(0),55,24\systab(0),1
               menu off
               on dialog gosub meter_trap
               edit field 2
               return

               meter_trap:
                    on dialog(0) gosub meter_btn,meter_field,default_meter,dummy,dummy
                    return

                    meter_btn:                'service buttons
                         button dialog(1),2
                         if dialog(1)=1 then gosub do_meter
                         if dialog(1)=2 or valid_data then gosub end_editwindow
                         return

                    meter_field:              'activate meter field
                         edit field dialog(2)
                         return

                    default_meter:            'default button (do meter)
                         button 1,2
                         gosub do_meter
                         if valid_data then gosub end_editwindow
                         return

                         do_meter:
                              low_pat=val(edit$(1))-1
                              hi_pat=val(edit$(2))-1
                              if low_pat>-1 and low_pat<99 and hi_pat>-1 and hi_pat<99 then
                                   mouse 256
                                   valid_data=1
                                   if low_pat>hi_pat then swap hi_pat,low_pat
                                   for dest_pat=low_pat to hi_pat
                                        for n=1 to 3
                                             pat_params(dest_pat,n)=pat_params(patnbr,n)
                                        next
                                   next
                                   mouse 257
                              else
                                   gosub over_range
                              endif
                              return

          accent_vel:
               gosub open_dialog
               gosub box_it
               save_w=active_w
               active_w=1
               gotoxy 7,1
               print "Accent velocity (1-9):";
               edit field 1,chr$(accent_char),138,60\systab(0),12,20\systab(0),3
               edit field 1
               button 1,1,"Ok",32,110\systab(0),96,20\systab(0),3
               button 2,1,"Cancel",160,110\systab(0),96,20\systab(0),1
               menu off
               on dialog gosub accent_dialog
               return

               accent_dialog:
                    on dialog(0) gosub accent_btn,dummy,accent_ret
                    return

                         accent_btn:
                              button dialog(1),2
                              if dialog(1)=1 then gosub get_accent
                              gosub end_accent
                              return

                         accent_ret:
                              button 1,2
                              gosub get_accent
                              gosub end_accent
                              return

                              get_accent:
                                   if val(edit$(1))>0 then
                                        accent_char=asc(edit$(1))
                                        call asm%(9,accent_char)
                                   endif
                                   return

                              end_accent:
                                   closew 1
                                   active_w=save_w
                                   menu on
                                   gosub select_trap
                                   return

          shift:
               save_w=active_w
               active_w=1
               alert 2,"Shift which tracks?",1,"Select|All|Cancel",shift_type
               if shift_type<>3 then
                    direction=0
                    while direction<>3
                    alert 2,"Which direction?",1,"Left|Right|Cancel",direction
                    if direction<>3 then
                         plttl=pat_params(patnbr,1)*pat_params(patnbr,2)*pat_params(patnbr,3)-1
                         mouse 256
                         for drum=0 to 15
                              track_ptr%=pat_ary%+768*patnbr+48*drum
                              if shift_type=2 or stat(drum)=3 then
                                   if direction=1 then
                                        save_byte=peek_b(track_ptr%)
                                        for byte=0 to plttl-1
                                             poke_b track_ptr%+byte,peek_b(track_ptr%+byte+1)
                                        next
                                        poke_b track_ptr%+plttl,save_byte
                                   else
                                        save_byte=peek_b(track_ptr%+plttl)
                                        for byte=plttl to 1 step -1
                                             poke_b track_ptr%+byte,peek_b(track_ptr%+byte-1)
                                        next
                                        poke_b track_ptr%,save_byte
                                   endif
                                   gosub draw_track
                              endif
                         next
                         mouse 257
                    endif
                    wend
               endif
               active_w=save_w
               return

          cclear:
               if active_w=0 then
                    save_w=active_w
                    active_w=1
                    alert 1," Erase pattern(s). ",1,"Current|All|Cancel",exit_val
                    if exit_val=1 then
                         gosub clear_pat
                         pat_flg=2                'redraw pattern without backup
                    elseif exit_val=2 then
                         alert 3,"Are you sure?",1,"Yes|No",exit_val
                         if exit_val=1 then
                              call asm%(8,pat_ary%)
                              patnbr=0
                              pat_flg=1
                         endif
                    endif
                    active_w=save_w
               elseif active_w=2 then
                    alert 1," Erase all phrases? ",1," Yes | No ",ok
                    if ok=1 then
                         for n=1 to 16
                              phrases$(n)=""
                         next
                         gosub phrase_redraw
                    endif
               elseif active_w=3 then
                    alert 1," Erase Song? ",1," Yes | No ",ok
                    if ok=1 then
                         for n=1 to 16
                              song$(n)=""
                         next
                         gosub phrase_redraw
                    endif
               endif
               return

               clear_pat:
                    pat_ptr%=768*patnbr+pat_ary%
                    for index%=0 to 767 step 4
                         poke_l pat_ptr%+index%,0
                    next
                    return

          rrandom:
               on menu(1) gosub generate,dummy,set_params
               return

               generate:
                    active_w=1
                    alert 2,"Randomize which track(s)?",1,"Select|All|Cancel",rand_flg
                    if rand_flg<>3 then
                         gosub open_dialog
                         gosub box_it
                         valid_data=0
                         n$=right$(str$(patnbr+1),2)
                         gotoxy 6,2
                         print "Generate new pattern(s):"
                         edit field 1,n$,77,70\systab(0),16,16\systab(0),3
                         gotoxy 17,4: print "to";
                         edit field 2,n$,190,70\systab(0),16,16\systab(0),3
                         button 1,1,"Random",56,110\systab(0),55,24\systab(0),3
                         button 2,1,"Cancel",169,110\systab(0),55,24\systab(0),1
                         menu off
                         on dialog gosub randpat_trap
                         edit field 2
                         return
                    else
                         active_w=0
                    endif
                    return

               randpat_trap:
                    on dialog(0) gosub randpat_btn,randpat_field,randpat_default,dummy,dummy
                    return

                    randpat_btn:                'service buttons
                         button dialog(1),2
                         if dialog(1)=1 then gosub do_randpat
                         if dialog(1)=2 or valid_data then gosub end_editwindow
                         return

                    randpat_field:               'activate randpat field
                         edit field dialog(2)
                         return

                    randpat_default:             'default button (do randpat)
                         button 1,2
                         gosub do_randpat
                         if valid_data then gosub end_editwindow
                         return

                         do_randpat:
                              low_pat=val(edit$(1))-1
                              hi_pat=val(edit$(2))-1
                              if low_pat>-1 and low_pat<99 and hi_pat>-1 and hi_pat<99 then
                                   mouse 256
                                   valid_data=1
                                   if low_pat>hi_pat then swap hi_pat,low_pat
                                   if patnbr>=low_pat and patnbr<=hi_pat then pat_flg=2
                                   for dest_pat=low_pat to hi_pat
                                        plttl=pat_params(dest_pat,1)*pat_params(dest_pat,2)*pat_params(dest_pat,3)-1
                                        for drum=0 to 15
                                             track_ptr%=pat_ary%+768*dest_pat+48*drum
                                             if rand_flg=2 or stat(drum)=3 then
                                                  for pulse%=0 to plttl
                                                       if rnd*99<note_density(drum) then
                                                                             'note density
                                                            if rnd*99<accent_prob(drum) then
                                                                             'accent probability
                                                                 velocity=28
                                                            else
                                                                 velocity=1
                                                            endif
                                                            if rnd*99<quant_prob(drum) then
                                                                              'quantization probability
                                                                 poke_b track_ptr%+(pulse%\quant_val(drum))*quant_val(drum),velocity
                                                            else
                                                                 poke_b track_ptr%+pulse%,velocity
                                                            endif
                                                       else
                                                            poke_b track_ptr%+pulse%,0
                                                       endif
                                                  next
                                             endif
                                        next
                                   next
                                   mouse 257
                              else
                                   gosub over_range
                              endif
                              return

               set_params:
                    gosub end_edit
                    openw 1,142,32\systab(0),352,352\systab(0),0
                    active_w=1
                    mouse 256
                    print tab(16);"DENSITY ACCENT QUANT VALUE"
                    for n=0 to 15
                         y=n*window(15)+20\systab(0)
                         print "    ";drum_name$(n+1)
                         edit field n+1,right$(str$(note_density(n)),2),160,y,16,window(15),3
                         edit field n+17,right$(str$(accent_prob(n)),2),208,y,16,window(15),3
                         edit field n+33,right$(str$(quant_prob(n)),2),256,y,16,window(15),3
                         edit field n+49,right$(str$(quant_val(n)),2),304,y,16,window(15),3
                    next
                    new_field=1
                    edit field 1
                    mouse 257
                    if systab(0)=1 then
                         y=25
                    elseif systab(0)=2 then
                         y=15
                    endif
                    button 1,1,"DONE",144,window(3)-y,64,window(15),1
                    menu off
                    on dialog gosub edit_randset
                    return

               edit_randset:
                    on dialog(0) gosub rand_btn,rand_edit,rand_ret
                    return

                    rand_btn:
                         button 1,2
                         for n=0 to 15
                              note_density(n)=val(edit$(n+1))
                              accent_prob(n)=val(edit$(n+17))
                              quant_prob(n)=val(edit$(n+33))
                              quant_val(n)=val(edit$(n+49))
                              if quant_val(n)=0 then quant_val(n)=1
                         next
                         closew 1
                         active_w=0
                         menu on
                         on dialog gosub dialog_trap
                         return

                    rand_edit:
                         new_field=dialog(2)
                         edit field new_field
                         return

                    rand_ret:
                         edit field (dialog(3) mod 64)+1
                         return 

     clock:
          on menu(1) gosub master,slave,dummy,set_start,dummy,pulse_pulse,beat_beat,dummy,clock_res,dummy,set_tapflag,dummy,met_select,met_res
          return

          master:
               slave=0
               call asm%(7,slave,midi_start)
               menu 6,1,2
               menu 6,2,1
               return

          slave:
               slave=1
               call asm%(7,slave,midi_start)
               menu 6,1,1
               menu 6,2,2
               return

          set_start:
               midi_start=midi_start xor 1
               call asm%(7,slave,midi_start)
               menu 6,4,midi_start+1
               return

          pulse_pulse:
               if unit=1 then gosub change_unit
               return

          beat_beat:
               if unit=0 then gosub change_unit
               return

               change_unit:
                    unit=unit xor 1
                    menu 6,6,2-unit
                    menu 6,7,1+unit
                    gosub clock_res
                    return

          clock_res:
               gosub open_dialog
               gosub box_it
               save_w=active_w
               active_w=1
               valid_data=0
               if unit=0 then
                    gotoxy 5,2
                    print "MIDI clocks per pulse:"
                    edit field 1,right$(str$(pulse_clocks),3),224,2*window(15)+1,28,20\systab(0),3
                    gotoxy 4,4
                    print "pulses per quarter note:"
                    edit field 2,right$(str$(quarter_pulses),3),224,4*window(15)+1,28,20\systab(0),3
               else
                    gotoxy 3,1
                    print " MIDI clocks per quarter note:"
                    edit field 1,right$(str$(btcl),3),130,60\systab(0),28,20\systab(0),3
               endif
               edit field 1
               button 1,1,"Ok",32,110\systab(0),96,20\systab(0),3
               button 2,1,"Cancel",160,110\systab(0),96,20\systab(0),1
               menu off
               on dialog gosub clock_dialog
               return

               clock_dialog:
                    on dialog(0) gosub clock_btn,clock_edit,clock_ret
                    return

                         clock_btn:
                              button dialog(1),2
                              if dialog(1)=1 then gosub get_clockres
                              if dialog(1)=2 or valid_data then gosub end_clock
                              return

                         clock_edit:
                              edit field dialog(2)
                              return

                         clock_ret:
                              button 1,2
                              gosub get_clockres
                              if valid_data then gosub end_clock
                              return

                              get_clockres:
                                   if unit=0 then
                                        if val(edit$(1))*val(edit$(2))>=24 and val(edit$(1))*val(edit$(2))<121 then
                                             pulse_clocks=val(edit$(1))
                                             quarter_pulses=val(edit$(2))
                                             btcl=pulse_clocks*quarter_pulses
                                             gosub res_valid
                                        else
                                             gosub clock_alert
                                        endif
                                   else
                                        if val(edit$(1))>=23 and val(edit$(1))<121 then
                                             btcl=val(edit$(1))
                                             pulse_clocks=btcl\quarter_pulses
                                             gosub res_valid
                                        else
                                             gosub clock_alert
                                        endif
                                   endif
                                   return

                              res_valid:
                                   tmpo=int(((24400*24)/btcl)/bpm)
                                   t_flg=1
                                   valid_data=1
                                   return

                              clock_alert:
                                   alert 1,"MIDI clocks per quarter note|must range from 24 to 120.",1,"OK",ok
                                   button 1,1
                                   return

                              end_clock:
                                   closew 1
                                   active_w=save_w
                                   menu on
                                   gosub select_trap
                                   return

          set_tapflag:
               tap_flag=1
               return

          met_select:
               mflg=mflg xor 1
               menu 6,13,mflg+1
               return

          met_res:
               gosub open_dialog
               gosub box_it
               save_w=active_w
               active_w=1
               valid_data=0
               gotoxy 4,1
               print "MIDI clocks/metronome click:"
               edit field 1,right$(str$(mtcl),3),130,60\systab(0),28,20\systab(0),3
               edit field 1
               button 1,1,"Ok",32,110\systab(0),96,20\systab(0),3
               button 2,1,"Cancel",160,110\systab(0),96,20\systab(0),1
               menu off
               on dialog gosub met_dialog
               return

               met_dialog:
                    on dialog(0) gosub met_btn,dummy,met_ret
                    return

                         met_btn:
                              button dialog(1),2
                              if dialog(1)=1 then gosub get_metres
                              if dialog(1)=2 or valid_data then gosub end_met
                              return

                         met_ret:
                              button 1,2
                              gosub get_metres
                              if valid_data then gosub end_met
                              return

                              get_metres:
                                   if val(edit$(1))>=1 then
                                        mtcl=val(edit$(1))
                                        valid_data=1
                                   else
                                        alert 1,"Invalid data",1,"Cancel",ok
                                        button 1,1
                                   endif
                                   return

                              end_met:
                                   closew 1
                                   active_w=save_w
                                   menu on
                                   gosub select_trap
                                   return

     help:
          on menu(1) gosub help_window
          return

          help_window:
               save_w=active_w
               active_w=1
               mouse 256
               if save_w=0 then
                    titlew 1," PATTERN MODE KEY FUNCTIONS "
               elseif save_w=2 then
                    titlew 1," PHRASE MODE KEY FUNCTIONS "
               elseif save_w=3 then
                    titlew 1," SONG MODE KEY FUNCTIONS "
               endif
               openw 1,0,0,640,400,1

                    x=1: y=0
                    gotoxy x,y
                    effect=1: gosub vst_effects: print "File:": effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Save.........CTRL S";
                    y=y+1: gotoxy x,y
                    print "Load.........CTRL L";
                    y=y+1: gotoxy x,y
                    print "Quit.........CTRL Q";

                    y=y+3
                    gotoxy x,y
                    effect=1: gosub vst_effects: print "Mode:"
                    effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Pattern......CTRL 1»";
                    y=y+1: gotoxy x,y
                    print "Phrase.......CTRL 2»";
                    y=y+1: gotoxy x,y
                    print "Song.........CTRL 3»";
                    x=2: y=y+1
                    gotoxy x,y
                    print "(»numeric keypad)";

                    x=1: y=y+2
                    gotoxy x,y
                    if save_w=0 then
                         effect=1: gosub vst_effects
                    else
                         effect=2: gosub vst_effects
                    endif
                    print "Randomize:"
                    if save_w=0 then effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Generate.....CTRL G";
                    y=y+1: gotoxy x,y
                    print "Parameters...CTRL P";

                    y=y+3
                    gotoxy x,y
                    effect=1: gosub vst_effects: print "Help:"
                    effect=0: gosub vst_effects
                    y=y+1
                    gotoxy x,y
                    print "This screen...CTRL Help";

                    x=24: y=0
                    gotoxy x,y
                    effect=1: gosub vst_effects: print "Edit:";
                    effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "On/off.........CTRL Undo";
                    if save_w<>0 then effect=2: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Backup.........CTRL Insert";
                    y=y+1: gotoxy x,y
                    print "Retrieve.......CTRL Clr/Home";
                    y=y+1: gotoxy x,y
                    print "Shift..........CTRL Backspace";
                    y=y+1: gotoxy x,y
                    print "Copy Pattern...CTRL ";chr$(4);
                    y=y+1: gotoxy x,y
                    print "Copy Meter.....CTRL ";chr$(3);
                    y=y+1: gotoxy x,y
                    print "Accent level...CTRL 1-9";
                    y=y+1: gotoxy x,y
                    effect=0: gosub vst_effects
                    print "Erase all......CTRL Delete";

                    y=y+2: gotoxy x,y
                    if save_w=0 then
                         print "Next pattern";
                    elseif save_w=2 then
                         print "Next phrase.";
                    elseif save_w=3 then
                         print "Next part...";
                    endif
                    print ".......CTRL ";chr$(1);
                    y=y+1: gotoxy x,y
                    if save_w=0 then
                         print "Previous pattern";
                    elseif save_w=2 then
                         print "Previous phrase.";
                    elseif save_w=3 then
                         print "Previous part...";
                    endif
                    print "...CTRL ";chr$(2);

                    y=y+2
                    gotoxy x,y
                    effect=1: gosub vst_effects: print "Playback:";
                    effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Go/stop........Enter(Return)";
                    y=y+1: gotoxy x,y
                    print "Pause..........Space bar";
                    y=y+1: gotoxy x,y
                    print "Metronome......[";

                    x=57: y=0
                    gotoxy x,y
                    effect=1: gosub vst_effects: print "Clock:";
                    effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Internal......CTRL (»";
                    y=y+1: gotoxy x,y
                    print "External......CTRL )»";
                    y=y+1: gotoxy x,y
                    print "MIDI start....CTRL /»";
                    y=y+1: gotoxy x,y
                    print "Pulse=pulse...CTRL *»";
                    y=y+1: gotoxy x,y
                    print "Beat=beat.....CTRL -»";
                    y=y+1: gotoxy x,y
                    print "Resolution....CTRL +»";
                    y=y+1: gotoxy x,y
                    print "Set tempo.....CTRL 0»";
                    y=y+1: gotoxy x,y
                    print "Metronome.....CTRL [";
                    y=y+1: gotoxy x,y
                    print "Clocks/click..CTRL ]";

                    x=59: y=y+1
                    gotoxy x,y
                    print "(»numeric keypad)";

                    x=57: y=y+3
                    gotoxy x,y
                    if save_w=0 then
                         effect=1: gosub vst_effects
                    else
                         effect=2: gosub vst_effects
                    endif
                    print "Pattern parameters:"
                    if save_w=0 then effect=0: gosub vst_effects
                    y=y+1: gotoxy x,y
                    print "Pattern #.....CTRL F1";
                    y=y+1: gotoxy x,y
                    print "Pulses/beat...CTRL F2";
                    y=y+1: gotoxy x,y
                    print "Beats/meas....CTRL F3";
                    y=y+1: gotoxy x,y
                    print "Measures......CTRL F4";
                    y=y+1: gotoxy x,y
                    print "Config Name...CTRL F5";
                    effect=0: gosub vst_effects

               if systab(0)=1 then
                    z=42
               elseif systab(0)=2 then
                    z=13
               endif
               button 1,1,"DONE",284,window(3)-z,64,window(15)+2\systab(0),3
               menu off
               on dialog gosub help_dialog
               mouse 257
               return

               help_dialog:
                    on dialog(0) gosub help_button,dummy,help_button
                    return

                    help_button:
                         button 1,2
                         closew 1
                         active_w=save_w
                         menu on
                         gosub select_trap
                         mouse 257
                         return

     mode:
          on menu(1) gosub make_pats,phrases,song
          return

               make_pats:
                    '$event off
                    mouse 256
                    for n=1 to 16
                         if active_w=2 then
                              phrases$(n)=edit$(n)
                         elseif active_w=3 then
                              song$(n)=edit$(n)
                         endif
                         edit field close n
                    next
                    old_t_pos(active_w)=t_arw
                    menu 3,1,0
                    menu 3,active_w,1
                    menu 4,13,1,"  Erase pattern(s) "
                    menu_stat=1
                    gosub enable_menu

                    activew 0
                    redraw 0
                    active_w=0
                    gosub update_t_arrow
                    reset
                    supress_redraw=1
                    fcode=0
                    act_field=0
                    phrase_vel=bs_vl
                    bs_vl=72
                    mouse 257
                    on dialog gosub dialog_trap
                    return
                    '$event on

          phrases:
               '$event off
               mouse 256
               if active_w=0 then
                    old_t_pos(0)=t_arw
               elseif active_w=3 then
                    for n=1 to 16
                         song$(n)=edit$(n)
                         edit field close n
                    next
               endif

               activew 2
               redraw 2
               active_w=2
               gosub update_t_arrow
               gosub update_v_arrow
               supress_redraw=1
               for n=1 to 16
                    y=(n-1)*20\systab(0)+7\systab(0)
                    edit field n,phrases$(n),160,y,469,window(15)-1,3
               next
               act_field=1
               edit field 1
               fcode=4
               menu_stat=0
               bs_vl=phrase_vel
               gosub enable_menu
               menu 3,1,1
               menu 3,2,0
               menu 3,3,1
               menu 4,13,1,"  Erase phrases    "
               mouse 257
               on dialog gosub phrase_dialog
               return
               '$event on

               phrase_dialog:
                    on dialog(0) gosub phrase_btn,phrase_edit,phrase_ret,redraw_w,dummy
                    return

                    phrase_btn:
                         if dialog(1)<>17 then
                              play_phrase$=edit$(dialog(1))+" "
                              phrase_no=dialog(1)
                         elseif dialog(1)=17 then
                              play_phrase$=edit$(act_field)+" "
                              phrase_no=act_field
                         endif
                         phrase_repeat=0
                         gosub phrase_playback
                         return

                    phrase_playback:
                         button 17,2
                         if systab(0)=1 then
                              z=40
                         elseif systab(0)=2 then
                              z=21
                         endif
                         c%=134
                         r%=(phrase_no-1)*20\systab(0)+z

                         save_number=patnbr
                         phrases$(act_field)=edit$(act_field)
                         edit field close act_field
                         y=(act_field-1)*20\systab(0)+7\systab(0)
                         edit field act_field,phrases$(act_field),160,y,469,window(15)-1,3

                    restart_phrase:
                         gosub play_phrase
                         if end_flg=2 then restart_phrase

                         call asm%(3)
                         menu 6,13,mflg+1
                         gosub space_out
                         edit field act_field
                         patnbr=save_number
                         button 17,1
                         gosub mouse_loop
                         gosub clear_queue
                         return

                         space_out:
                              mouse 256
                              strin$="   "
                              gosub v_gtext
                              mouse 257
                              return

                         play_phrase:
                              '$event off
                              key=0
                              end_flg=0
                              restart_flg=1
                              while restart_flg=1
                                   restart_flg=0
                                   for n=1 to len(play_phrase$)
                                        if end_flg=0 then

                                             e=n
                                             while mid$(play_phrase$,e,1)<>" "
                                                  e=e+1
                                             wend

                                             if e-n<5 then
                                                  if upper$(mid$(play_phrase$,n,1))="T" then
                                                       if slave=0 then
                                                            bpm=val(mid$(play_phrase$,n+1,e-n))
                                                            if bpm>0 and bpm<241 then
                                                                 tmpo=int(((24400*24)/btcl)/bpm)
                                                                 t_flg=1
                                                            endif
                                                       endif
                                                       n=e
                                                  elseif upper$(mid$(play_phrase$,n,1))="V" then
                                                       new_vel=val(mid$(play_phrase$,n+1,e-n))
                                                       if new_vel>0 and new_vel<100 then
                                                            bs_vl=new_vel
                                                            v_flg=1
                                                       endif
                                                       n=e
                                                  elseif upper$(mid$(play_phrase$,n,1))="R" and val(mid$(play_phrase$,n+1,e-n))>1 then
                                                       if phrase_repeat=0 then
                                                            phrase_repeat=val(mid$(play_phrase$,n+1,e-n))
                                                       endif
                                                       if phrase_repeat=1 then
                                                            phrase_repeat=0
                                                            n=e
                                                       else
                                                            phrase_repeat=phrase_repeat-1
                                                            n=0
                                                       endif
                                                  else
                                                       patnbr=val(mid$(play_phrase$,n,e-n))-1
                                                       n=e
                                                       if patnbr>-1 and patnbr<99 then
                                                            if fcode=4 then
                                                                 mouse 256
                                                                 strin$=right$(str$(patnbr+1),2)+chr$(3)
                                                                 gosub v_gtext
                                                                 mouse 257
                                                            endif
                                                            gosub play_pat
                                                       endif
                                                       if end_flg<>0 then
                                                           if phr_prt>0 then gosub erase_marker
                                                            n=len(play_phrase$)
                                                            phrase_repeat=0
                                                            if fcode=5 then
                                                                 s=len(part$)
                                                                 part_repeat=0
                                                                 part=16
                                                            endif
                                                       else
                                                            if key<>0 then
                                                                 n=len(play_phrase$)
                                                                 phrase_repeat=0
                                                                 if phr_prt>0 then gosub erase_marker
                                                                 if key=&h48 then
                                                                      if fcode=4 then
                                                                           phrase_no=phrase_no-1
                                                                           if phrase_no<1 then phrase_no=16
                                                                           gosub replay_phrase
                                                                      elseif fcode=5 then
                                                                           s=len(part$)
                                                                           part_repeat=0
                                                                           part=part-2
                                                                           if part<0 then part=15
                                                                      endif
                                                                 elseif key=&h50 then
                                                                      if fcode=4 then
                                                                           phrase_no=phrase_no+1
                                                                           if phrase_no>16 then phrase_no=1
                                                                           gosub replay_phrase
                                                                      elseif fcode=5 then
                                                                          s=len(part$)
                                                                           part_repeat=0
                                                                           if part>15 then part=0
                                                                      endif
                                                                 endif
                                                                 key=0
                                                            endif
                                                            if phr_prt>0 then
                                                                 gosub space_out
                                                                 n=len(play_phrase$)
                                                                 r%=(phr_prt-1)*20\systab(0)+z
                                                                 if fcode=4 then
                                                                      phrase_no=phr_prt
                                                                      play_phrase$=edit$(phrase_no)+" "
                                                                      phrase_repeat=0
                                                                      restart_flg=1
                                                                 elseif fcode=5 then
                                                                      s=len(part$)
                                                                      part_repeat=0
                                                                      part=phr_prt-1
                                                                 endif
                                                                 phr_prt=0
                                                            endif
                                                       endif
                                                  endif
                                             endif
                                        endif
                                   next
                              wend
                         resume_phrase:
                              return
                              '$event on

                    phrase_edit:
                         phrases$(act_field)=edit$(act_field)
                         act_field=dialog(2)
                         edit field act_field
                         return

                    phrase_ret:
                         play_phrase$=edit$(act_field)+" "
                         phrase_no=act_field
                         gosub phrase_playback
                         return

                    erase_marker:
                         save_r%=r%
                         r%=(phr_prt-1)*20\systab(0)+z
                         gosub space_out
                         r%=save_r%
                         phr_prt=0
                         return

               replay_phrase:
                    mouse 256
                    strin$="   "
                    gosub v_gtext
                    r%=(phrase_no-1)*20\systab(0)+z
                    strin$=right$(str$(patnbr),2)+chr$(3)
                    gosub v_gtext
                    mouse 257
                    restart_flg=1
                    play_phrase$=edit$(phrase_no)+" "
                    return


          song:
               '$event off
               mouse 256
               if active_w=0 then
                    old_t_pos(0)=t_arw
               elseif active_w=2 then
                    for n=1 to 16
                         phrases$(n)=edit$(n)
                         edit field close n
                    next
               endif

               activew 3
               redraw 3
               active_w=3
               gosub update_t_arrow
               gosub update_v_arrow
               supress_redraw=1
               for n=1 to 16
                    y=(n-1)*20\systab(0)+7\systab(0)
                    edit field n,song$(n),160,y,469,window(15)-1,3
               next
               act_field=1
               edit field 1
               fcode=5
               menu_stat=0
               bs_vl=phrase_vel
               gosub enable_menu
               menu 3,1,1
               menu 3,2,1
               menu 3,3,0
               menu 4,13,1,"  Erase song       "
               mouse 257
               on dialog gosub song_dialog
               return
               '$event on

               song_dialog:
                    on dialog(0) gosub song_btn,song_edit,song_ret,redraw_w,dummy
                    return

                    song_btn:
                         if dialog(1)<>17 then
                              start_part=dialog(1)
                         elseif dialog(1)=17 then
                              start_part=act_field
                         endif
                         part_repeat=0
                         gosub song_playback
                         return

                    song_playback:
                         '$event off
                         button 17,2

                         song$(act_field)=edit$(act_field)
                         edit field close act_field
                         y=(act_field-1)*20\systab(0)+7\systab(0)
                         edit field act_field,song$(act_field),160,y,469,window(15)-1,3

                         if systab(0)=1 then
                              z=40
                         elseif systab(0)=2 then
                              z=21
                         endif
                         c%=134
                         save_number=patnbr
                    restart_song:
                         end_flg=0
                         for part=start_part to 16
                              if edit$(part)<>"" then
                                   r%=(part-1)*20\systab(0)+z
                                   part$=edit$(part)+" "
                                   for s=1 to len(part$)
                                        f=s
                                        while mid$(part$,f,1)<>" "
                                             f=f+1
                                        wend
                                        if f-s<5 then
                                             if upper$(mid$(part$,s,1))="T" then
                                                  if slave=0 then
                                                       bpm=val(mid$(part$,s+1,f-s))
                                                       if bpm>0 and bpm<241 then
                                                            tmpo=int(((24400*24)/btcl)/bpm)
                                                            t_flg=1
                                                       endif
                                                  endif
                                                  s=f
                                             elseif upper$(mid$(part$,s,1))="V" then
                                                  new_vel=val(mid$(part$,s+1,f-s))
                                                  if new_vel>0 and new_vel<100 then
                                                       bs_vl=new_vel
                                                       v_flg=1
                                                  endif
                                                  s=f
                                             elseif upper$(mid$(part$,s,1))="R" and val(mid$(part$,s+1,f-s))>1 then
                                                  if part_repeat=0 then
                                                       part_repeat=val(mid$(part$,s+1,f-s))
                                                  endif
                                                  if part_repeat=1 then
                                                       part_repeat=0
                                                       s=f
                                                  else
                                                       part_repeat=part_repeat-1
                                                       s=len(part$)
                                                       part=part-1
                                                  endif
                                             else
                                                  phrase_n=val(mid$(part$,s,f-s))
                                                  s=f
                                                  if phrase_n>0 and phrase_n<17 then
                                                       mouse 256
                                                       strin$=right$(str$(phrase_n),2)+chr$(3)
                                                       gosub v_gtext
                                                       mouse 257

                                                       play_phrase$=phrases$(phrase_n)+" "
                                                       gosub play_phrase
                                                       gosub space_out
                                                  endif
                                             endif
                                        endif
                                   next
                              endif
                         next
                    resume_song:
                         if end_flg=2 then restart_song
                         call asm%(3)
                         menu 6,13,mflg+1
                         patnbr=save_number
                         edit field act_field
                         button 17,1
                         gosub mouse_loop
                         gosub clear_queue
                         return
                         '$event on
  

                    song_edit:
                         song$(act_field)=edit$(act_field)
                         act_field=dialog(2)
                         edit field act_field
                         return

                    song_ret:
                         start_part=act_field
                         gosub song_playback
                         return

button_bar:
     mouse 256
     if systab(0)=1 then
          linef 0,327,632,327
          color ,1,,8,2
          box 16,336,228,366                 'draw velocity bar
          linef 20,366,20,370,231,370,231,340,228,340
          fill 21,367

          size=1: gosub vst_point
          strin$="VELOCITY": c%=22: r%=362
          gosub v_gtext
          gosub hires_text

          for n=25 to 217 step 8
               linef n,360,n,363
          next
                                             'draw PLAY button
          box 275,336,331,366
          button 17,1,"PLAY",279,340,49,23,1
          linef 279,366,279,370,334,370,334,340,331,340
          fill 280,367

                                             'draw tmpo bar
          box 378,336,622,366
          linef 382,366,382,370,625,370,625,340,622,340
          fill 383,367

          size=1: gosub vst_point
          strin$="TEMPO": c%=384: r%=362
          gosub v_gtext
          gosub hires_text

          for n=387 to 611 step 8
               linef n,360,n,363
          next
          color ,,,4,2: fill 1,328
     elseif systab(0)=2 then
          linef 0,165,632,165
          color ,1,,8,2
                                             'draw velocity bar
          box 16,165,228,183
          for n=25 to 219 step 8
               linef n,182,n,182
          next

          size=1: gosub vst_point
          strin$="VELOCITY": c%=22: r%=183
          gosub v_gtext
          gosub medres_text

                                             'draw PLAY button
          button 17,1,"PLAY",279,167,49,15

                                             'draw tempo bar
          box 378,165,622,183
          for n=387 to 611 step 8
               linef n,182,n,182
          next

          size=1: gosub vst_point
          strin$="TEMPO": c%=384: r%=183
          gosub v_gtext
          gosub medres_text

          color ,,,4,2
          fill 1,174
          fill 230,174
          fill 376,174
          fill 623,174
     endif
     mouse 257
     return

enable_menu:
     menu 4,3,menu_stat 'Backup pattern
     menu 4,4,menu_stat 'Retrieve pattern
     menu 4,6,menu_stat 'Shift pulses
     menu 4,8,menu_stat 'Copy pattern
     menu 4,9,menu_stat 'Copy meter
     menu 4,11,menu_stat'Accent velocity
     menu 5,1,menu_stat 'Generate Tracks
     menu 5,3,menu_stat 'Set Parameters
     return

open_dialog:
     openw 1,176,124\systab(0),288,172\systab(0),0
     return

box_it:
     box 6,6\systab(0),window(2)-7,window(3)-7\systab(0)
     linef 7,window(3)-7\systab(0),7,7\systab(0),window(2)-7,7\systab(0)
     linef 8,window(3)-7\systab(0),8,8\systab(0),window(2)-7,8\systab(0)
     return

draw_track:
     '$event off
     if systab(0)=1 then
          z=88
     elseif systab(0)=2 then
          z=48
     endif
     r%=(drum*window(15))+z
     for pulse%=0 to 47
          velocity=peek_b(track_ptr%+pulse%)
          if velocity=0 then
               strin$=" "
          elseif velocity=1 then
               strin$=chr$(11)
          elseif velocity>1 and velocity<28 then
               strin$=chr$((velocity-1)\3+48)
          elseif velocity=28 then
               strin$=">"
          endif
          c%=(pulse%*9)+198
          gosub v_gtext
     next
     return
     '$event on

open_file:
     dummy$=exit_file$+chr$(0)
     dummy%=peek_l(varptr(dummy$))
     gemdos &h3d,dummy%,2
     error_code=status_w
     return

mouse_loop:
     '$event off
     while inp(-2)<>0: b=inp(2): wend
     b=1
     while b<>0: ask mouse x,y,b: wend
     if active_w<>0 then
          delay%=timer+50
          while delay%>timer: wend
     endif
     return
     '$event on

default_configuration:
     config_name$=" Default configuration "
                                             'default drum names
     for n=1 to 16
          drum_name$(n)="Drum #"+right$(str$(n),2)
     next 

     for n=0 to 15
          read ptch(n)
          chnl(n)=0
          stat(n)=1
          note_density(n)=20                 'note density=20%
          accent_prob(n)=35                  'accent probability=35%
          quant_prob(n)=25                   'quantization probability=25%
          quant_val(n)=4                     'quantization value=4 pulses
     next
                                             'default drum ptches
          data 36,40,43,48,52,55,60,64
          data 67,72,76,79,84,88,91,96

     return

default_patterns:                           '4 pulses/4 beats/3 measures
     for patnbr=0 to 98
          pat_params(patnbr,0)=patnbr+1     '(0)=pattern number
          pat_params(patnbr,1)=4            '(1)=pulses per beat
          pat_params(patnbr,2)=4            '(2)=beats per measure
          pat_params(patnbr,3)=3            '(3)=measures per pattern
     next
     patnbr=0
     return

error_trap:
     xbios 5,physbase%,physbase%,res
     alert 3,"System error",1,"Abort",ok
     end

