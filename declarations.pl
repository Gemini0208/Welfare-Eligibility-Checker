% ============================================================
%   declarations.pl
%   Dynamic predicate declarations for the welfare system.
% ============================================================

:- dynamic citizen/7.
    % citizen(Name, Age, MonthlyIncome, Status, Education, GovtEmployee, HouseholdID)
    % Status      : disabled | not_disabled
    % Education   : undergraduate | school_student | not_student
    % GovtEmployee: govt_employee | not_govt_employee
    % HouseholdID : atom identifying which household this person belongs to

:- dynamic already_receiving/2.
    % already_receiving(CitizenName, BenefitName)

:- dynamic benefit/3.
    % benefit(ID, Name, Authority)
    % Income filtering is handled entirely by qualifies_category rules
