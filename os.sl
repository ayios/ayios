ifnot (ISSUPROC)
  {
  tostderr ("you should run this script with super user rights");
  exit (1);
  }

sigprocmask (SIG_BLOCK, [SIGINT]);

public variable HASHEDDATA;
public variable STDERR = TEMPDIR + "/" + string (PID) + "stderr.os";
public variable STDERRFD;
public variable STDERRFDDUP = NULL;
public variable ERR;
public variable OSUID = UID;
public variable OSUSR = USER;
public variable VERBOSITY = 0;
public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x04;

VERBOSITY |= (LOGNORM|LOGERR);

loadfrom ("input", "inputInit", NULL, &on_eval_err);
loadfrom ("smg", "smgInit", NULL, &on_eval_err);

private define _reset_ ()
{
  smg->reset ();
  input->at_exit ();
}

define on_eval_err (ar, code)
{
  _reset_ ();
  array_map (Void_Type, &tostderr, ar);
  exit (code);
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
  exit (code);
}

loadfrom ("os", "passwd", 1, &on_eval_err);
loadfrom ("rline", "rlineInit", NULL, &on_eval_err);
loadfrom ("os", "login", 1, &on_eval_err);
loadfrom ("posix", "redirstreams", NULL, &on_eval_err);
loadfrom ("api", "vedlib", NULL, &on_eval_err);

HASHEDDATA = os->login ();

STDERRFDDUP = redir (stderr, STDERR, NULL, NULL);

if (NULL == STDERRFDDUP)
  exit_me (1);

STDERRFD = ();

define on_eval_err (ar, exit_code)
{
  at_exit ();
  array_map (&tostderr, ar);
  exit (exit_code);
}

loadfrom ("os", "osInit", NULL, &on_eval_err);

define tostderr (str)
{
  () = lseek (STDERRFD, 0, SEEK_END);
  () = write (STDERRFD, str + "\n");
}

define on_eval_err (ar, code)
{
  array_map (&tostderr, ar);

  tostderr ("err: " + string (code));

  smg->init ();
  draw (ERR);
  osloop ();
}

_log_ ("started os session, with pid " + string (PID), LOGNORM);

os->runapp (;argv0 = __argc > 1 ? __argv[1] : "shell");

toplinedr (" -- OS CONSOLE --" + " (depth " + string (_stkdepth ()) + ")");

osloop ();
