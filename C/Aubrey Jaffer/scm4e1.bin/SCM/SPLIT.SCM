;;;; "split.scm", split input, output, and error streams into windows.
;;; Copyright (C) 1993, 1994 Aubrey Jaffer.
;;; See the file `COPYING' for terms applying to this program.

(require 'curses)
(define *stdscr* (initscr))
(nocbreak)
(echo)
(nl)
(define subwindow-height (max 2 (quotient (output-port-height) 5)))
(define *output-window*
  (newwin (- (output-port-height) (* 2 subwindow-height) 2)
	  (output-port-width)
	  0
	  0))
(define *input-window*
  (newwin subwindow-height
	  (output-port-width)
	  (- (output-port-height) (* 2 subwindow-height) 1)
	  0))
(define *error-window*
  (newwin subwindow-height
	  (output-port-width)
	  (- (output-port-height) subwindow-height)
	  0))
(wmove *stdscr* (- (output-port-height) subwindow-height 1) 0)
(wstandout *stdscr*)
(display (make-string (output-port-width) #\-) *stdscr*)
(wmove *stdscr* (- (output-port-height) (* 2 subwindow-height) 2) 0)
(display (make-string (output-port-width) #\-) *stdscr*)
(wstandend *stdscr*)
(touchwin *stdscr*)
(force-output *stdscr*)
(scrollok *output-window* #t)
(scrollok *input-window* #t)
(scrollok *error-window* #t)
(define *default-output-port* (set-current-output-port *output-window*))
(define *default-input-port* (set-current-input-port *input-window*))
(define *default-error-port* (set-current-error-port *error-window*))
(leaveok *output-window* #t)
(leaveok *input-window* #f)
(leaveok *error-window* #t)

(define (unsplit)
  (cond ((endwin)
	 (set-current-output-port *default-output-port*)
	 (set-current-input-port *default-input-port*)
	 (set-current-error-port *default-error-port*))))
