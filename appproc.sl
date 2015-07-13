sigprocmask (SIG_BLOCK, [SIGINT]);

set_slang_load_path (loaddir + char (path_get_delimiter) +
  get_slang_load_path ());

variable HASHEDDATA = NULL;
variable STDOUT     = TEMPDIR + "/" + string (PID) + app + "stdout." + stdouttype;
variable STDERR     = TEMPDIR + "/" + string (PID) + app + "stderr.txt";
variable OUTFD;
variable ERRFD;
variable MSG;
variable SOCKET;
variable RLINE = NULL;

define on_eval_err (err, code)
{
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n", err);
  exit (code);
}

define tostderr (str)
{
  () = fprintf (stderr, "%s\n", str);
}

define exit_me (err, code)
{
  on_eval_err (err, code);
}

putenv ("USER=" + USER);
putenv ("LOGNAME=" + USER);
putenv ("USERNAME=" + USER);
putenv ("HOME=/home/" + USER); 
putenv ("GROUP=" + GROUP);

importfrom ("std", "socket",  NULL, &on_eval_err);

loadfrom ("sock", "sockInit", 1, &on_eval_err);

define send_int (fd, i)
{
  sock->send_int (fd, i);
}

define get_int (fd)
{
  return sock->get_int (fd);
}

define at_exit ()
{
  variable f;

  if (any ("input" == _get_namespaces ()))
    {
    f = __get_reference ("input->at_exit");
    (@f);
    }

  if (any ("smg" == _get_namespaces ()))
    {
    f = __get_reference ("smg->reset");
    (@f);
    }
}

define exit_me (exit_code)
{
  at_exit ();
  exit (exit_code);
}

define go_idled ()
{
  at_exit ();
  exit (0);
}

define on_eval_err (err, code)
{
  at_exit ();
  () = array_map (Integer_Type, &fprintf, stderr, "%s\n", err);
  exit (code);
}

loadfrom ("input", "inputInit", NULL, &on_eval_err);
loadfrom ("keys", "keysInit", 1, &on_eval_err);
loadfrom ("smg", "smgInit", NULL, &on_eval_err);
loadfrom ("stdio", "readfile", NULL, &on_eval_err);
loadfrom ("ved", "vedtypes", NULL, &on_eval_err);
loadfrom ("ved", "vedvars", NULL, &on_eval_err);
loadfrom ("os", "passwd", 1, &on_eval_err);
loadfrom ("parse", "is_arg", NULL, &on_eval_err);
loadfrom ("rline", "rlineInit", NULL, &on_eval_err);
loadfrom ("proc", "procInit", NULL, &on_eval_err);
loadfrom ("smg", "smgInit", NULL, &on_eval_err);
loadfrom ("sys", "checkpermissions", NULL, &on_eval_err);
loadfrom ("sys", "setpermissions", NULL, &on_eval_err);
loadfrom ("string", "repeat", NULL, &on_eval_err);
loadfrom ("stdio", "getlines", NULL, &on_eval_err);
loadfrom ("smg", "widg", "widg", &on_eval_err);
loadfrom ("wind", app + "topline", NULL, &on_eval_err);

if (VED_LIB)
  {
  loadfrom ("os", "appclientfuncs", NULL, &on_eval_err);
  loadfrom ("ved", "vedlib", NULL, &on_eval_err);
  }

define init_stream (fname)
{
  variable fd;

  if (-1 == access (fname, F_OK))
    fd = open (fname, FILE_FLAGS["<>"], PERM["_PRIVATE"]);
  else
    fd = open (fname, FILE_FLAGS["<>|"], PERM["_PRIVATE"]);

  if (NULL == fd)
    {
    tostderr ("Can't open file " + fname + " " + errno_string (errno));
    exit_me ();
    }
 
  variable st = fstat (fd);
  if (-1 == checkperm (st.st_mode, PERM["_PRIVATE"]))
    if (-1 == setperm (fname, PERM["_PRIVATE"]))
      exit_me ();

  return fd;
}

define tostdout (str)
{
  () = lseek (OUTFD, 0, SEEK_END);
  () = write (OUTFD, str);
}

define tostderr (str)
{
  () = lseek (ERRFD, 0, SEEK_END);
  () = write (ERRFD, str);
}

OUTFD = init_stream (STDOUT);
ERRFD = init_stream (STDERR);

loadfile ("Init", NULL, &on_eval_err);

MSG = init_ftype ("txt");
txt_settype (MSG, STDERR, VED_ROWS, NULL);
RLINE = rlineinit ();

