% ============================================================
%   main.pl
%   Entry Point - load this file to start the system.
%
%   File structure:
%     declarations.pl  - dynamic predicate declarations
%     facts.pl         - static knowledge base (benefits, docs, rules)
%     sample_data.pl   - sample citizen records for testing
%     rules.pl         - inference rules (eligibility, household, categories)
%     database.pl      - runtime KB operations (register, update, remove)
%     display.pl       - output formatting and report generation
%     menu.pl          - CLI menu loop and input handling
%
%   Usage:
%     swipl main.pl
%     ?- menu.
% ============================================================

:- ensure_loaded(declarations).
:- ensure_loaded(facts).
:- ensure_loaded(sample_data).
:- ensure_loaded(rules).
:- ensure_loaded(database).
:- ensure_loaded(display).
:- ensure_loaded(menu).

:- write('============================================'), nl,
   write('  Welfare Eligibility System loaded.'), nl,
   write('  Type   menu.   to start.'), nl,
   write('============================================'), nl.
