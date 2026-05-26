import { Badge } from "@/components/ui/badge";

const ROLE_LABEL: Record<string, { label: string; variant: "default" | "secondary" | "destructive" | "outline" | "success" }> = {
  admin: { label: "Admin", variant: "default" },
  moderator: { label: "Moderator", variant: "secondary" },
  user: { label: "User", variant: "outline" },
};

export function RoleBadge({ role }: { role: string }) {
  const cfg = ROLE_LABEL[role] ?? { label: role, variant: "outline" };
  return <Badge variant={cfg.variant}>{cfg.label}</Badge>;
}
