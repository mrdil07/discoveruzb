"use client";

import { useEffect, useState } from "react";
import {
  RefreshCw,
  Star,
  MapPin,
  Globe,
  AlertTriangle,
  Loader2,
} from "lucide-react";
import { toast } from "sonner";

import { api, extractErrorMessage } from "@/lib/api";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { formatDate } from "@/lib/utils";

interface SourceSummary {
  source: string;
  review_count: number;
  average_rating: number | null;
  last_fetched_at: string | null;
  error: string | null;
}

interface ExternalReview {
  id: string;
  source: string;
  author_name: string;
  author_avatar_url: string | null;
  rating: number | null;
  text: string | null;
  posted_at: string | null;
  fetched_at: string;
}

interface ExternalReviewsResponse {
  post_id: string;
  summaries: SourceSummary[];
  reviews: ExternalReview[];
}

const SOURCE_META: Record<
  string,
  { label: string; color: string; emoji: string }
> = {
  google: { label: "Google", color: "bg-blue-500", emoji: "🅖" },
  yandex: { label: "Yandex", color: "bg-red-500", emoji: "🅨" },
  "2gis": { label: "2GIS", color: "bg-emerald-500", emoji: "🅖" },
};

export function ExternalReviewsPanel({ postId }: { postId: string }) {
  const [data, setData] = useState<ExternalReviewsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState<string | null>(null); // source nomi yoki "all"

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [postId]);

  async function load() {
    setLoading(true);
    try {
      const response = await api.get<ExternalReviewsResponse>(
        `/posts/${postId}/external-reviews`,
      );
      setData(response.data);
    } catch (error) {
      toast.error(extractErrorMessage(error, "Sharhlarni yuklashda xatolik"));
    } finally {
      setLoading(false);
    }
  }

  async function refresh(sources?: string[]) {
    const label = sources?.join(", ") ?? "barchasi";
    setRefreshing(sources?.length === 1 ? sources[0] : "all");
    try {
      await api.post(`/posts/${postId}/external-reviews/refresh`, {
        sources: sources ?? null,
      });
      await load();
      toast.success(`Yangilandi: ${label}`);
    } catch (error) {
      toast.error(extractErrorMessage(error, "Yangilashda xatolik"));
    } finally {
      setRefreshing(null);
    }
  }

  if (loading && !data) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Globe className="h-4 w-4" /> Tashqi sharhlar
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <Skeleton className="h-16 w-full" />
          <Skeleton className="h-16 w-full" />
        </CardContent>
      </Card>
    );
  }

  const summariesByCode = new Map<string, SourceSummary>();
  for (const s of data?.summaries ?? []) {
    summariesByCode.set(s.source, s);
  }
  const activeSources = (data?.summaries ?? [])
    .filter((s) => !(s.error ?? "").includes("place_id"))
    .map((s) => s.source);

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <div>
          <CardTitle className="flex items-center gap-2">
            <Globe className="h-4 w-4" /> Tashqi sharhlar
          </CardTitle>
          <CardDescription>Google, Yandex, 2GIS</CardDescription>
        </div>
        <Button
          size="sm"
          variant="outline"
          onClick={() => refresh()}
          disabled={refreshing === "all"}
        >
          {refreshing === "all" ? (
            <Loader2 className="h-3 w-3 animate-spin" />
          ) : (
            <RefreshCw className="h-3 w-3" />
          )}
          Hammasi
        </Button>
      </CardHeader>

      <CardContent className="space-y-3">
        {/* Per-source summary cards */}
        {(data?.summaries ?? []).map((s) => (
          <SummaryCard
            key={s.source}
            summary={s}
            onRefresh={() => refresh([s.source])}
            isRefreshing={refreshing === s.source}
          />
        ))}

        {/* Tabbed reviews */}
        {activeSources.length > 0 && (data?.reviews.length ?? 0) > 0 && (
          <div className="pt-2">
            <Tabs defaultValue={activeSources[0]}>
              <TabsList className="grid w-full grid-cols-3">
                {activeSources.map((src) => (
                  <TabsTrigger key={src} value={src} className="text-xs">
                    {SOURCE_META[src]?.label ?? src}
                  </TabsTrigger>
                ))}
              </TabsList>
              {activeSources.map((src) => {
                const reviews = (data?.reviews ?? []).filter(
                  (r) => r.source === src,
                );
                return (
                  <TabsContent key={src} value={src} className="space-y-3">
                    {reviews.length === 0 ? (
                      <p className="py-6 text-center text-sm text-muted-foreground">
                        Sharhlar yo&apos;q
                      </p>
                    ) : (
                      reviews.slice(0, 5).map((r) => (
                        <ReviewItem key={r.id} review={r} />
                      ))
                    )}
                    {reviews.length > 5 && (
                      <p className="text-center text-xs text-muted-foreground">
                        +{reviews.length - 5} ta yana cache&apos;da
                      </p>
                    )}
                  </TabsContent>
                );
              })}
            </Tabs>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

function SummaryCard({
  summary,
  onRefresh,
  isRefreshing,
}: {
  summary: SourceSummary;
  onRefresh: () => void;
  isRefreshing: boolean;
}) {
  const meta = SOURCE_META[summary.source] ?? {
    label: summary.source,
    color: "bg-slate-500",
    emoji: "?",
  };
  const isMissingId = (summary.error ?? "").includes("place_id");

  return (
    <div className="rounded-md border p-3">
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2">
          <div
            className={`flex h-8 w-8 items-center justify-center rounded-md ${meta.color} text-xs font-bold text-white`}
          >
            <MapPin className="h-4 w-4" />
          </div>
          <div>
            <p className="text-sm font-medium">{meta.label}</p>
            <p className="text-xs text-muted-foreground">
              {summary.last_fetched_at
                ? formatDate(summary.last_fetched_at)
                : "Hali yuklanmagan"}
            </p>
          </div>
        </div>
        <Button
          size="icon"
          variant="ghost"
          className="h-7 w-7"
          onClick={onRefresh}
          disabled={isRefreshing || isMissingId}
          title="Bu manbani yangilash"
        >
          {isRefreshing ? (
            <Loader2 className="h-3 w-3 animate-spin" />
          ) : (
            <RefreshCw className="h-3 w-3" />
          )}
        </Button>
      </div>

      <div className="mt-2 flex items-center gap-2">
        {isMissingId ? (
          <Badge variant="outline" className="text-xs">
            place_id sozlanmagan
          </Badge>
        ) : summary.error ? (
          <div className="flex items-center gap-1 text-xs text-destructive">
            <AlertTriangle className="h-3 w-3" />
            {summary.error}
          </div>
        ) : (
          <>
            <Badge variant="secondary" className="text-xs">
              {summary.review_count} sharh
            </Badge>
            {summary.average_rating != null && (
              <div className="flex items-center gap-1 text-xs">
                <Star className="h-3 w-3 fill-amber-500 text-amber-500" />
                <span className="font-medium">
                  {summary.average_rating.toFixed(1)}
                </span>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}

function ReviewItem({ review }: { review: ExternalReview }) {
  const initial = review.author_name?.[0]?.toUpperCase() ?? "?";
  return (
    <div className="rounded-md border bg-muted/30 p-3">
      <div className="flex items-start gap-2">
        <Avatar className="h-7 w-7">
          {review.author_avatar_url && (
            <AvatarImage
              src={review.author_avatar_url}
              alt={review.author_name}
            />
          )}
          <AvatarFallback className="text-xs">{initial}</AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <div className="flex items-center justify-between gap-2">
            <p className="text-xs font-medium">{review.author_name}</p>
            {review.rating != null && (
              <div className="flex items-center gap-0.5 text-xs">
                <Star className="h-3 w-3 fill-amber-500 text-amber-500" />
                <span>{review.rating.toFixed(1)}</span>
              </div>
            )}
          </div>
          {review.posted_at && (
            <p className="text-[10px] text-muted-foreground">
              {formatDate(review.posted_at)}
            </p>
          )}
        </div>
      </div>
      {review.text && (
        <p className="mt-2 text-xs leading-relaxed text-foreground/80 line-clamp-4">
          {review.text}
        </p>
      )}
    </div>
  );
}
