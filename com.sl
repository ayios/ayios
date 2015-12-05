variable com = substr (path_basename_sans_extname (__argv[0]), 2, -1);
variable openstdout = 0;
define initproc (p) {}

load.from ("input", "inputInit", NULL;err_handler = &__err_handler__);
load.from ("smg", "gettermsize", NULL;err_handler = &__err_handler__);
load.from ("parse", "cmdopt", NULL;err_handler = &__err_handler__);
load.from ("print", "null_tostdout", NULL;err_handler = &__err_handler__);

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
  __IO__.tostdout (msg);
}

define sigint_handler (sig)
{
  input->at_exit ();
  __IO__.tostderr ("\b\bprocess interrupted by the user");
  exit_me (130);
}

signal (SIGINT, &sigint_handler);

define verboseon ()
{
  load.from ("print", "tostdout", NULL;err_handler = &__err_handler__);
}

define verboseoff ()
{
  load.from ("print", "null_tostdout", NULL;err_handler = &__err_handler__);
}

load.from ("api", "comapi", NULL;err_handler = &__err_handler__);

define close_smg ();
define restore_smg ();

define ask (questar, ar)
{
  __IO__.tostderr (questar);
  variable len = COLUMNS - strlen (questar[-1]) - 1;
  loop (len)
    () = fprintf (stderr, "\b");

  variable chr;

  while (chr = getch (), 0 == any (ar == chr));

  input->at_exit ();

  () = fprintf (stderr, "\n");

  return chr;
}

load.from ("com/" + com, "comInit", NULL;err_handler = &__err_handler__);
