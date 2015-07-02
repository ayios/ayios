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

loadfrom ("getvar", "defvars", NULL, &on_eval_err);
loadfrom ("proc", "setenv", NULL, &on_eval_err);
loadfrom ("sys", "which", NULL, &on_eval_err);
loadfrom ("sys", "getpw", NULL, &on_eval_err);
loadfrom ("os", "bootenviron", 1, &on_eval_err);

os->setenviron ();

ifnot (access (TEMPDIR, F_OK))
  {
  ifnot (_isdirectory (TEMPDIR))
    {
    tostderr (TEMPDIR + " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (TEMPDIR))
    {
    tostderr ("cannot create directory " + errno_string (errno));
    exit (1);
    }

ifnot (access (HISTDIR, F_OK))
  {
  ifnot (_isdirectory (HISTDIR))
    {
    tostderr (HISTDIR + " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (HISTDIR))
    {
    tostderr ("cannot create directory " + errno_string (errno));
    exit (1);
    }

loadfrom ("proc", "procInit", NULL, &on_eval_err);
