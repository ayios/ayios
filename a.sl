try
  {
  () = evalfile (path_dirname (__FILE__) +  "/../std/load");
  }
catch AnyError:
  {
  () = fprintf (stdout, "Error: %s %s %d\n", __get_exception_info.message,
    __get_exception_info.function, __get_exception_info.line);
  exit (__get_exception_info.error);
  }

define __err_handler__ (__r__)
{
  exit (1);
}

load.from("sys", "getpw", NULL;err_handler = &__err_handler__);
load.from ("os", "bootenviron", NULL;err_handler = &__err_handler__);

ifnot (access (TEMPDIR, F_OK))
  {
  ifnot (_isdirectory (TEMPDIR))
    {
    __IO__.tostderr (TEMPDIR, " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (TEMPDIR))
    {
    __IO__.tostderr ("cannot create directory ", errno_string (errno));
    exit (1);
    }

ifnot (access (HISTDIR, F_OK))
  {
  ifnot (_isdirectory (HISTDIR))
    {
    __IO__.tostderr (HISTDIR, " is not a directory");
    exit (1);
    }
  }
else
  if (-1 == mkdir (HISTDIR))
    {
    __IO__.tostderr ("cannot create directory ", errno_string (errno));
    exit (1);
    }

load.from ("proc", "procInit", NULL;err_handler = &__err_handler__);
