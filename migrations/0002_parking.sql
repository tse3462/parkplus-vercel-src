-- Parkhaus parking lot: sessions, payments, settings, event log.
-- Unowned rows (auth off). No user_id.

create table if not exists parking_settings (
  id integer primary key check (id = 1),
  lot_name text not null default 'Parkhaus Nord',
  lot_code text not null default 'PH-NORD',
  capacity integer not null default 120,
  hourly_rate numeric(10,2) not null default 2.50,
  daily_cap numeric(10,2) not null default 25.00,
  grace_minutes integer not null default 10,
  penalty_amount numeric(10,2) not null default 29.50,
  currency text not null default 'EUR',
  updated_at timestamptz not null default now()
);

insert into parking_settings (id) values (1) on conflict (id) do nothing;

create table if not exists parking_sessions (
  id text primary key,
  plate text not null,
  plate_norm text not null,
  entered_at timestamptz not null default now(),
  exited_at timestamptz,
  in_lot boolean not null default true,
  status text not null default 'open',
  close_reason text,
  penalty_fee numeric(10,2) not null default 0,
  paid_amount numeric(10,2) not null default 0,
  payment_method text,
  paid_at timestamptz,
  closed_at timestamptz,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists parking_sessions_status_idx on parking_sessions (status);
create index if not exists parking_sessions_plate_norm_idx on parking_sessions (plate_norm);
create index if not exists parking_sessions_in_lot_idx on parking_sessions (in_lot);
create index if not exists parking_sessions_entered_idx on parking_sessions (entered_at desc);

create table if not exists parking_payments (
  id text primary key,
  session_id text not null references parking_sessions(id),
  amount numeric(10,2) not null,
  method text not null,
  created_at timestamptz not null default now()
);

create index if not exists parking_payments_session_idx on parking_payments (session_id);

create table if not exists parking_events (
  id text primary key,
  session_id text,
  event_type text not null,
  detail text,
  created_at timestamptz not null default now()
);

create index if not exists parking_events_created_idx on parking_events (created_at desc);

-- Demo fleet so the admin panel is not empty on first load.
insert into parking_sessions (
  id, plate, plate_norm, entered_at, exited_at, in_lot, status,
  close_reason, penalty_fee, paid_amount, payment_method, paid_at, closed_at, notes
)
select * from (
  values
    (
      'ses_open_short',
      '34 ABC 123',
      '34ABC123',
      now() - interval '18 minutes',
      null::timestamptz,
      true,
      'open',
      null::text,
      0::numeric,
      0::numeric,
      null::text,
      null::timestamptz,
      null::timestamptz,
      null::text
    ),
    (
      'ses_open_long',
      '06 YK 458',
      '06YK458',
      now() - interval '2 hours 12 minutes',
      null,
      true,
      'open',
      null,
      0,
      0,
      null,
      null,
      null,
      null
    ),
    (
      'ses_open_overnight',
      '16 BL 902',
      '16BL902',
      now() - interval '9 hours 40 minutes',
      null,
      true,
      'open',
      null,
      0,
      0,
      null,
      null,
      null,
      null
    ),
    (
      'ses_penalty_left',
      '35 M 1907',
      '35M1907',
      now() - interval '4 hours 5 minutes',
      now() - interval '22 minutes',
      false,
      'open',
      null,
      29.50,
      0,
      null,
      null,
      null,
      'Cikis kamerasi odemesiz cikisi tespit etti'
    ),
    (
      'ses_closed_card',
      '34 PRK 01',
      '34PRK01',
      now() - interval '3 hours 20 minutes',
      now() - interval '12 minutes',
      false,
      'closed',
      'paid',
      0,
      7.50,
      'card',
      now() - interval '15 minutes',
      now() - interval '15 minutes',
      null
    ),
    (
      'ses_closed_apple',
      '07 TS 221',
      '07TS221',
      now() - interval '1 hour 5 minutes',
      now() - interval '8 minutes',
      false,
      'closed',
      'paid',
      0,
      2.50,
      'apple_pay',
      now() - interval '10 minutes',
      now() - interval '10 minutes',
      null
    ),
    (
      'ses_closed_waived',
      '41 KM 44',
      '41KM44',
      now() - interval '6 hours',
      now() - interval '2 hours',
      false,
      'closed',
      'waived',
      0,
      0,
      'waive',
      now() - interval '2 hours',
      now() - interval '2 hours',
      'Operator feragat'
    )
) as seed(
  id, plate, plate_norm, entered_at, exited_at, in_lot, status,
  close_reason, penalty_fee, paid_amount, payment_method, paid_at, closed_at, notes
)
where not exists (select 1 from parking_sessions limit 1);

insert into parking_payments (id, session_id, amount, method, created_at)
select * from (
  values
    ('pay_card_1', 'ses_closed_card', 7.50, 'card', now() - interval '15 minutes'),
    ('pay_apple_1', 'ses_closed_apple', 2.50, 'apple_pay', now() - interval '10 minutes')
) as p(id, session_id, amount, method, created_at)
where exists (select 1 from parking_sessions where id = p.session_id)
  and not exists (select 1 from parking_payments limit 1);

insert into parking_events (id, session_id, event_type, detail, created_at)
select * from (
  values
    ('ev_1', 'ses_open_short', 'entry', 'Kamera CAM-01 plaka okudu', now() - interval '18 minutes'),
    ('ev_2', 'ses_open_long', 'entry', 'Kamera CAM-01 plaka okudu', now() - interval '2 hours 12 minutes'),
    ('ev_3', 'ses_open_overnight', 'entry', 'Kamera CAM-01 plaka okudu', now() - interval '9 hours 40 minutes'),
    ('ev_4', 'ses_penalty_left', 'entry', 'Kamera CAM-01 plaka okudu', now() - interval '4 hours 5 minutes'),
    ('ev_5', 'ses_penalty_left', 'penalty', 'Odemesiz cikis — ceza 29,50 EUR', now() - interval '22 minutes'),
    ('ev_6', 'ses_closed_card', 'entry', 'Kamera CAM-01 plaka okudu', now() - interval '3 hours 20 minutes'),
    ('ev_7', 'ses_closed_card', 'payment', 'Kreditkarte 7,50 EUR', now() - interval '15 minutes'),
    ('ev_8', 'ses_closed_apple', 'entry', 'Kamera CAM-01 plaka okudu', now() - interval '1 hour 5 minutes'),
    ('ev_9', 'ses_closed_apple', 'payment', 'Apple Pay 2,50 EUR', now() - interval '10 minutes'),
    ('ev_10', 'ses_closed_waived', 'waive', 'Odemeden feragat', now() - interval '2 hours')
) as e(id, session_id, event_type, detail, created_at)
where not exists (select 1 from parking_events limit 1);
