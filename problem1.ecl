:- lib(ic).
:- lib(ic_global).
:- lib(ic_edge_finder).
:- lib(branch_and_bound).

:- compile(ex4).

/*
Para o Eclipse dar
export PATH=${PATH}:/home/unas/Aulas/TerceiroAno/Métodos\ de\ Apoio\ á\ Decisão/bin/x86_64_linux
*/

run(P) :-
    get_data(Tasks,Duration,Workers),
    length(Tasks,NTasks), length(StartDates,NTasks),
    total_duration(Tasks,MaxD),
    writeln(''),
    max_workers(Workers,MaxW,0),
    StartDates#::0..MaxD, EndTime#::0..MaxD, WorkerLimit#::0..MaxW, WorkerLimitEST#::0..MaxW,
    (P = 1 -> get_early_finish(Tasks,StartDates,EndTime);
    P = 2 -> min_es(Tasks,StartDates,Duration,Workers,WorkerLimitEST,EndTime);
    P = 3 -> get_critical_tasks(Tasks,StartDates,Duration,Workers,WorkerLimit,EndTime); 
    P = 4 -> get_start_time(Tasks,StartDates,Duration,Workers,WorkerLimit,EndTime)).

get_early_finish(Tasks,StartDates,EndTime) :-
    get_successors(Tasks,StartDates,EndTime),
    get_es(StartDates),
    get_min(EndTime,EndTime),
    write('Earliest Finish Time: '),writeln(EndTime).

min_es(Tasks,StartDates,Duration,Workers,WorkerLimitEST,EndTime) :-
    get_successors(Tasks,StartDates,EndTime),
    get_es(StartDates),
    cumulative(StartDates,Duration,Workers,WorkerLimitEST),
    get_min(WorkerLimitEST,WorkerLimitEST),
    print_tasks_(Tasks,StartDates),
    writeln(''),
    write('Minimum Workers on EST: '),writeln(WorkerLimitEST).

get_start_time(Tasks,StartDates,Duration,Workers,WorkerLimit,EndTime) :-
    get_successors(Tasks,StartDates,EndTime),
    get_min(EndTime,EndTime),
    cumulative(StartDates,Duration,Workers,WorkerLimit),
    minimize(labeling([WorkerLimit]),WorkerLimit),
    write('Minimum Workers: '),writeln(WorkerLimit),
    writeln(''),
    labeling(StartDates),
    writeln('Optimal Solution:'),
    print_tasks_(Tasks,StartDates).

get_critical_tasks(Tasks,StartDates,Duration,Workers,WorkerLimit,EndTime) :-
    get_successors(Tasks,StartDates,EndTime),
    get_min(EndTime,EndTime),
    cumulative(StartDates,Duration,Workers,WorkerLimit),
    MaxW is get_max(WorkerLimit),
    WorkerLimitCT#::0..MaxW,
    get_critical_n(StartDates,CriticalN,0),
    length(CriticalTasks,CriticalN), length(CriticalStart,CriticalN), length(CriticalDuration,CriticalN), length(CriticalWorkers,CriticalN),
    get_critical(Tasks,StartDates,CriticalTasks, CriticalStart),
    writeln('Critcal Tasks:'),
    print_tasks_(CriticalTasks,CriticalStart),
    writeln(''),
    get_others(CriticalTasks,CriticalDuration,CriticalWorkers),
    labeling([CriticalStart,CriticalDuration,CriticalWorkers]),
    cumulative(CriticalStart,CriticalDuration,CriticalWorkers,WorkerLimitCT),
    get_min(WorkerLimitCT,WorkerLimitCT),
    writeln('Minimum workers on critical tasks':WorkerLimitCT).

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

get_data(Tasks,Duration,Workers) :-
    findall(T,tarefa(T,_,_,_),Tasks),
    findall(D,tarefa(_,_,D,_),Duration),
    findall(W,tarefa(_,_,_,W),Workers).

get_es([]).
get_es([Xi|RX]) :-
    get_min(Xi,Xi),
    get_es(RX).

get_successors([],_,_).
get_successors([T|RTasks],Datas,EndTime) :-
    tarefa(T,Segs,Di,_),
    select_element(1,T,Datas,DataI),
    get_successors_(Segs,Datas,DataI,Di),
    DataI+Di #=< EndTime,
    get_successors(RTasks,Datas,EndTime).

get_successors_([],_,_,_).
get_successors_([J|PSegs],Datas,DataI,Di) :-
    select_element(1,J,Datas,DataJ),
    DataI+Di #=< DataJ,
    get_successors_(PSegs,Datas,DataI,Di).

total_duration([],0).
total_duration([T|RTasks], Total) :-
    tarefa(T,_,Di,_), 
    total_duration(RTasks,Total_), Total is Total_ + Di.

select_element(T,T,[I|_],I) :- !.
select_element(T0,T,[_|R],I) :-  T0n is T0+1, select_element(T0n,T,R,I).

print_tasks([],[]).
print_tasks([I|RTasks], [Xi|RX]) :-
    Min is get_min(Xi),
    write('Task':I), write(' EST':Min), nl,
    print_tasks(RTasks,RX).

print_tasks_([],[]).
print_tasks_([I|RTasks], [Xi|RX]) :-
    write('Task':I), write(' Start Time':Xi), nl,
    print_tasks_(RTasks,RX).

max_workers([],MaxW,Adder):- MaxW is Adder.
max_workers([T|RTrabs],MaxW,Adder) :-
    Adder_ is Adder + T,
    max_workers(RTrabs,MaxW,Adder_).