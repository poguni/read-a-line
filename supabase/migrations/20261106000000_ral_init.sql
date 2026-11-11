-- 한 줄 독서 (Read a Line) 초기 스키마
-- Supabase 프로젝트: Delicious Library (공유)
-- 이 파일은 read_a_line 스키마 안의 객체만 만듭니다. public 스키마와 auth 설정은 건드리지 않습니다.
-- 적용 후 대시보드 Project Settings > Data API > Exposed schemas 에 read_a_line 을 추가하세요.

create schema if not exists read_a_line;
grant usage on schema read_a_line to authenticated;

create table read_a_line.settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  nickname text,
  theme text not null default 'library' check (theme in ('library','pop','modern')),
  motion boolean not null default true,
  active_board_id uuid,
  updated_at timestamptz not null default now()
);

create table read_a_line.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  year int not null,
  target_books int not null check (target_books > 0),
  start_date date not null,
  end_date date not null check (end_date >= start_date),
  updated_at timestamptz not null default now(),
  unique (user_id, year)
);

create table read_a_line.books (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  author text,
  finished_at date not null,
  pages int check (pages > 0),
  rating smallint check (rating between 0 and 5),
  memo text,
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table read_a_line.boards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  year int not null,
  title text not null,
  size smallint not null check (size in (3,4,5)),
  free_center boolean not null default false,
  completed_lines text[] not null default '{}',
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table read_a_line.board_cells (
  board_id uuid not null references read_a_line.boards(id) on delete cascade,
  idx smallint not null,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  mission text not null,
  is_free boolean not null default false,
  book_id uuid references read_a_line.books(id) on delete set null,
  updated_at timestamptz not null default now(),
  primary key (board_id, idx)
);

create index on read_a_line.books (user_id, finished_at);
create index on read_a_line.boards (user_id, year);
create index on read_a_line.board_cells (book_id);

-- 모든 테이블: RLS 켜기 + 본인 행만 허용
alter table read_a_line.settings    enable row level security;
alter table read_a_line.goals       enable row level security;
alter table read_a_line.books       enable row level security;
alter table read_a_line.boards      enable row level security;
alter table read_a_line.board_cells enable row level security;

create policy "ral_own_rows" on read_a_line.settings    for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "ral_own_rows" on read_a_line.goals       for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "ral_own_rows" on read_a_line.books       for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "ral_own_rows" on read_a_line.boards      for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "ral_own_rows" on read_a_line.board_cells for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- 로그인한 사용자에게만 권한 부여 (anon에는 부여하지 않음)
grant select, insert, update, delete on all tables in schema read_a_line to authenticated;
