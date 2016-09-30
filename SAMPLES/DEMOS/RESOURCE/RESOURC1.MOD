(******************************************************************************
 * MODULE:        Resource
 * DESCRIPTION:   shows some resources
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 96/04/25  PDI     Version 1
 * 97/03/11  PDI     Minor changes for windows callback functions
 ******************************************************************************)
MODULE Resourc1;


IMPORT Error, W := Windows, SYSTEM;


CONST ClassName   = "CResourceTest";
      WindowTitle = "Resource Demo 1 (About Dialog)";
      IDM_EXIT  = 101;
      IDM_ABOUT = 102;

VAR hInst: W.HINSTANCE;
    

(******************************************************************************
 * Opens a modal dialog box.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * name           name of the dialog in the ressource file
 * dp             dialog procedure which handles all messages to the dialog
 * hWndParent     handle of the parent window
 * hInst          instance handle of the actual task
 ******************************************************************************)
PROCEDURE ShowModalDialog(name: ARRAY OF CHAR; dp: W.DLGPROC; hWndParent: W.HWND; hInst: W.HINSTANCE);
VAR r: LONGINT;
BEGIN
  r := W.DialogBox(hInst,             (* current instance                 *)
                   SYSTEM.ADR(name),  (* resource to use                  *)
                   hWndParent,        (* parent handle                    *)
                   dp);               (* About() instance address         *)
END ShowModalDialog;



(******************************************************************************)
(* FUNCTION: About(HWND, unsigned, WORD, LONG)                                *)
(*                                                                            *)
(* PURPOSE:  Processes messages for "About" dialog box                        *)
(*                                                                            *)
(* MESSAGES:                                                                  *)
(*   W.WM_INITDIALOG - initialize dialog box                                  *)
(*   W.WM_COMMAND    - Input received                                         *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*   No initialization is needed for this particular dialog box, but TRUE     *)
(*   must be returned to Windows.                                             *)
(*                                                                            *)
(*   Wait for user to click on "Ok" button, then close the dialog box.        *)
(******************************************************************************)
PROCEDURE [WINDOWS] About*(hDlg: W.HWND; message: W.WORD; wParam: W.WPARAM; lParam: W.LPARAM): W.BOOL;
BEGIN
  IF message = W.WM_INITDIALOG THEN       (* message: initialize dialog box   *)
    RETURN W.true
  ELSIF message = W.WM_COMMAND THEN       (* message: received a command      *)
    IF (wParam = W.IDOK) OR (wParam = W.IDCANCEL) THEN
      W.EndDialog(hDlg, W.true)           (* Exits the dialog box             *)
    END;
    RETURN W.true
  END;
  RETURN W.false                          (* Didn't process a message         *)
END About;

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
                             wParam:  W.WPARAM; 
                             lParam:  W.LPARAM): LONGINT;

  VAR
    hdc: W.HDC;
    ps:  W.PAINTSTRUCT;
    r:   INTEGER;
    
BEGIN

  IF message = W.WM_DESTROY THEN
    W.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = W.WM_COMMAND THEN
    IF wParam = IDM_EXIT THEN
      r := W.DestroyWindow(hWnd);
    ELSIF wParam = IDM_ABOUT THEN
      ShowModalDialog("About", About, hWnd, hInst);
    ELSE
      RETURN W.DefWindowProc(hWnd, message, wParam, lParam)
    END;

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
  wc.hIcon         := W.LoadIcon(hInstCurr, SYSTEM.ADR("Icon"));
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := SYSTEM.ADR("MainMenu");
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
    hWnd: W.HWND;
    r:    LONGINT;

BEGIN

  (* -- create main window -- *)
  hWnd := W.CreateWindow(
          SYSTEM.ADR(ClassName), SYSTEM.ADR(WindowTitle), 
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
                             nCmdShow:  INTEGER):          INTEGER;
  VAR
    msg: W.MSG;
    r:   LONGINT;
    
BEGIN

  hInst := hInstCurr;
  
  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    Error.DspMsg("Global Initialization didn't work!");
    RETURN W.false;
  END;

  (* -- initialize current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    Error.DspMsg("Local Initialization didn't work!");
    RETURN W.false;
  END; 
  
  (* -- standard message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    r := W.TranslateMessage(SYSTEM.ADR(msg)); 
    r := W.DispatchMessage(SYSTEM.ADR(msg));
  END;
  
  RETURN msg.wParam
  
END WinMain;


END Resourc1.
