-module(n2o_file).
-author('Andrey Martemyanov').
-include_lib("n2o/include/wf.hrl").
-compile(export_all).

info({binary,Message}, Req, State) -> info(binary_to_term(Message,[safe]),Req,State);

info({bin,Message}, Req, State) ->
    Module = State#cx.module,
    DpkldMessage = case wf:depickle(Message) of
        undefined -> Message;
        Depickled -> Depickled
    end,
    Term = try Module:event({bin,DpkldMessage}) catch E:R -> wf:error(?MODULE,"Catch: ~p:~p~n~p", wf:stack(E, R)), <<>> end,
    wf:info(?MODULE,"Raw Binary Message: ~p Result: ~p",[Message,Term]),
    Res = case Term of
        #ftp{
            id=Id, type=Type, app=App, version=Version,
            from=From, to=To, meta=Meta, data=Data } ->
            MetaSize = byte_size(Meta),
            <<132,Id:32,Type:8,App:8,Version:8,
                  From:32,To:32,MetaSize:32,Meta/binary,Data/binary>>;
        _ when is_binary(Term) -> Term;
        _ -> term_to_binary(Term) end,
    {reply,{binary,Res},Req,State};

info(Message, Req, State) -> {unknown,Message, Req, State}.
