"use client";

import { useRef, useState } from "react";
import { Loader2, Upload, X, Link2, GripVertical } from "lucide-react";
import { toast } from "sonner";

import { ImageWithFallback } from "@/components/image-with-fallback";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { api, extractErrorMessage } from "@/lib/api";
import { cn } from "@/lib/utils";

interface Props {
  value: string[];
  onChange: (next: string[]) => void;
  /** Backend upload endpoint — default `/uploads/post-image`. */
  uploadEndpoint?: string;
  className?: string;
}

interface UploadResult {
  url: string;
  key: string;
  size_bytes: number;
  content_type: string;
}

const ACCEPTED_MIME = "image/jpeg,image/png,image/webp,image/heic";

/**
 * Post (yoki galereya) uchun rasm ro'yxati muharriri.
 *
 * - URL bo'yicha qo'shish (Wikipedia, CDN, va h.k.)
 * - Lokal fayl yuklash → MinIO orqali public URL
 * - Drag handle (rad qilingan, faqat ko'rsatma; reorder oddiy ↑/↓ tugma orqali)
 * - Bitta rasm xato yuklansa, qolgan jarayon to'xtamaydi
 */
export function PostImagesEditor({
  value,
  onChange,
  uploadEndpoint = "/uploads/post-image",
  className,
}: Props) {
  const [urlInput, setUrlInput] = useState("");
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  function addUrl(raw: string) {
    const trimmed = raw.trim();
    if (!trimmed) return;
    // Oddiy URL validation: http(s)://
    if (!/^https?:\/\//i.test(trimmed)) {
      toast.error("URL `http://` yoki `https://` bilan boshlanishi kerak");
      return;
    }
    if (value.includes(trimmed)) {
      toast.warning("Bu rasm allaqachon qo'shilgan");
      return;
    }
    onChange([...value, trimmed]);
    setUrlInput("");
  }

  function removeAt(idx: number) {
    onChange(value.filter((_, i) => i !== idx));
  }

  function move(idx: number, direction: -1 | 1) {
    const next = [...value];
    const target = idx + direction;
    if (target < 0 || target >= next.length) return;
    [next[idx], next[target]] = [next[target], next[idx]];
    onChange(next);
  }

  async function handleFiles(files: FileList | null) {
    if (!files || files.length === 0) return;
    setUploading(true);
    const added: string[] = [];
    try {
      for (const file of Array.from(files)) {
        try {
          const formData = new FormData();
          formData.append("file", file);
          const response = await api.post<UploadResult>(uploadEndpoint, formData, {
            headers: { "Content-Type": "multipart/form-data" },
            timeout: 60_000,
          });
          added.push(response.data.url);
        } catch (error) {
          toast.error(
            `${file.name}: ${extractErrorMessage(error, "Yuklashda xatolik")}`,
          );
        }
      }
      if (added.length > 0) {
        onChange([...value, ...added]);
        toast.success(`${added.length} ta rasm yuklandi`);
      }
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  }

  return (
    <div className={cn("space-y-3", className)}>
      {/* Thumbnails list */}
      {value.length === 0 ? (
        <div className="rounded-md border border-dashed bg-muted/30 px-4 py-8 text-center text-sm text-muted-foreground">
          Hali rasm qo&apos;shilmagan. URL kiriting yoki fayl yuklang.
        </div>
      ) : (
        <ul className="space-y-2">
          {value.map((url, idx) => (
            <li
              key={`${idx}-${url}`}
              className="flex items-center gap-3 rounded-md border bg-card p-2"
            >
              <div className="flex flex-col gap-0.5 text-muted-foreground">
                <button
                  type="button"
                  onClick={() => move(idx, -1)}
                  disabled={idx === 0}
                  className="rounded p-0.5 hover:bg-muted disabled:opacity-30"
                  aria-label="Yuqoriga"
                >
                  <GripVertical className="h-3 w-3 rotate-90" />
                </button>
                <button
                  type="button"
                  onClick={() => move(idx, 1)}
                  disabled={idx === value.length - 1}
                  className="rounded p-0.5 hover:bg-muted disabled:opacity-30"
                  aria-label="Pastga"
                >
                  <GripVertical className="h-3 w-3 -rotate-90" />
                </button>
              </div>
              <ImageWithFallback
                src={url}
                alt={`Rasm ${idx + 1}`}
                width={64}
                height={48}
                className="h-12 w-16 flex-shrink-0 rounded object-cover"
              />
              <div className="min-w-0 flex-1">
                <p className="truncate text-xs text-muted-foreground">{url}</p>
                {idx === 0 && (
                  <span className="mt-0.5 inline-block rounded bg-primary/10 px-1.5 py-0.5 text-[10px] font-medium text-primary">
                    Asosiy
                  </span>
                )}
              </div>
              <Button
                type="button"
                size="icon"
                variant="ghost"
                onClick={() => removeAt(idx)}
                title="O'chirish"
              >
                <X className="h-4 w-4 text-destructive" />
              </Button>
            </li>
          ))}
        </ul>
      )}

      {/* Add via URL */}
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Link2 className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="https://example.com/image.jpg"
            value={urlInput}
            onChange={(e) => setUrlInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                addUrl(urlInput);
              }
            }}
            className="pl-9"
          />
        </div>
        <Button
          type="button"
          variant="outline"
          onClick={() => addUrl(urlInput)}
          disabled={!urlInput.trim()}
        >
          URL qo&apos;shish
        </Button>
      </div>

      {/* Upload */}
      <div className="flex items-center gap-2">
        <input
          ref={fileInputRef}
          type="file"
          accept={ACCEPTED_MIME}
          multiple
          className="hidden"
          onChange={(e) => handleFiles(e.target.files)}
        />
        <Button
          type="button"
          variant="outline"
          onClick={() => fileInputRef.current?.click()}
          disabled={uploading}
          className="w-full"
        >
          {uploading ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Upload className="h-4 w-4" />
          )}
          {uploading ? "Yuklanmoqda..." : "Fayl(lar) yuklash"}
        </Button>
      </div>
      <p className="text-xs text-muted-foreground">
        Maksimal 10 MB. Formatlar: JPEG, PNG, WebP, HEIC. Birinchi rasm — asosiy
        (preview sifatida ishlatiladi).
      </p>
    </div>
  );
}
