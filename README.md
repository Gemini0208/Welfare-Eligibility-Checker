# 🏛️ Government Welfare Eligibility Checker

A Prolog-based expert system that determines which government welfare benefits a Sri Lankan citizen is eligible for, based on their household income, age, disability status, education level, and employment status.

Built for **CM2520 - Deductive Reasoning and Logic Programming** using SWI-Prolog with a web-based UI.

---

## 💡 What Does This System Do?

A citizen enters their details — income, age, disability status, education level — and the system automatically:

- ✅ Checks which welfare benefits they qualify for
- 📋 Lists the exact documents they need to submit for each benefit
- 🏢 Shows which government office to submit to

---

## 🎁 Welfare Benefits Covered

| Benefit | Who Qualifies | Scope | Submit To |
|---|---|---|---|
| **Aswesuma** | Low income households (≤ Rs. 25,000/month) | Household | Divisional Secretariat |
| **Samurdhi** | Low income households (≤ Rs. 25,000/month) | Household | Divisional Secretariat |
| **Disability Allowance** | Low income + disabled individuals | Individual | Dept. of Social Services |
| **Elder Allowance** | Low income + aged 60 or above | Individual | Dept. of Social Services |
| **Student Bursary** | Low income + undergraduates or school students | Individual | University Grants Commission |
| **Mahapola** | Low income + undergraduates only | Individual | Mahapola Trust Fund |

### Eligibility Rules at a Glance

- **Income threshold:** Household monthly income must be **Rs. 25,000 or below** for all benefits
- **Government employee rule:** If **any member** of the household is a government employee, **no one** in that household is eligible
- **Student bursary vs Mahapola:** These two are mutually exclusive — receiving one blocks the other
- **Aswesuma vs Samurdhi:** Also mutually exclusive — only one household benefit at a time
- **Household benefits:** Only one person per household can claim Aswesuma or Samurdhi

---

## 🖥️ How to Run

### Prerequisites
Install SWI-Prolog first:
| OS | Command |
|---|---|
| Windows | Download from https://www.swi-prolog.org/download/stable |
| macOS | `brew install swi-prolog` |
| Ubuntu | `sudo apt install swi-prolog` |

---

### Option 1 — Web UI (Recommended)

```bash
# 1. Open a terminal inside the welfare_system folder
cd welfare_system

# 2. Load the server
swipl server.pl

# 3. At the Prolog prompt, type:
start.
```

Then open your browser and go to: **http://localhost:8080**

Press `Ctrl+C` in the terminal to stop the server.

---

### Option 2 — SWI Prolog

```prolog
consult 'Path to main.pl file'.
```
Then at the prompt type:
```prolog
menu.
```

---

## 🗂️ Project Structure

```
welfare_system/
│
├── main.pl           ← CLI entry point
├── server.pl         ← Web UI entry point (HTTP server)
├── index.html        ← Web frontend (served automatically)
│
├── declarations.pl   ← Dynamic predicate declarations
├── facts.pl          ← Knowledge base (benefits, documents, rules)
├── sample_data.pl    ← Sample citizens for testing
├── rules.pl          ← Inference engine (eligibility logic)
├── database.pl       ← Runtime operations (register, update, remove)
├── display.pl        ← Output formatting (CLI)
└── menu.pl           ← CLI menu and input handling
```

### How the files connect

When you run `server.pl`, it loads all other `.pl` files automatically. The browser sends HTTP requests to the Prolog server, which runs the eligibility rules and returns JSON. You never need to run individual files separately.

```
Browser  →  HTTP request  →  server.pl  →  rules.pl / database.pl  →  JSON response  →  Browser
```

---

## 🌐 Web UI Pages

| Page | What it does |
|---|---|
| **Check Eligibility** | Enter a citizen name → get a full benefit report with documents and offices |
| **Register Citizen** | Add a new citizen with their income, age, status, education, and household |
| **Update Income** | Change the household income — updates all members automatically |
| **Mark Received** | Record that a citizen has started receiving a benefit (activates exclusion rules) |
| **Welfare Programs** | View all benefits and who qualifies for each |
| **All Citizens** *(Admin)* | View, filter, and remove all registered citizens |

---

## 🧪 Sample Citizens (Loaded Automatically)

| Name | Age | Income | Household | Notes | Expected Benefits |
|---|---|---|---|---|---|
| kumara | 67 | Rs. 18,000 | h01 | Elderly, low income | Aswesuma, Samurdhi, Elder Allowance |
| nimalka | 35 | Rs. 22,000 | h02 | Disabled, low income | Disability Allowance |
| saman | 42 | Rs. 22,000 | h02 | Normal, same HH as nimalka | Aswesuma / Samurdhi |
| dilani | 20 | Rs. 12,000 | h03 | Undergraduate, low income | Aswesuma, Samurdhi, Mahapola, Student Bursary |
| kasun | 16 | Rs. 15,000 | h05 | School student, low income | Aswesuma, Samurdhi, Student Bursary |
| perera | 55 | Rs. 52,000 | h04 | Income above threshold | None |
| silva | 40 | Rs. 20,000 | h06 | Government employee | None |
| priya | 38 | Rs. 20,000 | h06 | Same household as silva | None (blocked by govt employee rule) |

---

## ⚙️ Prolog Features Used

| Feature | Where Used |
|---|---|
| `assertz` / `retractall` | Adding and removing citizens and benefit records at runtime |
| `setof` | Collecting eligible benefits (deduplicated and sorted) |
| `bagof` | Collecting already-received benefits cleanly |
| `findall` | Gathering documents, citizens, household members |
| `member/2` | Input validation for status, education, and govt employee fields |
| `append/3` | Combining document lists across multiple benefits |
| `delete/3` | Removing duplicate entries from combined document lists |
| `length/2` | Counting eligible benefits for the report summary |
| `call/1` | Higher-order `apply_to_all/2` helper for printing lists |
| `fail` (driven loop) | Iterating over all benefit facts in `list_all_benefits` |
| `cut (!)` | Committing to a branch in registration and menu exit |
| `read/1` / `write/1` | CLI input and output |

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/eligibility?name=X` | Full eligibility report for a citizen |
| `GET` | `/citizens` | List all registered citizens |
| `POST` | `/citizens` | Register a new citizen |
| `DELETE` | `/citizens?name=X` | Remove a citizen |
| `POST` | `/income` | Update household income |
| `POST` | `/receive` | Mark a benefit as received |
| `GET` | `/benefits` | List all welfare programs |

---

## 👨‍💻 Built With

- [SWI-Prolog](https://www.swi-prolog.org/) — logic engine and HTTP server
- Vanilla HTML / CSS / JavaScript — web frontend
- No external frameworks or databases required
