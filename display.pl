% ============================================================
%   display.pl
%   Display Helpers
% ============================================================

:- ensure_loaded(declarations).
:- ensure_loaded(facts).
:- ensure_loaded(rules).


% ============================================================
% UTILITY
% ============================================================

divider :-
    write('--------------------------------------------'), nl.

% apply_to_all/2: higher-order predicate using call/1.
apply_to_all(_, []).
apply_to_all(Goal, [H|T]) :-
    call(Goal, H),
    apply_to_all(Goal, T).


% ============================================================
% ELIGIBILITY REPORT
% ============================================================

print_eligibility_report(Person) :-
    nl,
    write('============================================'), nl,
    write('   WELFARE ELIGIBILITY REPORT'), nl,
    write('   Citizen: '), write(Person), nl,
    write('============================================'), nl,
    % Check govt employee block first
    household_of(Person, HID),
    ( household_has_govt_employee(HID) ->
        write('  NOT ELIGIBLE: A member of this household is a government employee.'), nl
    ;
        all_eligible(Person, Benefits),
        length(Benefits, Count),     % length/2: count eligible benefits
        write('   Eligible benefits found: '), write(Count), nl,
        ( Benefits = [] ->
            write('  No eligible benefits found.'), nl
        ;
            print_eligible_benefits(Benefits)
        ),
        nl,
        print_received_benefits(Person)
    ),
    write('============================================'), nl.

print_eligible_benefits([]).
print_eligible_benefits([B|Rest]) :-
    nl,
    write('  ELIGIBLE: '), write(B), nl,
    benefit(_, B, Office),
    write('  Submit to   : '), write(Office), nl,
    write('  Documents   : '), nl,
    findall(Doc, required_doc(B, Doc), Docs),
    apply_to_all(print_doc_item, Docs),
    ( household_benefit(B) ->
        write('  Scope       : Household benefit'), nl
    ;
        write('  Scope       : Individual benefit'), nl
    ),
    print_eligible_benefits(Rest).

print_doc_item(D) :-
    write('      - '), write(D), nl.

print_received_item(B) :-
    write('      - '), write(B), nl.


% ============================================================
% RECEIVED BENEFITS  (bagof: fails cleanly when none)
% ============================================================

print_received_benefits(Person) :-
    ( bagof(B, already_receiving(Person, B), Received) ->
        nl,
        write('  ALREADY RECEIVING:'), nl,
        apply_to_all(print_received_item, Received)
    ;
        true
    ).


% ============================================================
% LIST ALL BENEFITS  (fail-driven loop)
% ============================================================

list_all_benefits :-
    nl, write('=== ALL WELFARE PROGRAMS ==='), nl, nl,
    benefit(_, Name, Authority),
    write('  Benefit    : '), write(Name), nl,
    write('  Submit to  : '), write(Authority), nl,
    ( household_benefit(Name) ->
        write('  Scope      : Household'), nl
    ;
        write('  Scope      : Individual'), nl
    ),
    divider,
    fail.
list_all_benefits.


% ============================================================
% LIST ALL CITIZENS
% ============================================================

list_all_citizens :-
    nl, write('=== REGISTERED CITIZENS ==='), nl,
    findall(
        Name-Age-Income-Status-Edu-Govt-HID,
        citizen(Name, Age, Income, Status, Edu, Govt, HID),
        Citizens
    ),
    ( Citizens = [] ->
        write('No citizens registered.'), nl
    ;
        print_citizens(Citizens)
    ).

print_citizens([]).
print_citizens([Name-Age-Income-Status-Edu-Govt-HID|Rest]) :-
    write('  Name         : '), write(Name), nl,
    write('  Age          : '), write(Age), nl,
    write('  Income       : Rs.'), write(Income), nl,
    write('  Status       : '), write(Status), nl,
    write('  Education    : '), write(Edu), nl,
    write('  Govt Employee: '), write(Govt), nl,
    write('  Household    : '), write(HID), nl,
    divider,
    print_citizens(Rest).
