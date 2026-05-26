"use client";

import { useEffect, useState } from "react";
import {
  Users as UsersIcon,
  MapPin,
  MessageSquare,
  Image as ImageIcon,
  TrendingUp,
  UserPlus,
  Heart,
  Ban,
} from "lucide-react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { api, extractErrorMessage } from "@/lib/api";
import { formatNumber } from "@/lib/utils";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

interface DashboardStats {
  total_users: number;
  total_posts: number;
  total_comments: number;
  total_galleries: number;
  new_users_today: number;
  new_posts_today: number;
  top_post_likes: number;
  banned_users: number;
}

interface CountByDay {
  date: string;
  count: number;
}

interface CountByType {
  type: string;
  count: number;
}

const STATS_CARDS = [
  {
    key: "total_users" as const,
    label: "Foydalanuvchilar",
    icon: UsersIcon,
    accent: "text-primary",
  },
  {
    key: "total_posts" as const,
    label: "Postlar",
    icon: MapPin,
    accent: "text-emerald-600",
  },
  {
    key: "total_comments" as const,
    label: "Izohlar",
    icon: MessageSquare,
    accent: "text-orange-500",
  },
  {
    key: "total_galleries" as const,
    label: "Galereyalar",
    icon: ImageIcon,
    accent: "text-violet-500",
  },
  {
    key: "new_users_today" as const,
    label: "Bugungi yangi user",
    icon: UserPlus,
    accent: "text-sky-500",
  },
  {
    key: "new_posts_today" as const,
    label: "Bugungi yangi post",
    icon: TrendingUp,
    accent: "text-pink-500",
  },
  {
    key: "top_post_likes" as const,
    label: "Eng ko'p layk",
    icon: Heart,
    accent: "text-red-500",
  },
  {
    key: "banned_users" as const,
    label: "Bloklangan user",
    icon: Ban,
    accent: "text-destructive",
  },
];

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [usersByDay, setUsersByDay] = useState<CountByDay[]>([]);
  const [postsByType, setPostsByType] = useState<CountByType[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      try {
        const [statsRes, daysRes, typesRes] = await Promise.all([
          api.get<DashboardStats>("/stats/dashboard"),
          api.get<CountByDay[]>("/stats/users-by-day", { params: { days: 14 } }),
          api.get<CountByType[]>("/stats/posts-by-type"),
        ]);
        if (cancelled) return;
        setStats(statsRes.data);
        setUsersByDay(daysRes.data);
        setPostsByType(typesRes.data);
      } catch (err) {
        if (!cancelled)
          setError(extractErrorMessage(err, "Statistikani yuklashda xatolik"));
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
        <p className="text-sm text-muted-foreground">
          Tizimdagi asosiy ko'rsatkichlar
        </p>
      </div>

      {error && (
        <div className="rounded-md border border-destructive/50 bg-destructive/10 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      {/* Stats grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {STATS_CARDS.map((card) => {
          const Icon = card.icon;
          return (
            <Card key={card.key}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  {card.label}
                </CardTitle>
                <Icon className={`h-4 w-4 ${card.accent}`} />
              </CardHeader>
              <CardContent>
                {loading ? (
                  <Skeleton className="h-8 w-20" />
                ) : (
                  <div className="text-2xl font-bold">
                    {formatNumber(stats?.[card.key] ?? 0)}
                  </div>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Charts */}
      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Yangi foydalanuvchilar (14 kun)</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-64 w-full" />
            ) : usersByDay.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                Hali ma'lumot yo'q
              </p>
            ) : (
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={usersByDay}>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                  <XAxis
                    dataKey="date"
                    tickFormatter={(d) =>
                      new Date(d).toLocaleDateString("uz-UZ", {
                        month: "short",
                        day: "numeric",
                      })
                    }
                    fontSize={11}
                  />
                  <YAxis fontSize={11} allowDecimals={false} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--popover))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                    }}
                  />
                  <Bar
                    dataKey="count"
                    fill="hsl(var(--chart-1))"
                    radius={[4, 4, 0, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Postlar turlari bo'yicha</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-64 w-full" />
            ) : postsByType.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                Hali ma'lumot yo'q
              </p>
            ) : (
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={postsByType} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                  <XAxis type="number" fontSize={11} allowDecimals={false} />
                  <YAxis
                    type="category"
                    dataKey="type"
                    fontSize={11}
                    width={100}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--popover))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                    }}
                  />
                  <Bar
                    dataKey="count"
                    fill="hsl(var(--chart-2))"
                    radius={[0, 4, 4, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
