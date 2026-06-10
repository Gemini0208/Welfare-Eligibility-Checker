% ============================================================
%   database.pl
%   Dynamic Knowledge Base Operations
% ============================================================

:- ensure_loaded(declarations).
:- ensure_loaded(rules).


% ============================================================
% REGISTER A NEW CITIZEN
% CUT (!) after each branch ensures only one branch fires
% ============================================================

register_citizen(Name, Age, IncomeInput, Status, Education, GovtEmp, HID) :-
    ( citizen(Name, _, _, _, _, _, _) ->
        write('This person is already registered.'), nl, !
    ; violates_household_rule(Name, Age, IncomeInput, Status, Education, HID) ->
        write('Registration blocked: another normal member of this household is already registered.'), nl, !
    ;
        ( citizen(_, _, ExistingHouseholdIncome, _, _, _, HID) ->
            ActualIncome = ExistingHouseholdIncome
        ;
            ActualIncome = IncomeInput
        ),
        assertz(citizen(Name, Age, ActualIncome, Status, Education, GovtEmp, HID)),
        write('Citizen registered successfully.'), nl
    ).


% ============================================================
% UPDATE HOUSEHOLD INCOME
% ============================================================

update_income(Person, NewIncome) :-
    ( citizen(Person, _, _, _, _, _, HID) ->
        findall(citizen(N,A,_,S,E,G,HID), citizen(N,A,_,S,E,G,HID), Members),
        retractall(citizen(_,_,_,_,_,_,HID)),
        assert_updated_members(Members, NewIncome),
        write('Household income updated for all members.'), nl
    ;
        write('Citizen not found.'), nl
    ).

assert_updated_members([], _).
assert_updated_members([citizen(N,A,_,S,E,G,HID)|Rest], NewIncome) :-
    assertz(citizen(N, A, NewIncome, S, E, G, HID)),
    assert_updated_members(Rest, NewIncome).


% ============================================================
% MARK A BENEFIT AS RECEIVED
% ============================================================

mark_receiving(Person, Benefit) :-
    ( \+ citizen(Person, _, _, _, _, _, _) ->
        write('Citizen not found.'), nl
    ; already_receiving(Person, Benefit) ->
        write('This benefit is already marked as received.'), nl
    ;
        assertz(already_receiving(Person, Benefit)),
        write('Benefit marked as received: '), write(Benefit), nl
    ).


% ============================================================
% REMOVE A CITIZEN RECORD
% ============================================================

remove_citizen(Name) :-
    ( citizen(Name, _, _, _, _, _, _) ->
        retractall(citizen(Name, _, _, _, _, _, _)),
        retractall(already_receiving(Name, _)),
        write('Citizen record removed.'), nl
    ;
        write('Citizen not found.'), nl
    ).
