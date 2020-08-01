MODULE BinTree; (* generic binary trees                *)
                (* by h. M”ssenb”ck                    *)
                (* extended by Dirk_Theisen@su.maus.de *)


CONST

  inorder*  = 0; preorder* = 1; postorder* = 2;  (* traverse modes *)


TYPE

  Node*     = POINTER TO NodeDesc;

  NodeDesc* = RECORD (* to be extended *)
                left, right : Node;
              END;

  Tree*     = RECORD
                root: Node;
              END;

  doproc    = PROCEDURE (x:Node);

  PROCEDURE (x:Node) EqualTo* (y:Node):BOOLEAN;  (* please override *)
  BEGIN
    HALT(101);
  END EqualTo;

  PROCEDURE (x:Node) LessThan* (y:Node):BOOLEAN;  (* please override *)
  BEGIN
    HALT(101);
  END LessThan;


  PROCEDURE (VAR t: Tree) Init*;
  BEGIN
    t.root:=NIL;
  END Init;


  PROCEDURE (VAR t:Tree) Insert* (x:Node);
  VAR
    this, father: Node;
  BEGIN
    this:=t.root;
    x.left:=NIL;
    x.right:=NIL;
    WHILE this # NIL DO
      father:=this;
      IF x.EqualTo(this) THEN RETURN; (* no duplicates *) END(*IF*);
      IF x.LessThan(this) THEN
        this:=this.left;
      ELSE
        this:=this.right;
      END(*IF*);
    END(*WHILE*);
    IF t.root=NIL THEN
      t.root:= x;
    ELSIF x.LessThan(father) THEN
      father.left  := x;
    ELSE
      father.right := x;
    END(*IF*);
  END Insert;


  PROCEDURE (VAR t:Tree) Search* (x:Node):Node;
  VAR
    this     : Node;
  BEGIN
    this:=t.root;
    WHILE (this # NIL) & ~x.EqualTo(this) DO
      IF x.LessThan(this) THEN
        this:=this.left;
      ELSE
        this:=this.right;
      END(*IF*);
    END(*WHILE*);
    RETURN this;
  END Search;

  PROCEDURE (VAR t: Tree) Delete* (x:Node);
  VAR
    this,father,p,q : Node;
  BEGIN
    this:=t.root;
    WHILE (this # NIL) & ~x.EqualTo(this) DO
      father:=this;
      IF x.LessThan(this) THEN
        this:=this.left;
      ELSE
        this:=this.right;
      END(*IF*);
    END(*WHILE*);
    IF this # NIL THEN (* find a node to replace this *)
      IF this.right=NIL THEN
        p:=this.left;
      ELSIF this.right.left=NIL THEN
        p     :=this.right;
        p.left:=this.left;
      ELSE
        p:=this.right;
      END(*IF*);
      WHILE p.left # NIL DO
        q:=p;
        p:=p.left;
      END(*WHILE*);
      IF this=t.root THEN
        t.root:=p;
      ELSIF this.LessThan(father) THEN
        father.left  := p;
      ELSE
        father.right := p;
      END(*IF*);
    END(*IF*);
  END Delete;


  PROCEDURE (VAR t:Tree) Traverse* (mode: SHORTINT; do: doproc);

    PROCEDURE PreOrder(t: Node; do : doproc);
    BEGIN
      do(t);
      IF t.left # NIL THEN PreOrder(t.left,do); END(*IF*);
      IF t.right# NIL THEN PreOrder(t.right,do); END(*IF*);
    END PreOrder;

    PROCEDURE PostOrder(t: Node; do : doproc);
    BEGIN
      IF t.left # NIL THEN PostOrder(t.left,do); END(*IF*);
      IF t.right# NIL THEN PostOrder(t.right,do); END(*IF*);
      do(t);
    END PostOrder;

    PROCEDURE InOrder(t: Node; do : doproc);
    BEGIN
      IF t.left # NIL THEN InOrder(t.left,do); END(*IF*);
      do(t);
      IF t.right# NIL THEN InOrder(t.right,do); END(*IF*);
    END InOrder;

  BEGIN
    IF t.root # NIL THEN
      CASE mode OF
         inorder   : InOrder(t.root,do);
       | preorder  : PreOrder(t.root,do);
       | postorder : PostOrder(t.root,do);
      ELSE
        RETURN (* wrong mode *);
      END(*CASE*);
    END(*IF*);
  END Traverse;

END BinTree.
