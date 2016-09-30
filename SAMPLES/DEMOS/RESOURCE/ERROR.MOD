(******************************************************************************
 * MODULE:        Error
 * DESCRIPTION:   error processing
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 97/03/11  PDI     Version 1
 ******************************************************************************)
MODULE Error;

  IMPORT SYSTEM, W := Windows;

(******************************************************************************
 * DspMsg opens a message box and displays an error message in it.
 * It waits until the user has clicked on the Ok-button.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * msg            error message which should be displayed in the message box
 ******************************************************************************)
PROCEDURE DspMsg*(msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := W.MessageBox(W.NULL, SYSTEM.ADR(msg), SYSTEM.ADR("Error"), W.MB_OK);
END DspMsg;


END Error.
