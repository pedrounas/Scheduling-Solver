:- lib(ic).
:- lib(ic_global).
:- lib(ic_edge_finder).
:- lib(branch_and_bound).

:- compile(p2_ex2).

run :-
    get_data(Tasks,Deadline),
    length(Tasks,NTasks), length(StartDates,NTasks),
    total_duration(Tasks,MaxD),
    writeln(''),
    get_deadline(Deadline,DDay,DMonth),
    StartDates#::[8..11,13..MaxD], EndTime#::[8..11,13..MaxD],
    get_successors(Tasks,StartDates,EndTime),
    get_es(StartDates),
    sorted(Tasks,OrderedTasks),
    writeln('Deadline':DDay/DMonth),
    print_tasks_(OrderedTasks,StartDates,1,8),
    writeln('').

get_successors([],_,_).
get_successors([T|RTasks],Datas,EndTime) :-
    tarefa(T,Segs,Di,_,0),
    select_element(1,T,Datas,DataI),
    get_successors_(Segs,Datas,DataI,Di),
    DataI+Di #=< EndTime,
    get_successors(RTasks,Datas,EndTime).

get_successors_([],_,_,_).
get_successors_([J|PSegs],Datas,DataI,Di) :-
    select_element(1,J,Datas,DataJ),
    DataI+Di #=< DataJ,
    get_successors_(PSegs,Datas,DataI,Di).

get_es([]).
get_es([Xi|RX]) :-
    get_min(Xi,Xi),
    get_es(RX).

get_data(Tasks,Deadline) :-
    findall(T,tarefa(T,_,_,_,0),Tasks),
    findall(De,prazo(De),Deadline).

total_duration([],0).
total_duration([T|RTasks], Total) :-
    tarefa(T,_,Di,_,0), 
    total_duration(RTasks,Total_), Total is Total_ + Di.

print_tasks_([],[],_,_).
print_tasks_([I|RTasks], [Xi|RX], CurrDay, CurrTime) :-
    tarefa(I,_,D,_,_),
    (Xi + D > 17 * CurrDay -> CurrDay_ is CurrDay + 1, Flag is 1; 
    Xi + D =< 17 * CurrDay -> CurrDay_ is CurrDay, Flag is 0),
    (Xi = 8 -> print_first(I,Xi); Flag is 1 -> print_others(I,CurrDay_,CurrTime); print_others(I,CurrDay_,Xi)),
    print_tasks_(RTasks,RX, CurrDay_, CurrTime).

print_first(I,Start) :-
    calendario(Calen),
    find_days(Calen,Days),
    find_months(Calen,Months),
    element(1,Days,D),
    element(1,Months,M),
    write('Task':I), write(' Start Date':D/M), write(' at':Start), nl.

print_others(I,CurrDay,CurrTime) :-
    calendario(Calen),
    find_days(Calen,Days),
    find_months(Calen,Months),
    element(CurrDay,Days,D),
    element(CurrDay,Months,M),
    write('Task':I), write(' Start Date':D/M), write(' at':CurrTime), nl.

get_deadline(D,Dd,Dm) :-
    find_days(D,Aux),
    find_months(D,Aux_),
    element(1,Aux,Dd),
    element(1,Aux_,Dm).

find_days([],[]).
find_days([d(D,_,_)|RC],[D|RD]) :-
    find_days(RC,RD).

find_months([],[]).
find_months([d(_,M,_)|RC],[M|RM]) :-
    find_months(RC,RM).

select_element(T,T,[I|_],I) :- !.
select_element(T0,T,[_|R],I) :-  T0n is T0+1, select_element(T0n,T,R,I).