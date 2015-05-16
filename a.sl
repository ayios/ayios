define tostderr (str)
{
  () = fprintf (stderr, "%s\n", str);
}

define tostdout (str)
{
  () = fprintf (stdout, "%s\n", str);
}

define on_eval_err (ar, err)
{
  array_map (&tostderr, ar);
  exit (err);
}

try
  {
  () = evalfile (path_dirname (__FILE__) +  "/../std/load");
  }
catch AnyError:
  on_eval_err (["Error: " + __get_exception_info.message], __get_exception_info.error);

public variable
  TERM, LANG, HOME, PATH, DISPLAY, XAUTHORITY,
  SLSH_BIN, PWD, GROUP, UID, GID, PID, AREYOUSU, USER;

loadfrom ("proc", "procInit", NULL, &on_eval_err);
loadfrom ("sys", "which", NULL, &on_eval_err);
loadfrom ("sys", "getpw", 1, &on_eval_err);
loadfrom ("getvar", "getterm", NULL, &on_eval_err);
loadfrom ("getvar", "getlang", NULL, &on_eval_err);
loadfrom ("getvar", "isutf8", NULL, &on_eval_err);
loadfrom ("getvar", "gethome", NULL, &on_eval_err);
loadfrom ("boot", "getenviron", 1, &on_eval_err);

boot->getenviron ();
