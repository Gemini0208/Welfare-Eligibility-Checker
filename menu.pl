% ============================================================
%   menu.pl
%   CLI Menu
% ============================================================

:- ensure_loaded(declarations).
:- ensure_loaded(database).
:- ensure_loaded(display).


menu :-
    nl,
    write('============================================'), nl,
    write('   GOVERNMENT WELFARE ELIGIBILITY CHECKER  '), nl,
    write('============================================'), nl,
    write(' 1. Check eligibility for a citizen        '), nl,
    write(' 2. Register a new citizen                 '), nl,
    write(' 3. Update total household income          '), nl,
    write(' 4. Mark benefit as received               '), nl,
    write(' 5. Remove a citizen record                '), nl,
    write(' 6. View all welfare programs              '), nl,
    write(' 0. Exit                                   '), nl,
    write('============================================'), nl,
    write('Choose an option: '),
    read(Choice),
    handle_choice(Choice),
    ( Choice \= 0 -> menu ; true ).

% Admin menu - separate from main user menu
admin_menu :-
    nl,
    write('============================================'), nl,
    write('   ADMIN VIEW                              '), nl,
    write('============================================'), nl,
    write(' 1. View all registered citizens           '), nl,
    write(' 0. Back                                   '), nl,
    write('============================================'), nl,
    write('Choose an option: '),
    read(Choice),
    handle_admin_choice(Choice),
    ( Choice \= 0 -> admin_menu ; true ).

handle_admin_choice(0) :- write('Returning to main menu.'), nl, !.
handle_admin_choice(1) :- list_all_citizens.
handle_admin_choice(_) :- write('Invalid option.'), nl.

% CUT (!) prevents menu loop backtracking on exit
handle_choice(0) :-
    write('Goodbye.'), nl, !.

handle_choice(1) :-
    write('Enter citizen name: '), read(Name),
    ( citizen(Name, _, _, _, _, _, _) ->
        print_eligibility_report(Name)
    ;
        write('Citizen not found. Please register first.'), nl
    ).

handle_choice(2) :-
    write('Enter name: '), read(Name),
    write('Enter age: '), read(Age),
    write('Enter total household monthly income (Rs.): '), read(Income),
    write('Enter disability status (disabled/not_disabled): '), read(Status),
    ( member(Status, [disabled, not_disabled]) ->    % member/2: input validation
        true
    ;
        write('Invalid. Must be disabled or not_disabled.'), nl, fail
    ),
    write('Enter education (undergraduate/school_student/not_student): '), read(Edu),
    ( member(Edu, [undergraduate, school_student, not_student]) ->
        true
    ;
        write('Invalid. Must be undergraduate, school_student, or not_student.'), nl, fail
    ),
    write('Is any household member a government employee? (govt_employee/not_govt_employee): '), read(Govt),
    ( member(Govt, [govt_employee, not_govt_employee]) ->
        true
    ;
        write('Invalid. Must be govt_employee or not_govt_employee.'), nl, fail
    ),
    write('Enter household ID (e.g. h01, h02 ...): '), read(HID),
    register_citizen(Name, Age, Income, Status, Edu, Govt, HID).

handle_choice(3) :-
    write('Enter citizen name: '), read(Name),
    write('Enter new total household monthly income: '), read(Income),
    update_income(Name, Income).

handle_choice(4) :-
    write('Enter citizen name: '), read(Name),
    write('Enter benefit name (e.g. mahapola.): '), read(Benefit),
    mark_receiving(Name, Benefit).

handle_choice(5) :-
    write('Enter citizen name to remove: '), read(Name),
    remove_citizen(Name).

handle_choice(6) :-
    list_all_benefits.

handle_choice(_) :-
    write('Invalid option. Please try again.'), nl.
