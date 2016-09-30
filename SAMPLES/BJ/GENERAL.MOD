(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von CARDS.DLL        *)
(*                                                                        *)
(*  Modulname:          GENERAL.MOD                                       *)
(*  Aufgabe:            Diverses                                          *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        16. April 1995 - TDrawable, TRandomObject,        *)
(*                                       TBitmap                          *)
(*  Änderungen:         19. April 1995 - TWindow, TBufferedWindow         *)
(*                      24. April 1995 - T3DRect                          *)
(*                                                                        *)
(**************************************************************************)

MODULE General;

IMPORT W := Windows, SYSTEM, Utils, WU:=WinUtils;

CONST ABSTRACTCALL*   = 1;
      MAXDRAWPERIOD*  = 100;
      MAXSTRLEN*      = 25;
      DEF_CREDIT*     = 1000;
      DEF_BET*        = 20;
      DEF_NOOFPLAYERS* = 2;

TYPE PRandomNumber* = POINTER TO TRandomNumber;
     TRandomNumber* = RECORD
       value   : INTEGER;
     END;                            (* Objektklasse zur Erzeugung von       *) 
                                     (* positiven ganzzahligen Zufallszahlen *)

     PDrawable* = POINTER TO TDrawable;
     TDrawable* = RECORD 
       x-   : INTEGER;
       y-   : INTEGER;
     END;       (* Abstrakte Basisklasse für alle zeichenbaren Objektklassen *)
     
     P3DRect* = POINTER TO T3DRect;
     T3DRect* = RECORD(TDrawable)
       x2-          : INTEGER;
       y2-          : INTEGER;
       fillColor-   : LONGINT;
       topColor-    : LONGINT;
       bottomColor- : LONGINT;
       thickDraw-   : BOOLEAN;
     END;
     
     PBitmap* = POINTER TO TBitmap;
     TBitmap* = RECORD(TDrawable)
       handle-: W.HBITMAP;
       width  : INTEGER;
       height : INTEGER;
     END;

     PWindow* = POINTER TO TWindow;
     TWindow* = RECORD
       wnd-          : W.HWND;                              (* Window-Handle *)
       message-      : W.WORD;          (* MessageID der aktuellsten Message *) 
       wParam-       : W.WORD;          (* Parameter der aktuellsten Message *)
       lParam-       : LONGINT;         (* Parameter der aktuellsten Message *)
     END;
     
     PBufferedWindow* = POINTER TO TBufferedWindow;
     TBufferedWindow* = RECORD(TWindow)
       sizeX-        : INTEGER;                (* Größe des Shadow-Bitmaps = *)
       sizeY-        : INTEGER;                (* = Größe des Client-Rects   *)
       shadowBitmap  : W.HBITMAP;                           (* Shadow-Bitmap *)
       drawDC        : W.HDC;                  (* Devicekontext zum Zeichnen *)
       oldBitmap     : W.HBITMAP;             (* altes Bitmap des Zeichnen-DC*)
       lastDrawTime  : LONGINT;     (* Systemzeit der letzten Draw-Operation *)
       lastPaintTime : LONGINT;              (* Systemzeit des letzten Paint *)
     END;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE StringCopy*(VAR aDest : ARRAY OF CHAR; aSrc : ARRAY OF CHAR);
VAR i : INTEGER;
BEGIN
  i := 0;
  WHILE (aSrc[i] # 0X) DO
    aDest[i] := aSrc[i];
    INC(i);
  END;
  aDest[i] := 0X;
END StringCopy;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitRandomNumber*(r : PRandomNumber);
VAR sec, min, hour : INTEGER;
    hLongInt : LONGINT;
BEGIN
  Utils.GetTime(sec, min, hour);
  hLongInt := sec;
  r.value := SHORT(((hLongInt*60+min)*60+hour) MOD (MAX(INTEGER)+1));
END InitRandomNumber;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR r : TRandomNumber) Destroy*();
BEGIN
END Destroy;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR r : TRandomNumber) GetNumber*(aModule : INTEGER) : INTEGER;
  (* Berechnet eine neue Zufallszahl im Bereich 0..aModule-1 und liefert es  *)
  (* als Returnwert                                                          *)
VAR hLongInt : LONGINT;
BEGIN
  ASSERT(aModule > 0);
  hLongInt := r.value;
  r.value := SHORT((hLongInt*3421+1) MOD aModule);
  RETURN r.value;
END GetNumber;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitDrawable*(d : PDrawable; aX, aY : INTEGER);
BEGIN
  d.x := aX;
  d.y := aY;
END InitDrawable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR d : TDrawable) Draw*(dc : W.HDC);
BEGIN
  HALT(ABSTRACTCALL);
END Draw;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR d : TDrawable) DrawOffs*(dc : W.HDC; aX, aY : INTEGER);
BEGIN
  INC(d.x, aX); INC(d.y, aY);
  d.Draw(dc);
  DEC(d.x, aX); DEC(d.y, aY);
END DrawOffs;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR d : TDrawable) MoveAbs*(aX, aY : INTEGER);
BEGIN
  d.x := aX;
  d.y := aY;
END MoveAbs;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR d : TDrawable) MoveRel*(aX, aY : INTEGER);
BEGIN
  d.MoveAbs(d.x+aX, d.y+aY);
END MoveRel;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR d : TDrawable) Destroy*();
BEGIN
END Destroy;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE Init3DRect*(r : P3DRect; aX1, aY1, aX2, aY2 : INTEGER; 
                      aFillColor, aTopColor, aBottomColor : LONGINT; 
                      aThickDraw : BOOLEAN);
BEGIN
  InitDrawable(r, aX1, aY1);
  r.x2          := aX2;
  r.y2          := aY2;
  r.fillColor   := aFillColor;
  r.topColor    := aTopColor;
  r.bottomColor := aBottomColor;
  r.thickDraw   := aThickDraw;
END Init3DRect;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR r : T3DRect) Draw*(dc : W.HDC);
VAR brush,
    oldBrush : W.HBRUSH;
    pen      : W.LOGPEN;
    oldPen,
    newPen   : W.HPEN;
    dummy    : LONGINT;
BEGIN
  brush    := W.CreateSolidBrush(r.fillColor);
  oldBrush := W.SelectObject(dc, brush);
  oldPen   := W.SelectObject(dc, W.GetStockObject(W.NULL_PEN));
  dummy := W.Rectangle(dc, r.x, r.y, r.x2+1, r.y2+1);
  oldPen   := W.SelectObject(dc, oldPen);

  newPen := W.CreatePen(W.PS_SOLID, 1, r.topColor);
  oldPen := W.SelectObject(dc, newPen);
  dummy := W.MoveTo(dc, r.x, r.y2-1);
  ASSERT(W.LineTo(dc, r.x, r.y) # W.NULL);
  dummy := W.MoveTo(dc, r.x, r.y);
  ASSERT(W.LineTo(dc, r.x2+1, r.y) # W.NULL);

  IF r.thickDraw THEN
    dummy := W.MoveTo(dc, r.x+1, r.y2-2);
    ASSERT(W.LineTo(dc, r.x+1, r.y) # W.NULL);
    dummy := W.MoveTo(dc, r.x, r.y+1);
    ASSERT(W.LineTo(dc, r.x2, r.y+1) # W.NULL);
  END;
  oldPen := W.SelectObject(dc, oldPen);
  ASSERT(W.DeleteObject(newPen) # W.NULL);

  newPen := W.CreatePen(W.PS_SOLID, 1, r.bottomColor);
  oldPen := W.SelectObject(dc, newPen);
  dummy := W.MoveTo(dc, r.x2, r.y+1);
  ASSERT(W.LineTo(dc, r.x2, r.y2+1) # W.NULL);
  dummy := W.MoveTo(dc, r.x, r.y2);
  ASSERT(W.LineTo(dc, r.x2, r.y2) # W.NULL);

  IF r.thickDraw THEN
    dummy := W.MoveTo(dc, r.x2-1, r.y+2);
    ASSERT(W.LineTo(dc, r.x2-1, r.y2) # W.NULL);
    dummy := W.MoveTo(dc, r.x+1, r.y2-1);
    ASSERT(W.LineTo(dc, r.x2, r.y2-1) # W.NULL);
  END;
  oldPen := W.SelectObject(dc, oldPen);
  oldBrush := W.SelectObject(dc, oldBrush);
  ASSERT(W.DeleteObject(newPen) # W.NULL);
  ASSERT(W.DeleteObject(brush) # W.NULL);
END Draw;
  
(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitBitmap*(b : PBitmap; aHandle : W.HBITMAP);
VAR bm : W.BITMAP;
BEGIN
  InitDrawable(b, 0, 0);
  b.handle := aHandle;
  ASSERT(W.GetObject(aHandle,SIZE(W.BITMAP),SYSTEM.ADR(bm)) # 0);
  b.width  := bm.bmWidth;
  b.height := bm.bmHeight;
END InitBitmap;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR b : TBitmap) Draw*(dc : W.HDC);
VAR hdc : W.HDC;
    oldBitmap : W.HBITMAP;
    dummy     : INTEGER;
    dummy2    : LONGINT;
BEGIN
  dummy := W.SetBkMode(dc, W.OPAQUE);
  dummy2 := W.SetBkColor(dc, WU.RGB(255, 255, 255));
  hdc := W.CreateCompatibleDC(dc); ASSERT(hdc # W.NULL);
  oldBitmap := W.SelectObject(hdc, b.handle); ASSERT(oldBitmap # W.NULL);
  ASSERT(W.BitBlt(dc, b.x, b.y, b.width, b.height, hdc, 0, 0, W.SRCCOPY) # 0);
  ASSERT(W.SelectObject(hdc, oldBitmap) # W.NULL);
  ASSERT(W.DeleteDC(hdc) # 0);
END Draw;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitWindow*(w : PWindow; aWnd : W.HWND);
BEGIN
  w.wnd := aWnd;
END InitWindow;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) GetDC*() : W.HDC;
VAR hdc : W.HDC;
BEGIN
  hdc := W.GetDC(w.wnd);
  ASSERT(hdc # 0);
  RETURN hdc;
END GetDC;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) ReleaseDC*(aDC : W.HDC) : INTEGER;
BEGIN
  RETURN W.ReleaseDC(w.wnd, aDC);
END ReleaseDC;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) SetParams*(aMessage : W.WORD;
                                       aWParam : W.WORD; 
                                       aLParam : LONGINT);
BEGIN
  w.message := aMessage;
  w.wParam := aWParam;
  w.lParam := aLParam;
END SetParams;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) DefWindowProc*() :LONGINT;
BEGIN
  RETURN W.DefWindowProc(w.wnd, w.message, w.wParam, w.lParam);
END DefWindowProc;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) WMCreate*() : LONGINT;
BEGIN
  RETURN w.DefWindowProc();
END WMCreate;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) WMDestroy*() : LONGINT;
BEGIN
  RETURN w.DefWindowProc();
END WMDestroy;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) WMPaint*() : LONGINT;
BEGIN
  RETURN w.DefWindowProc();
END WMPaint;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) WMCommand*() : LONGINT;
BEGIN
  RETURN w.DefWindowProc();
END WMCommand;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) WMSize*() : LONGINT;
BEGIN
  RETURN w.DefWindowProc();
END WMSize;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) MainWndProc*() : LONGINT;
BEGIN
  IF (w.message = W.WM_CREATE) THEN RETURN w.WMCreate();
  ELSIF (w.message = W.WM_DESTROY) THEN RETURN w.WMDestroy();
  ELSIF (w.message = W.WM_PAINT) THEN RETURN w.WMPaint();
  ELSIF (w.message = W.WM_COMMAND) THEN RETURN w.WMCommand();
  ELSIF (w.message = W.WM_SIZE) THEN RETURN w.WMSize();
  ELSE RETURN w.DefWindowProc();
  END;
END MainWndProc;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TWindow) DoneDraw*(VAR r : W.RECT);
BEGIN
END DoneDraw;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitBufferedWindow*(w : PBufferedWindow; aWnd : W.HWND);
BEGIN
  InitWindow(w, aWnd);
END InitBufferedWindow;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) GetDC*() : W.HDC;
BEGIN
  RETURN w.drawDC;
END GetDC;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) ReleaseDC*(aDC : W.HDC) : INTEGER;
BEGIN
  ASSERT(aDC = w.drawDC);
  RETURN 1;
END ReleaseDC;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) WMCreate*() : LONGINT;
VAR dc  : W.HDC;
    ret : LONGINT;
    r   : W.RECT;
BEGIN
  ret := w.WMCreate^();
  
  W.GetClientRect(w.wnd, SYSTEM.ADR(r));
  w.sizeX := r.right - r.left + 1;
  w.sizeY := r.bottom - r.top + 1;
  
  dc := W.GetDC(w.wnd);
  w.drawDC := W.CreateCompatibleDC(dc); ASSERT(w.drawDC # 0);
  w.shadowBitmap := W.CreateCompatibleBitmap(w.drawDC, w.sizeX, w.sizeY);
  ASSERT(w.shadowBitmap # W.NULL);
  w.oldBitmap := W.SelectObject(w.drawDC, w.shadowBitmap);
  ASSERT(w.oldBitmap # W.NULL);
  ASSERT(W.PatBlt(w.drawDC, 0, 0, w.sizeX, w.sizeY, W.WHITENESS) # 0);
  ASSERT(W.ReleaseDC(w.wnd, dc) = 1);

  w.lastPaintTime := W.GetTickCount();
  RETURN ret;
END WMCreate;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) WMDestroy*() : LONGINT;
BEGIN
  ASSERT(W.SelectObject(w.drawDC, w.oldBitmap) # W.NULL);
  ASSERT(W.DeleteDC(w.drawDC) # 0);
  ASSERT(W.DeleteObject(w.shadowBitmap) # 0);
  RETURN w.WMDestroy^();
END WMDestroy;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) WMPaint*() : LONGINT;
VAR hdc : W.HDC;
    ps : W.PAINTSTRUCT;
BEGIN
  hdc := W.BeginPaint(w.wnd, SYSTEM.ADR(ps));
  ASSERT(W.BitBlt(hdc,
                  ps.rcPaint.left, ps.rcPaint.top,
                  ps.rcPaint.right-ps.rcPaint.left+1,
                  ps.rcPaint.bottom-ps.rcPaint.top+1,
                  w.drawDC,
                  ps.rcPaint.left, ps.rcPaint.top,
                  W.SRCCOPY) # 0);
                              (* Zu restaurienden Teil mit entsprechendem *)
                              (* Teil des Shadow-Bitmaps überschreiben    *)
  W.EndPaint(w.wnd, SYSTEM.ADR(ps));
  w.lastPaintTime := W.GetTickCount();
  RETURN 0;
END WMPaint;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) WMSize*() : LONGINT;
BEGIN
  IF (w.wParam # W.SIZEICONIC) &
     ((Utils.LoWord(w.lParam) # w.sizeX) OR 
      (Utils.HiWord(w.lParam) # w.sizeY)) THEN
    w.sizeX := Utils.LoWord(w.lParam);
    w.sizeY := Utils.HiWord(w.lParam);

    ASSERT(W.SelectObject(w.drawDC, w.oldBitmap) # W.NULL);
    ASSERT(W.DeleteObject(w.shadowBitmap) # 0);
    w.shadowBitmap := W.CreateCompatibleBitmap(w.drawDC, w.sizeX, w.sizeY);
    ASSERT(w.shadowBitmap # W.NULL);
    w.oldBitmap := W.SelectObject(w.drawDC, w.shadowBitmap);
    ASSERT(w.oldBitmap # W.NULL);
    ASSERT(W.PatBlt(w.drawDC, 0, 0, w.sizeX, w.sizeY, W.WHITENESS) # 0);

    w.lastPaintTime := W.GetTickCount();
  END;
  RETURN W.DefWindowProc(w.wnd, W.WM_SIZE, w.wParam, w.lParam);
END WMSize;

(*------------------------------------------------------------------------*)

PROCEDURE (VAR w : TBufferedWindow) DoneDraw*(VAR r : W.RECT);
BEGIN
  W.InvalidateRect(w.wnd, SYSTEM.ADR(r), 1);
  w.lastDrawTime := W.GetTickCount();
  IF w.lastDrawTime-w.lastPaintTime > MAXDRAWPERIOD THEN
    W.UpdateWindow(w.wnd);
  END;
END DoneDraw;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

END General.