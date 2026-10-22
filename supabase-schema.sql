-- Run after reviewing in a fresh Supabase project.
create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade, full_name text not null, member_code text unique not null, referral_code text unique not null, referred_by uuid references public.profiles(id), created_at timestamptz not null default now(), check(referred_by is null or referred_by<>id));
create table if not exists public.products(id uuid primary key default gen_random_uuid(),name text not null,description text not null default '',price_pkr numeric(12,2) not null check(price_pkr>0),commission_percent numeric(5,2) not null default 0 check(commission_percent between 0 and 50),active boolean not null default true,created_at timestamptz not null default now());
create table if not exists public.orders(id uuid primary key default gen_random_uuid(),buyer_id uuid references public.profiles(id),product_id uuid not null references public.products(id),quantity integer not null check(quantity>0 and quantity<=10000),unit_price_pkr numeric(12,2) not null check(unit_price_pkr>0),referrer_id uuid references public.profiles(id),status text not null default 'pending' check(status in ('pending','confirmed','cancelled','refunded')),created_at timestamptz not null default now());
create table if not exists public.commission_ledger(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id) on delete cascade,member_id uuid not null references public.profiles(id),amount_pkr numeric(12,2) not null check(amount_pkr>=0),status text not null default 'pending' check(status in ('pending','approved','paid','reversed')),created_at timestamptz not null default now(),unique(order_id,member_id));
create table if not exists public.admin_users(user_id uuid primary key references auth.users(id) on delete cascade);
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.admin_users where user_id=auth.uid()); $$;
alter table public.profiles enable row level security; alter table public.products enable row level security; alter table public.orders enable row level security; alter table public.commission_ledger enable row level security; alter table public.admin_users enable row level security;
create policy "profiles read own referrals admin" on public.profiles for select to authenticated using(id=auth.uid() or referred_by=auth.uid() or public.is_admin());
create policy "profile insert self" on public.profiles for insert to authenticated with check(id=auth.uid() and referred_by is distinct from id);
create policy "profile update self" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy "active products readable" on public.products for select to anon,authenticated using(active=true or public.is_admin());
create policy "admins manage products" on public.products for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "read related orders" on public.orders for select to authenticated using(buyer_id=auth.uid() or referrer_id=auth.uid() or public.is_admin());
create policy "buyer creates own order" on public.orders for insert to authenticated with check(buyer_id=auth.uid());
create policy "admin updates orders" on public.orders for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "read own commissions" on public.commission_ledger for select to authenticated using(member_id=auth.uid() or public.is_admin());
create policy "admin manages commissions" on public.commission_ledger for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "read own admin record" on public.admin_users for select to authenticated using(user_id=auth.uid() or public.is_admin());
-- Owner promotion: after creating your own account, run a separate SQL statement:
-- insert into public.admin_users(user_id) values ('YOUR_AUTH_USER_UUID');
-- This should only be run by the project owner in the Supabase SQL editor.
-- Before production, add secure server-side profile creation, referral-code validation,
-- server-side order price validation and commission functions/triggers.
