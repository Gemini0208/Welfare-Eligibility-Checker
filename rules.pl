% ============================================================
%   rules.pl
%   Inference Rules
% ============================================================

:- ensure_loaded(declarations).
:- ensure_loaded(facts).


% ============================================================
% CATEGORY RULES
% ============================================================

% Low income threshold: household income <= 25000
qualifies_category(Person, low_income) :-
    citizen(Person, _, Income, _, _, _, _),
    Income =< 25000.

qualifies_category(Person, elderly) :-
    citizen(Person, Age, _, _, _, _, _),
    Age >= 60.

qualifies_category(Person, disabled) :-
    citizen(Person, _, _, disabled, _, _, _).

% undergraduate: enrolled in a university/higher education
qualifies_category(Person, undergraduate) :-
    citizen(Person, _, _, _, undergraduate, _, _).

% school_student: enrolled in school (A/L, O/L etc.)
qualifies_category(Person, school_student) :-
    citizen(Person, _, _, _, school_student, _, _).

% student_eligible: covers both undergraduate and school_student
% Used for student_bursary which accepts both
qualifies_category(Person, student_eligible) :-
    citizen(Person, _, _, _, Edu, _, _),
    member(Edu, [undergraduate, school_student]).   % member/2 validation


% ============================================================
% GOVERNMENT EMPLOYEE HOUSEHOLD BLOCK
% If ANY member of the household is a govt employee,
% nobody in that household is eligible for any benefit
% ============================================================

household_has_govt_employee(HID) :-
    citizen(_, _, _, _, _, govt_employee, HID).


% ============================================================
% HOUSEHOLD RULES
% ============================================================

household_of(Person, HID) :-
    citizen(Person, _, _, _, _, _, HID).

household_has_normal_person(HID) :-
    citizen(_, Age, _, Status, Edu, _, HID),
    \+ special_category_check(Status, Age, Edu).

household_benefit_covered(Person, Benefit) :-
    household_benefit(Benefit),
    household_of(Person, HID),
    citizen(OtherPerson, _, _, _, _, _, HID),
    OtherPerson \= Person,
    already_receiving(OtherPerson, Benefit).

should_show_household_benefit(Person, Benefit) :-
    household_benefit(Benefit),
    household_of(Person, HID),
    citizen(Person, Age, _, Status, Edu, _, HID),
    \+ special_category_check(Status, Age, Edu),
    \+ household_benefit_covered(Person, Benefit).

should_show_household_benefit(Person, Benefit) :-
    household_benefit(Benefit),
    household_of(Person, HID),
    citizen(Person, Age, _, Status, Edu, _, HID),
    special_category_check(Status, Age, Edu),
    \+ household_has_normal_person(HID),
    \+ household_benefit_covered(Person, Benefit).

% special-category: disabled, elderly, or any kind of student
special_category_check(disabled, _, _).
special_category_check(_, Age, _)  :- Age >= 60.
special_category_check(_, _, undergraduate).
special_category_check(_, _, school_student).


% ============================================================
% HOUSEHOLD REGISTRATION RULE
% ============================================================

violates_household_rule(Name, Age, _Income, Status, Education, HID) :-
    \+ special_category_check(Status, Age, Education),
    citizen(Other, OtherAge, _, OtherStatus, OtherEducation, _, HID),
    Other \= Name,
    \+ special_category_check(OtherStatus, OtherAge, OtherEducation).


% ============================================================
% CORE ELIGIBILITY RULES
% ============================================================

conflicts_with_existing(Person, NewBenefit) :-
    already_receiving(Person, Existing),
    excludes(NewBenefit, Existing).

% A benefit requires ALL its listed categories to be satisfied.
% Uses findall + maplist to check every required category.
all_categories_met(Person, BID) :-
    findall(Cat, requires_category(BID, Cat), Cats),
    maplist(qualifies_category(Person), Cats).   % maplist with call internally

eligible(Person, BenefitName) :-
    benefit(BID, BenefitName, _),
    citizen(Person, _, _, _, _, _, HID),
    % Block entire household if any member is a govt employee
    \+ household_has_govt_employee(HID),
    all_categories_met(Person, BID),
    \+ conflicts_with_existing(Person, BenefitName),
    ( household_benefit(BenefitName) ->
        should_show_household_benefit(Person, BenefitName)
    ;
        true
    ).

% setof deduplicates and sorts; second clause handles no-results
all_eligible(Person, UniqueB) :-
    setof(B, eligible(Person, B), UniqueB), !.
all_eligible(_, []).


% ============================================================
% DOCUMENT HELPERS
% ============================================================

% collect_all_docs uses append/3 to join each benefit's doc list
collect_all_docs([], []).
collect_all_docs([B|Rest], AllDocs) :-
    findall(Doc, required_doc(B, Doc), Docs),
    collect_all_docs(Rest, RestDocs),
    append(Docs, RestDocs, AllDocs).    % append/3: concatenate lists
