/***************************************************************************
 * This program is Copyright (C) 1991-1996 by C.H.Lindsey, University of   *
 * Manchester.  (X)JOVETOOL is provided to you without charge, and with no *
 * warranty.  You may give away copies of (X)JOVETOOL, including sources,  *
 * provided that this notice is included in all the files, except insofar  *
 * as a more specific copyright notices attaches to the file (x)jovetool.c *
 ***************************************************************************/

/*
 * Note that the key bindings shown in the various menus below include some
 * for the Sun function keys. These presuppose that the provided jove.rc.sun
 * or jove.rc.sun-cmd (or even jove.rc.xterm) is being used. If some other
 * conventional binding is in use locally, this file should be ammended
 * accordingly.
 *
 * The following commands are not given menu items.
 * - because they involve some kind of self-insertion:
 *	digit-[0-9]
 *	digit-minus
 *	paren-flash
 *	self-insert
 *
 * - because it is not usefully executed:
 *	unbound
 *
 * - because they are mouse actions:
 *	xj-mouse-copy-cut
 *	xj-mouse-line
 *	xj-mouse-mark
 *	xj-mouse-point
 *	xj-mouse-word
 *	xj-mouse-yank
 *	xt-mouse-mark
 *	xt-mouse-point
 *	xt-mouse-up
 *
 *
 * The "xt-mouse" variable is not supported because it doesn't
 * apply to this "terminal".
 */

VARPROC(var_variables_proc, variables_menu)
VARPROC(var_files_proc, var_files_menu)
VARPROC(var_modes_proc, var_modes_menu)
VARPROC(var_move_proc, var_move_menu)
VARPROC(var_search_proc, var_search_menu)
VARPROC(var_process_proc, var_process_menu)
VARPROC(var_compile_proc, var_compile_menu)
VARPROC(var_format_proc, var_format_menu)
VARPROC(var_misc_proc, var_misc_menu)

void
menu_init()
{
	describing = printing = 0;

	empty_menu_item = menu_create_item(
		MENU_STRING, "", MENU_CLIENT_DATA, "",
		MENU_NOTIFY_PROC, print_client_data, 0
		);

	empty_menu = menu_create(
			MENU_APPEND_ITEM, empty_menu_item,
		0);

	on_off_menu = menu_create(
		MENU_NOTIFY_PROC, menu_return_item,
			MENU_APPEND_ITEM, empty_menu_item,
			MENU_ITEM, MENU_STRING, "on", MENU_CLIENT_DATA, "on", MENU_ACTION_PROC, sp_printit,  0,
			MENU_ITEM, MENU_STRING, "off", MENU_CLIENT_DATA, "off", MENU_ACTION_PROC, sp_printit, 0,
		0);

VARGROUP(var_files_menu)
			VARIBOOL("allow-bad-characters-in-filenames")
#ifdef F_COMPLETION
			VARIABLE("bad-filename-extensions")
			VARIBOOL("display-filenames-with-bad-extensions")
			VARIBOOL("expand-environment-variables")
#endif
#ifndef MSDOS
			VARIABLE("file-creation-mode")
#endif
			VARIBOOL("files-should-end-with-newline")
#ifdef BACKUPFILES
			VARIBOOL("make-backup-files")
#endif
			VARIABLE("tag-file")
	0);

VARGROUP(var_modes_menu)
			VARIABLE("c-argument-indentation")
			VARIABLE("c-indentation-increment")
			VARIABLE("paren-flash-delay")
	0);

VARGROUP(var_move_menu)
			VARIABLE("mark-threshold")
			VARIBOOL("scroll-all-lines")
#ifdef	HIGHLIGHTING
			VARIBOOL("scroll-bar")
#endif
			VARIABLE("scroll-step")
	0);

VARGROUP(var_search_menu)
			VARIBOOL("case-ignore-search")
			VARIBOOL("match-regular-expressions")
			VARIABLE("search-exit-char")
			VARIBOOL("wrap-search")
	0);

VARGROUP(var_process_menu)
#ifdef IPROCS
			VARIABLE("dbx-format-string")
#endif
#ifdef IPROCS
			VARIABLE("process-prompt")
#endif
#ifdef SUBSHELL
			VARIABLE("shell")
			VARIABLE("shell-flags")
#endif
			VARIBOOL("send-typeout-to-buffer")
#if defined(SUBSHELL) || defined(IPROCS)
			VARIBOOL("wrap-process-lines")
#endif
	0);

VARGROUP(var_compile_menu)
			VARIABLE("error-format-string")
			VARIABLE("error-window-size")
#ifdef SUBSHELL
			VARIBOOL("write-files-on-make")
#endif
	0);

VARGROUP(var_format_menu)
#ifdef CMT_FMT
			VARIABLE("comment-format")
#endif
			VARIABLE("left-margin")
			VARIABLE("paragraph-delimiter-pattern")
			VARIABLE("right-margin")
			VARIBOOL("space-sentence-2")
			VARIABLE("tab-width")
	0);

VARGROUP(var_abbrev_menu)
#ifdef ABBREV
			VARIBOOL("auto-case-abbrev")
#endif
	0);

VARGROUP(var_misc_menu)
			VARIABLE("abort-char")
#ifdef UNIX
			VARIBOOL("allow-^S-and-^Q")
#endif /* UNIX */
#ifdef BIFF
			VARIBOOL("disable-biff")
#endif
#ifdef IBMPCDOS
			VARIBOOL("enhanced-keyboard")
#endif
#ifdef HIGHLIGHTING
# ifdef IBMPCDOS
			VARIABLE("highlight-attribute")
# endif
			VARIABLE("highlight-mark")
#endif /* HIGHLIGHTING */
#ifdef	UNIX
			VARIABLE("interrupt-character")
#endif	/* UNIX */
#if defined(USE_CTYPE) && !defined(NO_SETLOCALE)
			VARIABLE("lc-ctype")
#endif
#ifdef MAC
			VARIBOOL("macify")
#endif
#ifdef UNIX
			VARIABLE("mailbox")
			VARIABLE("mail-check-frequency")
#endif /* UNIX */
			VARIBOOL("meta-key")
			VARIABLE("mode-line")
#ifdef IBMPCDOS
			VARIABLE("mode-line-attribute")
#endif
			VARIBOOL("mode-line-should-standout")
			VARIBOOL("one-key-confirmation")
#ifdef RECOVER
			VARIABLE("sync-frequency")
#endif /* RECOVER */
#ifdef IBMPCDOS
			VARIABLE("text-attribute")
#endif /* IBMPCDOS */
			VARIABLE("tmp-file-pathname")
#ifdef UNIX
			VARIABLE("update-time-frequency")
#endif /* UNIX */
#ifdef ID_CHAR
			VARIBOOL("use-i/d-char")
#endif
			VARIBOOL("visible-bell")
	0);

	variables_menu = menu_create(
		MENU_NOTIFY_PROC, print_client_data,
		MENU_APPEND_ITEM, empty_menu_item,
		GROUPNAME(var_files_menu, "Files")
		GROUPNAME(var_modes_menu, "Modes")
		GROUPNAME(var_move_menu, "Movement")
		GROUPNAME(var_search_menu, "Search/Replace")
		GROUPNAME(var_process_menu, "Processes/Shell")
		GROUPNAME(var_compile_menu, "Compiling")
		GROUPNAME(var_format_menu, "Formatting")
#if defined(ABBREV)
		GROUPNAME(var_abbrev_menu, "Abbreviations")
#endif
		GROUPNAME(var_misc_menu, "Miscellaneous")
		0);

GROUP(help_menu)
	MENU_GEN_PROC, do_describing_proc,
	FUNCPULLPROC(" E ? describe-command", "describe-command",  commands_proc)
	FUNCPULL("     describe-variable", "describe-variable",  variables_menu)
	FUNCTION("^X ? describe-key", "describe-key")
	FUNCTION("     describe-bindings", "describe-bindings")
	FUNCTION("     apropos", "apropos")
	FUNCTION("Help keychart (mac)", "execute-macro keychart")
	0);

GROUP(file_menu)
	FUNCTION("     append-region", "append-region")
	FUNCTION("     auto-execute-command", "auto-execute-command")
	FUNCTION("     auto-execute-macro", "auto-execute-macro")
	FUNCTION("F12  find-file", "find-file")
	FUNCTION("^X T find-tag", "find-tag")
	FUNCTION("     find-tag-at-point", "find-tag-at-point")
	FUNCTION("^X^I insert-file", "insert-file")
	FUNCTION("^X^S save-file", "save-file")
	FUNCTION("^X^V visit-file", "visit-file")
	FUNCTION("^X^W write-file", "write-file")
	FUNCTION("^X^M write-modified-files", "write-modified-files")
	FUNCTION("     write-region", "write-region")
	FUNCPULLPROC("VARS print", "print",  var_files_proc)
	FUNCPULLPROC("VARS set", "set",  var_files_proc)
	0);

GROUP(mode_menu)
#if defined(LISP)
	FUNCTION("     add-lisp-special", "add-lisp-special")
#endif
	FUNCTION("     auto-fill-mode", "auto-fill-mode")
	FUNCTION("     auto-indent-mode", "auto-indent-mode")
	FUNCTION("     c-mode", "c-mode")
	FUNCTION("     fundamental-mode", "fundamental-mode")
#if defined(LISP)
	FUNCTION("     lisp-mode", "lisp-mode")
#endif
	FUNCTION("L1   over-write-mode", "over-write-mode")
#if defined(IPROCS)
	FUNCTION("     process-dbx-output", "process-dbx-output")
#endif
	FUNCTION("     read-only-mode", "read-only-mode")
	FUNCTION("     show-match-mode", "show-match-mode")
	FUNCTION("     text-mode", "text-mode")
	FUNCPULLPROC("VARS print", "print",  var_modes_proc)
	FUNCPULLPROC("VARS set", "set",  var_modes_proc)
	0);

GROUP(move_menu)
	FUNCTION("<-   backward-character", "backward-character")
	FUNCTION("R2   backward-list", "backward-list")
	FUNCTION("     backward-paragraph", "backward-paragraph")
	FUNCTION(" E^B backward-s-expression", "backward-s-expression")
	FUNCTION(" E A backward-sentence", "backward-sentence")
	FUNCTION(" E^U backward-up-list", "backward-up-list")
	FUNCTION("R6   backward-word", "backward-word")
	FUNCTION("R7   beginning-of-file", "beginning-of-file")
	FUNCTION("R1   beginning-of-line", "beginning-of-line")
	FUNCTION(" E , beginning-of-window", "beginning-of-window")
	FUNCTION(" E^D down-list", "down-list")
	FUNCTION("R13  end-of-file", "end-of-file")
	FUNCTION("R4   end-of-line", "end-of-line")
	FUNCTION(" E . end-of-window", "end-of-window")
	FUNCTION(" E M first-non-blank", "first-non-blank")
	FUNCTION("->   forward-character", "forward-character")
	FUNCTION("R5   forward-list", "forward-list")
	FUNCTION(" E ] forward-paragraph", "forward-paragraph")
	FUNCTION(" E^F forward-s-expression", "forward-s-expression")
	FUNCTION(" E E forward-sentence", "forward-sentence")
	FUNCTION("R6   forward-word", "forward-word")
	FUNCTION(" E G goto-line", "goto-line")
	FUNCTION("DOWN next-line", "next-line")
	FUNCTION("R15  next-page", "next-page")
	FUNCTION("UP   previous-line", "previous-line")
	FUNCTION("R9   previous-page", "previous-page")
	FUNCTION("KP_- scroll-down", "scroll-down")
	FUNCTION("     scroll-left", "scroll-left")
	FUNCTION("     scroll-right", "scroll-right")
	FUNCTION("KP_+ scroll-up", "scroll-up")
	FUNCTION("     shift-region-left", "shift-region-left")
	FUNCTION("     shift-region-right", "shift-region-right")
	FUNCPULLPROC("VARS print", "print",  var_move_proc)
	FUNCPULLPROC("VARS set", "set",  var_move_proc)
	0);

GROUP(bind_menu)
	FUNCTION("     bind-keymap-to-key", "bind-keymap-to-key")
	FUNCTION("     bind-macro-to-key", "bind-macro-to-key")
#if defined(ABBREV)
	FUNCTION("     bind-macro-to-word-abbrev", "bind-macro-to-word-abbrev")
#endif
	FUNCTION("     bind-to-key", "bind-to-key")
	FUNCTION("     local-bind-keymap-to-key", "local-bind-keymap-to-key")
	FUNCTION("     local-bind-macro-to-key", "local-bind-macro-to-key")
	FUNCTION("     local-bind-to-key", "local-bind-to-key")
	FUNCTION("     process-bind-keymap-to-key", "process-bind-keymap-to-key")
	FUNCTION("     process-bind-macro-to-key", "process-bind-macro-to-key")
	FUNCTION("     process-bind-to-key", "process-bind-to-key")
	0);

GROUP(macro_menu)
	FUNCTION("^X ( begin-kbd-macro", "begin-kbd-macro")
	FUNCTION("     define-macro", "define-macro")
	FUNCTION("^X ) end-kbd-macro", "end-kbd-macro")
	FUNCTION("^X E execute-kbd-macro", "execute-kbd-macro")
	FUNCTION("     execute-macro", "execute-macro")
	FUNCTION(" E I make-macro-interactive", "make-macro-interactive")
	FUNCTION("     name-kbd-macro", "name-kbd-macro")
	FUNCTION("     start-remembering", "start-remembering")
	FUNCTION("     stop-remembering", "stop-remembering")
	FUNCTION("     write-macros-to-file", "write-macros-to-file")
	0);

GROUP(buffer_menu)
	FUNCTION("     buffer-position", "buffer-position")
	FUNCTION("^X K delete-buffer", "delete-buffer")
	FUNCTION("     erase-buffer", "erase-buffer")
	FUNCTION("     kill-some-buffers", "kill-some-buffers")
	FUNCTION("F10  list-buffers", "list-buffers")
	FUNCTION("     make-buffer-unmodified", "make-buffer-unmodified")
	FUNCTION("     rename-buffer", "rename-buffer")
	FUNCTION("F11  select-buffer", "select-buffer")
	FUNCTION("     select-buffer-1", "select-buffer-1")
	FUNCTION("     select-buffer-2", "select-buffer-2")
	FUNCTION("     select-buffer-3", "select-buffer-3")
	FUNCTION("     select-buffer-4", "select-buffer-4")
	FUNCTION("     select-buffer-5", "select-buffer-5")
	FUNCTION("     select-buffer-6", "select-buffer-6")
	FUNCTION("     select-buffer-7", "select-buffer-7")
	FUNCTION("     select-buffer-8", "select-buffer-8")
	FUNCTION("     select-buffer-9", "select-buffer-9")
	FUNCTION("     select-buffer-10", "select-buffer-10")
	0);

GROUP(window_menu)
	FUNCTION("F4   delete-other-windows", "delete-other-windows")
	FUNCTION("F5   delete-current-window", "delete-current-window")
	FUNCTION("     goto-window-with-buffer", "goto-window-with-buffer")
	FUNCTION("F6   grow-window", "grow-window")
	FUNCTION("F3   next-window", "next-window")
	FUNCTION("     number-lines-in-window", "number-lines-in-window")
	FUNCTION(" E^V page-next-window", "page-next-window")
	FUNCTION("^X P previous-window", "previous-window")
	FUNCTION("     shrink-window", "shrink-window")
	FUNCTION("F2   split-current-window", "split-current-window")
	FUNCTION("     visible-spaces-in-window", "visible-spaces-in-window")
	FUNCTION("^X 4 window-find", "window-find")
	0);

GROUP(mark_menu)
	FUNCTION("     case-region-lower", "case-region-lower")
	FUNCTION("     case-region-upper", "case-region-upper")
	FUNCTION("L6   copy-region", "copy-region")
	FUNCTION("L4   exchange-point-and-mark", "exchange-point-and-mark")
#if defined(SUBSHELL)
	FUNCTION("     filter-region", "filter-region")
#endif
	FUNCTION("L10  kill-region", "kill-region")
	FUNCTION("     pop-mark", "pop-mark")
	FUNCTION("     replace-in-region", "replace-in-region")
	FUNCTION("L3   set-mark", "set-mark")
	FUNCTION("L8   yank", "yank")
	FUNCTION(" E Y yank-pop", "yank-pop")
	0);

GROUP(edit_menu)
	FUNCTION("     case-character-capitalize", "case-character-capitalize")
	FUNCTION("     case-region-lower", "case-region-lower")
	FUNCTION("     case-region-upper", "case-region-upper")
	FUNCTION(" E C case-word-capitalize", "case-word-capitalize")
	FUNCTION(" E L case-word-lower", "case-word-lower")
	FUNCTION(" E U case-word-upper", "case-word-upper")
	FUNCTION("     character-to-octal-insert", "character-to-octal-insert")
	FUNCTION("^X^O delete-blank-lines", "delete-blank-lines")
	FUNCTION("KP_. kill-line (mac)", "execute-macro kill-line")
	FUNCTION("  ^D delete-next-character", "delete-next-character")
	FUNCTION("DEL  delete-previous-character", "delete-previous-character")
	FUNCTION(" E \\ delete-white-space", "delete-white-space")
	FUNCTION(" E D kill-next-word", "kill-next-word")
	FUNCTION(" EDL kill-previous-word", "kill-previous-word")
	FUNCTION(" E^K kill-s-expression", "kill-s-expression")
	FUNCTION("^XDL kill-to-beginning-of-sentence", "kill-to-beginning-of-sentence")
	FUNCTION("  ^K kill-to-end-of-line", "kill-to-end-of-line")
	FUNCTION(" E K kill-to-end-of-sentence", "kill-to-end-of-sentence")
	FUNCTION("RET  newline", "newline")
	FUNCTION("KP_0 newline-and-backup", "newline-and-backup")
	FUNCTION("LF   newline-and-indent", "newline-and-indent")
	FUNCTION("  ^Q quoted-insert", "quoted-insert")
	FUNCTION("  ^T transpose-characters", "transpose-characters")
	FUNCTION("^X^T transpose-lines", "transpose-lines")
	0);

GROUP(directory_menu)
	FUNCTION("     cd", "cd")
	FUNCTION("     dirs", "dirs")
	FUNCTION("     popd", "popd")
	FUNCTION("     pushd", "pushd")
	FUNCTION("     pushlibd", "pushlibd")
	FUNCTION("     pwd", "pwd")
	0);

GROUP(compile_menu)
#if defined(SUBSHELL)
	FUNCTION("^X^E compile-it", "compile-it")
#endif
	FUNCTION("     current-error", "current-error")
	FUNCTION("^X^N next-error", "next-error")
	FUNCTION("     parse-errors", "parse-errors")
#if defined(SPELL)
	FUNCTION("     parse-spelling-errors-in-buffer", "parse-spelling-errors-in-buffer")
#endif
	FUNCTION("^X^P previous-error", "previous-error")
#if defined(SPELL)
	FUNCTION("F7   spell-buffer", "spell-buffer")
	FUNCPULLPROC("VARS print", "print",  var_compile_proc)
	FUNCPULLPROC("VARS set", "set",  var_compile_proc)
	0);

GROUP(format_menu)
#if defined(CMT_FMT)
	FUNCTION("F8   fill-comment", "fill-comment")
#endif /* CMT_FMT */
	FUNCTION("F9   fill-paragraph", "fill-paragraph")
	FUNCTION("     fill-region", "fill-region")
#if defined(LISP)
	FUNCTION("     grind-s-expr", "grind-s-expr")
#endif
	FUNCTION("TAB  handle-tab", "handle-tab")
	FUNCTION("     left-margin-here", "left-margin-here")
	FUNCTION("     right-margin-here", "right-margin-here")
#endif
	FUNCPULLPROC("VARS print", "print",  var_format_proc)
	FUNCPULLPROC("VARS set", "set",  var_format_proc)
	0);

GROUP(search_menu)
	FUNCTION("     i-search-forward", "i-search-forward")
	FUNCTION("     i-search-reverse", "i-search-reverse")
	FUNCTION(" E Q query-replace-string", "query-replace-string")
	FUNCTION("     replace-in-region", "replace-in-region")
	FUNCTION(" E R replace-string", "replace-string")
	FUNCTION("L9   search-forward", "search-forward")
	FUNCTION("     search-forward-nd", "search-forward-nd")
	FUNCTION("EL9  search-reverse", "search-reverse")
	FUNCTION("     search-reverse-nd", "search-reverse-nd")
	FUNCPULLPROC("VARS print", "print",  var_search_proc)
	FUNCPULLPROC("VARS set", "set",  var_search_proc)
	0);

GROUP(process_menu)
#if defined(PTYPROCS)
	FUNCTION("     continue-process", "continue-process")
	FUNCTION("^C^Y dstop-process", "dstop-process")
	FUNCTION("^C^D eof-process", "eof-process")
#endif
#if defined(IPROCS)
	FUNCTION("     i-shell-command", "i-shell-command")
	FUNCTION("^C^C interrupt-process", "interrupt-process")
	FUNCTION("     kill-process", "kill-process")
	FUNCTION("     list-processes", "list-processes")
	FUNCTION("CR   process-newline", "process-newline")
	FUNCTION("     process-send-data-no-return", "process-send-data-no-return")
#endif
#if defined(SUBSHELL)
	FUNCTION("     push-shell", "push-shell")
#endif
#if defined(IPROCS)
	FUNCTION("^C^\\ quit-process", "quit-process")
#endif
#if defined(IPROCS)	/* for GNU compatibility */
	FUNCTION("Ent  shell", "shell")
#endif
#if defined(SUBSHELL)
	FUNCTION("^X ! shell-command", "shell-command")
	FUNCTION("     shell-command-no-buffer", "shell-command-no-buffer")
	FUNCTION("     shell-command-to-buffer", "shell-command-to-buffer")
	FUNCTION("     shell-command-with-typeout", "shell-command-with-typeout")
#endif
#if defined(PTYPROCS)
	FUNCTION("^C^Z stop-process", "stop-process")
#endif
	FUNCPULLPROC("VARS print", "print",  var_process_proc)
	FUNCPULLPROC("VARS set", "set",  var_process_proc)
	0);

GROUP(abbrev_menu)
#if defined(ABBREV)
	FUNCTION("     define-global-word-abbrev", "define-global-word-abbrev")
	FUNCTION("     define-mode-word-abbrev", "define-mode-word-abbrev")
	FUNCTION("     edit-word-abbrevs", "edit-word-abbrevs")
	FUNCTION("     read-word-abbrev-file", "read-word-abbrev-file")
	FUNCTION("     word-abbrev-mode", "word-abbrev-mode")
	FUNCTION("     write-word-abbrev-file", "write-word-abbrev-file")
#endif
	0);

GROUP(misc_menu)
	FUNCTION(" E^L clear-and-redraw", "clear-and-redraw")
	FUNCTION("     date", "date")
	FUNCTION("     execute-named-command", "execute-named-command")
	FUNCTION("^X^C exit-jove", "exit-jove")
	FUNCTION("  ^U gather-numeric-argument", "gather-numeric-argument")
#if defined(JOB_CONTROL)
	FUNCTION(" E S pause-jove", "pause-jove")
#else
#	ifndef MAC
	FUNCTION(" E S pause-jove", "pause-jove")
#	endif
#endif
	FUNCTION("     recursive-edit", "recursive-edit")
	FUNCTION("  ^L redraw-display", "redraw-display")
	FUNCTION("     source", "source")
	FUNCTION("     string-length", "string-length")
#if defined(JOB_CONTROL)
	FUNCTION("     suspend-jove", "suspend-jove")
#endif
	FUNCTION("     version", "version")
	FUNCPULLPROC("VARS print", "print",  var_misc_proc)
	FUNCPULLPROC("VARS set", "set",  var_misc_proc)
	0);

	main_menu = menu_create(
#ifndef	SUNVIEW
		XV_FONT, font,	/* not in SunView */
#endif
		MENU_NOTIFY_PROC, main_notify,
			GROUPNAME(help_menu, "Help")
			GROUPNAME(file_menu, "Files")
			GROUPNAME(directory_menu, "Directories")
			GROUPNAME(mode_menu, "Modes")
			GROUPNAME(move_menu, "Movement")
			GROUPNAME(edit_menu, "Editing")
			GROUPNAME(search_menu, "Search/Replace")
			GROUPNAME(buffer_menu, "Buffers")
			GROUPNAME(window_menu, "Windows")
			GROUPNAME(mark_menu, "Mark/Region")
			GROUPNAME(process_menu, "Processes/Shell")
			GROUPNAME(compile_menu, "Compiling/Spell")
			GROUPNAME(format_menu, "Formatting")
			GROUPNAME(macro_menu, "Macros")
#if defined(ABBREV)
			GROUPNAME(abbrev_menu, "Abbreviations")
#endif
			GROUPNAME(bind_menu, "Binding")
			GROUPNAME(misc_menu, "Miscellaneous")
			FUNCPULLPROC("VARS print", "print",  var_variables_proc)
			FUNCPULLPROC("VARS set", "set",  var_variables_proc)
		0);

GROUP(another_help_menu)
	FUNCTION(" E ? describe-command", "describe-command")
	FUNCTION("     describe-variable", "describe-variable")
	FUNCTION("^X ? describe-key", "describe-key")
	FUNCTION("     describe-bindings", "describe-bindings")
	FUNCTION("     apropos", "apropos")
	0);

	commands_menu = menu_create(
		MENU_NOTIFY_PROC, sp_printit,
			MENU_APPEND_ITEM, empty_menu_item,
			GROUPNAME(another_help_menu, "Help")
			GROUPNAME(file_menu, "Files")
			GROUPNAME(directory_menu, "Directories")
			GROUPNAME(mode_menu, "Modes")
			GROUPNAME(move_menu, "Movement")
			GROUPNAME(edit_menu, "Editing")
			GROUPNAME(search_menu, "Search/Replace")
			GROUPNAME(buffer_menu, "Buffers")
			GROUPNAME(window_menu, "Windows")
			GROUPNAME(mark_menu, "Mark/Region")
			GROUPNAME(process_menu, "Processes/Shell")
			GROUPNAME(compile_menu, "Compiling/Spell")
			GROUPNAME(format_menu, "Formatting")
			GROUPNAME(macro_menu, "Macros")
#if defined(ABBREV)
			GROUPNAME(abbrev_menu, "Abbreviations")
#endif
			GROUPNAME(bind_menu, "Binding")
			GROUPNAME(misc_menu, "Miscellaneous")
			FUNCTION("VARS print", "print")
			FUNCTION("VARS set", "set")
		0);

}
