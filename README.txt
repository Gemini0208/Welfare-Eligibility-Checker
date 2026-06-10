
GOVERNMENT WELFARE ELIGIBILITY CHECKER
CM2520 - Deductive Reasoning and Logic Programming
========================================================

PROJECT STRUCTURE
-----------------

welfare_system/
  declarations.pl   - dynamic predicate declarations (:- dynamic)
  facts.pl          - static knowledge base (benefits, documents, rules)
  sample_data.pl    - sample citizens loaded at startup for testing
  rules.pl          - inference rules (eligibility, category, household)
  database.pl       - runtime KB operations (register, update, remove)
  display.pl        - CLI output formatting and report printing
  menu.pl           - CLI menu loop and input handlers
  main.pl           - CLI entry point  (load this for the text interface)
  server.pl         - HTTP server + JSON API  (load this for the web UI)
  index.html        - web frontend  (opened automatically via server.pl)


HOW TO RUN - OPTION 1: Command-Line Interface (CLI)
----------------------------------------------------
Requirements: SWI-Prolog installed

1. Open a terminal
2. cd into the welfare_system folder
3. Run:
       swipl main.pl
4. At the prompt type:
       menu.
5. Use the numbered menu options


HOW TO RUN - OPTION 2: Web UI (recommended)
--------------------------------------------
Requirements: SWI-Prolog installed

1. Open a terminal
2. cd into the welfare_system folder
3. Run:
       swipl server.pl
4. At the prompt type:
       start.
5. You will see:
       Server running on http://localhost:8080
6. Open your browser and go to:
       http://localhost:8080
7. The web interface loads automatically.

To stop the server: press Ctrl+C in the terminal.


INSTALL SWI-PROLOG
------------------
Windows : https://www.swi-prolog.org/download/stable
macOS   : brew install swi-prolog
Ubuntu  : sudo apt install swi-prolog


WEB UI PAGES
------------
Check Eligibility    - enter a citizen name and see full benefit report
Citizens             - table of all registered citizens with quick actions
Register Citizen     - form to add a new citizen
Update Income        - update household income (applies to all members)
Mark Received        - record that a citizen has started receiving a benefit
Welfare Programs     - all benefits in the knowledge base
Add Benefit          - dynamically add a new government benefit
Doc Checklist        - master document list across all eligible benefits


API ENDPOINTS (for reference)
------------------------------
GET    /citizens              list all citizens
POST   /citizens              register a citizen  { name, age, income, status, education, household }
DELETE /citizens?name=X       remove a citizen
GET    /eligibility?name=X    full eligibility report
POST   /income                update income  { name, income }
POST   /receive               mark benefit received  { name, benefit }
GET    /benefits              list all benefits
POST   /benefits              add a benefit  { id, name, min_family, max_income, authority }
GET    /docs?name=X           master document checklist


SAMPLE DATA (loaded automatically)
-----------------------------------
Name     Age  Income   Household  Notes
kumara   67   18000    h01        Elderly, qualifies for elder_allowance + aswesuma
nimalka  35   22000    h02        Disabled, qualifies for disability_allow + aswesuma
saman    42   22000    h02        Same household as nimalka
dilani   20   12000    h03        Student, qualifies for mahapola + student_bursary + aswesuma
perera   55   52000    h04        Income too high for most benefits
