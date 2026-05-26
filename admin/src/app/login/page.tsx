import { Suspense } from "react";
import { LoginClient } from "./_client";

// Refine'ning auth hook'lari `useSearchParams` ishlatadi — bu CSR-only.
// Static prerender bilan mos kelmasligi uchun dynamic + Suspense.
export const dynamic = "force-dynamic";

export default function LoginPage() {
  return (
    <Suspense fallback={null}>
      <LoginClient />
    </Suspense>
  );
}
