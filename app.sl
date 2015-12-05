public variable app = path_basename_sans_extname (__argv[0]);
public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x03;
sigprocmask (SIG_BLOCK, [SIGINT]);

define _log_ (str) {}

define exit_me (code)
{
  exit (code);
}

load.from ("app/" + app, app, NULL;err_handler = &__err_handler__);
