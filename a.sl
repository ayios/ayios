try
  {
  () = evalfile (path_dirname (__FILE__) +  "/../std/load");
  }
catch AnyError:
  {
  () = fprintf (stderr, "Error: %s %s %d\n", __get_exception_info.message,
    __get_exception_info.function, __get_exception_info.line);
  exit (__get_exception_info.error);
  }

define __err_handler__ (__r__)
{
  IO.tostderr (__r__.err);
  exit (1);
}

Sys->Fun ("setgrname__", NULL);
Sys->Fun ("setpwname__", NULL);

if (NULL == Env->Vget ("TERM"))
  {
  IO.tostderr ("TERM environment variable isn't set");
  exit (1);
  }

if (NULL == Env->Vget ("LANG"))
  {
  IO.tostderr ("LANG environment variable isn't set");
  exit (1);
  }

if (5 > strlen (Env->Vget ("LANG")) || "UTF-8" != substr (Env->Vget ("LANG"),
  strlen (Env->Vget ("LANG")) - 4, -1))
  {
  IO.tostderr ("locale: " + Env->Vget ("LANG") + " isn't UTF-8 (Unicode), or misconfigured");
  exit (1);
  }

if (NULL == getenv ("HOME"))
  {
  IO.tostderr ("HOME environment variable isn't set");
  exit (1);
  }

if (NULL == Env->Vget ("PATH"))
  {
  IO.tostderr ("PATH environment variable isn't set");
  exit (1);
  }

SLSH_BIN = Sys.which ("slsh");
SUDO_BIN = Sys.which ("sudo");

Env->Var ("user", Sys.setpwname (Env->Vget ("uid"), &$1));

if (NULL == Env->Vget ("user"))
  {
  IO.tostderr (__tmp ($1));
  exit (1);
  }

Env->Var ("group", Sys.setgrname (Env->Vget ("gid"), &$1));

if (NULL == Env->Vget ("group"))
  {
  IO.tostderr (__tmp ($1));
  exit (1);
  }
ifnot (access (Dir->Vget ("TEMPDIR"), F_OK))
  {
  ifnot (_isdirectory (Dir->Vget ("TEMPDIR")))
    {
    IO.tostderr (Dir->Vget ("TEMPDIR"), " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (Dir->Vget ("TEMPDIR")))
    {
    IO.tostderr ("cannot create directory ", errno_string (errno));
    exit (1);
    }

ifnot (access (Dir->Vget ("HISTDIR"), F_OK))
  {
  ifnot (_isdirectory (Dir->Vget ("HISTDIR")))
    {
    IO.tostderr (Dir->Vget ("HISTDIR"), " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (Dir->Vget ("HISTDIR")))
    {
    IO.tostderr ("cannot create directory ", errno_string (errno));
    exit (1);
    }

load.from ("proc", "procInit", NULL;err_handler = &__err_handler__);
