variable app = path_basename_sans_extname (__argv[0]);
public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x03;

define _log_ (str) {}

importfrom ("std", "socket", NULL, &on_eval_err);

loadfrom ("app/" + app, "appInit", NULL, &on_eval_err);
