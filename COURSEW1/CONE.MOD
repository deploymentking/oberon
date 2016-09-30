MODULE cone;

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
    x, y, x2, y2, angle, count, color : INTEGER; 
    a, b, angleRad, x1, y1 : REAL;
    buttons : SET;
BEGIN
    (*create display area for graphics, this must be
    the first thing done*)
    CP.Open();
    
    (*Set up starting coordinates for drawing, and move
    cursor to this position*)
    (*x := MINX; y := MINY;
    CP.GotoXY(x, y);*)
    

  (*  
    REPEAT
       UNTIL CP.KeyPressed();   *)
 
  
  CP.SetForeColor(0,0,0);
    FOR angle := 0 TO 360 BY 1 DO
      
      angleRad := (angle/180) * PI;
      x1 := Float.Cos (angleRad) * 25;
      y1 := Float.Sin (angleRad) * 25;
      x := SHORT (ENTIER (x1)); y := SHORT (ENTIER (y1));
      CP.Line (100, 100, MINX + x, MINY + y, CP.DRAW); 

    END;   
        

                
                
  (*  FOR angle := 0 TO 360 BY 10 DO

        startAngleRad := (angle / 180) * PI;
        a := Float.Cos (startAngleRad) * 50;
        b := Float.Sin (startAngleRad) * 50;
        x1 := SHORT(ENTIER(a)) + MINX;
        y1 := SHORT(ENTIER(b)) + MINY;
        IF angle # 0 THEN
            CP.Line(x1, y1, x2, y2, CP.DRAW);
        END;
        x2 := x1;
        y2 := y1;
    END;    
                   *)
    
   
    HoldScreen;
    
    
END ProgMain;
END cone. 
