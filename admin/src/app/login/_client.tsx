"use client";

import { useState } from "react";
import { useLogin } from "@refinedev/core";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Loader2, ShieldCheck, User as UserIcon } from "lucide-react";
import { toast } from "sonner";
import { useGoogleReCaptcha } from "react-google-recaptcha-v3";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const loginSchema = z.object({
  identifier: z
    .string()
    .min(3, "Email yoki telefon kiriting")
    .max(255, "Juda uzun"),
  password: z
    .string()
    .min(6, "Kamida 6 belgi")
    .max(128, "Juda uzun"),
});

type LoginForm = z.infer<typeof loginSchema>;

export function LoginClient() {
  const [showPassword, setShowPassword] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const { mutate: login } = useLogin();
  const { executeRecaptcha } = useGoogleReCaptcha();

  const form = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
    defaultValues: { identifier: "", password: "" },
  });

  async function onSubmit(data: LoginForm) {
    setSubmitting(true);
    try {
      // Dev rejim: `NEXT_PUBLIC_RECAPTCHA_SITE_KEY` o'rnatilmagan bo'lsa,
      // provider ham mount qilinmagan — `executeRecaptcha` undefined bo'ladi.
      // Bunday holatda placeholder token yuboramiz (backend ham bo'sh secret
      // bilan verification skip qiladi). Backend schema `min_length=10`
      // ekanini hisobga olib, 10+ belgili token yuboramiz.
      const recaptchaToken = executeRecaptcha
        ? await executeRecaptcha("admin_login")
        : "dev-mode-no-recaptcha-token";

      login(
        {
          identifier: data.identifier.trim(),
          password: data.password,
          recaptcha_token: recaptchaToken,
        },
        {
          onSuccess: (result) => {
            if (!result?.success) {
              const message =
                (result?.error as { message?: string } | undefined)?.message ??
                "Kirish amalga oshmadi";
              toast.error(message);
            }
          },
          onError: (error) => {
            toast.error(error.message ?? "Kirish amalga oshmadi");
          },
          onSettled: () => setSubmitting(false),
        },
      );
    } catch (error) {
      console.error("[admin login]", error);
      toast.error("Kirishda kutilmagan xato");
      setSubmitting(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-primary/10 via-background to-background p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="space-y-2 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <ShieldCheck className="h-6 w-6 text-primary" />
          </div>
          <CardTitle className="text-2xl">DiscoverUzb Admin</CardTitle>
          <CardDescription>
            Email yoki telefon raqamingiz va parolingiz bilan kiring
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="identifier">Email yoki telefon</Label>
              <div className="relative">
                <UserIcon className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="identifier"
                  type="text"
                  autoComplete="username"
                  placeholder="admin@discoveruzb.local"
                  className="pl-9"
                  {...form.register("identifier")}
                />
              </div>
              {form.formState.errors.identifier && (
                <p className="text-sm text-destructive">
                  {form.formState.errors.identifier.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Parol</Label>
              <div className="relative">
                <Input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  placeholder="••••••••"
                  className="pr-10"
                  {...form.register("password")}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                  aria-label={showPassword ? "Parolni yashirish" : "Parolni ko'rsatish"}
                >
                  {showPassword ? (
                    <EyeOff className="h-4 w-4" />
                  ) : (
                    <Eye className="h-4 w-4" />
                  )}
                </button>
              </div>
              {form.formState.errors.password && (
                <p className="text-sm text-destructive">
                  {form.formState.errors.password.message}
                </p>
              )}
            </div>

            <Button
              type="submit"
              className="w-full"
              disabled={submitting}
            >
              {submitting && <Loader2 className="h-4 w-4 animate-spin" />}
              Kirish
            </Button>
          </form>
        </CardContent>
        <CardFooter className="flex flex-col gap-2">
          <p className="text-center text-xs text-muted-foreground">
            Bu sayt Google reCAPTCHA bilan himoyalangan —{" "}
            <a
              href="https://policies.google.com/privacy"
              target="_blank"
              rel="noreferrer"
              className="underline hover:text-foreground"
            >
              Maxfiylik
            </a>
            {" "}va{" "}
            <a
              href="https://policies.google.com/terms"
              target="_blank"
              rel="noreferrer"
              className="underline hover:text-foreground"
            >
              Shartlar
            </a>
            {" "}qo'llaniladi.
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
