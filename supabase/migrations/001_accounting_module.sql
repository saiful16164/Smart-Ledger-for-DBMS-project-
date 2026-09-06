-- Accounting module tables for SmartLedger
-- Run this in Supabase SQL editor or apply with Supabase CLI.

alter table if exists public.customers
  add column if not exists party_type text not null default 'customer';

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  code text not null,
  name text not null,
  type text not null check (type in ('asset', 'liability', 'equity', 'income', 'expense')),
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  unique(owner_id, code)
);

create table if not exists public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  voucher_no text not null,
  date timestamptz not null,
  narration text,
  source_type text not null default 'manual',
  source_id uuid,
  created_at timestamptz not null default now(),
  unique(owner_id, source_type, source_id)
);

create table if not exists public.journal_lines (
  id uuid primary key default gen_random_uuid(),
  journal_entry_id uuid not null references public.journal_entries(id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete restrict,
  debit numeric(14, 2) not null default 0 check (debit >= 0),
  credit numeric(14, 2) not null default 0 check (credit >= 0),
  created_at timestamptz not null default now(),
  check ((debit > 0 and credit = 0) or (credit > 0 and debit = 0))
);

create index if not exists accounts_owner_id_idx on public.accounts(owner_id);
create index if not exists journal_entries_owner_id_date_idx on public.journal_entries(owner_id, date desc);
create index if not exists journal_entries_source_idx on public.journal_entries(owner_id, source_type, source_id);
create index if not exists journal_lines_entry_id_idx on public.journal_lines(journal_entry_id);
create index if not exists journal_lines_account_id_idx on public.journal_lines(account_id);

alter table public.accounts enable row level security;
alter table public.journal_entries enable row level security;
alter table public.journal_lines enable row level security;

create policy "Users can read own accounts"
  on public.accounts for select
  using (auth.uid() = owner_id);

create policy "Users can insert own accounts"
  on public.accounts for insert
  with check (auth.uid() = owner_id);

create policy "Users can update own non-system accounts"
  on public.accounts for update
  using (auth.uid() = owner_id and is_system = false)
  with check (auth.uid() = owner_id);

create policy "Users can read own journal entries"
  on public.journal_entries for select
  using (auth.uid() = owner_id);

create policy "Users can insert own journal entries"
  on public.journal_entries for insert
  with check (auth.uid() = owner_id);

create policy "Users can read own journal lines"
  on public.journal_lines for select
  using (
    exists (
      select 1 from public.journal_entries je
      where je.id = journal_entry_id and je.owner_id = auth.uid()
    )
  );

create policy "Users can insert own journal lines"
  on public.journal_lines for insert
  with check (
    exists (
      select 1 from public.journal_entries je
      where je.id = journal_entry_id and je.owner_id = auth.uid()
    )
  );
