public variable HASHEDDATA;
public variable STDERR = TEMPDIR + "/" + string (PID) + "stderr.os";
public variable STDERRFD;
public variable STDERRFDDUP = NULL;
public variable ERR;
public variable OSUID = UID;
public variable OSUSR = setpwname (OSUID, 1);
public variable VERBOSITY = 0;
public variable LOGERR = 0x01;
public variable LOGNORM = 0x02;
public variable LOGALL = 0x04;

VERBOSITY = VERBOSITY|LOGALL|LOGNORM|LOGERR;

loadfrom ("posix", "redirstreams", NULL, &on_eval_err);
loadfrom ("boot", "login", 1, &on_eval_err);
loadfrom ("boot", "getloginpaswd", 1, &on_eval_err);
loadfrom ("crypt", "cryptInit", NULL, &on_eval_err);

ifnot (ISSUPROC)
  USER = setpwname (UID, 1);
else
  {
  USER = boot->getloginname ();
  (UID, GID) = setpwuidgid (USER, 1);
  }

GROUP = setgrname (GID, 1);
 
% ------------------ END HERE BOOT? ------------ %

loadfrom ("smg", "smgInit", NULL, &on_eval_err);
loadfrom ("app/ved/functions", "vedlib", NULL, &on_eval_err);
loadfrom ("input", "inputInit", NULL, &on_eval_err);
loadfrom ("boot", "passwd", 1, &on_eval_err);

if (ISSUPROC)
  {
  boot->getloginpaswd (USER, UID, GID, SLSH_BIN);

  HASHEDDATA = boot->encryptpasswd (NULL);
  }

private define at_exit ()
{
  smg->reset ();
  input->at_exit ();
  ifnot (NULL == STDERRFDDUP)
    () = dup2_fd (STDERRFDDUP, 2);
}

public define exit_me (code)
{
  at_exit ();
  exit (code);
}

STDERRFDDUP = redirstderr (STDERR, NULL, NULL);

if (NULL == STDERRFDDUP)
  exit_me (1);

STDERRFD = ();

define tostderr (str)
{
  () = lseek (STDERRFD, 0, SEEK_END);
  () = write (STDERRFD, str + "\n");
}

define on_eval_err (ar, exit_code)
{
  at_exit ();
 
  array_map (&tostderr, ar);

  exit_me (exit_code);
}


define _log_ (str, logtype)
{
  if (VERBOSITY & logtype)
    tostderr (str);
}

loadfrom ("os", "osInit", NULL, &on_eval_err);

define on_eval_err (ar, code)
{
  array_map (&tostderr, ar);
  tostderr ("err: " + string (code));

  osloop ();
}

_log_ ("started ayios session, with pid " + string (PID), LOGNORM);

osdraw (ERR);

osloop ();
