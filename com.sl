variable com = substr (path_basename_sans_extname (__argv[0]), 2, -1);
variable openstdout = 0;
define initproc (p) {}

loadfrom ("input", "inputInit", NULL, &on_eval_err);
loadfrom ("smg", "gettermsize", NULL, &on_eval_err);
loadfrom ("parse", "cmdopt", NULL, &on_eval_err);
loadfrom ("print", "null_tostdout", NULL, &on_eval_err);

variable LINES, COLUMNS;
(LINES, COLUMNS) = gettermsize ();

variable COMDIR;

define exit_me (x)
{
  input->at_exit ();
  exit (x);
}

define send_msg_dr (msg)
{
  tostdout (msg + "\n");
}

define sigint_handler (sig)
{
  input->at_exit ();
  tostderr ("\b\bprocess interrupted by the user");
  exit_me (130);
}

signal (SIGINT, &sigint_handler);

define verboseon ()
{
  loadfrom ("print", "tostdout", NULL, &on_eval_err);
}

define verboseoff ()
{
  loadfrom ("print", "null_tostdout", NULL, &on_eval_err);
}

define close_smg ();
define restore_smg ();

define ask (questar, ar)
{
  array_map (&tostderr, questar);
  variable len = COLUMNS - strlen (questar[-1]) - 1;
  loop (len)
    () = fprintf (stderr, "\b");

  variable chr;
 
  while (chr = getch (), 0 == any (ar == chr));
  
  () = fprintf (stderr, "\n");
 
  return chr;
}

define _usage ()
{
  verboseon ();
  variable
    if_opt_err = _NARGS ? () : " ",
    helpfile = qualifier ("helpfile", sprintf ("%s/help.txt", COMDIR)),
    ar = _NARGS ? [if_opt_err] : String_Type[0];

  if (NULL == helpfile)
    {
    tostderr ("No Help file available for " + com);

    ifnot (length (ar))
      exit (1);
    }

  ifnot (access (helpfile, F_OK))
    ar = [ar, readfile (helpfile)];

  ifnot (length (ar))
    {
    tostdout ("No Help file available for " + com);
    exit (1);
    }

  array_map (&tostdout, ar);

  exit (_NARGS);
}

define info ()
{
  verboseon ();
  variable
    info_ref = NULL,
    infofile = qualifier ("infofile", sprintf ("%s/desc.txt", COMDIR)),
    ar;

  if (NULL == infofile || -1 == access (infofile, F_OK))
    {
    tostdout ("No Info file available for " + com);
 
    exit (0);
    }

  ar = readfile (infofile);
  array_map (&tostdout, ar);
 
  exit (0);
}

loadfrom ("com/" + com, "comInit", NULL, &on_eval_err);
