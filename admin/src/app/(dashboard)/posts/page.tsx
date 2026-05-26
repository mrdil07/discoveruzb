"use client";

import { useState } from "react";
import Link from "next/link";
import { ImageWithFallback } from "@/components/image-with-fallback";
import {
  useTable,
  useUpdate,
  useDelete,
  type CrudFilter,
} from "@refinedev/core";
import {
  Search,
  ChevronLeft,
  ChevronRight,
  Heart,
  Eye,
  EyeOff,
  Trash2,
  Pencil,
  Plus,
} from "lucide-react";
import { toast } from "sonner";

import { formatDate, formatNumber } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";

interface PostRow {
  id: string;
  place_name: string;
  type: string;
  address: string;
  images: string[];
  like_count: number;
  is_published: boolean;
  created_at: string;
  author: { id: string; fullname: string; img_url: string | null } | null;
}

export default function PostsPage() {
  const [search, setSearch] = useState("");

  const filters: CrudFilter[] = [];
  if (search) filters.push({ field: "address", operator: "eq", value: search });

  const {
    tableQuery: { data, isLoading, refetch },
    current,
    setCurrent,
    pageCount,
  } = useTable<PostRow>({
    resource: "posts",
    pagination: { pageSize: 20 },
    sorters: { initial: [{ field: "time", order: "desc" }] },
    filters: { permanent: filters },
  });

  const { mutate: updatePost } = useUpdate();
  const { mutate: deletePost } = useDelete();

  function handleTogglePublish(post: PostRow) {
    updatePost(
      {
        resource: "posts",
        id: post.id,
        values: { is_published: !post.is_published },
      },
      {
        onSuccess: () => {
          toast.success(post.is_published ? "Yashirildi" : "Nashr qilindi");
          refetch();
        },
        onError: (err) => toast.error(err.message),
      },
    );
  }

  function handleDelete(post: PostRow) {
    if (!confirm(`"${post.place_name}" postini o'chirish?`)) return;
    deletePost(
      { resource: "posts", id: post.id },
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
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Postlar</h1>
          <p className="text-sm text-muted-foreground">
            Turistik joylar — moderatsiya va boshqaruv
          </p>
        </div>
        <Button asChild>
          <Link href="/posts/create">
            <Plus className="h-4 w-4" />
            Yangi post
          </Link>
        </Button>
      </div>

      <Card>
        <CardContent className="p-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Manzil bo'yicha qidirish..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9"
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[300px]">Joy</TableHead>
              <TableHead>Manzil</TableHead>
              <TableHead>Tur</TableHead>
              <TableHead>Avtor</TableHead>
              <TableHead>Layk</TableHead>
              <TableHead>Holat</TableHead>
              <TableHead>Sana</TableHead>
              <TableHead className="text-right">Amal</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <TableRow key={i}>
                  <TableCell colSpan={8}>
                    <Skeleton className="h-12 w-full" />
                  </TableCell>
                </TableRow>
              ))
            ) : !data?.data.length ? (
              <TableRow>
                <TableCell
                  colSpan={8}
                  className="text-center text-muted-foreground"
                >
                  Postlar topilmadi
                </TableCell>
              </TableRow>
            ) : (
              data.data.map((post) => (
                <TableRow key={post.id}>
                  <TableCell>
                    <div className="flex items-center gap-3">
                      <ImageWithFallback
                        src={post.images[0]}
                        alt={post.place_name}
                        width={56}
                        height={40}
                        sizes="56px"
                        className="h-10 w-14 rounded-md object-cover"
                      />
                      <div className="font-medium">{post.place_name}</div>
                    </div>
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">
                    {post.address}
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">{post.type}</Badge>
                  </TableCell>
                  <TableCell className="text-sm">
                    {post.author?.fullname ?? "—"}
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-1 text-sm">
                      <Heart className="h-3 w-3 text-red-500" />
                      {formatNumber(post.like_count)}
                    </div>
                  </TableCell>
                  <TableCell>
                    {post.is_published ? (
                      <Badge variant="success">Nashr</Badge>
                    ) : (
                      <Badge variant="secondary">Yashirin</Badge>
                    )}
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">
                    {formatDate(post.created_at)}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      size="icon"
                      variant="ghost"
                      asChild
                      title="Tahrirlash"
                    >
                      <Link href={`/posts/edit/${post.id}`}>
                        <Pencil className="h-4 w-4 text-primary" />
                      </Link>
                    </Button>
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => handleTogglePublish(post)}
                      title={post.is_published ? "Yashirish" : "Nashr qilish"}
                    >
                      {post.is_published ? (
                        <EyeOff className="h-4 w-4 text-orange-500" />
                      ) : (
                        <Eye className="h-4 w-4 text-emerald-500" />
                      )}
                    </Button>
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => handleDelete(post)}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>

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
