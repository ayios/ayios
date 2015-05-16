variable app = path_basename_sans_extname (__argv[0]);

importfrom ("std", "socket", NULL, &on_eval_err);

loadfrom ("app/" + app, "appInit", NULL, &on_eval_err);
