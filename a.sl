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

load.from("sys", "getpw", NULL;err_handler = &__err_handler__);
load.from ("os", "bootenviron", NULL;err_handler = &__err_handler__);

ifnot (access (Dir.vget ("TEMPDIR"), F_OK))
  {
  ifnot (_isdirectory (Dir.vget ("TEMPDIR")))
    {
    IO.tostderr (Dir.vget ("TEMPDIR"), " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (Dir.vget ("TEMPDIR")))
    {
    IO.tostderr ("cannot create directory ", errno_string (errno));
    exit (1);
    }

ifnot (access (Dir.vget ("HISTDIR"), F_OK))
  {
  ifnot (_isdirectory (Dir.vget ("HISTDIR")))
    {
    IO.tostderr (Dir.vget ("HISTDIR"), " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (Dir.vget ("HISTDIR")))
    {
    IO.tostderr ("cannot create directory ", errno_string (errno));
    exit (1);
    }

load.from ("proc", "procInit", NULL;err_handler = &__err_handler__);
