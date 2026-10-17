-- À exécuter dans Supabase > SQL Editor > New query.
-- Ce script peut être relancé sans risque, y compris si vous aviez
-- exécuté l'ancienne version (accès ouvert à tous).

-- 1. Tables ------------------------------------------------------------

create table if not exists public.people (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 1 and 60),
  budget      numeric(10,2) check (budget >= 0),
  note        text default '' check (char_length(note) <= 400),
  created_at  timestamptz not null default now()
);

create table if not exists public.gifts (
  id            uuid primary key default gen_random_uuid(),
  person_id     uuid not null references public.people(id) on delete cascade,
  title         text not null check (char_length(title) between 1 and 120),
  price         numeric(10,2) check (price >= 0),
  status        text not null default 'idee' check (status in ('idee','achete','emballe')),
  where_to_buy  text default '' check (char_length(where_to_buy) <= 80),
  link          text default '' check (char_length(link) <= 2000),
  note          text default '' check (char_length(note) <= 400),
  created_at    timestamptz not null default now()
);
create index if not exists gifts_person_id_idx on public.gifts(person_id);

-- Liste des adresses e-mail autorisées à voir et modifier la liste
create table if not exists public.allowed_emails (
  email      text primary key check (email = lower(email)),
  added_at   timestamptz not null default now()
);

-- 2. Qui a accès ? -----------------------------------------------------

create or replace function public.is_allowed()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.allowed_emails
    where email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.is_allowed() from public, anon;
grant execute on function public.is_allowed() to authenticated;

alter table public.people         enable row level security;
alter table public.gifts          enable row level security;
alter table public.allowed_emails enable row level security;

-- Supprime l'ancien accès ouvert à tous
drop policy if exists "liste commune" on public.people;
drop policy if exists "liste commune" on public.gifts;

drop policy if exists "membres autorises" on public.people;
create policy "membres autorises" on public.people
  for all to authenticated
  using (public.is_allowed()) with check (public.is_allowed());

drop policy if exists "membres autorises" on public.gifts;
create policy "membres autorises" on public.gifts
  for all to authenticated
  using (public.is_allowed()) with check (public.is_allowed());

-- allowed_emails n'a aucune règle : elle n'est modifiable que depuis
-- le tableau de bord Supabase, jamais depuis le site.

-- 3. Mises à jour en direct --------------------------------------------

do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and tablename = 'people') then
    alter publication supabase_realtime add table public.people;
  end if;
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and tablename = 'gifts') then
    alter publication supabase_realtime add table public.gifts;
  end if;
end $$;

-- 4. Ajoutez ici les adresses autorisées (en minuscules) ------------------

insert into public.allowed_emails (email) values
  ('titouan.beauhaire@gmail.com'),
  ('marinesavaris@gmail.com')
on conflict do nothing;
