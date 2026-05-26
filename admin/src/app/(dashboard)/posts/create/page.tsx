"use client";

import { useCreate, useList, type HttpError } from "@refinedev/core";
import { ArrowLeft, Loader2, Save } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { PostImagesEditor } from "@/components/post-images-editor";

const postSchema = z.object({
  place_name: z.string().min(1, "Joy nomi kiritilishi shart").max(200),
  place_info: z.string().min(1, "Tavsif kiritilishi shart"),
  address: z.string().min(1, "Manzil kiritilishi shart").max(300),
  type: z.string().min(1, "Kategoriya tanlang").max(50),
  source: z.string().optional(),
  price: z.string().optional(),
  images: z.array(z.string().url("Yaroqli URL kerak")).default([]),
  lat: z.coerce.number().min(-90).max(90),
  lon: z.coerce.number().min(-180).max(180),
  is_published: z.boolean(),
  google_place_id: z.string().max(255).optional(),
  yandex_place_id: z.string().max(255).optional(),
  gis_place_id: z.string().max(255).optional(),
});

type PostFormValues = z.infer<typeof postSchema>;

interface CategoryRow {
  slug: string;
  name_uz: string;
  name_ru?: string;
  name_en?: string;
}

export default function PostCreatePage() {
  const router = useRouter();

  const { data: catsData } = useList<CategoryRow, HttpError>({
    resource: "categories",
    pagination: { mode: "off" },
  });
  const categories = catsData?.data ?? [];

  // Refine 4 / TanStack Query v5 → `isPending` (not `isLoading`)
  const { mutate: createPost, isPending: isSaving } = useCreate();

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
      lat: 41.311081, // Tashkent default
      lon: 69.240562,
      is_published: true,
      google_place_id: "",
      yandex_place_id: "",
      gis_place_id: "",
    },
  });

  function onSubmit(values: PostFormValues) {
    const payload = {
      ...values,
      source: values.source || null,
      price: values.price || null,
      google_place_id: values.google_place_id || null,
      yandex_place_id: values.yandex_place_id || null,
      gis_place_id: values.gis_place_id || null,
    };
    createPost(
      { resource: "posts", values: payload },
      {
        onSuccess: (result) => {
          toast.success("Post yaratildi", { description: values.place_name });
          const id = (result?.data as { id?: string } | undefined)?.id;
          if (id) {
            router.push(`/posts/edit/${id}`);
          } else {
            router.push("/posts");
          }
        },
        onError: (err) => toast.error(err.message ?? "Yaratishda xatolik"),
      },
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Button size="icon" variant="ghost" asChild>
            <Link href="/posts">
              <ArrowLeft className="h-4 w-4" />
            </Link>
          </Button>
          <div>
            <h1 className="text-2xl font-semibold tracking-tight">Yangi post</h1>
            <p className="text-sm text-muted-foreground">
              Turistik joy haqida ma&apos;lumot qo&apos;shish
            </p>
          </div>
        </div>
        <Button
          onClick={form.handleSubmit(onSubmit)}
          disabled={isSaving}
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
        <div className="lg:col-span-2 space-y-6">
          {/* Asosiy ma'lumotlar */}
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
                  <Input
                    {...form.register("place_name")}
                    placeholder="Masalan: Registon maydoni"
                  />
                </FormField>

                <FormField
                  label="Manzil"
                  error={form.formState.errors.address?.message}
                >
                  <Input
                    {...form.register("address")}
                    placeholder="Samarqand, Registon ko'chasi"
                  />
                </FormField>

                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    label="Kategoriya"
                    error={form.formState.errors.type?.message}
                  >
                    <Select
                      value={form.watch("type")}
                      onValueChange={(v) =>
                        form.setValue("type", v, { shouldValidate: true })
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Tanlang..." />
                      </SelectTrigger>
                      <SelectContent>
                        {categories.map((cat) => (
                          <SelectItem key={cat.slug} value={cat.slug}>
                            {cat.name_uz}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
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
                    hint="Masalan: 41.311 (Toshkent)"
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
                    hint="Masalan: 69.279"
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
              <CardTitle>Tashqi xarita ID lari (ixtiyoriy)</CardTitle>
              <CardDescription>
                Google Maps, Yandex Maps va 2GIS&apos;dan sharhlarni avtomatik
                yig&apos;ish uchun joy ID&apos;lari.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <FormField label="Google Place ID">
                <Input
                  {...form.register("google_place_id")}
                  placeholder="ChIJ..."
                />
              </FormField>
              <FormField label="Yandex Place URI / Org ID">
                <Input
                  {...form.register("yandex_place_id")}
                  placeholder="1234567890 yoki ymapsbm1://..."
                />
              </FormField>
              <FormField label="2GIS Branch ID">
                <Input
                  {...form.register("gis_place_id")}
                  placeholder="70030076..."
                />
              </FormField>
            </CardContent>
          </Card>
        </div>

        {/* Sidebar — tips */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Maslahatlar</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-sm text-muted-foreground">
              <p>
                <strong className="text-foreground">Yaxshi tavsif</strong> — 100+ so&apos;z, joy
                tarixi, qiziqarli faktlar, qachon borish kerakligi.
              </p>
              <p>
                <strong className="text-foreground">Rasmlar</strong> — kamida 3 ta, eng yaxshisi
                gorizontal, 1280×720+ piksel.
              </p>
              <p>
                <strong className="text-foreground">Koordinatalar</strong> — Google Maps&apos;da
                joyga right-click qilib koordinatalarni nusxalash mumkin.
              </p>
            </CardContent>
          </Card>
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
