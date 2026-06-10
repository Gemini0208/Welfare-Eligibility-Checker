% ============================================================
%   facts.pl
%   Static Knowledge Base
% ============================================================

:- ensure_loaded(declarations).


% --- Welfare Benefits ---
% benefit(ID, Name, Authority)
% Income limits removed - filtering done entirely by category rules
benefit(b01, aswesuma,         divisional_secretariat).
benefit(b02, samurdhi,         divisional_secretariat).
benefit(b03, disability_allow, department_of_social_services).
benefit(b04, elder_allowance,  department_of_social_services).
benefit(b05, student_bursary,  university_grants_commission).
benefit(b06, mahapola,         mahapola_trust_fund).


% --- Category Requirements ---
% Every benefit requires low_income as a base condition.
% Additional category requirements are listed separately.
requires_category(b01, low_income).
requires_category(b02, low_income).
requires_category(b03, low_income).
requires_category(b03, disabled).
requires_category(b04, low_income).
requires_category(b04, elderly).
requires_category(b05, low_income).
requires_category(b05, student_eligible).    % undergraduate OR school_student
requires_category(b06, low_income).
requires_category(b06, undergraduate).       % undergraduate only


% --- Benefit Exclusions ---
% Once a benefit is RECEIVED, these pairs block each other
excludes(aswesuma,        samurdhi).
excludes(samurdhi,        aswesuma).
excludes(mahapola,        student_bursary).
excludes(student_bursary, mahapola).


% --- Benefit Scope: household vs individual ---
household_benefit(aswesuma).
household_benefit(samurdhi).
individual_benefit(disability_allow).
individual_benefit(elder_allowance).
individual_benefit(student_bursary).
individual_benefit(mahapola).


% --- Required Documents per Benefit ---
required_doc(aswesuma,         'National ID').
required_doc(aswesuma,         'Income certificate').
required_doc(aswesuma,         'Grama Niladhari letter').
required_doc(samurdhi,         'National ID').
required_doc(samurdhi,         'Family register').
required_doc(samurdhi,         'Income proof').
required_doc(disability_allow, 'National ID').
required_doc(disability_allow, 'Medical certificate').
required_doc(disability_allow, 'Specialist report').
required_doc(elder_allowance,  'National ID').
required_doc(elder_allowance,  'Birth certificate').
required_doc(elder_allowance,  'Bank account details').
required_doc(student_bursary,  'National ID').
required_doc(student_bursary,  'School/University admission letter').
required_doc(student_bursary,  'Income proof').
required_doc(mahapola,         'National ID').
required_doc(mahapola,         'University admission letter').
required_doc(mahapola,         'Mahapola application form').


% --- Valid Input Values ---
valid_status(disabled).
valid_status(not_disabled).
valid_education(undergraduate).
valid_education(school_student).
valid_education(not_student).
valid_govt(govt_employee).
valid_govt(not_govt_employee).
