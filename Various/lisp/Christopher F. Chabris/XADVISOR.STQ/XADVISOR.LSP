;***************************************************************************
;*                                                                         *
;*  XADVISOR.  Written by Christopher F. Chabris.  December 1985           *
;*       (June 1986: adapted from Franz Lisp to ST XLisp 1.5b)             *
;*                                                                         *
;*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing.    *
;*                                                                         *
;***************************************************************************
;
; A generic production-system interpreter/"expert system" capable of
;  both forward and backward chaining inference.


; Function ADVISE is a large front-end function used to invoke the production-
;  system interpreter for the first time.  After initializing the environment
;  in global variables, it will call either BACKWARDS or FORWARDS to proceed
;  depending on the arguments and options passed by the user.

(defun advise (context goal &rest options)
  (setq i-flag (member 'interactive options)
        proven context
        disproven nil)
  (cond ((and (null goal) (not (null context)))
         (let ((advice (car (forwards (reverse rulebase) nil))))
              (terpri)
              (princ "I ")
              (princ (car advice))))
        (t
         (let ((advice (backwards goal)))
              (terpri)
              (cond ((eq advice t)
                     (princ "I ")
                     (princ (car goal)))
                    ((eq advice nil)
                     (princ "I do not ")
                     (princ (car goal)))
                    (t
                     (princ "I ")
                     (princ (car advice)))))))
  (princ ".")
  (terpri)
  'OK)


; Function PREPARE will load a rule set from the specified file into global
;  variable rulebase and put the rules in the same order as in the file.

(defun prepare (rulefile)
  (setq rulebase nil)
  (load rulefile)
  (setq rulebase (reverse rulebase))
  (setq inconclusive-message
        '("cannot give any advice based on the given context"))
  'OK)


; Macro IF adds a rule to the knowledge base in global variable rulebase.
; [Written to accomodate rule file format, replaces built-in IF]

(defmacro if (conditions actions)
  (list 'setq
        'rulebase
        (list 'cons (list 'quote (list conditions actions)) 'rulebase)))


; Function BACKWARDS attempts to backward-chain from a given action, trying
;  to determine if it or all its conditions are (or can be) satisfied.  If no
;  action is specified, function TRYALL will be called to attempt to backward
;  chain from each terminal action.  The first to be satisified is returned.

(defun backwards (action)
  (cond ((null action)
         (try-all rulebase))
        ((member action proven :test 'equal) t)
        ((member action disproven :test 'equal) nil)
        (t (let ((condition-sets (conditions action rulebase)))
                (cond ((null condition-sets)
                       (cond (i-flag (ask-user action))))
                      (t (backwards-aux action condition-sets)))))))

(defun try-all (rules-left)
  (cond ((null rules-left)
         inconclusive-message)
        (t (let ((action (cadar rules-left)))
                (cond ((not (terminal action rulebase))
                       (try-all (cdr rules-left)))
                      (t (cond ((backwards action) action)
                               (t (try-all (cdr rules-left))))))))))

(defun backwards-aux (action condition-sets)
  (cond ((null condition-sets) nil)
        ((assert (car condition-sets))
         (setq proven (cons action proven))
         t)
        (t (backwards-aux action (cdr condition-sets)))))


; Function FORWARDS attempts to forward chain given the current context.  In
;  the current implementation, it assumes all rules are ordered according to
;  their "priority," and it will return a stream of all terminal actions
;  whose conditions have been satisfied.

(defun forwards (rules-left answer-stream)
  (cond ((null rules-left)
         (cond ((null answer-stream)
                (list inconclusive-message))
               (t answer-stream)))
        (t (let ((action (cadar rules-left)))
                (cond ((and (not (member action proven :test 'equal))
                            (true (caar rules-left)))
                       (setq proven (cons action proven))
                       (cond ((terminal action rulebase)
                              (forwards (reverse rulebase)
                                        (cons action answer-stream)))
                             (t (forwards (reverse rulebase)
                                          answer-stream))))
                      (t (forwards (cdr rules-left)
                                   answer-stream)))))))


; Utility functions for inference engine:
;  ASSERT returns t if all actions passed in condition-set can be satisfied;
;  CONDITIONS returns a list of sets of conditions that will satisfy an action;
;  ASK-USER returns the user's declaration of the (un)truth of a condition;
;  TRUE returns t if every condition in condition-set is already proven;
;  TERMINAL returns t if a given action is "terminal" -- that is, if it does
;           not appear in any sets of conditions anywhere in the rulebase.

(defun assert (condition-set)
  (cond ((null condition-set) t)
        ((backwards (car condition-set))
         (assert (cdr condition-set)))))

(defun conditions (action rules-left)
  (cond ((null rules-left) nil)
        ((equal action (cadar rules-left))
         (cons (caar rules-left)
               (conditions action (cdr rules-left))))
        (t (conditions action (cdr rules-left)))))

(defun ask-user (action)
  (terpri)
  (princ "Is it true that:")
  (terpri)
  (princ " ")
  (princ action)
  (princ "?")
  (let ((answer (read)))
       (cond ((member answer '(y yes Y Yes))
              (setq proven (cons action proven)) t)
             ((member answer '(n no N No))
              (setq disproven (cons action disproven)) nil)
             (t
              (princ "Answer (y)es or (n)o, please!")
              (terpri)
              (ask-user action)))))

(defun true (condition-set)
  (cond ((null condition-set) t)
        ((member (car condition-set) proven :test 'equal)
         (true (cdr condition-set)))))

(defun terminal (action rules-left)
  (cond ((null rules-left) t)
        ((not (member action (caar rules-left) :test 'equal))
         (terminal action (cdr rules-left)))))

