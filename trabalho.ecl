:- lib(ic).
:- lib(ic_global).
:- lib(ic_edge_finder).
:- lib(branch_and_bound).

:- compile(ex3).

/*
Para o Eclipse dar
export PATH=${PATH}:/home/unas/Aulas/TerceiroAno/Métodos\ de\ Apoio\ á\ Decisão/bin/x86_64_linux
*/

run(P) :-
    get_data(Tarefas,Duracao,Trabalhadores),
    length(Tarefas,NTarefas), length(DatasInicio,NTarefas),
    total_duration(Tarefas,MaxD),
    writeln(''),
    max_workers(Trabalhadores,MaxW,0),
    DatasInicio#::0..MaxD, Fim#::0..MaxD, Limit#::0..MaxW, Limit_#::0..MaxW,
    (P = 1 -> min_es(Tarefas,DatasInicio,Duracao,Trabalhadores,Limit_,Fim); P = 2 -> get_start_time(Tarefas,DatasInicio,Duracao,Trabalhadores,Limit,Fim); true).

    /*get_es(DatasInicio,EStarts),
    writeln('Earliest Start Times:'),
    print_tasks(Tarefas,DatasInicio),
    cumulative(EStarts,Duracao,Trabalhadores,Limit_),
    writeln(''),
    get_min(Fim,Fim),
    get_min(Limit,Limit),
    get_min(Limit_,Limit_),
    minimize(labeling([Fim,Limit,Limit_]),Fim),
    write('Earliest Finish Time: '), writeln(Fim),
    write('Número mínimo de trabalhadores com EST: '),writeln(Limit_),
    write('Número mínimo de trabalhadores: '),writeln(Limit),
    labeling(DatasInicio),
    writeln(''),
    writeln('Optimum Solution:'),
    print_tasks_(Tarefas,DatasInicio).*/
 

min_es(Tarefas,DatasInicio,Duracao,Trabalhadores,Limit_,Fim) :-
    get_successors(Tarefas,DatasInicio,Fim),
    get_es(DatasInicio),
    cumulative(DatasInicio,Duracao,Trabalhadores,Limit_),
    get_min(Limit_,Limit_),
    print_tasks_(Tarefas,DatasInicio),
    writeln(''),
    write('Número mínimo de trabalhadores com EST: '),writeln(Limit_).

get_start_time(Tarefas,DatasInicio,Duracao,Trabalhadores,Limit,Fim) :-
    get_successors(Tarefas,DatasInicio,Fim),
    cumulative(DatasInicio,Duracao,Trabalhadores,Limit),
    minimize(labeling([Fim,Limit]),Fim),
    labeling(DatasInicio),
    print_tasks_(Tarefas,DatasInicio),
    writeln(''),
    write('Número mínimo de trabalhadores: '),writeln(Limit),
    writeln(''),
    get_critical_tasks(DatasInicio,Tarefas).

get_critical_tasks(DatasInicio,Tarefas) :-
    get_critical_n(DatasInicio,CriticalN,0),
    length(CriticalTasks,CriticalN), length(CriticalStart,CriticalN), length(CriticalDuration,CriticalN), length(CriticalWorkers,CriticalN),
    get_critical(Tarefas,DatasInicio,CriticalTasks, CriticalStart),
    (foreach(X,CriticalTasks), foreach(Y,CriticalStart) do writeln('Critical Task':X:Y)),
    writeln(''),
    get_others(CriticalTasks,CriticalDuration,CriticalWorkers),
    cumulative(CriticalStart,CriticalDuration,CriticalWorkers,Limit__),
    get_min(Limit__,Limit__),
    writeln('Minimum workers for critical tasks':Limit__).

get_others([],[],[]).
get_others([T|RT], [D|RD], [W|RW]) :-
    tarefa(T,_,Di,Wi),
    D is Di,
    W is Wi,
    get_others(RT,RD,RW).

get_critical_n([],CriticalN,Adder) :- CriticalN is Adder.
get_critical_n([X|RX],CriticalN,Adder) :-
    Y is get_max(X),
    Z is get_min(X),
    (Y = Z -> Adder_ is Adder + 1; Adder_ is Adder),
    get_critical_n(RX,CriticalN,Adder_).

get_critical([],[],[],[]).
get_critical([T|RT],[X|RX],[Y|RY], [Z|RZ]) :-
    Max is get_max(X),
    Min is get_min(X),
    (Max = Min -> Y is T, Z is X, get_critical(RT,RX,RY,RZ); Max \= Min -> get_critical(RT,RX,[Y|RY],[Z|RZ])).

get_data(Tarefas,Duracao,Trabalhadores) :-
    findall(T,tarefa(T,_,_,_),Tarefas),
    findall(D,tarefa(_,_,D,_),Duracao),
    findall(W,tarefa(_,_,_,W),Trabalhadores).

get_es([]).
get_es([Xi|RX]) :-
    get_min(Xi,Xi),
    get_es(RX).

get_successors([],_,_).
get_successors([T|RTarefas],Datas,Fim) :-
    tarefa(T,Segs,Di,_),
    select_element(1,T,Datas,DataI),
    get_successors_(Segs,Datas,DataI,Di),
    DataI+Di #=< Fim,
    get_successors(RTarefas,Datas,Fim).

get_successors_([],_,_,_).
get_successors_([J|PSegs],Datas,DataI,Di) :-
    select_element(1,J,Datas,DataJ),
    DataI+Di #=< DataJ,
    get_successors_(PSegs,Datas,DataI,Di).

total_duration([],0).
total_duration([T|RTarefas], Total) :-
    tarefa(T,_,Di,_), 
    total_duration(RTarefas,Total_), Total is Total_ + Di.

select_element(T,T,[I|_],I) :- !.
select_element(T0,T,[_|R],I) :-  T0n is T0+1, select_element(T0n,T,R,I).

print_tasks([],[]).
print_tasks([I|RTarefas], [Xi|RX]) :-
    Min is get_min(Xi),
    write('Task':I), write(' EST':Min), nl,
    print_tasks(RTarefas,RX).

print_tasks_([],[]).
print_tasks_([I|RTarefas], [Xi|RX]) :-
    write('Task':I), write(' Start Time':Xi), nl,
    print_tasks_(RTarefas,RX).

max_workers([],MaxW,Adder):- MaxW is Adder.
max_workers([T|RTrabs],MaxW,Adder) :-
    Adder_ is Adder + T,
    max_workers(RTrabs,MaxW,Adder_).