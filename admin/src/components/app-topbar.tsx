"use client";

import { useGetIdentity, useLogout } from "@refinedev/core";
import { useTheme } from "next-themes";
import { LogOut, Moon, Sun, User as UserIcon } from "lucide-react";

import type { User } from "@/lib/auth-provider";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function AppTopbar() {
  const { data: identity } = useGetIdentity<User>();
  const { mutate: logout } = useLogout();
  const { theme, setTheme } = useTheme();

  const initial = identity?.fullname?.[0]?.toUpperCase() ?? "?";

  return (
    <header className="flex h-14 shrink-0 items-center justify-between border-b bg-background px-6">
      <div>
        {/* O'rta bo'sh qoldirildi — kelajakda breadcrumb yoki search */}
      </div>
      <div className="flex items-center gap-2">
        <Button
          variant="ghost"
          size="icon"
          onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          aria-label="Toggle theme"
        >
          <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
          <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-9 gap-2 px-2">
              <Avatar className="h-7 w-7">
                {identity?.img_url ? (
                  <AvatarImage src={identity.img_url} alt={identity.fullname} />
                ) : null}
                <AvatarFallback>{initial}</AvatarFallback>
              </Avatar>
              <div className="hidden text-left md:block">
                <p className="text-xs font-medium leading-tight">
                  {identity?.fullname ?? "..."}
                </p>
                <p className="text-[10px] uppercase leading-tight text-muted-foreground">
                  {identity?.role ?? ""}
                </p>
              </div>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>
              <div className="space-y-0.5">
                <p className="text-sm">{identity?.fullname}</p>
                <p className="text-xs font-normal text-muted-foreground">
                  {identity?.phone ?? identity?.email}
                </p>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem disabled>
              <UserIcon className="mr-2 h-4 w-4" />
              Profil (kelajakda)
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem onClick={() => logout()}>
              <LogOut className="mr-2 h-4 w-4" />
              Chiqish
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
