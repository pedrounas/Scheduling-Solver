:- lib(ic).
:- lib(ic_global).
:- lib(ic_edge_finder).
:- lib(branch_and_bound).

:- compile(ex2_1).

/*
Para o Eclipse dar
export PATH=${PATH}:/home/unas/Aulas/TerceiroAno/Métodos\ de\ Apoio\ á\ Decisão/bin/x86_64_linux
*/

run :-
    findall(T,tarefa(T,_,_,_),Tarefas),
    findall(D,tarefa(_,_,D,_),Duracao),
    findall(W,tarefa(_,_,_,W),Trabalhadores),
    length(Tarefas,NTarefas), length(DatasInicio,NTarefas),
    total_duration(Tarefas,MaxD),
    writeln(''),
    max_workers(Trabalhadores,MaxW,0),
    DatasInicio#::0..MaxD, Fim#::0..MaxD, Limit#::0..MaxW,
    get_successors(Tarefas,DatasInicio,Fim),
    cumulative(DatasInicio,Duracao,Trabalhadores,Limit),
    get_es(DatasInicio,EStarts),
    writeln('Earliest Start Times:'),
    print_tasks(Tarefas,DatasInicio),
    cumulative(EStarts,Duracao,Trabalhadores,Limit_),
    writeln(''),
    minimize(labeling([Fim,Limit]),Fim),
    Limit_ is get_min(Limit_),
    writeln(''),
    write('Número mínimo de trabalhadores com EST: '),writeln(Limit_),
    write('Número mínimo de trabalhadores: '),writeln(Limit).

get_es([],[]).
get_es([Xi|RX],[Yi|RY]) :-
    Yi is get_min(Xi),
    get_es(RX,RY).

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
    write('Tarefa':I), write(' EST':Min), nl,
    print_tasks(RTarefas,RX).

max_workers([],MaxW,Adder):- MaxW is Adder.
max_workers([T|RTrabs],MaxW,Adder) :-
    Adder_ is Adder + T,
    max_workers(RTrabs,MaxW,Adder_).