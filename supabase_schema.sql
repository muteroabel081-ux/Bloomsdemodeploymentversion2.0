-- ══════════════════════════════════════════════════════════
-- BLOOMS Junior School — Supabase Schema
-- Generated from: packages/database/prisma/schema.prisma
--
-- HOW TO USE:
--   1. Go to supabase.com → Your Project → SQL Editor
--   2. Paste this entire file and click "Run"
--   3. All 11 tables + indexes + foreign keys will be created
--
-- Safe to re-run: uses IF NOT EXISTS / DO blocks for enums
-- ══════════════════════════════════════════════════════════

-- ── Enums ─────────────────────────────────────────────────
-- (PostgreSQL doesn't support CREATE TYPE IF NOT EXISTS,
--  so we use DO blocks to skip if they already exist)

DO $$ BEGIN
  CREATE TYPE "UserRole" AS ENUM ('ADMIN', 'STAFF');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "StaffRole" AS ENUM ('TEACHER', 'ADMIN', 'ACCOUNTANT', 'HEADTEACHER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "FeeStatus" AS ENUM ('UNPAID', 'PARTIAL', 'PAID', 'WAIVED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ── NextAuth: users ───────────────────────────────────────

CREATE TABLE IF NOT EXISTS "users" (
    "id"            TEXT          NOT NULL,
    "name"          TEXT,
    "email"         TEXT,
    "emailVerified" TIMESTAMP(3),
    "image"         TEXT,
    "password"      TEXT,
    "role"          "UserRole"    NOT NULL DEFAULT 'STAFF',
    "staffId"       TEXT,
    "createdAt"     TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"     TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "users_email_key"   ON "users"("email");
CREATE UNIQUE INDEX IF NOT EXISTS "users_staffId_key" ON "users"("staffId");

-- ── NextAuth: accounts ────────────────────────────────────

CREATE TABLE IF NOT EXISTS "accounts" (
    "id"                TEXT    NOT NULL,
    "userId"            TEXT    NOT NULL,
    "type"              TEXT    NOT NULL,
    "provider"          TEXT    NOT NULL,
    "providerAccountId" TEXT    NOT NULL,
    "refresh_token"     TEXT,
    "access_token"      TEXT,
    "expires_at"        INTEGER,
    "token_type"        TEXT,
    "scope"             TEXT,
    "id_token"          TEXT,
    "session_state"     TEXT,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "accounts_provider_providerAccountId_key"
    ON "accounts"("provider", "providerAccountId");

-- ── NextAuth: sessions ────────────────────────────────────

CREATE TABLE IF NOT EXISTS "sessions" (
    "id"           TEXT         NOT NULL,
    "sessionToken" TEXT         NOT NULL,
    "userId"       TEXT         NOT NULL,
    "expires"      TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "sessions_sessionToken_key"
    ON "sessions"("sessionToken");

-- ── NextAuth: verification_tokens ────────────────────────

CREATE TABLE IF NOT EXISTS "verification_tokens" (
    "identifier" TEXT         NOT NULL,
    "token"      TEXT         NOT NULL,
    "expires"    TIMESTAMP(3) NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS "verification_tokens_token_key"
    ON "verification_tokens"("token");
CREATE UNIQUE INDEX IF NOT EXISTS "verification_tokens_identifier_token_key"
    ON "verification_tokens"("identifier", "token");

-- ── Staff ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "staff" (
    "id"        TEXT         NOT NULL,
    "firstName" TEXT         NOT NULL,
    "lastName"  TEXT         NOT NULL,
    "email"     TEXT         NOT NULL,
    "phone"     TEXT,
    "role"      "StaffRole"  NOT NULL DEFAULT 'TEACHER',
    "hireDate"  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "active"    BOOLEAN      NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "staff_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "staff_email_key" ON "staff"("email");

-- ── Classes ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "classes" (
    "id"                TEXT         NOT NULL,
    "name"              TEXT         NOT NULL,
    "level"             INTEGER      NOT NULL,
    "year"              INTEGER      NOT NULL,
    "homeroomTeacherId" TEXT,
    "createdAt"         TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"         TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "classes_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "classes_name_year_key"
    ON "classes"("name", "year");

-- ── Students ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "students" (
    "id"            TEXT         NOT NULL,
    "admissionNo"   TEXT         NOT NULL,
    "firstName"     TEXT         NOT NULL,
    "lastName"      TEXT         NOT NULL,
    "dateOfBirth"   TIMESTAMP(3),
    "gender"        "Gender",
    "guardianName"  TEXT,
    "guardianPhone" TEXT,
    "guardianEmail" TEXT,
    "address"       TEXT,
    "enrolledAt"    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "active"        BOOLEAN      NOT NULL DEFAULT true,
    "classId"       TEXT,
    "createdAt"     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "students_admissionNo_key"
    ON "students"("admissionNo");
CREATE INDEX IF NOT EXISTS "students_classId_idx"
    ON "students"("classId");

-- ── Scores ────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "scores" (
    "id"           TEXT             NOT NULL,
    "subject"      TEXT             NOT NULL,
    "term"         TEXT             NOT NULL,
    "year"         INTEGER          NOT NULL,
    "score"        DOUBLE PRECISION NOT NULL,
    "maxScore"     DOUBLE PRECISION NOT NULL DEFAULT 100,
    "comment"      TEXT,
    "studentId"    TEXT             NOT NULL,
    "recordedById" TEXT,
    "createdAt"    TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"    TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "scores_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "scores_studentId_idx" ON "scores"("studentId");

-- ── Fees ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "fees" (
    "id"          TEXT             NOT NULL,
    "description" TEXT             NOT NULL,
    "term"        TEXT             NOT NULL,
    "year"        INTEGER          NOT NULL,
    "amountDue"   DOUBLE PRECISION NOT NULL,
    "dueDate"     TIMESTAMP(3),
    "status"      "FeeStatus"      NOT NULL DEFAULT 'UNPAID',
    "studentId"   TEXT             NOT NULL,
    "createdAt"   TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"   TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fees_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "fees_studentId_idx" ON "fees"("studentId");

-- ── Payments ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "payments" (
    "id"        TEXT             NOT NULL,
    "amount"    DOUBLE PRECISION NOT NULL,
    "method"    TEXT,
    "reference" TEXT,
    "paidAt"    TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "feeId"     TEXT             NOT NULL,
    "createdAt" TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "payments_feeId_idx" ON "payments"("feeId");

-- ── Attendance ────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "attendance" (
    "id"        TEXT               NOT NULL,
    "date"      TIMESTAMP(3)       NOT NULL,
    "status"    "AttendanceStatus" NOT NULL DEFAULT 'PRESENT',
    "note"      TEXT,
    "studentId" TEXT               NOT NULL,
    "classId"   TEXT               NOT NULL,
    "takenById" TEXT,
    "createdAt" TIMESTAMP(3)       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "attendance_studentId_date_key"
    ON "attendance"("studentId", "date");
CREATE INDEX IF NOT EXISTS "attendance_classId_date_idx"
    ON "attendance"("classId", "date");

-- ══════════════════════════════════════════════════════════
-- Foreign Keys
-- (Added after all tables exist to avoid ordering issues)
-- ══════════════════════════════════════════════════════════

-- users → staff (SetNull: deleting a staff record clears staffId but keeps the login)
ALTER TABLE "users"
    DROP CONSTRAINT IF EXISTS "users_staffId_fkey",
    ADD CONSTRAINT "users_staffId_fkey"
        FOREIGN KEY ("staffId") REFERENCES "staff"("id")
        ON DELETE SET NULL ON UPDATE CASCADE;

-- accounts → users (Cascade: deleting a user removes their OAuth accounts)
ALTER TABLE "accounts"
    DROP CONSTRAINT IF EXISTS "accounts_userId_fkey",
    ADD CONSTRAINT "accounts_userId_fkey"
        FOREIGN KEY ("userId") REFERENCES "users"("id")
        ON DELETE CASCADE ON UPDATE CASCADE;

-- sessions → users (Cascade: deleting a user removes their sessions)
ALTER TABLE "sessions"
    DROP CONSTRAINT IF EXISTS "sessions_userId_fkey",
    ADD CONSTRAINT "sessions_userId_fkey"
        FOREIGN KEY ("userId") REFERENCES "users"("id")
        ON DELETE CASCADE ON UPDATE CASCADE;

-- classes → staff homeroom teacher (SetNull: removing a teacher doesn't delete the class)
ALTER TABLE "classes"
    DROP CONSTRAINT IF EXISTS "classes_homeroomTeacherId_fkey",
    ADD CONSTRAINT "classes_homeroomTeacherId_fkey"
        FOREIGN KEY ("homeroomTeacherId") REFERENCES "staff"("id")
        ON DELETE SET NULL ON UPDATE CASCADE;

-- students → classes (SetNull: deleting a class orphans students rather than deleting them)
ALTER TABLE "students"
    DROP CONSTRAINT IF EXISTS "students_classId_fkey",
    ADD CONSTRAINT "students_classId_fkey"
        FOREIGN KEY ("classId") REFERENCES "classes"("id")
        ON DELETE SET NULL ON UPDATE CASCADE;

-- scores → students (Cascade: deleting a student removes their scores)
ALTER TABLE "scores"
    DROP CONSTRAINT IF EXISTS "scores_studentId_fkey",
    ADD CONSTRAINT "scores_studentId_fkey"
        FOREIGN KEY ("studentId") REFERENCES "students"("id")
        ON DELETE CASCADE ON UPDATE CASCADE;

-- scores → staff recorder (SetNull: removing a teacher keeps the score record)
ALTER TABLE "scores"
    DROP CONSTRAINT IF EXISTS "scores_recordedById_fkey",
    ADD CONSTRAINT "scores_recordedById_fkey"
        FOREIGN KEY ("recordedById") REFERENCES "staff"("id")
        ON DELETE SET NULL ON UPDATE CASCADE;

-- fees → students (Cascade: deleting a student removes their fee records)
ALTER TABLE "fees"
    DROP CONSTRAINT IF EXISTS "fees_studentId_fkey",
    ADD CONSTRAINT "fees_studentId_fkey"
        FOREIGN KEY ("studentId") REFERENCES "students"("id")
        ON DELETE CASCADE ON UPDATE CASCADE;

-- payments → fees (Cascade: deleting a fee removes associated payments)
ALTER TABLE "payments"
    DROP CONSTRAINT IF EXISTS "payments_feeId_fkey",
    ADD CONSTRAINT "payments_feeId_fkey"
        FOREIGN KEY ("feeId") REFERENCES "fees"("id")
        ON DELETE CASCADE ON UPDATE CASCADE;

-- attendance → students (Cascade)
ALTER TABLE "attendance"
    DROP CONSTRAINT IF EXISTS "attendance_studentId_fkey",
    ADD CONSTRAINT "attendance_studentId_fkey"
        FOREIGN KEY ("studentId") REFERENCES "students"("id")
        ON DELETE CASCADE ON UPDATE CASCADE;

-- attendance → classes (Restrict: can't delete a class with attendance history)
ALTER TABLE "attendance"
    DROP CONSTRAINT IF EXISTS "attendance_classId_fkey",
    ADD CONSTRAINT "attendance_classId_fkey"
        FOREIGN KEY ("classId") REFERENCES "classes"("id")
        ON DELETE RESTRICT ON UPDATE CASCADE;

-- attendance → staff who took it (SetNull)
ALTER TABLE "attendance"
    DROP CONSTRAINT IF EXISTS "attendance_takenById_fkey",
    ADD CONSTRAINT "attendance_takenById_fkey"
        FOREIGN KEY ("takenById") REFERENCES "staff"("id")
        ON DELETE SET NULL ON UPDATE CASCADE;

-- ══════════════════════════════════════════════════════════
-- Done! Tables created:
--   users, accounts, sessions, verification_tokens,
--   staff, classes, students, scores, fees, payments, attendance
-- Enums created:
--   UserRole, StaffRole, Gender, FeeStatus, AttendanceStatus
-- ══════════════════════════════════════════════════════════
