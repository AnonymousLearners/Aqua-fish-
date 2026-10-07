-- Aqua Fish Aquarium: run this whole file once in Supabase > SQL Editor
create table categories(id uuid primary key default gen_random_uuid(), name text not null, description text, emoji text default '🐟', created_at timestamptz default now());
create table products(id uuid primary key default gen_random_uuid(), name text not null, category_id uuid references categories(id) on delete set null, price numeric not null default 0, description text, image_url text, in_stock boolean default true, featured boolean default false, sku text, created_at timestamptz default now(), updated_at timestamptz default now());
create table services(id uuid primary key default gen_random_uuid(), name text not null, description text, active boolean default true, created_at timestamptz default now());
create table service_requests(id uuid primary key default gen_random_uuid(), customer_name text, customer_phone text, service_id uuid references services(id) on delete set null, service_name text, message text, status text default 'New', created_at timestamptz default now());
create table orders(id uuid primary key default gen_random_uuid(), customer_name text, customer_phone text, items jsonb, total numeric, status text default 'New', created_at timestamptz default now());
create table store_settings(id int primary key default 1 check(id=1), store_name text, phone1 text, phone2 text, email text, address text, opening_time text, closing_time text, about text, maps_url text);

alter table categories enable row level security; alter table products enable row level security; alter table services enable row level security;
alter table service_requests enable row level security; alter table orders enable row level security; alter table store_settings enable row level security;

-- Public: read only
create policy "public read" on categories for select using (true);
create policy "public read" on products for select using (true);
create policy "public read" on services for select using (true);
create policy "public read" on store_settings for select using (true);
-- Public may only CREATE service requests / orders (never read them)
create policy "public create" on service_requests for insert to anon, authenticated with check (true);
create policy "public create" on orders for insert to anon, authenticated with check (true);
-- Admin (the single logged-in owner account): everything
create policy "admin all" on categories for all to authenticated using (true) with check (true);
create policy "admin all" on products for all to authenticated using (true) with check (true);
create policy "admin all" on services for all to authenticated using (true) with check (true);
create policy "admin all" on service_requests for all to authenticated using (true) with check (true);
create policy "admin all" on orders for all to authenticated using (true) with check (true);
create policy "admin all" on store_settings for all to authenticated using (true) with check (true);

-- Image storage
insert into storage.buckets(id,name,public) values('product-images','product-images',true);
create policy "public view images" on storage.objects for select using (bucket_id='product-images');
create policy "admin upload images" on storage.objects for insert to authenticated with check (bucket_id='product-images');
create policy "admin update images" on storage.objects for update to authenticated using (bucket_id='product-images');
create policy "admin delete images" on storage.objects for delete to authenticated using (bucket_id='product-images');

-- Starter data (all editable later in the dashboard)
insert into store_settings values(1,'Aqua Fish Aquarium','8081818123','9984947701','harshgupta.techy@gmail.com','Ratapur Chauraha, near Polytechnic, Raebareli, Uttar Pradesh, India','8:00 AM','9:00 PM','Aqua Fish Aquarium is a local aquarium, pet and bird store in Raebareli, offering fish, aquariums, aquarium equipment, pet food, bird cages, accessories and aquarium services. Visit us at Ratapur Chauraha, near Polytechnic.','https://www.google.com/maps/search/?api=1&query=Aqua+Fish+Aquarium+Ratapur+Chauraha+Raebareli');
insert into categories(name,emoji) values('Fish','🐠'),('Aquariums','🐟'),('Filters','🌀'),('Heaters','🔥'),('Air & Water Pumps','💨'),('Decorations & Toys','🪸'),('Fish Food','🍤'),('Turtle','🐢'),('Dog','🐕'),('Birds & Cages','🦜'),('Plants & Gravel','🌿'),('Medicines & Water Care','💧'),('Accessories','🧰');
insert into products(name,category_id,price,description,featured)
select p.n,(select id from categories where name=p.c),p.pr,p.d,p.f from (values
('Goldfish','Fish',120,'Healthy, active goldfish.',true),('Guppy Pair','Fish',80,'Colourful guppy pair.',true),
('Small Aquarium Tank','Aquariums',899,'Compact glass tank for beginners.',true),('Aquarium Filter','Filters',450,'Quiet internal filter.',false),
('Aquarium Heater','Heaters',550,'Keeps water at a steady temperature.',false),('Air Pump','Air & Water Pumps',300,'Double-outlet air pump.',false),
('Water Pump','Air & Water Pumps',400,'Submersible aquarium pump.',false),('Aquarium Decoration','Decorations & Toys',199,'Decor for your tank.',false),
('Fish Food','Fish Food',120,'Daily flakes for tropical fish.',true),('Turtle Food','Turtle',180,'Balanced turtle food.',false),
('Dog Food','Dog',350,'Nutritious dog food.',false),('Bird Cage','Birds & Cages',750,'Sturdy bird cage.',true),
('Bird Food','Birds & Cages',140,'Seed mix for birds.',false),('Bird Accessories','Birds & Cages',120,'Feeders and toys.',false),
('Aquarium Gravel','Plants & Gravel',150,'Clean aquarium gravel.',false),('Water Care Product','Medicines & Water Care',220,'Water conditioner.',false)
) as p(n,c,pr,d,f);
insert into services(name,description) values
('Aquarium Installation','Tank setup, equipment installation and basic aquarium arrangement.'),
('Aquarium Cleaning','Aquarium cleaning and water-care support.'),
('Aquarium Maintenance','Regular aquarium maintenance.'),
('Filter/Pump Installation','Installation of aquarium filters and pumps.'),
('Water Change','Aquarium water-change service.'),
('Aquarium Decoration / Setup','Aquarium decoration and complete setup assistance.');
