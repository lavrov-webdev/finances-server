-- CreateEnum
CREATE TYPE "CategoryType" AS ENUM ('LOSS', 'INCOME');

-- AlterTable
ALTER TABLE "Category" ADD COLUMN     "type" "CategoryType" NOT NULL DEFAULT 'LOSS';
