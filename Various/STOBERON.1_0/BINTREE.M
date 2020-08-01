MODULE BinTree;

(* Demo implementation of unbalanced binary trees *)

TYPE
     pNode*      = POINTER TO Node;
     Node*       = RECORD
                     left, right, parent: pNode
                   END; 
     CompareProc*= PROCEDURE (node1, node2: pNode) : SHORTINT;
                   (* node1   < node2 => result < 0 *)
                   (* node1   = node2 => result = 0 *)
                   (* node1   > node2 => result > 0 *)
     VisitProc*  = PROCEDURE (node: pNode);
     FindProc*   = PROCEDURE (node: pNode): SHORTINT;
                   (* key is lower  => < 0 *)
                   (* found         => = 0 *)
                   (* key is higher => > 0 *)
                   
PROCEDURE Insert*(VAR root: pNode; node: pNode; Compare: CompareProc);

  PROCEDURE RecInsert(VAR curr: pNode; node, parent: pNode; Compare: CompareProc);
  BEGIN
    IF curr # NIL THEN
      IF Compare(node, curr) < 0 THEN RecInsert(curr.left, node, curr, Compare)
      ELSE RecInsert(curr.right, node, curr, Compare)
      END
    ELSE
      curr := node; node.parent := parent
    END
  END RecInsert;
  
BEGIN
  RecInsert(root, node, NIL, Compare)
END Insert;

PROCEDURE Traverse*(root: pNode; Visit: VisitProc);
BEGIN
  IF root # NIL THEN
    Traverse(root.left, Visit); Visit(root); Traverse(root.right, Visit)
  END
END Traverse;

PROCEDURE Find*(root: pNode; Compare: FindProc): pNode;

VAR curr   : pNode;
    result : SHORTINT;
    
BEGIN
  curr := root;
  WHILE curr # NIL DO
    result := Compare(curr);
    IF result < 0 THEN curr := curr.left
    ELSIF result = 0 THEN RETURN curr
    ELSE curr := curr.right
    END
  END;
  RETURN NIL
END Find;

PROCEDURE Delete*(VAR root: pNode; node: pNode);

VAR parent, curr: pNode;

BEGIN
  parent := node.parent;
  IF node.left # NIL THEN
    curr := node.left;
    WHILE curr.right # NIL DO curr := curr.right END;
    curr.right:=node.right;
    curr:=node.left
  ELSE
    curr:=node.right
  END;
  IF parent = NIL THEN
    root := curr
  ELSIF parent.left = node THEN
    parent.left := curr
  ELSE (* parent.right = node *)
    parent.right := curr
  END
END Delete;

END BinTree.
