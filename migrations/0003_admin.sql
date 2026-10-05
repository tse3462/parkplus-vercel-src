alter table parking_settings
  add column if not exists admin_pin_hash text;

create table if not exists parking_admin_sessions (
  token_hash text primary key,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null
);

create index if not exists parking_admin_sessions_exp_idx
  on parking_admin_sessions (expires_at);
