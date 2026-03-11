create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.todos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'pending',
  priority text not null default 'medium',
  due_date date,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint todos_title_not_blank check (char_length(trim(title)) > 0),
  constraint todos_title_max_length check (char_length(title) <= 120),
  constraint todos_status_check check (status in ('pending', 'completed')),
  constraint todos_priority_check check (priority in ('low', 'medium', 'high')),
  constraint todos_completed_at_check check (
    (status = 'pending' and completed_at is null)
    or (status = 'completed')
  )
);

create index if not exists todos_user_id_idx on public.todos (user_id);
create index if not exists todos_user_id_status_idx on public.todos (user_id, status);
create index if not exists todos_user_id_created_at_idx on public.todos (user_id, created_at desc);
create index if not exists todos_user_id_due_date_idx on public.todos (user_id, due_date);

drop trigger if exists set_todos_updated_at on public.todos;

create trigger set_todos_updated_at
before update on public.todos
for each row
execute function public.set_updated_at();

alter table public.todos enable row level security;

drop policy if exists todos_select_own on public.todos;
create policy todos_select_own
on public.todos
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists todos_insert_own on public.todos;
create policy todos_insert_own
on public.todos
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists todos_update_own on public.todos;
create policy todos_update_own
on public.todos
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists todos_delete_own on public.todos;
create policy todos_delete_own
on public.todos
for delete
to authenticated
using (user_id = auth.uid());
