(******************************************************************************
 * MODULE:        MDI
 * DESCRIPTION:   A small example for MDI windows
 * LANGUAGE:      Oberon-2
 * AUTHOR(S):     Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 96/05/06  PDI     Version 1.0
 * 97/03/11  PDI     minor changes for windows callback functions
 ******************************************************************************)
MODULE MDI;


  IMPORT SYSTEM, W := Windows;


  CONST

    WindowTitle   = "Multiple Document Interface (MDI) Demo";
    MDIFrameClass = "CFrame";
    MDIChildClass = "CClient";

    IDM_NEW     = 101;
    IDM_EXIT    = 102;
    IDM_CASCADE = 201;
    IDM_TILE_H  = 202;
    IDM_TILE_V  = 203;
    IDM_ABOUT   = 301;


  VAR
    hInst:      W.HANDLE;  (* application's instance handle  *)
    hWnd:       W.HWND;    (* handle of main window          *)
    hWndChild:  W.HWND;
    hWndClient: W.HWND;


(******************************************************************************
 * DisplayError pops up a message box showing an ErrorMsg message.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * msg            ErrorMsg message
 ******************************************************************************)
PROCEDURE DisplayError*(msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := W.MessageBox(W.NULL, SYSTEM.ADR(msg), SYSTEM.ADR("Error"), W.MB_OK);
END DisplayError;


(******************************************************************************
 * creates a child window
 ******************************************************************************)
PROCEDURE CreateChildWindow(title: ARRAY OF CHAR; hInstCurr: W.HINSTANCE; hWndClient: W.HWND): W.HWND;
  VAR
    hWnd: W.HWND;
    mcs:  W.MDICREATESTRUCT;
    r:    LONGINT;
BEGIN
  (* -- create child window -- *)
  mcs.szClass := SYSTEM.ADR(MDIChildClass);
  mcs.szTitle := SYSTEM.ADR(title);
  mcs.hOwner  := hInstCurr;
  mcs.x       := W.CW_USEDEFAULT;
  mcs.y       := W.CW_USEDEFAULT;
  mcs.cx      := W.CW_USEDEFAULT;
  mcs.cy      := W.CW_USEDEFAULT;
  mcs.style   := W.MDIS_ALLCHILDSTYLES;
  mcs.lParam  := 0;
  hWnd := SHORT(W.SendMessage(hWndClient, W.WM_MDICREATE, 0, SYSTEM.ADR(mcs)));
  IF hWnd = 0 THEN
    DisplayError("Couldn't create child window!");
    RETURN 0;
  END;
  r := W.ShowWindow(hWnd, W.SW_SHOW);
  RETURN hWnd;
END CreateChildWindow;


(******************************************************************************
 * looks for a menu with the text "menu" and returns the position of this menu.
 ******************************************************************************)
PROCEDURE GetWindowPos(hMenu: W.HMENU; menu: ARRAY OF CHAR): INTEGER;
VAR
  i:  INTEGER;
  mt: ARRAY 20 OF CHAR;
  r:  LONGINT;
BEGIN
  i := 0; 
  r := W.GetMenuString(hMenu, i, SYSTEM.ADR(mt), LEN(mt), W.MF_BYPOSITION);
  WHILE (i < W.GetMenuItemCount(hMenu)) & (mt # menu) DO
    INC(i); 
    r := W.GetMenuString(hMenu, i, SYSTEM.ADR(mt), LEN(mt), W.MF_BYPOSITION);
  END;
  RETURN i;
END GetWindowPos;


(******************************************************************************
 * Window procedure for frame windows
 ******************************************************************************)
PROCEDURE [WINDOWS] MDIFrameWndProc*(hWnd: W.HWND; message: W.WORD; wParam: W.WORD; lParam: LONGINT): LONGINT;

  VAR
    ccs:   W.CLIENTCREATESTRUCT;
    hdc:   W.HDC;
    hMenu: W.HMENU;
    ps:    W.PAINTSTRUCT;
    r:     LONGINT;
    rf:    W.RECT;                  (* rectange of client area of frame window *)
    
BEGIN

  IF message = W.WM_CREATE THEN
    (* -- create client window -- *)
    hMenu := W.GetMenu(hWnd);
    ccs.hWindowMenu  := W.GetSubMenu(hMenu, GetWindowPos(hMenu, "&Window"));
    ccs.idFirstChild := 30000;
    W.GetClientRect(hWnd, SYSTEM.ADR(rf));
    hWndClient := W.CreateWindow(
                  SYSTEM.ADR("MDICLIENT"), W.NULL, 
                  W.WS_CLIPCHILDREN + W.WS_CHILD, 
                  rf.left, rf.top, rf.right, rf.bottom,
                  hWnd, W.NULL, hInst, SYSTEM.ADR(ccs));
    IF hWndClient = 0 THEN RETURN 1 END;
    r := W.ShowWindow(hWndClient, W.SW_SHOW);
    
  ELSIF message = W.WM_DESTROY THEN
    W.PostQuitMessage(0);

  ELSIF message = W.WM_COMMAND THEN
    IF wParam = IDM_NEW THEN
      hWndChild := CreateChildWindow("New", hInst, hWndClient);
    ELSIF wParam = IDM_EXIT THEN
      r := W.DestroyWindow(hWnd);
    ELSIF wParam = IDM_TILE_H THEN
      r := W.SendMessage(hWndClient, W.WM_MDITILE, W.MDITILE_HORIZONTAL, 0);
    ELSIF wParam = IDM_TILE_V THEN
      r := W.SendMessage(hWndClient, W.WM_MDITILE, W.MDITILE_VERTICAL, 0);
    ELSIF wParam = IDM_CASCADE THEN
      r := W.SendMessage(hWndClient, W.WM_MDICASCADE, 0, 0);
    ELSE
      RETURN W.DefFrameProc(hWnd, hWndClient, message, wParam, lParam)
    END;

  ELSE
    RETURN W.DefFrameProc(hWnd, hWndClient, message, wParam, lParam)

  END;

  RETURN 0

END MDIFrameWndProc;


(******************************************************************************
 * Window procedure for child windows
 ******************************************************************************)
PROCEDURE [WINDOWS] MDIChildWndProc*(hWnd: W.HWND; message: W.WORD; wParam: W.WORD; lParam: LONGINT): LONGINT;
  VAR
    hdc:    W.HDC;
    ps:     W.PAINTSTRUCT;
    r:      INTEGER;
BEGIN
  IF message = W.WM_PAINT THEN
    hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
    r := W.TextOut(hdc, 10, 10, SYSTEM.ADR("Hello world."), 12);
    W.EndPaint(hWnd, SYSTEM.ADR(ps));
  ELSE
    RETURN W.DefMDIChildProc(hWnd, message, wParam, lParam)
  END;
  RETURN 0
END MDIChildWndProc;


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

  (* -- register MDI frame window class -- *)
  wc.style         := W.NULL;
  wc.lpfnWndProc   := MDIFrameWndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := SYSTEM.ADR("MainMenu");
  wc.lpszClassName := SYSTEM.ADR(MDIFrameClass);
  IF W.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    DisplayError("Couldn't create frame window class!");
    RETURN FALSE
  END;

  (* -- register MDI child window class -- *)
  wc.style         := W.NULL;
  wc.lpfnWndProc   := MDIChildWndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.LoadIcon(W.NULL, W.IDI_HAND);
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(MDIChildClass);
  IF W.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    DisplayError("Couldn't create child window class!");
    RETURN FALSE
  END;

  RETURN TRUE

END InitApplication;



(******************************************************************************
 *
 * FUNCTION:
 * InitInstance performs the initialisation for the current instance of this
 * program.
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
    r: LONGINT;

BEGIN

  (* -- create frame window -- *)
  hWnd := W.CreateWindow(
          SYSTEM.ADR(MDIFrameClass), SYSTEM.ADR(WindowTitle), 
          W.WS_OVERLAPPEDWINDOW, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.NULL, W.NULL, 
          hInstCurr, W.NULL);
  IF hWnd = 0 THEN
    DisplayError("Couldn't create main window!");
    RETURN FALSE
  END;
  r := W.ShowWindow(hWnd, nCmdShow);

  (* -- create first child window --*)
  hWndChild := CreateChildWindow("Window #1", hInstCurr, hWndClient);
  hWndChild := CreateChildWindow("Window #2", hInstCurr, hWndClient);

  RETURN TRUE;

END InitInstance;



(******************************************************************************
 * "Main program"
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
                             nCmdShow:  INTEGER):  INTEGER;
  VAR
    msg:   W.MSG;
    r:     LONGINT;
    
BEGIN

  (* -- save instance handle for further use -- *)
  hInst := hInstCurr;

  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    DisplayError("Global initialization didn't work!");
    RETURN W.false;
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    DisplayError("Local initialization didn't work!");
    RETURN W.false;
  END; 
  
  (* -- message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    IF W.TranslateMDISysAccel(hWndClient, SYSTEM.ADR(msg)) = 0 THEN
      r := W.TranslateMessage(SYSTEM.ADR(msg)); 
      r := W.DispatchMessage(SYSTEM.ADR(msg));
    END;
  END;
  RETURN msg.wParam
  
END WinMain;


END MDI.
