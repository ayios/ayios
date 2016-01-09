ifnot (Env->Vget ("ISSUPROC"))
  {
  IO.tostderr ("you should run this script with super user rights");
  exit (1);
  }

sigprocmask (SIG_BLOCK, [SIGINT]);

public variable HASHEDDATA;
public variable STDERR = Dir->Vget ("TEMPDIR") + "/" + string (Env->Vget ("PID")) + "stderr.os";
public variable STDERRFD;
public variable STDERRFDDUP = NULL;
public variable ERR;
public variable OSUID = Env->Vget ("uid");
public variable OSUSR = Env->Vget ("user");
public variable VERBOSITY = 0;
public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x04;

VERBOSITY |= (LOGNORM|LOGERR);

Sys->Fun ("setpwuidgid__", NULL);

load.from ("input", "inputInit", NULL;err_handler = &__err_handler__);
load.from ("smg", "smginit", 1;err_handler = &__err_handler__);
load.from ("os", "getpasswd", NULL;err_handler = &__err_handler__);

smg->init ();

private define _reset_ ()
{
  smg->reset ();
  input->at_exit ();
}

define __err_handler__ (__r__)
{
  _reset_ ();
  IO.tostderr (__r__.err);
  exit (1);
}

private define at_exit ()
{
  _reset_ ();

  ifnot (NULL == STDERRFDDUP)
    () = dup2_fd (STDERRFDDUP, 2);
}

define exit_me (code)
{
  at_exit ();

  variable msg = qualifier ("msg");

  ifnot (NULL == msg)
    if (String_Type == typeof (msg) ||
       (Array_Type == typeof (msg) && _typeof (msg) == String_Type))
      IO.tostderr (msg);

  exit (code);
}

load.from ("os", "passwd", 1;err_handler = &__err_handler__);
load.from ("rline", "rlineInit", NULL;err_handler = &__err_handler__);
load.from ("os", "login", 1;err_handler = &__err_handler__);
load.from ("posix", "redirstreams", NULL;err_handler = &__err_handler__);
load.from ("api", "vedlib", NULL;err_handler = &__err_handler__);

HASHEDDATA = os->login ();

(STDERRFD, STDERRFDDUP) = redir (stderr, STDERR, NULL, NULL);

if (NULL == STDERRFDDUP)
  exit_me (1);

define __err_handler__ (__r__)
{
  at_exit ();
  IO.tostderr (__r__.err);
  exit (1);
}

load.from ("os", "osInit", NULL;err_handler = &__err_handler__);

define tostderr ()
{
  variable fmt = "%S";
  loop (_NARGS) fmt += " %S";
  variable args = __pop_list (_NARGS);

  () = lseek (STDERRFD, 0, SEEK_END);

  if (1 == length (args) && typeof (args[0]) == Array_Type &&
    String_Type == _typeof (args[0]))
    {
    args = args[0];
    if (Integer_Type == _typeof (args))
      args = array_map (String_Type, &string, args);

    ifnot (qualifier_exists ("n"))
      args += "\n";

    try
      {
      () = array_map (Integer_Type, &write, STDERRFD, args);
      }
    catch AnyError:
      throw __Error, "IOWriteError::" + _function_name + "::" + errno_string (errno), NULL;
    }
  else
    {
    variable str = sprintf (fmt, __push_list (args), qualifier_exists ("n") ? "" : "\n");
    if (-1 == write (STDERRFD, str))
      throw __Error, "IOWriteError::" + _function_name + "::" + errno_string (errno), NULL;
    }
}

IO->Fun ("tostderr?", &tostderr);

define __err_handler__ (__r__)
{
  smg->init ();
  draw (ERR);
  osloop ();
}

_log_ ("started os session, with pid " + string (Env->Vget ("PID")), LOGNORM);

os->runapp (;argv0 = __argc > 1 ? __argv[1] : "shell");

toplinedr (" -- OS CONSOLE --" + " (depth " + string (_stkdepth ()) + ")");

osloop ();
