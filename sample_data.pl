% ============================================================
%   sample_data.pl
%   Sample citizen records loaded at startup for testing.
% ============================================================

:- ensure_loaded(declarations).

load_sample_data :-
    ( \+ citizen(_, _, _, _, _, _, _) ->
        % h01: kumara - elderly, low income, alone
        assertz(citizen(kumara,   67, 18000, not_disabled, not_student,   not_govt_employee, h01)),
        % h02: nimalka (disabled) and saman - low income household
        assertz(citizen(nimalka,  35, 22000, disabled,     not_student,   not_govt_employee, h02)),
        assertz(citizen(saman,    42, 22000, not_disabled, not_student,   not_govt_employee, h02)),
        % h03: dilani - undergraduate student, low income
        assertz(citizen(dilani,   20, 12000, not_disabled, undergraduate, not_govt_employee, h03)),
        % h04: perera - income too high
        assertz(citizen(perera,   55, 52000, not_disabled, not_student,   not_govt_employee, h04)),
        % h05: kasun - school student, low income
        assertz(citizen(kasun,    16, 15000, not_disabled, school_student,not_govt_employee, h05)),
        % h06: silva - govt employee household, no one eligible
        assertz(citizen(silva,    40, 20000, not_disabled, not_student,   govt_employee,     h06)),
        assertz(citizen(priya,    38, 20000, not_disabled, not_student,   not_govt_employee, h06)),
        write('Sample data loaded.'), nl
    ;
        true
    ).

:- load_sample_data.
