MODULE Trucks;

IMPORT CP := ColorPlane;

(*This will draw a little box to represent a truck for destination 1*)
PROCEDURE TruckDest1*(x, y : INTEGER);
BEGIN
    CP.SetForeColor(0,0,255);
    CP.Bar(x, y, x + 5, y + 5, CP.DRAW);
END TruckDest1;

(*This will draw a little box to represent a truck for destination 2*)
PROCEDURE TruckDest2*(x, y : INTEGER);
BEGIN
    CP.SetForeColor(0,255,0);
    CP.Bar(x, y, x + 5, y + 5, CP.DRAW);
END TruckDest2;

(*This will draw a little box to represent a truck for destination 3*)
PROCEDURE TruckDest3*(x, y : INTEGER);
BEGIN
    CP.SetForeColor(255,0,0);
    CP.Bar(x, y, x + 5, y + 5, CP.DRAW);
END TruckDest3;

(*This procedure will erase the trucks from the siding after sorting
  by setting the colour to the background*)
PROCEDURE Erase*(x, y : INTEGER);
BEGIN
    CP.SetForeColor(255,255,255);
    CP.Bar(x, y, x + 5, y + 5, CP.DRAW);
END Erase;

END Trucks.
