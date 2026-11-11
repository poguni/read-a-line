-- 한 줄 독서 (Read a Line) v2 추가 스키마: 빙고 보상 + 효과음 설정
-- read_a_line 스키마 안의 객체만 다룹니다. public 스키마와 auth 설정은 건드리지 않습니다.

-- 효과음 설정 (기본 꺼짐)
alter table read_a_line.settings add column if not exists sound boolean not null default false;

-- 빙고 보상: 그 해 빙고판에서 N줄을 완성하면 받는 나만의 보상
create table read_a_line.rewards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  year int not null,
  lines smallint not null check (lines between 1 and 12),
  title text not null check (char_length(title) between 1 and 60),
  achieved_at timestamptz,
  claimed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index ral_rewards_user_year_idx on read_a_line.rewards (user_id, year);

alter table read_a_line.rewards enable row level security;
create policy "ral_own_rows" on read_a_line.rewards for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

grant select, insert, update, delete on read_a_line.rewards to authenticated;
