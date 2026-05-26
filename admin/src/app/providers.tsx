"use client";

import { Refine } from "@refinedev/core";
import routerProvider from "@refinedev/nextjs-router";
import { ThemeProvider } from "next-themes";
import { Toaster } from "sonner";
import { GoogleReCaptchaProvider } from "react-google-recaptcha-v3";
import {
  LayoutDashboard,
  Users,
  MapPin,
  MessageSquare,
  Image as ImageIcon,
  FolderTree,
} from "lucide-react";

import { authProvider } from "@/lib/auth-provider";
import { dataProvider } from "@/lib/data-provider";

// Productionda `.env.local` da `NEXT_PUBLIC_RECAPTCHA_SITE_KEY` o'rnating.
// Bo'sh bo'lsa — reCAPTCHA umuman yuklanmaydi (dev rejim, backend ham skip
// qiladi). Bu yerda `dev test` kalitini default qilmaymiz: u v2 uchun
// mo'ljallangan va v3 script bilan "Invalid site key" qizil xato beradi.
const RECAPTCHA_SITE_KEY = process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY;

function MaybeRecaptcha({ children }: { children: React.ReactNode }) {
  if (!RECAPTCHA_SITE_KEY) return <>{children}</>;
  return (
    <GoogleReCaptchaProvider
      reCaptchaKey={RECAPTCHA_SITE_KEY}
      scriptProps={{ async: true, defer: true, appendTo: "head" }}
    >
      {children}
    </GoogleReCaptchaProvider>
  );
}

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <MaybeRecaptcha>
      <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      <Refine
        routerProvider={routerProvider}
        authProvider={authProvider}
        dataProvider={dataProvider}
        resources={[
          {
            name: "dashboard",
            list: "/",
            meta: {
              label: "Dashboard",
              icon: <LayoutDashboard className="h-4 w-4" />,
            },
          },
          {
            name: "users",
            list: "/users",
            edit: "/users/edit/:id",
            show: "/users/show/:id",
            meta: {
              label: "Foydalanuvchilar",
              icon: <Users className="h-4 w-4" />,
            },
          },
          {
            name: "posts",
            list: "/posts",
            create: "/posts/create",
            edit: "/posts/edit/:id",
            show: "/posts/show/:id",
            meta: {
              label: "Postlar",
              icon: <MapPin className="h-4 w-4" />,
            },
          },
          {
            name: "comments",
            list: "/comments",
            meta: {
              label: "Izohlar",
              icon: <MessageSquare className="h-4 w-4" />,
            },
          },
          {
            name: "galleries",
            list: "/galleries",
            meta: {
              label: "Galereyalar",
              icon: <ImageIcon className="h-4 w-4" />,
            },
          },
          {
            name: "categories",
            list: "/categories",
            meta: {
              label: "Kategoriyalar",
              icon: <FolderTree className="h-4 w-4" />,
            },
          },
        ]}
        options={{
          syncWithLocation: true,
          warnWhenUnsavedChanges: true,
          disableTelemetry: true,
        }}
      >
        {children}
        <Toaster richColors position="top-right" />
      </Refine>
    </ThemeProvider>
    </MaybeRecaptcha>
  );
}
