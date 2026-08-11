-- ==============================================================================
-- SKEMA DATABASE POSTGRESQL / SUPABASE
-- Aplikasi Pelayanan Kesehatan & Antrean Rumah Sakit (Multi-Role)
-- ==============================================================================

-- 1. ENUM TYPES
CREATE TYPE user_role AS ENUM ('patient', 'doctor', 'admin');
CREATE TYPE reservation_status AS ENUM ('waiting', 'in_progress', 'completed', 'cancelled');

-- 2. TABEL USERS (Terhubung dengan Supabase Auth: auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role user_role NOT NULL DEFAULT 'patient',
    phone_number VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABEL SPESIALIS (Specialists)
CREATE TABLE public.specialists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABEL UNIT / POLIKLINIK (Units)
CREATE TABLE public.units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    hospital_name VARCHAR(255) NOT NULL DEFAULT 'RS Sehat Sejahtera',
    address TEXT NOT NULL,
    latitude NUMERIC(10, 8) NOT NULL,
    longitude NUMERIC(11, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABEL DOKTER (Doctors)
CREATE TABLE public.doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL, -- opsional relasi ke akun auth dokter
    name VARCHAR(255) NOT NULL,
    specialist_id UUID NOT NULL REFERENCES public.specialists(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES public.units(id) ON DELETE CASCADE,
    schedule VARCHAR(255) NOT NULL, -- Contoh: "Senin - Jumat (08:00 - 12:00)"
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. TABEL RESERVASI / ANTREAN (Reservations)
CREATE TABLE public.reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    queue_number VARCHAR(50) NOT NULL, -- Contoh: "A-001"
    barcode_code VARCHAR(100) NOT NULL UNIQUE, -- Contoh: "RES-20260811-001"
    patient_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
    reservation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status reservation_status NOT NULL DEFAULT 'waiting',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- INDEXING UNTUK OPTIMASI PERFORMA QUERY
-- ==============================================================================
CREATE INDEX idx_doctors_specialist ON public.doctors(specialist_id);
CREATE INDEX idx_doctors_unit ON public.doctors(unit_id);
CREATE INDEX idx_reservations_patient ON public.reservations(patient_id);
CREATE INDEX idx_reservations_doctor ON public.reservations(doctor_id);
CREATE INDEX idx_reservations_barcode ON public.reservations(barcode_code);
CREATE INDEX idx_reservations_date_doctor ON public.reservations(reservation_date, doctor_id);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) & POLICIES (SUPABASE SECURITY)
-- ==============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.specialists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;

-- Policy Read Master Data (Dapat dibaca oleh public / anon)
CREATE POLICY "Public Read Specialists" ON public.specialists FOR SELECT USING (true);
CREATE POLICY "Public Read Units" ON public.units FOR SELECT USING (true);
CREATE POLICY "Public Read Doctors" ON public.doctors FOR SELECT USING (true);

-- Policy Users (User hanya bisa membaca/edit profilnya sendiri)
CREATE POLICY "User View Own Profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "User Update Own Profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Policy Reservations (Pasien hanya bisa lihat reservasinya sendiri, Dokter/Admin bisa lihat semua)
CREATE POLICY "Patient Read Own Reservations" ON public.reservations 
FOR SELECT USING (
    auth.uid() = patient_id OR 
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() AND users.role IN ('doctor', 'admin')
    )
);

CREATE POLICY "Patient Create Reservation" ON public.reservations 
FOR INSERT WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "Doctor/Admin Update Reservation Status" ON public.reservations 
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE users.id = auth.uid() AND users.role IN ('doctor', 'admin')
    )
-- Policy Master Data Full Access (Super Admin)
CREATE POLICY "Admin Full Access Specialists" ON public.specialists 
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'admin')
);

CREATE POLICY "Admin Full Access Units" ON public.units 
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'admin')
);

CREATE POLICY "Admin Full Access Doctors" ON public.doctors 
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'admin')
);

-- ==============================================================================
-- SEED DATA (DUMMY DATA AWAL)
-- ==============================================================================
INSERT INTO public.specialists (id, name, description) VALUES
('11111111-1111-1111-1111-111111111111', 'Spesialis Penyakit Dalam', 'Menangani organ dalam dewasa'),
('22222222-2222-2222-2222-222222222222', 'Spesialis Anak', 'Kesehatan dan tumbuh kembang anak');

INSERT INTO public.units (id, name, hospital_name, address, latitude, longitude) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Poliklinik Penyakit Dalam (Gedung A, Lt 2)', 'RS Sehat Sejahtera', 'Jl. Sudirman No. 45, Jakarta', -6.20880000, 106.84560000),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Poliklinik Anak (Gedung B, Lt 1)', 'RS Sehat Sejahtera', 'Jl. Sudirman No. 45, Jakarta', -6.20900000, 106.84600000);
