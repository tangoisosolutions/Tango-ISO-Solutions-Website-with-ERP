-- Run once in Supabase: SQL Editor > New query > Run
create table if not exists profiles(id uuid primary key references auth.users on delete cascade,email text,full_name text default '',role text not null default 'employee' check(role in('admin','employee')),active boolean not null default false,created_at timestamptz default now());
create or replace function handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into profiles(id,email,full_name) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name','')); return new; end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();
create or replace function is_staff() returns boolean language sql security definer stable set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and active) $$;
create or replace function is_admin() returns boolean language sql security definer stable set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and active and role='admin') $$;
create sequence if not exists q_seq;create sequence if not exists so_seq;create sequence if not exists inv_seq;
create table if not exists inquiries(id uuid primary key default gen_random_uuid(),created_at timestamptz default now(),name text not null,company text,email text not null,phone text,service text,message text,status text not null default 'new' check(status in('new','converted','closed')),close_reason text);
create table if not exists customers(id uuid primary key default gen_random_uuid(),created_at timestamptz default now(),company text not null,address text,contact_name text,designation text,email text,gst text,pan text,service text,inquiry_id uuid);
create table if not exists quotations(id uuid primary key default gen_random_uuid(),created_at timestamptz default now(),qdate date default current_date,customer_id uuid references customers on delete set null,company text,subject text,number text unique default ('QTN-'||lpad(nextval('q_seq')::text,4,'0')),value numeric default 0,status text not null default 'Pending' check(status in('Pending','Accepted','Closed')),data jsonb default '{}',so_number text,po_number text,po_date date);
create table if not exists invoices(id uuid primary key default gen_random_uuid(),created_at timestamptz default now(),idate date default current_date,quotation_id uuid references quotations on delete set null,customer_id uuid references customers on delete set null,company text,subject text,number text unique default ('INV-'||lpad(nextval('inv_seq')::text,4,'0')),value numeric default 0,status text not null default 'Pending' check(status in('Pending','Paid')),data jsonb default '{}');
create or replace function set_so() returns trigger language plpgsql as $$ begin if new.status='Accepted' and new.so_number is null then new.so_number:='SO-'||lpad(nextval('so_seq')::text,4,'0'); end if; return new; end $$;
drop trigger if exists quo_so on quotations;
create trigger quo_so before insert or update on quotations for each row execute function set_so();
grant usage on sequence q_seq,so_seq,inv_seq to authenticated;
alter table profiles enable row level security;
drop policy if exists "own or admin read" on profiles;drop policy if exists "admin update" on profiles;
create policy "own or admin read" on profiles for select to authenticated using (id=auth.uid() or is_admin());
create policy "admin update" on profiles for update to authenticated using (is_admin()) with check (is_admin());
do $$ declare t text; begin foreach t in array array['inquiries','customers','quotations','invoices'] loop
 execute format('alter table %I enable row level security',t);
 execute format('drop policy if exists "staff read" on %I',t);execute format('drop policy if exists "staff update" on %I',t);execute format('drop policy if exists "admin delete" on %I',t);
 execute format('create policy "staff read" on %I for select to authenticated using (is_staff())',t);
 execute format('create policy "staff update" on %I for update to authenticated using (is_staff()) with check (is_staff())',t);
 execute format('create policy "admin delete" on %I for delete to authenticated using (is_admin())',t);
end loop; end $$;
drop policy if exists "staff insert" on customers;drop policy if exists "staff insert" on quotations;drop policy if exists "staff insert" on invoices;drop policy if exists "public inquiry" on inquiries;
create policy "staff insert" on customers for insert to authenticated with check (is_staff());
create policy "staff insert" on quotations for insert to authenticated with check (is_staff());
create policy "staff insert" on invoices for insert to authenticated with check (is_staff());
create policy "public inquiry" on inquiries for insert to anon,authenticated with check (status='new' and length(coalesce(message,''))<=1500);
-- AFTER creating your own login (Authentication > Users > Add user, tick Auto Confirm), make yourself admin:
-- update profiles set role='admin', active=true, full_name='Aditya' where email='tangoisosolutions@gmail.com';
