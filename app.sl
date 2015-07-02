public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x03;

public variable ALLOWIDLED = 0;

sigprocmask (SIG_BLOCK, [SIGINT]);
  
define _log_ (str) {}

importfrom ("std", "socket", NULL, &on_eval_err);

loadfrom ("os", "AppInit", NULL, &on_eval_err);

private define runapp ()
{
  variable app = path_basename_sans_extname (__argv[0]);

  ifnot (any (app == _APPS_))
    {
    tostderr (app + ": No such application");
    exit (1);
    }
  
  loadfrom ("app/" + app, APPSINFO[app].init, app, &on_eval_err);
  
  variable ref = __get_reference (app + "->" + app);
  variable args = {};
  variable argv = __argv[[1:]];
  variable i;
  
  _for i (0, __argc - 2)
    list_append (args, argv[i]);

  variable exit_code = (@ref) (__push_list (args));

  exit (exit_code); 
}

os->apptable ();

_APPS_ = assoc_get_keys (APPS);

runapp ();
