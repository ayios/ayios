public variable app = path_basename_sans_extname (__argv[0]);
public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x03;
public variable ALLOWIDLED = 0;

sigprocmask (SIG_BLOCK, [SIGINT]);
  
define _log_ (str) {}

define exit_me (code)
{
  exit (code);
}

loadfrom ("app/" + app, app, NULL, &on_eval_err);
