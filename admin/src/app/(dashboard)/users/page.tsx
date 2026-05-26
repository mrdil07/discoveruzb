"use client";

import { useState } from "react";
import {
  useTable,
  useUpdate,
  useDelete,
  type CrudFilter,
} from "@refinedev/core";
import {
  Search,
  Loader2,
  ChevronLeft,
  ChevronRight,
  Shield,
  Ban,
  Trash2,
  CheckCircle2,
} from "lucide-react";
import { toast } from "sonner";

import { formatDate } from "@/lib/utils";
import type { User } from "@/lib/auth-provider";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { RoleBadge } from "@/components/role-badge";

interface UserRow extends User {
  is_banned: boolean;
  created_at: string;
  last_login_at: string | null;
}

export default function UsersPage() {
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");

  const filters: CrudFilter[] = [];
  if (search) filters.push({ field: "q", operator: "eq", value: search });
  if (roleFilter !== "all")
    filters.push({ field: "role", operator: "eq", value: roleFilter });

  const {
    tableQuery: { data, isLoading, isError, refetch },
    current,
    setCurrent,
    pageCount,
    pageSize,
  } = useTable<UserRow>({
    resource: "users",
    pagination: { pageSize: 20 },
    filters: { permanent: filters },
  });

  const { mutate: updateUser } = useUpdate();
  const { mutate: deleteUser } = useDelete();

  function handleRoleChange(id: string, role: string) {
    updateUser(
      { resource: "users", id, values: { role } },
      {
        onSuccess: () => {
          toast.success("Rol o'zgartirildi");
          refetch();
        },
        onError: (err) => toast.error(err.message),
      },
    );
  }

  function handleToggleBan(user: UserRow) {
    updateUser(
      {
        resource: "users",
        id: user.id,
        values: { is_banned: !user.is_banned },
      },
      {
        onSuccess: () => {
          toast.success(user.is_banned ? "Blokdan chiqarildi" : "Bloklandi");
          refetch();
        },
        onError: (err) => toast.error(err.message),
      },
    );
  }

  function handleDelete(user: UserRow) {
    if (!confirm(`${user.fullname} ni o'chirish — bu amalni bekor qilib bo'lmaydi`)) return;
    deleteUser(
      { resource: "users", id: user.id },
      {
        onSuccess: () => {
          toast.success("O'chirildi");
          refetch();
        },
        onError: (err) => toast.error(err.message),
      },
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">
          Foydalanuvchilar
        </h1>
        <p className="text-sm text-muted-foreground">
          Tizimdagi barcha foydalanuvchilar va ularning rollari
        </p>
      </div>

      {/* Filterlar */}
      <Card>
        <CardContent className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Ism, telefon, email bo'yicha qidirish..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9"
            />
          </div>
          <Select value={roleFilter} onValueChange={setRoleFilter}>
            <SelectTrigger className="w-full sm:w-[180px]">
              <SelectValue placeholder="Rol" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Barcha rollar</SelectItem>
              <SelectItem value="user">User</SelectItem>
              <SelectItem value="moderator">Moderator</SelectItem>
              <SelectItem value="admin">Admin</SelectItem>
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {/* Jadval */}
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[280px]">Foydalanuvchi</TableHead>
              <TableHead>Aloqa</TableHead>
              <TableHead>Rol</TableHead>
              <TableHead>Holat</TableHead>
              <TableHead>Ro'yxatdan o'tgan</TableHead>
              <TableHead className="text-right">Amallar</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <TableRow key={i}>
                  <TableCell colSpan={6}>
                    <Skeleton className="h-10 w-full" />
                  </TableCell>
                </TableRow>
              ))
            ) : isError || !data?.data ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center text-destructive">
                  Yuklanmadi
                </TableCell>
              </TableRow>
            ) : data.data.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={6}
                  className="text-center text-muted-foreground"
                >
                  Foydalanuvchilar topilmadi
                </TableCell>
              </TableRow>
            ) : (
              data.data.map((user) => (
                <TableRow key={user.id}>
                  <TableCell>
                    <div className="flex items-center gap-3">
                      <Avatar className="h-9 w-9">
                        {user.img_url ? (
                          <AvatarImage src={user.img_url} alt={user.fullname} />
                        ) : null}
                        <AvatarFallback>
                          {user.fullname[0]?.toUpperCase() ?? "?"}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="font-medium">{user.fullname}</p>
                        <p className="text-xs text-muted-foreground">
                          {user.id.slice(0, 8)}…
                        </p>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="text-sm">
                    <div className="space-y-0.5">
                      {user.phone && <div>{user.phone}</div>}
                      {user.email && (
                        <div className="text-muted-foreground">{user.email}</div>
                      )}
                    </div>
                  </TableCell>
                  <TableCell>
                    <Select
                      value={user.role}
                      onValueChange={(v) => handleRoleChange(user.id, v)}
                    >
                      <SelectTrigger className="h-8 w-[130px]">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="user">User</SelectItem>
                        <SelectItem value="moderator">Moderator</SelectItem>
                        <SelectItem value="admin">Admin</SelectItem>
                      </SelectContent>
                    </Select>
                  </TableCell>
                  <TableCell>
                    {user.is_banned ? (
                      <Badge variant="destructive">Bloklangan</Badge>
                    ) : (
                      <Badge variant="success">Aktiv</Badge>
                    )}
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">
                    {formatDate(user.created_at)}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => handleToggleBan(user)}
                      title={user.is_banned ? "Blokdan chiqarish" : "Bloklash"}
                    >
                      {user.is_banned ? (
                        <CheckCircle2 className="h-4 w-4 text-emerald-500" />
                      ) : (
                        <Ban className="h-4 w-4 text-orange-500" />
                      )}
                    </Button>
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => handleDelete(user)}
                      title="O'chirish"
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>

        {/* Pagination */}
        {pageCount > 1 && (
          <div className="flex items-center justify-between border-t p-4">
            <p className="text-sm text-muted-foreground">
              Sahifa {current} / {pageCount}
            </p>
            <div className="flex gap-2">
              <Button
                size="sm"
                variant="outline"
                disabled={current <= 1}
                onClick={() => setCurrent(current - 1)}
              >
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <Button
                size="sm"
                variant="outline"
                disabled={current >= pageCount}
                onClick={() => setCurrent(current + 1)}
              >
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
}
