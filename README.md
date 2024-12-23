# Finance Manager Apps

![Group 1000001074](https://github.com/user-attachments/assets/79c7d1cc-384b-41ac-b2ee-43dd3f1328e2)

Finance Manager Apps is a financial management application designed to help users manage their finances easily. This application is built using **Flutter**, integrated with **Supabase** as a backend-as-a-service, and **Xendit** for payment features. All backend functionalities are managed without additional servers, ensuring a simpler and more efficient implementation.

## Key Features
- **Financial Management**: Manage your balance and financial records effortlessly.
- **Virtual Account (VA)**: Create and manage Virtual Accounts with Xendit API integration.
- **No Backend Required**: Utilizes Supabase for all authentication and data storage needs.

## Technologies Used
- **Flutter**: Main framework for application development.
- **Supabase**: Backend-as-a-service for authentication and data storage.
- **Xendit**: Payment provider for Virtual Account services.

### Flutter & Dart Versions
- **Flutter**: Version 3.19.5
- **Dart**: Version 3.3.3

## How to Use

### 1. Clone the Repository
Clone this repository to your local machine using the following command:

```bash
git clone https://github.com/nurd0tid/Finance-Manager-Apps.git
cd Finance-Manager-Apps
```

### 2. Install Dependencies
Run the following command to download all required dependencies:

```bash
flutter pub get
```

### 3. Configure API Keys
Open the file `lib/utils/constants.dart` and add your API keys as shown below:

```dart
class Constants {
  static const String supabaseUrl = 'your_supabase_url';
  static const String supabaseKey = 'your_supabase_key';
  static const String xenditApiKey = 'your_xendit_api_key';
}
```

- **supabaseUrl**: Your Supabase project URL.
- **supabaseKey**: The API Key from Supabase.
- **xenditApiKey**: The API Key from Xendit.

### 4. Setup Database
Set up your Supabase database by executing the following SQL commands in the Supabase SQL editor:

```sql
create table
  public.users (
    id uuid not null default extensions.uuid_generate_v4 (),
    name text not null,
    email text not null,
    balance integer not null default 0,
    created_at timestamp without time zone null default now(),
    virtual_account text null,
    bank_code text null,
    va_expired_at timestamp without time zone null,
    external_id text null,
    constraint users_pkey primary key (id),
    constraint users_email_key unique (email)
  ) tablespace pg_default;

create table
  public.transactions (
    id uuid not null default extensions.uuid_generate_v4 (),
    user_id uuid null,
    type text not null,
    amount integer not null,
    status text not null,
    created_at timestamp without time zone null default now(),
    external_id text null,
    updated_at timestamp without time zone null,
    constraint transactions_pkey primary key (id),
    constraint transactions_user_id_fkey foreign key (user_id) references users (id) on delete cascade,
    constraint transactions_status_check check (
      (
        status = any (
          array[
            'pending'::text,
            'completed'::text,
            'failed'::text
          ]
        )
      )
    ),
    constraint transactions_type_check check (
      (
        type = any (array['topup'::text, 'withdraw'::text])
      )
    )
  ) tablespace pg_default;

create table
  public.transaction_history (
    id bigserial not null,
    user_id uuid not null,
    transaction_id text not null,
    description text not null,
    amount numeric(15, 2) not null,
    transaction_type text not null,
    created_at timestamp without time zone null default now(),
    constraint transaction_history_pkey primary key (id),
    constraint transaction_history_user_id_fkey foreign key (user_id) references users (id)
  ) tablespace pg_default;

create table
  public.explore (
    id uuid not null default gen_random_uuid (),
    image character varying null,
    title character varying null,
    sub_title character varying null,
    price numeric null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone null default now(),
    constraint explore_pkey primary key (id)
  ) tablespace pg_default;
```

### 5. Add RPC to Supabase
Add the following RPC function in the Supabase SQL editor:

```sql
CREATE OR REPLACE FUNCTION process_payment(
  user_id_param UUID,
  amount INTEGER,
  description TEXT,
  explore_id_param UUID
) RETURNS TEXT AS $$
DECLARE
  current_balance INTEGER;
  transaction_id UUID;
BEGIN
  -- Ambil saldo saat ini
  SELECT balance INTO current_balance
  FROM users
  WHERE id = user_id_param;

  -- Validasi apakah saldo cukup
  IF current_balance IS NULL THEN
    RAISE EXCEPTION 'User not found: %', user_id_param;
  ELSIF current_balance < amount THEN
    RAISE EXCEPTION 'Insufficient balance for payment: %', user_id_param;
  END IF;

  -- Kurangi saldo pengguna
  UPDATE users
  SET balance = balance - amount
  WHERE id = user_id_param;

  -- Simpan log transaksi ke tabel transactions
  INSERT INTO transactions (
    user_id, 
    amount, 
    type, 
    status,
    explore_id
  )
  VALUES (
    user_id_param,
    amount,
    'explore',
    'completed',
    explore_id_param
  )
  RETURNING id INTO transaction_id;

  -- Simpan log tambahan ke tabel transaction_history
  INSERT INTO transaction_history (
    user_id,
    transaction_id,
    description,
    amount,
    transaction_type,
    explore_id
  )
  VALUES (
    user_id_param,
    transaction_id,
    description,
    amount,
    'explore',
    explore_id_param
  );

  -- Kembalikan status sukses
  RETURN 'Payment processed successfully';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_withdrawal(
  user_id_param UUID,
  amount INTEGER,
  description TEXT
) RETURNS TEXT AS $$
DECLARE
  current_balance INTEGER;
  transaction_id UUID;
BEGIN
  -- Ambil saldo saat ini
  SELECT balance INTO current_balance
  FROM users
  WHERE id = user_id_param;

  -- Validasi apakah saldo cukup
  IF current_balance IS NULL THEN
    RAISE EXCEPTION 'User not found: %', user_id_param;
  ELSIF current_balance < amount THEN
    RAISE EXCEPTION 'Insufficient balance for withdrawal: %', user_id_param;
  END IF;

  -- Kurangi saldo pengguna
  UPDATE users
  SET balance = balance - amount
  WHERE id = user_id_param;

  -- Simpan log transaksi ke tabel transactions
  INSERT INTO transactions (
    user_id, 
    amount, 
    type, 
    status
  )
  VALUES (
    user_id_param,
    amount,
    'withdraw',
    'completed'
  )
  RETURNING id INTO transaction_id;

  -- Simpan log tambahan ke tabel transaction_history
  INSERT INTO transaction_history (
    user_id,
    transaction_id,
    description,
    amount,
    transaction_type
  )
  VALUES (
    user_id_param,
    transaction_id,
    description,
    amount,
    'withdraw'
  );

  -- Kembalikan status sukses
  RETURN 'Withdrawal processed successfully';
END;
$$ LANGUAGE plpgsql;


-- WEBHOOK XENDIT
CREATE OR REPLACE FUNCTION update_balance_on_va_payment(
  account_number TEXT,
  amount INTEGER,
  bank_code TEXT,
  callback_virtual_account_id TEXT,
  country TEXT,
  created TIMESTAMP,
  currency TEXT,
  external_id TEXT,
  id TEXT,
  merchant_code TEXT,
  owner_id TEXT,
  payment_id TEXT,
  transaction_timestamp TIMESTAMP,
  updated TIMESTAMP
) RETURNS VOID AS $$
DECLARE
  user_id UUID;
  full_va TEXT;
BEGIN
  -- Gabungkan merchant_code dan account_number untuk mencocokkan virtual_account
  full_va := CONCAT(merchant_code, account_number);

  -- Cari user_id berdasarkan virtual_account yang digabung
  SELECT u.id INTO user_id
  FROM users u
  WHERE u.virtual_account = full_va;

  -- Jika user_id tidak ditemukan, keluarkan error
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'User not found for virtual_account %', full_va;
  END IF;

  -- Perbarui saldo pengguna
  UPDATE users u
  SET balance = COALESCE(u.balance, 0) + amount
  WHERE u.id = user_id;

  -- Simpan log transaksi ke tabel transactions
  INSERT INTO transactions (
    user_id, 
    amount, 
    type, 
    status, 
    external_id
  )
  VALUES (
    user_id,
    amount,
    'topup',
    'completed',
    external_id
  );

  -- Simpan log tambahan ke tabel transaction_history
  INSERT INTO transaction_history (
    user_id,
    transaction_id,
    description,
    amount,
    transaction_type
  )
  VALUES (
    user_id,
    id, -- Ambil dari parameter fungsi
    CONCAT('Top-Up'),
    amount,
    'topup'
  );
END;
$$ LANGUAGE plpgsql;

-- GET TRANSACTION
create or replace function get_user_transactions_limit(p_user_id uuid, p_limit int)
returns table (
  id bigint,           
  user_id uuid,
  explore_id uuid,
  created_at timestamptz,
  amount numeric,
  description text,
  transaction_type text,
  image varchar,
  title varchar,
  sub_title varchar,
  price numeric
) as $$
begin
  return query
  select 
    t.id,
    t.user_id,
    t.explore_id,
    t.created_at,
    t.amount,              -- Ambil kolom amount
    t.description,         -- Ambil kolom description
    t.transaction_type,    -- Ambil kolom transaction_type
    coalesce(e.image, '') as image,
    coalesce(e.title, '') as title,
    coalesce(e.sub_title, '') as sub_title,
    coalesce(e.price, 0) as price
  from transaction_history t
  left join explore e on t.explore_id = e.id
  where t.user_id = p_user_id
  order by t.created_at desc
  limit p_limit;
end;
$$ language plpgsql security definer;

create or replace function get_user_transactions_all(p_user_id uuid)
returns table (
  id bigint,           
  user_id uuid,
  explore_id uuid,
  created_at timestamptz,
  amount numeric,
  description text,
  transaction_type text,
  image varchar,
  title varchar,
  sub_title varchar,
  price numeric
) as $$
begin
  return query
  select 
    t.id,
    t.user_id,
    t.explore_id,
    t.created_at,
    t.amount,              -- Ambil kolom amount
    t.description,         -- Ambil kolom description
    t.transaction_type,    -- Ambil kolom transaction_type
    coalesce(e.image, '') as image,
    coalesce(e.title, '') as title,
    coalesce(e.sub_title, '') as sub_title,
    coalesce(e.price, 0) as price
  from transaction_history t
  left join explore e on t.explore_id = e.id
  where t.user_id = p_user_id
  order by t.created_at desc;
end;
$$ language plpgsql security definer;


-- GET STATISTICS
create or replace function get_user_statistics(p_user_id uuid, p_type_transaction text default null)
returns json as $$
declare
  user_balance numeric;
  chart_data json;
  transactions json;
begin
  -- Ambil balance user dari tabel users
  select balance into user_balance
  from users
  where id = p_user_id;

  -- Ambil data chart untuk 6 bulan terakhir
  with monthly_series as (
    select 
      generate_series(
        date_trunc('month', now()) - interval '5 months',
        date_trunc('month', now()),
        interval '1 month'
      ) as month
  ),
  monthly_data as (
    select 
      to_char(ms.month, 'Mon') as month_name, -- Nama bulan (e.g., Jan, Feb)
      coalesce(sum(th.amount), 0) as total_amount
    from monthly_series ms
    left join transaction_history th
      on date_trunc('month', th.created_at) = ms.month
      and th.user_id = p_user_id
      and (
        p_type_transaction is null or
        (p_type_transaction = 'income' and th.transaction_type = 'topup') or
        (p_type_transaction = 'expenses' and th.transaction_type in ('withdraw', 'explore'))
      )
    group by ms.month
    order by ms.month
  ),
  indexed_data as (
    select 
      row_number() over () - 1 as index, -- Tambahkan indeks dari 0
      month_name,
      total_amount
    from monthly_data
  )
  select json_agg(json_build_object(
    'index', index,
    'month', month_name,
    'amount', total_amount
  )) into chart_data
  from indexed_data;

  -- Ambil daftar 5 transaksi terbaru berdasarkan filter
    SELECT json_agg(json_build_object(
        'id', id,
        'amount', amount,
        'description', description,
        'title', title,
        'sub_title', sub_title,
        'image', image,
        'created_at', created_at,
        'transaction_type', transaction_type
    )) INTO transactions
    FROM (
        SELECT 
          th.id, 
          th.amount, 
          th.description, 
          th.created_at, 
          th.transaction_type,
          e.title,
          e.sub_title,
          e.image
        FROM transaction_history th
        LEFT JOIN explore e ON th.explore_id = e.id
        WHERE th.user_id = p_user_id
          AND (
            p_type_transaction IS NULL OR
            (p_type_transaction = 'income' AND th.transaction_type = 'topup') OR
            (p_type_transaction = 'expenses' AND th.transaction_type IN ('withdraw', 'explore'))
          )
        ORDER BY th.created_at DESC
        LIMIT 5
    ) AS latest_transactions;


  -- Return data dalam satu JSON object
  return json_build_object(
    'balance', user_balance,
    'chart_data', chart_data,
    'transactions', transactions
  );
end;
$$ language plpgsql;
```

Add the RPC URL to the Webhook URL on the Xendit dashboard under **FVA Virtual Accounts**:

- **FVA Paid**: `https://your-url-supabase/rest/v1/rpc/update_balance_on_va_payment?apikey=anon-key`

### 6. Enable RLS Policies
Ensure that **Row Level Security (RLS)** is enabled for all tables in Supabase and set the policy for roles `public` with the following:

- **Using Expression**: `true`
- **With Check Expression**: `true`

### 7. Run the Application
Use the following command to run the application on an emulator or physical device:

```bash
flutter run
```

## Project Structure
The project uses an organized folder structure for better code management:

```
lib/
├── controllers/   # Application logic controllers
├── models/        # Data models
├── screens/       # Application screens
├── services/      # Services for APIs and business logic
│   ├── supabase_service.dart
│   ├── xendit_service.dart
├── utils/         # Utilities like constants, validators, and formatters
│   ├── constants.dart
│   ├── validator.dart
│   ├── formatters.dart
└── assets/        # Static files like images and fonts
```

## Main Dependencies
- **http** (version 1.2.2 or above): For making HTTP requests.
- **intl** (version 0.18): For formatting data, such as currency.

## License
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

Enjoy using Finance Manager Apps! If you encounter any issues or have questions, feel free to reach out via the *Issues* section in this repository.
