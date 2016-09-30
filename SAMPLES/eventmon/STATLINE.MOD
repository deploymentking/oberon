(******************************************************************************)
(* MODULE:      StatLine                                        ME - 06.06.96 *)
(* DESCRIPTION: Provides a status line                                        *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 06.06.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE StatLine;

IMPORT SYSTEM, W := Windows;
  
CONST
  ClassName = "WC_StatusLine";
  BAR_HEIGHT* = 25;

TYPE
  StatusLineP = POINTER TO StatusLineDesc;
  StatusLineDesc = RECORD                   (* structure to hold status text  *)
    statusText: ARRAY 100 OF CHAR;
    textLen:  INTEGER;
  END;
 
VAR
    hInstBar:   W.HINSTANCE;                (* this module handle             *)
    hFont:      W.HFONT;                    (* font for status line           *)
    

(*============================================================================*)
(* PURPOSE:  StatusLineProc is the window function for this status line class *)
(*           It handles all messages sent to this bar.                        *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           window handle                                               *)
(* msg            message sent to the window                                  *)
(* wParam         first parameter of the message                              *)
(* lParam         second parameter                                            *) 
(*============================================================================*)
PROCEDURE [WINDOWS] StatusLineProc*(hWnd: W.HWND;
                                   msg: W.WORD; 
                                   wParam: W.WPARAM; 
                                   lParam: W.LPARAM): LONGINT;

VAR
  hdc:         W.HDC;
  hObj:        W.HGDIOBJ;
  hPen:        W.HPEN;
  hWndParent:  W.HWND;
  prevBkMode:  INTEGER;
  ps:          W.PAINTSTRUCT;
  r:           INTEGER;
  rb:          W.BOOL;
  rl:          LONGINT;
  rect:        W.RECT;
  data:        StatusLineP;

BEGIN

  IF msg = W.WM_PAINT THEN

    (*-- Get data --*)
    data := SYSTEM.VAL(StatusLineP, W.GetWindowLong(hWnd, 0)); ASSERT(data # NIL);

    (*-- Get size of parent window --*)
    W.GetClientRect(hWnd, SYSTEM.ADR(rect));

    hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));

    (*-- Draw a frame of statusline --*)
    INC(rect.left, 2); INC(rect.top, 3); DEC(rect.right, 2); DEC(rect.bottom, 3);
    
    hPen := W.SelectObject(hdc, W.GetStockObject(W.BLACK_PEN));
    rl := W.MoveTo(hdc, rect.left, rect.bottom);
    r := W.LineTo(hdc, rect.left, rect.top);
    r := W.LineTo(hdc, rect.right, rect.top);
    r := W.SelectObject(hdc, W.GetStockObject(W.WHITE_PEN));
    r := W.LineTo(hdc, rect.right, rect.bottom);
    r := W.LineTo(hdc, rect.left, rect.bottom);
    r := W.SelectObject(hdc, hPen);

    (*-- Display text --*)
    INC(rect.left, 10); 
    r := W.DrawText(hdc, 
                    SYSTEM.ADR(data^.statusText), 
                    data^.textLen, SYSTEM.ADR(rect), 
                    W.DT_SINGLELINE + W.DT_LEFT + W.DT_VCENTER);

    W.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;
    
  ELSIF msg = W.WM_SIZE THEN
    hWndParent := W.GetParent(hWnd);
    W.GetClientRect(hWndParent, SYSTEM.ADR(rect));
    IF rect.bottom - rect.top > BAR_HEIGHT THEN
      rect.top := rect.bottom - BAR_HEIGHT;
    END;
    rb := W.MoveWindow(hWnd, rect.left, rect.top, rect.right - rect.left, BAR_HEIGHT, W.true);
    W.InvalidateRect(hWnd, W.NULL, W.true);
    RETURN 0;
    
  ELSIF msg = W.WM_SETTEXT THEN
    data := SYSTEM.VAL(StatusLineP, W.GetWindowLong(hWnd, 0)); ASSERT(data # NIL);
    data^.textLen := W.lstrlen(lParam);
    SYSTEM.MOVE(lParam, SYSTEM.ADR(data^.statusText), data^.textLen);
    W.InvalidateRect(hWnd, W.NULL, W.true);
    RETURN 0;

  ELSIF msg = W.WM_CREATE THEN

    (*-- Set background --*)
    hdc := W.GetDC(hWnd);
    prevBkMode := W.SetBkMode(hdc, W.TRANSPARENT);
    hObj := W.SelectObject(hdc, hFont);
    r := W.ReleaseDC(hWnd, hdc);
    
    (*-- Create structure --*)
    NEW(data); ASSERT(data # NIL);
    rl := W.SetWindowLong(hWnd, 0, SYSTEM.VAL(LONGINT, data));
    
    RETURN 0;
  
  ELSIF msg = W.WM_DESTROY THEN
    data := SYSTEM.VAL(StatusLineP, W.GetWindowLong(hWnd, 0)); ASSERT(data # NIL);
    DISPOSE(data);
    RETURN 0;
    
  ELSE
    RETURN W.DefWindowProc(hWnd, msg, wParam, lParam)
    
  END;
  
END StatusLineProc;


(*============================================================================*)
(* PURPOSE:  CreateStatusLine creates a custom status line as child window of *)
(*           the window hWndParent.                                           *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWndParent     window handle of parent window                              *)
(* hInstance      instance handle of the module which wants to create         *)
(*============================================================================*)
PROCEDURE [WINDOWS] CreateStatusLine*(hWndParent: W.HWND; 
                                     hInstance:  W.HINSTANCE): W.HWND;

VAR
  hWndStatLine:    W.HWND;
    
BEGIN
  (* -- create window -- *)
  hWndStatLine := W.CreateWindow(SYSTEM.ADR(ClassName), 
                                 W.NULL, 
                                 W.WS_CHILD + W.WS_VISIBLE,
                                 0,
                                 0,
                                 0,
                                 0,
                                 hWndParent, 
                                 W.NULL, 
                                 hInstance, 
                                 W.NULL);

  RETURN hWndStatLine; 
END CreateStatusLine;


(*============================================================================*)
(* PURPOSE:  Sets text of statusline                                          *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           window handle of a status bar.                              *)
(* text           text                                                        *)
(*============================================================================*)
PROCEDURE [WINDOWS] SetStatusLine*(hWnd: W.HWND; text: ARRAY OF CHAR);
VAR
  r: LONGINT;
  
BEGIN
  r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR(text));
END SetStatusLine;


(*============================================================================*)
(* PURPOSE:  LibMain is the initialization function of this dynamic link      *)
(*           library. It automatically called when this DLL is loaded.        *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hInstCurr      instance handle for this DLL                                *)
(* wDataSeg       data segment for this DLL                                   *)
(* cbHeapSize     heap size                                                   *)
(* lpszCmdLine    command line (pointer to a null terminated string)          *)
(*============================================================================*)
PROCEDURE [WINDOWS] LibMain* (hInstCurr:   W.HANDLE; 
                              wDataSeg:    INTEGER; 
                              cbHeapSize:  INTEGER; 
                              lpszCmdLine: LONGINT): INTEGER;

VAR
  wc:  W.WNDCLASS;

BEGIN

  (*-- Save global data --*)
  hInstBar := hInstCurr;
  
  (*-- Prepare window class structure --*)
  wc.style         := W.CS_GLOBALCLASS + W.CS_CLASSDC;
  wc.lpfnWndProc   := StatusLineProc; 
  wc.cbClsExtra    := 0;                     
  wc.cbWndExtra    := 4;                     
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.COLOR_BTNFACE + 1;
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);

  (*-- Register statusbar class --*)
  IF W.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    W.MessageBeep(0);
    HALT(0);
    RETURN 0;
  END;  

  (*-- Create font for statusbar --*)
  hFont := W.CreateFont(-14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, SYSTEM.ADR("MS Sans Serif"));

  RETURN 1;

END LibMain;



(*============================================================================*)
(* PURPOSE:  WEP called when this DLL is unloaded.                            *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* nExitType      type of exit (e.g.: quit W, unload DLL, ...)                *)
(*============================================================================*)
PROCEDURE [WINDOWS] WEP* (nExitType: INTEGER): INTEGER;
VAR 
  r : INTEGER;

BEGIN
  (*-- Unregister window class -- *)
  IF W.UnregisterClass(SYSTEM.ADR(ClassName), hInstBar) = 0 THEN
    W.MessageBeep(-1);
    r := W.MessageBox(W.NULL, 
                      SYSTEM.ADR("Could not unregister class !"), 
                      SYSTEM.ADR("ERROR: StatLinear.WEP"), 
                      W.MB_OK + W.MB_ICONEXCLAMATION); ASSERT(r # W.NULL); 
  END;
  
  (*-- Delete font -- *)
  IF W.DeleteObject(hFont) = 0 THEN
    W.MessageBeep(-1);
    r := W.MessageBox(W.NULL, 
                      SYSTEM.ADR("Could not delete font !"), 
                      SYSTEM.ADR("ERROR: StatLinebar.WEP"), 
                      W.MB_OK + W.MB_ICONEXCLAMATION); ASSERT(r # W.NULL);
  END;
  RETURN 1;
END WEP;

END StatLine.
