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

loadfrom ("api", "comapi", NULL, &on_eval_err);

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

loadfrom ("com/" + com, "comInit", NULL, &on_eval_err);
