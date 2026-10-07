// packages/database/src/index.ts
import { PrismaClient } from "@prisma/client";

// Export a singleton instance for convenience
export const prisma = new PrismaClient();

// Also export the class in case other code wants to instantiate its own client
export { PrismaClient };
