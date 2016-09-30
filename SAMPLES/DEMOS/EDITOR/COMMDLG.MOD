(******************************************************************************
 * MODULE:      COMMDLG
 * DESCRIPTION: Interface for common dialog functions
 * LANGUAGE:    Oberon-2
 * COMPILER:    Robinson Associates Oberon-2 V1.14
 * AUTHOR(S):   Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 *              Ulrich Kreuzeder, kreuzeder@fim.uni-linz.ac.at (KRE)
 *              Bernhard Leisch, leisch@fim.uni-linz.ac.at
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 95/??/??  LEI     Version 1.0
 ******************************************************************************)
DEFINITION CommDlg;

  IMPORT Windows;

  CONST

    (* -- GetOpenFileName, GetSaveFileName -- *)
    OFN_READONLY             = 00000001H;
    OFN_OVERWRITEPROMPT      = 00000002H;
    OFN_HIDEREADONLY         = 00000004H;
    OFN_NOCHANGEDIR          = 00000008H;
    OFN_SHOWHELP             = 00000010H;
    OFN_ENABLEHOOK           = 00000020H;
    OFN_ENABLETEMPLATE       = 00000040H;
    OFN_ENABLETEMPLATEHANDLE = 00000080H;
    OFN_NOVALIDATE           = 00000100H;
    OFN_ALLOWMULTISELECT     = 00000200H;
    OFN_EXTENSIONDIFFERENT   = 00000400H;
    OFN_PATHMUSTEXIST        = 00000800H;
    OFN_FILEMUSTEXIST        = 00001000H;
    OFN_CREATEPROMPT         = 00002000H;
    OFN_SHAREAWARE           = 00004000H;
    OFN_NOREADONLYRETURN     = 00008000H;
    OFN_NOTESTFILECREATE     = 00010000H;

    (* -- return values sent to the hook function -- *)
    OFN_SHAREFALLTHROUGH = 2;
    OFN_SHARENOWARN      = 1;
    OFN_SHAREWARN        = 0;

    (* -- ChooseColor -- *)
    CC_RGBINIT              = 000000001H;
    CC_FULLOPEN             = 000000002H;
    CC_PREVENTFULLOPEN      = 000000004H;
    CC_SHOWHELP             = 000000008H;
    CC_ENABLEHOOK           = 000000010H;
    CC_ENABLETEMPLATE       = 000000020H;
    CC_ENABLETEMPLATEHANDLE = 000000040H;

    (* -- find/replace -- *)
    FR_DOWN                 = 000000001H;
    FR_WHOLEWORD            = 000000002H;
    FR_MATCHCASE            = 000000004H;
    FR_FINDNEXT             = 000000008H;
    FR_REPLACE              = 000000010H;
    FR_REPLACEALL           = 000000020H;
    FR_DIALOGTERM           = 000000040H;
    FR_SHOWHELP             = 000000080H;
    FR_ENABLEHOOK           = 000000100H;
    FR_ENABLETEMPLATE       = 000000200H;
    FR_NOUPDOWN             = 000000400H;
    FR_NOMATCHCASE          = 000000800H;
    FR_NOWHOLEWORD          = 000001000H;
    FR_ENABLETEMPLATEHANDLE = 000002000H;
    FR_HIDEUPDOWN           = 000004000H;
    FR_HIDEMATCHCASE        = 000008000H;
    FR_HIDEWHOLEWORD        = 000010000H;

    (* -- ChooseFont -- *)
    CF_SCREENFONTS          = 000000001H;
    CF_PRINTERFONTS         = 000000002H;
    CF_BOTH                 = (CF_SCREENFONTS + CF_PRINTERFONTS);
    CF_SHOWHELP             = 000000004H;
    CF_ENABLEHOOK           = 000000008H;
    CF_ENABLETEMPLATE       = 000000010H;
    CF_ENABLETEMPLATEHANDLE = 000000020H;
    CF_INITTOLOGFONTSTRUCT  = 000000040H;
    CF_USESTYLE             = 000000080H;
    CF_EFFECTS              = 000000100H;
    CF_APPLY                = 000000200H;
    CF_ANSIONLY             = 000000400H;
    CF_NOVECTORFONTS        = 000000800H;
    CF_NOOEMFONTS           = CF_NOVECTORFONTS;
    CF_NOSIMULATIONS        = 000001000H;
    CF_LIMITSIZE            = 000002000H;
    CF_FIXEDPITCHONLY       = 000004000H;
    CF_WYSIWYG              = 000008000H; (* must also have CF_SCREENFONTS & CF_PRINTERFONTS *)
    CF_FORCEFONTEXIST       = 000010000H;
    CF_SCALABLEONLY         = 000020000H;
    CF_TTONLY               = 000040000H;
    CF_NOFACESEL            = 000080000H;
    CF_NOSTYLESEL           = 000100000H;
    CF_NOSIZESEL            = 000200000H;

    (* -- extra nFontType bits that are added to what is returned to the EnumFonts callback routine -- *)
    SIMULATED_FONTTYPE      = 08000H;
    PRINTER_FONTTYPE        = 04000H;
    SCREEN_FONTTYPE         = 02000H;
    BOLD_FONTTYPE           = 00100H;
    ITALIC_FONTTYPE         = 00200H;
    REGULAR_FONTTYPE        = 00400H;

    WM_CHOOSEFONT_GETLOGFONT = (Windows.WM_USER + 1);

    (* -- strings used to obtain unique window message for communication between dialog and caller *)
    LBSELCHSTRING  = "commdlg_LBSelChangedNotify";
    SHAREVISTRING  = "commdlg_ShareViolation";
    FILEOKSTRING   = "commdlg_FileNameOK";
    COLOROKSTRING  = "commdlg_ColorOK";
    SETRGBSTRING   = "commdlg_SetRGBColor";
    FINDMSGSTRING  = "commdlg_FindReplace";
    HELPMSGSTRING  = "commdlg_help";

    (* HIWORD values for lParam of commdlg_LBSelChangeNotify message *)
    CD_LBSELNOITEMS = -1;
    CD_LBSELCHANGE  = 0;
    CD_LBSELSUB     = 1;
    CD_LBSELADD     = 2;

    (* -- print dialog -- *)
    PD_ALLPAGES                  = 000000000H;
    PD_SELECTION                 = 000000001H;
    PD_PAGENUMS                  = 000000002H;
    PD_NOSELECTION               = 000000004H;
    PD_NOPAGENUMS                = 000000008H;
    PD_COLLATE                   = 000000010H;
    PD_PRINTTOFILE               = 000000020H;
    PD_PRINTSETUP                = 000000040H;
    PD_NOWARNING                 = 000000080H;
    PD_RETURNDC                  = 000000100H;
    PD_RETURNIC                  = 000000200H;
    PD_RETURNDEFAULT             = 000000400H;
    PD_SHOWHELP                  = 000000800H;
    PD_ENABLEPRINTHOOK           = 000001000H;
    PD_ENABLESETUPHOOK           = 000002000H;
    PD_ENABLEPRINTTEMPLATE       = 000004000H;
    PD_ENABLESETUPTEMPLATE       = 000008000H;
    PD_ENABLEPRINTTEMPLATEHANDLE = 000010000H;
    PD_ENABLESETUPTEMPLATEHANDLE = 000020000H;
    PD_USEDEVMODECOPIES          = 000040000H;
    PD_DISABLEPRINTTOFILE        = 000080000H;
    PD_HIDEPRINTTOFILE           = 000100000H;

    DN_DEFAULTPRN = 1;


  TYPE

    (* -- basic data types -- *)
    DWORD  = LONGINT;
    UINT   = INTEGER;
    LPSTR  = LONGINT;
    LPCSTR = LPSTR;
    LPARAM = LONGINT;
    WPARAM = INTEGER;

    (* -- hook procedure type for common dialogs -- *)
    HOOK = PROCEDURE [WINDOWS] (hWnd: Windows.HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT;

    (* -- GetOpenFileName, GetSaveFileName -- *)
    OPENFILENAME = RECORD [WINDOWS]
      lStructSize:       LONGINT;
      hwndOwner:         Windows.HWND;
      hInstance:         Windows.HINSTANCE;
      lpstrFilter:       LPCSTR;
      lpstrCustomFilter: LPSTR;
      nMaxCustFilter:    LONGINT;
      nFilterIndex:      LONGINT;
      lpstrFile:         LPSTR;
      nMaxFile:          LONGINT;
      lpstrFileTitle:    LPSTR;
      nMaxFileTitle:     LONGINT;
      lpstrInitialDir:   LPCSTR;
      lpstrTitle:        LPCSTR;
      Flags:             DWORD;
      nFileOffset:       UINT;
      nFileExtension:    UINT;
      lpstrDefExt:       LPCSTR;
      lCustData:         LPARAM;
      lpfnHook:          HOOK;
      lpTemplateName:    LPCSTR;
    END;
    LPOPENFILENAME = LONGINT; (* POINTER TO OPENFILENAME *)

    CHOOSECOLOR = RECORD [WINDOWS]
      lStructSize:    DWORD;
      hwndOwner:      Windows.HWND;
      hInstance:      Windows.HWND;
      rgbResult:      Windows.COLORREF;
      lpCustColors:   LONGINT; (* POINTER TO Windows.COLORREF *)
      Flags:          DWORD;
      lCustData:      LPARAM;
      lpfnHook:       HOOK;
      lpTemplateName: LPCSTR
    END;
    LPCHOOSECOLOR = LONGINT; (* POINTER TO CHOOSECOLOR *)

    FINDREPLACE = RECORD [WINDOWS]
      lStructSize:      DWORD;                  (* size of this struct 0x20 *)
      hwndOwner:        Windows.HWND;           (* handle to owner's window *)
      hInstance:        Windows.HINSTANCE;      (* instance handle of.EXE
                                                   that contains cust. dlg.
                                                   template                 *)
      Flags:            DWORD;                  (* one or more of the FR_?? *)
      lpstrFindWhat:    LPSTR;                  (* ptr. to search string    *)
      lpstrReplaceWith: LPSTR;                  (* ptr. to replace string   *)
      wFindWhatLen:     UINT;                   (* size of find buffer      *)
      wReplaceWithLen:  UINT;                   (* size of replace buffer   *)
      lCustData:        LPARAM;                 (* data passed to hook fn.  *)
      lpfnHook:         HOOK;                   (* ptr. to hook fn. or NULL *)
      lpTemplateName:   LPCSTR;                 (* custom template name     *)
    END;
    LPFINDREPLACE = LONGINT; (* POINTER TO FINDREPLACE *)

    LPLOGFONT = POINTER TO Windows.LOGFONT;
    CHOOSEFONT = RECORD [WINDOWS]
      lStructSize:    DWORD;                    (* *)
      hwndOwner:      Windows.HWND;             (* caller's window handle   *)
      hDC:            Windows.HDC;              (* printer DC/IC or NULL    *)
      lpLogFont:      LPLOGFONT;                (* ptr. to a LOGFONT struct *)
      iPointSize:     INTEGER;                  (* 10 * size in points of   *
                                                 * selected font            *)
      Flags:          DWORD;                    (* enum. type flags         *)
      rgbColors:      Windows.COLORREF;         (* returned text color      *)
      lCustData:      LPARAM;                   (* data passed to hook fn.  *)
      lpfnHook:       HOOK;                     (* ptr. to hook function    *)
      lpTemplateName: LPCSTR;                   (* custom template name     *)
      hInstance:      Windows.HINSTANCE;        (* instance handle of.EXE   *
                                                 * that contains cust. dlg. *
                                                 * template                 *)
      lpszStyle:      LPSTR;                    (* return the style field   *
                                                 * here must be LF_FACESIZE *
                                                 * or bigger                *)
      nFontType:      UINT;                     (* same value reported to   *
                                                 * the EnumFonts call back  *
                                                 * with the extra           *
                                                 * FONTTYPE_bits added      *)
      nSizeMin:       INTEGER;                  (* minimum pt size allowed &*)
      nSizeMax:       INTEGER;                  (* max pt size allowed if   *)
                                                (* CF_LIMITSIZE is used     *)
    END;
    LPCHOOSEFONT = LONGINT; (* POINTER TO CHOOSEFONT *)

    PRINTDLG = RECORD [WINDOWS]
      lStructSize:         DWORD;
      hwndOwner:           Windows.HWND;
      hDevMode:            Windows.HGLOBAL;
      hDevNames:           Windows.HGLOBAL;
      hDC:                 Windows.HDC;
      Flags:               DWORD;
      nFromPage:           UINT;
      nToPage:             UINT;
      nMinPage:            UINT;
      nMaxPage:            UINT;
      nCopies:             UINT;
      hInstance:           Windows.HINSTANCE;
      lCustData:           Windows.LPARAM;
      lpfnPrintHook:       HOOK;
      lpfnSetupHook:       HOOK;
      lpPrintTemplateName: LPCSTR;
      lpSetupTemplateName: LPCSTR;
      hPrintTemplate:      Windows.HGLOBAL;
      hSetupTemplate:      Windows.HGLOBAL;
    END;
    LPPRINTDLG = LONGINT; (* POINTER TO PRINTDLG *)

    DEVNAMES = RECORD [WINDOWS]
      wDriverOffset: UINT;
      wDeviceOffset: UINT;
      wOutputOffset: UINT;
      wDefault:      UINT;
    END;
    LPDEVNAMES = LONGINT; (* POINTER TO DEVNAMES *)


PROCEDURE [WINDOWS] PrintDlg (lppd: LPPRINTDLG): Windows.BOOL;

PROCEDURE [WINDOWS] GetOpenFileName (lpofn: LPOPENFILENAME): Windows.BOOL;
PROCEDURE [WINDOWS] GetSaveFileName (lpofn: LPOPENFILENAME): Windows.BOOL;
PROCEDURE [WINDOWS] GetFileTitle    (lpszFile: LPCSTR; lpszTitle: LPSTR; cbBuf: UINT): INTEGER;

PROCEDURE [WINDOWS] ChooseColor (lpcc: LPCHOOSECOLOR);

PROCEDURE [WINDOWS] FindText    (lpfr: LPFINDREPLACE): Windows.HWND;
PROCEDURE [WINDOWS] ReplaceText (lpfr: LPFINDREPLACE): Windows.HWND;

PROCEDURE [WINDOWS] ChooseFont (lpcf: LPCHOOSEFONT): Windows.BOOL;

PROCEDURE [WINDOWS] CommDlgExtendedError (): DWORD;

END CommDlg.
