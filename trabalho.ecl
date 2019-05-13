:- lib(ic).
:- lib(ic_global).
:- lib(ic_edge_finder).
:- lib(branch_and_bound).

:- compile(ex2_v).

/*
Para o Eclipse dar
export PATH=${PATH}:/home/unas/Aulas/TerceiroAno/Métodos\ de\ Apoio\ á\ Decisão/bin/x86_64_linux
*/

/*
TODO:
 - Aguentar quando 2 tarefas não têm precedentes?
/*

/* tarefa(ID,Precs,Duracao,Trabalhadores) - EclipseCPL
   t(ID,Duracao,Precs) - SWIPL */

run :- get_data(Tarefas,Precedencias,D,T).

get_data(Tarefas,Precedencias,D,T) :-
    findall(T,tarefa(T,_,_,_),Tarefas),
    findall(D,tarefa(_,_,D,_),Duracao),
    findall(W,tarefa(_,_,_,W),Trabalhadores),
    length(Tarefas,NTarefas), length(DatasInicio,NTarefas),
    duracao_total(Tarefas,MaxD),
    writeln(''),
    DatasInicio#::0..MaxD, Fim#::0..MaxD, Limit#::0..50,
    get_succ(Tarefas,DatasInicio,Fim),
    cumulative(DatasInicio,Duracao,Trabalhadores,Limit),
    minimize(labeling([Fim,Limit]),Fim),
    escrever_tarefas(Tarefas,DatasInicio),
    writeln(''),
    write('Número mínimo de trabalhadores: '),writeln(Limit).

get_succ([],_,_).
get_succ([T|RTarefas],Datas,Fim) :-
    tarefa(T,Segs,Di,_),
    selec_elemento(1,T,Datas,DataI),
    get_succ_(Segs,Datas,DataI,Di),
    DataI+Di #=< Fim,
    get_succ(RTarefas,Datas,Fim).

get_succ_([],_,_,_).
get_succ_([J|PSegs],Datas,DataI,Di) :-
    selec_elemento(1,J,Datas,DataJ),
    DataI+Di #=< DataJ,
    get_succ_(PSegs,Datas,DataI,Di).

duracao_total([],0).
duracao_total([T|RTarefas], Total) :-
    tarefa(T,_,Di,_), 
    duracao_total(RTarefas,Total_), Total is Total_ + Di.

/*get_min_workers([],[],N,F) :- writeln(N:F).
get_min_workers([I|RTarefas],[Xi|RX],N,F) :-
    
helper([I|RTarefas],[Xi|RX], T, W) :-
    tarefa(I,_,D,Wk),
    Result is D + Xi,
    Result #=< T,
    W is W + Wk,
    helper(RTarefas,Rx,T,W).
*/

selec_elemento(T,T,[I|_],I) :- !.
selec_elemento(T0,T,[_|R],I) :-  T0n is T0+1, selec_elemento(T0n,T,R,I).

escrever_tarefas([],[]).
escrever_tarefas([I|RTarefas], [Xi|RX]) :-
    Minimum is get_min(Xi),
    write(I:Minimum), nl,
    escrever_tarefas(RTarefas,RX).

