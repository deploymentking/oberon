MODULE lines;

IMPORT Float, CP := ColorPlane;

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


(*Main Program*)
PROCEDURE ProgMain*;

CONST
    LENGTH = 50;
    PI = 3.14159;
    MINX = 200; (*Starting x coordinate*)
    MINY = 200; (*Starting y coordinate*)
    MAXX = 500; (*maximum x coordinate*)
    MAXY = 500; (*maximum y coordinate*)
    MAXCOLOUR = 255; (*all colours are given to ColourPlane as RGB values.
                       The minimum value for red, green or blue is 0, the
                       maximum is 255. Thus, the colour value 0,0,255 is blue,
                       and 0, 150, 150 is a muddy turquoise on my screen! *)
VAR
    x, y, count, count1 : INTEGER;
  
BEGIN
    (*create display area for graphics, this must be
    the first thing done*)
    CP.Open();
    
    (*Set up starting coordinates for drawing, and move
    cursor to this position*)
    x := 100; y := 100;
    CP.GotoXY(x, y);
    (*CP.Line(x, y, x, y + 50, CP.DRAW);  *)
  (*  FOR count := 10 TO 100 BY 5 DO
        CP.SetForeColor(223,2,23);
        CP.Line(x, y + count, x + 100, y + count, CP.DRAW);
    END;        *)
    

    FOR count1 := 1 TO 100 BY 2 DO 
         CP.Line(x + count1, y + count1, x + count1, (y + 50)+ count1, CP.DRAW); 
    END;

    
    FOR count := 1 TO 100 BY 2 DO
        CP.Line(x + count, y + count, (x + 50) + count, y + count, CP.DRAW);
    END;
    
    HoldScreen;
    
    
END ProgMain;
END lines. 
