MODULE logo;

IMPORT CP := ColorPlane, F := Float;


(*This procedure holds the screen after the last action has been 
  executed*)
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


(*This is a procedure to draw the serif in the top right corner of 
  a letter*)
PROCEDURE TRSerif (STARTX, STARTY : INTEGER);
BEGIN
    CP.Line(STARTX, STARTY, STARTX + 1, STARTY + 1, CP.DRAW);
    CP.Line(STARTX + 1, STARTY + 1, STARTX + 2, STARTY + 1, CP.DRAW);
    CP.Line(STARTX + 2, STARTY + 1, STARTX + 3, STARTY + 2, CP.DRAW);
    CP.Line(STARTX + 3, STARTY + 2, STARTX + 4, STARTY + 3, CP.DRAW);
    CP.Line(STARTX + 4, STARTY + 3, STARTX + 5, STARTY + 3, CP.DRAW);
END TRSerif;      


(*This is a procedure to draw the serif in the top left corner of 
  a letter*)
PROCEDURE TLSerif (STARTX, STARTY : INTEGER);
BEGIN
    CP.Line(STARTX, STARTY, STARTX - 1, STARTY + 1, CP.DRAW);
    CP.Line(STARTX - 1, STARTY + 1, STARTX - 2, STARTY + 1, CP.DRAW);
    CP.Line(STARTX - 2, STARTY + 1, STARTX - 3, STARTY + 2, CP.DRAW);
    CP.Line(STARTX - 3, STARTY + 2, STARTX - 4, STARTY + 3, CP.DRAW);
    CP.Line(STARTX - 4, STARTY + 3, STARTX - 5, STARTY + 3, CP.DRAW);
END TLSerif;      


(*This is a procedure to draw the serif in the bottom right corner of 
  a letter*)
PROCEDURE BRSerif (STARTX, STARTY : INTEGER);
BEGIN
    CP.Line(STARTX, STARTY, STARTX + 1, STARTY - 1, CP.DRAW);
    CP.Line(STARTX + 1, STARTY - 1, STARTX + 2, STARTY - 1, CP.DRAW);
    CP.Line(STARTX + 2, STARTY - 1, STARTX + 3, STARTY - 2, CP.DRAW);
    CP.Line(STARTX + 3, STARTY - 2, STARTX + 4, STARTY - 3, CP.DRAW);
    CP.Line(STARTX + 4, STARTY - 3, STARTX + 5, STARTY - 3, CP.DRAW);
END BRSerif;      


(*This is a procedure to draw the serif in the bottom left corner of 
  a letter*)
PROCEDURE BLSerif (STARTX, STARTY : INTEGER);
BEGIN
    CP.Line(STARTX, STARTY, STARTX - 1, STARTY - 1, CP.DRAW);
    CP.Line(STARTX - 1, STARTY - 1, STARTX - 2, STARTY - 1, CP.DRAW);
    CP.Line(STARTX - 2, STARTY - 1, STARTX - 3, STARTY - 2, CP.DRAW);
    CP.Line(STARTX - 3, STARTY - 2, STARTX - 4, STARTY - 3, CP.DRAW);
    CP.Line(STARTX - 4, STARTY - 3, STARTX - 5, STARTY - 3, CP.DRAW);
END BLSerif;      


(*This procedure draws the vertical line used in the L, R, I and N*)    
PROCEDURE VertLine (STARTX, STARTY : INTEGER);
BEGIN
    CP.Line(STARTX, STARTY, STARTX, STARTY + 94, CP.DRAW);
END VertLine;


(*This procedure draws the serif horizontal line that appears
  in all letters*)
PROCEDURE HorizLine (STARTX, STARTY : INTEGER );
BEGIN
    CP.Line(STARTX, STARTY, STARTX + 20, STARTY, CP.DRAW);
END HorizLine;


(*This procedure draws the box that surrounds the text*)    
PROCEDURE Box;
CONST
    MINX = 50; (*Starting x coordinate*)
    MINY = 50; (*Starting y coordinate*)
    MAXX = 585; (*Maximum x coordinate*)
    MAXY = 160; (*Maximum y coordinate*)
    IL = 20; (*Indent length for the outside box*)
BEGIN 
    CP.Box(MINX, MINY, MAXX, MAXY, CP.DRAW);
    CP.Line(MAXX, MAXY, MAXX + IL, MAXY + IL, CP.DRAW);
    CP.Line(MINX, MINY, MINX - IL, MINY - IL, CP.DRAW);
    CP.Line(MINX, MAXY, MINX - IL, MAXY + IL, CP.DRAW);
    CP.Line(MAXX, MINY, MAXX + IL, MINY - IL, CP.DRAW);
    CP.Line(MINX - IL, MINY - IL, MINX - IL, MAXY + IL, CP.DRAW);
    CP.Line(MINX - IL, MAXY + IL, MAXX + IL, MAXY + IL, CP.DRAW);
    CP.Line(MAXX + IL, MAXY + IL, MAXX + IL, MINY - IL, CP.DRAW); 
    CP.Line(MINX - IL, MINY - IL, MAXX + IL, MINY - IL, CP.DRAW);
END Box;


(*Main Program*)
PROCEDURE ProgMain*;
BEGIN
    (*create display area for graphics, this must be
    the first thing done*)
    CP.Open();
    Box;
    HoldScreen;
    
    
END ProgMain;
END logo. 
