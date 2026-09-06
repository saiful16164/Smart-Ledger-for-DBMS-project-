# Software Requirements Specification (SRS)
## Smart Ledger — Integrated Financial Management Platform
**Version:** 1.0  
**Date:** May 11, 2026  
**Status:** Draft  

---

## Table of Contents
1. Introduction  
2. Overall Description  
3. Specific Requirements
    - 3.1 Functional Requirements  
    - 3.2 Non-Functional Requirements  
    - 3.3 Use Cases  
    - 3.4 External Interface Requirements  
    - 3.5 Data Requirements  
    - 3.6 Additional Constraints  
    - 3.7 Security Requirements  
    - 3.8 Acceptance Criteria  
4. Appendix  

---

# 1. Introduction

## 1.1 Purpose
This Software Requirements Specification (SRS) document describes the complete functional and non-functional requirements for **Smart Ledger**, a cloud-based, cross-platform financial management application. It serves as the formal agreement between stakeholders (clients, developers, testers, and project managers) and defines what the system must do before any implementation decisions are finalized.

## 1.2 Scope
Smart Ledger is a premium financial management platform targeting small-to-medium enterprises (SMEs) and professional contractors. It replaces fragmented spreadsheets and manual ledger books with a unified, automated system. The platform covers:

- User authentication and role-based access
- Client and account receivable management
- Cashbook and unified ledger (double-entry bookkeeping)
- Transaction entry, categorization, and batch upload
- Financial reporting (Balance Sheet, P&L, Cash Flow)
- Settings, user management, and system configuration

**Out of Scope (v1.0):** AI-powered forecasting, blockchain integration, payroll module, intercompany settlement automation.

## 1.3 Objectives
- Reduce manual bookkeeping overhead by 70–80%
- Achieve 99.9% accuracy in transaction recording
- Provide real-time financial dashboards across Web, Android, iOS, and Desktop
- Ensure enterprise-grade security (encryption, MFA, RBAC)
- Enable month-end close in 1–2 days instead of 5–10 days

## 1.4 Definitions and Acronyms

| Term | Definition |
|------|-----------|
| SRS | Software Requirements Specification |
| SME | Small-to-Medium Enterprise |
| RBAC | Role-Based Access Control |
| RLS | Row-Level Security (Supabase/PostgreSQL feature) |
| MFA | Multi-Factor Authentication |
| P&L | Profit & Loss Statement |
| GAAP | Generally Accepted Accounting Principles |
| IFRS | International Financial Reporting Standards |
| MRR | Monthly Recurring Revenue |
| KPI | Key Performance Indicator |
| OCR | Optical Character Recognition |
| SSO | Single Sign-On |
| TLS | Transport Layer Security |
| AES | Advanced Encryption Standard |
| JWT | JSON Web Token |
| API | Application Programming Interface |
| REST | Representational State Transfer |

## 1.5 Intended Audience
- **Project Team:** Flutter developers, backend engineers, QA testers
- **Stakeholders:** Product owners, enterprise clients, finance managers
- **Testers:** QA engineers validating functional and non-functional requirements
- **Auditors:** Compliance officers verifying regulatory alignment

## 1.6 References
- Smart Ledger Project Proposal v1.0 (`Project_Proposal.md`)
- Flutter SDK Documentation (https://flutter.dev/docs)
- Supabase Documentation (https://supabase.com/docs)
- GAAP Accounting Standards
- IFRS Standards
- OWASP Top 10 Security Guidelines
- WCAG 2.1 Accessibility Guidelines

---

# 2. Overall Description

## 2.1 Product Perspective
Smart Ledger is a standalone cloud-native SaaS application. It does not replace an entire ERP system but integrates with third-party services (banks, payment gateways, CRMs) via REST APIs. All client data is stored in a Supabase-managed PostgreSQL database with Row-Level Security to ensure full multi-tenant data isolation.

```
┌─────────────────────────────────────────┐
│              Smart Ledger App            │
│  (Flutter: Web / Android / iOS / Desktop)│
└────────────────┬────────────────────────┘
                 │ HTTPS / WebSocket
┌────────────────▼────────────────────────┐
│            Supabase Backend              │
│  ┌───────────┐  ┌───────────────────┐   │
│  │ Auth (JWT)│  │ PostgreSQL + RLS   │   │
│  └───────────┘  └───────────────────┘   │
│  ┌───────────┐  ┌───────────────────┐   │
│  │  Storage  │  │  Realtime (WS)    │   │
│  └───────────┘  └───────────────────┘   │
└─────────────────────────────────────────┘
```

## 2.2 Product Functions (Summary)
| # | Function |
|---|----------|
| F1 | User Registration, Login, MFA |
| F2 | Executive Dashboard with KPIs |
| F3 | Client & Account Receivable Management |
| F4 | Cashbook & Double-Entry Ledger |
| F5 | Transaction Entry & Batch Upload |
| F6 | Financial Reporting & Export |
| F7 | Settings & Role/Permission Management |

## 2.3 User Classes and Characteristics

| Role | Description | Access Level |
|------|-------------|-------------|
| **Administrator** | Full system access; manages users, config, audit logs | Full |
| **Finance Manager** | Access all financial modules; approve transactions | High |
| **Accountant** | Enter transactions, reconcile, generate reports | Medium |
| **Executive/Viewer** | Read-only dashboard and summary reports | Read-only |
| **Client/Vendor** | View own invoices and account balance via portal | Restricted |
| **Department Manager** | View and manage departmental budgets only | Scoped |

## 2.4 Operating Environment
- **Client Platforms:** Android 10+, iOS 14+, Web (Chrome/Firefox/Edge latest), Windows 10+, macOS 11+
- **Backend:** Supabase (PostgreSQL 15), hosted on cloud (AWS/GCP regions)
- **Framework:** Flutter 3.x (Dart SDK ^3.8.1)
- **State Management:** Riverpod 2.x
- **Navigation:** GoRouter 14.x
- **Internet:** Required for all real-time features; partial offline support on mobile

## 2.5 Constraints
- Must use Flutter as the cross-platform framework
- Must use Supabase as the backend-as-a-service
- All financial logic must comply with GAAP/IFRS double-entry rules
- Passwords must never be stored in plaintext
- The system must operate within Supabase free/pro tier limits for the academic phase
- Development timeline: Academic semester constraint (approx. 8 weeks)

## 2.6 Assumptions and Dependencies
- Users have a stable internet connection for real-time sync
- Supabase services remain available (SLA 99.9%)
- Flutter SDK and Supabase Flutter SDK are actively maintained
- Users have basic accounting literacy (understanding of debit/credit)
- Organization has valid email addresses for all users

---

# 3. Specific Requirements
    - 3.1 Functional Requirements

> Each requirement is labeled **FR-[Module]-[Number]** for traceability.

---

### 3.1.1 Authentication Module (FR-AUTH)

### FR-AUTH-01: User Registration
- **Input:** Full name, email address, password, organization name
- **Processing:** Validate email format; enforce password strength (min 8 chars, 1 uppercase, 1 number, 1 special character); create user record in `auth.users` via Supabase Auth; create corresponding profile in `public.profiles`
- **Output:** Confirmation email sent; user redirected to onboarding screen
- **Conditions:** Email must be unique in the system

### FR-AUTH-02: User Login
- **Input:** Email address, password
- **Processing:** Validate credentials via Supabase Auth; generate JWT token; load user role and permissions; initialize session
- **Output:** User redirected to role-appropriate dashboard
- **Conditions:** If credentials are invalid, display error "Invalid email or password." Lock account after 5 consecutive failures for 15 minutes

### FR-AUTH-03: Multi-Factor Authentication (MFA)
- **Input:** TOTP code from authenticator app (Google Authenticator / Authy)
- **Processing:** Verify TOTP against stored secret; extend session on success
- **Output:** Session fully authenticated; access granted
- **Conditions:** MFA is optional during beta; admin can enforce MFA org-wide

### FR-AUTH-04: Password Reset
- **Input:** Registered email address
- **Processing:** Send password reset link via Supabase Auth email; link expires in 60 minutes
- **Output:** User can set a new password; old sessions invalidated
- **Conditions:** Link is single-use

### FR-AUTH-05: Session Management
- **Input:** User activity / inactivity
- **Processing:** Auto-logout after 30 minutes of inactivity; refresh JWT token on active use
- **Output:** Session terminated; user redirected to login page with notification
- **Conditions:** User is warned 2 minutes before auto-logout

### FR-AUTH-06: Logout
- **Input:** User clicks "Logout"
- **Processing:** Invalidate JWT token via Supabase Auth sign-out; clear local session state
- **Output:** User redirected to login screen; all cached data cleared

---

### 3.1.2 Dashboard Module (FR-DASH)

### FR-DASH-01: KPI Overview Widgets
- **Input:** Authenticated user session, selected date range
- **Processing:** Query aggregated financial data (net revenue, total expenses, cash on hand, outstanding receivables); compute KPIs in real-time
- **Output:** Display widgets: Net Revenue, Total Expenses, Cash Balance, Receivables, Payables
- **Conditions:** Data refreshes every 60 seconds or on WebSocket push event

### FR-DASH-02: Revenue vs. Expense Trend Chart
- **Input:** Date range filter (default: current month)
- **Processing:** Aggregate daily/weekly/monthly transaction data grouped by type (income/expense); format for fl_chart line/bar chart
- **Output:** Interactive line chart showing revenue and expense trends
- **Conditions:** Chart must render within 2 seconds; supports zoom/pan

### FR-DASH-03: Recent Transactions Feed
- **Input:** Authenticated session
- **Processing:** Fetch last 10 transactions sorted by date descending
- **Output:** Scrollable list showing: date, description, amount, category, status
- **Conditions:** Clicking a transaction opens the transaction detail screen

### FR-DASH-04: Alerts & Notifications
- **Input:** System event triggers (negative cash balance, overdue invoice, budget breach)
- **Processing:** Evaluate alert conditions on data update; push notification to user
- **Output:** In-app notification banner and notification center entry
- **Conditions:** Each alert type can be enabled/disabled per user preference

### FR-DASH-05: Dashboard Customization
- **Input:** User drag-and-drop or toggle widget visibility
- **Processing:** Save widget layout preferences to `public.user_preferences` table
- **Output:** Customized dashboard layout persists across sessions and devices
- **Conditions:** Minimum 2 widgets must remain visible at all times

---

### 3.1.3 Client & Account Receivable Management (FR-CL)

### FR-CL-01: Add New Client
- **Input:** Client name, email, phone, address, tax ID, payment terms, credit limit, currency
- **Processing:** Validate required fields; check for duplicate email/tax ID within organization; insert record into `public.clients`
- **Output:** Client profile created; appears in client list
- **Conditions:** Client name and email are mandatory

### FR-CL-02: Edit Client Profile
- **Input:** Updated client fields
- **Processing:** Validate changes; update `public.clients` record; log change in audit trail
- **Output:** Updated client profile saved; success toast shown
- **Conditions:** Only Accountant role and above can edit clients

### FR-CL-03: View Client Outstanding Balance
- **Input:** Selected client
- **Processing:** Sum all unpaid invoices and credits for client; compute aging schedule (0–30, 31–60, 61–90, 90+ days)
- **Output:** Balance summary card + aging schedule table
- **Conditions:** Balance updates in real-time when new transactions are posted

### FR-CL-04: Generate Invoice
- **Input:** Client ID, line items (description, quantity, unit price), due date, tax rate
- **Processing:** Calculate subtotal, tax, and total; assign invoice number (auto-incremented); insert into `public.invoices` and `public.invoice_items`
- **Output:** Formatted PDF invoice generated; option to email directly to client
- **Conditions:** Invoice number format: `INV-YYYY-XXXXXX`

### FR-CL-05: Track Invoice Status
- **Input:** Invoice ID
- **Processing:** Check payment records against invoice amount; update status (Draft → Sent → Partial → Paid → Overdue)
- **Output:** Invoice status badge updated; overdue invoices trigger alert
- **Conditions:** Status "Overdue" triggered automatically when due date passes and balance > 0

### FR-CL-06: Delete Client
- **Input:** Client ID, admin confirmation
- **Processing:** Soft-delete client (set `is_active = false`); retain all historical transactions and invoices for audit
- **Output:** Client removed from active list; data preserved
- **Conditions:** Only Administrator can delete clients; cannot delete clients with unpaid invoices

---

### 3.1.4 Cashbook Module (FR-CB)

### FR-CB-01: View Cashbook
- **Input:** Date range filter, account filter
- **Processing:** Fetch all cash receipts and payments in selected range; calculate running balance after each entry
- **Output:** Tabular view with columns: Date, Reference, Description, Debit, Credit, Balance
- **Conditions:** Sorted by date ascending; supports pagination (50 rows per page)

### FR-CB-02: Add Cash Receipt
- **Input:** Date, reference number, description, amount, category, client/source
- **Processing:** Validate amount > 0; insert debit entry into `public.cashbook_entries`; auto-post corresponding credit to ledger account
- **Output:** Entry appears in cashbook; running balance updated
- **Conditions:** Cannot post to a closed accounting period

### FR-CB-03: Add Cash Payment
- **Input:** Date, reference number, description, amount, category, payee/vendor
- **Processing:** Validate amount > 0 and sufficient balance; insert credit entry; auto-post debit to appropriate expense account
- **Output:** Entry in cashbook; balance reduced
- **Conditions:** Warning shown if payment causes cash balance to go negative

### FR-CB-04: Edit Cashbook Entry
- **Input:** Entry ID, updated fields
- **Processing:** Create reversal entry for original; post corrected entry; log both in audit trail
- **Output:** Cashbook reflects correction; audit trail shows original and revised entries
- **Conditions:** Only Finance Manager and above can edit posted entries

### FR-CB-05: Delete/Void Cashbook Entry
- **Input:** Entry ID, reason for void
- **Processing:** Mark entry as `voided`; create reversal posting; log void reason and user
- **Output:** Entry marked voided (not deleted); ledger balance corrected
- **Conditions:** Voiding requires Finance Manager approval; physical deletion is not permitted

---

### 3.1.5 Ledger Module (FR-LG)

### FR-LG-01: View General Ledger
- **Input:** Account filter, date range
- **Processing:** Fetch all journal entries for selected accounts in range; compute account balance
- **Output:** Ledger view: Date, Journal Ref, Description, Debit, Credit, Running Balance per account
- **Conditions:** Opening balance shown at top of each account section

### FR-LG-02: Create Manual Journal Entry
- **Input:** Date, journal reference, description, debit lines (account, amount), credit lines (account, amount)
- **Processing:** Validate total debits == total credits (balanced entry); insert into `public.journal_entries` and `public.journal_lines`; update account balances
- **Output:** Journal entry posted; ledger accounts updated
- **Conditions:** Unbalanced entries are rejected with error: "Debits must equal credits"

### FR-LG-03: Chart of Accounts Management
- **Input:** Account name, account type (Asset/Liability/Equity/Revenue/Expense), account code, parent account
- **Processing:** Validate unique account code; insert into `public.accounts`; support hierarchical structure
- **Output:** New account appears in chart of accounts; available for journal entries
- **Conditions:** Only Administrator can create/delete accounts

### FR-LG-04: Account Balance Summary
- **Input:** As-of date
- **Processing:** Compute closing balance for all accounts as of selected date
- **Output:** Trial balance report: Account | Debit Balance | Credit Balance
- **Conditions:** Total debits must equal total credits; imbalance flagged as system error

---

### 3.1.6 Transactions Module (FR-TX)

### FR-TX-01: Add Single Transaction
- **Input:** Date, type (Income/Expense/Transfer), amount, category, description, client/vendor, payment method, attachment
- **Processing:** Validate all required fields; classify category; insert into `public.transactions`; propagate to cashbook and ledger
- **Output:** Transaction recorded; dashboard KPIs updated
- **Conditions:** Amount must be > 0; date cannot be in the future unless it is a scheduled transaction

### FR-TX-02: Batch Import Transactions
- **Input:** CSV/Excel file upload
- **Processing:** Parse file; validate each row (required fields, data types, duplicates); preview rows with errors highlighted; on confirm, insert valid rows; log rejected rows
- **Output:** Import summary: X records imported, Y records failed; downloadable error report
- **Conditions:** Max file size 10 MB; max 5,000 rows per import

### FR-TX-03: Edit Transaction
- **Input:** Transaction ID, updated fields
- **Processing:** Check user permission; update record; create audit log entry; propagate changes to cashbook and ledger
- **Output:** Transaction updated; audit trail records who changed what and when
- **Conditions:** Posted transactions require Finance Manager approval to edit

### FR-TX-04: Delete/Void Transaction
- **Input:** Transaction ID, void reason
- **Processing:** Soft-delete; create reversal posting; notify relevant users
- **Output:** Transaction voided; balances corrected
- **Conditions:** Administrator only; irreversible physical deletion not permitted

### FR-TX-05: Filter & Search Transactions
- **Input:** Search term, filters (date range, category, amount range, status, client/vendor)
- **Processing:** Query `public.transactions` with applied filters; rank by relevance
- **Output:** Filtered transaction list; result count displayed
- **Conditions:** Response time < 1 second for up to 100,000 records with proper indexing

### FR-TX-06: Transaction Categorization
- **Input:** Transaction description and amount
- **Processing:** Match against category rules; suggest most likely category based on history patterns
- **Output:** Pre-filled category field; user can override
- **Conditions:** Suggestion accuracy target ≥ 80% after 50+ historical transactions

---

## 3.7 Reports Module (FR-RP)

### FR-RP-01: Profit & Loss Statement
- **Input:** Date range, comparison period (optional)
- **Processing:** Aggregate revenue and expense accounts; compute gross profit, operating profit, net profit; optionally compare with prior period
- **Output:** Formatted P&L report with section totals and variance percentages
- **Conditions:** Generated within 5 seconds for up to 1M transactions

### FR-RP-02: Balance Sheet
- **Input:** As-of date
- **Processing:** Compute total assets, liabilities, and equity as of selected date; verify Assets = Liabilities + Equity
- **Output:** Standard balance sheet format compliant with GAAP/IFRS
- **Conditions:** Any imbalance flagged as a critical error requiring admin review

### FR-RP-03: Cash Flow Statement
- **Input:** Date range
- **Processing:** Categorize cash movements into Operating, Investing, Financing activities; compute net cash change
- **Output:** Cash flow statement with opening and closing cash balances
- **Conditions:** Must reconcile with cashbook closing balance

### FR-RP-04: Accounts Receivable Aging Report
- **Input:** As-of date
- **Processing:** Group outstanding invoices by age bucket: Current, 1–30, 31–60, 61–90, 90+ days
- **Output:** Aging table per client with total outstanding
- **Conditions:** Highlights clients with 90+ day overdue amounts in red

### FR-RP-05: Export Reports
- **Input:** Report type, format (PDF/Excel/CSV)
- **Processing:** Render report data; format per selected type; generate download link
- **Output:** Downloadable file delivered to user
- **Conditions:** PDF exports include company logo and formatted headers; Excel exports include raw data and formulas

### FR-RP-06: Scheduled Reports
- **Input:** Report type, schedule (daily/weekly/monthly), recipient email list
- **Processing:** Generate report on schedule; email to recipients; log delivery
- **Output:** Report delivered to configured recipients on time
- **Conditions:** Failed deliveries retry 3 times; admin notified on persistent failure

---

## 3.8 Settings Module (FR-ST)

### FR-ST-01: User Management
- **Input:** User email, assigned role, department
- **Processing:** Send invitation email; create pending user record; on acceptance, activate account with assigned role
- **Output:** New user can log in with configured permissions
- **Conditions:** Only Administrator can invite and manage users

### FR-ST-02: Role & Permission Management
- **Input:** Role name, permission toggles per module
- **Processing:** Save custom role definition to `public.roles`; apply to all assigned users
- **Output:** Users with the role immediately reflect updated permissions
- **Conditions:** System roles (Administrator, Accountant, Viewer) cannot be deleted

### FR-ST-03: Organization Profile
- **Input:** Company name, logo, address, fiscal year start, accounting method (cash/accrual), base currency
- **Processing:** Validate required fields; update `public.organizations`
- **Output:** Organization settings saved; reflected across all reports
- **Conditions:** Changing fiscal year start requires Finance Manager approval

### FR-ST-04: Audit Log View
- **Input:** Date range, user filter, action type filter
- **Processing:** Fetch from `public.audit_logs`; display chronologically
- **Output:** Paginated audit log: Timestamp, User, Action, Affected Record, Old Value, New Value
- **Conditions:** Audit logs are read-only; cannot be edited or deleted; retained for 7 years

---

#     - 3.2 Non-Functional Requirements

## 4.1 Performance

| Requirement | Specification |
|-------------|--------------|
| **NFR-PERF-01** | Dashboard KPI widgets must load within **2 seconds** for up to 1 million transaction records |
| **NFR-PERF-02** | Any single transaction insert must complete within **100 milliseconds** |
| **NFR-PERF-03** | Report generation (P&L, Balance Sheet) must complete within **5 seconds** |
| **NFR-PERF-04** | Search/filter queries must return results within **1 second** |
| **NFR-PERF-05** | Batch import of 5,000 rows must complete within **30 seconds** |
| **NFR-PERF-06** | App cold start time must be < **3 seconds** on mid-range devices |

## 4.2 Scalability

| Requirement | Specification |
|-------------|--------------|
| **NFR-SCALE-01** | System must support **10,000+ concurrent users** without performance degradation |
| **NFR-SCALE-02** | Database must handle **100 million+ transaction rows** per organization |
| **NFR-SCALE-03** | Infrastructure must auto-scale horizontally during peak load |
| **NFR-SCALE-04** | Multi-tenancy architecture must support **1,000+ organizations** on shared infrastructure |

## 4.3 Reliability & Availability

| Requirement | Specification |
|-------------|--------------|
| **NFR-REL-01** | System uptime SLA: **99.99%** (< 52 minutes downtime per year) |
| **NFR-REL-02** | Recovery Time Objective (RTO): **< 1 hour** after catastrophic failure |
| **NFR-REL-03** | Recovery Point Objective (RPO): **< 15 minutes** data loss in worst case |
| **NFR-REL-04** | Automated daily backups with **90-day point-in-time recovery** |

## 4.4 Usability

| Requirement | Specification |
|-------------|--------------|
| **NFR-USE-01** | New users must be able to complete core tasks (add transaction, generate report) within **10 minutes** of first login without training |
| **NFR-USE-02** | All UI must comply with **WCAG 2.1 Level AA** accessibility standards |
| **NFR-USE-03** | Application must support **responsive layout** across screen sizes from 320px to 4K |
| **NFR-USE-04** | All error messages must be human-readable with actionable guidance |
| **NFR-USE-05** | App must support **dark mode** and **light mode** |

## 4.5 Maintainability

| Requirement | Specification |
|-------------|--------------|
| **NFR-MAINT-01** | Codebase follows Flutter/Dart best practices with feature-first folder structure |
| **NFR-MAINT-02** | All public APIs and complex business logic must have inline documentation |
| **NFR-MAINT-03** | Unit test coverage must be ≥ **70%** for business logic |
| **NFR-MAINT-04** | CI/CD pipeline must run automated tests on every pull request |

## 4.6 Compatibility

| Requirement | Specification |
|-------------|--------------|
| **NFR-COMP-01** | Android: version **10 (API 29)** and above |
| **NFR-COMP-02** | iOS: version **14** and above |
| **NFR-COMP-03** | Web: latest two versions of Chrome, Firefox, Edge, Safari |
| **NFR-COMP-04** | Desktop: Windows 10+, macOS 11+ |

---

#     - 3.3 Use Cases

## UC-01: User Login

| Field | Detail |
|-------|--------|
| **Actor** | Any registered user |
| **Precondition** | User has a registered account |
| **Main Flow** | 1. User opens the app → 2. Enters email and password → 3. Taps "Login" → 4. System validates credentials via Supabase Auth → 5. JWT issued → 6. User redirected to dashboard |
| **Alternative Flow** | If MFA is enabled: After step 4, user enters TOTP code → validated → dashboard shown |
| **Exception Flow** | Invalid credentials: error shown; 5th failure: account locked 15 min |
| **Postcondition** | Authenticated session established; user on dashboard |

---

## UC-02: Add New Transaction

| Field | Detail |
|-------|--------|
| **Actor** | Accountant, Finance Manager, Administrator |
| **Precondition** | User is authenticated; chart of accounts configured |
| **Main Flow** | 1. Navigate to Transactions → 2. Tap "Add Transaction" → 3. Fill form (date, type, amount, category, description) → 4. Tap "Save" → 5. System validates and inserts record → 6. Dashboard updates |
| **Alternative Flow** | Attach receipt: User taps attachment icon → selects image → OCR extracts data → pre-fills form |
| **Exception Flow** | Amount = 0: rejected with validation error; closed period: blocked with message |
| **Postcondition** | Transaction saved; cashbook and ledger updated; KPIs refreshed |

---

## UC-03: Generate P&L Report

| Field | Detail |
|-------|--------|
| **Actor** | Accountant, Finance Manager, Executive, Administrator |
| **Precondition** | Transactions exist for selected period |
| **Main Flow** | 1. Navigate to Reports → 2. Select "Profit & Loss" → 3. Set date range → 4. Tap "Generate" → 5. System aggregates data → 6. Report displayed on screen |
| **Alternative Flow** | Export: Tap "Export" → select format (PDF/Excel/CSV) → file downloaded |
| **Exception Flow** | No data for period: message "No transactions found for the selected period" |
| **Postcondition** | P&L report displayed/downloaded; data unchanged |

---

## UC-04: Create Invoice for Client

| Field | Detail |
|-------|--------|
| **Actor** | Accountant, Finance Manager, Administrator |
| **Precondition** | Client record exists |
| **Main Flow** | 1. Navigate to Clients → 2. Select client → 3. Tap "New Invoice" → 4. Add line items → 5. Set due date → 6. Tap "Generate" → 7. Invoice PDF created → 8. Option to email client |
| **Alternative Flow** | Save as draft: Tap "Save Draft" → invoice saved with status "Draft" |
| **Exception Flow** | Client email not set: warning shown; send option disabled |
| **Postcondition** | Invoice created; receivable balance updated; client notified (if emailed) |

---

## UC-05: Invite New User

| Field | Detail |
|-------|--------|
| **Actor** | Administrator |
| **Precondition** | Admin is logged in; user does not already exist |
| **Main Flow** | 1. Navigate to Settings → Users → 2. Tap "Invite User" → 3. Enter email and assign role → 4. Tap "Send Invite" → 5. System sends invitation email → 6. User accepts and sets password |
| **Alternative Flow** | Resend invite: If user has not accepted in 48h, admin can resend |
| **Exception Flow** | Email already registered: error "User with this email already exists" |
| **Postcondition** | New user account active with configured role and permissions |

---

## UC-06: Perform Month-End Close

| Field | Detail |
|-------|--------|
| **Actor** | Finance Manager |
| **Precondition** | All transactions for the month are posted and reconciled |
| **Main Flow** | 1. Navigate to Ledger → Accounting Periods → 2. Select current month → 3. Run "Pre-Close Checklist" → 4. Resolve any flagged items → 5. Tap "Close Period" → 6. System locks period from further edits |
| **Alternative Flow** | Reopen period: Administrator can reopen a closed period with documented reason |
| **Exception Flow** | Unreconciled items found: checklist shows warnings; close blocked until resolved |
| **Postcondition** | Period locked; all reports for the month finalized and immutable |
# SRS — Smart Ledger (Continued)
## Sections 6–11

---

#     - 3.4 External Interface Requirements

## 6.1 User Interface Requirements

| Requirement | Detail |
|-------------|--------|
| **UI-01** | The app uses Flutter Material Design 3 with a custom dark-mode-first theme |
| **UI-02** | Primary font: Google Fonts (Inter/Roboto); minimum body text size 14sp |
| **UI-03** | Color contrast ratio ≥ 4.5:1 for all text elements (WCAG AA) |
| **UI-04** | All interactive elements must have a minimum touch target of 48×48dp |
| **UI-05** | Navigation: Bottom navigation bar on mobile; side rail on tablet/desktop |
| **UI-06** | Loading states shown with skeleton loaders (not spinner-only) |
| **UI-07** | All forms must show inline validation errors on field blur |
| **UI-08** | Empty states must show illustrative icons and actionable guidance text |
| **UI-09** | All destructive actions require a confirmation dialog |
| **UI-10** | App must support both portrait and landscape orientations on mobile |

### 3.4.2 Hardware Interfaces
- **Camera:** Used for receipt scanning (OCR) on mobile devices
- **Biometric Sensor:** Fingerprint/Face ID for biometric authentication (optional)
- **Storage:** Local cache stored in device secure storage (shared_preferences)
- **Network:** Requires minimum 2G connection for basic operations; 4G recommended for file uploads

### 3.4.3 Software Interfaces

| System | Interface Type | Purpose |
|--------|---------------|---------|
| **Supabase Auth** | REST API / Dart SDK | User authentication, JWT management, MFA |
| **Supabase Database** | PostgreSQL + PostgREST | All data storage and querying |
| **Supabase Realtime** | WebSocket | Live data sync across devices |
| **Supabase Storage** | REST API | Receipt image and document storage |
| **Google Fonts** | CDN / Flutter package | Typography |
| **fl_chart** | Flutter package | Dashboard charts and visualizations |
| **go_router** | Flutter package | In-app navigation and deep linking |
| **Riverpod** | Flutter package | State management |

### 3.4.4 Communication Interfaces

| Protocol | Usage |
|----------|-------|
| **HTTPS (TLS 1.3)** | All API calls between client and Supabase backend |
| **WebSocket (WSS)** | Real-time data synchronization (Supabase Realtime) |
| **SMTP** | Transactional emails (invoice delivery, password reset, scheduled reports) — via Supabase/SendGrid |

### 3.4.5 API Interfaces
- **Stripe API:** Payment processing for invoice collection
- **Open Banking API:** Automated bank feed import
- **REST Webhooks:** Outbound event notifications to third-party systems

---

#     - 3.5 Data Requirements

### 3.5.1 Core Database Schema

### Table: `public.organizations`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Unique organization ID |
| `name` | TEXT | NOT NULL | Company name |
| `logo_url` | TEXT | NULLABLE | Logo image URL |
| `address` | TEXT | NULLABLE | Registered address |
| `base_currency` | VARCHAR(3) | NOT NULL, DEFAULT 'USD' | ISO 4217 currency code |
| `fiscal_year_start` | DATE | NOT NULL | Start of fiscal year |
| `accounting_method` | VARCHAR(10) | CHECK IN ('cash','accrual') | Accounting basis |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Record creation time |

### Table: `public.profiles`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, FK → auth.users(id) | Matches Supabase Auth user ID |
| `organization_id` | UUID | FK → organizations(id) | Owning organization |
| `full_name` | TEXT | NOT NULL | User's full name |
| `role` | VARCHAR(30) | NOT NULL | Assigned role |
| `is_active` | BOOLEAN | DEFAULT true | Account active status |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Profile creation time |

### Table: `public.accounts` (Chart of Accounts)
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Account ID |
| `organization_id` | UUID | FK → organizations(id) | Owning org |
| `code` | VARCHAR(20) | NOT NULL, UNIQUE per org | Account code |
| `name` | TEXT | NOT NULL | Account name |
| `type` | VARCHAR(20) | CHECK IN ('asset','liability','equity','revenue','expense') | Account type |
| `parent_id` | UUID | FK → accounts(id), NULLABLE | Parent account for hierarchy |
| `is_active` | BOOLEAN | DEFAULT true | Active flag |

### Table: `public.clients`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Client ID |
| `organization_id` | UUID | FK → organizations(id) | Owning org |
| `name` | TEXT | NOT NULL | Client/company name |
| `email` | TEXT | NULLABLE | Contact email |
| `phone` | TEXT | NULLABLE | Contact phone |
| `address` | TEXT | NULLABLE | Client address |
| `tax_id` | TEXT | NULLABLE | Tax identification number |
| `credit_limit` | DECIMAL(18,2) | DEFAULT 0 | Credit limit |
| `currency` | VARCHAR(3) | DEFAULT 'USD' | Client's preferred currency |
| `is_active` | BOOLEAN | DEFAULT true | Soft-delete flag |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Created timestamp |

### Table: `public.transactions`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Transaction ID |
| `organization_id` | UUID | FK → organizations(id) | Owning org |
| `date` | DATE | NOT NULL | Transaction date |
| `type` | VARCHAR(10) | CHECK IN ('income','expense','transfer') | Transaction type |
| `amount` | DECIMAL(18,2) | NOT NULL, CHECK > 0 | Transaction amount |
| `currency` | VARCHAR(3) | NOT NULL | Currency code |
| `category_id` | UUID | FK → categories(id) | Transaction category |
| `description` | TEXT | NULLABLE | Transaction description |
| `client_id` | UUID | FK → clients(id), NULLABLE | Related client |
| `status` | VARCHAR(15) | DEFAULT 'posted' | Transaction status |
| `created_by` | UUID | FK → profiles(id) | Creator user ID |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Record timestamp |
| `is_voided` | BOOLEAN | DEFAULT false | Void flag |
| `void_reason` | TEXT | NULLABLE | Reason for void |

### Table: `public.journal_entries`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Journal entry ID |
| `organization_id` | UUID | FK → organizations(id) | Owning org |
| `reference` | TEXT | NOT NULL | Journal reference number |
| `date` | DATE | NOT NULL | Entry date |
| `description` | TEXT | NULLABLE | Entry description |
| `is_balanced` | BOOLEAN | COMPUTED | Debits == Credits check |
| `created_by` | UUID | FK → profiles(id) | Creator |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Timestamp |

### Table: `public.journal_lines`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Line ID |
| `journal_entry_id` | UUID | FK → journal_entries(id) | Parent entry |
| `account_id` | UUID | FK → accounts(id) | Affected account |
| `debit` | DECIMAL(18,2) | DEFAULT 0 | Debit amount |
| `credit` | DECIMAL(18,2) | DEFAULT 0 | Credit amount |
| `description` | TEXT | NULLABLE | Line description |

### Table: `public.invoices`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Invoice ID |
| `organization_id` | UUID | FK → organizations(id) | Owning org |
| `invoice_number` | TEXT | NOT NULL, UNIQUE | Format: INV-YYYY-XXXXXX |
| `client_id` | UUID | FK → clients(id) | Billed client |
| `issue_date` | DATE | NOT NULL | Issue date |
| `due_date` | DATE | NOT NULL | Payment due date |
| `subtotal` | DECIMAL(18,2) | NOT NULL | Before tax |
| `tax_amount` | DECIMAL(18,2) | DEFAULT 0 | Tax amount |
| `total` | DECIMAL(18,2) | NOT NULL | Total due |
| `status` | VARCHAR(15) | DEFAULT 'draft' | Draft/Sent/Paid/Overdue |
| `notes` | TEXT | NULLABLE | Invoice notes |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Creation time |

### Table: `public.audit_logs`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Log ID |
| `organization_id` | UUID | FK → organizations(id) | Owning org |
| `user_id` | UUID | FK → profiles(id) | Acting user |
| `action` | TEXT | NOT NULL | CREATE/UPDATE/DELETE/VOID |
| `table_name` | TEXT | NOT NULL | Affected table |
| `record_id` | UUID | NOT NULL | Affected record |
| `old_value` | JSONB | NULLABLE | Previous state |
| `new_value` | JSONB | NULLABLE | New state |
| `timestamp` | TIMESTAMPTZ | DEFAULT now() | Event time |

## 7.2 Data Validation Rules

| Field | Validation Rule |
|-------|----------------|
| Email | Must match RFC 5322 email format |
| Amount | Must be a positive decimal; max 16 digits before decimal, 2 after |
| Currency | Must be a valid ISO 4217 3-letter code |
| Date | Must be a valid calendar date; transaction date cannot be more than 1 year in the future |
| Password | Min 8 chars; at least 1 uppercase, 1 number, 1 special character |
| Account Code | Alphanumeric; max 20 characters; unique per organization |
| Phone | Optional; if provided, must match E.164 format |

## 7.3 Data Retention Policy
- Transaction records: **Retained permanently** (required for accounting compliance)
- Audit logs: **Retained for 7 years** (SOX compliance)
- Voided/deleted records: **Soft-deleted only**; physical deletion not permitted
- User session tokens: **Expire after 30 minutes of inactivity**
- Backup data: **90-day point-in-time recovery window**

## 7.4 ER Diagram (Simplified)

```
organizations ──< profiles
organizations ──< accounts ──< journal_lines >── journal_entries
organizations ──< clients  ──< invoices
organizations ──< transactions >── categories
transactions ──> audit_logs
journal_entries ──> audit_logs
```

---

#     - 3.6 Additional Constraints

### 3.6.1 Technical Constraints
| ID | Constraint |
|----|-----------|
| CON-01 | The frontend **must** be built with Flutter (Dart SDK ^3.8.1) |
| CON-02 | The backend **must** use Supabase (PostgreSQL + Auth + Storage + Realtime) |
| CON-03 | State management **must** use flutter_riverpod v2.x |
| CON-04 | Navigation **must** use go_router v14.x |
| CON-05 | All database writes must use parameterized queries (no raw string interpolation in SQL) |
| CON-06 | Row-Level Security (RLS) **must** be enabled on all public schema tables |
| CON-07 | Financial calculations must use `DECIMAL(18,2)` types — never floating-point |

## 8.2 Business Constraints
| ID | Constraint |
|----|-----------|
| CON-08 | Double-entry bookkeeping rule: every transaction must have equal debits and credits |
| CON-09 | Posted entries in closed accounting periods **cannot** be modified without reopening |
| CON-10 | Physical deletion of financial records is **not permitted**; only soft-delete/void |
| CON-11 | All monetary amounts stored in the organization's base currency; forex rates logged at transaction time |
| CON-12 | Reports must comply with GAAP/IFRS format requirements |

## 8.3 Academic Project Constraints
| ID | Constraint |
|----|-----------|
| CON-13 | Development timeline: approximately 8 academic weeks |
| CON-14 | Team size: DBMS project team (typically 3–5 members) |
| CON-15 | Infrastructure: Supabase free/pro tier; no dedicated server budget |
| CON-16 | Scope for submission excludes: AI forecasting, payroll, blockchain, intercompany settlement |

---

#     - 3.7 Security Requirements

### 3.7.1 Authentication & Authorization

| ID | Requirement |
|----|------------|
| SEC-01 | All users must authenticate with email + password via Supabase Auth (JWT-based) |
| SEC-02 | JWT tokens must expire after **1 hour**; refresh tokens after **30 min inactivity** |
| SEC-03 | MFA (TOTP) must be available for all users; admin can enforce org-wide |
| SEC-04 | Role-Based Access Control (RBAC) must be enforced at both application and database (RLS) levels |
| SEC-05 | API endpoints must validate JWT on every request; unauthenticated requests receive HTTP 401 |
| SEC-06 | Account lockout after **5 consecutive failed login attempts** for **15 minutes** |
| SEC-07 | Password reset links must expire after **60 minutes** and be single-use |

## 9.2 Data Encryption

| ID | Requirement |
|----|------------|
| SEC-08 | All data in transit must use **TLS 1.3** |
| SEC-09 | All data at rest must be encrypted using **AES-256** (managed by Supabase) |
| SEC-10 | User passwords are **never stored in plaintext**; Supabase Auth uses bcrypt hashing |
| SEC-11 | Backup files must be encrypted with customer-managed encryption keys |
| SEC-12 | Receipt/document files in Supabase Storage must be stored in private buckets (not public URLs) |

## 9.3 Row-Level Security (RLS) Policies

| Policy | Rule |
|--------|------|
| **Organization Isolation** | Users can only SELECT/INSERT/UPDATE/DELETE records where `organization_id = auth.jwt()->>'org_id'` |
| **Role Enforcement** | DELETE operations on financial tables restricted to users with `role = 'administrator'` |
| **Audit Log Protection** | `public.audit_logs` is INSERT-only; no UPDATE or DELETE permitted by any role |
| **Client Portal** | External clients can only SELECT their own invoice records |

## 9.4 Input Security

| ID | Requirement |
|----|------------|
| SEC-13 | All user inputs must be sanitized server-side to prevent SQL injection |
| SEC-14 | File uploads must validate MIME type and limit size to **10 MB** |
| SEC-15 | Rate limiting must be applied: max **100 API requests per minute per user** |
| SEC-16 | CSRF protection enabled on all state-changing operations |

## 9.5 Audit & Compliance

| ID | Requirement |
|----|------------|
| SEC-17 | All CREATE, UPDATE, DELETE, and VOID operations must generate an immutable audit log entry |
| SEC-18 | Audit logs must capture: user ID, timestamp, action, affected table, old value, new value |
| SEC-19 | Audit logs retained for minimum **7 years** per SOX compliance |
| SEC-20 | System must support GDPR data export requests (user can download all their data) |
| SEC-21 | System must support GDPR right-to-erasure (user PII deletable; financial records anonymized) |

## 9.6 Network Security
| ID | Requirement |
|----|------------|
| SEC-22 | Supabase project must have IP allowlisting enabled for database direct access |
| SEC-23 | API keys (anon key) must be stored in secure environment config; never in source code |
| SEC-24 | Production Supabase credentials must not be committed to version control |

---

#     - 3.8 Acceptance Criteria

> A feature is considered **complete** when all its acceptance criteria pass in a production-equivalent environment.

## 10.1 Authentication
| AC-ID | Criterion |
|-------|-----------|
| AC-AUTH-01 | User can register with valid email/password; confirmation email received |
| AC-AUTH-02 | User can login and is redirected to dashboard within 2 seconds |
| AC-AUTH-03 | Login with incorrect password shows error; account locks after 5 attempts |
| AC-AUTH-04 | Password reset email received within 60 seconds; link expires after 60 minutes |
| AC-AUTH-05 | Session auto-expires after 30 minutes of inactivity; user redirected to login |
| AC-AUTH-06 | MFA can be enabled/disabled; TOTP code validated correctly |

## 10.2 Dashboard
| AC-ID | Criterion |
|-------|-----------|
| AC-DASH-01 | All KPI widgets load within 2 seconds on a dataset of 100,000 transactions |
| AC-DASH-02 | Revenue vs Expense chart accurately reflects transaction data for selected period |
| AC-DASH-03 | Dashboard reflects new transaction within 5 seconds of posting |
| AC-DASH-04 | Negative cash balance triggers an alert notification |

## 10.3 Transactions
| AC-ID | Criterion |
|-------|-----------|
| AC-TX-01 | Valid transaction saves in < 500ms and appears in cashbook and ledger |
| AC-TX-02 | Transaction with amount = 0 or negative is rejected with validation error |
| AC-TX-03 | CSV import of 1,000 rows completes in < 10 seconds; invalid rows reported |
| AC-TX-04 | Voided transaction reverses ledger balances correctly; void reason recorded |
| AC-TX-05 | Search with filters returns correct results within 1 second |

## 10.4 Ledger & Cashbook
| AC-ID | Criterion |
|-------|-----------|
| AC-LG-01 | Manual journal entry with unequal debits/credits is rejected |
| AC-LG-02 | Trial balance totals agree (Total Debits = Total Credits) after any valid posting |
| AC-LG-03 | Cashbook running balance matches sum of all debit-credit entries |
| AC-LG-04 | Entries in closed periods cannot be edited without period re-opening |

## 10.5 Clients & Invoices
| AC-ID | Criterion |
|-------|-----------|
| AC-CL-01 | Client with duplicate email within same org is rejected |
| AC-CL-02 | Invoice PDF generated with correct totals, line items, and invoice number format |
| AC-CL-03 | Invoice status changes to "Overdue" automatically when due date passes with outstanding balance |
| AC-CL-04 | Client outstanding balance matches sum of all unpaid invoices |

## 10.6 Reports
| AC-ID | Criterion |
|-------|-----------|
| AC-RP-01 | P&L report: Net Profit = Total Revenue − Total Expenses (verified against manual calculation) |
| AC-RP-02 | Balance Sheet: Total Assets = Total Liabilities + Total Equity |
| AC-RP-03 | Cash Flow net change reconciles with opening and closing cashbook balance |
| AC-RP-04 | PDF/Excel export downloads correctly and contains all displayed data |
| AC-RP-05 | Scheduled report email delivered within 5 minutes of scheduled time |

## 10.7 Security
| AC-ID | Criterion |
|-------|-----------|
| AC-SEC-01 | User A cannot access User B's organization data under any authenticated request |
| AC-SEC-02 | Accountant role cannot access User Management settings |
| AC-SEC-03 | Audit log entry is created for every transaction creation, update, and void |
| AC-SEC-04 | Audit logs cannot be edited or deleted via any UI or API call |

---

# 4. Appendix

## 11.1 Glossary

| Term | Definition |
|------|-----------|
| **Double-Entry Bookkeeping** | An accounting system where every transaction has equal debit and credit entries |
| **Trial Balance** | A summary listing all accounts and their balances; total debits must equal total credits |
| **Aging Schedule** | A report grouping outstanding receivables by how overdue they are |
| **Chart of Accounts** | A structured list of all financial accounts used by an organization |
| **Soft Delete** | Marking a record as inactive/voided without removing it from the database |
| **Multi-Tenancy** | A single application instance serving multiple organizations with full data isolation |
| **RLS** | Row-Level Security — a PostgreSQL feature restricting data access at the row level based on user context |
| **JWT** | JSON Web Token — a signed token used to authenticate API requests |
| **TOTP** | Time-based One-Time Password — used for MFA |
| **Fiscal Year** | A 12-month accounting period used for financial reporting |
| **Reconciliation** | The process of ensuring two sets of records (e.g., cashbook and bank statement) agree |

## 11.2 Technology Stack Summary

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend Framework | Flutter | 3.x |
| Language | Dart | ^3.8.1 |
| State Management | flutter_riverpod | ^2.6.1 |
| Navigation | go_router | ^14.6.2 |
| Backend | Supabase | Latest |
| Database | PostgreSQL | 15 |
| Charts | fl_chart | ^0.70.0 |
| Typography | google_fonts | ^6.2.1 |
| Icons | font_awesome_flutter | ^10.7.0 |
| Local Storage | shared_preferences | ^2.3.4 |

## 4.3 Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-05-11 | Project Team | Initial SRS draft |

## 4.4 Document Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Lead | | | |
| Technical Lead | | | |
| QA Lead | | | |
| Client Representative | | | |

---

*End of Software Requirements Specification — Smart Ledger v1.0*
