"use client";

import { useTable } from "@refinedev/core";
import { Image as ImageIcon, Eye } from "lucide-react";

import { ImageWithFallback } from "@/components/image-with-fallback";

import { formatDate } from "@/lib/utils";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";

interface GalleryRow {
  id: string;
  owner_id: string;
  place_name: string;
  images: string[];
  date: string | null;
  is_public: boolean;
  share_slug: string | null;
  created_at: string;
}

export default function GalleriesPage() {
  const {
    tableQuery: { data, isLoading },
  } = useTable<GalleryRow>({
    resource: "galleries",
    pagination: { pageSize: 24 },
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Galereyalar</h1>
        <p className="text-sm text-muted-foreground">
          Foydalanuvchilar yaratgan shaxsiy galereyalar (moderatsiya)
        </p>
      </div>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="aspect-square w-full" />
          ))}
        </div>
      ) : !data?.data.length ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12 text-muted-foreground">
            <ImageIcon className="mb-2 h-12 w-12" />
            <p>Galereyalar yo'q</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {data.data.map((gallery) => (
            <Card key={gallery.id} className="overflow-hidden">
              <div className="relative aspect-square bg-muted">
                <ImageWithFallback
                  src={gallery.images[0]}
                  alt={gallery.place_name}
                  fill
                  sizes="(min-width: 1280px) 25vw, (min-width: 1024px) 33vw, 50vw"
                  className="object-cover"
                  iconClassName="h-12 w-12"
                />
                <div className="absolute right-2 top-2 flex gap-1">
                  {gallery.is_public ? (
                    <Badge variant="success">Public</Badge>
                  ) : (
                    <Badge variant="secondary">Private</Badge>
                  )}
                  {gallery.images.length > 1 && (
                    <Badge variant="outline" className="bg-background/80">
                      +{gallery.images.length - 1}
                    </Badge>
                  )}
                </div>
              </div>
              <CardContent className="p-3">
                <p className="truncate font-medium">{gallery.place_name}</p>
                <p className="text-xs text-muted-foreground">
                  {formatDate(gallery.created_at)}
                </p>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
