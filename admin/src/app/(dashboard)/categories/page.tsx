"use client";

import { useState } from "react";
import { useTable, useCreate, useUpdate, useDelete } from "@refinedev/core";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Plus, Trash2, Pencil, Loader2 } from "lucide-react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Skeleton } from "@/components/ui/skeleton";

const schema = z.object({
  slug: z
    .string()
    .min(2)
    .max(50)
    .regex(/^[a-z0-9_-]+$/, "Faqat kichik harflar, raqamlar, _-"),
  name_uz: z.string().min(1).max(100),
  name_ru: z.string().min(1).max(100),
  name_en: z.string().min(1).max(100),
  icon_url: z.string().url().optional().or(z.literal("")),
  sort_order: z.coerce.number().int().min(0).default(0),
});

type FormValues = z.infer<typeof schema>;

interface CategoryRow extends FormValues {
  is_active: boolean;
}

export default function CategoriesPage() {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<CategoryRow | null>(null);

  const {
    tableQuery: { data, isLoading, refetch },
  } = useTable<CategoryRow>({
    resource: "categories",
    pagination: { mode: "off" },
  });

  const { mutate: createCategory, isPending: creating } = useCreate();
  const { mutate: updateCategory } = useUpdate();
  const { mutate: deleteCategory } = useDelete();

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      slug: "",
      name_uz: "",
      name_ru: "",
      name_en: "",
      icon_url: "",
      sort_order: 0,
    },
  });

  function openCreate() {
    setEditing(null);
    form.reset();
    setOpen(true);
  }

  function openEdit(row: CategoryRow) {
    setEditing(row);
    form.reset(row);
    setOpen(true);
  }

  function onSubmit(values: FormValues) {
    if (editing) {
      const { slug, ...rest } = values;
      updateCategory(
        { resource: "categories", id: editing.slug, values: rest },
        {
          onSuccess: () => {
            toast.success("Yangilandi");
            setOpen(false);
            refetch();
          },
          onError: (e) => toast.error(e.message),
        },
      );
    } else {
      createCategory(
        { resource: "categories", values },
        {
          onSuccess: () => {
            toast.success("Yaratildi");
            setOpen(false);
            refetch();
          },
          onError: (e) => toast.error(e.message),
        },
      );
    }
  }

  function handleDelete(slug: string) {
    if (!confirm(`"${slug}" kategoriyasini o'chirish?`)) return;
    deleteCategory(
      { resource: "categories", id: slug },
      {
        onSuccess: () => {
          toast.success("O'chirildi");
          refetch();
        },
        onError: (e) => toast.error(e.message),
      },
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">
            Kategoriyalar
          </h1>
          <p className="text-sm text-muted-foreground">
            Postlar uchun kategoriyalar (uch tilda)
          </p>
        </div>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button onClick={openCreate}>
              <Plus className="h-4 w-4" />
              Yangi
            </Button>
          </DialogTrigger>
          <DialogContent>
            <form onSubmit={form.handleSubmit(onSubmit)}>
              <DialogHeader>
                <DialogTitle>
                  {editing ? "Kategoriyani yangilash" : "Yangi kategoriya"}
                </DialogTitle>
                <DialogDescription>
                  Slug — barqaror identifikator (`historical`, `mountain`).
                </DialogDescription>
              </DialogHeader>

              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="slug">Slug</Label>
                  <Input
                    id="slug"
                    {...form.register("slug")}
                    disabled={!!editing}
                    placeholder="historical"
                  />
                  {form.formState.errors.slug && (
                    <p className="text-xs text-destructive">
                      {form.formState.errors.slug.message}
                    </p>
                  )}
                </div>
                <div className="grid grid-cols-3 gap-3">
                  <div className="grid gap-2">
                    <Label htmlFor="name_uz">UZ</Label>
                    <Input id="name_uz" {...form.register("name_uz")} />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="name_ru">RU</Label>
                    <Input id="name_ru" {...form.register("name_ru")} />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="name_en">EN</Label>
                    <Input id="name_en" {...form.register("name_en")} />
                  </div>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="icon_url">Ikonka URL (ixtiyoriy)</Label>
                  <Input
                    id="icon_url"
                    {...form.register("icon_url")}
                    placeholder="https://..."
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="sort_order">Tartib</Label>
                  <Input
                    id="sort_order"
                    type="number"
                    {...form.register("sort_order")}
                  />
                </div>
              </div>

              <DialogFooter>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setOpen(false)}
                >
                  Bekor qilish
                </Button>
                <Button type="submit" disabled={creating}>
                  {creating && <Loader2 className="h-4 w-4 animate-spin" />}
                  Saqlash
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Slug</TableHead>
              <TableHead>UZ / RU / EN</TableHead>
              <TableHead>Tartib</TableHead>
              <TableHead>Holat</TableHead>
              <TableHead className="text-right">Amal</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <TableRow key={i}>
                  <TableCell colSpan={5}>
                    <Skeleton className="h-8 w-full" />
                  </TableCell>
                </TableRow>
              ))
            ) : !data?.data.length ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center text-muted-foreground">
                  Kategoriyalar yo'q
                </TableCell>
              </TableRow>
            ) : (
              data.data.map((cat) => (
                <TableRow key={cat.slug}>
                  <TableCell className="font-mono text-sm">{cat.slug}</TableCell>
                  <TableCell>
                    <div className="space-y-0.5">
                      <p className="font-medium">{cat.name_uz}</p>
                      <p className="text-xs text-muted-foreground">
                        {cat.name_ru} · {cat.name_en}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell>{cat.sort_order}</TableCell>
                  <TableCell>
                    {cat.is_active ? (
                      <Badge variant="success">Aktiv</Badge>
                    ) : (
                      <Badge variant="secondary">Yashirin</Badge>
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => openEdit(cat)}
                    >
                      <Pencil className="h-4 w-4" />
                    </Button>
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => handleDelete(cat.slug)}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}
