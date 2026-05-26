"use client";

import { useState } from "react";
import Image, { type ImageProps } from "next/image";
import { ImageOff } from "lucide-react";
import { cn } from "@/lib/utils";

interface Props extends Omit<ImageProps, "src" | "alt"> {
  src: string | null | undefined;
  alt: string;
  /**
   * Fallback ko'rsatish uchun bitta marta yetib bormaganda — `false`
   * bo'lsa bo'sh placeholder (faqat ikon), `true` (default) bo'lsa
   * `ImageOff` ikon + muted background ko'rsatamiz.
   */
  showIconOnEmpty?: boolean;
  iconClassName?: string;
}

/**
 * Next.js `Image` ustida ishonchli wrapper. URL'siz yoki yuklanmasa,
 * broken-image piktogrammasi o'rniga muloyim placeholder ko'rsatadi.
 */
export function ImageWithFallback({
  src,
  alt,
  className,
  iconClassName,
  showIconOnEmpty = true,
  fill,
  ...rest
}: Props) {
  const [errored, setErrored] = useState(false);

  const hasSrc = Boolean(src) && !errored;

  if (!hasSrc) {
    return (
      <div
        className={cn(
          "flex items-center justify-center bg-muted text-muted-foreground",
          // `fill` modeda parent `relative` bo'lgani uchun placeholder
          // ham absolute-inset-0 bilan parentni to'liq qoplaydi.
          fill && "absolute inset-0",
          className,
        )}
        aria-label={alt}
        role="img"
      >
        {showIconOnEmpty && (
          <ImageOff className={cn("h-4 w-4 opacity-60", iconClassName)} />
        )}
      </div>
    );
  }

  return (
    <Image
      {...rest}
      fill={fill}
      src={src as string}
      alt={alt}
      className={className}
      onError={() => setErrored(true)}
      unoptimized
    />
  );
}
