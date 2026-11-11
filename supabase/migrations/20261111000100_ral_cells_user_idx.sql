-- 한 줄 독서: board_cells.user_id 외래 키 인덱스 (Supabase 성능 권고 반영, RLS 조회에도 사용)
create index if not exists ral_board_cells_user_idx on read_a_line.board_cells (user_id);
