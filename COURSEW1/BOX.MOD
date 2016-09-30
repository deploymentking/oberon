MODULE box;

IMPORT F := Float, CP := ColorPlane;
 
PROCEDURE HoldScreen;
CONST
    RIGHT = 2; (*Value returned by the right mouse button*)
   
VAR
    buttons : SET; (*The set of mouse button values*)
    x, y : INTEGER; (*Needed simply for GetMouse, which returns both set of 
                      buttons which have been pressed, and the current 
                      coordinates of the mouse pointer which we don't need to 
                      here*)
BEGIN
    REPEAT
        CP.GetMouse(buttons, x, y);
    UNTIL (RIGHT IN buttons);;
END HoldScreen;

PROCEDURE Box;
CONST
    MINX = 40; (*Starting x coordinate*)
    MINY = 50; (*Starting y coordinate*)
    MAXX = 590; (*maximum x coordinate*)
    MAXY = 210; (*maximum y coordinate*)
 
VAR
    x, y, count : INTEGER; (*Screen coordinates*)
    
BEGIN
    x := MINX; y := MINY;
    CP.SetForeColor(255,255,255);
    CP.Line(x, y, MAXX, y, CP.DRAW);
    CP.Line(x, y, x, MAXY, CP.DRAW);
    CP.Line(x, MAXY, MAXX, MAXY, CP.DRAW); 
    CP.Line(MAXX, y, MAXX, MAXY, CP.DRAW);
    CP.Line(MAXX, MAXY, MAXX + 5, MAXY + 5, CP.DRAW);
    CP.Line(MINX, MINY, MINX - 5, MINY - 5, CP.DRAW);
    CP.Line(MINX, MAXY, MINX - 5, MAXY + 5, CP.DRAW);
    CP.Line(MAXX, MINY, MAXX + 5, MINY - 5, CP.DRAW); 
    CP.SetForeColor(255,255,255);
    CP.Line(MINX - 5, MINY - 5, MINX - 5, MAXY + 5, CP.DRAW);
    CP.Line(MINX - 5, MAXY + 5, MAXX + 5, MAXY + 5, CP.DRAW);
    CP.Line(MAXX + 5, MAXY + 5, MAXX + 5, MINY - 5, CP.DRAW); 
    CP.Line(MINX - 5, MINY - 5, MAXX + 5, MINY - 5, CP.DRAW);
    (*CP.SetForeColor(0,0,0);
    CP.Bar(MINX - 1, MINY - 1, MAXX -1, MAXY -1 , CP.DRAW);*)
END Box;

(*Main Program*)
PROCEDURE ProgMain*;
CONST
    MAXCOLOUR = 255; 
VAR
    x, y : INTEGER;
     
BEGIN
    
    CP.Open();
    
    CP.SetBackColor(0,0,0);
    CP.Clear();
    CP.GotoXY(x, y);
    Box;
    HoldScreen;       
    
    
END ProgMain;
END box. 
