-module(n2o_client).
-author('Maxim Sokhatsky').
-include_lib("n2o/include/wf.hrl").
-compile(export_all).

info({client,Message}, Req, State) ->
    wf:info(?MODULE,"Client Message: ~p",[Message]),
    Module = State#cx.module,
    try Module:event({client,Message}) catch E:R -> wf:error(?MODULE,"Catch: ~p:~p~n~p", wf:stack(E, R)) end,
    {reply,wf:format({io,n2o_nitrogen:render_actions(wf:actions()),Message}),Req,State};

info({server,Message}, Req, State) ->
    wf:info(?MODULE,"Server Message: ~p",[Message]),
    Module = State#cx.module,
    try Module:event({server,Message}),[] catch E:R -> wf:error(?MODULE,"Catch: ~p:~p~n~p", wf:stack(E, R)) end,
    {reply,wf:format({io,n2o_nitrogen:render_actions(wf:actions()),Message}),Req,State};

info(Message, Req, State) -> {unknown,Message, Req, State}.
