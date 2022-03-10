

(* ---------- propositional logic unit --- *)

SPECIFICATION PROPLOG;
(*Propositional logic specification. *)
(*1*) SORT bool;
(*2*) SIGNATURE FALSE ()            : bool;
      SIGNATURE TRUE  ()            : bool;
(*3*) SIGNATURE and (bool,bool)     : bool;
      SIGNATURE or  (bool,bool)     : bool;
      SIGNATURE not (bool)          : bool;
      SIGNATURE implies (bool,bool) : bool;
      SIGNATURE equival (bool,bool) : bool;
      SIGNATURE test    (bool,bool) : bool;
(*9*) END PROPLOG.


AXIOMS PROPLOG;
(*Axioms for propositional logic. *)
(*1*) RULE not(TRUE())          => FALSE();
      RULE not(FALSE())         => TRUE();
(*2*) RULE and(TRUE(),TRUE())   => TRUE();
      RULE and(FALSE(),TRUE())  => FALSE();
      RULE and(TRUE(),FALSE())  => FALSE();
      RULE and(FALSE(),FALSE()) => FALSE();
(*3*) RULE or(TRUE(),TRUE())    => TRUE();
      RULE or(FALSE(),TRUE())   => TRUE();
      RULE or(TRUE(),FALSE())   => TRUE();
      RULE or(FALSE(),FALSE())  => FALSE();
(*4*) RULE implies(X,Y)         => or(not(X),Y);
      RULE equival(X,Y)         => and(implies(X,Y),implies(Y,X));
(*9*) END PROPLOG.


(* ---------- peano arithmetic unit --- *)

SPECIFICATION PEANO;
(*Peano structure specification. *)
(*1*) SORT nat;
      IMPORT PROPLOG;
(*2*) SIGNATURE null  ()        : nat;
      SIGNATURE one   ()        : nat;
   (* SIGNATURE succ  (nat)     : nat; *)
      SIGNATURE add   (nat,nat) : nat;
      SIGNATURE prod  (nat,nat) : nat;
(*3*) SIGNATURE equal (nat,nat) : bool;
   (* SIGNATURE pred  (nat)     : bool; *)
(*9*) END PEANO.


AXIOMS PEANO;
(*Axioms for Peano system. *)
      RULE equal(X,X)                 => TRUE();
      RULE equal(succ(X),null())      => FALSE();
      RULE equal(null(),succ(X))      => FALSE();
(*1*) RULE equal(succ(null()),null()) => FALSE();
(*2*) RULE equal(succ(X),succ(Y))     => equal(X,Y);
(*3*) RULE add(X,null())              => X;
(*4*) RULE add(X,succ(Y))             => succ(add(X,Y));
(*5*) RULE prod(X,null())             => null();
(*6*) RULE prod(X,succ(Y))            => add(prod(X,Y),X);
      (*additional equations "lemmas" *)
      RULE add(succ(X),Y)             => succ(add(X,Y));
      RULE add(null(),X)              => X;
      RULE prod(succ(X),Y)            => add(X,prod(X,Y));
      RULE prod(null(),X)             => null();
      RULE one()                      => succ(null());
(*9*) END PEANO.


MODEL RING;
(*Peano numbers are a model for rings, except subtract. *)
(*1*) IMPORT PEANO;
(*2*) MAP WRITE(nat)     -> MWRITE(VAL);
(*3*) MAP ONE(nat)       -> one();
      MAP ZERO(nat)      -> null();
(*4*) MAP PROD(nat,nat)  -> prod(VAL,VAL);
      MAP SUM(nat,nat)   -> add(VAL,VAL);
(*9*) END RING.

