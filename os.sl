private variable SESSION = Assoc_Type[Integer_Type];
private variable OS = Assoc_Type[String_Type];

loadfrom ("posix", "redirstreams", NULL, &on_eval_err);
loadfrom ("boot", "login", 1, &on_eval_err);
loadfrom ("boot", "setenviron", 1, &on_eval_err);
loadfrom ("boot", "getloginpaswd", 1, &on_eval_err);
loadfrom ("crypt", "cryptInit", NULL, &on_eval_err);

if (UID)
  USER = sys->getpwname (UID, 1);
else
  {
  USER = boot->getloginname ();
  (UID, GID) = sys->getpwuidgid (USER, 1);
  }

GROUP = sys->getgrname (GID, 1);
  
boot->setenviron (SESSION, OS);

% ------------------ END HERE BOOT? ------------ %

loadfrom ("smg", "smgInit", NULL, &on_eval_err);
loadfrom ("input", "inputInit", NULL, &on_eval_err);
loadfrom ("boot", "getsessionhashpaswd", 1, &on_eval_err);
loadfrom ("boot", "confirmsessionpaswd", 1, &on_eval_err);
loadfrom ("me", "exit", NULL, &on_eval_err);

if (AREYOUSU)
  {
  boot->getloginpaswd (USER, UID, GID, SLSH_BIN);

  OS["HASH"] = boot->getsessionhashpaswd ();
  
  if (NULL == boot->confirmsessionpaswd (OS["HASH"]))
    on_eval_err ("confirm failed", 1);
  }

% ok at this point
%redirstderr ("/tmp/rstderr", NULL, NULL);

define quit (str, code)
{
  on_eval_err (str, atoi (code));
}

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
