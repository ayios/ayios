<-- ...... so, here we are coming from

https://github.com/agh-xx/youandit

and sure we don't know where to end up, but for the first
time in humanity's history, I think we have some reference
that can be quite strong roots, but without to be stacked
in the ground.

Now, this is a first draft which is at thoughts level.

Present code achieved the same functionality, plus an editor
and with quite a few new capabilities.

And it does that with 40% less code. The code now is much easier
to understand and extend.

It's fairly easy to write new applications (even now at the early
state of development).

The code is much more compact, so easier to maintain, develop and
understand.

Commands can be used as standalone.

Applications can be used as standalone.

No need for extra sudo settings.

A readline with many features and easy to extend by using callbacks.

Still the error handling is not good and the messages are not always
helpfull. The old code never (almost) hangup (slowly getting there), but
the direction of the new code goes to: never fail.
This isn't now the case, since the interface is based in vedlib, which
is responsible for all the drawing/screen related actions, plus is being
used for editing and will be used to execute code in future. But
this is the first time I'm facing with such challenges (writting an editor)
and certainly could be improved, but anyway is considering a first draft.

The system is based on a robust load file (the root of everything), very few
things can be changed there).

While the old code spawned three processes and the new just one, however
every application spawn its own process; that's why for now the error handling
is more difficult, so what I have to do is to turn this into an advantage.
...
