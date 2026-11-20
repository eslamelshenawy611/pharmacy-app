-- دفتر عملاء الصيدلية: جداول Supabase
-- كل الموظفين اللي ليهم حساب بيشوفوا ويعدّلوا نفس البيانات. مفيش وصول من غير تسجيل دخول.

create table if not exists public.team (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.customers (
  id text primary key,
  name text not null,
  phone text default '',
  area text default '',
  source text default '',
  want text default '',
  stage text not null default 'lead' check (stage in ('lead','follow','buyer','lost')),
  next_follow_up date,
  last_contact date,
  notes text default '',
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users(id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid() references auth.users(id) on delete set null
);

create table if not exists public.cycles (
  id text primary key,
  customer_id text not null references public.customers(id) on delete cascade,
  start_date date,
  chick_type text default '',
  chick_count numeric default 0,
  chick_price numeric default 0,
  paid numeric default 0,
  notes text default '',
  vaccines jsonb not null default '[]'::jsonb,   -- [{id,name,date,done,doneAt}]
  meds jsonb not null default '[]'::jsonb,       -- [{id,name,qty,total,date}]
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users(id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid() references auth.users(id) on delete set null
);
create index if not exists cycles_customer_idx on public.cycles(customer_id);

create table if not exists public.settings (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- stamp who/when on every change
create or replace function public.touch_row() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  if auth.uid() is not null then new.updated_by := auth.uid(); end if;
  return new;
end $$;
drop trigger if exists customers_touch on public.customers;
create trigger customers_touch before insert or update on public.customers for each row execute function public.touch_row();
drop trigger if exists cycles_touch on public.cycles;
create trigger cycles_touch before insert or update on public.cycles for each row execute function public.touch_row();

-- a team row for every login account (name from metadata, else the part before @)
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.team(id, name)
  values (new.id, coalesce(nullif(new.raw_user_meta_data->>'name',''), split_part(new.email,'@',1)))
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
insert into public.team(id, name)
  select id, coalesce(nullif(raw_user_meta_data->>'name',''), split_part(email,'@',1)) from auth.users
  on conflict (id) do nothing;

-- row level security: signed-in team members only
alter table public.team enable row level security;
alter table public.customers enable row level security;
alter table public.cycles enable row level security;
alter table public.settings enable row level security;

drop policy if exists team_read on public.team;
create policy team_read on public.team for select to authenticated using (true);
drop policy if exists team_self on public.team;
create policy team_self on public.team for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists customers_all on public.customers;
create policy customers_all on public.customers for all to authenticated using (true) with check (true);
drop policy if exists cycles_all on public.cycles;
create policy cycles_all on public.cycles for all to authenticated using (true) with check (true);
drop policy if exists settings_all on public.settings;
create policy settings_all on public.settings for all to authenticated using (true) with check (true);

-- live updates between phones
do $$ begin
  begin alter publication supabase_realtime add table public.customers; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.cycles; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.settings; exception when duplicate_object then null; end;
end $$;
