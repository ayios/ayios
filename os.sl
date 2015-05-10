public define tostderr (str)
{
  () = fprintf (stderr, "%s\n", str);
}

public define tostdout (str)
{
  () = fprintf (stdout, "%s\n", str);
}

public define on_eval_err (ar, err)
{
  array_map (&tostderr, ar);
  exit (err);
}

typedef struct
  {
  home,
  passwd,
  } User_Type;

public variable ENV = Assoc_Type[Any_Type];
public variable PERM = Assoc_Type[Integer_Type];
public variable USERS = Assoc_Type[User_Type];

try
  {
  () = evalfile (path_dirname (__FILE__) +  "/../std/load");
  }
catch AnyError:
  on_eval_err (["Error: " + __get_exception_info.message], __get_exception_info.error);

loadfrom ("boot", "setenviron", 1, &on_eval_err);
loadfrom ("boot", "login", 1, &on_eval_err);
loadfrom ("sys", "getpw", NULL, &on_eval_err);


boot->setenviron ();

if (ENV["U_UID"])
  ENV["U_NAME"] = getpwname (ENV["U_UID"], 1);
else
  {
  ENV["U_NAME"] = boot->getloginname ();
  ENV["U_UID"] = getpwuid (ENV["U_NAME"], 1);
  }

tostdout (ENV["U_NAME"]);
tostdout (string (ENV["U_UID"]));
