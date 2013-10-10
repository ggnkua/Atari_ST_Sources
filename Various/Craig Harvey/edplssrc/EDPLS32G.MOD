IMPLEMENTATION MODULE EdPlus; (* was Diary.  even as 'EDHAK' *)
(****************************************************************)
(** Copyright (c) 1989-96 by Craig Harvey, All Rights Reserved **)
(******************************************************************)
(* REMEMBER TO FIX bssbaselen IF I ADD/DEL ANY GLOBAL VARIABLES!!!! *)
(******************************************************************)

(* sections left out for public EDHAK version are marked by (*ep*)
   just leaves out ability to save a new config *)
(* sections left out for registered DIARY version are marked by (*dr*)
   omits view/edit ram, disk sector editing: i.e., a "safe" version *)
(* sections left out for public DIARY version are marked by (*dp*)
   omits all (*ep,dr,dp*) things from above *)
(* sections left out for DIARY 'S' stripped version are marked by (*ds*)
   same as public but 4K buffer, no paste/wrap buffer, no word wrap,
   no block functions, no Undo, no find/replace, no NotiChar,
   no Help, no Encrypt, no macros *)
(* 3.2G  beta
   Change all mouse on/off to line-A read hidecount, call show; ?
   *)
(* 3.2F  beta
   Change all mouse on/off back to line-A; x
   *)
(* 3.2E  beta
   Try changing all mouse on/off to grafmouse; ?
   *)
(* 3.2D  beta 3/25/96
   Change from LineA mouse on/off to VDI for Magic compat; ?
   Fix outdev to last selected dev for shift-CR typeahead; x
   Fix 1-byte extra send to serial/printer vs Stalker typeahead; x
   Fix typeahead to Stalker after clear buffer etc.(null terminate); x
   Fix VirtualBuf when not find autoload or other open file; x
   Fix Stalker 3.03+ paste to STeno 153 vs 53; x
   Fix lost Ctl-key combos!; x
   *)
(* 3.2C release 3.20
   vfntadptr => startfold; x
   Get rid of extra misplaced redraw after goto line; x
   Get rid of extra misplaced redraw after gotobigind; x
   Fix InitMenu when slide/shift bigfile; x
   Fix lock-up when gotoline 1 after text/hack/text bigfile; x
   Alert: wrong line # when go hack->txt in bigfile after 1st blk; x
   *)
(* 3.2B
   Allow print while typeahead to modem; x
   Unset saved flag after block shift; x
   Save default strip during kwiksend (cfg.kwikstrip); x
   Fix lockup when Goto line bigger than there is; x
   *)
(* 3.2A
   Fix print block when no block selected; x
   Search for selected block; x  Use malloc'd buffer; x  handle RETURNs; x
   Last-used = default for replace all/next (cfg.askall); x
   Add Stalker/modem/printer typeahead command (shift-CR); x
   Allow lowercase hex conversion in hex/char convert; x
   Allow cancel from hex/char conversion; x
   change filename when clear buffer; x
   Allow char = hex with full buffer by destroying last half; x
   Add wrapped hack display mode; x
   YYMMDD date format; x  rsc; x
   shift-alt-D DateCfg; x
   shift-alt-K don't ask if strip; (looks like it already doesn't)
   User friendly convert CR/LF, LF, CR; 
   *)
(* 3.1H = 3.13
   Speed up global replace; x
   Tell number of replaces; x
   User friendly convert CR/LF, LF, CR;
   *)
(* 3.1G
   Fix search/load disk sectors cursor placement; x
   Fix Printer init text shown with DEC button; x
   Printer init: allow reset with null strg; x
   Fix Alt-I, Alt-G init strings; x
   *)
(* 3.1F 3.12
   Fix Diskopen after having bigfile (add clearall/fileend); ?
   Add Clearall for viewmem (fileend); ?
   Check/Fix Clear Buff for bigfiles, especially Stalker capture; 
   Clear 'shifting' notice after Find; x
   Check dofind & stripctl endability on bigfile; x, ?
   Add Stalker/STeno paste command (53); x
   Fix redraw on page up/dwn at top/bottom of file; x
   Fix redraw on arrow up/dwn at top/bottom of file; x
   Force rtarrow when arrow down on extended lastline; x
   Fix shift-clrhome x & redraw from bottom of single window file; ?
   Fix Joe's STalker (clearbuff bigfile) crash; x
    (init fileend, lasti, buffline, startf, endf)
   Fix slidesize when capture from Stalker (& init fileend); x
   Fix Mike's slidepos unable to move little bit from top/bottom; x
  *)
(* 3.1D  3.11
   Fix block highlight after menu:Wrapblock (was in 3.03); x
   Fix vert slide after merge & small files; x
   Fix vert slide & key down past buffer after not saving changes; x
   Ctl-up/dwn arrow for top/bottom of buffer; x
   Shift-Ctl-up/dwn arrow for top/bottom of file; 
   Shift-Ctl-clrhome toggle top/bottom of file; x
   Ctl-ClrHome toggle top/bottom of buffer; x
  *)
(* Edit*Plus 3.1C = 3.10
   No display during bigfile searches/shifts; x
   3.1C handle line# & offset by whole file; x
   Change viewram menu option to Gotoline; x
   Allow saving ACC buffer size to EdPlus in any path; x
   ruinblock before select all; x
   Set slider per whole file size, not just buffered part; x
   Warning of saving changes in extended search/replace; x
   Fix redraw after save after font change; x
   Add printer end-job string (or at least FF option); x
   Grab all RAM as PRG?? enough for file being loaded, up to max/min; x
   Called sorter; x
   Called encrypter; x
   Upper/Lower/Caps case changer; x
   Remove Pick/Find block dialog if bigfile; x
   Select All (shift-alt-E); x
   Strip all non-text (shift-alt-R); x
   Anthill multiTOS bugfixes; ?
   Strip LF, printinit, left margin if to serial port;
   Built-in (or called) wildcard srchrep;
   Read Config at will??
   input line buffer;
   expert minimal alert mode?
   configurable keyboard cmds;
   configurable eolstrg;
   *)
(* 3.0N = 3.03
   Change "too big for" to "larger than"; x
   Fix Falcon menu button alignment; ?
   Shift-space w/o block = space; x
   Add savecheck for closebutton as prg or MDX; x
   Remove "Really want to Quit?"; x
   Add Cancel option to text/hack alert; x
   Fully clear both kbd buffers when arrow keys are hit (too slow); no
   shift-alt-F weirdness??;
   *)
(* 3.0M
   Fix mouse/menu/blockmark w/CrazyDots; (* they just needed fixed driver *)
   Fix multitos kwiksend (2-loop delay: 1CBC0002); x
   Fix Spelling Sentry problem (mult events); x
   *)
(* 3.02 3.0K
   Cancel from loadbigfile in (Neo) passedfile no longer opens EdHak; x
   Add NeoACC capability; x
   Fix Delete-to-end display bug; x
   Shift-clr-home cursor to bottom of single screen buffer; x
   Fix crash if > 128 cols displayed, VDI limit!; x
   Re-Fix wrap/fill bug w/long lines; x
   Change nonclipboard names to BLOCK.TXT from SCRAP.TXT; x
   Bigger display fonts (use SetPointChar); mono x, color x; x
   Notichar font size; mono: x, color: x
   Blit horiz scroll; x
   Fix blank line and block display when startcol > displaylen; x
   Fix display with cursor scroll below window (setclipfill routine): x
   Fix undeletable file problem (double open in mergefile); x
   Remove shift-space no-block warning; x
   *)
(* 2.40/3.00
     3.0C
   3.01 = 3.0E
   Warn? about no colblk print, save, upload, kwiksend;
   Fix left click fall through in TOS 1.0 from Config menu; ??
   Adjust blockend and keep showing block after ctl-space; x
   Fix Showblock when col block is beyond window; x
   Add blockalert if copy non-block; x
   Don't bother clearing wind after 1st cfg screen; x
   Fix block dialog (firstitem=0 not -1); x

   3.00 = 3.0C
   Fixes menu dropthrough, adds shiftblk help items, blockalert if no
   block when try kwiksend, default no bypass clipbrd set, no block ops
   on unmarked blocks.

   Adjust blockend after shiftblk right; x
   Fix block ops when no block hilited; x
   Fully cancel font & clipbrd from config cancel (enough stack?); x
   Fix autokwiksend with held Block... menu (Waitup); x
   Fix possibility of 8x16 font in med res; x
   Resource (delete menuborder, add fontsize, expand Help, fsel?); x
   MultiTOS kwiksend from PRG?; x
   Allow kwiksend from PRG; x
   Fix biginc => dec above maxblock (only if allow buffsize=0); 
   Fix non-redraws sometimes after setting font (update:=); x
   Set window title before opening; x
   Retain mouse when open-write/create to write protected disk; x
   Better alert if fill edit buffer; x
   Redraw after cancel getblocknum; x
   BlkQuote; x
   BlkShift Right; x
   BlkShift Left; x
   Fix startf/endf/getblocknum/viewmem/diskopen incompat; x
   Allow Shifting in Disk sectors (PageDisk); x
   Allow Shifting in RAM; x
   Show user any truncation of typed-in value in GetBlockNum dialog; x
   Global startfileblk, startramblk, startsect; x
   Merge & Save block no longer require clipbrd dialog; x
   Block menu, NOTE new maxitems => new bssbaselen!!!!; x
   Omit Shift Alert, but add Pastebuffer save option; x
   Change to machine code RWAbs() code to get rid of 'Write' conflict; x
   Alert for bad save cfg; x
   Better macro display/pick; x
   Allow nulls in macros (use last char as size); x
   Reposition cursor to end of macro insert; x
   Keyboard font inc/dec alt-[+], alt-[-]; x
   Shift-F4 = copy normal block; x
   Move window mostly off screen (bottom & right edges); x
   Fix highlighting negative col block; x
   Fix typing past rt edge of window in overwrite mode; x
   Shift-Ins = paste normal; x
   Ctl-Ins   = CopyBlk (= shift-F4); x
   Ctl-Del   = Delete (= Cutblock if isblock); x
   Column blocks:
     copy to buffer; x
     paste from buffer; x
     delete; x
     copy to clipboard; x
     paste from clipboard; x
   *)
(* 2.39
   variables freed up (to be renamed/reused):
     blocknum => keep as temp global.
     oldblock => startfileblk
     priorlinelen,nextlinelen (2)diary.def => startramblk, startsect
     junkadr (was double local newlnptradr)(4) => neoptr or neoadr; (3.02)
     isblock (1 byte)=> ismdx (3.0N)
     vfntad (4)=> procptr (for neo listfiles)
     res (2)(can just use local var when set screenadr) => neoID (3.02)
     useme1 => defrowH (* 3.0n *)
     useme2, useme3 (2) in Diary.def => ?
     vfntadptr (4) => startfold (3.2B)
     fnthdadr, sysfontoffset (4) ? ? ?
     maxX (2) (can just use fullW)=> blocktype (0=none,1=normal,2=column)
     vfntwd (2)=> colW (INTEGER)
     colW (const 8) => colW (INTEGER, to allow smallest system font)
     Height/Width/Char/Font (2)=> fullX,fullY,fullW,fullH
     topdispline (2) => lastcol
     defcharht?? (keep, needed to set font)
   Fix nondisappearing s/replace dialog if cancel after viewmem; ?
   Fix viewmem buffer => ram function (loop exit); x
   Allow buffer=>ram block to any ram address; x
   Variable window size/resize/move off left edge; x
   Proper config handling for variable window; x
   Horiz Scroll Bar (still could use blitting); x
   Horiz scroll while typing only shifts 10 cols, instead of full window; x
   Fix Bottom (bug in all earlier versions) for extended lines; x
   Multiple Font Sizes (shift-alt-F); x
   *)
(* 2.38
   Clear KBD buffer after each kbd arrow scroll (use kwiksend method); x
   Fix menu alignment for TOS 4; x
   Fix MultiTOS drag/scroll stopping & TOS1.04 mouse/cursor vibrating; x
   Allow background MultiTOS scrolling; x
   Let menu drop ok with MultiTOS (AND vs = rect2 event); x
   windupdate in module resource; x
   *)
(* 2.37
   Replace 'Clear Thinking' with Douglas Communications;
   Fix Date/Byte insert commands (kreturn=0) to not do cr's with new file; x
   Fix lockup when save block to sectors (add fsel0ret); x
   Put LF at end of printout; x
   Remove final CR/LF output if going to midi; x
   *)
(* 2.36
   Set stack=0 prior to super() call in kwiksend; x
   *)
(* 2.35
   Refix scroll for 2.06, since applread in msgevent totally locks up 2.06; x
   Added handling for STalker 'Invoke STeno' call; x
   Fix disappearing mouse with kwiksend; ? (got rid of redundant MouseOn)
   Fix crashing with kwiksend into Calamus; ? (moved strip alert)
   Fix wrapping at end of pgraph with spaces at end of line; nope
   Fix windopen into Flash; x
  6/25/92
   Fix timer event not to drop menu when not top window; x
   Fix cursor residue when close acc window; x
   Fix redraw not happening after full/half window then top; x
   Fix menu dropping down even when not top window; x
   Fix double-scrolling of 2.34; x
   Continuous scrolling on TOS 1.0/1.2 (after slow double-click); x
   Fix Help screens for low/med res; x
   Fix check for write-protected file on save block/file (from 2.33); x
   Get rid of excess WriteErr alerts; x
   Fix disappearing Menu button when cancel Launch from selector; x
   Fix crashing when try Launching non-prg or can't find; x
   Fix setting & displaying buffer size > 1023K; x
   Allow bypassing clipboard on block save/merge; x
   Fix initmenu after setclipbrd; x
   Get desktop menus to work after Launch (nope, but run other prg does it);
   Set path at init time so setclip or launch doesn't just get **.*; ?
   *)
(* 2.34
   Add timer event for TOS 2.06/3.06 acc scroll bar compat;
   *)
(* 2.33  4/9/92
   Fix full disk non-error introduced in 2.30; x
   Try using Open instead of Sfirst; x
   Add WantAbort to Find, Searchload; ?
     (from PRNTALL abort check)
   Try fix TOS 2.06 click bug; ?
   Fix fileend bug in Loadfile; x
   Fix filename/paths in failed search/load file; x
   Setting ok to FALSE for all non Alt-X quits (4/10/92); x
   *)
(* 2.32
   Fix Savecheck to do save if last = 0 & bigpart; x
   Find crashing bug when 2 copies are loaded backtoback & quicksend
     into STWriter (probably setdta); ?
     Try set/reset dta before/after each SFirst 3/29/92 works; x
   Fix cfg.fsel0 and cfg.oldpath when file not found; x
   Fix redraw full/half/movedown/moveup; x
   Fix non-redraw of Menu button on canceled Save w/window at top; x
   *)
(* 2.31
   Fix force pastelen:= 0 when delete eol (linptrs() uses pastebuffer); x
   Put shift status in high byte of kwiksend kbdbuffer for Tempus; x
   *)
(* 2.3  first to sell for $29.95 instead of $18.95
   1/8/92 best Stalker mouse handling yet: after initial 'trailing' works
     almost perfectly. (trails only when scroll during autoappend)

   Fix infinite loop when searching changed bigfile to alt save-as; x
   FIX paging on search/load; x
   Fix H.Wolfe bigfile bug (having < overlap in buffer when shift); x
   Menu access to Midi 'upload'; x
   STalker support (moved IF closer to start of loop 12/12/91); x
   STalker auto-append; x
   Hex conversion; x
   Scrap handling (w/block save & merge); x
   Set Scrap path at will (shift-alt-C); x
   QuickCIS F4 exit (shift-alt-X)(had but lost! refix); x
   Initial delay in Kwiksend; x
   Strip cr/lf in Kwiksend; x
   Abort Kwiksend; x (instantly 1/1/92); x
   (discover Tempus uses TOS kbd buffer, but only high word of keycode)
   Update date/time stamp on appended file; x
   Shift-alt-A = append, no questions; x
   Shift-alt-S = save, no questions, no bak unless in cfg; x
   Fix *.**.*... on multiple launch prg & set clipbrd path; x
    Refix to give *.* for LGFselector; x
   Fix Launch return to acc by putting Lineptrs call before Setslides; x
   Fix Launch return to acc w/o GEM menu function;
   Disable alt-k exit from prg; x
   Fix hack mode delete single char line; x
   Fix up hack mode backspace twice to new line skipping char; x
   Fix disappearing mouse per Pete Thomas; ??
   Fix crashing upon Wrap All, introduced in 2.30; x
   Loading of zero length files; x
   Fix case sensitive search/load & pagebigfile in Find; x
   Handle too many windows open; x
   Fix filespec handling: x ; cancel from save: x ; 
   Mouse disappears/reappears when using keyboard/mouse; x
   Cursor changes to underline for overwrite mode; x
   cfg.autoindent toggle (Alt-Return) 1/15/92: x ; extended lines (1/19): x
   cfg.eurodate / US date: x ;
   cfg.hexdisp, decimal vs hex option on hack status bar: x
   Increase path lengths (& stacksize); x
   delete to end of line (Alt-Delete); x
   remember small window position, cfg.smalltop; x redraw better x
   Stalker 'redraw' w/overlapping windows; x
   Fix Stalker crashing if EdHak hasn't been opened since reboot (noVDI); x
   Fix Stalker crashing sometimes on opening EdHak after capturing; ?
   Fix replace final CR/LF w/CR then BS crash; x
   Fix redraw after replacing CR/LF; x
   Pattie fix to Wrapblock (* 1/19/92 *); x
   Fix cursorpos for Stalker capture (1/20/92); x
   Fix mouse better for Stalker: x

   Check enough handles for creating Window3 v.G 1/21/92; x
   Use vdihandle to tell if is a valid vdihandle! x

   New Config dialogs to add autoindent, eurodate, hexdisp, autowrap; x
   Update Help screens (use dialog box); x
   Remove hackable test, just do sector write caution; x
   Let user find EdHak.acc/prg for new buffer size; x
   Use dialog for selecthead; x
   Redo loadfile/mergefile redraw handling for no windclose; x
   Kwiksend option in menu quit routine; x
   RESTORE REGISTERS after all ML GEMDOS/BIOS/XBIOS calls!!; x
   Fix H.Wolfe no-window save existing file crashing (my own DTA); x
   H.Wolfe TT DA window-halving reloc to top of screen (force new cfg); x
   Fix redraw upon initial merge; x

   Fix +2 for cr/lf on stalker line input; x
   Add goto line # (alt-G) 2/1/92; x  Goto offset; x
   Fix redraws, e.g., tabset, after a Read/Merge; x
   Fix mouse disappear after About EdHak with EdAcc open; x
   Refix losing mouse on closed scrap.txt fill/save in Stalker; x
    (was only if EdHak hadn't been opened since reboot)
   Fix mouse arrow clone when topping window with mouse in slider area; x
   (* Start 2.30I: *)
   Fix menu/redraw when open/top acc w/mouse on menu button; x
   Fix cursor/menu redraw glitch; x
   No strip multiple cr/lf in Kwiksend; x
   Don't let menu drop when capturing Stalker; x
   QuickCIS mouse interaction fixed by Jim Ness in final QC 1.70; x

   Make alt-A append, shift-alt-A append no query; x
   Make shift-alt-K kwikedhaksend as with QCIS; x
   Add Alt-E, Alt-A, shift-alt-A to Help screen; x
   Fix mouse clone on kwiksend from 1/2 window (2/8/92); x
   (* start 2.30J: *)
   Add Ctl-Arrow to Help screens (2/9/92); x
   Fix helptre1 (files) w/recreate; x
   Use keytabl for full keycode in kwiksend; x RELEASE VERSION 2.30, WAUG
   Fix leftover cursor when halve window, using display & no update; x

   Allow paging disk or RAM;
   Incorp DCoffset into GEMX;?
   Continue search of disk or RAM beyond buffer;
   Use -1 menuregister call to set AES name = 'EDHAK   '; works
   Speed up retab & multi-replace?
   *)
(* 2.26
   *)
(* 2.25 10/2/91
   Output to Midi port; x
   Bigger Stack (640 byte, needed for search/rep/pagebigfile loop); x
   Paging a bigfile maintains buffersize-2K (or 1K) at ends of file; x
   Continue search of bigfile: x
   Extended RAM search on find; x
   Force tabspaces >= 2, so can't crash with tabspaces = 0 or 1; x
   Add SaveCheck to ClearBuffer; x
   Fix redraw after cancel from Replace/Query/Found dialog; x
   Fix tab <> spaces routine for line starts; x
   *)
(* 2.24 9/26/91
   Stop DeleteChar from adding to pastebuffer & ruining prior contents; x
   Fix bssbaselen, which has been wrong possibly since 2.13! x
   FIX! inter-program address/length passing hooks, both directions; x
   Add slide setting etc inits to received from acc routine; x
   Tab to space conversion; x
   Space <=> tab conversion; x
   Fix mouse redraw under ALL conditions (including Launch); x
   *)
(* 2.23 9/21/91
   Fix Alt-A hooks to be DIV/MOD 010000H instead of 0100H !!; x
   *)
(* 2.22
   Fix mouse disappearing in ViewRam. x
   Fix mouse disappearing in Search/Rep with no founds. x
   *)
(* 2.21
   Fix crash on BS or Delete into block (make BS/Del do block delete). x
   Fix redraw after Search/Rep with no founds. x
   *)
(* 2.20  9/5/91
   Fix redraw screen on cancel from Replace alert box (Query/All/Canc). x
   no: BCosStat (w/timeout) before each char output to printer or modem.
   Retry/abort for print/upload device not responding. x
   Esc/Undo anytime during print/upload. x
   Force CR after upload as well as print. x
   Provide buffer/block passing protocol for QuickCIS. x
   VDI text output & TT compatibility! x
   Change line/col counters to start at 1 instead of 0. x
   Treat keypad Enter same as normal Return. x
   Kwiksend CR/LF as Return key instead of ^M ^J. x
   *)
(* 2.14
   Fix to again allow ctl-J entry of linefeed char; x
   *)
(* 2.13
   Fix Find(new) to start at next index if same findstrg; x
   Properly decipher incoming CR followed by LF in txt mode; x
   Default Find/Pick buttons in ViewRam/(&Loadbigfile?); x
   Install Kwiksend, Alt-K from acc; x
   *)
(* 2.11
   Fix DiskOpen to do more than 50 megs, w/different sector/cluster sizes; ?
   Fix mouse to busy bee during disk & other searches; x
 (* 2.12 *)
   Modify DiskOpen to work in clusters rather than sectors??;
   Rename BAK to Orig when disk write/full error occurs (3.0?); x

   Hex conversions either direction (for 3.0 release?);
   Modifiable window widths (& maybe heights);
   Bottom slider?;
   CFG additions:
     Date options in cfg; ?
     marks;
   warning about loss of cut block on first delete attempt;
     (( add newblock boolean var to check & clear ))
   able to search entire bigfile after it's loaded;
   Tab conversion;
   goto line #;
   Delete word (ctl-del);
   Delete to end of line (shft-ctl-delete);
   Auto-adjust bookmarks with all deletions/inserts;
   Better Help screen layout;
   Memory handling by blocks for FAST insert/delete ? ;
   Enhanced srch/replace utility (SR10);
   Quick save of bigpart if size unchanged;
   Allow other eolstrg besides CR/LF;
    (just do global replace to get to/from cr/lf)
   Allow finding DIARY file to save buffer size;
   Position Find/Query 'Alert' not over found text (& allow key cmds);
    (can handle by user using a fulled window)
   Edit/Save Degas pic;
    (launch ARTST)
   make mouse arrow disappear (or move out of way); ?
   block copy (& move?) commands;
   *)
(* 2.10    23 Jan 1991
   Fix macro display & macro block highlight; x
   Fix Bigfile shifting to display first block properly (newly); x
   Set saved:= TRUE after any successful PageBigFile; x
   Fix Find casesens after done with a search; ?
     (By keeping findstrg uncorrupted in MyLib Find() routine)
   Fix changing default findbtn in GetStrg; x
   Rename "Can Hack Disk" to "Full Hacking" (need to do it in RSC); x
   Fix del line at last screen w/299-301K, 598-602K buffer...; x
     ( by making all the 4*line# = 4*LONG(line#) )
   Combine InitStrg & InitObjStrg; x
   Fix buffer size & cursor offset displays for > 99K; x
   Combine Pwr with Cardtostrg to save a little space; x
   Speed up Lineptrs with machine code; x
   Fix a couple more little bugs with > 64K files (wordwrap); x
   Add 1900 to new 4-digit year date; x
   *)
(* 2.09
   Make Date:  DD Mon YYYY; x
   Fix use with GOGO ST & tos 1.0 (& DC Desktop, Superboot..?); x
     (problem was AES window calls in Init:ClearAll)
   Fix deletes vs block functions & initial line 0 undo; x
   Recognize that cut/paste blocks make saved = FALSE; x

   Make Kwiksend from Alt-K for PRG & ACC; (for 3.0) x
   4-byte char indexes to go beyond 64K buffer limit; (for 3.0?) x
    (* 97K until fix 5 digit card display limit *)
    (* lnptrarray will need to be twice? as big, & newlnptrarray for wraps *)
   *)
(* 2.08
   Revised Kwiksend using VBL interrupt, ANY length block send;(for 3.0) x
   *)
(* 2.07
   Show Degas pic; x (wait for 3.0 to release)
     User interface for show pic; x
   Kwiksend block to application using KBD buffer; x (wait for 3.0 release)
     (4 bytes per char! uses both lnptr & newlnptr areas);
   Fix (by comparing) open or reopen routine for Flash; x
   Metered Upload; x
   DD Mon YY date; x
   *)
(* 2.06
   auto adjust bookmarks with some deletions; x
   Call ACC with std msg pipe extension & add forcefull for QuickCIS; x
   *)
(* 2.05 (* first batch of 30 copies to Pacific *)
   Fix bigfile shifting again (proper backshifts); x
   Add Buffer & Cursor offsets to cfg display; x
   Fix Goto marks when they're beyond last; x
   Works with MonSTEr & Moniterm! (use logical scrn); x
   Incorp Move() & Arrow() directly into Message case routines; x
   *)
(* 2.04 (* first batch of 50 copies to American *)
   Fix more search/replace at end of file; x
   Fix shifting last when toggle txt/hack; x
   *)
(* 2.03
   Remove MailPrint routine accidentally left in 2.01? & 2.02; x
   Change ViewRam default to Pick from Find; x
   *)
(* 2.02
   Encryption warning for bigfile & append; x
   forcefull window for QuickCIS; x
   no autoload for QuickCIS; x
   Default open disk to Pick; x
   Fix menu extra click/ding; (all TOS's?); x
   Clarify ViewMem write dialog; x
   *)
(* 2.01
   Fix edit then shift in bigfile (revise fileend, endf?); x
   Fix disappear mouse when autoload at bootup (not MultiDesk); x
   Change default from Find to Pick when load bigfile; x
   Fix search/rep bomb on replace of last char with nothing; x
   *)
(* 2.0H = shareware 2.0R
   Double-wide fast display (non-rsc text) menu; x
   Fix Esc from Help and Config; x
   Use F9 for showmacros instead of Alt-N; x
   Fix Replace with shorter string messing up end of buffer; x
   Make work with Install Application; x
   Make new menu compatible with TOS 1.4 (remove excess eventmulti); x
     (just problem if Launch from menu with wide file selector)
   Allow finding rsc file of Launched prg; x
   autoload/findbigfile not screw up when/if try to display; x
   Fix last line pointer in hack mode for large file; x
   Many optimizations, including GEMDOS machine code routines, Savefile; x
   Fix wrap, lnptrs, and lineout in hack mode including for 64K file; x
   Add Free RAM status, Save and casesens defaults to cfg display; x
   Fix RuinBlock in overwrite mode; x
   Fix to allow Adding in overwrite mode; x

   Better mouse initialization on or off; ?
   *)
(* 2.0G
   Better/faster block highlighting; x
   Fix highlighting of extended lines from many prior versions; x
   Fix shift-leftarrow in extended line followed by editing; x
     (e.g. delete = shiftdelete or type char = overwrite & screw lnptrs);
   Fix RuinBlock when deleting char in mid-block; x
   *)
(* 2.0F
   Even more GEM-look menu, single-wide; x
   Combine some bigfile save code into WriteRemains; x
   Scroll in bigfile!!; x
   Bar arrows take you to i = 0 or last if on line 0 or lastline; x
   Fixed redraw when window is not top and less than maxdispline lines; x
   *)
(* 2.0E
   Allow Launching other program, with proper screen redraw; (mostly)
   Allow passing filespec to Diary as command tail in basepage; ?
   Force mouse reset many places to avoid losing mouse; x
   Fix Fselect to only change cfg.fsel0 & cfg.path when appropriate; x
   New standard (highlighting) GEM-look menu, double-wide; x
   Fix GOTO's, since block markers change with any Delete; x
   Fix Wrap problem on indented last line, introduced in 2.0B; x
   Fix Wrap in extended window; x
   Fix Add into extended window; x
   Shorten by combining Add & Insert into AddInsert; x
   *)
(* 2.0D
   fix running as PRG from floppy-booted system (add MShrink); x
   fix to allow search/loading by hex or decimal srch string; x
   Replace all ResourceGetAdr calls with treeptr:= TreeAddr^[tree]; x
   Split OK/Cancel buttons out in config dialog; x
   Change Alt-Z to Alt-Upload; x
   More path fixes, from MultiDesk;
   *)
(* 2.0C
   autoload path fix; x
   fix crash if autoload bigfile; x
   fix autoload in hack mode by forcing text mode; x
   ClearAll clears title to default; x
   allow esc from mid-Help & mid-config; x
   config dialog box; x
   re-integrate diary & edhak with config option; x
   fsel config stuff; x
   fix bombs when quit from prg; x
   fix tab wraparound end of line; x
   fix search for '$'; x
   dialog box picking of txt, hex, or decimal string; x
   fix GetDrv call on bootup to be in EditProc init code; x
   *)
(* 2.0B
   Word wrap:  new paragraph can just be a space at start of line; x
   Word wrap:  wrap block instead of wrap line choice; x
   Word wrap:  correct handling of periods at end of lines; x
   Word wrap:  fix prior bug in Wrap All when less than 4 lines of text; x
   Faster Scrolling (the improved clipping had slowed it down, and this
     makes it as fast as it had been before that); x
   *)
(* 2.0A mail list printing for Craig; x
   search/load bigfiles; x
   search/load disk sectors; x
   shift-click extends block; x
   non-repeating 'menu' click; x
   fix capslock possibilities: delete, funckeys,...; x
   fix setfoundpos bug for line 0 when not in window; x
   alert if try saving file as an existing foldername; x
   adjust ruinblock one byte back; x
   goto startblock or endblock; x
   fix clipping top/bottom edges; x
   *)
(* 1.9C run as prg or acc; x
   Fix Macro Set/Truncated notice; x
   refix remembering of window position on screen after closing; x
   refix saving bigpart file which save w/BAK screwed up;
   disappearing mouse w/ 2 window search or new config; x
   mouse droppings w/ 2 window search; x
   default merge filename = BLOCK.TXT; x
   Make compatible with UniTerm (as long as close when switching modes)
    This required moving screen init to InitWork to deal with
    an application that relocates the screen; x
   Change Ctl-arrow to be word left/right & shft-ctl-arrow = edge of wind; x
   Make SetFoundPos (& viewmem) set to next-to-top line instead of top; x
   Fix crash when hit F6 before setting a Find string; x
   Make Moniterm compatible?; x
   Remove floating point slider routines; x
   Title becomes 'RAM: 00NNNK' for viewmem; x
   Title becomes 'D:sec:000NN' for disk edit; x
   Fixed wrapW when first open w/cfg for hack mode; x
   Stopped forcing autowrap for viewmem (which fixes Wrap Alert bug); x
   Fixed kperblock for 64K buffer (now 62K instead of 63K); x
   *)
(* 1.9B delete "Working" after global replace; x
   Fix "buffer full" msg on increasing srch/rep w/65536 byte buffer; x
   disappearing mouse if fail autoload; x
   set slider after encryption; x
   Make macro #10 be printer setup string (boolean in config); x
   Shft-Cntrl-Arrow = cursor to next/prev word; x
   Add overwrite/append default to config; x
   Save w/BAK; x
   *)
(* 1.9A Fix saving config w/o new buff size, doesn't zero buffer size!
   Fix mouse access to i > 0 when i = 0 in Hackmode, (Findend routine);
   Add Alt-M to Help screens;
   Add output to serial port (Alt-Z, or menu2-Zap);
   Change VDI keyboard shift key status to BIOS status check;
   Add window size to config record;
   Fast machine code search routine;
   *)
(* 1.8E Make lnptrarray & newlnptr array adjust automatically with buffsize,
   (results in more lines for given buffer size & bigger cut/paste buffer);
   Fix mouse/block selection speed loss when near end of large file;
   Auto-update wording of lines 2 & 3 of block/buffer size selection dialog;
   Fix Tab Space dialog;
   Read/Edit/Write any range of disk sectors that will fit into edit buffer;
   AutoLoad a default file of user's choice on bootup;
   Revise/update Help screens;
   Alt-I = Insert bytestring (text or hex);
   Fixed bug not allowing undo of deletion of 1st char after bootup;
   Better macro instructions/descriptions via menu entry;
   *)
(* 1.8D Fixed accopen debug stuff I forgot to remove!;
   Get configurable buffer size that handles resolution changes;
   Fix bug introduced by Flash on-line mode fix, so leaving Diary open
   should not crash Flash or fail to redraw when not the top window;
   Save txt/hack mode instead of resetting when opening new file;
   Save eolchar when go into hack mode so it's there when return to txt;
   Alert when run out of disk space while saving file;
   *)
(* 1.8C fix config to include filename/path (delete declarations in MOD);
   Fix clipping with showblock so it block doesn't show over higher window;
   Output esc char with alt-esc (as well as standard ctl-[ );
   Fix mouse block select/scroll, cursor and i were not positioned right;
   Make window open/top work right from Flash - draws slider completely;
   No lock-up after returning from Flash on-line mode and reopening Diary;
     (try that with STeno or Notepad!)
   Window redraws correctly even if opened/topped with mouse on menu button;
   Set Slider after inserting a macro;
   *)
(* 1.8B Menu 2 for various config, encrypt, & hack options;
   Set right wrap column;
   Set left print margin;
   Set tab spaces;
   Insert Date;
   Line/Col display in text mode; n/char display only in hack mode;
   Notices shown separately at own location in hi & med res;
   Fixed block print error introduced in 1.8A;
   Macros!
   Fix slide positioning after merge;
   *)
(* 1.8A Fast text output via assembly lang routines to write direct to scrn;
   By handling cursor myself, it's QuickST compatible;
   Fixed word wrap of lines with no spaces;
   Now erase and replace cursor when do Ctl-Arrow;
   Shift-ClrHome acts like ClrHome when in top window of buffer;
   *)
(* 1.7C reset wrapW and bigpart when clear buffer;
   fix printing of extra char at end of printout;
   add Replace to Find options and to menu;
   Hex string search/replace;
   Alt-X = Quit w/o query;
   FIX All wordwrap in Text and Hack modes;
   fix loss of mouse in F4/F5/F6;
   *)
(* 1.7B Handle full display/editing of files/memory chunks with no eol chars;
   Alt-T = toggle text (cr/lf) mode;
   Change F2 (blk end) to extend block when i < blkstart;
   display char offset & value;
   change overwrite tab mode to skip over spaces to next tab stop;
   fix loss of mouse when hit esc or F10;
   Encrypt; View/FindMem;
   fix wrap when cursor is at end of line;
   fix double \\ when Diary is loaded from a folder with Atari item selector;
   menuregister with 3 rsc trees registers in editproc init code,
   thus always putting it at top;
   block color left at default red *)
(* 1.7A smaller by 600 bytes by replace MouseOn/Off with lineA functions,
   Make more QuickST compatible by replace XBIOS ConfigureCursor with
   VT-52 curson/off (still partial mouse droppings though),
   Add LF to print, Fix mouse droppings on pageup/down, fix windowfull. *)
(* 1.6D Select block with mouse, hi-lite selected block, shift screen with
   mouse click at edge of window, fix startcol when opening new file, fix
   drag mouse over scroll bar with extended line, fix wrap routine again,
   fix Find again in extended line, display toggled 'cr' immediately. *)
(* 1.6C 5 digit blocknum, Alt-M, ShiftScrn!, better bigfile handling *)
(* 1.6B Insert (merge) file, Reduce size by 12K!! *)
(* 1.6A Insert/Overwrite notice, hard tab columns, toggle 'cr' display,
   Fix Find & bigpart dialogs when lots of underneath windows *)
(* 1.5D save block & automated saving of big file portions, fix Find OK box,
   Fix, again, color scrolling, add 'No Marks' notice, 10K buffer *)
(* 1.5C fixed Close file bug, load portions of files, save/append;
   discovered Find OK box won't exit with Return key, no matter WHAT. *)
(* 1.5B non-ASCII keyboard input *)
(* 1.5A non-ASCII char output *)
(* 1.4B Find + fix double menuism, 14A print block *)
(* 1.3 more blits, more TurboST compat, undo of deletes *)
(* 1.21, fixes display bug *)(*full window,(reconfig),blits,blocks *)

(* Add these for (embedded) rsc file *)
  IMPORT SYSTEM;
  IMPORT AESResources;

FROM SYSTEM IMPORT ADR, ADDRESS, CODE, REGISTER, PUSH, SETREG; (*, BYTE,LONGWORD,PUSH *)
FROM Mylib IMPORT (* Cardtostrg, *)(*ds*) Find, (*ds*) MoveMem;
FROM GEMX IMPORT BasePageAddress; (* was pointer to BasePageType *)
FROM XBIOS IMPORT GetResolution, ScreenLogicalBase;
FROM BIOS IMPORT (* BCosStat, BConOut,*) BPBPtr; (* GetBPB, RWAbs, RW *)
     (* BConStat, BConIn, Device *)
FROM GEMDOS IMPORT (* Delete, SFirst, GetDate,*) Super, SFirst, DirCreate,
     Write, Create, Close;
     (* GetDrv, GetPath, Exec, ExecMode, Free, NecIn, Alloc, Shrink, Rename *)
FROM EdPro2 IMPORT Display, SetSlidePos, SetSlideSize, SetHSlidePos,
     Scrolldown, Scrollup, Rtarrow, Leftarrow, Downarrow, Uparrow, Compare,
     AddInsert, (* Overwrite, *) DeleteChar, Backspace,  Lineptrs,
     Readfile, Writefile, Findend, DeleteLine, Blit, CheckStart, FullAlert,
     (* MakeBak,*) Bottomstay, Bconout, Bcosstat, BconinGetBPB, Kbshift,
     Graphictext, Lineout, DelToEnd, FileAlert, Redraw, SetHSlideSize,
     Findxpos, Finddispline, Min, Max, Conzap, ScrnLeft, ScrnRt,
     Findscrn, Findline, Downup, CursorDraw, CursorPos, SetClipFill,
     TypeInit, TypeAhead, Showmouse, (* ShowCursor, HideCursor, *)
(*ep*)
     WriteConfig, ReadConfig, ChangeCase, BlockAlert,
(*ep*)
(*ds*)
     Wrapblock, Cutblock, Pasteblock, ShowBlock, RuinBlock, Mergefile,
     Copyblock, Copycolblk, Pastecolblk, Delcolblk, WriteErr;
(*ds*)
FROM VDIAttribs IMPORT SetFillInteriorStyle, SetFillColour, 
     SetFillPerimeterVisibility, SetPointCharHeight, (* 3.02 *)
     (* SetAbsCharHeight, *) SetWritingMode, SetGraphicTextAlignment;
FROM GEMVDIbase IMPORT VDIWorkInType, VDIWorkOutType, PxyArrayType,
     (* procs *) CallVDI, SetContrl,
     (* vars  *) contrl, intin, ptsin, (* intout, *) ptsout;
FROM VDIControls IMPORT OpenVirtualWorkstation, CloseVirtualWorkstation,
     SetClipping;
FROM VDIOutputs IMPORT FillRectangle, DrawBar;
(* FROM AESResources IMPORT ResourceGetAddr, ResourceLoad, ResourceFree; *)
(* FROM VDIInquires IMPORT InquireColour; *)
FROM AESObjects IMPORT ObjectDraw (*,ObjectFind, ObjectChange *);
FROM AESGraphics IMPORT GrafHandle, GrafMouse;
FROM Strings IMPORT Length, Concat (*, Assign *);
FROM AESForms IMPORT FormAlert, FileSelectorInput, FormCenter,
     FormDo, FormDialogue;
FROM AESApplications IMPORT ApplExit, ApplWrite, ApplFind, ApplRead, ApplInitialise;
FROM AESMenus IMPORT MenuBar,(* MenuItemEnable,*) MenuTitleNormal; 
FROM AESWindows IMPORT WindowCreate, WindowOpen, WindowClose, WindowGet,
       WindowSet, WindowDelete, WindowUpdate, WindowCalc;
FROM AESEvents IMPORT EventMultiple, EventMessage (*, EventTimer *);
FROM AESScraps IMPORT ScrapRead, ScrapWrite;
IMPORT GEMAESbase;
(*
FROM MathLib0 IMPORT real (*, entier *);
*)
FROM VDIRasters IMPORT MFDBType;

CONST  (* Object definitions in DIARYAC9.RSC from DIARYAC9.H *)
 NEOACCINI = 80;  (* How NeoDesk says hello to a DA *)
 NEOACCBAD = 81;  (* DA's pointer to Neo's info is no longer valid *)
 NEOCLIRUN = 82;  (* how Neo tells a CLI DA to run a batch file *)
 NEOACCEXC = 83;  (* tell Neo to run a program ARGS MUST BE STATIC *)
 NEOACCQUI = 84;  (* quit NeoDesk *)
 NEOACCTXT = 85;  (* tell Neo to show a text file *)
 NEOACCINF = 86;  (* tell Neo to load an .INF, .MAC or .NOT file *)
 NEOACCPAS = 87;  (* how Neo tells a DA that user has passed it files *)
 NEOACOPEN = 88;  (* nearly identical to GEM's AC_OPEN *)
 NEOACCMAGIC = 04321H;
 MAXNEOACC = 10;  (* maximum of 10 DA's can be used at once *)
 DUMMSG     = 99;  (* dummy message, used most often to ack an order *)
(* application types for NEO_ACC_EXC *)
 NOAPP = 0;
 PRG   = 1;
 TOS   = 2;
 TTP   = 3;
 BTP   = 4;

  MENUTREE = 0; (* menu bar these two added in DIARYACA.RSC *)
  DESKMENU = 3; (* desk accessory menu NEEDS TO BE ADDED TO RSC! *)
    ABOUT1 = 6; (* neither of these ABOUTs seem to be used *)
     ABOUT = 6; (* About Diary *)
(* EDPLUSB *)
  BLCKTREE = 1 ;
  BLOKTXT1 = 1 ;
  BLOKTXT2 = 2 ;
  BLOKTX2A = 3 ;
  BLOKTXT3 = 4 ;
  DECBLOCK = 5 ;
    BIGDEC = 6 ;
  BLOCKNUM = 7 ;
    BIGINC = 8 ;
  INCBLOCK = 9 ;
   BLOCKOK = 10 ;
  BLOCKCAN = 11 ;

  TEXTTREE = 2 ;
     TEXT1 = 1 ;
     TEXT2 = 2 ;
  TEXTSTRG = 3 ;
    TEXTOK = 4 ;
    TXTBTN = 5 ;
  TEXTCANC = 6 ;
    HEXBTN = 7 ;
    DECBTN = 8 ;

      CFG1 = 3 ;
  INSERTBT = 1 ;
  PRNTINIT = 2 ;
    SHOWCR = 3 ;
  AUTOLOAD = 4 ;
  MARGINSB = 5 ;
  SAVEWBAK = 6 ;
      TABS = 7 ;
   HEXHACK = 8 ;
    USDATE = 9 ;
    INDENT = 10 ;
  AUTOWRAP = 11 ;
  BUFFSIZE = 12 ;
   SETFONT = 13 ;
   CLIPBRD = 14 ;
    CFG1OK = 15 ;
  CFG1SAVE = 16 ;
  CFG1CANC = 17 ;

  HELPTRE0 = 9 ;
  HELP0MOR = 13 ;
  HELP0EXI = 14 ;

  HELPTRE1 = 5 ;
  HELP1MOR = 2 ;
  HELP1EXI = 3 ;

  HELPTRE2 = 6 ;
  HELP2MOR = 10 ;
  HELP2EXI = 11 ;

  HELPTRE3 = 7 ;
  HELP3MOR = 13 ;
  HELP3EXI = 12 ;

  HELPTRE4 = 4 ;
  HELP4MOR = 2 ;
  HELP4EXI = 3 ;

  FSELTITL = 8 ;
  FSELSTRG = 1 ;

(**********************)
  (* File menu *)
  FILEMENU = 1; (* just for SelectMenu calls *)
      OPEN = 0 ;
      SAVE = 1 ;
      HELP = 2 ;
     PRINT = 3 ;
    UPLOAD = 4 ;
    NEWCFG = 5 ;
    MACROS = 6 ;
    LAUNCH = 7 ;
      QUIT = 8 ;

  (* Edit menu *)
  EDITMENU = 2; (* just for SelectMenu calls *)
   FINDREP = 9  ;
      WRAP = 10 ;
    INSERT = 11 ;
      DATE = 12 ;
  TEXTHACK = 13 ;
     BLOCK = 14 ;
   VIEWRAM = 15 ; (* changed to Goto 3.1C *)
   ENCRYPT = 16 ;
  CLEARBUF = 17 ;

(**
  FILEMENU =  4;
      SAVE = 18;
      READ = 19 ;
      QUIT = 20 ;
  EDITMENU =  5;
**)

  PRNTMENU =  6;
   PRNTALL = 27;

(*2.30*)
       clippath = 'CLIPBRD'; (* for dir create *)
(*2.30*)
       ext = '*.*';
       in = 0;  (* wait for mouse to be IN a block *)
       out = 1; (* wait for mouse to be OUTside of a block *)
       maxitems = 35; (* 17;*) (* 0.. 9 x 2 *)

       Select = 0;
  (* LineA offsets for Conzap fast char output routine *)
(* (* these 2 now in editproc.mod *)
  VCURAD    = -022H; (* -34 *) (* 4 bytes, current cursor address *)
  VCURX     = -01CH; (* -28 *) (* 2 bytes, current cursor column *)
*)
(* VCURY = -01AH; (* -26 *) (* 2 bytes, current cursor row, not needed *) *)
  VFNTAD    = -016H; (* -22 *) (* 4 bytes, address of monospaced font *)
  VFNTWD    = -00EH; (* -14 *) (* 2 bytes, font form width in bytes = sum of widths/8 *)
  VCELHT    = -02EH; (* -46 *) (* 2 bytes, txt cell height in pixels *)
  VCELMX    = -02CH; (* -44 *) (* 2 bytes, max chars across - 1 *)
  WIDTH     =  002H; (* 2 bytes, should be same as BYTESLIN *)
  BYTESLIN  = -002H; (* -2 *) (* 2 bytes, 80 mono, 160 color *)
  VCELWR    = -028H; (* -40 *) (* 2 bytes, bytes to next vert char cell *)

  DATATABLE = 76; (* offset in font header of pointer to font *)
  FORMWIDTH = 80; (* offset in font header of total font width, in bytes? *)
                     (* 192 for 6x6, 256 for 8x8 and 8x16 *)
  FORMHEIGHT= 82; (* offset in font header of cell height for that font *)
  (* BIGFONT   =  4;     (* offset from fnthdptr to pointer to 8x16 font *) *)
  VREZHZ    = -00CH; (* -12 *) (* 2 bytes, vert pixel resolution, 400/200 *)
  VREZVT    = -004H; (* 2 bytes, horizontal pixel resolution, 640/320 *)
  INTIN     =  008H; (* 4 bytes, pointer to intin array *)

  PHYSTOP   =  1070; (* decimal address of phystop *)
  
  (** Function Equates **)
  InitLineA =    0A000H;

(*
(* copy to start of module *)
 IMPORT WindowUpdate;
(* copy to after last FROM and before first CONST in MODULE resource *)
 EXPORT TreeAddr;
(* copy to just after BEGIN of main res *)
 WindowUpdate(1);
(* copy to just before END of module *)
 WindowUpdate(0);
(* and replace period at end of resource with semi-colon *)
*)
(*******************  EMBEDDED RSC FILE **************)
MODULE resource;
 IMPORT WindowUpdate;

(*
   Produced by ResourceMaker 0.10a
   Copyright (c) 1985, 1986 Modula 2 Software Ltd.
   Copyright (c) 1985, 1986 TDI Software Inc.

   Resource file version: 00000H
*)

  FROM SYSTEM IMPORT CODE, ADDRESS;

  FROM AESResources IMPORT ResourceObjectFix;
 EXPORT TreeAddr;

  CONST
    (* object types that don't have to be relocated *)
    GBOX = 20;
    GPROGDEF = 24;
    GIBOX = 25;
    GBOXCHAR = 27;

  CONST
    (* resource file object counts and indicies *)
    nrObjects = 144;  ixObjects = 5372;
    nrTrees = 10;  ixTrees = 8828;
    nrTedInfos = 74;  ixTedInfos = 3300;

  (* resource file data inserted into CODE stream *)

  (*$S-,$P-,$T-*)
  PROCEDURE RESOURCEDATA0;
  BEGIN
    CODE(00000H,014FCH,00CE4H,00CE4H,00CE4H,00CE4H,00024H,00CE4H);
    CODE(00CE4H,0227CH,00090H,0000AH,0004AH,00000H,00000H,00000H);
    CODE(00000H,022A4H,05175H,06974H,02077H,02F6FH,02071H,07565H);
    CODE(07279H,02020H,02020H,02020H,02020H,02020H,02020H,0416CH);
    CODE(0742DH,05820H,07C20H,0436CH,06F73H,06500H,00051H,07569H);
    CODE(07420H,07769H,07468H,02071H,07565H,07279H,02020H,02020H);
    CODE(02020H,02020H,02020H,02041H,06C74H,02D51H,0207CH,02045H);
    CODE(07363H,06170H,06500H,00041H,07070H,0656EH,06420H,06669H);
    CODE(06C65H,02028H,06E6FH,02071H,07565H,07279H,02920H,02020H);
    CODE(02053H,06869H,06674H,02D41H,06C74H,02D41H,00000H,04170H);
    CODE(07065H,06E64H,02066H,0696CH,06520H,0286FH,07220H,0626CH);
    CODE(06F63H,06B29H,02020H,02020H,0416CH,0742DH,04100H,0004DH);
    CODE(06572H,06765H,02046H,0696CH,06520H,06174H,02063H,07572H);
    CODE(0736FH,07220H,02020H,02020H,02041H,06C74H,02D4DH,00000H);
    CODE(05072H,0696EH,07420H,02862H,07566H,06665H,07220H,06F72H);
    CODE(02062H,06C6FH,0636BH,02920H,02020H,0416CH,0742DH,05000H);
    CODE(00055H,0706CH,06F61H,06420H,02D3EH,0206DH,06F64H,0656DH);
    CODE(0206FH,07220H,06D69H,06469H,02020H,02041H,06C74H,02D55H);
    CODE(00000H,0224BH,07769H,06B73H,0656EH,06422H,02062H,06C6FH);
    CODE(0636BH,02020H,02020H,02020H,02020H,02020H,0416CH,0742DH);
    CODE(04B00H,00043H,06C65H,06172H,02042H,07566H,06665H,07220H);
    CODE(02020H,02020H,02020H,02020H,02020H,02020H,02041H,06C74H);
    CODE(02D43H,00000H,04C61H,0756EH,06368H,02055H,07469H,06C2FH);
    CODE(05072H,06F67H,07261H,06D20H,02020H,02020H,02020H,0416CH);
    CODE(0742DH,04C00H,00045H,07869H,07400H,04D6FH,07265H,00053H);
    CODE(06176H,06520H,04669H,06C65H,02028H,06E6FH,02071H,07565H);
    CODE(07279H,02920H,02020H,02020H,02053H,06869H,06674H,02D41H);
    CODE(06C74H,02D53H,00000H,04669H,06C65H,02026H,02047H,0656EH);
    CODE(06572H,0616CH,00000H,05669H,06577H,02F45H,06469H,07420H);
    CODE(05241H,04D20H,02020H,02020H,02020H,02020H,02020H,02020H);
    CODE(0416CH,0742DH,05600H,00042H,07566H,06665H,07220H,0746FH);
    CODE(02045H,04449H,05450H,04C55H,0532EH,04143H,04320H,02020H);
    CODE(02053H,06869H,06674H,02D41H,06C74H,02D4BH,00000H,05365H);
    CODE(06E64H,02054H,07970H,06541H,06865H,06164H,0204CH,0696EH);
    CODE(0652FH,0426CH,06B20H,02020H,05368H,06966H,0742DH,05265H);
    CODE(07475H,0726EH,00000H,05361H,07665H,02046H,0696CH,06520H);
    CODE(0286FH,07220H,0626CH,06F63H,06B29H,02061H,07320H,02020H);
    CODE(0416CH,0742DH,05300H,0004FH,07065H,06E2FH,05265H,06164H);
    CODE(02046H,0696CH,06520H,02020H,02020H,02020H,02020H,02020H);
    CODE(02041H,06C74H,02D4FH,0207CH,02041H,06C74H,02D52H,00000H);
    CODE(04865H,06C70H,02120H,02020H,02020H,02020H,02020H,02020H);
    CODE(02020H,02020H,02020H,02020H,02020H,0416CH,0742DH,04820H);
    CODE(07C20H,03C48H,0656CH,0703EH,00000H,04669H,06C65H,02069H);
    CODE(07320H,06C61H,07267H,06572H,02074H,06861H,06E20H,07465H);
    CODE(07874H,02062H,07566H,06665H,0722EH,0004CH,06F61H,06420H);
    CODE(0626CH,06F63H,06B20H,06F66H,02073H,0697AH,06520H,0284BH);
    CODE(0293AH,02000H,03820H,02020H,02020H,00053H,07461H,07274H);
    CODE(0696EH,06720H,06174H,02077H,06869H,06368H,02031H,04B20H);
    CODE(0626FH,0756EH,06461H,07279H,0203FH,02000H,03C2DH,0003CH);
    CODE(03C3DH,00030H,03030H,03030H,0005FH,05F5FH,05F5FH,00058H);
    CODE(03939H,03939H,0003DH,03E3EH,0002DH,03E00H,04F4BH,00043H);
    CODE(0414EH,04345H,04C00H,05341H,05645H,02054H,04F20H,04649H);
    CODE(04C45H,02F44H,06973H,06B2EH,02E2EH,00045H,06E74H,06572H);
    CODE(02053H,07472H,0696EH,06720H,02020H,02020H,02020H,02020H);
    CODE(02020H,02020H,00054H,06578H,07420H,06F72H,02043H,06861H);
    CODE(07261H,06374H,06572H,02056H,0616CH,07565H,07320H,0005FH);
    CODE(05F5FH,05F5FH,05F5FH,05F5FH,05F5FH,05F5FH,05F5FH,05F5FH);
    CODE(05F5FH,05F00H,02020H,03D3EH,03E20H,05F5FH,05F5FH,05F5FH);
    CODE(05F5FH,05F5FH,05F5FH,05F5FH,05F5FH,05F5FH,05F5FH,00058H);
    CODE(05858H,05858H,05858H,05858H,05858H,05858H,05858H,05858H);
    CODE(05858H,05800H,04F4BH,00054H,05854H,00043H,0414EH,04345H);
    CODE(04C00H,04845H,05800H,04445H,04300H,04375H,07273H,06F72H);
    CODE(00000H,04D6FH,07265H,00045H,07869H,07400H,0546FH,0702FH);
    CODE(0426FH,07474H,06F6DH,0206FH,06620H,06669H,06C65H,02020H);
    CODE(02020H,02020H,02020H,05368H,06966H,0742DH,0436CH,07248H);
    CODE(06F6DH,06500H,00054H,06F70H,02F42H,06F74H,0746FH,06D20H);
    CODE(06F66H,02062H,07566H,06665H,07220H,02020H,02020H,02043H);
    CODE(0746CH,02D41H,07272H,06F77H,00000H,0546FH,0702FH,0426FH);
    CODE(07474H,06F6DH,0206FH,06620H,07363H,07265H,0656EH,02020H);
    CODE(02020H,02020H,0436CH,07248H,06F6DH,06500H,00054H,06F70H);
    CODE(02F42H,06F74H,0746FH,06D20H,06F66H,02066H,0696CH,06520H);
    CODE(02020H,02020H,02020H,02053H,06866H,0742DH,04374H,06C2DH);
    CODE(04172H,0726FH,07700H,00047H,06F74H,06F20H,04C69H,06E65H);
    CODE(02023H,0202FH,0204FH,06666H,07365H,07420H,02320H,02020H);
    CODE(02041H,06C74H,02D47H,00000H,0476FH,0746FH,02073H,07461H);
    CODE(07274H,02F65H,06E64H,0206FH,06620H,0626CH,06F63H,06B20H);
    CODE(02020H,0416CH,0742DH,03120H,02F20H,0416CH,0742DH,03200H);
    CODE(00047H,06F74H,06F20H,04E65H,07874H,02F50H,07265H,07620H);
    CODE(0776FH,07264H,02020H,02020H,02020H,02043H,0746CH,02D41H);
    CODE(07272H,06F77H,00000H,05061H,06765H,02075H,0702FH,0646FH);
    CODE(0776EH,02020H,02020H,02020H,02020H,02020H,02020H,02020H);
    CODE(05368H,06966H,0742DH,06172H,0726FH,07700H,00053H,07461H);
    CODE(07274H,02F45H,06E64H,0206FH,06620H,06C69H,06E65H,02020H);
    CODE(02020H,02020H,02020H,02053H,06869H,06674H,02D41H,07272H);
    CODE(06F77H,00000H,05374H,06172H,0742FH,0456EH,06420H,06C69H);
    CODE(06E65H,02069H,06E20H,07769H,06E64H,06F77H,02020H,05368H);
    CODE(06674H,02D43H,0746CH,02D41H,07272H,06F77H,00000H,04564H);
    CODE(06974H,02050H,06C75H,07320H,07620H,0332EH,03220H,02020H);
    CODE(02024H,03339H,02E39H,03500H,0436CH,06561H,07220H,05468H);
    CODE(0696EH,06B69H,06E67H,02C20H,03134H,02050H,06179H,06575H);
    CODE(07220H,0526FH,06164H,00000H,0416EH,06E20H,04172H,0626FH);
    CODE(0722CH,0204DH,04920H,03438H,03130H,03820H,05553H,04120H);
    CODE(03331H,0332DH,03937H,0312DH,03836H,03731H,00000H,0436FH);
    CODE(07079H,07269H,06768H,07420H,02863H,02931H,03938H,0392DH);
    CODE(03936H,02062H,07920H,04372H,06169H,06720H,0412EH,02048H);
    CODE(06172H,07665H,07900H,00020H,04465H,0736BH,02000H,02020H);
    CODE(04162H,06F75H,07420H,04564H,04861H,06B2FH,04469H,06172H);
    CODE(07920H,0002DH,02D2DH,02D2DH,02D2DH,02D2DH,02D2DH,02D2DH);
    CODE(02D2DH,02D2DH,02D2DH,02D00H,02020H,04465H,0736BH,02041H);
    CODE(06363H,06573H,0736FH,07279H,02031H,02020H,00020H,02044H);
    CODE(06573H,06B20H,04163H,06365H,07373H,06F72H,07920H,03220H);
    CODE(02000H,02020H,04465H,0736BH,02041H,06363H,06573H,0736FH);
    CODE(07279H,02033H,02020H,00020H,02044H,06573H,06B20H,04163H);
    CODE(06365H,07373H,06F72H,07920H,03420H,02000H,02020H,04465H);
    CODE(0736BH,02041H,06363H,06573H,0736FH,07279H,02035H,02020H);
    CODE(00020H,02044H,06573H,06B20H,04163H,06365H,07373H,06F72H);
    CODE(07920H,03620H,02000H,0426CH,06F63H,06B73H,00000H,05374H);
    CODE(06172H,0742FH,0456EH,06420H,0626CH,06F63H,06B20H,02020H);
    CODE(02020H,02020H,02020H,02020H,04631H,02F46H,03200H,00045H);
    CODE(07869H,07400H,04D6FH,07265H,00043H,07574H,02042H,06C6FH);
    CODE(0636BH,02028H,06275H,06666H,06572H,02920H,02020H,02020H);
    CODE(02046H,03420H,07C20H,04253H,0207CH,02044H,0656CH,00000H);
    CODE(05061H,07374H,06520H,0426CH,06F63H,06B20H,02862H,07566H);
    CODE(06665H,07229H,02020H,04635H,0207CH,02055H,06E64H,06F20H);
    CODE(07C20H,00149H,06E73H,00000H,04375H,07420H,0426CH,06F63H);
    CODE(06B20H,02863H,06C69H,07062H,06F61H,07264H,02920H,02020H);
    CODE(02020H,04637H,00000H,05365H,06C65H,06374H,02041H,06C6CH);
    CODE(02028H,04576H,06572H,07974H,06869H,06E67H,02920H,02020H);
    CODE(05368H,06966H,0742DH,0416CH,0742DH,04500H,00050H,06173H);
    CODE(07465H,02043H,06F6CH,02042H,06C6FH,0636BH,02028H,06275H);
    CODE(06666H,06572H,02920H,02053H,06869H,06674H,02D46H,03500H);
    CODE(00043H,06F70H,07920H,0426CH,06F63H,06B20H,02863H,06C69H);
    CODE(07062H,06F61H,07264H,02920H,02020H,02053H,06869H,06674H);
    CODE(02D46H,03700H,00050H,06173H,07465H,02042H,06C6FH,0636BH);
    CODE(02028H,0636CH,06970H,0626FH,06172H,06429H,02020H,02046H);
    CODE(03800H,00050H,06173H,07465H,02043H,06F6CH,02042H,06C6FH);
    CODE(0636BH,02028H,0636CH,06970H,06264H,02920H,02053H,06869H);
    CODE(06674H,02D46H,03800H,00043H,06C65H,06172H,02042H,06C6FH);
  END RESOURCEDATA0;
  (*$S-,$P-,$T-*)
  PROCEDURE RESOURCEDATA1;
  BEGIN
    CODE(0636BH,0206DH,06172H,06B73H,02020H,02020H,02020H,02020H);
    CODE(02046H,03300H,00043H,06F70H,07920H,0426CH,06F63H,06B20H);
    CODE(02862H,07566H,06665H,07229H,02020H,02053H,06869H,06674H);
    CODE(02D46H,03420H,07C20H,05E49H,06E73H,00000H,0456EH,06420H);
    CODE(0436FH,06C75H,06D6EH,02042H,06C6FH,0636BH,02020H,02020H);
    CODE(02020H,02020H,02020H,05368H,06966H,0742DH,04632H,00000H);
    CODE(04564H,06974H,0696EH,06700H,00044H,0656CH,06574H,06520H);
    CODE(04C69H,06E65H,02020H,02020H,02020H,02020H,02020H,02020H);
    CODE(02020H,02053H,06869H,06674H,02D44H,0656CH,06574H,06500H);
    CODE(00046H,0696EH,0642FH,05265H,0706CH,06163H,06520H,02020H);
    CODE(02020H,02020H,02020H,02020H,02020H,02041H,06C74H,02D46H);
    CODE(00000H,04465H,06C65H,07465H,02074H,06F20H,0656EH,06420H);
    CODE(06F66H,0206CH,0696EH,06520H,02020H,02020H,0416CH,0742DH);
    CODE(04465H,06C65H,07465H,00000H,04D6FH,07265H,00045H,07869H);
    CODE(07400H,0496EH,07365H,07274H,02F6FH,07665H,07277H,07269H);
    CODE(07465H,02044H,06174H,06520H,02020H,02020H,0416CH,0742DH);
    CODE(04400H,00052H,06570H,06561H,07420H,04669H,06E64H,02020H);
    CODE(02020H,02020H,02020H,02020H,02020H,02020H,02046H,03600H);
    CODE(00049H,06E73H,06572H,07420H,07465H,07874H,0204DH,06163H);
    CODE(0726FH,02046H,0312DH,04631H,03020H,02041H,06C74H,02D46H);
    CODE(0756EH,0636BH,06579H,00000H,04564H,06974H,02055H,07070H);
    CODE(06572H,02F4CH,06F77H,06572H,02043H,06173H,06520H,02020H);
    CODE(02020H,0416CH,0742DH,04500H,00049H,06E73H,06572H,07420H);
    CODE(04573H,06361H,07065H,02063H,06861H,07220H,0281BH,02920H);
    CODE(02020H,0416CH,0742DH,04573H,06320H,07C20H,04374H,06C2DH);
    CODE(05B00H,00049H,06E73H,06572H,0742FH,06F76H,06572H,07772H);
    CODE(06974H,06520H,04279H,07465H,07320H,02020H,02041H,06C74H);
    CODE(02D49H,00000H,05772H,06170H,02F52H,06566H,06F72H,06D61H);
    CODE(07420H,02020H,02020H,02020H,02020H,02020H,02020H,0416CH);
    CODE(0742DH,05720H,07C20H,04631H,03000H,00052H,0656DH,06F76H);
    CODE(06520H,0616CH,06C20H,06E6FH,06E2DH,07465H,07874H,02020H);
    CODE(02020H,02020H,02053H,06869H,06674H,02D41H,06C74H,02D52H);
    CODE(00000H,0436FH,06E66H,06967H,07572H,06174H,0696FH,06E00H);
    CODE(0004EH,06577H,02043H,06F6EH,06669H,0673FH,02020H,02020H);
    CODE(02020H,02020H,02020H,02020H,02020H,02041H,06C74H,02D4EH);
    CODE(00000H,04578H,06974H,00054H,06578H,0742FH,04861H,0636BH);
    CODE(02F48H,06578H,02074H,06F67H,0676CH,06520H,02020H,02020H);
    CODE(02041H,06C74H,02D54H,00000H,04175H,0746FH,02D49H,06E64H);
    CODE(0656EH,07420H,0746FH,06767H,06C65H,02020H,02020H,02020H);
    CODE(02020H,0416CH,0742DH,05265H,07475H,0726EH,00000H,00D20H);
    CODE(06469H,07370H,06C61H,07920H,0746FH,06767H,06C65H,02020H);
    CODE(02020H,02020H,02020H,02020H,04374H,06C2DH,05265H,07475H);
    CODE(0726EH,00000H,05461H,06220H,07370H,06163H,0696EH,06720H);
    CODE(02020H,02020H,02020H,02020H,02020H,02020H,02020H,0416CH);
    CODE(0742DH,05461H,06200H,00052H,06967H,06874H,02057H,07261H);
    CODE(07020H,0436FH,06C75H,06D6EH,02020H,02020H,02020H,02020H);
    CODE(02041H,06C74H,02D20H,03E00H,0004CH,06566H,07420H,05072H);
    CODE(0696EH,07420H,04D61H,07267H,0696EH,02020H,02020H,02020H);
    CODE(02020H,02041H,06C74H,02D20H,03C00H,00053H,06574H,02F63H);
    CODE(06861H,06E67H,06520H,0436CH,06970H,0626FH,06172H,06420H);
    CODE(02020H,02020H,02053H,06869H,06674H,02D41H,06C74H,02D43H);
    CODE(00000H,04461H,07465H,02046H,06F72H,06D61H,07420H,02020H);
    CODE(02020H,02020H,02020H,02020H,02020H,02020H,05368H,06966H);
    CODE(0742DH,0416CH,0742DH,04400H,00049H,06E73H,06572H,0742FH);
    CODE(04F76H,06572H,07772H,06974H,06520H,0746FH,06767H,06C65H);
    CODE(02020H,0203CH,0496EH,07365H,07274H,03E00H,00053H,06176H);
    CODE(06520H,0426CH,06F63H,06B20H,02D3EH,0204DH,06163H,0726FH);
    CODE(02020H,02020H,02020H,02043H,0746CH,02D46H,0756EH,0634BH);
    CODE(06579H,00000H,05365H,07420H,0466FH,06E74H,02020H,02020H);
    CODE(02020H,02020H,02020H,02020H,02020H,02020H,02020H,05368H);
    CODE(06966H,0742DH,0416CH,0742DH,04600H,00046H,06F6EH,07420H);
    CODE(04269H,06767H,06572H,0207CH,02053H,06D61H,06C6CH,06572H);
    CODE(02020H,02020H,02041H,06C74H,0202BH,0207CH,02041H,06C74H);
    CODE(0202DH,00000H,04265H,06769H,06E6EH,0696EH,06700H,05479H);
    CODE(07065H,04168H,06561H,06420H,0636FH,06E66H,06967H,02020H);
    CODE(02020H,02020H,02020H,02020H,05368H,06966H,0742DH,0416CH);
    CODE(0742DH,05265H,07400H,00049H,06E73H,06572H,07420H,04D6FH);
    CODE(06465H,00050H,07269H,06E74H,06572H,02049H,06E69H,0742EH);
    CODE(02E2EH,00053H,0686FH,07720H,04352H,00041H,07574H,06F2DH);
    CODE(04C6FH,06164H,02046H,0696CH,06500H,04D61H,07267H,0696EH);
    CODE(0732EH,02E2EH,00053H,06176H,06520H,07769H,07468H,02042H);
    CODE(0414BH,07570H,00054H,06162H,0732EH,02E2EH,00048H,06578H);
    CODE(02048H,06163H,06B20H,05374H,06174H,07573H,00044H,06174H);
    CODE(06573H,02E2EH,02E00H,04175H,0746FH,02D49H,06E64H,0656EH);
    CODE(07400H,04175H,0746FH,02D57H,07261H,07000H,04275H,06666H);
    CODE(06572H,02053H,0697AH,0652EH,02E2EH,00053H,06574H,02046H);
    CODE(06F6EH,0742EH,02E2EH,00043H,06C69H,07042H,06F61H,07264H);
    CODE(02E2EH,02E00H,04361H,06E63H,0656CH,0004FH,04B00H,05361H);
    CODE(07665H,00000H,00000H,00024H,00000H,00000H,00000H,0004CH);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00028H,00001H);
    CODE(00000H,0004DH,00000H,00000H,00000H,00076H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00029H,00001H,00000H,00077H);
    CODE(00000H,00000H,00000H,0009DH,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00026H,00001H,00000H,0009EH,00000H,00000H);
    CODE(00000H,000BEH,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00020H,00001H,00000H,000BFH,00000H,00000H,00000H,000DFH);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00020H,00001H);
    CODE(00000H,000E0H,00000H,00000H,00000H,00100H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00020H,00001H,00000H,00101H);
    CODE(00000H,00000H,00000H,00121H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00020H,00001H,00000H,00122H,00000H,00000H);
    CODE(00000H,00142H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00020H,00001H,00000H,00143H,00000H,00000H,00000H,00163H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00020H,00001H);
    CODE(00000H,00164H,00000H,00000H,00000H,00184H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00020H,00001H,00000H,0018FH);
    CODE(00000H,00000H,00000H,001B5H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00026H,00001H,00000H,001B6H,00000H,00000H);
    CODE(00000H,001C5H,00003H,00006H,00000H,01180H,00000H,000FFH);
    CODE(0000FH,00001H,00000H,001C6H,00000H,00000H,00000H,001E6H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00020H,00001H);
    CODE(00000H,001E7H,00000H,00000H,00000H,0020DH,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00026H,00001H,00000H,0020EH);
    CODE(00000H,00000H,00000H,00235H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00027H,00001H,00000H,00236H,00000H,00000H);
    CODE(00000H,00256H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00020H,00001H,00000H,00257H,00000H,00000H,00000H,0027FH);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00028H,00001H);
    CODE(00000H,00280H,00000H,00000H,00000H,002A9H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00029H,00001H,00000H,00313H);
    CODE(00000H,00319H,00000H,0031FH,00003H,00006H,00002H,01180H);
    CODE(00000H,000FDH,00006H,00006H,00000H,0037FH,00000H,00394H);
    CODE(00000H,003AFH,00003H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00015H,0001BH,00000H,003DAH,00000H,00000H,00000H,003E1H);
    CODE(00003H,00006H,00000H,01180H,00000H,000FFH,00007H,00001H);
    CODE(00000H,003ECH,00000H,00000H,00000H,00414H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00028H,00001H,00000H,00415H);
    CODE(00000H,00000H,00000H,00439H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00024H,00001H,00000H,0043AH,00000H,00000H);
    CODE(00000H,0045CH,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00022H,00001H,00000H,0045DH,00000H,00000H,00000H,00486H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00029H,00001H);
    CODE(00000H,00487H,00000H,00000H,00000H,004A7H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00020H,00001H,00000H,004A8H);
    CODE(00000H,00000H,00000H,004D0H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00028H,00001H,00000H,004D1H,00000H,00000H);
    CODE(00000H,004F5H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00024H,00001H,00000H,004F6H,00000H,00000H,00000H,0051CH);
  END RESOURCEDATA1;
  (*$S-,$P-,$T-*)
  PROCEDURE RESOURCEDATA2;
  BEGIN
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00026H,00001H);
    CODE(00000H,0051DH,00000H,00000H,00000H,00543H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00026H,00001H,00000H,00544H);
    CODE(00000H,00000H,00000H,0056DH,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00029H,00001H,00000H,00588H,00000H,00000H);
    CODE(00000H,005A7H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(0001FH,00001H,00000H,005A8H,00000H,00000H,00000H,005CDH);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00025H,00001H);
    CODE(00000H,005CEH,00000H,00000H,00000H,005F6H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00028H,00001H,00000H,006A6H);
    CODE(00000H,00000H,00000H,006ADH,00003H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00007H,00001H,00000H,006AEH,00000H,00000H);
    CODE(00000H,006CEH,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00020H,00001H,00000H,006D9H,00000H,00000H,00000H,006FFH);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00026H,00001H);
    CODE(00000H,00700H,00000H,00000H,00000H,00727H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00027H,00001H,00000H,00728H);
    CODE(00000H,00000H,00000H,00745H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,0001DH,00001H,00000H,00746H,00000H,00000H);
    CODE(00000H,0076CH,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00026H,00001H,00000H,0076DH,00000H,00000H,00000H,00790H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00023H,00001H);
    CODE(00000H,00791H,00000H,00000H,00000H,007B4H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00023H,00001H,00000H,007B5H);
    CODE(00000H,00000H,00000H,007D2H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,0001DH,00001H,00000H,007D3H,00000H,00000H);
    CODE(00000H,007F6H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00023H,00001H,00000H,007F7H,00000H,00000H,00000H,00814H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,0001DH,00001H);
    CODE(00000H,00815H,00000H,00000H,00000H,0083BH,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00026H,00001H,00000H,0083CH);
    CODE(00000H,00000H,00000H,0085FH,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00023H,00001H,00000H,00860H,00000H,00000H);
    CODE(00000H,00868H,00003H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00008H,00001H,00000H,00869H,00000H,00000H,00000H,00890H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00027H,00001H);
    CODE(00000H,00891H,00000H,00000H,00000H,008B1H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00020H,00001H,00000H,008B2H);
    CODE(00000H,00000H,00000H,008D7H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00025H,00001H,00000H,008E2H,00000H,00000H);
    CODE(00000H,00902H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00020H,00001H,00000H,00903H,00000H,00000H,00000H,00920H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,0001DH,00001H);
    CODE(00000H,00921H,00000H,00000H,00000H,00947H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00026H,00001H,00000H,00948H);
    CODE(00000H,00000H,00000H,00968H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00020H,00001H,00000H,00969H,00000H,00000H);
    CODE(00000H,00992H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00029H,00001H,00000H,00993H,00000H,00000H,00000H,009B3H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00020H,00001H);
    CODE(00000H,009B4H,00000H,00000H,00000H,009DAH,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00026H,00001H,00000H,009DBH);
    CODE(00000H,00000H,00000H,00A01H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00026H,00001H,00000H,00A02H,00000H,00000H);
    CODE(00000H,00A10H,00003H,00006H,00000H,01180H,00000H,000FFH);
    CODE(0000EH,00001H,00000H,00A11H,00000H,00000H,00000H,00A31H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00020H,00001H);
    CODE(00000H,00A37H,00000H,00000H,00000H,00A57H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00020H,00001H,00000H,00A58H);
    CODE(00000H,00000H,00000H,00A7DH,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00025H,00001H,00000H,00A7EH,00000H,00000H);
    CODE(00000H,00AA3H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00025H,00001H,00000H,00AA4H,00000H,00000H,00000H,00AC6H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00022H,00001H);
    CODE(00000H,00AC7H,00000H,00000H,00000H,00AE8H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00021H,00001H,00000H,00AE9H);
    CODE(00000H,00000H,00000H,00B0AH,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00021H,00001H,00000H,00B0BH,00000H,00000H);
    CODE(00000H,00B31H,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00026H,00001H,00000H,00B32H,00000H,00000H,00000H,00B58H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00026H,00001H);
    CODE(00000H,00B59H,00000H,00000H,00000H,00B7CH,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00023H,00001H,00000H,00B7DH);
    CODE(00000H,00000H,00000H,00BA3H,00005H,00006H,00000H,01180H);
    CODE(00000H,000FFH,00026H,00001H,00000H,00BA4H,00000H,00000H);
    CODE(00000H,00BCAH,00005H,00006H,00000H,01180H,00000H,000FFH);
    CODE(00026H,00001H,00000H,00BCBH,00000H,00000H,00000H,00BF3H);
    CODE(00005H,00006H,00000H,01180H,00000H,000FFH,00028H,00001H);
    CODE(00000H,00BFEH,00000H,00000H,00000H,00C26H,00005H,00006H);
    CODE(00000H,01180H,00000H,000FFH,00028H,00001H,0FFFFH,00001H);
    CODE(00014H,00014H,00000H,00010H,00002H,01100H,00000H,00000H);
    CODE(00126H,00614H,00004H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00CE4H,00502H,0010DH,0061FH,00001H,0000DH,0FFFFH);
    CODE(0FFFFH,0001AH,00047H,00020H,00000H,0018AH,00303H,00312H);
    CODE(00008H,00001H,00002H,0FFFFH,0FFFFH,0001AH,00045H,00000H);
    CODE(00000H,00185H,00518H,00012H,00008H,00001H,00005H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00D00H,00502H,0020CH);
    CODE(0061FH,00001H,00006H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00D1CH,00502H,00507H,0001DH,00201H,00007H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00D38H,00502H,00007H);
    CODE(0001FH,00600H,00008H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00D54H,00502H,00006H,0041FH,00001H,00009H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00D70H,00502H,00105H);
    CODE(0021EH,00001H,0000AH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00D8CH,00502H,0030AH,0061EH,00001H,0000BH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00DA8H,00502H,00508H);
    CODE(0021EH,00001H,0000CH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00DC4H,00502H,0030BH,0001AH,00001H,00003H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00DE0H,00502H,0010EH);
    CODE(0001FH,00001H,0000EH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00DFCH,00502H,00204H,0021CH,00001H,0000FH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00E18H,00501H,00500H);
    CODE(0000EH,00001H,00010H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00E34H,00502H,00310H,00418H,00001H,00011H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00E50H,00602H,00509H);
    CODE(0041CH,00001H,00012H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00E6CH,00502H,0030FH,0051CH,00600H,00013H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00E88H,00502H,00403H);
    CODE(0051EH,00600H,00014H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00EA4H,00502H,00602H,0041EH,00600H,00000H,0FFFFH);
    CODE(0FFFFH,00015H,00020H,00000H,00000H,00EC0H,00502H,00701H);
    CODE(0011FH,00600H,0FFFFH,00001H,0000BH,00014H,00000H,00010H);
    CODE(00002H,01100H,00000H,00000H,00025H,0000BH,00002H,0FFFFH);
    CODE(0FFFFH,0001CH,00000H,00000H,00000H,002AAH,00003H,00001H);
    CODE(00020H,00001H,00003H,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,002CBH,00003H,00002H,00018H,00001H,00004H,0FFFFH);
    CODE(0FFFFH,0001CH,00000H,00000H,00000H,002E4H,0001BH,00002H);
    CODE(00006H,00001H,00005H,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,002EBH,00003H,00003H,00020H,00001H,00006H,0FFFFH);
    CODE(0FFFFH,0001AH,00044H,00000H,00000H,0030CH,00005H,00005H);
    CODE(00003H,00002H,00007H,0FFFFH,0FFFFH,0001AH,00044H,00000H);
    CODE(00000H,0030FH,00009H,00005H,00703H,00002H,00008H,0FFFFH);
    CODE(0FFFFH,0001EH,00008H,00000H,00000H,00EDCH,0000EH,00005H);
    CODE(00007H,00002H,00009H,0FFFFH,0FFFFH,0001AH,00044H,00000H);
    CODE(00000H,00325H,00016H,00005H,00703H,00002H,0000AH,0FFFFH);
    CODE(0FFFFH,0001AH,00044H,00000H,00000H,00329H,0001BH,00005H);
    CODE(00003H,00002H,0000BH,0FFFFH,0FFFFH,0001AH,00007H,00020H);
    CODE(00000H,0032CH,00004H,00008H,0050BH,00402H,00000H,0FFFFH);
  END RESOURCEDATA2;
  (*$S-,$P-,$T-*)
  PROCEDURE RESOURCEDATA3;
  BEGIN
    CODE(0FFFFH,0001AH,00025H,00000H,00000H,0032FH,00018H,00008H);
    CODE(00207H,00402H,0FFFFH,00001H,00001H,00014H,00000H,00000H);
    CODE(00001H,01100H,00000H,00000H,00517H,00401H,00000H,0FFFFH);
    CODE(0FFFFH,0001CH,00020H,00000H,00000H,00336H,00102H,00200H);
    CODE(00014H,00001H,0FFFFH,00001H,00008H,00014H,00000H,00010H);
    CODE(00002H,01100H,00000H,00000H,00021H,0000BH,00002H,0FFFFH);
    CODE(0FFFFH,0001CH,00000H,00000H,00000H,0034BH,00003H,00001H);
    CODE(00019H,00001H,00003H,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,00365H,00003H,00002H,00019H,00001H,00004H,0FFFFH);
    CODE(0FFFFH,0001EH,00008H,00000H,00000H,00EF8H,00002H,00004H);
    CODE(0001BH,00002H,00005H,0FFFFH,0FFFFH,0001AH,00047H,00020H);
    CODE(00000H,003C4H,00002H,00007H,00008H,00003H,00006H,0FFFFH);
    CODE(0FFFFH,0001AH,00011H,00000H,00000H,003C7H,0000DH,00007H);
    CODE(00007H,00001H,00007H,0FFFFH,0FFFFH,0001AH,00045H,00000H);
    CODE(00000H,003CBH,00016H,00007H,00008H,00003H,00008H,0FFFFH);
    CODE(0FFFFH,0001AH,00011H,00000H,00000H,003D2H,0000DH,00008H);
    CODE(00007H,00001H,00000H,0FFFFH,0FFFFH,0001AH,00031H,00000H);
    CODE(00000H,003D6H,0000DH,00009H,00007H,00001H,0FFFFH,00001H);
    CODE(0000CH,00014H,00000H,00010H,00002H,01100H,00000H,00000H);
    CODE(00226H,00214H,0000DH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00F14H,00101H,00400H,00006H,00001H,00003H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00F30H,00003H,00509H);
    CODE(0021EH,00600H,00004H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00F4CH,00702H,00508H,0011BH,00600H,00005H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00F68H,00003H,00507H);
    CODE(0031FH,00600H,00006H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00F84H,00003H,0040AH,0061EH,00700H,00007H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00FA0H,00003H,00506H);
    CODE(00618H,00600H,00008H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00FBCH,00003H,00505H,0061FH,00600H,00009H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,00FD8H,00003H,00404H);
    CODE(0031BH,00001H,0000AH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,00FF4H,00003H,00501H,0071FH,00600H,0000BH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01010H,00003H,00502H);
    CODE(00220H,00600H,0000CH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,0102CH,00003H,00503H,0001FH,00600H,00000H,0000FH);
    CODE(00012H,00014H,00000H,00000H,000FFH,01100H,00102H,0070CH);
    CODE(00720H,00504H,0000EH,0FFFFH,0FFFFH,0001AH,00047H,00020H);
    CODE(00000H,003E2H,00103H,00212H,00008H,00001H,00002H,0FFFFH);
    CODE(0FFFFH,0001AH,00045H,00000H,00000H,003E7H,00119H,00412H);
    CODE(00008H,00001H,00010H,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,0056EH,00503H,00400H,00019H,00001H,00011H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01048H,00601H,00502H);
    CODE(00318H,00700H,00012H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01064H,00601H,00403H,0011BH,00700H,0000CH,0FFFFH);
    CODE(0FFFFH,00015H,00020H,00000H,00000H,01080H,00601H,00601H);
    CODE(0051DH,00700H,0FFFFH,00001H,00004H,00019H,00000H,00000H);
    CODE(00000H,00000H,00000H,00000H,00050H,00019H,00004H,00002H);
    CODE(00002H,00014H,00000H,00000H,00000H,01100H,00000H,00000H);
    CODE(00050H,00201H,00001H,00003H,00003H,00019H,00000H,00000H);
    CODE(00000H,00000H,00002H,00000H,00006H,00301H,00002H,0FFFFH);
    CODE(0FFFFH,00020H,00000H,00000H,00000H,005F7H,00000H,00000H);
    CODE(00006H,00301H,00000H,00005H,00005H,00019H,00000H,00000H);
    CODE(00000H,00000H,00000H,00301H,00050H,00013H,00004H,00006H);
    CODE(0000DH,00014H,00000H,00000H,000FFH,01100H,00002H,00000H);
    CODE(00014H,00008H,00007H,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,005FEH,00000H,00000H,00014H,00001H,00008H,0FFFFH);
    CODE(0FFFFH,0001CH,00000H,00008H,00000H,00613H,00000H,00001H);
    CODE(00014H,00001H,00009H,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,00628H,00000H,00002H,00014H,00001H,0000AH,0FFFFH);
    CODE(0FFFFH,0001CH,00000H,00000H,00000H,0063DH,00000H,00003H);
    CODE(00014H,00001H,0000BH,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,00652H,00000H,00004H,00014H,00001H,0000CH,0FFFFH);
    CODE(0FFFFH,0001CH,00000H,00000H,00000H,00667H,00000H,00005H);
    CODE(00014H,00001H,0000DH,0FFFFH,0FFFFH,0001CH,00000H,00000H);
    CODE(00000H,0067CH,00000H,00006H,00014H,00001H,00005H,0FFFFH);
    CODE(0FFFFH,0001CH,00020H,00000H,00000H,00691H,00000H,00007H);
    CODE(00014H,00001H,0FFFFH,00001H,0000FH,00014H,00000H,00010H);
    CODE(00002H,01100H,00000H,00000H,00325H,00014H,00004H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,0109CH,00301H,00600H);
    CODE(00006H,00001H,00005H,0FFFFH,0FFFFH,0001AH,00047H,00020H);
    CODE(00000H,006D4H,00702H,00012H,00008H,00001H,00002H,0FFFFH);
    CODE(0FFFFH,0001AH,00045H,00000H,00000H,006CFH,00419H,00112H);
    CODE(00008H,00001H,00003H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,010B8H,00502H,00202H,0061EH,00700H,00006H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,010D4H,00502H,00306H);
    CODE(0001DH,00700H,00007H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,010F0H,00602H,00009H,0021FH,00700H,00008H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,0110CH,00502H,0030BH);
    CODE(0001CH,00700H,00009H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01128H,00502H,00210H,0011DH,00201H,0000AH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01144H,00602H,0030AH);
    CODE(0041CH,00700H,0000BH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01160H,00502H,0030CH,0061AH,00601H,0000CH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,0117CH,00502H,0010EH);
    CODE(0001CH,00700H,0000DH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01198H,00502H,0020FH,0061CH,00001H,0000EH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,011B4H,00502H,00005H);
    CODE(0061EH,00700H,0000FH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,011D0H,00502H,00507H,0071CH,00001H,00000H,0FFFFH);
    CODE(0FFFFH,00015H,00020H,00000H,00000H,011ECH,00502H,00303H);
    CODE(0051AH,00201H,0FFFFH,00001H,0000EH,00014H,00000H,00010H);
    CODE(00002H,01100H,00000H,00000H,00425H,00414H,00002H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01208H,00301H,00600H);
    CODE(00007H,00001H,00003H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01224H,00502H,00302H,0001EH,00700H,00004H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01240H,00502H,00704H);
    CODE(0061EH,00700H,0000AH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,0125CH,00502H,00503H,0021FH,00700H,00006H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01278H,00402H,0010AH);
    CODE(0061AH,00600H,00007H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01294H,00502H,00306H,00618H,00600H,00008H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,012B0H,00402H,0020BH);
    CODE(0061DH,00600H,00009H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,012CCH,00502H,0010CH,00219H,00101H,0000CH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,012E8H,00402H,0050DH);
    CODE(0021FH,00700H,0000BH,0FFFFH,0FFFFH,0001AH,00047H,00020H);
    CODE(00000H,008D8H,00103H,00212H,00008H,00001H,00005H,0FFFFH);
    CODE(0FFFFH,0001AH,00045H,00000H,00000H,008DDH,00319H,00412H);
    CODE(00008H,00001H,0000DH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01304H,00502H,00408H,0061AH,00001H,0000EH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01320H,00502H,00307H);
    CODE(0001EH,00700H,00000H,0FFFFH,0FFFFH,00015H,00020H,00000H);
    CODE(00000H,0133CH,00502H,0070EH,0011DH,00700H,0FFFFH,00001H);
    CODE(00011H,00014H,00000H,00010H,00002H,01100H,00000H,00000H);
    CODE(00525H,00514H,00002H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01358H,00102H,00001H,0000DH,00001H,0000CH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01374H,00403H,00702H);
    CODE(00118H,00700H,00004H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01390H,00303H,00004H,00618H,00600H,00005H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,013ACH,00303H,00005H);
    CODE(0051CH,00600H,00006H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,013C8H,00403H,00006H,0011CH,00600H,00007H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,013E4H,00303H,00107H);
    CODE(0001AH,00700H,00008H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01400H,00303H,0040BH,0021AH,00600H,00009H,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,0141CH,00303H,0010AH);
    CODE(0041AH,00700H,0000AH,0FFFFH,0FFFFH,00015H,00000H,00000H);
  END RESOURCEDATA3;
  (*$S-,$P-,$T-*)
  PROCEDURE RESOURCEDATA4;
  BEGIN
    CODE(00000H,01438H,00303H,00209H,0061CH,00001H,0000BH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,01454H,00303H,00308H);
    CODE(0021DH,00001H,0000EH,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,01470H,00203H,0010CH,0031AH,00401H,00003H,0FFFFH);
    CODE(0FFFFH,0001AH,00047H,00020H,00000H,00A32H,00603H,00412H);
    CODE(00008H,00001H,00011H,0FFFFH,0FFFFH,0001AH,00045H,00000H);
    CODE(00000H,00BF4H,00715H,00212H,0010BH,00001H,0000FH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,0148CH,00303H,0050DH);
    CODE(0061CH,00001H,00010H,0FFFFH,0FFFFH,00015H,00000H,00000H);
    CODE(00000H,014A8H,00303H,0070EH,0041CH,00700H,0000DH,0FFFFH);
    CODE(0FFFFH,00015H,00000H,00000H,00000H,014C4H,00403H,0060FH);
    CODE(0041DH,00700H,00000H,0FFFFH,0FFFFH,00015H,00020H,00000H);
    CODE(00000H,014E0H,00303H,00710H,0071DH,00600H,0FFFFH,00001H);
    CODE(00010H,00014H,00000H,00010H,00002H,01100H,00000H,00000H);
    CODE(00025H,00014H,00002H,0FFFFH,0FFFFH,0001AH,00001H,00020H);
    CODE(00000H,00C27H,00002H,00001H,0000CH,00001H,00003H,0FFFFH);
    CODE(0FFFFH,0001AH,00005H,00020H,00000H,00C33H,00011H,00001H);
    CODE(00011H,00001H,00004H,0FFFFH,0FFFFH,0001AH,00001H,00020H);
    CODE(00000H,00C43H,00002H,00003H,0000CH,00001H,00005H,0FFFFH);
    CODE(0FFFFH,0001AH,00001H,00020H,00000H,00C4BH,00011H,00003H);
    CODE(00011H,00001H,00006H,0FFFFH,0FFFFH,0001AH,00005H,00020H);
    CODE(00000H,00C5AH,00002H,00005H,0000CH,00001H,00007H,0FFFFH);
    CODE(0FFFFH,0001AH,00001H,00020H,00000H,00C65H,00011H,00005H);
    CODE(00011H,00001H,00008H,0FFFFH,0FFFFH,0001AH,00005H,00020H);
    CODE(00000H,00C75H,00002H,00007H,0000CH,00001H,00009H,0FFFFH);
    CODE(0FFFFH,0001AH,00001H,00020H,00000H,00C7DH,00011H,00007H);
    CODE(00011H,00001H,0000AH,0FFFFH,0FFFFH,0001AH,00005H,00020H);
    CODE(00000H,00C8DH,00002H,00009H,0000CH,00001H,0000BH,0FFFFH);
    CODE(0FFFFH,0001AH,00001H,00020H,00000H,00C96H,00011H,00009H);
    CODE(00011H,00001H,0000CH,0FFFFH,0FFFFH,0001AH,00001H,00020H);
    CODE(00000H,00CA2H,00002H,0000BH,0000CH,00001H,0000DH,0FFFFH);
    CODE(0FFFFH,0001AH,00045H,00020H,00000H,00CACH,00011H,0000BH);
    CODE(00011H,00001H,0000EH,0FFFFH,0FFFFH,0001AH,00005H,00020H);
    CODE(00000H,00CBBH,00002H,0000DH,0000CH,00001H,00011H,0FFFFH);
    CODE(0FFFFH,0001AH,00005H,00020H,00000H,00CC7H,00011H,0000DH);
    CODE(00011H,00001H,00010H,0FFFFH,0FFFFH,0001AH,00047H,00020H);
    CODE(00000H,00CDBH,00003H,00010H,00008H,00002H,00000H,0FFFFH);
    CODE(0FFFFH,0001AH,00065H,00020H,00000H,00CDEH,0000EH,00010H);
    CODE(00008H,00002H,0000FH,0FFFFH,0FFFFH,0001AH,00045H,00020H);
    CODE(00000H,00CD4H,00019H,00010H,00008H,00002H,00000H,01AE4H);
    CODE(00000H,016F4H,00000H,01844H,00000H,020CCH,00000H,01C34H);
    CODE(00000H,014FCH,00000H,01DB4H,00000H,01F1CH,00000H,01814H);
    CODE(00000H,0191CH);
  END RESOURCEDATA4;


TYPE
  OBJECT = RECORD
             next, head: INTEGER;
             tail, type: INTEGER;
             flags, state: INTEGER;
             spec: ADDRESS;
             x, y: INTEGER;
             width, height: INTEGER;
           END;
  TEDINFO = RECORD
              ptext,
              ptmplt,
              pvalid: ADDRESS;
              font, resvd1: INTEGER;
              just, color: INTEGER;
              resvd2, thickness: INTEGER;
              txtlen, tmplen: INTEGER;
            END;
VAR
  i: CARDINAL; o: INTEGER; x: ADDRESS;
  TreeAddr: POINTER TO ARRAY [0..nrTrees-1] OF ADDRESS;
  TedInfoAddr: POINTER TO ARRAY [0..nrTedInfos-1] OF TEDINFO;
  ObjectAddr: POINTER TO ARRAY [0..nrObjects-1] OF OBJECT;

BEGIN
 WindowUpdate(1);
  (* Access resource procedures so optimising linker will
     not remove them. *)
  x := ADDRESS(RESOURCEDATA1);
  x := ADDRESS(RESOURCEDATA2);
  x := ADDRESS(RESOURCEDATA3);
  x := ADDRESS(RESOURCEDATA4);
  (* relocate tree indicies *)
  x := ADDRESS(RESOURCEDATA0) + ixTrees;
  TreeAddr := x;
  FOR i := 0 TO nrTrees-1 DO
    TreeAddr^[i] := TreeAddr^[i] + ADDRESS(RESOURCEDATA0); INC(x,4); 
  END;
  (* relocate ted infos *)
  x := ADDRESS(RESOURCEDATA0) + ixTedInfos;
  TedInfoAddr := x;
  FOR i := 0 TO nrTedInfos-1 DO
    WITH TedInfoAddr^[i] DO
      ptext := ptext + ADDRESS(RESOURCEDATA0);
      ptmplt := ptmplt + ADDRESS(RESOURCEDATA0);
      pvalid := pvalid + ADDRESS(RESOURCEDATA0);
    END;
  END;
  (* relocate object specs *)
  x := ADDRESS(RESOURCEDATA0) + ixObjects;
  ObjectAddr := x;
  FOR i := 0 TO nrObjects-1 DO
    WITH ObjectAddr^[i] DO
      IF (type # GBOX)  & (type # GPROGDEF) &
         (type # GIBOX) & (type # GBOXCHAR) THEN
        (* relocate against resource base *)
        spec := spec + ADDRESS(RESOURCEDATA0);
      END;
      (* Fix up the scaling *)
      ResourceObjectFix(ObjectAddr,i) ;  (*0.10a*)
    END;
  END;
 WindowUpdate(0);
END resource;
(***********  End of Embedded RSC  *************)

TYPE
     (*
     Substrg = ARRAY[0..20] OF CHAR;
     Pathtype = ARRAY[0..32] OF CHAR;
     Fsel0type = ARRAY[0..15] OF CHAR;
     Fseltype = ARRAY[0..40] OF CHAR;
     *) (* now in DEF *)
     Charset = SET OF CHAR;
(*
     MyBPBrec = RECORD
                  bytespersec,
                  secperclust,
                  resvdsecs: CARDINAL;
                  nfats: CHAR;
                  ndirs,
                  nsectors: CARDINAL;
                END; (* record *)
*)                

VAR
  (* move to DEF *)
(*
  daccTitle: ARRAY[0..12] OF CHAR;
  dacc: INTEGER; (* menu item # 0..5 *)
  diaryname: Fsel0type;
*)
  (* kreturn: CARDINAL; *) (* now in DEF *)
  ch, savedeolchar: CHAR;
(* charray:                      ARRAY[0..buffsize-1] OF CHAR; *)
(**
  pipeBuff:                     ARRAY[0..7] OF INTEGER;
  mark:                         ARRAY[0..1] OF CARDINAL; (* bookmarks *)
**)
  Title1:                       ARRAY[0..12] OF CHAR; (* enough for filename *)
  menuTitle:                    ARRAY[0..6] OF CHAR;
(**2.1**
  cardstrg:                     ARRAY[0..5] OF CHAR;
**)
  cardstrg:                     ARRAY[0..7] OF CHAR; (* 7 for 2.35 *)
  bslash, pathmark:             ARRAY[0..3] OF CHAR;
  alertstrg1, alertstrg2: ARRAY[0..62] OF CHAR; (* for Turn Wrap On/Off *)
  alertstrg3, alertstrg4: ARRAY[0..4] OF CHAR;  (* 'ON]' or 'OFF]' *)
  path (* oldpath *):              Pathtype; (* ARRAY[0..128] OF CHAR; *)
  (* fsel0:                      Fsel0type; (* ARRAY[0..15] OF CHAR; *)*)
  (*  fsel:                       Fseltype; (* ARRAY[0..40] OF CHAR; *) *)
  oldfindstrg, findstrg, oldrepstrg, repstrg : Substrg;

  update, alldone, forcefull, kwiksend, hexdisp, menuok:     BOOLEAN;
  (* note: show mouse is not currently used *)

  item:      ARRAY[0..maxitems],[0..13] OF CHAR; (* menu items *)

(*  macro:   ARRAY[1..10],[0..macrosize] OF CHAR; *)

  treeptr:   POINTER TO ARRAY[0..25] OF GEMAESbase.Object;
  bpbptr:    BPBPtr; (* pointer to Bios parameter block *)
  procptr:   POINTER TO PROCEDURE(): ADDRESS; (* 3.02 *)
(*test*
  tstcard1,tstcard2,
*test*)
  j, k, srchlen, eventflags, scrnmaxdispln, buffline,
  maxblock, (* oldblock, *) kperblock, blocknum, 
  startfileblk, startramblk, startsect, xfertype:  CARDINAL;

(** 2/9/92 **)
  unshiftptr, shiftptr, capslockptr,
(***)
  mstatptr: POINTER TO CHAR; (* cur_ms_stat *)
(*  mhideptr: POINTER TO INTEGER; *) (* m_hid_cnt *) (* 2.30 1/2/92 *)

  (* x, y, w, h, curX, curY, *) offset, slidepos, findbtn,
  dummy, result, int, noticeX, noticharX, aplsend,
  kret, mX0, mY0, mbstate, breturn, mkstate,
  (* WidthChar, HeightChar, WidthFont, HeightFont, *) defcharht,
  (* Window data *)
  (* fullX, fullY, fullW, fullH, *)
  (* Window1 is text window, Window3 is Fsel header window *)
  Window3,         (* window handles *)
  (* wind1X, wind1Y, wind1W, wind1H, *)        (* text window *)
  (*  workX, workY, workW, workH, *)      (* Working window, in DEF *)
  menubX, menubY, menubW, menubH, inout,  (* for menu button/title block *)
  menuX, (* menuY,*) menuW, menuH, stalkID, neoID: INTEGER;

(*test*
  tstlong1, tstlong2,
*test*)
  blocksize, maxmem, maxadrlcard, membot, sendlim, startfold:  LONGCARD;
   (* 1070 is PhysTop, but it doesn't include ramdisk *)
  workIn  :                     VDIWorkInType ;
  workOut :                     VDIWorkOutType ;

  Hexset:           Charset; (* all hex digits + 0C *)
  saveA4, saveA5, findadr, tmpadr, kbshiftadr,
  mfdbADR, stack, memadr, MenuTree, sendadr:      ADDRESS;

    (* for conzap fast character output routine *)
    (* counter, vfntwd, byteslin, vcelht: CARDINAL; *)
    (* adrptr, neoptr, vfntadptr: POINTER TO ADDRESS; *)
    neoadr, fnthdadr, sysfontoffset: ADDRESS;
    (* sysfont is offset from font headptr address, = 0 for 6x6, 4 for 8x8, 8 for 8x16 *)

  mfdbrec:       MFDBType;
(*
  RGBi:          PxyArrayType; (* initial RGB settings to return to *)
*)


(***** 2 Added procedures for RSC file embedding... ****)
(*
PROCEDURE ResourceLoad(a: ARRAY OF CHAR);
BEGIN
END ResourceLoad;
*)
(*
PROCEDURE ResourceGetAddr(a, b: INTEGER; VAR c: ADDRESS);
BEGIN
  c:= TreeAddr^[b];
END ResourceGetAddr;
*)

(***** End of added RSC embedding procedures ****)
(**2.1**
PROCEDURE Pwr(x, exp: CARDINAL): LONGCARD;
VAR i: CARDINAL;
    y: LONGCARD;
BEGIN
  y:= LONG(x);
  IF exp = 0 THEN y:= 1;
  ELSIF exp > 1 THEN
    FOR i:= 2 TO exp DO
      y:= y * LONG(x);
    END; (* for *)
  END; (* if *) (* note: if exp=1 then y just stays as x *)
  RETURN y;
END Pwr;
**2.1**)

PROCEDURE Cardtostrg(x: LONGCARD; VAR cardstrg: ARRAY OF CHAR;
                     ishex: BOOLEAN; digits: CARDINAL);
(* modified to do 5 or 6 digits WITH leading zeros as needed *)
(* now should do ANY number of digits, if receiving strg is long enough *)
VAR i, card, ref, place, max, base: CARDINAL;
    y: LONGCARD;
(*    big: BOOLEAN; *)
BEGIN
  i:= 0;
(*  big:= FALSE; *)(* whether need a zero in a place *)
(**2.1**
  max:= 4;
*)
  max:= digits - 1;
  base:= 10;
  IF ishex THEN
(**2.1**
    max:= 5; (* gives 6 hex digits (3 bytes), enough for all addresses *)
*)
    base:= 16;
  END;
  FOR place:= max TO 0 BY -1 DO (* 4 for full 5 digits *)
(**
    y:= Pwr(base, place);  (* x, exp from old Pwr() *)
**)
(**2.1**)
    y:= LONG(base);
    IF place = 0 THEN y:= 1;
    ELSIF place > 1 THEN
      FOR card:= 2 TO place DO
        y:= y * LONG(base);
      END; (* for *)
    END; (* if *) (* note: if place=1 then y just stays as x *)
    (* RETURN y; *)
(**2.1**)

    card:= SHORT(x DIV y);
    ref:= 48; (* ORD('0') *)
    IF card > 9 THEN (* A-F *)
      ref:= 55; (* ORD ('A') - ORD('9') + 1 *)
    END;
    cardstrg[i]:= CHR(card + ref);
(*
    ch:= CHR(card + ref);
    IF stripzero & (ch <> 0C) THEN
      stripzero:= FALSE;
    END;
    IF NOT (stripzero & (ch = 0C)) THEN
      cardstrg[i]:= ch;
      INC(i);
    END;
*)
    x:= x MOD y;
    (* big:= TRUE; *)
    INC(i);
  END; (* for place = 4 to 1 *)
  (* cardstrg[i]:= CHR(SHORT(x) + 48); *)
  cardstrg[i]:= 0C; (* was i+1 *)
END Cardtostrg;

PROCEDURE Strgtolongc(cardstrg: ARRAY OF CHAR; ishex: BOOLEAN): LONGCARD;
VAR i, ref: CARDINAL;
    x, y, base: LONGCARD;
BEGIN
  x:= 0;
  y:= 0;
  i:= 0;
  base:= 10; (* defaults to decimal *)
(*
  IF cardstrg[0] = '$' THEN (* hex number *)
*)
  IF ishex THEN
    base:= 16;
  END; (* if hex *)
  WHILE NOT (cardstrg[i] IN Hexset) DO (* skip over leading spaces etc. *)
    INC(i);
  END;
  WHILE cardstrg[i] <> 0C DO
    ref:= 48; (* ORD('0'); *) (* default to decimal *)
    IF cardstrg[i] >= 'A' THEN (* change to hex A-F base *)
      ref:= 55; (* ORD('A') - 10; *)
      IF cardstrg[i] >= 'a' THEN (* 3.2 *)
        ref:= 87; (* ORD('a') - 10; *)
      END; (* if lowercase *)
    END; (* if hex *)
    y:= LONG(ORD(cardstrg[i]) - ref);
    x:= x * base + y;
    INC(i);
  END; (* while *)
  RETURN x;
END Strgtolongc;

PROCEDURE StringZap(string: ARRAY OF CHAR);
VAR j: CARDINAL;
BEGIN
  j:= 0;
  (* ensure that it can't put out more than window width *)
  WHILE (string[j] <> 0C) & (j <= displaylen) DO (* & (j <= HIGH(string) *)
    (* Bconout(string[j], 5); *) Conzap(string[j]);
    INC(j);
  END;
END StringZap;

(*ds*)
(**)
PROCEDURE ShowDate;
(* 2.30 1/15/92 allow either mm/dd/yy or dd Mon yy *)
(* revised to do DD Mon YY *)
VAR datecard, month, day, year: CARDINAL;
    datestrg: ARRAY[0..11] OF CHAR;
    monthstrg: ARRAY[0..35] OF CHAR;
    monstrg, daystrg: ARRAY[0..2] OF CHAR;
    yrstrg: ARRAY[0..4] OF CHAR; (* to all full 1995 type year *)
BEGIN
(*
  GetDate(datecard);  (* returns date in special format to decode: *)
*)
  (* save registers *)
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  PUSH(02AH); (* getdate code *)
  CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
  CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  datecard:= CARDINAL(REGISTER(D0));
  day:= datecard MOD 32;
  month:= (datecard MOD 512) DIV 32;
  year:= (datecard DIV 512) + 1980; (* for 2-digit format, e.g. 87 *)

(**
  IF cfg.eurodate THEN
    datestrg[2]:= '.';
    datestrg[5]:= '.';
    j:= day;
    day:= month;
    month:= j;
  END; (* if eurodate, e.g. 25.12.90 *)  
**)
  (* day *)
  Cardtostrg(LONG(day), daystrg, FALSE, 2); (* gets in 2 digit format *)

  (* year *)
  Cardtostrg(LONG(year), yrstrg, FALSE, 4); (* gets in 4 digit format *)

  IF cfg.eurodate = 1C THEN  (*209* DD Mon YYYY *)
    datestrg:= '00 XXX 0000';
    monthstrg:= 'JanFebMarAprMayJunJulAugSepOctNovDec';
  (* month: *)
    MoveMem(ADR(monthstrg[(month-1)*3]), ADR(datestrg[3]), 3);
  
  (* day: *)
    Cardtostrg(LONG(day), daystrg, FALSE, 2); (* gets in 2 digit format *)
    datestrg[0]:= daystrg[0]; datestrg[1]:= daystrg[1];  (* day *)
  
  (* year *)
    Cardtostrg(LONG(year), yrstrg, FALSE, 4); (* gets in 4 digit format *)
  (*209* DD Mon YYYY *)
    datestrg[7]:= yrstrg[0]; datestrg[8]:= yrstrg[1];  (* year *)
    datestrg[9]:= yrstrg[2]; datestrg[10]:= yrstrg[3];  (* year *)
    datestrg[11]:= 0C;
  ELSIF cfg.eurodate = 0C THEN (* US mm/dd/yy date *)
    datestrg:= '00/00/00';
    (* month *)
    Cardtostrg(LONG(month), monstrg, FALSE, 2); (* gets in 2 digit format *)
    datestrg[0]:= monstrg[0]; datestrg[1]:= monstrg[1];  (* month *)
    datestrg[3]:= daystrg[0]; datestrg[4]:= daystrg[1];  (* day *)
    datestrg[6]:= yrstrg[2]; datestrg[7]:= yrstrg[3];  (* year *)
    datestrg[8]:= 0C;
  ELSE (* data yymmdd date cfg.eurodate = 2C *)
    datestrg:= '000000';
    (* month *)
    Cardtostrg(LONG(month), monstrg, FALSE, 2); (* gets in 2 digit format *)
    datestrg[0]:= yrstrg[2]; datestrg[1]:= yrstrg[3];  (* year *)
    datestrg[2]:= monstrg[0]; datestrg[3]:= monstrg[1];  (* month *)
    datestrg[4]:= daystrg[0]; datestrg[5]:= daystrg[1];  (* day *)
    datestrg[6]:= 0C;
  END; (* if eurodate *)

(*
  FOR j:= 0 TO HIGH(datestrg) DO (* insert or overwrite the date at cursor *)
*)
  j:= 0;
  kreturn:= 0; (* 2.37 *)
  WHILE datestrg[j] <> 0C DO
    newchar:= datestrg[j];
    AddInsert; (* DoAscii; *)
    INC(j);
  END;
END ShowDate;
(**)
(*ds*)
(* *******************  START INIT ****************** *)

PROCEDURE MiniInit;
BEGIN
  i:= 0;
  line:= 0;
  curdispline:= 0;
  linepos:= 0;
  startcol:= 0;
  blocktype:= 0;
(*
  isblock:= FALSE;
*)
  notistrg:= 0C;
(*209* moved here from ClearAll *)
  blockstart:= 0;
  blockend:= 0;
  delstart:= 0;
 (* marks?? leave alone, but ensure it doesn't try positioning after last *)
(* 2.30 *)
  hexdisp:= FALSE;
END MiniInit;

PROCEDURE ClearAll(newfile: BOOLEAN);
(* use selectmenu(editmenu, wipebuff) for confirm *)
BEGIN
(**209**
  delete since miniInit handles blockstart,end,isblock, etc.:
  RuinBlock(TRUE); (* do it no matter what *)
**)
  MiniInit;
  cfg.eollen:= 2; (* force text mode *)
  wrapW:= cfg.textwrapW; (* displaylen *)
(*^^^*)
  CursorPos(0, leftedge);
(*^^^*)
  saved:= TRUE;
(*
  Title1:= ' NEWFILE.TXT ';
*)
  (* 2.30 *)
  MoveMem(ADR(cfg.fsel0), ADR(Title1), LONG(Length(cfg.fsel0)+1));
(* 3.12 *)
  IF newfile THEN
    buffline:= 0;
    fileend:= 0;
    bigpart:= FALSE;
    startf:= 0;
    endf:= 0;
  ELSE (* stalker capture/append, not debugged yet, so use newfile *)
    buffline:= buffline + lastline;
    startf:= endf + last;
    endf:= startf;
    fileend:= fileend + last;
    bigpart:= TRUE;
  END;
  last:= 0;
  lastline:= 0;
  lasti:= 0;
(*
  IF iswind THEN
*)
  IF VDIHandle >= 0 THEN
    InitMenu;
    ClearWindow(Window1);
    SetSlideSize;
    SetSlidePos;
  END; (* if is window open *)
END ClearAll;

(*ds*)
PROCEDURE WrapCheck;
BEGIN
  IF cfg.autowrap THEN
    Concat(alertstrg1, alertstrg3, alertstrg2); (* turn OFF *)
  ELSE
    Concat(alertstrg1, alertstrg4, alertstrg2); (* turn ON *)
  END; (* if toggle autowrap *)
END WrapCheck;
(*ds*)

PROCEDURE LineAinit;
BEGIN
  (* save all registers that get changed, except scratch regs A0 + D0 *)
(*
  (* movem.l A1-A2/,-(SP) *)
  CODE(048E7H, 00060H); (* 0100 1000 1110 0111, 0000 0000 0110 0000 *)
*)
  CODE(048E7H,06060H); (* movem.l A1-A2/D1-D2,-(SP) *)

  CODE(InitLineA); (* lineA init code, 0A000H *)
  lineAadr:= REGISTER(A0); (* A0 = address of lineA variable table *)
  fnthdadr:= REGISTER(A1); (* A1 = address of font headers, 6x6,8x8,8x16 *)

  (* get keyboard shift status vector while we're at it *)
  CODE(02F3CH,0FFFFH,0FFFFH); (* move.l   #-1,-(sp)  locate the shift vec *)
  CODE(02F3CH,0FFFFH,0FFFFH); (* move.l   #-1,-(sp) *)
  CODE(02F3CH,0FFFFH,0FFFFH); (* move.l   #-1,-(sp) *)
  CODE(03F3CH,00010H); (* move.w   #$10,-(sp) *)
  CODE(04E4EH); (* trap  #14  ; xbios call *)
  CODE(04FEFH,0000EH); (* lea   14(sp),sp *)
  kbshiftadr:= REGISTER(D0);   (* move.l  d0,shiftvec save for later *)

  (* restore all registers *)
(*
  (* movem.l (sp)+,A1-A2/ *)
  CODE(04CDFH, 00600H); (* 0100 1100 1101 1111, 0000 0110 0000 0000 *)
*)
  CODE(04CDFH,00606H); (* movem.l (sp)+,A1-A2/D1-D2 *)

  adrptr:= lineAadr + ADDRESS(INTIN);
  mstatptr:= lineAadr - ADDRESS(348); (* cur_ms_stat *)
(**
  mresetptr:= adrptr^; (* mouse reset pointer = ptr to INTIN array *)
**)
  mhideptr:= lineAadr - ADDRESS(598); (* ptr to mouse hide count *)
(**)
  cardptr:= lineAadr + ADDRESS(BYTESLIN); (* or WIDTH *)
  byteslin:= cardptr^;
END LineAinit;

PROCEDURE KeyFont(inc: BOOLEAN);
(* increase or decrease font size *)
VAR tmpint: INTEGER;
    ismedium: BOOLEAN;
BEGIN
  ismedium:= FALSE;
  IF (defcharht = 9) & (fullW > 600) THEN (* medium res *)
    ismedium:= TRUE;
  END;
  tmpint:= cfg.charht; (* current font *)
  IF inc THEN (* increase *)
    IF (cfg.charht = 8) OR (cfg.charht = 9) THEN
      INC(cfg.charht);
      IF ismedium & (cfg.charht = 10) THEN
        cfg.charht:= 16; (* no 8 x 16 med res, it crashes ! *)
      END;
    ELSIF cfg.charht = 10 THEN
      cfg.charht:= 16;
    ELSIF cfg.charht < 20 THEN
      INC(cfg.charht, 2);
    END;
  ELSE (* decrease *)
    IF cfg.charht > 16 THEN
      DEC(cfg.charht, 2);
    ELSIF cfg.charht = 16 THEN
      cfg.charht:= 10;
      IF ismedium THEN (* med res *)
        cfg.charht:= 9; (* no 8 x 16 med res, it crashes ! *)
      END;
    ELSIF cfg.charht > 8 THEN
      DEC(cfg.charht);
    END;
  END;
  IF tmpint <> cfg.charht THEN (* font changed, so redisplay *)
    EndFont;
  END;
END KeyFont;

PROCEDURE ChooseFont;
BEGIN
(*
  int:= 1; (* default to big font *)
  IF rowH = 8 THEN
    int:= 2;
  ELSIF rowH = 6 THEN
    int:= 3;
  END;
*)
  int:= 3; (* default to big font *)
  IF (cfg.charht > defcharht) OR (cfg.charht < defcharht) THEN
    int:= 2;
  END;
  Showmouse; (* lineA Show mouse *)
  result:= FormAlert(int,"[2][   Choose Font Size][Bigger|Default|Smaller]");
  CODE(0A00AH); (* lineA Hide mouse *)
  IF result = 1 THEN
    KeyFont(TRUE); (* inc *)
  ELSIF result = 3 THEN
    KeyFont(FALSE); (* dec *)
  ELSE
    cfg.charht:= defcharht;
    EndFont;
  END;
(*
  IF int <> result THEN (* changed fonts *)
    cfg.charht:= 13;
    IF result = 2 THEN
      cfg.charht:= 27;
    ELSIF result = 3 THEN
      cfg.charht:= 4;
    END;
*)
(*
    EndFont;
*)
(*
  END; (* if changed fonts *)
*)
END ChooseFont;

PROCEDURE EndFont;
(* handles display after any font change *)
BEGIN
  SetFont;
  (* set possible adjustments to window size due to 6x6 font or 8x8=>8x16 *)
  CheckSize;
(**  (* EdPlus test *)
  update:= FALSE;
**)
  Setxywh;
  InitMenu; (* sets new clipping area, needed for Display *)
  Display(0, cfg.maxdispline);
  IF (curdispline > cfg.maxdispline)
      OR (linepos > displaylen) THEN (* get cursor into window *)
    Bottom; (* puts cursor at last text in shrunk window *)
  ELSE
    CursorPos(curdispline, leftedge + linepos);
  END;
END EndFont;

PROCEDURE SetFont;
BEGIN
  IF (defcharht = 9) & (cfg.charht = 10) & (fullW > 600) THEN
    cfg.charht:= 6; (* no 8 x 16 med res, it crashes ! *)
  END;
  cfg.charht:= SetPointCharHeight(VDIHandle, cfg.charht, dummy, dummy, colW, rowH);
  WindowCalc(1, GEMAESbase.Mover + GEMAESbase.Name + GEMAESbase.Fuller +
     GEMAESbase.VertSlide + GEMAESbase.HorizSlide + GEMAESbase.Sizer +
     GEMAESbase.Closer, fullX,fullY,fullW,fullH, 
     workX, workY, workW, workH); (* return workxywh *)

  scrnmaxdispln:= CARDINAL(workH DIV rowH) - 1;

(******
  IF cfg.maxdispline > scrnmaxdispln THEN
    cfg.maxdispline:= scrnmaxdispln;
  END;
  (** could get wind1H by windowcalc of workH=rowH * (cfg.maxdispline+1) **)
  wind1H:= rowH * INTEGER(cfg.maxdispline+1) + offset + offset;
*******)
(**
  InquireTextAttributes(VDIHandle, TextAttr);
**)
(***++*
  SetContrl(38, 0, 0, 0, VDIHandle);
  CallVDI;
  rowH:= ptsout[3];
  colW:= ptsout[2];
*++***)
END SetFont;

PROCEDURE InitWinSize;
BEGIN
(*
  WindowGet(0, 4, fullX, fullY, fullW, fullH); (* desktop workxywh *)
*)
  WindowGet(0, 4, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H); (* desktop workxywh *)
(*
  maxX:= cfg.wind1W;
*)
  maxY:= cfg.wind1Y + wind1H;
  fullX:= cfg.wind1X;
  fullY:= cfg.wind1Y;
  fullW:= cfg.wind1W;
  fullH:= wind1H;
(*
  wind1H:= fullH;
*)
END InitWinSize;


PROCEDURE InitBuffSize;
BEGIN
  IF daccTitle[0] = 0C THEN (* prg, grab desired ram *)
    (* find largest free ram block *)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(LONGINT(-0001H)); (* to get largest free ram block *)
    PUSH(048H); (* malloc code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
    tmplong:= LONGCARD(REGISTER(D0));
(**)
    IF tmplong > cfg.minsys + (6 * 1024) THEN
      DEC(tmplong, cfg.minsys); (* leave enough RAM for system *)
      IF tmplong > 3 * cfg.maxbuff DIV 2 THEN (* truncate to user max *)
        tmplong:= 3 * cfg.maxbuff DIV 2;
      END;
(**
      IF daccTitle[0] <> 0C THEN (* acc *)
        tmplong:= 6 * 1024;
      END;
**)
      (* get integral # of 1K blocks *)
      buffsize:= 2*tmplong DIV 3;
      buffsize:= buffsize DIV 0400H;
      buffsize:= buffsize * 0400H;
      tmplong:= buffsize * 3 DIV 2;
      IF buffsize > (16 * 0FFFFH) THEN
        maxlines:= 0FFFFH;
        buffsize:= tmplong - 080000H; (* 8 * LONG(maxlines+1) *);
      ELSE
        maxlines:= SHORT(buffsize DIV 16);
      END; (* if truncate maxlines *)
(***
      newbuffsize:= buffsize; (* this is only used for acc buffer *)
***)
      (* grab desired ram *)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
      PUSH(tmplong); (* to grab ram block for buffer+lineptrs+pastebuff *)
      PUSH(048H); (* malloc code *)
      CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
      CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
      (* restore all necessary registers *)
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
      tmpadr:= REGISTER(D0);
      (* set startadr to beginning of block *)
      startadr:= tmpadr;
      lnptradr:= startadr + ADDRESS(buffsize); (* start of lnptrarray *)
      newlnptradr:= lnptradr + ADDRESS(4*LONG(maxlines));

      longptr:= lnptradr;
      longptr^:= 0; (* needed for initial setfoundpos! *)

      DEC(maxlines); (* since was 0..maxlines, and now is 1 less length *)
(**)
    ELSE (* no room *)
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1,'[3][Not enough free RAM][ OK ]');
      CODE(0A00AH); (* lineA Hide mouse *)
    END; (* if enough ram *)
(**)
(******)
  END; (* if grabram *)
(*******)
  tmplong:= 0800H; (* 2K *)
  IF buffsize < 02800H THEN (* only leave 1K open if buffer < 10K *)
    tmplong:= 0400H; (* 1K *)
  END; 
  blocksize:= buffsize - tmplong; (* leaves 1K or 2K space for additions *)
  kperblock:= SHORT(blocksize DIV 0400H); (* 1K *)
END InitBuffSize;


PROCEDURE Init;
VAR temppath: Pathtype;
BEGIN
  stack:= 0; (* into supervisor to get PhysTop *)
  Super(stack);
  SETREG(A0, PHYSTOP); (* 1070 *)
  adrptr:= REGISTER(A0); (* 1070 *)
  maxadrlcard:= LONGCARD(adrptr^);
  maxmem:= maxadrlcard - 1; (* 0280000H - 1 since maxadrlcard is 1st address BEYOND physical ram *)
  INC(adrptr, 4);
  membot:= LONGCARD(adrptr^); (* 1074 mem_bot *)
  Super(stack); (* back out of super mode *)
(*  startadr:= ADR(charray); *)
  mfdb:= ADR(mfdbrec);
  mfdb^.pointer:= 0;
(*
  inout:= in;
*)
  typeahead:= 0C;
  menuTitle:= ' Menu ';
(**)
  (* File menu *)
  item[0]:=  'Open...     O';
  item[1]:=  'Save...     S';
  item[2]:=  'Help!       H';
  item[3]:=  'Print...    P';
  item[4]:=  'Upload...   U';
  item[5]:=  'New cnfig?  N';
  item[6]:=  'macros...  F9';
  item[7]:=  'Launch...   L';
  item[8]:=  'Quit        Q';
  (* Edit menu *)
  item[9]:=  'Find/replc  F';
  item[10]:= 'Wrap/refmt  W';
  item[11]:= 'Insert any  I';
  item[12]:= 'Date insrt  D';
  item[13]:= 'Text/Hack   T';
  item[14]:= 'to block menu';
  item[15]:= 'Go to...    G';
(*
  item[15]:= 'View/edit RAM';
*)
  item[16]:= 'mark all    E';
  item[17]:= 'Clear buff  C';
(***)
  (* Block menu *)
  item[18]:= 'Merge...    M';
  item[19]:= 'Save...     S';
  item[20]:= 'to main menu ';
  item[21]:= 'Print...    P';
  item[22]:= 'Upload...   U';
  item[23]:= 'cpy->clip  F7';
  item[24]:= 'cut->clip  F7';
  item[25]:= 'past<-clip F8';
  item[26]:= 'col<-clip  F8';
  (* 2nd col of block menu *)
  item[27]:= 'quote ">"   _';
  item[28]:= 'Wrap/refmt  W';
  item[29]:= 'shift    _/ _';
  item[30]:= 'Edit caps   E';
  item[31]:= 'Kwiksend    K';
  item[32]:= 'cpy->buff  F4';
  item[33]:= 'cut->buff  F4';
  item[34]:= 'past<-buff F5';
  item[35]:= 'col<-buff  F5';
(***)
  pathmark:= ':\';
  bslash:= '\';
  (* lnptrarray[0]:= 0; *)

  (* 32 bit *)
  longptr:= lnptradr;
  longptr^:= 0;

(**209* revert to old method since ClearAll assumes window is open,
  & locks up in TOS 1.0 from GOGO & probably others **);
  (* moved to ClearAll: *)
(* 2.30 *
  Title1:= ' EdHak ';
*)
(*** 3.1C ***)
  buffline:= 0;
(***)
  last:= 0;
  lastline:= 0;
  fileend:= 0; (* 3.12 *)
  saved:= TRUE;
  bigpart:= FALSE;
  MiniInit;

  dummy:= 0;
(*ds*)
(*
  memadr:= 0; (* for viewing/editing memory *)
*)
  pastelen:= 0;
(*
  oldblock:= 0;
*)
  startfileblk:= 0;
  startramblk:= 0;
  startsect:= 0;

  (* charray[0]:= 0C; *)
  oldfindstrg[0]:= 0C; (* full search string *)
  findstrg[0]:= 0C; (* converted search string *)
  repstrg[0]:= 0C; (* converted replace string *)
  oldrepstrg[0]:= 0C; (* converted replace string *)
  findbtn:= TXTBTN;
  alertstrg1:= '[2][    Word Wrap Functions    ][Wrap!...|Cancel|Turn ';
  alertstrg3:= 'OFF]';
  alertstrg4:= 'ON]';
(*ds*)

  (* Get full current path for *.*  *)
(**
  GetDrv(j); (* 0=A, 1=B,... *)
  ch:= CHR(65 + j); (* 65 = 'A' *)
  temppath[0]:= ch; temppath[1]:= 0C; (* A *)
  Concat(temppath, pathmark, configpath); (* gives A:\ *)
  GetPath(path, 0); (* 0=current drive, but doesn't give drive or last \ *)
  IF path[0] <> 0C THEN (* there's something there *)
    configpath[2]:= 0C; (* removes '\' before adding another *)
    Concat(configpath, path, temppath); (* gave A:\\path *)
    Concat(temppath, bslash, configpath); (* gives A:\path\ *)
  END; (* if subdirectory/folder *)
**)

  (* cfg.oldpath[0] = drive letter from editproc.mod *)
  cfg.oldpath[1]:= 0C; (* A *)
  Concat(cfg.oldpath, pathmark, configpath); (* gives A:\ *)
(*
  GetPath(path, 0); (* 0=current drive, but doesn't give drive or last \ *)
*)
  (* fsel is from GetPath in editproc.mod *)
  IF fsel[0] <> 0C THEN (* there's something there *)
    configpath[2]:= 0C; (* removes '\' before adding another *)
    Concat(configpath, fsel, temppath); (* gave A:\\path *)
    Concat(temppath, bslash, configpath); (* gives A:\path\ *)
  END; (* if subdirectory/folder *)

  (***** Config stuff *****)
(*demo*)
  IF NOT ReadConfig() THEN (* config file not found/read ok, so init vars *)
(*demo*)
    cfg.tabspaces:= 5;
    cfg.insertmode:= TRUE; (* yes, you are inserting *)
    cfg.eollen:= 2; (* assume cr/lf at end of each line *)
    cfg.autowrap:= (*ds* FALSE; *ds*) TRUE; (*ds*) (* FALSE for S versions *)
    cfg.autoload:= FALSE;
    cfg.textwrapW:= 0; (* just so we know that the user hasn't set it *)
    cfg.printmargin:= 0;
    cfg.maxdispline:= 0; (* will be scrnmaxdispln; *)
    cfg.defoverwrite:= 1; (* default to overwrite in save dialog *)
    cfg.casesens:= FALSE;
    cfg.printsetup:= FALSE;
    cfg.dobak:= FALSE;
(*213*)
    cfg.hackable:= TRUE; (* FALSE; *)(* finally added in 2.13 *)
    cfg.deffind:= 2; (* default to Pick *)
(*213*)
(* 2.30 *)
    cfg.autoindent:= FALSE; (* 2.30 1/15/92 *)
    cfg.eurodate:= 1C; (* cfg.eurodate:= TRUE; *)
    cfg.hexdisp:= FALSE; (* for hack offset/char display *)
    cfg.charht:= 0;
    cfg.wind1Y:= fullY; (* wind1Y in case of incorrect cfg *)
    cfg.wind1X:= fullX;
    cfg.wind1W:= fullW; (* H is handled via cfg.maxdispline *)
(***)
  (*ep-*)
    cfg.eolchar:= 0C; (* ' ';*) (* 15C = 'cr', or use space or 4C or '<' *)
  (*ep+*
    cfg.eolchar:= 15C;
  *ep*)
    cfg.askall:= 1; (* 3.2A *)
    cfg.kwikstrip:= 1; (* 3.2B *)
    cfg.fsel0:= 'EDITPLUS'; (* was '' 2.30 *)
    cfg.oldpath:= configpath;
(** $ **)
    cfg.needclick:= FALSE; (* for testing use only *)
(** $ **)
(*demo*)
  ELSE (* did find & read config file *)
    IF cfg.kwikstrip <> 2 THEN
      cfg.kwikstrip:= 1;
    END;
    IF cfg.askall <> 2 THEN
      cfg.askall:= 1;
    END;
    IF cfg.defoverwrite <> 2 THEN
      cfg.defoverwrite:= 1;
    END;
(*213*)
    IF cfg.deffind <> 1 THEN (* must be either pick(2) or find(1) *)
      cfg.deffind:= 2; (* 2 = pick *)
    END;
(*213*)
(*
    cfg.needclick:= cfg.hexdisp; (* for testing *)
*)
(**^^*)
    IF cfg.charht = 6 THEN (* for cfg based on pixel height instead of points *)
      cfg.charht:= 9;
    ELSIF cfg.charht = 4 THEN
      cfg.charht:= 8;
    END;
(*^^**)
  END; (* if no config file *)
(*demo*)
(*+
  (** could get wind1H by windowcalc of workH=rowH * (cfg.maxdispline+1) **)
  wind1H:= rowH * INTEGER(cfg.maxdispline+1) + offset + offset;
+*)
(*****
  IF (buffsize = 0) (* cfg.needclick & (daccTitle[0] = 0C) *) (* grabram, PRG *) THEN
******)
  IF cfg.maxbuff < 20 * 1024 THEN
    cfg.maxbuff:= 20 * 1024;
  END;
  IF cfg.minsys < 40 * 1024 THEN
     cfg.minsys:= 40 * 1024;
  END;
  InitBuffSize;

  (* 2.30 *)
  Concat(cfg.oldpath, cfg.fsel0, fsel); (* gives e.g., A:\path\*.* *)
  MoveMem(ADR(cfg.fsel0), ADR(Title1), LONG(Length(cfg.fsel0)+1));
  path:= cfg.oldpath;
  savedeolchar:= cfg.eolchar;
(*ds*)
  WrapCheck; (* assigns correct string for wrap toggle dialog *)
(*ds*)
  Hexset:= Charset{'0'..'9','A'..'F','a'..'f'};
  INCL(Hexset, 0C);
  lastcol:= 80; (* for H slider *)
END Init;

PROCEDURE CheckSize;
(* makes window size conform to char cell boundaries *)
(* adjusts wind1XYWH *)
(* used for both resizes and moves *)
VAR w, h: INTEGER; (* temp for new wind1xywh *)
BEGIN
(* keep fully on screen *)
(*
  CheckwinY(cfg.wind1Y); (* forces vert cell alignment *)
*)
  IF cfg.wind1Y < offset THEN
    cfg.wind1Y:= offset;
  END;
  IF cfg.wind1Y + offset > maxY THEN (* limit how far down window can go *)
    cfg.wind1Y:= maxY - offset;
  END;
(* keep on screen x & w *)
  IF cfg.wind1X + colW > fullW THEN
    cfg.wind1X:= fullW - colW;
  END;
  IF cfg.wind1W > fullW THEN
    cfg.wind1W:= fullW;
  ELSE
    INC(cfg.wind1W, 2); (* keep from auto-downsizing? *)
  END;
  IF wind1H > fullH THEN
    wind1H:= fullH;
  END;
  INC(cfg.wind1X, colW);
(*
  INC(wind1H, rowH); (* ?? *)
*)
  WindowCalc(1, GEMAESbase.Name + GEMAESbase.VertSlide + GEMAESbase.HorizSlide +
    GEMAESbase.UpArrow + GEMAESbase.DownArrow + GEMAESbase.Mover +
    GEMAESbase.Closer + GEMAESbase.Fuller + GEMAESbase.Sizer,
    cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H, workX,workY,workW,workH); (* return workxywh *)
(*
 Ensure minimum width of 38 chars to allow title bar info
*)
  w:= colW * 38;
  IF(workW < w) THEN
    workW:= w; (* set to minimum width *)
  END;
(***
  w:= colW * 129; (* 3.02 *)
  IF(workW > w) THEN
    workW:= w; (* set to max width per VDI 128 char limit *)
  END;
***)
(*
  now force char alignment of left edge & width
*)
(**  (* this not right for 6x6 font *)
  workX:= INTEGER(BITSET(workX) * BITSET(0FFF8H)); (* bitwise AND *)
**)
  IF workX < colW THEN
    workX:= colW;
  ELSE
    workX:= workX DIV colW;
    workX:= workX * colW;
  END;
  w:= workW DIV colW;
  IF workW MOD colW <> 0 THEN
    workW:= w * colW; (* truncate *)
  END;
(*
 now check height, min & char alignment
*)
  h:= rowH * 9;
  IF(workH < h) THEN
    workH:= h; (* set to minimum height *)
  ELSE (* trim to exact multiple of rowH *)
    workH:= workH DIV rowH;
    workH:= workH * rowH;
  END;
(*
 now recalc exterior from aligned interior
*)
  WindowCalc(0, GEMAESbase.Name + GEMAESbase.VertSlide + GEMAESbase.HorizSlide +
    GEMAESbase.UpArrow + GEMAESbase.DownArrow + GEMAESbase.Mover +
    GEMAESbase.Closer + GEMAESbase.Fuller + GEMAESbase.Sizer,
    workX,workY,workW,workH, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H); (* return windxywh *)
  DEC(cfg.wind1X, colW); (* leave blank margin *)
END CheckSize;


PROCEDURE Setxywh;
BEGIN
  WindowSet(Window1, GEMAESbase.CurrXYWH, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
  WindowGet(Window1, GEMAESbase.WorkXYWH, workX,workY,workW,workH) ;
  cfg.maxdispline:= workH DIV rowH - 1;
  displaylen:= CARDINAL(workW DIV colW) - lm; (* was widthfont *)
  pageW:= displaylen + 1; (* use something else if do half page scrolls ? *)
  leftedge:= CARDINAL(workX DIV colW) + lm (* - 1 *);

  menuX:= cfg.wind1X + (3 * colW);
  menubX:= menuX + 1;
  noticharX:= cfg.wind1X + ((cfg.wind1W+1) DIV 2) + 56; (* 7 * colW; *)
  noticharX:= noticharX DIV colW; (* force onto char boundary for speed *)
  noticharX:= noticharX * colW;
  noticeX:= menuX + 56;
  IF (displaylen < 42) THEN (* low res or small window, so not room to leave for filename *)
    DEC(noticharX, 16); (* 2 * colW); *)
    noticeX:= noticharX; (* put it over where there's room *)
  END;
  SetSlideSize;
  SetSlidePos;
  SetHSlideSize;
  SetHSlidePos;
END Setxywh;

(*ds*)
PROCEDURE NotiChar;
(* allow either hex or dec status display in hack mode 2.30 1/15/92 *)
VAR numlen: CARDINAL;
    numstrg2: ARRAY[0..7] OF CHAR; (* hex char code [00..FF] *)
    strg: ARRAY[0..13] OF CHAR;
BEGIN
  IF cfg.eollen <> 0 THEN (* text mode: show line, column in decimal *)
    strg:= 'L:00000 C:000';
    IF startf > 0 THEN (* bigfile offset from start *)
      strg[1]:= '+';
    END;
    (*** 3.1C ***)
    Cardtostrg(LONG(buffline+line+1+curdispline), numstrg2, FALSE, 5); (* line in decimal *)
    MoveMem(ADR(numstrg2), ADR(strg) + ADDRESS(2), 5); (* strg[2..6] *)
    Cardtostrg(LONG(startcol+linepos+1), numstrg2, FALSE, 3); (* get 5 digit dec *)
    MoveMem(ADR(numstrg2), ADR(strg) + ADDRESS(10), 3); (* strg[10..12] *)
  ELSE  (* eollen = 0, hack mode: show offset in decimal & char value in hex *)
    strg:= '#000000 c:$00';
    IF startf > 0 THEN (* bigfile offset from start *)
      strg[0]:= '+';
    END;
    (* first fill in n:xxxxx *)
    (*** 3.1C ***)
    numlen:= 7; (* for decimal up to 9+ megs *)
    IF cfg.hexdisp = TRUE THEN
      numlen:= 6;
    END; (* if hex *)
    Cardtostrg(startf+i, numstrg2, cfg.hexdisp, numlen); (* offset in hex or dec *)
    MoveMem(ADR(numstrg2), ADR(strg) + ADDRESS(7-numlen), LONG(numlen)); (* strg[2..6] *)
    (*** 3.1C ***)
    
    (* now fill in c:xx character value *)
    (**2.1**)
    ptr1:= startadr + ADDRESS(i); (* char value [0..255] *)
    IF i < last THEN
(**)
        Cardtostrg(LONG(ORD(ptr1^)), numstrg2, cfg.hexdisp, 3); (* true = show in hex *)
        MoveMem(ADR(numstrg2), ADR(strg) + ADDRESS(10), 3); (* strg[11..12] *)
    END;
    IF cfg.hexdisp THEN
      strg[0]:= '$';
      strg[10]:= '$';
    END;
    IF i >= last THEN (* i >= last, so no char value should display *)
      strg[10]:= '-';
      strg[11]:= '-';
      strg[12]:= '-';
    END; (* if i = last in hack mode *)
  END; (* if in text vs hack mode *)
(*
  GraphicText(VDIHandle, noticharX, cfg.wind1Y+menubH, strg);
  Graphictext(VDIHandle, noticharX, cfg.wind1Y+menubH, ADR(strg), Length(strg));
*)
(**^^*)
  IF cfg.charht > defcharht THEN
(*
    SetAbsCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
*)
    dummy:= SetPointCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
  END;
  Graphictext(VDIHandle, noticharX, workY-2, ADR(strg), Length(strg));
(**)
  IF cfg.charht > defcharht THEN
(*
    SetAbsCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
*)
    cfg.charht:= SetPointCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
  END;
(*^^**)
(**)
END NotiChar;
(*ds*)

PROCEDURE Notice; (* (notistrg: ARRAY OF CHAR); *)
BEGIN
(**^^*)
  IF cfg.charht > defcharht THEN
(*
    SetAbsCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
*)
    dummy:= SetPointCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
  END;
  Graphictext(VDIHandle, noticeX, workY-2, ADR(notistrg), Length(notistrg));
  IF cfg.charht > defcharht THEN
(*
    SetAbsCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
*)
    cfg.charht:= SetPointCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
  END;
(*^^**)
END Notice;

PROCEDURE InitMenu;
(* sets window title and notices *)
BEGIN
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy); (* wx,wy,ww,wh); *)
  IF Window1 = topwind THEN
    (* Set title *)
    WindowSet(Window1, GEMAESbase.WindowName,
                INTEGER(ADR(Title1) DIV 010000H),
                INTEGER(ADR(Title1) MOD 010000H), 0,0) ;
(*
    menubY:= cfg.wind1Y + 2; (* was + 1 *)
*)
    menubY:= workY - menubH - 1; (* 3.0n *)

(**^^*)
(*
    SetAbsCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
*)
    dummy:= SetPointCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
(* height = 13 mono, 6 color *)

(*
    GraphicText(VDIHandle, menubX, cfg.wind1Y+menubH, menuTitle);
*)
    Graphictext(VDIHandle, menubX, workY-2, ADR(menuTitle), Length(menuTitle));
(*
    SetAbsCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
*)
    cfg.charht:= SetPointCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
(*^^**)
    Notice;
    (*ds*) NotiChar; (*ds*)
(*
    SetClipxy(workX, workY, workX+workW, workY+workH);
*)
(******* test **
    SetClipFill(workX, workY, workX+workW, workY+workH, TRUE);
** test *******)
    SetClipFill(1,1,fullW (* maxX *), maxY, TRUE);
    SetClipping(VDIHandle, 1, clipxy2);

    (* why? because need it after fselect *)
  END; (* if on top *)
END InitMenu;

(* ------------  Start Window Routines  ------------------------------- *)

PROCEDURE Windfix; (* stops underlying windows from overwriting dialog box *)
BEGIN
  FOR j:= 1 TO Window1 DO (* max windows open underneath Diary? *)
    WindowUpdate(0); (* end *)
    WindowUpdate(1); (* start *)
  END;
END Windfix;

PROCEDURE InitWindow(): BOOLEAN;
BEGIN
(*
  menubH:= offset - 4; (* was rowH - 1 *);
*)
  menubH:= defrowH; (* 3.0n *)
  menubW:= 6 * colW;
(*
    Showmouse;  (* lineA Show mouse *)
    dummy:= FormAlert(1,'[3][Start InitWind][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
*)
  (* Set vdi text vert alignment to bottom of cell *)
  SetGraphicTextAlignment(VDIHandle, 0, 3, dummy, dummy);

  update:= TRUE;
  (* Set fill for blanking operations *)
  dummy:= SetFillInteriorStyle(VDIHandle,1) ; (* Set solid fill *)
  dummy:= SetFillColour(VDIHandle,GEMAESbase.White) ; (* Set white *)
  (* Create space for window *)
  Window1:= WindowCreate(GEMAESbase.Name + GEMAESbase.VertSlide +
     GEMAESbase.UpArrow + GEMAESbase.DownArrow + GEMAESbase.Mover +
     GEMAESbase.Closer+GEMAESbase.Fuller+GEMAESbase.Sizer +
     GEMAESbase.HorizSlide + GEMAESbase.LeftArrow + GEMAESbase.RightArrow,
     fullX,fullY,fullW,fullH);
  IF Window1 < 0 THEN (* no window handles left on desktop, 2.30 1/12/92 *)
(**
    mhideptr^:= 1; (* 2.30I 2/5/92 *)
**)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[3][Too Many Windows|Already Open][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN FALSE; (* thanks to Chet Walters *)
  END; (* if can't open window *)
  (* Set title *)
  WindowSet(Window1, GEMAESbase.WindowName,
            INTEGER(ADR(Title1) DIV 010000H),
            INTEGER(ADR(Title1) MOD 010000H), 0,0) ;
  CheckSize; (* of wind1X,Y,W,H *)
  (* Draw the window *)
  WindowUpdate(1); (* start try 2.3Q *)
  WindowOpen(Window1, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
  Windfix; (* yes! *)
  WindowUpdate(0); (* end *)
  Setxywh;
  FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, cfg.wind1X,cfg.wind1Y,cfg.wind1W-1,wind1H-1);

  wrapW:= cfg.textwrapW; (* to what user set it as *)
  IF cfg.textwrapW = 0 THEN (* not set, so set textwrapW to default *)
    wrapW:= displaylen;
    cfg.textwrapW:= wrapW;
  END;
  IF cfg.eollen = 0 THEN (* hack mode *)
    wrapW:= 64;
(**+
    IF ((res = 0) OR (res = 7)) THEN
+**)
    IF fullW < 64 * colW THEN
      wrapW:= 32;
    END; (* if lo res *)
  END; (* if hack mode *)
  (* InitMenu; *)(* Already done by Redraw.  also sets title *)
(*
  CursorPos(curdispline, lm + linepos); (* must happen before first CursorDraw *)
*)
(***
  (* moved since is no VDI handle here at times? *)
  SetFoundPos(FALSE); (* don't force top *)
  SetSlideSize;
  SetSlidePos;
***)
  kwiksend:= FALSE;
  RETURN TRUE;
END InitWindow ;

PROCEDURE CloseWindow(window: INTEGER);
VAR result: INTEGER;
BEGIN
  (* 2.30 1/2/92, 1/18/92 1/21/92, 1/26/92 *)
(*
  IF (Window1 > 0) & (window > 0) THEN (* window3 must never be done if no window1 exists *)
    WindowGet(Window1, 11, dummy, result, dummy,dummy); (* 1stxYwh *)
    IF result <> cfg.wind1Y THEN (* wind1 IS open, so is vdihandle so do it *)
*)
  IF (VDIHandle >= 0) & (window > 0) THEN
      WindowClose(window);
      WindowDelete(window);
(**
      IF window = Window3 THEN
        InitMenu;
      END;
**)
(*
    END; (* if window1 is open => window3 would have been made *)
*)
  END; (* if window1 has ever been opened *)
END CloseWindow ;

PROCEDURE ClearWindow(window: INTEGER);
VAR workX,workY,workW,workH: INTEGER;
BEGIN
  WindowGet(window, GEMAESbase.WorkXYWH, workX,workY,workW,workH) ;
(*
  ClearArea(workX, workY, workW, workH);
*)
  SetClipFill(workX, workY, workW, workH, FALSE); (* F = fill *)
END ClearWindow ;

PROCEDURE DoTop(isclosed: BOOLEAN); (* tops Diary window *)
BEGIN
  (* 2/5/92 *)
(**+*)
  menuok:= FALSE;
(*+**)
  update:= FALSE; (**)
  IF isclosed THEN
    WindowOpen(Window1, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
    isclosed:= FALSE;
  ELSE (* window not closed *)
    Windfix; (**)
    WindowSet(Window1, GEMAESbase.Top, dummy,dummy,dummy,dummy);
  END; (* if window needed re-opening *)

  Windfix; (* yes! *)
  FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);

  CODE(0A00AH); (* lineA Hide mouse *)(* since was showing as not topwind *)
  Display(0, cfg.maxdispline); (**)

  (* to be safe, 2.30 1/19/92... *)
  CursorPos(curdispline, leftedge+linepos); (* reset cursor to i *)
  SetSlideSize; (* needed in case background capture was going on *)
  SetSlidePos; (* ditto *)
END DoTop;

(* ---------  Start File I/O  ----------------------------- *)

PROCEDURE Selecthead(strg: ARRAY OF CHAR; show: BOOLEAN);
(* use dialog instead of window, 2.30 1/25/92 *)
VAR x,y,w,h: INTEGER;
    tedptr: POINTER TO GEMAESbase.TEdInfo;
BEGIN
  InitObjStrg(FSELTITL, FSELSTRG, strg); (* sets global treeptr *)
(*
  treeptr:= TreeAddr^[FSELTITL];
*)
  FormCenter(treeptr, x,y,w,h);
  y:= offset; (* any higher overwrites menu bar, and it doesn't redraw *)
  treeptr^[0].y:= y;
  IF show THEN
    tedptr:= treeptr^[FSELSTRG].spec;
    MoveMem(ADR(strg), tedptr, LONG(Length(strg)+1)); (* +1 for final 0C not needed? *)
    FormDialogue(GEMAESbase.FormStart, 0,0,0,0, x,y,w,h);
    ObjectDraw(treeptr, 0, 2, x,y,w,h);
  ELSE (* get rid of it *)
    FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, x,y,w,h);
(*
    InitMenu;
    FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
*)
  END; (* if show *)
END Selecthead;


PROCEDURE Fselect(VAR wantpath: Pathtype; VAR fseltmp: Fseltype;
          VAR fsel0ret: Fsel0type; newfile, carename: BOOLEAN): BOOLEAN;
(** NOTE you MUST call Selecthead before calling this **)
(* always returns new path in tmp global variable 'path' with final \ *)
(* carename = TRUE => return false if filename is null *)
(* add fsel0ret, 2.37 10/14/92 to fix block save to sectors *)
VAR (* fsel0tmp: Fsel0type; *)(* so if cancel, filename won't change *)
    j: CARDINAL; (* to hold length of path, 2.30 1/12/92 *)
    result: INTEGER; (* 2.30 1/12/92 *)
BEGIN
(*
  Concat(cfg.oldpath, ext, path);
*)
(**)
  Concat(wantpath, ext, path);
(**
  path:= wantpath; (* exp 2.30, works great except LGFSel needs *.*! *)
**)
  fsel0ret:= cfg.fsel0;
(**
  mresetptr^:= 0; (* reset flag *) (* test 1/20/92?? *)
**)
  Showmouse; (* lineA Show mouse *)
  FileSelectorInput(ADR(path), ADR(fsel0ret), result);
  CODE(0A00AH); (* lineA Hide mouse *)
(*
  CloseWindow(Window3); (* close selecthead *)
*)
  Selecthead(ext, FALSE); (* just use ext as dummy string *)

  (* strip wildcards & filename so setpath works *)
  (* moved here for 2.30 1/13/92 *)
  j:= Length(path); (* was -1, but stripped for safety *)
  WHILE (path[j] <> '\') AND (j > 0) DO
    path[j]:= 0C;
    DEC(j);
  END; (* while *)

  IF result = 0 THEN (* CANCEL *)
    RETURN FALSE;
(****)
(* 2.30 1/25/92 NOTE: hackable no longer of any use! *)
(*dr+*)
  ELSIF (fsel0ret[0] = 0C) & carename (* & (NOT cfg.hackable) *) THEN (* need some filename *)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[1][No Filename selected][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN FALSE;
(*dr*)
(****)
  END; (* if cancel or no filename *)
  IF newfile THEN
    cfg.fsel0:= fsel0ret;
(*
    cfg.oldpath:= path;
*)
  END; (* if newfile *)
(* 2.30 *)
  wantpath:= path;
  Concat(path, fsel0ret, fseltmp);
  RETURN TRUE;
END Fselect;

(*
PROCEDURE ChangeExt(VAR fname: ARRAY OF CHAR; ext: ARRAY OF CHAR);
(* fname is just name or whole path? 1st *)
VAR j,k,len: CARDINAL;
BEGIN
  len:= Length(fname);
  j:= len;
  k:= 0;
  WHILE (j > 0) & (k < 4) DO (* find current '.' if exists *)
    DEC(j);
    INC(k);
    IF fname[j] = '.' THEN
      k:= 4; (* force end, yes I know 2 would work fine too. *)
    END;
  END; (* while finding '.' *)
  IF fname[j] <> '.' THEN (* '.' wasn't found, so tack onto end *)
    j:= len; (* '.' wasn't found, or is at position zero *)
  END;
  fname[j]:= '.';
  INC(j);
  FOR k:= 0 TO 2 DO
    fname[j + k]:= ext[k];
  END; (* for *)
  fname[j + 3]:= 0C; (* terminate *)
END ChangeExt;
*)

(*
PROCEDURE WriteErr;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[1][Cancelled or disk full][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
END WriteErr;
*)

PROCEDURE BlockInit23; (* Sets default lines 2, 2A, 3 of block dialog *)
BEGIN
  InitObjStrg(BLCKTREE, BLOKTXT2, 'Copy Block of Size (K): ');
  Cardtostrg(LONG(kperblock), cardstrg, FALSE, 5); (* show in dec *)
  InitObjStrg(BLCKTREE, BLOKTX2A, cardstrg);
  InitObjStrg(BLCKTREE, BLOKTXT3, 'Starting at which 1K boundary?');
END BlockInit23;

(*dr*)
(*
PROCEDURE DiskOpen(readwrite: RW; startblk: LONGCARD; VAR endblk: LONGCARD): BOOLEAN;
*)
PROCEDURE DiskOpen(readwrite: CARDINAL; startblk: LONGCARD; VAR endblk: LONGCARD): BOOLEAN;
(* for reading/writing disk sectors *)
VAR drivenum, numsectors: CARDINAL;
    (* tmplong: LONGCARD; *)
    numbytes: LONGCARD;
    indexadr: ADDRESS;
    loadres: INTEGER;
    getnew, found, ok: BOOLEAN;
BEGIN 
  (* get pointer to BIOS parameter block for chosen drive *)
  (* later add check for drives on line? *)
  found:= TRUE; (* for non search operations *)
  drivenum:= ORD(cfg.oldpath[0]) - 65; (* drive number, A = 0 ... *)
  bpbptr:= ADDRESS(BconinGetBPB(drivenum, 7)); (* 7=GetBPB opcode *)
  IF ADDRESS(bpbptr) = 0 THEN (* drive not available? *)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[1][Sorry, Drive not available?][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN FALSE;
  END; (* if error *)
  InitObjStrg(BLCKTREE, BLOKTXT2, 'Copy this many Sectors: ');
  InitObjStrg(BLCKTREE, BLOKTXT3, 'Starting at which disk sector?');
  IF readwrite = 0 THEN (* 0 = Read *)
(** NOTE: This old way assumed 512 byte sectors! **
    numsectors:= kperblock + kperblock; (* Read: # of sectors to fill blocksize *)
***2.11**)
    numsectors:= SHORT(LONG(kperblock) * 0400H DIV LONG(bpbptr^.recsiz));
(***)
    InitObjStrg(BLCKTREE, BLOKTXT1, 'Read Sectors From Disk');
(**********...*)
    (* ask if pick block to read or search *)
(**)
(**)

    Showmouse; (* lineA Show mouse *)
    loadres:= FormAlert(cfg.deffind,"[2][Find string on disk|or Pick sector][ Find |Pick|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF loadres = 3 THEN
      RETURN FALSE;
    END; (* if cancel *)
    cfg.deffind:= 2;
    IF loadres = 1 THEN (* get string to search for *)
      cfg.deffind:= 1;
(*213*)
      getnew:= TRUE;
      srchlen:= GetFindStrg(getnew);
      IF (srchlen = 0) OR (srchlen = 0FFH) THEN
        RETURN FALSE;
      END;  (* zero length or cancelled *)
      InitObjStrg(BLCKTREE, BLOKTXT3, 'Search from which disk sector?');
    END; (* if get find strg *)
  (*...*************)
  ELSE (* readwrite = Write THEN *) (* get number of sectors in buffer *)
(*demo*
    PleaseBuy;
(**
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[3][Saving is Disabled|in this Demo|See Help for order info][OK]');
    CODE(0A00AH); (* lineA Hide mouse *)
**)
    RETURN FALSE;
*demo*)
    numbytes:= endblk - startblk; (* 2.37 *)
    numsectors:= SHORT(numbytes DIV LONG(bpbptr^.recsiz));
    Showmouse; (* lineA Show mouse *)
    IF numbytes MOD LONG(bpbptr^.recsiz) <> 0 THEN (* not integral # of sectors *)
      dummy:= FormAlert(1,'[1][Warning: Not Integral|# of Sectors.|Will Truncate][ OK ]');
    END;
(*
    IF last MOD LONG(bpbptr^.recsiz) <> 0 THEN (* not integral # of sectors *)
      dummy:= FormAlert(1,'[1][Warning: Not Integral|# of Sectors.|Will Truncate][ OK ]');
    END;
*)
    IF numsectors > kperblock + kperblock THEN (* more sectors than read in *)
      dummy:= FormAlert(1,'[1][Warning: Increased|# of Sectors.|May Ruin a File][ OK ]');
    END;
    CODE(0A00AH); (* lineA Hide mouse *)
    InitObjStrg(BLCKTREE, BLOKTXT1, 'Write Sectors to Disk');
(*demo*)
  END; (* if Read or Write *)
  Cardtostrg(LONG(numsectors), cardstrg, FALSE, 5); (* show in dec *)
  InitObjStrg(BLCKTREE, BLOKTX2A, cardstrg);

  maxblock:= bpbptr^.rdlen + bpbptr^.fsiz + bpbptr^.fsiz
    + SHORT(LONG(bpbptr^.numcl) * LONG(bpbptr^.clsizb) DIV LONG(bpbptr^.recsiz))
    - numsectors + 1; (* +1 for boot sector *)
    (* max must be limited to max on disk minus numsectors so it doesn't
     try to read/write beyond end of disk, as in ramdisk at least *)
  IF NOT GetBlockNum(tmplong, tmplong, startsect) THEN
    (* gets blocknum, which is starting sector # *)
    RETURN FALSE;
  END;

  (* 2.30 1/25/92 *)
  IF readwrite = 1 THEN (* 1 = Write to disk sectors *)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[2][Caution:  Really Want|to Write Disk Sectors?][OK|Cancel]');
    CODE(0A00AH); (* lineA Hide mouse *)
    IF dummy = 2 THEN
      RETURN FALSE;
    END;
  ELSE
    ClearAll(TRUE); (* newfile 3.12 *)
  END; (* query disk write *)
  blocknum:= startsect;
  Showmouse; (* lineA Show mouse *)
  LOOP (* load blocks & search for strg *)
(**
    IF RWAbs(readwrite, startadr, numsectors, blocknum, drivenum) <> 0 THEN
**)
    PUSH(drivenum);
    PUSH(blocknum);
    PUSH(numsectors);
    PUSH(startadr); (* long *)
    PUSH(readwrite); (* 0 = read, 1 = write *)
    PUSH(4);
    CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
    CODE(04FEFH,0000EH); (* lea.l  14(sp),sp  ; fix stack *)
    j:= CARDINAL(REGISTER(D0)); (* 0 = no error *)
    IF j <> 0 THEN
      dummy:= FormAlert(1,'[1][Disk Access Error|May Still Be OK][ OK ]');
    END; (* if error *)

    IF loadres <> 1 THEN (* not search load *)
      EXIT;
    END;

    found:= FALSE; (* to init for search routine *)
    indexadr:= startadr; (* start searching from start of buffer *)
    GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)
    IF Find(blocksize+LONG(srchlen)- 512, ADR(findstrg),
      srchlen, cfg.casesens, indexadr) THEN (* found it! *)
(*
      blocknum:= SHORT(startftmp DIV 0400H); (* 1K *)
*)
      GrafMouse(GEMAESbase.Arrow, NIL); (* end busy bee *)
      startsect (* oldblock *):= blocknum;
      found:= TRUE;
      endblk:= LONGCARD(indexadr - startadr); (* return for setting i *)
      EXIT; (* from search loop *)
    ELSIF blocknum >= maxblock - numsectors THEN (* endftmp >= endf *)
      (* not found on whole disk *)
      GrafMouse(GEMAESbase.Arrow, NIL); (* end busy bee *)
      CODE(0A00AH);  (* LineA hide mouse *)
      FoundAlert; (* false = don't ask about extended search *)
      Showmouse; (* lineA Show mouse *)
      ClearAll(TRUE); (* true = newfile *)
      (* presumably exits loop ok, but relies on mreset for mouse fix *)
      EXIT;
    END; (* if found *)
    (* not found in that block so move on to next block *)
    INC(blocknum, numsectors-2); (* -2 for 2 sector overlap *)
    IF blocknum > maxblock THEN (* truncate last block *)
      blocknum:= maxblock;
    END;
  END; (* Loop to search/load disk sectors *)
  CODE(0A00AH); (* lineA Hide mouse *)
  IF found THEN
    RETURN TRUE;
  END;
  RETURN FALSE;
END DiskOpen;
(*dr*)

PROCEDURE AppendAlert;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,"[1][Can't Append Disk Sectors][ OK ]");
  CODE(0A00AH); (* lineA Hide mouse *)
END AppendAlert;

PROCEDURE Savefile(askbig: BOOLEAN; overpend: INTEGER): BOOLEAN;
VAR (* start, end: LONGCARD; *)
    fsel0ret: Fsel0type;
    fseltmp, fseltmp2: Fseltype;
    (* bigpart = TRUE when buffer holds only a piece of whole disk file *)
    (* askbig allows skipping optional stuff to allow PageBigFile *)
(*
  overpend:
  0 = no force overwrite or append
  1 = force overwrite
  2 = force append
*)
BEGIN
(*demo*
  PleaseBuy;
(*
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][Saving is Disabled|in this Demo|See Help for order info][OK]');
  CODE(0A00AH); (* lineA Hide mouse *)
*)
  RETURN FALSE;
*demo*)
  fseltmp2:= fsel; (* ?? do we need this for anything ?? *)
  fseltmp:= fsel; (* for when askbig = false *)
  IF askbig THEN
    IF blocktype > 0 (* isblock *) THEN
(**
      mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
      Showmouse; (* lineA Show mouse *)
      result:= FormAlert(1,'[2][Save Marked Block Only ?][Yes|No|Cancel]');
      CODE(0A00AH); (* lineA Hide mouse *)
      IF result = 1 THEN
        IF Saveblock(blockstart, blockend, overpend) THEN
          RETURN TRUE;
        END;
        RETURN FALSE;
      ELSIF result = 3 THEN
        RETURN FALSE;
      END;
    END; (* if isblock *)
    IF bigpart THEN (* see if want to do automatic save of this part into rest of file *)
(**
      mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
      Showmouse; (* lineA Show mouse *)
      result:= FormAlert(1,
        '[2][File larger than buffer; Save:| (1) Entire disk file, w/BAK| (2) Edit buffer only][1|2|Cancel]');
      CODE(0A00AH); (* lineA Hide mouse *)
      IF result = 2 THEN
        IF Saveblock(0, last, overpend) THEN
          RETURN TRUE;
        END;
        RETURN FALSE;
      ELSIF result = 3 THEN
        RETURN FALSE;
      END;
      (* bigpart:= TRUE; *)
    END; (* if bigpart *)
    IF overpend = 2 THEN
      Selecthead('APPEND To File...', TRUE); (* true = show it *)
    ELSE
      Selecthead('SAVE To FILE/Disk...', TRUE); (* true = show it *)
    END; (* if append *)
    (*  update:= FALSE; (* so no windowupdate when not needed *) *)
    IF NOT Fselect(cfg.oldpath, fseltmp,fsel0ret, TRUE, FALSE) THEN
      InitMenu; (* 2.32 4/2/92 *)
      RETURN FALSE;
    END; (* if cancel or fselect error *)
  END; (* if askbig *)
(*dr*)
  IF cfg.fsel0[0] = 0C (* hackable checked in Fselect *) THEN (* no filename so write to disk sectors *)
    (* no filename so write to disk sectors *)
    IF overpend = 2 THEN
      AppendAlert;
    ELSE
      IF NOT DiskOpen(1, 0, last) THEN  (* 1 = Write *)
        RETURN FALSE;
      END;
    END; (* if try appending w/o filename *)
  ELSE (* write to file *)
(*dr*)
(**2.12** (* move? to editproc writefile routine *)
    IF bigpart & (Compare(fseltmp, fsel)) THEN (* need to rename original as .BAK *)
      (* should check if saved & if last = endf - startf *)
      MakeBak(fsel, 'BAK');
    END; (* if make BAKup *)
**2.12**)
    IF NOT Writefile(fseltmp, 0, last, bigpart, overpend) THEN
      (* 2.30: FALSE = don't force append *)
(*
      WriteErr;
*)
      fsel:= fseltmp2; (* restore to what it was at start of procedure *)
      RETURN FALSE; (* Disk full? *)
    END;
    fsel:= fseltmp; (*@ 2.30 12/31 @*)
    IF bigpart (* & (Compare(fseltmp, fseltmp2)) *) THEN (* change source to new name *)
(*@
      fsel:= fseltmp; (* set current filespec to what it was saved as *)
@*)
      endf:= startf + last; (* fseltmp is newly chosen name *)
      IF last > lasti THEN
        INC(fileend, last - lasti);
      ELSE
        DEC(fileend, lasti - last);
      END;
      lasti:= last; (* 2.30 12/12/91 *)
      (* need to also fix startf somehow? *)
    END;
(*dr*)
  END; (* if write disk sectors or file *)
(*dr*)
  saved:= TRUE;
  MoveMem(ADR(cfg.fsel0), ADR(Title1), LONG(Length(cfg.fsel0)+1));
  InitMenu; (* 2.30 1/29/92, redraw used to do *)
  RETURN TRUE;
(*demo*)
END Savefile;

PROCEDURE Saveblock(startblk, endblk: LONGCARD; overpend: INTEGER): BOOLEAN;
(* overpend:
  0 = no force overwrite or append
  1 = force overwrite
  2 = force append
*)
VAR fseltmp: Fseltype;
    fsel0tmp,fsel0ret: Fsel0type;
    ok: BOOLEAN;
BEGIN
(*demo*
  PleaseBuy;
(*
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][Saving is Disabled|in this Demo|See Help for order info][OK]');
  CODE(0A00AH); (* lineA Hide mouse *)
*)
*demo*)
(**
  ok:= Clipbrd(); (* set 'path' to clipboard if exists or user desires *)
**)
   (* else sets to default file path *)
  IF overpend = 2 THEN
    Selecthead('APPEND Block...', TRUE);
  ELSE
    Selecthead('SAVE BLOCK...', TRUE);
  END; (* if append *)
  (*  update:= FALSE; (* so no windowupdate when not needed *) *)
  fsel0tmp:= cfg.fsel0;
  cfg.fsel0:= 'BLOCK.TXT'; (* Used to be block.txt then scrap.txt *)
  ok:= TRUE; (* use ok instead of returning FALSE's to allow
                restoring filename just once at end *)

(*
  IF Fselect(path, fseltmp, FALSE, TRUE) THEN
*)
  IF Fselect(path, fseltmp,fsel0ret, FALSE, FALSE) THEN  (* 2.30 1/26/92 *)
(*dr*)
    IF fsel0ret[0] = 0C THEN
(*
    IF cfg.fsel0[0] = 0C (* hackable was checked in Fselect *) THEN
*)
      (* no filename so write to disk sectors *)
      IF overpend = 2 THEN
        AppendAlert;
      ELSE
        IF NOT DiskOpen(1, startblk, endblk) THEN  (* 1 = Write *)
          ok:= FALSE;
        END;
      END; (* if tried to append w/o filename *)
    ELSE (* write to file *)
(*dr*)
      IF NOT Writefile(fseltmp, startblk, endblk, FALSE, overpend) THEN
        (* false1 = not bigpart; 0 = no force overwrite or append *)
        ok:= FALSE;
      END; (* if not writefile *)
(*dr*)
    END; (* if write to disk or file *)
(*dr*)
  ELSE (* cancel or fselect error *)
    ok:= FALSE;
  END; (* if cancel or fselect error *)
  cfg.fsel0:= fsel0tmp; (* restore filename to original *)
  InitMenu; (* 2.30 1/29/92 *)
  IF ok THEN
    RETURN TRUE;
  END;
(*demo*)
  RETURN FALSE; (* Disk full? *)
END Saveblock;

(*demo+*
PROCEDURE PleaseBuy;
BEGIN
(**
  mhideptr^:= 1;
**)
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][Saving is Disabled|in this Demo|See Help for order info][OK]');
  CODE(0A00AH); (* lineA Hide mouse *)
END PleaseBuy;
*demo+*)

PROCEDURE ShowNew;
BEGIN
  Display(0, cfg.maxdispline);
  SetFoundPos(TRUE, TRUE); (* includes findline *)
  SetSlideSize;
  SetSlidePos;
  InitMenu; (* to clear shifting notice *)
END ShowNew;

PROCEDURE SaveCheck(askbig, asksave: BOOLEAN): BOOLEAN;
BEGIN
  (* add bigpart check 2.32 3/2/92 *)
  IF ((last > 0) OR bigpart) & (NOT saved) THEN (* ask/save revised stuff *)
    result:= 1; (* default to save changes *)
    IF asksave THEN
(**
      mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
      Showmouse; (* lineA Show mouse *)
      result:= FormAlert(1,"[3][Save Changes First ?][Yes|No|Cancel]");
      CODE(0A00AH); (* lineA Hide mouse *)
    END; (* if asksave *)
    IF result = 3 THEN (* cancel *)
      RETURN FALSE;
    ELSIF result = 1 THEN (* Save it *)
      (* MakeBak(fsel); gets done now in Savefile *)
      IF NOT Savefile(askbig, 0) THEN
       (* askbig = ask any questions?; 0 = don't force overwrite or append *)
        RETURN FALSE;
      END; (* if write error *)
    END; (* if *)
  END; (* if not saved *)
  RETURN TRUE; (* user answered 'No' save or was successful save *)
END SaveCheck;

PROCEDURE ShiftCheck(): BOOLEAN;
VAR
    startftmp, endftmp: LONGCARD;
    fseltmp: Fseltype;
    fsel0tmp: Fsel0type;
    handle: INTEGER;
    fromadr: ADDRESS;
BEGIN
      Showmouse; (* lineA Show mouse *)
      result:= FormAlert(1,'[2][Shifting will Empty|Pastebuffer!|Save to Clipboard?][OK|No|Cancel]');
      CODE(0A00AH); (* lineA Hide mouse *)
      IF result = 3 THEN (* cancel *)
        RETURN FALSE;
      ELSIF result = 1 THEN (* save pastebuffer to clipboard *)
        fromadr:= newlnptradr; (* pastebuffer *)
        endftmp:= pastelen; (* count *)
        IF Clipbrd() THEN (* set 'path' to clipboard if exists or user desires *)
          fsel0tmp:= 'SCRAP.TXT';
          Concat(path, fsel0tmp, fseltmp); (* gives e.g., A:\path\*.* *)
          Create(fseltmp, 0, handle); (* 0 = read/write *)
          startftmp:= endftmp;
          Write(handle, endftmp, fromadr); (* write to scrap file *)
          IF (NOT Close(handle)) OR (endftmp <> startftmp) THEN
            WriteErr;
            RETURN FALSE;
          END;
        END; (* if clipbrd *)
      END; (* if cancel or to clipbrd *)
      RETURN TRUE;
END ShiftCheck;

PROCEDURE PageBigFile(forward, ask: BOOLEAN): BOOLEAN;
(* gets next/prev buffer size hunk of a bigfile, saving current if needed *)
VAR startftmp, endftmp, overlap: LONGCARD;
    j, fileline: CARDINAL;
(*
    fseltmp: Fseltype;
    fsel0tmp: Fsel0type;
    fromadr: ADDRESS;
*)
    handle: INTEGER;
BEGIN
  IF bigpart & 
  ((forward & (endf < fileend)) OR (NOT forward & (startf > 0))) THEN
  (* is reason to page *)
    (* 2.25 *)
    IF (ask & (pastelen > 0)) THEN
      IF NOT ShiftCheck() THEN
        RETURN FALSE;
      END;
    END; (* if ask about pagebigfile *)

    notistrg:= 'Shifting..';
    Notice;
    IF NOT SaveCheck(FALSE, ask) THEN (* no askbig, maybe asksave *)
      notistrg:= 0C;
      InitMenu; (* to clear shifting notice *)
      RETURN FALSE;
    END;

    MiniInit; (* sets i:= 0 & notistrg among other things *)
    overlap:= 1024;
    IF forward THEN (* move on to next part *)
      fileline:= buffline + lastline;
(*
      ptr1:= startadr + ADDRESS(last - 1);
      IF (ptr1^ = 15C) & (cfg.eollen <> 0) THEN (* at CR w/o LF *)
        DEC(fileline);
      END;
*)
      startftmp:= 0;
      IF endf > overlap THEN  (* 2.30 *)
        startftmp:= endf - overlap;
      END; (* if endf > overlap *) 
      endftmp:= startftmp + blocksize;
      (* 2.25 *)
      IF endftmp > fileend THEN (* set endftmp to actual end of file *)
        endftmp:= fileend;
        startftmp:= 0; (* 2.30... *)
        IF endftmp > blocksize THEN
          startftmp:= endftmp - blocksize; (* 2.25 *)
        END;
      END; (* if truncate last block *)
      (** Readfile would take care of shortening endf as needed **)
(**)
    ELSE (* move back to prior part of bigfile *)
      fileline:= buffline;
      ptr1:= startadr;
      IF (ptr1^ = 12C) & (cfg.eollen <> 0) THEN (* at LF w/o CR *)
        DEC(fileline);
      END;
      endftmp:= startf + overlap;
      IF endftmp > fileend THEN (* 2.30 *)
        endftmp:= fileend;
      END;
      IF endftmp > blocksize THEN
        startftmp:= endftmp - blocksize;
      ELSE (* at beginning of file *)
        startftmp:= 0; (* do not let this go negative! *)
        endftmp:= blocksize; (* 2.25 *)
        IF endftmp > fileend THEN (* 2.30 *)
          endftmp:= fileend; (* and bigpart is really false now *)
          (* bigpart:= FALSE; *)
        END;
      END;  
    END; (* if move forward or backward *)
(*
    fseltmp:= fsel;
*)
    j:= Readfile(fsel, startftmp, endftmp);
    IF j = 3 THEN
      FileAlert;
      (* RETURN FALSE; *)
    END; (* if failed read *)

    (* 2.25 *)
    IF forward THEN
      i:= endf - startftmp; (* which is overlap if did a full block shift *)
      IF NOT ask THEN (* auto forward paging for searching 2.25 *)
        i:= i - LONG(srchlen); (* in case string was split at overlap point *)
      END;
    ELSE (* backward *)
      i:= startf - startftmp;
    END; (* if forward *)

    startfold:= startf; (* 3.2B *)
    startf:= startftmp;
    endf:= endftmp;
    last:= endf - startf;

    lasti:= last;
    Lineptrs(0);
(*
    notistrg:= '';
*)
    pastelen:= 0; (* should have been done by Readfile *)
    buffline:= fileline - Findline(i);
(****
     (* moved to shownew *)
      Display(0, cfg.maxdispline);
      SetFoundPos(TRUE, TRUE); (* includes findline *)
  (*** 3.1C ***
      buffline:= fileline - (line + curdispline);
      IF (startf = 0) OR ((line + curdispline) > fileline) THEN
        buffline:= 0;
      END;
  *** ***)
      SetSlideSize;
      SetSlidePos;
      InitMenu; (* to clear shifting notice *)
****)
    saved:= TRUE;
    RETURN TRUE;
  END; (* if bigpart *)
  RETURN TRUE; (* FALSE; so loops calling this can end 3.1C *)
  (* bigpart still = TRUE if was true *)
END PageBigFile;

PROCEDURE LoadFile(VAR fseltmp: Fseltype; shownow: BOOLEAN): BOOLEAN;
(* shownow allows immediate displaying via setfoundpos *)
VAR startftmp, endftmp, overlap: LONGCARD;
    bigparttmp, found, getnew: BOOLEAN;
    indexadr: ADDRESS;
    klong: LONGCARD; (* 32 bit.  was CARD *)
    (* fsel0tmp: Fsel0type; *)
    loadres: INTEGER;
BEGIN
  overlap:= 1024;
  found:= FALSE; (* also used to tell if a search has been done *)
  blocknum:= 0;
  startftmp:= 0;
  endftmp:= buffsize; (* + 5 *) (* to force error if file is bigger than buffer *)
    (* and to leave a FEW whole spaces for editing additions! *)
  bigparttmp:= FALSE;
  (* fsel0tmp:= cfg.fsel0; *)
(*dr*)
  IF (cfg.fsel0[0] = 0C) (** & cfg.hackable **) THEN (* open disk *)
    klong:= 0;
    IF NOT DiskOpen(0, tmplong, klong) THEN
    (* 0 = Read; tmplong=dummy, klong will be i if from find/open *)
      RETURN FALSE;
    END;
    found:= TRUE;
    SetHack;
    last:= blocksize;
    Title1:= 'D:sec:     ';
    Title1[0]:= fseltmp[0]; (* drive letter *)
    Cardtostrg(LONG(startsect), cardstrg, FALSE, 5); (* decimal *)
     (** NOTE: large drives could need 6 digit sector #'s ( > 50 meg ) **)
     (** using clusters would help & make more sense **)
    MoveMem(ADR(cardstrg), ADR(Title1)+ADDRESS(6), 5); (* sector # *)
  ELSE (* open file *)
(*dr*)
    REPEAT
      j:= Readfile(fseltmp, startftmp, endftmp);
      (* moved for 2.33 from j=2  4/8/92 *)
      IF j = 0 THEN  (* Read error *)(* 3.2D put before fileend = *)
        FileAlert;
        (* cfg.fsel0:= fsel0tmp; *)
        RETURN FALSE;
      END;
      IF NOT bigparttmp THEN (* save fileend of normal size file *)
        fileend:= endftmp; (* save actual end of disk file *)
      END;
      IF j = 2 THEN  (* file too big, ask for portion to read *)
        result:= 2;
(***)
        IF daccTitle[0] = 0C THEN (* prg, see if want to grab ram *)
          Showmouse; (* lineA Show mouse *)
          result:= FormAlert(2,"[2][Resize Buffer to|Fit Whole File?|(may slow down editing)][Yes|No|Cancel]");
          CODE(0A00AH); (* lineA Hide mouse *)
          IF result = 3 THEN
            RETURN FALSE;
          END; (* if cancel *)
          IF result = 1 THEN (* make big buffer *)
            cfg.maxbuff:= endftmp + 2048;
            InitBuffSize;
            IF buffsize < endftmp THEN
              result:= 2; (* not enough free ram for whole file *)
              Showmouse; (* lineA Show mouse *)
              dummy:= FormAlert(1,'[3][Not enough free RAM|for whole file][ OK ]');
              CODE(0A00AH); (* lineA Hide mouse *)
            END; (* if not enough ram for whole file *)
          END; (* if make buffer bigger *)
        END; (* if prg check buff increase *)
(***)
        IF result = 2 THEN (* work with current buffer size *)
          fileend:= endftmp; (* save actual end of disk file *)
          maxblock:= SHORT(endftmp DIV 0400H); (* 400H=1K *)
          IF (maxblock > 0) & (blocksize > 0800H) THEN (* assure at least 1K of text in buffer *)
            DEC(maxblock);
          END;

(************
          (* ask if pick block to read or search *)
          Showmouse; (* lineA Show mouse *)
  (*213*)
          loadres:= FormAlert(cfg.deffind,"[2][File larger than buffer:|Find string in file|or Pick block][ Find |Pick|Cancel]");
          CODE(0A00AH); (* lineA Hide mouse *)
          IF loadres = 3 THEN
            (* cfg.fsel0:= fsel0tmp; *)
            RETURN FALSE;
          END; (* if cancel *)
          cfg.deffind:= 2;
          IF loadres = 1 THEN (* get string to search for *)
            (* below allow user to set start block for search *)
            cfg.deffind:= 1;
  (*213*)
            getnew:= TRUE;
            srchlen:= GetFindStrg(getnew);
            IF (srchlen = 0) OR (srchlen = 0FFH) THEN
              (* cfg.fsel0:= fsel0tmp; *)
              RETURN FALSE;
            END;  (* zero length or cancelled *)
            endf:= endftmp; (* stores file end just for search routine *)
            (*
            startftmp:= 0;
            endftmp:= LONG(blocksize);
            *)
          END; (* if get find strg *)
  
          (***** getblocknum routine ******)
          InitObjStrg(BLCKTREE, BLOKTXT1, 'File is larger than text buffer');
          BlockInit23; (* sets other lines of block dialog *)
          IF loadres = 1 THEN (* find string in file *)
            InitObjStrg(BLCKTREE, BLOKTXT2, 'Find Block of Size (K): ');
          END;
          IF NOT(GetBlockNum(startftmp, endftmp, startfileblk)) THEN (* cancelled *)
            (* this ruins endftmp, which is why it's saved in fileend & endf *)
            RETURN FALSE
          END;
          (********)
          IF loadres = 1 THEN (* find string in file *)
            LOOP (* load blocks & search for strg *)
              j:= Readfile(fseltmp, startftmp, endftmp);
              indexadr:= startadr; (* start searching from start of buffer *)
              IF Find(blocksize, ADR(findstrg),
                srchlen, cfg.casesens, indexadr) THEN (* found it! *)
                (* this assumed that 2nd half of overlap would be searched in
                   next block, but won't happen at end of file *)
                (* load block of memory containing findstrg into buffer *)
                blocknum:= SHORT(startftmp DIV 0400H); (* 1K *)
                startfileblk (* oldblock *):= blocknum;
                found:= TRUE;
                EXIT; (* from search loop *)
              ELSIF endftmp >= endf THEN (* not found in whole file *)
                EXIT;
                (*
                FoundAlert;
                RETURN FALSE;
                *)
              END; (* if found *)
  
              (* not found in that block so move on to next block *)
              startftmp:= endftmp - overlap;
              (* 32 bit *)
              endftmp:= startftmp + blocksize;
              IF endftmp > endf THEN (* set endftmp to actual end of file *)
                endftmp:= endf;
                startftmp:= endftmp - blocksize; (* 2.25 *)
              END; (* if truncate last block *)
  
              (* 2.33 4/8/92 *)
              IF WantAbort(FALSE) THEN   (* esc or undo *)
                EXIT;
              END;
            END; (* loop to search/load file *)
            IF NOT found THEN
              FoundAlert; (* don't ask about extended search *)
  (*%%
              ClearAll(TRUE);
  %%*)
              (* for extended find from buffer, need to reload 'current' part *)
  (**%%
              RETURN FALSE;
  %%**)
            END; (* if not found *)
  
            klong:= LONGCARD(indexadr - startadr);
            j:= 1; (* to let repeat loop end *)
          END; (* if find to load bigfile *)
****************)
(***)
          startftmp:= 0;
          endftmp:= blocksize;
(***)
          bigparttmp:= TRUE;
        END; (* if use current buffer size *)

      END; (* if j = 0 or 2 *)
    UNTIL (j = 1) OR (j = 3); (* read went ok, or bytes read <> requested *)
    IF (j = 3) THEN
      FileAlert;
      (* RETURN FALSE; not wanted, since probably still read in something *)
    END;
    last:= endftmp - startftmp; (* file or portion length *)
    MoveMem(ADR(cfg.fsel0), ADR(Title1), LONG(Length(cfg.fsel0)+1));
(*dr*)
  END; (* if open disk or file *)
(*dr*)
  lasti:= last; (* initial size of file part in buffer *)
  startf:= startftmp;
  endf:= endftmp;
  bigpart:= bigparttmp;
  lastcol:= 80;
  (* cfg.eollen:= 2; *)
  Lineptrs(0);
  MiniInit; (* sets i:= 0 among other things *)
(*** 3.1C ***)
  buffline:= 0;
(***)
  (* why didn't just do clearall at start of routine? *)
  (* add 2.30 1/26/92, since no window3 close to force redraw *)
  IF shownow & (fileend > endf) THEN
    notistrg:= 'VirtualBUF';
    Notice;
  END; (* if file > buffer *)

  (*** put back in for 3.13 since is needed for search/load sectors ***)
  IF found THEN (* was a search/open operation *)
    i:= klong; (* 'endblk' for passing new i *)
  END;
(*
  IF shownow THEN
    Display(0, cfg.maxdispline);
    SetFoundPos(FALSE); (* no need to forcetop *)
    update:= FALSE; (* so any redraw msg doesn't do redraw *)
    InitMenu;
  END;
*)
(***
  IF found THEN (* was a search/open operation *)
    i:= klong; (* 'endblk' for passing new i *)
    IF shownow THEN
      SetFoundPos(FALSE); (* no need to forcetop *)
    END; (* if shownow *)
  END; (* if search/opened *)
***)
  RETURN TRUE;
END LoadFile;

(****)
PROCEDURE PageDisk(forward: BOOLEAN): BOOLEAN;
VAR drivenum, numsectors: CARDINAL;
BEGIN
(********************)
  drivenum:= ORD(cfg.oldpath[0]) - 65; (* drive number, A = 0 ... *)
  bpbptr:= ADDRESS(BconinGetBPB(drivenum, 7)); (* 7=GetBPB opcode *)
  IF ADDRESS(bpbptr) = 0 THEN (* drive not available? *)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[1][Sorry, Drive not available?][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN FALSE;
  END; (* if error *)
  numsectors:= SHORT(LONG(kperblock) * 0400H DIV LONG(bpbptr^.recsiz));
(********************)
  IF forward THEN
    blocknum:= startsect + numsectors - 2; (* 2 sector overlap *)
    IF blocknum > maxblock THEN
      blocknum:= maxblock;
    END;
  ELSE (* backward *)
    IF startsect > numsectors - 2 THEN
      blocknum:= startsect - (numsectors - 2); (* 2 sector overlap *)
    ELSE
      blocknum:= 0;
    END;
  END;
(********************)
(**
  IF RWAbs(readwrite, startadr, numsectors, blocknum, drivenum) <> 0 THEN
**)
  PUSH(drivenum);
  PUSH(blocknum);
  PUSH(numsectors);
  PUSH(startadr); (* long *)
  PUSH(00H); (* 0 = read, 1 = write *)
  PUSH(4);
  CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
  CODE(04FEFH,0000EH); (* lea.l  14(sp),sp  ; fix stack *)
  j:= CARDINAL(REGISTER(D0)); (* 0 = no error *)
  IF j <> 0 THEN
    dummy:= FormAlert(1,'[1][Disk Access Error|May Still Be OK][ OK ]');
  END; (* if error *)
(********************)
  Cardtostrg(LONG(startsect), cardstrg, FALSE, 5); (* decimal *)
  MoveMem(ADR(cardstrg), ADR(Title1)+ADDRESS(6), 5); (* sector # *)
  MiniInit; (* sets i:= 0 among other things *)
  IF forward THEN
    i:= LONG(startsect + numsectors - blocknum) * LONG(bpbptr^.recsiz);
  ELSE (* backward *)
    i:= LONG(startsect - blocknum) * LONG(bpbptr^.recsiz);
  END; (* if forward *)
  startsect:= blocknum;
  Cardtostrg(LONG(startsect), cardstrg, FALSE, 5); (* decimal *)
  MoveMem(ADR(cardstrg), ADR(Title1)+ADDRESS(6), 5); (* sector # *)
  last:= LONG(numsectors) * LONG(bpbptr^.recsiz);
  lasti:= last;
(*
  startf:= 0;
  endf:= buffsize;
*)
  Lineptrs(0);
  (* notistrg:= ''; *)
(*
  pastelen:= 0; (* not needed for sector shift *)
*)
  ShowNew; (* 3.2C replaces next 5 lines *)
(**
  Display(0, cfg.maxdispline);
  SetFoundPos(TRUE, TRUE);
  SetSlideSize;
  SetSlidePos;
  InitMenu; (* to clear shifting notice *)
**)
  saved:= TRUE;
  RETURN TRUE;
END PageDisk;
(****)

(* 2.30 *)
PROCEDURE Setclipbrd(VAR temppath: Pathtype): BOOLEAN;
VAR fseltmp: Fseltype; (* not used for anything *)
    fsel0tmp,fsel0ret: Fsel0type;
    okfsel: BOOLEAN;
BEGIN
  Selecthead('Set Clipboard Path', TRUE);
  fsel0tmp:= cfg.fsel0;
  cfg.fsel0:= 0C;
  okfsel:= FALSE;
  IF Fselect(temppath, fseltmp,fsel0ret, FALSE, FALSE) THEN
   (* false1 = not newfile, false2 = not carename *)
(*****
    (* append 'CLIPBRD' to path *)
    j:= Length(temppath);
    Concat(temppath, clippath, path); (* gives e.g., A:\path\CLIPBRD *)
    path[j+7]:= 0C; (* terminate *)
    ok:= DirCreate(path);
 (*
    Concat(temppath, bslash, path); (* ...\CLIPBRD\ *)
 *)
    path[j+7]:= '\';
    path[j+8]:= 0C;
*****)
    ScrapWrite(ADR(temppath)); (* sets AES scrap path *)
    okfsel:= TRUE;
  END; (* if complete fselect *)
  cfg.fsel0:= fsel0tmp;
  InitMenu;
  RETURN okfsel;
END Setclipbrd;

(**2.30*)
PROCEDURE Clipbrd(): BOOLEAN;
(* sets global 'path' to clipboard path *)
VAR fseltmp: Fseltype;
    temppath: Pathtype;
BEGIN
(* get & set if needed current scrap path *)
  ptr1:= ADR(path);
  ScrapRead(ADR(path)); (* use path as temp holder *)
(*
  StringZap(path);
*)
  j:= Length(path);
  IF j <> 0 THEN (* check existing path *)
    IF path[j] <> '\' THEN

(**##*)
    (* try leaving out for testing, 2.32 3/12/92 *)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    (*
      GetDTA(tmpadr); (* temporary use *)
    *)
      PUSH(02FH); (* GetDTA opcode *)
      CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
      CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
      olddta:= ADDRESS(REGISTER(D0)); (* use wrapadr as temp address *)
    
      (* try using my own DTA 2.30 1/30/92 *)
      (* SetDTA(ADR(DTA))); *)
      SETREG(A0, ADR(DTA));
      CODE(02F08H); (* move.l  a0,-(sp) *)
      CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
      CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
      CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
      (* restore all necessary registers *)
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(*##**)
      SFirst(path, 010H, result); (* 16 = bit 4 = folder only *)

(**##*) (* 2.32 3/29/92 *)
      (* SetDTA(olddta); *)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
      SETREG(A0, olddta);
      CODE(02F08H); (* move.l  a0,-(sp) *)
      CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
      CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
      CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
      (* restore all necessary registers *)
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(**##*)    
      IF result = 0 THEN (* found possibly folder *)
      (* due to gemdos bug, must now really see if it's a folder *)
(********
(*
        GetDTA(wrapadr); (* temporary use *)
*)
        (* save registers *)
        CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
        PUSH(02FH); (* GetDTA opcode *)
        CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
        CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
   (* restore all necessary registers *)
   (* movem.l A1-A2/D1-D2,(SP)+ *)
        CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
        ptr1:= ADDRESS(REGISTER(D0)); (* use wrapadr as temp address *)
        ptr1:= ADDRESS(ptr1) + ADDRESS(21); (* pointer to dta *)
******)
        ptr1:= ADR(DTA) + ADDRESS(21); (* now that use own dta *)
        (* 010H = bit 4 set *)
        IF BITSET(010H) * BITSET(ORD(ptr1^)) <> {} THEN (* AND *)
          path[j]:= '\'; (* append backslash *)
          path[j+1]:= 0C;
          RETURN TRUE; (* now fully valid clipboard path *)
        ELSE (* found file, so strip to \ but don't reset clipbrd *)
          (* stalker/steno test, leave scrap path as it is with SCRAP.TXT *)
          WHILE (path[j] <> '\') & (j > 1) DO
            path[j]:= 0C;
            DEC(j);
          END; (* while strip chars *)
          RETURN TRUE; (* w/o doing new scrapwrite with \ on end *)
        END; (* if found real folder *)
      ELSE (* strip to \ *)
        (* stalker/steno test, leave scrap path as it is with SCRAP.TXT *)
        WHILE (path[j] <> '\') & (j > 1) DO
          path[j]:= 0C;
          DEC(j);
        END; (* while strip chars *)
        RETURN TRUE; (* w/o doing new scrapwrite with \ on end *)
      END; (* if need \ on end of valid path *)
    ELSE
      RETURN TRUE; (* was a \ terminated path already *)
    END; (* in case was left by someone else's mistake *)
  END; (* if some path already exists *)
(* only continues if either no path or invalid path *)
(**
  IF j <= 1 THEN (* invalid/no path, should always be true *)
**)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(2,'[1][Clipboard not found|Set path?][Not now|OK]');
    CODE(0A00AH); (* lineA Hide mouse *)
    IF result = 2 THEN (* try to set it *)
      temppath:= cfg.oldpath;
      IF Setclipbrd(temppath) THEN
        path:= temppath;
        RETURN TRUE;
      END; (* if complete fselect *)
    END; (* wanted to set it now *)
    path:= cfg.oldpath;
    RETURN FALSE;
(**
  END; (* if needed to select new path *)
  RETURN TRUE; (* ? no path at all *)
**)
END Clipbrd;
(*2.30**)

(*ds*)
PROCEDURE DoMerge(topastebuff, fromclip: BOOLEAN): BOOLEAN;
VAR fseltmp: Fseltype;
    fsel0tmp,fsel0ret: Fsel0type;
    ok: BOOLEAN;
BEGIN
(**)(*
  PleaseReg;
(**)*)
(**)
(* first do scrapread to find/set clipboard path *)
  fsel0tmp:= cfg.fsel0;
  cfg.fsel0:= 'SCRAP.TXT';
  ok:= FALSE;
  IF fromclip THEN  
    ok:= Clipbrd();
    Concat(path, cfg.fsel0, fseltmp); (* gives e.g., A:\path\*.* *)
    ok:= TRUE;
  ELSE
(*
    path:= cfg.oldpath; (* let it be whatever it was *)
*)
    cfg.fsel0:= 'BLOCK.TXT'; (* 3.02 *)
    Selecthead('MERGE File...', TRUE);
    ok:= Fselect(path, fseltmp, fsel0ret, FALSE, TRUE);
  END;
  cfg.fsel0:= fsel0tmp; (* return it to orig name *)
  IF ok THEN
    ok:= FALSE;
    IF Mergefile(fseltmp, topastebuff) THEN
      IF topastebuff THEN
        RETURN TRUE;
      END;
      saved:= FALSE;
      Lineptrs(line);
      update:= TRUE; (* 6/4/93 *)
      IF VDIHandle >= 0 THEN
        FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
        SetFoundPos(FALSE, TRUE); (* no need to forcetop *)
        SetSlideSize;
        SetSlidePos;
      END; (* if window is open *)
      ok:= TRUE;
    END; (* if successful merge file *)
  END; (* if cancel or fselect error *)
  InitMenu; (* sets clipping too *)
  IF ok THEN
    RETURN TRUE;
  END;
  RETURN FALSE; (* either canceled from fselect or failed mergefile *)
(**)
END DoMerge;
(*ds*)

PROCEDURE Newfile(): BOOLEAN;
VAR fseltmp: Fseltype;
    fsel0tmp,fsel0ret: Fsel0type; (* add back in 2.32 3/30/92 *)
    temppath: Pathtype; (* add 2.32 *)
BEGIN
  Selecthead('OPEN FILE/Disk...', TRUE);
  (* update:= FALSE; *)
  (* add this back in for 2.32 3/30/92 *)
  fsel0tmp:= cfg.fsel0;
  temppath:= cfg.oldpath; (* add 2.32 *)
(*
  IF NOT Fselect(cfg.oldpath, fseltmp, TRUE, TRUE) THEN
*)
  IF NOT Fselect(cfg.oldpath, fseltmp, fsel0ret, TRUE, FALSE) THEN
    RETURN FALSE;
  END; (* if cancel or fselect error *)
  IF NOT LoadFile(fseltmp, TRUE) THEN
    cfg.fsel0:= fsel0tmp; (* add back in 2.32 3/30/92 *)
    cfg.oldpath:= temppath; (* add 2.32 *)
    RETURN FALSE;
  END;
(**
  SetSlideSize;
  SetSlidePos;
**)
(*
  MenuItemEnable(MenuTree, SAVE, 1);
*)
  fsel:= fseltmp;
  (* sourcepath:= path; *)
  saved:= TRUE;
  RETURN TRUE;
END Newfile;

PROCEDURE Getfile(): BOOLEAN;
BEGIN
  result:= 1;
  IF last > 0 THEN (* is text now in buffer *)
(**
    mresetptr^:= 0; (* mouse reset flag *)
**
    mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(1,'[2][Open New File or |Merge at cursor ?][New|Merge]');
    CODE(0A00AH); (* lineA Hide mouse *)
  END;
  IF result = 1 THEN
    ok:= Newfile();
    InitMenu;
(*
    update:= FALSE; (* so any redraw msg doesn't do redraw *)
*)
(*ds*)
  ELSE
(*
    ok:= DoMerge(); (* now does its own initmenu due to other access point *)
*)
    RETURN DoMerge(FALSE, FALSE); (* not topastebuff, not clipbrd *)
 (*ds*)
  END;
  IF NOT ok THEN
    RETURN FALSE;
  END;
  (* 2.30 1/26/92 *)
(**
  update:= FALSE; (* so any redraw msg doesn't do redraw *)
  Display(0, cfg.maxdispline);
**)
(* testing... to see if update fixes problem *)
  update:= TRUE;
  (* sometimes after font change then load, there's no display with this *)
  FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
  SetFoundPos(FALSE, TRUE); (* no need to forcetop *)
  SetSlideSize;
  SetSlidePos;
  SetHSlideSize;
  SetHSlidePos;
  RETURN TRUE;
END Getfile;

PROCEDURE GetBlockNum(VAR startftmp, endftmp: LONGCARD;
                      VAR oldblock: CARDINAL):   BOOLEAN;
VAR dTree: ADDRESS;
    x, y, w, h: INTEGER;
    limited: BOOLEAN;
BEGIN
  blocknum:= oldblock; (* default to whatever it was last time *)
  IF maxblock < oldblock THEN (* but not bigger than it's allowed to be now *)
    blocknum:= maxblock;
  END;
  Cardtostrg(LONG(blocknum), cardstrg, FALSE, 5); (* 5 digit longcard *)
  InitObjStrg(BLCKTREE, BLOCKNUM, cardstrg);
(*
  ResourceGetAddr(GEMAESbase.RTree, BLCKTREE, dTree);
*)
  dTree:= TreeAddr^[BLCKTREE];
  (* Windfix; *)(* keeps underlying windows from overwriting dialog *)
  FormCenter(dTree, x,y,w,h);
  FormDialogue(GEMAESbase.FormStart, 0,0,0,0, x,y,w,h);
  ObjectDraw(dTree, 0, 3, x,y,w,h); (* was just before Wupdate(0) *)
  (* WindowUpdate(0); (* end *) *)
(**
  mresetptr^:= 0; (* reset flag *)
**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  LOOP (* changes number in box as inc/dec arrow is held down *)
    result:= FormDo(dTree, BLOCKNUM);
    DeselectObj(BLCKTREE, result, FALSE);
    IF result = BLOCKCAN THEN
      EXIT;
    ELSIF (result = BLOCKOK) THEN (* could have typed in blocknum! *)
      limited:= FALSE;
      GetObjStrg(BLCKTREE, BLOCKNUM, 5, cardstrg);
      tmplong:= Strgtolongc(cardstrg, FALSE); (* TRUE=ishex *)
      IF tmplong > 0FFFFH THEN
        tmplong:= 0FFFFH;
        limited:= TRUE;
      END;
      blocknum:= SHORT(tmplong);
      IF maxblock < blocknum THEN
        blocknum:= maxblock;
        limited:= TRUE;
      END;
      IF NOT limited THEN
        EXIT;
      END;
      ObjectDraw(dTree, BLOCKOK, 0, x,y,w,h); (* was just before Wupdate(0) *)
    ELSE
      IF (result = BIGINC) THEN
        IF (blocknum <= maxblock - kperblock) THEN
          INC(blocknum, kperblock);
        ELSE
          blocknum:= maxblock;
        END; (* if biginc *)
      ELSIF (result = INCBLOCK) & (blocknum < maxblock) THEN
        INC(blocknum);
      ELSIF (result = BIGDEC) THEN
        IF (blocknum >= kperblock) THEN
          DEC(blocknum, kperblock);
        ELSE
          blocknum:= 0;
        END; (* if bigdec *)
      ELSIF (result = DECBLOCK) & (blocknum > 0) THEN
        DEC(blocknum);
      END; (* inc/dec *)
    END; (* if canc/ok *)
(*
    tmplong:= 0; (* testing for biginc dec'ing *)
*)
    tmplong:= LONG(blocknum);
    Cardtostrg(tmplong, cardstrg, FALSE, 5); (* for cases when use inc/dec arrow *)
    InitObjStrg(BLCKTREE, BLOCKNUM, cardstrg);
    (* will this actually redraw the number on the screen? yes, when use ObjDraw *)
    ObjectDraw(dTree, BLOCKNUM, 0, x,y,w,h); (* was just before Wupdate(0) *)
  END; (* loop *)
  CODE(0A00AH); (* lineA Hide mouse *)
  update:= TRUE; (* 6/4/93 *)
  FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, x,y,w,h);
  IF result = BLOCKCAN THEN
    RETURN FALSE;
  END;
  startftmp:= LONG(blocknum) * 0400H; (* 400H = 1K *)
  endftmp:= startftmp + blocksize;
  oldblock:= blocknum;
  RETURN TRUE;
END GetBlockNum;

(* -----------  End File I/O ---------- *)

(* ------------ Start Keyboard & Mouse Input ------------------- *)

PROCEDURE PageUp; (* toward start of file *)
BEGIN
  IF line > 0 THEN (* is reason to do something *)
    IF line <= cfg.maxdispline THEN
      line:= 0; (* page (9 lines) up *)
    ELSE
      DEC(line, cfg.maxdispline); (* provides 1 line overlap *)
    END; (* if line <= 9 *)
    startcol:= 0;
    Display(0, cfg.maxdispline);
    SetSlidePos;
  ELSE (* line = 0, bigpart? *)
      IF PageBigFile(FALSE, TRUE) THEN (* forward?, asksave? *)
        ShowNew;
      END;
  END; (* if line > 0 *)
  ClrHome;
END PageUp;

PROCEDURE PageDown; (* toward end of file *)
BEGIN
  IF line + cfg.maxdispline < lastline THEN (* is room & reason to move down *)
    INC(line, cfg.maxdispline);
    IF lastline - line < cfg.maxdispline THEN
      line:= lastline - cfg.maxdispline;
    END; (* if only partial screen left to show *)
    IF startcol = 0 THEN
      Display(0, cfg.maxdispline);
    END;
    SetSlidePos;
  ELSE (* bigpart? *)
      IF PageBigFile(TRUE, TRUE) THEN (* forward?, asksave? *)
        ShowNew;
      END;
  END; (* if room to pagedown *)
  CheckStart; (* Displays only if startcol <> 0, & resets startcol:=0 *)
  Bottom;
END PageDown;


PROCEDURE ClrHome; (* cursor to top of window *)
BEGIN
  longptr:= lnptradr + ADDRESS(4*LONG(line));
  i:= longptr^;
  linepos:= 0;
  curdispline:= 0;
  CheckStart; (* handles display & setHslidepos *)
  CursorPos(0, leftedge);
END ClrHome;

PROCEDURE Bottom; (* cursor to last displayed position *)
VAR tmpln: CARDINAL;
BEGIN
  curdispline:= Min(lastline - line, cfg.maxdispline);
  tmpln:= line + curdispline;
  longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
 (* need to fix if window is shifted right *)
  linelen:= SHORT(Findend(tmpln) - longptr^); (* linelen *)
  IF linelen >= startcol THEN
    linepos:= Min(linelen - startcol, displaylen);
  ELSE
    Findscrn(linelen);
    linepos:= linelen - startcol;
    Display(0, cfg.maxdispline);
  END; (* if need to shift screens *)
  i:= longptr^ + LONG(linepos + startcol);
  CursorPos(curdispline, leftedge + linepos);
END Bottom;

PROCEDURE ChkClrHome;
BEGIN
  longptr:= lnptradr + ADDRESS(4*LONG(line));
  IF i <> longptr^ THEN
    ClrHome; (* set to top of window *)
  ELSE (* to last screen pos *)
    Bottom;
  END; (* if to home or to end *)
END ChkClrHome;

PROCEDURE DoMenu(VAR newobj: INTEGER);
(* show double-wide fast menu and get choice  v 2.01 *)
VAR oldobj, tmpint: INTEGER;
    menutop: CARDINAL;
    strg: ARRAY[0..30] OF CHAR;
    pxyarray2: PxyArrayType;

  PROCEDURE Highlight;
  BEGIN
    IF oldobj >= 0 THEN
      CODE(0A00AH);  (* LineA hide mouse *)
      SetClipFill(menubX + (oldobj DIV 9)*tmpint, workY + (oldobj MOD 9)*rowH,
        tmpint, rowH, FALSE);
      Showmouse; (* LineA show mouse *)
    END;
  END Highlight;

BEGIN (* main DoMenu *)
  WindowUpdate(3); (* take control of mouse *)
(*
  menuX:= cfg.wind1X + (3 * colW);
  menubX:= menuX + 1;
*)
  (* draw menus *)
  dummy:= SetFillColour(VDIHandle, GEMAESbase.Black) ; (* Set black *)
  dummy:= SetFillInteriorStyle(VDIHandle, 0); (* 0 = hollow fill *)
  dummy:= SetFillPerimeterVisibility(VDIHandle, 1); (* 1 = make visible *)
  dummy:= SetWritingMode(VDIHandle, 1); (* 3=XOR 1=Replace 2=Transparent *)
(* 1st menu *)
  menuW:= 15 * colW;
  menuH:= 9 * rowH + 1;
  pxyarray2[0]:= menubX - 1;
  pxyarray2[1]:= workY - 1;
  pxyarray2[2]:= pxyarray2[0] + menuW + 1;
  pxyarray2[3]:= pxyarray2[1] + menuH;
  DrawBar(VDIHandle, pxyarray2);
(* 2nd menu *)
  pxyarray2[0]:= menubX + menuW;
  pxyarray2[1]:= workY - 1;
  pxyarray2[2]:= pxyarray2[0] + menuW; (* since hilite is one left *)
  pxyarray2[3]:= pxyarray2[1] + menuH;
  DrawBar(VDIHandle, pxyarray2);
  dummy:= SetFillColour(VDIHandle,GEMAESbase.White);
  dummy:= SetFillInteriorStyle(VDIHandle, 1); (* 0=hollow 1=solid fill *)
  dummy:= SetFillPerimeterVisibility(VDIHandle, 0); (* 1 = make visible *)
  menuW:= menuW + menuW;

  (* this just puts 'File' and 'Edit' headers *)
(**^^*)
  dummy:= SetPointCharHeight(VDIHandle, defcharht, dummy,dummy,dummy,dummy);
  IF newobj = 0 THEN
    IF colW >= 8 THEN (* 8x8 or 8x16 *)
      strg:= '    File           Edit       ';
      k:= 30;
    ELSE (* 6x6 font *)
      strg:= '    File       Edit    ';
      k:= 23;
    END;
  ELSE (* newobj = 1, block menu *)
    IF colW >= 8 THEN (* 8x8 or 8x16 *)
      strg:= '    Block          Block      ';
      k:= 30;
    ELSE (* 6x6 font *)
      strg:= '    Block      Block   ';
      k:= 23;
    END;
  END;
  Graphictext(VDIHandle, menubX, workY-2, ADR(strg), k);
  cfg.charht:= SetPointCharHeight(VDIHandle, cfg.charht, dummy,dummy,dummy,dummy);
(*^^**)
  (* now fill in menu item text *)
  tmpint:= colW * 15;
  k:= leftedge + 3;
  menutop:= 0;
  (* for block menu *)
  IF newobj <> 0 THEN (* block menu *)
    menutop:= 18;
  END;
  FOR oldobj:= 0 TO 1 DO (* just use oldobj as tmp counter *)
    FOR j:= menutop TO (menutop + 8) DO
      CursorPos(j - menutop, k); (* sets vcurx & vcury *)
      Graphictext(VDIHandle, INTEGER(vcurx)*colW, vcury+rowH, ADR(item[j]), Length(item[j]));
    END; (* for each item *)
    INC(k, 15);
    INC(menutop, 9);
  END; (* for each of 2 menus *)
  Showmouse;  (* LineA show mouse *)
  ptr1:= lineAadr - ADDRESS(348); (* -015H cur_ms_stat *)
(*
  cardptr:= lineAadr - ADDRESS(596); (* mouse_bt *)
*)
  oldobj:= -1;
  newobj:= -1;
  dummy:= SetWritingMode(VDIHandle, 3); (* XOR *)
  LOOP (* menu interaction to highlight/unhighlight *)
    (* get mouse coords *)
    cardptr:= lineAadr - ADDRESS(602); (* cur_x *)
    mX0:= cardptr^;
    INC(cardptr, 2); (* cur_y *)
    mY0:= cardptr^;
    IF (mX0 < menuX) OR (mX0 > menuX + menuW - 1) OR (mY0 < menubY) OR
      (mY0 > workY + menuH - 2) THEN (* close/exit/no-select *)
      newobj:= -1;
      EXIT;
    END;
    (* determine new object *)
    IF mY0 < workY THEN (* in header area *)
      newobj:= -1;
    ELSE (* in menu item area *)
      newobj:= (mY0 - workY) DIV rowH;
      IF mX0 > menuX + tmpint THEN (* in second menu *)
        INC(newobj, 9);
      END; (* if 2nd menu *)
    END;
    (* un/highlight objects as mouse moves *)
    IF (newobj <> oldobj) THEN (* moved to other object *)
      (* first unhighlght old menu item *)
      Highlight;
      (* highlight new item *)
      oldobj:= newobj;
      Highlight;
    END; (* if newobj <> obj *)
    (* check if mouse button clicked *)
    IF (0 IN BITSET(ORD(ptr1^))) & (newobj >= 0) THEN (* left button pressed *)
(**
      (* clear the button event that must have occurred, why needed? *)
      (* this extra event check makes things work nice with TOS 1.0 *)
      dummy:= EventMultiple(GEMAESbase.ButtonEvent,
                         1,1,1, (* wait for left button down *)
                         0,0,0,0,0,
                         0,0,0,0,0,
                         ADR(pipeBuff), 0,0,
                         dummy,dummy,dummy,dummy, dummy, dummy);

**)
      Waitup(FALSE); (* T = both lineA loop & gem *)
      EXIT;
    END; (* if button pressed *)
  END; (* loop *)
  CODE(0A00AH);  (* LineA hide mouse *)
  dummy:= SetWritingMode(VDIHandle, 1); (* replace *)
(**)
  (* redraw text area where menu was *)
  (* FormFinish handles text, but not block highlighting properly *)
  dummy:= 0;
  IF cfg.maxdispline = 8 THEN (* handle non-redraw of menu bottom *)
    (* implies smallest 8x16 window in mono, menu bottom hits window *)
    dummy:= 1;
  END;
  Redraw(menuX, workY, menuW+4, menuH-dummy);
  WindowUpdate(2); (* give mouse control back to GEM *)
END DoMenu;


PROCEDURE Wait(VAR result, mX, mY, kret: INTEGER);  (* for left button or keypress *)
(*
PROCEDURE Wait;  (* for left button or keypress *)
*)
BEGIN
(*
  WindowUpdate(0);
*)
(**
  LOOP
    IF Bcosstat(2,1) THEN 
    (* keypressed (device 2, input=1) *)
      kret:= INTEGER(BconinGetBPB(2, 2)); (* dev=2=CON, opcode=2=bconin *)
      EXIT;
    ELSIF 0 IN BITSET(ORD(mstatptr^)) THEN
    (* left button changed *)
      mstatptr^:= CHR(ORD(mstatptr^) - 1); (* clear bit? *)
      Windfix;
      EXIT;
    END; (* if exit *)
  END; (* wait loop *)
**)
(**)
  WindowUpdate(3); (* take control of mouse from GEM *)
  Showmouse; (* LineA show mouse *)
(*
  adrptr:= lineAadr + ADDRESS(16); (* INTOUT *)
  cardptr:= adrptr^ + ADDRESS(10); (* intout[5] *)
  cardptr^:= 03920H;
  kret:= 03920H;
*)
  Waitup(FALSE); (* T = both lineA loop & gem *)
  result:= EventMultiple(GEMAESbase.KeyboardEvent + GEMAESbase.ButtonEvent
                         (* GEMAESbase.MesageEvent *),
                         1,1,1, (* wait for left button down *)
(*
                         1,2,2, (* wait for right button down *)
*)                         0,0,0,0,0, 0,0,0,0,0,
                         ADR(pipeBuff), 0,0,
                         mX, mY, dummy,dummy, kret, dummy);
  CODE(0A00AH);  (* LineA hide mouse *)
  IF result = GEMAESbase.ButtonEvent THEN
    Waitup(FALSE); (* F = just lineA loop *)
(***
    result:= EventMultiple(GEMAESbase.KeyboardEvent + GEMAESbase.ButtonEvent
                           (* GEMAESbase.MesageEvent *),
                           1,2,0, (* wait for right button up *)
                           0,0,0,0,0, 0,0,0,0,0,
                           ADR(pipeBuff), 0,0,
                           dummy,dummy,dummy,dummy, inout, dummy);
***)
    kret:= 0;
  END;
  WindowUpdate(2); (* give back control of mouse to GEM *)
(**)
(*
  WindowUpdate(1);
*)
END Wait;

PROCEDURE Waitup(both: BOOLEAN);
(* waits for left button up *)
BEGIN
(**
  ptr1:= lineAadr - ADDRESS(348); (* -015H cur_ms_stat *)
  LOOP
    IF NOT (0 IN BITSET(ORD(ptr1^))) THEN (* left button up *)
      EXIT;
    END;
  END;
(***)
  IF both THEN
**)
    dummy:= EventMultiple((* GEMAESbase.KeyboardEvent + *) GEMAESbase.ButtonEvent,
                         1,1,0, (* 3rd 0 means wait for buttons up *)
                         0,0,0,0,0, 0,0,0,0,0,
                         ADR(pipeBuff), 0,0,
                         dummy,dummy,dummy,dummy, dummy, dummy);
(***
  END;
***)
(***)
  ptr1:= lineAadr - ADDRESS(348); (* -015H cur_ms_stat *)
  LOOP
    IF NOT (0 IN BITSET(ORD(ptr1^))) THEN (* left button up *)
      EXIT;
    END;
  END;
(***)
END Waitup;


PROCEDURE DoHelp;
(* resource dialog version for 2.30 1/25/92 *)
VAR nexttree, x,y,w,h: INTEGER; (* temp dialog coords *)
BEGIN
  nexttree:= HELPTRE0;
  LOOP (* go through help dialogs until an Exit is clicked *)
    treeptr:= TreeAddr^[nexttree];
    FormCenter(treeptr, x,y,w,h);
    FormDialogue(GEMAESbase.FormStart, 0,0,0,0, x,y,w,h);
    ObjectDraw(treeptr, 0, 2, x,y,w,h);

    Showmouse; (* lineA Show mouse *)
    result:= FormDo(treeptr, 0); (* 0 = no editable *)
    CODE(0A00AH); (* lineA Hide mouse *)
    update:= TRUE;
    FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, x,y,w,h);
    DeselectObj(nexttree, result, FALSE); (* unhighlight *)
    IF (result = HELP0EXI) OR (result = HELP1EXI) OR 
       (result = HELP2EXI) OR (result = HELP3EXI) OR
       (result = HELP4EXI) THEN
      EXIT;
    END;
    (* else move onto next dialog *)
    IF nexttree = HELPTRE0 THEN
      nexttree:= HELPTRE1;
    ELSIF nexttree = HELPTRE1 THEN
      nexttree:= HELPTRE2;
    ELSIF nexttree = HELPTRE2 THEN
      nexttree:= HELPTRE4;
    ELSIF nexttree = HELPTRE4 THEN
      nexttree:= HELPTRE3;
    ELSE
      nexttree:= HELPTRE0;
    END;
  END; (* help loop *)
END DoHelp;

PROCEDURE DoQuit;
BEGIN
  IF SaveCheck(TRUE, TRUE) THEN (* askbig & asksave *)
    (* update:= TRUE; *)
(**
    (* removed for 3.0N *)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(1,"[2][Really want to Quit?][Yes|No]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF result = 1 THEN
**)
      ok:= FALSE; (* 2.33, 4/10/92 for non-alt-exit *)
      Terminate;
(**
    END; (* if really quit *)
**)
  END; (* if file not saved *)
END DoQuit;

(*ds*)
PROCEDURE BlockCheck;
BEGIN
  IF blockend < blockstart THEN (* switch block markers *)
    tmplong:= blockstart;
    blockstart:= blockend;
    blockend:= tmplong;
  END;
(*
  saveline:= Findline(blockstart);
*)
(*+
  isblock:= TRUE;
+*)
  notistrg:= 'Block Set ';
  Notice;
  mark[0]:= blockstart;
  mark[1]:= blockend;
END BlockCheck;

PROCEDURE CopyBlk(toclip: INTEGER);
(* 0 = ask, 1 = buffer, 2 = clipbrd *)
BEGIN
  IF blocktype > 0 THEN
    IF toclip = 2 THEN (* clip *)
      CutClip(FALSE); (* copy only *)
    ELSIF toclip = 1 THEN (* buffer *)
      IF blocktype = 2 THEN (* col block *)
        ok:= Copycolblk(FALSE); (* not firstcol *)
      ELSIF blocktype = 1 THEN (* normal block copy *)
        delstart:= blockstart; (* global *)
        pastelen:= 0; (* zero the undo buffer *)
        ok:= Copyblock(blockend);
      END; (* if blocktype *)
      RuinBlock(TRUE);
    END; (* if copy to buffer *)
  ELSE
    BlockAlert;
  END; (* if is block *)
END CopyBlk;

PROCEDURE DoCut(toclip: INTEGER);
(* 0 = ask, 1 = buffer, 2 = clipbrd *)
BEGIN
  IF blocktype > 0 (* isblock *) THEN (* a valid block has been selected *)
    IF toclip = 2 THEN
      CutClip(TRUE); (* withdelete *)
    ELSIF toclip = 1 THEN  
      delstart:= blockstart; (* global *)
      IF blocktype = 1 THEN
        pastelen:= 0; (* zero the undo buffer *)
        ok:= Cutblock(blockend);
      ELSE (* 2 = column block *)
        ok:= Copycolblk(FALSE);
        IF ok THEN
          Delcolblk(FALSE); (* not firstcol *)
        END;
      END;
      IF ok THEN
        (* blockstart:= 0FFFFH; (** why? **) *)
        blocktype:= 0; (* isblock:= FALSE; *)
        notistrg:= 0C;
        InitMenu; (* clear the mark notices *)
        Display(curdispline, cfg.maxdispline);
        Bottomstay;
      END; (* if didn't cancel when/if found paste buffer wasn't big enough *)
    END; (* if to clipbrd *)
  ELSE
    BlockAlert;
  END;
END DoCut;
(*ds*)

PROCEDURE ShiftBlk(leftrt: CARDINAL);
(* 0 = left, 1 = right, 2 = quote *)
BEGIN
  IF blocktype > 0 THEN
    IF leftrt = 0 THEN  (* delete 1st colblk *)
      IF Copycolblk(TRUE) THEN (* firstcol, allow undo via shift-F5 *)
        Delcolblk(TRUE); (* firstcol *)
        Display(curdispline, cfg.maxdispline);
      END;
    ELSE (* insert col *)
      ch:= ' '; (* right, insert blank col *)
      IF leftrt = 2 THEN (* quote *)
        ch:= '>';  
      END;
      saveline:= Findline(blockstart);
      longptr:= lnptradr + ADDRESS(4 * LONG(saveline));
      i:= longptr^; (* start of line *)
      SetFoundPos(FALSE, TRUE); (* no forcetop; yes calc linepos *)
      j:= Findline(blockend) - saveline + 1; (* number of lines *)
      (* fill pastebuff with fill chars *)
      pastelen:= LONG(j) * 3; (* add cr/lf's *)
      IF pastelen > 4*LONG(maxlines) THEN (* truncate *)
        j:= SHORT(4*LONG(maxlines) DIV 3);
        pastelen:= LONG(j) * 3;
      END;
      INC(blockend, j); (* ?? *)
      ptr1:= newlnptradr;
      LOOP
        IF (j <= 0) THEN
          EXIT;
        END;
        ptr1^:= ch;
        INC(ptr1);
        ptr1^:= 15C; (* CR *)
        INC(ptr1);
        ptr1^:= 12C; (* LF *)
        INC(ptr1);
        DEC(j);
      END; (* loop *)
      ok:= Pastecolblk();
  (*
      longptr:= lnptradr + ADDRESS(4 * LONG(Findline(blockend)));
      i:= longptr^; (* set to last line of block *)
      SetFoundPos(FALSE, TRUE); (* no forcetop; yes calc linepos *)
  *)
    END; (* if del vs insert *)
  (* remove for 3.02 put in for 3.0N *)
    saved:= FALSE;
  ELSE (* no block *)
    AddInsert; (* space *)
  END; (* if isblock *)
END ShiftBlk;


PROCEDURE CutClip(withdelete: BOOLEAN);
(* Cut to clipboard *)
VAR fsel0tmp: Fsel0type;
    fseltmp: Fseltype;
    count, pos: LONGCARD;
    handle: INTEGER;
    fromadr: ADDRESS;
BEGIN
  delstart:= blockstart; (* global *)
  ok:= FALSE;
  IF blocktype = 1 THEN (* copy directly to scrap.txt *)
    fromadr:= startadr + ADDRESS(blockstart);
    count:= blockend - blockstart;
    ok:= TRUE;
  ELSIF blocktype = 2 THEN (* column block *)
    ok:= Copycolblk(FALSE);
    fromadr:= newlnptradr; (* pastebuffer *)
    count:= pastelen;
  END;
  (* write paste buffer to clipboard *)
  IF ok & Clipbrd() THEN (* set 'path' to clipboard if exists or user desires *)
    fsel0tmp:= 'SCRAP.TXT';
    Concat(path, fsel0tmp, fseltmp); (* gives e.g., A:\path\*.* *)
    Create(fseltmp, 0, handle); (* 0 = read/write *)
    pos:= count;
    Write(handle, count, fromadr); (* write to scrap file *)
    IF (NOT Close(handle)) OR (count <> pos) THEN
      WriteErr;
    END;
    IF withdelete THEN
      IF blocktype = 1 THEN
        ok:= Cutblock(blockend); (* actually just want delete block *)
      ELSE (* col block *)
        Delcolblk(FALSE); (* not firstcol *)
      END;
    END; (* if delete *)
  END; (* if copied to clipboard *)
  IF ok THEN (* did do copy/deletion *)
    IF withdelete THEN
      blocktype:= 0; (* isblock:= FALSE; *)
      notistrg:= 0C;
      InitMenu; (* clear the mark notices *)
      Display(curdispline, cfg.maxdispline);
      Bottomstay;
    ELSE (* copy only *)
      RuinBlock(TRUE);
    END;
  END; (* if didn't cancel when/if found paste buffer wasn't big enough *)
END CutClip;

PROCEDURE PasteBlk(colblk, fromclip: BOOLEAN);
BEGIN
(**
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[1][Paste from:|PasteBuffer or|Clipboard?][Buff|Clip|Cancel]');
  CODE(0A00AH); (* lineA Hide mouse *)
**)
  IF fromclip (* dummy = 2 *) THEN (* merge clipboard *)
    IF DoMerge(colblk, TRUE) THEN (* T = clipbrd *)
      IF colblk THEN
        ok:= Pastecolblk();
      END;
    END;
  ELSE (* IF dummy = 1 THEN *)(* from buffer *)
    IF colblk THEN
      ok:= Pastecolblk();
    ELSE
      Pasteblock;
    END;
  END; (* if not cancel *)
END PasteBlk;


PROCEDURE DeselectObj(tree: INTEGER; obindex: INTEGER; setit: BOOLEAN);
(** NOTE: Selects OR DEselects depending on setit **)
VAR b: BITSET;
BEGIN
  treeptr:= TreeAddr^[tree];
  b:= BITSET(treeptr^[obindex].state);
(*
  b:= GetObjectState(tree, obindex);
*)
  b:= b - {Select}; (* default to deselect *)
  IF setit THEN
    b:= b + {Select};
  END;
(*
  SetObjectState(tree, obindex, b);
*)
  treeptr^[obindex].state:= INTEGER(b);
END DeselectObj;
          
(** All TEXT1, TEXT2, & BLOKTX? strings WERE InitStrg calls
    not TEXTSTRG or BLOKNUM... **)

(**2.1**)
PROCEDURE InitObjStrg(tree, obindex: INTEGER; strg: ARRAY OF CHAR);
VAR tedptr: POINTER TO GEMAESbase.TEdInfo;
    (* txtptr: POINTER TO CHAR; *) (* ARRAY[0..31] OF CHAR; *)
BEGIN
(*
  ResourceGetAddr(GEMAESbase.RTree, tree, treeptr);
*)
  treeptr:= TreeAddr^[tree];
  tedptr:= treeptr^[obindex].spec;
  IF 3 IN BITSET(treeptr^[obindex].flags) THEN (* editable *)
(*
    txtptr:= tedptr^.ptext;
    tedptr:= ADDRESS(txtptr);
*)
    tedptr:= tedptr^.ptext;
  END;

  MoveMem(ADR(strg), tedptr, LONG(Length(strg)+1)); (* +1 for final 0C is needed *)
(*
  MoveMem(ADR(strg), tedptr, LONG(Length(strg))); (* +1 for final 0C not needed *)
*)
END InitObjStrg;
(**)

PROCEDURE GetObjStrg(tree, obindex: INTEGER; len: CARDINAL;
                     VAR strg: ARRAY OF CHAR);
VAR i: CARDINAL;
    txtadr: POINTER TO ARRAY[0..30] OF CHAR;
    tedadr: POINTER TO GEMAESbase.TEdInfo;
BEGIN
(*
  ResourceGetAddr(GEMAESbase.RTree, tree, treeptr);
*)
  treeptr:= TreeAddr^[tree];
  tedadr:= treeptr^[obindex].spec;
  txtadr:= tedadr^.ptext;
  i:= 0;
  (** Note: will not find underline character at end of string **)
  WHILE (txtadr^[len] = '_') & (len > 0) DO  (* strip backward to end of string *)
    DEC(len);
  END;
  IF txtadr^[len] <> '_' THEN (* some string entered *)
    WHILE (i <= len) DO
      strg[i]:= txtadr^[i];
      INC(i);
    END; (* while <= len *)
  END; (* if *)
  strg[i]:= 0C; (* terminator *)
END GetObjStrg;

(*ds*
(** moved to separate module for Edit Plus **)
PROCEDURE Encrypt(): BOOLEAN;
VAR j, k, pwlen: CARDINAL;
    pw: Substrg; (* password *)
    result: INTEGER;
    chptr: POINTER TO CHAR;
    getnew: BOOLEAN;
BEGIN (* main encrypt *)
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][Do Not Encrypt if|File bigger than buffer|or will Append][OK|Cancel]');
  CODE(0A00AH); (* lineA Hide mouse *)
  IF dummy = 2 THEN
    RETURN FALSE;
  END;
  pw[0]:= 0C; (* init *)
  InitObjStrg(TEXTTREE, TEXTSTRG, pw);
  InitObjStrg(TEXTTREE, TEXT1, 'ENCRYPT/DECRYPT BUFFER');
  InitObjStrg(TEXTTREE, TEXT2, 'Enter your password:');
  getnew:= TRUE;
  pwlen:= GetStrg(pw, getnew, FALSE); (* disable hex/dec buttons *)
  IF (pwlen = 0) OR (pwlen = 0FFH) THEN (* cancelled or zero length strg *)
    RETURN FALSE;
  END;
  (* encrypt password so run of spaces doesn't reveal it *)
  j:= 0;
  WHILE j < pwlen DO
    pw[j]:= CHR(CARDINAL( BITSET(ORD(pw[j])) / BITSET(60) ));
    (* 60 just for the heck of it *)
    INC(j);
  END; (* while *)
  (* now encrypt buffer using encrypted password *)
  tmplong:= 0;
  chptr:= startadr;
  LOOP (* WHILE j <= last DO *)
    k:= 0;
    WHILE k < pwlen DO
      chptr^:= CHR(CARDINAL( BITSET(ORD(chptr^)) / BITSET(pw[k]) ));
      (* char XOR pw; = union - intersection = symmetric difference *)
      IF tmplong >= last THEN EXIT;
      END;
      INC(tmplong);
      INC(k);
      INC(chptr);
    END; (* while *)
  END; (* loop *)
  Lineptrs(0);
  MiniInit; (* sets i = 0, etc. *)
  saved:= FALSE;
  Display(0, cfg.maxdispline);
  SetSlideSize;
  SetSlidePos;
  RETURN TRUE;
END Encrypt;
*ds*)

(*ds*)
PROCEDURE GetStrg(VAR strg: Substrg; VAR getnew: BOOLEAN;
           hexdecok: BOOLEAN): CARDINAL;     (**2.1R**  VAR btn: INTEGER **)
(* Returns length of string, even if new strg includes nulls
   btn is which txt, hex, decimal button to default to *)
VAR tmpstrg: Substrg; (* only needs to be half this length *)
    okset: Charset; (* hex or decimal chars + 0C *)
    hexdecstrg: ARRAY[0..3] OF CHAR;
    len, card: CARDINAL;
    result: INTEGER;
    x,y,w,h: INTEGER;
    (* dTree: ADDRESS; *)
BEGIN
(*
  result:= DoDialog(TEXTTREE, TEXTSTRG);
*)
  (* Windfix; *)
(*
  ResourceGetAddr(GEMAESbase.RTree, TEXTTREE, treeptr); (* was dTree *)
*)
  treeptr:= TreeAddr^[TEXTTREE];
  FOR result:= TXTBTN TO DECBTN DO (* init button states *)
    DeselectObj(TEXTTREE, result, FALSE); (* DEselect all 3 objects *)
  END; (* for 3 buttons *)    
(**2.1R**)
(*
  DeselectObj(TEXTTREE, btn, TRUE); (* select object *)
*)
  IF NOT hexdecok THEN (* disable hex & dec buttons in dialog *)
    (* disable HEX & DEC BTNS whether were enabled or not *)
    treeptr^[HEXBTN].state:= INTEGER(BITSET(treeptr^[HEXBTN].state) + BITSET(8));
    treeptr^[DECBTN].state:= INTEGER(BITSET(treeptr^[DECBTN].state) + BITSET(8));
    DeselectObj(TEXTTREE, TXTBTN, TRUE); (* Force select text button *)
  ELSE
    DeselectObj(TEXTTREE, findbtn, TRUE); (* select default button *)
  END; (* if enable hex & dec *)
  (* Windfix; *)
  FormCenter(treeptr, x,y,w,h);
  FormDialogue(GEMAESbase.FormStart, 0,0,0,0, x,y,w,h);
  ObjectDraw(treeptr, 0, 2, x,y,w,h);
(**
  mresetptr^:= 0; (* reset flag *)
**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  result:= FormDo(treeptr, TEXTSTRG);
  CODE(0A00AH); (* lineA Hide mouse *)
  update:= TRUE;
  FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, x,y,w,h);
(****
  WindowUpdate(0);
  WindowUpdate(1);
****)
  (* always re-enable hex & dec buttons *)
  treeptr^[HEXBTN].state:= INTEGER(BITSET(treeptr^[HEXBTN].state) - BITSET(8));
  treeptr^[DECBTN].state:= INTEGER(BITSET(treeptr^[DECBTN].state) - BITSET(8));
  IF result <> TEXTCANC THEN
    (* Redraw(x,y,w,h); *)
    (* Go ahead and decipher string and then search *)
    GetObjStrg(TEXTTREE, TEXTSTRG, 20, strg);
    DeselectObj(TEXTTREE, TEXTOK, FALSE);
    IF strg[0] = 0C THEN (* string of zero length *)
      RETURN 0;
    END;

    IF ADR(strg) = ADR(findstrg) THEN (* relacing findstrg *)
      IF Compare(findstrg, oldfindstrg) THEN
        getnew:= FALSE; (* so will inc(indexadr) so not find same again *)
      END;
      oldfindstrg:= findstrg;
    ELSIF ADR(strg) = ADR(repstrg) THEN (* changing replace strg *)
      oldrepstrg:= strg;
    END;

    len:= Length(strg);
    findbtn:= TXTBTN; (* default 2.1R**)

    (*** Check for and decipher hex numeric string ***)

(*
    IF Select IN GetObjectState(TEXTTREE, HEXBTN) THEN (* decode hex number *)
*)
    IF Select IN (BITSET(treeptr^[HEXBTN].state)) THEN
      okset:= Hexset;
      findbtn:= HEXBTN;
      hexdecstrg[2]:= 0C;
      k:= 0; (* original strg index *)
      j:= 0; (* converted byte strg index *)
      LOOP (* decode hex string *)
        IF NOT (strg[k] IN okset) THEN (* NOT a valid hex number, treat as txt *)
          EXIT;
        END; (* if fail hex test *)
        (* This SHOULD allow null chars inside new string *)
        IF strg[k] = 0C THEN (* Entire strg IS a valid hex number *)
          tmpstrg[j]:= 0C;
          strg:= tmpstrg;
          len:= j;
          EXIT;
        END; (* if end of valid hex strg *)
        IF k MOD 2 = 1 THEN (* convert two hex digits to byte *)
          hexdecstrg[0]:= CAP(strg[k-1]);
          hexdecstrg[1]:= CAP(strg[k]);
          tmpstrg[j]:= CHR(SHORT(Strgtolongc(hexdecstrg, TRUE))); (* TRUE=ishex *)
          INC(j); (* move to next byte in converted strg *)
        END;
        INC(k);
      END; (* hex decode loop *)

    (*** Now Check & Decode DECIMAL number ***)

(*
    ELSIF Select IN GetObjectState(TEXTTREE, DECBTN) THEN (* decode decimal number *)
*)
    ELSIF Select IN (BITSET(treeptr^[DECBTN].state)) THEN
(** unneeded since can't select hex or dec if not doing find/rep/ins
      IF ok THEN (* doing findstrg or repstrg *)
        findbtn:= DECBTN;
      END;
**)
      findbtn:= DECBTN;
      k:= 0; (* original strg index *)
      j:= 0; (* converted byte strg index *)
      card:= 0;
      okset:= Charset{'0'..'9'};
(*
      INCL(okset, 0C);
*)
      LOOP (* decode decimal string *)
        INCL(okset, 0C);
        WHILE NOT (strg[k] IN okset) DO (* NOT a valid decimal character *)
          INC(k); (* treat any non 1..9 char as separator including leading zeros *)
(*
          EXIT; (* so treat as text *)
*)
        END; (* if fail decimal test *)
        (* This SHOULD allow null chars inside new string *)
        IF strg[k] = 0C THEN (* strg HAS at least 1 valid dec number in it *)
          tmpstrg[j]:= 0C;   (* or is zero length *)
          strg:= tmpstrg;
          len:= j;
          EXIT;
        END; (* if end of valid hex strg *)
        hexdecstrg[card]:= strg[k];
        INC(k);
        INC(card);
        EXCL(okset, 0C);
        IF (NOT (strg[k] IN okset)) OR (card >= 3) THEN 
          (* hit end of 1 dec number, so convert it to one byte *)
          hexdecstrg[card]:= 0C;
          tmpstrg[j]:= CHR(SHORT(Strgtolongc(hexdecstrg, FALSE))); (* TRUE=ishex *)
          INC(j);
          card:= 0; (* initialize 0..2 counter *)
        END;
      END; (* decimal decode loop *)
    END; (* if is a hex or decimal string *)
  ELSE (* canceled from find dialog *)
    DeselectObj(TEXTTREE, TEXTCANC, FALSE);
    RETURN 0FFH; (* to distinguish it from string of length zero. FALSE; *)
  END; (* if not canceled from find dialog *)
  RETURN len; (* either length of original string, or of new hex byte strg *)
END GetStrg;

PROCEDURE InsertBytes;
(* allow insertion of any hex bytes 0..FF *)
VAR bytestrg: Substrg;
    j, strlen: CARDINAL;
BEGIN
  bytestrg:= 0C;
  InitObjStrg(TEXTTREE, TEXT1, 'Insert String at Cursor');
  InitObjStrg(TEXTTREE, TEXT2, "(HEX:xxyy  DEC:xx,yyy,z)");
  InitObjStrg(TEXTTREE, TEXTSTRG, bytestrg); (* return to '' for 3.13 *)
  strlen:= GetStrg(bytestrg, ok, TRUE (*, findbtn *) ); (* ok is just a dummy boolean here *)
  IF (strlen <> 0) & (strlen <> 0FFH) THEN (* not cancelled or zero length strg *)
(**
    ok:= cfg.insertmode; (* for temp storage *)
    cfg.insertmode:= TRUE; (* force insert rather than overwrite *)
**)
    j:= 0;
    kreturn:= 0; (* 2.37 *)
    WHILE j < strlen DO (* insert each character *)
      newchar:= bytestrg[j];
      AddInsert; (* DoAscii; *)
      INC(j);
    END; (* while inserting *)
(**
    cfg.insertmode:= ok; (* restore orig insert mode *)
**)
  END;  
END InsertBytes;


PROCEDURE GetFindStrg(VAR getnew: BOOLEAN): CARDINAL;
(* returns length of string so can later use length even if has nulls *)
VAR j, strlen: CARDINAL;
BEGIN
  InitObjStrg(TEXTTREE, TEXT1, 'FIND String of Characters');
  InitObjStrg(TEXTTREE, TEXT2, "(HEX:xxyy   DEC:xx,yyy,z)");
  InitObjStrg(TEXTTREE, TEXTSTRG, oldfindstrg);
  (* oldfindstrg is char representation of txt, hex, or dec strings *)
  strlen:= GetStrg(findstrg, getnew, TRUE); (* allow dec/hex buttons *)
  IF (strlen <> 0) & (strlen <> 0FFH) THEN (* not cancelled or zero length strg *)
    (* CaseSensitive; *)
    j:= 1;
    IF cfg.casesens THEN
      j:= 2;
    END;
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(j,"[2][Case Sensitive Search ?][No|Yes]");
    CODE(0A00AH); (* lineA Hide mouse *)
    cfg.casesens:= FALSE; (* default *)
    IF result = 2 THEN
      cfg.casesens:= TRUE;
    END;
  END;
  RETURN strlen;
END GetFindStrg;

PROCEDURE SetFoundPos(forcetop, findlnpos: BOOLEAN);
(* puts cursor at index i doing any needed redisplay *)
VAR j, newln: CARDINAL;
BEGIN
  IF i > last THEN (* needed for goto marks *)
    i:= last;
  END;
  newln:= Findline(i); (* here newln is measured from buffline *)
(**
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][done Findline][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
**)
  IF findlnpos THEN
    longptr:= lnptradr + ADDRESS(4*LONG(newln));
    linepos:= SHORT(i - longptr^);
  END; (* if need to find line *)
  j:= startcol;
  Findscrn(linepos); (* sets startcol *)
  DEC(linepos, startcol); (* was in next IF *)
  IF startcol <> j THEN
    Display(0, cfg.maxdispline);
    SetHSlidePos;
  END; (* if shift screen *)
  IF (newln < line) OR (newln > line + cfg.maxdispline) OR forcetop 
   OR (startf <> startfold) THEN
    curdispline:= 1; (* set to display one row down from top *)
    IF newln = 0 THEN (* was lastline < 1 *)
      curdispline:= 0;
    END;
    IF (line + curdispline <> newln) OR (startf <> startfold) THEN
      startfold:= startf; (* 3.2C want? *)
      line:= newln - curdispline;
      Display(0, cfg.maxdispline);
      Bottomstay; (* sets all slidesize/pos *)
    END;
  ELSE (* don't need to redraw screen *)
    curdispline:= newln - line;
  END;
  CursorPos(curdispline, leftedge + linepos);
END SetFoundPos;

PROCEDURE FoundAlert; (* (askextend: BOOLEAN): BOOLEAN; *)
BEGIN
  Showmouse; (* LineA show mouse *)
  dummy:= FormAlert(1,"[0][No More Found   ][ OK ]");
  CODE(0A00AH);  (* LineA hide mouse *)
(*2.25*
  IF askextend THEN (* file bigger than buffer or disk or RAM *)
    dummy:= FormAlert(2,"[2][ None found in buffer ][Cancel|Extend Search]");
  ELSE
    dummy:= FormAlert(1,"[0][No More Found   ][ OK ]");
  END;
  CODE(0A00AH);  (* LineA hide mouse *)
  IF dummy = 1 THEN
    RETURN TRUE; (* done searching *)
  END;    
  RETURN FALSE; (* not done, continue search in bigfile, disk or ram *)
*2.25*)
END FoundAlert;

PROCEDURE DoFind(getnew: BOOLEAN): BOOLEAN; (* true if need to do whole dialog *)
VAR (* findstrg: Substrg; *)
    replen: CARDINAL; (* srchlen is now global *)
    indexadr, saveadr, remainsadr: ADDRESS;
    freespace, reps: LONGCARD; (* 3.1H *)
    tmplongint: LONGINT;
    searchres, repres, allres, extend: INTEGER;
    tmpstrg: Substrg;
    found, ok, firsttime, blksrch: BOOLEAN;

PROCEDURE FreeMemChk(tmpadr: ADDRESS);
BEGIN
  IF blksrch THEN (** free the ram grabbed for block search **)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(tmpadr); (* to free ram block at this address *)
    PUSH(049H); (* mfree code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  END; (* if needed to restore malloc'd ram *)
END FreeMemChk;

BEGIN (* Main DoFind, Search/Replace *)
  blksrch:= FALSE;
  searchres:= 1;
  allres:= 1; (* not all *)
  indexadr:= startadr + ADDRESS(i); (* start searching from current cursor position *)
(*
  findstrg:= oldfindstrg; (* this would screw up hex & dec searches *)
*)
  (* needed since Find() capitalizes all of findstrg if case-insens search *)
  IF getnew OR (findadr = ADDRESS(0456H)) THEN (* findadr used by kwiksend *)
(**
    mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
    Showmouse; (* lineA Show mouse *)
    searchres:= FormAlert(1, "[1][Search/Replace Options:    | (1) Find| (2) Find/Replace][1|2|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF searchres = 3 THEN (* cancelled *)
      RETURN TRUE; (* 2.25 was FALSE; *)
    ELSE (* get find string *)
(**)
      IF blocktype = 1 THEN (* isblock, so use block as findstrg *)
        tmplong:= blockend - blockstart;
        srchlen:= SHORT(tmplong); (* better be < 65535 *)
(**
      (* testing only, need tmp buffer for replaces before block, bigfile & repall *)
        findadr:= startadr + ADDRESS(blockstart); 
**)
        (* grab desired ram *)
        (* save registers *)
        CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
        PUSH(tmplong); (* to grab tmp RAM buffer for search 'string' *)
        PUSH(048H); (* malloc code *)
        CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
        CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
        (* restore all necessary registers *)
        (* movem.l A1-A2/D1-D2,(SP)+ *)
        CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
        tmplongint:= LONGINT(REGISTER(D0));
        blksrch:= TRUE;
        findadr:= ADDRESS(tmplongint);
        IF tmplongint < 1 THEN (* malloc error, not enough free ram *)
          Showmouse; (* lineA Show mouse *)
          dummy:= FormAlert(1,'[3][Not enough free RAM][ OK ]');
          CODE(0A00AH); (* lineA Hide mouse *)
          FreeMemChk(findadr);
          RETURN TRUE;
        ELSE (* success *)
          MoveMem(startadr + ADDRESS(blockstart), findadr, tmplong);
        END; (* if enough ram *)
      ELSE (* not searching for block *)
        findadr:= ADR(findstrg);
        srchlen:= GetFindStrg(getnew);
        IF (srchlen = 0) OR (srchlen = 0FFH) THEN (* zero length or cancelled *)
          FreeMemChk(findadr);
          RETURN TRUE; (* 2.25 was FALSE; *)
        END;
      END; (* if block *)
    END; (* if searchres = 3 *)
(*
  ELSE (* not getnew *)
    INC(indexadr); (* so not find same string location again with F6 *)
*)
  END; (* if get new findstrg *)
(*213*)
  IF NOT getnew THEN (* separate from above IF block since
                      getnew could have changed in GetFindStrg *)
    INC(indexadr); (* so not find same string location  with F6 or repeat *)
  END; (* if not getnew *)

  IF searchres = 2 THEN (* replace *)
    (* Get Replace String *)
    InitObjStrg(TEXTTREE, TEXT1, '   Replace with What:');
    InitObjStrg(TEXTTREE, TEXTSTRG, oldrepstrg);

    replen:= GetStrg(repstrg, getnew, TRUE (*, findbtn *) );

    IF replen = 0FFH THEN (* cancelled *)
      FreeMemChk(findadr);
      RETURN TRUE; (* 2.25 was FALSE; *)
    END; (* if cancelled from getstrg dialog *)
(**
    mhideptr^:= 1;
**)
    Showmouse; (* lineA Show mouse *)
(*
    allres:= FormAlert(1, "[2][   Replace How Many ?   ][Query|All|Cancel]");
*)
    allres:= FormAlert(cfg.askall, "[2][   Replace How Many ?   ][Query|All|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF allres = 3 THEN (* cancel *)
      Display(0, cfg.maxdispline);
      FreeMemChk(findadr);
      RETURN TRUE; (* 2.25, was FALSE; *)
    ELSIF allres = 2 THEN (* replace all *)
      (*
      GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)
      *)
      notistrg:= 'Working...';
      Notice;
    END; (* if all *)
    cfg.askall:= allres;
    reps:= 0; (* number of replaces *)
  END; (* if need to get replace string *)
  firsttime:= TRUE;
  repres:= 2; (* find next *)
  tmpstrg:= findstrg;

  LOOP (* findbigshell *)

    (* for 3.1H optimize multiple replace strategy *)
    remainsadr:= indexadr;
    saveadr:= indexadr;
    freespace:= buffsize - last;
    IF allres = 2 THEN (* replace all *)
      MoveMem(indexadr, indexadr + ADDRESS(freespace), last - i);
      INC(indexadr, freespace);
      remainsadr:= indexadr;
    END; (* if replace all *)

    LOOP (* 32 bit *)
      found:= FALSE; (* 2.25 *)
      IF Find((last - i), findadr,
       srchlen, cfg.casesens, indexadr) THEN (* found it! *)
(*
      IF Find((last - i), ADR(findstrg),
       srchlen, cfg.casesens, indexadr) THEN (* found it! *)
*)
        found:= TRUE;
        i:= LONGCARD((indexadr-remainsadr)+(saveadr-startadr)); (* found location *)(* 3.1H *)
        IF (searchres = 2) & (allres <> 2) THEN (* just single find/replace *)
          (* position cursor/window *)
          (*
          CursorDraw; (* Curson; *)
          *)
          SetFoundPos(TRUE, TRUE); (* true = force to top of window *)
      (**  (* searchres is always = 2 in here... *)
          IF searchres = 2 THEN (* ask whether to replace it or not *)
      **)
          InitMenu; (* gets rid of 'Working...' and does Notichar *)
  (*
          NotiChar; (* show proper index and char hex value *)
  *)
          CursorDraw; (* Curson; *)
          Showmouse; (* lineA Show mouse *)
          repres:= FormAlert(1, "[2][   Found it!  Now what?   ][Replace|Next|Quit]");
          CODE(0A00AH); (* lineA Hide mouse *)
          CursorDraw; (* Cursoff; *)
  
          IF repres = 3 THEN (* quit *)
            Display(0, cfg.maxdispline); (* 2.25 *)
            EXIT; (* search loop only *)
          ELSIF repres = 2 THEN (* find next *)
            INC(indexadr);
          END; (* if want replace *)
          found:= FALSE; (* so will continue with bigfind if needed *)
        (** END; (* if need to ask *) **)
        ELSIF searchres = 1 THEN (* just find *)
          EXIT; (* search loop only *)
        END; (* if need to display *)
  
        IF (repres = 1) OR (allres = 2) THEN (* Replace *)
          found:= FALSE;
          tmplong:= last; (* was k.  temp storage for later movemem *)
          IF replen > srchlen THEN (* increasing total length *)
            j:= replen - srchlen;
            IF last + LONG(j) > buffsize THEN (* can't fit any more in buffer *)
              FullAlert;
              EXIT; (* search loop only *)
            ELSE (* is room for new text *)
              INC(last, j); (* compiler allows this (long, short)? *)
            END; (* if increasing total length *)
          ELSE (* decreasing total length *)
            DEC(last, srchlen - replen); (* compiler seems to allow this *)
          END; (* if increasing or decreasing length *)
          (* move trailing text to its new location *)
          IF allres = 2 THEN (* replace all *)(* 3.1H *)
            MoveMem(remainsadr, saveadr, LONGCARD(indexadr - remainsadr));
            INC(saveadr, LONGCARD(indexadr - remainsadr));
            IF srchlen > replen THEN
              INC(indexadr, (srchlen-replen));
            ELSE (* replen >= srchlen *)
              DEC(indexadr, (replen-srchlen));
            END;
            remainsadr:= indexadr;
          ELSE (* single replace *)
            MoveMem(indexadr + ADDRESS(srchlen), indexadr + ADDRESS(replen), 
              tmplong - i - LONG(srchlen));
          END; (* if all *)
          (* and insert replace string *)
          MoveMem(ADR(repstrg), indexadr, LONG(replen));
          INC(reps);
          saved:= FALSE;
          IF replen >= srchlen THEN
            INC(indexadr, replen);
          END; (* otherwise, allow continued replacement, such as to squeeze spaces *)
  
          IF allres <> 2 THEN (* is replace with query *)
            Lineptrs(Findline(i)); (* redo line pointers from current line *)
            Display(0, cfg.maxdispline);
          END;
          IF (i >= last) & (endf >= fileend) THEN
            FoundAlert;
            EXIT; (* search loop only *)
          END;
         END; (* replace routine *)
      ELSE (* no more found *)
        IF endf >= fileend THEN
          FoundAlert;
          Display(0, cfg.maxdispline);
        END;
        EXIT; (* search loop only *)
      END; (* if found *)
    END; (* search loop *)

    (* for 3.1H optimize multiple replace strategy *)
    (* move remains back to proper place in buffer *)
    IF allres = 2 THEN (* replace all *)
      MoveMem(remainsadr, saveadr, 
        LONGCARD(startadr + ADDRESS(buffsize) - remainsadr));
    END; (* if replace *)
  
    IF (NOT found) & (bigpart (* OR bigdev *) ) & (endf < fileend) THEN
      (* not found, ask extend *)
      (* need to do savecheck if disk sectors, already done by pagebigfile *)
      (* file bigger than buffer or disk or RAM *)
      IF firsttime THEN
        Showmouse; (* LineA show mouse *)
        extend:= FormAlert(1,"[2][  No more in buffer.|Continue saves changes.|(Esc/Undo Aborts during)][Continue|Cancel]");
        CODE(0A00AH);  (* LineA hide mouse *)
        firsttime:= FALSE;
      END; (* if firsttime *)
      IF extend = 1 THEN (* loop through DoFind(FALSE) until found or done *)
        (* 2.33 4/9/92 *)
        IF WantAbort(FALSE) THEN   (* esc or undo *)
          EXIT; (* findbig loop *)
        END; (* abort search *)
(***
        Kbshift(dummy);
        IF (3 IN BITSET(dummy)) THEN  (* Alt key pressed to abort *)
          EXIT;
        END; (* if abort search *)
***)  
        IF NOT PageBigFile(TRUE, FALSE) THEN (* forward, no ask *)
          EXIT; (* findbig loop *)
        END;
        notistrg:= 0C;
        InitMenu; (* to clear 'shifting' and show line number *)
      ELSE (* Canceled *)
        EXIT; (* findbig loop *)
      END; (* if extended search *)
    ELSE (* found or have end of file in buffer *)
      EXIT; (* findbig loop *)
    END; (* if not found and firsttime *)
  
    indexadr:= startadr + ADDRESS(i + 1); (* continue from next position *)
  END; (* findbig loop *)

  findstrg:= tmpstrg;

  IF allres = 2 THEN (* replace all w/o query *)
    Lineptrs(0); (* redo all line pointers *)
    (* 2.30 1/18/92... *)
    Display(0, cfg.maxdispline);
    Bottomstay;
    (*
    GrafMouse(GEMAESbase.Arrow, NIL); (* from busy bee *)
    *)

    (* 3.1H show # of replaces *)
    notistrg:= '-> 0000000';
    Cardtostrg(reps, cardstrg, FALSE, 7); (* reps in dec *)
    MoveMem(ADR(cardstrg), ADR(notistrg) + ADDRESS(3), 7); (* strg[3..9] *)
    Notice;
(*
    notistrg:= 0C;
*)
    InitMenu; (* gets rid of 'Working...' and does Notichar *)
  END; (* if replace all w/o query *)
  SetFoundPos(FALSE, TRUE); (* don't force to top *)
  FreeMemChk(findadr);
  IF found THEN (* 2.25 *)
    RETURN TRUE;
  END;
  RETURN FALSE;
END DoFind;

PROCEDURE ViewMem(): BOOLEAN;
(* Copy chunk of ram into buffer or buffer to ram.  Allows examining/editing memory *)
VAR (* srchlen: CARDINAL; *) (* now global *)
    viewres, findres, extend, blockres: INTEGER;
    getnew: BOOLEAN;
    indexadr: ADDRESS;
    memlong, copysize, tmplong: LONGCARD;
BEGIN
(****
(* 2.30 1/25/92 *)
(*dr+*)
  IF NOT cfg.hackable THEN
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(1,"[1][Not configured for full Hacking][ OK ]");
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN TRUE;
  END; (* if not hackable *)
(*dr-*)
****)
(**
  mresetptr^:= 0; (* reset flag *)
**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  viewres:= FormAlert(1,"[2][View/Copy Memory          |RAM => Buffer|Buffer => RAM][ R->B |B->R|Cancel]");
  CODE(0A00AH); (* lineA Hide mouse *)
  IF viewres = 3 THEN
    RETURN FALSE;
  ELSIF viewres = 1 THEN (* copy ram to buffer *)
    Showmouse; (* lineA Show mouse *)
    findres:= FormAlert(cfg.deffind,"[2][ Find string in RAM or | Pick block][ Find |Pick|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF findres = 3 THEN
      RETURN FALSE;
    END;
    cfg.deffind:= 2;
    IF findres = 1 THEN (* get string to search for *)
      (* below allow user to set start block for search *)
      cfg.deffind:= 1;
      getnew:= TRUE;
      srchlen:= GetFindStrg(getnew); (* enable hex/dec buttons *)
      IF (srchlen = 0) OR (srchlen = 0FFH) THEN
        RETURN FALSE;
      END;  (* zero length or cancelled *)
    END; (* if findmem *)
  END; (* if view mem *)
(*
  startf:= LONGCARD(memadr);
  endf:= startf;
*)
  memlong:= LONGCARD(memadr);
  maxblock:= SHORT(maxmem DIV 0400H); (* 400H=1K *)
  (* need to subtract 1 ?? *)
  BlockInit23; (* Sets default block dialog lines 2, 2A, and 3 *)
  IF viewres = 1 THEN
    InitObjStrg(BLCKTREE, BLOKTXT1, 'View/Copy RAM => Buffer');
    IF NOT GetBlockNum(memlong, tmplong, startramblk) THEN
      RETURN FALSE;
    END; (* if cancelled from dialog *)
    ClearAll(TRUE); (* newfile *)
  ELSE  (* viewres = 2, paste *)
    blockres:= 0;
    IF blocktype = 1 (* isblock *) THEN
      Showmouse; (* lineA Show mouse *)
      blockres:= FormAlert(1,'[2][Write Marked Block Only ?][Yes|No|Cancel]');
      CODE(0A00AH); (* lineA Hide mouse *)
      (* blockres: 1=block; 2=whole buffer *)
      IF blockres = 3 THEN (* cancel *)
        RETURN FALSE;
      END;
    END; (* if block *)
    copysize:= last; (* used below when copy to ram *)
    IF blockres = 1 THEN (* do block only *)
      copysize:= blockend - blockstart;
(***++***
      IF NOT GetBlockNum(memlong, tmplong) THEN
        RETURN FALSE;
      END; (* if cancelled from dialog *)
***+***)
    END; (* if blockres = 1 or 2 *)
    oldrepstrg[0]:= 0C; (* init *)
    InitObjStrg(TEXTTREE, TEXT1, 'Write From Buffer     ');
    InitObjStrg(TEXTTREE, TEXT2, 'To What RAM Address:');
    Cardtostrg(memlong, repstrg, TRUE, 6); (* show in hex *)
    InitObjStrg(TEXTTREE, TEXTSTRG, repstrg);
    getnew:= TRUE;
    findbtn:= HEXBTN; (* select hex as default button *)
    (* disable txt button *)
    treeptr^[TXTBTN].state:= INTEGER(BITSET(treeptr^[TXTBTN].state) + BITSET(8));
    j:= GetStrg(repstrg, getnew, TRUE); (* allow hex/dec buttons *)
    (* reenable txt button *)
    treeptr:= TreeAddr^[TEXTTREE];
    treeptr^[TXTBTN].state:= INTEGER(BITSET(treeptr^[TXTBTN].state) - BITSET(8));
    IF (j = 0) OR (j = 0FFH) THEN (* cancelled or zero length strg *)
      RETURN FALSE;
    END;
    memlong:= Strgtolongc(oldrepstrg, findbtn=HEXBTN); (* false = not ishex *)
(**
    memadr:= ADDRESS(Strgtolongc(oldrepstrg, findbtn=HEXBTN)); (* false = not ishex *)
**)
(*
    longptr:= ADR(repstrg);
    memlong:= longptr^; (* assumes numeric input *)
*)
(**+
    InitObjStrg(BLCKTREE, BLOKTXT1, 'Paste buffer => RAM');
    InitObjStrg(BLCKTREE, BLOKTXT2, 'Copy this many Bytes :  ');
    Cardtostrg(copysize, cardstrg, FALSE, 5); (* show in dec *)
    (**2.1** This needs to be 6 digits in dialog **)
    InitObjStrg(BLCKTREE, BLOKTX2A, cardstrg);
+**)
  END; (* if viewres *)
(****+
  IF NOT GetBlockNum(memlong, tmplong) THEN
    RETURN FALSE;
  END; (* if cancelled from dialog *)
+****)
(*test*)
  LOOP (* to allow extended search *)
(*test*)
    IF findres = 1 THEN (* set before go into super mode *)
      GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)
      (* but where does it come back out of busy bee? after calls to ViewMem. *)
    END;
    (* Into Supervisor mode for possible system addresses *)
    stack:= 0;
    Super(stack);
    IF viewres = 1 THEN (* to buffer *)
      (* if 2, to ram, could have changed memlong to non-sector boundary *)
      memadr:= ADDRESS(memlong);
    END;
    IF findres = 1 THEN (* search *)
      indexadr:= memadr; (* start searching from selected start block address *)
      IF LONGCARD(indexadr) >= maxmem THEN (* startadr + ADDRESS(last - 1) *)
        indexadr:= ADDRESS(maxmem - 1); (* startadr + ADDRESS(last - 2); *)
      END;
      Showmouse; (* lineA Show mouse NOTE: this & 2 following may crash in Super *)
      IF Find(maxmem - LONGCARD(indexadr),
              ADR(findstrg), srchlen, cfg.casesens, indexadr) THEN (* found it! *)
        (* load block of memory containing findstrg into buffer *)
        CODE(0A00AH); (* lineA Hide mouse *)
        blocknum:= SHORT(LONGCARD(indexadr) DIV 0400H); (* 1K *)
        IF (blocknum > 0) & (blocksize > 0800H) THEN (* assure at least 1K of text in buffer *)
          DEC(blocknum);
        END;
        startramblk (* oldblock *):= blocknum;
        memadr:= ADDRESS(LONG(blocknum) * 0400H);
        i:= LONGCARD(indexadr - memadr);
      ELSE (* not found *)
        CODE(0A00AH); (* lineA Hide mouse *)
        Super(stack); (* back out of Supervisor mode *)
        FoundAlert; (* but would be with busy bee here. *)
  (*test*
        found:= FALSE;
  *test*)
        RETURN FALSE;
      END; (* if found *)
    END; (* if was search *)
    IF viewres = 1 THEN (* copy block of ram into buffer *)
      copysize:= maxmem - LONGCARD(memadr);
      IF copysize > blocksize THEN
        copysize:= blocksize;
      END;
      MoveMem(memadr, startadr, copysize);
      bigpart:= FALSE; (* in case true was left over from a readfile *)
    ELSE (* viewres = 2, paste from buffer to ram *)
      indexadr:= startadr; (* default to whole buffer *)
(*
      copysize:= last;
*)
      IF blockres = 1 THEN (* just block *)
        indexadr:= startadr + ADDRESS(blockstart);
(*
        copysize:= blockend - blockstart;
*)
      END;
      MoveMem(indexadr, memadr, copysize); (* paste buffer to ram *)
    END; (* if viewres = 1 or 2 *)
  
    Super(stack); (* back out of Supervisor mode *)
    IF viewres = 1 THEN (* from ram to buffer *)
  (*
      cfg.autowrap:= FALSE;
  *)
      SetHack;
      last:= blocksize; (* 8192 for 8K *)
      blocktype:= 0; (* no block *)
      (* fix lnptrarray to show wrapW chars accross *)
      Lineptrs(0);
      IF findres = 2 THEN (* picked block. position at start of buffer *)
        MiniInit;
      ELSE  (* findres = 1, Find was done, needs cursor positioning *)
        (* mini version of SetFoundPos *)
        line:= Findline(i);
        curdispline:= 0;
        IF line > 0 THEN
          DEC(line); (* to put displine one below top line *)
          INC(curdispline);
        END;
        longptr:= lnptradr + ADDRESS(4*LONG(line+curdispline));
        linepos:= SHORT(i - longptr^);
        startcol:= 0; (** ?? **)
      END; (* if pick vs find was done *)
      Title1:= 'RAM:     K';
      Cardtostrg(LONG(startramblk), cardstrg, FALSE, 5); (* decimal *)
 (****** ADDRESS(5) or (4)??? *****   was blocknum ********)
      MoveMem(ADR(cardstrg), ADR(Title1)+ADDRESS(4), 5); (* insert address into strg *)
      Display(0, cfg.maxdispline);
      SetSlideSize;
      SetSlidePos;
    (*test*)
      IF (findres = 1) & (LONGCARD(indexadr) + LONG(srchlen) < maxmem) THEN
      (* is more to search *)
        InitMenu; (* to show new ram location & cursor offset *)
        CursorDraw; (* to show position of found string *)
        Showmouse; (* LineA show mouse *)
        extend:= FormAlert(1,"[2][  Found|Continue searching ?][Continue|Cancel]");
        CODE(0A00AH);  (* LineA hide mouse *)
        CursorDraw; (* turn off cursor *)
        IF extend = 2 THEN
          EXIT;
        END; (* if done searching ram *)
        memlong:= LONGCARD(indexadr) + 1;
      ELSE (* no more to search *)
        EXIT;
      END; (* if more to search *)
    ELSE (* viewres = 2, buffer -> ram *)
      EXIT;
    END; (* if view *)
  END; (* loop: extended ram find *)
(*test*)
(*dr*)
  RETURN TRUE;
END ViewMem;

(***)
PROCEDURE PageRam(forward: BOOLEAN);
VAR oldmemadr: ADDRESS;
BEGIN
  (* Into Supervisor mode for possible system addresses *)
  stack:= 0;
  Super(stack);
(********************)
  oldmemadr:= memadr;
  IF forward THEN
    memadr:= memadr + ADDRESS(blocksize - 0400H); (* 1K overlap *)
    IF memadr > ADDRESS(maxmem) THEN
      memadr:= ADDRESS(maxmem - blocksize);
    END;
    i:= i - LONGCARD(memadr - oldmemadr);
  ELSE (* backward *)
    IF memadr > ADDRESS(blocksize - 0400H) THEN
      memadr:= memadr - ADDRESS(blocksize - 0400H); (* 1K overlap *)
    ELSE
      memadr:= 0;
    END;
    i:= LONGCARD(oldmemadr - memadr);
  END; (* if forward *)
(********************)
  tmplong:= maxmem - LONGCARD(memadr);
  IF blocksize < tmplong THEN
    tmplong:= blocksize;
  END;
  MoveMem(memadr, startadr, tmplong);
(**
  startf:= LONGCARD(memadr); (* for viewmem dialog *)
**)
  startramblk:= SHORT(LONGCARD(memadr) DIV 0400H);
  Super(stack); (* back out of Supervisor mode *)
(*
  bigpart:= FALSE; (* in case true was left over from a readfile *)
*)
  last:= blocksize; (* 8192 for 10K buffer *)
  blocktype:= 0; (* no block *)
  Lineptrs(0);
(*
  MiniInit; (* sets i:= 0 among other things *)
*)
(*
  IF findres = 2 THEN (* picked block. position at start of buffer *)
    MiniInit;
  ELSE  (* findres = 1, Find was done, needs cursor positioning *)
*)
    (* mini version of SetFoundPos *)
    line:= Findline(i);
    curdispline:= 0;
    IF line > 0 THEN
      DEC(line); (* to put displine one below top line *)
      INC(curdispline);
    END;
    longptr:= lnptradr + ADDRESS(4*LONG(line+curdispline));
    linepos:= SHORT(i - longptr^);
    startcol:= 0;
(*
  END; (* if pick vs find was done *)
*)
(*
  Title1:= 'RAM:     K';
*)
  Cardtostrg(LONG(startramblk), cardstrg, FALSE, 5); (* decimal *)
  MoveMem(ADR(cardstrg), ADR(Title1)+ADDRESS(4), 5); (* insert address into strg *)
  Display(0, cfg.maxdispline);
  SetSlideSize;
  SetSlidePos;
(*
  IF (findres = 1) & (LONGCARD(indexadr) + LONG(srchlen) < maxmem) THEN
  (* is more to search *)
*)
    InitMenu; (* to show new ram location & cursor offset *)
(*
    IF extend = 2 THEN
      EXIT;
    END; (* if done searching ram *)
    startf:= LONGCARD(indexadr) + 1;
*)
(*
  ELSE (* no more to search *)
    EXIT;
  END; (* if more to search *)
*)
END PageRam;
(***)

(***************
MODULE StripCtl;
(**
  Movemem all to top of buffer,
  Set source ptr to buffsize-last;
  Set dest ptr to start of buffer (startadr);
 Start loop;
  Check char at source to see if is in unwanted set ( >127 ),
  If wanted (not >127 ) then copy char to dest (begin @ start of buffer);
    Keep count of stripped chars;
  Increment pointers to source and dest;
 Loop until done with last char at top of buffer;
**)
*******************)

PROCEDURE StripCtl;
VAR tmpstart, oldcount, stripcntall, fullcount: LONGCARD;

 PROCEDURE StripBuff;
 VAR stripcount: LONGCARD;
 BEGIN
  fullcount:= 0;
  stripcount:= 0;
  tmpstart:= buffsize - last;
  ptr1:= startadr + ADDRESS(tmpstart);
  ptr2:= startadr;
  MoveMem(ptr2, ptr1, last);
  LOOP
    IF fullcount >= last THEN
      EXIT;
    END;
    IF ((ptr1^ >= 40C) & (ptr1^ <= 176C)) OR (ptr1^ = 11C)
     OR (ptr1^ = 12C) OR (ptr1^ = 14C) OR (ptr1^ = 15C) THEN (* don't strip *)
      ptr2^:= ptr1^;
      INC(ptr2);
    ELSE
      INC(stripcount);
    END; (* if not ctl char *)
    INC(fullcount);
    INC(ptr1);
  END; (* loop *)
  DEC(last, stripcount);
  INC(stripcntall, stripcount);
 END StripBuff;

BEGIN (* main stripctl *)
  oldcount:= 0;
  stripcntall:= 0;
  LOOP (* start bigpart loop *)
    StripBuff;
    IF stripcntall > oldcount THEN
      saved:= FALSE;
      oldcount:= stripcntall;
    END;
    IF bigpart & (endf < fileend) THEN
      IF NOT PageBigFile(TRUE, FALSE) THEN (* forward, ask? *)
        EXIT;
      END;
    ELSE
      EXIT;
    END;
  END; (* bigpart loop *)
  Lineptrs(Findline(i)); (* redo line pointers from current line *)
(*
  Display(0, cfg.maxdispline);
*)
  ShowNew;
END StripCtl;


PROCEDURE SetHack;
BEGIN
  cfg.eollen:= 0; (* neglect any space for cr/lf in display *)
  savedeolchar:= cfg.eolchar;
  cfg.eolchar:= 0C;
  (* Set wrapW for cases when eollen = 0 *)
  wrapW:= 64;
  IF fullW < 64 * colW THEN (* lo resolution *)
    wrapW:= 32;
  END; (* if lo res *)
END SetHack;

PROCEDURE CloseOpen(close: BOOLEAN; VAR savesize: CARDINAL; VAR saveadr: ADDRESS);
(* routines called before/after Launch or showpic *)
BEGIN
  IF close THEN (* prepare to launch prg or showpic *)
    IF daccTitle[0] = 0C THEN (* is running as prg *)
      MenuBar(MenuTree, 0); (* erase menu bar at top of screen *)
    ELSE (* running as acc w/o its own menubar, so save menu bar *)
(*
      savesize:= Min(CARDINAL(offset)*byteslin, maxlines*4); (* To Save Menu Bar *)
      MoveMem(screenadr, lnptradr, LONG(savesize));
*)
      savesize:= CARDINAL(offset)*byteslin; (* To Save Menu Bar *)
      (* grab desired ram *)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
      PUSH(LONG(savesize)); (* to grab ram block for screen menu bar *)
      PUSH(048H); (* malloc code *)
      CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
      CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
      (* restore all necessary registers *)
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
      saveadr:= REGISTER(D0);
      IF LONGINT(saveadr) < 1 THEN
        Showmouse; (* lineA Show mouse *)
        dummy:= FormAlert(1,"[2][Error grabbing RAM for menu][OK]");
        CODE(0A00AH); (* lineA Hide mouse *)
      END; (* if error *)
      (* set saveadr to beginning of block *)
      MoveMem(screenadr, saveadr, LONG(savesize));
    END; (* if prg *)
    CloseWindow(Window1);
    Windfix;
    WindowUpdate(0);
    (* may not want for showpic *)
    (*
    Showmouse; (* lineA Show mouse, may not want for showpic *)
    *)
  ELSE (* recover from launching or showpic *)
    IF InitWindow() THEN (* starts with WindowUpdate(1), ends with (0) *)
      WindowUpdate(1);
      Windfix;
      (* force redraw of whole screen *)
      (* formfinish call must go before movemem for acc to redraw! *)
      update:= TRUE;
      FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, 0,0, fullW (* maxX *),maxY);
      IF daccTitle[0] = 0C THEN (* is running as prg *)
        MenuBar(MenuTree, 1); (* replace menu bar at top of screen *)
        (* may not want for showpic: *)
        (*
        CODE(0A00AH); (* lineA Hide mouse, assumes other prg showed it *)
        *)
      ELSE (* running as acc w/o its own menubar *)
(**
      WindowUpdate(0);
      MenuBar(MenuTree, 1); (* replace menu bar at top of screen *)
      MenuBar(MenuTree, 0); (* erase menu bar at top of screen *)
      WindowUpdate(1);
**)
        MoveMem(saveadr, screenadr, LONG(savesize));
        (** free ram grabbed for save screen **)
        (* save registers *)
        CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
        PUSH(saveadr); (* to free ram block at this address *)
        PUSH(049H); (* mfree code *)
        CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
        CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
        (* restore all necessary registers *)
        (* movem.l A1-A2/D1-D2,(SP)+ *)
        CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(*
        saveadr:= REGISTER(D0);
*)
  (*
        WindowUpdate(0);
        WindowUpdate(1);
  *)
(*
        Lineptrs(0); (* needs to be before Setfoundpos or Setslide's *)
*)
        SetSlideSize;
        SetSlidePos;
(*
        dummy:=  ApplInitialise(); (* failed attempt to make menus re-work *)
        ApplExit;
*)
      END; (* if prg or acc *)
      Windfix;
    END; (* if initwindow *)
  END; (* if close or open *)
END CloseOpen;

PROCEDURE HackToggle;
VAR j: CARDINAL;
    jlong, klong: LONGCARD;
    cancelled: BOOLEAN;
BEGIN
  int:= 1;  (* default to Text/Hack toggle *)
(*
  IF cfg.eollen = 0 THEN (* now in hack mode, so go into text mode *)
*)
  IF hexdisp THEN
    int:= 2; (* default to Text mode *)
  END; (* if in txt or hack mode *)
  cancelled:= FALSE;
(**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  result:= FormAlert(int,"[2][Toggle character  |display & conversions:][Text/Hack|Hex/Char|Cancel]");
  CODE(0A00AH); (* lineA Hide mouse *)
  IF result <> 3 THEN
    IF result = 1 THEN (* toggle Text/Hack mode *)
      IF cfg.eollen = 0 THEN (* now in hack mode, so go into text mode *)
        (* 3.2C *)
        IF bigpart & (startf > 0) THEN (* in latter block of bigfile *)
          Showmouse; (* lineA Show mouse *)
          dummy:= FormAlert(1,"[1][Line # will not be|correct until you move|to Top of file][OK|Cancel]");
          CODE(0A00AH); (* lineA Hide mouse *)
          IF dummy = 2 THEN
            cancelled:= TRUE;
          END;
        END; (* if bigfile past 1st block *)
        IF NOT cancelled THEN
          cfg.eollen:= 2;
          cfg.eolchar:= savedeolchar;
          wrapW:= cfg.textwrapW; (* displaylen *)
          ptr1:= startadr + ADDRESS(i);
          IF (ptr1^ = 12C) & (i < last) THEN (* need to move it to something besides LF *)
            INC(i);
          END;
        END; (* if not cancelled *)
      ELSE (* go into Hack mode *)
        SetHack;
        int:= 2;
        IF cfg.hackable THEN (* 3.2 start using hackable again as do-wrap-CR *)
          int:= 1;
        END;
        Showmouse; (* lineA Show mouse *)
        dummy:= FormAlert(int,"[2][Wrap at CR/LF's?][Yes|No]");
        CODE(0A00AH); (* lineA Hide mouse *)
        cfg.hackable:= TRUE;
        IF dummy = 2 THEN
          cfg.hackable:= FALSE;
        END;
      END; (* if go into Text or Hack mode *)
    ELSE (* will toggle Hex/Char display *)
(**
  Showmouse; (* lineA Show mouse *)
  result:= FormAlert(int,"[2][Convert From: ][CR|CR/LF|LF]");
  result:= FormAlert(int,"[2][Convert To: ][CR|CR/LF|nothing]");
  CODE(0A00AH); (* lineA Hide mouse *)
**)

      cancelled:= FALSE;
      (* int is left over from above Alert, 2=hexdisp *)
      Showmouse; (* lineA Show mouse *)
      result:= FormAlert(int,"[2][Convert Buffer|(not just display!)][To Hex|To Char|Cancel]");
      CODE(0A00AH); (* lineA Hide mouse *)
      IF result = 3 THEN
        cancelled:= TRUE;
      ELSIF result = 2 THEN (* convert from hex to char *)
        ptr1:= startadr;
        ptr2:= startadr;
        jlong:= 0;
        klong:= 0;
        cardstrg[2]:= 0C;
        WHILE klong < last DO
          cardstrg[0]:= ptr2^;
          INC(ptr2);
          cardstrg[1]:= ptr2^;
          ptr1^:= CHR(SHORT(Strgtolongc(cardstrg, TRUE))); (* ishex *)
          INC(ptr1);
          INC(ptr2);
          INC(jlong);
          INC(klong,2);
        END; (* while converting to hex *)
        last:= jlong;
        i:= i DIV 2;
        hexdisp:= FALSE;
      ELSIF result = 1 THEN (* convert from char to hex display & force hack mode *)
        (* cvt to Hex *)
        IF last + last >= buffsize THEN (* not enough room *)
          Showmouse; (* lineA Show mouse *)
          result:= FormAlert(1,"[1][Not Enough Room...|OK to DESTROY 2nd|Half of Buffer??][No!!|OK]");
          CODE(0A00AH); (* lineA Hide mouse *)
          IF result = 1 THEN
            cancelled:= TRUE;
          ELSE
            last:= buffsize DIV 2; (* lose 2nd half of buffer! *)
          END; (* if cancelled *)
        END; (* if cancelchk *)
        IF NOT cancelled THEN
          ptr1:= startadr + ADDRESS(last - 1);
          ptr2:= startadr + ADDRESS(last + last - 1);
          tmplong:= 0;
          WHILE tmplong < last DO
            Cardtostrg(LONG(ORD(ptr1^)), cardstrg, TRUE, 2); (* ishex *)
            ptr2^:= cardstrg[1];
            DEC(ptr2);
            ptr2^:= cardstrg[0];
            DEC(ptr1);
            DEC(ptr2);
            INC(tmplong);
          END; (* while converting to hex *)
          last:= last + last;
          i:= i + i;
          hexdisp:= TRUE;
        END; (* if is room for full conversion *)
        SetHack;
      END; (* if go to hex or to char display *)
    END; (* if toggle txt/hack or hex/char *)

    IF NOT cancelled THEN
      Lineptrs(0);
      Display(0, cfg.maxdispline);
      SetFoundPos(FALSE, TRUE); (* don't force to top of window *)
      SetSlideSize;
      SetSlidePos;
      NotiChar;
    END; (* if not cancel #2 *)
  END; (* if not cancel #1 *)
END HackToggle;


PROCEDURE DoMargins(whichmargin: INTEGER): BOOLEAN;
VAR len, card: CARDINAL;
    getnew: BOOLEAN;
    strg: Substrg;
BEGIN
  IF whichmargin = 0 THEN (* need to ask which to set *)
(**
    mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
    Showmouse; (* lineA Show mouse *)
    whichmargin:= FormAlert(2,"[2][Set Left Print Margin or|Right Wrap Column ?][Left|Right|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF whichmargin = 3 THEN (* cancel *)
      RETURN FALSE;
    END;
  END; (* if need to ask *)
  strg:= 0C; (* '';*) (* init *)
  IF whichmargin = 1 THEN (* set left print margin *)
    Cardtostrg(LONG(cfg.printmargin), strg, FALSE, 3); (* decimal *)
    InitObjStrg(TEXTTREE, TEXT1, 'Set Left Print Margin');
    InitObjStrg(TEXTTREE, TEXT2, '  ');
  ELSE (* whichmargin = 2,  set right wrap column *)
    Cardtostrg(LONG(cfg.textwrapW), strg, FALSE, 5); (* decimal *)
    InitObjStrg(TEXTTREE, TEXT1, 'Set Right Wrap Column');
    InitObjStrg(TEXTTREE, TEXT2, '  ( minimum = 20 )');
  END;
  getnew:= FALSE;
  InitObjStrg(TEXTTREE, TEXTSTRG, strg);
  len:= GetStrg(strg, getnew, FALSE (*, dummy *) ); (* disable hex/dec *)
  IF (len = 0) OR (len = 0FFH) THEN (* cancelled or zero length strg *)
    RETURN FALSE;
  END;
  card:= SHORT(Strgtolongc(strg, FALSE)); (* TRUE=ishex *)
  IF whichmargin = 1 THEN (* set new left print margin *)
    cfg.printmargin:= card;
  ELSE (* IF cfg.eollen > 0 THEN *)(* whichmargin = 2, set right wrap margin *)
    cfg.textwrapW:= Max(20, card);
    wrapW:= cfg.textwrapW;
  END;
  RETURN TRUE;
END DoMargins;

PROCEDURE TabSet;
(* just sets number of spaces between tabstops *)
VAR strg: Substrg;
    len: CARDINAL;
    getnew: BOOLEAN;
BEGIN
  Cardtostrg(LONG(cfg.tabspaces), strg, FALSE, 3); (* decimal *)
  InitObjStrg(TEXTTREE, TEXT1, 'Spaces Between Tabstops');
  InitObjStrg(TEXTTREE, TEXT2, '( Same for all, min=2 )');
  getnew:= FALSE;
  InitObjStrg(TEXTTREE, TEXTSTRG, strg);
  (* default to decimal *)
  len:= GetStrg(strg, getnew, FALSE (*, dummy *) ); (* disable hex/dec *)
  IF (len <> 0) & (len <> 0FFH) THEN (* not cancelled or zero length strg *)
    cfg.tabspaces:= SHORT(Strgtolongc(strg, FALSE)); (* ok=ishex *)
    (* 2.25 *)
    IF cfg.tabspaces < 2 THEN
      cfg.tabspaces:= 2;
    END;
  END; (* if valid string *)
END TabSet;

PROCEDURE Printinit(): BOOLEAN;
VAR whichset: INTEGER;
    len (*, card *): CARDINAL;
    getnew: BOOLEAN;
    strg: Substrg;
BEGIN
(**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  whichset:= FormAlert(1,"[2][Set Printer Init or|Ending String ?][Init|End|Cancel]");
  CODE(0A00AH); (* lineA Hide mouse *)
  IF whichset = 3 THEN (* cancel *)
    RETURN FALSE;
  END;
  strg:= 0C; (* init *)
  IF whichset = 1 THEN (* set printer init strg *)
(*
    Cardtostrg(LONG(cfg.printinit), strg, FALSE, 3); (* decimal *)
*)
    strg:= cfg.printinit;
    InitObjStrg(TEXTTREE, TEXT1, '  Set Print Init String');
    InitObjStrg(TEXTTREE, TEXT2, 'Esc=27 see printer manual');
  ELSE (* whichset = 2, set print end strg *)
(*
    Cardtostrg(LONG(cfg.printend), strg, FALSE, 5); (* decimal *)
*)
    strg:= cfg.printend;
    InitObjStrg(TEXTTREE, TEXT1, '  Set Print End String');
    InitObjStrg(TEXTTREE, TEXT2, '(DEC: FF=12  CR/LF=13,10)');
  END;
  getnew:= FALSE;
  InitObjStrg(TEXTTREE, TEXTSTRG, strg);
  findbtn:= TXTBTN; (* findbtn:= DECBTN; *)
  len:= GetStrg(strg, getnew, TRUE); (* hex/dec ok *)
  (* 3.13 allow zero length strg = no init strg *)
  IF (* (len = 0) OR *) (len = 0FFH) THEN (* cancelled or zero length strg *)
    RETURN FALSE;
  END;
(*
  card:= SHORT(Strgtolongc(strg, FALSE)); (* TRUE=ishex *)
*)
  IF whichset = 1 THEN (* set new left print margin *)
    cfg.printinit:= strg;
  ELSE (* whichset = 2, set print end strg *)
    cfg.printend:= strg;
  END;
  RETURN TRUE;
END Printinit;

PROCEDURE DateCfg;
VAR tmpint: INTEGER;
BEGIN
  tmpint:= ORD(cfg.eurodate) + 1; (* US=0, euro=1, YYMMDD=2 *)
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(tmpint,"[2][Preferred Date Format:|1) 12/25/95|2) 25 Dec 1995|3) 951225][1|2|3]");
  CODE(0A00AH); (* lineA Hide mouse *)
  cfg.eurodate:= CHR(dummy - 1);
END DateCfg;

PROCEDURE InsertMacro(whichmacro: CARDINAL);
VAR macrolen: CARDINAL;
BEGIN
  (* find macro length *)
  macrolen:= ORD(cfg.macro[whichmacro][macrosize]);
  IF macrolen = 0 THEN (* either zero length or old null termed macro *)
(*
    macrolen:= 0;
*)
    WHILE (macrolen <= macrosize) & (cfg.macro[whichmacro][macrolen] <> 0C) DO
      INC(macrolen);
    END; (* while inserting macro *)
  END; (* check for old macro *)
  IF macrolen > 0 THEN
    (* check if is enough room for inserting macro *)
    IF last + LONG(macrolen) > buffsize THEN (* can't fit any more in buffer *)
      FullAlert;
    ELSE (* is room for insert *)
      (* make room for macro by shifting all following text *)
      MoveMem(startadr + ADDRESS(i), startadr + ADDRESS(i + LONG(macrolen)), last - i);
      INC(last, macrolen);
      (* and copy macro into that space *)
      MoveMem(ADR(cfg.macro[whichmacro]), startadr + ADDRESS(i), LONG(macrolen));
      Lineptrs(line + curdispline); (* to handle any embedded cr/lf's in macro *)
      Display(curdispline, cfg.maxdispline);
      RuinBlock(FALSE); (* unmark block if inserting before marked blk *)
      (* leaves cursor at start of macro *)
      (* NotiChar; *)
      SetSlideSize;
      SetSlidePos;
      INC(i, macrolen);
      SetFoundPos(FALSE, TRUE);
    END; (* if is room for insert *)
  ELSE (* is nothing in that macro *)
    notistrg:= 'No Macro  ';
    Notice; (* ('No Macro! '); *)
  END; (* if is a macro to paste *)
END InsertMacro;


PROCEDURE ShowMacros; (* (startline: CARDINAL); *)
VAR j: CARDINAL;
    mX, mY: INTEGER;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,"[1][Macros Follow.|Click one or hit Function Key.|All else quits][ OK ]");
  CODE(0A00AH); (* lineA Hide mouse *)
  ClearWindow(Window1);
  SetClipFill(workX, workY, workW, workH, TRUE);
  SetClipping(VDIHandle, 1, clipxy2);
  FOR j:= 1 TO 10 DO (* show macros, truncates if < 80 col window *)
    CursorPos(j - 1, leftedge);
    StringZap(cfg.macro[j]);
  END; (* for each macro *)
  SetClipFill(1,1,fullW, maxY, TRUE);
  SetClipping(VDIHandle, 1, clipxy2);

  notistrg:= ' Macros:  ';
  Notice;
(**
  Wait; (* also handles turning mouse on/off, & returns kret *)
**)
(*********)
  WindowUpdate(3); (* take control of mouse from GEM *)
  Showmouse;  (* LineA show mouse *)
(*
   For macro display/pick, try wait left up, then left down,
   and use click Y to pick macro to insert.  Allow escape.
*)
  Wait(result, mX, mY, kret);
(*
  Waitup;
*)
(***
  result:= EventMultiple((* GEMAESbase.KeyboardEvent + *) GEMAESbase.ButtonEvent,
                         1,1,0, (* 3rd 0 means wait for buttons up *)
                         0,0,0,0,0, 0,0,0,0,0,
                         ADR(pipeBuff), 0,0,
                         dummy,dummy,dummy,dummy, dummy, dummy);
***)
(**
  result:= EventMultiple(GEMAESbase.KeyboardEvent + GEMAESbase.ButtonEvent,
                         1,1,1, (* 3rd 1 means wait for left button down *)
                         0,0,0,0,0, 0,0,0,0,0,
                         ADR(pipeBuff), 0,0,
                         mX, mY, dummy,dummy, kret, dummy);

**)
  CODE(0A00AH);  (* LineA hide mouse *)
  WindowUpdate(2); (* give back control of mouse to GEM *)
(**)
  Display(0, cfg.maxdispline);
  notistrg:= 0C;
  InitMenu;
  j:= 0;
  IF (result = GEMAESbase.KeyboardEvent) &
     (kret >= 03B00H) & (kret <= 04400H) THEN       (* Funckey *)
    j:= (CARDINAL(kret) - 03A00H) DIV 0100H; (* gives 1..10 *)
  ELSIF (result = GEMAESbase.ButtonEvent) &
     (mY > workY) & (mY < workY + workH) &
     (mX > workX) & (mX < workX + workW) THEN
    inout:= 0;
    j:= Finddispline(mY, FALSE) + 1; (* F = don't limit to buffer lines *)
  END;
  IF (j >= 1) & (j <= 10) THEN 
    InsertMacro(j);
  END;
END ShowMacros;

PROCEDURE NewConfig;
VAR j: CARDINAL;
    olddate: CHAR;
    tmpsize, newmaxbuff, newminsys: LONGCARD;
    tmpint, x,y,w,h, result, buffresult, savefont: INTEGER;
   (* use local since treeptr is needed to set buffer, etc *)
    treeptr2: POINTER TO ARRAY[0..25] OF GEMAESbase.Object;
    temppath, temppath2: Pathtype;
BEGIN
  (* first show current configuration, then ask if want to save it. *)
  (* Show as with help screens... *)

  ClearWindow(Window1);
  notistrg:= ' Config:  ';
  Notice;
(*
  CursorPos(0, lm);
  StringZap('File: ');
  StringZap(cfg.fsel0); (* may want to make it Title1 *)
*)
  CursorPos(0, leftedge);
  StringZap('Path: ');
  StringZap(cfg.oldpath);

  CursorPos(1, leftedge);
  StringZap('Buffer Size: ');
  Cardtostrg(buffsize, cardstrg, FALSE, 7);
  StringZap(cardstrg);
  StringZap(',  Used: ');
  Cardtostrg(last, cardstrg, FALSE, 7);
  StringZap(cardstrg);

  CursorPos(2, leftedge);
  StringZap('File Size: ');
  tmplong:= fileend;
  IF last > lasti THEN
    INC(tmplong, last - lasti);
  ELSE
    DEC(tmplong, lasti - last);
  END;
  Cardtostrg(tmplong, cardstrg, FALSE, 7);
  StringZap(cardstrg);

  CursorPos(3, leftedge);
  StringZap('Offsets: buffer:');
  Cardtostrg(startf DIV 0400H, cardstrg, FALSE, 5);
  StringZap(cardstrg);
  Conzap('K');
  StringZap(' cursor:');
  Cardtostrg(i, cardstrg, FALSE, 7);
  StringZap(cardstrg);

  CursorPos(4, leftedge);
  StringZap('Free RAM: ');
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  PUSH(LONGINT(-0001H)); (* to get largest free ram block *)
  PUSH(048H); (* get free ram code *)
  CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  tmplong:= LONGCARD(REGISTER(D0)) DIV 0400H; (* gives K *)
  Cardtostrg(tmplong, cardstrg, FALSE, 5); (* decimal *)
  StringZap(cardstrg);
  Conzap('K');
(**
  StringZap(',  Mode: ');
  IF cfg.eollen > 0 THEN
    StringZap('TEXT/hack');
  ELSE
    StringZap('text/HACK');
  END;
**)
  StringZap(', Save: ');
  IF cfg.defoverwrite = 1 THEN
    StringZap('OVER/append');
  ELSE (* = 2, append *)
    StringZap('over/APPEND');
  END;

(**
  StringZap('Default File Save: ');
  IF cfg.defoverwrite = 1 THEN
    StringZap('OVERWRITE/append');
  ELSE (* = 2, append *)
    StringZap('overwrite/APPEND');
  END;
**)
  CursorPos(5, leftedge);
  StringZap('Case Sensitive Search: ');
  IF cfg.casesens THEN
    StringZap('Yes');
  ELSE
    StringZap('No');
  END;

  CursorPos(6, leftedge);
  StringZap('Clipboard path (set with shft-alt-C): ');

  CursorPos(7, leftedge);
  ScrapRead(ADR(temppath)); (* use path as temp holder *)
  StringZap(temppath);
  IF temppath[0] = 0C THEN
    StringZap(' * no clipboard path is set *');
  END;

  CursorPos(8, leftedge);
  StringZap('[ Hit Key or L Button;  Esc exits ]');

  Wait(dummy,dummy,dummy, kret); (* also handles turning mouse on/off *)
(*******
  ClearWindow(Window1);
******)
  IF kret <> 0011BH THEN (* not escaped from 1st cfg display *)
    olddate:= cfg.eurodate; (* 3.2 *)
    newbuffsize:= accbuffsize;
    newmaxbuff:= cfg.maxbuff;
    newminsys:= cfg.minsys;
    savefont:= cfg.charht; (* save for cancel *)
    temppath2:= temppath;
    FOR j:= INSERTBT TO CFG1CANC DO
      DeselectObj(CFG1, j, FALSE); (* true means select it *)
    END; (* for deselect all *)      
    IF cfg.autoload THEN
      DeselectObj(CFG1, AUTOLOAD, TRUE); (* true means select it *)
    END;
(***
    IF cfg.printsetup THEN
      DeselectObj(CFG1, PRNTINIT, TRUE);
    END;
***)
    IF cfg.dobak THEN
      DeselectObj(CFG1, SAVEWBAK, TRUE);
    END;
(*
    IF cfg.hackable THEN
      DeselectObj(CFG1, HACKABLE, TRUE);
    END;
*)
    IF cfg.insertmode THEN
      DeselectObj(CFG1, INSERTBT, TRUE);
    END;
    IF cfg.eolchar <> 0C THEN
      DeselectObj(CFG1, SHOWCR, TRUE);
    END;

(***)
    (* 2.30 1/25/92 *)
    IF cfg.autowrap THEN
      DeselectObj(CFG1, AUTOWRAP, TRUE);
    END;
(**
    IF NOT cfg.eurodate THEN
      DeselectObj(CFG1, USDATE, TRUE);
    END;
**)
    IF cfg.autoindent THEN
      DeselectObj(CFG1, INDENT, TRUE);
    END;
    IF cfg.hexdisp THEN
      DeselectObj(CFG1, HEXHACK, TRUE);
    END;
(***)
(*
    ResourceGetAddr(GEMAESbase.RTree, CFG1, dTree);
  treeptr:= TreeAddr^[tree];
  BITSET(treeptr^[obindex].state);
*)
    treeptr2:= TreeAddr^[CFG1]; (* address *)
    FormCenter(treeptr2, x,y,w,h);
    FormDialogue(GEMAESbase.FormStart, 0,0,0,0, x,y,w,h);
    (* MINUS space for OS, EdHak, etc. *)
    (* also minus space for lnptrarray + paste buffer !! so take 2/3 *)
(*
    maxblock:= SHORT(maxmem DIV 0400H - 100); (* 400H=1K *)
*)
    tmplong:= maxmem - membot - 045000H; (* TPA - 100K-screen-edhak code size *)
    (* 100K for EdHak, 32K for screen, about 150K for who knows what *)
    IF tmplong < 0180000H THEN
      maxblock:= SHORT(tmplong DIV 0C00H * 2); (* 2/3 of available space, 400H=1K *)
    ELSE (* will be truncation of maxlines for word length *)
      maxblock:= SHORT(tmplong DIV 0400H - 512);
      (* 512=128*4 for max lineptrarray + pastebuffer *)
    END; (* if is maxline truncation *)
(*
    j (* oldblock *) := SHORT(buffsize DIV 0400H); (* current size in K *)
*)
    REPEAT
(*
      DeselectObj(CFG1, BUFFSIZE, FALSE);
*)
      ObjectDraw(treeptr2, 0, 2, x,y,w,h);
(**
      mresetptr^:= 0; (* reset flag *)
**
      mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
      Showmouse; (* lineA Show mouse *)
      result:= FormDo(treeptr2, 0); (* 0, Not -1, = no editable objects *)
      CODE(0A00AH); (* lineA Hide mouse *)
      IF result = BUFFSIZE THEN (* do buffer size show/change *)
        tmpint:= 1; (* acc *)
        IF daccTitle[0] = 0C THEN (* prg *)
          tmpint:= 2; (* prg default *)
        END; (* if acc *)
        Showmouse; (* lineA Show mouse *)
        buffresult:= FormAlert(tmpint,"[1][ACC buffer size or|Max PRG or Min System][ACC|PRG|System]");
        CODE(0A00AH); (* lineA Hide mouse *)
        InitObjStrg(BLCKTREE, BLOKTX2A, '  ');
        InitObjStrg(BLCKTREE, BLOKTXT3, '[gets saved in cfg file]');
        IF buffresult = 1 THEN
          InitObjStrg(BLCKTREE, BLOKTXT1, 'New ACC Buffer Size in K');
          InitObjStrg(BLCKTREE, BLOKTXT2, '      ( Min = 4K )');
          InitObjStrg(BLCKTREE, BLOKTXT3, 'Must Save and then run/reboot');
          j:= SHORT(newbuffsize DIV 0400H); (* current size in K *)
        ELSIF buffresult = 2 THEN
          InitObjStrg(BLCKTREE, BLOKTXT1, 'Max PRG Buffer Size in K');
          InitObjStrg(BLCKTREE, BLOKTXT2, '(Limited by Min. System)');
          j:= SHORT(newmaxbuff DIV 0400H); (* current size in K *)
        ELSE (* buffresult=3 *)
          InitObjStrg(BLCKTREE, BLOKTXT1, 'Minimum Remaining System');
          InitObjStrg(BLCKTREE, BLOKTXT2, ' RAM in K ( Min = 40K )');
          j:= SHORT(newminsys DIV 0400H); (* current size in K *)
        END; (* if acc/prg/sys *)

        IF GetBlockNum(tmpsize, tmplong, j) THEN
          IF buffresult < 3 THEN (* acc or prg buff size *)
            IF tmpsize < 01000H THEN
              tmpsize:= 01000H; (* 4k minimum *)
            END;
            IF buffresult = 1 THEN (* ACC *)
              newbuffsize:= tmpsize;
            ELSE (* PRG *)
              newmaxbuff:= tmpsize;
            END;
          ELSE (* system minimum *)
            newminsys:= tmpsize;
            IF newminsys < 40 * 1024 THEN
              newminsys:= 40 * 1024;
            END;
          END;
(**
        ELSE (* canceled *)
          newbuffsize:= accbuffsize; (* in case couldn't find Diary file *)
**)
        END; (* if GetBlockNum *)
      ELSIF result = MARGINSB THEN
        ok:= DoMargins(0); (* zero means ask which margin to set *)
      ELSIF result = TABS THEN
        TabSet;
      ELSIF result = SETFONT THEN
        ChooseFont; (* sets cfg.charht & displays *)
      ELSIF result = CLIPBRD THEN
        ok:= Setclipbrd(temppath);
(**)
      ELSIF result = PRNTINIT THEN
        ok:= Printinit();
      ELSIF result = USDATE THEN (* 3.2 *)
        DateCfg;
(**)
      END; (* if set newbuffsize, margins or tabs *)
      DeselectObj(CFG1, result, FALSE); (* resets treeptr to CFG1 *)
    UNTIL (result = CFG1SAVE) OR (result = CFG1OK) OR (result = CFG1CANC);
    update:= TRUE;
    FormDialogue(GEMAESbase.FormFinish, 0,0,0,0, x,y,w,h);

    IF result <> CFG1CANC THEN (* keep selected changes *)
      cfg.autoload:= FALSE;
      IF Select IN BITSET(treeptr2^[AUTOLOAD].state) THEN
(*
      IF Select IN GetObjectState(CFG1, AUTOLOAD) THEN
*)
        cfg.autoload:= TRUE;
      END;
(**
      cfg.printsetup:= FALSE;
      IF Select IN BITSET(treeptr2^[PRNTINIT].state) THEN
        cfg.printsetup:= TRUE;
      END;
**)
      cfg.dobak:= FALSE;
      IF Select IN BITSET(treeptr2^[SAVEWBAK].state) THEN
        cfg.dobak:= TRUE;
      END;
(*
      cfg.hackable:= FALSE;
      IF Select IN BITSET(treeptr2^[HACKABLE].state) THEN
        cfg.hackable:= TRUE;
      END;
*)
      cfg.insertmode:= FALSE;
      IF Select IN BITSET(treeptr2^[INSERTBT].state) THEN
        cfg.insertmode:= TRUE;
      END;

      cfg.eolchar:= 0C;
      IF Select IN BITSET(treeptr2^[SHOWCR].state) THEN
        cfg.eolchar:= 15C; (* 'cr' *)
      END;
(***)
(**
      cfg.eurodate:= TRUE;
      IF Select IN BITSET(treeptr2^[USDATE].state) THEN
        cfg.eurodate:= FALSE;
      END;
**)
      cfg.autowrap:= FALSE;
      IF Select IN BITSET(treeptr2^[AUTOWRAP].state) THEN
        cfg.autowrap:= TRUE;
      END;

      cfg.hexdisp:= FALSE;
      IF Select IN BITSET(treeptr2^[HEXHACK].state) THEN
        cfg.hexdisp:= TRUE;
      END;

      cfg.autoindent:= FALSE;
      IF Select IN BITSET(treeptr2^[INDENT].state) THEN
        cfg.autoindent:= TRUE;
      END;
(** 3.02 **
      IF savefont <> cfg.charht THEN
        EndFont;
      END;
**)
      IF (daccTitle[0] = 0C) (* prg *) & 
      ((newmaxbuff <> cfg.maxbuff) OR (newminsys <> cfg.minsys)) THEN
        Showmouse; (* lineA Show mouse *)
        dummy:= FormAlert(1,"[1][Set PRG/System|Buffer Size & |ReLoad File NOW?][ OK | Not Now]");
        CODE(0A00AH); (* lineA Hide mouse *)
        IF dummy = 1 THEN (* resize buffer *)
          IF SaveCheck(FALSE, TRUE) THEN (* no askbig, yes asksave *)
            (* deallocate current prg buffer if any *)
            (* save registers *)
            CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
            PUSH(startadr); (* to grab ram block for buffer+lineptrs+pastebuff *)
            PUSH(049H); (* mfree code *)
            CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
            CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
            (* restore all necessary registers *)
            (* movem.l A1-A2/D1-D2,(SP)+ *)
            CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
            cfg.maxbuff:= newmaxbuff;
            cfg.minsys:= newminsys;
            InitBuffSize;
            (* loadfile *)
            IF last > 0 THEN
              ok:= LoadFile(fsel, TRUE); (* display right now? *)
              SetSlideSize;
              SetSlidePos;
            END; (* if anything in buffer to reload *)
          END;
        END; (* if resize buffer now *)
      END; (* if change prg buff *)
(***)
      IF result = CFG1SAVE THEN
  (*demo+*
        PleaseBuy;
  *demo-*)
        cfg.maxbuff:= newmaxbuff;
        cfg.minsys:= newminsys;
        notistrg:= 'Saving CFG';
        Notice;
        IF WriteConfig() THEN
          accbuffsize:= newbuffsize;
          notistrg:= 'CFG Saved ';
        ELSE
          notistrg:= 'Not Saved ';
        END;
        Notice;
  (*demo*)
      END; (* if save config changes to disk *)
    ELSE (* canceled but can't now undo printinit *)
      cfg.eurodate:= olddate;
      cfg.charht:= savefont;
      EndFont; (* 3.02 *)
      ScrapWrite(ADR(temppath2)); (* resets AES scrap path *)
    END; (* if not cancel from config *)
  END; (* if not esc from showmacros *)
(*
  inout:= 0; (* just to get rid of esc keycode for following event *)
*)
(*
  WindowUpdate(0);
*)
  Display(0, cfg.maxdispline);
(*
  WindowUpdate(1);
*)
  notistrg:= 0C;
  InitMenu;
END NewConfig;
(*ds*)

(*ex*
(* 32 bit *)
PROCEDURE MailPrint;
VAR headlen, j,k,tmpcard: CARDINAL; (* end of print area *)
    longptr2: POINTER TO LONGCARD;

 PROCEDURE PrintBlock(start, end: LONGCARD);
 BEGIN
   ptr1:= startadr + ADDRESS(start);
   WHILE start < end DO
     Bconout(ptr1^, outdev); (* charray[j]); *)
     INC(ptr1);
     INC(start);
   END;
 END PrintBlock;

BEGIN
  headlen:= 8; (* # of header lines *)
(*
  formlen:=  18; (* 6 lines/inch, 3" top to top *)
  endmail:= blockend;
  k:= headlen;
*)
  k:= Findline(blockstart); (* start searching for addresses at start of block *)
  LOOP (* main loop *)
    (* print header *)
    longptr2:= lnptradr + ADDRESS(4*headlen);
    (* now print next address entry, first find start *)
    j:= k; (* start looking at end of prev block *)
    LOOP
      longptr:= lnptradr + ADDRESS(4*LONG(j));
      ptr1:= startadr + ADDRESS(longptr^);
      IF (ptr1^ = 15C) OR (longptr^ >= blockend) THEN
        EXIT; (* findstart loop *)
      END;
      INC(j);
    END; (* findstart loop *)
    IF longptr^ >= blockend THEN
      EXIT; (* main loop *)
    END;
    INC(j, 2); (* skip blank line & # line *)
    (* cardptr:= lnptradr + ADDRESS(j+j); *)
    INC(longptr, 8); (* 2 lines *)
    tmplong:= longptr^; (* prtstart *)
    (* now find end *)
    k:= j+1;
    LOOP
      longptr:= lnptradr + ADDRESS(4*LONG(k));
      ptr1:= startadr + ADDRESS(longptr^);
      IF (ptr1^ = '(') OR (ptr1^ = 15C) THEN
        EXIT;
      END;
      INC(k);
    END; (* findend loop *)
    PrintBlock(0, longptr2^); (* prints header *)
    PrintBlock(tmplong, longptr^);
 (*
    FOR tmpcard:= 0 TO 25 DO
      Bconout('*', outdev);
    END;
 *)
    Bconout(15C, outdev);
    Bconout(12C, outdev);
    Bconout(14C, outdev); (* FormFeed *)
(*
    tmpcard:= k - j;
    WHILE tmpcard < formlen DO
      Bconout(15C, outdev);
      Bconout(12C, outdev);
      INC(tmpcard);
    END; (* while formfeeding *)
*)
  END; (* main loop *)
END MailPrint;
*ex*)

(************************  Key Decoding  *************************)

PROCEDURE HelpCntrl(kreturn: CARDINAL);
(* zero low byte, kreturn > 05D00H *)
VAR tmpln: CARDINAL;
    int: INTEGER;
BEGIN
  tmpln:= line + curdispline;
  IF kreturn = 06200H THEN DoHelp;                          (* HELP key *)
(*ds*)
  ELSIF kreturn = 06100H THEN;                                 (* UNDO  *)
    Pasteblock;
(*ds*)
  ELSIF (kreturn >= 07800H) & (kreturn <= 07900H) THEN (* goto bookmarks *)
    i:= mark[(kreturn - 07800H) DIV 0100H]; (* easily expandable to more marks *)
    SetFoundPos(FALSE, TRUE);
  ELSE                                                    (* Arrow keys *)
   (* 32 bit *)
    longptr:= lnptradr + ADDRESS(4*LONG(tmpln));

    ptr1:= startadr + ADDRESS(i); (* for word left, right *)
    Kbshift(int); (* SampleKeyboard(VDIHandle, int); *)
    IF kreturn = 07300H THEN                          (* Cntl-Leftarrow *)
      (* Kbshift(int); *)(* SampleKeyboard(VDIHandle, int); *)
      IF (0 IN BITSET(int)) OR (1 IN BITSET(int)) THEN (* Shft-Cntl-Leftarrow *)
        linepos:= 0;
(**
        i:= cardptr^ + startcol;
**)
        i:= longptr^ + LONG(startcol);
        CursorPos(curdispline, leftedge);
      ELSE (* just cntl-leftarrow *)
        (* cursor to start of prior word *)
        DEC(ptr1); (* to check character prior to cursor *)
        WHILE ((ptr1^ = 40C) OR (ptr1^ = 12C)) & (i > 0) DO (* stop before 1st space *)
          Leftarrow;
          ptr1:= startadr + ADDRESS(i);
          IF i > 0 THEN
            DEC(ptr1);
          END;
        END; (* while *)
        WHILE (ptr1^ <> 40C) & (ptr1^ <> 12C) & (i > 0) DO (* stop before 1st space *)
          Leftarrow;
          ptr1:= startadr + ADDRESS(i);
          IF i > 0 THEN
            DEC(ptr1);
          END;
        END; (* while *)
      END; (* if shifted or not *)
    ELSIF kreturn = 07400H THEN                         (* Cntl-Rtarrow *)
      (* Kbshift(int); *)(* SampleKeyboard(VDIHandle, int); *)
      IF (0 IN BITSET(int)) OR (1 IN BITSET(int)) THEN (* Shft-Cntl-Rtarrow *)
        (* cursor to right edge of line in window *)
(**
        linepos:= Findend(tmpln) - cardptr^ - startcol;
**)
      (* 32 bit *)
        linepos:= SHORT(Findend(tmpln) - longptr^) - startcol;

        IF linepos > displaylen THEN (* toolong *)
          linepos:= displaylen;
        END; (* if toolong *)
(**
        i:= cardptr^ + linepos + startcol;
**)
       (* 32 bit *)
        i:= longptr^ + LONG(linepos + startcol);

        CursorPos(curdispline, leftedge + linepos);
      ELSE (* just cntl-rtarrow *)
        (* cursor to next word *)
        WHILE (ptr1^ <> 40C) & (ptr1^ <> 15C) & (i < last) DO (* find first space *)
          Rtarrow;
          ptr1:= startadr + ADDRESS(i);
        END; (* while *)
        WHILE ((ptr1^ = 40C) OR (ptr1^ = 15C)) & (i < last) DO (* find first non-space *)
          Rtarrow;
          ptr1:= startadr + ADDRESS(i);
        END; (* while *)
      END; (* if shft-cntrl-arrow *)
    ELSIF kreturn = 07700H THEN (* 3.11 *)                 (* Ctl-ClrHome *)
      IF i = 0 THEN (* to end of buff *)
        i:= last;
        SetFoundPos(FALSE, TRUE); (* no forcetop; yes calc linepos *)
      ELSE (* to top of buff *)
        i:= 0;
        SetFoundPos(FALSE, TRUE); (* no forcetop; yes calc linepos *)
      END; (* if at buffer top *)
    ELSIF kreturn = 08300H THEN                                  (* Alt-[+] *)
      KeyFont(TRUE); (* inc *)
    ELSIF kreturn = 08200H THEN                                  (* Alt-[-] *)
      KeyFont(FALSE); (* dec *)
    END; (* if ctl-arrow *)
  END; (* if *)
END HelpCntrl;

(****
(*ep*)
PROCEDURE LaunchPrg(): BOOLEAN;
VAR fname: Fseltype;
    fsel0ret: Fsel0type;
    envtail: ARRAY[0..1] OF CHAR;
    j: CARDINAL;
    result: INTEGER;
    saveA5, saveA6, saveA7: ADDRESS;
BEGIN
(*
  WindowUpdate(0);
*)
  IF daccTitle[0] <> 0C THEN (* running as acc *)
(**
    mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(1, "[1][Some PRG's won't|run from ACC][Try it!|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF result = 2 THEN (* quit *)
      RETURN TRUE;
    END;
  END; (* if running as acc *)

  Selecthead('Launch Program...', TRUE);
  IF Fselect(path, fname,fsel0ret, FALSE, TRUE) THEN
    (* Set default drive & path to match new prg *)
    j:= ORD(fname[0]) - 65;
(*
    SetDrv(j, tmplong);
*)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(j); (* drive num *)
    PUSH(0EH); (* set drv code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
(*
    ok:= SetPath(path); (* path remains from Fselect *)
*)
    PUSH(ADR(path));
    PUSH(03BH); (* setpath code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)

    CloseOpen(TRUE, j); (* do close routine, save size in j *)
    Showmouse; (* lineA Show mouse *)
(***
  for Sort module need to send startadr, last, buffsize, lnptradr.
***)
(*
    Exec(loadExecute, fname, tail, env, result);
*)
    (* save registers *)
(*
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
*)
    CODE(048E7H, 07878H); (* movem.l A1-A4/D1-D4,-(SP) *)
    envtail:= 0C;  (* don't offer any environment or command line *)
    PUSH(ADR(envtail));
    PUSH(ADR(envtail));
    PUSH(ADR(fname));
    PUSH(CARDINAL(0)); (* load & execute mode *)
    PUSH(CARDINAL(04BH)); (* Exec command *)
    saveA5:= REGISTER(A5); saveA6:= REGISTER(A6); saveA7:= REGISTER(A7);

    (*** Exec the Program! ***)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)

    SETREG(A7, saveA7); (* must be before, not after stack correction *)
    CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
    CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
    (* restore all other registers used *)
    SETREG(A5, saveA5);  SETREG(A6, saveA6);  (* SETREG(A7, saveA7); *)
    (* restore GEM registers *)
(*
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
*)
    (* movem.l A1-A4/D1-D4,(SP)+ *)
    CODE(04CDFH, 01E1EH); (* 0100 1100 1101 1111, 0001 1110 0001 1110 *)

    result:= INTEGER(REGISTER(D0));
    CODE(0A00AH); (* lineA Hide mouse *)
    CloseOpen(FALSE, j); (* do open routine restoring menu size from j *)
   (* still must restore mouse if ran mouseless application like procopy *)
    IF result < 0 THEN (* failed to find/run prg *)
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1, "[1][Can't Find or|Not Enough RAM?][ OK ]");
      CODE(0A00AH); (* lineA Hide mouse *)
    END; (* if found/ran it or not *)
  ELSE (* canceled from fselect *)
    InitMenu;
  END; (* if not cancel from Fselect *)
(**
  CODE(0A00AH); (* lineA Hide mouse *)
**)
  RETURN TRUE;
END LaunchPrg;
(*ep*)
****)

PROCEDURE LaunchPrg(): BOOLEAN;
(* launch EdHak Utility Module *)
(* pass startadr, last, lnptradr, blockstart, blockend, buffsize? *)
(* filename/path? *)
VAR fname: Fseltype;
    fsel0tmp, fsel0ret: Fsel0type;
    temppath: Pathtype;
    lcardstrg: ARRAY[0..12] OF CHAR;
    cmdtail: ARRAY[0..80] OF CHAR;
    env: ARRAY[0..1] OF CHAR; (* to send nothing *)
    savesize, j: CARDINAL;
    result: INTEGER;
    saveA5, saveA6, saveA7, saveadr: ADDRESS;
BEGIN
(*
  WindowUpdate(0);
*)
(**
    mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(1, "[1][(1) Edit Plus Utils|(2) Other Program ?][ 1 | 2 |Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    cmdtail[0]:= 0C;
    lcardstrg[0]:= 0C;
    IF result = 3 THEN (* quit *)
      RETURN TRUE;
    ELSIF result = 1 THEN (* set cmdtail with parameters to pass *)
(*
      Concat(configpath, prgname, fseltmp);
*)
      Cardtostrg(LONGCARD(ADR(cmdtail)), lcardstrg, FALSE, 7);
      MoveMem(ADR(lcardstrg), ADR(lcardstrg)+ADDRESS(3), 8);
(*
      lcardstrg[0]:= CHR(7);
*)
      lcardstrg[0]:= CHR(9);
      lcardstrg[1]:= 'C'; (* code to let util know it's EditPlus util *)
      lcardstrg[2]:= 'T';
      cmdtail[0]:= CHR(5); (* 05C; *)
      cmdtail[1]:= 'J';
      cmdtail[2]:= 'U';
      cmdtail[3]:= 'N';
      cmdtail[4]:= 'K';
      cmdtail[5]:= 'Y';
      MoveMem(ADR(startadr), ADR(cmdtail[6]), 4);
      MoveMem(ADR(lnptradr), ADR(cmdtail[10]), 4);
      MoveMem(ADR(last), ADR(cmdtail[14]), 4);
      MoveMem(ADR(lastline), ADR(cmdtail[18]), 2);
      MoveMem(ADR(buffsize), ADR(cmdtail[20]), 4);
    END;
(***
  IF daccTitle[0] <> 0C THEN (* running as acc *)
(**
    mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(1, "[1][Some PRG's won't|run from ACC][Try it!|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF result = 2 THEN (* quit *)
      RETURN TRUE;
    END;
  END; (* if running as acc *)
***)
  fsel0tmp:= cfg.fsel0;
  cfg.fsel0:= '*.PRG';
  temppath:= configpath;
  Selecthead('Launch Program...', TRUE);
  IF Fselect(configpath, fname,fsel0ret, FALSE, TRUE) THEN
    (* Set default drive & path to match new prg *)
    j:= ORD(fname[0]) - 65;
(*
    SetDrv(j, tmplong);
*)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(j); (* drive num *)
    PUSH(0EH); (* set drv code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
(*
    ok:= SetPath(path); (* path remains from Fselect *)
*)
    PUSH(ADR(path));
    PUSH(03BH); (* setpath code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
    CloseOpen(TRUE, savesize, saveadr); (* do close routine, save size in j *)
    Showmouse; (* lineA Show mouse *)
(*
    Exec(loadExecute, fname, tail, env, result);
*)
    (* save registers *)
(*
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
*)
    CODE(048E7H, 07878H); (* movem.l A1-A4/D1-D4,-(SP) *)
    env:= 0C;  (* don't offer any environment or command line *)
    PUSH(ADR(env));
    PUSH(ADR(lcardstrg)); (* cmdtail)); *)
    PUSH(ADR(fname));
    PUSH(CARDINAL(0)); (* load & execute mode *)
    PUSH(CARDINAL(04BH)); (* Exec command *)
    saveA5:= REGISTER(A5); saveA6:= REGISTER(A6); saveA7:= REGISTER(A7);

    (*** Exec the Program! ***)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)

    SETREG(A7, saveA7); (* must be before, not after stack correction *)
    CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
    CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
    (* restore all other registers used *)
    SETREG(A5, saveA5);  SETREG(A6, saveA6);  (* SETREG(A7, saveA7); *)
    (* restore GEM registers *)
(*
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
*)
    (* movem.l A1-A4/D1-D4,(SP)+ *)
    CODE(04CDFH, 01E1EH); (* 0100 1100 1101 1111, 0001 1110 0001 1110 *)

    result:= INTEGER(REGISTER(D0));
    CODE(0A00AH); (* lineA Hide mouse *)
    CloseOpen(FALSE, savesize, saveadr); (* do open routine restoring menu size from j *)
   (* still must restore mouse if ran mouseless application like procopy *)
    IF result < 0 THEN (* failed to find/run prg *)
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1, "[1][Can't Find or|Not Enough RAM?][ OK ]");
      CODE(0A00AH); (* lineA Hide mouse *)
    ELSE
      Lineptrs(0); (* needed if called sorting prg *)
      saved:= FALSE;
    END; (* if found/ran it or not *)
  ELSE (* canceled from fselect *)
    InitMenu;
  END; (* if not cancel from Fselect *)
  cfg.fsel0:= fsel0tmp;
  configpath:= temppath;
(**
  CODE(0A00AH); (* lineA Hide mouse *)
**)
  RETURN TRUE;
END LaunchPrg;
(*ep*)

PROCEDURE Upload;
VAR tmpdev: INTEGER;
BEGIN
(**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  IF typeahead <> 0C THEN
    dummy:= FormAlert(3, "[2][ Output Options:     ][Serial|Midi|TypeAhead Off]");
  ELSE
    dummy:= FormAlert(1, "[2][ Output Options:     ][Serial|Midi|TypeAhead On]");
(*
  dummy:= FormAlert(1, "[2][ Send Ouput To:  ][Serial|Midi|Cancel]");
*)
  END; 
  CODE(0A00AH); (* lineA Hide mouse *)
  IF dummy = 3 THEN
    TypeInit; (* set typeahead on/off & outdev *)
  ELSE (* just upload *)
    tmpdev:= outdev;
    IF dummy = 1 THEN
      outdev:= 1; (* serial port *)
    ELSIF dummy = 2 THEN
      outdev:= 3; (* midi port *)
    END; (* if tospaces *)
    SelectMenu(PRNTMENU, PRNTALL);
(*
    outdev:= 0; (* reset to parallel port when done *)
*)
    outdev:= tmpdev; (* restore original output device *)
  END; (* if not cancelled from Send *)
END Upload;

PROCEDURE Print;
VAR tmpdev: INTEGER;
BEGIN
  tmpdev:= outdev;
  outdev:= 0; (* parallel port *)
  SelectMenu(PRNTMENU, PRNTALL);
  outdev:= tmpdev; (* restore original output device *)
END Print;

PROCEDURE GotoBigInd(wantind: LONGCARD): BOOLEAN;
VAR startftmp, endftmp: LONGCARD;
(*
    doit: BOOLEAN;
*)
BEGIN
(**
  IF (wantind < startf) OR (wantind > endf) THEN (* must shift buffer *)
**)
(**)
  IF (wantind < startf) OR (wantind > startf + last) THEN (* must shift buffer *)
(**)
(*
    IF doit THEN
*)
(*** 3.1C+ ***)
      IF wantind > (startf + last) (* endf *) THEN (* forward *)
        LOOP
          IF NOT PageBigFile(TRUE, TRUE) THEN (* forward, no ask *)
            RETURN FALSE;
(*
            doit:= FALSE;
            EXIT;
*)
          END;
          IF (wantind <= endf) OR (endf >= fileend) THEN
            EXIT;
          END;
        END; (* loop forward *)
      ELSE (* backward *)
        IF wantind = 0 THEN (* just read start of file *)
          notistrg:= 'Shifting..';
          Notice;
          IF pastelen > 0 THEN
            IF NOT ShiftCheck() THEN
              RETURN FALSE; (* canceled *)
            END;
          END; (* if something in pastebuffer *)
          IF NOT SaveCheck(FALSE, TRUE) THEN (* askbig?, asksave? *)
            RETURN FALSE;
          END;
          startftmp:= 0; (* do not let this go negative! *)
          endftmp:= blocksize; (* 2.25 *)
          IF endftmp > fileend THEN (* 2.30 *)
            endftmp:= fileend; (* and bigpart is really false now *)
            (* bigpart:= FALSE; *)
          END;
          j:= Readfile(fsel, startftmp, endftmp);
          IF j = 3 THEN
            FileAlert;
            (* RETURN FALSE; *)
          END; (* if failed read *)
          MiniInit;
          startf:= startftmp;
          endf:= endftmp;
          last:= endf - startf;
          lasti:= last;
          Lineptrs(0);
          pastelen:= 0;
          buffline:= 0;
        ELSE (* goto somewhere other than filestart *)
          LOOP
            IF NOT PageBigFile(FALSE, TRUE) THEN (* forward?, ask? *)
              RETURN FALSE;
(*
              doit:= FALSE;
              EXIT;
*)
            END;
            IF (wantind >= startf) OR (startf = 0) THEN
              EXIT;
            END;
          END; (* loop forward *)
        END; (* if jump to filestart *)
      END; (* if forward/back *)
(**  remove for 3.2C ? **
      ShowNew;
**)
(*
    END; (* if not canceled *)
*)
(*** +3.1C ***)
  END; (* if outside buffer *)
  i:= wantind - startf;
  SetFoundPos(FALSE, TRUE); (* no forcetop.  keeps i<=last *)
  InitMenu;
  RETURN TRUE;
END GotoBigInd;

PROCEDURE Gotoline;  (* alt-G *)
(* goes to line # in txt mode, or offset in hack mode *)
VAR strg: Substrg;
    newln,len: CARDINAL;
    tmplong, tmplast: LONGCARD;
    doit, getnew: BOOLEAN;
BEGIN
  strg:= 0C;
  InitObjStrg(TEXTTREE, TEXT2, '  '); (* '(counted within buffer)'); *)
  InitObjStrg(TEXTTREE, TEXTSTRG, strg); (* 3.13 *)
  IF cfg.eollen > 0 THEN
    InitObjStrg(TEXTTREE, TEXT1, '     Go To Line #      ');
  ELSE  (* hack mode *)
    InitObjStrg(TEXTTREE, TEXT1, '  Go To Byte Offset #  ');
  END;
  getnew:= FALSE;
  (* default to decimal *)
  len:= GetStrg(strg, getnew, FALSE (*, dummy *) ); (* disable hex/dec *)
  IF (len <> 0) & (len <> 0FFH) THEN (* not cancelled or zero length strg *)
    (* do it *)
    tmplong:= Strgtolongc(strg, FALSE); (* false = not ishex *)
    IF cfg.eollen > 0 THEN (* text mode *)
      newln:= SHORT(tmplong); (* here newln is in terms of total file *)
      IF newln < 1 THEN
        newln:= 1;
      END;
      DEC(newln); (* since calcs use #'s from zero *)
(**
      IF (endf >= fileend) & (newln > buffline + lastline) THEN (* in last buffer *)
        newln:= buffline + lastline;
      END;
**)
      doit:= TRUE;
(*** 3.1C+ ***)
      IF (newln < buffline) OR (newln > buffline + lastline) THEN (* must shift buffer *)
        IF newln > buffline + lastline THEN (* forward *)
          LOOP
            IF NOT PageBigFile(TRUE, TRUE) THEN (* forward?, asksave? *)
              doit:= FALSE;
              EXIT;
            END;
            IF (newln <= buffline + lastline) OR (endf >= fileend) THEN
              EXIT;
            END;
          END; (* loop forward *)
        ELSE (* backward *)
          LOOP
            IF NOT PageBigFile(FALSE, TRUE) THEN (* forward?, asksave? *)
              doit:= FALSE;
              EXIT;
            END;
            IF (newln >= buffline) OR (startf = 0) THEN
              IF startf = 0 THEN (* add startf stuff 3.2C *)
                buffline:= 0;
              END;
              EXIT;
            END;
          END; (* loop backward *)
        END; (* if forward/back *)

(** why here?? **
        IF doit THEN
          ShowNew;
        END; (* if doit, not canceled *)
**)      
(*** +3.1C ***)
      END; (* if outside buffer *)
      IF doit THEN
        IF newln > buffline + lastline THEN
          newln:= buffline + lastline;
        END;
        IF newln < buffline THEN
          newln:= buffline;
        END;
(**     
        i:= wantind - startf;
        SetFoundPos(FALSE, TRUE); (* no forcetop.  keeps i<=last *)
**)     
        longptr:= lnptradr + ADDRESS(4*LONG(newln - buffline));
(*      
        longptr:= lnptradr + ADDRESS(4*LONG(newln));
*)      
        i:= longptr^;
        linepos:= 0;
        SetFoundPos(FALSE, FALSE); (* no forcetop, no find linepos *)
        InitMenu;
      END; (* if doit *)
    ELSE (* hack mode, newln means new i *)
      tmplast:= fileend; (* 3.11 *)
      IF last > lasti THEN
        INC(tmplast, last - lasti);
      ELSE
        DEC(tmplast, lasti - last);
      END;

      IF tmplong > tmplast THEN
        tmplong:= tmplast;
      END;
      ok:= GotoBigInd(tmplong);
(**
      i:= tmplong;
      SetFoundPos(FALSE, TRUE); (* no forcetop.  keeps i<=last *)
**)
    END; (* if txt or hack mode *)
(*
    CursorPos(curdispline, leftedge + linepos); (* done in setfoundpos *)
*)
    NotiChar;
    SetSlidePos;
  END; (* if valid string *)
END Gotoline;

PROCEDURE AltKey(VAR kreturn: CARDINAL);
(* kreturn < 03B00H *)
VAR cardptr, cardptr2: POINTER TO CARDINAL;
    saveadr: ADDRESS;
    j: CARDINAL;
    shiftset: BOOLEAN; (* one of shift keys is pressed *)
BEGIN
  shiftset:= FALSE;
  Kbshift(dummy);
  IF BITSET(dummy) * BITSET(03H) <> {} THEN (* one of shift keys pressed *)
    shiftset:= TRUE;
  END;
  j:= 04355H; (* to allow finding this spot in binary *)
  IF kreturn = 01F00H THEN                                      (* Alt-S *)
    dummy:= 0;
    IF shiftset THEN        (* alt-shift-S *)
      dummy:= 1;
    END;
    ok:= Savefile(NOT(shiftset), dummy); (* ask? questions; force? overwrite *)
  ELSIF (kreturn = 01300H) OR (kreturn = 01800H) THEN  (* Alt-R, Alt-Open *)
    IF shiftset THEN        (* alt-shift-R or O *)
      StripCtl;
    ELSE
      SelectMenu(FILEMENU, OPEN);
    END;
  ELSIF kreturn = 01000H THEN
    DoQuit; (* SelectMenu(FILEMENU, QUIT); *)                   (* Alt-Q *)
  ELSIF kreturn = 02D00H THEN (* no query *)                    (* Alt-X *)
    (* since cursor is turned off when this keypress occurs *)
    (* Curson; *)(* don't need to bother since that's VT-52 cursor *)
    (* check if shift key pressed for alt exit for QCIS *)
(*
    ok:= TRUE;
    IF (daccTitle[0] = 0C) (* or MDX *) THEN (* treat as prg *)
      ok:= SaveCheck(TRUE, TRUE) THEN (* askbig & asksave *)
    END;
    IF ok THEN
*)
      ok:= FALSE; (* default to normal exit *)
      IF shiftset THEN (* shift key pressed *)
        ok:= TRUE;
      END; (* if alt terminate *)
      Terminate;
(*
    END;
*)
  ELSIF kreturn = 02E00H THEN                                 (* Alt-C *)
    IF shiftset THEN (* shift-alt-C *)
      ok:= Setclipbrd(path);
    ELSE
      SelectMenu(EDITMENU, CLEARBUF);
    END; (* if shift-alt-C *)
  ELSIF kreturn = 02300H THEN DoHelp;                         (* Alt-H *)
  ELSIF kreturn = 01900H THEN Print;                          (* Alt-P *)
    (* SelectMenu(PRNTMENU, PRNTALL) *)
(*ds*)
  ELSIF kreturn = 01100H THEN SelectMenu(EDITMENU, WRAP);     (* Alt-W *)
(**
  ELSIF kreturn = 03000H THEN SelectMenu(EDITMENU, BLOCK);    (* Alt-B *)
**)
  ELSIF kreturn = 02100H THEN                                 (* Alt-F *)
    IF shiftset THEN (* shift-alt-F *)
      ChooseFont;
(*
      EndFont; (* sets to new *)
*)
    ELSE (* just alt-F *)
      ok:= DoFind(TRUE);
    END; (* if shift-alt-C *)
  ELSIF kreturn = 02200H THEN (* goto line # *)               (* Alt-G *)
    Gotoline;
  ELSIF kreturn = 03200H THEN                                 (* Alt-M *)
    ok:= DoMerge(FALSE, FALSE); (* not topastebuff, not clipbrd *)
  ELSIF kreturn = 01200H THEN (* ok:= Encrypt(); *)           (* Alt-E *)
    IF shiftset THEN (* shift-alt-E select all *)
      RuinBlock(TRUE);
      blockstart:= 0;
      blockend:= last;
      BlockCheck; (* sets isblock & switches start/end if needed *)
      blocktype:= 1; (* isblock:= TRUE; 1=normal block *)
      ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
    ELSE (* Alt-E *)
      CallCase;
(*
      Showmouse; (* lineA Show mouse *)
      int:= 2;
      result:= FormAlert(int,"[2][ Change Case of Block][Lower|Upper|Caps]");
      CODE(0A00AH); (* lineA Hide mouse *)
      ChangeCase(result);
*)
    END; (* if shift-alt-C *)
  ELSIF kreturn = 01700H THEN InsertBytes;                     (* Alt-I *)
  ELSIF kreturn = 02F00H THEN (* ViewMem() *)                  (* Alt-V *)
    (**)(*
    PleaseReg;
    (**)*)
    ok:= ViewMem();
    GrafMouse(GEMAESbase.Arrow, NIL); (* from busy bee in case of search *)
    (**)
  ELSIF kreturn = 01400H THEN HackToggle;                      (* Alt-T *)
  ELSIF kreturn = 02000H THEN
    IF shiftset THEN                         (* shift-alt-D date format *)
      DateCfg;
    ELSE                                                       (* Alt-D *)
      ShowDate;
    END; (* if shifted *)
  ELSIF kreturn = 03100H THEN NewConfig;                       (* Alt-N *)
  ELSIF kreturn = 01600H THEN (* Upload to serial port, (Zap)*)(* Alt-U *)
    Upload;
(*ep*)
  ELSIF kreturn = 02600H THEN (* Launch prg *)                 (* Alt-L *)
    ok:= LaunchPrg();
(*ep*)
(*ex*
  ELSIF kreturn = 02400H THEN                                  (* Alt-J *)
    MailPrint;
*ex*)
  ELSIF kreturn = 01E00H THEN                                  (* Alt-A *)
(* 2.30 make alt-A append, and shift-alt-K = kwikedhaksend *)
    IF shiftset THEN (* a shift key pressed *)
      ok:= Savefile(FALSE, 2); (* don't ask questions; force append *)
    ELSE (* force append with file selection *)
      ok:= Savefile(TRUE, 2); (* ask questions, force append *)
    END; (* if shift-alt-C *)
  ELSIF (kreturn = 03900H) THEN                             (* Ctl-Space *)
    ShiftBlk(0); (* left, note shift/alt-space are done in key()! *)
(*213*)
  ELSIF (kreturn = 02500H) (* & (daccTitle[0] <> 0C) *) THEN     (* Alt-K *)
  (* 2.30 make alt-A append, and shift-alt-K = kwikedhaksend *)
    IF shiftset THEN (* a shift key pressed *)
      (* do buffer send to EDITPLUS.ACC, as QCIS does *)
      result:= ApplFind('EDITPLUS');
      IF result < 0 THEN (* not found *)
        notistrg:= 'Not Found ';
        Notice;
      ELSE
        pipeBuff[0]:= GEMAESbase.AccessoryOpen;
        (* the next two are needed *)
        pipeBuff[1]:= Appl; (* your application ID, 
                               so EdHak knows where to send back data *)
        pipeBuff[2]:= 16; (* anything above 0 will let EdHak know to
                             read all 16, since it just checks for > 0 *)
        pipeBuff[5]:= 04354H; (* magic number that ensures this is for EdHak *)
        pipeBuff[6]:= 2; (* xfertype:
                          1 = pass filespec, 2 = pass buffer address/size *)
        ApplWrite(result, 16, ADR(pipeBuff)); (* std 16 byte msg *)
        (* now send filespec and related info *)
  (*
        pipeBuff[0]:= 04354H; (* magic number that EdHak knows to look for *)
        pipeBuff[0]:= 2; (* xfertype:
                          1 = pass filespec, 2 = pass buffer address/size *)
  *)
        pipeBuff[0]:= 0; (* 1 = Force full window only, 0 = don't force full *)
        pipeBuff[1]:= 1; (* 1 = Load, 0 = don't load file *)
  (*
        (* for xfertype #1, passing filespec: *)
        pipeBuff[2]:= SHORT(LONGCARD(ADR(fsel)) DIV 010000H);
        pipeBuff[3]:= SHORT(LONGCARD(ADR(fsel)) MOD 010000H);
  *)
        pipeBuff[2]:= SHORT(LONGCARD(startadr) DIV 010000H); (* hi word of adr *)
        pipeBuff[3]:= SHORT(LONGCARD(startadr) MOD 010000H); (* low word *)
         (* Set 2 & 3 to the address of your buffer, split into words *)
        pipeBuff[4]:= SHORT(last DIV 010000H); (* high word of used size *)
        pipeBuff[5]:= SHORT(last MOD 010000H); (* low word of used size *)
         (* Set 4 & 5 to the used size of your buffer, zero for new mail *)
        pipeBuff[6]:= SHORT(buffsize DIV 010000H); (* high word of buffer size *)
        pipeBuff[7]:= SHORT(buffsize MOD 010000H); (* low word of buffer size *)
         (* Set 6 & 7 to the total size of your buffer *)
        ApplWrite(result, 16, ADR(pipeBuff)); (* std 16 byte msg *)
      END; (* if write accopen msg *)
    ELSE
(*
      IF (daccTitle[0] <> 0C) THEN
*)
      IF blocktype = 1 THEN
        (* send to other appl/acc window via kbd buffer *)
        kwiksend:= TRUE;
        Terminate;
      ELSE
        BlockAlert;
      END; (* if normal block is marked *)
(*
      END; (* if running as acc *)
*)
    END; (* if shiftset alt-k *)
  END; (* if alt keys *)
END AltKey;


PROCEDURE FuncArrow(kreturn: CARDINAL);
(* kreturn between 03B00H and 05D00H inclusive *)
(* function keys, arrows, insert, delete, home, LoByte = 0 *)
VAR extend, shiftset, ctlset: BOOLEAN;
    whichmacro, macrolen: CARDINAL;
    int: INTEGER;
BEGIN
  ctlset:= FALSE;
  shiftset:= FALSE;
  Kbshift(dummy);
  IF BITSET(dummy) * BITSET(04H) <> {} THEN (* control key pressed *)
    ctlset:= TRUE;
  END;
  IF BITSET(dummy) * BITSET(03H) <> {} THEN (* one of shift keys pressed *)
    shiftset:= TRUE;
  END;
  IF kreturn >= 04700H THEN
    IF kreturn = 04B00H THEN Leftarrow;                    (* Left Arrow *)
    ELSIF kreturn = 04D00H THEN Rtarrow;                  (* Right Arrow *)
    ELSIF kreturn = 05000H THEN                            (* Down Arrow *)
      IF ctlset THEN
        IF shiftset THEN                          (* shift-ctl-downarrow *)
          Slide(Window1, 1000);
        ELSE (* no shift *)
          i:= last;
          SetFoundPos(FALSE, TRUE); (* no forcetop; yes calc linepos *)
        END; (* if ctl *)
      ELSE
        Downarrow;
      END;
    ELSIF kreturn = 04800H THEN                            (* UpArrow *)
      IF ctlset THEN
(*
        IF shiftset THEN                            (* shift-ctl-uparrow *)
          Slide(Window1, 0);
        ELSE (* no shift *)
*)
          i:= 0;
          SetFoundPos(FALSE, TRUE); (* no forcetop; yes calc linepos *)
(*
        END;
*)
      ELSE
        Uparrow;                 (* Up Arrow *)
      END;
    ELSIF kreturn = 04700H THEN ChkClrHome;                   (* ClrHome *)
    ELSIF kreturn = 05200H THEN (* toggle insert/replace *)    (* Insert *)
      Kbshift(int); (* SampleKeyboard(VDIHandle, int); *)
      IF (2 IN BITSET(int)) THEN                          (* Ctrl-Insert *)
        CopyBlk(1); (* not toclip *)
      ELSE
        cfg.insertmode:= NOT(cfg.insertmode);
        IF cfg.insertmode THEN
          notistrg:= ' Insert   ';
        ELSE
          notistrg:= 'Overwrite ';
        END; (* if *)
        Notice;
      END; (* if ctl-ins *)
(*
      | 05300H : Delete; (* how is this different from 00E7FH = DEL ? *)
*)
(*
      IF BITSET(int) * BITSET(03H) <> {} THEN (* one of shift keys pressed *)
      IF (0 IN BITSET(int)) OR (1 IN BITSET(int)) THEN (* shift-alt-Fn *)
*)
    ELSIF kreturn = 05400H THEN                         (* shift-F1 *)
      (* mark column block start *)
      RuinBlock(TRUE);
      blockstart:= i;
      mark[0]:= i;
      notistrg:= 'Start Set ';
      Notice; (* ('START Set '); *)
    ELSIF kreturn = 05500H THEN                         (* shift-F2 *)
      (* mark column block end *)
      extend:= FALSE;
      IF blocktype > 0 (* isblock *) THEN
        extend:= TRUE;
      END;
      mark[1]:= i;
      RuinBlock(TRUE);
      IF i <> blockstart THEN
        IF (i < blockstart) & extend THEN
          blockstart:= i;
        ELSE (* i > blockstart or i < blockstart w/o isblock *)
          blockend:= i;
        END;
        BlockCheck; (* sets isblock & switches start/end if needed *)
        blocktype:= 2; (* isblock:= TRUE; 2=col block *)
        ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
      END; (* if i <> blockstart *)
    ELSIF kreturn = 05700H THEN                 (* shift-F4 = Copy block *)
      CopyBlk(1); (* to buff *)
    ELSIF kreturn = 05800H THEN                 (* shift-F5 = paste col block *)
      PasteBlk(TRUE, FALSE); (* colblk, fromclip *)
(*
      ok:= Pastecolblk();
*)
    ELSIF kreturn = 05A00H THEN               (* shift-F7 = Copy toClip *)
      CopyBlk(2); (* toclip *)
    ELSIF kreturn = 05B00H THEN             (* shift-F8 = pastecol fromClip *)
      PasteBlk(TRUE, TRUE); (* colblk, fromclip *)
    END; (* if arrows or shift-Fn *)
(*ds*)
(**)
    ClearKBD; (* moved here from beginning for 3.02 *)
(**)
  ELSE (* unshifted Function keys *)
    Kbshift(int); (* SampleKeyboard(VDIHandle, int); *)
    IF NOT ( (2 IN BITSET(int)) OR (3 IN BITSET(int)) ) THEN
      (* neither cntrl or alt keys pressed *)
      IF kreturn = 03B00H THEN                  (* F1 = mark start of block *)
        RuinBlock(TRUE);
        blockstart:= i;
        mark[0]:= i;
        notistrg:= 'Start Set ';
        Notice; (* ('START Set '); *)
      ELSIF kreturn = 03C00H THEN                  (* F2 = mark end of block *)
        extend:= FALSE;
        IF blocktype > 0 (* isblock *) THEN
          extend:= TRUE;
        END;
        mark[1]:= i;
        RuinBlock(TRUE);
        IF i <> blockstart THEN
          blocktype:= 1; (* isblock:= TRUE; *)
          IF (i < blockstart) & extend THEN
            blockstart:= i;
          ELSE (* i > blockstart or i < blockstart w/o isblock *)
            blockend:= i;
          END;
          BlockCheck; (* sets isblock & switches start/end if needed *)
          blocktype:= 1; (* 1=normal block *)
          ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
        END; (* if i <> blockstart *)
      ELSIF kreturn = 03D00H THEN                      (* F3 = Clear marks *)
        RuinBlock(TRUE);
        notistrg:= 0C;
        InitMenu;
      ELSIF kreturn = 03E00H THEN                        (* F4 = cut block *)
        DoCut(1); (* not toclip *)
      ELSIF kreturn = 03F00H THEN                      (* F5 = paste block *)
        PasteBlk(FALSE, FALSE); (* colblk, fromclip *)
(*
        Pasteblock;
*)
      ELSIF kreturn = 04000H THEN                        (* F6 = Find next *)
        IF srchlen > 0 THEN (* is a string to find *)
          ok:= DoFind(FALSE);
        END; (* if something to find *)
      ELSIF kreturn = 04100H THEN                        (* F7 = cut toClip *)
        DoCut(2); (* toclip *)
      ELSIF kreturn = 04200H THEN                      (* F8 = paste fromClip *)
        PasteBlk(FALSE, TRUE); (* colblk, fromclip *)
      ELSIF kreturn = 04300H THEN                         (* F9 = Macros *)
        ShowMacros;
      ELSIF kreturn = 04400H THEN                         (* F10 = Wrap *)
        SelectMenu(EDITMENU, WRAP); 
      END; (* if kreturn = F1... *)
    ELSIF 3 IN BITSET(int) THEN (* alt key is pressed *)       (* Alt-Fn *)
      (* insert macro for that function key at cursor *)
      whichmacro:= (kreturn - 03A00H) DIV 0100H; (* gives 1..10 *)
      InsertMacro(whichmacro);
    ELSIF 2 IN BITSET(int) THEN (* control key pressed *)      (* Ctl-Fn *)
      IF blocktype = 1 (* isblock *) THEN
        (* copy marked block to macro for that function key *)
        macrolen:= SHORT(blockend - blockstart);
        IF macrolen > macrosize THEN (* truncate and notify user *)
          macrolen:= macrosize;
          notistrg:= 'Truncated!';
        ELSE
          notistrg:= 'Macro Set ';
        END;
        Notice;
        whichmacro:= (kreturn - 03A00H) DIV 0100H; (* gives 1..10 *)
        MoveMem(startadr + ADDRESS(blockstart), ADR(cfg.macro[whichmacro]), LONG(macrolen));
        cfg.macro[whichmacro][macrolen]:= 0C; (* old terminator *)
        cfg.macro[whichmacro][macrosize]:= CHR(macrolen); (* size *)

        (* clear marked block & confirm macro set *)
        (* RuinBlock(TRUE); *)
      ELSE (* no normal block is set *)
        BlockAlert;
      END; (* if isblock to copy to macro *)
    END; (* if alt/cntl/shft key pressed with FuncKey *)
(*ds*)
  END; (* if kreturn >= 4700H arrow keypad or function keys *)
END FuncArrow;

PROCEDURE Tabtospace(): BOOLEAN;
VAR col, ln, spaces, minspaces: CARDINAL;
    start, len: LONGCARD;
    totab: BOOLEAN;
BEGIN
  minspaces:= 2;
  (* need to do repeated search for tab or multiple spaces *)
  (* and replace appropriately per tabspace setting *)
(**
  mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
  Showmouse; (* lineA Show mouse *)
  totab:= TRUE;
  dummy:= FormAlert(2, "[2][   Convert:   ][To Tabs|To Spaces|Cancel]");
  CODE(0A00AH); (* lineA Hide mouse *)
  IF dummy = 3 THEN
    RETURN TRUE;
  ELSIF dummy = 2 THEN
    totab:= FALSE;
  END; (* if tospaces *)
  ln:= 0;
  Showmouse; (* lineA Show mouse *)
  GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)

  LOOP (* through each line *)
    col:= 0;
    (* find linestart and count spaces from there *)
    longptr:= lnptradr + ADDRESS(4*LONG(ln));
    tmpadr:= startadr + ADDRESS(longptr^); (* line start address *)
    len:= Findend(ln) - longptr^;
    IF totab THEN
      WHILE (col + cfg.tabspaces) < minspaces DO
        INC(col, cfg.tabspaces);
      END; (* while inc col *)
      WHILE (col + cfg.tabspaces) < SHORT(len) DO
        (* check each tab column for at least 2 preceding spaces *)
        (* and replace that run of spaces with one tab *)
        INC(col, cfg.tabspaces); (* col must be >= 1 for next line *)
        ptr1:= tmpadr + ADDRESS(LONG(col-1)); (* char prior to tabset *)
        ptr2:= ADDRESS(ptr1) - 1;
        IF (ptr1^ = 40C) & (ptr2^ = 40C) THEN
          ptr1^:= 11C; (* tab = 9 decimal *)
          spaces:= 2;
            (* 2.25 *)
            DEC(ptr2);
            WHILE (ptr2 >= ADDRESS(longptr^)) & (ptr2^ = 40C) 
              & (spaces < cfg.tabspaces) DO       (* 40C = space *)
              INC(spaces);
              DEC(ptr2);
            END; (* while counting spaces to replace *)
            INC(ptr2);

          tmplong:= last - LONGCARD(ADDRESS(ptr1) - startadr);
          MoveMem(ptr1, ptr2, tmplong);
          DEC(spaces);
          DEC(col, spaces);
          DEC(last, spaces);
          DEC(len, spaces);

          (* dec following lnptrs by deletions *)
          j:= ln;
          longptr:= lnptradr + ADDRESS(LONG(ln)*4);
          WHILE j < lastline DO
            INC(j);
            longptr:= ADDRESS(longptr) + 4;  (* this skips current line *)
            longptr^:= longptr^ - LONG(spaces);
          END; (* while dec'ing lnptrs *)

        END; (* if made a tab *)  
      END; (* while handling this line to tabs *)
    ELSE (* tab to spaces *)
      ptr1:= tmpadr; (* + ADDRESS(LONG(col));*) (* char prior to tabset *)
      WHILE col < SHORT(len) DO
        (* search for each tab and expand out to next tabstop *)
        WHILE (ptr1^ <> 11C) & (col < SHORT(len)) DO
          INC(col);
          INC(ptr1);
        END; (* While search for tab *)
        IF ptr1^ = 11C THEN (* found tab *)
          (* calc # of spaces to add after replacing tab with space *)
          spaces:= cfg.tabspaces - (col MOD cfg.tabspaces) - 1;
          (* make tab a space, movemem spaces -1, make other chars spaces *)
          ptr1^:= 40C; (* space *)
          INC(ptr1);
          ptr2:= ADDRESS(ptr1) + ADDRESS(spaces);
  
          tmplong:= last - LONGCARD(ADDRESS(ptr1) - startadr);
          MoveMem(ptr1, ptr2, tmplong);

          j:= 0;
          WHILE j < spaces DO
            ptr1^:= 40C;
            INC(ptr1);
            INC(j);
          END; (* while filling spaces *)
          (* now ptr1 should = ptr2 *)
          ptr1:= ptr2; (* just to be sure *)
          INC(last, spaces);
          INC(len, spaces);
          col:= SHORT(LONGCARD(ADDRESS(ptr1) - tmpadr));

          (* inc following lnptrs by insertions *)
          j:= ln;
          longptr:= lnptradr + ADDRESS(LONG(ln)*4);
          WHILE j < lastline DO
            INC(j);
            longptr:= ADDRESS(longptr) + 4;  (* this skips current line *)
            longptr^:= longptr^ + LONG(spaces);
          END; (* while dec'ing lnptrs *)

        END; (* if found a tab to convert to spaces *)
      END; (* while handling this line to spaces *)

    END; (* if totab or to spaces *)
    INC(ln);
    IF ln > lastline THEN
      EXIT;
    END;
  END; (* loop through lines *)
  GrafMouse(GEMAESbase.Arrow, NIL); (* end busy bee *)
  CODE(0A00AH); (* lineA Hide mouse *)

  longptr:= lnptradr + ADDRESS(LONG(line+curdispline)*4);
  i:= longptr^;
  linepos:= 0;
  saved:= FALSE;
  Display(0, cfg.maxdispline);
  RETURN TRUE;
END Tabtospace;

PROCEDURE ClearKBD;
(* clear keyboard buffer by setting head = tail *)
(* same as in aborting kwiksend *)
VAR tmplong: LONGCARD;
BEGIN
(* method 1 *)
  SETREG(A2, kbdrecptr); (* 6 bytes. later must move.l (a2),a2 *)
(*d0*)
  (* move.w 6(A2),8(A2) ; set tail = head to 'empty' kbd buffer *)
  CODE(0356AH,00006H,00008H); (* move.w 6(A2),8(A2) *)
(*d0*)

(***
  LOOP
(*
    (* method 2 *)
    LOOP (* clear gemdos buffer *) (* 3.0N test *)
      IF Bcosstat(2, 1) THEN (* 2=CON, 1=input *)
        tmplong:= BconinGetBPB(2, 2); (* 2=CON, 2=bconin *)
      ELSE
        EXIT;
      END;
    END;
*)

(* This plus gemdos buffer clear e.g., method 1, works, but this is too slow *)

      dummy:= EventMultiple(GEMAESbase.KeyboardEvent+GEMAESbase.TimerEvent,
                         1,1,1, (* wait for left button down *)
                         0,0,0,0,0,
                         0,0,0,0,0,
                         ADR(pipeBuff), 0,0,
                         dummy,dummy, dummy,dummy, dummy, dummy);
    IF BITSET(dummy) * BITSET(GEMAESbase.KeyboardEvent) = {} THEN
      EXIT;
    END;
  END; (* loop *)
***)
END ClearKBD;


PROCEDURE Key(kreturn: CARDINAL); (* process non-zero low byte keystroke *)
VAR j,k, tmpln: CARDINAL;
    int: INTEGER;
BEGIN
  (* see what the scan code really is ! *)
(**
  Cardtostrg(LONG(kreturn DIV 00100H), cardstrg, FALSE, 5);
  StringZap(cardstrg);
  Cardtostrg(LONG(kreturn MOD 00100H), cardstrg, FALSE, 5);
  StringZap(cardstrg);
  Wait(dummy,dummy,dummy,dummy);
**)
  Kbshift(int); (* SampleKeyboard(VDIHandle, int); *)
  IF (newchar >= 40C) & (kreturn < 04737H) THEN (* just ascii 32..126 *)
(*ds*)
    IF (newchar <> '.') & (newchar <> ',') &
       (newchar <> ' ') THEN (* don't check for alt-< > *)
(*ds*)
      AddInsert; (* DoAscii; *)
(*ds*)
    ELSE (* see if Alt-< > for margin setting *)
      (* Kbshift(int); *)(* SampleKeyboard(VDIHandle, int); *)
      IF newchar = ' ' THEN
        IF BITSET(3) * BITSET(int) <> {} THEN (* shift-space *)
          ShiftBlk(1); (* right *)
        ELSIF 3 IN BITSET(int) THEN (* alt-space *)
          ShiftBlk(2); (* quote *)
        ELSE (* note: ctl-space is done in altkey()!! *)
          AddInsert; (* DoAscii; *)
        END; (* if space *)
      ELSE (* < > *)
        IF 3 IN BITSET(int) THEN (* alt key is pressed *)
          IF newchar = ',' THEN (* < means set left print margin *)
            ok:= DoMargins(1);
          ELSE (* > means set right wrap margin *)
            ok:= DoMargins(2);
          END;
        ELSE (* just process as normal keypress *)
          AddInsert; (* DoAscii; *)
        END; (* if alt key is pressed *)
      END; (* if space or < > *)
    END; (* if not < or > key *)
(*ds*)
  ELSIF newchar < 40C THEN (* was <= 33C, 1..27 *)
    (* CASE kreturn OF *)
    IF kreturn = 00E08H THEN       (* 10C *)              (* Backspace *)
      IF blocktype > 0 (* isblock *) THEN (* delete block *)
        DoCut(1); (* to buffer *)
      ELSE
        Backspace;
      END; (* if isblock to delete *)
    ELSIF kreturn = 0531FH THEN                           (* Ctl-Delete *)
      DoCut(1); (* to buffer *)
    ELSIF kreturn = 01C0AH THEN                           (* control-CR *)
      (*ep+*
      PleaseReg;
      *ep-*)
      (* toggles 'cr' display at end of line *)
      IF cfg.eolchar = 15C THEN
        cfg.eolchar:= 0C; (* ' '; space *)
      ELSE
        cfg.eolchar:= 15C; (* CR *)
      END;
      Display(0, cfg.maxdispline);
      (*ep*)
(*213*)
    ELSIF (newchar = 12C) & (i > 0) THEN     (* LF *)          (* Linefeed *)
      ptr1:= startadr + ADDRESS(i-1);
      IF ptr1^ = 15C THEN      (* LF is preceded by CR *)
        ok:= cfg.autowrap; (* temp holder *)
        cfg.autowrap:= FALSE;
        AddInsert;
        cfg.autowrap:= ok;
        Lineptrs(line + curdispline);
        Display(curdispline, cfg.maxdispline);
        SetFoundPos(FALSE, TRUE); (* don't force to top of window *)
        SetSlideSize;
        SetSlidePos;
        NotiChar;
      ELSE (* just enter the LF char *)
        AddInsert;
      END; (* if was CR before this LF *)
(*213*)
    ELSIF kreturn = 00F09H THEN                          (* Tab *) (* 11C *)
      (* Kbshift(int); *)(* SampleKeyboard(VDIHandle, int); *)
      IF (int = 0) OR (int = 16) THEN (* no shift/cntrl/alt keys pressed *)
        k:= cfg.tabspaces - (linepos MOD cfg.tabspaces);
        j:= 0;
        IF cfg.insertmode THEN (* insert spaces to next tabstop *)
          newchar:= 40C;
          REPEAT
            AddInsert; (* DoAscii; *)
            INC(j);
          UNTIL (j = k) OR (linepos = 0); (* stop if hit start of line *)
        ELSE (* overwrite *) (* skip over chars to next tabstop *)
          REPEAT
            Rtarrow;
            INC(j);
          UNTIL (j = k) OR (linepos = 0); (* stop if hit start of line *)
        END; (* if insert or 'overwrite' tab *)
(*ds*)
      ELSIF 2 IN BITSET(int) THEN (* cntrl key pressed *)   (* Ctl-Tab *)
        ok:= Tabtospace();
      ELSE (* ANY shift/alt/cntrl key(s) pressed *)         (* Alt-Tab *)
        TabSet;
(*ds*)
      END;
    ELSIF kreturn = 0011BH THEN                    (* Escape *) (* 33C *)
      (* Kbshift(int); *)(* SampleKeyboard(VDIHandle, int); *)
      IF (int = 0) OR (int = 16) THEN (* no shift/cntrl/alt keys pressed *)
        DoQuit; (* also handles turning on/off mouse *)
      ELSE (* ANY shift/alt/cntrl key(s) *)
        AddInsert; (* DoAscii; *) (* output esc char *)
      END; (* if no alt etc key pressed with esc *)
    ELSIF kreturn = 04818H THEN                   (* shift-ctl-uparrow *)
      Slide(Window1, 0);
    ELSE (* other control char, including RETURNKEY *)
      IF (newchar = 15C) THEN (* CR or keypad Enter *)
(*
      IF (newchar = 15C) & (3 IN BITSET(int)) THEN (* Alt-CR or Alt-Enter *)
*)
        IF BITSET(int) * BITSET(03H) <> {} THEN (* A Shift key pressed *)
          IF (3 IN BITSET(int)) THEN (* Alt-shift-CR *)
            TypeInit; (* set typeahead on/off *)
          ELSE (* just shift-CR or ctl-shift-CR *)
            TypeAhead(line+curdispline); (* to Stalker or outdev *)
          END;
        ELSE (* unshifted CR *)
          IF (3 IN BITSET(int)) THEN (* Alt-CR or Alt-Enter *)
            cfg.autoindent:= NOT cfg.autoindent;
          END;
          IF (typeahead > 0C) & (blocktype > 0) THEN
            TypeAhead(line+curdispline); (* to Stalker or outdev *)
          ELSE (* normal *)
            AddInsert;
          END; (* if typeahead block *)
        END; (* if shifted alt *)
      ELSE
        AddInsert; (* 3.21 *)
      END; (* if 15C *)
    END; (* case of ctrl chars *)
  ELSE (* delete,shift-home,-arrow,-insert,-delete *)
    tmpln:= line + curdispline;
    longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
    IF kreturn =  0537FH THEN                                (* Delete *)
      (* Kbshift(int); *)(* SampleKeyboard(VDIHandle, int); *)
      IF blocktype > 0 (* isblock *) THEN (* delete block *)
        DoCut(1); (* to buffer *)
      ELSE
        IF (int = 0) OR (int = 16) THEN (* no shift/cntrl/alt keys pressed *)
          DeleteChar;
        ELSIF 3 IN BITSET(int) THEN                              (* Alt-Delete *)
          DelToEnd(tmpln);
        ELSIF BITSET(3) * BITSET(int) <> {} THEN               (* Shift-Delete *)
          DeleteLine(tmpln);
        END; (* if *)
      END; (* if isblock *)
    ELSIF kreturn = 04D36H THEN                          (* ShiftRtArrow *)
      linepos:= SHORT(Findend(tmpln) - longptr^);
      i:= longptr^ + LONG(linepos);
      j:= startcol;
      Findscrn(linepos); (* sets startcol *)
      IF j <> startcol THEN
        Display(0, cfg.maxdispline);
        SetHSlidePos;
      END; (* if shift screen *)
      DEC(linepos, startcol);
      CursorPos(curdispline, leftedge+linepos);
    ELSIF kreturn = 04B34H THEN                     (* ShiftLeftArrow *)
      linepos:= 0;
      i:= longptr^;
      CheckStart; (* NOTE: this can change cardptr, which is global *)
      CursorPos(curdispline, leftedge);
    ELSIF kreturn = 04737H THEN                     (* Shift-ClrHome *)
      IF startf + i > 0 THEN (* not at buffer top, so go there *)
        Slide(Window1, 0);
      ELSE (* at top, so go to bottom of buffer *)
        Slide(Window1, 1000);
      END; (* if not at top *)
    ELSIF kreturn = 05032H THEN                     (* ShiftDownArrow *)
(**
      IF (2 IN BITSET(int)) THEN                 (* Ctl-shift-downarrow *)
        Slide(Window1, 1000);
      ELSE (* no ctl *)
**)
        IF i < last THEN
          PageDown;
        ELSE
          IF Title1[1] = ':' THEN (* disk sectors *)
            ok:= PageDisk(TRUE); (* forward *)
          ELSIF Title1[3] = ':' THEN (* RAM *)
            PageRam(TRUE);
          ELSE (* file *)
            IF (endf < fileend) THEN
              IF PageBigFile(TRUE, TRUE) THEN (* forward, asksave? *)
                ShowNew;
              END;
            END; (* if more bigfile *)
          END; (* if *)
        END; (* if paging needed *)
(**
      END; (* if ctl *)
**)
    ELSIF kreturn = 04838H THEN                       (* ShiftUpArrow *)
(**
      IF (2 IN BITSET(int)) THEN                      (* Ctl-shift-uparrow *)
        Slide(Window1, 0);
      ELSE (* no ctl *)
**)
        IF i > 0 THEN
          PageUp;
        ELSE
          IF Title1[1] = ':' THEN (* disk sectors *)
            ok:= PageDisk(FALSE); (* backward *)
          ELSIF Title1[3] = ':' THEN (* RAM *)
            PageRam(FALSE);
          ELSE (* file *)
            IF (startf > 0) THEN
              IF PageBigFile(FALSE, TRUE) THEN (* backward, asksave? *)
                ShowNew;
              END;
            END; (* if startf > 0 *)
          END; (* if *)
        END; (* if paging needed *)
(**
      END; (* if ctl *)
**)
    ELSIF kreturn = 05230H THEN                         (* Shift-Insert *)
      Pasteblock;
    ELSIF ((kreturn = 04E2BH) & (3 IN BITSET(int))) THEN     (* Alt-[pad +] *)
      KeyFont(TRUE); (* inc *)
    ELSIF ((kreturn = 04A2DH) & (3 IN BITSET(int))) THEN     (* Alt-[pad -] *)
      KeyFont(FALSE); (* dec *)
    ELSIF kreturn = 07737H THEN (* 3.11 *)            (* shift-Ctl-ClrHome *)
      IF startf + i > 0 THEN (* not at buffer top, so go there *)
        Slide(Window1, 0);
      ELSE (* at top, so go to bottom of buffer *)
        Slide(Window1, 1000);
      END; (* if not at top *)
    ELSE
      AddInsert; (* DoAscii; *)
    END; (* case of shift-home, etc *)
  END; (* if ascii or shift-home etc. *)
END Key;

PROCEDURE FindMouse(x,y: INTEGER);
(* finds i, linepos, and curdispline, moves scrn left/right if needed *)
BEGIN
  linepos:= Findxpos(x);
  curdispline:= Finddispline(y, TRUE);
  Downup; (* sets i & cursorpos & shifts scrn if needed *)
END FindMouse;

PROCEDURE Button(mX, mY: INTEGER; altclick: BOOLEAN);
(* process mouse button clicks & drags *)
VAR oldindex, startb, endb, oldi: LONGCARD; (* were CARDINAL; *)
    newblock: BOOLEAN;
    mXptr, mYptr: POINTER TO INTEGER;
BEGIN (* main Button *)
  IF (mY <= workY + workH) & (mY >= workY) &
     (mX >= workX) & (mX <= workX + workW) THEN
    (* is in text window *)
    FindMouse(mX, mY); (* finds i, linepos, curdispline, sets cursorpos *)
(**+
    IF (mX < workX + 5) & (startcol > 0) THEN (* clicked by left edge of window *)
      ScrnLeft(10);
     ELSIF (mX > workX+workW-4) THEN (* clicked by right edge of window *)
      ScrnRt(10); (* sets new i *)
    END;
+**)
    oldindex:= i;
    oldi:= i;
    newblock:= TRUE;
    mXptr:= lineAadr - ADDRESS(602); (* cur_x *)
    mYptr:= ADDRESS(mXptr) + 2; (* cur_y *)

    Showmouse; (* lineA Show mouse *)
    WindowUpdate(3); (* take full mouse control from GEM *)

    LOOP (* track what happens while button is held down *)

      IF NOT(0 IN BITSET(ORD(mstatptr^))) THEN (* left button now up *)
        (* clear the button event that must have occurred *)
        EXIT;
      END; (* if exit, button released *)

      (* else mouse moved, or held down outside text area of work area *)

      (* get mouse coords *)
      mX:= mXptr^;
      mY:= mYptr^;
      CODE(0A00AH); (* lineA Hide mouse *)
      FindMouse(mX, mY); (* gets i, linepos, curdispline, sets proper screen *)
      Showmouse; (* lineA Show mouse *)
      IF mX >= workX+workW-1 THEN (* shift screen right *)
        CODE(0A00AH); (* lineA Hide mouse *)
        ScrnRt(10); (* sets new i *)
        Showmouse; (* lineA Show mouse *)
        (* position mouse at left margin ? maybe in later version. *)
      ELSIF mX < workX+2 THEN (* shift screen left *)
        CODE(0A00AH); (* lineA Hide mouse *)
        ScrnLeft(10); (* sets new i *)
        Showmouse; (* lineA Show mouse *)
      ELSIF (mY >= workY + workH-1) & (lastline > line + cfg.maxdispline) THEN (* shift screen down *)
        CODE(0A00AH); (* lineA Hide mouse *)
        Scrolldown;
        Showmouse; (* lineA Show mouse *)
        FindMouse(mX, mY);
      ELSIF (mY < workY) & (line > 0) THEN (* shift screen up *)
        CODE(0A00AH); (* lineA Hide mouse *)
        Scrollup;
        Showmouse; (* lineA Show mouse *)
        FindMouse(mX, mY);
      END; (* if page right or down *)
(**)
      WindowUpdate(0);
(**)
      IF i <> oldi THEN (* effective mouse motion *)
        (* block routine #1 *)
        IF newblock THEN (* prepare to set new block *)
          IF blocktype > 0 (* isblock *) THEN (* un-hilite old block *)
            CODE(0A00AH); (* lineA Hide mouse *)
            ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
            Showmouse; (* lineA Show mouse *)
          END;  
(*
          blocktype:= 0; (* isblock:= FALSE; *)
*)
          newblock:= FALSE;
          blockstart:= oldindex;
          blockend:= oldindex;
        END; (* if erase old block *)          
        (* calc incremental area to hilite/unhilite *)
        blocktype:= 1;
        IF altclick THEN
          blocktype:= 2; (* colblock *)
        END;
        startb:= i;
        endb:= i;

        IF blocktype = 1 THEN (* normal block *)
          IF (i > blockstart) & (blockstart < oldindex) THEN
            startb:= blockstart;
            (* endb:= i; *)
          ELSIF (i < blockend) & (blockend > oldindex) THEN
            (* startb:= i; *)
            endb:= blockend;
          ELSIF (i < blockstart) THEN
            (* startb:= i; *)
            endb:= blockstart;
          ELSIF (i > blockend) THEN
            startb:= blockend;
            (* endb:= i; *)
          END; (* if i in various places, set block redraw limits *)
        ELSE (* blocktype = 2 colblk *)
          (* unmark entire old block, mark entire new block *)
          CODE(0A00AH); (* lineA Hide mouse *)
          ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
          Showmouse; (* lineA Show mouse *)
          IF i > oldindex THEN
            startb:= oldindex; (* original blockstart *)
            (* endb:= i; *)(* new blockend *)
          END;
        END; (* if blocktype *)

        (* hilites or unhilites incremental area *)
(****** test **)
          IF (blocktype = 1) OR (i > oldindex) THEN
(** test ******)
          CODE(0A00AH); (* lineA Hide mouse *)
          ShowBlock(line, line+cfg.maxdispline, startb, endb);
          Showmouse; (* lineA Show mouse *)
(****** test **
        ELSE (* blocktype <> 1 & i <= oldindex *)
          blocktype:= 0; (* isblock:= FALSE; *)
** test ******)
        END; (* if *)
(** test ******)
  
        blockstart:= oldindex;
        blockend:= i;
(***
        IF oldindex <> i THEN (* a block has been marked *)
          BlockCheck; (* did set isblock & switches start/end if needed *)
***)
        IF (oldindex = i) OR ((blocktype = 2) & (i < oldindex)) THEN
(****** test **
        ELSE (* i = oldindex *)
****** test **)
          newblock:= TRUE;
          blocktype:= 0; (* isblock:= FALSE; *)
          notistrg:= 0C;
          CODE(0A00AH); (* lineA Hide mouse *)
          InitMenu; (* get rid of BLOCK msg *)
          Showmouse; (* lineA Show mouse *)
        ELSE (* oldindex <> i, etc. *)
          BlockCheck; (* did set isblock & switches start/end if needed *)
(****)
        END; (* if new block marked *)
        oldi:= i;
      END; (* if mouse moved to new i *)
(**)
      WindowUpdate(1);
(**)
    END; (* loop *)
    WindowUpdate(2); (* return mouse control to GEM *)
    CODE(0A00AH); (* lineA Hide mouse *)
  END; (* if in text window *)
END Button;

PROCEDURE Slide(window, pos: INTEGER);
VAR 
    wantind, tmplast (*, startftmp, endftmp *) : LONGCARD;
BEGIN (* main slide *)
  IF (startf > 0) OR (endf < fileend) THEN (* bigfile *)
    tmplast:= fileend; (* 3.11 *)
  (**)
    IF last > lasti THEN
      INC(tmplast, last - lasti);
    ELSE
      DEC(tmplast, lasti - last);
    END;
  (**)
    wantind:= LONGCARD(pos) * tmplast DIV 1000;
    IF wantind > tmplast THEN
      wantind:= tmplast;
    END;   
    IF GotoBigInd(wantind) THEN
      SetSlidePos;
      IF pos > 0 THEN
        Bottom; (* 3.02 *)
      ELSE
        CursorPos(curdispline, leftedge + linepos); (* setfoundpos *)
      END;
    END;
  ELSE (* not bigfile *)
    IF (lastline > cfg.maxdispline) OR
     ((pos = 0) & (i > 0)) THEN (* is a reason to slide *)
      dummy:= 0;
      line:= SHORT(LONGCARD(pos) * LONG(lastline - cfg.maxdispline) DIV 1000);
      startcol:= 0;
      IF line = 0 THEN (* slide to top *)
        i:= 0;
        linepos:= 0;
        curdispline:= 0;
        Display(0, cfg.maxdispline);
      ELSE (* set cursor to bottom of any other screen *)
        Display(0, cfg.maxdispline);
      END; (* if at top or not *)
      SetSlidePos;
      SetHSlidePos;
    END; (* if can slide *)
    IF (line <> 0) OR (pos = 1000) THEN
      Bottom; (* 3.02 *)
    END;
  END; (* if bigfile *)
END Slide;


PROCEDURE HSlide(window, pos: INTEGER);
VAR newstart, ln: CARDINAL;
BEGIN
  dummy:= 0;
  newstart:= SHORT(LONGCARD(pos) * LONG(lastcol (* - displaylen *) ) DIV 1000);
  IF newstart <> startcol THEN (* was moved *)
    startcol:= newstart;
    ln:= line + curdispline;
    longptr:= lnptradr + ADDRESS(4*LONG(ln)); (* x4 for 4 bytes/index *)
    IF startcol = 0 THEN (* slide full left *)
      linepos:= 0;
      i:= longptr^;
    ELSE (* check cursor/linepos, linelen *)
      (** need to set cursor **)
      (* 1st check if startcol > end of line *)
      tmplong:= Findend(ln);
      j:= SHORT(tmplong - longptr^); (* linelen *)      
      k:= SHORT(i - longptr^);
      IF j < startcol THEN (* line length < startcol, so startcol:= linelen *)
        startcol:= j;
        linepos:= 0;
        i:= tmplong;
      ELSIF k > startcol + displaylen THEN (* shift cursor left *)
        i:= longptr^ + LONG(startcol + displaylen);
        linepos:= displaylen;
      ELSIF k < startcol THEN (* shift cursor right into window *)
        i:= longptr^ + LONG(startcol);
        linepos:= 0;
      ELSE (* cursor already in desired window *)
        linepos:= k - startcol;
      END; (* if need to shift startcol left to find eol *)
    END; (* if at top or not *)
    Display(0, cfg.maxdispline);
    CursorPos(curdispline, leftedge + linepos);
    SetHSlidePos;
  END; (* if was motion *)
END HSlide;
(*******)

PROCEDURE WantAbort(ask: BOOLEAN): BOOLEAN;
VAR key: CARDINAL;
BEGIN
  IF Bcosstat(2,1) THEN (* console(2) has waiting input(1) *)
    (* for input, FALSE means char(s) waiting *)
    key:= SHORT(BconinGetBPB(2, 2) DIV 010000H);
    IF (key = 1) OR (key = 061H) THEN 
      (* esc or undo: Abort from printout or other operation *)
      (* dev: 0=PRN, 1=AUX, 2=CON, 3=MIDI, 4=IKBD, 5=256 chars *)
      (* opcode: 7 = GetBPB, 2 = bconin *)
      IF ask THEN
        dummy:= FormAlert(1, "[2][ Abort Operation ?][Abort|Continue]");
      END; (* if ask *)
      IF ((NOT ask) OR (dummy = 1)) THEN
        RETURN TRUE; (* Abort! *)
      END;
    END; (* if esc or undo *)
  END; (* if keypressed *)
  RETURN FALSE; (* no abort *)
END WantAbort;

PROCEDURE WrapMult(j, k: CARDINAL);
BEGIN
  REPEAT
    j:= Wrapblock(j, k);
    INC(j);
  UNTIL j >= k;
END WrapMult;

PROCEDURE WrapMarked;
VAR j, k: CARDINAL;
BEGIN
  IF blocktype > 0 (* isblock *) THEN
    i:= blockstart;
    SetFoundPos(FALSE, TRUE); (* don't forcetop *)
    j:= Findline(blockstart);
    k:= Findline(blockend);
    (* KEEP longptr global for this! *)
    IF (blockend > longptr^) & (k < lastline) THEN
      INC(k);
    END;  (* Pattie fix, 2.30 1/19/92 *)
    WrapMult(j, k);
  ELSE
    BlockAlert;
  END; (* if wrap marked block *)
END WrapMarked;


PROCEDURE SelectMenu(Menu, Item: INTEGER) ;
VAR start, end, jlong: LONGCARD; (* 32 bit.  print limiters *)
    startbcol, endbcol: CARDINAL;  (*+ 2.4 +*)
    j,k: CARDINAL; (* 2.30 1/9/92 *)
BEGIN (* main SelectMenu *)
(***
  timeout:= 12000; (* for printer/modem output *)
***)  CASE Menu OF
(*
    DESKMENU : 
            IF Item = ABOUT THEN
              Showmouse; (* lineA Show mouse *)
              result:= FormAlert(1,'[1][EdHak v 3.0  by Craig Harvey|Clear Thinking|PO Box 715|Ann Arbor, MI 48105][ OK ]');
              CODE(0A00AH); (* lineA Hide mouse *)
            END ;
            (* put header back normal.  put at end of SelectMenu if use real appl *)
            MenuTitleNormal(MenuTree, Menu, 1) ; (* deselects selected item *)
  |
*)
    FILEMENU :
      CASE Item OF
(*
        SAVE : ok:= Savefile(TRUE); (* ask questions *)
*)
      | OPEN :
          IF SaveCheck(TRUE, TRUE) THEN (* askbig & asksave *)
            ok:= Getfile();
          END; (* if not cancel or error on save *)
(*
      | HELP : DoHelp;
*)
(*
      | CONFIG :
          IF (NOT Config() ) THEN
            result:= FormAlert(1,"[1][New config NOT done][OK]");
          END; (* if did config *)
*)
(*
      | QUIT : DoQuit;
*)
      ELSE (* other file command? *)
      END; (* file menu *)
  | EDITMENU :
      CASE Item OF
      (*ds*)
        WRAP : 
          Showmouse; (* lineA Show mouse *)
          result:= FormAlert(1, alertstrg2);
          CODE(0A00AH); (* lineA Hide mouse *)
          IF result <> 2 THEN (* do it *)
            IF result = 1 THEN (* wrap now... *)
              result:= 3; (* default to wrap all *)
              IF cfg.eollen > 0 THEN
                int:= 2;
                IF blocktype > 0 (* isblock *) THEN
                  int:= 1; (* default to block *)
                END;
                Showmouse; (* lineA Show mouse *)
                result:= FormAlert(int,"[2][       Wrap how far ?      ][Block|P'graph|ALL]");
                CODE(0A00AH); (* lineA Hide mouse *)
              END; (* if hack mode wrap all *)
              j:= line + curdispline;
              IF result = 1 THEN  (* wrap block; was single line *)
                WrapMarked;
              ELSIF result = 2 THEN (* paragraph *)
                k:= 0FFFFH;
                j:= Wrapblock(j, k);
              ELSE (* result = 3, wrap all *)
                k:= lastline;
                WrapMult(j, k);
              END; (* if just Pgraph *)
              saved:= FALSE;
              pastelen:= 0; (* since wrap destroyed paste buffer in newlnptrs *)
              Display(curdispline, cfg.maxdispline);
              Bottomstay; (* Display(0); *)
            ELSE  (* result = 3, toggle autowrap *)
              cfg.autowrap:= NOT(cfg.autowrap);
              WrapCheck;
            (*
              IF cfg.autowrap THEN
                Concat(alertstrg1, alertstrg3, alertstrg2); (* turn OFF *)
              ELSE
                Concat(alertstrg1, alertstrg4, alertstrg2); (* turn ON *)
              END; (* if toggle autowrap *)
            *)
            END; (* if wrap now... *)
          END; (* if not cancel *)
      (*ds*)
      | CLEARBUF : 
          Showmouse; (* lineA Show mouse *)
          result:= FormAlert(1,"[2][Really ERASE EVERYTHING ?][Yes|Cancel]");
          CODE(0A00AH); (* lineA Hide mouse *)
          (* 2.25 *)
          IF (result = 1) & SaveCheck(TRUE, TRUE) THEN
            (* Wipe! *)
            ClearAll(TRUE);
            (** 3.2 **)
            cfg.fsel0:= 'NEWFILE.TXT';
            MoveMem(ADR(cfg.fsel0), ADR(Title1), LONG(Length(cfg.fsel0)+1));
            InitMenu;
            (** 3.2 **)
          END; (* if wipe *)
      ELSE (* other edit command? *)
      END; (* edit case *)
  | PRNTMENU :
     (* 2.15.. stat should be after each char or line *)
(*ds*)
      int:= 1; (* default = All *)
      IF blocktype > 0 (* isblock *) THEN
        int:= 2; (* set default button to Block *)
      END;
      result:= 2; (* default to PRNTBLK *)
      IF Item = PRNTALL THEN (* ask & allow cancel *)
        Showmouse; (* lineA Show mouse *)
        result:= FormAlert(int, "[2][ Print/send what?|(Esc/Undo aborts)][All|Block|Cancel]");
        CODE(0A00AH); (* lineA Hide mouse *)
      END; (* if ask what to print *)
      startbcol:= 0;
      endbcol:= 0FFH;
      CASE result OF (* Item OF *)
        2: (* PRNTBLK: *)
           IF blocktype > 0 (* isblock *) THEN
             start:= blockstart;
             end:= blockend;
      (**+*)
             IF blocktype = 2 THEN (* colblk *)
               longptr:= lnptradr + ADDRESS(4*LONG(Findline(start)));
               startbcol:= SHORT(start - longptr^);
               longptr:= lnptradr + ADDRESS(4 * LONG(Findline(end)));
               endbcol:= SHORT(end - longptr^);
             END;
      (*+**)
           ELSE
             BlockAlert;
             result:= 3; (* force cancel 3.2a *)
           END;
      | 1: (* PRNTALL: *)
      (*ds*)
           start:= 0;
           end:= last;
      (*ds*)
      ELSE (* other print command? *)
           (** ADD PRINT FILE ? **)
      END; (* case *)
      IF result <> 3 THEN (* not cancel *)
        result:= 0; (* default no metering *)
        IF outdev = 1 THEN (* serial port *)
          Showmouse; (* lineA Show mouse *)
          result:= FormAlert(1, "[2][ Metered output?][No|Med|Slow]");
          CODE(0A00AH); (* lineA Hide mouse *)
          DEC(result);
        END; (* if user wants metering *)
        Showmouse; (* lineA Show mouse *)
        GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)
        ok:= TRUE; (* at start *)
        (*test*)
(*
        IF outdev = 3 THEN
          ok:= FALSE; (* so doesn't send left margin spaces at start *)
        END; (* if to midi port *)
*)
        (*test*)
        LOOP
          IF Bcosstat(outdev,8) THEN (* printer/modem ready to start *)
          (* outdev 0=printer/1=modem is ready 8=output, 1=input *)
          (**)
            IF outdev <> 3 THEN (* not midi *)
              k:= 0; (* counter for string *)
              WHILE cfg.printinit[k] <> 0C DO
                Bconout(cfg.printinit[k], outdev);
                INC(k);
              END;
            END; (* if not midi *)
(*ds*)
            tmplong:= start; (* tmplong was j *)
            ptr1:= startadr + ADDRESS(tmplong);
            WHILE tmplong < end DO (* this way 'end' doesn't get printed *)
              IF WantAbort(TRUE) THEN (* true = ask *)
                EXIT;
              END;

              IF (outdev <> 3) & (ok OR ((ptr1^ = 12C) & (tmplong < end))) THEN (* LF character = end of line *)
                ok:= FALSE; (* no longer at start of job *)
                jlong:= tmplong; (* tmp holder for start of line *)
                k:= 0;
                j:= 0; (* col blk counter *)
                WHILE k < cfg.printmargin DO (* space over to margin *)
                 (* IF Bcosstat(outdev,8) THEN *)
                  Bconout(' ', outdev); (* space *)
                  INC(k);
                END; (* while printing spaces *)
                INC(tmplong, startbcol); (* for col block *)
                INC(j, startbcol);
              END; (* if send margin spaces at start of line *)

              FOR k:= 0 TO result * 6000 DO
              END; (* delay loop *)

              ptr1:= startadr + ADDRESS(tmplong);
              ch:= ptr1^;
              IF (SHORT(tmplong - jlong) < endbcol) OR
                 (ptr1^ = 15C) OR (ptr1^ = 12C) THEN (* for col blks *)
                Bconout(ch, outdev);
              END;
              INC(tmplong);
            END; (* while print start to end *)
            IF outdev <> 3 THEN (* do final cr/lf if not midi port *)
              k:= 0; (* counter for string *)
              WHILE cfg.printend[k] <> 0C DO
                Bconout(cfg.printend[k], outdev);
                INC(k);
              END;
            END; (* if need final cr/lf *)
(*ds*)
            EXIT; (* from loop after completing printing *)
          ELSE (* printer not ready *)
            GrafMouse(GEMAESbase.Arrow, NIL); (* arrow *)
            dummy:= FormAlert(1, "[1][Device not Responding][Retry|Abort]");
            GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)
            IF dummy = 2 THEN  (* abort; else keep looping *)
              EXIT;
            END; (* if abort *)
          END; (* if printer ready at first *)
        END; (* loop *)
        GrafMouse(GEMAESbase.Arrow, NIL); (* arrow *)
        CODE(0A00AH); (* lineA Hide mouse *)
      END; (* if not canceled *)
 (*
 | HELPMENU :
               result:= FormAlert(1,"[0][ Ack! I'm helpless!! ][OK]");
  *)
  ELSE (* other menu? *)
  END; (* case of menus *)
END SelectMenu ;


PROCEDURE Arrow(window, action: INTEGER);
(* mouse clicked on vert or horiz scroll bar *)
VAR tmpW: INTEGER;
    shiftcols: CARDINAL;
BEGIN
  CASE pipeBuff[4] OF (* action *)
    0: (* IF line > 0 THEN *)(* page up *)
         PageUp;
  | 1: (* IF lastline - line >= cfg.maxdispline THEN *) (* page down *)
         PageDown;
  | 2: (* arrow up *)
       IF i > 0 THEN  (* see if need/want to pagebigfile *)
         curdispline:= 0;
         IF line > 0 THEN   (* 1 line up, i.e., move text down *)
           Scrollup; (* also dec's line & setsslidepos *)
         END; (* if line > 0 *)
         ClrHome;
       ELSE (* i = 0 *)
         IF Title1[1] = ':' THEN (* disk sectors *)
           ok:= PageDisk(FALSE); (* backward *)
         ELSIF Title1[3] = ':' THEN (* RAM *)
           PageRam(FALSE);
         ELSE (* file *)
           IF (startf > 0) & PageBigFile(FALSE, TRUE) THEN (* backward, ask *)
             ShowNew;
           END;
         END; (* if *)
       END; (* if page bigfile or scroll up *)
  | 3: (* arrow down *)
       IF i < last THEN
         IF line + curdispline < lastline THEN
           IF lastline - line > cfg.maxdispline THEN (* 1 line down, text up *)
             Scrolldown; (* also inc's line & sets slidepos *)
           END;
           Bottom; (* cursor to bottom of window *)
         ELSE (* at lastline *)
           Rtarrow;
         END;
       ELSE (* i >= last *)
         IF Title1[1] = ':' THEN (* disk sectors *)
           ok:= PageDisk(TRUE); (* forward *)
         ELSIF Title1[3] = ':' THEN (* RAM *)
           PageRam(TRUE);
         ELSE (* file *)
           IF (endf < fileend) & PageBigFile(TRUE, TRUE) THEN (* forward, asksave? *)
             ShowNew;
           END;
         END; (* if *)
       END; (* if i < last *)
    (* start horiz functions *)
  | 4: (* page left *)
         ScrnLeft(pageW); (* 20? *)
  | 5: (* page right *)
         ScrnRt(pageW);
  | 6: (* left arrow *)
       IF startcol > 0 THEN (* can shift left *)
         shiftcols:= 2;
         IF startcol = 1 THEN (* can only shift 1 column *)
           shiftcols:= 1;
         END;
         DEC(startcol, shiftcols);
(*
         Display(0, cfg.maxdispline); (* easy way out, instead of blit *)
*)
(* 3.02 *)
         IF Window1 = topwind THEN
           tmpW:= INTEGER(shiftcols) * colW + colW;
           Blit(workX+colW-1, workY, workW-tmpW, workH, workX+tmpW-1, workY);
           SetClipFill(workX, workY, tmpW, workH, TRUE);
           SetClipping(VDIHandle, 1, clipxy2);
         END;
         Display(0, cfg.maxdispline);
         SetClipFill(1,1, fullW, maxY, TRUE);
         SetClipping(VDIHandle, 1, clipxy2);
(**)
         (* handle if cursor moved off screen *)
(**
         linepos:= SHORT(Findend(tmpln) - longptr^) - startcol;
**)
         INC(linepos, shiftcols);
         IF linepos > displaylen THEN
           DEC(linepos, shiftcols);
           DEC(i, LONG(shiftcols));
         END; (* if need to reposition cursor *)
         CursorPos(curdispline, leftedge+linepos);
         SetHSlidePos;
       END; (* if scroll left *)
  | 7: (* right arrow *)
       tmplong:= Findend(line + curdispline);
       longptr:= lnptradr + ADDRESS(4*LONG(line + curdispline));
       j:= SHORT(tmplong - longptr^); (* linelen *)
       IF startcol < j THEN (* can shift right *)
         shiftcols:= 2;
         IF startcol = j-1 THEN (* can only shift 1 column *)
           shiftcols:= 1;
         END;
         INC(startcol, shiftcols);
(*
         Display(0, cfg.maxdispline); (* easy way out, instead of blit *)
*) (* 3.02 *)
         IF Window1 = topwind THEN
           tmpW:= INTEGER(shiftcols) * colW + colW;
           Blit(workX+tmpW, workY, workW-tmpW-1, workH, workX+colW, workY);
           SetClipFill(workX+workW-tmpW, workY, tmpW, workH, TRUE);
           SetClipping(VDIHandle, 1, clipxy2);
         END;
         Display(0, cfg.maxdispline);
         SetClipFill(1,1, fullW, maxY, TRUE);
         SetClipping(VDIHandle, 1, clipxy2);
(**)
         (* handle if cursor moved off screen *)
         IF linepos >= shiftcols THEN
           DEC(linepos, shiftcols);
         ELSE
           INC(i, LONG(shiftcols));
         END; (* if need to reposition cursor *)
         CursorPos(curdispline, leftedge+linepos);
         SetHSlidePos;
       END; (* if scroll right *)
(*
  ELSE (* for safety *)
*)
  END; (* case for Window1 arrows *)
END Arrow;

PROCEDURE Capture(doshow: BOOLEAN); (* BOOLEAN; *)
VAR tmpline: CARDINAL;
    tmpint, topx,topy,topw,toph,wx,ww,wy,wh: INTEGER; (* top window coords *)
    autoappend, tmpbig: BOOLEAN;
    tmplong: LONGCARD;
    fromptr: POINTER TO CHAR;
(*
    savemouse: INTEGER;
*)
  PROCEDURE CapCopy;
  BEGIN
    ptr2:= startadr + ADDRESS(last);
    MoveMem(fromptr, ptr2, tmplong); (* append text *)
    INC(lastline);
    INC(ptr2, tmplong); (* ptr1:= startadr + ADDRESS(last); *)(* new last *)
    INC(tmplong, 2); (* for cr/lf *)
    INC(last, tmplong);
    ptr2^:= 15C; (* CR *)
    INC(ptr2);
    ptr2^:= 12C; (* LF *)

   (** Now display... **)
   (* set new lnptr for start of new line *)
    longptr:= lnptradr + ADDRESS(lastline+lastline+lastline+lastline);
    longptr^:= last;
(*
    linepos:= 0; (* ahh! delete, 1/20/92 *)
*)
    saved:= FALSE;

    tmpline:= lastline - line - 1; (* lastline was already inc'd so safe *)
    IF doshow & (tmpline <= cfg.maxdispline) THEN (* show in window *)
      WindowGet(topwind, GEMAESbase.CurrXYWH, topx,topy,topw,toph);
      CursorPos(tmpline, leftedge);
      IF (vcury > topy+toph) OR (vcury+rowH < topy) THEN
        Lineout(lastline-1, 0, displaylen);
      END; (* if ok to output line *)
      CursorPos(curdispline, leftedge+linepos); (* reset cursor to i *)
    END; (* if we're in the window *)
    (** Tell Stalker we're done with its buffer **)
    pipeBuff[0]:= -1000; (* -STENO_APPEND_LINE;*) (* -1000 *)
  END CapCopy;

BEGIN (* main capture *)
  stalkID:= pipeBuff[1];  (* Stalker appl ID *)
  tmplong:= Swapadd(0, pipeBuff[5]);
  fromptr:= ADDRESS(Swapadd(pipeBuff[3], pipeBuff[4]));
  (* +2 for cr/lf added 2/1/92 *)
  IF last + tmplong +2 < buffsize THEN (* is room for added text *)
    CapCopy;
  ELSE (*** buffer full, warn Stalker not to send more ***)
(*
    savemouse:= mhideptr^;
*)
    Bconout(7C, 2); (* bell $07 to console device *)
    autoappend:= FALSE;
    IF Compare(cfg.fsel0, 'CAPTURE.TXT') THEN
      autoappend:= TRUE;
    END;
    dummy:= 1; (* default to save *)
    tmpint:= 2; (* default to force append *)
    IF NOT autoappend THEN
(**
      mhideptr^:= 1; (* was 1 *)
**)
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1,'[2][Buffer Full|Save to disk?][OK|Cancel]');
      CODE(0A00AH); (* lineA Hide mouse *)
      tmpint:= 0; (* ask append, o/w *)
    END; (* if ask *)
    ok:= FALSE; (* 3.12 *)
    IF dummy = 1 THEN (* let user save capture and keep capturing *)
      IF autoappend THEN (* 3.12 *)
        bigpart:= FALSE;
      END;
      ok:= Savefile(NOT(autoappend), tmpint); (* ask? questions; force append *)
      IF ok & autoappend THEN (* 3.12 *)
        bigpart:= TRUE;
      ELSE
        bigpart:= tmpbig;
      END;
    END; (* if save *)    

    IF NOT autoappend THEN
(**
      mhideptr^:= 1; (* was 1 *)
**)
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1,'[2][Clear Buffer|& Resume Capture?][OK|Cancel]');
      CODE(0A00AH); (* lineA Hide mouse *)
    END; (* if ask append *)

    IF (dummy = 1) OR (autoappend & ok) THEN  (* ok is 3.12 *)
(**
      ClearAll(TRUE); (* newfile *)
**)
      ClearAll(NOT autoappend); (* if capture.txt, treats as bigfile *)
(**)
      IF doshow THEN
        WindowGet(Window1,GEMAESbase.FirstXYWH, wx,wy,ww,wh);
        (* Windfix;(**??**) *)
        WHILE (ww > 0) & (wh > 0) DO
          (** 2.30 1/18/92 ??? *)
          (* IS something sticking out *)
          SetClipFill(wx, wy, ww, wh, FALSE);
          WindowGet(Window1, GEMAESbase.NextXYWH, wx,wy,ww,wh);
        END; (* while checking for rectangles to redraw *)
      END;
      (* get line that otherwise would be lost  1/1/92 *)
      CapCopy;
    ELSE (* just turn off capture and leave full *)
      pipeBuff[0]:= 9999; (* BUFFER_FULL; *)(* 9999 *)
    END; (* if buffer full *)
(*
    mhideptr^:= savemouse;
*)
(**
      mhideptr^:= 0; (* 0 w/just A009 allows mouse to disappear *)
**)
      Showmouse; (* added 3.2g *)
  END; (* if room for text *)
  (* Set mouse to however it was *)
  pipeBuff[1]:= Appl; (* EdHak application ID *)
  pipeBuff[2]:= 0; (* excess message length *)
  ApplWrite(stalkID, 16, ADR(pipeBuff)); (* std 16 byte msg *)
END Capture;


(**********************************************************************)
(* -----------------  Start EVENTS  --------------------------------- *)

PROCEDURE MainMenu(int: INTEGER);
BEGIN
  CASE int OF
  | OPEN: SelectMenu(FILEMENU, OPEN);
  | SAVE: ok:= Savefile(TRUE, 0); (* ask questions, no force overwrite or append *)
  | HELP: DoHelp; (* SelectMenu(FILEMENU, HELP); *)
  | PRINT: Print; (* SelectMenu(PRNTMENU, PRNTALL); *)
  | UPLOAD: Upload; (* to serial or midi port *)
  | NEWCFG: NewConfig;
  | MACROS: ShowMacros;
  | LAUNCH: ok:= LaunchPrg();
  | QUIT:
      DoQuit; (* sets terminate flag *)
      IF (blocktype = 1) (* isblock *) (* & (daccTitle[0] <> 0C) *) THEN (* is running as acc *)
(**
        mresetptr^:= 0; (* 0 w/just A009 allows mouse to disappear *)
**
        mhideptr^:= 1; (* reset flag to force mouse to show *)
**)
        Showmouse; (* lineA Show mouse *)
        dummy:= FormAlert(1,'[2]["Kwiksend" block to|other application?][Yes|No]');
        CODE(0A00AH); (* lineA Hide mouse *)
        IF dummy = 1 THEN
          kwiksend:= TRUE;
        END;          
(*
        keepmouse:= FALSE;
*)
      END; (* if isblock *)
  | FINDREP: ok:= DoFind(TRUE);
  | WRAP: SelectMenu(EDITMENU, WRAP);
  | INSERT: InsertBytes;
  | DATE: ShowDate;
  | TEXTHACK: HackToggle;
(*
  | BLOCK: (* SelectMenu(EDITMENU, BLOCK); *)
      BlockMenu(int);
*)
  | VIEWRAM: (* Alt-V *)
      Gotoline;
(**
      ok:= ViewMem();
      GrafMouse(GEMAESbase.Arrow, NIL); (* from busy bee in case of search *)
      CODE(0A00AH); (* lineA Hide mouse *)
***)
  | ENCRYPT: (* 3.1 shift-alt-E mark everything *)
(*
      ok:= Encrypt();
*)
      RuinBlock(TRUE);
      blockstart:= 0;
      blockend:= last;
      BlockCheck; (* sets isblock & switches start/end if needed *)
      blocktype:= 1; (* isblock:= TRUE; 1=normal block *)
      ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
  | CLEARBUF: SelectMenu(EDITMENU, CLEARBUF);
  ELSE
  END; (* case menu *)
END MainMenu;

PROCEDURE BlockMenu(int: INTEGER);
(* get/return item # *)
BEGIN
  CASE int OF
  | OPEN: (* merge *)
      ok:= DoMerge(FALSE, FALSE); (* not topastebuff, not clipbrd *)
  | SAVE: (* no force overwrite or append *)
      ok:= Saveblock(blockstart, blockend, 0);
(*
  | HELP: (* to main from block *)
      int:= 0;
*)
  | PRINT: Print; (* SelectMenu(PRNTMENU, PRNTALL); *)
  | UPLOAD: Upload; (* to serial or midi port *)
  | NEWCFG:
    (* item[23]:= 'Copy  -> Clip' *)
      CutClip(FALSE);
  | MACROS:
    (* item[24]:= 'Cut   -> Clip' *)
      DoCut(2);
  | LAUNCH: (* item[25]:= 'Paste <- Clip' *)
      PasteBlk(FALSE, TRUE); (* colblk, fromclip *)
  | QUIT: (* item[26]:= 'PasteCol Clip' *)
      PasteBlk(TRUE, TRUE); (* colblk, fromclip *)
  | FINDREP: (* item[27]:= 'Quote ">" *)
      ShiftBlk(2); (* quote *)
  | WRAP: (* item[28]:= 'Wrap/reformat' *)
      WrapMarked;
      saved:= FALSE;
      pastelen:= 0; (* since wrap destroyed paste buffer in newlnptrs *)
      Display(curdispline, cfg.maxdispline);
      Bottomstay; (* Display(0); *)
  | INSERT: (* item[29]:= Shift left/right *)
      int:= 2;
      Showmouse; (* lineA Show mouse *)
      result:= FormAlert(int,"[2][  Shift Block:][ Left|Right|Cancel]");
      CODE(0A00AH); (* lineA Hide mouse *)
      IF result < 3 THEN
        ShiftBlk(result - 1); (* left=0, right=1 *)
      END;  
  | DATE: (* item[30]:= Edit caps *)
      CallCase;
(*
      Showmouse; (* lineA Show mouse *)
      int:= 2;
      result:= FormAlert(int,"[2][ Change Case of Block][Lower|Upper|Caps]");
      CODE(0A00AH); (* lineA Hide mouse *)
      ChangeCase(result);      
*)
  | TEXTHACK:
   (* item[31]:= 'Kwiksend...  ' *)
      IF blocktype = 1 THEN
(*
      IF (daccTitle[0] <> 0C) THEN (* running as acc *)
*)
        kwiksend:= TRUE;
        Terminate;
      ELSE
        BlockAlert;
      END; (* if normal block *)
(*
      END; (* if running as acc *)
*)
  | BLOCK:
   (* item[32]:= 'Copy  -> Buff' *)
      CopyBlk(1); (* 1=buff *)
  | VIEWRAM:
   (* item[33]:= 'Cut   -> Buff' *)
      DoCut(1);
  | ENCRYPT: (* item[34]:= 'Paste <- Buff' *)
      PasteBlk(FALSE, FALSE); (* colblk, fromclip *)
  | CLEARBUF: (* item[35]:= 'PasteCol Buff' *)
      PasteBlk(TRUE, FALSE); (* colblk, fromclip *)
  ELSE
  END; (* case block menu *)
END BlockMenu;


PROCEDURE CallCase;
BEGIN
  IF blocktype > 0 THEN (* is block *)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(2,"[2][ Change Case of Block][Lower|Upper|Caps]");
    CODE(0A00AH); (* lineA Hide mouse *)
    ChangeCase(result);      
  ELSE (* no block *)
    BlockAlert;
  END; (* if isblock *)
END CallCase;

PROCEDURE NeoMsg(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN
  ok:= TRUE;
  IF (pipeBuff[0] = NEOACCPAS) & (neoadr <> ADR(pipeBuff)) THEN (* get 1st file from Neo *)
(*
    procptr:= neoadr + ADDRESS(94); (* points to listfiles() in neo *)
*)
    CODE(048E7H,0787EH); (* movem.l A1-A6/D1-D4,-(SP) *)
(*
    SETREG(A0, procptr);
*)
    PUSH(ADR(ptr1));
    SETREG(A0, neoadr);
    CODE(02068H,0005EH); (* movea.l 94(A0),A0 *)
    CODE(04E90H); (* jsr (A0) *)
    CODE(0588FH); (* addq.l  #4,a7 *)
    CODE(04CDFH,07E1EH); (* movem.l (SP)+,A1-A6/D1-D4 *)
    IF REGISTER(D0) <> 0 THEN
      ok:= PassedFile(HIGH(fsel), TRUE); (* TRUE = do load it *)
    END;
  END; (* if passed files *)
  pipeBuff[0]:= DUMMSG;
  pipeBuff[1]:= Appl; (* EdHak application ID *)
  pipeBuff[2]:= 0; (* excess message length *)
  ApplWrite(neoID, 16, ADR(pipeBuff)); (* std 16 byte msg *)
  RETURN ok;
END NeoMsg;

PROCEDURE Events;
(* Handle resource events once the editor has been called *)
VAR oldworkY,oldworkX, x,y,w,h, savemouse, whichmenu, whatevents: INTEGER;
    oldi, oldlast : LONGCARD; (* 32 bit.  were CARD *)
    donemenu, keepmouse, scrollok: BOOLEAN;
(*
    hibyte: CHAR;
*)
PROCEDURE InitEvents;
BEGIN
  eventflags:= 017H; (* 0001 0111, all but rect2 and timer *)
  IF (topwind = Window1) THEN
    IF (i <> oldi) OR (last <> oldlast) THEN
      NotiChar;
    END; (* if *)
    eventflags:= 037H; (* 0011 0111, all but rect2 *)
    CursorDraw; (* Curson; *)
  (** force mouse to show, in case other prg changed it **)
 (** try remove for 3.2D, replace in 3.2E **)
(**
    mresetptr^:= 0; (* mouse reset flag *)
**)
(***
    mhideptr^:= 0; (* 0 w/just A009 allows mouse to disappear *)
    IF keepmouse THEN
      mhideptr^:= 1; (* reset flag to force mouse to show *)
    END; (* if keepmouse *)
    CODE(0A009H); (* lineA Show mouse *)
***)
(**
    Showmouse; (* lineA Show mouse *)
    IF NOT keepmouse THEN
      CODE(0A00AH); (* lineA Hide mouse *)
    END; (* if keepmouse *)
**)
    dummy:= 1; (* allows mouse to disappear? *)
    IF keepmouse THEN
(**
      dummy:= 0; (* force mouse to show *)
    END; (* if keepmouse *)
**)
      LOOP
        IF mhideptr^ > 0 THEN
          CODE(0A009H); (* lineA Show mouse *)
        ELSIF mhideptr^ < 0 THEN
          CODE(0A00AH); (* lineA Hide mouse *)
        ELSE
          EXIT;
        END;
      END; (* loop *)
    ELSE (* not keepmouse *)
      mhideptr^:= 0; (* 0 w/just A009 allows mouse to disappear *)
      CODE(0A009H); (* lineA Show mouse *)
    END; (* if keepmouse *)
(**)
(***
    mresetptr^:= 0; (* mouse reset flag *)
    mhideptr^:= 1; (* reset flag to force mouse to show *)
***)
(**
    intin[0]:= 1; (* 0 means force show mouse *)
    IF keepmouse THEN
      intin[0]:= 0; (* reset flag to force mouse to show *)
    END; (* if keepmouse *)
    SetContrl(122, 0, 1, 0, VDIHandle); (* Show Mouse *)
    CallVDI;
**)

  END; (* if topwind *)
  oldi:= i;
  oldlast:= last;
  WindowUpdate(0); (* give screen to GEM, 2/7/92 *)
END InitEvents;

PROCEDURE EndEvent;
BEGIN
  WindowUpdate(1); (* begin, ends at end of redraw *)
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy);
  IF (topwind = Window1) (* & (NOT alldone) *) THEN
(**)
    CODE(0A00AH);  (* LineA hide mouse *)
(**
    SetContrl(123, 0, 0, 0, VDIHandle);
    CallVDI;
**)
    CursorDraw; (* Cursoff; *)
  END; (* if topwind *)
END EndEvent;

BEGIN (* Events *)
  WindowUpdate(1); (* begin, ends at end of redraw *)
  (**)
  GrafMouse(GEMAESbase.Arrow,NIL) ; (* ensure pointing mouse *)
  (**)
  alldone := FALSE;
  keepmouse:= FALSE; (* mouse appears for all mouse operations only *)
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy);
  InitEvents;
(*
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][begin event loop][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
*)
  LOOP
    whatevents:= EventMultiple(eventflags,
                           1,1,1, (* 3rd 1 means wait for left button down *)
                           0 (* inout *), menubX,menubY,menubW,menubH,
                           0,0,0,0,0, ADR(pipeBuff), 1,0, (* 1,0 *)
                           mX0, mY0,  mbstate, mkstate, kret, breturn);
(*
 dummy:= FormAlert(1,'[1][EdHak sensed event][ OK ]');
*)
   IF whatevents <> GEMAESbase.TimerEvent THEN
    EndEvent;
    (* CASE result OF *)
(*************************************************)
(*
    IF result = GEMAESbase.MesageEvent THEN
*)
(**)
    IF BITSET(whatevents) * BITSET(GEMAESbase.MesageEvent) <> {} THEN
(**)
      keepmouse:= TRUE;

(*
      CASE pipeBuff[0] OF           (* message type *)
*)
      IF pipeBuff[0] = 1000 THEN (* STENO_APPEND_LINE = 1000 *)
        keepmouse:= FALSE;
        (* Stalker has a line of text ready to send *)
        Capture(TRUE); (* do show text, since window is open *)
      ELSIF pipeBuff[0] = GEMAESbase.MenuSelected THEN (* SelectMenu(pipeBuff[3], pipeBuff[4]); *)
        savemouse:= mhideptr^;
(** 3.2D **)
        Showmouse; (* lineA Show mouse *)
        dummy:= FormAlert(1,'[1][EditPlus 3.2g|Clear Thinking|14 Payeur Road|Ann Arbor, MI 48108  USA][ OK ]');
        CODE(0A00AH); (* lineA Hide mouse *)
(***
        mhideptr^:= savemouse; (* try take out for 3.2g & use loop: *)
***)
        LOOP
          IF savemouse < mhideptr^ THEN
            CODE(0A009H); (* lineA Show mouse *)
            (* DEC(savemouse); *)
          ELSIF savemouse > mhideptr^ THEN
            CODE(0A00AH); (* lineA Hide mouse *)
            (* INC(savemouse); *)
          ELSE
            EXIT;
          END;
        END; (* loop *)
       (* put header back normal.  put at end of SelectMenu if use real appl *)
        MenuTitleNormal(MenuTree, DESKMENU, 1) ; (* deselects selected item *)
      ELSIF pipeBuff[0] = GEMAESbase.WindowArrowed THEN
        IF scrollok THEN
  (**
          (* debug *)
          Cardtostrg(LONGCARD(result), cardstrg, TRUE, 4);
          StringZap(cardstrg);
          Wait;
  **)
          LOOP (* handle held down button, should handle TOS 1.0! *)
            Arrow(pipeBuff[3], pipeBuff[4]);
            IF NOT(0 IN BITSET(ORD(mstatptr^))) THEN (* left button now up *)
              EXIT;
            END; (* if exit, button released *)
          END; (* scroll loop *) 
          scrollok:= FALSE;
        ELSE
          scrollok:= TRUE;
        END; (* if scrollok *)
      ELSIF pipeBuff[0] = GEMAESbase.WindowVertSlided THEN
        Slide(pipeBuff[3], pipeBuff[4]);
      ELSIF pipeBuff[0] = GEMAESbase.WindowHorizSlided THEN
        HSlide(pipeBuff[3], pipeBuff[4]);
(***)
      ELSIF pipeBuff[0] = GEMAESbase.WindowMoved THEN
        (* WindowUpdate(1); (* begin, ends at end of redraw *) *)
        update:= TRUE; (* 2.32 3/30/92 *)
        cfg.wind1X:= pipeBuff[4]; (* requested X *)
        cfg.wind1Y:= pipeBuff[5]; (* Y *)
        CheckSize;
        Setxywh;
(*
        cfg.wind1Y:= wind1Y;
        cfg.wind1X:= wind1X;
**)
        InitMenu;
        CursorPos(curdispline, leftedge + linepos);
        (* WindowUpdate(0); (* ends redraw *) *)
      ELSIF pipeBuff[0] = GEMAESbase.WindowSized THEN
        update:= TRUE;
        cfg.wind1W:= pipeBuff[6]; (* W *)
        wind1H:= pipeBuff[7]; (* H *)
        CheckSize;
        Setxywh;
        IF (curdispline > cfg.maxdispline)
         OR (linepos > displaylen) THEN (* get cursor into window *)
          Bottom; (* puts cursor at last text in shrunk window *)
        END;
        InitMenu;
      ELSIF pipeBuff[0] = GEMAESbase.WindowFulled THEN
        IF NOT forcefull THEN
          WindowGet(Window1, GEMAESbase.FullXYWH, x,y,w,h);
          oldworkX:= workX;
          oldworkY:= workY;
          IF (wind1H+rowH < h) OR (cfg.wind1W+colW < w) THEN (* make it full *)
            cfg.wind1X:= x;
            cfg.wind1Y:= y;
            cfg.wind1W:= w;
            wind1H:= h;
(**)
            update:= FALSE; (* should be no redraw *)
(**)
          ELSE (* make it small again *)
            WindowGet(Window1, GEMAESbase.PrevXYWH, cfg.wind1X,cfg.wind1Y,cfg.wind1W,wind1H);
          END; (* if not full *)
          CheckSize; (* also sets cfg.maxdispline, displaylen *)
          Setxywh;
          InitMenu;
          IF (cfg.maxdispline = scrnmaxdispln) &  (* fulled window *)
              (cfg.wind1W > fullW - colW) THEN (* fill in bottom of window *)
            Display(0, cfg.maxdispline);
            Bottomstay; (* also sets slide size & pos *)
          ELSE (* shrunk window *)
            (* let redraw handle display nope? 2.31 *)
            IF (curdispline > cfg.maxdispline) OR (linepos > displaylen) THEN (* get cursor into window *)
              Bottom; (* puts cursor at last text in halved window *)
            END;
            IF (oldworkY <> workY) OR (oldworkX <> workX) THEN
              update:= FALSE; (* strip redraw that would occur *)
            END;
            Display(0, cfg.maxdispline);
          END; (* if need to fill in bottom half *)
        END; (* if not forcefull *)
      ELSIF pipeBuff[0] = GEMAESbase.WindowRedraw THEN
(*
        keepmouse:= FALSE;
*)
  (*
        IF pipeBuff[1] = 0 THEN
          (* you are exiting to desktop or equivalent; Flash on-line mode *)
      (** BUT this also happens when moving desktop window over Diary,
          and thus this SCREWS UP!! **)
          EXIT;
          END;
  *)
          (* Set vdi text vert alignment to bottom of cell *)
          SetGraphicTextAlignment(VDIHandle, 0, 3, dummy, dummy);
          IF (update) (* & (pipeBuff[3] = Window1)) *) THEN
            Redraw(pipeBuff[4], pipeBuff[5], pipeBuff[6], pipeBuff[7]); (* x,y,w,h *)
            menuok:= TRUE;
          ELSE
            update:= TRUE; (* NOT update; *)
          END; (* if need to redraw window *)
          menuok:= TRUE; (**** ? ***)
      ELSIF pipeBuff[0] = GEMAESbase.WindowClosed THEN
(*
        keepmouse:= FALSE;
*)
(**)
        (* add for 3.0N *)
        ok:= TRUE;
        IF (daccTitle[0] = 0C) OR ismdx
          (* (GEMAESbase.AESIntOut[1] = 04E52H) *) (* MDX *) THEN (* treat as prg *)
          ok:= SaveCheck(TRUE, TRUE);  (* askbig & asksave *)
        END;
        IF ok THEN
(**)
          ok:= FALSE; (* 2.33 4/10/92 for non-alt-exit *)
          Terminate;
(**)
        END;
(**)
      ELSIF (pipeBuff[0] = GEMAESbase.WindowTopped)
        OR (pipeBuff[0] = 88) THEN  (* 88 = 'STeno' invoked from STalker *)
      (* IF pipeBuff[3] = Window1 THEN  (* THIS window topped *) *)
        keepmouse:= FALSE; (* prevent mouse cloning in slide area? *)
        DoTop(FALSE); (* isclosed *)
        InitMenu; (* done by redraw only if window needs some redraw! *)
      (* END; (* if topped *) *)
      ELSIF pipeBuff[0] = GEMAESbase.AccessoryOpen THEN
        IF pipeBuff[4] = dacc THEN (* THIS acc opened *)
          WindowGet(Window1, 11, dummy, result, dummy,dummy); (* 1stxYwh *)
          IF result = cfg.wind1Y THEN (* this seems reversed, why does it work? *)
            DoTop(TRUE); (* wind1 IS closed, so open it *)
          ELSE
            DoTop(FALSE); (* simple Top *)
          END;
          InitMenu;
        END; (* Redraw no longer is allowed to handle display.  re-opened *)
      ELSIF pipeBuff[0] = GEMAESbase.AccessoryClose THEN
        (* this happens anytime an application closes *)
        (* Terminate procedure screws up exiting from Flash at least *)
(*
        keepmouse:= FALSE;
*)
        WindowUpdate(0); (* end *)
        EXIT;
        (** but still need to close/delete window?? as needed **)
        (* or does GEM do it for us? *)
(**)
      ELSIF pipeBuff[0] = 04354H THEN  
        (* your buffer has been stuffed with input from EdHak.ACC *)
        last:= Swapadd(pipeBuff[3], pipeBuff[4]);
(*
        last:= LONGCARD(pipeBuff[3]) * 010000H; (* hi word of size *)
        last:= last + LONGCARD(pipeBuff[4]);
*)
        (* do whatever you need to with your buffer...*)
        (* the next 3 lines are what EdHak itself does with it as a test *)
        Lineptrs(0);
        MiniInit; (* sets i:= 0 among other things *)
        SetSlideSize;
        SetSlidePos;
        saved:= FALSE;
        Display(0, cfg.maxdispline);
(***)
      (* Add for full NeoDesk ACC support 3.02 *)
      ELSIF (* (pipeBuff[0] = NEOACCCLI) OR *)
       ((pipeBuff[0] = NEOACCPAS) OR (pipeBuff[0] = NEOCLIRUN))
       & (pipeBuff[3] = NEOACCMAGIC) THEN
        ok:= NeoMsg();
      ELSIF (pipeBuff[0] = NEOACCINI) & (pipeBuff[3] = NEOACCMAGIC) THEN
        neoadr:= ADDRESS(Swapadd(pipeBuff[4], pipeBuff[5]));
        neoID:= pipeBuff[6];
      ELSIF (pipeBuff[0] = NEOACCBAD) & (pipeBuff[3] = NEOACCMAGIC) THEN
        neoadr:= ADR(pipeBuff); (* use this as null address *)
(***)
      ELSIF (pipeBuff[0] = 53) OR (pipeBuff[0] = 153) THEN
        (* Stalker EM_PASTE Steno pre-3.03, post 3.03 *)
        PasteBlk(FALSE, TRUE); (* colblk, fromclip *)
      ELSE (* other pipebuff msg?, e.g., windownewtop *)
(**
        eventok:= TRUE;
**)
(**
        IF ((pipeBuff[2] > 0) & (pipeBuff[2] <= 16)) THEN (* is extended msg *)
          ApplRead(Appl, pipeBuff[2], ADR(pipeBuff));
        END; (* if extended msg *)
**)
      END; (* case of message/pipebuff *)
(***  (* remove from 2.35 for 2.3W *)
      IF ((pipeBuff[2] > 0) & (pipeBuff[2] <= 16)) THEN (* is extended msg *)
        ApplRead(Appl, pipeBuff[2], ADR(pipeBuff));
      END; (* if extended msg *)
***)
(*
    ELSE (* other multi-event? *)
*)
    END; (* case eventmsg *)
    
(********************************************************)

    IF BITSET(whatevents) * BITSET(GEMAESbase.KeyboardEvent) <> {} THEN
      keepmouse:= FALSE;
      kreturn:= CARDINAL(kret);
(*
      hibyte:= CHR(BITSET(kreturn) * BITSET(0FF00H));
*)
      newchar:= CHR(kreturn); (* CHAR MOD 00100H);*)(* low byte of 16 bit scancode *)
      IF (newchar > 0C) (* & (newchar <= 177C) *) THEN (* ascii 1-127, shift- *)
        Key(kreturn);
      ELSE (* lo byte, newchar = 0C *)
(*
        IF ORD(hibyte) < 03BH THEN (* was DIV 0100H *)
*)
        IF (CARDINAL(BITSET(kreturn) * BITSET(0FF00H)) < 03B00H) THEN (* was DIV 0100H *)
          AltKey(kreturn);
(*
        ELSIF ORD(hibyte) > 05DH THEN (* was DIV 0100H *)
*)
        ELSIF (CARDINAL(BITSET(kreturn) * BITSET(0FF00H))  > 05D00H) THEN (* was DIV 0100H *)
          HelpCntrl(kreturn); (* Help, Undo, cntrl-arrows *)
        ELSE (* kreturn between 03BH and 05DH inclusive *)
          FuncArrow(kreturn);
        END; (* if func, arrow, help, alt- keys *)
      END; (* if in low byte in ascii range *)
      (* end case of KeyboardEvent *)
    ELSIF (BITSET(whatevents) * BITSET(GEMAESbase.ButtonEvent) <> {}) &
          (Window1 = topwind) THEN
      keepmouse:= TRUE;
      IF (0 IN BITSET(mkstate)) OR (1 IN BITSET(mkstate)) THEN
        (* shift-click, extend block = F2 *)
        (* first relocate cursor, and then extend block *)
        FindMouse(mX0, mY0); (* finds i & linepos & curdispline *)
        FuncArrow(03C00H); (* F2 = mark end of block *)
      ELSE (* 0 IN BITSET(ORD(mstatptr^)) THEN *) (* left button is down *)
        ok:= FALSE; (* no alt key *)
        IF 3 IN BITSET(mkstate) THEN (* alt-click, column block start *)
          ok:= TRUE;
        END;
        Button(mX0, mY0, ok); (* ok => alt-click, col block *)
      END; (* if shift-click *)
    ELSIF (BITSET(whatevents) * BITSET(GEMAESbase.Mouse1Event) <> {}) &
          (Window1 = topwind) THEN
(*******
      IF cfg.hexdisp THEN (* needclick to drop menu *)
        menuok:= TRUE;
        WindowUpdate(0); (* begin, ends at end of redraw *)
        Showmouse; (* lineA Show mouse *)
        result:= EventMultiple(GEMAESbase.ButtonEvent+GEMAESbase.Mouse1Event,
                           1,1,1, (* 3rd 1 means wait for left button down *)
                           1 (* inout *), menubX,menubY,menubW,menubH,
                           0,0,0,0,0, ADR(pipeBuff), 0,0,
                           dummy,dummy,dummy,dummy,dummy,dummy);
        CODE(0A00AH); (* lineA Hide mouse *)
        WindowUpdate(1); (* begin, ends at end of redraw *)
        IF result = GEMAESbase.Mouse1Event THEN (* skip menu *)
          menuok:= FALSE;
        END;
      END; (* if needclick *)
*******)
      IF menuok THEN
        keepmouse:= TRUE;
        int:= 0; (* main menu *)
        IF blocktype > 0 THEN
          int:= 1;
        END;
(**
        WindowUpdate(3); (* take control of mouse *)
**)
        LOOP
          whichmenu:= int;
          DoMenu(int);
          IF int = -1 THEN
            EXIT;
          END;
          IF whichmenu = 0 THEN (* main *)
            IF int = BLOCK THEN
              int:= 1; (* to block menu *)
            ELSE
              MainMenu(int);
              IF kwiksend THEN
                keepmouse:= FALSE;
              END;
              EXIT;
            END;
          ELSE (* block menu *)
            IF int = HELP THEN (* to main menu *)
              int:= 0;
            ELSE
              BlockMenu(int);
              EXIT;
            END;
          END;
        END; (* loop *)
(**
        (* redraw text area where menu was *)
        (* FormFinish handles text, but not block highlighting properly *)
        dummy:= 0;
        IF cfg.maxdispline = 8 THEN (* handle non-redraw of menu bottom *)
          (* implies smallest 8x16 window in mono, menu bottom hits window *)
          dummy:= 1;
        END;
        Redraw(menuX, workY, menuW+4, menuH-dummy);
        WindowUpdate(2); (* give mouse control back to GEM *)
**)
      ELSE (* menuok was turned off by dotop or initwind *)
        menuok:= TRUE;
      END; (* if update *)
    END; (* if non msg event *)
(*******************************************************)
    IF alldone THEN
      WindowUpdate(0); (* end 2.30 2/7/92 *)
      EXIT;
    END;
    InitEvents;
   ELSE (* is just timer event *)
     menuok:= FALSE;
     scrollok:= TRUE;
   END; (* if not timer event *)
  END; (* loop *)
END Events ;

(* ------------------------------------------------------------------- *)

PROCEDURE InitWork() : BOOLEAN ; (* done each time the window is opened *)
(*
VAR RGBx: PxyArrayType;
*)
CONST
(*
  ResourceFileName = "DIARY.RSC" ;
  Alert = "[3][ No resource file DIARY.RSC ][OK]" ;
*)
VAR
(*
  str : ARRAY [0..15] OF CHAR;
  result : INTEGER;
*)
  i : CARDINAL;
BEGIN

(*** take out old rsc file call routine ***)
(*
  str:= ResourceFileName ;
  ResourceLoad(str);
  IF ( GEMAESbase.AESCallResult = 0 ) THEN
    str:= Alert;
    result:= FormAlert(1, str);
    RETURN FALSE;
  END; (* if error loading rsc file *)
*)
(** End of removed rsc load routine **)
(*
  ResourceGetAddr(GEMAESbase.RTree, MENUTREE, MenuTree) ;
  MenuBar(MenuTree,1) ;
*)
  (* Get AES VDI handle *)
  VDIHandle:= GrafHandle(dummy, rowH, dummy, offset); (* boxH *)
  defrowH:= rowH;
  defcharht:= 10; (* default to rowH=16, height = 13, 8x16 font *)
  IF rowH = 8 THEN
    defcharht:= 9; (* height 6 = 8x8 *)
    IF cfg.charht = 10 THEN
      cfg.charht:= 9; (* no 8 x 16 med res, it crashes ! *)
    END;
  ELSIF rowH = 6 THEN
    defcharht:= 8; (* height 4 = 6x6 *)
  END;
  (* Open VDI Virtual workstation *)
  (* workIn was already init'd in Init procedure *)
  FOR i:= 0 TO 9 DO
    workIn[i]:= 1 ;
  END; (* for *)
  workIn[10]:= 2 ; (* Set to Raster Coordinate system *)
  OpenVirtualWorkstation(workIn, VDIHandle, workOut) ;
  fullW:= workOut[0] + 1;
  fullH:= workOut[1] - offset + 1;
  screenadr:= ScreenLogicalBase(); (* ScreenPhysicalBase(); *)
  IF GetResolution() = 1 THEN
    DEC(screenadr); (* for med res.   who knows why? *)
  END;
(******
  IF cfg.charht = 0 THEN (* need to get max wind coords *)
    InitWinSize;
    cfg.wind1Y:= fullY; (* wind1Y in case of incorrect cfg *)
    cfg.wind1X:= fullX;
    cfg.wind1W:= fullW; (* H is handled via cfg.maxdispline *)
  END; (* if no cfg *)
*******)

(*
  IF (cfg.charht <> 13) & (cfg.charht <> 6) & (cfg.charht <> 4) THEN
*)
  IF cfg.charht < 8 THEN (* point sizes *)
    cfg.charht:= defcharht;
  END;
  SetFont; (* to cfg.charht, sets rowH *)
(******
  IF cfg.charht = 0 THEN (* need to get max wind coords *)
    InitWinSize;
    cfg.wind1Y:= fullY; (* wind1Y in case of incorrect cfg *)
    cfg.wind1X:= fullX;
    cfg.wind1W:= fullW; (* H is handled via cfg.maxdispline *)
  END; (* if no cfg *)
*******)
  IF (cfg.maxdispline = 0) OR (cfg.maxdispline > scrnmaxdispln) THEN
    cfg.maxdispline:= scrnmaxdispln;
  END;
  (** could get wind1H by windowcalc of workH=rowH * (cfg.maxdispline+1) **)
  wind1H:= rowH * INTEGER(cfg.maxdispline+1) + offset + offset;

  (* Get kbd rec address *)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  PUSH(01H); (* xbios keyboard device # *)
  PUSH(14); (* iorec call *)
  CODE(04E4EH); (* (0100 1110 0100 1110) trap #14 [call XBIOS] *)
  CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
  kbdrecptr:= REGISTER(D0); (* pointer to kbd iorec *)

(**##*
(* try leaving out for testing, 2.32 3/12/92 *)
  (* try using my own DTA 2.30 1/30/92 *)
  (* SetDTA(ADR(DTA))); *)
  SETREG(A0, ADR(DTA));
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)

*##**)

(** 2/9/92 **)
  (* get keytbl pointers to use in kwiksend to get full keycodes *)
  CODE(02F3CH,0FFFFH,0FFFFH); (* move.l #-1,-(sp)   ; capslock *)
  CODE(02F3CH,0FFFFH,0FFFFH); (* move.l #-1,-(sp)   ; shift *)
  CODE(02F3CH,0FFFFH,0FFFFH); (* move.l #-1,-(sp)   ; unshifted *)
  CODE(03F3CH,00010H); (* move.w #16,-(sp)  ; xbios keytbl() opcode *)
  CODE(04E4EH); (* trap   #14  ; call xbios *)
  CODE(04FEFH,0000EH); (* lea.l  14(sp),sp  ; fix stack *)
  adrptr:= REGISTER(D0);  (* pointer to 3 addresses of tables *)
  unshiftptr:= adrptr^;
  INC(adrptr,4);
  shiftptr:= adrptr^;
  INC(adrptr,4);
  capslockptr:= adrptr^;
(***)

  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(**
(* WITH kbdrecptr^ DO *)
  IF lnptradr = kbdrecptr^.ibuffadr THEN (* adrptr^; *)
    kbdrecptr^.ibuffadr:= kbdbuffadr; (* return to saved kbd buffer adr *)
    kbdrecptr^.ibuffhead:= 0;
    kbdrecptr^.ibufftail:= 0;
    kbdrecptr^.ibuffsize:= kbdbuffsize;
    Lineptrs(0); (* restore linepointers after using that space for kbd *)
  END; (* if need to restore kbd buffer after having changed for KwikSend *)    
**)
  IF NOT InitWindow() THEN (* 2.30f 1/12/92 *)
    CloseVirtualWorkstation(VDIHandle) ;
    RETURN FALSE;
  END;
  (* exp 2.30 1/1/92 *)
(**
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[3][Done InitWind][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
**)
  SetFoundPos(FALSE, TRUE); (* don't force top *)
  IF (fileend > endf) THEN
    notistrg:= 'VirtualBUF';
    Notice;
  END; (* if file > buffer *)
(**
  SetSlideSize; (* now done in setxywh *)
  SetSlidePos;
**)
  (* Windfix; *)(* probably not needed ??? *)
  (* dummy:= ConfigureCursor(-1, 3); (* same rate, but no flash *) *)
  (* InquireColour(VDIHandle, GEMAESbase.Red, 0, RGBi); *)
(*
  RGBx[0]:= 800; (* red [0..1000] *)
  RGBx[1]:= 500; (* green *)
  RGBx[2]:= 1000; (* blue *)
  SetColour(VDIHandle, GEMAESbase.Red, RGBx);
*)
(*
  Cardtostrg(LONGCARD(unshiftptr), cardstrg, TRUE, 6); (* hex *)
  StringZap(cardstrg);
  Wait;
*)
  RETURN TRUE;
END InitWork;

(* ------------------------------------------------------------------- *)

PROCEDURE Terminate;
BEGIN
  (* Cursoff; *) (* don't need to bother since that's vt-52 cursor *)
  update:= FALSE;
  CloseWindow(Window1); (* includes WindowDelete & FormFinish *)
(*  MenuBar(MenuTree,0) ; *)
(*  ResourceFree() ; *)(** Remove this for embedded rsc **)
  (* SetColour(VDIHandle, GEMAESbase.Red, RGBi); *)
  alldone:= TRUE;

(**##
  (* try using my own DTA 2.30 1/30/92 *)
  (* SetDTA(olddta); *)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  SETREG(A0, olddta);
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
##**)
END Terminate ;

PROCEDURE PassedFile(max: CARDINAL; doload: BOOLEAN): BOOLEAN;
(* passed prg filespec as address in msgpipe or in basepage *)
(* max is max length of filespec string = maxindex + 1 *)
(* ptr1 points to filespec *)
BEGIN
  j:= 0;
  k:= 0;
  WHILE (ptr1^ > 40C) & (j < max) DO (* xfer to fsel *)
    fsel[j]:= ptr1^;
    INC(j);
    IF ptr1^ = '\' THEN (* to set cfg.oldpath length *)
      k:= j;
    END;
    INC(ptr1);
  END; (* while *)
  fsel[j]:= 0C;
  (* INC(k); *) (* k becomes length of path part of string *)
  (* set cfg.oldpath *)
  IF k > 0 THEN (* includes more than filename, e.g. F:\ *)
    MoveMem(ADR(fsel), ADR(cfg.oldpath), LONG(k));
    cfg.oldpath[k]:= 0C;
  END; (* if also passed drive\path, else leave as was *)
  (* set fsel0 *)
  DEC(j, k);
  MoveMem(ADR(fsel) + ADDRESS(k), ADR(cfg.fsel0), LONG(j));
  cfg.fsel0[j]:= 0C;
  (** Use this if want to actually load the file into buffer **)
  ok:= TRUE;
(*** DEBUG ***
    cfg.macro[1]:= '[1][>';
    Concat(cfg.macro[1],fsel,cfg.macro[2]);
    cfg.macro[1]:= '<][ OK ]';
    Concat(cfg.macro[2], cfg.macro[1], cfg.macro[3]);
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1, cfg.macro[3]);
    CODE(0A00AH); (* lineA Hide mouse *)
*** end debug ***)
  IF doload THEN
    (* no vdi handle here! use lineA ? *)
    CODE(0A00AH); (* lineA Hide mouse *)
       (* in case of failed load *)
    ok:= LoadFile(fsel, FALSE); (* don't allow display yet *)
    Showmouse; (* lineA Show mouse *)
  END; (* if doload *)
  RETURN ok; (* false if canceled from loadfile *)
END PassedFile;

PROCEDURE DoKwiksend;
BEGIN
(***^
  IF isblock THEN
    (* see if user wants to strip cr/lf's *)
    (** 2.30 **)
(**  (* remove 7/8/92 2.3Q *)
    Showmouse; (* lineA Show mouse *)
**)
    result:= FormAlert(1,"[2][Strip CR/LF's|During Kwiksend ?|(Alt aborts)][No|Yes|Cancel]");
    IF result <> 3 THEN (* not cancel *)
      ok:= FALSE; (* don't strip cr/lf *)
      IF result = 2 THEN
        ok:= TRUE; (* strip cr/lf *)
      END; (* if cancel or strip *)
   (***)
^***)

      (* install vbl interrupt routine to keep putting text into kbd
         one char per vbi until end of block at which point it
         disinstalls itself *)
      (* use PC relative address for adr of routine *)
      stack:= 0;  (* 2.36 *)
      Super(stack); (* into super mode *)
      findadr:= ADDRESS(0456H);
      adrptr:= findadr; (* vblqueue pointer *)
      cardptr:= ADDRESS(adrptr) - ADDRESS(2); (* 0454H, nvbls *)

      adrptr:= adrptr^ (* + ADDRESS(4) *);
      (* find empty vbl queue slot if available *)
      k:= 0; (* or = 1 if skip 1st *)

      WHILE (adrptr^ <> 0) & (k < cardptr^) DO
        adrptr:= ADDRESS(adrptr) + ADDRESS(4);
        INC(k);
      END; (* while look for unused vbl interrupt slot *)
      IF adrptr^ = 0 THEN (* found open slot *)
        findadr:= startadr + ADDRESS(blockstart);
        tmpadr:= startadr + ADDRESS(blockend);
 (*
        sendcount:= 0; (* could just use tmp var j or k *)
 *)
        k:= 0; (* sendcount *)
        ch:= 36C; (* = 30 loop delay counter for start of kwiksend *)
        saveA4:= REGISTER(A4);
        saveA5:= REGISTER(A5);

        SETREG(A5, adrptr); (* pointer to vbl queue *)

        (* lea.l #8(pc),a4 *)(* assumes pc is at end of 1st word of command *)
        CODE(049FAH, 0008H);
        (* 0100 1001 1111 1010, 0000 0000 0000 .... *)

        (* move.l a4,(a5) *) (* puts vbl routine address into queue *)
        CODE(02A8CH); (* 0010 1010 1000 1100 *)

        (* go beyond 126, so must now use long branch here *)

        (* bra  #254(pc)  ; bra to restore registers !!! *) (* 3.03 *)
        CODE(06000H,00FEH); (* 0110 0000 .... .... *)
(**
        (* bra  #250(pc)  ; bra to restore registers !!! *)
        CODE(06000H,00FAH); (* 0110 0000 .... .... *)
**)
      (***********************************)
      (****** start of VBL routine: ******)
(*w*)
 (*** add initial delay 2.30 using A6 as ptr to countdown counter ***)
        (* 20 bytes in just this delay section *)

        SETREG(A6, ADR(ch)); (* 10 bytes, delay counter *)
        (* tst.b (A6)  ; is counter down to zero yet? *)
        CODE(04A16H);
        (* beq.s cont  ; is 0 so get on with sending, adj offset !!! *)
        CODE(06706H);
        (* subq.b #1,(A6) ; dec counter *)
        CODE(05316H);
        (* bra  #232(pc)   ; skip to RTS at end of vbl routine *)
        CODE(06000H,000E8H); (* remember 2 extra bytes in bra.l, offset !!! *)
(*
        (* bra  #228(pc)   ; skip to RTS at end of vbl routine *)
        CODE(06000H,000E4H); (* remember 2 extra bytes in bra.l, offset !!! *)
*)
(* label: cont *)
        (* move.b #$2,(A6) *)
        CODE(01CBCH,00002H); (* reset delay counter to 2 for multitos *)

(*w*)
(*r*)
        (* 44-6=38 bytes w/o A0 in following 5 setregs *)
(*
        SETREG(A0, findadr); (* 6 bytes, although adds 8 bytes to prg *)
*)
        SETREG(A1, tmpadr); (* 6 bytes, although adds 8 bytes to prg *)
        SETREG(A2, kbdrecptr); (* 6 bytes. later must move.l (a2),a2 *)
        SETREG(A3, ADR(k)); (* 10 bytes *) (* was sendcount *)
        SETREG(A5, adrptr); (* 6 bytes *)
        (* for stripcr: must be after delay section which uses A6 *)
        SETREG(A6, ADR(ok)); (* 10 bytes, A6 not now needed for delay count *)
(*r*)
(*q*)
 (** 2.30  18 bytes in this Abort check  **)
 (* must come after setreg(a5) and before setregs a0 **)
(*
        CODE(04AFCH); (* illegal instruct for debug *)
*)
        SETREG(A0, kbshiftadr); (* 6 bytes? *)
        (* move.b -1(A0),D0  ; get kbshift byte *)
        CODE(01028H,0FFFFH); (* move.b -1(A0),D0  ; get kbshift byte *)
  
        (* andi.b  #%00001000,D0  ; strip all alt key test *)
        CODE(00200H,00008H); (* D0:  CODE(00200H,0000FH); *)
        (* tst.b  D0   ; see if any shift, ctl, alt keys pressed *)
        CODE(04A00H);
        (* bne.s  #28(pc)  ;  skip to disinstall, adjust offset!!! *)
        CODE(0661CH);
(*q*)  
        SETREG(A0, findadr); (* 6 bytes *)
(*a*)
        (* 20+2 bytes in this section to start of Disinstall routine *)
        (* move.w (A3),D4 ; *)(* copy sendcount to D4 *)
        CODE(03813H); (* 0011 1000 0001 0011 *)
        (* instead of all the following setting of data registers
           I could just use x(A2) later to refer to these things,
           except for the indirect with index addressing I use later *)
        (* movea.l A2,A4 *) (* copy address of kbdrec *)
        CODE(0284AH); (* 0010 1000 0100 1010 *) (* SETREG(A4, REGISTER(A2)) *)
        (* addq.l #4,A4 *) (* get address of ibuffsize *)
        CODE(0588CH); (* 0101 1000 1000 1100 *)

        (* move.w (A4)+,D0 ; SETREG(D0, kbdrecptr^.ibuffsize); *)
        CODE(0301CH); (* 0011 0000 0001 1100 *)

        (* move.w (A4)+,D1 ; SETREG(D1, kbdrecptr^.ibuffhead); *)
        CODE(0321CH); (* 0011 0010 0001 1100 *)

        (* move.w (A4),D2 ; SETREG(D2, kbdrecptr^.ibufftail); *)
        CODE(03414H); (* 0011 0100 0001 0100 *)

        (* get blocklength *)(* why not have set D3 directly above? *)
        (* move.l A1,D3 ; SETREG(D3, ADR(blockend) A1 no longer needed *)
        CODE(02609H); (* 0010 0110 0000 1001 *)
        (* sub.l A0,D3 ; D3 = ADR(blockend) - ADR(blockstart) *)
        CODE(09688H); (* 1001 0110 1000 1000 *) (* D3:= blocklength *)

        (* if sendcount = blocklen then put zero into vbl slot to disinstall *)
        (* cmp.w D4,D3 ; compare sendcount, blocklen *)
        CODE(0B644H); (* D3 is not needed for blocklen after this *)

        (* skip disinstall routine if blocklen > sendcount *)
        (* bhi.s 12(pc) bhi is for unsigned #'s, instead of bgt *)
        CODE(0620CH); (* adjust offset !!! *)

        (* bra.s 6(pc) disinstall 1 ; skip over emptying buffer.  offset !!! *)
        CODE(06006H);
(*a*)
(*d0*)
        (* move.w 6(A2),8(A2) ; set tail = head to 'empty' kbd buffer *)
        CODE(0356AH,00006H,00008H); (* move.w 6(A2),8(A2) *)
(*d0*)
(*d1*)
       (* Disinstall routine, 4 bytes *)
        (* clr.l (A5)  disinstall vector from vbl queue *)
        CODE(04295H); (* 0100 0010 1001 0101 *)

        (* RTS *)
        CODE(04E75H); (* 0100 1110 0111 0101 *)
(*d1*)   
     (* copy char to kbd buffer, circularly as a longword *)
(*t*)
  (* 12 bytes in this version: *)
        (* addq.w #4,D2 *)
        CODE(05842H);
        (* cmp.w D0,D2 *) (* at end of buffer? D0 now free to use *)
        CODE(0B440H);
        (* bcs.s #2(pc) *) (* not there yet *)
        CODE(06502H);
        (* moveq.w #0,D2 *) (* set tmptail to 0 *)
        CODE(07400H);
        (* cmp.w D2,D1 *) (* tmptail = head? D1 now free to use *)
        CODE(0B242H);

    (* -2 bytes *)
        (* beq.s end ; 118(pc) skip whole copy section, adj offset!!! *)
        CODE(06778H); (* to start of RTS *)
(*
        (* adds another 2 bytes, 2/9/92 *)
        (* beq  end ; 128(pc) skip whole copy section, adj offset!!! *)
        CODE(06700H,00080H); (* to start of RTS *)
*)
(*
        (* beq.s end ; 126(pc) skip whole copy section, adj offset!!! *)
        CODE(0677EH); (* to start of RTS *)
*)
(*t*)
(*c*)
        (* 16+28+12 = 56 bytes in this Copy section up to before RTS *)

        (* move.l (a2),a2 ; *) (* put address of kbd buffer into a2 *)
        CODE(02452H); (* 0010 0100 0101 0010 *)
        (* clr.l (A2,D2.w) ;  *) (* force top 3 bytes = 0; 4 bytes per char *)
        CODE(042B2H, 02000H);

(*** 2.30 2/9/92 **)
(* ks *)
    (** 50 bytes in this keycode search routine **)
    (* try searching unshift & shift keytables for char to get keycode *)
        (* initloop: *)
        CODE(01030H,04000H); (* move.b (A0,D4.w),D0  ; set char byte for comparisons *)
(***    (* use only unshifted if char > 'Z' *)
        cmp.b #
***)
        SETREG(A1,unshiftptr); (* address of unshifted keytbl *) (* 6 bytes *)
(****)
(*
        CODE(0D3FCH,0000H,00001H); (* adda.l #1,A1 *)
*)
(***
        CODE(043E9H,00001H); (* lea.l 1(A1),A1 ; since first scancode is 1 not zero *)
***)
        CODE(07200H); (* moveq.w #0,D1 ; init counter to limit max & yield keycode *)
        (* srchlp1: *)
        CODE(0B019H); (* cmp.b  (A1)+,D0  ; actual byte comparison *)
(*
        CODE(0671EH); (* beq.s  foundkey  ; found char in keytbl *)
*)
        CODE(06720H); (* beq.s  foundkey  ; found char in keytbl, offset!! *)
        CODE(05241H); (* addq.w #1,D1     ; inc counter *)
        CODE(00C41H,0003AH); (* cmpi.w #$3A,D1  ; check if hit max *)
        CODE(065F4H); (* bcs.s  srchlp1   ; continue search *)
        (* not found so now check shifted keytbl *)
        SETREG(A1,shiftptr); (* 6 bytes *)
(***
        CODE(043E9H,00001H); (* lea.l 1(A1),A1 ; since first scancode is 1 not zero *)
***)
(*
        CODE(07200H); (* moveq.w #0,D1    ; init counter to limit max & yield keycode *)
*)
        CODE(0323CH,00100H); (* move.w #$100,D1  ; set rt-shift bit of high byte *)
        (* srchlp2: *)
        CODE(0B019H); (* cmp.b  (A1)+,D0  ; actual byte comparison *)
        CODE(0670AH); (* beq.s  foundkey  ; found char in keytbl *)
        CODE(05241H); (* addq.w #1,D1     ; inc counter *)
        CODE(00C41H,0013AH); (* cmpi.w #$13A,D1  ; check if hit max *)
(*
        CODE(00C41H,0003AH); (* cmpi.w #$3A,D1  ; check if hit max *)
*)
        CODE(065F4H); (* bcs.s  srchlp2   ; continue search *)
        CODE(06004H); (* bra.s  nokey     ; no keycode found *)
        (* foundkey: *)
        CODE(03581H,02000H); (* move.w  D1,(A2,D2.w) ; set high word of keycode *)
(*
        CODE(01581H,02001H); (* move.b  D1,1(A2,D2.w) ; set high word of keycode *)
*)
        (* nokey: *)
(* ks *)

(***)   (* -2 bytes *)
        CODE(01580H,02003H); (* move.b D0,3(A2,D2.w) ; *) (* put ascii code into buffer *)
(*
        (* move.b (A0,D4.w),3(A2,D2.w) ; *) (* put ascii code into buffer *)
        CODE(015B0H, 04000H, 02003H);
*)
      (**...**)
      (** 28 bytes in this new inserted cr/lf handler...
        should check here if (A0,D4.w) is CR and 1(A0,D4.w) is LF, then
        set hi byte of word 1(A2,D2.w) to 01CH for Return key, and 
        inc (A3) which is sendcount. 
      **)
        CODE(01A3CH,0000DH); (* move.b  #13,D5  ; CR  can't do cr/lf together if at odd address *)
        CODE(0BA30H,04000H); (* cmp.b (A0,D4.w),D5  ; is CR? *)
        CODE(0662CH);  (* bne.s notcr  #44(pc) adjust offset !!!*)
(*
        CODE(06634H);  (* bne.s notcr  #52(pc) adjust offset !!!*)
*)
(*
        CODE(06632H);  (* bne.s notcr  #50(pc) adjust offset !!!*)
*)    
        CODE(01A3CH,0000AH); (* move.b  #10,D5  ; LF *)
        CODE(0BA30H,04001H); (* cmp.b  1(A0,D4.w),D5 *)
        CODE(06622H); (* bne.s notcr #34(pc) adjust offset !!! *)
(*
        CODE(0662AH); (* bne.s notcr #42(pc) adjust offset !!! *)
*)
(*
        CODE(06628H); (* bne.s notcr #40(pc) adjust offset !!! *)
*)  
    (*** 2.30, +12 bytes ***)
        (* tst.b (A6)   ; strip cr/lf ? *)
        CODE(04A16H); 
(*
        (* beq.s  skipret #36(pc)   offset!!! *)
        CODE(06724H);
*)
(*
        (* beq.s  skipstrip #30(pc)   offset!!! *)
        CODE(0671EH);
*)
        (* beq.s  skipret #28(pc)   offset!!! *)
        CODE(0671CH);

(**#*)
   (* 20 bytes in mult cr/lf section *)
        (* add test for multiple cr/lf, 2/7/92 *)
        (* test if preceding two bytes are cr/lf; if so branch to skipstrip *)
        CODE(01A3CH,0000DH); (* move.b  #13,D5  ; CR  can't do cr/lf together if at odd address *)
        CODE(0BA30H,040FEH); (* cmp.b -2(A0,D4.w),D5  ; is CR? *)
        CODE(0660AH);  (* bne.s dostrip #10(pc) adjust offset !!!*)
    
        CODE(01A3CH,0000AH); (* move.b  #10,D5  ; LF *)
        CODE(0BA30H,040FFH); (* cmp.b  -1(A0,D4.w),D5 *)
(*
        CODE(06710H); (* beq.s skipret #16(pc) adjust offset !!! *)
*)
(*
        CODE(0670AH); (* beq.s skipstrip #10(pc) adjust offset !!! *)
*)
        CODE(06708H); (* beq.s skipret #8(pc) adjust offset !!! *)
(*#**)
        (* label dostrip: *)
(* add 2 bytes for high word of space keycode 2/9/92 *)
        (* or just use move.l, but won't work if ever at odd address *)
        (* move.l #$390020,(A2,D2.w) ; replace CR keycode with space *)
        CODE(025BCH,00039H,00020H,02000H);
(* *)
(**
        (* move.b #32,3(A2,D2.w)  ; replace cr with space *)
        CODE(015BCH,00020H,02003H);

        (* move.b #$39,1(A2,D2.w) ; set keycode word of space char *)
**)
(*
     (* -8 bytes *)
        (* bra.s  skipret ; skip over placement of 1C in hi byte, offset !!! *)
        CODE(06006H);
    (***)
    (* label: skipstrip *) (* not needed if we already added all keycodes *)
        CODE(015BCH,0001CH,02001H);  (* move.b  #$1C,1(A2,D2.w) ; set high word of Return key keycode *)
*)
    (* label: skipret *)
        CODE(05253H);        (* addq.w  #1,(A3) *)
    (* label: notcr *)
  (*
     if instead of sending CR, user wants cr/lf stripped and replaced by 
     a space, I would first have an alert upon hitting Alt-K that sets a 
     boolean variable that sets D6 upon entry to the machine code stuff.
     Then when find a cr/lf before putting in the $1C do a tst.b of D6 and
     if set move.b #32,2(A2,D2.w) and skip over the move.b #$1C line.
  *)
        (* successfully copied char to buffer so set tail:= tmptail **)
        (* switched these two 2/9/92... *)

        (* addq.w #1,(A3); inc(sendcount) *)
        CODE(05253H); (* 0101 0010 0101 0011 *)

        (* move.w D2,(A4) *) (* set true tail:= tmptail *)
        CODE(03882H); (* is flag to TOS that a char awaits application *)

(*c*)
     (* end: *)

        (* RTS *)
        CODE(04E75H); (* 0100 1110 0111 0101 *)

      (****** End of VBL routine. ******)
      (***********************************)

        (* restore used registers from installing vbl routine *)
        SETREG(A4, saveA4);
        SETREG(A5, saveA5);
      ELSE (* no room found in vbl queue *)
        Super(stack); (* back out of super mode for AES call *)
        dummy:= FormAlert(1,'[1][No Room in VBL Queue][ OK ]');
        stack:= 0; (* 2.36 *)
        Super(stack); (* back into super mode *)
      END; (* if found open vbi slot *)
      Super(stack); (* back out of super mode *)
(***^
    END; (* if not cancel from stripcr alert *)
  END; (* if isblock, install vbl routine to send text to kbd buffer *)
^***)
  (*213*)
  kwiksend:= FALSE;
END DoKwiksend;

(**
PROCEDURE Shift(number: LONGCARD; nbits: CARDINAL; isleft: BOOLEAN);
(* D0 will be number, D1 will be nbits *)
BEGIN
  (* save D1 contents just in case *)
  tmplong:= REGISTER(1); (* D1 *)
  IF isleft THEN
    SETREG(D0, number);
    SETREG(D1, nbits);
    CODE(0E3A8H); (* 1110 0011 1010 1000 lsl.l d1,d0 *)
    number:= REGISTER(D0);
  ELSE (* is lsr *)
    SETREG(D0, number);
    SETREG(D1, nbits);
    CODE(0E2A8H); (* 1110 0010 1010 1000 lsr.l d1,d0 *)
    number:= REGISTER(D0);
  END; (* if isleft *)
  SETREG(D1, tmplong); (* restore *)
END Shift;
**)

PROCEDURE Swapadd(number, low: CARDINAL): LONGCARD;
VAR tmplong,tmplong1, longret: LONGCARD;
BEGIN
  tmplong1:= LONGCARD(REGISTER(D1));
  tmplong:= 0;
  SETREG(D0, tmplong); (* ensure it's zero *)
  SETREG(D0, number);
  SETREG(D1, low);
  CODE(04840H); (* 0100 1000 0100 0000  swap D0 *)
  CODE(0D041H); (* 1101 0000 0100 0001  add.w D1,D0 *)
  longret:= LONGCARD(REGISTER(D0));
  SETREG(D1, tmplong1);
  RETURN longret;
END Swapadd;
(*test*)

(*test*
PROCEDURE Test(longc: LONGCARD);
VAR longstrg: ARRAY[0..8] OF CHAR; (* for 8 hex digits *)
BEGIN
  Cardtostrg(longc, longstrg, TRUE, 8);
  StringZap(longstrg);
END Test;
*test*)

(* ------------------------------------------------------------------- *)

BEGIN (* main *)
  LineAinit;
  InitWinSize;
  Init;  (* assigns all variables that can be done before opening window *)
         (* needs scrnmaxdispln from LineAinit for Reg versions *)
  (* InitResource *)

  i:= 0; (* this is needed again here seemingly due to a compiler bug *)
  last:= 0; (* ?? *)
(*ds*)
  IF cfg.autoload THEN
    cfg.eollen:= 2; (* force text mode *)
    (* read default file into buffer (& put cursor at end?) *)
    Concat(cfg.oldpath, cfg.fsel0, fsel);
(*
    CODE(0A00AH); (* lineA Hide mouse *) (* in case of failed load *)
                  (* don't need now with mreset in filealert *)
*)
    ok:= LoadFile(fsel, FALSE);

(**
    IF daccTitle[0] <> 0C THEN (* is running as acc *)
**)
      (** force mouse to show **)
(**
      mresetptr^:= 0; (* reset flag *)
**
      mhideptr^:= 1;
**)
      (* no vdihandle yet, so must use lineA ? *)
      Showmouse; (* lineA Show mouse *)
(**
    END; (* if acc & needs mouse *)
**)
  END; (* if autoload *)
(*ds*)
  eventflags:=
               GEMAESbase.KeyboardEvent +
               GEMAESbase.ButtonEvent   +
               GEMAESbase.Mouse1Event   +
               GEMAESbase.MesageEvent;
               (* GEMAESbase.TimerEvent; *)
  (* Check if prg or acc *)
  IF daccTitle[0] <> 0C THEN (* is running as acc *)
    VDIHandle:= -1; (* to know there's no vdihandle & no window is open *)
    REPEAT
      forcefull:= FALSE;
      EventMessage(ADR(pipeBuff));
      IF pipeBuff[0] = 1000 THEN (* STENO_APPEND_LINE = 1000 *)
        (* No VDI handle exists here! *)
        (* Stalker has a line of text ready to send *)
        Capture(FALSE); (* do NOT show text, since window is NOT open *)
      ELSIF (pipeBuff[0] = NEOACCINI) & (pipeBuff[3] = NEOACCMAGIC) THEN
        neoadr:= ADDRESS(Swapadd(pipeBuff[4], pipeBuff[5]));
        neoID:= pipeBuff[6];
      ELSIF (pipeBuff[0] = NEOACCBAD) & (pipeBuff[3] = NEOACCMAGIC) THEN
        neoadr:= ADR(pipeBuff); (* use this as null address *)
(**)
      ELSIF (pipeBuff[0] = 53) THEN  (* Stalker EM_PASTE to Steno *)
       (** mergefile requires open window? **)
        PasteBlk(FALSE, TRUE); (* colblk, fromclip *)
(**)
      ELSIF (pipeBuff[0] = GEMAESbase.AccessoryOpen)
       OR (pipeBuff[0] = NEOACOPEN) (* 88 = Steno invoked from Stalker *)
        (* Add for full NeoDesk ACC support 3.02 *)
       OR (pipeBuff[0] = NEOACCPAS)
       OR (pipeBuff[0] = NEOCLIRUN) THEN
        (* User clicked on THIS accessory or called it with msgpipe *)
        xfertype:= 0; (* general init *)
        ok:= TRUE;
        IF ((pipeBuff[0] = NEOACCPAS) OR (pipeBuff[0] = NEOCLIRUN))
         & (pipeBuff[3] = NEOACCMAGIC) THEN
          ok:= NeoMsg(); (* note, this changes contents of pipebuff! *)
        ELSIF ((pipeBuff[2] <> 0) & (pipeBuff[5] = 04354H)) THEN (* is EdHak info waiting *)
          aplsend:= pipeBuff[1]; (* who sent me the message *)
          xfertype:= pipeBuff[6];
          ApplRead(Appl, 16, ADR(pipeBuff)); 
          (* used to just check if [5] <> 0 but MultiDesk 2.1 sends something in [5] *)
          forcefull:= BOOLEAN(pipeBuff[0]); (* force only full window *)
          IF forcefull THEN
            cfg.maxdispline:= scrnmaxdispln;
            cfg.wind1X:= fullX;
            cfg.wind1Y:= fullY;
            cfg.wind1W:= fullW;
            wind1H:= fullH;
(*
            cfg.wind1Y:= rowH + rowH - 3; (* 29 mono, 13 color *)
*)
          END;

          tmplong:= Swapadd(pipeBuff[2], pipeBuff[3]);
(*
          tmplong:= tmplong + LONGCARD(pipeBuff[3]);
          INC(tmplong, pipeBuff[3]); (* low word of (filespec) address *)
*)
          ptr1:= ADDRESS(tmplong); (* adr of filespec or buffer *)
          IF xfertype = 1 THEN
            (* decipher filespec into path/name etc, don't try to load *)
            ok:= PassedFile(HIGH(fsel), BOOLEAN(pipeBuff[1])); (* FALSE = don't load it *)
          ELSIF xfertype = 2 THEN
            sendadr:= ptr1;
            (* get total size of receiving application's buffer *)
            sendlim:= Swapadd(pipeBuff[6], pipeBuff[7]);
(*
            sendlim:= LONGCARD(pipeBuff[6]) * 010000H; (* hi word size limit *)
            sendlim:= sendlim + LONGCARD(pipeBuff[7]);
*)
            IF BOOLEAN(pipeBuff[1]) THEN (* "open" whatever is sent *)
              (* get length of his buffer *)
              last:= Swapadd(pipeBuff[4], pipeBuff[5]);
(*
              last:= LONGCARD(pipeBuff[4]) * 010000H; (* hi word *)
              last:= last + LONGCARD(pipeBuff[5]);
*)
              (* Add a check that last < my own buffsize... *)
              IF last > buffsize-2 THEN
                last:= buffsize-2;
              END; (* if need to trim what EdHak receives *)
              (* copy his buffer contents to mine *)
              MoveMem(sendadr, startadr, last);
              (* At done (window close), if xfertype = 2, then do a movemem *)
              Lineptrs(0);
              MiniInit; (* sets i:= 0 among other things *)
            END; (* if open it *)
          END; (* if xfertype *)

        END; (* if Neo or 04354H in msg pipe, special EdHak instructions *)

        IF ok & InitWork() THEN
(*
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[3][Done InitWork][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
*)
          Events;
          (* note: don't want to do this if got ac_close msg from the 
            other application being closed, which would mean alldone=false
          *)
          IF ((xfertype = 2) & alldone) THEN (* send buffer to other application buffer *)
            (* ensure EdHak doesn't send more than receiving app buffer size *)
            tmpadr:= startadr;
            tmplong:= last;
            result:= 1; (* set to not truncated *)
            IF blocktype = 1 (* isblock *) THEN
              tmpadr:= startadr + ADDRESS(blockstart);
              tmplong:= blockend-blockstart;
            END; (* if isblock *)
            IF tmplong > sendlim THEN (* warn user *)
              tmplong:= sendlim;
              result:= 0; (* means was truncated *)
              Showmouse; (* lineA Show mouse *)
              dummy:= FormAlert(1, "[1][Output Truncated|to fit Application][ OK ]");
              CODE(0A00AH); (* lineA Hide mouse *)
            END;
            MoveMem(tmpadr, sendadr, sendlim);
            pipeBuff[0]:= 04354H; (* tell other apl this is an EdHak msg *)
            (* the next two are probably not needed, but maybe desirable? *)
            pipeBuff[1]:= Appl;
            pipeBuff[2]:= 0; (* no bytes beyond 16 *)
            pipeBuff[3]:= SHORT(tmplong DIV 010000H);
            pipeBuff[4]:= SHORT(tmplong MOD 010000H);
            pipeBuff[5]:= result; (* 0 = truncated; 1 = not truncated *)
(* 2.30 *)
            (* Add bit 1 flag parameter to tell QCIS of special exit flag *)
            IF ok THEN (* exit special, QCIS F4 *)
              INC(pipeBuff[5], 2); (* sets bit 1 *)
            END; (* if special flag *)
(* 2.30 *)
            ApplWrite(aplsend, 16, ADR(pipeBuff)); (* std 16 byte msg *)
          END; (* if xfertype = 2 *)
          IF kwiksend & (blocktype = 1) (* isblock *) THEN
            (* see if user wants to strip cr/lf's *)
            (** moved here 2.35 7/8/92 **)
            Showmouse; (* lineA Show mouse *)
            result:= FormAlert(cfg.kwikstrip,"[2][Strip CR/LF's|During Kwiksend ?|(Alt aborts)][No|Yes|Cancel]");
            CODE(0A00AH); (* lineA Hide mouse *)
            IF result <> 3 THEN (* not cancel *)
              cfg.kwikstrip:= result;
              ok:= FALSE; (* don't strip cr/lf *)
              IF result = 2 THEN
                ok:= TRUE; (* strip cr/lf *)
              END; (* if cancel or strip *)
            ELSE
              kwiksend:= FALSE; (* canceled *)
            END;
          ELSE
            kwiksend:= FALSE; (* in case was kwiksend but no block *)
          END;
          CloseVirtualWorkstation(VDIHandle) ;
          VDIHandle:= -1; (* 2.30 1/21/92, for wind open checking *)
          (* no vdihandle anymore, so must use lineA ? *)
          Showmouse; (* lineA Show mouse *)
          IF kwiksend (* & (daccTitle[0] <> 0C) *) THEN (* moved inside last if's 7/8/92 *)
            DoKwiksend;
          END;
        END; (* if init resource *)
      END; (* if call Diary.acc *)
(****)
(*
      WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy); (* wx,wy,ww,wh); *)
      Cardtostrg(LONGCARD(topwind), cardstrg, FALSE); (* gets in 5 digit format *)
      StringZap(cardstrg);
      Wait;
      Cardtostrg(LONGCARD(Window1), cardstrg, FALSE); (* gets in 5 digit format *)
      StringZap(cardstrg);
      Wait;
*)
(*  There's no way to ensure that a proper window is open to receive
    the output, so make user responsible.
*)
    UNTIL FALSE; (* never end *)
  ELSE (* running as prg *)
    forcefull:= FALSE;
(**
    cfg.maxdispline:= scrnmaxdispln; (* force 'full' window *)
**)
    ptr1:= ADDRESS(BasePageAddress) + ADDRESS(128);
    ok:= TRUE;
    IF ptr1^ <> 0C THEN (* passed filename as from installed appl *)
      j:= ORD(ptr1^); (* length of command tail string *)
      INC(ptr1);
      ok:= PassedFile(j, TRUE); (* do load it *)
    END; (* if passed a filename in basepage *)
    IF ok & InitWork() THEN (* don't bother if passedfile was canceled *)
(*
      ResourceGetAddr(GEMAESbase.RTree, MENUTREE, MenuTree) ;
*)
      MenuTree:= TreeAddr^[MENUTREE];
      MenuBar(MenuTree,1) ;
      (**)
      Events;
    END; (* if init resource *)
  END; (* if acc or prg *)

(*********
  (* try using my own DTA 2.30 1/30/92 *)
  (* SetDTA(olddta); *)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  SETREG(A0, olddta);
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
***********)
  IF kwiksend & (blocktype = 1) (* isblock *) THEN
    (* see if user wants to strip cr/lf's *)
    (** moved here 2.35 7/8/92 **)
    Showmouse; (* lineA Show mouse *)
    result:= FormAlert(cfg.kwikstrip,"[2][Strip CR/LF's|During Kwiksend ?|(Alt aborts)][No|Yes|Cancel]");
    CODE(0A00AH); (* lineA Hide mouse *)
    IF result <> 3 THEN (* not cancel *)
      cfg.kwikstrip:= result;
      ok:= FALSE; (* don't strip cr/lf *)
      IF result = 2 THEN
        ok:= TRUE; (* strip cr/lf *)
      END; (* if cancel or strip *)
    ELSE
      kwiksend:= FALSE; (* canceled *)
    END;
  ELSE
    kwiksend:= FALSE; (* in case was kwiksend but no block *)
  END;

  CloseVirtualWorkstation(VDIHandle) ;
  Showmouse; (* lineA Show mouse *)
  MenuBar(MenuTree, 0); (* erase menu bar, supposedly a good idea *)
  ApplExit; (* needed only when run as application, not as acc *)
(**)
  IF kwiksend THEN
    DoKwiksend;
  END;
(**)
END EdPlus.
