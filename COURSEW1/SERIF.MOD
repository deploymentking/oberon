MODULE serif;

IMPORT CP := ColorPlane;

PROCEDURE HoldScreen;

CONST
    RIGHT = 2; 
VAR
    buttons : SET; 
    x, y : INTEGER; 
BEGIN
    REPEAT
        CP.GetMouse(buttons, x, y);
    UNTIL (RIGHT IN buttons);;
END HoldScreen;


 
    
  (*  CP.Line(140,140,142,142,CP.DRAW);
    CP.Line(142,142,144,142,CP.DRAW);
    CP.Line(144,142,146,144,CP.DRAW);
    CP.Line(146,144,148,144,CP.DRAW);
    CP.Line(148,144,150,146,CP.DRAW);     *)
PROCEDURE Serif (MINX, MINY : INTEGER);
BEGIN

    CP.Line(MINX, MINY, MINX + 1, MINY + 1, CP.DRAW);
    CP.Line(MINX + 1, MINY + 1, MINX + 2, MINY + 1, CP.DRAW);
    CP.Line(MINX + 2, MINY + 1, MINX + 3, MINY + 2, CP.DRAW);
    CP.Line(MINX + 3, MINY + 2, MINX + 4, MINY + 3, CP.DRAW);
    CP.Line(MINX + 4, MINY + 3, MINX + 5, MINY + 3, CP.DRAW);
END Serif;    
    
    
    
(*Main Program*)
PROCEDURE ProgMain*;
BEGIN
    (*create display area for graphics, this must be
    the first thing done*)
    CP.Open();
    Serif(100, 100);    
    HoldScreen;
    
    
END ProgMain;
END serif. 
