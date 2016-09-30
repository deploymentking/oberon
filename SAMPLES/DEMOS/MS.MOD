(******************************************************************************
 * MODULE:        MS
 * DESCRIPTION:   This program shows various Mouse possibilities.
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 95/03/28  PDI     Version 1.0
 * 97/03/11  PDI     minor changes for windows callback functions
 ******************************************************************************)
MODULE MS;

  IMPORT Utils, W := Windows, SYSTEM;

  CONST ClassName  = "CMouseTest";
        WindowName = "Mouse Demo";

  VAR
    selection:  BOOLEAN;
    orgX:       INTEGER;
    orgY:       INTEGER;
    prevX:      INTEGER;
    prevY:      INTEGER;


(******************************************************************************
 * DspErrMsg pops up a message box showing an ErrorMsg message.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * msg            ErrorMsg message
 ******************************************************************************)
PROCEDURE DspErrMsg*(msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := W.MessageBox(W.NULL, SYSTEM.ADR(msg), SYSTEM.ADR("Error"), W.MB_OK);
END DspErrMsg;


(******************************************************************************
 * RGB transforms an rgb-value consisting of three seperate values for red, green
 * and blue into one value needed for some GDI-functions.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * r              value for red (0..255)
 * g              value for green (0..255)
 * b              value for blue (0..255)
 ******************************************************************************)
PROCEDURE RGB(r,g,b: INTEGER): LONGINT;
BEGIN
  RETURN (b * 256 + g) * 256 + r
END RGB;


(******************************************************************************
 *
 * FUNCTION:
 * DrawMainWindow draws the main. This procedure is designed to be called
 * in response to a WM_PAINT message.
 *
 * PRECONDITIONS: 
 * BeginPaint or GetDC should be called before to get the device contect handle
 * for the window.
 *
 * POSTCONDITIONS: 
 * In a WM_PAINT message EndPaint should be called. Otherwise the device context
 * handle should be released by calling ReleaseDC.
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           handle of the window which should be drawn
 * hdc            handle of the device context of the window passed by hWnd
 ******************************************************************************)
PROCEDURE DrawMainWindow(hWnd: W.HWND; hdc: W.HDC);

  CONST
    text = "Hint: Try the left mouse button!";

  VAR 
    r:   LONGINT;
    wnd: W.RECT;
    
BEGIN

  (* -- get size of client area -- *)
  W.GetClientRect(hWnd, SYSTEM.ADR(wnd));
  r := W.DrawText(hdc, SYSTEM.ADR(text), W.lstrlen(SYSTEM.ADR(text)), SYSTEM.ADR(wnd), W.DT_CENTER + W.DT_VCENTER + W.DT_SINGLELINE);
  
END DrawMainWindow;



PROCEDURE DrawMousePosition(hWnd: W.HWND; hdc: W.HDC; x1: INTEGER; y1: INTEGER; x2: INTEGER; y2: INTEGER);
  VAR r:    LONGINT;
BEGIN
  r := W.SetROP2(hdc, W.R2_NOT);
  r := W.MoveTo(hdc, x1, y1);
  r := W.LineTo(hdc, x2, y1);
  r := W.LineTo(hdc, x2, y2);
  r := W.LineTo(hdc, x1, y2);
  r := W.LineTo(hdc, x1, y1);
END DrawMousePosition;


(******************************************************************************
 * WndProc is the so called "callback function" for the window displayed by
 * this application. WndProc is called by Windows every time Windows wants 
 * to send a message to the window. 
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle
 * message        message for the window
 * wParam         first parameter for the message
 * lParam         second parameter for the message
 ******************************************************************************)
PROCEDURE [WINDOWS] WndProc*(hWnd:    W.HWND; 
                             message: W.WORD; 
                             wParam:  W.WORD; 
                             lParam:  LONGINT): LONGINT;
  VAR
    box: W.RECT;
    hdc: W.HDC;
    ps:  W.PAINTSTRUCT;
    r:   LONGINT;
    
BEGIN

  IF message = W.WM_DESTROY THEN
    W.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = W.WM_PAINT THEN
    hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
    DrawMainWindow(hWnd, hdc);
    W.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;

  ELSIF message = W.WM_SIZE THEN
    W.InvalidateRect(hWnd, W.NULL, W.true);
    RETURN 0;

  ELSIF message = W.WM_LBUTTONDOWN THEN
    hdc := W.GetDC(hWnd);
    selection := TRUE;
    orgX := Utils.LoWord(lParam);
    orgY := Utils.HiWord(lParam);
    prevX := orgX;
    prevY := orgY;
    DrawMousePosition(hWnd, hdc, orgX, orgY, prevX, prevY);
    r := W.SetCapture(hWnd);
    r := W.ReleaseDC(hWnd, hdc);
    RETURN 0;

  ELSIF message = W.WM_MOUSEMOVE THEN
    IF selection THEN
      hdc := W.GetDC(hWnd);
      DrawMousePosition(hWnd, hdc, orgX, orgY, prevX, prevY);
      prevX := Utils.LoWord(lParam);
      prevY := Utils.HiWord(lParam);
      DrawMousePosition(hWnd, hdc, orgX, orgY, prevX, prevY);
      r := W.ReleaseDC(hWnd, hdc);
    END;
    RETURN 0;

  ELSIF message = W.WM_LBUTTONUP THEN
    selection := FALSE;
    W.ReleaseCapture();
    hdc := W.GetDC(hWnd);
    DrawMousePosition(hWnd, hdc, orgX, orgY, prevX, prevY);
    box.left := orgX;
    box.top  := orgY;
    box.right := prevX;
    box.bottom := prevY;
    W.InvertRect(hdc, SYSTEM.ADR(box));
    r := W.ReleaseDC(hWnd, hdc);
    RETURN 0;

  ELSE
    RETURN W.DefWindowProc(hWnd, message, wParam, lParam)

  END;
  RETURN 0;

END WndProc;


(******************************************************************************
 * InitApplication registers all window classes.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 ******************************************************************************)
PROCEDURE InitApplication(hInstCurr: W.HINSTANCE): BOOLEAN;
  VAR wc: W.WNDCLASS;
BEGIN
  (* -- register application specific classes -- *)
  wc.style         := W.NULL;
  wc.lpfnWndProc   := WndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);
  RETURN W.RegisterClass(SYSTEM.ADR(wc)) # 0;
END InitApplication;


(******************************************************************************
 *
 * FUNCTION:
 * InitInstance performs the initialisation for the current instance of this
 * program. It creates the main window.
 *
 * PRECONDITIONS:
 * The window class used by this program should be registered. (InitApplication)
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 * nCmdShow       ??
 ******************************************************************************)
PROCEDURE InitInstance(hInstCurr: W.HINSTANCE; nCmdShow: INTEGER): BOOLEAN;

  VAR
    hWnd:  W.HWND;
    r:     LONGINT;

BEGIN

  (* -- create main window -- *)
  hWnd := W.CreateWindow(
          SYSTEM.ADR(ClassName), SYSTEM.ADR(WindowName), 
          W.WS_OVERLAPPEDWINDOW, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.NULL, W.NULL, 
          hInstCurr, W.NULL);
  IF hWnd = 0 THEN RETURN FALSE END;
  r := W.ShowWindow(hWnd, nCmdShow);
  RETURN TRUE;

END InitInstance;


(******************************************************************************
 * WinMain is the "main program". It is automartically called by Windows when
 * the user starts this application. It displays a simple window with the 
 * standard features of windows like moving, sizing and system menu.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for the current instance of this application
 * hInstPrev      instance handle for the previously loaded instance
 * lpCmdLine      command line (far pointer to a null terminated string)
 * nCmdShow       This parameter says how the main window should be displayed.
 ******************************************************************************)
PROCEDURE [WINDOWS] WinMain*(hInstCurr: W.HINSTANCE; 
                             hInstPrev: W.HINSTANCE;
                             lpCmdLine: W.LPSTR;
                             nCmdShow:  INTEGER): INTEGER;
  VAR
    msg: W.MSG;
    r:   LONGINT;
    
BEGIN

  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    DspErrMsg("Global initialization did't work!");
    RETURN W.false;
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    DspErrMsg("Local initialization did't work!");
    RETURN W.false;
  END; 
  
  (* -- standard message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    r := W.TranslateMessage(SYSTEM.ADR(msg)); 
    r := W.DispatchMessage(SYSTEM.ADR(msg));
  END;
  RETURN msg.wParam
  
END WinMain;


END MS.
