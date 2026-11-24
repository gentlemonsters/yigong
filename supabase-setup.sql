-- 南开义工之家 · Supabase 初始化脚本
-- 用法：Supabase 后台 → SQL Editor → New query → 粘贴全文 → Run

-- 1. 四张数据表
create table if not exists yigong_notices (
  id text primary key,
  title text not null default '',
  body text not null default '',
  author text not null default '',
  status text not null default 'draft',
  pinned boolean not null default false,
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create table if not exists yigong_members (
  id text primary key,
  name text not null default '',
  klass text not null default '',
  role text not null default '志愿者',
  joined text not null default '',
  count integer not null default 0,
  hours integer not null default 0,
  note text not null default ''
);

create table if not exists yigong_records (
  id text primary key,
  title text not null default '',
  date text not null default '',
  place text not null default '',
  text text not null default '',
  people jsonb not null default '[]'::jsonb,
  photos jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists yigong_posts (
  id text primary key,
  nick text not null default '',
  klass text not null default '',
  text text not null default '',
  at timestamptz not null default now(),
  likes integer not null default 0,
  replies jsonb not null default '[]'::jsonb
);

-- 2. 行级安全 + 匿名读写策略（先删后建，可重复执行）
alter table yigong_notices enable row level security;
alter table yigong_members enable row level security;
alter table yigong_records enable row level security;
alter table yigong_posts enable row level security;

drop policy if exists yigong_notices_all on yigong_notices;
create policy yigong_notices_all on yigong_notices for all using (true) with check (true);

drop policy if exists yigong_members_all on yigong_members;
create policy yigong_members_all on yigong_members for all using (true) with check (true);

drop policy if exists yigong_records_all on yigong_records;
create policy yigong_records_all on yigong_records for all using (true) with check (true);

drop policy if exists yigong_posts_all on yigong_posts;
create policy yigong_posts_all on yigong_posts for all using (true) with check (true);

-- 3. 照片存储桶（公开读，匿名可上传）
insert into storage.buckets (id, name, public)
values ('yigong', 'yigong', true)
on conflict (id) do update set public = true;

drop policy if exists yigong_storage_read on storage.objects;
create policy yigong_storage_read on storage.objects for select using (bucket_id = 'yigong');

drop policy if exists yigong_storage_insert on storage.objects;
create policy yigong_storage_insert on storage.objects for insert with check (bucket_id = 'yigong');

drop policy if exists yigong_storage_update on storage.objects;
create policy yigong_storage_update on storage.objects for update using (bucket_id = 'yigong');

drop policy if exists yigong_storage_delete on storage.objects;
create policy yigong_storage_delete on storage.objects for delete using (bucket_id = 'yigong');
