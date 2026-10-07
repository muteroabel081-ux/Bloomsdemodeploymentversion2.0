import { PrismaClient } from "@prisma/client";
import { PrismaLibSQL } from "@prisma/adapter-libsql";
import bcrypt from "bcryptjs";

// ══════════════════════════════════════════════════════════
// Seeds one of each entity with real relations between them,
// so every route added above has something to actually return.
// Run with: npx tsx prisma/seed.ts
// (or `npm run db:seed` once wired up — see package.json note
// in the setup guide)
// ══════════════════════════════════════════════════════════

const adapter = new PrismaLibSQL({
  url: process.env.DATABASE_URL ?? "file:./db/custom.db",
  authToken: process.env.DATABASE_AUTH_TOKEN,
});
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log("Seeding BLOOMS Junior School...");

  // ── Staff: one headteacher, one teacher ──
  const headteacher = await prisma.staff.create({
    data: {
      firstName: "Grace",
      lastName: "Wanjiru",
      email: "g.wanjiru@bloomsjunior.school",
      phone: "+254700000001",
      role: "HEADTEACHER",
    },
  });

  const teacher = await prisma.staff.create({
    data: {
      firstName: "Peter",
      lastName: "Kimani",
      email: "p.kimani@bloomsjunior.school",
      phone: "+254700000002",
      role: "TEACHER",
    },
  });

  // ── Admin login, linked to the headteacher's Staff record ──
  const adminPassword = process.env.ADMIN_PASSWORD || "demo-password-123";
  const passwordHash = await bcrypt.hash(adminPassword, 10);
  await prisma.user.create({
    data: {
      name: "Grace Wanjiru",
      email: "g.wanjiru@bloomsjunior.school",
      password: passwordHash,
      role: "ADMIN",
      staffId: headteacher.id,
    },
  });

  // ── Class, homeroom = the teacher above ──
  const cls = await prisma.class.create({
    data: {
      name: "Grade 4 Blue",
      level: 4,
      year: 2026,
      homeroomTeacherId: teacher.id,
    },
  });

  // ── Student, enrolled in that class ──
  const student = await prisma.student.create({
    data: {
      admissionNo: "BJS-2026-001",
      firstName: "Amani",
      lastName: "Otieno",
      dateOfBirth: new Date("2016-03-14"),
      gender: "MALE",
      guardianName: "Susan Otieno",
      guardianPhone: "+254711000000",
      guardianEmail: "s.otieno@example.com",
      classId: cls.id,
    },
  });

  // ── Score, recorded by the teacher ──
  await prisma.score.create({
    data: {
      studentId: student.id,
      subject: "Mathematics",
      term: "Term 1",
      year: 2026,
      score: 78,
      maxScore: 100,
      comment: "Good grasp of fractions, needs more practice with word problems.",
      recordedById: teacher.id,
    },
  });

  // ── Fee + one partial payment against it ──
  const fee = await prisma.fee.create({
    data: {
      studentId: student.id,
      description: "Term 1 Tuition",
      term: "Term 1",
      year: 2026,
      amountDue: 15000,
      dueDate: new Date("2026-02-01"),
      status: "PARTIAL",
    },
  });

  await prisma.payment.create({
    data: {
      feeId: fee.id,
      amount: 8000,
      method: "M-Pesa",
      reference: "SFA1QZ9K2X",
    },
  });

  // ── Attendance, taken by the teacher ──
  await prisma.attendance.create({
    data: {
      studentId: student.id,
      classId: cls.id,
      date: new Date(),
      status: "PRESENT",
      takenById: teacher.id,
    },
  });

  console.log("Seed complete.");
  console.log("  Admin login: g.wanjiru@bloomsjunior.school / [your-admin-password]");
  console.log(`  Student: ${student.firstName} ${student.lastName} (${student.admissionNo})`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
