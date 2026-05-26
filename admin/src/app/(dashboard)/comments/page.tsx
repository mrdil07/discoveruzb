"use client";

import { Card, CardContent } from "@/components/ui/card";
import { MessageSquare } from "lucide-react";

export default function CommentsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Izohlar</h1>
        <p className="text-sm text-muted-foreground">
          Postlar bo'yicha barcha izohlar (moderatsiya)
        </p>
      </div>

      <Card>
        <CardContent className="flex flex-col items-center justify-center py-16 text-center">
          <MessageSquare className="mb-3 h-12 w-12 text-muted-foreground" />
          <p className="font-medium">Izohlar moderatsiyasi</p>
          <p className="mt-1 max-w-md text-sm text-muted-foreground">
            Backend'da hozirda barcha izohlarni listing endpoint'i yo'q
            (faqat post bo'yicha). Sprint 5'da `GET /api/v1/comments` admin
            uchun qo'shiladi va shu yerda jadval ko'rinishida chiqadi.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
