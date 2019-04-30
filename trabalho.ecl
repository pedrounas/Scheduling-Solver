:- lib(ic).
:- lib(ic_global).
:- lib(branch_and_bound).

:- compile(base_dados).

/* tarefa(ID,Precs,Duracao,Trabalhadores) - EclipseCPL
   t(ID,Duracao,Precs) - SWIPL */

run :- get_data(Tarefas,Precedencias,D,T).

get_data(Tarefas,Precedencias,D,T) :-
    findall(T,tarefa(T,_,_,_),Tarefas),
    findall(P,tarefa(_,P,_,_),Precedencias),
    findall(D,tarefa(_,_,D,_),Duracao),
    findall(W,tarefa(_,_,_,W),Trabalhadores),
    length(Tarefas,NTarefas), length(DatasInicio,NTarefas),
    duracao_total(Tarefas,MaxW),
    DatasInicio#::0..MaxW, Fim#::0..MaxW,
    get_succ(Tarefas,DatasInicio,Fim),
    (foreach(X,Tarefas),foreach(Y,DatasInicio) do writeln(X:Y)).
    
get_succ([],_,_).
get_succ([T|RTarefas],Datas,Fim) :-
    tarefa(T,Segs,Di,_),
    selec_elemento(1,T,Datas,DataI),
    get_succ_(Segs,Datas,DataI,Di),
    DataI+Di #=< Fim,
    get_succ(Segs,Datas,Fim).

get_succ_([],_,_,_).
get_succ_([J|PSegs],Datas,DataI,Di) :-
    selec_elemento(1,J,Datas,DataJ),
    DataI+Di #=< DataJ,
    get_succ_(PSegs,Datas,DataI,Di).


duracao_total([],0).
duracao_total([T|RTarefas], Total) :-
    tarefa(T,_,Di,_), 
    duracao_total(RTarefas,Total_), Total is Total_ + Di.

selec_elemento(T,T,[I|_],I) :- !.
selec_elemento(T0,T,[_|R],I) :-  T0n is T0+1, selec_elemento(T0n,T,R,I).

/*get_succ([],_).
get_succ([T|RTarefas],DataI) :-
    tarefa(T,Succs,Di,_),
    get_succ_(T,Succs,Di,DataI),
    Res is DataI + Di,
    get_succ(RTarefas, Res).

get_succ_([],_,_,_).
get_succ_(T,[],Di,DataI) :-
    writeln(T:[]:Di:DataI).
get_succ_(T,[S|RS],Di,DataI) :-
    writeln(T:S:Di:DataI),
    Res is DataI + Di,
    get_succ_(T,RS,Di,Res).*/

/*print_workers([]).
print_workers([Trabalhadores|RTrabalhadores]) :-
    writeln(Trabalhadores),
    print_workers(RTrabalhadores).*/

