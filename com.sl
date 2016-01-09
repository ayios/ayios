variable com = substr (path_basename_sans_extname (__argv[0]), 2, -1);
variable openstdout = 0;
define initproc (p) {}

define verboseon ()
{
  IO->Fun ("tostdout?", NULL);
}

define verboseoff ()
{
  IO->Fun ("tostdout?", NULL;FuncFname = "null_tostdout");
}

load.from ("input", "inputInit", NULL;err_handler = &__err_handler__);
load.from ("smg", "gettermsize", NULL;err_handler = &__err_handler__);
load.from ("parse", "cmdopt", NULL;err_handler = &__err_handler__);

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
  IO.tostdout (msg);
}

define sigint_handler (sig)
{
  input->at_exit ();
  IO.tostderr ("\b\bprocess interrupted by the user");
  exit_me (130);
}

signal (SIGINT, &sigint_handler);

verboseoff ();

load.from ("api", "comapi", NULL;err_handler = &__err_handler__);

define close_smg ();
define restore_smg ();

define ask (questar, ar)
{
  IO.tostderr (questar);
  variable len = COLUMNS - strlen (questar[-1]) - 1;
  loop (len)
    () = fprintf (stderr, "\b");

  variable chr;

  while (chr = getch (), 0 == any (ar == chr));

  input->at_exit ();

  () = fprintf (stderr, "\n");

  chr;
}

load.from ("com/" + com, "comInit", NULL;err_handler = &__err_handler__);
