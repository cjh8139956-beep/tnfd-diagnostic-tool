-- TNFD 진단 도구 — Supabase DB 스키마
-- Supabase 대시보드 > SQL Editor 에서 그대로 실행

-- 1) 진단 프로젝트 테이블
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_name text not null,
  industry text,
  report_year int,
  pdf_filename text,
  bm_filename text,
  status text default 'draft', -- draft | analyzing | done
  results jsonb default '{}'::jsonb,  -- {id: {status, score, page, excerpt, ...}}
  bm_results jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_projects_user on projects(user_id, created_at desc);

-- 2) RLS — 본인 데이터만 접근
alter table projects enable row level security;

drop policy if exists "own_select" on projects;
create policy "own_select" on projects for select using (auth.uid() = user_id);

drop policy if exists "own_insert" on projects;
create policy "own_insert" on projects for insert with check (auth.uid() = user_id);

drop policy if exists "own_update" on projects;
create policy "own_update" on projects for update using (auth.uid() = user_id);

drop policy if exists "own_delete" on projects;
create policy "own_delete" on projects for delete using (auth.uid() = user_id);

-- 3) updated_at 자동 갱신
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

drop trigger if exists trg_projects_updated on projects;
create trigger trg_projects_updated before update on projects
  for each row execute function set_updated_at();
