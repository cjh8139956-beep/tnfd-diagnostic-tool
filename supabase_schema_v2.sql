-- v2 추가: PDF 파일 저장(Storage) + 진단대상/BM 회사명 컬럼 + 페이지 텍스트 캐시
-- Supabase SQL Editor 에 통째로 붙여넣고 RUN

-- 1) projects 테이블에 컬럼 추가 (이미 있으면 무시됨)
alter table projects add column if not exists pdf_path text;
alter table projects add column if not exists bm_path text;
alter table projects add column if not exists bm_client_name text;
alter table projects add column if not exists pdf_texts jsonb;   -- [{page:1, text:"..."}, ...]
alter table projects add column if not exists bm_texts jsonb;

-- 2) Storage 버킷 생성 (PDF 보관용, private)
insert into storage.buckets (id, name, public)
  values ('pdfs', 'pdfs', false)
on conflict (id) do nothing;

-- 3) Storage RLS — 본인 폴더만 접근
-- 경로 규칙: {user_id}/{file_id}.pdf
drop policy if exists "pdf_own_select" on storage.objects;
create policy "pdf_own_select" on storage.objects for select
  using (bucket_id='pdfs' and auth.uid()::text = (storage.foldername(name))[1]);

drop policy if exists "pdf_own_insert" on storage.objects;
create policy "pdf_own_insert" on storage.objects for insert
  with check (bucket_id='pdfs' and auth.uid()::text = (storage.foldername(name))[1]);

drop policy if exists "pdf_own_delete" on storage.objects;
create policy "pdf_own_delete" on storage.objects for delete
  using (bucket_id='pdfs' and auth.uid()::text = (storage.foldername(name))[1]);
