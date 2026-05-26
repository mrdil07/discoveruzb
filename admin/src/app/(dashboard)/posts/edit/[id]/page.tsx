"use client";

import { use } from "react";
import { useShow, useUpdate, type HttpError } from "@refinedev/core";
import { ArrowLeft, Loader2, Save } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";
import { PostImagesEditor } from "@/components/post-images-editor";

import { ExternalReviewsPanel } from "./_external-reviews-panel";

const postSchema = z.object({
  place_name: z.string().min(1, "Joy nomi kiritilishi shart").max(200),
  place_info: z.string().min(1, "Tavsif kiritilishi shart"),
  address: z.string().min(1, "Manzil kiritilishi shart").max(300),
  type: z.string().min(1, "Tur kiritilishi shart").max(50),
  source: z.string().nullish(),
  price: z.string().nullish(),
  images: z.array(z.string().url("Yaroqli URL kerak")).default([]),
  lat: z.coerce.number().min(-90).max(90),
  lon: z.coerce.number().min(-180).max(180),
  is_published: z.boolean(),
  google_place_id: z.string().max(255).nullish(),
  yandex_place_id: z.string().max(255).nullish(),
  gis_place_id: z.string().max(255).nullish(),
});

type PostFormValues = z.infer<typeof postSchema>;

interface PostDetail extends PostFormValues {
  id: string;
  author?: { id: string; fullname: string } | null;
  like_count: number;
  created_at: string;
}

export default function PostEditPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();

  const {
    queryResult: { data, isLoading: isLoadingPost, error: loadError },
  } = useShow<PostDetail, HttpError>({ resource: "posts", id });

  // Refine 4 / TanStack Query v5 → `isPending` (not `isLoading`)
  const { mutate: updatePost, isPending: isSaving } = useUpdate();

  const form = useForm<PostFormValues>({
    resolver: zodResolver(postSchema),
    defaultValues: {
      place_name: "",
      place_info: "",
      address: "",
      type: "",
      source: "",
      price: "",
      images: [],
      lat: 0,
      lon: 0,
      is_published: true,
      google_place_id: "",
      yandex_place_id: "",
      gis_place_id: "",
    },
  });

  // Backend javobi kelganda formni to'ldirish
  useEffect(() => {
    const post = data?.data;
    if (!post) return;
    form.reset({
      place_name: post.place_name,
      place_info: post.place_info,
      address: post.address,
      type: post.type,
      source: post.source ?? "",
      price: post.price ?? "",
      images: post.images ?? [],
      lat: post.lat,
      lon: post.lon,
      is_published: post.is_published,
      google_place_id: post.google_place_id ?? "",
      yandex_place_id: post.yandex_place_id ?? "",
      gis_place_id: post.gis_place_id ?? "",
    });
  }, [data, form]);

  function onSubmit(values: PostFormValues) {
    const payload = {
      ...values,
      // Bo'sh string'larni null qilamiz (backend Optional kutadi)
      source: values.source || null,
      price: values.price || null,
      google_place_id: values.google_place_id || null,
      yandex_place_id: values.yandex_place_id || null,
      gis_place_id: values.gis_place_id || null,
    };
    updatePost(
      { resource: "posts", id, values: payload },
      {
        onSuccess: () => {
          toast.success("Saqlandi", { description: values.place_name });
        },
        onError: (err) => toast.error(err.message ?? "Saqlashda xatolik"),
      },
    );
  }

  if (loadError) {
    return (
      <div className="space-y-4">
        <Button variant="ghost" asChild>
          <Link href="/posts">
            <ArrowLeft className="mr-2 h-4 w-4" /> Postlar
          </Link>
        </Button>
        <Card>
          <CardContent className="py-12 text-center text-destructive">
            Postni yuklashda xatolik
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Button size="icon" variant="ghost" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-2xl font-semibold tracking-tight">
              {isLoadingPost ? (
                <Skeleton className="h-7 w-64" />
              ) : (
                data?.data.place_name
              )}
            </h1>
            <p className="text-sm text-muted-foreground">
              Post tafsilotlarini tahrirlash
            </p>
          </div>
        </div>
        <Button
          onClick={form.handleSubmit(onSubmit)}
          disabled={isSaving || isLoadingPost}
        >
          {isSaving ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Save className="h-4 w-4" />
          )}
          Saqlash
        </Button>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Asosiy form */}
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Asosiy ma&apos;lumotlar</CardTitle>
            </CardHeader>
            <CardContent>
              <form
                onSubmit={form.handleSubmit(onSubmit)}
                className="space-y-4"
              >
                <FormField
                  label="Joy nomi"
                  error={form.formState.errors.place_name?.message}
                >
                  <Input {...form.register("place_name")} />
                </FormField>

                <FormField
                  label="Manzil"
                  error={form.formState.errors.address?.message}
                >
                  <Input {...form.register("address")} />
                </FormField>

                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    label="Tur (kategoriya slug)"
                    error={form.formState.errors.type?.message}
                  >
                    <Input
                      {...form.register("type")}
                      placeholder="historical"
                    />
                  </FormField>
                  <FormField label="Narx">
                    <Input
                      {...form.register("price")}
                      placeholder="Bepul yoki 30 000 so'm"
                    />
                  </FormField>
                </div>

                <FormField
                  label="Tavsif"
                  error={form.formState.errors.place_info?.message}
                >
                  <Textarea
                    {...form.register("place_info")}
                    rows={6}
                    placeholder="Joy haqida batafsil ma'lumot..."
                  />
                </FormField>

                <FormField label="Manba (havola yoki nom)">
                  <Input
                    {...form.register("source")}
                    placeholder="Wikipedia, Lonely Planet..."
                  />
                </FormField>

                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    label="Latitude"
                    error={form.formState.errors.lat?.message}
                  >
                    <Input
                      type="number"
                      step="any"
                      {...form.register("lat")}
                    />
                  </FormField>
                  <FormField
                    label="Longitude"
                    error={form.formState.errors.lon?.message}
                  >
                    <Input
                      type="number"
                      step="any"
                      {...form.register("lon")}
                    />
                  </FormField>
                </div>

                <div className="flex items-center justify-between rounded-md border p-3">
                  <div>
                    <Label htmlFor="is_published" className="font-medium">
                      Nashr qilingan
                    </Label>
                    <p className="text-xs text-muted-foreground">
                      Faqat nashr qilingan postlar mobile&apos;da ko&apos;rinadi
                    </p>
                  </div>
                  <Switch
                    id="is_published"
                    checked={form.watch("is_published")}
                    onCheckedChange={(v) => form.setValue("is_published", v)}
                  />
                </div>
              </form>
            </CardContent>
          </Card>

          {/* Rasmlar */}
          <Card>
            <CardHeader>
              <CardTitle>Rasmlar</CardTitle>
              <CardDescription>
                Mobile ilovada slayder sifatida ko&apos;rsatiladi. Birinchi rasm
                — kartochkalardagi preview.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <PostImagesEditor
                value={form.watch("images") ?? []}
                onChange={(next) =>
                  form.setValue("images", next, { shouldDirty: true })
                }
              />
            </CardContent>
          </Card>

          {/* External map place IDs */}
          <Card>
            <CardHeader>
              <CardTitle>Tashqi xarita ID lari</CardTitle>
              <CardDescription>
                Google Maps, Yandex Maps va 2GIS&apos;dan sharhlarni avtomatik
                yig&apos;ish uchun joy ID&apos;lari. Bo&apos;sh qoldirsa,
                tegishli manbadan sharhlar yig&apos;ilmaydi.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <FormField
                label="Google Place ID"
                hint="Misol: ChIJsRyHpJALaBgRsbsOFv1eWQ4 — Google Maps URL'dan yoki Place ID Finder orqali olinadi."
              >
                <Input
                  {...form.register("google_place_id")}
                  placeholder="ChIJ..."
                />
              </FormField>
              <FormField
                label="Yandex Place URI / Org ID"
                hint="Misol: 1234567890 — Yandex Maps URL'dan."
              >
                <Input
                  {...form.register("yandex_place_id")}
                  placeholder="1234567890 yoki ymapsbm1://..."
                />
              </FormField>
              <FormField
                label="2GIS Branch ID"
                hint="Misol: 70030076175123456 — 2GIS URL'dan."
              >
                <Input
                  {...form.register("gis_place_id")}
                  placeholder="70030076..."
                />
              </FormField>
              <p className="text-xs text-muted-foreground">
                Batafsil:{" "}
                <code className="rounded bg-muted px-1">
                  docs/external-reviews-setup.md
                </code>
              </p>
            </CardContent>
          </Card>
        </div>

        {/* External reviews panel — sidebar */}
        <div className="space-y-6">
          <ExternalReviewsPanel postId={id} />
        </div>
      </div>
    </div>
  );
}

function FormField({
  label,
  hint,
  error,
  children,
}: {
  label: string;
  hint?: string;
  error?: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-1.5">
      <Label className="font-medium">{label}</Label>
      {children}
      {hint && !error && (
        <p className="text-xs text-muted-foreground">{hint}</p>
      )}
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  );
}
