;========================================================================
;
;   qa.lsp - Question answering program using set-of-support
;            unit-preference resolution principles.
;
;   Author: John W. Ward (jwward)
;   Date:   06-Dec-86
;
;       The following program was written for an Artificial Intelligence
;   class at Kent State University.  The testing sequence used was designed
;   specifically to fit class requirements.  The program is offered for
;   inspection and experimentation.  The only claim I make regarding the
;   program is that I enjoyed working on it and learned something from it.
;
;       Some of the algorithms and examples follow our textbook: Artificial
;   Intelligence, by Elaine Rich (McGraw-Hill, 1983).
;
;-------------------------------------------------------------------------
;
;       Known limitations: The program degrades quickly when there is
;   a relatively high branching factor (i.e. many possible paths).  When
;   the pairs variable gets too big, something nasty usually happens.  On
;   my machine the something nasty is a warm restart.
;
;       The program was written in XLISP 1.7.  Converted to XLISP 2.0
;   by David Betz.
;
;-------------------------------------------------------------------------
;   QA.LOG provides a transcript of a program session.
;-------------------------------------------------------------------------
;
;   Question-answering is done as follows:
;   1) The question is negated, then converted to clause form with the
;      original question tacked on in a $SUCCESS$ "literal".
;   2) Each clause of the question is paired with all members of base,
;      producing the original "pairs" list.  Insertion to the list are
;      according to size of smaller clause * 1000 + size of larger clause.
;      Each clause is then added to the "base", which thus contains the
;      set-of-support as well.
;   3) Until solution is found (and user specifies QUIT) or "pairs" is
;      exhausted or the number of pairs tested exceeds a set limit (400):
;      a) Take the next pair of clauses from "pairs".  Try to resolve by
;         attempting to unify any pair of literals having opposite sign.
;      b) If the unification is successful, produce the resolution.
;         If resolution produces a clause already in the base, ignore it.
;         Otherwise, if the resolution is a success state, display and
;            ask the user for MORE or QUIT.
;         Otherwise (new, non-success result), add the result paired with
;            all current members of the base cum set-of-support to "pairs",
;            then add the result to the base.
;
;   Practically, this thing is slow and perverse.  It's amazing how long
;   it takes to exhaust the possibilities of an obviously wrong path.
;
;   Data structures and variables:
;       base            - List of hypotheses and set-of-support. The
;                         set-of-support can be distinguished by a $success$
;                         clause.  Each clause is actually a list, with the
;                         clause proceeded by its literal-count.
;       pairs           - List of clause-pairs to consider for resolution.
;                         Entries are triples - combined literal-count,
;                         left-clause and right-clause.  Sorted on ascending
;                         literal-count, with new entries following old ones
;                         to provide results analogous to a breadth-first
;                         search.  (New preceding old ends up close to depth-
;                         first.)
;       q-clause        - S-o-s clause currently under consideration (LHS)
;       b-clause        - Base clause currently under consideration (RHS)
;       subst-list      - Composition of all substitutions used in
;                         resolution.  This can be applied to the
;                         query to produce a solution.  (I hope!)
;       names           - Names in use in the base including variable names,
;                         predicates, and Skolem functions.  The type of
;                         each name will be attached to it.
;                         (I will convert variables on initial entry into
;                         the base or query, thus avoiding renaming later.
;                         I hope!)
;
;   Naming:
;       Constants       - begin with letters A through F or with $.
;                         (XLISP converts input to upper-case, so I can't
;                         distinguish that way.)
;       Variables       - Begin with G through Z.
;
;       Associate with every element of a clause is its type - CONSTANT or
;           VARIABLE.
;
;=========================================================================
;
(alloc 1000)
(expand 20)
;
;-------------------------------------------------------------------
;
;   qa - main routine
;
;   The program is in assert or question mode.  In question mode,
;       it will attempt to answer the question given by the user.  In
;       assert mode, it will add to the fact base.
;
;   Special commands:
;       assert    - Change to assert mode
;       question  - Change to question mode
;       end       - Start with a new base of information
;       nil       - End the program
;
;-------------------------------------------------------------------
(defun qa ()
    ; First time
    (init-qa)

    ; Main loop for each base set
    (do
        ()  ; No initialization
        ((or (null in-line) (equal in-line 'end)))

        (setq in-line (get-input mode))
        (cond
            ((null in-line) nil)
            ((equal in-line 'end) (init-qa))
            ((equal in-line 'assert) (setq mode in-line))
            ((equal in-line 'question) (setq mode in-line))
            ((equal in-line 'base)
                (mapcar `(lambda (a) (print (cadr a))) base)
            )
            ((equal in-line 'proof)
                (setq show-proof (not show-proof))
                (cond
                    (show-proof (princ "Resolutions will be shown.\n"))
                    (t (princ "Only answers will be shown.\n"))
                )
            )
            ((equal in-line 'unify)
                (setq show-unify (not show-unify))
                (cond
                    (show-unify (princ "Unifications will be shown.\n"))
                    (t (princ "Unifications will not be shown.\n"))
                )
            )
            ((equal in-line 'pairs)
                (setq show-pairs (not show-pairs))
                (cond
                    (show-pairs (princ "Clause-pairs will be shown.\n"))
                    (t (princ "Clause-pairs will be shown.\n"))
                )
            )
            ((equal in-line 'help) (give-help))
            ((equal mode 'question) (answer in-line))
            (t (assume in-line))
        )
    )
)
;
;-------------------------------------------------------------------
;
;   Provide simple help messages
;
(defun give-help ()
    (princ "\n\n\tQA - Help\n\n")
    (princ "Commands:\n")
    (princ "\tNil to exit, End to restart\n")
    (princ "\tProof, Unify, and Pairs toggle display settings\n")
    (princ "\tAssert      - Shift to assertion mode\n")
    (princ "\tQuestion    - Shift to question mode\n")
    (princ "\tBase        - Display base assumptions\n")
    (princ "\tHelp        - Print this message\n")
    (princ "\nInput form:\n\n")
    (princ "\tConstants begin with letters A-E or $.\n\n")
    (princ "\tEnter assertions or questions in LISP-like form.  You may\n")
    (princ "include the operators AND, OR, NOT, IMPLY, AND EQUIV.  Thus,\n")
    (princ "to indicate that a male parent is a father, type:\n\n")
    (princ "\t(EQUIV (AND ($PARENT X Y) ($MALE X)) ($FATHER X Y))\n\n")
    (princ "The definition of commutative binary operations is:\n\n")
    (princ "\t(IMPLY ($COMMUT K) (EQUIV (K X Y Z) (K Y X Z)))\n")
)
;-------------------------------------------------------------------
;
;   Attempt to answer the question
;
(defun answer (question)
    (let
        (
            (c-question nil)
        )
        (setq pairs nil)
        (setq
            c-question
            (clause-convert `(or (not ,question) ($success$ ,question)))
        )
        (cond
            ((equal (car c-question) 'and)
                (setq c-question (mapcar 'set-types c-question))
                (mapcar 'add-sos (cdr c-question))
            )
            (t
                (setq c-question (set-types c-question))
                (add-sos c-question)
            )
        )
        (solve)
        (princ "\n\nDone.\n\n")
        (setq base (remove-success base))
    )
)
;
;-------------------------------------------------------------------
;
;   Find solution to the question -
;
;
;   pairs = (question X base) from set-up
;   done <-- nil
;   While pairs != nil and done == nil {
;       pair <-- (car pairs); pairs <-- (cdr pairs);
;       Get q-clause and b-clause from pair
;           <<< solve-clause-clause >>>
;           For each q-literal in q-clause {
;               <<< solve-lit-clause >>>
;               For each b-literal of opposite sign in b-clause {
;                   <<< solve-lit-lit >>>
;                   subs <-- unification of q-literal and b-literal
;                   If subs != nil {
;                       Make subs in q-clause and b-clause
;                       resolution <-- resolve of q-clause and b-clause
;                       <<< resolved >>>
;                           Report resolution
;                           If resolution is a success-state {
;                               return true if they don't want More
;                           }
;                           else {
;                               add (resolution X base) to pairs
;                               add resolution to base
;                               return nil (keep going)
;                           }
;                   }
;               }
;           }
;   }
;
;
(defun solve ()
    (setq solutions-found nil)
    (setq pairs-count 0)
    (do
        (
            (done nil)
            (pair nil)
        )
        (
            (or done (null pairs) (>= pairs-count max-pairs))
        )
        (setq pair (car pairs))
        (setq pairs (cdr pairs))

        (setq q-clause (cadr pair))
        (setq b-clause (caddr pair))

        (setq done (solve-clause-clause))
    )
)
;-------------------------------------------------------------------
;
;   Test if result is a success
;
;
(defun success-p (clause)
    (cond
        ((atom clause) nil)
        ((equal (car (first-lit clause)) '$success$) t)
        (t nil)
    )
)
;-------------------------------------------------------------------
;
;   Solve given two clauses - pass on with full clauses for later
;       breakup
;
;           <<< solve-clause-clause >>>
;           Add b-clause to right-used
;           For each q-literal in q-clause {
;               <<< solve-lit-clause >>>
;           }
;
(defun solve-clause-clause ()
    (cond
        (show-pairs
            (princ "Working on clauses:\n")
            (print q-clause)
            (print b-clause)
            (terpri)
        )
    )
    (setq pairs-count (1+ pairs-count))
    (cond
        ((equal (rem pairs-count 50) 0)
            (princ "Pairs count:\t") (print pairs-count)
            (princ "Base:\t\t")  (print (length base))
            (princ "Pairs:\t\t") (print (length pairs))
            (princ "Size:\t\t")  (print (deep-count pairs))
            (terpri)
            (gc)
            (mem)
            (terpri)
        )
    )

    (solve-clause-clause* (remove-success q-clause) (remove-success b-clause))
)
(defun solve-clause-clause* (q-work b-work)
    (let
        (
            (result nil)
        )
        (cond
            ((null b-work) nil)
            ((atom b-work)
                (princ "Error in solve-clause-clause* - b-work is atom\n")
                nil
            )
            ((null q-work) nil)
            ((atom q-work)
                (princ "Error in solve-clause-clause* - q-work is atom\n")
                nil
            )
            (
                (setq result (solve-lit-clause (first-lit q-work) b-work))
                result
            )
            (t (solve-clause-clause* (remove-first-lit q-work) b-work))
        )
    )
)
;-------------------------------------------------------------------
;
;   Solve with a question literal and a base clause
;
;               <<< solve-lit-clause >>>
;               For each b-literal of opposite sign in b-clause {
;                   <<< solve-lit-lit >>>
;               }
;
;
(defun solve-lit-clause (q-lit b-work)
    (let
        (
            (result nil)
        )
        (cond
            ((null q-lit) nil)
            ((atom q-lit)
                (princ "Error in solve-lit-clause - q-lit is atom\n")
                nil
            )
            ((null b-work) nil)
            ((atom b-work)
                (princ "Error in solve-lit-clause - b-work is atom\n")
                nil
            )
            ((setq result (solve-lit-lit q-lit (first-lit b-work))) result)
            (t (solve-lit-clause q-lit (remove-first-lit b-work)))
        )
    )
)
;-------------------------------------------------------------------
;
;   Solve with a question literal and a base literal
;
;                   <<< solve-lit-lit >>>
;                   subs <-- unification of q-literal and b-literal
;                   If subs != nil {
;                       Make subs in q-clause and b-clause
;                       resolution <-- resolve of q-clause and b-clause
;                       If resolution != nil {
;                           <<< resolved >>>
;                       }
;                   }
;
;
(defun solve-lit-lit (q-lit b-lit)
    (let
        (
            (subs nil)
            (resolution nil)
            (old-q q-clause)
            (old-b b-clause)
        )

        ; Quit without effort if literals are not of opposite sign
        (cond
            ((equal (lit-sign q-lit) (lit-sign b-lit)) nil)
            (t
                (setq subs (unify q-lit b-lit))
                (cond
                    (show-unify
                        (princ "Unification of: ") (print q-lit)
                        (princ "           and: ") (print b-lit)
                        (princ "            is: ") (print subs)
                        (terpri)
                    )
                )
                (cond
                    ((not (null subs))
                        (setq old-q (make-subs subs q-clause))
                        (setq old-b (make-subs subs b-clause))
                        (setq resolution (resolve old-q old-b))
                        (cond
                            (
                                (not
                                    (member
                                        (add-count resolution)
                                        base :test #'equal
                                    )
                                )
                                (resolved resolution)
                            )
                            (t nil)
                        )
                    )
                    (t nil)
                )
            )
        )
    )
)
;-------------------------------------------------------------------
;
;   Handle a successful resolution
;
;                           Report resolution
;                           If resolution is a success-state {
;                               done <-- quit if they don't want More
;                           }
;                           else {
;                               add (resolution X base) to pairs
;                               add resolution to base
;                               return nil for resolution
;                           }
;
(defun resolved (resolution)
    (cond
        (show-proof
            (terpri)
            (princ "Clause 1   ") (print q-clause)
            (princ "Clause 2   ") (print b-clause)
            (princ "Resolution ") (print resolution)
            (terpri)
        )
    )
    (cond
        ((success-p resolution)
            (cond
                (
                    (not
                        (member
                            resolution
                            solutions-found :test #'equal
                        )
                    )
                    (setq
                        solutions-found
                        (append solutions-found (list resolution))
                    )
                    (print (first-lit resolution))
                    (terpri)
                    (princ "Enter QUIT to quit, MORE for more solutions --")
                    (equal (read) 'quit)
                )
                (t nil)
            )
        )
        (t
            (add-sos resolution)
            nil
        )
    )
)
;-------------------------------------------------------------------
;
;   Determine sign of literal (either NOT or NIL)
;
;
(defun lit-sign (lit)
    (cond
        ((atom lit) nil)
        ((equal (car lit) 'not) 'not)
        (t nil)
    )
)
;-------------------------------------------------------------------
;
;   Return the "absolute value" (NOT removed) of lit
;
;
(defun lit-abs (lit)
    (cond
        ((null (lit-sign lit)) lit)
        (t (cadr lit))
    )
)
;-------------------------------------------------------------------
;
;   Return the negation of a literal
;
;
(defun lit-negative (lit)
    (cond
        ((null (lit-sign lit)) `(not ,lit))
        (t (cadr lit))
    )
)
;-------------------------------------------------------------------
;
;   Unify two literals - (from the book, page 156)
;
;
(defun unify (q-lit b-lit)
    (unify* (lit-abs q-lit) (lit-abs b-lit) nil)
)
(defun unify* (q-lit b-lit subs)
    (cond
        ; If either is an atom, they must be equal or
        ;       at least one a variable, else fail
        ((or (atom q-lit) (atom b-lit))
            (cond
                ((equal q-lit b-lit) (compose subs '(nil nil)))
                ((variable-p b-lit) (compose subs (ok-sub b-lit q-lit)))
                ((variable-p q-lit) (compose subs (ok-sub q-lit b-lit)))
                (t nil)
            )
        )

        ; We get here for lists
        ((/= (length q-lit) (length b-lit)) nil)
        (t
            (setq subs (unify* (car q-lit) (car b-lit) subs))
            (cond
                ((null subs) nil)
                (t
                    (unify*
                        (make-subs subs (cdr q-lit))
                        (make-subs subs (cdr b-lit))
                        subs
                    )
                )
            )
        )
    )
)
;-------------------------------------------------------------------
;
;   Return nil if y contains x, else return (x y)
;
;
(defun ok-sub (x y)
    (cond
        ((deep-member x y) nil)
        (t `(,x ,y))
    )
)
;-------------------------------------------------------------------
;
;   Compose single substitution y into list x
;
;
(defun compose (x y)
    (let
        (
            (result nil)
        )
        (cond
            ((null y) nil)
            ((null x) (list y))
            ((equal x '((nil nil))) (list y))
            (t
                (setq x (sub-right-side y x))
                (cond
                    ((assoc (car y) x) x)
                    (t (append x (list y)))
                )
            )
        )
    )
)
;-------------------------------------------------------------------
;
;   Make all substitutions sub (a b) into substitution list
;       of the form ((x a)) --> ((x b))
;
;
(defun sub-right-side (sub sub-list)
    (mapcar `(lambda (x) (sub-right-side* ',sub x)) sub-list)
)
(defun sub-right-side* (sub sub-entry)
    (cons
        (car sub-entry)
        (make-subs (list sub) (cdr sub-entry))
    )
)
;-------------------------------------------------------------------
;
;   Is x variable?
;
;
(defun variable-p (x)
    (cond
        ((null x) nil)
        ((atom x) (equal (get x 'type) 'variable))
        (t nil)
    )
)
;-------------------------------------------------------------------
;
;   Resolve two unified clauses
;
;
(defun resolve (clause-1 clause-2)
    (let
        (
            (result nil)
        )
        (setq success-list '(or))
        (setq clause-1 (strip-success clause-1))
        (setq clause-2 (strip-success clause-2))

        (setq result (load-lits (lit-factor clause-1) '(or)))
        (setq result (load-lits (lit-factor clause-2) result))
        (setq result (load-lits success-list result))
        result
    )
)
;-------------------------------------------------------------------
;
;   Return clause less all $success$ literals and record $success$
;       literals in success-list
;
;
(defun strip-success (clause)
    (cond
        ((null clause) nil)
        ((atom clause) nil)     ; Should be an error
        ((equal (car clause) '$success$)
            (setq success-list (load-lits clause success-list))
            nil
        )
        ((literal-p clause) clause)
        (t                              ; Begins with OR
            (remove
                nil
                (cons (car clause) (mapcar 'strip-success (cdr clause)))
            )
        )
    )
)
;-------------------------------------------------------------------
;
;   Before we turn the clauses loose on each other, factor any
;   internally repeated literals.  If there are internal opposite
;   literals, return nil, thus letting the other clauses be unaffected
;   by the tautology.
;
;
(defun lit-factor (clause)
    (lit-factor* clause '(or))
)
(defun lit-factor* (clause new-clause)
    (let
        (
            (first (first-lit clause))
            (rest (remove-first-lit clause))
        )
        (cond
            ((null clause) new-clause)
            ((member first new-clause :test #'equal)
                (lit-factor* rest new-clause)
            )
            ((member (lit-negative first) new-clause :test #'equal) nil)
            (t (lit-factor* rest (append new-clause (list first))))
        )
    )
)
;-------------------------------------------------------------------
;
;   Add literals to clause -
;       If literal's negative is in clause, remove from both clauses
;       If literal is in clause, don't add it.
;       Otherwise add at end of clause
;
;
(defun load-lits (clause new-clause)
    (let
        (
            (first (first-lit clause))
            (rest (remove-first-lit clause))
            (negative nil)
        )
        (setq negative (lit-negative first))
        (cond
            ((null clause) new-clause)
            ((member first new-clause :test #'equal)
                (load-lits rest new-clause)
            )
            ((member negative new-clause :test #'equal)
                (load-lits rest (remove negative new-clause :test #'equal))
            )
            (t (load-lits rest (append new-clause (list first))))
        )
    )
)
;-------------------------------------------------------------------
;
;   Make substitutions from substitution list
;
(defun make-subs (subs clause)
    (let
        (
            (pair nil)
        )
        (cond
            ((null clause) nil)
            ((atom clause)
                (setq pair (assoc clause subs))
                (cond
                    ((null pair) clause)
                    (t (cadr pair))
                )
            )
            (t (mapcar `(lambda (x) (make-subs ',subs x)) clause))
        )
    )
)
;-------------------------------------------------------------------
;
;   Add fact to the base hypotheses
;
;   Convert the fact to clause form.
;   If the result is a conjuction of clauses, set types and add them all;
;   else set the types and add the single clause.
;
(defun assume (fact)
    (setq fact (clause-convert fact))
    (cond
        ((equal (car fact) 'and)
            (setq fact (mapcar 'set-types fact))
            (setq base (append base (mapcar 'add-count (cdr fact))))
        )
        (t
            (setq fact (set-types fact))
            (setq base (append base (list (add-count fact))))
        )
    )
    fact
)
;-------------------------------------------------------------------
;
;   Return clause in a list preceded by the clause's literal-count
;
(defun add-count (clause)
    (list (literal-count clause) clause)
)
;-------------------------------------------------------------------
;
;   Add a clause to the set-of-support -
;       add (clause X base) to pairs;
;       add clause to base
;
(defun add-sos (clause)
    (let
        (
            (pair (list (literal-count clause) clause))
        )
        (mapcar `(lambda (a) (add-pair pair a)) base)
        (setq base (append base (list (add-count clause))))
    )
)
;-------------------------------------------------------------------
;
;   Insert a pair of clauses into pairs - returns pairs
;
(defun add-pair (q b)
    (let
        (
            (size-q (car q))
            (size-b (car b))
            (q-cl (cadr q))
            (b-cl (cadr b))
            (size 0)
            (new-pair nil)
        )
        (cond
            ((< size-q size-b)
                (setq size (+ (* 1000 size-q) size-b))
                (setq pairs (insert-pair (list size q-cl b-cl) pairs))
            )
            (t
                (setq size (+ (* 1000 size-b) size-q))
                (setq pairs (insert-pair (list size b-cl q-cl) pairs))
            )
        )
    )
)
;-------------------------------------------------------------------
;
;   Insert pair into pairs list - return new list
;
(defun insert-pair (pair pair-list)
    (cond
        ((null pair-list) (list pair))

        ;  Use <= for "depth-first", < for "breadth-first"
        ((< (car pair) (caar pair-list)) (cons pair pair-list))
        (t (cons (car pair-list) (insert-pair pair (cdr pair-list))))
    )
)
;-------------------------------------------------------------------
;
;   Count the literals in a clause
;       Ignore a success clause and change 2's to 1 [e.g. (OR (A)) --> (A)]
;
(defun literal-count (clause)
    (setq clause (remove-success clause))
    (cond
        ((atom clause) 0)
        ((literal-p clause) 1)
        (t (1- (length clause)))
    )
)
;-------------------------------------------------------------------
;
;   Return the clause with any $success$ element removed
;
(defun remove-success (clause)
    (cond
        ((atom clause) clause)
        (t (remove nil (remove '$success$ clause :test #'deep-member)))
    )
)
;-------------------------------------------------------------------
;
;   Set the types for each name in the new line
;
;   Uses the global association list new-names
;
;   If a clause is nil, return nil.
;   If it's an atom, type it as variable or constant with separate routine.
;   If it's a list, pass the set-types through on mapcar.
;
(defun set-types (clause)
    (setq new-names nil)
    (set-types* clause)
)
(defun set-types* (clause)
    (cond
        ((null clause) nil)
        ((equal clause 'not) clause)
        ((equal clause 'or) clause)
        ((equal clause 'and) clause)
        ((atom clause) (set-unit-type clause))
        (t (mapcar 'set-types* clause))
    )
)
;
;-------------------------------------------------------------------
;
;   Set the type for an atom - either constant or variable
;
;   For constants:
;       Add name to names if new.
;
;   For variables:
;       Is the name is already in the new-names list?
;       Yes : return the associated name.
;       No  : Is the name in names?
;             Yes : Find an alternate name, add the substitution pair to
;                   new-names, add the new name to names with type variable
;                   and return the new name.
;             No  : Add the name to names with type variable, add an identity
;                   pair to new-names, return the original.
;
(defun set-unit-type (atm)
    (let
        (
            (g-symb atm)        ; Substitution name
            (atm-type 'variable)
            (pair nil)
        )
        (cond
            ((equal (get atm 'type) 'constant) nil)
            ((char> (char (symbol-name atm) 0) #\F)

                ; If first character > F, it's a variable.
                (setq pair (assoc atm new-names))
                (cond
                    ((not (null pair)) (setq g-symb (cadr pair)))
                    (t
                        (cond
                            ((member atm names)
                                (setq g-symb (gensym))
                                (add-new-name atm g-symb)
                            )
                            (t  (add-new-name atm atm))
                        )
                    )
                )
            )
        )
        (add-name g-symb)
    )
)
;
;-------------------------------------------------------------------
;
;   If the atom is not found in names, add it with given type.
;   Return the atom
;
(defun add-name (atm)
    (cond
        ((member atm names) atm)
        (t (setq names (cons atm names)))
    )
    (cond
        ((get atm 'type) nil)
        ((char<= (char (symbol-name atm) 0) #\F) (putprop atm 'constant 'type))
        (t (putprop atm 'variable 'type))
    )
    atm
)
;
;-------------------------------------------------------------------
;
;   Add a new name to the new-names a-list.  Return the substitution
;   value
;
(defun add-new-name (x y)
    (setq new-names (cons (list x y) new-names))
    y
)
;-------------------------------------------------------------------
;
;   Find x at any depth in list
;
(defun deep-member (x lst)
    (cond
        ((equal x lst) t)
        ((atom lst) nil)
        ((deep-member x (car lst)) t)
        (t (deep-member* x (cdr lst)))
    )
)
(defun deep-member* (x lst)     ; To avoid x = cdr
    (cond
        ((null lst) nil)
        ((deep-member x (car lst)) t)
        (t (deep-member* x (cdr lst)))
    )
)
;-------------------------------------------------------------------
;
;   Print prompt and get input
;
(defun get-input (mode)
    (terpri)
    (cond
        ((equal mode 'assert) (princ "Assert --"))
        (t (princ "Question --"))
    )
    (read)
)
;
;-------------------------------------------------------------------
;
;   Test if x is a literal
;
(defun literal-p (x)
    (cond
        ((atom x) nil)
        ((equal (car x) 'not)
            (not (member (caadr x) (cons 'not operators)))
        )
        ((member (car x) operators) nil)
        (t t)
    )
)
;-------------------------------------------------------------------
;
;   Find first literal in x
;
(defun first-lit (x)
    (cond
        ((atom x) nil)
        ((equal (car x) 'or) (cadr x))
        (t x)
    )
)
;-------------------------------------------------------------------
;
;   Return x with first literal removed (keep OR unless down to one literal
;
(defun remove-first-lit (x)
    (cond
        ((atom x) nil)
        ((literal-p x) nil)       ; If not, must be clause
        ((equal (car x) '$success$) nil)
        ((<= (length x) 3) (car (cdr (cdr x))))
        (t (cons 'or (cdr (cdr x))))
    )
)
;-------------------------------------------------------------------
;
;   Count the items in a list - for memory test purposes
;
(defun deep-count (x)
    (cond
        ((null x) 0)
        ((atom x) 1)
        (t
            (apply '+ (mapcar 'deep-count x))
        )
    )
)
;-------------------------------------------------------------------
;
;   Set global variables to initial states
;
(defun init-qa ()
    (setq base nil)
    (setq names '(not or))
    (setq show-proof t)
    (setq show-unify nil)
    (setq show-pairs nil)
    (setq max-pairs 400)
    (putprop 'not       'constant 'type)
    (putprop 'or        'constant 'type)
    (putprop '$success$ 'constant 'type)
    (putprop 'and       'constant 'type)
    (putprop 'imply     'constant 'type)
    (putprop 'equiv     'constant 'type)
    (setq operators '(or and imply equiv))    ; Can't begin a literal
    (setq mode 'assert)
    (setq in-line 0)
    (princ "Type HELP for help.\n\n")
)
;
;-------------------------------------------------------------------
;
;   CLAUSE CONVERSION CODE
;
;   Convert the fact to clause form
;
(defun clause-convert (fact)
    (let
        (
            (result fact)
        )
        (cond
            ((atom fact) fact)
            ((literal-p fact) fact)
            (t
                (setq result (cc-equiv result))
                (setq result (cc-imply result))
                (setq result (cc-push-not result))
                (setq result (cc-push-or result))
                (setq result (cc-disassoc result))
                result
            )
        )
    )
)
;-------------------------------------------------------------------
;
;   Convert clause form (equiv (a) (b)) -->
;           (and (imply (a) (b)) (imply (b) (a)))
;
;
(defun cc-equiv (c)
    (cond
        ((atom c) c)
        ((literal-p c) c)
        ((equal (car c) 'equiv)
            `(and
                (imply ,(cc-equiv (cadr c)) ,(cc-equiv (caddr c)))
                (imply ,(cc-equiv (caddr c)) ,(cc-equiv (cadr c)))
            )
        )
        (t (mapcar 'cc-equiv c))
    )
)
;-------------------------------------------------------------------
;
;   Convert clause form (imply (a) (b)) -->
;       (or (not (a)) (b))
;
;
(defun cc-imply (c)
    (cond
        ((atom c) c)
        ((literal-p c) c)
        ((equal (car c) 'imply)
            `(or
                (not ,(cc-imply (cadr c)))
                ,(cc-imply (caddr c))
            )
        )
        (t (mapcar 'cc-imply c))
    )
)
;-------------------------------------------------------------------
;
;   Push NOTs down to literals -
;       (not (not (a))) --> (a)
;       (not (or (a) (b) (c))) --> (and (not (a)) (not (b)) (not (c)))
;       (not (and (a) (b) (c))) --> (or (not (a)) (not (b)) (not (c)))
;       (not (exist x (...)) --> (all x (not (...)))
;       (not (all x (...)) --> (exist x (not (...)))
;
;
(defun cc-push-not (c)              ; No prior NOT being pushed
    (cond
        ((atom c) c)
        ((literal-p c) c)
        ((equal (car c) 'not) (cc-push-not* (cadr c)))
        (t (mapcar 'cc-push-not c))
    )
)
(defun cc-push-not* (c)             ; Prior NOT being pushed
    (cond
        ((atom c) c)
        ((literal-p c) (lit-negative c))
        ((equal (car c) 'not) (cc-push-not (cadr c)))
        ((equal (car c) 'and)
            (append '(or) (mapcar 'cc-push-not* (cdr c)))
        )
        ((equal (car c) 'or)
            (append '(and) (mapcar 'cc-push-not* (cdr c)))
        )
        ((equal (car c) 'exist)
            (append `(all ,(cadr c)) (mapcar 'cc-push-not* (caddr c)))
        )
        ((equal (car c) 'all)
            (append `(exist ,(cadr c)) (mapcar 'cc-push-not* (caddr c)))
        )
    )
)
;----------------------------------------------------------------------
;
;   Move all the ORs down below the AND's
;
;
(defun cc-push-or (c)
    (cond
        ((atom c) c)
        ((literal-p c) c)
        ((equal (length c) 2) (cadr c))     ; (AND/OR (a)) --> (a)

        ((equal (car c) 'or)
            (cc-or-merge
                (cc-push-or (cadr c))
                (cc-push-or (append '(or) (cddr c)))
            )
        )
        (t (mapcar 'cc-push-or c))
    )
)
;----------------------------------------------------------------------
;
;   Merge two cleaned-up forms with an OR
;
;
(defun cc-or-merge (x y)
    (cond
        ((null x) y)
        ((null y) (cc-or-merge y x))
        ((atom x)
            (princ "Error in cc-or-merge - invalid form ")
            (print x)
        )
        ((atom y) (cc-or-merge y x))
        ((equal (car x) 'and)
            (append
                '(and)
                (mapcar '(lambda (a) (cc-or-merge y a)) (cdr x))
            )
        )
        ((equal (car y) 'and) (cc-or-merge y x))
        (t `(or ,x ,y))
    )
)
;----------------------------------------------------------------------
;
;   Flatten the form by the association rule
;
;
(defun cc-disassoc (c)
    (cond
        ((atom c) c)
        ((literal-p c) c)

        ; (AND/OR (a)) --> (a)
        ((equal (length c) 2) (cc-disassoc (cadr c)))

        (t
            (cc-merge-assoc
                (car c)
                (cc-disassoc (cadr c))
                (cc-disassoc (caddr c))
            )
        )
    )
)
;----------------------------------------------------------------------
;
;   Merge two cleaned-up forms by association
;
;
(defun cc-merge-assoc (op x y)
    (cond
        ((null x) y)
        ((null y) (cc-merge-assoc op y x))
        ((atom x)
            (princ "Error in cc-merge-assoc - invalid form ")
            (print x)
        )
        ((atom y) (cc-merge-assoc op y x))

        (t
            (append
                (list op)
                (cond
                    ((equal (car x) op) (cdr x))
                    (t (list x))
                )
                (cond
                    ((equal (car y) op) (cdr y))
                    (t (list y))
                )
            )
        )
        ((equal (car y) 'and) (cc-merge-assoc y x))
        (t `(or ,x ,y))
    )
)

(qa)
