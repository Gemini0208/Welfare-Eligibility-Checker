% ============================================================
%   server.pl
%   HTTP Server - JSON API for the web UI
%   Run: swipl server.pl  then  start.
% ============================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_cors)).

:- ensure_loaded(declarations).
:- ensure_loaded(facts).
:- ensure_loaded(sample_data).
:- ensure_loaded(rules).
:- ensure_loaded(database).

:- set_setting(http:cors, [*]).


% ============================================================
% ROUTES
% ============================================================

:- http_handler(root(.),           handle_index,      []).
:- http_handler(root(citizens),    handle_citizens,   [methods([get,post,delete])]).
:- http_handler(root(eligibility), handle_eligibility,[methods([get])]).
:- http_handler(root(income),      handle_income,     [methods([post])]).
:- http_handler(root(receive),     handle_receive,    [methods([post])]).
:- http_handler(root(benefits),    handle_benefits,   [methods([get])]).


% ============================================================
% SERVE index.html
% ============================================================

handle_index(Request) :-
    http_reply_file('index.html', [], Request).


% ============================================================
% GET /citizens  - list all citizens  (admin view)
% POST /citizens - register a new citizen
% DELETE /citizens?name=X - remove a citizen
% ============================================================

handle_citizens(Request) :-
    memberchk(method(get), Request), !,
    findall(
        citizen{name:N, age:A, income:I, status:S,
                education:E, govt:G, household:H},
        citizen(N, A, I, S, E, G, H),
        Citizens
    ),
    reply_json_dict(json{status:ok, citizens:Citizens}).

handle_citizens(Request) :-
    memberchk(method(post), Request), !,
    http_read_json_dict(Request, Body),
    atom_string(Name,   Body.name),
    atom_string(Status, Body.status),
    atom_string(Edu,    Body.education),
    atom_string(Govt,   Body.govt),
    atom_string(HID,    Body.household),
    Age    = Body.age,
    Income = Body.income,
    % member/2: validate all enum inputs
    ( member(Status, [disabled, not_disabled]) -> true ;
        reply_json_dict(json{status:error, message:"Invalid status"}), ! ),
    ( member(Edu, [undergraduate, school_student, not_student]) -> true ;
        reply_json_dict(json{status:error, message:"Invalid education value"}), ! ),
    ( member(Govt, [govt_employee, not_govt_employee]) -> true ;
        reply_json_dict(json{status:error, message:"Invalid govt employee value"}), ! ),
    ( citizen(Name, _, _, _, _, _, _) ->
        reply_json_dict(json{status:error, message:"Citizen already registered"})
    ; violates_household_rule(Name, Age, Income, Status, Edu, HID) ->
        reply_json_dict(json{status:error,
            message:"Registration blocked: another normal member already registered in this household"})
    ;
        ( citizen(_, _, ExistingIncome, _, _, _, HID) ->
            ActualIncome = ExistingIncome
        ;
            ActualIncome = Income
        ),
        assertz(citizen(Name, Age, ActualIncome, Status, Edu, Govt, HID)),
        reply_json_dict(json{status:ok, message:"Citizen registered successfully"})
    ).

handle_citizens(Request) :-
    memberchk(method(delete), Request), !,
    http_parameters(Request, [name(NameStr, [])]),
    atom_string(Name, NameStr),
    ( citizen(Name, _, _, _, _, _, _) ->
        retractall(citizen(Name, _, _, _, _, _, _)),
        retractall(already_receiving(Name, _)),
        reply_json_dict(json{status:ok, message:"Citizen removed"})
    ;
        reply_json_dict(json{status:error, message:"Citizen not found"})
    ).


% ============================================================
% GET /eligibility?name=X
% ============================================================

handle_eligibility(Request) :-
    http_parameters(Request, [name(NameStr, [])]),
    atom_string(Name, NameStr),
    ( \+ citizen(Name, _, _, _, _, _, _) ->
        reply_json_dict(json{status:error, message:"Citizen not found"})
    ;
        citizen(Name, Age, Income, Status, Edu, Govt, HID),
        % Check govt employee block
        ( household_has_govt_employee(HID) ->
            reply_json_dict(json{
                status:         ok,
                name:           Name,
                age:            Age,
                income:         Income,
                citizen_status: Status,
                education:      Edu,
                govt:           Govt,
                household:      HID,
                blocked:        true,
                block_reason:   "A member of this household is a government employee",
                benefit_count:  0,
                benefits:       [],
                receiving:      []
            })
        ;
            all_eligible(Name, Benefits),
            length(Benefits, Count),
            maplist(benefit_detail, Benefits, BenefitDetails),
            ( bagof(B, already_receiving(Name, B), Received) -> true ; Received = [] ),
            reply_json_dict(json{
                status:         ok,
                name:           Name,
                age:            Age,
                income:         Income,
                citizen_status: Status,
                education:      Edu,
                govt:           Govt,
                household:      HID,
                blocked:        false,
                benefit_count:  Count,
                benefits:       BenefitDetails,
                receiving:      Received
            })
        )
    ).

benefit_detail(B, Dict) :-
    benefit(_, B, Office),
    findall(Doc, required_doc(B, Doc), Docs),
    ( household_benefit(B) -> Scope = household ; Scope = individual ),
    atom_string(B,      BStr),
    atom_string(Office, OStr),
    atom_string(Scope,  SStr),
    maplist(atom_string, Docs, DocStrs),
    Dict = benefit{name:BStr, office:OStr, scope:SStr, documents:DocStrs}.


% ============================================================
% POST /income  { name, income }
% ============================================================

handle_income(Request) :-
    http_read_json_dict(Request, Body),
    atom_string(Name, Body.name),
    Income = Body.income,
    ( citizen(Name, _, _, _, _, _, HID) ->
        findall(citizen(N,A,_,S,E,G,HID), citizen(N,A,_,S,E,G,HID), Members),
        retractall(citizen(_,_,_,_,_,_,HID)),
        assert_updated_members(Members, Income),
        reply_json_dict(json{status:ok, message:"Household income updated"})
    ;
        reply_json_dict(json{status:error, message:"Citizen not found"})
    ).


% ============================================================
% POST /receive  { name, benefit }
% ============================================================

handle_receive(Request) :-
    http_read_json_dict(Request, Body),
    atom_string(Name,    Body.name),
    atom_string(Benefit, Body.benefit),
    ( \+ citizen(Name, _, _, _, _, _, _) ->
        reply_json_dict(json{status:error, message:"Citizen not found"})
    ; already_receiving(Name, Benefit) ->
        reply_json_dict(json{status:error, message:"Already marked as received"})
    ;
        assertz(already_receiving(Name, Benefit)),
        reply_json_dict(json{status:ok, message:"Benefit marked as received"})
    ).


% ============================================================
% GET /benefits
% ============================================================

handle_benefits(Request) :-
    memberchk(method(get), Request), !,
    findall(
        benefit{id:ID, name:N, authority:A, scope:Sc},
        (   benefit(ID, N, A),
            ( household_benefit(N) -> Sc = household ; Sc = individual )
        ),
        Benefits
    ),
    reply_json_dict(json{status:ok, benefits:Benefits}).


% ============================================================
% START
% ============================================================

start :-
    http_server(http_dispatch, [port(8080)]),
    write('Server running on http://localhost:8080'), nl,
    write('Press Ctrl+C to stop.'), nl,
    thread_get_message(_).

:- write('=============================================='), nl,
   write('  Welfare Eligibility Server'), nl,
   write('  Type   start.   to launch on port 8080'), nl,
   write('=============================================='), nl.
