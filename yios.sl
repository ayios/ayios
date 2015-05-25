private variable ENV = Assoc_Type[String_Type];
private variable SESSION = Assoc_Type[Integer_Type];
private variable OS = Assoc_Type[String_Type];

loadfrom ("posix", "redirstreams", NULL, &on_eval_err);
loadfrom ("dir", "isdirectory", NULL, &on_eval_err);
loadfrom ("sys", "which", 1, &on_eval_err);
loadfrom ("sys", "getpw", 1, &on_eval_err);
loadfrom ("boot", "login", 1, &on_eval_err);
loadfrom ("boot", "setenviron", 1, &on_eval_err);
loadfrom ("proc", "procInit", NULL, &on_eval_err);
loadfrom ("boot", "getloginpaswd", 1, &on_eval_err);
loadfrom ("crypt", "cryptInit", NULL, &on_eval_err);

boot->setenviron (ENV, SESSION, OS);

% ------------------ END HERE BOOT? ------------ %

loadfrom ("smg", "smgInit", NULL, &on_eval_err);
loadfrom ("input", "inputInit", NULL, &on_eval_err);
loadfrom ("boot", "getsessionhashpaswd", 1, &on_eval_err);
loadfrom ("boot", "confirmsessionpaswd", 1, &on_eval_err);
loadfrom ("me", "exit", NULL, &on_eval_err);

smg->init ();
smg->set_img (LINES - 2);
 
if (SESSION["AREYOUSU"])
  {
  boot->getloginpaswd (ENV["USER"], SESSION["U_UID"], SESSION["U_GID"], OS["SLSH_BIN"]);

  ENV["HASH"] = boot->getsessionhashpaswd ();
 
  if (NULL == boot->confirmsessionpaswd (ENV["HASH"]))
    on_eval_err ("confirm failed", 1);
  }

smg->suspend ();

% ok at this point
%redirstderr ("/tmp/rstderr", NULL, NULL);

% ---------------------------------------------- %
loadfrom ("app/ved", "vedInit", NULL, &on_eval_err);

% ----------------- TESTING ---------------- %
define quit (str, code)
{
  on_eval_err (str, atoi (code));
}

ved ("/tmp/os.sl";lines = LINES, columns = COLUMNS,
  tmpdir = "/tmp", slshbin = OS["SLSH_BIN"]);

smg->resume ();

smg->setrc (10, 10);
smg->addnstr ("Hello world", 20);
smg->refresh ();

variable mywind = struct
  {
  ptr = [10, 16],
  };

variable CLINEC = Assoc_Type[Ref_Type];
CLINEC["q"] = &quit;

loadfrom ("wind", "rootTopline", NULL, &on_eval_err);
loadfrom ("rline", "rlineInit", NULL, &on_eval_err);

variable rl = rline->init (LINES - 2, ":", 6, LINES, COLUMNS, ["q", "write"], [10, 16]);
rline->readline (rl, " -- ROOT --", " -- ROOT --", CLINEC);

exit_me ();
