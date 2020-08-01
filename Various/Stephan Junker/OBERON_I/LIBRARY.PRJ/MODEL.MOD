MODULE Model; (* SJ 10.12.94 *)

(*
 A Model is an Object extension. Instances of this type have a list of
 dependants, i.e. objects which depend on the active object. A change of
 the active objects' contents produces a message to its dependants.

 Model replaces MVC which is not supported anymore. It provides much more
 flexibility.
 *)


IMPORT
  LinkedList;



TYPE
  Desc* = RECORD  (* used for active objects *)
    dependants: LinkedList.Desc;
  END;
  Ptr* = POINTER TO Desc;

  DependDesc* = RECORD(LinkedList.ElemDesc) (* used for dependants *)
    model-: Ptr;
  END;
  Dependant* = POINTER TO DependDesc;

  AspectDesc* = RECORD  (* defines changed aspect *)
  END;
  Aspect* = POINTER TO AspectDesc;



PROCEDURE (self: Dependant) Initialize*;
(*
 Initialize the receiver.
 *)
 BEGIN
  self.model := NIL;
 END Initialize;


PROCEDURE (self: Dependant) Update*(aspect: Aspect);
(*
 Is called by active objects when their contents is changed. aspect
 describes the changes. A value of NIL means "everything has changed"
 (or no further description possible).
 *)
 BEGIN
 END Update;


PROCEDURE (self: Ptr) Initialize*;
(*
 Initialize the receiver. No dependants.
 *)
 BEGIN
  self.dependants.Initialize;
 END Initialize;


PROCEDURE (self: Ptr) AddDependant*(dependant: Dependant);
(*
 Add obj as a dependant of the receiver.
 *)
 BEGIN
  self.dependants.Add( dependant);
 END AddDependant;


PROCEDURE (self: Ptr) RemoveDependant*(dependant: Dependant);
(*
 Remove obj as a dependant of the receiver.
 *)
 BEGIN
  self.dependants.Remove( dependant);
 END RemoveDependant;


PROCEDURE (self: Ptr) Changed*(aspect: Aspect);
(*
 Send the Changed message to all dependants of the receiver.
 *)

  PROCEDURE~ Send(e: LinkedList.Element);
   BEGIN
    WITH e: Dependant DO
      e.Update(aspect)
    END(*WITH*);
   END Send;

 BEGIN
  self.dependants.Do( Send);
 END Changed;


PROCEDURE (self: Dependant) SetModel*(m: Ptr);
 BEGIN
  IF self.model # NIL THEN
    self.model.RemoveDependant(self);
  END;
  m.AddDependant(self);
  self.model := m;
  self.Update(NIL);
 END SetModel;


END Model.