;;; Gofer mode for GNU Emacs
;;;
;;; Last update: 6/12/91
;;;
;;; Author: Stuart Clayman,
;;;     Dept. Computer Science,
;;;     University College London
;;;
;;; Email: sclayman@uk.ac.ucl.cs
;;;
;;; Use:
;;; In .emacs put
;;;
;;;   (autoload 'gofer-mode "gofer" "Go into gofer mode" t)
;;;   (autoload 'run-gofer "gofer" "Run gofer as inferior process" t)
;;;   (autoload 'gofer-project "gofer" "Go into a gofer project" t)
;;;
;;;   (set-variable 'auto-mode-alist
;;;        (append '(
;;;         ("\\.gs$" . gofer-mode)   ;; gofer source
;;;     ("\\.gp$" . gofer-project) ;; gofer project files
;;;     ) auto-mode-alist))
;;;
;;;  All gofer source files should end in .gs
;;;  All gofer project files should end in .gp
;;;
;;;  In gofer source files
;;; ESC \C-x
;;; \C-c \C-c
;;; \C-c l      loads the current file
;;;
;;; \C-u ESC \C-x
;;; \C-u \C-c \C-c
;;; \C-u \C-c l loads the current file and does a cd first
;;;
;;; \C-c a      adds the current file
;;; \C-u \C-c a adds the current file and does a cd first
;;; \C-c r      reloads the current file
;;;
;;;
;;;  In gofer project files
;;; ESC \C-x
;;; \C-c \C-c
;;; \C-c p      loads the project file
;;; \C-u ESC \C-x
;;; \C-u \C-c \C-c
;;; \C-u \C-c p loads the project file and does a cd first
;;;
;;;  The duplication of ESC \C-x, \C-c \C-c, and \C-c l is for
;;;  historical reasons.

(require 'shell)

(defvar gofer-mode-hook nil "Gofer mode hook")

(defun run-gofer()
  "Run an inferior Gofer process."
  (interactive)
  (switch-to-buffer (make-shell "gofer" "gofer"))
  (make-variable-buffer-local 'shell-cd-pattern)
  (make-variable-buffer-local 'shell-prompt-pattern)
  (setq shell-cd-pattern ":cd")
  (setq shell-prompt-pattern "^[? ]*? \\|^"))

(defun save-buffer-and-go-outline(which arg)
  "Save current Gofer file buffer.
Goto inferior Gofer buffer and load file.
WHICH operation is required.
With ARG for additional operation"
  (save-buffer)
  (if (or (null (get-buffer "*gofer*")) (null (process-status "gofer")))  ; if gofer not running
      (save-excursion (run-gofer))) ; run gofer

  (if (equal which "r")         ; reload a file
      (progn
    (send-string "gofer" (concat ":reload" "\n")))
    (if (equal which "l")       ; load a file
    (progn
      (if arg
          (send-string "gofer" (concat ":cd " default-directory "\n")))
      (send-string "gofer" (concat ":l " (buffer-name) "\n")))
      (if (equal which "a")     ; add a file
      (progn
        (if arg
        (send-string "gofer" (concat ":cd " default-directory "\n")))
          (send-string "gofer" (concat ":a " (buffer-name) "\n")))
    (if (equal which "p")       ; a project file
        (progn
          (if arg
          (send-string "gofer" (concat ":cd " default-directory "\n")))
          (send-string "gofer" (concat ":p " (buffer-name) "\n")))
    (message "Bad programming in gofer.el")))))

  (switch-to-buffer-other-window "*gofer*"))

(defun save-gofer-buffer-and-load(arg)
  "Save a gofer source file and load it"
  (interactive "P")
  (save-buffer-and-go-outline "l" arg))

(defun save-gofer-buffer-and-add(arg)
  "Save a gofer source file and add it to the file list"
  (interactive "P")
  (save-buffer-and-go-outline "a" arg))

(defun save-gofer-buffer-and-reload(arg)
  "Save a gofer source file and reload it"
  (interactive "P")
  (save-buffer-and-go-outline "r" arg))

(defun save-gofer-project-buffer-and-go(arg)
  "Save a gofer project file and run"
  (interactive "P")
  (save-buffer-and-go-outline "p" arg))

(defun gofer-mode()
  "Gofer mode."
  (interactive)
  (setq mode-name "Gofer")
  (make-variable-buffer-local 'indent-line-function)
  (setq indent-line-function 'indent-relative)
  (run-hooks 'gofer-mode-hook)
  (local-set-key "\e\C-x" 'save-gofer-buffer-and-load)
  (local-set-key "\C-c\C-c" 'save-gofer-buffer-and-load)
  (local-set-key "\C-cl" 'save-gofer-buffer-and-load)
  (local-set-key "\C-cr" 'save-gofer-buffer-and-reload)
  (local-set-key "\C-ca" 'save-gofer-buffer-and-add)
  (local-set-key "\eg" 'goto-line))

(defun gofer-project()
  "For Gofer project files"
  (local-set-key "\e\C-x" 'save-gofer-project-buffer-and-go)
  (local-set-key "\C-c\C-c" 'save-gofer-project-buffer-and-go)
  (local-set-key "\C-cp" 'save-gofer-project-buffer-and-go))
