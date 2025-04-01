(* Listing 4 *)

MODULE GraphMOB;

  IMPORT Box, Point;

  VAR p : Point.Type;
      b : Box.Type;


BEGIN Box.INIT(b,10,10,50,50);
      Point.INIT(p,400,400);

      Point.MOVE(b.ID,p.ID,Point.DRAW);
      Point.MOVE(b.ID,p.ID,Box.DRAW);

      HALT
END GraphMOB.



