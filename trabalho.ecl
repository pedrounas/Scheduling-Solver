:- lib(ic).
:- lib(ic_global).
:- lib(branch_and_bound).

:- compile(base_dados).

duracao_projeto :- get_data(Tarefas,Precedencias,D,T).

get_data(Tarefas,Precedencias,D,T) :-
    findall(T,tarefa(T,_,_,_),Tarefas),
    findall(P,tarefa(_,P,_,_),Precedencias),
    findall(D,tarefa(_,_,D,_),Duracao),
    basic_duration(Duracao).

basic_duration(Duracao) :-
    sum = 0,
    (foreach(X,Duracao), fromto(0,In,Out,Sum) do Out is In+X),
    write(Out), nl.
    